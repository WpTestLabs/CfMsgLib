#!/usr/bin/env bash
#!/bin/sh
#	echo "WkFloSqlRcv.sh"; # Receives messages incoming to SQL Kn (GX)

msg "TL [SQL] Start: $Srv/bin/WkFloSqlRcv.sh"
msg "TL [SQL] WkFloSqlRcv.sh - fifoPFN: $KnWkFloFifoGPFN"

export LogFQPFN=$SrvGP/run/wkFlo/wkFloSqlRcvLog.txt
export WfRcvN=WfSqlRcv

# Example - msg () { echo "$@" >> $LogFQPFN; } # For Knz, add hardlink w/in Kn vw back to main fifo

echo "#### Start: $LogFQPFN ####"  > $LogFQPFN
log () { echo "`date +%Y/%m/%d-%T` - $@" >>$LogFQPFN; }
#xx export -f log #@@@ But not in Alpine!!!
export  log #@@@ But not in Alpine!!!
log "[SQL] Starting log for: WkFloSqlRcv.sh" #@@@@@@@@

. $SrvGP/lib/fifoRcvLib-01.sh # Here $SrvLib is GX

CmdMp[Echo]=Echo
# CmdMp[TL]=TL
CmdMp[WkPrxySQL]=WkPrxySQL

# TL () { echo "`cat /proc/uptime` -- $@" >> /TimeLine.txt; }


Echo () {  log "[SQL] Echo>> $@"; 
    msg "# [SQL] Echo>> $@"; 
    msg $@;
}


WkPrxySQL () {  log "[WkFlo] Start - WkPrxySQL()  xc: $1   FQHP: $2  FN: $3"
    if [[ "0" = $1 ]]; then
    	log "[WkFlo] WkPrxySQL() - Push $2$3 OffSite!"
    else
    	log "[WkFlo] WkPrxySQL() - Error exit code: $1"
    fi
}
#suFifoRcv $Srv/Knz/WkFlo/srv/cmd /srv/run/wkFlo  hstWkFloRcv.fifo
suFifoRcv /srv/lib/wkFlo/cmd /srv/run/wkFlo  WkFlo2Kn.fifo
