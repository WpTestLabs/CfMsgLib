#!/bin/sh
#	echo "fifoRcvLib.sh";

export LogFQPFN=/srv/log/wkFlo/hstWkFloRcvRAW.txt
# Example - msg () { echo "$@" >> $LogFQPFN; } # For Knz, add hardlink w/in Kn vw back to main fifo

echo "#### Start: $LogFQPFN ####"  > $LogFQPFN
log () { echo "`date +%Y/%m/%d-%T` - $@" >>$LogFQPFN; }
export -f log #@@@ But not in Alpine!!!
log "[Hst] Starting log for: fifoRcvLib.sh"

die () { log "$@"; exit; }
##### doMsg () { log "doMsg STUB >>$1"; }
declare -A CmdMp     # Create an associative array

doMsgA () {  local cmd0=$1; shift;  # log "doMsgA() - cmd: $cmd >< args: $@"
    cmd=${CmdMp[$cmd0]}
    [[ -n "$cmd" ]] && $cmd "$@" && return;
    log "[WkFlo] doMsgA() - $cmd0 is not an internal cmd - Trying external cmd's..."
    log "[WkFlo] WkFloRcv - cur dir: $PWD - lib dir: $myCmdDir"
    log "ls>> `ls $myCmdDir`"
    if [[ -e $myCmdDir/$cmd0 ]]; then
        $myCmdDir/$cmd0 ">>$@"; xc=$?;
    else
        log "[WkFlo] ** $cmd0 is NOT an External Command >> $cmd0 $@  **"
    fi
}

doMsg () { #dd log "doMsg #2  >>$1"; 
	[[ "#" = "${1:0:1}" ]] && log "$@" && return;
	doMsgA $1;
}

onRcvLpInit () { log "#Info - onRcvLpInit is NOOP"; }

fifoRcvLp () {  onRcvLpInit
    local tmOt=false  p='~~~' line='__'  ; # tmOt: timeOut (in sec's)
    while [ -p "$myFifoPFN" ]; do
#	@@@@          vvvvv  when inactive, progress timeout to longer ???
        while read -r -t 10 -u $myFifoFD p; do 	line=$line$p
            if [ "$line" = "QUIT" ]; then # @@@ But not for Central IN, ?????
                log ">>MsgPipe[$myFifoPFN] - Quit cmd recv'd";     return; 
            else
                if [ $tmOt ]; then tmOt=false; # log ''; #1st after TimeOut -> new ln
                fi
         #dd    log "MsgPipe[$myFifoPFN] >>$line<<"
                doMsg "$line";  line='';
            fi
        done
        if [ -z "$p"]; then  #Is this a time out w/o any partial read?
            tmOt=true; # echo -n "*";  
            #qq sleep 5;
        else
            log "lclMsgRcv.sh - fifoRcvLp: read -> partial, so sleep 1";  sleep 1;
        fi 
#qq	tmOt=false
    done
    log "[RcvMsg] fifoRcvLp() - Exiting: $myFifoPFN FiFo GONE!"
} # ----
startFifoRcv () { local myCmdDir=$1 myFifoPFN=$2  myFifoFD # FD = File Descriptor
    trap "rm -f $myFifoPFN" EXIT;  [[ -e $myFifoPFN ]] || mkfifo $myFifoPFN;
    exec {myFifoFD}<>"$myFifoPFN";  fifoRcvLp;  {myFifoFD}>&- ;  rm -f myFifoPFN;
} 

suFifoRcv() { local cmdPth=$1  fifoPth=$2 fifoFN=$3 ;
    mkdir -p $cmdPth $fifoPth;   cd $cmdPth;
    startFifoRcv $cmdPth  $fifoPth/$fifoFN
}
############ End of lib #########

CmdMp[SqlHB]=SqlHB
CmdMp[TL]=TL
CmdMp[WkPrxySQL]=WkPrxySQL

SqlHB () { log "[SQL] SqlHB: $@  `cat /proc/uptime`"; }
TL () { echo "`cat /proc/uptime` -- $@" >> /TimeLine.txt; }

WkPrxySQL () {  log "[WkFlo] Start - WkPrxySQL()  xc: $1   FQHP: $2  FN: $3"
    if [[ "0" = $1 ]]; then
    	log "[WkFlo] WkPrxySQL() - Push $2$3 OffSite!"
    else
    	log "[WkFlo] WkPrxySQL() - Error exit code: $1"
    fi
}
#######

#qq mkdir -p /srv/run/wkFlo  $Srv/Knz/WkFlo/srv/cmd
#qq cd $Srv/Knz/WkFlo/srv/cmd
#qq startFifoRcv $Srv/Knz/WkFlo/srv/cmd /srv/run/wkFlo/hstWkFloRcv.fifo

suFifoRcv $Srv/Knz/WkFlo/srv/cmd /srv/run/wkFlo  hstWkFloRcv.fifo
