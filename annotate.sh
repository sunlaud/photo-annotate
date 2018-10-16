#!/bin/bash
set -u

FILL_COLOR="100%,100%,100%"
STROKE_COLOR="0,0,0"
STROKE_ALFA=0.5
FILL_ALFA=0.5
FONT='./fonts/ComicRelief.ttf'


TARGET_DIR="/tmp/preprint/annotated"
SOURCE_DIR="/tmp/preprint/src"
OVERWRITE_EXISTING=1

source ../utils/utils.inc.sh


annotateFile() {
	local file="$1"
	local fileName="`basename "$file"`"
    local newFileName="${fileName%.*}_annotated.${fileName##*.}"
    local newFile="$TARGET_DIR/$newFileName"
	local dateExif="$(exiftool -s3 -d "%d.%m.%Y" -EXIF:DateTimeOriginal "$file")"
	local orientation="0$(exiftool -s3 -EXIF:Orientation "$file" | grep -o '[0-9]*')"
    local stroke="rgba($STROKE_COLOR,$STROKE_ALFA)"
    local fill="rgba($FILL_COLOR,$FILL_ALFA)"
	local gravity=SouthEast
	#~ [ $orientation -eq 270 ] && gravity=SouthWest || gravity=SouthEast
	local annotation="$dateExif"
	#annotation="Львів, $dateExif"

	local height=`identify -format "%[height]" "$file"`
	local width=`identify -format "%[width]" "$file"`
	if [ $width -gt $height ]; then
	    local longSide=$width
	else
	    local longSide=$height
	fi

	local pts=$[(longSide+64/2)/64]   # calculate font size proportional to image size (division with round to nearest)
	local strokeWidth=$[(pts+8/2)/8] # division with round to nearest
	local toSide=$[(longSide+70/2)/70]
	local toBottom=$[(longSide+40/2)/40]

    y=$toBottom
    x=$toSide


    if [ -e "$newFile" ] && [ ! $OVERWRITE_EXISTING = 1 ];then
        printf "${cl}file $newFile exists - skipping\n"
    else
        renderAnnotation "$file" "$newFile" "$annotation"
#         test various combinations of annotation configs
#         for var in '../fonts/UNIVERSALFRUITCAKE.ttf' '../fonts/with_cyrrilic/ComicRelief.ttf' '../fonts/with_cyrrilic/FHABGBSTNC.ttf' '../fonts/with_cyrrilic/MewTooHandBdIta.otf' '../fonts/with_cyrrilic/JustBreatheBd.otf' '../fonts/with_cyrrilic/JustBreathe.otf' '../fonts/with_cyrrilic/Gecko_PersonalUseOnly.ttf' '../fonts/with_cyrrilic/beer money.ttf'; do
#             FONT=$var
#             y=$[$y+45]
#             renderAnnotation "$newFile" "$newFile" "$var $annotation"
#         done
    fi
}


renderAnnotation() {
    local file="$1"
    local newFile="$2"
    local annotation="$3"

    echo -e "\ni=$i, stroke=$stroke, fill=$fill, orientation=$orientation,\n longSide=$longSide,\n pts=$pts,\n x=$x, y=$y\n width=$width, height=$height\n stroke_width=$strokeWidth\n==================\n"

    convert "$file" \
        -rotate $orientation \
        -gravity $gravity \
        -font "$FONT" \
        -pointsize $[$pts] \
        -fill none -stroke "$stroke" -strokewidth $strokeWidth \
        -annotate +$x+$y "$annotation" \
        -fill "$fill" -stroke none \
        -annotate +$x+$y "$annotation" \
        -rotate -$orientation \
        "$newFile"
#        - | display -resize 750x500 -auto-orient -geometry +$x+$y - &
}


echo -e "SOURCE_DIR: $SOURCE_DIR\nTARGET_DIR: $TARGET_DIR\n"

[ ! -d "$SOURCE_DIR" ] && (echo "error: SOURCE_DIR doesn't exist"; exit 1)
[ ! -d "$TARGET_DIR" ] && mkdir "$TARGET_DIR"

forEachFileIn "find '$SOURCE_DIR' -iname '*.jpg'" annotateFile





