extends MeshInstance3D
var MeshHelper = load("res://mesh_helper.gd").new()
var IcoGenerator = load("res://ico2.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	var ico = IcoGenerator.generate(3, 1)
	#var hexa = MeshHelper.dual_operator(ico[0], ico[1])
	var prepared_ico = MeshHelper.prepare_mesh(ico[0], ico[1])
	var indices = prepared_ico[0]
	var verts = prepared_ico[1]
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(mesh, 0)
	surface_tool.generate_normals()
	mesh = surface_tool.commit()
	ResourceSaver.save(mesh, "res://sphere.tres", ResourceSaver.FLAG_COMPRESS)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
