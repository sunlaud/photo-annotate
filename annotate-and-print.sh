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
    local newFileName="${fileName%.*}_annotated.${fileName##*.}"
    local newFile="$TARGET_DIR/$newFileName"
    annotateFile "$file" "$newFile"
    aaphoto -a --overwrite "$newFile"

    lp -d EPSON_L805/photo_10x15 -o PageSize=100x148mm "$newFile"
}


[ ! -d "$TARGET_DIR" ] && mkdir "$TARGET_DIR"
echo -e "TARGET_DIR: $TARGET_DIR\n"

forEachFileDoWithDialog enchanceAnnotateAndPrint $@
