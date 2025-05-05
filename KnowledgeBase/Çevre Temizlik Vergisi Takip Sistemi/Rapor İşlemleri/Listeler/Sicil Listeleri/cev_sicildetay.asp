
<%@ Language=VBScript Codepage=1254%>
<%
Option Explicit
%>
<!--#INCLUDE FILE="../global/inc/com/comFunctions.asp"-->
<%
Dim o_DataBinding,obj_AddUpdateDeleteRead
Dim vi_RowCount
Dim vs_Event
Dim vs_Error
Dim strTCPIP
Dim vs_UDR_SQL, vs_tarih, vs_yil
Dim vs_ilksicil, vs_sonsicil, vs_ilkmodsic, vs_sonmodsic, vs_ilkdogyer, vs_sondogyer, vs_sirali
Dim vs_ilkdogtar, vs_idogtar, vs_sondogtar, vs_sdogtar, vs_optionsmeslek, vs_meslek, vs_meslekfilter
Dim vs_cinsiyet, vs_cinsiyetfilter, vs_kangrup, vs_kangrupfilter, vs_ilkemektar, vs_iemektar
Dim vs_sonemektar, vs_semektar, vs_ilkoltar, vs_ioltar, vs_sonoltar, vs_soltar, vs_evil
Dim vs_optionsevil, vs_evilfilter, vs_evilce, vs_optionsevilce, vs_evilcefilter, vs_ilkevmah
Dim vs_sonevmah, vs_ilkevcad, vs_sonevcad, vs_ilkevsok, vs_sonevsok, vs_ilkevsite, vs_sonevsite
Dim vs_ilkevblok, vs_sonevblok, vs_ilkevapt, vs_sonevapt, vs_isil, vs_optionsisil, vs_isilfilter
Dim vs_isilce, vs_optionsisilce, vs_isilcefilter, vs_ilkismah, vs_sonismah, vs_ilkiscad, vs_soniscad
Dim vs_ilkissok, vs_sonissok, vs_ilkissite, vs_sonissite, vs_ilkisblok, vs_sonisblok, vs_ilkisapt
Dim vs_sonisapt, vs_kurumsahis, vs_optionskurumsahis, vs_ilksoyad, vs_sonsoyad
Dim vs_kurumsahisfilter, vs_siralama, vs_order, vs_sql_where, i, vs_ilkad, vs_sonad 
Dim vs_RunMode 'Rapor çalisma modu S:Stand Alone C:Call A:Application Stand Alone
' Hangi Raporun çalistirilacagini belirleyen degiskenler. udr_master tablosundan
' bu degiskenlerin degerleri ile okuma yapilacaktir.
Dim vi_modulno
Dim vs_kod
Dim vs_rapor


Response.Expires = 0
Response.CharSet ="windows-1254"
strTCPIP=Request.cookies("VisitorID")
'Response.Write vs_rapor
'ReportRunMode "51",vs_rapor '1.parametre modulno 2.parametre rapor kodu
ReportRunMode "4","cev_sicildetay" '1.parametre modulno 2.parametre rapor kodu

'Set obj_AddUpdateDeleteRead = Server.CreateObject("BelsisDBCommon_.AddUpdateDeleteRead")
vs_optionsmeslek = ReadMultiRecordForCombo(Application("g_dbconstring"&strTCPIP), "select recid, meslek from genmeslek order by meslek", "recid","meslek")
'Set obj_AddUpdateDeleteRead = Nothing

'Set obj_AddUpdateDeleteRead = Server.CreateObject("BelsisDBCommon_.AddUpdateDeleteRead")
vs_optionsevilce = ReadMultiRecordForCombo(Application("g_dbconstring"&strTCPIP), "select ilce.recid, (il.il_adi+' '+ilce.ilce_adi) as ilce_adi from genilce ilce inner join genil il on ilce.il_kodu=il.il_kodu order by ilce.ilce_adi", "recid","ilce_adi")
'Set obj_AddUpdateDeleteRead = Nothing

