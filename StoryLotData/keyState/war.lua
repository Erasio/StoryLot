-- This story event defines a war breaking out between two kingdoms.

local Character = sl.DataObjects.Character
local Attribute = sl.DataObjects.Attribute
local Relationship = sl.DataObjects.Relationship

-- Definition of the desired world state

local world = sl.DataObjects.World()

local k1, k2

k1 = Character(false)
k1:addAttribute(Attribute("Care", -2)) 		-- Care 	vs harm
k1:addAttribute(Attribute("Fairness", -2))	-- Fairness vs cheating
k1:addAttribute(Attribute("Loyalty", 1))	-- Loyalty 	vs betrayal

k2 = Character(false)
k2:addAttribute(Attribute("Care", -4))
k2:addAttribute(Attribute("Fairness", 1))
k2:addAttribute(Attribute("Loyalty", -3))

world:addCharacter(k1)
world:addCharacter(k2)

-- Set up Relationships
local r12, r21

-- Set up relationships of Kingdom 1 to the other two.
r12 = Relationship(k2:getId())
r12:addAttributeModifier(Attribute("Care", -5))
r12:addAttributeModifier(Attribute("Fairness", -3))
r12:addAttributeModifier(Attribute("Loyalty", 0))

k1:addRelationship(r12)

-- Set up relationships of Kingdom 2 to the other two.
r21 = Relationship(k1:getId())
r21:addAttributeModifier(Attribute("Care", -2))
r21:addAttributeModifier(Attribute("Fairness", -1))
r21:addAttributeModifier(Attribute("Loyalty", -2))

-- Assign relationships
k2:addRelationship(r21)

-- Definition of the story edge

local edge = {}

return world, edge