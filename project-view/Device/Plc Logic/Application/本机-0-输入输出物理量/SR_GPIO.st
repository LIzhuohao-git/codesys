PROGRAM SR_GPIO
VAR
	rtrigPause					:Standard.R_TRIG;
	ftrigPause					:Standard.F_TRIG;
	rtrigReset					:Standard.R_TRIG;
	rtrigFuntion				:Standard.R_TRIG;	
END_VAR
// --- implementation ---
//按钮触发
rtrigPause(CLK:= GPI.xPauseButton, Q=> GPI_Logic.xPause);
ftrigPause(CLK:= GPI.xPauseButton, Q=> GPI_Logic.xContinue);
rtrigReset(CLK:= GPI.xResetButton, Q=> GPI_Logic.xReset);
rtrigFuntion(CLK:= GPI.xFuntionButton, Q=> GPI_Logic.xFuntion);

//传感器滤波处理
GPI_Logic.xLocalRackPos1:=GPI.xLocalRackPos1;
GPI_Logic.xLocalRackPos2:=GPI.xLocalRackPos2;
GPI_Logic.xLocalRackPos3:=GPI.xLocalRackPos3;
GPI_Logic.xLocalRackPos4:=GPI.xLocalRackPos4;
END_PROGRAM
