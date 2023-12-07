#include "CP77RPC2/discordcore.h"

#include <discord.h>

#include <memory>
#include <mutex>
#include <thread>

int64_t g_AppId = 0;
std::unique_ptr<discord::Core> g_Core = nullptr;
discord::Result g_LastRunCallbacksResult = discord::Result::NotRunning;
std::mutex g_CoreMutex;
std::unique_ptr<std::thread> g_Thread = nullptr;
bool g_ThreadRunning = false;

std::unique_ptr<discord::Core> _CreateDiscordCore(discord::ClientId clientId, uint64_t flags)
{
    discord::Core* _corePtr = nullptr;
    auto res = discord::Core::Create(clientId, flags, &_corePtr);
    if (res == discord::Result::Ok)
        return std::unique_ptr<discord::Core>(_corePtr);
    return nullptr;
}

void _RunCallbacks()
{
    g_ThreadRunning = true;
    while (g_ThreadRunning) {
        std::this_thread::sleep_for(std::chrono::seconds(1));
        {
            std::lock_guard lock(g_CoreMutex);
            if (g_Core)
                g_LastRunCallbacksResult = g_Core->RunCallbacks();
        }
    }
}

bool CP77RPC2::Discord::IsRunning()
{
    return g_Core && g_ThreadRunning;
}

bool CP77RPC2::Discord::IsConnected()
{
    if (!IsRunning())
        return false;
    switch (g_LastRunCallbacksResult) {
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

bool CP77RPC2::Discord::IsOk()
{
    return IsRunning() && g_LastRunCallbacksResult == discord::Result::Ok;
}

int32_t CP77RPC2::Discord::GetLastRunCallbacksResult()
{
    return static_cast<int32_t>(g_LastRunCallbacksResult);
}

void CP77RPC2::Discord::Start()
{
    if (g_ThreadRunning)
        return;
    else if (g_Thread)
        g_Thread->join();
    g_Thread = std::make_unique<std::thread>(_RunCallbacks);
}

void CP77RPC2::Discord::Stop()
{
    g_ThreadRunning = false;
    if (g_Thread) {
        g_Thread->join();
        g_Thread = nullptr;
    }
}

bool CP77RPC2::Discord::UpdateActivity(const CP77RPC2::REDDiscordActivity& redActivity, bool block)
{
    if (!g_ThreadRunning)
        return false;

    bool locked = g_CoreMutex.try_lock();
    if (!locked) {
        if (!block)
            return false;
        g_CoreMutex.lock();
    }

    if (!g_Core || redActivity.ApplicationId != g_AppId || !IsConnected()) {
        g_Core = _CreateDiscordCore(redActivity.ApplicationId, DiscordCreateFlags_NoRequireDiscord);
        if (!g_Core) {
            g_CoreMutex.unlock();
            return false;
        }
        g_AppId = redActivity.ApplicationId;
    }

    discord::Activity dActivity{};
    dActivity.SetState(redActivity.State.c_str());
    dActivity.SetDetails(redActivity.Details.c_str());
    
    if (redActivity.StartTimestamp != -1)
        dActivity.GetTimestamps().SetStart(redActivity.StartTimestamp);
    if (redActivity.EndTimestamp != -1)
        dActivity.GetTimestamps().SetEnd(redActivity.EndTimestamp);

    dActivity.GetAssets().SetLargeImage(redActivity.LargeImageKey.c_str());
    dActivity.GetAssets().SetLargeText(redActivity.LargeImageText.c_str());

    dActivity.GetAssets().SetSmallImage(redActivity.SmallImageKey.c_str());
    dActivity.GetAssets().SetSmallText(redActivity.SmallImageText.c_str());

    switch (redActivity.Type) {
    case REDDiscordActivityType::Streaming:
        dActivity.SetType(discord::ActivityType::Streaming);
        break;
    case REDDiscordActivityType::Listening:
        dActivity.SetType(discord::ActivityType::Listening);
        break;
    case REDDiscordActivityType::Watching:
        dActivity.SetType(discord::ActivityType::Watching);
        break;
    default: // REDDiscordActivityType::Playing
        dActivity.SetType(discord::ActivityType::Playing);
    }

    if (redActivity.PartySize >= 0)
        dActivity.GetParty().GetSize().SetCurrentSize(redActivity.PartySize);
    if (redActivity.PartyMax >= 0)
        dActivity.GetParty().GetSize().SetCurrentSize(redActivity.PartyMax);

    g_Core->ActivityManager().UpdateActivity(dActivity, nullptr);
    g_CoreMutex.unlock();
    return true;
}

bool CP77RPC2::Discord::ClearActivity(bool block)
{
    if (!g_ThreadRunning)
        return false;

    bool locked = g_CoreMutex.try_lock();
    if (!locked) {
        if (!block)
            return false;
        g_CoreMutex.lock();
    }

    if (g_Core)
        g_Core->ActivityManager().ClearActivity(nullptr);
    g_CoreMutex.unlock();
    return true;
}
