extends CharacterBody2D

var speed = 300.0

@onready var spell_container = $Spells

func _physics_process(delta):
	var direction = Input.get_vector("left", "right", "up", "down").normalized()
	velocity = direction * speed
	move_and_slide()
	

func _input(event):
	if event.is_action_pressed("spell 1"):
		cast_spell(1)


func cast_spell(n):
	if spell_container.get_child_count() < n - 1:
		push_error("Spell index out of range")
		return
	
	var spell: Node2D = spell_container.get_child(n - 1)
	if not spell.has_method("cast"):
		push_error("No Cast Method")
		return
	
	spell.cast()
