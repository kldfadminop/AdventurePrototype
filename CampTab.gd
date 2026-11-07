extends Control

@onready var rest_btn: Button = $VBoxContainer/RestBtn
@onready var inv_container: VBoxContainer = $VBoxContainer/ScrollContainer/InvContainer
var item_buttons: Dictionary = {}

func _ready() -> void:
    if rest_btn:
        rest_btn.pressed.connect(GameState.rest)
    EventBus.resource_changed.connect(_refresh_inventory)
    EventBus.player_stat_changed.connect(_refresh_inventory)
    await EventBus.init_completed
    _refresh_inventory()

func _refresh_inventory() -> void:
    if not inv_container:
        return
    # 清空旧按钮
    for child in inv_container.get_children():
        child.queue_free()
    item_buttons.clear()
    # 遍历所有物品
    for item_id in GameData.ITEMS:
        var count: int = int(GameState.inventory.get(item_id, 0))
        var item_data: Dictionary = GameData.ITEMS.get(item_id, {})
        if count <= 0 and not item_data.get("can_use", false):
            continue
        var hbox: HBoxContainer = HBoxContainer.new()
        hbox.custom_minimum_size = Vector2(0, 30)
        # 物品名称+数量+描述
        var label: Label = Label.new()
        label.size_flags_horizontal = 3
        label.text = "%s x%d - %s" % [
            item_data.get("name", item_id),
            count,
            item_data.get("desc", "")
        ]
        hbox.add_child(label)
        # 使用按钮
        if item_data.get("can_use", false) and count > 0:
            var use_btn: Button = Button.new()
            use_btn.custom_minimum_size = Vector2(80, 25)
            use_btn.text = "[使用]"
            use_btn.pressed.connect(func(): GameState.use_item(item_id))
            hbox.add_child(use_btn)
        inv_container.add_child(hbox)