// Programa.: INOLIEXT.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Movimento de un Codigo por Mes
#include "FiveWin.ch"
#include "Btnget.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE InoLiExt( aLS )
   LOCAL oAr, oDlg, oLF, oGet := ARRAY(8)
 oLF := TMovCod()
If aLS # NIL
   oLF:ListoExt( aLS )
   RETURN
EndIf
 oAr := TInv() ; oAr:New()
 aLS := { SPACE(12),NtChr( LEFT( DTOS(DATE()),6 ),"F" ),DATE(),oApl:nTFor,.t.,"" }
DEFINE DIALOG oDlg TITLE "Extracto de un Código" FROM 0, 0 TO 11,52
   @ 02,00 SAY "CODIGO DEL ARTICULO" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02,92 BTNGET oGet[1] VAR aLS[1] OF oDlg PICTURE "@!"         ;
      VALID EVAL( {|| If( oAr:oDb:Seek( {"codigo",aLS[1]} )      ,;
                ( oGet[6]:Settext( oAr:oDb:DESCRIP ), .t. )      ,;
                ( MsgStop("Este Código no Existe"),.f.)) } )      ;
      SIZE 58,10 PIXEL  RESOURCE "BUSCAR"                         ;
      ACTION EVAL({|| If(oAr:Mostrar(), (aLS[1] := oAr:oDb:CODIGO,;
                         oGet[1]:Refresh() ),) })
   @ 14, 40 SAY oGet[6] VAR aLS[6] OF oDlg PIXEL SIZE 120,10;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 26,00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 26,92 GET oGet[2] VAR aLS[2] OF oDlg  SIZE 40,10 PIXEL
   @ 38,00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 38,92 GET oGet[3] VAR aLS[3] OF oDlg ;
      VALID aLS[3] >= aLS[2] SIZE 40,10 PIXEL
   @ 50,00 SAY "TIPO DE IMPRESORA"    OF oDlg RIGHT PIXEL SIZE 90,10
   @ 50,92 COMBOBOX oGet[4] VAR aLS[4] ITEMS { "Matriz","Laser" };
      SIZE 40,90 OF oDlg PIXEL
   @ 50,150 CHECKBOX oGet[5] VAR aLS[5] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 64, 50 BUTTON oGet[7] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[7]:Disable(), oLF:ListoExt( aLS ), oGet[7]:Enable(),;
        oGet[7]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 64,100 BUTTON oGet[8] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 70, 02 SAY "[INOLIEXT]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
CLASS TMovCod FROM TIMPRIME

 DATA aLS, aEX

 METHOD ListoExt( aLS )
 METHOD LaserExt()
 METHOD Lineas( cTit,nX,nV,oRpt )
 METHOD Memo( cQry,hRes )
ENDCLASS

//------------------------------------//
METHOD ListoExt( aLS ) CLASS TMovCod
   LOCAL oRpt, nK := DAY(aLS[2])
::aEX    := { 0,0,0,0,0,0,0,0,0 }
  aLS[6] := NtChr( aLS[2] - nK,"1" )
::aEX[1] := ::aEX[7] := SaldoInv( aLS[1],aLS[6],1 )
  aLS[6] := NtChr( aLS[3],"1" )
::aEX[2] := SaldoInv( aLS[1],aLS[6],1 )
  aLS[6] := TRANSFORM( ::aEX[1],"99,999.99999" )
::aLS    := aLS
If aLS[4] == 2
   ::LaserExt()
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New(oApl:cPuerto,oApl:cImpres,{"MOVIMIENTO DEL CODIGO "+ aLS[1],;
         ALLTRIM(oApl:oInv:DESCRIP) + "  DESDE " +NtChr(aLS[2],"2") +;
         " HASTA " + NtChr(aLS[3],"2"),"    EXISTENCIA ANTERIOR " + aLS[6],;
         " ---FECHA-- No.DOCUMEN   CANTIDAD         P.VENDIDO"},aLS[5] )
 ::Lineas( "V E N T A S",1,-1,oRpt )

oRpt:aEnc[4] := STRTRAN( oRpt:aEnc[4],"VENDIDO","COSTO" )
 ::Lineas( "C O M P R A S",2,1,oRpt )
 ::Lineas( "A J U S T E S",3,0,oRpt )
