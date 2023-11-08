module io.github.marco4413.cp77rpc2

enum DiscordActivityType {
    Playing = 0,
    Streaming = 1,
    Listening = 2,
    Watching = 3,
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
