local AD = apollo.druid
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
local lowMana = apollo.lowMana
local isMoving = apollo.isMoving
local affectingCombat = apollo.affectingCombat
local isTank = apollo.isTank

local function attackBaseCondition(spellName, target)
	return (not isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (offCooldown(spellName)) and ((affectingCombat(target)) or not IsInInstance())
end

local function healBaseCondition(spellName, target)
	return (isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (not lowMana()) and (offCooldown(spellName))
end

local function attackCrusaderStrike(target)
	local spellName = "Crusader Strike"
	local spellCast = attackBaseCondition(spellName, target)
	
	return spellCast, spellName
end

local function attackJudgment(target)
	local spellName = "Judgment"
	local spellCast = attackBaseCondition(spellName, target)
	
	return spellCast, spellName
end

local function attackHammerOfJustice(target)
	local spellName = "Hammer of Justice"
	local targetCasting = UnitCastingInfo(target)
	local spellCast = attackBaseCondition(spellName, target) and targetCasting
	
	return spellCast, spellName
end

local function attackHolyShock(target)
	local spellName = "Holy Shock"
	local spellCast = attackBaseCondition(spellName, target) and (not IsInInstance())
	
	return spellCast, spellName
end

local function attackHandOfReckoning(target)
	local spellName = "Hand of Reckoning"
	local spellCast = attackBaseCondition(spellName, target) and (not IsInInstance()) and (not InCombatLockdown())
	
	return spellCast, spellName
end

local function healFlashOfLight(target)
	local spellName = "Flash of Light"
	local spellCast = healBaseCondition(spellName, target) and (unitHealthPct(target) < .9) and (not isMoving("player"))
	
	return spellCast, spellName
end

local function healBestowFaith(target)
	local spellName = "Bestow Faith"
	local spellCast = healBaseCondition(spellName, target) and (unitHealthPct(target) < .9) and (isTank(target))
	
	return spellCast, spellName
end

local function healHolyShock(target)
	local spellName = "Holy Shock"
	local spellCast = healBaseCondition(spellName, target) and (unitHealthPct(target) < .9)
	
	return spellCast, spellName
end

local function healDivineShield(target)
	local spellName = "Divine Shield"
	local spellCast = healBaseCondition(spellName, target) and (UnitIsUnit("player",target)) and (unitHealthPct(target) < .7)
	
	return spellCast, spellName
end

function apollo.paladin.retributionSkillRotation()
	local skillRotation = {
		attackHammerOfJustice,
		attackJudgment,
		attackCrusaderStrike,
	}
	return skillRotation
end

function apollo.paladin.holySkillRotation()
	local skillRotation = {
		healDivineShield,
		healHolyShock,
		healBestowFaith,
		healFlashOfLight,
		attackHammerOfJustice,
		attackJudgment,
		attackCrusaderStrike,
		attackHolyShock,
		attackHandOfReckoning,
	}
	return skillRotation
end