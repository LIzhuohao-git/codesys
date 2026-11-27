FUNCTION_BLOCK FB_Overtime
VAR_INPUT
	bEnable						: BOOL;
	tTimeSet					: TIME:=T#1S;//定时时间
	iMode						: INT:=0;//超时后，0模式的bEnable变false，输出跟着变false；1模式的bEnable变false，输出不变，需要bReset复位。
	bReset						: BOOL;//上升沿将输出复位为false，仅1模式有效
END_VAR

VAR_OUTPUT
	bOvertime					: BOOL;
END_VAR

VAR
	tTimer						: TON;
	R_TRIG_1						: R_TRIG;
	R_TRIG_2						: R_TRIG;
END_VAR
// --- implementation ---
tTimer(IN:=bEnable , PT:= tTimeSet);
R_TRIG_1(CLK:=tTimer.Q);
R_TRIG_2(CLK:=bReset);


IF iMode = 0 THEN
	IF tTimer.Q THEN
		bOvertime:=TRUE;
	ELSE
		bOvertime:=FALSE;
	END_IF

	
ELSIF iMode = 1 THEN
	IF R_TRIG_1.Q THEN
		bOvertime:=TRUE;
	END_IF
	IF R_TRIG_2.Q THEN
		bOvertime:=false;
	END_IF
	
END_IF
END_FUNCTION_BLOCK
