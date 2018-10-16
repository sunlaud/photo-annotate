#!/bin/bash
set -eu

TARGET_DIR="/tmp/preprint/annotated"
SOURCE_DIR="/tmp/preprint/src"
OVERWRITE_EXISTING=1

source ../utils/utils.inc.sh
source ./annotate.inc.sh

annotate(){
    local file="$1"
    local fileName="`basename "$file"`"
    local newFileName="${fileName%.*}_annotated.${fileName##*.}"
    local newFile="$TARGET_DIR/$newFileName"
    annotateFile "$file" "$newFile"
}


echo -e "SOURCE_DIR: $SOURCE_DIR\nTARGET_DIR: $TARGET_DIR\n"

[ ! -d "$SOURCE_DIR" ] && (echo "error: SOURCE_DIR doesn't exist"; exit 1)
[ ! -d "$TARGET_DIR" ] && mkdir "$TARGET_DIR"

forEachFileIn "find '$SOURCE_DIR' -iname '*.jpg'" annotate





