// Programa.: PDLLICOM.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Comisiones y Facturas que Vencen Hoy.
#include "FiveWin.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE CaoLiCom( nOpc )
   LOCAL aDB, oDlg, oLF, oGet := ARRAY(9)
   DEFAULT nOpc := 1
oLF := TLComis()
aDB := { { {|| oLF:ListoCom() },"Listar Comisiones" },;
         { {|| oLF:ListoHoy() },"Listar Facturas que Vencen Hoy" },;
         { {|| oLF:ListoRes() },"Listar Resumen Diario" },;
         "FECHA INICIAL [DD.MM.AA]","FECHA  FINAL  [DD.MM.AA]" }
If nOpc == 2
   aDB[4] := "FECHA ANTERIOR [DD.MM.AA]"
   aDB[5] := "FECHA DE CORTE [DD.MM.AA]"
EndIf
oLF:aLS := { DATE(),DATE(),1,"N",.t.,1,oApl:nTFor }

DEFINE DIALOG oDlg TITLE aDB[nOpc,2] FROM 0, 0 TO 12,50
   @ 02,00 SAY aDB[4]                 OF oDlg RIGHT PIXEL SIZE 86,10
   @ 02,88 GET oGet[1] VAR oLF:aLS[1] OF oDlg  SIZE 40,10 PIXEL
   @ 14,00 SAY aDB[5]                 OF oDlg RIGHT PIXEL SIZE 86,10
   @ 14,88 GET oGet[2] VAR oLF:aLS[2] OF oDlg ;
      VALID oLF:aLS[2] >= oLF:aLS[1] SIZE 40,10 PIXEL
   @ 26,00 SAY "PAGINA INICIAL"           OF oDlg RIGHT PIXEL SIZE 86,10
   @ 26,88 GET oGet[3] VAR oLF:aLS[3] OF oDlg PICTURE "999";
      VALID Rango( oLF:aLS[3],1,999 )  SIZE 24,10 PIXEL
   @ 38,00 SAY "DESEA  UN  RESUMEN [S/N]" OF oDlg RIGHT PIXEL SIZE 86,10
   @ 38,88 GET oGet[4] VAR oLF:aLS[4] OF oDlg PICTURE "!";
      VALID oLF:aLS[4] $ "NS"                            ;
      WHEN nOpc == 1  SIZE 07,10 PIXEL
   @ 50,00 SAY "CLASE DE PAPEL"           OF oDlg RIGHT PIXEL SIZE 86,10
   @ 50,88 COMBOBOX oGet[5] VAR oLF:aLS[6] ITEMS ArrayCol( oApl:aPapel,1 );
      SIZE 46,99 OF oDlg PIXEL
   @ 50,138 CHECKBOX oGet[6] VAR oLF:aLS[5] PROMPT "Vista Previa" OF oDlg;
       SIZE 60,10 PIXEL
   @ 62,00 SAY "TIPO DE IMPRESORA"   OF oDlg RIGHT PIXEL SIZE 86,10
   @ 62,88 COMBOBOX oGet[7] VAR oLF:aLS[7] ITEMS { "MS-DOS","Laser" };
      SIZE 48,90 OF oDlg PIXEL

   @ 76, 50 BUTTON oGet[8] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[8]:Disable(), EVAL( aDB[nOpc,1] ), oDlg:End() ) PIXEL
   @ 76,100 BUTTON oGet[9] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 82, 02 SAY STR(nOpc,1)+"_PDLLICOM" OF oDlg PIXEL SIZE 34,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED NOMODAL
RETURN

//------------------------------------//
CLASS TLComis FROM TIMPRIME
 DATA aLS, hRes, nL

 METHOD ListoCom()
 METHOD LaserCom( aRes,aGT )
 METHOD ListoHoy( aVT )
 METHOD LaserHoy( aRes,aGT )
 METHOD ListoRes()
 METHOD LaserRes( aRes,aGT )
 METHOD Memo( aRes,cQry )
