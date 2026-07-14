from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import GroceryItemViewSet

router = DefaultRouter()
router.register(r'', GroceryItemViewSet, basename='grocery')

urlpatterns = [
    path('', include(router.urls)),
]
