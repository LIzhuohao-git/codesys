PROGRAM Robot_PRG
VAR_IN_OUT
	Robot						: ST_ROBOT_MODULE;
END_VAR

VAR_INPUT
	bInitBtn					: BOOL;								//初始化按钮
	bStartBtn					: BOOL;								//启动按钮
	bPauseBtn					: BOOL;								//暂停按钮
	bStopBtn					: BOOL;								//停止按钮
	bResetBtn					: BOOL;								//复位按钮
	bAutoMode					: BOOL:= TRUE;						//true=自动模式，false=手动模式
END_VAR

VAR
	Warning_T					: Standard.TON;
	Warning						: BOOL;
	Delay						: Standard.TON;
END_VAR

//状态反馈
VAR
	
	wCommErrorCode				: WORD;	//通讯错误码
	wControllerState			: WORD;	//控制器状态机	
	wInDriveSafe				: WORD;	//当前在行驶安全点(0:false，1:true)	
	//wTaskID						: WORD;	//任务ID(当前任务ID，任务开始时获取一次，用于辨识)  	
	wTaskState					: WORD;	//任务状态(0:NONE，1:进行中，2:暂停中，3:已完成，4:参数异常，5:失败)
	wPhotoState					: WORD;	//拍照状态(0:空，1:拍照成功，2:拍照失败)
	wTakeRackState				: WORD;	//管架取料状态(0:空，1:抓料成功，2:抓料抓空，3:抓料抓歪)
	wPutRackState				: WORD;	//管架放料状态(0:空，1:放料成功，2:放料异常)
	wRackSensorState			: WORD;	//管架传感器状态(0:空，1:放料位被占用，2:取料位空闲)	
	
	bMannualStart				: BOOL;		//手动模式启动
	
END_VAR

VAR
	eState						: Robot_STATE;						//总流程状态
	iInitStep					: INT;								//初始化步
	iAutoStep					: INT;								//自动步
	iMannualStep				: INT;								//手动模式步
	rTrig_Init					: Standard.R_TRIG;							//初始化按钮上升沿
	rTrig_Start					: Standard.R_TRIG;							//启动按钮上升沿
	rTrig_Pause					: Standard.R_TRIG;							//暂停按钮上升沿
	rTrig_Stop					: Standard.R_TRIG;							//停止按钮上升沿
	rTrig_Stop_1				: Standard.R_TRIG;							//停止按钮上升沿
	rTrig_Reset					: Standard.R_TRIG;							//复位按钮上升沿
	
END_VAR
VAR_OUTPUT
	iStepId						: INT;
	wsSteplog					: WSTRING;
	bBusy						: BOOL;								//正在运行标志位
	bInitializing				: BOOL;								//初始化中
	bInitialized				: BOOL;								//初始化完成标志位
	bAutoRunning				: BOOL;								//自动运行中
	bPausing					: BOOL;								//暂停中
	bStopping					: BOOL;								//停止中
	uliErrorId					: ULINT;							//错误ID
	uliWarningId				: ULINT;							//警告ID
	bReadyToRun					: BOOL;
	bOnSafePos					: BOOL;								//位于安全位置
END_VAR

VAR_INPUT

	uWorkStation				: UINT;		//工作站点
	uRackType					: UINT;		//管架类型
	uDeviceRackPos				: UINT;		//设备管架位置
	uChassisRackPos				: UINT;		//底盘管架位置
	wTaskID						: UINT;		//任务ID(ID标识符，用于辨识当前任务)  	                                            		
	wTaskNum					: UINT;		//工作方式 (0=无, 1=下料, 2=上料)	
	bStart						: BOOL;
END_VAR
// --- implementation ---
bPausing := bPauseBtn;

ACT_00_FB();
Act_01_Stop();
ACT_02_State();
ACT_03_Warning();


(*初始化按钮*)
rTrig_Init(CLK:= bInitBtn);

