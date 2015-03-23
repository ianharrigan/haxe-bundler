package haxe.tools.bundler;
import haxe.tools.bundler.util.HaxeLib;
import sys.FileSystem;
import sys.io.File;

class OpenFLBundler implements IBundler {
	private static var _fileNames:Array<String> = ["include.xml", "project.xml", "application.xml"];
	
	public function new() {
		
	}
	
	public function bundle(options:Dynamic):Void {
		trace("Performing openfl bundle");
		
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
		var xml:Xml = Xml.parse(contents);
		for (node in xml.firstElement().elementsNamed("haxelib")) {
			var libname:String = node.get("name");
			var currentVersion:String = node.get("version");
			trace(libname +  " version currently set to " + currentVersion);
			var repoVersion:String = HaxeLib.getLocalVersion(libname);
			trace(libname +  " repo version is " + repoVersion);
			node.set("version", repoVersion);
		}
		File.saveContent(file, xml.toString());
	}
	
}