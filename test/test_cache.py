# -*- coding: utf-8 -*-
import os
import sys
import tempfile
import unittest

sys.path.append(
    os.path.abspath(os.path.join(os.path.dirname(__file__), "../script"))
)

from translator import TranslationCache


class TranslationCacheTest(unittest.TestCase):
    def test_result_is_reused_for_matching_arguments(self):
        with tempfile.TemporaryDirectory() as directory:
            cache = TranslationCache(os.path.join(directory, "cache.sqlite3"))
            result = {"engine": "google", "paraphrase": "你好", "explains": []}
            cache.save("google", "auto", "zh", "hello", [], result)

            self.assertEqual(
                result, cache.get("google", "auto", "zh", "hello", [])
            )
            self.assertIsNone(cache.get("google", "auto", "zh", "goodbye", []))


if __name__ == "__main__":
    unittest.main()
