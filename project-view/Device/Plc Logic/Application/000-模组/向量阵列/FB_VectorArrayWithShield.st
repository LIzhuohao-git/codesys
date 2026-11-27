{attribute 'enable_dynamic_creation'}
//三维向量阵列，编号可以屏蔽/跳过
FUNCTION_BLOCK FB_VectorArrayWithShield EXTENDS FB_VectorArray
VAR_IN_OUT
	auiShield							: ARRAY[0..19] OF UINT;//屏蔽编号
END_VAR

VAR_INPUT
END_VAR

VAR_OUTPUT
END_VAR

VAR
	uiShieldSum							: UINT;//被屏蔽的数量
	uiOriSum							: UINT;//此阵列的原始数量（含屏蔽）
	
	
END_VAR
// --- implementation ---
// //屏蔽数组没有外部变量传入引用
// IF auiShield = 0 THEN
// 	iErrorCode := 5;
// 	RETURN;
// END_IF
// 
// 
// diShield_Low := LOWER_BOUND(auiShield , 1);
// diShield_High := UPPER_BOUND(auiShield , 1);
// diShieldNum := ABS(diShield_High - diShield_Low);
// 
// 
// //第一次有效初始化 或 屏蔽数组发生改变
// IF NOT bFirstOn THEN
// 	bFirstOn := TRUE;
// END_IF


//auiShield_Sort := auiShield;
END_FUNCTION_BLOCK

(*通过大于0的序号获取目标位置*)
METHOD METH_GetPosByPoint : SMC_VECTOR3D
VAR_INPUT
	(*整列序号*)
	uiNum									: UINT;
END_VAR

VAR
	uiUsed									: DINT;//可使用的数量
	uiOffset								: UINT;//经过偏移的值（跳过屏蔽序号的实际序号）
	i										: UINT;
	
END_VAR
// --- implementation ---
//根据屏蔽编号计算偏移值
FOR i := 1 TO uiOriSum DO
	IF NOT METH_IsShield(i) THEN		//每次去屏蔽数组轮询，查看是否被屏蔽
		uiUsed := uiUsed + 1;			//该阵列无屏蔽，可以使用，则+1
		IF uiUsed = uiNum THEN			//uiUsed = uiNum，表示已到目标序号
			uiOffset := i;
			EXIT;
		END_IF
		
	END_IF
END_FOR


METH_GetPosByPoint := SUPER^.METH_GetPosByPoint(uiNum:= uiOffset);
END_METHOD

(*清除错误*)
METHOD METH_ClearError : BOOL
// --- implementation ---
SUPER^.METH_ClearError();
END_METHOD

(*通过行列坐标获取目标位置，坐标从(0,0)开始*)
METHOD METH_GetPosByCoordinate : SMC_VECTOR3D
VAR_INPUT
	(*X轴方向工位数/列数 *)
	uiColumn_X								: UINT;
	(*Y轴方向工位数/行数 *)                         
	uiRow_Y									: UINT;
END_VAR                                     
                                            
                                            
VAR                                         
	i										: DINT;
	uiNum									: UINT;
	
	
END_VAR
// --- implementation ---
//不考虑屏蔽位置，计算输入坐标在绝对阵列中的编号
uiNum := FC_CoordinateToPoint(
						uiCoordinate_X	:= uiColumn_X, 
						uiCoordinate_Y	:= uiRow_Y, 
						uiColumn_X		:= SUPER^.uiColumn_X, 
						uiRow_Y			:= SUPER^.uiRow_Y);


//查询屏蔽数组，若屏蔽数组的元素值有uiNum的值，则表示输入坐标是一个屏蔽位，报错返回
FOR i := LOWER_BOUND(auiShield , 1) TO UPPER_BOUND(auiShield , 1) DO
	IF auiShield[i]<>0 AND auiShield[i]=uiNum THEN
		iErrorCode := 4;
		RETURN;
	END_IF
	
END_FOR
						
						
						
//使用绝对阵列中的编号，调用父类方法 METH_GetPosByPoint （用标号获取坐标）
METH_GetPosByCoordinate := SUPER^.METH_GetPosByPoint(uiNum:= uiNum);
END_METHOD

//是否被屏蔽
METHOD METH_IsShield : BOOL
VAR_INPUT
	uiNum							: UINT;
END_VAR

VAR
	i								: DINT;
	
END_VAR
// --- implementation ---
FOR i := LOWER_BOUND(auiShield , 1) TO UPPER_BOUND(auiShield , 1) DO
	IF uiNum = auiShield[i] THEN
		METH_IsShield := TRUE;
		RETURN;
	END_IF
	
