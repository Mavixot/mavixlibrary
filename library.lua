-- Mavix Library v2.0
-- https://discord.gg/fszKHXW3RF

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

-- Constants
local LIBRARY_NAME = "Acrylic"
local DEFAULT_CONFIG_FOLDER = "AcrylicConfigs"

-- Configuration
local Colors = {
    Background = Color3.fromRGB(25, 15, 15),
    Secondary = Color3.fromRGB(25, 15, 15),
    Border = Color3.fromRGB(15, 0, 0),
    Text = Color3.fromRGB(235, 235, 235),
    TextDark = Color3.fromRGB(180, 180, 180),
    TextFade = Color3.fromRGB(60, 10, 10),
    Accent = Color3.fromRGB(190, 50, 50),
    Toggle = {
        Enabled = Color3.fromRGB(255, 215, 215),
        Disabled = Color3.fromRGB(45, 15, 15),
        Circle = Color3.fromRGB(235, 235, 235)
    },
    Notification = {
        Background = Color3.fromRGB(18, 10, 10),
        Border = Color3.fromRGB(0, 0, 0),
        Timer = Color3.fromRGB(190, 50, 50)
    }
}

-- Sizes
local Sizes = {
    Window = {Width = 690, Height = 446},
    MinWindow = {Width = 500, Height = 300},
    MaxWindow = {Width = 1200, Height = 800},
    Toggle = {Width = 38, Height = 21, Circle = 13},
    Button = {Height = 39},
    Slider = {Height = 46},
    Dropdown = {Height = 39, OptionHeight = 30},
    Tab = {Width = 135, Height = 35},
    ColorPicker = {Width = 180, Height = 160},
    Notification = {Width = 220, Height = 70},
    TextBox = {Height = 39, InputWidth = 150}
}

-- Fonts
local Fonts = {
    Regular = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
    Bold = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
}

-- Text Sizes
local TextSizes = {
    Title = 14,
    Normal = 14,
    Small = 13,
    Tiny = 11
}

-- Animation Speeds
local AnimSpeed = {
    Fast = 0.1,
    Normal = 0.15,
    Slow = 0.2,
    VerySlow = 0.3
}

-- Utility Functions
local function CreateTween(instance, properties, duration, easingStyle, easingDirection)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(
            duration or AnimSpeed.Normal,
            easingStyle or Enum.EasingStyle.Quad,
            easingDirection or Enum.EasingDirection.Out
        ),
        properties
    )
    tween:Play()
    return tween
end

local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        if property ~= "Parent" then
            instance[property] = value
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

local function CreateCorner(parent, radius)
    return CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, radius or 5),
        Parent = parent
    })
end

local function CreateStroke(parent, color, transparency)
    return CreateInstance("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = color or Colors.Border,
        Transparency = transparency or 0,
        Thickness = 1,
        Parent = parent
    })
end

local function CreatePadding(parent, padding)
    return CreateInstance("UIPadding", {
        PaddingTop = UDim.new(0, padding or 0),
        PaddingBottom = UDim.new(0, padding or 0),
        PaddingLeft = UDim.new(0, padding or 0),
        PaddingRight = UDim.new(0, padding or 0),
        Parent = parent
    })
end

local function CreateListLayout(parent, padding, sortOrder, direction)
    return CreateInstance("UIListLayout", {
        Padding = UDim.new(0, padding or 0),
        SortOrder = sortOrder or Enum.SortOrder.LayoutOrder,
        FillDirection = direction or Enum.FillDirection.Vertical,
        Parent = parent
    })
end

local function IsMobileDevice()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

-- Drag Handler
local function MakeDraggable(frame, handle)
    local dragging = false
    local dragInput, dragStart, startPos
    handle = handle or frame

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    handle.InputEnded:Connect(function()
        dragging = false
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
end

-- Config System
local function EnsureConfigFolder()
    if isfolder and not isfolder(DEFAULT_CONFIG_FOLDER) then
        makefolder(DEFAULT_CONFIG_FOLDER)
    end
end

local function GetAvailableConfigs()
    if not isfolder or not listfiles then return {} end
    EnsureConfigFolder()
    
    local configs = {}
    for _, file in ipairs(listfiles(DEFAULT_CONFIG_FOLDER)) do
        local name = file:match(DEFAULT_CONFIG_FOLDER .. "/(.+)%.json$") or 
                     file:match(DEFAULT_CONFIG_FOLDER .. "\\(.+)%.json$")
        if name then
            table.insert(configs, name)
        end
    end
    return configs
end

-- Acrylic Blur Effect
local AcrylicBlur = {}
AcrylicBlur.__index = AcrylicBlur

function AcrylicBlur.new(object)
    local self = setmetatable({
        _object = object,
        _folder = nil,
        _root = nil,
        _frame = nil,
        _dof = nil,
        _enabled = true,
        _connections = {}
    }, AcrylicBlur)
    self:_Initialize()
    return self
end

function AcrylicBlur:_CreateDepthOfField()
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect.Name == "AcrylicBlur" or effect.Name == "AcrylicBlurEffect" then
            effect:Destroy()
        end
    end
    
    self._dof = CreateInstance("DepthOfFieldEffect", {
        Name = "AcrylicBlur",
        FarIntensity = 0,
        FocusDistance = 0.05,
        InFocusRadius = 0.1,
        NearIntensity = 0.5,
        Parent = Lighting
    })
end

function AcrylicBlur:_CreateFolder()
    local existing = workspace.CurrentCamera:FindFirstChild("AcrylicBlur")
    if existing then existing:Destroy() end
    
    self._folder = CreateInstance("Folder", {
        Name = "AcrylicBlur",
        Parent = workspace.CurrentCamera
    })
end

function AcrylicBlur:_CreateRoot()
    self._root = CreateInstance("Part", {
        Name = "Root",
        Color = Color3.new(0, 0, 0),
        Material = Enum.Material.Glass,
        Size = Vector3.new(1, 1, 0),
        Anchored = true,
        CanCollide = false,
        CanQuery = false,
        Locked = true,
        CastShadow = false,
        Transparency = 0.95,
        Parent = self._folder
    })
    CreateInstance("SpecialMesh", {
        MeshType = Enum.MeshType.Brick,
        Parent = self._root
    })
end

function AcrylicBlur:_CreateFrame()
    self._frame = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Parent = self._object
    })
end

