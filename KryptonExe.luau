--[[
    Krypton Exe v2.0 - Advanced Script-Based Roblox Executor UI
    Features: Scrolling Editor, Tab Management, Auto-Save, Enhanced Detection
    Created for use inside existing Roblox executors
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer

-- File System Detection
local hasFileSystem = pcall(function()
    return writefile and readfile and isfolder and makefolder and listfiles
end)

-- Auto-Save Configuration
local SAVE_FOLDER = "KryptonExe"
local SAVE_FILE = SAVE_FOLDER .. "/workspace.json"

-- Clean up existing instances
if CoreGui:FindFirstChild("KryptonExeUI") then
    CoreGui:FindFirstChild("KryptonExeUI"):Destroy()
end

-- Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KryptonExeUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 850, 0, 550)
MainFrame.Position = UDim2.new(0.5, -425, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Drop Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.Position = UDim2.new(0, -15, 0, -15)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxasset://textures/ui/Chat/ChatInputBarBackground.png"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(8, 8, 8, 8)
Shadow.ZIndex = 0
Shadow.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

local TopBarFix = Instance.new("Frame")
TopBarFix.Size = UDim2.new(1, 0, 0, 10)
TopBarFix.Position = UDim2.new(0, 0, 1, -10)
TopBarFix.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TopBarFix.BorderSizePixel = 0
TopBarFix.Parent = TopBar

-- Logo
local Logo = Instance.new("ImageLabel")
Logo.Name = "Logo"
Logo.Size = UDim2.new(0, 30, 0, 30)
Logo.Position = UDim2.new(0, 10, 0.5, -15)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://81774885922568"
Logo.Parent = TopBar

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 50, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "Krypton Exe v2.0"
Title.TextColor3 = Color3.fromRGB(147, 112, 219)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -45, 0.5, -20)
CloseButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Minimize Button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 40, 0, 40)
MinimizeButton.Position = UDim2.new(1, -90, 0.5, -20)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "−"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 18
MinimizeButton.Parent = TopBar

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 8)
MinimizeCorner.Parent = MinimizeButton

-- Content Container (holds everything below TopBar)
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, 0, 1, -50)
ContentContainer.Position = UDim2.new(0, 0, 0, 50)
ContentContainer.BackgroundTransparency = 1
ContentContainer.BorderSizePixel = 0
ContentContainer.Parent = MainFrame