If ::aEX[4] # 0 .OR. ::aEX[5] # 0
   oRpt:Separator( 0,3 )
   oRpt:Say( oRpt:nL++,05,REPLICATE("_",68) )
   oRpt:Say( oRpt:nL++,06,"AJUSTE POR FALTANTES" )
   oRpt:Say( oRpt:nL  ,24,TRANSFORM(::aEX[5],"99,999.99999") )
   oRpt:Say( oRpt:nL++,06,"AJUSTE POR SOBRANTES" )
   oRpt:Say( oRpt:nL  ,24,TRANSFORM(::aEX[4],"99,999.99999") )
EndIf
//::Lineas( "T R A S L A D O S",4,1,oRpt )
 ::Lineas( "DEVOLUCION A PROVEEDOR",5,-1,oRpt )
 ::Lineas( "DEVOLUCION DE CLIENTES",6,1,oRpt )

::aEX[7] += ::aEX[4] - ::aEX[5]

 oRpt:Titulo( 73,10 )
 oRpt:Say( oRpt:nL  ,05,REPLICATE("_",68),,,1 )
 oRpt:Say( oRpt:nL+1,06,"SALDO MATEMATICO" ,,,1 )
 oRpt:Say( oRpt:nL+1,24,TRANSFORM(::aEX[7],"99,999.99999") )
 oRpt:Say( oRpt:nL+2,06,"EXISTENCIA ACTUAL",,,1 )
 oRpt:Say( oRpt:nL+2,24,TRANSFORM(::aEX[2],"99,999.99999") )
 oRpt:NewPage()
 oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserExt() CLASS TMovCod
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit                  ,;
             "MOVIMIENTO DEL CODIGO " + ::aLS[1]                ,;
             ALLTRIM( oApl:oInv:DESCRIP ) + "  DESDE "          +;
             NtChr(::aLS[2],"2" )+" HASTA "+NtChr(::aLS[3],"2" ),;
             { .F., 0.8,"EXISTENCIA ANTERIOR","F E C H A" }     ,;
             { .F., 2.7,"","DOCUMENTO" },;
             { .T., 8.0,::aLS[6],"CANTIDAD" }, { .T.,10.7,"","P.VENDIDO" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[5] ,,, ::aLS[5] )
  PAGE
 ::Lineas( "V E N T A S",1,-1 )

 ::aEnc[9,4] := "P.COSTO"
 ::Lineas( "C O M P R A S",2,1 )
 ::Lineas( "A J U S T E S",3,0 )
If ::aEX[4] # 0 .OR. ::aEX[5] # 0
   ::Cabecera( .t.,0.40,1.34,20 )
   UTILPRN ::oUtil Self:nLinea, 1.0 SAY "AJUSTE POR FALTANTES"
   UTILPRN ::oUtil Self:nLinea, 7.9 SAY TRANSFORM( ::aEX[5],"99,999.99999" ) RIGHT
   ::nLinea += 0.42
   UTILPRN ::oUtil Self:nLinea, 1.0 SAY "AJUSTE POR SOBRANTES"
   UTILPRN ::oUtil Self:nLinea, 8.0 SAY TRANSFORM( ::aEX[4],"99,999.99999" ) RIGHT
EndIf
//::Lineas( "T R A S L A D O S",4,1 )
 ::Lineas( "DEVOLUCION A PROVEEDOR",5,-1 )
 ::Lineas( "DEVOLUCION DE CLIENTES",6,1 )

 ::aEX[7] += ::aEX[4] - ::aEX[5]
   ::Cabecera( .t.,0.40,1.34,20 )
   UTILPRN ::oUtil Self:nLinea, 1.0 SAY "SALDO MATEMATICO"
   UTILPRN ::oUtil Self:nLinea, 8.0 SAY TRANSFORM( ::aEX[7],"99,999.99999" ) RIGHT
   ::nLinea += 0.42
   UTILPRN ::oUtil Self:nLinea, 1.0 SAY "EXISTENCIA ACTUAL"
   UTILPRN ::oUtil Self:nLinea, 8.0 SAY TRANSFORM( ::aEX[2],"99,999.99999" ) RIGHT
  ENDPAGE
 ::EndInit( .F. )