function AcrylicBlur:_Render()
    local function ViewportToWorld(location, dist)
        local ray = workspace.CurrentCamera:ScreenPointToRay(location.X, location.Y)
        return ray.Origin + ray.Direction * dist
    end
    
    local function Update()
        if not self._root or not self._enabled then return end
        
        local offset = (workspace.CurrentCamera.ViewportSize.Y / 2560) * 24 + 4
        local size = self._frame.AbsoluteSize - Vector2.new(offset, offset)
        local position = self._frame.AbsolutePosition + Vector2.new(offset / 2, offset / 2)
        
        local tl = ViewportToWorld(position, 0.001)
        local tr = ViewportToWorld(position + Vector2.new(size.X, 0), 0.001)
        local br = ViewportToWorld(position + size, 0.001)
        
        local width = (tr - tl).Magnitude
        local height = (tr - br).Magnitude
        
        self._root.CFrame = CFrame.fromMatrix(
            (tl + br) / 2,
            workspace.CurrentCamera.CFrame.XVector,
            workspace.CurrentCamera.CFrame.YVector,
            workspace.CurrentCamera.CFrame.ZVector
        )
        self._root.Mesh.Scale = Vector3.new(width, height, 0)
    end
    
    -- Connect to camera changes
    local camera = workspace.CurrentCamera
    local events = {
        {camera, "CFrame"},
        {camera, "ViewportSize"},
        {camera, "FieldOfView"},
        {self._frame, "AbsolutePosition"},
        {self._frame, "AbsoluteSize"}
    }
    
    for _, event in ipairs(events) do
        local connection = event[1]:GetPropertyChangedSignal(event[2]):Connect(Update)
        table.insert(self._connections, connection)
    end
    
    -- Render loop
    local renderConnection = RunService.RenderStepped:Connect(Update)
    table.insert(self._connections, renderConnection)
    
    task.spawn(Update)
end

function AcrylicBlur:_Initialize()
    self:_CreateDepthOfField()
    self:_CreateFolder()
    self:_CreateRoot()
    self:_CreateFrame()
    self:_Render()
end

function AcrylicBlur:SetEnabled(enabled)
    self._enabled = enabled
    if self._root then
        self._root.Transparency = enabled and 0.95 or 1
    end
    if self._dof then
        self._dof.Enabled = enabled
    end
end

function AcrylicBlur:Destroy()
    for _, connection in ipairs(self._connections) do
        connection:Disconnect()
    end
    if self._folder then self._folder:Destroy() end
    if self._dof then self._dof:Destroy() end
end

-- Library Class
local Library = {}
Library.__index = Library

function Library.new(title, configFolder)
    local self = setmetatable({}, Library)
    
    -- Properties
    self.title = title or "Acrylic"
    self.configFolder = configFolder or title or "Acrylic"
    self.sections = {}
    self.currentTab = nil
    self.minimized = false
    self._acrylicBlur = nil
    self._keybinds = {}
    self._toggleKey = Enum.KeyCode.RightShift  -- Changed default to RightShift
    self._visible = true
    self._originalHeight = Sizes.Window.Height
    self._minSize = Vector2.new(Sizes.MinWindow.Width, Sizes.MinWindow.Height)
    self._maxSize = Vector2.new(Sizes.MaxWindow.Width, Sizes.MaxWindow.Height)
    self._mobileToggle = nil
    self._configElements = {}
    self._autoSave = false
    self._currentConfig = "default"
    self._connections = {}
    self._notificationContainer = nil
    
    -- Create UI
    self:_CreateMainWindow()
    self:_SetupKeybindListener()
    self:_SetupMobileSupport()
    self:_CreateNotificationContainer()
    
    return self
end

function Library:_CreateMainWindow()
    -- ScreenGui
    self.screenGui = CreateInstance("ScreenGui", {
        Name = LIBRARY_NAME,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Main Container
    self.container = CreateInstance("Frame", {
        Name = "Container",
        BackgroundColor3 = Colors.Background,
        BackgroundTransparency = 0.05,
        Position = UDim2.new(0.5, -Sizes.Window.Width / 2, 0.5, -Sizes.Window.Height / 2),
        BorderSizePixel = 0,
        Size = UDim2.new(0, Sizes.Window.Width, 0, Sizes.Window.Height),
        ClipsDescendants = false,
        Parent = self.screenGui
    })
    CreateCorner(self.container, 5)
    CreateStroke(self.container)
    
    -- Top Bar
    self.topBar = CreateInstance("Frame", {
        Name = "TopBar",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 45),
        Parent = self.container
    })
    
    -- Title
    self.titleLabel = CreateInstance("TextLabel", {
        Name = "Title",
        FontFace = Fonts.Regular,
        TextColor3 = Colors.Text,
        Text = self.title,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 10),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = TextSizes.Title,
        Size = UDim2.new(0, 150, 0, 25),
        Parent = self.topBar
    })
    
    -- Window Controls
    self:_CreateWindowControls()
    
    -- Separator
    CreateInstance("Frame", {
        Name = "HeaderSeparator",
        BackgroundColor3 = Colors.Border,
        Position = UDim2.new(0, 0, 0, 45),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1),
        Parent = self.container
    })
    
    -- Content Area
    self:_CreateContentArea()
    
    -- Make draggable
    MakeDraggable(self.container, self.topBar)
    
    -- Parent to player
    local player = Players.LocalPlayer
    self.screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Add blur effect
    self._acrylicBlur = AcrylicBlur.new(self.container)
end

function Library:_CreateWindowControls()
    -- Minimize Button
    local minimizeBtn = CreateInstance("ImageLabel", {
        Name = "Minimize",
        ImageColor3 = Colors.TextDark,
        Image = "rbxassetid://82603981310445",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -35, 0, 15),
        Size = UDim2.new(0, 15, 0, 15),
        Parent = self.topBar
    })
    
    local minimizeArea = CreateInstance("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 21, 0, 15),
        Parent = minimizeBtn
    })
    
    minimizeArea.MouseButton1Click:Connect(function()
        self:_ToggleMinimize()
    end)
    
    -- Hover effects
    minimizeBtn.MouseEnter:Connect(function()
        CreateTween(minimizeBtn, {ImageColor3 = Colors.Text}, AnimSpeed.Fast)
    end)
    minimizeBtn.MouseLeave:Connect(function()
        CreateTween(minimizeBtn, {ImageColor3 = Colors.TextDark}, AnimSpeed.Fast)
    end)
    
    -- Close Button
    local closeBtn = CreateInstance("ImageButton", {
        Name = "Close",
        ImageColor3 = Colors.TextDark,
        Image = "rbxassetid://119943770201674",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -10, 0, 15),
        Size = UDim2.new(0, 15, 0, 15),
        Parent = self.topBar
    })
    
    closeBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    closeBtn.MouseEnter:Connect(function()
        CreateTween(closeBtn, {ImageColor3 = Color3.fromRGB(255, 100, 100)}, AnimSpeed.Fast)
    end)
    closeBtn.MouseLeave:Connect(function()
        CreateTween(closeBtn, {ImageColor3 = Colors.TextDark}, AnimSpeed.Fast)
    end)
    
    -- Resize Handle
    local resizeBtn = CreateInstance("ImageButton", {
        Name = "Resize",
        ImageColor3 = Color3.fromRGB(110, 110, 110),
        Image = "rbxassetid://120997033468887",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, -5, 1, -5),
        Size = UDim2.new(0, 62, 0, 60),
        BorderSizePixel = 0,
        Parent = self.container
    })
    
    self.resizeBtn = resizeBtn
    self:_SetupResize(resizeBtn)
end