-- Left Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 200, 1, 0)
Sidebar.Position = UDim2.new(0, 0, 0, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = ContentContainer

-- Tab Storage
local TabData = {}
local CurrentTab = 1
local TabCounter = 0

-- Tabs Section
local TabsSection = Instance.new("Frame")
TabsSection.Name = "TabsSection"
TabsSection.Size = UDim2.new(1, 0, 0, 180)
TabsSection.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TabsSection.BorderSizePixel = 0
TabsSection.Parent = Sidebar

local TabsHeader = Instance.new("Frame")
TabsHeader.Name = "TabsHeader"
TabsHeader.Size = UDim2.new(1, -20, 0, 30)
TabsHeader.Position = UDim2.new(0, 10, 0, 5)
TabsHeader.BackgroundTransparency = 1
TabsHeader.Parent = TabsSection

local TabsTitle = Instance.new("TextLabel")
TabsTitle.Size = UDim2.new(1, -35, 1, 0)
TabsTitle.BackgroundTransparency = 1
TabsTitle.Font = Enum.Font.GothamBold
TabsTitle.Text = "Editor Tabs"
TabsTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
TabsTitle.TextSize = 14
TabsTitle.TextXAlignment = Enum.TextXAlignment.Left
TabsTitle.Parent = TabsHeader

-- Add Tab Button
local AddTabButton = Instance.new("TextButton")
AddTabButton.Name = "AddTabButton"
AddTabButton.Size = UDim2.new(0, 30, 0, 25)
AddTabButton.Position = UDim2.new(1, -30, 0, 2.5)
AddTabButton.BackgroundColor3 = Color3.fromRGB(147, 112, 219)
AddTabButton.Font = Enum.Font.GothamBold
AddTabButton.Text = "+"
AddTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AddTabButton.TextSize = 18
AddTabButton.Parent = TabsHeader

local AddTabCorner = Instance.new("UICorner")
AddTabCorner.CornerRadius = UDim.new(0, 6)
AddTabCorner.Parent = AddTabButton

local TabsContainer = Instance.new("ScrollingFrame")
TabsContainer.Name = "TabsContainer"
TabsContainer.Size = UDim2.new(1, -20, 1, -40)
TabsContainer.Position = UDim2.new(0, 10, 0, 35)
TabsContainer.BackgroundTransparency = 1
TabsContainer.BorderSizePixel = 0
TabsContainer.ScrollBarThickness = 4
TabsContainer.ScrollBarImageColor3 = Color3.fromRGB(147, 112, 219)
TabsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
TabsContainer.Parent = TabsSection

local TabsList = Instance.new("UIListLayout")
TabsList.SortOrder = Enum.SortOrder.LayoutOrder
TabsList.Padding = UDim.new(0, 5)
TabsList.Parent = TabsContainer

-- Status Section
local StatusSection = Instance.new("Frame")
StatusSection.Name = "StatusSection"
StatusSection.Size = UDim2.new(1, 0, 0, 200)
StatusSection.Position = UDim2.new(0, 0, 0, 185)
StatusSection.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
StatusSection.BorderSizePixel = 0
StatusSection.Parent = Sidebar

local StatusTitle = Instance.new("TextLabel")
StatusTitle.Size = UDim2.new(1, -20, 0, 30)
StatusTitle.Position = UDim2.new(0, 10, 0, 5)
StatusTitle.BackgroundTransparency = 1
StatusTitle.Font = Enum.Font.GothamBold
StatusTitle.Text = "Status Panel"
StatusTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusTitle.TextSize = 14
StatusTitle.TextXAlignment = Enum.TextXAlignment.Left
StatusTitle.Parent = StatusSection

local StatusContainer = Instance.new("Frame")
StatusContainer.Name = "StatusContainer"
StatusContainer.Size = UDim2.new(1, -20, 1, -40)
StatusContainer.Position = UDim2.new(0, 10, 0, 35)
StatusContainer.BackgroundTransparency = 1
StatusContainer.Parent = StatusSection

local StatusList = Instance.new("UIListLayout")
StatusList.SortOrder = Enum.SortOrder.LayoutOrder
StatusList.Padding = UDim.new(0, 8)
StatusList.Parent = StatusContainer

-- Status Labels
local function CreateStatusLabel(name, order)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = name .. ": Loading..."
    label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.LayoutOrder = order
    label.Parent = StatusContainer
    return label
end

local PlayerCountLabel = CreateStatusLabel("Players", 1)
local MoonLabel = CreateStatusLabel("Moon Phase", 2)
local ExecutorLabel = CreateStatusLabel("Executor", 3)
local FPSLabel = CreateStatusLabel("FPS", 4)
local PingLabel = CreateStatusLabel("Ping", 5)

-- Executor Info Section
local ExecutorSection = Instance.new("Frame")
ExecutorSection.Name = "ExecutorSection"
ExecutorSection.Size = UDim2.new(1, 0, 0, 80)
ExecutorSection.Position = UDim2.new(0, 0, 0, 390)
ExecutorSection.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ExecutorSection.BorderSizePixel = 0
ExecutorSection.Parent = Sidebar

local ExecutorTitle = Instance.new("TextLabel")
ExecutorTitle.Size = UDim2.new(1, -20, 0, 30)
ExecutorTitle.Position = UDim2.new(0, 10, 0, 5)
ExecutorTitle.BackgroundTransparency = 1
ExecutorTitle.Font = Enum.Font.GothamBold
ExecutorTitle.Text = "Executor Info"
ExecutorTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
ExecutorTitle.TextSize = 14
ExecutorTitle.TextXAlignment = Enum.TextXAlignment.Left
ExecutorTitle.Parent = ExecutorSection

local ExecutorInfo = Instance.new("TextLabel")
ExecutorInfo.Size = UDim2.new(1, -20, 1, -35)
ExecutorInfo.Position = UDim2.new(0, 10, 0, 35)
ExecutorInfo.BackgroundTransparency = 1
ExecutorInfo.Font = Enum.Font.Gotham
ExecutorInfo.Text = "Detecting..."
ExecutorInfo.TextColor3 = Color3.fromRGB(180, 180, 180)
ExecutorInfo.TextSize = 11
ExecutorInfo.TextXAlignment = Enum.TextXAlignment.Left
ExecutorInfo.TextYAlignment = Enum.TextYAlignment.Top
ExecutorInfo.TextWrapped = true
ExecutorInfo.Parent = ExecutorSection

-- Main Editor Container
local EditorContainer = Instance.new("Frame")
EditorContainer.Name = "EditorContainer"
EditorContainer.Size = UDim2.new(0, 405, 1, -60)
EditorContainer.Position = UDim2.new(0, 205, 0, 5)
EditorContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
EditorContainer.BorderSizePixel = 0
EditorContainer.ClipsDescendants = true
EditorContainer.Parent = ContentContainer

local EditorCorner = Instance.new("UICorner")
EditorCorner.CornerRadius = UDim.new(0, 8)
EditorCorner.Parent = EditorContainer

-- Line Numbers Frame
local LineNumbers = Instance.new("ScrollingFrame")
LineNumbers.Name = "LineNumbers"
LineNumbers.Size = UDim2.new(0, 40, 1, 0)
LineNumbers.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
LineNumbers.BorderSizePixel = 0
LineNumbers.ScrollBarThickness = 0
LineNumbers.CanvasSize = UDim2.new(0, 0, 0, 0)
LineNumbers.ScrollingEnabled = false
LineNumbers.ClipsDescendants = true
LineNumbers.Parent = EditorContainer

local LineNumbersText = Instance.new("TextLabel")
LineNumbersText.Name = "LineNumbersText"
LineNumbersText.Size = UDim2.new(1, 0, 1, 0)
LineNumbersText.BackgroundTransparency = 1
LineNumbersText.Font = Enum.Font.Code
LineNumbersText.Text = "1"
LineNumbersText.TextColor3 = Color3.fromRGB(100, 100, 100)
LineNumbersText.TextSize = 14
LineNumbersText.TextXAlignment = Enum.TextXAlignment.Center
LineNumbersText.TextYAlignment = Enum.TextYAlignment.Top
LineNumbersText.Parent = LineNumbers

-- Script Editor (Scrolling)
local ScriptEditor = Instance.new("ScrollingFrame")
ScriptEditor.Name = "ScriptEditor"
ScriptEditor.Size = UDim2.new(1, -45, 1, 0)
ScriptEditor.Position = UDim2.new(0, 45, 0, 0)
ScriptEditor.BackgroundTransparency = 1
ScriptEditor.BorderSizePixel = 0
ScriptEditor.ScrollBarThickness = 6
ScriptEditor.ScrollBarImageColor3 = Color3.fromRGB(147, 112, 219)
ScriptEditor.CanvasSize = UDim2.new(0, 0, 0, 0)
ScriptEditor.ClipsDescendants = true
ScriptEditor.Parent = EditorContainer

local ScriptBox = Instance.new("TextBox")
ScriptBox.Name = "ScriptBox"
ScriptBox.Size = UDim2.new(1, -10, 1, 0)
ScriptBox.BackgroundTransparency = 1
ScriptBox.Font = Enum.Font.Code
ScriptBox.Text = "-- Welcome to Krypton Exe v2.0\n-- Start scripting here!"
ScriptBox.TextColor3 = Color3.fromRGB(220, 220, 220)
ScriptBox.TextSize = 14
ScriptBox.TextXAlignment = Enum.TextXAlignment.Left
ScriptBox.TextYAlignment = Enum.TextYAlignment.Top
ScriptBox.ClearTextOnFocus = false
ScriptBox.MultiLine = true
ScriptBox.TextWrapped = false
ScriptBox.Parent = ScriptEditor

-- Right Sidebar (Scripts Section)
local RightSidebar = Instance.new("Frame")
RightSidebar.Name = "RightSidebar"
RightSidebar.Size = UDim2.new(0, 225, 1, 0)
RightSidebar.Position = UDim2.new(1, -225, 0, 0)
RightSidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
RightSidebar.BorderSizePixel = 0
RightSidebar.Parent = ContentContainer

-- Built-in Scripts Section
local BuiltInSection = Instance.new("Frame")
BuiltInSection.Name = "BuiltInSection"
BuiltInSection.Size = UDim2.new(1, 0, 0, 120)
BuiltInSection.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
BuiltInSection.BorderSizePixel = 0
BuiltInSection.Parent = RightSidebar

local BuiltInTitle = Instance.new("TextLabel")
BuiltInTitle.Size = UDim2.new(1, -20, 0, 30)
BuiltInTitle.Position = UDim2.new(0, 10, 0, 5)
BuiltInTitle.BackgroundTransparency = 1
BuiltInTitle.Font = Enum.Font.GothamBold
BuiltInTitle.Text = "Built-in Scripts"
BuiltInTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
BuiltInTitle.TextSize = 14
BuiltInTitle.TextXAlignment = Enum.TextXAlignment.Left
BuiltInTitle.Parent = BuiltInSection

-- Built-in Script Item
local BuiltInItem = Instance.new("Frame")
BuiltInItem.Name = "KryptonUtilities"
BuiltInItem.Size = UDim2.new(1, -20, 0, 70)
BuiltInItem.Position = UDim2.new(0, 10, 0, 40)
BuiltInItem.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
BuiltInItem.BorderSizePixel = 0
BuiltInItem.Parent = BuiltInSection

local BuiltInItemCorner = Instance.new("UICorner")
BuiltInItemCorner.CornerRadius = UDim.new(0, 8)
BuiltInItemCorner.Parent = BuiltInItem

local BuiltInItemTitle = Instance.new("TextLabel")
BuiltInItemTitle.Size = UDim2.new(1, -20, 0, 25)
BuiltInItemTitle.Position = UDim2.new(0, 10, 0, 5)
BuiltInItemTitle.BackgroundTransparency = 1
BuiltInItemTitle.Font = Enum.Font.GothamBold
BuiltInItemTitle.Text = "Krypton Utilities"
BuiltInItemTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
BuiltInItemTitle.TextSize = 13
BuiltInItemTitle.TextXAlignment = Enum.TextXAlignment.Left
BuiltInItemTitle.Parent = BuiltInItem

local BuiltInExecuteBtn = Instance.new("TextButton")
BuiltInExecuteBtn.Size = UDim2.new(0, 120, 0, 30)
BuiltInExecuteBtn.Position = UDim2.new(0.5, -60, 1, -35)
BuiltInExecuteBtn.BackgroundColor3 = Color3.fromRGB(147, 112, 219)
BuiltInExecuteBtn.Font = Enum.Font.GothamBold
BuiltInExecuteBtn.Text = "▶ Execute"
BuiltInExecuteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BuiltInExecuteBtn.TextSize = 12
BuiltInExecuteBtn.Parent = BuiltInItem

local BuiltInExecCorner = Instance.new("UICorner")
BuiltInExecCorner.CornerRadius = UDim.new(0, 6)
BuiltInExecCorner.Parent = BuiltInExecuteBtn

BuiltInExecuteBtn.MouseButton1Click:Connect(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/raffametamofuruze-netizen/Utilitys/refs/heads/main/Utilitys"))()
    end)
end)

