# A plain data object that intentionally does NOT implement the JSLGSavable trait.
# It is made savable by registering JSLGTestPacker via JSLG.register_packer, which
# exercises the "static packer" path in JSLGObjectHandler.
class_name JSLGTestPackerTarget extends Resource

var int_prop = 0
var string_prop = ""
# Can hold another savable object (trait-based or packer-based) to test interop.
var nested_prop

# Transient flags set by the packer's static hooks. Not part of save_properties,
# so they are never serialized - they only record that the hooks ran.
var was_saved = false
var was_loaded = false