CASE eState OF
	Robot_STATE.STOP:
		IF uliWarningId=0 AND uliErrorId=0  AND rTrig_Init.Q THEN		//停止模式下，进入初始化
		iInitStep := 0;
		bInitializing := TRUE;
		Act_99_ActionReset();
		eState := Robot_STATE.INIT;
	END_IF
	
	Robot_STATE.MANNUAL:
		bAutoRunning := FALSE;
		IF bMannualStart THEN
			eState := Robot_STATE.MannualRun;
		ELSIF bAutoMode THEN
			bAutoRunning := TRUE;
			eState := Robot_STATE.AUTO;
		END_IF
	
	Robot_STATE.INIT:
		Act_08_Init();
		IF bInitialized THEN		//初始化完成，进入自动模式
			bInitBtn := FALSE;
			bInitialized := FALSE;
			bAutoRunning := TRUE;
			eState := Robot_STATE.AUTO;
		END_IF
		
	Robot_STATE.MannualRun:
		ACT_11_bMannual();
		IF bAutoMode AND NOT bMannualStart AND iMannualStep = 0 THEN
			eState := Robot_STATE.AUTO;
		END_IF
		
	Robot_STATE.AUTO:
		IF uWorkStation>=1 AND uDeviceRackPos >= 1 
			AND uChassisRackPos>=1 AND uChassisRackPos<=6 AND wTaskNum <> 0 AND bStart 
				AND Glob_ModbusTcpServer.Car_xIsStatic 
					AND NOT Glob_ModbusTcpServer.Car_xIsCharging 
						AND NOT Glob_ModbusTcpServer.Car_xIsEStop THEN
			bBusy := TRUE;
			wTaskState := 1;
			iAutoStep := 0;
			eState := Robot_STATE.RobotAct;
		ELSIF NOT bAutoMode THEN
			eState := Robot_STATE.MANNUAL;
		END_IF
		
	Robot_STATE.RobotAct:
		ACT_10_RobotAct();
		IF NOT bBusy AND NOT bStart AND iAutoStep = 0 THEN
			eState := Robot_STATE.AUTO;
		END_IF
	
END_CASE
END_PROGRAM

ACTION Act_99_ActionReset:
iInitStep := 0;
iAutoStep := 0;
bBusy := FALSE;
bInitBtn := FALSE;
iMannualStep := 0;
END_ACTION

