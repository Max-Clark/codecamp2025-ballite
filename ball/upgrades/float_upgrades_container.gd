class_name FloatUpgradesContainer

var _idx = 0
var _upgrades: Array[FloatUpgrade]

func _init(upgrades: Array[FloatUpgrade]):
	self._upgrades = upgrades
	
func get_value():
	return _upgrades[_idx].value
	
func get_upgrade_cost_array() -> Array[float]:
	var costs: Array[float] = []
	for upg in _upgrades:
		costs.append(upg.cost)
	return costs

func preview_upgrade() -> FloatUpgrade:
	if _idx + 1 >= len(_upgrades):
		return null
	
	return _upgrades[_idx+1]

func buy_upgrade() -> FloatUpgrade:
	if _idx + 1 >= len(_upgrades):
		return null
	
	_idx += 1
	return _upgrades[_idx]
