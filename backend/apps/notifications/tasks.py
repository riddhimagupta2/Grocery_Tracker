from celery import shared_task
from django.utils import timezone
from django.db import transaction
from django.contrib.auth import get_user_model
from apps.groceries.models import GroceryItem
from .models import DeviceToken
import logging
import datetime

logger = logging.getLogger('freshtrack.notifications.tasks')
User = get_user_model()

@shared_task
def send_expiry_alerts_task():
    logger.info("Executing periodic expiry check alerts task...")
    today = timezone.now().date()
    
    # 1. Query active items that are expiring in 3 days or 1 day and haven't been alerted yet
    items_3d = GroceryItem.objects.filter(
        expiry_date=today + datetime.timedelta(days=3),
        notified_3d=False,
        quantity__gt=0
    )
    items_1d = GroceryItem.objects.filter(
        expiry_date=today + datetime.timedelta(days=1),
        notified_1d=False,
        quantity__gt=0
    )

    # 2. Process 3-day alerts
    for item in items_3d:
        user = item.user
        if user.notify_3_days:
            message_body = f"Your {item.name} is expiring in 3 days! Plan a recipe to cook it soon."
            _send_push_notification(user, "Grocery Expiry Alert 🥦", message_body)
            item.notified_3d = True
            item.save(update_fields=['notified_3d'])

    # 3. Process 1-day alerts
    for item in items_1d:
        user = item.user
        if user.notify_1_day:
            message_body = f"Urgent: Your {item.name} is expiring tomorrow! Cook it today to avoid waste."
            _send_push_notification(user, "Urgent Expiry Alert ⚠️", message_body)
            item.notified_1d = True
            item.save(update_fields=['notified_1d'])

    # 4. Auto-update expired statuses daily
    expired_items = GroceryItem.objects.filter(
        expiry_date__lt=today,
        status='fresh', # or 'expiring'
        quantity__gt=0
    )
    for item in expired_items:
        # Saving triggers model logic to update status to 'expired'
        item.save(update_fields=['status'])

    return True

def _send_push_notification(user, title, body):
    # Retrieve all tokens registered for this user
    tokens = DeviceToken.objects.filter(user=user)
    if not tokens.exists():
        logger.info(f"Notification skipped for {user.email}: No device tokens registered")
        return

    logger.info(f"Sending Push Alert to {user.email}: Title='{title}', Body='{body}' across {tokens.count()} devices.")
    
    # Try sending via Firebase Admin SDK if initialized
    try:
        import firebase_admin
        from firebase_admin import messaging
        
        if firebase_admin._apps:
            for token_obj in tokens:
                try:
                    msg = messaging.Message(
                        notification=messaging.Notification(
                            title=title,
                            body=body,
                        ),
                        token=token_obj.token,
                    )
                    messaging.send(msg)
                    logger.info(f"FCM Notification sent successfully to token {token_obj.token[:15]}...")
                except Exception as token_err:
                    logger.warning(f"Failed to send FCM to token {token_obj.token[:15]}: {str(token_err)}")
        else:
            logger.info(f"Firebase Admin not initialized. Simulated push: Title='{title}', Body='{body}'")
    except ImportError:
        logger.info(f"firebase-admin module not available. Simulated push: Title='{title}', Body='{body}'")

