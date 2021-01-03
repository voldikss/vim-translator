# -*- coding: utf-8 -*-
import re
import threading
import socket
import sys
import time
import os
import random
import copy
import json
import argparse
import codecs

if sys.version_info.major < 3:
    is_py3 = False
    reload(sys)
    sys.setdefaultencoding("utf-8")
    sys.stdout = codecs.getwriter("utf-8")(sys.stdout)
    sys.stderr = codecs.getwriter("utf-8")(sys.stderr)
    from urlparse import urlparse
    from urllib import urlencode
    from urllib import quote_plus as url_quote
    from urllib2 import urlopen
    from urllib2 import Request
    from urllib2 import URLError
    from urllib2 import HTTPError
else:
    is_py3 = True
    sys.stdout = codecs.getwriter("utf-8")(sys.stdout.buffer)
    sys.stderr = codecs.getwriter("utf-8")(sys.stderr.buffer)
    from urllib.parse import urlencode
    from urllib.parse import quote_plus as url_quote
    from urllib.parse import urlparse
    from urllib.request import urlopen
    from urllib.request import Request
    from urllib.error import URLError
    from urllib.error import HTTPError


class BaseTranslator(object):
    def __init__(self, name):
        self._name = name
        self._proxy_url = None
        self._agent = (
            "Mozilla/5.0 (X11; Linux x86_64; rv:50.0) Gecko/20100101 Firefox/50.0"
        )

    def request(self, url, data=None, post=False, header=None):
        if header:
            header = copy.deepcopy(header)
        else:
            header = {}
            header[
                "User-Agent"
            ] = "Mozilla/5.0 (X11; Linux x86_64) \
                    AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36"

        if post:
            if data:
                data = urlencode(data).encode("utf-8")
        else:
            if data:
                query_string = urlencode(data)
                url = url + "?" + query_string
                data = None

        req = Request(url, data, header)

        try:
            r = urlopen(req, timeout=5)
        except (URLError, HTTPError, socket.timeout):
            sys.stderr.write(
                "Engine %s timed out, please check your network\n" % self._name
            )
            return None

        if is_py3:
            charset = r.headers.get_param("charset") or "utf-8"
        else:
            charset = r.headers.getparam("charset") or "utf-8"

        r = r.read().decode(charset)
        return r

    def http_get(self, url, data=None, header=None):
        return self.request(url, data, False, header)

    def http_post(self, url, data=None, header=None):
        return self.request(url, data, True, header)

    def set_proxy(self, proxy_url=None):
        try:
            import socks
        except ImportError:
            sys.stderr.write("pySocks module should be installed\n")
            return None

        try:
            import ssl

            ssl._create_default_https_context = ssl._create_unverified_context
        except Exception:
            pass

        self._proxy_url = proxy_url

        proxy_types = {
            "http": socks.PROXY_TYPE_HTTP,
            "socks": socks.PROXY_TYPE_SOCKS4,
            "socks4": socks.PROXY_TYPE_SOCKS4,
            "socks5": socks.PROXY_TYPE_SOCKS5,
        }

        url_component = urlparse(proxy_url)

        proxy_args = {
            "proxy_type": proxy_types[url_component.scheme],
            "addr": url_component.hostname,
            "port": url_component.port,
            "username": url_component.username,
            "password": url_component.password,
        }

        socks.set_default_proxy(**proxy_args)
        socket.socket = socks.socksocket

    def test_request(self, test_url):
        print("test url: %s" % test_url)
        print(self.request(test_url))

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

    def md5sum(self, text):
        import hashlib

        m = hashlib.md5()
        if sys.version_info[0] < 3:
            if isinstance(text, unicode):  # noqa: F821
                text = text.encode("utf-8")
        else:
            if isinstance(text, str):
                text = text.encode("utf-8")
        m.update(text)
        return m.hexdigest()

    def html_unescape(self, text):
        # https://stackoverflow.com/questions/2087370/decode-html-entities-in-python-string
        # Python 3.4+
        if sys.version_info[0] >= 3 and sys.version_info[1] >= 4:
            import html

            return html.unescape(text)
        else:
            try:
                # Python 2.6-2.7
                from HTMLParser import HTMLParser
            except ImportError:
                # Python 3
                from html.parser import HTMLParser
            h = HTMLParser()
            return h.unescape(text)


# NOTE: expired
class BaicizhanTranslator(BaseTranslator):
    def __init__(self):
        super(BaicizhanTranslator, self).__init__("baicizhan")

    def translate(self, sl, tl, text, options=None):
        url = "http://mall.baicizhan.com/ws/search"
        req = {}
        req["w"] = url_quote(text)
        resp = self.http_get(url, req, None)
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