'Set obj_AddUpdateDeleteRead = Server.CreateObject("BelsisDBCommon_.AddUpdateDeleteRead")
vs_optionskurumsahis = ReadMultiRecordForCombo(Application("g_dbconstring"&strTCPIP), "select recid, kurumturu from kurumturleri order by kurumturu", "recid","kurumturu")
'Set obj_AddUpdateDeleteRead = Nothing

vs_tarih=Application("g_tarih" & strTCPIP)
vs_Event = Request.Form("EventControl")
vs_ilksicil=Request.Form("ilksicil")
if vs_ilksicil="" then
	vs_ilksicil="1"
end if
vs_sonsicil=Request.Form("sonsicil")
if vs_sonsicil="" then
	vs_sonsicil="999999999"
end if

vs_ilkmodsic=Request.Form("ilkmodsic")
if vs_ilkmodsic="" then
	vs_ilkmodsic="1"
end if
vs_sonmodsic=Request.Form("sonmodsic")
if vs_sonmodsic="" then
	vs_sonmodsic="999999999"
end if

vs_ilkdogyer=Request.Form("ilkdogyer")
vs_sondogyer=Request.Form("sondogyer")
if vs_sondogyer="" then
	vs_sondogyer="zzzzzzzzzzzzzzz"
end if

vs_ilkdogtar=Request.Form("ilkdogtar")
vs_idogtar=mid(vs_ilkdogtar,7,4)+mid(vs_ilkdogtar,4,2)+mid(vs_ilkdogtar,1,2)
vs_sondogtar=Request.Form("sondogtar")
if vs_sondogtar="" then
	vs_sondogtar= Application("g_tarih" & strTCPIP)
end if
vs_sdogtar=mid(vs_sondogtar,7,4)+mid(vs_sondogtar,4,2)+mid(vs_sondogtar,1,2)

vs_ilkemektar=Request.Form("ilkemektar")
vs_iemektar=mid(vs_ilkemektar,7,4)+mid(vs_ilkemektar,4,2)+mid(vs_ilkemektar,1,2)
vs_sonemektar=Request.Form("sonemektar")
if vs_sonemektar="" then
	vs_sonemektar= Application("g_tarih" & strTCPIP)
end if
vs_semektar=mid(vs_sonemektar,7,4)+mid(vs_sonemektar,4,2)+mid(vs_sonemektar,1,2)

vs_ilkoltar=Request.Form("ilkoltar")
vs_ioltar=mid(vs_ilkoltar,7,4)+mid(vs_ilkoltar,4,2)+mid(vs_ilkoltar,1,2)
vs_sonoltar=Request.Form("sonoltar")
if vs_sonoltar="" then
	vs_sonoltar= Application("g_tarih" & strTCPIP)
end if
vs_soltar=mid(vs_sonoltar,7,4)+mid(vs_sonoltar,4,2)+mid(vs_sonoltar,1,2)

vs_ilkevmah=Request.Form("ilkevmah")
vs_sonevmah=Request.Form("sonevmah")
if vs_sonevmah="" then
	vs_sonevmah="zzzzzzzzzzzzzzz"
end if

vs_ilkevcad=Request.Form("ilkevcad")
vs_sonevcad=Request.Form("sonevcad")
if vs_sonevcad="" then
	vs_sonevcad="zzzzzzzzzzzzzzz"
end if

vs_ilkevsok=Request.Form("ilkevsok")
vs_sonevsok=Request.Form("sonevsok")
if vs_sonevsok="" then
	vs_sonevsok="zzzzzzzzzzzzzzz"
end if

vs_ilkevsite=Request.Form("ilkevsite")
vs_sonevsite=Request.Form("sonevsite")
if vs_sonevsite="" then
	vs_sonevsite="zzzzzzzzzzzzzzz"
end if

vs_ilkevblok=Request.Form("ilkevblok")
vs_sonevblok=Request.Form("sonevblok")
if vs_sonevblok="" then
	vs_sonevblok="zzzzzzzzzzzzzzz"
end if

