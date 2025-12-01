class_name JSLGTestObject extends Resource

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
var vector2_prop = Vector2(1.0, 2.0)
var vector2i_prop = Vector2i(1, 2)
var vector3_prop = Vector3(1.0, 2.0, 3.0)
var vector3i_prop = Vector3i(1, 2, 3)
var color_prop = Color(1.0, 0.5, 0.0)
var rect2_prop = Rect2(1.0, 2.0, 3.0, 4.0)
var rect2i_prop = Rect2i(1, 2, 3, 4)
var transform2d_prop = Transform2D.IDENTITY
var plane_prop = Plane(Vector3(0, 1, 0), 0)
var quaternion_prop = Quaternion.IDENTITY
var aabb_prop = AABB(Vector3(0, 0, 0), Vector3(1, 1, 1))
var basis_prop = Basis.IDENTITY
var transform3d_prop = Transform3D.IDENTITY
var rid_prop = RID()
var packed_byte_array_prop = PackedByteArray([1, 2, 3])
var packed_int32_array_prop = PackedInt32Array([1, 2, 3])
var packed_int64_array_prop = PackedInt64Array([1, 2, 3])
var packed_float32_array_prop = PackedFloat32Array([1.0, 2.0, 3.0])
var packed_float64_array_prop = PackedFloat64Array([1.0, 2.0, 3.0])
var packed_string_array_prop = PackedStringArray(["a", "b", "c"])
var packed_vector2_array_prop = PackedVector2Array([Vector2(1, 2), Vector2(3, 4)])
var packed_vector3_array_prop = PackedVector3Array([Vector3(1, 2, 3), Vector3(4, 5, 6)])
var packed_color_array_prop = PackedColorArray([Color(1, 0, 0), Color(0, 1, 0)])
var exported_resource_ref : Resource
var was_loaded = false

var exclude_prop

func who_am_i():
  return get_script().get_global_name()

func on_load_complete():
  was_loaded = true

func save_properties() -> Array:
  return [
    "int_prop", 
    "string_prop", 
    "array_prop", 
    "dict_prop", 
    "typed_array_prop", 
    "typed_dict_prop", 
    "enum_prop", 
    "obj_prop", 
    "vector2_prop", 
    "vector2i_prop", 
    "vector3_prop", 
    "vector3i_prop", 
    "color_prop", 
    "rect2_prop",
    "rect2i_prop",
    "transform2d_prop",
    "plane_prop",
    "quaternion_prop",
    "aabb_prop",
    "basis_prop",
    "transform3d_prop",
    "rid_prop",
    "packed_byte_array_prop",
    "packed_int32_array_prop",
    "packed_int64_array_prop",
    "packed_float32_array_prop",
    "packed_float64_array_prop",
    "packed_string_array_prop",
    "packed_vector2_array_prop",
    "packed_vector3_array_prop",
    "packed_color_array_prop",
    "exported_resource_ref",
    ]

func test_function():
  return true