class_name GameState

var points: int = 0

var ball_state: Dictionary = {
	NormalBall.BALL_NAME: BallState.new(
		BallUpgrades.new(
			MultUpgradesContainer.new([
				FloatUpgrade.new(0, NormalBall.DEFAULT_MULTIPLIER),
				FloatUpgrade.new(1000, NormalBall.DEFAULT_MULTIPLIER * 1.1),
				FloatUpgrade.new(10000, NormalBall.DEFAULT_MULTIPLIER * 1.2),
				FloatUpgrade.new(100000, NormalBall.DEFAULT_MULTIPLIER * 1.3)
			]),
			GravUpgradesContainer.new([
				FloatUpgrade.new(0, NormalBall.DEFAULT_GRAVITY),
				FloatUpgrade.new(100000, NormalBall.DEFAULT_GRAVITY)
			]),
			MassUpgradesContainer.new([
				FloatUpgrade.new(0, NormalBall.DEFAULT_MASS),
				FloatUpgrade.new(100000, NormalBall.DEFAULT_MASS * 2.0)
			]),
			SizeUpgradesContainer.new([
				FloatUpgrade.new(0, NormalBall.DEFAULT_SIZE),
				FloatUpgrade.new(1000, NormalBall.DEFAULT_SIZE * 0.95),
				FloatUpgrade.new(100000, NormalBall.DEFAULT_SIZE * 0.90),
				FloatUpgrade.new(1000000, NormalBall.DEFAULT_SIZE * 0.85)
			]),
			RateUpgradesContainer.new([
				FloatUpgrade.new(0, NormalBall.DEFAULT_RATE),
				FloatUpgrade.new(100, NormalBall.DEFAULT_RATE - 1),
				FloatUpgrade.new(1000, NormalBall.DEFAULT_RATE - 2),
				FloatUpgrade.new(10000, NormalBall.DEFAULT_RATE - 4),
			])
		),
		Globals.LockedState.UNLOCKED,
		0.0
	),
	HoneycombBall.BALL_NAME:  BallState.new(
		BallUpgrades.new(
			MultUpgradesContainer.new([
				FloatUpgrade.new(0, HoneycombBall.DEFAULT_MULTIPLIER),
				FloatUpgrade.new(1000, HoneycombBall.DEFAULT_MULTIPLIER * 1.1),
				FloatUpgrade.new(10000, HoneycombBall.DEFAULT_MULTIPLIER * 1.2),
				FloatUpgrade.new(100000, HoneycombBall.DEFAULT_MULTIPLIER * 1.3)
			]),
			GravUpgradesContainer.new([
				FloatUpgrade.new(0, HoneycombBall.DEFAULT_GRAVITY),
				FloatUpgrade.new(100000, HoneycombBall.DEFAULT_GRAVITY)
			]),
			MassUpgradesContainer.new([
				FloatUpgrade.new(0, HoneycombBall.DEFAULT_MASS),
				FloatUpgrade.new(100000, HoneycombBall.DEFAULT_MASS * 2.0)
			]),
			SizeUpgradesContainer.new([
				FloatUpgrade.new(0, HoneycombBall.DEFAULT_SIZE),
				FloatUpgrade.new(1000, HoneycombBall.DEFAULT_SIZE * 0.95),
				FloatUpgrade.new(100000, HoneycombBall.DEFAULT_SIZE * 0.90),
				FloatUpgrade.new(1000000, HoneycombBall.DEFAULT_SIZE * 0.85)
			]),
			RateUpgradesContainer.new([
				FloatUpgrade.new(0, HoneycombBall.DEFAULT_RATE),
				FloatUpgrade.new(100, HoneycombBall.DEFAULT_RATE - 1),
				FloatUpgrade.new(1000, HoneycombBall.DEFAULT_RATE - 2),
				FloatUpgrade.new(10000, HoneycombBall.DEFAULT_RATE - 4),
			])
		),
		Globals.LockedState.LOCKED,
		500.0
	),

}

func add_points(amount: int):
	points += amount

func spend_points(amount: float) -> bool:
	if points >= amount:
		points -= int(amount)
		return true
	return false

func get_unlocked_balls() -> Array[String]:
	var unlocked: Array[String] = []
	for ball_name in ball_state.keys():
		if ball_state[ball_name].unlocked == Globals.LockedState.UNLOCKED:
			unlocked.append(ball_name)
	return unlocked

func get_locked_balls() -> Array[String]:
	var locked: Array[String] = []
	for ball_name in ball_state.keys():
		if ball_state[ball_name].unlocked == Globals.LockedState.LOCKED:
			locked.append(ball_name)
	return locked

func unlock_ball(ball_name: String) -> bool:
	if ball_name in ball_state and ball_state[ball_name].unlocked == Globals.LockedState.LOCKED:
		var cost = ball_state[ball_name].cost
		if spend_points(cost):
			ball_state[ball_name].unlocked = Globals.LockedState.UNLOCKED
			# Start timer for newly unlocked ball
			ball_state[ball_name].start_timer()
			return true
	return false

