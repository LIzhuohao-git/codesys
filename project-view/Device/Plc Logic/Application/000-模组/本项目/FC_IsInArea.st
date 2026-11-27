FUNCTION FC_IsInArea : BOOL
VAR_INPUT
	LR_Pos							: REAL;//当前左右位置
	UD_Pos							: REAL;//当前上下位置
	
	LeftLimit						: REAL;//左边限位，LR_Pos要大于等于此变量
	RightLimit						: REAL;//右边限位，LR_Pos要小于等于此变量
	UpLimit							: REAL;//上边限位，UD_Pos要小于等于此变量
	DownLimit						: REAL;//下边限位，UD_Pos要大于等于此变量
END_VAR
VAR
END_VAR
// --- implementation ---
//判断是否在此平面范围内

IF (LeftLimit <= LR_Pos AND LR_Pos <= RightLimit) AND
	(DownLimit <= UD_Pos AND UD_Pos <= UpLimit) THEN
	
	FC_IsInArea := TRUE;
ELSE
	FC_IsInArea := FALSE;
END_IF
END_FUNCTION
