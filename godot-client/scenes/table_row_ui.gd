extends HBoxContainer
class_name TableRowUI

@export var row : _ModuleTableType
@export var row_export_names : Array[String]
@export var column_labels : Dictionary[String, Label]

func create_row(new_row:_ModuleTableType) -> void:
	row = new_row
	row_export_names = get_exported_variable_names(row)
	for column in row_export_names:
		append_label(column, str(row[column]))


func update_row(new_row:_ModuleTableType) -> void:
	row= new_row
	for column in row_export_names:
		var value : Variant = row[column]
		if value is float:
			value= String.num_scientific(value)
		update_label(column, str(row[column]))

func append_label(column:String, text: String) -> void:
	var label : Label = Label.new()
	label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
	label.text = text
	column_labels[column] = label
	add_child(label)


func update_label(column:String, text:String) -> void:
	var label : Label = column_labels[column]
	label.text=text


func get_exported_variable_names(_row:_ModuleTableType) -> Array[String]:
	var names: Array[String] = []
	var property_list: Array[Dictionary] = row.get_property_list()

	for p in property_list:
		# Check if the property is exported.
		# "usage" contains flags like PROPERTY_USAGE_EDITOR, PROPERTY_USAGE_SCRIPT_VARIABLE, etc.
		# We are looking for properties that are exposed in the editor.
		if p.has("usage") and (p.usage & PROPERTY_USAGE_EDITOR) and (p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
			names.append(p.name)
	return names

func create_header_row(new_row:_ModuleTableType) -> void:
	row = new_row
	row_export_names = get_exported_variable_names(row)
	for column in row_export_names:
		append_label(column, column)
