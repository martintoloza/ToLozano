// Programa.: CGELIMOV.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listado de Movto. Diario.
#INCLUDE "Fivewin.CH"
#INCLUDE "Utilprn.CH"

MEMVAR oApl

FUNCTION CgeLiMov()
   LOCAL oDlg, oGet := ARRAY(12), aP := { "999999","99","@E" }
   LOCAL aM := { "EL CONSECUTIVO","EL COMPROBANTE","LA FECHA" }, nO := 1
   LOCAL oM := TLimov()
 oM:New( "Relacion de Movim. Ordenado por " )
DEFINE DIALOG oDlg TITLE "LISTA MOVIMIENTO DIARIO" FROM 0, 0 TO 16,50
   @ 02,00 SAY "PERIODO [AAAAMM]"  OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02,92 GET oGet[1] VAR oM:aLS[1] OF oDlg PICTURE "999999" SIZE 32,10 PIXEL;
      VALID NtChr( oM:aLS[1],"P" )
   @ 14,00 SAY "ORDEN [C/T/F]"     OF oDlg RIGHT PIXEL SIZE 90,10
   @ 14,92 GET oGet[2] VAR oM:aLS[2] OF oDlg PICTURE "!" SIZE 08,10 PIXEL;
      VALID If( oM:aLS[2] $ "CTF", (nO := AT( oM:aLS[2],"CTF" ),;
                oM:dFec   := NtChr( oM:aLS[1],"F" )            ,;
                oM:aLS[3] := { 1,1,oM:dFec }[nO]               ,;
                oM:aLS[4] := { 999999,99,oM:dFec }[nO], oDlg:Update(), .t.), .f. )
   @ 14,130 SAY "C=Consecutivo  T=Comprobante  F=Fecha" OF oDlg PIXEL SIZE 60,30
   @ 26,00 SAY "DESDE " + aM[nO]     OF oDlg RIGHT PIXEL SIZE 90,10 UPDATE
   @ 26,92 GET oGet[3] VAR oM:aLS[3] OF oDlg PICTURE aP[nO] SIZE 38,10 PIXEL UPDATE
   @ 38,00 SAY "HASTA " + aM[nO]     OF oDlg RIGHT PIXEL SIZE 90,10 UPDATE
   @ 38,92 GET oGet[4] VAR oM:aLS[4] OF oDlg PICTURE aP[nO] SIZE 38,10 PIXEL UPDATE
   @ 50,00 SAY "PAGINA INICIAL"      OF oDlg RIGHT PIXEL SIZE 90,10
   @ 50,92 GET oGet[5] VAR oM:aLS[5] OF oDlg PICTURE "###";
      VALID Rango( oM:aLS[5],1,999 )    SIZE 20,10 PIXEL
   @ 50,144 CHECKBOX oGet[6] VAR oM:aLS[6] PROMPT "REGISTRADO" OF oDlg ;
      SIZE 60,10 PIXEL
   @ 62, 00 SAY "Libro" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 62, 92 COMBOBOX oGet[7] VAR oM:aLS[9] ITEMS { "COLGAAP","IFRS" };
      SIZE 48,90 OF oDlg PIXEL;
      WHEN !EMPTY(oApl:oEmp:NIIF) .AND. oM:aLS[1] >= oApl:oEmp:NIIF
   @ 74, 00 SAY "TIPO DE IMPRESORA"  OF oDlg RIGHT PIXEL SIZE 90,10
   @ 74, 92 COMBOBOX oGet[8] VAR oM:aLS[7] ITEMS { "Matriz","Laser" };
      SIZE 48,90 OF oDlg PIXEL
   @ 74,144 CHECKBOX oGet[9] VAR oM:aLS[8] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 86,00 SAY "Escoja la Fuente"  OF oDlg RIGHT PIXEL SIZE 90,10
   @ 86,92 COMBOBOX oGet[10] VAR oM:cFont  ITEMS oM:aFont SIZE 80,99 OF oDlg PIXEL;
      WHEN oM:aLS[7] > 1
   @ 100, 50 BUTTON oGet[11] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
       ( oGet[11]:Disable(), oM:ArmarMOV( oDlg ),;
         oGet[11]:Enable() , oM:aLS[2] := "C"   ,;
         oGet[11]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 100,100 BUTTON oGet[12] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 106, 02 SAY "[CGELIMOV]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT ( Empresa( .t. ) )

RETURN NIL

//Clase Para Listar Movimientos de Diario.
CLASS TLimov FROM TIMPRIME

 DATA aLS, aMV, dFec, hRes, nL

   METHOD NEW( cTitulo ) Constructor
   METHOD ArmarMOV( oDlg )
   METHOD ListoDOS( oDlg )
// METHOD ListoWIN()
   METHOD Cabecera( lSep,nSpace,nSuma )
   METHOD Lineas()
ENDCLASS

//------------------------------------//
METHOD NEW( cTitulo ) CLASS TLimov
   LOCAL hDC := GetDC( 0 )
   DEFAULT cTitulo := ""
 ::aFont := GetFontNames( hDC )
 ::aLS   := { NtChr( DATE(),"1" ),"C",1,999999,1,.f.,oApl:nTFor,.t.,1 }
 ::aMV   := { 0,0,0,0,"#,###,###,###.##",0,"","" }
 ::aEnc  := { .t.,cTitulo,"","" }
 ::cFont := "Arial"
RETURN NIL

//------------------------------------//
METHOD ArmarMOV( oDlg ) CLASS TLimov
   LOCAL cOrd, cQry
 ::aLS[2] := AT( ::aLS[2],"CTF" )
do Case
Case ::aLS[2] == 1
   ::aMV[7] := " AND c.control"
   cOrd := "c.control"
Case ::aLS[2] == 2
   ::aMV[7] := " AND c.fuente"
   ::aMV[8] := "Totales Comprobante ==================>  $"
   cOrd := "c.fuente, c.comprobant"
Case ::aLS[2] == 3
   ::aMV[7] := " AND c.fecha"
   ::aMV[8] := "Totales del Dia ======================>  $"
   cOrd := "c.fecha"
EndCase
cOrd := If( !::aLS[6], cOrd, "c.fuente, c.comprobant" ) + ", d.row_id"
cQry := "SELECT c.control, c.fuente, c.fecha, c.comprobant, c.concepto, d.cuenta,"+;
        " d.infa, d.infb, d.infc, d.infd, d.valor_deb, d.valor_cre, d.codigo_nit "+;
        "FROM cgemovd d, cgemovc c "  +;
        "WHERE d.empresa = c.empresa" +;
         " AND d.ano_mes = c.ano_mes" +;
         " AND d.control = c.control" +;
         " AND d.libro   = " +       STR(::aLS[9],2)    +;
         " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.ano_mes = " + xValToChar( ::aLS[1] )   +;
           ::aMV[7] + " >= " + xValToChar( ::aLS[3] )   +;
           ::aMV[7] + " <= " + xValToChar( ::aLS[4] )   +;
         " AND c.estado <> 2 ORDER BY " + cOrd
::hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes )
   RETURN NIL
