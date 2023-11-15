#!/usr/bin/env bash

convert logo: input.jpg &&
    magick input.jpg \
        -font FreeMono \
        -fill blue \
        -gravity southeast \
        -annotate +10+10 \
        'Copyright 2023' \
        -flatten output.jpg