function Library:_SetupResize(handle)
    local resizing = false
    local resizeStart, startSize
    
    handle.MouseEnter:Connect(function()
        CreateTween(handle, {ImageColor3 = Colors.Text}, AnimSpeed.Fast)
    end)
    
    handle.MouseLeave:Connect(function()
        if not resizing then
            CreateTween(handle, {ImageColor3 = Color3.fromRGB(110, 110, 110)}, AnimSpeed.Fast)
        end
    end)
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeStart = input.Position
            startSize = self.container.AbsoluteSize
        end
    end)
    
    handle.InputEnded:Connect(function()
        resizing = false
        CreateTween(handle, {ImageColor3 = Color3.fromRGB(110, 110, 110)}, AnimSpeed.Fast)
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                         input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - resizeStart
            local newWidth = math.clamp(startSize.X + delta.X, self._minSize.X, self._maxSize.X)
            local newHeight = math.clamp(startSize.Y + delta.Y, self._minSize.Y, self._maxSize.Y)
            self.container.Size = UDim2.new(0, newWidth, 0, newHeight)
            self._originalHeight = newHeight
        end
    end)
end

function Library:_CreateContentArea()
    self.mainContent = CreateInstance("Frame", {
        Name = "MainContent",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 46),
        Size = UDim2.new(1, 0, 1, -46),
        ClipsDescendants = true,
        Parent = self.container
    })
    
    -- Sections sidebar
    self.sectionsContainer = CreateInstance("ScrollingFrame", {
        Name = "SectionsContainer",
        ScrollBarThickness = 0,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 165, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Parent = self.mainContent
    })
    CreateListLayout(self.sectionsContainer, 0, Enum.SortOrder.LayoutOrder)
    CreatePadding(self.sectionsContainer, 5)
    
    -- Separator
    CreateInstance("Frame", {
        Name = "Separator",
        BackgroundColor3 = Colors.Border,
        Position = UDim2.new(0, 165, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 1, 1, 0),
        Parent = self.mainContent
    })
    
    -- Content container
    self.contentContainer = CreateInstance("ScrollingFrame", {
        Name = "ContentContainer",
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 166, 0, 0),
        Size = UDim2.new(1, -166, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Parent = self.mainContent
    })
    CreateListLayout(self.contentContainer, 8, Enum.SortOrder.LayoutOrder)
    CreatePadding(self.contentContainer, 10, 10, 15, 15)
end

function Library:_ToggleMinimize()
    self.minimized = not self.minimized
    if self.minimized then
        if self._acrylicBlur then
            self._acrylicBlur:SetEnabled(false)
        end
        CreateTween(self.mainContent, {Size = UDim2.new(1, 0, 0, 0)}, AnimSpeed.Slow)
        CreateTween(self.container, {Size = UDim2.new(0, self.container.AbsoluteSize.X, 0, 45)}, AnimSpeed.Slow)
        self.resizeBtn.Visible = false
    else
        if self._acrylicBlur then
            self._acrylicBlur:SetEnabled(true)
        end
        CreateTween(self.container, {Size = UDim2.new(0, self.container.AbsoluteSize.X, 0, self._originalHeight)}, AnimSpeed.Slow)
        task.delay(0.1, function()
            CreateTween(self.mainContent, {Size = UDim2.new(1, 0, 1, -46)}, AnimSpeed.Normal)
        end)
        self.resizeBtn.Visible = true
    end
end

function Library:_SetupKeybindListener()
    local connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == self._toggleKey then
            self:Toggle()
        end
        
        for _, keybindData in pairs(self._keybinds) do
            if input.KeyCode == keybindData.key then
                keybindData.callback()
            end
        end
    end)
    table.insert(self._connections, connection)
end

function Library:_SetupMobileSupport()
    -- Don't create mobile button at all - this removes the home button
    self._mobileToggle = nil
end

function Library:_CreateNotificationContainer()
    if self._notificationContainer then return end
    self._notificationContainer = CreateInstance("Frame", {
        Name = "NotificationContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -240, 0, 20),
        Size = UDim2.new(0, 220, 1, -40),
        Parent = self.screenGui
    })
    CreateListLayout(self._notificationContainer, 10, Enum.SortOrder.LayoutOrder, Enum.FillDirection.Vertical)
end

