//读取文件，将字符串里的数据分成数组[0..199]
//数据完整返回'OK'，否则返回'NG'
FUNCTION FUN_ReadFileArray : STRING
VAR_INPUT
	FilePath						: STRING;
END_VAR

VAR_OUTPUT
	sReceData						: STRING(GlobFile.iStringLen);				//读取的字符串(无处理)
	asParaNum						: ARRAY[0..GlobFile.iParaLen] OF STRING;	//读取分割后的数据字符串数组
	arNum							: ARRAY[0..GlobFile.iParaLen] OF REAL;		//读取的数据
END_VAR




VAR
	i								: UINT;
	uniLogPara						: uniLogPara;
	
	FileHandle						: RTS_IEC_HANDLE;
	ResError1						: RTS_IEC_RESULT;
	ResError2						: RTS_IEC_RESULT;
	ResError3						: RTS_IEC_RESULT;
	
	
	sIsComplete						: STRING;//字符串是否完整
	iFind							: ARRAY[0..1] OF INT;
	asTmp							: ARRAY[0..GlobFile.iParaLen] OF STRING;

END_VAR



VAR CONSTANT
	sConnect						: STRING:='$R$N';
	
END_VAR
// --- implementation ---
(**************************************************************
例如：
sReceData := '123$R$N456';

输出：
arNum[0] => 123;			arNum[1] => 456;

***************************************************************)




// //清除数据		
// sReceData := '';
// FOR i:=0 TO GlobFile.iParaLen DO
// 	arNum[i] := 0;
// END_FOR




//打开文件
FileHandle:= SysFileOpen(szFile:= FilePath, am:= ACCESS_MODE.AM_READ_PLUS, pResult:= ADR(ResError1));
	
//读取数据
SysFileRead(hFile:= FileHandle, pbyBuffer:= ADR(uniLogPara.abyLog[0]), ulSize:=SIZEOF(uniLogPara.abyLog), pResult:=ADR(ResError2));

//关闭文件
SysFileClose(hFile:= FileHandle);
	

sReceData := uniLogPara.sLog;







(*********************************		处理字符串		*********************************)

//检查字符串是否完整
sIsComplete := FUN_CheckString(RcvStr:=uniLogPara.sLog , StartStr:=GlobFile.sStartCharacter , EndStr:=GlobFile.sTerminator , xFromStr=>uniLogPara.sLog );



IF sIsComplete = 'OK' THEN	//数据完整
	
	//将字符串分割成字符串数组
	FUN_CutString(sString:=uniLogPara.sLog , sStartCharacter:='/' , sTerminator:=';' , asParaNum=>asParaNum );

	//提取字符串数组' := '后面的数据
	FOR i := 0 TO GlobFile.iParaLen DO
		IF asParaNum[i] = '' THEN//空数据，跳出循环
			EXIT;
		ELSE
			arNum[i] := TO_REAL(	FUN_FindString(str:=asParaNum[i] , str1:=':= ' , str2:=';' )	);
		
		END_IF
	
	
	END_FOR
	
	FUN_ReadFileArray := 'OK';

	
	
ELSE	//数据不完整，报错
	
	FUN_ReadFileArray := 'NG';
	
END_IF






(******************************************************
//此部分是预留，如果字符串长度超过255，可以使用此部分

iFind[0] := FIND(STR1:=asParaNum[i] , STR2:=':= ' );		//查询':= '的位置
iFind[1] := FIND(STR1:=asParaNum[i] , STR2:=';' );			//查询';'的位置
StrMidA(
	pst := ADR(asParaNum[i]), 
	uiInputBufferSize := SIZEOF(ADR(asParaNum[i])), 
	iLength := iFind[1] - iFind[0] - len(':= '), 		//计算提取数据的长度。从':= '开始数，到';'结束，其中还要减去':= '自身长度
	iPosition := iFind[0] + len(':= '), 				//从':= '最右边开始提取，所以加上':= '自身长度
	pstResult := ADR(asTmp[i]), 
	uiResultBufferSize := 0);
arNum[i] := TO_REAL(asTmp[i]);


**********************************************************)
END_FUNCTION
