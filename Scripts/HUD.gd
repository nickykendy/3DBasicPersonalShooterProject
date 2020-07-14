extends Control

onready var SpdNum = $Num

func _ready():
	SpdNum.text = String(0)

func _on_Character_show_speed(value):
	SpdNum.text = String(value)