ENDCLASS

//------------------------------------//
METHOD ListoCom() CLASS TLComis
   LOCAL aFac, aRes, cQry, oRpt
   LOCAL aGT := { 0,0,0,0,"99,999,999.99" }
 aRes := ::Memo( "Comision" )
If ::nL == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes )
   RETURN NIL
ElseIf ::aLS[7] == 2
   ::LaserCom( aRes,aGT )
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"REPORTE DE COMISIONES",;
         "DESDE " + NtChr( ::aLS[1],"2" ) + " HASTA " + NtChr( ::aLS[2],"2" ),;
         "          --FACTURA-   FECHA FACTURA          VALOR FACTURA   "+;
         " VALOR  PAGOS"},::aLS[5],::aLS[3],1,oApl:aPapel[::aLS[6],2] )
aFac := { aRes[1],aRes[2],aRes[3],0 }
cQry := "SELECT SUM(abono) FROM cadpagos "             +;
        "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
         " AND numfac  = [X]"                          +;
         " AND tipo    = " + xValToChar( oApl:Tipo )   +;
         " AND fecpag >= " + xValToChar( ::aLS[1] )    +;
         " AND fecpag <= " + xValToChar( ::aLS[2] )    +;
         " AND indicador <> 'A'"
While ::nL > 0
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. aFac[1] # aRes[1]
      aFac[4] := Buscar( STRTRAN( cQry,"[X]",LTRIM(STR(aFac[1])) ),"CM",,8 )
      If !EMPTY( aFac[4] )
         If ::aLS[4] == "N"
            oRpt:Titulo( 76 )
            If oRpt:nPage >= oRpt:nPagI
               oRpt:Say( oRpt:nL,10,aFac[1] )
               oRpt:Say( oRpt:nL,25,NtChr( aFac[2],"2" ) )
               oRpt:Say( oRpt:nL,46,TRANSFORM(aFac[3],aGT[5]) )
               oRpt:Say( oRpt:nL,62,TRANSFORM(aFac[4],aGT[5]) )
            EndIf
            oRpt:nL ++
         EndIf
         aGT[1] ++
         aGT[2] += aFac[3]
         aGT[3] += aFac[4]
      EndIf
      aFac := { aRes[1],aRes[2],aRes[3],0 }
   EndIf
EndDo
MSFreeResult( ::hRes )
If aGT[1] > 0
   aGT[4] := aGT[3] * .0075
   oRpt:Say(  oRpt:nL, 01,REPLICATE("_",76),,,1 )
   oRpt:Say(++oRpt:nL, 01,STR( aGT[1],3 ) + " TOTAL FACTURAS CON PAGOS :",,,1 )
   oRpt:Say(  oRpt:nL,46,TRANSFORM(aGT[2],aGT[5]) )
   oRpt:Say(  oRpt:nL,62,TRANSFORM(aGT[3],aGT[5]) )
   oRpt:Separator( 2,6 )
   oRpt:Say( oRpt:nL  ,10,"Total Comision   0.75% " + NtChr( aGT[4]     ,aGT[5] ) )
   oRpt:Say( oRpt:nL+1,10,"Total Comision  35   % " + NtChr( aGT[4]*.35 ,aGT[5] ) )
   oRpt:Say( oRpt:nL+2,10,"Total Comision  20   % " + NtChr( aGT[4]*.20 ,aGT[5] ) )
   oRpt:Say( oRpt:nL+3,10,"Total Comision  12.5 % " + NtChr( aGT[4]*.125,aGT[5] ) )
EndIf
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserCom( aRes,aGT ) CLASS TLComis
   LOCAL aFac, cQry
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit,;
             "REPORTE DE COMISIONES"          ,;
             "DESDE "+NtChr( ::aLS[1],"2" ) + " HASTA " + NtChr( ::aLS[2],"2" ),;
             { .T., 5.0,"FACTURA" }      , { .F., 9.0,"FECHA FACTURA" },;
             { .T.,16.0,"VALOR FACTURA" }, { .T.,20.0,"VALOR  PAGOS" } }
