extends StaticBody3D

@onready var main = get_node("/root/Main")
@onready var player = get_node("/root/Main/GameViewContainer/GameView/Player")
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var dialogue_options: Control = get_node("/root/Main/UI/UIFrame/DialogueOptions")


@export_group("Dialogue")
@export var initial_text: BasicDialogue

@export var dialogue_dict: Dictionary[String, DynamicDialogue]

func interact():
	main.current_object_interacting = self
	main.show_object_description(initial_text.text, initial_text.text_speed, false, initial_text.skippable)
	
	player.can_move = false
	player.can_turn = false
	
	dialogue_options.current_npc_chatting = self
	dialogue_options.set_visible_options(dialogue_dict.keys())


func process_selected_option(option: String):
	if dialogue_dict[option]:
		var text: String = dialogue_dict[option].text
		var text_speed: float = dialogue_dict[option].text_speed
		var skippable: bool = dialogue_dict[option].skippable
		main.update_textbox(text, text_speed, true, false, skippable)
	
	else:
		main.end_text()
