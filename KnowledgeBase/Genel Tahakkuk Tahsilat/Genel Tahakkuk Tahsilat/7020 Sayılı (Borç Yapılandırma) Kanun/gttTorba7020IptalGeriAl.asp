<%@ Language=VBScript CodePage=1254%>
<%
     Dim strTCPIP
     Dim strTarih
     Response.Expires = 0
     Response.CharSet="windows-1254"
     strTCPIP=Request.Cookies("VisitorID") 
     strTarih=Application("g_tarih" & strTCPIP)
%>
<html>
<head>
<style>
	.tblData {border:none;width:100%;margin:0px;}
	.tblDataDetail {border:1px solid #DDDDDD;text-align:right;}
	.tblFormFields TD {text-align:center;vertical-align:middle;background-color:#eee6d2;padding:1px;white-space:nowrap; font-size:20px}
</style>
<link rel="stylesheet" href="../global/css/BelsisNewStyle.css" type="text/css" />
<script id="globalFunctionScript" type="text/javascript" src="../global/ajaxFunctions/globalFunction.js"></script>
<script id="ajaxFunctions" type="text/javascript" src="../global/ajaxFunctions/ajaxMainFunctions.js"></script>
<script type="text/javascript">

    var vs_elementSrc = null;
    var oldAbsolute = null;
    function formLoad() {
        maximizeWindow();
        formFocus();
        clearForm();
    }
    function formFocus() {
        $('txtgensicilno').focus();
    }

    function iptalGeriAl() {
        if (pasifKontrol()) {
            uiBilgiVer("Öncelikle PASÝF kaydý geri almalýsýnýz !");
            return;
        }

        uiSoruSor('Geri Alma Ýþlemine Devam Edecek misiniz?', islemeDevam);
        function islemeDevam(retVal) {
            if (retVal) {
                $('btnDelete').disabled = true;
                $('txtStrSql').value = 'Exec dbo.torba7020TaksitDeleteGeriAl ' + $("txtmasterID").value + ',' + $("txtkayitTipi").value;
                ajaxExecuteSQL('Exec dbo.torba7020TaksitDeleteGeriAl ' + $("txtmasterID").value + ',' + $("txtkayitTipi").value, mahsupKontrol);
                function mahsupKontrol() {
                    ajaxBindRecords('select dbo.fnmask(sum(emanetToplam),\'H\') emanetToplam from torba7020IptalGeriAlTakip where eskiTorbaMasterID=' + $("txtmasterID").value, 'txt', mahsupKontrolDevam)
                    function mahsupKontrolDevam() {
                        if ($('txtemanetToplam').value != '' && $('txtemanetToplam').value != '0') {
                            uiSoruSor('7020 Ýptalinin Geri Almasýndan Dolayý ' + $('txtemanetToplam').value + 'TL.' + '<br>Emanet Kaydý Oluþtu<br>Mahsup Yapacakmýsýnýz ?', mahsupIslem);
                            function mahsupIslem(retVal) {
                                if (retVal) {
                                    window.open('gtt_mahsup_alindisi.asp?gensicilno=' + $('txtgensicilno').value, 'gtt_mahsup_alindisi', 'left=0,top=0,height=525,width=792,resizable=yes,fullscreen=no,status=yes,scrollbars=yes,toolbar=no,menubar=no,location=no');
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function pasifKontrol() {
        var pasifKontrol = false;
        if ($('txtkayitTipi').value == '1') {
            var objXML = $('detailXML');
            objXML.recordset.moveFirst();
            if (!objXML.recordset.EOF) {
                while (!objXML.recordset.EOF) {
                    if (objXML.recordset.fields("kayitTipi") == '2') {
                        pasifKontrol = true;
                    }
                    objXML.recordset.moveNext();
                }
            }
        }
        return pasifKontrol;
    }

    function sicilSec() {
        var strReturnWin = window.showModalDialog('../genel/modsicilwin.asp?strwinmodulno=145', 'sicilsec', 'dialogTop:240px;dialogLeft:440px;dialogWidth:205px;dialogHeight:60px;status:no;scroll:no;resizable:no;help:no;center:yes;')
        if (strReturnWin != '' && strReturnWin != null) {
            if (window.showModalDialog('../global/win.asp?strSelect=' + strReturnWin + '&intnrowsperpage=15&strReturnValue=txtgensicilno:gensicilno', window, 'resizable:yes;dialogwidth:45;status=yes;dialogheight:30;scrollbars:no;center:yes')) {
                showRecord();
            }
        }
    }

    function formClose() {
        uiSoruSor('Çýkmak Ýstiyormusunuz?', closeForm);
        function closeForm(retVal) {
            if (retVal) { window.close() };
        }
    }

    function kontrol() {
        var falseTrue = true;
        if ($('txtgensicilno').value == '') {
            uiUyariGoster('Sicil No Boþ Geçilemez !');
            falseTrue = false;
        }
        return falseTrue;
    }

    function showRecord() {
        $('btnOdemePlani').disabled = true;
        $('btnDelete').disabled = true;
        vs_elementSrc = null;
        if (!kontrol()) {
            return false;
        }

        $('divData').style.display = '';

        var strSQL = ' select adi+\' \'+soyadi+ case when isnull(unvan,\'\')<>\'\' then \' (\'+unvan+\')\' else \'\' end as adSoyadUnvan from gttsicil where gensicilno = ' + $('txtgensicilno').value;
        ajaxBindRecords(strSQL, 'txt', loadXML);
        function loadXML() {
            var strSql = 'dbo.torba7020TaksitDeleteGeriAl_READ ' + $('txtgensicilno').value;

            //$('txtStrSql').value = strSql;

            ajaxLoadDataToXML(strSql, 'detailXML', 'divData', kayitSayisiFN);
            function kayitSayisiFN() {
                var objXML = $('detailXML');
                if (objXML.recordset && objXML.recordset.state == 1) {
                    objXML.recordset.moveFirst();
                    if (objXML.recordset.fields('ID').value != '') {
                        $('txtkayitSayisi').innerHTML = 'KAYIT SAYISI  :  ' + objXML.recordset.recordCount;
                    } else {
                        $('txtkayitSayisi').innerHTML = '<h3>KRÝTERLERE UYGUN KAYIT BULUNAMADI' + '</h3>';
                        clearForm();
                    }
                }
            }
        }
    }

    function clearForm() {
        $('divData').style.display = 'none';
        $('detailXML').outerHTML = '<xml id=detailXML></xml>';
        $('btnDelete').disabled = true;
        $('btnOdemePlani').disabled = true;
        $('txtgensicilno').focus();
    }

    function kayitSec(obj) {
        var objXML = $('detailXML');
        var newAbsolute = obj.recordNumber;
        if (newAbsolute == oldAbsolute) {
            document.getElementsByName('secimChk')[oldAbsolute - 1].checked = true;
            return;
        }
        if (objXML.recordset) {
            if (vs_elementSrc != null) {
                vs_elementSrc.parentElement.parentElement.style.backgroundColor = '#FFFFFF';
            }

            if (oldAbsolute != null) {
                objXML.recordset.absolutePosition = oldAbsolute;
                document.getElementsByName('secimChk')[oldAbsolute - 1].checked = false;
            }

            objXML.recordset.absolutePosition = newAbsolute;

            window.event.srcElement.parentElement.parentElement.style.backgroundColor = '#FFE87C';
            vs_elementSrc = window.event.srcElement;
            var selectTR = obj.parentElement.parentElement;
            $("txtmasterID").value = selectTR.children(1).children(0).innerText;
            $("txtkayitTipi").value = selectTR.children(0).children(0).innerText;
            oldAbsolute = objXML.recordset.absolutePosition;

            if ($("txtkayitTipi").value == '2') {
                $('btnOdemePlani').disabled = false;
            } else {
                $('btnOdemePlani').disabled = true;
            }

            if ($("txtmasterID").value != '') {
                $('btnDelete').disabled = false;
            }
            //alert($("txtkayitTipi").value);
            //alert($("txtmasterID").value);
        }
        objXML = null;
    }

    function odemePlani() {
        if ($("txtkayitTipi").value != '2') {
            uiBilgiVer('Seçtiðiniz Kaydýn Ödeme Planý Bulunamadý');
            return;
        }
        if ($("txtmasterID").value != '') {
            var strSql = 'select ' +
						'hes.taksit, convert(varchar(10),max(hes.sonOdemeTarihi),103) AS sonOdemeTarihi, ' +
						'dbo.fnmask(sum(hes.tutar),\'H\') AS asilBorc, dbo.fnmask(sum(hes.ufeTefeFaizTutar),\'H\') AS ufeTefeFaizTutar, ' +
						'dbo.fnmask(sum(hes.katsayiFaizTutar),\'H\') AS katsayiFaizTutar, ' +
						'dbo.fnmask(sum(hes.tutar+hes.ufeTefeFaizTutar+hes.katsayiFaizTutar),\'H\') AS toplamTutar, ' +
						'(select sum(tutar_odeme) from gtttah tah where tah.gensicilno=mas.gensicilno and modulno=145 and tah.beyan_id in ( select torba7020Beyan.ID from torba7020Beyan where torba7020Beyan.torbaMasterID = ' + $("txtmasterID").value + ') and tah.borc_donemi=hes.taksit) AS odemeTutari,isnull((select sum(tutar_mahsup) from gtttah tah where tah.gensicilno=mas.gensicilno and modulno=145 and tah.beyan_id in ( select torba7020Beyan.ID from torba7020Beyan where torba7020Beyan.torbaMasterID = ' + $("txtmasterID").value + ') and tah.borc_donemi=hes.taksit),0) AS mahsupTutari ' +
						'from torba7020Master mas ' +
						'inner join torba7020Beyan bey on bey.torbaMasterID=mas.ID ' +
						'inner join torba7020Hesap hes on hes.torbaBeyanID=bey.ID ' +
						'where mas.ID=' + $("txtmasterID").value + ' ' +
						'group by mas.gensicilno,hes.taksit ' +
						'order by hes.taksit '

            ajaxLoadDataToXML(strSql, 'taksitXML', '', addElements);
            function addElements() {
                var dblodemeTutari = 0;
                var dblmahsupTutari = 0;
                var dblufeTefeFaizTutari = 0;
                var dblkatsayiFaizTutari = 0;
                var dbltoplamTutari = 0;

                var objXML = $('taksitXML');
                if (objXML.recordset) {
                    objXML.recordset.moveFirst();
                    while (!objXML.recordset.EOF) {
                        if (objXML.recordset.fields('taksit').value != '') {
                            dblodemeTutari += stringToNumeric(objXML.recordset.fields('odemeTutari').value);
                            dblmahsupTutari += stringToNumeric(objXML.recordset.fields('mahsupTutari').value);
                            dblufeTefeFaizTutari += stringToNumeric(objXML.recordset.fields('ufeTefeFaizTutar').value);
                            dblkatsayiFaizTutari += stringToNumeric(objXML.recordset.fields('katsayiFaizTutar').value);
                            dbltoplamTutari += stringToNumeric(objXML.recordset.fields('toplamTutar').value);
                        }
                        objXML.recordset.moveNext();
                    }
                }
                objXML = null;
                $('txttoplamOdeme').value = formatNumeric(dblodemeTutari);
                $('txttoplamMahsup').value = formatNumeric(dblmahsupTutari);
                $('txtufeTefeFaizTutar').value = formatNumeric(dblufeTefeFaizTutari);
                $('txtkatsayiFaizTutar').value = formatNumeric(dblkatsayiFaizTutari);
                $('txttoplamTutar').value = formatNumeric(dbltoplamTutari);

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
				'(select dbo.fnmask(isnull(sum(torba7020detay.bakiye),0)+isnull(sum(dbo.gecikme_altsinir(dbo.fgzamhes(gtttah.modulno,gtttah.tturu,torba7020detay.sonodemetarihi,tb.islemtarihi,torba7020detay.bakiye,gtttah.beyan_id,gtttah.rec_id,1))),0),\'H\') as bakiye  from gtttah  with (nolock) inner join torba7020detay on torba7020detay.tahakkukID=gtttah.rec_id inner join torba7020beyan on torba7020beyan.ID=torba7020detay.torbabeyanID  inner join torba7020master tb on tb.ID=torba7020beyan.torbaMasterID where tb.ID= ' + $("txtmasterID").value + ' and aktifpasif=\'A\') as bakiye ' +
				'from torba7020Master mas ' +
				'inner join gttsicil sic on mas.gensicilno=sic.gensicilno ' +
				'where mas.ID=' + $("txtmasterID").value

                ajaxBindRecords(strSql2, '', odemePlaniPrint);
                function odemePlaniPrint() {
                    winOdemePlani = window.open("gttTorba7020OdemePlani.asp?dokumTuru=2&sicilno=" + $('txtgensicilno').value, "odemePlani");
                }
            }
        }
    }
</script>
</head>
<body onload="formLoad()" style="text-align:center">
	<form id="frm" name="frm">
		<table cellSpacing=0 cellpadding=1 style="background-color:#EEEEEE;width:100%;height:100%;">
			<tr>
				<td height=18 class="visualCaption" style="font-size:14px">
					7020 Borç Yapýlandýrma Ýptalinin Geri Alýnmasý
				</td>
			</tr>
			<tr class=tblFormFields >
				<td height=18 align="center">
				    GTT Sicil No&nbsp&nbsp&nbsp <input id=txtgensicilno class=MTextBox MTType="Integer" size="12" maxlength="9" style="text-align:center; font-size:16px; font-weight:bold" onKeyDown="if(event.keyCode==13) showRecord();" >
				    <button tabindex=-1 title="Sicil Ara" onclick="sicilSec()" style="background-color:#E0EFF6;"><!--#INCLUDE FILE="../Global/Inc/Images/imgFindNew.inc"--></button>
				</td>
			</tr>
			<tr>
				<td style="border-top-width:1;border-top-style:inset;text-align:center;height:40px;" nowrap>
					<input id="txtadSoyadUnvan" size="50" maxlength="100" style="text-align:center; font-size:16px; font-weight:bold;border:none;background-color:#EEEEEE" readonly />
				</td>
			</tr>
			<tr>
				<td style="border-top-width:1;border-top-style:inset;text-align:center;height:40px;" nowrap>
					<button id="btnOdemePlani" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" style="width:90px;margin:0px 3px 0px 3px;" onclick="odemePlani()" >Ödeme Planý</button>
					<button id="btnDelete" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" style="width:90px;margin:0px 3px 0px 3px;" onclick="iptalGeriAl()" >Ýptalden Geri Al</button>
					<button id="btnExit" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" style="width:75px;margin:0px 3px 0px 3px" onclick="formClose()">Çýkýþ</button>
				</td>
			</tr>
		    <tr>
			    <td colspan=1 style="padding:0px;text-align:center;font-size:11px;font-weight:bold;color:maroon;background-color:#e3e4f0;">
                    <span id="txtkayitSayisi"></span>
				    <div id=divData style="width:100%;overflow:scroll;height:100%;padding:0px;margin:0px;display:none" >
				        <table class=tblData cellSpacing=0 cellpadding=1 datasrc=#detailXML >
                            <thead>
                                <tr style="position:relative;top:expression(offsetParent.scrollTop)">
                                    <td class="uiSubHeader">Seçim</td>
                                    <td class="uiSubHeader">Durumu</td>
                                    <td class="uiSubHeader">Ýþlem Tarihi</td>
                                    <td class="uiSubHeader">Taksit Sayýsý</td>
                                    <td class="uiSubHeader">Toplam Taksit Tutarý</td>
                                </tr>
                            </thead>
				            <tr style="cursor:hand; height:30px; font-size:14px;" >
				                <td style="display:none;">
					                <span datafld="kayitTipi" />
				                </td>
				                <td style="display:none;">
					                <span datafld="ID" />
				                </td>
				                <td class=tblDataDetail style="font-weight:bold;text-align:center;" >
					                <input id="secimChk" name="secimChk" type="checkbox" style="border-style:none;cursor:pointer;" onclick="kayitSec(this)"/>
				                </td>
				                <td class=tblDataDetail style="font-weight:bold;text-align:center;" >
					                <span datafld="kayitTipiAciklama" />
				                </td>
				                <td class=tblDataDetail style="font-weight:bold;text-align:center;" >
					                <span datafld="islemTarihi" />
				                </td>
				                <td class=tblDataDetail style="font-weight:bold;text-align:center;" >
					                <span datafld="taksitSayi" />
				                </td>
				                <td class=tblDataDetail style="font-weight:bold;text-align:right;" >
					                <span datafld="tutar" />
				                </td>
				            </tr>
				        </table>
				    </div>
			    </td>
		    </tr>
		</table>
    <textarea id=txtStrSql style="display:none" ></textarea> 
    <textarea id=txtStrSql2 style="display:none" ></textarea> 
    <input id=txtdetailXML style="display:none" >
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
    <input id=txtbakiye style="display:none"></input>
    <input id=txtmasterID style="display:none"></input> 
    <input id=txtkayitTipi style="display:none"></input>
    <input id=txtemanetToplam style="display:none"></input>
    <xml id=detailXML></xml>
    <xml id=taksitXML></xml>
    <xml id=dataXML></xml>
	</form>
</body>
</html>
