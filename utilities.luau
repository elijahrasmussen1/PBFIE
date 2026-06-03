local player = game:GetService("Players").LocalPlayer
for i = 1, 10 do
  if player then
    break
  end
  task.wait()
  player = game:GetService("Players").LocalPlayer
end
do
  local userInputService = game:GetService("UserInputService")
  do
    local stepped = game:GetService("RunService").RenderStepped
    local Timing = require(script.Timing)
    do
      local util = {}
      local debugInstances = true
      do
        local classes = {}
        util.class = function(nc, newf)
  if not nc then
    nc = {}
  end
  nc.__index = nc
  local classDebugData = nil
  if debugInstances and nc.className then
    classDebugData = {name = nc.className, class = nc, instances = setmetatable({}, {__mode = "v"})}
    table.insert(classes, classDebugData)
  end
  nc.new = function(self, o, ...)
    if not o then
      o = {}
    end
    if type(o) == "table" then
      setmetatable(o, nc)
    end
    if ((newf and newf(o, ...)) or type(o) == "table") and not getmetatable(o) then
      setmetatable(o, nc)
    end
    if classDebugData then
      table.insert(classDebugData.instances, o)
    end
    return o
  end

  return nc
end

        util.subclass = function(super, nc, newf)
  nc = util.class(nc, newf)
  nc.super = super
  nc.__index = function(_, key)
    if not rawget(nc, key) then
      return super[key]
    end
  end

  return nc
end

        util.setupDestroyWatch = function()
  if not debugInstances then
    return 
  end
  for _,class in pairs(classes) do
    do
      local oldDestroy = class.class.destroy
      do
        if not oldDestroy then
          class.lacksDestroy = true
        end
        class.class.destroy = function(obj, ...)
    local instances = class.instances
    for i = #instances, 1, -1 do
      if instances[i] == obj then
        table.remove(instances, i)
      end
    end
    if oldDestroy then
      oldDestroy(obj, ...)
    end
    for i in pairs(obj) do
      obj[i] = nil
    end
  end

      end
    end
  end
