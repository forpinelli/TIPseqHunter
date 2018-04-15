#!/bin/bash

BASE=$(cd $(dirname $(readlink -f "${BASH_SOURCE[0]}")) && pwd)

TIPSEQ_HUNTER_IMG="tipseq_hunter"
TIPSEQ_HUNTER_DATA="TIPseqHunter_data.tar.gz"
TIPSEQ_HUNTER_DATA_PART="TIPseqHunter_data.tar.gz.part"

PARTS=$(ls "$BASE" | grep $TIPSEQ_HUNTER_DATA_PART | sort)
cat $PARTS > "$TIPSEQ_HUNTER_DATA"
docker build -t "$TIPSEQ_HUNTER_IMG" "$BASE"
rm -f "$TIPSEQ_HUNTER_DATA"
