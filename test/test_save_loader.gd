class_name JSLGTestJSLG extends GutTest


func test_save_simple():
  var obj = JSLGTestObject.new()
  var save_data = JSLG.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = JSLG.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.int_prop, obj.int_prop)
  assert_eq(loaded_obj.string_prop, obj.string_prop)
  assert_eq(obj.was_loaded, false)
  assert_eq(loaded_obj.was_loaded, true)


func test_pre_save():
  var obj = JSLGTestObject.new()
  assert_eq(obj.was_saved, false)
  var save_data = JSLG.save(obj)
  assert_not_null(save_data)
  # pre_save is called on the source object before it is serialized.
  assert_eq(obj.was_saved, true)


func test_save_simple_array_dict():
  var obj = JSLGTestObject.new()
  obj.array_prop = [1, 2, 3]
  obj.dict_prop = {"a": 1, "b": 2, "c": 3}
  var save_data = JSLG.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = JSLG.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.array_prop, obj.array_prop)
  assert_eq(loaded_obj.dict_prop, obj.dict_prop)
  # Test that script runs.
  assert_true(loaded_obj.test_function())


func test_save_nested_objects():
  var obj = JSLGTestObject.new()
  obj.obj_prop = JSLGTestObject.new()
  obj.obj_prop.int_prop = 2
  obj.obj_prop.string_prop = "nested"
  var save_data = JSLG.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = JSLG.load(save_data)
  assert_not_null(loaded_obj)
  assert_not_null(loaded_obj.obj_prop)
  assert_eq(loaded_obj.obj_prop.int_prop, obj.obj_prop.int_prop)
  assert_eq(loaded_obj.obj_prop.string_prop, obj.obj_prop.string_prop)
  # Test that script runs.
  assert_true(loaded_obj.test_function())
  assert_true(loaded_obj.obj_prop.test_function())


func test_save_nested_objects_in_array():
  var obj = JSLGTestObject.new()
  obj.array_prop = [JSLGTestObject.new(), JSLGTestObject.new()]
  obj.array_prop[0].int_prop = 2
  obj.array_prop[0].string_prop = "nested"
  obj.array_prop[1].int_prop = 3
  obj.array_prop[1].string_prop = "nested2"
  var save_data = JSLG.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = JSLG.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.array_prop[0].int_prop, obj.array_prop[0].int_prop)
  assert_eq(loaded_obj.array_prop[0].string_prop, obj.array_prop[0].string_prop)
  assert_eq(loaded_obj.array_prop[1].int_prop, obj.array_prop[1].int_prop)
  assert_eq(loaded_obj.array_prop[1].string_prop, obj.array_prop[1].string_prop)


func test_save_nested_objects_in_dict_value():
  var obj = JSLGTestObject.new()
  obj.dict_prop = {"a": JSLGTestObject.new(), "b": JSLGTestObject.new()}
  obj.dict_prop["a"].int_prop = 2
  obj.dict_prop["a"].string_prop = "nested"
  obj.dict_prop["b"].int_prop = 3
  obj.dict_prop["b"].string_prop = "nested2"
  var save_data = JSLG.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = JSLG.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.dict_prop["a"].int_prop, obj.dict_prop["a"].int_prop)
  assert_eq(loaded_obj.dict_prop["a"].string_prop, obj.dict_prop["a"].string_prop)
  assert_eq(loaded_obj.dict_prop["b"].int_prop, obj.dict_prop["b"].int_prop)
  assert_eq(loaded_obj.dict_prop["b"].string_prop, obj.dict_prop["b"].string_prop)


func test_save_nested_objects_in_dict_key():
  var obj = JSLGTestObject.new()
  obj.dict_prop = {JSLGTestObject.new(): 1, JSLGTestObject.new(): 2}
  obj.dict_prop.keys()[0].int_prop = 2
  obj.dict_prop.keys()[0].string_prop = "nested"
  obj.dict_prop.keys()[1].int_prop = 3
  obj.dict_prop.keys()[1].string_prop = "nested2"
  var save_data = JSLG.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = JSLG.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.dict_prop.keys()[0].int_prop, obj.dict_prop.keys()[0].int_prop)
  assert_eq(loaded_obj.dict_prop.keys()[0].string_prop, obj.dict_prop.keys()[0].string_prop)
  assert_eq(loaded_obj.dict_prop.keys()[1].int_prop, obj.dict_prop.keys()[1].int_prop)
  assert_eq(loaded_obj.dict_prop.keys()[1].string_prop, obj.dict_prop.keys()[1].string_prop)


