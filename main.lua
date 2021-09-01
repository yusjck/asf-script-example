script.LoadScript("base")
script.LoadScript("inputapi")
script.LoadScript("colorapi")
script.LoadScript("osapi")
script.LoadScript("device")
script.LoadScript("utils")

function 全局弹窗测试()
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

function 触控测试()
	logPrint("开始触控测试")
	showMessage("按下HOME键")
	delay(500)
	home()
	delay(2000)

	showMessage("左滑")
	delay(500)
	Touch:swipeLeft()
	delay(2000)

	showMessage("右滑")
	delay(500)
	Touch:swipeRight()
	delay(1000)

	showMessage("下拉")
	delay(500)
	Touch:pullDown()
	delay(1000)
	
	showMessage("返回")
	back()
	delay(1000)
	logPrint("触控测试完成")
end

function 屏幕捕获测试()
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

function 搜索QQ图标()
	logPrint("开始搜索桌面QQ图标")
	home()
	delay(1000)
	home()
	delay(1000)
	for i = 0, 5 do
		local appIcon = Display:findPicture(getScriptDir().."/pic/qq.png", "C0C0C0", 1)
		if appIcon then
			logPrint("点击QQ图标")
			showMessage("点击QQ图标，坐标：%d,%d", appIcon.x, appIcon.y)
			appIcon:tap()
			break
		end
		Touch:swipeLeft()
		delay(1000)
	end
	logPrint("搜索桌面QQ图标完成")
end

function 内存访问测试()
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

function basicCmdTest()
	if getUserVar("全局弹窗") == "1" then
		全局弹窗测试()
	end
	if getUserVar("触控模拟") == "1" then
		触控测试()
	end
	if getUserVar("屏幕捕获") == "1" then
		屏幕捕获测试()
	end
	if getUserVar("图色识别") == "1" then
		搜索QQ图标()
	end
	if getUserVar("内存测试") == "1" then
		内存访问测试()
	end
end

function repeatPrintLog()
	logPrint("开始循环日志打印")
	for i = 1, 100 do
		logPrint("log output%d", i)
		delay(500)
	end
	logPrint("循环日志打印完成")
end

function main()
	if not requiresAsfVersion("1.4.6") then
		msgBox("脚本无法在当前asf平台上运行，请更新asf平台后再试")
		endScript()
	end

	Display:init()
	View:init()
	Touch:init()

	-- msgBox("%s", getSDCardPath())
	-- writeFile(getSDCardPath().."/ss/1.txt", "aaa123456")
	-- msgBox("%s", readFile(getSDCardPath().."/ss/1.txt"))
	-- if not file.open(getScriptDir().."/libcallhlp.so", "rb") then
		-- msgBox("open fail")
		-- endScript()
	-- end
	-- local s1 = file.read()
	-- writeFile(getSDCardPath().."/data.bin", s1)
	-- local s2 = readFile(getSDCardPath().."/data.bin")
	-- if s1 ~= s2 then msgBox("err") end
	-- msgBox(1)
	-- msgBox(plugin.example.TestCommand1("Hello", 123))
	-- msgBox(plugin.memory.GetProcessIdByName("com.android.musicfx"))
	-- Display:snapshot(getScriptDir().."/test.png")
	-- msgBox(getViewsInfo())
	-- setClipText("afa")
	-- msgBox("%s", getClipText())
	-- startActivity("taobao://m.tb.cn/h.en8o2i9?sm=069084 ")

	local touchMode = getUserVar("touch_mode")
	if touchMode == "2" then
		logPrint("使用root权限模拟")
		Touch:setMode(1)
	elseif touchMode == "1" then
		logPrint("使用无障碍手势模拟")
		Touch:setMode(2)
	end

	Device:init()
	Device:wakeAndUnlock()

	local runMode = getUserVar("run_mode")
	if runMode == "0" then
		basicCmdTest()
	elseif runMode == "1" then
		repeatPrintLog()
	end
	logPrint("全部测试完成")
end

function onScriptExit()
	logPrint("Script exiting")
end

main()

