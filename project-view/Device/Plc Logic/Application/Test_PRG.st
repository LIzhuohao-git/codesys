PROGRAM Test_PRG
VAR
	istate					:UINT;
	bstart					:BOOL;
END_VAR
// --- implementation ---
CASE istate OF
	0:
		IF bstart	THEN
			istate := 10;
		END_IF
		
		
	10:
		Robot_PRG.uWorkStation := 1;
		Robot_PRG.uRackType := 1;
		Robot_PRG.uDeviceRackPos := 1;
		Robot_PRG.uChassisRackPos := 1;
		Robot_PRG.wTaskID := 1;
		Robot_PRG.wTaskNum := 1;
		Robot_PRG.bStart := TRUE;
		istate := 20;
		
	20:
		IF Robot_PRG.bBusy AND Glob_ModbusTcpServer.Robot_wTaskState = 1 THEN
			istate := 25;
		END_IF
		
	25:
		IF NOT Robot_PRG.bBusy  AND NOT Robot_PRG.bStart AND Glob_ModbusTcpServer.Robot_wTaskState = 3 THEN
			istate := 30;
		END_IF
		
	30:
		Robot_PRG.uWorkStation := 1;
		Robot_PRG.uRackType := 1;
		Robot_PRG.uDeviceRackPos := 1;
		Robot_PRG.uChassisRackPos := 1;
		Robot_PRG.wTaskID := 1;
		Robot_PRG.wTaskNum := 2;
		Robot_PRG.bStart := TRUE;
		istate := 50;
		
	50:
		IF Robot_PRG.bBusy AND Glob_ModbusTcpServer.Robot_wTaskState = 1 THEN
			istate := 60;
		END_IF
		
	60:
		IF NOT Robot_PRG.bBusy  AND NOT Robot_PRG.bStart AND Glob_ModbusTcpServer.Robot_wTaskState = 3 THEN
			istate := 0;
		END_IF
		
END_CASE
END_PROGRAM
