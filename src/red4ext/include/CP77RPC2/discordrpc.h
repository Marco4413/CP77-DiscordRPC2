#ifndef _CP77RPC2_CORE_H
#define _CP77RPC2_CORE_H

#include <atomic>
#include <memory>
#include <mutex>
#include <thread>

#include "discord.h"

#include "CP77RPC2/bindings.h"

namespace CP77RPC2
{
    class DiscordRPC
    {
    public:
        ~DiscordRPC() = default;

        DiscordRPC(const DiscordRPC&) = delete;
        DiscordRPC(DiscordRPC&&) = delete;
        DiscordRPC& operator=(const DiscordRPC&) = delete;
        DiscordRPC& operator=(DiscordRPC&&) = delete;

        bool IsRunning() const;
        bool IsConnected() const;
        bool IsOk() const;

        int32_t GetLastRunCallbacksResult() const;

        void Start();
        void Stop();

        bool UpdateActivity(const Bindings::DiscordActivity& newActivity);
        bool ClearActivity();

    public:
        static const std::unique_ptr<DiscordRPC>& GetInstance();

    private:
        // This class is a singleton, please use ::GetInstance() to retrieve the instance of this class.
        DiscordRPC() = default;

    private:
        static std::unique_ptr<discord::Core> CreateCore(discord::ClientId clientId, uint64_t flags);

    private:
        std::mutex m_Mutex;

        int64_t m_CurrentAppId = 0;
        std::unique_ptr<discord::Core> m_Core = nullptr;
        discord::Result m_LastRunCallbacksResult = discord::Result::NotRunning;

        std::unique_ptr<std::thread> m_Thread = nullptr;
        std::atomic<bool> m_ThreadRunning = false;
    };
}

#endif // _CP77RPC2_CORE_H
