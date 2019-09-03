package vim;

import haxe.extern.EitherType;
import lua.UserData;

typedef AnyReference = EitherType<Int,EitherType<String,Bool>>;

@:native('vim')
extern class Vim {
    public static var firstline : String;
    public static var lastline : String;

    public static function isbuffer(value : UserData) : Bool;
    public static function buffer(?arg : AnyReference) : Buffer;
    public static function iswindow(value : UserData) : Bool;
    public static function window(?arg : AnyReference) : Buffer;
    public static function command(cmd : String) : Void;
    public static function eval(cmd : String) : Void;
    public static function line() : String;
    public static function beep() : Void;
    public static function open(fname : String) : Void;
}
