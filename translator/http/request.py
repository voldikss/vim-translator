from ..compat import urlencode
from ..compat import urlencode
from typing import Any, Dict, Tuple
from json import dumps as json_dumps

EncodePayloadResult = Tuple[Dict, bytes]


class Request:
    def __init__(
        self,
        method: str,
        url: str,
        data=None,
        json=None,
        params=None,
        files=None,
        headers: Dict = None,
    ):
        self.url = self._prepare_url(url, params)
        self.method = self._prepare_method(method)
        self.headers = self._prepare_headers(headers)
        headers, self.data = self._prepare_data(data, json, files)
        self.headers.update(headers)

    def __repr__(self):
        class_name = self.__class__.__name__
        return "<{}({}, {})>".format(class_name, self.method, self.url)

    def _prepare_method(self, method: str) -> str:
        return method.upper()

    def _prepare_url(self, url: str, params: Dict = None) -> str:
        if params:
            query_params = urlencode(params)
            return "{url}?{params}".format(url=url, params=query_params)
        return url

    def _prepare_headers(self, headers: Dict = None) -> Dict:
        if not headers:
            headers = {}
        if "User-Agent" not in headers:
            headers[
                "User-Agent"
            ] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36"
        return headers

    def _prepare_data(
        self, data: Dict = None, json: Dict = None, files: Any = None
    ) -> EncodePayloadResult:
        if data:
            return encode_urlencoded_data(data)
        elif json:
            return encode_json(json)
        elif files:
            return encode_files(files)
        return {}, b""


def encode_urlencoded_data(data: Dict) -> EncodePayloadResult:
    """
    :param data: form data
    """
    body = urlencode(data).encode("utf-8")
    headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Content-Length"] = len(body)
    return headers, body


def encode_json(json: Dict[str, Any]) -> EncodePayloadResult:
    """
    :param data: json payload
    """
    body = json_dumps(json).encode("utf-8")
    headers = {}
    headers["Content-Type"] = "application/json"
    headers["Content-Length"] = len(body)
    return headers, body


def encode_files(files: Any) -> EncodePayloadResult:
    ...
