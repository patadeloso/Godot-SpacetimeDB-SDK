class_name SpacetimeParsedSchema extends Resource

var module: String = ""
var types: Array[Dictionary] = []
var reducers: Array[Dictionary] = []
var type_map: Dictionary[String, String] = {}
var meta_type_map: Dictionary[String, String] = {}
var tables: Array[Dictionary] = []
var typespace: Array[Dictionary] = []

func is_empty() -> bool:
    return types.is_empty() && reducers.is_empty()
