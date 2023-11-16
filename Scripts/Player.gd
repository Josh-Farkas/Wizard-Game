extends CharacterBody2D

const spell_dict = {
	"Expulsion": preload("res://Scenes/Spells/ExpulsionSpell.tscn"),
	"Explosion": preload("res://Scenes/Spells/ExplosionSpell.tscn")
}

@export var speed = 100.0
@export var spell_capacity: int = 2

@onready var spell_container = $Spells

func _ready():
	add_spell("Expulsion")
	add_spell("Explosion")
	

func _physics_process(delta):
	var direction = Input.get_vector("left", "right", "up", "down").normalized()
	velocity = direction * speed
	move_and_slide()
	

func _input(event):
	if event.is_action_pressed("spell 1"):
		cast_spell(1)
	if event.is_action_pressed("spell 2"):
		cast_spell(2)


func cast_spell(n):
	if spell_container.get_child_count() < n - 1:
		push_error("Spell index out of range")
		return
	
	var spell: Node2D = spell_container.get_child(n - 1)
	if not spell.has_method("cast"):
		push_error("No Cast Method")
		return
	
	if spell.on_cooldown:
		return
		
	spell.cast()


func add_spell(spell_name):
	if spell_name not in spell_dict:
		push_error("Spell Not Found")
		return
	
	if spell_container.get_child_count() >= spell_capacity:
		push_error("Capacity Reached")
		return
		
	var spell: PackedScene = spell_dict[spell_name]
	spell_container.add_child(spell.instantiate())
