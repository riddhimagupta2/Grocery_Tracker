from rest_framework import serializers
from .models import ScanSession, ScanImage, ScanCandidate

class ScanImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = ScanImage
        fields = ('id', 'status', 'error_message', 'created_at')

class ScanCandidateSerializer(serializers.ModelSerializer):
    class Meta:
        model = ScanCandidate
        fields = '__all__'
        read_only_fields = ('id', 'scan_session', 'source_image', 'created_at')

class ScanSessionSerializer(serializers.ModelSerializer):
    images = ScanImageSerializer(many=True, read_only=True)
    
    class Meta:
        model = ScanSession
        fields = (
            'id', 'status', 'image_count', 'successful_image_count',
            'failed_image_count', 'candidate_count', 'idempotency_key',
            'completed_at', 'created_at', 'updated_at', 'images'
        )
        read_only_fields = ('id', 'status', 'image_count', 'successful_image_count', 'failed_image_count', 'candidate_count', 'completed_at', 'created_at', 'updated_at')
