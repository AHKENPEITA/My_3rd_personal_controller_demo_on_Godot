extends Node
@export var camera_module:Node3D
@export var player_character:CharacterBody3D
@export var target_object_label : Label

func _ready():
	PlayerController.set_scene_manager(self)
	PlayerController.set_camera_module(camera_module)
	if player_character:
		PlayerController.set_character(player_character)
		
func write_target_object(object):
	if object:
		target_object_label.text = object.object_name
	else :
		target_object_label.text = '无目标'
