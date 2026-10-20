extends Control
@onready var main: Node3D = get_node("/root/Main")


var current_npc_chatting: Node


func set_visible_options(options: Array = []):
	print(options)
	
	var options_amount = options.size()
	print(options_amount)
	
	# Set all children to invisible
	for child in get_children():
		child.visible = false
	
	# Set desired children to visible
	for i in options_amount:
		var current_option = get_child(i)
		current_option.button.text = options[i]
		current_option.visible = true


func select_option(option: String):
	if main.text_timer.is_stopped():
		set_visible_options()
		current_npc_chatting.process_selected_option(option)