function Library:Notify(config)
    local title = config.Title or "Notification"
    local description = config.Description or ""
    local duration = config.Duration or 3
    local icon = config.Icon or "rbxassetid://10709775704"
    
    local notification = CreateInstance("Frame", {
        Name = "Notification",
        BackgroundColor3 = Colors.Notification.Background,
        Position = UDim2.new(1, 20, 0, 0),
        Size = UDim2.new(1, 0, 0, Sizes.Notification.Height),
        ClipsDescendants = true,
        Parent = self._notificationContainer
    })
    CreateCorner(notification, 4)
    CreateStroke(notification, Colors.Notification.Border)
    
    -- Title
    local titleLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.Text,
        Text = title,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 16),
        TextSize = TextSizes.Normal,
        Size = UDim2.new(1, -60, 0, 19),
        Parent = notification
    })
    
    -- Description
    local descriptionLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.TextDark,
        Text = description,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 38),
        TextSize = TextSizes.Normal,
        Size = UDim2.new(1, -60, 0, 19),
        Parent = notification
    })
    
    -- Icon
    local iconImage = CreateInstance("ImageLabel", {
        BackgroundTransparency = 1,
        Image = icon,
        Position = UDim2.new(1, -33, 0, 23),
        Size = UDim2.new(0, 19, 0, 19),
        Parent = notification
    })
    CreateInstance("UIAspectRatioConstraint", {
        Parent = iconImage
    })
    
    -- Timer
    local timerBar = CreateInstance("Frame", {
        Name = "Timer",
        BackgroundColor3 = Colors.Notification.Timer,
        Position = UDim2.new(0, 0, 1, -3),
        Size = UDim2.new(1, 0, 0, 3),
        Parent = notification
    })
    CreateCorner(timerBar, 100)
    
    -- Animations
    CreateTween(notification, {Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    CreateTween(timerBar, {Size = UDim2.new(0, 0, 0, 3)}, duration, Enum.EasingStyle.Linear)
    
    task.delay(duration, function()
        CreateTween(notification, {Position = UDim2.new(1, 20, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.3)
        notification:Destroy()
    end)
    
    return notification
end

function Library:Toggle()
    self._visible = not self._visible
    self.container.Visible = self._visible
    
    if self._acrylicBlur then
        self._acrylicBlur:SetEnabled(self._visible)
    end
end

function Library:SetToggleKey(keyCode)
    self._toggleKey = keyCode
end

function Library:Destroy()
    if self._autoSave then
        self:SaveConfig(self._currentConfig)
    end
    
    for _, connection in ipairs(self._connections) do
        connection:Disconnect()
    end
    
    if self._acrylicBlur then
        self._acrylicBlur:Destroy()
    end
    
    if self.screenGui then
        self.screenGui:Destroy()
    end
end

-- Config System Methods
function Library:_RegisterConfigElement(id, elementType, getValue, setValue)
    self._configElements[id] = {
        type = elementType,
        getValue = getValue,
        setValue = setValue
    }
end

function Library:SaveConfig(configName)
    if not writefile then
        self:Notify({
            Title = "Error",
            Description = "Config system not supported",
            Duration = 3
        })
        return false
    end
    
    EnsureConfigFolder()
    
    local configData = {}
    for id, element in pairs(self._configElements) do
        local value = element.getValue()
        
        if typeof(value) == "Color3" then
            value = {R = value.R, G = value.G, B = value.B, _type = "Color3"}
        elseif typeof(value) == "EnumItem" then
            value = {_type = "EnumItem", _enum = tostring(value.EnumType), _value = value.Name}
        end
        
        configData[id] = value
    end
    
    local success, err = pcall(function()
        writefile(DEFAULT_CONFIG_FOLDER .. "/" .. configName .. ".json", 
                 HttpService:JSONEncode(configData))
    end)
    
    if success then
        self._currentConfig = configName
        self:Notify({
            Title = "Config Saved",
            Description = "Saved as: " .. configName,
            Duration = 2,
            Icon = "rbxassetid://10723356507"
        })
        return true
    else
        self:Notify({
            Title = "Error",
            Description = "Failed to save config: " .. tostring(err),
            Duration = 3
        })
        return false
    end
end

function Library:LoadConfig(configName)
    if not readfile or not isfile then
        self:Notify({
            Title = "Error",
            Description = "Config system not supported",
            Duration = 3
        })
        return false
    end
    
    local path = DEFAULT_CONFIG_FOLDER .. "/" .. configName .. ".json"
    if not isfile(path) then
        self:Notify({
            Title = "Error",
            Description = "Config not found: " .. configName,
            Duration = 3
        })
        return false
    end
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    
    if not success or not data then
        self:Notify({
            Title = "Error",
            Description = "Failed to load config",
            Duration = 3
        })
        return false
    end
    
    for id, value in pairs(data) do
        if self._configElements[id] then
            if type(value) == "table" and value._type == "Color3" then
                value = Color3.new(value.R, value.G, value.B)
            elseif type(value) == "table" and value._type == "EnumItem" then
                value = Enum[value._enum][value._value]
            end
            
            pcall(function()
                self._configElements[id].setValue(value)
            end)
        end
    end
    
    self._currentConfig = configName
    self:Notify({
        Title = "Config Loaded",
        Description = "Loaded: " .. configName,
        Duration = 2,
        Icon = "rbxassetid://10723356507"
    })
    return true
end

function Library:DeleteConfig(configName)
    if not delfile or not isfile then
        return false
    end
    
    local path = DEFAULT_CONFIG_FOLDER .. "/" .. configName .. ".json"
    if isfile(path) then
        delfile(path)
        self:Notify({
            Title = "Config Deleted",
            Description = "Deleted: " .. configName,
            Duration = 2
        })
        return true
    end
    return false
end

function Library:GetConfigs()
    return GetAvailableConfigs()
end

function Library:SetAutoSave(enabled)
    self._autoSave = enabled
    if enabled then
        task.spawn(function()
            while self._autoSave and self.screenGui and self.screenGui.Parent do
                task.wait(30)
                if self._autoSave then
                    self:SaveConfig(self._currentConfig)
                end
            end
        end)
    end
end

-- Section and Tab Creation
function Library:CreateSection(name)
    local section = {
        name = name,
        tabs = {},
        expanded = true,
        _library = self
    }
    
    -- Section frame
    local sectionFrame = CreateInstance("Frame", {
        Name = "Section_" .. name,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = self.sectionsContainer
    })
    CreateListLayout(sectionFrame, 2, Enum.SortOrder.LayoutOrder)
    
    -- Header
    local headerContainer = CreateInstance("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 25),
        LayoutOrder = 0,
        Parent = sectionFrame
    })
    
    local headerBtn = CreateInstance("TextButton", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.TextDark,
        Text = "",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = headerContainer
    })
    
    local headerLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.TextDark,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 5, 0, 0),
        TextSize = TextSizes.Small,
        Size = UDim2.new(1, -25, 1, 0),
        Parent = headerContainer
    })
    
    local arrow = CreateInstance("ImageButton", {
        Image = "rbxassetid://105558791071013",
        ImageColor3 = Colors.TextDark,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 0.5, -7),
        Size = UDim2.new(0, 15, 0, 15),
        Rotation = 0,
        Parent = headerContainer
    })
    
    -- Tabs container
    local tabsContainer = CreateInstance("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        LayoutOrder = 1,
        Parent = sectionFrame
    })
    CreateListLayout(tabsContainer, 2, Enum.SortOrder.LayoutOrder)
    CreatePadding(tabsContainer, 0, 0, 15, 0)
    
    local function ToggleSection()
        section.expanded = not section.expanded
        CreateTween(arrow, {Rotation = section.expanded and 0 or 180}, AnimSpeed.Normal)
        tabsContainer.Visible = section.expanded
    end
    
    headerBtn.MouseButton1Click:Connect(ToggleSection)
    arrow.MouseButton1Click:Connect(ToggleSection)
    
    section.frame = sectionFrame
    section.tabsContainer = tabsContainer
    table.insert(self.sections, section)
    
    return setmetatable({
        _section = section,
        _library = self,
        
        CreateTab = function(_, tabName, icon)
            return self:_CreateTab(section, tabName, icon)
        end
    }, {__index = function(t, k)
        return section[k]
    end})
end

function Library:_CreateTab(section, name, icon)
    local tab = {
        name = name,
        elements = {},
        _library = self
    }
    
    -- Tab button
    local tabBtn = CreateInstance("Frame", {
        Name = name,
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(0, Sizes.Tab.Width, 0, Sizes.Tab.Height),
        Parent = section.tabsContainer
    })
    CreateCorner(tabBtn, 5)
    
    local tabStroke = CreateStroke(tabBtn, Colors.Border, 1)
    
    local iconLabel = CreateInstance("ImageLabel", {
        BackgroundTransparency = 1,
        Image = icon or "rbxassetid://112235310154264",
        ImageColor3 = Colors.TextDark,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 11, 0.5, 0),
        Size = UDim2.new(0, 15, 0, 15),
        Parent = tabBtn
    })
    
    local tabText = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.TextDark,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 33, 0, 0),
        Size = UDim2.new(1, -42, 1, 0),
        TextSize = TextSizes.Small,
        Parent = tabBtn
    })
    CreateInstance("UIPadding", {
        PaddingRight = UDim.new(0, 9),
        Parent = tabText
    })
    
    local textGradient = CreateInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Colors.TextDark),
            ColorSequenceKeypoint.new(0.65, Colors.TextDark),
            ColorSequenceKeypoint.new(1, Colors.TextFade)
        }),
        Parent = tabText
    })
    
    -- Click handler
    local clickBtn = CreateInstance("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = tabBtn
    })
    
    -- Content frame
    tab.content = CreateInstance("Frame", {
        Name = name .. "_Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = self.contentContainer
    })
    CreateListLayout(tab.content, 8, Enum.SortOrder.LayoutOrder)
    
    -- Click handler
    clickBtn.MouseButton1Click:Connect(function()
        self:_SelectTab(tab, tabBtn, tabStroke, iconLabel, tabText, textGradient)
    end)
    
    -- Hover effects
    clickBtn.MouseEnter:Connect(function()
        if self.currentTab ~= tab then
            CreateTween(tabBtn, {BackgroundTransparency = 0.7}, AnimSpeed.Fast)
        end
    end)
    
    clickBtn.MouseLeave:Connect(function()
        if self.currentTab ~= tab then
            CreateTween(tabBtn, {BackgroundTransparency = 1}, AnimSpeed.Fast)
        end
    end)
    
    tab.button = tabBtn
    tab.stroke = tabStroke
    tab.icon = iconLabel
    tab.textLabel = tabText
    tab.textGradient = textGradient
    
    table.insert(section.tabs, tab)
    
    -- Select first tab
    if not self.currentTab then
        self:_SelectTab(tab, tabBtn, tabStroke, iconLabel, tabText, textGradient)
    end
    
    -- Return tab methods
    return setmetatable({
        _tab = tab,
        _library = self,
        
        CreateSection = function(_, sectionName)
            return self:_CreateContentSection(tab, sectionName)
        end,
        
        CreateParagraph = function(_, config)
            return self:_CreateParagraph(tab, config)
        end,
        
        CreateSlider = function(_, config)
            return self:_CreateSlider(tab, config)
        end,
        
        CreateButton = function(_, config)
            return self:_CreateButton(tab, config)
        end,
        
        CreateToggle = function(_, config)
            return self:_CreateToggle(tab, config)
        end,
        
        CreateDropdown = function(_, config)
            return self:_CreateDropdown(tab, config)
        end,
        
        CreateKeybind = function(_, config)
            return self:_CreateKeybind(tab, config)
        end,
        
        CreateColorPicker = function(_, config)
            return self:_CreateColorPicker(tab, config)
        end,
        
        CreateTextBox = function(_, config)
            return self:_CreateTextBox(tab, config)
        end,
        
        CreateConfigSection = function(_)
            return self:_CreateConfigSection(tab)
        end
    }, {__index = function(t, k)
        return tab[k]
    end})