EndIf
 cOrd      := ::aEnc[2]
 ::aEnc[2] += { "Consecutivo","Comprobante","Fecha" }[::aLS[2]] +;
              NtChr( ::aLS[9],"CI" )
 ::aEnc[3] := "EN " + NtChr( ::dFec,"6" )
If ::aLS[7] == 1
   ::ListoDOS( oDlg )
Else
   ::Init( ::aEnc[2], .f. ,, !::aLS[8] ,,,, 5 )
     PAGE
       ::Lineas()
     ENDPAGE
   IMPRIME END .F.
   ::aEnc[1] := .T.
EndIf
MSFreeResult( ::hRes )
 ::aEnc[2] := cOrd
RETURN NIL

//------------------------------------//
METHOD ListoDOS( oDlg ) CLASS TLimov
   LOCAL aRes, cNit, nK := 0
   LOCAL oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[2],::aEnc[3],;
         "TC Docum.   F e c h a Descripcion" + SPACE(32) + "Cuenta  "   +;
         "INFA/INFC  INFB/INFD       Debitos         Creditos    Cons."},;
         ::aLS[8],::aLS[5],2 )
oRpt:lTimbrado := ::aLS[6]
aRes := MyReadRow( ::hRes )
AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
::aMV[6] := aRes[::aLS[2]]
While ::nL > 0
   oRpt:Titulo( 134 )
   If oRpt:nPage >= oRpt:nPagI
      If nK  # aRes[4]
         nK := aRes[4]
         oRpt:Say( oRpt:nL,00,STR(aRes[02],2)+ STR(aRes[04],7)+ " "+;
                    NtChr( aRes[03],"2" )+ " " + aRes[05] )
      EndIf
      cNit := ""
      If aRes[13] > 0
         cNit :=  Buscar( {"codigo_nit",aRes[13]},"cadclien","nombre",8 )
      EndIf
      oRpt:Say( oRpt:nL  ,63,aRes[06] + aRes[07] + " " + aRes[08] + " " +;
                 TRANSFORM( aRes[11],::aMV[5] ) + " " + ;
                 TRANSFORM( aRes[12],::aMV[5] ) + STR(aRes[01],6) )
      oRpt:Say( oRpt:nL+1,34,cNit )
      oRpt:Say( oRpt:nL+1,71,aRes[09] + " " + aRes[10] )
   EndIf
   oRpt:nL += 2
   ::aMV[1] += aRes[11]
   ::aMV[2] += aRes[12]
   ::aMV[3] += aRes[11]
   ::aMV[4] += aRes[12]
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aMV[6] # aRes[::aLS[2]]
      If ::aLS[2] # 1 .AND. (::aMV[1] # 0 .OR. ::aMV[2] # 0)
         If oRpt:nPage >= oRpt:nPagI
            oRpt:Say( oRpt:nL+1,53,::aMV[8] + TRANSFORM( ::aMV[1],::aMV[5] ) +;
                       " " + TRANSFORM( ::aMV[2],::aMV[5] ),,,1 )
         EndIf
         oRpt:nL += 3
      EndIf
      ::aMV[1] := ::aMV[2] := 0
      ::aMV[6] := aRes[::aLS[2]]
   EndIf
