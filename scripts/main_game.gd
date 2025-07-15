extends Node2D
class_name MainGame

enum BallType { NORMAL = 10, SHINY = 2 }

var board: Node2D
var info_menu: InfoMenu
var screen_width: float
var screen_height: float

var spawn_timer: Timer
var game_state: GameState

func _ready():
	screen_width = get_viewport().get_visible_rect().size.x
	screen_height = get_viewport().get_visible_rect().size.y
	
	setup_game_state()
	setup_board()
	setup_info_menu()
	setup_spawn_timer()
	connect_signals()

func setup_game_state():
	game_state = GameState.new()
	game_state.initialize_ball_timers(self)
	game_state.connect_ball_spawn_signals(self, "_on_ball_spawn_requested")

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
	info_menu.initialize_game_state(game_state)

func setup_spawn_timer():
	# Legacy single timer - now replaced by individual ball timers in GameState
	# Keep this method for compatibility but it's no longer used
	pass

func connect_signals():
	# Connect score signals from board to game state
	if board.has_signal("score_changed"):
		board.score_changed.connect(_on_score_changed)
	
	# Connect info menu button signals
	info_menu.reset_requested.connect(_on_reset)
	info_menu.board_change_requested.connect(_on_board_change)
	info_menu.upgrade_requested.connect(_on_upgrade_requested)
	info_menu.unlock_ball_requested.connect(_on_unlock_ball_requested)

func _on_score_changed(points_earned: int):
	# Add points directly - ball multipliers are applied during spawning
	game_state.add_points(points_earned)
	info_menu.update_display()

func _on_reset():
	# Reset game state (create a new one)
	game_state = GameState.new()
	game_state.initialize_ball_timers(self)
	game_state.connect_ball_spawn_signals(self, "_on_ball_spawn_requested")
	info_menu.initialize_game_state(game_state)
	board.score = 0

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
	
	# Don't reset score when changing boards

func _on_ball_spawn_requested(ball_name: String):
	# Calculate spawn position relative to board
	var ballPos = Vector2(board.board_width / 2 + randf_range(-100, 100), 0)
	ballPos += board.position  # Offset by board position
	
	var ball = game_state.create_ball(ball_name, ballPos)
	if ball:
		board.add_child(ball)

# Legacy method - kept for compatibility
func spawn_ball():
	# This method is no longer used - spawning now handled by individual ball timers
	pass

#func _create_weighted_ball(pos: Vector2) -> Ball:
	## Select random ball config from unlocked balls
	#var unlocked_configs = game_state.get_unlocked_ball_configs()
	#if unlocked_configs.is_empty():
		#return null
	#
	#var selected_config = unlocked_configs[randi() % unlocked_configs.size()]
	#
	## Get upgrade levels for this ball
	#var level_data = {
		#"drop_rate": game_state.ball_drop_rate_levels.get(selected_config.id, 1),
		#"multiplier": game_state.ball_multiplier_levels.get(selected_config.id, 1),
		#"gravity": game_state.ball_gravity_levels.get(selected_config.id, 1)
	#}
	#
	## Use BallFactory to create the ball
	#return BallFactory.create_ball(selected_config, pos, level_data)

func _update_spawn_rate():
	# Legacy method - now handled automatically by individual ball timers
	pass

func _on_upgrade_requested(upgrade_type: String, ball_name: String):
	if game_state.purchase_upgrade(ball_name, upgrade_type):
		# Timer updates are now handled automatically in GameState
		# Update UI to reflect changes
		info_menu.update_display()

func _on_unlock_ball_requested(ball_name: String):
	if game_state.unlock_ball(ball_name):
		# Recreate the UI sections to show new unlocked ball
		info_menu.setup_ball_sections()
		info_menu.update_display()
