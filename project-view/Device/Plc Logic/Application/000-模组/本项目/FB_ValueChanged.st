//监控变量的值是否发生改变
FUNCTION_BLOCK FB_ValueChanged 
VAR_INPUT
	pValue						: POINTER TO BYTE;
	uxiSize						: __UXINT;						
END_VAR

VAR_OUTPUT
	bHasChanged					: BOOL;//变量值发生改变，该输出变量保持一个周期 true
END_VAR


VAR
	bFirstScan					: BOOL;
	pOrigin						: POINTER TO BYTE;//记录变量上一个周期的值


END_VAR
// --- implementation ---
//初次上电，分配与 pValue 相同长度的内存
IF NOT bFirstScan THEN
	pOrigin := SM3_Basic.SysMemAllocData(szComponent:='pOrigin' , udiSize:=uxiSize , pResult:=0 );
	bFirstScan := TRUE;
END_IF

//比较内存值
IF 0 <> SM3_Basic.SysMemCmp(pBuffer1:=pOrigin , pBuffer2:=pValue , udiCount:=uxiSize ) THEN
	SM3_Basic.SysMemCpy(pDest:=pOrigin , pSrc:=pValue , udiCount:=uxiSize );//从指针层面，将新值复制到pOrigin
	bHasChanged := TRUE;
ELSE
	bHasChanged := FALSE;
END_IF
END_FUNCTION_BLOCK
