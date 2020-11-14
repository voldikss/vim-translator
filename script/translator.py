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

if sys.version_info[0] < 3:
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


class Translation(object):
    translation = {"engine": "", "phonetic": "", "paraphrase": "", "explain": []}

    def __init__(self, engine):
        pass

    def __new__(self, engine):
        translation = copy.deepcopy(self.translation)
        translation["engine"] = engine
        return translation

    def __setitem__(self, k, v):
        self.translation.update({k: v})

    def __str__(self):
        return str(self.translation)


class BasicTranslator(object):
    def __init__(self, name):
        self._name = name
        self._trans = Translation(name)
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

    def translate(self, sl, tl, text, options=None):
        """Need to be implemented by subclass"""
        raise NotImplementedError

    def get_paraphrase(self, obj):
        """Need to be implemented by subclass"""
        raise NotImplementedError

    def get_phonetic(self, obj):
        """Need to be implemented by subclass"""
        raise NotImplementedError

    def get_explain(self, obj):
        raise NotImplementedError


# NOTE: expired
class BaicizhanTranslator(BasicTranslator):
    def __init__(self, name="baicizhan"):
        super(BaicizhanTranslator, self).__init__(name)

    def translate(self, sl, tl, text, options=None):
        url = "http://mall.baicizhan.com/ws/search"
        req = {}
        req["w"] = url_quote(text)
        r = self.http_get(url, req, None)
        if r:
            resp = json.loads(r)
            if not resp:
                return

            self._trans["phonetic"] = self.get_phonetic(resp)
            self._trans["explain"] = self.get_explain(resp)
        return self._trans

    def get_phonetic(self, obj):
        return obj["accent"] if "accent" in obj else ""

    def get_explain(self, obj):
        return ["; ".join(obj["mean_cn"].split("\n"))] if "mean_cn" in obj else []


class BingTranslator(BasicTranslator):
    def __init__(self, name="bing"):
        super(BingTranslator, self).__init__(name)

    def translate(self, sl, tl, text, options=None):
        if "zh" in tl:
            url = "http://cn.bing.com/dict/SerpHoverTrans"
        else:
            url = "http://bing.com/dict/SerpHoverTrans"
        url = url + "?q=" + url_quote(text)
        headers = {
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "en-US,en;q=0.5",
        }
        resp = self.http_get(url, None, headers)
        if not resp:
            return
        self._trans["phonetic"] = self.get_phonetic(resp)
        self._trans["explain"] = self.get_explain(resp)
        return self._trans

    def get_phonetic(self, html):
        if not html:
            return ""
        m = re.findall(r'<span class="ht_attr" lang=".*?">\[(.*?)\] </span>', html)
        return m[0].strip() if len(m) > 0 else ""

    def get_explain(self, html):
        if not html:
            return []
        m = re.findall(
            r'<span class="ht_pos">(.*?)</span><span class="ht_trs">(.*?)</span>', html
        )
        expls = []
        for item in m:
            expls.append("%s %s" % item)
        return expls


class GoogleTranslator(BasicTranslator):
    def __init__(self, name="google"):
        super(GoogleTranslator, self).__init__(name)

    def get_url(self, sl, tl, qry):
        http_host = "translate.googleapis.com"
        if "zh" in tl:
            http_host = "translate.google.cn"
        qry = url_quote(qry)
        url = (
            "https://{}/translate_a/single?client=gtx&sl={}&tl={}&dt=at&dt=bd&dt=ex&"
            "dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&q={}".format(
                http_host, sl, tl, qry
            )
        )
        return url

    def translate(self, sl, tl, text, options=None):
        self.text = text
        url = self.get_url(sl, tl, text)
        r = self.http_get(url)
        if not r:
            return
        obj = json.loads(r)
        self._trans["paraphrase"] = self.get_paraphrase(obj)
        self._trans["explain"] = self.get_explain(obj)
        return self._trans

    def get_paraphrase(self, obj):
        paraphrase = ""
        for x in obj[0]:
            if x[0]:
                paraphrase += x[0]
        return paraphrase

    def get_explain(self, obj):
        explain = []
        if obj[1]:
            for x in obj[1]:
                expl = "[{}] ".format(x[0][0])
                for i in x[2]:
                    expl += i[0] + ";"
                explain.append(expl)
        return explain


