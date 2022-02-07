# -*- coding: utf-8 -*-
import re
import threading
import sys
import copy
import json
import argparse

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
