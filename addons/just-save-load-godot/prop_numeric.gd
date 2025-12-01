class_name JSLGNumeric

# Godot's JSON parses everything as a float, so we add annotations to 
# numeric types inside arrays and dicts.
const int_key : String = "+int"
const float_key : String = "+float"

static func make_numeric(obj) -> Dictionary:
  if obj is int:
    return {int_key: obj}
  elif obj is float:
    return {float_key: obj}
  return {}


static func get_numeric(obj):
  if obj is Dictionary:
    if int_key in obj:
      return obj[int_key] as int
    elif float_key in obj:
      return obj[float_key] as float
  return null 
