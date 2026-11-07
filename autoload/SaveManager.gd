extends Node

const SAVE_PATH: String = "res://save/save.json"

func _ready() -> void:
	# 创建存档目录
	var dir: DirAccess = DirAccess.open("res://")
	if not dir.dir_exists("save"):
		dir.make_dir("save")

func save_game(data: Dictionary, is_auto: bool = false) -> bool:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		GameLogger.log_bad("存档写入失败")
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	if is_auto:
		GameLogger.log_info("已自动存档")
	else:
		GameLogger.log_good("游戏已手动存档")
	return true

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		GameLogger.log_bad("存档读取失败")
		return {}
	var content: String = file.get_as_text()
	file.close()
	var parse_res: Variant = JSON.parse_string(content)
	if parse_res is Dictionary:
		return parse_res
	return {}

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		GameLogger.log_info("旧存档已删除")
