<%@ Language=VBScript CodePage=1254%>
<!--#INCLUDE FILE="../global/inc/com/comFunctions.asp"-->
<%
'Dim strTCPIP
Response.Expires = 0
Response.CharSet="windows-1254"
strTCPIP=Request.Cookies("VisitorID") 
GetkulHak()

'response.Write Application("g_kurumsalKod"&strTCPIP)
'response.End

vs_kurumTipi = left(Application("g_kurumsalKod"&strTCPIP),2)
Dim vs_radio1,vs_radio2,vs_radio3,vs_radio4,vs_radio5
Dim belediyeKodu
Dim vs_display,strError

if vs_kurumTipi="48" Then
    vs_radio1    = "1"
    vs_radio2    = "2"
    vs_radio3    = "3"
    vs_radio4    = "4"
    vs_radio5    = "5"
    vs_display   = "block"
else
    vs_radio1    = "1"
    vs_radio2    = "6"
    vs_radio3    = "9"
    vs_radio4    = "12"
    vs_radio5    = "18"
    vs_display   = "none"
end if

belediyeKodu = Trim(Application("g_belediyekodu"&strTCPIP))

strError=BindMultiRecordsXML _
					(Application("g_dbconstring"&strTCPIP), _
				    "select count(*) onay from torba7020tturuOnay" , _
					"dsoRS")

%>
<!--#INCLUDE FILE="../Global/Inc/Other/GetKulHakJS.INC"-->
<html>
<head>
<style>
    .tblFormFields TD {
        white-space: nowrap;
        font-weight: bold;
    }

    .tblDetailFields TD {
        white-space: nowrap;
    }

    .tblData {
        border: none;
        width: 100%;
        margin: 0px;
    }

    .tblDataDetail {
        height: 20px;
        border: 1px solid #DDDDDD;
        text-align: right;
    }

    .optionTD {
        font-size: 12px;
        color: #0076A3;
        font-weight: bold;
        font-family: Arial;
    }
