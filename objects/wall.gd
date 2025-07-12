extends StaticBody2D
class_name Wall

var _from: Vector2
var _to: Vector2

func _init(from: Vector2, to: Vector2) -> void:
	self._from = from
	self._to = to

func _ready() -> void:
	setup_collision()
	setup_visuals()

func setup_collision():
	var collision = CollisionShape2D.new()
	var shape = SegmentShape2D.new()
	shape.a = self._from
	shape.b = self._to
	collision.shape = shape
	add_child(collision)

func setup_visuals():
	var line = Line2D.new()
	line.add_point(self._from)
	line.add_point(self._to)
	line.width = 5.0
	line.default_color = Color.WHITE
	add_child(line)
