
Display = {Point={}}

function Display:init()
	if not isCaptureAvailable() then
		if not runAsRoot() then
			ePrint("screen capture not available")
			endScript("failure")
		end
		logPrint("screen capture by minicap")
		sendDeviceCmd("SetCaptureMode", "minicap")
	end
	local width, height = self:getSize()
	logPrint("screen resolution: %dx%d", width, height)
end

function Display:newBounds(left, top, right, bottom)
	local display = {bounds={}}
	setmetatable(display, self)
	self.__index = self
	display.bounds.left, display.bounds.top = left, top
	display.bounds.right, display.bounds.bottom = right, bottom
	return display
end

function Display:getBounds()
	if not self.bounds then
		local displayInfo = getDeviceInfo("DisplayInfo")
		self.bounds = {}
		self.bounds.left, self.bounds.top = 0, 0
		self.bounds.right, self.bounds.bottom = string.match(displayInfo, "width=(%d+),height=(%d+).+")
	end
	return self.bounds.left, self.bounds.top, self.bounds.right, self.bounds.bottom
end

function Display:getWidth()
	local left, _, right, _ = self:getBounds()
	return right - left
end

function Display:getHeight()
	local _, top, _, bottom = self:getBounds()
	return bottom - top
end

function Display:getSize()
	local left, top, right, bottom = self:getBounds()
	return right - left, bottom - top
end

function Display.Point:new(x, y)
	local point = {}
	setmetatable(point, self)
	self.__index = self
	point.x, point.y = x, y
	return point
end

function Display.Point:tap(offsetX, offsetY)
	if not offsetX then offsetX = 0 end
	if not offsetY then offsetY = 0 end
	Touch:tap(self.x + offsetX, self.y + offsetY)
end

function Display:snapshot(file_name, file_fmt)
	local left, top, right, bottom = self:getBounds()
	return captureScreen(left, top, right, bottom, file_name, file_fmt)
end

function Display:findPicture(pic_file, color_mask, sim)
	local left, top, right, bottom = self:getBounds()
	local x, y = findPicture(left, top, right, bottom, pic_file, color_mask, sim)
	if x then
		return self.Point:new(x, y)
	end
end

function Display:findColor(color_str, sim)
	local left, top, right, bottom = self:getBounds()
	local x, y = findColor(left, top, right, bottom, color_str, sim)
	if x then
		return self.Point:new(x, y)
	end
end

function Display:findColorEx(color_array_str, sim)
	local left, top, right, bottom = self:getBounds()
	local x, y = findColorEx(left, top, right, bottom, color_array_str, sim)
	if x then
		return self.Point:new(x, y)
	end
end

function Display:getColorCount(color_str, sim)
	local left, top, right, bottom = self:getBounds()
	return getColorCount(left, top, right, bottom, color_str, sim)
end

function Display:findString(str, dict)
	local left, top, right, bottom = self:getBounds()
	local x, y = findString(left, top, right, bottom, str, dict)
	if x then
		return self.Point:new(x, y)
	end
end

function Display:findStringEx(str, dict, color_str, sim)
	local left, top, right, bottom = self:getBounds()
	local x, y = findStringEx(left, top, right, bottom, str, dict, color_str, sim)
	if x then
		return self.Point:new(x, y)
	end
end

function Display:simpleOcr(dict_name, color_str, sim)
	local left, top, right, bottom = self:getBounds()
	return simpleOcr(left, top, right, bottom, dict_name, color_str, sim)
end

function Display:simpleOcrEx(dict_name, color_str, sim, check_space)
	local left, top, right, bottom = self:getBounds()
	return simpleOcrEx(left, top, right, bottom, dict_name, color_str, sim, check_space)
end

View = {}

function View:init()
	if not isAccessibilityAvailable() then
		logPrint("accessibility service not available")
		endScript("failure")
	end
end

function View:new(node, parent)
	setmetatable(node, self)
	self.__index = self
	node.parent = parent
	if not node.text then
		node.text = node.desc
	end
	return node
end

-- ??????view????????????
function View:getInfo()
	return getViewInfo(self.handle)
end

-- ??????view
function View:click()
	local node = self
	repeat
		if node.clickable then
			break
		end
		node = node.parent
	until not node
	if not node then
		node = self
	end
	clickView(node.handle)
end

-- ?????????view
function View:longClick()
	local node = self
	repeat
		if node.clickable then
			break
		end
		node = node.parent
	until not node
	if not node then
		node = self
	end
	longClickView(node.handle)
