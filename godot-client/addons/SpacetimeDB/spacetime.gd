@tool
class_name SpacetimePlugin extends EditorPlugin

const AUTOLOAD_NAME := "SpacetimeDB"
const BINDINGS_PATH := "res://spacetime_bindings/"
const AUTOLOAD_PATH := BINDINGS_PATH + "generated_client.gd"
const SAVE_PATH := BINDINGS_PATH + "codegen_data.json"

var http_request = HTTPRequest.new()
var codegen_data: Dictionary
var ui: SpacetimePluginUI

    if not ProjectSettings.has_setting("autoload/" + AUTOLOAD_NAME):
        # get_editor_interface().get_resource_filesystem().scan()
        add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
        
static var instance: SpacetimePlugin

func _enter_tree():    
    instance = self
    
    ui = SpacetimePluginUI.new()
    ui.module_updated.connect(_on_module_updated)
    ui.module_removed.connect(_on_module_removed)
    ui.check_uri.connect(_on_check_uri)
    ui.generate_schema.connect(_on_generate_schema)
    
    load_codegen_data()

func add_module(name: String, fromLoad: bool = false):
    ui.add_module(name)
    
    if not fromLoad:
        codegen_data.modules.append(name)
        save_codegen_data()

func load_codegen_data() -> void:
    var load_data = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if load_data:
        print_log("Loading codegen data from %s" % [SAVE_PATH])
        codegen_data = JSON.parse_string(load_data.get_as_text())
        load_data.close()
        ui.set_uri(codegen_data.uri)
        
        for module in codegen_data.modules.duplicate():
            add_module(module, true)
            print_log("Loaded module: %s" % [module])
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

func _on_module_updated(index: int, name: String) -> void:
    codegen_data.modules[index] = name
    save_codegen_data()

func _on_module_removed(index: int) -> void:
    codegen_data.modules.remove_at(index)
    save_codegen_data()

func _on_check_uri(uri: String):
    if codegen_data.uri != uri:
        codegen_data.uri = uri
        save_codegen_data()
    
    if uri.ends_with("/"):
        uri = uri.left(-1)
    uri += "/v1/ping"
    
    print_log("Pinging... " + uri)
    http_request.request(uri)
    
    var result = await http_request.request_completed
    if result[1] == 0:
        print_err("Request timeout - " + uri)
    else:
        print_log("Response code: " + str(result[1]))

func _on_generate_schema(uri: String, modules: Array[String]):
    if uri.ends_with("/"):
        uri = uri.left(-1)
            
    print_log("Starting code generation...")
    var codegen := Codegen.new()
    var generated_files: Array[String] = ["res://%s/%s/spacetime_modules.gd" % [Codegen.PLUGIN_DATA_FOLDER ,Codegen.CODEGEN_FOLDER]]
    for module in modules:
        var schema_uri := "%s/v1/database/%s/schema?version=9" % [uri, module]
        http_request.request(uri)
        var result = await http_request.request_completed
        if result[1] == 200:
            var json = PackedByteArray(result[3]).get_string_from_utf8()
            var parse_module_name = module.replace("-", "_")
            generated_files.append_array(codegen._on_request_completed(json, parse_module_name))
            modules.append(parse_module_name)
    codegen.generate_module_link(modules)
    _cleanup_unused_classes("res://%s/%s" % [Codegen.PLUGIN_DATA_FOLDER ,Codegen.CODEGEN_FOLDER], generated_files)
    
    get_editor_interface().get_resource_filesystem().scan()
    print_log("Code Generation Complete!")

func _cleanup_unused_classes(dir_path: String = "res://schema", files: Array[String] = []) -> void:
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
func check_uri():
        _cleanup_unused_classes(dir_path + "/" + folder, files)

static func clear_logs():
    instance.ui.clear_logs()

static func print_log(text: Variant) -> void:
    instance.ui.add_log(text)

static func print_err(text: Variant) -> void:
    instance.ui.add_err(text)

func _exit_tree():
    ui.destroy()
    ui = null
    http_request.queue_free()
    http_request = null
        
    if ProjectSettings.has_setting("autoload/" + AUTOLOAD_NAME):
        remove_autoload_singleton(AUTOLOAD_NAME)
