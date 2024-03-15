extends CharacterBody3D
@export_group('内部组件')
@export var body_mesh : Node3D #贴图网格
#var animation_tree:AnimationTree #动画混合树
@export_group('参数配置')
## 跳跃速度
@export var jump_speed := 10.0
## 跳跃容错时间
@export var next_jump_tolerance := 0.05
## 边缘跳跃容错时间
@export var edge_jump_tolerance := 0.15
## 重力加速度
@export var gravity := 30.0
## 长按跳跃时重力加速度乘数
@export var gravity_table :={GravityMode.NORMAL:40.0,GravityMode.FALL:60.0,GravityMode.JUMP:20.0}
## 行走速率
@export var walk_speed := 200.0
## 奔跑速率
@export var run_speed := 400.0
## 潜行速率
@export var sneak_speed := 50.0
## 水平运动加速度
@export var move_acceleration := 12.0
## 贴图网格旋转速率
@export var rotate_rate := 0.2
#状态
enum MoveMode {WALK,RUN,SPRINT} #行进模式枚举{行走，慢跑，冲刺}
enum GravityMode {NORMAL,FALL,JUMP}
var move_mode = MoveMode.WALK #行进模式，默认为WALK
var gravity_mode = GravityMode.NORMAL
var sneak_mode = false #潜行模式
var aim_mode = false #瞄准模式
#变量
var move_vector := Vector3.ZERO #移动方向矢量
var face_towards := 0.0 #面朝方向弧度
var move_speed := 0.0 #当前水平运动速率
var next_jump_cache := 0.0 #落地跳跃缓存
var edge_jump_cache := 0.0 #边缘跳跃缓存

func motion_control(vector,towards):
	move_vector = vector
	face_towards = towards

func switchRunMode():
	if move_mode == MoveMode.WALK:
		move_mode = MoveMode.RUN
	elif move_mode == MoveMode.RUN:
		move_mode = MoveMode.WALK
	
func switchSneakMode(is_sneak):
	sneak_mode = is_sneak

func switchAimMode(isAim):
	aim_mode = isAim

func jump(is_jump):
	if is_jump:
		next_jump_cache = next_jump_tolerance	
	else :
		gravity_mode = GravityMode.NORMAL

func normalize_angle(angle):
	angle = fmod(angle,360.0)
	if angle >= 180.0:
		return angle - 360.0
	elif angle <=-180:
		return angle + 360.0
	else:
		return angle

func _physics_process(delta):
## 设定垂直移动速率
	## 浮空
	if !is_on_floor():
		## 依据当前重力模式积分相应的垂直速度
		velocity.y -= gravity_table.get(gravity_mode)*delta
		## 速度变为向下时重力模式变为下落
		if velocity.y <0:
			gravity_mode = GravityMode.FALL
		## 边缘容错时间倒计时
		if edge_jump_cache-delta > 0:
			edge_jump_cache -=delta
		else:
			edge_jump_cache = 0
		## 跳跃缓存时间倒计时
		if next_jump_cache-delta > 0:
			next_jump_cache -=delta
		else:
			next_jump_cache = 0
		## 边缘容错时间内激活跳跃
		if edge_jump_cache > 0:
			if next_jump_cache > 0:
				velocity.y = jump_speed
				next_jump_cache = 0
				gravity_mode = GravityMode.JUMP
	## 落地
	else:
		## 当落地并且缓存中有剩余未激活的跳跃时，激活跳跃
		if next_jump_cache > 0:
			velocity.y = jump_speed
			next_jump_cache = 0
			gravity_mode = GravityMode.JUMP
		## 当落地并且缓存中无剩余未激活的跳跃时，落地，速度归零
		else :
			edge_jump_cache = edge_jump_tolerance
			velocity.y = 0

	#设定当前平面移动速率
	if sneak_mode: #潜行状态
		move_speed = sneak_speed
	elif aim_mode: #瞄准状态
		move_speed = walk_speed
		#animation_tree.set("parameters/aim_transition/transition_request","aim")
	else :
		#animation_tree.set("parameters/aim_transition/transition_request","not_aim")
		match move_mode: #常规运动状态
			MoveMode.WALK:
				move_speed = walk_speed #赋予行走速率
				#animation_tree.set("parameters/move_transition/transition_request","walk")
			MoveMode.RUN:
				move_speed = run_speed #赋予慢跑速率
				#animation_tree.set("parameters/move_transition/transition_request","run")

	#插值得到当前水平移动速度
	velocity.x = lerp(velocity,move_vector*move_speed*delta,move_acceleration*delta).x
	velocity.z = lerp(velocity,move_vector*move_speed*delta,move_acceleration*delta).z


	if move_vector!= Vector3.ZERO or aim_mode:
		var alpha = rad_to_deg(face_towards)
		var theta = rad_to_deg(body_mesh.rotation.y )
		var phi = alpha-theta
		body_mesh.rotate_y(normalize_angle(phi) *rotate_rate*delta)
	
	
	
	move_and_slide()
