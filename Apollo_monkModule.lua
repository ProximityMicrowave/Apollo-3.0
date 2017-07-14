local AM = apollo.monk
local notDead = apollo.notDead
local inRange = apollo.inRange
local isUsable = apollo.isUsable
local missingHealth = apollo.missingHealth
local unitHealthPct = apollo.unitHealthPct
local hasThreat = apollo.hasThreat
local isFriend = apollo.isFriend
local offCooldown = apollo.offCooldown
local getEnergy = apollo.getEnergy
local getComboPoints = apollo.getComboPoints
local canInterupt = apollo.canInterupt
local lowMan = apollo.lowMana
local affectingCombat = apollo.affectingCombat

local function getChi()
	return UnitPower("player",12) or 0
end

local function attackBasicCondition(spellName, target)
	return (not isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (offCooldown(spellName)) and ((affectingCombat(target)) or not IsInInstance())
end

local function healBasicCondition(spellName, target)
	return (isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName))
end

local function attackTigerPalm(target)
	local spellName = "Tiger Palm"
	local spellCast = attackBasicCondition(spellName, target) and getChi() <= 3
	
	return spellCast, spellName
end

local function attackBlackoutKick(target)
	local spellName = "Blackout Kick"
	local spellCast = attackBasicCondition(spellName, target)
	
	return spellCast, spellName
end

local function healEffuse(target)
	local spellName = "Effuse"
	local spellCast = healBasicCondition(spellName, target) and (unitHealthPct(target) < .3)
	
	return spellCast, spellName
end

local function attackRisingSunKick(target)
	local spellName = "Rising Sun Kick"
	local spellCast = attackBasicCondition(spellName, target)
	
	return spellCast, spellName
end

function AM.windwalkerSkillRotation()
	local skillRotation = {
		apollo.healHealthstone,
		healEffuse,
		attackTigerPalm,
		attackRisingSunKick,
		attackBlackoutKick,
	}
	return skillRotation
end