--// AUTO SKIN CRATE BUYER SCRIPT
--// Created for purchasing skin crates without going to location
--// Supports all available skin crates with quantity selection
--// UI Library: Kavo UI from GitHub

--// Load Kavo UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/FRISDAWOYLASARISUSILO/fishch/refs/heads/main/kavo.lua"))()

--// Services
local Players = cloneref(game:GetService('Players'))
local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local RunService = cloneref(game:GetService('RunService'))
local MarketplaceService = cloneref(game:GetService('MarketplaceService'))

--// Variables
local lp = Players.LocalPlayer
local flags = {}

-- Auto Skin Crate Settings
flags['autoskincrate'] = false
flags['selectedcrate'] = "Moosewood"
flags['cratequantity'] = 1
flags['autobuydelay'] = 1 -- delay between purchases in seconds
flags['stoponfail'] = true -- stop if purchase fails
flags['maxpurchases'] = 10 -- maximum purchases per session

-- Available Skin Crates List (based on your data.txt)
local SkinCratesList = {
    "Moosewood",
    "Desolate", 
    "Cthulu",
    "Ancient",
    "Mariana's",
    "Cosmetic Case",
    "Cosmetic Case Legendary",
    "Atlantis",
    "Cursed",
    "Cultist",
    "Coral",
    "Friendly",
    "Red Marlins",
    "Midas' Mates",
    "Ghosts"
}

-- Skin Crate Purchase Data (let game handle pricing)
local SkinCrateData = {
    ["Moosewood"] = {
        id = "Moosewood"
    },
    ["Desolate"] = {
        id = "Desolate"
    },
    ["Cthulu"] = {
        id = "Cthulu"
    },
    ["Ancient"] = {
        id = "Ancient"
    },
    ["Mariana's"] = {
        id = "Mariana's"
    },
    ["Cosmetic Case"] = {
        id = "Cosmetic Case"
    },
    ["Cosmetic Case Legendary"] = {
        id = "Cosmetic Case Legendary"
    },
    ["Atlantis"] = {
        id = "Atlantis"
    },
    ["Cursed"] = {
        id = "Cursed"
    },
    ["Cultist"] = {
        id = "Cultist"
    },
    ["Coral"] = {
        id = "Coral"
    },
    ["Friendly"] = {
        id = "Friendly"
    },
    ["Red Marlins"] = {
        id = "Red Marlins"
    },
    ["Midas' Mates"] = {
        id = "Midas' Mates"
    },
    ["Ghosts"] = {
        id = "Ghosts"
    }
}

-- Purchase Statistics
local purchaseStats = {
    totalPurchases = 0,
    successfulPurchases = 0,
    failedPurchases = 0,
    currentSession = 0
}

-- Auto Purchase System
local autoPurchaseActive = false
local purchaseConnection = nil

-- Function to get player's currency (you may need to adjust based on actual game structure)
local function getPlayerCurrency()
    pcall(function()
        local playerData = lp:FindFirstChild("Data") or lp:FindFirstChild("leaderstats")
        if playerData then
            local currency = playerData:FindFirstChild("C$") or playerData:FindFirstChild("Cash") or playerData:FindFirstChild("Coins")
            if currency then
                return currency.Value
            end
        end
    end)
    return 0
end

-- Function to find purchase remote (improved search)
local function findPurchaseRemote()
    local possiblePaths = {
        -- Original path from data.txt
        function() 
            local packages = ReplicatedStorage:FindFirstChild("packages")
            if packages then
                local net = packages:FindFirstChild("Net")
                if net then
                    local rf = net:FindFirstChild("RF")
                    if rf then
                        local skinCrates = rf:FindFirstChild("SkinCrates")
                        if skinCrates then
                            return skinCrates:FindFirstChild("Purchase")
                        end
                    end
                end
            end
        end,
        
        -- Alternative paths
        function()
            return ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("SkinCratePurchase")
        end,
        
        function()
            return ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("PurchaseSkinCrate")
        end,
        
        function()
            local events = ReplicatedStorage:FindFirstChild("Events")
            if events then
                return events:FindFirstChild("BuyCrate") or events:FindFirstChild("Purchase") or events:FindFirstChild("SkinCrate")
            end
        end,
        
        function()
            -- Search for any remote with skin/crate in name
            for _, child in pairs(ReplicatedStorage:GetDescendants()) do
                if (child.ClassName == "RemoteFunction" or child.ClassName == "RemoteEvent") then
                    local name = child.Name:lower()
                    if (name:find("skin") and name:find("crate")) or 
                       (name:find("crate") and name:find("buy")) or
                       (name:find("crate") and name:find("purchase")) then
                        print("🔍 [SKIN CRATE] Found potential remote: " .. child:GetFullName())
                        return child
                    end
                end
            end
        end
    }
    
    for i, pathFunc in pairs(possiblePaths) do
        local remote = pathFunc()
        if remote then
            print("✅ [SKIN CRATE] Found purchase remote via path " .. i .. ": " .. remote:GetFullName())
            return remote
        end
    end
    
    return nil
