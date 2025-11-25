extends Control


@onready var test_table_datatypes_main: RowReceiver = $"Receiver [MainTestTableDatatypes]"
@onready var test_table_datatypes_view_all: RowReceiver = $"Receiver [MainTestTableDatatypes]2"
@onready var test_table_datatypes_first_row: RowReceiver = $"Receiver [MainTestTableDatatypes]3"
@onready var test_table_datatypes_at_30: RowReceiver = $"Receiver [MainTestTableDatatypes]4"
@onready var test_scheduled_table_private: RowReceiver = $"Receiver [MainTestScheduledTable]"
@onready var test_scheduled_table_public: RowReceiver = $"Receiver [MainTestScheduledTable]2"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var options = SpacetimeDBConnectionOptions.new()

	options.one_time_token = true # <--- anonymous-like. set to false to persist
	options.debug_mode = false # <--- enables lots of additional debug prints and warnings
	options.compression = SpacetimeDBConnection.CompressionPreference.GZIP
	options.threading = false
	# Increase buffer size. In general, you don't need this.
	# options.set_all_buffer_size(1024 * 1024 * 2)

	# Disable threading (e.g., for web builds)
	# options.threading = false

	SpacetimeDB.Main.connect_db( # WARNING <--- replace 'Main' with your module name
		"http://127.0.0.1:3000", # WARNING <--- replace it with your url
		"main", # WARNING <--- replace it with your database name
		options
	)

	SpacetimeDB.Main.connected.connect(_on_spacetimedb_connected)
	SpacetimeDB.Main.disconnected.connect(_on_spacetimedb_disconnected)
	SpacetimeDB.Main.connection_error.connect(_on_spacetimedb_connection_error)
	SpacetimeDB.Main.database_initialized.connect(_on_spacetimedb_database_init)

func _on_spacetimedb_connected(identity: PackedByteArray, token: String):
	print("Game: Connected to SpacetimeDB!")
	print("Game: My Identity: 0x%s" % [identity.hex_encode()])

func _on_spacetimedb_disconnected():
	print("Game: Disconnected from SpacetimeDB.")

func _on_spacetimedb_connection_error(code: int, reason: String):
	printerr("Game: SpacetimeDB Connection Error: ", reason, " Code: ", code)

func _on_spacetimedb_database_init():
	print("Game: Database initialised")


func _on_button_pressed() -> void:
	SpacetimeDB.Main.reducers.start_integration_tests()
	var query_string := [
		"SELECT * FROM test_table_datatypes" 
	]
	var sub := SpacetimeDB.Main.subscribe(query_string)
	if sub.error:
		printerr("Game: Failed to send subscription request.")
		return
	
	sub.applied.connect(func(): print("subsciptions applied"))
	print("Game: Subscription request sent (Query ID: %d)." % sub.query_id)


func _on_button_2_pressed() -> void:
	SpacetimeDB.Main.reducers.clear_integration_tests() # Replace with function body.