EndDo
oRpt:Say(++oRpt:nL,53,"Total del Movimiento Listado =========>  $" + ;
           TRANSFORM( ::aMV[3],::aMV[5] ) + " " + TRANSFORM( ::aMV[4],::aMV[5] ),,,1 )
oRpt:SetFont( oRpt:CPINormal,80,2 )
nK := oRpt:nLength - oRpt:nL
oRpt:nL += If( nK < 3, nK, 3 )
oRpt:Say( oRpt:nL,2,"Procesado por : ____________________  " + ;
           " Revisado por : ____________________",,,1 )
oRpt:NewPage()
oRpt:End()
RETURN NIL
/*
//------------------------------------//
METHOD ListoWIN() CLASS TLimov

 ::Init( ::aEnc[2], .f. ,, !::aLS[8] ,,,, 5 )
   PAGE
     ::Lineas()
   ENDPAGE
 IMPRIME END .F.

RETURN NIL
*/
//------------------------------------//
METHOD Cabecera( lSep,nSpace,nSuma ) CLASS TLimov
If lSep .AND. !::aEnc[1]
   ::aEnc[1] := ::Separator( nSpace )
EndIf
If ::aEnc[1]
   ::aEnc[1] := .F.
   If !::aLS[6]
      ::Centrar( oApl:cEmpresa,::aFnt[4],1.0 )
      UTILPRN ::oUtil 1.5, 0.5 SAY "FEC.PROC:"+DTOC( DATE() ) FONT ::aFnt[2]
      UTILPRN ::oUtil 1.5, 8.2 SAY "NIT: " + oApl:oEmp:Nit    FONT ::aFnt[2]
      UTILPRN ::oUtil 1.5,16.4 SAY "HORA: " + AmPm( TIME() )  FONT ::aFnt[2]
      ::Centrar( ::aEnc[2],::aFnt[2],2.0 )
      UTILPRN ::oUtil 2.0,16.5 SAY "PAGINA" + STR(::nPage,4 ) FONT ::aFnt[2]
   EndIf
      ::Centrar( ::aEnc[3],::aFnt[2],2.5 )
   UTILPRN ::oUtil 3.0, 1.5 SAY "TC  DOCUM. F e c h a"
   UTILPRN ::oUtil 3.0, 5.1 SAY "DESCRIPCION"
   UTILPRN ::oUtil 3.0,10.7 SAY "CUENTA"
   UTILPRN ::oUtil 3.0,12.2 SAY "INFA/INFC"
   UTILPRN ::oUtil 3.0,13.7 SAY "INFB/INFD"
   UTILPRN ::oUtil 3.0,16.7 SAY "DEBITOS"               RIGHT
   UTILPRN ::oUtil 3.0,19.2 SAY "CREDITOS"              RIGHT
   UTILPRN ::oUtil 3.0,20.5 SAY "CONS"                  RIGHT
   UTILPRN ::oUtil LINEA 3.5,1.0 TO 3.5,20.5 PEN ::oPen
   ::nLinea := 3.5
