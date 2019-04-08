#include<IE.au3>
#include <File.au3>
Run("C:\Program Files\internet explorer\iexplore.exe https://sycm.taobao.com/custom/login.htm?_target=http://sycm.taobao.com/portal/home.htm")

;Start初始化一下当前文件路径下的detail目录
Local $flag=FileExists(@ScriptDir&'\detail\')
If $flag=1 Then
	FileDelete(@ScriptDir&'\detail\')
EndIf
_FileCreate(@ScriptDir&'\detail\')
;End初始化一下当前文件路径下的detail目录

Sleep(1000)
Local $ie = _IEAttach("生意参谋")
While @error <> 0
	 Sleep(500)
	 $ie = _IEAttach("生意参谋")
WEnd
Local $aRetArray, $sFilePath = @ScriptDir&'\temp\fileTemp.csv'
_FileReadToArray($sFilePath, $aRetArray)

Local $row,$rowArray
For $i = 1 To $aRetArray[0] Step +1
	$row=$aRetArray[$i]
	$rowArray=StringSplit($row,',')
	_IENavigate($ie,$rowArray[2])
	$ie = _IEAttach('https:'&$rowArray[2],'url')
	Local $Position = StringInStr($rowArray[2],"item.taobao.com")
	;说明是来自天猫
	if $Position=0 Then
		Local $judgeNum=WaitIsObj($ie,'document.querySelector("#J_ItemRates>.tm-indcon>.tm-count")',5)
		if $judgeNum=0 Then
			$ie = _IEAttach('淘宝网 - 淘！我喜欢')
			ContinueLoop
		EndIf
		Local $ele1=$ie.document.querySelector("#J_ItemRates>.tm-indcon>.tm-count").innerText
		While StringLen($ele1)=0 Or  $ele1='-'
			Sleep(200)
			$ele1=$ie.document.querySelector("#J_ItemRates>.tm-indcon>.tm-count").innerText
		WEnd
	Else
		Local $judgeNum=WaitIsObj($ie,'document.querySelector("#J_RateCounter")',5)
		if $judgeNum=0 Then
			$ie = _IEAttach('淘宝网 - 淘！我喜欢')
			ContinueLoop
		EndIf
		Local $ele2=$ie.document.querySelector("#J_RateCounter").innerText
		While StringLen($ele2)=0 Or  $ele2='-'
			Sleep(200)
			$ele2=$ie.document.querySelector("#J_RateCounter").innerText
		WEnd
	EndIf
	Local $sHTML = _IEBodyReadHTML($ie)
	;Start拼接存储html的文件名
	Local $hFile
	If $Position=0 Then
		$hFile = FileOpen(@ScriptDir&"\detail\"&$rowArray[1]&'#'&$rowArray[3]&'#1'&'.txt',1);天猫是1
	Else
		$hFile = FileOpen(@ScriptDir&"\detail\"&$rowArray[1]&'#'&$rowArray[3]&'#0'&'.txt',1);淘宝是0
	EndIf
	;End拼接存储html的文件名
	_FileWriteLog ($hFile, $sHTML)
	FileFlush($hFile)
	;关闭打开的文件
	FileClose($hFile)
Next

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
