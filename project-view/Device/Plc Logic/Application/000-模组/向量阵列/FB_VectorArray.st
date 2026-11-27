//三维向量阵列
FUNCTION_BLOCK FB_VectorArray IMPLEMENTS IVectorArray
VAR_INPUT
END_VAR

VAR_OUTPUT
	uiSum							: UINT;//可用的阵列总数
	bHasInitPara					: BOOL;//标志位，已设置阵列参数
	iErrorCode						: INT;//错误码
END_VAR

VAR
	//点位
	Vector_O						: SMC_VECTOR3D;//工位原点坐标
	Vector_X						: SMC_VECTOR3D;//工位X轴终点坐标
	Vector_Y						: SMC_VECTOR3D;//工位Y轴终点坐标
	
	//行列数
	uiColumn_X						: UINT;//X轴方向工位数/列数 
	uiRow_Y							: UINT;//Y轴方向工位数/行数 
	
	//单位向量
	UnitVector_X					: SMC_VECTOR3D;//X轴方向的单位向量
	UnitVector_Y					: SMC_VECTOR3D;//Y轴方向的单位向量
	                                  
	                                  
	Vector_Null						: SMC_VECTOR3D;//空向量
	
END_VAR
// --- implementation ---
(*第一次使用该FB块，先调用 METH_SetPara() 或 METH_SetParaByUnitVector() 设置内部参数*)



(**********************************************************************************************************
bHasInitPara -> TRUE
表示已设置好实例化该FB的参数。

若在此基础上，重新设置参数，即再次调用METH_SetPara的时候，参数设置错误，iErrorCode会报错为1。
但是原本的阵列参数保持原来参数，不会改变



iErrorCode:
0	->	无错误
1	->	行列参数设置错误
2	->	该阵列工位还没有行列参数设置
3	->	行列索引超出原本设置的参数
4	->	行列坐标是屏蔽位置


***********************************************************************************************************)
END_FUNCTION_BLOCK

(*清除错误*)
METHOD METH_ClearError : BOOL
// --- implementation ---
iErrorCode := 0;
END_METHOD

(*通过行列坐标获取目标位置，坐标从(0,0)开始*)
METHOD METH_GetPosByCoordinate : SMC_VECTOR3D
VAR_INPUT
	(*X轴方向工位数/列数 *)
	uiColumn_X						: UINT;
	(*Y轴方向工位数/行数 *)
	uiRow_Y							: UINT;
END_VAR

VAR
	tmpVector_X						: SMC_VECTOR3D;
	tmpVector_Y						: SMC_VECTOR3D;
	tmpVector_T						: SMC_VECTOR3D;
	tmpVector_Null					: SMC_VECTOR3D;
	
END_VAR
// --- implementation ---
iErrorCode := 0;

//没有设置阵列参数
IF NOT bHasInitPara THEN
	iErrorCode := 2;
	RETURN;
END_IF


//行列索引超出原本设置的参数
IF uiColumn_X > THIS^.uiColumn_X OR uiRow_Y > THIS^.uiRow_Y THEN
	iErrorCode := 3;
	RETURN;
END_IF



(****	根据行列点位，偏移单位向量，得出目标点位。从(0,0)开始	****)
IF uiColumn_X > 0 THEN
	//从原点偏移uiColumn_X个单位向量X
	SMC_V3_Mult(vDst:=tmpVector_X , vSrc:=UnitVector_X , d:=TO_LREAL(uiColumn_X) );
ELSE
	tmpVector_X := tmpVector_Null;
END_IF


IF uiRow_Y > 0 THEN
	//从原点偏移uiRow_Y个单位向量Y
	SMC_V3_Mult(vDst:=tmpVector_Y , vSrc:=UnitVector_Y , d:=TO_LREAL(uiRow_Y) );
ELSE
	tmpVector_Y := tmpVector_Null;
END_IF



SMC_V3_Add(vDst:=tmpVector_T , vLhs:=THIS^.Vector_O , vRhs:=tmpVector_X );
SMC_V3_Add(vDst:=tmpVector_T , vLhs:=tmpVector_T , vRhs:=tmpVector_Y );
METH_GetPosByCoordinate := tmpVector_T;
END_METHOD

(*通过大于0的序号获取目标位置*)
METHOD METH_GetPosByPoint : SMC_VECTOR3D
VAR_INPUT
	(*整列序号*)
	uiNum							: UINT;
END_VAR

VAR
	uiColumn_X						: UINT;
	uiRow_Y							: UINT;

	tmpVector_X						: SMC_VECTOR3D;
	tmpVector_Y						: SMC_VECTOR3D;
	tmpVector_T						: SMC_VECTOR3D;
	tmpVector_Null					: SMC_VECTOR3D;
	
	bFC_Done						: BOOL;
END_VAR
// --- implementation ---
iErrorCode := 0;

//没有设置阵列参数
IF NOT bHasInitPara THEN
	iErrorCode := 2;
	RETURN;
END_IF


//行列索引超出原本设置的参数
IF uiNum = 0 THEN
	iErrorCode := 3;
	RETURN;
