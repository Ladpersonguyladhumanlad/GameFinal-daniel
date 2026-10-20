extends StaticBody3D

@onready var main = get_node("/root/Main")
@onready var player = get_node("/root/Main/GameViewContainer/GameView/Player")
@onready var item_slots: Node = $"/root/Main/UI/ItemSlots"
@onready var interact_text_shape = get_node("/root/Main/UI/UIFrame/Textbox/TextArea/InteractTextShape")
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D


@export_group("Interaction")
@export_enum (
	"Door",
	"Torch",
	"Fire",
	"BasicNPC",
) var object_type: String


@export var object_ids: Array[String] = [
	"gen"
]


enum InteractLogics {
	NONE,
	GIVE_ITEM,
	UNLOCK,
	STOP_PLAYER,
}
@export var interact_logic: InteractLogics
@export var sub_interact_logic: InteractLogics

@export var destroy_on_use: bool = false
@export var locked: bool

@export var use_logic_on_locked: bool = false
@export var use_sub_logic_on_locked: bool = false


@export_group("Unlocked Description")
@export_multiline var description_unlocked: String
@export var description_unlocked_text_speed: float
@export var description_unlocked_controllable: bool = false
@export var description_unlocked_skippable: bool = true

@export_group("Locked Description")
@export_multiline var description_locked: String
@export var description_locked_text_speed: float
@export var description_locked_controllable: bool = false
@export var description_locked_skippable: bool = true


func _ready() -> void:
	if interact_logic == InteractLogics.GIVE_ITEM:
		var initial_item: Node = get_child(2)
		initial_item.process_mode = Node.PROCESS_MODE_DISABLED
		initial_item.visible = false


func interact() -> void:
	main.current_object_interacting = self
	
	if locked:
		main.show_object_description(description_locked, description_locked_text_speed, description_locked_controllable, description_locked_skippable)
		
		if use_logic_on_locked:
			match_interact_logic(interact_logic)
		if use_sub_logic_on_locked:
			match_interact_logic(sub_interact_logic)
		
	else:
		main.show_object_description(description_unlocked, description_unlocked_text_speed, description_unlocked_controllable, description_unlocked_skippable)
		
		match_interact_logic(interact_logic)
		match_interact_logic(sub_interact_logic)

		if destroy_on_use:
			queue_free()


func match_interact_logic(logic: InteractLogics):
	if not logic == InteractLogics.NONE:
		match logic:
			InteractLogics.UNLOCK:
				locked = false
			
			InteractLogics.GIVE_ITEM:
				var item: Node = get_child(2)
				if item:
					item_slots.receive_item(item)
			
			InteractLogics.STOP_PLAYER:
				player.can_move = false
				player.can_turn = false
