# -*- coding: utf-8 -*-
import sys
import copy
import os
import unittest

curr_filename = os.path.abspath(__file__)
curr_dir = os.path.dirname(curr_filename)
script_path = os.path.join(curr_dir, "../script")
sys.path.append(script_path)

from translator import Translation
from translator import BingTranslator
from translator import CibaTranslator
from translator import ICibaTranslator
from translator import GoogleTranslator
from translator import YoudaoTranslator
from translator import TranslateShell


class TestTranslator(unittest.TestCase):
    def __init__(self, *args, **kwargs):
        super(TestTranslator, self).__init__(*args, **kwargs)

    # def test_bing(self):
    #     translation = Translation("bing")
    #     translation["phonetic"] = "'f&#230;m(ə)li"
    #     translation["explain"] = ["n. 家族；亲属；子女；家庭（包括父母子女）", "adj. 家庭的；一家所有的；适合全家人的"]
    #     t = BingTranslator()
    #     r = t.translate("", "", "family")
    #     self.assertEqual(translation, r)

    # def test_ciba(self):
    #     translation = Translation("ciba")
    #     translation["phonetic"] = "ˈfæməli"
    #     translation["explain"] = ["n. 家庭;家族;孩子;祖先;", "adj. 家庭的;一家所有的;属于家庭的;适合全家人的;"]
    #     t = CibaTranslator()
    #     r = t.translate("", "", "family")
    #     self.assertEqual(translation, r)

    def test_google(self):
        translation = Translation("google")
        translation["paraphrase"] = "家庭"
        translation["explain"] = ["[名] 家庭;家族;家人;家;科;户;系;家眷;僚属;"]
        t = GoogleTranslator()
        r = t.translate("auto", "zh", "family")
        self.assertEqual(translation, r)

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
        r = t.translate("", "", "master")
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
            "family",
            "/ˈfam(ə)lē/",
            "",
            "家庭",
            "",
            "名词",
            "家庭",
            "family, household",
            "家族",
            "family, clan, household",
            "家人",
            "family, household",
            "家",
            "home, family, household, school, specialist, school of thought",
            "科",
            "family, branch, division, subject, field",
            "户",
            "household, family, door",
            "系",
            "system, line, series, department, family, faculty",
            "家眷",
            "family, wife, wife and children",
            "僚属",
            "family",
            "",
            "family",
            "家庭, 家族, 家人",
        ]
        t = TranslateShell()
        r = t.translate("auto", "zh", "family")
        self.maxDiff = None
        self.assertEqual(translation, r)


if __name__ == "__main__":
    unittest.main()
