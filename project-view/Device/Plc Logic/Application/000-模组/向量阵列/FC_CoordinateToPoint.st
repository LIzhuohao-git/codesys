//输入从(0,0)开始的坐标，返回从X轴数过去且从1开始的序号。
//输入设定的行数与列数均大于0；
//函数返回值>0，计算无误；返回值=0，输入数据错误。
FUNCTION FC_CoordinateToPoint : UINT
VAR_INPUT
	uiCoordinate_X					: UINT;//X轴坐标
	uiCoordinate_Y					: UINT;//Y轴坐标
	uiColumn_X						: UINT;//X轴方向工位数/列数 
	uiRow_Y							: UINT;//Y轴方向工位数/行数 
END_VAR


VAR
	i								: UINT;

END_VAR
// --- implementation ---
IF uiColumn_X=0 OR uiRow_Y=0 OR uiCoordinate_X>=uiColumn_X OR uiCoordinate_Y>=uiRow_Y THEN
	FC_CoordinateToPoint := 0;
	RETURN;
END_IF




IF uiColumn_X = 1 THEN	//只有从Y轴方向延伸的一列
	FC_CoordinateToPoint := uiCoordinate_Y + 1;

	
ELSE	//只有从X轴方向延伸的一行，或者是有行有列
	i := uiCoordinate_Y * uiColumn_X;					//算出已填满的行有多少个
	i := i + uiCoordinate_X;							//再算出未填满的那一行，有多少个
	FC_CoordinateToPoint := i + 1;						//因为输出的序号要从1开始，加补偿
	
END_IF
END_FUNCTION
