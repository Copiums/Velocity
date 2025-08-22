--[[

    ____   ____     .__                .__  __          
    \   \ /   /____ |  |   ____   ____ |__|/  |_ ___.__.
     \   Y   // __ \|  |  /  _ \_/ ___\|  \   __<   |  |
      \     /\  ___/|  |_(  <_> )  \___|  ||  |  \___  |
       \___/  \___  >____/\____/ \___  >__||__|  / ____|
                  \/                 \/          \/      

       The #1 Roblox Bedwars Vape Config on the market.

        - luc - modules / organizer
		- null.wtf - modules 
		- copium - modules
		- sammz - modules
		- lr - modules
        - blanked - modules
        - gamesense - modules
        - sown - modules
        - relevant - executor
        - nick - first UI



       _  _                       _                 __ _  _       _                     _    _          
     _| |<_> ___ ___  ___  _ _  _| |    ___  ___   / /| |<_>._ _ | |__ _ _  ___  _ _  _| |_ <_> ___ ___ 
    / . || |<_-</ | '/ . \| '_>/ . | _ / . |/ . | / / | || || ' || / /| | |/ ._>| '_>  | |  | |<_-</ ._>
    \___||_|/__/\_|_.\___/|_|  \___|<_>\_. |\_. |/_/  |_||_||_|_||_\_\|__/ \___.|_|    |_|  |_|/__/\___.
                                       <___'<___'                                                       

]]--

local velo: table = {};
local vape: table = shared.velo
local function notif(...: any): void
        return vape:CreateNotification(...);
end;

velo.run = function(x : Function)
        return x();
end;

velo.run(function()
        loadstring(readfile("velo/games/Velocity.lua"))();
end)
