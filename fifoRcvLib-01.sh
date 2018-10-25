#!/bin/sh
#	echo "fifoRcvLib-01.sh";
die () { log "$@"; exit; }
declare -A CmdMp     # Create an associative array
doMsgA () {  local cmd0=$1; shift;  # log "doMsgA() - cmd: $cmd >< args: $@"
    cmd=${CmdMp[$cmd0]}
    [[ -n "$cmd" ]] && $cmd "$@" && return;
    log "[$WfRcvN] doMsgA() - $cmd0 is not an internal cmd - Trying external cmd's..."
    log "[$WfRcvN] WkFloRcv - cur dir: $PWD - lib dir: $myCmdDir"
    log "ls>> `ls $myCmdDir`"
    if [[ -e $myCmdDir/$cmd0 ]]; then
        log "doMsgA() - cmd: $cmd >< args: $@"
        $myCmdDir/$cmd0 "$@"; xc=$?;
    else
        log "[$WfRcvN] ** $cmd0 is NOT an External Command >> $cmd0 $@  **"
    fi
}
doMsg () { #dd log "doMsg #2  >>$1"; 
	[[ "#" = "${1:0:1}" ]] && log "$@" && return;
	doMsgA $@;
}
onRcvLpInit () { log "#Info - onRcvLpInit is NOOP"; }
fifoRcvLp () {  onRcvLpInit
    local tmOt=false  p='~~~' line=''  ; # tmOt: timeOut (in sec's)
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
        else
            log "lclMsgRcv.sh - fifoRcvLp: read -> partial, so sleep 1";  sleep 1;
        fi 
#qq	tmOt=false
    done
    log "[$WfRcvN] fifoRcvLp() - Exiting: $myFifoPFN FiFo GONE!"
} # ----
startFifoRcv () { local myCmdDir=$1 myFifoPFN=$2  myFifoFD # FD = File Descriptor
    trap "rm -f $myFifoPFN" EXIT;  [[ -e $myFifoPFN ]] || mkfifo $myFifoPFN;
    exec {myFifoFD}<>"$myFifoPFN";  fifoRcvLp;  {myFifoFD}>&- ;  rm -f myFifoPFN;
} 
suFifoRcv() { local cmdPth=$1  fifoPth=$2 fifoFN=$3 ;
    mkdir -p $cmdPth $fifoPth;   cd $cmdPth;
    startFifoRcv $cmdPth  $fifoPth/$fifoFN
}
