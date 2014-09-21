#! /bin/bash

jekyll build
git checkout gh-pages
rm -Rf !(_site|deploy.sh)
mv _site/* .
git commit -a
# git push origin HEAD
# git checkout master
