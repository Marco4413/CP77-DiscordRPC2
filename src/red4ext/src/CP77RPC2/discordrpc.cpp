#include "CP77RPC2/discordrpc.h"

const std::unique_ptr<CP77RPC2::DiscordRPC>& CP77RPC2::DiscordRPC::GetInstance()
{
    static std::unique_ptr<DiscordRPC> instance(new DiscordRPC());
    return instance;
}

std::unique_ptr<discord::Core> CP77RPC2::DiscordRPC::CreateCore(discord::ClientId clientId, uint64_t flags)
{
    discord::Core* core = nullptr;
    auto res = discord::Core::Create(clientId, flags, &core);
    if (res == discord::Result::Ok)
        return std::unique_ptr<discord::Core>(core);
    return nullptr;
}

bool CP77RPC2::DiscordRPC::IsRunning() const
{
    return m_Core && m_ThreadRunning;
}

bool CP77RPC2::DiscordRPC::IsConnected() const
{
    if (!IsRunning())
        return false;
    switch (m_LastRunCallbacksResult) {
    case discord::Result::ServiceUnavailable:
    case discord::Result::InvalidAccessToken:
    case discord::Result::NotInstalled:
    case discord::Result::NotRunning:
    case discord::Result::OAuth2Error:
        return false;
    case discord::Result::Ok:
    default:
        return true;
    }
}

bool CP77RPC2::DiscordRPC::IsOk() const
{
    return IsRunning() && m_LastRunCallbacksResult == discord::Result::Ok;
}

int32_t CP77RPC2::DiscordRPC::GetLastRunCallbacksResult() const
{
    return static_cast<int32_t>(m_LastRunCallbacksResult);
}

void CP77RPC2::DiscordRPC::Start()
{
    std::lock_guard lock(this->m_Mutex);
    if (m_ThreadRunning || m_Thread) return;

    this->m_ThreadRunning = true;
    m_Thread = std::make_unique<std::thread>([this]() {
        while (this->m_ThreadRunning) {
            std::this_thread::sleep_for(std::chrono::seconds(1));
            std::lock_guard lock(this->m_Mutex);
            if (this->m_Core) {
                this->m_LastRunCallbacksResult = this->m_Core->RunCallbacks();
            }
        }
    });
}

void CP77RPC2::DiscordRPC::Stop()
{
    m_ThreadRunning = false;
    std::lock_guard lock(m_Mutex);
    if (m_Thread) {
        m_Thread->join();
        m_Thread = nullptr;
    }
}

bool CP77RPC2::DiscordRPC::UpdateActivity(const Bindings::DiscordActivity& newActivity)
{
    if (!m_ThreadRunning)
        return false;

    std::lock_guard lock(m_Mutex);
    if (!m_Core || newActivity.ApplicationId != m_CurrentAppId || !IsConnected()) {
        m_Core = DiscordRPC::CreateCore(newActivity.ApplicationId, DiscordCreateFlags_NoRequireDiscord);
        if (!m_Core) return false;
        m_CurrentAppId = newActivity.ApplicationId;
    }

    discord::Activity dActivity{};
    dActivity.SetState(newActivity.State.c_str());
    dActivity.SetDetails(newActivity.Details.c_str());
    
    if (newActivity.StartTimestamp != -1)
        dActivity.GetTimestamps().SetStart(newActivity.StartTimestamp);
    if (newActivity.EndTimestamp != -1)
        dActivity.GetTimestamps().SetEnd(newActivity.EndTimestamp);

    dActivity.GetAssets().SetLargeImage(newActivity.LargeImageKey.c_str());
    dActivity.GetAssets().SetLargeText(newActivity.LargeImageText.c_str());

    dActivity.GetAssets().SetSmallImage(newActivity.SmallImageKey.c_str());
    dActivity.GetAssets().SetSmallText(newActivity.SmallImageText.c_str());

    switch (newActivity.Type) {
    case Bindings::DiscordActivityType::Streaming:
        dActivity.SetType(discord::ActivityType::Streaming);
        break;
    case Bindings::DiscordActivityType::Listening:
        dActivity.SetType(discord::ActivityType::Listening);
        break;
    case Bindings::DiscordActivityType::Watching:
        dActivity.SetType(discord::ActivityType::Watching);
        break;
    default: // REDDiscordActivityType::Playing
        dActivity.SetType(discord::ActivityType::Playing);
    }

    if (newActivity.PartySize >= 0)
        dActivity.GetParty().GetSize().SetCurrentSize(newActivity.PartySize);
    if (newActivity.PartyMax >= 0)
        dActivity.GetParty().GetSize().SetCurrentSize(newActivity.PartyMax);

    m_Core->ActivityManager().UpdateActivity(dActivity, nullptr);
    return true;
}

bool CP77RPC2::DiscordRPC::ClearActivity()
{
    if (!m_ThreadRunning)
        return false;

    std::lock_guard lock(m_Mutex);
    if (m_Core) {
        m_Core->ActivityManager()
            .ClearActivity(nullptr);
    }
    return true;
}
