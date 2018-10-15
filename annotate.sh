#!/bin/bash

set -eu

COLOR1="100%,100%,100%"
COLOR2="0,0,0"

STROKE_ALFA=0.3
FILL_ALFA=0.3

BASE_DIR="/media/9d022e05-f3de-413c-a31d-96076992adb2/photo-video/print-prepare"
TARGET_DIR="$BASE_DIR/annotated"
#SOURCE_DIR="/media/9d022e05-f3de-413c-a31d-96076992adb2/print-photo"
SOURCE_DIR="$BASE_DIR/not-annotated/3"



echo -e "SOURCE_DIR: $SOURCE_DIR\nTARGET_DIR: $TARGET_DIR\n"

[ ! -d "$SOURCE_DIR" ] && (echo "error: SOURCE_DIR doesn't exist"; exit 1)
[ ! -d "$TARGET_DIR" ] && mkdir "$TARGET_DIR"


posX=0


for file in $SOURCE_DIR/*.JPG; do
fileName="`basename "$file"`"
dateExif="$(exiftool -s3 -d "%d.%m.%Y" -EXIF:DateTimeOriginal "$file")"
orientation="0$(exiftool -s3 -EXIF:Orientation "$file" | grep -o '[0-9]*')"
annotation="$dateExif"

height=`identify -format "%[height]" "$file"`
width=`identify -format "%[width]" "$file"`
# identify -format "%[fx:w>h]" "$file"
if [ $width -gt $height ]; then
    longSide=$width
else
    longSide=$height
fi

PTS=$[longSide*16/1000]   # calculate font size proportional to image size
strokeWidth=$[longSide*20/5000]

toLongSide=$[longSide*21/1000]
toShortSide=$[longSide*15/1000]

if [ $orientation -gt 0 ] ; then
    y=$[$toShortSide-$longSide/150]
    x=$toLongSide
else
    x=$toShortSide
    y=$[$toLongSide-$longSide/150]
fi

gravity=SouthEast
#~ [ $orientation -eq 270 ] && gravity=SouthWest || gravity=SouthEast

posY=100
for i in {0..1} ;do
    [ $i = 0 ] && strokeColor=$COLOR2 || strokeColor=$COLOR1
    [ $i = 0 ] && fillColor=$COLOR1 || fillColor=$COLOR2

    stroke="rgba($strokeColor,$STROKE_ALFA)"
    fill="rgba($fillColor,$FILL_ALFA)"

    echo -e "i=$i, stroke=$stroke, fill=$fill, orientation=$orientation,\n longSide=$longSide,\n PTS=$PTS,\n x=$x,\n y=$y,\n width=$width,\n stroke_width=$strokeWidth\n==================\n"

    # x=$[x+2000]
    newFileName="${fileName%.*}_annotated${i}.${fileName##*.}"

    convert "$file" \
        -rotate $orientation \
        -gravity $gravity \
        -font "./fonts/UNIVERSALFRUITCAKE.ttf" \
        -pointsize $[$PTS] \
        -fill none -stroke "$stroke" -strokewidth $strokeWidth \
        -annotate +$x+$y "$annotation" \
        -fill "$fill" -stroke none \
        -annotate +$x+$y "$annotation" \
        -rotate -$orientation \
        "$TARGET_DIR/$newFileName"

        #- | display -resize 750x500 -auto-orient -geometry +$posX+$posY - &

        # -fill "rgba(100%,25%,25%,1)" -stroke "rgba(0,0,0,1)" -strokewidth 3 \
        # -annotate +700+$y "PTS=$PTS, stroke_width=$strokeWidth, stroke=$STROKE_ALFA, fill=$FILL_ALFA" \

    posY=$[posY+50]
done
posX=$[posX+100]
# exit 0
done