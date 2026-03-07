from rest_framework.views import exception_handler
from rest_framework.response import Response
from shared.exceptions import ProjectBaseException


def base_exception_handler(exc, context):
    if isinstance(exc, ProjectBaseException):
        return Response(
            {'message': exc.message},
            status=exc.status_code
        )

    return exception_handler(exc, context)
