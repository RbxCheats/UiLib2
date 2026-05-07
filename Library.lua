--[[
  EMBER UI LIBRARY  v1.0.5
  Fixes: color picker (UIGradient, no asset IDs), dropdown UIListLayout,
         notifications (no stripe, outline only), SetTheme live update,
         drop shadow subtler, section padding balanced, toggle color syncs.
  v1.0.5: Dropdown border uses accent/surface styling (no ugly grey),
          Dropdown list uses Modal ZIndex layer so it always appears above buttons,
          Tab label colors register with theme system for live updates.
]]

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local LocalPlayer      = Players.LocalPlayer

local Theme = {
	Background    = Color3.fromHex("1e1f23"),
	Surface       = Color3.fromHex("2a2c31"),
	SurfaceHover  = Color3.fromHex("32353b"),
	SurfaceActive = Color3.fromHex("22242a"),
	Border        = Color3.fromHex("3a3d44"),
	Accent        = Color3.fromHex("f0a64b"),
	AccentDark    = Color3.fromHex("c07a20"),
	AccentGlow    = Color3.fromHex("f0a64b"),
	TextPrimary   = Color3.fromHex("e8e9ec"),
	TextSecondary = Color3.fromHex("9a9da6"),
	TextDisabled  = Color3.fromHex("5a5d66"),
	Success       = Color3.fromHex("4caf8a"),
	Danger        = Color3.fromHex("e05c5c"),
	SliderTrack   = Color3.fromHex("1a1b1f"),
	ScrollBar     = Color3.fromHex("3a3d44"),
	ToggleOff     = Color3.fromHex("3a3d44"),
	ToggleOn      = Color3.fromHex("f0a64b"),
	DropdownBg    = Color3.fromHex("22242a"),
	DropdownItem  = Color3.fromHex("2a2c31"),
	DropdownHover = Color3.fromHex("34373e"),
	Separator     = Color3.fromHex("35383f"),
}

local Font = {
	Regular  = Enum.Font.GothamMedium,
	Bold     = Enum.Font.GothamBold,
	SemiBold = Enum.Font.GothamSemibold,
	Mono     = Enum.Font.Code,
}

local Ease = {
	Fast   = TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	Medium = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	Bounce = TweenInfo.new(0.35, Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
}

-- Live theme registry
local ThemeReg = {}
for k in pairs(Theme) do ThemeReg[k] = {} end

local function reg(key, inst, prop)
	if ThemeReg[key] then table.insert(ThemeReg[key], {inst=inst, prop=prop}) end
end
local function regFn(key, fn)
	if ThemeReg[key] then table.insert(ThemeReg[key], {fn=fn}) end
end
local function applyThemeKey(key, value)
	for _, e in ipairs(ThemeReg[key] or {}) do
		if e.fn then pcall(e.fn, value)
		elseif e.inst and e.prop then pcall(function() e.inst[e.prop] = value end) end
	end
end

local Util = {}

function Util.Tween(obj, info, goal)
	local t = TweenService:Create(obj, info, goal); t:Play(); return t
end
function Util.Clamp(v, lo, hi) return math.max(lo, math.min(hi, v)) end
function Util.Round(n, step) return math.floor(n/step+0.5)*step end

function Util.HSVtoRGB(h, s, v)
	h = h % 1
	if s == 0 then return Color3.new(v,v,v) end
	local i = math.floor(h*6); local f = h*6-i
	local p=v*(1-s); local q=v*(1-f*s); local t=v*(1-(1-f)*s)
	local r,g,b
	i = i%6
	if i==0 then r,g,b=v,t,p elseif i==1 then r,g,b=q,v,p
	elseif i==2 then r,g,b=p,v,t elseif i==3 then r,g,b=p,q,v
	elseif i==4 then r,g,b=t,p,v elseif i==5 then r,g,b=v,p,q end
	return Color3.new(Util.Clamp(r,0,1),Util.Clamp(g,0,1),Util.Clamp(b,0,1))
end

function Util.RGBtoHSV(c)
	local r,g,b=c.R,c.G,c.B
	local mx=math.max(r,g,b); local mn=math.min(r,g,b); local d=mx-mn
	local h,s,v=0,0,mx
	if mx~=0 then s=d/mx end
	if d~=0 then
		if mx==r then h=(g-b)/d+(g<b and 6 or 0)
		elseif mx==g then h=(b-r)/d+2
		elseif mx==b then h=(r-g)/d+4 end
		h=h/6
	end
	return h,s,v
end

function Util.ToHex(c)
	return string.format("%02X%02X%02X",
		math.clamp(math.floor(c.R*255+.5),0,255),
		math.clamp(math.floor(c.G*255+.5),0,255),
		math.clamp(math.floor(c.B*255+.5),0,255))
end
function Util.FromHex(hex)
	hex=hex:gsub("#","")
	if #hex~=6 then return Color3.new(1,1,1) end
	return Color3.fromRGB(tonumber(hex:sub(1,2),16) or 0,tonumber(hex:sub(3,4),16) or 0,tonumber(hex:sub(5,6),16) or 0)
end

function Util.New(class, props)
	local i=Instance.new(class)
	for k,v in pairs(props or {}) do if k~="Parent" then i[k]=v end end
	if props and props.Parent then i.Parent=props.Parent end
	return i
end
function Util.Corner(r, p) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 6); if p then c.Parent=p end; return c end
function Util.Pad(t,r,b,l,p) local x=Instance.new("UIPadding"); x.PaddingTop=UDim.new(0,t or 0); x.PaddingRight=UDim.new(0,r or 0); x.PaddingBottom=UDim.new(0,b or 0); x.PaddingLeft=UDim.new(0,l or 0); if p then x.Parent=p end; return x end
function Util.Stroke(color,thickness,transparency,p) local s=Instance.new("UIStroke"); s.Color=color or Theme.Border; s.Thickness=thickness or 1; s.Transparency=transparency or 0; if p then s.Parent=p end; return s end
function Util.List(gap,dir,halign,p)
	local l=Instance.new("UIListLayout")
	l.Padding=UDim.new(0,gap or 0); l.FillDirection=dir or Enum.FillDirection.Vertical
	l.HorizontalAlignment=halign or Enum.HorizontalAlignment.Left; l.SortOrder=Enum.SortOrder.LayoutOrder
	if p then l.Parent=p end; return l
