--[[找图找色命令--]]

g_screenshotCache = {}
function getScreenshot()
	local key = coroutine.running()
	if key == nil then key = "main" end
	return g_screenshotCache[key]
end
function setScreenshot(bmp)
	local key = coroutine.running()
	if key == nil then key = "main" end
	g_screenshotCache[key] = bmp
end
function createScreenshot(screenWidth, screenHeight)
	local key = coroutine.running()
	if key == nil then key = "main" end
	if g_screenshotCache[key] then
		color.ReleaseBitmap(g_screenshotCache[key])
	end
	g_screenshotCache[key] = color.CaptureBitmap(0, 0, screenWidth, screenHeight)
end
function deleteScreenshot()
	local key = coroutine.running()
	if key == nil then key = "main" end
	if g_screenshotCache[key] then
		color.ReleaseBitmap(g_screenshotCache[key])
		g_screenshotCache[key] = nil
	end
end

-- 锁定当前屏幕画面,锁定后可保证连续几条找图找色命令对应的是同一图片,另外锁定后找图找色执行效率更高
function keepScreen(keep)	-- 参数表示当前要锁定还是解锁
	if keep then
		local w, h = getClientSize(g_boundWindowHandle)
		if not w then
			w = 2048
			h = 2048
		end
		createScreenshot(w, h)
	else
		deleteScreenshot()
	end
end

-- 屏幕画面锁定的情况下用于强制更新画面缓冲
function updateScreen()
	if getScreenshot() then
		keepScreen(false)
		keepScreen(true)
	end
end

g_pictureCache = {}
-- 找图命令,示例: findPicture(300, 0, 600, 200, "xxx.png", "C0C0C0", 1)
function findPicture(left, top, right, bottom, pic_file, color_mask, sim)
	local pic = g_pictureCache[pic_file]
	if not pic then
		pic = color.LoadBitmapFromFile(pic_file)	-- 此处加载的图片将不释放直到脚本结束,方便重复使用
		assert(pic, "加载图片失败，图片路径：%s", pic_file)
		g_pictureCache[pic_file] = pic
	end
	local r = color.FindPicture(getScreenshot(), left, top, right, bottom, pic, color_mask, sim, 1)
	if r and r ~= "" then
		return string.match(r, "(%d+)|(%d+)")
	end
	return false
end

-- 单点找色命令,示例: findColor(100, 100, 400, 300, "ffed03-101010|ffed90", 1)
function findColor(left, top, right, bottom, color_str, sim)
	local r = color.FindColor(getScreenshot(), left, top, right, bottom, color_str, sim, 1)
	if r and r ~= "" then
		return string.match(r, "(%d+)|(%d+)")
	end
	return false
end

-- 多点找色命令,示例: findColorEx(100, 100, 400, 300, "0|0|b6ffff,-24|-2|ffffff,-37|17|ffffff,-35|23|003a90", 1)
function findColorEx(left, top, right, bottom, color_array_str, sim)
	local r = color.FindColorEx(getScreenshot(), left, top, right, bottom, color_array_str, sim, 1, 1)
	if r and r ~= "" then
		return string.match(r, "(%d+)|(%d+)")
	end
	return false
end

-- 取指定像素的颜色值
function getPixelColor(x, y)
	return color.GetPixelColor(getScreenshot(), x, y)
end

-- 获取指定区域内特定颜色的像素数量,示例: getColorCount(200, 200, 300, 201, "000000|ffffff", 1)
function getColorCount(left, top, right, bottom, color_str, sim)
	local r1 = color.GetColorCount(getScreenshot(), left, top, right, bottom, color_str, sim)
	if r1 then return r1 end
	return 0
end

-- 判断指定坐标上是否是指定颜色,示例: isSimilarColor(345, 321, "ffffff", 1)
function isSimilarColor(x, y, color_str, sim)
	local r1 = color.IsSimilarColor(getScreenshot(), x, y, color_str, sim)
	if r1 and r1 == 1 then return true end
	return false
end

