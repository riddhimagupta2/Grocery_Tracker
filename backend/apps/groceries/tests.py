from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from django.utils import timezone
from .models import GroceryItem
import datetime

User = get_user_model()

class GroceryAPITests(APITestCase):
    def setUp(self):
        self.user1 = User.objects.create_user(
            email='user1@example.com',
            password='Password123!',
            display_name='User One'
        )
        self.user2 = User.objects.create_user(
            email='user2@example.com',
            password='Password123!',
            display_name='User Two'
        )
        
        # Create item for User 1
        self.item1 = GroceryItem.objects.create(
            user=self.user1,
            name='User 1 Milk',
            quantity=2.0,
            unit='pcs',
            storage_zone='fridge',
            expiry_date=timezone.now().date() + datetime.timedelta(days=5)
        )
        
        self.list_url = '/api/v1/groceries/'
        self.detail_url = f'/api/v1/groceries/{self.item1.id}/'

    def test_status_calculation_fresh(self):
        """Ensure status calculates correctly based on expiry date."""
        self.assertEqual(self.item1.status, 'fresh')
        
        # Test expiring
        item2 = GroceryItem.objects.create(
            user=self.user1,
            name='Expiring Cheese',
            quantity=1.0,
            expiry_date=timezone.now().date() + datetime.timedelta(days=2)
        )
        self.assertEqual(item2.status, 'expiring')
        
        # Test expired
        item3 = GroceryItem.objects.create(
            user=self.user1,
            name='Expired Bread',
            quantity=1.0,
            expiry_date=timezone.now().date() - datetime.timedelta(days=1)
        )
        self.assertEqual(item3.status, 'expired')

    def test_idor_protection(self):
        """Ensure User 2 cannot access or modify User 1's grocery items."""
        # Authenticate as User 2
        self.client.force_authenticate(user=self.user2)
        
        # GET list should be empty for User 2
        response = self.client.get(self.list_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results'] if 'results' in response.data else response.data), 0)

        # GET detail of User 1's item should return 404 Not Found (or 403)
        response = self.client.get(self.detail_url)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

        # POST consume to User 1's item should return 404 Not Found
        response = self.client.post(self.detail_url + 'consume/')
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
