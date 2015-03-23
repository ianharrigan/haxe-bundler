package haxe.tools.bundler.util;

import haxe.io.Path;
import sys.FileSystem;
import sys.io.*;

using StringTools;

class HaxeLib {
	static var REPNAME = "lib";
	public static var alphanum = ~/^[A-Za-z0-9_.-]+$/;
	
	public static function getRepository( ?setup : Bool ) {
		var win = Sys.systemName() == "Windows";
		var haxepath = Sys.getEnv("HAXEPATH");
		if( haxepath != null )
			haxepath = Path.addTrailingSlash( haxepath );
		var config_file;
		if( win )
			config_file = Sys.getEnv("HOMEDRIVE") + Sys.getEnv("HOMEPATH");
		else
			config_file = Sys.getEnv("HOME");
		config_file += "/.haxelib";
		var rep = try
			File.getContent(config_file)
		catch( e : Dynamic ) try
			File.getContent("/etc/.haxelib")
		catch( e : Dynamic ) {
			if( setup ) {
				(win ? haxepath : "/usr/lib/haxe/")+REPNAME;
			} else if( win ) {
				// Windows have a default directory (no need for setup)
				if( haxepath == null )
					throw "HAXEPATH environment variable not defined, please run haxesetup.exe first";
				var rep = haxepath+REPNAME;
				try {
					safeDir(rep);
				} catch( e : String ) {
					throw "Error accessing Haxelib repository: $e";
				}
				return Path.addTrailingSlash( rep );
			} else
				throw "This is the first time you are runing haxelib. Please run `haxelib setup` first";
		}
		rep = rep.trim();
		if ( setup ) {
			/*
			if( args.length <= argcur ) {
				print("Please enter haxelib repository path with write access");
				print("Hit enter for default (" + rep + ")");
			}
			var line = param("Path");
			if( line != "" )
				rep = line;
			if( !FileSystem.exists(rep) ) {
				try {
					FileSystem.createDirectory(rep);
				} catch( e : Dynamic ) {
					print("Failed to create directory '"+rep+"' ("+Std.string(e)+"), maybe you need appropriate user rights");
					print("Check also that the parent directory exists");
					Sys.exit(1);
				}
			}
			rep = try FileSystem.fullPath(rep) catch( e : Dynamic ) rep;
			File.saveContent(config_file, rep);
			*/
		} else if( !FileSystem.exists(rep) ) {
			throw "haxelib Repository "+rep+" does not exists. Please run `haxelib setup` again";
		} else if ( !FileSystem.isDirectory(rep) ) {
			throw "haxelib Repository "+rep+" exists, but was a file, not a directory.  Please remove it and run `haxelib setup` again.";
		}
		return rep+"/";
	}
	
	static function safeDir( dir ) {
		if( FileSystem.exists(dir) ) {
			if( !FileSystem.isDirectory(dir) )
				throw ("A file is preventing "+dir+" to be created");
		}
		try {
			FileSystem.createDirectory(dir);
		} catch( e : Dynamic ) {
			throw "You don't have enough user rights to create the directory "+dir;
		}
		return true;
	}
	
	public static function safe( name : String ) {
		if( !alphanum.match(name) )
			throw "Invalid parameter : "+name;
		return name.split(".").join(",");
	}

	public static function getLocalVersion(project:String):String {
		var pdir = getRepository() + safe(project);
		if ( !FileSystem.exists(pdir) ) {
			return null;
		}
		return getCurrent(pdir);
	}
	
	static function getCurrent( dir ) {
		return (FileSystem.exists(dir+"/.dev")) ? "dev" : File.getContent(dir + "/.current").trim();
	}
	
}