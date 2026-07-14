from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ScanSessionViewSet, ScanCandidateViewSet

router = DefaultRouter()
router.register(r'sessions', ScanSessionViewSet, basename='scan_session')
router.register(r'candidates', ScanCandidateViewSet, basename='scan_candidate')

# Standardize path mapping
urlpatterns = [
    path('', include(router.urls)),
]
