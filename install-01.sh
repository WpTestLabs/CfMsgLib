#  CfMsgLib-01/install-01.sh
	install -pm 740 -o root -g root -t $SrvBin  WkFloMainRcv.sh
	install -pm 740 -o root -g root -t $SrvBin  WkFloSqlRcv.sh
	install -pm 740 -o root -g root -t $SrvLib  fifoRcvLib-01.sh
	install -pm 740 -o root -g root -t $SrvReq  WkFloRcv
	install -pm 740 -o root -g root -t $WkFloCmd  ./cmd/WfDbDmpCB;
	
