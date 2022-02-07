from typing import Any, Dict
import json as jsonlib
import cgi

from .exceptions import NoDataException
from .headers import Headers


class Response:
    def __init__(self, content: bytes, status_code: int, headers: Dict = None):
        self._content = content
        self.status_code = status_code
        self.headers = Headers(headers)

    def __repr__(self):
        class_name = self.__class__.__name__
        return "<{}[{}]>".format(class_name, self.status_code)

    @property
    def json(self, **kwargs: Any) -> Dict:
        return jsonlib.loads(self.text, **kwargs)

    @property
    def text(self) -> str:
        if not hasattr(self, "_text"):
            content = self.content
            if not content:
                self._text = ""
            self._text = content.decode(self.encoding)
        return self._text

    @property
    def content(self) -> bytes:
        if not hasattr(self, "_content"):
            raise NoDataException()
        return self._content

    @property
    def encoding(self):
        if not hasattr(self, "_encoding"):
            content_type = self.headers.get("content-type")
            _, params = cgi.parse_header(content_type)
            self._encoding = params.get("charset", "utf-8")
        return self._encoding
