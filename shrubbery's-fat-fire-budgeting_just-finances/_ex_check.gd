extends SceneTree

var frames := 0
var main: Node

func _init() -> void:
	main = (load("res://main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	for child in main.get_children():
		child.visible = child.name == "Expenses"


func _process(_delta: float) -> bool:
	frames += 1
	if frames == 2:
		var config := main.get_node("Config")
		config.get_node("ScrollContainer/MarginContainer/Sections/MonthlyBudget/AnnualBudgetTable/BudgetCategory1").text = "Groceries"
		config.get_node("ScrollContainer/MarginContainer/Sections/FixedMonthlyCosts/FixedCostTable/BudgetCategory2").text = "Rent"
		config.get_node("ScrollContainer/MarginContainer/Sections/AnnualBudget/AnnualBudgetTable/BudgetCategory1").text = "Insurance"
		var expenses := main.get_node("Expenses")
		expenses.get_node("%AddMonthly").pressed.emit()
		expenses.get_node("%AddAnnual").pressed.emit()
		return false
	if frames == 4:
		var expenses := main.get_node("Expenses")
		var monthly_row: Node = expenses.get_node("%MonthlyRows").get_child(0)
		var annual_row: Node = expenses.get_node("%AnnualRows").get_child(0)
		print("MONTHLY ", _items(monthly_row.get_node("%CategoryOption")))
		print("ANNUAL ", _items(annual_row.get_node("%CategoryOption")))
		print("EMPTY ", expenses.get_node("%MonthlyEmpty").visible, " ", expenses.get_node("%AnnualEmpty").visible)
		print("PERIODS ", expenses.get_node("%YearOption").item_count, " ", expenses.get_node("%MonthOption").get_item_text(0))
		var total: Label = expenses.get_node("MarginContainer/Layout/TableScroll/Sections/MonthlyPanel/MonthlyMargin/MonthlyBox/MonthlyTotal/TotalValue")
		print("TOTAL [", total.text, "]")
		var amount: LineEdit = monthly_row.get_node("%AmountEdit")
		print("AMOUNT_PLACEHOLDER [", amount.placeholder_text, "] ALIGN ", amount.alignment)
		expenses.get_node("%MonthOption").select(9)
		expenses.get_node("%YearOption").select(2)
		print("ROWS_AFTER_PERIOD ", expenses.get_node("%MonthlyRows").get_child_count())
		monthly_row.get_node("%RemoveButton").pressed.emit()
		print("AFTER_REMOVE ", expenses.get_node("%MonthlyRows").get_child_count(), " EMPTY ", expenses.get_node("%MonthlyEmpty").visible)
		expenses.get_node("%AddMonthly").pressed.emit()
		expenses.get_node("%AddMonthly").pressed.emit()
		return false
	if frames == 6:
		var expenses := main.get_node("Expenses")
		var header: Control = expenses.get_node("MarginContainer/Layout/TableScroll/Sections/MonthlyPanel/MonthlyMargin/MonthlyBox/MonthlyHeader/DateHeader")
		var amount_header: Control = expenses.get_node("MarginContainer/Layout/TableScroll/Sections/MonthlyPanel/MonthlyMargin/MonthlyBox/MonthlyHeader/AmountHeader")
		var remove_header: Control = expenses.get_node("MarginContainer/Layout/TableScroll/Sections/MonthlyPanel/MonthlyMargin/MonthlyBox/MonthlyHeader/RemoveHeader")
		var row: Node = expenses.get_node("%MonthlyRows").get_child(0)
		var total: Control = expenses.get_node("MarginContainer/Layout/TableScroll/Sections/MonthlyPanel/MonthlyMargin/MonthlyBox/MonthlyTotal/TotalValue")
		var vendor_header: Control = expenses.get_node("MarginContainer/Layout/TableScroll/Sections/MonthlyPanel/MonthlyMargin/MonthlyBox/MonthlyHeader/VendorHeader")
		var category_header: Control = expenses.get_node("MarginContainer/Layout/TableScroll/Sections/MonthlyPanel/MonthlyMargin/MonthlyBox/MonthlyHeader/CategoryHeader")
		_px(header, "date_header")
		_px(row.get_node("%DateEdit"), "date_field")
		_px(vendor_header, "vendor_header")
		_px(row.get_node("%VendorEdit"), "vendor_field")
		_px(category_header, "category_header")
		_px(row.get_node("%CategoryOption"), "category_field")
		_px(amount_header, "amount_header")
		_px(row.get_node("%AmountEdit"), "amount_field")
		_px(total, "total_dash")
		_px(remove_header, "remove_header")
		_px(row.get_node("%RemoveButton"), "remove_button")
		var image := root.get_viewport().get_texture().get_image()
		print("SHOT ", image.save_png(ProjectSettings.globalize_path("res://_ex_shot.png")), " ", image.get_width(), "x", image.get_height())
		quit()
	return false


func _px(node: Control, label: String) -> void:
	print("%s x=%.1f w=%.1f" % [label, node.global_position.x, node.size.x])


func _items(option: OptionButton) -> PackedStringArray:
	var names := PackedStringArray()
	for index in option.item_count:
		names.append(option.get_item_text(index))
	return names
