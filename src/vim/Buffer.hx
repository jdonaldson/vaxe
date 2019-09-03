package vim;

extern class Buffer implements ArrayAccess<String> {
    @:selfCall
    public function setcurrent() : Void;

    public var name : String;
    public var fname : String;
    public var number : String;

    public function insert(str : String, ?pos : Int) : Void;
    public function next() : Buffer;
    public function previous() : Buffer;
    public function isvalid() : Bool;

}
