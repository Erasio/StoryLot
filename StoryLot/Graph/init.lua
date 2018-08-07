local folderOfThisFile = (...)
local Graph = class('Graph')
Graph.Node = require(folderOfThisFile .. ".node")(Graph)
Graph.Edge = require(folderOfThisFile .. ".edge")(Graph)


-- Args is a table containing the following arguments:
--	transitionSteps: The amount of nodes between key nodes.
--		default: 3
--  numKeySteps: The amount of key nodes within the graph.
--		default: 1
--	root: The root node
--		default: Empty node

function Graph:initialize(args)
	args = args or {}

	self.timeSteps = {}

	args.numTransitionSteps = args.numTransitionSteps or 3

	args.numKeySteps = args.numKeySteps or 1

	self.rootNode = args.root or Graph.Node()
	self.rootNode.timeStep = 1
	self.timeSteps[1] = {timeStepType = "InitialState", timeStep = 1}
	self.timeSteps[1][1] = self.rootNode

	rootNode = self.rootNode
	
	-- Create tables to hold timeSteps per time step.
	local numTimeStep
	for i = 1, args.numKeySteps do
		for j=1, args.numTransitionSteps + 1 do 
			numTimeStep = (i - 1) * (args.numTransitionSteps + 1) + j + 1
			self.timeSteps[numTimeStep] = {timeStepType = "TransitionState", timeStep = numTimeStep}
		end
		numTimeStep = i * (args.numTransitionSteps + 1) + 1
		self.timeSteps[numTimeStep] = {timeStepType = "KeyState", timeStep = numTimeStep}
	end
	self.timeSteps[#self.timeSteps].timeStepType = "ConclusionState"
	
	self.activeNode = self.timeSteps[1][1]
	self.activeTimeStep = 1

	    -- Insert root node and set as active node
    self.timeSteps[1][1] = self.rootNode
    self.activeNode = self.timeSteps[1][1]
end



function Graph:newNode(timeStep, data)
	if self.timeSteps[timeStep] then
		table.insert(self.timeSteps[timeStep], self.Node(data))
	end
end

function Graph:addNode(timeStep, newNode)
	if self.timeSteps[timeStep] then 
		if newNode:isInstanceOf(self.Node) then
			table.insert(self.timeSteps[timeStep], newNode)
		end
	end
end

function Graph:getCurrentTimeStep()
	return self.timeSteps[self.activeTimeStep]
end

function Graph:getActiveNode()
	return self.activeNode
end

return Graph