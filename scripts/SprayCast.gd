extends RayCast

var ray_length = 20

signal sprayed(position, normal)

#func _physics_process(delta):
#
#	var camera = get_parent()
##	var mouse_position = get_viewport().get_mouse_position()
##	print(mouse_position)
#	var screen_center = Vector2(960,540)
#	var ray_normal = camera.project_ray_normal(screen_center)
##	set_cast_to(ray_normal * ray_length)
#	var to_vector = ray_normal * ray_length
##	var from_vector = Vector3(960,540, 0)
#	var from_vector = camera.transform.position
#	var state = get_world().get_direct_space_state()
#	var intersections = state.intersect_ray(from_vector, to_vector)
#	print(intersections)

func _physics_process(delta):
	if Input.is_action_pressed("mouse_left") and is_colliding():
		var obj = get_collider()
		print(obj.get_name())
		var location = get_collision_point()
		var normal = get_collision_normal()
		print(location)
		print(normal)
#		emit_signal("sprayed", location, normal)
		_on_sprayed(obj, location, normal)

func debug_intersections(intersections):
	for x in intersections:
		print(x)

func _on_sprayed(collider, click_position, click_normal):
#	if(event is InputEventMouseButton and event.pressed):
#		print("normal: %s" % click_normal)
#		print("world position: %s" % click_position)
		
	var tag = Sprite3D.new()
	tag.transform.origin = click_position
#		tag.transform.origin = get_viewport().get_mouse_position()
#	tag.rotation.z = -90
#	print(tag.transform.origin)
	tag.texture = load("res://textures/sprayblume.png")
	
	collider.add_child(tag)
