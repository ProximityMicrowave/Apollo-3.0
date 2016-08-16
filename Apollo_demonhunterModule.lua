local notDead = apollo.notDead
local inRange = apollo.inRange
local isUsable = apollo.isUsable
local missingHealth = apollo.missingHealth
local unitHealthPct = apollo.unitHealthPct
local hasThreat = apollo.hasThreat
local isFriend = apollo.isFriend
local offCooldown = apollo.offCooldown
local getEnergy = apollo.getEnergy
local getFury = apollo.getFury
local canInterupt = apollo.canInterupt
local lowMan = apollo.lowMana
local isMoving = apollo.isMoving
local affectingCombat = apollo.affectingCombat
local isTank = apollo.isTank

local function attackBaseCondition(spellName, target)
	return (not isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (offCooldown(spellName))
end

local function attackDemonsBite(target)
	local spellName = "Demon's Bite"
	local spellCast = attackBaseCondition(spellName, target)
	
	return spellCast, spellName
end

local function attackThrowGlaive(target)
	local spellName = "Throw Glaive"
	local spellCast = attackBaseCondition(spellName, target)
	
	return spellCast, spellName
end

local function attackChaosStrike(target)
	local spellName = "Chaos Strike"
	local spellCast = attackBaseCondition(spellName, target) and (getFury() > 50)
	
	return spellCast, spellName
end

local function attackEyeBeam(target)
	local spellName = "Eye Beam"
	local spellCast = (not isFriend(target)) and (notDead(target)) and (inRange("Demon's Bite",target)) and (isUsable(spellName)) and (offCooldown(spellName))
	
	return spellCast, spellName
end

local function attackConsumeMagic(target)
	local spellName = "Consume Magic"
	local spellCast = attackBaseCondition(spellName, target) and (canInterupt(target))
	
	return spellCast, spellName
end

function apollo.demonHunter.havocSkillRotation()
	local skillRotation = {
		attackConsumeMagic,
		attackEyeBeam,
		attackChaosStrike,
		attackThrowGlaive,
		attackDemonsBite,
	}
	return skillRotation
end