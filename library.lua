-- Acrylic UI Library v3.0
-- Premium Modern Design

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Modern Color Scheme
local Colors = {
    -- Main Theme (Dark Glass)
    Background = Color3.fromRGB(18, 18, 22),
    Secondary = Color3.fromRGB(28, 28, 34),
    Tertiary = Color3.fromRGB(38, 38, 46),
    
    -- Accents
    Primary = Color3.fromRGB(120, 80, 255),      -- Vibrant purple
    PrimaryDark = Color3.fromRGB(90, 60, 200),
    PrimaryLight = Color3.fromRGB(160, 130, 255),
    
    -- Gradients
    Gradient1 = Color3.fromRGB(120, 80, 255),
    Gradient2 = Color3.fromRGB(255, 80, 180),
    
    -- Text
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 195),
    TextMuted = Color3.fromRGB(120, 120, 140),
    TextDark = Color3.fromRGB(80, 80, 100),
    
    -- UI Elements
    Border = Color3.fromRGB(45, 45, 55),
    BorderLight = Color3.fromRGB(65, 65, 80),
    Shadow = Color3.fromRGB(0, 0, 0),
    
    -- Toggle
    Toggle = {
        Enabled = Color3.fromRGB(120, 80, 255),
        Disabled = Color3.fromRGB(40, 40, 50),
        Circle = Color3.fromRGB(255, 255, 255),
    },
    
    -- Notification
    Notification = {
        Background = Color3.fromRGB(22, 22, 28),
        Border = Color3.fromRGB(45, 45, 55),
        Timer = Color3.fromRGB(120, 80, 255),
    },
    
    -- State Colors
    Success = Color3.fromRGB(80, 220, 100),
    Warning = Color3.fromRGB(255, 180, 50),
    Error = Color3.fromRGB(255, 80, 80),
    Info = Color3.fromRGB(80, 180, 255),
}

-- Modern Sizes
local Sizes = {
    Window = {Width = 720, Height = 480},
    MinWindow = {Width = 520, Height = 320},
    MaxWindow = {Width = 1280, Height = 860},
    Toggle = {Width = 42, Height = 24, Circle = 16},
    Button = {Height = 42},
    Slider = {Height = 50},
    Dropdown = {Height = 42, OptionHeight = 34},
    Tab = {Width = 140, Height = 38},
    ColorPicker = {Width = 190, Height = 170},
    Notification = {Width = 240, Height = 76},
    TextBox = {Height = 42, InputWidth = 160},
    CornerRadius = 8,
}

-- Fonts
local Fonts = {
    Regular = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
    Bold = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
    Light = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Light),
}

local TextSizes = {
    Title = 16,
    Header = 15,
    Normal = 14,
    Small = 13,
    Tiny = 11,
}

local AnimSpeed = {
    Instant = 0.05,
    Fast = 0.1,
    Normal = 0.2,
    Smooth = 0.35,
    Slow = 0.5,
}

-- Utility Functions
local function CreateTween(instance, properties, duration, style, direction)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(
            duration or AnimSpeed.Normal,
            style or Enum.EasingStyle.Quad,
            direction or Enum.EasingDirection.Out
        ),
        properties
    )
    tween:Play()
    return tween
end

local function CreateInstance(className, props)
    local inst = Instance.new(className)
    for k, v in pairs(props) do
        if k ~= "Parent" then inst[k] = v end
    end
    if props.Parent then inst.Parent = props.Parent end
    return inst
end

local function CreateCorner(parent, radius)
    return CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, radius or Sizes.CornerRadius),
        Parent = parent,
    })
end

local function CreateStroke(parent, color, thickness)
    return CreateInstance("UIStroke", {
        Color = color or Colors.Border,
        Thickness = thickness or 1.5,
        Transparency = 0.5,
        Parent = parent,
    })
end

local function CreateShadow(parent, size, transparency)
    return CreateInstance("UIShadow", {
        Color = Colors.Shadow,
        Size = size or 12,
        Transparency = transparency or 0.4,
        Parent = parent,
    })
end

local function CreatePadding(parent, padding)
    return CreateInstance("UIPadding", {
        PaddingTop = UDim.new(0, padding or 0),
        PaddingBottom = UDim.new(0, padding or 0),
        PaddingLeft = UDim.new(0, padding or 0),
        PaddingRight = UDim.new(0, padding or 0),
        Parent = parent,
    })
end

local function CreateListLayout(parent, padding, order, direction)
    return CreateInstance("UIListLayout", {
        Padding = UDim.new(0, padding or 0),
        SortOrder = order or Enum.SortOrder.LayoutOrder,
        FillDirection = direction or Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = parent,
    })
end

local function IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

-- Acrylic Blur Effect (Enhanced)
local AcrylicBlur = {}
AcrylicBlur.__index = AcrylicBlur

function AcrylicBlur.new(object)
    local self = setmetatable({
        _object = object,
        _enabled = true,
        _connections = {},
    }, AcrylicBlur)
    self:_Initialize()
    return self
end

function AcrylicBlur:_Initialize()
    -- Cleanup existing
    for _, child in ipairs(Lighting:GetChildren()) do
        if child.Name:match("Acrylic") then child:Destroy() end
    end
    
    -- Create DOF
    self._dof = CreateInstance("DepthOfFieldEffect", {
        Name = "AcrylicBlur",
        FarIntensity = 0,
        FocusDistance = 0.05,
        InFocusRadius = 0.1,
        NearIntensity = 0.4,
        Parent = Lighting,
    })
    
    -- Create folder
    local existing = workspace.CurrentCamera:FindFirstChild("AcrylicBlur")
    if existing then existing:Destroy() end
    self._folder = CreateInstance("Folder", {
        Name = "AcrylicBlur",
        Parent = workspace.CurrentCamera,
    })
    
    -- Create root part
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
        Transparency = 0.92,
        Parent = self._folder,
    })
    CreateInstance("SpecialMesh", {
        MeshType = Enum.MeshType.Brick,
        Parent = self._root,
    })
    
    -- Create frame
    self._frame = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Parent = self._object,
    })
    
    self:_SetupRender()
end

