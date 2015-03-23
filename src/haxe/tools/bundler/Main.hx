package haxe.tools.bundler;

import haxe.tools.bundler.util.HaxeLib;
import neko.Lib;

class Main  {
	private static var ACTION_BUNDLE:String = "bundle";
	
	private static var SYSTEM_HAXELIB:String = "haxelib";
	private static var SYSTEM_OPENFL:String = "openfl";
	
	
	static function main() {
		var options:Dynamic = {
			action: null,
			system: null,
			path: null
		}
		for (arg in Sys.args()) {
			switch (arg) {
				case "bundle":
					options.action = ACTION_BUNDLE;
				case "-haxelib":
					options.system = SYSTEM_HAXELIB;
				case "-openfl":
					options.system = SYSTEM_OPENFL;
				default:
					options.path = arg;
			}
		}
		
		if (options.path == null) {
			options.path = Sys.getCwd();
		}
		
		trace(options);
		
		if (options.action == null) {
			throw "No action set";
		}
		
		if (options.system == null) {
			throw "No system set";
		}
		
		
		var bundler:IBundler = null;
		switch (options.system) {
			case "haxelib":
				bundler = new HaxeLibBundler();
			case "openfl":
				bundler = new OpenFLBundler();
		}
		
		if (bundler == null) {
			throw "Could not create bundler class";
		}
		
		trace("Using haxelib repo: " + HaxeLib.getRepository());
		
		switch (options.action) {
			case "bundle":
				bundler.bundle(options);
			default:
				throw "Action not recognised";
		}
	}
}