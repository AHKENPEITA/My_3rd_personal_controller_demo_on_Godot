extends Node
#事件库
var EventTable  = {}
func add_listener(arg_EventType,arg_callable:Callable):
	if !EventTable.has(arg_EventType):
		EventTable[arg_EventType] = [arg_callable]
	else :
			EventTable[arg_EventType].append(arg_callable)

func remove_listener(arg_EventType,arg_callable:Callable):
	if!EventTable.has(arg_EventType):
		push_error("移除监听错误：事件库中不存在事件：",arg_EventType)
	elif EventTable[arg_EventType] ==null:
		push_error("移除监听错误：事件：",arg_EventType,"下没有挂载任何回调")
	else :
		var target_callable = EventTable[arg_EventType].find(arg_callable)
		if target_callable ==-1:
			push_error("移除监听错误：事件",arg_EventType,"下没有挂载回调：",arg_callable)
		else :
			EventTable[arg_EventType].erase(arg_callable)
			if EventTable[arg_EventType].is_empty():
				EventTable.erase(arg_EventType)

func broadcast0(arg_EventType):
	if EventTable.has(arg_EventType):
		if EventTable[arg_EventType]!=null:
			for callback in EventTable[arg_EventType]:
				callback.call()

func broadcast1(arg_EventType,arg1):
	if EventTable.has(arg_EventType):
		if EventTable[arg_EventType]!=null:
			for callback in EventTable[arg_EventType]:
				callback.call(arg1)

func broadcast2(arg_EventType,arg1,arg2):
	if EventTable.has(arg_EventType):
		if EventTable[arg_EventType]!=null:
			for callback in EventTable[arg_EventType]:
				callback.call(arg1,arg2)

func broadcast3(arg_EventType,arg1,arg2,arg3):
	if EventTable.has(arg_EventType):
		if EventTable[arg_EventType]!=null:
			for callback in EventTable[arg_EventType]:
				callback.call(arg1,arg2,arg3)

enum{
}

func debug():
	pass