EndIf
/*
   LOCAL oFont,oPen,oBrush
   LOCAL nColor := 15724527

  DEFINE FONT  oFont  NAME "Arial" SIZE 0,-16 BOLD OF ::oPrn
  DEFINE PEN   oPen   WIDTH 2
  DEFINE BRUSH oBrush COLOR nColor
  UTILPRN ::oUtil ;
          MSG "Listado de Pendientes de Cobro" TEXTFONT oFont AT 1.25,0;
          BRUSH ::oBrush ;
          ROUND  20,20 ;
          SHADOW WIDTH 0.1 ;
          EXPANDBOX 0.1,1 ALIGN 3

   UTILPRN ::oUtil SELECT oBrush

   UTILPRN ::oUtil MSG "Cliente"+Space(60)      AT 2.5,01.00 SHADOW WIDTH .05 EXPANDBOX 0.1,0
   UTILPRN ::oUtil MSG "    VTO    "            AT 2.5,08.00 SHADOW WIDTH .05 EXPANDBOX 0.1,0
   UTILPRN ::oUtil MSG " Total"+space(15)       AT 2.5,09.80 SHADOW WIDTH .05 EXPANDBOX 0.1,0
   UTILPRN ::oUtil MSG PADC("Forma de Pago",35) AT 2.5,12.25 SHADOW WIDTH .05 EXPANDBOX 0.1,0
   UTILPRN ::oUtil MSG "   FECHA   "            AT 2.5,16.90 SHADOW WIDTH .05 EXPANDBOX 0.1,0
   UTILPRN ::oUtil MSG " Factura "              AT 2.5,18.90 SHADOW WIDTH .05 EXPANDBOX 0.1,0

   oFont:End()
   oPen:End()
   oBrush:End()

   ::oUtil:Reset()  //Valores por defecto

  oPen:End()
  oBrush:End()
   UTILPRN ::oUtil MSG "Total"+;
                       Str( nTotalGeneral,12,2 ) TEXTFONT ::aFnt[4] TEXTCOLOR CLR_HRED;
                       AT ::nLinea,09.0  SHADOW WIDTH .05 EXPANDBOX .2,1 ;
                       BRUSH ::oBrush ROUND 30,30
*/
RETURN NIL

//------------------------------------//
METHOD Lineas() CLASS TLimov
   LOCAL aRes, cNit, nK := 0