</style>
<link rel="stylesheet" href="../global/css/BelsisNewStyle.css" type="text/css" />
<script id="globalFunctionScript" type="text/javascript" src="../global/ajaxFunctions/globalFunction.js"></script>
<script id="belsisTree" type="text/javascript" src="../global/ajaxFunctions/belsisTree.js"></script>
<script id="ajaxFunctions" type="text/javascript" src="../global/ajaxFunctions/ajaxMainFunctions.js"></script>
<script type="text/javascript">

    var ajaxDataPage = new ajaxDynamicDataPage();
    var taksitSayisi;
    var vs_Sql;
    var uiBox;

    function formLoad() {

        maximizeWindow();
        if (dsoRS.recordset.Fields("onay").value == '0') {
            uiUyariGoster('Taksitlendirme Ýþlemine Devam Edebilmek Ýçin<font color="red"><br>"Tahakkuk Türleri Düzenleme"<br></font>Menüsünü Kontrol Edip Kayýt Etmelisiniz !');
            $("txtaramaNo").disabled = true;
        }

        objTree = new belsisTree('borcList');
        objTree.caption = '<b>Modül/Gelir Türü</b>';
        objTree.isIconless = true;
        objTree.footer = true;
        objTree.setLevelColors('#FFFFFF,#FFFFFF');

        objTree.addColumn({ caption: '<b>Asýl Borç<br>Tutarý</b>', datafld: 'asilBorc', name: 'asilBorc', align: 'right', width: '75', type: 'currency', autoSummary: true, showColumnSummary: true });
        objTree.addColumn({ caption: '<b>Gecikme Zammý<br>Tutarý</b>', datafld: 'gecikmeZammi', name: 'gecikmeZammi', align: 'right', width: '75', type: 'currency', autoSummary: true, showColumnSummary: true });
        objTree.addColumn({ caption: '<b>Asýl Toplam<br>Tutar</b>', datafld: 'toplamBorc', name: 'toplamBorc', align: 'right', width: '75', type: 'currency', autoSummary: true, showColumnSummary: true });
        objTree.addColumn({ caption: '<b>Ýndirim Tutarý</b>', datafld: 'indirimTutar', name: 'indirimTutar', align: 'right', width: '75', type: 'currency', autoSummary: true, showColumnSummary: true });
        objTree.addColumn({ caption: '<b>Hes. Esas<br>Tutar</b>', datafld: 'hesaplamayaEsasBorc', name: 'hesaplamayaEsasBorc', align: 'right', width: '100', type: 'currency', autoSummary: true, showColumnSummary: true });
        objTree.addHideColumns('bosSonOdemeTarihi');

        objTree.drawTree();

        objTreeEskiTaksit = new belsisTree('eskiTaksitList');
        objTreeEskiTaksit.caption = '<b>Taksit Tipi</b>';
        objTreeEskiTaksit.isIconless = true;
        objTreeEskiTaksit.footer = true;
        objTreeEskiTaksit.setLevelColors('#EEEEEE,#FFFFFF');

        objTreeEskiTaksit.addColumn({ caption: 'Ýþlem Tarihi', datafld: 'islemTarihi', name: 'islemTarihi', align: 'center', width: '100', type: 'date' });
        objTreeEskiTaksit.addColumn({ caption: 'Taksit', datafld: 'taksitSayi', name: 'taksitSayi', align: 'center', width: '50' });
        objTreeEskiTaksit.addColumn({ caption: 'Tutar', datafld: 'tutar', name: 'tutar', align: 'right', width: '100', type: 'currency' });
        objTreeEskiTaksit.addColumn({ caption: 'Ödeme Tutarý', datafld: 'odemeTutari', name: 'odemeTutari', align: 'right', width: '100', type: 'currency' });
        objTreeEskiTaksit.addColumn({ caption: 'Mahsup Tutarý', datafld: 'mahsupTutari', name: 'mahsupTutari', align: 'right', width: '100', type: 'currency' });
        objTreeEskiTaksit.addColumn({ caption: 'Bakiye', datafld: 'kalanTutar', name: 'kalanTutar', align: 'right', width: '100', type: 'currency' });

        objTreeEskiTaksit.addHideColumns('ID,gensicilno');

        objTreeEskiTaksit.drawTree();

        formElementsLoad();
        formFocus();

    }

    function formElementsLoad() {
        var vs_Sql = 'select top 1 convert(varchar(10),kontrolTarih,103) AS kontrolTarih,' +
        'case when (select count(*) from torba7020Tturu)=0 Then 999 Else (select count(*) from torba7020Tturu where isnull(taksitTuru,0)=0) end AS tturuKontrol ' +
        'from torba7020Parametre order by ID desc ';
        ajaxBindRecords(vs_Sql);
    }
    function sicilSec() {
        var strReturnWin = window.showModalDialog('../genel/modsicilwin.asp?strwinmodulno=145', 'sicilsec', 'dialogTop:240px;dialogLeft:440px;dialogWidth:205px;dialogHeight:60px;status:no;scroll:no;resizable:no;help:no;center:yes;')
        if (strReturnWin != '' && strReturnWin != null) {
            if (window.showModalDialog('../global/win.asp?strSelect=' + strReturnWin + '&intnrowsperpage=15&strReturnValue=txtaramaNo:gensicilno', window, 'resizable:yes;dialogwidth:45;status=yes;dialogheight:30;scrollbars:no;center:yes')) {
                kisiGetir();
            }
        }
    }

    function aramaNoTemizle() {
        $('txtaramaNo').value = "";
    }

    function kisiGetir() {
        $('txtaboneNo').value = '';
        var aramaNo = $('txtaramaNo').value;
        var aramaTipi;
        var strWhere;
        listTemizle();
        if (aramaNo != "") {
            if ($('radioAramaTipi2').checked) {
                strWhere = "mernis_no='" + aramaNo + "'";
                aramaTipi = 2;
            }
            else if ($('radioAramaTipi3').checked) {
                strWhere = "gensicilno = (select gensicilno from suabone where aboneno=" + aramaNo + ")";
                aramaTipi = 3;
                $('txtaboneNo').value = aramaNo;
            }
            else {
                strWhere = "gensicilno=" + aramaNo;
                aramaTipi = 1;
            }
            $('txtaramaTipi').value = aramaTipi;
            vs_Sql = "select gensicilno sicilNo,isnull(adi,'')+' '+isnull(soyadi,'') adiSoyadi, unvan, mernis_no mernisNo, " +
                     "vergi_no vergiNo, dbo.fget_sicil_adres(gensicilno,0,2) adres, isnull(nullif(cep_tel,''),isnull(nullif(ev_tel,''),is_tel)) telefon, " +
                     "e_mail ePosta, " +
                     "( " +
                     "  select count(*) from gtttah tah where gensicilno=gttsicil.gensicilno and " +
                     "      ( " +
                     "          tah.modulno=103 " +
                     "          or exists(select top 1 tec1.recid from gtttecil tec1 where yeni_tahakkuk_id is not null and yeni_tahakkuk_id=tah.rec_id) " +
                     "          or exists(select top 1 tec2.masterrecid from gttteciltah tec2 where tec2.tah_id=tah.rec_id)) " +
                     "      and tah.bakiye>0 " +
                     ") AS tecilBorcu,/* " +
                     "(select count(*) from torbaMaster where torbaMaster.gensicilno=gttsicil.gensicilno and torbaMaster.aktifPasif='A' " +
                     "and exists(select top 1 * from torbaBeyan inner join gtttah on torbaBeyan.torbaMasterID=torbaMaster.ID and gtttah.modulno=122 and torbaBeyan.ID=gtttah.beyan_id and gtttah.bakiye>0))*/ 0 borc6111 " +
                     "from gttsicil where " + strWhere

            ajaxBindRecords(vs_Sql, '', aboneGetir);
            radioButtonSifirla();
            butonKontrol(false);
        }
    }
    function modulGetir() {
        vs_Sql = 'select -1 AS modulno, \'TÜMÜ\' AS modulAdi union All select modulno,modul_adi modulAdi from modul with (nolock)' +
                 'where exists(select top 1 * from gtttah tah with (nolock) where tah.gensicilno=' + $('txtsicilNo').value + ' and tah.modulno=modul.modulno) ' +
                 'and modulno not in(122,135,105,143,145) ';
        ajaxDataPage.fillDataCombo('txtmodulList', vs_Sql, '', modulSelected);
        function modulSelected() {
            $('txtmodulList').item(0).selected = true
            /*
            if ($("txtborc6111").value != '0') {
                var uyari6111 = $('txtsicilNo').value + ' nolu sicile ait ' + $('txtborc6111').value + ' adet Aktif (Ödenmemiþ) 6111 Sayýlý Borç Yapýlandýrmasý Var,<br>Yapýlandýrmayý Ýptal Etmek Ýster misiniz ?';
                uiSoruSor(uyari6111, iptalWin6111);
                function iptalWin6111(retVal) {
                    if (retVal) {
                        vs_Sql = "Exec dbo.torbaTaksitDeleteOzel " + $('txtsicilNo').value;
                        ajaxExecuteSQL(vs_Sql, iptalTecil);
                    } else {
                        iptalTecil();
                    }
                }
            } else {
                iptalTecil();
            }
            */
        }
    }
    /*
        function iptalTecil() {
            if ($('txttecilBorcu').value != '0') {
                uiSoruSor('Taksitlendirme veya Tecil Yapýlmýþ Ödenmemiþ Kayýtlar Mevcut, Ýptal Etmek Ýster misiniz?', iptalWinTecil);
            }
    
        }
        function iptalWinTecil(retVal) {
            if (retVal) {
                vs_Sql = " delete from torba7020TahSonTar where tah_id in (" +
                 " select rec_id " +
                 " from gtttah t " +
                 " inner join gtttecil on yeni_tahakkuk_id=rec_id" +
                 " where bakiye>0 and t.gensicilno=" + $('txtsicilNo').value +
                 " union all" +
                 " select rec_id " +
                 " from gtttecil " +
                 " inner join (select rec_id,masterrecid,tturu,gensicilno from gtttah inner join  gttteciltah on tah_id=rec_id )x" +
                 " on x.masterrecid=gtttecil.masterrecid and x.tturu=gtttecil.tturu and x.gensicilno=gtttecil.gensicilno" +
                 " where gtttecil.gensicilno=" + $('txtsicilNo').value +
                 " union all" +
                 " select rec_id from gtttah " +
                 " inner join sutaksitbeyan on recid=beyan_id" +
                 " where modulno=103 and bakiye>0 and not exists (select * from gttteciltah where tah_id=rec_id) " +
                 " and not exists (select * from gtttecil where yeni_tahakkuk_id=rec_id) and gensicilno=" + $('txtsicilNo').value + ")"
                ajaxExecuteSQL(vs_Sql, retFunc);
                function retFunc(retVal) {
                    if (retVal) {
    
                        vs_Sql = " insert into torba7020TahSonTar ( tah_id, tarih, tutar )" +
                                    " select rec_id, (select tarih_son from gtttah where rec_id=tah_id)tarihSon, gtttecil.tutar" +
                                    " from gtttah t " +
                                    " inner join gtttecil on yeni_tahakkuk_id=rec_id" +
                                    " where bakiye>0 and t.gensicilno=" + $('txtsicilNo').value +
                                    " union all" +
                                    " select rec_id, tarih, sum(tutar) tutar from" +
                                    " (select gtttecil.gensicilno,rec_id,isnull((select tarih_son from gtttah where rec_id =tah_id),taksitTarih) tarih,tutar" +
                                    " from gtttecil " +
                                    " inner join (select rec_id,masterrecid,tturu,gensicilno from gtttah inner join  gttteciltah on tah_id=rec_id )x" +
                                    " on x.masterrecid=gtttecil.masterrecid and x.tturu=gtttecil.tturu and x.gensicilno=gtttecil.gensicilno" +
                                    " where gtttecil.gensicilno=" + $('txtsicilNo').value + ")y" +
                                    " group by rec_id,gensicilno,tarih" +
                                    " union all" +
                                    " select rec_id, tah_tarihi, tutar from gtttah " +
                                    " inner join sutaksitbeyan on recid=beyan_id" +
                                    " where modulno=103 and bakiye>0 and not exists (select * from gttteciltah where tah_id=rec_id) " +
                                    " and not exists (select * from gtttecil where yeni_tahakkuk_id=rec_id) and gensicilno=" + $('txtsicilNo').value
                        ajaxExecuteSQL(vs_Sql);
                    }
                }
            }
    
        }
    */
    function aboneGetir(retVal) {
        if ($("txtsicilNo").value.length == 0) {
            uiUyariGoster('Sicil Kaydý Bulunamadý !');
            return false;
        }
        var sicilNo = $('txtsicilNo').value;
        var aboneyeGore = $('txtaboneyeGore');
        var aboneNo = $('txtaramaNo').value;
        var objList = $('txtaboneList');

        if (retVal && sicilNo != "") {
            if ($('txtaramaTipi').value == '3') {
                objList.innerHTML = "";

                var oOption = document.createElement('option');
                objList.add(oOption);
                oOption.text = aboneNo;
                oOption.value = aboneNo;
                //oOption.selected=true;
                oOption = null;
                suBorcSecenekAyarla();

            }
            else {

                vs_Sql = "select " +
                        "	distinct bey.aboneNo aboneno,'Ab.N.:'+cast(bey.aboneNo as varchar(10)) + \'\' + isnull(abo.kiraciadi,\'\') kiraciAdi " +
                        "from gtttah tah  " +
                        "left join subeyan bey on tah.modulno=24 and bey.recid=beyan_id " +
                        "left join suabone abo on bey.aboneno=abo.aboneno " +
                        "where tah.gensicilno=" + sicilNo + " and modulno in (24,103) and bakiye>0";
                ajaxDataPage.fillDataCombo('txtaboneList', vs_Sql, '', suBorcSecenekAyarla);
            }
        }
        else {
            $('txtaboneNo').value = '';
            suBorcSecenekAyarla();
        }

    }

    function suBorcSecenekAyarla() {
        var sicilNo = $('txtsicilNo').value;
        var suDahil = $('txtsuDahil');
        var aboneyeGore = $('txtaboneyeGore');
        var aboneNo = $('txtaramaNo').value;
        var objList = $('txtaboneList');

        objList.disabled = true;
        aboneyeGore.checked = false;
        aboneyeGore.disabled = true;

        if ($('radioAramaTipi3').checked) {
            suDahil.checked = true;
            suDahil.disabled = true;
            aboneyeGore.checked = true;
            aboneyeGore.disabled = true;
        }
        else {
            if (sicilNo != "") {
                suDahil.checked = true;
                suDahil.disabled = false;
                if (objList.options.length > 0) {
                    aboneyeGore.checked = false;
                    aboneyeGore.disabled = false;
                }
                else {
                    objList.innerHTML = '';
                }
            }
            else {
                suDahil.checked = false;
                suDahil.disabled = true;
                objList.innerHTML = '';
            }
        }
        modulGetir();
    }

    function suDahilChange(obj) {
        var aboneyeGore = $('txtaboneyeGore');
        var objList = $('txtaboneList');
        //aboneyeGore.checked=false;
        aboneyeGore.disabled = !obj.checked;
        objList.disabled = !obj.checked;
        aboneyeGore = null;
        objList = null;
    }

    function listTemizle() {
        objTree.deleteAll();
        $('taksitXML').outerHTML = '<xml id=taksitXML></xml>';
        $('lblasilBorc').innerHTML = '';
        $('lblufeTefeFaizTutar').innerHTML = '';
        $('lblkatsayiFaizTutar').innerHTML = '';
        $('lbltoplamTutar').innerHTML = '';
        taksitSayisi = null;
        radioButtonSifirla();
    }

    function formFocus() {
        $('txtaramaNo').focus();
    }

    function formClose() {
        uiSoruSor('Çýkmak Ýstiyormusunuz?', closeForm);
        function closeForm(retVal) {
            if (retVal) { window.close() };
        }
    }

    function radioButtonSifirla() {
        $('Radio1').checked = null;
        $('Radio2').checked = null;
        $('Radio3').checked = null;
        $('Radio4').checked = null;
        $('Radio5').checked = null;
    }

    function loadKontrol() {
        if ($('txtkontrolTarih').value == '') {
            uiBilgiVer('Parametrelerden Kontrol Tarihi Bilgisi Girilmemiþ<br>Ýþleme Devam Edilmeyecek!');
            return false;
        }
        if ($('txttturuKontrol').value != '0') {
            uiBilgiVer('Tahakkuk Türleri Düzenleme Menüsünden<br>Taksitlendirme Türü Alanlarýný Seçmelisiniz !');
            return false;
        }
        return true;
    }
    function borcHesapla() {
        listTemizle();
        if (!loadKontrol()) return false;
/*
        vs_Sql = 'select ' +
            'taksitTipi+\'_\'+CAST(ID as varchar(10)) nodeID, ' +
            'null parentID, ' +
            'taksitTipi nodeText, ' +
            'ID,gensicilno,islemTarihi,taksitSayi,tutar,odemeTutari,mahsupTutari,kalanTutar ' +
            'from dbo.taksitKontrol(' + $('txtsicilNo').value + ') taksit ';
        objTreeEskiTaksit.loadFromSQL(vs_Sql, eskiTaksitKontrol);
        function eskiTaksitKontrol(retVal) {
            if (retVal) {
                if (objTreeEskiTaksit.nodes.length > 0) {
                    uiBox = new uiModalBox(690, 380);
                    uiBox.contentElement = $('tableEskiTaksit');
                    uiBox.show();
                } else {
                    borcHesaplaDevam();
                }
            }
        }
*/
        borcHesaplaDevam();
    }

    function eskiTaksitKapat() {
        uiBox.close();
        borcHesaplaDevam();
    }

    function borcHesaplaDevam() {
        var sicilNo = $('txtsicilNo').value;
        var suDahil = $('txtsuDahil');
        var aboneyeGore = $('txtaboneyeGore');
        var aramaTipi = $('txtaramaTipi').value;
        var aboneNo = $('txtaboneNo').value;
        var objList = $('txtaboneList');

        if (sicilNo != '') {
            var strWhere;

            if (aramaTipi == '3') {
                strWhere = " and modulno in(24,103) and (bey.aboneNo=" + aboneNo + " or bey2.aboneNo=" + aboneNo + ")";
            }
            else {
                if (suDahil.checked) {
                    if (aboneyeGore.checked) {
                        var strAboneler = getMultipleSelectValues(objList);
                        if (strAboneler.length > 0) {
                            strWhere = " and  (modulno not in (24,103,122,135,105,143,145) or ((modulno=24 and bey.aboneNo in (" + strAboneler + ")))) ";
                        }
                        else {
                            uiUyariGoster('En Az Bir Abone Seçmelisiniz'); return;
                        }
                    }
                    else {
                        strWhere = " and modulno not in(122,135,105,143,145) ";
                    }
                }
                else {
                    strWhere = " and  modulno not in (24,103,122,135,105,143,145) ";
                }
            }

            var strWhereModul = '';
            var strWhereModulKont = true;
            for (var i = 0; i < $('txtmodulList').length; i++) {
                if ($('txtmodulList').item(i).value == '-1' && $('txtmodulList').item(i).selected) {
                    strWhereModulKont = false;
                    break;
                }
                if ($('txtmodulList').item(i).selected) {
                    strWhereModul = strWhereModul + $('txtmodulList').item(i).value + ',';
                }
            }
            if (strWhereModulKont) { strWhereModul = " and tah.modulno in(" + left(strWhereModul, strWhereModul.length - 1) + ')'; }
            strWhereModulKont = null;
            vs_Sql = 'select modul.modulno as nodeID,  ' +
                                    'case when x.tturu is null then upper(modul.modul_adi) else upper(ttur.gel_adi) end AS nodeText, ' +
                                    'case when x.tturu is not null Then x.modulno end AS parentID, asilBorc, gecikmeZammi,toplamBorc, indirimTutar, affaEsasTutar AS hesaplamayaEsasBorc, ' +
                                    'bosSonOdemeTarihi ' +
                                    'from ' +
                                    '( ' +
                                    'select  ' +
                                    'modulno,tturu, sum(bakiye) asilBorc, ' +
                                    'isnull(sum(dbo.gecikme_altsinir(dbo.fgzamhes(tah.modulno,tah.tturu,tah.tarih_son,\'' + convertSQLDate($('txtislemTarihi').value) + '\',tah.bakiye,tah.beyan_id,tah.rec_id,1))),0) gecikmeZammi, ' +
                                    'sum(bakiye)+isnull(sum(dbo.gecikme_altsinir(dbo.fgzamhes(tah.modulno,tah.tturu,tah.tarih_son,\'' + convertSQLDate($('txtislemTarihi').value) + '\',tah.bakiye,tah.beyan_id,tah.rec_id,1))),0) as toplamBorc, ' +
									'sum(dbo.tefeindirimHesap1_7020(tah.bakiye,tah.tutar,tah.modulno,tah.tturu)) affaEsasTutar, ' +
                                    'sum(dbo.tefeindirimHesap2_7020(tah.bakiye,tah.tutar,tah.modulno,tah.tturu)) indirimTutar, count(case when tarih_son is null Then 1 end) bosSonOdemeTarihi ' +
                                    'from gtttah tah ' +
                                    'left join subeyan bey on tah.modulno=24 and tah.beyan_id=bey.recid ' +
                                    'left join sutaksitbeyan bey2 on tah.modulno=103 and tah.beyan_id=bey2.recid ' +
                                    'where tah.gensicilno=' + sicilNo + ' and bakiye>0 ' +
                                    'and tah.borc_yili between ' + $('txtborcYili1').value + ' and ' + $('txtborcYili2').value + ' ' + strWhere + strWhereModul +
                                    '/*and isnull(tarih_son,\'19000101\')<=(select top 1 kontrolTarih from torba7020Parametre order by ID desc)*/ ' +
                                    'and (tah.modulno=3  or  isnull(tah_tarihi,\'19000101\')<=(select top 1 beyanKontrolTarihi from torba7020Parametre order by ID desc) ' +
		                            '        or exists(select top 1 tec2.masterrecid from gttteciltah tec2 ' +
		                            '        inner join gtttecilmaster tecM on tecM.recid=tec2.masterrecid and tecM.tarih<=(select top 1 sonBasvuruTarih from torba7020Parametre order by ID desc) where tec2.tah_id=tah.rec_id ' +
		                            '        ) ' +
                                    'or (tah.modulno=124 and (select top 1 isnull(icraEH,\'H\') from torba7020Parametre order by ID desc)=\'E\') '+
                                    ') ' +
                                    'and ( ' +
		                            '        isnull(tarih_son,\'19000101\')<=(select top 1 kontrolTarih from torba7020Parametre order by ID desc) ' +
		                            '        or isnull(case when tah.modulno=3 and exists(select * from gtttturkod where modulno=3 and ttur_kod in(\'VZKOD\',\'KUSURKOD\',\'USUL1KOD\',\'USUL2KOD\') and ttur_recid=tah.tturu) Then (select donem from emlbeyan where recid=beyan_id) end,9999)<=year((select top 1 kontrolTarih from torba7020Parametre order by ID desc)) ' +
                                    '            or exists(select top 1 tec2.masterrecid from gttteciltah tec2 ' +
                                    '            inner join gtttecilmaster tecM on tecM.recid=tec2.masterrecid and tecM.tarih<=(select top 1 sonBasvuruTarih from torba7020Parametre order by ID desc) where tec2.tah_id=tah.rec_id ' +
                                    '            ) ' +
                                    '        or (tah.modulno=124 and (select top 1 isnull(icraEH,\'H\') from torba7020Parametre order by ID desc)=\'E\') '+
                                    '        ) ' +
                                    'and exists(select * from torba7020Tturu where torba7020Tturu.modulno=tah.modulno and torba7020Tturu.tturu=tah.tturu and taksitTuru in(1,2,3,4,6,7)) ' +
                                    'and dbo.torba7020BeyanKontrol(tah.modulno,tah.beyan_id,(select top 1 beyanKontrolTarihi from torba7020Parametre order by ID desc))=0 ' +
                                    'and dbo.borcBul7020(tah.rec_id)=0 ' +
                                    'group by modulno, tturu ' +
                                    'with rollup ' +
                                    ') x ' +
                                    'inner join modul on x.modulno=modul.modulno ' +
                                    'left join gttttur ttur on x.tturu=ttur.tturu ' +
                                    'where x.modulno is not null or x.tturu is not null ' +
                                    'order by x.modulno, x.tturu asc';
            $("txtsql").value = vs_Sql;
            objTree.loadFromSQL(vs_Sql, retBorcHesapla);
            function retBorcHesapla() {
                $("txtbakiye").value = formatNumeric(objTree.dataColumns[objTree.names["asilBorc"]].columnSummary + objTree.dataColumns[objTree.names["gecikmeZammi"]].columnSummary);
                $('taksitXML').outerHTML = '<xml id=taksitXML></xml>';
            }
        }
    }

    function taksitLoad(obj) {
        for (var i = 0; i < objTree.nodes.length; i++) {
            if (objTree.nodes[i].parentID == null) {
                if (objTree.nodes[i].getDataValue('bosSonOdemeTarihi') != '0') {
                    uiUyariGoster('Sicile Ait Son Ödeme Tarihi Olmayan Kayýtlar Tespit Edildi<br>Son Ödeme Tarihlerini Düzenlemek Ýçin "Tamam" a Basýn !', tarihDuzenWin);
                    function tarihDuzenWin() {
                        window.open('gttTorba7020TarihDuzenle.asp?gensicilno=' + $('txtsicilNo').value, 'tarihDuzenWin');
                    }
                    return;
                }
            }
        }

        if (objTree.getRowCount() == '0') { radioButtonSifirla(); return false; }
        var sicilNo = $('txtsicilNo').value;
        var suDahil = $('txtsuDahil');
        var aboneyeGore = $('txtaboneyeGore');
        var aramaTipi = $('txtaramaTipi').value;
        var aboneNo = $('txtaboneNo').value;
        var objList = $('txtaboneList');
        var objModulList = $('txtmodulList');
        taksitSayisi = null;
        if (sicilNo == '') { return false };
        if (obj.value != '') {
            var strAboneXML = '<root></root>';
            var strModulXML = '<root></root>';
            if (suDahil.checked) {
                if (aboneyeGore.checked) { strAboneXML = getMultipleSelectValuesXML(objList, 'aboneNo'); }
            }

            strModulXML = getMultipleSelectValuesXML(objModulList, 'modulNo');
            if (aboneNo == '') { aboneNo = 'null'; }
            if (aboneyeGore.checked) { strAboneXML = getMultipleSelectValuesXML(objList, 'aboneNo'); }
            vs_Sql = "Exec dbo.torba7020TaksitSP " + sicilNo + "," + aboneNo + "," + obj.value + ",'" + convertSQLDate($('txtislemTarihi').value) + "',1," + (suDahil.checked ? "1" : "0") + "," + (aboneyeGore.checked ? "1" : "0") + "," + ((suDahil.checked && aboneyeGore.checked) ? "1" : "0") + ",'" + strAboneXML + "'" + ",'" + strModulXML + "'," + $('txtborcYili1').value + ',' + $('txtborcYili2').value;
            ajaxLoadDataToXML(vs_Sql, 'taksitXML', 'divData', toplamTutariHesapla);
            function toplamTutariHesapla(retVal) {
                var dblasilBorc = 0;
                var dblufeTefeFaizTutar = 0;
                var dblkatsayiFaizTutar = 0;
                var dbltoplamTutar = 0;
                var objXML = $('taksitXML');
                if (trim(objXML.innerHTML) != '') {
                    objXML.recordset.moveFirst();
                    while (!objXML.recordset.EOF) {
                        if (objXML.recordset.fields('taksit').value != '') {
                            dblasilBorc += stringToNumeric(objXML.recordset.fields('asilBorc').value);
                            dblufeTefeFaizTutar += stringToNumeric(objXML.recordset.fields('ufeTefeFaizTutar').value);
                            dblkatsayiFaizTutar += stringToNumeric(objXML.recordset.fields('katsayiFaizTutar').value);
                            dbltoplamTutar += stringToNumeric(objXML.recordset.fields('toplamTutar').value);
                        }
                        objXML.recordset.moveNext();
                    }
                }
                objXML = null;
                $('lblasilBorc').innerHTML = formatNumeric(dblasilBorc);
                $('lblufeTefeFaizTutar').innerHTML = formatNumeric(dblufeTefeFaizTutar);
                $('lblkatsayiFaizTutar').innerHTML = formatNumeric(dblkatsayiFaizTutar);
                $('lbltoplamTutar').innerHTML = formatNumeric(dbltoplamTutar);

                $('txtsuDahilKontrol').checked = $('txtsuDahil').checked;
                $('txtaboneyeGoreKontrol').checked = $('txtaboneyeGore').checked;
                $('txtborcYili1Kontrol').value = $('txtborcYili1').value;
                $('txtborcYili2Kontrol').value = $('txtborcYili2').value;
                $('txtaboneListKontrol').value = getMultipleSelectValues($('txtaboneList'));
            }
            taksitSayisi = obj.value;
        }
        else {
            $('taksitXML').outerHTML = '<xml id=taksitXML></xml>';
        }
    }

    function colorizeTable(obj) {

        if (obj.rows.length > 2) {
            var aryColor = new Array('#EFF8FD', '#E2F3FC');
            var objRow;
            var strTmp;
            for (var i = 1; i < obj.rows.length; i++) {
                objRow = obj.rows[i];

                objRow.style.backgroundColor = aryColor[i % 2];
            }
            objRow = null;
            aryColor = null;
        }
    }
    function odemePlani() {
        window.open("gttTorba7020OdemePlani.asp?sicilno=" + $('txtsicilNo').value, "odemePlani");
    }
    function basvuruFormu() {
        window.open("gttTorba7020BasvuruFormu.asp", "basvuruFormu");
    }

    function eskiTaksitIptal() {
        var activeNode = objTreeEskiTaksit.getActiveNode();
        if (activeNode != null) {
            uiSoruSor('Seçtiðiniz Taksitlendirme Kaydý Ýptal Edilecek, Onaylýyor musunuz?', kayitSil);
            function kayitSil(retVal) {
                if (retVal) {
                    if (activeNode.nodeText.indexOf('6552', 0) >= 0) {
                        if (activeNode.nodeText.indexOf('YENÝDEN YAPILANDIRILMIÞ', 0) > 0)
                            ajaxExecuteSQL('Exec dbo.torba6552RefinansTaksitDelete ' + activeNode.getDataValue("ID"), returnFunction);
                        else
                            ajaxExecuteSQL('Exec dbo.torba6552TaksitDelete ' + activeNode.getDataValue("ID"), returnFunction);
                    }
                    if (activeNode.nodeText.indexOf('6111', 0) >= 0) {
                        if (activeNode.nodeText.indexOf('YENÝDEN YAPILANDIRILMIÞ', 0) > 0)
                            ajaxExecuteSQL('Exec dbo.torba6111RefinansTaksitDelete ' + activeNode.getDataValue("ID"), returnFunction);
                        else
                            ajaxExecuteSQL('Exec dbo.torba6111TaksitDelete ' + activeNode.getDataValue("ID"), returnFunction);
                    }
                    function returnFunction(retVal) {
                        if (retVal) {
                            objTreeEskiTaksit.deleteNode(activeNode.nodeID);
                        }
                    }
                };
            }
        } else {
            uiUyariGoster('Ýptal Etmek Ýstediðiniz Kaydý Seçmelisiniz');
        }
    }
    function formClear() {
        if (taksitXML) {
            taksitXML.outerHTML = ('<xml id=taksitXML><root><row taksit=\'\' sonOdemeTarihi=\'\' asilBorc=\'\' ufeTefeFaizTutar=\'\' katsayiFaizTutar=\'\' toplamTutar=\'\'/></root></xml>');
        }

        var elements = document.all;
        var objClear;
        for (var s = 0; s < elements.length; s++) {
            objClear = elements[s];
            if (objClear.id.substring(0, 3) == 'txt' || objClear.id.substring(0, 3) == 'lbl') {
                if (objClear.id != 'txtborcYili1' && objClear.id != 'txtborcYili2' && objClear.id != 'txtislemTarihi' && objClear.id != 'txtkontrolTarih' && objClear.id != 'txttturuKontrol') {
                    if (objClear.tagName.toLowerCase() == 'span') {
                        objClear.innerHTML = '';
                    } else {
                        objClear.value = '';
                    }
                }
            }
        }
        $('txtaboneList')
        objTree.deleteAll();
        $('txtsuDahil').checked = false;
        $('txtsuDahil').disabled = true;
        $('txtaboneyeGore').checked = false;
        $('txtaboneyeGore').disabled = true;
        $('txtaboneList').innerHTML = null;
        $('txtmodulList').innerHTML = null;
        radioButtonSifirla();
        butonKontrol(false);
        taksitSayisi = null;
        elements = null;
        objClear = null;
        formFocus();
    }

    function saveTaksit() {

        if (!saveKontrol()) { return; };

        var sicilNo = $('txtsicilNo').value;
        var suDahil = $('txtsuDahil');
        var aboneyeGore = $('txtaboneyeGore');
        var aramaTipi = $('txtaramaTipi').value;
        var aboneNo = $('txtaboneNo').value;
        var objList = $('txtaboneList');
        var objModulList = $('txtmodulList');
        if (degisenKontrol()) {
            uiSoruSor('Hesaplama Seçeneklerinde Deðiþiklik Yaptýðýnýz Ýçin Tekrar Hesaplama Yapýlacak, Devam Etmek Ýstiyor musunuz?', uiReturn);
            function uiReturn(retVal) {
                if (retVal) { borcHesapla() };
            }
            return;
        }

        if (taksitSayisi != '') {
            var strAboneXML = '<root></root>';
            var strModulXML = '<root></root>';
            if (suDahil.checked) {
                if (aboneyeGore.checked) { strAboneXML = getMultipleSelectValuesXML(objList, 'aboneNo'); }
            }
            strModulXML = getMultipleSelectValuesXML(objModulList, 'modulNo');
            if (aboneNo == '') { aboneNo = 'null'; }

            if (aboneyeGore.checked) { strAboneXML = getMultipleSelectValuesXML(objList, 'aboneNo'); }
            uiSoruSor('Kayýt Ýþlemini Onaylýyor musunuz?', taksitSave);
            function taksitSave(retVal) {
                if (retVal) {
                    vs_Sql = "Exec dbo.torba7020TaksitSP " + sicilNo + "," + aboneNo + "," + taksitSayisi + ",'" + convertSQLDate($('txtislemTarihi').value) + "','2'," + (suDahil.checked ? "1" : "0") + "," + (aboneyeGore.checked ? "1" : "0") + "," + ((suDahil.checked && aboneyeGore.checked) ? "1" : "0") + ",'" + strAboneXML + "'" + ",'" + strModulXML + "'," + $('txtborcYili1').value + ',' + $('txtborcYili2').value;
                    ajaxExecuteSQL(vs_Sql, saveEnd);
                    function saveEnd(retVal) {
                        butonKontrol(true);
                        uiBilgiVer('Borç Yapýlandýrmasý Tamamlandý')
                    }
                }
            }
        }
    }
    function butonKontrol(obj) {
        $('btnSave').disabled = obj;
        $('Radio1').disabled = obj;
        $('Radio2').disabled = obj;
        $('Radio3').disabled = obj;
        $('Radio4').disabled = obj;
        $('Radio5').disabled = obj;
    }

    function saveKontrol() {

        if (trim($('taksitXML').innerHTML) == '') {
            return false;
        }

        if (!($('Radio1').checked || $('Radio2').checked || $('Radio3').checked || $('Radio4').checked || $('Radio5').checked)) {
            return false;
        }
        if (objTree.getRowCount() == '0') {
            return false;
        }
        if ($('txtsicilNo').value == '') {
            return false;
        }
        return true;
    }

    function degisenKontrol() {
        var kontrol = false
        if ($('txtsuDahil').checked != $('txtsuDahilKontrol').checked) {
            kontrol = true
        }
        if ($('txtaboneyeGore').checked != $('txtaboneyeGoreKontrol').checked) {
            kontrol = true
        }
        if ($('txtborcYili1').value != $('txtborcYili1Kontrol').value) {
            kontrol = true
        }
        return kontrol;
    }
	</script>
