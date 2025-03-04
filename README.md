# Just Save and Load, Please!

Godot makes it a bit hard to save and load game state. There are many tutorials out there on how to do it, but no obvious, standardized means. This is not surprising, as deciding what data to save (or not) is individual to each game, and restoring a highly interlinked game state is also not at all trivial.

This plugin seeks to add another layer of duct tape by providing a modular, simple way to save and load arbitrary objects.

## This is useful if...
* You store game state outside of the scene tree, e.g. with a data-oriented pattern that
  builds the scene tree dynamically.
* You want to save a custom class without making it a Resource.
* You plan on people sharing the data you are saving.

## This is not useful if...
* You are trying to save the scene tree. It could potentially sorta work, but would be very buggy, unwieldy, and generally not worth the effort. Use PackedScene instead.
* You're trying to store other data like textures, etc in your save file. You can still use the plugin to store object data, but you probably want store resource-shaped things alongside in a zip file and load it separately.
* You're trying to outright replace Resources. Godot does some pretty smart things with
resources that this plugin does not do. Resources are still very much recommended for assets to be packed with the game.

## Usage
To be saved, an object needs to satisfy the following requirements:

1. Exist in the global class table (`[GlobalClass]/class_name`).
2. Implement `save_properties() : Array[String]` that returns a list of property names to save. This would be better handled by an annotation, but custom annotations are not supported in GDScript as of today. Superclass properties can also be included in this list.
3. Optionally, implement `on_load_completed()` that will be called once all data is loaded.

Example:

`my_class.gd`
```
class_name MyClass

var want_to_save
var dont_save

func save_properties():
  return [
    "want_to_save"
  ]

```

Elsewhere...
```
var my_class = MyClass.new()
my_class.want_to_save = "save this"

var saved : String = SaveLoader.save(my_class)

var my_class_2 = SaveLoader.load(saved)
print my_class_2.want_to_save
```

## How It Works
To save, the SaveLoader traverses an object's property tree, and finds any other savable objects, and adds them to an object catalog. Then, the loader goes through the catalog, saving all of the objects' properties and replacing references to other objects with reference markers. The output of this operation is saved to the output.

To load, the SaveLoader parses the object catalog from the dictionary, and instantiates empty copies of each object. It then initializes all savable properties, replacing object reference markers with objects from the catalog. It then returns the root object that was passed into the save() method.

## Why not...

### Resources?
"Resources considered harmful" for data that changes often or is exposed to players.
* Loading resources from outside of res:// is a known ACE vector (https://github.com/godotengine/godot-proposals/issues/4925).
* Renaming variables in resource scripts causes data loss that is difficult to recover from (https://github.com/godotengine/godot-proposals/issues/3152).

### ConfigFile?
* It has the same ACE issue as resources. The underlying issue is that str_to_var can load any object, which includes `script` or objects containing `script`. JSON lets you disallow objects during deserialization.

### Plain JSON?
* Doesn't give control over what to save and what not to save.
* Doesn't save objects unless you turn it on explicitly, at which point it is exposed to
  the same ACE as everything else.