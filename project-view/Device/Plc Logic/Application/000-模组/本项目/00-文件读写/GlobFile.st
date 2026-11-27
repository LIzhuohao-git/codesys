{attribute 'qualified_only'}
VAR_GLOBAL
END_VAR


VAR_GLOBAL CONSTANT
	iParaLen						: UINT:=249;//数组长度，从0开始算到iParaLen，最大值249
	iStringLen						: UINT:=20000;//文件读写的字符串总长度
// 	sNullPara						: STRING:='/ := 0.0;';//空数据连接
	
	sStartCharacter					: STRING:='^$R$N';//起始符
	sTerminator						: STRING:='#';//终止符
	
END_VAR
