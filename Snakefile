#!/usr/bin/env python3
# The above line is a lie, but it's close enough to the truth to make syntax
# highlighting happen. Snakemake syntax is an extension of Python 3 syntax.
from exquisite_corpus.tokens import CLD2_LANGUAGES
from collections import defaultdict


SOURCE_LANGUAGES = {
    # OPUS's data files of OpenSubtitles 2016
    #
    # Include languages with at least 500 subtitle files, but skip:
    # - 'ze' because that's not a real language code
    #   (it seems to represent code-switching Chinese and English)
    # - 'th' because we don't know how to tokenize it
    'opensubtitles': [
        'ar', 'bg', 'bs', 'ca', 'cs', 'da', 'de', 'el', 'en', 'es', 'fa', 'fi',
        'fr', 'he', 'hr', 'hu', 'id', 'is', 'it', 'ja', 'ko', 'lt', 'mk', 'ms',
        'nl', 'nb', 'pl', 'pt-PT', 'pt-BR', 'pt', 'ro', 'ru', 'sh-Latn', 'si', 'sk',
        'sl', 'sq', 'sr', 'sv', 'tr', 'uk', 'vi', 'zh-Hans', 'zh-Hant', 'zh'
    ],

    # Europarl v7, which also comes from OPUS
    'europarl': [
        'bg', 'cs', 'da', 'de', 'el', 'en', 'es', 'et', 'fi', 'fr', 'hu', 'it',
        'lt', 'lv', 'nl', 'pl', 'pt-PT', 'pt', 'ro', 'sk', 'sl', 'sv'
    ],

    # GlobalVoices (LREC 2012), from OPUS -- languages with over 50,000 tokens
    'globalvoices': [
        'ar', 'aym', 'bg', 'bn', 'ca', 'cs', 'da', 'de', 'en', 'eo', 'es',
        'fa', 'fil', 'fr', 'hi', 'hu', 'id', 'it', 'ja', 'km', 'mg', 'mk',
        'my', 'nl', 'pl', 'pt', 'ro', 'ru', 'sr', 'sv', 'sw', 'tr', 'ur',
        'zh-Hans', 'zh-Hant', 'zh'
    ],

    # Tatoeba 2014, from OPUS -- languages with over 50,000 tokens.
    # Skip 'ber' (we don't have the ability to sort out the dialects and
    # scripts of Berber and Tamazight) and 'tlh' (Klingon is not useful enough
    # for the tokenization code it would require).
    'tatoeba': [
        'en', 'eo', 'de', 'fr', 'es', 'ja', 'ru', 'tr', 'it', 'pt', 'he',
        'pl', 'zh-Hans', 'zh', 'hu', 'nl', 'uk', 'fi', 'mn', 'fa', 'ar',
        'da', 'sv', 'bg', 'ia', 'is', 'nb', 'la', 'el', 'fil', 'lt', 'jbo',
        'sr'
    ],

    # Sufficiently large, non-spammy Wikipedias.
    # See https://meta.wikimedia.org/wiki/List_of_Wikipedias -- we're looking
    # for Wikipedias that have at least 100,000 articles and a "depth" measure
    # of 10 or more (indicated that they're not mostly written by bots).
    'wikipedia': [
        'ar', 'bg', 'bs', 'ca', 'cs', 'da', 'de', 'el', 'en', 'eo', 'es', 'et',
        'eu', 'fa', 'fi', 'fr', 'gl', 'he', 'hi', 'hu', 'hr', 'hy', 'id', 'it',
        'ja', 'ko', 'la', 'lt', 'lv', 'ms', 'nn', 'nb', 'nl', 'pl', 'pt',
        'ro', 'ru', 'sh-Latn', 'sk', 'sl', 'sr-Cyrl', 'sv', 'tr', 'uk', 'uz',
        'vi', 'zh'
    ],

    # 99.2% of Reddit is in English. Some text that's in other languages is
    # just spam, but these languages seem to have a reasonable amount of
    # representative text.
    #
    # The frequency of the Balkan languages is surprising, but it seems to be
    # legit.
    'reddit/merged': [
        'en', 'es', 'fr', 'de', 'it', 'nl', 'sv', 'nb', 'da', 'fi', 'is',
        'sh-Latn', 'sr-Cyrl', 'pl', 'ro', 'ru', 'uk', 'hi', 'tr', 'ar', 'ja',
        'eo', 'fil'
    ],

    # Skip Greek because of kaomoji, Simplified Chinese because it's largely
    # spam
    'twitter': [
        'en', 'ar', 'ja', 'ru', 'es', 'tr', 'id', 'pt', 'ko', 'fr', 'ms',
        'it', 'de', 'nl', 'pl', 'hi', 'fil', 'uk', 'sh-Latn', 'sr-Cyrl',
        'ca', 'ta', 'gl', 'fa', 'ne', 'ur', 'he', 'da', 'fi', 'zh-Hant',
        'mn', 'su', 'bn', 'lv', 'jv', 'nb', 'bg', 'mk', 'cs', 'ro', 'hu',
        'sw', 'vi', 'az', 'sq'
    ],

    # NewsCrawl 2014, from the EMNLP Workshops on Statistical Machine Translation
    'newscrawl': ['en', 'fr', 'fi', 'de', 'cs', 'ru'],

    # Google Ngrams 2012
    'google': ['en', 'zh-Hans', 'zh', 'fr', 'de', 'he', 'it', 'ru', 'es'],

    # Jieba's built-in wordlist
    'jieba': ['zh'],

    # Leeds
    'leeds': ['ar', 'de', 'el', 'en', 'es', 'fr', 'it', 'ja', 'pt', 'ru', 'zh'],

    # The Hungarian Webcorpus by Halácsy et al., from http://mokk.bme.hu/resources/webcorpus/
    'mokk': ['hu'],

    # SUBTLEX: word counts from subtitles
    'subtlex': ['en-US', 'en-GB', 'en', 'de', 'nl', 'pl', 'zh-Hans', 'zh'],
}