end
function Util.Drag(handle, target)
	local down,sp,op=false,nil,nil
	handle.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then down=true;sp=i.Position;op=target.Position end end)
	handle.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then down=false end end)
	UserInputService.InputChanged:Connect(function(i)
		if down and i.UserInputType==Enum.UserInputType.MouseMovement then
			local d=i.Position-sp; target.Position=UDim2.new(op.X.Scale,op.X.Offset+d.X,op.Y.Scale,op.Y.Offset+d.Y)
		end
	end)
end

-- Build a UIGradient rainbow hue bar (vertical, client-side, no asset needed)
function Util.MakeHueGradient(parent)
	local stops={}
	for i=0,6 do
		local t=i/6
		table.insert(stops,ColorSequenceKeypoint.new(t,Color3.fromHSV(t==1 and 0 or t,1,1)))
	end
	local g=Instance.new("UIGradient"); g.Rotation=90; g.Color=ColorSequence.new(stops); g.Parent=parent; return g
end

local Ember={}; Ember.__index=Ember; Ember._version="1.0.6"; Ember._windows={}

pcall(function() if CoreGui:FindFirstChild("EmberUI") then CoreGui.EmberUI:Destroy() end end)

local ScreenGui=Util.New("ScreenGui",{Name="EmberUI",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true,DisplayOrder=999,Parent=CoreGui})

-- Dropdown overlay: separate ScreenGui at higher DisplayOrder so lists always render
-- above the window. Unlike a transparent Frame, a ScreenGui doesn't swallow clicks
-- on empty space — input falls through to lower layers naturally.
local DropGui=Util.New("ScreenGui",{Name="EmberDropdowns",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true,DisplayOrder=1000,Parent=CoreGui})

-- ─── NOTIFICATIONS ────────────────────────────────────────────────────────────
local NotifHolder=Util.New("Frame",{Name="Notifications",Size=UDim2.new(0,300,1,0),Position=UDim2.new(1,-316,0,0),BackgroundTransparency=1,Parent=ScreenGui})
local notifList=Util.List(8,Enum.FillDirection.Vertical,Enum.HorizontalAlignment.Right,NotifHolder)
notifList.VerticalAlignment=Enum.VerticalAlignment.Bottom
Util.Pad(0,0,16,0,NotifHolder)

function Ember:Notify(opts)
	opts=opts or {}
	local title=opts.Title or "Notification"; local message=opts.Message or ""
	local duration=opts.Duration or 4; local ntype=opts.Type or "info"
	local accent=Theme.Accent
	if ntype=="success" then accent=Theme.Success elseif ntype=="error" then accent=Theme.Danger end

	local card=Util.New("Frame",{Name="Notif",Size=UDim2.new(1,0,0,66),Position=UDim2.new(1,20,0,0),BackgroundColor3=Theme.Surface,Parent=NotifHolder})
	Util.Corner(8,card)
	Util.Stroke(accent,1.5,0,card)

	Util.New("TextLabel",{Size=UDim2.new(1,-24,0,20),Position=UDim2.new(0,12,0,10),BackgroundTransparency=1,Text=title,TextColor3=Theme.TextPrimary,Font=Font.Bold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,Parent=card})
	Util.New("TextLabel",{Size=UDim2.new(1,-24,0,28),Position=UDim2.new(0,12,0,33),BackgroundTransparency=1,Text=message,TextColor3=Theme.TextSecondary,Font=Font.Regular,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextWrapped=true,Parent=card})

	Util.Tween(card,Ease.Bounce,{Position=UDim2.new(0,0,0,0)})
	task.spawn(function()
		task.wait(duration)
		if card and card.Parent then
			local t=Util.Tween(card,Ease.Medium,{Position=UDim2.new(1,20,0,0)})
			t.Completed:Wait(); card:Destroy()
		end
	end)
end

-- ─── WINDOW ───────────────────────────────────────────────────────────────────
local Window={}; Window.__index=Window

