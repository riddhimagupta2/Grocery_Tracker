from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models
import uuid

class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('The Email field must be set')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        return self.create_user(email, password, **extra_fields)

class User(AbstractUser):
    objects = UserManager()
    
    # Overwrite username fields since email is the primary login
    username = None
    email = models.EmailField(unique=True)
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    display_name = models.CharField(max_length=80, blank=True)
    avatar_url = models.URLField(blank=True, null=True)
    email_verified = models.BooleanField(default=False)
    
    # Preferences
    diet_type = models.CharField(
        max_length=20, 
        choices=[('veg', 'Vegetarian'), ('non-veg', 'Non-Vegetarian'), ('any', 'Any')], 
        default='any'
    )
    cuisine_pref = models.CharField(max_length=100, blank=True)
    allergies = models.JSONField(default=list, blank=True)
    household_size = models.PositiveIntegerField(default=1)
    
    # Notifications Settings
    notify_3_days = models.BooleanField(default=True)
    notify_1_day = models.BooleanField(default=True)
    notify_daily_recipe = models.BooleanField(default=True)
    
    # Server-derived stats
    total_tracked = models.PositiveIntegerField(default=0)
    saved_from_waste = models.PositiveIntegerField(default=0)
    recipes_cooked = models.PositiveIntegerField(default=0)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    def __str__(self):
        return self.email
