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
    from urllib2 import urlopen
    from urllib import urlencode
else:
    from urllib.request import urlopen
    from urllib.parse import urlencode


BAIDU_URL = 'http://api.fanyi.baidu.com/api/trans/vip/translate'

ERROR_CODE = {
    '52000': '成功(Success)',
    '52001': '请求超时，请重试(HTTP request timed out, retry)',
    '52002': '系统错误，请重试(System error)',
    '52003': '未授权用户，请检查您的 appid 是否正确，或者服务是否开通(Unauthorized user, please check your appid or service)',
    '54000': '必填参数为空，请检查是否少传参数(Expected argument)',
    '54001': '签名错误，请检查您的签名生成方法(Sign error, please check your sign generation function)',
    '54003': '访问频率受限，请降低您的调用频率(Limited access frequency)',
    '54004': '账户余额不足，请前往管理控制台为账户充值(Insufficient balance for your account)',
    '54005': '长query请求频繁，请降低长query的发送频率，3s后再试(Too long and frequent requests)',
    '58000': '客户端IP非法(Invalid client IP address)',
    '58001': '译文语言方向不支持，检查译文语言是否在语言列表里(Not supported translation)',
    '58002': '服务当前已关闭，请前往管理控制台开启服务(Service has been closed, please start your service in the console)'
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
    data['to'] = to_lang
    data['salt'] = salt
    data['sign'] = sign
    return urlencode(data)


def vtmQuery(word):
    url = BAIDU_URL + '?' + buildQuery(word)
    try:
        res = urlopen(url).read()
    except Exception as e:
        sys.stderr.write("网络请求错误(HTTP request error) %s" % e)
        return

    # sample of the response from the youdao server
    # SAMPLE_RESPONSE = {
    #     'from': 'en',
    #     'to': 'zh',
    #     'trans_result': [{'src': 'sample', 'dst': '样品'}]
    # }

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
        trans = {}
        data_json = json.loads(res.decode('utf-8'))
        if 'error_code' in data_json:
            sys.stderr.write(ERROR_CODE[data_json['error_code']])
            return

        trans_result = data_json['trans_result'][0]
        trans['query'] = trans_result.get('src', 'null')
        trans['translation'] = trans_result.get('dst', 'null')

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
    APP_KEY = '20190429000292722'  # 你的appid
    APP_SECRET = 'sv566pogmFxLFUjaJY4e'  # 你的密钥
    to_lang = 'zh'
    vtmQuery('baidu')
else:
    APP_KEY = args.appKey
    APP_SECRET = args.appSecret
    # todo
    # to trim the string's quote/doublequote(becase `shellescape` was used in autoload/vtm.vim)
    word = args.word.strip('\'')
    word = word.strip('\"')
    word = word.strip()
    to_lang = args.toLang
    vtmQuery(word)