end

        util.debugClasses = function()
  if not debugInstances then
    print("instance debug disabled")
    return 
  end
  table.sort(classes, function(a, b)
    do return a.name < b.name end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  for _,class in pairs(classes) do
    print(class.name .. ": " .. #class.instances .. (class.lacksDestroy and " [?]" or ""))
  end
end

      end
      local gui, fader = nil, nil
      do
        if player then
          local playerGui = player:WaitForChild("PlayerGui")
          util.backGui = Instance.new("ScreenGui", playerGui)
          util.backGui.Name = "BackGui"
          gui = Instance.new("ScreenGui", playerGui)
          gui.Name = "MainGui"
          util.gui = gui
          fader = Instance.new("Frame", gui)
          fader.Name = "FadeGui"
          fader.BorderSizePixel = 0
          fader.Size = UDim2.new(1, 0, 1, 60)
          fader.Position = UDim2.new(0, 0, 0, -40)
          fader.BackgroundTransparency = 1
          util.fadeGui = fader
          util.frontGui = Instance.new("ScreenGui", playerGui)
          util.frontGui.Name = "FrontGui"
          util.soundContainer = Instance.new("ScreenGui", playerGui)
          util.soundContainer.Name = "SoundContainer"
        end
        util.layerGuis = function(self)
  local playerGui = player:WaitForChild("PlayerGui")
  util.backGui.Parent = nil
  util.backGui.Parent = playerGui
  util.gui.Parent = playerGui
  util.frontGui.Parent = playerGui
end

        util.getHumanoid = function()
  local s, r = pcall(function()
    for _,h in pairs(player.Character:GetChildren()) do
      if h:IsA("Humanoid") then
        return h
      end
    end
  end
)
  if s and r then
    return r
  end
end

        util.isTouchDevice = function()
  local touchEnabled = false
  pcall(function()
    touchEnabled = userInputService.TouchEnabled
  end
)
  return touchEnabled
end

        util.isPhone = function()
  do return gui.AbsoluteSize.X <= 640 end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

        util.lerpCFrame = require(script.CFrameInterpolator)
        util.uid = require(script.Ascii85).uid
        util.Timing = Timing
        do
          local fds = require(script.FontDisplayService)
          util.Write = function(...)
  return fds:Write(...)
end

          do
            local httpService = game:GetService("HttpService")
            util.jsonEncode = function(...)
  return httpService:JSONEncode(...)
end

            util.jsonDecode = function(...)
  return httpService:JSONDecode(...)
end

            local tostring = tostring
            util.toId = function(thing)
  if thing and thing.id then
    thing = thing.id
  end
  return tostring(thing):lower():gsub("[^a-z0-9]+", "")
end

            util.split = function(str, sep)
  local arr = {}
  for sub in string.gmatch(str, "[^" .. sep .. "]+") do
    table.insert(arr, sub)
  end
  return arr
end

            local deepcopy = function(t)
  if type(t) ~= "table" then
    return t
  end
  local mt = getmetatable(t)
  local res = {}
  for k,v in pairs(t) do
    if type(v) == "table" then
      v = deepcopy(v)
    end
    res[k] = v
  end
  setmetatable(res, mt)
  return res
end

            util.deepcopy = deepcopy
            util.shallowcopy = function(t)
  local c = {}
  for k,v in pairs(t) do
    c[k] = v
  end
  return c
end

            util.trim = function(str)
  return str:match("^%s*(.-)%s*$")
end

            util.Create = function(instanceType)
  return function(data)
    local obj = Instance.new(instanceType)
    for k,v in pairs(data) do
      do
        local s, e = pcall(function()
      if type(k) == "number" then
        v.Parent = obj
      else
        if type(v) == "function" then
        obj[k]:Connect(v)
        else
          obj[k] = v
        end
      end
    end
)
        if not s then
          do
            error("Create: could not set property " .. k .. " of " .. instanceType .. " (" .. e .. ")", 2)
            -- DECOMPILER ERROR at PC27: LeaveBlock: unexpected jumping out IF_THEN_STMT

            -- DECOMPILER ERROR at PC27: LeaveBlock: unexpected jumping out IF_STMT

          end
        end
      end
    end
    return obj
  end

end

            util.FadeOut = function(duration, color, fn)
  fader.ZIndex = 10
  if not color then
    fader.BackgroundColor3 = Color3.new(0, 0, 0)
    local s = fader.BackgroundTransparency
    local e = 0
    util.Tween(duration, nil, function(a)
    fader.BackgroundTransparency = s + (e - s) * a
    if fn then
      fn(a)
    end
  end
)
  end
end

            util.FadeIn = function(duration, fn)
  local s = fader.BackgroundTransparency
  local e = 1
  util.Tween(duration, nil, function(a)
    fader.BackgroundTransparency = s + (e - s) * a
    if fn then
      fn(a)
    end
  end
)
end

            util.FadeOutWithCircle = function(duration, keepCircle)
  local create = util.Create
  local container = create("Frame")({BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 36), Position = UDim2.new(0, 0, 0, -36), Parent = util.frontGui})
  local scope = create("ImageLabel")({BackgroundTransparency = 1, Image = "rbxassetid://317129150", ZIndex = 9, Parent = container})
  local left = create("Frame")({BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0), ZIndex = 9, Parent = container})
  local right = create("Frame")({BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0), ZIndex = 9, Parent = container, Position = UDim2.new(1, 0, 0, 0)})
  local top = create("Frame")({BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0), ZIndex = 9, Parent = container})
  local bottom = create("Frame")({BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0), ZIndex = 9, Parent = container, Position = UDim2.new(0, 0, 1, 0)})
  util.Tween(duration or 0.6, nil, function(a)
    local x = container.AbsoluteSize.X * 1.42 * (1 - a)
    scope.Size = UDim2.new(0, x, 0, x)
    scope.Position = UDim2.new(0.5, -x / 2, 0.5, -x / 2)
    left.Size = UDim2.new(0.5, -x / 2 + 1, 1, 0)
    right.Size = UDim2.new(-0.5, x / 2 - 1, 1, 0)
    top.Size = UDim2.new(1, 0, 0.5, -x / 2 + 1)
    bottom.Size = UDim2.new(1, 0, -0.5, x / 2 - 1)
  end
)
  if keepCircle then
    return {container, scope, left, right, top, bottom}
  else
    fader.BackgroundColor3 = Color3.new(0, 0, 0)
    fader.BackgroundTransparency = 0
    container:Destroy()
  end
