
-- 判断当前是否以root权限运行
function runAsRoot()
	return getDeviceInfo("UserId") == "0"
end

-- 获取屏幕显示信息
function getDisplayInfo()
	local res = cjson.decode(sendDeviceCmd("device.getDisplayInfo", "[]"))["result"]
	return cjson.decode(res)
end

-- 获取设备的品牌
function getBrand()
	return cjson.decode(sendDeviceCmd("device.getBrand", "[]"))["result"]
end

-- 获取设备的型号
function getModel()
	return cjson.decode(sendDeviceCmd("device.getModel", "[]"))["result"]
end

-- 获取设备的IMEI
function getIMEI()
	return cjson.decode(sendDeviceCmd("device.getIMEI", "[]"))["result"]
end

-- 返回当前连接的Wifi网络名称
function getWifiSSID()
	return string.sub(cjson.decode(sendDeviceCmd("device.getWifiSSID", "[]"))["result"], 2, -2)
end

-- 获取SD存储路径
function getSDCardPath()
	return cjson.decode(sendDeviceCmd("device.getSDCardPath", "[]"))["result"]
end

-- 返回设备是否已锁定
function isDeviceLocked()
	return cjson.decode(sendDeviceCmd("device.isDeviceLocked", "[]"))["result"]
end

-- 返回屏幕是否亮着
function isScreenOn()
	return cjson.decode(sendDeviceCmd("device.isScreenOn", "[]"))["result"]
end

-- 唤醒手机
function wakeUp()
	sendDeviceCmd("device.wakeUp", '[]')
end

-- 使屏幕保持开启状态，参数：保持开启时长（毫秒）
function keepScreenOn(timeout)
	local args = {timeout}
	sendDeviceCmd("device.keepScreenOn", cjson.encode(args))
end

-- 取消使屏幕保持开启状态
function cancelKeepingAwake()
	sendDeviceCmd("device.cancelKeepingAwake", '[]')
end

-- 设备振动，参数：持续时长（毫秒）
function vibrate(duration)
	local args = {duration}
	sendDeviceCmd("device.vibrate", cjson.encode(args))
	delay(duration)
end

-- 停止振动
function cancelVibration()
	sendDeviceCmd("device.cancelVibration", '[]')
end

-- 显示toast提示信息
function showMessage(...)
	local args = {string.format(...)}
	sendDeviceCmd("system.showMessage", cjson.encode(args))
end

-- 使用通知栏向用户推送消息
function pushNotification(...)
	local args = {string.format(...)}
	sendDeviceCmd("system.pushNotification", cjson.encode(args))
end

-- 移除推送的消息
function removeNotification()
	sendDeviceCmd("system.removeNotification", '[]')
end

-- 检查当前执行器版本是否满足运行当前脚本的最低要求
function requiresAsfVersion(targetVersion)
	local currentVersion = cjson.decode(sendDeviceCmd("system.getAsfVersion", "[]"))["result"]
	if currentVersion == "" then
		return false
	end
	currentVersion = split(currentVersion, ".")
	targetVersion = split(targetVersion, ".")
	for i = 1, 3 do
		if tonumber(currentVersion[i]) > tonumber(targetVersion[i]) then
			return true
		end
		if tonumber(currentVersion[i]) < tonumber(targetVersion[i]) then
			return false
		end
	end
	return true
end

-- 获取SDK版本
function getSdkInt()
	return cjson.decode(sendDeviceCmd("system.getSdkInt", "[]"))["result"]
end

-- 设备是否已root
function haveRoot()
	return cjson.decode(sendDeviceCmd("system.haveRoot", "[]"))["result"]
end

-- 判断当前界面是否是桌面
function isHome()
	return cjson.decode(sendDeviceCmd("system.isHome", "[]"))["result"]
end

-- 检测屏幕捕获功能是否可用，要求安卓5.0以上系统
function isCaptureAvailable()
	return cjson.decode(sendDeviceCmd("system.isCaptureAvailable", "[]"))["result"]
end

-- 检测无障碍服务是否可用
function isAccessibilityAvailable()
	return cjson.decode(sendDeviceCmd("system.isAccessibilityAvailable", "[]"))["result"]
