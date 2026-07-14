from rest_framework import serializers
from .models import GroceryItem, GroceryActivity
from rest_framework.exceptions import ValidationError
import math

class GroceryItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = GroceryItem
        fields = '__all__'
        read_only_fields = ('id', 'user', 'status', 'created_at', 'updated_at', 'notified_3d', 'notified_1d')

    def validate_quantity(self, value):
        if value is None:
            raise ValidationError("Quantity is required.")
        if math.isnan(value) or math.isinf(value):
            raise ValidationError("Quantity must be a valid finite number.")
        if value <= 0:
            raise ValidationError("Quantity must be greater than zero.")
        if value > 10000:
            raise ValidationError("Quantity exceeds the maximum permitted limit.")
        return value

    def validate(self, attrs):
        expiry_date = attrs.get('expiry_date')
        purchase_date = attrs.get('purchase_date')

        # If compiling partial updates, pull existing values for comparison
        if self.instance:
            if expiry_date is None and 'expiry_date' not in attrs:
                expiry_date = self.instance.expiry_date
            if purchase_date is None and 'purchase_date' not in attrs:
                purchase_date = self.instance.purchase_date

        if expiry_date and purchase_date:
            if expiry_date < purchase_date:
                raise ValidationError({"expiry_date": "Expiry date must be equal to or after the purchase date."})

        return attrs

class GroceryActivitySerializer(serializers.ModelSerializer):
    class Meta:
        model = GroceryActivity
        fields = '__all__'
        read_only_fields = ('id', 'user', 'created_at')
