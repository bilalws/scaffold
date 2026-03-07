class ProjectBaseException(Exception):
    def __init__(self, message='Error', status_code=400, payload=None):
        super().__init__(message)
        self.message = message
        self.status_code = status_code
        self.payload = payload
