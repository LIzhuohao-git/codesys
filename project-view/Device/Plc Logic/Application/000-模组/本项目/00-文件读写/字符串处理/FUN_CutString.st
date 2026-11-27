//根据起始符和终止符，裁剪分成字符串数组[0.199]
FUNCTION FUN_CutString : STRING
VAR_INPUT
	sString							: STRING(GlobFile.iStringLen);
	sStartCharacter					: STRING:='/';//起始符
	sTerminator						: STRING:=';';//终止符
END_VAR

VAR_OUTPUT
	asParaNum							: ARRAY[0..GlobFile.iParaLen] OF STRING;
END_VAR



VAR
	i								: UINT;
	temp							: INT;		//查找的起始位置
	iFindStartCharacter				: INT;		//查找起始符的位置
	iFindTerminator					: INT;		//查找终止符的位置
	
END_VAR
// --- implementation ---
(**********************************************************
例如：
sString := '/a := 123;$R$N/b := 456;';


输出：
asPara[0] => '/a := 123;'		asPara[1] => '/b := 456;'
**********************************************************)


// iFindStartCharacter := 0;
// iFindTerminator := 0;
// temp:=0;
FOR i:=0 TO GlobFile.iParaLen DO
	iFindStartCharacter := StrFindA(pst1 := ADR(sString), pst2 := ADR(sStartCharacter), uiSearchStart := INT_TO_UINT(temp+1));
	iFindTerminator := StrFindA(pst1 := ADR(sString), pst2 := ADR(sTerminator), uiSearchStart := INT_TO_UINT(temp+1));
	
	
	IF iFindStartCharacter>0 AND iFindTerminator>0 THEN	//有数据才记录下来，读到空数据就跳出循环
		StrMidA(pst := ADR(sString), uiInputBufferSize := SIZEOF(ADR(sString)), iLength := iFindTerminator-iFindStartCharacter+1, iPosition := iFindStartCharacter , pstResult := ADR(asParaNum[i]), uiResultBufferSize := 0);
		
		temp := iFindTerminator;//记录本次终止符的位置，下次从此位置开始搜索字符串
		iFindStartCharacter := 0;
		iFindTerminator := 0;
		
	ELSE
		EXIT;
	END_IF
	
	
END_FOR
END_FUNCTION
