extends Node3D

@onready var player: CharacterBody3D = $GameViewContainer/GameView/Player

@onready var interact_area: Area2D = $GameViewContainer/InteractArea
@onready var game_view: SubViewport = $GameViewContainer/GameView

@onready var rich_text_label: RichTextLabel = $UI/UIFrame/Textbox/Panel/RichTextLabel
@onready var label: Label = $UI/UIFrame/Textbox/Panel/Label

@onready var text_area: Area2D = $UI/UIFrame/Textbox/TextArea
@onready var interact_text_shape: CollisionShape2D = $UI/UIFrame/Textbox/TextArea/InteractTextShape

@onready var text_timer: Timer = $UI/UIFrame/Textbox/TextTimer
@onready var audio_player: AudioStreamPlayer = $MainAudioStreamPlayer


@onready var arrow_u: TextureRect = $UI/UIFrame/Arrows/Arrow_U
@onready var arrow_d: TextureRect = $UI/UIFrame/Arrows/Arrow_D
@onready var arrow_l: TextureRect = $UI/UIFrame/Arrows/Arrow_L
@onready var arrow_r: TextureRect = $UI/UIFrame/Arrows/Arrow_R

@onready var canvas_layer: CanvasLayer = $CanvasLayer

@onready var dialogue_options: Control = $UI/UIFrame/DialogueOptions


var current_object: Node
var current_object_interacting: Node

var current_item: Node

var base_text_wait_time: float

var full_text: String

var current_character: String


var endlines: Array
var lines: Array
var current_line: int = 0
var text_control: bool
var text_skippable: bool


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # Unlocking mouse
	
	get_window().size = Vector2i(1280, 1200)
	canvas_layer.visible = true


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		current_item = null


# Pushing input to subviewport
func _on_interact_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		game_view.push_input(event)
		
		if event.is_pressed():
			pass
		
		if event.is_released():
			pass


# Interact with objects
func show_object_description(description, text_speed, controllable, skippable):
	var object_collider = current_object_interacting.get_node("CollisionShape3D")
	object_collider.disabled = true
	interact_text_shape.disabled = false
	
	update_textbox(description, text_speed, true, controllable, skippable)


# -------------------------------------------------------------------------------------------------
# USING ITEMS
# -------------------------------------------------------------------------------------------------
func try_item_use(item: Node = current_item, object = current_object):

	if item:
		var object_type: String = object.object_type
		var item_logic: Dictionary = item.use_logic_dict

		if object_type and item_logic[object_type]["useable"]:
			var pair_logic = item_logic[object_type]
			
			audio_player.stream = pair_logic["use_sfx"]
			audio_player.play()
			
			if object.locked:
				update_textbox(pair_logic["use_text_locked"], pair_logic["text_speed_locked"])
			else:
				update_textbox(pair_logic["use_text_unlocked"], pair_logic["text_speed_locked"])
			
			match pair_logic["item_preset"]:
				"destroy_object": current_object.queue_free()
				
				"toggle_object_lock": current_object.locked = !current_object.locked
		
		
			if not pair_logic["reuseable"]:
				current_item.queue_free()
		
		
		# FAILED USAGE TEXTS
		else:
			var text_rando = randi_range(1, 5)
			match text_rando:
				1:
					update_textbox("*? Pointless.", 0.03)
				2:
					update_textbox("*? I don't know how to use that here.", 0.03)
				3:
					update_textbox("*? I am willing, but the body is incapable.", 0.03)
				4:
					update_textbox("*? I see no use.", 0.03)
				_:
					update_textbox("*? Impossible.", 0.03)
# ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo


func interact_description(object_type, text, speed, controllable, skippable):
	
	match object_type:
		"BasicNPC":
			player.can_move = false
			player.can_turn = false
	
	update_textbox(text, speed, true, controllable, skippable)



