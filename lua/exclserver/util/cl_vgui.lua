
-- Font generation
ES.Font = "Roboto"

function ES.CreateFont(name,font)
	if type(name) ~= "string" or type(font) ~= "table" then return end

	local tab;

	tab=table.Copy(font)
	tab.font = ES.Font;
	surface.CreateFont(name,tab);

	tab=table.Copy(font)
	tab.font = ES.Font;
	tab.blursize = 2
	surface.CreateFont(name..".Shadow",tab)
end

ES.CreateFont( "ESDefault-", {
	size = 12,
	weight = 500
})
ES.CreateFont( "ESDefault", {
	size = 14,
	weight = 400
})
ES.CreateFont( "ESDefaultBold", {
	size = 14,
	weight = 700
})
ES.CreateFont( "ESDefault+", {
	size=20,
	weight=400
})
ES.CreateFont( "ESDefaultBold+", {
	size=20,
	weight=600
})
ES.CreateFont( "ESDefault++", {
	size=26,
	weight=400
})
ES.CreateFont( "ESDefault+++", {
	size=32,
	weight=400
})

-- Speeds up development
function ES.UIAddHoverListener(panel)
	AccessorFunc(panel,"hover","Hover",FORCE_BOOL)
	panel.OnCursorEntered = function(self)
		self:SetHover(true)
		self:SetCursor("hand")
	end
	panel.OnCursorExited = function(self)
		self:SetHover(false)
		self:SetCursor("arrow")
	end

	return panel
end

-- The ripple effect
local matRipple = Material("exclserver/vgui/ripple.png")
function ES.UIInitRippleEffect(tab)
	tab.rippleColor = Color(255,255,255,0)
	tab.rippleScale = 1
	tab.cursorPos_x = 0
	tab.cursorPos_y = 0
end
function ES.UIMakeRippleEffect(tab)
	if not tab.rippleColor or not tab.rippleScale or not tab.cursorPos_x or not tab.cursorPos_y then return	end

	tab.rippleScale = 0
	tab.cursorPos_x, tab.cursorPos_y = tab:CursorPos()
end
function ES.UIDrawRippleEffect(tab,w,h)
	if not tab.rippleColor or not tab.rippleScale or not tab.cursorPos_x or not tab.cursorPos_y then return	end

	tab.rippleScale = Lerp(FrameTime()*3,tab.rippleScale,1)

	if tab.rippleScale > 0 and tab.rippleScale < 1 then
		tab.cursorPos_x = Lerp(FrameTime()*0.1,tab.cursorPos_x,w/2)
		tab.cursorPos_y = Lerp(FrameTime()*0.1,tab.cursorPos_y,h/2)
		tab.rippleColor.a = 255 - 255*tab.rippleScale

		surface.SetDrawColor(tab.rippleColor)
		surface.SetMaterial(matRipple)
		surface.DrawTexturedRectRotated(tab.cursorPos_x,tab.cursorPos_y,128*tab.rippleScale,128*tab.rippleScale,0)
	end
end

-- Blur
local matBlurScreen = Material( "pp/blurscreen" )
local matGradient = Material("exclserver/nothing.png")
function ES.UIDrawBlur(panel,mtr)
	local x, y = panel:LocalToScreen( 0, 0 )

	render.ClearStencil()
	render.SetStencilEnable(true)

	render.SetStencilFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilZFailOperation( STENCILOPERATION_REPLACE )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )

	render.SetStencilReferenceValue( 1 )

	surface.SetDrawColor(ES.Color.White)
	surface.SetMaterial(matGradient)
	surface.DrawTexturedRect(0,0,panel:GetWide(),panel:GetTall())

	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )

	surface.SetMaterial( matBlurScreen )

	if mtr then
		cam.PopModelMatrix(mtr)
	end

	--DisableClipping( true )

	for i=.2, 1, 0.2 do
		matBlurScreen:SetFloat( "$blur", 10 * i )
		matBlurScreen:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect( x * -1, y * -1, ScrW(), ScrH() )
	end

	--DisableClipping( false )

	render.SetStencilEnable(false)

	if mtr then
		cam.PushModelMatrix(mtr)
	end
end

-- easily create settings stuff
function ES.UICreateSettingModPanel(setting)
	local val=ES.GetSetting(setting)
	local pnl;
	local typ=type(val)
	if typ == "boolean" then
		pnl = vgui.Create("esToggleButton")
		pnl:SetChecked(val)
		pnl:SetText(setting)
		pnl.DoClick = function(pnl,check)
			net.Start("exclserver.settings.send")
			net.WriteString(setting);
			net.WriteString(tostring(check))
			net.SendToServer()
		end
	else
		pnl = vgui.Create("Panel")
		pnl:SetTall(18)

		local lbl=pnl:Add("DLabel")
		lbl:SetFont("ESDefaultBold")
		lbl:SetColor(ES.Color.White)
		lbl:SetText(setting)
		lbl:SizeToContents()

	end

	return pnl;
end

-- Disable ugly progress thingy
hook.Remove( "SpawniconGenerated", "SpawniconGenerated")
