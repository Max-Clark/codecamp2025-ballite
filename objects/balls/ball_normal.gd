extends Ball
class_name BallNormal

func _init(pos: Vector2, radius: float) -> void:
	var shaderMaterial = ShaderMaterial.new()
	shaderMaterial.shader = preload("res://shaders/ball/normal.gdshader")
	super(pos, radius, shaderMaterial)
