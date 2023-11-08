module io.github.marco4413.cp77rpc2

public native class DiscordRPC {
    public native static func GetTime() -> Uint64;
    public native static func UpdateActivity(activity: DiscordActivity, block: Bool) -> Bool;
    public native static func ClearActivity(block: Bool) -> Bool;
}
