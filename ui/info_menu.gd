extends Control
class_name InfoMenu

@export var menu_width: float = 300

var points_label: Label
var game_state: GameState
var ball_sections: Array[Control] = []
var unlock_button: Button
var current_selected_ball_id: String = ""

signal reset_requested()
signal board_change_requested(board_number: int)
signal upgrade_requested(upgrade_type: String, ball_id: String)
signal unlock_ball_requested()

func _ready():
	setup_ui()

func initialize_game_state(state: GameState):
	game_state = state
	game_state.points_changed.connect(_on_points_changed)
	game_state.upgrade_purchased.connect(_on_upgrade_purchased)
	game_state.ball_unlocked.connect(_on_ball_unlocked)
	setup_ball_tabs()
	setup_ball_sections()
	update_display()
	
func setup_ui():
	# Set size and position
	size = Vector2(menu_width, get_viewport().get_visible_rect().size.y)
	position = Vector2(get_viewport().get_visible_rect().size.x - menu_width, 0)
	
	# Background
	var background = ColorRect.new()
	background.size = size
	background.color = Color(0.2, 0.2, 0.3, 0.9)
	add_child(background)
	
	# Title
	var title = Label.new()
	title.text = "BALL UPGRADES"
	title.position = Vector2(20, 20)
	title.add_theme_font_size_override("font_size", 20)
	add_child(title)
	
	# Points section
	var points_title = Label.new()
	points_title.text = "Points:"
	points_title.position = Vector2(20, 50)
	points_title.add_theme_font_size_override("font_size", 14)
	add_child(points_title)
	
	points_label = Label.new()
	points_label.text = "0"
	points_label.position = Vector2(20, 70)
	points_label.add_theme_font_size_override("font_size", 20)
	points_label.add_theme_color_override("font_color", Color.YELLOW)
	add_child(points_label)
	
	# Ball selection tabs
	setup_ball_tabs()
	
	# Unlock next ball button
	unlock_button = Button.new()
	unlock_button.text = "Unlock Honeycomb (500 pts)"
	unlock_button.position = Vector2(20, 140)
	unlock_button.size = Vector2(260, 30)
	unlock_button.pressed.connect(_on_unlock_ball)
	add_child(unlock_button)
	
	# Reset button
	var reset_button = Button.new()
	reset_button.text = "Reset All"
	reset_button.position = Vector2(20, 600)
	reset_button.size = Vector2(260, 30)
	reset_button.pressed.connect(_on_reset_pressed)
	add_child(reset_button)
	
	# Board selection section
	var board_title = Label.new()
	board_title.text = "Boards:"
	board_title.position = Vector2(20, 640)
	board_title.add_theme_font_size_override("font_size", 14)
	add_child(board_title)
	
	# Board buttons (smaller, in a grid)
	for i in range(4):
		var board_button = Button.new()
		board_button.text = str(i + 1)
		var row = i / 2
		var col = i % 2
		board_button.position = Vector2(20 + col * 70, 660 + row * 35)
		board_button.size = Vector2(60, 30)
		board_button.pressed.connect(_on_board_pressed.bind(i + 1))
		add_child(board_button)

func setup_ball_tabs():
	if not game_state:
		return
	
	# Create tabs for all ball configs
	var all_configs = game_state.all_ball_configs
	for i in range(all_configs.size()):
		var config = all_configs[i]
		var tab_button = Button.new()
		tab_button.text = config.display_name.substr(0, 8)  # Shortened for space
		tab_button.position = Vector2(20 + i * 90, 100)
		tab_button.size = Vector2(85, 25)
		tab_button.pressed.connect(_on_ball_tab_pressed.bind(config.id))
		add_child(tab_button)

func setup_ball_sections():
	if not game_state:
		return
		
	# Clear existing sections
	for section in ball_sections:
		section.queue_free()
	ball_sections.clear()
	
	# Create sections for each ball config
	var all_configs = game_state.all_ball_configs
	for config in all_configs:
		var section = Control.new()
		section.position = Vector2(20, 180)
		section.size = Vector2(260, 400)
		section.visible = false  # Will be shown when selected
		
		# Ball title
		var ball_title = Label.new()
		ball_title.text = config.display_name
		ball_title.position = Vector2(0, 0)
		ball_title.add_theme_font_size_override("font_size", 16)
		ball_title.add_theme_color_override("font_color", Color.CYAN)
		section.add_child(ball_title)
		
		# Create upgrade buttons for this ball
		create_upgrade_buttons(section, config.id)
		
		add_child(section)
		ball_sections.append(section)
	
	# Set first unlocked ball as selected
	if not game_state.unlocked_ball_ids.is_empty():
		current_selected_ball_id = game_state.unlocked_ball_ids[0]
		_update_ball_section_visibility()

