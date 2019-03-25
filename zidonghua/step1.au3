#include<IE.au3>
#include <File.au3>
#include <Date.au3>

ConsoleWrite(_NowTime())
Local $testNum=0;

Run("C:\Program Files\internet explorer\iexplore.exe https://sycm.taobao.com/custom/login.htm?_target=http://sycm.taobao.com/portal/home.htm")
Sleep(1000)
Local $ie = _IEAttach("生意参谋")
While @error <> 0
	 Sleep(500)
	 $ie = _IEAttach("生意参谋")
WEnd
Local $frame = $ie.document.querySelector('.login-box>iframe').src
 _IENavigate($ie,$frame)
Sleep(1000)
$ie.document.querySelector("#TPL_username_1").value="乐友官方旗舰店:数据"
$ie.document.querySelector("#TPL_password_1").value = "147258AA"
MouveClick($ie,'document.querySelector("#J_SubmitStatic")',20,10,"left",1)
$ie = _IEAttach("生意参谋 - 零售电商大数据产品平台")
While @error <> 0
	 Sleep(500)
	 $ie = _IEAttach("生意参谋 - 零售电商大数据产品平台")
WEnd
Sleep(3000)
;单击市场tab页
Local $ele1=$ie.document.querySelector("a[href^='//sycm.taobao.com/mc/mq/market_monitor']")
While IsObj($ele1)=0
	 Sleep(1000)
	 $ele1=$ie.document.querySelector("a[href^='//sycm.taobao.com/mc/mq/market_monitor']")
WEnd
$ele1.click()

$ie.document.querySelector("a[href^='//sycm.taobao.com/mc/mq/market_rank']").click()
Sleep(500)
Local $ele2=$ie.document.querySelector(".common-picker-header")
While IsObj($ele2)=0
	 ;单击搜索排行
	 $ie.document.querySelector("a[href^='//sycm.taobao.com/mc/mq/market_rank']").click()
	 Sleep(1000)
	 $ele2=$ie.document.querySelector(".common-picker-header")
WEnd
;此处根据商品品类进行选择遍历
$ie.document.querySelector(".common-picker-header").click()
Sleep(2000)
;单击商品列表
$ie.document.querySelector(".ebase-Switch__root.op-ebase-switch>span:nth-child(2)").click()
;单击商品列表之判断页面的每页展示条数控件是否出现,直到出现时才进行后续操作
Local $ele3=$ie.document.querySelector(".ant-table-tbody>tr:nth-child(1)")
;flagNum作为标识字段，标识等待的次数
Local $flagNum=0
While IsObj($ele3)=0
	 Sleep(500)
	 $ele3=$ie.document.querySelector(".ant-table-tbody>tr:nth-child(1)")
	 ;如果等待5次预期的元素还没有在页面展示，重新执行单击事件
	 if $flagNum=5 then
		 $flagNum=0
		 $ie.document.querySelector(".ebase-Switch__root.op-ebase-switch>span:nth-child(2)").click()
	 EndIf
