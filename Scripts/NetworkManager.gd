extends MultiplayerSpawner

enum StateId { Disconnected, Server, Client, Host}

#var state : StateId = StateId.Disconnected

#var State : String : 
	#get:
		#return "[%s]" % StateId.keys()[state]
var debug_state : String : 
	get:
		if multiplayer :
			if multiplayer.has_multiplayer_peer():
				if multiplayer.is_server():
					return "[Server]"
				else:
					return "[Client]"
			else :
				return "[NoPeer]"
		else :
			return "[Offline]"

@onready var offline_scene : PackedScene = preload("res://Scenes/Menu.tscn")
@onready var online_scene : PackedScene = preload("res://Scenes/battlefield.tscn")
@onready var player_object : PackedScene = preload("res://Prefabs/player.tscn")
@onready var mobile_controller: PackedScene = preload("res://Prefabs/mobile_controller.tscn")
@onready var desktop_controller: PackedScene = preload("res://Prefabs/desktop_controller.tscn")

var peer : ENetMultiplayerPeer
var address : String
const port := 7000
const default_server_ip : String = "127.0.0.1" #Ip V4 localhost
const max_connections : int = 1;
var players : Dictionary #[int]:Player

signal player_joined(Player)
signal player_left(Player)

func _ready() -> void:
	DisplayServer.window_set_title("Offline")
	spawn_path = "."
	add_spawnable_scene(player_object.resource_path)

func _process(_delta: float) -> void:
	if multiplayer.has_multiplayer_peer() and multiplayer.is_server() \
	and Input.is_key_pressed(KEY_ESCAPE):
		stop_server()

func set_address(new_address : String) -> void:
	address = new_address

# for desktop player
func start_server() -> void:
	#print("starting server")
	peer = ENetMultiplayerPeer.new()
	if peer.create_server(port, max_connections) != OK:
		return
	multiplayer.multiplayer_peer = peer
	#state = StateId.Server
	DisplayServer.window_set_title("Server")
	multiplayer.peer_connected.connect(peer_connected_to_server)
	multiplayer.peer_disconnected.connect(peer_disconnected_from_server)
	load_online_scene()

func start_client() -> void:
	#print("starting client")
	peer = ENetMultiplayerPeer.new()
	if peer.create_client(address, port) != OK:
		return
	multiplayer.multiplayer_peer = peer
	DisplayServer.window_set_title("Client")
	multiplayer.connected_to_server.connect(client_connected_to_server)
	multiplayer.connection_failed.connect(client_fail_to_connect_to_server)
	multiplayer.server_disconnected.connect(client_disconnected_from_server)
	load_online_scene()

func stop_client() -> void:
	#print("stoping Client")
	multiplayer.connection_failed.disconnect(client_fail_to_connect_to_server)
	multiplayer.connected_to_server.disconnect(client_connected_to_server)
	multiplayer.server_disconnected .disconnect(client_disconnected_from_server)
	DisplayServer.window_set_title("Offline")
	multiplayer.multiplayer_peer = null
	load_offline_scene()

func stop_server() -> void:
	#print("stoping Server")
	multiplayer.peer_connected.disconnect(peer_connected_to_server)
	multiplayer.peer_disconnected.disconnect(peer_disconnected_from_server)
	DisplayServer.window_set_title("Offline")
	multiplayer.multiplayer_peer = null
	load_offline_scene()

func load_online_scene() -> void:
	get_tree().change_scene_to_packed(online_scene)

func load_offline_scene() -> void:
	get_tree().change_scene_to_packed(offline_scene)

func add_player(peer_id : int = 1) -> void:
	var player : Player = player_object.instantiate()
	player.name = "[Player] %s" % peer_id
	players[peer_id] = player
	player.owner_peer_id = peer_id 
	add_child(player,true)
	player_joined.emit(player)

func remove_player(peer_id : int = 1) -> void : 
	var player = players[peer_id]
	players.erase(peer_id)
	player.queue_free()
	player_left.emit(player)

func peer_connected_to_server(peer_id : int) -> void:
	add_player(peer_id)

func peer_disconnected_from_server(peer_id : int) -> void:
	remove_player(peer_id)

func client_fail_to_connect_to_server() -> void:
	printerr("client fail to connect to server")
	stop_client()

func client_connected_to_server() -> void:
	print("client connected to server")

func client_disconnected_from_server() -> void:
	print("client disconnected from server")
	stop_client()

