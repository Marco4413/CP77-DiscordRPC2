module CP77RPC2

public class CP77RPC2 extends ScriptableSystem {
    private let m_Initialized: Bool = false;
    private let m_StartTime: Uint64 = 0ul;

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

    private func OnAttach() -> Void {
        if (this.m_Initialized) {
            return;
        }
        
        this.m_Initialized = true;
        this.m_StartTime = DiscordRPC.GetTime();

        LogChannel(n"Debug", "Creating Activity.");
        let activity = this.CreateDefaultActivity();
        LogChannel(n"Debug", "Sending Activity.");
        let ok = DiscordRPC.UpdateActivity(activity, true);
        if (ok) {
            LogChannel(n"Debug", "Activity Sent.");
        } else {
            LogChannel(n"Debug", "Activity not sent.");
        }
    }
}
