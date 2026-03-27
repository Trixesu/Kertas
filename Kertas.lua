repeat task.wait() until game:IsLoaded()

-- UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Kertas Hub",
    LoadingTitle = "Kertas Hub",
    LoadingSubtitle = "Script is loading...",
    ConfigurationSaving = {Enabled = false}
})

-- SERVICES
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")

-- CHARACTER
local function GetHRP()
    local Character = Player.Character or Player.CharacterAdded:Wait()
    return Character:WaitForChild("HumanoidRootPart")
end

local function GetHumanoid()
    local Character = Player.Character or Player.CharacterAdded:Wait()
    return Character:WaitForChild("Humanoid")
end

local HRP = GetHRP()
local Humanoid = GetHumanoid()

Player.CharacterAdded:Connect(function()
    HRP = GetHRP()
    Humanoid = GetHumanoid()
end)

-- CONFIG FILE
local FileName = "TeleportCoords.json"
local SavedCoords = {}

if isfile(FileName) then
    SavedCoords = HttpService:JSONDecode(readfile(FileName))
end

local function SaveFile()
    writefile(FileName, HttpService:JSONEncode(SavedCoords))
end

-- VARIABLES
local Selected = nil
local Spam = false
local FastTP = false
local Delay = 1

-- BHOP VARIABLES
local Bhop = false
local HoldingSpace = false

-- ANTI AFK
local VirtualUser = game:GetService("VirtualUser")
Player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

-- UI TAB
local Tab = Window:CreateTab("Teleport",4483362458)

-- DROPDOWN
local Dropdown = Tab:CreateDropdown({
    Name = "Saved Coordinates",
    Options = {},
    CurrentOption = nil,
    Callback = function(Value)
        if type(Value) == "table" then
            Selected = Value[1]
        else
            Selected = Value
        end
    end
})

local function Refresh()
    local list = {}

    for name,_ in pairs(SavedCoords) do
        table.insert(list,name)
    end

    Dropdown:Refresh(list)
end

Refresh()

-- INPUT
local coordName = ""

Tab:CreateInput({
    Name = "Coordinate Name",
    PlaceholderText = "Enter name",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        coordName = Text
    end
})

-- SAVE
Tab:CreateButton({
    Name = "Save Current Coordinate",
    Callback = function()
        SavedCoords[coordName] = {
            x = HRP.Position.X,
            y = HRP.Position.Y,
            z = HRP.Position.Z
        }

        SaveFile()
        Refresh()

        Rayfield:Notify({
            Title = "Saved",
            Content = coordName.." saved permanently",
            Duration = 3
        })
    end
})

-- TELEPORT
Tab:CreateButton({
    Name = "Teleport",
    Callback = function()
        if Selected and SavedCoords[Selected] then
            local pos = SavedCoords[Selected]
            HRP.CFrame = CFrame.new(pos.x,pos.y,pos.z)
        end
    end
})

-- DELETE
Tab:CreateButton({
    Name = "Delete Coordinate",
    Callback = function()
        SavedCoords[Selected] = nil
        SaveFile()
        Refresh()
    end
})

-- TOGGLES
Tab:CreateToggle({
    Name = "Spam Teleport",
    CurrentValue = false,
    Callback = function(Value)
        Spam = Value
    end
})

Tab:CreateToggle({
    Name = "Fast Teleport (0.1s)",
    CurrentValue = false,
    Callback = function(Value)
        FastTP = Value
    end
})

Tab:CreateToggle({
    Name = "Auto Bhop",
    CurrentValue = false,
    Callback = function(Value)
        Bhop = Value
    end
})

-- SLIDER
Tab:CreateSlider({
    Name = "Spam Delay",
    Range = {0.1,5},
    Increment = 0.1,
    CurrentValue = 1,
    Callback = function(Value)
        Delay = Value
    end
})

-- INPUT DETECTION (SPACE)
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Space then
        HoldingSpace = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        HoldingSpace = false
    end
end)

-- SPAM LOOP
task.spawn(function()
    while true do
        if Spam and Selected and SavedCoords[Selected] then
            local pos = SavedCoords[Selected]
            HRP.CFrame = CFrame.new(pos.x,pos.y,pos.z)
            task.wait(Delay)
        else
            task.wait(0.1)
        end
    end
end)

-- FAST LOOP
task.spawn(function()
    while true do
        if FastTP and Selected and SavedCoords[Selected] then
            local pos = SavedCoords[Selected]
            HRP.CFrame = CFrame.new(pos.x,pos.y,pos.z)
            task.wait(0.1)
        else
            task.wait(0.1)
        end
    end
end)

-- BHOP LOOP
task.spawn(function()
    while true do
        if Bhop and HoldingSpace and Humanoid then
            if Humanoid.FloorMaterial ~= Enum.Material.Air then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
        task.wait(0.01)
    end
end)
