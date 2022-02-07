# -*- coding: utf-8 -*-
import re
import os
from ._base import BaseTranslator

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


