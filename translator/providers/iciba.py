# -*- coding: utf-8 -*-
import json
from ._base import BaseTranslator

# NOTE: deprecated
class ICibaTranslator(BaseTranslator):
    def __init__(self):
        super(ICibaTranslator, self).__init__("iciba")

    def translate(self, sl, tl, text, options=None):
        url = "http://www.iciba.com/index.php"
        req = {}
        req["a"] = "getWordMean"
        req["c"] = "search"
        req["word"] = urlquote(text)
        resp = self.get(url, req, None)
        if not resp:
            return None
        try:
            obj = json.loads(resp)
            obj = obj["baesInfo"]["symbols"][0]
        except:
            return None

        res = self.create_translation(sl, tl, text)
        res["paraphrase"] = self.get_paraphrase(obj)
        res["phonetic"] = self.get_phonetic(obj)
        res["explains"] = self.get_explains(obj)
        return res

    def get_paraphrase(self, obj):
        try:
            return obj["parts"][0]["means"][0]
        except:
            return ""

    def get_phonetic(self, obj):
        return obj["ph_en"] if "ph_en" in obj else ""

    def get_explains(self, obj):
        parts = obj["parts"] if "parts" in obj else []
        explains = []
        for part in parts:
            explains.append(part["part"] + ", ".join(part["means"]))
        return explains

