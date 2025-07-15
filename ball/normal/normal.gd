extends Ball
class_name NormalBall

const DEFAULT_MULTIPLIER = 1.0
const DEFAULT_GRAVITY = 1.0
const DEFAULT_MASS = 1.0
const DEFAULT_SIZE = 12.0
const DEFAULT_RATE = 10

const BALL_NAME = "NORMAL_BALL"

func _init(pos: Vector2):
	super(pos, BALL_NAME)
