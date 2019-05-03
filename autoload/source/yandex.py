# -*- coding: utf-8 -*-
# @Author: voldikss
# @Date: 2019-05-01 00:00:37
# @Last Modified by: voldikss
# @Last Modified time: 2019-05-01 00:00:37

import sys
import json
import argparse
import codecs

if sys.version_info[0] == 2:
    from urllib2 import urlopen
    from urllib import urlencode
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout)
else:
    from urllib.request import urlopen
    from urllib.parse import urlencode
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer)


YANDEX_URL = 'https://translate.yandex.net/api/v1.5/tr.json/translate'

ERROR_CODE = {
    200: "Operation completed successfully",
    401: "Invalid API key",
    402: "Blocked API key",
    404: "Exceeded the daily limit on the amount of translated text",
    413: "Exceeded the maximum text size",
    422: "The text cannot be translated",
    501: "The specified translation direction is not supported"
}


def buildQuery(word):
    data = {}
    data['key'] = APP_SECRET
    data['text'] = word.encode('utf-8')
    data['lang'] = to_lang
    return urlencode(data)


def vtmQuery(word):
    url = YANDEX_URL + '?' + buildQuery(word)

    try:
        res = urlopen(url).read()
    except Exception as e:
        sys.stderr.write("网络请求错误(HTTP request error):%s" % e)
        return

    # sample response content:
    # sample_res = {'code': 200, 'lang': 'en-zh', 'text': ['该应']}

    # sample stdout that we build
    # SAMPLE_STDOUT = {
    #     'data': {
    #         'query': 'word',
    #         'phonetic': 'phonetic',
    #         'translation': 'translation1',         # not necessary
    #         'explain': ['explains1', 'explains2']  # not necessary
    #     }
    # }

    try:
        data_json = json.loads(res.decode('utf-8'))
        if data_json['code'] != 200:
            sys.stderr.write(ERROR_CODE[data_json['code']])
            return

        trans = {}
        trans['query'] = word
        trans['translation'] = data_json.get('text', ['null'])[0]

        sys.stdout.write(str(trans))
    except Exception as e:
        sys.stderr.write("数据解析错误(Data parsing error) Line[%s]：%s" % (
            sys.exc_info()[2].tb_lineno, e))
        return


parser = argparse.ArgumentParser()
parser.add_argument('--word', required=False)
parser.add_argument('--appKey', required=False)
parser.add_argument('--appSecret', required=False)
parser.add_argument('--toLang', required=False)
args = parser.parse_args()

if not args.word:   # for debug
    APP_SECRET = 'trnsl.1.1.20190430T070040Z.b4d258419bc606c3.c91de1b8a30d1e62228a51de3bf0a036160b2293'
    to_lang = 'zh'
    vtmQuery('yandex')
else:
    APP_SECRET = args.appSecret
    # todo
    # to trim the string's quote/doublequote(becase `shellescape` was used in autoload/vtm.vim)
    word = args.word.strip('\'')
    word = word.strip('\"')
    word = word.strip()
    to_lang = args.toLang
    vtmQuery(word)
