extends Node2D
class_name Board3

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
	# Funnel design - wide at top, narrow at bottom with obstacles
	var top_width = board_width * 0.8
	var bottom_width = board_width * 0.3
	var funnel_height = board_height * 0.6
	var start_y = 100
	
	# Create funnel walls
	var rows = 8
	for row in range(rows):
		var progress = float(row) / (rows - 1)
		var row_width = top_width - (top_width - bottom_width) * progress
		var row_y = start_y + row * (funnel_height / rows)
		
		# Left and right funnel walls
		var left_x = board_width / 2 - row_width / 2
		var right_x = board_width / 2 + row_width / 2
		
		add_child(Peg.new(Vector2(left_x, row_y), 12, null))
		add_child(Peg.new(Vector2(right_x, row_y), 12, null))
		
		# Add some chaos in the middle
		if row % 2 == 0 and row > 2:
			var center_x = board_width / 2
			add_child(Peg.new(Vector2(center_x - 40, row_y), 8, null))
			add_child(Peg.new(Vector2(center_x + 40, row_y), 8, null))

func create_scoring_zones():
	# Concentrated scoring - harder to hit center = more points
	var zones = [25, 50, 75, 200, 75, 50, 25]
	var zone_width = board_width / len(zones)
	var zone_height = 50
	var zone_y = board_height - zone_height
	
	for i in range(len(zones)):
		var zone_x = i * zone_width
		create_scoring_zone(Vector2(zone_x, zone_y), Vector2(zone_width, zone_height), zones[i])

func create_scoring_zone(pos: Vector2, size: Vector2, points: int):
	var color_ratio = (points - 25.0) / (200.0 - 25.0)  # 0 to 1
	var scorezone = Scorezone.new(pos, size, points, Color(color_ratio, 1.0 - color_ratio, 0.0))
	scorezone.scored.connect(_on_score_earned)
	add_child(scorezone)

func _on_score_earned(points: int):
	score += points
	score_changed.emit(score)
