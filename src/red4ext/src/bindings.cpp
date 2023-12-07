#include "CP77RPC2/bindings.h"
#include "CP77RPC2/discordcore.h"

#include <chrono>

RED4ext::TTypedClass<CP77RPC2::DiscordRPC> g_DiscordRPCClass("CP77RPC2.DiscordRPC");

void CP77RPC2::DiscordRPC_IsRunning(RED4ext::IScriptable* aContext, RED4ext::CStackFrame* aFrame, bool* aOut, int64_t a4)
{
    aFrame->code++;
    if (aOut)
        *aOut = Discord::IsRunning();
}

void CP77RPC2::DiscordRPC_IsConnected(RED4ext::IScriptable* aContext, RED4ext::CStackFrame* aFrame, bool* aOut, int64_t a4)
{
    aFrame->code++;
    if (aOut)
        *aOut = Discord::IsConnected();
}

void CP77RPC2::DiscordRPC_IsOk(RED4ext::IScriptable* aContext, RED4ext::CStackFrame* aFrame, bool* aOut, int64_t a4)
{
    aFrame->code++;
    if (aOut)
        *aOut = Discord::IsOk();
}

void CP77RPC2::DiscordRPC_GetLastRunCallbacksResult(RED4ext::IScriptable* aContext, RED4ext::CStackFrame* aFrame, int32_t* aOut, int64_t a4)
{
    aFrame->code++;
    if (aOut)
        *aOut = Discord::GetLastRunCallbacksResult();
}

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

    // === Discord::IsRunning ===
    auto isRunning = RED4ext::CClassStaticFunction::Create(&g_DiscordRPCClass,
        "IsRunning", "IsRunning", &DiscordRPC_IsRunning);
    isRunning->SetReturnType("Bool");
    g_DiscordRPCClass.RegisterFunction(isRunning);

    // === Discord::IsConnected ===
    auto isConnected = RED4ext::CClassStaticFunction::Create(&g_DiscordRPCClass,
        "IsConnected", "IsConnected", &DiscordRPC_IsConnected);
    isConnected->SetReturnType("Bool");
    g_DiscordRPCClass.RegisterFunction(isConnected);

    // === Discord::IsOk ===
    auto isOk = RED4ext::CClassStaticFunction::Create(&g_DiscordRPCClass,
        "IsOk", "IsOk", &DiscordRPC_IsOk);
    isOk->SetReturnType("Bool");
    g_DiscordRPCClass.RegisterFunction(isOk);

    // === Discord::GetLastRunCallbacksResult ===
    auto getLastRunCallbacksResult = RED4ext::CClassStaticFunction::Create(&g_DiscordRPCClass,
        "GetLastRunCallbacksResult", "GetLastRunCallbacksResult", &DiscordRPC_GetLastRunCallbacksResult);
    getLastRunCallbacksResult->SetReturnType("Int32");
    g_DiscordRPCClass.RegisterFunction(getLastRunCallbacksResult);

    // === GetTime ===
    auto getTime = RED4ext::CClassStaticFunction::Create(&g_DiscordRPCClass,
        "GetTime", "GetTime", &DiscordRPC_GetTime);
    getTime->SetReturnType("Uint64");
    g_DiscordRPCClass.RegisterFunction(getTime);

    // === Discord::UpdateActivity ===
    auto updateActivity = RED4ext::CClassStaticFunction::Create(&g_DiscordRPCClass,
        "UpdateActivity", "UpdateActivity", &DiscordRPC_UpdateActivity);
    updateActivity->AddParam("DiscordActivity", "activity");
    updateActivity->AddParam("Bool", "block");
    updateActivity->SetReturnType("Bool");
    g_DiscordRPCClass.RegisterFunction(updateActivity);

    // === Discord::ClearActivity ===
    auto clearActivity = RED4ext::CClassStaticFunction::Create(&g_DiscordRPCClass,
        "ClearActivity", "ClearActivity", &DiscordRPC_ClearActivity);
    clearActivity->AddParam("Bool", "block");
    clearActivity->SetReturnType("Bool");
    g_DiscordRPCClass.RegisterFunction(clearActivity);
}