vs_ilkevapt=Request.Form("ilkevapt")
vs_sonevapt=Request.Form("sonevapt")
if vs_sonevapt="" then
	vs_sonevapt="zzzzzzzzzzzzzzz"
end if

vs_ilkismah=Request.Form("ilkismah")
vs_sonismah=Request.Form("sonismah")
if vs_sonismah="" then
	vs_sonismah="zzzzzzzzzzzzzzz"
end if

vs_ilkiscad=Request.Form("ilkiscad")
vs_soniscad=Request.Form("soniscad")
if vs_soniscad="" then
	vs_soniscad="zzzzzzzzzzzzzzz"
end if

vs_ilkissok=Request.Form("ilkissok")
vs_sonissok=Request.Form("sonissok")
if vs_sonissok="" then
	vs_sonissok="zzzzzzzzzzzzzzz"
end if

vs_ilkissite=Request.Form("ilkissite")
vs_sonissite=Request.Form("sonissite")
if vs_sonissite="" then
	vs_sonissite="zzzzzzzzzzzzzzz"
end if

vs_ilkisblok=Request.Form("ilkisblok")
vs_sonisblok=Request.Form("sonisblok")
if vs_sonisblok="" then
	vs_sonisblok="zzzzzzzzzzzzzzz"
end if

vs_ilkisapt=Request.Form("ilkisapt")
vs_sonisapt=Request.Form("sonisapt")
if vs_sonisapt="" then
	vs_sonisapt="zzzzzzzzzzzzzzz"
end if

vs_ilkad=Request.Form("ilkad")
vs_sonad=Request.Form("sonad")
if vs_sonad="" then
	vs_sonad="zzzzzzzzzzzzzzz"
end if

vs_ilksoyad=Request.Form("ilksoyad")
vs_sonsoyad=Request.Form("sonsoyad")
if vs_sonsoyad="" then
	vs_sonsoyad="zzzzzzzzzzzzzzz"
end if

'Dökümdeki detay satirlari sayisi
vi_RowCount=Request.Form ("RowCount")
if (vi_RowCount="0") or (vi_RowCount="") or not isnumeric(vi_RowCount) then
	vi_RowCount=40
end if	