WEnd
$flagNum=0
;获取一级菜单的数量
Local $levelOneNum=$ie.document.querySelector(".tree-scroll-menu-level-1").getElementsByTagName("li").length
For $i = 1 To $levelOneNum Step +1
    $ie.document.querySelector(".tree-scroll-menu-level-1>li:nth-child("&$i&")").click()
	Local $levelOneText=$ie.document.querySelector(".tree-scroll-menu-level-1>li:nth-child("&$i&")").innerText
	$levelOneText=StringStripCR($levelOneText)
	$levelOneText=StringRegExpReplace($levelOneText,'/','-')
	;获取二级菜单的数量
	Local $levelTwoNum=$ie.document.querySelector(".tree-scroll-menu-level-2").getElementsByTagName("li").length
	For $j = 1 To $levelTwoNum Step +1
		$ie.document.querySelector(".tree-scroll-menu-level-2>li:nth-child("&$j&")").click()
		Local $levelTwoText=$ie.document.querySelector(".tree-scroll-menu-level-2>li:nth-child("&$j&")").innerText
		$levelTwoText=StringStripCR($levelTwoText)
		$levelTwoText=StringRegExpReplace($levelTwoText,'/','-')
		;获取三级菜单的数量
		Local $levelThreeNum=$ie.document.querySelector(".tree-scroll-menu-level-3").getElementsByTagName("li").length
		For $k = 1 To $levelThreeNum Step +1
			$testNum=$testNum+1
			if $testNum=50 Then
				ConsoleWrite(_NowTime())
				exit(0)
			EndIf
			$ie.document.querySelector(".tree-scroll-menu-level-3>li:nth-child("&$k&")").click()
			Local $levelThreeText=$ie.document.querySelector(".tree-scroll-menu-level-3>li:nth-child("&$k&")").innerText
			$levelThreeText=StringStripCR($levelThreeText)
			$levelThreeText=StringRegExpReplace($levelThreeText,'/','-')
			$ele3=$ie.document.querySelector(".ant-table-tbody>tr:nth-child(1)")
			While IsObj($ele3)=0
				Sleep(1000)
				$ele3=$ie.document.querySelector(".ant-table-tbody>tr:nth-child(1)")
				;如果等待5次预期的元素还没有在页面展示，重新执行单击事件
				if $flagNum=5 then
					$flagNum=0
					$ie.document.querySelector(".tree-scroll-menu-level-3>li:nth-child("&$k&")").click()
				EndIf
			WEnd
			$flagNum=0
			;单击之后选择每页展示20条
			$ie.document.querySelector(".ant-select-sm.oui-select.oui-page-size-select").click()
			$ie.document.querySelector(".ant-select-dropdown-menu.ant-select-dropdown-menu-root.ant-select-dropdown-menu-vertical>li:nth-child(2)").click()
			Local $teNums=$ie.document.querySelector(".ant-select-sm.oui-select.oui-page-size-select>div>.ant-select-selection__rendered>.ant-select-selection-selected-value").innerText
			While $teNums<>20
				Sleep(500)
				$teNums=$ie.document.querySelectorAll('.ant-table-tbody>tr').length
				;如果等待5次预期的元素还没有在页面展示，重新执行单击事件
				if $flagNum=5 then
					$flagNum=0
					$ie.document.querySelector(".ant-select-sm.oui-select.oui-page-size-select").click()
					Sleep(2000)
					$ie.document.querySelector(".ant-select-dropdown-menu.ant-select-dropdown-menu-root.ant-select-dropdown-menu-vertical>li:nth-child(2)").click()
				EndIf
			WEnd
			$flagNum=0
			Local $sHTML = _IEBodyReadHTML($ie)
			;将获取到的html存储到文件供在python中解析
			Local $hFile = FileOpen("D:\zidonghua\data\"&$levelOneText&'_'&$levelTwoText&'_'&$levelThreeText&'.txt',1)
			_FileWriteLog ($hFile, $sHTML)
			FileFlush($hFile)
			;关闭打开的文件
			FileClose($hFile)
		Next
	Next
Next
;~ 自定义的单击函数
Func MouveClick($oIE,$id,$Offsetx,$Offsety,$Buttons,$Times)
	;write_log("鼠标移动点击浏览器元素")
	Local $oIECoordinate = Execute("$oIE." & $id)
	Local $x = _IEPropertyGet($oIECoordinate,"screenx")
	Local $y = _IEPropertyGet($oIECoordinate,"screeny")
	;write_log("_IEPropertyGet获取元素坐标位置的结果X:"&$x&";Y:"&$y&";@error:"&@error)
	Local $MouveClick_i = 0
	While $y = 0
		$MouveClick_i += 1
		Sleep(1000)
		$x = _IEPropertyGet($oIECoordinate,"screenx")
		$y = _IEPropertyGet($oIECoordinate,"screeny")
		;write_log("进入while循环，第"&$MouveClick_i&"次_IEPropertyGet获取元素坐标位置的结果X:"&$x&";Y:"&$y&";@error:"&@error)
		If $MouveClick_i = 10 Then
			Return "获取元素失败"
		EndIf
	WEnd
	MouseMove($x+$Offsetx,$y+$Offsety)
	MouseClick($Buttons,$x+$Offsetx,$y+$Offsety,$Times)
EndFunc

;==========等待指定的元素是对象再继续执行
;$IEObj:     浏览器的IE对象
;$Element：  页面元素
;$OverTime： 等待超时时间
;===================================
Func WaitIsObj($IEObj,$Element,$OverTime)
	Local $Tag = Execute("$IEObj." & $Element)
	Local $iNum = 1
	While Not IsObj($Tag)
		Sleep(1000)
		$iNum += 1
		;MsgBox(1,1,"IsObj($Tag):"&IsObj($Tag))
		$Tag = Execute("$IEObj." & $Element)
		If $iNum > $OverTime Then
			Return 0
			;ExitLoop
		EndIf
	WEnd
	Return 1
EndFunc

