extends Node

const BUILD: String = "0.1.0"
const PROTOCOL: int = 1
var notice: String = ""

func content_hash() -> String:
	return (FileAccess.get_file_as_string("res://resources/data/catalog.json") + FileAccess.get_file_as_string("res://resources/data/map.json") + JSON.stringify(QuestionRepository.questions)).sha256_text()
