#!/bin/sh

# BASIC CONFIGURATION ========================================================================
# HOTSPOT'S LOGIN WEBPAGE URL
HOTSPOT_URL="http://192.168.108.1/"
# INPUT YOUR WLAN MAC ADDRESS INSTEAD OF X-s!
USERNAME="T-XX%3AXX%3AXX%3AXX%3AXX%3AXX"
# ============================================================================================

# ADVANCED CONFIGURATION =====================================================================
# PATH FOR LOG FILE STORAGE
LOG_FILE="/tmp/FreeWiFi_LOG.log"
# ENABLE LOG FILE 1/0 = on/off
LOG=1
# LEAVE EVERYTHING ELSE AS IS!!
MAIN_SLEEP=60
BOOT_SLEEP=30
LOGOUT_WHEN_LEFT_S=$(($MAIN_SLEEP+5))
AQUIRE_TIME_RETRY=10
# ============================================================================================

# STATIC VAR ALLOC ===========================================================================
LOGIN_URL="$HOTSPOT_URL/login?username=$USERNAME"
LOGOUT="$HOTSPOT_URL/logout"
LOGIN="$HOTSPOT_URL/login"
STATUS_URL="$HOTSPOT_URL/status"
# ============================================================================================




#before first login sleep for 60s
if [ $LOG -eq 1]
then
	echo "$(date), BOOT OK. Waiting $BOOT_SLEEP seconds." >> $LOG_FILE
fi


sleep $BOOT_SLEEP

LOGIN_NR=1
RUN=1

# UNCOMENT FOR DEBUGING
#set -x

while [ $RUN -eq 1 ]
do
#LOGIN
	CONN_STATUS=0
	R=1
	
	if [ $LOG -eq 1]
	then
		echo -n "$(date), Connecting ... " >> $LOG_FILE
	fi
	
	
	while [ $CONN_STATUS -eq 0 ]
	do
		if [ $LOG -eq 1]
		then
			echo -n "$R " >> $LOG_FILE
		fi
		
		CONN_STATUS=$(wget -T 2 -q -O - "$@" "$LOGIN_URL" | grep -c "You are logged in")
		if [ $CONN_STATUS -eq 0 ]
		then
			sleep 1
		fi
		R=$((R+1))
	done
	if [ $LOG -eq 1]
	then
		echo "OK: $(date +%H:%M:%S)" >> $LOG_FILE
	fi
#AQUIRE TIME LEFT
	
	#WAIT FOR NTP SERVER
	TIME_NOW=$(date +%s)
	if [ $TIME_NOW -lt 300 ]
	then
		if [ $LOG -eq 1]
		then
 			echo -n "$(date), NTP Time ... " >> $LOG_FILE
 		fi
		
		NTP=1
 		while true                                 
		do
			if [ $LOG -eq 1]
			then
				echo -n "$NTP " >> $LOG_FILE
			fi
			
			SEC=$(date +%s)                                                         
			if [ $SEC -gt 300 ]
			then
				if [ $LOG -eq 1]
				then
					echo "OK: $(date +%H:%M:%S)" >> $LOG_FILE
				fi
				
				break
			fi
			NTP=$((NTP+1))
			sleep 1
		done
	fi
	WHOLE_START=$(date +%s)
	
	if [ $LOG -eq 1]
	then
		echo -n "$(date), Login time ... " >> $LOG_FILE
	fi
	
	
	I=1
	T=0
	TIME_OK=0
	while [ $TIME_OK -eq 0 ]
	do
		if [ $LOG -eq 1]
		then
			echo -n "$I " >> $LOG_FILE
		fi
		
		STATUS_PAGE=$(wget -T 2 -q -O - "$@" "$STATUS_URL")
		STA=$?


		if [ "$STATUS_PAGE" = "" ]
		then
			if [ $LOG -eq 1]
			then
				echo -n  "PAGE_ERR " >> $LOG_FILE
			fi
			
			sleep 1
			I=$((I+1))
			continue
		fi

		MINUTES=$(echo $STATUS_PAGE | grep -o '/ [0-9]*m' | tr -d 'm' | tr -d ' ' | tr -d '/')

		if [ "$MINUTES" = "" ]
		then
			if [ $LOG -eq 1]
			then
				echo -n "TIME_ERR " >> $LOG_FILE
			fi
			
			sleep 1
			I=$((I+1))
			continue
		fi
		
		T=$MINUTES
	
		if [ $T -gt 0 ]
		then
			TIME_OK=1
			
			if [ $LOG -eq 1]
			then
				echo "OK: $MINUTES minutes left." >> $LOG_FILE
			fi
			
			I=$((I+1))
			break
		fi
		if [ $I -gt $AQUIRE_TIME_RETRY ]
		then
			if [ $LOG -eq 1]
			then
				echo "FAIL. Restarting script ..." >> $LOG_FILE
			fi
			TIME_OK=1
			sleep 1
			continue 1
		fi
		I=$((I+1))
	done
	if [ $LOG -eq 1]
	then
        	echo "1...5....10...15...20...25...30...35...40...45...50...55...60" >> $LOG_FILE
	fi
#WAIT PERIOD
	#CALC TIME	
	S=$(($T*60))
	NOW=$(date +%s)
	ELPASSED=$(($NOW-$WHOLE_START))
	LEFT=$(($S-$ELPASSED))
	while [ $LEFT -gt $LOGOUT_WHEN_LEFT_S ]
	do

		#  check for internet connection - ping google DNS
		P=$(ping -c 1 -w 2 8.8.4.4 &> /dev/null)
		PING_OK=$?
		# SET PING ms TO 0 ON FAIL
		if [ $PING_OK -eq 1 ]
		then
			
			PING=0
			if [ $LOG -eq 1]
			then
				echo -n "-" >> $LOG_FILE
			fi
		else
			PING=1
			if [ $LOG -eq 1]
			then
				echo -n "+" >> $LOG_FILE
			fi
		fi
		sleep $MAIN_SLEEP
		#CALC TIME
		NOW=$(date +%s)
		ELPASSED=$(($NOW-$WHOLE_START))
		LEFT=$(($S-$ELPASSED))
	done
	echo "|" >> $LOG_FILE
#LOGOUT
	if [ $LOG -eq 1]
	then
		echo "$(date), Connection finished ..." >> $LOG_FILE
	fi
	
	OUT=$(wget -T 2 -q -O - "$@"  $LOGOUT)
	LOGIN_NR=$(($LOGIN_NR+1))
done