function AcrylicBlur:_SetupRender()
    local camera = workspace.CurrentCamera
    
    local function Update()
        if not self._root or not self._enabled then return end
        
        local viewY = camera.ViewportSize.Y
        local offset = (viewY / 2560) * 20 + 4
        local size = self._frame.AbsoluteSize - Vector2.new(offset, offset)
        local pos = self._frame.AbsolutePosition + Vector2.new(offset / 2, offset / 2)
        
        local function ScreenToWorld(loc, dist)
            local ray = camera:ScreenPointToRay(loc.X, loc.Y)
            return ray.Origin + ray.Direction * dist
        end
        
        local tl = ScreenToWorld(pos, 0.001)
        local tr = ScreenToWorld(pos + Vector2.new(size.X, 0), 0.001)
        local br = ScreenToWorld(pos + size, 0.001)
        
        local width = (tr - tl).Magnitude
        local height = (tr - br).Magnitude
        
        self._root.CFrame = CFrame.fromMatrix(
            (tl + br) / 2,
            camera.CFrame.XVector,
            camera.CFrame.YVector,
            camera.CFrame.ZVector
        )
        self._root.Mesh.Scale = Vector3.new(width, height, 0)
    end
    
    local events = {
        {camera, "CFrame"},
        {camera, "ViewportSize"},
        {camera, "FieldOfView"},
        {self._frame, "AbsolutePosition"},
        {self._frame, "AbsoluteSize"},
    }
    
    for _, e in ipairs(events) do
        local conn = e[1]:GetPropertyChangedSignal(e[2]):Connect(Update)
        table.insert(self._connections, conn)
    end
    
    local conn = RunService.RenderStepped:Connect(Update)
    table.insert(self._connections, conn)
    task.spawn(Update)
end

function AcrylicBlur:SetEnabled(enabled)
    self._enabled = enabled
    if self._root then
        self._root.Transparency = enabled and 0.92 or 1
    end
    if self._dof then
        self._dof.Enabled = enabled
    end
end

function AcrylicBlur:Destroy()
    for _, conn in ipairs(self._connections) do
        conn:Disconnect()
    end
    if self._folder then self._folder:Destroy() end
    if self._dof then self._dof:Destroy() end
end

-- Main Library
local Library = {}
Library.__index = Library

function Library.new(title)
    local self = setmetatable({}, Library)
    
    self.title = title or "Acrylic"
    self.sections = {}
    self.currentTab = nil
    self.minimized = false
    self._visible = true
    self._toggleKey = Enum.KeyCode.RightControl
    self._configElements = {}
    self._autoSave = false
    self._currentConfig = "default"
    self._connections = {}
    self._keybinds = {}
    self._originalHeight = Sizes.Window.Height
    self._minSize = Vector2.new(Sizes.MinWindow.Width, Sizes.MinWindow.Height)
    self._maxSize = Vector2.new(Sizes.MaxWindow.Width, Sizes.MaxWindow.Height)
    
    self:_CreateUI()
    self:_SetupKeybinds()
    self:_SetupMobile()
    
    return self
end

function Library:_CreateUI()
    -- ScreenGui
    self.screenGui = CreateInstance("ScreenGui", {
        Name = "Acrylic",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
    })
    
    -- Main Container
    self.container = CreateInstance("Frame", {
        Name = "Container",
        BackgroundColor3 = Colors.Background,
        BackgroundTransparency = 0.08,
        Position = UDim2.new(0.5, -Sizes.Window.Width / 2, 0.5, -Sizes.Window.Height / 2),
        Size = UDim2.new(0, Sizes.Window.Width, 0, Sizes.Window.Height),
        ClipsDescendants = false,
        Parent = self.screenGui,
    })
    CreateCorner(self.container)
    CreateStroke(self.container, Colors.BorderLight)
    CreateShadow(self.container, 20, 0.6)
    
    -- Glass overlay
    local glass = CreateInstance("Frame", {
        Name = "GlassOverlay",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.03,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = self.container,
    })
    CreateCorner(glass)
    
    -- Top Bar
    self.topBar = CreateInstance("Frame", {
        Name = "TopBar",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 48),
        Parent = self.container,
    })
    
    -- Title with icon
    local titleContainer = CreateInstance("Frame", {
        Name = "TitleContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Parent = self.topBar,
    })
    
    local titleIcon = CreateInstance("ImageLabel", {
        Name = "Icon",
        Image = "rbxassetid://10734898355",
        ImageColor3 = Colors.Primary,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, -9),
        Size = UDim2.new(0, 18, 0, 18),
        Parent = titleContainer,
    })
    CreateInstance("UIAspectRatioConstraint", {Parent = titleIcon})
    
    self.titleLabel = CreateInstance("TextLabel", {
        Name = "Title",
        FontFace = Fonts.Bold,
        TextColor3 = Colors.Text,
        Text = self.title,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 24, 0.5, -11),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = TextSizes.Title,
        Size = UDim2.new(1, -24, 0, 22),
        Parent = titleContainer,
    })
    
    -- Window Controls
    self:_CreateControls()
    
    -- Separator with gradient
    local separator = CreateInstance("Frame", {
        Name = "Separator",
        BackgroundColor3 = Colors.Border,
        Position = UDim2.new(0, 0, 0, 48),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = self.container,
    })
    CreateInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Colors.Border),
            ColorSequenceKeypoint.new(0.5, Colors.BorderLight),
            ColorSequenceKeypoint.new(1, Colors.Border),
        }),
        Parent = separator,
    })
    
    -- Content
    self:_CreateContent()
    
    -- Make draggable
    self:_MakeDraggable()
    
    -- Parent to player
    local player = Players.LocalPlayer
    self.screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Blur effect
    self._acrylicBlur = AcrylicBlur.new(self.container)
end

function Library:_CreateControls()
    local controls = CreateInstance("Frame", {
        Name = "Controls",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -90, 0, 0),
        Size = UDim2.new(0, 90, 1, 0),
        Parent = self.topBar,
    })
    CreateListLayout(controls, 0, Enum.SortOrder.LayoutOrder, Enum.FillDirection.Horizontal)
    CreatePadding(controls, 0, 0, 0, 12)
    
    -- Minimize
    local minimizeBtn = CreateInstance("ImageButton", {
        Name = "Minimize",
        Image = "rbxassetid://82603981310445",
        ImageColor3 = Colors.TextMuted,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 16, 0, 16),
        Parent = controls,
    })
    minimizeBtn.MouseButton1Click:Connect(function()
        self:_ToggleMinimize()
    end)
    minimizeBtn.MouseEnter:Connect(function()
        CreateTween(minimizeBtn, {ImageColor3 = Colors.Text}, AnimSpeed.Fast)
    end)
    minimizeBtn.MouseLeave:Connect(function()
        CreateTween(minimizeBtn, {ImageColor3 = Colors.TextMuted}, AnimSpeed.Fast)
    end)
    
    -- Resize
    local resizeBtn = CreateInstance("ImageButton", {
        Name = "Resize",
        Image = "rbxassetid://120997033468887",
        ImageColor3 = Colors.TextMuted,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 16, 0, 16),
        Parent = controls,
    })
    self.resizeBtn = resizeBtn
    self:_SetupResize(resizeBtn)
    
    -- Close
    local closeBtn = CreateInstance("ImageButton", {
        Name = "Close",
        Image = "rbxassetid://119943770201674",
        ImageColor3 = Colors.TextMuted,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 16, 0, 16),
        Parent = controls,
    })
    closeBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    closeBtn.MouseEnter:Connect(function()
        CreateTween(closeBtn, {ImageColor3 = Colors.Error}, AnimSpeed.Fast)
    end)
    closeBtn.MouseLeave:Connect(function()
        CreateTween(closeBtn, {ImageColor3 = Colors.TextMuted}, AnimSpeed.Fast)
    end)
