extends Area2D
class_name Scorezone

var _points: int
var _size: Vector2
var _color: Color

signal scored(points: int)

func _init(pos: Vector2, size: Vector2, points: int, color: Color) -> void:
	self.position = pos + size / 2
	self._size = size
	self._points = points
	self._color = color
	
	setup_collision()
	setup_visuals()

func setup_collision():
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = self._size
	collision.shape = shape
	add_child(collision)
	
	# Connect signal
	body_entered.connect(_on_ball_scored)

func setup_visuals():
	# Visual rectangle with color based on score
	var rect = ColorRect.new()
	rect.position = self.position - (self.position + self._size / 2)
	rect.size = self._size
	rect.color = self._color
	
	add_child(rect)

func _on_ball_scored(body: Node2D):
	if body is Ball:
		scored.emit(self._points)
		body.queue_free()
