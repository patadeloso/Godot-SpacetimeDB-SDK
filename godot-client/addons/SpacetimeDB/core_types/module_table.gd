class_name _ModuleTable extends Resource

var _db: LocalDatabase

func _init(db: LocalDatabase) -> void:
    _db = db

func count() -> int:
    var table_name: String = get_meta("table_name", "")
    return _db.count_all_rows(table_name)

func iter() -> Array:
    var table_name: String = get_meta("table_name", "")
    return _db.get_all_rows(table_name)