Select Case vs_Event
	Case "Run"
	vs_sirali=Request.Form("order")
	if vs_sirali="1" then 
		vs_order=" order by s.gensicilno "
	end if
	if vs_sirali="2" then 
		vs_order=" order by s.soyadi, s.adi "
	end if
	if vs_sirali="3" then 
		vs_order=" order by s.adi, s.soyadi "
	end if
	
	vs_meslek=""
	for i=1 to Request.Form("meslek").Count 
		if vs_meslek="" then
			vs_meslek=vs_meslek+Request.Form("meslek")(I)
		else 
			vs_meslek=vs_meslek+","+Request.Form("meslek")(I)
		end if
	next
	vs_meslekfilter="   in ("+vs_meslek+") "
	
	vs_cinsiyet=""
	for i=1 to Request.Form("cinsiyet").Count 
		if vs_cinsiyet="" then
			vs_cinsiyet=vs_cinsiyet+Request.Form("cinsiyet")(I)
		else 
			vs_cinsiyet=vs_cinsiyet+","+Request.Form("cinsiyet")(I)
		end if
	next
	vs_cinsiyetfilter="   in ("+vs_cinsiyet+") "
	
	vs_kangrup=""
	for i=1 to Request.Form("kangrup").Count 
		if vs_kangrup="" then
			vs_kangrup=vs_kangrup+"'"+Request.Form("kangrup")(I)+"'"
		else 
			vs_kangrup=vs_kangrup+",'"+Request.Form("kangrup")(I)+"'"
		end if
	next
	vs_kangrupfilter="   in ("+vs_kangrup+") "
	
	vs_evil=""
	for i=1 to Request.Form("evil").Count 
		if vs_evil="" then
			vs_evil=vs_evil+Request.Form("evil")(I)
		else 
			vs_evil=vs_evil+","+Request.Form("evil")(I)
		end if
	next
	vs_evilfilter="   in ("+vs_evil+") "
	
	vs_evilce=""
	for i=1 to Request.Form("evilce").Count 
		if vs_evilce="" then
			vs_evilce=vs_evilce+Request.Form("evilce")(I)
		else 
			vs_evilce=vs_evilce+","+Request.Form("evilce")(I)
		end if
	next
	vs_evilcefilter="   in ("+vs_evilce+") "
	
	vs_isil=""
	for i=1 to Request.Form("isil").Count 
		if vs_isil="" then
			vs_isil=vs_isil+Request.Form("isil")(I)
		else 
			vs_isil=vs_isil+","+Request.Form("isil")(I)
		end if
	next
	vs_isilfilter="   in ("+vs_isil+") "
	
	vs_isilce=""
	for i=1 to Request.Form("isilce").Count 
		if vs_isilce="" then
			vs_isilce=vs_isilce+Request.Form("isilce")(I)
		else 
			vs_isilce=vs_isilce+","+Request.Form("isilce")(I)
		end if
	next
	vs_isilcefilter="   in ("+vs_isilce+") "
	
	vs_kurumsahis=""
	for i=1 to Request.Form("kurumsahis").Count 
		if vs_kurumsahis="" then
			vs_kurumsahis=vs_kurumsahis+Request.Form("kurumsahis")(I)
		else 
			vs_kurumsahis=vs_kurumsahis+","+Request.Form("kurumsahis")(I)
		end if
	next
	vs_kurumsahisfilter="   in ("+vs_kurumsahis+") "
	   
	   vs_sql_where=" where isnull(s.gensicilno,0) between "+vs_ilksicil+" and "+vs_sonsicil+" and "+_ 
					"isnull(s.soyadi,'') between '"+vs_ilksoyad+"' and '"+vs_sonsoyad+"' and "+_ 
					"isnull(s.adi,'') between '"+vs_ilkad+"' and '"+vs_sonad+"' and "+_ 
					"isnull(s.dogum_yeri,'') between '"+vs_ilkdogyer+"' and '"+vs_sondogyer+"' and "+_
					"isnull(dogum_tarihi,'') between '"+vs_idogtar+"' and '"+vs_sdogtar+"' and "+_ 
					"isnull(meslek,0) "+vs_meslekfilter+" and "+_
					"isnull(cinsiyet,0) "+vs_cinsiyetfilter+" and "+_
					"isnull(emekli_tarihi,'') between '"+vs_iemektar+"' and '"+vs_semektar+"' and "+_ 
					"isnull(olum_tarihi,'') between '"+vs_ioltar+"' and '"+vs_soltar+"' and "+_
					"isnull(ev_ilce_kodu,0) "+vs_evilcefilter+" and "+_
					"isnull(evmah.mah_adi,'') between '"+vs_ilkevmah+"' and '"+vs_sonevmah+"' and "+_ 
					"isnull(evmah.cad_adi,'') between '"+vs_ilkevcad+"' and '"+vs_sonevcad+"' and "+_ 
					"isnull(evmah.sok_adi,'') between '"+vs_ilkevsok+"' and '"+vs_sonevsok+"' and "+_ 
					"isnull(ev_site_adi,'') between '"+vs_ilkevsite+"' and '"+vs_sonevsite+"' and "+_ 
					"isnull(ev_blok,'') between '"+vs_ilkevblok+"' and '"+vs_sonevblok+"' and "+_ 
					"isnull(ev_apartman,'') between '"+vs_ilkevapt+"' and '"+vs_sonevapt+"' and "+_ 
					"isnull(is_ilce_kodu,0) "+vs_isilcefilter+" and "+_
					"isnull(ismah.mah_adi,'') between '"+vs_ilkismah+"' and '"+vs_sonismah+"' and "+_ 
					"isnull(ismah.cad_adi,'') between '"+vs_ilkiscad+"' and '"+vs_soniscad+"' and "+_ 
					"isnull(ismah.sok_adi,'') between '"+vs_ilkissok+"' and '"+vs_sonissok+"' and "+_ 
					"isnull(is_site_adi,'') between '"+vs_ilkissite+"' and '"+vs_sonissite+"' and "+_ 
					"isnull(is_blok,'') between '"+vs_ilkisblok+"' and '"+vs_sonisblok+"' and "+_ 
					"isnull(is_apartman,'') between '"+vs_ilkisapt+"' and '"+vs_sonisapt+"' and "+_
					"isnull(kurumturu ,0) "+vs_kurumsahisfilter+" and "+_
					"isnull(kan_grubu,'') "+vs_kangrupfilter+" and "+_
					"isnull((select sicilno from gttmsic where s.gensicilno=gensicilno and modulno=4),0) between "+vs_ilkmodsic+" and "+vs_sonmodsic+" "
	   vs_UDR_SQL=Request.Form("UDR_sql")
	  ' vs_order_by=Request.Form("order_by")
	  'Response.write vs_order_by
	  vs_UDR_SQL=vs_UDR_SQL+vs_sql_where+vs_order
	   'vs_UDR_SQL=vs_UDR_SQL+ vs_order_by
	'   response.write vs_UDR_SQL
	   'client scripte koy
	   
 	    
		'Set o_DataBinding = Server.CreateObject("BelsisDBCommon_.DataBinding")
			BindMultiRecordsXML _
				Application("g_dbconstring"&strTCPIP), _
				vs_UDR_SQL _
				,"dsoRS"
				'response.write vs_UDR_SQL
		'Set o_DataBinding = Nothing