class BingDict(BaseTranslator):
    def __init__(self):
        super(BingDict, self).__init__("bing")
        self._url = "http://bing.com/dict/SerpHoverTrans"
        self._cnurl = "http://cn.bing.com/dict/SerpHoverTrans"

    def translate(self, sl, tl, text, options=None):
        url = self._cnurl if "zh" in tl else self._url
        url = url + "?q=" + url_quote(text)
        headers = {
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "en-US,en;q=0.5",
        }
        resp = self.http_get(url, None, headers)
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


class GoogleTranslator(BaseTranslator):
    def __init__(self):
        super(GoogleTranslator, self).__init__("google")
        self._host = "translate.googleapis.com"
        self._cnhost = "translate.google.cn"

    def get_url(self, sl, tl, qry):
        http_host = self._cnhost if "zh" in tl else self._host
        qry = url_quote(qry)
        url = (
            "https://{}/translate_a/single?client=gtx&sl={}&tl={}&dt=at&dt=bd&dt=ex&"
            "dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&q={}".format(
                http_host, sl, tl, qry
            )
        )
        return url

    def translate(self, sl, tl, text, options=None):
        url = self.get_url(sl, tl, text)
        resp = self.http_get(url)
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


class HaiciDict(BaseTranslator):
    def __init__(self):
        super(HaiciDict, self).__init__("haici")

    def translate(self, sl, tl, text, options=None):
        url = "http://dict.cn/mini.php"
        req = {}
        req["q"] = url_quote(text)
        resp = self.http_get(url, req)
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


# NOTE: deprecated
class ICibaTranslator(BaseTranslator):
    def __init__(self):
        super(ICibaTranslator, self).__init__("iciba")

    def translate(self, sl, tl, text, options=None):
        url = "http://www.iciba.com/index.php"
        req = {}
        req["a"] = "getWordMean"
        req["c"] = "search"
        req["word"] = url_quote(text)
        resp = self.http_get(url, req, None)
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


