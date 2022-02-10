def test0():
    t = BaseTranslator("test_proxy")
    t.set_proxy("http://localhost:8087")
    t.test_request("https://www.google.com")

def test1():
    t = BaicizhanTranslator()
    r = t.translate("", "zh", "naive")
    print(r)

def test2():
    t = BingDict()
    r = t.translate("", "", "naive")
    print(r)

def test3():
    gt = GoogleTranslator()
    r = gt.translate("auto", "zh", "filencodings")
    print(r)

def test4():
    t = HaiciDict()
    r = t.translate("", "zh", "naive")
    print(r)

def test5():
    t = ICibaTranslator()
    r = t.translate("", "", "naive")
    print(r)

def test6():
    t = TranslateShell()
    r = t.translate("auto", "zh", "naive")
    print(r)

def test7():
    t = YoudaoTranslator()
    r = t.translate("auto", "zh", "naive")
    print(r)