End Select 

if vi_modulno<>"" then
	UDR_Get()
end if	
%>

<!--#INCLUDE FILE="../Genel/ReportEngineServerScripts.inc"-->



<SCRIPT ID=clientEventHandlersVBS LANGUAGE=vbscript>
<!--

Sub window_onload
WindowOnloadControl()
	for i=0 to frm.meslek.length-1
	frm.meslek.item(i).selected=true
	next
	for i=0 to frm.cinsiyet.length-1
	frm.cinsiyet.item(i).selected=true
	next
	for i=0 to frm.kangrup.length-1
	frm.kangrup.item(i).selected=true
	next
	for i=0 to frm.evilce.length-1
	frm.evilce.item(i).selected=true
	next
	for i=0 to frm.isilce.length-1
	frm.isilce.item(i).selected=true
	next
	for i=0 to frm.kurumsahis.length-1
	frm.kurumsahis.item(i).selected=true
	next
End sub


'Filtreler Tanimlandiktan sonra Raporun Çalistirilmasi 
'(Stand Alone Application örnegi için)
'Sub btnList_onclick
'UDR_PrepareSQL()
'frm.EventControl.value="Run"
'frm.Submit
'End sub

Sub btnList_onclick
UDR_PrepareSQL()
frm.EventControl.value="Run"
frm.Submit
End Sub

sub frm_onkeydown
if window.event.keyCode=13 then
   window.event.keyCode=09
end if
end sub

-->
</SCRIPT>
<script ID=ReportEngineVBScripts LANGUAGE=vbscript src="../Genel/ReportEngineVBScripts.htm"></script>

<HTML>
<HEAD>
<link rel=stylesheet HREF="..\Global\css\BelsisStyle.css" TYPE='text/css'>
<style>
.ReportTable
{
   table-layout:fixed;
   border-collapse:collapse;
   background:white;
   font-family:Times New Roman;
   font-size:10
}

</style>
<!--#INCLUDE FILE="../Global/Inc/Other/WinTitle.inc"-->

<META NAME="GENERATOR" Content="Microsoft Visual Studio 6.0">
<script ID=clientEventHandlersVBS LANGUAGE=vbscript src="..\Global\GlobalFunction.htm"></script>

</HEAD>
<BODY>