RETURN NIL

//------------------------------------//
METHOD Lineas( cTit,nX,nV,oRpt ) CLASS TMovCod
   LOCAL aRes, hRes, nA, nL, bExt
hRes := ::Memo( ,nX )
If (nL := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   RETURN NIL
EndIf
If nX == 1
   //Ventas
   bExt := {|| oApl:oNit:Seek( {"codigo_nit",aRes[7]} ),;
               aRes[2] := STR(aRes[2],10) + aRes[6]    ,;
               ::aLS[6]:=  oApl:oNit:NOMBRE }
ElseIf nX == 3
   //Ajustes
   bExt := {|| ::aLS[6] := aRes[7], nA := If( aRes[6] == 5, 4, 5 ),;
               ::aEX[nA] += aRes[3] }
ElseIf nX == 4
   bExt := {|| aRes[2] := STR(aRes[2],6) + "-" + aRes[6], ::aLS[6] := "" }
ElseIf nX == 5
   //Devolución a Proveedor
   bExt := {|| ::aLS[6] := aRes[7] }
ElseIf nX == 6
   //Devolución de Clientes
   bExt := {|| ::aLS[6] := "Fac."+STR(aRes[6],7) }
Else
   bExt := {|| ::aLS[6] := "" }
EndIf
::aEX[8] := ::aEX[9] := 0

While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EVAL( bExt )
//      aF := UMedidas( aRes[5],"" )
   If ::aLS[4] == 1
      oRpt:Titulo( 73,10 )
      If ::aEX[8] == 0
         oRpt:Say( oRpt:nL+1,01,PADC( cTit,72,"=" ) )
         oRpt:nL += 2
      EndIf
      oRpt:Say( oRpt:nL,01,aRes[1] )
      oRpt:Say( oRpt:nL,12,aRes[2] )
      oRpt:Say( oRpt:nL,24,TRANSFORM(aRes[3], "99,999.99999") )
      oRpt:Say( oRpt:nL,37,aRes[5] )
      oRpt:Say( oRpt:nL,40,TRANSFORM(aRes[4],"999,999,999") )
      oRpt:Say( oRpt:nL,52,::aLS[6] )
      oRpt:nL++
   Else
      If ::aEX[8] == 0
         ::Cabecera( .t.,0.42 )
         UTILPRN ::oUtil Self:nLinea, 0.6 SAY PADC( cTit,72,"=" )
      EndIf
      ::Cabecera( .t.,0.42 )
      UTILPRN ::oUtil Self:nLinea, 0.5 SAY NtChr( aRes[1],"2" )
      UTILPRN ::oUtil Self:nLinea, 4.7 SAY aRes[2]                              RIGHT
      UTILPRN ::oUtil Self:nLinea, 8.0 SAY TRANSFORM( aRes[3], "99,999.99999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea, 8.2 SAY aRes[5]
      UTILPRN ::oUtil Self:nLinea,10.7 SAY TRANSFORM( aRes[4],"999,999,999" )   RIGHT
      UTILPRN ::oUtil Self:nLinea,10.9 SAY ::aLS[6]
   EndIf
   aRes[3] := AFormula( aRes[3],aRes[5],,oApl:oInv:CODCON )
   ::aEX[8] += aRes[3]
   ::aEX[9] += aRes[4] * If( nX == 1, 1, aRes[3] )
   nL --
EndDo
MSFreeResult( hRes )
If ::aEX[8] > 0 .AND. nV # 0
   aRes := { "TOTAL VENTA"          ,"TOTAL COMPRAS",;
             "TOTAL AJUSTES"        ,"ENTRADAS POR TRASLADO" ,;
             "DEVOLUCIONES A PROVEE","DEVOLUCION DE CLIENTES" }
   If ::aLS[4] == 1
      oRpt:Say( oRpt:nL++,01,REPLICATE("_",72) )
      oRpt:Say( oRpt:nL  ,05,aRes[nX] )
      oRpt:Say( oRpt:nL,  24,TRANSFORM( ::aEX[8], "99,999.99999") )
      oRpt:Say( oRpt:nL++,40,TRANSFORM( ::aEX[9],"999,999,999" ) )
   Else
      ::Cabecera( .t.,0.4,0.1,20 )
      UTILPRN ::oUtil Self:nLinea, 1.0 SAY aRes[nX]
      UTILPRN ::oUtil Self:nLinea, 8.0 SAY TRANSFORM( ::aEX[8], "99,999.99999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,10.7 SAY TRANSFORM( ::aEX[9],"999,999,999" )   RIGHT
   EndIf
   ::aEX[7] += ::aEX[8] * nV
EndIf
RETURN NIL

//------------------------------------//
METHOD Memo( cQry,hRes ) CLASS TMovCod
If hRes == 1
   cQry := "SELECT c.fechoy, c.numfac, d.cantidad, d.precio"+;
             "ven, d.unidadmed, c.tipo, c.codigo_nit "      +;
           "FROM cadfactd d, cadfactc c "                   +;
           "WHERE d.codigo  = " + xValToChar( ::aLS[1] )    +;
            " AND c.empresa = d.empresa"                    +;
            " AND c.numfac  = d.numfac"                     +;
            " AND c.tipo    = d.tipo "                      +;
            " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
            " AND c.fechoy >= " + xValToChar( ::aLS[2] )    +;
            " AND c.fechoy <= " + xValToChar( ::aLS[3] )    +;
            " AND c.tipo   <> 'Z' AND c.indicador <> 'A'"
ElseIf hRes == 2
   cQry := "SELECT c.fecingre, c.ingreso, d.cantidad, d.pcosto, d.unidadmed "+;
           "FROM cadartid d, cadartic c "                  +;
           "WHERE d.codigo  = "   + xValToChar( ::aLS[1] ) +;
            " AND c.ingreso = d.ingreso"                   +;
            " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND c.fecingre >= " + xValToChar( ::aLS[2] ) +;
            " AND c.fecingre <= " + xValToChar( ::aLS[3] )
       //" AND d.indica <> 'B'"
ElseIf hRes == 3
   cQry := "SELECT a.fecha, a.numero, a.cantidad, a.pcosto"+;
                ", a.unidadmed, t.tipo_ajust, t.nombre "   +;
           "FROM cadtipos t, cadajust a "                  +;
           "WHERE t.clase   = 'Ajustes'"                   +;
            " AND a.tipo    = t.tipo"                      +;
            " AND a.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND a.fecha  >= " + xValToChar( ::aLS[2] )   +;
            " AND a.fecha  <= " + xValToChar( ::aLS[3] )   +;
            " AND a.codigo  = " + xValToChar( ::aLS[1] )   +;
            " ORDER BY a.fecha"
ElseIf hRes == 5
   cQry := "SELECT c.fecha, c.numero, d.cantidad, d.pcosto,"+;
                     " d.unidadmed, t.tipo_ajust, t.nombre "+;
           "FROM cadtipos t, caddevod d, caddevoc c "       +;
           "WHERE t.clase   = 'Devolucion'"                 +;
            " AND t.tipo    = d.causadev"                   +;
            " AND d.codigo  = " + xValToChar( ::aLS[1] )    +;
            " AND c.empresa = d.empresa"                    +;
            " AND c.numero  = d.numero"                     +;
            " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
            " AND c.fecha  >= " + xValToChar( ::aLS[2] )    +;
            " AND c.fecha  <= " + xValToChar( ::aLS[3] )
ElseIf hRes == 6
   cQry := "SELECT c.fecha, CONCAT('N.C.',c.numero), "     +;
             "d.cantidad, d.pcosto, d.unidadmed, c.numfac "+;
           "FROM cadnotad d, cadnotac c "                  +;
           "WHERE d.codigo  = " + xValToChar( ::aLS[1] )   +;
            " AND c.empresa = d.empresa"                   +;
            " AND c.numero  = d.numero"                    +;
            " AND c.tipo    = d.tipo"                      +;
            " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND c.fecha  >= " + xValToChar( ::aLS[2] )   +;
            " AND c.fecha  <= " + xValToChar( ::aLS[3] )   +;
            " AND c.tipo    = " + xValToChar(oApl:Tipo)
EndIf
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
RETURN hRes