extends Control

var available_stencils = ["RAINBOW","ACAB","ratte","blume","BREMER","Redstripe"]
var current_stencil 
var controlkastl = []
var ui_counter = 6

func _ready():
	var stencil_container = get_node("StencilContainer")

	for i in range(ui_counter) :
		var newButton = TextureButton.new()
		var newSprite = Sprite.new()
		newButton.texture_normal = load("res://ui/selector_frame.png")
		newButton.texture_hover = load("res://ui/selector_frame.png")
		newSprite.texture = load("res://textures/stencils/spray"+(available_stencils[i])+".png")
		stencil_container.add_child(newButton)
		newButton.add_child(newSprite)
		scale_sprite_to_container(newSprite, newButton)
		newSprite.position = newButton.get_transform().origin + newButton.get_size() / 2


func _process(delta):
	if Input.is_action_just_pressed("spray_select") :
		$TextureButton/ButtonSprite.texture = load("res://textures/stencils/spray"+(available_stencils[3])+".png")

func scale_sprite_to_container(sprite, texbutton):
	var superscale = texbutton.get_size() - Vector2(20,20)
	print (superscale)
	print(sprite.texture.get_size())
	var tag_width = sprite.texture.get_width()
	var tag_height = sprite.texture.get_height()
	var longer_side = max(tag_width, tag_height) 
	var scale_factor = superscale.x / longer_side
	sprite.scale = Vector2(scale_factor, scale_factor)
