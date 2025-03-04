# Just Save and Load, Please!

Godot makes it a bit hard to save and load game state. There are many tutorials out there on how to do it, but no standardized means. This is not surprising, as deciding what data to save (or not) is individual to each game, and restoring a highly interlinked game state is also not at all trivial.

This plugin seeks to add another layer of duct tape to the solution by providing a simple way to save and load arbitrary objects.

## This is useful if...
* You store game state outside of the scene tree, e.g. with a data-oriented pattern that
  builds the scene tree dynamically.
* You want to save a custom class without making it a Resource.
* You plan on people sharing the data you are saving.

## This is not useful if...
* You are trying to save the scene tree. It could potentially sorta work, but would be very buggy, unwieldy, and generally not worth the effort. Use PackedScene.
* You're trying to store built-ins like textures, anim sequences, etc in your save file. You can still use the plugin to store "generic data", but you probably want store resource-shaped things alongside the generic data in a zip file.

## Usage

```
var my_class = MyClass.new()

var saved : String = SaveLoader.save(my_class)

var my_class_2 = SaveLoader.load(saved)

```

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