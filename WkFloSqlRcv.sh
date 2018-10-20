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
CmdMp[WkFlo]=WkFloGX

Echo () {  log "[SQL] Echo>> $@"; 
    msg "# [SQL] Echo>> $@"; 
    msg $@;
}
# TL () { echo "`cat /proc/uptime` -- $@" >> /TimeLine.txt; }


WkPrxySQL () {  log "[WkFlo] Start - WkPrxySQL()  xc: $1   FQHP: $2  FN: $3"
    if [[ "0" = $1 ]]; then
    	log "[WkFlo] WkPrxySQL() - Push $2$3 OffSite!"
    else
    	log "[WkFlo] WkPrxySQL() - Error exit code: $1"
    fi
}  ##############
export WkFloTkn
declare -A WfCmdMP
  WfCmdMP[DbDmp]=DbDmpGX

WkFloGX () { WkFloTkn= $1; local cmdGP=$SrvGP/lib/wkFlo  cmd0=$2  cmd; shift 2;
  msg "# [SQL] WkFloGX() - Start, tkn: $WkFloTkn  cmd: $cmd0  args: $@ "
  cmd=${WfCmdMP[$cmd0]};  [[ -n "$cmd" ]] && $cmd "$@" && return;
  msg "# [SQL] WkFloGX() >> $cmd0 is NOT an Internal Command!"
  if [[ -e $cmdGP/$cmd0 ]]; then
    $cmdGP/$cmd0 "$@";  xc=$?; 
	msg "# [SQL] WkFlo() >> $cmd0 - Exit Code: $xc"
  else 
    msg "# [SQL] ** WkFlo() >> $cmd0 is NOT an External Command! **"
  fi
}
DbDmpGX () {  local dbN=$1  tmpGP; shift  
    msg "# [SQL] DbDmpGX() >> Start: tkn: $WkFloTkn  DbN: $dbN  args: $@"
tmpGP=$SrvGP/tmp/$dbN; mkdir -p $tmpGP;  rm -fr $tmpGP/*
mysqldump --add-drop-table $dbN > $tmpGP/${dbN}.sql.tmp 2> $tmpGP/dqlDmp.log; xc=$? 
msg "# [SQL] DbDmpGX() - tmpGP: $tmpGP  xc: $xc"
msg "# WfDbDmpCB $WfFloTkn $xc $tmpGP" 
}  
###########
#suFifoRcv $Srv/Knz/WkFlo/srv/cmd /srv/run/wkFlo  hstWkFloRcv.fifo
suFifoRcv /srv/lib/wkFlo/cmd /srv/run/wkFlo  WkFlo2Kn.fifo
