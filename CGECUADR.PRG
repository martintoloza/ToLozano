// Programa.: CGECUADR.PRG    >>> Martin A. Toloza L. <<<
// Notas....: Listo Descuadre en COMPROBANTE DE DIARIO DE CONTABILIDAD
#include "Fivewin.ch"
#INCLUDE "Utilprn.CH"

MEMVAR oApl

PROCEDURE CgeCuadr( nOpc )
   LOCAL oA, oDlg, oGet := ARRAY(6)
   LOCAL aCge := { "CUADRE DE MOVIMIENTO","CONTROL DE CONSECUTIVOS FALTANTES" }
   DEFAULT nOpc := 1
 oA := TCuadr() ; oA:New( aCge[nOpc] )
DEFINE DIALOG oDlg TITLE oA:aEnc[2] FROM 0, 0 TO 08,50
   @ 02,00 SAY "PERIODO [AAAAMM]"    OF oDlg RIGHT PIXEL SIZE 70,10
   @ 02,72 GET oGet[1] VAR oA:aLS[1] OF oDlg PICTURE "999999" SIZE 36,10 PIXEL;
      VALID NtChr( oA:aLS[1],"P" )
   @ 14,00 SAY "TIPO DE IMPRESORA"   OF oDlg RIGHT PIXEL SIZE 70,10
   @ 14,72 COMBOBOX  oGet[2] VAR oA:aLS[2] ITEMS { "Matriz","Laser" };
      SIZE 48,90 OF oDlg PIXEL
   @ 14,136 CHECKBOX oGet[3] VAR oA:aLS[3] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 26,00 SAY "Escoja la Fuente"   OF oDlg RIGHT PIXEL SIZE 70,10
   @ 26,72 COMBOBOX oGet[4] VAR oA:cFont ITEMS oA:aFont SIZE 80,99 OF oDlg PIXEL;
      WHEN oA:aLS[2] > 1
   @ 40, 50 BUTTON oGet[5] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[5]:Disable(), oA:ArmarMOV( oDlg,nOpc ), oDlg:End() ) PIXEL
   @ 40,100 BUTTON oGet[6] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 46, 02 SAY "[CGECUADR]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT ( Empresa( .t. ) )
RETURN

//------------------------------------//
CLASS TCuadr FROM TIMPRIME

 DATA aLS, aMV, hRes, nL

 METHOD NEW( cTit ) Constructor
 METHOD ArmarMOV( oDlg,nOpc )
 METHOD ListoDOS( oRpt )
 METHOD Lineas()
 METHOD Cabecera( lSep,nSpace,nSuma )
 METHOD Descuadre( nControl )
 METHOD ListoCTL( oDlg )
ENDCLASS

//------------------------------------//
METHOD NEW( cTit ) CLASS TCuadr
   LOCAL hDC := GetDC( 0 )
 ::aFont:= GetFontNames( hDC )
 ::aLS  := { NtChr( DATE(),"1" ),oApl:nTFor,.t.,1 }
 ::aMV  := { 0,0,0,0,0,0,0,"","99,999,999,999.99" }
 ::cFont:= "Arial"
 ::aEnc := { .t.,cTit,"" }
RETURN NIL

//------------------------------------//
METHOD ArmarMOV( oDlg,nOpc ) CLASS TCuadr
   LOCAL aV, oRpt
 ::aEnc[3]:= NtChr( NtChr( ::aLS[1],"F" ),"6" )
 ::aLS[1] := xValToChar( ::aLS[1] )
If (::aLS[4] := nOpc) == 2
   nOpc := 3
   aV := "SELECT f.fuente, f.descripcio, c.comprobant "  +;
         "FROM cgemovc c, cgefntes f "                   +;
         "WHERE f.ctrl_conse = '1'"                      +;
          " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
          " AND c.ano_mes = " + ::aLS[1]                 +;
          " AND c.fuente  = f.fuente"                    +;
          " AND c.estado <> 2 ORDER BY c.fuente, c.comprobant"
Else
   nOpc := ::aLS[2]
   aV := "SELECT c.control, c.concepto, c.comprobant, c.fecha, c.fuente, "+;
         "f.descripcio FROM cgemovc c, cgefntes f "      +;
         "WHERE c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
          " AND c.ano_mes = " + ::aLS[1]                 +;
          " AND c.estado <> 2"                           +;
          " AND f.fuente = c.fuente ORDER BY c.fuente, c.comprobant"