end

            util.FadeInWithCircle = function(duration, circle)
  local container, scope, left, right, top, bottom = unpack(circle)
  do
    if not container then
      local create = util.Create
      container = create("Frame")({BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 36), Position = UDim2.new(0, 0, 0, -36), Parent = util.frontGui})
      scope = create("ImageLabel")({BackgroundTransparency = 1, Image = "rbxassetid://317129150", ZIndex = 9, Parent = container})
      left = create("Frame")({BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0), ZIndex = 9, Parent = container})
      right = create("Frame")({BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0), ZIndex = 9, Parent = container, Position = UDim2.new(1, 0, 0, 0)})
      top = create("Frame")({BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0), ZIndex = 9, Parent = container})
      bottom = create("Frame")({BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0), ZIndex = 9, Parent = container, Position = UDim2.new(0, 0, 1, 0)})
      fader.BackgroundTransparency = 1
    end
    util.Tween(duration or 0.6, nil, function(a)
    local x = container.AbsoluteSize.X * 1.42 * a
    scope.Size = UDim2.new(0, x, 0, x)
    scope.Position = UDim2.new(0.5, -x / 2, 0.5, -x / 2)
    left.Size = UDim2.new(0.5, -x / 2 + 1, 1, 0)
    right.Size = UDim2.new(-0.5, x / 2 - 1, 1, 0)
    top.Size = UDim2.new(1, 0, 0.5, -x / 2 + 1)
    bottom.Size = UDim2.new(1, 0, -0.5, x / 2 - 1)
  end
)
    container:Destroy()
  end
end

            util.lookBackAtMe = function(t, leaveCameraScriptable)
  local cam = workspace.CurrentCamera
  local headP = player.Character.Head.Position
  local camGoal = CFrame.new(headP + cam.CFrame.Position - headP.unit * 12.5, headP)
  local _, lerp = util.lerpCFrame(cam.CFrame, camGoal)
  util.Tween(t or 0.8, "easeOutCubic", function(a)
    local cf = lerp(a)
    cam.CFrame = CFrame.new(cf.Position, cf.Position + cf.LookVector)
  end
)
  if not leaveCameraScriptable then
    cam.CameraType = Enum.CameraType.Custom
  end
end

            util.lookAt = function(p, f, t)
  local cam = workspace.CurrentCamera
  local ocf = cam.CFrame
  local dynamic = false
  local lerp = nil
  if type(f) == "function" then
    dynamic = true
  else
    lerp = select(2, util.lerpCFrame(ocf, CFrame.new(p, f)))
  end
  util.Tween(t or 0.8, "easeOutCubic", function(a)
    local cf = nil
    if dynamic then
      cf = select(2, util.lerpCFrame(ocf, CFrame.new(p, f(a))))(a)
    else
      cf = lerp(a)
    end
    cam.CFrame = CFrame.new(cf.Position, cf.Position + cf.LookVector)
  end
)
end

            do
              local threads = {}
              util.Teleport = function(newCF, torso)
  if not torso then
    torso = player.Character.HumanoidRootPart
  end
  local thisThread = {}
  threads[torso] = thisThread
  while torso and torso.Parent and (torso.Position - newCF.Position).magnitude > 5 and threads[torso] == thisThread do
    torso.CFrame = newCF
    task.wait()
  end
end

              util.TeleportToSpawnBox = function()
  util.Teleport(CFrame.new(3, 70, 389) + Vector3.new(math.random(-20, 20), 0, math.random(-20, 20)))
end

              util.Tween = function(duration, timing, fn)
  if duration == 0 then
    fn(1)
    return true
  end
  if type(timing) == "string" then
    timing = Timing[timing](duration)
  end
  local st = tick()
  fn(0)
  while 1 do
    stepped:Wait()
    local et = tick() - st
    if duration <= et then
      fn(1)
      return 
    end
    local a = et / duration
    if timing then
      a = timing(et)
    end
    if fn(a) == false then
      return false
    end
  end
  return true
end

              util.MoveModel = function(part, newcf, recursive)
  local MMRecursive = function(part, newcf, dm, r)
    local model = dm
    if not model then
      model = part.Parent
    end
    for _,p in pairs(model:GetChildren()) do
      if p ~= part and p:IsA("BasePart") and not p:IsA("Terrain") then
        p.CFrame = newcf:toWorldSpace(part.CFrame:toObjectSpace(p.CFrame))
      else
        if p:IsA("Model") and r then
          MMRecursive(part, newcf, p, true)
        end
      end
    end
    if not dm then
      part.CFrame = newcf
    end
  end

  MMRecursive(part, newcf, nil, recursive)
