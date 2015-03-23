package haxe.tools.bundler;

import haxe.format.JsonPrinter;
import haxe.tools.bundler.util.HaxeLib;
import sys.FileSystem;
import sys.io.File;

class HaxeLibBundler implements IBundler {
	private static var _fileNames:Array<String> = ["haxelib.json"];
	
	public function new() {
		
	}
	
	public function bundle(options:Dynamic):Void {
		trace("Performing haxelib bundle");
		
		for (f in _fileNames) {
			f = options.path + "/" + f;
			if (FileSystem.exists(f)) {
				processFile(f);
			}
		}

		trace("COMPLETE");
	}

	private function processFile(file) {
		trace("Processing " + file);
		var contents:String = File.getContent(file);
		File.saveContent(file + ".backup", contents);
		var json:Dynamic = Json.parse(contents);
		var deps = json.dependencies;
		for (d in Reflect.fields(deps)) {
			var libname:String = d;
			var currentVersion:String = Reflect.getProperty(deps, d);
			trace(libname +  " version currently set to " + currentVersion);
			var repoVersion:String = HaxeLib.getLocalVersion(libname);
			trace(libname +  " repo version is " + repoVersion);
			Reflect.setProperty(deps, d, repoVersion);
		}
		File.saveContent(file, Json.stringify(json, null, "    "));
	}
}