func _update_ball_section_visibility():
	for i in range(ball_sections.size()):
		var config = game_state.all_ball_configs[i]
		var is_selected = (config.id == current_selected_ball_id)
		var is_unlocked = config.id in game_state.unlocked_ball_ids
		ball_sections[i].visible = is_selected and is_unlocked

func create_upgrade_buttons(parent: Control, ball_id: String):
	var upgrade_types = ["drop_rate", "multiplier", "gravity"]
	var upgrade_names = ["Drop Rate", "Point Multiplier", "Gravity"]
	
	for i in range(3):
		var y_pos = 40 + i * 80
		
		# Upgrade title
		var title = Label.new()
		title.text = upgrade_names[i] + ":"
		title.position = Vector2(0, y_pos)
		title.add_theme_font_size_override("font_size", 14)
		parent.add_child(title)
		
		# Info label
		var info = Label.new()
		info.name = upgrade_types[i] + "_info"
		info.position = Vector2(0, y_pos + 20)
		info.add_theme_font_size_override("font_size", 12)
		parent.add_child(info)
		
		# Upgrade button
		var button = Button.new()
		button.name = upgrade_types[i] + "_button"
		button.position = Vector2(0, y_pos + 40)
		button.size = Vector2(240, 30)
		button.pressed.connect(_on_upgrade_button_pressed.bind(upgrade_types[i], ball_id))
		parent.add_child(button)

func update_display():
	if not game_state:
		return
		
	points_label.text = str(game_state.points)
	
	# Update unlock button
	var next_ball = game_state.get_next_ball_to_unlock()
	if next_ball:
		var ball_names = ["", "Honeycomb", "Shiny"]
		var cost = game_state.get_unlock_cost(next_ball)
		unlock_button.text = "Unlock %s (%d pts)" % [ball_names[next_ball], cost]
		unlock_button.disabled = not game_state.can_unlock_next_ball()
		unlock_button.visible = true
	else:
		unlock_button.visible = false
	
	# Update all ball sections
	for config in game_state.all_ball_configs:
		update_ball_section(config.id)

func update_ball_section(ball_id: String):
	var ball_index = -1
	for i in range(game_state.all_ball_configs.size()):
		if game_state.all_ball_configs[i].id == ball_id:
			ball_index = i
			break
	
	if ball_index == -1 or ball_index >= ball_sections.size():
		return
		
	var section = ball_sections[ball_index]
	var is_unlocked = ball_id in game_state.unlocked_ball_ids
	
	if not is_unlocked:
		return
	
	# Update upgrade info and buttons
	var upgrade_types = ["drop_rate", "multiplier", "gravity"]
	for upgrade_type in upgrade_types:
		var info_label = section.get_node(upgrade_type + "_info")
		var button = section.get_node(upgrade_type + "_button")
		
		if info_label and button:
			var level = game_state.ball_drop_rate_levels.get(ball_id, 1) if upgrade_type == "drop_rate" else (game_state.ball_multiplier_levels.get(ball_id, 1) if upgrade_type == "multiplier" else game_state.ball_gravity_levels.get(ball_id, 1))
			var value = game_state.get_ball_drop_rate(ball_id) if upgrade_type == "drop_rate" else (game_state.get_ball_multiplier(ball_id) if upgrade_type == "multiplier" else game_state.get_ball_gravity(ball_id))
			var cost = game_state.get_upgrade_cost(upgrade_type, ball_id)
			
			# Format info text
			var info_text = ""
			match upgrade_type:
				"drop_rate":
					info_text = "Level %d (%.2fs)" % [level, value]
				"multiplier":
					info_text = "Level %d (%.1fx)" % [level, value]
				"gravity":
					info_text = "Level %d (%.1fx)" % [level, value]
			
			info_label.text = info_text
			button.text = "Upgrade (%d pts)" % cost
			button.disabled = not game_state.can_afford_upgrade(upgrade_type, ball_id)

func _on_points_changed(_new_points: int):
	update_display()

func _on_upgrade_purchased(_upgrade_type: String, _ball_id: String, _new_level: int):
	update_display()

func _on_ball_unlocked(_ball_id: String):
	update_display()

func _on_ball_tab_pressed(ball_id: String):
	# Only allow switching to unlocked balls
	if ball_id in game_state.unlocked_ball_ids:
		current_selected_ball_id = ball_id
		_update_ball_section_visibility()

func _on_upgrade_button_pressed(upgrade_type: String, ball_id: String):
	upgrade_requested.emit(upgrade_type, ball_id)

func _on_unlock_ball():
	unlock_ball_requested.emit()

func _on_reset_pressed():
	reset_requested.emit()

func _on_board_pressed(board_number: int):
	board_change_requested.emit(board_number)
