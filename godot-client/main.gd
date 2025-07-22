extends Node3D

func _ready():
    var options = SpacetimeDBConnectionOptions.new()

    options.one_time_token = true # <--- anonymous-like. set to false to persist
    options.debug_mode = true # <--- enables lots of additional debug prints and warnings
    options.compression = SpacetimeDBConnection.CompressionPreference.GZIP
    options.threading = true
    # Increase buffer size. In general, you don't need this.
    # options.set_all_buffer_size(1024 * 1024 * 2)

    # Disable threading (e.g., for web builds)
    # options.threading = false

    SpacetimeDB.Main.connect_db( #WARNING <--- replace 'Main' with your module name
        "http://127.0.0.1:3000", #WARNING <--- replace it with your url
        "main", #WARNING <--- replace it with your database name
        options
    )

    SpacetimeDB.Main.connected.connect(_on_spacetimedb_connected)
    SpacetimeDB.Main.disconnected.connect(_on_spacetimedb_disconnected)
    SpacetimeDB.Main.connection_error.connect(_on_spacetimedb_connection_error)

func _on_spacetimedb_connected(identity: PackedByteArray, token: String):
    print("Game: Connected to SpacetimeDB!")
    print("Game: My Identity: 0x%s" % [identity.hex_encode()])
    subscribe_self_updates()
    
func subscribe_self_updates():
    var id = SpacetimeDB.Main.get_local_identity().duplicate()
    id.reverse()
    var query_string := [
        "SELECT * FROM user WHERE identity = '0x%s'" % id.hex_encode()
    ]
    var sub := SpacetimeDB.Main.subscribe(query_string)
    if sub.error:
        printerr("Game: Failed to send subscription request.")
        return
    
    sub.applied.connect(_on_self_loaded)
    print("Game: Subscription request sent (Query ID: %d)." % sub.query_id)
    
func _on_self_loaded():
    var id = SpacetimeDB.Main.get_local_identity()
    var user := SpacetimeDB.Main.db.user.identity.find(id)
    var user_obj := {
        identity = user.identity.hex_encode(),
        online = user.online, 
        lobby_id = user.lobby_id, 
        damage = user.damage,
        test_option_string = user.test_option_string,
        test_option_message = user.test_option_message
    }
    print("Game: Received user from subscription: %s" % user_obj)

func _on_spacetimedb_disconnected():
    print("Game: Disconnected from SpacetimeDB.")

func _on_spacetimedb_connection_error(code: int, reason: String):
    printerr("Game: SpacetimeDB Connection Error: ", reason, " Code: ", code)
