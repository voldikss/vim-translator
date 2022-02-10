# -*- coding: utf-8 -*-
from abc import abstractmethod

from .. import manager
from .. import compat

provider_registry = {}


def register_provider(provider_class):
    """
    register translator provider to manager
    :param provider_class: translator class
    """
    provider_registry[provider_class.__name__.lower()] = provider_class


class AutoRegisterMixin(type):
    def __new__(cls, name, bases, attrs):
        newclass = type.__new__(cls, name, bases, attrs)
        register_provider(newclass)
        return newclass


class BaseProvider(object, metaclass=AutoRegisterMixin):  # type: ignore
    def __init__(self, name):
        self._name = name
        # self._proxy_url = None

    @abstractmethod
    def translate(self, text: str, sl: str, tl: str):
        return NotImplementedError()
