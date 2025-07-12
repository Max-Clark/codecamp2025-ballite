extends Ball
class_name BallHoneycomb

func _init(pos: Vector2, radius: float) -> void:
	var shaderMaterial = ShaderMaterial.new()
	shaderMaterial.shader = preload("res://shaders/ball/honeycomb.gdshader")
	shaderMaterial.set_shader_parameter("background_texture", preload("res://assets/img/honeycomb.jpg"))
	super(pos, radius, shaderMaterial)
