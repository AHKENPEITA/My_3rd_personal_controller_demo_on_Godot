extends MeshInstance3D
var camera

func ready():
	print(PlayerController.camera_module)
	
	
func _process(_delta):
	if camera:
		print('face_to_camera()')
		pass
