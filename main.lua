--[[
	Simple ROBLOX Luau player icon changer [in right leaderboard]
	Designed for exploit environments containing the following capabilites / functions:
	- writefile
	- getcustomasset
	- game:HttpGet [exploit-specific alterations]
	- CoreGui access
--]]
local appliedIcons = {}
local userIds = { "1" } -- User IDs to apply icon onto
writefile("your-image.png", game:HttpGet("https://example.com/your-image.png")) -- Change this to your image URL
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local playerList = CoreGui:WaitForChild("PlayerList")
local childrenFrame = playerList:FindFirstChild("Children")
local function replaceIcon(parent)
    if not parent then
        return
    end
    for _, child in ipairs(parent:GetChildren()) do
        local playerId = child.Name:match("PlayerEntry_(%d+)")
        if playerId and table.find(userIds, playerId) then
            local icon = child:FindFirstChild("PlayerEntryContentFrame") and child.PlayerEntryContentFrame:FindFirstChild("OverlayFrame") and child.PlayerEntryContentFrame.OverlayFrame:FindFirstChild("NameFrame") and child.PlayerEntryContentFrame.OverlayFrame.NameFrame:FindFirstChild("PlayerIcon")
            if icon and not appliedIcons[icon] then
                local newIcon = Instance.new("ImageLabel")
                newIcon.Size = icon.Size
                newIcon.Position = icon.Position
                newIcon.BackgroundTransparency = 1
                newIcon.Image = getcustomasset("your-image.png")
                newIcon.Parent = icon.Parent
                icon:Destroy()
                appliedIcons[newIcon] = true
            end
        end
        replaceIcon(child)
    end
end
if childrenFrame then
    replaceIcon(childrenFrame)
    childrenFrame.DescendantAdded:Connect(function()
        replaceIcon(childrenFrame)
    end)
end
playerList.ChildAdded:Connect(function(child)
    if child.Name == "Children" then
        childrenFrame = child
        replaceIcon(childrenFrame)
        childrenFrame.DescendantAdded:Connect(function()
            replaceIcon(childrenFrame)
        end)
    end
end)
Players.PlayerAdded:Connect(function(player)
    task.defer(function()
        if childrenFrame then
            replaceIcon(childrenFrame, tostring(player.UserId))
        end
    end)
end)
Players.PlayerRemoving:Connect(function(player)
    for icon, _ in pairs(appliedIcons) do
        local entryId = icon.Parent.Name:match("PlayerEntry_(%d+)")
        if entryId == tostring(player.UserId) then
            appliedIcons[icon] = nil
        end
    end
end)
