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
from translator import CibaTranslator
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
            "phonetic": "/ˈmæstər/",
            "paraphrase": "",
            "explain": ["c. 主人"],
        }
        t = BaicizhanTranslator()
        r = t.translate("", "", "master")
        self.assertEqual(translation, r)

    @unittest.skip("Skip for GitHub Action")
    def test_bing(self):
        translation = {
            "engine": "bing",
            "phonetic": "'m&#230;stər",
            "paraphrase": "",
            "explain": [
                "n. 硕士；主人；主宰；能手",
                "v. 掌握；精通；控制（情绪）；控制（动物或人）",
                "adj. 灵巧的；最大的；最重要的",
            ],
        }
        t = BingTranslator()
        r = t.translate("", "", "master")
        self.assertEqual(translation, r)

    @unittest.skip("Skip for GitHub Action")
    def test_ciba(self):
        translation = {
            "engine": "ciba",
            "phonetic": "ˈmɑ:stə(r)",
            "paraphrase": "",
            "explain": [
                "n. 硕士;主人（尤指男性）;大师;男教师;",
                "vt. 精通，熟练;作为主人，做…的主人;征服;使干燥（染过的物品）;",
                "adj. 主要的;主人的;精通的，优秀的;原版的;",
            ],
        }
        t = CibaTranslator()
        r = t.translate("", "", "master")
        self.assertEqual(translation, r)

    def test_google(self):
        translation = {
            "engine": "google",
            "phonetic": "",
            "paraphrase": "主",
            "explain": [
                "[名] 主;硕士;师傅;大师;师;老爷;主子;主人翁;雇主;好手;爷;",
                "[动] 精通;学会;征服;树立;",
                "[形] 主要的;主人的;",
            ],
        }
        t = GoogleTranslator()
        r = t.translate("auto", "zh", "master")
        self.assertEqual(translation, r)

    def test_haici(self):
        translation = {
            "engine": "haici",
            "phonetic": "'mæstər",
            "paraphrase": "",
            "explain": ["n.主人；硕士；专家", "vt.控制；精通", "adj.主要的；主人的；精通的"],
        }
        t = HaiciTranslator()
        r = t.translate("", "zh", "master")
        self.assertEqual(translation, r)

    @unittest.skip("Skip for GitHub Action")
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
        translation = {
            "engine": "youdao",
            "phonetic": "",
            "paraphrase": "主",
            "explain": [
                "v. 精通；控制；征服；制作……母版",
                "adj. 主人的；主要的；熟练的；原始版的",
                "n. 主人；大师；硕士；男教师；原件；院长；主宰者；船长；著名画家；少爷；桅船",
            ],
        }
        t = YoudaoTranslator()
        r = t.translate("auto", "zh", "master")
        self.assertEqual(translation, r)

    def test_translate_shell(self):
        translation = {
            "engine": "trans",
            "phonetic": "",
            "paraphrase": "",
            "explain": [
                "master",
                "/ˈmastər/",
                "",
                "主",
                "",
                "名词",
                "主",
                "master, host, owner, lord, Allah, party concerned",
                "硕士",
                "master, holder of a master's degree, master's degree",
                "师傅",
                "master, qualified worker",
                "大师",
                "master, great master",
                "师",
                "division, teacher, master, expert, model, example",
                "老爷",
                "master, lord, bureaucrat, maternal grandfather",
                "主子",
                "master, boss",
                "主人翁",
                "master, hero",
                "雇主",
                "employer, master, hirer",
                "好手",
                "master",
                "爷",
                "father, master, grandfather, grandpa, grandpapa, old gentleman",
                "",
                "动词",
                "精通",
                "master, be proficient in, have a good command",
                "学会",
                "learn, master, study, be taught, be trained, become skilled at",
                "征服",
                "conquer, subdue, subjugate, master, vanquish, subject",
                "树立",
                "adopt, acquire, assert, maintain, affirm, master",
                "",
                "形容词",
                "主要的",
                "foremost, key, staple, governing, master",
                "主人的",
                "master",
                "",
                "master",
                "主, 硕士, 主人",
            ],
        }
        t = TranslateShell()
        r = t.translate("auto", "zh", "master")
        self.maxDiff = None
        self.assertEqual(translation, r)


if __name__ == "__main__":
    unittest.main()
