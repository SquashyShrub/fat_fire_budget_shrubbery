extends Control

# Reads category names from Config. Rows are temporary and are not saved.

const ROW_SCENE := preload("res://expense_row.tscn")
const FIXED_TABLE := "ScrollContainer/MarginContainer/Sections/FixedMonthlyCosts/FixedCostTable"
const MONTHLY_TABLE := "ScrollContainer/MarginContainer/Sections/MonthlyBudget/AnnualBudgetTable"
const ANNUAL_TABLE := "ScrollContainer/MarginContainer/Sections/AnnualBudget/AnnualBudgetTable"

var _fixed_category: Label
var _monthly_sources: Array[LineEdit] = []
var _annual_sources: Array[LineEdit] = []

func _ready() -> void:
	_ensure_periods()
	%AddMonthly.pressed.connect(_add_row.bind(%MonthlyRows, %MonthlyEmpty, true))
	%AddAnnual.pressed.connect(_add_row.bind(%AnnualRows, %AnnualEmpty, false))
	_bind_categories()
	_update_empty(%MonthlyRows, %MonthlyEmpty)
	_update_empty(%AnnualRows, %AnnualEmpty)


func _ensure_periods() -> void:
	if %YearOption.item_count == 0:
		for year in range(2026, 2031):
			%YearOption.add_item(str(year))
		%YearOption.select(0)
	if %MonthOption.item_count == 0:
		for month in ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]:
			%MonthOption.add_item(month)
		%MonthOption.select(0)


func _bind_categories() -> void:
	var config := _find_config()
	if config == null:
		return
	var fixed := config.get_node_or_null(FIXED_TABLE)
	if fixed != null:
		_fixed_category = fixed.get_node_or_null("AfterTaxRetirement") as Label
		for index in range(2, 10):
			_watch_category(fixed.get_node_or_null("BudgetCategory%d" % index) as LineEdit, true)
	var monthly := config.get_node_or_null(MONTHLY_TABLE)
	if monthly != null:
		for index in range(1, 10):
			_watch_category(monthly.get_node_or_null("BudgetCategory%d" % index) as LineEdit, true)
	var annual := config.get_node_or_null(ANNUAL_TABLE)
	if annual != null:
		for index in range(1, 10):
			_watch_category(annual.get_node_or_null("BudgetCategory%d" % index) as LineEdit, false)


func _watch_category(edit: LineEdit, monthly: bool) -> void:
	if edit == null:
		return
	if monthly:
		_monthly_sources.append(edit)
	else:
		_annual_sources.append(edit)
	edit.text_changed.connect(func(_new_text: String) -> void: _refresh_section(monthly))


func _add_row(rows: VBoxContainer, empty_label: Label, monthly: bool) -> void:
	var row := ROW_SCENE.instantiate()
	rows.add_child(row)
	row.remove_requested.connect(_remove_row.bind(rows, empty_label))
	row.set_categories(_category_names(monthly))
	_update_empty(rows, empty_label)


func _remove_row(row: Node, rows: VBoxContainer, empty_label: Label) -> void:
	if is_instance_valid(row) and row.get_parent() == rows:
		rows.remove_child(row)
		row.queue_free()
	_update_empty(rows, empty_label)


func _update_empty(rows: VBoxContainer, empty_label: Label) -> void:
	empty_label.visible = rows.get_child_count() == 0


func _refresh_section(monthly: bool) -> void:
	var rows: VBoxContainer = %MonthlyRows if monthly else %AnnualRows
	var names := _category_names(monthly)
	for row in rows.get_children():
		if row.has_method("set_categories"):
			row.set_categories(names)


func _category_names(monthly: bool) -> PackedStringArray:
	var names := PackedStringArray()
	if monthly and _fixed_category != null:
		_append_category(names, _fixed_category.text)
	var sources: Array[LineEdit] = _monthly_sources if monthly else _annual_sources
	for edit in sources:
		_append_category(names, edit.text)
	return names


func _append_category(names: PackedStringArray, raw: String) -> void:
	var text := raw.strip_edges()
	while text.ends_with(":"):
		text = text.substr(0, text.length() - 1).strip_edges()
	if text.is_empty() or names.has(text):
		return
	names.append(text)


func _find_config() -> Node:
	var parent := get_parent()
	if parent == null:
		return null
	return parent.get_node_or_null("Config")