-- 截取屏幕区域并存成文件,示例: captureScreen(0, 0, 800, 600, "C:\\1.png")
function captureScreen(left, top, right, bottom, file_name, file_fmt)
	if not file_fmt then file_fmt = string.sub(file_name, -3) end
	return color.SaveBitmapToFile(getScreenshot(), left, top, right, bottom, file_name, file_fmt)
end

-- 将上一找图找色命令截屏信息保存成文件,主要用于除错,示例: saveLastCapture("C:\\1.png")
function saveLastCapture(file_name, file_fmt)
	if not file_fmt then file_fmt = string.sub(file_name, -3) end
	return color.SaveBitmapToFile(color.GetPreviousCapture(), 0, 0, 0, 0, file_name, file_fmt)
end

-- 获取上一次截屏或找图找色时捕获的图面
function getPreviousCapture()
	return color.GetPreviousCapture()
end

-- 查找屏幕上某字符串的坐标,只支持边缘锐利颜色单一的字体,示例: findString(0, 0, 800, 600, "确定", "XP宋体9号字") -- "XP宋体9号字"为字库名,字库需另外加载
function findString(left, top, right, bottom, str, dict)
	local r = color.FindString(getScreenshot(), left, top, right, bottom, str, dict, 1)
	if r and r ~= "" then
		return string.match(r, "(%d+)|(%d+)")
	end
	return false
end

-- 查找屏幕上某字符串的坐标,支持自定义字库,示例: findStringEx(0, 0, 800, 600, "掉线提示", "字体点阵字库", "ffffff-101010", 1)
function findStringEx(left, top, right, bottom, str, dict, color_str, sim)
	local r = color.FindStringEx(getScreenshot(), left, top, right, bottom, str, dict, color_str, sim, 1)
	if r and r ~= "" then
		return string.match(r, "(%d+)|(%d+)")
	end
	return false
end

-- 识别屏幕上的文本内容,示例: simpleOcr(0, 0, 800, 600, "XP宋体9号字", "ffffff", 1)
function simpleOcr(left, top, right, bottom, dict_name, color_str, sim)
	if not sim then sim = 1 end
	local s = color.SimpleOcr(getScreenshot(), left, top, right, bottom, dict_name, color_str, sim)
	if s then return string.gsub(s, "\r\n", "") end
	return ""
end

-- 识别屏幕上的文本内容并返回所有识别到的字符坐标,示例: simpleOcrEx(0, 0, 800, 600, "XP宋体9号字", "ffffff", 1, false)
function simpleOcrEx(left, top, right, bottom, dict_name, color_str, sim, check_space)
	if not sim then sim = 1 end
	local r = color.SimpleOcrEx(getScreenshot(), left, top, right, bottom, dict_name, color_str, sim, check_space)
	if r and r ~= "" then
		local tab = {}
		for i, v in ipairs(split(r, "\r\n")) do
			table.insert(tab, {string.match(r, "(%d+)|(%d+)|(.+)")})
		end
		return r, tab
	end
	return false
end

-- 加载找字和文字识别使用的字库
function loadOcrDict(dict_path, dict_name)
	local dict = file.getcontents(dict_path)
	assert(dict, "读取字库文件出错，文件名：%s", dict_path)
	local success = color.SetOcrDict(dict_name, 2, dict, "")
	assert(success, "加载字库出错，字库名：%s", dict_name)
end

----------------------------------------------------------------------
-- 以下命令只用于WIN32平台，ANDROID平台不支持
----------------------------------------------------------------------

function convertToBinaryDict(text_dict, log_font, binary_dict)
	assert(getUserVar("MicroServerName") == "", "无法转换，请关闭微端后再试")
	color.SetOcrDict("临时字库", 1, text_dict, log_font)
	color.SetOcrDict("临时字库", 4, binary_dict, "")
end

-- 获取当前光标的特征码
function getCursorShape()
	return color.GetCursorShape()
end 

-- 捕获并保存成GIF图像
function captureAndSaveWithGIF(x1, y1, x2, y2, frameDelay, totalFrames, saveFileName)
	return misc.CaptureAndSaveWithGIF(x1, y1, x2, y2, frameDelay, totalFrames, saveFileName)
end

