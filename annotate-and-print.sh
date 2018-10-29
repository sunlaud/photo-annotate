#!/bin/bash
set -eu
LOG_FILE="/tmp/annotate-and-print.log"
exec 2> $LOG_FILE > $LOG_FILE
echo "" > $LOG_FILE

TARGET_DIR="/tmp/preprint/annotated"
OVERWRITE_EXISTING=1

mydir=`dirname "$0"`
mydir=`readlink -e "$mydir"`

#hack for launching inside XnView
export TERM=xtermm
export LD_LIBRARY_PATH="/usr/lib:$LD_LIBRARY_PATH"


source "$mydir/../utils/utils.inc.sh"
source "$mydir/./annotate.inc.sh"


enchanceAnnotateAndPrint(){
    local file="$1"
    local fileName="`basename "$file"`"
    local enchancedFileName="${fileName%.*}_new.${fileName##*.}"    #aaphoto appends "_new" to filename
    local annotatedFileName="${fileName%.*}_annotated.${fileName##*.}"
    local annotatedFile="$TARGET_DIR/$annotatedFileName"
    local enchancedFile="$TARGET_DIR/$enchancedFileName"

    [ -e "$enchancedFile" ] && rm "$enchancedFile"
    aaphoto -a -o "$TARGET_DIR" "$file"
    annotateFile "$enchancedFile" "$annotatedFile"
    lp -d EPSON_L805/photo_10x15 -o PageSize=100x148mm "$annotatedFile"
}


[ ! -d "$TARGET_DIR" ] && mkdir "$TARGET_DIR"
echo -e "TARGET_DIR: $TARGET_DIR\n"

forEachFileDoWithDialog enchanceAnnotateAndPrint $@