function Ember:CreateWindow(opts)
	opts=opts or {}
	local title=opts.Title or "Ember"; local sub=opts.Subtitle or ""
	local width=opts.Width or 780; local height=opts.Height or 520

	local win=setmetatable({},Window)
	win._tabs={}; win._activeTab=nil; win._visible=true

	local Root=Util.New("Frame",{Name="Window",Size=UDim2.new(0,width,0,height),Position=UDim2.new(0.5,-width/2,0.5,-height/2),BackgroundColor3=Theme.Background,BorderSizePixel=0,ClipsDescendants=false,Parent=ScreenGui})
	Util.Corner(10,Root); Util.Stroke(Theme.Border,1,0,Root)
	Util.New("ImageLabel",{Name="Shadow",Size=UDim2.new(1,30,1,30),Position=UDim2.new(0,-15,0,-15),BackgroundTransparency=1,Image="rbxassetid://6014261993",ImageColor3=Color3.new(0,0,0),ImageTransparency=0.78,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(49,49,450,450),ZIndex=-1,Parent=Root})
	win._root=Root

	-- Title bar
	local TitleBar=Util.New("Frame",{Name="TitleBar",Size=UDim2.new(1,0,0,52),BackgroundColor3=Theme.Surface,BorderSizePixel=0,ZIndex=2,Parent=Root})
	Util.Corner(10,TitleBar)
	Util.New("Frame",{Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=Theme.Surface,BorderSizePixel=0,ZIndex=1,Parent=TitleBar})

	local Dot=Util.New("Frame",{Size=UDim2.new(0,8,0,8),Position=UDim2.new(0,18,0.5,-4),BackgroundColor3=Theme.Accent,BorderSizePixel=0,ZIndex=3,Parent=TitleBar})
	Util.Corner(4,Dot); reg("Accent",Dot,"BackgroundColor3")

	local TitleLbl=Util.New("TextLabel",{Size=UDim2.new(0,200,1,0),Position=UDim2.new(0,34,0,0),BackgroundTransparency=1,Text=title,TextColor3=Theme.TextPrimary,Font=Font.Bold,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3,Parent=TitleBar})
	if sub~="" then
		local SubLbl=Util.New("TextLabel",{Size=UDim2.new(0,200,1,0),Position=UDim2.new(0,150,0,0),BackgroundTransparency=1,Text=sub,TextColor3=Theme.TextSecondary,Font=Font.Regular,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3,Parent=TitleBar})
		TitleLbl:GetPropertyChangedSignal("TextBounds"):Connect(function() SubLbl.Position=UDim2.new(0,34+TitleLbl.TextBounds.X+8,0,0) end)
	end

	local KeyHint=Util.New("TextLabel",{Size=UDim2.new(0,60,0,20),Position=UDim2.new(1,-72,0.5,-10),BackgroundColor3=Theme.SurfaceActive,Text="INSERT",TextColor3=Theme.TextDisabled,Font=Font.Mono,TextSize=10,ZIndex=3,Parent=TitleBar})
	Util.Corner(4,KeyHint); Util.Stroke(Theme.Border,1,0.5,KeyHint)

	-- Tab bar
	local TabBar=Util.New("Frame",{Size=UDim2.new(1,0,0,40),Position=UDim2.new(0,0,0,52),BackgroundColor3=Theme.Background,BorderSizePixel=0,ZIndex=2,Parent=Root})
	local TabScroll=Util.New("ScrollingFrame",{Size=UDim2.new(1,-20,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,ScrollBarThickness=0,ScrollingDirection=Enum.ScrollingDirection.X,CanvasSize=UDim2.new(0,0,1,0),AutomaticCanvasSize=Enum.AutomaticSize.X,Parent=TabBar})
	local TabList=Util.List(4,Enum.FillDirection.Horizontal,Enum.HorizontalAlignment.Left,TabScroll)
	TabList.VerticalAlignment=Enum.VerticalAlignment.Center
	Util.New("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=Theme.Separator,BorderSizePixel=0,Parent=TabBar})
	win._tabScroll=TabScroll

	local ContentArea=Util.New("Frame",{Size=UDim2.new(1,-16,1,-(52+40+8+8)),Position=UDim2.new(0,8,0,52+40+8),BackgroundTransparency=1,ClipsDescendants=true,Parent=Root})
	win._contentArea=ContentArea
	Util.Drag(TitleBar,Root)

	function win:_selectTab(tab)
		for _,t in ipairs(self._tabs) do
			t._scroll.Visible=false
			Util.Tween(t._lbl,Ease.Fast,{TextColor3=Theme.TextSecondary})
			Util.Tween(t._ind,Ease.Fast,{BackgroundTransparency=1})
			-- Close any open color pickers on the tab we are leaving
			if t._closePickers then t._closePickers() end
		end
		tab._scroll.Visible=true
		Util.Tween(tab._lbl,Ease.Fast,{TextColor3=Theme.Accent})
		Util.Tween(tab._ind,Ease.Fast,{BackgroundTransparency=0})
		self._activeTab=tab
	end

	function win:Toggle() win._visible=not win._visible; Root.Visible=win._visible end
	UserInputService.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==Enum.KeyCode.Insert then win:Toggle() end end)

	function win:CreateTab(label)
		local tab={_label=label,_sections={},_colIdx=0}
		-- Registry of close functions for color pickers on this tab
		local _pickerClosers={}
		tab._closePickers=function() for _,fn in ipairs(_pickerClosers) do fn() end end

		local btn=Util.New("TextButton",{Size=UDim2.new(0,0,1,-8),AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=TabScroll})
		Util.Pad(0,12,0,12,btn)
		local lbl=Util.New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=label,TextColor3=Theme.TextSecondary,Font=Font.SemiBold,TextSize=12,Parent=btn})
		local ind=Util.New("Frame",{Size=UDim2.new(1,-8,0,2),Position=UDim2.new(0,4,1,-2),BackgroundColor3=Theme.Accent,BorderSizePixel=0,BackgroundTransparency=1,Parent=btn})
		Util.Corner(2,ind); reg("Accent",ind,"BackgroundColor3")
		tab._btn=btn; tab._lbl=lbl; tab._ind=ind

		-- FIX: Register tab label TextColor3 with theme so inactive tabs update live.
		-- We store whether this tab is active so we can apply the right colour on change.
		regFn("Accent",function(newAccent)
			if self._activeTab==tab then
				lbl.TextColor3=newAccent
			end
			-- Inactive tabs keep TextSecondary; nothing needed for them.
		end)
		regFn("TextSecondary",function(newColor)
			if self._activeTab~=tab then
				lbl.TextColor3=newColor
			end
		end)

		btn.MouseEnter:Connect(function() if self._activeTab~=tab then Util.Tween(lbl,Ease.Fast,{TextColor3=Theme.TextPrimary}) end end)
		btn.MouseLeave:Connect(function() if self._activeTab~=tab then Util.Tween(lbl,Ease.Fast,{TextColor3=Theme.TextSecondary}) end end)

		local scroll=Util.New("ScrollingFrame",{Name="TC_"..label,Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=Theme.ScrollBar,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false,Parent=ContentArea})
		local ColWrap=Util.New("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=scroll})
		local ColL=Util.New("Frame",{Size=UDim2.new(0.5,-5,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=ColWrap})
		Util.List(8,nil,nil,ColL)
		local ColR=Util.New("Frame",{Size=UDim2.new(0.5,-5,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Position=UDim2.new(0.5,5,0,0),Parent=ColWrap})
		Util.List(8,nil,nil,ColR)
		tab._scroll=scroll; tab._colL=ColL; tab._colR=ColR

		btn.MouseButton1Click:Connect(function() self:_selectTab(tab) end)
		table.insert(self._tabs,tab)
		if #self._tabs==1 then self:_selectTab(tab) end

		function tab:CreateSection(title,column)
			local sec={_order=0}
			local useLeft
			if column=="left" then useLeft=true elseif column=="right" then useLeft=false
			else self._colIdx=self._colIdx+1; useLeft=(self._colIdx%2==1) end
			local parent=useLeft and self._colL or self._colR

			local Card=Util.New("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=Theme.Surface,BorderSizePixel=0,Parent=parent})
			Util.Corner(8,Card); Util.Stroke(Theme.Border,1,0,Card)
			local Inner=Util.New("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=Card})
			Util.Pad(12,14,12,14,Inner); Util.List(0,nil,nil,Inner)

			local Hdr=Util.New("Frame",{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,LayoutOrder=0,Parent=Inner})
			local HdrLbl=Util.New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=title:upper(),TextColor3=Theme.Accent,Font=Font.Bold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=Hdr})
			reg("Accent",HdrLbl,"TextColor3")

			Util.New("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=Theme.Separator,BorderSizePixel=0,LayoutOrder=1,Parent=Inner})

			local Elems=Util.New("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=2,Parent=Inner})
			Util.List(0,nil,nil,Elems)
			sec._elems=Elems

			local function row(h)
				sec._order=sec._order+1
				return Util.New("Frame",{Size=UDim2.new(1,0,0,h),BackgroundTransparency=1,LayoutOrder=sec._order,Parent=Elems})
			end

			-- AddToggle
			function sec:AddToggle(opts)
				opts=opts or {}
				local lbl=opts.Label or "Toggle"; local default=opts.Default~=nil and opts.Default or false
				local callback=opts.Callback or function() end; local state=default
				local r=row(40)
				Util.New("TextLabel",{Size=UDim2.new(1,-56,1,0),BackgroundTransparency=1,Text=lbl,TextColor3=Theme.TextPrimary,Font=Font.Regular,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Parent=r})
				local Track=Util.New("Frame",{Size=UDim2.new(0,36,0,20),Position=UDim2.new(1,-44,0.5,-10),BackgroundColor3=state and Theme.ToggleOn or Theme.ToggleOff,BorderSizePixel=0,Parent=r})
				Util.Corner(10,Track)
				local Knob=Util.New("Frame",{Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,state and 18 or 3,0.5,-7),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Parent=Track})
				Util.Corner(7,Knob)
				local Hit=Util.New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=r})
				regFn("Accent",function(newAccent) Theme.ToggleOn=newAccent; if state then Track.BackgroundColor3=newAccent end end)
				local function set(v,fire)
					state=v
					Util.Tween(Track,Ease.Fast,{BackgroundColor3=state and Theme.ToggleOn or Theme.ToggleOff})
					Util.Tween(Knob,Ease.Fast,{Position=UDim2.new(0,state and 18 or 3,0.5,-7)})
					if fire then callback(state) end
				end
				Hit.MouseButton1Click:Connect(function() set(not state,true) end)
				local ctrl={}; function ctrl:Set(v) set(v,false) end; function ctrl:Get() return state end; return ctrl
			end

			-- AddSlider
			function sec:AddSlider(opts)
				opts=opts or {}
				local lbl=opts.Label or "Slider"; local min=opts.Min or 0; local max=opts.Max or 100
				local default=opts.Default or min; local suffix=opts.Suffix or ""; local step=opts.Step or 1
				local callback=opts.Callback or function() end; local value=Util.Clamp(default,min,max)
				local r=row(52)
				local TopR=Util.New("Frame",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,Parent=r})
				Util.New("TextLabel",{Size=UDim2.new(0.7,0,1,0),BackgroundTransparency=1,Text=lbl,TextColor3=Theme.TextPrimary,Font=Font.Regular,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Parent=TopR})
				local ValLbl=Util.New("TextLabel",{Size=UDim2.new(0.3,0,1,0),Position=UDim2.new(0.7,0,0,0),BackgroundTransparency=1,Text=tostring(value)..suffix,TextColor3=Theme.Accent,Font=Font.SemiBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right,Parent=TopR})
				reg("Accent",ValLbl,"TextColor3")
				local Wrap=Util.New("Frame",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,28),BackgroundTransparency=1,ClipsDescendants=false,Parent=r})
				local Track=Util.New("Frame",{Size=UDim2.new(1,-14,0,6),Position=UDim2.new(0,7,0.5,-3),BackgroundColor3=Theme.SliderTrack,BorderSizePixel=0,ClipsDescendants=true,Parent=Wrap})
				Util.Corner(3,Track)
				local pct=(value-min)/(max-min)
				local Fill=Util.New("Frame",{Size=UDim2.new(pct,0,1,0),BackgroundColor3=Theme.Accent,BorderSizePixel=0,Parent=Track})
				Util.Corner(3,Fill); reg("Accent",Fill,"BackgroundColor3")
				local Thumb=Util.New("Frame",{Size=UDim2.new(0,14,0,14),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(pct,math.floor(7-pct*14+0.5),0.5,0),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=2,Parent=Wrap})
				Util.Corner(7,Thumb); Util.Stroke(Color3.fromHex("999999"),1,0.4,Thumb)
				local Hit=Util.New("TextButton",{Size=UDim2.new(1,0,1,24),Position=UDim2.new(0,0,0,-12),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=3,Parent=Wrap})
				local drag=false
				local function update(x)
					local abs=Track.AbsolutePosition.X; local sz=Track.AbsoluteSize.X
					local p=Util.Clamp((x-abs)/sz,0,1)
					value=Util.Clamp(Util.Round(p*(max-min)+min,step),min,max)
					local np=(value-min)/(max-min)
					Fill.Size=UDim2.new(np,0,1,0); Thumb.Position=UDim2.new(np,math.floor(7-np*14+0.5),0.5,0)
					ValLbl.Text=tostring(value)..suffix; callback(value)
				end
				Hit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true;update(i.Position.X) end end)
				Hit.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
				UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then update(i.Position.X) end end)
				local ctrl={}
				function ctrl:Set(v) value=Util.Clamp(v,min,max); local np=(value-min)/(max-min); Fill.Size=UDim2.new(np,0,1,0); Thumb.Position=UDim2.new(np,math.floor(7-np*14+0.5),0.5,0); ValLbl.Text=tostring(value)..suffix end
				function ctrl:Get() return value end; return ctrl
			end

			-- AddDropdown
			function sec:AddDropdown(opts)
				opts=opts or {}
				local lbl=opts.Label or "Dropdown"; local items=opts.Items or {"none"}
				local default=opts.Default or items[1] or "none"; local callback=opts.Callback or function() end
				local selected=default
				local r=row(60)
				Util.New("TextLabel",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,Text=lbl,TextColor3=Theme.TextPrimary,Font=Font.Regular,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Parent=r})

				-- FIX: Dropdown button border uses Surface border style, not the raw Border grey.
				-- We use a subtle stroke that matches the button background edge.
				local Btn=Util.New("TextButton",{Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,0,24),BackgroundColor3=Theme.DropdownBg,Text="",AutoButtonColor=false,Parent=r})
				Util.Corner(6,Btn)
				Util.Stroke(Theme.Border,1,0.3,Btn)

				local BtnLbl=Util.New("TextLabel",{Size=UDim2.new(1,-34,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=selected,TextColor3=Theme.TextPrimary,Font=Font.Regular,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=Btn})
				local Arrow=Util.New("ImageLabel",{Size=UDim2.new(0,10,0,10),Position=UDim2.new(1,-20,0.5,-5),BackgroundTransparency=1,Image="rbxassetid://6034818372",ImageColor3=Theme.TextSecondary,Rotation=90,Parent=Btn})

				local function setBtnOpen(isOpen)
					-- Arrow rotation handled by callers; placeholder kept for call-site compat
					_ = isOpen
				end

				local ITEM_H=30; local visRows=math.min(#items,5); local listH=visRows*ITEM_H

				-- Parent to DropGui (DisplayOrder=1000) so it always renders above the window.
				-- A ScreenGui doesn't swallow clicks on empty space unlike a transparent Frame.
				local List=Util.New("ScrollingFrame",{
					Size=UDim2.new(0,100,0,listH),
					BackgroundColor3=Theme.DropdownBg,
					BorderSizePixel=0,
					Visible=false,
					ZIndex=1,
					ClipsDescendants=true,
					ScrollBarThickness=#items>5 and 3 or 0,
					ScrollBarImageColor3=Theme.ScrollBar,
					CanvasSize=UDim2.new(0,0,0,#items*ITEM_H),
					Parent=DropGui
				})
				Util.Corner(6,List)
				-- Subtle neutral border — no accent colour, matches the closed button style
				Util.Stroke(Theme.Border,1,0.2,List)
				local IL=Util.List(0,Enum.FillDirection.Vertical,Enum.HorizontalAlignment.Left,List)
				IL.SortOrder=Enum.SortOrder.LayoutOrder

				local open=false; local itemBtns={}
				local function closeList()
					open=false; List.Visible=false
					Util.Tween(Arrow,Ease.Fast,{Rotation=90})
					setBtnOpen(false)
				end

				for idx,itemText in ipairs(items) do
					local isSel=(itemText==selected)
					local ItemBtn=Util.New("TextButton",{Size=UDim2.new(1,0,0,ITEM_H),BackgroundColor3=isSel and Theme.SurfaceHover or Theme.DropdownItem,Text="",AutoButtonColor=false,LayoutOrder=idx,ZIndex=2,Parent=List})
					local ItemLbl=Util.New("TextLabel",{Size=UDim2.new(1,-10,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=itemText,TextColor3=isSel and Theme.Accent or Theme.TextPrimary,Font=isSel and Font.SemiBold or Font.Regular,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3,Parent=ItemBtn})
					if idx<#items then Util.New("Frame",{Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,1,-1),BackgroundColor3=Theme.Separator,BorderSizePixel=0,ZIndex=4,Parent=ItemBtn}) end
					ItemBtn.MouseEnter:Connect(function() if itemText~=selected then ItemBtn.BackgroundColor3=Theme.DropdownHover end end)
					ItemBtn.MouseLeave:Connect(function() ItemBtn.BackgroundColor3=(itemText==selected) and Theme.SurfaceHover or Theme.DropdownItem end)
					ItemBtn.MouseButton1Up:Connect(function()
						for _,ib in ipairs(itemBtns) do ib.btn.BackgroundColor3=Theme.DropdownItem; ib.lbl.TextColor3=Theme.TextPrimary; ib.lbl.Font=Font.Regular end
						ItemBtn.BackgroundColor3=Theme.SurfaceHover; ItemLbl.TextColor3=Theme.Accent; ItemLbl.Font=Font.SemiBold
						selected=itemText; BtnLbl.Text=itemText; closeList(); callback(selected)
					end)
					table.insert(itemBtns,{btn=ItemBtn,lbl=ItemLbl,text=itemText})
				end

				-- Keep ListStroke accent colour in sync with theme changes
				regFn("Accent",function(newAccent) ListStroke.Color=newAccent end)

				Btn.MouseButton1Click:Connect(function()
					open=not open
					if open then
						local ap=Btn.AbsolutePosition; local as=Btn.AbsoluteSize
						List.Position=UDim2.new(0,ap.X,0,ap.Y+as.Y+4); List.Size=UDim2.new(0,as.X,0,listH)
						List.Visible=true; Util.Tween(Arrow,Ease.Fast,{Rotation=270})
						setBtnOpen(true)
					else closeList() end
				end)
				UserInputService.InputBegan:Connect(function(i)
					if open and i.UserInputType==Enum.UserInputType.MouseButton1 then
						local mp=UserInputService:GetMouseLocation()
						local lp=List.AbsolutePosition; local ls=List.AbsoluteSize
						local bp=Btn.AbsolutePosition; local bs=Btn.AbsoluteSize
						local inList=mp.X>=lp.X and mp.X<=lp.X+ls.X and mp.Y>=lp.Y and mp.Y<=lp.Y+ls.Y
						local inBtn=mp.X>=bp.X and mp.X<=bp.X+bs.X and mp.Y>=bp.Y and mp.Y<=bp.Y+bs.Y
						if not inList and not inBtn then closeList() end
					end
				end)
				local ctrl={}
				function ctrl:Set(v) selected=v; BtnLbl.Text=v; for _,ib in ipairs(itemBtns) do local s=(ib.text==v); ib.btn.BackgroundColor3=s and Theme.SurfaceHover or Theme.DropdownItem; ib.lbl.TextColor3=s and Theme.Accent or Theme.TextPrimary; ib.lbl.Font=s and Font.SemiBold or Font.Regular end end
				function ctrl:Get() return selected end; return ctrl
			end

			-- AddButton
			function sec:AddButton(opts)
				opts=opts or {}
				local lbl=opts.Label or "Button"; local sublbl=opts.SubLabel or nil
				local style=opts.Style or "default"; local callback=opts.Callback or function() end
				local h=sublbl and 52 or 42; local r=row(h)
				local baseBg=style=="danger" and Theme.Danger or style=="success" and Theme.Success or Color3.fromHex("363840")
				local hoverBg=style=="danger" and Color3.fromHex("c04040") or style=="success" and Color3.fromHex("3a8f6a") or Color3.fromHex("3e4149")
				local pressBg=style=="default" and Theme.SurfaceActive or hoverBg
				local Btn=Util.New("TextButton",{Size=UDim2.new(1,0,1,-4),Position=UDim2.new(0,0,0,2),BackgroundColor3=baseBg,Text="",AutoButtonColor=false,Parent=r})
				Util.Corner(6,Btn); Util.Stroke(style=="default" and Color3.fromHex("4a4e58") or baseBg,1,0,Btn)
				local IL=Util.List(2,Enum.FillDirection.Vertical,Enum.HorizontalAlignment.Center,Btn); IL.VerticalAlignment=Enum.VerticalAlignment.Center
				Util.New("TextLabel",{Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,Text=lbl,TextColor3=style=="default" and Theme.TextPrimary or Color3.new(1,1,1),Font=Font.SemiBold,TextSize=13,Parent=Btn})
				if sublbl then Util.New("TextLabel",{Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Text=sublbl,TextColor3=style=="default" and Theme.TextSecondary or Color3.fromRGB(220,220,220),Font=Font.Regular,TextSize=11,Parent=Btn}) end
				Btn.MouseEnter:Connect(function() Util.Tween(Btn,Ease.Fast,{BackgroundColor3=hoverBg}) end)
				Btn.MouseLeave:Connect(function() Util.Tween(Btn,Ease.Fast,{BackgroundColor3=baseBg}) end)
				Btn.MouseButton1Down:Connect(function() Util.Tween(Btn,Ease.Fast,{BackgroundColor3=pressBg}) end)
				Btn.MouseButton1Up:Connect(function() Util.Tween(Btn,Ease.Fast,{BackgroundColor3=hoverBg}); callback() end)
			end

			-- AddLabel
			function sec:AddLabel(opts)
				opts=opts or {}; local r=row(30)
				Util.New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=opts.Text or "",TextColor3=opts.Color or Theme.TextSecondary,Font=Font.Regular,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,TextWrapped=true,Parent=r})
			end

			-- AddColorPicker
			function sec:AddColorPicker(opts)
				opts=opts or {}
				local lbl=opts.Label or "Color"; local default=opts.Default or Color3.fromRGB(240,166,75)
				local callback=opts.Callback or function() end
				local H,S,V=Util.RGBtoHSV(default); local curColor=default

				local r=row(36)
				Util.New("TextLabel",{Size=UDim2.new(1,-46,1,0),BackgroundTransparency=1,Text=lbl,TextColor3=Theme.TextPrimary,Font=Font.Regular,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Parent=r})
				local Swatch=Util.New("TextButton",{Size=UDim2.new(0,36,0,22),Position=UDim2.new(1,-40,0.5,-11),BackgroundColor3=default,Text="",AutoButtonColor=false,Parent=r})
				Util.Corner(4,Swatch); Util.Stroke(Theme.Border,1,0,Swatch)

				sec._order=sec._order+1
				local PanelRow=Util.New("Frame",{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,ClipsDescendants=false,LayoutOrder=sec._order,Visible=false,Parent=Elems})
				local Panel=Util.New("Frame",{Size=UDim2.new(1,0,0,200),BackgroundColor3=Theme.SurfaceActive,Parent=PanelRow})
				Util.Corner(6,Panel); Util.Pad(10,10,10,10,Panel)

				local SQ=Util.New("Frame",{Size=UDim2.new(1,-(8+18+8+80),1,0),BackgroundColor3=Color3.fromHSV(H,1,1),BorderSizePixel=0,ClipsDescendants=false,Parent=Panel})
				Util.Corner(4,SQ)

				local SatF=Util.New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=2,ClipsDescendants=false,Parent=SQ})
				Util.Corner(4,SatF)
				local SatG=Instance.new("UIGradient"); SatG.Rotation=0
				SatG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(H,1,1))})
				SatG.Transparency=NumberSequence.new(0); SatG.Parent=SatF

				local ValF=Util.New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,ZIndex=3,ClipsDescendants=false,Parent=SQ})
				Util.Corner(4,ValF)
				local ValG=Instance.new("UIGradient"); ValG.Rotation=90
				ValG.Color=ColorSequence.new(Color3.new(0,0,0))
				ValG.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}); ValG.Parent=ValF

				local SVCur=Util.New("Frame",{Size=UDim2.new(0,12,0,12),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(S,0,1-V,0),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=10,Parent=SQ})
				Util.Corner(6,SVCur); Util.Stroke(Color3.new(0,0,0),1.5,0.15,SVCur)

				local HueBar=Util.New("Frame",{Size=UDim2.new(0,18,1,0),Position=UDim2.new(1,-(8+80+8+18),0,0),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ClipsDescendants=false,Parent=Panel})
				Util.Corner(4,HueBar); Util.MakeHueGradient(HueBar)

				local HueLine=Util.New("Frame",{Size=UDim2.new(1,6,0,3),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,H,0),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=5,Parent=HueBar})
				Util.Corner(1,HueLine); Util.Stroke(Color3.new(0,0,0),1,0.2,HueLine)

				local RP=Util.New("Frame",{Size=UDim2.new(0,80,1,0),Position=UDim2.new(1,-80,0,0),BackgroundTransparency=1,Parent=Panel})
				local CPrev=Util.New("Frame",{Size=UDim2.new(1,0,0,50),BackgroundColor3=curColor,Parent=RP}); Util.Corner(5,CPrev)
				Util.New("TextLabel",{Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,0,54),BackgroundTransparency=1,Text="HEX",TextColor3=Theme.TextDisabled,Font=Font.Bold,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Parent=RP})
				local HexBox=Util.New("TextBox",{Size=UDim2.new(1,0,0,24),Position=UDim2.new(0,0,0,66),BackgroundColor3=Theme.DropdownBg,Text="#"..Util.ToHex(curColor),TextColor3=Theme.TextPrimary,Font=Font.Mono,TextSize=10,ClearTextOnFocus=false,Parent=RP})
				Util.Corner(4,HexBox); Util.Pad(0,4,0,4,HexBox)

				local function mkRGB(ch,yoff,init)
					local f=Util.New("Frame",{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,0,yoff),BackgroundColor3=Theme.DropdownBg,Parent=RP}); Util.Corner(3,f)
					Util.New("TextLabel",{Size=UDim2.new(0,14,1,0),BackgroundTransparency=1,Text=ch,TextColor3=Theme.TextDisabled,Font=Font.Bold,TextSize=9,Parent=f})
					return Util.New("TextLabel",{Size=UDim2.new(1,-14,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,Text=tostring(init),TextColor3=Theme.TextPrimary,Font=Font.Mono,TextSize=10,Parent=f})
				end
				local RLbl=mkRGB("R",96,math.floor(curColor.R*255))
				local GLbl=mkRGB("G",115,math.floor(curColor.G*255))
				local BLbl=mkRGB("B",134,math.floor(curColor.B*255))

				local function apply()
					curColor=Util.HSVtoRGB(H,S,V)
					local hCol=Color3.fromHSV(H,1,1)
					SQ.BackgroundColor3=hCol
					SatG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,hCol)})
					Swatch.BackgroundColor3=curColor; CPrev.BackgroundColor3=curColor
					HexBox.Text="#"..Util.ToHex(curColor)
					RLbl.Text=tostring(math.floor(curColor.R*255)); GLbl.Text=tostring(math.floor(curColor.G*255)); BLbl.Text=tostring(math.floor(curColor.B*255))
					callback(curColor)
				end

				local svDrag=false
				SQ.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=true; local a=SQ.AbsolutePosition;local s2=SQ.AbsoluteSize; S=Util.Clamp((i.Position.X-a.X)/s2.X,0,1); V=1-Util.Clamp((i.Position.Y-a.Y)/s2.Y,0,1); SVCur.Position=UDim2.new(S,0,1-V,0); apply() end end)
				SQ.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=false end end)
				UserInputService.InputChanged:Connect(function(i) if svDrag and i.UserInputType==Enum.UserInputType.MouseMovement then local a=SQ.AbsolutePosition;local s2=SQ.AbsoluteSize; S=Util.Clamp((i.Position.X-a.X)/s2.X,0,1); V=1-Util.Clamp((i.Position.Y-a.Y)/s2.Y,0,1); SVCur.Position=UDim2.new(S,0,1-V,0); apply() end end)

				local hDrag=false
				HueBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hDrag=true; local a=HueBar.AbsolutePosition;local s2=HueBar.AbsoluteSize; H=Util.Clamp((i.Position.Y-a.Y)/s2.Y,0,1); HueLine.Position=UDim2.new(0.5,0,H,0); apply() end end)
				HueBar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hDrag=false end end)
				UserInputService.InputChanged:Connect(function(i) if hDrag and i.UserInputType==Enum.UserInputType.MouseMovement then local a=HueBar.AbsolutePosition;local s2=HueBar.AbsoluteSize; H=Util.Clamp((i.Position.Y-a.Y)/s2.Y,0,1); HueLine.Position=UDim2.new(0.5,0,H,0); apply() end end)

				HexBox.FocusLost:Connect(function() local hex=HexBox.Text:gsub("#",""); if #hex==6 then local c=Util.FromHex(hex); H,S,V=Util.RGBtoHSV(c); SVCur.Position=UDim2.new(S,0,1-V,0); HueLine.Position=UDim2.new(0.5,0,H,0); apply() end end)

				local pickerOpen=false
				local function closePicker()
					if pickerOpen then
						pickerOpen=false
						PanelRow.Visible=false
						PanelRow.Size=UDim2.new(1,0,0,0)
					end
				end
				table.insert(_pickerClosers,closePicker)
				Swatch.MouseButton1Click:Connect(function()
					pickerOpen=not pickerOpen
					PanelRow.Visible=pickerOpen
					PanelRow.Size=UDim2.new(1,0,0,pickerOpen and 210 or 0)
				end)

				local ctrl={}
				function ctrl:Set(c) curColor=c; H,S,V=Util.RGBtoHSV(c); SVCur.Position=UDim2.new(S,0,1-V,0); HueLine.Position=UDim2.new(0.5,0,H,0); apply() end
				function ctrl:Get() return curColor end; return ctrl
			end

			-- AddSeparator
			function sec:AddSeparator()
				sec._order=sec._order+1
				Util.New("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=Theme.Separator,BorderSizePixel=0,LayoutOrder=sec._order,Parent=Elems})
			end

			table.insert(self._sections,sec); return sec
		end -- CreateSection

		return tab
	end -- CreateTab

	table.insert(Ember._windows,win); return win
end -- CreateWindow

-- ─── THEME API ────────────────────────────────────────────────────────────────
function Ember:SetTheme(overrides)
	for k,v in pairs(overrides or {}) do
		if Theme[k]~=nil then
			Theme[k]=v
			if k=="Accent" then Theme.ToggleOn=v; applyThemeKey("ToggleOn",v) end
			applyThemeKey(k,v)
		end
	end
end
function Ember:GetTheme() local c={}; for k,v in pairs(Theme) do c[k]=v end; return c end
function Ember:GetVersion() return Ember._version end

return Ember
