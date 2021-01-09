class_name TextureMerge

var merge_limit = 2

# Pass an array of SprayStencil
# It is assumed that they all have the same parent and normal
# and lie on a common plane.
# Iow, they were all sprayed on the same face of a mesh.
func merge_stencils(stencils:Array):
	if stencils.size() < merge_limit:
		return # nothing to merge
	
	if not have_same_parent(stencils):
		push_error("All stencils must have the same parent!")
	
	if not have_same_pixel_size(stencils):
		push_error("All stencils must have the same pixel size!")
	
	print("merging %s stencils on same object" % stencils.size())
	
	var original_parent = stencils[0].get_parent()
	var rotation_helper = duplicate_stencils(stencils)
	rotate_normal_to_global_x(rotation_helper)
	var combined_size = calculate_combined_size(rotation_helper)
	var combined_image = draw_image(combined_size, rotation_helper)
	var combined_texture = ImageTexture.new()
	combined_texture.create_from_image(combined_image)
	var combined_stencil = SprayStencil.new()
	combined_stencil.set_texture(combined_texture)
	combined_stencil.translate(Vector3(0,0,5))
	original_parent.add_child(combined_stencil)
	delete_rotation_helper(rotation_helper)

func have_same_parent(stencils:Array):
	var parent_check = null
	for stencil in stencils:
		var parent = stencil.get_parent()
		if parent_check == null:
			parent_check = parent
		elif parent != parent_check:
			return false
	return true

func have_same_pixel_size(stencils:Array):
	var pixel_size_check = null
	for stencil in stencils:
		var image = stencil.texture.get_data()
		var pixel_size = stencil.get_pixel_size()
		if pixel_size_check == null:
			pixel_size_check = pixel_size
		elif pixel_size != pixel_size_check:
			return false
	return true

func duplicate_stencils(stencils:Array):
	var original_parent = stencils[0].get_parent()
	var rotation_helper = create_rotation_helper(original_parent)
	
	for stencil in stencils:
		var copy = stencil.duplicate()
		original_parent.remove_child(copy)
		rotation_helper.add_child(copy)
	return rotation_helper

func create_rotation_helper(original_parent):
	var rotation_helper = Spatial.new()
	var root = original_parent.get_parent()
	root.add_child(rotation_helper)
	rotation_helper.transform = original_parent.transform
	return rotation_helper

# This requires the stencils be direct children of the game object
# (house, NPC,...) they're drawn onto.
# Note that after the function returns, the children are parented
# to a temporary helper spatial!
func rotate_normal_to_global_x(rotation_helper):
	print("rotation_helper: basis=%s" % rotation_helper.transform.basis)
	rotation_helper.rotation = Vector3.ZERO
	var any_child = rotation_helper.get_child(0)
	var rotated_transform = MathUtils.rotate_to_normal(
		rotation_helper.transform, any_child.transform.basis.z, Vector3(0,0,1))
	rotation_helper.transform = rotated_transform
	print("after rotation: basis=%s" % rotation_helper.transform.basis)

func calculate_combined_size(rotation_helper):
	var min_x = MathUtils.MAX_INT
	var min_y = MathUtils.MAX_INT
	var max_x = MathUtils.MIN_INT
	var max_y = MathUtils.MIN_INT
	var pixel_size
	
	for stencil in rotation_helper.get_children():
		pixel_size = stencil.get_pixel_size()
		var used_rect = image_size_world(stencil)
		var horizontal = used_rect.size.x / 2
		var vertical = used_rect.size.y / 2
		var center = stencil.transform.origin
		print("image at position %s has world size %s" % [center, used_rect.size])

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

	var width = (max_x - min_x) / pixel_size
	var height = (max_y - min_y) / pixel_size
	print("combined image has size (%s, %s)" % [width, height])
	return Rect2(min_x, min_y, width, height)

func image_size_world(sprite):
	var image = sprite.texture.get_data()
	var used_rect = image.get_used_rect()
	var pixel_size = sprite.get_pixel_size()
	var world_x = used_rect.size.x * pixel_size
	var world_y = used_rect.size.y * pixel_size
	return Rect2(used_rect.position, Vector2(world_x, world_y))
	
func draw_image(combined_size:Rect2, rotation_helper):
	var pixel_size = rotation_helper.get_child(0).get_pixel_size()
	var builder = ImageBuilder.new(combined_size.size, pixel_size)
	
	for stencil in rotation_helper.get_children():
		var image = stencil.texture.get_data()
		var origin = stencil.transform.origin
		var origin2d = Vector2(origin.x, origin.y)
		builder.append(image, origin2d)
	
	return builder.get_result()

func delete_rotation_helper(rotation_helper):
	for child in rotation_helper.get_children():
		child.queue_free()
	rotation_helper.queue_free()

func delete_original_stencils(stencils:Array):
	for stencil in stencils:
		stencil.queue_free()

class ImageBuilder:
	var result:Image
	var pixel_size
	
	func _init(combined_size:Vector2, pixel_size):
		self.pixel_size = pixel_size
		print("create image builder for combined size (%s, %s)" % [combined_size.x, combined_size.y])
		result = Image.new()
		result.create(combined_size.x, combined_size.y, false, Image.FORMAT_RGBA8)
		result.fill(Color.transparent)
	
	func append(image:Image, origin:Vector2):
		image.decompress()
		result.lock()
		image.lock()
		
		var height = image.get_height()
		var width = image.get_width()
		print("image at origin (%s), width, height (%s, %s)" % [origin, width, height])
		
		var left = origin.x / pixel_size - (width/2)
		var top = origin.y / pixel_size - (height/2)
		
		print("top left of appended image (%s, %s)" % [top, left])
		
		for y in range(height):
			var y_combined = top + y
			for x in range(width):
				var pixel = image.get_pixel(x, y)
				var x_combined = left + x
#				print("set pixel (%s, %s): %s" % [x, y, pixel])
				result.set_pixel(x_combined, y_combined, pixel)
		
		image.unlock()
		result.unlock()

	func get_result():
		return result