aFac := { aRes[1],aRes[2],aRes[3],0 }
cQry := "SELECT SUM(abono) FROM cadpagos "             +;
        "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
         " AND numfac  = [X]"                          +;
         " AND tipo    = " + xValToChar( oApl:Tipo )   +;
         " AND fecpag >= " + xValToChar( ::aLS[1] )    +;
         " AND fecpag <= " + xValToChar( ::aLS[2] )    +;
         " AND indicador <> 'A'"
 ::TamanoHoja( oApl:aPapel[::aLS[6],2] )
 ::Init( ::aEnc[4], .f. ,, !::aLS[5] ,,,, 2 )
   PAGE
While ::nL > 0
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. aFac[1] # aRes[1]
      aFac[4] := Buscar( STRTRAN( cQry,"[X]",LTRIM(STR(aFac[1])) ),"CM",,8 )
      If !EMPTY( aFac[4] )
         If ::aLS[4] == "N"
            ::Cabecera( .t.,0.45 )
            UTILPRN ::oUtil Self:nLinea,05.0 SAY STR(aFac[1],10)             RIGHT
            UTILPRN ::oUtil Self:nLinea,09.0 SAY NtChr( aFac[2],"2" )
            UTILPRN ::oUtil Self:nLinea,16.0 SAY TRANSFORM( aFac[3],aGT[5] ) RIGHT
            UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM( aFac[4],aGT[5] ) RIGHT
         EndIf
         aGT[1] ++
         aGT[2] += aFac[3]
         aGT[3] += aFac[4]
      EndIf
      aFac := { aRes[1],aRes[2],aRes[3],0 }
   EndIf
EndDo
MSFreeResult( ::hRes )
   If aGT[1] > 0
      aGT[4] := aGT[3] * .0075
      ::Cabecera( .t.,0.4,2.35,20 )
      UTILPRN ::oUtil Self:nLinea,02.0 SAY STR( aGT[1],3 ) + " TOTAL FACTURAS CON PAGOS :"
      UTILPRN ::oUtil Self:nLinea,16.0 SAY TRANSFORM( aGT[2],aGT[5] )      RIGHT
      UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM( aGT[3],aGT[5] )      RIGHT
      ::nLinea += 0.60
      UTILPRN ::oUtil Self:nLinea,02.0 SAY "Total Comision   0.75% "
      UTILPRN ::oUtil Self:nLinea,09.0 SAY TRANSFORM( aGT[4],aGT[5] )      RIGHT
      ::nLinea += 0.45
      UTILPRN ::oUtil Self:nLinea,02.0 SAY "Total Comision  35   % "
      UTILPRN ::oUtil Self:nLinea,09.0 SAY TRANSFORM( aGT[4]*.35 ,aGT[5] ) RIGHT
      ::nLinea += 0.45
      UTILPRN ::oUtil Self:nLinea,02.0 SAY "Total Comision  20   % "
      UTILPRN ::oUtil Self:nLinea,09.0 SAY TRANSFORM( aGT[4]*.20 ,aGT[5] ) RIGHT
      ::nLinea += 0.45
      UTILPRN ::oUtil Self:nLinea,02.0 SAY "Total Comision  12.5 % "
      UTILPRN ::oUtil Self:nLinea,09.0 SAY TRANSFORM( aGT[4]*.125,aGT[5] ) RIGHT
   EndIf
   ENDPAGE
IMPRIME END .F.
RETURN NIL

//------------------------------------//
METHOD ListoHoy() CLASS TLComis
   LOCAL oRpt, aRes, aGT := { 0,.5,0,0,0,"99,999,999" }
