//将字符串数组[0..199]中每个元素合并，以'$R$N'连接，并写入文件
FUNCTION FUN_WriteFileArray : STRING
VAR_INPUT
	FilePath						: STRING;
	asParaNum						: ARRAY[0..GlobFile.iParaLen] OF STRING;
END_VAR


VAR
	uniLogPara						: uniLogPara;//写入文件的字符串
	i								: UINT;
	sTmp							: STRING(GlobFile.iStringLen);
	
	
	FileHandle						: RTS_IEC_HANDLE;
	ResError1						: RTS_IEC_RESULT;
	ResError2						: RTS_IEC_RESULT;
	ResError3						: RTS_IEC_RESULT;
	
END_VAR



VAR CONSTANT
	sConnect						: STRING:='$R$N';
// 	sStart							: STRING(GlobFile.iStringLen):='^$R$N';
// 	sFinal							: STRING:='#';
END_VAR
// --- implementation ---
(**************************************************************
数组元素合并
例如：
asParaNum[0] := '123';			asParaNum[1] := '456';

输出：
sParaWtrie => '123$R$N456';

***************************************************************)






(*****************	处理字符串，使之与上面注释描述连接	**********************)

FOR i := 0 TO TO_UINT(GlobFile.iParaLen) DO
	
	//如果这个数据是空数据，就跳出循环，不连接空数据
	IF asParaNum[i] = '' THEN//GlobFile.sNullPara THEN
		EXIT;
	END_IF

	
	//连接字符串
	IF i = 0 THEN
		uniLogPara.sLog := CONCAT(STR1:=GlobFile.sStartCharacter , STR2:=asParaNum[i] );//最前面加个'^$R$N'作起始符号
		StrConcatA(pstFrom:=ADR(sConnect) , pstTo:=ADR(uniLogPara.sLog) , iBufferSize:=TO_INT(SIZEOF(uniLogPara.sLog)) );
	ELSE
		StrConcatA(pstFrom:=ADR(asParaNum[i]) , pstTo:=ADR(uniLogPara.sLog) , iBufferSize:=TO_INT(SIZEOF(uniLogPara.sLog)) );
		StrConcatA(pstFrom:=ADR(sConnect) , pstTo:=ADR(uniLogPara.sLog) , iBufferSize:=TO_INT(SIZEOF(uniLogPara.sLog)) );
		
	END_IF
	
END_FOR

//最后加个'#'作结束符号
StrConcatA(pstFrom:=ADR(GlobFile.sTerminator) , pstTo:=ADR(uniLogPara.sLog) , iBufferSize:=TO_INT(SIZEOF(uniLogPara.sLog)) );


(***********************************************************************************************)










//为了避免写入数据长度出错的问题，先删除文件，再写入
// SysFileDeleteByHandle(hFile:=FileHandle );
SM3_Basic.SysFileDelete(szFileName:=FilePath );

//打开文件
FileHandle:= SysFileOpen(szFile:= FilePath, am:= ACCESS_MODE.AM_WRITE_PLUS, pResult:= ADR(ResError1));

//设置写入的偏移位置，每次都从第一个位置开始复写
// SysFileSetPos(hFile:= FileHandle, ulOffset:=SysFileGetSize(szFileName:= FilePath, pResult:= ADR(ResError2)) );

//写入数据
SM3_Basic.SysFileWrite(hFile:= FileHandle, pbyBuffer:= ADR(uniLogPara.abyLog), ulSize:= TO_LWORD(StrLenA(pstData:=ADR(uniLogPara.sLog)) ), pResult:= ADR(ResError3));

//关闭文件
SysFileClose(hFile:= FileHandle);
END_FUNCTION
