FUNCTION_BLOCK Temperature_PID
VAR_INPUT
    Enable: BOOL;           // 使能PID控制
    Setpoint: REAL;         // 温度设定值
    ProcessValue: REAL;     // 当前温度测量值
    Kp: REAL := 2.0;        // 比例系数
    Ki: REAL := 0;        // 积分系数
    Kd: REAL := 0;        // 微分系数
    Ts: TIME := T#1s;       // 采样时间
    OutMin: REAL := 0.0;    // 输出最小值
    OutMax: REAL := 100.0;  // 输出最大值
END_VAR

VAR_OUTPUT
    Heater_ON: BOOL;        // 加热器输出
    PWM_Output: REAL;       // PWM输出百分比
END_VAR

VAR
    LastError: REAL;        // 上次误差
    Integral: REAL;         // 积分项累积
    LastTime: TIME;         // 上次计算时间
    CycleTimer: TON;        // PWM周期定时器
    PWM_Counter: REAL;      // PWM周期计数器
END_VAR

VAR
	Error: REAL;
    Derivative: REAL;
    Output: REAL;
    DeltaTime: TIME;
END_VAR
// --- implementation ---
    IF NOT Enable THEN
        Integral := 0.0;
        LastError := 0.0;
        Heater_ON := FALSE;
        PWM_Output := 0.0;
        RETURN;
    END_IF;
	
	DeltaTime := TIME() - LastTime;
	
	// 到达采样时间时执行计算
    IF DeltaTime >= Ts THEN
        Error := Setpoint - ProcessValue;
        
        // 比例项
        Output := Kp * Error;
        
        // 积分项（带抗饱和）
        Integral := Integral + Ki * Error * TIME_TO_REAL(DeltaTime)/1000.0;
        Integral := LIMIT(OutMin, Integral, OutMax);
        
        // 微分项
        Derivative := Kd * (Error - LastError) / (TIME_TO_REAL(DeltaTime)/1000.0);
        
        // 计算总输出
        Output := Output + Integral + Derivative;
        Output := LIMIT(OutMin, Output, OutMax);
        
        // 更新状态
        LastError := Error;
        LastTime := TIME();
        PWM_Output := Output;
    END_IF;
	
	// PWM控制
    CycleTimer(IN:=NOT CycleTimer.Q, PT:=T#1s);
    
    IF CycleTimer.Q THEN
        PWM_Counter := 0.0;
    ELSE
        PWM_Counter := PWM_Counter + (TIME_TO_REAL(DeltaTime)/1000.0);
    END_IF;
    
    // 输出PWM信号
    Heater_ON := (PWM_Counter / 1000.0) < (PWM_Output / 100.0);
END_FUNCTION_BLOCK
