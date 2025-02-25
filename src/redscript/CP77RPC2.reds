module CP77RPC2

enum DiscordActivityType {
    Playing   = 0,
    Streaming = 1,
    Listening = 2,
    Watching  = 3,
}

struct DiscordActivity {
    let ApplicationId: Int64;
    let Details: String;
    let StartTimestamp: Uint64;
    let EndTimestamp: Uint64;
    let LargeImageKey: String;
    let LargeImageText: String;
    let SmallImageKey: String;
    let SmallImageText: String;
    let State: String;
    let Type: DiscordActivityType;
    let PartySize: Int32;
    let PartyMax: Int32;
}

public native class DiscordRPC {
    public native static func IsRunning() -> Bool;
    public native static func IsConnected() -> Bool;
    public native static func IsOk() -> Bool;

    public native static func GetLastRunCallbacksResult() -> Int32;

    public native static func GetTime() -> Uint64;
    public native static func UpdateActivity(activity: DiscordActivity) -> Bool;
    public native static func ClearActivity() -> Bool;
}

public class CP77RPC2 extends ScriptableSystem {
    public func CreateDefaultActivity() -> DiscordActivity {
        return new DiscordActivity(
            /* ApplicationId  = */ 1025361016802005022l,
            /* Details        = */ "",
            /* StartTimestamp = */ 0ul,
            /* EndTimestamp   = */ 0ul,
            /* LargeImageKey  = */ "default",
            /* LargeImageText = */ "",
            /* SmallImageKey  = */ "",
            /* SmallImageText = */ "",
            /* State          = */ "",
            /* Type           = */ DiscordActivityType.Playing,
            /* PartySize      = */ -1,
            /* PartyMax       = */ -1
        );
    }

    public func IsRunning() -> Bool {
        return DiscordRPC.IsRunning();
    }

    public func IsConnected() -> Bool {
        return DiscordRPC.IsConnected();
    }

    public func IsOk() -> Bool {
        return DiscordRPC.IsOk();
    }

    public func GetLastRunCallbacksResult() -> Int32 {
        return DiscordRPC.GetLastRunCallbacksResult();
    }

    public func UpdateActivity(activity: DiscordActivity) -> Bool {
        return DiscordRPC.UpdateActivity(activity);
    }

    public func ClearActivity() -> Bool {
        return DiscordRPC.ClearActivity();
    }

    private func OnAttach() -> Void { }
}
