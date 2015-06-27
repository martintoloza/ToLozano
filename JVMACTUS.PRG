// Programa.: JVMACTUS.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Cambiar numeracion de Facturas
#include "Fivewin.ch"

MEMVAR oApl

PROCEDURE NumerFac( nOpc )
   LOCAL oDlg, oGet := ARRAY(9), aOpc, aRep
   LOCAL aPrv := Privileg( "RENUMERAR" )
   DEFAULT nOpc := 1
If !aPrv[nOpc]
   aOpc := If( nOpc == 1, "RENUMERAR LAS FACTURAS", "ACTUALIZAR LOS SALDOS" )
   MsgStop( "Usted no está Autorizado para " + aOpc,oApl:cUser )
   RETURN
EndIf
aRep      := ALLTRIM(oApl:oEmp:TIPOFAC)
oApl:Tipo := LEFT( Saca( @aRep,"," ),1 )
aOpc := { DATE(),DATE(),2,1,6,0,aRep }
aRep := { { {||  Renumera( aOpc,oDlg ) },"RENUMERAR LAS FACTURAS"},;
          { {|| ActuSaldo( aOpc,oDlg ) },"ACTUALIZAR LOS SALDOS"} }
DEFINE DIALOG oDlg TITLE aRep[nOpc,2] FROM 0, 0 TO 12,50
   @ 02, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02, 92 GET oGet[1] VAR aOpc[1] OF oDlg SIZE 40,10 PIXEL
   @ 14, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 14, 92 GET oGet[2] VAR aOpc[2] OF oDlg    ;
      VALID aOpc[2] >= aOpc[1] SIZE 40,10 PIXEL;
      WHEN nOpc == 1
   @ 26, 00 SAY  "INCREMENTAR FACTURAS EN" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 26, 92 GET oGet[3] VAR aOpc[3] OF oDlg PICTURE "9999" SIZE 24,10 PIXEL
    oGet[3]:cTooltip := "2 = Resumen para ver descuadres"
   @ 38, 00 SAY "TIPO DE FACTURA"          OF oDlg RIGHT PIXEL SIZE 90,10
   @ 38, 92 GET oGet[4] VAR oApl:Tipo OF oDlg PICTURE "!" ;
      VALID( If( oApl:Tipo $ aOpc[7], .t.                ,;
               ( MsgStop( "El Tipo es ["+aOpc[7]+"]","<< OJO >>" ), .f. ) ) );
      SIZE 14,10 PIXEL WHEN nOpc == 1
   @ 50, 00 SAY "Nro. FACTURA INICIAL" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 50, 92 GET oGet[5] VAR aOpc[4] OF oDlg    ;
      VALID aOpc[4] > 0 SIZE 44,10 PIXEL       ;
      WHEN nOpc == 1
   @ 62, 00 SAY "Nro. FACTURA   FINAL" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 62, 92 GET oGet[6] VAR aOpc[5] OF oDlg    ;
      VALID aOpc[5] >= aOpc[4] SIZE 44,10 PIXEL;
      WHEN nOpc == 1
   @ 62,154 SAY oGet[7] VAR aOpc[6] OF oDlg PIXEL SIZE 44,18 ;
      UPDATE COLOR nRGB( 160,19,132 )
   @ 76, 50 BUTTON oGet[8] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[8]:Disable(), EVAL( aRep[nOpc,1] ), oDlg:End() ) PIXEL
   @ 76,100 BUTTON oGet[9] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 80, 02 SAY "[JVMACTUS]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
PROCEDURE Renumera( aLS,oDlg )
   LOCAL aRes, hRes, cQry, nL
aRes := If( aLS[3] == 0, "* -1", "+ " + LTRIM( STR(aLS[3]) ) )

cQry := "UPDATE cadfactd d, cadfactc c " +;
          "SET d.numfac = d.numfac "     + aRes         +;
       " WHERE c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.numfac >= " + LTRIM( STR( aLS[4] ) )   +;
         " AND c.numfac <= " + LTRIM( STR( aLS[5] ) )   +;
         " AND c.tipo    = " + xValToChar( oApl:Tipo )  +;
         " AND c.fechoy >= " + xValToChar( aLS[1] )     +;
         " AND c.fechoy <= " + xValToChar( aLS[2] )     +;
         " AND c.empresa = d.empresa"                   +;
         " AND c.numfac  = d.numfac"                    +;
         " AND c.tipo    = d.tipo"
 MSQuery( oApl:oMySql:hConnect,cQry )

cQry := "UPDATE cadfactc SET numfac = numfac " + aRes +;
       " WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND numfac >= " + LTRIM( STR( aLS[4] ) )   +;
         " AND numfac <= " + LTRIM( STR( aLS[5] ) )   +;
         " AND tipo    = " + xValToChar( oApl:Tipo )  +;
         " AND fechoy >= " + xValToChar( aLS[1] )     +;
         " AND fechoy <= " + xValToChar( aLS[2] )
 MSQuery( oApl:oMySql:hConnect,cQry )
RETURN

