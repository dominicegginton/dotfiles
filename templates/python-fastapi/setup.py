#!/usr/bin/env python

from setuptools import setup, find_packages

setup(
    name='hello-world',
    version='0.0.0',
    packages=find_packages(),
    scripts=["hello-world"],
    install_requires=["fastapi", "uvicorn"],
)
