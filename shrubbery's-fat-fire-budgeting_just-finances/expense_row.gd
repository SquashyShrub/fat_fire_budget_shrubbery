extends HBoxContainer

signal remove_requested(row: HBoxContainer)

func _ready() -> void:
	%RemoveButton.pressed.connect(func() -> void: remove_requested.emit(self))


func set_categories(names: PackedStringArray) -> void:
	var option := %CategoryOption as OptionButton
	var current := ""
	if option.item_count > 0 and option.selected >= 0:
		current = option.get_item_text(option.selected)
	option.clear()
	if names.is_empty():
		option.add_item("No categories configured")
		option.select(0)
		return
	var select_index := 0
	for i in names.size():
		option.add_item(names[i])
		if names[i] == current:
			select_index = i
	option.select(select_index)