func test_save_nested_arrays():
  var obj = JSLGTestObject.new()
  obj.array_prop = [[1, 2, 3], [4, 5, 6]]
  var save_data = JSLG.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = JSLG.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.array_prop, obj.array_prop)


func test_save_nested_dicts():
  var obj = JSLGTestObject.new()
  obj.dict_prop = {"a": {"b": 1, "c": 2}, "d": {"e": 3, "f": 4}}
  var save_data = JSLG.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = JSLG.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.dict_prop, obj.dict_prop)


func test_save_mixed_arrays():
  var obj = JSLGTestObject.new()
  obj.array_prop = [1, "test", [1, 2, 3], {"a": 1, "b": 2}]
  var save_data = JSLG.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = JSLG.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.array_prop, obj.array_prop)


func test_load_invalid_data():
  var loaded_obj = JSLG.load("whargarblgarbage")
  assert_null(loaded_obj)


func test_save_typed_array():
  var obj = JSLGTestObject.new()
  # Can't set a literal here because Godot can't do it yet.
  obj.typed_array_prop.append(1)
  obj.typed_array_prop.append(2)
  obj.typed_array_prop.append(3)
  print("TYPE >> " + type_string(typeof(obj.typed_array_prop)))
  print("VAL >> " + str(obj.typed_array_prop))
  var save_data = JSLG.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = JSLG.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.typed_array_prop, obj.typed_array_prop)


func test_save_typed_dict():
  var obj = JSLGTestObject.new()
  # Can't set a literal here because Godot can't do it yet.
  obj.typed_dict_prop["a"] = 1
  obj.typed_dict_prop["b"] = 2
  obj.typed_dict_prop["c"] = 3
  var save_data = JSLG.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = JSLG.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.typed_dict_prop, obj.typed_dict_prop)


func test_save_enum():
  var obj = JSLGTestObject.new()
  obj.enum_prop = JSLGTestObject.TestEnum.TEST2
  var save_data = JSLG.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = JSLG.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.enum_prop, obj.enum_prop)


func test_save_builtin_types():
  var obj = JSLGTestObject.new()

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

  var save_data = JSLG.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = JSLG.load(save_data)
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
  var obj = JSLGTestObject.new()
  obj.exported_resource_ref = preloaded_resource

  var save_data = JSLG.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = JSLG.load(save_data)
  assert_not_null(loaded_obj)
  assert_not_null(loaded_obj.exported_resource_ref)
  assert_eq(loaded_obj.exported_resource_ref, obj.exported_resource_ref)
  assert_eq(loaded_obj.exported_resource_ref, preloaded_resource)


func test_savable_resource_with_uid_use_cached():
  var preloaded_test_object = preload("uid://c0l7bnq5u8wyx") # test_resource_saved.tres, which is a JSLGTestObject.
  var obj = JSLGTestObject.new()
  obj.exported_resource_ref = preloaded_test_object

  var save_data = JSLG.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  print(save_data)
  var loaded_obj = JSLG.load(save_data)
  assert_not_null(loaded_obj)
  assert_not_null(loaded_obj.exported_resource_ref)
  assert_eq(loaded_obj.exported_resource_ref, preloaded_test_object) # No new instance created.


func test_save_nan_float():
  # JSON has no NaN literal, so Godot serializes NaN as null. JSLGNumeric must
  # round-trip it back to NAN. NAN != NAN, so we check with is_nan().
  var obj = JSLGTestObject.new()
  obj.array_prop = [NAN]
  obj.dict_prop = {"nan": NAN}
  var save_data = JSLG.save(obj)
  # JSON.stringify emits an engine warning when it replaces NaN with null.
  # Assert it so GUT treats it as expected rather than an unexpected error.
  assert_engine_error("NaN")
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = JSLG.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.array_prop.size(), 1)
  assert_true(is_nan(loaded_obj.array_prop[0]), "Array NaN should round-trip to NAN")
  assert_true(loaded_obj.dict_prop.has("nan"))
  assert_true(is_nan(loaded_obj.dict_prop["nan"]), "Dict NaN should round-trip to NAN")


