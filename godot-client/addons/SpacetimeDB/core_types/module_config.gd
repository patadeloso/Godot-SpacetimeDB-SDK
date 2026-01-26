extends Resource
class_name SpacetimeDBModuleConfig

@export var name: String
@export var alias: String
@export_category("Codegen Config")
@export var hide_scheduled_reducers: bool = true
@export var hide_private_tables: bool = true

var unparsed_module_schema : String
var module_schema: SpacetimeDBSchema
