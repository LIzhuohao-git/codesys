//输出 STRING = sStr1 + sStr2 + sStr3 + sStr4 +sStr5
FUNCTION FC_StringConnect : STRING
VAR_INPUT
	sStr1						: STRING:='';
	sStr2						: STRING:='';
	sStr3						: STRING:='';
	sStr4						: STRING:='';
	sStr5						: STRING:='';
	
END_VAR                           
                                  
VAR                               
	temp						: STRING;
	
END_VAR
// --- implementation ---
//temp := sStr1;

// StrConcatW(pstFrom:=ADR(wsContent_2) , pstTo:=ADR(temp) , iBufferSize:=TO_INT(SIZEOF(temp)) );
// StrConcatW(pstFrom:=ADR(wsContent_3) , pstTo:=ADR(temp) , iBufferSize:=TO_INT(SIZEOF(temp)) );

temp := CONCAT(STR1:=sStr1 , STR2:=sStr2 );
temp := CONCAT(STR1:=temp , STR2:=sStr3 );
temp := CONCAT(STR1:=temp , STR2:=sStr4 );
temp := CONCAT(STR1:=temp , STR2:=sStr5 );



FC_StringConnect := temp;
END_FUNCTION
