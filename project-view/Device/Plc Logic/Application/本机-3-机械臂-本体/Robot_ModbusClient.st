PROGRAM Robot_ModbusClient
VAR_IN_OUT
	RobotMod							:ST_ROBOT_MODULE;
	Client								: ModbusFB.ClientTCP;
END_VAR
VAR_INPUT               			
	uiUnitId							: UINT:=1;		//设备ID
	udiTimeOut							: UDINT:=1000;	//动作时间，单位ms
	udiReplyTimeout						: UDINT:=1000;	//回复超时，单位ms
END_VAR
VAR

	FB_WriteSingleRegister				: ModbusFB.ClientRequestWriteSingleRegister;	//写单个寄存器 06
	FB_WriteMulRegister					: ModbusFB.ClientRequestWriteMultipleRegisters;	//写多个寄存器
	FB_ReadHoldingRegisters				: ModbusFB.ClientRequestReadHoldingRegisters;	//读保持寄存器 03
	FB_WriteSingleCoil 					: ModbusFB.ClientRequestWriteSingleCoil; 		//写单个线圈 05
	FB_ReadDiscreteInputs				: ModbusFB.ClientRequestReadDiscreteInputs;	//读触电寄存器  02
END_VAR
VAR
	Ton_LostConnect						: Standard.TON;
	bError								: BOOL;
	rTrig_Active						: Standard.R_TRIG;	//通讯连接成功上升沿
	iState								: INT;
END_VAR
VAR
	xDiscreteInputs						: ARRAY [0..11] OF BOOL;		//触电寄存器
	arrWHoldingRegisters				: ARRAY [0..7] OF WORD;
	arrWHoldingRegisters1				: ARRAY [0..2] OF WORD;
	arrWriteMulRegister					: ARRAY [0..3] OF WORD;

	
	pAction								:POINTER TO BOOL;
	Delay								:Standard.TON;
END_VAR
// --- implementation ---
ACT_01_FB();

ACT_02_Excute();

Act_03_State();

// (*断线、通讯错误时，自动重连*)
// IF ( NOT RobotMod.bConnected OR RobotMod.bTcpError OR bError ) AND RobotMod.bConnect THEN
// 	IF Ton_LostConnect.Q THEN
//         Ton_LostConnect(IN:=FALSE);
//     END_IF
//     Ton_LostConnect(IN:=TRUE, PT:=T#1000MS);
// ELSE
// 	Ton_LostConnect(IN:=FALSE);
// END_IF
END_PROGRAM

ACTION ACT_01_FB:
// Client(
// 	xConnected=> RobotMod.bTcpActive );
	
	(*客户端*)
//Client(xConnected=> RobotMod.bConnected);


//写单个寄存器
FB_WriteSingleRegister(
	xExecute:= , 
	udiTimeOut:= udiTimeOut * 1000, 				//单位us
	xDone=> , 
	xBusy=> , 
	xError=> , 
	rClient:= Client, 
	uiUnitId:= uiUnitId, 
	udiReplyTimeout:= udiReplyTimeout * 1000, 		//回复超时，单位us, 
	uiMaxRetries:= , 
	eErrorID=> , 
	eException=> , 
	uiRetryCnt=> , 
	uiItem:= , 
	uiValue:= );
	

//写保持型寄存器	
FB_ReadHoldingRegisters(
	xExecute:= , 
	udiTimeOut:= udiTimeOut * 1000, 				//单位us, ,
	xDone=> , 
	xBusy=> , 
	xError=> , 
	rClient:= Client, 
	uiUnitId:= uiUnitId, 
	udiReplyTimeout:= udiReplyTimeout * 1000, 		//回复超时，单位us, , , 
	uiMaxRetries:= , 
	eErrorID=> , 
	eException=> , 
	uiRetryCnt=> , 
	uiStartItem:= , 
	uiQuantity:= , 
	pData:= );
	
//写单个线圈
FB_WriteSingleCoil(
	xExecute:= , 
	udiTimeOut:= udiTimeOut * 1000, 				//单位us, ,
	xDone=> , 
	xBusy=> , 
	xError=> , 
	rClient:= Client, 
	uiUnitId:= uiUnitId, 
	udiReplyTimeout:= udiReplyTimeout * 1000, 		//回复超时，单位us, , , 
	uiMaxRetries:= , 
	eErrorID=> , 
	eException=> , 
	uiRetryCnt=> , 
	uiItem:= , 
	xValue:= );

//读取离散型输入	
FB_ReadDiscreteInputs(
	xExecute:= , 
	udiTimeOut:= udiTimeOut * 1000, 				//单位us, ,
	xDone=> , 
	xBusy=> , 
	xError=> , 
	rClient:= Client, 
	uiUnitId:= uiUnitId, 
	udiReplyTimeout:= udiReplyTimeout * 1000, 		//回复超时，单位us, , , 
	uiMaxRetries:= , 
	eErrorID=> , 
	eException=> , 
	uiRetryCnt=> , 
	uiStartItem:= , 
	uiQuantity:= , 
	pData:= );