If ::aLS[1] < ::aLS[2]
   aRes := "UPDATE cadfactu SET fechacob = " + xValToChar( ::aLS[2] )+;
          " WHERE empresa  = " + LTRIM(STR(oApl:nEmpresa))           +;
          " AND fechacob  >= " + xValToChar( ::aLS[1] )              +;
          " AND fechacob  <= " + xValToChar( ::aLS[2] )              +;
          " AND indicador <> 'C'"
   MSQuery( oApl:oMySql:hConnect,aRes )
EndIf
/*
FROM cadfactm s, cadfactu f, cadclien n
WHERE f.codigo_nit = n.codigo_nit
  AND f.empresa  = 4

SELECT n.nombre, n.codigo, n.digito, f.hora, f.numfac,
       f.fechoy, f.cliente, f.telefono, s.saldo
FROM cadfactm s, cadfactu f LEFT JOIN cadclien n
 USING( codigo_nit )
WHERE f.empresa  = 4
  AND f.fechacob = '2013-05-08'
  AND f.tipo     = 'U'
  AND f.indicador <> 'A'
  AND s.empresa = f.empresa
  AND s.numfac = f.numfac and s.tipo = f.tipo
  AND s.anomes = (SELECT MAX(m.anomes) FROM cadfactm m
                  WHERE m.empresa = f.empresa
                    AND m.numfac  = f.numfac
                    AND m.tipo    = f.tipo
                    AND m.anomes <= '201305')
  AND s.saldo <> 0
ORDER BY n.sector, n.nombre, f.cliente, f.numfac
*/
 aRes := ::Memo( "Cobros" )
If ::nL == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes )
   RETURN NIL
ElseIf ::aLS[7] == 2
   ::LaserHoy( aRes,aGT )
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"REPORTE DE FACTURAS PARA COBRAR HOY"   ,;
         NtChr( ::aLS[2],"3" ),SPACE(50)+"----FACTURA  FEC.FACTURA  N O M B R E"+;
         "  DEL C L I E N T E -T E L E F O N O S SALDO FACT."},::aLS[5],,2,oApl:aPapel[::aLS[6],2] )
While ::nL > 0
   oApl:oFah:Seek( {"numfac",aRes[5],"tipo",oApl:Tipo} )
   oRpt:Titulo( 136 )
   If aGT[2]  # aRes[2]
      aGT[2] := aRes[2]
      oRpt:Say( oRpt:nL,01,aRes[1] )
      oRpt:Say( oRpt:nL,31,TRANSFORM(aRes[2],"999,999,999-") + STR(aRes[3],1) )
   EndIf
   oRpt:Say( oRpt:nL, 45,aRes[4] + STR(aRes[5],8) )
   oRpt:Say( oRpt:nL, 63,NtChr( aRes[6],"2" ) )
   oRpt:Say( oRpt:nL, 76,aRes[7] )
   oRpt:Say( oRpt:nL,107,aRes[8],18 )
   oRpt:Say( oRpt:nL,126,TRANSFORM(aRes[9],aGT[6]) )
   oRpt:Say( oRpt:nL,137,If( oApl:oFah:lOK, "A", "" ) )
   oRpt:nL ++
   aGT[3] += aRes[9]
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. aGT[2] # aRes[2]
      If aGT[3] # 0
         aGT[1] ++
         aGT[4] += If( aGT[2] > 0, aGT[3], 0 )
         aGT[5] += aGT[3]
         aGT[3] := 0
         oRpt:nL ++
      EndIf
   EndIf
EndDo
MSFreeResult( ::hRes )
If aGT[1] > 0
   oRpt:Say(  oRpt:nL, 01,REPLICATE("_",136),,,1 )
   oRpt:Say(++oRpt:nL, 01,STR( aGT[1],3 ) + "  SALDOS",,,1 )
   oRpt:Say(  oRpt:nL,126,TRANSFORM(aGT[5],aGT[6]) )
   oRpt:Say(++oRpt:nL, 01,REPLICATE("_",136),,,1 )
   oRpt:Separator( 2,2 )
   oRpt:Say( oRpt:nL  ,10,"TOTAL EMPRESAS ------------> $"+NtChr( aGT[4],aGT[6] ) )
   oRpt:Say( oRpt:nL+2,10,"TOTAL CUENTAS POR COBRAR --> $"+NtChr( aGT[5],aGT[6] ) )
