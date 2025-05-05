<%@ Language=VBScript CodePage=1254%>
<!--#INCLUDE FILE="../global/inc/com/comFunctions.asp"-->
<%
Dim strTCPIP
    Response.Expires = 0
    Response.CharSet="windows-1254"
    strTCPIP=Request.Cookies("VisitorID") 
%>
<html>
<head>
<style>
</style>
<link rel="stylesheet" href="../global/css/BelsisNewStyle.css" type="text/css" />
<script id="globalFunctionScript" type="text/javascript" src="../global/ajaxFunctions/globalFunction.js"></script>
<script id="ajaxFunctions" type="text/javascript" src="../global/ajaxFunctions/ajaxMainFunctions.js"></script>
<script type="text/javascript">

    var ajaxDataPage = new ajaxDynamicDataPage('torba7020Parametre', 'recID');

		function setAjaxPageParameter()
		{
		    ajaxDataPage.getRecordQuery = 'top 1 convert(varchar(10),kontrolTarih,103) AS kontrolTarih, convert(varchar(10),beyanKontrolTarihi,103) AS beyanKontrolTarihi,convert(varchar(10),sonBasvuruTarih,103) AS sonBasvuruTarih, convert(varchar(10),sonodemeTarih,103) AS sonodemeTarih, convert(varchar(10),sonodemeTarih2,103) AS sonodemeTarih2, ufeTefeTturu,katsayiTturu, ' +
		    '(select tur.gel_adi from gttttur tur where tur.tturu=torba7020Parametre.ufeTefeTturu) AS ufeTefeTturuAciklama, '+
		    '(select tur.gel_adi from gttttur tur where tur.tturu=torba7020Parametre.katsayiTturu) AS katsayiTturuAciklama, ' +
		    'convert(varchar(10),iptalSonBasvuruTarihi,103) iptalSonBasvuruTarihi, dbo.fnmask(cezaIndirimTutari,\'H\') cezaIndirimTutari, ' +
            'isnull(icraEH,\'\') icraEH, isnull(aciklama, \'\') as aciklama  ' +
		    'from torba7020Parametre '+
		    'order by ID desc ';
			ajaxDataPage.autoIncrement=true;
		}

		function formLoad()
		{
				setAjaxPageParameter();
				getRecord();
		}

		function saveRecord()
		{
			ajaxDataPage.saveRecord(getRecord);
		}

		function getRecord()
		{
			ajaxDataPage.getRecord(null);
		}
		
		function formClose()
		{
			uiSoruSor('Çýkmak Ýstiyormusunuz?',closeForm);
			function closeForm(retVal)
			{
				if(retVal) {window.close()};
			}
		}

		function tahakkukTuruSec(obj)
		{
		    window.showModalDialog('../global/win.asp?strSelect=select tturu,gel_kod,gel_adi from gttttur order by gel_kod&strColumnDisplay=Kayýt No,Gelir Kodu,Gelir Adý&intnrowsperpage=15&strReturnValue=txt' + obj + ':tturu,lbl' + obj + 'Aciklama:gel_adi', window, 'resizable:yes;dialogwidth:45;status=yes;dialogheight:30;scrollbars:no;center:yes')
		}

	</script>
</head>
<body onload="formLoad()">
<form id=frm name=frm>
	<table align=center cellSpacing=0 cellpadding=1 width="600">
		<tr>
			<td height=18 colspan=2 class="visualCaption">
				7020 Sayýlý Kanun - Genel Parametreler
			</td>
		</tr>
		<tr>
		    <td>Borç (Vade) Kontrol Tarihi</td>
		    <td>
			    <input id=txtkontrolTarih size=10 maxlength=10 class=MTextBox MTType="Date" >
		    </td>
		</tr>
		<tr>
		    <td>Beyan Kontrol Tarihi</td>
		    <td>
			    <input id=txtbeyanKontrolTarihi size=10 maxlength=10 class=MTextBox MTType="Date" readonly >
		    </td>
		</tr>
		<tr>
		    <td>Son Baþvuru Tarihi</td>
		    <td>
			    <input id=txtsonBasvuruTarih size=10 maxlength=10 class=MTextBox MTType="Date" >
		    </td>
		</tr>
		<tr>
		    <td>Ýlk Taksit Son Ödeme Tarihi</td>
		    <td>
			    <input id=txtsonodemeTarih2 size=10 maxlength=10 class=MTextBox MTType="Date" />
			    <input id=txtsonodemeTarih size=10 maxlength=10 class=MTextBox MTType="Date" style="display:none" />
		    </td>
		</tr>
		<tr>
		    <td>Ýptal Ýçin Son Baþvuru Tarihi</td>
		    <td>
			    <input id=txtiptalSonBasvuruTarihi size=10 maxlength=10 class=MTextBox MTType="Date" />
		    </td>
		</tr>
		<tr>
		    <td>TEFE/ÜFE Faizi Tahakkuk Türü</td>
		    <td>
			    <input type=hidden id=txtufeTefeTturu>
			    <input id=lblufeTefeTturuAciklama disabled size =50>
			    <button id=btnTurSec onclick="tahakkukTuruSec('ufeTefeTturu')"><!--#INCLUDE FILE="../Global/Inc/Images/imgFind.inc"--></button>
		    </td>
		</tr>
		<tr>
		    <td>Katsayý Faizi Tahakkuk Türü</td>
		    <td>
			    <input type=hidden id=txtkatsayiTturu>
			    <input id=lblkatsayiTturuAciklama disabled size =50>
			    <button id=btnKatSayiSec onclick="tahakkukTuruSec('katsayiTturu')"><!--#INCLUDE FILE="../Global/Inc/Images/imgFind.inc"--></button>
		    </td>
		</tr>
		<tr>
		    <td>Ceza Ýndirim Tutarý</td>
		    <td>
			    <input id=txtcezaIndirimTutari size=10 maxlength=10 class=MTextBox MTType="Currency" disabled />
		    </td>
		</tr>
        <tr>
            <td>Ýcra Tahakkuklarýný Taksitlendir</td>
        <td>
            <select id="txticraEH" name="txticraEH" >
                <option value="E">Evet</option>
                <option value="H">Hayýr</option>
            </select>
        </td>
        </tr>
                <tr>
            <td> Açýklama </td>
            <td>
                <textarea id="txtaciklama" cols="50" rows="10"></textarea>
            </td>
        </tr>
	</table>
</form>
<table id="buttons" name="buttons" align="center" width="500">
    <tr>
	    <TD style="border-top-width:1;border-top-style:inset;text-align:center" colspan="4" nowrap>
		    <input style="width:20%" type="button" value="Kaydet" name="btnSave" id="btnSave" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" onclick="javascript:saveRecord()">
		    <input style="width:20%" type="button" value="Çýkýþ" name="btnExit" id="btnExit" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" onclick="javascript:formClose()">
	    </TD>
    </tr>
</table>
</body>
</html>