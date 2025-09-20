--// ULTRA INSTANT REEL - EXTREME VERSION
--// Versi paling instan dengan optimalisasi maksimal

--// Services
local Players = cloneref(game:GetService('Players'))
local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local RunService = cloneref(game:GetService('RunService'))

--// Variables
local lp = Players.LocalPlayer
local ultraInstantActive = false
local connections = {}

-- ULTRA INSTANT FLAGS
local flags = {
    ['ultrainstantreel'] = false,
    ['ultrainstantdelay'] = 0, -- ZERO delay
    ['ultrainstantmultifire'] = 10, -- Fire 10x events sekaligus
    ['ultrainstantbypassall'] = true, -- Bypass semua animasi dan GUI
    ['ultrainstantpredictive'] = true, -- Prediktif catch sebelum bite
}

--// ULTRA OPTIMIZED ROD FINDER
local function FindRodUltraFast()
    local character = lp.Character
    if not character then return nil end
    
    -- Check equipped tool first (paling cepat)
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("events") then
            return tool
        end
    end
    
    -- Check backpack if not equipped
    for _, tool in pairs(lp.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("events") then
            return tool
        end
    end
    
    return nil
end

--// ULTRA INSTANT CATCH FUNCTION
local function UltraInstantCatch(rod)
    if not rod or not rod.events then return end
    
    -- INSTANT FIRE MULTIPLE EVENTS (NO DELAY)
    local fireCount = flags['ultrainstantmultifire'] or 10
    
    -- Fire events sebanyak mungkin tanpa delay
    for i = 1, fireCount do
        pcall(function()
            ReplicatedStorage.events.reelfinished:FireServer(100, true)
        end)
    end
    
    -- INSTANT GUI DESTRUCTION - Destroy semua GUI fishing
    pcall(function()
        local guis = {"reel", "shakeui", "fish", "catch", "progress"}
        for _, guiName in pairs(guis) do
            local gui = lp.PlayerGui:FindFirstChild(guiName)
            if gui then
                gui:Destroy()
            end
        end
    end)
    
    -- FORCE STOP ALL ANIMATIONS IMMEDIATELY
    local character = lp.Character
    if character and character:FindFirstChild("Humanoid") then
        local humanoid = character.Humanoid
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            track:Stop() -- Paksa stop
            track:AdjustSpeed(0) -- Set speed ke 0
            track:Destroy() -- Hancurkan track
        end
    end
    
    print("⚡ [ULTRA INSTANT] Catch completed in ZERO time!")
end

--// PREDICTIVE CATCH SYSTEM (catch sebelum fish bite)
local function PredictiveCatch()
    if not flags['ultrainstantpredictive'] then return end
    
    local rod = FindRodUltraFast()
    if not rod or not rod.values then return end
    
    local lureValue = rod.values.lure and rod.values.lure.Value or 0
    
    -- PREDICTIVE: Catch pada 80% lure (sebelum bite actual)
    if lureValue >= 80 then
        UltraInstantCatch(rod)
    end
end

--// ULTRA INSTANT MONITORING SYSTEM
local function StartUltraInstantMonitoring()
    if ultraInstantActive then return end
    ultraInstantActive = true
    
    -- EXTREME HIGH FREQUENCY MONITORING
    connections.heartbeat = RunService.Heartbeat:Connect(function()
        if flags['ultrainstantreel'] then
            PredictiveCatch()
        end
    )
    
    connections.stepped = RunService.Stepped:Connect(function()
        if flags['ultrainstantreel'] then
            PredictiveCatch()
        end
    end)
    
    connections.renderstepped = RunService.RenderStepped:Connect(function()
        if flags['ultrainstantreel'] then
            PredictiveCatch()
        end
    end)
    
    -- INSTANT GUI INTERCEPTION
    connections.guiAdded = lp.PlayerGui.ChildAdded:Connect(function(gui)
        if not flags['ultrainstantreel'] then return end
        
        local fishingGuis = {"reel", "shakeui", "fish", "catch", "progress", "minigame"}
        
        if table.find(fishingGuis, gui.Name) then
            -- INSTANT DESTROY (NO DELAY)
            gui:Destroy()
            
            -- FIRE COMPLETION EVENT
            for i = 1, flags['ultrainstantmultifire'] do
                pcall(function()
                    ReplicatedStorage.events.reelfinished:FireServer(100, true)
                end)
            end
        end
    end)
    
    -- CONTINUOUS ANIMATION BLOCKING
    connections.animationBlock = task.spawn(function()
        while ultraInstantActive do
            if flags['ultrainstantreel'] and flags['ultrainstantbypassall'] then
                pcall(function()
                    local character = lp.Character
                    if character and character:FindFirstChild("Humanoid") then
                        local humanoid = character.Humanoid
                        
                        -- AGGRESSIVE ANIMATION BLOCKING
                        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                            local name = track.Name:lower()
                            local id = tostring(track.Animation.AnimationId):lower()
                            
                            -- Block ALL fishing related animations
                            if name:find("fish") or name:find("reel") or name:find("cast") or 
                               name:find("rod") or name:find("catch") or name:find("lift") or
                               name:find("pull") or name:find("bobber") or name:find("yank") or
                               name:find("shake") or name:find("struggle") or
                               id:find("fish") or id:find("reel") or id:find("cast") or
                               id:find("rod") or id:find("catch") or id:find("lift") or
                               id:find("pull") or id:find("bobber") or id:find("yank") or
                               id:find("shake") or id:find("struggle") then
                                
                                track:Stop()
                                track:AdjustSpeed(0)
                                track:Destroy()
                            end
                        end
                    end
                end)
            end
            task.wait(0.01) -- Check setiap 10ms
        end
    end)
    
    print("🚀 [ULTRA INSTANT REEL] Extreme monitoring activated!")
    print("⚡ Predictive catch, zero animations, maximum speed!")
end

--// ULTRA INSTANT TOGGLE FUNCTION
local function ToggleUltraInstantReel(state)
    flags['ultrainstantreel'] = state
    
    if state then
        StartUltraInstantMonitoring()
        print("⚡ [ULTRA INSTANT REEL] ACTIVATED - MAXIMUM SPEED MODE!")
        print("🎯 Predictive catch enabled - catches fish before they bite!")
        print("🚫 All animations disabled - zero visual delay!")
        print("🔥 Multi-fire enabled - " .. flags['ultrainstantmultifire'] .. "x events per catch!")
    else
        -- Stop all connections
        for name, connection in pairs(connections) do
            if connection then
                if typeof(connection) == "RBXScriptConnection" then
                    connection:Disconnect()
                elseif typeof(connection) == "thread" then
                    task.cancel(connection)
                end
            end
        end
        connections = {}
        ultraInstantActive = false
        print("❌ [ULTRA INSTANT REEL] Deactivated")
    end
end

--// ADVANCED SETTINGS
local function SetUltraInstantSettings(setting, value)
    if setting == "multifire" then
        flags['ultrainstantmultifire'] = math.clamp(value, 5, 20) -- 5-20x fire rate
        print("🔥 Multi-fire set to: " .. flags['ultrainstantmultifire'] .. "x")
    elseif setting == "predictive" then
        flags['ultrainstantpredictive'] = value
        print("🎯 Predictive catch: " .. (value and "ON" or "OFF"))
    elseif setting == "bypassall" then
        flags['ultrainstantbypassall'] = value
        print("🚫 Bypass all animations: " .. (value and "ON" or "OFF"))
    end
end

--// EXTREME OPTIMIZATION - Pre-fire events
local function PreFireEvents()
    if not flags['ultrainstantreel'] then return end
    
    -- Pre-fire events untuk memastikan instant response
    task.spawn(function()
        while flags['ultrainstantreel'] do
            pcall(function()
                -- Pre-fire reelfinished events
                ReplicatedStorage.events.reelfinished:FireServer(100, true)
            end)
            task.wait(0.05) -- Pre-fire setiap 50ms
        end
    end)
end

--// AUTO START SYSTEM
task.spawn(function()
    task.wait(2) -- Wait for game to load
    StartUltraInstantMonitoring()
end)

--// EXPORT FUNCTIONS
_G.UltraInstantReel = {
    Toggle = ToggleUltraInstantReel,
    SetSettings = SetUltraInstantSettings,
    GetFlags = function() return flags end,
    
    -- Quick activation functions
    MaxSpeed = function()
        ToggleUltraInstantReel(true)
        SetUltraInstantSettings("multifire", 20)
        SetUltraInstantSettings("predictive", true)
        SetUltraInstantSettings("bypassall", true)
        PreFireEvents()
        print("🚀 ULTRA INSTANT REEL - MAXIMUM SPEED ACTIVATED!")
    end,
    
    Stop = function()
        ToggleUltraInstantReel(false)
    end
}

print("⚡ Ultra Instant Reel System Loaded!")
print("💡 Usage: _G.UltraInstantReel.MaxSpeed() - untuk aktivasi maksimal")
print("💡 Usage: _G.UltraInstantReel.Stop() - untuk stop")

return _G.UltraInstantReel