class_name TestObject

var int_prop = 1
var string_prop = "test"
var array_prop
var dict_prop
var obj_prop

var exclude_prop

func who_am_i():
  return get_script().get_global_name()

func save_properties() -> Array:
  return ["int_prop", "string_prop", "array_prop", "dict_prop", "obj_prop"]

func test_function():
  return true