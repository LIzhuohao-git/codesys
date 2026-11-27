{attribute 'qualified_only'}
{attribute 'strict'}
(*A区三轴模组状态机*)
TYPE Robot_STATE :
(
	STOP := 0,						//停止
	INIT,						//初始化
	MANNUAL,					//手动模式	
	AUTO,						//自动模式
	RobotAct,					//自动运行中
	MannualRun					//手动运行中
);
END_TYPE
