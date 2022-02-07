# -*- coding: utf-8 -*-
import json
from ._base import BaseTranslator

# NOTE: expired
class BaicizhanTranslator(BaseTranslator):
    def __init__(self):
        super(BaicizhanTranslator, self).__init__("baicizhan")

    def translate(self, sl, tl, text, options=None):
        url = "http://mall.baicizhan.com/ws/search"
        req = {}
        req["w"] = urlquote(text)
        resp = self.get(url, req, None)
        if not resp:
            return None
        try:
            obj = json.loads(resp)
        except:
            return None

        res = self.create_translation(sl, tl, text)
        res["phonetic"] = self.get_phonetic(obj)
        res["explains"] = self.get_explains(obj)
        return res

    def get_phonetic(self, obj):
        return obj["accent"] if "accent" in obj else ""

    def get_explains(self, obj):
        return ["; ".join(obj["mean_cn"].split("\n"))] if "mean_cn" in obj else []


