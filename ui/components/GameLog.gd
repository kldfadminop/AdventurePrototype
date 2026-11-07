extends PanelContainer

@onready var log_text: RichTextLabel = $VBoxContainer/LogText

func _ready() -> void:
    log_text.scroll_following = true
    log_text.bbcode_enabled = true
    GameLogger.set_ui(log_text)
    await EventBus.init_completed
    GameLogger.log_info("游戏加载完成")