END_IF



//序号转换成从(0,0)开始的坐标
bFC_Done := FC_PointToCoordinate(
				uiTargetPoint:=uiNum , 
				uiColumn_X:=THIS^.uiColumn_X , 
				uiRow_Y:=THIS^.uiRow_Y , 
				Coordinate_X=>uiColumn_X , 
				Coordinate_Y=>uiRow_Y );

IF NOT bFC_Done THEN//序号转换坐标失败，常见于uiNum值大于总阵列数
	iErrorCode := 3;
	RETURN;
END_IF
		
				
				
				

(****	根据行列点位，偏移单位向量，得出目标点位。从(0,0)开始	****)
IF uiColumn_X > 0 THEN
	//从原点偏移uiColumn_X个单位向量X
	SMC_V3_Mult(vDst:=tmpVector_X , vSrc:=UnitVector_X , d:=TO_LREAL(uiColumn_X) );
ELSE
	tmpVector_X := tmpVector_Null;
END_IF


IF uiRow_Y > 0 THEN
	//从原点偏移uiRow_Y个单位向量Y
	SMC_V3_Mult(vDst:=tmpVector_Y , vSrc:=UnitVector_Y , d:=TO_LREAL(uiRow_Y) );
ELSE
	tmpVector_Y := tmpVector_Null;
END_IF



SMC_V3_Add(vDst:=tmpVector_T , vLhs:=THIS^.Vector_O , vRhs:=tmpVector_X );
SMC_V3_Add(vDst:=tmpVector_T , vLhs:=tmpVector_T , vRhs:=tmpVector_Y );
METH_GetPosByPoint := tmpVector_T;
END_METHOD

(*三点示教设置阵列参数*)
METHOD METH_SetPara : BOOL
VAR_INPUT
	(*工位原点坐标*)
	Vector_O						: SMC_VECTOR3D;
	(*工位X轴终点坐标*)
	Vector_X						: SMC_VECTOR3D;
	(*工位Y轴终点坐标*)
	Vector_Y						: SMC_VECTOR3D;
	(*X轴方向工位数/列数 *)
	uiColumn_X						: UINT;
	(*Y轴方向工位数/行数 *)
	uiRow_Y							: UINT;
END_VAR

VAR
	//行列向量
	Vector_Xline					: SMC_VECTOR3D;
	Vector_Yline					: SMC_VECTOR3D;
	
END_VAR
// --- implementation ---
iErrorCode := 0;

(*行列数都是0，不是阵列，参数设置有误*)
IF uiColumn_X = 0 OR uiRow_Y = 0 THEN
	iErrorCode := 1;
	RETURN;
END_IF



(*向量相减，计算行列向量*)
SMC_V3_Sub(vDst:=Vector_Xline , vLhs:=Vector_X , vRhs:=Vector_O );
SMC_V3_Sub(vDst:=Vector_Yline , vLhs:=Vector_Y , vRhs:=Vector_O );



(****	
根据行列数量，计算行列的单位向量
(uiColumn_X-1)和(uiRow_Y-1)都要减1，是因为这里算的是位置之间的间距数量，不是位置本身的数量
****)
IF uiColumn_X > 1 THEN
	SMC_V3_Mult(vDst:=UnitVector_X , vSrc:=Vector_Xline , d:=1 / TO_LREAL(uiColumn_X-1) );
ELSE
	UnitVector_X := Vector_Null;
END_IF

IF uiRow_Y > 1 THEN
	SMC_V3_Mult(vDst:=UnitVector_Y , vSrc:=Vector_Yline , d:=1 / TO_LREAL(uiRow_Y-1) );
ELSE
	UnitVector_Y := Vector_Null;
END_IF


(****	Meth形参赋值给FB实参	****)
THIS^.Vector_O := Vector_O;
THIS^.Vector_X := Vector_X;
THIS^.Vector_Y := Vector_Y;
THIS^.uiColumn_X := uiColumn_X;
THIS^.uiRow_Y := uiRow_Y;
uiSum := METH_Sum(uiColumn_X:=uiColumn_X , uiRow_Y:=uiRow_Y );//计算可用的阵列总数
bHasInitPara := TRUE;//标志位置true，已设置该FB阵列参数



METH_SetPara := TRUE;
END_METHOD

(*直接输入单位向量设置阵列参数
常用于单点示教阵列*)
METHOD METH_SetParaByUnitVector : BOOL
VAR_INPUT
	(*工位原点坐标*)
	Vector_O						: SMC_VECTOR3D;
	(*X轴方向的单位向量*)
	UnitVector_X					: SMC_VECTOR3D;
	(*Y轴方向的单位向量*)
	UnitVector_Y					: SMC_VECTOR3D;
	(*X轴方向工位数/列数 *)
	uiColumn_X						: UINT;
	(*Y轴方向工位数/行数 *)
	uiRow_Y							: UINT;
END_VAR

VAR
	//行列向量
	Vector_Xline					: SMC_VECTOR3D;
	Vector_Yline					: SMC_VECTOR3D;