FULL_TEXT_SOURCES = [
    'wikipedia', 'reddit/merged', 'twitter', 'opensubtitles', 'tatoeba',
    'newscrawl', 'europarl', 'globalvoices'
]

LANGUAGE_VARIANTS = {
    'pt': ['pt-PT', 'pt-BR'],
    'en': ['en-US', 'en-GB'],
    'zh': ['zh-Hans', 'zh-Hant']
}

OPUS_LANGUAGE_MAP = {
    'pt-PT': 'pt',
    'pt-BR': 'pt_br',
    'zh-Hans': 'zh_cn',
    'zh-Hant': 'zh_tw',
    'nb': 'no',
}
GLOBALVOICES_LANGUAGE_MAP = {
    'ja': 'jp',
    'zh-Hant': 'zht',
    'zh-Hans': 'zhs'
}
TATOEBA_LANGUAGE_MAP = {
    'zh-Hans': 'cmn',
    'fa': 'pes',
    'fil': 'tl',
    'sr-Cyrl': 'sr'
}
WP_LANGUAGE_MAP = {
    'sr-Cyrl': 'sr',
    'fil': 'tl'
}
WP_VERSION = '20161120'
GOOGLE_LANGUAGE_MAP = {
    'en': 'eng',
    'zh-Hans': 'chi-sim',
    'fr': 'fre',
    'de': 'ger',
    'he': 'heb',
    'it': 'ita',
    'ru': 'rus',
    'es': 'spa'
}
GOOGLE_1GRAM_SHARDS = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e',
    'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'other',
    'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
]
REDDIT_SHARDS = ['{:04d}-{:02d}'.format(y, m) for (y, m) in (
    [(2007, month) for month in range(10, 12 + 1)] +
    [(year, month) for year in range(2008, 2015) for month in range(1, 12 + 1)] +
    [(2015, month) for month in range(1, 5 + 1)]
)]


LANGUAGE_SOURCES = defaultdict(list)
for source in SOURCE_LANGUAGES:
    for _lang in SOURCE_LANGUAGES[source]:
        LANGUAGE_SOURCES[_lang].append(source)

SUPPORTED_LANGUAGES = sorted([_lang for _lang in LANGUAGE_SOURCES if len(LANGUAGE_SOURCES[_lang]) >= 3])
TOKENIZED_LANGUAGES = [_lang for _lang in SUPPORTED_LANGUAGES if '-' not in _lang and _lang != 'zh' and _lang != 'sr' and _lang != 'sh' and _lang != 'pt']


def language_count_sources(lang):
    """
    Get all the source of word counts we have in a language.
    """
    return [
        "data/counts/{source}/{lang}.txt".format(source=source, lang=lang)
        for source in LANGUAGE_SOURCES[lang]
    ]