end

-- 打开新的活动
function startActivity(uri)
	local args = {uri}
	local res = sendDeviceCmd("system.startActivity", cjson.encode(args))
	return cjson.decode(res)["result"]
end

-- 检测指定APP是否已安装
function checkAppInstalled(pkgName)
	local args = {pkgName}
	local res = sendDeviceCmd("system.checkAppInstalled", cjson.encode(args))
	return cjson.decode(res)["result"]
end

-- 启动APP
function startApp(pkgName, clsName)
	local args = {pkgName, clsName and clsName or ""}
	local res = sendDeviceCmd("system.startApp", cjson.encode(args))
	return cjson.decode(res)["result"]
end

-- 结束后台APP
function killBackgroundApp(pkgName)
	local args = {pkgName}
	sendDeviceCmd("system.killBackgroundApp", cjson.encode(args))
end

-- 获取剪贴板中的文本
function getClipText()
	return cjson.decode(sendDeviceCmd("system.getClipText", "[]"))["result"]
end

-- 设置剪贴板
function setClipText(text)
	local args = {text}
	sendDeviceCmd("system.setClipText", cjson.encode(args))
end

-- 读取文件
function readFile(filePath)
	local args = {filePath}
	local enc_file = cjson.decode(sendDeviceCmd("system.readFile", cjson.encode(args)))["result"]
	return misc.FromBase64(enc_file)
end

-- 写入文件，成功返回true
function writeFile(filePath, content)
	local args = {filePath, misc.ToBase64(content)}
	return cjson.decode(sendDeviceCmd("system.writeFile", cjson.encode(args)))["result"]
end

-- 使用HTTP GET获取数据
function httpGet(url)
	local args = {url}
	return cjson.decode(sendDeviceCmd("net.httpGet", cjson.encode(args)))["result"]
end

-- 使用HTTP POST向服务器提交数据
function httpPost(url, content)
	local args = {url, content}
	return cjson.decode(sendDeviceCmd("net.httpPost", cjson.encode(args)))["result"]
end

-- 检查无障碍服务是否可用
function checkAccessibility()
	return cjson.decode(sendDeviceCmd("accessibility.isServiceAvailable", "[]"))["result"]
end

-- 返回屏幕上所有view信息
function getViewsInfo()
	for i = 1, 6 do
		local res = sendDeviceCmd("accessibility.getViewsInfo", "[]")
		if res then
			return cjson.decode(res)["result"]
		end
		delay(500)
	end
	return nil
end

-- 返回指定view信息
function getViewInfo(handle)
	return sendDeviceCmd("accessibility.getViewInfo", cjson.encode({handle}))
end

-- 点击view
function clickView(handle)
	if handle then
		sendDeviceCmd("accessibility.clickView", cjson.encode({handle}))
	else
		sendDeviceCmd("accessibility.clickView", "[]")
	end
end

-- 长点击view
function longClickView(handle)
	if handle then
		sendDeviceCmd("accessibility.longClickView", cjson.encode({handle}))
	else
		sendDeviceCmd("accessibility.longClickView", "[]")
	end
end

-- 模拟手势
function gesture(path, duration)
	local points = cjson.encode(path)
	local args = {20, duration, points}
	sendDeviceCmd("accessibility.gesture", cjson.encode(args))
end

-- 模拟坐标点击
function tap(x, y)
	gesture({{x, y}}, 20)
end

-- 模拟划动
function swipe(x1, y1, x2, y2, duration)
	gesture({{x1, y1}, {x2, y2}}, duration)
end

-- 模拟返回操作
function back()
	sendDeviceCmd("accessibility.back", "[]")
end

-- 模拟回桌面
function home()
	sendDeviceCmd("accessibility.home", "[]")
end

-- 模拟下划操作
function scrollBackward()
	sendDeviceCmd("accessibility.scrollBackward", "[]")
end

-- 模拟上划操作
function scrollForward()
	sendDeviceCmd("accessibility.scrollForward", "[]")
end

-- 往查找到的编辑框里输入文本
function inputText(text)
	local args = {text}
	sendDeviceCmd("accessibility.inputText", cjson.encode(args))
end

