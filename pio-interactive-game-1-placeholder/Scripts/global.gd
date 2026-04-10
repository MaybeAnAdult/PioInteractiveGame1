extends Node

@export_group("colors")
@export var defeated_red: bool = false
@export var defeated_blue: bool = false
@export var defeated_green: bool = false

@export_group("powerups")
@export var max_health_up: int = 0


@export_group("challenges")
@export var play_time: float = 0.0 #achievement(s) for speed
@export var colorless_run: bool = true #false when first color collected - achievement
