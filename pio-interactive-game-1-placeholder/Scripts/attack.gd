class_name AttackComponent
extends Node
#how many times entity can attack before cooldown
@export var max_attack: int = 3
#timer to reset attacks
@export var attack_time: float = 0.2
#how many times has attacked
var attack: int = 1


##func handle_attack(body: CharacterBody2D, want_to_attack: bool, delta: float) -> void:
##	if want_to_attack == true and attack > max_attack:
		
		
#call attack animations
#iterate attack variable
#wait until attack animation is done to attack again
#only go to max_attack in the combo
#each attack number has different animation and physics
#reset attack number after a certain time 
#only 1 crouch attack animation
