import sys
import codecs


if sys.version_info.major < 3:
    is_py3 = False
    reload(sys)
    sys.setdefaultencoding("utf-8")
    sys.stdout = codecs.getwriter("utf-8")(sys.stdout)
    sys.stderr = codecs.getwriter("utf-8")(sys.stderr)
    from urlparse import urlparse
    from urllib import urlencode
    from urllib import quote_plus as urlquote
    from urllib2 import urlopen
    from urllib2 import Request
    from urllib2 import URLError
    from urllib2 import HTTPError
else:
    is_py3 = True
    sys.stdout = codecs.getwriter("utf-8")(sys.stdout.buffer)
    sys.stderr = codecs.getwriter("utf-8")(sys.stderr.buffer)
    from urllib.parse import urlencode
    from urllib.parse import quote_plus as urlquote
    from urllib.parse import urlparse
    from urllib.request import urlopen
    from urllib.request import Request
    from urllib.error import URLError
    from urllib.error import HTTPError

version_num = '.'.join(map(lambda i: str(i), sys.version_info[:3]))
