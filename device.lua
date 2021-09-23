
Device = {}

function Device:init()
	self.brand = string.lower(getBrand())
	if getUserVar("auto_unlock_screen", "0") == "1" then
		self.pinCode = getUserVar("device_pin_code")
	elseif getUserVar("auto_unlock_screen", "0") == "2" then
		local wifiSsid = getWifiSSID()
		for i = 1, 6 do
			if wifiSsid ~= "unknown ssid" then
				break
			end
			delay(1000)
			wifiSsid = getWifiSSID()
		end
		local trustWifis = split(getUserVar("trust_wifi_name", ""), ";")
		if table.contains(trustWifis, wifiSsid) then
			self.pinCode = getUserVar("device_pin_code")
		else
			logPrint("非信任网络，当前WIFI：%s", wifiSsid)
		end
	end
end

function Device:isInWelcomeView()
	if self.brand == "xiaomi" then
		return View:findByRule({id="com.android.systemui:id/keyguard_indication_text"})
	elseif self.brand == "oppo" then
		return View:findByRule({id="com.android.systemui:id/keyguard_slider_layout"})
	else
		return View:findByRule({id="com.android.systemui:id/keyguard_carrier_text"})
	end
end

function Device:isInKeyguardView()
	return View:findByRule({id="com.android.systemui:id/keyguard_host_view"})
end

function Device:unlock1()
	if self.brand == "xiaomi" then
		logPrint("MIUI解锁")
		repeat
			repeat
				Touch:pullDown()
				delay(1000)
			until View:findByRule({id="com.android.systemui:id/notification_container_parent"})
			View:clickByRule({id="com.android.systemui:id/big_time"})
			delay(1000)
		until not Device:isInWelcomeView()
	else
		logPrint("模拟上滑解锁")
		repeat
			Touch:swipe(0.5, 0.7, 0.5, 0.1, 500)
			delay(1000)
		until not Device:isInWelcomeView()
	end
end

function Device:unlock2()
	repeat
		if self:isInKeyguardView() then
			logPrint("进入锁屏密码界面")
			if not self.pinCode then
				ePrint("未能解锁屏幕")
				showMessage("未开启自动解锁，脚本退出")
				endScript("failure")
			end
			repeat
				self:inputPin(self.pinCode)
				delay(1000)
			until not self:isInKeyguardView()
			logPrint("解锁完成")
		end
		delay(500)
	until not isDeviceLocked()
end

function Device:inputPin(pin)
	local function getKeyBtn(key)
		local keyBtn = View:findByRule({id="com.android.systemui:id/key"..key})
		if not keyBtn then
			keyBtn = View:findByRule({text=key})
		end
		if not keyBtn then
			return nil
		end
		return Display.Point:new(keyBtn.x, keyBtn.y)
	end
	local function getKey0Btn()
		local key5Btn = getKeyBtn("5")
		local key8Btn = getKeyBtn("8")
		if not key5Btn or not key8Btn then
			return nil
		end
		return Display.Point:new(key8Btn.x, key8Btn.y + (key8Btn.y - key5Btn.y))
	end
	for i = 1, #pin do
		local key = string.sub(pin, i, i)
		local keyBtn = getKeyBtn(key)
		if keyBtn then
			keyBtn:tap()
			delay(500)
		else
			if key == "0" then
				keyBtn = getKey0Btn()
			end
			if keyBtn then
				keyBtn:tap()
				delay(500)
			else
				ePrint("未找到数字键："..key)
				endScript("failure")
			end
		end
	end
	View:clickByRule({id="com.android.systemui:id/key_enter"})
end

function Device:wakeAndUnlock()
	setTimer("wake_device_timeout", function()
		ePrint("唤醒设备超时，中断脚本")
		saveFailScreen()
		endScript("failure")
	end, true, 30 * 1000)
	if not isScreenOn() then
		logPrint("唤醒设备")
		repeat
			wakeUp()
			delay(1000)
		until isScreenOn()
		self:unlock1()
	end
	if self:isInWelcomeView() then
		self:unlock1()
	end
	if isDeviceLocked() then
		logPrint("设备已锁定，开始解锁")
		self:unlock2()
	end
	cancelTimer("wake_device_timeout")
end