def language_text_sources(lang):
    return [
        "data/tokenized/{source}/{lang}.txt".format(source=source, lang=lang)
        for source in LANGUAGE_SOURCES[lang]
        if source in FULL_TEXT_SOURCES
    ]


rule all:
    input:
        expand("data/freqs/{lang}.txt", lang=SUPPORTED_LANGUAGES),
        expand("data/skipgrams/{lang}.vec", lang=TOKENIZED_LANGUAGES)


# Downloaders
# ===========

rule download_opensubtitles_monolingual:
    output:
        "data/downloaded/opensubtitles/{lang}.txt.gz"
    run:
        source_lang = OPUS_LANGUAGE_MAP.get(wildcards.lang, wildcards.lang)
        shell("curl -L 'http://opus.lingfil.uu.se/download.php?f=OpenSubtitles2016/mono/OpenSubtitles2016.raw.{source_lang}.gz' -o {output}")
    resources:
        download=1, opusdownload=1
    priority: 0

rule download_europarl_monolingual:
    output:
        "data/downloaded/europarl/{lang}.txt"
    run:
        source_lang = OPUS_LANGUAGE_MAP.get(wildcards.lang, wildcards.lang)
        shell("curl -L 'http://opus.lingfil.uu.se/download.php?f=Europarl/mono/Europarl.raw.{source_lang}.gz' | zcat > {output}")
    resources:
        download=1, opusdownload=1
    priority: 0

rule download_globalvoices_monolingual:
    output:
        "data/downloaded/globalvoices/{lang}.txt"
    run:
        source_lang = GLOBALVOICES_LANGUAGE_MAP.get(wildcards.lang, wildcards.lang)
        shell("curl -L 'http://opus.lingfil.uu.se/download.php?f=GlobalVoices/mono/GlobalVoices.raw.{source_lang}.gz' | zcat > {output}")
    resources:
        download=1, opusdownload=1
    priority: 0


rule download_tatoeba_monolingual:
    output:
        "data/downloaded/tatoeba/{lang}.txt"
    run:
        source_lang = TATOEBA_LANGUAGE_MAP.get(wildcards.lang, wildcards.lang)
        shell("curl -L 'http://opus.lingfil.uu.se/download.php?f=Tatoeba/mono/Tatoeba.raw.{source_lang}.gz' | zcat > {output}")
    resources:
        download=1, opusdownload=1
    priority: 0



rule download_wikipedia:
    output:
        "data/downloaded/wikipedia/wikipedia_{lang}.xml.bz2"
    run:
        source_lang = WP_LANGUAGE_MAP.get(wildcards.lang, wildcards.lang)
        version = WP_VERSION
        shell("curl 'ftp://ftpmirror.your.org/pub/wikimedia/dumps/{source_lang}wiki/{version}/{source_lang}wiki-{version}-pages-articles.xml.bz2' -o {output}")
    resources:
        download=1, wpdownload=1
    priority: 0

rule download_newscrawl:
    output:
        "data/downloaded/newscrawl-2014-monolingual.tar.gz"
    shell:
        "curl -L 'http://www.statmt.org/wmt15/training-monolingual-news-2014.tgz' -o {output}"

rule download_google:
    output:
        "data/downloaded/google/1grams-{lang}-{shard}.txt.gz"
    run:
        source_lang = GOOGLE_LANGUAGE_MAP.get(wildcards.lang, wildcards.lang)
        shard = wildcards.shard
        if source_lang == 'heb' and shard == 'other':
            # This file happens not to exist
            shell("echo -n '' | gzip -c > {output}")
        else:
            # Do a bit of pre-processing as we download
            shell("curl -L 'http://storage.googleapis.com/books/ngrams/books/googlebooks-{source_lang}-all-1gram-20120701-{shard}.gz' | zcat | cut -f 1,3 | gzip -c > {output}")

# Handling downloaded data
# ========================
rule extract_newscrawl:
    input:
        "data/downloaded/newscrawl-2014-monolingual.tar.gz"
    output:
        expand("data/extracted/newscrawl/training-monolingual-news-2014/news.2014.{lang}.shuffled", lang=SOURCE_LANGUAGES['newscrawl'])
    shell:
        "tar xf {input} -C data/extracted/newscrawl && touch data/extracted/newscrawl/training-monolingual-news-2014/*"

