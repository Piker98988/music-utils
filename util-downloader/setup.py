from setuptools import setup, find_packages

setup(
    name="pikers-spotifydown-scraper",
    version='0.0.1',
    author='piker',
    description='spotifydown.com web scraper that lets you interact with website via a cli',
    packages=find_packages(),
    install_requires=[
        "loguru",
        "playwright"
    ],
)