end

function Library:_SetupResize(handle)
    local resizing = false
    local startPos, startSize
    
    handle.MouseEnter:Connect(function()
        CreateTween(handle, {ImageColor3 = Colors.Text}, AnimSpeed.Fast)
    end)
    handle.MouseLeave:Connect(function()
        if not resizing then
            CreateTween(handle, {ImageColor3 = Colors.TextMuted}, AnimSpeed.Fast)
        end
    end)
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            startPos = input.Position
            startSize = self.container.AbsoluteSize
        end
    end)
    
    handle.InputEnded:Connect(function()
        resizing = false
        CreateTween(handle, {ImageColor3 = Colors.TextMuted}, AnimSpeed.Fast)
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or
                         input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startPos
            local width = math.clamp(startSize.X + delta.X, self._minSize.X, self._maxSize.X)
            local height = math.clamp(startSize.Y + delta.Y, self._minSize.Y, self._maxSize.Y)
            self.container.Size = UDim2.new(0, width, 0, height)
            self._originalHeight = height
        end
    end)
end

function Library:_CreateContent()
    self.mainContent = CreateInstance("Frame", {
        Name = "MainContent",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 49),
        Size = UDim2.new(1, 0, 1, -49),
        ClipsDescendants = true,
        Parent = self.container,
    })
    
    -- Sidebar
    self.sidebar = CreateInstance("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(0, 170, 1, 0),
        Parent = self.mainContent,
    })
    CreateCorner(self.sidebar, 0, 0, Sizes.CornerRadius, 0)
    
    -- Sidebar sections
    self.sectionsContainer = CreateInstance("ScrollingFrame", {
        Name = "SectionsContainer",
        ScrollBarThickness = 0,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Parent = self.sidebar,
    })
    CreateListLayout(self.sectionsContainer, 2, Enum.SortOrder.LayoutOrder)
    CreatePadding(self.sectionsContainer, 8)
    
    -- Separator
    CreateInstance("Frame", {
        Name = "Separator",
        BackgroundColor3 = Colors.Border,
        Position = UDim2.new(0, 170, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        Parent = self.mainContent,
    })
    
    -- Content area
    self.contentContainer = CreateInstance("ScrollingFrame", {
        Name = "ContentContainer",
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Colors.Primary,
        ScrollBarImageTransparency = 0.5,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 171, 0, 0),
        Size = UDim2.new(1, -171, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Parent = self.mainContent,
    })
    CreateListLayout(self.contentContainer, 10, Enum.SortOrder.LayoutOrder)
    CreatePadding(self.contentContainer, 12, 12, 16, 16)
end

function Library:_MakeDraggable()
    local dragging = false
    local dragStart, startPos, dragInput
    
    self.topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.container.Position
        end
    end)
    
    self.topBar.InputEnded:Connect(function()
        dragging = false
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.container.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Library:_ToggleMinimize()
    self.minimized = not self.minimized
    if self.minimized then
        self._acrylicBlur:SetEnabled(false)
        CreateTween(self.mainContent, {Size = UDim2.new(1, 0, 0, 0)}, AnimSpeed.Smooth)
        CreateTween(self.container, {Size = UDim2.new(0, self.container.AbsoluteSize.X, 0, 48)}, AnimSpeed.Smooth)
        self.resizeBtn.Visible = false
    else
        self._acrylicBlur:SetEnabled(true)
        CreateTween(self.container, {Size = UDim2.new(0, self.container.AbsoluteSize.X, 0, self._originalHeight)}, AnimSpeed.Smooth)
        task.wait(AnimSpeed.Smooth)
        CreateTween(self.mainContent, {Size = UDim2.new(1, 0, 1, -49)}, AnimSpeed.Normal)
        self.resizeBtn.Visible = true
    end
end

function Library:_SetupKeybinds()
    local conn = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == self._toggleKey then
            self:Toggle()
        end
        for _, bind in pairs(self._keybinds) do
            if input.KeyCode == bind.key then
                bind.callback()
            end
        end
    end)
    table.insert(self._connections, conn)
end

