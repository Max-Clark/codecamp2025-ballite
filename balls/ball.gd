extends RigidBody2D
class_name Ball

var _pos: Vector2
var _radius: float
var _shaderMaterial: ShaderMaterial

var _multiplierIdx = 0
var _multiplierUpgrades: Array[FloatUpgrade] = [ FloatUpgrade.new(0, 1) ]

var _gravityIdx = 0
var _gravityUpgrades: Array[FloatUpgrade] = [ FloatUpgrade.new(0, 1) ]

func _init(pos: Vector2, radius: float, shaderMaterial: ShaderMaterial) -> void:
	self._shaderMaterial = shaderMaterial
	self._radius = radius
	self._pos = pos
	self.rotation = randf() * PI
	self.angular_velocity = randf() * 5

func _ready():
	_setup_physics()
	_setup_visuals()

	self.position = self._pos
	
	# TODO: remove this
	var timer = Timer.new()
	timer.wait_time = 10.0
	timer.timeout.connect(queue_free)
	timer.one_shot = true
	add_child(timer)
	timer.start()

func _setup_physics():
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = self._radius
	collision.shape = shape
	add_child(collision)
	
	mass = 1.0
	gravity_scale = 1.0
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = 0.7
	physics_material_override.friction = 0.1

func _setup_visuals():
	var sprite = Sprite2D.new()
	var radiusInt = int(self._radius)
	var diameterInt = radiusInt * 2
	
	var image = Image.create(diameterInt, diameterInt, false, Image.FORMAT_RGBA8)
	image.fill(Color.GRAY)
	
	for x in range(diameterInt):
		for y in range(diameterInt):
			var distance = Vector2(x - radiusInt, y - radiusInt).length()
			if distance > radiusInt:
				image.set_pixel(x, y, Color.TRANSPARENT)
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	sprite.texture = texture
	
	if self._shaderMaterial != null:
		sprite.material = self._shaderMaterial
	
	add_child(sprite)

func get_multiplier_upgrade_cost() -> float:
	if _multiplierIdx + 1 >= len(_multiplierUpgrades):
		return NAN
	
	return _multiplierUpgrades[_multiplierIdx + 1].cost
	
func upgrade_multiplier():
	if _gravityIdx + 1 >= len(_gravityUpgrades):
		return NAN
	
	_gravityIdx += 1
	self.gravity_scale = _gravityUpgrades[_gravityIdx].value

func get_multiplier() -> float:
	return _multiplierUpgrades[_multiplierIdx].value

func get_gravity_upgrade_cost() -> float:
	if _gravityIdx + 1 >= len(_gravityUpgrades):
		return NAN
	
	return _gravityUpgrades[_gravityIdx + 1].cost
	
func upgrade_gravity():
	if _gravityIdx + 1 >= len(_gravityUpgrades):
		return NAN
	
	_gravityIdx += 1
	self.gravity_scale = _gravityUpgrades[_gravityIdx].value
	
