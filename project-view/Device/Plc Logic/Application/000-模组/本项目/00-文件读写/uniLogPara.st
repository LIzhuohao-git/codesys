TYPE uniLogPara :
UNION
	sLog					: STRING(GlobFile.iStringLen);
	abyLog					: ARRAY[0..GlobFile.iStringLen-1] OF BYTE;
	
END_UNION
END_TYPE
