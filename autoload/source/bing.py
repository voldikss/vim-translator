# -*- coding: utf-8 -*-
# @Author: voldikss
# @Date: 2019-04-30 17:47:30
# @Last Modified by: voldikss
# @Last Modified time: 2019-04-30 17:47:30

import sys
import json
import argparse
import uuid

if sys.version_info[0] == 2:
    from urllib2 import Request
    from urllib2 import urlopen
else:
    from urllib.request import urlopen
    from urllib.request import Request


BING_URL = 'https://api.cognitive.microsofttranslator.com/translate?api-version=3.0'


def vtmQuery(word):
    url = BING_URL + '&to=' + to_lang
    headers = {
        'Ocp-Apim-Subscription-Key': APP_SECRET,
        'Content-type': 'application/json',
        'X-ClientTraceId': str(uuid.uuid4())
    }

    body = [{
        'text': word
    }]

    try:
        if sys.version_info[0] == 2:
            req = Request(url, headers=headers)
            res = urlopen(req, json.dumps(body)).read()
        else:
            req = Request(url, headers=headers)
            json_d = json.dumps(body)
            json_b = json_d.encode('utf-8')
            req.add_header('Content-Length', len(json_b))
            res = urlopen(req, json_b).read()
    except Exception as e:
        sys.stderr.write("网络请求错误(HTTP request error):%s" % e)
        return

    # sample response content:
    # sample_res = {'query': 'response', 'translation': '响应'}

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
        data_json = json.loads(res.decode('utf-8'))[0]
        if 'error' in data_json:
            sys.stderr.write(data_json['error']['message'])
            return

        trans = {}
        trans_result = data_json['translations'][0]
        trans['query'] = word
        trans['translation'] = trans_result.get('text', 'null')

        sys.stdout.write(str(trans))
    except Exception as e:
        sys.stderr.write("数据解析错误(Data parsing error)[%s]：%s" % (sys.exc_info()[2].tb_lineno, e))
        return


parser = argparse.ArgumentParser()
parser.add_argument('--word', required=False)
parser.add_argument('--appKey', required=False)
parser.add_argument('--appSecret', required=False)
parser.add_argument('--toLang', required=False)
args = parser.parse_args()

if not args.word:
    APP_SECRET = '81d36c3ed9d4472ab270b165d7bfaf65'
    to_lang = 'zh'
    vtmQuery('response')
else:
    APP_SECRET = args.appSecret
    # todo
    # to trim the string's quote/doublequote(becase `shellescape` was used in autoload/vtm.vim)
    word = args.word.strip('\'')
    word = word.strip('\"')
    word = word.strip()
    to_lang = args.toLang
    vtmQuery(word)
