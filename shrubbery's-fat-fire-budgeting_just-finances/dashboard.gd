extends Control

# Summary labels only. Category names are read from Config and are not edited here.

const FIXED_TABLE := "ScrollContainer/MarginContainer/Sections/FixedMonthlyCosts/FixedCostTable"
const MONTHLY_TABLE := "ScrollContainer/MarginContainer/Sections/MonthlyBudget/AnnualBudgetTable"
const ANNUAL_TABLE := "ScrollContainer/MarginContainer/Sections/AnnualBudget/AnnualBudgetTable"
const MONTH_NAMES: PackedStringArray = [
	"January", "February", "March", "April", "May", "June",
	"July", "August", "September", "October", "November", "December",
]
const BUDGET_WIDTHS: Array[int] = [280, 120, 120, 130, 150]
const HISTORY_WIDTHS: Array[int] = [250, 148, 148, 148, 148, 148, 148, 148, 150]

var _fixed_category: Label
var _monthly_sources: Array[LineEdit] = []
var _annual_sources: Array[LineEdit] = []

func _ready() -> void:
	_ensure_periods()
	%YearOption.item_selected.connect(func(_index: int) -> void: _apply_period())
	%MonthOption.item_selected.connect(func(_index: int) -> void: _apply_period())
	%HistoryCategory.item_selected.connect(func(_index: int) -> void: _apply_history_selection())
	_bind_categories()
	_refresh_categories()
	_apply_period()


func _ensure_periods() -> void:
	if %YearOption.item_count == 0:
		for year in range(2026, 2031):
			%YearOption.add_item(str(year))
		%YearOption.select(0)
	if %MonthOption.item_count == 0:
		for month in MONTH_NAMES:
			%MonthOption.add_item(month)
		%MonthOption.select(0)
	if %HistoryCategory.item_count == 0:
		%HistoryCategory.add_item("Total")
		%HistoryCategory.select(0)


func _bind_categories() -> void:
	var config := _find_config()
	print("CONFIG_FOUND ", config != null)
	if config == null:
		return
	var fixed := config.get_node_or_null(FIXED_TABLE)
	print("FIXED_TABLE ", fixed)
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
	edit.text_changed.connect(func(_new_text: String) -> void: _refresh_categories())


func _refresh_categories() -> void:
	var monthly := _category_names(true)
	var annual := _category_names(false)
	_fill_rows(%MonthlyRows, monthly, BUDGET_WIDTHS)
	_fill_rows(%AnnualRows, annual, BUDGET_WIDTHS)
	var history := PackedStringArray()
	for category_name in monthly:
		_append_category(history, category_name)
	for category_name in annual:
		_append_category(history, category_name)
	_fill_rows(%HistoryRows, history, HISTORY_WIDTHS)
	%MonthlyEmpty.visible = monthly.is_empty()
	%AnnualEmpty.visible = annual.is_empty()
	%HistoryEmpty.visible = history.is_empty()
	_refresh_history_selector(history)


func _fill_rows(rows: VBoxContainer, names: PackedStringArray, widths: Array[int]) -> void:
	for child in rows.get_children():
		rows.remove_child(child)
		child.queue_free()
	for category_name in names:
		rows.add_child(_summary_row(category_name, widths))


func _summary_row(caption: String, widths: Array[int]) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.add_child(_cell(caption, widths[0], HORIZONTAL_ALIGNMENT_LEFT))
	for index in range(1, widths.size()):
		row.add_child(_cell("—", widths[index], HORIZONTAL_ALIGNMENT_RIGHT))
	return row


func _cell(text: String, width: int, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.custom_minimum_size = Vector2(width, 31)
	label.text = text
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.tooltip_text = text
	return label


func _refresh_history_selector(names: PackedStringArray) -> void:
	var previous := "Total"
	if %HistoryCategory.item_count > 0:
		previous = %HistoryCategory.get_item_text(%HistoryCategory.selected)
	%HistoryCategory.clear()
	%HistoryCategory.add_item("Total")
	for category_name in names:
		%HistoryCategory.add_item(category_name)
	var selected_index := 0
	for index in %HistoryCategory.item_count:
		if %HistoryCategory.get_item_text(index) == previous:
			selected_index = index
			break
	%HistoryCategory.select(selected_index)
	_apply_history_selection()


func _apply_history_selection() -> void:
	if %HistoryCategory.item_count == 0:
		%HistorySelection.text = "Category: Total"
		return
	%HistorySelection.text = "Category: " + %HistoryCategory.get_item_text(%HistoryCategory.selected)


func _apply_period() -> void:
	var year := _selected_year()
	var month_index := clampi(%MonthOption.selected, 0, 11)
	%MonthlyPeriod.text = MONTH_NAMES[month_index] + " " + str(year)
	%AnnualPeriod.text = str(year)
	var labels := _previous_month_labels(year, month_index)
	for index in labels.size():
		var header := get_node_or_null("%HistoryMonth" + str(index + 1)) as Label
		if header != null:
			header.text = labels[index]


func _previous_month_labels(year: int, month_index: int) -> PackedStringArray:
	var labels := PackedStringArray()
	var cursor_month := month_index
	var cursor_year := year
	for _step in 7:
		cursor_month -= 1
		if cursor_month < 0:
			cursor_month = 11
			cursor_year -= 1
	for _step in 7:
		labels.append(MONTH_NAMES[cursor_month] + " " + str(cursor_year))
		cursor_month += 1
		if cursor_month > 11:
			cursor_month = 0
			cursor_year += 1
	return labels


func _selected_year() -> int:
	if %YearOption.item_count == 0:
		return 2026
	return int(%YearOption.get_item_text(%YearOption.selected))


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
