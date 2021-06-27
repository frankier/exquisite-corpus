from setuptools import setup

setup(
    name="exquisite_corpus",
    version='0.1',
    maintainer='Luminoso Technologies, Inc.',
    maintainer_email='rspeer@luminoso.com',
    platforms=["any"],
    description="Download and process many gigabytes of natural language data, assembled from various corpora.",
    packages=['exquisite_corpus'],
    include_package_data=True,
    install_requires=[
        'snakemake', 'jieba >= 0.42', 'wordfreq[jieba,mecab] >= 2.3.2',
        'click', 'regex >= 2020.04.04', 'pycld2', 'msgpack-python',
        'ordered-set', 'ftfy', 'subword-nmt', 'sentencepiece==0.1.86', 'mmh3',
        'pytest', 'tqdm<4.50.0', 'lumi-language-id', 'zstandard', 'langcodes[data] >= 2.1',
        'datasets',
    ],
    zip_safe=False,
    classifiers=[
        "Programming Language :: Python :: 3",
        'License :: OSI Approved :: MIT License',
    ],
    entry_points={
        'console_scripts': ['xc = exquisite_corpus.cli:cli'],
    },
)