-- Saved Scripts Section
local SavedScriptsSection = Instance.new("Frame")
SavedScriptsSection.Name = "SavedScriptsSection"
SavedScriptsSection.Size = UDim2.new(1, 0, 1, -125)
SavedScriptsSection.Position = UDim2.new(0, 0, 0, 125)
SavedScriptsSection.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
SavedScriptsSection.BorderSizePixel = 0
SavedScriptsSection.Parent = RightSidebar

local SavedScriptsTitle = Instance.new("TextLabel")
SavedScriptsTitle.Size = UDim2.new(1, -20, 0, 30)
SavedScriptsTitle.Position = UDim2.new(0, 10, 0, 5)
SavedScriptsTitle.BackgroundTransparency = 1
SavedScriptsTitle.Font = Enum.Font.GothamBold
SavedScriptsTitle.Text = "Saved Scripts"
SavedScriptsTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
SavedScriptsTitle.TextSize = 14
SavedScriptsTitle.TextXAlignment = Enum.TextXAlignment.Left
SavedScriptsTitle.Parent = SavedScriptsSection

-- Saved Scripts Container
local SavedScriptsContainer = Instance.new("ScrollingFrame")
SavedScriptsContainer.Name = "SavedScriptsContainer"
SavedScriptsContainer.Size = UDim2.new(1, -20, 1, -80)
SavedScriptsContainer.Position = UDim2.new(0, 10, 0, 35)
SavedScriptsContainer.BackgroundTransparency = 1
SavedScriptsContainer.BorderSizePixel = 0
SavedScriptsContainer.ScrollBarThickness = 4
SavedScriptsContainer.ScrollBarImageColor3 = Color3.fromRGB(147, 112, 219)
SavedScriptsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
SavedScriptsContainer.Parent = SavedScriptsSection

