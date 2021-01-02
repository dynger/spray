class_name TextureMerge

const MIN_INT = -2^63
const MAX_INT = 2^63 - 1

# pass an array of SprayStencil
func merge_stencils(stencils:Array):
	var combined_size = calculate_combined_size(stencils)
	
#	for stencil in stencils:
#		stencil.texture.

func calculate_combined_size(stencils:Array):
	var min_x = MAX_INT
	var min_y = MAX_INT
	var max_x = MIN_INT
	var max_y = MIN_INT
	
	for stencil in stencils:
		var image = stencil.texture.get_data()
		var used_rect = image.get_used_rect()
		var horizontal = used_rect.width / 2
		var vertical = used_rect.height / 2
		var center = stencil.position

		# WRONG: must project to 2D first!
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
#	var image = Image.new()
#	image.create(combined_size.size.x, combined_size.size.y, false, Image.FORMAT_RGBA8)
#	image.fill(Color.transparent)
#	image.lock()
	
	for stencil in stencils:
		var image = stencil.texture.get_data()

#func append_image()

class ImageBuilder:
	var image
	
	func _init(size:Vector2):
		image = Image.new()
		image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
		image.fill(Color.transparent)
	
	func append(image:Image, center:Vector2):
		pass
