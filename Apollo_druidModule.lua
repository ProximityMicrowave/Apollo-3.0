local AD = apollo.druid
local notDead = apollo.notDead
local inRange = apollo.inRange
local isUsable = apollo.isUsable
local missingHealth = apollo.missingHealth

function AD.healHealingTouch(target)
	local spellName = "Healing Touch"
	local target = target or "player"
	local heal = (GetSpellBonusHealing() * 4)
	
	local spellCast = (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (missingHealth(target) > heal)
	
	return spellCast, spellName
end



--[[
function AD.HealingTouch(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "focus"; end;
	local __func__ = "Apollo.Druid.HealingTouch"
	
	local spellCast = false
	local spellName = "Healing Touch"
	local keybinding = 3
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, "focus", keybinding);return; end;
	if (not UnitExists(spellTarget)) or spellTarget == "target" then return false, 0, keybinding; end;
	
	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local isUsable,noMana = IsUsableSpell(spellName)
	local unitHealthPct = Apollo.UnitHealthPct(spellTarget)
	local missingHealth = Apollo.MissingHealth(spellTarget)
	local threat = UnitThreatSituation(spellTarget) or 0
	
	if (not isDead)
	and (inRange == 1) 
	and (missingHealth > AD.SpellHealing["Healing Touch"])
	and (isUsable)
	and (not noMana)
	then spellCast = true; end;
	
	return spellCast, spellHeal, keybinding
end
]]--