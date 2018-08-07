local Character = sl.DataObjects.Character
local Attribute = sl.DataObjects.Attribute
local Relationship = sl.DataObjects.Relationship

local world = sl.DataObjects.World()
-- Set up the 3 characters
local k1, k2, k3 
-- Set up Kingdom 1
-- Caring, fair and loyal. But not really taking any of that seriously.
k1 = Character()
k1:addAttribute(Attribute("Care", 1))  		-- Care 	vs harm
k1:addAttribute(Attribute("Fairness", 2))	-- Fairness vs cheating
k1:addAttribute(Attribute("Loyalty", 1))	-- Loyalty 	vs betrayal

-- Set up Kingdom 2
-- Not caring about the well being of others at all.
-- But sticking to a strict codex of fairness and loyalty. 
k2 = Character()
k2:addAttribute(Attribute("Care", -5))
k2:addAttribute(Attribute("Fairness", 3))
k2:addAttribute(Attribute("Loyalty", 5))

-- Set up Kingdom 3
-- The perceived well being of others is of the utmost importance.
-- All methods are fine to care for others.
k3 = Character()
k3:addAttribute(Attribute("Care", 5))
k3:addAttribute(Attribute("Fairness", -4))
k3:addAttribute(Attribute("Loyalty", -2))

world:addCharacter(k1)
world:addCharacter(k2)
world:addCharacter(k3)


-- Set up Relationships
local r12, r13, r21, r23, r31, r32

-- Set up relationships of Kingdom 1 to the other two.
r12 = Relationship(k2:getId())
r12:addAttributeModifier(Attribute("Care", 0))
r12:addAttributeModifier(Attribute("Fairness", 1))
r12:addAttributeModifier(Attribute("Loyalty", 0))
r13 = Relationship(k3:getId())
r13:addAttributeModifier(Attribute("Care", 1))
r13:addAttributeModifier(Attribute("Fairness", -2))
r13:addAttributeModifier(Attribute("Loyalty", -1))

-- Assign relationships
k1:addRelationship(r12)
k1:addRelationship(r13)

-- Set up relationships of Kingdom 2 to the other two.
r21 = Relationship(k1:getId())
r21:addAttributeModifier(Attribute("Care", 2))
r21:addAttributeModifier(Attribute("Fairness", 0))
r21:addAttributeModifier(Attribute("Loyalty", -1))
r23 = Relationship(k3:getId())
r23:addAttributeModifier(Attribute("Care", -5))
r23:addAttributeModifier(Attribute("Fairness", -2))
r23:addAttributeModifier(Attribute("Loyalty", -5))

-- Assign relationships
k2:addRelationship(r21)
k2:addRelationship(r23)

-- Set up relationships of Kingdom 3 to the other two.
r31 = Relationship(k1:getId())
r31:addAttributeModifier(Attribute("Care", 0))
r31:addAttributeModifier(Attribute("Fairness", 0))
r31:addAttributeModifier(Attribute("Loyalty", 0))
r32 = Relationship(k2:getId())
r31:addAttributeModifier(Attribute("Care", -1))
r31:addAttributeModifier(Attribute("Fairness", -1))
r31:addAttributeModifier(Attribute("Loyalty", -2))

-- Assing relationships
k3:addRelationship(r31)
k3:addRelationship(r32)

return world