function Library:_SetupMobile()
    local btn = CreateInstance("ImageButton", {
        Name = "MobileToggle",
        Image = "rbxassetid://112235310154264",
        ImageColor3 = Colors.Text,
        BackgroundColor3 = Colors.Background,
        BackgroundTransparency = 0.2,
        Position = UDim2.new(0, 16, 0.5, -28),
        Size = UDim2.new(0, 56, 0, 56),
        AnchorPoint = Vector2.new(0, 0.5),
        Visible = false,
        ZIndex = 999,
        Parent = self.screenGui,
    })
    CreateCorner(btn, 28)
    CreateStroke(btn, Colors.BorderLight)
    CreateShadow(btn, 10, 0.3)
    
    -- Drag support
    local dragging, dragStart, startPos = false
    
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or
           input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
        end
    end)
    
    btn.InputEnded:Connect(function(input)
        if dragging then
            local delta = input.Position - dragStart
            if delta.Magnitude < 10 then
                self:Toggle()
            end
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or
                         input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    self._mobileToggle = btn
    if IsMobile() then
        btn.Visible = not self._visible
    end
end

-- Public Methods
function Library:Toggle()
    self._visible = not self._visible
    self.container.Visible = self._visible
    self._acrylicBlur:SetEnabled(self._visible)
    if self._mobileToggle then
        self._mobileToggle.Visible = not self._visible
    end
end

function Library:SetToggleKey(key)
    self._toggleKey = key
end

function Library:Notify(config)
    local title = config.Title or "Notification"
    local desc = config.Description or ""
    local duration = config.Duration or 3
    local icon = config.Icon or "rbxassetid://10709775704"
    
    -- Create notification container if needed
    if not self._notificationContainer then
        self._notificationContainer = CreateInstance("Frame", {
            Name = "NotificationContainer",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -260, 0, 20),
            Size = UDim2.new(0, 240, 1, -40),
            Parent = self.screenGui,
        })
        CreateListLayout(self._notificationContainer, 10, Enum.SortOrder.LayoutOrder, Enum.FillDirection.Vertical)
    end
    
    local notif = CreateInstance("Frame", {
        Name = "Notification",
        BackgroundColor3 = Colors.Notification.Background,
        Position = UDim2.new(1, 20, 0, 0),
        Size = UDim2.new(1, 0, 0, Sizes.Notification.Height),
        ClipsDescendants = true,
        Parent = self._notificationContainer,
    })
    CreateCorner(notif, 6)
    CreateStroke(notif, Colors.Notification.Border)
    CreateShadow(notif, 8, 0.2)
    
    -- Icon
    local iconImg = CreateInstance("ImageLabel", {
        Image = icon,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0.5, -12),
        Size = UDim2.new(0, 24, 0, 24),
        Parent = notif,
    })
    CreateInstance("UIAspectRatioConstraint", {Parent = iconImg})
    
    -- Title
    local titleLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Bold,
        TextColor3 = Colors.Text,
        Text = title,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 44, 0, 12),
        TextSize = TextSizes.Normal,
        Size = UDim2.new(1, -54, 0, 20),
        Parent = notif,
    })
    
    -- Description
    local descLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.TextSecondary,
        Text = desc,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 44, 0, 34),
        TextSize = TextSizes.Small,
        Size = UDim2.new(1, -54, 0, 18),
        Parent = notif,
    })
    
    -- Progress bar
    local progress = CreateInstance("Frame", {
        Name = "Progress",
        BackgroundColor3 = Colors.Notification.Timer,
        Position = UDim2.new(0, 0, 1, -3),
        Size = UDim2.new(1, 0, 0, 3),
        Parent = notif,
    })
    CreateCorner(progress, 100)
    CreateInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Colors.Primary),
            ColorSequenceKeypoint.new(1, Colors.PrimaryDark),
        }),
        Parent = progress,
    })
    
    -- Animate
    CreateTween(notif, {Position = UDim2.new(0, 0, 0, 0)}, AnimSpeed.Smooth, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    CreateTween(progress, {Size = UDim2.new(0, 0, 0, 3)}, duration, Enum.EasingStyle.Linear)
    
    task.delay(duration, function()
        CreateTween(notif, {Position = UDim2.new(1, 20, 0, 0)}, AnimSpeed.Smooth, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(AnimSpeed.Smooth)
        notif:Destroy()
    end)
    
    return notif
end

function Library:Destroy()
    if self._autoSave then
        self:SaveConfig(self._currentConfig)
    end
    for _, conn in ipairs(self._connections) do
        conn:Disconnect()
    end
    if self._acrylicBlur then
        self._acrylicBlur:Destroy()
    end
    if self.screenGui then
        self.screenGui:Destroy()
    end
end

-- Config System
function Library:_RegisterConfigElement(id, type, get, set)
    self._configElements[id] = {type = type, getValue = get, setValue = set}
end

function Library:SaveConfig(name)
    if not writefile then
        self:Notify({Title = "Error", Description = "Config system not supported", Duration = 3})
        return false
    end
    
    if not isfolder then makefolder("AcrylicConfigs") end
    
    local data = {}
    for id, element in pairs(self._configElements) do
        local value = element.getValue()
        if typeof(value) == "Color3" then
            value = {R = value.R, G = value.G, B = value.B, _type = "Color3"}
        elseif typeof(value) == "EnumItem" then
            value = {_type = "EnumItem", _enum = tostring(value.EnumType), _value = value.Name}
        end
        data[id] = value
    end
    
    local success = pcall(function()
        writefile("AcrylicConfigs/" .. name .. ".json", HttpService:JSONEncode(data))
    end)
    
    if success then
        self._currentConfig = name
        self:Notify({Title = "Saved", Description = "Config saved as: " .. name, Duration = 2})
        return true
    else
        self:Notify({Title = "Error", Description = "Failed to save config", Duration = 3})
        return false
    end
end

function Library:LoadConfig(name)
    if not readfile or not isfile then
        self:Notify({Title = "Error", Description = "Config system not supported", Duration = 3})
        return false
    end
    
    local path = "AcrylicConfigs/" .. name .. ".json"
    if not isfile(path) then
        self:Notify({Title = "Error", Description = "Config not found", Duration = 3})
        return false
    end
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    
    if not success or not data then
        self:Notify({Title = "Error", Description = "Failed to load config", Duration = 3})
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
    
    self._currentConfig = name
    self:Notify({Title = "Loaded", Description = "Config loaded: " .. name, Duration = 2})
    return true
end

function Library:GetConfigs()
    if not isfolder or not listfiles then return {} end
    if not isfolder("AcrylicConfigs") then makefolder("AcrylicConfigs") end
    
    local configs = {}
    for _, file in ipairs(listfiles("AcrylicConfigs")) do
        local name = file:match("AcrylicConfigs/(.+)%.json$") or file:match("AcrylicConfigs\\(.+)%.json$")
        if name then table.insert(configs, name) end
    end
    return configs
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

-- Section Creation
function Library:CreateSection(name)
    local section = {
        name = name,
        tabs = {},
        expanded = true,
        _library = self,
    }
    
    -- Section button
    local sectionBtn = CreateInstance("Frame", {
        Name = "Section_" .. name,
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.8,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = self.sectionsContainer,
    })
    CreateCorner(sectionBtn, 5)
    
    local header = CreateInstance("TextButton", {
        Name = "Header",
        FontFace = Fonts.Bold,
        TextColor3 = Colors.Text,
        Text = "  " .. name,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 32),
        Parent = sectionBtn,
    })
    
    local arrow = CreateInstance("ImageLabel", {
        Name = "Arrow",
        Image = "rbxassetid://105558791071013",
        ImageColor3 = Colors.TextMuted,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.new(0, 12, 0, 12),
        Rotation = 0,
        Parent = header,
    })
    
    -- Tabs container
    local tabsContainer = CreateInstance("Frame", {
        Name = "TabsContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        Parent = sectionBtn,
    })
    CreateListLayout(tabsContainer, 2, Enum.SortOrder.LayoutOrder)
    CreatePadding(tabsContainer, 4, 4, 8, 8)
    
    local function ToggleSection()
        section.expanded = not section.expanded
        CreateTween(arrow, {Rotation = section.expanded and 0 or 180}, AnimSpeed.Normal)
        tabsContainer.Visible = section.expanded
    end
    
    header.MouseButton1Click:Connect(ToggleSection)
    
    section.frame = sectionBtn
    section.tabsContainer = tabsContainer
    table.insert(self.sections, section)
    
    return setmetatable({
        _section = section,
        CreateTab = function(_, tabName, icon)
            return self:_CreateTab(section, tabName, icon)
        end,
    }, {__index = function(t, k) return section[k] end})
end

function Library:_CreateTab(section, name, icon)
    local tab = {
        name = name,
        elements = {},
        _library = self,
    }
    
    -- Tab button
    local tabBtn = CreateInstance("TextButton", {
        Name = name,
        FontFace = Fonts.Regular,
        TextColor3 = Colors.TextMuted,
        Text = "  " .. name,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundColor3 = Colors.Primary,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = section.tabsContainer,
    })
    CreateCorner(tabBtn, 5)
    
    -- Tab icon
    if icon then
        local iconImg = CreateInstance("ImageLabel", {
            Image = icon,
            ImageColor3 = Colors.TextMuted,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0.5, -8),
            Size = UDim2.new(0, 16, 0, 16),
            Parent = tabBtn,
        })
        CreateInstance("UIAspectRatioConstraint", {Parent = iconImg})
        tab.icon = iconImg
    end
    
    -- Content
    tab.content = CreateInstance("Frame", {
        Name = name .. "_Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = self.contentContainer,
    })
    CreateListLayout(tab.content, 10, Enum.SortOrder.LayoutOrder)
    
    -- Select handler
    tabBtn.MouseButton1Click:Connect(function()
        self:_SelectTab(tab, tabBtn)
    end)
    
    -- Hover
    tabBtn.MouseEnter:Connect(function()
        if self.currentTab ~= tab then
            CreateTween(tabBtn, {BackgroundTransparency = 0.7}, AnimSpeed.Fast)
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if self.currentTab ~= tab then
            CreateTween(tabBtn, {BackgroundTransparency = 1}, AnimSpeed.Fast)
        end
    end)
    
    tab.button = tabBtn
    tab.contentFrame = tab.content
    table.insert(section.tabs, tab)
    
    if not self.currentTab then
        self:_SelectTab(tab, tabBtn)
    end
    
    return setmetatable({
        _tab = tab,
        CreateSection = function(_, sectionName)
            return self:_CreateSectionHeader(tab, sectionName)
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
        end,
    }, {__index = function(t, k) return tab[k] end})
