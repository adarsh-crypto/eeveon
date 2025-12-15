from setuptools import setup, find_packages
import os

# Read the README file
with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

# Read version from a version file
VERSION = "0.1.0"

setup(
    name="eeveon",
    version=VERSION,
    author="Adarsh",
    author_email="adarsh@example.com",
    description="A lightweight bash-based CI/CD pipeline for automatic deployment from GitHub",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/adarsh-crypto/eeveon",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "Topic :: Software Development :: Build Tools",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
        "Operating System :: POSIX :: Linux",
    ],
    python_requires=">=3.6",
    install_requires=[
        # No Python dependencies - uses system tools
    ],
    entry_points={
        "console_scripts": [
            "eeveon=bin.eeveon:main",
        ],
    },
    include_package_data=True,
    package_data={
        "": ["scripts/*.sh", "bin/*"],
    },
    scripts=[
        "bin/eeveon",
        "scripts/monitor.sh",
        "scripts/deploy.sh",
        "install.sh",
    ],
    keywords="ci cd deployment automation github devops pipeline",
    project_urls={
        "Bug Reports": "https://github.com/adarsh-crypto/eeveon/issues",
        "Source": "https://github.com/adarsh-crypto/eeveon",
        "Documentation": "https://github.com/adarsh-crypto/eeveon#readme",
    },
)