rule extract_google:
    input:
        expand("data/downloaded/google/1grams-{{lang}}-{shard}.txt.gz",
               shard=GOOGLE_1GRAM_SHARDS)
    output:
        "data/messy-counts/google/{lang}.txt"
    shell:
        # Lowercase the terms, remove part-of-speech tags such as _NOUN, and
        # run the result through the 'countmerge' utility
        r"zcat {input} | sed -n -e 's/\([^_	]\+\)\(_[A-Z]\+\)/\L\1/p' | countmerge > {output}"

rule extract_reddit:
    input:
        "data/raw/reddit/{year}/RC_{year}-{month}.bz2"
    output:
        "data/extracted/reddit/{year}-{month}.txt.gz"
    shell:
        "bunzip2 -c {input} | jq -r 'select(.score > 0) | .body' | fgrep -v '[deleted]' | sed -e 's/&gt;/>/g' -e 's/&lt;/</g' -e 's/&amp;/\&/g' | gzip -c > {output}"

# Transforming existing word lists
# ================================
# To convert the Leeds corpus, look for space-separated lines that start with
# an integer and a decimal. The integer is the rank, which we discard. The
# decimal is the frequency, and the remaining text is the term. Use sed -n
# with /p to output only lines where the match was successful.
#
# The decimals all have 2 digits after the decimal point; we drop the decimal
# point to effectively multiply them by 100 and get integers.
#
# Grep out the term "EOS", an indication that Leeds used MeCab and didn't
# strip out the EOS lines.

rule transform_leeds:
    input:
        "data/source-lists/leeds/internet-{lang}-forms.num"
    output:
        "data/messy-counts/leeds/{lang}.txt"
    shell:
        "sed -rn -e 's/([0-9]+) ([0-9]+).([0-9][0-9]) (.*)/\\4\t\\2\\3/p' {input} | grep -v 'EOS\t' > {output}"

# The Mokk Hungarian Web corpus comes from scraping all known .hu Web sites and
# filtering the results for whether they seemed to actually be Hungarian. The
# list contains different counts at different levels of filtering; we choose
# the second most permissive level, which is in the 3rd tab-separated field.

rule transform_mokk:
    input:
        "data/source-lists/mokk/web2.2-freq-sorted.txt"
    output:
        "data/messy-counts/mokk/hu.txt"
    shell:
        "iconv -f iso-8859-2 -t utf-8 {input} | cut -f 1,3 > {output}"

# SUBTLEX is different in each instance.
# The main issue with German is that it's mostly (but not entirely) in
# double-UTF-8.
rule transform_subtlex_de:
    input:
        "data/source-lists/subtlex/subtlex.de.txt"
    output:
        "data/messy-counts/subtlex/de.txt"
    shell:
        "tail -n +2 {input} | cut -f 1,3 | ftfy > {output}"

rule transform_subtlex_en:
    input:
        "data/source-lists/subtlex/subtlex.en-{region}.txt"
    output:
        "data/messy-counts/subtlex/en-{region}.txt"
    shell:
        "tail -n +2 {input} | cut -f 1,2 > {output}"

rule transform_subtlex_nl:
    input:
        "data/source-lists/subtlex/subtlex.nl.txt"
    output:
        "data/messy-counts/subtlex/nl.txt"
    shell:
        "tail -n +2 {input} | cut -f 1,2 > {output}"

rule transform_subtlex_pl:
    input:
        "data/source-lists/subtlex/subtlex.pl.txt"
    output:
        "data/messy-counts/subtlex/pl.txt"
    shell:
        "tail -n +2 {input} | cut -f 1,5 > {output}"

rule transform_subtlex_zh:
    input:
        "data/source-lists/subtlex/subtlex.zh.txt"
    output:
        "data/messy-counts/subtlex/zh-Hans.txt"
    shell:
        "tail -n +2 {input} | cut -f 1,5 > {output}"

rule transform_jieba:
    input:
        "data/source-lists/jieba/dict.txt.big"
    output:
        "data/messy-counts/jieba/zh.txt"
    shell:
        "cut -d ' ' -f 1,2 {input} | tr ' ' '\t' | xc simplify-chinese - {output}"

# Tokenizing
# ==========

rule tokenize_wikipedia:
    input:
        "data/downloaded/wikipedia/wikipedia_{lang}.xml.bz2"
    output:
        "data/tokenized/wikipedia/{lang}.txt"
    shell:
        "bunzip2 -c {input} | wiki2text | xc tokenize -l {wildcards.lang} > {output}"

