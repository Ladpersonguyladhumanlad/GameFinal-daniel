extends Resource
class_name DynamicDialogue

@export_multiline var text: String
@export var text_speed: float = 0.06
@export var skippable: bool = true

@export var cancellable: bool = true

@export var nested_dialogue_dict: Dictionary[String, DynamicDialogue]
