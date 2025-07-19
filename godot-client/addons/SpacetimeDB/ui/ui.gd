class_name SpacetimePluginUI extends RefCounted

const UI_PANEL_NAME := "SpacetimeDB"
const UI_PATH := "res://addons/SpacetimeDB/ui/ui.tscn"

signal module_updated(index: int, name: String)
signal module_removed(index: int)
signal check_uri(uri: String)
signal generate_schema(uri: String, modules: Array[String])

var _ui_panel: Control
var _uri_input: LineEdit
var _modules_container: VBoxContainer
var _logs_container: VBoxContainer
var _add_module_hint_container: VBoxContainer
var _new_module_name_input: LineEdit
var _new_module_button: Button
var _check_uri_button: Button
var _generate_button: Button

func _init() -> void:
    if not is_instance_valid(_ui_panel):
        var scene = load(UI_PATH)
        if scene:
            _ui_panel = scene.instantiate()
        else:
            printerr("[SpacetimePlugin] Failed to load UI scene: ", UI_PATH)
            return
    if is_instance_valid(_ui_panel):
        SpacetimePlugin.instance.add_control_to_bottom_panel(_ui_panel, UI_PANEL_NAME)
    else:
        printerr("[SpacetimePlugin] UI panel is not valid after instantiation")
        return
    
    _uri_input = _ui_panel.get_node("Uri") as LineEdit
    _modules_container = _ui_panel.get_node("ModulesContainer/VBox") as VBoxContainer
    _logs_container = _ui_panel.get_node("Logs/VBox") as VBoxContainer
    _add_module_hint_container = _ui_panel.get_node("AddModuleHint") as VBoxContainer
    _new_module_name_input = _ui_panel.get_node("NewModule/ModuleNameInput") as LineEdit
    _new_module_button = _ui_panel.get_node("NewModule/AddButton") as Button
    _check_uri_button = _ui_panel.get_node("CheckUri") as Button
    _generate_button = _ui_panel.get_node("Generate") as Button
    
    _check_uri_button.button_down.connect(_on_check_uri)
    _generate_button.button_down.connect(_on_generate_code)
    _new_module_button.button_down.connect(_on_new_module)

func set_uri(uri: String) -> void:
    _uri_input.text = uri

func add_module(name: String) -> void:
    var new_module: Panel = _ui_panel.get_node("Prefabs/ModulePrefab").duplicate() as Panel
    var name_input: LineEdit = new_module.get_node("ModuleNameInput") as LineEdit
    name_input.text = name
    _modules_container.add_child(new_module)

    name_input.focus_exited.connect(func():
        var index = new_module.get_index()
        module_updated.emit(index, name_input.text)
    )

    var remove_button: Button = new_module.get_node("RemoveButton") as Button
    remove_button.button_down.connect(func():
        var index = new_module.get_index()
        module_removed.emit(index)
        _modules_container.remove_child(new_module)
        new_module.queue_free()
        
        if _modules_container.get_child_count() == 0:
            _add_module_hint_container.show()
            _generate_button.disabled = true
    )
    
    new_module.show()
    _add_module_hint_container.hide()
    _generate_button.disabled = false

func clear_logs():
    var logs := _logs_container.get_children()
    for log in logs:
        if not log.is_queued_for_deletion():
            log.queue_free()

func add_log(text: Variant) -> void:
    var new_log: Label = _ui_panel.get_node("Prefabs/LogPrefab").duplicate() as Label
    match typeof(text):
        TYPE_STRING:
            new_log.text += text as String
        TYPE_ARRAY:
            for i in text as Array:
                new_log.text += str(i) + " "
        _:
            new_log.text += str(text)
    
    _logs_container.add_child(new_log)
    new_log.show()

func add_err(text: Variant) -> void:
    var new_err: Control = _ui_panel.get_node("Prefabs/ErrorPrefab").duplicate() as Control
    var message: Label = new_err.get_node("Message") as Label
    
    match typeof(text):
        TYPE_STRING:
            message.text += text as String
        TYPE_ARRAY:
            for i in text as Array:
                message.text += str(i) + " "
        _:
            message.text += str(text)
    
    _logs_container.add_child(new_err)
    new_err.show()

func destroy() -> void:
    if is_instance_valid(_ui_panel):
        SpacetimePlugin.instance.remove_control_from_bottom_panel(_ui_panel)
        _ui_panel.queue_free()
    _ui_panel = null
    _uri_input = null
    _modules_container = null
    _logs_container = null
    _add_module_hint_container = null
    _new_module_name_input = null
    _new_module_button = null
    _check_uri_button = null
    _generate_button = null
  
func _on_check_uri() -> void:
    check_uri.emit(_uri_input.text)
    
func _on_generate_code() -> void:
    var modules: Array[String] = []
    for child in _modules_container.get_children():
        var module_name := (child.get_node("ModuleNameInput") as LineEdit).text
        modules.append(module_name)
        
    generate_schema.emit(_uri_input.text, modules)
    
func _on_new_module() -> void:
    var name := _new_module_name_input.text
    add_module(name)
    _new_module_name_input.text = ""
