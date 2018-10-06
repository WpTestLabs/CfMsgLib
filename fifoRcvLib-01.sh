#!/bin/sh
#	echo "fifoRcvLib.sh";

echo '#### /srv/log/wkFlo/hstWkFloRcvRAW.txt ####'  > /srv/log/wkFlo/hstWkFloRcvRAW.txt

exec {logFD}<>"/srv/log/wkFlo/hstWkFloRcvRAW.txt";

log () { echo "`date +%Y/%m/%d-%T` - $@" >&$logFD; }

log "Starting log for: fifoRcvLib.sh"

die () { log "$@"; exit; }
doMsg () { log "doMsg STUB >>$1"; }

onRcvLpInit () { log "#Info - onRcvLpInit is NOOP"; }

fifoRcvLp () {  onRcvLpInit
	local timeOut=false  p='~~~' line='__'  ;
	while [ -p "$myFifoPFN" ]; do
#		@@@@          vvvvv  when inactive, progress timeout to longer ???
		while read -r -t 10 -u $myFifoFD p; do 	line=$line$p
			if [ "$line" = "QUIT" ]; then # @@@ But not for Central IN, ?????
				log ">>MsgPipe[$myFifoPFN] - Quit cmd recv'd";     return; 
			else
				if [ $timeOut ]; then timeOut=false; # log ''; #1st after TimeOut -> new ln
				fi
			#dd	log "MsgPipe[$myFifoPFN] >>$line<<"
				doMsg "$line";  line='';
			fi
		done
		if [ -z "$p"]; then  #Is this a time out w/o any partial read?
			timeOut=true; # echo -n "*";  
			sleep 5;
		else
			log "lclMsgRcv.sh - fifoRcvLp: read -> partial, so sleep 1";  sleep 1;
		fi 
#qq		timeOut=false
	done
	log "fifoRcvLp() - Exiting: $myFifoPFN FiFo GONE!"
} # ----
startFifoRcv () { local myFifoPFN=$1  myFifoFD # FD = File Descriptor
	trap "rm -f $myFifoPFN" EXIT;  [[ -e $myFifoPFN ]] || mkfifo $myFifoPFN;
	exec {myFifoFD}<>"$myFifoPFN";  fifoRcvLp;  {myFifoFD}>&- ;  rm -f myFifoPFN;
#xx	&& die "** ERROR: FiFo Pipe already Exists: $myFifoPFN" 
}

TL () { echo "`cat /proc/uptime` -- $@" >> /TimeLine.txt; }

WkPrxySQL () {  log "Start - WkPrxySQL()  xc: $1   FQHP: $2  FN: $3"
    if [[ "0" = $1 ]]; then
    	log "WkPrxySQL() - Push $2$3 OffSite!"
    else
    	log "WkPrxySQL() - Error exit code: $1"
    fi
}

SqlHB () { log "SqlHB: $@  `cat /proc/uptime`"; }

declare -A CmdMp     # Create an associative array
CmdMp[SqlHB]=SqlHB
CmdMp[TL]=TL
CmdMp[WkPrxySQL]=WkPrxySQL

doMsgA () {  local cmd0=$1; shift;  # log "doMsgA() - cmd: $cmd >< args: $@"
#xx    [[ "TL" = "$cmd" ]] && TL "$@" && return;
    cmd=${CmdMp[$cmd0]}
    [[ -n "$cmd" ]] && $cmd "$@" && return;
    log "doMsgA() - $cmd0 is not an internal command - Trying external commands..."
    # @@ call it if 4cmd exists in __/cmd/ dir @@@
    log "??? $cmd0  $@"
}

doMsg () { #dd log "doMsg #2  >>$1"; 
	[[ "#" = "${1:0:1}" ]] && log "$@" && return;
#dd	log "NOT a Comment >>$1";
	doMsgA $1;
}

mkdir -p /srv/run/wkFlo
startFifoRcv /srv/run/wkFlo/hstWkFloRcv.fifo

#msg () { echo "$@" >> /srv/run/wkFlo/hstWkFloRcv.fifo; }
