#pragma once

#ifndef _CP77RPC2_DISCORDCORE
#define _CP77RPC2_DISCORDCORE

#include "CP77RPC2/bindings.h"

namespace CP77RPC2
{
    namespace Discord
    {
        void Start();
        void Stop();

        bool UpdateActivity(const REDDiscordActivity& redActivity, bool block);
        bool ClearActivity(bool block);
    }
}

#endif // _CP77RPC2_DISCORDCORE
