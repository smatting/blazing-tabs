#!/usr/bin/env bash

version=$(cat ./src/manifest.json | jq -r '.version')
archive="$(pwd)/dist/blazing_tabs-$version.zip"
mkdir -p dist
rm -f "$archive"
cd src
7z a "$archive" \
    service_worker.js \
    callbacks.js \
    index.html \
    index.js \
    logo128.png \
    logo16.png \
    logo48.png \
    logo.svg \
    manifest.json \
    setup.js \
    styles.css