class HaiciTranslator(BasicTranslator):
    def __init__(self, name="haici"):
        super(HaiciTranslator, self).__init__(name)

    def translate(self, sl, tl, text, options=None):
        url = "http://dict.cn/mini.php"
        req = {}
        req["q"] = url_quote(text)
        resp = self.http_get(url, req)
        if not resp:
            return

        self._trans["phonetic"] = self.get_phonetic(resp)
        self._trans["explain"] = self.get_explain(resp)
        return self._trans

    def get_phonetic(self, html):
        m = re.findall(r"<span class='p'> \[(.*?)\]</span>", html)
        return m[0] if len(m) > 0 else ""

    def get_explain(self, html):
        m = re.findall(r'<div id="e">(.*?)</div>', html)
        explains = []
        for item in m:
            for e in item.split("<br>"):
                explains.append(e)
        return explains


# this api was deprecated
class ICibaTranslator(BasicTranslator):
    def __init__(self, name="iciba"):
        super(ICibaTranslator, self).__init__(name)

    def translate(self, sl, tl, text, options=None):
        url = "http://www.iciba.com/index.php"
        req = {}
        req["a"] = "getWordMean"
        req["c"] = "search"
        req["word"] = url_quote(text)
        r = self.http_get(url, req, None)
        if r:
            resp = json.loads(r)
            if not resp:
                return
            if "baesInfo" not in resp:
                return
            if "symbols" not in resp["baesInfo"]:
                return

            obj = resp["baesInfo"]["symbols"][0]
            self._trans["paraphrase"] = self.get_paraphrase(obj)
            self._trans["phonetic"] = self.get_phonetic(obj)
            self._trans["explain"] = self.get_explain(obj)
        return self._trans

    def get_paraphrase(self, obj):
        return obj["parts"][0]["means"][0]

    def get_phonetic(self, obj):
        return obj["ph_en"] if "ph_en" in obj else ""

    def get_explain(self, obj):
        parts = obj["parts"]
        explains = []
        for part in parts:
            explains.append(part["part"] + ", ".join(part["means"]))
        return explains


class YoudaoTranslator(BasicTranslator):
    def __init__(self, name="youdao"):
        super(YoudaoTranslator, self).__init__(name)
        self.url = "https://fanyi.youdao.com/translate_o"
        self.D = "97_3(jkMYg@T[KZQmqjTK"
        # 备用 self.D = "n%A-rKaT5fb[Gy?;N5@Tj"

    def get_md5(self, value):
        import hashlib

        m = hashlib.md5()
        m.update(value.encode("utf-8"))
        return m.hexdigest()

    def sign(self, text, salt):
        s = "fanyideskweb" + text + salt + self.D
        return self.get_md5(s)

    def translate(self, sl, tl, text, options=None):
        self.text = text
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
        r = self.http_post(self.url, data, header)
        if not r:
            return
        obj = json.loads(r)
        self._trans["paraphrase"] = self.get_paraphrase(obj)
        self._trans["explain"] = self.get_explain(obj)
        return self._trans

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

    def get_explain(self, obj):
        explain = []
        if "smartResult" in obj:
            smarts = obj["smartResult"]["entries"]
            for entry in smarts:
                if entry:
                    entry = entry.replace("\r", "")
                    entry = entry.replace("\n", "")
                    explain.append(entry)
        return explain


class TranslateShell(BasicTranslator):
    def __init__(self, name="trans"):
        super(TranslateShell, self).__init__(name)

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
        self.text = text
        self._trans["explain"] = lines
        run.close()
        return self._trans


class SdcvShell(BasicTranslator):
    def __init__(self, name="sdcv"):
        super(SdcvShell, self).__init__(name)

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
            default_opts = [
                " ".join(["-u", dictionary]),
            ]
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
        self.text = text
        self._trans["explain"] = lines
        run.close()
        return self._trans


ENGINES = {
    "baicizhan": BaicizhanTranslator,
    "bing": BingTranslator,
    "haici": HaiciTranslator,
    "google": GoogleTranslator,
    "iciba": ICibaTranslator,
    "sdcv": SdcvShell,
    "trans": TranslateShell,
    "youdao": YoudaoTranslator,
}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--text", required=True)
    parser.add_argument("--engines", nargs="+", required=True)
    parser.add_argument("--target_lang", required=True)
    parser.add_argument("--source_lang", required=True)
    parser.add_argument("--proxy", required=False)
    parser.add_argument("--options", type=str, default=None, required=False)
    args = parser.parse_args()

    text = args.text.strip("'")
    text = text.strip('"')
    text = text.strip()
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
        t = BasicTranslator("test_proxy")
        t.set_proxy("http://localhost:8087")
        t.test_request("https://www.google.com")

    def test1():
        t = BaicizhanTranslator()
        r = t.translate("", "zh", "naive")
        print(r)

    def test2():
        t = BingTranslator()
        r = t.translate("", "", "naive")
        print(r)

    def test3():
        gt = GoogleTranslator()
        r = gt.translate("auto", "zh", "naive")
        print(r)

    def test4():
        t = HaiciTranslator()
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

    # test6()
    main()
