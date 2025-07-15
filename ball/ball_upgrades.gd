class_name BallUpgrades

const MULT_UPGRADE_STRING = "MULT"
const GRAV_UPGRADE_STRING = "GRAV"
const MASS_UPGRADE_STRING = "MASS"
const SIZE_UPGRADE_STRING = "SIZE"
const RATE_UPGRADE_STRING = "RATE"

var upgrades: Dictionary = {
	MULT_UPGRADE_STRING: MultUpgradesContainer,
	GRAV_UPGRADE_STRING: GravUpgradesContainer,
	MASS_UPGRADE_STRING: MassUpgradesContainer,
	SIZE_UPGRADE_STRING: SizeUpgradesContainer,
	RATE_UPGRADE_STRING: RateUpgradesContainer
}

func _init(
	mult: MultUpgradesContainer, 
	grav: GravUpgradesContainer, 
	mass: MassUpgradesContainer, 
	size: SizeUpgradesContainer,
	rate: RateUpgradesContainer
) -> void:
	self.upgrades = {
		MULT_UPGRADE_STRING: mult,
		GRAV_UPGRADE_STRING: grav,
		MASS_UPGRADE_STRING: mass,
		SIZE_UPGRADE_STRING: size,
		RATE_UPGRADE_STRING: rate
	}