rule tokenize_europarl:
    input:
        "data/downloaded/europarl/{lang}.txt"
    output:
        "data/tokenized/europarl/{lang}.txt"
    shell:
        # Remove country codes and fix mojibake
        "sed -e 's/([A-Z][A-Z]\+)//g' {input} | ftfy | xc tokenize -l {wildcards.lang} > {output}"

rule tokenize_tatoeba:
    input:
        "data/downloaded/tatoeba/{lang}.txt"
    output:
        "data/tokenized/tatoeba/{lang}.txt"
    shell:
        "xc tokenize -l {wildcards.lang} {input} {output}"

rule tokenize_globalvoices:
    input:
        "data/downloaded/globalvoices/{lang}.txt"
    output:
        "data/tokenized/globalvoices/{lang}.txt"
    shell:
        "sed -e 's/· Global Voices//' {input} | xc tokenize -c -l {wildcards.lang} - {output}"

rule tokenize_newscrawl:
    input:
        "data/extracted/newscrawl/training-monolingual-news-2014/news.2014.{lang}.shuffled"
    output:
        "data/tokenized/newscrawl/{lang}.txt"
    shell:
        "xc tokenize -c -l {wildcards.lang} {input} {output}"

rule tokenize_gzipped_text:
    input:
        "data/downloaded/{dir}/{lang}.txt.gz"
    output:
        "data/tokenized/{dir}/{lang}.txt"
    shell:
        "zcat {input} | xc tokenize -l {wildcards.lang} > {output}"

rule tokenize_reddit:
    input:
        "data/extracted/reddit/{date}.txt.gz"
    output:
        expand("data/tokenized/reddit/{{date}}/{lang}.txt", lang=SOURCE_LANGUAGES['reddit/merged'])
    shell:
        "zcat {input} | xc tokenize-by-language -m reddit - data/tokenized/reddit/{wildcards.date}"

rule tokenize_twitter:
    input:
        "data/raw/twitter/twitter-2014.txt.gz",
        "data/raw/twitter/twitter-2015.txt.gz"
    output:
        expand("data/tokenized/twitter/{lang}.txt", lang=SOURCE_LANGUAGES['twitter'])
    shell:
        "zcat {input} | xc tokenize-by-language -m twitter - data/tokenized/twitter"


# Counting tokens
# ===============
rule count_tokens:
    input:
        "data/tokenized/{source}/{lang}.txt"
    output:
        "data/counts/{source}/{lang}.txt"
    shell:
        "xc count {input} {output}"

# Merging frequencies
rule merge_freqs:
    input:
        lambda wildcards: language_count_sources(wildcards.lang)
    output:
        "data/freqs/{lang}.txt"
    shell:
        "xc merge-freqs {input} {output}"


# Handling overlapping languages
# ==============================

# Reddit has a fair amount of conversation in Serbo-Croatian. cld2 cannot
# actually distinguish what country the speaker is in, so the Latin text
# ends up spread pretty much arbitrarily between Serbian, Croatian, and
# Bosnian. Here, we re-split the data into Latin text (Serbo-Croatian)
# and Cyrillic (Serbian).

rule debalkanize_reddit_sh:
    input:
        expand("data/counts/reddit/{{date}}/{lang}.txt", lang=['bs', 'hr', 'sr'])
    output:
        "data/counts/reddit/{date}/sh-Latn.txt"
    shell:
        "grep -vh '[А-Яа-я]' {input} | xc recount - {output} -l sh"

# Twitter has the same effect.
rule debalkanize_twitter_sh:
    input:
        expand("data/counts/twitter/{lang}.txt", lang=['bs', 'hr', 'sr'])
    output:
        "data/counts/twitter/sh-Latn.txt"
    shell:
        "grep -vh '[А-Яа-я]' {input} | xc recount - {output} -l sh"

# OpenSubtitles is presumably separated by country, but we also want to align
# it with the 'sh' data we have from other sources.
rule debalkanize_opensubtitles_sh:
    input:
        expand("data/counts/opensubtitles/{lang}.txt", lang=['bs', 'hr', 'sr'])
    output:
        "data/counts/opensubtitles/sh-Latn.txt"
    shell:
        "grep -vh '[А-Яа-я]' {input} | xc recount - {output} -l sh"

