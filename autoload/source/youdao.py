# -*- coding: utf-8 -*-
# @Author: voldikss
# @Date: 2019-04-24 22:28:42
# @Last Modified by: voldikss
# @Last Modified time: 2019-04-28 13:30:28

import sys
import codecs
import argparse
import uuid
import hashlib
import time
import json

if sys.version_info[0] == 2:
    from urllib2 import urlopen
    from urllib import urlencode
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout)
else:
    from urllib.request import urlopen
    from urllib.parse import urlencode
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer)


YOUDAO_URL = 'http://openapi.youdao.com/api'


ERROR_CODE = {
    '101': '缺少必填的参数(Expected arguments were not filled)',
    '102': '不支持的语言类型(Not supported language)',
    '103': '翻译文本过长(Text is too long to translate)',
    '104': '不支持的API类型(Not supported API)',
    '105': '不支持的签名类型(Not supported signature)',
    '106': '不支持的响应类型(Not supported response)',
    '107': '不支持的传输加密类型(Not supported transport encryption)',
    '108': 'appKey无效(Invalid appKey)',
    '109': 'batchLog格式不正确(Wrong format batchLog)',
    '110': '无相关服务的有效实例(No instance for relative service)',
    '111': '开发者账号无效(Invalid developer account)',
    '113': 'q不能为空(q can\' be empty)',
    '201': '解密失败(Failed to decode)',
    '202': '签名检验失败(Signature checking failed)',
    '203': '访问IP地址不在可访问IP列表(Not permitted IP address)',
    '205': '请求的接口与应用的平台类型不一致(The API you request isn\'t consistent with the platform of application)',
    '206': '因为时间戳无效导致签名校验失败(Signature checking failed due to invalid time stamp)',
    '207': '重放请求(Replay request)',
    '301': '辞典查询失败(Dictionary looking up failed)',
    '302': '翻译查询失败(Translation looking up failed)',
    '303': '服务端的其它异常(Other exception of server)',
    '401': '账户已经欠费停(Your account is out of credit)',
    '411': '访问频率受限,请稍后访问(Limited access frequency)',
    '412': '长请求过于频繁，请稍后访问(Long request is too frequent)'
}


def encrypt(sign_str):
    hash_algorithm = hashlib.sha256()
    hash_algorithm.update(sign_str.encode('utf-8'))
    return hash_algorithm.hexdigest()


def truncate(q):
    if q is None:
        return None
    size = len(q)
    return q if size <= 20 else q[0:10] + str(size) + q[size - 10:size]


def buildQuery(word):
    data = {}
    data['from'] = 'auto'
    data['to'] = to_lang
    data['signType'] = 'v3'
    curtime = str(int(time.time()))
    data['curtime'] = curtime
    salt = str(uuid.uuid1())
    sign_str = APP_KEY + truncate(word) + salt + curtime + APP_SECRET
    sign = encrypt(sign_str)
    data['appKey'] = APP_KEY
    data['q'] = word
    data['salt'] = salt
    data['sign'] = sign
    return urlencode(data)


# todo
def byteify(input, encoding='utf-8'):
    if isinstance(input, dict):
        return {byteify(key): byteify(value) for key, value in input.iteritems()}
    elif isinstance(input, list):
        return [byteify(element) for element in input]
    elif isinstance(input, unicode):
        return input.encode(encoding)
    else:
        return input


def vtmQuery(word):
    url = YOUDAO_URL + '?' + buildQuery(word)
    try:
        res = urlopen(url).read()
    except Exception as e:
        sys.stderr.write("网络请求错误(HTTP request error) %s" % e)
        return

    # sample of the response from the youdao server
    # SAMPLE_RESPONSE = {
    #     "tSpeakUrl": "...",
    #     "returnPhrase": ["test"],
    #     "web": [
    #         {"value": ["正交试验", "正交实验法", "正交设计"], "key":"orthogonal test"},
    #         {"value": ["双缩脲试剂", "二缩", "双脲试验"], "key":"biuret test"},
    #         {"value": ["项测试", "长期试验", "期中考试"], "key":"Term test"}],
    #     "query": "test",
    #     "translation": ["测试"],
    #     "errorCode": "0",
    #     "dict": {"url": "yddict://m.youdao.com/dict?le=eng&q=test"},
    #     "webdict": {"url": "http://m.youdao.com/dict?le=eng&q=test"},
    #     "basic": {
    #         "exam_type": ["高中", "初中"],
    #         "us-phonetic": "tɛst",
    #         "phonetic": "test",
    #         "uk-phonetic": "test",
    #         "uk-speech": "...",
    #         "explains": ["n. 试验；检验", "vt. 试验；测试", "vi. 试验；测试", "n. (Test)人名"],
    #         "us-speech": "..."
    #     },
    #     "l": "en2zh-CHS",
    #     "speakUrl": "..."
    # }

    # sample stdout that we build
    # SAMPLE_STDOUT = {
    #     'data': {
    #         'query': 'word',
    #         'phonetic': 'phonetic',
    #         'translation': 'translation1',        # not necessary
    #         'explain': ['explains1', 'explains2'] # not necessary
    #     }
    # }

    try:
        data_json = json.loads(res.decode('utf-8'))
        if data_json['errorCode'] != "0":
            sys.stderr.write(ERROR_CODE[data_json['errorCode']])
            return

        trans = {}
        trans['query'] = data_json['query']
        trans['translation'] = data_json['translation'][0]
        # sometimes data_json['basic'] is type <'None'>
        if 'basic' in data_json and data_json['basic']:
            basic = data_json['basic']
            if 'phonetic' in basic:
                trans['phonetic'] = basic['phonetic']
            if 'explains' in basic:
                trans['explain'] = basic['explains']

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

if not args.word:  # for debug
    APP_KEY = '70d26c625f056dba'
    APP_SECRET = 'wqbp7g6MloxwmOTUGSkMghnIWxTGOyrp'
    to_lang = 'zh-CHS'
    vtmQuery('import')
else:
    APP_KEY = args.appKey
    APP_SECRET = args.appSecret
    # todo
    # to trim the string's quote/doublequote(becase `shellescape` was used in autoload/vtm.vim)
    word = args.word.strip('\'')
    word = word.strip('\"')
    word = word.strip()
    to_lang = args.toLang
    if to_lang == 'zh':
        to_lang = 'zh-CHS'
    vtmQuery(word)
