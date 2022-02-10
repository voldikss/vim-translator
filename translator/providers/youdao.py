# -*- coding: utf-8 -*-
import time
import random
from typing import Dict, List

from .. import httpclient
from ..model import Translation
from ..compat import urlquote
from ._base import BaseProvider
from ._utils import md5sum


class YoudaoProvider(BaseProvider):
    def __init__(self):
        super(YoudaoProvider, self).__init__("youdao")
        self.url = "https://fanyi.youdao.com/translate_o"
        self.D = "97_3(jkMYg@T[KZQmqjTK"
        # 备用 self.D = "n%A-rKaT5fb[Gy?;N5@Tj"

    def sign(self, text, salt):
        s = "fanyideskweb" + text + salt + self.D
        return md5sum(s)

    def translate(self, sl: str, tl: str, text: str) -> Translation:
        salt = str(int(time.time() * 1000) + random.randint(0, 10))
        sign = self.sign(text, salt)
        headers = {
            "Cookie": "OUTFOX_SEARCH_USER_ID=-2022895048@10.168.8.76;",
            "Referer": "http://fanyi.youdao.com/",
            "User-Agent": "Mozilla/5.0 (Windows NT 6.2; rv:51.0) Gecko/20100101 Firefox/51.0",
        }
        params = {
            "i": urlquote(text),
            "from": sl,
            "to": tl,
            "smartresult": "dict",
            "client": "fanyideskweb",
            "salt": salt,
            "sign": sign,
            "doctype": "json",
            "version": "2.1",
            "keyfrom": "fanyi.web",
            "action": "FY_BY_CL1CKBUTTON",
            "typoResult": "true",
        }
        resp = httpclient.get(self.url, params=params, headers=headers)
        obj = resp.json
        res = self.create_translation(sl, tl, text)
        res["paraphrase"] = self.get_paraphrase(obj)
        res["explains"] = self.get_explains(obj)
        return res

    def get_paraphrase(self, obj: Dict) -> str:
        translation = ""
        t = obj.get("translateResult")
        if t:
            for n in t:
                part = []
                for m in n:
                    x = m.get("tgt")
                    if x:
                        part.append(x)
                if part:
                    translation += ", ".join(part)
        return translation

    def get_explains(self, obj: Dict) -> List[str]:
        explains: List[str] = []
        if "smartResult" in obj:
            smarts = obj.get("smartResult", {}).get("entries")
            if smarts:
                for entry in smarts:
                    if entry:
                        entry = entry.replace("\r", "")
                        entry = entry.replace("\n", "")
                        explains.append(entry)
        return explains