end

function Library:_SelectTab(tab, btn)
    if self.currentTab then
        self.currentTab.content.Visible = false
        CreateTween(self.currentTab.button, {BackgroundTransparency = 1}, AnimSpeed.Fast)
        self.currentTab.button.TextColor3 = Colors.TextMuted
        if self.currentTab.icon then
            CreateTween(self.currentTab.icon, {ImageColor3 = Colors.TextMuted}, AnimSpeed.Fast)
        end
    end
    
    self.currentTab = tab
    tab.content.Visible = true
    CreateTween(btn, {BackgroundTransparency = 0.15}, AnimSpeed.Fast)
    btn.TextColor3 = Colors.Text
    if tab.icon then
        CreateTween(tab.icon, {ImageColor3 = Colors.Primary}, AnimSpeed.Fast)
    end
end

-- UI Element Creation
function Library:_CreateSectionHeader(tab, name)
    return CreateInstance("TextLabel", {
        FontFace = Fonts.Bold,
        TextColor3 = Colors.Text,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        TextSize = TextSizes.Header,
        Size = UDim2.new(1, 0, 0, 28),
        Parent = tab.content,
    })
end

function Library:_CreateParagraph(tab, config)
    local title = config.Title or "Paragraph"
    local content = config.Content or "Description text here."
    
    local frame = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = tab.content,
    })
    CreateCorner(frame)
    CreateStroke(frame, Colors.BorderLight)
    
    local padding = CreatePadding(frame, 14)
    
    local titleLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Bold,
        TextColor3 = Colors.Text,
        Text = title,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        TextSize = TextSizes.Normal,
        Size = UDim2.new(1, 0, 0, 22),
        Parent = frame,
    })
    
    local contentLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.TextSecondary,
        Text = content,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        BackgroundTransparency = 1,
        TextSize = TextSizes.Small,
        Position = UDim2.new(0, 0, 0, 24),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = frame,
    })
    
    return {
        SetTitle = function(_, text) titleLabel.Text = text end,
        SetContent = function(_, text) contentLabel.Text = text end,
    }
end

function Library:_CreateSlider(tab, config)
    local name = config.Name or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or 50
    local callback = config.Callback or function() end
    local flag = config.Flag
    local value = default
    
    local frame = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, Sizes.Slider.Height),
        Parent = tab.content,
    })
    CreateCorner(frame)
    CreateStroke(frame, Colors.BorderLight)
    CreatePadding(frame, 12)
    
    local nameLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.Text,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 4),
        TextSize = TextSizes.Normal,
        Size = UDim2.new(0, 180, 0, 18),
        Parent = frame,
    })
    
    local valueLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Bold,
        TextColor3 = Colors.Primary,
        Text = tostring(value),
        TextXAlignment = Enum.TextXAlignment.Right,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -4, 0, 4),
        TextSize = TextSizes.Normal,
        Size = UDim2.new(0, 60, 0, 18),
        Parent = frame,
    })
    
    local sliderBg = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Toggle.Disabled,
        Position = UDim2.new(0, 0, 0, 26),
        Size = UDim2.new(1, 0, 0, 6),
        Parent = frame,
    })
    CreateCorner(sliderBg, 100)
    
    local sliderFill = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Primary,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        Parent = sliderBg,
    })
    CreateCorner(sliderFill, 100)
    CreateInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Colors.Primary),
            ColorSequenceKeypoint.new(1, Colors.PrimaryLight),
        }),
        Parent = sliderFill,
    })
    
    local dragging = false
    
    local function UpdateSlider(input)
        local pos = input.Position
        local bgPos = sliderBg.AbsolutePosition
        local bgSize = sliderBg.AbsoluteSize
        local percent = math.clamp((pos.X - bgPos.X) / bgSize.X, 0, 1)
        value = math.floor(min + (max - min) * percent)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        valueLabel.Text = tostring(value)
        callback(value)
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateSlider(input)
        end
    end)
    
    sliderBg.InputEnded:Connect(function()
        dragging = false
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                         input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)
    
    local methods = {
        SetValue = function(_, val)
            value = math.clamp(val, min, max)
            local percent = (value - min) / (max - min)
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            valueLabel.Text = tostring(value)
            callback(value)
        end,
        GetValue = function() return value end,
    }
    
    if flag then
        self:_RegisterConfigElement(flag, "Slider",
            function() return value end,
            function(v) methods:SetValue(v) end
        )
    end
    
    return methods
end

