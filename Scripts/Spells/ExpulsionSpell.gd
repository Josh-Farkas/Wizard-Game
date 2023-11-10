extends Node2D


var on_cooldown := false

@export var cooldown: float = 2
@export var duration: float = .2
@export var damage: float = 0
@export var knockback: float = 10000
@export var stun_duration: float = 2.0

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var cooldown_timer = $Cooldown
@onready var duration_timer = $Duration
@onready var hitbox = $Hitbox
@onready var particles = $CPUParticles2D

# Called when the node enters the scene tree for the first time.
func _ready():
	cooldown_timer.wait_time = cooldown
	duration_timer.wait_time = duration
	
	
func cast():
	on_cooldown = true
	cooldown_timer.start()
	duration_timer.start()
	hitbox.monitoring = true
	
	# Custom Logic Here
	global_position = player.global_position
	particles.restart()


func _on_cooldown_timeout():
	on_cooldown = false


func _on_duration_timeout():
	hitbox.monitoring = false


func _on_hitbox_body_entered(body: PhysicsBody2D):
	if body == player:
		return
	
	if body.has_method("apply_force"):
		var direction: Vector2 = body.global_position - global_position
		var distance: float = global_position.distance_squared_to(body.global_position)
		var force = direction * (1 / distance) * knockback
		body.apply_force(force)
	
	if body.has_method("stun"):
		body.stun(stun_duration)
