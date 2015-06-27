// Programa.: INOLIRSM.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Lista Inventario mensual por grupo
#include "FiveWin.ch"
#include "Btnget.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE InoLiRsm( lResu )
   LOCAL aRep, bLV, oCg, oIM, oVt, oDlg, oGet := ARRAY(13)
   DEFAULT lResu := .f.
If lResu
   aRep := { {|| oIM:ListoRsm() },"Resumen del Inventario" }
Else
   aRep := { {|| oIM:ListoInv() },"Inventario Mensual" }
EndIf
 oIM := TRinve()
 oCg := TCat() ; oCg:New()
 oVt := TRip() ; oVt:New( 8 )
 bLV := {|| oIM:aLS[5] := ALLTRIM( oIM:aLS[5] )                                  ,;
            oIM:aLS[5] := If( EMPTY( oIM:aLS[5] ), "", " AND LEFT(s.codigo,"     +;
                        STR( LEN( oIM:aLS[5] ),1 ) + ") = '" + oIM:aLS[5] + "'" ),;
            oIM:aLS[7] := If( EMPTY( oIM:aLS[7] ), "", "i.vitrina = '" + oIM:aLS[7] + "' AND " ) }
DEFINE DIALOG oDlg TITLE aRep[2] FROM 0, 0 TO 18,50
   @ 02, 00 SAY "DIGITE EL PERIODO" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02, 92 GET oGet[1] VAR oIM:aLS[1] OF oDlg PICTURE "999999";
      VALID NtChr( oIM:aLS[1],"P" )    SIZE 30,10 PIXEL
   @ 14, 00 SAY "ORDENADO POR"      OF oDlg RIGHT PIXEL SIZE 90,10
   @ 14, 92 COMBOBOX oGet[2] VAR oIM:aLS[2] ITEMS { "Codigo","Nombre" } ;
      SIZE 50,99 OF oDlg PIXEL
   @ 26, 00 SAY "RECUPERA PAGINA DESDE LA" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 26, 92 GET oGet[3] VAR oIM:aLS[3] OF oDlg PICTURE "###";
      VALID Rango( oIM:aLS[3],1,999 )  SIZE 20,10 PIXEL
   @ 38, 00 SAY "RESUMEN [N/S/R]"   OF oDlg RIGHT PIXEL SIZE 90,10
   @ 38, 92 GET oGet[4] VAR oIM:aLS[4] OF oDlg PICTURE "!";
      VALID oIM:aLS[4] $ "NSR"         SIZE 08,10 PIXEL
   @ 50, 00 SAY "LINEA por Default TODAS" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 50, 92 BTNGET oGet[5] VAR oIM:aLS[5] OF oDlg PICTURE "!!9"      ;
      VALID EVAL( {|| If( EMPTY( oIM:aLS[5] ), .t.                  ,;
                    ( If( oCg:oDb:Seek( {"linea",oIM:aLS[5]} )      ,;
                        ( oGet[6]:Settext( oCg:oDb:NOMBRE), .t. )   ,;
                   (MsgStop("Está Linea no Existe"), .f.) ) )) } )   ;
      SIZE 36,10 PIXEL RESOURCE "BUSCAR"                             ;
      ACTION EVAL({|| If(oCg:Mostrar(), (oIM:aLS[5] := oCg:oDb:LINEA,;
                         oGet[5]:Refresh() ),) })
   @ 62, 10 SAY oGet[6] VAR oIM:aLS[6] OF oDlg PIXEL SIZE 150,18 COLOR nRGB( 128,0,255 )
   @ 80, 00 SAY "VITRINA por Default TODAS" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 80, 92 BTNGET oGet[7] VAR oIM:aLS[7] OF oDlg PICTURE "!!9999"    ;
      ACTION EVAL({|| If(oVt:Mostrar(), (oIM:aLS[7] := oVt:oDb:CODIGO,;
                         oGet[7]:Refresh() ),) })                     ;
      VALID EVAL( {|| If( EMPTY( oIM:aLS[7] ), .t.                   ,;
                    ( If( oVt:oDb:Seek( {"codigo",oIM:aLS[7]} )      ,;
                        ( oGet[8]:Settext( oVt:oDb:NOMBRE), .t. ) ,;
                  (MsgStop("Está Vitrina no Existe"), .f.) ) )) } );
      SIZE 36,10 PIXEL RESOURCE "BUSCAR"
   @  92, 10 SAY oGet[8] VAR oIM:aLS[8] OF oDlg PIXEL SIZE 130,10 COLOR nRGB( 128,0,255 )
   @ 104, 00 SAY "TIPO DE IMPRESORA"   OF oDlg RIGHT PIXEL SIZE 90,10
   @ 104, 92 COMBOBOX oGet[09] VAR oIM:aLS[9] ITEMS { "Matriz","Laser" };
      SIZE 48,90 OF oDlg PIXEL
   @ 104,140 CHECKBOX oGet[10] VAR oIM:aLS[10] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 118, 50 BUTTON oGet[11] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[11]:Disable(), EVAL( bLV ),;
        EVAL( aRep[1] )   , oDlg:End() ) PIXEL
   @ 118,100 BUTTON oGet[12] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 118,150 BUTTON oGet[13] PROMPT "Stock M." SIZE 44,12 OF oDlg ACTION;
      ( oGet[13]:Disable() , EVAL( bLV ),;
        oIM:StockMin(), oDlg:End() ) PIXEL
   @ 124, 02 SAY "[INOLIRSM]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
 oCg:oDb:Destroy()
 oVt:oDb:Destroy()
RETURN

//------------------------------------//
CLASS TRinve FROM TIMPRIME

 DATA aLS  AS ARRAY INIT { NtChr( DATE(),"1" ),1,1,"N","   ","","     ","",oApl:nTFor,.t. }

 METHOD ListoInv()
 METHOD LaserInv( nL,hRes )
 METHOD ListoRsm()
 METHOD LaserRsm( nL,hRes )
 METHOD StockMin()
 METHOD LaserMin( nL,hRes )
 METHOD Resumen()
 METHOD Query( nH,aGT )
ENDCLASS

//------------------------------------//
METHOD ListoInv() CLASS TRinve
   LOCAL aGT, aRes, cQry, hRes, nL, oRpt
If ::aLS[4] == "R"
   ::Resumen( ::aLS )
   RETURN NIL
