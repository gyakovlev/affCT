local addon, namespace = ...

namespace[1] = {} -- F, lib
namespace[2] = {} -- C, config
namespace[3] = {} -- L, local

local F, C, L = unpack(select(2, ...))

--F.noop = function() end -- just in case
F.frames = {} -- will contain fames created by mkframe()

C.media = {	font = [[Interface\Addons\AffCT\HOOGE.TTF]],
						fontsize = 16,
						fontstyle = "OUTLINE",
						justify = "CENTER"
					}

-- there are must always be a default config
C.all = {	timevisible = 3,
					fadeduration = 0.5,
					maxlines = 32,
					spacing = 2,
					insertmode = "BOTTOM"
				}


C.cfg = {} -- this table will contain per-frame config values.

C.cfg.ctf = {	name = "CombatTextFrame",
							justify = "CENTER",
							insertmode = "BOTTOM",
							width = 512,
							height = 128,
							x = 0,
							y = 256
						}

C.cfg.idf = {	name = "IncomingDamageFrame",

							justify="LEFT",
							insertmode = "BOTTOM",
							fontsize = 8,
							width = 128,
							height = 128,
							x = 128,
							y = 64,
							spacing = 1,
							timevisible = 1,
						}

C.cfg.ihf = {	name="IncomingHealingFrame",
							justify = "RIGHT",
							insertmode="BOTTOM",
					 		spacing=1,
					 		height=128,
					 		fontsize=8,
					 		width=128,
							x = -128,
							y = 64,
							timevisible = 1,
							fadeduration = 0.3,
							shakecrit = true
				 		}



F.mkframe = function(cfg, anchor, x, y)
	local f=CreateFrame("ScrollingMessageFrame","affCT"..cfg.name,UIParent)
	f:SetFont(cfg.font and cfg.font or C.media.font,
						cfg.fontsize and cfg.fontsize or C.media.fontsize,
						cfg.fontstyle and cfg.fontstyle or C.media.fontstyle)
	f:SetShadowColor(0,0,0,0)
	f:SetFading(true)
	f:SetFadeDuration(cfg.fadeduration and cfg.fadeduration or C.all.fadeduration)
	f:SetTimeVisible(cfg.timevisible and cfg.timevisible or C.all.timevisible)
	f:SetInsertMode(cfg.insertmode and cfg.insertmode or C.all.insertmode)
	f:SetSpacing(cfg.spacing and cfg.spacing or C.all.spacing)
	f:SetWidth(cfg.width)
	f:SetHeight(cfg.height)
	f:SetMaxLines(cfg.height / C.media.fontsize)
	f:SetMovable(true)
	f:SetResizable(true)
	f:SetMinResize(64,64)
	f:SetMaxResize(768,768)
	f:SetClampedToScreen(true)
	f:SetClampRectInsets(0,0,C.media.fontsize,0)
	f:SetJustifyH(cfg.justify and cfg.justify or C.all.justify)
	f:SetPoint(anchor, x and x or cfg.x, y and y or cfg.y)
	tinsert(f,F.frames)

	if cfg.shakecrit then
			local fc=CreateFrame("ScrollingMessageFrame","affCTIncomingHealingFrameCrit",UIParent)
			fc:SetFont(cfg.font and cfg.font or C.media.font,
								cfg.fontsize and cfg.fontsize * 2 or C.media.fontsize * 2,
								cfg.fontstyle and cfg.fontstyle or C.media.fontstyle)
			fc:SetShadowColor(0,0,0,0)
			fc:SetFading(true)
			fc:SetFadeDuration(cfg.fadeduration and cfg.fadeduration or C.all.fadeduration)
			fc:SetTimeVisible(cfg.timevisible and cfg.timevisible or C.all.timevisible)
			fc:SetInsertMode(cfg.insertmode and cfg.insertmode or C.all.insertmode)
			fc:SetSpacing(cfg.spacing and cfg.spacing or C.all.spacing)
			fc:SetWidth(cfg.width)
			fc:SetHeight(cfg.height)
			fc:SetMaxLines(cfg.height / C.media.fontsize * 2)
			fc:SetMovable(true)
			fc:SetResizable(true)
			fc:SetMinResize(64,64)
			fc:SetMaxResize(768,768)
			fc:SetClampedToScreen(true)
			fc:SetClampRectInsets(0,0,C.media.fontsize * 2,0)
			--fc:SetJustifyH(cfg.justify and cfg.justify or C.all.justify)
			fc:SetJustifyH("CENTER")
			--fc:SetAllPoints(f)
			fc:SetPoint(anchor, x and x or cfg.x, y and y or cfg.y)
			local CritShake=fc:CreateAnimationGroup("$parentCritShake")
			CritShake:SetLooping("BOUNCE")
			local dur = cfg.timevisible / 4

			local scaleup = CritShake:CreateAnimation("Scale");
			scaleup:SetScale(1.1, 1.1)
			scaleup:SetDuration(cfg.timevisible);
			scaleup:SetOrder(2);
			scaleup:SetSmoothing("NONE")

			local shakeleft = CritShake:CreateAnimation("Translation");
			shakeleft:SetDuration(dur);
			shakeleft:SetOffset(-4, 0);
			shakeleft:SetOrder(2);

			local shakeright = CritShake:CreateAnimation("Translation");
			shakeright:SetDuration(dur);
			shakeright:SetOffset(4, 0);
			shakeright:SetOrder(3);

			local shakup = CritShake:CreateAnimation("Translation");
			shakup:SetDuration(dur);
			shakup:SetOffset(0, 4);
			shakup:SetOrder(4);

			local shakedown = CritShake:CreateAnimation("Translation");
			shakedown:SetDuration(dur);
			shakedown:SetOffset(0, -4);
			shakedown:SetOrder(5);

			fc:HookScript("OnMessageScrollChanged",function(self)
					if not CritShake:IsPlaying() or CritShake:IsPendingFinish() then
							CritShake:Play()
					end
			end)


	end

	return F.frames[#F.frames]
end

F.cfgframe = function(f)

	f:SetBackdrop({	bgFile="Interface/Tooltips/UI-Tooltip-Background",
									edgeFile="Interface/Tooltips/UI-Tooltip-Border",
									tile=false,tileSize=0,edgeSize=2,
									insets={left=0,right=0,top=0,bottom=0}})
	f:SetBackdropColor(.1,.1,.1,.8)
	f:SetBackdropBorderColor(.1,.1,.1,.5)

	f.fs=f:CreateFontString(nil,"OVERLAY")
	f.fs:SetFont(f:GetFont())
	f.fs:SetPoint("BOTTOM",f,"TOP",0,0)
	f.fs:SetText(string.gsub(f:GetName(), "affCT", ""))
	f.fs:SetTextColor(1,.1,.1,.9)

	f.t=f:CreateTexture"ARTWORK"
	f.t:SetPoint("TOPLEFT",f,"TOPLEFT",1,-1)
	f.t:SetPoint("TOPRIGHT",f,"TOPRIGHT",-1,-19)
	f.t:SetHeight(20)
	f.t:SetTexture(.5,.5,.5)
	f.t:SetAlpha(.3)

	f.d=f:CreateTexture"ARTWORK"
	f.d:SetHeight(16)
	f.d:SetWidth(16)
	f.d:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-1,1)
	f.d:SetTexture(.5,.5,.5)
	f.d:SetAlpha(.3)

	f.tr=f:CreateTitleRegion()
	f.tr:SetPoint("TOPLEFT",f,"TOPLEFT",0,0)
	f.tr:SetPoint("TOPRIGHT",f,"TOPRIGHT",0,0)
	f.tr:SetHeight(20)

	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart",f.StartSizing)
	--if not(ct.scrollable)then
	f:SetScript("OnSizeChanged",function(self)
	--	self:SetMaxLines(self:GetHeight()/ct.fontsize)
		self:Clear()
	end)
	f:SetScript("OnDragStop",f.StopMovingOrSizing)