EndIf
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserHoy( aRes,aGT ) CLASS TLComis
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit     ,;
             "REPORTE DE FACTURAS PARA COBRAR HOY" ,;
             NtChr( ::aLS[2],"3" )                 ,;
             { .T., 9.5,"FACTURA" }  , { .F., 9.7,"FEC.FACTURA" },;
             { .F.,11.8,"NOMBRE DEL CLIENTE" }                   ,;
             { .F.,16.5,"TELEFONOS" }, { .T.,20.6,"SALDO FACT." } }
 ::TamanoHoja( oApl:aPapel[::aLS[6],2] )
 ::Init( ::aEnc[4], .f. ,, !::aLS[5] ,,,, 5 )
 ::nMD := 20.9
   PAGE
While ::nL > 0
   oApl:oFah:Seek( {"numfac",aRes[5],"tipo",oApl:Tipo} )
      ::Cabecera( .t.,0.45 )
   If aGT[2]  # aRes[2]
      aGT[2] := aRes[2]
      UTILPRN ::oUtil Self:nLinea,00.5 SAY aRes[1]
      UTILPRN ::oUtil Self:nLinea,07.2 SAY TRANSFORM(aRes[2],"999,999,999-") + STR(aRes[3],1) RIGHT
   EndIf
      UTILPRN ::oUtil Self:nLinea,07.4 SAY aRes[4]
      UTILPRN ::oUtil Self:nLinea,09.5 SAY STR(aRes[5],8)              RIGHT
      UTILPRN ::oUtil Self:nLinea,09.7 SAY NtChr( aRes[6],"2" )
      UTILPRN ::oUtil Self:nLinea,11.8 SAY aRes[7]
      UTILPRN ::oUtil Self:nLinea,16.5 SAY LEFT(aRes[8],18)
      UTILPRN ::oUtil Self:nLinea,20.6 SAY TRANSFORM( aRes[9],aGT[6] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,20.8 SAY If( oApl:oFah:lOK, "A", "" )
   aGT[3] += aRes[9]
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. aGT[2] # aRes[2]
      If aGT[3] # 0
         aGT[1] ++
         aGT[4] += If( aGT[2] > 0, aGT[3], 0 )
         aGT[5] += aGT[3]
         aGT[3] := 0
         ::nLinea += 0.45
      EndIf
   EndIf
EndDo
MSFreeResult( ::hRes )
      ::Cabecera( .t.,0.4,1.45,21 )
      UTILPRN ::oUtil Self:nLinea,02.0 SAY STR( aGT[1],3 ) + "  SALDOS"
      UTILPRN ::oUtil Self:nLinea,20.6 SAY TRANSFORM( aGT[5],aGT[6] ) RIGHT
      ::nLinea += 0.60
      UTILPRN ::oUtil Self:nLinea,02.0 SAY "TOTAL EMPRESAS ------------> $"
      UTILPRN ::oUtil Self:nLinea,08.0 SAY TRANSFORM( aGT[4],aGT[6] ) RIGHT
      ::nLinea += 0.45
      UTILPRN ::oUtil Self:nLinea,02.0 SAY "TOTAL CUENTAS POR COBRAR --> $"
      UTILPRN ::oUtil Self:nLinea,08.0 SAY TRANSFORM( aGT[5],aGT[6] ) RIGHT
   ENDPAGE
IMPRIME END .F.
RETURN NIL

//------------------------------------//
METHOD ListoRes() CLASS TLComis
   LOCAL aGT, aRes, nFP, nSaldo, oRpt
oApl:cPer := NtChr( ::aLS[2],"1" )
 aRes := ::Memo( "Resumen" )
 aGT  := { 0,0,0,0,0,0,0,0,0,"E F E C T I V O    ","C H E Q U E S      ",;
           "TARJETAS DEBITO    ","TARJETAS DE CREDITO","TARJETA DE AHORROS " }
If ::nL == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes )
   RETURN NIL
