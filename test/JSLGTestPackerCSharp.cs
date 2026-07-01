using Godot;
using Godot.Collections;

// A C# packer for JSLGTestPackerTargetCSharp. It implements the JSLGSavable trait
// statically so the target can be saved/loaded without implementing the trait itself.
//
// Register with:
//   JSLG.register_packer(JSLGTestPackerCSharp, JSLGTestPackerTargetCSharp.new())
[GlobalClass]
public partial class JSLGTestPackerCSharp : RefCounted
{
    // REQUIRED: static SaveProperties(obj) -> Array
    public static Array<string> SaveProperties(JSLGTestPackerTargetCSharp obj)
    {
        return new Array<string>
        {
            nameof(JSLGTestPackerTargetCSharp.IntProp),
            nameof(JSLGTestPackerTargetCSharp.StringProp),
        };
    }

    // OPTIONAL: static PreSave(obj), called before the object is serialized.
    public static void PreSave(JSLGTestPackerTargetCSharp obj)
    {
        obj.WasSaved = true;
    }

    // OPTIONAL: static PostLoad(obj), called after the object is loaded.
    public static void PostLoad(JSLGTestPackerTargetCSharp obj)
    {
        obj.WasLoaded = true;
    }
}
