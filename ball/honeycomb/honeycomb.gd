extends Ball
class_name HoneycombBall

const DEFAULT_MULTIPLIER = 4.0
const DEFAULT_GRAVITY = 2.0
const DEFAULT_MASS = 5.0
const DEFAULT_SIZE = 12.0
const DEFAULT_RATE = 10

const BALL_NAME = "HONEYCOMB_BALL"

func _init(pos: Vector2):
	super(pos, BALL_NAME)
