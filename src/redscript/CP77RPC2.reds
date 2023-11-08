module CP77RPC2

public class CP77RPC2 extends ScriptableSystem {
    private let m_Initialized: Bool = false;
    private let m_StartTime: Uint64 = 0ul;

    public func GetStartTime() -> Uint64 { return this.m_StartTime; }
    public func CreateDefaultActivity() -> DiscordActivity {
        return new DiscordActivity(
            1025361016802005022l, // APP ID
            "",
            this.m_StartTime, 0ul,
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

    private func OnAttach() -> Void {
        if (this.m_Initialized) {
            return;
        }

        this.m_Initialized = true;
        this.m_StartTime = DiscordRPC.GetTime();
        this.UpdateActivity(this.CreateDefaultActivity());
    }
}