rule debalkanize_reddit_sr:
    input:
        "data/counts/reddit/{date}/sr.txt"
    output:
        "data/counts/reddit/{date}/sr-Cyrl.txt"
    shell:
        "egrep '[А-Яа-я]|__total__' {input} | xc recount - {output} -l sr"

# Twitter has the same effect.
rule debalkanize_twitter_sr:
    input:
        "data/counts/twitter/sr.txt"
    output:
        "data/counts/twitter/sr-Cyrl.txt"
    shell:
        "egrep '[А-Яа-я]|__total__' {input} | xc recount - {output} -l sr"

rule recount_messy_tokens:
    input:
        "data/messy-counts/{source}/{lang}.txt"
    output:
        "data/counts/{source}/{lang}.txt"
    shell:
        "xc recount {input} {output} -l {wildcards.lang}"

rule merge_reddit:
    input:
        expand("data/counts/reddit/{date}/{{lang}}.txt", date=REDDIT_SHARDS)
    output:
        "data/counts/reddit/merged/{lang}.txt"
    shell:
        "cat {input} | xc recount - {output} -l {wildcards.lang}"

rule merge_subtlex_en:
    input:
        "data/counts/subtlex/en-GB.txt",
        "data/counts/subtlex/en-US.txt",
    output:
        "data/counts/subtlex/en.txt"
    shell:
        "cat {input} | xc recount - {output} -l en"

rule merge_opensubtitles_pt:
    input:
        "data/counts/opensubtitles/pt-BR.txt",
        "data/counts/opensubtitles/pt-PT.txt",
    output:
        "data/counts/opensubtitles/pt.txt"
    shell:
        "cat {input} | xc recount - {output} -l pt"

rule merge_opensubtitles_zh:
    input:
        "data/counts/opensubtitles/zh-Hans.txt",
        "data/counts/opensubtitles/zh-Hant.txt",
    output:
        "data/counts/opensubtitles/zh.txt"
    shell:
        "cat {input} | xc recount - {output} -l zh"

rule merge_globalvoices_zh:
    input:
        "data/counts/globalvoices/zh-Hans.txt",
        "data/counts/globalvoices/zh-Hant.txt",
    output:
        "data/counts/globalvoices/zh.txt"
    shell:
        "cat {input} | xc recount - {output} -l zh"

rule copy_google_zh:
    input:
        "data/counts/google/zh-Hans.txt"
    output:
        "data/counts/google/zh.txt"
    shell:
        "cp {input} {output}"

rule copy_tatoeba_zh:
    input:
        "data/counts/tatoeba/zh-Hans.txt"
    output:
        "data/counts/tatoeba/zh.txt"
    shell:
        "cp {input} {output}"

rule copy_subtlex_zh:
    input:
        "data/counts/subtlex/zh-Hans.txt"
    output:
        "data/counts/subtlex/zh.txt"
    shell:
        "cp {input} {output}"

rule copy_europarl_pt:
    input:
        "data/counts/europarl/pt-PT.txt"
    output:
        "data/counts/europarl/pt.txt"
    shell:
        "cp {input} {output}"


# Assembling corpus text
# ======================

rule combine_reddit:
    input:
        expand("data/tokenized/reddit/{date}/{{lang}}.txt", date=REDDIT_SHARDS)
    output:
        "data/tokenized/reddit/merged/{lang}.txt"
    run:
        if wildcards.lang == 'en':
            shell("cat {input} | split -n r/1/50 > {output}")
        else:
            shell("cat {input} > {output}")

rule shuffle_full_text:
    input:
        lambda wildcards: language_text_sources(wildcards.lang)
    output:
        "data/shuffled/{lang}.txt"
    shell:
        "grep -h '.' {input} | scripts/imperfect-shuffle.sh {output} {wildcards.lang}"

rule fasttext_skipgrams:
    input:
        "data/shuffled/{lang}.txt"
    output:
        "data/skipgrams/{lang}.vec",
        "data/skipgrams/{lang}.bin"
    shell:
        "fasttext skipgram -epoch 10 -input {input} -output data/skipgrams/{wildcards.lang}"

ruleorder:
    merge_reddit > \
    merge_subtlex_en > merge_opensubtitles_pt > merge_opensubtitles_zh > merge_globalvoices_zh > \
    debalkanize_reddit_sh > debalkanize_twitter_sh > debalkanize_reddit_sr > debalkanize_twitter_sr > \
    copy_google_zh > copy_tatoeba_zh > copy_europarl_pt > \
    recount_messy_tokens > count_tokens

