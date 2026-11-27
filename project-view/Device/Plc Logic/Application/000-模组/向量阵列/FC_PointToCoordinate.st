//输入大于0的序号和行列数，根据行列数转换为第一象限坐标，坐标从(0,0)开始。
//函数返回true表示计算无误；
//函数返回false表示输入数据错误，输出坐标固定为(0,0)。
FUNCTION FC_PointToCoordinate : BOOL
VAR_INPUT
	uiTargetPoint					: UINT;//目标序号
	uiColumn_X						: UINT;//X轴方向工位数/列数 
	uiRow_Y							: UINT;//Y轴方向工位数/行数 
END_VAR

VAR_OUTPUT
	Coordinate_X					: UINT;//X轴坐标
	Coordinate_Y					: UINT;//Y轴坐标
END_VAR

VAR
	i								: UINT;
	Rounding						: UINT;//整数部分
	Remainder						: UINT;//余数
	tmpCoordinate_X					: UINT;//X轴坐标
	tmpCoordinate_Y					: UINT;//Y轴坐标
END_VAR
// --- implementation ---
IF uiColumn_X=0 OR uiRow_Y=0 OR uiTargetPoint=0 OR uiTargetPoint>uiColumn_X*uiRow_Y THEN
	RETURN;
END_IF



(****	下面算法适用于坐标从(1,1)开始，后面要转化	****)
Rounding := uiTargetPoint / uiColumn_X;//行序号
Remainder := uiTargetPoint MOD uiColumn_X;//最终停留的所在列序号



(*转化成从(0,0)开始的坐标*)
IF Remainder > 0 THEN	//有余数，表示下一行还有计算
	tmpCoordinate_X := Remainder - 1;
	tmpCoordinate_Y := Rounding;//本来行数+1，但转化成从(0,0)开始的坐标，所以不需要
	
ELSE					//没有余数，表示停留在最后一行的最后一列
	tmpCoordinate_X := uiColumn_X - 1;
	tmpCoordinate_Y := Rounding - 1;
	
END_IF




(*输出结果*)
Coordinate_X := tmpCoordinate_X;
Coordinate_Y := tmpCoordinate_Y;

FC_PointToCoordinate := TRUE;
END_FUNCTION
