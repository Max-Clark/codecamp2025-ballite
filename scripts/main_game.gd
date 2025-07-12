extends Node2D
class_name MainGame

enum BallType { NORMAL = 10, HONEYCOMB = 2 }

var board: Node2D
var info_menu: InfoMenu
var screen_width: float
var screen_height: float

@export var ball_spawn_rate: float = 0.25
var spawn_timer: Timer
var score: int = 0

func _ready():
	screen_width = get_viewport().get_visible_rect().size.x
	screen_height = get_viewport().get_visible_rect().size.y
	
	setup_board()
	setup_info_menu()
	setup_spawn_timer()
	connect_signals()

func setup_board():
	board = Board1.new()
	# Resize board to take 3/4 of screen width
	var board_area_width = screen_width * 0.75
	board.board_width = board_area_width - 20  # 10px margin on each side
	board.board_height = screen_height - 20
	board.position = Vector2(10, 10)
	add_child(board)

func setup_info_menu():
	info_menu = InfoMenu.new()
	info_menu.menu_width = screen_width * 0.25
	add_child(info_menu)

func setup_spawn_timer():
	spawn_timer = Timer.new()
	spawn_timer.wait_time = ball_spawn_rate
	spawn_timer.timeout.connect(spawn_ball)
	spawn_timer.autostart = true
	add_child(spawn_timer)

func connect_signals():
	# Connect score signals from board to info menu
	if board.has_signal("score_changed"):
		board.score_changed.connect(_on_score_changed)
	
	# Connect info menu button signals
	info_menu.reset_score_requested.connect(_on_reset_score)
	info_menu.board_change_requested.connect(_on_board_change)

func _on_score_changed(new_score: int):
	score = new_score
	info_menu.update_score(score)

func _on_reset_score():
	score = 0
	board.score = 0
	info_menu.update_score(score)

func _on_board_change(board_number: int):
	# Remove current board
	if board:
		board.queue_free()
	
	# Create new board based on selection
	match board_number:
		1:
			board = preload("res://objects/boards/board_1.gd").new()
		2:
			board = preload("res://objects/boards/board_2.gd").new()
		3:
			board = preload("res://objects/boards/board_3.gd").new()
		4:
			board = preload("res://objects/boards/board_4.gd").new()
		_:
			board = preload("res://objects/boards/board_1.gd").new()
	
	# Setup new board
	var board_area_width = screen_width * 0.75
	board.board_width = board_area_width - 20
	board.board_height = screen_height - 20
	board.position = Vector2(10, 10)
	add_child(board)
	
	# Reconnect score signal
	board.score_changed.connect(_on_score_changed)
	
	# Reset score
	_on_reset_score()

func spawn_ball():
	var ballPos = Vector2(board.board_width / 2 + randf_range(-100, 100), 0)
	ballPos += board.position  # Offset by board position
	var ball: Ball = _create_weighted_ball(ballPos)
	board.add_child(ball)

func _create_weighted_ball(pos: Vector2) -> Ball:
	var selected_type = _weighted_choice([BallType.NORMAL, BallType.HONEYCOMB])
	match selected_type:
		BallType.NORMAL:
			return preload("res://objects/balls/ball_normal.gd").new(pos, 10.0)
		BallType.HONEYCOMB:
			return preload("res://objects/balls/ball_honeycomb.gd").new(pos, 12.0)
		_:
			return preload("res://objects/balls/ball_normal.gd").new(pos, 10.0)

func _weighted_choice(choices: Array[BallType]) -> BallType:
	var total_weight = 0
	for choice in choices:
		total_weight += choice
	
	var random_value = randf() * total_weight
	var current_weight = 0
	
	for choice in choices:
		current_weight += choice
		if random_value <= current_weight:
			return choice
	
	return choices[0]
