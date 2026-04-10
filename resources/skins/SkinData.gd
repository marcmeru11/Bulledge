extends Resource
class_name SkinData

# Nombre de la skin (ej: "Nave de Oro")
@export var skin_name: String = ""

# Puntuación necesaria para desbloquearla (ej: 50.5)
@export var required_score: float = 0.0

# La imagen que se le pondrá al Sprite2D del Player
@export var texture: Texture2D