aRes := MyReadRow( ::hRes )
AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
::aMV[6] := aRes[::aLS[2]]
While ::nL > 0
   cNit := ""
   If aRes[13] > 0
      cNit :=  Buscar( {"codigo_nit",aRes[13]},"cadclien","nombre",8 )
   EndIf
      ::Cabecera( .t. )
   If nK  # aRes[4]
      nK := aRes[4]
      UTILPRN ::oUtil Self:nLinea,01.7 SAY TRANSFORM(aRes[02],"99")     RIGHT
      UTILPRN ::oUtil Self:nLinea,03.0 SAY TRANSFORM(aRes[04],"999999") RIGHT
      UTILPRN ::oUtil Self:nLinea,03.2 SAY NtChr( aRes[03],"2" ) FONT ::aFnt[5]
      UTILPRN ::oUtil Self:nLinea,05.1 SAY aRes[05]              FONT ::aFnt[5]
   EndIf
      UTILPRN ::oUtil Self:nLinea,10.7 SAY aRes[06]              FONT ::aFnt[5] LEFT
      UTILPRN ::oUtil Self:nLinea,12.2 SAY aRes[07]              FONT ::aFnt[5] LEFT
      UTILPRN ::oUtil Self:nLinea,13.7 SAY aRes[08]              FONT ::aFnt[5] LEFT
      UTILPRN ::oUtil Self:nLinea,16.7 SAY TRANSFORM( aRes[11],::aMV[5] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,19.2 SAY TRANSFORM( aRes[12],::aMV[5] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM(aRes[01],"99999")    RIGHT
      ::Cabecera( .t. )
      UTILPRN ::oUtil Self:nLinea,07.1 SAY cNit                  FONT ::aFnt[5] LEFT
      UTILPRN ::oUtil Self:nLinea,12.1 SAY aRes[09]              FONT ::aFnt[5] LEFT
      UTILPRN ::oUtil Self:nLinea,13.6 SAY aRes[10]              FONT ::aFnt[5] LEFT
   ::aMV[1] += aRes[11]
   ::aMV[2] += aRes[12]
   ::aMV[3] += aRes[11]
   ::aMV[4] += aRes[12]
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEval( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aMV[6] # aRes[::aLS[2]]
      If ::aLS[2] # 1 .AND. (::aMV[1] # 0 .OR. ::aMV[2] # 0)
         ::Cabecera( .t. )
         UTILPRN ::oUtil Self:nLinea,05.1 SAY ::aMV[8]              FONT ::aFnt[5]
         UTILPRN ::oUtil Self:nLinea,16.7 SAY TRANSFORM( ::aMV[1],::aMV[5] ) RIGHT
         UTILPRN ::oUtil Self:nLinea,19.2 SAY TRANSFORM( ::aMV[2],::aMV[5] ) RIGHT
         ::Cabecera( .t.,1.5 )
      EndIf
      ::aMV[1] := ::aMV[2] := 0
      ::aMV[6] := aRes[::aLS[2]]
   EndIf
End While

::Cabecera( .t. )
UTILPRN ::oUtil Self:nLinea,03.5 SAY "Total del Movimiento Listado =========>  $" FONT ::aFnt[5]
UTILPRN ::oUtil Self:nLinea,16.7 SAY TRANSFORM( ::aMV[3],::aMV[5] ) RIGHT
UTILPRN ::oUtil Self:nLinea,19.2 SAY TRANSFORM( ::aMV[4],::aMV[5] ) RIGHT

::Cabecera( .t.,1.0 )
UTILPRN ::oUtil Self:nLinea,00.9 SAY "Procesado por : ____________________" FONT ::aFnt[2]
UTILPRN ::oUtil Self:nLinea,10.9 SAY " Revisado por : ____________________" FONT ::aFnt[2]
RETURN .t.

// 1_nCol, 2_cTexto1, 3_cTexto2, 4_Alineacion, 5_Imprimo( 1_Si, 0_No )
PROCEDURE ImpLine( aLinea,oRpt )
   LOCAL nC, nCol, lSi := .f.
FOR nC := 1 TO LEN( aLinea ) STEP 5
   If aLinea[nC+4] == 1 .AND. !EMPTY( aLinea[nC+2] )
      lSi := .t.
      Exit
   EndIf
NEXT nC
If lSi
   oRpt:StartLine()
// If aTit[1]
//    aTit[1] := .f.
//    oRpt:Say( aTit[2], aTit[3], 1, aTit[4] )
// EndIf
   FOR nC := 1 TO LEN( aLinea ) STEP 5
      oRpt:Say( aLinea[nC], aLinea[nC+1]+aLinea[nC+2], 1, aLinea[nC+3] )
   NEXT nC
   oRpt:EndLine()
EndIf
RETURN