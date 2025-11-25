extends Control

@onready var header_row: TableRowUI = $VBoxContainer/ScrollContainer/TableContainer/HeaderRow
@onready var table_container: VBoxContainer = $VBoxContainer/ScrollContainer/TableContainer
@export var row_receiver: RowReceiver
@export var row_nodes:Dictionary[Variant, TableRowUI]
const TABLE_ROW_UI = preload("uid://dp3rr1360qvna")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	header_row.create_header_row(row_receiver.table_to_receive)
	row_receiver.insert.connect(row_insert)
	row_receiver.update.connect(row_update)
	row_receiver.delete.connect(row_delete)

func row_insert(new_row:_ModuleTableType):
	var row_ui:TableRowUI = TABLE_ROW_UI.instantiate()
	row_ui.create_row(new_row)
	table_container.add_child(row_ui)
	row_nodes[new_row[new_row.get_meta("primary_key")]] = row_ui

func row_update(prev_row: _ModuleTableType, new_row: _ModuleTableType):
	var row_ui = row_nodes[prev_row[prev_row.get_meta("primary_key")]]
	row_ui.update_row(new_row)

func row_delete(old_row:_ModuleTableType):
	var row_ui = row_nodes[old_row[old_row.get_meta("primary_key")]]
	row_ui.queue_free()
	row_nodes.erase(old_row[old_row.get_meta("primary_key")])
