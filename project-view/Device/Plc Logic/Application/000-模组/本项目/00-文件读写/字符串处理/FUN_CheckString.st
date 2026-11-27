//利用起始符和终止符，检查字符串是否完整
FUNCTION FUN_CheckString : STRING
VAR_INPUT
	RcvStr					: STRING(GlobFile.iStringLen);
	StartStr				: STRING:=GlobFile.sStartCharacter;
	EndStr					: STRING:=GlobFile.sTerminator;
END_VAR

VAR_OUTPUT
	xFromStr				: STRING(GlobFile.iStringLen);
END_VAR



VAR
	iFind_startStr			: INT;
	iFind_endStr			: INT;
	sMid					: STRING;
    suiMid					: UINT;

	
	
END_VAR
// --- implementation ---
//查找字符 StartStr
iFind_startStr:=stu.StrFindA(pst1 := ADR(RcvStr), pst2 := ADR(startStr), uiSearchStart := 1);
//查找字符 EndStr
iFind_endStr:=stu.StrFindA(pst1 := ADR(RcvStr), pst2 := ADR(endStr), uiSearchStart := 1);



IF iFind_startStr>0 AND iFind_endStr>0 THEN
	//截取字符串 '^'~'#'
	stu.StrMidA(pst := ADR(RcvStr), uiInputBufferSize := SIZEOF(ADR(RcvStr)), iLength := iFind_endStr-iFind_startStr+1, iPosition := 1 , pstResult := ADR(xFromStr), uiResultBufferSize := suiMid);

	FUN_CheckString := 'OK';
	
ELSE
	FUN_CheckString := 'Incomplete';//数据报文不完整
	
END_IF
END_FUNCTION
