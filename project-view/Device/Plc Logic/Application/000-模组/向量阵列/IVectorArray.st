INTERFACE IVectorArray
END_INTERFACE

//三点示教设置阵列参数
METHOD METH_SetPara : BOOL
VAR_INPUT
	Vector_O						: SMC_VECTOR3D;//工位原点坐标
	Vector_X						: SMC_VECTOR3D;//工位X轴终点坐标
	Vector_Y						: SMC_VECTOR3D;//工位Y轴终点坐标
	
	uiColumn_X						: UINT;//X轴方向工位数/列数 
	uiRow_Y							: UINT;//Y轴方向工位数/行数 
END_VAR
END_METHOD

//直接输入单位向量设置阵列参数
//常用于单点示教阵列
METHOD METH_SetParaByUnitVector : BOOL
VAR_INPUT
	Vector_O						: SMC_VECTOR3D;//工位原点坐标
	UnitVector_X					: SMC_VECTOR3D;//X轴方向的单位向量
	UnitVector_Y					: SMC_VECTOR3D;//Y轴方向的单位向量
	
	uiColumn_X						: UINT;//X轴方向工位数/列数 
	uiRow_Y							: UINT;//Y轴方向工位数/行数 
END_VAR
END_METHOD

//清除错误
METHOD METH_ClearError : BOOL
VAR_INPUT
END_VAR
END_METHOD

//通过行列坐标获取目标位置，坐标从(0,0)开始
METHOD METH_GetPosByCoordinate : SMC_VECTOR3D
VAR_INPUT
	uiColumn_X						: UINT;//X轴方向工位数/列数 
	uiRow_Y							: UINT;//Y轴方向工位数/行数 
END_VAR
END_METHOD

//可用的阵列总数
METHOD METH_Sum : UINT
VAR_INPUT
	uiColumn_X						: UINT;//X轴方向工位数/列数 
	uiRow_Y							: UINT;//Y轴方向工位数/行数 
END_VAR
END_METHOD

//对角线示教设置矩形阵列参数
//因只有对角线2个点，不能确定一个平行四边形，所以此函数默认阵列是矩形
METHOD METH_SetParaWithDiagonalRectangle: BOOL
VAR_INPUT
	Vector_O						: SMC_VECTOR3D;//工位原点坐标
	Vector_E						: SMC_VECTOR3D;//工位终点坐标/对角坐标
	
	uiColumn_X						: UINT;//X轴方向工位数/列数 
	uiRow_Y							: UINT;//Y轴方向工位数/行数 
END_VAR
END_METHOD

//通过大于0的序号获取目标位置
METHOD METH_GetPosByPoint : SMC_VECTOR3D
VAR_INPUT
	uiNum							: UINT;//整列序号
END_VAR
END_METHOD
