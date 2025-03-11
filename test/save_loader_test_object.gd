class_name TestObject

enum TestEnum {
  TEST1,
  TEST2,
  TEST3
}

var int_prop = 1
var string_prop = "test"
var array_prop
var dict_prop
var typed_array_prop: Array[int]
var typed_dict_prop: Dictionary[String, int]
var enum_prop: TestEnum
var obj_prop

var exclude_prop

func who_am_i():
  return get_script().get_global_name()

func save_properties() -> Array:
  return ["int_prop", "string_prop", "array_prop", "dict_prop", "typed_array_prop", "typed_dict_prop", "enum_prop", "obj_prop"]

func test_function():
  return true