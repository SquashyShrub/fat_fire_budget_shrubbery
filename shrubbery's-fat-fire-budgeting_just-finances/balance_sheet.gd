extends Control

# Config nicknames are read when that scene is in the tree. Nothing is saved.

const NICKNAME_FIELDS: Dictionary = {
	"PrimaryChecking": "PrimaryCheckingAccountInput",
	"OtherChecking": "SecondaryCheckingAccountInput",
	"Savings1": "SavingsAccountInput1",
	"Savings2": "SavingsAccountInput2",
	"Savings3": "SavingsAccountInput3",
	"Savings4": "SavingsAccountInput4",
	"PreTax": "PreTaxRetirementInput",
	"AfterTax": "AfterTaxRetirementInput",
	"OtherAsset1": "OtherAssetInput1",
	"OtherAsset2": "OtherAssetInput2",
	"OtherAsset3": "OtherAssetInput3",
	"OtherAsset4": "OtherAssetInput4",
	"Rent": "RentMortgageInput",
	"CarLoan": "CarLoanInput",
	"Credit1": "CreditCardInput1",
	"Credit2": "CreditCardInput2",
	"Credit3": "CreditCardInput3",
}

func _ready() -> void:
	_ensure_years()
	_bind_nicknames()


func _ensure_years() -> void:
	if %YearOption.item_count > 0:
		return
	for year in range(2026, 2031):
		%YearOption.add_item(str(year))
	%YearOption.select(0)


func _bind_nicknames() -> void:
	var config := _find_config()
	if config == null:
		return
	for row_name in NICKNAME_FIELDS:
		var label := get_node_or_null("%" + str(row_name)) as Label
		var edit := config.find_child(str(NICKNAME_FIELDS[row_name]), true, false) as LineEdit
		if label == null or edit == null:
			continue
		var fallback := label.text
		_show_nickname(edit.text, label, fallback)
		edit.text_changed.connect(_show_nickname.bind(label, fallback))


func _show_nickname(nickname: String, label: Label, fallback: String) -> void:
	var trimmed := nickname.strip_edges()
	if trimmed.is_empty():
		label.text = fallback
		label.tooltip_text = fallback
	else:
		label.text = trimmed
		label.tooltip_text = "%s (%s)" % [trimmed, fallback]


func _find_config() -> Node:
	var parent := get_parent()
	if parent == null:
		return null
	return parent.get_node_or_null("Config")
