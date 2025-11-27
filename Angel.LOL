--! ANGEL.LOL 3.0 Executor Version (Super Smooth Cam + Silent Aim with Respawn Fix)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local lock = false
local target = nil
local targetChar = nil
local dragging = false
local dragOffset = Vector2.new()

-- Camera smooth factor
local smoothness = 0.12 -- lower = smoother (super smooth)

-- HSV rainbow
local function HSV(h, s, v)
local i = math.floor(h * 6)
local f = h * 6 - i
local p = v * (1 - s)
local q = v * (1 - f * s)
local t = v * (1 - (1 - f) * s)
i = i % 6
if i == 0 then return Color3.new(v, t, p)
elseif i == 1 then return Color3.new(q, v, p)
elseif i == 2 then return Color3.new(p, v, t)
elseif i == 3 then return Color3.new(p, q, v)
elseif i == 4 then return Color3.new(t, p, v)
else return Color3.new(v, p, q)
end
end

-- Helpers
local function IsAlive(player)
if not player or not player.Character then return false end
local hum = player.Character:FindFirstChildOfClass("Humanoid")
return hum and hum.Health > 0
end

local function GetTargetOnCrosshair()
local closest, closestDist
local vp = Camera.ViewportSize
local center = Vector2.new(vp.X/2, vp.Y/2)
for _, plr in ipairs(Players:GetPlayers()) do
if plr ~= LocalPlayer and IsAlive(plr) then
local root = plr.Character:FindFirstChild("HumanoidRootPart")
if root then
local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
if onScreen then
local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
if not closestDist or dist < closestDist then
closest = plr
closestDist = dist
end
end
end
end
end
return closest
end

-- GUI
local function CreateMainGUI()
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "ANGELL_GUI"
MainGui.ResetOnSpawn = false
MainGui.Parent = PlayerGui

local Button = Instance.new("TextButton", MainGui)
Button.Name = "LockButton"
Button.Size = UDim2.new(0,180,0,40)
Button.Position = UDim2.new(0,12,0,12)
Button.BackgroundColor3 = Color3.fromRGB(20,20,20)
Button.BorderSizePixel = 2
Button.BorderColor3 = Color3.fromRGB(0,100,255)
Button.Font = Enum.Font.GothamBlack
Button.TextSize = 18
Button.Text = "ANGEL.LOL"
Button.TextColor3 = Color3.fromRGB(255,255,255)

local NameLabel = Instance.new("TextLabel", Button)
NameLabel.AnchorPoint = Vector2.new(0,1)
NameLabel.Size = UDim2.new(1,-10,0,16)
NameLabel.Position = UDim2.new(0,5,1,-4)
NameLabel.BackgroundTransparency = 1
NameLabel.Text = "No target"
NameLabel.Font = Enum.Font.GothamMedium
NameLabel.TextSize = 12
NameLabel.TextColor3 = Color3.fromRGB(200,200,200)

-- Drag
Button.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragOffset = i.Position - Button.AbsolutePosition
    end
end)
Button.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local p=i.Position-dragOffset
        Button.Position=UDim2.new(0,p.X,0,p.Y)
    end
end)

local function ToggleLock()
    lock = not lock
    if lock then
        target = GetTargetOnCrosshair()
        targetChar = target and target.Character
        NameLabel.Text = target and ("Target: "..target.Name) or "No valid target"
    else
        target = nil
        targetChar = nil
        NameLabel.Text = "No target"
    end
end

Button.MouseButton1Click:Connect(ToggleLock)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Q then
        ToggleLock()
    end
end)

-- CAMERA LOCK & LABEL (Respawn-safe)
RunService.RenderStepped:Connect(function()
    local h = (tick()*0.25)%1
    Button.TextColor3 = HSV(h,1,1)
    NameLabel.TextColor3 = HSV((h+0.2)%1,1,1)

    if lock and target then
        -- Ensure character exists
        if not targetChar or not targetChar.Parent then
            targetChar = target.Character or target.CharacterAdded:Wait()
        end
        local root = targetChar:FindFirstChild("UpperTorso") 
                 or targetChar:FindFirstChild("Head") 
                 or targetChar:FindFirstChild("HumanoidRootPart")
        if root then
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position, root.Position),
                smoothness
            )
            NameLabel.Text = "Target: "..target.Name
        end
    else
        target = lock and GetTargetOnCrosshair() or nil
        targetChar = target and target.Character
        NameLabel.Text = target and ("Target: "..target.Name) or "No target"
    end
end)

end

CreateMainGUI()

-- =====================
-- Zee Hood Silent Aim
-- =====================
local success, GunHandler = pcall(function() return require(ReplicatedStorage.Modules.GunHandler) end)
if success and GunHandler then
local originalShoot = GunHandler.Shoot
GunHandler.Shoot = function(params)
if lock and target and IsAlive(target) then
local head = target.Character:FindFirstChild("Head")
if head then
params.AimPosition = head.Position
params.Hit = head
params.Normal = Vector3.new(0,1,0)
if params.BeamTarget then params.BeamTarget = head end
end
end
return originalShoot(params)
end
end

print("=== Angel.LOL: Super Smooth Cam + Silent Aim with Respawn Fix Loaded ===")
