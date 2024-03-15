extends StaticBody3D
@export_category('世界物体')
@export_group('基本属性')
@export var object_name : String = '物体名称'



func on_target():
	print(str(object_name)+' '+str('是当前目标物体'))

func off_target():
	print(str(object_name)+' '+str('不再是当前目标物体'))
