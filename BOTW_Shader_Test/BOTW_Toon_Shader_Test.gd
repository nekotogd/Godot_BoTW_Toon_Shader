extends Spatial

onready var shaded = $linkPosed001
onready var unshaded = $link_nonshaded
onready var toggle_button = $CameraRoot/Camera/ToggleButton
onready var camera = $CameraRoot/Camera

func _physics_process(delta):
	if Input.is_action_just_released("wheel_up"):
		camera.translation.z -= delta * 5.0
		camera.translation.z = clamp(camera.translation.z, 0.0, 50.0)
	elif Input.is_action_just_released("wheel_down"):
		camera.translation.z += delta * 5.0
		camera.translation.z = clamp(camera.translation.z, 0.0, 50.0)



func _on_ToggleButton_toggled(button_pressed):
	if button_pressed:
		shaded.visible = true
		unshaded.visible = false
	else:
		shaded.visible = false
		unshaded.visible = true
