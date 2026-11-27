TYPE ST_Chassis_Car :
STRUCT
	bConnect						:BOOL;							//连接
	bError 							:BOOL;							//通讯错误
	bConnected						:BOOL;							//连接成功
		//写
	wClearError_WData				:WORD;	//清除错误
	wNavStationNum_WData			:WORD;	//导航站点编号
	wReLocation_WData				:WORD;	//重定位
	wConfirmLocation_WData			:WORD;	//确认定位
	wNavPause_WData					:WORD;	//暂停导航
	wNavContinue_WData				:WORD;	//继续导航
	wNavCancel_WData				:WORD;	//取消导航
	wSeizeControlPower_WData		:WORD;	//抢占控制权
	wReleaseControlPower_WData		:WORD;	//释放控制权
	wSetDoTrue_WData				:WORD;	//设置DO高电平
	wSetDoFalse_WData				:WORD;	//设置DO低电平	
		
	//读
	wCoordPosX_Low_RData			:WORD;	//坐标位置X_低位
	wCoordPosX_High_RData			:WORD;	//坐标位置X_高位	
	wCoordPosY_Low_RData			:WORD;	//坐标位置Y_低位
	wCoordPosY_High_RData			:WORD;	//坐标位置Y_高位
	wCoordPosDeg_Low_RData			:WORD;	//坐标位置角度_低位
	wCoordPosDeg_High_RData			:WORD;	//坐标位置角度_高位	
	wNavNumCur_RData				:WORD;	//当前导航任务站点	
	wLocationState_RData			:WORD;	//当前定位状态(0:定位失败，1:定位正确，2:正在重定位，3:定位完成)	
	wNavState_RData					:WORD;	//当前导航状态(0:无，1:等待执行导航，2:正在执行导航，3:导航暂停，4:到达，5:失败，6:取消，7:超时)		
	wNavTypeCur_RData				:WORD;	//当前导航类型(0:没有导航，1:自由导航到任意点，2:自由导航到站点，3:路径导航到站点，7:平动转动，100:其他)		
	wLocationConfidence_Low_RData	:WORD;	//定位置信度_低位	
	wLocationConfidence_High_RData	:WORD;	//定位置信度_高位
	wBatteryLevel_RData				:WORD;	//电池电量
	wBatteryVoltage_Low_RData		:WORD;	//电池电压_低位
	wBatteryVoltage_High_RData		:WORD;	//电池电压_高位	
	wBatteryCurrent_Low_RData		:WORD;	//电池电流_低位	
	wBatteryCurrent_High_RData		:WORD;	//电池电流_高位		
	wFatalCode_RData				:WORD;	//Fatal码	
	wErrorCode_RData				:WORD;	//Error码
	wWarningCode_RData				:WORD;	//Warning码	
	wStationNumCur_RData			:WORD;	//当前站点	
	wControlModeCur_RData			:WORD;	//当前控制模式(0:自己抢占或未被抢占，1:被外部抢占)
	wVelocityVx_Low_RData			:WORD;	//速度Vx_低位
	wVelocityVx_High_RData			:WORD;	//速度Vx_高位	
	wVelocityVy_Low_RData			:WORD;	//速度Vy_低位
	wVelocityVy_High_RData			:WORD;	//速度Vy_高位				
	wVelocityVdeg_Low_RData			:WORD;	//速度Vdeg_低位
	wVelocityVdeg_High_RData		:WORD;	//速度Vdeg_高位		
	xIsSlowDown_RData				:BOOL;	//当前减速
	xIsBlocked_RData				:BOOL;	//当前被阻挡	
	xIsCharging_RData				:BOOL;	//当前正在充电
	xIsEStop_RData					:BOOL;	//当前被急停
	xIsBrake_RData					:BOOL;	//当前抱闸
	xIsStatic_RData					:BOOL;	//当前静止中
	wDiState_RData					:WORD;	//当前DI状态
	wDoState_RData					:WORD;	//当前DO状态	
END_STRUCT
END_TYPE
