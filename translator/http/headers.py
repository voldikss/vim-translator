from typing import (
    Dict,
    ItemsView,
    Iterator,
    KeysView,
    Union,
    ValuesView,
)

HeadersLike = Union["Headers", Dict[str, str]] | None


class Headers:
    def __init__(self, headers: HeadersLike) -> None:
        if isinstance(headers, Headers):
            self._headers = dict(headers.items())
        elif isinstance(headers, dict):
            self._headers = {key.lower(): value for key, value in headers.items()}
        else:
            self._headers = {}

    def get(self, key: str, default: str = None) -> str:
        try:
            return self[key]
        except KeyError:
            return default  # type: ignore

    def keys(self) -> KeysView[str]:
        return self._headers.keys()

    def values(self) -> ValuesView[str]:
        return self._headers.values()

    def items(self) -> ItemsView[str, str]:
        return self._headers.items()

    def update(self, other: HeadersLike) -> None:
        other_headers = Headers(other)
        for key, value in other_headers.items():
            self[key] = value

    def copy(self) -> "Headers":
        return Headers(self)

    def __getitem__(self, key: str) -> str:
        return self._headers[key.lower()]

    def __setitem__(self, key: str, value: str) -> None:
        self._headers[key.lower()] = value

    def __delitem__(self, key: str) -> None:
        del self._headers[key]

    def __len__(self) -> int:
        return len(self._headers)

    def __contains__(self, key: str) -> bool:
        try:
            return self[key] is not None
        except:
            return False

    def __iter__(self) -> Iterator:
        return iter(self.keys())

    def __eq__(self, other: HeadersLike) -> bool:
        other_headers = Headers(other)
        self_list = self.items()
        other_list = other_headers.items()
        return sorted(self_list) == sorted(other_list)

    def __repr__(self) -> str:
        class_name = self.__class__.__name__
        kv_str = ", ".join(["{}={}".format(key, value) for key, value in self.items()])
        return "<{class_name}({kv_str})>".format(class_name=class_name, kv_str=kv_str)
