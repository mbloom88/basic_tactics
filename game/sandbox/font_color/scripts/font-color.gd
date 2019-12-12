extends Control

# Child nodes
onready var _label = $Label

func _ready():
	_label.set("custom_colors/font_color", Color.chartreuse)
