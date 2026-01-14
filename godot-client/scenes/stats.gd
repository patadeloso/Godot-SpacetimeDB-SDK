extends Panel

func _ready() -> void:
	await SpacetimeDB.Main.connected
	SpacetimeDB.Main._connection.total_bytes.connect(_total_bytes)
	SpacetimeDB.Main._connection.total_messages.connect(_total_messages)

func _total_bytes(sent: int, received: int):
	if received == 100:
		return
	$HBoxContainer/VBoxContainer/bytes.text = format_bytes(sent)
	$HBoxContainer/VBoxContainer2/bytes.text = format_bytes(received)

func _total_messages(sent: int, received: int):
	#if received == 50:
	#	SpacetimeDB.Main._connection.total_bytes.disconnect(_total_bytes)
	#	SpacetimeDB.Main._connection.total_messages.disconnect(_total_messages)

	$HBoxContainer/VBoxContainer/count.text = str(sent)
	$HBoxContainer/VBoxContainer2/count.text = str(received)

func format_bytes(bytes_value: int) -> String:
	var suffixes = ["B", "KB", "MB", "GB", "TB"]
	var i = 0
	var d_bytes = float(bytes_value)

	while d_bytes >= 1024.0 and i < suffixes.size() - 1:
		d_bytes /= 1024.0
		i += 1

	return "%.1f %s" % [d_bytes, suffixes[i]]
