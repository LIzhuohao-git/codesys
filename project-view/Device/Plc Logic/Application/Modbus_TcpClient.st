PROGRAM Modbus_TcpClient
VAR
	Car_addr						: ARRAY [0..3] OF BYTE := [192,168,1,20];
	Car_Port						: UINT := 502;
	                        		
	Robot_addr						: ARRAY [0..3] OF BYTE := [192,168,1,15];
	Robot_Port						: UINT := 502;
	
	timer_Start						: Standard.TON;

END_VAR
// --- implementation ---
//开机后等待3秒，再执行下方程序
timer_Start(IN:=TRUE , PT:=T#2S);
IF NOT timer_Start.Q THEN
	RETURN;
END_IF

ACT_Car();

ACT_Robot();
END_PROGRAM

ACTION ACT_Car:
Glob.Chassis_CarClient(
	xConnect:= Glob.Chassis_Car.bConnect, 
	xConnected=> Glob.Chassis_Car.bConnected, 
	aIPaddr:= Car_addr, 
	uiPort:= Car_Port );
	
	

ModTcp_Chassis_Car(
	Client:= Glob.Chassis_CarClient, 
	Chassis_Car:= Glob.Chassis_Car, 
	uiUnitId:= 1, 
	udiTimeOut:= , 
	udiReplyTimeout:= );
END_ACTION

ACTION ACT_Robot:
Glob.Robot_Client(
	xConnect:= Glob.Robot.bConnect, 
	xConnected=> Glob.Robot.bConnected, 
	aIPaddr:= Robot_addr, 
	uiPort:= Robot_Port );


Robot_ModbusClient(
	RobotMod:= Glob.Robot, 
	Client:= Glob.Robot_Client, 
	uiUnitId:= , 
	udiTimeOut:= , 
	udiReplyTimeout:= );
END_ACTION
