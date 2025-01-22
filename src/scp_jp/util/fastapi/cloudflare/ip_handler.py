from fastapi import Request


class CFIPAddressHandler:
    @staticmethod
    def get_client_ip(request: Request) -> str:
        if "CF-Connecting-IP" in request.headers:
            return request.headers["CF-Connecting-IP"]
        return request.client.host
