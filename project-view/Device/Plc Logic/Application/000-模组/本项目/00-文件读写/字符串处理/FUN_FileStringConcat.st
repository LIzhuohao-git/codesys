//[0..199]的数组中每个元素都连接成'/[x] := num;'
FUNCTION FUN_FileStringConcat : BOOL
VAR_INPUT
	asPara						: ARRAY[0..GlobFile.iParaLen] OF STRING;
	arNum						: ARRAY[0..GlobFile.iParaLen] OF REAL;
END_VAR

VAR_OUTPUT
	asParaNum					: ARRAY[0..GlobFile.iParaLen] OF STRING;
END_VAR



VAR
	sTmp						: STRING;
	sTmpNum						: ARRAY[0..GlobFile.iParaLen] OF STRING;
	i							: UINT;
	
END_VAR
// --- implementation ---
(*********************************************************
例如：
asPara[0] := 'Example';			asNum[0] := 1234;

输出：
asParaNum[0] => '/Example := 1234;' 	//有数据
asParaNum[1] => '/ := 0;' 				//没数据，即 GlobFile.sNullPara
**********************************************************)




//先把数据转成string
FOR i := 0 TO TO_UINT(GlobFile.iParaLen) DO
	sTmpNum[i] := TO_STRING(arNum[i]);
END_FOR




FOR i := 0 TO TO_UINT(GlobFile.iParaLen) DO
	IF asPara[i] = '' THEN		//如果是空字符串，就退出循环不连接
		EXIT;
	ELSE
		sTmp := CONCAT(STR1:='/' , STR2:=asPara[i] );
		sTmp := CONCAT(STR1:=sTmp , STR2:=' := ' );
		sTmp := CONCAT(STR1:=sTmp , STR2:=sTmpNum[i] );
		asParaNum[i] := CONCAT(STR1:=sTmp , STR2:=';' );
	END_IF
	
END_FOR
END_FUNCTION