ACTION ACT_10_RobotAct:
CASE iAutoStep OF
	0:
		IF Robot.rGlobInitStatus = 4 AND Robot.rAct_Status <> 1 THEN
			Glob_ModbusTcpServer.Robot_wPhotoState := 0;
			iAutoStep := 10;
		END_IF
	
	10:
		//输入机器人参数
		Robot.wOrderNumCur := uWorkStation;
		Robot.wRackTpye := uRackType;
		Robot.wDeviceRackPosNum := uDeviceRackPos;
		Robot.wChassisRackPosNum := uChassisRackPos;
		Robot.xExcuteSetVal := TRUE;
		iAutoStep := 20;
		
	20:
		IF NOT Robot.xExcuteSetVal AND uWorkStation = Robot.rOrderNumCur 
			AND uRackType = Robot.rRackTpye AND uDeviceRackPos = Robot.rDeviceRackPosNum
				AND uChassisRackPos = Robot.rChassisRackPosNum THEN
			iAutoStep := 30;
		END_IF
		
		
	30:
		//触发机器人动作
		Robot.wExecute_Act := wTaskNum;
		Robot.xExcuteAct := TRUE;
		iAutoStep := 40;
		
	40:
		IF NOT Robot.xExcuteAct AND  Robot.rAct_Status = 1 THEN	
			iAutoStep := 50;
		END_IF
		
	50:
		//清空触发机器人动作
		Robot.wExecute_Act := 0;
		Robot.xExcuteAct := TRUE;
		iAutoStep := 60;
		
	60:
		IF NOT Robot.xExcuteAct THEN
			iAutoStep := 80;
		END_IF
		
		//机械臂状态写入
	80:
		IF Robot.rAct_Status = 2 AND NOT Robot.x_oStatePausing AND Robot.x_oStateRunning THEN	//运行完成
			Glob_ModbusTcpServer.Robot_wPhotoState := 1;
			Glob_ModbusTcpServer.Robot_wTaskState := 3;
			iAutoStep := 100;	
			
		ELSIF Robot.rAct_Status = 3 OR uliWarningId <> 0 THEN	//报错
			//Glob_ModbusTcpServer.Robot_wTaskState := 5;
			iAutoStep := 85;
			
		ELSIF Robot.rAct_Status = 1 AND NOT Robot.x_oStatePausing THEN
			Glob_ModbusTcpServer.Robot_wTaskState := 1;
			
		ELSIF Robot.rAct_Status = 1 AND Robot.x_oStatePausing THEN
			Glob_ModbusTcpServer.Robot_wTaskState := 2; 
			
		END_IF
		
	85:
		Glob_ModbusTcpServer.Robot_wTaskState := 5;
		IF Robot.G_FailCode = 5 THEN
			Glob_ModbusTcpServer.Robot_wPhotoState := 2;
		END_IF
		iAutoStep := 100;	
		
	100:
		//清空触发机器人动作
		Robot.wExecute_Act := 0;
		Robot.xExcuteAct := TRUE;
		iAutoStep := 150;
		
	150:
		IF NOT Robot.xExcuteAct AND  Robot.rAct_Status <> 1 THEN	
			iAutoStep := 500;
		END_IF
		
		
	500:
		wTaskNum := 0;
		uWorkStation := 0;
		uRackType := 0;
		uDeviceRackPos := 0;
		uChassisRackPos := 0;
		bStart := FALSE;
		bBusy := FALSE;
		iAutoStep := 0;
END_CASE
END_ACTION

ACTION ACT_00_FB:
END_ACTION

ACTION Act_01_Stop:
(*停止按钮*)
rTrig_Stop(CLK :=  bStopBtn);
IF rTrig_Stop.Q THEN
	eState := Robot_STATE.STOP;
END_IF

(*停止状态标志位*)
IF eState=Robot_STATE.STOP THEN
	
	bInitializing := FALSE;
	bInitialized := FALSE;
	bAutoRunning := FALSE;
	bPausing := FALSE;
	bStopping := TRUE;
	Delay(IN:= FALSE);
	iAutoStep := 0;
	bStart := FALSE;
	bBusy := FALSE;
	iStepId := 2;

	wsSteplog := "急停中，等待复位初始化";
ELSE
	bStopping := FALSE;
END_IF

rTrig_Stop_1(CLK :=  eState=Robot_STATE.STOP);
IF rTrig_Stop_1.Q THEN
	Robot.x_iStopScript := TRUE;
	Robot.x_iGrpDisable := TRUE;
END_IF
END_ACTION

