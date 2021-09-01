
-- 结束脚本运行
-- 参数quitReason可忽略，字符串类型，有效值为completion/failure/pending
function endScript(quitReason)
	script.AbortScript(quitReason)
end

-- 重启脚本
function resetScript()
	logPrint("[重启脚本]")
	script.ResetScript()
	logPrint("[停止脚本]")
	script.AbortScript()
end

-- 打印日志
function logPrint(...)
	-- 参数分别为：日志内容，显示颜色，是否记录到日志文件中
	script.LogPrint(string.format(...), nil, false)
end

-- 打印警告
function wPrint(...)
	script.LogPrint(string.format(...), 0xff0000)
end

-- 打印错误
function ePrint(...)
	script.LogPrint(string.format(...), 0x0000ff)
end

-- 显示消息框提示
function msgBox(...)
	local msg = string.format(...)
	if string.len(msg) > 40960 then
		msg = string.sub(msg, 0, 40960).."..."
	end
	misc.MsgBox(msg)
end

-- 显示带超时自动关闭的消息框（毫秒）
function msgBoxTimeout(timeout, ...)
	misc.MsgBox(string.format(...), timeout)
end

-- 调试断言
function assert(b, ...)
	if not b then
		if getSystemInfo(4) == "dev" then
			msgBox(...)
			endScript()
		else
			ePrint(...)
			resetScript()
		end
	end
end

-- 返回脚本文件存放目录
-- pathType: 0.相对路径, 1.绝对路径
function getScriptDir(pathType)
	return script.GetScriptDir(pathType)
end

-- 返回临时文件存放目录
-- pathType: 0.相对路径, 1.绝对路径
function getTempDir(pathType)
	return script.GetTempDir(pathType)
end

-- 获取共享变量，该变量可在多个不同脚本间共享，脚本退出后仍保留
function getShareVar(key, defaultValue)
	local value = script.GetShareVar(key, "")
	if value == "" then
		return defaultValue
	end
	return cjson.decode(value)
end

-- 设置共享变量
function setShareVar(key, value)
	value = cjson.encode(value)
	return script.SetShareVar(key, value)
end

-- 获取用户变量
function getUserVar(key, defaultValue)
	return script.GetUserVar(key, defaultValue)
end

-- 调用一个外部程序
function runApp(appName, param, waitExit)
	if param == nil then param = "" end
	return misc.RunApp(appName, param, 0, waitExit)
end

-- 结束指定进程，示例：killApp(1024),killApp("com.xxx.xxx")
function killApp(pidOrName)
	if type(pidOrName) == "number" then
		return misc.KillApp(pidOrName, nil)
	else
		return misc.KillApp(0, pidOrName)
	end
end

-- 使用Base64进行解码
function fromBase64(base64_txt)
	return misc.FromBase64(base64_txt)
end

-- 使用Base64进行编码
function toBase64(msg)
	return misc.ToBase64(msg)
end

-- 分割字符串
function split(str, delim)
	local start = 1
	local spt = {} 
	repeat
		local s, e = string.find(str, delim, start, true)
		if s then 
			table.insert(spt, string.sub(str, start, s - 1))
			start = e + 1
		end 
	until not s
	table.insert(spt, string.sub(str, start))	-- insert final one (after last delimiter)
	return spt
end

-- 移除字符串头尾空格
function trim(str)
	return string.gsub(str, "^%s*(.-)%s*$", "%1")
end

function isAssignmentExpression( str )
	local i = 1;
	local curChar;
	local quotesType = "none" -- none, single or double
	local isEscaping = false
	curChar = string.sub( str, 1, 1 )
	while ( curChar ~= "" ) do
		if ( curChar == "'" and
			 isEscaping == false and
			 quotesType ~= "double" )
		then
			if ( quotesType == "single" )
			then quotesType = "none"
			elseif ( quotesType == "none" )
			then quotesType = "single"
			end
		end
		if ( curChar == "\"" and
			 isEscaping == false and
			 quotesType ~= "single" )
		then
			if ( quotesType == "double" )
			then quotesType = "none"
			elseif ( quotesType == "none" )
			then quotesType = "double"
			end
		end
		if ( curChar == "\\" and isEscaping == false )
		then isEscaping = true
		else isEscaping = false
		end
		if ( curChar == "=" and quotesType == "none" )
		then
			if ( string.sub( str, i+1, i+1 ) ~= "=" )
			then
				return true, string.sub( str, 1, i - 1 )
			else
				return false
			end
		end
		i = i + 1
		curChar = string.sub( str, i, i )
	end
 
	return false
end

-- 执行动态脚本代码，示例：s = "msgBox('hello')" eval(s)
function eval( str )
	local bAssign
	local var
	bAssign, var = isAssignmentExpression( str )
	if ( bAssign )
	then
		print( "Assignment, var=" .. var )
		loadstring( str )()
		return loadstring( "return " .. var )()
	else
		return loadstring( "return " .. str )()
	end
