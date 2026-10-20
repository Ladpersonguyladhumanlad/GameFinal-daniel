extends SubViewport

@export var fps = 15 # Max 60

var count_to_frame: int = 0
var fps_divider = 60/fps

func _ready() -> void:
	render_target_update_mode = SubViewport.UPDATE_DISABLED

func _physics_process(delta: float) -> void:

	if count_to_frame >= fps_divider:
		render_target_update_mode = SubViewport.UPDATE_ONCE
		count_to_frame = 0

	count_to_frame += 1
