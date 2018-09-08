#!/bin/bash


# Check if variable already defined. If so, proably running from Makefile, so skip assignment
if test -z "$NAME"; then
  CONF_FILE=docker.conf
  source $CONF_FILE
fi

# Parse variables
EXIT_STATUS=1
NAME=$(test -n $NAME && echo "$NAME")
RNAME=$(test -n $RNAME && echo "--name $RNAME")
SHARE=$(test -n $SHARE && echo "-v $SHARE")
PORT=$(test -n $PORT && echo "-p $PORT")

# Check if getopt available in environment
getopt --test > /dev/null
if [[ $? -ne 4 ]]; then
    echo "'getopt --test' failed in this environment. Please install."
    exit 1
fi

OPTIONS=dbnpt:v
LONGOPTIONS=debug,bash,noport,port,temp

# -temporarily store output to be able to check for errors
# -e.g. use “--options” parameter by name to activate quoting/enhanced mode
# -pass arguments only via   -- "$@"   to separate them correctly
PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTIONS --name "$0" -- "$@")
if [[ $? -ne 0 ]]; then
    # e.g. $? == 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi

# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"

# now enjoy the options in order and nicely split until we see --
while true; do
	case "$1" in
		-p|--port)
			PORT="$2"
			shift
			;;

		-n|--noport)
			NOPORT=y
			shift
			;;

		-t|--temp)
			TEMP="--rm"
			shift
			;;

		-d|--debug)
			DEBUG=y
			shift
			;;

		-b|--bash)
			DEBUG=y
			CMD=bash
			RNAME=""
			shift
			;;

		--)
			shift
			break
			;;

		*)
			echo "Command error"
			exit 3
			;;
	esac
done

if test "$NOPORT" == "y"; then
	PORT=
fi

if test "$DEBUG" == "y"; then
	OPTS="-it"
else
  OPTS="-id"
fi

ALL_OPTIONS=$(echo "$TEMP $SHARE $HOST $OPTS $PORT $RNAME $NAME $CMD" | awk '$1=$1')
echo "Running: docker run $ALL_OPTIONS"
docker run $ALL_OPTIONS && EXIT_STATUS=0
exit $EXIT_STATUS
