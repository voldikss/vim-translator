# -*- coding: utf-8 -*-
# @Author: voldikss
# @Date: 2019-04-24 22:28:42
# @Last Modified by: voldikss
# @Last Modified time: 2019-04-28 13:30:28

import sys
import argparse
import uuid
import hashlib
import time
import json

if sys.version_info[0] == 2:
    from urllib import urlopen
    from urllib import urlencode
else:
    from urllib.request import urlopen
    from urllib.parse import urlencode


YOUDAO_URL = 'http://openapi.youdao.com/api?'


ERROR_CODE = {
    '101': '缺少必填的参数，出现这个情况还可能是et的值和实际加密方式不对应',
    '102': '不支持的语言类型',
    '103': '翻译文本过长',
    '104': '不支持的API类型',
    '105': '不支持的签名类型',
    '106': '不支持的响应类型',
    '107': '不支持的传输加密类型',
    '108': 'appKey无效，注册账号， 登录后台创建应用和实例并完成绑定， 可获得应用ID和密钥等信息，其中应用ID就是appKey（ 注意不是应用密钥）',
    '109': 'batchLog格式不正确',
    '110': '无相关服务的有效实例',
    '111': '开发者账号无效',
    '113': 'q不能为空',
    '201': '解密失败，可能为DES,BASE64,URLDecode的错误',
    '202': '签名检验失败',
    '203': '访问IP地址不在可访问IP列表',
    '205': '请求的接口与应用的平台类型不一致，如有疑问请参考[入门指南]()',
    '206': '因为时间戳无效导致签名校验失败',
    '207': '重放请求',
    '301': '辞典查询失败',
    '302': '翻译查询失败',
    '303': '服务端的其它异常',
    '401': '账户已经欠费停',
    '411': '访问频率受限,请稍后访问',
    '412': '长请求过于频繁，请稍后访问'
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
    data['to'] = 'auto'
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


# sample of the response from the youdao server
SAMPLE_RESPONSE = {
    "tSpeakUrl": "...",
    "returnPhrase": ["test"],
    "web": [
        {"value": ["正交试验", "正交实验法", "正交设计"], "key":"orthogonal test"},
        {"value": ["双缩脲试剂", "二缩", "双脲试验"], "key":"biuret test"},
        {"value": ["项测试", "长期试验", "期中考试"], "key":"Term test"}],
    "query": "test",
    "translation": ["测试"],
    "errorCode": "0",
    "dict": {"url": "yddict://m.youdao.com/dict?le=eng&q=test"},
    "webdict": {"url": "http://m.youdao.com/dict?le=eng&q=test"},
    "basic": {
        "exam_type": ["高中", "初中"],
        "us-phonetic": "tɛst",
        "phonetic": "test",
        "uk-phonetic": "test",
        "uk-speech": "...",
        "explains": ["n. 试验；检验", "vt. 试验；测试", "vi. 试验；测试", "n. (Test)人名"],
        "us-speech": "..."
    },
    "l": "en2zh-CHS",
    "speakUrl": "..."
}


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


# sample stdout that we build
SAMPLE_STDOUT = {
    'data': {
        'query': 'word',
        'phonetic': 'phonetic',
        'translation': 'translation1',
        'explain': ['explains1', 'explains2']
    }
}


def vtmQuery(word):
    trans = {}
    url = YOUDAO_URL + buildQuery(word)
    try:
        data_back = urlopen(url).read()
    except:
        sys.stderr.write("网络请求错误，请检查网络")
        return

    try:
        data_json = json.loads(data_back.decode('utf-8'))
        if data_json['errorCode'] != "0":
            sys.stderr.write(ERROR_CODE[data_json['errorCode']])
            return

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
        sys.stderr.write("数据解析错误第[%s]行：%s" % (sys.exc_info()[2].tb_lineno, e))
        return


parser = argparse.ArgumentParser()
parser.add_argument('--word', required=False)
parser.add_argument('--appKey', required=False)
parser.add_argument('--appSecret', required=False)
args = parser.parse_args()

if not args.word:
    APP_KEY = '70d26c625f056dba'
    APP_SECRET = 'wqbp7g6MloxwmOTUGSkMghnIWxTGOyrp'
    vtmQuery('import')
else:
    APP_KEY = args.appKey
    APP_SECRET = args.appSecret
    # todo
    # to trim the string's quote/doublequote(becase `shellescape` was used in autoload/vtm.vim)
    word = args.word.strip('\'')
    word = word.strip('\"')
    vtmQuery(word)