end

function Library:_SelectTab(tab, btn, stroke, icon, textLabel, textGradient)
    -- Deselect current tab
    if self.currentTab then
        self.currentTab.content.Visible = false
        CreateTween(self.currentTab.button, {BackgroundTransparency = 1}, AnimSpeed.Fast)
        CreateTween(self.currentTab.icon, {ImageColor3 = Colors.TextDark}, AnimSpeed.Fast)
        self.currentTab.stroke.Transparency = 1
        if self.currentTab.textGradient then
            self.currentTab.textGradient.Enabled = true
        end
    end
    
    -- Select new tab
    self.currentTab = tab
    tab.content.Visible = true
    CreateTween(btn, {BackgroundTransparency = 1}, AnimSpeed.Fast)
    CreateTween(icon, {ImageColor3 = Colors.Text}, AnimSpeed.Fast)
    stroke.Transparency = 1
    if textGradient then
        textGradient.Enabled = false
    end
    textLabel.TextColor3 = Colors.Text
end

-- UI Element Creation Methods
function Library:_CreateContentSection(tab, name)
    return CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.TextDark,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        TextSize = 15,
        Size = UDim2.new(1, 0, 0, 25),
        Parent = tab.content
    })
end

function Library:_CreateParagraph(tab, config)
    local title = config.Title or "Paragraph"
    local content = config.Content or "Description text here."
    
    local frame = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = tab.content
    })
    CreateCorner(frame, 5)
    CreateStroke(frame)
    CreatePadding(frame, 10)
    
    local titleLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.Text,
        Text = title,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        TextSize = TextSizes.Normal,
        Size = UDim2.new(1, 0, 0, 20),
        Parent = frame
    })
    
    local contentLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.TextDark,
        Text = content,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        BackgroundTransparency = 1,
        TextSize = TextSizes.Small,
        Position = UDim2.new(0, 0, 0, 22),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = frame
    })
    
    return {
        SetTitle = function(_, newTitle)
            titleLabel.Text = newTitle
        end,
        SetContent = function(_, newContent)
            contentLabel.Text = newContent
        end
    }
end

function Library:_CreateSlider(tab, config)
    local name = config.Name or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or 50
    local callback = config.Callback or function() end
    local flag = config.Flag
    local currentValue = default
    
    local frame = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, Sizes.Slider.Height),
        Parent = tab.content
    })
    CreateCorner(frame, 5)
    CreateStroke(frame)
    
    local nameLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.Text,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 5),
        TextSize = TextSizes.Normal,
        Size = UDim2.new(0, 200, 0, 20),
        Parent = frame
    })
    
    local valueLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.Text,
        Text = tostring(currentValue),
        TextXAlignment = Enum.TextXAlignment.Right,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -60, 0, 5),
        TextSize = TextSizes.Normal,
        Size = UDim2.new(0, 50, 0, 20),
        Parent = frame
    })
    
    local sliderBg = CreateInstance("Frame", {
        BackgroundColor3 = Color3.fromRGB(11, 11, 11),
        Position = UDim2.new(0, 10, 0, 29),
        BorderSizePixel = 0,
        Size = UDim2.new(1, -20, 0, 7),
        Parent = frame
    })
    CreateCorner(sliderBg, 100)
    
    local sliderFill = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        Parent = sliderBg
    })
    CreateCorner(sliderFill, 100)
    
    local dragging = false
    
    local function UpdateSlider(input)
        local pos = input.Position
        local framePos = sliderBg.AbsolutePosition
        local frameSize = sliderBg.AbsoluteSize
        local relativeX = math.clamp((pos.X - framePos.X) / frameSize.X, 0, 1)
        currentValue = math.floor(min + (max - min) * relativeX)
        CreateTween(sliderFill, {Size = UDim2.new(relativeX, 0, 1, 0)}, 0.05)
        valueLabel.Text = tostring(currentValue)
        callback(currentValue)
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateSlider(input)
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                         input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)
    
    local methods = {
        SetValue = function(_, value)
            currentValue = math.clamp(value, min, max)
            local relativeX = (currentValue - min) / (max - min)
            sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            valueLabel.Text = tostring(currentValue)
            callback(currentValue)
        end,
        GetValue = function()
            return currentValue
        end
    }
    
    if flag then
        self:_RegisterConfigElement(flag, "Slider", 
            function() return currentValue end,
            function(value) methods:SetValue(value) end
        )
    end
    
    return methods
end

function Library:_CreateButton(tab, config)
    local name = config.Name or "Button"
    local callback = config.Callback or function() end
    
    local frame = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, Sizes.Button.Height),
        Parent = tab.content
    })
    CreateCorner(frame, 5)
    CreateStroke(frame)
    
    local nameLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.Text,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -10),
        TextSize = TextSizes.Normal,
        Size = UDim2.new(0, 200, 0, 20),
        Parent = frame
    })
    
    local icon = CreateInstance("ImageLabel", {
        BackgroundTransparency = 1,
        Image = "rbxassetid://10734898355",
        ImageColor3 = Colors.Text,
        Position = UDim2.new(1, -30, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Parent = frame
    })
    CreateInstance("UIAspectRatioConstraint", {
        Parent = icon
    })
    
    local button = CreateInstance("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = frame
    })
    
    button.MouseButton1Click:Connect(function()
        CreateTween(frame, {BackgroundTransparency = 0.2}, AnimSpeed.Fast)
        task.wait(0.1)
        CreateTween(frame, {BackgroundTransparency = 0.4}, AnimSpeed.Fast)
        callback()
    end)
    
    return {
        SetText = function(_, text)
            nameLabel.Text = text
        end
    }
end

