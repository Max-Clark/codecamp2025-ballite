extends Ball

func _init():
	self._shaderMaterial = ShaderMaterial.new()
	self._shaderMaterial.shader = preload("res://shaders/ball/honeycomb.gdshader")

	self._multiplierUpgrades = [
		FloatUpgrade.new(0, 1),
		FloatUpgrade.new(1000, 1.1),
		FloatUpgrade.new(10000, 1.2),
		FloatUpgrade.new(100000, 1.3),
		FloatUpgrade.new(1000000, 1.4),
	]
	self._gravityUpgrades = [
		FloatUpgrade.new(0, 1),
		FloatUpgrade.new(1000, 1.1),
		FloatUpgrade.new(10000, 1.2),
		FloatUpgrade.new(100000, 1.3),
		FloatUpgrade.new(1000000, 1.4),
	]
	
	#
	#id = "honeycomb"
	#display_name = "Honeycomb Ball"
	#script_path = "res://objects/balls/ball_honeycomb.gd"
	#shader_path = "res://shaders/ball/honeycomb.gdshader"
	#texture_path = "res://assets/img/honeycomb.jpg"
	#
	## Visual properties
	#base_size = 12.0
	#color = Color(1, 0.8, 0.2, 1)
	#
	## Unlock requirements
	#unlock_cost = 500
	#unlock_order = 1
	#
	## Upgrade costs (more expensive than normal)
	#drop_rate_base_cost = 75
	#multiplier_base_cost = 150
	#gravity_base_cost = 100
	#
	## Upgrade effectiveness (better than normal)
	#drop_rate_improvement = 0.025
	#multiplier_improvement = 0.2
	#gravity_improvement = 0.12
	#
	## Base values (better stats)
	#base_drop_rate = 0.28
	#base_multiplier = 1.2
	#base_gravity = 1.1
#
## Custom scoring: Honeycomb balls get bonus points in multiples of 10
#func calculate_score(base_score: int, ball_level_data: Dictionary) -> int:
	#var score = int(base_score * multiplier)
	#
	## Bonus: +1 point for every 10 base points
	#var bonus = base_score / 10.0
	#return score + bonus
