def get_client_ip(request):
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')

    if x_forwarded_for:
        client_ip = x_forwarded_for.split(',')[0]

    else:
        client_ip = request.META.get('REMOTE_ADDR')

    return client_ip


class IPAddressMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        request.client_ip = get_client_ip(request)

        return self.get_response(request)