local SavedScriptsList = Instance.new("UIListLayout")
SavedScriptsList.SortOrder = Enum.SortOrder.LayoutOrder
SavedScriptsList.Padding = UDim.new(0, 8)
SavedScriptsList.Parent = SavedScriptsContainer

-- Add Script Button
local AddScriptBtn = Instance.new("TextButton")
AddScriptBtn.Name = "AddScriptBtn"
AddScriptBtn.Size = UDim2.new(0, 40, 0, 40)
AddScriptBtn.Position = UDim2.new(1, -50, 1, -50)
AddScriptBtn.BackgroundColor3 = Color3.fromRGB(147, 112, 219)
AddScriptBtn.Font = Enum.Font.GothamBold
AddScriptBtn.Text = "+"
AddScriptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AddScriptBtn.TextSize = 24
AddScriptBtn.Parent = SavedScriptsSection

local AddScriptCorner = Instance.new("UICorner")
AddScriptCorner.CornerRadius = UDim.new(0, 20)
AddScriptCorner.Parent = AddScriptBtn

-- Saved Scripts Data
local SavedScriptsData = {}
local MAX_SAVED_SCRIPTS = 10

-- Save/Load Functions for Saved Scripts
local SAVED_SCRIPTS_FILE = SAVE_FOLDER .. "/saved_scripts.json"

local function SaveScriptsData()
    if not hasFileSystem then return end
    
    pcall(function()
        if not isfolder(SAVE_FOLDER) then
            makefolder(SAVE_FOLDER)
        end
        writefile(SAVED_SCRIPTS_FILE, HttpService:JSONEncode(SavedScriptsData))
    end)
end

local function LoadScriptsData()
    if not hasFileSystem then return end
    
    pcall(function()
        if isfile(SAVED_SCRIPTS_FILE) then
            local data = HttpService:JSONDecode(readfile(SAVED_SCRIPTS_FILE))
            SavedScriptsData = data or {}
        end
    end)
end