EndIf
::hRes := If( MSQuery( oApl:oMySql:hConnect,aV ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes )
   RETURN NIL
EndIf
 aV := { {|| ::ListoDOS( oRpt ) },{|| ::Lineas() },;
         {|| ::ListoCTL( oRpt ) } }
If ::aLS[2] == 1
   oRpt := TDosPrint()
   If nOpc == 1
      oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[2],::aEnc[3]  ,;
         "TC Docum.  F e c h a  Descripcion" + SPACE(34) + "Cuenta       "+;
         "D E B I T O S    C R E D I T O S   D E S C U A D R E"},::aLS[3],,2 )
   Else
      oRpt:New( oApl:cPuerto,oApl:cImpres,{::aEnc[2],::aEnc[3],SPACE(10)+;
         "C O M P R O B A N T E                  DOCUMENTOS FALTANTES"},::aLS[3] )
   EndIf
   EVAL( aV[ nOpc ] )
   oRpt:NewPage()
   oRpt:End()
Else
   ::Init( ::aEnc[2], .f. ,, !::aLS[3] ,,,, If( nOpc == 2, 5, 2 ) )
     PAGE
       EVAL( aV[ nOpc ] )
     ENDPAGE
   IMPRIME END .F.
EndIf
 MSFreeResult( ::hRes )
RETURN NIL

//------------------------------------//
METHOD ListoDOS( oRpt ) CLASS TCuadr
   LOCAL aRes, aMD, cQry, hRes, nL
