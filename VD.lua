--[[
    EXE HUB UI Library
    x
    All rights reserved.
]]

-- Clean up all previously executed instances, threads and UI elements
pcall(function()
    if typeof(getgenv) == "function" and type(getgenv()._EXEHUB_CLEANUP) == "function" then
        pcall(getgenv()._EXEHUB_CLEANUP)
        getgenv()._EXEHUB_CLEANUP = nil
    end

    local priorCleanups = {
        "_VD_PERFECT_SKILLCHECK_CLEANUP",
        "_VD_FREEING_PERFECT_CLEANUP",
        "_VD_AUTOSKILL_CLEANUP",
        "_VD_RECORDER_CLEANUP",
        "_FREEING_DUMP_CLEANUP",
        "_AUTO_FREEING_CLEANUP",
        "_VD_DEEP_RECORDER_CLEANUP",
        "_VD_TEST_BENCH_CLEANUP"
    }
    for _, key in ipairs(priorCleanups) do
        if typeof(getgenv) == "function" and type(getgenv()[key]) == "function" then
            pcall(getgenv()[key])
            getgenv()[key] = nil
        end
    end

    if typeof(getgenv) == "function" and getgenv().ExeHubWindow then
        pcall(function()
            if not getgenv().ExeHubWindow._destroyed then
                getgenv().ExeHubWindow:Destroy()
            end
        end)
        getgenv().ExeHubWindow = nil
    end

    local searchLocs = {}
    if typeof(gethui) == "function" then
        pcall(function() table.insert(searchLocs, gethui()) end)
    end
    pcall(function() table.insert(searchLocs, game:GetService("CoreGui")) end)
    pcall(function()
        local lp = game:GetService("Players").LocalPlayer
        if lp and lp:FindFirstChild("PlayerGui") then
            table.insert(searchLocs, lp.PlayerGui)
        end
    end)

    local oldNames = { EXEHUB_UI = true, AirflowUI = true, ExeHub_ESP_Holder = true, VD_AutoSkill_HUD = true, VD_TrapRecorder_HUD = true, VD_SkillCheckRecorder = true }
    for _, loc in ipairs(searchLocs) do
        pcall(function()
            for _, gui in ipairs(loc:GetChildren()) do
                if (gui:IsA("ScreenGui") or gui:IsA("Folder")) and (oldNames[gui.Name] or gui.Name:find("EXEHUB") or gui:GetAttribute("ExeHubGui")) then
                    gui:Destroy()
                end
            end
        end)
    end

    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
        if p.Character then
            for _, item in ipairs(p.Character:GetDescendants()) do
                if item.Name == "ExeHub_HL" or item.Name == "ExeHub_Tag" then
                    pcall(function() item:Destroy() end)
                end
            end
        end
    end
end)

local O="Accent"local aa=game:GetService"TweenService"local p=game:GetService"UserInputService"local ao=game:GetService"GuiService"local ab=game:GetService"RunService"local H=game:GetService"HttpService"local I=game:GetService"Players"local J=I.LocalPlayer; if not J then pcall(function() local _st=tick() while not J and tick()-_st<3 do task.wait(0.1) J=I.LocalPlayer end end) end local e={}e.Flags={}e.Windows={}local function n(b,c)local a={}if type(b)=="string"then a.Name=b elseif type(b)=="table"then for b,c in pairs(b)do a[b]=c end end for b,c in pairs(c or{})do if a[c]==nil and a[b]~=nil then a[c]=a[b]end end if a.Range then a.Min=a.Min or a.Range[1]a.Max=a.Max or a.Range[2]end return a end local ac local function q(g,b,a,d,h,f)a._type=h a._frame=d a._listeners=a._listeners or{}local c=g and g.Window if b.Flag then e.Flags[b.Flag]=a if c then c.Flags[b.Flag]=a f=f or"Callback"local d=b[f]b[f]=function(...)if type(d)=="function"then d(...)end c:_autoSave()end end end function a:Destroy()if a._destroyed then return end a._destroyed=true for b,a in ipairs(a._listeners)do a()end a._listeners={}if b.Flag then if e.Flags[b.Flag]==a then e.Flags[b.Flag]=nil end if c and c.Flags[b.Flag]==a then c.Flags[b.Flag]=nil end end if c then c._controlsDirty=true end if d then d:Destroy()end end if d then ac(a,d,b)end return a end local K={"Background","Surface","Surface2","Surface3","Stroke","StrokeHover",O,"AccentDark","Text","Muted","Glow","Warning","Success","Error"}local function d(a,b,c)return Color3.fromRGB(a,b,c)end local ap={Warning=d(240,176,108),Success=d(150,220,170),Error=d(240,120,120)}local function x(a)for b,c in pairs(ap)do if a[b]==nil then a[b]=c end end return a end e.Themes={Default=x{Background=d(20,16,20),Surface=d(24,19,24),Surface2=d(28,22,28),Surface3=d(42,36,43),Stroke=d(40,32,41),StrokeHover=d(88,70,90),Accent=d(235,199,246),AccentDark=d(24,18,26),Text=d(233,229,234),Muted=d(138,127,139),Glow=d(226,218,230)},Midnight=x{Background=d(14,16,22),Surface=d(18,21,28),Surface2=d(22,25,34),Surface3=d(36,41,54),Stroke=d(32,36,48),StrokeHover=d(70,80,104),Accent=d(150,180,255),AccentDark=d(12,16,28),Text=d(226,230,240),Muted=d(122,131,153),Glow=d(210,220,240)},Moss=x{Background=d(15,18,15),Surface=d(19,23,19),Surface2=d(23,28,23),Surface3=d(37,44,37),Stroke=d(33,40,33),StrokeHover=d(72,88,72),Accent=d(176,222,170),AccentDark=d(14,22,14),Text=d(228,234,227),Muted=d(121,136,119),Glow=d(214,230,212)},Ember=x{Background=d(20,16,13),Surface=d(25,20,16),Surface2=d(30,24,19),Surface3=d(46,37,30),Stroke=d(42,34,27),StrokeHover=d(96,76,58),Accent=d(255,190,140),AccentDark=d(28,18,10),Text=d(240,232,226),Muted=d(146,129,113),Glow=d(240,222,208)},Rose=x{Background=d(21,14,17),Surface=d(26,18,21),Surface2=d(31,21,25),Surface3=d(48,34,40),Stroke=d(44,30,36),StrokeHover=d(100,66,80),Accent=d(255,170,195),AccentDark=d(30,12,18),Text=d(240,228,232),Muted=d(149,124,133),Glow=d(240,214,222)},Mono=x{Background=d(16,16,17),Surface=d(20,20,21),Surface2=d(24,24,26),Surface3=d(40,40,43),Stroke=d(36,36,39),StrokeHover=d(80,80,86),Accent=d(230,230,235),AccentDark=d(18,18,20),Text=d(232,232,236),Muted=d(130,130,136),Glow=d(220,220,226)}}e.Theme=table.clone(e.Themes.Default)e.ThemeName="Default"e.Assets={Shadow="rbxassetid://6014261993",Glow="rbxassetid://8992230677",Logo="rbxassetid://103859712365480"}local E local function P()if E~=nil then return E end local b,a=pcall(function()local a=game:HttpGet"https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua"return loadstring(a)()end)if b and type(a)=="table"then E=a else E=false warn("[EXE HUB] lucide icons unavailable: "..tostring(a))end return E end local aq={ValleySans={Regular="https://raw.githubusercontent.com/HelsinkiTypeStudio/valley-sans/main/fonts/ttf/ValleySans-Regular.ttf",Medium="https://raw.githubusercontent.com/HelsinkiTypeStudio/valley-sans/main/fonts/ttf/ValleySans-Medium.ttf",SemiBold="https://raw.githubusercontent.com/HelsinkiTypeStudio/valley-sans/main/fonts/ttf/ValleySans-SemiBold.ttf"}}local ad={Regular={400,Enum.FontWeight.Regular},Medium={500,Enum.FontWeight.Medium},SemiBold={600,Enum.FontWeight.SemiBold},Bold={700,Enum.FontWeight.Bold}}function e:LoadFont(b)local f="function"b=n(b,{})if type(writefile)~=f or type(isfile)~=f or typeof(getcustomasset)~=f then warn"[EXE HUB] custom fonts need writefile, isfile and getcustomasset"return false end local a=b.Name or"CustomFont"local g=b.Weights or aq[a]if type(g)~="table"then warn("[EXE HUB] no font weights for "..a)return false end local d=b.Folder or"ExeHubFonts"pcall(function()if type(isfolder)=="function"and type(makefolder)=="function"and not isfolder(d)then makefolder(d)end end)local h={}for b,e in pairs(g)do local c=ad[b]if c then local f,g=d.."/"..a.."-"..b..".ttf",true if not isfile(f)then g=pcall(function()writefile(f,game:HttpGet(e))end)end if g then table.insert(h,{name=b,weight=c[1],style="normal",assetId=getcustomasset(f)})else warn("[EXE HUB] could not download "..b.." weight of "..a)end end end if#h==0 then return false end local i=d.."/"..a..".json"local j=pcall(function()writefile(i,H:JSONEncode{name=a,faces=h})end)if not j then return false end local k=getcustomasset(i)local function c(a,c)local b=ad[a]if b and g[a]then return Font.new(k,b[2])end return c end e.Fonts.Regular=c("Regular",e.Fonts.Regular)e.Fonts.Medium=c("Medium",c("Regular",e.Fonts.Medium))e.Fonts.Bold=c("SemiBold",c("Bold",e.Fonts.Bold))return true end function e:PreloadIcons()return P()~=false end local fallbackIcons = {
    user = "rbxassetid://81589895647169",
    profile = "rbxassetid://81589895647169",
    eye = "rbxassetid://100033680381365",
    visual = "rbxassetid://100033680381365",
    zap = "rbxassetid://130551565616516",
    automatic = "rbxassetid://130551565616516",
    bot = "rbxassetid://80451686744860",
    cpu = "rbxassetid://77549309870247",
    cog = "rbxassetid://116544501716299",
    optimize = "rbxassetid://116544501716299",
    gauge = "rbxassetid://110273524101447",
    sun = "rbxassetid://130551565616516",
    server = "rbxassetid://92188766517878",
    sever = "rbxassetid://92188766517878",
    network = "rbxassetid://92188766517878",
    globe = "rbxassetid://10723346959",
    settings = "rbxassetid://80758916183665",
    setting = "rbxassetid://80758916183665",
    sliders = "rbxassetid://80758916183665",
    gamepad = "rbxassetid://10723374641",
    player = "rbxassetid://10723374641",
    crosshair = "rbxassetid://10734922324",
    wrench = "rbxassetid://116544501716299",
    shield = "rbxassetid://110987169760162"
}
local function ar(a)
    if typeof(a)=="table" then return a.Image,a.RectOffset,a.RectSize end
    if type(a)~="string" then return nil end
    if a:find"^rbxassetid://" or a:find"^rbxasset://" or a:find"^http" then return a end
    local d=a:gsub("^lucide:","")
    local b=P()
    if b and type(b)=="table" then
        local c=b[d] or (b.Icons and b.Icons[d])
        if type(c)=="string" then return c end
        if type(c)=="table" then
            local img=c.Image
            if type(img)=="number" then img="rbxassetid://"..tostring(img) end
            local s=b.Spritesheets and b.Spritesheets[tostring(img)] or img
            return s,c.ImageRectPosition,c.ImageRectSize
        end
    end
    if fallbackIcons[d] then return fallbackIcons[d] end
    warn("[EXE HUB] unknown lucide icon: "..d)
    return nil
