extends Node2D

@onready var PLAYER_SCENE = preload("res://player.tscn")
@onready var menu: Panel = $menu_canvas/Panel
@onready var ip_selected: TextEdit = $menu_canvas/Panel/VBoxContainer/ip_selected
@onready var ip_list: RichTextLabel = $menu_canvas/Panel/VBoxContainer/ScrollContainer/ip_list


var PORT: int = 7070;
var MAX_CONNECTIONS: int = 8;
var PEER: ENetMultiplayerPeer;
var ADDRESS: String = ""


func _ready():
	_init_ip_list()

	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)	



func _init_ip_list():
	var _text = ""
	var results = []
	for ip in _get_ip_address_list():
		if ip.begins_with("192.168."):
			_text += ip + "\n"
			results.append(ip)
	ip_list.text = _text
	if results.size() == 1:
		ip_selected.text = results[0]
		ADDRESS = results[0]



func _get_ip_address_list():
	var _ip_list = []
	var local_addresses = IP.get_local_addresses()
	for address in local_addresses:
		if address.is_valid_ip_address():
			_ip_list.append(address)
	return _ip_list


func _on_ip_selected_text_changed():
	ADDRESS = ip_selected.text


func _on_host_pressed():
	PEER = ENetMultiplayerPeer.new()
	var error = PEER.create_server(PORT, MAX_CONNECTIONS)
	if error: return error
	multiplayer.multiplayer_peer = PEER
	
	menu.visible = false

	var label = Label.new()
	label.text = "Server started at %s:%s" % [ADDRESS, PORT]
	label.position = Vector2(100, 100)
	DisplayServer.clipboard_set(IP.get_local_addresses()[0] + ":" + str(PORT))
	
	add_child(label)
	

	print("Server started")

func _on_join_pressed():
	PEER = ENetMultiplayerPeer.new()
	var error = PEER.create_client(ADDRESS, PORT)
	if error: return error
	multiplayer.multiplayer_peer = PEER
	menu.visible = false
	print("Client started")

func _add_player(id):
	if not multiplayer.is_server(): return
	var player = PLAYER_SCENE.instantiate()
	if id == 1:
		player.name = str(multiplayer.get_unique_id())
	else:
		player.name = str(id)
	add_child(player, true)


func _on_connected_to_server():
	print("Connected to server")


func _on_connection_failed():
	print("Connection failed")


func _on_peer_connected(id):
	_add_player(id)


func _on_peer_disconnected(id):
	print("Peer disconnected: ", id)

