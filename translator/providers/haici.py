# -*- coding: utf-8 -*-
import re
from ._base import BaseTranslator

class HaiciDict(BaseTranslator):
    def __init__(self):
        super(HaiciDict, self).__init__("haici")

    def translate(self, sl, tl, text, options=None):
        url = "http://dict.cn/mini.php"
        req = {}
        req["q"] = urlquote(text)
        resp = self.get(url, req)
        if not resp:
            return

        res = self.create_translation(sl, tl, text)
        res["phonetic"] = self.get_phonetic(resp)
        res["explains"] = self.get_explains(resp)
        return res

    def get_phonetic(self, html):
        m = re.findall(r"<span class='p'> \[(.*?)\]</span>", html)
        return m[0] if m else ""

    def get_explains(self, html):
        m = re.findall(r'<div id="e">(.*?)</div>', html)
        explains = []
        for item in m:
            for e in item.split("<br>"):
                explains.append(e)
        return explains

