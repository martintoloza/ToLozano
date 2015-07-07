// Programa.: CGELIAUX.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Libro Auxiliar de Contabilidad
//            Saldos de una Cuenta y Su movimiento
#include "Fivewin.ch"
#include "btnget.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE CgeLiAux()
   LOCAL oDlg, oGet := ARRAY(15), oA, oCt, oNi
   LOCAL aX := { .f.,.f.,"","","","","","","NIT" }, nP
 oA := TLiaux() ;  oA:New()
oCt := TPuc()   ; oCt:New()
oNi := TNits()  ; oNi:New()
DEFINE DIALOG oDlg TITLE oA:aEnc[2] FROM 0, 0 TO 19,76
   @ 02,00 SAY "CUENTA INICIAL" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 02,82 BTNGET oGet[1] VAR oA:aLS[1] OF oDlg PICTURE "9999999999" ;
      ACTION EVAL({|| If(oCt:Mostrar(), (oA:aLS[1] := oCt:oDb:CUENTA,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})  ;
      VALID If( oCt:oDb:Seek( {"empresa",oApl:nPUC,"cuenta",oA:aLS[1]} ),;
              ( aX[1] := InfAc( oCt:oDb,@nP,"NIT" )                 ,;
                If( (aX[2] := InfAc( oCt:oDb,@nP ))                 ,;
                     aX[7] := TRIM( oCt:oDb:FldLoad( nP+5 ) ), )    ,;
                aX[3] := oCt:oDb:NOMBRE, oDlg:Update(), .t. )       ,;
              ( MsgStop( "Está Cuenta NO EXISTE !!!" ), .f. ) )      ;
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"
   @ 02,140 SAY aX[3] OF oDlg PIXEL SIZE 160,10 UPDATE COLOR nRGB( 128,0,255 )
   @ 14,00 SAY "CUENTA   FINAL" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 14,82 BTNGET oGet[2] VAR oA:aLS[2] OF oDlg PICTURE "9999999999" ;
      ACTION EVAL({|| If(oCt:Mostrar(), (oA:aLS[2] := oCt:oDb:CUENTA,;
                        oGet[2]:Refresh(), oGet[2]:lValid(.f.)),)})  ;
      VALID If( oCt:oDb:Seek( {"empresa",oApl:nPUC,"cuenta",oA:aLS[2]} ),;
              ( aX[1] := InfAc( oCt:oDb,@nP,"NIT" )                 ,;
                If( (aX[2] := InfAc( oCt:oDb,@nP ))                 ,;
                     aX[8] :=aX[9]:=TRIM( oCt:oDb:FldLoad(nP+5) ), ),;
                aX[4] := oCt:oDb:NOMBRE, oDlg:Update(), .t. )       ,;
              ( MsgStop( "Está Cuenta NO EXISTE !!!" ), .f. ) )      ;
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"
   @ 14,140 SAY aX[4] OF oDlg PIXEL SIZE 160,10 UPDATE COLOR nRGB( 128,0,255 )
   @ 26,00 SAY "NIT INICIAL" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 26,82 BTNGET oGet[3] VAR oA:aLS[3] OF oDlg PICTURE "99999999999";
      VALID EVAL( {|| If( EMPTY( oA:aLS[3] ), .t.                   ,;
              (If( oNi:oDb:Seek( { "codigo",oA:aLS[3] } )           ,;
              ( aX[5] := oNi:oDb:NOMBRE, oDlg:Update(), .t. )       ,;
              ( MsgStop("Este Nit no Existe"),.f.)))) } )            ;
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"                            ;
      ACTION EVAL({|| If(oNi:Mostrar(), (oA:aLS[3] := oNi:oDb:CODIGO,;
                        oGet[3]:Refresh(), oGet[3]:lValid(.f.)),)})  ;
      WHEN aX[1]
   @ 26,140 SAY aX[5] OF oDlg PIXEL SIZE 160,10 UPDATE COLOR nRGB( 128,0,255 )
   @ 38,00 SAY "NIT   FINAL" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 38,82 BTNGET oGet[4] VAR oA:aLS[4] OF oDlg PICTURE "99999999999";
      VALID EVAL( {|| If( EMPTY( oA:aLS[4] ), .t.                   ,;
              (If( oNi:oDb:Seek( { "codigo",oA:aLS[4] } )           ,;
              ( aX[6] := oNi:oDb:NOMBRE, oDlg:Update(), .t. )       ,;
              ( MsgStop("Este Nit no Existe"),.f.)))) } )            ;
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"                            ;
      ACTION EVAL({|| If(oNi:Mostrar(), (oA:aLS[4] := oNi:oDb:CODIGO,;
                        oGet[4]:Refresh(), oGet[4]:lValid(.f.)),)})  ;
      WHEN aX[1]
   @ 38,140 SAY aX[6] OF oDlg PIXEL SIZE 160,10 UPDATE COLOR nRGB( 128,0,255 )
   @ 50, 00 SAY aX[7]+" INICIAL" OF oDlg RIGHT PIXEL SIZE 80,10 UPDATE
   @ 50, 82 GET oGet[5] VAR oA:aLS[5] OF oDlg PICTURE "9999999999" SIZE 44,10 PIXEL;
      WHEN aX[2] UPDATE
   @ 62, 00 SAY aX[8]+"   FINAL" OF oDlg RIGHT PIXEL SIZE 80,10 UPDATE
   @ 62, 82 GET oGet[6] VAR oA:aLS[6] OF oDlg PICTURE "9999999999" SIZE 44,10 PIXEL;
      WHEN aX[2] UPDATE
   @ 74, 00 SAY "PERIODO INICIAL"  OF oDlg RIGHT PIXEL SIZE 80,10
   @ 74, 82 GET oGet[7] VAR oA:aLS[7] OF oDlg PICTURE "999999" SIZE 32,10 PIXEL;
      VALID NtChr( oA:aLS[7],"P" )
   @ 86, 00 SAY "PERIODO   FINAL"  OF oDlg RIGHT PIXEL SIZE 80,10
   @ 86, 82 GET oGet[8] VAR oA:aLS[8] OF oDlg PICTURE "999999" SIZE 32,10 PIXEL;
      VALID NtChr( oA:aLS[8],"P" )
   @ 86,136 CHECKBOX oGet[09] VAR oA:aLS[9] PROMPT "TOTAL X " +aX[9] OF oDlg ;
      SIZE 60,10 PIXEL
   @ 98, 00 SAY "Libro" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 98, 82 COMBOBOX oGet[10] VAR oA:aLS[12] ITEMS { "COLGAAP","IFRS" };
      SIZE 48,90 OF oDlg PIXEL;
      WHEN !EMPTY(oApl:oEmp:NIIF) .AND. oA:aLS[7] >= oApl:oEmp:NIIF
   @ 110, 00 SAY "CLASE DE LISTADO"    OF oDlg RIGHT PIXEL SIZE 80,10
   @ 110, 82 COMBOBOX oGet[11] VAR oA:aLS[10] ITEMS { "Matriz","Laser","Excel" };
      SIZE 48,90 OF oDlg PIXEL
   @ 110,136 CHECKBOX oGet[12] VAR oA:aLS[11] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,10 PIXEL
   @ 122,00 SAY "Escoja la Fuente"  OF oDlg RIGHT PIXEL SIZE 80,10
   @ 122,82 COMBOBOX oGet[13] VAR oA:cFont ITEMS oA:aFont SIZE 80,99 OF oDlg PIXEL;
      WHEN oA:aLS[10] > 1
   @ 122,170 BUTTON oGet[14] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[14]:Disable(), If( aX[2], AFILL( oA:aLS,0,3,2 ), ),;
        oA:ArmarMOV( oDlg,oCt:oDb )  , oGet[14]:Enable()       ,;
        oGet[14]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 122,220 BUTTON oGet[15] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 128, 02 SAY "[CGELIAUX]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT ( Empresa( .t. ) )
oCt:oDb:Destroy()
RETURN

//------------------------------------//
CLASS TLiaux FROM TIMPRIME

 DATA aLS, aMV, nF, oAux, oExc

 METHOD NEW( cFile,hDC ) Constructor
 METHOD ArmarMOV( oDlg,oPuc )
 METHOD ListoDOS( oDlg )
 METHOD Lineas()
 METHOD LineaCor( oRpt )
 METHOD LineaTit( oRpt )
 METHOD Cabecera( lSep,nSpace )
 METHOD Totales( oRpt )
 METHOD ExcelAUX()
 METHOD ExcelCab( oExcel )
 METHOD SayExec( aEx,nC )
ENDCLASS

//------------------------------------//
METHOD NEW( cFile,hDC ) CLASS TLiaux
If cFile == NIL
   cFile := SPACE(10)
   hDC := GetDC( 0 )
   ::aFont:= GetFontNames( hDC )
   ::aLS  := { cFile,cFile,1,1,cFile,cFile,"","",.t.,oApl:nTFor,.t.,;
               1,LOWER( ALLTRIM(oApl:cUser) ) + "aux" }
   ::aMV  := { 0,0,0,0,SPACE(10),"#,###,###,###.##","999,999,999,999.99",0,"",.f.,0 }
   ::aEnc := { .t.,"LIBROS AUXILIARES DE CONTABILIDAD","","","","","" }
   ::aLS[4] := Buscar( "SELECT MAX(codigo) FROM cadclien","CM",,8 )
   ::aLS[7] := ::aLS[8] := NtChr( DATE(),"1" )
   ::cFont := "Arial"
ElseIf cFile == "NEW"
   If oApl:lOffice
      cFile := cFilePath( GetModuleFileName( GetInstance() )) + "AUX.csv"
      FERASE( cFile )
      ::oExc := FCREATE( cFile,0 )
      If FERROR() != 0
         Msginfo( FERROR(),"No se pudo crear el archivo "+cFile )
         RETURN .T.
      EndIf
   Else
      cFile := cFilePath( GetModuleFileName( GetInstance() )) + "AUX.xls"
      If EMPTY( cFile )
         RETURN .T.
      EndIf
      ::oExc := TExcelScript():New()
      ::oExc:Create( cFile )
      ::oExc:Font("Verdana")
      ::oExc:Visualizar(.F.)
   EndIf
   oApl:oWnd:SetMsg( "Exportando hacia "+cFile )
Else
   If oApl:lOffice
      If !FCLOSE( ::oExc )
         Msginfo( FERROR(),"Error cerrando el archivo AUX.csv" )
      EndIf
      WAITRUN( "OPENOFICE.BAT AUX.csv", 0 )
   Else
      ::oExc:Borders( cFile + LTRIM(STR(::nF)) ,,, 1 )
      ::oExc:ColumnWidth( 4 , 45 )
      ::oExc:Visualizar(.T.)
      ::oExc:End(.f.) ; ::oExc := NIL
   EndIf
EndIf
RETURN .F.

//------------------------------------//
METHOD ArmarMOV( oDlg,oPuc ) CLASS TLiaux
   LOCAL aRes, cVar, hRes, nL, nP, aV := ::aLS
oDlg:SetText( "POR FAVOR << ESPERE >>" )
If aV[2] == aV[1] .AND. LEN( ALLTRIM(aV[2]) ) < 8
   aV[2] := STRTRAN( aV[2]," ","9" )
EndIf
aV[4] := If( EMPTY(aV[4]), 999999999999, aV[4] )
aV[6] := If( EMPTY(aV[6]), "9999999999", aV[6] )
Swap( @aV,1,2 ) //Cuenta
Swap( @aV,7,8 ) //Periodo
/*
SELECT a.cuenta, n.codigo, a.codigo, SUM(a.valor_deb), SUM(a.valor_cre)
FROM cgeacumn a LEFT JOIN cadclien n
USING(codigo_nit)
WHERE empresa = 2
  AND cuenta  = '51353501'
  AND ano_mes >= '201013'
  AND ano_mes <= '201112'
GROUP BY a.cuenta, n.codigo, a.codigo

SELECT fuente, comprobant, cuenta, codigo, codvar, fecha, valor_deb, valor_cre, nombre
FROM cgeauxil
ORDER BY cuenta, codigo, codigo_nit, codvar, fecha
*/
aRes := "SELECT d.cuenta, d.infa, d.infb, d.infc, d.infd, d.codigo_nit, "+;
          "d.valor_deb, d.valor_cre, c.fecha, c.fuente, "+;
          "c.comprobant, c.concepto, n.codigo, n.nombre "+;
         "FROM cgemovc c, cgemovd d LEFT JOIN cadclien n"+;
         " USING( codigo_nit )"                          +;
         "WHERE d.empresa = c.empresa"                   +;
          " AND d.ano_mes = c.ano_mes"                   +;
          " AND d.control = c.control AND c.estado <> 2" +;
          " AND d.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
          " AND d.cuenta  >= " + xValToChar( aV[1] )     +;
          " AND d.cuenta  <= " + xValToChar( aV[2] )     +;
          " AND d.ano_mes >= " + xValToChar( aV[7] )     +;
          " AND d.ano_mes <= " + xValToChar( aV[8] )     +;
          " AND d.libro    = " + LTRIM(STR(::aLS[12]))
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes ) ; RETURN NIL
EndIf
Swap( @aV,3,4 ) //Nit
Swap( @aV,5,6 ) //Codigo
/*
If oApl:oDb:ExistTable( ::aLS[13] )
   MSQuery( oApl:oMySql:hConnect,"DELETE FROM " + ::aLS[13] )
Else
   Diccionario( "cgeauxil",::aLS[13] )
EndIf
*/
 ::aLS  := aV
 ::oAux := oApl:Abrir( "cgeauxil","cuenta, codigo, codvar, fecha",,.t. )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   oPuc:Seek( {"empresa",oApl:nPuc,"cuenta",aRes[1]} )
   cVar := If( InfAc( oPuc,@nP ), aRes[nP+1], "" )
   If (aRes[6] > 0  .AND. Rango( aRes[13],aV[3],aV[4] )) .OR.;
      (!EMPTY(cVar) .AND. EMPTY( aV[6] ))                .OR.;
      (!EMPTY(cVar) .AND. Rango( cVar,aV[5],aV[6] ))
      ::oAux:xBlank()
      ::oAux:CUENTA    := aRes[1]  ; ::oAux:CODIGO    := aRes[13]
      ::oAux:CODVAR    := cVar     ; ::oAux:FECHA     := aRes[09]
      ::oAux:FUENTE    := aRes[10] ; ::oAux:COMPROBANT:= aRes[11]
      ::oAux:CONCEPTO  := STRTRAN( aRes[12],'"',"" )
      ::oAux:INFA      := aRes[02] ; ::oAux:INFB      := aRes[03]
      ::oAux:INFC      := aRes[04] ; ::oAux:INFD      := aRes[05]
      ::oAux:VALOR_DEB := aRes[07] ; ::oAux:VALOR_CRE := aRes[08]
      ::oAux:CODIGO_NIT:= aRes[06] ; ::oAux:NOMBRE    := aRes[14]
      ::oAux:PNOMBRE   := oPuc:NOMBRE ; ::oAux:DB_CR  := oPuc:DB_CR
      ::oAux:Insert(.f.)
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
 cVar := ACLONE( ::aLS )
 aV   := { NtChr( ::aLS[7],"F" ),NtChr( ::aLS[8],"F" ) }
 ::aEnc[2]+= NtChr( ::aLS[12],"CI" )
 ::aEnc[3]:= "PERIODO DE : " + NtChr( aV[1],"6" ) + " A " + NtChr( aV[2],"6" )
 ::aLS[7] := STR( VAL( LEFT(::aLS[7],4) )-1,4 ) + "13"
 ::aLS[8] := NtChr( aV[1]-1,"1" )
 ::aLS[8] := If( ::aLS[8] < ::aLS[7], ::aLS[7], ::aLS[8] )
//Saldos Anteriores
If ::aLS[9]
   aRes := "SELECT a.cuenta, n.codigo, n.nombre, a.codigo, "+;
              "SUM(a.valor_deb), SUM(a.valor_cre), a.codigo_nit "+;
           "FROM cgeacumn a LEFT JOIN cadclien n "          +;
            "USING( codigo_nit )"                           +;
           "WHERE a.empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND a.cuenta  >= " + xValToChar( ::aLS[1] )   +;
            " AND a.cuenta  <= " + xValToChar( ::aLS[2] )   +;
            " AND a.ano_mes >= " + xValToChar( ::aLS[7] )   +;
            " AND a.ano_mes <= " + xValToChar( ::aLS[8] )   +;
            " AND a.libro    = " + LTRIM(STR( ::aLS[12]))   +;
          " GROUP BY a.cuenta, n.codigo, a.codigo_nit, a.codigo"
/*
            " AND a.codigo  >= " + xValToChar( ::aLS[5] )   +;
            " AND a.codigo  <= " + xValToChar( ::aLS[6] )   +;
            " AND n.codigo  >= " +  LTRIM(STR( ::aLS[3] ))  +;
            " AND n.codigo  <= " +  LTRIM(STR( ::aLS[4] ))  +;
*/
Else
   aRes := "SELECT cuenta, 0, '', '0', SUM(valor_deb), SUM(valor_cre), 0 "+;
           "FROM cgeacumc "                               +;
           "WHERE empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND cuenta  >= " + xValToChar( ::aLS[1] )   +;
            " AND cuenta  <= " + xValToChar( ::aLS[2] )   +;
            " AND ano_mes >= " + xValToChar( ::aLS[7] )   +;
            " AND ano_mes <= " + xValToChar( ::aLS[8] )   +;
            " AND libro    = " + LTRIM(STR( ::aLS[12]))   +;
          " GROUP BY cuenta"
EndIf
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
//MsgInfo( aRes,STR(nL) )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If (aRes[2] > 0     .AND. Rango( aRes[2],::aLS[3],::aLS[4] )) .OR.;
      (!EMPTY(aRes[4]) .AND. Rango( aRes[4],::aLS[5],::aLS[6] ))
      If aRes[5] - aRes[6] <> 0
         oPuc:Seek( {"empresa",oApl:nPuc,"cuenta",aRes[1]} )
         If ::aLS[9]
            nP := If( ::oAux:Seek( {"cuenta",aRes[1],"codigo",aRes[2],"codigo_nit",aRes[7],;
                                    "codvar",aRes[4]} ), 1, 0 )
         Else
            aRes[4] := ""
            nP := If( ::oAux:Seek( {"cuenta",aRes[1]} ), 1, 0 )
         EndIf
         ::oAux:xBlank()
         ::oAux:CUENTA    := aRes[1]  ; ::oAux:CODIGO    := aRes[2]
         ::oAux:CODVAR    := aRes[4]  ; ::oAux:FUENTE    := -9
         ::oAux:CONCEPTO  := "SALDO ANTERIOR"
         ::oAux:VALOR_DEB := aRes[5]  ; ::oAux:VALOR_CRE := aRes[6]
         ::oAux:NOMBRE    := aRes[3]  ; ::oAux:PNOMBRE   := oPuc:NOMBRE
         ::oAux:COMPROBANT:= nP       ; ::oAux:DB_CR     := oPuc:DB_CR
         ::oAux:CODIGO_NIT:= aRes[7]
         ::oAux:Insert(.f.)
      EndIf
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
//FIN Saldos Anteriores
 ::aLS[1] := ::aLS[2] := " "
       nP := If( ::aLS[3] > 1, ::aLS[3], 0 )
 ::oAux:Seek( {"codigo >= ",nP,"codvar >= ",::aLS[5]},"cuenta, codigo, codigo_nit, codvar, fecha" )
If ::aLS[10] == 1
   ::ListoDOS( oDlg )
ElseIf ::aLS[10] == 2
   ::Lineas()
Else
   ::ExcelAUX()
EndIf
::aLS := ACLONE( cVar )
::oAux:Destroy()
MSQuery( oApl:oMySql:hConnect,"DROP TABLE cgeauxil" )
oApl:oDb:GetTables()
RETURN NIL

//------------------------------------//
METHOD ListoDOS( oDlg ) CLASS TLiaux
 //LOCAL aSal := { 0,0,0 }, cNom, cTit, cVar, lInf
   LOCAL oRpt := TDosPrint()
::aEnc[4] := "Descripcion"+ SPACE(31)+ "F e c h a  TC Docum.  INFA/INFC  INFB/INFD    "
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[2],::aEnc[3],"","",SPACE(87)+;
         "Saldo Anterior  ------MOVIMIENTO  DEL  MES------",""},::aLS[11],,2 )
