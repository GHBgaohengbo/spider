#include<IE.au3>
#include <File.au3>
#include <Date.au3>

ConsoleWrite(_NowTime())
Local $testNum=0;

Run("C:\Program Files\internet explorer\iexplore.exe https://sycm.taobao.com/custom/login.htm?_target=http://sycm.taobao.com/portal/home.htm")
Sleep(1000)
Local $ie = _IEAttach("�����ı")
While @error <> 0
	 Sleep(500)
	 $ie = _IEAttach("�����ı")
WEnd
Local $frame = $ie.document.querySelector('.login-box>iframe').src
 _IENavigate($ie,$frame)
Sleep(1000)
$ie.document.querySelector("#TPL_username_1").value="���ѹٷ��콢��:����"
$ie.document.querySelector("#TPL_password_1").value = "147258AA"
MouveClick($ie,'document.querySelector("#J_SubmitStatic")',20,10,"left",1)
$ie = _IEAttach("�����ı - ���۵��̴����ݲ�Ʒƽ̨")
While @error <> 0
	 Sleep(500)
	 $ie = _IEAttach("�����ı - ���۵��̴����ݲ�Ʒƽ̨")
WEnd
Sleep(3000)
;�����г�tabҳ
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
	 ;������������
	 $ie.document.querySelector("a[href^='//sycm.taobao.com/mc/mq/market_rank']").click()
	 Sleep(1000)
	 $ele2=$ie.document.querySelector(".common-picker-header")
WEnd
;�˴�������ƷƷ�����ѡ�����
$ie.document.querySelector(".common-picker-header").click()
Sleep(2000)
;������Ʒ�б�
$ie.document.querySelector(".ebase-Switch__root.op-ebase-switch>span:nth-child(2)").click()
;������Ʒ�б�֮�ж�ҳ���ÿҳչʾ�����ؼ��Ƿ����,ֱ������ʱ�Ž��к�������
Local $ele3=$ie.document.querySelector(".ant-table-tbody>tr:nth-child(1)")
;flagNum��Ϊ��ʶ�ֶΣ���ʶ�ȴ��Ĵ���
Local $flagNum=0
While IsObj($ele3)=0
	 Sleep(500)
	 $ele3=$ie.document.querySelector(".ant-table-tbody>tr:nth-child(1)")
	 ;����ȴ�5��Ԥ�ڵ�Ԫ�ػ�û����ҳ��չʾ������ִ�е����¼�
	 if $flagNum=5 then
		 $flagNum=0
		 $ie.document.querySelector(".ebase-Switch__root.op-ebase-switch>span:nth-child(2)").click()
	 EndIf
WEnd
$flagNum=0
;��ȡһ���˵�������
Local $levelOneNum=$ie.document.querySelector(".tree-scroll-menu-level-1").getElementsByTagName("li").length
For $i = 1 To $levelOneNum Step +1
    $ie.document.querySelector(".tree-scroll-menu-level-1>li:nth-child("&$i&")").click()
	Local $levelOneText=$ie.document.querySelector(".tree-scroll-menu-level-1>li:nth-child("&$i&")").innerText
	$levelOneText=StringStripCR($levelOneText)
	$levelOneText=StringRegExpReplace($levelOneText,'/','-')
	;��ȡ�����˵�������
	Local $levelTwoNum=$ie.document.querySelector(".tree-scroll-menu-level-2").getElementsByTagName("li").length
	For $j = 1 To $levelTwoNum Step +1
		$ie.document.querySelector(".tree-scroll-menu-level-2>li:nth-child("&$j&")").click()
		Local $levelTwoText=$ie.document.querySelector(".tree-scroll-menu-level-2>li:nth-child("&$j&")").innerText
		$levelTwoText=StringStripCR($levelTwoText)
		$levelTwoText=StringRegExpReplace($levelTwoText,'/','-')
		;��ȡ�����˵�������
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
				;����ȴ�5��Ԥ�ڵ�Ԫ�ػ�û����ҳ��չʾ������ִ�е����¼�
				if $flagNum=5 then
					$flagNum=0
					$ie.document.querySelector(".tree-scroll-menu-level-3>li:nth-child("&$k&")").click()
				EndIf
			WEnd
			$flagNum=0
			;����֮��ѡ��ÿҳչʾ20��
			$ie.document.querySelector(".ant-select-sm.oui-select.oui-page-size-select").click()
			$ie.document.querySelector(".ant-select-dropdown-menu.ant-select-dropdown-menu-root.ant-select-dropdown-menu-vertical>li:nth-child(2)").click()
			Local $teNums=$ie.document.querySelector(".ant-select-sm.oui-select.oui-page-size-select>div>.ant-select-selection__rendered>.ant-select-selection-selected-value").innerText
			While $teNums<>20
				Sleep(500)
				$teNums=$ie.document.querySelectorAll('.ant-table-tbody>tr').length
				;����ȴ�5��Ԥ�ڵ�Ԫ�ػ�û����ҳ��չʾ������ִ�е����¼�
				if $flagNum=5 then
					$flagNum=0
					$ie.document.querySelector(".ant-select-sm.oui-select.oui-page-size-select").click()
					Sleep(2000)
					$ie.document.querySelector(".ant-select-dropdown-menu.ant-select-dropdown-menu-root.ant-select-dropdown-menu-vertical>li:nth-child(2)").click()
				EndIf
			WEnd
			$flagNum=0
			Local $sHTML = _IEBodyReadHTML($ie)
			;����ȡ����html�洢���ļ�����python�н���
			Local $hFile = FileOpen("D:\zidonghua\data\"&$levelOneText&'_'&$levelTwoText&'_'&$levelThreeText&'.txt',1)
			_FileWriteLog ($hFile, $sHTML)
			FileFlush($hFile)
			;�رմ򿪵��ļ�
			FileClose($hFile)
		Next
	Next
Next
;~ �Զ���ĵ�������
Func MouveClick($oIE,$id,$Offsetx,$Offsety,$Buttons,$Times)
	;write_log("����ƶ���������Ԫ��")
	Local $oIECoordinate = Execute("$oIE." & $id)
	Local $x = _IEPropertyGet($oIECoordinate,"screenx")
	Local $y = _IEPropertyGet($oIECoordinate,"screeny")
	;write_log("_IEPropertyGet��ȡԪ������λ�õĽ��X:"&$x&";Y:"&$y&";@error:"&@error)
	Local $MouveClick_i = 0
	While $y = 0
		$MouveClick_i += 1
		Sleep(1000)
		$x = _IEPropertyGet($oIECoordinate,"screenx")
		$y = _IEPropertyGet($oIECoordinate,"screeny")
		;write_log("����whileѭ������"&$MouveClick_i&"��_IEPropertyGet��ȡԪ������λ�õĽ��X:"&$x&";Y:"&$y&";@error:"&@error)
		If $MouveClick_i = 10 Then
			Return "��ȡԪ��ʧ��"
		EndIf
	WEnd
	MouseMove($x+$Offsetx,$y+$Offsety)
	MouseClick($Buttons,$x+$Offsetx,$y+$Offsety,$Times)
EndFunc

;==========�ȴ�ָ����Ԫ���Ƕ����ټ���ִ��
;$IEObj:     �������IE����
;$Element��  ҳ��Ԫ��
;$OverTime�� �ȴ���ʱʱ��
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