-- Create Saved Script Item
local function CreateSavedScriptItem(scriptData, index)
    local item = Instance.new("Frame")
    item.Name = "ScriptItem" .. index
    item.Size = UDim2.new(1, 0, 0, 70)
    item.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    item.BorderSizePixel = 0
    item.LayoutOrder = index
    item.Parent = SavedScriptsContainer
    
    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 8)
    itemCorner.Parent = item
    
    -- Star Icon
    local starIcon = Instance.new("TextLabel")
    starIcon.Size = UDim2.new(0, 20, 0, 20)
    starIcon.Position = UDim2.new(0, 10, 0, 8)
    starIcon.BackgroundTransparency = 1
    starIcon.Font = Enum.Font.GothamBold
    starIcon.Text = "⭐"
    starIcon.TextColor3 = Color3.fromRGB(255, 215, 0)
    starIcon.TextSize = 16
    starIcon.Parent = item
    
    -- Script Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -90, 0, 25)
    titleLabel.Position = UDim2.new(0, 35, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = scriptData.title
    titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.Parent = item
    
    -- Time Label
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(1, -90, 0, 15)
    timeLabel.Position = UDim2.new(0, 35, 0, 28)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.Text = scriptData.time or "Just now"
    timeLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    timeLabel.TextSize = 10
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeLabel.Parent = item
    
    -- Delete Button
    local deleteBtn = Instance.new("TextButton")
    deleteBtn.Size = UDim2.new(0, 30, 0, 30)
    deleteBtn.Position = UDim2.new(0, 10, 1, -35)
    deleteBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    deleteBtn.Font = Enum.Font.GothamBold
    deleteBtn.Text = "🗑"
    deleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    deleteBtn.TextSize = 14
    deleteBtn.Parent = item
    
    local deleteCorner = Instance.new("UICorner")
    deleteCorner.CornerRadius = UDim.new(0, 15)
    deleteCorner.Parent = deleteBtn
    
    deleteBtn.MouseButton1Click:Connect(function()
        table.remove(SavedScriptsData, index)
        item:Destroy()
        SaveScriptsData()
        
        -- Refresh list
        for i, child in ipairs(SavedScriptsContainer:GetChildren()) do
            if child:IsA("Frame") then
                child.LayoutOrder = i
            end
        end
    end)
    
    -- Execute Button
    local executeBtn = Instance.new("TextButton")
    executeBtn.Size = UDim2.new(0, 120, 0, 30)
    executeBtn.Position = UDim2.new(1, -130, 1, -35)
    executeBtn.BackgroundColor3 = Color3.fromRGB(147, 219, 112)
    executeBtn.Font = Enum.Font.GothamBold
    executeBtn.Text = "▶ Execute"
    executeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    executeBtn.TextSize = 12
    executeBtn.Parent = item
    
    local execCorner = Instance.new("UICorner")
    execCorner.CornerRadius = UDim.new(0, 6)
    execCorner.Parent = executeBtn
    
    executeBtn.MouseButton1Click:Connect(function()
        pcall(function()
            local func, err = loadstring(scriptData.script)
            if func then
                func()
            else
                warn("Script Error: " .. tostring(err))
            end
        end)
    end)
    
    return item
end

-- Refresh Saved Scripts List
local function RefreshSavedScripts()
    for _, child in ipairs(SavedScriptsContainer:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    for i, scriptData in ipairs(SavedScriptsData) do
        CreateSavedScriptItem(scriptData, i)
    end
    
    SavedScriptsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SavedScriptsContainer.CanvasSize = UDim2.new(0, 0, 0, SavedScriptsList.AbsoluteContentSize.Y + 10)
    end)
end

-- Add Script Popup
local AddScriptPopup = Instance.new("Frame")
AddScriptPopup.Name = "AddScriptPopup"
AddScriptPopup.Size = UDim2.new(0, 400, 0, 300)
AddScriptPopup.Position = UDim2.new(0.5, -200, 0.5, -150)
AddScriptPopup.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
AddScriptPopup.BorderSizePixel = 0
AddScriptPopup.Visible = false
AddScriptPopup.ZIndex = 10
AddScriptPopup.Parent = ScreenGui

local PopupCorner = Instance.new("UICorner")
PopupCorner.CornerRadius = UDim.new(0, 12)
PopupCorner.Parent = AddScriptPopup

-- Popup Shadow
local PopupShadow = Instance.new("ImageLabel")
PopupShadow.Size = UDim2.new(1, 30, 1, 30)
PopupShadow.Position = UDim2.new(0, -15, 0, -15)
PopupShadow.BackgroundTransparency = 1
PopupShadow.Image = "rbxasset://textures/ui/Chat/ChatInputBarBackground.png"
PopupShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
PopupShadow.ImageTransparency = 0.3
PopupShadow.ScaleType = Enum.ScaleType.Slice
PopupShadow.SliceCenter = Rect.new(8, 8, 8, 8)
PopupShadow.ZIndex = 9
PopupShadow.Parent = AddScriptPopup

-- Popup Title
local PopupTitle = Instance.new("TextLabel")
PopupTitle.Size = UDim2.new(1, -50, 0, 40)
PopupTitle.Position = UDim2.new(0, 10, 0, 5)
PopupTitle.BackgroundTransparency = 1
PopupTitle.Font = Enum.Font.GothamBold
PopupTitle.Text = "Add New Script"
PopupTitle.TextColor3 = Color3.fromRGB(147, 112, 219)
PopupTitle.TextSize = 16
PopupTitle.TextXAlignment = Enum.TextXAlignment.Left
PopupTitle.ZIndex = 10
PopupTitle.Parent = AddScriptPopup

-- Close Popup Button
local ClosePopupBtn = Instance.new("TextButton")
ClosePopupBtn.Size = UDim2.new(0, 35, 0, 35)
ClosePopupBtn.Position = UDim2.new(1, -40, 0, 5)
ClosePopupBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
ClosePopupBtn.Font = Enum.Font.GothamBold
ClosePopupBtn.Text = "X"
ClosePopupBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClosePopupBtn.TextSize = 16
ClosePopupBtn.ZIndex = 10
ClosePopupBtn.Parent = AddScriptPopup

local ClosePopupCorner = Instance.new("UICorner")
ClosePopupCorner.CornerRadius = UDim.new(0, 8)
ClosePopupCorner.Parent = ClosePopupBtn

-- Title Input
local TitleInput = Instance.new("TextBox")
TitleInput.Size = UDim2.new(1, -40, 0, 40)
TitleInput.Position = UDim2.new(0, 20, 0, 55)
TitleInput.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
TitleInput.Font = Enum.Font.Gotham
TitleInput.PlaceholderText = "Set your script title"
TitleInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
TitleInput.Text = ""
TitleInput.TextColor3 = Color3.fromRGB(220, 220, 220)
TitleInput.TextSize = 14
TitleInput.TextXAlignment = Enum.TextXAlignment.Left
TitleInput.ClearTextOnFocus = false
TitleInput.ZIndex = 10
TitleInput.Parent = AddScriptPopup

local TitleInputCorner = Instance.new("UICorner")
TitleInputCorner.CornerRadius = UDim.new(0, 8)
TitleInputCorner.Parent = TitleInput

local TitleInputPadding = Instance.new("UIPadding")
TitleInputPadding.PaddingLeft = UDim.new(0, 10)
TitleInputPadding.Parent = TitleInput

-- Script Input
local ScriptInput = Instance.new("TextBox")
ScriptInput.Size = UDim2.new(1, -40, 0, 130)
ScriptInput.Position = UDim2.new(0, 20, 0, 105)
ScriptInput.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
ScriptInput.Font = Enum.Font.Code
ScriptInput.PlaceholderText = "Put your script here"
ScriptInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
ScriptInput.Text = ""
ScriptInput.TextColor3 = Color3.fromRGB(220, 220, 220)
ScriptInput.TextSize = 12
ScriptInput.TextXAlignment = Enum.TextXAlignment.Left
ScriptInput.TextYAlignment = Enum.TextYAlignment.Top
ScriptInput.ClearTextOnFocus = false
ScriptInput.MultiLine = true
ScriptInput.TextWrapped = true
ScriptInput.ZIndex = 10
ScriptInput.Parent = AddScriptPopup

local ScriptInputCorner = Instance.new("UICorner")
ScriptInputCorner.CornerRadius = UDim.new(0, 8)
ScriptInputCorner.Parent = ScriptInput

local ScriptInputPadding = Instance.new("UIPadding")
ScriptInputPadding.PaddingLeft = UDim.new(0, 10)
ScriptInputPadding.PaddingTop = UDim.new(0, 8)
ScriptInputPadding.Parent = ScriptInput

-- Add Script Confirm Button
local AddScriptConfirmBtn = Instance.new("TextButton")
AddScriptConfirmBtn.Size = UDim2.new(0, 150, 0, 40)
AddScriptConfirmBtn.Position = UDim2.new(0.5, -75, 1, -50)
AddScriptConfirmBtn.BackgroundColor3 = Color3.fromRGB(147, 112, 219)
AddScriptConfirmBtn.Font = Enum.Font.GothamBold
AddScriptConfirmBtn.Text = "Add Script"
AddScriptConfirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AddScriptConfirmBtn.TextSize = 14
AddScriptConfirmBtn.ZIndex = 10
AddScriptConfirmBtn.Parent = AddScriptPopup

local AddConfirmCorner = Instance.new("UICorner")
AddConfirmCorner.CornerRadius = UDim.new(0, 8)
AddConfirmCorner.Parent = AddScriptConfirmBtn

-- Popup Animation Functions
local function ShowPopup()
    AddScriptPopup.Visible = true
    AddScriptPopup.Size = UDim2.new(0, 0, 0, 0)
    AddScriptPopup.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local sizeTween = TweenService:Create(AddScriptPopup, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 400, 0, 300),
        Position = UDim2.new(0.5, -200, 0.5, -150)
    })
    sizeTween:Play()
