(*检测复位按钮状态-单击、双击、长按*)
FUNCTION_BLOCK FB_ButtonCheck
VAR_INPUT
	bEnable:BOOL;
	bButton:BOOL;
END_VAR
VAR_OUTPUT
	bSingleClick:BOOL;
	bDoubleClick:BOOL;
	bLongClick:BOOL;
END_VAR
VAR
	iState			:INT;
	R_TRIG			:R_TRIG;				//停止上升沿
	tTimer			:TON;
END_VAR
// --- implementation ---
R_TRIG(CLK:= bButton);
IF bEnable THEN
	CASE iState OF
	0:
		IF R_TRIG.Q THEN
			bSingleClick:=FALSE;
			bDoubleClick:=FALSE;
			bLongClick:=FALSE;
			iState:=10;
		END_IF
		
	10:
		tTimer(IN:= bButton, PT:= T#1000MS);
		IF tTimer.Q THEN
			iState:=300;
			tTimer(IN:= FALSE);
		END_IF
		IF NOT bButton THEN
			iState:=20;
			tTimer(IN:= FALSE);
		END_IF
		
	20:
		tTimer(IN:= TRUE, PT:= T#300MS);
		IF tTimer.Q THEN
			iState:=100;
			tTimer(IN:= FALSE);
		END_IF
		IF R_TRIG.Q THEN
			iState:=200;
			tTimer(IN:= FALSE);
		END_IF
		
	100:
		bSingleClick:=TRUE;
		iState:=0;
		
	200:
		bDoubleClick:=TRUE;
		iState:=0;	
		
	300:
		bLongClick:=TRUE;
		iState:=0;
		
	END_CASE
ELSE
	bSingleClick:=FALSE;
	bDoubleClick:=FALSE;
	bLongClick:=FALSE;
	iState:=0;
END_IF
END_FUNCTION_BLOCK
