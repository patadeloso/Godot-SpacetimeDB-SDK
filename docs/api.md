# API Reference

## `SpacetimeDBClient` class

**Inherits:** Node

A connection to a SpacetimeDB database is controlled by the `SpacetimeDBClient` class. All generated [`ModuleClient`](#generated-moduleclient-class) classes extend this class.

### Connect to a database

#### `connect_db()` method

```gdscript
class SpacetimeDBClient:
    func connect_db(
        uri: String,
        module_name: String,
        options: SpacetimeDBConnectionOptions = null
    ) -> void
```

Connects to a SpacetimeDB database.

| Name | Description |
| --- | --- |
| uri | The URI of the SpacetimeDB instance hosting the remote database. |
| module_name | The name or identity of the remote database. |
| options | Client connection options, see the [`SpacetimeDBConnectionOptions`](#spacetimedbconnectionoptions-resource) documentation. |

#### `disconnect_db()` method

```gdscript
class SpacetimeDBClient:
    func disconnect_db() -> void
```

Disconnects from the SpacetimeDB database.

### Query the local database cache

#### `get_local_database()` method

```gdscript
class SpacetimeDBClient:
    func get_local_database() -> LocalDatabase
```

Get the untyped [`LocalDatabase`](#localdatabase-class) instance by calling `SpacetimeDBClient.get_local_database()`.

### Get the identity of the current connection

#### `get_local_identity()` method

```gdscript
class SpacetimeDBClient:
    func get_local_identity() -> PackedByteArray
```

Get the SpacetimeDB identity of the current connection by calling `SpacetimeDBClient.get_local_identity()`.

### Subscribe to queries

#### `subscribe()` method

```gdscript
class SpacetimeDBClient:
    func subscribe(queries: PackedStringArray) -> SpacetimeDBSubscription
```

| Name    | Description                              |
| ------- | ---------------------------------------- |
| queries | An array of SQL queries to subscribe to. |

Subscribe to queries by calling `subscribe(queries)`, which returns a [`SpacetimeDBSubscription`](#spacetimedbsubscription-class) instance.

See the [SpacetimeDB SQL Reference](https://spacetimedb.com/docs/sql#subscriptions) for information on the queries SpacetimeDB supports.

#### `unsubscribe()` method

```gdscript
class SpacetimeDBClient:
    func unsubscribe(query_id: int) -> Error
```

| Name     | Description                             |
| -------- | --------------------------------------- |
| query_id | The query id of an active subscription. |

Close a subscription by calling `unsubscribe(query_id)` with the query id of an existing query. A Godot `Error` is returned to indicate success or failure.

## Generated `ModuleClient` class

**Inherits:** [SpacetimeDBClient](#spacetimedbclient-class) < Node

This class is generated per module and contains information about the types, tables and reducers defined by your module.

### Access tables and reducers

#### `db` property

```gdscript
class ModuleClient:
    var db: ModuleDb
```

The `db` property provides access to the subscribed view of the database's tables. See [Access the local database](#access-the-local-database).

#### `reducers` property

```gdscript
class ModuleClient:
    const reducers: ModuleReducers
```

The `reducers` property provides access to reducers exposed by the module. See [Calling reducers](#calling-reducers).

### Access the local database

Each table defined by your module has a property, whose name is the table name converted to `snake_case`. The table properties are [`ModuleTable`](#moduletable-class) instances which have methods for accessing rows and registering `on_insert`, `on_update` and `on_delete` listeners.

#### `count` method

```gdscript
class ModuleTable:
    func count() -> int
```

Returns the number of rows of the table in the local database, i.e. the total number of rows which match any of the subscribed queries.

#### `iter` method

```gdscript
class ModuleTable:
    func iter() -> Array[Row]
```

An array of all of the subscribed rows in the local database, i.e. those which match any of the subscribed queries.

The `Row` type will be the auto-generated type which matches the row type defined in the module.

#### `on_insert` listener

```gdscript
class ModuleTable:
    func on_insert(listener: Callable) -> void

    func remove_on_insert(listener: Callable) -> void

# Listener function signature
func(row: Row) -> void
```

The `on_insert` listener runs whenever a new row is inserted into the local database.

The `Row` type will be the auto-generated type which matches the row type defined in the module.

Call `remove_on_insert` to un-register a previously registered listener.

#### `on_update` listener

```gdscript
class ModuleTable:
    func on_update(listener: Callable) -> void

    func remove_on_update(listener: Callable) -> void

# Listener function signature
func(old_row: Row, new_row: Row) -> void
```

The `on_update` listener runs whenever a row already in the local database is updated.

The `Row` type will be the auto-generated type which matches the row type defined in the module.

Call `remove_on_update` to un-register a previously registered listener.

#### `on_delete` listener

```gdscript
class ModuleTable:
    func on_delete(listener: Callable) -> void

    func remove_on_delete(listener: Callable) -> void

# Listener function signature
func(row: Row) -> void
```

The `on_delete` listener runs whenever a row already in the local database is deleted.

The `Row` type will be the auto-generated type which matches the row type defined in the module.

Call `remove_on_delete` to un-register a previously registered listener.

#### Unique index access

For each unique constraint on a table, its table class has a property whose name is the unique column name. This property is a `ModuleTableUniqueIndex` which has a `find` method.

```gdscript
class ModuleTableUniqueIndex:
    func find(col_val: Col) -> Row | null
```

Where `Col` is the column data type and `Row` is the table row type. If a row with the `col_val` exists in the local database, the method returns that row, otherwise it returns `null`.

#### BTree index access

This SDK does not currently support non-unique BTree indexes.

### Calling reducers

Each public reducer defined by your module has a method on the `.reducers` property. The method name is the reducer name converted to `snake_case`. Each reducer method takes the arguments defined by the reducer and an optional callback function.

```gdscript
static func example_reducer(
    arg1: String,
    arg2: int,
    callback: Callable
) -> void

# Callback function signature
func(tx: TransactionUpdateMessage) -> void
```

## `SpacetimeDBConnection` class

**Inherits:** Node

Holds and listens to the websocket connection to the SpacetimeDB server.

#### `CompressionPreference` enum

```gdscript
class SpacetimeDBConnection:
    enum CompressionPreference { NONE = 0, BROTLI = 1, GZIP = 2 }
```

The compression preference for the connection.

| Name   | Description                                       |
| ------ | ------------------------------------------------- |
| NONE   | No compression                                    |
| BROTLI | Brotli compression (NOT SUPPORTED out-of-the-box) |
| GZIP   | GZIP compression                                  |

## `SpacetimeDBConnectionOptions` resource

**Inherits:** Resource

#### `compression` property

```gdscript
class SpacetimeDBConnectionOptions:
    var compression: CompressionPreference
```

The [`CompressionPreference`](#compressionpreference-enum) for the connection

#### `threading` property

```gdscript
class SpacetimeDBConnectionOptions:
    var threading: bool = true
```

Whether to use threading for processing database update messages

#### `one_time_token` property

```gdscript
class SpacetimeDBConnectionOptions:
    var one_time_token: bool = true
```

Whether to use a one-time token for the connection

#### `debug_mode` property

```gdscript
class SpacetimeDBConnectionOptions:
    var debug_mode: bool = false
```

Enables verbose logging

#### `inbound_buffer_size` property

```gdscript
class SpacetimeDBConnectionOptions:
    var inbound_buffer_size: int = 1024 * 1024 * 2
```

The maximum size of the inbound buffer

#### `outbound_buffer_size` property

```gdscript
class SpacetimeDBConnectionOptions:
    var outbound_buffer_size: int = 1024 * 1024 * 2
```

#### `set_all_buffer_size()` method

Sets the inbound and outbound buffer sizes:

```gdscript
class SpacetimeDBConnectionOptions:
    func set_all_buffer_size(size: int) -> void
```

| Name | Description                                             |
| ---- | ------------------------------------------------------- |
| size | The size of the inbound and outbound buffers, in bytes. |

## `SpacetimeDBSubscription` class

**Inherits:** Node

A handle to a subscription to the SpacetimeDB database. The handle does not contain or provide access to the subscribed data, all subscribed rows are available via the module's [`LocalDatabase`](#localdatabase-class). See [Access the local database](#access-the-local-database).

#### `active` property

```gdscript
class SpacetimeDBSubscription:
    var active: bool
```

Indicates whether this subscription has been applied and has not yet been unsubscribed.

#### `ended` property

```gdscript
class SpacetimeDBSubscription:
    var ended: bool
```

Indicates if this subscription has been terminated due to an unsubscribe request or an error.

#### `unsubscribe()` method

```gdscript
class SpacetimeDBSubscription:
    func unsubscribe() -> Error
```

Terminate this subscription, causing the subscribed rows to be removed from the [`LocalDatabase`](#localdatabase-class).

Returns an error if the subscription has already ended, either due to a previous `unsubscribe()` call or an error.

#### `wait_for_applied()` method

```gdscript
class SpacetimeDBSubscription:
    async func wait_for_applied(timeout_sec: float = 5) -> Error
```

| Name | Description |
| --- | --- |
| timeout_sec | The number of seconds to wait for the subscription to be applied before timing out. |

Waits for the subscription to be applied, or until it times out.

Returns an error if the subscription has already ended or if the timeout is reached.

#### `wait_for_end()` method

```gdscript
class SpacetimeDBSubscription:
    async func wait_for_end(timeout_sec: float = 5) -> Error
```

| Name | Description |
| --- | --- |
| timeout_sec | The number of seconds to wait for the subscription to be terminated before timing out. |

Waits for the subscription to be terminated, or until it times out.

Returns an error if the timeout is reached.

#### `applied` signal

```gdscript
class SpacetimeDBSubscription:
    signal applied
```

Emitted when the `SubscribeMultiApplied` message is received and the subscription is set to active.

#### `end` signal

```gdscript
class SpacetimeDBSubscription:
    signal end
```

Emitted when the `UnsubscribeMultiApplied` message is received and the subscription is set to ended.

## `LocalDatabase` class

**Inherits:** Node

The underlying local database cache for a module.

### Subscribe to inserts

```gdscript
class LocalDatabase:
    func subscribe_to_inserts(table_name: StringName, callable: Callable) -> void

    func unsubscribe_from_inserts(table_name: StringName, callable: Callable) -> void
```

The `callable` runs whenever a new row is inserted into the table with the given `table_name`.

You can call `unsubscribe_from_inserts` with a `callable` that was previously registered.

### Subscribe to updates

```gdscript
class LocalDatabase:
    func subscribe_to_updates(table_name: StringName, callable: Callable) -> void

    func unsubscribe_from_updates(table_name: StringName, callable: Callable) -> void
```

The `callable` runs whenever an existing row in the table with the given `table_name` receives an update.

You can call `unsubscribe_from_updates` with a `callable` that was previously registered.

### Subscribe to deletes

```gdscript
class LocalDatabase:
    func subscribe_to_deletes(table_name: StringName, callable: Callable) -> void

    func unsubscribe_from_deletes(table_name: StringName, callable: Callable) -> void
```

The `callable` runs whenever an existing row in the table with the given `table_name` is deleted.

You can call `unsubscribe_from_deletes` with a `callable` that was previously registered.

### Access untyped data in the local database

#### `get_row_by_pk()` method

```gdscript
class LocalDatabase:
    func get_row_by_pk(table_name: String, primary_key_value) -> _ModuleTableType
```

Returns the row in the table with the given `table_name` that has the given `primary_key_value`.

If a table with the given `table_name` does not exist or no row with the given `primary_key_value` exists, the method returns `null`.

#### `get_all_rows()` method

```gdscript
class LocalDatabase:
    func get_all_rows(table_name: String) -> Array[_ModuleTableType]
```

Returns all subscribed rows in the table with the given `table_name`, if the table does not exist an empty array is returned.

#### `count_all_rows()` method

```gdscript
class LocalDatabase:
    func count_all_rows(table_name: String) -> int
```

Returns the number of subscribed rows in the table with the given `table_name`.

# Rust Enums in Godot

There is full support for rust enum sumtypes when derived from SpacetimeType.

The following is fully supported syntax:

```rs
#[derive(spacetimedb::SpacetimeType, Debug, Clone)]
pub enum CharacterClass {
    Warrior(Vec<i32>),
    Mage(CharacterMageData),
    Archer(ArcherOptions),
}

#[derive(SpacetimeType, Debug, Clone)]
pub struct CharacterMageData {
    mana: u32,
    spell_power: u32,
    other: Vec<u8>,
}

#[derive(SpacetimeType, Debug, Clone)]
pub enum ArcherOptions {
    None,
    Bow(BowOptions),
    Crossbow,
}

#[derive(SpacetimeType, Debug, Clone)]
pub enum BowOptions {
    None,
    Longbow,
    Shortbow,
}
```

This will codegen the following for `CharacterClass`: ![image](https://github.com/user-attachments/assets/cdd5cddd-8a15-4da2-a0bb-ef0a1e446883)

There are static functions to create specific enum variants in godot as well as getters to return the variant as the specific type. The following is how to create and match through and enum:

```gdscript
var cc = SpacetimeDB.MyModule.Types.CharacterClass.create_warrior([1,2,3,4,5])
match cc.value:
	cc.Warrior:
		var warrior: = cc.get_warrior()
		var first: = warrior[0]
		print_debug("Warrior:", first)
```

With this you will have full support for code completion due to strong types being returned. ![image](https://github.com/user-attachments/assets/ddfeab8b-1423-41b0-84ca-52af19c96015)

![image](https://github.com/user-attachments/assets/3bb7cac8-78d4-40b7-90f8-20e19274d94a)

Since BowOptions in rust is not being used as a sumtype in godot it becomes just a standard enum.

![image](https://github.com/user-attachments/assets/0c4b4c00-c479-47cc-a459-394b917457c1)

# Technical Details

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/flametime/Godot-SpacetimeDB-SDK)

## Type System & Serialization

The SDK handles serialization between Godot types and SpacetimeDB's BSATN format based on your schema Resources.

-   **Default Mappings:**

    -   `bool` <-> `bool`
    -   `int` <-> `i64` (Signed 64-bit integer)
    -   `float` <-> `f64` (Single-precision float)
    -   `String` <-> `String` (UTF-8)
    -   `Vector2`/`Vector3`/`Color`/`Quaternion` <-> Matching server struct (f32 fields)
    -   `PackedByteArray` <-> `Vec<u8>` (Default) OR `Identity`
    -   `Array[T]` <-> `Vec<T>` (Requires typed array hint, e.g., `@export var scores: Array[int]`)
    -   Nested `Resource` <-> `struct` (Fields serialized inline)

-   **Metadata for Specific Types:** Use `set_meta("bsatn_type_fieldname", "type_string")` in your schema's `_init()` for:

    -   Integers other than `i64` (e.g., `"u8"`, `"i16"`, `"u32"`).
    -   Floats that are `f64` (use `"f64"`).

-   **Reducer Type Hints:** The `types` array in `call_reducer` helps serialize arguments correctly, especially important for non-default integer/float types.

### Supported Data Types

-   **Primitives:** `bool`, `int` (maps to `i8`-`i64`, `u8`-`u64` via metadata/hints), `float` (maps to `f32`, `f64` via metadata/hints), `String`
-   **Godot Types:** `Vector2`, `Vector3`, `Color`, `Quaternion` (require compatible server structs)
-   **Byte Arrays:** `PackedByteArray` (maps to `Vec<u8>` or `Identity`)
-   **Collections:** `Array[T]` (requires typed `@export` hint)
-   **Custom Resources:** Nested `Resource` classes defined in your schema path.
-   **Rust Enums:** Code generator creates a RustEnum class in Godot

## Compression

-   **Client -> Server:** Not currently implemented. Messages sent from the client (like reducer calls) are uncompressed.
-   **Server -> Client:**
    -   **None (0x00):** Fully supported. This is the default requested by the client.
    -   **Gzip (0x02):** Experimental support.
    -   **Brotli (0x01):** **NOT SUPPORTED out-of-the-box.** If the server sends Brotli-compressed messages, the parser will report an error. To handle Brotli, you would need to:
        1.  Obtain or create a GDExtension/GDNative module wrapping a Brotli library.
        2.  Modify `addons/SpacetimeDB/core/bsatn_deserializer.gd` (`_get_query_update_stream` function and potentially `parse_packet`) to call your native decompression function.
    -   **Recommendation:** Ensure your SpacetimeDB server is configured _not_ to send compressed messages, or only use `CompressionPreference.NONE` when connecting.

---

### Other documentation

-   [Installation](installation.md)
-   [Generate module bindings](codegen.md)
-   [Quick Start guide](quickstart.md)
