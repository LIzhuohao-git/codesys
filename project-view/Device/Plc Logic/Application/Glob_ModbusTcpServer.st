//{attribute 'qualified_only'}
VAR_GLOBAL
	//状态机
	xAllowRunning_Chassis				AT %MX0000.0:BOOL;	//允许运行-底盘
	xAllowRunning_Robot					AT %MX0002.0:BOOL;	//允许运行-机械臂	
	
	awChassisNotAllowRunningReason		AT %MW0010:ARRAY [0..9] OF WORD;	//底盘不允许运行原因
	awRobotNotAllowRunningReason		AT %MW0020:ARRAY [0..9] OF WORD;	//机械臂不允许运行原因	
	
	//底盘-本体	CmdMT
	Car_M_xClearError							AT %MX2000.0:BOOL;	//清除错误
	Car_M_xReLocation							AT %MX2002.0:BOOL;	//重定位
	Car_M_xConfirmLocation						AT %MX2004.0:BOOL;	//确认定位
	Car_M_xNavStart								AT %MX2006.0:BOOL;	//开始导航
	Car_M_xNavPause								AT %MX2008.0:BOOL;	//暂停导航
	Car_M_xNavContinue							AT %MX2010.0:BOOL;	//继续导航
	Car_M_xNavCancel							AT %MX2012.0:BOOL;	//取消导航
	Car_M_wNavStationNum						AT %MW1007:WORD;	//导航站点编号		
	Car_M_xSeizeControlPower					AT %MX2016.0:BOOL;	//抢占控制权
	Car_M_xReleaseControlPower					AT %MX2018.0:BOOL;	//释放控制权
	Car_M_awDoSwitch							AT %MW1010:ARRAY [0..15] OF WORD;	//DO开关
	
	//底盘-本体	State
	Car_wCommErrorCode						AT %MW1100:WORD;					//通讯错误码	
	Car_rCoordPosX							AT %MD551:REAL;						//坐标位置X
	Car_rCoordPosY							AT %MD552:REAL;						//坐标位置Y
	Car_rCoordPosDeg						AT %MD553:REAL;						//坐标位置Deg
	Car_wNavNumCur							AT %MW1108:WORD;					//当前导航任务站点	
	Car_wLocationState						AT %MW1109:WORD;					//当前定位状态(0:定位失败，1:定位正确，2:正在重定位，3:定位完成)	
	Car_wNavState							AT %MW1110:WORD;					//当前导航状态(0:无，1:等待执行导航，2:正在执行导航，3:导航暂停，4:到达，5:失败，6:取消，7:超时)		
	Car_wNavTypeCur							AT %MW1111:WORD;					//当前导航类型(0:没有导航，1:自由导航到任意点，2:自由导航到站点，3:路径导航到站点，7:平动转动，100:其他)		
	Car_rLocationConfidence					AT %MD556:REAL;						//定位置信度
	Car_wBatteryLevel						AT %MW1114:WORD;					//电池电量
	Car_rBatteryVoltage						AT %MD558:REAL;						//电池电压
	Car_rBatteryCurrent						AT %MD559:REAL;						//电池电流	
	Car_wFatalCode							AT %MW1120:WORD;					//Fatal码	
	Car_wErrorCode							AT %MW1121:WORD;					//Error码
	Car_wWarningCode						AT %MW1122:WORD;					//Warning码	
	Car_wStationNumCur						AT %MW1123:WORD;					//当前站点	
	Car_wControlModeCur						AT %MW1124:WORD;					//当前控制模式(0:自己抢占或未被抢占，1:被外部抢占)
	Car_rVelocityVx							AT %MD563:REAL;						//速度Vx
	Car_rVelocityVy							AT %MD564:REAL;						//速度Vy			
	Car_rVelocityVdeg						AT %MD565:REAL;						//速度Vdeg	
	Car_xIsSlowDown							AT %MX2264.0:BOOL;					//当前减速
	Car_xIsBlocked							AT %MX2266.0:BOOL;					//当前被阻挡	
	Car_xIsCharging							AT %MX2268.0:BOOL;					//当前正在充电
	Car_xIsEStop							AT %MX2270.0:BOOL;					//当前被急停
	Car_xIsBrake							AT %MX2272.0:BOOL;					//当前抱闸
	Car_xIsStatic							AT %MX2274.0:BOOL;					//当前静止中	
	Car_awDiState							AT %MW1138:ARRAY [0..15] OF WORD;	//DI开关状态	
	Car_awDoState							AT %MW1154:ARRAY [0..15] OF WORD;	//DO开关状态	
	
	//机械臂-本体  Cmd AT	仙工控制器写入
	Robot_A_xTaskStart					AT %MX2600.0:BOOL;			//任务开始	
	Robot_A_xTaskPause					AT %MX2602.0:BOOL;			//任务暂停
	Robot_A_xTaskContiune				AT %MX2604.0:BOOL;			//任务继续	
	Robot_A_xTaskStop					AT %MX2606.0:BOOL;			//任务停止
	Robot_A_wTaskID						AT %MW1304:WORD;			//任务ID   	                                            		
	Robot_A_wTaskNum					AT %MW1305:WORD;			//任务编号(0:无，1:设备管架下料，2:设备管架上料)	
	Robot_A_wPhotoMode					AT %MW1306:WORD;			//拍照模式(0:设备判定，1:强制拍照)
	Robot_A_wWorkStation				AT %MW1307:WORD;			//工作站点
	Robot_A_wRackType					AT %MW1308:WORD;			//管架类型
	Robot_A_wDeviceRackPos				AT %MW1309:WORD;			//设备管架位置
	Robot_A_wChassisRackPos				AT %MW1310:WORD;			//底盘管架位置	
	
	
	//机械臂-本体	State	仙工控制器读取
	Robot_wCommErrorCode				AT %MW1400:WORD;	//通讯错误码
	Robot_wControllerState				AT %MW1401:WORD;	//控制器状态机	
	Robot_wInDriveSafe					AT %MW1402:WORD;	//当前在行驶安全点(0:false，1:true)	
	Robot_wTaskID						AT %MW1403:WORD;	//任务ID(当前任务ID，任务开始时获取一次，用于辨识)  	
	Robot_wTaskState					AT %MW1404:WORD;	//任务状态(0:NONE，1:进行中，2:暂停中，3:已完成，4:参数异常，5:失败)
	Robot_wPhotoState					AT %MW1405:WORD;	//拍照状态(0:空，1:拍照成功，2:拍照失败)
	Robot_wTakeRackState				AT %MW1406:WORD;	//管架取料状态(0:空，1:抓料成功，2:抓料抓空，3:抓料抓歪)
	Robot_wPutRackState					AT %MW1407:WORD;	//管架放料状态(0:空，1:放料成功，2:放料异常)
	Robot_wRackSensorState				AT %MW1408:WORD;	//管架传感器状态(0:空，1:放料位被占用，2:取料位空闲)
	

END_VAR