ACTION Act_08_Init:
CASE iInitStep OF
	0:
		Robot.bConnect := TRUE;
		Glob.Chassis_Car.bConnect := TRUE;
		Robot.x_iAutoMode := FALSE;
		Warning_T(IN := TRUE,PT:= T#5S);
		IF Robot.bConnected AND Glob.Chassis_Car.bConnected THEN
			Warning_T(IN := FALSE);
			iInitStep := 20;
		ELSIF Warning_T.Q THEN
			;
		END_IF
		
		//机械臂切换手动模式
	20:
		Robot.x_iAutoMode := TRUE;
		Delay(IN := TRUE,PT := T#500MS);
		IF Delay.Q THEN
			Delay(IN := false);
			iInitStep := 30;
		END_IF
		
	30:
		IF NOT Robot.x_iAutoMode THEN
			iInitStep := 50;
		END_IF
		
		//机械臂运行脚本
	50:
		IF NOT Robot.x_oStatePower THEN
			Robot.x_iGrpEnable := TRUE;
		ELSIF Robot.x_oStateErr THEN
			Robot.x_iGrpReset := TRUE;
		ELSIF Robot.x_oStateFree OR Robot.x_oStateStopping THEN
			Robot.x_iStartScript := TRUE;
		ELSIF Robot.x_oStatePausing THEN
			Robot.x_iStopScript := TRUE;
		ELSIF Robot.x_oStateRunning THEN
			iInitStep := 100;
		END_IF
		
	100:
		Delay(IN := TRUE,PT := T#1000MS);
		IF Delay.Q THEN
			Delay(IN := false);
			iInitStep := 105;
		END_IF

	105:
		//机械臂运行初始化动作
		//Robot.wExecute_Init := 1;
		Robot.xExcuteInit := TRUE;
		Delay(IN := TRUE,PT := T#1000MS);
		IF Delay.Q THEN
			Delay(IN := false);
			iInitStep := 110;
		END_IF
		
	110:
		IF NOT Robot.xExcuteInit THEN
			iInitStep := 120;
		END_IF
		
	120:
		IF Robot.rGlobInitStatus = 4 THEN
			iInitStep := 150;
		END_IF
		
		
	150:
		Robot.wExecute_Act := 0;
		Robot.xExcuteAct := TRUE;
		iInitStep := 160;
		
	160:
		IF NOT Robot.xExcuteAct AND  Robot.rAct_Status = 0 THEN	
			iInitStep := 1000;
		END_IF
	
	1000:
		iStepId := 1;
		wsSteplog := "待机中";
	
		bInitializing := FALSE;
		bInitialized := TRUE;
		iInitStep := 0;
			
		
END_CASE
END_ACTION

ACTION ACT_02_State:
END_ACTION

ACTION ACT_03_Warning:
IF eState = Robot_STATE.AUTO OR eState = Robot_STATE.RobotAct THEN
	
	uliWarningId.1 S= NOT Robot.bConnected;				//机械臂TCP未连接
	uliWarningId.2 S= Robot.bTcpError;					//机械臂TCP功能块错误
	uliWarningId.3 S= Robot.x_oStateErr;				//机械臂-报警
	uliWarningId.4 S= Robot.x_oCollide;					//机械臂-碰撞
	uliWarningId.5 S= Robot.x_oStateStopping;			//机械臂-停止运行
	uliWarningId.6 S= NOT Robot.x_oStateElectrify;		//机械臂-未上电
	uliWarningId.7 S= NOT Robot.x_oStatePower;			//机械臂-未使能
	uliWarningId.8 S= NOT Robot.x_oStateRunning;		//未运行
	uliWarningId.9 S= Robot.rGlobInitStatus <> 4;		//未初始化
	
	
	IF uliWarningId<>0 AND eState = Robot_STATE.RobotAct THEN
		Glob_ModbusTcpServer.Robot_wTaskState := 5;
		eState := Robot_STATE.STOP;
	ELSIF uliWarningId<>0 AND eState = Robot_STATE.AUTO THEN
		eState := Robot_STATE.STOP;
	END_IF
	
	
	
END_IF

(*复位按钮*)
rTrig_Reset(CLK :=  bResetBtn);
IF rTrig_Reset.Q THEN
	uliWarningId := 0;
END_IF
END_ACTION

ACTION ACT_11_bMannual:
CASE iMannualStep OF
	0:
		IF bMannualStart THEN
			iMannualStep := 10;
		END_IF
		
	10:
		Robot.xExcuteAct := TRUE;
		iMannualStep := 20;
		
	20:
		IF NOT Robot.xExcuteAct AND  Robot.rAct_Status = 1 THEN	
			iMannualStep := 50;
		END_IF
		
	50:	
		//清空触发机器人动作
		Robot.wExecute_Act := 0;
		Robot.xExcuteAct := TRUE;
		iMannualStep := 60;
		
	60:
		IF NOT Robot.xExcuteAct THEN
			iMannualStep := 1000;
		END_IF
		
	1000:
		bMannualStart := FALSE;
		iMannualStep := 0;
END_CASE
END_ACTION