*234567890123456789012345678901234567890 25-Mar/1998--4---1171 8060018842 ---------- #,###,###,###.## #,###,###,###.## #,###,###,###.##
/*
   If ::aMV[4]  # ::oAux:CODIGO .OR.;
      ::aMV[5]  # ::oAux:CODVAR .OR. ::aLS[1] # ::oAux:CUENTA
      ::aMV[4] := ::oAux:CODIGO
      ::aMV[5] := ::oAux:CODVAR
      cTit := TRANSFORM(::aMV[4],"999,999,999")
      cVar := "CODIGO"
      lInf := If( ::aLS[1] == ::oAux:CUENTA .AND.;
                  ::aLS[2] # STR( ::aMV[4],10 )+::aMV[5] .AND. !::aLS[9], .f., .t. )
      ::aLS[2] := STR( ::aMV[4],10 ) + ::aMV[5]
      If ( ::aMV[2] # 0 .OR. ::aMV[3] # 0 ) .AND. lInf
         ::Totales( aSal[3],oRpt )
         oRpt:NewPage()
         oRpt:nL    := oRpt:nLength
         oRpt:nPage := 0
      EndIf
      If ::aLS[1]  # ::oAux:CUENTA
         ::aLS[1] := ::oAux:CUENTA
         cNom := If( EMPTY( ::aMV[5] ), "", ALLTRIM(::aMV[5])+" " )
      EndIf
      do Case
      Case !::aLS[9]
         aSal := SaldoCta( { ::aLS[1] },::aLS[8],::aLS[7],1 )
         cTit := " "
         cVar := "CUENTA"
      Case ::aMV[4] > 0 .AND. EMPTY( ::aMV[5] )
         cTit := SPACE(11) + "NIT : " + cTit + "  " + ::oAux:NOMBRE
      Case ::aMV[4] = 0 .AND. !EMPTY( ::aMV[5] )
         cTit := cNom + ::aMV[5] + " " + ::oAux:PNOMBRE
      OtherWise
         cTit := cNom + ::aMV[5] + " " + "NIT : " + cTit + "  " + ::oAux:PNOMBRE
      EndCase
      If cVar # "CUENTA"
         aSal := SaldoCta( {::aLS[1],::aMV[5],::oAux:CODIGO_NIT},::aLS[8],::aLS[7],1 )
      EndIf
      oRpt:aEnc[3] := ::aLS[1] + " " + ::oAux:PNOMBRE
      oRpt:aEnc[4] := cTit
      oRpt:aEnc[6] := ::aEnc[4]+ If( ::oAux:DB_CR==1, "D E B I T O  ", "C R E D I T O")+;
                       "          Debitos         Creditos"
   EndIf
*/
While !::oAux:EOF()
      ::LineaCor( oRpt )
   If ::oAux:FUENTE == -9
      LOOP
   EndIf
   ::aMV[2] += ::oAux:VALOR_DEB
   ::aMV[3] += ::oAux:VALOR_CRE
   oRpt:Titulo( 135 )
   oRpt:Say( oRpt:nL,00,::oAux:CONCEPTO + " " + NtChr( ::oAux:FECHA,"2" )+ STR(::oAux:FUENTE,3) + ;
              STR(::oAux:COMPROBANT,7) + " " + ::oAux:INFA + " " + ::oAux:INFB + SPACE(18) + ;
              TRANSFORM( ::oAux:VALOR_DEB,::aMV[6] ) + " " + TRANSFORM( ::oAux:VALOR_CRE,::aMV[6] ) )
   oRpt:Say( oRpt:nL+1,63,::oAux:INFC + " " + ::oAux:INFD )
   oRpt:nL += 2
   ::oAux:Skip(1):Read()
   ::oAux:xLoad()
