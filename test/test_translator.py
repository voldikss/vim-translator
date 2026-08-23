# -*- coding: utf-8 -*-
import sys
import copy
import os
import unittest

curr_filename = os.path.abspath(__file__)
curr_dir = os.path.dirname(curr_filename)
script_path = os.path.join(curr_dir, "../script")
sys.path.append(script_path)

from translator import BaicizhanTranslator
from translator import BingDict
from translator import DeepLTranslator
from translator import GoogleTranslator
from translator import HaiciDict
from translator import ICibaTranslator
from translator import YoudaoTranslator
from translator import TranslateShell


class TestTranslator(unittest.TestCase):
    def __init__(self, *args, **kwargs):
        super(TestTranslator, self).__init__(*args, **kwargs)

    @unittest.skip("Expired")
    def test_baicizhan(self):
        t = BaicizhanTranslator()
        r = t.translate("", "", "naive")
        self.assertTrue(len(r['paraphrase']) != 0 or len(r['explains']))

    @unittest.skip("Skip for GitHub Action")
    def test_bing(self):
        t = BingDict()
        r = t.translate("", "", "naive")
        self.assertTrue(len(r['paraphrase']) != 0 or len(r['explains']))

    def test_google(self):
        t = GoogleTranslator()
        r = t.translate("auto", "zh", "naive")
        self.assertTrue(len(r['paraphrase']) != 0 or len(r['explains']))

    def test_deepl(self):
        t = DeepLTranslator("test-key:fx")
        request = {}

        def http_post(url, data, headers):
            request["url"] = url
            request["data"] = data
            request["headers"] = headers
            return '{"translations": [{"text": "天真"}]}'

        t.http_post = http_post
        r = t.translate("auto", "zh_cn", "naive")
        self.assertEqual(r["paraphrase"], "天真")
        self.assertEqual(request["url"], "https://api-free.deepl.com/v2/translate")
        self.assertEqual(
            request["data"],
            {"text": "naive", "target_lang": "ZH"},
        )
        self.assertEqual(
            request["headers"], {"Authorization": "DeepL-Auth-Key test-key:fx"}
        )
        t.translate("zh_cn", "en", "naive")
        self.assertEqual(request["data"]["source_lang"], "ZH")
        self.assertEqual(
            DeepLTranslator("test-key").get_url(),
            "https://api.deepl.com/v2/translate",
        )

    def test_deepl_invalid_response(self):
        t = DeepLTranslator("test-key")
        t.http_post = lambda url, data, headers: '{"translations": [{}]}'
        self.assertIsNone(t.translate("auto", "zh", "naive"))

    def test_haici(self):
        t = HaiciDict()
        r = t.translate("", "zh", "naive")
        self.assertTrue(len(r['paraphrase']) != 0 or len(r['explains']))

    @unittest.skip("ciba api was deprecated")
    def test_iciba(self):
        t = ICibaTranslator()
        r = t.translate("", "", "naive")
        self.assertTrue(len(r['paraphrase']) != 0 or len(r['explains']))

    def test_translate_shell(self):
        t = TranslateShell()
        r = t.translate("auto", "zh", "naive")
        self.maxDiff = None
        self.assertTrue(len(r['paraphrase']) != 0 or len(r['explains']))

    def test_youdao(self):
        t = YoudaoTranslator()
        r = t.translate("auto", "zh", "naive")
        self.assertTrue(len(r['paraphrase']) != 0 or len(r['explains']))


if __name__ == "__main__":
    unittest.main()
