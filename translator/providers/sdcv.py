# -*- coding: utf-8 -*-
import re
import sys
import os
from ._base import BaseProvider

class SdcvProvider(BaseProvider):
    def __init__(self):
        super(SdcvProvider, self).__init__("sdcv")

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

