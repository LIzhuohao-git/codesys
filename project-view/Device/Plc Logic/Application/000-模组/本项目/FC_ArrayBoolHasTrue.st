//布尔数组里面至少有一个值为true的话，函数返回TRUE
FUNCTION FC_ArrayBoolHasTrue : BOOL
VAR_IN_OUT
	abArray							: ARRAY[*] OF BOOL;
END_VAR

VAR
	i								: DINT;
END_VAR
// --- implementation ---
FOR i := LOWER_BOUND(abArray,1) TO UPPER_BOUND(abArray,1) DO
	IF abArray[i] THEN
		FC_ArrayBoolHasTrue := TRUE;
		RETURN;
	END_IF
END_FOR

FC_ArrayBoolHasTrue := FALSE;
END_FUNCTION
