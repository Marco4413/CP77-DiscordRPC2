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
        let activity: DiscordActivity;
        activity.ApplicationId  = 1025361016802005022l;
        activity.Details        = "";
        activity.StartTimestamp = 0ul;
        activity.EndTimestamp   = 0ul;
        activity.LargeImageKey  = "default";
        activity.LargeImageText = "";
        activity.SmallImageKey  = "";
        activity.SmallImageText = "";
        activity.State          = "";
        activity.Type           = DiscordActivityType.Playing;
        activity.PartySize      = -1;
        activity.PartyMax       = -1;
        return activity;
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

    public func OnAttach() -> Void { }
}
