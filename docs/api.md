# API Reference

## Rust Enums In Godot

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

## Technical Details

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/flametime/Godot-SpacetimeDB-SDK)

### Type System & Serialization

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
