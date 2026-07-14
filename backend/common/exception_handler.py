import logging
import uuid
from rest_framework.views import exception_handler
from rest_framework.response import Response
from rest_framework import status
from rest_framework.exceptions import ValidationError, Throttled, NotAuthenticated, PermissionDenied

logger = logging.getLogger('freshtrack.api')

def custom_exception_handler(exc, context):
    # Call DRF's default exception handler first to get the standard response.
    response = exception_handler(exc, context)
    
    correlation_id = str(uuid.uuid4())
    
    # Log the full exception with context details on the server side
    request = context.get('request')
    path = request.path if request else 'Unknown path'
    method = request.method if request else 'Unknown method'
    user = request.user if request and request.user.is_authenticated else 'Anonymous'
    logger.error(
        f"API Error [{correlation_id}] on {method} {path} by user {user}: {str(exc)}", 
        exc_info=True
    )

    # Base error structures
    error_code = "INTERNAL_SERVER_ERROR"
    error_message = "An unexpected error occurred. Reference: " + correlation_id
    fields = {}

    if response is not None:
        # Standardize the status code mapping
        status_code = response.status_code
        
        if isinstance(exc, ValidationError):
            error_code = "VALIDATION_ERROR"
            error_message = "Some validation checks failed. Please check your fields."
            # DRF ValidationError details are usually a dict or list
            if isinstance(response.data, dict):
                fields = response.data
            elif isinstance(response.data, list):
                fields = {'non_field_errors': response.data}
        elif isinstance(exc, Throttled):
            error_code = "RATE_LIMIT_EXCEEDED"
            error_message = f"Too many requests. Please retry in {exc.wait} seconds."
        elif isinstance(exc, NotAuthenticated):
            error_code = "UNAUTHORIZED"
            error_message = "Authentication credentials were not provided or are invalid."
        elif isinstance(exc, PermissionDenied):
            error_code = "FORBIDDEN"
            error_message = "You do not have permission to perform this action."
        elif hasattr(exc, 'code'):
            error_code = exc.code
            error_message = str(exc.detail) if hasattr(exc, 'detail') else str(exc)
        else:
            # Custom code matching for other exception classes
            error_code = exc.__class__.__name__.replace('Exception', '').upper()
            error_message = response.data.get('detail', str(exc)) if isinstance(response.data, dict) else str(exc)
    else:
        # For completely unhandled exceptions (500 errors)
        status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
        response = Response(status=status_code)

    response.data = {
        "success": False,
        "error": {
            "code": error_code,
            "message": error_message,
            "fields": fields,
            "correlation_id": correlation_id
        }
    }
    return response
