extends Node
#外部组件
var scene_manager:Node
var camera_module:Node3D
var player_character:CharacterBody3D
#变量
var target_object
var debug_pointting_object_label
var move_direction = Vector3.ZERO #前进的朝向（相机坐标，八向正交）
var move_vector = Vector3.ZERO #前进的向量（世界坐标，单位圆周）
var face_towards := 0.0 #面朝的方向（世界坐标，弧度浮点数）
#状态
var aim_mode := false #瞄准模式
var sneak_mode := false #潜行模式
var action_mode := true #角色受控



# 帧更新和帧方法
func _process(_delta):
	if player_character:
		character_motion()
	if camera_module:
		catch_target_object()
## 控制角色的移动（水平移动和面朝向）
func character_motion():
	move_vector = move_direction.normalized()
	if camera_module != null:
		move_vector = move_vector.rotated(Vector3.UP,camera_module.yaw)
		
	if aim_mode:
		face_towards = camera_module.yaw
	else:
		var cos_Alpha = (move_vector.dot(Vector3(0,0,-1)))#先将向量分别映射到前后（0，0，-1）
		var sin_Alpha = (move_vector.dot(Vector3(-1,0,0)))#以及左右（-1，0，0）的三角函数
		face_towards = atan2(sin_Alpha,cos_Alpha)#再用反三角函数atan2求出该单位向量相对绕Y轴相对（0，0，-1）发生的转动	
	
	player_character.motion_control(move_vector,face_towards)
## 接收准星射线传入的目标物体
func catch_target_object():
	var temp_object = camera_module.detect_object()
	if temp_object != null && temp_object!= target_object:
		target_object = temp_object
		target_object.on_target()
	elif temp_object == null && target_object != null:
		target_object.off_target()
		target_object = null
	scene_manager.write_target_object(target_object)
## 处理输入信号
func _input(event):
	## 前后左右
	if event.is_action_pressed("Up"):
		move_direction += Vector3.FORWARD
	if event.is_action_released("Up"):
		move_direction -= Vector3.FORWARD
	if event.is_action_pressed("Down"):
		move_direction += Vector3.BACK
	if event.is_action_released("Down"):
		move_direction -= Vector3.BACK
	if event.is_action_pressed("Left"):
		move_direction += Vector3.LEFT
	if event.is_action_released("Left"):
		move_direction -= Vector3.LEFT	
	if event.is_action_pressed("Right"):
		move_direction += Vector3.RIGHT
	if event.is_action_released("Right"):
		move_direction -= Vector3.RIGHT
	## 奔跑
	if event.is_action_pressed("Run"):
		player_character.switchRunMode()
	## 潜行
	if event.is_action_pressed("Sneak"):
		player_character.switchSneakMode(true)
	if event.is_action_released("Sneak"):
		player_character.switchSneakMode(false)
	## 瞄准（远程武器）
	if event.is_action_pressed("Aim"):
		aim_mode = true
		player_character.switchAimMode(true)
		camera_module.aim(true)
	if event.is_action_released("Aim"):
		aim_mode = false
		player_character.switchAimMode(false)
		camera_module.aim(false)
	## 跳跃	
	if event.is_action_pressed("Jump"):
		player_character.jump(true)
	if event.is_action_released("Jump"):
		player_character.jump(false)
	## 脱离、恢复控制
	if event.is_action_pressed("Esc"):
		if action_mode :
			action_mode = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else :
			action_mode = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)	
	## 视角控制
	if event is InputEventMouseMotion: 
		if camera_module:
			if action_mode:
				camera_module.look_around(event.relative) 

# 外部方法
## 初始化绑定场景管理器
func set_scene_manager(manager):
	scene_manager = manager
## 初始化绑定相机模组，由SceneManager初始化时调用
func set_camera_module(module):
	camera_module = module
	camera_module.set_player_controller(self)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #鼠标隐藏
## 初始化绑定角色模组
func set_character(character):
	player_character = character
	camera_module.set_player_character(player_character)
