from setuptools import setup, find_packages

setuptools.setup(
    name='LoisLFPutils',
    version='0.0.1',
    author='Daniel Pollak',
    author_email='danpollak23@gmail.com',
    description='Utils for our LFP analysis',
    long_description="",
    long_description_content_type='ext/markdown',
    packages=setuptools.find_packages(),
    install_requires=["numpy","pandas", "bokeh>=1.4.0"],
    classifiers=(
        "Programming Language :: Python :: 3",
        "Operating System :: OS Independent",
    ),
)