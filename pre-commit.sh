#!/bin/sh

# pre-process README.md to create toc
md-toc README.md.pre > README.md
git add README.md