EndIf
cQry := "SELECT s.codigo, i.descrip, i.ppubli, s.existencia, s.pcosto "+;
        "FROM cadinven i, cadinvme s "                            +;
        "WHERE " + ::aLS[7]                                       +;
              "s.codigo  = i.codigo"                              +;
         " AND s.empresa = " + LTRIM(STR(oApl:nEmpresa)) + ::aLS[5] +;
         " AND s.anomes  = (SELECT MAX(m.anomes) FROM cadinvme m "  +;
                           "WHERE m.empresa = s.empresa"            +;
                            " AND m.codigo  = s.codigo"             +;
                            " AND m.anomes <= '" + ::aLS[1] + "')"  +;
         " AND s.existencia <> 0"                                   +;
         " ORDER BY " + If( ::aLS[2] == 1, "s.codigo", "i.descrip" )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( cQry,"NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[9] == 2
   ::LaserInv( nL,hRes )
   RETURN NIL
EndIf
aGT  := { 0,0,0 }
cQry := NtChr( ::aLS[1],"F" )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"RESUMEN DEL MOVIMIENTO DEL INVENTARIO","EN " + ;
         NtChr( cQry,"6" ),SPACE(58) + "PRECIO       S A L D O       PRECIO       T O T A L",;
         "CODIGO---- D E S C R I P C I O N-------------------      PUBLICO     A C T U A L    C O"+;
         " S T O       C O S T O"},::aLS[10],::aLS[3],2,,,106 )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aGT[3] := aRes[4] * aRes[5]
   aGT[1] += aRes[4]
   aGT[2] +=  aGT[3]
   If ::aLS[4] == "N"
      oRpt:Titulo( 109 )
      If oRpt:nPage >= oRpt:nPagI
         oRpt:Say( oRpt:nL,00,aRes[1] )
         oRpt:Say( oRpt:nL,11,aRes[2] )
         oRpt:Say( oRpt:nL,52,TRANSFORM(aRes[3],  "9,999,999.99") )
         oRpt:Say( oRpt:nL,67,TRANSFORM(aRes[4],    "999,999.99999") )
         oRpt:Say( oRpt:nL,83,TRANSFORM(aRes[5],    "999,999.99") )
         oRpt:Say( oRpt:nL,95,TRANSFORM( aGT[3],"999,999,999.99") )
      EndIf
      oRpt:nL ++
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
   oRpt:Say( oRpt:nL++,00,REPLICATE("=",109),,,1 )
   oRpt:Say( oRpt:nL  ,10,"  T O T A L E S ======>" )
   oRpt:Say( oRpt:nL  ,63,TRANSFORM(aGT[1],"999,999,999.99999" ) )
   oRpt:Say( oRpt:nL  ,95,TRANSFORM(aGT[2],"999,999,999.99" ) )
   oRpt:NewPage()
   oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserInv( nL,hRes ) CLASS TRinve
   LOCAL aGT := { 0,0,0 }, aRes
aRes := NtChr( ::aLS[1],"F" )
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit      ,;
             "RESUMEN DEL MOVIMIENTO DEL INVENTARIO",;
             "EN " + NtChr( aRes,"6" )              ,;
             { .F., 0.5,"CODIGO----" }    , { .F., 2.6,"D E S C R I P C I O N" },;
             { .T.,13.0,"PRECIO PUBLICO" }, { .T.,15.5,"SALDO ACTUAL" },;
             { .T.,18.0,"PRECIO COSTO" }  , { .T.,20.5,"TOTAL COSTO" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[10] ,,, ::aLS[10], 5 )
 ::nMD := 20.5
 PAGE
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aGT[3] := aRes[4] * aRes[5]
   aGT[1] += aRes[4]
   aGT[2] +=  aGT[3]
   If ::aLS[4] == "N"
      ::Cabecera( .t.,0.42 )
//      If oRpt:nPage >= oRpt:nPagI
         UTILPRN ::oUtil Self:nLinea, 0.5 SAY aRes[1]
         UTILPRN ::oUtil Self:nLinea, 2.6 SAY aRes[2]
         UTILPRN ::oUtil Self:nLinea,13.0 SAY TRANSFORM(aRes[3],  "9,999,999.99")    RIGHT
         UTILPRN ::oUtil Self:nLinea,15.5 SAY TRANSFORM(aRes[4],    "999,999.99999") RIGHT
         UTILPRN ::oUtil Self:nLinea,18.0 SAY TRANSFORM(aRes[5],    "999,999.99")    RIGHT
         UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aGT[3],"999,999,999.99")    RIGHT
//      EndIf
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
   ::Cabecera( .t.,0.3,0.6,20.5 )
   UTILPRN ::oUtil Self:nLinea, 2.6 SAY "  T O T A L E S ======>"
   UTILPRN ::oUtil Self:nLinea,15.5 SAY TRANSFORM( aGT[1],"999,999,999.99999") RIGHT
   UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aGT[2],"999,999,999.99")    RIGHT
 ENDPAGE
 ::EndInit( .F. )
RETURN NIL

//------------------------------------//
METHOD ListoRsm() CLASS TRinve
   LOCAL oRpt, aGT, cPer, nC, nK
   LOCAL aRes, hRes, nL, cQry, aTI := ARRAY(2,9)