end local Q="rbxasset://fonts/families/BuilderSans.json"e.Fonts={Regular=Font.new(Q,Enum.FontWeight.Regular),Medium=Font.new(Q,Enum.FontWeight.Medium),Bold=Font.new(Q,Enum.FontWeight.SemiBold)}local a=e.Theme local v=e.Assets local j=e.Fonts local m=p.TouchEnabled and not p.KeyboardEnabled e.Touch=m local R=m and 54 or 48 local y=m and 70 or 64 local S=m and 40 or 34 local t=m and 34 or 28 local ae={}local function b(e,f,a,b,c)a=a or.2 if a<=0 then for a,b in pairs(f)do e[a]=b end return nil end b=b or Enum.EasingStyle.Quart c=c or Enum.EasingDirection.Out local g=a..b.Name..c.Name local d=ae[g]if not d then d=TweenInfo.new(a,b,c)ae[g]=d end local h=aa:Create(e,d,f)h:Play()return h end local function c(d,b,c)local a=Instance.new(d)for b,c in pairs(b)do if b~="Parent"then a[b]=c end end if c then for c,b in ipairs(c)do b.Parent=a end end if b.Parent then a.Parent=b.Parent end return a end local function g(a,b)return c("UICorner",{CornerRadius=b or UDim.new(0,8),Parent=a})end local function i(b,d,e,f)return c("UIStroke",{Color=d or a.Stroke,Transparency=e or 0,Thickness=f or 1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=b})end local function o(a,b,d,e,f)return c("UIPadding",{PaddingLeft=UDim.new(0,b or 0),PaddingRight=UDim.new(0,d or 0),PaddingTop=UDim.new(0,e or 0),PaddingBottom=UDim.new(0,f or 0),Parent=a})end local function f(d)local b={BackgroundTransparency=1,TextColor3=a.Text,TextSize=14,FontFace=j.Medium,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,TextTruncate=Enum.TextTruncate.AtEnd}for a,c in pairs(d)do b[a]=c end return c("TextLabel",b)end local function z(d,e,f,g,h)local b=c("ImageLabel",{AnchorPoint=Vector2.new(.5,.5),Position=f,Size=e,BackgroundTransparency=1,Image=v.Glow,ImageColor3=a.Glow,ImageTransparency=g,ZIndex=0,Parent=d})c("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(255,255,255),a.Accent),Rotation=h or 90,Parent=b})return b end local function T(a)return c("Frame",{Position=UDim2.fromOffset(0,0),Size=UDim2.new(1,0,0,1),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.93,BorderSizePixel=0,ZIndex=0,Parent=a})end local function u(a,c)local b,d,e=ar(c)if not b then return end a.Image=b a.ImageRectOffset=d or Vector2.zero a.ImageRectSize=e or Vector2.zero end local function as()
    local b
    if typeof(gethui)=="function" then
        pcall(function()
            local h=gethui()
            if typeof(h)=="Instance" then b=h end
        end)
    end
    if b then return b end
    local canCore,cg=false,nil
    pcall(function()
        cg=game:GetService"CoreGui"
        local test=Instance.new"Folder"
        test.Parent=cg
        test:Destroy()
        canCore=true
    end)
    if canCore and cg then return cg end
    local lp=J or I.LocalPlayer
    if lp then
        local pg=lp:FindFirstChild"PlayerGui" or lp:WaitForChild("PlayerGui",5)
        if pg then return pg end
    end
    local fb
    pcall(function() fb=game:GetService"CoreGui" end)
    return fb or (lp and lp:WaitForChild("PlayerGui",5))
end local af,ag=nil,Vector2.zero local function s()local a=time()if af~=a then af=a ag=ao:GetGuiInset()end return p:GetMouseLocation()-ag end local function r(a)return a.UserInputType==Enum.UserInputType.MouseButton1 or a.UserInputType==Enum.UserInputType.Touch end local function U(a)return a.UserInputType==Enum.UserInputType.MouseMovement or a.UserInputType==Enum.UserInputType.Touch end local function A(d,e,f,g)local a=c("Frame",{AnchorPoint=Vector2.new(0,.5),Position=g,Size=UDim2.fromOffset(16,16),BackgroundTransparency=1,Parent=d})local b=c("ImageLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ImageColor3=f,ScaleType=Enum.ScaleType.Fit,Parent=a})u(b,e)return a,b end local function ah(j,g,k)local h=c("Frame",{AnchorPoint=Vector2.new(g,.5),Position=UDim2.new(g,k,.5,0),Size=UDim2.fromOffset(18,18),BackgroundTransparency=1,Parent=j})local d={}local e=c("ImageLabel",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(16,16),BackgroundTransparency=1,ImageColor3=a.Muted,ScaleType=Enum.ScaleType.Fit,Parent=h})u(e,"chevron-down")if e.Image~=""then function d:Set(c)b(e,{Rotation=c and 180 or 0,ImageColor3=c and a.Accent or a.Muted},.3,Enum.EasingStyle.Quint)end return d end e:Destroy()local function i(b,c)return f{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(18,18),Text="›",TextSize=22,TextXAlignment=Enum.TextXAlignment.Center,TextColor3=a.Muted,TextTransparency=c,Rotation=b,Parent=h}end local l=i(90,0)local m=i(270,1)function d:Set(c)b(l,{TextTransparency=c and 1 or 0},.2)b(m,{TextTransparency=c and 0 or 1,TextColor3=c and a.Accent or a.Muted},.2)end return d end local V={}local function at(e,i)local f=s()local h=math.max(e.AbsoluteSize.X,e.AbsoluteSize.Y)*2.2 local d=table.remove(V)if not d then d=c("Frame",{AnchorPoint=Vector2.new(.5,.5),BorderSizePixel=0})g(d,UDim.new(1,0))end d.BackgroundColor3=i or a.Accent d.Position=UDim2.fromOffset(f.X-e.AbsolutePosition.X,f.Y-e.AbsolutePosition.Y)d.Size=UDim2.fromOffset(0,0)d.BackgroundTransparency=.82 d.ZIndex=e.ZIndex+1 d.Parent=e b(d,{Size=UDim2.fromOffset(h,h),BackgroundTransparency=1},.55)task.delay(.55,function()if d.Parent~=e then return end d.Parent=nil if#V<4 then table.insert(V,d)else d:Destroy()end end)end local function w(c)if not c then return end b(c,{Color=a.Accent,Transparency=.2},.08)task.delay(.12,function()b(c,{Color=a.Stroke,Transparency=0},.35)end)end local function L(c,d)c.MouseEnter:Connect(function()b(d,{Color=a.StrokeHover},.12)end)c.MouseLeave:Connect(function()b(d,{Color=a.Stroke},.25)end)end local au={[Enum.KeyCode.LeftControl]="LCtrl",[Enum.KeyCode.RightControl]="RCtrl",[Enum.KeyCode.LeftShift]="LShift",[Enum.KeyCode.RightShift]="RShift",[Enum.KeyCode.LeftAlt]="LAlt",[Enum.KeyCode.RightAlt]="RAlt",[Enum.KeyCode.Return]="Enter",[Enum.KeyCode.Escape]="Esc",[Enum.KeyCode.Backspace]="Backspace"}local function W(a)if a==nil then return"None"end return au[a]or a.Name end local function F(a)if typeof(a)=="EnumItem"then return a end if type(a)~="string"or a==""or a=="None"then return nil end local b,c=pcall(function()return Enum.KeyCode[a]end)if b then return c end warn("[EXE HUB] unknown key name: "..a)return nil end local function l(a,...)if type(a)~="function"then return end local b,c=pcall(a,...)if not b then warn("[EXE HUB] callback error: "..tostring(c))end end local function ai(b,c,a)if c<b then b,c=c,b end if not a or a<=0 then a=1 end local d=0 while d<6 do local b=a*10^d if math.abs(b-math.floor(b+.5))<1e-9 then break end d+=1 end local e="%."..d.."f"return{snap=function(d)d=math.floor(d/a+.5)*a d=tonumber(string.format(e,d))or d return math.clamp(d,b,c)end,format=function(a)return string.format(e,a)end}end local function G(e,f,h,k)local d={Size=UDim2.new(1,0,0,h),BackgroundColor3=a.Surface2,BorderSizePixel=0,LayoutOrder=e:_nextOrder(),Parent=e.List}if f=="TextButton"then d.AutoButtonColor=false d.Text=""end local b=c(f,d)b:SetAttribute("NoDrag",true)g(b)local j=i(b,a.Stroke)return b,j end local function M(b,e,g,c)local d,h if g then local i=(y-38)/2 d=f{Name="Title",Position=UDim2.fromOffset(14,i),Size=UDim2.new(1,-(14+c),0,18),Text=e,Parent=b}h=f{Name="Desc",Position=UDim2.fromOffset(14,i+20),Size=UDim2.new(1,-(14+c),0,17),Text=g,TextSize=13,FontFace=j.Regular,TextColor3=a.Muted,Parent=b}else d=f{Name="Title",Position=UDim2.fromOffset(14,0),Size=UDim2.new(1,-(14+c),1,0),Text=e,Parent=b}end return d,h end local function B(h,a,i,j,c,k)a=n(a,i)local d=a.Desc and y or R local b,e=G(h,j or"Frame",d,a)L(b,e)local f,g if c then f,g=M(b,a.Name or k,a.Desc,c)end return a,b,e,d,f,g end local function N(a,b,c)if a then a.Size=UDim2.new(1,-(14+c),a.Size.Y.Scale,a.Size.Y.Offset)end if b then b.Size=UDim2.new(1,-(14+c),0,b.Size.Y.Offset)end end ac=function(b,e,h)local function j(a)return e:FindFirstChild(a,true)end if b.SetTitle==nil then function b:SetTitle(b)local a=j"Title"if a then a.Text=tostring(b)end end end if b.SetDesc==nil then function b:SetDesc(b)local a=j"Desc"if a then a.Text=tostring(b)else warn"[EXE HUB] SetDesc needs the element to be created with a Desc"end end end b.Visible=true function b:SetVisible(a)b.Visible=a~=false e.Visible=b.Visible end b.Locked=false local d,k function b:SetLocked(h,j)b.Locked=h==true if b.Locked and type(b.SetOpen)=="function"then b:SetOpen(false)end if not d then if not b.Locked then return end d=c("TextButton",{Name="Lock",Size=UDim2.fromScale(1,1),BackgroundColor3=a.Background,BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=20,Parent=e})g(d)local h=c("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),Size=UDim2.fromOffset(0,t),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=a.Surface,BorderSizePixel=0,ZIndex=21,Parent=d})g(h,UDim.new(0,6))i(h)o(h,8,10)c("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,VerticalAlignment=Enum.VerticalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6),Parent=h})local j=c("ImageLabel",{Size=UDim2.fromOffset(14,14),BackgroundTransparency=1,ImageColor3=a.Muted,ScaleType=Enum.ScaleType.Fit,LayoutOrder=1,ZIndex=22,Parent=h})u(j,"lock")k=f{Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,TextSize=12,TextColor3=a.Muted,TextTruncate=Enum.TextTruncate.None,LayoutOrder=2,ZIndex=22,Parent=h}end k.Text=j or"Locked"d.Visible=b.Locked d.BackgroundTransparency=b.Locked and.35 or 1 end if h.Locked then b:SetLocked(true,h.LockedReason)end if h.Visible==false then b:SetVisible(false)end end local k={}k.__index=k function k:_nextOrder()self._order+=1 return self._order end function k:Section(b)if type(b)=="table"then b=b.Name or b.Title or""end local d=c("Frame",{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,LayoutOrder=self:_nextOrder(),Parent=self.List})local e=f{Position=UDim2.fromOffset(2,8),Size=UDim2.new(0,0,0,16),AutomaticSize=Enum.AutomaticSize.X,Text=string.upper(b),TextSize=12,TextColor3=a.Muted,TextTruncate=Enum.TextTruncate.None,Parent=d}local h=c("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,0,16),Size=UDim2.new(1,-12,0,1),BackgroundColor3=a.Stroke,BorderSizePixel=0,Parent=d})local i=self.Window local function g()h.Size=UDim2.new(1,-(e.AbsoluteSize.X/i.Scale.Scale+14),0,1)end e:GetPropertyChangedSignal"AbsoluteSize":Connect(g)task.defer(g)return q(self,{},{Set=function(b,a)e.Text=string.upper(a)end},d,"Section")end function k:Divider()local b=c("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=a.Stroke,BorderSizePixel=0,LayoutOrder=self:_nextOrder(),Parent=self.List})return q(self,{},{},b,"Divider")end function k:Label(b)b=n(b,{Name="Text",Title="Text"})local c=f{Size=UDim2.new(1,0,0,18),Text=b.Text or"",TextSize=13,FontFace=j.Regular,TextColor3=b.Color or a.Muted,LayoutOrder=self:_nextOrder(),Parent=self.List}o(c,2)local d={Set=function(b,a)c.Text=tostring(a)end,Get=function()return c.Text end}if type(b.Update)=="function"then local a,e=math.max(tonumber(b.UpdateRate)or 1,.05),true d._listeners=d._listeners or{}table.insert(d._listeners,function()e=false end)task.spawn(function()while e and c.Parent do local e,d=pcall(b.Update)if e and d~=nil then c.Text=tostring(d)elseif not e then warn("[EXE HUB] label update error: "..tostring(d))end task.wait(a)end end)function d:SetUpdateRate(b)a=math.max(tonumber(b)or a,.05)end end return q(self,b,d,c,"Label")end function k:Paragraph(b)b=n(b,{Title="Name"})local d=G(self,"Frame",0,b)d.AutomaticSize=Enum.AutomaticSize.Y o(d,14,14,11,12)c("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4),Parent=d})f{Name="Title",Size=UDim2.new(1,0,0,14),Text=b.Name or"",LayoutOrder=1,Parent=d}local e=f{Name="Content",Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Text=b.Content or"",TextSize=13,FontFace=j.Regular,TextColor3=a.Muted,TextWrapped=true,TextTruncate=Enum.TextTruncate.None,TextYAlignment=Enum.TextYAlignment.Top,LayoutOrder=2,Parent=d}return q(self,b,{Set=function(b,a)e.Text=tostring(a)end,Get=function()return e.Text end},d,"Paragraph")end local av={Primary=O,Danger="Error"}function k:Button(d)d=n(d,{Title="Name",Description="Desc"})local i=av[d.Style]local e=i~=nil local j=d.Desc and y or R local c,f=G(self,"TextButton",j,d)c.ClipsDescendants=true if e then c.BackgroundColor3=a[i]c.BackgroundTransparency=.12 f.Color=a[i]f.Transparency=.4 c.MouseEnter:Connect(function()b(c,{BackgroundTransparency=0},.12)b(f,{Transparency=0},.12)end)c.MouseLeave:Connect(function()b(c,{BackgroundTransparency=.12},.25)b(f,{Transparency=.4},.25)end)else L(c,f)end local k,g=e and a.AccentDark or a.Text,0 if d.Icon then A(c,d.Icon,e and a.AccentDark or a.Accent,UDim2.new(0,14,.5,0))g=26 end local m=M(c,d.Name or"Button",d.Desc,30)if g>0 then for b,a in ipairs(c:GetChildren())do if a:IsA"TextLabel"then a.Position+=UDim2.fromOffset(g,0)a.Size-=UDim2.fromOffset(g,0)end end end if e then for b,a in ipairs(c:GetChildren())do if a:IsA"TextLabel"then a.TextColor3=k end end end A(c,"chevron-right",e and a.AccentDark or a.Muted,UDim2.new(1,-30,.5,0))c.MouseButton1Click:Connect(function()at(c,e and a.AccentDark or a.Accent)l(d.Callback)end)local h={}function h:SetText(a)m.Text=tostring(a)end h.SetTitle=h.SetText return q(self,d,h,c,"Button")end function k:Toggle(e)local j,n e,j,n=B(self,e,{Title="Name",Description="Desc",CurrentValue="Default",Value="Default"},"TextButton",56,"Toggle")local f=c("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-14,.5,0),Size=m and UDim2.fromOffset(44,24)or UDim2.fromOffset(36,20),BackgroundColor3=a.Surface3,BorderSizePixel=0,Parent=j})g(f,UDim.new(1,0))i(f,a.Stroke)local h=c("Frame",{AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,3,.5,0),Size=m and UDim2.fromOffset(18,18)or UDim2.fromOffset(14,14),BackgroundColor3=a.Muted,BorderSizePixel=0,Parent=f})g(h,UDim.new(1,0))local p=c("ImageLabel",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.new(1,24,1,24),BackgroundTransparency=1,Image=v.Glow,ImageColor3=a.Accent,ImageTransparency=1,ZIndex=0,Parent=f})local d={Value=e.Default==true}local function o(i)local e=d.Value local g=i and.25 or 0 b(f,{BackgroundColor3=e and a.Accent or a.Surface3},g)b(p,{ImageTransparency=e and.75 or 1},g)local c=m and 18 or 14 b(h,{Position=e and UDim2.new(0,(m and 44 or 36)-3-c,.5,0)or UDim2.new(0,3,.5,0)},g,Enum.EasingStyle.Back)b(h,{BackgroundColor3=e and a.AccentDark or a.Muted},g)if i then b(h,{Size=UDim2.fromOffset(c+4,c-2)},.08)task.delay(.08,function()b(h,{Size=UDim2.fromOffset(c,c)},.2,Enum.EasingStyle.Back)end)end end local k=false function d:Set(a,b)a=a==true if a==d.Value then return end d.Value=a o(true)if not k then w(n)end if not b then l(e.Callback,a)end end function d:Get()return d.Value end o(false)j.MouseButton1Click:Connect(function()k=true d:Set(not d.Value)k=false end)local r=q(self,e,d,j,"Toggle")if d.Value then l(e.Callback,true)end return r end function k:Slider(d)local B="Frame"d=n(d,{Title="Name",Description="Desc",CurrentValue="Default",Value="Default",Increment="Step"})local k=math.min(d.Min or 0,d.Max or 100)local C=math.max(d.Min or 0,d.Max or 100)local W=d.Step or 1 local H=d.Suffix or""local I=ai(k,C,W)local N=y+(d.Desc and 18 or 0)local t,Q=G(self,B,N,d)L(t,Q)f{Name="Title",Position=UDim2.fromOffset(14,12),Size=UDim2.new(1,-120,0,18),Text=d.Name or"Slider",Parent=t}if d.Desc then f{Name="Desc",Position=UDim2.fromOffset(14,31),Size=UDim2.new(1,-28,0,17),Text=d.Desc,TextSize=13,FontFace=j.Regular,TextColor3=a.Muted,Parent=t}end local o=c(B,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,9),Size=UDim2.fromOffset(40,24),BackgroundColor3=a.Surface,BorderSizePixel=0,ClipsDescendants=true,Parent=t})g(o,UDim.new(0,6))local J=i(o)local z=f{Size=UDim2.new(1,0,1,0),TextSize=13,TextColor3=a.Accent,TextXAlignment=Enum.TextXAlignment.Center,TextTruncate=Enum.TextTruncate.None,Parent=o}local h=c("TextBox",{Position=UDim2.fromOffset(9,0),Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=1,Text="",TextColor3=a.Text,TextSize=13,FontFace=j.Medium,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,Visible=false,Parent=o})c("UISizeConstraint",{MinSize=Vector2.new(14,0),Parent=h})local K=f{Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,Text=H,TextSize=13,TextColor3=a.Accent,TextTruncate=Enum.TextTruncate.None,Visible=false,Parent=o}local D,E=c("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=2,Parent=o}),false local function F(c)local a if E then a=9+h.AbsoluteSize.X/self.Window.Scale.Scale+K.TextBounds.X+9 K.Position=UDim2.fromOffset(9+h.AbsoluteSize.X/self.Window.Scale.Scale,0)else a=z.TextBounds.X+18 end a=math.max(a,36)if c then o.Size=UDim2.fromOffset(a,24)else b(o,{Size=UDim2.fromOffset(a,24)},.2)end end z:GetPropertyChangedSignal"TextBounds":Connect(function()if not E then F(false)end end)h:GetPropertyChangedSignal"AbsoluteSize":Connect(function()if E then F(false)end end)local u=c(B,{Position=UDim2.new(0,14,0,N-18),Size=UDim2.new(1,-28,0,5),BackgroundColor3=a.Surface3,BorderSizePixel=0,Parent=t})g(u,UDim.new(1,0))local R=c(B,{Size=UDim2.new(0,0,1,0),BackgroundColor3=a.Accent,BorderSizePixel=0,Parent=u})g(R,UDim.new(1,0))local x=c("ImageLabel",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(0,0,.5,0),Size=UDim2.fromOffset(28,28),BackgroundTransparency=1,Image=v.Glow,ImageColor3=a.Accent,ImageTransparency=.85,ZIndex=2,Parent=u})local A=c(B,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(0,0,.5,0),Size=UDim2.fromOffset(12,12),BackgroundColor3=a.Accent,BorderSizePixel=0,ZIndex=3,Parent=u})g(A,UDim.new(1,0))local O=c("TextButton",{Position=UDim2.new(0,8,0,N-(m and 37 or 31)),Size=UDim2.new(1,-16,0,m and 40 or 28),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=4,Parent=t})local e,p={Value=math.clamp(d.Default or k,k,C)},false D.MouseEnter:Connect(function()b(J,{Color=a.StrokeHover},.12)end)D.MouseLeave:Connect(function()if not h:IsFocused()then b(J,{Color=a.Stroke},.2)end end)D.MouseButton1Click:Connect(function()E=true h.Text=I.format(e.Value)z.Visible=false h.Visible=true K.Visible=H~=""D.Visible=false b(J,{Color=a.StrokeHover},.12)h:CaptureFocus()task.defer(F,false)end)h.FocusLost:Connect(function()local c=tonumber(h.Text)E=false h.Visible=false K.Visible=false z.Visible=true D.Visible=true b(J,{Color=a.Stroke},.2)if c then e:Set(c)end F(false)end)O.MouseEnter:Connect(function()if not p then b(x,{ImageTransparency=.78,Size=UDim2.fromOffset(34,34)},.15)end end)O.MouseLeave:Connect(function()if not p then b(x,{ImageTransparency=.85,Size=UDim2.fromOffset(28,28)},.2)end end)local S=I.snap local function M()return C-k==0 and 0 or(e.Value-k)/(C-k)end local function P(c,d,a)a=a or Enum.EasingStyle.Linear b(R,{Size=UDim2.new(c,0,1,0)},d,a)b(A,{Position=UDim2.new(c,0,.5,0)},d,a)b(x,{Position=UDim2.new(c,0,.5,0)},d,a)end local function T(a,b)P(M(),a,b)z.Text=I.format(e.Value)..H end local function X(b)local a=M()local c=math.max(u.AbsoluteSize.X,1)local d=(a>=b and 1 or-1)*(5/c)P(math.clamp(a+d,0,1),.22,Enum.EasingStyle.Quint)task.delay(.22,function()if not p then P(M(),.18,Enum.EasingStyle.Quint)end end)z.Text=I.format(e.Value)..H end local function Y()b(A,{Size=UDim2.fromOffset(14,12)},.08)b(x,{Size=UDim2.fromOffset(32,32),ImageTransparency=.78},.12)task.delay(.1,function()b(A,{Size=UDim2.fromOffset(12,12)},.25,Enum.EasingStyle.Quint)b(x,{Size=UDim2.fromOffset(28,28),ImageTransparency=.85},.25)end)end function e:Set(a,b)a=S(tonumber(a)or k)if a==e.Value then return end local c=M()e.Value=a if p then T(.05)else X(c)Y()w(Q)end if not b then l(d.Callback,a)end end function e:Get()return e.Value end local function V(b)local a=u.AbsoluteSize.X if a<=0 then return end local c=math.clamp((b-u.AbsolutePosition.X)/a,0,1)e:Set(k+(C-k)*c)end O.InputBegan:Connect(function(a)if r(a)then p=true b(A,{Size=UDim2.fromOffset(16,16)},.15,Enum.EasingStyle.Back)b(x,{Size=UDim2.fromOffset(44,44),ImageTransparency=.7},.15)V(s().X)end end)self.Window:_listen("Changed",function(a)if p and U(a)then V(s().X)end end,e)self.Window:_listen("Ended",function(a)if p and r(a)then p=false b(A,{Size=UDim2.fromOffset(12,12)},.2)b(x,{Size=UDim2.fromOffset(28,28),ImageTransparency=.85},.2)l(d.OnRelease,e.Value)end end,e)e.Value=S(e.Value)T(0)task.defer(F,true)return q(self,d,e,t,"Slider")end function k:Dropdown(d)local y="Frame"d=n(d,{Title="Name",Description="Desc",CurrentOption="Default",Value="Default",MultipleOptions="Multi",Values="Options"})if d.Multi and type(d.Default)~="table"and d.Default~=nil then d.Default={d.Default}elseif not d.Multi and type(d.Default)=="table"then d.Default=d.Default[1]end local s=d.Multi==true local o=d.Options or{}local p,L,x d,p,L,x=B(self,d,{},y)p.ClipsDescendants=true local G=c("TextButton",{Size=UDim2.new(1,0,0,x),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=p})local T,U=M(G,d.Name or"Dropdown",d.Desc,180)local r=c(y,{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),Size=UDim2.fromOffset(60,t),BackgroundColor3=a.Surface,BorderSizePixel=0,ClipsDescendants=true,Parent=G})g(r,UDim.new(0,6))local V=i(r)local H=f{Position=UDim2.fromOffset(10,0),Size=UDim2.new(1,-34,1,0),TextColor3=a.Muted,TextSize=13,TextTruncate=Enum.TextTruncate.None,ClipsDescendants=true,Parent=r}local W=ah(r,1,-6)local z,k=f{Size=UDim2.fromOffset(0,t),AutomaticSize=Enum.AutomaticSize.X,TextSize=13,Visible=false,Parent=r},""local function X()z.Text=k if z.TextBounds.X<=146 then return k end local c=utf8.len(k)local function d(a)if not c then return k:sub(1,a)end return k:sub(1,(utf8.offset(k,a+1)or#k+1)-1)end local a,b=0,(c or#k)-1 while a<b do local c=math.ceil((a+b)/2)z.Text=d(c)..".."if z.TextBounds.X<=146 then a=c else b=c-1 end end return d(a)..".."end local function O(c)local a=math.clamp(H.TextBounds.X+10+34,60,190)N(T,U,a+20)if c then r.Size=UDim2.fromOffset(a,t)else b(r,{Size=UDim2.fromOffset(a,t)},.2)end end H:GetPropertyChangedSignal"TextBounds":Connect(function()O(false)end)local I=c(y,{Position=UDim2.new(0,10,0,x),Size=UDim2.new(1,-20,0,0),BackgroundTransparency=1,Parent=p})c("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4),Parent=I})local e={Open=false}local h={}local m,A={},""local Y=d.SearchAfter or 6 local P=d.Placeholder or"None"local v=c(y,{Size=UDim2.new(1,0,0,S),BackgroundColor3=a.Surface,BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=0,Visible=false,Parent=I})g(v,UDim.new(0,6))local Z=i(v,a.Stroke,1)local C=c("TextBox",{Position=UDim2.fromOffset(12,0),Size=UDim2.new(1,-20,1,0),BackgroundTransparency=1,Text="",PlaceholderText="Search",PlaceholderColor3=a.Muted,TextColor3=a.Text,TextSize=13,FontFace=j.Regular,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,TextTransparency=1,Parent=v})local function Q(a)return A==""or string.find(string.lower(tostring(a)),A,1,true)~=nil end if s then for b,a in ipairs(d.Default or{})do h[a]=true end elseif d.Default~=nil then h[d.Default]=true end local function D()if s then local a={}for c,b in ipairs(o)do if h[b]then table.insert(a,b)end end return a end for b,a in ipairs(o)do if h[a]then return a end end return nil end local function E()local c=D()if s then local a={}for b,c in ipairs(c)do a[b]=tostring(c)end k=#a>0 and table.concat(a,", ")or P else k=c~=nil and tostring(c)or P end H.Text=X()for f,d in pairs(m)do local c=h[f]==true if d.On~=c then d.On=c b(d.Label,{TextColor3=c and a.Text or a.Muted},.15)if e.Open then b(d.Check,{ImageTransparency=c and 0 or 1},.15)b(d.CheckScale,{Scale=c and 1 or.6},c and.3 or.15,c and Enum.EasingStyle.Back or Enum.EasingStyle.Quint)end end end end local function aa()local a=0 for c,b in ipairs(o)do if Q(b)then a+=1 end end return a end local function J()for a,b in pairs(m)do b.Frame.Visible=Q(a)end end local function K()local a=aa()+(v.Visible and 1 or 0)return x+a*(S+4)+8 end local function F(c)e.Open=c v.Visible=#o>Y if not c then A=""C.Text=""J()end b(p,{Size=UDim2.new(1,0,0,c and K()or x)},.3,Enum.EasingStyle.Quint)b(v,{BackgroundTransparency=c and 0 or 1},.2)b(Z,{Transparency=c and 0 or 1},.2)b(C,{TextTransparency=c and 0 or 1},.2)W:Set(c)b(V,{Color=c and a.StrokeHover or a.Stroke},.2)local function d(d)if not d.Stroke then d.Stroke=i(d.Frame,a.Stroke,1)end local e=c and d.On b(d.Check,{ImageTransparency=e and 0 or 1},.18)d.CheckScale.Scale=e and 1 or.6 b(d.Label,{TextTransparency=c and 0 or 1},.18)b(d.Stroke,{Transparency=c and 0 or 1},.18)b(d.Frame,{BackgroundTransparency=c and 0 or 1},.18)end if c then local a=(e._openGeneration or 0)+1 e._openGeneration=a task.spawn(function()local b=true for g,f in ipairs(o)do local c=m[f]if c and c.Frame.Visible then if not b then task.wait(.025)if e._openGeneration~=a or not e.Open then return end end b=false d(c)end end end)else local b=(e._openGeneration or 0)+1 e._openGeneration=b local a={}for d,c in ipairs(o)do local b=m[c]if b and b.Frame.Visible then table.insert(a,b)end end task.spawn(function()for c=#a,1,-1 do d(a[c])if c>1 then task.wait(.015)if e._openGeneration~=b or e.Open then return end end end end)end end local function R()local i={}for a,b in ipairs(o)do i[b]=a end for a,b in pairs(m)do if not i[a]then b.Frame:Destroy()m[a]=nil end end for n,e in ipairs(o)do local o=m[e]if o then o.Frame.LayoutOrder=n continue end local i=c("TextButton",{Size=UDim2.new(1,0,0,S),BackgroundColor3=a.Surface,BackgroundTransparency=1,Text="",AutoButtonColor=false,LayoutOrder=n,Parent=I})g(i,UDim.new(0,6))local j=c("ImageLabel",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),Size=UDim2.fromOffset(14,14),BackgroundTransparency=1,ImageColor3=a.Accent,ImageTransparency=1,ScaleType=Enum.ScaleType.Fit,Parent=i})u(j,"check")local p=c("UIScale",{Scale=.6,Parent=j})local k=f{Position=UDim2.fromOffset(12,-1),Size=UDim2.new(1,-36,1,0),Text=tostring(e),TextSize=13,TextColor3=a.Muted,TextTransparency=1,Parent=i}i.MouseEnter:Connect(function()b(k,{TextColor3=a.Text},.15)local c=m[e]if c and c.Stroke then b(c.Stroke,{Color=a.StrokeHover},.12)end end)i.MouseLeave:Connect(function()b(k,{TextColor3=h[e]and a.Text or a.Muted},.2)local c=m[e]if c and c.Stroke then b(c.Stroke,{Color=a.Stroke},.2)end end)i.MouseButton1Click:Connect(function()if h[e]then h[e]=nil else if not s then h={}end h[e]=true end E()l(d.Callback,D())if not s and h[e]then F(false)end end)m[e]={Frame=i,Label=k,Check=j,CheckScale=p,Stroke=nil,On=nil}end J()if e.Open then p.Size=UDim2.new(1,0,0,K())end end function e:Set(a,b)h={}if s then for b,a in ipairs(type(a)=="table"and a or{a})do h[a]=true end elseif a~=nil then h[a]=true end E()w(L)if not b then l(d.Callback,D())end end function e:Get()return D()end function e:Refresh(a,b)o=a or{}if not b then h={}end R()E()if e.Open then F(true)end end function e:SetOpen(a)F(a==true)end G.MouseButton1Click:Connect(function()F(not e.Open)end)C:GetPropertyChangedSignal"Text":Connect(function()A=string.lower(C.Text)J()if e.Open then b(p,{Size=UDim2.new(1,0,0,K())},.2,Enum.EasingStyle.Quint)end end)R()E()task.defer(O,true)return q(self,d,e,p,"Dropdown")end function k:Input(e)local k,s,x,t,u e,k,s,x,t,u=B(self,e,{Title="Name",Description="Desc",PlaceholderText="Placeholder",CurrentValue="Default",Value="Default"},"Frame",160,"Input")local f=c("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),Size=UDim2.fromOffset(170,30),BackgroundColor3=a.Surface,BorderSizePixel=0,Parent=k})g(f,UDim.new(0,6))local v=i(f)local m=e.Icon if m then A(f,m,a.Muted,UDim2.new(0,8,.5,0))end local o=tonumber(e.MaxLength)local function p(a)a=tostring(a or"")if o and#a>o then return a:sub(1,o)end return a end local d=c("TextBox",{Position=UDim2.fromOffset(m and 30 or 8,0),Size=UDim2.new(1,m and-38 or-16,1,0),BackgroundTransparency=1,Text=p(e.Default),PlaceholderText=e.Placeholder or"",PlaceholderColor3=a.Muted,TextColor3=a.Text,TextSize=14,FontFace=j.Regular,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=e.ClearOnFocus==true,TextTruncate=Enum.TextTruncate.None,ClipsDescendants=true,Parent=f})f.ClipsDescendants=true local r=false local y=(m and 30 or 8)+8 local function h(g)local h=k.AbsoluteSize.X/self.Window.Scale.Scale local c=math.clamp(h-14-110-20,100,200)local i=d.Text local e=d.TextBounds.X if#i==0 then e=math.min(d.TextBounds.X,90)end local a=math.clamp(e+y+12,90,c)+(r and 8 or 0)a=math.min(a,c+8)N(t,u,a+20)if g then f.Size=UDim2.fromOffset(a,30)else b(f,{Size=UDim2.fromOffset(a,30)},.18)end end k:GetPropertyChangedSignal"AbsoluteSize":Connect(function()h(true)end)d:GetPropertyChangedSignal"Text":Connect(function()local a=p(d.Text)if a~=d.Text then d.Text=a return end h(false)if d:IsFocused()then l(e.OnChanged,d.Text)end end)d:GetPropertyChangedSignal"TextBounds":Connect(function()h(false)end)task.defer(h,true)d.Focused:Connect(function()r=true b(v,{Color=a.StrokeHover},.15)h(false)end)d.FocusLost:Connect(function(c)r=false b(v,{Color=a.Stroke},.15)h(false)if e.Numeric and not tonumber(d.Text)then d.Text=""return end l(e.Callback,d.Text,c)end)local n={}function n:Set(a,b)d.Text=p(a)w(s)if not b then l(e.Callback,d.Text,false)end end function n:Get()return d.Text end function n:SetPlaceholder(a)d.PlaceholderText=tostring(a)end return q(self,e,n,k,"Input")end function k:Keybind(e)local n,o,y,r,s e,n,o,y,r,s=B(self,e,{Title="Name",Description="Desc",CurrentKeybind="Default",Value="Default"},"Frame",110,"Keybind")e.Default=F(e.Default)local u=e.Mode=="Hold"local h=c("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),Size=UDim2.fromOffset(44,t),BackgroundColor3=a.Surface,BorderSizePixel=0,Text="",AutoButtonColor=false,ClipsDescendants=true,Parent=n})g(h,UDim.new(0,6))local z=i(h)local k=f{Size=UDim2.new(1,0,1,0),TextSize=13,TextColor3=a.Muted,TextXAlignment=Enum.TextXAlignment.Center,TextTruncate=Enum.TextTruncate.None,Parent=h}local d={Value=e.Default,Listening=false,Held=false}local function v(c)local a=math.max(k.TextBounds.X+20,m and 44 or 36)N(r,s,a+20)if c then h.Size=UDim2.fromOffset(a,t)else b(h,{Size=UDim2.fromOffset(a,t)},.2)end end k:GetPropertyChangedSignal"TextBounds":Connect(function()v(false)end)local function j()k.Text=d.Listening and"..."or W(d.Value)b(z,{Color=d.Listening and a.StrokeHover or a.Stroke},.15)b(k,{TextColor3=d.Listening and a.Accent or a.Muted},.15)end local function x()if d.Held then d.Held=false l(e.Callback,false)end end function d:Set(a,b)local c=d.Listening x()a=F(a)d.Value=a d.Listening=false j()if not c then w(o)end if not b then l(e.OnChanged,a)end end h.MouseButton1Click:Connect(function()d.Listening=not d.Listening j()end)self.Window:_listen("Began",function(a,b)if a.UserInputType~=Enum.UserInputType.Keyboard then return end if d.Listening and p:GetFocusedTextBox()then d.Listening=false j()return end if d.Listening then self.Window._consumedKey=a.KeyCode self.Window._consumedAt=os.clock()if a.KeyCode==Enum.KeyCode.Escape then d.Listening=false j()elseif a.KeyCode==Enum.KeyCode.Backspace or a.KeyCode==Enum.KeyCode.Delete then d:Set(nil)else d:Set(a.KeyCode)end return end if b or d.Locked or d.Value==nil or a.KeyCode~=d.Value then return end if u then d.Held=true l(e.Callback,true)else l(e.Callback,a.KeyCode)end end,d)if u then self.Window:_listen("Ended",function(a)if a.KeyCode==d.Value then x()end end,d)end j()task.defer(v,true)function d:Get()return d.Value end return q(self,e,d,n,"Keybind","OnChanged")end function k:ColorPicker(h)local F,k,G,H="Default","Frame","TextButton","UIGradient"local m,K,v h,m,K,v=B(self,h,{Title="Name",Description="Desc",Color=F,CurrentValue=F,Value=F},k)m.ClipsDescendants=true local A=c(G,{Size=UDim2.new(1,0,0,v),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=m})M(A,h.Name or"Color",h.Desc,90)local C=c(k,{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-34,.5,0),Size=UDim2.fromOffset(36,20),BorderSizePixel=0,Parent=A})C:SetAttribute("ExeHubNoTheme",true)g(C,UDim.new(0,6))i(C,a.Stroke)local S=ah(A,1,-12)local n=c(k,{Position=UDim2.fromOffset(14,v+2),Size=UDim2.new(1,-28,0,156),BackgroundTransparency=1,Visible=false,Parent=m})local e=c(G,{Size=UDim2.new(1,-30,0,110),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Text="",AutoButtonColor=false,ClipsDescendants=true,Parent=n})g(e,UDim.new(0,6))local T=c(H,{Color=ColorSequence.new(Color3.new(1,1,1),Color3.new(1,0,0)),Parent=e})local V=c(k,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Parent=e})c(H,{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)},Rotation=90,Parent=V})local x=c(k,{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(10,10),BackgroundTransparency=1,ZIndex=3,Parent=e})g(x,UDim.new(1,0))i(x,Color3.new(1,1,1),0,2)local o=c(G,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Size=UDim2.fromOffset(14,110),BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=n})g(o,UDim.new(0,6))c(H,{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),ColorSequenceKeypoint.new(.16666666666666666,Color3.fromRGB(255,255,0)),ColorSequenceKeypoint.new(.3333333333333333,Color3.fromRGB(0,255,0)),ColorSequenceKeypoint.new(.5,Color3.fromRGB(0,255,255)),ColorSequenceKeypoint.new(.6666666666666666,Color3.fromRGB(0,0,255)),ColorSequenceKeypoint.new(.8333333333333334,Color3.fromRGB(255,0,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))},Rotation=90,Parent=o})local y=c(k,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,0,0),Size=UDim2.fromOffset(18,5),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=3,Parent=o})g(y,UDim.new(1,0))i(y,a.AccentDark,.4)local I=c(k,{Position=UDim2.fromOffset(6,122),Size=UDim2.fromOffset(118,28),BackgroundColor3=a.Surface,BorderSizePixel=0,Parent=n})g(I,UDim.new(0,6))local L=i(I)local p=c("TextBox",{Position=UDim2.fromOffset(14,0),Size=UDim2.new(1,-24,1,0),BackgroundTransparency=1,Text="",TextTruncate=Enum.TextTruncate.None,ClipsDescendants=false,TextColor3=a.Text,TextSize=13,FontFace=j.Regular,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,Parent=I})local W=f{Position=UDim2.fromOffset(134,122),Size=UDim2.new(1,-134,0,28),TextXAlignment=Enum.TextXAlignment.Right,TextSize=13,FontFace=j.Regular,TextColor3=a.Muted,Parent=n}local d={Open=false}local t=h.Default if type(t)=="string"then local a,b=pcall(Color3.fromHex,t)t=a and b or nil end if typeof(t)~="Color3"then t=a.Accent end local z,D,E=Color3.toHSV(t)local u local function N(a)return string.format("#%02X%02X%02X",math.floor(a.R*255+.5),math.floor(a.G*255+.5),math.floor(a.B*255+.5))end local function O(c)local a=Color3.fromHSV(z,D,E)d.Value=a C.BackgroundColor3=a T.Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromHSV(z,1,1))b(x,{Position=UDim2.fromScale(D,1-E)},c,Enum.EasingStyle.Linear)b(y,{Position=UDim2.new(.5,0,z,0)},c,Enum.EasingStyle.Linear)if not p:IsFocused()then p.Text=N(a)end W.Text=string.format("RGB %d, %d, %d",math.floor(a.R*255+.5),math.floor(a.G*255+.5),math.floor(a.B*255+.5))end local function J(a,b)O(a)if not b then l(h.Callback,d.Value)end end function d:Set(a,b)if type(a)=="string"then local b,c=pcall(Color3.fromHex,a)a=b and c or nil end if typeof(a)~="Color3"then warn"[EXE HUB] ColorPicker:Set expects a Color3 or hex string"return end z,D,E=Color3.toHSV(a)J(.25,b)w(K)end function d:Get()return d.Value end local function P(a)d.Open=a b(m,{Size=UDim2.new(1,0,0,a and v+168 or v)},.35,Enum.EasingStyle.Quint)S:Set(a)if a then n.Visible=true else task.delay(.35,function()if not d.Open then n.Visible=false end end)end end function d:SetOpen(a)P(a==true)end A.MouseButton1Click:Connect(function()P(not d.Open)end)local function Q(a)D=math.clamp((a.X-e.AbsolutePosition.X)/e.AbsoluteSize.X,0,1)E=1-math.clamp((a.Y-e.AbsolutePosition.Y)/e.AbsoluteSize.Y,0,1)J(.04)end local function R(a)z=math.clamp((a.Y-o.AbsolutePosition.Y)/o.AbsoluteSize.Y,0,.999)J(.04)end e.InputBegan:Connect(function(a)if r(a)then u="sv"b(x,{Size=UDim2.fromOffset(14,14)},.15,Enum.EasingStyle.Back)Q(s())end end)o.InputBegan:Connect(function(a)if r(a)then u="hue"b(y,{Size=UDim2.fromOffset(20,7)},.15,Enum.EasingStyle.Back)R(s())end end)self.Window:_listen("Changed",function(b)if not u or not U(b)then return end local a=s()if u=="sv"then Q(a)else R(a)end end,d)self.Window:_listen("Ended",function(a)if u and r(a)then u=nil b(x,{Size=UDim2.fromOffset(10,10)},.2)b(y,{Size=UDim2.fromOffset(18,5)},.2)end end,d)p.Focused:Connect(function()b(L,{Color=a.StrokeHover},.15)end)p.FocusLost:Connect(function()b(L,{Color=a.Stroke},.15)local c,e,f=p.Text:match"^%s*#?(%x%x)(%x%x)(%x%x)%s*$"if c then d:Set(Color3.fromRGB(tonumber(c,16),tonumber(e,16),tonumber(f,16)))else p.Text=N(d.Value)end end)O(0)return q(self,h,d,m,"ColorPicker")end function k:Stepper(e)local n,s,I,u,v e,n,s,I,u,v=B(self,e,{Title="Name",Description="Desc",CurrentValue="Default",Value="Default",Increment="Step"},"Frame",150,"Stepper")local k=math.min(e.Min or 0,e.Max or 100)local o=math.max(e.Min or 0,e.Max or 100)local x=e.Step or 1 local J=e.Suffix or""local y=ai(k,o,x)local h=c("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),Size=UDim2.fromOffset(0,t),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=a.Surface,BorderSizePixel=0,Parent=n})g(h,UDim.new(0,6))local z=i(h)c("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center,Parent=h})local function A(e,f)local d=c("TextButton",{Size=UDim2.fromOffset(t,t),BackgroundTransparency=1,Text=e,TextColor3=a.Muted,TextSize=18,FontFace=j.Medium,AutoButtonColor=false,LayoutOrder=f,Parent=h})d.MouseEnter:Connect(function()b(d,{TextColor3=a.Accent},.12)end)d.MouseLeave:Connect(function()b(d,{TextColor3=a.Muted},.2)end)return d end local C=A("−",1)local m=f{Size=UDim2.new(0,30,1,0),TextSize=13,TextColor3=a.Accent,TextXAlignment=Enum.TextXAlignment.Center,TextTruncate=Enum.TextTruncate.None,LayoutOrder=2,Parent=h}local D=A("+",3)local function E(c)local a=math.max(m.TextBounds.X+12,30)if c then m.Size=UDim2.new(0,a,1,0)else b(m,{Size=UDim2.new(0,a,1,0)},.2)end end m:GetPropertyChangedSignal"TextBounds":Connect(function()E(false)end)h:GetPropertyChangedSignal"AbsoluteSize":Connect(function()N(u,v,h.AbsoluteSize.X/self.Window.Scale.Scale+20)end)local d={Value=math.clamp(e.Default or k,k,o)}local K,p=y.snap,false local function F()m.Text=y.format(d.Value)..J b(C,{TextTransparency=d.Value<=k and.6 or 0},.15)b(D,{TextTransparency=d.Value>=o and.6 or 0},.15)end function d:Set(a,b)a=K(tonumber(a)or k)if a==d.Value then return end d.Value=a F()if not p then w(s)end if not b then l(e.Callback,a)end end function d:Get()return d.Value end local function G(c)p=true d:Set(d.Value+c*x)p=false b(z,{Color=a.StrokeHover},.08)task.delay(.12,function()b(z,{Color=a.Stroke},.2)end)end local L,M=.4,.07 local function H(a,e)local c,b=0,false a.InputBegan:Connect(function(f)if not r(f)then return end c+=1 local g=c b=true G(e)task.delay(L,function()while b and c==g and not d.Locked and not d._destroyed and a.Parent do G(e)task.wait(M)end end)end)a.InputEnded:Connect(function(a)if r(a)then b=false end end)a.MouseLeave:Connect(function()b=false end)end H(C,-1)H(D,1)F()task.defer(E,true)return q(self,e,d,n,"Stepper")end function k:Progress(d)d=n(d,{Title="Name",Description="Desc",CurrentValue="Default",Value="Default"})local h,s=G(self,"Frame",d.Desc and y+10 or R+10,d)L(h,s)local i=d.Desc and(y-38)/2-2 or 12 f{Name="Title",Position=UDim2.fromOffset(14,i),Size=UDim2.new(1,-110,0,18),Text=d.Name or"Progress",Parent=h}if d.Desc then f{Name="Desc",Position=UDim2.fromOffset(14,i+20),Size=UDim2.new(1,-110,0,17),Text=d.Desc,TextSize=13,FontFace=j.Regular,TextColor3=a.Muted,Parent=h}end local m=f{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,i),Size=UDim2.fromOffset(90,18),TextXAlignment=Enum.TextXAlignment.Right,TextSize=13,TextColor3=a.Accent,Parent=h}local o=c("Frame",{Position=UDim2.new(0,14,1,-16),Size=UDim2.new(1,-28,0,5),BackgroundColor3=a.Surface3,BorderSizePixel=0,Parent=h})g(o,UDim.new(1,0))local k=c("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=d.Color or a.Accent,BorderSizePixel=0,Parent=o})g(k,UDim.new(1,0))local e={Value=math.clamp(d.Default or 0,0,1)}local p=d.Format local function r(c)local a=e.Value b(k,{Size=UDim2.new(a,0,1,0)},c,Enum.EasingStyle.Quint)if type(p)=="function"then m.Text=tostring(p(a))else m.Text=string.format("%d%%",math.floor(a*100+.5))end end function e:Set(a,b)a=math.clamp(tonumber(a)or 0,0,1)if a==e.Value then return end e.Value=a r(.35)if not b then l(d.Callback,a)end end function e:Get()return e.Value end function e:SetColor(a)k.BackgroundColor3=a end r(0)return q(self,d,e,h,"Progress")end function k:ConfigManager(d)d=n(d,{})local a=self.Window local b={}self:Section(d.Name or"Configs")local e=self:Input{Name="Config name",Placeholder=a.ConfigName,Callback=function(a,c)if c and#a>0 then b:Save(a)end end}local c=self:Dropdown{Name="Saved configs",Options=a:ListConfigs(),Default=a.ConfigName,Callback=function(a)if a then e:Set(a,true)end end}function b:Refresh()c:Refresh(a:ListConfigs(),true)end function b:Save(e)e=e or c:Get()or a.ConfigName local d,f=a:SaveConfig(e)b:Refresh()if d then c:Set(a.ConfigName,true)end a:Notify{Title=d and"Config saved"or"Save failed",Content=d and a.ConfigName or tostring(f),Type=d and"Success"or"Error",Duration=3}end function b:Load(b)b=b or c:Get()if not b then return end local d,e=a:LoadConfig(b)a:Notify{Title=d and"Config loaded"or"Load failed",Content=d and b or tostring(e),Type=d and"Success"or"Error",Duration=3}end function b:Delete(d)d=d or c:Get()if not d then return end local e,f=a:DeleteConfig(d)b:Refresh()a:Notify{Title=e and"Config deleted"or"Delete failed",Content=e and d or tostring(f),Type=e and"Info"or"Error",Duration=3}end self:Button{Name="Save",Desc="Writes every flagged element to the selected name",Icon="save",Style="Primary",Callback=function()local a=e:Get()b:Save(#a>0 and a or nil)end}self:Button{Name="Load",Icon="folder-open",Callback=function()b:Load()end}self:Button{Name="Delete",Icon="trash-2",Callback=function()local d=c:Get()if not d then return end a:Confirm{Title="Delete config",Content="Remove "..d.."? This cannot be undone.",Icon="trash-2",ConfirmText="Delete",Callback=function()b:Delete(d)end}end}self:Toggle{Name="Auto save",Desc="Save whenever a flagged element changes",Default=a._autoSaveEnabled,Callback=function(b)a:SetAutoSave(b)end}return b end function k:ThemePicker(a)a=n(a,{Title="Name",Description="Desc"})local b=a.Callback return self:Dropdown{Name=a.Name or"Theme",Desc=a.Desc,Options=e:GetThemes(),Default=e.ThemeName,Flag=a.Flag,Callback=function(a)if a then e:SetTheme(a)end l(b,a)end}end function k:Folder(d)d=n(d,{Title="Name",Description="Desc"})local v=c("Frame",{Name="Folder_"..(d.Name or"Folder"),Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=self:_nextOrder(),Parent=self.List})c("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4),Parent=v})local h=c("TextButton",{Name="FolderHeader",Size=UDim2.new(1,0,0,42),BackgroundColor3=a.Surface2,BorderSizePixel=0,AutoButtonColor=false,Text="",LayoutOrder=1,Parent=v})g(h,UDim.new(0,8))local s=i(h,a.Stroke,1)L(h,s)local m=14 if d.Icon then local e,q=A(h,d.Icon,a.Accent,UDim2.new(0,14,.5,0))m=38 end f{Name="Title",Position=UDim2.fromOffset(m,d.Desc and 6 or 0),Size=UDim2.new(1,-(m+40),d.Desc and 0 or 1,d.Desc and 18 or 0),Text=d.Name or"Folder",TextSize=14,Parent=h}if d.Desc then f{Name="Desc",Position=UDim2.fromOffset(m,24),Size=UDim2.new(1,-(m+40),0,14),Text=d.Desc,TextSize=12,TextColor3=a.Muted,FontFace=j.Regular,Parent=h}end local C=f{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-14,.5,0),Size=UDim2.fromOffset(20,20),Text=">",TextSize=18,TextColor3=a.Muted,TextXAlignment=Enum.TextXAlignment.Center,Parent=h}local l=c("Frame",{Name="FolderContent",Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,ClipsDescendants=true,LayoutOrder=2,Parent=v})o(l,14,4,4,6)c("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6),Parent=l})local O=d.Default~=false local function u(e)l.Visible=O if e then b(C,{Rotation=O and 90 or 0,TextColor3=O and a.Accent or a.Muted},.2,Enum.EasingStyle.Quint)else C.Rotation=O and 90 or 0 C.TextColor3=O and a.Accent or a.Muted end end u(false)h.MouseButton1Click:Connect(function()O=not O u(true)end)return setmetatable({Window=self.Window,List=l,_order=0,_nextOrder=function(a)a._order+=1 return a._order end},{__index=k})end local aw={Select=true}function k:Select()self.Window:SelectTab(self)end for a,b in pairs(table.clone(k))do if type(b)=="function"and a:sub(1,1)~="_"and a:sub(1,6)~="Create"and not aw[a]then k["Create"..a]=b end end local function ax()local a pcall(function()if typeof(identifyexecutor)=="function"then a=(identifyexecutor())elseif typeof(getexecutorname)=="function"then a=getexecutorname()end end)if type(a)=="string"and#a>0 then return a end return ab:IsStudio()and"Studio"or"Unknown"end local function ay()local b,a=pcall(function()return game:GetService"MarketplaceService":GetProductInfo(game.PlaceId)end)if b and type(a)=="table"and a.Name then return a.Name end return"Unknown game"end local az={US="United States",GB="United Kingdom",DE="Germany",FR="France",NL="Netherlands",SG="Singapore",JP="Japan",AU="Australia",BR="Brazil",IN="India",HK="Hong Kong",CA="Canada"}local function aA(a)task.spawn(function()local b=request or http_request or syn and syn.request or http and http.request local c if type(b)=="function"then pcall(function()local a=b{Url="https://ipinfo.io/json",Method="GET"}local d=type(a)=="table"and(a.Body or a.body)or nil if type(d)=="string"then local a=H:JSONDecode(d)if type(a)=="table"and a.country then local b=az[a.country]or a.country c=a.city and a.city..", "..b or b end end end)end a(c or"Unavailable")end)end local aB={Info=O,Success="Success",Warning="Warning",Error="Error"}local h={}h.__index=h function e.Window(ac,k)if type(ac)=="table" and k==nil then k=ac end local H,q,I,M,J,B="EXEHUB_UI","Frame","CanvasGroup","UIListLayout","AbsoluteSize","table"k=n(k,{Name="Title",LoadingSubtitle="Subtitle",ToggleUIKeybind="Keybind"})if k.Theme~=nil then e:SetTheme(k.Theme)end local V=k.Size or UDim2.fromOffset(640,480)local N=F(k.Keybind)or Enum.KeyCode.RightControl local d=setmetatable({Tabs={},Flags={},CurrentTab=nil,Open=true,Keybind=N,_connections={},_controls={},_inputListeners={Began={},Changed={},Ended={},Render={}},_frameSteps={},_destroyed=false},h)local function C(a)return function(...)for b,a in ipairs(d._inputListeners[a])do a(...)end end end local X=C"Render"table.insert(d._connections,ab.RenderStepped:Connect(function(a)X(a)for c,b in ipairs(d._frameSteps)do b(a)end end))table.insert(d._connections,p.InputBegan:Connect(C"Began"))table.insert(d._connections,p.InputChanged:Connect(C"Changed"))table.insert(d._connections,p.InputEnded:Connect(C"Ended"))local s=c("ScreenGui",{Name=k.Name or H,IgnoreGuiInset=true,ResetOnSpawn=false,DisplayOrder=999,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})d.Gui=s local y=c(q,{Name="Window",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=V,BackgroundTransparency=1,Parent=s})d.Root=y local O=c("UIScale",{Parent=y})d.Scale=O local P=c("ImageLabel",{Position=UDim2.fromOffset(-25,-25),Size=UDim2.new(1,50,1,50),BackgroundTransparency=1,Image=v.Shadow,ImageColor3=Color3.new(0,0,0),ImageTransparency=.6,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(49,49,450,450),Parent=y})d.Shadow=P local l=c(I,{Name="Body",Size=UDim2.fromScale(1,1),BackgroundColor3=a.Background,BorderSizePixel=0,Parent=y})d.Body=l g(l,UDim.new(0,10))d.BodyStroke=i(l,a.Stroke)T(l)z(l,UDim2.fromOffset(500,180),UDim2.new(.5,0,1,8),.86,270)z(l,UDim2.fromOffset(130,60),UDim2.new(0,-10,1,-10),.75,90)z(l,UDim2.fromOffset(520,240),UDim2.new(1,-14,0,10),.92,90)local D=c(q,{Name="Sidebar",Size=UDim2.new(0,170,1,0),BackgroundTransparency=1,Parent=l})c(q,{Position=UDim2.new(0,170,0,28),Size=UDim2.new(0,1,1,-56),BackgroundColor3=a.Stroke,BorderSizePixel=0,Parent=l})local K=c(q,{Name="Header",Size=UDim2.new(1,0,0,72),BackgroundTransparency=1,Parent=D})local Q=c("ImageLabel",{Position=UDim2.fromOffset(22,27),Size=UDim2.fromOffset(30,28),BackgroundTransparency=1,Image="",ImageColor3=a.Accent,ScaleType=Enum.ScaleType.Fit,Parent=K})u(Q,k.Icon or v.Logo)d._logo=Q d._titleLabel=f{Position=UDim2.fromOffset(60,25),Size=UDim2.new(1,-70,0,20),Text=k.Title or"EXE HUB",TextSize=20,Parent=K}d._subtitleLabel=f{Position=UDim2.fromOffset(60,45),Size=UDim2.new(1,-70,0,14),Text=k.Subtitle or"x",TextSize=13,FontFace=j.Regular,TextColor3=a.Muted,Parent=K}local t=c("ScrollingFrame",{Name="Tabs",Position=UDim2.fromOffset(0,80),Size=UDim2.new(1,0,1,-116),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Parent=D})d.TabList=t if m then t:SetAttribute("NoDrag",true)end o(t,16,16,4,4)c(M,{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4),Parent=t})local E=c(q,{AnchorPoint=Vector2.new(0,.5),Position=UDim2.fromOffset(6,0),Size=UDim2.fromOffset(3,18),BackgroundColor3=a.Accent,BorderSizePixel=0,Visible=false,ZIndex=2,Parent=D})g(E,UDim.new(1,0))d.Indicator=E local R=t.CanvasPosition.Y table.insert(d._frameSteps,function()local b=t.CanvasPosition.Y if b==R or not d.CurrentTab or not d._introDone then return end R=b local a=d:_indicatorY(d.CurrentTab)local c=t.Position.Y.Offset local e=c+t.AbsoluteSize.Y/d.Scale.Scale E.Visible=a>c and a<e E.Position=UDim2.fromOffset(6,a)end)local S=c(q,{Position=UDim2.new(0,22,1,-36),Size=UDim2.new(1,-44,0,22),BackgroundTransparency=1,Parent=D})local x=c(q,{Size=UDim2.fromOffset(0,22),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=a.Surface,BorderSizePixel=0,Parent=S})g(x,UDim.new(0,5))i(x)o(x,7,7)local Y=f{Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,Text=W(N),TextSize=11,TextColor3=a.Muted,TextTruncate=Enum.TextTruncate.None,Parent=x}d._keyChipLabel=Y local Z=f{Size=UDim2.new(1,0,1,0),Text=m and"or tap the pill"or"to hide",TextSize=12,FontFace=j.Regular,TextColor3=a.Muted,Parent=S}local function U()Z.Position=UDim2.fromOffset(x.AbsoluteSize.X/d.Scale.Scale+8,0)end x:GetPropertyChangedSignal("AbsoluteSize"):Connect(U)task.defer(U)local G=c(q,{Name="Content",Position=UDim2.fromOffset(171,0),Size=UDim2.new(1,-171,1,0),BackgroundTransparency=1,ClipsDescendants=true,Parent=l})d.Content=G d._outLayer=c(I,{Name="TransitionOut",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,ZIndex=2,Parent=G})d._inLayer=c(I,{Name="TransitionIn",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,ZIndex=3,Parent=G})local w=c("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,14),Size=UDim2.fromOffset(34,34),BackgroundColor3=a.Surface2,BackgroundTransparency=1,Text="×",TextColor3=a.Muted,TextSize=28,FontFace=j.Bold,AutoButtonColor=false,ZIndex=5,Parent=G})o(w,0,0,1,0)g(w,UDim.new(0,8))w.MouseEnter:Connect(function()b(w,{BackgroundTransparency=0,TextColor3=a.Text},.15)end)w.MouseLeave:Connect(function()b(w,{BackgroundTransparency=1,TextColor3=a.Muted},.2)end)w.MouseButton1Click:Connect(function()d:Toggle(false)end)local L=c(q,{Name="Notifications",AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-20,1,-20),Size=UDim2.new(0,280,1,-40),BackgroundTransparency=1,Parent=s})local function aa()L.Size=UDim2.new(0,math.min(280,s.AbsoluteSize.X-40),1,-40)end table.insert(d._connections,s:GetPropertyChangedSignal("AbsoluteSize"):Connect(aa))c(M,{SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Bottom,Padding=UDim.new(0,4),Parent=L})d.NotifyHolder=L d._notifyOrder=0 d._toasts={}d.MaxNotifications=k.MaxNotifications or 4 d._controlsDirty=true table.insert(d._connections,l.DescendantAdded:Connect(function()d._controlsDirty=true end))table.insert(d._connections,l.DescendantRemoving:Connect(function()d._controlsDirty=true end))d:_enableDrag()d.MaxSize=k.MaxSize d.KeepOnScreen=k.KeepOnScreen~=false d:_enableResize(k.MinSize or Vector2.new(480,360))local A=k.ConfigurationSaving if type(A)==B and A.Enabled~=false then d.ConfigFolder=A.FolderName or H d.ConfigName=A.FileName or"default"d._autoSaveEnabled=A.AutoSave==true else d.ConfigFolder=H d.ConfigName="default"d._autoSaveEnabled=false end table.insert(d._connections,p.InputBegan:Connect(function(a,b)if b then return end if a.KeyCode==Enum.KeyCode.Escape and d._dialog and d._dialog.Dismissable then d._dialog.Cancel()return end if a.UserInputType==Enum.UserInputType.Keyboard and a.KeyCode==d.Keybind then task.defer(function()local b=d._consumedKey==a.KeyCode and os.clock()-(d._consumedAt or 0)<.2 d._consumedKey=nil if not b and not d._destroyed then d:Toggle(not d.Open)end end)end end))pcall(function()
    if typeof(syn)=="table" and typeof(syn.protect_gui)=="function" then
        syn.protect_gui(s)
    elseif typeof(protectgui)=="function" then
        protectgui(s)
    end
end)
local pOk = pcall(function()
    s.Parent = k.Parent or as()
end)
if not pOk or not s.Parent then
    pcall(function()
        local lp = J or I.LocalPlayer
        s.Parent = lp and lp:WaitForChild("PlayerGui", 5)
    end)
end
if not s.Parent then
    pcall(function() s.Parent = game:GetService("CoreGui") end)
end
if not s.Parent then
    pcall(function() local lp = J or I.LocalPlayer; s.Parent = lp and lp:FindFirstChildOfClass("PlayerGui") end)
end
s.Enabled = true
O.Scale=.9 l.GroupTransparency=1 P.ImageTransparency=1 d.BodyStroke.Transparency=1 y.Visible=false d:_fitToScreen(true)table.insert(d._connections,s:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()d:_fitToScreen()d:_clampToScreen()end))if k.OpenButton~=nil and k.OpenButton~=false or k.OpenButton==nil and m then d:_createOpenButton(type(k.OpenButton)==B and k.OpenButton or{})end d._introDone=false table.insert(e.Windows,d)if k.Home then d:_buildHome(type(k.Home)==B and k.Home or{})end local r=k.Loading if type(r)==B then k.LoadingDuration=r.Duration or k.LoadingDuration k.LoadingText=r.Text or r.Subtitle or k.LoadingText k.LoadingSteps=r.Steps or k.LoadingSteps k.LoadingTitle=r.Title or k.LoadingTitle r=r.Enabled~=false end if r==false then
    task.defer(function()d:_playIntro()end)