END_FOR
END_METHOD

(*三点示教设置阵列参数*)
METHOD METH_SetPara : BOOL
VAR_INPUT
	(*工位原点坐标*)
	Vector_O	: SMC_VECTOR3D;
	(*工位X轴终点坐标*)
	Vector_X	: SMC_VECTOR3D;
	(*工位Y轴终点坐标*)
	Vector_Y	: SMC_VECTOR3D;
	(*X轴方向工位数/列数 *)
	uiColumn_X	: UINT;
	(*Y轴方向工位数/行数 *)
	uiRow_Y		: UINT;
END_VAR
// --- implementation ---
METH_SetPara := SUPER^.METH_SetPara(
							Vector_O		:= Vector_O	, 
							Vector_X		:= Vector_X	, 
							Vector_Y		:= Vector_Y	, 
							uiColumn_X		:= uiColumn_X	, 
							uiRow_Y			:= uiRow_Y		);
	
//auiShield_Sort := auiShield;
//OSCAT_BASIC._ARRAY_SORT(PT:=ADR(auiShield_Sort) , SIZE:=SIZEOF(auiShield_Sort) );
uiSum := METH_Sum(uiColumn_X:=uiColumn_X , uiRow_Y:=uiRow_Y );//计算可用的阵列总数
END_METHOD

(*直接输入单位向量设置阵列参数
常用于单点示教阵列*)
METHOD METH_SetParaByUnitVector : BOOL
VAR_INPUT
	(*工位原点坐标*)
	Vector_O		: SMC_VECTOR3D;
	(*X轴方向的单位向量*)
	UnitVector_X	: SMC_VECTOR3D;
	(*Y轴方向的单位向量*)
	UnitVector_Y	: SMC_VECTOR3D;
	(*X轴方向工位数/列数 *)
	uiColumn_X	: UINT;
	(*Y轴方向工位数/行数 *)
	uiRow_Y	: UINT;
END_VAR
// --- implementation ---
METH_SetParaByUnitVector := SUPER^.METH_SetParaByUnitVector(
													Vector_O		:= Vector_O	, 
													UnitVector_X	:= UnitVector_X, 
													UnitVector_Y	:= UnitVector_Y, 
													uiColumn_X		:= uiColumn_X	, 
													uiRow_Y			:= uiRow_Y		);
													
//auiShield_Sort := auiShield;
//OSCAT_BASIC._ARRAY_SORT(PT:=ADR(auiShield_Sort) , SIZE:=SIZEOF(auiShield_Sort) );
uiSum := METH_Sum(uiColumn_X:=uiColumn_X , uiRow_Y:=uiRow_Y );//计算可用的阵列总数
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
	
	
END_VAR
// --- implementation ---
METH_SetParaWithDiagonalRectangle := SUPER^.METH_SetParaWithDiagonalRectangle(
												Vector_O	:= Vector_O	, 
												Vector_E	:= Vector_E	, 
												uiColumn_X	:= uiColumn_X	, 
												uiRow_Y		:= uiRow_Y		);
												
//auiShield_Sort := auiShield;
//OSCAT_BASIC._ARRAY_SORT(PT:=ADR(auiShield_Sort) , SIZE:=SIZEOF(auiShield_Sort) );
uiSum := METH_Sum(uiColumn_X:=uiColumn_X , uiRow_Y:=uiRow_Y );//计算可用的阵列总数
END_METHOD

(*可用的阵列总数*)
METHOD METH_Sum : UINT
VAR_INPUT
	(*X轴方向工位数/列数 *)
	uiColumn_X							: UINT;
	(*Y轴方向工位数/行数 *)
	uiRow_Y								: UINT;
END_VAR

VAR
	i,j									: DINT;
	
END_VAR
// --- implementation ---
//先算出不带屏蔽的原始数量
uiOriSum := SUPER^.METH_Sum(uiColumn_X:=uiColumn_X , uiRow_Y:=uiRow_Y);


//计算被屏蔽的数量
uiShieldSum := 0;
FOR i := LOWER_BOUND(auiShield , 1) TO UPPER_BOUND(auiShield , 1) DO
	IF auiShield[i] <> 0 THEN
		uiShieldSum := uiShieldSum + 1;
	END_IF
END_FOR


//计算可用阵列的总数
uiSum := 0;
FOR i := 1 TO uiOriSum DO
	IF NOT METH_IsShield( TO_UINT(i) ) THEN
		uiSum := uiSum + 1;
	END_IF
END_FOR




METH_Sum := uiSum;
END_METHOD
