io.stdout:setvbuf("no")
math.randomseed(os.time())
math.random()
math.random()
math.random()

saveFile = false

function love.load()
	json = require("Utils.json")
	sl = require("StoryLot")

	local World = sl.DataObjects.World
	local StoryEdge = sl.DataObjects.StoryEdge
	
	local war = World.load("StoryLotData/keyState/war.lot")

	local keySteps ={
		{
			World.load("StoryLotData/keyState/war.lot"),
			World.load("StoryLotData/keyState/treaty.lot")
		},
		{
			World.load("StoryLotData/keyState/treaty.lot"),
			World.load("StoryLotData/keyState/naturalDisaster.lot")
		}
	}

	local minorStoryEvents = {
		StoryEdge.load("StoryLotData/minorStoryEvent/eventC1.se"),
		StoryEdge.load("StoryLotData/minorStoryEvent/eventC-1.se"),
		StoryEdge.load("StoryLotData/minorStoryEvent/eventC2.se"),
		StoryEdge.load("StoryLotData/minorStoryEvent/eventC-2.se"),
		StoryEdge.load("StoryLotData/minorStoryEvent/eventC3.se"),
		StoryEdge.load("StoryLotData/minorStoryEvent/eventC-3.se"),
		StoryEdge.load("StoryLotData/minorStoryEvent/eventF1.se"),
		StoryEdge.load("StoryLotData/minorStoryEvent/eventF-1.se"),
		StoryEdge.load("StoryLotData/minorStoryEvent/eventF2.se"),
		StoryEdge.load("StoryLotData/minorStoryEvent/eventF-2.se"),
		StoryEdge.load("StoryLotData/minorStoryEvent/eventF3.se"),
		StoryEdge.load("StoryLotData/minorStoryEvent/eventF-3.se"),
		StoryEdge.load("StoryLotData/minorStoryEvent/eventL1.se"),
		StoryEdge.load("StoryLotData/minorStoryEvent/eventL-1.se"),
		StoryEdge.load("StoryLotData/minorStoryEvent/eventL2.se"),
		StoryEdge.load("StoryLotData/minorStoryEvent/eventL-2.se"),
		StoryEdge.load("StoryLotData/minorStoryEvent/eventL3.se"),
		StoryEdge.load("StoryLotData/minorStoryEvent/eventL-3.se"),
	}

	storyGraph = sl.generate{
		initialStates = { World.load("StoryLotData/initialState/default.lot") },
		keySteps = keySteps,
		minorStoryEvents = minorStoryEvents,
		conclustionSteps = { World.load("StoryLotData/concludingState/default.lot") }, 
		numTransitionSteps = 3,
		numKeyStatesPerStep = 2
	}

	-- Output

	print("")

	local texts = {}
	local currentNode = storyGraph.timeSteps[1][1]
	
	while currentNode do
		if currentNode.data.text then
			table.insert(texts, currentNode.data.text)
		end

		local listOfEdges = {}
		for _, edge in pairs(currentNode.edges) do
			if edge:getOther(currentNode).timeStep > currentNode.timeStep then
				table.insert(listOfEdges, edge)
			end
		end
		local edge = listOfEdges[math.random(#listOfEdges)]
		if edge then
			for _, struct in pairs(edge.data.storyEvents) do
				table.insert(texts, struct.event:getString(struct.char))
			end
			currentNode = edge:getOther(currentNode)
			table.insert(texts, "")
		else
			break
		end
	end

	outputPath = ""

	for _, text in pairs(texts) do
		print(text)
	end

	if saveFile then 
		local file, errorstr = love.filesystem.newFile("demoOutput.txt", "w")
        
    	if file then
	    	for _, text in pairs(texts) do
				file:write(text .. "\r\n")
			end

			outputPath = "Output file written to: " .. love.filesystem.getSaveDirectory() .. "/demoOutput.txt"
			print(outputPath)
	    else
	        print(errorstr) 
	    end

	    file:close()
    end
end

function love.update(dt)
end

function love.draw()
	if storyGraph then
		sl.drawGraph(storyGraph)
		love.timer.sleep(0.1)
	end
	if outputPath then
		love.graphics.print(outputPath)
	end
end