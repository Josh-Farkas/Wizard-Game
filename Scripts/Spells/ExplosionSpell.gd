extends Node2D

# I can comment + walk you through it if you want
# also remember you can control + click to get to docs of ANYTHING
var on_cooldown := false
var projectile_travelling := false
var direction := Vector2.ZERO

@export var cooldown: float = 5
@export var projectile_speed: float = 50
@export var projectile_duration: float = 3
@export var explosion_duration: float = .2
@export var projectile_damage: float = 0
@export var explosion_damage: float = 100
@export var knockback: float = 2000
@export var stun_duration: float = .3
# The dollar signs are path to the node from this node Timer node yes
# it can be done in code too I just prefer it with nodes
# just instantiate a timer node and then delete it
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var cooldown_timer = $Cooldown
@onready var projectile_duration_timer = $ProjectileDuration
@onready var explosion_duration_timer = $ExplosionDuration
@onready var projectile_hitbox = $ProjectileHitbox
@onready var explosion_hitbox = $ExplosionHitbox
@onready var projectile_particles = $ProjectileHitbox/ProjectileParticles
@onready var explosion_particles = $ExplosionHitbox/ExplosionParticles

# Called when the node enters the scene tree for the first time.
func _ready():
	cooldown_timer.wait_time = cooldown
	projectile_duration_timer.wait_time = projectile_duration
	explosion_duration_timer.wait_time = explosion_duration
	

func cast():
	projectile_particles.emitting = true
	on_cooldown = true
	cooldown_timer.start()
	projectile_duration_timer.start()
	projectile_hitbox.monitoring = true
	
	# Custom Logic Here
	global_position = player.global_position
	projectile_travelling = true
	direction = get_global_mouse_position() - player.global_position
	direction = direction.normalized()
	
	projectile_particles.rotation = atan(direction.y/direction.x)
	

func start_explosion():
	projectile_particles.emitting = false
	explosion_particles.restart()
	projectile_travelling = false
	projectile_hitbox.monitoring = false
	explosion_hitbox.monitoring = true
	explosion_duration_timer.start()


func _on_cooldown_timeout():
	on_cooldown = false


func _on_projectile_duration_timeout():
	start_explosion()


func _on_projectile_hitbox_body_entered(body):
	if body == player:
		return
	if body.has_method("damage"):
		body.damage(projectile_damage)
	
	projectile_duration_timer.stop()
	start_explosion()


func _on_explosion_duration_timeout():
	explosion_hitbox.monitoring = false


func _on_explosion_hitbox_body_entered(body):
	if body == player:
		return
	
	if body.has_method("damage"):
		body.damage(explosion_damage)
	
	if body.has_method("apply_force"):
		var direction: Vector2 = body.global_position - explosion_hitbox.global_position
		var distance: float = explosion_hitbox.global_position.distance_squared_to(body.global_position)
		var force = direction * (1 / distance) * knockback
		body.apply_force(force)
	
	if body.has_method("stun"):
		body.stun(stun_duration)


func _physics_process(delta):
	if projectile_travelling:
		position += direction * projectile_speed * delta