//------------------------------------//
PROCEDURE ActuSaldo( aLS,oDlg )
   LOCAL aGF, cCod, cGI, nCan
   LOCAL aMV, aRes, hRes, cQry, nL
aLS[1] := NtChr( LEFT( DTOS( aLS[1] ),6 ),"F" )
aLS[2] := CTOD( NtChr( aLS[1],"4" ) )
If aLS[3] == 2
   Descuadre( aLS,oDlg )
   RETURN
ElseIf aLS[3] >= 3
   Despcosto( aLS,oDlg )
   RETURN
ElseIf aLS[4] == 0
   aGF := { aLS[7],aLS[6],aLS[5], }
   cGI := " AND d.codigo = " + xValToChar( aLS[5] )
   aLS[5] := 6
Else
   aGF := { .f.,0,0, }
   cGI := ""
EndIf

 oApl:oWnd:SetMsg( "Por Favor espere Actualizando Saldos" )
aGF[4] := NtChr( aLS[2],"1" )
aLS[6] := LOWER( ALLTRIM(oApl:cUser) ) + "sm"
/*
CREATE TABLE `promedio` (
  `row_id` int(11) NOT NULL AUTO_INCREMENT,
  `fecha` date DEFAULT NULL,
  `codigo` varchar(12) DEFAULT NULL,
  `cantidad` double(9,2) DEFAULT NULL,
  `unidadmed` char(2) DEFAULT NULL,
  `pcosto` double(12,2) DEFAULT NULL,
  `mov` smallint(1) DEFAULT NULL,
  `row_vta` int(11) DEFAULT NULL,
  PRIMARY KEY (`row_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
*/
 MSQuery( oApl:oMySql:hConnect,  "DROP TABLE " + aLS[6] )
 MSQuery( oApl:oMySql:hConnect,"CREATE TABLE " + aLS[6] + " LIKE promedio" )
/* 1.entradas, 2.salidas, 3.devol_e, 4.devol_s, 5.ajustes_e, 6.ajustes_s, 7.devolcli
               COMPRAS       DEVOLUCIONES       VENTAS        N.CREDITO     AJUSTES
1. fecha       c.fecingre    c.fecha            c.fechoy      c.fecha       d.fecha
2. codigo      d.codigo      d.codigo           d.codigo      d.codigo      d.codigo
3. cantidad    d.cantidad    d.cantidad         d.cantidad    d.cantidad    d.cantidad
4. unidadmed   d.unidadmed   d.unidadmed        d.unidadmed   d.unidadmed   d.unidadmed
5. pcosto      d.pcosto      d.pcosto           d.pcosto      d.pcosto      d.pcosto
6. mov         1             u.tipo_ajust(3,4)  2             7             t.tipo_ajust(5,6)
7. row_vta                                      d.row_id                    d.row_id
*/
 aMV := "INSERT INTO " + aLS[6] + " (fecha, codigo, cantidad, unidadmed, pcosto, mov) "
cQry := aMV + ;
        "SELECT c.fecingre, d.codigo, d.cantidad, "         +;
               "d.unidadmed, d.pcosto, 1 "                  +;
        "FROM cadartid d, cadartic c "                      +;
        "WHERE d.ingreso = c.ingreso"                       +;
         " AND (d.indica <> 'B' OR d.indica IS NULL) " + cGI+;
         " AND c.empresa  = "  + LTRIM(STR(oApl:nEmpresa))  +;
         " AND c.fecingre >= " + xValToChar( aLS[1] )       +;
         " AND c.fecingre <= " + xValToChar( aLS[2] )
//MsgInfo( cQry,"1_Compras" )
 MSQuery( oApl:oMySql:hConnect,cQry )

cQry := aMV + ;
        "SELECT c.fecha, d.codigo, d.cantidad, d.unidadmed,"+;
              " d.pcosto, u.tipo_ajust "                    +;
        "FROM caddevod d, cadtipos u, caddevoc c "          +;
        "WHERE d.empresa = c.empresa"                       +;
         " AND d.numero  = c.numero"  + cGI                 +;
         " AND u.tipo    = d.causadev"                      +;
         " AND u.clase   = 'Devolucion'"                    +;
         " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa))    +;
         " AND c.fecha  >= " + xValToChar( aLS[1] )         +;
         " AND c.fecha  <= " + xValToChar( aLS[2] )
//MsgInfo( cQry,"2_Devoluciones" )
 MSQuery( oApl:oMySql:hConnect,cQry )

cQry := STRTRAN( aMV,")",", row_vta)" ) + ;
        "SELECT c.fechoy, d.codigo, d.cantidad, d.unidadmed"+;
             ", d.pcosto, 2, d.row_id "                     +;
        "FROM cadfactd d, cadfactc c "                      +;
        "WHERE d.empresa = c.empresa"                       +;
         " AND d.numfac  = c.numfac"                        +;
         " AND d.tipo    = c.tipo"    + cGI                 +;
         " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa))    +;
         " AND c.fechoy >= " + xValToChar( aLS[1] )         +;
         " AND c.fechoy <= " + xValToChar( aLS[2] )         +;
         " AND c.tipo   <> 'Z' AND c.indicador <> 'A'"