cQry := "SELECT s.codigo, i.descrip, s.entradas, s.salidas, s.devol_e, s.devol_s, "+;
        "s.ajustes_e, s.ajustes_s, s.devolcli, s.existencia, s.pcosto, s.anomes "  +;
        "FROM cadinven i, cadinvme s "                              +;
        "WHERE " + ::aLS[7]                                         +;
              "s.codigo  = i.codigo"                                +;
         " AND s.empresa = " + LTRIM(STR(oApl:nEmpresa)) + ::aLS[5] +;
         " AND s.anomes  = (SELECT MAX(m.anomes) FROM cadinvme m "  +;
                           "WHERE m.empresa = s.empresa"            +;
                            " AND m.codigo  = s.codigo"             +;
                            " AND m.anomes <= '" + ::aLS[1] + "')"  +;
         " ORDER BY " + If( ::aLS[2] == 1, "s.codigo", "i.descrip" )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( cQry,"NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[9] == 2
   ::LaserInv( nL,hRes )
   RETURN NIL
EndIf
AEVAL( aTI, { |x| AFILL( x,0 ) } )
cQry := NtChr( ::aLS[1],"F" )
cPer := NtChr( cQry-1,"1" )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"RESUMEN DEL MOVIMIENTO DEL INVENTARIO" ,;
         "EN " + NtChr(cQry,"6" ),SPACE(49) + "SALDO     TOTAL      TOTAL   "+;
         "DEVOLUCI  DEVOLUCI   AJUSTE     AJUSTE  DEVOLUCI    SALDO"         ,;
         "CODIGO---- D E S C R I P C I O N--------------  ANTERIOR  ENTRADAS"+;
         "    VENTAS  ENTRADAS   SALIDAS  ENTRADAS   SALIDAS   CLIENTE    ACTUAL"},;
         ::aLS[10],::aLS[3],2,,,136 )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aRes[12] == ::aLS[1]
      aGT := { 0,aRes[03],aRes[04],aRes[05],aRes[06],aRes[07],aRes[08],;
                 aRes[09],aRes[10],aRes[11],0 }
      aGT[01] := SaldoInv( aRes[01],cPer,1 )
      aGT[11] := oApl:aInvme[2]  // Pcosto Anterior
   Else
      aGT := { aRes[10],0,0,0,0,0,0,0,aRes[10],aRes[11],aRes[11] }
   EndIf
   nK := 0
   AEVAL( aGT, { | nV,nP | nC := If( nP # 1, 10, 11 ),;
                           If( nV # 0, nK ++, )      ,;
                           aTI[1][nP] +=  nV         ,;
                           aTI[2][nP] += (nV * aGT[nC]) },1,9 )
   If nK > 0
      If ::aLS[4] == "N"
         oRpt:Titulo( 136 )
         If oRpt:nPage >= oRpt:nPagI
            oRpt:Say( oRpt:nL, 00,aRes[1] )
            oRpt:Say( oRpt:nL, 11,aRes[2],35 )
            oRpt:Say( oRpt:nL, 48,TRANSFORM(aGT[1],   "99,999.9") )
            oRpt:Say( oRpt:nL, 58,TRANSFORM(aGT[2],"@Z 99,999.9") )
            oRpt:Say( oRpt:nL, 68,TRANSFORM(aGT[3],"@Z 99,999.9") )
            oRpt:Say( oRpt:nL, 78,TRANSFORM(aGT[4],"@Z 99,999.9") )
            oRpt:Say( oRpt:nL, 88,TRANSFORM(aGT[5],"@Z 99,999.9") )
            oRpt:Say( oRpt:nL, 98,TRANSFORM(aGT[6],"@Z 99,999.9") )
            oRpt:Say( oRpt:nL,108,TRANSFORM(aGT[7],"@Z 99,999.9") )
            oRpt:Say( oRpt:nL,118,TRANSFORM(aGT[8],"@Z 99,999.9") )
            oRpt:Say( oRpt:nL,128,TRANSFORM(aGT[9],   "99,999.9") )
         EndIf
         oRpt:nL ++
      EndIf
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
   cPer := "999,999.9" ; cQry := "999,999,999.9"
   oRpt:Say( oRpt:nL, 00,REPLICATE("_",136),,,1 )
   oRpt:Separator( 1,8 )
   oRpt:SetFont( oRpt:CPINormal,80,2 )
   oRpt:Say(  oRpt:nL, 10,"  Saldo Anterior " + TRANSFORM(aTI[1,1],cPer) )
   oRpt:Say(  oRpt:nL, 42,TRANSFORM(aTI[2,1],cQry) )
   oRpt:Say(++oRpt:nL, 10,"Entradas del Mes " + TRANSFORM(aTI[1,2],cPer) )
   oRpt:Say(  oRpt:nL, 42,TRANSFORM(aTI[2,2],cQry) )
   oRpt:Say(++oRpt:nL, 10," Ventas  del Mes " + TRANSFORM(aTI[1,3],cPer) )
   oRpt:Say(  oRpt:nL, 42,TRANSFORM(aTI[2,3],cQry) )
   oRpt:Say(++oRpt:nL, 10,"Devolu. Entradas " + TRANSFORM(aTI[1,4],cPer) )
   oRpt:Say(  oRpt:nL, 42,TRANSFORM(aTI[2,4],cQry) )
   oRpt:Say(++oRpt:nL, 10,"Devolu.  Salidas " + TRANSFORM(aTI[1,5],cPer) )
   oRpt:Say(  oRpt:nL, 42,TRANSFORM(aTI[2,5],cQry) )
   oRpt:Say(++oRpt:nL, 10,"Ajuste  Entradas " + TRANSFORM(aTI[1,6],cPer) )
   oRpt:Say(  oRpt:nL, 42,TRANSFORM(aTI[2,6],cQry) )
   oRpt:Say(++oRpt:nL, 10,"Ajuste   Salidas " + TRANSFORM(aTI[1,7],cPer) )
   oRpt:Say(  oRpt:nL, 42,TRANSFORM(aTI[2,7],cQry) )
   oRpt:Say(++oRpt:nL, 10,"Devolu. Clientes " + TRANSFORM(aTI[1,8],cPer) )
   oRpt:Say(  oRpt:nL, 42,TRANSFORM(aTI[2,8],cQry) )
   oRpt:Say(++oRpt:nL, 10,"  Saldo  Actual  " + TRANSFORM(aTI[1,9],cPer) )
   oRpt:Say(  oRpt:nL, 42,TRANSFORM(aTI[2,9],cQry) )
   oRpt:NewPage()
   oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserRsm( nL,hRes ) CLASS TRinve
   LOCAL aGT, cPer, nC, nK
   LOCAL aRes, aTI := ARRAY(2,9)
AEVAL( aTI, { |x| AFILL( x,0 ) } )
aRes := NtChr( ::aLS[1],"F" )
cPer := NtChr( aRes-1,"1" )
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit      ,;
             "RESUMEN DEL MOVIMIENTO DEL INVENTARIO",;
             "EN " + NtChr( aRes,"6" )              ,;
             { .F., 0.5,"CODIGO----" }    , { .F., 2.6,"D E S C R I P C I O N" },;
             { .F.,10.7,"PRECIO PUBLICO" }, { .F.,13.4,"SALDO ACTUAL" },;
             { .F.,15.9,"PRECIO COSTO" }  , { .F.,18.5,"TOTAL COSTO" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[10] ,,, ::aLS[10], 5 )
 ::nMD := 20.5
 PAGE
/*
         SPACE(49) + "SALDO     TOTAL      TOTAL   "+;
         "DEVOLUCI  DEVOLUCI   AJUSTE     AJUSTE  DEVOLUCI    SALDO"         ,;
         "CODIGO---- D E S C R I P C I O N--------------  ANTERIOR  ENTRADAS"+;
         "    VENTAS  ENTRADAS   SALIDAS  ENTRADAS   SALIDAS   CLIENTE    ACTUAL"},;
*/
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aRes[12] == ::aLS[1]
      aGT := { 0,aRes[03],aRes[04],aRes[05],aRes[06],aRes[07],aRes[08],;
                 aRes[09],aRes[10],aRes[11],0 }
      aGT[01] := SaldoInv( aRes[01],cPer,1 )
      aGT[11] := oApl:aInvme[2]  // Pcosto Anterior
   Else
      aGT := { aRes[10],0,0,0,0,0,0,0,aRes[10],aRes[11],aRes[11] }
   EndIf
   nK := 0
   AEVAL( aGT, { | nV,nP | nC := If( nP # 1, 10, 11 ),;
                           If( nV # 0, nK ++, )      ,;
                           aTI[1][nP] +=  nV         ,;
                           aTI[2][nP] += (nV * aGT[nC]) },1,9 )
   If nK > 0
      If ::aLS[4] == "N"
         ::Cabecera( .t.,0.42 )
//      If oRpt:nPage >= oRpt:nPagI
         UTILPRN ::oUtil Self:nLinea, 0.5 SAY aRes[1]
         UTILPRN ::oUtil Self:nLinea, 2.6 SAY LEFT(aRes[2],35)
         UTILPRN ::oUtil Self:nLinea,13.0 SAY TRANSFORM(aGT[1],   "99,999.9") RIGHT
         UTILPRN ::oUtil Self:nLinea,13.0 SAY TRANSFORM(aGT[2],"@Z 99,999.9") RIGHT
         UTILPRN ::oUtil Self:nLinea,13.0 SAY TRANSFORM(aGT[3],"@Z 99,999.9") RIGHT
         UTILPRN ::oUtil Self:nLinea,13.0 SAY TRANSFORM(aGT[4],"@Z 99,999.9") RIGHT
         UTILPRN ::oUtil Self:nLinea,13.0 SAY TRANSFORM(aGT[5],"@Z 99,999.9") RIGHT

         UTILPRN ::oUtil Self:nLinea,13.0 SAY TRANSFORM(aGT[6],"@Z 99,999.9") RIGHT
         UTILPRN ::oUtil Self:nLinea,15.5 SAY TRANSFORM(aGT[7],"@Z 99,999.9") RIGHT
         UTILPRN ::oUtil Self:nLinea,18.0 SAY TRANSFORM(aGT[8],"@Z 99,999.9") RIGHT
         UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM(aGT[9],   "99,999.9") RIGHT
//      EndIf
      EndIf
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
   cPer := "999,999.9" ; aRes := "999,999,999.9"
   ::Cabecera( .t.,0.3,5.1,20.5 )
   UTILPRN ::oUtil SELECT ::aFnt[ 2 ]
   UTILPRN ::oUtil Self:nLinea, 2.6 SAY "  Saldo Anterior "
   UTILPRN ::oUtil Self:nLinea, 8.5 SAY TRANSFORM( aTI[1,1],cPer ) RIGHT
   UTILPRN ::oUtil Self:nLinea,12.5 SAY TRANSFORM( aTI[2,1],aRes ) RIGHT
   ::nLinea += 0.5
   UTILPRN ::oUtil Self:nLinea, 2.6 SAY "Entradas del Mes "
   UTILPRN ::oUtil Self:nLinea, 8.5 SAY TRANSFORM( aTI[1,2],cPer ) RIGHT
   UTILPRN ::oUtil Self:nLinea,12.5 SAY TRANSFORM( aTI[2,2],aRes ) RIGHT
   ::nLinea += 0.5
   UTILPRN ::oUtil Self:nLinea, 2.6 SAY " Ventas  del Mes "
   UTILPRN ::oUtil Self:nLinea, 8.5 SAY TRANSFORM( aTI[1,3],cPer ) RIGHT
   UTILPRN ::oUtil Self:nLinea,12.5 SAY TRANSFORM( aTI[2,3],aRes ) RIGHT
   ::nLinea += 0.5
   UTILPRN ::oUtil Self:nLinea, 2.6 SAY "Devolu. Entradas "
   UTILPRN ::oUtil Self:nLinea, 8.5 SAY TRANSFORM( aTI[1,4],cPer ) RIGHT
   UTILPRN ::oUtil Self:nLinea,12.5 SAY TRANSFORM( aTI[2,4],aRes ) RIGHT
   ::nLinea += 0.5
   UTILPRN ::oUtil Self:nLinea, 2.6 SAY "Devolu.  Salidas "
   UTILPRN ::oUtil Self:nLinea, 8.5 SAY TRANSFORM( aTI[1,5],cPer ) RIGHT
   UTILPRN ::oUtil Self:nLinea,12.5 SAY TRANSFORM( aTI[2,5],aRes ) RIGHT
   ::nLinea += 0.5
   UTILPRN ::oUtil Self:nLinea, 2.6 SAY "Ajuste  Entradas "
   UTILPRN ::oUtil Self:nLinea, 8.5 SAY TRANSFORM( aTI[1,6],cPer ) RIGHT
   UTILPRN ::oUtil Self:nLinea,12.5 SAY TRANSFORM( aTI[2,6],aRes ) RIGHT
   ::nLinea += 0.5
   UTILPRN ::oUtil Self:nLinea, 2.6 SAY "Ajuste   Salidas "
   UTILPRN ::oUtil Self:nLinea, 8.5 SAY TRANSFORM( aTI[1,7],cPer ) RIGHT
   UTILPRN ::oUtil Self:nLinea,12.5 SAY TRANSFORM( aTI[2,7],aRes ) RIGHT
   ::nLinea += 0.5
   UTILPRN ::oUtil Self:nLinea, 2.6 SAY "Devolu. Clientes "
   UTILPRN ::oUtil Self:nLinea, 8.5 SAY TRANSFORM( aTI[1,8],cPer ) RIGHT
   UTILPRN ::oUtil Self:nLinea,12.5 SAY TRANSFORM( aTI[2,8],aRes ) RIGHT
   ::nLinea += 0.5
   UTILPRN ::oUtil Self:nLinea, 2.6 SAY "  Saldo  Actual  "
   UTILPRN ::oUtil Self:nLinea, 8.5 SAY TRANSFORM( aTI[1,9],cPer ) RIGHT
   UTILPRN ::oUtil Self:nLinea,12.5 SAY TRANSFORM( aTI[2,9],aRes ) RIGHT
 ENDPAGE
 ::EndInit( .F. )
RETURN NIL

//------------------------------------//
METHOD StockMin() CLASS TRinve
   LOCAL aGT, aRes, cQry, hRes, nL, oRpt
cQry := "SELECT s.codigo, i.descrip, i.stockm, s.existencia, s.pcosto "+;
        "FROM cadinven i, cadinvme s "                              +;
        "WHERE s.codigo  = i.codigo"                                +;
         " AND s.empresa = " + LTRIM(STR(oApl:nEmpresa)) + ::aLS[5] +;
         " AND s.anomes  = (SELECT MAX(m.anomes) FROM cadinvme m "  +;
                           "WHERE m.empresa = s.empresa"            +;
                            " AND m.codigo  = s.codigo"             +;
                            " AND m.anomes <= '" + ::aLS[1] + "')"  +;
         " AND s.existencia <= i.stockm"                            +;
         " ORDER BY " + If( ::aLS[2] == 1, "s.codigo", "i.descrip" )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( cQry,"NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[9] == 2
   ::LaserMin( nL,hRes )
   RETURN NIL
EndIf
 aGT := { 0,0,0 }
cQry := NtChr( ::aLS[1],"F" )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"RESUMEN DEL MOVIMIENTO DEL INVENTARIO","EN " +;
         NtChr( cQry,"6" ),SPACE(58) + " STOCK       S A L D O       PRECIO       T O T A L",;
         "CODIGO---- D E S C R I P C I O N-------------------       MINIMO     A C T U A L    C O"+;
         " S T O       C O S T O"},::aLS[10],::aLS[3],2,,,106 )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aGT[3] := aRes[4] * aRes[5]
   aGT[1] += aRes[4]
   aGT[2] +=  aGT[3]
      oRpt:Titulo( 109 )
   If oRpt:nPage >= oRpt:nPagI
      oRpt:Say( oRpt:nL,00,aRes[1] )
      oRpt:Say( oRpt:nL,11,aRes[2] )
      oRpt:Say( oRpt:nL,53,TRANSFORM(aRes[3],"999,999,999") )
      oRpt:Say( oRpt:nL,67,TRANSFORM(aRes[4],    "999,999.99999") )
      oRpt:Say( oRpt:nL,83,TRANSFORM(aRes[5],    "999,999.99") )
      oRpt:Say( oRpt:nL,95,TRANSFORM( aGT[3],"999,999,999.99") )
   EndIf
      oRpt:nL ++
   nL --
EndDo
MSFreeResult( hRes )
 oRpt:Say( oRpt:nL++,00,REPLICATE("=",109),,,1 )
 oRpt:Say( oRpt:nL  ,10,"  T O T A L E S ======>" )
 oRpt:Say( oRpt:nL  ,63,TRANSFORM(aGT[1],"999,999,999.99999" ) )
 oRpt:Say( oRpt:nL  ,95,TRANSFORM(aGT[2],"999,999,999.99" ) )
 oRpt:NewPage()
 oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserMin( nL,hRes ) CLASS TRinve
   LOCAL aGT, aRes
 aGT := { 0,0,0 }
aRes := NtChr( ::aLS[1],"F" )
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit      ,;
             "RESUMEN DEL MOVIMIENTO DEL INVENTARIO",;
             "EN " + NtChr( aRes,"6" )              ,;
             { .F., 0.5,"CODIGO----" }  , { .F., 2.6,"D E S C R I P C I O N" },;
             { .T.,13.0,"STOCK MINIMO" }, { .T.,15.5,"SALDO ACTUAL" },;
             { .T.,18.0,"PRECIO COSTO" }, { .T.,20.5,"TOTAL COSTO" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[10] ,,, ::aLS[10], 5 )
 ::nMD := 20.5
 PAGE
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aGT[3] := aRes[4] * aRes[5]
   aGT[1] += aRes[4]
   aGT[2] +=  aGT[3]
      ::Cabecera( .t.,0.42 )
// If oRpt:nPage >= oRpt:nPagI
      UTILPRN ::oUtil Self:nLinea, 0.5 SAY aRes[1]
      UTILPRN ::oUtil Self:nLinea, 2.6 SAY aRes[2]
      UTILPRN ::oUtil Self:nLinea,13.0 SAY TRANSFORM(aRes[3],"999,999,999")       RIGHT
      UTILPRN ::oUtil Self:nLinea,15.5 SAY TRANSFORM(aRes[4],    "999,999.99999") RIGHT
      UTILPRN ::oUtil Self:nLinea,18.0 SAY TRANSFORM(aRes[5],    "999,999.99")    RIGHT
      UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aGT[3],"999,999,999.99")    RIGHT
// EndIf
   nL --
EndDo
MSFreeResult( hRes )
   ::Cabecera( .t.,0.3,0.6,20.5 )
   UTILPRN ::oUtil Self:nLinea, 2.6 SAY "  T O T A L E S ======>"
   UTILPRN ::oUtil Self:nLinea,15.5 SAY TRANSFORM( aGT[1],"999,999,999.99999") RIGHT
   UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aGT[2],"999,999,999.99")    RIGHT
 ENDPAGE
 ::EndInit( .F. )
RETURN NIL

//------------------------------------//
METHOD Resumen() CLASS TRinve
   LOCAL aRes, cQry, hRes, nC, nL, nF, oRpt
   LOCAL aRS := ARRAY(10,4), aGT := { NtChr( ::aLS[1],"F" ),0,0,"",::aLS[1] }
AEVAL( aRS, { |x| AFILL( x,0 ) } )
//If ::aLS[3]
//   Todo el Año
//   aGT[1] := CTOD( "01.01."+LEFT(::aLS[1],4) )
//   aGT[2] := CTOD( "31.12."+LEFT(::aLS[1],4) )
//   aGT[5] := LEFT(::aLS[1],4) + "12"
//   ::aLS[1] := LEFT(::aLS[1],4) + "01"
//Else
   aGT[2] := CTOD( NtChr( aGT[1],"4" ) )
//EndIf
   aGT[3] := NtChr( aGT[1]-1,"1" )
// Saldos de Inventario
hRes := ::Query( 1 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      aRS[9,1] +=  aRes[2]
      aRS[9,2] += (aRes[2] * aRes[3])
   If aRes[4] == ::aLS[1]
      aRS[2,3] +=  aRes[5]
      aRS[2,4] += (aRes[3] * aRes[05])
      aRS[3,3] +=  aRes[6]
      aRS[3,4] += (aRes[3] * aRes[06])
      aRS[4,3] +=  aRes[7]
      aRS[4,4] += (aRes[3] * aRes[07])
      aRS[5,3] +=  aRes[8]
      aRS[5,4] += (aRes[3] * aRes[08])
      aRS[6,3] +=  aRes[9]
      aRS[6,4] += (aRes[3] * aRes[09])
      aRS[7,3] +=  aRes[10]
      aRS[7,4] += (aRes[3] * aRes[10])
      aRS[8,3] +=  aRes[11]
      aRS[8,4] += (aRes[3] * aRes[11])
      aRes[2]  := SaldoInv( aRes[1],aGT[3],1 )
      aRes[3]  := oApl:aInvme[2]
   EndIf
      aRS[1,1] +=  aRes[2]
      aRS[1,2] += (aRes[2] * aRes[3])
      nL --
EndDo
MSFreeResult( hRes )

hRes := ::Query( 2,aGT )     // 2_Compras
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[1] := AFormula( aRes[1],aRes[2],aRes[4],aRes[5] )
   aRS[2,1] +=  aRes[1]
   aRS[2,2] += (aRes[1] * aRes[3])
   nL --
EndDo
MSFreeResult( hRes )

hRes := ::Query( 5,aGT )     // 5_Ventas
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[1] := AFormula( aRes[1],aRes[2],aRes[4],aRes[5] )
   aRS[5,1] +=  aRes[1]
   aRS[5,2] += (aRes[1] * aRes[3])
   nL --
EndDo
MSFreeResult( hRes )

hRes := ::Query( 4,aGT )     // 4_Devolucion de Clientes
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[1] := AFormula( aRes[1],aRes[2],aRes[4],aRes[5] )
   aRS[4,1] +=  aRes[1]
   aRS[4,2] += (aRes[1] * aRes[3])
   nL --
EndDo
MSFreeResult( hRes )

hRes := ::Query( 3,aGT )     // 3,6_Devoluciones
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[1] := AFormula( aRes[1],aRes[2],aRes[4],aRes[5] )
   nF  := If( aRes[6] == 4, 6, 3 )
   aRS[nF,1] +=  aRes[1]
   aRS[nF,2] += (aRes[1] * aRes[3])
   nL --
EndDo
MSFreeResult( hRes )

hRes := ::Query( 6,aGT )     // 3,6_Devoluciones
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[1] := AFormula( aRes[1],aRes[2],aRes[4],aRes[5] )
   nF  := If( aRes[6] == 5, 7, 8 )
   aRS[nF,1] +=  aRes[1]
   aRS[nF,2] += (aRes[1] * aRes[3])
   nL --
EndDo
MSFreeResult( hRes )

aRes := {5,6,8}
FOR nL := 1 TO LEN( aRes )
  nF := aRes[nL]
  AEVAL( aRS[nF], { |xV,nP| aRS[nF,nP] := xV *-1 } )
NEXT nL
aRes := { "Saldo Anterior           ","C o m p r a s  del Mes   ",;
          "Traslados de Bodega      ","Devolucion de Clientes   ",;
          "Ventas del Mes           ","Devoluciones y Traslados ",;
          "Ajustes de Entradas      ","Ajustes de Salidas       ",;
          "Saldo  Actual            " }
aGT[4] := NtChr( aGT[2],"3" )
If ::aLS[9] == 1
   oRpt := TDosPrint()
   oRpt:New( oApl:cPuerto,oApl:cImpres,{"MOVIMIENTO A",aGT[4]},::aLS[10] )
   oRpt:Titulo( 70 )
   oRpt:Say( 08,31,"C A N T I D A D      PRECIO COSTO" )
   oRpt:nL := 10
   aGT  := { 0,0,0,0 }
   FOR nF := 1 TO 8
      oRpt:Say( oRpt:nL,01,aRes[nF] )
      oRpt:Say( oRpt:nL,31,TRANSFORM(aRS[nF,1],  "9,999,999.99999") )
      oRpt:Say( oRpt:nL,50,TRANSFORM(aRS[nF,2],"999,999,999.99") )
      oRpt:nL += 3
      aRS[10,1] += aRS[nF,1]
      aRS[10,2] += aRS[nF,2]
   NEXT nF
      aGT[1]  := aRS[09,1] - aRS[10,1]
      aGT[2]  := aRS[09,2] - aRS[10,2]
   oRpt:Say( 33,30,"================   ===============" )
   oRpt:Say( 34,01,aRes[9] )
   oRpt:Say( 34,31,TRANSFORM(aRS[09,1],  "9,999,999.99999") )
   oRpt:Say( 34,50,TRANSFORM(aRS[09,2],"999,999,999.99") )
   oRpt:Say( 35,20,"SUMAS " )
   oRpt:Say( 35,31,TRANSFORM(aRS[10,1],  "9,999,999.99999") )
   oRpt:Say( 35,50,TRANSFORM(aRS[10,2],"999,999,999.99") )
   oRpt:Say( 36,20,"DIFER " )
   oRpt:Say( 36,31,TRANSFORM(aGT[1]   ,  "9,999,999.99999") )
   oRpt:Say( 36,50,TRANSFORM(aGT[2]   ,"999,999,999.99") )

   oRpt:Say( 42,31,"TOTALES A COSTO PROMEDIO" )
   oRpt:nL := 43
   aRS[9,3] += aRS[9,1]
   aRS[9,4] += aRS[9,2]
   FOR nF := 2 TO 9
      oRpt:Say( oRpt:nL,01,aRes[nF] )
      oRpt:Say( oRpt:nL,31,TRANSFORM(aRS[nF,3],  "9,999,999.99999") )
      oRpt:Say( oRpt:nL,50,TRANSFORM(aRS[nF,4],"999,999,999.99") )
      oRpt:nL += 2
   NEXT nF
   aGT[1]  := aRS[09,3] - aRS[10,1]
   aGT[2]  := aRS[09,4] - aRS[10,2]
   oRpt:Say( oRpt:nL,20,"DIFERENCIA " )
   oRpt:Say( oRpt:nL,31,TRANSFORM(aGT[1]   ,  "9,999,999.99999") )
   oRpt:Say( oRpt:nL,50,TRANSFORM(aGT[2]   ,"999,999,999.99") )
   oRpt:NewPage()
   oRpt:End()
ElseIf ::aLS[9] == 2
   ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit      ,;
               "MOVIMIENTO A", aGT[4]  ,;
             {  9.6,"C A N T I D A D" }, { 14.2,"PRECIO COSTO" } }
   ::Init( ::aEnc[4], .f. ,, !::aLS[10] ,,, ::aLS[10] )
   ::nMD := 18.0
    PAGE
      ::Cabecera( .t. )
   FOR nF := 1 TO 8
      UTILPRN ::oUtil Self:nLinea, 1.0 SAY aRes[nF]
      UTILPRN ::oUtil Self:nLinea,12.0 SAY TRANSFORM(aRS[nF,1],  "9,999,999.99999") RIGHT
      UTILPRN ::oUtil Self:nLinea,17.0 SAY TRANSFORM(aRS[nF,2],"999,999,999.99")    RIGHT
      ::nLinea += 1
      aRS[10,1] += aRS[nF,1]
      aRS[10,2] += aRS[nF,2]
   NEXT nF
      aGT[1]  := aRS[09,1] - aRS[10,1]
      aGT[2]  := aRS[09,2] - aRS[10,2]
      UTILPRN ::oUtil Self:nLinea,12.0 SAY "================" RIGHT
      UTILPRN ::oUtil Self:nLinea,17.0 SAY "================" RIGHT
      ::nLinea += 0.5
      UTILPRN ::oUtil Self:nLinea, 1.0 SAY aRes[9]
      UTILPRN ::oUtil Self:nLinea,12.0 SAY TRANSFORM(aRS[09,1],  "9,999,999.99999") RIGHT
      UTILPRN ::oUtil Self:nLinea,17.0 SAY TRANSFORM(aRS[09,2],"999,999,999.99")    RIGHT
      ::nLinea += 0.5
      UTILPRN ::oUtil Self:nLinea, 1.0 SAY "SUMAS"
      UTILPRN ::oUtil Self:nLinea,12.0 SAY TRANSFORM(aRS[10,1],  "9,999,999.99999") RIGHT
      UTILPRN ::oUtil Self:nLinea,17.0 SAY TRANSFORM(aRS[10,2],"999,999,999.99")    RIGHT
      ::nLinea += 0.5
      UTILPRN ::oUtil Self:nLinea, 1.0 SAY "DIFER"
      UTILPRN ::oUtil Self:nLinea,12.0 SAY TRANSFORM(aGT[1]   ,  "9,999,999.99999") RIGHT
      UTILPRN ::oUtil Self:nLinea,17.0 SAY TRANSFORM(aGT[2]   ,"999,999,999.99")    RIGHT
      ::nLinea += 2.0

      UTILPRN ::oUtil Self:nLinea, 9.0 SAY "TOTALES A COSTO PROMEDIO"
      ::nLinea += 0.5
   aRS[9,3] += aRS[9,1]
   aRS[9,4] += aRS[9,2]
   FOR nF := 2 TO 9
      UTILPRN ::oUtil Self:nLinea, 1.0 SAY aRes[nF]
      UTILPRN ::oUtil Self:nLinea,12.0 SAY TRANSFORM(aRS[nF,3],  "9,999,999.99999") RIGHT
      UTILPRN ::oUtil Self:nLinea,17.0 SAY TRANSFORM(aRS[nF,4],"999,999,999.99")    RIGHT
      ::nLinea += 1
   NEXT nF
   aGT[1]  := aRS[09,3] - aRS[10,1]
   aGT[2]  := aRS[09,4] - aRS[10,2]
      UTILPRN ::oUtil Self:nLinea, 1.0 SAY "DIFERENCIA"
      UTILPRN ::oUtil Self:nLinea,12.0 SAY TRANSFORM(aGT[1]   ,  "9,999,999.99999") RIGHT
      UTILPRN ::oUtil Self:nLinea,17.0 SAY TRANSFORM(aGT[2]   ,"999,999,999.99")    RIGHT
  ENDPAGE
 ::EndInit( .F. )
EndIf
/*aQUI
ElseIf ::aLS[9] == 3
   cQry := cFilePath( GetModuleFileName( GetInstance() )) + "Test1.xls"
   oRpt := TExcelScript():New()
   oRpt:Create( cQry )
   oRpt:Font("Verdana")
   oRpt:Size(10)
   oRpt:Align(1)
   oRpt:Visualizar(.F.)
   oRpt:Say(  1 , 1 , oApl:cEmpresa )
   oRpt:Say(  2 , 2 , "MOVIMIENTO A " + aGT[4] )
   oRpt:Say(  3 , 2 , "Monturas" )
   oRpt:Say(  3 , 3 , "Liquidos" )
   oRpt:Say(  3 , 4 , "Accesorios" )
   oRpt:Say(  3 , 5 , "L.Contacto" )
   oRpt:Say(  3 , 6 , "T O T A L" )
   aGT := "=SUMA(B*:E*)"
   FOR nF := 1 TO 10
      oRpt:Say( nF+3 , 1 , aRes[nF] )
      oRpt:Say( nF+3 , 2 , aRS[nF,5] )
      oRpt:Say( nF+3 , 3 , aRS[nF,6] )
      oRpt:Say( nF+3 , 4 , aRS[nF,7] )
      oRpt:Say( nF+3 , 5 , aRS[nF,8] )
      oRpt:Say( nF+3 , 6 , STRTRAN( aGT,"*",LTRIM(STR(nF+3)) ) )
   NEXT nF
   oRpt:Say( nF+3 , 2 , "=SUMA(B4:B12)" )
   oRpt:Say( nF+3 , 3 , "=SUMA(C4:C12)" )
   oRpt:Say( nF+3 , 4 , "=SUMA(D4:D12)" )
   oRpt:Say( nF+3 , 5 , "=SUMA(E4:E12)" )

   oRpt:Say( nF+5 , 2 , "DIFERENCIAS" )
   oRpt:Say( nF+5 , 2 , "=SUMA(B13-B14)" )
   oRpt:Say( nF+5 , 3 , "=SUMA(C13-C14)" )
   oRpt:Say( nF+5 , 4 , "=SUMA(D13-D14)" )
   oRpt:Say( nF+5 , 5 , "=SUMA(E13-E14)" )
   oRpt:Visualizar(.T.)
   oRpt:End(.F.) ; oRpt := NIL
Else
   cQry := cFilePath( GetModuleFileName( GetInstance() )) + "Test1.csv"
   FERASE(cQry)
   hRes := FCREATE(cQry,0) //, FC_NORMAL)
   If FERROR() != 0
      Msginfo(FERROR(),"No se pudo crear el archivo "+cQry )
      RETURN
   EndIf
   aGT[1] := "=SUMA(B*:E*)"
   aGT[2] := CHR(13) + CHR(10)  //CRLF

   FWRITE( hRes,'"'+oApl:cEmpresa+'"'+aGT[2] )
   FWRITE( hRes,'"MOVIMIENTO A ' + aGT[4] + '"' +aGT[2] )
   FWRITE( hRes,'"","Monturas","Liquidos","Accesorios","L.Contacto","T O T A L"'+aGT[2] )

   FOR nF := 1 TO 10
      aGT[3] := XTrim( aRes[nF] ,-9 ) + XTrim( aRS[nF,5],-9 ) +;
                XTrim( aRS[nF,6],-9 ) + XTrim( aRS[nF,7],-9 ) + XTrim( aRS[nF,8],-9 )
      FWRITE( hRes,aGT[3]  + '"' + STRTRAN( aGT[1],"*",LTRIM(STR(nF+3)) ) + '"' + aGT[2] )
   NEXT nF
   FWRITE( hRes,'"SUMATORIA","=SUMA(B4:B12)","=SUMA(C4:C12)",' +;
                            '"=SUMA(D4:D12)","=SUMA(E4:E12)"'  +  aGT[2] )
   FWRITE( hRes,'""' + aGT[2] )
   FWRITE( hRes,'"DIFERENCIA","=SUMA(B13-B14)","=SUMA(C13-C14)",'+;
                             '"=SUMA(D13-D14)","=SUMA(E13-E14)"' + aGT[2] )
   If !FCLOSE(hRes)
      Msginfo(FERROR(),"Error cerrando el archivo "+cQry)
   EndIf
   WAITRUN("OPENOFICE.BAT " + cQry, 0 )
EndIf
*/
RETURN NIL

//------------------------------------//
METHOD Query( nH,aGT ) CLASS TRinve
   LOCAL cQry, hRes
If nH == 1
   cQry := "SELECT s.codigo, s.existencia, s.pcosto, s.anomes, s.entradas, s.devol_e, "+;
                  "s.devolcli, s.salidas, s.devol_s, s.ajustes_e, s.ajustes_s "        +;
           "FROM cadinvme s  "                                       +;
           "WHERE s.empresa = " + LTRIM(STR(oApl:nEmpresa))          +;
            " AND s.anomes  = (SELECT MAX(m.anomes) FROM cadinvme m "+;
                              "WHERE m.empresa = s.empresa"          +;
	                             " AND m.codigo  = s.codigo"           +;
			                         " AND m.anomes <= '" + ::aLS[1] + "')"+;
            " AND (s.existencia <> 0 OR s.anomes = '"+ ::aLS[1] + "')"
ElseIf nH == 2
   cQry := "SELECT d.cantidad, d.unidadmed, d.pcosto, i.unidadmed, i.codcon "+;
           "FROM cadartic c, cadartid d LEFT JOIN cadinven i"+;
           " USING( codigo ) "                               +;
           "WHERE d.indica <> 'B'"                           +;
            " AND c.ingreso = d.ingreso"                     +;
            " AND c.empresa   = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND c.fecingre >= " + xValToChar( aGT[1] )     +;
            " AND c.fecingre <= " + xValToChar( aGT[2] )
ElseIf nH == 3
   cQry := "SELECT d.cantidad, d.unidadmed, d.pcosto, i.unidadmed, i.codcon, t.tipo_ajust "+;
           "FROM cadtipos t, caddevoc c, caddevod d LEFT JOIN cadinven i"+;
           " USING( codigo ) "                              +;
           "WHERE t.clase    = 'Devolucion'"                +;
            " AND d.causadev = t.tipo"                      +;
            " AND d.empresa  = c.empresa"                   +;
            " AND d.numero   = c.numero"                    +;
            " AND c.empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND c.fecha   >= " + xValToChar( aGT[1] )     +;
            " AND c.fecha   <= " + xValToChar( aGT[2] )
ElseIf nH == 4
   cQry := "SELECT d.cantidad, d.unidadmed, d.pcosto, i.unidadmed, i.codcon "+;
           "FROM cadnotac c, cadnotad d LEFT JOIN cadinven i"+;
           " USING( codigo ) "                               +;
           "WHERE d.empresa = c.empresa"                     +;
            " AND d.numero  = c.numero"                      +;
            " AND d.tipo    = c.tipo"                        +;
            " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa))  +;
            " AND c.fecha  >= " + xValToChar( aGT[1] )       +;
            " AND c.fecha  <= " + xValToChar( aGT[2] )
ElseIf nH == 5
   cQry := "SELECT d.cantidad, d.unidadmed, d.pcosto, i.unidadmed, i.codcon "+;
           "FROM cadfactc c, cadfactd d LEFT JOIN cadinven i"+;
           " USING( codigo ) "                               +;
           "WHERE d.empresa = c.empresa"                     +;
            " AND d.numfac  = c.numfac"                      +;
            " AND d.tipo    = c.tipo"                        +;
            " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa))  +;
            " AND c.fechoy >= " + xValToChar( aGT[1] )       +;
            " AND c.fechoy <= " + xValToChar( aGT[2] )       +;
            " AND c.tipo   <> 'Z' AND c.indicador <> 'A'"
ElseIf nH == 6
   cQry := "SELECT d.cantidad, d.unidadmed, d.pcosto, i.unidadmed, i.codcon, t.tipo_ajust "+;
           "FROM cadtipos t, cadajust d LEFT JOIN cadinven i"+;
           " USING( codigo ) "                               +;
           "WHERE t.clase   = 'Ajustes'"                     +;
            " AND d.tipo    = t.tipo"                        +;
            " AND d.empresa = " + LTRIM(STR(oApl:nEmpresa))  +;
            " AND d.fecha  >= " + xValToChar( aGT[1] )       +;
            " AND d.fecha  <= " + xValToChar( aGT[2] )
EndIf
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry, ),;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
RETURN hRes