aRes := MyReadRow( ::hRes )
AEval( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
::aMV[7] := aRes[5]
::aMV[8] := aRes[6]
While ::nL > 0
   If ::Descuadre( aRes[1] )
      cQry := "SELECT cuenta, valor_deb, valor_cre FROM cgemovd "+;
              "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND ano_mes = " + ::aLS[1]                 +;
               " AND control = " + LTRIM(STR( aRes[1] ))
      hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      nL   := MSNumRows( hRes )
         oRpt:Titulo( 133 )
         oRpt:Say( oRpt:nL,00,STR(aRes[5],2)+ STR(aRes[3],7)+ " "+;
                    NtChr( aRes[4],"2" )+ " " + aRes[2] + STR(aRes[1],4) )
      While nL > 0
         aMD := MyReadRow( hRes )
         AEval( aMD, {| xV,nP | aMD[nP] := MyClReadCol( hRes,nP ) } )
         oRpt:Titulo( 133 )
         oRpt:Say( oRpt:nL,67,aMD[1] )
         oRpt:Say( oRpt:nL,79,TRANSFORM(aMD[2],"@Z 9,999,999,999.99") )
         oRpt:Say( oRpt:nL,98,TRANSFORM(aMD[3],"@Z 9,999,999,999.99") )
         oRpt:nL ++
         nL --
      EndDo
      MSFreeResult( hRes )
      oRpt:Say(  oRpt:nL, 79,"-----------------  -----------------" )
      oRpt:Say(++oRpt:nL, 79,TRANSFORM( ::aMV[5],::aMV[9] ) )
      oRpt:Say(  oRpt:nL, 98,TRANSFORM( ::aMV[6],::aMV[9] ) )
      oRpt:Say(  oRpt:nL,116,TRANSFORM( ::aMV[5]-::aMV[6],::aMV[9] ) )
      oRpt:nL += 2
   EndIf
   ::aMV[1] += ::aMV[5]
   ::aMV[2] += ::aMV[6]
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEval( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aMV[7] # aRes[5]
      oRpt:Titulo( 133 )
      oRpt:Say( oRpt:nL, 07,"SUBTOTAL COMPROBANTE" + STR(::aMV[7],5) + ;
                 "  " + ::aMV[8] )
      oRpt:Say( oRpt:nL, 79,TRANSFORM( ::aMV[1],::aMV[9] ) )
      oRpt:Say( oRpt:nL, 98,TRANSFORM( ::aMV[2],::aMV[9] ) )
      oRpt:Say( oRpt:nL,116,TRANSFORM( ::aMV[1]-::aMV[2],::aMV[9] ) )
      oRpt:nL += 2
      ::aMV[3] += ::aMV[1]
      ::aMV[4] += ::aMV[2]
      ::aMV[1] := ::aMV[2] := 0
      ::aMV[7] := aRes[5]
      ::aMV[8] := aRes[6]
   EndIf
EndDo
 oRpt:Say(  oRpt:nL, 79,"-----------------  -----------------" )
 oRpt:Say(++oRpt:nL, 07,"G R A N  T O T A L" )
 oRpt:Say(  oRpt:nL, 79,TRANSFORM( ::aMV[3],::aMV[9] ) )
 oRpt:Say(  oRpt:nL, 98,TRANSFORM( ::aMV[4],::aMV[9] ) )
 oRpt:Say(  oRpt:nL,116,TRANSFORM( ::aMV[3]-::aMV[4],::aMV[9] ) )
RETURN NIL

//------------------------------------//
METHOD Lineas() CLASS TCuadr
   LOCAL cLI := REPLICATE("-",20)
   LOCAL aMD, aRes, cQry, hRes, nL
aRes := MyReadRow( ::hRes )
AEval( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
::aMV[7] := aRes[5]
::aMV[8] := aRes[6]
While ::nL > 0
   If ::Descuadre( aRes[1] )
      cQry := "SELECT cuenta, valor_deb, valor_cre FROM cgemovd "+;
              "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND ano_mes = " + ::aLS[1]                 +;
               " AND control = " + LTRIM(STR( aRes[1] ))
      hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      nL   := MSNumRows( hRes )
      ::Cabecera( .t. )
      UTILPRN ::oUtil Self:nLinea,01.3 SAY TRANSFORM(aRes[1],"99")     RIGHT
      UTILPRN ::oUtil Self:nLinea,02.6 SAY TRANSFORM(aRes[3],"999999") RIGHT
      UTILPRN ::oUtil Self:nLinea,02.8 SAY NtChr( aRes[4],"2" )
      UTILPRN ::oUtil Self:nLinea,04.7 SAY aRes[2]
      ::nLinea -= .5
      While nL > 0
         aMD := MyReadRow( hRes )
         AEval( aMD, {| xV,nP | aMD[nP] := MyClReadCol( hRes,nP ) } )
         ::Cabecera( .t. )
         UTILPRN ::oUtil Self:nLinea,10.5 SAY aMD[1]
         UTILPRN ::oUtil Self:nLinea,14.8 SAY TRANSFORM( aMD[2],"@Z 9,999,999,999.99" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,17.4 SAY TRANSFORM( aMD[3],"@Z 9,999,999,999.99" ) RIGHT
         nL --
      EndDo
      MSFreeResult( hRes )
      ::Cabecera( .t. )
      UTILPRN ::oUtil Self:nLinea,14.8 SAY cLi  RIGHT
      UTILPRN ::oUtil Self:nLinea,17.4 SAY cLi  RIGHT
      ::nLinea += .5
      UTILPRN ::oUtil Self:nLinea,14.8 SAY TRANSFORM( ::aMV[5],::aMV[9] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,17.4 SAY TRANSFORM( ::aMV[6],::aMV[9] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM( ::aMV[5]-::aMV[6],::aMV[9] ) RIGHT
      ::nLinea += .5
   EndIf
   ::aMV[1] += ::aMV[5]
   ::aMV[2] += ::aMV[6]
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEval( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aMV[7] # aRes[5]
      ::Cabecera( .t. )
      UTILPRN ::oUtil Self:nLinea, 1.5 SAY "SUBTOTAL COMPROBANTE" + STR(::aMV[7],5) + "  " + ::aMV[8]
      UTILPRN ::oUtil Self:nLinea,14.8 SAY TRANSFORM( ::aMV[1],::aMV[9] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,17.4 SAY TRANSFORM( ::aMV[2],::aMV[9] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM( ::aMV[1]-::aMV[2],::aMV[9] ) RIGHT
//      ::nLinea += .5
      ::aMV[3] += ::aMV[1]
      ::aMV[4] += ::aMV[2]
      ::aMV[1] := ::aMV[2] := 0
      ::aMV[7] := aRes[5]
      ::aMV[8] := aRes[6]
   EndIf
EndDo
::Cabecera( .t.,,1 )
UTILPRN ::oUtil Self:nLinea,14.8 SAY cLi  RIGHT
UTILPRN ::oUtil Self:nLinea,17.4 SAY cLi  RIGHT
::nLinea += .5
UTILPRN ::oUtil Self:nLinea, 1.5 SAY "G R A N  T O T A L"
UTILPRN ::oUtil Self:nLinea,14.8 SAY TRANSFORM( ::aMV[3],::aMV[9] ) RIGHT
UTILPRN ::oUtil Self:nLinea,17.4 SAY TRANSFORM( ::aMV[4],::aMV[9] ) RIGHT
UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM( ::aMV[3]-::aMV[4],::aMV[9] ) RIGHT
RETURN NIL

//------------------------------------//
METHOD Cabecera( lSep,nSpace,nSuma ) CLASS TCuadr
If lSep .AND. !::aEnc[1]
   ::aEnc[1] := ::Separator( nSpace,nSuma )
EndIf
If ::aEnc[1]
   ::aEnc[1] := .F.
   ::Centrar( oApl:cEmpresa,::aFnt[4],1.0 )
   UTILPRN ::oUtil 1.5, 8.2 SAY "NIT: " + oApl:oEmp:Nit
   ::FechaHora( 1.5, 0.5, 16.4 )
   ::Centrar( ::aEnc[2],,2.0 )
   UTILPRN ::oUtil 2.0,16.5 SAY "PAGINA" + STR(::nPage,4 )
   ::Centrar( ::aEnc[3],,2.5 )
   If ::aLS[4] == 1
      UTILPRN ::oUtil 3.0, 1.3 SAY "TC"                RIGHT
      UTILPRN ::oUtil 3.0, 2.6 SAY "Docum."            RIGHT
      UTILPRN ::oUtil 3.0, 2.8 SAY "F e c h a"
      UTILPRN ::oUtil 3.0, 4.7 SAY "Descripcion"
      UTILPRN ::oUtil 3.0,10.5 SAY "Cuenta"
      UTILPRN ::oUtil 3.0,14.8 SAY "D E B I T O S"     RIGHT
      UTILPRN ::oUtil 3.0,17.4 SAY "C R E D I T O S"   RIGHT
      UTILPRN ::oUtil 3.0,20.0 SAY "D E S C U A D R E" RIGHT
   Else
      UTILPRN ::oUtil 3.0, 3.0 SAY "C O M P R O B A N T E"
      UTILPRN ::oUtil 3.0,13.0 SAY "DOCUMENTOS FALTANTES"
   EndIf
      UTILPRN ::oUtil LINEA 3.5,0.8 TO 3.5,20.0 PEN ::oPen
   ::nLinea := 3.5
EndIf
RETURN NIL

//------------------------------------//
METHOD Descuadre( nControl ) CLASS TCuadr
   LOCAL cQry, hRes, nReg := 0
cQry := "SELECT SUM(valor_deb), SUM(valor_cre) FROM cgemovd "+;
        "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND ano_mes = " + ::aLS[1]                 +;
         " AND control = " + LTRIM(STR( nControl ))
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
::aMV[5] := ::aMV[6] := 0
If MSNumRows( hRes ) > 0
   cQry := MyReadRow( hRes )
   AEVAL( cQry, {| xV,nP | cQry[nP] := MyClReadCol( hRes,nP ) } )
   ::aMV[5] := cQry[1] ; ::aMV[6] := cQry[2]
   nReg := ROUND( ::aMV[5] - ::aMV[6],2 )
EndIf
MSFreeResult( hRes )
RETURN (nReg != 0)

//------------------------------------//
METHOD ListoCTL( oRpt ) CLASS TCuadr
   LOCAL aRes
aRes := MyReadRow( ::hRes )
AEval( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
::aMV[5] := .t.
::aMV[8] := "Primer Documento Digitado : "
::aMV[9] := "Ultimo Documento Digitado : "
While ::nL > 0
   If ::aLS[2] == 1
      oRpt:Titulo( 78 )
      If ::aMV[5]
         ::aMV[1] := ::aMV[2] := ::aMV[3] := aRes[3] //COMPROBANT
         ::aMV[4] := aRes[1]
         ::aMV[5] := .f.
         oRpt:Say( oRpt:nL,10,STR(aRes[1],3) + "  " + aRes[2] )
      EndIf
      If ::aMV[1] < ::aMV[3]
         ::aMV[7] := If( ::aMV[3]-::aMV[1] > 1, " -"+STR( ::aMV[3]-1,7 ), "" )
         oRpt:Say( oRpt:nL,54,STR(::aMV[1]) + ::aMV[7] )
         oRpt:nL++
         ::aMV[1] := ::aMV[3]
      EndIf
   Else
      If ::aMV[5]
         ::aMV[1] := ::aMV[2] := ::aMV[3] := aRes[3]
         ::aMV[4] := aRes[1]
         ::aMV[5] := .f.
         ::Cabecera( .t. )
         UTILPRN ::oUtil Self:nLinea, 3.0 SAY STR(aRes[1],3) + "  " + aRes[2]
      EndIf
      If ::aMV[1] < ::aMV[3]
         ::aMV[7] := If( ::aMV[3]-::aMV[1] > 1, " -"+STR( ::aMV[3]-1,7 ), "" )
         ::Cabecera( .t. )
         UTILPRN ::oUtil Self:nLinea,14.0 SAY STR(::aMV[1]) + ::aMV[7]
         ::aMV[1] := ::aMV[3]
      EndIf
   EndIf
   ::aMV[1] ++
   ::aMV[3] := aRes[3]
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aMV[4] # aRes[1]
      If ::aLS[2] == 1
         oRpt:Say(++oRpt:nL,15,::aMV[8] + STR(::aMV[2]),,,1 )
         oRpt:Say(++oRpt:nL,15,::aMV[9] + STR(::aMV[3]),,,1 )
         oRpt:nL += 3
      Else
         ::Cabecera( .t.,,1 )
         UTILPRN ::oUtil Self:nLinea, 4.5 SAY ::aMV[8] + STR(::aMV[2])
         ::nLinea += .5
         UTILPRN ::oUtil Self:nLinea, 4.5 SAY ::aMV[9] + STR(::aMV[3])
         ::nLinea += .5
      EndIf
      ::aMV[5] := .t.
   EndIf
EndDo
RETURN NIL