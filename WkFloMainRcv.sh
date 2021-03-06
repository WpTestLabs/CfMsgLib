#!/bin/bash
#!/bin/sh
    #	echo "WkFloMainRcv.sh";
export LogFQP=/srv/log/wkFlo
export LogFQPFN=$LogFQP/hstWkFloRcvRAW.txt
export HeartBeatLogFQPFN=$LogFQP/hstWkFloRcvHeartBeat.txt
export WfRcvN=WfMainRcv
    #Example: msg () { echo "$@" >> $LogFQPFN; } # 4 Knz, add hardlink w/in Kn vw back to main fifo
echo "#### Start: $LogFQPFN ####"  > $LogFQPFN
log () { echo "`date +%Y/%m/%d-%T` - $@" >>$LogFQPFN; }
export -f log #@@@ But not in Alpine!!!
log "[Hst] Starting log for: fifoRcvLib.sh" #@@@@@@@@

. $SrvLib/fifoRcvLib-01.sh # Here $SrvLib is HX

SqlHB () { echo "[SQL] SqlHB: $@  `cat /proc/uptime`" >> $HeartBeatLogFQPFN; }
TL () { echo "`cat /proc/uptime` -- $@" >> /TimeLine.txt; }

CmdMp[SqlHB]=SqlHB
CmdMp[TL]=TL
#CmdMp[WkPrxySQL]=WkPrxySQL
#CmdMp[WfDbDmpCB]=WfDbDmpCB

#WfDbDmpCB () { local SqlSrvID=$1  WkFloTkn=$2  xc=$3  tmpGP=$4; shift 4;
WfDbDmpCB () { export SqlSrvID=$1  WkFloTkn=$2  xc=$3  tmpGP=$4; shift 4;
    local WfTknBasHP=$SrvWkFlo/svrCB/$SqlSrvID/WfDbDmpCB # /{G,B,w8}
    if [[ -e $WfTknBasHP/w8/$WkFloTkn ]]; then 
        log "[WkFlo] WfDbDmpCB() - Found tkn file: $WfTknBasHP/w8/$WkFloTkn - Loading..."
        . $WfTknBasHP/w8/$WkFloTkn
        
 log " Start: dmpVars()";  dmpVars; log "After dmpVars()"  #@@@@ <<<< can't get env ?????
 log "qq >> $qq"
log "[WfDbDmpCB after Tkn load] Loaded token env: $WkFloTkn "
log "[WfDbDmpCB after Tkn load] WfDbDmpCB $SqlSrvID $WkFloTkn   $xc  $tmpGP"
. $SrvWkFlo/svrByID/$SqlSvrID # Soft link to guestEnv.sh
log "[WfDbDmpCB after Tkn load] WfDbDmpCB - Hst Pth: $KnBasHP$tmpGP"
log "[WfDbDmpCB after Tkn load] WfDbDmpCB - ls: `ls $KnBasHP$tmpGP`"
        # @@ Load WkStp & WkStpKls, Confirm G|B,  call G()|B(), __? exit!  <<<<<<<<<<<<< 
    else
        log "[WkFlo] WfDbDmpCB() - ** MISSING tkn file: $WfTknBasHP/w8/$WkFloTkn "
    fi  # Confirm G/B / mv results to 'marshal' area
}
WkPrxySQL () {  log "[WkFlo] Start - WkPrxySQL()  xc: $1   FQHP: $2  FN: $3"
    if [[ "0" = $1 ]]; then
    	log "[WkFlo] WkPrxySQL() - Push $2$3 OffSite!"
    else
    	log "[WkFlo] WkPrxySQL() - Error exit code: $1"
    fi
}
#xx suFifoRcv $Srv/Knz/WkFlo/srv/cmd /srv/run/wkFlo  hstWkFloRcv.fifo
suFifoRcv $WkFloCmd /srv/run/wkFlo  hstWkFloRcv.fifo
