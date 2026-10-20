extends Control

#region Arrows
@onready var arrow_u: TextureRect = $UIFrame/Arrows/Arrow_U
@onready var arrow_d: TextureRect = $UIFrame/Arrows/Arrow_D
@onready var arrow_l: TextureRect = $UIFrame/Arrows/Arrow_L
@onready var arrow_r: TextureRect = $UIFrame/Arrows/Arrow_R
#endregion


# INPUT FUNCTION (RUNS ON INPUT)
func _input(event: InputEvent) -> void:
	
#region -----------------------------------------------------------------------
# HIGHLIGHTING ARROWS
#endregion oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
	if event is InputEventKey:
		if event.pressed:
			if event.is_action_pressed("move_forward"):
				arrow_u.visible = true

			if event.is_action_pressed("move_back"):
				arrow_d.visible = true

			if event.is_action_pressed("move_turn_right"):
				arrow_r.visible = true

			if event.is_action_pressed("move_turn_left"):
				arrow_l.visible = true

		else:
			if event.is_action_released("move_forward"):
				arrow_u.visible = false

			if event.is_action_released("move_back"):
				arrow_d.visible = false

			if event.is_action_released("move_turn_right"):
				arrow_r.visible = false

			if event.is_action_released("move_turn_left"):
				arrow_l.visible = false
