#include<IE.au3>
#include <File.au3>
Run("C:\Program Files\internet explorer\iexplore.exe https://sycm.taobao.com/custom/login.htm?_target=http://sycm.taobao.com/portal/home.htm")

;Start��ʼ��һ�µ�ǰ�ļ�·���µ�detailĿ¼
Local $flag=FileExists(@ScriptDir&'\detail\')
If $flag=1 Then
	FileDelete(@ScriptDir&'\detail\')
EndIf
_FileCreate(@ScriptDir&'\detail\')
;End��ʼ��һ�µ�ǰ�ļ�·���µ�detailĿ¼

Sleep(1000)
Local $ie = _IEAttach("�����ı")
While @error <> 0
	 Sleep(500)
	 $ie = _IEAttach("�����ı")
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
	;˵����������è
	if $Position=0 Then
		Local $judgeNum=WaitIsObj($ie,'document.querySelector("#J_ItemRates>.tm-indcon>.tm-count")',5)
		if $judgeNum=0 Then
			$ie = _IEAttach('�Ա��� - �ԣ���ϲ��')
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
			$ie = _IEAttach('�Ա��� - �ԣ���ϲ��')
			ContinueLoop
		EndIf
		Local $ele2=$ie.document.querySelector("#J_RateCounter").innerText
		While StringLen($ele2)=0 Or  $ele2='-'
			Sleep(200)
			$ele2=$ie.document.querySelector("#J_RateCounter").innerText
		WEnd
	EndIf
	Local $sHTML = _IEBodyReadHTML($ie)
	;Startƴ�Ӵ洢html���ļ���
	Local $hFile
	If $Position=0 Then
		$hFile = FileOpen(@ScriptDir&"\detail\"&$rowArray[1]&'#'&$rowArray[3]&'#1'&'.txt',1);��è��1
	Else
		$hFile = FileOpen(@ScriptDir&"\detail\"&$rowArray[1]&'#'&$rowArray[3]&'#0'&'.txt',1);�Ա���0
	EndIf
	;Endƴ�Ӵ洢html���ļ���
	_FileWriteLog ($hFile, $sHTML)
	FileFlush($hFile)
	;�رմ򿪵��ļ�
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
