# -*- coding: utf-8 -*-
from abc import abstractmethod

from ..import manager

def register_provider(provider_class):
    """
    register translator provider to manager
    :param provider_class: translator class
    """
    manager.provider_registry[provider_class.__name__.lower()] = provider_class

class AutoRegisterMixin(type):
    def __new__(cls, name, bases, attrs):
        newclass = type.__new__(cls, name, bases, attrs)
        register_provider(newclass)
        return newclass

class BaseTranslator(object, metaclass=AutoRegisterMixin):

    def __init__(self, name):
        self._name = name
        self._proxy_url = None

    def create_translation(self, sl="auto", tl="auto", text=""):
        res = {}
        res["engine"] = self._name
        res["sl"] = sl  # 来源语言
        res["tl"] = tl  # 目标语言
        res["text"] = text  # 需要翻译的文本
        res["phonetic"] = ""  # 音标
        res["paraphrase"] = ""  # 简单释义
        res["explains"] = []  # 分行解释
        return res

    # 翻译结果：需要填充如下字段
    def translate(self, sl, tl, text):
        return self.create_translation(sl, tl, text)

    @abstractmethod
    def translate(self, sl, tl, text, options=None):
        return NotImplementedError()