else
    local sOk = pcall(function() d:_showLoader(k) end)
    if not sOk then
        task.defer(function() d:_playIntro(true) end)
    end
end
task.delay(2.5, function()
    if not d._introDone and not d._destroyed then
        d:_playIntro(true)
    end
end)
return d end e.CreateWindow=e.Window local function C(a,b,d)local e=a[b]:ToHex()local c=d[e]if c then a[b]=c end end local function aC(a,d)local b=false local c={}for f,a in ipairs(a.Color.Keypoints)do local e=d[a.Value:ToHex()]if e then b=true end c[f]=ColorSequenceKeypoint.new(a.Time,e or a.Value)end if b then a.Color=ColorSequence.new(c)end end local function aD(a,b)if a:GetAttribute"ExeHubNoTheme"then return end if a:IsA"GuiObject"then C(a,"BackgroundColor3",b)end if a:IsA"TextLabel"or a:IsA"TextButton"or a:IsA"TextBox"then C(a,"TextColor3",b)end if a:IsA"TextBox"then C(a,"PlaceholderColor3",b)end if a:IsA"ImageLabel"or a:IsA"ImageButton"then C(a,"ImageColor3",b)end if a:IsA"ScrollingFrame"then C(a,"ScrollBarImageColor3",b)end if a:IsA"UIStroke"then C(a,"Color",b)elseif a:IsA"UIGradient"then aC(a,b)end end local function aj(a)for c,b in ipairs(e.Windows)do if b.Gui and b.Gui.Parent then for c,b in ipairs(b.Gui:GetDescendants())do aD(b,a)end end end end local function ak(a)if type(a)=="string"then local b=e.Themes[a]if not b then warn("[EXE HUB] unknown theme: "..a)return nil end return table.clone(b),a elseif type(a)=="table"then local c=e.Themes[a.Base or"Default"]or e.Themes.Default local b=table.clone(c)for d,c in ipairs(K)do if typeof(a[c])=="Color3"then b[c]=a[c]end end return b,a.Name or"Custom"end warn"[EXE HUB] SetTheme expects a theme name or a table of colours"return nil end function e:GetThemes()local a={}for b in pairs(e.Themes)do if b~="Default"then table.insert(a,b)end end table.sort(a)table.insert(a,1,"Default")return a end function e:AddTheme(a,c)assert(type(a)=="string"and a~="","AddTheme needs a name")local b=ak(c)if b then e.Themes[a]=b end return b~=nil end local X=0 function e:SetTheme(g)local b,h=ak(g)if not b then return false end local c,d={},{}for c,a in ipairs(K)do d[b[a]:ToHex()]=true end for h,d in ipairs(K)do local e,f=a[d],b[d]local g=e:ToHex()if e~=f and c[g]==nil then c[g]=f end end for d,c in ipairs(K)do a[c]=b[c]end e.ThemeName=h aj(c)X+=1 local i=X local f={}for a,b in pairs(c)do if not d[a]then f[a]=b end end task.delay(.6,function()if i==X then aj(f)end end)return true end function e:Notify(b)local a=e.Windows[#e.Windows]if a then return a:Notify(b)end end function e:Confirm(b)local a=e.Windows[#e.Windows]if a then return a:Confirm(b)end end function e:Dialog(b)local a=e.Windows[#e.Windows]if a then return a:Dialog(b)end end local function D(a,c)local b,d=c.AbsolutePosition,c.AbsoluteSize return a.X>=b.X and a.X<=b.X+d.X and a.Y>=b.Y and a.Y<=b.Y+d.Y end local function aE(c,b,d)local a=c while a and a~=b and a:IsA"GuiObject"do if not a.Visible then return false end local c=a.Parent if c and c~=b and c:IsA"GuiObject"and(c.ClipsDescendants or c:IsA"ScrollingFrame")and not D(d,c)then return false end a=c end return true end function h:_refreshControls()local a={}for c,b in ipairs(self.Body:GetDescendants())do if b:IsA"GuiButton"or b:IsA"TextBox"or b:GetAttribute"NoDrag"then table.insert(a,b)end end self._controls=a self._controlsDirty=false end function h:_overControl(a)if self._dialog then return true end if self._controlsDirty then self:_refreshControls()end for c,b in ipairs(self._controls)do if b.Parent and D(a,b)and aE(b,self.Body,a)then return true end end return false end function h:_overOverlay(a)if self._grip and D(a,self._grip)then return true end if self.OpenButton and self.OpenButton.Visible and D(a,self.OpenButton)then return true end for c,b in ipairs(self.NotifyHolder:GetChildren())do if b:IsA"GuiObject"and D(a,b)then return true end end return false end function h:_enableDrag()local a=false local c=Vector2.zero local b local function d()local a=self.Root return a.AbsolutePosition+a.AbsoluteSize*a.AnchorPoint-self.Gui.AbsolutePosition end table.insert(self._connections,p.InputBegan:Connect(function(e)if not r(e)then return end if not self.Open or not self.Root.Visible then return end local b=s()if not D(b,self.Body)or self:_overControl(b)or self:_overOverlay(b)then return end a=true c=b-d()end))table.insert(self._connections,p.InputEnded:Connect(function(c)if not a then return end if r(c)then a,b=false,nil self:_clampToScreen()end end))table.insert(self._frameSteps,function(f)if not a then return end b=s()-c local g=d()local h=1-math.exp(-f*45)local e=g:Lerp(b,h)self.Root.Position=UDim2.fromOffset(e.X,e.Y)end)end local function al(a,d,e)if not a.Visible and not e then return end a.Visible=false task.delay(d,function()if not a.Parent then return end local d=c("UIScale",{Scale=.94,Parent=a})a.Visible=true b(d,{Scale=1},.4,Enum.EasingStyle.Back)task.delay(.4,function()d:Destroy()end)end)end function h:_revealCards(a,c)if a._revealed then return end a._revealed=true for _,item in ipairs(a.List:GetChildren())do if item:IsA"GuiObject"then item.Visible=true end end end function h:_playIntro(c)if self._introDone then return end self._introDone=true task.delay(1,function()self._autoSaveReady=true end)local a,d,e,f=self.Root,self.Body,self.Shadow,self.Scale if self.CurrentTab then self:_revealCards(self.CurrentTab,c and.15 or.25)end a.Visible=true if c then f.Scale=self._fitScale or 1 a.Position=UDim2.fromScale(.5,.5)b(d,{GroupTransparency=0},.3)b(self.BodyStroke,{Transparency=0},.3)b(e,{ImageTransparency=.6},.3)else a.Position=UDim2.new(.5,0,.5,24)b(f,{Scale=self._fitScale or 1},.5,Enum.EasingStyle.Back)b(a,{Position=UDim2.fromScale(.5,.5)},.5,Enum.EasingStyle.Quint)b(d,{GroupTransparency=0},.35)b(self.BodyStroke,{Transparency=0},.35)end if not c then b(e,{ImageTransparency=.6},.5)end for a,b in ipairs(self.Tabs)do b._button.Visible=true end self.Indicator.Visible=false task.delay(.05,function()if self.CurrentTab then self:_placeIndicator(self.CurrentTab)end end)end function h:_showLoader(e)local h="Frame"local m=e.LoadingDuration or 1.6 local w=self.Gui local d=c("CanvasGroup",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,16),Size=UDim2.fromOffset(300,132),BackgroundColor3=a.Background,BorderSizePixel=0,GroupTransparency=1,ZIndex=10,Parent=w})local x=g(d,UDim.new(0,12))local y=i(d,a.Stroke,1)T(d)z(d,UDim2.fromOffset(320,140),UDim2.new(1,-20,0,-20),.85,90)z(d,UDim2.fromOffset(240,100),UDim2.new(0,10,1,10),.9,270)local p=c("UIScale",{Scale=.92,Parent=d})local q=c("ImageLabel",{Position=UDim2.fromOffset(-25,-25),Size=UDim2.new(1,50,1,50),BackgroundTransparency=1,Image=v.Shadow,ImageColor3=Color3.new(0,0,0),ImageTransparency=1,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(49,49,450,450),ZIndex=0,Parent=d})local r=c(h,{Position=UDim2.fromOffset(24,26),Size=UDim2.fromOffset(40,40),BackgroundTransparency=1,Parent=d})local n=c("ImageLabel",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(.5,.5),Rotation=-14,BackgroundTransparency=1,ImageColor3=a.Accent,ImageTransparency=1,ScaleType=Enum.ScaleType.Fit,Parent=r})u(n,e.Icon or v.Logo)task.delay(.15,function()b(n,{Size=UDim2.fromScale(.85,.85),Rotation=0},.6,Enum.EasingStyle.Back)b(n,{ImageTransparency=0},.4)end)f{Position=UDim2.fromOffset(78,30),Size=UDim2.new(1,-100,0,22),Text=e.LoadingTitle or e.Title or"EXE HUB",TextSize=20,Parent=d}local A=f{Position=UDim2.fromOffset(78,52),Size=UDim2.new(1,-100,0,16),Text=e.LoadingText or e.Subtitle or"x",TextSize=13,FontFace=j.Regular,TextColor3=a.Muted,Parent=d}local k=c(h,{Position=UDim2.new(0,24,1,-30),Size=UDim2.new(1,-48,0,4),BackgroundColor3=a.Surface3,BorderSizePixel=0,ClipsDescendants=true,Parent=d})g(k,UDim.new(1,0))local l=c(h,{Size=UDim2.fromScale(0,1),BackgroundColor3=a.Accent,BorderSizePixel=0,Parent=k})g(l,UDim.new(1,0))local o=c(h,{Position=UDim2.fromScale(-.4,0),Size=UDim2.fromScale(.4,1),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.6,BorderSizePixel=0,ZIndex=2,Parent=k})c("UIGradient",{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.5,0),NumberSequenceKeypoint.new(1,1)},Parent=o})b(d,{GroupTransparency=0,Position=UDim2.fromScale(.5,.5)},.4,Enum.EasingStyle.Quint)b(p,{Scale=1},.5,Enum.EasingStyle.Back)b(q,{ImageTransparency=.6},.4)local s=aa:Create(o,TweenInfo.new(1.1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1),{Position=UDim2.fromScale(1,0)})s:Play()b(l,{Size=UDim2.fromScale(.85,1)},m*.8,Enum.EasingStyle.Quart)task.spawn(P)local t=e.LoadingSteps or{"Preparing interface","Loading icons","Almost there"}for a,b in ipairs(t)do task.delay(m*(a-1)/#t,function()if d.Parent then A.Text=b end end)end task.delay(m,function()b(l,{Size=UDim2.fromScale(1,1)},.25,Enum.EasingStyle.Quint)task.delay(.25,function()s:Cancel()for c,a in ipairs(d:GetChildren())do if a:IsA"TextLabel"then b(a,{TextTransparency=1},.15)end end for c,a in ipairs(r:GetChildren())do b(a,{ImageTransparency=1},.15)end b(k,{BackgroundTransparency=1},.15)b(l,{BackgroundTransparency=1},.15)b(o,{BackgroundTransparency=1},.1)b(d,{GroupTransparency=1},.22)b(q,{ImageTransparency=1},.2)b(p,{Scale=.96},.22,Enum.EasingStyle.Quint)task.delay(.22,function()d:Destroy()self:_playIntro()end)end)end)end function h:_fitToScreen(d)local a=self.Gui.AbsoluteSize if a.X==0 or a.Y==0 then return end local c=self.Root.Size local e=math.min(1,(a.X-24)/math.max(c.X.Offset,1),(a.Y-24)/math.max(c.Y.Offset,1))self._fitScale=math.max(e,.45)if self._introDone and self.Open then if d then self.Scale.Scale=self._fitScale else b(self.Scale,{Scale=self._fitScale},.2)end end end function h:_clampToScreen()if not self.KeepOnScreen then return end local a=self.Gui.AbsoluteSize local d=self.Root local c=d.AbsoluteSize/2 local e=d.AbsolutePosition+c-self.Gui.AbsolutePosition local f=Vector2.new(math.clamp(e.X,math.min(c.X,a.X/2),math.max(a.X-c.X,a.X/2)),math.clamp(e.Y,math.min(c.Y,a.Y/2),math.max(a.Y-c.Y,a.Y/2)))if(f-e).Magnitude>.5 then b(d,{Position=UDim2.fromOffset(f.X,f.Y)},.25,Enum.EasingStyle.Quint)end end function h:_createOpenButton(k)local d=self.Gui local b=c("TextButton",{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,14),Size=UDim2.fromOffset(0,40),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=a.Background,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=30,Parent=d})g(b,UDim.new(1,0))i(b,a.Stroke)o(b,12,16)local m=c("ImageLabel",{AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,0,.5,0),Size=UDim2.fromOffset(20,20),BackgroundTransparency=1,ImageColor3=a.Accent,ScaleType=Enum.ScaleType.Fit,ZIndex=31,Parent=b})u(m,k.Icon or v.Logo)f{Position=UDim2.fromOffset(28,0),Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,Text=k.Title or"EXE HUB",TextSize=13,TextTruncate=Enum.TextTruncate.None,ZIndex=31,Parent=b}self.OpenButton=b local e,h=false,false local l,j=Vector2.zero,Vector2.zero b.InputBegan:Connect(function(a)if r(a)then e,h=true,false j=s()l=j-b.AbsolutePosition end end)table.insert(self._connections,p.InputChanged:Connect(function(a)if not e then return end if U(a)then local a=s()if(a-j).Magnitude>4 then h=true end if not h then return end local c=a-l-d.AbsolutePosition b.AnchorPoint=Vector2.new(0,0)b.Position=UDim2.fromOffset(math.clamp(c.X,0,math.max(d.AbsoluteSize.X-b.AbsoluteSize.X,0)),math.clamp(c.Y,0,math.max(d.AbsoluteSize.Y-b.AbsoluteSize.Y,0)))end end))table.insert(self._connections,p.InputEnded:Connect(function(a)if e and r(a)then e=false if not h then self:Toggle()end end end))end function h:_enableResize(i)local j=self.MaxSize or Vector2.new(math.huge,math.huge)local f=c("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(1,4,1,4),Size=UDim2.fromOffset(32,32),BackgroundTransparency=1,Active=true,ZIndex=20,Parent=self.Root})self._grip=f local g,d=c("ImageLabel",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,-16,.5,-16),Size=UDim2.fromOffset(96,96),BackgroundTransparency=1,Image="rbxassetid://120997033468887",ImageColor3=a.Accent,ImageTransparency=.8,ZIndex=20,Parent=f}),false local h=self.Root.Size local k=Vector2.zero local e f.InputBegan:Connect(function(a)if r(a)then d=true h=self.Root.Size k=s()b(g,{ImageTransparency=.35},.1)end end)f.MouseEnter:Connect(function()if not d then b(g,{ImageTransparency=.35},.1)end end)f.MouseLeave:Connect(function()if not d then b(g,{ImageTransparency=.8},.17)end end)table.insert(self._connections,p.InputEnded:Connect(function(a)if d and r(a)then d=false b(g,{ImageTransparency=.8},.17)if e then self.Root.Size=UDim2.fromOffset(e.X,e.Y)e=nil end self:_fitToScreen()self:_clampToScreen()end end))table.insert(self._frameSteps,function(f)if not d then return end local b=(s()-k)/self.Scale.Scale e=Vector2.new(math.clamp(h.X.Offset+b.X*2,i.X,j.X),math.clamp(h.Y.Offset+b.Y*2,i.Y,j.Y))local c=Vector2.new(self.Root.Size.X.Offset,self.Root.Size.Y.Offset)local g=1-math.exp(-f*35)local a=c:Lerp(e,g)a=Vector2.new(math.floor(a.X+.5),math.floor(a.Y+.5))if a~=c then self.Root.Size=UDim2.fromOffset(a.X,a.Y)end end)end local function aF(a)a=tostring(a or""):gsub('[%c/\\:%*%?"<>|]',""):gsub("%.%.+","."):gsub("^[%s%.]+",""):gsub("[%s%.]+$","")if a==""then return nil end return a end local function Y(b,c)local a=aF(c)if not a then return nil,"invalid config name"end return b.ConfigFolder.."/"..a..".json",a end local function Z()local a="function"return type(writefile)==a and type(readfile)==a and type(isfile)==a end local function aG(a)if type(isfolder)=="function"and type(makefolder)=="function"and not isfolder(a)then makefolder(a)end end local function aH(c)local b=c._type local a=c:Get()if b=="Keybind"then return{Type=b,Value=a and a.Name or nil}elseif b=="ColorPicker"then return{Type=b,Value={a.R,a.G,a.B}}end return{Type=b,Value=a}end local function aI(b,e,c)local d=b._type local a=e.Value if d=="Keybind"then b:Set(F(a),c)elseif d=="ColorPicker"then if type(a)=="table"then b:Set(Color3.new(a[1],a[2],a[3]),c)end elseif a~=nil then b:Set(a,c)end end function h:SaveConfig(e)if not Z()then return false,"file API unavailable"end local a,b=Y(self,e or self.ConfigName)if not a then return false,b end local c={}for b,a in pairs(self.Flags)do if a._type and type(a.Get)=="function"then c[b]=aH(a)end end local d,f=pcall(function()aG(self.ConfigFolder)writefile(a,H:JSONEncode(c))end)if d then self.ConfigName=b end return d,f end function h:LoadConfig(a,e)if not Z()then return false,"file API unavailable"end local b,c=Y(self,a or self.ConfigName)if not b then return false,c end a=c if not isfile(b)then return false,"no config named "..a end local f,d=pcall(function()return H:JSONDecode(readfile(b))end)if not f or type(d)~="table"then return false,"config is not valid JSON"end local g=self._autoSaveEnabled self._autoSaveEnabled=false for c,b in pairs(d)do local a=self.Flags[c]if a and type(a.Set)=="function"and type(b)=="table"and b.Type==a._type then local d,f=pcall(aI,a,b,e==true)if not d then warn("[EXE HUB] could not load flag "..tostring(c)..": "..tostring(f))end end end self._autoSaveEnabled=g self._autoSaveReady=true self.ConfigName=a return true end function h:DeleteConfig(c)if not Z()or type(delfile)~="function"then return false,"file API unavailable"end local a,b=Y(self,c)if not a then return false,b end if not isfile(a)then return false,"no config named "..b end local d,e=pcall(delfile,a)return d,e end function h:ListConfigs()local a={}if type(listfiles)~="function"or type(isfolder)~="function"or not isfolder(self.ConfigFolder)then return a end for d,c in ipairs(listfiles(self.ConfigFolder))do local b=c:match"([^/\\]+)%.json$"if b then table.insert(a,b)end end table.sort(a)return a end function h:SetAutoSave(a)self._autoSaveEnabled=a==true end function h:_autoSave()if not self._autoSaveEnabled or self._destroyed or not self._autoSaveReady then return end if self._autoSavePending then return end self._autoSavePending=true task.delay(.5,function()self._autoSavePending=false if not self._destroyed then self:SaveConfig(self.ConfigName)end end)end local function aJ(e,g,h)local b=c("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,-10),Size=UDim2.fromOffset(200,70),BackgroundTransparency=1,Parent=e})local d=c("ImageLabel",{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,0),Size=UDim2.fromOffset(26,26),BackgroundTransparency=1,ImageColor3=a.Muted,ImageTransparency=.15,ScaleType=Enum.ScaleType.Fit,Parent=b})u(d,g)local i=f{Position=UDim2.fromOffset(0,36),Size=UDim2.new(1,0,0,16),Text=h,TextSize=13,FontFace=j.Regular,TextColor3=a.Muted,TextXAlignment=Enum.TextXAlignment.Center,Parent=b}return b,i,d end local function aK(e,h,d,j)local b=c("Frame",{Size=UDim2.new(.5,-4,0,62),BackgroundColor3=a.Surface2,BorderSizePixel=0,LayoutOrder=h,Parent=e})g(b)i(b)b:SetAttribute("NoDrag",true)if d then A(b,d,a.Muted,UDim2.new(0,14,0,21))end f{Position=UDim2.fromOffset(d and 36 or 14,12),Size=UDim2.new(1,-(d and 50 or 28),0,16),Text=j,TextSize=12,TextColor3=a.Muted,Parent=b}return f{Position=UDim2.fromOffset(14,34),Size=UDim2.new(1,-28,0,18),Text="…",TextSize=15,Parent=b}end local am=setmetatable({},{__mode="k"})local function an(c)local d={}local function a(a,c)local b=am[a]if b==nil then b=a[c]am[a]=b end table.insert(d,{a,c,b})end local function e(b)for c,b in ipairs(b:GetChildren())do if b:IsA"TextLabel"or b:IsA"TextButton"or b:IsA"TextBox"then a(b,"TextTransparency")elseif b:IsA"ImageLabel"or b:IsA"ImageButton"then a(b,"ImageTransparency")elseif b:IsA"UIStroke"then a(b,"Transparency")elseif b:IsA"Frame"then a(b,"BackgroundTransparency")end e(b)end end if c:IsA"Frame"then a(c,"BackgroundTransparency")end e(c)for c,a in ipairs(d)do a[1][a[2]]=1 b(a[1],{[a[2]]=a[3]},.28)end end local function aL(a,c)c=c or 0 a.GroupTransparency=1 a.Position=UDim2.fromOffset(0,c+14)a.Visible=true b(a,{GroupTransparency=0,Position=UDim2.fromOffset(0,c)},.32,Enum.EasingStyle.Quint)end function h:_buildHome(d)local e,n,p,w="Frame","UIListLayout","NoDrag","Executor"local m=self:Tab{Name=d.Name or"Home",Desc=d.Desc,Icon=d.Icon or"house"}local q=m.List local x=d.Pages or d.Tabs local r={}local s if type(x)=="table"and#x>0 then s=c(e,{Size=UDim2.new(1,0,0,32),BackgroundTransparency=1,LayoutOrder=1,Parent=q})c(n,{FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6),Parent=s})end local y=d.Greeting if y==nil then local a=tonumber(os.date"%H")or 12 local b=a<12 and"morning"or(a<18 and"afternoon"or"evening")y="Good "..b.."."end local h=c(e,{Size=UDim2.new(1,0,0,58),BackgroundColor3=a.Surface2,BorderSizePixel=0,LayoutOrder=2,Parent=q})h:SetAttribute(p,true)g(h)i(h)local z=c("ImageLabel",{Position=UDim2.fromOffset(12,11),Size=UDim2.fromOffset(36,36),BackgroundColor3=a.Surface,BorderSizePixel=0,Parent=h})g(z,UDim.new(0,8))i(z)task.spawn(function()local b,a=pcall(function()return I:GetUserThumbnailAsync(J.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100)end)if b and a then z.Image=a end end)f{Position=UDim2.fromOffset(58,11),Size=UDim2.new(1,-72,0,18),Text=(d.Welcome or"Hello, ")..J.DisplayName,TextSize=15,Parent=h}f{Position=UDim2.fromOffset(58,30),Size=UDim2.new(1,-72,0,16),Text=y,TextSize=13,FontFace=j.Regular,TextColor3=a.Muted,Parent=h}local t=c(e,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=3,Parent=q})c(n,{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,8),Parent=t})if d.Sections~=false then local b=c(e,{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,LayoutOrder=1,Parent=t})local g=f{Position=UDim2.fromOffset(2,6),Size=UDim2.new(0,0,0,16),AutomaticSize=Enum.AutomaticSize.X,Text=string.upper(d.SectionName or"System info"),TextSize=12,TextColor3=a.Muted,TextTruncate=Enum.TextTruncate.None,Parent=b}local i=c(e,{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,0,14),Size=UDim2.new(1,-12,0,1),BackgroundColor3=a.Stroke,BorderSizePixel=0,Parent=b})local function h()i.Size=UDim2.new(1,-(g.AbsoluteSize.X/self.Scale.Scale+14),0,1)end g:GetPropertyChangedSignal"AbsoluteSize":Connect(h)task.defer(h)end local C=c(e,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=2,Parent=t})c("UIGridLayout",{CellSize=UDim2.new(.5,-4,0,62),CellPadding=UDim2.fromOffset(8,8),SortOrder=Enum.SortOrder.LayoutOrder,Parent=C})local N=d.Stats or{"FPS","Ping",w,"Game","Region","Time"}local D={}for b,a in ipairs(N)do D[a]=true end local E=0 local function k(a,b,c)if not D[a]then return nil end E+=1 return aK(C,E,b,c)end local F=k("FPS","activity","FPS")local G=k("Ping","wifi","Ping")local H=k(w,"terminal",w)local A=k("Game","gamepad-2","Game")local B=k("Region","globe","Server region")local K=k("Time","clock","Time of day")local L=k("Players","users","Players")local M=k("Uptime","timer","Session")if H then H.Text=ax()end if A then A.Text="Loading"task.spawn(function()A.Text=ay()end)end if B then B.Text="Loading"aA(function(a)B.Text=a end)end local v=0 local O=os.clock()self:_listen("Render",function()v+=1 end)task.spawn(function()while not self._destroyed and m.List.Parent and m._page.Parent do if not self.Open or self.CurrentTab~=m then v=0 task.wait(1)continue end if F then F.Text=tostring(v)end v=0 if G then local a,b=pcall(function()return math.floor(J:GetNetworkPing()*1e3)end)G.Text=(a and b or 0).." ms"end if K then K.Text=os.date(d.TimeFormat or"%H:%M")end if L then L.Text=#I:GetPlayers().." / "..I.MaxPlayers end if M then local a=math.floor(os.clock()-O)M.Text=string.format("%d:%02d",math.floor(a/60),a%60)end task.wait(1)end end)table.insert(r,{Title=d.SectionName or"Details",Icon=d.TabIcon or"layout-grid",Frame=t})if s then for h,b in ipairs(x)do local d=c(e,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Visible=false,LayoutOrder=3,Parent=q})c(n,{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,8),Parent=d})if type(b.Content)=="string"then local h=c(e,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=a.Surface2,BorderSizePixel=0,LayoutOrder=1,Parent=d})h:SetAttribute(p,true)g(h)i(h)o(h,14,14,12,14)f{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Text=b.Content,TextSize=13,FontFace=j.Regular,TextColor3=a.Muted,TextWrapped=true,TextTruncate=Enum.TextTruncate.None,TextYAlignment=Enum.TextYAlignment.Top,Parent=h}end if type(b.Entries)=="table"then for m,b in ipairs(b.Entries)do local h=c(e,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=a.Surface2,BorderSizePixel=0,LayoutOrder=m,Parent=d})h:SetAttribute(p,true)g(h)i(h)o(h,14,14,12,14)c(n,{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4),Parent=h})local l=c(e,{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,LayoutOrder=1,Parent=h})f{Size=UDim2.new(1,-70,1,0),Text=b.Title or b.Version or"Update",TextSize=14,Parent=l}if b.Date or b.Tag then local d=c(e,{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,.5,0),Size=UDim2.fromOffset(0,20),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=a.Surface,BorderSizePixel=0,Parent=l})g(d,UDim.new(0,5))i(d)o(d,8,8)f{Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,Text=b.Tag or b.Date,TextSize=11,TextColor3=a.Muted,TextTruncate=Enum.TextTruncate.None,Parent=d}end local k=b.Content or b.Body if type(b.Changes)=="table"then k="• "..table.concat(b.Changes,"\n• ")end if k then f{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Text=k,TextSize=13,FontFace=j.Regular,TextColor3=a.Muted,TextWrapped=true,TextTruncate=Enum.TextTruncate.None,TextYAlignment=Enum.TextYAlignment.Top,LayoutOrder=2,Parent=h}end end end if type(b.Build)=="function"then l(b.Build,d)for b,a in ipairs(d:GetChildren())do if a:IsA"GuiObject"then a:SetAttribute(p,true)end end end table.insert(r,{Title=b.Name or b.Title or"Page",Icon=b.Icon,Frame=d})end local d={}local function k(c,e)local f=self._homeIndex~=c self._homeIndex=c h.Visible=c==1 if c==1 and f and not e then an(h)end for i,k in ipairs(r)do local g=i==c local j=k.Frame j.Visible=g if g and f and not e then for b,a in ipairs(j:GetChildren())do if a:IsA"GuiObject"then an(a)end end end local h=d[i]if h then b(h.Frame,{BackgroundTransparency=g and 0 or 1},.15)b(h.Stroke,{Transparency=g and 0 or 1},.15)b(h.Label,{TextColor3=g and a.Text or a.Muted},.15)if h.Icon then b(h.Icon,{ImageColor3=g and a.Accent or a.Muted},.15)end end end end for h,l in ipairs(r)do local e=c("TextButton",{Size=UDim2.fromOffset(0,32),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=a.Surface2,BackgroundTransparency=1,Text="",AutoButtonColor=false,LayoutOrder=h,Parent=s})g(e,UDim.new(0,7))local m=i(e,a.Stroke,1)o(e,12,12)local j if l.Icon then j=c("ImageLabel",{AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,0,.5,0),Size=UDim2.fromOffset(14,14),BackgroundTransparency=1,ImageColor3=a.Muted,ScaleType=Enum.ScaleType.Fit,Parent=e})u(j,l.Icon)end local n=f{Position=UDim2.fromOffset(j and 20 or 0,0),Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,Text=l.Title,TextSize=13,TextColor3=a.Muted,TextTruncate=Enum.TextTruncate.None,Parent=e}d[h]={Frame=e,Stroke=m,Label=n,Icon=j}e.MouseEnter:Connect(function()if self._homeIndex~=h then b(e,{BackgroundTransparency=.4},.12)b(m,{Transparency=.5},.12)end end)e.MouseLeave:Connect(function()if self._homeIndex~=h then b(e,{BackgroundTransparency=1},.2)b(m,{Transparency=1},.2)end end)e.MouseButton1Click:Connect(function()k(h)end)end k(1)end m._order=10 self.Home=m return m end function h:Tab(e,v)e=n(e,{Title="Name",Description="Desc"})if v~=nil and e.Icon==nil then e.Icon=v end local d=setmetatable({Name=e.Name or"Tab",Window=self,_order=0},k)local h=c("TextButton",{Size=UDim2.new(1,0,0,38),BackgroundColor3=a.Surface2,BackgroundTransparency=1,Text="",AutoButtonColor=false,LayoutOrder=#self.Tabs+1,Parent=self.TabList})g(h)local r=i(h,a.Stroke,1)d._button=h local s=e.Icon~=nil if s then local b=c("ImageLabel",{AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,12,.5,0),Size=UDim2.fromOffset(16,16),BackgroundTransparency=1,ImageColor3=a.Muted,ScaleType=Enum.ScaleType.Fit,Parent=h})u(b,e.Icon)d._icon=b end d._label=f{Position=UDim2.fromOffset(s and 36 or 14,0),Size=UDim2.new(1,-(s and 44 or 22),1,0),Text=d.Name,TextColor3=a.Muted,Parent=h}local p=c("Frame",{Name=d.Name,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,Parent=self.Content})d._page=p f{Position=UDim2.fromOffset(24,20),Size=UDim2.new(1,-72,0,24),Text=d.Name,TextSize=22,Parent=p}if e.Desc then f{Position=UDim2.fromOffset(24,44),Size=UDim2.new(1,-72,0,16),Text=e.Desc,TextSize=13,FontFace=j.Regular,TextColor3=a.Muted,Parent=p}end local w=e.Desc and 70 or 58 local l=c("ScrollingFrame",{Position=UDim2.fromOffset(0,w),Size=UDim2.new(1,0,1,-w),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=a.Accent,ScrollBarImageTransparency=.5,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Parent=p})o(l,24,24,2,24)if m then l:SetAttribute("NoDrag",true)end c("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,8),Parent=l})d.List=l local t,q=aJ(p,e.Icon or"layout-grid",e.EmptyText or"Nothing here yet"),0 l.ChildAdded:Connect(function(a)if a:IsA"GuiObject"then q+=1 t.Visible=false end end)l.ChildRemoved:Connect(function(a)if a:IsA"GuiObject"then q=math.max(q-1,0)t.Visible=q<=0 end end)t.Visible=true h.MouseEnter:Connect(function()if self.CurrentTab~=d then b(h,{BackgroundTransparency=.4},.12)b(r,{Transparency=.5},.12)end end)h.MouseLeave:Connect(function()if self.CurrentTab~=d then b(h,{BackgroundTransparency=1},.2)b(r,{Transparency=1},.2)end end)h.MouseButton1Click:Connect(function()self:SelectTab(d)end)d._stroke=r if not self._introDone then h.Visible=false end table.insert(self.Tabs,d)if#self.Tabs==1 then task.defer(function()if not self.CurrentTab then self:SelectTab(d)end end)end return d end h.CreateTab=h.Tab function h:Dialog(h)local s,t="TextButton","TextTransparency"h=n(h,{Text="Content",Message="Content"})if self._dialog then self._dialog.Close()end local d=18 local q=c(s,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=40,Parent=self.Body})local e=c(s,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,10),Size=UDim2.fromOffset(300,120),BackgroundColor3=a.Background,BackgroundTransparency=1,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=41,Parent=q})g(e,UDim.new(0,10))local v=i(e,a.Stroke,1)local w=c("UIScale",{Scale=.94,Parent=e})local m,u={},0 if h.Icon then local c,b=A(e,h.Icon,a.Accent,UDim2.new(0,d,0,d+9))b.ImageTransparency=1 c.ZIndex=42 b.ZIndex=42 table.insert(m,{b,"ImageTransparency",0})u=24 end local y=f{Position=UDim2.fromOffset(d+u,d),Size=UDim2.new(1,-(d*2+u),0,18),Text=h.Title or"Are you sure?",TextSize=15,TextTransparency=1,ZIndex=42,Parent=e}table.insert(m,{y,t,0})local p=0 if h.Content then local b=f{Position=UDim2.fromOffset(d,d+24),Size=UDim2.new(1,-d*2,0,0),AutomaticSize=Enum.AutomaticSize.Y,Text=h.Content,TextSize=13,FontFace=j.Regular,TextColor3=a.Muted,TextWrapped=true,TextTransparency=1,TextTruncate=Enum.TextTruncate.None,TextYAlignment=Enum.TextYAlignment.Top,ZIndex=42,Parent=e}table.insert(m,{b,t,0})p=math.max(b.TextBounds.Y,16)+6 b:GetPropertyChangedSignal"TextBounds":Connect(function()local a=math.max(b.TextBounds.Y,16)+6 if a~=p then p=a e.Size=UDim2.fromOffset(300,d+24+p+12+34+d)local b=e:FindFirstChild"ButtonRow"if b then b.Position=UDim2.fromOffset(d,d+24+p+12)end end end)end local x=c("Frame",{Name="ButtonRow",Position=UDim2.fromOffset(d,d+24+p+12),Size=UDim2.new(1,-d*2,0,34),BackgroundTransparency=1,ZIndex=42,Parent=e})c("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Right,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,8),Parent=x})e.Size=UDim2.fromOffset(300,d+24+p+12+34+d)local k,r={},false function k.Close()if r then return end r=true if self._dialog==k then self._dialog=nil end b(q,{BackgroundTransparency=1},.18)b(e,{BackgroundTransparency=1,Position=UDim2.new(.5,0,.5,8)},.18,Enum.EasingStyle.Quint)b(w,{Scale=.96},.18,Enum.EasingStyle.Quint)b(v,{Transparency=1},.12)for c,a in ipairs(m)do b(a[1],{[a[2]]=1},.12)end task.delay(.2,function()q:Destroy()end)end for q,j in ipairs(h.Buttons or{})do local e=j.Variant=="Primary"local d=c(s,{Size=UDim2.fromOffset(0,34),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=e and a.Accent or a.Surface2,BackgroundTransparency=1,BorderSizePixel=0,Text="",AutoButtonColor=false,ClipsDescendants=true,LayoutOrder=q,ZIndex=43,Parent=x})g(d,UDim.new(0,7))local h=i(d,e and a.Accent or a.Stroke,1)o(d,14,14)local u=f{Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,Text=j.Title or j.Name or"OK",TextSize=13,TextColor3=e and a.AccentDark or a.Text,TextXAlignment=Enum.TextXAlignment.Center,TextTransparency=1,ZIndex=44,Parent=d}local n=e and.12 or 0 local p=e and.4 or 0 table.insert(m,{d,"BackgroundTransparency",n})table.insert(m,{h,"Transparency",p})table.insert(m,{u,t,0})d.MouseEnter:Connect(function()if r then return end if e then b(d,{BackgroundTransparency=0},.12)b(h,{Transparency=0},.12)else b(h,{Color=a.StrokeHover},.12)end end)d.MouseLeave:Connect(function()if r then return end if e then b(d,{BackgroundTransparency=n},.2)b(h,{Transparency=p},.2)else b(h,{Color=a.Stroke},.2)end end)d.MouseButton1Click:Connect(function()k.Close()l(j.Callback)end)end function k.Cancel()if r then return end k.Close()l(h.OnCancel)end k.Dismissable=h.CloseOnBackdrop~=false if k.Dismissable then q.MouseButton1Click:Connect(k.Cancel)end self._dialog=k b(q,{BackgroundTransparency=.45},.25)b(e,{BackgroundTransparency=0,Position=UDim2.fromScale(.5,.5)},.3,Enum.EasingStyle.Quint)b(v,{Transparency=0},.25)b(w,{Scale=1},.4,Enum.EasingStyle.Back)for c,a in ipairs(m)do b(a[1],{[a[2]]=a[3]},.25)end return k end function h:Confirm(a)a=n(a,{Text="Content",Message="Content"})return self:Dialog{Title=a.Title or"Are you sure?",Content=a.Content,Icon=a.Icon,OnCancel=a.OnCancel,Buttons={{Title=a.CancelText or"Cancel",Callback=a.OnCancel},{Title=a.ConfirmText or"Confirm",Variant="Primary",Callback=a.Callback}}}end function h:_listen(e,c,a)local b=self._inputListeners[e]table.insert(b,c)local function d()for a,d in ipairs(b)do if d==c then table.remove(b,a)break end end end if a then a._listeners=a._listeners or{}table.insert(a._listeners,d)end return d end function h:_indicatorY(a)local b=self.TabList local c=self.Scale.Scale return(a._button.AbsolutePosition.Y-b.AbsolutePosition.Y+a._button.AbsoluteSize.Y/2)/c+b.Position.Y.Offset end function h:_placeIndicator(d)local a=self.Indicator local c=self:_indicatorY(d)if not a.Visible then a.Visible=true a.Position=UDim2.fromOffset(6,c)a.Size=UDim2.fromOffset(3,0)end b(a,{Position=UDim2.fromOffset(6,c),Size=UDim2.fromOffset(3,18)},.35,Enum.EasingStyle.Back)end function h:SelectTab(c)if type(c)=="string"then for b,a in ipairs(self.Tabs)do if a.Name==c then c=a break end end end if type(c)~="table"or self.CurrentTab==c then return end local d=self.CurrentTab self.CurrentTab=c self:_settleTransition()local f=(self._transitionGeneration or 0)+1 self._transitionGeneration=f if d then b(d._button,{BackgroundTransparency=1},.2)b(d._stroke,{Transparency=1},.2)b(d._label,{TextColor3=a.Muted},.2)if d._icon then b(d._icon,{ImageColor3=a.Muted},.2)end local c=self._outLayer d._page.Parent=c self._outPage=d._page c.GroupTransparency=0 c.Position=UDim2.fromOffset(0,0)c.Visible=true b(c,{GroupTransparency=1,Position=UDim2.fromOffset(0,-10)},.18)task.delay(.18,function()if self._transitionGeneration==f then self:_settleOut()end end)end b(c._button,{BackgroundTransparency=0},.2)b(c._stroke,{Transparency=0},.2)b(c._label,{TextColor3=a.Text},.2)if c._icon then b(c._icon,{ImageColor3=a.Accent},.2)end self:_placeIndicator(c)local e=c._page e.Position=UDim2.fromOffset(0,0)e.Visible=true e.Parent=self._inLayer self._inPage=e aL(self._inLayer)task.delay(.32,function()if self._transitionGeneration==f then self:_settleIn()end end)end function h:_settleOut()local a=self._outPage if a then a.Parent=self.Content a.Visible=false self._outPage=nil end self._outLayer.Visible=false end function h:_settleIn()local a=self._inPage if a then a.Parent=self.Content a.Position=UDim2.fromOffset(0,0)self._inPage=nil end self._inLayer.Visible=false end function h:_settleTransition()self:_settleOut()self:_settleIn()end function h:Toggle(a)if not self._introDone then return end if a==nil then a=not self.Open end if a==self.Open then return end self.Open=a if a then self.Root.Visible=true b(self.Scale,{Scale=self._fitScale or 1},.4,Enum.EasingStyle.Back)b(self.Body,{GroupTransparency=0},.25)b(self.BodyStroke,{Transparency=0},.25)b(self.Shadow,{ImageTransparency=.6},.3)else b(self.Scale,{Scale=(self._fitScale or 1)*.94},.2,Enum.EasingStyle.Quint)b(self.Body,{GroupTransparency=1},.16)b(self.BodyStroke,{Transparency=1},.12)b(self.Shadow,{ImageTransparency=1},.16)task.delay(.2,function()if not self.Open then self.Root.Visible=false end end)end end function h:SetKeepOnScreen(a)self.KeepOnScreen=a~=false if self.KeepOnScreen then self:_clampToScreen()end end function h:SetKeybind(a)a=F(a)if not a then return end self.Keybind=a self._keyChipLabel.Text=W(a)end function h:SetTitle(a)self._titleLabel.Text=tostring(a)end function h:SetSubtitle(a)self._subtitleLabel.Text=tostring(a)end function h:SetIcon(a)u(self._logo,a)end function h:Notify(d)local h="Frame"d=n(d,{Text="Content",Message="Content",Image="Icon"})local u=d.Duration or 4 local t=aB[d.Type]local r=t and a[t]or a.Accent local C=t and d.Type~="Info"and r or a.Text self._notifyOrder+=1 local k=c(h,{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,LayoutOrder=self._notifyOrder,Parent=self.NotifyHolder})local s=c(h,{Position=UDim2.fromOffset(320,0),Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=k})local w=c("ImageLabel",{Position=UDim2.fromOffset(-20,-20),Size=UDim2.new(1,40,1,40),BackgroundTransparency=1,Image=v.Shadow,ImageColor3=Color3.new(0,0,0),ImageTransparency=1,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(49,49,450,450),ZIndex=0,Parent=s})local e=c("CanvasGroup",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=a.Background,BorderSizePixel=0,GroupTransparency=1,Parent=s})g(e,UDim.new(0,10))local D=i(e,a.Stroke)T(e)z(e,UDim2.fromOffset(260,120),UDim2.new(1,-10,0,-10),.86,90)local l=c(h,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=e})o(l,16,16,14,24)local m=0 local E=c(h,{Position=UDim2.fromOffset(0,14),Size=UDim2.new(0,2,1,-28),BackgroundColor3=r,BorderSizePixel=0,Parent=e})g(E,UDim.new(1,0))if d.Icon then A(l,d.Icon,r,UDim2.new(0,0,0,8))m=24 end f{Position=UDim2.fromOffset(m,0),Size=UDim2.new(1,-28-m,0,16),Text=d.Title or"Notification",TextSize=14,TextColor3=C,Parent=l}local p=c("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,6,0,-5),Size=UDim2.fromOffset(24,24),BackgroundTransparency=1,Text="×",TextColor3=a.Muted,TextSize=22,FontFace=j.Bold,AutoButtonColor=false,Parent=l})p.MouseEnter:Connect(function()b(p,{TextColor3=a.Text},.15)end)p.MouseLeave:Connect(function()b(p,{TextColor3=a.Muted},.2)end)if d.Content then f{Position=UDim2.fromOffset(m,21),Size=UDim2.new(1,-m,0,0),AutomaticSize=Enum.AutomaticSize.Y,Text=d.Content,TextSize=13,FontFace=j.Regular,TextColor3=a.Muted,TextWrapped=true,TextTruncate=Enum.TextTruncate.None,TextYAlignment=Enum.TextYAlignment.Top,Parent=l}end local x=c(h,{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,16,1,-8),Size=UDim2.new(1,-32,0,3),BackgroundColor3=a.Surface3,BorderSizePixel=0,Parent=e})g(x,UDim.new(1,0))local y=c(h,{Size=UDim2.fromScale(1,1),BackgroundColor3=r,BorderSizePixel=0,Parent=x})g(y,UDim.new(1,0))task.defer(function()if k.Parent then b(k,{Size=UDim2.new(1,0,0,e.AbsoluteSize.Y)},.3,Enum.EasingStyle.Quint)end end)b(s,{Position=UDim2.fromOffset(0,0)},.5,Enum.EasingStyle.Back)b(e,{GroupTransparency=0},.3)b(w,{ImageTransparency=.6},.4)b(y,{Size=UDim2.fromScale(0,1)},u,Enum.EasingStyle.Linear)local B=false local function q()if B then return end B=true for a,b in ipairs(self._toasts)do if b==q then table.remove(self._toasts,a)break end end b(s,{Position=UDim2.fromOffset(320,0)},.3,Enum.EasingStyle.Quint)b(e,{GroupTransparency=1},.2)b(D,{Transparency=1},.15)b(w,{ImageTransparency=1},.2)task.delay(.22,function()k.ClipsDescendants=true b(k,{Size=UDim2.new(1,0,0,-4)},.22,Enum.EasingStyle.Quint)task.delay(.24,function()k:Destroy()end)end)end task.delay(u,q)p.MouseButton1Click:Connect(q)table.insert(self._toasts,q)while#self._toasts>self.MaxNotifications do local a=table.remove(self._toasts,1)a()end return{Dismiss=q}end function h:Destroy()if self._destroyed then return end self._destroyed=true for a,b in ipairs(e.Windows)do if b==self then table.remove(e.Windows,a)break end end for b,a in ipairs(self._connections)do a:Disconnect()end self._connections={}for a,b in pairs(self.Flags)do if e.Flags[a]==b then e.Flags[a]=nil end end self.Flags={}b(self.Scale,{Scale=.9},.2)b(self.Body,{GroupTransparency=1},.2)b(self.BodyStroke,{Transparency=1},.12)b(self.Shadow,{ImageTransparency=1},.2)task.delay(.22,function()self.Gui:Destroy()end)end

-- ======================================================================
-- EXE HUB (x) - PROFILE & VISUAL ENGINE (SMOOTH 60FPS)
-- ======================================================================
if typeof(getgenv) == "function" then
    getgenv().ExeHub = e
end

local activeCleanupTasks = {}
if typeof(getgenv) == "function" then
    getgenv()._EXEHUB_CLEANUP = function()
        for _, taskFn in ipairs(activeCleanupTasks) do
            pcall(taskFn)
        end
        table.clear(activeCleanupTasks)
        if typeof(getgenv) == "function" and getgenv().ExeHubWindow then
            pcall(function()
                if not getgenv().ExeHubWindow._destroyed then
                    getgenv().ExeHubWindow:Destroy()
                end
            end)
            getgenv().ExeHubWindow = nil
        end
    end
    getgenv()._EXEHUB_ADD_CLEANUP = function(fn)
        if type(fn) == "function" then
            table.insert(activeCleanupTasks, fn)
        end
    end
end

local function checkIsViolenceDistrict()
    local placeId = game.PlaceId
    local gameId = game.GameId
    local gameName = ""

    -- 1. Known PlaceIds / UniverseIds for Violence District
    local knownIds = {
        [17387349195] = true, -- Violence District Main
        [17478637731] = true, -- Violence District Testing / Lobby
        [17495398299] = true, -- Violence District Alt
        [5957078833] = true,  -- Violence District UniverseId
    }
    if knownIds[placeId] or (gameId and knownIds[gameId]) then
        return true, "Violence District"
    end

    -- 2. Query MarketplaceService with pcall
    pcall(function()
        local info = game:GetService("MarketplaceService"):GetProductInfo(placeId)
        if info and type(info.Name) == "string" and #info.Name > 0 then
            gameName = info.Name
        end
    end)

    -- 3. Fallback to game.Name
    if gameName == "" then
        pcall(function()
            if game.Name and #game.Name > 0 and game.Name ~= "Game" then
                gameName = game.Name
            end
        end)
    end

    -- 4. Case-insensitive name match for Violence District
    if gameName ~= "" then
        local lower = string.lower(gameName)
        if string.find(lower, "violence district", 1, true) or (string.find(lower, "violence", 1, true) and string.find(lower, "district", 1, true)) then
            return true, gameName
        end
    end

    -- 5. Hierarchy and asset markers unique to Violence District
    local hasSignature = false
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        local ws = game:GetService("Workspace")
        if rs:FindFirstChild("ViolenceDistrict") or rs:FindFirstChild("Violence") then
            hasSignature = true
        elseif ws:FindFirstChild("Generators") and (rs:FindFirstChild("GameEvents") or rs:FindFirstChild("Weapons")) then
            hasSignature = true
        end
    end)
    if hasSignature then
        return true, gameName ~= "" and gameName or "Violence District"
    end

    return false, gameName ~= "" and gameName or ("Place " .. tostring(placeId))
