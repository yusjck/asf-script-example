--[[模拟输入命令--]]

-- 使用绝对坐标移动鼠标指针
function moveTo(x, y)
	return input.MouseMove(x, y)
end

-- 使用相对坐标移动鼠标指针
function moveR(x, y)
	return input.MouseMove(x, y, 1)
end

-- 模拟左键双击
function leftDoubleClick()
	return input.MouseDoubleClick(1)
end

-- 模拟中键点击
function middleClick(delay)
	return input.MouseClick(4, delay and delay or 50)
end

-- 模拟左键按下
function leftDown()
	return input.MouseDown(1)
end

-- 模拟左键弹起
function leftUp()
	return input.MouseUp(1)
end

-- 模拟左键点击
function leftClick(delay)
	return input.MouseClick(1, delay and delay or 50)
end

-- 模拟右键按下
function rightDown()
	return input.MouseDown(2)
end

-- 模拟右键弹起
function rightUp()
	return input.MouseUp(2)
end

-- 模拟右键点击
function rightClick(delay)
	return input.MouseClick(2, delay and delay or 50)
end

-- 模拟鼠标滚轮滚动
function mouseWheel(zDelta)
	return input.MouseWheel(zDelta)
end

-- 模拟按键按下
function keyDown(key)
	return input.KeyDown(key)
end

-- 模拟按键弹起
function keyUp(key)
	return input.KeyUp(key)
end

-- 模拟按键
function keyPress(key, delay)
	return input.KeyPress(key, delay and delay or 50)
end

-- 模拟手指在触摸屏上按下
function touchDown(x, y)
	return input.TouchDown(x, y)
end

-- 移动按下的点
function touchMove(x, y)
	return input.TouchMove(x, y)
end

-- 放开按下的点
function touchUp()
	return input.TouchUp()
end

-- 模拟点击触摸屏
function touchTap(x, y)
	return input.Tap(x, y)
end

-- 模拟手指在触摸屏上划动
function touchSwipe(x1, y1, x2, y2, duration)
	return input.Swipe(x1, y1, x2, y2, duration)
end

----------------------------------------------------------------------
-- 以下命令只用于WIN32平台，ANDROID平台不支持
----------------------------------------------------------------------

-- 指定前台鼠标键盘模拟方式
-- emu_mode:
--			0.由执行器决定
--			1.普通模拟
--			2.超级模拟
--			3.硬件模拟
function setEmulateMode(emu_mode)
	return input.SetEmulateMode(emu_mode)
end

-- 锁定前台鼠标键盘，只允许后台输入
function lockInput()
	return input.LockInput()
end

-- 解锁前台鼠标键盘
function unlockInput()
	return input.UnlockInput()
end

-- 在绑定窗口上输入文字
-- send_mode:
--			0.使用窗口消息进行输入
--			1.使用窗口消息进行输入2
--			2.使用模拟输入法进行输入2（需要注入并在BindWindow时加入参数2048）
--			3.使用模拟输入法进行输入（需要注入）
--			4.使用窗口消息进行输入，只支持英文
function sendString(send_mode, str)
	return input.SendString(send_mode, str)
end

