extends "res://scripts/SprayCast.gd"

class_name CoalescingSprayCast

func _physics_process(delta):
	if Input.is_action_just_pressed("spray_stencil") and is_colliding():
		var collider = get_collider()
		var global_position = get_collision_point()
		var normal = get_collision_normal()
		_on_sprayed(collider, global_position, normal)

func _on_sprayed(collision_object, collision_position, collider_normal):
	var tag = create_tag(collision_object)
	rotate_spray_to_collider_normal(tag, collider_normal)
	apply_spray_at_position(tag, collision_object, collision_position, collider_normal)
	apply_spray_texture(tag)
	
func create_tag(collision_object):
	var tag = SprayStencil.new()
	collision_object.add_child(tag)
	return tag

func rotate_spray_to_collider_normal(tag, collider_normal):
	var axis = tag.front.cross(collider_normal)
	axis = axis.normalized()

	var cosa = tag.front.dot(collider_normal)
	var angle = acos(cosa)
	
	var rotated_global_transform = tag.transform.rotated(axis, angle)
	tag.set_global_transform(rotated_global_transform) 

func apply_spray_at_position(tag, collision_object, collision_position, collider_normal):
	var local_position = collision_object.to_local(collision_position)
	var normalized_normal = collider_normal.normalized()
	tag.transform.origin = local_position + (normalized_normal * 0.001)

func apply_spray_texture(tag):
	tag.texture = get_selected_spray()

func get_selected_spray():
	return load("res://textures/sprayblume.png")

func collect_existing_sprays_on_same_surface(collision_object, collision_position, collider_normal):
	var result = []
	for existing_spray in collision_object.get_children():
		if existing_spray is SprayStencil:
			result.append(existing_spray)
	
	return result