class YoudaoTranslator(BaseTranslator):
    def __init__(self):
        super(YoudaoTranslator, self).__init__("youdao")
        self.url = "https://fanyi.youdao.com/translate_o"
        self.D = "97_3(jkMYg@T[KZQmqjTK"
        # 备用 self.D = "n%A-rKaT5fb[Gy?;N5@Tj"

    def sign(self, text, salt):
        s = "fanyideskweb" + text + salt + self.D
        return self.md5sum(s)

    def translate(self, sl, tl, text, options=None):
        salt = str(int(time.time() * 1000) + random.randint(0, 10))
        sign = self.sign(text, salt)
        header = {
            "Cookie": "OUTFOX_SEARCH_USER_ID=-2022895048@10.168.8.76;",
            "Referer": "http://fanyi.youdao.com/",
            "User-Agent": "Mozilla/5.0 (Windows NT 6.2; rv:51.0) Gecko/20100101 Firefox/51.0",
        }
        data = {
            "i": url_quote(text),
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
        resp = self.http_post(self.url, data, header)
        if not resp:
            return
        try:
            obj = json.loads(resp)
        except:
            return None

        res = self.create_translation(sl, tl, text)
        res["paraphrase"] = self.get_paraphrase(obj)
        res["explains"] = self.get_explains(obj)
        return res

    def get_paraphrase(self, obj):
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

    def get_explains(self, obj):
        explains = []
        if "smartResult" in obj:
            smarts = obj["smartResult"]["entries"]
            for entry in smarts:
                if entry:
                    entry = entry.replace("\r", "")
                    entry = entry.replace("\n", "")
                    explains.append(entry)
        return explains


class TranslateShell(BaseTranslator):
    def __init__(self):
        super(TranslateShell, self).__init__("trans")

    def translate(self, sl, tl, text, options=None):
        if not options:
            options = []

        if self._proxy_url:
            options.append("-proxy {}".format(self._proxy_url))

        default_opts = [
            "-no-ansi",
            "-no-theme",
            "-show-languages n",
            "-show-prompt-message n",
            "-show-translation-phonetics n",
            "-hl {}".format(tl),
        ]
        options = default_opts + options
        source_lang = "" if sl == "auto" else sl
        cmd = "trans {} {}:{} '{}'".format(" ".join(options), source_lang, tl, text)
        run = os.popen(cmd)
        lines = []
        for line in run.readlines():
            line = re.sub(r"[\t\n]", "", line)
            line = re.sub(r"\v.*", "", line)
            line = re.sub(r"^\s*", "", line)
            lines.append(line)
        res = self.create_translation(sl, tl, text)
        res["explains"] = lines
        run.close()
        return res


class SdcvShell(BaseTranslator):
    def __init__(self):
        super(SdcvShell, self).__init__("sdcv")

    def get_dictionary(self, sl, tl, text):
        """get dictionary of sdcv

        :sl: source_lang
        :tl: target_lang
        :returns: dictionary

        """
        dictionary = ""
        if sl == "":
            try:
                import langdetect
            except ImportError:
                sys.stderr.write("langdetect module should be installed\n")
                return None
            sl = langdetect.detect(text)

        if (sl == "en") & (tl == "zh"):
            dictionary = "朗道英汉字典5.0"
        elif (sl == "zh_cn") & (tl == "en"):
            dictionary = "朗道汉英字典5.0"
        elif (sl == "en") & (tl == "ja"):
            dictionary = "jmdict-en-ja"
        elif (sl == "ja") & (tl == "en"):
            dictionary = "jmdict-ja-en"
        return dictionary

    def translate(self, sl, tl, text, options=None):
        if not options:
            options = []

        if self._proxy_url:
            options.append("-proxy {}".format(self._proxy_url))

        source_lang = "" if sl == "auto" else sl
        dictionary = self.get_dictionary(source_lang, tl, text)
        if dictionary == "":
            default_opts = []
        else:
            default_opts = [" ".join(["-u", dictionary])]
        options = default_opts + options
        cmd = "sdcv {} '{}'".format(" ".join(options), text)
        run = os.popen(cmd)
        lines = []
        for line in run.readlines():
            line = re.sub(r"^Found.*", "", line)
            line = re.sub(r"^-->.*", "", line)
            line = re.sub(r"^\s*", "", line)
            line = re.sub(r"^\*", "", line)
            lines.append(line)
        res = self.create_translation(sl, tl, text)
        res["explains"] = lines
        run.close()
        return res


ENGINES = {
    "baicizhan": BaicizhanTranslator,
    "bing": BingDict,
    "haici": HaiciDict,
    "google": GoogleTranslator,
    "iciba": ICibaTranslator,
    "sdcv": SdcvShell,
    "trans": TranslateShell,
    "youdao": YoudaoTranslator,
}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--engines", nargs="+", required=False, default=["google"])
    parser.add_argument("--target_lang", required=False, default="zh")
    parser.add_argument("--source_lang", required=False, default="en")
    parser.add_argument("--proxy", required=False)
    parser.add_argument("--options", type=str, default=None, required=False)
    parser.add_argument("text", nargs="+", type=str)
    args = parser.parse_args()

    text = " ".join(args.text).strip("'").strip('"').strip()
    text = re.sub(r"([a-z])([A-Z][a-z])", r"\1 \2", text)
    text = re.sub(r"([a-zA-Z])_([a-zA-Z])", r"\1 \2", text).lower()
    engines = args.engines
    to_lang = args.target_lang
    from_lang = args.source_lang
    if args.options:
        options = args.options.split(",")
    else:
        options = []

    translation = {}
    translation["text"] = text
    translation["status"] = 1
    translation["results"] = []

    def runner(translator):
        res = translator.translate(from_lang, to_lang, text, options)
        if res:
            translation["results"].append(copy.deepcopy(res))
        else:
            translation["status"] = 0

    threads = []
    for e in engines:
        cls = ENGINES.get(e)
        if not cls:
            sys.stderr.write("Invalid engine name %s\n" % e)
            continue
        translator = cls()
        if args.proxy:
            translator.set_proxy(args.proxy)

        t = threading.Thread(target=runner, args=(translator,))
        threads.append(t)

    list(map(lambda x: x.start(), threads))
    list(map(lambda x: x.join(), threads))

    sys.stdout.write(json.dumps(translation))


if __name__ == "__main__":

    def test0():
        t = BaseTranslator("test_proxy")
        t.set_proxy("http://localhost:8087")
        t.test_request("https://www.google.com")

    def test1():
        t = BaicizhanTranslator()
        r = t.translate("", "zh", "naive")
        print(r)

    def test2():
        t = BingDict()
        r = t.translate("", "", "naive")
        print(r)

    def test3():
        gt = GoogleTranslator()
        r = gt.translate("auto", "zh", "filencodings")
        print(r)

    def test4():
        t = HaiciDict()
        r = t.translate("", "zh", "naive")
        print(r)

    def test5():
        t = ICibaTranslator()
        r = t.translate("", "", "naive")
        print(r)

    def test6():
        t = TranslateShell()
        r = t.translate("auto", "zh", "naive")
        print(r)

    def test7():
        t = YoudaoTranslator()
        r = t.translate("auto", "zh", "naive")
        print(r)

    # test3()
    main()
