class_name GameManager extends Node

@export var round_duration : float = 40
@export var round_count : int = 5
@export var victory_round_count : int = 3

# Network Variable 
enum Team {None , Desktop, Mobile}
@export var round_results : Array[Team]

@onready var timer : Timer = $Timer
@onready var neon_engine : NeonEngine = %NeonEngine


static var is_started : bool = false

var round_index : int = 0

func prepare_match():
	# set all round result to null
	for i in range(round_count):
		round_results.append(0)
	
	# be sure that we start at round 0
	round_index = 0
 
func prepare_round():
	is_started = true
	neon_engine.pos = 0
	#TODO reset desktop rotation

var is_last_round : bool : 
	get: return round_index + 1 == round_count

func on_castle_destroyed():
	is_started = false
	round_results[round_index] = Team.Mobile
	if is_last_round : 
		is_started = false
		pass #TODO Display results
	else :
		round_index += 1
		prepare_round()

func on_timer_timeout():
	is_started = false
	round_results[round_index] = Team.Desktop
	if is_last_round : 
		is_started = false
		pass #TODO Display results
	else :
		round_index += 1
		prepare_round()
