package vim.api;
import lua.Table;
import haxe.Constraints.Function;

@:native("vim.api.nvim")
extern class Nvim {
    @:native("nvim_command")
    public static function command(cmd : String) : Void;

    @:native("nvim_get_hl_by_name")
    public static function get_hl_by_name(name:String, rgb:Dynamic) : Dynamic;

    @:native("nvim_get_hl_by_id")
    public static function get_hl_by_id(id:String, rgb:Dynamic) : Dynamic;

    @:native("nvim_feedkeys")
    public static function feedkeys(keys:String, mode:Int, escape_csi:Bool) : Void;

    @:native("nvim_input")
    public static function input(keys:String) : Int;

    @:native("nvim_input_mouse")
    public static function input_mouse(button:String, action:String, modifier:String, grid:Int, row:Int, col:Int) : Void;

    @:native("nvim_replace_termcodes")
    public static function replace_termcodes(str:String, from_part:Bool, do_lt:Bool, special:Bool) : Void;

    @:native("nvim_command_output")
    public static function command_output(command:String) : Void;

    @:native("nvim_eval")
    public static function eval(expr:String) : Void;

    @:native("nvim_execute_lua")
    public static function execute_lua(code:String, args:Table<Int,String>) : Dynamic;

    @:native("nvim_call_function")
    public static function call_function(fn:Function, args:Table<Int,String>) : Dynamic;

    @:native("nvim_call_dict_function")
    public static function call_dict_function(dict:Table<String,String>, fn:String, args:Table<Int,String>) : Dynamic;

    @:native("nvim_strwidth")
    public static function strwidth(txt:String) : Int;


}

extern class ApiVersion {
    public var api_level : Int;
    public var api_compatible : Int;
    public var api_prerelease : Bool;
}
