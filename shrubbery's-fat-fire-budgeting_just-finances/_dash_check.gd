extends SceneTree

var frames := 0
var main: Node

func _init() -> void:
	main = (load("res://main.tscn") as PackedScene).instantiate()
	root.add_child(main)


func _process(_delta: float) -> bool:
	frames += 1
	if frames == 2:
		var sheet := main.get_node("Dashboard")
		var errors := PackedStringArray()
		_expect(sheet.get_node("%MonthlyPeriod").text == "January 2026", "monthly period", errors)
		_expect(sheet.get_node("%AnnualPeriod").text == "2026", "annual period", errors)
		_expect(sheet.get_node("%HistoryMonth1").text == "June 2025", "history start", errors)
		_expect(sheet.get_node("%HistoryMonth7").text == "December 2025", "history end", errors)
		_expect(sheet.get_node("%MonthlyRows").get_child_count() == 1, "monthly rows", errors)
		if sheet.get_node("%MonthlyRows").get_child_count() > 0:
			_expect(sheet.get_node("%MonthlyRows").get_child(0).get_child(0).text == "After Tax Retirement Contribution", "fixed category", errors)
		_expect(sheet.get_node("%AnnualEmpty").visible, "annual empty", errors)
		_expect(sheet.get_node("%HistoryCategory").get_item_text(0) == "Total", "selector total", errors)
		_expect(sheet.get_node("%HistoryCategory").item_count == 2, "selector count", errors)
		var config := main.get_node("Config")
		var annual := config.get_node("ScrollContainer/MarginContainer/Sections/AnnualBudget/AnnualBudgetTable/BudgetCategory1") as LineEdit
		var monthly := config.get_node("ScrollContainer/MarginContainer/Sections/MonthlyBudget/AnnualBudgetTable/BudgetCategory1") as LineEdit
		annual.text = "Travel"
		monthly.text = "Groceries"
		sheet.set_meta("errors", errors)
		return false
	if frames == 4:
		var sheet := main.get_node("Dashboard")
		var errors: PackedStringArray = sheet.get_meta("errors")
		_expect(sheet.get_node("%AnnualRows").get_child_count() == 1, "annual row", errors)
		if sheet.get_node("%AnnualRows").get_child_count() > 0:
			_expect(sheet.get_node("%AnnualRows").get_child(0).get_child(0).text == "Travel", "annual name", errors)
		_expect(sheet.get_node("%MonthlyRows").get_child_count() == 2, "monthly plus grocery", errors)
		_expect(not sheet.get_node("%AnnualEmpty").visible, "annual empty hidden", errors)
		_expect(sheet.get_node("%HistoryCategory").item_count == 4, "selector grew", errors)
		sheet.get_node("%MonthOption").select(9)
		_expect(sheet.get_node("%MonthlyPeriod").text == "October 2026", "october period", errors)
		_expect(sheet.get_node("%HistoryMonth1").text == "March 2026", "october history start", errors)
		_expect(sheet.get_node("%HistoryMonth7").text == "September 2026", "october history end", errors)
		_expect(sheet.get_node("%AnnualPeriod").text == "2026", "year unchanged", errors)
		sheet.get_node("%HistoryCategory").select(0)
		_expect(sheet.get_node("%HistorySelection").text == "Category: Total", "selection label", errors)
		var header_parent := str(sheet.get_node("MarginContainer/Layout/Header").get_parent().name)
		var scroll_parent := str(sheet.get_node("MarginContainer/Layout/TableScroll").get_parent().name)
		_expect(header_parent == "Layout" and scroll_parent == "Layout", "header outside scroll", errors)
		if errors.is_empty():
			print("DASHBOARD_OK")
		else:
			for err in errors:
				print("FAIL ", err)
		quit()
	return false


func _expect(ok: bool, label: String, errors: PackedStringArray) -> void:
	if not ok:
		errors.append(label)