ElseIf ::aLS[7] == 2
   ::LaserRes( aRes,aGT )
   RETURN NIL
EndIf

oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"RESUMEN DE INGRESOS DIARIOS",""  ,;
          SPACE(20) + "NRO FACTURA  MONTO DEL ABONO  SALDO FACTURA  "  +;
          "BANCO NUMERO DEL CHEQUE" },::aLS[5],,2,oApl:aPapel[::aLS[6],2] )
If ::aLS[2] > ::aLS[1]
   oRpt:aEnc[2] := "DESDE " + NtChr( ::aLS[1],"2" ) + " HASTA " + NtChr( ::aLS[2],"2" )
Else
   oRpt:aEnc[2] := NtChr( ::aLS[1],"3" )
EndIf
While ::nL > 0
   nSaldo := SaldoFac( aRes[02],1 )
   oRpt:Titulo( 126 )
   If aGT[9] == 0
      nFP := aRes[1]
      oRpt:Say( oRpt:nL,01,aGT[nFP+10] + ":" )
   EndIf
   oRpt:Say( oRpt:nL,21,STR( aRes[02],10 ) )
// oRpt:Say( oRpt:nL,31,If( cTipo = "UD" .And. Tipo = "D", ".", " " ))
   oRpt:Say( oRpt:nL,34,TRANSFORM(aRes[05],"99,999,999.99") )
   oRpt:Say( oRpt:nL,50,TRANSFORM(nSaldo  ,"99,999,999.99") )
   oRpt:Say( oRpt:nL,67,aRes[03] )  //CodBanco
   oRpt:Say( oRpt:nL,71,aRes[04] )  //NumCheque
   oRpt:Say( oRpt:nL,88,aRes[13] )  //Cliente
   oRpt:nL ++
   aGT[2] += aRes[06]  //Deduccion
   aGT[3] += aRes[07]  //Descuento
   aGT[4] += aRes[08]  //Retencion
   aGT[5] += aRes[09]  //Retica
   aGT[6] += aRes[10]  //Retiva
   aGT[7] += aRes[11]  //Retfte
   aGT[8] += aRes[12]  //Retcre
   aGT[9] += aRes[05]  //Abono
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. nFP # aRes[1]
      oRpt:Titulo( 126 )
      oRpt:Say(++oRpt:nL,01,oRpt:CPIBold + "TOTAL "+ aGT[nFP+10]+ ":",,,1 )
      oRpt:Say(  oRpt:nL,34,TRANSFORM( aGT[9],"99,999,999.99" )+oRpt:CPIBoldN )
      oRpt:nL += 2
      aGT[1] += aGT[9]
      aGT[9] := 0
   EndIf
EndDo
MSFreeResult( ::hRes )
aGT[9] := aGT[1] + aGT[2] + aGT[3] + aGT[4] + aGT[5] + aGT[6] + aGT[7] + aGT[8]
aRes := { "TOTAL INGRESOS"  ,"TOTAL DEDUCCION","TOTAL DESCUENTO",;
          "TOTAL RETENCION" ,"TOTAL RET.ICA." ,"TOTAL RET.IVA"  ,;
          "TOTAL RET.FUENTE","TOTAL RET.CREE" ,"TOTAL CARTERA" }
