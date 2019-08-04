#!/bin/bash
#
# Places a grayscale image into an alpha channel of another image.

function get_image_dimensions()
{
    magick identify -format '%[w]x%[h]' "$1" || exit 1
}

if [[ $# != 3 ]]; then
    echo "Usage: $0 <primary-image> <secondary-image> <out-file>" > /dev/stderr
    echo "Places grayscale image into an alpha channel of another image." > /dev/stderr
    echo "" > /dev/stderr
    echo "Note: file extension of the output image parameter determines the image format" > /dev/stderr
    echo "of the combined image. Make sure that you use an image format that supports " > /dev/stderr
    echo "alpha channel (e.g. png)" > /dev/stderr
    exit 1
fi

if ! which magick &> /dev/null; then
    echo "Unable to locate ImageMagick executable. Is it installed?" > /dev/stderr
    exit 1
fi

primary_image=$1
secondary_image=$2
out_file=$3

primary_dimensions=$(get_image_dimensions "$primary_image")
secondary_dimensions=$(get_image_dimensions "$secondary_image")

if [[ "$primary_dimensions" != "$secondary_dimensions" ]]; then
    echo "Image dimensions do not match ($primary_dimensions vs. $secondary_dimensions)" > /dev/stderr
    exit 1
fi

magick convert -depth 16 \
    "$primary_image" \( -colorspace Gray "$secondary_image" \) \
    -alpha off -compose copy-opacity -composite -depth 8 "$out_file"