class_name TestSaveLoader extends GutTest


func test_save_simple():
  var obj = TestObject.new()
  var save_data = SaveLoader.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = SaveLoader.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.int_prop, obj.int_prop)
  assert_eq(loaded_obj.string_prop, obj.string_prop)


func test_save_simple_array_dict():
  var obj = TestObject.new()
  obj.array_prop = [1, 2, 3]
  obj.dict_prop = {"a": 1, "b": 2, "c": 3}
  var save_data = SaveLoader.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = SaveLoader.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.array_prop, obj.array_prop)
  assert_eq(loaded_obj.dict_prop, obj.dict_prop)
  # Test that script runs.
  assert_true(loaded_obj.test_function())


func test_save_nested_objects():
  var obj = TestObject.new()
  obj.obj_prop = TestObject.new()
  obj.obj_prop.int_prop = 2
  obj.obj_prop.string_prop = "nested"
  var save_data = SaveLoader.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = SaveLoader.load(save_data)
  assert_not_null(loaded_obj)
  assert_not_null(loaded_obj.obj_prop)
  assert_eq(loaded_obj.obj_prop.int_prop, obj.obj_prop.int_prop)
  assert_eq(loaded_obj.obj_prop.string_prop, obj.obj_prop.string_prop)
  # Test that script runs.
  assert_true(loaded_obj.test_function())
  assert_true(loaded_obj.obj_prop.test_function())


func test_save_nested_objects_in_array():
  var obj = TestObject.new()
  obj.array_prop = [TestObject.new(), TestObject.new()]
  obj.array_prop[0].int_prop = 2
  obj.array_prop[0].string_prop = "nested"
  obj.array_prop[1].int_prop = 3
  obj.array_prop[1].string_prop = "nested2"
  var save_data = SaveLoader.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = SaveLoader.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.array_prop[0].int_prop, obj.array_prop[0].int_prop)
  assert_eq(loaded_obj.array_prop[0].string_prop, obj.array_prop[0].string_prop)
  assert_eq(loaded_obj.array_prop[1].int_prop, obj.array_prop[1].int_prop)
  assert_eq(loaded_obj.array_prop[1].string_prop, obj.array_prop[1].string_prop)


func test_save_nested_objects_in_dict_value():
  var obj = TestObject.new()
  obj.dict_prop = {"a": TestObject.new(), "b": TestObject.new()}
  obj.dict_prop["a"].int_prop = 2
  obj.dict_prop["a"].string_prop = "nested"
  obj.dict_prop["b"].int_prop = 3
  obj.dict_prop["b"].string_prop = "nested2"
  var save_data = SaveLoader.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = SaveLoader.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.dict_prop["a"].int_prop, obj.dict_prop["a"].int_prop)
  assert_eq(loaded_obj.dict_prop["a"].string_prop, obj.dict_prop["a"].string_prop)
  assert_eq(loaded_obj.dict_prop["b"].int_prop, obj.dict_prop["b"].int_prop)
  assert_eq(loaded_obj.dict_prop["b"].string_prop, obj.dict_prop["b"].string_prop)


func test_save_nested_objects_in_dict_key():
  var obj = TestObject.new()
  obj.dict_prop = {TestObject.new(): 1, TestObject.new(): 2}
  obj.dict_prop.keys()[0].int_prop = 2
  obj.dict_prop.keys()[0].string_prop = "nested"
  obj.dict_prop.keys()[1].int_prop = 3
  obj.dict_prop.keys()[1].string_prop = "nested2"
  var save_data = SaveLoader.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = SaveLoader.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.dict_prop.keys()[0].int_prop, obj.dict_prop.keys()[0].int_prop)
  assert_eq(loaded_obj.dict_prop.keys()[0].string_prop, obj.dict_prop.keys()[0].string_prop)
  assert_eq(loaded_obj.dict_prop.keys()[1].int_prop, obj.dict_prop.keys()[1].int_prop)
  assert_eq(loaded_obj.dict_prop.keys()[1].string_prop, obj.dict_prop.keys()[1].string_prop)


func test_save_nested_arrays():
  var obj = TestObject.new()
  obj.array_prop = [[1, 2, 3], [4, 5, 6]]
  var save_data = SaveLoader.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = SaveLoader.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.array_prop, obj.array_prop)


func test_save_nested_dicts():
  var obj = TestObject.new()
  obj.dict_prop = {"a": {"b": 1, "c": 2}, "d": {"e": 3, "f": 4}}
  var save_data = SaveLoader.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = SaveLoader.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.dict_prop, obj.dict_prop)


func test_save_mixed_arrays():
  var obj = TestObject.new()
  obj.array_prop = [1, "test", [1, 2, 3], {"a": 1, "b": 2}]
  var save_data = SaveLoader.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = SaveLoader.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.array_prop, obj.array_prop)


func test_load_invalid_data():
  var loaded_obj = SaveLoader.load("whargarblgarbage")
  assert_null(loaded_obj)


func test_save_typed_array():
  var obj = TestObject.new()
  # Can't set a literal here because Godot can't do it yet.
  obj.typed_array_prop.append(1)
  obj.typed_array_prop.append(2)
  obj.typed_array_prop.append(3)
  print("TYPE >> " + type_string(typeof(obj.typed_array_prop)))
  print("VAL >> " + str(obj.typed_array_prop))
  var save_data = SaveLoader.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = SaveLoader.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.typed_array_prop, obj.typed_array_prop)


