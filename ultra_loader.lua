--// ULTRA INSTANT REEL - MAIN LOADER
--// File utama untuk load semua sistem ultra instant

print("🚀 Loading Ultra Instant Reel System...")

-- LOAD CONFIG FIRST
loadstring(game:HttpGet("https://raw.githubusercontent.com/FRISDAWOYLASARISUSILO/fishch/main/ultra_config.lua"))()

-- LOAD MAIN SYSTEM
loadstring(game:HttpGet("https://raw.githubusercontent.com/FRISDAWOYLASARISUSILO/fishch/main/ultra_instant_reel.lua"))()

-- WAIT FOR SYSTEMS TO LOAD
task.wait(1)

-- SETUP ULTRA INSTANT REEL
if _G.UltraInstantReel and _G.UltraInstantConfig then
    -- Load Maximum profile by default
    _G.UltraInstantConfig:LoadProfile("Maximum")
    
    -- Create integrated system
    local UltraSystem = {}
    
    -- QUICK START FUNCTION
    function UltraSystem:QuickStart()
        print("⚡ ULTRA INSTANT REEL - QUICK START!")
        _G.UltraInstantConfig:LoadProfile("Maximum")
        _G.UltraInstantReel.MaxSpeed()
        print("🎯 System aktif dengan pengaturan maksimal!")
    end
    
    -- CUSTOM START
    function UltraSystem:CustomStart(profile)
        profile = profile or "Maximum"
        print("⚡ ULTRA INSTANT REEL - CUSTOM START: " .. profile)
        _G.UltraInstantConfig:LoadProfile(profile)
        _G.UltraInstantReel.MaxSpeed()
    end
    
    -- STOP ALL
    function UltraSystem:Stop()
        _G.UltraInstantReel.Stop()
        print("❌ Ultra Instant Reel dihentikan")
    end
    
    -- STATUS CHECK
    function UltraSystem:Status()
        local flags = _G.UltraInstantReel.GetFlags()
        print("📊 ULTRA INSTANT REEL STATUS:")
        print("   Active: " .. tostring(flags.ultrainstantreel))
        print("   Multi-fire: " .. tostring(flags.ultrainstantmultifire) .. "x")
        print("   Predictive: " .. tostring(flags.ultrainstantpredictive))
        print("   Bypass All: " .. tostring(flags.ultrainstantbypassall))
    end
    
    -- PROFILE SWITCHER  
    function UltraSystem:SwitchProfile(profileName)
        print("🔄 Switching to profile: " .. profileName)
        self:Stop()
        task.wait(0.5)
        self:CustomStart(profileName)
    end
    
    -- EXTREME MODE (PALING INSTAN)
    function UltraSystem:ExtremeMode()
        print("💥 EXTREME MODE ACTIVATED!")
        _G.UltraInstantConfig:SetCustom({
            PredictiveThreshold = 70, -- Catch pada 70%
            DefaultFireCount = 30, -- 30x fire events
            MonitoringFrequency = 0.001, -- Check setiap 1ms
            AnimationBlockFrequency = 0.001, -- Block setiap 1ms
        })
        _G.UltraInstantReel.MaxSpeed()
        print("⚠️ WARNING: Extreme mode - paling cepat tapi mungkin tidak stabil!")
    end
    
    -- SAFE MODE
    function UltraSystem:SafeMode()
        print("🛡️ SAFE MODE ACTIVATED!")
        self:CustomStart("Safe")
    end
    
    -- BALANCED MODE
    function UltraSystem:BalancedMode()
        print("⚖️ BALANCED MODE ACTIVATED!")
        self:CustomStart("Balanced")
    end
    
    -- Export to global
    _G.UltraInstant = UltraSystem
    
    print("✅ Ultra Instant Reel System fully loaded!")
    print("")
    print("🎮 QUICK COMMANDS:")
    print("   _G.UltraInstant:QuickStart() - Start dengan pengaturan maksimal")
    print("   _G.UltraInstant:ExtremeMode() - Mode paling ekstrem (70% threshold)")
    print("   _G.UltraInstant:BalancedMode() - Mode balanced")
    print("   _G.UltraInstant:SafeMode() - Mode aman")
    print("   _G.UltraInstant:Stop() - Stop system")
    print("   _G.UltraInstant:Status() - Cek status")
    print("")
    print("🚀 Ready to use! Jalankan _G.UltraInstant:QuickStart() untuk mulai!")
    
else
    warn("❌ Gagal load Ultra Instant Reel System!")
end