end

local function HidePopup()
    local sizeTween = TweenService:Create(AddScriptPopup, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    sizeTween:Play()
    
    sizeTween.Completed:Connect(function()
        AddScriptPopup.Visible = false
        TitleInput.Text = ""
        ScriptInput.Text = ""
    end)
end

-- Add Script Button Click
AddScriptBtn.MouseButton1Click:Connect(function()
    if #SavedScriptsData >= MAX_SAVED_SCRIPTS then
        warn("Maximum saved scripts reached (10)")
        return
    end
    ShowPopup()
end)

-- Close Popup Button Click
ClosePopupBtn.MouseButton1Click:Connect(function()
    HidePopup()
end)

-- Add Script Confirm
AddScriptConfirmBtn.MouseButton1Click:Connect(function()
    local title = TitleInput.Text
    local script = ScriptInput.Text
    
    if title == "" or script == "" then
        warn("Please fill in both fields")
        return
    end
    
    if #SavedScriptsData >= MAX_SAVED_SCRIPTS then
        warn("Maximum saved scripts reached (10)")
        return
    end
    
    local scriptData = {
        title = title,
        script = script,
        time = os.date("%X")
    }
    
    table.insert(SavedScriptsData, scriptData)
    SaveScriptsData()
    RefreshSavedScripts()
    HidePopup()
end)

-- Load saved scripts on start
LoadScriptsData()
RefreshSavedScripts()

-- Sync scrolling between editor and line numbers
ScriptEditor:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
    LineNumbers.CanvasPosition = Vector2.new(0, ScriptEditor.CanvasPosition.Y)
end)

-- Update Line Numbers and Canvas Size
local function UpdateLineNumbers()
    local text = ScriptBox.Text
    local lines = 1
    for _ in text:gmatch("\n") do
        lines = lines + 1
    end
    
    local lineText = ""
    for i = 1, lines do
        lineText = lineText .. i .. "\n"
    end
    LineNumbersText.Text = lineText
    
    -- Calculate text height
    local textHeight = lines * 19 -- Approximate line height
    ScriptEditor.CanvasSize = UDim2.new(0, 0, 0, math.max(textHeight, ScriptEditor.AbsoluteSize.Y))
    LineNumbers.CanvasSize = UDim2.new(0, 0, 0, math.max(textHeight, LineNumbers.AbsoluteSize.Y))
    
    -- Adjust TextLabel size
    LineNumbersText.Size = UDim2.new(1, 0, 0, textHeight)
    ScriptBox.Size = UDim2.new(1, -10, 0, math.max(textHeight, ScriptEditor.AbsoluteSize.Y))
end

ScriptBox:GetPropertyChangedSignal("Text"):Connect(UpdateLineNumbers)
UpdateLineNumbers()

-- Buttons Container
local ButtonsContainer = Instance.new("Frame")
ButtonsContainer.Name = "ButtonsContainer"
ButtonsContainer.Size = UDim2.new(0, 405, 0, 45)
ButtonsContainer.Position = UDim2.new(0, 205, 1, -50)
ButtonsContainer.BackgroundTransparency = 1
ButtonsContainer.Parent = ContentContainer

local function CreateButton(text, position, color, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 150, 0, 35)
    button.Position = position
    button.BackgroundColor3 = color
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Parent = ButtonsContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(callback)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(
            math.min(color.R * 255 + 20, 255),
            math.min(color.G * 255 + 20, 255),
            math.min(color.B * 255 + 20, 255)
        )}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
    end)
    
    return button
end

-- Clear Button
CreateButton("Clear", UDim2.new(0, 10, 0, 5), Color3.fromRGB(60, 60, 70), function()
    ScriptBox.Text = ""
    if TabData[CurrentTab] then
        TabData[CurrentTab].Content = ""
    end
end)

-- Execute Button
CreateButton("Execute", UDim2.new(0, 170, 0, 5), Color3.fromRGB(147, 112, 219), function()
    local success, err = pcall(function()
        local func, loadErr = loadstring(ScriptBox.Text)
        if func then
            func()
        else
            warn("Krypton Exe Error: " .. tostring(loadErr))
        end
    end)
    if not success then
        warn("Krypton Exe Execution Error: " .. tostring(err))
    end
end)

