local folderOfThisFile = (...)
local DataObjects = {}

DataObjects.Attribute = require(folderOfThisFile .. ".attribute")
DataObjects.StoryEvent = require(folderOfThisFile .. ".storyEvent")
DataObjects.Relationship = require(folderOfThisFile .. ".relationship")(DataObjects)
DataObjects.Character = require(folderOfThisFile .. ".character")(DataObjects)
DataObjects.World = require(folderOfThisFile .. ".world")(DataObjects)
DataObjects.StoryEdge = require(folderOfThisFile .. ".minorStoryEvent")(DataObjects)

return DataObjects