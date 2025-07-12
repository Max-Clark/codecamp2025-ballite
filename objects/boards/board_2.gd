extends Node2D
class_name Board2

@export var board_width: float = 800
@export var board_height: float = 600

var score: int = 0

signal score_changed(new_score: int)

func _ready():
	setup_board()
	
func setup_board():
	# Create walls
	create_wall(Vector2(0,0), Vector2(0, board_height)) # Left wall
	create_wall(Vector2(board_width, 0), Vector2(board_width, board_height)) # Right wall
	create_wall(Vector2(0, board_height), Vector2(board_width, board_height)) # Bottom wall
	
	# Create pegs
	create_pegs()
	
	# Create scoring zones
	create_scoring_zones()

func create_wall(from: Vector2, to: Vector2):
	var wall = Wall.new(from, to)
	add_child(wall)

func create_pegs():
	# Spiral pattern - variable density based on spiral tightness
	var center_x = board_width / 2
	var center_y = board_height / 2
	var spiral_arms = 3
	var max_radius = 370
	var max_peg_count = 90
	
	for i in range(max_peg_count):
		var progress = float(i) / max_peg_count
		var angle = (i * 2.0 * PI * spiral_arms) / max_peg_count
		var radius = progress * max_radius
		
		# Calculate spiral tightness (how fast angle changes relative to radius)
		var spiral_tightness = spiral_arms / (radius + 1)  # +1 to avoid division by zero
		
		# Skip pegs based on tightness - tighter spiral = fewer pegs
		var skip_chance = spiral_tightness * 0.3  # Adjust multiplier to control effect
		if randf() < skip_chance:
			continue
		
		var peg_x = center_x + cos(angle) * radius
		var peg_y = center_y + sin(angle) * radius * 0.7
		
		# Only place pegs in valid area
		if peg_x > 30 and peg_x < board_width - 30 and peg_y > 80 and peg_y < board_height - 80:
			add_child(Peg.new(Vector2(peg_x, peg_y), 8, null))

func create_scoring_zones():
	# High-risk, high-reward zones
	var zones = [5, 20, 100, 500, 100, 20, 5]
	var zone_width = board_width / len(zones)
	var zone_height = 50
	var zone_y = board_height - zone_height
	
	for i in range(len(zones)):
		var zone_x = i * zone_width
		create_scoring_zone(Vector2(zone_x, zone_y), Vector2(zone_width, zone_height), zones[i])

func create_scoring_zone(pos: Vector2, size: Vector2, points: int):
	var color_ratio = (points - 5.0) / (500.0 - 5.0)  # 0 to 1
	var scorezone = Scorezone.new(pos, size, points, Color(color_ratio, 1.0 - color_ratio, 0.0))
	scorezone.scored.connect(_on_score_earned)
	add_child(scorezone)

func _on_score_earned(points: int):
	score += points
	score_changed.emit(score)
