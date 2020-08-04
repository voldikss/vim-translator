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
from translator import BingTranslator
from translator import GoogleTranslator
from translator import HaiciTranslator
from translator import ICibaTranslator
from translator import YoudaoTranslator
from translator import TranslateShell


class TestTranslator(unittest.TestCase):
    def __init__(self, *args, **kwargs):
        super(TestTranslator, self).__init__(*args, **kwargs)

    def test_baicizhan(self):
        translation = {
            "engine": "baicizhan",
            "phonetic": "/naɪ'iv/",
            "paraphrase": "",
            "explain": ["a. 天真的;幼稚的,轻信的"],
        }
        t = BaicizhanTranslator()
        r = t.translate("", "", "naive")
        self.assertEqual(translation, r)

    @unittest.skip("Skip for GitHub Action")
    def test_bing(self):
        translation = {
            "engine": "bing",
            "phonetic": "nɑ'iv",
            "paraphrase": "",
            "explain": ["adj. 缺乏经验的；幼稚的；无知的；轻信的"],
        }
        t = BingTranslator()
        r = t.translate("", "", "naive")
        self.assertEqual(translation, r)

    def test_google(self):
        translation = {
            "engine": "google",
            "phonetic": "",
            "paraphrase": "幼稚",
            "explain": ["[形] 幼稚;老实;戆;稚气的;天真的;"],
        }
        t = GoogleTranslator()
        r = t.translate("auto", "zh", "naive")
        self.assertEqual(translation, r)

    def test_haici(self):
        translation = {
            "engine": "haici",
            "phonetic": "naɪ'iːv",
            "paraphrase": "",
            "explain": ["adj.天真的；幼稚的"],
        }
        t = HaiciTranslator()
        r = t.translate("", "zh", "naive")
        self.assertEqual(translation, r)

    @unittest.skip("ciba api was deprecated")
    def test_iciba(self):
        translation = {
            "engine": "iciba",
            "phonetic": "ˈmɑ:stə(r)",
            "paraphrase": "硕士",
            "explain": [
                "n.硕士, 主人（尤指男性）, 大师, 男教师",
                "vt.精通，熟练, 作为主人，做…的主人, 征服, 使干燥（染过的物品）",
                "adj.主要的, 主人的, 精通的，优秀的, 原版的",
            ],
        }
        t = ICibaTranslator()
        r = t.translate("", "", "naive")
        self.assertEqual(translation, r)

    def test_translate_shell(self):
        translation = {
            "engine": "trans",
            "phonetic": "",
            "paraphrase": "",
            "explain": [
                "naive",
                "/nīˈēv/",
                "",
                "幼稚",
                "",
                "形容词",
                "幼稚",
                "naive, childish, young",
                "老实",
                "honest, frank, naive, simple-minded",
                "戆",
                "stupid, simple, ingenuous, innocent, untutored, naive",
                "稚气的",
                "childly, ingenuous, babyish, questionless, untutored, naive",
                "天真的",
                "naive",
                "",
                "naive",
                "幼稚, 天真",
            ],
        }
        t = TranslateShell()
        r = t.translate("auto", "zh", "naive")
        self.maxDiff = None
        self.assertEqual(translation, r)

    def test_youdao(self):
        translation = {
            "engine": "youdao",
            "phonetic": "",
            "paraphrase": "天真的",
            "explain": ["adj. 天真的,幼稚的"],
        }
        t = YoudaoTranslator()
        r = t.translate("auto", "zh", "naive")
        self.assertEqual(translation, r)


if __name__ == "__main__":
    unittest.main()
