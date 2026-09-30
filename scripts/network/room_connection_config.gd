extends Resource
## Set this to the deployed relay URL before exporting the game.
@export var relay_url: String = ""
@export_range(15, 120, 1) var connection_timeout_seconds: int = 75
