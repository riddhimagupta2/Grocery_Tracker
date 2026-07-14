from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.decorators import action
from django.db import transaction
from django.db.models import Count
from .models import GroceryList, GroceryListItem
from .serializers import GroceryListSerializer, GroceryListItemSerializer, GroceryListItemCreateSerializer
from apps.groceries.models import GroceryItem, GroceryActivity
from apps.groceries.serializers import GroceryItemSerializer
from common.exceptions import ResourceNotFoundException, ForbiddenException
import logging

logger = logging.getLogger('freshtrack.grocery_lists')

class GroceryListViewSet(viewsets.ModelViewSet):
    serializer_class = GroceryListSerializer

    def get_queryset(self):
        # IDOR protection: scoped to request.user
        return GroceryList.objects.filter(user=self.request.user)

    @action(detail=False, methods=['get'])
    def current(self, request):
        user = request.user
        # Find active list or create a blank one
        list_obj = GroceryList.objects.filter(user=user, status=GroceryList.Statuses.ACTIVE).first()
        if not list_obj:
            list_obj = GroceryList.objects.create(
                user=user,
                status=GroceryList.Statuses.ACTIVE,
                generation_reason="Initial manual list"
            )
        serializer = GroceryListSerializer(list_obj)
        return Response({
            "success": True,
            "data": serializer.data
        })

    @action(detail=False, methods=['post'])
    def generate(self, request):
        user = request.user
        
        # 1. Fetch user activities
        activities = GroceryActivity.objects.filter(user=user)
        if activities.count() < 3:
            return Response({
                "success": False,
                "error": "Not enough history to generate list. Add more items and log consumption/waste to generate suggestions."
            }, status=400)

        # 2. Analyze usage frequency
        top_items = activities.values('grocery_item__name', 'unit').annotate(
            count=Count('id')
        ).order_by('-count')[:5]

        # 3. Create grocery list
        with transaction.atomic():
            # Archive old active list
            GroceryList.objects.filter(user=user, status=GroceryList.Statuses.ACTIVE).update(
                status=GroceryList.Statuses.ARCHIVED
            )
            
            new_list = GroceryList.objects.create(
                user=user,
                status=GroceryList.Statuses.ACTIVE,
                generation_reason="Replenishment analysis"
            )

            for item_info in top_items:
                name = item_info['grocery_item__name']
                unit = item_info['unit']
                if not name:
                    continue

                # Check if item is already present in pantry
                pantry_qty = GroceryItem.objects.filter(
                    user=user, name__iexact=name
                ).exclude(quantity=0).first()

                if not pantry_qty or pantry_qty.quantity < 0.5:
                    reason = f"You frequently use {name} and your stock is low."
                    
                    # Create suggestion item
                    GroceryListItem.objects.create(
                        grocery_list=new_list,
                        name=name,
                        suggested_quantity=1.0,
                        quantity=1.0,
                        unit=unit or 'pcs',
                        reason=reason,
                        confidence='High'
                    )

            # Re-fetch with populated items
            new_list.refresh_from_db()

        serializer = GroceryListSerializer(new_list)
        return Response({
            "success": True,
            "data": serializer.data,
            "message": "Suggested grocery list generated successfully."
        })

    @action(detail=True, methods=['post'], url_path='items')
    def add_item(self, request, pk=None):
        list_obj = self.get_object()
        serializer = GroceryListItemCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        with transaction.atomic():
            item = GroceryListItem.objects.create(
                grocery_list=list_obj,
                name=serializer.validated_data['name'],
                suggested_quantity=serializer.validated_data.get('quantity', 1.0),
                quantity=serializer.validated_data.get('quantity', 1.0),
                unit=serializer.validated_data.get('unit', 'pcs'),
                reason="Added manually",
                confidence="High",
                feedback=GroceryListItem.Feedbacks.ACCEPTED
            )
            return Response({
                "success": True,
                "data": GroceryListItemSerializer(item).data,
                "message": f"Added {item.name} to grocery list."
            }, status=201)

    @action(detail=True, methods=['PATCH', 'DELETE'], url_path='items/(?P<item_pk>[^/.]+)')
    def manage_item(self, request, pk=None, item_pk=None):
        list_obj = self.get_object()
        try:
            item = list_obj.items.get(id=item_pk)
        except GroceryListItem.DoesNotExist:
            raise ResourceNotFoundException("Item not found in grocery list.")

        if request.method == 'DELETE':
            item.delete()
            return Response({
                "success": True,
                "data": {},
                "message": "Item removed from grocery list."
            })

        old_qty = item.quantity
        serializer = GroceryListItemSerializer(item, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        updated_item = serializer.save()

        # Update feedback automatically if quantity edited
        if old_qty != updated_item.quantity and updated_item.feedback == GroceryListItem.Feedbacks.PENDING:
            updated_item.feedback = GroceryListItem.Feedbacks.EDITED
            updated_item.save(update_fields=['feedback'])

        return Response({
            "success": True,
            "data": GroceryListItemSerializer(updated_item).data,
            "message": "Item updated successfully."
        })

    @action(detail=True, methods=['post'], url_path='items/(?P<item_pk>[^/.]+)/feedback')
    def set_feedback(self, request, pk=None, item_pk=None):
        list_obj = self.get_object()
        try:
            item = list_obj.items.get(id=item_pk)
        except GroceryListItem.DoesNotExist:
            raise ResourceNotFoundException("Item not found in grocery list.")

        feedback_val = request.data.get('feedback')
        if feedback_val not in GroceryListItem.Feedbacks.values:
            return Response({"success": False, "error": "Invalid feedback type."}, status=400)

        item.feedback = feedback_val
        item.save(update_fields=['feedback'])
        return Response({
            "success": True,
            "data": GroceryListItemSerializer(item).data,
            "message": f"Feedback updated to {feedback_val}"
        })

    @action(detail=True, methods=['post'], url_path='items/(?P<item_pk>[^/.]+)/mark-purchased')
    def mark_purchased(self, request, pk=None, item_pk=None):
        list_obj = self.get_object()
        try:
            item = list_obj.items.get(id=item_pk)
        except GroceryListItem.DoesNotExist:
            raise ResourceNotFoundException("Item not found in grocery list.")

        if item.purchased:
            return Response({"success": False, "error": "Item is already marked purchased."}, status=400)

        with transaction.atomic():
            item.purchased = True
            item.feedback = GroceryListItem.Feedbacks.ACCEPTED
            item.save()

            # Insert into pantry
            pantry_item = GroceryItem.objects.create(
                user=request.user,
                name=item.name,
                quantity=item.quantity,
                unit=item.unit,
                storage_zone='pantry' # default
            )

            # Record Activity
            GroceryActivity.objects.create(
                user=request.user,
                grocery_item=pantry_item,
                activity_type=GroceryActivity.ActivityTypes.ITEM_ADDED,
                new_quantity=pantry_item.quantity,
                unit=pantry_item.unit,
                metadata={'source': 'grocery_list'}
            )

            # Update stats
            user = request.user
            user.total_tracked += 1
            user.save(update_fields=['total_tracked'])

        return Response({
            "success": True,
            "data": GroceryItemSerializer(pantry_item).data,
            "message": f"Successfully purchased {item.name} and added to kitchen."
        })
