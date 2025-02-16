extends StaticBody3D


var wall_material: Material = null

func _ready() -> void:
	# Get the material from WallMesh
	wall_material = $WallMesh.mesh.material
	if wall_material == null:
		print("Material override not found on WallMesh!")

func _on_player_detector_body_entered(body: Node3D) -> void:
	if body.name == "Player" and wall_material:
		make_material_transparent(wall_material, 0.5) # Set transparency to 50%

func _on_player_detector_body_exited(body: Node3D) -> void:
	if body.name == "Player" and wall_material:
		make_material_transparent(wall_material, 1.0) # Restore full opacity

func make_material_transparent(material: Material, alpha: float):
	if material is StandardMaterial3D:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color.a = alpha # Set alpha value
