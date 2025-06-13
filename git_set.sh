#!/bin/bash

echo "path of the repo"
read path
echo "url"
read url

cd $path

git init
git add .
git commit -m "Initial commit"
git remote add origin $url
git push -u origin main
