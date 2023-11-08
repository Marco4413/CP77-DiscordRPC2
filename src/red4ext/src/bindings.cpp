#include "CP77RPC2/bindings.h"
#include "CP77RPC2/discordcore.h"

#include <chrono>

RED4ext::TTypedClass<CP77RPC2::DiscordRPC> g_DiscordRPCClass("io.github.marco4413.cp77rpc2.DiscordRPC");

void CP77RPC2::DiscordRPC_GetTime(RED4ext::IScriptable* aContext, RED4ext::CStackFrame* aFrame, uint64_t* aOut, int64_t a4)
{
    aFrame->code++;
    if (aOut)
        *aOut = std::chrono::duration_cast<std::chrono::seconds>(std::chrono::system_clock::now().time_since_epoch()).count();
}

void CP77RPC2::DiscordRPC_UpdateActivity(RED4ext::IScriptable* aContext, RED4ext::CStackFrame* aFrame, bool* aOut, int64_t a4)
{
    REDDiscordActivity activity;
    RED4ext::GetParameter(aFrame, &activity);

    bool block;
    RED4ext::GetParameter(aFrame, &block);
    aFrame->code++;

    auto retVal = Discord::UpdateActivity(activity, block);
    if (aOut)
        *aOut = retVal;
}

void CP77RPC2::DiscordRPC_ClearActivity(RED4ext::IScriptable* aContext, RED4ext::CStackFrame* aFrame, bool* aOut, int64_t a4)
{
    bool block;
    RED4ext::GetParameter(aFrame, &block);
    aFrame->code++;

    auto retVal = Discord::ClearActivity(block);
    if (aOut)
        *aOut = retVal;
}

RED4ext::CClass* CP77RPC2::DiscordRPC::GetNativeType()
{
    return &g_DiscordRPCClass;
}

void CP77RPC2::RegisterTypes()
{
    RED4ext::CRTTISystem::Get()->RegisterType(&g_DiscordRPCClass);
}

void CP77RPC2::PostRegisterTypes()
{
    auto rtti = RED4ext::CRTTISystem::Get();
    auto scriptable = rtti->GetClass("IScriptable");
    g_DiscordRPCClass.parent = scriptable;

    auto getTime = RED4ext::CClassStaticFunction::Create(&g_DiscordRPCClass,
        "GetTime", "GetTime", &DiscordRPC_GetTime);
    getTime->SetReturnType("Uint64");
    g_DiscordRPCClass.RegisterFunction(getTime);

    auto updateActivity = RED4ext::CClassStaticFunction::Create(&g_DiscordRPCClass,
        "UpdateActivity", "UpdateActivity", &DiscordRPC_UpdateActivity);
    updateActivity->AddParam("DiscordActivity", "activity");
    updateActivity->AddParam("Bool", "block");
    updateActivity->SetReturnType("Bool");
    g_DiscordRPCClass.RegisterFunction(updateActivity);

    auto clearActivity = RED4ext::CClassStaticFunction::Create(&g_DiscordRPCClass,
        "ClearActivity", "ClearActivity", &DiscordRPC_ClearActivity);
    clearActivity->AddParam("Bool", "block");
    clearActivity->SetReturnType("Bool");
    g_DiscordRPCClass.RegisterFunction(clearActivity);
}
