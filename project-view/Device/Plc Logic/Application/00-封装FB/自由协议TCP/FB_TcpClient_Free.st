FUNCTION_BLOCK FB_TcpClient_Free
VAR_INPUT
	xConnect			:BOOL;				//连接
	xDisConnect			:BOOL;				//断开连接	
	xReset				:BOOL;				//复位
	sServerIP			:STRING;			//服务器IP
	uiServerPort		:UINT;				//服务器端口号
	xSend				:BOOL;				//发送
	pbySendData			:POINTER TO BYTE;	//发送数据变量容器起始地址
	udiSendDataSize		:UDINT;				//发送数据变量容器大小
	udiSendLenght		:UDINT;				//发送数据长度
	pbyReceiveData		:POINTER TO BYTE;	//接收数据变量容器起始地址
	udiReceiveDataSize	:UDINT;				//接收数据变量容器大小
END_VAR
VAR_OUTPUT
	xBusy				:BOOL;				//运行中				
	xConnected			:BOOL;				//已连接
	xError				:BOOL;				//错误
	xSendDone			:BOOL;				//发送完毕
	udiNumOfSend		:UDINT;				//发送次数（满4294967295自动清零）
	xReceiveDone		:BOOL;				//接收完毕
	udiNumOfReceive		:UDINT;				//接收次数（满4294967295自动清零）
	udiReceiveLenght	:UDINT;				//接收数据长度	
END_VAR
VAR
	iStep			:INT;	
	udiIndex		:UDINT;;
	fbClient		:TCP.Connector;
	eClientError	:TCP.ERROR;	
	rtrigSend		:Standard.R_TRIG;
	eSendError		:TCP.ERROR;	
	rtrigReceive	:Standard.R_TRIG;	
	eReceiveError	:TCP.ERROR;		
	xiReceiveLen	:__XINT;	
	pby1			:POINTER TO BYTE;
	ton1:		Standard.TON;	
END_VAR
// --- implementation ---
// ton1(IN:= TRUE, PT:= T#5000MS, Q=> , ET=> );
// IF NOT ton1.Q THEN
// 	RETURN;
// END_IF

IF xDisConnect THEN
	iStep:=0;
END_IF

//work step
CASE iStep OF
	
0:	//start
	fbClient.Disconnect();
	fbClient.Reset();
	RESET();
	xBusy:=FALSE;
	IF xConnect AND NOT xDisConnect THEN
		SysMem.SysMemSet(pDest:= pbySendData,udiCount:= udiSendDataSize, udiValue:=0);
		SysMem.SysMemSet(pDest:= pbyReceiveData,udiCount:= udiReceiveDataSize, udiValue:=0);
		xBusy:=TRUE;	
		iStep:=10;
	END_IF

10:	//wait connect
	eClientError:=fbClient.Connect(sIPAddress:= sServerIP, uiPort:= uiServerPort, pStream=> );
	IF eClientError = TCP.ERROR.NO_ERROR THEN
		xConnected:=TRUE;
		iStep:=20;
	ELSIF xReset THEN
		iStep:=0;
	END_IF	
	
20:	//work
	RECEIVE();
	SEND();
	
30:	//error
	fbClient.Disconnect();
	fbClient.Reset();
	xConnected:=FALSE;
	xError:=TRUE;
	IF xReset THEN
		RESET();
		SysMem.SysMemSet(pDest:= pbySendData,udiCount:= udiSendDataSize, udiValue:=0);
		SysMem.SysMemSet(pDest:= pbyReceiveData,udiCount:= udiReceiveDataSize, udiValue:=0);
		iStep:=10;
	END_IF
	
END_CASE
END_FUNCTION_BLOCK

ACTION SEND:
rtrigSend(CLK:= xSend, Q=> );
//没有触发send功能，把成功标志位置false
IF NOT xSend THEN
	xSendDone:=FALSE;
END_IF
IF rtrigSend.Q THEN
	//发送次数++1
	udiNumOfSend:=udiNumOfSend+1;
	IF udiNumOfSend=4294967295 THEN
		udiNumOfSend:=0;
	END_IF	
	//判断发送长度，防止发送长度超越变量容器大小
	IF udiSendLenght > udiSendDataSize THEN
		eSendError:=fbClient._Stream.Send(pbyBuffer:= pbySendData, diBufferSize:= UDINT_TO_DINT(udiSendDataSize), diSent=> );
	ELSE	
		eSendError:=fbClient._Stream.Send(pbyBuffer:= pbySendData, diBufferSize:= UDINT_TO_DINT(udiSendLenght), diSent=> );
	END_IF
	//判断发送结果
	IF eSendError = TCP.ERROR.NO_ERROR THEN
		xSendDone:=TRUE;
	ELSE	
		iStep:=30;
	END_IF
END_IF
END_ACTION

ACTION RECEIVE:
//启动receive功能
eReceiveError:=fbClient._Stream.Receive(pbyBuffer:= pbyReceiveData, diBufferSize:= UDINT_TO_DINT(udiReceiveDataSize), diReceived=> xiReceiveLen);
rtrigReceive(CLK:= eReceiveError=TCP.ERROR.NO_ERROR , Q=> );
IF rtrigReceive.Q THEN
	//发送次数++1
	udiNumOfReceive:=udiNumOfReceive+1;	
	IF udiNumOfReceive=4294967295 THEN
		udiNumOfReceive:=0;
	END_IF
	//触发接收标志位时，对接收数据操作。把不属于本次接收数据长度以外的数据清除
	FOR udiIndex:=__XINT_TO_UDINT(xiReceiveLen) TO (udiReceiveDataSize-1) BY 1 DO
		pby1:=pbyReceiveData+udiIndex;
		pby1^:=0;
	END_FOR	
	SysMem.SysMemSet(pDest:= pbyReceiveData+TO_DWORD(xiReceiveLen),udiCount:= udiReceiveDataSize-TO_UDINT(xiReceiveLen), udiValue:=0);	
	//输出接收数据长度
	udiReceiveLenght:=__XINT_TO_UDINT(xiReceiveLen);
END_IF
//输出接收成功标志位，上升沿
xReceiveDone:=rtrigReceive.Q;
//receive功能错误判定
IF eReceiveError <> TCP.ERROR.NO_ERROR AND eReceiveError <> TCP.ERROR.PENDING THEN
	iStep:=30;
END_IF
END_ACTION

ACTION RESET:
//复位各类标志位
xConnected:=FALSE;
xError:=FALSE;
xSendDone:=FALSE;
xReceiveDone:=FALSE;
udiReceiveLenght:=0;	
udiNumOfSend:=0;
udiNumOfReceive:=0;

//复位功能rtrig
rtrigReceive(CLK:= FALSE, Q=> );
rtrigSend(CLK:= FALSE, Q=> );

//复位功能fun状态
eClientError:=TCP.ERROR.NO_ERROR;
eReceiveError:=TCP.ERROR.NO_ERROR;
eSendError:=TCP.ERROR.NO_ERROR;
END_ACTION