end

local function showUnsupportedGameMessage(detectedGame)
    local alertTitle = "EXE HUB — Game Not Supported"
    local alertMsg = "This script only supports Violence District.\nDetected Game: " .. tostring(detectedGame)

    -- Log to console
    pcall(function()
        warn("[EXE HUB] " .. alertTitle)
        warn("[EXE HUB] " .. alertMsg)
    end)

    -- Native Roblox client notification
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "EXE HUB — Unsupported Game",
            Text = "Only works in Violence District!\nDetected: " .. tostring(detectedGame),
            Duration = 6
        })
    end)

    -- Sleek on-screen alert banner matching EXE HUB aesthetic
    pcall(function()
        local targetParent = as and as()
        if not targetParent then
            if typeof(gethui) == "function" then
                pcall(function() targetParent = gethui() end)
            end
            if not targetParent then
                pcall(function() targetParent = game:GetService("CoreGui") end)
            end
            if not targetParent then
                local lp = game:GetService("Players").LocalPlayer
                targetParent = lp and lp:FindFirstChild("PlayerGui")
            end
        end

        if not targetParent then return end

        local tweenService = game:GetService("TweenService")
        local alertGui = Instance.new("ScreenGui")
        alertGui.Name = "ExeHub_UnsupportedAlert"
        alertGui.ResetOnSpawn = false
        alertGui.DisplayOrder = 99999
        alertGui.IgnoreGuiInset = true

        local banner = Instance.new("Frame")
        banner.Name = "Banner"
        banner.AnchorPoint = Vector2.new(0.5, 0)
        banner.Position = UDim2.new(0.5, 0, 0, -90)
        banner.Size = UDim2.fromOffset(430, 68)
        banner.BackgroundColor3 = Color3.fromRGB(24, 19, 24)
        banner.BorderSizePixel = 0
        banner.Parent = alertGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = banner

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(240, 90, 90)
        stroke.Thickness = 1.2
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = banner

        local icon = Instance.new("ImageLabel")
        icon.AnchorPoint = Vector2.new(0, 0.5)
        icon.Position = UDim2.new(0, 14, 0.5, 0)
        icon.Size = UDim2.fromOffset(26, 26)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://10709791437"
        icon.ImageColor3 = Color3.fromRGB(240, 100, 100)
        icon.ScaleType = Enum.ScaleType.Fit
        icon.Parent = banner

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Position = UDim2.fromOffset(48, 12)
        titleLabel.Size = UDim2.new(1, -58, 0, 18)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = "EXE HUB — Game Not Supported"
        titleLabel.TextColor3 = Color3.fromRGB(245, 110, 110)
        titleLabel.TextSize = 14
        titleLabel.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold)
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = banner

        local descLabel = Instance.new("TextLabel")
        descLabel.Position = UDim2.fromOffset(48, 32)
        descLabel.Size = UDim2.new(1, -58, 0, 24)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = "This script is made only for Violence District.\nDetected: " .. tostring(detectedGame)
        descLabel.TextColor3 = Color3.fromRGB(200, 195, 202)
        descLabel.TextSize = 12
        descLabel.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Regular)
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextWrapped = true
        descLabel.Parent = banner

        alertGui.Parent = targetParent

        local enterTween = tweenService:Create(banner, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0, 36)
        })
        enterTween:Play()

        task.delay(5, function()
            if banner and banner.Parent then
                local exitTween = tweenService:Create(banner, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                    Position = UDim2.new(0.5, 0, 0, -100)
                })
                exitTween:Play()
                exitTween.Completed:Connect(function()
                    pcall(function() alertGui:Destroy() end)
                end)
            end
        end)
    end)
