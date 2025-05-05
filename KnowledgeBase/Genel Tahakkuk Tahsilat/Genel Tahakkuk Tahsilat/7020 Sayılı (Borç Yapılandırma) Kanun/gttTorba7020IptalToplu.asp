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
<!--<meta http-equiv="content-type" content="text/html; charset=windows-1254"> -->
<link rel="stylesheet" href="../global/css/BelsisNewStyle.css" type="text/css" />
<script id="globalFunctionScript" type="text/javascript" src="../global/ajaxFunctions/globalFunction.js"></script>
<script id="ajaxFunctions" type="text/javascript" src="../global/ajaxFunctions/ajaxMainFunctions.js"></script>
<script type="text/javascript">

	function formLoad()
	{
        maximizeWindow();
        formFocus();
        clearForm();
	}

	function formFocus() {
	    $('txtilkgensicilno').focus();
	}

	function topluIptal() {
	    var objXML = $('detailXML');
	    var xmlStr;

	    if (objXML.recordset && objXML.recordset.state == 1) {
	        objXML.recordset.moveFirst();
	        if (!objXML.recordset.EOF) {
                xmlStr='<root>'
	            while (!objXML.recordset.EOF) {
	                if (objXML.recordset.fields('secim').value != 0) {
	                    xmlStr = xmlStr + '<row ID="' + objXML.recordset.fields('ID').value + '"  />'
	                }
                    
	                objXML.recordset.moveNext();
	            }
	        xmlStr = xmlStr + '</root>'
	    }
	    if (xmlStr.length <= 13) 
	        {
	            uiUyariGoster('İptal Etmek İstediğiniz Kayıtları Seçiniz !');
	            return;
	        }
	    }

	    uiSoruSor('İptal İşlemine Devam Edecek misiniz?', islemeDevam);
	    function islemeDevam(retVal) 
        {
            if (retVal) {
                ajaxExecuteSQL('Exec dbo.torba7020Topluiptal ' + $('txtilkgensicilno').value + ',' + $('txtsongensicilno').value + ',\'' + xmlStr + '\'', returnExecute);
                function returnExecute(retVal) {
                    if (retVal) 
                    {
                        uiBilgiVer('İşlem Tamamlandı', clearForm);
                    }
                }

            }
            objXML = null;
            xmlStr = null;
        }
	}

	function formClose() {
	    uiSoruSor('Çıkmak İstiyormusunuz?', closeForm);
	    function closeForm(retVal) {
	        if (retVal) { window.close() };
	    }
	}

	function kontrol() {
	    var falseTrue=true;
	    if ($('txtilkgensicilno').value == '') {
	        uiUyariGoster('İlk Sicil No Boş Geçilemez !');
	        falseTrue = false;
	    }
	    if ($('txtsongensicilno').value == '') {
	        uiUyariGoster('Son Sicil No Boş Geçilemez !')
	        falseTrue = false;
	    }
	    if ($('txtsongensicilno').value < $('txtilkgensicilno').value) {
	        uiUyariGoster('İlk Sicil No Son Sicilno dan Büyük Olamaz !')
	        falseTrue = false;
	    }
	    return falseTrue;
    }
	
	function showRecord() {
	    if (!kontrol()) {
	        return false;
	    }

	    $('divData').style.display = '';

	    var strSql ='select '+
	                    '0 AS secim, '+
                        'mas.ID, '+
                        'max(mas.gensicilno) AS gensicilno, '+
                        'ltrim(rtrim(isnull(max(sic.adi),\'\')+\' \'+isnull(max(sic.soyadi),\'\'))) AS adiSoyadi, '+
                        'convert(varchar(10),max(mas.islemTarihi),103) AS islemTarihi, '+
                        'max(mas.taksitSayi) AS taksitSayi, '+
                        'dbo.fnmask(max(mas.affaEsasTutar)+max(mas.ufeTefeFaizTutar)+max(mas.katsayiFaizTutar),\'H\') AS tutar '+
	                    'from torba7020Master mas '+
	                    'inner join torba7020Beyan bey on mas.ID=bey.torbaMasterID '+
	                    'inner join gttsicil sic on mas.gensicilno=sic.gensicilno '+
	                    'where mas.gensicilno between '+$('txtilkgensicilno').value+' and '+$('txtsongensicilno').value+' '+
	                    'and dbo.torba7020IptalBul (mas.ID,\''+convertSQLDate("<%=strTarih%>")+'\')>0 '+
	                    'group by mas.ID '+
	                    'order by max(mas.taksitSayi),max(mas.gensicilno) ';

	    ajaxLoadDataToXML(strSql, 'detailXML', 'divData', kayitSayisiFN);
        function kayitSayisiFN() 
        {
            var objXML = $('detailXML');
	        if (objXML.recordset && objXML.recordset.state == 1) 
	        {
	            objXML.recordset.moveFirst();
	            if (objXML.recordset.fields('ID').value != '') 
	            {
	                $('txtkayitSayisi').innerHTML = 'LİSTELENEN KAYIT SAYISI  :  ' + objXML.recordset.recordCount;
	                $('btnDelete').disabled = false;
	            } else 
	            {
    	            $('txtkayitSayisi').innerHTML = '<h3>KRİTERLERE UYGUN KAYIT BULUNAMADI' +'</h3>';
    	            $('divData').style.display = 'none';
	            }
	        }
        }
	}

	function clearForm() {
	    $('divData').style.display = 'none';
	    $('detailXML').outerHTML = '<xml id=detailXML></xml>';
	    $('txtilkgensicilno').value = '';
	    $('txtsongensicilno').value = '';
	    $('btnDelete').disabled = true;
	    $('txtilkgensicilno').focus();
	}

		function hepsiniSec(checked) {
			var obj=document.getElementsByName('secim');
			if (obj)
			{
				for (var i=0; i<obj.length; i++)
				{
				    obj[i].checked = checked;
					if (checked)
						obj[i].parentNode.parentNode.style.backgroundColor='#FFFFCC';
					else
						obj[i].parentNode.parentNode.style.backgroundColor='FFFFFF';
				}
				obj=null;
			}
		}

        function settingColor(obj) {
            if (obj.checked)
                obj.parentNode.parentNode.style.backgroundColor = '#FFFFCC';
            else
                obj.parentNode.parentNode.style.backgroundColor = '#FFFFFF';
        }

        function odemePlani(obj) {
            var strGensicilno = obj.parentNode.parentNode.childNodes[3].innerText;
            var strmasID = obj.parentNode.parentNode.childNodes[1].innerText;
            if (strmasID != '') {
                var strSql = 'select ' +
							'hes.taksit, convert(varchar(10),max(hes.sonOdemeTarihi),103) AS sonOdemeTarihi, ' +
							'dbo.fnmask(sum(hes.tutar),\'H\') AS asilBorc, dbo.fnmask(sum(hes.ufeTefeFaizTutar),\'H\') AS ufeTefeFaizTutar, ' +
							'dbo.fnmask(sum(hes.katsayiFaizTutar),\'H\') AS katsayiFaizTutar, ' +
							'dbo.fnmask(sum(hes.tutar+hes.ufeTefeFaizTutar+hes.katsayiFaizTutar),\'H\') AS toplamTutar, ' +
							'(select sum(tutar_odeme) from gtttah tah where tah.gensicilno=mas.gensicilno and modulno=145 and tah.beyan_id in ( select torba7020Beyan.ID from torba7020Beyan where torba7020Beyan.torbaMasterID = ' + strmasID + ') and tah.borc_donemi=hes.taksit) AS odemeTutari,isnull((select sum(tutar_mahsup) from gtttah tah where tah.gensicilno=mas.gensicilno and modulno=145 and tah.beyan_id in ( select torba7020Beyan.ID from torba7020Beyan where torba7020Beyan.torbaMasterID = ' + strmasID + ') and tah.borc_donemi=hes.taksit),0) AS mahsupTutari ' +
							'from torba7020Master mas ' +
							'inner join torba7020Beyan bey on bey.torbaMasterID=mas.ID ' +
							'inner join torba7020Hesap hes on hes.torbaBeyanID=bey.ID ' +
							'where mas.ID=' + strmasID + ' ' +
							'group by mas.gensicilno,hes.taksit ' +
							'order by hes.taksit '
                
                ajaxLoadDataToXML(strSql, 'taksitXML', '', addElements);
                function addElements() {
                    var dblodemeTutari = 0;
                    var dblmahsupTutari = 0;
                    var objXML = $('taksitXML');
                    if (objXML.recordset) {
                        objXML.recordset.moveFirst();
                        while (!objXML.recordset.EOF) {
                            if (objXML.recordset.fields('taksit').value != '') {
                                dblodemeTutari += stringToNumeric(objXML.recordset.fields('odemeTutari').value);
                                dblmahsupTutari += stringToNumeric(objXML.recordset.fields('mahsupTutari').value);
                            }
                            objXML.recordset.moveNext();
                        }
                    }
                    objXML = null;
                    $('txttoplamOdeme').value = formatNumeric(dblodemeTutari);
                    $('txttoplamMahsup').value = formatNumeric(dblmahsupTutari);
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
                    '(select '+
                            'dbo.fnmask(sum(isnull(torba7020detay.bakiye,0)+isnull(torba7020detay.gecikme,0)),\'H\') '+
                            'from torba7020detay with (nolock) '+
                            'inner join torba7020beyan with (nolock) on torba7020beyan.ID=torba7020detay.torbabeyanID '+
                            'where torba7020beyan.torbaMasterID=mas.ID '+
                    ') as bakiye '+
					'from torba7020Master mas ' +
					'inner join gttsicil sic on mas.gensicilno=sic.gensicilno ' +
					'where mas.ID=' + strmasID

                    $("txtsql").value = strSql2;
                    ajaxBindRecords(strSql2, 'txt', odemePlaniPrint);
                    function odemePlaniPrint() {
                        winOdemePlani = window.open("gttTorba7020OdemePlani.asp?dokumTuru=2&sicilno=" + strGensicilno, "odemePlani");
                    }
                }
            }
        }

        function sicilnoOnchange(obj) {
            if (obj.name == 'txtilkgensicilno') {
                $('txtsongensicilno').value = $('txtilkgensicilno').value;
            }
            $('detailXML').outerHTML = '<xml id=detailXML></xml>';
            $('divData').style.display = 'none';
            $('txtkayitSayisi').innerHTML = '';
        }

        function tefeArttir() {
            uiBox = new uiModalBox(460, 250);
            uiBox.contentElement = $('uyariTable');
            uiBox.show();
            $('btntefeArttirDevam').style.display = '';
            $('btntefeAzaltDevam').style.display = 'none';

            $("lblUyari").innerHTML = '<font color="red">Sayın ' + '<%=Application("g_kuladi" & strTCPIP)%>;</font>' + '<p>İşleme devam etmeniz durumunda peşin olarak yapılandırılan ' +
                've % 50 indirim uygulanan 7020 taksitlerinizdeki TEFE/ÜFE faizlerine uygulanan indirim geri alınacaktır!<br><br>İşlemi onaylıyor musunuz?<br><br>&nbsp'
        }
        function tefeAzalt() {
            uiBox = new uiModalBox(460, 250);
            uiBox.contentElement = $('uyariTable');
            uiBox.show();
            $('btntefeArttirDevam').style.display = 'none';
            $('btntefeAzaltDevam').style.display = '';
            $("lblUyari").innerHTML = '<font color="red">Sayın ' + '<%=Application("g_kuladi" & strTCPIP)%>;</font>' + '<p>İşleme devam etmeniz durumunda peşin olarak yapılandırılan ' +
                've daha önce iptal edilen "% 50 TEFE/ÜFE indirimi" tekrar uygulanacaktır !<br><br>İşlemi onaylıyor musunuz?<br><br>&nbsp'
        }

        function tefeArttirDevam() {
            uiSoruSor('İşleme Başlanacak Devam Etmek İstiyor musunuz?', uiReturn);
            function uiReturn(retVal) {
                if (retVal) {
                    ajaxExecuteSQL('Exec dbo.torba7020TefeArttir', tefeArttirIslemTamam);
                    function tefeArttirIslemTamam(retVal) {
                        if (retVal) {
                            uiBilgiVer('İŞLEM TAMAMLANDI', uiReturn2)
                            function uiReturn2() {
                                uiBox.close();
                            }
                        } else {
                            uiBox.close();
                        }
                    }
                };
            }
        }

        function tefeAzaltDevam() {
            uiSoruSor('İşleme Başlanacak Devam Etmek İstiyor musunuz?', uiReturn);
            function uiReturn(retVal) {
                if (retVal) {
                    ajaxExecuteSQL('Exec dbo.torba7020TefeAzaltSP', tefeArttirIslemTamam);
                    function tefeArttirIslemTamam(retVal) {
                        if (retVal) {
                            uiBilgiVer('İŞLEM TAMAMLANDI', uiReturn2)
                            function uiReturn2() {
                                uiBox.close();
                            }
                        } else {
                            uiBox.close();
                        }
                    }
                };
            }
        }

