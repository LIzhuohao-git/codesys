TYPE ST_ROBOT_MODULE :	//机械臂模块
STRUCT
	bConnect					:BOOL;
	bConnected					:BOOL;
	bTcpError					:BOOL;
	
	//写
	x_iGrpEnable				:BOOL;			//上使能
	x_iGrpDisable				:BOOL;			//去使能
	x_iGrpReset					:BOOL;			//复位
	x_iStartScript				:BOOL;			//开始脚本
	x_iPauseScript				:BOOL;			//暂停脚本
	x_iContinueScript			:BOOL;			//继续脚本
	x_iStopScript				:BOOL;			//停止脚本	
	x_iManualMode				:BOOL;			//手动模式
	x_iAutoMode					:BOOL;			//自动模式
	
	//读
	x_oStateRunning				:BOOL;			//状态-运行中
	x_oStateStopping			:BOOL;			//状态-停止中
	x_oStatePausing				:BOOL;			//状态-暂停中
	x_oStateFree				:BOOL;			//状态-空闲中
	x_oStateElectrify			:BOOL;			//状态-上电
	x_oStatePower				:BOOL;			//状态-使能中
	x_oStateErr					:BOOL;			//状态-报警
	x_oCollide					:BOOL;			//状态-碰撞
	
	//写
	wExecute_Init    			:WORD := 1;		//-- PLC请求初始化 (0/1)
	wExecute_Act     			:word;		//-- PLC请求执行动作 (0=无, 1=下料, 2=上料)
	wOrderNumCur     			:word;		//-- PLC指定工作站点 (1,2...)
	wRackTpye        			:word;		//-- PLC指定盘架类型
	wDeviceRackPosNum			:word;		//-- PLC指定设备取放编号
	wChassisRackPosNum			:WORD;		//-- PLC指定小车底盘位置编号
	xExcuteSetVal				:BOOL;		//搬运参数写入
	xExcuteInit					:BOOL;		//机械臂初始化
	xExcuteAct					:BOOL;		//执行机械臂搬运动作
	
	
	//读
	rGlobInitStatus				:WORD;			//初始化状态反馈		--4是初始化完成
	rOrderNumCur				:WORD;			//工作站点参数反馈
	rRackTpye					:WORD;			//盘架类型参数反馈
	rDeviceRackPosNum			:WORD;			//设备位置参数反馈
	rChassisRackPosNum			:WORD;			//小车位置参数反馈
	rAct_Status					:WORD;			//机械臂动作状态 (0=未执行,1=执行中,2=完成,3=失败)
	rExecute_Act				:WORD;			//当前执行动作反馈 (0=无, 1=下料, 2=上料)
	RobotBusy					:WORD;			//机械臂忙标志 (0=空闲, 1=忙碌)
	
	G_FailCode					:WORD;			//失败代码 (0=无错误, 1=RTU连接失败, 2=电爪初始化失败, 3=电爪打开失败, 4=电爪夹紧失败, 5=拍照失败)
	G_FailWorkstationrk			:WORD;			//失败时的工作站点编号
	G_FailActType				:WORD;			//失败时的动作类型 (1=下料/出库, 2=上料/入库)
	
END_STRUCT
END_TYPE
