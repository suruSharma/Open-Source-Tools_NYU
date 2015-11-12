#!/usr/bin/env bash

# Script name: calendar

chmod 711 /home/$USER

chmod -R 700 /home/$USER/bin

################################ DEFAULT VALUES ###################################################

VALID_RETURN_VALUE=0

MIN_ARGS=1
MAX_ARGS=4

CREATE_MANDATORY_ARGS=2
CREATE_TITLE_ARG_INDEX=4

DELETE_MAX_ARGS=2

SHOW_MIN_ARGS=1
SHOW_MAX_ARGS=3
SHOW_ALL=2

LINK_MAX_ARGS=3

EXPORT_MAX_ARGS=4

################################ ERROR CODES ###################################################

ERROR_NONE=0
ERROR=1
ERROR_2=2
ERROR_LESS_ARGS=2
ERROR_INVALID_OPTION=3
ERROR_EXTRA_ARGS=4
ERROR_INCORRECT_NUMBER_OF_ARGUMENTS=5
ERROR_FILE_EXISTS=6
ERROR_INVALID_LENGTH=7
ERROR_TITLE_MISSING=8
ERROR_END_LT_START=9

################################ INITIAL VALIDATION ###################################################
if [ $# -lt "$MIN_ARGS" ]
then
    printf "No option supplied.\n" 1>&2
    printf "Usage: `basename $0` option [args]\n" 1>&2
    exit "$ERROR_LESS_ARGS"
fi

if ! [[ "$1" == "create" || "$1" == "delete" || "$1" == "show" || "$1" == "link" || "$1" == "export" ]]
then
    printf "Invalid option supplied.\n" 1>&2
    printf "The available options are create, delete, show, link and export.\n" 1>&2
    printf "Usage: `basename $0` option [args]\n" 1>&2
    exit "$ERROR_INVALID_OPTION"
fi


if [ $# -gt "$MAX_ARGS" ]
then
    printf "Too many arguments supplied\n" 1>&2
    printf "Usage: `basename $0` option [args]\n" 1>&2
    exit "$ERROR_EXTRA_ARGS"
fi

#"$userId" "$f" "$title" "$description" "$endTime"
createCalendar(){
	printf "BEGIN:VCALENDAR\n"
	printf "VERSION:2.0\n"
	printf "PRODID:-//Open Source Tools//Calendar for $1//EN\n"
	printf "BEGIN:VEVENT\n"
	printf "UID:$1_$2\n"
	printf "DTSTAMP:$2\n"
	printf "ORGANIZER;CN=$1:MAILTO:$1@cims.nyu.edu\n"
	printf "DTSTART:$2\n"
	printf "DTEND:$5\n"
	printf "SUMMARY:$3\n"
	printf "DESCRIPTION:$4\n"
	printf "END:VEVENT\n"
	printf "END:VCALENDAR\n"
}

################################ CREATE ###################################################

if [ "$1" == "create" ]
then
	#Check if the number of arguments as per expectation
	if [ $# -le "$CREATE_MANDATORY_ARGS" ]
    then
        printf "Invalid number of arguments supplied to create\n" 1>&2
        printf "Usage: `basename $0` create time length [title]\n" 1>&2
		exit "$ERROR_INCORRECT_NUMBER_OF_ARGUMENTS"
    fi
	
	startTime="$2"
	fileName=`date --date="$startTime" +%s 2>/dev/null` 
	returnVal=$?
	if ! [ "$returnVal" == "$VALID_RETURN_VALUE" ]
	then
		printf "Syntax of time is incorrect.\nEvent not created." 1>&2
		exit "$ERROR"
	fi
	
	re='^[0-9]+$'	
	length="$3"
	if ! [[ "$length" =~ $re ]]
	then
		printf "Either length is missing or length should be a postive number indicating the number of minutes\n" 1>&2
		printf "Usage: `basename $0` create time length [title]\n" 1>&2
		exit "$ERROR_INVALID_LENGTH"
	fi
	
	description=`sed '/^$/q'`
	if [ "$#" -eq "$CREATE_TITLE_ARG_INDEX" ]
	then 
		title="$4"
	else
		title="$description"
		unset $description
	fi

	if ! [ -n "$title" ]
	then
		printf "Title should be provided\n" 1>&2
		printf "Usage: `basename $0` create time length [title]\n" 1>&2
		exit "$ERROR_TITLE_MISSING"
	fi
	
	#create folder if it is not present
	mkdir -p ~/.calendar
	chmod -R 755 ~/.calendar
	
	touch ~/.calendar/"$fileName"
	chmod 755 ~/.calendar/"$fileName"
	printf "$length\n$title" > ~/.calendar/"$fileName"
	
	if [ -z "$description" ]
	then
		printf "\n" >> ~/.calendar/"$fileName"
		printf "$description" >> ~/.calendar/"$fileName"
	fi
	printf "$fileName\n"
fi

################################ DELETE ###################################################

if [ "$1" == "delete" ]
then
	if ! [ $# -eq "$DELETE_MAX_ARGS" ]
    then
        printf "Invalid number of arguments supplied to delete\n" 1>&2
        printf "Usage: `basename $0` delete event_id\n" 1>&2
	exit "$ERROR_INCORRECT_NUMBER_OF_ARGUMENTS"
    fi
	
	eventId="$2"
	
	if ! [ -d ~/.calendar ]
	then
		printf "Calendar folder does not exist.\n" 1>&2
		exit "$ERROR_2"
	fi
	
	if ! [ -f ~/.calendar/"$eventId" ]
    then
        printf "Event does not exist.\n" 1>&2
		exit "$ERROR"
	fi
	
	rm ~/.calendar/"$eventId"
	exit "$ERROR_NONE"
	
fi

################################ SHOW ###################################################

if [ "$1" == "show" ]
then
	if [[ $# -eq "$SHOW_MIN_ARGS" || $# -gt "$SHOW_MAX_ARGS" ]]
    then
        printf "Invalid number of arguments supplied to show\n" 1>&2
        printf "Usage: `basename $0` show event_id [title|description|time]\n" 1>&2
	exit "ERROR_INCORRECT_NUMBER_OF_ARGUMENTS"
    fi

	eventName="$2"
	
	if ! [ -d ~/.calendar ]
	then
		printf "Calendar folder does not exist.\n" 1>&2
		exit "$ERROR_2"
	fi
	
	if ! [ -f ~/.calendar/"$eventName" ]
    then
        printf "Event does not exist\n" 1>&2
		exit "$ERROR"
	fi

	title=`cat ~/.calendar/"$eventName" | head -2 | tail -1`
	description=`cat ~/.calendar/"$eventName" | sed -n '3,$p'`
	startTime=`date -d @"$eventName"`
	len=`cat ~/.calendar/"$eventName" | head -1`
	lengthSeconds=$(expr $len \* 60)
	endTime=$(expr $eventName + $lengthSeconds)
	endDate=`date -d @"$endTime"`
	
#Print whole file	
	if [[ $# -eq "$SHOW_ALL" ]]
	then
		printf "$startTime to $endDate\n" 1>&2
		printf "$title\n$description\n" 1>&2
		exit "$ERROR_NONE"
	fi
		
	if [[ $# -eq "$SHOW_MAX_ARGS" ]]
	then
		info="$3"
		if ! [[ "$info" == "title" || "$info" == "description" || "$info" == "time" ]]
		then
			printf "Invalid argument supplied to show\n" 1>&2
			printf "Usage: `basename $0` show event_id [title|description|time]\n" 1>&2
			exit "ERROR_INVALID_OPTION"
		fi
		
		if [[ "$info" == "time" ]]
		then
			printf "$startTime to $endDate\n" 1>&2
			exit "$ERROR_NONE"
		fi
		
		if [[ "$info" == "title" ]]
		then
			printf "$title\n" 1>&2
			exit "$ERROR_NONE"
		fi
		
		if [[ "$info" == "description" ]]
		then
			printf "$description\n" 1>&2
			exit "$ERROR_NONE"
		fi
	fi
fi

################################ LINK ###################################################

if [ "$1" == "link" ]
then
	if ! [ $# -eq "$LINK_MAX_ARGS" ]
    then
        printf "Invalid number of arguments supplied to link\n" 1>&2
        printf "Usage: `basename $0` link user_id event_id\n" 1>&2
	exit "$ERROR_INCORRECT_NUMBER_OF_ARGUMENTS"
    fi
	
	mkdir -p ~/.calendar
	chmod -R 755 ~/.calendar
	
	userId="$2"
	eventId="$3"
	
	if [ -f ~/.calendar/"$eventId" ]
    then
        printf "Link already exists.\n" 1>&2
		exit "$ERROR_FILE_EXISTS"
	fi
	
	filePath=/home/"$userId"/.calendar/"$eventId"
	if ! [ -f "$filePath" ]
    then
        printf "Event not found in user's directory\n" 1>&2
		exit "$ERROR"
	fi
	
	destinationPath=~/.calendar/"$eventId"
	ln -s "$filePath" "$destinationPath" 2>/dev/null
	returnVal=$?
	if ! [ "$returnVal" == 0 ]
	then
		printf "Error creating link. Link not created.\n" 1>&2
		exit "$ERROR"
	fi
fi

################################ EXPORT ###################################################

if [ "$1" == "export" ]
then
	if ! [ $# -eq "$EXPORT_MAX_ARGS" ]
    then
        printf "Invalid number of arguments supplied to export\n" 1>&2
        printf "Usage: `basename $0` export user_id begin_time end_time\n" 1>&2
		exit "$ERROR_INCORRECT_NUMBER_OF_ARGUMENTS"
    fi
	
	userId="$2"
	
	beginTime="$3"
	start=`date --date="$beginTime" +%s 2>/dev/null`
	returnVal=$?
	if ! [ "$returnVal" == "$VALID_RETURN_VALUE" ]
	then
		printf "Syntax of begin time is incorrect.\n" 1>&2
		exit "$ERROR"
	fi
	
	endTime="$4"
	end=`date --date="$endTime" +%s 2>/dev/null`
	returnVal=$?
	if ! [ "$returnVal" == "$VALID_RETURN_VALUE" ]
	then
		printf "Syntax of end time is incorrect.\n" 1>&2
		exit "$ERROR"
	fi
	
	if [ "$end" -lt "$start" ]
	then
		printf "The end time cannot be less than the start time.\n" 1>&2
		exit "$ERROR_END_LT_START"
	fi
	
	if ! [ -d /home/"$userId"/.calendar/ ]
	then
		printf "User's calendar is not present or does not have appropriate permissions. \n" 1>&2
		exit "$ERROR_2"
	fi
	
	userCalendar=/home/"$userId"/.calendar/*
	FILES=$(find $userCalendar -type f | cut -d'/' -f5 2>/dev/null)
	for f in $FILES
	do
		title=`cat ~/.calendar/"$f" | head -2 | tail -1`
		description=`cat ~/.calendar/"$f" | sed -n '3,$p'`
		len=`cat ~/.calendar/"$f" | head -1`
		lengthSeconds=`expr $len \* 60`
		endTime=`expr $f + $lengthSeconds`
		if [ "$f" -ge "$start" ] && [ "$f" -le "$end" ]
		then
			createCalendar "$userId" "$f" "$title" "$description" "$endTime"
		fi
	done
	
	FILES=$(find $userCalendar -type l | cut -d'/' -f5 2>/dev/null)
	for f in $FILES
	do
		if ! [ -f ~/.calendar/"$f" ]
		then 
			title=`cat ~/.calendar/"$f" | head -2 | tail -1`
			description=`cat ~/.calendar/"$f" | sed -n '3,$p'`
			len=`cat ~/.calendar/"$f" | head -1`
			lengthSeconds=`expr $len \* 60`
			endTime=`expr $f + $lengthSeconds`
			if [ "$f" -ge "$start" ] && [ "$f" -le "$end" ]
			then
				createCalendar "$userId" "$f" "$title" "$description" "$endTime"
			fi
		fi
	done
	
fi