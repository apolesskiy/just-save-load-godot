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

  print(save_data)
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

  print(save_data)
  var loaded_obj = SaveLoader.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.typed_dict_prop, obj.typed_dict_prop)


func test_save_enum():
  var obj = TestObject.new()
  obj.enum_prop = TestObject.TestEnum.TEST2
  var save_data = SaveLoader.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  print(save_data)
  var loaded_obj = SaveLoader.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.enum_prop, obj.enum_prop)
