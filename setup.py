from setuptools import find_packages, setup

setup(
    name="FixedPoint",
    version="0.0.1",
    author="Juergen Hasch",
    author_email="juergen.hasch@elbonia.de",
    description="Fixed point calcilations",
    license="BSD 3-Clause Clear License",
    keywords="Fixedpoint ",
    python_requires=">=3.10",
    url="https://github.com/juhasch/fixedpoint",
    packages=find_packages(),
    install_requires=['numpy'],
    long_description_content_type='text/markdown',
    long_description="""
A simple Python module for fixedpoint calculations.
""",
    classifiers=[
        "Development Status :: 4 - Beta",
        "Topic :: Utilities",
        "License :: OSI Approved :: MIT License",
    ],
)
