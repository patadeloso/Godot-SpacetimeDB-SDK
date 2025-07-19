@tool
class_name Spacetime extends EditorPlugin

const AUTOLOAD_NAME := "SpacetimeDB"
const AUTOLOAD_PATH := "res://addons/SpacetimeDB/Core/SpacetimeDBClient.gd"
const DATA_PATH := "res://spacetime_data/"
const SAVE_PATH := DATA_PATH +"/codegen_data.txt"
const UI_PATH := "res://addons/SpacetimeDB/UI/ui.tscn"

var ui_panel: Control
var http_request = HTTPRequest.new()
var module_prefab:Control
var codegen_data: Dictionary
static var spacetime: Spacetime

func _enter_tree():
	if not ProjectSettings.has_setting("autoload/" + AUTOLOAD_NAME):
		# get_editor_interface().get_resource_filesystem().scan()
		add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
		
	if not is_instance_valid(ui_panel):
		var scene = load(UI_PATH)
		if scene:
			ui_panel = scene.instantiate()
		else:
			printerr("Failed to load UI scene: ", UI_PATH)
			return
	if is_instance_valid(ui_panel):
		add_control_to_bottom_panel(ui_panel, AUTOLOAD_NAME)
	else:
		printerr("UI panel is not valid after instantiation attempt.")
	
	spacetime = self
	subscribe_controls()
	load_codegen_data()
		
func subscribe_controls():
	http_request.timeout = 4;
	add_child(http_request)
	module_prefab = ui_panel.get_node("prefab").duplicate()

	ui_panel.get_node("CheckUri").button_down.connect(check_uri);
	ui_panel.get_node("Panel/Button").button_down.connect(add_module)
	ui_panel.get_node("Generate").button_down.connect(generate_code);
	
func add_module(name: String = "EnterModuleName", fromLoad: bool = false):
	var new_module = module_prefab.duplicate()
	var line_edit = new_module.get_node("LineEdit")
	ui_panel.get_node("ScrollContainer/VBoxContainer").add_child(new_module)
	line_edit.text = name
	if not fromLoad:
		codegen_data.modules.append(line_edit.text)
		save_codegen_data()

	line_edit.focus_exited.connect(func():
		var index = new_module.get_index()
		codegen_data.modules[index] = line_edit.text
		save_codegen_data()
	)

	new_module.get_node("Button").button_down.connect(func():
		var index = new_module.get_index()
		codegen_data.modules.remove_at(index)
		save_codegen_data()
		new_module.queue_free()
	)
	new_module.show()

func generate_code():
	clear_log()
	print_log("Start Code Generation...")
	var codegen: Codegen = Codegen.new()
	var modules: Array[String] = []
	var generated_files: Array[String] = ["res://%s/%s/spacetime_modules.gd" % [Codegen.PLUGIN_DATA_FOLDER ,Codegen.CODEGEN_FOLDER]]
	for i in ui_panel.get_node("ScrollContainer/VBoxContainer").get_children():
		var module_name = i.get_node("LineEdit").text
		var uri = ui_panel.get_node("Uri").text
		if uri.ends_with("/"):
			uri = uri.left(-1)
		uri += "/v1/database/" + module_name + "/schema?version=9"
		http_request.request(uri)
		var result = await http_request.request_completed
		if result[1] == 200:
			var json = PackedByteArray(result[3]).get_string_from_utf8()
			var parse_module_name = module_name.replace("-", "_")
			generated_files.append_array(codegen._on_request_completed(json, parse_module_name))
			modules.append(parse_module_name)
	codegen.generate_module_link(modules)
	cleanup_unused_classes("res://%s/%s" % [Codegen.PLUGIN_DATA_FOLDER ,Codegen.CODEGEN_FOLDER], generated_files)
	get_editor_interface().get_resource_filesystem().scan()
	print_log("Code Generation Complete!")

func load_codegen_data() -> void:
	var load_data = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if load_data:
		codegen_data = JSON.parse_string(load_data.get_as_text())
		load_data.close()
		ui_panel.get_node("Uri").text = codegen_data.uri
		for module in codegen_data.modules.duplicate():
			add_module(module, true)
	else:
		codegen_data = {
			"uri": "http://127.0.0.1:3000",
			"modules": []
		}
		save_codegen_data()

func save_codegen_data() -> void:
	if not FileAccess.file_exists(DATA_PATH):
		DirAccess.make_dir_absolute(DATA_PATH)
		get_editor_interface().get_resource_filesystem().scan()

	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not save_file:
		printerr("Failed to open codegen_data.dat for writing.")
		return
	save_file.store_string(JSON.stringify(codegen_data))
	save_file.close()

func cleanup_unused_classes(dir_path: String = "res://schema", files: Array[String] = []) -> void:
	var dir = DirAccess.open(dir_path)
	if not dir: return
	print_log("File Cleanup:Scanning folder: " + dir_path)
	for file in dir.get_files():
		if not file.ends_with(".gd"): continue
		var full_path = "%s/%s" % [dir_path, file]
		if not full_path in files:
			print_log("Removing file: %s" % [full_path])
			DirAccess.remove_absolute(full_path)
			if FileAccess.file_exists("%s.uid" % [full_path]):
				DirAccess.remove_absolute("%s.uid" % [full_path])
	var subfolders = dir.get_directories()
	for folder in subfolders:
		cleanup_unused_classes(dir_path + "/" + folder, files)

func check_uri():
	codegen_data.uri = ui_panel.get_node("Uri").text
	save_codegen_data()
	var uri = ui_panel.get_node("Uri").text
	if uri.ends_with("/"):
		uri = uri.left(-1)
	uri += "/v1/ping"
	http_request.request(uri)
	var result = await http_request.request_completed
	clear_log()
	if result[1] == 0:
		print_log("Timeout Error: " +  uri)
	else:
		print_log("Response code: " + str(result[1]))

static func clear_log():
	spacetime.ui_panel.get_node("Log").text = ""

static func print_log(text: Variant) -> void:
	var log = spacetime.ui_panel.get_node("Log")
	match typeof(text):
		TYPE_STRING:
			log.text += text + "\n"
		TYPE_ARRAY:
			for i in text:
				log.text += str(i) + " "
			log.text += "\n"
		_:
			log.text += str(text) + "\n"

func _exit_tree():
	if is_instance_valid(ui_panel):
		remove_control_from_bottom_panel(ui_panel)
		ui_panel.queue_free()
		ui_panel = null
		http_request.queue_free()
		http_request = null
		
	if ProjectSettings.has_setting("autoload/" + AUTOLOAD_NAME):
		remove_autoload_singleton(AUTOLOAD_NAME)
