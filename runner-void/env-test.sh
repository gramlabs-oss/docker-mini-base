#!/usr/bin/env ash

convert logo: input.jpg &&
    magick input.jpg \
        -font 'Lato-Regular' \
        -fill blue \
        -gravity southeast \
        -annotate +10+10 \
        'Copyright 2023' \
        -flatten output.jpg
