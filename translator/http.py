import socket
import sys
from typing import Any, Dict

from translator.http.client import Client
from translator.http.response import Response


def request(
    method: str,
    url: str,
    data: Dict = None,
    json: Dict = None,
    files: Dict = None,
    params: Dict = None,
    headers: Dict = None,
) -> Response:
    client = Client()
    return client.request(
        method,
        url,
        data=data,
        json=json,
        files=files,
        params=params,
        headers=headers,
    )


def get(url, params: Dict = None, headers: Dict = None):
    return request(
        "GET",
        url=url,
        params=params,
        headers=headers,
    )


def post(
    url,
    data: Dict = None,
    json: Dict = None,
    files: Any = None,
    params: Dict = None,
    headers: Dict = None,
):
    return request(
        "POST",
        url=url,
        data=data,
        json=json,
        files=files,
        params=params,
        headers=headers,
    )


# def set_proxy(self, proxy_url=None):
#     try:
#         import socks
#     except ImportError:
#         sys.stderr.write("pySocks module should be installed\n")
#         return None
#
#     try:
#         import ssl
#
#         ssl._create_default_https_context = ssl._create_unverified_context
#     except Exception:
#         pass
#
#     self._proxy_url = proxy_url
#
#     proxy_types = {
#         "http": socks.PROXY_TYPE_HTTP,
#         "socks": socks.PROXY_TYPE_SOCKS4,
#         "socks4": socks.PROXY_TYPE_SOCKS4,
#         "socks5": socks.PROXY_TYPE_SOCKS5,
#     }
#
#     url_component = urlparse(proxy_url)
#
#     proxy_args = {
#         "proxy_type": proxy_types[url_component.scheme],
#         "addr": url_component.hostname,
#         "port": url_component.port,
#         "username": url_component.username,
#         "password": url_component.password,
#     }
#
#     socks.set_default_proxy(**proxy_args)
#     socket.socket = socks.socksocket
#
#
# def test_request(self, test_url):
#     print("test url: %s" % test_url)
#     print(self._request(test_url))
