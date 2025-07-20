class_name SpacetimeParsedSchema extends Resource

var module: String = ""
var types: Array[Dictionary] = []
var reducers: Array[Dictionary] = []
var type_map: Dictionary[String, String] = {}
var meta_type_map: Dictionary[String, String] = {}
var tables: Array = []
var typespace: Array = []

func is_empty() -> bool:
    return types.is_empty() && reducers.is_empty()

func to_dictionary() -> Dictionary:
    return {
        "module": module,
        "types": types,
        "reducers": reducers,
        "type_map": type_map,
        "meta_type_map": meta_type_map,
        "tables": tables,
        "typespace": typespace
    }