end

-- 判断表中是否存在指定值
function table.contains(tab, value)
	for _, v in pairs(tab) do
		if v == value then
			return true
		end
	end
	return false
end

-- 通过比较函数从表中搜索指定元素
function table.find(tab, comp)
	for _, v in pairs(tab) do
		if comp(v) then
			return v
		end
	end
	return false
end

-- 对表进行拷贝
function table.clone(orig)
	local copy = {}
	for orig_key, orig_value in pairs(orig) do
		copy[orig_key] = orig_value
	end
	return copy
end

-- 对表进行深度拷贝
function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

-- 读取文件内容
function file.getcontents(filename)
	if file.open(filename, "rb") then
		local contents = file.read()
		file.close()
		return contents
	end
	return false
end

-- 写入到文件中
function file.putcontents(filename, contents)
	if file.open(filename, "wb") then
		file.write(contents)
		file.close()
		return true
	end
	return false
end

-- 追加到文件中
function file.appendcontents(filename, contents)
	if file.open(filename, "ab+") then
		file.write(contents)
		file.close()
		return true
	end
	return false
end

-- 返回操作系统启动以来经过的毫秒数
function getTickCount()
	return misc.GetTickCount()
end

-- 向挂机设备发送命令
-- cmd：1.PowerOff, 2.Reboot
function sendDeviceCmd(cmd, args)
	return misc.SendDeviceCmd(cmd, args)
end

-- 获取挂机设备信息
-- infoClass: 1.DisplayInfo, 2.DeviceId, 3.UserId
function getDeviceInfo(infoClass)
	return misc.GetDeviceInfo(infoClass)
end

g_timerList = {}

-- 设置/修改定时器
function setTimer(timerName, timerFunc, runOnce, interval)
	assert(timerName, "invalid timer name")
	cancelTimer(timerName)
	local timer = {timerName=timerName, interval=interval, timerFunc=timerFunc, runOnce=runOnce, nextRunTime=getTickCount() + interval}
	table.insert(g_timerList, timer)
	table.sort(g_timerList, function(a, b) return a["nextRunTime"] < b["nextRunTime"] end)
	return timerName
end

-- 取消已设置的定时器
function cancelTimer(timerName)
	for i, v in ipairs(g_timerList) do
		if v["timerName"] == timerName then
			table.remove(g_timerList, i)
			return true
		end
	end
	return false
end

function checkTimer()
	local now = getTickCount()
	while table.getn(g_timerList) > 0 do
		local timer = g_timerList[1]
		if timer["nextRunTime"] > now then
			break
		end
		-- 从列表中移除即将执行的定时器
		table.remove(g_timerList, 1)
		-- 执行定时器例程
		timer["timerFunc"]()
		now = getTickCount()
		if not timer["runOnce"] then
			-- 非只执行一次的定时器需重新加入定时器列表并设置下一次执行时间
			timer["nextRunTime"] = now + timer["interval"]
			table.insert(g_timerList, timer)
			-- 将运行时间最近的定时器排在列表最前面
			table.sort(g_timerList, function(a, b) return a["nextRunTime"] < b["nextRunTime"] end)
		end
	end
	if table.getn(g_timerList) == 0 then
		return false
	end
	return g_timerList[1]["nextRunTime"] - now
end

-- 延迟执行（毫秒）
function delay(n)
	repeat
		local elapsedTime = getTickCount()
		local nextTimerInterval = checkTimer()
		elapsedTime = getTickCount() - elapsedTime
		if n <= elapsedTime then
			break
		end
		n = n - elapsedTime
		if not nextTimerInterval or n < nextTimerInterval then
			script.Delay(n)
			break
		else
			script.Delay(nextTimerInterval)
			n = n - nextTimerInterval
		end
	until n == 0
end

-- 注册脚本退出函数
event.RegisterCallback("ScriptExit", function()
	if type(onScriptExit) == "function" then
		onScriptExit()
	end
	runEventCallback("ScriptExit")
	if script.IsUserAbort() then
		-- 当用户中断脚本时调用已注册的回调
		runEventCallback("UserAbort")
	end
end)

g_callbackList = {}

-- 注册一个事件回调函数用于监听指定类型的事件
-- eventType:
--			1.ScriptExit
--			2.UserAbort
--			3.ThrowExcept
function registerCallback(cbName, eventType, cbFunc)
	g_callbackList[cbName] = {eventType=eventType, cbFunc=cbFunc}
end

-- 根据名称删除已注册的回调函数
function unregisterCallback(cbName)
	g_callbackList[cbName] = nil
end

