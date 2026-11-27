PROGRAM ModbusTcp_Server
VAR
	ModbusTcpServer					:ModbusFB.ServerTCP;
	fcsSupported					:ModbusFB.SupportedFcs ;
	
	CoilsTableSection				:ARRAY[0..0] OF ModbusFB.TableSection;				//线圈定义
	HoldingRegistersTableSection	:ARRAY[0..0] OF ModbusFB.TableSection;				//保持寄存器定义
	//InputRegistersTableSection		:ARRAY[0..0] OF ModbusFB.TableSection;				//输入寄存器定义
	//DiscreteInputsTableSection		:ARRAY[0..0] OF ModbusFB.TableSection;				//离散输入寄存器定义
	
	TableDefinitions				:ModbusFB.TableDefinitions;							//整体定义
END_VAR
VAR_OUTPUT
	uiNumConnected		: UINT;		//实际连接数量
END_VAR
// --- implementation ---
(*功能码启用*)
fcsSupported.ReadCoils:=TRUE;					//01功能码
fcsSupported.ReadDiscreteInputs:=TRUE;			//02功能码
fcsSupported.ReadHoldingRegisters:=TRUE;		//03功能码
fcsSupported.ReadInputRegisters:=FALSE;			//04功能码	输入寄存器
fcsSupported.WriteSingleCoil:=TRUE;				//05功能码
fcsSupported.WriteSingleRegister:=TRUE;			//06功能码
fcsSupported.WriteMultipleCoils:=TRUE;			//15功能码
fcsSupported.WriteMultipleRegisters:=TRUE;		//16功能码

(*线圈 / 离散输入 定义*)							
CoilsTableSection[0].uiStart:=0;
CoilsTableSection[0].uiNumDataItems:=10000;
CoilsTableSection[0].pStartAddr:=ADR(%MX0000.0);
CoilsTableSection[0].uiDataItemSize:=8;

(*保持寄存器定义*)							
HoldingRegistersTableSection[0].uiStart:=0;
HoldingRegistersTableSection[0].uiNumDataItems:=10000;
HoldingRegistersTableSection[0].pStartAddr:=ADR(%MW0);
HoldingRegistersTableSection[0].uiDataItemSize:=16;


(*整体定义*)
(*uiNumSections表示有几个数组*)
TableDefinitions.tableCoils.uiNumSections:=1;
TableDefinitions.tableCoils.pSections:=ADR(CoilsTableSection[0]);
TableDefinitions.tableHoldingRegisters.uiNumSections:=1;
TableDefinitions.tableHoldingRegisters.pSections:=ADR(HoldingRegistersTableSection[0]);
// TableDefinitions.tableInputRegisters.uiNumSections:=1;
// TableDefinitions.tableInputRegisters.pSections:=ADR(InputRegistersTableSection[0]);
// TableDefinitions.tableDiscreteInputs.uiNumSections:=1;
// TableDefinitions.tableDiscreteInputs.pSections:=ADR(DiscreteInputsTableSection[0]);

(*ModbusTcp服务器*)	
ModbusTcpServer(
	xEnable:= TRUE, 
	fcsSupported:= fcsSupported, 
	dataModel:= TableDefinitions, 
	tInactivityInfoTime:= , 
	xRunning=> , 
	xError=> , 
	eErrorID=> , 
	xInactive=> , 
	udiNumMsgRecv=> , 
	udiNumMsgReply=> , 
	udiNumMsgExcReply=> , 
	udiNumMsgExcReplyIllFct=> , 
	udiNumMsgExcReplyIllDataAdr=> , 
	udiNumMsgExcReplyIllDataValue=> , 
	xReadRequest=> , 
	udiNumReadRequests=> , 
	xWriteRequest=> , 
	udiNumWriteRequests=> , 
	wsInterfaceName:= "eth0", 
	uiPort:= 502, 
	xReset:= , 
	udiLogOptions:= , 
	uiConnectedClients=> uiNumConnected);
END_PROGRAM