end

-- Function to purchase skin crate
local function purchaseSkinCrate(crateName, quantity)
    local success = false
    local crateData = SkinCrateData[crateName]
    
    if not crateData then
        warn("⚠️ [SKIN CRATE] Unknown crate: " .. crateName)
        return false
    end
    
    print("🛒 [SKIN CRATE] Attempting to purchase " .. quantity .. "x " .. crateName)
    
    pcall(function()
        
        -- Use improved remote search function
        local purchaseRemote = findPurchaseRemote()
        
        if purchaseRemote then
            
            -- Try different purchase patterns based on actual game structure
            local purchasePatterns = {
                -- Pattern 1: Direct crate name and quantity
                function() 
                    local result = purchaseRemote:InvokeServer(crateName, quantity)
                    print("📡 [SKIN CRATE] Pattern 1 result: " .. tostring(result))
                    return result
                end,
                
                -- Pattern 2: Crate ID and quantity
                function() 
                    local result = purchaseRemote:InvokeServer(crateData.id, quantity)
                    print("📡 [SKIN CRATE] Pattern 2 result: " .. tostring(result))
                    return result
                end,
                
                -- Pattern 3: Table format
                function() 
                    local result = purchaseRemote:InvokeServer({
                        crate = crateName,
                        quantity = quantity
                    })
                    print("📡 [SKIN CRATE] Pattern 3 result: " .. tostring(result))
                    return result
                end,
                
                -- Pattern 4: With currency type
                function() 
                    local result = purchaseRemote:InvokeServer(crateName, quantity, crateData.currency)
                    print("📡 [SKIN CRATE] Pattern 4 result: " .. tostring(result))
                    return result
                end,
                
                -- Pattern 5: Individual purchases (if bulk not supported)
                function()
                    local results = {}
                    for i = 1, quantity do
                        local result = purchaseRemote:InvokeServer(crateName, 1)
                        table.insert(results, result)
                        if not result then break end
                        task.wait(0.1) -- Small delay between individual purchases
                    end
                    print("📡 [SKIN CRATE] Pattern 5 results: " .. #results .. " successful")
                    return #results > 0
                end
            }
            
            for i, pattern in pairs(purchasePatterns) do
                local patternSuccess, result = pcall(pattern)
                if patternSuccess and result then
                    print("✅ [SKIN CRATE] Purchase successful using pattern " .. i .. ": " .. quantity .. "x " .. crateName)
                    purchaseStats.successfulPurchases = purchaseStats.successfulPurchases + 1
                    -- Game will handle the currency deduction
                    success = true
                    break
                else
                    print("⚠️ [SKIN CRATE] Pattern " .. i .. " failed: " .. tostring(result))
                end
            end
        else
            warn("❌ [SKIN CRATE] Could not find any SkinCrate purchase remote!")
            print("🔍 [SKIN CRATE] Please check that you're in the correct game")
            print("🔍 [SKIN CRATE] Try using 'Debug Remote Structure' button to see available remotes")
        end
    end)
    
    if not success then
        purchaseStats.failedPurchases = purchaseStats.failedPurchases + 1
        warn("❌ [SKIN CRATE] Purchase failed for: " .. crateName)
    end
    
    purchaseStats.totalPurchases = purchaseStats.totalPurchases + 1
    return success
end

-- Auto Purchase Loop
local function startAutoPurchase()
    if autoPurchaseActive then
        warn("⚠️ [SKIN CRATE] Auto purchase already running!")
        return
    end
    
    autoPurchaseActive = true
    purchaseStats.currentSession = 0
    
    print("🚀 [SKIN CRATE] Starting auto purchase...")
    print("📦 Crate: " .. flags['selectedcrate'])
    print("🔢 Quantity per purchase: " .. flags['cratequantity'])
    print("⏱️ Delay: " .. flags['autobuydelay'] .. "s")
    print("🎯 Max purchases: " .. flags['maxpurchases'])
    
    purchaseConnection = task.spawn(function()
        while flags['autoskincrate'] and autoPurchaseActive and purchaseStats.currentSession < flags['maxpurchases'] do
            local success = purchaseSkinCrate(flags['selectedcrate'], flags['cratequantity'])
            
            if success then
                purchaseStats.currentSession = purchaseStats.currentSession + 1
                print("🎁 [SKIN CRATE] Session progress: " .. purchaseStats.currentSession .. "/" .. flags['maxpurchases'])
            else
                if flags['stoponfail'] then
                    warn("🛑 [SKIN CRATE] Purchase failed, stopping auto purchase")
                    break
                end
            end
            
            task.wait(flags['autobuydelay'])
        end
        
        autoPurchaseActive = false
        print("🏁 [SKIN CRATE] Auto purchase completed!")
        printPurchaseStats()
    end)
end

-- Stop Auto Purchase
local function stopAutoPurchase()
    flags['autoskincrate'] = false
    autoPurchaseActive = false
    
    if purchaseConnection then
        task.cancel(purchaseConnection)
        purchaseConnection = nil
    end
    
    print("🛑 [SKIN CRATE] Auto purchase stopped!")
    printPurchaseStats()
end

-- Print Purchase Statistics
function printPurchaseStats()
    print("\n📊 [SKIN CRATE STATS]")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("🎁 Total Purchases: " .. purchaseStats.totalPurchases)
    print("✅ Successful: " .. purchaseStats.successfulPurchases)
    print("❌ Failed: " .. purchaseStats.failedPurchases)
    print(" Success Rate: " .. math.floor((purchaseStats.successfulPurchases / math.max(purchaseStats.totalPurchases, 1)) * 100) .. "%")
    print("🔄 Current Session: " .. purchaseStats.currentSession)
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
end

-- Manual Purchase Function
local function buySkincrate(crateName, quantity)
    quantity = quantity or 1
    crateName = crateName or flags['selectedcrate']
    
    if not SkinCrateData[crateName] then
        warn("⚠️ [SKIN CRATE] Invalid crate name: " .. crateName)
        print("📋 Available crates:")
        for i, crate in pairs(SkinCratesList) do
            print("  " .. i .. ". " .. crate)
        end
        return
    end
    
    print("🛒 [SKIN CRATE] Purchasing " .. quantity .. "x " .. crateName .. "...")
    local success = purchaseSkinCrate(crateName, quantity)
    
    if success then
        print("✅ [SKIN CRATE] Purchase completed!")
    else
        warn("❌ [SKIN CRATE] Purchase failed!")
    end
end

-- List Available Crates
local function listSkinCrates()
    print("\n📦 [AVAILABLE SKIN CRATES]")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    for i, crateName in pairs(SkinCratesList) do
        print(string.format("%2d. %-25s | Game will handle pricing", 
            i, crateName))
    end
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
end

-- Monitor for flag changes
task.spawn(function()
    while task.wait(0.5) do
        if flags['autoskincrate'] and not autoPurchaseActive then
            startAutoPurchase()
        elseif not flags['autoskincrate'] and autoPurchaseActive then
            stopAutoPurchase()
        end
    end
end)

-- Expose functions globally for easy access
_G.buySkincrate = buySkincrate
_G.listSkinCrates = listSkinCrates
_G.printPurchaseStats = printPurchaseStats
_G.SkinCrateFlags = flags

-- Initial setup
print("🎁 [AUTO SKIN CRATE] Script loaded successfully!")
print("📋 Available commands:")
print("  • buySkincrate('CrateName', quantity) - Manual purchase")
print("  • listSkinCrates() - Show all available crates")
print("  • printPurchaseStats() - Show purchase statistics")
print("  • Set flags['autoskincrate'] = true to start auto purchase")
print("  • Set flags['selectedcrate'] = 'CrateName' to change crate")
print("  • Set flags['cratequantity'] = number to change quantity")

--// CREATE KAVO UI
local Window = Library.CreateLib("🎁 Auto Skin Crate Buyer", "Midnight")

-- Main Tab
local MainTab = Window:NewTab("🎁 Main")
local MainSection = MainTab:NewSection("Skin Crate Purchase")

-- Settings Tab
local SettingsTab = Window:NewTab("⚙️ Settings")
local SettingsSection = SettingsTab:NewSection("Purchase Settings")

-- Stats Tab
local StatsTab = Window:NewTab("📊 Statistics")
local StatsSection = StatsTab:NewSection("Purchase Statistics")

--// MAIN TAB ELEMENTS

-- Crate Selection Dropdown
MainSection:NewDropdown("Select Skin Crate", "Choose which crate to purchase", SkinCratesList, function(selectedCrate)
    flags['selectedcrate'] = selectedCrate
    print("🎁 [SKIN CRATE] Selected: " .. selectedCrate .. " (Game will handle pricing)")
end)

-- Quantity Slider
MainSection:NewSlider("Purchase Quantity", "How many crates to buy per purchase", 10, 1, function(value)
    flags['cratequantity'] = value
    print("🔢 [SKIN CRATE] Quantity set to: " .. value)
end)

-- Manual Buy Button
MainSection:NewButton("💰 Buy Selected Crate", "Purchase the selected crate manually", function()
    buySkincrate(flags['selectedcrate'], flags['cratequantity'])
end)

-- Auto Purchase Toggle
MainSection:NewToggle("🔄 Auto Purchase", "Enable/disable automatic purchasing", function(state)
    flags['autoskincrate'] = state
    if state then
        print("🚀 [SKIN CRATE] Auto purchase enabled!")
    else
        print("🛑 [SKIN CRATE] Auto purchase disabled!")
    end
end)

-- Quick Buy Buttons
MainSection:NewButton("⚡ Quick Buy x1", "Instantly buy 1 selected crate", function()
    buySkincrate(flags['selectedcrate'], 1)
end)

MainSection:NewButton("⚡ Quick Buy x5", "Instantly buy 5 selected crates", function()
    buySkincrate(flags['selectedcrate'], 5)
end)

MainSection:NewButton("⚡ Quick Buy x10", "Instantly buy 10 selected crates", function()
    buySkincrate(flags['selectedcrate'], 10)
end)

--// SETTINGS TAB ELEMENTS

-- Purchase Delay Slider
SettingsSection:NewSlider("Purchase Delay (seconds)", "Delay between auto purchases", 10, 0, function(value)
    flags['autobuydelay'] = value
    print("⏱️ [SKIN CRATE] Delay set to: " .. value .. "s")
end)

-- Max Purchases Slider
SettingsSection:NewSlider("Max Purchases per Session", "Maximum purchases in one auto session", 100, 1, function(value)
    flags['maxpurchases'] = value
    print("🎯 [SKIN CRATE] Max purchases set to: " .. value)
end)

-- Stop on Fail Toggle
SettingsSection:NewToggle("🛑 Stop on Purchase Fail", "Stop auto purchase if a purchase fails", function(state)
    flags['stoponfail'] = state
    print("🛑 [SKIN CRATE] Stop on fail: " .. tostring(state))
end)

-- Currency Display
SettingsSection:NewLabel("💰 Current Currency: Loading...")

-- Update currency display
task.spawn(function()
    while task.wait(2) do
        local currency = getPlayerCurrency()
        pcall(function()
            SettingsSection:NewLabel("💰 Current Currency: " .. currency .. " C$")
        end)
    end
end)

--// POPULAR CRATES SECTION
local PopularSection = MainTab:NewSection("🔥 Popular Crates")

-- Quick access to popular crates
PopularSection:NewButton("🏰 Ancient Crate", "Quick buy Ancient crate", function()
    flags['selectedcrate'] = "Ancient"
    buySkincrate("Ancient", flags['cratequantity'])
end)

PopularSection:NewButton("🌊 Atlantis Crate", "Quick buy Atlantis crate", function()
    flags['selectedcrate'] = "Atlantis"
    buySkincrate("Atlantis", flags['cratequantity'])
end)

PopularSection:NewButton("👻 Cursed Crate", "Quick buy Cursed crate", function()
    flags['selectedcrate'] = "Cursed"
    buySkincrate("Cursed", flags['cratequantity'])
end)

PopularSection:NewButton("💎 Midas' Mates Crate", "Quick buy Midas' Mates crate", function()
    flags['selectedcrate'] = "Midas' Mates"
    buySkincrate("Midas' Mates", flags['cratequantity'])
end)

--// STATS TAB ELEMENTS

-- Statistics Display
local function updateStatsDisplay()
    StatsSection:NewLabel("📊 PURCHASE STATISTICS")
    StatsSection:NewLabel("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    StatsSection:NewLabel("🎁 Total Purchases: " .. purchaseStats.totalPurchases)
    StatsSection:NewLabel("✅ Successful: " .. purchaseStats.successfulPurchases)
    StatsSection:NewLabel("❌ Failed: " .. purchaseStats.failedPurchases)
    StatsSection:NewLabel(" Success Rate: " .. math.floor((purchaseStats.successfulPurchases / math.max(purchaseStats.totalPurchases, 1)) * 100) .. "%")
    StatsSection:NewLabel("🔄 Current Session: " .. purchaseStats.currentSession)
end

-- Reset Stats Button
StatsSection:NewButton("🔄 Reset Statistics", "Reset all purchase statistics", function()
    purchaseStats = {
        totalPurchases = 0,
        successfulPurchases = 0,
        failedPurchases = 0,
        currentSession = 0
    }
    print("🔄 [SKIN CRATE] Statistics reset!")
    updateStatsDisplay()
end)

-- Refresh Stats Button
StatsSection:NewButton("📊 Refresh Statistics", "Refresh the statistics display", function()
    updateStatsDisplay()
end)

--// CRATE INFO SECTION
local InfoTab = Window:NewTab("ℹ️ Crate Info")
local InfoSection = InfoTab:NewSection("Crate Information")

-- Display all crate info
InfoSection:NewLabel("📦 AVAILABLE SKIN CRATES")
InfoSection:NewLabel("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

for i, crateName in pairs(SkinCratesList) do
    InfoSection:NewLabel(string.format("%-20s | Game will handle pricing", crateName))
end

-- Quick List Button
InfoSection:NewButton("📋 Print Crate List to Console", "Print all crates to console", function()
    listSkinCrates()
end)

--// UTILITY SECTION
local UtilityTab = Window:NewTab("🔧 Utilities")
local UtilitySection = UtilityTab:NewSection("Utility Functions")

-- Utility Buttons
UtilitySection:NewButton("📊 Print Stats to Console", "Print detailed stats to console", function()
    printPurchaseStats()
end)

UtilitySection:NewButton("� Debug Remote Structure", "Check SkinCrate remote structure", function()
    print("\n🔍 [DEBUG] Checking SkinCrate remote structure...")
    pcall(function()
        local netPackage = ReplicatedStorage:FindFirstChild("packages")
        if netPackage then
            print("✅ Found packages folder")
            local net = netPackage:FindFirstChild("Net")
            if net then
                print("✅ Found Net folder")
                local rf = net:FindFirstChild("RF")
                if rf then
                    print("✅ Found RF folder")
                    local skinCrates = rf:FindFirstChild("SkinCrates")
                    if skinCrates then
                        print("✅ Found SkinCrates folder")
                        for _, remote in pairs(skinCrates:GetChildren()) do
                            print("  📡 Remote: " .. remote.Name .. " (" .. remote.ClassName .. ")")
                        end
                    else
                        print("❌ SkinCrates folder not found in RF")
                        print("Available RF children:")
                        for _, child in pairs(rf:GetChildren()) do
                            print("  📁 " .. child.Name)
                        end
                    end
                else
                    print("❌ RF folder not found")
                end
            else
                print("❌ Net folder not found")
            end
        else
            print("❌ packages folder not found")
            print("Available ReplicatedStorage children:")
            for _, child in pairs(ReplicatedStorage:GetChildren()) do
                if child.Name:lower():find("net") or child.Name:lower():find("remote") or child.Name:lower():find("package") then
                    print("  📁 " .. child.Name .. " (" .. child.ClassName .. ")")
                end
            end
        end
    end)
end)

UtilitySection:NewButton("🧪 Test Purchase (Single)", "Test purchase 1 selected crate", function()
    print("🧪 [TEST] Testing single purchase of " .. flags['selectedcrate'])
    local result = purchaseSkinCrate(flags['selectedcrate'], 1)
    if result then
        print("✅ [TEST] Purchase test successful!")
    else
        print("❌ [TEST] Purchase test failed!")
    end
end)

UtilitySection:NewButton("�🛑 Emergency Stop", "Stop all auto purchase immediately", function()
    flags['autoskincrate'] = false
    stopAutoPurchase()
    print("🛑 [SKIN CRATE] Emergency stop activated!")
end)

UtilitySection:NewButton("🔄 Restart Auto Purchase", "Restart the auto purchase system", function()
    stopAutoPurchase()
    task.wait(1)
    flags['autoskincrate'] = true
    print("🔄 [SKIN CRATE] Auto purchase restarted!")
end)

-- Initial stats display
updateStatsDisplay()

-- Show initial crate list in console
listSkinCrates()

print("🎁 [AUTO SKIN CRATE UI] Successfully loaded with Kavo UI!")
print("📋 Use the GUI to interact with the skin crate buyer!")

return {
    flags = flags,
    buySkincrate = buySkincrate,
    listSkinCrates = listSkinCrates,
    printPurchaseStats = printPurchaseStats,
    SkinCratesList = SkinCratesList,
    SkinCrateData = SkinCrateData,
    Window = Window
}
