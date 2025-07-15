extends Control
class_name InfoMenu

@export var menu_width: float = 300

var points_label: Label
var fps_label: Label
var game_state: GameState
var ball_sections: Array[Control] = []
var current_selected_ball_id: String = ""

signal reset_requested()
signal board_change_requested(board_number: int)
signal upgrade_requested(upgrade_type: String, ball_name: String)
signal unlock_ball_requested(ball_name: String)

func _ready():
	setup_ui()

func _process(_delta):
	if fps_label:
		fps_label.text = "FPS: " + str(Engine.get_frames_per_second())

func initialize_game_state(state: GameState):
	game_state = state
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
	
	# FPS counter
	fps_label = Label.new()
	fps_label.text = "FPS: 60"
	fps_label.position = Vector2(20, 45)
	fps_label.add_theme_font_size_override("font_size", 12)
	fps_label.add_theme_color_override("font_color", Color.GREEN)
	add_child(fps_label)
	
	# Points section
	var points_title = Label.new()
	points_title.text = "Points:"
	points_title.position = Vector2(20, 70)
	points_title.add_theme_font_size_override("font_size", 14)
	add_child(points_title)
	
	points_label = Label.new()
	points_label.text = "0"
	points_label.position = Vector2(20, 90)
	points_label.add_theme_font_size_override("font_size", 20)
	points_label.add_theme_color_override("font_color", Color.YELLOW)
	add_child(points_label)
	
	## Ball selection tabs
	#setup_ball_tabs()
	
	# Unlock next ball button will be created dynamically
	
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
		var row = int(i / 2)
		var col = i % 2
		board_button.position = Vector2(20 + col * 70, 660 + row * 35)
		board_button.size = Vector2(60, 30)
		board_button.pressed.connect(_on_board_pressed.bind(i + 1))
		add_child(board_button)

#func setup_ball_tabs():
	#if not game_state:
		#return
	#
	## Create tabs for all ball configs
	##var all_configs = game_state.all_ball_configs
	#for i in range(all_configs.size()):
		#var config = all_configs[i]
		#var tab_button = Button.new()
		#tab_button.text = config.display_name.substr(0, 8)  # Shortened for space
		#tab_button.position = Vector2(20 + i * 90, 100)
		#tab_button.size = Vector2(85, 25)
		#tab_button.pressed.connect(_on_ball_tab_pressed.bind(config.id))
		#add_child(tab_button)

func setup_ball_sections():
	if not game_state:
		return
		
	# Clear existing sections
	for section in ball_sections:
		section.queue_free()
	ball_sections.clear()
	
	var y_offset = 100
	
	# Create unlock buttons for locked balls
	var locked_balls = game_state.get_locked_balls()
	for ball_name in locked_balls:
		var unlock_button = Button.new()
		unlock_button.name = "unlock_" + ball_name
		var cost = game_state.get_unlock_cost(ball_name)
		unlock_button.text = "Unlock %s (%.0f pts)" % [ball_name.replace("_", " ").capitalize(), cost]
		unlock_button.position = Vector2(20, y_offset)
		unlock_button.size = Vector2(260, 30)
		unlock_button.pressed.connect(_on_unlock_ball.bind(ball_name))
		add_child(unlock_button)
		y_offset += 40
	
	# Create sections for unlocked balls
	var unlocked_balls = game_state.get_unlocked_balls()
	for ball_name in unlocked_balls:
		var section = Control.new()
		section.position = Vector2(20, y_offset)
		section.size = Vector2(260, 300)
		
		# Ball title
		var ball_title = Label.new()
		ball_title.text = ball_name.replace("_", " ").capitalize()
		ball_title.position = Vector2(0, 0)
		ball_title.add_theme_font_size_override("font_size", 16)
		ball_title.add_theme_color_override("font_color", Color.CYAN)
		section.add_child(ball_title)
		
		# Create upgrade buttons for this ball
		create_upgrade_buttons(section, ball_name)
		
		add_child(section)
		ball_sections.append(section)
		y_offset += 320

#func _update_ball_section_visibiliS