end

function View:tap()
	Touch:tap(self.x, self.y)
end

-- ??????view????????????
function View:getRootNode()
	local function convertToObject(node, parent)
		node = self:new(node, parent)
		if node.children then
			for _, v in ipairs(node.children) do
				convertToObject(v, node)
			end
		end
	end
	local viewsInfo = getViewsInfo()
	if viewsInfo then
		local rootNode = cjson.decode(viewsInfo)
		convertToObject(rootNode)
		return rootNode
	end
	return nil
end

function View:enumNodeTree(node, isFoundFunc)
	if isFoundFunc(node) then
		return node
	end
	if node.children then
		for i = 1, #node.children do
			local found = self:enumNodeTree(node.children[i], isFoundFunc)
			if found then
				return found
			end
		end
	end
	return nil
end

function View:find(isFoundFunc)
	local rootNode = self.handle and self or self:getRootNode()
	if rootNode then
		return self:enumNodeTree(rootNode, isFoundFunc)
	end
end

function View:findByRule(rule)
	return self:find(function(node)
		if rule.clickable and node.clickable ~= rule.clickable then
			return false
		end
		if rule.id and node.id == rule.id then
			return true
		end
		if rule.text and node.text == rule.text then
			return true
		end
		if node.text and rule.textRules then
			local textRules = split(rule.textRules, "|")
			for _, v in ipairs(textRules) do
				if string.find(node.text, v) then
					return true
				end
			end
		end
		return false
	end)
end

function View:findByPos(x, y, clickable)
	local rootNode = self.handle and self or self:getRootNode()
	if rootNode then
		local foundNode, lastNodeDistance
		self:enumNodeTree(rootNode, function(node)
			if clickable and node.clickable ~= clickable then
				return false
			end
			local dist = math.sqrt(math.pow(node.x - x, 2) + math.pow(node.y - y, 2))
			if not lastNodeDistance or dist < lastNodeDistance then
				foundNode = node
				lastNodeDistance = dist
			end
			return false
		end)
		return foundNode
	end
end

function view(rule)
	local finder = {}
	finder.findOne = function(self, timeout)
		local v
		repeat
			v = View:findByRule(self.rule)
			if v then break end
			if not timeout or timeout == 0 then break end
			local delayTime = timeout > 500 and 500 or timeout
			delay(delayTime)
			timeout = timeout - delayTime
		until false
		return v
	end
	finder.getOne = function(self, timeout)
		local v = self:findOne(timeout)
		if not v then
			throw("view not found")
		end
		return v
	end
	finder.rule = rule
	return finder
end

Touch = {}

function Touch:init()
	if runAsRoot() then
		self.mode = 1
	else
		if not isAccessibilityAvailable() then
			ePrint("accessibility service not available")
			endScript("failure")
		end
		self.mode = 2
	end
	local displayInfo = getDeviceInfo("DisplayInfo")
	self.screenWidth, self.screenHeight = string.match(displayInfo, "width=(%d+),height=(%d+).+")
end

function Touch:setMode(mode)
	assert(mode ~= 1 and mode ~= 2, "invalid touch mode")
	self.mode = mode
end

function Touch:transformXY(x, y)
	if x > 0 and x < 1 then
		x = self.screenWidth * x
	end
	if y > 0 and y < 1 then
		y = self.screenHeight * y
	end
	return x, y
end

function Touch:tap(x, y)
	x, y = self:transformXY(x, y)
	if self.mode == 1 then
		touchTap(x, y)
	elseif self.mode == 2 then
		tap(x, y)
	end
end

function Touch:swipe(x1, y1, x2, y2, duration)
	x1, y1 = self:transformXY(x1, y1)
	x2, y2 = self:transformXY(x2, y2)
	if self.mode == 1 then
		touchSwipe(x1, y1, x2, y2, duration)
	elseif self.mode == 2 then
		swipe(x1, y1, x2, y2, duration)
	end
end

function Touch:pullDown()
	self:swipe(0.5, 0.01, 0.5, 0.5, 300)
end

function Touch:swipeUp()
	self:swipe(0.5, 0.8, 0.5, 0.2, 300)
end

function Touch:swipeDown()
	self:swipe(0.5, 0.2, 0.5, 0.8, 300)
end

function Touch:swipeLeft()
	self:swipe(0.85, 0.7, 0.15, 0.7, 200)
end

function Touch:swipeRight()
	self:swipe(0.15, 0.7, 0.85, 0.7, 200)
end