//MsgInfo( cQry,"3_Ventas" )
 MSQuery( oApl:oMySql:hConnect,cQry )

cQry := aMV + ;
        "SELECT c.fecha, d.codigo, d.cantidad, d.unidadmed,"+;
              " d.pcosto, 7 "                               +;
        "FROM cadnotad d, cadnotac c "                      +;
        "WHERE d.empresa = c.empresa"                       +;
         " AND d.numero  = c.numero"                        +;
         " AND d.tipo    = c.tipo" + cGI                    +;
         " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa))    +;
         " AND c.fecha  >= " + xValToChar( aLS[1] )         +;
         " AND c.fecha  <= " + xValToChar( aLS[2] )
//MsgInfo( cQry,"4_N.Credito" )
 MSQuery( oApl:oMySql:hConnect,cQry )

cQry := STRTRAN( aMV,")",", row_vta)" ) + ;
        "SELECT d.fecha, d.codigo, d.cantidad, "           +;
           "d.unidadmed, d.pcosto, t.tipo_ajust, d.row_id "+;
        "FROM cadtipos t, cadajust d "                     +;
        "WHERE t.clase   = 'Ajustes'"                      +;
         " AND d.tipo    = t.tipo"                         +;
         " AND d.empresa = " + LTRIM(STR(oApl:nEmpresa))   +;
         " AND d.fecha  >= " + xValToChar( aLS[1] )        +;
         " AND d.fecha  <= " + xValToChar( aLS[2] ) + cGI
//MsgInfo( cQry,"5_Ajustes" )
 MSQuery( oApl:oMySql:hConnect,cQry )

 aMV := { 0,0,0,0,0,0,0,0,0,"",0,0 }
cGI  := NtChr( aLS[1]-1,"1" )   // ANOMES Anterior
cQry := "SELECT codigo, cantidad, pcosto, unidadmed, mov, row_vta, row_id FROM " + aLS[6] +;
        " ORDER BY codigo, fecha"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL  := MSNumRows( hRes )) > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
   SaldoInv( aRes[1],cGI )
   aMV[08] := oApl:aInvme[1]
   aMV[09] := oApl:aInvme[2]
   aMV[10] := aRes[1]
   oApl:oInv:Seek( {"codigo",aRes[1]} )
EndIf

cCod := " WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
          " AND codigo  = '[COD]'"                     +;
          " AND anomes  = '" + aGF[4] + "'"
