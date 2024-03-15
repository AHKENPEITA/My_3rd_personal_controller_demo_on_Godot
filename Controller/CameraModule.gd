extends Node3D

# 上级组件
## 控制本模块的控制器
var player_controller
## 第一人称时跟踪的角色
var player_character

# 内部组件
@export_group('内部组件')
## 角色的追踪锚点
@export var center_pivot : Node3D 
## 摄像机
@export var camera : Camera3D
## 探测物体的射线
@export var detect_ray : RayCast3D
## 平常时的机位
@export var normal_view : Node3D
## 瞄准时的机位
@export var aim_view : Node3D
# 参数配置
@export_group('参数配置')
## 相机追踪速度
@export var trace_rate  = 0.15
## 相机偏航速度
@export var sens_yaw = 0.8 
## 相机俯仰速度
@export var sens_pitch = 0.2 
## 相机仰视限制角
@export var pitch_posi_lim = 70  
## 相机俯视限制角
@export var pitch_nega_lim = -70 

#变量
## 相机偏航弧度（世界坐标）
var yaw := 0.0 
## 相机俯仰弧度（世界坐标）
var pitch := 0.0 
## 当前机位（本地坐标）
var current_view



#初始化函数
func _ready():
	current_view = normal_view

## 初始化绑定玩家控制器
func set_player_controller(controller):
	player_controller = controller
## 绑定角色
func set_player_character(character):
	player_character = character
	global_transform = player_character.global_transform

#帧函数
func _process(_delta):
	trace_character()
	trace_view()
	detect_object()
	
#本地方法
## 跟踪角色，每帧调用
func trace_character():
	if player_character!=null:
		if current_view == normal_view:
			global_position = lerp(global_position,player_character.global_position,trace_rate)
		elif current_view == aim_view:
			global_position = player_character.global_position
## 机位调整，每帧调用
func trace_view():
	camera.position = lerp(camera.position,current_view.position,trace_rate)
	camera.rotation = lerp(camera.rotation,current_view.rotation,trace_rate)



		

#外部方法
## 环视四周的控制函数，由player_controller脚本在收到对应的input时激活
func look_around(movement):
	yaw   = center_pivot.global_rotation.y - deg_to_rad(movement.x*sens_yaw) #计算偏航
	pitch = center_pivot.global_rotation.x - deg_to_rad(movement.y*sens_pitch) #计算俯仰
	pitch = clamp(pitch,deg_to_rad(pitch_nega_lim),deg_to_rad(pitch_posi_lim)) #限制最大俯仰
	center_pivot.global_rotation.y = yaw #设置相机偏航
	center_pivot.global_rotation.x = pitch #设置相机俯仰
## 瞄准、取消瞄准方法，由player_controller脚本在收到对应的input时激活
func aim(is_aim):
	if is_aim:
		current_view = aim_view
	else :
		current_view = normal_view
## 探测物体，由player_controller脚本每帧调用
func detect_object():
	if detect_ray.is_colliding():
		if detect_ray.get_collider().is_class('Object'):
			return detect_ray.get_collider()
	else:
		return null



