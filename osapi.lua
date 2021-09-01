
-- �жϵ�ǰ�Ƿ���rootȨ������
function runAsRoot()
	return getDeviceInfo("UserId") == "0"
end

-- ��ȡ��Ļ��ʾ��Ϣ
function getDisplayInfo()
	local res = cjson.decode(sendDeviceCmd("device.getDisplayInfo", "[]"))["result"]
	return cjson.decode(res)
end

-- ��ȡ�豸��Ʒ��
function getBrand()
	return cjson.decode(sendDeviceCmd("device.getBrand", "[]"))["result"]
end

-- ��ȡ�豸���ͺ�
function getModel()
	return cjson.decode(sendDeviceCmd("device.getModel", "[]"))["result"]
end

-- ��ȡ�豸��IMEI
function getIMEI()
	return cjson.decode(sendDeviceCmd("device.getIMEI", "[]"))["result"]
end

-- ���ص�ǰ���ӵ�Wifi��������
function getWifiSSID()
	return string.sub(cjson.decode(sendDeviceCmd("device.getWifiSSID", "[]"))["result"], 2, -2)
end

-- ��ȡSD�洢·��
function getSDCardPath()
	return cjson.decode(sendDeviceCmd("device.getSDCardPath", "[]"))["result"]
end

-- �����豸�Ƿ�������
function isDeviceLocked()
	return cjson.decode(sendDeviceCmd("device.isDeviceLocked", "[]"))["result"]
end

-- ������Ļ�Ƿ�����
function isScreenOn()
	return cjson.decode(sendDeviceCmd("device.isScreenOn", "[]"))["result"]
end

-- �����ֻ�
function wakeUp()
	sendDeviceCmd("device.wakeUp", '[]')
end

-- ʹ��Ļ���ֿ���״̬�����������ֿ���ʱ�������룩
function keepScreenOn(timeout)
	local args = {timeout}
	sendDeviceCmd("device.keepScreenOn", cjson.encode(args))
end

-- ȡ��ʹ��Ļ���ֿ���״̬
function cancelKeepingAwake()
	sendDeviceCmd("device.cancelKeepingAwake", '[]')
end

-- �豸�񶯣�����������ʱ�������룩
function vibrate(duration)
	local args = {duration}
	sendDeviceCmd("device.vibrate", cjson.encode(args))
	delay(duration)
end

-- ֹͣ��
function cancelVibration()
	sendDeviceCmd("device.cancelVibration", '[]')
end

-- ��ʾtoast��ʾ��Ϣ
function showMessage(...)
	local args = {string.format(...)}
	sendDeviceCmd("system.showMessage", cjson.encode(args))
end

-- ʹ��֪ͨ�����û�������Ϣ
function pushNotification(...)
	local args = {string.format(...)}
	sendDeviceCmd("system.pushNotification", cjson.encode(args))
end

-- �Ƴ����͵���Ϣ
function removeNotification()
	sendDeviceCmd("system.removeNotification", '[]')
end

-- ��鵱ǰִ�����汾�Ƿ��������е�ǰ�ű������Ҫ��
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

-- ��ȡSDK�汾
function getSdkInt()
	return cjson.decode(sendDeviceCmd("system.getSdkInt", "[]"))["result"]
end

-- �豸�Ƿ���root
function haveRoot()
	return cjson.decode(sendDeviceCmd("system.haveRoot", "[]"))["result"]
end

-- �жϵ�ǰ�����Ƿ�������
function isHome()
	return cjson.decode(sendDeviceCmd("system.isHome", "[]"))["result"]
end

-- �����Ļ�������Ƿ���ã�Ҫ��׿5.0����ϵͳ
function isCaptureAvailable()
	return cjson.decode(sendDeviceCmd("system.isCaptureAvailable", "[]"))["result"]
end

-- ������ϰ������Ƿ����
function isAccessibilityAvailable()
	return cjson.decode(sendDeviceCmd("system.isAccessibilityAvailable", "[]"))["result"]
