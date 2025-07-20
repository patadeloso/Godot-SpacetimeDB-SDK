class_name SpacetimeDBSchema extends RefCounted

var types: Dictionary[String, GDScript] = {}
var tables: Dictionary[String, GDScript] = {}

var debug_mode: bool = false # Controls verbose debug printing

func _init(p_schema_path: String = "res://spacetime_bindings/schema", p_debug_mode: bool = false) -> void:
    debug_mode = p_debug_mode
    
    # Load table row schema scripts
    _load_types("%s/tables" % p_schema_path, tables)
    # Load spacetime types
    _load_types("%s/spacetime_types" % p_schema_path)
    # Load core types if they are defined as Resources with scripts
    _load_types("res://addons/SpacetimeDB/core_types")
    
func _load_types(path: String, category: Variant = null) -> void:
    var dir := DirAccess.open(path)
    if not DirAccess.dir_exists_absolute(path):
        printerr("SpacetimeDBSchema: Schema directory does not exist: ", path)
        return

    dir.list_dir_begin()
    var file_name_raw := dir.get_next()
    while file_name_raw != "":
        if dir.current_is_dir():
            file_name_raw = dir.get_next()
            continue

        var file_name := file_name_raw

        # Handle potential remapping on export
        if file_name.ends_with(".remap"):
            file_name = file_name.replace(".remap", "")
            if not file_name.ends_with(".gd"):
                file_name += ".gd"

        if not file_name.ends_with(".gd"):
            file_name_raw = dir.get_next()
            continue

        var script_path := path.path_join(file_name)
        if not ResourceLoader.exists(script_path):
            printerr("SpacetimeDBSchema: Script file not found or inaccessible: ", script_path, " (Original name: ", file_name_raw, ")")
            file_name_raw = dir.get_next()
            continue

        var script := ResourceLoader.load(script_path, "GDScript") as GDScript

        if script and script.can_instantiate():
            var instance_for_name = script.new()
            if instance_for_name is Resource: # Ensure it's a resource to get metadata
                var base_name: Array[String] = [file_name.get_basename().get_file()]
                var table_names := _get_schema_table_name(instance_for_name, base_name)

                for table_name in table_names:
                    var lower_table_name := table_name.to_lower().replace("_", "")
                    if types.has(lower_table_name) and debug_mode:
                        push_warning("SpacetimeDBSchema: Overwriting schema for table '%s' (from %s)" % [table_name, script_path])
                        
                    if category:
                        category[lower_table_name] = script
                    types[lower_table_name] = script
                    

        file_name_raw = dir.get_next()

    dir.list_dir_end()

func _get_schema_table_name(instance: Resource, fallback_base_filename: Array[String]) -> Array[String]:
    # Prioritize const, then filename
    var constants := (instance.get_script() as GDScript).get_script_constant_map()
    
    if constants.has('table_names'):
        return constants['table_names'] as Array[String]
    else:
        return fallback_base_filename

func get_type(type_name: String) -> GDScript:
    return types.get(type_name)
    
