extends Resource
class_name ItemLogic


@export var useable: bool
@export var reuseable: bool

@export_enum (
"destroy_object",

"toggle_object_lock",
) var item_preset: String

@export var ids_useable: Array[String] = [
	"gen",
	
]

@export var use_sfx: AudioStream

@export_multiline var use_text_unlocked: String
@export_range(0, 9.9) var text_speed_unlocked: float = 0.03

@export_multiline var use_text_locked: String
@export_range(0, 9.9) var text_speed_locked: float = 0.03