func update_textbox(new_text: String, text_speed: float = 0, init: bool = true, controllable: bool = true, skippable: bool = true):
	if init:
		rich_text_label.text = ""
		current_line = 0
		full_text = new_text
		text_control = controllable
		text_skippable = skippable
		endlines.clear()
		lines.clear()

		# GETTING ENDLINES (`)
		for i in new_text.length():
			var character = new_text[i]
			if character == "`":
				endlines.append(i)
		
		
		# GETTING LINES IF ENDLINES
		if endlines:
			lines = [full_text.substr(0, endlines[0])]
			new_text = lines[0]
			for i in endlines.size():
				if i + 1  < endlines.size():
					lines.append(full_text.substr(endlines[i] + 1, (endlines[i + 1] - endlines[i]) - 1))
				else:
					lines.append(full_text.substr(endlines[i] + 1))
		else:
			lines = [new_text]

	if endlines and controllable:
		if current_line == 0:
			label.text = "(" + str(current_line + 1)
		elif current_line == lines.size() - 1:
			label.text = str(current_line + 1) + ")"
		else:
			label.text = str(current_line + 1)
 
	rich_text_label.text = new_text
	rich_text_label.visible_characters = -1

	if text_speed:
		text_timer.wait_time = text_speed
		base_text_wait_time = text_speed

		rich_text_label.visible_characters = 0

		text_timer.start()


func end_text():
	update_textbox("")

	dialogue_options.set_visible_options()

	var object_collider = current_object_interacting.get_node("CollisionShape3D")
	object_collider.disabled = false

	player.can_move = true
	player.can_turn = true
	interact_text_shape.disabled = true


func _on_text_timer_timeout() -> void:
	var next_wait_time := base_text_wait_time

	if rich_text_label.visible_characters >= rich_text_label.text.length() or rich_text_label.visible_characters == -1:
		text_timer.stop()
		return


	current_character = rich_text_label.text[rich_text_label.visible_characters]

	rich_text_label.visible_characters += 1


	match current_character:
		":": next_wait_time *= 12
		
		".", "!", "?", "+", "-": next_wait_time *= 8
		
		"," , ";", "&": next_wait_time *= 4
		
		_: next_wait_time = base_text_wait_time


	text_timer.start(next_wait_time)


func _on_text_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and rich_text_label.text:

		if (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT):
			
			if event.button_index == MOUSE_BUTTON_LEFT:
				if rich_text_label.visible_characters == rich_text_label.text.length() or rich_text_label.visible_characters == -1:
					current_line += 1
					if current_line < 0 or current_line > endlines.size():
						end_text()
					else:
						update_textbox(lines[current_line], base_text_wait_time, false, text_control)
				elif text_skippable:
					rich_text_label.visible_characters = -1


			elif event.button_index == MOUSE_BUTTON_RIGHT and text_control:
				current_line -= 1
				
				if current_line < 0 or current_line > endlines.size():
					update_textbox("")
					player.can_move = true
					player.can_turn = true
				else:
					update_textbox(lines[current_line], base_text_wait_time, false, text_control)


# MOVING/TURNING BY CLICKING ARROWS
func _on_arrows_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		match shape_idx:
			0: # FORWARD
				arrow_u.visible = true
				player.queued_move = player.queue_move(player.MoveDirection.FORWARD, player.forward_speed)
			1: # BACK
				arrow_d.visible = true
				player.queued_move = player.queue_move(player.MoveDirection.BACK, player.back_speed)
			2: # LEFT
				arrow_l.visible = true
				player.queued_action = player.QueuedAction.TURN # Set action queue
				player.queued_deg = 90 # Set queued turn
			3: # RIGHT
				arrow_r.visible = true
				player.queued_action = player.QueuedAction.TURN # Set action queue
				player.queued_deg = -90 # Set queued turn

	elif event is InputEventMouseButton:
		arrow_u.visible = false
		arrow_d.visible = false
		arrow_l.visible = false
		arrow_r.visible = false


func _on_arrows_area_mouse_shape_exited(shape_idx: int) -> void:
		arrow_u.visible = false
		arrow_d.visible = false
		arrow_l.visible = false
		arrow_r.visible = false