oRpt:Separator( 0,9 )
oRpt:SetFont( oRpt:cFontI+oRpt:CPIBold,82,2 )
   FOR nFP := 1 TO 9
      oRpt:Say( oRpt:nL  ,01,aRes[nFP] )
      oRpt:Say( oRpt:nL++,34,TRANSFORM(aGT[nFP],"99,999,999.99") )
      If nFP == 8
         oRpt:Say( oRpt:nL++,34,"=============" )
      EndIf
   NEXT nFP
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserRes( aRes,aGT ) CLASS TLComis
   LOCAL nFP, nSaldo
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit     ,;
             "RESUMEN DE INGRESOS DIARIOS" , ""    ,;
             { .T., 5.9,"FACTURA" }, { .T., 8.8,"MONTO DEL ABONO" },;
             { .T.,11.4,"SALDO FACTURA" }                   ,;
             { .F.,11.6,"BANCO" }  , { .F.,12.8,"NUMERO DEL CHEQUE" } }
If ::aLS[2] > ::aLS[1]
   ::aEnc[5] := "DESDE " + NtChr( ::aLS[1],"2" ) + " HASTA " + NtChr( ::aLS[2],"2" )
Else
   ::aEnc[5] := NtChr( ::aLS[1],"3" )
EndIf
 ::TamanoHoja( oApl:aPapel[::aLS[6],2] )
 ::Init( ::aEnc[4], .f. ,, !::aLS[5] ,,,, 5 )
 ::nMD := 20.9
   PAGE
