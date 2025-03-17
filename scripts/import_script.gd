@tool
extends EditorScenePostImport


# Called by the editor when a scene has this script set as the import script in the import tab.
func _post_import(scene: Node) -> Object:
	if scene.get_child_count(true) == 1:
		return scene.get_child(0)
	else:
		return scene