-- Auto-Save Functions
local function SaveWorkspace()
    if not hasFileSystem then return end
    
    pcall(function()
        if not isfolder(SAVE_FOLDER) then
            makefolder(SAVE_FOLDER)
        end
        
        local saveData = {
            tabs = {},
            currentTab = CurrentTab,
            tabCounter = TabCounter
        }
        
        for id, data in pairs(TabData) do
            table.insert(saveData.tabs, {
                id = id,
                name = data.Name,
                content = data.Content,
                order = data.Order
            })
        end
        
        writefile(SAVE_FILE, HttpService:JSONEncode(saveData))
    end)
end

local function LoadWorkspace()
    if not hasFileSystem then return false end
    
    local success = pcall(function()
        if not isfolder(SAVE_FOLDER) or not isfile(SAVE_FILE) then
            return
        end
        
        local data = HttpService:JSONDecode(readfile(SAVE_FILE))
        
        if data.tabs and #data.tabs > 0 then
            TabCounter = data.tabCounter or #data.tabs
            
            -- Sort tabs by order
            table.sort(data.tabs, function(a, b)
                return (a.order or a.id) < (b.order or b.id)
            end)
            
            -- Create tabs
            for _, tabData in ipairs(data.tabs) do
                CreateTab(tabData.id, tabData.name, tabData.content)
            end
            
            -- Set current tab
            if data.currentTab and TabData[data.currentTab] then
                CurrentTab = data.currentTab
                ScriptBox.Text = TabData[CurrentTab].Content
                TabData[CurrentTab].Button.BackgroundColor3 = Color3.fromRGB(147, 112, 219)
            end
        end
    end)
    
    return success
end

-- Tab Functions
function CreateTab(id, name, content)
    id = id or (TabCounter + 1)
    name = name or ("Tab " .. id)
    content = content or ""
    
    if TabData[id] then return end
    
    TabCounter = math.max(TabCounter, id)
    
    local tabButton = Instance.new("TextButton")
    tabButton.Name = "Tab" .. id
    tabButton.Size = UDim2.new(1, 0, 0, 30)
    tabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    tabButton.Font = Enum.Font.Gotham
    tabButton.Text = name
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.TextSize = 12
    tabButton.LayoutOrder = id
    tabButton.Parent = TabsContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabButton
    
    TabData[id] = {
        Button = tabButton,
        Content = content,
        Name = name,
        Order = id
    }
    
    tabButton.MouseButton1Click:Connect(function()
        -- Save current tab content
        if TabData[CurrentTab] then
            TabData[CurrentTab].Content = ScriptBox.Text
        end
        
        -- Switch to new tab
        CurrentTab = id
        ScriptBox.Text = TabData[id].Content
        UpdateLineNumbers()
        
        -- Update button colors
        for _, data in pairs(TabData) do
            data.Button.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        end
        TabData[id].Button.BackgroundColor3 = Color3.fromRGB(147, 112, 219)
        
        -- Auto-save
        SaveWorkspace()
    end)
    
    return tabButton
end

-- Add Tab Button Click
AddTabButton.MouseButton1Click:Connect(function()
    TabCounter = TabCounter + 1
    CreateTab(TabCounter)
    
    -- Auto-save
    SaveWorkspace()
end)

-- Auto-save on text change (debounced)
local saveDebounce = false
ScriptBox:GetPropertyChangedSignal("Text"):Connect(function()
    if TabData[CurrentTab] then
        TabData[CurrentTab].Content = ScriptBox.Text
    end
    
    if not saveDebounce then
        saveDebounce = true
        task.delay(2, function()
            SaveWorkspace()
            saveDebounce = false
        end)
    end
end)

-- Load saved workspace or create default tabs
local loaded = LoadWorkspace()
if not loaded then
    -- Create default tabs
    for i = 1, 3 do
        CreateTab(i)
    end
    TabData[1].Button.BackgroundColor3 = Color3.fromRGB(147, 112, 219)
end

-- Update canvas size
TabsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabsContainer.CanvasSize = UDim2.new(0, 0, 0, TabsList.AbsoluteContentSize.Y + 10)
end)

-- Enhanced Executor Detection
local function DetectExecutor()
    local executors = {
        -- Modern Executors
        {name = "Velocity", check = function() 
            return getgenv().velocity or getgenv().VELOCITY_VERSION 
        end},
        {name = "Arceus X v5", check = function() 
            return getgenv().ARCEUS_VERSION and tostring(getgenv().ARCEUS_VERSION):find("5") 
        end},
        {name = "Arceus X", check = function() 
            return getgenv().ARCEUS_VERSION 
        end},
        {name = "Xeno", check = function() 
            return getgenv().XENO_VERSION or getgenv().xeno 
        end},
        {name = "Solara", check = function() 
            return getgenv().SOLARA_VERSION or getgenv().solara 
        end},
        {name = "Wave", check = function() 
            return getgenv().WAVE_VERSION or getgenv().wave or identifyexecutor():lower():find("wave") 
        end},
        {name = "SirHurt", check = function() 
            return getgenv().SIRHURT_VERSION or getgenv().sirhurt or is_sirhurt_closure 
        end},
        {name = "Bunni.fun", check = function() 
            return getgenv().BUNNI_VERSION or getgenv().bunni 
        end},
        {name = "Codex", check = function() 
            return getgenv().CODEX_VERSION or getgenv().codex or identifyexecutor():lower():find("codex") 
        end},
        {name = "AppleWare", check = function() 
            return getgenv().APPLEWARE_VERSION or getgenv().appleware 
        end},
        {name = "Ronix Mobile", check = function() 
            return (getgenv().RONIX_VERSION or getgenv().ronix) and (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) 
        end},
        {name = "Ronix PC", check = function() 
            return (getgenv().RONIX_VERSION or getgenv().ronix) and UserInputService.KeyboardEnabled 
        end},
        {name = "Potassium", check = function() 
            return getgenv().POTASSIUM_VERSION or getgenv().potassium 
        end},
        
        -- Legacy Executors
        {name = "Synapse X", check = function() 
            return syn and (syn.request or syn.crypt) 
        end},
        {name = "Script-Ware", check = function() 
            return getgenv().SCRIPTWARE_VERSION or getgenv().SWVERSION 
        end},
        {name = "KRNL", check = function() 
            return getgenv().KRNL_LOADED 
        end},
        {name = "Fluxus", check = function() 
            return getgenv().fluxus and getgenv().fluxus.version 
        end},
        {name = "Delta", check = function() 
            return getgenv().DELTA_VERSION 
        end},
        {name = "Electron", check = function() 
            return getgenv().ELECTRON_VERSION or getgenv().electron 
        end},
        {name = "Trigon", check = function() 
            return getgenv().TRIGON_VERSION or getgenv().trigon 
        end},
    }
    
    -- Try identifyexecutor first
    if identifyexecutor then
        local success, name = pcall(identifyexecutor)
        if success and name and name ~= "" and name:lower() ~= "unknown" then
            return name
        end
    end
    
    -- Check each executor
    for _, executor in ipairs(executors) do
        local success, result = pcall(function()
            return executor.check()
        end)
        if success and result then
            return executor.name
        end
    end
    
    return "Unknown Executor"
