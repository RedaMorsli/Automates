extends Control

var automate_item = preload("res://src/ui/AutomateItem.tscn")



func _on_TopBar_add_clicked():
	var item = automate_item.instance()
	$Panel/AutomateList/List.add_child(item)
