tool
extends TextureButton

#Defines the Title button: a button for the title screen, noticeable when cursor hovers 

export(String) var buttonText = "UNASSIGNED"

# Called when the node enters the scene tree for the first time.
func _ready():
	$RichTextLabel.bbcode_text = "[center] " + buttonText + " [/center]"
	$RichTextLabel.rect_pivot_offset = rect_size / 2


func _on_Button_mouse_entered():
	if !disabled:
		$RichTextLabel.rect_scale = Vector2(1.1, 1.1)


func _on_Button_mouse_exited():
	$RichTextLabel.rect_scale = Vector2(1, 1)
