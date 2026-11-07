extends Control

@onready var monster_label: Label = $VBoxContainer/MonsterInfo
@onready var player_hp_label: Label = $VBoxContainer/PlayerInfo
@onready var attack_btn: Button = $VBoxContainer/ButtonRow/AttackBtn
@onready var heavy_btn: Button = $VBoxContainer/ButtonRow/HeavyBtn
@onready var flee_btn: Button = $VBoxContainer/ButtonRow/FleeBtn

func _ready() -> void:
    if attack_btn:
        attack_btn.pressed.connect(func(): BattleSystem.player_attack(false))
    if heavy_btn:
        heavy_btn.pressed.connect(func(): BattleSystem.player_attack(true))
    if flee_btn:
        flee_btn.pressed.connect(BattleSystem.try_flee)
    EventBus.battle_start.connect(_on_battle_start)
    EventBus.battle_end.connect(_on_battle_end)
    EventBus.battle_turn_update.connect(_refresh_battle)
    EventBus.player_stat_changed.connect(_refresh_battle)
    _set_buttons_enabled(false)

func _set_buttons_enabled(enabled: bool) -> void:
    if attack_btn:
        attack_btn.disabled = not enabled
    if heavy_btn:
        heavy_btn.disabled = not enabled
    if flee_btn:
        flee_btn.disabled = not enabled

func _on_battle_start(_monster: Dictionary) -> void:
    _set_buttons_enabled(true)
    _refresh_battle()

func _on_battle_end(_is_win: bool) -> void:
    _set_buttons_enabled(false)
    if monster_label:
        monster_label.text = "当前没有战斗"

func _refresh_battle() -> void:
    if not monster_label:
        return
    if not BattleSystem.in_battle:
        monster_label.text = "当前没有战斗"
        player_hp_label.text = "你的气血：%d/%d" % [
            int(GameState.player.get("hp", 0)),
            int(GameState.player.get("max_hp", 100))
        ]
        return
    var m: Dictionary = BattleSystem.current_monster
    monster_label.text = "怪物：%s | 气血：%d | 攻击：%d" % [
        m.get("name", "怪物"),
        m.get("hp", 0),
        m.get("atk", 0)
    ]
    player_hp_label.text = "你的气血：%d/%d" % [
        int(GameState.player.get("hp", 0)),
        int(GameState.player.get("max_hp", 100))
    ]