end

              util.findPartOnRayWithIgnoreFunction = function(ray, ignoreList, ignoreFunction)
  if type(ignoreList) == "function" then
    ignoreFunction = ignoreList
    ignoreList = {}
  end
  local raycastParams = RaycastParams.new()
  raycastParams.FilterType = Enum.RaycastFilterType.Exclude
  raycastParams.FilterDescendantsInstances = ignoreList
  local hit, pos, normal, material = nil, nil, nil, nil
  repeat
    local result = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
    hit = result and result.Instance
    if hit then
      pos = result.Position
      normal = result.Normal
      material = result.Material
      if ignoreFunction(hit) then
        table.insert(ignoreList, hit)
        raycastParams.FilterDescendantsInstances = ignoreList
      else
        return hit, pos, normal, material
      end
    end
  until not hit
  return hit, pos, normal, material
end

              util.Signal = function(debugOff)
  local sig = {}
  local mSignaler = (Instance.new("BindableEvent"))
  local mArgData, mArgDataCount = nil, nil
  sig.fire = function(self, ...)
    mArgData = {...}
    mArgDataCount = select("#", ...)
    mSignaler:Fire()
  end

  sig.connect = function(self, f)
    if not f then
      error("connect(nil)", 2)
    end
    return mSignaler.Event:Connect(function()
      f(unpack(mArgData, 1, mArgDataCount))
    end
)
  end

  sig.wait = function(self)
    mSignaler.Event:Wait()
    assert(mArgData, "Missing arg data, likely due to :TweenSize/Position corrupting threadrefs.")
    return unpack(mArgData, 1, mArgDataCount)
  end

  return sig
end

              util.fastSpawn = function(fn, ...)
  local sig = util.Signal(true)
  sig:connect(fn)
  sig:fire(...)
end

              util.extents = function(pos, size)
  local cam = workspace.CurrentCamera
  local cf = CFrame.new(pos, pos + cam.CFrame.LookVector)
  local p = cam:WorldToScreenPoint(pos)
  local p1 = cam:WorldToScreenPoint((cf * CFrame.new(-size / 2, -size / 2, 0)).Position)
  do
    local p2 = cam:WorldToScreenPoint((cf * CFrame.new(size / 2, size / 2, 0)).Position)
    do return Vector2.new(p.x, p.y), p1 - p2.magnitude / math.sqrt(2), p.z > 0 end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
end

              util.sound = function(id, volume, playFrom, destroyAfter)
  local sound = util.Create("Sound")({SoundId = type(id) == "number" and "rbxassetid://" .. id or id, Volume = volume or 0.5, TimePosition = playFrom or 0, Parent = util.soundContainer or workspace})
  sound:Play()
  task.delay(destroyAfter or 120, function()
    sound:Destroy()
  end
)
  return sound
end

              util.loopSound = function(id, volume)
  if id == 317469005 then
    volume = 0.7
  end
  local sound = util.Create("Sound")({SoundId = type(id) == "number" and "rbxassetid://" .. id or id, Volume = volume or 0.5, Looped = true, Parent = util.soundContainer or workspace})
  sound:Play()
  return sound
