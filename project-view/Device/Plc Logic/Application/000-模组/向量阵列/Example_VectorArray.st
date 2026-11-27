PROGRAM Example_VectorArray
VAR
	//向量阵列
	FB_50Array					: FB_VectorArray;					//50ml盘架
	FB_15Array					: FB_VectorArray;					//15ml盘架
	FB_15analArray				: FB_VectorArrayWithShield;			//15anal盘架

	auiShield					: ARRAY[0..19] OF UINT:=[4,6];//屏蔽编号，举例：4号和6号数学工位屏蔽

	
	
	
	
	//50ml试管盘架的单位向量（机械工位偏移）
	rRank50_X							: SMC_VECTOR3D:=(dX:=41,dY:=0,dZ:=0);
	rRank50_Y							: SMC_VECTOR3D:=(dX:=0,dY:=41,dZ:=0);
	
	
	
	//示教变量	[1..3]-->[原点坐标，X轴末端坐标，Y轴末端坐标]
	Pos_50								: ARRAY[1..3] OF SMC_VECTOR3D;//50ml示教试管管架位置
	Pos_15								: ARRAY[1..3] OF SMC_VECTOR3D;//15ml示教试管管架位置
	Pos_15anal							: ARRAY[1..3] OF SMC_VECTOR3D;//15ml示教分析试管管架位置
	
	
	
	bSetPosPara							: BOOL;//触发改写阵列数据
	
	bGetPosByNum						: BOOL;//获取位置触发--序号
	bGetPosByCoor						: BOOL;//获取位置触发--坐标
	uiNum								: UINT:=4;//序号
	GetPos_50							: SMC_VECTOR3D;//50ml目标试管管架位置
	GetPos_15							: SMC_VECTOR3D;//15ml目标试管管架位置
	GetPos_15anal						: SMC_VECTOR3D;//15ml目标分析试管管架位置
	
	
	bError								: BOOL;//FB阵列报错（如：获取参数有误）
	
END_VAR
// --- implementation ---
FB_50Array();
FB_15Array();
FB_15analArray(auiShield:= auiShield);


//设置阵列参数
IF bSetPosPara THEN
	bSetPosPara := FALSE;
	//uiColumn_X:= 6,uiRow_Y:= 10	意为6列10行，共60个工位
	
	//单点示教偏移
	FB_50Array.METH_SetParaByUnitVector(
		Vector_O:= Pos_50[1], 
		UnitVector_X:= rRank50_X, 
		UnitVector_Y:= rRank50_Y, 
		uiColumn_X:= 6, 
		uiRow_Y:= 10);
		
	//对角线示教，只能是矩形
	FB_15Array.METH_SetParaWithDiagonalRectangle(
		Vector_O:= Pos_15[1], 
		Vector_E:= Pos_15[2], 
		uiColumn_X:= 6, 
		uiRow_Y:= 10);
		
	//三点示教	
	FB_15analArray.METH_SetPara(
		Vector_O:= Pos_15anal[1], 
		Vector_X:= Pos_15anal[2], 
		Vector_Y:= Pos_15anal[3], 
		uiColumn_X:= 6, 
		uiRow_Y:= 10);

	
END_IF






//根据序号获取位置坐标
IF bGetPosByNum THEN
	bGetPosByNum := FALSE;
	
	GetPos_50 := FB_50Array.METH_GetPosByPoint(uiNum:= uiNum);
	GetPos_15 := FB_15Array.METH_GetPosByPoint(uiNum:= uiNum);
	
	//15anal的4号工位被屏蔽，所以返回5号工位坐标，即返回真正使用的工位坐标
	GetPos_15anal := FB_15analArray.METH_GetPosByPoint(uiNum:= uiNum);
	
END_IF



//根据坐标获取位置坐标，坐标从(0,0)开始
IF bGetPosByCoor THEN
	bGetPosByCoor := FALSE;
	
	//(uiColumn_X:=4 , uiRow_Y:=0)，意为第4列第1行
	
	GetPos_50 := FB_50Array.METH_GetPosByCoordinate(uiColumn_X:=4 , uiRow_Y:=0);
	GetPos_15 := FB_15Array.METH_GetPosByCoordinate(uiColumn_X:=4 , uiRow_Y:=0);
	
	//15anal的获取坐标是4号屏蔽位，会立刻报错
	GetPos_15anal := FB_15analArray.METH_GetPosByCoordinate(uiColumn_X:=3 , uiRow_Y:=0);
	
END_IF






//报错
bError := FB_50Array.iErrorCode<>0 OR FB_15Array.iErrorCode<>0 OR FB_15analArray.iErrorCode<>0;
END_PROGRAM