func create_upgrade_buttons(parent: Control, ball_name: String):
	var upgrade_types = [BallUpgrades.RATE_UPGRADE_STRING, BallUpgrades.MULT_UPGRADE_STRING, BallUpgrades.GRAV_UPGRADE_STRING, BallUpgrades.MASS_UPGRADE_STRING, BallUpgrades.SIZE_UPGRADE_STRING]
	var upgrade_names = ["Drop Rate", "Point Multiplier", "Gravity", "Mass", "Size"]
	
	for i in range(upgrade_types.size()):
		var y_pos = 40 + i * 55
		
		# Upgrade title
		var title = Label.new()
		title.text = upgrade_names[i] + ":"
		title.position = Vector2(0, y_pos)
		title.add_theme_font_size_override("font_size", 12)
		parent.add_child(title)
		
		# Info label
		var info = Label.new()
		info.name = upgrade_types[i] + "_info"
		info.position = Vector2(0, y_pos + 15)
		info.add_theme_font_size_override("font_size", 10)
		parent.add_child(info)
		
		# Upgrade button
		var button = Button.new()
		button.name = upgrade_types[i] + "_button"
		button.position = Vector2(0, y_pos + 30)
		button.size = Vector2(240, 25)
		button.pressed.connect(_on_upgrade_button_pressed.bind(upgrade_types[i], ball_name))
		parent.add_child(button)

func update_display():
	if not game_state:
		return
		
	points_label.text = str(game_state.points)
	
	# Update unlock buttons
	var locked_balls = game_state.get_locked_balls()
	for ball_name in locked_balls:
		var unlock_button = get_node_or_null("unlock_" + ball_name)
		if unlock_button:
			unlock_button.disabled = not game_state.can_unlock_ball(ball_name)
	
	# Update all ball sections
	var unlocked_balls = game_state.get_unlocked_balls()
	for ball_name in unlocked_balls:
		update_ball_section(ball_name)

func update_ball_section(ball_name: String):
	# Find the section for this ball
	var section: Control = null
	for ball_section in ball_sections:
		if ball_section.get_child(0).text.to_upper().replace(" ", "_") + "_BALL" == ball_name:
			section = ball_section
			break
	
	if not section:
		return
	
	# Update upgrade info and buttons
	var upgrade_types = [BallUpgrades.RATE_UPGRADE_STRING, BallUpgrades.MULT_UPGRADE_STRING, BallUpgrades.GRAV_UPGRADE_STRING, BallUpgrades.MASS_UPGRADE_STRING, BallUpgrades.SIZE_UPGRADE_STRING]
	for upgrade_type in upgrade_types:
		var info_label = section.get_node_or_null(upgrade_type + "_info")
		var button = section.get_node_or_null(upgrade_type + "_button")
		
		if info_label and button:
			var value = game_state.get_upgrade_value(ball_name, upgrade_type)
			var cost = game_state.get_upgrade_cost(ball_name, upgrade_type)
			
			# Format info text
			var info_text = ""
			match upgrade_type:
				BallUpgrades.RATE_UPGRADE_STRING:
					info_text = "Current: %.1fs" % value
				BallUpgrades.MULT_UPGRADE_STRING:
					info_text = "Current: %.1fx" % value
				BallUpgrades.GRAV_UPGRADE_STRING:
					info_text = "Current: %.1fx" % value
				BallUpgrades.MASS_UPGRADE_STRING:
					info_text = "Current: %.1f" % value
				BallUpgrades.SIZE_UPGRADE_STRING:
					info_text = "Current: %.1f" % value
			
			info_label.text = info_text
			if cost > 0:
				button.text = "Upgrade (%.0f pts)" % cost
				button.disabled = not game_state.can_upgrade(ball_name, upgrade_type)
			else:
				button.text = "Max Level"
				button.disabled = true

func _on_points_changed(_new_points: int):
	update_display()

func _on_upgrade_purchased(_upgrade_type: String, _ball_id: String, _new_level: int):
	update_display()

func _on_ball_unlocked(_ball_id: String):
	update_display()

#func _on_ball_tab_pressed(ball_id: String):
	## Only allow switching to unlocked balls
	#if ball_id in game_state.unlocked_ball_ids:
		#current_selected_ball_id = ball_id
		#_update_ball_section_visibility()

func _on_upgrade_button_pressed(upgrade_type: String, ball_name: String):
	upgrade_requested.emit(upgrade_type, ball_name)

func _on_unlock_ball(ball_name: String):
	unlock_ball_requested.emit(ball_name)

func _on_reset_pressed():
	reset_requested.emit()

func _on_board_pressed(board_number: int):
	board_change_requested.emit(board_number)
