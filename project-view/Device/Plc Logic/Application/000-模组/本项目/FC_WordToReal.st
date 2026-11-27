FUNCTION FC_WordToReal : REAL
VAR_INPUT
	arrRegisters0 : WORD;
	arrRegisters1 : WORD;
END_VAR
VAR
	dwCombined: DWORD;              // 合并后的DWORD 
    rResult: REAL;                  // 输出浮点数 
    pReal: POINTER TO REAL;         // 类型转换指针 
    bIsBigEndian: BOOL := TRUE;     // 字节序配置开关 
END_VAR
// --- implementation ---
// 寄存器合并与转换逻辑 
IF bIsBigEndian THEN 
    dwCombined := SHL(WORD_TO_DWORD(arrRegisters0), 16) OR arrRegisters1;
ELSE 
    dwCombined := SHL(WORD_TO_DWORD(arrRegisters0), 16) OR arrRegisters1;
END_IF 


pReal := ADR(dwCombined);           // 获取内存地址 
FC_WordToReal := pReal^;                  // 指针解引用
END_FUNCTION