end

local detectedExecutor = DetectExecutor()
if ExecutorLabel then
    ExecutorLabel.Text = "Executor: " .. detectedExecutor
end
if ExecutorInfo then
    local fsStatus = hasFileSystem and "Enabled" or "Disabled"
    ExecutorInfo.Text = "Running on: " .. detectedExecutor .. "\nVersion: Krypton Exe v2.0\nAuto-Save: " .. fsStatus
end

-- Moon Phase Detection (Blox Fruits Only)
local function GetMoonPhase()
    local gameId = tostring(game.PlaceId)
    
    -- Check if game is Blox Fruits
    local bloxFruitsIds = {
        "2753915549", -- Blox Fruits
        "4442272183", -- Blox Fruits (Sea 2)
        "7449423635"  -- Blox Fruits (Sea 3)
    }
    
    local isBloxFruits = false
    for _, id in ipairs(bloxFruitsIds) do
        if gameId == id then
            isBloxFruits = true
            break
        end
    end
    
    if not isBloxFruits then
        return "Unsupported Game"
    end
    
    -- Moon phase detection
    local MoonPhases = {
        ["9709149431"] = "8/8 🌕",
        ["9709149052"] = "7/8 🌖",
        ["9709143733"] = "6/8 🌗",
        ["9709150401"] = "5/8 🌘",
        ["9709135895"] = "4/8 🌑",
        ["9709139597"] = "3/8 🌒",
        ["9709150086"] = "2/8 🌓",
        ["9709149680"] = "1/8 🌔",
    }
    
    local success, result = pcall(function()
        if Lighting:FindFirstChild("Sky") then
            local skyId = tostring(Lighting.Sky.MoonTextureId):match("%d+")
            return MoonPhases[skyId] or "Loading..."
        end
        return "Loading..."
    end)
    
    return success and result or "Loading..."
end

-- Status Update Loop
local lastFPS = 60
local fpsUpdateInterval = 0
local pingUpdateInterval = 0

RunService.Heartbeat:Connect(function(deltaTime)
    -- FPS Counter
    fpsUpdateInterval = fpsUpdateInterval + deltaTime
    if fpsUpdateInterval >= 0.5 then
        pcall(function()
            lastFPS = math.floor(1 / deltaTime)
            if FPSLabel then
                FPSLabel.Text = "FPS: " .. lastFPS
            end
        end)
        fpsUpdateInterval = 0
    end
    
    -- Ping Counter
    pingUpdateInterval = pingUpdateInterval + deltaTime
    if pingUpdateInterval >= 1 then
        pcall(function()
            if Player then
                local ping = math.floor(Player:GetNetworkPing() * 1000)
                if PingLabel then
                    PingLabel.Text = "Ping: " .. ping .. " ms"
                end
            end
        end)
        pingUpdateInterval = 0
    end
end)

-- Player Count
pcall(function()
    if PlayerCountLabel then
        PlayerCountLabel.Text = "Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers
    end
end)

Players.PlayerAdded:Connect(function()
    pcall(function()
        if PlayerCountLabel then
            PlayerCountLabel.Text = "Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers
        end
    end)
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.1)
    pcall(function()
        if PlayerCountLabel then
            PlayerCountLabel.Text = "Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers
        end
    end)
end)

-- Moon Phase Update
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            local moonPhase = GetMoonPhase()
            if MoonLabel then
                MoonLabel.Text = "Moon Phase: " .. moonPhase
            end
        end)
    end
end)

-- Initial moon check
pcall(function()
    if MoonLabel then
        MoonLabel.Text = "Moon Phase: " .. GetMoonPhase()
    end
end)

-- Minimize Functionality
local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        -- Minimize
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 850, 0, 50)}):Play()
        ContentContainer.Visible = false
    else
        -- Restore
        ContentContainer.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 850, 0, 550)}):Play()
    end
end)

-- Dragging Functionality
local dragging = false
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Save on close
ScreenGui.Destroying:Connect(function()
    SaveWorkspace()
end)

-- Initialization Complete
print("=================================")
print("Krypton Exe v2.0 loaded successfully!")
print("Executor detected: " .. detectedExecutor)
print("Auto-Save: " .. (hasFileSystem and "Enabled" or "Disabled"))
print("Tabs loaded: " .. #TabData)
print("=================================")