</script>
</head>
<body onload="formLoad()" style="text-align:center">
	<form id="frm" name="frm">
		<table cellSpacing=0 cellpadding=1 style="background-color:#EEEEEE;width:100%;">
			<tr>
				<td height=18 class="visualCaption" style="font-size:14px">
					7020 Borç Yapılandırma Kayıtları Toplu İptal
				</td>
			</tr>
			<tr class=tblFormFields >
				<td height=18 align="center">
				    GTT Sicil No&nbsp&nbsp&nbsp 
				    <input id=txtilkgensicilno name=txtilkgensicilno class=MTextBox MTType="Integer" size="12" maxlength="9" style="text-align:center; font-size:16px; font-weight:bold" onchange="sicilnoOnchange(this)">
				    <input id=txtsongensicilno name=txtsongensicilno class=MTextBox MTType="Integer" size="12" maxlength="9" style="text-align:center; font-size:16px; font-weight:bold" onchange="sicilnoOnchange(this)">
				</td>
			</tr>
			<tr>
				<td style="border-top-width:1;border-top-style:inset;text-align:center;height:40px;" nowrap>
					<button id="btnPrint" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" style="width:75px;margin:0px 3px 0px 3px" onclick="showRecord()">Kayıtları Çağır</button>
					<button id="btnDelete" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" style="width:90px;margin:0px 3px 0px 3px;" onclick="topluIptal()" >İptal Et</button>
					<button id="btnTefeArttir" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" style="width:150px;margin:0px 3px 0px 3px" onclick="tefeArttir()">TEFE/ÜFE İndirimini İptal Et</button>
					<button id="btnTefeArttir" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" style="width:150px;margin:0px 3px 0px 3px" onclick="tefeAzalt()">TEFE/ÜFE İndirimi Uygula</button>
					<button id="btnExit" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" style="width:75px;margin:0px 3px 0px 3px" onclick="formClose()">Çıkış</button>
				</td>
			</tr>
		    <tr>
			    <td colspan=1 style="padding:0px;text-align:center;font-size:11px;font-weight:bold;color:maroon;background-color:#e3e4f0;">
                    <span id=txtkayitSayisi></span>
				    <div id=divData style="width:100%;overflow:scroll;height:100%;padding:0px;margin:0px;" style="display:none" >
				        <table class=tblData cellSpacing=0 cellpadding=1 datasrc=#detailXML >
                        <thead>
                            <tr style="position:relative;top:expression(offsetParent.scrollTop)">
                            <td class=uiSubHeader>Seçim<br>
                            <input type=checkbox name=tumSecim onclick="hepsiniSec(this.checked)" />
                            </td>
                            <td class=uiSubHeader>Ödeme Planı</td>
                            <td class=uiSubHeader>Sicil No</td>
                            <td class=uiSubHeader>Adı Soyadı</td>
                            <td class=uiSubHeader>İşlem Tarihi</td>
                            <td class=uiSubHeader>Taksit Sayısı</td>
                            <td class=uiSubHeader>Toplam Taksit Tutarı</td>
                            </tr>
                        </thead>
				        <tr style="cursor:hand" >
				            <td class=tblDataDetail style="text-align:center;width:30px;">
					            <input type=checkbox name=secim datafld=secim style="border:none" onclick="settingColor(this)"/>
				            </td>
				            <td class=tblDataDetail style="font-weight:bold;text-align:center; display:none;">
					            <span datafld=ID />
				            </td>
				            <td class=tblDataDetail style="font-weight:bold;text-align:center; font-style:italic; text-decoration:underline; color:Maroon;">
				                <span onclick="odemePlani(this)">Ödeme Planı</span>
				            </td>
				            <td class=tblDataDetail style="font-weight:bold;text-align:center;">
					            <span datafld=gensicilno />
				            </td>
				            <td class=tblDataDetail style="font-weight:bold;text-align:left;">
					            <span datafld=adiSoyadi />
				            </td>
				            <td class=tblDataDetail style="font-weight:bold;text-align:center;">
					            <span datafld=islemTarihi />
				            </td>
				            <td class=tblDataDetail style="font-weight:bold;text-align:center;">
					            <span datafld=taksitSayi />
				            </td>
				            <td class=tblDataDetail style="font-weight:bold;text-align:right;">
					            <span datafld=tutar />
				            </td>
				        </tr>
				        </table>
				    </div>
			    </td>
		    </tr>
		</table>
        <table id="uyariTable" class=tblDetailFields cellspacing=0 cellpadding=0 style="height:100%;width:100%;border:1px solid #427F9B;display:none;">
            <tr>
                <td>
                    <label id="lblUyari" style="font-weight:bold; font-family:Tahoma; font-size:16px;"></label>
                </td>
            </tr>
	        <tr style="height:30px;">
		        <td class="uiPastelButtonBar">
			        <button id="btntefeArttirDevam" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" style="margin:0px 3px 0px 3px;width:150px;color:red; font-weight:bold; display:none;" onclick="tefeArttirDevam();">İŞLEME DEVAM ET</button>
			        <button id="btntefeAzaltDevam" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" style="margin:0px 3px 0px 3px;width:150px;color:red; font-weight:bold; display:none;" onclick="tefeAzaltDevam();">İŞLEME DEVAM ET</button>
			        <button id="btntefeArttirKapat" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" style="margin:0px 3px 0px 3px;width:75px;" onclick="uiBox.close();">KAPAT</button>
		        </td>
	        </tr>

        </table>
    <textarea id="txtsql" style="display:none" ></textarea> 
    <input id="txtdetailXML" style="display:none" >
    <input id="txtislemTarihi" style="display:none"/>
    <input id="txtsicilNo" style="display:none"/>
    <input id="txtevrakNo" style="display:none"/>
    <input id="txtmernisNo" style="display:none"/>
    <input id="txtadiSoyadi" style="display:none"/>
    <input id="txtunvan" style="display:none"/>
    <input id="txtaboneler" style="display:none"/>
    <input id="txtasilBorc" style="display:none"/>
    <input id="txtufeTefeFaizTutar" style="display:none"/>
    <input id="txtkatsayiFaizTutar" style="display:none"/>
    <input id="txttoplamTutar" style="display:none"/>
    <input id="txttoplamOdeme" style="display:none"/>
    <input id="txttoplamMahsup" style="display:none"/>
    <input id="txtbakiye" style="display:none"/>
    <xml id="detailXML"></xml>
    <xml id="taksitXML"></xml>
	</form>
</body>
</html>
