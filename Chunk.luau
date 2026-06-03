local player = game:GetService("Players").LocalPlayer
local storage = game:GetService("ReplicatedStorage")
local _p = require(storage.Plugins)
local Utilities = _p.Utilities
local MasterControl = _p.MasterControl
local create = Utilities.Create
local rc4 = Utilities.rc4
local runService = game:GetService("RunService")
local stepped = runService.RenderStepped
local Room = require(script.Room)
local Door = require(script.Door)
local Chunk = Utilities.class({className = "Chunk", doorDebounce = false, indoors = false}, function(self)
  local container = Instance.new("Folder")
  container.Parent = storage
  self.map.Parent = container
  for _,room in pairs(self.rooms) do
    room.Parent = container
  end
  self.container = container
  self.regions = {}
  if self.map:FindFirstChild("Regions") then
    for _,part in pairs(self.map.Regions:GetChildren()) do
      if part:IsA("BasePart") then
        local region = _p.Region.FromPart(part)
        region.Name = part.Name
        table.insert(self.regions, region)
      end
    end
    self.map.Regions:Destroy()
  end
  local battle = _p.Battle
  local indoorCamOffset = nil
  do
    local angle = math.rad(40)
    indoorCamOffset = Vector3.new(0, math.sin(angle), -math.cos(angle)) * 18
    self.indoorCamFunc = function(override)
    if not self.room then
      self:unbindIndoorCam()
      return 
    end
    if (battle.currentBattle and not override) or self.roomCamDisabled then
      return 
    end
    local p = player.Character.HumanoidRootPart.CFrame * Vector3.new(0, 1.5, 0)
    p = Vector3.new(math.max(self.room.indoorCamMinX, math.min(self.room.indoorCamMaxX, p.X)), p.Y, p.Z)
    local from = p + indoorCamOffset
    workspace.CurrentCamera.CFrame = CFrame.new(from, p)
  end

    self.getIndoorCamCFrame = function()
    local p = player.Character.HumanoidRootPart.CFrame * Vector3.new(0, 1.5, 0)
    p = Vector3.new(math.max(self.room.indoorCamMinX, math.min(self.room.indoorCamMaxX, p.X)), p.Y, p.Z)
    local from = p + indoorCamOffset
    return CFrame.new(from, p)
  end

    self.roomStack = {}
    self.doors = {}
    self.npcs = {}
    return self
  end
end
)
Chunk.bindIndoorCam = function(self)
  runService:BindToRenderStep("IndoorCameraStep", Enum.RenderPriority.Camera.Value, self.indoorCamFunc)
end

Chunk.unbindIndoorCam = function(self)
  runService:UnbindFromRenderStep("IndoorCameraStep")
end

Chunk.setDay = function(self, isDay, model)
  if _p.Menu.options.reduceGraphics then
    isDay = true
  end
  local set -- forward declare so recursion works
  set = function(obj)
    if obj.Name == "Light" and obj:IsA("BasePart") then
      if not isDay then
        obj.Material = Enum.Material.Neon
        for _,light in pairs(obj:GetChildren()) do
          if light:IsA("Light") then
            light.Enabled = not isDay
          end
        end
        for _,ch in pairs(obj:GetChildren()) do
          set(ch)
        end
      end
    end
  end

  if model then
    set(model)
  else
    set(self.map)
    for _,r in pairs(self.roomStack) do
      set(r.model)
    end
  end
end

