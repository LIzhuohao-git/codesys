//{attribute 'qualified_only'}
VAR_GLOBAL
	bRunning												: BOOL;								//设备运行标志位
	bPausing												: BOOL;								//设备暂停标志位
	bStopping												: BOOL;								//设备停止标志位,True为急停状态
	bWarning												: BOOL;								//设备报警标志位
	bError													: BOOL;								//设备故障标志位
	bInitializing											: BOOL;								//设备初始化标志位
	bInitFinished											: BOOL;								//设备初始化完成标志位
	bReset													: BOOL;								//复位
	bCancelPause											: BOOL;								//取消暂停，触发模组的bStartBtn
	
	strUTC													: STRING;				//UTC时间，示例'2024-02-19-14:30:18'
	
	Robot													: ST_ROBOT_MODULE;
	Robot_Client											: ModbusFB.ClientTCP;
	
	Chassis_Car												: ST_Chassis_Car;
	Chassis_CarClient										: ModbusFB.ClientTCP;
END_VAR