While ::nL > 0
   nSaldo := SaldoFac( aRes[02],1 )
      ::Cabecera( .t.,0.45 )
   If aGT[9] == 0
      nFP := aRes[1]
      UTILPRN ::oUtil Self:nLinea,00.5 SAY aGT[nFP+10] + ":"
   EndIf
      UTILPRN ::oUtil Self:nLinea,05.9 SAY STR(aRes[2])              RIGHT
      UTILPRN ::oUtil Self:nLinea,08.8 SAY TRANSFORM( aRes[5],"99,999,999.99" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,11.4 SAY TRANSFORM(  nSaldo,"99,999,999.99" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,11.8 SAY aRes[3]
      UTILPRN ::oUtil Self:nLinea,12.8 SAY aRes[4]
      UTILPRN ::oUtil Self:nLinea,15.8 SAY aRes[13]
   aGT[2] += aRes[06]  //Deduccion
   aGT[3] += aRes[07]  //Descuento
   aGT[4] += aRes[08]  //Retencion
   aGT[5] += aRes[09]  //Retica
   aGT[6] += aRes[10]  //Retiva
   aGT[7] += aRes[11]  //Retfte
   aGT[8] += aRes[12]  //Retcre
   aGT[9] += aRes[05]  //Abono
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. nFP # aRes[1]
      ::Cabecera( .t.,0.80 )
      UTILPRN ::oUtil SELECT ::aFnt[6]
      UTILPRN ::oUtil Self:nLinea,00.5 SAY "TOTAL "+ aGT[nFP+10]+ ":"
      UTILPRN ::oUtil Self:nLinea,08.8 SAY TRANSFORM( aGT[9],"99,999,999.99" ) RIGHT
      UTILPRN ::oUtil SELECT ::aFnt[5]
      aGT[1] += aGT[9]
      aGT[9] := 0
      ::nLinea += 0.45
   EndIf
EndDo
MSFreeResult( ::hRes )
aGT[9] := aGT[1] + aGT[2] + aGT[3] + aGT[4] + aGT[5] + aGT[6] + aGT[7] + aGT[8]
aRes := { "TOTAL INGRESOS"  ,"TOTAL DEDUCCION","TOTAL DESCUENTO",;
          "TOTAL RETENCION" ,"TOTAL RET.ICA." ,"TOTAL RET.IVA"  ,;
          "TOTAL RET.FUENTE","TOTAL RET.CREE" ,"TOTAL CARTERA" }
      ::Cabecera( .t.,0.4,4.50,20.9 )
      UTILPRN ::oUtil SELECT ::aFnt[6]
   FOR nFP := 1 TO 9
      UTILPRN ::oUtil Self:nLinea,01.0 SAY aRes[nFP]
      UTILPRN ::oUtil Self:nLinea,08.8 SAY TRANSFORM( aGT[nFP],"99,999,999.99" ) RIGHT
      ::nLinea += 0.45
      If nFP == 8
         UTILPRN ::oUtil Self:nLinea,08.8 SAY "=============" RIGHT
         ::nLinea += 0.45
      EndIf
   NEXT nFP
   ENDPAGE
IMPRIME END .F.
RETURN NIL

//------------------------------------//
METHOD Memo( aRes,cQry ) CLASS TLComis
If aRes == "Comision"
   cQry := "SELECT f.numfac, f.fechoy, f.totalfac, v.despor "       +;
           "FROM cadventa v, cadfactu f "                           +;
           "WHERE f.empresa = " + LTRIM(STR(oApl:nEmpresa))         +;
            " AND f.fechoy >= " + xValToChar( ::aLS[1]-45 )         +;
            " AND f.fechoy <= " + xValToChar( ::aLS[2] )            +;
            " AND f.tipo    = " + xValToChar( oApl:Tipo )           +;
            " AND v.numfac  = f.numfac"                             +;
            " AND v.tipo    = f.tipo"                               +;
            " AND v.despor = (SELECT MAX(d.despor) FROM cadventa d "+;
                             "WHERE d.empresa = f.empresa"          +;
                              " AND d.numfac  = f.numfac"           +;
                              " AND d.tipo    = f.tipo)"            +;
            " AND v.despor < 20 ORDER BY f.numfac"
ElseIf aRes == "Cobros"
   cQry := "SELECT n.nombre, n.codigo, n.digito, f.hora, f.numfac, "+;
                  "f.fechoy, f.cliente, f.telefono, s.saldo "       +;
           "FROM cadfactm s, cadfactu f LEFT JOIN cadclien n "      +;
            "USING( codigo_nit ) "                                  +;
           "WHERE f.empresa  = " + LTRIM(STR(oApl:nEmpresa))        +;
            " AND f.fechacob = " + xValToChar( ::aLS[2] )           +;
            " AND f.tipo     = " + xValToChar( oApl:Tipo )          +;
            " AND f.indicador <> 'A'"                               +;
            " AND s.empresa = f.empresa"                            +;
            " AND s.numfac = f.numfac and s.tipo = f.tipo"          +;
            " AND s.anomes = (SELECT MAX(m.anomes) FROM cadfactm m "+;
                             "WHERE m.empresa = f.empresa"          +;
                              " AND m.numfac  = f.numfac"           +;
                              " AND m.tipo    = f.tipo"             +;
			                        " AND m.anomes <= '" + NtChr(::aLS[2],"1")+;
          "') AND s.saldo <> 0"                                     +;
            " ORDER BY n.sector, n.nombre, f.cliente, f.numfac"
ElseIf aRes == "Resumen"
   cQry := "SELECT p.formapago, p.numfac, p.codbanco, p.numcheque, p.abono, p.deduccion, "+;
            "p.descuento, p.retencion, p.retica, p.retiva, p.retfte, p.retcre, f.cliente "+;
           "FROM cadpagos p LEFT JOIN cadfactu f "         +;
            "USING( empresa, numfac, tipo ) "              +;
           "WHERE p.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND p.fecpag >= " + xValToChar( ::aLS[1] )   +;
            " AND p.fecpag <= " + xValToChar( ::aLS[2] )   +;
            " AND p.tipo = "    + xValToChar( oApl:Tipo )  +;
            " AND p.formapago <= 4"                        +;
            " AND p.indicador <> 'A' ORDER BY p.formapago, p.numfac"
EndIf
::hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) > 0
   aRes := MyReadRow( ::hRes )
   AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( ::hRes,nP ) } )
EndIf
//MsgInfo( cQry,STR(::nL) )
RETURN aRes