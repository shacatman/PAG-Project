extends Node2D

#Defines the CrystalEffect: controls the effect of the crystal and disables it when needed
#Could be deleted in the future?

var active = true

#crystal collected-remove the crystal effect
func _on_Crystal_newcolor(_color : int) -> void:
	$ShaderRect.material.set_shader_param("active",false)
	active = false


func getSaveData():
	return {"active": active}
	
func loadData(data:Dictionary):
	if data["active"] == false:
		_on_Crystal_newcolor(-1)#disables the shader(input doesn't matter)