end

-- ���µĻ
function startActivity(uri)
	local args = {uri}
	local res = sendDeviceCmd("system.startActivity", cjson.encode(args))
	return cjson.decode(res)["result"]
end

-- ���ָ��APP�Ƿ��Ѱ�װ
function checkAppInstalled(pkgName)
	local args = {pkgName}
	local res = sendDeviceCmd("system.checkAppInstalled", cjson.encode(args))
	return cjson.decode(res)["result"]
end

-- ����APP
function startApp(pkgName, clsName)
	local args = {pkgName, clsName}
	local res = sendDeviceCmd("system.startApp", cjson.encode(args))
	return cjson.decode(res)["result"]
end

-- ������̨APP
function killBackgroundApp(pkgName)
	local args = {pkgName}
	sendDeviceCmd("system.killBackgroundApp", cjson.encode(args))
end

-- ��ȡ�������е��ı�
function getClipText()
	return cjson.decode(sendDeviceCmd("system.getClipText", "[]"))["result"]
end

-- ���ü�����
function setClipText(text)
	local args = {text}
	sendDeviceCmd("system.setClipText", cjson.encode(args))
end

-- ��ȡ�ļ�
function readFile(filePath)
	local args = {filePath}
	local enc_file = cjson.decode(sendDeviceCmd("system.readFile", cjson.encode(args)))["result"]
	return misc.FromBase64(enc_file)
end

-- д���ļ����ɹ�����true
function writeFile(filePath, content)
	local args = {filePath, misc.ToBase64(content)}
	return cjson.decode(sendDeviceCmd("system.writeFile", cjson.encode(args)))["result"]
end

-- ʹ��HTTP GET��ȡ����
function httpGet(url)
	local args = {url}
	return cjson.decode(sendDeviceCmd("net.httpGet", cjson.encode(args)))["result"]
end

-- ʹ��HTTP POST��������ύ����
function httpPost(url, content)
	local args = {url, content}
	return cjson.decode(sendDeviceCmd("net.httpPost", cjson.encode(args)))["result"]
end

-- ������ϰ������Ƿ����
function checkAccessibility()
	return cjson.decode(sendDeviceCmd("accessibility.isServiceAvailable", "[]"))["result"]
end

-- ������Ļ������view��Ϣ
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

-- ����ָ��view��Ϣ
function getViewInfo(handle)
	return sendDeviceCmd("accessibility.getViewInfo", cjson.encode({handle}))
end

-- ���view
function clickView(handle)
	if handle then
		sendDeviceCmd("accessibility.clickView", cjson.encode({handle}))
	else
		sendDeviceCmd("accessibility.clickView", "[]")
	end
end

-- �����view
function longClickView(handle)
	if handle then
		sendDeviceCmd("accessibility.longClickView", cjson.encode({handle}))
	else
		sendDeviceCmd("accessibility.longClickView", "[]")
	end
end

-- ģ������
function gesture(path, duration)
	local points = cjson.encode(path)
	local args = {20, duration, points}
	sendDeviceCmd("accessibility.gesture", cjson.encode(args))
end

-- ģ��������
function tap(x, y)
	gesture({{x, y}}, 50)
end

-- ģ�⻬��
function swipe(x1, y1, x2, y2, duration)
	gesture({{x1, y1}, {x2, y2}}, duration)
end

-- ģ�ⷵ�ز���
function back()
	sendDeviceCmd("accessibility.back", "[]")
end

-- ģ�������
function home()
	sendDeviceCmd("accessibility.home", "[]")
end

-- ģ���»�����
function scrollBackward()
	sendDeviceCmd("accessibility.scrollBackward", "[]")
end

-- ģ���ϻ�����
function scrollForward()
	sendDeviceCmd("accessibility.scrollForward", "[]")
end

-- �����ҵ��ı༭���������ı�
function inputText(text)
	local args = {text}
	sendDeviceCmd("accessibility.inputText", cjson.encode(args))
end

