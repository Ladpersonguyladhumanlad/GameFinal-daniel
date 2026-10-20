extends Node2D

const ITEM_LOGIC = preload("uid://dxsm2k6x6jb8q")

@export var icon: Texture2D

@export_multiline var description: String
@export var description_text_speed: float

@export var use_logic_dict: Dictionary[String, ItemLogic] = {
	"Door": ITEM_LOGIC,
	"Torch": ITEM_LOGIC,
	"Fire": ITEM_LOGIC,
}


@onready var main = get_node("/root/Main")
@onready var grab_box: Area2D = $GrabBox

@onready var icon_rect: TextureRect = $IconRect

var selected := false # Has the player selected the UI?
var mouse_offset := Vector2.ZERO
var base_position = 0


func _ready() -> void:
	if visible:
		init()


func init() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	icon_rect.texture = icon
	base_position = get_parent().global_position
	global_position = base_position
	visible = true


# Runs on input
func _input(event: InputEvent) -> void:
	if selected:
		if (
		event is InputEventMouseButton and
		event.button_index == MOUSE_BUTTON_LEFT and 
		event.is_released()):

		# On release
			selected = false
			z_index = 1

			if global_position == base_position:
				main.update_textbox(description, description_text_speed)
			else:
				main.current_item = self
				
				global_position = base_position
		
		elif event is InputEventMouseMotion:
			position = event.position + mouse_offset


func _on_grab_box_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# Is the input a left mouse click?
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:

	# On press
		if event.pressed:
			mouse_offset = position - event.position
			selected = true

			z_index = 3
