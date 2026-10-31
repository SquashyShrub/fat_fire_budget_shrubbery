extends SceneTree

func _initialize() -> void:
	var main := (load("res://main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	call_deferred("_check", main)


func _check(main: Node) -> void:
	for _frame in 3:
		await process_frame
	var errors: PackedStringArray = []
	for child in main.get_children():
		_walk(child, errors)
	if errors.is_empty():
		print("SCROLL_CHECK_OK")
	else:
		for line in errors:
			print("SCROLL_CHECK_FAIL ", line)
	quit(0 if errors.is_empty() else 1)


func _walk(node: Node, errors: PackedStringArray) -> void:
	if node is ScrollContainer:
		var sc := node as ScrollContainer
		var hbar := sc.get_h_scroll_bar()
		var vbar := sc.get_v_scroll_bar()
		var h_range := hbar.max_value - hbar.page
		var v_range := vbar.max_value - vbar.page
		print("SCROLL ", sc.get_path(), " size=", sc.size, " h=", snappedf(h_range, 1), " v=", snappedf(v_range, 1), " swap=", sc.scroll_horizontal_by_default)
		if sc.size.x < 100 or sc.size.y < 100:
			errors.append(str(sc.get_path()) + " has no area")
		if sc.scroll_horizontal_by_default:
			errors.append(str(sc.get_path()) + " swaps trackpad axes")
		var screen_name: String = str(sc.name)
		if sc.owner != null:
			screen_name = str(sc.owner.name)
		if screen_name in ["Config", "Balance Sheet", "Dashboard"] and h_range <= 1:
			errors.append(screen_name + " cannot scroll horizontally")
		if screen_name in ["Config", "Balance Sheet", "Dashboard", "Expenses"] and v_range <= 1:
			errors.append(screen_name + " cannot scroll vertically")
	for child in node.get_children():
		_walk(child, errors)
