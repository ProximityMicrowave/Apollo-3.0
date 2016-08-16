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
	return (not isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (offCooldown(spellName)) and (affectingCombat(target))
end

local function attackSlam(target)
	local spellName = "Slam"
	local spellCast = attackBaseCondition(spellName, target)
	
	return spellCast, spellName
end

local function attackShieldSlam(target)
	local spellName = "Shield Slam"
	local spellCast = attackBaseCondition(spellName, target)
	
	return spellCast, spellName
end

local function attackDevastate(target)
	local spellName = "Devastate"
	local spellCast = attackBaseCondition(spellName, target)
	
	return spellCast, spellName
end

local function attackVictoryRush(target)
	local spellName = "Victory Rush"
	local spellCast = attackBaseCondition(spellName, target)
	
	return spellCast, spellName
end

local function attackExecute(target)
	local spellName = "Execute"
	local spellCast = attackBaseCondition(spellName, target)
	
	return spellCast, spellName
end

local function attackMortalStrike(target)
	local spellName = "Mortal Strike"
	local spellCast = attackBaseCondition(spellName, target)
	
	return spellCast, spellName
end

local function attackCharge(target)
	local spellName = "Charge"
	local spellCast = attackBaseCondition(spellName, target)
	
	return spellCast, spellName
end

function apollo.warrior.armsSkillRotation()
	local skillRotation = {
		attackCharge,
		attackVictoryRush,
		attackExecute,
		attackMortalStrike,
		attackSlam,
	}
	return skillRotation
end

function apollo.warrior.protectionSkillRotation()
	local skillRotation = {
		attackCharge,
		attackVictoryRush,
		attackShieldSlam,
		attackDevastate,
	}
	return skillRotation
end