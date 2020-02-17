# -*- coding: utf-8 -*-
import sys
import copy
import os
import unittest

curr_filename = os.path.abspath(__file__)
curr_dir = os.path.dirname(curr_filename)
script_path = "%s/../script" % curr_dir
sys.path.append(script_path)

from translator import Translation
from translator import BingTranslator
from translator import CibaTranslator
from translator import GoogleTranslator
from translator import YoudaoTranslator
from translator import TranslateShell


class TestTranslator(unittest.TestCase):
    def __init__(self, *args, **kwargs):
        super(TestTranslator, self).__init__(*args, **kwargs)

    def test_bing(self):
        translation = Translation("bing")
        translation["phonetic"] = "'f&#230;m(ə)li"
        translation["explain"] = ["n. 家族；亲属；子女；家庭（包括父母子女）", "adj. 家庭的；一家所有的；适合全家人的"]
        t = BingTranslator()
        r = t.translate("", "", "family")
        self.assertEqual(translation, r)

    def test_ciba(self):
        translation = Translation("ciba")
        translation["phonetic"] = "ˈfæməli"
        translation["explain"] = ["n. 家庭;家族;孩子;祖先;", "adj. 家庭的;一家所有的;属于家庭的;适合全家人的;"]
        t = CibaTranslator()
        r = t.translate("", "", "family")
        self.assertEqual(translation, r)

    def test_google(self):
        translation = Translation("google")
        translation["paraphrase"] = "家庭"
        translation["explain"] = ["[名] 家庭;家族;家人;家;科;户;系;家眷;僚属;"]
        t = GoogleTranslator()
        r = t.translate("auto", "zh", "family")
        self.assertEqual(translation, r)

    def test_youdao(self):
        translation = Translation("youdao")
        translation["paraphrase"] = "家庭"
        translation["explain"] = ["n. 家庭；亲属；家族；子女；[生]科；语族；[化]族", "adj. 家庭的；家族的；适合于全家的"]
        t = YoudaoTranslator()
        r = t.translate("auto", "zh", "family")
        self.assertEqual(translation, r)

    def test_translate_shell(self):
        translation = Translation("trans")
        translation["explain"] = [
            "n",
            "",
            "ñ",
            "",
            "n 的翻译",
            "",
            "n",
            "    ñ, ň, ņ, ń, ŋ",
        ]
        t = TranslateShell()
        r = t.translate("auto", "zh", "family")
        self.assertEqual(translation, r)


if __name__ == "__main__":
    unittest.main()