</head>
<body onload="formLoad()">
<div id="transdiv" style="position:absolute;left:0;top:0;width:100%;height:100%;z-index:9998;background-color:white;filter:Alpha(opacity=80);visibility:hidden;"></div>
<form id=frm name=frm style="width:100%;height:100%;" action="gttTorba7020OdemePlani.asp" method="post" target="_blank">
	<table id=tblMain align=center cellSpacing=0 cellpadding=1 style="width:100%;height:100%;">
		<tr>
			<td height=18 class="visualCaption" colspan=2>
				7020 SAYILI BORÇ YAPILANDIRMA ÝÞLEMLERÝ
			</td>
		</tr>
		<tr>
            <td colspan="2">
                <table class=tblFormFields cellspacing=1 cellpadding=0 style="height:90px;border:none;">
                     <tr>
                        <td>

                           <table class=tblFormFields cellspacing=0 cellpadding=0 style="height:100%;padding:0px 2px 0px 2px;color:#E0EFF6;border:1px solid #427F9B;background-color:#E0EFF6;">
								<tr style="height:30px;">
									<td class=uiSubCaption>KÝÞÝ ARAMA</td>
								</tr>
                                <tr>
                                    <td class=optionTD>
                                        <input type="radio" id="radioAramaTipi1" name="txtaramaTipi" value="1" checked style="border:none;" onclick="aramaNoTemizle()"><label for="radioAramaTipi1" style="cursor:hand;">Sicil Numarasýna Göre</label>
                                    </td>
								</tr>
                                <tr>
                                    <td class=optionTD>
                                        <input type="radio" id="radioAramaTipi2" name="txtaramaTipi" value="2" style="border:none" onclick="aramaNoTemizle()"><label for="radioAramaTipi2" style="cursor:hand;">T.C. Kimlik Numarasýna Göre</label>
                                    </td>
                                </tr>
                                <tr>
                                    <td class=optionTD>
                                        <input type="radio" id="radioAramaTipi3" name="txtaramaTipi" value="3" style="border:none" onclick="aramaNoTemizle()"><label for="radioAramaTipi3" style="cursor:hand;">Su Abone Numarasýna Göre</label>
                                    </td>
                                </tr>

                                <tr>
                                    <td class=optionTD>
	                                    Ara : <input id="txtaramaNo" size=20 maxlength=11 class=MTextBox MTType="Integer" style="font-size:12px;" onchange="kisiGetir()"><button tabindex=-1 title="Sicil Ara" onclick="sicilSec()" style="background-color:#E0EFF6;"><!--#INCLUDE FILE="../Global/Inc/Images/imgFindNew.inc"--></button>
                                    </td>
                                </tr>
                          </table>
						
						</td>
						<td>
                           <table class=tblFormFields cellspacing=0 cellpadding=0 style="height:100%;padding:0px 2px 0px 2px;color:#0076A3;;border:1px solid #427F9B;background-color:#E0EFF6;">
								<tr style="height:30px;">
									<td colspan="2" class=uiSubCaption>KÝÞÝ BÝLGÝLERÝ</td>
								</tr>
                                <tr>
                                    <td>GTT Sicil No</td>
                                    <td>
                                        <input id=txtsicilNo size=10 class=MTextBox style="font-size:12px;" disabled><input id=txtaramaTipi style="display:none"><input id=txtaboneNo style="display:none">
                                    </td>
                                </tr>
                                <tr>
                                    <td>Adý Soyadý</td>
                                    <td>
                                        <input id=txtadiSoyadi size=50 class=MTextBox style="font-size:12px;" disabled>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Ünvaný</td>
                                    <td>
                                        <input id=txtunvan size=50 class=MTextBox style="font-size:12px;"  disabled>
                                    </td>
                                </tr>
                                <tr>
                                    <td>T.C. Kimlik No</td>
                                    <td>
                                        <input id=txtmernisNo size=12 class=MTextBox style="font-size:12px;" disabled>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Vergi No</td>
                                    <td>
                                        <input id=txtvergiNo size=12 class=MTextBox style="font-size:12px;" disabled>
                                    </td>
                                </tr>
                           </table>

						</td>
						<td>

                           <table class=tblFormFields cellspacing=0 cellpadding=0 style="height:100%;padding:0px 2px 0px 2px;color:#0076A3;;border:1px solid #427F9B;background-color:#E0EFF6;">
								<tr style="height:30px;">
									<td class=uiSubCaption>SU BORÇLARI</td>
								</tr>
                                <tr>
                                    <td><input type="checkbox" id=txtsuDahil style="font-size:12px;border:none" disabled onclick="suDahilChange(this)"><label for="txtsuDahil" style="font-size:11px;">Su Borçlarý Dahil Edilsin</label></td>
								</tr>
                                <tr>
                                    <td><input type="checkbox" id=txtaboneyeGore style="font-size:12px;border:none" disabled onclick="$('txtaboneList').disabled = !this.checked"><label for="txtaboneyeGore" style="font-size:11px;">Su Borçlarýný Aboneye Göre Taksitlendir</label></td>
                                </tr>
                                <tr>
                                    <td colspan="2">
										<select style="font-size:12px;width:100%;border:1px solid gray" id=txtaboneList multiple size=3 disabled>
										</select>
									</td>
                                </tr>
                                <tr style="display:<%=vs_display%>">
                                    <td>
                                        Borç Yýlý &nbsp&nbsp&nbsp <input id="txtborcYili1" size=4 maxlength=4 class=MTextBox MTType="Integer" style="font-size:12px" value="0" onblur="javascript:if (this.value=='') {this.value='0'}" > <input id="txtborcYili2" size=4 maxlength=4 class=MTextBox MTType="Integer" style="font-size:12px" value=9999 onblur="javascript:if (this.value=='') {this.value='9999'}">
                                    </td>
                                </tr>

							</table>
						
						</td>
						<td style="width:100%">
                           <table class=tblFormFields cellspacing=0 cellpadding=0 style="height:100%;width:100%;padding:0px 2px 0px 2px;color:#0076A3;border:1px solid #427F9B;background-color:#E0EFF6;">
								<tr style="height:30px;">
									<td colspan="2" class=uiSubCaption>ÝÞLEM BÝLGÝLERÝ</td>
								</tr>
                                <tr>
                                    <td>Ýþlem Tarihi/Evrak No</td>
                                    <td>
                                        <input id="txtislemTarihi" size=10 maxlength=10 class=MTextBox MTType="Date" style="font-size:12px" value=<% =Application("g_tarih"+strTCPIP) %>>
                                        <input id=txtevrakNo size=10 maxlength=20 class=MTextBox style="font-size:12px">
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
										<select style="font-size:12px;width:100%;border:1px solid gray" id=txtmodulList multiple size=3 >
										</select>
									</td>
                                </tr>
                                <tr>
                                    <td align="center" colspan="2" >
                                    <input type="button" id="btnBorcGetir" name="btnBorcGetir" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" style="margin:0px 3px 0px 3px;width:100%; font-size:18px; font-weight:bold; font-family:Courier New TUR;" onclick="borcHesapla()" value="BORÇ GETÝR">
                                </tr>
							</table>

						</td>

                    </tr>
                </table>
            </td>
        </tr>
		<tr style="height:100%">
			<td style="width:50%;text-align:center;vertical-align:top;padding:2px;">
				<table class=tblDetailFields cellspacing=0 cellpadding=0 style="height:100%;width:100%;border:1px solid #427F9B;">
				    <tr style="height:30px;">
					    <td class=uiSubCaption>BORÇ DURUMU</td>
				    </tr>
				    <tr>
					    <td colspan=1 style="padding:0px;text-align:center;font-size:11px;font-weight:bold;color:maroon;background-color:#e3e4f0">
						    <div id="borcList" style="margin:0px;padding:2px;border:none;width:100%;height:100%;overflow-y:scroll;"></div>
					    </td>
				    </tr>
				</table>
			</td>
			<td style="width:50%;text-align:center;vertical-align:top;padding:2px;">
				<table class=tblDetailFields cellspacing=0 cellpadding=0 style="height:100%;width:100%;border:1px solid #427F9B;">
				    <tr style="height:30px;">
					    <td class=uiSubCaption >BORÇ YAPILANDIRMA</td>
				    </tr>
                    <tr style="height:30px; background-color:#e3e4f0;">
                        <td align="center" style="font-size:15px;color:#0076A3;font-weight:bold;font-family:Arial;">
                            <input type="radio" id="Radio1" name="txttaksitSayi" value=<%=vs_radio1%> style="border:none;" onclick=taksitLoad(this) ><label for="Radio1" style="cursor:hand;">Peþin</label> &nbsp
                            <input type="radio" id="Radio2" name="txttaksitSayi" value=<%=vs_radio2%> style="border:none;" onclick=taksitLoad(this)><label for="Radio2" style="cursor:hand;"><%if vs_kurumTipi="46" Then %>6 Taksit<%else %>2 Taksit<%end if %></label>&nbsp
                            <input type="radio" id="Radio3" name="txttaksitSayi" value=<%=vs_radio3%> style="border:none;" onclick=taksitLoad(this)><label for="Radio3" style="cursor:hand;"><%if vs_kurumTipi="46" Then %>9 Taksit<%else %>3 Taksit<%end if %> </label> &nbsp
                            <input type="radio" id="Radio4" name="txttaksitSayi" value=<%=vs_radio4%> style="border:none;" onclick=taksitLoad(this)><label for="Radio4" style="cursor:hand;"><%if vs_kurumTipi="46" Then %>12 Taksit<%else %>4 Taksit<%end if %></label> &nbsp
                            <input type="radio" id="Radio5" name="txttaksitSayi" value=<%=vs_radio5%> style="border:none;" onclick=taksitLoad(this)><label for="Radio5" style="cursor:hand;"><%if vs_kurumTipi="46" Then %>18 Taksit<%else %>5 Taksit<%end if %></label>
                        </td>
                    </tr>
				    <tr>
					    <td colspan=1 style="padding:0px;text-align:center;font-size:11px;font-weight:bold;color:maroon;background-color:#e3e4f0">
						    <div id=divData style="margin:0px;padding:2px;border:none;width:100%;height:100%;overflow-y:scroll">
							    <table id="taksitTable" class=tblData cellSpacing=0 cellpadding=1 datasrc=#taksitXML onreadystatechange="colorizeTable(this)">
								    <thead>
								        <tr style="position:relative;top:expression(offsetParent.scrollTop)">
								            <td class=uiSubHeader style="width:3%">Taksit</td>
                                            <td class=uiSubHeader style="width:6%">Son Öd.Trh.</td>
                                            <td class=uiSubHeader style="width:7%">Hes. Esas Tutar</td>
                                            <td class=uiSubHeader style="width:7%">TEFE/ÜFE G.Z.</td>
                                            <td class=uiSubHeader style="width:7%">Katsayý G.Z.</td>
                                            <td class=uiSubHeader style="width:7%">Taksit Tutarý</td>
                                        </tr>
                                    </thead>
                                    <tr style="cursor:hand; height:50px" >
                                        <td class=tblDataDetail style="text-align:left">
                                            <span datafld=taksit style="text-align:center;border:none;width:100%;"></span>
                                        </td>
                                        <td class=tblDataDetail style="text-align:left">
                                            <span datafld=sonOdemeTarihi style="text-align:center;border:none;width:100%;"></span>
                                        </td>
                                        <td class=tblDataDetail style="text-align:left">
                                            <span datafld=asilBorc style="text-align:right;border:none;width:100%;"></span>
                                        </td>
                                        <td class=tblDataDetail style="text-align:left">
                                            <span datafld=ufeTefeFaizTutar style="text-align:right;border:none;width:100%;"></span>
                                        </td>
                                        <td class=tblDataDetail style="text-align:left">
                                            <span datafld=katsayiFaizTutar style="text-align:right;border:none;width:100%;"></span>
                                        </td>
                                        <td class=tblDataDetail style="text-align:left">
                                            <span datafld=toplamTutar style="text-align:right;border:none;width:100%;"></span>
                                        </td>
                                    </tr>
                                    <tfoot>
                    				<tr style="height:30px;">
					                    <td colspan=2 class=uiSubCaption style="text-align:left;border-right:none;">Toplamlar</td>
					                    <td class=uiSubCaption style="text-align:right;border-left:none;">
					                        <span id=lblasilBorc></span>
					                    </td>
					                    <td class=uiSubCaption style="text-align:right;border-left:none;">
					                        <span id=lblufeTefeFaizTutar></span>
					                    </td>
					                    <td class=uiSubCaption style="text-align:right;border-left:none;">
					                        <span id=lblkatsayiFaizTutar></span>
					                    </td>
					                    <td class=uiSubCaption style="text-align:right;border-left:none;">
					                        <span id=lbltoplamTutar></span>
					                    </td>
				                    </tr>
				                    </tfoot>
							    </table>
						    </div>
					    </td>
				    </tr>
				    <tr style="height:30px; background-color:#e3e4f0;">
			            <td style="border-top-width:1;border-top-style:inset;text-align:center" nowrap>
				            <input type="button" id="btnSave" name="btnSave" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" style="margin:0px 3px 0px 3px;width:100px;" onclick="javascript: saveTaksit()" value="Kaydet">
				            <input type="button" id="btnPrint" name="btnPrint" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" style="margin:0px 3px 0px 3px;width:100px;" onclick="javascript: odemePlani()" value="Ödeme Planý">
				            <input type="button" id="btnPrint2" name="btnPrint2" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" style="margin:0px 3px 0px 3px;width:100px;" onclick="javascript: basvuruFormu()" value="Baþvuru Formu">
				            <input type="button" id="btnformClear" name="btnformClear" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" style="margin:0px 3px 0px 3px;width:100px;" onclick="javascript: formClear(true)" value="Form Temizle">
				            <input type="button" id="btnExit" name="btnExit" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" style="margin:0px 3px 0px 3px;width:100px;" onclick="javascript: formClose()" value="Çýkýþ">
			            </td>
				    </tr>
				</table>
			</td>
		</tr>
	</table>
	<table id="tableEskiTaksit" class=tblDetailFields cellspacing=0 cellpadding=0 style="height:100%;width:100%;border:1px solid #427F9B;display:none;">
	<tr style="height:30px;">
		<td class="uiPastelCaption">ÖDENMEMÝÞ DÝÐER TAKSÝTLER</td>
	</tr>
	<tr>
		<td style="padding:0px;text-align:center;font-size:11px;font-weight:bold;color:maroon;background-color:#e3e4f0">
			<div id="eskiTaksitList" style="margin:0px;padding:2px;border:none;width:100%;height:100%;overflow-y:scroll;"></div>
		</td>
	</tr>
	<tr style="height:30px;">
		<td class="uiPastelButtonBar">
			<button id="btnEskiTaksitIptal" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" style="margin:0px 3px 0px 3px;width:150px;color:red; font-weight:bold;" onclick="eskiTaksitIptal();">TAKSÝTLENDÝRME ÝPTAL</button>
			<button id="btnEskiTaksitKapat" class="glossybutton" onmouseover="javascript:this.className='glossybuttonover'" onmouseout="javascript:this.className='glossybutton'" style="margin:0px 3px 0px 3px;width:75px;" onclick="eskiTaksitKapat();">KAPAT</button>
		</td>
	</tr>
	</table>

<textarea id=txttaksitXML style="display:none"></textarea> 
<textarea id=txtsql style="display:none"></textarea> 
<xml id=taksitXML><root><row taksit="" sonOdemeTarihi="" asilBorc="" ufeTefeFaizTutar="" katsayiFaizTutar="" toplamTutar="" odemeTutari=""/></root></xml>
<input id=txtkontrolTarih name=txtkontrolTarih style="display:none"/>
<input id=txttturuKontrol name=txttturuKontrol style="display:none"/>
<input type="checkbox" id=txtsuDahilKontrol style="display:none;" >
<input type="checkbox" id=txtaboneyeGoreKontrol style="display:none;" >
<input id="txtborcYili1Kontrol" style="display:none;" >
<input id="txtborcYili2Kontrol" style="display:none;" >
<input id=txtaboneListKontrol style="display:none;" >
<input id=txtadres style="display:none;" >
<input id=txttelefon style="display:none;" >
<input id=txtePosta style="display:none;" >
<input id=txttecilBorcu style="display:none;"/>
<input id=txtbakiye style="display:none" />
<input id=txtborc6111 style="display:none" />
<input id="txtonay" style="display:none" />
</form>
</body>
</html>