Chunk.changedRegions = function(self, newRegion)
  local s, regionData = pcall(function()
    return self.data.regions[newRegion.Name]
  end
)
  if not s or not regionData then
    return 
  end
  self.regionData = regionData
  do
    if regionData.Grass then
      local rq = {}
      do
        do
          for _,p in pairs(regionData.Grass) do
            table.insert(rq, {"_FRONT", rc4(p[1])})
            table.insert(rq, {"_SHINY_FRONT", rc4(p[1])})
          end
        end
        _p.DataManager:queueSpritesToCache(unpack(rq))
      end
    end
    _p.MusicManager:popMusic("RegionMusic", 1.5)
    if regionData.Music then
      local music = _p.MusicManager:stackMusic(regionData.Music, "RegionMusic", regionData.MusicVolume)
      if self.StartMusicAtZeroVolume then
        print("zeroing music")
        music.Volume = 0
        local cn = nil
        cn = music.Changed:Connect(function()
    if not self.StartMusicAtZeroVolume then
      cn:Disconnect()
      return 
    end
    if music.Volume > 0 then
      music.Volume = 0
    end
  end
)
      end
    end
    do
      if _p.DataManager.ignoreRegionChangeFlag then
        _p.DataManager.ignoreRegionChangeFlag = nil
        return 
      end
      local thread = {}
      self.regionThread = thread
      local board = create("ImageLabel")({create("Frame")({Name = "Container", BackgroundTransparency = 1, Size = UDim2.new(0.9, 0, 0.5, 0), Position = UDim2.new(0.05, 0, 0.25, 0), ClipsDescendants = true})})
      if regionData.SignColor then
        board.ImageColor3 = regionData.SignColor
      end
      local text = create("Frame")({BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0.6, 0), ZIndex = 2, Parent = board.Container})
      local written = Utilities.Write(newRegion.Name)({Frame = text, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left})
      task.spawn(function()
    local limit = written.MaxBounds.X + board.Container.AbsoluteSize.X
    local start = tick()
    local rate = 3
    while 1 do
      if self.regionThread ~= thread then
        break
      end
      local et = tick() - start
      local p = et * rate * text.AbsoluteSize.Y
      text.Position = UDim2.new(1, -p, 0.2, 0)
      if limit < p then
        break
      end
      stepped:Wait()
    end
    do
      Utilities.Tween(0.5, "easeOutCubic", function(a)
      if self.regionThread ~= thread then
        return false
      end
      board.Position = UDim2.new(0.1, 0, 0.025 - 0.3 * a, 0)
    end
)
      board:Destroy()
    end
  end
)
      Utilities.Tween(0.5, "easeOutCubic", function(a)
    if self.regionThread ~= thread then
      return false
    end
    board.Position = UDim2.new(0.1, 0, 0.025 - 0.3 * (1 - a), 0)
  end
)
    end
  end
end

Chunk.checkRegion = function(self, pos)
  do
    if not pos then
      local s, p = pcall(function()
    return _p.player.Character.HumanoidRootPart.Position
  end
)
      if not s or not p then
        return 
      end
      pos = p
    end
    local currentRegion = self.currentRegion
    if currentRegion and currentRegion:CastPoint(pos) then
      return 
    end
    do
      for _,region in pairs(self.regions) do
        if region ~= currentRegion and (not currentRegion or region.Name ~= currentRegion.Name) and region:CastPoint(pos) then
          Utilities.fastSpawn(function()
    self:changedRegions(region)
  end
)
          self.currentRegion = region
          return 
        end
      end
    end
  end
end

Chunk.doorFromModel = function(self, door)
  if type(door) ~= "userdata" then
    return door
  end
  for _,d in pairs(self.doors) do
    if d.model == door then
      return d
    end
  end
end

Chunk.getDoor = function(self, id)
  for _,door in pairs(self.doors) do
    if door.id == id then
      return door
    end
  end
end

Chunk.getNPCs = function(self)
  local npcs = {}
  for _,npc in pairs(self.npcs) do
    table.insert(npcs, npc)
  end
  for _,room in pairs(self.roomStack) do
    for _,npc in pairs(room.npcs) do
      table.insert(npcs, npc)
    end
  end
  return npcs
end

