import sys, os

sys.path.append(os.path.abspath('sphinxext'))


language = 'zh_CN'
author = 'DingJing'
project = 'Tiny Kernel'
html_theme = 'alabaster'
copyright = 'Copyright 2023 DingJing'


extensions = [
        'myst_parser',
]

exclude_patterns = []
templates_path = ['_templates']
html_static_path = ['_static']

html_theme_options = {

}


source_suffix = {
    '.rst': 'restructuredtext',
    '.txt': 'restructuredtext',
    '.md': 'markdown',
}
