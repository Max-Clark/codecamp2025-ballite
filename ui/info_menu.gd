extends Control
class_name InfoMenu

@export var menu_width: float = 200

var score_label: Label
var current_score: int = 0

signal score_updated(new_score: int)
signal reset_score_requested()
signal board_change_requested(board_number: int)

func _ready():
	setup_ui()
	
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
	title.text = "INFO"
	title.position = Vector2(20, 20)
	title.add_theme_font_size_override("font_size", 24)
	add_child(title)
	
	# Score section
	var score_title = Label.new()
	score_title.text = "Score:"
	score_title.position = Vector2(20, 80)
	score_title.add_theme_font_size_override("font_size", 18)
	add_child(score_title)
	
	score_label = Label.new()
	score_label.text = "0"
	score_label.position = Vector2(20, 110)
	score_label.add_theme_font_size_override("font_size", 32)
	score_label.add_theme_color_override("font_color", Color.YELLOW)
	add_child(score_label)
	
	# Reset button
	var reset_button = Button.new()
	reset_button.text = "Reset Score"
	reset_button.position = Vector2(20, 170)
	reset_button.size = Vector2(160, 40)
	reset_button.pressed.connect(_on_reset_pressed)
	add_child(reset_button)
	
	# Board selection section
	var board_title = Label.new()
	board_title.text = "Boards:"
	board_title.position = Vector2(20, 230)
	board_title.add_theme_font_size_override("font_size", 18)
	add_child(board_title)
	
	# Board buttons
	for i in range(4):
		var board_button = Button.new()
		board_button.text = "Board " + str(i + 1)
		board_button.position = Vector2(20, 260 + i * 50)
		board_button.size = Vector2(160, 40)
		board_button.pressed.connect(_on_board_pressed.bind(i + 1))
		add_child(board_button)

func update_score(new_score: int):
	current_score = new_score
	score_label.text = str(current_score)
	score_updated.emit(new_score)

func _on_reset_pressed():
	reset_score_requested.emit()

func _on_board_pressed(board_number: int):
	board_change_requested.emit(board_number)