Chunk.topRoom = function(self)
  return self.roomStack[#self.roomStack]
end

Chunk.getRoom = function(self, id, door, level)
  if not level then
    level = 1
  end
  local pos = self.localIndoorsOrigin + Vector3.new(0, (level - 1) * 100, 0)
  local room = Room:new(self.rooms[id]:Clone(), pos)
  room.id = id
  room.chunk = self
  room.model.Parent = workspace
  room:init()
  self:setDay(_p.DataManager.isDay, room.model)
  if self.roomData and self.roomData[id] and self.roomData[id].NPCs then
    for _,nd in pairs(self.roomData[id].NPCs) do
      local model = _p.storage.Models.NPCs[nd.appearance]:Clone()
      Utilities.MoveModel(model.HumanoidRootPart, CFrame.new(room.model.Base.Position + nd.cframe.Position + Vector3.new(0, room.model.Base.Size.Y / 2 + 3, 0)) * (nd.cframe - nd.cframe.Position), true)
      model.Parent = room.model
      local npc = _p.NPC:new(model)
      npc:Animate()
      room.npcs[model.Name] = npc
      if nd.interact then
        _p.NPCChat.interactableNPCs[model] = nd.interact
      end
    end
  end
  do
    self.room = room
    if not room.Exit then
      local exitPart = (room.model:FindFirstChild("ToChunk:" .. self.id))
      do
        local exitCon = nil
        do
          exitCon = exitPart.Touched:Connect(function(p)
    if self.doorDebounce or not p or not p:IsDescendantOf(player.Character) or not p.Parent or p.Parent:IsA("Hat") then
      return 
    end
    if not _p.MasterControl.WalkEnabled then
      return 
    end
    exitCon:Disconnect()
    if door then
      self.doorDebounce = true
      self:exitDoor(door)
      self.doorDebounce = false
    else
      self:popSubRoom()
    end
  end
)
          for _,part in pairs(room.model:GetChildren()) do
            if part:IsA("BasePart") and part.Name:sub(1, 8) == "ToChunk:" then
              local chunkId = part.Name:sub(9)
              if chunkId ~= self.id then
                local touchCon = nil
                touchCon = part.Touched:Connect(function(p)
    if self.doorDebounce or not p or not p:IsDescendantOf(player.Character) or not p.Parent or p.Parent:IsA("Hat") then
      return 
    end
    touchCon:Disconnect()
    self.doorDebounce = true
    MasterControl.WalkEnabled = false
    MasterControl:Stop()
    _p.MusicManager:popMusic("all", 1)
    Utilities.FadeOut(1)
    Utilities.Teleport(CFrame.new(3, 70, 389) + Vector3.new(math.random(-20, 20), 0, math.random(-20, 20)))
    self:destroy()
    local newChunk = _p.DataManager:loadChunk(chunkId, true)
    newChunk.doorDebounce = true
    self:exitDoor(newChunk:getDoor(id), true)
    newChunk.doorDebounce = false
  end
)
              end
            end
          end
          return room
        end
      end
    end
  end
end

Chunk.stackSubRoom = function(self, id, button, noAnim)
  if not noAnim then
    MasterControl.WalkEnabled = false
    MasterControl:Stop()
    Utilities.FadeOut(1)
  end
  local newroom = self:getRoom(id, nil, #self.roomStack + 1)
  table.insert(self.roomStack, newroom)
  newroom.exitCFrame = button.CFrame * CFrame.new(0, 3, -3.5)
  local event = _p.Events["onBeforeEnter_" .. id]
  if event then
    event(newroom)
  end
  if not noAnim then
    Utilities.Teleport(self.room.Entrance.CFrame * CFrame.new(0, 3, 3.5) * CFrame.Angles(0, math.pi, 0))
    task.wait(0.5)
    Utilities.FadeIn(1)
    MasterControl.WalkEnabled = true
  end
  return newroom
end

Chunk.popSubRoom = function(self, noAnim)
  if not noAnim then
    MasterControl.WalkEnabled = false
    MasterControl:Stop()
    Utilities.FadeOut(1)
  end
  local st = tick()
  local room = table.remove(self.roomStack, #self.roomStack)
  local event = _p.Events["onExit_" .. room.id]
  if event then
    event(room)
  end
  local exitcf = room.exitCFrame
  room:destroy()
  self.room = self.roomStack[#self.roomStack]
  if not noAnim then
    Utilities.Teleport(exitcf)
    local elapsed = tick() - st
    if elapsed < 0.5 then
      task.wait(0.5 - elapsed)
    end
    Utilities.FadeIn(1)
    MasterControl.WalkEnabled = true
  end
end

Chunk.enterDoor = function(self, door)
  MasterControl.WalkEnabled = false
  MasterControl:Stop()
  _p.NPCChat:disable()
  self.indoors = true
  local angle = nil
  pcall(function()
    angle = self.roomData[door.id].DoorViewAngle
  end
)
  local y = player.Character.HumanoidRootPart.Position.Y
  local walkTo1 = door.Position + Vector3.new(0, y - door.Position.Y, 0)
  local walkTo2 = door.Position + Vector3.new(0, y - door.Position.Y, 0) - door.CFrame.LookVector * 5
  local cam = workspace.CurrentCamera
  -- Camera.Focus was removed; derive the look-at point from the camera CFrame
  local camF0 = cam.CFrame.Position + cam.CFrame.LookVector * 20
  local camC0 = cam.CFrame.Position
  local camF1 = door.Position
  local camC1 = door.Position + door.CFrame * CFrame.Angles(math.rad(angle or 35), 0, 0).LookVector * 20
  cam.CameraType = Enum.CameraType.Scriptable
  Utilities.Tween(0.3, "easeOutCubic", function(a)
    cam.CFrame = CFrame.new(camC0:Lerp(camC1, a), camF0:Lerp(camF1, a))
  end
)
  local event = _p.Events["onDoorFocused_" .. door.id]
  if event and event() then
    _p.NPCChat:enable()
    self.indoors = false
    return 
  end
  door:open(0.75)
  player:Move(walkTo1 - player.Character.HumanoidRootPart.Position, false)
  task.wait(0.1)
  player:Move(walkTo2 - player.Character.HumanoidRootPart.Position, false)
  local roomMusicId, roomMusicVolume = nil, nil
  if door.id == "PokeCenter" then
    roomMusicId = 288895151
  else
    if door.id:sub(1, 4) == "Gate" and tonumber(door.id:sub(5)) then
      roomMusicId = 288893317
      roomMusicVolume = 0.45
    end
  end
  pcall(function()
    if not self.roomData[door.id].Music then
      return 
    end
    roomMusicId = self.roomData[door.id].Music
    roomMusicVolume = self.roomData[door.id].MusicVolume
  end
)
  task.spawn(function()
    _p.MusicManager:fadeToVolume("top", roomMusicId and 0 or 0.3, 1)
  end
)
  Utilities.FadeOut(1)
  local room = self:getRoom(door.id, door)
  self.roomStack = {room}
  local event = _p.Events["onBeforeEnter_" .. door.id]
  if event then
    event(room)
  end
  MasterControl:Stop()
  local entrance = self.room.Entrance
  local cf = nil
  if entrance then
    cf = entrance.CFrame * CFrame.new(0, 3, 3.5) * CFrame.Angles(0, math.pi, 0)
  else
    entrance = self.room.model:FindFirstChild("ToChunk:" .. self.id)
    if entrance then
      cf = entrance.CFrame * CFrame.new(0, 0, -5.5)
    end
  end
  Utilities.Teleport(cf)
  MasterControl:SetIndoors(true)
  door:close()
  self.indoorCamFunc()
  self:bindIndoorCam()
  task.wait(0.5)
  if roomMusicId then
    _p.MusicManager:stackMusic(roomMusicId, "RoomMusic", roomMusicVolume)
  end
  Utilities.FadeIn(1)
  MasterControl.WalkEnabled = true
  _p.NPCChat:enable()
end

Chunk.exitDoor = function(self, door, alreadyFaded)
  MasterControl:SetJumpEnabled(false)
  MasterControl.WalkEnabled = false
  MasterControl:Stop()
  MasterControl:SetIndoors(false)
  _p.NPCChat:disable()
  _p.MusicManager:popMusic("RoomMusic", 1, true)
  if not alreadyFaded then
    Utilities.FadeOut(1)
  end
  local angle = nil
  pcall(function()
    angle = self.roomData[door.id].DoorViewAngle
  end
)
  self:unbindIndoorCam()
  local walkFrom = door.CFrame * CFrame.new(0, -door.Size.Y / 2 + 3, 2)
  local walkTo = door.Position + door.CFrame.LookVector * 5
  local cam = workspace.CurrentCamera
  local camF0 = door.Position
  local camC0 = door.Position + door.CFrame * CFrame.Angles(math.rad(angle or 35), 0, 0).LookVector * 20
  cam.CFrame = CFrame.new(camC0, camF0)
  door:open()
  Utilities.Teleport(walkFrom)
  if self.room then
    self.room:destroy()
  end
  self.room = nil
  self.roomStack = {}
  task.wait(0.5)
  task.spawn(function()
    _p.MusicManager:fadeToVolume("top", 1, 1)
  end
)
  task.spawn(function()
    Utilities.FadeIn(1)
  end
)
  local flat = Vector3.new(1, 0, 1)
  local torso = player.Character.HumanoidRootPart
  local prox = nil
  repeat
    prox = (walkTo - torso.Position).Magnitude
    player:Move((walkTo - torso.Position) * flat, false)
    stepped:Wait()
  until prox < (walkTo - torso.Position).Magnitude or ((walkTo - torso.Position) * flat).Magnitude < 0.1
  MasterControl:Stop()
  door:close(0.75)
  self.indoors = false
  _p.NPCChat:enable()
  local event = _p.Events["onExit_" .. door.id]
  if event and event() then
    local cam = workspace.CurrentCamera
    do
      local headP = player.Character.Head.Position
      local camGoal = CFrame.new(headP + cam.CFrame.Position - headP.Unit * 12.5, headP)
      local _, lerp = Utilities.lerpCFrame(cam.CFrame, camGoal)
      Utilities.Tween(0.8, "easeOutCubic", function(a)
    cam.CFrame = lerp(a)
  end
)
    end
  else
    do
      Utilities.Tween(0.2, "easeOutCubic", function(a)
    cam.CFrame = CFrame.new(camC0:Lerp(player.Character.Head.Position + camC0 - camF0.Unit * 12.5, a), camF0:Lerp(player.Character.Head.Position, a))
  end
)
      cam.CameraType = Enum.CameraType.Custom
      MasterControl.WalkEnabled = true
    end
  end
end

Chunk.hookupDoor = function(self, doorModel)
  local door = Door:new(doorModel)
  table.insert(self.doors, door)
  doorModel.Main.Touched:Connect(function(p)
    if door.disabled or self.doorDebounce or not p or not p:IsDescendantOf(player.Character) or not p.Parent or p.Parent:IsA("Hat") then
      return 
    end
    self.doorDebounce = true
    self:enterDoor(door)
    self.doorDebounce = false
  end
)
end

Chunk.hookupItem = function(self, itemModel)
  local part = itemModel:FindFirstChild("Top")
  local hinge = (itemModel:FindFirstChild("Hinge"))
  local obtainableItemNum, id = nil, nil
  local tm = itemModel:FindFirstChild("TM")
  if tm then
    tm = tm.Value
    if not part or not hinge or _p.BitBuffer.GetBit(_p.PlayerData.tms, tm) then
      itemModel:Destroy()
      return 
    end
  else
    obtainableItemNum = itemModel:FindFirstChild("ObtainableItemNumber")
    if not part or not hinge or not obtainableItemNum or _p.BitBuffer.GetBit(_p.PlayerData.obtainedItems, obtainableItemNum.Value) then
      itemModel:Destroy()
      return 
    end
    obtainableItemNum = obtainableItemNum.Value
    id = self.oItems[tostring(obtainableItemNum)]
    _p.DataManager:queueDataToCache({"Items", rc4(id)})
  end
  local db = false
  part.Touched:Connect(function(p)
    if db or not MasterControl.WalkEnabled or not p or not p:IsDescendantOf(player.Character) or not p.Parent or p.Parent:IsA("Hat") then
      return 
    end
    db = true
    MasterControl.WalkEnabled = false
    MasterControl:Stop()
    local item = nil
    if tm then
      item = {name = "TM" .. tostring(tm)}
    else
      item = _p.DataManager:getData("Items", rc4(id))
    end
    local pos = part.Position + Vector3.new(0, -0.25, 0)
    local cf = hinge.CFrame
    task.delay(0.2, function()
      for i = 1, 12 do
        _p.Particles:new({Position = pos, Velocity = Vector3.new(0, 5, 0), VelocityVariation = 30, Acceleration = Vector3.new(0, -5, 0), Size = 0.3, Image = 286854973, Color = Color3.new(0.9, 0.9, 0.9)})
      end
    end
)
    Utilities.Tween(0.5, "easeOutCubic", function(a)
      Utilities.MoveModel(hinge, cf * CFrame.Angles(0, 0, -math.pi / 2 * a))
    end
)
    Utilities.sound(288899943, nil, nil, 10)
    local chat = _p.NPCChat
    chat:say(_p.PlayerData.trainerName .. " found a " .. item.name .. "!")
    itemModel:Destroy()
    chat:say(_p.PlayerData.trainerName .. " put the " .. item.name .. " in the Bag.")
    if tm then
      _p.PlayerData.tms = _p.BitBuffer.SetBit(_p.PlayerData.tms, tm, true)
    else
      _p.PlayerData.obtainedItems = _p.BitBuffer.SetBit(_p.PlayerData.obtainedItems, obtainableItemNum, 1)
      _p.PlayerData:addBagItems({id = id, quantity = 1})
    end
    MasterControl.WalkEnabled = true
  end
)
end

Chunk.init = function(self)
  for _,obj in pairs(self.map:GetChildren()) do
    if obj.Name == "Door" then
      self:hookupDoor(obj)
    else
      if obj.Name == "#Item" then
        self:hookupItem(obj)
      else
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
          local npc = _p.NPC:new(obj)
          if not obj:FindFirstChild("NoAnimate") then
            npc:Animate()
          end
          self.npcs[obj.Name] = npc
        end
      end
    end
  end
  _p.NPC:collectNPCs(self.map, self.npcs)
  task.delay(0.5, function()
    while self.regions do
      if not self.indoors then
        self:checkRegion()
      end
      task.wait(0.5)
    end
  end
)
  local event = _p.Events["onLoad_" .. self.id]
  if event then
    event(self)
  end
end

Chunk.destroy = function(self)
  self.regions = nil
  self.currentRegion = nil
  self.regionData = nil
  pcall(function()
    self.map:Destroy()
  end
)
  local music = self.Music
  if music then
    task.spawn(function()
    local v = music.Volume
    Utilities.Tween(0.5, nil, function(a)
      music.Volume = v * (1 - a)
    end
)
    music:Destroy()
  end
)
  end
  for _,room in pairs(self.roomStack) do
    do
      pcall(function()
    room:Destroy()
  end
)
    end
  end
  self.roomStack = nil
  for _,room in pairs(self.rooms) do
    pcall(function()
    room:Destroy()
  end
)
  end
  self.rooms = nil
  for _,door in pairs(self.doors) do
    pcall(function()
    door:Destroy()
  end
)
  end
  self.doors = nil
  for _,npc in pairs(self.npcs) do
    pcall(function()
    npc:Destroy()
  end
)
  end
  self.npcs = nil
  pcall(function()
    self.container:Destroy()
  end
)
end

return Chunk