func can_unlock_ball(ball_name: String) -> bool:
	if ball_name in ball_state and ball_state[ball_name].unlocked == Globals.LockedState.LOCKED:
		return points >= ball_state[ball_name].cost 
	return false

func get_unlock_cost(ball_name: String) -> float:
	if ball_name in ball_state:
		return ball_state[ball_name].cost
	return 0.0

func can_upgrade(ball_name: String, upgrade_type: String) -> bool:
	if ball_name not in ball_state:
		return false
	
	var upgrades = ball_state[ball_name].upgrades
	var container = _get_upgrade_container(upgrades, upgrade_type)
	if not container:
		return false
	
	var next_upgrade = container.preview_upgrade()
	return next_upgrade != null and points >= next_upgrade.cost

func purchase_upgrade(ball_name: String, upgrade_type: String) -> bool:
	if not can_upgrade(ball_name, upgrade_type):
		return false
	
	var upgrades = ball_state[ball_name].upgrades
	var container = _get_upgrade_container(upgrades, upgrade_type)
	var next_upgrade = container.preview_upgrade()
	
	if spend_points(next_upgrade.cost):
		container.buy_upgrade()
		# Update timer if rate was upgraded
		if upgrade_type == BallUpgrades.RATE_UPGRADE_STRING:
			ball_state[ball_name].update_timer_rate()
		return true
	return false

func get_upgrade_cost(ball_name: String, upgrade_type: String) -> float:
	if ball_name not in ball_state:
		return 0.0
	
	var upgrades = ball_state[ball_name].upgrades
	var container = _get_upgrade_container(upgrades, upgrade_type)
	if not container:
		return 0.0
	
	var next_upgrade = container.preview_upgrade()
	return next_upgrade.cost if next_upgrade else 0.0

func get_upgrade_value(ball_name: String, upgrade_type: String) -> float:
	if ball_name not in ball_state:
		return 0.0
	
	var upgrades = ball_state[ball_name].upgrades
	var container = _get_upgrade_container(upgrades, upgrade_type)
	if not container:
		return 0.0
	
	return container.get_value()

func get_fastest_drop_rate() -> float:
	var fastest_rate = 999.0
	for ball_name in get_unlocked_balls():
		var rate = get_upgrade_value(ball_name, BallUpgrades.RATE_UPGRADE_STRING)
		if rate < fastest_rate:
			fastest_rate = rate
	return fastest_rate

func _get_upgrade_container(upgrades: BallUpgrades, upgrade_type: String):
	match upgrade_type:
		BallUpgrades.MULT_UPGRADE_STRING:
			return upgrades.upgrades[BallUpgrades.MULT_UPGRADE_STRING]
		BallUpgrades.GRAV_UPGRADE_STRING:
			return upgrades.upgrades[BallUpgrades.GRAV_UPGRADE_STRING]
		BallUpgrades.MASS_UPGRADE_STRING:
			return upgrades.upgrades[BallUpgrades.MASS_UPGRADE_STRING]
		BallUpgrades.SIZE_UPGRADE_STRING:
			return upgrades.upgrades[BallUpgrades.SIZE_UPGRADE_STRING]
		BallUpgrades.RATE_UPGRADE_STRING:
			return upgrades.upgrades[BallUpgrades.RATE_UPGRADE_STRING]
		_:
			return null

func create_ball(ball_name: String, pos: Vector2) -> Ball:
	if ball_name not in ball_state or ball_state[ball_name].unlocked == Globals.LockedState.LOCKED:
		return null
	
	var ball: Ball
	match ball_name:
		NormalBall.BALL_NAME:
			ball = NormalBall.new(pos)
		HoneycombBall.BALL_NAME:
			ball = HoneycombBall.new(pos)
		_:
			return null
	
	# Apply upgrades to the ball
	if ball:
		_apply_upgrades_to_ball(ball, ball_name)
	
	return ball

func _apply_upgrades_to_ball(ball: Ball, ball_name: String):
	# Apply mass
	ball.mass = get_upgrade_value(ball_name, BallUpgrades.MASS_UPGRADE_STRING)
	
	# Apply gravity
	ball.gravity_scale = get_upgrade_value(ball_name, BallUpgrades.GRAV_UPGRADE_STRING)
	
	# Apply size (need to implement in Ball class)
	ball.set_ball_size(get_upgrade_value(ball_name, BallUpgrades.SIZE_UPGRADE_STRING))
	
	# Multiplier will be applied when scoring

func initialize_ball_timers(parent_node: Node):
	# Initialize timers for all ball states
	for ball_name in ball_state.keys():
		var ball_state_obj = ball_state[ball_name]
		ball_state_obj.initialize_timer(parent_node, ball_name)
		
		# Start timer only if ball is unlocked
		if ball_state_obj.unlocked == Globals.LockedState.UNLOCKED:
			ball_state_obj.start_timer()

func connect_ball_spawn_signals(target_object: Object, method_name: String):
	# Connect all ball state spawn signals to the target method
	for ball_name in ball_state.keys():
		var ball_state_obj = ball_state[ball_name]
		if not ball_state_obj.spawn_requested.is_connected(Callable(target_object, method_name)):
			ball_state_obj.spawn_requested.connect(Callable(target_object, method_name))
