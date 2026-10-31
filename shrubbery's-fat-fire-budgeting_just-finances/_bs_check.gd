extends SceneTree

var frames := 0
var main: Node
var primary: LineEdit
var other: LineEdit

func _init() -> void:
	main = (load("res://main.tscn") as PackedScene).instantiate()
	root.add_child(main)


func _process(_delta: float) -> bool:
	frames += 1
	if frames == 2:
		var config := main.get_node("Config")
		primary = config.find_child("PrimaryCheckingAccountInput", true, false) as LineEdit
		other = config.find_child("SecondaryCheckingAccountInput", true, false) as LineEdit
		primary.text_changed.connect(func(t: String) -> void: print("SIGNAL [", t, "]"))
		primary.text_changed.emit("manual")
		primary.insert_text_at_caret("Typed")
		primary.text = "Everyday Cash"
		other.text = "Backup"
		return false
	if frames == 4:
		var sheet := main.get_node("Balance Sheet")
		var primary_label := sheet.get_node("%PrimaryChecking") as Label
		var other_label := sheet.get_node("%OtherChecking") as Label
		print("PRIMARY [", primary_label.text, "] tip [", primary_label.tooltip_text, "]")
		print("OTHER [", other_label.text, "]")
		primary.text = "   "
	if frames == 6:
		var sheet := main.get_node("Balance Sheet")
		var primary_label := sheet.get_node("%PrimaryChecking") as Label
		print("PRIMARY_CLEARED [", primary_label.text, "]")
		quit()
	return false