-- 运行所有指定类型的回调函数
function runEventCallback(eventType)
	for _, v in pairs(g_callbackList) do
		if v.eventType == eventType then
			v.cbFunc()
		end
	end
end

-- 捕获保护模式下脚本主动抛出的异常并将异常信息返回给保护模式的调用者
function __except__(errmsg)
	local msg = string.match(errmsg, "[^:]+:%d+: (.+)")
	if msg == "interrupted!" then
		-- 处理终止脚本命令
		return "throw:"..msg
	end
	-- 判断是不是通过throw()抛出的异常
	if debug.getinfo(3).name == "throw" then
		-- 返回throw的参数
		return "throw:"..msg
	end
	-- 返回异常发生时的调用栈
	return debug.traceback(tostring(errmsg), 2)
end

-- 在保护模式中调用指定函数
function trycall(func, ...)
	local args = { ... }
	local status, err = xpcall(function() func(unpack(args)) end, __except__)
	if not status then
		if string.sub(err, 1, 6) == "throw:" then
			local msg = string.sub(err, 7)
			if msg == "interrupted!" then
				error(msg)
			end
			runEventCallback("ThrowExcept")
			-- 主动抛出的异常返回给调用者
			return false, msg
		else
			-- 非主动抛出的异常直接报错
			error(err)
		end
	end
	return true
end

-- 保护模式下通过抛出异常来退出顶层函数
-- 注意：该函数只能在保护模式下使用
function throw(errmsg)
	error(errmsg and errmsg or "none")
end

----------------------------------------------------------------------
-- 以下命令只用于WIN32平台，ANDROID平台不支持
----------------------------------------------------------------------

-- 进入临界区，保证特定代码只有一个脚本在执行
-- name 临界区名
-- timeout 设置进入超时，单位：毫秒（可选）
function namedLockEnter(name, timeout)
	return script.NamedLockEnter(name, timeout)
end

-- 退出临界区
function namedLockLeave(name)
	return script.NamedLockLeave(name)
end

-- 获取用户按下按键的虚拟键码
-- timeout 指定等待超时时间，为0时不等待立即返回 单位：毫秒（可选，不使用该参数相当于永久等待）
function waitKey(time_out)
	if time_out then
		return misc.WaitKey(time_out)
	else
		return misc.WaitKey()
	end
end

-- 等待用户按下指定列表中的按键
-- time_out 同上
function waitMultiKey(key_list, time_out)
	if time_out then
		local cur_time = getTickCount()
		local end_time = cur_time + time_out
		repeat
			local vk = waitKey(end_time - cur_time)
			if not vk then return false end
			for i, v in ipairs(key_list) do
				if vk == v[1] then
					return v[2]
				end
			end
			cur_time = getTickCount()
		until cur_time >= end_time
		return false
	else
		repeat
			local vk = waitKey()
			if not vk then return false end
			for i, v in ipairs(key_list) do
				if vk == v[1] then
					return v[2]
				end
			end
		until false
	end
end

-- 取执行器版本和用户注册信息
-- class：	0.获取软件ID
--			1.获取从服务器端获取的脚本激活信息
--			2.获取当前脚本实例的唯一ID（不会与当前运行的其它脚本实例重复，但重启执行器后可能会发生变化）
--			3.获取执行器命令版本
--			4.当前运行模式，dev（开发版）,trial（试用版）,full（正式版）
--			5.保留
--			6.获取执行器外壳版本，v1（玩家单开版），v2（工作室多开版，可连接微端客户端），v4（通用单开版，可作为微端客户端），ex（开发版）
--			7.获取从用户启动后脚本自动重启次数
function getSystemInfo(class)
	if not script.GetSystemInfo then
		return nil
	end
	return script.GetSystemInfo(class)
end

-- 发送本地图片到答题服务器
-- question_type：
--			0.填空题
--			1.选择题
--			2.坐标题
-- timeout 发送超时设置（秒）
function sendImage(img_path, server_addr, question_type, timeout)
	return misc.SendImage(img_path, server_addr, question_type, timeout)
end

-- 读取INI中的配置信息
-- secondName 设为nil可获取所有节名，使用“\n”隔开
-- keyName 设为nil可获取节中所有键名，使用“\n”隔开
-- defaultValue INI不存在或字段无效时返回该值
function readINI(secondName, keyName, defaultValue, iniPath)
	return misc.ReadINI(secondName, keyName, defaultValue, iniPath)
end

-- 修改INI中的配置信息
-- keyName 设为nil可将整个节删除
-- value 设为nil可删除当前键和值
function writeINI(secondName, keyName, value, iniPath)
	if not file.exists(iniPath) then
		-- 创建UNICODE编码的INI文件，防止乱码
		file.putcontents(iniPath, string.char(0xff, 0xfe))
	end
	return misc.WriteINI(secondName, keyName, value, iniPath)
end

