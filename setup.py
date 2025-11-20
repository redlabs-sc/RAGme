"""
RAGME Setup Configuration
Self-Evolving AI System
"""

from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

with open("requirements.txt", "r", encoding="utf-8") as fh:
    requirements = [line.strip() for line in fh if line.strip() and not line.startswith("#")]

setup(
    name="ragme",
    version="0.1.0",
    author="RAGME Team",
    author_email="",
    description="Self-Evolving AI System with Autonomous Capability Generation",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/redlabs-sc/RAGme",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "Topic :: Scientific/Engineering :: Artificial Intelligence",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
    ],
    python_requires=">=3.11",
    install_requires=requirements,
    entry_points={
        "console_scripts": [
            "ragme=ragme.cli.main:main",
        ],
    },
)