function Library:_CreateButton(tab, config)
    local name = config.Name or "Button"
    local callback = config.Callback or function() end
    
    local frame = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, Sizes.Button.Height),
        Parent = tab.content,
    })
    CreateCorner(frame)
    CreateStroke(frame, Colors.BorderLight)
    CreatePadding(frame, 12)
    
    local btn = CreateInstance("TextButton", {
        FontFace = Fonts.Bold,
        TextColor3 = Colors.Text,
        Text = name,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = frame,
    })
    
    btn.MouseButton1Click:Connect(function()
        CreateTween(frame, {BackgroundTransparency = 0.1}, AnimSpeed.Fast)
        task.wait(0.1)
        CreateTween(frame, {BackgroundTransparency = 0.3}, AnimSpeed.Fast)
        callback()
    end)
    
    btn.MouseEnter:Connect(function()
        CreateTween(frame, {BackgroundTransparency = 0.15}, AnimSpeed.Fast)
    end)
    btn.MouseLeave:Connect(function()
        CreateTween(frame, {BackgroundTransparency = 0.3}, AnimSpeed.Fast)
    end)
    
    return {
        SetText = function(_, text) btn.Text = text end,
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
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, Sizes.Button.Height),
        Parent = tab.content,
    })
    CreateCorner(frame)
    CreateStroke(frame, Colors.BorderLight)
    CreatePadding(frame, 12)
    
    local nameLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.Text,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, -10),
        TextSize = TextSizes.Normal,
        Size = UDim2.new(0, 200, 0, 20),
        Parent = frame,
    })
    
    local switchBg = CreateInstance("Frame", {
        BackgroundColor3 = enabled and Colors.Toggle.Enabled or Colors.Toggle.Disabled,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -4, 0.5, 0),
        Size = UDim2.new(0, Sizes.Toggle.Width, 0, Sizes.Toggle.Height),
        Parent = frame,
    })
    CreateCorner(switchBg, 100)
    
    local switchCircle = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Toggle.Circle,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = enabled and UDim2.new(0, Sizes.Toggle.Width - Sizes.Toggle.Circle - 3, 0.5, 0) or
                      UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.new(0, Sizes.Toggle.Circle, 0, Sizes.Toggle.Circle),
        Parent = switchBg,
    })
    CreateCorner(switchCircle, 100)
    CreateShadow(switchCircle, 4, 0.3)
    
    local btn = CreateInstance("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = frame,
    })
    
    local function UpdateToggle()
        if enabled then
            CreateTween(switchBg, {BackgroundColor3 = Colors.Toggle.Enabled}, AnimSpeed.Normal)
            CreateTween(switchCircle, {Position = UDim2.new(0, Sizes.Toggle.Width - Sizes.Toggle.Circle - 3, 0.5, 0)}, AnimSpeed.Normal)
        else
            CreateTween(switchBg, {BackgroundColor3 = Colors.Toggle.Disabled}, AnimSpeed.Normal)
            CreateTween(switchCircle, {Position = UDim2.new(0, 3, 0.5, 0)}, AnimSpeed.Normal)
        end
    end
    
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        UpdateToggle()
        callback(enabled)
    end)
    
    local methods = {
        SetValue = function(_, val)
            enabled = val
            UpdateToggle()
            callback(enabled)
        end,
        GetValue = function() return enabled end,
    }
    
    if flag then
        self:_RegisterConfigElement(flag, "Toggle",
            function() return enabled end,
            function(v) methods:SetValue(v) end
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
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, Sizes.Dropdown.Height),
        ClipsDescendants = false,
        ZIndex = 1,
        Parent = tab.content,
    })
    CreateCorner(frame)
    CreateStroke(frame, Colors.BorderLight)
    CreatePadding(frame, 12)
    
    local nameLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.Text,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        TextSize = TextSizes.Normal,
        Size = UDim2.new(0, 200, 0, 20),
        Position = UDim2.new(0, 0, 0.5, -10),
        ZIndex = 1,
        Parent = frame,
    })
    
    local selectedDisplay = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Tertiary,
        BackgroundTransparency = 0.3,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -4, 0.5, 0),
        Size = UDim2.new(0, 160, 0, 30),
        ZIndex = 2,
        Parent = frame,
    })
    CreateCorner(selectedDisplay, 5)
    CreateStroke(selectedDisplay, Colors.BorderLight)
    
    local selectedLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.Text,
        Text = multiSelect and (#selected > 0 and table.concat(selected, ", ") or "None") or tostring(selected),
        TextTruncate = Enum.TextTruncate.AtEnd,
        BackgroundTransparency = 1,
        TextSize = TextSizes.Small,
        Position = UDim2.new(0, 10, 0.5, -10),
        Size = UDim2.new(1, -36, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
        Parent = selectedDisplay,
    })
    
    local arrow = CreateInstance("ImageLabel", {
        Image = "rbxassetid://105558791071013",
        ImageColor3 = Colors.TextMuted,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.new(0, 12, 0, 12),
        Rotation = 0,
        ZIndex = 2,
        Parent = selectedDisplay,
    })
    
    -- Options container
    local maxVisible = 5
    local totalHeight = math.min(#options * Sizes.Dropdown.OptionHeight, maxVisible * Sizes.Dropdown.OptionHeight)
    
    local optionsContainer = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Background,
        BackgroundTransparency = 0.05,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -4, 0, Sizes.Dropdown.Height - 6),
        Size = UDim2.new(0, 160, 0, totalHeight),
        Visible = false,
        ZIndex = 100,
        ClipsDescendants = true,
        Parent = frame,
    })
    CreateCorner(optionsContainer)
    CreateStroke(optionsContainer, Colors.BorderLight)
    CreateShadow(optionsContainer, 8, 0.3)
    
    local optionsScroll = CreateInstance("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, #options * Sizes.Dropdown.OptionHeight),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Colors.Primary,
        ZIndex = 100,
        Parent = optionsContainer,
    })
    CreateListLayout(optionsScroll, 0, Enum.SortOrder.LayoutOrder)
    
    local function UpdateSelectedText()
        if multiSelect then
            selectedLabel.Text = #selected > 0 and table.concat(selected, ", ") or "None"
        else
            selectedLabel.Text = tostring(selected)
        end
    end
    
    local function CreateOption(option)
        local btn = CreateInstance("TextButton", {
            Name = option,
            FontFace = Fonts.Regular,
            TextColor3 = Colors.Text,
            Text = option,
            BackgroundTransparency = 1,
            TextSize = TextSizes.Small,
            Size = UDim2.new(1, 0, 0, Sizes.Dropdown.OptionHeight),
            ZIndex = 100,
            Parent = optionsScroll,
        })
        
        btn.MouseEnter:Connect(function()
            CreateTween(btn, {BackgroundTransparency = 0.5}, AnimSpeed.Fast)
        end)
        btn.MouseLeave:Connect(function()
            CreateTween(btn, {BackgroundTransparency = 1}, AnimSpeed.Fast)
        end)
        
        btn.MouseButton1Click:Connect(function()
            if multiSelect then
                local idx = table.find(selected, option)
                if idx then
                    table.remove(selected, idx)
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
        
        return btn
    end
    
    for _, option in ipairs(options) do
        CreateOption(option)
    end
    
    local toggleBtn = CreateInstance("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 3,
        Parent = selectedDisplay,
    })
    
    toggleBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        optionsContainer.Visible = expanded
        CreateTween(arrow, {Rotation = expanded and 180 or 0}, AnimSpeed.Normal)
        frame.ZIndex = expanded and 10 or 1
    end)
    
    local methods = {
        SetValue = function(_, val)
            if multiSelect and type(val) == "table" then
                selected = val
            elseif not multiSelect then
                selected = val
            end
            UpdateSelectedText()
            callback(selected)
        end,
        GetValue = function() return selected end,
        Refresh = function(_, newOptions)
            options = newOptions
            for _, child in ipairs(optionsScroll:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            for _, option in ipairs(options) do
                CreateOption(option)
            end
            optionsScroll.CanvasSize = UDim2.new(0, 0, 0, #options * Sizes.Dropdown.OptionHeight)
            local newHeight = math.min(#options * Sizes.Dropdown.OptionHeight, maxVisible * Sizes.Dropdown.OptionHeight)
            optionsContainer.Size = UDim2.new(0, 160, 0, newHeight)
        end,
    }
    
    if flag then
        self:_RegisterConfigElement(flag, "Dropdown",
            function() return selected end,
            function(v) methods:SetValue(v) end
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
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, Sizes.Button.Height),
        Parent = tab.content,
    })
    CreateCorner(frame)
    CreateStroke(frame, Colors.BorderLight)
    CreatePadding(frame, 12)
    
    local nameLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.Text,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, -10),
        TextSize = TextSizes.Normal,
        Size = UDim2.new(0, 200, 0, 20),
        Parent = frame,
    })
    
    local keyBox = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Tertiary,
        BackgroundTransparency = 0.3,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -4, 0.5, 0),
        Size = UDim2.new(0, 40, 0, 30),
        Parent = frame,
    })
    CreateCorner(keyBox, 5)
    CreateStroke(keyBox, Colors.BorderLight)
    
    local keyLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Bold,
        TextColor3 = Colors.Text,
        Text = currentKey.Name,
        BackgroundTransparency = 1,
        TextSize = TextSizes.Normal,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = keyBox,
    })
    
    local btn = CreateInstance("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = keyBox,
    })
    
    local bindId = name .. "_" .. tostring(tick())
    self._keybinds[bindId] = {key = currentKey, callback = callback}
    
    local function UpdateDisplay()
        if listening then
            keyLabel.Text = "..."
            keyBox.Size = UDim2.new(0, 50, 0, 30)
        else
            local text = currentKey.Name
            local width = math.max(#text * 9 + 16, 40)
            keyBox.Size = UDim2.new(0, width, 0, 30)
            keyLabel.Text = text
        end
    end
    
    btn.MouseButton1Click:Connect(function()
        listening = true
        UpdateDisplay()
    end)
    
    local conn = UserInputService.InputBegan:Connect(function(input, processed)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            currentKey = input.KeyCode
            listening = false
            self._keybinds[bindId].key = currentKey
            UpdateDisplay()
        end
    end)
    table.insert(self._connections, conn)
    UpdateDisplay()
    
    local methods = {
        SetKey = function(_, key)
            currentKey = key
            self._keybinds[bindId].key = key
            UpdateDisplay()
        end,
        GetKey = function() return currentKey end,
    }
    
    if flag then
        self:_RegisterConfigElement(flag, "Keybind",
            function() return currentKey end,
            function(v) methods:SetKey(v) end
        )
    end
    
    return methods
end

function Library:_CreateColorPicker(tab, config)
    local name = config.Name or "Color Picker"
    local default = config.Default or Color3.fromRGB(255, 255, 255)
    local callback = config.Callback or function() end
    local flag = config.Flag
    local color = default
    local hue, sat, val = color:ToHSV()
    local expanded = false
    
    local frame = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, Sizes.Button.Height),
        Parent = tab.content,
    })
    CreateCorner(frame)
    CreateStroke(frame, Colors.BorderLight)
    CreatePadding(frame, 12)
    
    local nameLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.Text,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, -10),
        TextSize = TextSizes.Normal,
        Size = UDim2.new(0, 200, 0, 20),
        Parent = frame,
    })
    
    local preview = CreateInstance("Frame", {
        BackgroundColor3 = color,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -4, 0.5, 0),
        Size = UDim2.new(0, 40, 0, 30),
        Parent = frame,
    })
    CreateCorner(preview, 5)
    CreateStroke(preview, Colors.BorderLight)
    
    local previewBtn = CreateInstance("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = preview,
    })
    
    -- Picker
    local picker = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Background,
        BackgroundTransparency = 0.05,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -4, 0, Sizes.Button.Height - 6),
        Size = UDim2.new(0, Sizes.ColorPicker.Width, 0, Sizes.ColorPicker.Height),
        Visible = false,
        ZIndex = 100,
        Parent = frame,
    })
    CreateCorner(picker)
    CreateStroke(picker, Colors.BorderLight)
    CreateShadow(picker, 10, 0.3)
    CreatePadding(picker, 10)
    
    -- SV Picker
    local svPicker = CreateInstance("Frame", {
        BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
        Size = UDim2.new(1, 0, 0, Sizes.ColorPicker.Height - 70),
        Parent = picker,
    })
    CreateCorner(svPicker, 5)
    
    local white = CreateInstance("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1),
        Size = UDim2.new(1, 0, 1, 0),
        Parent = svPicker,
    })
    CreateCorner(white, 5)
    CreateInstance("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Parent = white,
    })
    
    local black = CreateInstance("Frame", {
        BackgroundColor3 = Color3.new(0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        Parent = svPicker,
    })
    CreateCorner(black, 5)
    CreateInstance("UIGradient", {
        Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        }),
        Parent = black,
    })
    
    local svCursor = CreateInstance("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(sat, 0, 1 - val, 0),
        Size = UDim2.new(0, 12, 0, 12),
        ZIndex = 5,
        Parent = svPicker,
    })
    CreateCorner(svCursor, 100)
    CreateStroke(svCursor, Color3.new(1, 1, 1), 2)
    
    -- Hue
    local hueSlider = CreateInstance("Frame", {
        Position = UDim2.new(0, 0, 0, Sizes.ColorPicker.Height - 60),
        Size = UDim2.new(1, 0, 0, 10),
        Parent = picker,
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
            ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
        }),
        Parent = hueSlider,
    })
    
    local hueCursor = CreateInstance("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(hue, 0, 0.5, 0),
        Size = UDim2.new(0, 12, 0, 16),
        ZIndex = 5,
        Parent = hueSlider,
    })
    CreateCorner(hueCursor, 100)
    CreateStroke(hueCursor, Color3.fromRGB(50, 50, 50))
    
    local function UpdateColor()
        color = Color3.fromHSV(hue, sat, val)
        preview.BackgroundColor3 = color
        svPicker.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        svCursor.Position = UDim2.new(sat, 0, 1 - val, 0)
        hueCursor.Position = UDim2.new(hue, 0, 0.5, 0)
        callback(color)
    end
    
    local svDrag, hueDrag = false, false
    
    local function ProcessInput(input)
        if not picker.Visible then return end
        
        if svDrag then
            local size = svPicker.AbsoluteSize
            local pos = svPicker.AbsolutePosition
            sat = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
            val = 1 - math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1)
            UpdateColor()
        elseif hueDrag then
            local size = hueSlider.AbsoluteSize
            local pos = hueSlider.AbsolutePosition
            hue = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
            UpdateColor()
        end
    end
    
    svPicker.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            svDrag = true
            ProcessInput(input)
        end
    end)
    
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDrag = true
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
            svDrag = false
            hueDrag = false
        end
    end)
    
    local function TogglePicker()
        expanded = not expanded
        picker.Visible = expanded
        frame.ZIndex = expanded and 10 or 1
    end
    
    previewBtn.MouseButton1Click:Connect(TogglePicker)
    
    local methods = {
        SetColor = function(_, col)
            color = col
            hue, sat, val = color:ToHSV()
            UpdateColor()
        end,
        GetColor = function() return color end,
    }
    
    if flag then
        self:_RegisterConfigElement(flag, "ColorPicker",
            function() return color end,
            function(v) methods:SetColor(v) end
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
    local text = default
    
    local frame = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, Sizes.TextBox.Height),
        Parent = tab.content,
    })
    CreateCorner(frame)
    CreateStroke(frame, Colors.BorderLight)
    CreatePadding(frame, 12)
    
    local nameLabel = CreateInstance("TextLabel", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.Text,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, -10),
        TextSize = TextSizes.Normal,
        Size = UDim2.new(0, 150, 0, 20),
        Parent = frame,
    })
    
    local inputBox = CreateInstance("Frame", {
        BackgroundColor3 = Colors.Tertiary,
        BackgroundTransparency = 0.3,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -4, 0.5, 0),
        Size = UDim2.new(0, Sizes.TextBox.InputWidth, 0, 30),
        Parent = frame,
    })
    CreateCorner(inputBox, 5)
    local inputStroke = CreateStroke(inputBox, Colors.BorderLight)
    
    local input = CreateInstance("TextBox", {
        FontFace = Fonts.Regular,
        TextColor3 = Colors.Text,
        PlaceholderText = placeholder,
        PlaceholderColor3 = Colors.TextMuted,
        Text = text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        BackgroundTransparency = 1,
        TextSize = TextSizes.Small,
        Position = UDim2.new(0, 10, 0.5, -10),
        Size = UDim2.new(1, -20, 0, 20),
        ClearTextOnFocus = clearOnFocus,
        Parent = inputBox,
    })
    
    input.Focused:Connect(function()
        CreateTween(inputBox, {BackgroundTransparency = 0.1}, AnimSpeed.Fast)
        CreateTween(inputStroke, {Color = Colors.Primary}, AnimSpeed.Fast)
    end)
    
    input.FocusLost:Connect(function(enter)
        CreateTween(inputBox, {BackgroundTransparency = 0.3}, AnimSpeed.Fast)
        CreateTween(inputStroke, {Color = Colors.BorderLight}, AnimSpeed.Fast)
        
        if numbersOnly then
            local num = tonumber(input.Text)
            if num then
                text = tostring(num)
                input.Text = text
            else
                input.Text = text
            end
        else
            text = input.Text
        end
        callback(text, enter)
    end)
    
    if numbersOnly then
        input:GetPropertyChangedSignal("Text"):Connect(function()
            local filtered = input.Text:gsub("[^%d%.%-]", "")
            if input.Text ~= filtered then
                input.Text = filtered
            end
        end)
    end
    
    local methods = {
        SetText = function(_, val)
            text = tostring(val)
            input.Text = text
        end,
        GetText = function() return text end,
        SetPlaceholder = function(_, val) input.PlaceholderText = val end,
        Focus = function() input:CaptureFocus() end,
    }
    
    if flag then
        self:_RegisterConfigElement(flag, "TextBox",
            function() return text end,
            function(v) methods:SetText(v) end
        )
    end
    
    return methods