EndDo
If ::aMV[2] # 0 .OR. ::aMV[3] # 0
   ::Totales( oRpt )
EndIf
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD Lineas() CLASS TLiaux
 ::Init( ::aEnc[2], .f. ,, !::aLS[11] ,,,, 5 )
   PAGE
While !::oAux:EOF()
      ::LineaCor()
   If ::oAux:FUENTE == -9
      LOOP
   EndIf
   ::aMV[2] += ::oAux:VALOR_DEB
   ::aMV[3] += ::oAux:VALOR_CRE
   ::Cabecera( .t. )
   UTILPRN ::oUtil Self:nLinea, 0.7 SAY ::oAux:CONCEPTO
   UTILPRN ::oUtil Self:nLinea, 6.4 SAY NtChr( ::oAux:FECHA,"2" )
   UTILPRN ::oUtil Self:nLinea, 8.5 SAY TRANSFORM(::oAux:FUENTE,"99")         RIGHT
   UTILPRN ::oUtil Self:nLinea, 9.8 SAY TRANSFORM(::oAux:COMPROBANT,"999999") RIGHT
   UTILPRN ::oUtil Self:nLinea,10.0 SAY ::oAux:INFA
   UTILPRN ::oUtil Self:nLinea,11.5 SAY ::oAux:INFB
   UTILPRN ::oUtil Self:nLinea,17.7 SAY TRANSFORM( ::oAux:VALOR_DEB,::aMV[6] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,20.2 SAY TRANSFORM( ::oAux:VALOR_CRE,::aMV[6] ) RIGHT
   ::nLinea += .5
   UTILPRN ::oUtil Self:nLinea,10.0 SAY ::oAux:INFC
   UTILPRN ::oUtil Self:nLinea,11.5 SAY ::oAux:INFD
   ::oAux:Skip(1):Read()
   ::oAux:xLoad()
EndDo
If ::aMV[2] # 0 .OR. ::aMV[3] # 0
   ::Totales()
EndIf
   ENDPAGE
 IMPRIME END .F.
 ::aEnc[1] := .T.
RETURN NIL

//------------------------------------//
METHOD LineaCor( oRpt ) CLASS TLiaux

If ::oAux:FUENTE == -9
    If ::aMV[1] # 0 .OR. ::aMV[2] # 0 .OR. ::aMV[3] # 0
       ::Totales( oRpt )
   EndIf
    ::aMV[1] := ::oAux:VALOR_DEB - ::oAux:VALOR_CRE
 //MsgInfo( TRANSFORM( ::oAux:VALOR_DEB,::aMV[6] ) + CRLF +;
 //         TRANSFORM( ::oAux:VALOR_CRE,::aMV[6] ) + CRLF +;
 //         TRANSFORM( ::aMV[1],::aMV[6] ),STR(::oAux:CODIGO)+STR(::oAux:COMPROBANT) )
   If ::oAux:COMPROBANT == 0
      ::aMV[4] := ::oAux:CODIGO
      ::aMV[5] := ::oAux:CODVAR
      ::aMV[8] := ::oAux:CODIGO_NIT
      ::aLS[2] := STR( ::aMV[4],10 ) + ::aMV[5]
      ::LineaTit( oRpt )
      ::Totales( oRpt )
   EndIf
   ::oAux:Skip(1):Read()
   ::oAux:xLoad()
EndIf

If ::aLS[1]  # ::oAux:CUENTA .OR. ;
   ::aMV[4]  # ::oAux:CODIGO .OR. ;
   ::aMV[5]  # ::oAux:CODVAR .OR. ;
   ::aMV[8]  # ::oAux:CODIGO_NIT
   ::aMV[4] := ::oAux:CODIGO
   ::aMV[5] := ::oAux:CODVAR
   ::aMV[8] := ::oAux:CODIGO_NIT
   //MsgInfo( TRANSFORM( ::aMV[1],::aMV[6] ),"LineaCor"+STR(::oAux:CODIGO) )

   ::aMV[10]:= If( ::aLS[1] == ::oAux:CUENTA .AND.;
                   ::aLS[2] # STR( ::aMV[4],10 )+::aMV[5] .AND. !::aLS[9], .f., .t. )
   ::aLS[2] := STR( ::aMV[4],10 ) + ::aMV[5]
   If ( ::aMV[2] # 0 .OR. ::aMV[3] # 0 ) .AND. ::aMV[10]
      //MsgInfo( ::aLS[2],"Voy a Totales" )
      ::Totales( oRpt )
   EndIf
   ::LineaTit( oRpt )
EndIf
RETURN NIL

//------------------------------------//
METHOD LineaTit( oRpt ) CLASS TLiaux

   If ::aLS[1]  # ::oAux:CUENTA
      ::aLS[1] := ::oAux:CUENTA
      ::aMV[9] := If( EMPTY( ::aMV[5] ), "", ALLTRIM(::aMV[5])+" " )
   EndIf
      ::aEnc[6]:= TRANSFORM( ::aMV[4],"9,999,999,999" )
   If !::aLS[9]
      ::aEnc[6] := " "
   ElseIf ::aMV[4] > 0 .AND. EMPTY( ::aMV[5] )
      ::aEnc[6] := SPACE(11) + "NIT : " + ::aEnc[6] + "  " + ::oAux:NOMBRE
   ElseIf ::aMV[4] = 0 .AND. !EMPTY( ::aMV[5] )
      ::aEnc[6] := ::aMV[9] + ::aMV[5] + " " + ::oAux:PNOMBRE
   Else
      ::aEnc[6] := ::aMV[9] + ::aMV[5] + " " + "NIT : " + ::aEnc[6] + "  " + ::oAux:PNOMBRE
   EndIf
   ::aEnc[5] := ::aLS[1] + " " + ::oAux:PNOMBRE
   ::aEnc[7] := If( ::oAux:DB_CR == 1, "D E B I T O", "C R E D I T O" )
   //If oRpt # NIL
   If ::aLS[10] == 1
      oRpt:aEnc[3] := ::aEnc[5]
      oRpt:aEnc[4] := ::aEnc[6]
      oRpt:aEnc[6] := ::aEnc[4] + ::aEnc[7] + "          Debitos         Creditos"
   EndIf
RETURN NIL

//------------------------------------//
METHOD Cabecera( lSep,nSpace ) CLASS TLiaux
If lSep .AND. !::aEnc[1]
   ::aEnc[1] := ::Separator( nSpace )
EndIf
If ::aEnc[1]
   ::aEnc[1] := .F.
   ::Centrar( oApl:cEmpresa,::aFnt[4],1.0 )
   UTILPRN ::oUtil 1.5, 8.2 SAY "NIT: " + oApl:oEmp:Nit
   ::FechaHora( 1.5, 0.5, 16.4 )
   ::Centrar( ::aEnc[2],,2.0 )
   UTILPRN ::oUtil 2.0,16.5 SAY "PAGINA" + STR(::nPage,4 )
   ::Centrar( ::aEnc[3],,2.5 )
   UTILPRN ::oUtil 3.0, 1.0 SAY ::aEnc[5]
   UTILPRN ::oUtil 3.5, 2.5 SAY ::aEnc[6]
   UTILPRN ::oUtil 4.0,15.2 SAY "Saldo Anterior" RIGHT
   UTILPRN ::oUtil 4.0,20.2 SAY "-----MOVIMIENTO DEL MES-----" RIGHT
   UTILPRN ::oUtil 4.5, 0.7 SAY "Descripcion"
   UTILPRN ::oUtil 4.5, 6.5 SAY "F e c h a"
   UTILPRN ::oUtil 4.5, 8.2 SAY "TC  DOCUM."
   UTILPRN ::oUtil 4.5,10.0 SAY "INFA/INFC"
   UTILPRN ::oUtil 4.5,11.5 SAY "INFB/INFD"
   UTILPRN ::oUtil 4.5,15.2 SAY ::aEnc[7]        RIGHT
   UTILPRN ::oUtil 4.5,17.7 SAY "DEBITOS"        RIGHT
   UTILPRN ::oUtil 4.5,20.2 SAY "CREDITOS"       RIGHT
   UTILPRN ::oUtil LINEA 5.0,1.0 TO 5.0,20.0 PEN ::oPen
   ::nLinea := 5.0
EndIf
RETURN NIL

//------------------------------------//
METHOD Totales( oRpt ) CLASS TLiaux
   ::aMV[10] := If( ::aMV[2] # 0 .OR. ::aMV[3] # 0, .t., .f. )
   ::aMV[11] := ::aMV[1] + ::aMV[2] - ::aMV[3]
If ::aLS[10] == 1
   //MsgInfo( TRANSFORM( ::aMV[1],::aMV[6] ),"Totales"+STR(::aMV[4]) )
   oRpt:Titulo( 135 )
   If ::aMV[10]
      oRpt:Say(++oRpt:nL,43,"Total del Movimiento Listado =========>  $" +;
                 TRANSFORM( ::aMV[1] ,::aMV[6] ) + " " +;
                 TRANSFORM( ::aMV[2] ,::aMV[6] ) + " " +;
                 TRANSFORM( ::aMV[3] ,::aMV[6] ) )
   EndIf
      oRpt:Say(++oRpt:nL,59,"Saldo Actual =========>$" +;
                 TRANSFORM( ::aMV[11],::aMV[7] ) )
   oRpt:NewPage()
   oRpt:nL    := oRpt:nLength
   oRpt:nPage := 0
ElseIf ::aLS[10] == 2
   ::Cabecera( .t.,1.0 )
   If ::aMV[10]
      UTILPRN ::oUtil Self:nLinea,12.6 SAY "Total del Movimiento Listado =========>  $" RIGHT
      UTILPRN ::oUtil Self:nLinea,15.2 SAY TRANSFORM( ::aMV[1] ,::aMV[6] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,17.7 SAY TRANSFORM( ::aMV[2] ,::aMV[6] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,20.2 SAY TRANSFORM( ::aMV[3] ,::aMV[6] ) RIGHT
      ::nLinea += .5
   EndIf
      UTILPRN ::oUtil Self:nLinea,12.6 SAY "Saldo Actual =========>  $" RIGHT
      UTILPRN ::oUtil Self:nLinea,15.2 SAY TRANSFORM( ::aMV[11],::aMV[7] ) RIGHT
   ::nLinea := ::nEndLine
   ::nPage  := 0
Else
   ::ExcelCab()
   If ::aMV[10]
      ::SayExec( { {"",,,,}, {"",,,,}, {"",,,,},;
                   {"Total del Movimiento Listado =========>  $",,,,},;
                   {"",,,,}, {"",,,,}, {::aMV[1],,,,"#.##0,00"}      ,;
                   {::aMV[2],,,,"#.##0,00"}, {::aMV[3],,,,"#.##0,00"} } )
   EndIf
      ::SayExec( { {"",,,,}, {"",,,,}, {"",,,,},;
                   {"Saldo Actual =========>  $",,,,},;
                   {"",,,,}, {"",,,,}, {::aMV[11],,,,"#.##0,00"} } )
      ::SayExec( { {"",,,,} } )
   ::aEnc[1] := .T.
EndIf
::aMV[1] := ::aMV[2] := ::aMV[3] := 0
RETURN NIL

//------------------------------------//
METHOD ExcelAUX() CLASS TLiaux
If ::NEW( "NEW" )
   RETURN NIL
EndIf
 ::nF := 1
   ::SayExec( { {"",,,,},{oApl:cEmpresa,14,,0,} } )
   ::SayExec( { {"",,,,},{"NIT: " + oApl:oEmp:Nit,12,7,0,} } )
   ::SayExec( { {"",,,,},{"",,,,},{"",,,,},{::aEnc[2],12,7,0,} } )
   ::SayExec( { {"",,,,},{"",,,,},{"",,,,},{::aEnc[3],12,7,0,} } )
While !::oAux:EOF()
      ::LineaCor()
   If ::oAux:FUENTE == -9
      LOOP
   EndIf
   ::aMV[2] += ::oAux:VALOR_DEB
   ::aMV[3] += ::oAux:VALOR_CRE
   ::ExcelCab()
   ::SayExec( { {::oAux:FUENTE,,,,}   ,{::oAux:COMPROBANT,,,,}, {NtChr( ::oAux:FECHA,"2" ),,,,},;
                {::oAux:CONCEPTO,,1,,},{::oAux:INFA,,1,,}     , {::oAux:INFA,,1,,},;
                {"",,,,},     {::oAux:VALOR_DEB,,,,"#.##0,00"}, {::oAux:VALOR_CRE,,,,"#.##0,00"} } )
   ::SayExec( { {"",,,,}, {"",,,,}, {"",,,,}, {"",,,,},;
                {::oAux:INFC,,1,,}, {::oAux:INFD,,1,,} } )
   ::oAux:Skip(1):Read()
   ::oAux:xLoad()
EndDo

If ::aMV[2] # 0 .OR. ::aMV[3] # 0
   ::Totales()
EndIf
 ::NEW( "A1:I" )
 ::aEnc[1] := .T.
RETURN NIL

//------------------------------------//
METHOD ExcelCab() CLASS TLiaux
If ::aEnc[1]
   ::aEnc[1] := .F.
   ::SayExec( { {::aEnc[5],,1,,} } )
   ::SayExec( { {"",,,,},{::aEnc[6],,1,,} } )
   ::SayExec( { {"TC",,1,,}         , {"DOCUM",,1,,}    , {"F e c h a",,1,,},;
                {"Descripcion",,1,,}, {"INFA/INFC",,1,,}, {"INFB/INFD",,1,,},;
                {::aEnc[7],,1,,}    , {"DEBITOS",,1,,}  , {"CREDITOS",,1,,} } )
EndIf
RETURN NIL

// 1_xValue, 2_nSize, 3_nAlign, 4_nStyle, 5_cFormat //
METHOD SayExec( aEx,nC ) CLASS TLiaux
 ::aEnc[4] := ""
FOR nC := 1 TO LEN( aEx )
   If oApl:lOffice
      ::aEnc[4] += XTrim( aEx[nC,1],-9 )
   Else
      ::oExc:Say( ::nF,nC,aEx[nC,1],,aEx[nC,2],,,,aEx[nC,3],,,,aEx[nC,4],aEx[nC,5] )
   // oExcel:Say( nRow, nCol, 3xValue, cFont, 5nSize, lBold, lItalic, ;
   //             lUnderLine, 9nAlign, nColor, nFondo, nOrien, 13nStyle, cFormat )
   EndIf
NEXT nC
   If oApl:lOffice
      FWRITE( ::oExc,::aEnc[4] + ::aEnc[5] )
   EndIf
 ::nF ++
RETURN NIL

//------------------------------------//
PROCEDURE Swap( xIni,xFin,nS )
   LOCAL xTem, nP := xFin
If VALTYPE( xIni ) == "A"
   If xIni[nP]  > xIni[nS]
      xTem     := xIni[nS]
      xIni[nS] := xIni[nP]
      xIni[nP] := xTem
   EndIf
Else
   If xIni  > xFin
      xTem := xFin
      xFin := xIni
      xIni := xTem
   EndIf
EndIf
RETURN