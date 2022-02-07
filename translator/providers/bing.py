# -*- coding: utf-8 -*-
import re
from ._base import BaseTranslator

class BingDict(BaseTranslator):
    def __init__(self):
        super(BingDict, self).__init__("bing")
        self._url = "http://bing.com/dict/SerpHoverTrans"
        self._cnurl = "http://cn.bing.com/dict/SerpHoverTrans"

    def translate(self, sl, tl, text, options=None):
        url = self._cnurl if "zh" in tl else self._url
        url = url + "?q=" + urlquote(text)
        headers = {
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "en-US,en;q=0.5",
        }
        resp = self.get(url, None, headers)
        if not resp:
            return None
        res = self.create_translation(sl, tl, text)
        res["phonetic"] = self.get_phonetic(resp)
        res["explains"] = self.get_explains(resp)
        return res

    def get_phonetic(self, html):
        if not html:
            return ""
        m = re.findall(r'<span class="ht_attr" lang=".*?">\[(.*?)\] </span>', html)
        if not m:
            return ""
        return self.html_unescape(m[0].strip())

    def get_explains(self, html):
        if not html:
            return []
        m = re.findall(
            r'<span class="ht_pos">(.*?)</span><span class="ht_trs">(.*?)</span>', html
        )
        expls = []
        for item in m:
            expls.append("%s %s" % item)
        return expls

