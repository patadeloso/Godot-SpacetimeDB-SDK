extends Node

signal user_join(user: MainUser)
signal user_leave(user: MainUser)

@export var receiver: RowReceiver
var local_user: MainUser
var users = {}

func _ready() -> void:
    receiver.insert.connect(_on_user_inserted)
    receiver.delete.connect(_on_user_deleted)

func _on_user_inserted(user: MainUser):
    if user.identity == SpacetimeDB.Main.get_local_identity():
        print("Set local user: ", user.identity.hex_encode())
        local_user = user
        subscibe_on_lobby(user.lobby_id)
    
    if users.has(user.identity):
        return
    
    print("Join: ", user.identity.hex_encode())
    user_join.emit(user)
    users[user.identity] = user

func _on_user_deleted(user: MainUser):
    print("Leave: ", user.identity.hex_encode())
    user_leave.emit(user)

func subscibe_on_lobby(lobby_to_sub: int):
    var query = [
        "SELECT * FROM user WHERE online == true AND lobby_id == " + str(lobby_to_sub), 
        "SELECT * FROM user_data WHERE lobby_id == " + str(lobby_to_sub),
    ]
    var sub := SpacetimeDB.Main.subscribe(query)
    if sub.error:
        printerr("Failed to subscribe to lobby")
