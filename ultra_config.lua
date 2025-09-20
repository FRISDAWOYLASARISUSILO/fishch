--// ULTRA INSTANT REEL - ADVANCED CONFIG
--// Pengaturan advanced untuk ultra instant reel

local UltraConfig = {
    -- TIMING SETTINGS
    PredictiveThreshold = 80, -- Catch pada 80% lure (lebih cepat dari 95%)
    MonitoringFrequency = 0.01, -- Check setiap 10ms (super fast)
    AnimationBlockFrequency = 0.005, -- Block animation setiap 5ms
    
    -- FIRE RATE SETTINGS
    MinFireCount = 5, -- Minimum fire events
    MaxFireCount = 25, -- Maximum fire events
    DefaultFireCount = 15, -- Default fire count
    
    -- BYPASS SETTINGS
    BypassGUIs = {"reel", "shakeui", "fish", "catch", "progress", "minigame", "fishing", "bobber"},
    BypassAnimations = {
        "fish", "reel", "cast", "rod", "catch", "lift", "pull", "bobber", 
        "yank", "shake", "struggle", "throw", "swing", "wave"
    },
    
    -- EXTREME OPTIMIZATION
    UseMultipleConnections = true, -- Gunakan multiple RunService connections
    UsePreFireSystem = true, -- Pre-fire events untuk instant response
    UseAggressiveBlocking = true, -- Aggressive animation blocking
    UsePredictiveSystem = true, -- Predictive catch system
    
    -- SAFETY SETTINGS
    MaxConnectionRetries = 3,
    ErrorRecoveryDelay = 0.1,
    SafetyChecks = false, -- Disable untuk maksimal speed
    
    -- DEBUG SETTINGS
    DebugMode = false,
    ShowCatchMessages = true,
    ShowPerformanceStats = false,
}

-- PERFORMANCE PROFILES
UltraConfig.Profiles = {
    ["Maximum"] = {
        PredictiveThreshold = 75,
        DefaultFireCount = 25,
        MonitoringFrequency = 0.005,
        AnimationBlockFrequency = 0.001,
        UseMultipleConnections = true,
        UsePreFireSystem = true,
        UseAggressiveBlocking = true,
        SafetyChecks = false,
    },
    
    ["Balanced"] = {
        PredictiveThreshold = 85,
        DefaultFireCount = 15,
        MonitoringFrequency = 0.01,
        AnimationBlockFrequency = 0.01,
        UseMultipleConnections = true,
        UsePreFireSystem = true,
        UseAggressiveBlocking = true,
        SafetyChecks = false,
    },
    
    ["Safe"] = {
        PredictiveThreshold = 90,
        DefaultFireCount = 10,
        MonitoringFrequency = 0.02,
        AnimationBlockFrequency = 0.02,
        UseMultipleConnections = false,
        UsePreFireSystem = false,
        UseAggressiveBlocking = false,
        SafetyChecks = true,
    }
}

-- LOAD PROFILE FUNCTION
function UltraConfig:LoadProfile(profileName)
    local profile = self.Profiles[profileName]
    if not profile then
        warn("Profile tidak ditemukan: " .. tostring(profileName))
        return false
    end
    
    for key, value in pairs(profile) do
        self[key] = value
    end
    
    print("🔧 Profile loaded: " .. profileName)
    return true
end

-- CUSTOM SETTINGS FUNCTION
function UltraConfig:SetCustom(settings)
    for key, value in pairs(settings) do
        self[key] = value
    end
    print("⚙️ Custom settings applied")
end

-- GET OPTIMIZED SETTINGS
function UltraConfig:GetOptimized()
    return {
        threshold = self.PredictiveThreshold,
        fireCount = self.DefaultFireCount,
        monitoring = self.MonitoringFrequency,
        blocking = self.AnimationBlockFrequency,
        multiConnection = self.UseMultipleConnections,
        preFire = self.UsePreFireSystem,
        aggressive = self.UseAggressiveBlocking,
        predictive = self.UsePredictiveSystem,
    }
end

-- EXPORT
_G.UltraInstantConfig = UltraConfig

print("⚙️ Ultra Instant Reel Config Loaded!")
print("💡 Profiles: Maximum, Balanced, Safe")
print("💡 Usage: _G.UltraInstantConfig:LoadProfile('Maximum')")

return UltraConfig