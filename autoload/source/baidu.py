# -*- coding: utf-8 -*-
# @Author: voldikss
# @Date: 2019-04-29 15:04:35
# @Last Modified by: voldikss
# @Last Modified time: 2019-04-29 15:04:35

import sys
import json
import random
import hashlib
import argparse

if sys.version_info[0] == 2:
    from urllib import urlopen
    from urllib import urlencode
else:
    from urllib.request import urlopen
    from urllib.parse import urlencode


BAIDU_URL = 'http://api.fanyi.baidu.com/api/trans/vip/translate'

ERROR_CODE = {
    '52000': '成功',
    '52001': '请求超时，请重试',
    '52002': '系统错误，请重试',
    '52003': '未授权用户，请检查您的 appid 是否正确，或者服务是否开通',
    '54000': '必填参数为空，请检查是否少传参数',
    '54001': '签名错误，请检查您的签名生成方法',
    '54003': '访问频率受限，请降低您的调用频率',
    '54004': '账户余额不足，请前往管理控制台为账户充值',
    '54005': '长query请求频繁，请降低长query的发送频率，3s后再试',
    '58000': '客户端IP非法，请检查个人资料里填写的 IP地址 是否正确，可前往管理控制平台修改，IP限制，IP可留空',
    '58001': '译文语言方向不支持，检查译文语言是否在语言列表里',
    '58002': '服务当前已关闭，请前往管理控制台开启服务'
}


def buildQuery(word):
    data = {}
    salt = random.randint(32768, 65536)
    sign = APP_KEY+word+str(salt)+APP_SECRET
    m = hashlib.md5()
    m.update(sign.encode('utf-8'))
    sign = m.hexdigest()
    data['appid'] = APP_KEY
    data['q'] = word
    data['from'] = 'auto'
    data['to'] = 'zh'
    data['salt'] = salt
    data['sign'] = sign
    return urlencode(data)


# sample of the response from the youdao server
SAMPLE_RESPONSE = {
    'from': 'en',
    'to': 'zh',
    'trans_result': [{'src': 'sample', 'dst': '样品'}]
}


# sample stdout that we build
SAMPLE_STDOUT = {
    'data': {
        'query': 'word',
        'phonetic': 'phonetic',
        'translation': 'translation1',         # not necessary
        'explain': ['explains1', 'explains2']  # not necessary
    }
}


def vtmQuery(word):
    trans = {}
    url = BAIDU_URL + '?' + buildQuery(word)
    try:
        data_back = urlopen(url).read()
    except:
        sys.stderr.write("网络请求错误，请检查网络")
        return

    try:
        data_json = json.loads(data_back.decode('utf-8'))
        if 'error_code' in data_json:
            sys.stderr.write(ERROR_CODE[data_json['error_code']])
            return

        trans_result = data_json['trans_result'][0]
        trans['query'] = trans_result.get('src', 'null')
        trans['translation'] = trans_result.get('dst', 'null')

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
    APP_KEY = '20190429000292722'  # 你的appid
    APP_SECRET = 'sv566pogmFxLFUjaJY4e'  # 你的密钥
    vtmQuery('baidu')
else:
    APP_KEY = args.appKey
    APP_SECRET = args.appSecret
    # todo
    # to trim the string's quote/doublequote(becase `shellescape` was used in autoload/vtm.vim)
    word = args.word.strip('\'')
    word = word.strip('\"')
    word = word.strip()
    vtmQuery(word)
