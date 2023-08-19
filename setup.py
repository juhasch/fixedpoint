from os import path
from setuptools import find_packages, setup

this_directory = path.abspath(path.dirname(__file__))
with open(path.join(this_directory, 'README.md'), encoding='utf-8') as f:
    long_description = f.read()

setup(
    name="FixedPoint",
    version="0.0.1",
    author="Juergen Hasch",
    author_email="juergen.hasch@elbonia.de",
    description="Fixed point calculations",
    long_description=long_description,
    long_description_content_type='text/markdown',
    license="BSD 3-Clause Clear License",
    keywords="Fixedpoint ",
    python_requires=">=3.10",
    url="https://github.com/juhasch/fixedpoint",
    packages=find_packages(),
    include_package_data=True,
    install_requires=[
        'numpy>=1.18.0',
    ],
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "Topic :: Software Development :: Libraries :: Python Modules",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.7",
    ],
)
