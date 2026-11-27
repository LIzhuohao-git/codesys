PROGRAM ModTcp_Chassis_Car
VAR_IN_OUT
	Client								: ModbusFB.ClientTCP;
	Chassis_Car							: ST_Chassis_Car;
END_VAR
VAR_INPUT               			
	uiUnitId							: UINT:=1;		//设备ID
	udiTimeOut							: UDINT:=1000;	//动作时间，单位ms
	udiReplyTimeout						: UDINT:=1000;	//回复超时，单位ms
END_VAR
VAR
	FB_WriteSingleRegister				: ModbusFB.ClientRequestWriteSingleRegister;	//写单个寄存器
	FB_WriteSingleCoil					: ModbusFB.ClientRequestWriteSingleCoil;		//写单个线圈
	FB_WriteMultipleCoils				: ModbusFB.ClientRequestWriteMultipleCoils;		//写多个线圈
	FB_ReadInputRegisters				: ModbusFB.ClientRequestReadInputRegisters;		//只读输入寄存器
	FB_ReadDiscreteInputs				: ModbusFB.ClientRequestReadDiscreteInputs;		//读取离散输入值
	
	W_InputRegisters					: ARRAY[0..56] OF WORD;
	//W_Statue							: ARRAY[0..1] OF WORD;
	arrBool_Statue						: ARRAY[0..20] OF BOOL;
	W_DI								: WORD;
	W_DO								: WORD;
	wDoFalse							: WORD;
	afrigDoFalse						: ARRAY [0..15] OF Standard.F_TRIG;
	atrigDoTrue							: ARRAY [0..15] OF Standard.R_TRIG;
	iIndex								: INT;
	axDoFalse							: ARRAY [0..15] OF BOOL;
	axDoTrue							: ARRAY [0..15] OF BOOL;
	wDoTrue								: WORD;
END_VAR

VAR
	Ton_LostConnect						: Standard.TON;
	bError								: BOOL;
	rTrig_Active						: Standard.R_TRIG;	//通讯连接成功上升沿
	iState								: INT;
END_VAR
VAR CONSTANT
	rPi									: REAL:=3.14159265358979323846;		
END_VAR
// --- implementation ---
ACT_01_FB();

(*通讯连接成功后，进入TCP读写轮询*)
// rTrig_Active(CLK:= Chassis_Car.bConnected);
// IF rTrig_Active.Q THEN
// 	iState:=100;
// END_IF
ACT_02_Excute();

ACT_03_WriteMess();

