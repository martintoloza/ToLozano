// Programa.: INOLIRSM.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Lista Inventario mensual por grupo
#include "FiveWin.ch"

MEMVAR oApl

PROCEDURE InoLiRsm( lResu )
   LOCAL oDlg, oGet := ARRAY(7)
   LOCAL aRep, aOpc := { NtChr( DATE(),"1" ),1,1,"N",.f. }
   DEFAULT lResu := .f.
If lResu
   aRep := { {|| ListoRsm( aOpc ) },"Resumen del Inventario" }
Else
   aRep := { {|| ListoInv( aOpc ) },"Inventario Mensual" }
EndIf
DEFINE DIALOG oDlg TITLE aRep[2] FROM 0, 0 TO 10,50
   @ 02, 00 SAY "DIGITE EL PERIODO" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02, 92 GET oGet[1] VAR aOpc[1] OF oDlg PICTURE "999999";
      VALID NtChr( aOpc[1],"P" )   SIZE 30,12 PIXEL
   @ 16, 00 SAY "ORDENADO POR"      OF oDlg RIGHT PIXEL SIZE 90,10
   @ 16, 92 COMBOBOX oGet[2] VAR aOpc[2] ITEMS { "Codigo","Nombre" } ;
      SIZE 50,99 OF oDlg PIXEL
   @ 30, 00 SAY "RECUPERA PAGINA DESDE LA" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 30, 92 GET oGet[3] VAR aOpc[3] OF oDlg PICTURE "###";
      VALID Rango( aOpc[3],1,999 )  SIZE 20,12 PIXEL
   @ 44, 00 SAY "RESUMEN [S/N]"     OF oDlg RIGHT PIXEL SIZE 90,10
   @ 44, 92 GET oGet[4] VAR aOpc[4] OF oDlg PICTURE "!";
      VALID aOpc[4] $ "NS"          SIZE 08,12 PIXEL
   @ 44,130 CHECKBOX oGet[5] VAR aOpc[5] PROMPT "Vista &Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 60, 50 BUTTON oGet[6] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[6]:Disable(), EVAL( aRep[1] ), oDlg:End() ) PIXEL
   @ 60,100 BUTTON oGet[7] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 66, 02 SAY "[INOLIRSM]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
STATIC PROCEDURE ListoInv( aLS )
   LOCAL oRpt, aGT := { 0,0,0 }
   LOCAL aRes, hRes, cQry, nL := NtChr( aLS[1],"F" )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"RESUMEN DEL MOVIMIENTO DEL INVENTARIO"    ,;
         "EN " + NtChr( nL,"6" ),SPACE(56) + "PRECIO    S A L D O      T O T A L",;
         "CODIGO---- D E S C R I P C I O N-------------------   C O S T O  A C T"+;
         " U A L     C O S T O"},aLS[5],aLS[3],2,,,136 )
cQry := "SELECT s.codigo, i.descrip, s.existencia, s.pcosto "     +;
        "FROM cadinvme s, cadinven i "                            +;
        "WHERE s.empresa = " + LTRIM(STR(oApl:nEmpresa))          +;
         " AND s.anomes  = (SELECT MAX(anomes) FROM cadinvme m "  +;
                           "WHERE m.empresa = s.empresa"          +;
                            " AND m.codigo  = s.codigo"           +;
                            " AND m.anomes <= '" + aLS[1] + "')"  +;
         " AND s.existencia <> 0"                                 +;
         " AND s.codigo = i.codigo  ORDER BY "   + If( aLS[2] == 1,;
         "s.codigo", "i.descrip" )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aGT[3] := aRes[3] * aRes[4]
   aGT[1] += aRes[3]
   aGT[2] +=  aGT[3]
   If aLS[4] == "N"
      oRpt:Titulo( 90 )
      If oRpt:nPage >= oRpt:nPagI
         oRpt:Say( oRpt:nL,00,aRes[1] )
         oRpt:Say( oRpt:nL,11,aRes[2] )
         oRpt:Say( oRpt:nL,53,TRANSFORM(aRes[4],    "999,999.99") )
         oRpt:Say( oRpt:nL,65,TRANSFORM(aRes[3],    "999,999.99") )
         oRpt:Say( oRpt:nL,77,TRANSFORM( aGT[3],"999,999,999.99") )
      EndIf
      oRpt:nL ++
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
If aGT[1] > 0
   oRpt:Say( oRpt:nL++,00,REPLICATE("=",90),,,1 )
   oRpt:Say( oRpt:nL  ,10,"  T O T A L E S ======>" )
   oRpt:Say( oRpt:nL  ,61,TRANSFORM(aGT[1],"999,999,999.99" ) )
   oRpt:Say( oRpt:nL  ,77,TRANSFORM(aGT[2],"999,999,999.99" ) )
EndIf
oRpt:NewPage()
oRpt:End()
RETURN

//------------------------------------//
STATIC PROCEDURE ListoRsm( aLS )
   LOCAL oRpt, aGT, cPer, nC, nK := NtChr( aLS[1],"F" )
   LOCAL aRes, hRes, nL, cQry, aTI := ARRAY(2,9)
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"RESUMEN DEL MOVIMIENTO DEL INVENTARIO" ,;
         "EN " + NtChr( nK,"6" ),SPACE(49) + "SALDO     TOTAL      TOTAL   " +;
         "DEVOLUCI  DEVOLUCI   AJUSTE     AJUSTE  DEVOLUCI    SALDO"         ,;
         "CODIGO---- D E S C R I P C I O N--------------  ANTERIOR  ENTRADAS"+;
         "    VENTAS  ENTRADAS   SALIDAS  ENTRADAS   SALIDAS   CLIENTE    ACTUAL"},;
         aLS[5],aLS[3],2,,,136 )
AEVAL( aTI, { |x| AFILL( x,0 ) } )

cPer := NtChr( nK - 1,"1" )
cQry := "SELECT s.codigo, i.descrip, s.entradas, s.salidas, s.devol_e, s.devol_s, "+;
        "s.ajustes_e, s.ajustes_s, s.devolcli, s.existencia, s.pcosto, s.anomes "  +;
        "FROM cadinvme s, cadinven i "                                  +;
        "WHERE s.empresa = " + LTRIM(STR(oApl:nEmpresa))                +;
         " AND s.anomes  = (SELECT MAX(anomes) FROM cadinvme m "        +;
                           "WHERE m.empresa = s.empresa"                +;
                            " AND m.codigo  = s.codigo"                 +;
                            " AND m.anomes <= '" + aLS[1] + "')"        +;
         " AND s.codigo = i.codigo  ORDER BY "         + If( aLS[2] == 1,;
         "s.codigo", "i.descrip" )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := aLS[3] := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aRes[12] == aLS[1]
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
      If aLS[4] == "N"
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
If aLS[3] > 0
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
EndIf
oRpt:NewPage()
oRpt:End()
RETURN