end

stopcfg = function()
	for i=1,#F.frames do
		f=F.frames[i]
		f:SetBackdrop(nil)
		f.fs:Hide()
		f.fs=nil
		f.t:Hide()
		f.t=nil
		f.d:Hide()
		f.d=nil
		f.tr=nil
		f:EnableMouse(false)
		f:SetScript("OnDragStart",nil)
		f:SetScript("OnDragStop",nil)
	end
end

F.startswith = function(message,start)
   return string.sub(message,1,string.len(start))==start
end

F.stripnumbers = function(message)
		return string.match(message, "%d+")
end

F.routemessage = function(message, r, g, b, displayType, isStaggered)
	local f
	local starts = F.startswith

	if starts(message,"+") then
		if isStaggered then
				f = affCTIncomingHealingFrameCrit
		else
				f = affCTIncomingHealingFrame
		--f = affCTIncomingHealingFrame
		end
	elseif
		starts(message,"-") then
		f = affCTIncomingDamageFrame
	else
		f = affCTCombatTextFrame
	end

	f:AddMessage(message, r, g, b)
	--F.cfgframe(f)
end


--[[
	Create 3 frames.
	Params are: name, anchor, x, y
]]
ctf = F.mkframe(C.cfg.ctf, "CENTER")
idf = F.mkframe(C.cfg.idf, "CENTER")
ihf = F.mkframe(C.cfg.ihf, "CENTER")

--[[
	here is some weird black magic (well not really)
	we just iterate over available Blizzard_CombatText fontstrings and make them
	route messages to our frame instead of showing it. Pretty hackish isn't it?
	Also disable blizzct OnUpdate.
]]

local function StealCT()
		COMBAT_TEXT_TO_ANIMATE = {}
		CombatText_ClearAnimationList()
		for i=1, NUM_COMBAT_TEXT_LINES do

			local string
			string = _G["CombatText"..i]
			string._SetText = string.SetText
			string._SetTextColor = string.SetTextColor
			string._Show = string.Show

			function string.SetText(self, message)
				self.message = message
			end

			function string.SetTextColor(self, r, g, b)
				self.r = r
				self.g = g
				self.b = b
			end

			function string.Show(self)
				F.routemessage(self.message,self.r,self.g,self.b, nil, self.isCrit == 1)
				self.isCrit = nil
			end
		end
		CombatText:SetScript("OnUpdate", nil)
end
StealCT()
hooksecurefunc("CombatText_OnLoad", StealCT)
