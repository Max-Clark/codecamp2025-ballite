extends RigidBody2D
class_name Ball

func _init(_pos: Vector2, _name: String) -> void:
	name = _name
	position = _pos
	self.rotation = randf() * PI
	self.angular_velocity = randf() * 5

func _ready():
	#_setup_physics()
	#_setup_visuals()
	
	var timer = Timer.new()
	timer.wait_time = 20.0
	timer.timeout.connect(queue_free)
	timer.one_shot = true
	add_child(timer)
	timer.start()

#func _setup_physics():
	#var collision = CollisionShape2D.new()
	#var shape = CircleShape2D.new()
	#shape.radius = self._radius
	#collision.shape = shape
	#add_child(collision)
	#
	#mass = 1.0
	#gravity_scale = 1.0
	#physics_material_override = PhysicsMaterial.new()
	#physics_material_override.bounce = 0.7
	#physics_material_override.friction = 0.1

func set_ball_size(radius: float):
	var child = find_child("CollisionShape2D", false, true)
	if child and \
		child is CollisionShape2D and \
		(child as CollisionShape2D).shape is CircleShape2D:
			((child as CollisionShape2D).shape as CircleShape2D).radius = radius
			
	var sprite = Sprite2D.new()
	var radiusInt = int(radius)
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
	
	add_child(sprite)