END_VAR
// --- implementation ---
iErrorCode := 0;

(*行列数都是0，不是阵列，参数设置有误*)
IF uiColumn_X = 0 OR uiRow_Y = 0 THEN
	iErrorCode := 1;
	RETURN;
END_IF



(****	Meth形参赋值给FB实参	****)
THIS^.Vector_O := Vector_O;
THIS^.UnitVector_X := UnitVector_X;
THIS^.UnitVector_Y := UnitVector_Y;
THIS^.uiColumn_X := uiColumn_X;
THIS^.uiRow_Y := uiRow_Y;
uiSum := METH_Sum(uiColumn_X:=uiColumn_X , uiRow_Y:=uiRow_Y );//计算可用的阵列总数
bHasInitPara := TRUE;//标志位置true，已设置该FB阵列参数



METH_SetParaByUnitVector := TRUE;
END_METHOD

(*对角线示教设置阵列参数*)
(*因只有对角线2个点，不能确定一个平行四边形，所以此函数默认阵列是矩形*)
METHOD METH_SetParaWithDiagonalRectangle: BOOL
VAR_INPUT
	Vector_O						: SMC_VECTOR3D;//工位原点坐标
	Vector_E						: SMC_VECTOR3D;//工位终点坐标/对角坐标（dZ不处理）
	
	uiColumn_X						: UINT;//X轴方向工位数/列数 
	uiRow_Y							: UINT;//Y轴方向工位数/行数 
END_VAR


VAR
	//行列向量
	Vector_Xline					: SMC_VECTOR3D;
	Vector_Yline					: SMC_VECTOR3D;


	//行列终点向量
	Vector_Xend						: SMC_VECTOR3D;
	Vector_Yend						: SMC_VECTOR3D;
	
	//待确认：两点只能决定线而不能决定一个平面，因此dZ统一取Vector_O.dZ*)
END_VAR
// --- implementation ---
iErrorCode := 0;

(*行列数都是0，不是阵列，参数设置有误*)
IF uiColumn_X = 0 OR uiRow_Y = 0 THEN
	iErrorCode := 1;
	RETURN;
END_IF




(*利用对角线计算行与列的终点向量*)
// Vector_Xend := Vector_O;
// Vector_Yend := Vector_O;
// 
// Vector_Xend.dX := Vector_E.dX;
// Vector_Yend.dY := Vector_E.dY;

Vector_Xend := Vector_E;
Vector_Xend.dY := Vector_O.dY;

Vector_Yend := Vector_E;
Vector_Yend.dX := Vector_O.dX;




(*向量相减，计算行列向量*)
SMC_V3_Sub(vDst:=Vector_Xline , vLhs:=Vector_Xend , vRhs:=Vector_O );
SMC_V3_Sub(vDst:=Vector_Yline , vLhs:=Vector_Yend , vRhs:=Vector_O );



(****	
根据行列数量，计算行列的单位向量
(uiColumn_X-1)和(uiRow_Y-1)都要减1，是因为这里算的是位置之间的间距数量，不是位置本身的数量
****)
IF uiColumn_X > 1 THEN
	SMC_V3_Mult(vDst:=UnitVector_X , vSrc:=Vector_Xline , d:=1 / TO_LREAL(uiColumn_X-1) );
ELSE
	UnitVector_X := Vector_Null;
END_IF

IF uiRow_Y > 1 THEN
	SMC_V3_Mult(vDst:=UnitVector_Y , vSrc:=Vector_Yline , d:=1 / TO_LREAL(uiRow_Y-1) );
ELSE
	UnitVector_Y := Vector_Null;
END_IF


(****	Meth形参赋值给FB实参	****)
THIS^.Vector_O := Vector_O;
THIS^.Vector_X := Vector_X;
THIS^.Vector_Y := Vector_Y;
THIS^.uiColumn_X := uiColumn_X;
THIS^.uiRow_Y := uiRow_Y;
uiSum := METH_Sum(uiColumn_X:=uiColumn_X , uiRow_Y:=uiRow_Y );//计算可用的阵列总数
bHasInitPara := TRUE;//标志位置true，已设置该FB阵列参数



METH_SetParaWithDiagonalRectangle := TRUE;
END_METHOD

(*可用的阵列总数*)
METHOD METH_Sum : UINT
VAR_INPUT
	(*X轴方向工位数/列数 *)
	uiColumn_X							: UINT;
	(*Y轴方向工位数/行数 *)
	uiRow_Y								: UINT;
END_VAR
// --- implementation ---
IF uiColumn_X=1 AND uiRow_Y=1 THEN
	METH_Sum := 1;
	
ELSIF uiColumn_X>1 AND uiRow_Y=1 THEN//只有列数（即只有1行）
	METH_Sum := uiColumn_X;
	
ELSIF uiColumn_X=1 AND uiRow_Y>1 THEN//只有行数（即只有1列）
	METH_Sum := uiRow_Y;
	
ELSIF uiColumn_X>1 AND uiRow_Y>1 THEN
	METH_Sum := uiColumn_X * uiRow_Y;
	
END_IF
END_METHOD
