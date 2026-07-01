using Godot;

// A plain C# data object that intentionally does NOT implement the JSLGSavable trait.
// It is made savable by registering JSLGTestPackerCSharp as its packer, exercising the
// static packer path with C#/PascalCase method names.
[GlobalClass]
public partial class JSLGTestPackerTargetCSharp : Resource
{
    [Export]
    public int IntProp { get; set; } = 0;

    [Export]
    public string StringProp { get; set; } = string.Empty;

    // Transient flags set by the packer's static hooks. Not part of SaveProperties,
    // so they are never serialized - they only record that the hooks ran.
    public bool WasSaved { get; set; } = false;
    public bool WasLoaded { get; set; } = false;
}
