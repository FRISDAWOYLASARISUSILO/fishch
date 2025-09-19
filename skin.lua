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

-- Skin Crate Purchase Data (based on actual game structure)
local SkinCrateData = {
    ["Moosewood"] = {
        price = 100, -- adjust prices based on actual game
        currency = "C$",
        id = "Moosewood"
    },
    ["Desolate"] = {
        price = 150,
        currency = "C$",
        id = "Desolate"
    },
    ["Cthulu"] = {
        price = 300,
        currency = "C$",
        id = "Cthulu"
    },
    ["Ancient"] = {
        price = 500,
        currency = "C$",
        id = "Ancient"
    },
    ["Mariana's"] = {
        price = 400,
        currency = "C$",
        id = "Mariana's"
    },
    ["Cosmetic Case"] = {
        price = 75,
        currency = "C$",
        id = "Cosmetic Case"
    },
    ["Cosmetic Case Legendary"] = {
        price = 250,
        currency = "C$",
        id = "Cosmetic Case Legendary"
    },
    ["Atlantis"] = {
        price = 600,
        currency = "C$",
        id = "Atlantis"
    },
    ["Cursed"] = {
        price = 350,
        currency = "C$",
        id = "Cursed"
    },
    ["Cultist"] = {
        price = 275,
        currency = "C$",
        id = "Cultist"
    },
    ["Coral"] = {
        price = 125,
        currency = "C$",
        id = "Coral"
    },
    ["Friendly"] = {
        price = 80,
        currency = "C$",
        id = "Friendly"
    },
    ["Red Marlins"] = {
        price = 200,
        currency = "C$",
        id = "Red Marlins"
    },
    ["Midas' Mates"] = {
        price = 450,
        currency = "C$",
        id = "Midas' Mates"
    },
    ["Ghosts"] = {
        price = 300,
        currency = "C$",
        id = "Ghosts"
    }
}

-- Purchase Statistics
local purchaseStats = {
    totalPurchases = 0,
    successfulPurchases = 0,
    failedPurchases = 0,
    totalSpent = 0,
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
        local totalCost = crateData.price * quantity
        local currentCurrency = getPlayerCurrency()
        
        print("💰 [SKIN CRATE] Cost: " .. totalCost .. " " .. crateData.currency .. " | Current: " .. currentCurrency)
        
        if currentCurrency < totalCost then
            warn("💰 [SKIN CRATE] Insufficient funds! Need: " .. totalCost .. " " .. crateData.currency)
            return false
        end
        
        -- Get the correct Net package structure
        local netPackage = ReplicatedStorage:WaitForChild("packages"):WaitForChild("Net")
        local purchaseRemote = netPackage:WaitForChild("RF"):WaitForChild("SkinCrates"):WaitForChild("Purchase")
        
        if purchaseRemote then
            print("🔍 [SKIN CRATE] Found purchase remote: " .. purchaseRemote:GetFullName())
            
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
                    purchaseStats.totalSpent = purchaseStats.totalSpent + totalCost
                    success = true
                    break
                else
                    print("⚠️ [SKIN CRATE] Pattern " .. i .. " failed: " .. tostring(result))
                end
            end
        else
            warn("❌ [SKIN CRATE] Could not find SkinCrates Purchase remote!")
            
            -- Fallback: Try to find alternative remotes
            print("🔍 [SKIN CRATE] Searching for alternative remotes...")
            local function searchRemotes(parent, depth)
                if depth > 3 then return end
                for _, child in pairs(parent:GetChildren()) do
                    if child.Name:lower():find("purchase") or child.Name:lower():find("buy") or child.Name:lower():find("crate") then
                        print("🔍 [SKIN CRATE] Found potential remote: " .. child:GetFullName())
                    end
                    if child:GetChildren() and #child:GetChildren() > 0 then
                        searchRemotes(child, depth + 1)
                    end
                end
            end
            searchRemotes(netPackage, 0)
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
    print("💰 Total Spent: " .. purchaseStats.totalSpent)
    print("📈 Success Rate: " .. math.floor((purchaseStats.successfulPurchases / math.max(purchaseStats.totalPurchases, 1)) * 100) .. "%")
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
        local crateData = SkinCrateData[crateName]
        print(string.format("%2d. %-25s | %s%d %s", 
            i, crateName, "", crateData.price, crateData.currency))
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
    local crateData = SkinCrateData[selectedCrate]
    if crateData then
        print("🎁 [SKIN CRATE] Selected: " .. selectedCrate .. " (Price: " .. crateData.price .. " " .. crateData.currency .. ")")
    end
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
    StatsSection:NewLabel("💰 Total Spent: " .. purchaseStats.totalSpent .. " C$")
    StatsSection:NewLabel("📈 Success Rate: " .. math.floor((purchaseStats.successfulPurchases / math.max(purchaseStats.totalPurchases, 1)) * 100) .. "%")
    StatsSection:NewLabel("🔄 Current Session: " .. purchaseStats.currentSession)
end

-- Reset Stats Button
StatsSection:NewButton("🔄 Reset Statistics", "Reset all purchase statistics", function()
    purchaseStats = {
        totalPurchases = 0,
        successfulPurchases = 0,
        failedPurchases = 0,
        totalSpent = 0,
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
    local crateData = SkinCrateData[crateName]
    InfoSection:NewLabel(string.format("%-20s | %d %s", crateName, crateData.price, crateData.currency))
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
