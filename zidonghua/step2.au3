#include<IE.au3>
#include <File.au3>
;step1:先将文件读取到autoit中
Run("C:\Program Files\internet explorer\iexplore.exe https://sycm.taobao.com/custom/login.htm?_target=http://sycm.taobao.com/portal/home.htm")
Sleep(1000)
Local $ie = _IEAttach("生意参谋")
While @error <> 0
	 Sleep(500)
	 $ie = _IEAttach("生意参谋")
WEnd
Local $aRetArray, $sFilePath = "D:\zidonghua\temp\fileTemp.csv"
_FileReadToArray($sFilePath, $aRetArray)

Local $row,$rowArray
For $i = 1 To $aRetArray[0] Step +1
	$row=$aRetArray[$i]
	$rowArray=StringSplit($row,',')
	_IENavigate($ie,$rowArray[2])
	$ie = _IEAttach('https:'&$rowArray[2],'url')

	Local $iPosition = StringInStr($rowArray[2],"item.taobao.com")

	;说明是来自淘宝 J_FavCount
	if $iPosition=0 Then
		Local $ele1=$ie.document.querySelector("#J_CollectCount").innerText
		While StringLen($ele1)=0
			Sleep(200)
			$ele1=$ie.document.querySelector("#J_CollectCount").innerText
		WEnd
	Else
		Local $ele2=$ie.document.querySelector(".J_FavCount").innerText
		While StringLen($ele2)=0
			Sleep(200)
			$ele2=$ie.document.querySelector(".J_FavCount").innerText
		WEnd
	EndIf
	Local $sHTML = _IEBodyReadHTML($ie)
	;根据url来判断是来自淘宝还是来自天猫
	Local $hFile = FileOpen("D:\zidonghua\detail\"&$rowArray[1]&'#'&$rowArray[3]&'.txt',1)
	_FileWriteLog ($hFile, $sHTML)
	FileFlush($hFile)
	;关闭打开的文件
	FileClose($hFile)
Next
