extends Node

var total_score: int = 0
var high_score: int = 0
var balls_dropped: int = 0

signal score_changed(new_score: int)

func add_score(points: int):
	total_score += points
	if total_score > high_score:
		high_score = total_score
	score_changed.emit(total_score)

func reset_score():
	total_score = 0
	balls_dropped = 0
	score_changed.emit(total_score)

func increment_balls_dropped():
	balls_dropped += 1
