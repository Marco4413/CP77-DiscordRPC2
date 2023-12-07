#pragma once

#ifndef _CP77RPC2_BINDINGS
#define _CP77RPC2_BINDINGS

#include <RED4ext/RED4ext.hpp>

namespace CP77RPC2
{
    enum class REDDiscordActivityType
    {
        Playing = 0,
        Streaming = 1,
        Listening = 2,
        Watching = 3,
    };

    struct REDDiscordActivity
    {
        int64_t ApplicationId = 0;
        RED4ext::CString Details = "";
        uint64_t StartTimestamp = -1;
        uint64_t EndTimestamp = -1;
        RED4ext::CString LargeImageKey = "";
        RED4ext::CString LargeImageText = "";
        RED4ext::CString SmallImageKey = "";
        RED4ext::CString SmallImageText = "";
        RED4ext::CString State = "";
        REDDiscordActivityType Type = REDDiscordActivityType::Playing;
        int32_t PartySize = -1;
        int32_t PartyMax = -1;
    };

    struct DiscordRPC : RED4ext::IScriptable
    {
    public:
        RED4ext::CClass* GetNativeType();
    };
    
    void DiscordRPC_IsRunning(RED4ext::IScriptable* aContext, RED4ext::CStackFrame* aFrame, bool* aOut, int64_t a4);
    void DiscordRPC_IsConnected(RED4ext::IScriptable* aContext, RED4ext::CStackFrame* aFrame, bool* aOut, int64_t a4);
    void DiscordRPC_IsOk(RED4ext::IScriptable* aContext, RED4ext::CStackFrame* aFrame, bool* aOut, int64_t a4);
    
    void DiscordRPC_GetLastRunCallbacksResult(RED4ext::IScriptable* aContext, RED4ext::CStackFrame* aFrame, int32_t* aOut, int64_t a4);

    void DiscordRPC_GetTime(RED4ext::IScriptable* aContext, RED4ext::CStackFrame* aFrame, uint64_t* aOut, int64_t a4);
    void DiscordRPC_UpdateActivity(RED4ext::IScriptable* aContext, RED4ext::CStackFrame* aFrame, bool* aOut, int64_t a4);
    void DiscordRPC_ClearActivity(RED4ext::IScriptable* aContext, RED4ext::CStackFrame* aFrame, bool* aOut, int64_t a4);

    void RegisterTypes();
    void PostRegisterTypes();
}

#endif //_CP77RPC2_BINDINGS
