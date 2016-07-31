Apollo = {}

local frame = CreateFrame("FRAME");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
function frame:OnEvent(event, arg1)	

	if (event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_SPECIALIZATION_CHANGED") then
		Apollo.playerClass = UnitClass("player")
		Apollo.playerSpec = select(2,GetSpecializationInfo(GetSpecialization()))
		
		
	end

end
frame:SetScript("OnEvent", frame.OnEvent);

function Apollo_OnUpdate(self, elapsed)
	local r, g, b, idealTarget
	r, g, b = 0, 0, 0
	
	
	ColorDot:SetColorTexture(r,g,b,1)
end