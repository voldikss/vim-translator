import hashlib

from .. import compat

def md5sum(text: str) -> str:
    m = hashlib.md5()
    m.update(text.encode("utf-8"))
    return m.hexdigest()


def html_unescape(text: str) -> str:
    # https://stackoverflow.com/questions/2087370/decode-html-entities-in-python-string
    # Python 3.4+
    if compat.version_num >= "3.4":
        import html
        return html.unescape(text)
    try:
        # Python 2.6-2.7
        from HTMLParser import HTMLParser # type: ignore
    except ImportError:
        # Python 3+
        from html.parser import HTMLParser
    html_parser = HTMLParser()
    return html_parser.unescape(text) # type: ignore
