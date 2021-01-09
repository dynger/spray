extends SprayCast

class_name MergingSprayCast

var texture_merge = TextureMerge.new()

func _on_sprayed():
	draw_stencil()
	merge_stencils()

func merge_stencils():
	var stencils = collect_existing_sprays_on_same_surface()
	print("collected %s stencils on same object" % stencils.size())
	texture_merge.merge_stencils(stencils)

func collect_existing_sprays_on_same_surface():
	var result = []
	var collision_object = get_collider()
	var collider_normal = get_collision_normal()
	
	for existing_spray in collision_object.get_children():
		# TODO: collect only those which lie on the same face!
		if existing_spray is SprayStencil and existing_spray.collider_normal == collider_normal:
			result.append(existing_spray)
	
	return result
