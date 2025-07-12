extends Node
class_name GameState

# Currency
var points: int = 0

# Ball configurations and registry
var ball_registry: BallRegistry = BallRegistry.new()
var all_ball_configs: Array[BallConfig] = []

# Ball unlock status (using ball IDs)
var unlocked_ball_ids: Array[String] = []

# Ball-specific upgrade levels (using ball IDs)
var ball_drop_rate_levels: Dictionary = {}
var ball_multiplier_levels: Dictionary = {}
var ball_gravity_levels: Dictionary = {}

signal points_changed(new_points: int)
signal ball_unlocked(ball_id: String)
signal upgrade_purchased(upgrade_type: String, ball_id: String, new_level: int)

func _ready():
	initialize_ball_system()

func initialize_ball_system():
	all_ball_configs = BallRegistry.get_all_balls()
	
	# Initialize first ball as unlocked
	if all_ball_configs.size() > 0:
		var first_ball = all_ball_configs[0]
		unlocked_ball_ids = [first_ball.id]
		_initialize_ball_levels(first_ball.id)

func _initialize_ball_levels(ball_id: String):
	ball_drop_rate_levels[ball_id] = 1
	ball_multiplier_levels[ball_id] = 1
	ball_gravity_levels[ball_id] = 1

func add_points(amount: int):
	points += amount
	points_changed.emit(points)

func spend_points(amount: int) -> bool:
	if points >= amount:
		points -= amount
		points_changed.emit(points)
		return true
	return false

# Ball unlock functions
func can_unlock_next_ball() -> bool:
	var next_ball = get_next_ball_to_unlock()
	return next_ball != null and points >= next_ball.unlock_cost

func get_next_ball_to_unlock() -> BallConfig:
	for config in all_ball_configs:
		if config.id not in unlocked_ball_ids:
			return config
	return null

func unlock_ball(ball_config: BallConfig) -> bool:
	if spend_points(ball_config.unlock_cost):
		unlocked_ball_ids.append(ball_config.id)
		_initialize_ball_levels(ball_config.id)
		ball_unlocked.emit(ball_config.id)
		return true
	return false

func unlock_next_ball() -> bool:
	var next_ball = get_next_ball_to_unlock()
	if next_ball:
		return unlock_ball(next_ball)
	return false

# Ball-specific upgrade functions
func get_ball_config(ball_id: String) -> BallConfig:
	return ball_registry.get_ball_config(ball_id)

func get_ball_drop_rate(ball_id: String) -> float:
	var config = get_ball_config(ball_id)
	if not config:
		return 0.3
	var level = ball_drop_rate_levels.get(ball_id, 1)
	return config.get_drop_rate(level)

func get_ball_multiplier(ball_id: String) -> float:
	var config = get_ball_config(ball_id)
	if not config:
		return 1.0
	var level = ball_multiplier_levels.get(ball_id, 1)
	return config.get_multiplier(level)

func get_ball_gravity(ball_id: String) -> float:
	var config = get_ball_config(ball_id)
	if not config:
		return 1.0
	var level = ball_gravity_levels.get(ball_id, 1)
	return config.get_gravity(level)

# Legacy compatibility method - returns fastest drop rate from unlocked balls
func get_drop_rate() -> float:
	var fastest_rate = 999.0
	for ball_id in unlocked_ball_ids:
		var rate = get_ball_drop_rate(ball_id)
		if rate < fastest_rate:
			fastest_rate = rate
	return fastest_rate if fastest_rate < 999.0 else 0.3

# Cost calculation functions
func get_upgrade_cost(upgrade_type: String, ball_id: String) -> int:
	var config = get_ball_config(ball_id)
	if not config:
		return 0
	
	var level: int
	match upgrade_type:
		"drop_rate":
			level = ball_drop_rate_levels.get(ball_id, 1)
		"multiplier":
			level = ball_multiplier_levels.get(ball_id, 1)
		"gravity":
			level = ball_gravity_levels.get(ball_id, 1)
		_:
			return 0
	
	return config.get_upgrade_cost(upgrade_type, level)

func can_afford_upgrade(upgrade_type: String, ball_id: String) -> bool:
	return points >= get_upgrade_cost(upgrade_type, ball_id)

# Purchase upgrade functions
func purchase_upgrade(upgrade_type: String, ball_id: String) -> bool:
	var cost = get_upgrade_cost(upgrade_type, ball_id)
	if not spend_points(cost):
		return false
	
	match upgrade_type:
		"drop_rate":
			ball_drop_rate_levels[ball_id] = ball_drop_rate_levels.get(ball_id, 1) + 1
		"multiplier":
			ball_multiplier_levels[ball_id] = ball_multiplier_levels.get(ball_id, 1) + 1
		"gravity":
			ball_gravity_levels[ball_id] = ball_gravity_levels.get(ball_id, 1) + 1
		_:
			return false
	
	var new_level = ball_drop_rate_levels.get(ball_id, 1)
	upgrade_purchased.emit(upgrade_type, ball_id, new_level)
	return true

func get_unlocked_ball_configs() -> Array[BallConfig]:
	var configs: Array[BallConfig] = []
	for ball_id in unlocked_ball_ids:
		var config = get_ball_config(ball_id)
		if config:
			configs.append(config)
	return configs

func reset_upgrades():
	points = 0
	unlocked_ball_ids.clear()
	ball_drop_rate_levels.clear()
	ball_multiplier_levels.clear()
	ball_gravity_levels.clear()
	
	# Re-initialize with first ball
	if all_ball_configs.size() > 0:
		var first_ball = all_ball_configs[0]
		unlocked_ball_ids = [first_ball.id]
		_initialize_ball_levels(first_ball.id)
	
	points_changed.emit(points)
