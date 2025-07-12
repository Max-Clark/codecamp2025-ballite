extends BallConfig

func _init():
	id = "normal"
	display_name = "Normal Ball"
	script_path = "res://objects/balls/ball_normal.gd"
	shader_path = "res://shaders/ball/normal.gdshader"
	texture_path = ""
	
	# Visual properties
	base_size = 10.0
	color = Color(0.5, 0.5, 0.5, 1)
	
	# Unlock requirements
	unlock_cost = 0
	unlock_order = 0
	
	# Upgrade costs
	drop_rate_base_cost = 50
	multiplier_base_cost = 100
	gravity_base_cost = 75
	
	# Upgrade effectiveness
	drop_rate_improvement = 0.03
	multiplier_improvement = 0.15
	gravity_improvement = 0.1
	
	# Base values
	base_drop_rate = 0.3
	base_multiplier = 1.0
	base_gravity = 1.0
