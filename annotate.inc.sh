#!/bin/bash
set -eu

mydir=`dirname "$0"`
mydir=`readlink -e "$mydir"`

FILL_COLOR="100%,100%,100%"
STROKE_COLOR="0,0,0"
STROKE_ALFA=0.75
FILL_ALFA=0.50
FONT="$mydir/./fonts/ComicRelief.ttf"

annotateFile() {
	local file="$1"
    local newFile="$2"
	local dateExif="$(exiftool -s3 -d "%d.%m.%Y" -EXIF:DateTimeOriginal "$file")"
	local orientation="0$(exiftool -s3 -EXIF:Orientation "$file" | grep -o '[0-9]*')"
    local stroke="rgba($STROKE_COLOR,$STROKE_ALFA)"
    local fill="rgba($FILL_COLOR,$FILL_ALFA)"
	local gravity=SouthEast
	#~ [ $orientation -eq 270 ] && gravity=SouthWest || gravity=SouthEast
	local annotation="$dateExif"

	local height=`identify -format "%[height]" "$file"`
	local width=`identify -format "%[width]" "$file"`
	if [ $width -gt $height ]; then
	    local longSide=$width
	else
	    local longSide=$height
	fi

	local pts=$[(longSide+70/2)/70]   # calculate font size proportional to image size (division with round to nearest)
	local strokeWidth=$[(pts+18/2)/18] # division with round to nearest
	local toSide=$[(longSide+46/2)/46]
	if [ $orientation -eq 0 ]; then
		local toBottom=$[(longSide+54/2)/54]
	else
		local toBottom=$[(longSide+32/2)/32]
	fi

    y=$toBottom
    x=$toSide


    if [ -e "$newFile" ] && [ ! $OVERWRITE_EXISTING = 1 ];then
        printf "${cl}file $newFile exists - skipping\n"
    else
        renderAnnotation "$file" "$newFile" "$annotation"
    fi
}


renderAnnotation() {
    local file="$1"
    local newFile="$2"
    local annotation="$3"

    echo -e "\twidth=$width, height=$height, orientation=$orientation\n\tpts=$pts, stroke_width=$strokeWidth\n\tx=$x, y=$y, longSide=$longSide\n\tstroke=$stroke, fill=$fill"

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



