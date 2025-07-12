extends Node2D
class_name Board4

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
	# Chaotic maze pattern with heavy randomness
	var cell_size = 60
	var start_y = 80
	
	# Seed randomizer for consistent but varied layouts
	randomize()
	
	# Create a grid-based maze pattern with random elements
	for row in range(8):
		for col in range(12):
			var x = col * cell_size + 80 + randf_range(-15, 15)  # Random position offset
			var y = start_y + row * cell_size + randf_range(-10, 10)
			
			# Random skip chance - creates unpredictable paths
			if randf() < 0.4:  # 40% chance to skip any cell
				continue
			
			# Random peg size for variety
			var peg_size = randi_range(8, 15)
			
			# Create barriers and obstacles with randomness
			if row % 2 == 0:
				# Horizontal barriers with random gaps
				if randf() < 0.7:  # 70% chance to place peg
					add_child(Peg.new(Vector2(x, y), peg_size, null))
			else:
				# Vertical barriers with random gaps
				if randf() < 0.6:  # 60% chance to place peg
					add_child(Peg.new(Vector2(x, y), peg_size, null))
	
	# Add random large obstacle pegs
	var large_peg_count = randi_range(3, 6)
	for i in range(large_peg_count):
		var random_x = randf_range(board_width * 0.2, board_width * 0.8)
		var random_y = randf_range(board_height * 0.3, board_height * 0.7)
		var large_size = randi_range(18, 25)
		add_child(Peg.new(Vector2(random_x, random_y), large_size, null))
	
	# Scatter some small chaos pegs randomly
	var chaos_peg_count = randi_range(15, 25)
	for i in range(chaos_peg_count):
		var chaos_x = randf_range(50, board_width - 50)
		var chaos_y = randf_range(100, board_height - 100)
		var chaos_size = randi_range(5, 10)
		add_child(Peg.new(Vector2(chaos_x, chaos_y), chaos_size, null))

func create_scoring_zones():
	# Varied scoring - rewards finding different paths
	var zones = [15, 30, 60, 120, 60, 30, 15]
	var zone_width = board_width / len(zones)
	var zone_height = 50
	var zone_y = board_height - zone_height
	
	for i in range(len(zones)):
		var zone_x = i * zone_width
		create_scoring_zone(Vector2(zone_x, zone_y), Vector2(zone_width, zone_height), zones[i])

func create_scoring_zone(pos: Vector2, size: Vector2, points: int):
	var color_ratio = (points - 15.0) / (120.0 - 15.0)  # 0 to 1
	var scorezone = Scorezone.new(pos, size, points, Color(color_ratio, 1.0 - color_ratio, 0.0))
	scorezone.scored.connect(_on_score_earned)
	add_child(scorezone)

func _on_score_earned(points: int):
	score += points
	score_changed.emit(score)