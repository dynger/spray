class_name TextureMerge

# Pass an array of SprayStencil
# It is assumed that they all have the same parent and normal
# and lie on a common plane.
# Iow, they were all sprayed on the same face of a mesh.
func merge_stencils(stencils:Array):
	if stencils.size() < 2:
		return # nothing to merge
	
	if not have_same_parent(stencils):
		push_error("All stencils must have the same parent!")
	
	print("merging %s stencils on same object" % stencils.size())
	
	var original_parent = stencils[0].get_parent()
	rotate_normal_to_global_x(stencils)
	var combined_size = calculate_combined_size(stencils)
	var combined_image = draw_image(combined_size, stencils)
	
	
# This requires the stencils be direct children of the game object
# (house, NPC,...) they're drawn onto.
# Note that after the function returns, the children are parented
# to a temporary helper spatial!
func rotate_normal_to_global_x(stencils:Array):
	var rotation_helper = parent_with_helper(stencils)
	print("rotation_helper: basis=%s" % rotation_helper.transform.basis)
	
	rotation_helper.rotation = Vector3.ZERO
	var rotated_transform = MathUtils.rotate_to_normal(
		rotation_helper.transform, stencils[0].transform.basis.z, Vector3(0,0,1))
	rotation_helper.transform = rotated_transform
	print("after rotation: basis=%s" % rotation_helper.transform.basis)
	
func parent_with_helper(stencils:Array):
	var original_parent = stencils[0].get_parent()
	var rotation_helper = Spatial.new()
	var root = original_parent.get_parent()
	root.add_child(rotation_helper)
	rotation_helper.transform = original_parent.transform
	
	for stencil in stencils:
		original_parent.remove_child(stencil)
		rotation_helper.add_child(stencil)
	return rotation_helper

func have_same_parent(stencils:Array):
	var parent_check = null
	for stencil in stencils:
		var parent = stencil.get_parent()
		if parent_check == null:
			parent_check = parent
		elif parent != parent_check:
			return false
	return true

func calculate_combined_size(stencils:Array):
	var min_x = MathUtils.MAX_INT
	var min_y = MathUtils.MAX_INT
	var max_x = MathUtils.MIN_INT
	var max_y = MathUtils.MIN_INT
	
	for stencil in stencils:
		var image = stencil.texture.get_data()
		var used_rect = image.get_used_rect()
		var horizontal = used_rect.size.x / 2
		var vertical = used_rect.size.y / 2
		var center = stencil.transform.origin
		print("image size %s" % used_rect.size)

		var top = center.y - vertical
		var bottom = center.y + vertical
		var left = center.x - horizontal
		var right = center.x + horizontal

		if top < min_y:
			min_y = top
		if bottom > max_y:
			max_y = bottom
		if left < min_x:
			min_x = left
		if right > max_x:
			max_x = right

	var width = max_x - min_x
	var height = max_y - min_y
	
	return Rect2(min_x, min_y, width, height)

func draw_image(combined_size:Rect2, stencils:Array):
	var builder = ImageBuilder.new(combined_size.size)
	
	for stencil in stencils:
		var image = stencil.texture.get_data()
		var origin = stencil.transform.origin
		var origin2d = Vector2(origin.x, origin.y)
		print("processing image at origin (%s, %s)" % [origin2d.x, origin2d.y])
		#builder.append(image, origin2d)
	
	return builder.get_result()

class ImageBuilder:
	var result:Image
	
	func _init(size:Vector2):
		print("create image builder for combined size (%s, %s)" % [size.x, size.y])
		result = Image.new()
		result.create(size.x, size.y, false, Image.FORMAT_RGBA8)
		result.fill(Color.transparent)
	
	func append(image:Image, origin:Vector2):
		print("append image")
		result.lock()
		image.lock()
		for x in range(0, image.get_width()-1, 1):
			for y in range(0, image.get_height()-1, 1):
				print("set pixel (%s, %s)" % [x, y])
				var pixel = image.get_pixel(x, y)
				result.set_pixel(x, y, pixel)
		image.unlock()
		result.unlock()

	func get_result():
		return result
