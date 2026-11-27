//取str1与str2的中间字符串
FUNCTION FUN_FindString : STRING
VAR_INPUT
	str:STRING(255);		//
	str1:STRING;	//first find string
	str2:STRING;	//second find string
END_VAR


VAR
	temp1:INT;
	temp2:INT;
END_VAR
// --- implementation ---
temp1:=find(str,str1);
temp2:=find(str,str2);
FUN_FindString:=mid(str,temp2-temp1-len(str1),temp1+len(str1));	//取str1与str2的中间字符串
END_FUNCTION