(*断线自动重连*)
IF NOT Chassis_Car.bConnected AND Chassis_Car.bConnect THEN
	IF Ton_LostConnect.Q THEN
        Ton_LostConnect(IN:=FALSE);
    END_IF
    Ton_LostConnect(IN:=TRUE, PT:=T#2000MS);
ELSE
	Ton_LostConnect(IN:=FALSE);
END_IF

(*功能块错误*)
IF Chassis_Car.bConnect AND bError THEN
	Chassis_Car.bError:=TRUE;
ELSE
	bError:=FALSE;
	Chassis_Car.bError:=FALSE;
END_IF
END_PROGRAM

ACTION ACT_02_Excute:
CASE iState OF
	0:
		//只读输入寄存器
		FB_ReadInputRegisters.uiStartItem := 0;
		FB_ReadInputRegisters.uiQuantity := 57;
		FB_ReadInputRegisters.pData := ADR(W_InputRegisters);
		FB_ReadInputRegisters.xExecute := Chassis_Car.bConnected;
		IF FB_ReadInputRegisters.xDone THEN
			FB_ReadInputRegisters.xExecute:=FALSE;
			iState:=10;
		ELSIF FB_ReadInputRegisters.xError THEN
			iState:=1000;
		END_IF
		
	10:
		//读状态量
		FB_ReadDiscreteInputs.uiStartItem := 0;
		FB_ReadDiscreteInputs.uiQuantity := 19;
		FB_ReadDiscreteInputs.pData := ADR(arrBool_Statue);//32
		FB_ReadDiscreteInputs.xExecute := Chassis_Car.bConnected;
		IF FB_ReadDiscreteInputs.xDone THEN
			FB_ReadDiscreteInputs.xExecute:=FALSE;
			iState:=40;
		ELSIF FB_ReadDiscreteInputs.xError THEN
			iState:=1000;
		END_IF
		
	20:
		//读DI状态
		FB_ReadDiscreteInputs.uiStartItem := 19;
		FB_ReadDiscreteInputs.uiQuantity := 16;
		FB_ReadDiscreteInputs.pData := ADR(W_DI);
		FB_ReadDiscreteInputs.xExecute := Chassis_Car.bConnected;
		IF FB_ReadDiscreteInputs.xDone THEN
			FB_ReadDiscreteInputs.xExecute:=FALSE;
			iState:=30;
		ELSIF FB_ReadDiscreteInputs.xError THEN
			iState:=1000;
		END_IF
		
	30:
		//读DO状态
		FB_ReadDiscreteInputs.uiStartItem := 59;
		FB_ReadDiscreteInputs.uiQuantity := 16;
		FB_ReadDiscreteInputs.pData := ADR(W_DO);
		FB_ReadDiscreteInputs.xExecute := Chassis_Car.bConnected;
		IF FB_ReadDiscreteInputs.xDone THEN
			FB_ReadDiscreteInputs.xExecute:=FALSE;
			iState:=40;
		ELSIF FB_ReadDiscreteInputs.xError THEN
			iState:=1000;
		END_IF
		
	40:
		//抢占控制权
		IF Glob_ModbusTcpServer.Car_M_xSeizeControlPower THEN
			FB_WriteSingleCoil.uiItem := 9;
			FB_WriteSingleCoil.xValue := TRUE;
			FB_WriteSingleCoil.xExecute := Chassis_Car.bConnected;;
			IF FB_WriteSingleCoil.xDone THEN
				Glob_ModbusTcpServer.Car_M_xSeizeControlPower:= FALSE;
				FB_WriteSingleCoil.xExecute := FALSE;
				iState:=50;
			ELSIF FB_WriteSingleCoil.xError THEN
				iState:=1000;
			END_IF
		//释放控制权
		ELSIF Glob_ModbusTcpServer.Car_M_xReleaseControlPower THEN
			FB_WriteSingleCoil.uiItem := 10;
			FB_WriteSingleCoil.xValue := TRUE;
			FB_WriteSingleCoil.xExecute := Chassis_Car.bConnected;;
			IF FB_WriteSingleCoil.xDone THEN
				Glob_ModbusTcpServer.Car_M_xReleaseControlPower:= FALSE;
				FB_WriteSingleCoil.xExecute := FALSE;
				iState:=50;
			ELSIF FB_WriteSingleCoil.xError THEN
				iState:=1000;
			END_IF	
		ELSE
			iState:=50;
		END_IF
		
	50:
		//DO置FALSE
		FOR iIndex:=0 TO 15 BY 1 DO 
			afrigDoFalse[iIndex](CLK:= ( Chassis_Car.wControlModeCur_RData = 0 AND Glob_ModbusTcpServer.Car_M_awDoSwitch[iIndex]=1), Q=> axDoFalse[iIndex]);
		END_FOR
		wDoFalse:=FC_ARR16BOOL_TO_1WORD(axIN:= axDoFalse);
		IF wDoFalse > 0 THEN
			FB_WriteMultipleCoils.uiStartItem := 19;
			FB_WriteMultipleCoils.uiQuantity := 16;
			FB_WriteMultipleCoils.pData := ADR(wDoFalse);
			FB_WriteMultipleCoils.xExecute := Chassis_Car.bConnected;
			IF FB_WriteMultipleCoils.xDone THEN
				FB_WriteMultipleCoils.xExecute := FALSE;
				iState:=60;
			ELSIF FB_WriteMultipleCoils.xError THEN
				iState:=1000;
			END_IF
		ELSE
			iState:=60;
		END_IF
		
	60:
		//DO置TRUE
		FOR iIndex:=0 TO 15 BY 1 DO 
			atrigDoTrue[iIndex](CLK:= ( Chassis_Car.wControlModeCur_RData=0 AND Glob_ModbusTcpServer.Car_M_awDoSwitch[iIndex]=1), Q=> axDoTrue[iIndex]);
		END_FOR
		wDotrue:=FC_ARR16BOOL_TO_1WORD(axIN:= axDotrue);
		IF wDotrue > 0 THEN
			FB_WriteMultipleCoils.uiStartItem := 59;
			FB_WriteMultipleCoils.uiQuantity := 16;
			FB_WriteMultipleCoils.pData := ADR(wDoFalse);
			FB_WriteMultipleCoils.xExecute := Chassis_Car.bConnected;
			IF FB_WriteMultipleCoils.xDone THEN
				FB_WriteMultipleCoils.xExecute := FALSE;
				iState:=70;
			ELSIF FB_WriteMultipleCoils.xError THEN
				iState:=1000;
			END_IF
		ELSE
			iState:=70;
		END_IF
		
	70:
		IF Chassis_Car.wControlModeCur_RData = 0 THEN
			iState:=100;
		ELSE
			iState:=0;
		END_IF
		
	100:
		//路径导航开始
		IF Glob_ModbusTcpServer.Car_M_xNavStart  THEN
			FB_WriteSingleRegister.uiItem := 0;
			FB_WriteSingleRegister.uiValue:=Chassis_Car.wNavStationNum_WData;
			FB_WriteSingleRegister.xExecute := Chassis_Car.bConnected;
			IF FB_WriteSingleRegister.xDone THEN
				Glob_ModbusTcpServer.Car_M_xNavStart := FALSE;
				FB_WriteSingleRegister.xExecute:=FALSE;
				iState:=200;
			ELSIF FB_WriteSingleRegister.xError THEN
				iState:=1000;
			END_IF
		//清除错误
		ELSIF Glob_ModbusTcpServer.Car_M_xClearError  THEN
			FB_WriteSingleRegister.uiItem := 89;
			FB_WriteSingleRegister.uiValue:=1;
			FB_WriteSingleRegister.xExecute := Chassis_Car.bConnected;
			IF FB_WriteSingleRegister.xDone THEN
				Glob_ModbusTcpServer.Car_M_xClearError := FALSE;
				FB_WriteSingleRegister.xExecute := FALSE;
				iState:=200;
			ELSIF FB_WriteSingleRegister.xError THEN
				iState:=1000;
			END_IF
		//重定位
		ELSIF Glob_ModbusTcpServer.Car_M_xReLocation THEN
			FB_WriteSingleCoil.uiItem := 1;
			FB_WriteSingleCoil.xValue := TRUE;
			FB_WriteSingleCoil.xExecute := Chassis_Car.bConnected;;
			IF FB_WriteSingleCoil.xDone THEN
				Glob_ModbusTcpServer.Car_M_xReLocation:= FALSE;
				FB_WriteSingleCoil.xExecute := FALSE;
				iState:=200;
			ELSIF FB_WriteSingleCoil.xError THEN
				iState:=1000;
			END_IF
		//确认定位
		ELSIF Glob_ModbusTcpServer.Car_M_xConfirmLocation  THEN
			FB_WriteSingleCoil.uiItem := 2;
			FB_WriteSingleCoil.xValue := TRUE;
			FB_WriteSingleCoil.xExecute := Chassis_Car.bConnected;;
			IF FB_WriteSingleCoil.xDone THEN
				Glob_ModbusTcpServer.Car_M_xConfirmLocation:= FALSE;
				FB_WriteSingleCoil.xExecute := FALSE;
				iState:=200;
			ELSIF FB_WriteSingleCoil.xError THEN
				iState:=1000;
			END_IF
		//暂停导航
		ELSIF Glob_ModbusTcpServer.Car_M_xNavPause THEN
			FB_WriteSingleCoil.uiItem := 3;
			FB_WriteSingleCoil.xValue := TRUE;
			FB_WriteSingleCoil.xExecute := Chassis_Car.bConnected;;
			IF FB_WriteSingleCoil.xDone THEN
				Glob_ModbusTcpServer.Car_M_xNavPause:= FALSE;
				FB_WriteSingleCoil.xExecute := FALSE;
				iState:=200;
			ELSIF FB_WriteSingleCoil.xError THEN
				iState:=1000;
			END_IF
		//继续导航
		ELSIF Glob_ModbusTcpServer.Car_M_xNavContinue THEN
			FB_WriteSingleCoil.uiItem := 4;
			FB_WriteSingleCoil.xValue := TRUE;
			FB_WriteSingleCoil.xExecute := Chassis_Car.bConnected;;
			IF FB_WriteSingleCoil.xDone THEN
				Glob_ModbusTcpServer.Car_M_xNavContinue:= FALSE;
				FB_WriteSingleCoil.xExecute := FALSE;
				iState:=200;
			ELSIF  FB_WriteSingleCoil.xError THEN
				iState:=1000;
			END_IF
		//取消导航
		ELSIF Glob_ModbusTcpServer.Car_M_xNavCancel THEN
			FB_WriteSingleCoil.uiItem := 5;
			FB_WriteSingleCoil.xValue := TRUE;
			FB_WriteSingleCoil.xExecute := Chassis_Car.bConnected;;
			IF FB_WriteSingleCoil.xDone THEN
				Glob_ModbusTcpServer.Car_M_xNavCancel:= FALSE;
				FB_WriteSingleCoil.xExecute := FALSE;
				iState:=200;
			ELSIF FB_WriteSingleCoil.xError THEN
				iState:=1000;
			END_IF
		ELSE
			iState:=200;
		END_IF
		
		
	200:
		bError:=FALSE;
		iState:=0;
		
	1000:
		FB_WriteSingleRegister.xExecute := FALSE;
		FB_WriteSingleCoil.xExecute := FALSE;
		FB_WriteMultipleCoils.xExecute := FALSE;
		FB_ReadInputRegisters.xExecute := FALSE;
		FB_ReadDiscreteInputs.xExecute := FALSE;
END_CASE
END_ACTION

ACTION ACT_01_FB:
// Client(
// 	xConnect:= Chassis_Car.bConnect, 
// 	xConnected=> Chassis_Car.bConnected, 
// 	xError=> , 
// 	eErrorID=> , 
// 	udiNumMsgSent=> , 
// 	udiNumMsgReply=> , 
// 	udiNumMsgExcReply=> , 
// 	udiNumMsgExcReplyIllFct=> , 
// 	udiNumMsgExcReplyIllDataAdr=> , 
// 	udiNumReplyTimeouts=> , 
// 	udiNumReqNotProcessed=> , 
// 	udiNumReqParamError=> , 
// 	udiLastTransactionTime=> , 
// 	aIPaddr:= addr, 
// 	uiPort:= Port, 
// 	tConnnectTimeOut:= , 
// 	udiLogOptions:= );
	
//Client(xConnected=> Chassis_Car.bConnected );	
	
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
	
//写单个线圈
FB_WriteSingleCoil(
	xExecute:= , 
	udiTimeOut:= udiTimeOut * 1000, 				//单位us
	xDone=> , 
	xBusy=> , 
	xError=> , 
	rClient:= Client, 
	uiUnitId:= uiUnitId, 
	udiReplyTimeout:= udiReplyTimeout * 1000, 		//回复超时，单位us, , 
	uiMaxRetries:= , 
	eErrorID=> , 
	eException=> , 
	uiRetryCnt=> , 
	uiItem:= , 
	xValue:= );
	
//写多个线圈
FB_WriteMultipleCoils(
	xExecute:= , 
	udiTimeOut:= udiTimeOut * 1000, 				//单位us
	xDone=> , 
	xBusy=> , 
	xError=> , 
	rClient:= Client, 
	uiUnitId:= uiUnitId, 
	udiReplyTimeout:= udiReplyTimeout * 1000, 		//回复超时，单位us, , 
	uiMaxRetries:= , 
	eErrorID=> , 
	eException=> , 
	uiRetryCnt=> , 
	uiStartItem:= , 
	uiQuantity:= , 
	pData:= );
	
//只读输入寄存器
FB_ReadInputRegisters(
	xExecute:= , 
	udiTimeOut:= udiTimeOut * 1000, 				//单位us
	xDone=> , 
	xBusy=> , 
	xError=> , 
	rClient:= Client, 
	uiUnitId:= uiUnitId, 
	udiReplyTimeout:= udiReplyTimeout * 1000, 		//回复超时，单位us, , 
	uiMaxRetries:= , 
	eErrorID=> , 
	eException=> , 
	uiRetryCnt=> , 
	uiStartItem:= , 
	uiQuantity:= , 
	pData:= );
	
//读取离散输入值
FB_ReadDiscreteInputs(
	xExecute:= , 
	udiTimeOut:= udiTimeOut * 1000, 				//单位us
	xDone=> , 
	xBusy=> , 
	xError=> , 
	rClient:= Client, 
	uiUnitId:= uiUnitId, 
	udiReplyTimeout:= udiReplyTimeout * 1000, 		//回复超时，单位us, , 
	uiMaxRetries:= , 
	eErrorID=> , 
	eException=> , 
	uiRetryCnt=> , 
	uiStartItem:= , 
	uiQuantity:= , 
	pData:= );
END_ACTION

ACTION ACT_03_WriteMess:
Chassis_Car.wCoordPosX_Low_RData 				:= W_InputRegisters[0];
Chassis_Car.wCoordPosX_High_RData 				:= W_InputRegisters[1];
Chassis_Car.wCoordPosY_Low_RData 				:= W_InputRegisters[2];
Chassis_Car.wCoordPosY_High_RData 				:= W_InputRegisters[3];
Chassis_Car.wCoordPosDeg_Low_RData 				:= W_InputRegisters[4];
Chassis_Car.wCoordPosDeg_High_RData 			:= W_InputRegisters[5];
Chassis_Car.wNavNumCur_RData		 			:= W_InputRegisters[6];
Chassis_Car.wLocationState_RData		 		:= W_InputRegisters[7];
Chassis_Car.wNavState_RData				 		:= W_InputRegisters[8];
Chassis_Car.wNavState_RData				 		:= W_InputRegisters[8];
Chassis_Car.wNavTypeCur_RData					:= W_InputRegisters[9];
Chassis_Car.wLocationConfidence_Low_RData		:= W_InputRegisters[10];
Chassis_Car.wLocationConfidence_High_RData		:= W_InputRegisters[11];
Chassis_Car.wBatteryLevel_RData					:= W_InputRegisters[12];

Chassis_Car.wBatteryVoltage_Low_RData			:= W_InputRegisters[16];
Chassis_Car.wBatteryVoltage_High_RData			:= W_InputRegisters[17];
Chassis_Car.wBatteryCurrent_Low_RData			:= W_InputRegisters[18];
Chassis_Car.wBatteryCurrent_High_RData			:= W_InputRegisters[19];

Chassis_Car.wFatalCode_RData					:= W_InputRegisters[30];
Chassis_Car.wErrorCode_RData					:= W_InputRegisters[31];
Chassis_Car.wWarningCode_RData					:= W_InputRegisters[32];
Chassis_Car.wStationNumCur_RData				:= W_InputRegisters[33];

Chassis_Car.wControlModeCur_RData				:= W_InputRegisters[42];

Chassis_Car.wVelocityVx_Low_RData				:= W_InputRegisters[50];
Chassis_Car.wVelocityVx_High_RData				:= W_InputRegisters[51];
Chassis_Car.wVelocityVy_Low_RData				:= W_InputRegisters[52];
Chassis_Car.wVelocityVy_High_RData				:= W_InputRegisters[53];
Chassis_Car.wVelocityVdeg_Low_RData				:= W_InputRegisters[54];
Chassis_Car.wVelocityVdeg_High_RData			:= W_InputRegisters[55];

Chassis_Car.xIsSlowDown_RData					:= arrBool_Statue[0];
Chassis_Car.xIsBlocked_RData					:= arrBool_Statue[1];
Chassis_Car.xIsCharging_RData					:= arrBool_Statue[2];
Chassis_Car.xIsEStop_RData						:= arrBool_Statue[3];
Chassis_Car.xIsBrake_RData						:= arrBool_Statue[4];
Chassis_Car.xIsStatic_RData						:= arrBool_Statue[18];

Chassis_Car.wDiState_RData 						:= W_DI;
Chassis_Car.wDoState_RData 						:= W_DO;

//状态传递
Glob_ModbusTcpServer.Car_rCoordPosX			:=FC_2WORD_TO_1REAL(wIN0:= Chassis_Car.wCoordPosX_Low_RData, wIN1:= Chassis_Car.wCoordPosX_High_RData);					//坐标位置X
Glob_ModbusTcpServer.Car_rCoordPosY			:=FC_2WORD_TO_1REAL(wIN0:= Chassis_Car.wCoordPosY_Low_RData, wIN1:= Chassis_Car.wCoordPosY_High_RData);					//坐标位置Y
Glob_ModbusTcpServer.Car_rCoordPosDeg		:=FC_2WORD_TO_1REAL(wIN0:= Chassis_Car.wCoordPosDeg_Low_RData, wIN1:= Chassis_Car.wCoordPosDeg_High_RData)/rPi*180;		//坐标位置角度
Glob_ModbusTcpServer.Car_wNavNumCur			:=Chassis_Car.wNavNumCur_RData;			//当前导航任务站点	
Glob_ModbusTcpServer.Car_wLocationState		:=Chassis_Car.wLocationState_RData;		//当前定位状态(0:定位失败，1:定位正确，2:正在重定位，3:定位完成)	
Glob_ModbusTcpServer.Car_wNavState			:=Chassis_Car.wNavState_RData;			//当前导航状态(0:无，1:等待执行导航，2:正在执行导航，3:导航暂停，4:到达，5:失败，6:取消，7:超时)		
Glob_ModbusTcpServer.Car_wNavTypeCur			:=Chassis_Car.wNavTypeCur_RData;		//当前导航类型(0:没有导航，1:自由导航到任意点，2:自由导航到站点，3:路径导航到站点，7:平动转动，100:其他)		
Glob_ModbusTcpServer.Car_rLocationConfidence	:=FC_2WORD_TO_1REAL(wIN0:= Chassis_Car.wLocationConfidence_Low_RData, wIN1:= Chassis_Car.wLocationConfidence_High_RData);	//定位置信度	
Glob_ModbusTcpServer.Car_wBatteryLevel		:=Chassis_Car.wBatteryLevel_RData;		//电池电量
Glob_ModbusTcpServer.Car_rBatteryVoltage		:=FC_2WORD_TO_1REAL(wIN0:= Chassis_Car.wBatteryVoltage_Low_RData, wIN1:= Chassis_Car.wBatteryVoltage_High_RData);	//电池电压	
Glob_ModbusTcpServer.Car_rBatteryCurrent		:=FC_2WORD_TO_1REAL(wIN0:= Chassis_Car.wBatteryCurrent_Low_RData, wIN1:= Chassis_Car.wBatteryCurrent_High_RData);	//电池电流	
Glob_ModbusTcpServer.Car_wFatalCode			:=Chassis_Car.wFatalCode_RData;			//Fatal码	
Glob_ModbusTcpServer.Car_wErrorCode			:=Chassis_Car.wErrorCode_RData;			//Error码
Glob_ModbusTcpServer.Car_wWarningCode		:=Chassis_Car.wWarningCode_RData;		//Warning码	
Glob_ModbusTcpServer.Car_wStationNumCur		:=Chassis_Car.wStationNumCur_RData;		//当前站点	
Glob_ModbusTcpServer.Car_wControlModeCur		:=Chassis_Car.wControlModeCur_RData;	//当前控制模式(0:自己抢占或未被抢占，1:被外部抢占)
Glob_ModbusTcpServer.Car_rVelocityVx			:=FC_2WORD_TO_1REAL(wIN0:= Chassis_Car.wVelocityVx_Low_RData, wIN1:= Chassis_Car.wVelocityVx_High_RData);				//速度Vx
Glob_ModbusTcpServer.Car_rVelocityVy			:=FC_2WORD_TO_1REAL(wIN0:= Chassis_Car.wVelocityVy_Low_RData, wIN1:= Chassis_Car.wVelocityVy_High_RData);				//速度Vy			
Glob_ModbusTcpServer.Car_rVelocityVdeg		:=FC_2WORD_TO_1REAL(wIN0:= Chassis_Car.wVelocityVdeg_Low_RData, wIN1:= Chassis_Car.wVelocityVdeg_High_RData)/rPi*180;	//速度Vdeg	
Glob_ModbusTcpServer.Car_xIsSlowDown			:=Chassis_Car.xIsSlowDown_RData;		//当前减速
Glob_ModbusTcpServer.Car_xIsBlocked			:=Chassis_Car.xIsBlocked_RData;			//当前被阻挡	
Glob_ModbusTcpServer.Car_xIsCharging			:=Chassis_Car.xIsCharging_RData;		//当前正在充电
Glob_ModbusTcpServer.Car_xIsEStop			:=Chassis_Car.xIsEStop_RData;			//当前被急停
Glob_ModbusTcpServer.Car_xIsBrake			:=Chassis_Car.xIsBrake_RData;			//当前抱闸
Glob_ModbusTcpServer.Car_xIsStatic			:=Chassis_Car.xIsStatic_RData;			//当前静止中
Glob_ModbusTcpServer.Car_awDiState			:=FC_1WORD_TO_ARR16WORD(wIN:= Chassis_Car.wDiState_RData);	//当前DI状态
Glob_ModbusTcpServer.Car_awDoState			:=FC_1WORD_TO_ARR16WORD(wIN:= Chassis_Car.wDoState_RData);	//当前DO状态
END_ACTION
