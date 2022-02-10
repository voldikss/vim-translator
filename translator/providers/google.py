# -*- coding: utf-8 -*-
import json
from ._base import BaseProvider

class GoogleProvider(BaseProvider):
    def __init__(self):
        super(GoogleProvider, self).__init__("google")
        self._host = "translate.googleapis.com"
        self._cnhost = "translate.google.cn"

    def get_url(self, sl, tl, qry):
        http_host = self._cnhost if "zh" in tl else self._host
        qry = urlquote(qry)
        url = (
            "https://{}/translate_a/single?client=gtx&sl={}&tl={}&dt=at&dt=bd&dt=ex&"
            "dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&q={}".format(
                http_host, sl, tl, qry
            )
        )
        return url

    def translate(self, sl, tl, text, options=None):
        url = self.get_url(sl, tl, text)
        resp = self.get(url)
        if not resp:
            return None
        try:
            obj = json.loads(resp)
        except:
            return None

        res = self.create_translation(sl, tl, text)
        res["paraphrase"] = self.get_paraphrase(obj)
        res["explains"] = self.get_explains(obj)
        res["phonetic"] = self.get_phonetic(obj)
        res["detail"] = self.get_detail(obj)
        res["alternative"] = self.get_alternative(obj)
        return res

    def get_phonetic(self, obj):
        for x in obj[0]:
            if len(x) == 4:
                return x[3]
        return ""

    def get_paraphrase(self, obj):
        paraphrase = ""
        for x in obj[0]:
            if x[0]:
                paraphrase += x[0]
        return paraphrase

    def get_explains(self, obj):
        explains = []
        if obj[1]:
            for x in obj[1]:
                expl = "[{}] ".format(x[0][0])
                for i in x[2]:
                    expl += i[0] + ";"
                explains.append(expl)
        return explains

    def get_detail(self, resp):
        if len(resp) < 13 or resp[12] is None:
            return []
        result = []
        for x in resp[12]:
            result.append("[{}]".format(x[0]))
            for y in x[1]:
                result.append("- {}".format(y[0]))
                if len(y) >= 3:
                    result.append("  * {}".format(y[2]))
        return result

    def get_alternative(self, resp):
        if len(resp) < 6 or resp[5] is None:
            return []
        definition = self.get_paraphrase(resp)
        result = []
        for x in resp[5]:
            # result.append('- {}'.format(x[0]))
            for i in x[2]:
                if i[0] != definition:
                    result.append(" * {}".format(i[0]))
        return result

