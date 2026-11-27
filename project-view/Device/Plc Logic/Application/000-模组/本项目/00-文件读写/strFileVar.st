TYPE strFileVar :
STRUCT
	
	(*文件读写变量*)
	asPara						: ARRAY[0..GlobFile.iParaLen] OF STRING;
	arNum						: ARRAY[0..GlobFile.iParaLen] OF REAL;
	asParaNum					: ARRAY[0..GlobFile.iParaLen] OF STRING;
	iFile						: UINT;
	sFileState					: STRING;//读写状态
	sFileName					: STRING:='Para_Model.txt';


END_STRUCT
END_TYPE
