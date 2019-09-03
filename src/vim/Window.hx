package vim;

extern class Window {
    @:selfCall
    public function setcurrent() : Void;

    public var buffer : Buffer;
    public var line : Int;
    public var col: Int;
    public var width : Int;
    public var height : Int;

    public function next() : Window;
    public function previous() : Window;
    public function isvalid() : Bool;
}