func test_save_typed_dict():
  var obj = TestObject.new()
  # Can't set a literal here because Godot can't do it yet.
  obj.typed_dict_prop["a"] = 1
  obj.typed_dict_prop["b"] = 2
  obj.typed_dict_prop["c"] = 3
  var save_data = SaveLoader.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = SaveLoader.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.typed_dict_prop, obj.typed_dict_prop)


func test_save_enum():
  var obj = TestObject.new()
  obj.enum_prop = TestObject.TestEnum.TEST2
  var save_data = SaveLoader.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = SaveLoader.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.enum_prop, obj.enum_prop)

func test_save_builtin_types():
  var obj = TestObject.new()

  obj.vector2_prop = Vector2(2.0, 2.0)
  obj.vector2i_prop = Vector2i(2, 2)
  obj.vector3_prop = Vector3(3.0, 2.0, 3.0)
  obj.vector3i_prop = Vector3i(3, 2, 3)
  obj.color_prop = Color(3.0, 0.5, 0.0)
  obj.rect2_prop = Rect2(3.0, 2.0, 3.0, 4.0)
  obj.rect2i_prop = Rect2i(1, 2, 5, 6)
  obj.transform2d_prop = Transform2D(0.5, Vector2(1, 1))
  obj.plane_prop = Plane(Vector3(0, 1, 1), 0)
  obj.quaternion_prop = Quaternion(0.5, 0.5, 0.5, 0.5)
  obj.aabb_prop = AABB(Vector3(0, 0, 0), Vector3(1, 1, 2))
  obj.basis_prop = Basis(Vector3(0.5, 0.5, 0.5), Vector3(1, 1, 1), Vector3(1, 0, 0))
  obj.transform3d_prop = Transform3D(Basis(Vector3(0.5, 0.5, 0.5), Vector3(1, 1, 1), Vector3(1, 0, 0)), Vector3(1, 1, 1))
  obj.rid_prop = RID()
  obj.packed_byte_array_prop = PackedByteArray([3, 4, 5])
  obj.packed_int32_array_prop = PackedInt32Array([3, 4, 5])
  obj.packed_int64_array_prop = PackedInt64Array([3, 4, 5])
  obj.packed_float32_array_prop = PackedFloat32Array([2.0, 2.0, 3.0])
  obj.packed_float64_array_prop = PackedFloat64Array([2.0, 2.0, 3.0])
  obj.packed_string_array_prop = PackedStringArray(["d", "b", "c"])
  obj.packed_vector2_array_prop = PackedVector2Array([Vector2(2, 2), Vector2(3, 4)])
  obj.packed_vector3_array_prop = PackedVector3Array([Vector3(2, 2, 3), Vector3(3, 5, 6)])
  obj.packed_color_array_prop = PackedColorArray([Color(1, 1, 0), Color(1, 1, 0)])

  var save_data = SaveLoader.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = SaveLoader.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.vector2_prop, obj.vector2_prop)
  assert_eq(loaded_obj.vector2i_prop, obj.vector2i_prop)
  assert_eq(loaded_obj.vector3_prop, obj.vector3_prop)
  assert_eq(loaded_obj.vector3i_prop, obj.vector3i_prop)
  assert_eq(loaded_obj.color_prop, obj.color_prop)
  assert_eq(loaded_obj.rect2_prop, obj.rect2_prop)
  assert_eq(loaded_obj.rect2i_prop, obj.rect2i_prop)
  assert_true(loaded_obj.transform2d_prop.is_equal_approx(obj.transform2d_prop))
  assert_eq(loaded_obj.plane_prop, obj.plane_prop)
  assert_true(loaded_obj.quaternion_prop.is_equal_approx(obj.quaternion_prop))
  assert_eq(loaded_obj.aabb_prop, obj.aabb_prop)
  assert_eq(loaded_obj.basis_prop, obj.basis_prop)
  assert_true(loaded_obj.transform3d_prop.is_equal_approx(obj.transform3d_prop))
  assert_eq(loaded_obj.rid_prop, obj.rid_prop)
  assert_eq(loaded_obj.packed_byte_array_prop, obj.packed_byte_array_prop)
  assert_eq(loaded_obj.packed_int32_array_prop, obj.packed_int32_array_prop)
  assert_eq(loaded_obj.packed_int64_array_prop, obj.packed_int64_array_prop)
  assert_eq(loaded_obj.packed_float32_array_prop, obj.packed_float32_array_prop)
  assert_eq(loaded_obj.packed_float64_array_prop, obj.packed_float64_array_prop)
  assert_eq(loaded_obj.packed_string_array_prop, obj.packed_string_array_prop)
  assert_eq(loaded_obj.packed_vector2_array_prop, obj.packed_vector2_array_prop)
  assert_eq(loaded_obj.packed_vector3_array_prop, obj.packed_vector3_array_prop)
  assert_eq(loaded_obj.packed_color_array_prop, obj.packed_color_array_prop)

func test_save_resource_reference():
  var preloaded_resource = preload("uid://itov6b543ess") # The default icon.svg
  var obj = TestObject.new()
  obj.exported_resource_ref = preloaded_resource

  var save_data = SaveLoader.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  print(save_data)
  var loaded_obj = SaveLoader.load(save_data)
  assert_not_null(loaded_obj)
  assert_not_null(loaded_obj.exported_resource_ref)
  assert_eq(loaded_obj.exported_resource_ref, obj.exported_resource_ref)
  assert_eq(loaded_obj.exported_resource_ref, preloaded_resource)