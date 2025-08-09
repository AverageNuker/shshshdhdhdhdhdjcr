local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RingPartsControl"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 350)
mainFrame.Position = UDim2.new(0.5, -200, 0.6, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BackgroundTransparency = 0.1
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = mainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(40, 60, 100)
UIStroke.Thickness = 3
UIStroke.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 30, 45)
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 14)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -20, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.Text = "RING PARTS CONTROL"
titleText.TextColor3 = Color3.fromRGB(180, 200, 255)
titleText.Font = Enum.Font.GothamBlack
titleText.TextSize = 18
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.BackgroundTransparency = 1
titleText.Parent = titleBar

local function createControl(name, defaultValue, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 50)
    frame.Position = UDim2.new(0.05, 0, yPos, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = mainFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 25)
    label.Text = name
    label.TextColor3 = Color3.fromRGB(150, 170, 220)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.35, 0, 0, 30)
    box.Position = UDim2.new(0.65, 0, 0, 0)
    box.Text = tostring(defaultValue)
    box.TextColor3 = Color3.fromRGB(200, 200, 200)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 16
    box.BackgroundColor3 = Color3.fromRGB(30, 40, 55)
    box.Parent = frame

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = box
    
    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = Color3.fromRGB(70, 100, 150)
    boxStroke.Parent = box
    
    return box
end

local radius = 50
local height = 100
local rotationSpeed = 1
local attractionStrength = 1000
local ringPartsEnabled = false

local radiusBox = createControl("RADIUS:", radius, 0.15)
local heightBox = createControl("HEIGHT:", height, 0.3)
local spinBox = createControl("SPIN:", rotationSpeed, 0.45)
local powerBox = createControl("POWER:", attractionStrength, 0.6)

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.9, 0, 0, 50)
toggleButton.Position = UDim2.new(0.05, 0, 0.8, 0)
toggleButton.Text = "ACTIVATE RING PARTS"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBlack
toggleButton.TextSize = 18
toggleButton.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
toggleButton.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(200, 60, 60)
toggleStroke.Parent = toggleButton

if not getgenv().Network then
    getgenv().Network = {
        BaseParts = {},
        Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)
    }

    Network.RetainPart = function(Part)
        if typeof(Part) == "Instance" and Part:IsA("BasePart") and Part:IsDescendantOf(Workspace) then
            table.insert(Network.BaseParts, Part)
            Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            Part.CanCollide = false
        end
    end

    local function EnablePartControl()
        LocalPlayer.ReplicationFocus = Workspace
        RunService.Heartbeat:Connect(function()
            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            for _, Part in pairs(Network.BaseParts) do
                if Part:IsDescendantOf(Workspace) then
                    Part.Velocity = Network.Velocity
                end
            end
        end)
    end

    EnablePartControl()
end

local function RetainPart(Part)
    if Part:IsA("BasePart") and not Part.Anchored and Part:IsDescendantOf(Workspace) then
        if Part.Parent == LocalPlayer.Character or Part:IsDescendantOf(LocalPlayer.Character) then
            return false
        end
        Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        Part.CanCollide = false
        return true
    end
    return false
end

local parts = {}
local function addPart(part)
    if RetainPart(part) then
        if not table.find(parts, part) then
            table.insert(parts, part)
        end
    end
end

local function removePart(part)
    local index = table.find(parts, part)
    if index then
        table.remove(parts, index)
    end
end

for _, part in pairs(Workspace:GetDescendants()) do
    if part:IsA("BasePart") then
        addPart(part)
    end
end

Workspace.DescendantAdded:Connect(function(part)
    if part:IsA("BasePart") then
        addPart(part)
    end
end)

Workspace.DescendantRemoving:Connect(removePart)

RunService.Heartbeat:Connect(function()
    if not ringPartsEnabled then return end
    
    radius = math.clamp(tonumber(radiusBox.Text) or radius, 10, 1000)
    height = math.clamp(tonumber(heightBox.Text) or height, 1, 500)
    rotationSpeed = math.clamp(tonumber(spinBox.Text) or rotationSpeed, 0.1, 10)
    attractionStrength = math.clamp(tonumber(powerBox.Text) or attractionStrength, 100, 5000)
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local playerPosition = humanoidRootPart.Position
    
    for i, part in pairs(parts) do
        if part and part.Parent and not part.Anchored and part ~= humanoidRootPart then
            if part.Parent == character then continue end
            
            local partPosition = part.Position
            local horizontalOffset = Vector3.new(partPosition.X - playerPosition.X, 0, partPosition.Z - playerPosition.Z)
            local horizontalDistance = horizontalOffset.Magnitude
            
            if horizontalDistance > 0.1 then
                local currentAngle = math.atan2(horizontalOffset.Z, horizontalOffset.X)
                local newAngle = currentAngle + math.rad(rotationSpeed)
                
                local targetRadius = math.min(radius, horizontalDistance + 5)
                local targetX = playerPosition.X + math.cos(newAngle) * targetRadius
                local targetZ = playerPosition.Z + math.sin(newAngle) * targetRadius
                local targetY = playerPosition.Y + math.sin(tick() * 2 + i) * height * 0.1
                
                local targetPosition = Vector3.new(targetX, targetY, targetZ)
                local direction = (targetPosition - partPosition).Unit
                
                if direction.Magnitude > 0 then
                    part.Velocity = direction * attractionStrength
                end
            end
        end
    end
end)

toggleButton.MouseButton1Click:Connect(function()
    ringPartsEnabled = not ringPartsEnabled
    
    if ringPartsEnabled then
        toggleButton.Text = "DEACTIVATE RING PARTS"
        toggleButton.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
        toggleStroke.Color = Color3.fromRGB(60, 220, 60)
    else
        toggleButton.Text = "ACTIVATE RING PARTS"
        toggleButton.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        toggleStroke.Color = Color3.fromRGB(200, 60, 60)
        
        for _, part in pairs(parts) do
            if part and part.Parent then
                part.Velocity = Vector3.new(0, 0, 0)
                part.CanCollide = true
            end
        end
    end
end)

local dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragStart = nil
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
