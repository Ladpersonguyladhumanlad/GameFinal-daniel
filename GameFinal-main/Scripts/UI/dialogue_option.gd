extends MarginContainer
@onready var dialogue_options: Control = get_parent()
@onready var button: Button = $Panel/Button

func _on_button_button_up() -> void:
	dialogue_options.select_option(button.text)
