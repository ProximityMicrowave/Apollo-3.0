local AH = apollo.hunter
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

local function healBasicCondition(target, spellName)
	return (isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) --and (not lowMana)
end

local function attackBasicCondition(target, spellName)
	return (not isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (offCooldown(spellName)) and ((affectingCombat(target)) or not IsInInstance())
end

local function attackCobraShot(target)
	local spellName = "Cobra Shot"
	local spellCast = attackBasicCondition(target, spellName)
	
	return spellCast, spellName
end

local function attackKillCommand(target)
	local spellName = "Kill Command"
	local spellCast = attackBasicCondition(target, spellName)
	
	return spellCast, spellName
end

local function attackDireBeast(target)
	local spellName = "Dire Beast"
	local spellCast = attackBasicCondition(target, spellName)
	
	return spellCast, spellName
end

local function attackConcussiveShot(target)
	local spellName = "Concussive Shot"
	local spellCast = attackBasicCondition(target, spellName)
	
	return spellCast, spellName
end

function AH.beastmasterySkillRotation()
	local skillRotation = {
		apollo.healHealthstone,
		attackConcussiveShot,
		attackKillCommand,
		attackCobraShot,
		attackDireBeast,
	}
	return skillRotation
end