While nL > 0
   aRes[2] := AFormula( aRes[2],aRes[4],oApl:oInv:UNIDADMED,oApl:oInv:CODCON )
   If Rango( aRes[5],{5,6} )
      If aRes[3] <= 0 .AND. aRes[6] > 0
         aRes[3] := aMV[9]
         cQry := "UPDATE cadajust SET pcosto = " + LTRIM(STR(aMV[9])) +;
                 " WHERE row_id = " + LTRIM(STR(aRes[6]))
         If (nCan := RunSql1( cQry,"ActuSaldo" )) > 0
            aMV[12] += nCan
            cQry := "UPDATE " + aLS[6] +;
                    " SET codigo = 'AJUSTE' WHERE row_id = " + LTRIM(STR(aRes[7]))
            MSQuery( oApl:oMySql:hConnect,cQry )
         EndIf
      EndIf
   EndIf
   If Rango( aRes[5],{1,3,5,7} )
         aLS[4] := ABS( aMV[8] ) + aRes[2]
      If aLS[4]  > 0
         aMV[9] := (ABS( aMV[8] )*aMV[9] + aRes[2]*aRes[3]) / aLS[4]
         aMV[9] := ROUND( aMV[9],2 )
      EndIf
      aMV[8] += aRes[2]
   Else
      aMV[8] -= aRes[2]
   EndIf
      aMV[ aRes[5] ] += aRes[2]
   If aLS[3] > 0 .AND. aRes[5] == 2 .AND. aRes[3] # aMV[9]
      cQry := "UPDATE cadfactd SET pcosto = " + LTRIM(STR(aMV[9])) +;
             " WHERE row_id = " + LTRIM(STR(aRes[6]))
      If (nCan := RunSql1( cQry,"ActuSaldo" )) > 0
         aMV[11] += nCan
         cQry := "UPDATE " + aLS[6] +;
                 " SET codigo = 'VENTAS' WHERE row_id = " + LTRIM(STR(aRes[7]))
         MSQuery( oApl:oMySql:hConnect,cQry )
      EndIf
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aMV[10] # aRes[1]
      If aGF[1]
         cGI := "PC.A=" + TRANSFORM(aGF[2],"999,999,999.99") + CRLF +;
                "PC.N=" + TRANSFORM(aMV[9],"999,999,999.99") + CRLF +;
                "EX.N=" + TRANSFORM(aMV[8],"999,999,999.99999")
         If !MsgNoYes( cGI,"Cambio el Promedio" )
            EXIT
         EndIf
      EndIf
      If Buscar( "SELECT 1 FROM cadinvme" + STRTRAN( cCod,"[COD]",TRIM(aMV[10]) ),;
                 "CM",,8,,4 ) == 0
         cQry := "INSERT INTO cadinvme VALUES( NULL, " + LTRIM(STR(oApl:nEmpresa))+;
                                                 ", '" +  TRIM(aMV[10])           +;
                                                "', '" +       aGF[4]             +;
                                                "', "  + LTRIM(STR(aMV[8],12,5))  +;
                                                 ", "  + LTRIM(STR(aMV[1],12,5))  +;
                                                 ", "  + LTRIM(STR(aMV[2],12,5))  +;
                                                 ", "  + LTRIM(STR(aMV[5],12,5))  +;
                                                 ", "  + LTRIM(STR(aMV[6],12,5))  +;
                                     ", NULL, NULL, "  + LTRIM(STR(aMV[3],12,5))  +;
                                                 ", "  + LTRIM(STR(aMV[4],12,5))  +;
                                                 ", "  + LTRIM(STR(aMV[7],12,5))  +;
                                                 ", "  + LTRIM(STR(aMV[9])) + " )"
      Else
         cQry := "UPDATE cadinvme SET entradas = " + LTRIM(STR(aMV[1],12,5)) +;
                                    ", salidas = " + LTRIM(STR(aMV[2],12,5)) +;
                                    ", devol_e = " + LTRIM(STR(aMV[3],12,5)) +;
                                    ", devol_s = " + LTRIM(STR(aMV[4],12,5)) +;
                                  ", ajustes_e = " + LTRIM(STR(aMV[5],12,5)) +;
                                  ", ajustes_s = " + LTRIM(STR(aMV[6],12,5)) +;
                                   ", devolcli = " + LTRIM(STR(aMV[7],12,5)) +;
                                 ", existencia = " + LTRIM(STR(aMV[8],12,5)) +;
                                     ", pcosto = " + LTRIM(STR(aMV[9]))      +;
                 STRTRAN( cCod,"[COD]",TRIM(aMV[10]) )
      EndIf
      MSQuery( oApl:oMySql:hConnect,cQry )
      If aLS[3] == 0
         cQry := "UPDATE cadfactd v, " + aLS[6] + " m SET v.pcosto = " + LTRIM(STR(aMV[9])) +;
                " WHERE m.row_vta  = v.row_id AND m.row_vta <> 0 AND m.mov = 2"
         If (nCan := RunSql1( cQry,"ActuSaldo" )) > 0
            aMV[11] += nCan
            cQry := "UPDATE " + aLS[6] +;
                    " SET codigo = 'VENTAS' WHERE row_vta <> 0 AND mov = 2"
            MSQuery( oApl:oMySql:hConnect,cQry )
         EndIf
      EndIf
      SaldoInv( aRes[1],cGI )
      AFILL( aMV,0,1,7 )
      aMV[08] := oApl:aInvme[1]
      aMV[09] := oApl:aInvme[2]
      aMV[10] := aRes[1]
      oApl:oInv:Seek( {"codigo",aRes[1]} )
      oApl:oWnd:SetMsg( "CODIGO = "+aMV[10] )
   EndIf
EndDo
MSFreeResult( hRes )
If aMV[11] > 0 .OR. aMV[12] > 0
   aGF[1] := oApl:Abrir( "cgemovc" ,"empresa, ano_mes, control",.t.,,1 )
   aGF[2] := oApl:Abrir( "cgemovd" ,"empresa, ano_mes, control",.t.,,100 )
   aGF[3] := Cuentas( 3,1 )
   nCan   := LEN( aGF[3] )
   If nCan >= 10 .AND. aMV[11] > 0
      oApl:oWnd:SetMsg( "Actualizo Ventas" )
      cQry := "SELECT d.numfac, d.tipo FROM cadfactd d, " + aLS[6]   +;
              " m WHERE m.row_vta = d.row_id AND m.codigo = 'VENTAS'"+;
              " GROUP BY d.numfac, d.tipo"
      aRes := Buscar( cQry,"CM",,9 )
      FOR nL := 1 TO LEN( aRes )
         If oApl:oFac:Seek( {"empresa",oApl:nEmpresa,"numfac",aRes[nL,1],"tipo",aRes[nL,2]} )
            If oApl:oFac:FECHOY >= CTOD("01.01.2008")
               oApl:oNit:Seek( {"codigo_nit",oApl:oFac:CODIGO_NIT} )
               oApl:cPer := NtChr( oApl:oFac:FECHOY,"1" )
               oApl:Tipo := oApl:oFac:TIPO
               ContaVta( aGF[1],aGF[2],.f.,aGF[3] )
            EndIf
         EndIf
      NEXT nL
   EndIf

   If nCan >= 10 .AND. aMV[12] > 0
      //aRes   := ACLONE( aGF[3] )
      //aGF[3] := {}
      //AEVAL( aRes, {| x | AADD( aGF[3], x[1] ) },10 )
      //AEVAL( aRes, {| x | AADD( aGF[3], LEFT(x[1],6) ) },10 )
      aGF[3] := Cuentas( 13,1 )
      If LEN( aGF[3] ) > 0
         cQry := STRTRAN( LEFT( oApl:oEmp:NIT,AT("-",oApl:oEmp:NIT)-1 ),".","" )
         oApl:oNit:Seek( {"codigo",INT(VAL(cQry))} )
         cQry := "SELECT a.numero FROM cadajust a, " + aLS[6]   +;
         " m WHERE m.row_vta = a.row_id AND m.codigo = 'AJUSTE'"+;
                 " GROUP BY a.numero"
         aRes := Buscar( cQry,"CM",,9 )
         FOR nL := 1 TO LEN( aRes )
            ContAjuste( aGF[1],aGF[2],aRes[nL],aGF[3] )
         NEXT nL
      EndIf
   EndIf
   aGF[1]:Destroy()
   aGF[2]:Destroy()
