#!/usr/bin/env bash

rsync --archive --verbose --del --partial --progress --include='*.txt' --include='*/' --exclude='*' aleph.gutenberg.org::gutenberg ./data

mkdir ./temp

find ./data -type f -iname "*.txt" -exec mv '{}' ./temp ';'



