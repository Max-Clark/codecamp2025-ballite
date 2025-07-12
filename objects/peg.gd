extends StaticBody2D
class_name Peg

var _pos: Vector2
var _radius: float
var _shaderMaterial: ShaderMaterial

func _init(pos: Vector2, radius: float, shaderMaterial: ShaderMaterial) -> void: 
	self._pos = pos
	self._radius = radius
	self._shaderMaterial = shaderMaterial
	
func _ready() -> void:
	var collision = CollisionShape2D.new()
	var pegShape = CircleShape2D.new()
	
	pegShape.radius = self._radius
	collision.shape = pegShape
	self.position = self._pos
	self.add_child(collision)
	
	var diameter = self._radius * 2
	
	# Visual representation
	var sprite = Sprite2D.new()
	var image = Image.create_empty(int(diameter), int(diameter), false, Image.FORMAT_RGBA8)
	image.fill(Color.BLACK)
	
	# Make it circular by setting alpha based on distance from center
	for x in range(diameter):
		for y in range(diameter):
			var distance = Vector2(x - int(self._radius), y - int(self._radius)).length()
			if distance > 10:
				image.set_pixel(x, y, Color.TRANSPARENT)
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	sprite.texture = texture
	self.add_child(sprite)
	
	if self._shaderMaterial != null:
		var shader_material = ShaderMaterial.new()
		shader_material.shader = self._shaderMaterial
		sprite.material = shader_material
