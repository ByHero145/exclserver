-- A bunch of command aliases to open up the main menu. Nothing special here.
if SERVER then
	util.AddNetworkString("es.plugins.thirdperson.toggle")
end

local PLUGIN=ES.Plugin()
PLUGIN:SetInfo("Thirdperson","Allow you to toggle thirdperson.","Excl")

PLUGIN:AddFlag(EXCL_PLUGIN_FLAG_NODEFAULTDISABLED)


if SERVER then

	PLUGIN:AddCommand("thirdperson",function(p,a)
		if p:ESGetVIPTier() < 3  then return end
		net.Start("es.plugins.thirdperson.toggle") net.WriteBool(true) net.Send(p)
	end)
	PLUGIN:AddCommand("firstperson",function(p,a)
		if p:ESGetVIPTier() < 3 then return end
		net.Start("es.plugins.thirdperson.toggle") net.WriteBool(false) net.Send(p)
	end)

else --if CLIENT then

	net.Receive("es.plugins.thirdperson.toggle",function()
		ES.DebugPrint("Setting third person mode.")

		LocalPlayer()._es_thirdpersonMode = net.ReadBool() and not LocalPlayer()._es_thirdpersonMode or false

		if LocalPlayer()._es_thirdpersonMode then
			chat.AddText("You have enabled thirdperson mode.")
		end
	end)

	local fov = 0
	local newpos
	local tracedata = {}
	local distance = 60
	local camPos = Vector(0, 0, 0)
	local camAng = Angle(0, 0, 0)

	local newpos
	local newangles
	hook.Add("CalcView", "exclThirdperson", function(ply, pos , angles ,fov)
		if not newpos then
			newpos = pos
			newangles = angles
		end

		if( ply._es_thirdpersonMode ) and distance > 2 then
			local side = ply:GetActiveWeapon()
			side = side and IsValid(side) and side.GetHoldType and side:GetHoldType() ~= "normal" and side:GetHoldType() ~= "melee" and side:GetHoldType() ~= "melee2" and side:GetHoldType() ~= "knife"

			if side then
				tracedata.start = pos
				tracedata.endpos = pos - ( angles:Forward() * distance ) + ( angles:Right()* ((distance/90)*50) )
				tracedata.filter = player.GetAll()
				trace = util.TraceLine(tracedata)
		        pos = newpos
				newpos = LerpVector( 0.5, pos, trace.HitPos + trace.HitNormal*2 )
				angles = newangles
				newangles = LerpAngle( 0.5, angles, (ply:GetEyeTraceNoCursor().HitPos-newpos):Angle() )

				camPos = pos
				camAng = angles
				return GAMEMODE:CalcView(ply, newpos, angles, fov)
			else
				tracedata.start = pos
				tracedata.endpos = pos - ( angles:Forward() * distance * 2 ) + ( angles:Up()* ((distance/60)*10) )
				tracedata.filter = player.GetAll()

		    	trace = util.TraceLine(tracedata)
		        pos = newpos
				newpos = trace.HitPos + trace.HitNormal*2

				camPos = pos
				camAng = angles
				return GAMEMODE:CalcView(ply, newpos , angles ,fov)

			end
		else
			newpos = ply:EyePos()
		end
	end)

	hook.Add("ShouldDrawLocalPlayer", "ESThirdpersonDrawLocal", function()
		if LocalPlayer()._es_thirdpersonMode == true then
			return true
		end
	end)
end

PLUGIN()