EndIf

RETURN

//------------------------------------//
STATIC PROCEDURE Descuadre( aLS,oDlg )
   LOCAL aGF, cQry, nCon, nCan
   LOCAL aRes, hRes, nL, oTB, oRpt
oTB := oApl:Abrir( "cadsaldo","codigo",,.t. )
oDlg:SetText( "<< ESPERE >> ARMANDO LOS DATOS " )

cQry := "SELECT d.codigo, SUM(d.cantidad), d.unidadmed, i.unidadmed, i.codcon "+;
        "FROM cadinven i, cadartid d, cadartic c "        +;
        "WHERE i.codigo    = d.codigo"                    +;
         " AND (d.indica <> 'B' OR d.indica IS NULL) "    +;
         " AND c.ingreso   = d.ingreso"                   +;
         " AND c.empresa   = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fecingre >= " + xValToChar( aLS[1] )     +;
         " AND c.fecingre <= " + xValToChar( aLS[2] )     +;
        " GROUP BY d.codigo, d.unidadmed"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
aLS[6] := STR(nL,5) + " ARTIC" ; oDlg:Update()
While nL > 0
   aRes := MyReadRow( hRes )
   If LEN( aRes[1] ) >= oApl:oEmp:LENCOD
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      SaldosMov( aRes,"entradas" )
   EndIf
   nL --
EndDo
MSFreeResult( hRes )

cQry := "SELECT d.codigo, d.cantidad, d.unidadmed,"       +;
              " d.causadev, u.tipo_ajust "                +;
        "FROM caddevod d, cadtipos u, caddevoc c "        +;
        "WHERE d.empresa = c.empresa"                     +;
         " AND d.numero  = c.numero"                      +;
         " AND u.tipo    = d.causadev"                    +;
         " AND u.clase   = 'Devolucion'"                  +;
         " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa))  +;
         " AND c.fecha  >= " + xValToChar( aLS[1] )       +;
         " AND c.fecha  <= " + xValToChar( aLS[2] )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
aLS[6] := STR(nL,5) + " DEVOLUCION" ; oDlg:Update()
While nL > 0
   aRes := MyReadRow( hRes )
   If LEN( aRes[1] ) >= oApl:oEmp:LENCOD
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      If aRes[5] == 2
         cQry := "devol_e"
      ElseIf aRes[5] == 4
         cQry := "devol_s"
    //Else
    //   cQry := "devol_e"
      Else
         cQry := "devolcli"
      EndIf
      aRes[4] := ""
      SaldosMov( aRes,cQry )
   EndIf
   nL --
EndDo
MSFreeResult( hRes )

cQry := "SELECT d.codigo, d.cantidad, d.unidadmed, i.unidadmed, i.codcon "+;
        "FROM cadinven i, cadfactd d, cadfactc c "      +;
        "WHERE i.codigo  = d.codigo"                    +;
         " AND c.empresa = d.empresa"                   +;
         " AND c.numfac  = d.numfac"                    +;
         " AND c.tipo    = d.tipo"                      +;
         " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fechoy >= " + xValToChar( aLS[1] )     +;
         " AND c.fechoy <= " + xValToChar( aLS[2] )     +;
         " AND c.tipo   <> 'Z' AND c.indicador <> 'A'"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
aLS[6] := STR(nL,5) + " VENTAS" ; oDlg:Update()
While nL > 0
   aRes := MyReadRow( hRes )
   If LEN( aRes[1] ) >= oApl:oEmp:LENCOD
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      SaldosMov( aRes,"salidas" )
   EndIf
   nL --
EndDo
MSFreeResult( hRes )

cQry := "SELECT d.codigo, d.cantidad, d.unidadmed, i.unidadmed, i.codcon "+;
        "FROM cadinven i, cadnotad d, cadnotac c "      +;
        "WHERE i.codigo  = d.codigo"                    +;
         " AND c.empresa = d.empresa"                   +;
         " AND c.numero  = d.numero"                    +;
         " AND c.tipo    = d.tipo"                      +;
         " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fecha  >= " + xValToChar( aLS[1] )     +;
         " AND c.fecha  <= " + xValToChar( aLS[2] )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
