<%@ Language=VBScript CodePage=1254%>
<!--#INCLUDE FILE="../global/inc/com/comFunctions.asp"-->
<%
Dim strTCPIP
    Response.Expires = 0
    Response.CharSet="windows-1254"
    strTCPIP=Request.Cookies("VisitorID") 
    Dim strtaksitTuru
    strtaksitTuru = ReadMultiRecordForCombo(Application("g_dbconstring" & strTCPIP), "select ID, aciklama from torba7020TturuAciklama order by ID", "ID","aciklama")
    strtaksitTuru = "<option value=''>--Seçiniz--</option>" & strtaksitTuru

 'response.write Application("g_kuladi" & strTCPIP)
%>
<html>
<head>
<style>
	.tblData {border:none;width:100%;margin:0px;}
	.tblDataDetail {border:1px solid #DDDDDD;}
</style>
<link rel="stylesheet" href="../global/css/BelsisNewStyle.css" type="text/css" />
<script id="globalFunctionScript" type="text/javascript" src="../global/ajaxFunctions/globalFunction.js"></script>
<script id="ajaxFunctions" type="text/javascript" src="../global/ajaxFunctions/ajaxMainFunctions.js"></script>
<script type="text/javascript">

var ajaxDataPage=new ajaxDynamicDataPage();
ajaxDataPage.spName = 'torba7020TturuSave';
	function saveRecord()
	{
			if (formValidate()) 
			{
				document.getElementById('txttturuXML').value=document.getElementById('tturuXML').xml;
				ajaxDataPage.saveRecord();
			}
	}

	function formValidate()
	{
	    var objXML = document.getElementById('tturuXML');
	    var kontrol=true;
        if (objXML.recordset) 
        {
            objXML.recordset.moveFirst();
            while (!objXML.recordset.EOF) 
            {
                if (objXML.recordset.fields('taksitTuru').value == '' || objXML.recordset.fields('taksitTuru').value == '0') 
                {
                    uiUyariGoster('Taksitlendirme Türü Seçilmemiþ Kayýtlar Var!', returnFunction())
                    function returnFunction()
                    {
                        kontrol = false;
                    }
                    break;
                }
                objXML.recordset.moveNext();
            }
        }
        objXML = null;

        return kontrol;
    }

	function formClose()
	{
		uiSoruSor('Çýkmak Ýstiyormusunuz?',uiReturn);
		function uiReturn(retVal)
		{
			if(retVal) {window.close()};
		}
	}

	function closeUiBox() {
	    uiBox.close();
	}

	function formLoad()
	{
	    maximizeWindow();

	    var strSQL;
			strSQL = 'select modulno,modul_adi,tturu,gelAdi,taksitTuru,hesapKodu from ( '+
                    'select torba7020Tturu.modulno, modul.modul_adi, torba7020Tturu.tturu, upper(ttur.gel_adi) AS gelAdi,torba7020Tturu.taksitTuru, ' +
                    'case when isnull(ttur.bbm_hes_kod,\'\')<>\'\' Then bbm_hes_kod else ttur.entgel_kod end AS hesapKodu '+
                    'from torba7020Tturu '+
                    'inner join gttttur ttur on torba7020Tturu.tturu=ttur.tturu ' +
                    'inner join modul on modul.modulno=torba7020Tturu.modulno '+
                    'union All '+
	                'select tah.modulno,max(modul.modul_adi) modul_adi, tah.tturu, upper(max(ttur.gel_adi)) AS gelAdi, Null taksitTuru, ' +
                    'case when isnull(max(ttur.bbm_hes_kod),\'\')<>\'\' Then max(bbm_hes_kod) else max(ttur.entgel_kod) end AS hesapKodu ' +
                    'from gtttah tah with (nolock) ' +
                    'inner join gttttur ttur with (nolock) on tah.tturu=ttur.tturu ' +
                    'inner join modul on modul.modulno=tah.modulno '+
                    'where tah.modulno not in(122,135,105,143,145) ' +
                    'and tah.bakiye>0 ' +
                    'and not exists(select torba.ID from torba7020Tturu torba where torba.modulno=tah.modulno and torba.tturu=tah.tturu) '+
                    'and ttur.tturu not in(select par.ufeTefeTturu from torba7020Parametre par where ID=(select max(ID) from torba7020Parametre)) ' +
                    'and ttur.tturu not in(select par.katsayiTturu from torba7020Parametre par where ID=(select max(ID) from torba7020Parametre)) '+
                    'group by tah.modulno,tah.tturu ) x '+
                    'order by taksitTuru asc, modulno desc, tturu asc '

                    //$("txtsql").value = strSQL;

                    ajaxLoadDataToXML(strSQL, 'tturuXML', 'divData', retFormLoad);
                    function retFormLoad() {
                        uiBox = new uiModalBox(460, 300);
                        uiBox.contentElement = $('uyariTable');
                        uiBox.show();
                        $("lblUyari").innerHTML = '<font color="red">Sayýn ' + '<%=Application("g_kuladi" & strTCPIP)%>;</font>'+'<p>7020 Sayýlý yasa kapsamýna girecek tahakkuk türlerini arka planda yer alan ekranda '+
                            'inceleyeniz. Taksitlendirme Türü boþ olanlarý seçip kayýt etmelisiniz.Otomatik olarak doldurulmuþ Taksitlendirme Türlerini kontrol ederek yanlýþlýk varsa düzeltiniz.<br><br><font color="red">ÖNEMLÝ NOT:</font><br>Seçtiðiniz taksitlendirme türlerine göre yapýlandýrma iþlemi yapýlacaðýndan kapsama giren/girmeyen/indirim uygulanan ' +
                            'tahakkuk türlerini dikkatlice seçiniz.<br><br>&nbsp'

                    }
	}

</script>
</head>
<body onload="formLoad()">
<form id=frm name=frm style="height:100%;">
	<table align=center cellSpacing=0 cellpadding=1 style="height:100%;">
		<tr >
			<td height=18 colspan=2 class="visualCaption">
				7020 Sayýlý Yasa Tahakkuk Türü Düzenlemeleri
			</td>
		</tr>
		<tr >
			<td colspan=2 style="vertical-align:top">
				<div id=divData style="width:100%;height:100%;overflow-y:scroll;padding:0px;margin:0px;">
					<table class=tblData cellSpacing=0 cellpadding=1 datasrc=#tturuXML >
						<thead>
						<tr style="position:relative;top:expression(offsetParent.scrollTop)">
							<td class=uiSubHeader>Modül</td>
							<td class=uiSubHeader>Tahakkuk Türü</td>
							<td class=uiSubHeader>Gelir Kodu</td>
							<td class=uiSubHeader>Tahakkuk Türü<br>Açýklama</td>
							<td class=uiSubHeader>Taksitlendirme Türü</td>
						</tr>
						</thead>
						<tr>
                            <td>
								<input datafld=modulno type=hidden>
	                            <input datafld=modul_adi class=MTextBox size=40 maxlength=20 readonly>
                            </td>
							<td class=tblDataDetail>
								<input datafld=tturu readonly>
							</td>
                            <td>
	                            <input datafld=hesapKodu class=MTextBox size=20 maxlength=20 readonly>
                            </td>
                            <td>
	                            <input datafld=gelAdi class=MTextBox size=30 maxlength=30 readonly>
                            </td>
							<td>
							    <select datafld=taksitTuru ><%=strtaksitTuru%></select>
							</td>
						</tr>
					</table>
				</div>
			</td>
		</tr>
		<tr height=30>
			<TD colspan=2 style="border-top-width:1;border-top-style:inset;text-align:center" nowrap>
				<input type="button" value="Kaydet" name="btnSave" id="btnSave" class="glossybutton" style="width:30%" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" onclick="javascript:saveRecord()">
				<input type="button" value="Çýkýþ" name="btnExit" id="btnExit" class="glossybutton" style="width:30%" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" onclick="javascript:formClose()">
                <textarea id="txtsql" style="display:none;"></textarea>
			</TD>
		</tr>
	</table>
    <table id="uyariTable" cellspacing="1" style="border:none; display:none;" >
        <tr>
            <td align="right" style="background-color:#EDC87E;">
                <img src="../images/goCancel.png" title="Kapat" onclick=" closeUiBox();" style="cursor:pointer;" />
            </td>
        </tr>
        <tr>
            <td>
                <label id="lblUyari" style="font-weight:bold; font-family:Tahoma; font-size:16px;"></label>
            </td>
        </tr>
    </table>
	<textarea id=txttturuXML style="display:none"></textarea> 
	<xml id=tturuXML></xml>
</form>
</body>
</html>