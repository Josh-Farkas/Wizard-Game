extends CharacterBody2D

var navigation_target
var force_velocity := Vector2.ZERO
var stunned := false

@export var speed: float = 75.0
@export var force_damping: float = .96

@onready var navigation_agent := $NavigationAgent2D
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")
@onready var stun_timer := $Stunned

func _ready():
	navigation_target = player


func _physics_process(delta):
	force_velocity *= force_damping
	navigation_agent.target_position = navigation_target.global_position

	var direction = navigation_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	
	if stunned:
		velocity = force_velocity
	else:
		velocity = force_velocity + direction * speed
	
	move_and_slide()
	
func apply_force(force: Vector2):
	force_velocity += force


func stun(seconds: float):
	stunned = true
	stun_timer.start(seconds)


func _on_stunned_timeout():
	stunned = false

# ryan wuz here