<!--START OF FILTERS AND USER INTERFACE SECTION -->
<form id=frm name=frm method=post>
<div id=filters name=filters>
<table align=center cellpadding=0 cellspacing=0>
<caption style="FONT-WEIGHT: bold; BACKGROUND: teal; COLOR: white; TEXT-ALIGN: center">SÝCÝL LÝSTESÝ (DETAY)</caption>
<colgroup><col style="WIDTH: 3cm"></colgroup>
<colgroup><col style="WIDTH: 4cm"></colgroup>
<colgroup><col style="WIDTH: 0.5cm"></colgroup>
<colgroup><col style="WIDTH: 4cm"></colgroup>
<colgroup><col style="WIDTH: 3cm"></colgroup>
<colgroup><col style="WIDTH: 4cm"></colgroup>
<colgroup><col style="WIDTH: 0.5cm"></colgroup>
<colgroup><col style="WIDTH: 4cm"></colgroup>

<tr>
	<td style="border:none">
	<td><select id=order name=order >
		<option value="1" selected>Sicil No Sýralý</option>
		<option value="2">Soyadý ve Adýna Göre Sýralý</option>
		<option value="3">Adý ve Soyadýna Göre Sýralý</option>
		</select>
	</td>	
	</td>
</tr>

<tr height=20>
	<td style="border:none"></td>
	<td style="border:none;font-weight:bold">Baþlangýç</td>
	<td style="border:none"></td>
	<td style="border:none;font-weight:bold">Bitiþ</td>
	<td style="border:none"></td>
	<td style="border:none;font-weight:bold">Baþlangýç</td>
	<td style="border:none"></td>
	<td style="border:none;font-weight:bold">Bitiþ</td>
</tr>

<tr height=20>
	<td style="border:none">GTT Sicil No</td>
	<td style="border:none"><input size=10  id=ilksicil name=ilksicil value="<%=vs_ilksicil%>" maxlength=20 class="MTextBox" MTTYpe="Integer"></td>
	<td style="border:none"></td>
	<td style="border:none"><input size=10 id=sonsicil name=sonsicil value="<%=vs_sonsicil%>" maxlength=20 class="MTextBox" MTTYpe="Integer"></td>
	<td style="border:none">Modül Sicil No</td>
	<td style="border:none"><input size=10 id=ilkmodsic name=ilkmodsic value="<%=vs_ilkmodsic%>" maxlength=20 class="MTextBox" MTTYpe="Integer"></td>
	<td style="border:none"></td>
	<td style="border:none"><input size=10 id=sonmodsic name=sonmodsic value="<%=vs_sonmodsic%>" maxlength=20 class="MTextBox" MTTYpe="Integer"></td>
</tr>

<tr height=20>
	
</tr>

<tr height=20>
	<td style="border:none">Doðum Yeri</td>
	<td style="border:none"><input size=15 id=ilkdogyer name=ilkdogyer value="<%=vs_ilkdogyer%>" maxlength=40></td>
	<td style="border:none"></td>
	<td style="border:none"><input size=15 id=sondogyer name=sondogyer value="<%=vs_sondogyer%>" maxlength=40></td>
	<td style="border:none">Doðum Tarihi</td>
	<td style="border:none"><input size=10 id=ilkdogtar name=ilkdogtar value="<%=vs_ilkdogtar%>" maxlength=20 class="MTextBox" MTTYpe="Date"></td>
	<td style="border:none"></td>
	<td style="border:none"><input size=10 id=sondogtar name=sondogtar value="<%=vs_sondogtar%>" maxlength=20 class="MTextBox" MTTYpe="Date"></td>
</tr>

<tr height=20>
	<td style="border:none">Emekli Tarihi</td>
	<td style="border:none"><input size=10 id=ilkemektar name=ilkemektar value="<%=vs_ilkemektar%>" maxlength=20 class="MTextBox" MTTYpe="Date"></td>
	<td style="border:none"></td>
	<td style="border:none"><input size=10 id=sonemektar name=sonemektar value="<%=vs_sonemektar%>" maxlength=20 class="MTextBox" MTTYpe="Date"></td>
	<td style="border:none">Ölüm Tarihi</td>
	<td style="border:none"><input size=10 id=ilkoltar name=ilkoltar value="<%=vs_ilkoltar%>" maxlength=20 class="MTextBox" MTTYpe="Date"></td>
	<td style="border:none"></td>
	<td style="border:none"><input size=10 id=sonoltar name=sonoltar value="<%=vs_sonoltar%>" maxlength=20 class="MTextBox" MTTYpe="Date"></td>
