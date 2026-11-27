//X维持设定的初始值，直到指定时间结束，取反。
//若中途取消动作，X保持设定的初始值。
FUNCTION_BLOCK FB_DelayInvert
VAR_IN_OUT
	X							: BOOL;
END_VAR


VAR_INPUT
	bStart						: BOOL;
	bStop						: BOOL;
	
	bInitValue					: BOOL;//初始值
	tDelay						: TIME:=T#1S;
	
END_VAR


VAR_OUTPUT
END_VAR

VAR
	timer						: TON;
	R_TRIG_Start				: R_TRIG;
	R_TRIG_Stop					: R_TRIG;
	
END_VAR
// --- implementation ---
//定时器FB块
timer();


//启动
R_TRIG_Start(CLK:=bStart);
IF R_TRIG_Start.Q THEN
	X := bInitValue;
	timer.PT := tDelay;
	timer.IN := TRUE;
	bStart := FALSE;
END_IF


//定时器计时中（触发动作），中途取消动作，X维持初始值
R_TRIG_Stop(CLK:=bStop);
IF R_TRIG_Stop.Q AND timer.IN THEN
	X := bInitValue;
	timer.IN := FALSE;
END_IF



//时间到，取反
IF timer.Q THEN
	X := NOT X;
	timer.IN := FALSE;
END_IF
END_FUNCTION_BLOCK