function Library:_CreateToggle(tab, config)
    local name = config.Name or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end
    local flag = config.Flag
    local enabled = default
    
    local frame = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, Sizes.Button.Height),
        Parent = tab.content
    })
    CreateCorner(frame, 5)
    CreateStroke(frame)
    
    local nameLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.Text,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -10),
        TextSize = TextSizes.Normal,
        Size = UDim2.new(0, 200, 0, 20),
        Parent = frame
    })
    
    local switchBg = CreateInstance("Frame", {
        BackgroundColor3 = enabled and Colors.Toggle.Enabled or Colors.Toggle.Disabled,
        Position = UDim2.new(1, -48, 0.5, -10),
        BorderSizePixel = 0,
        Size = UDim2.new(0, Sizes.Toggle.Width, 0, Sizes.Toggle.Height),
        Parent = frame
    })
    CreateCorner(switchBg, 100)
    
    local switchCircle = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Toggle.Circle,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = enabled and UDim2.new(0, 21, 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(0, Sizes.Toggle.Circle, 0, Sizes.Toggle.Circle),
        Parent = switchBg
    })
    CreateCorner(switchCircle, 100)
    
    local toggleBtn = CreateInstance("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = switchCircle
    })
    
    local button = CreateInstance("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = frame
    })
    
    local function UpdateToggle()
        if enabled then
            CreateTween(switchBg, {BackgroundColor3 = Colors.Toggle.Enabled}, AnimSpeed.Normal)
            CreateTween(switchCircle, {Position = UDim2.new(0, 21, 0.5, 0)}, AnimSpeed.Normal)
        else
            CreateTween(switchBg, {BackgroundColor3 = Colors.Toggle.Disabled}, AnimSpeed.Normal)
            CreateTween(switchCircle, {Position = UDim2.new(0, 4, 0.5, 0)}, AnimSpeed.Normal)
        end
    end
    
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        UpdateToggle()
        callback(enabled)
    end)
    
    local methods = {
        SetValue = function(_, value)
            enabled = value
            UpdateToggle()
            callback(enabled)
        end,
        GetValue = function()
            return enabled
        end
    }
    
    if flag then
        self:_RegisterConfigElement(flag, "Toggle", 
            function() return enabled end,
            function(value) methods:SetValue(value) end
        )
    end
    
    return methods
end

function Library:_CreateDropdown(tab, config)
    local name = config.Name or "Dropdown"
    local options = config.Options or {"Option 1", "Option 2", "Option 3"}
    local default = config.Default or options[1]
    local multiSelect = config.MultiSelect or false
    local callback = config.Callback or function() end
    local flag = config.Flag
    local selected = multiSelect and {} or default
    local expanded = false
    
    if multiSelect and type(default) == "table" then
        selected = default
    elseif multiSelect then
        selected = {}
    end
    
    local frame = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, Sizes.Dropdown.Height),
        ClipsDescendants = false,
        ZIndex = 1,
        Parent = tab.content
    })
    CreateCorner(frame, 5)
    CreateStroke(frame)
    
    local nameLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.Text,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 10),
        TextSize = TextSizes.Normal,
        Size = UDim2.new(0, 200, 0, 20),
        ZIndex = 1,
        Parent = frame
    })
    
    local selectedDisplay = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.04,
        Position = UDim2.new(1, -145, 0, 6),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 135, 0, 26),
        ZIndex = 2,
        Parent = frame
    })
    CreateCorner(selectedDisplay, 5)
    CreateStroke(selectedDisplay)
    
    local selectedLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.Text,
        Text = multiSelect and (#selected > 0 and table.concat(selected, ", ") or "None") or tostring(selected),
        TextTruncate = Enum.TextTruncate.AtEnd,
        BackgroundTransparency = 1,
        TextSize = TextSizes.Small,
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
        Parent = selectedDisplay
    })
    
    local arrow = CreateInstance("ImageLabel", {
        Image = "rbxassetid://105558791071013",
        ImageColor3 = Colors.TextDark,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 0.5, -5),
        Size = UDim2.new(0, 10, 0, 10),
        Rotation = 0,
        ZIndex = 2,
        Parent = selectedDisplay
    })
    
    local maxVisibleOptions = 5
    local totalOptionsHeight = math.min(#options * Sizes.Dropdown.OptionHeight, maxVisibleOptions * Sizes.Dropdown.OptionHeight)
    
    local optionsContainer = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.04,
        Position = UDim2.new(1, -145, 0, 38),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 135, 0, totalOptionsHeight),
        Visible = false,
        ZIndex = 100,
        ClipsDescendants = true,
        Parent = frame
    })
    CreateCorner(optionsContainer, 5)
    CreateStroke(optionsContainer)
    
    local optionsScroll = CreateInstance("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, #options * Sizes.Dropdown.OptionHeight),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60),
        ZIndex = 100,
        Parent = optionsContainer
    })
    CreateListLayout(optionsScroll, 0, Enum.SortOrder.LayoutOrder)
    
    local function UpdateSelectedText()
        if multiSelect then
            selectedLabel.Text = #selected > 0 and table.concat(selected, ", ") or "None"
        else
            selectedLabel.Text = tostring(selected)
        end
    end
    
    local function CreateOptionButton(option)
        local optionBtn = CreateInstance("TextButton", {
            Name = option,
            FontFace = Fonts.Regular,
            TextColor3 = Colors.Text,
            Text = option,
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            TextSize = TextSizes.Small,
            Size = UDim2.new(1, 0, 0, Sizes.Dropdown.OptionHeight),
            ZIndex = 100,
            Parent = optionsScroll
        })
        
        optionBtn.MouseEnter:Connect(function()
            CreateTween(optionBtn, {BackgroundTransparency = 0.5}, AnimSpeed.Fast)
        end)
        
        optionBtn.MouseLeave:Connect(function()
            CreateTween(optionBtn, {BackgroundTransparency = 1}, AnimSpeed.Fast)
        end)
        
        optionBtn.MouseButton1Click:Connect(function()
            if multiSelect then
                local index = table.find(selected, option)
                if index then
                    table.remove(selected, index)
                else
                    table.insert(selected, option)
                end
                UpdateSelectedText()
                callback(selected)
            else
                selected = option
                UpdateSelectedText()
                callback(selected)
                expanded = false
                optionsContainer.Visible = false
                CreateTween(arrow, {Rotation = 0}, AnimSpeed.Normal)
                frame.ZIndex = 1
            end
        end)
        
        return optionBtn
    end
    
    for _, option in ipairs(options) do
        CreateOptionButton(option)
    end
    
    local toggleBtn = CreateInstance("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 3,
        Parent = selectedDisplay
    })
    
    toggleBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        optionsContainer.Visible = expanded
        CreateTween(arrow, {Rotation = expanded and 180 or 0}, AnimSpeed.Normal)
        frame.ZIndex = expanded and 10 or 1
    end)
    
    local methods = {
        SetValue = function(_, value)
            if multiSelect and type(value) == "table" then
                selected = value
            elseif not multiSelect then
                selected = value
            end
            UpdateSelectedText()
            callback(selected)
        end,
        GetValue = function()
            return selected
        end,
        Refresh = function(_, newOptions)
            options = newOptions
            for _, child in ipairs(optionsScroll:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            for _, option in ipairs(options) do
                CreateOptionButton(option)
            end
            optionsScroll.CanvasSize = UDim2.new(0, 0, 0, #options * Sizes.Dropdown.OptionHeight)
            local newTotalHeight = math.min(#options * Sizes.Dropdown.OptionHeight, maxVisibleOptions * Sizes.Dropdown.OptionHeight)
            optionsContainer.Size = UDim2.new(0, 135, 0, newTotalHeight)
        end
    }
    
    if flag then
        self:_RegisterConfigElement(flag, "Dropdown", 
            function() return selected end,
            function(value) methods:SetValue(value) end
        )
    end
    
    return methods
end

function Library:_CreateKeybind(tab, config)
    local name = config.Name or "Keybind"
    local default = config.Default or Enum.KeyCode.F
    local callback = config.Callback or function() end
    local flag = config.Flag
    local currentKey = default
    local listening = false
    
    local frame = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, Sizes.Button.Height),
        Parent = tab.content
    })
    CreateCorner(frame, 5)
    CreateStroke(frame)
    
    local nameLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.Text,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -10),
        TextSize = TextSizes.Normal,
        Size = UDim2.new(0, 200, 0, 20),
        Parent = frame
    })
    
    local keybindBox = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.04,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 30, 0, 26),
        Parent = frame
    })
    CreateCorner(keybindBox, 5)
    CreateStroke(keybindBox)
    
    local keyLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.Text,
        Text = currentKey.Name,
        BackgroundTransparency = 1,
        TextSize = TextSizes.Normal,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = keybindBox
    })
    
    local button = CreateInstance("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = keybindBox
    })
    
    local keybindId = name .. "_" .. tostring(tick())
    
    self._keybinds[keybindId] = {
        key = currentKey,
        callback = callback
    }
    
    local function UpdateKeyDisplay()
        if listening then
            keyLabel.Text = "..."
            keybindBox.Size = UDim2.new(0, 43, 0, 26)
        else
            local keyName = currentKey.Name
            local textWidth = math.max(#keyName * 9 + 10, 24)
            keybindBox.Size = UDim2.new(0, textWidth, 0, 26)
            keyLabel.Text = keyName
        end
    end
    
    button.MouseButton1Click:Connect(function()
        listening = true
        UpdateKeyDisplay()
    end)
    
    local inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            currentKey = input.KeyCode
            listening = false
            self._keybinds[keybindId].key = currentKey
            UpdateKeyDisplay()
        end
    end)
    table.insert(self._connections, inputConnection)
    UpdateKeyDisplay()
    
    local methods = {
        SetKey = function(_, keyCode)
            currentKey = keyCode
            self._keybinds[keybindId].key = currentKey
            UpdateKeyDisplay()
        end,
        GetKey = function()
            return currentKey
        end
    }
    
    if flag then
        self:_RegisterConfigElement(flag, "Keybind", 
            function() return currentKey end,
            function(value) methods:SetKey(value) end
        )
    end
    
    return methods
