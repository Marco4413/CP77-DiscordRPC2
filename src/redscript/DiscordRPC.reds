module CP77RPC2

public native class DiscordRPC {
    public native static func IsRunning() -> Bool;
    public native static func IsConnected() -> Bool;
    public native static func IsOk() -> Bool;

    public native static func GetLastRunCallbacksResult() -> Int32;

    public native static func GetTime() -> Uint64;
    public native static func UpdateActivity(activity: DiscordActivity, block: Bool) -> Bool;
    public native static func ClearActivity(block: Bool) -> Bool;
}
