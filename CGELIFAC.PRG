// Programa.: CGELIFAC.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Libro Auxiliar de Facturacion
#include "Fivewin.ch"
#include "btnget.ch"
#INCLUDE "Utilprn.CH"

MEMVAR oApl

PROCEDURE Caolifac()
   LOCAL oDlg, oGet := ARRAY(8), oA, oNi
 oA := TLifac() ;  oA:New()
oNi := TNits()  ; oNi:New()
DEFINE DIALOG oDlg TITLE oA:aEnc[2] FROM 0, 0 TO 11,60
   @ 02,00 SAY "NIT INICIAL" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 02,62 BTNGET oGet[1] VAR oA:aLS[1] OF oDlg PICTURE "9999999999" ;
      VALID EVAL( {|| If( EMPTY( oA:aLS[1] ), .t.                   ,;
              (If( oNi:oDb:Seek( { "codigo",oA:aLS[1] } )           ,;
              ( oA:aLS[6] := oNi:oDb:NOMBRE, oDlg:Update(), .t. )   ,;
              ( MsgStop("Este Nit no Existe"),.f.)))) } )            ;
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"                            ;
      ACTION EVAL({|| If(oNi:Mostrar(), (oA:aLS[1] := oNi:oDb:CODIGO,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
   @ 02,120 SAY oA:aLS[6] OF oDlg PIXEL SIZE 160,10 UPDATE COLOR nRGB( 128,0,255 )
   @ 14,00 SAY "PERIODO INICIAL"  OF oDlg RIGHT PIXEL SIZE 60,10
   @ 14,62 GET oGet[2] VAR oA:aLS[2] OF oDlg PICTURE "999999" SIZE 32,10 PIXEL;
      VALID NtChr( oA:aLS[2],"P" )
   @ 26,00 SAY "PERIODO   FINAL"  OF oDlg RIGHT PIXEL SIZE 60,10
   @ 26,62 GET oGet[3] VAR oA:aLS[3] OF oDlg PICTURE "999999" SIZE 32,10 PIXEL;
      VALID NtChr( oA:aLS[3],"P" )
   @ 38,00 SAY "TIPO DE IMPRESORA"   OF oDlg RIGHT PIXEL SIZE 60,10
   @ 38,62 COMBOBOX oGet[4] VAR oA:aLS[4] ITEMS { "Matriz","Laser" };
      SIZE 48,90 OF oDlg PIXEL
   @ 38,136 CHECKBOX oGet[5] VAR oA:aLS[5] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,10 PIXEL
   @ 50,00 SAY "Escoja la Fuente"  OF oDlg RIGHT PIXEL SIZE 60,10
   @ 50,62 COMBOBOX oGet[6] VAR oA:cFont ITEMS oA:aFont SIZE 80,99 OF oDlg PIXEL;
      WHEN oA:aLS[4] > 1
   @ 64,106 BUTTON oGet[7] PROMPT "Aceptar"  SIZE 40,12 OF oDlg ACTION;
      ( oGet[7]:Disable(), oA:ArmarMOV( oDlg ), oDlg:End() ) PIXEL
   @ 64,150 BUTTON oGet[8] PROMPT "Cancelar" SIZE 40,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 70, 02 SAY "[CGELIFAC]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT ( Empresa( .t. ) )
RETURN

//------------------------------------//
CLASS TLifac FROM TIMPRIME

 DATA aCT, aGT, aLS, aMV, aRS, hRes, nL

 METHOD NEW() Constructor
 METHOD ArmarMOV( oDlg )
 METHOD ListoDOS( oDlg )
 METHOD Lineas( nI )
 METHOD Cabecera( lSep,nSpace )
 METHOD Totales( nI )
ENDCLASS

//------------------------------------//
METHOD NEW() CLASS TLifac
   LOCAL cPer := NtChr( DATE(),"1" )
   LOCAL hDC := GetDC( 0 )
 ::aFont:= GetFontNames( hDC )
 ::aLS  := { 0,cPer,cPer,oApl:nTFor,.f.,"","#,###,###,###",0,"" }
 ::aMV  := ARRAY(2,7)
 ::aEnc := { .t.,"LISTADO DE FACTURACION","","" }
 ::cFont:= "Arial"
RETURN NIL

//------------------------------------//
METHOD ArmarMOV( oDlg ) CLASS TLifac
   LOCAL aV
oDlg:SetText( "POR FAVOR << ESPERE >>" )
::aLS[2] := NtChr( ::aLS[2],"F" )
::aLS[3] := NtChr( ::aLS[3],"F" )
::aLS[3] := CTOD( NtChr( ::aLS[3],"4" ) )
aV   := "SELECT c.numfac, c.indicador, n.nombre, 0, c.totaliva, c.totalfac"+;
             ", c.seradmon, c.totaldes, 0, c.fecha, c.piva "               +;
        "FROM cgefactc c LEFT JOIN cadclien n "         +;
         "USING( codigo_nit ) "                         +;
        "WHERE c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fecha  >= " + xValToChar( ::aLS[2] )   +;
         " AND c.fecha  <= " + xValToChar( ::aLS[3] )   + If( ::aLS[1] > 0,;
         " AND c.codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT)), "" ) +;
         " ORDER BY c.numfac"
::hRes := If( MSQuery( oApl:oMySql:hConnect,aV ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes ) ; RETURN NIL
EndIf
 ::aEnc[3]:= "PERIODO DE : " + NtChr( ::aLS[2],"6" ) + " A " + NtChr( ::aLS[3],"6" )
 AEVAL( ::aMV,{|x| AFILL( x,0 ) } )
::aLS[2] := "SELECT SUM( d.valor_deb ) "                       +;
            "FROM cgemovc c LEFT JOIN cgemovd d "              +;
             "USING( empresa, ano_mes, control ) "             +;
            "WHERE c.empresa    = " + LTRIM(STR(oApl:nEmpresa))+;
             " AND c.ano_mes    = '[P]'"                       +;
             " AND c.fuente     = 6"                           +;
             " AND c.comprobant = [C]"                         +;
             " AND c.estado    <> 2"                           +;
             " AND d.cuenta     = " + If( oApl:nEmpresa == 10, "'16751002'", "'13551801'" )
::aGT    := { {16,0} }
::aLS[9] := If( oApl:nEmpresa == 11, "IMPOCONSUMO", "  TOTAL IVA" )
If ::aLS[4] == 1
   ::ListoDOS( oDlg )
Else
   ::Init( ::aEnc[2], .f. ,, !::aLS[5] ,,,, 5 )
     PAGE
       ::Lineas()
     ENDPAGE
   IMPRIME END .F.
EndIf
MSFreeResult( ::hRes )
RETURN NIL

//------------------------------------//
METHOD ListoDOS( oDlg ) CLASS TLifac
   LOCAL nI, oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[2],::aEnc[3],::aLS[6],;
         "   FACTURA EMPRESA                    SUBTOTAL    " + ::aLS[9] +;
         "  TOTAL FACTURA      VALOR 10%       DESC 30%        AIU  7%         I.C.A."},::aLS[5],,2 )
// FACTURA EMPRESA                    SUBTOTAL      TOTAL-IVA  TOTAL FACTURA      VALOR 10%       DESC 30%        AIU  7%         I.C.A.
//34567890 12345678901234567890  #,###,###,###  #,###,###,###  #,###,###,###  #,###,###,###  #,###,###,###  #,###,###,###  #,###,###,###
While ::nL > 0
   ::Totales()
      oRpt:Titulo( 136 )
      oRpt:Say( oRpt:nL, 00,TRANSFORM(::aRS[1],"9999999999") )
      oRpt:Say( oRpt:nL, 11,     LEFT(::aRS[3],20) )
   If ::aRS[2] # "A"
      oRpt:Say( oRpt:nL, 33,TRANSFORM(::aRS[04],::aLS[7]) )
      oRpt:Say( oRpt:nL, 48,TRANSFORM(::aRS[05],::aLS[7]) )
      oRpt:Say( oRpt:nL, 63,TRANSFORM(::aRS[06],::aLS[7]) )
      oRpt:Say( oRpt:nL, 78,TRANSFORM(::aRS[07],::aLS[7]) )
      oRpt:Say( oRpt:nL, 93,TRANSFORM(::aRS[08],::aLS[7]) )
      oRpt:Say( oRpt:nL,108,TRANSFORM(::aRS[09],::aLS[7]) )
      oRpt:Say( oRpt:nL,123,TRANSFORM(::aRS[10],::aLS[7]) )
   EndIf
      oRpt:nL ++
EndDo
 oRpt:Separator( 0,3 )
 oRpt:Say(  oRpt:nL, 00,REPLICATE("_",136) )
 oRpt:Say(++oRpt:nL, 01,"TOTALES" )
 oRpt:Say(  oRpt:nL, 33,TRANSFORM(::aMV[1,1],::aLS[7]) )
 oRpt:Say(  oRpt:nL, 48,TRANSFORM(::aMV[1,2],::aLS[7]) )
 oRpt:Say(  oRpt:nL, 63,TRANSFORM(::aMV[1,3],::aLS[7]) )
 oRpt:Say(  oRpt:nL, 78,TRANSFORM(::aMV[1,4],::aLS[7]) )
 oRpt:Say(  oRpt:nL, 93,TRANSFORM(::aMV[1,5],::aLS[7]) )
 oRpt:Say(  oRpt:nL,108,TRANSFORM(::aMV[1,6],::aLS[7]) )
 oRpt:Say(  oRpt:nL,123,TRANSFORM(::aMV[1,7],::aLS[7]) )
If ::aMV[1,2] > 0
   ASORT( ::aGT,,, { |x,y| x[1] < y[1] } )
   oRpt:nL ++
   oRpt:Separator( 0,LEN( ::aGT )+2 )
   oRpt:Say(++oRpt:nL, 39,"DESGLOSE DEL IVA" )
   FOR nI := 1 TO LEN( ::aGT )
      If ::aGT[nI,1] > 0
         oRpt:Say(++oRpt:nL,39,TRANSFORM(::aGT[nI,1],"999.99%") )
         oRpt:Say(  oRpt:nL,48,TRANSFORM(::aGT[nI,2],::aLS[7] ) )
      EndIf
   NEXT
EndIf
 oRpt:NewPage()
 oRpt:End()
RETURN NIL

//------------------------------------//
METHOD Lineas( nI ) CLASS TLifac

While ::nL > 0
   ::Totales()
      ::Cabecera( .t. )
      UTILPRN ::oUtil Self:nLinea, 1.8 SAY TRANSFORM(::aRS[1],"9999999999")  RIGHT
      UTILPRN ::oUtil Self:nLinea, 2.0 SAY      LEFT(::aRS[3],20)
   If ::aRS[2] # "A"
      UTILPRN ::oUtil Self:nLinea, 7.4 SAY TRANSFORM(::aRS[04],::aLS[7]) RIGHT
      UTILPRN ::oUtil Self:nLinea, 9.6 SAY TRANSFORM(::aRS[05],::aLS[7]) RIGHT
      UTILPRN ::oUtil Self:nLinea,11.8 SAY TRANSFORM(::aRS[06],::aLS[7]) RIGHT
      UTILPRN ::oUtil Self:nLinea,14.0 SAY TRANSFORM(::aRS[07],::aLS[7]) RIGHT
      UTILPRN ::oUtil Self:nLinea,16.2 SAY TRANSFORM(::aRS[08],::aLS[7]) RIGHT
      UTILPRN ::oUtil Self:nLinea,18.4 SAY TRANSFORM(::aRS[09],::aLS[7]) RIGHT
      UTILPRN ::oUtil Self:nLinea,20.6 SAY TRANSFORM(::aRS[10],::aLS[7]) RIGHT
   EndIf
EndDo
 ::Cabecera( .t.,0.5,1.5 )
 UTILPRN ::oUtil LINEA Self:nLinea,1.0 TO Self:nLinea,20.6 PEN ::oPen
 ::nLinea += 0.5
 UTILPRN ::oUtil Self:nLinea, 1.0 SAY "TOTALES"
 UTILPRN ::oUtil Self:nLinea, 7.4 SAY TRANSFORM(::aMV[1,1],::aLS[7]) RIGHT
 UTILPRN ::oUtil Self:nLinea, 9.6 SAY TRANSFORM(::aMV[1,2],::aLS[7]) RIGHT
 UTILPRN ::oUtil Self:nLinea,11.8 SAY TRANSFORM(::aMV[1,3],::aLS[7]) RIGHT
 UTILPRN ::oUtil Self:nLinea,14.0 SAY TRANSFORM(::aMV[1,4],::aLS[7]) RIGHT
 UTILPRN ::oUtil Self:nLinea,16.2 SAY TRANSFORM(::aMV[1,5],::aLS[7]) RIGHT
 UTILPRN ::oUtil Self:nLinea,18.4 SAY TRANSFORM(::aMV[1,6],::aLS[7]) RIGHT
 UTILPRN ::oUtil Self:nLinea,20.6 SAY TRANSFORM(::aMV[1,7],::aLS[7]) RIGHT
If ::aMV[1,2] > 0
   ASORT( ::aGT,,, { |x,y| x[1] < y[1] } )
   nI := ( LEN( ::aGT )+1 ) / 2
   ::Cabecera( .t.,0.8,nI )
   UTILPRN ::oUtil Self:nLinea, 6.5 SAY "DESGLOSE DEL IVA"
   FOR nI := 1 TO LEN( ::aGT )
      If ::aGT[nI,1] > 0
         ::nLinea += 0.5
         UTILPRN ::oUtil Self:nLinea, 7.4 SAY TRANSFORM(::aGT[nI,1],"999.99%") RIGHT
         UTILPRN ::oUtil Self:nLinea, 9.6 SAY TRANSFORM(::aGT[nI,2],::aLS[7]) RIGHT
      EndIf
   NEXT
EndIf
RETURN NIL

//------------------------------------//
METHOD Cabecera( lSep,nSpace,nSuma ) CLASS TLifac
If lSep .AND. !::aEnc[1]
   ::aEnc[1] := ::Separator( nSpace )
EndIf
If ::aEnc[1]
   ::aEnc[1] := .F.
   ::Centrar( oApl:cEmpresa,::aFnt[4],1.0 )
   UTILPRN ::oUtil 1.5, 8.2 SAY "NIT: " + oApl:oEmp:Nit
   ::Centrar( ::aEnc[2],,2.0 )
   UTILPRN ::oUtil 2.0,16.5 SAY "PAGINA" + STR(::nPage,4 )
   ::Centrar( ::aEnc[3],,2.5 )
   UTILPRN ::oUtil 3.0, 1.0 SAY ::aLS[6]
   UTILPRN ::oUtil 3.5, 1.8 SAY "FACTURA"   RIGHT
   UTILPRN ::oUtil 3.5, 2.0 SAY "EMPRESA"
   UTILPRN ::oUtil 3.5, 7.4 SAY "SUBTOTAL"  RIGHT
   UTILPRN ::oUtil 3.5, 9.6 SAY ::aLS[9]    RIGHT
   UTILPRN ::oUtil 3.5,11.8 SAY "TOTAL-FAC" RIGHT
   UTILPRN ::oUtil 3.5,14.0 SAY "VALOR 10%" RIGHT
   UTILPRN ::oUtil 3.5,16.2 SAY "DESC 30%"  RIGHT
   UTILPRN ::oUtil 3.5,18.4 SAY "AIU  7%"   RIGHT
   UTILPRN ::oUtil 3.5,20.6 SAY "I.C.A."    RIGHT
   UTILPRN ::oUtil LINEA 4.0,1.0 TO 4.0,20.6 PEN ::oPen
   ::nLinea := 4.5
EndIf
RETURN NIL

//------------------------------------//
METHOD Totales( nI ) CLASS TLifac
       ::aRS := MyReadRow( ::hRes )
AEVAL( ::aRS, {|xV,nP| ::aRS[nP] := MyClReadCol( ::hRes,nP ) } )
   ::aLS[8] := ::aRS[1]
If ::aRS[2] == "A"
   ::aRS[3] := ">>> ANULADA <<<"
Else
   ::aLS[3] := STRTRAN( ::aLS[2],"[P]",NtChr( ::aRS[10],"1" ) )
      ::aRS[4] := ::aRS[6] - ::aRS[5]
   If ::aRS[8] > 0
      ::aRS[9] := ::aRS[7] - ::aRS[8]
   EndIf
   ::aRS[10] := Buscar( STRTRAN( ::aLS[3],"[C]",LTRIM( STR(::aRS[1]) ) ),"CM",,8 )
   ::aMV[1,1]+= ::aRS[04]
   ::aMV[1,2]+= ::aRS[05]
   ::aMV[1,3]+= ::aRS[06]
   ::aMV[1,4]+= ::aRS[07]
   ::aMV[1,5]+= ::aRS[08]
   ::aMV[1,6]+= ::aRS[09]
   ::aMV[1,7]+= ::aRS[10]
   If (nI := ASCAN( ::aGT,{ |aX| aX[1] == ::aRS[11] } )) == 0
      AADD( ::aGT,{ ::aRS[11],0 } )
      nI := LEN( ::aGT )
   EndIf
   ::aGT[nI,2] += ::aRS[05]
EndIf
   ::nL --
RETURN NIL
/*
//------------------------------------//
METHOD ArmarMOV( oDlg ) CLASS TLifac
   LOCAL aV
oDlg:SetText( "POR FAVOR << ESPERE >>" )
aV   := "SELECT c.comprobant, c.fecha, d.cuenta,  "     +;
        "d.valor_deb, d.valor_cre, d.codigo_nit, c.estado "+;
        "FROM cgemovc c LEFT JOIN cgemovd d "           +;
         "USING( empresa, ano_mes, control ) "          +;
        "WHERE c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fuente  = 6"                           +;
         " AND c.ano_mes >= " + xValToChar( ::aLS[2] )  +;
         " AND c.ano_mes <= " + xValToChar( ::aLS[3] )  +;
         " ORDER BY c.comprobant"
//         " AND c.Estado <> 2"         + If( ::aLS[1] > 0,;
//         " AND c.Codigonit = "+ LTRIM(STR(oApl:oNit:CODIGO_NIT)), "" )+;
::hRes := If( MSQuery( oApl:oMySql:hConnect,aV ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes ) ; RETURN NIL
EndIf
If oApl:nPuc == 10
  ::aCT := { "16059501  ","16750502  ","16752001  ",;
             "16753001  ","25100101  ","16751002  ","25100104  " }
Else
  ::aCT := { "13050501  ","13551501  ","13551701  ",;
             "13551801  ","24080101  ","13551801  ","24080101  " }
EndIf
 aV    := { NtChr( ::aLS[2],"F" ),NtChr( ::aLS[3],"F" ) }
 ::aEnc[3]:= "PERIODO DE : " + NtChr( aV[1],"6" ) + " A " + NtChr( aV[2],"6" )
 ::aRS := MyReadRow( ::hRes )
 AEVAL( ::aRS,{|xV,nP| ::aRS[nP] := MyClReadCol( ::hRes,nP ) } )
 AEVAL( ::aMV,{|x| AFILL( x,0 ) } )
 ::aLS[8] := ::aRS[1]
If ::aLS[4] == 1
   ::ListoDOS( oDlg )
Else
   ::Init( ::aEnc[2], .f. ,, !::aLS[5] ,,,, 5 )
     PAGE
       ::Lineas()
     ENDPAGE
   IMPRIME END .F.
EndIf
MSFreeResult( ::hRes )
RETURN NIL

//------------------------------------//
METHOD ListoDOS( oDlg ) CLASS TLifac
   LOCAL oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[2],::aEnc[3],::aLS[6],;
          "   FACTURA        SUBOTOTAL           I.V.A.    TOTAL FACTURA"+;
          "        RETENCION     IVA RETENIDO           I.C.A.    TOTAL A PAGAR"},::aLS[5],,2 )
While ::nL > 0
   If ::Totales()
      oRpt:Titulo( 130 )
      oRpt:Say( oRpt:nL, 00,TRANSFORM(::aLS[8],"9999999999") )
      If EMPTY( ::aEnc[4] )
         oRpt:Say( oRpt:nL, 11,TRANSFORM(::aMV[1,1],::aLS[7]) )
         oRpt:Say( oRpt:nL, 28,TRANSFORM(::aMV[1,2],::aLS[7]) )
         oRpt:Say( oRpt:nL, 45,TRANSFORM(::aMV[1,3],::aLS[7]) )
         oRpt:Say( oRpt:nL, 62,TRANSFORM(::aMV[1,4],::aLS[7]) )
         oRpt:Say( oRpt:nL, 79,TRANSFORM(::aMV[1,5],::aLS[7]) )
         oRpt:Say( oRpt:nL, 96,TRANSFORM(::aMV[1,6],::aLS[7]) )
         oRpt:Say( oRpt:nL,113,TRANSFORM(::aMV[1,7],::aLS[7]) )
      Else
         oRpt:Say( oRpt:nL, 12,::aEnc[4] )
      EndIf
      oRpt:nL ++
   EndIf
   ::aLS[8] := ::aRS[1]
EndDo
 oRpt:Separator( 0,3 )
 oRpt:Say(  oRpt:nL, 00,REPLICATE("_",130) )
 oRpt:Say(++oRpt:nL, 01,"TOTALES" )
 oRpt:Say(  oRpt:nL, 11,TRANSFORM(::aMV[2,1],::aLS[7]) )
 oRpt:Say(  oRpt:nL, 28,TRANSFORM(::aMV[2,2],::aLS[7]) )
 oRpt:Say(  oRpt:nL, 45,TRANSFORM(::aMV[2,3],::aLS[7]) )
 oRpt:Say(  oRpt:nL, 62,TRANSFORM(::aMV[2,4],::aLS[7]) )
 oRpt:Say(  oRpt:nL, 79,TRANSFORM(::aMV[2,5],::aLS[7]) )
 oRpt:Say(  oRpt:nL, 96,TRANSFORM(::aMV[2,6],::aLS[7]) )
 oRpt:Say(  oRpt:nL,113,TRANSFORM(::aMV[2,7],::aLS[7]) )
 oRpt:NewPage()
 oRpt:End()
RETURN NIL

//------------------------------------//
METHOD Lineas() CLASS TLifac

While ::nL > 0
   If ::Totales()
      ::Cabecera( .t. )
      UTILPRN ::oUtil Self:nLinea, 1.8 SAY TRANSFORM(::aLS[8],"9999999999")  RIGHT
      If EMPTY( ::aEnc[4] )
         UTILPRN ::oUtil Self:nLinea, 5.0 SAY TRANSFORM(::aMV[1,1],::aLS[7]) RIGHT
         UTILPRN ::oUtil Self:nLinea, 7.5 SAY TRANSFORM(::aMV[1,2],::aLS[7]) RIGHT
         UTILPRN ::oUtil Self:nLinea,10.0 SAY TRANSFORM(::aMV[1,3],::aLS[7]) RIGHT
         UTILPRN ::oUtil Self:nLinea,12.5 SAY TRANSFORM(::aMV[1,4],::aLS[7]) RIGHT
         UTILPRN ::oUtil Self:nLinea,15.0 SAY TRANSFORM(::aMV[1,5],::aLS[7]) RIGHT
         UTILPRN ::oUtil Self:nLinea,17.5 SAY TRANSFORM(::aMV[1,6],::aLS[7]) RIGHT
         UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM(::aMV[1,7],::aLS[7]) RIGHT
      Else
         UTILPRN ::oUtil Self:nLinea, 5.0 SAY ::aEnc[4]
      EndIf
   EndIf
   ::aLS[8] := ::aRS[1]
EndDo
 ::Cabecera( .t.,0.5,1.5 )
 UTILPRN ::oUtil LINEA Self:nLinea,1.0 TO Self:nLinea,20.0 PEN ::oPen
 ::nLinea += 0.5
 UTILPRN ::oUtil Self:nLinea, 1.0 SAY "TOTALES"
 UTILPRN ::oUtil Self:nLinea, 5.0 SAY TRANSFORM(::aMV[2,1],::aLS[7]) RIGHT
 UTILPRN ::oUtil Self:nLinea, 7.5 SAY TRANSFORM(::aMV[2,2],::aLS[7]) RIGHT
 UTILPRN ::oUtil Self:nLinea,10.0 SAY TRANSFORM(::aMV[2,3],::aLS[7]) RIGHT
 UTILPRN ::oUtil Self:nLinea,12.5 SAY TRANSFORM(::aMV[2,4],::aLS[7]) RIGHT
 UTILPRN ::oUtil Self:nLinea,15.0 SAY TRANSFORM(::aMV[2,5],::aLS[7]) RIGHT
 UTILPRN ::oUtil Self:nLinea,17.5 SAY TRANSFORM(::aMV[2,6],::aLS[7]) RIGHT
 UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM(::aMV[2,7],::aLS[7]) RIGHT
RETURN NIL

//------------------------------------//
METHOD Cabecera( lSep,nSpace,nSuma ) CLASS TLifac
If lSep .AND. !::aEnc[1]
   ::aEnc[1] := ::Separator( nSpace )
EndIf
If ::aEnc[1]
   ::aEnc[1] := .F.
   ::Centrar( oApl:cEmpresa,::aFnt[4],1.0 )
   UTILPRN ::oUtil 1.5, 8.2 SAY "NIT: " + oApl:oEmp:Nit
   ::Centrar( ::aEnc[2],,2.0 )
   UTILPRN ::oUtil 2.0,16.5 SAY "PAGINA" + STR(::nPage,4 )
   ::Centrar( ::aEnc[3],,2.5 )
   UTILPRN ::oUtil 3.0, 1.0 SAY ::aLS[6]
   UTILPRN ::oUtil 3.5, 1.8 SAY "FACTURA"        RIGHT
   UTILPRN ::oUtil 3.5, 5.0 SAY "SUBOTOTAL"      RIGHT
   UTILPRN ::oUtil 3.5, 7.5 SAY "I.V.A."         RIGHT
   UTILPRN ::oUtil 3.5,10.0 SAY "TOTAL FACTURA"  RIGHT
   UTILPRN ::oUtil 3.5,12.5 SAY "RETENCION"      RIGHT
   UTILPRN ::oUtil 3.5,15.0 SAY "IVA RETENIDO"   RIGHT
   UTILPRN ::oUtil 3.5,17.5 SAY "I.C.A."         RIGHT
   UTILPRN ::oUtil 3.5,20.0 SAY "TOTAL A PAGAR"  RIGHT
   UTILPRN ::oUtil LINEA 4.0,1.0 TO 4.0,20.0 PEN ::oPen
   ::nLinea := 4.5
EndIf
RETURN NIL

//------------------------------------//
METHOD Totales() CLASS TLifac
   LOCAL nC, lOK := .t.
 AEVAL( ::aMV,{|x| AFILL( x,0 ) },1,1 )
 ::aEnc[4] := If( ::aRS[7] == 2, "ANULADO", "" )
While ::nL > 0
   If ::aRS[7]  # 2
      If ::aRS[3] ==    ::aCT[1]
         ::aMV[1,7] += ::aRS[4]       //Cartera
         If ::aLS[1] > 0 .AND. ::aRS[6] # oApl:oNit:CODIGO_NIT
            lOK := .f.
         EndIf
      ElseIf ::aRS[3] == ::aCT[2]
         ::aMV[1,4] += ::aRS[4]       //Retencion
      ElseIf ::aRS[3] == ::aCT[3]
         ::aMV[1,5] += ::aRS[4]       //IVA Retencion
      ElseIf ::aRS[3] == ::aCT[4] .OR. ::aRS[3] == ::aCT[6]
         ::aMV[1,6] += ::aRS[4]       //ICA
      ElseIf ::aRS[3] == ::aCT[5] .OR. ::aRS[3] == ::aCT[7]
         ::aMV[1,2] += ::aRS[5]       //IVA
      EndIf
   EndIf
   If (::nL --) > 1
      ::aRS := MyReadRow( ::hRes )
      AEval( ::aRS, {|xV,nP| ::aRS[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aLS[8] # ::aRS[1]
      If lOK
         ::aMV[1,3] := ::aMV[1,4] + ::aMV[1,5] + ::aMV[1,6] + ::aMV[1,7]
         ::aMV[1,1] := ::aMV[1,3] - ::aMV[1,2]
         FOR nC := 1 TO 7
            ::aMV[2,nC] += ::aMV[1,nC]
         NEXT nC
      EndIf
      EXIT
   EndIf
EndDo
RETURN lOK*/