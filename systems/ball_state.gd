class_name BallState

signal spawn_requested(ball_name: String)

var cost: float
var unlocked: Globals.LockedState
var upgrades: BallUpgrades
var timer: Timer
var ball_name: String

func _init(
	_upgrades: BallUpgrades, 
	_unlocked: Globals.LockedState = Globals.LockedState.UNLOCKED, 
	_cost: float = 0.0
) -> void:
	self.upgrades = _upgrades
	self.unlocked = _unlocked
	self.cost = _cost

func initialize_timer(parent_node: Node, _ball_name: String):
	ball_name = _ball_name
	
	if timer:
		timer.queue_free()
	
	timer = Timer.new()
	timer.wait_time = upgrades.upgrades[BallUpgrades.RATE_UPGRADE_STRING].get_value()
	timer.timeout.connect(_on_timer_timeout)
	timer.autostart = unlocked == Globals.LockedState.UNLOCKED
	
	parent_node.add_child(timer)

func start_timer():
	if timer and unlocked == Globals.LockedState.UNLOCKED:
		timer.start()

func stop_timer():
	if timer:
		timer.stop()

func update_timer_rate():
	if timer:
		timer.wait_time = upgrades.upgrades[BallUpgrades.RATE_UPGRADE_STRING].get_value()

func _on_timer_timeout():
	spawn_requested.emit(ball_name)
