@tool
extends Camera3D

@export var post_processing : bool = true:
	set(p):
		post_processing = p
		if $Postprocess:
			if p:
				$Postprocess.show()
				var a = Vector3(-1, 1, 0).normalized()
				var b = Vector3(1, 0, 0).normalized()
				print("dot: ", a.dot(b))
			else:
				$Postprocess.hide()
		else:
			print("Error: Postprocess node is null")