//写多个寄存器	
FB_WriteMulRegister(
	xExecute:= , 
	udiTimeOut:=  udiTimeOut * 1000, 				//单位us, ,
	xDone=> , 
	xBusy=> , 
	xError=> , 
	rClient:= Client, 
	uiUnitId:= uiUnitId, 
	udiReplyTimeout:= udiReplyTimeout * 1000, 		//回复超时，单位us, , , 
	uiMaxRetries:= , 
	eErrorID=> , 
	eException=> , 
	uiRetryCnt=> , 
	uiStartItem:= , 
	uiQuantity:= , //“回复超时”情况下的请求重试次数。
	pData:= );
END_ACTION

ACTION ACT_02_Excute:
CASE iState OF
	0:
		//只读触点寄存器
		FB_ReadDiscreteInputs.uiStartItem := 0;
		FB_ReadDiscreteInputs.uiQuantity := 12;
		FB_ReadDiscreteInputs.pData := ADR(xDiscreteInputs);
		FB_ReadDiscreteInputs.xExecute := RobotMod.bConnected;
		IF FB_ReadDiscreteInputs.xDone THEN
			FB_ReadDiscreteInputs.xExecute:=FALSE;
			iState:=10;
		ELSIF FB_ReadDiscreteInputs.xError THEN
			iState:=1000;
		END_IF
		
	10:
		//读保持寄存器 1010-1017
		FB_ReadHoldingRegisters.uiStartItem := 1010;
		FB_ReadHoldingRegisters.uiQuantity := 8;
		FB_ReadHoldingRegisters.pData := ADR(arrWHoldingRegisters);
		FB_ReadHoldingRegisters.xExecute := RobotMod.bConnected;
		IF FB_ReadHoldingRegisters.xDone THEN
			FB_ReadHoldingRegisters.xExecute := FALSE;
			iState:=15;
		ELSIF FB_ReadHoldingRegisters.xError THEN
			iState:=1000;
		END_IF
		
	15:
		//读保持寄存器 1020-1022
		FB_ReadHoldingRegisters.uiStartItem := 1020;
		FB_ReadHoldingRegisters.uiQuantity := 3;
		FB_ReadHoldingRegisters.pData := ADR(arrWHoldingRegisters1);
		FB_ReadHoldingRegisters.xExecute := RobotMod.bConnected;
		IF FB_ReadHoldingRegisters.xDone THEN
			FB_ReadHoldingRegisters.xExecute := FALSE;
			iState:=20;
		ELSIF FB_ReadHoldingRegisters.xError THEN
			iState:=1000;
		END_IF
		
	20:
		//写运动指令
		//上使能
		IF RobotMod.x_iGrpEnable THEN
			pAction := ADR(RobotMod.x_iGrpEnable);
			FB_WriteSingleCoil.uiItem := 3;
			FB_WriteSingleCoil.xValue := TRUE;
			FB_WriteSingleCoil.xExecute := RobotMod.bConnected;
			IF FB_WriteSingleCoil.xDone THEN
				FB_WriteSingleCoil.xExecute := FALSE;
				iState:=50;
			ELSIF FB_WriteSingleCoil.xError THEN
				iState:=1000;
			END_IF
		//去使能
		ELSIF RobotMod.x_iGrpDisable THEN
			pAction := ADR(RobotMod.x_iGrpDisable);
			FB_WriteSingleCoil.uiItem := 4;
			FB_WriteSingleCoil.xValue := TRUE;
			FB_WriteSingleCoil.xExecute := RobotMod.bConnected;
			IF FB_WriteSingleCoil.xDone THEN
				FB_WriteSingleCoil.xExecute := FALSE;
				iState:=50;
			ELSIF FB_WriteSingleCoil.xError THEN
				iState:=1000;
			END_IF
		//清除报警
		ELSIF RobotMod.x_iGrpReset THEN
			pAction := ADR(RobotMod.x_iGrpReset);
			FB_WriteSingleCoil.uiItem := 5;
			FB_WriteSingleCoil.xValue := TRUE;
			FB_WriteSingleCoil.xExecute := RobotMod.bConnected;
			IF FB_WriteSingleCoil.xDone THEN
				FB_WriteSingleCoil.xExecute := FALSE;
				iState:=50;
			ELSIF FB_WriteSingleCoil.xError THEN
				iState:=1000;
			END_IF
		//开始脚本
		ELSIF RobotMod.x_iStartScript THEN
			pAction := ADR(RobotMod.x_iStartScript);
			FB_WriteSingleCoil.uiItem := 0;
			FB_WriteSingleCoil.xValue := TRUE;
			FB_WriteSingleCoil.xExecute := RobotMod.bConnected;
			IF FB_WriteSingleCoil.xDone THEN
				FB_WriteSingleCoil.xExecute := FALSE;
				iState:=50;
			ELSIF FB_WriteSingleRegister.xError THEN
				iState:=1000;
			END_IF
		//暂停脚本
		ELSIF RobotMod.x_iPauseScript THEN
			pAction := ADR(RobotMod.x_iPauseScript);
			FB_WriteSingleCoil.uiItem := 2;
			FB_WriteSingleCoil.xValue := TRUE;
			FB_WriteSingleCoil.xExecute := RobotMod.bConnected;
			IF FB_WriteSingleCoil.xDone THEN
				FB_WriteSingleCoil.xExecute := FALSE;
				iState:=50;
			ELSIF FB_WriteSingleCoil.xError THEN
				iState:=1000;
			END_IF
		//继续脚本
		ELSIF RobotMod.x_iContinueScript THEN
			pAction := ADR(RobotMod.x_iContinueScript);
			FB_WriteSingleCoil.uiItem := 2;
			FB_WriteSingleCoil.xValue := FALSE;
			FB_WriteSingleCoil.xExecute := RobotMod.bConnected;
			IF FB_WriteSingleCoil.xDone THEN
				FB_WriteSingleCoil.xExecute := FALSE;
				iState:=50;
			ELSIF FB_WriteSingleRegister.xError THEN
				iState:=1000;
			END_IF
		//停止脚本
		ELSIF RobotMod.x_iStopScript THEN
			pAction := ADR(RobotMod.x_iStopScript);
			FB_WriteSingleCoil.uiItem := 1;
			FB_WriteSingleCoil.xValue := TRUE;
			FB_WriteSingleCoil.xExecute := RobotMod.bConnected;
			IF FB_WriteSingleCoil.xDone THEN
				FB_WriteSingleCoil.xExecute := FALSE;
				iState:=50;
			ELSIF FB_WriteSingleCoil.xError THEN
				iState:=1000;
			END_IF
		//手动模式
		ELSIF RobotMod.x_iManualMode THEN
			pAction := ADR(RobotMod.x_iManualMode);
			FB_WriteSingleCoil.uiItem := 9;
			FB_WriteSingleCoil.xValue := TRUE;
			FB_WriteSingleCoil.xExecute := RobotMod.bConnected;
			IF FB_WriteSingleCoil.xDone THEN
				FB_WriteSingleCoil.xExecute := FALSE;
				iState:=50;
			ELSIF FB_WriteSingleCoil.xError THEN
				iState:=1000;
			END_IF
		//自动模式
		ELSIF RobotMod.x_iAutoMode THEN
			pAction := ADR(RobotMod.x_iAutoMode);
			FB_WriteSingleCoil.uiItem := 8;
			FB_WriteSingleCoil.xValue := TRUE;
			FB_WriteSingleCoil.xExecute := RobotMod.bConnected;
			IF FB_WriteSingleCoil.xDone THEN
				FB_WriteSingleCoil.xExecute := FALSE;
				iState:=50;
			ELSIF FB_WriteSingleCoil.xError THEN
				iState:=1000;
			END_IF
		//搬运参数写入	--iState 不需要跳 50
		ELSIF RobotMod.xExcuteSetVal THEN
			arrWriteMulRegister[0] 			:= RobotMod.wOrderNumCur;
			arrWriteMulRegister[1] 			:= RobotMod.wRackTpye;
			arrWriteMulRegister[2] 			:= RobotMod.wDeviceRackPosNum;
			arrWriteMulRegister[3] 			:= RobotMod.wChassisRackPosNum;
			FB_WriteMulRegister.uiStartItem := 1002;
			FB_WriteMulRegister.uiQuantity := 4;
			FB_WriteMulRegister.pData := ADR(arrWriteMulRegister);
			FB_WriteMulRegister.xExecute := RobotMod.bConnected;
			IF FB_WriteMulRegister.xDone THEN
				RobotMod.xExcuteSetVal := FALSE;
				FB_WriteMulRegister.xExecute := FALSE;
				iState:=100;
			ELSIF FB_WriteMulRegister.xError THEN
				iState:=1000;
			END_IF
		//执行初始化动作	--iState 不需要跳 50
		ELSIF RobotMod.xExcuteInit THEN
			FB_WriteSingleRegister.uiItem := 1000;
			FB_WriteSingleRegister.uiValue := 1;
			FB_WriteSingleRegister.xExecute := RobotMod.bConnected;
			IF FB_WriteSingleRegister.xDone THEN
				RobotMod.xExcuteInit := FALSE;
				FB_WriteSingleRegister.xExecute := FALSE;
				iState:=100;
			ELSIF FB_WriteSingleRegister.xError THEN
				iState:=1000;
			END_IF
		//执行搬运动作	--iState 不需要跳 50
		ELSIF RobotMod.xExcuteAct  THEN
			FB_WriteSingleRegister.uiItem := 1001;
			FB_WriteSingleRegister.uiValue := RobotMod.wExecute_Act;
			FB_WriteSingleRegister.xExecute := RobotMod.bConnected;
			IF FB_WriteSingleRegister.xDone THEN
				RobotMod.xExcuteAct := FALSE;
				FB_WriteSingleRegister.xExecute := FALSE;
				iState:=100;
			ELSIF FB_WriteSingleRegister.xError THEN
				iState:=1000;
			END_IF
		ELSE
			iState:=100;
		END_IF
		
		//线圈控制，仅上升沿有效，需要另外控制复位逻辑
	50:
		Delay(IN:= TRUE,PT:=T#50MS);
		IF Delay.Q THEN
			Delay(IN:= FALSE);
			FB_WriteSingleCoil.xValue := FALSE;
			FB_WriteSingleCoil.xExecute := RobotMod.bConnected;
			IF FB_WriteSingleCoil.xDone THEN
				FB_WriteSingleCoil.xExecute := FALSE;
				pAction^ := FALSE;
				iState:=100;
			ELSIF FB_WriteSingleCoil.xError THEN
				iState:=1000;
			END_IF
		END_IF
		
		
	100:
		bError:=FALSE;
		iState:=0;
		
	1000:
		bError := TRUE;
		FB_WriteSingleRegister.xExecute := FALSE;
		FB_WriteMulRegister.xExecute := FALSE;
		FB_ReadHoldingRegisters.xExecute := FALSE;
		FB_WriteSingleCoil.xExecute := FALSE;
		FB_ReadDiscreteInputs.xExecute := FALSE;
		
		Delay(IN:= TRUE,PT:=T#3S);
		IF Delay.Q THEN
			Delay(IN:= FALSE);
			iState:=0;
		END_IF
END_CASE
END_ACTION

ACTION Act_03_State:
RobotMod.x_oStateRunning :=xDiscreteInputs[0];
RobotMod.x_oStateStopping :=xDiscreteInputs[1];
RobotMod.x_oStatePausing :=xDiscreteInputs[2];
RobotMod.x_oStateFree :=xDiscreteInputs[5];
RobotMod.x_oStateElectrify := xDiscreteInputs[6];
RobotMod.x_oStatePower :=xDiscreteInputs[7];
RobotMod.x_oStateErr :=xDiscreteInputs[8];
RobotMod.x_oCollide :=xDiscreteInputs[9];


// -- 寄存器 1010-1017: 机械臂写入PLC的状态区域（机械臂写，PLC读）
// --   1010: GlobInitStatus   -- 初始化状态反馈
// --   1011: OrderNumCur      -- 当前工作站点反馈
// --   1012: RackTpye         -- 当前盘架类型反馈
// --   1013: DeviceRackPosNum -- 当前设备位置反馈
// --   1014: ChassisRackPosNum-- 当前小车位置反馈
// --   1015: Act_Status       -- 动作状态 (0=未执行,1=执行中,2=完成,3=失败)
// --   1016: Execute_Act      -- 当前执行动作反馈 (0/1/2)
// --   1017: RobotBusy        -- 机械臂忙标志 (0=空闲, 1=忙碌)
RobotMod.rGlobInitStatus 		:= arrWHoldingRegisters[0];
RobotMod.rOrderNumCur 			:= arrWHoldingRegisters[1];
RobotMod.rRackTpye	 			:= arrWHoldingRegisters[2];
RobotMod.rDeviceRackPosNum		:= arrWHoldingRegisters[3];
RobotMod.rChassisRackPosNum		:= arrWHoldingRegisters[4];
RobotMod.rAct_Status			:= arrWHoldingRegisters[5];
RobotMod.rExecute_Act			:= arrWHoldingRegisters[6];
RobotMod.RobotBusy				:= arrWHoldingRegisters[7];


// -- 寄存器 1020-1022: 失败详细信息（机械臂写，PLC读）
// --   1020: G_FailCode          -- 失败代码 (0=无错误, 1=RTU连接失败, 2=电爪初始化失败, 3=电爪打开失败, 4=电爪夹紧失败, 5=拍照失败)
// --   1021: G_FailWorkstationrk -- 失败时的工作站点编号
// --   1022: G_FailActType       -- 失败时的动作类型 (1=下料/出库, 2=上料/入库)
RobotMod.G_FailCode 			:= arrWHoldingRegisters[0];
RobotMod.G_FailWorkstationrk 	:= arrWHoldingRegisters[1];
RobotMod.G_FailActType 			:= arrWHoldingRegisters[2];
END_ACTION