aLS[6] := STR(nL,5) + " N.CREDITO" ; oDlg:Update()
While nL > 0
   aRes := MyReadRow( hRes )
   If LEN( aRes[1] ) >= oApl:oEmp:LENCOD
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      SaldosMov( aRes,"devolcli" )
   EndIf
   nL --
EndDo
MSFreeResult( hRes )

cQry := "SELECT a.codigo, a.cantidad, a.unidadmed, t.tipo_ajust, 1 "+;
        "FROM cadtipos t, cadajust a "                  +;
        "WHERE t.clase   = 'Ajustes'"                   +;
         " AND a.tipo    = t.tipo"                      +;
         " AND a.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND a.fecha  >= " + xValToChar( aLS[1] )     +;
         " AND a.fecha  <= " + xValToChar( aLS[2] )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
aLS[6] := STR(nL,5) + " AJUSTES" ; oDlg:Update()
While nL > 0
   aRes := MyReadRow( hRes )
   If LEN( aRes[1] ) >= oApl:oEmp:LENCOD
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      If aRes[4] == 5
         cQry := "ajustes_e"
      Else
         cQry := "ajustes_s"
      EndIf
      aRes[4] := ""
      SaldosMov( aRes,cQry )
   EndIf
   nL --
EndDo
MSFreeResult( hRes )

aLS[3] := NtChr( aLS[1]-1,"1" )   // ANOMES Anterior
aLS[4] := NtChr( aLS[2],"1" )     // ANOMES Final
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"DESCUADRE DE INVENTARIO ", NtChr( aLS[2],"3" ),SPACE(36) +;
         "EXISTENCIA     TOTAL        TOTAL   DEVOLUCION  DEVOLUCION     AJUSTE      AJUSTE  DEVOLUCION     SALDO ",;
         "C O D I G O- -----DESCRIPCION-----  MES ANTER.    ENTRADAS      VENTAS"+;
         "   ENTRADAS     SALIDAS     ENTRADAS     SALIDAS   CLIENTE      ACTUAL"},.t.,1,2 )