end

function Library:_CreateColorPicker(tab, config)
    local name = config.Name or "Color Picker"
    local default = config.Default or Color3.fromRGB(255, 255, 255)
    local callback = config.Callback or function() end
    local flag = config.Flag
    local currentColor = default
    local hue, sat, val = currentColor:ToHSV()
    local expanded = false
    local activePicker = nil
    
    local frame = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, Sizes.Button.Height),
        Parent = tab.content
    })
    CreateCorner(frame, 6)
    CreateStroke(frame)
    
    local nameLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.Text,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        TextSize = TextSizes.Normal,
        Size = UDim2.new(1, -50, 1, 0),
        Parent = frame
    })
    
    local colorPreview = CreateInstance("Frame", {
        BackgroundColor3 = currentColor,
        Position = UDim2.new(1, -45, 0.5, -8),
        Size = UDim2.new(0, 35, 0, 16),
        ZIndex = 2,
        Parent = frame
    })
    CreateCorner(colorPreview, 4)
    CreateStroke(colorPreview)
    
    local previewBtn = CreateInstance("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 3,
        Parent = colorPreview
    })
    
    -- Picker Container
    local pickerContainer = CreateInstance("Frame", {
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 160, 0, 115),
        Visible = false,
        ZIndex = 3000,
        Parent = tab.content:FindFirstAncestorOfClass("ScreenGui") or tab.content
    })
    CreateCorner(pickerContainer, 6)
    CreateStroke(pickerContainer, Color3.fromRGB(40, 40, 40))
    
    -- SV Picker
    local svPicker = CreateInstance("Frame", {
        BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(1, -16, 0, 85),
        ZIndex = 3001,
        Parent = pickerContainer
    })
    CreateCorner(svPicker, 4)
    
    local whiteLayer = CreateInstance("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1),
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 3002,
        Parent = svPicker
    })
    CreateCorner(whiteLayer, 4)
    CreateInstance("UIGradient", {
        Color = ColorSequence.new(Color3.new(1, 1, 1)),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        }),
        Parent = whiteLayer
    })
    
    local blackLayer = CreateInstance("Frame", {
        BackgroundColor3 = Color3.new(0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 3003,
        Parent = svPicker
    })
    CreateCorner(blackLayer, 4)
    CreateInstance("UIGradient", {
        Color = ColorSequence.new(Color3.new(0, 0, 0)),
        Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0)
        }),
        Parent = blackLayer
    })
    
    local svCursor = CreateInstance("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(sat, 0, 1 - val, 0),
        Size = UDim2.new(0, 10, 0, 10),
        ZIndex = 3005,
        Parent = svPicker
    })
    CreateCorner(svCursor, 100)
    CreateStroke(svCursor, Color3.new(1, 1, 1), 1.5)
    
    -- Hue Slider
    local hueSlider = CreateInstance("Frame", {
        Position = UDim2.new(0, 8, 0, 98),
        Size = UDim2.new(1, -16, 0, 8),
        ZIndex = 3001,
        Parent = pickerContainer
    })
    CreateCorner(hueSlider, 100)
    CreateInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
            ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
            ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
            ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
            ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
        }),
        Parent = hueSlider
    })
    
    local hueCursor = CreateInstance("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(hue, 0, 0.5, 0),
        Size = UDim2.new(0, 10, 0, 10),
        ZIndex = 3005,
        Parent = hueSlider
    })
    CreateCorner(hueCursor, 100)
    CreateStroke(hueCursor, Color3.fromRGB(50, 20, 20))
    
    local function UpdateColor()
        currentColor = Color3.fromHSV(hue, sat, val)
        colorPreview.BackgroundColor3 = currentColor
        svPicker.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        svCursor.Position = UDim2.new(sat, 0, 1 - val, 0)
        hueCursor.Position = UDim2.new(hue, 0, 0.5, 0)
        callback(currentColor)
    end
    
    local svDragging, hueDragging = false, false
    
    local function ProcessInput(input)
        if not pickerContainer.Visible then return end
        
        if svDragging then
            local size = svPicker.AbsoluteSize
            local pos = svPicker.AbsolutePosition
            sat = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
            val = 1 - math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1)
            UpdateColor()
        elseif hueDragging then
            local size = hueSlider.AbsoluteSize
            local pos = hueSlider.AbsolutePosition
            hue = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
            UpdateColor()
        end
    end
    
    svPicker.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            svDragging = true
            ProcessInput(input)
        end
    end)
    
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = true
            ProcessInput(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            ProcessInput(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            svDragging = false
            hueDragging = false
        end
    end)
    
    local function ClosePicker()
        pickerContainer.Visible = false
        expanded = false
        if activePicker then
            activePicker = nil
        end
    end
    
    local function OpenPicker()
        if activePicker then
            activePicker()
        end
        activePicker = ClosePicker
        
        local btnPos = colorPreview.AbsolutePosition
        local viewport = workspace.CurrentCamera.ViewportSize
        local targetX = btnPos.X - 170
        local targetY = btnPos.Y
        
        if targetY + 115 > viewport.Y then
            targetY = viewport.Y - 125
        end
        if targetX < 0 then
            targetX = btnPos.X + 50
        end
        
        pickerContainer.Position = UDim2.new(0, targetX, 0, targetY)
        pickerContainer.Visible = true
        expanded = true
    end
    
    previewBtn.MouseButton1Click:Connect(function()
        if expanded then
            ClosePicker()
        else
            OpenPicker()
        end
    end)
    
    local methods = {
        SetColor = function(_, color)
            currentColor = color
            hue, sat, val = color:ToHSV()
            UpdateColor()
        end,
        GetColor = function()
            return currentColor
        end
    }
    
    if flag then
        self:_RegisterConfigElement(flag, "ColorPicker", 
            function() return currentColor end,
            function(value) methods:SetColor(value) end
        )
    end
    
    return methods
end

function Library:_CreateTextBox(tab, config)
    local name = config.Name or "TextBox"
    local default = config.Default or ""
    local placeholder = config.Placeholder or "Enter text..."
    local callback = config.Callback or function() end
    local clearOnFocus = config.ClearOnFocus or false
    local numbersOnly = config.NumbersOnly or false
    local flag = config.Flag
    local currentText = default
    
    local frame = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, Sizes.TextBox.Height),
        Parent = tab.content
    })
    CreateCorner(frame, 5)
    CreateStroke(frame)
    
    local nameLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.Text,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -10),
        TextSize = TextSizes.Normal,
        Size = UDim2.new(0, 150, 0, 20),
        Parent = frame
    })
    
    local icon = CreateInstance("ImageLabel", {
        BackgroundTransparency = 1,
        Image = "rbxassetid://93828793199781",
        ImageColor3 = Colors.TextDark,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -165, 0.5, 0),
        Size = UDim2.new(0, 18, 0, 18),
        Parent = frame
    })
    
    local textBoxContainer = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.04,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(0, Sizes.TextBox.InputWidth, 0, 26),
        Parent = frame
    })
    CreateCorner(textBoxContainer, 5)
    local textBoxStroke = CreateStroke(textBoxContainer)
    
    local textBox = CreateInstance("TextBox", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.Text,
        PlaceholderText = placeholder,
        PlaceholderColor3 = Colors.TextDark,
        Text = currentText,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        BackgroundTransparency = 1,
        TextSize = TextSizes.Small,
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        ClearTextOnFocus = clearOnFocus,
        Parent = textBoxContainer
    })
    
    textBox.Focused:Connect(function()
        CreateTween(textBoxContainer, {BackgroundTransparency = 0}, AnimSpeed.Fast)
        CreateTween(textBoxStroke, {Color = Colors.Accent}, AnimSpeed.Fast)
        CreateTween(icon, {ImageColor3 = Colors.Text}, AnimSpeed.Fast)
    end)
    
    textBox.FocusLost:Connect(function(enterPressed)
        CreateTween(textBoxContainer, {BackgroundTransparency = 0.04}, AnimSpeed.Fast)
        CreateTween(textBoxStroke, {Color = Colors.Border}, AnimSpeed.Fast)
        CreateTween(icon, {ImageColor3 = Colors.TextDark}, AnimSpeed.Fast)
        
        if numbersOnly then
            local numValue = tonumber(textBox.Text)
            if numValue then
                currentText = tostring(numValue)
                textBox.Text = currentText
            else
                textBox.Text = currentText
            end
        else
            currentText = textBox.Text
        end
        
        callback(currentText, enterPressed)
    end)
    
    if numbersOnly then
        textBox:GetPropertyChangedSignal("Text"):Connect(function()
            local text = textBox.Text
            local filtered = text:gsub("[^%d%.%-]", "")
            if text ~= filtered then
                textBox.Text = filtered
            end
        end)
    end
    
    local methods = {
        SetText = function(_, text)
            currentText = tostring(text)
            textBox.Text = currentText
        end,
        GetText = function()
            return currentText
        end,
        SetPlaceholder = function(_, newPlaceholder)
            textBox.PlaceholderText = newPlaceholder
        end,
        Focus = function()
            textBox:CaptureFocus()
        end
    }
    
    if flag then
        self:_RegisterConfigElement(flag, "TextBox", 
            function() return currentText end,
            function(value) methods:SetText(value) end
        )
    end
    
    return methods
