#!/bin/bash

#Usage
#./generate-slides.sh "#color" slideGroupId input.svg output.pdf
# Used apps Xcfb, inkscape, stapler

if [ -z "$1" ] ; then 
  if [ -z "$2" ] ; then 
    if [ -z "$3" ] ; then 
      echo 'Usage: ./generate-slides.sh "#color" slideGroupId input.svg output.pdf'
      echo 'Used apps: Xcfb, inkscape, stapler, grep (make sure to have them installed)'

    fi
  fi
else
  COLOR_INPUT=$1
  GROUP=$2
  INPUT=$3
  OUTPUT=$4
  echo Export all slides with background color $1 in file $2
  Xvfb :100 &
  OLDDISPLAY=$DISPLAY
  DISPLAY=":100"
  PID=$!
  COLOR="fill:${COLOR_INPUT}"

  TMP="/tmp/slide_exporter_$RANDOM"
  mkdir $TMP

  `inkscape -z --export-id=${GROUP} --export-plain-svg=$TMP/group.svg --export-id-only -f $INPUT`

  objList=`inkscape --file $TMP/group.svg --query-all | grep rect | sort -n -t "," -k 3,3 | cut -d "," -f 1`

  i=0
  for ID in $objList; do
    `inkscape -z --export-id=${ID} --export-plain-svg=$TMP/${ID}.svg --export-id-only -f $INPUT`

    testString=`grep "$COLOR" $TMP/${ID}.svg`

    if [ ! -z "$testString" ] ; then 
      echo -n ..
      inkscape -g --select=$ID --verb FitCanvasToSelection --verb=FileSave --verb=FileQuit $INPUT
      echo -n ..
      inkscape --file $INPUT --export-pdf="$TMP/${i}.pdf" 
      i=$(($i+1))
    fi

  done
  kill $PID

  DISPLAY=$OLDDISPLAY

  echo ""
  stapler sel `ls $TMP/*.pdf | sort -n -t "/" -k 4,4` $OUTPUT
  echo "Output file is saved as $OUTPUT"

fi

