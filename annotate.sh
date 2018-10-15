#!/bin/bash
set -u

COLOR1="100%,100%,100%"
COLOR2="0,0,0"

STROKE_ALFA=0.25
FILL_ALFA=0.25
FONT="../fonts/UNIVERSALFRUITCAKE.ttf"
# FONT="../fonts/with_cyrrilic/ComicRelief.ttf"
# FONT="../fonts/with_cyrrilic/FHABGBSTNC.ttf"
# FONT="../fonts/with_cyrrilic/MewTooHandBdIta_.otf"
# FONT="../fonts/with_cyrrilic/JustBreatheBd.otf"
# FONT="../fonts/with_cyrrilic/JustBreathe.otf"
# FONT="../fonts/with_cyrrilic/Gecko_PersonalUseOnly.ttf"
# FONT="../fonts/with_cyrrilic/beer money.ttf"


BASE_DIR="/media/9d022e05-f3de-413c-a31d-96076992adb2/photo-video/print-prepare"
TARGET_DIR="/media/9d022e05-f3de-413c-a31d-96076992adb2/print-photo-annotated-3"
SOURCE_DIR="/media/9d022e05-f3de-413c-a31d-96076992adb2/print-photo"
OVERWRITE_EXISTING=1

source ../utils/utils.inc.sh


annotateFile() {
	file="$1"
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

	PTS=$[longSide*18/1000]   # calculate font size proportional to image size
	# strokeWidth=$[longSide*18/6000]
	strokeWidth=$[PTS*10/60]

	toLongSide=$[longSide*15/1000]
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
	for j in {0..1} ;do
	    [ $j = 0 ] && strokeColor=$COLOR2 || strokeColor=$COLOR1
	    [ $j = 1 ] && fillColor=$COLOR1 || fillColor=$COLOR2

	    stroke="rgba($strokeColor,$STROKE_ALFA)"
	    fill="rgba($fillColor,$FILL_ALFA)"

	    # echo -e "i=$j, stroke=$stroke, fill=$fill, orientation=$orientation,\n longSide=$longSide,\n PTS=$PTS,\n x=$x,\n y=$y,\n width=$width,\n stroke_width=$strokeWidth\n==================\n"

	    # x=$[x+2000]
	    newFileName="${fileName%.*}_annotated${j}.${fileName##*.}"

	    if [ -e "$TARGET_DIR/$newFileName" ] && [ ! $OVERWRITE_EXISTING = 1 ];then
	    	printf "${cl}file $TARGET_DIR/$newFileName exists - skipping\n"
	    else
		    convert "$file" \
		        -rotate $orientation \
		        -gravity $gravity \
		        -font "$FONT" \
		        -pointsize $[$PTS] \
		        -fill "$fill" -stroke "$stroke" -strokewidth $strokeWidth \
		        -annotate +$x+$y "$annotation" \
		        -rotate -$orientation \
		        "$TARGET_DIR/$newFileName"

		        # -fill "$fill" -stroke none \
		        # -annotate +$x+$y "$annotation" \

		        #- | display -resize 750x500 -auto-orient -geometry +$posX+$posY - &

		        # -fill "rgba(100%,25%,25%,1)" -stroke "rgba(0,0,0,1)" -strokewidth 3 \
		        # -annotate +700+$y "PTS=$PTS, stroke_width=$strokeWidth, stroke=$STROKE_ALFA, fill=$FILL_ALFA" \

	    fi
	    posY=$[posY+50]
	done
}



echo -e "SOURCE_DIR: $SOURCE_DIR\nTARGET_DIR: $TARGET_DIR\n"

[ ! -d "$SOURCE_DIR" ] && (echo "error: SOURCE_DIR doesn't exist"; exit 1)
[ ! -d "$TARGET_DIR" ] && mkdir "$TARGET_DIR"

forEachFileIn "find '$SOURCE_DIR' -iname '*.jpg'" annotateFile





