apollo = {}
apollo.druid = {}

local frame = CreateFrame("FRAME");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
function frame:OnEvent(event, arg1)	
	apollo.getPlayerRotation()
	apollo.assignKeybindings()
	
end
frame:SetScript("OnEvent", frame.OnEvent);

function apollo_OnUpdate(self, elapsed)
	local r, g, b, idealTarget
	r, g, b = 0, 0, 0
	
	ColorDot:SetColorTexture(r,g,b,1)
end

function apollo.getPlayerRotation()
	local playerClass = UnitClass("player")
	local playerSpec = select(2,GetSpecializationInfo(GetSpecialization()))
		
	if playerClass == "Druid" and playerSpec == "Restoration" then apollo.skillRotation = {apollo.druid.healingTouch, apollo.druid.regrowth}; end;
end

function apollo.assignKeybindings()
	if InCombatLockdown() then return; end;
	local groupType, offset
	
	if IsInRaid() == true then 
		groupType = "raid"
		offset = 0
	else 
		groupType = "party"
		offset = -1
	end

	for i=1,40 do
		local target = groupType..(i + offset)
		if target == "party0" then target = "player"; end;
		
		local btnName = "apolloTarget"..i
		local btn = CreateFrame("Button", btnName, UIParent, "SecureActionButtonTemplate")
		btn:SetAttribute("type", "macro");
		btn:SetAttribute("macrotext", "/focus "..target)
		SetBinding(apollo.targetKeybinding[i])
		SetBindingClick(apollo.targetKeybinding[i], btnName)
	end
	
	-----------------------------------------------------------------------------------------------------------
	local skillRotation = apollo.skillRotation
	for i in ipairs(skillRotation) do
		local btnName = "skill"..i
		local btn = CreateFrame("Button", btnName, UIParent, "SecureActionButtonTemplate")
		btn:SetAttribute("type", "macro")
		btn:SetAttribute("macrotext", "/use [nochanneling,@focus]"..select(2,skillRotation[i]()))
		SetBinding(apollo.abilityKeybinding[i])
		SetBindingClick(apollo.abilityKeybinding[i], btnName)
	end
	
end


