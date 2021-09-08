tool
extends MultiMeshInstance

const MeshFactory = preload("mesh_factory.gd")

export(float) var span = 5.0 setget set_span
export(int) var count = 1000 setget set_count
export(Vector2) var width = Vector2(0.01, 0.02) setget set_width
export(Vector2) var height = Vector2(0.04, 0.08) setget set_height
export(Vector2) var sway_yaw = Vector2(0.0, 10.0) setget set_sway_yaw
export(Vector2) var sway_pitch = Vector2(0.0, 10.0) setget set_sway_pitch

func _init():
	rebuild()
	
func _ready():
	rebuild()

func rebuild():
	if !multimesh:
		multimesh = MultiMesh.new()
	multimesh.instance_count = 0
	multimesh.mesh = MeshFactory.simple_grass()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.set_custom_data_format(MultiMesh.CUSTOM_DATA_FLOAT)
	multimesh.set_color_format(MultiMesh.COLOR_NONE)
	multimesh.instance_count = count
	for index in (multimesh.instance_count):
		var pos = Vector3(rand_range(-span,span), 0.0, rand_range(-span,span))
		var basis = Basis(Vector3.UP, deg2rad(rand_range(0, 359)))
		multimesh.set_instance_transform(index, Transform(basis, pos))
		multimesh.set_instance_custom_data(index, Color(
			rand_range(width.x, width.y),
			rand_range(height.x, height.y),
			deg2rad(rand_range(sway_pitch.x, sway_pitch.y)),
			deg2rad(rand_range(sway_yaw.x, sway_yaw.y))
		))
	
func set_span(p_span):
	span = p_span
	rebuild()
	
func set_count(p_count):
	count = p_count
	rebuild()
	
func set_width(p_width):
	width = p_width
	rebuild()
	
func set_height(p_height):
	height = p_height
	rebuild()
	
func set_sway_yaw(p_sway_yaw):
	sway_yaw = p_sway_yaw
	rebuild()
	
func set_sway_pitch(p_sway_pitch):
	sway_pitch = p_sway_pitch
	rebuild()
