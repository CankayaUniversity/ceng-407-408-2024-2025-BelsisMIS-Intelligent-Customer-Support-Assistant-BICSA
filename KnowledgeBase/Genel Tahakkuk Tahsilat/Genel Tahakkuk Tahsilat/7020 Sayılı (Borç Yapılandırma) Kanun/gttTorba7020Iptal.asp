<%@ Language=VBScript CodePage=1254%>
<%
     Dim strTCPIP
     Response.Expires = 0
     Response.CharSet="windows-1254"
     strTCPIP=Request.Cookies("VisitorID") 
     GetKulHak()
%>
<!--#INCLUDE FILE="../Global/Inc/Other/GetKulHakJS.INC"-->
<html>
<head>
<style>
	.tblData {border:none;width:100%;margin:0px;}
	.tblDataDetail {border:1px solid #DDDDDD;text-align:right;}
	.tblFormFields TD {text-align:center;vertical-align:middle;background-color:#eee6d2;padding:1px;white-space:nowrap; font-size:20px}
</style>
<!--<meta http-equiv="content-type" content="text/html; charset=windows-1254"> -->
<link rel="stylesheet" href="../global/css/BelsisNewStyle.css" type="text/css" />
<script id="globalFunctionScript" type="text/javascript" src="../global/ajaxFunctions/globalFunction.js"></script>
<script id="ajaxFunctions" type="text/javascript" src="../global/ajaxFunctions/ajaxMainFunctions.js"></script>
<script id="belsisTree" type="text/javascript" src="../global/ajaxFunctions/belsisTree.js"></script>
<script type="text/javascript">

	function formLoad()
	{
        maximizeWindow();

        objTree = new belsisTree('borcList');
        objTree.caption = '<b>İşlem Tarihi/Taksit</b>';
        objTree.isIconless = true;
        objTree.footer = true;

        objTree.addDataColumn('currency', 75, '<b>Taksit<br>Tutarı</b>', 'taksitTutar', 'right', true, true);
        objTree.addDataColumn('currency', 75, '<b>Ödeme<br>Tutarı</b>', 'taksitOdeme', 'right', true, true);
        objTree.addDataColumn('currency', 75, '<b>Mahsup<br>Tutarı</b>', 'taksitMahsup', 'right', true, true);
        objTree.addDataColumn('text', 250, '<b>Aktif/Pasif</b>', 'aktifPasif', 'center');
		objTree.setLevelColors('#FFFFFF,#FFFFFF');

        objTree.drawTree();

        formFocus();
	}
	function formFocus() {
	    $('txtgensicilno').focus();
	}

	function iptal() {
	    var activeNode = objTree.getActiveNode();
	    if (activeNode != null) 
	    {
	        uiSoruSor('İptal Etmek İstiyormusunuz?', kayitSil);
	        function kayitSil(retVal) 
	        {
	            if (retVal) 
	            {
					if (activeNode.getDataValue(3).indexOf('YENİDEN YAPILANDIRILMIŞ',0)>0)
		                ajaxExecuteSQL('Exec dbo.torba7020RefinansTaksitDelete ' + activeNode.nodeID, returnFunction);
					else
						ajaxExecuteSQL('Exec dbo.torba7020TaksitDelete ' + activeNode.nodeID, returnFunction);
	                function returnFunction(retVal) 
	                {
	                    if (retVal) 
	                    {
	                        objTree.deleteNode(activeNode.nodeID);
							taksitGoruntule();
	                    }
	                }
	            };
	        }
	    } else {
	        uiUyariGoster('İptal Etmek İstediğiniz Kaydı Seçmelisiniz');
	    }
	}

	function formClose() {
	    uiSoruSor('Çıkmak İstiyormusunuz?', closeForm);
	    function closeForm(retVal) {
	        if (retVal) { window.close() };
	    }
	}

	function sicilSec() {
	    var strReturnWin = window.showModalDialog('../genel/modsicilwin.asp?strwinmodulno=145', 'sicilsec', 'dialogTop:240px;dialogLeft:440px;dialogWidth:205px;dialogHeight:60px;status:no;scroll:no;resizable:no;help:no;center:yes;')
	    if (strReturnWin != '' && strReturnWin != null) {
	        if (window.showModalDialog('../global/win.asp?strSelect=' + strReturnWin + '&intnrowsperpage=15&strReturnValue=txtgensicilno:gensicilno', window, 'resizable:yes;dialogwidth:45;status=yes;dialogheight:30;scrollbars:no;center:yes')) {
	        }
	    }
	}

	function taksitGoruntule() {
	    if ($('txtgensicilno').value=='' || $('txtgensicilno').value==null || $('txtgensicilno').value=='0') {return false;}

        var strSQL = ' select adi+\' \'+soyadi+ case when isnull(unvan,\'\')<>\'\' then \' (\'+unvan+\')\' else \'\' end as adSoyadUnvan from gttsicil where gensicilno = ' + $('txtgensicilno').value;
        ajaxBindRecords(strSQL,'',taksitGoruntu);

		function taksitGoruntu()
		{
				var strSql = 'select x.beyanID AS nodeID, '+
							'case when x.taksit is null then \'<b>İşlem Tarihi</b>:\' + islemTarihi + \'&nbsp;-&nbsp;<b>İşlem Saati</b>: \' + islemSaati + \'&nbsp;-&nbsp;<b>İşlem Yapan</b>: \' + kuladi else \'<b>\'+cast(x.taksit as varchar(2))+\'</b>.Taksit\' + \'&nbsp;-&nbsp;<b>Son Ödeme Tarihi</b>:\' + sonOdemeTarihi end AS nodeText, '+
							'case when x.taksit is not null Then x.beyanID end AS parentID, '+
							'\'<font color="#571B7e"><b>\'+aktifPasif+\'</b></font>\' AS aktifPasif, '+
							'taksitTutar, taksitOdeme,taksitMahsup ' +
							'from '+
							'( '+
							'   select mas.ID as beyanID, convert(nvarchar(5),max(mas.kultarih),108) as islemSaati, max(kul.kuladi) as kuladi, tah.taksit, convert(varchar(10),max(mas.islemTarihi),103) AS islemTarihi, ' +
							'   case max(mas.aktifPasif) when \'P\' Then \'PASİF\' when \'A\' Then \'AKTİF\' end + case when (select count(*) from torba7020Master masRef where masRef.refinansID = mas.ID)>0 then \' - YENİDEN YAPILANDIRILMIŞ\' else \'\' end AS aktifPasif, ' +
							'   sum(isnull(tah.tutar,0)+isnull(case when tah.tutar_azaltan>0 Then tah.tutar_azaltan end,0)) taksitTutar, ' +
							'	isnull(sum(tah.tutar_odeme),0) taksitOdeme,isnull(sum(tah.tutar_mahsup),0) as taksitMahsup, convert(nvarchar(10),max(tarih_son),103) as sonOdemeTarihi ' +
							'   from torba7020Master mas ' +
							'   inner join torba7020Beyan bey on mas.ID=bey.torbaMasterID ' +
							'   inner join kullanici kul on kul.kulno = mas.kulno ' +
							'   inner join gtttah tah on tah.gensicilno = mas.gensicilno and modulno=145 and tah.beyan_id = bey.ID ' +
							'   where mas.gensicilno=' + $('txtgensicilno').value + ' '+
							'   group by mas.ID, tah.taksit with rollup '+
							') x '+
							'where x.beyanID is not null or x.taksit is not null '+
							'order by aktifPasif,beyanID, taksit ';			

							$('txtsql').value = strSql;
							objTree.loadFromSQL(strSql);
		}
	}

	function tefeUfeIndirim() {

	    var activeNode = objTree.getActiveNode();
	    if (activeNode != null) 
	    {
	        uiSoruSor('TEFE/ÜFE İndirimi Uygulanacak, Devam Etmek İstiyormusunuz?', rettefeUfeIndirim);
	        function rettefeUfeIndirim(retVal) {
	            if (retVal) {
	                var strSQL='Exec dbo.torba7020TefeAzaltSPSicil '+objTree.getActiveNode().nodeID;
	                ajaxExecuteSQL(strSQL, tefeUfeIndirimIslemTamam);
	                function tefeUfeIndirimIslemTamam(retVal) {
	                    taksitGoruntule();
	                }
	            }
	        }	    
	    } else {
	        uiUyariGoster('TEFE/ÜFE İndirimi Yapmak İstediğiniz Kaydı Seçmelisiniz');
	    }
	}

	function odemePlani()
	{
		var activeNode = objTree.getActiveNode();
		if (activeNode != null) 
		{
		    var strSql = 'select ' +
							'hes.taksit, convert(varchar(10),max(hes.sonOdemeTarihi),103) AS sonOdemeTarihi, ' +
							'dbo.fnmask(sum(hes.tutar),\'H\') AS asilBorc, dbo.fnmask(sum(hes.ufeTefeFaizTutar),\'H\') AS ufeTefeFaizTutar, ' +
							'dbo.fnmask(sum(hes.katsayiFaizTutar),\'H\') AS katsayiFaizTutar, ' +
							'dbo.fnmask(sum(hes.tutar+hes.ufeTefeFaizTutar+hes.katsayiFaizTutar),\'H\') AS toplamTutar, ' +
							'(select sum(tutar_odeme) from gtttah tah where tah.gensicilno=mas.gensicilno and modulno=145 and tah.beyan_id in ( select torba7020Beyan.ID from torba7020Beyan where torba7020Beyan.torbaMasterID = ' + activeNode.nodeID + ') and tah.borc_donemi=hes.taksit) AS odemeTutari,isnull((select sum(tutar_mahsup) from gtttah tah where tah.gensicilno=mas.gensicilno and modulno=145 and tah.beyan_id in ( select torba7020Beyan.ID from torba7020Beyan where torba7020Beyan.torbaMasterID = ' + activeNode.nodeID + ') and tah.borc_donemi=hes.taksit),0) AS mahsupTutari ' +
							'from torba7020Master mas ' +
							'inner join torba7020Beyan bey on bey.torbaMasterID=mas.ID ' +
							'inner join torba7020Hesap hes on hes.torbaBeyanID=bey.ID ' +
							'where mas.ID=' + activeNode.nodeID + ' ' +
							'group by mas.gensicilno,hes.taksit ' +
							'order by hes.taksit ';

			ajaxLoadDataToXML(strSql, 'taksitXML', '', addElements);
			function addElements() {
				var dblodemeTutari = 0;
				var dblmahsupTutari=0;
				var dblufeTefeFaizTutari=0;
				var dblkatsayiFaizTutari=0;
				var dbltoplamTutari=0;
			
				var objXML = $('taksitXML');
				if (objXML.recordset) {
					objXML.recordset.moveFirst();
					while (!objXML.recordset.EOF) {
						if (objXML.recordset.fields('taksit').value != '') {
							dblodemeTutari += stringToNumeric(objXML.recordset.fields('odemeTutari').value);
						    dblmahsupTutari+=stringToNumeric(objXML.recordset.fields('mahsupTutari').value);
						    dblufeTefeFaizTutari+=stringToNumeric(objXML.recordset.fields('ufeTefeFaizTutar').value);
						    dblkatsayiFaizTutari+=stringToNumeric(objXML.recordset.fields('katsayiFaizTutar').value);
						    dbltoplamTutari+=stringToNumeric(objXML.recordset.fields('toplamTutar').value);
						  
						}
						objXML.recordset.moveNext();
					}
				}
				objXML = null;
				$('txttoplamOdeme').value = formatNumeric(dblodemeTutari);
				$('txttoplamMahsup').value = formatNumeric(dblmahsupTutari);
				$('txtufeTefeFaizTutar').value=formatNumeric(dblufeTefeFaizTutari);
				$('txtkatsayiFaizTutar').value=formatNumeric(dblkatsayiFaizTutari);
				$('txttoplamTutar').value=formatNumeric(dbltoplamTutari);
			
				var strSql2 = 'select ' +
					'mas.gensicilno AS sicilNo, ' +
					'dbo.torba7020AboneBul(mas.ID,2) AS aboneler, ' +
					'convert(varchar(10),mas.islemTarihi,103) AS islemTarihi, ' +
					'mas.evrakNo, ' +
					'sic.mernis_no AS mernisNo, ' +
					'isnull(sic.adi,\'\')+\' \'+isnull(sic.soyadi,\'\') adiSoyadi, ' +
					'sic.unvan, dbo.fnmask(affaEsasTutar,\'H\') AS asilBorc, ' +
					'dbo.fnmask(ufeTefeFaizTutar,\'H\') AS ufeTefeFaizTutar, dbo.fnmask(katsayiFaizTutar,\'H\') AS katsayiFaizTutar, ' +
					'dbo.fnmask(affaEsasTutar + ufeTefeFaizTutar + katsayiFaizTutar,\'H\') AS toplamTutar, ' +
                    '(select ' +
                            'dbo.fnmask(sum(isnull(torba7020detay.bakiye,0)+isnull(torba7020detay.gecikme,0)),\'H\') ' +
                            'from torba7020detay with (nolock) ' +
                            'inner join torba7020beyan with (nolock) on torba7020beyan.ID=torba7020detay.torbabeyanID ' +
                            'where torba7020beyan.torbaMasterID=mas.ID ' +
                    ') as bakiye ' +
                    'from torba7020Master mas ' +
					'inner join gttsicil sic on mas.gensicilno=sic.gensicilno ' +
					'where mas.ID=' + activeNode.nodeID;

				ajaxBindRecords(strSql2, '', odemePlaniPrint);
				function odemePlaniPrint() {
					winOdemePlani = window.open("gttTorba7020OdemePlani.asp?dokumTuru=2&sicilno="+$("txtgensicilno").value, "odemePlani");
				}
			}
		} else 
		{
			uiUyariGoster('Ödeme Planı Almak İstediğiniz Kaydı Seçmelisiniz');
		}
	}
</script>
</head>
<body onload="formLoad()" style="text-align:center">
	<form id="frm" name="frm">
		<table cellSpacing=0 cellpadding=1 style="background-color:#EEEEEE;width:100%;">
			<tr>
				<td height=18 class="visualCaption" style="font-size:14px">
					7020 Borç Yapılandırma Kayıtları Görüntüleme / İptal
				</td>
			</tr>
			<tr class=tblFormFields >
				<td height=18 align="center">
				    GTT Sicil No&nbsp&nbsp&nbsp <input id=txtgensicilno class=MTextBox MTType="Integer" size="12" maxlength="9" style="text-align:center; font-size:16px; font-weight:bold" onKeyDown="if(event.keyCode==13) taksitGoruntule();" >
				    <button tabindex=-1 title="Sicil Ara" onclick="sicilSec()" style="background-color:#E0EFF6;"><!--#INCLUDE FILE="../Global/Inc/Images/imgFindNew.inc"--></button>
				</td>
			</tr>
			<tr>
				<td style="border-top-width:1;border-top-style:inset;text-align:center;height:40px;" nowrap>
					<input id=txtadSoyadUnvan size="50" maxlength="100" style="text-align:center; font-size:16px; font-weight:bold;border:none;background-color:#EEEEEE" >
				</td>
			</tr>
			<tr>
				<td style="border-top-width:1;border-top-style:inset;text-align:center;height:40px;" nowrap>
					<button id="btnDelete" name="btnDelete" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" style="width:90px;margin:0px 3px 0px 3px;" onclick="iptal()" >İptal Et</button>
					<button id="btnPrint" name="btnPrint" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" style="width:75px;margin:0px 3px 0px 3px" onclick="odemePlani()">Ödeme Planı</button>
					<button id="btnTekrarYapilandir" name="btnTekrarYapilandir" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" style="width:90px;margin:0px 3px 0px 3px;" onclick="if (!objTree.getActiveNode()) {uiUyariGoster('Yapılandırma Seçmelisiniz'); return;} if (objTree.getActiveNode().getDataValue(3).indexOf('PASİF',0)>0 ){uiUyariGoster('Pasif Kaydı Yapılandıramazsınız!!!'); return;} if (objTree.getActiveNode().getDataValue(3).indexOf('YENİDEN YAPILANDIRILMIŞ',0)>0 ){uiUyariGoster('Seçtiğiniz Kayıt Zaten Yeniden Yapılandırılmış!!!'); return;} if (objTree.getActiveNode().nodeID>0) { window.open('gttTorba7020Refinans.asp?ID='+objTree.getActiveNode().nodeID, 'Refinans'); } else {uiUyariGoster('Yapılandırma Seçmelisiniz');} " >Tekrar Yapılandır</button>
					<button id="btnTefeIndirim" name="btnTefeIndirim" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" style="width:150px;margin:0px 3px 0px 3px; display:none;" onclick="tefeUfeIndirim()" >TEFE/ÜFE İndirimi Uygula</button>
					<button id="btnExit" name="btnExit" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" style="width:75px;margin:0px 3px 0px 3px" onclick="formClose()">Çıkış</button>
				</td>
			</tr>
		    <tr>
			    <td colspan=1 style="padding:0px;text-align:center;font-size:11px;font-weight:bold;color:maroon;background-color:#e3e4f0">
				    <div id="borcList" style="margin:0px;padding:2px;border:none;width:100%;height:100%;overflow-y:scroll;"></div>
			    </td>
		    </tr>
		</table>
    <textarea id="txtsql" style="display:none;"></textarea> 
    <input id=txtislemTarihi style="display:none"/>
    <input id=txtsicilNo style="display:none"/>
    <input id=txtevrakNo style="display:none"/>
    <input id=txtmernisNo style="display:none"/>
    <input id=txtadiSoyadi style="display:none"/>
    <input id=txtunvan style="display:none"/>
    <input id=txtaboneler style="display:none"/>
    <input id=txtasilBorc style="display:none"/>
    <span id=txtufeTefeFaizTutar style="display:none"></span>
    <span id=txtkatsayiFaizTutar style="display:none"></span>
    <span id=txttoplamTutar style="display:none"></span>
    <input id=txttoplamOdeme style="display:none"/>
    <input id=txttoplamMahsup style="display:none"/>
    <input id=txtbakiye style="display:none" />
    <xml id=taksitXML><root><row taksit="" sonOdemeTarihi="" asilBorc="" ufeTefeFaizTutar="" katsayiFaizTutar="" toplamTutar="" odemeTutari="" mahsupTutari=""/></root></xml>
	</form>
</body>
</html>