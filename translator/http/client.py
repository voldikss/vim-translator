from typing import Any, Dict
from http.client import HTTPResponse

from ..compat import urlopen
from .request import Request
from .response import Response


class Client:
    """
    HttpClient
    """

    def __init__(self):
        ...

    def request(
        self,
        method: str,
        url: str,
        data: Dict = None,
        json: Dict = None,
        params: Dict = None,
        files: Any = None,
        headers: Dict = None,
        timeout: int = None,
        follow_redirects: bool = True,
    ) -> Response:
        req = self.build_request(
            method=method,
            url=url,
            data=data,
            json=json,
            params=params,
            files=files,
            headers=headers,
        )
        return self.send_request(
            req, timeout=timeout, follow_redirects=follow_redirects
        )

    def build_request(
        self,
        method: str,
        url: str,
        data: Dict = None,
        json: Dict = None,
        params: Dict = None,
        files: Any = None,
        headers: Dict = None,
    ):
        """
        build a `Request` object
        """
        return Request(
            method,
            url,
            data=data,
            json=json,
            params=params,
            files=files,
            headers=headers,
        )

    def send_request(
        self, request: Request, timeout: int = None, follow_redirects: bool = True
    ):
        """
        send request and get response
        """
        res: HTTPResponse = urlopen(request.url, data=request.data, timeout=timeout)
        return self.build_response(res)

    def build_response(self, response: HTTPResponse) -> Response:
        """
        :param response: HTTPResponse
        build response object
        """
        return Response(
            content=response.read(),
            status_code=response.status,
            headers=dict(response.headers.items()),
        )