end

function Library:_CreateConfigSection(tab)
    self:_CreateSectionHeader(tab, "Configuration")
    
    local lib = self
    
    local nameBox = self:_CreateTextBox(tab, {
        Name = "Config Name",
        Default = "default",
        Placeholder = "Enter name...",
        Callback = function(val) lib._currentConfig = val end,
    })
    
    local dropdown = self:_CreateDropdown(tab, {
        Name = "Select Config",
        Options = lib:GetConfigs(),
        Default = "default",
        Callback = function(val)
            nameBox:SetText(val)
            lib._currentConfig = val
        end,
    })
    
    self:_CreateButton(tab, {
        Name = "💾 Save Config",
        Callback = function()
            local name = nameBox:GetText()
            if name and name ~= "" then
                lib:SaveConfig(name)
                dropdown:Refresh(lib:GetConfigs())
            end
        end,
    })
    
    self:_CreateButton(tab, {
        Name = "📂 Load Config",
        Callback = function()
            local name = nameBox:GetText()
            if name and name ~= "" then
                lib:LoadConfig(name)
            end
        end,
    })
    
    self:_CreateButton(tab, {
        Name = "🗑️ Delete Config",
        Callback = function()
            local name = nameBox:GetText()
            if name and name ~= "" then
                lib:DeleteConfig(name)
                dropdown:Refresh(lib:GetConfigs())
            end
        end,
    })
    
    self:_CreateButton(tab, {
        Name = "🔄 Refresh",
        Callback = function()
            dropdown:Refresh(lib:GetConfigs())
            lib:Notify({Title = "Refreshed", Description = "Config list updated", Duration = 2})
        end,
    })
    
    self:_CreateToggle(tab, {
        Name = "Auto Save",
        Default = false,
        Callback = function(enabled)
            lib:SetAutoSave(enabled)
        end,
    })
    
    return {
        Refresh = function()
            dropdown:Refresh(lib:GetConfigs())
        end,
    }
end

return Library
