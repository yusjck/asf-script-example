script.LoadScript("base")
script.LoadScript("inputapi")
script.LoadScript("colorapi")
script.LoadScript("osapi")
script.LoadScript("device")
script.LoadScript("utils")

function test_popupBox()
	logPrint("开始全局弹窗测试")
	local startTime = getTickCount()
	msgBoxTimeout(3000, "全局弹窗测试")
	if getTickCount() - startTime < 100 then
		showMessage("全局弹窗测试失败")
		ePrint("全局弹窗测试失败")
		endScript()
	end
	logPrint("全局弹窗测试完成")
end

function test_touch()
	logPrint("开始触控测试")
	showMessage("按下HOME键")
	delay(500)
	home()
	delay(2000)

	showMessage("左划")
	delay(500)
	Touch:swipeLeft()
	delay(2000)

	showMessage("右划")
	delay(500)
	Touch:swipeRight()
	delay(1000)

	showMessage("下拉")
	delay(500)
	Touch:pullDown()
	delay(1000)
	
	showMessage("返回")
	delay(500)
	back()
	delay(1000)
	logPrint("触控测试完成")
end

function test_capture()
	logPrint("开始屏幕捕获测试")
	showMessage("截屏")
	local savePath = getScriptDir().."/test.png"
	if not Display:snapshot(savePath) then
		ePrint("屏幕捕获失败")
		showMessage("屏幕捕获测试未通过")
		endScript()
	end
	local f = file.open(savePath, "rb")
	local name = getSDCardPath().."/test.png"
	writeFile(name, f:read())
	f:close()
	local s = file.stat(savePath)
	showMessage("图片已保存到：%s，大小：%d", name, s.size)
	logPrint("屏幕捕获测试完成")
end

function test_findPicture()
	logPrint("开始搜索桌面Google Play图标")
	home()
	delay(1000)
	home()
	delay(1000)
	for i = 1, 3 do
		local appIcon = Display:findPicture(getScriptDir().."/pic/play.png", "C0C0C0", 0.85)
		if appIcon then
			showMessage("点击Play图标，坐标：%d,%d", appIcon.x, appIcon.y)
			delay(1000)
			logPrint("点击Play图标")
			appIcon:tap()
			break
		end
		Touch:swipeLeft()
		delay(1000)
	end
	logPrint("搜索桌面图标完成")
end

function test_readMemory()
	local targetAppName = getUserVar("注入目标")
	local pid = misc.GetProcessId(targetAppName)
	if not pid then
		msgBox("无法获取pid，请确保%s已在运行", targetAppName)
		endScript()
	end
	msgBox("目标进程pid为：%d", pid)
	if not memory.BindProcess(pid, 0) then
		msgBox("绑定进程失败")
		endScript()
	end
	local val = memory.ReadInteger("<libm.so>")
	msgBox("模块libm.so的首地址内存为：%08x", val)
	local res = memory.InvokeExtModule(getScriptDir().."/libcallhlp.so", "HelloWorld", "")
	if not res then
		msgBox("调用注入代码失败")
		endScript()
	end
	msgBox("调用注入代码完成，命令返回：%s", res)
end

function test_outputLog()
	logPrint("开始循环日志打印")
	for i = 1, 100 do
		logPrint("log output%d", i)
		delay(500)
	end
	logPrint("循环日志打印完成")
end

function main()
	if not requiresAsfVersion("1.5.3") then
		msgBox("asf版本过低，请更新后再试")
		endScript("failure")
	end

	local delayRun = tonumber(getUserVar("delay_run", "0"))
	if delayRun > 0 then
		logPrint("执行%d秒延迟", delayRun)
		delay(delayRun * 1000)
	end

	local touchMode = getUserVar("touch_mode")
	if touchMode == "2" then
		logPrint("使用root权限模拟")
		Touch:setMode(1)
	elseif touchMode == "1" then
		logPrint("使用无障碍手势模拟")
		Touch:setMode(2)
	end

	-- 初始化基于无障碍辅助的视图解析和手势模拟
	View:init()
	Touch:init()

	-- 解除设备息屏和锁定状态
	Device:init()
	Device:wakeAndUnlock()

	-- 尝试获取屏幕捕获权限并确认截屏功能可用
	Device:turnOnCapture()
	Display:init()

	local tasks = {
		{name="全局弹窗", func=test_popupBox},
		{name="触控模拟", func=test_touch},
		{name="屏幕捕获", func=test_capture},
		{name="图色识别", func=test_findPicture},
		{name="内存测试", func=test_readMemory},
		{name="日志输出测试", func=test_outputLog},
	}
	for _, task in ipairs(tasks) do
		if getUserVar(task.name) == "1" then
			task.func()
		end
	end
	logPrint("全部测试完成")
end

function onScriptExit()
	logPrint("Script exiting")
end

main()