func test_csharp_savable_object():
  var csharp_obj = JSLGTestObjectCSharp.new()
  csharp_obj.IntProp = 42
  csharp_obj.StringProp = "Hello from GDScript"

  var save_data = JSLG.save(csharp_obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = JSLG.load(save_data)
  assert_true(loaded_obj != null)
  assert_eq(loaded_obj.IntProp, csharp_obj.IntProp)
  assert_eq(loaded_obj.StringProp, csharp_obj.StringProp)
  assert_eq(csharp_obj.WasLoaded, false)
  assert_eq(loaded_obj.WasLoaded, true)


func test_csharp_pre_save():
  var csharp_obj = JSLGTestObjectCSharp.new()
  assert_eq(csharp_obj.WasSaved, false)
  var save_data = JSLG.save(csharp_obj)
  assert_not_null(save_data)
  # PreSave is called on the source object before it is serialized.
  assert_eq(csharp_obj.WasSaved, true)


# --- Packer feature ---
# JSLGTestPackerTarget does not implement the savable trait itself; JSLGTestPacker
# is registered as a packer for it. Registration is idempotent per session, so it
# lives in before_all.
func before_all():
  # Only register once - the packer registry is process-global.
  if JSLGObjectHandler.get_packer_for_object(JSLGTestPackerTarget.new()) == null:
    JSLG.register_packer(JSLGTestPacker, JSLGTestPackerTarget.new())
  if JSLGObjectHandler.get_packer_for_object(JSLGTestPackerTargetCSharp.new()) == null:
    JSLG.register_packer(JSLGTestPackerCSharp, JSLGTestPackerTargetCSharp.new())
  # Node packer, used by the node tree tests. Free the throwaway example node.
  var example_node = JSLGTestPackerNode.new()
  if JSLGObjectHandler.get_packer_for_object(example_node) == null:
    JSLG.register_packer(JSLGTestNodePacker, example_node)
  example_node.free()


func test_packer_save_load():
  var obj = JSLGTestPackerTarget.new()
  obj.int_prop = 7
  obj.string_prop = "packed"
  var save_data = JSLG.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = JSLG.load(save_data)
  assert_not_null(loaded_obj)
  assert_true(loaded_obj is JSLGTestPackerTarget)
  assert_eq(loaded_obj.int_prop, obj.int_prop)
  assert_eq(loaded_obj.string_prop, obj.string_prop)


func test_packer_pre_save():
  var obj = JSLGTestPackerTarget.new()
  assert_eq(obj.was_saved, false)
  JSLG.save(obj)
  # The packer's static pre_save(obj) runs on the source object before serialization.
  assert_eq(obj.was_saved, true)


func test_packer_post_load():
  var obj = JSLGTestPackerTarget.new()
  var save_data = JSLG.save(obj)

  var loaded_obj = JSLG.load(save_data)
  assert_not_null(loaded_obj)
  # The source object is not post-loaded; the loaded one is, via the packer's static post_load.
  assert_eq(obj.was_loaded, false)
  assert_eq(loaded_obj.was_loaded, true)


func test_packer_and_trait_interop():
  # A trait-based object (JSLGTestObject) referencing a packer-managed object.
  # Exercises both save mechanisms in a single object graph.
  var root = JSLGTestObject.new()
  root.int_prop = 11
  var packed_child = JSLGTestPackerTarget.new()
  packed_child.int_prop = 22
  packed_child.string_prop = "child"
  root.obj_prop = packed_child

  var save_data = JSLG.save(root)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = JSLG.load(save_data)
  assert_not_null(loaded_obj)
  assert_eq(loaded_obj.int_prop, root.int_prop)
  assert_not_null(loaded_obj.obj_prop)
  assert_true(loaded_obj.obj_prop is JSLGTestPackerTarget)
  assert_eq(loaded_obj.obj_prop.int_prop, packed_child.int_prop)
  assert_eq(loaded_obj.obj_prop.string_prop, packed_child.string_prop)
  # Both mechanisms fired their post_load hook.
  assert_eq(loaded_obj.was_loaded, true)          # trait post_load
  assert_eq(loaded_obj.obj_prop.was_loaded, true) # packer static post_load


func test_csharp_packer_save_load():
  var obj = JSLGTestPackerTargetCSharp.new()
  obj.IntProp = 9
  obj.StringProp = "csharp packed"
  var save_data = JSLG.save(obj)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded_obj = JSLG.load(save_data)
  assert_not_null(loaded_obj)
  assert_true(loaded_obj is JSLGTestPackerTargetCSharp)
  assert_eq(loaded_obj.IntProp, obj.IntProp)
  assert_eq(loaded_obj.StringProp, obj.StringProp)


func test_csharp_packer_pre_save():
  var obj = JSLGTestPackerTargetCSharp.new()
  assert_eq(obj.WasSaved, false)
  JSLG.save(obj)
  # The packer's static PreSave(obj) runs on the source object before serialization.
  assert_eq(obj.WasSaved, true)


func test_csharp_packer_post_load():
  var obj = JSLGTestPackerTargetCSharp.new()
  var save_data = JSLG.save(obj)

  var loaded_obj = JSLG.load(save_data)
  assert_not_null(loaded_obj)
  # The source object is not post-loaded; the loaded one is, via the packer's static PostLoad.
  assert_eq(obj.WasLoaded, false)
  assert_eq(loaded_obj.WasLoaded, true)


# --- Node tree feature ---
# Savable nodes save and re-parent their savable children automatically, without
# an explicit "children" property.
func test_node_no_children():
  var node = autofree(JSLGTestSavableNode.new())
  node.int_prop = 5
  node.string_prop = "root"

  var save_data = JSLG.save(node)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  var loaded = JSLG.load(save_data)
  assert_not_null(loaded)
  autofree(loaded)
  assert_true(loaded is JSLGTestSavableNode)
  assert_eq(loaded.int_prop, 5)
  assert_eq(loaded.string_prop, "root")
  assert_eq(loaded.get_child_count(), 0)


func test_node_with_savable_children():
  var parent = autofree(JSLGTestSavableNode.new())
  parent.int_prop = 1
  var child_a = JSLGTestSavableNode.new()
  child_a.int_prop = 10
  child_a.string_prop = "a"
  var child_b = JSLGTestSavableNode.new()
  child_b.int_prop = 20
  child_b.string_prop = "b"
  parent.add_child(child_a)
  parent.add_child(child_b)

  var save_data = JSLG.save(parent)
  assert_not_null(save_data)

  var loaded = JSLG.load(save_data)
  assert_not_null(loaded)
  autofree(loaded)
  assert_eq(loaded.get_child_count(), 2)
  var loaded_children = loaded.get_children()
  # Child order is preserved.
  assert_eq(loaded_children[0].int_prop, 10)
  assert_eq(loaded_children[0].string_prop, "a")
  assert_eq(loaded_children[1].int_prop, 20)
  assert_eq(loaded_children[1].string_prop, "b")
  # post_load ran on the loaded children.
  assert_true(loaded_children[0].was_loaded)
  assert_true(loaded_children[1].was_loaded)


func test_node_with_non_savable_children():
  var parent = autofree(JSLGTestSavableNode.new())
  var plain_child = Node.new()  # no trait, no packer -> not savable
  plain_child.name = "PlainChild"
  var savable_child = JSLGTestSavableNode.new()
  savable_child.int_prop = 7
  parent.add_child(plain_child)
  parent.add_child(savable_child)

  var save_data = JSLG.save(parent)
  assert_not_null(save_data)

  var loaded = JSLG.load(save_data)
  assert_not_null(loaded)
  autofree(loaded)
  # Only the savable child is restored; the plain Node is not saved.
  assert_eq(loaded.get_child_count(), 1)
  assert_true(loaded.get_child(0) is JSLGTestSavableNode)
  assert_eq(loaded.get_child(0).int_prop, 7)


func test_node_with_packer_children():
  var parent = autofree(JSLGTestSavableNode.new())
  var packer_child = JSLGTestPackerNode.new()  # savable only via registered packer
  packer_child.int_prop = 99
  parent.add_child(packer_child)

  var save_data = JSLG.save(parent)
  assert_not_null(save_data)

  var loaded = JSLG.load(save_data)
  assert_not_null(loaded)
  autofree(loaded)
  assert_eq(loaded.get_child_count(), 1)
  assert_true(loaded.get_child(0) is JSLGTestPackerNode)
  assert_eq(loaded.get_child(0).int_prop, 99)


func test_resource_referencing_node_tree():
  # A savable resource referencing a savable node that has savable children.
  var root = JSLGTestObject.new()
  root.int_prop = 3
  var node = autofree(JSLGTestSavableNode.new())
  node.int_prop = 50
  var node_child = JSLGTestSavableNode.new()
  node_child.int_prop = 60
  node_child.string_prop = "leaf"
  node.add_child(node_child)
  root.obj_prop = node

  var save_data = JSLG.save(root)
  assert_not_null(save_data)

  var loaded = JSLG.load(save_data)
  assert_not_null(loaded)
  assert_eq(loaded.int_prop, 3)
  assert_not_null(loaded.obj_prop)
  assert_true(loaded.obj_prop is JSLGTestSavableNode)
  autofree(loaded.obj_prop)
  assert_eq(loaded.obj_prop.int_prop, 50)
  assert_eq(loaded.obj_prop.get_child_count(), 1)
  assert_eq(loaded.obj_prop.get_child(0).int_prop, 60)
  assert_eq(loaded.obj_prop.get_child(0).string_prop, "leaf")


func test_node_deep_tree():
  # Savable children are traversed recursively, so grandchildren are saved too.
  var root = autofree(JSLGTestSavableNode.new())
  root.int_prop = 1
  var child = JSLGTestSavableNode.new()
  child.int_prop = 2
  var grandchild = JSLGTestSavableNode.new()
  grandchild.int_prop = 3
  child.add_child(grandchild)
  root.add_child(child)

  var save_data = JSLG.save(root)
  assert_not_null(save_data)

  var loaded = JSLG.load(save_data)
  assert_not_null(loaded)
  autofree(loaded)
  assert_eq(loaded.get_child_count(), 1)
  var loaded_child = loaded.get_child(0)
  assert_eq(loaded_child.int_prop, 2)
  assert_eq(loaded_child.get_child_count(), 1)
  assert_eq(loaded_child.get_child(0).int_prop, 3)


# --- Model scene feature ---
# A savable node's model_scene (a PackedScene) is instantiated on load, and its
# non-savable children are reparented onto the node, restoring static data that was
# never serialized.
const MODEL_SCENE = preload("res://test/model_scene.tscn")
const BLANK_ROOT_MODEL = preload("res://test/blank_root_model.tscn")
# A Node2D model: savable root (saves its transform) + a static, offset Node2D child.
const MODEL_SCENE_2D = preload("res://test/model_scene_2d.tscn")


func test_model_scene_spawn_save_delete_load():
  # Spawn an authored scene: savable root + savable child + non-savable static child.
  var instance = MODEL_SCENE.instantiate()
  instance.model_scene = MODEL_SCENE  # this scene is its own model
  instance.int_prop = 5
  var savable_child = instance.get_node("SavableChild")
  savable_child.int_prop = 222  # runtime state that must survive the round trip

  var save_data = JSLG.save(instance)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  # Delete the spawned tree.
  instance.free()

  # Load into a fresh tree.
  var loaded = JSLG.load(save_data)
  assert_not_null(loaded)
  autofree(loaded)
  # The handler queue_free()s the temporary model instance; let that frame process.
  await get_tree().process_frame
  assert_true(loaded is JSLGTestModelNode)
  assert_eq(loaded.int_prop, 5)

  # One savable child (from save data) and one static child (from the model scene).
  var savable_children = []
  var static_children = []
  for child in loaded.get_children():
    if child is JSLGTestSavableNode:
      savable_children.append(child)
    else:
      static_children.append(child)
  assert_eq(savable_children.size(), 1, "savable child restored from save data")
  assert_eq(savable_children[0].int_prop, 222, "savable child runtime state survived")
  assert_eq(static_children.size(), 1, "static child restored from model scene")
  assert_eq(static_children[0].name, "StaticChild")


func test_model_scene_non_packedscene_ignored():
  var node = autofree(JSLGTestModelNode.new())
  # A non-PackedScene value must be rejected by get_model_scene.
  node.model_scene = "not a packed scene"
  assert_null(JSLGNodeTreeHandler.get_model_scene(node))

  # A full save/load with a bogus model_scene still succeeds and spawns nothing.
  var save_data = JSLG.save(node)
  assert_not_null(save_data)
  var loaded = JSLG.load(save_data)
  assert_not_null(loaded)
  autofree(loaded)
  assert_eq(loaded.get_child_count(), 0)


func test_model_scene_none():
  # No model_scene set: existing node behavior, loads normally with no spawned children.
  var node = autofree(JSLGTestModelNode.new())
  node.int_prop = 9
  assert_null(JSLGNodeTreeHandler.get_model_scene(node))

  var save_data = JSLG.save(node)
  assert_not_null(save_data)
  var loaded = JSLG.load(save_data)
  assert_not_null(loaded)
  autofree(loaded)
  assert_eq(loaded.int_prop, 9)
  assert_eq(loaded.get_child_count(), 0)


func test_model_scene_blank_root():
  # The model scene's root is a plain (non-savable) Node; it is discarded and its
  # non-savable children are reparented onto the loaded node.
  var node = autofree(JSLGTestModelNode.new())
  node.model_scene = BLANK_ROOT_MODEL

  var save_data = JSLG.save(node)
  assert_not_null(save_data)
  var loaded = JSLG.load(save_data)
  assert_not_null(loaded)
  autofree(loaded)
  # The handler queue_free()s the temporary model instance; let that frame process.
  await get_tree().process_frame
  assert_eq(loaded.get_child_count(), 2)
  var names = []
  for c in loaded.get_children():
    names.append(c.name)
  assert_true(names.has(&"StaticA"), "StaticA reparented from model scene")
  assert_true(names.has(&"StaticB"), "StaticB reparented from model scene")


# --- Model scene transform preservation ---
# When a model_scene's static child is reparented onto the loaded node, its authored
# local offset must be preserved so its GLOBAL position matches what a plain
# PackedScene.instantiate() would produce. Regression guard for a bug where the static
# child spawned displaced by the root's transform (reparent kept the child's global
# transform relative to the throwaway model root, which sits at the origin, instead of
# keeping its local offset relative to the loaded node).
func test_model_scene_2d_child_global_position_preserved():
  var instance = MODEL_SCENE_2D.instantiate()
  instance.model_scene = MODEL_SCENE_2D  # this scene is its own model
  add_child(instance)

  # Move the root away from the origin, then record where the static child sits globally.
  instance.position = Vector2(100, 100)
  var offset_child = instance.get_node("StaticOffsetChild")
  var expected_global_position = offset_child.global_position
  # Sanity: authored local offset is (50, 30), root at (100, 100) -> child global (150, 130).
  assert_eq(expected_global_position, Vector2(150, 130), "spawned child global position")

  var save_data = JSLG.save(instance)
  assert_not_null(save_data)
  assert_ne(save_data, "")

  # Delete the spawned tree.
  instance.free()

  # Load into a fresh node.
  var loaded = JSLG.load(save_data)
  assert_not_null(loaded)
  add_child_autoqfree(loaded)
  # The handler queue_free()s the temporary model instance; let that frame process.
  await get_tree().process_frame

  var loaded_child = loaded.get_node_or_null("StaticOffsetChild")
  assert_not_null(loaded_child, "static offset child restored from model scene")
  assert_true(loaded_child.global_position.is_equal_approx(expected_global_position),
    "loaded static child global position preserved. expected %s got %s" %
    [expected_global_position, loaded_child.global_position])


# As above, but the root carries a non-trivial transform (translation + rotation + scale),
# so preserving the child's full global transform - not just its position - is exercised.
func test_model_scene_2d_child_global_transform_preserved():
  var instance = MODEL_SCENE_2D.instantiate()
  instance.model_scene = MODEL_SCENE_2D
  add_child(instance)

  instance.position = Vector2(100, 100)
  instance.rotation = deg_to_rad(30)
  instance.scale = Vector2(2, 2)
  var offset_child = instance.get_node("StaticOffsetChild")
  var expected_global_transform = offset_child.global_transform

  var save_data = JSLG.save(instance)
  assert_not_null(save_data)

  instance.free()

  var loaded = JSLG.load(save_data)
  assert_not_null(loaded)
  add_child_autoqfree(loaded)
  await get_tree().process_frame

  var loaded_child = loaded.get_node_or_null("StaticOffsetChild")
  assert_not_null(loaded_child, "static offset child restored from model scene")
  assert_true(loaded_child.global_transform.is_equal_approx(expected_global_transform),
    "loaded static child global transform preserved. expected %s got %s" %
    [expected_global_transform, loaded_child.global_transform])