end

              util.weightedRandom = function(objects, getWeight, rand)
  if not rand then
    rand = math.random
  end
  local stuff = {}
  local totalWeight = 0
  for _,obj in pairs(objects) do
    local weight = getWeight(obj)
    table.insert(stuff, {obj, weight})
    totalWeight = totalWeight + weight
  end
  local r = rand() * (totalWeight)
  for _,thing in pairs(stuff) do
    if r <= thing[2] then
      return thing[1]
    end
    r = r - thing[2]
  end
  warn("! defaulting to last object in wtRdm")
  return stuff[#stuff][1]
end

              util.pageItemPairs = function(pages)
  return coroutine.wrap(function()
    local itemnum = 1
    local pagenum = 1
    while 1 do
      for _,item in ipairs(pages:GetCurrentPage()) do
        coroutine.yield(pagenum, itemnum, item)
        itemnum = itemnum + 1
      end
      if pages.IsFinished then
        break
      end
      pages:AdvanceToNextPageAsync()
      pagenum = pagenum + 1
    end
  end
)
end

              util.hsb = function(h, s, v)
  if s == 0 then
    return Color3.new(v, v, v)
  end
  h = h / 60
  local i = math.floor(h)
  local f = h - i
  local p = v * (1 - s)
  local q = v * (1 - s * f)
  local t = v * (1 - s * (1 - f))
  if i == 0 then
    return Color3.new(v, t, p)
  else
    if i == 1 then
      return Color3.new(q, v, p)
    else
      if i == 2 then
        return Color3.new(p, v, t)
      else
        if i == 3 then
          return Color3.new(p, q, v)
        else
          if i == 4 then
            return Color3.new(t, p, v)
          end
        end
      end
    end
  end
  return Color3.new(v, p, q)
end

              util.comma_value = function(n)
  local left, num, right = string.match(n, "^([^%d]*%d)(%d*)(.-)$")
  return left .. num:reverse():gsub("(%d%d%d)", "%1,"):reverse() .. right
end

              do
                local rc4 = require(script.RC4)("_=pLn.*0f-g@")
                util.rc4 = rc4
                util.rc4equal = function(x, y)
  local typeX = type(x)
  if typeX ~= type(y) then
    return false
  end
  if typeX == "table" then
    return x == y
  end
  return rc4(x) == rc4(y)
end

                util.exclaim = function(object)
  local create = util.Create
  local part = create("Part")({Size = Vector3.new(1, 1, 1), Anchored = true, CanCollide = false, Transparency = 1, CFrame = object.CFrame * CFrame.new(0, 2, 0), Parent = workspace})
  local bbg = create("BillboardGui")({Adornee = part, Parent = part})
  local exc = create("Frame")({BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0.2, 0), Parent = gui})
  util.Write("!")({Frame = exc, Scaled = true})
  exc.Parent = bbg
  exc.Size = UDim2.new(1, 0, 1, 0)
  local duration = 0.35
  util.Tween(duration, util.Timing.cubicBezier(duration, 0.85, 0, 0.6, 2), function(a)
    bbg.Size = UDim2.new(1.8, 0, 1.8 * a, 0)
  end
)
  wait(0.25)
  bbg:Destroy()
  part:Destroy()
end

                util.aOrAn = function(str, upper)
  local vowels = {a = true, e = true, i = true, o = true, u = true}
  if vowels[str:sub(1, 1):lower()] then
    return (upper and "An " or "an ") .. str
  else
    return (upper and "A " or "a ") .. str
  end
end

                util.map = function(t, fn)
  local newT = {}
  for k,v in pairs(t) do
    newT[k] = fn(v)
  end
  return newT
end

                util.Sync = function(fnList)
  local nFunctions = 0
  local nReturnedFunctions = 0
  local completionSignal = util.Signal()
  for _,fn in pairs(fnList) do
    do
      if type(fn) == "function" then
        do
          nFunctions = nFunctions + 1
          util.fastSpawn(function()
    fn()
    nReturnedFunctions = nReturnedFunctions + 1
    completionSignal:fire()
  end
)
          -- DECOMPILER ERROR at PC22: LeaveBlock: unexpected jumping out IF_THEN_STMT

          -- DECOMPILER ERROR at PC22: LeaveBlock: unexpected jumping out IF_STMT

        end
      end
    end
  end
  do
    while nReturnedFunctions < nFunctions do
      completionSignal:wait()
    end
  end
end

                util.print_r = function(t)
  local print_r_cache = {}
  local sub_print_r = function(t, indent)
    if print_r_cache[tostring(t)] then
      print(indent .. "*" .. tostring(t))
    else
      print_r_cache[tostring(t)] = true
      if type(t) == "table" then
        for pos,val in pairs(t) do
          if type(val) == "table" then
            print(indent .. "[" .. pos .. "] => " .. tostring(val) .. " {")
            sub_print_r(val, indent .. string.rep(" ", string.len(pos) + 8))
            print(indent .. string.rep(" ", string.len(pos) + 6) .. "}")
          else
            if type(val) == "string" then
              print(indent .. "[" .. pos .. "] => \"" .. val .. "\"")
            else
              print(indent .. "[" .. pos .. "] => " .. tostring(val))
            end
          end
        end
      else
        do
          print(indent .. tostring(t))
        end
      end
    end
  end

  if type(t) == "table" then
    print(tostring(t) .. " {")
    sub_print_r(t, "  ")
    print("}")
  else
    sub_print_r(t, "  ")
  end
  print()
end

                return util
              end
            end
          end
        end
      end
    end
  end
end

