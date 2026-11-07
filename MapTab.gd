extends Control

@onready var back_btn: Button = $VBoxContainer/BackBtn
@onready var loc_container: VBoxContainer = $VBoxContainer/ScrollContainer/LocContainer

func _ready() -> void:
    if back_btn:
        back_btn.pressed.connect(GameState.go_to_camp)
    EventBus.location_changed.connect(_on_location_changed)
    EventBus.player_stat_changed.connect(_refresh_locations)
    await EventBus.init_completed
    _refresh_locations()

func _refresh_locations() -> void:
    if not loc_container:
        return
    for child in loc_container.get_children():
        child.queue_free()
    var player_level: int = int(GameState.player.get("level", 1))
    var current_loc: String = ExploreSystem.current_location_id
    for loc_id in GameData.LOCATIONS:
        var loc_data: Dictionary = GameData.LOCATIONS.get(loc_id, {})
        var req_level: int = int(loc_data.get("req_level", 1))
        var hbox: HBoxContainer = HBoxContainer.new()
        hbox.custom_minimum_size = Vector2(0, 30)
        var label: Label = Label.new()
        label.size_flags_horizontal = 3
        var status: String = ""
        if loc_id == current_loc:
            status = "（当前在这里）"
        elif player_level < req_level:
            status = "（需要等级%d，当前等级不足）" % req_level
        label.text = "%s [需要等级%d]%s" % [
            loc_data.get("name", "未知地点"),
            req_level,
            status
        ]
        hbox.add_child(label)
        if player_level >= req_level and loc_id != current_loc:
            var go_btn: Button = Button.new()
            go_btn.custom_minimum_size = Vector2(80, 25)
            go_btn.text = "[前往]"
            go_btn.pressed.connect(func(): GameState.go_to_location(loc_id))
            hbox.add_child(go_btn)
        loc_container.add_child(hbox)

func _on_location_changed(new_loc: String) -> void:
    _refresh_locations()