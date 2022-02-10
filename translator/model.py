from typing import List


class Translation:
    def __init__(
        self,
        engine: str,
        text: str,
        source_lang: str,
        target_lang: str,
        phonetic: str,
        paraphrase: str,
        explains: List[str],
    ) -> None:
        self.engine = engine
        self.text = text
        self.source_lang = source_lang
        self.target_lang = target_lang
        self.phonetic = phonetic
        self.paraphrase = paraphrase
        self.explains = explains

    def __repr__(self) -> str:
        ...

    def __str__(self) -> str:
        ...
