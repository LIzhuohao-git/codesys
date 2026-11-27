PROGRAM Main_PRG
VAR
	dtResult 				: RTS_IEC_RESULT;	//UTC

END_VAR
// --- implementation ---
ACT_01_Moddle();

ACT_02_State();

Test_PRG();
END_PROGRAM

ACTION ACT_01_Moddle:
(*获取UTC时间，示例'2024-02-19-14:30:18'*)
Glob.strUTC:=Standard.DELETE(TO_STRING(TO_DT(Sm3_basic.SysTimeRtcGet(dtResult))),3,1);


SR_GPIO();


Robot_PRG(
	Robot:= Glob.Robot, 
	bInitBtn:= , 
	bStartBtn:= , 
	bPauseBtn:= Glob.bPausing, 
	bStopBtn:= , 
	bResetBtn:= , 
	bAutoMode:= , 
	uWorkStation:= , 
	uRackType:= , 
	uDeviceRackPos:= , 
	uChassisRackPos:= , 
	wTaskID:= , 
	wTaskNum:= );
END_ACTION

ACTION ACT_02_State:
IF Glob_ModbusTcpServer.Robot_A_xTaskStart THEN
	Glob_ModbusTcpServer.Robot_A_xTaskStart := FALSE;
	Glob_ModbusTcpServer.Robot_wTaskState := 1;
	
	Robot_PRG.uWorkStation := Glob_ModbusTcpServer.Robot_A_wWorkStation;
	Robot_PRG.uRackType := Glob_ModbusTcpServer.Robot_A_wRackType;
	Robot_PRG.uDeviceRackPos := Glob_ModbusTcpServer.Robot_A_wDeviceRackPos;
	Robot_PRG.uChassisRackPos := Glob_ModbusTcpServer.Robot_A_wChassisRackPos;
	Robot_PRG.wTaskID := Glob_ModbusTcpServer.Robot_A_wTaskID;
	Robot_PRG.wTaskNum := Glob_ModbusTcpServer.Robot_A_wTaskNum;
	Robot_PRG.bStart := TRUE;
	
END_IF



//机械臂任务反馈
Glob_ModbusTcpServer.Robot_wTaskID := Robot_PRG.wTaskID;
//Glob_ModbusTcpServer.Robot_wTaskState :=Robot_PRG.wTaskState;

//条件判断
IF NOT Robot_PRG.bAutoRunning THEN
	Glob_ModbusTcpServer.xAllowRunning_Chassis := FALSE;
	Glob_ModbusTcpServer.xAllowRunning_Robot := FALSE;
END_IF

Glob_ModbusTcpServer.xAllowRunning_Robot := Robot_PRG.bAutoRunning AND Robot_PRG.uliWarningId = 0 
							AND Glob.Robot.RobotBusy = 0 AND Glob.Chassis_Car.bConnected;


Glob_ModbusTcpServer.xAllowRunning_Chassis := Glob_ModbusTcpServer.xAllowRunning_Robot;
END_ACTION
