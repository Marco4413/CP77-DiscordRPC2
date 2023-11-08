module CP77RPC2

public class CP77RPC2 extends ScriptableSystem {
    public func CreateDefaultActivity() -> DiscordActivity {
        return new DiscordActivity(
            1025361016802005022l, // APP ID
            "",
            0ul, 0ul,
            "default", "",
            "", "",
            "", DiscordActivityType.Playing,
            -1, -1
        );
    }

    public func UpdateActivity(activity: DiscordActivity) -> Bool {
        return DiscordRPC.UpdateActivity(activity, true);
    }

    public func ClearActivity() -> Bool {
        return DiscordRPC.ClearActivity(true);
    }

    private func OnAttach() -> Void { }
}
