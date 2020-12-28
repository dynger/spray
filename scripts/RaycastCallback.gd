extends StaticBody

#Error connect(signal: String, target: Object, method: String, binds: Array = [  ], flags: int = 0)

#func _ready():
#	$CameraHolder/Camera/SprayCast.connect("sprayed", self, "_on_sprayed")

func _on_sprayed(click_position, click_normal):
#	if(event is InputEventMouseButton and event.pressed):
#		print("normal: %s" % click_normal)
#		print("world position: %s" % click_position)
		
	var tag = Sprite3D.new()
	tag.transform.origin = click_position
#		tag.transform.origin = get_viewport().get_mouse_position()
#	tag.rotation.z = -90
#	print(tag.transform.origin)
	tag.texture = load("res://textures/sprayblume.png")
	
	get_parent().add_child(tag)