end

function Library:_CreateConfigSection(tab)
    self:_CreateContentSection(tab, "Configuration")
    
    local lib = self
    
    -- Config name input
    local configNameBox = self:_CreateTextBox(tab, {
        Name = "Config Name",
        Default = "default",
        Placeholder = "Enter config name...",
        Callback = function(text)
            lib._currentConfig = text
        end
    })
    
    -- Config dropdown
    local configDropdown = self:_CreateDropdown(tab, {
        Name = "Select Config",
        Options = lib:GetConfigs(),
        Default = "default",
        Callback = function(selected)
            configNameBox:SetText(selected)
            lib._currentConfig = selected
        end
    })
    
    -- Save button
    self:_CreateButton(tab, {
        Name = "Save Config",
        Callback = function()
            local configName = configNameBox:GetText()
            if configName and configName ~= "" then
                lib:SaveConfig(configName)
                configDropdown:Refresh(lib:GetConfigs())
            end
        end
    })
    
    -- Load button
    self:_CreateButton(tab, {
        Name = "Load Config",
        Callback = function()
            local configName = configNameBox:GetText()
            if configName and configName ~= "" then
                lib:LoadConfig(configName)
            end
        end
    })
    
    -- Delete button
    self:_CreateButton(tab, {
        Name = "Delete Config",
        Callback = function()
            local configName = configNameBox:GetText()
            if configName and configName ~= "" then
                lib:DeleteConfig(configName)
                configDropdown:Refresh(lib:GetConfigs())
            end
        end
    })
    
    -- Refresh button
    self:_CreateButton(tab, {
        Name = "Refresh Configs",
        Callback = function()
            configDropdown:Refresh(lib:GetConfigs())
            lib:Notify({
                Title = "Configs Refreshed",
                Description = "Config list updated",
                Duration = 2,
                Icon = "rbxassetid://10723356507"
            })
        end
    })
    
    -- Auto-save toggle
    self:_CreateToggle(tab, {
        Name = "Auto Save",
        Default = false,
        Callback = function(enabled)
            lib:SetAutoSave(enabled)
        end
    })
    
    return {
        RefreshConfigs = function()
            configDropdown:Refresh(lib:GetConfigs())
        end
    }
end

return Library