cQry := "SELECT s.codigo, i.descrip, s.entradas, s.salidas, s.devol_e, s.devol_s, "+;
                  "s.ajustes_e, s.ajustes_s, s.devolcli, s.existencia, s.anomes "  +;
        "FROM cadinven i, cadinvme s "                           +;
        "WHERE i.codigo  = s.codigo"                             +;
         " AND s.empresa = " + LTRIM(STR(oApl:nEmpresa))         +;
         " AND s.anomes = (SELECT MAX(m.anomes) FROM cadinvme m "+;
                          "WHERE m.empresa = s.empresa"          +;
                           " AND m.codigo  = s.codigo"           +;
                           " AND m.anomes <= '" + aLS[4] + "')"  +;
         " AND s.anomes = '" + aLS[4]                            +;
        "' ORDER BY s.codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aRes[11] == aLS[4]
      aGF := { SaldoInv( aRes[01],aLS[3],1 ),;
               aRes[03],aRes[04],aRes[05],aRes[06],aRes[07],aRes[08],aRes[09],aRes[10] }
   Else
      aGF := { aRes[10],0,0,0,0,0,0,0,aRes[10] }
   EndIf
   oTB:Seek( {"codigo",aRes[1]} )
   If oTB:ENTRADAS  # aGF[2] .OR. oTB:SALIDAS   # aGF[3] .OR.;
      oTB:DEVOL_E   # aGF[4] .OR. oTB:DEVOL_S   # aGF[5] .OR.;
      oTB:AJUSTES_E # aGF[6] .OR. oTB:AJUSTES_S # aGF[7] .OR.;
      oTB:DEVOLCLI  # aGF[8]
      nCan := aGF[1] + aGF[2] - aGF[3] + aGF[4] - aGF[5] + aGF[6] - aGF[7] + aGF[8]
      nCon := aGF[1] + oTB:ENTRADAS  - oTB:SALIDAS   + oTB:DEVOL_E - oTB:DEVOL_S +;
                       oTB:AJUSTES_E - oTB:AJUSTES_S + oTB:DEVOLCLI
      oRpt:Titulo( 141 )
      oRpt:Say( oRpt:nL, 00,aRes[1] )
      oRpt:Say( oRpt:nL, 13,aRes[2],24 )
      oRpt:Say( oRpt:nL, 38,TRANSFORM(aGF[1],"999,999") )
      oRpt:Say( oRpt:nL, 50,TRANSFORM(aGF[2],"@Z 999,999") )
      oRpt:Say( oRpt:nL, 62,TRANSFORM(aGF[3],"@Z 999,999") )
      oRpt:Say( oRpt:nL, 74,TRANSFORM(aGF[4],"@Z 999,999") )
      oRpt:Say( oRpt:nL, 86,TRANSFORM(aGF[5],"@Z 999,999") )
      oRpt:Say( oRpt:nL, 98,TRANSFORM(aGF[6],"@Z 999,999") )
      oRpt:Say( oRpt:nL,110,TRANSFORM(aGF[7],"@Z 999,999") )
      oRpt:Say( oRpt:nL,122,TRANSFORM(aGF[8],"@Z 999,999") )
      oRpt:Say( oRpt:nL,134,TRANSFORM(aGF[9],"999,999") )
      oRpt:Say( oRpt:nL,142,If(nCan # aGF[9], "X", "" ) )
      oRpt:nL ++
      oRpt:Say( oRpt:nL, 50,TRANSFORM(oTB:ENTRADAS ,"@Z 999,999") )
      oRpt:Say( oRpt:nL, 62,TRANSFORM(oTB:SALIDAS  ,"@Z 999,999") )
      oRpt:Say( oRpt:nL, 74,TRANSFORM(oTB:DEVOL_E  ,"@Z 999,999") )
      oRpt:Say( oRpt:nL, 86,TRANSFORM(oTB:DEVOL_S  ,"@Z 999,999") )
      oRpt:Say( oRpt:nL, 98,TRANSFORM(oTB:AJUSTES_E,"@Z 999,999") )
      oRpt:Say( oRpt:nL,110,TRANSFORM(oTB:AJUSTES_S,"@Z 999,999") )
      oRpt:Say( oRpt:nL,122,TRANSFORM(oTB:DEVOLCLI ,"@Z 999,999") )
      oRpt:Say( oRpt:nL,134,TRANSFORM(nCon,"999,999") )
      oRpt:nL ++
   EndIf
   If oTB:lOK
      oTB:ANOMES_AN := "SI"
      oTB:Update(.f.,1)
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
oTB:Seek( "anomes_an <> 'SI'","CM" )
WHILE !oTB:Eof()
   oRpt:Titulo( 141 )
   oRpt:Say( oRpt:nL, 00,oTB:CODIGO )
   oRpt:Say( oRpt:nL, 50,TRANSFORM(oTB:ENTRADAS ,"@Z 999,999") )
   oRpt:Say( oRpt:nL, 62,TRANSFORM(oTB:SALIDAS  ,"@Z 999,999") )
   oRpt:Say( oRpt:nL, 74,TRANSFORM(oTB:DEVOL_E  ,"@Z 999,999") )
   oRpt:Say( oRpt:nL, 86,TRANSFORM(oTB:DEVOL_S  ,"@Z 999,999") )
   oRpt:Say( oRpt:nL, 98,TRANSFORM(oTB:AJUSTES_E,"@Z 999,999") )
   oRpt:Say( oRpt:nL,110,TRANSFORM(oTB:AJUSTES_S,"@Z 999,999") )
   oRpt:Say( oRpt:nL,122,TRANSFORM(oTB:DEVOLCLI ,"@Z 999,999") )
   oRpt:nL ++
   oTB:Skip(1):Read()
   oTB:xLoad()
ENDDO
oRpt:NewPage()
oRpt:End()
oTB:DropIndex( "codigo" )
oTB:Destroy()
MSQuery( oApl:oMySql:hConnect,"DROP TABLE cadsaldo" )
oApl:oDb:GetTables()
RETURN

//------------------------------------//
STATIC PROCEDURE Despcosto( aLS,oDlg )
   LOCAL aGF, aRes, cQry, hRes, nL, oTB, oRpt
If aLS[3] == 3
   cQry := "SELECT c.tipo, c.numfac, d.codigo, i.descrip, d.cantidad, d.unidadmed,"+;
                 " d.precioven, d.pcosto, i.unidadmed, i.codcon, i.pcosto "        +;
           "FROM cadfactc c, cadfactd d LEFT JOIN cadinven i "+;
             " ON d.codigo  = i.codigo "                    +;
           "WHERE c.empresa = d.empresa"                    +;
            " AND c.numfac  = d.numfac"                     +;
            " AND c.tipo    = d.tipo"                       +;
            " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
            " AND c.fechoy >= " + xValToChar( aLS[1] )      +;
            " AND c.fechoy <= " + xValToChar( aLS[2] )      +;
            " ORDER BY c.fechoy, c.numfac"
Else
   cQry := "SELECT 'A', d.numero, d.codigo, i.descrip, d.cantidad, d.unidadmed,"+;
                 " d.tipo, d.pcosto, i.unidadmed, i.codcon, i.pcosto "          +;
           "FROM cadajust d LEFT JOIN cadinven i "          +;
             " ON d.codigo  = i.codigo "                    +;
           "WHERE d.empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
            " AND d.fecha  >= " + xValToChar( aLS[1] )      +;
            " AND d.fecha  <= " + xValToChar( aLS[2] )      +;
            " ORDER BY d.numero"
EndIf
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes ) ; RETURN
EndIf
oTB := oApl:Abrir( "cadsaldo","codigo",,.t. )
oDlg:SetText( "<< ESPERE >> ARMANDO LOS DATOS " )
aLS[4] := NtChr( aLS[2],"1" )
cQry := "INSERT INTO cadsaldo (codigo, anomes_ac, existe_ac, pcosto_ac) "+;
        "SELECT s.codigo, s.anomes, s.existencia, s.pcosto "     +;
        "FROM cadinvme s "                                       +;
        "WHERE s.empresa = " + LTRIM(STR(oApl:nEmpresa))         +;
         " AND s.anomes = (SELECT MAX(m.anomes) FROM cadinvme m "+;
                          "WHERE m.empresa = s.empresa"          +;
                           " AND m.codigo  = s.codigo"           +;
                           " AND m.anomes <= '" + aLS[4] + "')"
 MSQuery( oApl:oMySql:hConnect,cQry )

aGF  := { 0,0,0,0,0,0,"99,999,999.99" }
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"COMPARACION PRECIO COSTO ",NtChr( aLS[2],"3" ),+;
          "----FACTURA  CODIGO----  DESCRIPCION--------------  --CANTIDAD      VALO" +;
          "R VENTA    TOTAL COSTO    VALOR COSTO       PROMEDIO"},.t.,1,2 )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   oTB:Seek( {"codigo",aRes[3]} )
   aGF[1] := AFormula( aRes[5],aRes[6],aRes[09],aRes[10] )
   aGF[2] := aGF[1] * aRes[08]
   aGF[3] += aRes[08]
   aGF[4] += aGF[2]
   aGF[5] += aRes[08]
   aGF[6] += oTB:PCOSTO_AC
   oRpt:Titulo( 124 )
   oRpt:Say( oRpt:nL, 00,aRes[01] + STR(aRes[02],10) )
   oRpt:Say( oRpt:nL, 13,aRes[03] )
   oRpt:Say( oRpt:nL, 25,aRes[04],25 )
   oRpt:Say( oRpt:nL, 52,TRANSFORM(aRes[05],   "999,999.99" ))
   oRpt:Say( oRpt:nL, 63,aRes[06] )
   oRpt:Say( oRpt:nL, 65,If( aRes[6] # aRes[9], "*"+aRes[9], "" ) )
   oRpt:Say( oRpt:nL, 69,TRANSFORM(aRes[07],"99,999,999" ))
   oRpt:Say( oRpt:nL, 81,TRANSFORM( aGF[02]     ,aGF[7] ))
   oRpt:Say( oRpt:nL, 94,If( aRes[7] > aGF[2], "", "+" ) )
   oRpt:Say( oRpt:nL, 96,TRANSFORM(aRes[08]     ,aGF[7] ))
   oRpt:Say( oRpt:nL,109,If( aRes[08] < oTB:PCOSTO_AC, "", "+" ) )
   oRpt:Say( oRpt:nL,111,TRANSFORM(oTB:PCOSTO_AC,aGF[7] ))
   oRpt:nL++
   nL --
EndDo
MSFreeResult( hRes )
   oRpt:Titulo( 124 )
   oRpt:Say(  oRpt:nL, 00,REPLICATE("_",124) )
   oRpt:Say(++oRpt:nL, 25,"TOTALES  ==> " )
   oRpt:Say(  oRpt:nL, 68,TRANSFORM(aGF[3],"999,999,999" ))
   oRpt:Say(  oRpt:nL, 81,TRANSFORM(aGF[4],aGF[7] ))
   oRpt:Say(  oRpt:nL, 96,TRANSFORM(aGF[5],aGF[7] ))
   oRpt:Say(  oRpt:nL,111,TRANSFORM(aGF[6],aGF[7] ))
   oRpt:NewPage()
   oRpt:End()
oTB:DropIndex( "codigo" )
oTB:Destroy()
MSQuery( oApl:oMySql:hConnect,"DROP TABLE cadsaldo" )
oApl:oDb:GetTables()
RETURN

//------------------------------------//
STATIC PROCEDURE SaldosMov( aRes,cCam,cIns )
  LOCAL cQry := " WHERE codigo = '" + ALLTRIM(aRes[1]) + "'"
If Buscar( "SELECT 1 FROM cadsaldo" + cQry,"CM",,8,,4 ) == 0
   cIns := "INSERT INTO cadsaldo VALUES( NULL, '" + ALLTRIM(aRes[1]) +;
             "', NULL, 0, 0, NULL, 0, 0, NULL, 0, 0, 0, 0, 0, 0, 0, 0)"
   Guardar( cIns,"cadsaldo" )
EndIf
If EMPTY( aRes[4] )
   oApl:oInv:Seek( {"codigo",aRes[1]} )
   aRes[4] := oApl:oInv:UNIDADMED
   aRes[5] := oApl:oInv:CODCON
EndIf
   aRes[2] := AFormula( aRes[2],aRes[3],aRes[4],aRes[5] )
   cQry := "UPDATE cadsaldo SET " + cCam + " = " + cCam + " + " +;
            LTRIM(STR(aRes[2],12,5)) + cQry
   Guardar( cQry,"cadsaldo" )
RETURN