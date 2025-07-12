extends Node2D
class_name Board1

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
	
	# Create pegs (obstacles)
	create_pegs()
	
	# Create scoring zones
	create_scoring_zones()

func create_wall(from: Vector2, to: Vector2):
	var wall = Wall.new(from, to)
	add_child(wall)

func create_pegs():
	# Create diamond pattern of pegs
	var peg_spacing = 80
	var start_y = 100
	
	for row in range(6):
		var pegs_in_row: float = 8 - row
		var row_y = start_y + row * peg_spacing
		var start_x = board_width / 2 - (pegs_in_row - 1) * peg_spacing / 2
		
		for col in range(pegs_in_row):
			var peg_x = start_x + col * peg_spacing
			add_child(Peg.new(Vector2(peg_x, row_y), 10, null))

func create_scoring_zones():
	var zones = [10, 25, 50, 100, 50, 25, 10]
	var zone_width = board_width / len(zones)
	var zone_height = 50
	var zone_y = board_height - zone_height
	
	for i in range(len(zones)):
		var zone_x = i * zone_width
		create_scoring_zone(Vector2(zone_x, zone_y), Vector2(zone_width, zone_height), zones[i])

func create_scoring_zone(pos: Vector2, size: Vector2, points: int):
	## Color transition: green (10 points) to red (100 points)
	var color_ratio = (points - 10.0) / (100.0 - 10.0)  # 0 to 1
	var scorezone = Scorezone.new(pos, size, points, Color(color_ratio, 1.0 - color_ratio, 0.0))
	scorezone.scored.connect(_on_score_earned)
	add_child(scorezone)

func _on_score_earned(points: int):
	score += points
	score_changed.emit(score)