</tr>

<tr height=20>
	<td style="border:none">Ev Mahalle</td>
	<td style="border:none"><input size=15 id=ilkevmah name=ilkevmah value="<%=vs_ilkevmah%>" maxlength=40></td>
	<td style="border:none"></td>
	<td style="border:none"><input size=15 id=sonevmah name=sonevmah value="<%=vs_sonevmah%>" maxlength=40></td>
	<td style="border:none">Ev Cadde</td>
	<td style="border:none"><input size=15 id=ilkevcad name=ilkevcad value="<%=vs_ilkevcad%>" maxlength=40></td>
	<td style="border:none"></td>
	<td style="border:none"><input size=15 id=sonevcad name=sonevcad value="<%=vs_sonevcad%>" maxlength=40></td>
</tr>

<tr height=20>
	<td style="border:none">Ev Sokak</td>
	<td style="border:none"><input size=15 id=ilkevsok name=ilkevsok value="<%=vs_ilkevsok%>" maxlength=40></td>
	<td style="border:none"></td>
	<td style="border:none"><input size=15 id=sonevsok name=sonevsok value="<%=vs_sonevsok%>" maxlength=40></td>
	<td style="border:none">Ev Site</td>
	<td style="border:none"><input size=15 id=ilkevsite name=ilkevsite value="<%=vs_ilkevsite%>" maxlength=40></td>
	<td style="border:none"></td>
	<td style="border:none"><input size=15 id=sonevsite name=sonevsite value="<%=vs_sonevsite%>" maxlength=40></td>
</tr>

<tr height=20>
	<td style="border:none">Ev Blok</td>
	<td style="border:none"><input size=7 id=ilkevblok name=ilkevblok value="<%=vs_ilkevblok%>" maxlength=20></td>
	<td style="border:none"></td>
	<td style="border:none"><input size=7 id=sonevblok name=sonevblok value="<%=vs_sonevblok%>" maxlength=20></td>
	<td style="border:none">Ev Apartman</td>
	<td style="border:none"><input size=15 id=ilkevapt name=ilkevapt value="<%=vs_ilkevapt%>" maxlength=40></td>
	<td style="border:none"></td>
	<td style="border:none"><input size=15 id=sonevapt name=sonevapt value="<%=vs_sonevapt%>" maxlength=40></td>
</tr>

<tr height=20>
	<td style="border:none">Ýþ Mahalle</td>
	<td style="border:none"><input size=15 id=ilkismah name=ilkismah value="<%=vs_ilkismah%>" maxlength=40></td>
	<td style="border:none"></td>
	<td style="border:none"><input size=15 id=sonismah name=sonismah value="<%=vs_sonismah%>" maxlength=40></td>
	<td style="border:none">Ýþ Cadde</td>
	<td style="border:none"><input size=15 id=ilkiscad name=ilkiscad value="<%=vs_ilkiscad%>" maxlength=40></td>
	<td style="border:none"></td>
	<td style="border:none"><input size=15 id=soniscad name=soniscad value="<%=vs_soniscad%>" maxlength=40></td>
</tr>

<tr height=20>
	<td style="border:none">Ýþ Sokak</td>
	<td style="border:none"><input size=15 id=ilkissok name=ilkissok value="<%=vs_ilkissok%>" maxlength=40></td>
	<td style="border:none"></td>
	<td style="border:none"><input size=15 id=sonissok name=sonissok value="<%=vs_sonissok%>" maxlength=40></td>
	<td style="border:none">Ýþ Site</td>
	<td style="border:none"><input size=15 id=ilkissite name=ilkissite value="<%=vs_ilkissite%>" maxlength=40></td>
	<td style="border:none"></td>
	<td style="border:none"><input size=15 id=sonissite name=sonissite value="<%=vs_sonissite%>" maxlength=40></td>
</tr>

