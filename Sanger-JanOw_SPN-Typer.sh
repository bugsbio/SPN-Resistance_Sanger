#!/usr/bin/env bash

temp_path=$(dirname $0)

read -a PARAM <<< $(/bin/sed -n ${LSB_JOBINDEX}p $1/job-control.txt)

typer.sh ${PARAM[0]} ${PARAM[1]} ${PARAM[2]} ${PARAM[3]} ${PARAM[4]}