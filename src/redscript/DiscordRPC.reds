module CP77RPC2

public native class DiscordRPC {
    public native static func GetTime() -> Uint64;
    public native static func UpdateActivity(activity: DiscordActivity, block: Bool) -> Bool;
    public native static func ClearActivity(block: Bool) -> Bool;
}