<tr height=20>
	<td style="border:none">Ýþ Blok</td>
	<td style="border:none"><input size=7 id=ilkisblok name=ilkisblok value="<%=vs_ilkisblok%>" maxlength=20></td>
	<td style="border:none"></td>
	<td style="border:none"><input size=7 id=sonisblok name=sonisblok value="<%=vs_sonisblok%>" maxlength=20></td>
	<td style="border:none">Ýþ Apartman</td>
	<td style="border:none"><input size=15 id=ilkisapt name=ilkisapt value="<%=vs_ilkisapt%>" maxlength=40></td>
	<td style="border:none"></td>
	<td style="border:none"><input size=15 id=sonisapt name=sonisapt value="<%=vs_sonisapt%>" maxlength=40></td>
</tr>

<tr height=20>
<td style="border:none">Meslek</td>
	<td><select multiple id=meslek name=meslek>
	<option value="0">boþ</option>
	<%=vs_optionsmeslek%>
	</td></select>
	</td>
	<td style="border:none">Cinsiyet</td>
	<td><select multiple id=cinsiyet name=cinsiyet>
	<option value="0">Erkek</option>
	<option value="1">Kadýn</option>
	<option value="2">Diðer</option>
	</td></select>
	</td>
	<td style="border:none">Kan Grubu</td>
	<td><select multiple id=kangrup name=kangrup>
	<option value="">boþ</option>
	<option value="0(+)">0(+)</option>
	<option value="0(-)">0(-)</option>
	<option value="A(+)">A(+)</option>
	<option value="A(-)">A(-)</option>
	<option value="B(+)">B(+)</option>
	<option value="B(-)">B(-)</option>
	<option value="AB(+)">AB(+)</option>
	<option value="AB(-)">AB(-)</option>
	</td></select>
	</td>	
</tr>	

<tr height=20>
<td style="border:none">Ev Ýlçe</td>
	<td><select multiple id=evilce name=evilce>
	<option value="0">boþ</option>
	<%=vs_optionsevilce%>
	</td></select>
	</td>
	<td style="border:none">Ýþ Ýlçe</td>
	<td><select multiple id=isilce name=isilce>
	<option value="0">boþ</option>
	<%=vs_optionsevilce%>
	</td></select>
	</td>
	<td style="border:none">Kurum/Þahýs</td>
	<td><select multiple id=kurumsahis name=kurumsahis>
	<option value="0">boþ</option>
	<%=vs_optionskurumsahis%>
	</td></select>
	</td>
</tr>	

<tr height=20>
	<td style="border:none">Satýr Sayýsý:</td>
	<td style="border:none"><input size=5 id=rowcount name=rowcount value="<%=vi_RowCount%>" maxlength=4 class="MTextBox" MTTYpe="Integer"></td>
</tr>	
<tr>
<td style="BORDER-TOP: 1px inset; TEXT-ALIGN:center" colspan="8">
<!--#INCLUDE FILE="../Global/Inc/Buttons/btnList.inc"-->
<!--#INCLUDE FILE="../Global/Inc/Buttons/btnExit.inc"-->
</td>
</tr>
</table>

<input style="DISPLAY: none" id=EventControl name=EventControl value="<%=vs_Event%>">
<input style="DISPLAY: none"  id=yil value="<%=vs_yil%>">
<input id=ReportRunMode name=ReportRunMode style="DISPLAY: none" value="<%=vs_RunMode%>">
<textarea id=UDR_sql name=UDR_sql style="DISPLAY: none"  ><%=vs_UDR_SQL%></textarea>
<input id=bel_adi name=bel_adi value="<%=Application("g_beladi" & strTCPIP)%>" style="DISPLAY: none" >
<input style="DISPLAY: none" id=tarih name=tarih value="<%=vs_tarih%>">
</div>
</form>

<!--END OF FILTERS AND USER INTERFACE SECTION -->



<!--START OF PRINT OUT SECTION -->
<!--#INCLUDE FILE="../Global/Inc/Buttons/PrintOutToolBar.inc"-->
<DIV id=printout style="display:none">
</DIV>
<!--END OF PRINT OUT SECTION -->



</BODY>
</HTML>