end

local function _InitExeHubUI()
    local isSupported, detectedGame = checkIsViolenceDistrict()
    if not isSupported then
        showUnsupportedGameMessage(detectedGame)
        return nil
    end

    local lp = J or I.LocalPlayer
    local theme = e.Theme
    local workspace = game:GetService("Workspace")
    local camera = workspace.CurrentCamera

    local Window = e:CreateWindow({
        Title = "EXE HUB",
        Subtitle = "x",
        Icon = "rbxassetid://103859712365480",
        Size = UDim2.fromOffset(640, 490),
        Loading = {
            Enabled = false,
            Duration = 0
        },
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "EXEHUB",
            FileName = "config",
            AutoSave = true
        }
    })

    if Window and Window.Gui then
        Window.Gui:SetAttribute("ExeHubGui", true)
    end

    e.ActiveWindow = Window
    if typeof(getgenv) == "function" then
        getgenv().ExeHubWindow = Window
    end

    local espConnections = {}

    local function copyToClipboard(str)
        local fn = setclipboard or toclipboard or (Clipboard and Clipboard.set)
        if typeof(fn) == "function" then
            pcall(fn, tostring(str))
            e:Notify({
                Title = "Copied",
                Content = "Copied to clipboard: " .. tostring(str),
                Duration = 2
            })
        else
            e:Notify({
                Title = "Notice",
                Content = tostring(str),
                Duration = 2
            })
        end
    end

    -- ==================================================================
    -- Tab 1: Profile (Icon: user/profile)
    -- ==================================================================
    local ProfileTab = Window:CreateTab({
        Name = "Profile",
        Icon = "user"
    })

    ProfileTab:CreateSection("Client Identity")

    -- Profile Info Card
    local profileCard = Instance.new("Frame")
    profileCard.Name = "ProfileCard"
    profileCard.Size = UDim2.new(1, 0, 0, 84)
    profileCard.BackgroundColor3 = theme.Surface2
    profileCard.BorderSizePixel = 0
    profileCard.LayoutOrder = ProfileTab:_nextOrder()
    profileCard.Parent = ProfileTab.List

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = profileCard

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = theme.Stroke
    cardStroke.Thickness = 1
    cardStroke.Parent = profileCard

    local cardPadding = Instance.new("UIPadding")
    cardPadding.PaddingLeft = UDim.new(0, 14)
    cardPadding.PaddingRight = UDim.new(0, 14)
    cardPadding.PaddingTop = UDim.new(0, 12)
    cardPadding.PaddingBottom = UDim.new(0, 12)
    cardPadding.Parent = profileCard

    -- Avatar Thumbnail Image (Circular)
    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Name = "Avatar"
    avatarImg.Size = UDim2.fromOffset(60, 60)
    avatarImg.Position = UDim2.fromOffset(0, 0)
    avatarImg.BackgroundColor3 = theme.Surface
    avatarImg.BorderSizePixel = 0
    avatarImg.Image = "rbxassetid://10723417131"
    avatarImg.ScaleType = Enum.ScaleType.Fit
    avatarImg.Parent = profileCard

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0, 30)
    avatarCorner.Parent = avatarImg

    local avatarStroke = Instance.new("UIStroke")
    avatarStroke.Color = theme.Accent
    avatarStroke.Thickness = 1.5
    avatarStroke.Parent = avatarImg

    -- Asynchronously load headshot thumbnail (non-blocking for 60FPS)
    task.spawn(function()
        if lp and lp.UserId then
            local ok, thumb = pcall(function()
                return I:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
            if ok and thumb and avatarImg and avatarImg.Parent then
                avatarImg.Image = thumb
            end
        end
    end)

    local displayName = lp and lp.DisplayName or "Player"
    local username = lp and lp.Name or "Unknown"
    local userId = lp and lp.UserId or 0

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "DisplayName"
    nameLabel.Size = UDim2.new(1, -76, 0, 22)
    nameLabel.Position = UDim2.fromOffset(74, 2)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 16
    nameLabel.TextColor3 = theme.Text
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Text = displayName
    nameLabel.Parent = profileCard

    local userLabel = Instance.new("TextLabel")
    userLabel.Name = "UsernameAndID"
    userLabel.Size = UDim2.new(1, -76, 0, 16)
    userLabel.Position = UDim2.fromOffset(74, 24)
    userLabel.BackgroundTransparency = 1
    userLabel.Font = Enum.Font.Gotham
    userLabel.TextSize = 12
    userLabel.TextColor3 = theme.Muted
    userLabel.TextXAlignment = Enum.TextXAlignment.Left
    userLabel.Text = "@" .. username .. "  •  ID: " .. tostring(userId)
    userLabel.Parent = profileCard

    local ageLabel = Instance.new("TextLabel")
    ageLabel.Name = "AccountAge"
    ageLabel.Size = UDim2.new(1, -76, 0, 14)
    ageLabel.Position = UDim2.fromOffset(74, 42)
    ageLabel.BackgroundTransparency = 1
    ageLabel.Font = Enum.Font.Gotham
    ageLabel.TextSize = 11
    ageLabel.TextColor3 = theme.Accent
    ageLabel.TextXAlignment = Enum.TextXAlignment.Left
    ageLabel.Text = (lp and tostring(lp.AccountAge) or "0") .. " days on Roblox"
    ageLabel.Parent = profileCard

    -- Game & Place Info
    ProfileTab:CreateSection("Active Place")

    local placeCard = Instance.new("Frame")
    placeCard.Name = "PlaceCard"
    placeCard.Size = UDim2.new(1, 0, 0, 72)
    placeCard.BackgroundColor3 = theme.Surface2
    placeCard.BorderSizePixel = 0
    placeCard.LayoutOrder = ProfileTab:_nextOrder()
    placeCard.Parent = ProfileTab.List

    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(0, 8)
    pCorner.Parent = placeCard

    local pStroke = Instance.new("UIStroke")
    pStroke.Color = theme.Stroke
    pStroke.Thickness = 1
    pStroke.Parent = placeCard

    local pPadding = Instance.new("UIPadding")
    pPadding.PaddingLeft = UDim.new(0, 14)
    pPadding.PaddingRight = UDim.new(0, 14)
    pPadding.PaddingTop = UDim.new(0, 10)
    pPadding.PaddingBottom = UDim.new(0, 10)
    pPadding.Parent = placeCard

    local placeTitleLabel = Instance.new("TextLabel")
    placeTitleLabel.Name = "PlaceTitle"
    placeTitleLabel.Size = UDim2.new(1, 0, 0, 20)
    placeTitleLabel.Position = UDim2.fromOffset(0, 2)
    placeTitleLabel.BackgroundTransparency = 1
    placeTitleLabel.Font = Enum.Font.GothamBold
    placeTitleLabel.TextSize = 14
    placeTitleLabel.TextColor3 = theme.Text
    placeTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    placeTitleLabel.Text = "Loading place info..."
    placeTitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    placeTitleLabel.Parent = placeCard

    local placeIdLabel = Instance.new("TextLabel")
    placeIdLabel.Name = "PlaceId"
    placeIdLabel.Size = UDim2.new(1, 0, 0, 16)
    placeIdLabel.Position = UDim2.fromOffset(0, 24)
    placeIdLabel.BackgroundTransparency = 1
    placeIdLabel.Font = Enum.Font.Gotham
    placeIdLabel.TextSize = 12
    placeIdLabel.TextColor3 = theme.Muted
    placeIdLabel.TextXAlignment = Enum.TextXAlignment.Left
    placeIdLabel.Text = "Place ID: " .. tostring(game.PlaceId)
    placeIdLabel.Parent = placeCard

    local jobIdLabel = Instance.new("TextLabel")
    jobIdLabel.Name = "JobId"
    jobIdLabel.Size = UDim2.new(1, 0, 0, 14)
    jobIdLabel.Position = UDim2.fromOffset(0, 42)
    jobIdLabel.BackgroundTransparency = 1
    jobIdLabel.Font = Enum.Font.Gotham
    jobIdLabel.TextSize = 11
    jobIdLabel.TextColor3 = theme.Accent
    jobIdLabel.TextXAlignment = Enum.TextXAlignment.Left
    local jid = tostring(game.JobId)
    jobIdLabel.Text = "Server: " .. (jid ~= "" and (jid:sub(1, 16) .. "...") or "Local / Studio")
    jobIdLabel.Parent = placeCard

    task.spawn(function()
        local ok, info = pcall(function()
            return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        end)
        if ok and type(info) == "table" and info.Name and placeTitleLabel and placeTitleLabel.Parent then
            placeTitleLabel.Text = tostring(info.Name)
        else
            pcall(function()
                placeTitleLabel.Text = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
            end)
            if placeTitleLabel.Text == "Loading place info..." then
                placeTitleLabel.Text = "Place " .. tostring(game.PlaceId)
            end
        end
    end)

    ProfileTab:CreateButton({
        Name = "Copy Place ID",
        Desc = "Copy current Place ID to clipboard",
        Icon = "copy",
        Callback = function()
            copyToClipboard(tostring(game.PlaceId))
        end
    })

    ProfileTab:CreateButton({
        Name = "Copy Server Job ID",
        Desc = "Copy server Job ID for joining friends or reconnecting",
        Icon = "copy",
        Callback = function()
            copyToClipboard(game.JobId ~= "" and game.JobId or tostring(game.PlaceId))
        end
    })

    ProfileTab:CreateSection("Settings & Auto-Save")

    ProfileTab:CreateToggle({
        Name = "Auto Save Preferences",
        Desc = "Automatically saves every tapped option to disk instantly",
        Default = true,
        Flag = "Profile_AutoSave",
        Callback = function(val)
            Window:SetAutoSave(val)
        end
    })

    ProfileTab:CreateToggle({
        Name = "Keep Window On Screen",
        Desc = "Clamp the interface bounds within your viewport",
        Default = true,
        Flag = "Profile_KeepOnScreen",
        Callback = function(val)
            Window:SetKeepOnScreen(val)
        end
    })

    ProfileTab:CreateDropdown({
        Name = "Interface Theme",
        Desc = "Persists your chosen visual theme across executions",
        Options = e:GetThemes(),
        Default = e.ThemeName,
        Flag = "Profile_Theme",
        Callback = function(val)
            if val then
                e:SetTheme(val)
            end
        end
    })

    -- ==================================================================
    -- Tab 2: Player (FOV Adjustments by Input & Drag)
    -- ==================================================================
    local PlayerTab = Window:CreateTab({
        Name = "Player",
        Icon = "gamepad"
    })

    local playerConfig = {
        FovEnabled = false,
        FieldOfView = 70,
        DefaultFov = 70
    }

    pcall(function()
        local cam = workspace.CurrentCamera
        if cam and cam.FieldOfView then
            playerConfig.DefaultFov = cam.FieldOfView
        end
    end)

    local function applyCameraFov(targetFov)
        local cam = workspace.CurrentCamera
        if not cam then return end
        if playerConfig.FovEnabled then
            cam.FieldOfView = targetFov or playerConfig.FieldOfView
        else
            cam.FieldOfView = playerConfig.DefaultFov or 70
        end
    end

    PlayerTab:CreateSection("Camera Field of View")

    PlayerTab:CreateToggle({
        Name = "Enable Custom FOV",
        Desc = "Lock and enforce custom field of view in real time",
        Default = false,
        Flag = "Player_FovEnabled",
        Callback = function(val)
            playerConfig.FovEnabled = val
            applyCameraFov()
        end
    })

    local fovSlider = nil
    local fovInput = nil
    local isSyncingFov = false

    local function setTargetFov(newVal, origin)
        local num = tonumber(newVal)
        if not num then return end
        num = math.clamp(math.floor(num + 0.5), 30, 130)
        playerConfig.FieldOfView = num
        applyCameraFov(num)

        if not isSyncingFov then
            isSyncingFov = true
            if origin ~= "slider" and fovSlider and typeof(fovSlider.Set) == "function" then
                pcall(function() fovSlider:Set(num) end)
            end
            if origin ~= "input" and fovInput and typeof(fovInput.Set) == "function" then
                pcall(function() fovInput:Set(tostring(num)) end)
            end
            isSyncingFov = false
        end
    end

    fovSlider = PlayerTab:CreateSlider({
        Name = "FOV (Drag)",
        Desc = "Drag slider or click value bubble to adjust view angle (60° - 130°)",
        Min = 60,
        Max = 130,
        Step = 1,
        Default = 70,
        Suffix = "°",
        Flag = "Player_FieldOfView",
        Callback = function(val)
            setTargetFov(val, "slider")
        end
    })

    fovInput = PlayerTab:CreateInput({
        Name = "FOV (Input)",
        Desc = "Type exact FOV value (30 - 130) and press Enter",
        Default = "70",
        Placeholder = "70",
        Flag = "Player_FovInput",
        Callback = function(val)
            setTargetFov(val, "input")
        end
    })

    PlayerTab:CreateButton({
        Name = "Reset FOV to Default (70°)",
        Desc = "Restore default Roblox camera angle",
        Callback = function()
            setTargetFov(70)
        end
    })

    -- Continuous 60FPS RenderStepped enforcement to prevent game camera scripts from resetting FOV
    local fovRenderConn = game:GetService("RunService").RenderStepped:Connect(function()
        if playerConfig.FovEnabled then
            local cam = workspace.CurrentCamera
            if cam and cam.FieldOfView ~= playerConfig.FieldOfView then
                cam.FieldOfView = playerConfig.FieldOfView
            end
        end
    end)
    table.insert(espConnections, fovRenderConn)

    -- ==================================================================
    -- Tab 3: Visual (Killer ESP, Survivor ESP, Generator ESP)
    -- ==================================================================
    local VisualTab = Window:CreateTab({
        Name = "Visual",
        Icon = "eye"
    })

    local espConfig = {
        KillerESP = true,
        KillerColor = Color3.fromRGB(255, 60, 60),
        KillerName = true,
        KillerStuds = true,

        SurvivorESP = true,
        SurvivorColor = Color3.fromRGB(60, 220, 120),
        SurvivorName = true,
        SurvivorStuds = true,

        GeneratorESP = true,
        GeneratorColor = Color3.fromRGB(255, 205, 50),
        GenName = true,
        GenDistance = true,
        GenProgress = true,
        HideCompleted = true,

        PumpkinESP = true,
        PumpkinColor = Color3.fromRGB(255, 130, 20),
        PumpkinName = true,
        PumpkinDistance = true,

        VaultESP = true,
        VaultColor = Color3.fromRGB(0, 220, 255),
        VaultBox = true,
        VaultName = true,
        VaultStuds = true,
        BoxTransparency = 0.65,

        PalletESP = true,
        PalletColor = Color3.fromRGB(245, 185, 45),
        PalletName = true,
        PalletStuds = true,

        GateESP = true,
        GateColor = Color3.fromRGB(60, 240, 120),
        GateName = true,
        GateStuds = true,

        HookESP = true,
        HookColor = Color3.fromRGB(195, 80, 255),
        HookName = true,
        HookStuds = true,

        TrapESP = true,
        TrapColor = Color3.fromRGB(255, 50, 50),
        TrapName = true,
        TrapStuds = true,

        MaxDistance = 2500,
        FillTransparency = 0.5,
        OutlineTransparency = 0
    }

    -- Killer Controls
    VisualTab:CreateSection("Killer ESP")

    VisualTab:CreateToggle({
        Name = "Killer ESP",
        Desc = "Highlight killer players with full visibility through walls",
        Default = true,
        Flag = "Visual_KillerESP",
        Callback = function(val)
            espConfig.KillerESP = val
        end
    })

    VisualTab:CreateColorPicker({
        Name = "Killer Color",
        Desc = "Customize killer highlight and tag color",
        Default = Color3.fromRGB(255, 60, 60),
        Flag = "Visual_KillerColor",
        Callback = function(val)
            espConfig.KillerColor = val
        end
    })

    VisualTab:CreateToggle({
        Name = "Show Killer Name",
        Desc = "Display killer name tag and role",
        Default = true,
        Flag = "Visual_KillerName",
        Callback = function(val)
            espConfig.KillerName = val
        end
    })

    VisualTab:CreateToggle({
        Name = "Show Killer Studs",
        Desc = "Display live distance to killer in studs",
        Default = true,
        Flag = "Visual_KillerStuds",
        Callback = function(val)
            espConfig.KillerStuds = val
        end
    })

    -- Survivor Controls
    VisualTab:CreateSection("Survivor ESP")

    VisualTab:CreateToggle({
        Name = "Survivor ESP",
        Desc = "Highlight team survivors with clear wallhack outlines",
        Default = true,
        Flag = "Visual_SurvivorESP",
        Callback = function(val)
            espConfig.SurvivorESP = val
        end
    })

    VisualTab:CreateColorPicker({
        Name = "Survivor Color",
        Desc = "Customize survivor highlight and tag color",
        Default = Color3.fromRGB(60, 220, 120),
        Flag = "Visual_SurvivorColor",
        Callback = function(val)
            espConfig.SurvivorColor = val
        end
    })

    VisualTab:CreateToggle({
        Name = "Show Survivor Name",
        Desc = "Display survivor player names",
        Default = true,
        Flag = "Visual_SurvivorName",
        Callback = function(val)
            espConfig.SurvivorName = val
        end
    })

    VisualTab:CreateToggle({
        Name = "Show Survivor Studs",
        Desc = "Display live distance to survivors in studs",
        Default = true,
        Flag = "Visual_SurvivorStuds",
        Callback = function(val)
            espConfig.SurvivorStuds = val
        end
    })

    -- Generator Controls
    VisualTab:CreateSection("Generator ESP")

    VisualTab:CreateToggle({
        Name = "Generator ESP",
        Desc = "Locate all map generators through obstacles with live progress",
        Default = true,
        Flag = "Visual_GeneratorESP",
        Callback = function(val)
            espConfig.GeneratorESP = val
        end
    })

    VisualTab:CreateColorPicker({
        Name = "Generator Color",
        Desc = "Customize generator highlight and marker color",
        Default = Color3.fromRGB(255, 205, 50),
        Flag = "Visual_GeneratorColor",
        Callback = function(val)
            espConfig.GeneratorColor = val
        end
    })

    VisualTab:CreateToggle({
        Name = "Show Generator Name",
        Desc = "Display Generator label on tags",
        Default = true,
        Flag = "Visual_GenName",
        Callback = function(val)
            espConfig.GenName = val
        end
    })

    VisualTab:CreateToggle({
        Name = "Show Generator Studs",
        Desc = "Display live distance to each generator in studs",
        Default = true,
        Flag = "Visual_GenDistance",
        Callback = function(val)
            espConfig.GenDistance = val
        end
    })

    VisualTab:CreateToggle({
        Name = "Show Repair Progress",
        Desc = "Display 0-100% completion status on generator tags",
        Default = true,
        Flag = "Visual_GenProgress",
        Callback = function(val)
            espConfig.GenProgress = val
        end
    })

    VisualTab:CreateToggle({
        Name = "Hide Completed (100%)",
        Desc = "Do not show ESP or markers for fully repaired 100% generators",
        Default = true,
        Flag = "Visual_HideCompletedGens",
        Callback = function(val)
            espConfig.HideCompleted = val
        end
    })

    -- Pumpkin Controls
    VisualTab:CreateSection("Pumpkin ESP")

    VisualTab:CreateToggle({
        Name = "Pumpkin ESP",
        Desc = "Highlight collectible pumpkins across the district map",
        Default = true,
        Flag = "Visual_PumpkinESP",
        Callback = function(val)
            espConfig.PumpkinESP = val
        end
    })

    VisualTab:CreateColorPicker({
        Name = "Pumpkin Color",
        Desc = "Customize pumpkin highlight and marker color",
        Default = Color3.fromRGB(255, 130, 20),
        Flag = "Visual_PumpkinColor",
        Callback = function(val)
            espConfig.PumpkinColor = val
        end
    })

    VisualTab:CreateToggle({
        Name = "Show Pumpkin Name",
        Desc = "Display Pumpkin label on tags",
        Default = true,
        Flag = "Visual_PumpkinName",
        Callback = function(val)
            espConfig.PumpkinName = val
        end
    })

    VisualTab:CreateToggle({
        Name = "Show Pumpkin Studs",
        Desc = "Display live distance to each pumpkin in studs",
        Default = true,
        Flag = "Visual_PumpkinDistance",
        Callback = function(val)
            espConfig.PumpkinDistance = val
        end
    })

    -- Vault Controls
    VisualTab:CreateSection("Vault ESP")

    VisualTab:CreateToggle({
        Name = "Vault ESP",
        Desc = "Highlight window vaults through walls",
        Default = true,
        Flag = "Visual_VaultESP",
        Callback = function(val)
            espConfig.VaultESP = val
        end
    })

    VisualTab:CreateColorPicker({
        Name = "Vault Color",
        Desc = "Customize vault 3D box and tag color",
        Default = Color3.fromRGB(0, 220, 255),
        Flag = "Visual_VaultColor",
        Callback = function(val)
            espConfig.VaultColor = val
        end
    })

    VisualTab:CreateToggle({
        Name = "Vault 3D Box",
        Desc = "Render slim-fit 3D box around window bottom",
        Default = true,
        Flag = "Visual_VaultBox",
        Callback = function(val)
            espConfig.VaultBox = val
        end
    })

    VisualTab:CreateToggle({
        Name = "Show Vault Name",
        Desc = "Display VAULT label on tags",
        Default = true,
        Flag = "Visual_VaultName",
        Callback = function(val)
            espConfig.VaultName = val
        end
    })

    VisualTab:CreateToggle({
        Name = "Show Vault Studs",
        Desc = "Display live distance to vault in studs",
        Default = true,
        Flag = "Visual_VaultStuds",
        Callback = function(val)
            espConfig.VaultStuds = val
        end
    })

    -- Pallet Controls
    VisualTab:CreateSection("Pallet ESP")

    VisualTab:CreateToggle({
        Name = "Pallet ESP",
        Desc = "Highlight pallet structures (Newpallet) across the district",
        Default = true,
        Flag = "Visual_PalletESP",
        Callback = function(val)
            espConfig.PalletESP = val
        end
    })

    VisualTab:CreateColorPicker({
        Name = "Pallet Color",
        Desc = "Customize pallet highlight and marker color",
        Default = Color3.fromRGB(245, 185, 45),
        Flag = "Visual_PalletColor",
        Callback = function(val)
            espConfig.PalletColor = val
        end
    })

    VisualTab:CreateToggle({
        Name = "Show Pallet Name",
        Desc = "Display PALLET label on tags",
        Default = true,
        Flag = "Visual_PalletName",
        Callback = function(val)
            espConfig.PalletName = val
        end
    })

    VisualTab:CreateToggle({
        Name = "Show Pallet Studs",
        Desc = "Display live distance to pallet in studs",
        Default = true,
        Flag = "Visual_PalletStuds",
        Callback = function(val)
            espConfig.PalletStuds = val
        end
    })

    -- Exit Gate Controls
    VisualTab:CreateSection("Exit Gate ESP")

    VisualTab:CreateToggle({
        Name = "Exit Gate ESP",
        Desc = "Highlight escape gates and switches through obstacles",
        Default = true,
        Flag = "Visual_GateESP",
        Callback = function(val)
            espConfig.GateESP = val
        end
    })

    VisualTab:CreateColorPicker({
        Name = "Gate Color",
        Desc = "Customize exit gate highlight and marker color",
        Default = Color3.fromRGB(60, 240, 120),
        Flag = "Visual_GateColor",
        Callback = function(val)
            espConfig.GateColor = val
        end
    })

    VisualTab:CreateToggle({
        Name = "Show Gate Name",
        Desc = "Display EXIT GATE label on tags",
        Default = true,
        Flag = "Visual_GateName",
        Callback = function(val)
            espConfig.GateName = val
        end
    })

    VisualTab:CreateToggle({
        Name = "Show Gate Studs",
        Desc = "Display live distance to exit gate in studs",
        Default = true,
        Flag = "Visual_GateStuds",
        Callback = function(val)
            espConfig.GateStuds = val
        end
    })

    -- Hook Controls
    VisualTab:CreateSection("Hook ESP")

    VisualTab:CreateToggle({
        Name = "Hook ESP",
        Desc = "Highlight sacrifice hooks (Hook.001) through walls",
        Default = true,
        Flag = "Visual_HookESP",
        Callback = function(val)
            espConfig.HookESP = val
        end
    })

    VisualTab:CreateColorPicker({
        Name = "Hook Color",
        Desc = "Customize sacrifice hook highlight and marker color",
        Default = Color3.fromRGB(195, 80, 255),
        Flag = "Visual_HookColor",
        Callback = function(val)
            espConfig.HookColor = val
        end
    })

    VisualTab:CreateToggle({
        Name = "Show Hook Name",
        Desc = "Display HOOK label on tags",
        Default = true,
        Flag = "Visual_HookName",
        Callback = function(val)
            espConfig.HookName = val
        end
    })

    VisualTab:CreateToggle({
        Name = "Show Hook Studs",
        Desc = "Display live distance to sacrifice hook in studs",
        Default = true,
        Flag = "Visual_HookStuds",
        Callback = function(val)
            espConfig.HookStuds = val
        end
    })

    -- Trap Controls
    VisualTab:CreateSection("Trap ESP")

    VisualTab:CreateToggle({
        Name = "Trap ESP",
        Desc = "Highlight killer traps and disarm triggers",
        Default = true,
        Flag = "Visual_TrapESP",
        Callback = function(val)
            espConfig.TrapESP = val
        end
    })

    VisualTab:CreateColorPicker({
        Name = "Trap Color",
        Desc = "Customize trap highlight and marker color",
        Default = Color3.fromRGB(255, 50, 50),
        Flag = "Visual_TrapColor",
        Callback = function(val)
            espConfig.TrapColor = val
        end
    })

    VisualTab:CreateToggle({
        Name = "Show Trap Name",
        Desc = "Display TRAP label on tags",
        Default = true,
        Flag = "Visual_TrapName",
        Callback = function(val)
            espConfig.TrapName = val
        end
    })

    VisualTab:CreateToggle({
        Name = "Show Trap Studs",
        Desc = "Display live distance to trap in studs",
        Default = true,
        Flag = "Visual_TrapStuds",
        Callback = function(val)
            espConfig.TrapStuds = val
        end
    })

    -- Visual Tuning & Sliders
    VisualTab:CreateSection("Display Settings")

    VisualTab:CreateSlider({
        Name = "Max Render Distance",
        Desc = "Max distance in studs to render visual highlights",
        Min = 200,
        Max = 5000,
        Step = 100,
        Default = 2500,
        Flag = "Visual_MaxDistance",
        Callback = function(val)
            espConfig.MaxDistance = val
        end
    })

    VisualTab:CreateSlider({
        Name = "Fill Transparency",
        Desc = "Adjust inner fill opacity of character highlights",
        Min = 0,
        Max = 1,
        Step = 0.05,
        Default = 0.5,
        Flag = "Visual_FillTransparency",
        Callback = function(val)
            espConfig.FillTransparency = val
        end
    })

    VisualTab:CreateSlider({
        Name = "Outline Transparency",
        Desc = "Adjust outer border opacity of character highlights",
        Min = 0,
        Max = 1,
        Step = 0.05,
        Default = 0,
        Flag = "Visual_OutlineTransparency",
        Callback = function(val)
            espConfig.OutlineTransparency = val
        end
    })

    -- ==================================================================
    -- AUTOMATIC TAB
    -- ==================================================================
    local autoConfig = {
        PerfectSkillCheck = true,
        SkillCheckMode = "Perfect",
        SkillCheckDelay = 0,
        SupportMobileTouch = true
    }

    local AutomaticTab = Window:CreateTab({
        Name = "Automatic",
        Icon = "zap"
    })

    AutomaticTab:CreateSection("Skill Check Automation")

    AutomaticTab:CreateToggle({
        Name = "Auto Perfect Skill Check",
        Desc = "Automatically hits perfect skill checks for Generators and Trap Freeing",
        Default = true,
        Flag = "Auto_PerfectSkillCheck",
        Callback = function(val)
            autoConfig.PerfectSkillCheck = val
        end
    })

    AutomaticTab:CreateDropdown({
        Name = "Skill Check Accuracy",
        Desc = "Select accuracy zone (Perfect gives maximum progression & fastest escape)",
        Options = { "Perfect", "Great", "Safe" },
        Default = "Perfect",
        Flag = "Auto_SkillCheckMode",
        Callback = function(val)
            autoConfig.SkillCheckMode = val or "Perfect"
        end
    })

    AutomaticTab:CreateSlider({
        Name = "Skill Check Delay",
        Desc = "Humanization timing delay in milliseconds before hitting the skill check",
        Min = 0,
        Max = 50,
        Step = 5,
        Default = 0,
        Suffix = "ms",
        Flag = "Auto_SkillCheckDelay",
        Callback = function(val)
            autoConfig.SkillCheckDelay = val
        end
    })

    AutomaticTab:CreateToggle({
        Name = "Support Mobile Action Touch",
        Desc = "Simulate exact mobile button press when touch controls are present",
        Default = true,
        Flag = "Auto_SkillCheckTouch",
        Callback = function(val)
            autoConfig.SupportMobileTouch = val
        end
    })

    AutomaticTab:CreateSection("Automation Status")

    local autoStatusLabel = AutomaticTab:CreateLabel({
        Text = "Skill Check Engine: Active • Ready for generators & traps...",
        Color = Color3.fromRGB(120, 225, 150)
    })

    -- ==================================================================
    -- TAB 4: OPTIMIZE (FPS BOOSTER, FULL BRIGHT, NO FOG)
    -- ==================================================================
    local Lighting = game:GetService("Lighting")
    local optimizeConfig = {
        BoostFPS = false,
        FullBright = false,
        NoFog = false
    }

    local OptimizeTab = Window:CreateTab({
        Name = "Optimize",
        Icon = "cog"
    })

    -- Storage for original graphics & lighting state for clean restoration
    local defaultLighting = {
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        FogColor = Lighting.FogColor
    }

    local optimizeConnections = {}
    local originalPostEffects = {}
    local disabledAtmospheres = {}
    local fullBrightLight = nil
    local isEnforcingOptimize = false

    -- Camera PointLight Anchor: instantly re-anchors to CurrentCamera across match respawns & round switches
    local function ensureCameraFullBright()
        if not optimizeConfig.FullBright then return end
        local cam = workspace.CurrentCamera or camera
        if not cam then return end
        if not fullBrightLight or fullBrightLight.Parent ~= cam then
            pcall(function()
                if fullBrightLight then fullBrightLight:Destroy() end
            end)
            pcall(function()
                local light = Instance.new("PointLight")
                light.Name = "ExeHub_FullBrightLight"
                light.Range = 10000
                light.Brightness = 2.5
                light.Shadows = false
                light.Parent = cam
                fullBrightLight = light
            end)
        end
    end

    -- Persistent Round Enforcement: guarantees zero lighting revert across all rounds
    local function enforceOptimizations()
        if isEnforcingOptimize then return end
        isEnforcingOptimize = true

        pcall(function()
            if optimizeConfig.FullBright then
                if Lighting.Ambient ~= Color3.fromRGB(255, 255, 255) then
                    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
                end
                if Lighting.OutdoorAmbient ~= Color3.fromRGB(255, 255, 255) then
                    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
                end
                if Lighting.Brightness ~= 2 then
                    Lighting.Brightness = 2
                end
                if Lighting.ClockTime ~= 14 then
                    Lighting.ClockTime = 14
                end
                if Lighting.GlobalShadows ~= false then
                    Lighting.GlobalShadows = false
                end
                ensureCameraFullBright()
            end

            if optimizeConfig.NoFog then
                if Lighting.FogEnd < 100000 then
                    Lighting.FogEnd = 1000000
                    Lighting.FogStart = 0
                end
                for _, child in ipairs(Lighting:GetChildren()) do
                    if child:IsA("Atmosphere") then
                        if child.Density > 0 or child.Haze > 0 or child.Glare > 0 then
                            child.Density = 0
                            child.Haze = 0
                            child.Glare = 0
                        end
                    elseif (child:IsA("DepthOfFieldEffect") or child:IsA("BlurEffect")) and child.Enabled then
                        originalPostEffects[child] = true
                        child.Enabled = false
                    end
                end
            end

            if optimizeConfig.BoostFPS then
                if Lighting.GlobalShadows ~= false then
                    Lighting.GlobalShadows = false
                end
                for _, child in ipairs(Lighting:GetChildren()) do
                    if child:IsA("PostEffect") and child.Enabled then
                        originalPostEffects[child] = true
                        child.Enabled = false
                    end
                end
            end
        end)

        isEnforcingOptimize = false
    end

    -- Smooth Full Bright Engine (Camera PointLight + Lighting Enforcement, Zero Latency)
    local function applyFullBright(enabled)
        if enabled then
            enforceOptimizations()
            ensureCameraFullBright()
        else
            if fullBrightLight then
                pcall(function() fullBrightLight:Destroy() end)
                fullBrightLight = nil
            end
            pcall(function()
                Lighting.Ambient = defaultLighting.Ambient
                Lighting.OutdoorAmbient = defaultLighting.OutdoorAmbient
                Lighting.Brightness = defaultLighting.Brightness
                Lighting.ClockTime = defaultLighting.ClockTime
                if not optimizeConfig.BoostFPS then
                    Lighting.GlobalShadows = defaultLighting.GlobalShadows
                end
            end)
        end
    end

    -- Smooth No Fog Engine
    local function applyNoFog(enabled)
        if enabled then
            for _, child in ipairs(Lighting:GetChildren()) do
                if child:IsA("Atmosphere") then
                    disabledAtmospheres[child] = {
                        Density = child.Density,
                        Haze = child.Haze,
                        Glare = child.Glare
                    }
                end
            end
            enforceOptimizations()
        else
            pcall(function()
                Lighting.FogEnd = defaultLighting.FogEnd
                Lighting.FogStart = defaultLighting.FogStart
            end)
            for atmos, props in pairs(disabledAtmospheres) do
                if atmos and atmos.Parent then
                    pcall(function()
                        atmos.Density = props.Density or 0.3
                        atmos.Haze = props.Haze or 0
                        atmos.Glare = props.Glare or 0
                    end)
                end
            end
            table.clear(disabledAtmospheres)
        end
    end

    -- Smooth FPS Boost Engine (Zero-Replication: Lighting, Quality & Local Effects Only)
    local function applyFpsBoost(enabled)
        if enabled then
            pcall(function()
                if typeof(setfpscap) == "function" then
                    setfpscap(999)
                elseif typeof(set_fps_cap) == "function" then
                    set_fps_cap(999)
                end
            end)
            enforceOptimizations()
        else
            for effect, _ in pairs(originalPostEffects) do
                if effect and effect.Parent then
                    pcall(function() effect.Enabled = true end)
                end
            end
            table.clear(originalPostEffects)

            if not optimizeConfig.FullBright then
                pcall(function() Lighting.GlobalShadows = defaultLighting.GlobalShadows end)
            end
        end
    end

    -- Multi-Round Persistent Event Listeners (Reacts instantly to new round lighting changes)
    table.insert(optimizeConnections, Lighting.ChildAdded:Connect(function(child)
        if optimizeConfig.NoFog or optimizeConfig.BoostFPS then
            task.delay(0.05, enforceOptimizations)
        end
    end))

    table.insert(optimizeConnections, Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
        if optimizeConfig.FullBright and not isEnforcingOptimize and Lighting.Ambient ~= Color3.fromRGB(255, 255, 255) then
            enforceOptimizations()
        end
    end))

    table.insert(optimizeConnections, Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
        if optimizeConfig.FullBright and not isEnforcingOptimize and Lighting.ClockTime ~= 14 then
            enforceOptimizations()
        end
    end))

    table.insert(optimizeConnections, Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
        if optimizeConfig.NoFog and not isEnforcingOptimize and Lighting.FogEnd < 100000 then
            enforceOptimizations()
        end
    end))

    table.insert(optimizeConnections, Lighting:GetPropertyChangedSignal("GlobalShadows"):Connect(function()
        if (optimizeConfig.FullBright or optimizeConfig.BoostFPS) and not isEnforcingOptimize and Lighting.GlobalShadows ~= false then
            enforceOptimizations()
        end
    end))

    table.insert(optimizeConnections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        if optimizeConfig.FullBright then
            task.delay(0.05, function()
                pcall(ensureCameraFullBright)
            end)
        end
    end))

    OptimizeTab:CreateSection("Performance Booster")

    OptimizeTab:CreateToggle({
        Name = "Boost FPS",
        Desc = "Optimizes rendering, materials, particles, and shadows for smooth framerate",
        Default = false,
        Flag = "Optimize_BoostFPS",
        Callback = function(val)
            optimizeConfig.BoostFPS = val
            applyFpsBoost(val)
        end
    })

    OptimizeTab:CreateSection("Lighting & Visibility")

    OptimizeTab:CreateToggle({
        Name = "Full Bright",
        Desc = "Illuminates dark areas and removes shadows across the map",
        Default = false,
        Flag = "Optimize_FullBright",
        Callback = function(val)
            optimizeConfig.FullBright = val
            applyFullBright(val)
        end
    })

    OptimizeTab:CreateToggle({
        Name = "No Fog",
        Desc = "Clears all environmental fog, mist, and atmosphere haze",
        Default = false,
        Flag = "Optimize_NoFog",
        Callback = function(val)
            optimizeConfig.NoFog = val
            applyNoFog(val)
        end
    })

    OptimizeTab:CreateSection("Optimization Status")

    local optimizeStatusLabel = OptimizeTab:CreateLabel({
        Text = "Engine: Ready • Toggle features above for instant optimization",
        Color = Color3.fromRGB(150, 220, 170)
    })

    -- ==================================================================
    -- TAB 5: SERVER (QUICK SERVER ACTIONS & HOPPING)
    -- ==================================================================
    local ServerTab = Window:CreateTab({
        Name = "Server",
        Icon = "server"
    })

    local isHopping = false

    local function fetchPublicServers()
        local placeId = game.PlaceId
        local currentJobId = game.JobId
        local url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", tostring(placeId))

        local success, response = pcall(function()
            if typeof(game.HttpGet) == "function" then
                return game:HttpGet(url)
            elseif typeof(request) == "function" then
                local res = request({ Url = url, Method = "GET" })
                return res and res.Body
            elseif typeof(http_request) == "function" then
                local res = http_request({ Url = url, Method = "GET" })
                return res and res.Body
            end
            return nil
        end)

        if not success or not response then
            return nil, "Failed to connect to Roblox Server API"
        end

        local decodeSuccess, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(response)
        end)

        if not decodeSuccess or not data or not data.data then
            return nil, "Failed to parse server list JSON"
        end

        local validServers = {}
        for _, s in ipairs(data.data) do
            if s.id and s.id ~= currentJobId and (tonumber(s.playing) or 0) < (tonumber(s.maxPlayers) or 12) then
                table.insert(validServers, {
                    id = tostring(s.id),
                    playing = tonumber(s.playing) or 0,
                    maxPlayers = tonumber(s.maxPlayers) or 12,
                    ping = tonumber(s.ping) or 0,
                    fps = tonumber(s.fps) or 60
                })
            end
        end

        return validServers
    end

    local serverStatusLabel = ServerTab:CreateLabel({
        Text = "Server Engine: Ready • Select a quick action below",
        Color = Color3.fromRGB(150, 220, 170)
    })

    ServerTab:CreateSection("Quick Server Actions")

    ServerTab:CreateButton({
        Name = "Quick Hop (Fewest Players)",
        Desc = "Instantly teleports to the public server with the smallest player count",
        Callback = function()
            if isHopping then return end
            isHopping = true
            e:Notify({
                Title = "Server Hop",
                Content = "Searching for server with fewest players...",
                Duration = 3
            })
            serverStatusLabel:Set("Searching for lowest population server...")
            task.spawn(function()
                local servers, err = fetchPublicServers()
                if not servers or #servers == 0 then
                    isHopping = false
                    serverStatusLabel:Set("No alternative servers available")
                    e:Notify({
                        Title = "Server Hop",
                        Content = err or "No alternative public servers found",
                        Type = "Warning",
                        Duration = 3
                    })
                    return
                end

                table.sort(servers, function(a, b)
                    if a.playing == b.playing then
                        local pA = a.ping > 0 and a.ping or 999
                        local pB = b.ping > 0 and b.ping or 999
                        return pA < pB
                    end
                    return a.playing < b.playing
                end)

                local target = servers[1]
                serverStatusLabel:Set(string.format("Connecting to server [%s] (%d/%d players)...", target.id:sub(1, 8), target.playing, target.maxPlayers))
                e:Notify({
                    Title = "Connecting",
                    Content = string.format("Teleporting to server with %d/%d players...", target.playing, target.maxPlayers),
                    Duration = 4
                })
                task.wait(0.2)
                pcall(function()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, target.id, lp)
                end)
                task.delay(4, function() isHopping = false end)
            end)
        end
    })

    ServerTab:CreateButton({
        Name = "Quick Hop (Lowest Ping)",
        Desc = "Instantly teleports to the public server with lowest estimated latency",
        Callback = function()
            if isHopping then return end
            isHopping = true
            e:Notify({
                Title = "Server Hop",
                Content = "Searching for server with lowest ping...",
                Duration = 3
            })
            serverStatusLabel:Set("Searching for lowest latency server...")
            task.spawn(function()
                local servers, err = fetchPublicServers()
                if not servers or #servers == 0 then
                    isHopping = false
                    serverStatusLabel:Set("No alternative servers available")
                    e:Notify({
                        Title = "Server Hop",
                        Content = err or "No alternative public servers found",
                        Type = "Warning",
                        Duration = 3
                    })
                    return
                end

                table.sort(servers, function(a, b)
                    local pA = a.ping > 0 and a.ping or 999
                    local pB = b.ping > 0 and b.ping or 999
                    if pA == pB then
                        return a.playing < b.playing
                    end
                    return pA < pB
                end)

                local target = servers[1]
                serverStatusLabel:Set(string.format("Connecting to server [%s] (%dms ping)...", target.id:sub(1, 8), target.ping))
                e:Notify({
                    Title = "Connecting",
                    Content = string.format("Teleporting to server with %dms ping...", target.ping),
                    Duration = 4
                })
                task.wait(0.2)
                pcall(function()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, target.id, lp)
                end)
                task.delay(4, function() isHopping = false end)
            end)
        end
    })

    ServerTab:CreateButton({
        Name = "Quick Rejoin",
        Desc = "Reconnects you immediately to this exact server instance",
        Callback = function()
            serverStatusLabel:Set("Reconnecting to current server...")
            e:Notify({
                Title = "Rejoin",
                Content = "Rejoining server instance...",
                Duration = 3
            })
            task.wait(0.2)
            pcall(function()
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
            end)
        end
    })

    -- ==================================================================
    -- TAB 6: SETTINGS (THEMES, KEYBINDS, CONFIGS & LIFECYCLE)
    -- ==================================================================
    local SettingsTab = Window:CreateTab({
        Name = "Settings",
        Icon = "settings"
    })

    SettingsTab:CreateSection("Appearance & Themes")

    SettingsTab:CreateDropdown({
        Name = "Interface Theme",
        Desc = "Select accent and surface color palette",
        Options = e:GetThemes(),
        Default = e.ThemeName or "Default",
        Flag = "Settings_Theme",
        Callback = function(val)
            if val then
                e:SetTheme(val)
            end
        end
    })

    SettingsTab:CreateSection("Interface Controls")

    SettingsTab:CreateKeybind({
        Name = "Toggle Hub Keybind",
        Desc = "Key to show or hide the EXE HUB interface",
        Default = Enum.KeyCode.RightShift,
        Flag = "Settings_ToggleKeybind",
        Callback = function(key)
            if key then
                Window:SetKeybind(key)
            end
        end
    })

    SettingsTab:CreateToggle({
        Name = "Keep Window On Screen",
        Desc = "Prevents the interface window from being dragged outside the viewport",
        Default = true,
        Flag = "Settings_KeepOnScreen",
        Callback = function(val)
            Window:SetKeepOnScreen(val)
        end
    })

    SettingsTab:CreateSection("Configuration Management")

    SettingsTab:CreateButton({
        Name = "Save Configuration",
        Desc = "Saves all current flags, ESP settings, and toggles to disk",
        Callback = function()
            pcall(function()
                if Window and typeof(Window.SaveConfig) == "function" then
                    Window:SaveConfig()
                end
            end)
            e:Notify({
                Title = "Config Saved",
                Content = "Configuration successfully saved to disk!",
                Type = "Success",
                Duration = 2
            })
        end
    })

    SettingsTab:CreateButton({
        Name = "Load Configuration",
        Desc = "Reloads previously saved configuration from disk",
        Callback = function()
            pcall(function()
                if Window and typeof(Window.LoadConfig) == "function" then
                    Window:LoadConfig()
                end
            end)
            e:Notify({
                Title = "Config Loaded",
                Content = "Configuration reloaded from disk!",
                Type = "Success",
                Duration = 2
            })
        end
    })

    SettingsTab:CreateSection("Hub Lifecycle & Version")

    SettingsTab:CreateLabel({
        Text = "EXE HUB v1.0 Final Build • Violence District",
        Color = Color3.fromRGB(150, 220, 170)
    })

    SettingsTab:CreateButton({
        Name = "Unload EXE HUB",
        Desc = "Cleanly unloads the entire hub, disconnects ESP loops, and restores graphics",
        Callback = function()
            local confirmFn = (Window and Window.Confirm) or (e and e.Confirm)
            local function doUnload()
                pcall(function()
                    if typeof(getgenv) == "function" and type(getgenv()._EXEHUB_CLEANUP) == "function" then
                        getgenv()._EXEHUB_CLEANUP()
                    else
                        for _, taskFn in ipairs(activeCleanupTasks) do
                            pcall(taskFn)
                        end
                        table.clear(activeCleanupTasks)
                        if Window and not Window._destroyed then
                            Window:Destroy()
                        end
                    end
                end)
            end

            if type(confirmFn) == "function" then
                confirmFn(Window or e, {
                    Title = "Unload EXE HUB",
                    Content = "Are you sure you want to unload EXE HUB? All ESP loops and features will terminate cleanly.",
                    ConfirmText = "Unload",
                    CancelText = "Cancel",
                    Callback = doUnload
                })
            else
                doUnload()
            end
        end
    })

    -- ==================================================================
    -- HIGH-PERFORMANCE 60FPS ESP & AUTOMATION ENGINE
    -- ==================================================================
    local playerHighlights = {}
    local playerTags = {}
    local genHighlights = {}
    local genTags = {}
    local discoveredGens = {}
    local pumpkinHighlights = {}
    local pumpkinTags = {}
    local discoveredPumpkins = {}

    local discoveredVaults = {}
    local discoveredTraps = {}
    local discoveredPallets = {}
    local discoveredHooks = {}
    local discoveredGates = {}

    local mapHighlights = {}
    local selectionBoxes = {}
    local boxAdornments = {}
    local mapTags = {}

    -- Universal Killer Detection Strategy
    local function isPlayerKiller(player)
        if not player or player == lp then return false end

        -- 1. Check Team Name
        local team = player.Team
        if team then
            local tname = team.Name:lower()
            if tname:find("killer", 1, true) or tname:find("murder", 1, true) or tname:find("beast", 1, true)
                or tname:find("hunter", 1, true) or tname:find("monster", 1, true) or tname:find("slasher", 1, true) then
                return true
            end
        end

        -- 2. Player Attributes
        local role = player:GetAttribute("Role") or player:GetAttribute("Class") or player:GetAttribute("Team")
        if type(role) == "string" then
            local r = role:lower()
            if r:find("killer", 1, true) or r:find("murder", 1, true) or r:find("beast", 1, true) or r:find("hunter", 1, true) then
                return true
            end
        end
        if player:GetAttribute("IsKiller") == true or player:GetAttribute("Killer") == true then
            return true
        end

        -- 3. Character & Tools Check
        local char = player.Character
        if char then
            local crole = char:GetAttribute("Role") or char:GetAttribute("Class")
            if type(crole) == "string" and (crole:lower():find("killer", 1, true) or crole:lower():find("beast", 1, true)) then
                return true
            end
            if char:GetAttribute("IsKiller") == true or char:GetAttribute("Killer") == true then
                return true
            end

            local weaponNames = { "knife", "hammer", "machete", "axe", "weapon", "chainsaw", "scythe", "slash", "club", "claw" }
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Tool") then
                    local iname = item.Name:lower()
                    for _, w in ipairs(weaponNames) do
                        if iname:find(w, 1, true) then return true end
                    end
                end
            end
            local bp = player:FindFirstChild("Backpack")
            if bp then
                for _, item in ipairs(bp:GetChildren()) do
                    if item:IsA("Tool") then
                        local iname = item.Name:lower()
                        for _, w in ipairs(weaponNames) do
                            if iname:find(w, 1, true) then return true end
                        end
                    end
                end
            end
        end

        return false
    end

    -- Universal Generator Detection Strategy
    local function isGeneratorModel(obj)
        if not obj or not obj.Parent then return false end
        if not obj:IsA("Model") then return false end
        if obj:FindFirstAncestorOfClass("Player") then return false end
        for _, p in ipairs(I:GetPlayers()) do
            if p.Character and (obj == p.Character or obj:IsDescendantOf(p.Character)) then
                return false
            end
        end

        local name = obj.Name:lower()
        if name:find("animation", 1, true) or name:find("gui", 1, true) or name:find("effect", 1, true) then
            return false
        end

        if name:find("generator", 1, true) or name:find("gens") or name:find("^gen") then
            return true
        end
        if obj:GetAttribute("RepairProgress") ~= nil or obj:GetAttribute("Progress") ~= nil
           or obj:GetAttribute("Completed") ~= nil or obj:GetAttribute("IsCompleted") ~= nil
           or obj:GetAttribute("Repaired") ~= nil or obj:GetAttribute("Done") ~= nil then
            return true
        end
        if obj:FindFirstChild("RepairProgress") or obj:FindFirstChild("Progress")
           or obj:FindFirstChild("Completed") or obj:FindFirstChild("IsCompleted") then
            return true
        end

        local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then
            local pText = (tostring(prompt.ObjectText) .. " " .. tostring(prompt.ActionText) .. " " .. tostring(prompt.Name)):lower()
            if pText:find("gen", 1, true) or pText:find("repair", 1, true) or pText:find("fix", 1, true) then
                return true
            end
        end

        return false
    end

    local function getRootGenerator(obj)
        if not obj then return nil end
        local curr = obj
        local best = nil
        while curr and curr ~= workspace and curr ~= game do
            if curr:IsA("Model") then
                local cname = curr.Name:lower()
                if cname:find("generator", 1, true) or cname:find("^gen") or cname:find("gens")
                   or curr:GetAttribute("RepairProgress") ~= nil or curr:GetAttribute("Progress") ~= nil
                   or curr:GetAttribute("Completed") ~= nil or curr:GetAttribute("IsCompleted") ~= nil
                   or curr:GetAttribute("Done") ~= nil or curr:GetAttribute("Repaired") ~= nil then
                    best = curr
                end
            end
            curr = curr.Parent
        end
        return best or (obj:IsA("Model") and obj) or (obj.Parent and obj.Parent:IsA("Model") and obj.Parent)
    end

    local function getGenProgress(obj)
        if not obj then return nil end
        local raw = obj:GetAttribute("RepairProgress") or obj:GetAttribute("Progress")
                    or obj:GetAttribute("Percent") or obj:GetAttribute("RepairPercent")
                    or obj:GetAttribute("Completion")
        if raw == nil and obj.Parent and obj.Parent ~= workspace then
            raw = obj.Parent:GetAttribute("RepairProgress") or obj.Parent:GetAttribute("Progress")
                  or obj.Parent:GetAttribute("Percent") or obj.Parent:GetAttribute("RepairPercent")
                  or obj.Parent:GetAttribute("Completion")
        end

        if type(raw) == "number" then
            if raw > 0 and raw <= 1 then
                return math.clamp(math.floor(raw * 100 + 0.5), 0, 100)
            end
            return math.clamp(math.floor(raw + 0.5), 0, 100)
        end

        local pv = obj:FindFirstChild("Progress") or obj:FindFirstChild("RepairProgress")
        if pv and (pv:IsA("NumberValue") or pv:IsA("IntValue")) then
            local val = pv.Value
            if val > 0 and val <= 1 then
                return math.clamp(math.floor(val * 100 + 0.5), 0, 100)
            end
            return math.clamp(math.floor(val + 0.5), 0, 100)
        end
        return nil
    end

    local function isGeneratorCompleted(obj)
        if not obj then return false end
        local root = getRootGenerator(obj)
        for _, target in ipairs({ obj, root, obj.Parent }) do
            if target and target ~= workspace then
                if target:GetAttribute("Completed") == true or target:GetAttribute("IsCompleted") == true
                   or target:GetAttribute("Done") == true or target:GetAttribute("Repaired") == true
                   or target:GetAttribute("Finished") == true or target:GetAttribute("Fixed") == true then
                    return true
                end
                local comp = target:FindFirstChild("Completed") or target:FindFirstChild("IsCompleted")
                if comp and (comp:IsA("BoolValue") and comp.Value == true) then
                    return true
                end
                local prog = getGenProgress(target)
                if prog and prog >= 100 then
                    return true
                end
            end
        end
        return false
    end

    local function getGenPart(obj)
        if not obj or not obj.Parent then return nil end
        if obj:IsA("BasePart") then return obj end
        if obj:IsA("Model") then
            if obj.PrimaryPart then return obj.PrimaryPart end
            local core = obj:FindFirstChild("Hitbox") or obj:FindFirstChild("Main") or obj:FindFirstChild("Root")
                         or obj:FindFirstChild("Base") or obj:FindFirstChild("Body") or obj:FindFirstChild("Part")
            if core and core:IsA("BasePart") then return core end
            return obj:FindFirstChildWhichIsA("BasePart", true)
        end
        return nil
    end

    local function registerGenerator(candidate)
        if not candidate or not candidate.Parent then return end
        local obj = candidate
        if not isGeneratorModel(obj) then
            local root = getRootGenerator(candidate)
            if root and isGeneratorModel(root) then
                obj = root
            elseif candidate.Parent and isGeneratorModel(candidate.Parent) then
                obj = candidate.Parent
            else
                return
            end
        end
        if discoveredGens[obj] then return end

        local part = getGenPart(obj)
        if not part then return end

        discoveredGens[obj] = part
    end

    -- Universal Pumpkin Detection Strategy (Accurate & Zero-Lag)
    local function isPumpkinModel(obj)
        if not obj or not obj.Parent then return false end
        if obj == lp or obj == lp.Character or obj:IsDescendantOf(lp.Character or obj) then return false end
        if obj:IsA("Player") or obj:FindFirstChildOfClass("Humanoid") then return false end

        local name = obj.Name:lower()
        if name:find("animation", 1, true) or name:find("gui", 1, true) or name:find("sound", 1, true) or name:find("camera", 1, true) then
            return false
        end

        -- 1. Direct name matching on object
        if name:find("pumpkin", 1, true) or name:find("pumkin", 1, true)
           or name:find("jackolantern", 1, true) or name:find("jack%-o%-lantern")
           or name:find("halloween", 1, true) or name:find("candypumpkin", 1, true) then
            return true
        end

        -- 2. Parent folder name matching (e.g. workspace.Pumpkins.Model or workspace.Map.Collectibles.Spawn1)
        local parent = obj.Parent
        if parent and parent ~= workspace then
            local pName = parent.Name:lower()
            if pName:find("pumpkin", 1, true) or pName:find("pumkin", 1, true)
               or pName:find("halloween", 1, true) or pName == "candies" or pName == "candy"
               or pName == "collectibles" or pName == "treats" then
                if obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Tool") then
                    return true
                end
            end
            local grandParent = parent.Parent
            if grandParent and grandParent ~= workspace then
                local gpName = grandParent.Name:lower()
                if gpName:find("pumpkin", 1, true) or gpName:find("pumkin", 1, true)
                   or gpName:find("halloween", 1, true) then
                    if obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Tool") then
                        return true
                    end
                end
            end
        end

        -- 3. Attributes inspection
        if obj:GetAttribute("Pumpkin") ~= nil or obj:GetAttribute("IsPumpkin") == true
           or obj:GetAttribute("ItemType") == "Pumpkin" or obj:GetAttribute("Candy") ~= nil
           or (parent and (parent:GetAttribute("Pumpkin") ~= nil or parent:GetAttribute("IsPumpkin") == true)) then
            return true
        end

        -- 4. Children check
        if obj:FindFirstChild("Pumpkin") or obj:FindFirstChild("IsPumpkin") or obj:FindFirstChild("JackOLantern") then
            return true
        end

        -- 5. ProximityPrompt inspection (Interactivity tag in Violence District)
        local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then
            local pText = (tostring(prompt.ObjectText) .. " " .. tostring(prompt.ActionText) .. " " .. tostring(prompt.Name)):lower()
            if pText:find("pumpkin", 1, true) or pText:find("pumkin", 1, true)
               or pText:find("candy", 1, true) or pText:find("treat", 1, true)
               or pText:find("jack", 1, true) then
                return true
            end
        end

        return false
    end

    local function getPumpkinPart(obj)
        if not obj or not obj.Parent then return nil end
        if obj:IsA("BasePart") then return obj end
        if obj:IsA("Model") or obj:IsA("Tool") or obj:IsA("Folder") then
            if obj:IsA("Model") and obj.PrimaryPart then return obj.PrimaryPart end
            local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and prompt.Parent and prompt.Parent:IsA("BasePart") then
                return prompt.Parent
            end
            local hit = obj:FindFirstChild("Hitbox") or obj:FindFirstChild("Main") or obj:FindFirstChild("Handle")
                     or obj:FindFirstChild("Root") or obj:FindFirstChild("Part") or obj:FindFirstChild("Pumpkin")
            if hit and hit:IsA("BasePart") then return hit end
            return obj:FindFirstChildWhichIsA("BasePart", true)
        end
        return nil
    end

    local function removePumpkin(targetObj)
        if pumpkinHighlights[targetObj] then
            pcall(function() pumpkinHighlights[targetObj]:Destroy() end)
            pumpkinHighlights[targetObj] = nil
        end
        if pumpkinTags[targetObj] then
            pcall(function() pumpkinTags[targetObj].Gui:Destroy() end)
            pumpkinTags[targetObj] = nil
        end
        discoveredPumpkins[targetObj] = nil
    end

    local function registerPumpkin(obj)
        if not obj or not obj.Parent then return end
        if discoveredPumpkins[obj] then return end

        local targetObj = obj
        if not isPumpkinModel(targetObj) then
            if obj.Parent and isPumpkinModel(obj.Parent) then
                targetObj = obj.Parent
            else
                return
            end
        end

        if discoveredPumpkins[targetObj] then return end
        local part = getPumpkinPart(targetObj)
        if not part then return end
        discoveredPumpkins[targetObj] = part

        -- Instantly unhighlight & remove tag as soon as pumpkin is collected by user
        pcall(function()
            part.AncestryChanged:Connect(function(_, parent)
                if not parent then
                    removePumpkin(targetObj)
                end
            end)
            if targetObj ~= part then
                targetObj.AncestryChanged:Connect(function(_, parent)
                    if not parent then
                        removePumpkin(targetObj)
                    end
                end)
            end
        end)
    end

    -- ==================================================================
    -- MAP ENTITY RESOLVERS (VAULT, TRAP, PALLET, HOOK, GATE)
    -- Deduplicated 1-to-1 root mapping with zero duplicate tags
    -- ==================================================================

    -- 1. Window Vault: Strictly targets the "Bottom" Part in Window
    local function resolveVault(obj)
        if not obj or not obj.Parent then return nil, nil end

        local bottomPart = nil
        if obj:IsA("BasePart") and obj.Name == "Bottom" then
            local p = obj.Parent
            if p and (p.Name == "Window" or p.Name:lower():find("window") or p:FindFirstChild("VaultTrigger")) then
                bottomPart = obj
            end
        end

        if not bottomPart and (obj:IsA("Model") or obj:IsA("Folder")) and (obj.Name == "Window" or obj.Name:lower():find("window")) then
            local b = obj:FindFirstChild("Bottom")
            if b and b:IsA("BasePart") then
                bottomPart = b
            end
        end

        if not bottomPart and obj:IsA("BasePart") and obj.Name == "VaultTrigger" and obj.Parent then
            local b = obj.Parent:FindFirstChild("Bottom")
            if b and b:IsA("BasePart") then
                bottomPart = b
            end
        end

        if bottomPart then
            return bottomPart, bottomPart
        end
        return nil, nil
    end

    -- Checks if an object is inside any player, killer character, or tool (traps held by killer)
    local function isInsideCharacter(obj)
        if not obj or not obj.Parent then return false end

        -- 1. Tool or Accessory ancestry (instant match for held items)
        if obj:IsA("Tool") or obj:FindFirstAncestorOfClass("Tool")
           or obj:IsA("Accessory") or obj:FindFirstAncestorOfClass("Accessory") then
            return true
        end

        -- 2. Descendant of ANY player's character in the game
        local players = I:GetPlayers()
        for _, plr in ipairs(players) do
            local char = plr.Character
            if char and (obj == char or obj:IsDescendantOf(char)) then
                return true
            end
        end

        -- 3. Any ancestor model with a Humanoid (covers NPC killers or models without player objects)
        local cur = obj.Parent
        while cur and cur ~= workspace and cur ~= game do
            if cur:IsA("Model") and cur:FindFirstChildOfClass("Humanoid") then
                return true
            end
            cur = cur.Parent
        end

        return false
    end

    -- 2. Bear Trap: Model named "BearTrap" placed on the ground/dirt (original name BearTrap, named only Trap)
    local function resolveTrap(obj)
        if not obj or not obj.Parent then return nil, nil end
        if isInsideCharacter(obj) then return nil, nil end

        local rawName = tostring(obj.Name):lower()
        if rawName:find("ghost", 1, true) or rawName:find("preview", 1, true) or rawName:find("template", 1, true) then return nil, nil end
        if obj:FindFirstChildOfClass("Humanoid") then return nil, nil end

        local isTrapName = (rawName == "beartrap" or rawName == "bear trap" or rawName == "bear_trap"
                            or rawName:find("beartrap", 1, true)
                            or rawName:find("bear trap", 1, true)
                            or rawName:find("bear_trap", 1, true)
                            or rawName == "trap"
                            or rawName:find("killertrap", 1, true))

        local trapModel = nil
        if obj:IsA("Model") and isTrapName then
            trapModel = obj
        elseif obj.Parent and obj.Parent:IsA("Model") and (
            obj.Parent.Name:lower():find("beartrap", 1, true)
            or obj.Parent.Name:lower():find("bear trap", 1, true)
            or obj.Parent.Name:lower():find("bear_trap", 1, true)
            or obj.Parent.Name:lower() == "trap"
        ) then
            trapModel = obj.Parent
        elseif obj:IsA("BasePart") and isTrapName and not (obj.Parent and obj.Parent:IsA("Model")) then
            trapModel = obj
        end

        -- Also check for ProximityPrompt with Disarm / Untrap / Trap
        if not trapModel then
            local prompt = obj:IsA("ProximityPrompt") and obj or obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                local pText = (tostring(prompt.ObjectText) .. " " .. tostring(prompt.ActionText) .. " " .. tostring(prompt.Name)):lower()
                if pText:find("disarm", 1, true) or pText:find("untrap", 1, true) or pText:find("trap", 1, true) then
                    local pPart = prompt.Parent
                    if pPart then
                        trapModel = (pPart.Parent and pPart.Parent:IsA("Model") and pPart.Parent ~= workspace) and pPart.Parent or (pPart:IsA("Model") and pPart or pPart)
                    end
                end
            end
        end

        if trapModel then
            if isInsideCharacter(trapModel) then return nil, nil end

            local anchor = nil
            if trapModel:IsA("BasePart") then
                anchor = trapModel
            else
                anchor = trapModel.PrimaryPart
                      or trapModel:FindFirstChild("Main")
                      or trapModel:FindFirstChild("Base")
                      or trapModel:FindFirstChild("Part")
                      or trapModel:FindFirstChild("Hitbox")
                      or trapModel:FindFirstChildWhichIsA("BasePart", true)
            end
            if anchor then
                if isInsideCharacter(anchor) then return nil, nil end
                return trapModel, anchor
            end
        end
        return nil, nil
    end

    -- 3. Pallet: Strictly targets Model "Newpallet" inside "Pallets"
    local function resolvePallet(obj)
        if not obj or not obj.Parent then return nil, nil end
        if lp and lp.Character and obj:IsDescendantOf(lp.Character) then return nil, nil end
        if obj:FindFirstChildOfClass("Humanoid") then return nil, nil end

        local palletModel = nil
        if obj:IsA("Model") and (obj.Name == "Newpallet" or obj.Name:lower() == "newpallet") then
            palletModel = obj
        end
        if not palletModel and obj.Parent and obj.Parent:IsA("Model") and (obj.Parent.Name == "Newpallet" or obj.Parent.Name:lower() == "newpallet") then
            palletModel = obj.Parent
        end
        if not palletModel and obj.Parent and obj.Parent.Name == "Pallets" and obj:IsA("Model") then
            palletModel = obj
        end

        if palletModel then
            local anchor = palletModel.PrimaryPart
                  or palletModel:FindFirstChild("Hinge")
                  or palletModel:FindFirstChild("Main")
                  or palletModel:FindFirstChild("Hitbox")
                  or palletModel:FindFirstChildWhichIsA("BasePart", true)

            if anchor then
                return palletModel, anchor
            end
        end
        return nil, nil
    end

    -- 4. Hook: Strictly targets MeshPart "Hook.001" inside Model "Hook"
    local function resolveHook(obj)
        if not obj or not obj.Parent then return nil, nil end
        if lp and lp.Character and obj:IsDescendantOf(lp.Character) then return nil, nil end
        if obj:IsA("Accessory") or obj:FindFirstChildOfClass("Humanoid") then return nil, nil end

        local hookPart = nil
        if (obj:IsA("BasePart") or obj:IsA("MeshPart")) and obj.Name == "Hook.001" then
            hookPart = obj
        end
        if not hookPart and obj:IsA("Model") and (obj.Name == "Hook" or obj.Name:lower() == "hook") then
            local h = obj:FindFirstChild("Hook.001")
            if h and (h:IsA("BasePart") or h:IsA("MeshPart")) then
                hookPart = h
            end
        end
        if not hookPart and obj.Parent and obj.Parent:IsA("Model") and (obj.Parent.Name == "Hook" or obj.Parent.Name:lower() == "hook") then
            local h = obj.Parent:FindFirstChild("Hook.001")
            if h and (h:IsA("BasePart") or h:IsA("MeshPart")) then
                hookPart = h
            end
        end

        if hookPart then
            return hookPart, hookPart
        end
        return nil, nil
    end

    -- 5. Exit Gate: Model "Gate"
    local function resolveGate(obj)
        if not obj or not obj.Parent then return nil, nil end

        local gateModel = nil
        if obj:IsA("Model") and (obj.Name == "Gate" or obj.Name:lower() == "gate") then
            gateModel = obj
        elseif obj.Parent and obj.Parent:IsA("Model") and (obj.Parent.Name == "Gate" or obj.Parent.Name:lower() == "gate") then
            gateModel = obj.Parent
        end

        if gateModel then
            local anchor = gateModel.PrimaryPart
                        or gateModel:FindFirstChild("ExitLever")
                        or gateModel:FindFirstChildWhichIsA("BasePart", true)
            if anchor and anchor:IsA("Model") then
                anchor = anchor.PrimaryPart or anchor:FindFirstChildWhichIsA("BasePart", true)
            end
            if anchor then
                return gateModel, anchor
            end
        end
        return nil, nil
    end

    local function attachMapDestructionWatcher(root, registry)
        root.AncestryChanged:Connect(function(_, parent)
            if not parent then
                if mapHighlights[root] then pcall(function() mapHighlights[root]:Destroy() end) mapHighlights[root] = nil end
                if selectionBoxes[root] then pcall(function() selectionBoxes[root]:Destroy() end) selectionBoxes[root] = nil end
                if boxAdornments[root] then pcall(function() boxAdornments[root]:Destroy() end) boxAdornments[root] = nil end
                if mapTags[root] then pcall(function() mapTags[root].Gui:Destroy() end) mapTags[root] = nil end
                registry[root] = nil
            end
        end)
    end

    local function registerMapEntity(rawObj)
        if not rawObj or not rawObj.Parent then return end

        -- 1. Window Vault (Bottom part)
        local vaultRoot, vaultAnchor = resolveVault(rawObj)
        if vaultRoot and vaultAnchor then
            if not discoveredVaults[vaultRoot] then
                discoveredVaults[vaultRoot] = vaultAnchor
                attachMapDestructionWatcher(vaultRoot, discoveredVaults)
            end
            return
        end

        -- 2. Exit Gate
        local gateRoot, gateAnchor = resolveGate(rawObj)
        if gateRoot and gateAnchor then
            if not discoveredGates[gateRoot] then
                discoveredGates[gateRoot] = gateAnchor
                attachMapDestructionWatcher(gateRoot, discoveredGates)
            end
            return
        end

        -- 3. Bear Trap (Strictly ignore killer-carried traps; only traps on dirt)
        local trapRoot, trapAnchor = resolveTrap(rawObj)
        if trapRoot and trapAnchor then
            if isInsideCharacter(trapRoot) or isInsideCharacter(trapAnchor) then
                return
            end
            if not discoveredTraps[trapRoot] then
                discoveredTraps[trapRoot] = trapAnchor
                attachMapDestructionWatcher(trapRoot, discoveredTraps)
            end
            return
        end

        -- 4. Pallet (Model: Newpallet)
        local palletRoot, palletAnchor = resolvePallet(rawObj)
        if palletRoot and palletAnchor then
            if not discoveredPallets[palletRoot] then
                discoveredPallets[palletRoot] = palletAnchor
                attachMapDestructionWatcher(palletRoot, discoveredPallets)
            end
            return
        end

        -- 5. Hook (MeshPart: Hook.001)
        local hookRoot, hookAnchor = resolveHook(rawObj)
        if hookRoot and hookAnchor then
            if not discoveredHooks[hookRoot] then
                discoveredHooks[hookRoot] = hookAnchor
                attachMapDestructionWatcher(hookRoot, discoveredHooks)
            end
            return
        end
    end

    -- Targeted Map Entity Scanner (Instant 0.05ms, Zero Network Overhead)
    local hasFoundFullQuota = false
    local function scanMapEntities()
        -- 1. Targeted check in workspace.Map descendants (Where Violence District houses all map models)
        local mapFolder = workspace:FindFirstChild("Map") or workspace:FindFirstChild("map")
        if mapFolder then
            for _, desc in ipairs(mapFolder:GetDescendants()) do
                if desc:IsA("Model") then
                    if isGeneratorModel(desc) then
                        registerGenerator(desc)
                    elseif isPumpkinModel(desc) then
                        registerPumpkin(desc)
                    end
                elseif desc:IsA("BasePart") or desc:IsA("ProximityPrompt") then
                    if isPumpkinModel(desc) then
                        registerPumpkin(desc)
                    elseif desc.Name:lower():find("gen", 1, true) then
                        registerGenerator(desc)
                    end
                end
                registerMapEntity(desc)
            end
        end

        -- 2. Check other common container folders
        for _, name in ipairs({"Generators", "Gens", "Pumpkins", "Pumpkin", "Halloween", "Collectibles", "Spawns", "Interactables", "Items", "Debris"}) do
            local folder = workspace:FindFirstChild(name)
            if folder and folder ~= mapFolder then
                for _, desc in ipairs(folder:GetDescendants()) do
                    if desc:IsA("Model") then
                        if isGeneratorModel(desc) then
                            registerGenerator(desc)
                        elseif isPumpkinModel(desc) then
                            registerPumpkin(desc)
                        end
                    elseif desc:IsA("BasePart") or desc:IsA("ProximityPrompt") then
                        if isPumpkinModel(desc) then
                            registerPumpkin(desc)
                        end
                    end
                end
            end
        end

        -- 3. Check direct workspace children
        for _, child in ipairs(workspace:GetChildren()) do
            if child:IsA("Model") then
                if isGeneratorModel(child) then
                    registerGenerator(child)
                elseif isPumpkinModel(child) then
                    registerPumpkin(child)
                end
            elseif child:IsA("BasePart") and isPumpkinModel(child) then
                registerPumpkin(child)
            end
            registerMapEntity(child)
        end

        -- 4. Scan designated folders for map entities
        for _, name in ipairs({"Pallets", "Pallet", "Hooks", "Hook", "Windows", "Window", "Gates", "Gate", "Traps", "BearTraps", "BearTrap", "Interactables", "Debris"}) do
            local folder = workspace:FindFirstChild(name)
            if folder then
                for _, desc in ipairs(folder:GetDescendants()) do
                    registerMapEntity(desc)
                end
                registerMapEntity(folder)
            end
        end

        -- Count discovered pumpkins
        local pCount = 0
        for _ in pairs(discoveredPumpkins) do pCount = pCount + 1 end
        if pCount >= 7 then
            hasFoundFullQuota = true
        end
    end

    -- Initial round scan (runs immediately and after short delay)
    task.spawn(function()
        task.wait(0.3)
        scanMapEntities()
        for _, p in ipairs(I:GetPlayers()) do
            if p ~= lp then
                pcall(updatePlayerEsp, p)
            end
        end
        task.wait(1.5)
        scanMapEntities()
        if not hasFoundFullQuota then
            task.wait(3.0)
            scanMapEntities()
        end

        -- Smooth segmented sweep across workspace for remaining map entities
        local all = workspace:GetDescendants()
        for i = 1, #all do
            local item = all[i]
            if item and item.Parent then
                registerMapEntity(item)
            end
            if i % 600 == 0 then
                task.wait()
            end
        end
    end)

    -- Clean Player ESP Helper (Removes dead highlights and billboard tags)
    local function cleanPlayerEsp(player)
        if not player then return end
        if playerHighlights[player] then
            pcall(function() playerHighlights[player]:Destroy() end)
            playerHighlights[player] = nil
        end
        local tagData = playerTags[player]
        if tagData then
            if tagData.Gui then
                pcall(function() tagData.Gui:Destroy() end)
            end
            playerTags[player] = nil
        end
    end

    -- Safe ESP ScreenGui Container (Guaranteed Cross-Executor Isolation & Multi-Round Persistence)
    local espScreenGui = nil
    local function getSafeEspHolder()
        if espScreenGui and espScreenGui.Parent and espScreenGui:IsDescendantOf(game) then
            return espScreenGui
        end
        if espScreenGui then
            pcall(function() espScreenGui:Destroy() end)
            espScreenGui = nil
        end

        local holder = nil
        pcall(function()
            local targetParent = as()
            if targetParent and targetParent:IsDescendantOf(game) then
                local sg = targetParent:FindFirstChild("ExeHub_ESP_Holder")
                if not sg or not sg:IsDescendantOf(game) then
                    if sg then pcall(function() sg:Destroy() end) end
                    sg = Instance.new("ScreenGui")
                    sg.Name = "ExeHub_ESP_Holder"
                    sg.ResetOnSpawn = false
                    sg.IgnoreGuiInset = true
                    sg.Parent = targetParent
                end
                holder = sg
            end
        end)
        if not holder or not holder:IsDescendantOf(game) then
            pcall(function()
                local pg = lp and (lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui", 2))
                if pg and pg:IsDescendantOf(game) then
                    local sg = pg:FindFirstChild("ExeHub_ESP_Holder")
                    if not sg or not sg:IsDescendantOf(game) then
                        if sg then pcall(function() sg:Destroy() end) end
                        sg = Instance.new("ScreenGui")
                        sg.Name = "ExeHub_ESP_Holder"
                        sg.ResetOnSpawn = false
                        sg.IgnoreGuiInset = true
                        sg.Parent = pg
                    end
                    holder = sg
                end
            end)
        end
        espScreenGui = holder
        return holder
    end

    -- Create BillboardTag for ESP (Ultra-safe: ScreenGui or direct 3D adorneePart fallback)
    local function createBillboardTag(adorneePart, defaultTitle, defaultColor)
        if not adorneePart or not adorneePart.Parent or not adorneePart:IsDescendantOf(workspace) then return nil end
        local holder = getSafeEspHolder()
        local bg = Instance.new("BillboardGui")
        bg.Name = "ExeHub_Tag"
        bg.Adornee = adorneePart
        bg.Size = UDim2.fromOffset(160, 42)
        bg.StudsOffset = Vector3.new(0, 2.5, 0)
        bg.AlwaysOnTop = true
        bg.ResetOnSpawn = false
        bg.Enabled = true

        local tl = Instance.new("TextLabel")
        tl.Name = "Title"
        tl.Size = UDim2.new(1, 0, 0, 18)
        tl.Position = UDim2.fromOffset(0, 0)
        tl.BackgroundTransparency = 1
        tl.Text = defaultTitle or ""
        tl.TextColor3 = defaultColor or Color3.new(1, 1, 1)
        tl.TextSize = 13
        tl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
        tl.TextStrokeColor3 = Color3.new(0, 0, 0)
        tl.TextStrokeTransparency = 0.2
        tl.Parent = bg

        local sl = Instance.new("TextLabel")
        sl.Name = "Sub"
        sl.Size = UDim2.new(1, 0, 0, 14)
        sl.Position = UDim2.fromOffset(0, 18)
        sl.BackgroundTransparency = 1
        sl.Text = ""
        sl.TextColor3 = Color3.fromRGB(220, 220, 220)
        sl.TextSize = 11
        sl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
        sl.TextStrokeColor3 = Color3.new(0, 0, 0)
        sl.TextStrokeTransparency = 0.2
        sl.Parent = bg

        local parentOk = false
        if holder and holder:IsDescendantOf(game) then
            parentOk = pcall(function() bg.Parent = holder end)
        end
        if not parentOk or not bg.Parent or not bg:IsDescendantOf(game) then
            pcall(function() bg.Parent = adorneePart end)
        end

        return { Gui = bg, Title = tl, Sub = sl }
    end

    local function updatePlayerEsp(player)
        if not player or player == lp then return end
        local char = player.Character
        if not char or not char.Parent or not char:IsDescendantOf(workspace) then
            cleanPlayerEsp(player)
            return
        end

        local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char.PrimaryPart or char:FindFirstChildWhichIsA("BasePart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or (hum and hum.Health <= 0) then
            cleanPlayerEsp(player)
            return
        end

        local killer = isPlayerKiller(player)
        local isEnabled = killer and espConfig.KillerESP or ((not killer) and espConfig.SurvivorESP)
        local espColor = killer and espConfig.KillerColor or espConfig.SurvivorColor
        local showInfo = killer and espConfig.KillerInfo or espConfig.SurvivorInfo

        -- Highlight update (strictly re-anchors to current character across all rounds)
        local hl = playerHighlights[player]
        if isEnabled then
            if not hl or not hl.Parent or hl.Parent ~= char or hl.Adornee ~= char or not hl:IsDescendantOf(workspace) then
                if hl then
                    pcall(function() hl:Destroy() end)
                end
                pcall(function()
                    local newHl = Instance.new("Highlight")
                    newHl.Name = "ExeHub_HL"
                    newHl.Adornee = char
                    newHl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    newHl.Parent = char
                    hl = newHl
                    playerHighlights[player] = newHl
                end)
            end
            if hl and hl.Parent == char then
                pcall(function()
                    hl.Enabled = true
                    hl.FillColor = espColor
                    hl.OutlineColor = Color3.new(1, 1, 1)
                    hl.FillTransparency = espConfig.FillTransparency
                    hl.OutlineTransparency = espConfig.OutlineTransparency
                end)
            end
        else
            if hl then
                pcall(function() hl.Enabled = false end)
            end
        end

        local showName = killer and espConfig.KillerName or espConfig.SurvivorName
        local showStuds = killer and espConfig.KillerStuds or espConfig.SurvivorStuds

        -- Billboard Tag update (strictly re-anchors to current character root across all rounds)
        local tagData = playerTags[player]
        if isEnabled and (showName or showStuds) then
            if not tagData or not tagData.Gui or not tagData.Gui.Parent or tagData.Gui.Adornee ~= root or not tagData.Gui:IsDescendantOf(game) then
                if tagData and tagData.Gui then
                    pcall(function() tagData.Gui:Destroy() end)
                end
                local defaultName = player.DisplayName or player.Name
                tagData = createBillboardTag(root, defaultName, espColor)
                playerTags[player] = tagData
            end
            if tagData and tagData.Gui and tagData.Gui.Parent then
                pcall(function()
                    tagData.Gui.Adornee = root
                    tagData.Gui.Enabled = true
                    tagData.Title.TextColor3 = espColor

                    if showName then
                        tagData.Title.Text = string.format("%s%s", player.DisplayName, killer and " [KILLER]" or "")
                    else
                        tagData.Title.Text = ""
                    end

                    if showStuds then
                        local myCam = workspace.CurrentCamera or camera
                        local myPos = (myCam and myCam.CFrame.Position) or (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp.Character.HumanoidRootPart.Position)
                        if myPos and root then
                            local dist = math.floor((root.Position - myPos).Magnitude)
                            tagData.Sub.Text = string.format("[%d studs]", dist)
                        end
                    else
                        tagData.Sub.Text = ""
                    end
                end)
            end
        else
            if tagData and tagData.Gui then
                pcall(function() tagData.Gui.Enabled = false end)
            end
        end
    end

    local function updateGeneratorEsp(obj, part)
        if not obj or not obj.Parent or not part or not part.Parent then
            if genHighlights[obj] then
                pcall(function() genHighlights[obj]:Destroy() end)
                genHighlights[obj] = nil
            end
            if genTags[obj] then
                pcall(function() genTags[obj].Gui:Destroy() end)
                genTags[obj] = nil
            end
            discoveredGens[obj] = nil
            return
        end

        local isEnabled = espConfig.GeneratorESP
        local espColor = espConfig.GeneratorColor

        local isCompleted = isGeneratorCompleted(obj)
        if isCompleted and espConfig.HideCompleted then
            if genHighlights[obj] then genHighlights[obj].Enabled = false end
            if genTags[obj] and genTags[obj].Gui then genTags[obj].Gui.Enabled = false end
            return
        end

        local hl = genHighlights[obj]
        if isEnabled then
            if not hl or not hl.Parent then
                hl = Instance.new("Highlight")
                hl.Name = "ExeHub_HL"
                hl.Adornee = obj
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = obj
                genHighlights[obj] = hl
            end
            hl.Enabled = true
            hl.FillColor = espColor
            hl.OutlineColor = Color3.new(1, 1, 1)
            hl.FillTransparency = espConfig.FillTransparency
            hl.OutlineTransparency = espConfig.OutlineTransparency
        else
            if hl then hl.Enabled = false end
        end

        local tagData = genTags[obj]
        local showName = espConfig.GenName
        local showStuds = espConfig.GenDistance
        local showProgress = espConfig.GenProgress

        if isEnabled and (showName or showStuds or showProgress) then
            if not tagData or not tagData.Gui or not tagData.Gui.Parent then
                tagData = createBillboardTag(part, "Generator", espColor)
                genTags[obj] = tagData
            end
            if tagData and tagData.Gui then
                tagData.Gui.Enabled = true
                tagData.Title.TextColor3 = espColor

                local prog = getGenProgress(obj)
                local titleText = ""
                if showName and showProgress and prog then
                    titleText = string.format("Generator (%d%%)", prog)
                elseif showName then
                    titleText = "Generator"
                elseif showProgress and prog then
                    titleText = string.format("(%d%%)", prog)
                end
                tagData.Title.Text = titleText

                if showStuds then
                    local myCam = workspace.CurrentCamera or camera
                    local myPos = (myCam and myCam.CFrame.Position) or (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp.Character.HumanoidRootPart.Position)
                    if myPos and part then
                        local dist = math.floor((part.Position - myPos).Magnitude)
                        tagData.Sub.Text = string.format("[%d studs]", dist)
                    end
                else
                    tagData.Sub.Text = ""
                end
            end
        else
            if tagData and tagData.Gui then tagData.Gui.Enabled = false end
        end
    end

    local function updatePumpkinEsp(obj, part, myPos)
        if not obj or not obj.Parent or not part or not part.Parent then
            removePumpkin(obj)
            return
        end

        local isEnabled = espConfig.PumpkinESP
        local espColor = espConfig.PumpkinColor

        local hl = pumpkinHighlights[obj]
        if isEnabled then
            if not hl or not hl.Parent then
                local targetHlParent = (obj:IsA("Model") and obj) or part
                hl = Instance.new("Highlight")
                hl.Name = "ExeHub_PumpkinHL"
                hl.Adornee = targetHlParent
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillColor = espColor
                hl.OutlineColor = Color3.new(1, 1, 1)
                hl.FillTransparency = espConfig.FillTransparency
                hl.OutlineTransparency = espConfig.OutlineTransparency
                hl.Parent = targetHlParent
                pumpkinHighlights[obj] = hl
            else
                if not hl.Enabled then hl.Enabled = true end
                hl.FillColor = espColor
            end
        else
            if hl and hl.Enabled then hl.Enabled = false end
        end

        local tagData = pumpkinTags[obj]
        local showName = espConfig.PumpkinName
        local showStuds = espConfig.PumpkinDistance

        if isEnabled and (showName or showStuds) then
            if not tagData or not tagData.Gui or not tagData.Gui.Parent then
                tagData = createBillboardTag(part, "Pumpkin", espColor)
                pumpkinTags[obj] = tagData
            end
            if tagData and tagData.Gui then
                if not tagData.Gui.Enabled then tagData.Gui.Enabled = true end
                tagData.Title.TextColor3 = espColor
                tagData.Title.Text = showName and "Pumpkin" or ""

                if showStuds and myPos and part then
                    local dist = math.floor((part.Position - myPos).Magnitude)
                    tagData.Sub.Text = string.format("[%d studs]", dist)
                else
                    tagData.Sub.Text = ""
                end
            end
        else
            if tagData and tagData.Gui and tagData.Gui.Enabled then tagData.Gui.Enabled = false end
        end
    end

    local function renderMapGroup(registry, isEnabled, maxDist, labelText, color, showName, showStuds, myPos, useBox)
        if not isEnabled then
            for root in pairs(registry) do
                if mapHighlights[root] then mapHighlights[root].Enabled = false end
                if selectionBoxes[root] then selectionBoxes[root].Visible = false end
                if boxAdornments[root] then boxAdornments[root].Visible = false end
                if mapTags[root] and mapTags[root].Gui then mapTags[root].Gui.Enabled = false end
            end
            return
        end

        for root, anchor in pairs(registry) do
            if not root or not root.Parent or not anchor or not anchor.Parent then
                if mapHighlights[root] then pcall(function() mapHighlights[root]:Destroy() end) mapHighlights[root] = nil end
                if selectionBoxes[root] then pcall(function() selectionBoxes[root]:Destroy() end) selectionBoxes[root] = nil end
                if boxAdornments[root] then pcall(function() boxAdornments[root]:Destroy() end) boxAdornments[root] = nil end
                if mapTags[root] then pcall(function() mapTags[root].Gui:Destroy() end) mapTags[root] = nil end
                registry[root] = nil
            elseif labelText == "TRAP" and (isInsideCharacter(root) or isInsideCharacter(anchor)) then
                -- Dynamically suppress ESP while held/equipped by killer
                if mapHighlights[root] then mapHighlights[root].Enabled = false end
                if selectionBoxes[root] then selectionBoxes[root].Visible = false end
                if boxAdornments[root] then boxAdornments[root].Visible = false end
                if mapTags[root] and mapTags[root].Gui then mapTags[root].Gui.Enabled = false end
            else
                local dist = myPos and (anchor.Position - myPos).Magnitude or 0
                if dist <= maxDist then
                    -- 1. Slim-fit 3D Box (Exclusive for Window Bottom / Vault)
                    if useBox then
                        local holder = getSafeEspHolder()
                        local sbox = selectionBoxes[root]
                        if not sbox or not sbox.Parent then
                            sbox = Instance.new("SelectionBox")
                            sbox.Name = "Vault_SelectionBox"
                            sbox.Adornee = anchor
                            sbox.Color3 = color
                            sbox.LineThickness = 0.02
                            sbox.SurfaceTransparency = 1
                            sbox.Parent = holder or anchor
                            selectionBoxes[root] = sbox
                        else
                            sbox.Color3 = color
                        end
                        sbox.Visible = true

                        local bbox = boxAdornments[root]
                        if not bbox or not bbox.Parent then
                            bbox = Instance.new("BoxHandleAdornment")
                            bbox.Name = "Vault_BoxFill"
                            bbox.Adornee = anchor
                            bbox.Size = anchor:IsA("BasePart") and anchor.Size or Vector3.new(3, 1, 0.5)
                            bbox.Color3 = color
                            bbox.Transparency = espConfig.BoxTransparency or 0.65
                            bbox.AlwaysOnTop = true
                            bbox.ZIndex = 5
                            bbox.Parent = holder or anchor
                            boxAdornments[root] = bbox
                        else
                            bbox.Color3 = color
                            bbox.Transparency = espConfig.BoxTransparency or 0.65
                            if anchor:IsA("BasePart") then bbox.Size = anchor.Size end
                        end
                        bbox.Visible = true

                        if mapHighlights[root] then mapHighlights[root].Enabled = false end
                    else
                        if selectionBoxes[root] then selectionBoxes[root].Visible = false end
                        if boxAdornments[root] then boxAdornments[root].Visible = false end

                        -- Standard Clean Highlight ESP (Trap, Pallet, Hook, Gate, or non-box Vault)
                        local hl = mapHighlights[root]
                        if not hl or not hl.Parent then
                            local holder = getSafeEspHolder()
                            hl = Instance.new("Highlight")
                            hl.Name = "ExeHub_MapHL"
                            hl.Adornee = root
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.FillColor = color
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = espConfig.FillTransparency
                            hl.OutlineTransparency = espConfig.OutlineTransparency
                            hl.Parent = holder or root
                            mapHighlights[root] = hl
                        else
                            hl.FillColor = color
                            hl.FillTransparency = espConfig.FillTransparency
                            hl.OutlineTransparency = espConfig.OutlineTransparency
                        end
                        hl.Enabled = true
                    end

                    -- 2. Clean Text Billboard Tag (NO EMOJIS)
                    local tag = mapTags[root]
                    if showName or showStuds then
                        if not tag or not tag.Gui or not tag.Gui.Parent then
                            tag = createBillboardTag(anchor, labelText, color)
                            mapTags[root] = tag
                        end
                        if tag and tag.Gui then
                            tag.Gui.Enabled = true
                            tag.Title.TextColor3 = color
                            tag.Title.Text = showName and labelText or ""
                            tag.Sub.Text = showStuds and string.format("[%d studs]", math.floor(dist)) or ""
                        end
                    else
                        if tag and tag.Gui then tag.Gui.Enabled = false end
                    end
                else
                    if mapHighlights[root] then mapHighlights[root].Enabled = false end
                    if selectionBoxes[root] then selectionBoxes[root].Visible = false end
                    if boxAdornments[root] then boxAdornments[root].Visible = false end
                    if mapTags[root] and mapTags[root].Gui then mapTags[root].Gui.Enabled = false end
                end
            end
        end
    end

    -- Hook dynamic map entity spawning (instant zero-lag filtering)
    local wConn = workspace.DescendantAdded:Connect(function(desc)
        pcall(registerMapEntity, desc)
        if not desc:IsA("Model") and not desc:IsA("BasePart") and not desc:IsA("ProximityPrompt") then
            return
        end
        local name = desc.Name:lower()
        if name:find("gen", 1, true) or name:find("motor", 1, true) then
            task.delay(0.2, function()
                pcall(registerGenerator, desc)
            end)
        elseif name:find("pump", 1, true) or name:find("jack", 1, true) or name:find("candy", 1, true) or name:find("treat", 1, true) then
            task.delay(0.1, function()
                pcall(registerPumpkin, desc)
            end)
        elseif desc:IsA("ProximityPrompt") then
            local pText = (tostring(desc.ObjectText) .. " " .. tostring(desc.ActionText) .. " " .. tostring(desc.Name)):lower()
            if pText:find("pump", 1, true) or pText:find("candy", 1, true) or pText:find("treat", 1, true) then
                task.delay(0.1, function()
                    local pPart = desc.Parent
                    if pPart and pPart:IsA("BasePart") then
                        local owner = (pPart.Parent and pPart.Parent:IsA("Model") and pPart.Parent ~= workspace) and pPart.Parent or pPart
                        pcall(registerPumpkin, owner)
                    end
                end)
            elseif pText:find("gen", 1, true) or pText:find("repair", 1, true) or pText:find("fix", 1, true) then
                task.delay(0.2, function()
                    local pPart = desc.Parent
                    if pPart then
                        local root = getRootGenerator(pPart)
                        if root then pcall(registerGenerator, root) end
                    end
                end)
            end
        end
    end)
    table.insert(espConnections, wConn)

    -- Hook player characters with multi-round lifecycle tracking
    local function hookPlayer(p)
        if not p or p == lp then return end
        local cConn = p.CharacterAdded:Connect(function(newChar)
            cleanPlayerEsp(p)
            task.delay(0.1, function() pcall(updatePlayerEsp, p) end)
            task.delay(0.5, function() pcall(updatePlayerEsp, p) end)
            task.delay(1.5, function() pcall(updatePlayerEsp, p) end)
        end)
        table.insert(espConnections, cConn)

        local rConn = p.CharacterRemoving:Connect(function()
            cleanPlayerEsp(p)
        end)
        table.insert(espConnections, rConn)
    end

    for _, p in ipairs(I:GetPlayers()) do
        hookPlayer(p)
    end
    local pAddedConn = I.PlayerAdded:Connect(function(p)
        hookPlayer(p)
    end)
    table.insert(espConnections, pAddedConn)

    local pRemovedConn = I.PlayerRemoving:Connect(function(p)
        cleanPlayerEsp(p)
    end)
    table.insert(espConnections, pRemovedConn)

    -- Handle LocalPlayer round respawn / new game round
    local lpCharConn = lp.CharacterAdded:Connect(function()
        task.delay(0.2, function()
            pcall(enforceOptimizations)
            pcall(ensureCameraFullBright)
        end)
        task.delay(1.5, function()
            pcall(enforceOptimizations)
            pcall(ensureCameraFullBright)
            -- Clean up old dead references from previous round
            for obj in pairs(discoveredPumpkins) do
                removePumpkin(obj)
            end
            for obj in pairs(discoveredGens) do
                if not obj.Parent then
                    if genHighlights[obj] then pcall(function() genHighlights[obj]:Destroy() end) genHighlights[obj] = nil end
                    if genTags[obj] then pcall(function() genTags[obj].Gui:Destroy() end) genTags[obj] = nil end
                    discoveredGens[obj] = nil
                end
            end
            for obj in pairs(discoveredVaults) do
                if not obj.Parent then
                    if selectionBoxes[obj] then pcall(function() selectionBoxes[obj]:Destroy() end) selectionBoxes[obj] = nil end
                    if boxAdornments[obj] then pcall(function() boxAdornments[obj]:Destroy() end) boxAdornments[obj] = nil end
                    if mapTags[obj] then pcall(function() mapTags[obj].Gui:Destroy() end) mapTags[obj] = nil end
                    discoveredVaults[obj] = nil
                end
            end
            for obj in pairs(discoveredTraps) do
                if not obj.Parent then
                    if mapHighlights[obj] then pcall(function() mapHighlights[obj]:Destroy() end) mapHighlights[obj] = nil end
                    if mapTags[obj] then pcall(function() mapTags[obj].Gui:Destroy() end) mapTags[obj] = nil end
                    discoveredTraps[obj] = nil
                end
            end
            for obj in pairs(discoveredPallets) do
                if not obj.Parent then
                    if mapHighlights[obj] then pcall(function() mapHighlights[obj]:Destroy() end) mapHighlights[obj] = nil end
                    if mapTags[obj] then pcall(function() mapTags[obj].Gui:Destroy() end) mapTags[obj] = nil end
                    discoveredPallets[obj] = nil
                end
            end
            for obj in pairs(discoveredHooks) do
                if not obj.Parent then
                    if mapHighlights[obj] then pcall(function() mapHighlights[obj]:Destroy() end) mapHighlights[obj] = nil end
                    if mapTags[obj] then pcall(function() mapTags[obj].Gui:Destroy() end) mapTags[obj] = nil end
                    discoveredHooks[obj] = nil
                end
            end
            for obj in pairs(discoveredGates) do
                if not obj.Parent then
                    if mapHighlights[obj] then pcall(function() mapHighlights[obj]:Destroy() end) mapHighlights[obj] = nil end
                    if mapTags[obj] then pcall(function() mapTags[obj].Gui:Destroy() end) mapTags[obj] = nil end
                    discoveredGates[obj] = nil
                end
            end
            -- Clean up & re-anchor all players across match change
            for _, p in ipairs(I:GetPlayers()) do
                if p ~= lp then
                    cleanPlayerEsp(p)
                    pcall(updatePlayerEsp, p)
                end
            end
            -- Scan new round's entities (7-10 pumpkins & generators)
            scanMapEntities()
        end)
    end)
    table.insert(espConnections, lpCharConn)

    -- Ultra-smooth 60FPS Heartbeat update throttled to 10Hz (ZERO periodic scan lag)
    local lastTextUpdate = 0
    local espLoopConn = game:GetService("RunService").Heartbeat:Connect(function()
        local now = os.clock()
        if now - lastTextUpdate < 0.1 then return end
        lastTextUpdate = now

        -- Guarantee camera light persistence across round/camera resets
        if optimizeConfig.FullBright then
            pcall(ensureCameraFullBright)
        end

        -- Update players at 10Hz
        for _, p in ipairs(I:GetPlayers()) do
            if p ~= lp then
                pcall(updatePlayerEsp, p)
            end
        end

        -- Update generators at 10Hz
        if espConfig.GeneratorESP then
            for genObj, genPart in pairs(discoveredGens) do
                pcall(updateGeneratorEsp, genObj, genPart)
            end
        end

        -- Update pumpkins at 10Hz with cached camera position
        local myCam = workspace.CurrentCamera or camera
        local myPos = (myCam and myCam.CFrame.Position) or (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp.Character.HumanoidRootPart.Position)
        if espConfig.PumpkinESP then
            for pObj, pPart in pairs(discoveredPumpkins) do
                pcall(updatePumpkinEsp, pObj, pPart, myPos)
            end
        end

        -- Update Map Entities at 10Hz (Vaults, Traps, Pallets, Hooks, Gates)
        pcall(renderMapGroup, discoveredVaults,  espConfig.VaultESP,  espConfig.MaxDistance, "VAULT",       espConfig.VaultColor,  espConfig.VaultName,   espConfig.VaultStuds,  myPos, espConfig.VaultBox)
        pcall(renderMapGroup, discoveredTraps,   espConfig.TrapESP,   espConfig.MaxDistance, "TRAP",        espConfig.TrapColor,   espConfig.TrapName,    espConfig.TrapStuds,   myPos, false)
        pcall(renderMapGroup, discoveredPallets, espConfig.PalletESP, espConfig.MaxDistance, "PALLET",      espConfig.PalletColor, espConfig.PalletName,  espConfig.PalletStuds, myPos, false)
        pcall(renderMapGroup, discoveredHooks,   espConfig.HookESP,   espConfig.MaxDistance, "HOOK",        espConfig.HookColor,   espConfig.HookName,    espConfig.HookStuds,   myPos, false)
        pcall(renderMapGroup, discoveredGates,   espConfig.GateESP,   espConfig.MaxDistance, "EXIT GATE",   espConfig.GateColor,   espConfig.GateName,    espConfig.GateStuds,   myPos, false)
    end)
    table.insert(espConnections, espLoopConn)

    -- ==================================================================
    -- AUTO PERFECT SKILL CHECK ENGINE (VIOLENCE DISTRICT)
    -- ==================================================================
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local GuiService = game:GetService("GuiService")
    local touchID = 8822
    local isProcessingSkillHit = false
    local lastSkillHitTime = 0

    local function findMobileActionCheck()
        local pg = lp and lp:FindFirstChild("PlayerGui")
        if not pg then return nil end
        local mob = pg:FindFirstChild("Survivor-mob")
        if mob and mob:FindFirstChild("Controls") then
            local action = mob.Controls:FindFirstChild("action")
            if action and action:FindFirstChild("check") then
                return action.check
            end
        end
        return nil
    end

    local function triggerSkillCheckInput()
        local triggered = false

        -- 1. Mobile touch emulation if on mobile or mobile controls active
        if autoConfig.SupportMobileTouch then
            local mobCheck = findMobileActionCheck()
            if mobCheck and mobCheck:IsA("GuiObject") and mobCheck.Visible then
                task.spawn(function()
                    pcall(function()
                        local pos = mobCheck.AbsolutePosition
                        local size = mobCheck.AbsoluteSize
                        local inset = GuiService:GetGuiInset()
                        local cx = pos.X + (size.X / 2) + inset.X
                        local cy = pos.Y + (size.Y / 2) + inset.Y
                        VirtualInputManager:SendTouchEvent(touchID, 0, cx, cy)
                        task.wait(0.025)
                        VirtualInputManager:SendTouchEvent(touchID, 2, cx, cy)
                    end)
                end)
                triggered = true
            end
        end

        -- 2. PC Spacebar Key Event via VirtualInputManager
        if not triggered then
            task.spawn(function()
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.025)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                end)
            end)
            triggered = true
        end

        -- 3. Executor keypress / keyrelease fallback
        if not triggered then
            task.spawn(function()
                pcall(function()
                    if typeof(keypress) == "function" and typeof(keyrelease) == "function" then
                        keypress(0x20)
                        task.wait(0.025)
                        keyrelease(0x20)
                    end
                end)
            end)
        end
    end

    local function getSkillCheckPrompt()
        local pg = lp and lp:FindFirstChild("PlayerGui")
        if not pg then return nil end

        -- Standard Violence District Prompt
        local prompt = pg:FindFirstChild("SkillCheckPromptGui")
        if prompt and prompt:FindFirstChild("Check") then
            return prompt
        end

        -- Dynamic search across PlayerGui for active skill checks
        for _, gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name:find("SkillCheck") or gui.Name:find("Prompt") or gui.Name:find("QTE")) then
                if gui:FindFirstChild("Check") then
                    return gui
                end
            end
        end
        return nil
    end

    -- Calibrated hit boundary resolver for Generators & Killer Trap Freeing
    local function getHitBoundaries(check, lr)
        -- 1. Trap Freeing: Check.TrapGoal exists and is visible
        local trapGoal = check:FindFirstChild("TrapGoal")
        if trapGoal and trapGoal.Visible then
            local tgr = (trapGoal.Rotation or 0) % 360

            -- Special case: Initial spawn before TrapGoal begins dynamic rotation
            if tgr == 0 and (lr > 260 and lr < 290) then
                return 272.0, 286.0, 279.0, "Trap Freeing (Initial)"
            end

            -- Calibrated ground-truth offset: [TrapGoal + 108°, TrapGoal + 130°]
            -- Perfect center sits at TrapGoal + 119.0°
            local ss = (tgr + 108.0) % 360
            local se = (tgr + 130.0) % 360
            local center = (tgr + 119.0) % 360
            return ss, se, center, "Trap Freeing"
        end

        -- 2. Trap Freeing fallback: Check.TrapPerfect exists without TrapGoal
        local trapPerfect = check:FindFirstChild("TrapPerfect")
        if trapPerfect and trapPerfect.Visible and not (check:FindFirstChild("Goal") and check.Goal.Visible) then
            return 272.0, 286.0, 279.0, "Trap Freeing (Static)"
        end

        -- 3. Standard Generator: Check.Goal ([+104°, +114°] represents the Perfect hit segment)
        local goal = check:FindFirstChild("Goal")
        if goal and goal.Visible then
            local gr = (goal.Rotation or 0) % 360
            local startOffset = 104
            local endOffset = 114
            if autoConfig.SkillCheckMode == "Great" then
                startOffset = 100
                endOffset = 118
            elseif autoConfig.SkillCheckMode == "Safe" then
                startOffset = 96
                endOffset = 122
            end
            local ss = (gr + startOffset) % 360
            local se = (gr + endOffset) % 360
            local center = (gr + 109.0) % 360
            return ss, se, center, "Generator"
        end

        return nil, nil, nil, nil
    end

    local skillCheckConn = game:GetService("RunService").Heartbeat:Connect(function()
        if not autoConfig.PerfectSkillCheck then return end

        local prompt = getSkillCheckPrompt()
        if not prompt then
            isProcessingSkillHit = false
            return
        end

        local check = prompt:FindFirstChild("Check")
        if not check or not check.Visible or not check.Parent then
            isProcessingSkillHit = false
            return
        end

        local line = check:FindFirstChild("Line")
        if not line or not line.Visible then
            isProcessingSkillHit = false
            return
        end

        local lr = (line.Rotation or 0) % 360
        local ss, se, center, hitType = getHitBoundaries(check, lr)
        if not ss or not se then
            isProcessingSkillHit = false
            return
        end

        local isInZone = (ss > se and (lr >= ss or lr <= se)) or (lr >= ss and lr <= se)

        if not isInZone and isProcessingSkillHit then
            if os.clock() - lastSkillHitTime > 0.12 then
                isProcessingSkillHit = false
            end
        end

        if isInZone and not isProcessingSkillHit then
            isProcessingSkillHit = true
            lastSkillHitTime = os.clock()

            local delayMs = tonumber(autoConfig.SkillCheckDelay) or 0
            if delayMs > 0 then
                task.delay(delayMs / 1000, function()
                    triggerSkillCheckInput()
                end)
            else
                triggerSkillCheckInput()
            end

            pcall(function()
                if autoStatusLabel then
                    autoStatusLabel:Set("Hit Triggered: " .. tostring(hitType) .. " (Perfect)")
                end
            end)

            task.delay(0.12, function()
                isProcessingSkillHit = false
                pcall(function()
                    if autoStatusLabel then
                        autoStatusLabel:Set("Skill Check Engine: Active • Ready for generators & traps...")
                    end
                end)
            end)
        end
    end)
    table.insert(espConnections, skillCheckConn)

    -- Restore saved client configuration from disk
    pcall(function()
        if Window and typeof(Window.LoadConfig) == "function" then
            Window:LoadConfig()
        end
        if Window then
            Window._autoSaveReady = true
        end
    end)

    -- Select the Profile Tab by default
    ProfileTab:Select()

    -- Instant visibility guarantee
    task.defer(function()
        pcall(function()
            if Window.Root then
                Window.Root.Visible = true
            end
            if Window.Body then
                Window.Body.GroupTransparency = 0
            end
            if Window.Scale then
                Window.Scale.Scale = Window._fitScale or 1
            end
        end)
    end)

    -- Cleanup hook for Window unload or re-execution
    table.insert(activeCleanupTasks, function()
        for _, conn in ipairs(espConnections) do
            pcall(function() conn:Disconnect() end)
        end
        table.clear(espConnections)
        for _, conn in ipairs(optimizeConnections) do
            pcall(function() conn:Disconnect() end)
        end
        table.clear(optimizeConnections)
        if fullBrightLight then pcall(function() fullBrightLight:Destroy() end) end
            pcall(function()
                applyFullBright(false)
                applyNoFog(false)
                applyFpsBoost(false)
            end)
            pcall(function()
                if workspace.CurrentCamera and playerConfig and playerConfig.DefaultFov then
                    workspace.CurrentCamera.FieldOfView = playerConfig.DefaultFov or 70
                end
            end)

        for _, hl in pairs(playerHighlights) do
            pcall(function() hl:Destroy() end)
        end
        table.clear(playerHighlights)

        for _, tag in pairs(playerTags) do
            pcall(function() tag.Gui:Destroy() end)
        end
        table.clear(playerTags)

        for _, hl in pairs(genHighlights) do
            pcall(function() hl:Destroy() end)
        end
        table.clear(genHighlights)

        for _, tag in pairs(genTags) do
            pcall(function() tag.Gui:Destroy() end)
        end
        table.clear(genTags)

        for _, hl in pairs(pumpkinHighlights) do
            pcall(function() hl:Destroy() end)
        end
        table.clear(pumpkinHighlights)

        for _, tag in pairs(pumpkinTags) do
            pcall(function() tag.Gui:Destroy() end)
        end
        table.clear(pumpkinTags)

        for _, hl in pairs(mapHighlights) do
            pcall(function() hl:Destroy() end)
        end
        table.clear(mapHighlights)

        for _, sbox in pairs(selectionBoxes) do
            pcall(function() sbox:Destroy() end)
        end
        table.clear(selectionBoxes)

        for _, bbox in pairs(boxAdornments) do
            pcall(function() bbox:Destroy() end)
        end
        table.clear(boxAdornments)

        for _, tag in pairs(mapTags) do
            pcall(function() tag.Gui:Destroy() end)
        end
        table.clear(mapTags)



        if espScreenGui and espScreenGui.Parent then
            pcall(function() espScreenGui:Destroy() end)
        end

        pcall(function()
            if Window and typeof(Window.SaveConfig) == "function" then
                Window:SaveConfig()
            end
        end)
        if Window and not Window._destroyed then
            Window:Destroy()
        end
    end)

    e:Notify({
        Title = "EXE HUB Loaded",
        Content = "Profile & Visual Engine ready for " .. displayName,
        Duration = 3
    })

    return Window
end

task.spawn(function()
    if typeof(getgenv) == "function" then
        getgenv()._EXEHUB_LIBRARY_ONLY = nil
    end
    local ok, err = pcall(_InitExeHubUI)
    if not ok and err then
        warn("[EXE HUB Init Error]:", tostring(err))
    end
end)

return e
