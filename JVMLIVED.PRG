// Programa.: JVMLIVED.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo ventas diarias de las Empresas
#include "FiveWin.ch"
#include "Utilprn.CH"
#include "btnget.ch"

MEMVAR oApl

PROCEDURE CaoLiVed( nOpc )
   LOCAL aVT, cOpc, oA, oCg, oDlg, oGet := ARRAY(13)
   DEFAULT nOpc := 1
 oA := TLived() ; oA:New()
oCg := TCat()   ; oCg:New()
cOpc:= If( nOpc == 3, "RESUMEN POR CODIGO [S/N]", "DIFERENCIAS EN PRECIOS [S/N]" )
aVT := { { {|| oA:ListoVen() },"Listar Ventas Diarias" }  ,;
         { {|| oA:ListoCar() },"Listo Resumen Diario" }   ,;
         { {|| oA:ListoRes() },"Listo Ventas con Codigo" },;
         { {|| oA:ListoTIZ() },"Listo Resumen Diario" },"" }
DEFINE DIALOG oDlg TITLE aVT[nOpc,2] FROM 0, 0 TO 19,50
   @ 02, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 86,10
   @ 02, 88 GET oGet[1] VAR oA:aLS[1] OF oDlg  SIZE 40,10 PIXEL
   @ 14, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 86,10
   @ 14, 88 GET oGet[2] VAR oA:aLS[2] OF oDlg ;
      VALID oA:aLS[2] >= oA:aLS[1]            ;
      SIZE 40,10 PIXEL
// @ 26, 00 SAY "DESEA UN RESUMEN [S/N/U]" OF oDlg RIGHT PIXEL SIZE 86,10
// @ 26, 88 GET oGet[3] VAR oA:aLS[3] OF oDlg PICTURE "!";
//    VALID If( oA:aLS[3] $ "NSU", .t., .f. ) ;
//    WHEN nOpc #  4         SIZE 08,10 PIXEL
   @ 26, 00 SAY "DESEA UN RESUMEN" OF oDlg RIGHT PIXEL SIZE 86,10
   @ 26,88 COMBOBOX oGet[3] VAR oA:aLS[3] ITEMS {"Sin Resumen","Con Resumen","Retenciones","Utilidad"};
      SIZE 48,90 OF oDlg PIXEL  WHEN nOpc #  4
   @ 38, 00 SAY cOpc                       OF oDlg RIGHT PIXEL SIZE 86,10
   @ 38, 88 GET oGet[4] VAR oA:aLS[4] OF oDlg PICTURE "!";
      VALID If( oA:aLS[4] $ "NS", .t., .f. ) ;
      WHEN nOpc #  2         SIZE 08,10 PIXEL
   @ 50, 00 SAY "PAGINA INICIAL"           OF oDlg RIGHT PIXEL SIZE 86,10
   @ 50, 88 GET oGet[5] VAR oA:aLS[5] OF oDlg PICTURE "999";
      VALID Rango( oA:aLS[5],1,999 ) ;
      WHEN nOpc #  4         SIZE 24,10 PIXEL
   @ 62, 00 SAY "TIPO DE FACTURA"           OF oDlg RIGHT PIXEL SIZE 86,10
   @ 62, 88 COMBOBOX oGet[6] VAR oA:aLS[6] ITEMS oA:aTF;
      SIZE 40,99 OF oDlg PIXEL
   @ 74, 00 SAY "LINEA por Default TODAS" OF oDlg RIGHT PIXEL SIZE 86,10
   @ 74, 88 BTNGET oGet[7] VAR oA:aLS[10] OF oDlg PICTURE "@!"         ;
      ACTION EVAL({|| If(oCg:Mostrar( ,,oA:aLS[10] ), ( oA:aLS[10] :=  ;
                         oCg:oDb:LINEA, oGet[7]:Refresh(), ), )} )     ;
      VALID EVAL( {|| If( EMPTY( oA:aLS[10] ), .t.                    ,;
                     (If( oCg:Buscar( oA:aLS[10],"linea",.t. )        ,;
                        ( oGet[8]:Settext( oCg:oDb:NOMBRE), .t. )     ,;
                        ( MsgStop("Esta Línea no Existe"),.f. ) ))) } );
      WHEN (nOpc = 3)  SIZE 30,10 PIXEL  RESOURCE "BUSCAR"
   @ 86,10 SAY oGet[8] VAR aVT[5] OF oDlg PIXEL SIZE 190,14 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 102,00 SAY "TIPO DE IMPRESORA" OF oDlg RIGHT PIXEL SIZE 86,10
   @ 102,88 COMBOBOX oGet[9] VAR oA:aLS[9] ITEMS { "Matriz","Laser" };
      SIZE 48,90 OF oDlg PIXEL
   @ 102,144 CHECKBOX oGet[10] VAR oA:aLS[7] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 114,00 SAY "Escoja la Fuente"  OF oDlg RIGHT PIXEL SIZE 86,10
   @ 114,88 COMBOBOX oGet[11] VAR oA:cFont ITEMS oA:aFont SIZE 80,99 OF oDlg PIXEL;
      WHEN oA:aLS[9] > 1

   @ 128, 50 BUTTON oGet[12] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[12]:Disable(), EVAL( aVT[nOpc,1] ), oDlg:End() ) PIXEL
   @ 128,100 BUTTON oGet[13] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 132, 02 SAY "[JVMLIVED]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
oCg:oDb:Destroy()

RETURN

//------------------------------------//
CLASS TLived FROM TIMPRIME

 DATA aLS, aMV, aTF, nFC

 METHOD NEW( cTit,hRes ) Constructor
 METHOD ListoVen()
 METHOD LaserVen( hRes,nL )
 METHOD ListoDif()
 METHOD ListoDim()
 METHOD LaserDim( hRes,nL )
 METHOD ListoRet()
 METHOD LaserRet( hRes,nL )
 METHOD ListoUti()
 METHOD LaserUti( hRes,nL )
 METHOD ListoCar()
 METHOD ListoRes()
 METHOD LaserRes( hRes,nL )
 METHOD TotalCod()
 METHOD ListoTIZ()
 METHOD LaserTIZ( aCP,aFP,aVT,hRes,nL )
ENDCLASS

//------------------------------------//
METHOD NEW( cTit,hRes ) CLASS TLived
If cTit == NIL
   hRes   := GetDC( 0 )
   ::aFont:= GetFontNames( hRes )
   ::aTF  := TipoFac( .t. )
   ::aLS  := { DATE(),DATE(),1,"N",1,1,.t.,;
               LEN( ::aTF ) -1,oApl:nTFor,"   " }
   ::cFont:= "Arial"
   hRes   := ""
Else
   ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit, cTit ,;
               "DESDE " + NtChr(::aLS[1],"2" ) + " HASTA " + NtChr(::aLS[2],"2" ) }
   If hRes == 1
      cTit := "SELECT c.numfac, c.tipo, n.codigo, n.nombre, c.cliente, " +;
               "c.totalfac, c.totaliva, c.totaldes, c.retfte, c.retiva, "+;
               "c.retica, c.indicador, d.precioven, d.montoiva "+;
              "FROM cadclien n, cadfactc c LEFT JOIN cadfactd d"+;
              " USING( empresa, numfac, tipo ) "                +;
              "WHERE c.empresa = " + LTRIM(STR(oApl:nEmpresa))  +;
               " AND c.fechoy >= " + xValToChar( ::aLS[1] )     +;
               " AND c.fechoy <= " + xValToChar( ::aLS[2] )     + If( ::aLS[6] <= ::aLS[8],;
               " AND c.tipo   = '" + ::aTF[::aLS[6]] + "'", "" )+;
               " AND n.codigo_nit = c.codigo_nit ORDER BY c.numfac"
   ElseIf hRes == 2
      cTit := "SELECT c.tipo, c.numfac, d.codigo, i.descrip, d.cantidad, "+;
               "d.unidadmed, d.precioven, d.desmon, d.montoiva, d.ppubli "+;
              "FROM cadfactc c LEFT JOIN cadfactd d "          +;
               "USING( empresa, numfac, tipo ) "               +;
                              "LEFT JOIN cadinven i "          +;
               "USING( codigo ) "                              +;
              "WHERE c.empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
               " AND c.fechoy >= " + xValToChar( ::aLS[1] )    +;
               " AND c.fechoy <= " + xValToChar( ::aLS[2] )    + If( ::aLS[6] <= ::aLS[8],;
               " AND c.tipo = '" + ::aTF[::aLS[6]] + "'", "" ) +;
               " ORDER BY c.tipo, c.numfac"
   ElseIf hRes == 3
      cTit := "SELECT CONCAT(numfac, tipo) numero, 0, numfac, control, totalfac "+;
              "FROM cadfactc "                                +;
              "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))  +;
               " AND fechoy >= " + xValToChar( ::aLS[1] )     +;
               " AND fechoy <= " + xValToChar( ::aLS[2] )     +;
               " AND indicador <> 'A'"                        +;
              " UNION "                                       +;
              "SELECT d.infb numero, 1, c.comprobant, c.control, SUM(d.valor_cre) "+;
              "FROM cgemovd d, cgemovc c "                    +;
              "WHERE LEFT(d.cuenta,4) IN('2408', '4135')"     +;
               " AND c.empresa = d.empresa"                   +;
               " AND c.ano_mes = d.ano_mes"                   +;
               " AND c.control = d.control"                   +;
               " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND c.fecha  >= " + xValToChar( ::aLS[1] )   +;
               " AND c.fecha  <= " + xValToChar( ::aLS[2] )   +;
               " AND c.fuente  = 3"                           +;
               " AND c.estado <> 2"                           +;
               " GROUP BY c.control, d.infb"                  +;
               " ORDER BY numero"
   ElseIf hRes == 4
      cTit := "SELECT c.numfac, c.tipo, c.cliente, c.totaliva, c.totaldes, c.totalfac"+;
                   ", c.retfte + c.retiva + c.retica + c.retcre, c.indicador, "       +;
                     "d.cantidad, d.unidadmed, d.precioven, d.desmon, d.montoiva, "   +;
                     "d.pcosto, i.unidadmed, i.codcon, i.pcosto "+;
              "FROM cadfactc c LEFT JOIN cadfactd d "            +;
               "USING( empresa, numfac, tipo ) "                 +;
                              "LEFT JOIN cadinven i "            +;
               "USING( codigo ) "                                +;
              "WHERE c.empresa = " + LTRIM(STR(oApl:nEmpresa))   +;
               " AND c.fechoy >= " + xValToChar( ::aLS[1] )      +;
               " AND c.fechoy <= " + xValToChar( ::aLS[2] )      + If( ::aLS[6] <= ::aLS[8],;
               " AND c.tipo    = '"+ ::aTF[::aLS[6]] + "'", "" ) +;
               " ORDER BY c.numfac, c.tipo"
   ElseIf hRes == 5
      cTit := "SELECT p.formapago, p.numfac, p.codbanco, p.numcheque, p.abono, "+;
                     "p.deduccion, p.descuento, p.retencion, c.cliente, c.tipo "+;
              "FROM cadfactc c LEFT JOIN cadpagos p "         +;
               "USING( empresa, numfac, tipo ) "              +;
              "WHERE p.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND p.fecpag >= " + xValToChar( ::aLS[1] )   +;
               " AND p.fecpag <= " + xValToChar( ::aLS[2] )   + If( ::aLS[6] <= ::aLS[8],;
               " AND p.tipo = '" + ::aTF[::aLS[6]] + "'", "" )+;
               " AND p.formapago <= 4"                        +;
               " AND p.indicador <> 'A' ORDER BY p.formapago, p.numfac"
   ElseIf hRes == 6
      cTit := "SELECT c.fechoy, d.tipo, d.numfac, d.codigo, i.descrip, d.cantidad, "+;
                     "d.unidadmed, d.precioven, d.desmon, d.montoiva, d.indicador, "+;
                     "d.fecdev, d.pcosto, i.pcosto, i.unidadmed, i.codcon "         +;
              "FROM cadfactc c LEFT JOIN cadfactd d "          +;
               "USING( empresa, numfac, tipo ) "               +;
                              "LEFT JOIN cadinven i "          +;
               "USING( codigo ) "                              +;
              "WHERE " + ::aLS[10]                             +;
                    "c.empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
               " AND c.fechoy >= " + xValToChar( ::aLS[1] )    +;
               " AND c.fechoy <= " + xValToChar( ::aLS[2] )    + If( ::aLS[6] <= ::aLS[8],;
               " AND c.tipo = '" + ::aTF[::aLS[6]] + "'", "" ) +;
               " ORDER BY c.fechoy, c.numfac"
   ElseIf hRes == 7
      cTit := "SELECT c.tipo, c.numfac, c.totaliva, c.totalfac, c.efectivo"+;
                   ", d.cantidad, d.unidadmed, d.precioven, d.montoiva, "  +;
                     "d.pcosto, i.unidadmed, i.codcon  "       +;
              "FROM cadfactc c LEFT JOIN cadfactd d "          +;
               "USING( empresa, numfac, tipo ) "               +;
                              "LEFT JOIN cadinven i "          +;
               "USING( codigo ) "                              +;
              "WHERE c.empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
               " AND c.fechoy >= " + xValToChar( ::aLS[1] )    +;
               " AND c.fechoy <= " + xValToChar( ::aLS[2] )    +;
               " AND c.indicador <> 'A' ORDER BY c.tipo, c.numfac"
   ElseIf hRes == 8
      cTit := "SELECT d.clasepag, d.formapago, SUM(d.dsctos), SUM(d.comision), "+;
                   "SUM(d.retfte), SUM(d.retiva), SUM(d.retica), SUM(d.valorp) "+;
              "FROM ingresoc c LEFT JOIN ingresod d "          +;
               "USING( ingre_id ) "                            +;
              "WHERE c.empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
               " AND c.fecha  >= " + xValToChar( ::aLS[1] )    +;
               " AND c.fecha  <= " + xValToChar( ::aLS[2] )    +;
               " AND c.estado <> 2"                            +;
               " GROUP BY d.clasepag, d.formapago ORDER BY d.formapago"
      If ::aLS[1] == ::aLS[2]
         ::aEnc[5] := "DIA : "+ NtChr( ::aLS[1],"2" )
      EndIf
   ElseIf hRes == 9
      cTit := "SELECT banco, SUM(valorb) FROM chequesc "       +;
              "WHERE empresa  = " + LTRIM(STR(oApl:nEmpresa))  +;
               " AND fecha   >= " + xValToChar( ::aLS[1] )     +;
               " AND fecha   <= " + xValToChar( ::aLS[2] )     +;
               " AND estado <> 2 GROUP BY banco"
   ElseIf hRes == 10
      cTit := "SELECT n.codigo, n.digito, n.nombre, c.numfac, c.tipo, "    +;
                    "c.totalfac, c.totaliva, c.retfte, c.retiva, c.retica "+;
              "FROM cadfactc c LEFT JOIN cadclien n "           +;
               "USING( codigo_nit ) "                           +;
              "WHERE c.empresa = " + LTRIM(STR(oApl:nEmpresa))  +;
               " AND c.fechoy >= " + xValToChar( ::aLS[1] )     +;
               " AND c.fechoy <= " + xValToChar( ::aLS[2] )     + If( ::aLS[6] <= ::aLS[8],;
               " AND c.tipo   = '" + ::aTF[::aLS[6]] + "'", "" )+;
               " AND c.indicador <> 'A'"                        +;
               " AND (c.retfte > 0 OR c.retiva > 0 OR c.retica > 0)"+;
               " ORDER BY n.codigo, c.numfac"
   EndIf
   hRes := If( MSQuery( oApl:oMySql:hConnect,cTit ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
EndIf
RETURN hRes

//------------------------------------//
METHOD ListoVen() CLASS TLived
   LOCAL aGT, aVT, aFF, aRes, bTL, cQry, hRes, nL, nK, oRpt
//If ::aLS[3] == "N"
If ::aLS[3] == 3
   ::ListoRet()
   RETURN NIL
ElseIf ::aLS[3] == 4
   ::ListoUti()
   RETURN NIL
ElseIf ::aLS[4] == "S"
   ::ListoDif()
   RETURN NIL
ElseIf ::aLS[5] == 999
   ::ListoDim()
   RETURN NIL
EndIf
hRes := ::NEW( "LISTADO DE VENTAS DIARIAS",1 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[9] == 2
   ::LaserVen( hRes,nL )
   RETURN NIL
EndIf
 aGT := { 0,0,0,0,0,0,0,0,0,0 }
 aVT := ARRAY(4,5)
 oRpt := TDosPrint()
 oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4], ::aEnc[5],;
           "                                         --VENTAS--  --VENTAS--    "  +;
           "                                                          CUENTAS  X" ,;
           "FACTURA   NOMBRE DEL CLIENTE             --GRAVADAS  NOGRAVADAS  ----"+;
           "I.V.A.  DESCUENTOS  ---RET.FTE  ---RET.IVA  ---RET.ICA  ----COBRAR"},::aLS[7],::aLS[5],2 )
 AEVAL( aVT, { |x| AFILL( x,0 ) } )
  aRes := MyReadRow( hRes )
 AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aFF := { aRes[01],aRes[01]+1 }
 ::aMV := { aRes[01],aRes[02],If( aRes[3] > 0, aRes[4], aRes[5] ),0,0,0,;
            aRes[06],aRes[07],aRes[08],aRes[09],aRes[10],aRes[11],aRes[12],0,0 }
While nL > 0
   If aRes[12] # "A"
      If aRes[14] > 0
         ::aMV[4] += aRes[13]  //Gravadas
      Else
         ::aMV[5] += aRes[13]
      EndIf
         ::aMV[6] += aRes[14]  //Montoiva
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. ::aMV[1] # aRes[1] .OR. ::aMV[2] # aRes[2]
      ::aMV[14] := ::aMV[07] - ::aMV[10] - ::aMV[11] - ::aMV[12]
      If ::aLS[3] == 1
         oRpt:Titulo( 135 )
         If oRpt:nPage >= oRpt:nPagI
            oRpt:Say( oRpt:nL,00,STR(::aMV[1],6) + ::aMV[2] )
            If ::aMV[13] == "A"
               oRpt:Say( oRpt:nL,08,"** A N U L A D A **" )
            Else
               ::aMV[15] := ::aMV[7] - ::aMV[8] - ::aMV[4] - ::aMV[5]
               oRpt:Say( oRpt:nL, 08,If( ::aMV[15] # 0, "*", "" ) )
               oRpt:Say( oRpt:nL, 10,::aMV[3],28 )
            // oRpt:Say( oRpt:nL, 29,TRANSFORM(::aMV[04],   "99,999,999" ))
               oRpt:Say( oRpt:nL, 41,TRANSFORM(::aMV[04],   "99,999,999" ))
               oRpt:Say( oRpt:nL, 53,TRANSFORM(::aMV[05],   "99,999,999" ))
               oRpt:Say( oRpt:nL, 65,TRANSFORM(::aMV[08],"@Z 99,999,999" ))
               oRpt:Say( oRpt:nL, 77,TRANSFORM(::aMV[09],"@Z 99,999,999" ))
               oRpt:Say( oRpt:nL, 89,TRANSFORM(::aMV[10],"@Z 99,999,999" ))
               oRpt:Say( oRpt:nL,101,TRANSFORM(::aMV[11],"@Z 99,999,999" ))
               oRpt:Say( oRpt:nL,113,TRANSFORM(::aMV[12],"@Z 99,999,999" ))
               oRpt:Say( oRpt:nL,125,TRANSFORM(::aMV[14],"@Z 99,999,999" ))
            EndIf
         EndIf
         oRpt:nL ++
         If ::aMV[13] # "A"
            aGT[02] += ::aMV[04]
            aGT[03] += ::aMV[05]
            aGT[04] += ::aMV[08]
            aGT[05] += ::aMV[09]
            aGT[06] += ::aMV[10]
            aGT[07] += ::aMV[11]
            aGT[08] += ::aMV[12]
            aGT[09] += ::aMV[14]
         EndIf
      EndIf
      If ::aMV[13] # "A"
         nK := ASCAN( ::aTF,::aMV[2] )
         aVT[nK,1] += ::aMV[07]
         aVT[nK,2] += ::aMV[09]
         aVT[nK,3] += ::aMV[04]
         aVT[nK,4] += ::aMV[05]
         aVT[nK,5] += ::aMV[08]
      EndIf
      If ::aLS[6] <= ::aLS[8] .AND. aFF[2] < aRes[1]
            cQry := STR(aFF[2],9)
         If aFF[2] < aRes[1] -1
            cQry += " al" + STR(aRes[1] -1,9)
         EndIf
         AADD( aFF,cQry )
      EndIf
         aFF[2] := aRes[1] + 1
      aGT[01] ++
      ::aMV := { aRes[01],aRes[02],If( aRes[3] > 0, aRes[4], aRes[5] ),0,0,0,;
                 aRes[06],aRes[07],aRes[08],aRes[09],aRes[10],aRes[11],aRes[12],0,0 }
   EndIf
EndDo
 MSFreeResult( hRes )
 cQry := "999,999,999"
If ::aLS[3] == 1
   oRpt:Titulo( 150 )
   oRpt:Say(  oRpt:nL, 00,Replicate("_",135) )
   oRpt:Say(++oRpt:nL, 01,STR(aGT[01],5) + " FACTURAS" )
   oRpt:Say(  oRpt:nL, 40,TRANSFORM(aGT[02],cQry ))
   oRpt:Say(  oRpt:nL, 52,TRANSFORM(aGT[03],cQry ))
   oRpt:Say(  oRpt:nL, 64,TRANSFORM(aGT[04],cQry ))
   oRpt:Say(  oRpt:nL, 76,TRANSFORM(aGT[05],cQry ))
   oRpt:Say(  oRpt:nL, 88,TRANSFORM(aGT[06],cQry ))
   oRpt:Say(  oRpt:nL,100,TRANSFORM(aGT[07],cQry ))
   oRpt:Say(  oRpt:nL,112,TRANSFORM(aGT[08],cQry ))
   oRpt:Say(  oRpt:nL,124,TRANSFORM(aGT[09],cQry ))
   oRpt:NewPage()
   oRpt:nL := 67
EndIf
   ASIZE( oRpt:aEnc,2 )
   oRpt:cFontI := oRpt:CPINormal
   oRpt:aEnc[1]:= "MOVIMIENTO  DE  VENTAS"
   oRpt:Titulo( 78 )
FOR nK := 1 TO 3
   If aVT[nK,1] # 0
      aVT[04,1] += aVT[nK,1]
      aVT[04,2] += aVT[nK,2]
      aVT[04,3] += aVT[nK,3]
      aVT[04,4] += aVT[nK,4]
      aVT[04,5] += aVT[nK,5]
      oRpt:Say(  oRpt:nL, 10,"Total Facturas Tipo " + ::aTF[nK] )
      oRpt:Say(++oRpt:nL, 10,"Cuentas por Cobrar            "+ TRANSFORM(aVT[nK,1],cQry ))
//    oRpt:Say(++oRpt:nL, 10,"Descuento                     "+ TransForm(aVT[nK,2],cQry ))
      oRpt:Say(++oRpt:nL, 10,"Ventas    Gravadas" + SPACE(23)+ TRANSFORM(aVT[nK,3],cQry ))
      oRpt:Say(++oRpt:nL, 10,"Ventas NO Gravadas" + SPACE(23)+ TRANSFORM(aVT[nK,4],cQry ))
      oRpt:Say(++oRpt:nL, 10,"I.V.A.            " + SPACE(23)+ TRANSFORM(aVT[nK,5],cQry ))
      oRpt:nL ++
   EndIf
NEXT nK
   If ::aLS[5] == 4
      oRpt:Say(++oRpt:nL, 10,"Gran Total" )
      oRpt:Say(++oRpt:nL, 10,"Cuentas por Cobrar            "+ TRANSFORM(aVT[4,1],cQry ))
      oRpt:Say(++oRpt:nL, 10,"Ventas    Gravadas" + SPACE(23)+ TRANSFORM(aVT[4,3],cQry ))
      oRpt:Say(++oRpt:nL, 10,"Ventas NO Gravadas" + SPACE(23)+ TRANSFORM(aVT[4,4],cQry ))
      oRpt:Say(++oRpt:nL, 10,"I.V.A.            " + SPACE(23)+ TRANSFORM(aVT[4,5],cQry ))
   EndIf
   If LEN( aFF ) > 2
      oRpt:nL := 67
      oRpt:aEnc[1]:= "FACTURAS FALTANTES"
      oRpt:Titulo( 78 )
      oRpt:Say( oRpt:nL,20,"Primer Factura :" + STR(aFF[1],8) )
      oRpt:Say( oRpt:nL,60,"Ultima Factura :" + STR(::aMV[1]) )
      FOR nK := 3 TO LEN( aFF )
         oRpt:nL ++
         oRpt:Say( oRpt:nL,02,aFF[nK] )
      NEXT nK
   EndIf
   oRpt:NewPage()
   oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserVen( hRes,nL ) CLASS TLived
   LOCAL aGT, aVT, aFF, aRes, cQry, nK
 ::aEnc:= { ::aEnc[1], ::aEnc[2], ::aEnc[3], ::aEnc[4], ::aEnc[5]               ,;
            { .T., 2.0,"","FACTURA" }       , { .F., 2.3,"","C L I E N T E" }   ,;
            { .T., 7.8,"VENTAS","Gravadas" }, { .T., 9.6,"VENTAS","NoGravadas" },;
            { .T.,11.4,"","I.V.A." }        , { .T.,13.2,"","Descuentos" }      ,;
            { .T.,15.0,"","RET.FTE." }      , { .T.,16.8,"","RET.IVA" }         ,;
            { .T.,18.6,"","RET.ICA" }       , { .T.,20.4,"CUENTAS X","COBRAR" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[7] ,,,, 5 )
 ::nMD := 20.5
  PAGE
 aGT := { 0,0,0,0,0,0,0,0,0,0,"999,999,999" }
 aVT := ARRAY(4,5)
 AEVAL( aVT, { |x| AFILL( x,0 ) } )
  aRes := MyReadRow( hRes )
 AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aFF := { aRes[01],aRes[01]+1 }
 ::aMV := { aRes[01],aRes[02],If( aRes[3] > 0, aRes[4], aRes[5] ),0,0,0,;
            aRes[06],aRes[07],aRes[08],aRes[09],aRes[10],aRes[11],aRes[12],0,0 }
While nL > 0
   If aRes[12] # "A"
      If aRes[14] > 0
         ::aMV[4] += aRes[13]  //Gravadas
      Else
         ::aMV[5] += aRes[13]
      EndIf
         ::aMV[6] += aRes[14]  //Montoiva
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. ::aMV[1] # aRes[1] .OR. ::aMV[2] # aRes[2]
      ::aMV[14] := ::aMV[07] - ::aMV[10] - ::aMV[11] - ::aMV[12]
      If ::aLS[3] == 1
         ::Cabecera( .t.,0.42 )
         UTILPRN ::oUtil Self:nLinea, 2.0 SAY STR(::aMV[1],6) + ::aMV[2] RIGHT
         If ::aMV[13] == "A"
            UTILPRN ::oUtil Self:nLinea, 2.2 SAY "** A N U L A D A **"
         Else
            ::aMV[15] := ::aMV[7] - ::aMV[8] - ::aMV[4] - ::aMV[5]
            UTILPRN ::oUtil Self:nLinea, 2.1 SAY If( ::aMV[15] # 0, "*", "" )
            UTILPRN ::oUtil Self:nLinea, 2.3 SAY LEFT( ::aMV[3],26 )
            UTILPRN ::oUtil Self:nLinea, 7.8 SAY TRANSFORM(::aMV[04],   "99,999,999" ) RIGHT
            UTILPRN ::oUtil Self:nLinea, 9.6 SAY TRANSFORM(::aMV[05],   "99,999,999" ) RIGHT
            UTILPRN ::oUtil Self:nLinea,11.4 SAY TRANSFORM(::aMV[08],"@Z 99,999,999" ) RIGHT
            UTILPRN ::oUtil Self:nLinea,13.2 SAY TRANSFORM(::aMV[09],"@Z 99,999,999" ) RIGHT
            UTILPRN ::oUtil Self:nLinea,15.0 SAY TRANSFORM(::aMV[10],"@Z 99,999,999" ) RIGHT
            UTILPRN ::oUtil Self:nLinea,16.8 SAY TRANSFORM(::aMV[11],"@Z 99,999,999" ) RIGHT
            UTILPRN ::oUtil Self:nLinea,18.6 SAY TRANSFORM(::aMV[12],"@Z 99,999,999" ) RIGHT
            UTILPRN ::oUtil Self:nLinea,20.4 SAY TRANSFORM(::aMV[14],"@Z 99,999,999" ) RIGHT
         EndIf
         If ::aMV[13] # "A"
            aGT[02] += ::aMV[04]
            aGT[03] += ::aMV[05]
            aGT[04] += ::aMV[08]
            aGT[05] += ::aMV[09]
            aGT[06] += ::aMV[10]
            aGT[07] += ::aMV[11]
            aGT[08] += ::aMV[12]
            aGT[09] += ::aMV[14]
         EndIf
      EndIf
      If ::aMV[13] # "A"
         nK := ASCAN( ::aTF,::aMV[2] )
         aVT[nK,1] += ::aMV[07]
         aVT[nK,2] += ::aMV[09]
         aVT[nK,3] += ::aMV[04]
         aVT[nK,4] += ::aMV[05]
         aVT[nK,5] += ::aMV[08]
      EndIf
      If ::aLS[6] <= ::aLS[8] .AND. aFF[2] < aRes[1]
            cQry := STR(aFF[2],9)
         If aFF[2] < aRes[1] -1
            cQry += " al" + STR(aRes[1] -1,9)
         EndIf
         AADD( aFF,cQry )
      EndIf
         aFF[2] := aRes[1] + 1
      aGT[01] ++
      ::aMV := { aRes[01],aRes[02],If( aRes[3] > 0, aRes[4], aRes[5] ),0,0,0,;
                 aRes[06],aRes[07],aRes[08],aRes[09],aRes[10],aRes[11],aRes[12],0,0 }
   EndIf
EndDo
 MSFreeResult( hRes )
If ::aLS[3] == 1
   ::Cabecera( .t.,0.42,1.26,20.5 )
   UTILPRN ::oUtil Self:nLinea, 1.5 SAY STR(aGT[01],5) + " FACTURAS"
   UTILPRN ::oUtil Self:nLinea, 7.8 SAY TRANSFORM( aGT[02],aGT[11] ) RIGHT
   UTILPRN ::oUtil Self:nLinea, 9.6 SAY TRANSFORM( aGT[03],aGT[11] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,11.4 SAY TRANSFORM( aGT[04],aGT[11] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,13.2 SAY TRANSFORM( aGT[05],aGT[11] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,15.0 SAY TRANSFORM( aGT[06],aGT[11] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,16.8 SAY TRANSFORM( aGT[07],aGT[11] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,18.6 SAY TRANSFORM( aGT[08],aGT[11] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,20.4 SAY TRANSFORM( aGT[09],aGT[11] ) RIGHT
   ::nLinea := ::nEndLine
EndIf
   ::aEnc[4] := "MOVIMIENTO  DE  VENTAS"
   ::Cabecera( .t.,0.42 )
   UTILPRN ::oUtil SELECT ::aFnt[2]
FOR nK := 1 TO 3
   If aVT[nK,1] # 0
      aVT[04,1] += aVT[nK,1]
      aVT[04,2] += aVT[nK,2]
      aVT[04,3] += aVT[nK,3]
      aVT[04,4] += aVT[nK,4]
      aVT[04,5] += aVT[nK,5]
      UTILPRN ::oUtil Self:nLinea, 2.5 SAY "Total Facturas Tipo " + ::aTF[nK]
      ::nLinea += .5
      UTILPRN ::oUtil Self:nLinea, 2.5 SAY "Cuentas por Cobrar"
      UTILPRN ::oUtil Self:nLinea, 8.5 SAY TRANSFORM( aVT[nK,1],cQry ) RIGHT
      ::nLinea += .5
      UTILPRN ::oUtil Self:nLinea, 2.5 SAY "Ventas    Gravadas"
      UTILPRN ::oUtil Self:nLinea,11.0 SAY TRANSFORM( aVT[nK,3],cQry ) RIGHT
      ::nLinea += .5
      UTILPRN ::oUtil Self:nLinea, 2.5 SAY "Ventas NO Gravadas"
      UTILPRN ::oUtil Self:nLinea,11.0 SAY TRANSFORM( aVT[nK,4],cQry ) RIGHT
      ::nLinea += .5
      UTILPRN ::oUtil Self:nLinea, 2.5 SAY "I.V.A."
      UTILPRN ::oUtil Self:nLinea,11.0 SAY TRANSFORM( aVT[nK,5],cQry ) RIGHT
      ::nLinea ++
   EndIf
NEXT nK
   If ::aLS[5] == 4
      UTILPRN ::oUtil Self:nLinea, 2.5 SAY "Gran Total"
      ::nLinea += .5
      UTILPRN ::oUtil Self:nLinea, 2.5 SAY "Cuentas por Cobrar"
      UTILPRN ::oUtil Self:nLinea, 8.5 SAY TRANSFORM( aVT[4,1],cQry ) RIGHT
      ::nLinea += .5
      UTILPRN ::oUtil Self:nLinea, 2.5 SAY "Ventas    Gravadas"
      UTILPRN ::oUtil Self:nLinea,11.0 SAY TRANSFORM( aVT[4,3],cQry ) RIGHT
      ::nLinea += .5
      UTILPRN ::oUtil Self:nLinea, 2.5 SAY "Ventas NO Gravadas"
      UTILPRN ::oUtil Self:nLinea,11.0 SAY TRANSFORM( aVT[4,4],cQry ) RIGHT
      ::nLinea += .5
      UTILPRN ::oUtil Self:nLinea, 2.5 SAY "I.V.A."
      UTILPRN ::oUtil Self:nLinea,11.0 SAY TRANSFORM( aVT[4,5],cQry ) RIGHT
   EndIf
   ENDPAGE
IMPRIME END .F.
RETURN NIL

//------------------------------------//
METHOD ListoDif() CLASS TLived
   LOCAL aRes, hRes, nL, nK, oRpt
hRes := ::NEW( "VENTAS CON DIFERENCIAS DE PRECIOS",2 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
EndIf
 ::aMV := { "999,999,999",0,0,0,0 }
If ::aLS[9] == 1
   oRpt := TDosPrint()
   oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4],::aEnc[5],;
            "----FACTURA  CODIGO----  DESCRIPCION--------------  --CANTIDAD     "+;
            "VALOR VENTA      PUBLICO   DIFERENCIA"},::aLS[7],,2 )
Else
   ::aEnc:= { ::aEnc[1], ::aEnc[2], ::aEnc[3], ::aEnc[4], ::aEnc[5] ,;
            { .F., 0.7,"FACTURA" } , { .F., 2.2,"CODIGO" }          ,;
            { .F., 4.0,"D E S C R I P C I O N" }                    ,;
            { .T.,13.4,"CANTIDAD" }, { .T.,16.0,"VALOR VENTA" }     ,;
            { .T.,18.0,"PUBLICO" } , { .T.,20.0,"DIFERENCIA" } }
   ::Init( ::aEnc[4], .f. ,, !::aLS[7] ,,,, 5 )
     PAGE
EndIf
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      aRes[07] += aRes[08] + aRes[09]
      aRes[10] *= aRes[05]
   If aRes[07] # aRes[10]
      nK := aRes[07] - aRes[10]
      If ::aLS[9] == 1
         oRpt:Titulo( 104 )
         oRpt:Say( oRpt:nL,00,aRes[01] + STR(aRes[02],10) )
         oRpt:Say( oRpt:nL,13,aRes[03] )
         oRpt:Say( oRpt:nL,25,aRes[04],25 )
         oRpt:Say( oRpt:nL,52,TRANSFORM(aRes[05],"999,999.99" ))
         oRpt:Say( oRpt:nL,63,aRes[06] )
         oRpt:Say( oRpt:nL,68,TRANSFORM(aRes[07],::aMV[1] ))
         oRpt:Say( oRpt:nL,80,TRANSFORM(aRes[10],::aMV[1] ))
         oRpt:Say( oRpt:nL,93,TRANSFORM(     nK ,::aMV[1] ))
         oRpt:nL++
      Else
         ::Cabecera( .t.,0.42 )
         UTILPRN ::oUtil Self:nLinea, 2.0 SAY STR(aRes[02],10) + aRes[01] RIGHT
         UTILPRN ::oUtil Self:nLinea, 2.2 SAY aRes[03]
         UTILPRN ::oUtil Self:nLinea, 4.0 SAY LEFT( aRes[04],25 )
         UTILPRN ::oUtil Self:nLinea,13.4 SAY TRANSFORM(aRes[05],"999,999.99" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,13.6 SAY aRes[06]
         UTILPRN ::oUtil Self:nLinea,16.0 SAY TRANSFORM(aRes[07],::aMV[1] )     RIGHT
         UTILPRN ::oUtil Self:nLinea,18.0 SAY TRANSFORM(aRes[10],::aMV[1] )     RIGHT
         UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM(     nK ,::aMV[1] )     RIGHT
      EndIf
      ::aMV[02] ++
      ::aMV[03] += aRes[07]
      ::aMV[04] += aRes[10]
      ::aMV[05] += nK
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
If ::aMV[2] > 0
   If ::aLS[9] == 1
      oRpt:Titulo( 104 )
      oRpt:Say(  oRpt:nL,00,REPLICATE("_",105) )
      oRpt:Say(++oRpt:nL,25,"TOTALES  ==> "+ TRANSFORM(::aMV[2],::aMV[1]) )
      oRpt:Say( oRpt:nL,68,TRANSFORM(::aMV[3],::aMV[1] ))
      oRpt:Say( oRpt:nL,80,TRANSFORM(::aMV[4],::aMV[1] ))
      oRpt:Say( oRpt:nL,93,TRANSFORM(::aMV[5],::aMV[1] ))
      oRpt:NewPage()
      oRpt:End()
   Else
      ::Cabecera( .t.,0.42,1.26,20.0 )
      UTILPRN ::oUtil Self:nLinea, 4.0 SAY "TOTALES  ==> "+ TRANSFORM(::aMV[2],::aMV[1])
      UTILPRN ::oUtil Self:nLinea,16.0 SAY TRANSFORM( ::aMV[3],::aMV[1] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,18.0 SAY TRANSFORM( ::aMV[4],::aMV[1] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM( ::aMV[5],::aMV[1] ) RIGHT
     ENDPAGE
    IMPRIME END .F.
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD ListoDim() CLASS TLived
   LOCAL aGT, aRA, aRS, hRes, nL, oRpt, lOK := .t.
hRes := ::NEW( "VENTAS CON DIFERENCIAS EN CONTABILIDAD",3 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[9] == 2
   ::LaserDim( hRes,nL )
   RETURN NIL
EndIf
 aGT := { "99,999,999.99",0,0,0 }
 oRpt := TDosPrint()
 oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4],::aEnc[5],;
           "INFB------  ----NUMFAC  CONTROL_FA  COMPROBANT  CONTROL_CG"+;
           "    VALOR VENTA    VALOR CONTA     DIFERENCIA"},::aLS[7],,2 )
While nL > 0
   If lOK
      aRA := MyReadRow( hRes )
      AEVAL( aRA, {| xV,nP | aRA[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If (nL --) > 1
      aRS := MyReadRow( hRes )
      AEVAL( aRS, {| xV,nP | aRS[nP] := MyClReadCol( hRes,nP ) } )
   Else
      aRS := aRA
   EndIf
   If aRA[1] == aRS[1]
      If aRA[3] # aRS[3] .OR. aRA[4] # aRS[4]
         If aRA[2] == 0
            ::aMV := { aRA[3],aRA[4],aRS[3],aRS[4],aRA[5],aRS[5] }
         Else
            ::aMV := { aRS[3],aRS[4],aRA[3],aRA[4],aRS[5],aRA[5] }
         EndIf
         aGT[2] += ::aMV[5]
         aGT[3] += ::aMV[6]
         aGT[4] := ::aMV[5] - ::aMV[6]
         oRpt:Titulo( 103 )
         oRpt:Say( oRpt:nL,00,aRA[1] )
         oRpt:Say( oRpt:nL,12,STR(::aMV[1]) )
         oRpt:Say( oRpt:nL,24,STR(::aMV[2]) )
         oRpt:Say( oRpt:nL,36,STR(::aMV[3]) )
         oRpt:Say( oRpt:nL,48,STR(::aMV[4]) )
         oRpt:Say( oRpt:nL,60,TRANSFORM(::aMV[5],aGT[1] ))
         oRpt:Say( oRpt:nL,75,TRANSFORM(::aMV[6],aGT[1] ))
         oRpt:Say( oRpt:nL,90,TRANSFORM(  aGT[4],aGT[1] ))
         oRpt:nL++
      EndIf
      lOK := .t.
   Else
         oRpt:Titulo( 103 )
         oRpt:Say( oRpt:nL,00,aRA[1] )
      If aRA[2] == 0
         aGT[2] += aRA[5]
         oRpt:Say( oRpt:nL,12,STR(aRA[3]) )
         oRpt:Say( oRpt:nL,24,STR(aRA[4]) )
         oRpt:Say( oRpt:nL,60,TRANSFORM(aRA[5],aGT[1] ))
         oRpt:Say( oRpt:nL,90,"  FACTURACION" )
      Else
         aGT[3] += aRA[5]
         oRpt:Say( oRpt:nL,36,STR(aRA[3]) )
         oRpt:Say( oRpt:nL,48,STR(aRA[4]) )
         oRpt:Say( oRpt:nL,75,TRANSFORM(aRA[5],aGT[1] ))
         oRpt:Say( oRpt:nL,90," CONTABILIDAD" )
      EndIf
         oRpt:nL++
      aRA := ACLONE( aRS )
      lOK := .f.
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
   aGT[4] := aGT[2] - aGT[3]
   oRpt:Titulo( 103 )
   oRpt:Say(  oRpt:nL,00,REPLICATE("_",103) )
   oRpt:Say(++oRpt:nL,25,"TOTALES  ==> " )
   oRpt:Say(  oRpt:nL,60,TRANSFORM(aGT[2],aGT[1] ))
   oRpt:Say(  oRpt:nL,75,TRANSFORM(aGT[3],aGT[1] ))
   oRpt:Say(  oRpt:nL,90,TRANSFORM(aGT[4],aGT[1] ))
   oRpt:NewPage()
   oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserDim( hRes,nL ) CLASS TLived
   LOCAL aGT, aRA, aRS, lOK := .t.
   aGT := { "99,999,999.99",0,0,0 }
 ::aEnc:= { ::aEnc[1], ::aEnc[2], ::aEnc[3], ::aEnc[4], ::aEnc[5] ,;
            { .F., 0.7,"INFB---" }    , { .T., 7.0,"FACTURA" }    ,;
            { .T.,09.0,"CONTROL_FA" } , { .T.,11.0,"COMPROBANTE" },;
            { .T.,13.0,"CONTROL_CG" } , { .T.,15.0,"VALOR VENTA" },;
            { .T.,17.5,"VALOR CONTA" }, { .T.,20.0,"DIFERENCIA" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[7] ,,,, 5 )
   PAGE
While nL > 0
   If lOK
      aRA := MyReadRow( hRes )
      AEVAL( aRA, {| xV,nP | aRA[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If (nL --) > 1
      aRS := MyReadRow( hRes )
      AEVAL( aRS, {| xV,nP | aRS[nP] := MyClReadCol( hRes,nP ) } )
   Else
      aRS := aRA
   EndIf
   If aRA[1] == aRS[1]
      If aRA[3] # aRS[3] .OR. aRA[4] # aRS[4]
         If aRA[2] == 0
            ::aMV := { aRA[3],aRA[4],aRS[3],aRS[4],aRA[5],aRS[5] }
         Else
            ::aMV := { aRS[3],aRS[4],aRA[3],aRA[4],aRS[5],aRA[5] }
         EndIf
         aGT[2] += ::aMV[5]
         aGT[3] += ::aMV[6]
         aGT[4] := ::aMV[5] - ::aMV[6]
         ::Cabecera( .t.,0.42 )
         UTILPRN ::oUtil Self:nLinea, 0.5 SAY aRA[1]
         UTILPRN ::oUtil Self:nLinea, 7.0 SAY STR(::aMV[1])               RIGHT
         UTILPRN ::oUtil Self:nLinea, 9.0 SAY STR(::aMV[2])               RIGHT
         UTILPRN ::oUtil Self:nLinea,11.0 SAY STR(::aMV[3])               RIGHT
         UTILPRN ::oUtil Self:nLinea,13.0 SAY STR(::aMV[4])               RIGHT
         UTILPRN ::oUtil Self:nLinea,15.0 SAY TRANSFORM(::aMV[5],aGT[1] ) RIGHT
         UTILPRN ::oUtil Self:nLinea,17.5 SAY TRANSFORM(::aMV[6],aGT[1] ) RIGHT
         UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM(  aGT[4],aGT[1] ) RIGHT
      EndIf
      lOK := .t.
   Else
         ::Cabecera( .t.,0.42 )
         UTILPRN ::oUtil Self:nLinea, 0.5 SAY aRA[1]
      If aRA[2] == 0
         aGT[2] += aRA[5]
         UTILPRN ::oUtil Self:nLinea, 7.0 SAY STR( aRA[3] )               RIGHT
         UTILPRN ::oUtil Self:nLinea, 9.0 SAY STR( aRA[4] )               RIGHT
         UTILPRN ::oUtil Self:nLinea,15.0 SAY TRANSFORM(  aRA[5],aGT[1] ) RIGHT
         UTILPRN ::oUtil Self:nLinea,18.5 SAY "  FACTURACION"
      Else
         aGT[3] += aRA[5]
         UTILPRN ::oUtil Self:nLinea,11.0 SAY STR( aRA[3] )               RIGHT
         UTILPRN ::oUtil Self:nLinea,13.0 SAY STR( aRA[4] )               RIGHT
         UTILPRN ::oUtil Self:nLinea,17.5 SAY TRANSFORM(  aRA[5],aGT[1] ) RIGHT
         UTILPRN ::oUtil Self:nLinea,18.5 SAY " CONTABILIDAD"
      EndIf
      aRA := ACLONE( aRS )
      lOK := .f.
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
   aGT[4] := aGT[2] - aGT[3]
      ::Cabecera( .t.,0.42,1.26,20.0 )
      UTILPRN ::oUtil Self:nLinea, 4.0 SAY "TOTALES  ==> "
      UTILPRN ::oUtil Self:nLinea,15.0 SAY TRANSFORM( aGT[2],aGT[1] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,17.5 SAY TRANSFORM( aGT[3],aGT[1] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM( aGT[4],aGT[1] ) RIGHT
   ENDPAGE
 IMPRIME END .F.
RETURN NIL

//------------------------------------//
METHOD ListoRet() CLASS TLived
   LOCAL aGT, aRes, hRes, nL, oRpt
hRes := ::NEW( "LISTADO DE VENTAS",10 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[9] == 2
   ::LaserRet( hRes,nL )
   RETURN NIL
EndIf
   aGT := { 0,0,0,0,0,0,"999,999,999",0 }
   oRpt := TDosPrint()
   oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4], ::aEnc[5],;
             "      CC o NIT  NOMBRE DEL CLIENTE                       FACTURA  " +;
             "TOTAL VENTA      I.V.A.    RET.FTE.    RET.IVA.    RET.ICA."},::aLS[7],::aLS[5],2 )
//    CC o NIT  NOMBRE DEL CLIENTE                       FACTURA  TOTAL VENTA      I.V.A.    RET.FTE.    RET.IVA.    RET.ICA."},::aLS[7],::aLS[5],2 )
//99,999,999-9  123456789012345678900123456789012345  1234567890   99,999,999  99,999,999  99,999,999  99,999,999  99,999,999
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   oRpt:Titulo( 125 )
   If aGT[8]  # aRes[1]
      aGT[8] := aRes[1]
      oRpt:Say( oRpt:nL, 00,FormatoNit(aRes[1],aRes[2]) )
      oRpt:Say( oRpt:nL, 16,aRes[3] )
   EndIf
   oRpt:Say( oRpt:nL, 53,STR(aRes[4])+aRes[5] )
   oRpt:Say( oRpt:nL, 67,TRANSFORM( aRes[06],"99,999,999" ))
   oRpt:Say( oRpt:nL, 79,TRANSFORM( aRes[07],"99,999,999" ))
   oRpt:Say( oRpt:nL, 91,TRANSFORM( aRes[08],"99,999,999" ))
   oRpt:Say( oRpt:nL,103,TRANSFORM( aRes[09],"99,999,999" ))
   oRpt:Say( oRpt:nL,115,TRANSFORM( aRes[10],"99,999,999" ))
   oRpt:nL ++
   aGT[1] ++
   aGT[2] += aRes[06]
   aGT[3] += aRes[07]
   aGT[4] += aRes[08]
   aGT[5] += aRes[09]
   aGT[6] += aRes[10]
   nL --
EndDo
MSFreeResult( hRes )
   oRpt:Titulo( 112 )
   oRpt:Say(  oRpt:nL, 00,REPLICATE("_",125) )
   oRpt:Say(++oRpt:nL, 01,STR(aGT[1],5) + " FACTURAS" )
   oRpt:Say(  oRpt:nL, 66,TRANSFORM( aGT[2],aGT[7] ))
   oRpt:Say(  oRpt:nL, 78,TRANSFORM( aGT[3],aGT[7] ))
   oRpt:Say(  oRpt:nL, 90,TRANSFORM( aGT[4],aGT[7] ))
   oRpt:Say(  oRpt:nL,102,TRANSFORM( aGT[5],aGT[7] ))
   oRpt:Say(  oRpt:nL,114,TRANSFORM( aGT[6],aGT[7] ))
   oRpt:NewPage()
   oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserRet( hRes,nL ) CLASS TLived
   LOCAL aGT, aRes
   aGT := { 0,0,0,0,0,0,"999,999,999",0 }
 ::aEnc:= { ::aEnc[1], ::aEnc[2], ::aEnc[3], ::aEnc[4], ::aEnc[5],;
           { .T., 2.5,"CC o NIT" }, { .F., 2.8,"C L I E N T E" } ,;
           { .T.,11.4,"FACTURA" } , { .T.,13.3,"TOTAL VENTA" }   ,;
           { .T.,15.1,"I.V.A." }  , { .T.,16.9,"RET.FTE." }      ,;
           { .T.,18.7,"RET.IVA." }, { .T.,20.5,"RET.ICA." } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[7] ,,, ::aLS[7], 5 )
 ::nMD := 20.5
  PAGE
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   ::Cabecera( .t.,0.41 )
   If aGT[8]  # aRes[1]
      aGT[8] := aRes[1]
      UTILPRN ::oUtil Self:nLinea, 2.5 SAY FormatoNit(aRes[1],aRes[2]) RIGHT
      UTILPRN ::oUtil Self:nLinea, 2.8 SAY aRes[3]
   EndIf
   UTILPRN ::oUtil Self:nLinea,11.4 SAY STR(aRes[4])+aRes[5]         RIGHT
   UTILPRN ::oUtil Self:nLinea,13.3 SAY TRANSFORM( aRes[06],aGT[7] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,15.1 SAY TRANSFORM( aRes[07],aGT[7] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,16.9 SAY TRANSFORM( aRes[08],aGT[7] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,18.7 SAY TRANSFORM( aRes[09],aGT[7] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aRes[10],aGT[7] ) RIGHT
   aGT[1] ++
   aGT[2] += aRes[06]
   aGT[3] += aRes[07]
   aGT[4] += aRes[08]
   aGT[5] += aRes[09]
   aGT[6] += aRes[10]
   nL --
EndDo
MSFreeResult( hRes )
   ::Cabecera( .t.,0.41,0.82,20.5 )
   UTILPRN ::oUtil Self:nLinea, 2.8 SAY STR(aGT[1],5) + " FACTURAS"
   UTILPRN ::oUtil Self:nLinea,13.3 SAY TRANSFORM( aGT[2],aGT[7] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,15.1 SAY TRANSFORM( aGT[3],aGT[7] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,16.9 SAY TRANSFORM( aGT[4],aGT[7] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,18.7 SAY TRANSFORM( aGT[5],aGT[7] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aGT[6],aGT[7] ) RIGHT
  ENDPAGE
 ::EndInit( .F. )
RETURN NIL

//------------------------------------//
METHOD ListoUti() CLASS TLived
   LOCAL aGT, aRes, cQry, hRes, nL, oRpt
hRes := ::NEW( "LISTADO DE VENTAS",4 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[9] == 2
   ::LaserUti( hRes,nL )
   RETURN NIL
EndIf
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
 ::aMV := { aRes[1],aRes[2],aRes[3],aRes[4],aRes[5],aRes[6],aRes[7],aRes[8],0,0,0,0,0,0 }
   aGT := { 0,0,0,0,0,0,0,0,0,"999,999,999" }
   oRpt := TDosPrint()
   oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4], ::aEnc[5],;
             "                             --VENTAS--  --VENTAS--              " +;
             "                        CUENTAS  X     TOTAL  "                    ,;
             "FACTURA NOMBRE DEL CLIENTE   -GRAVADAS-  NOGRAVADAS  --I.V.A.--  " +;
             "DESCUENTOS  RETENCION-  --COBRAR--  ---COSTO--  --UTILIDAD"},::aLS[7],::aLS[5],2 )
While nL > 0
   If aRes[08] # "A"
      aRes[16] := AFormula( aRes[09],aRes[10],aRes[15],aRes[16] )
      aRes[14] *= aRes[16]
      If aRes[13] > 0
         ::aMV[09] += aRes[11]  //Gravadas
      Else
         ::aMV[10] += aRes[11]
      EndIf
         ::aMV[11] += aRes[13]  //Montoiva
         ::aMV[12] += aRes[14]  //PCosto
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. ::aMV[1] # aRes[1] .OR. ::aMV[2] # aRes[2]
      ::aMV[14] := ::aMV[09] + ::aMV[10]
      ::aMV[13] +=(::aMV[14] - ::aMV[12])
      oRpt:Titulo( 135 )
      oRpt:Say( oRpt:nL,00,STR(::aMV[1],6) + ::aMV[2] )
      If ::aMV[08] == "A"
         oRpt:Say( oRpt:nL,08,"** A N U L A D A **" )
      Else
//       Porcentaje Utilidad es Utilidad / Pcosto
         ::aMV[14] := ROUND( (::aMV[13] / ::aMV[12]) * 100,2 )
         oRpt:Say( oRpt:nL,08,::aMV[3],20 )
         oRpt:Say( oRpt:nL, 29,TRANSFORM(::aMV[09],   "99,999,999" ))
         oRpt:Say( oRpt:nL, 41,TRANSFORM(::aMV[10],   "99,999,999" ))
         oRpt:Say( oRpt:nL, 53,TRANSFORM(::aMV[11],"@Z 99,999,999" ))
         oRpt:Say( oRpt:nL, 65,TRANSFORM(::aMV[05],"@Z 99,999,999" ))
         oRpt:Say( oRpt:nL, 77,TRANSFORM(::aMV[07],"@Z 99,999,999" ))
         oRpt:Say( oRpt:nL, 89,TRANSFORM(::aMV[06],"@Z 99,999,999" ))
         oRpt:Say( oRpt:nL,101,TRANSFORM(::aMV[12],"@Z 99,999,999" ))
         oRpt:Say( oRpt:nL,113,TRANSFORM(::aMV[13],"@Z 99,999,999" ))
         oRpt:Say( oRpt:nL,125,TRANSFORM(::aMV[14],"99,999.99%" ))
      EndIf
      oRpt:nL ++
      If ::aMV[08] # "A"
         aGT[02] += ::aMV[09]
         aGT[03] += ::aMV[10]
         aGT[04] += ::aMV[11]
         aGT[05] += ::aMV[05]
         aGT[06] += ::aMV[07]  //Retenciones
         aGT[07] += ::aMV[06]  //Totalfac
         aGT[08] += ::aMV[12]  //Costo
         aGT[09] += ::aMV[13]  //Utilidad
      EndIf
        aGT[01] ++
      ::aMV := { aRes[1],aRes[2],aRes[3],aRes[4],aRes[5],aRes[6],aRes[7],aRes[8],0,0,0,0,0,0 }
   EndIf
EndDo
MSFreeResult( hRes )
 cQry := "999,999,999"
   oRpt:Titulo( 135 )
   oRpt:Say(  oRpt:nL, 00,REPLICATE("_",135) )
   oRpt:Say(++oRpt:nL, 01,STR(aGT[01],5) + " FACTURAS" )
   oRpt:Say(  oRpt:nL, 28,TRANSFORM(aGT[02],cQry ))
   oRpt:Say(  oRpt:nL, 40,TRANSFORM(aGT[03],cQry ))
   oRpt:Say(  oRpt:nL, 52,TRANSFORM(aGT[04],cQry ))
   oRpt:Say(  oRpt:nL, 64,TRANSFORM(aGT[05],cQry ))
   oRpt:Say(  oRpt:nL, 76,TRANSFORM(aGT[06],cQry ))
   oRpt:Say(  oRpt:nL, 88,TRANSFORM(aGT[07],cQry ))
   oRpt:Say(  oRpt:nL,100,TRANSFORM(aGT[08],cQry ))
   oRpt:Say(  oRpt:nL,112,TRANSFORM(aGT[09],cQry ))
   oRpt:NewPage()
   oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserUti( hRes,nL ) CLASS TLived
   LOCAL aGT, aRes
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aGT := { 0,0,0,0,0,0,0,0,0,"999,999,999" }
 ::aMV := { aRes[1],aRes[2],aRes[3],aRes[4],aRes[5],aRes[6],aRes[7],aRes[8],0,0,0,0,0,0 }
 ::aEnc:= { ::aEnc[1], ::aEnc[2], ::aEnc[3], ::aEnc[4], ::aEnc[5]              ,;
           { .F., 1.0,"","Factura" }       , { .F., 2.2,"","C L I E N T E" }   ,;
           { .T., 6.8,"VENTAS","Gravadas" }, { .T., 8.6,"VENTAS","NoGravadas" },;
           { .T.,10.4,"","I.V.A." }        , { .T.,12.2,"","Descuentos" }      ,;
           { .T.,14.0,"","RETENCION" }     , { .T.,15.8,"CUENTAS X","COBRAR" } ,;
           { .T.,17.6,"TOTAL","COSTO" }    , { .T.,19.4,"","UTILIDAD" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[7] ,,, ::aLS[7], 5 )
 ::nMD := 20.5
  PAGE
While nL > 0
   If aRes[08] # "A"
      aRes[16] := AFormula( aRes[09],aRes[10],aRes[15],aRes[16] )
      aRes[14] *= aRes[16]
      If aRes[13] > 0
         ::aMV[09] += aRes[11]  //Gravadas
      Else
         ::aMV[10] += aRes[11]
      EndIf
         ::aMV[11] += aRes[13]  //Montoiva
         ::aMV[12] += aRes[14]  //PCosto
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. ::aMV[1] # aRes[1] .OR. ::aMV[2] # aRes[2]
      ::aMV[14] := ::aMV[09] + ::aMV[10]
      ::aMV[13] +=(::aMV[14] - ::aMV[12])
      ::Cabecera( .t.,0.42 )
      UTILPRN ::oUtil Self:nLinea, 2.0 SAY STR(::aMV[1],6) + ::aMV[2] RIGHT
      If ::aMV[08] == "A"
         UTILPRN ::oUtil Self:nLinea, 2.2 SAY "** A N U L A D A **"
      Else
         ::aMV[14] := ROUND( (::aMV[13] / ::aMV[12]) * 100,2 )
         UTILPRN ::oUtil Self:nLinea, 2.2 SAY LEFT( ::aMV[3],18 )
         UTILPRN ::oUtil Self:nLinea, 6.8 SAY TRANSFORM(::aMV[09],   "99,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea, 8.6 SAY TRANSFORM(::aMV[10],   "99,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,10.4 SAY TRANSFORM(::aMV[11],"@Z 99,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,12.2 SAY TRANSFORM(::aMV[05],"@Z 99,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,14.0 SAY TRANSFORM(::aMV[07],"@Z 99,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,15.8 SAY TRANSFORM(::aMV[06],"@Z 99,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,17.6 SAY TRANSFORM(::aMV[12],"@Z 99,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,19.4 SAY TRANSFORM(::aMV[13],"@Z 99,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM(::aMV[14],   "99,999.99%" ) RIGHT
      EndIf
      If ::aMV[08] # "A"
         aGT[02] += ::aMV[09]
         aGT[03] += ::aMV[10]
         aGT[04] += ::aMV[11]
         aGT[05] += ::aMV[05]
         aGT[06] += ::aMV[07]  //Retenciones
         aGT[07] += ::aMV[06]  //Totalfac
         aGT[08] += ::aMV[12]  //Costo
         aGT[09] += ::aMV[13]  //Utilidad
      EndIf
        aGT[01] ++
      ::aMV := { aRes[1],aRes[2],aRes[3],aRes[4],aRes[5],aRes[6],aRes[7],aRes[8],0,0,0,0,0,0 }
   EndIf
EndDo
MSFreeResult( hRes )
      ::Cabecera( .t.,0.42,1.26,20.5 )
      UTILPRN ::oUtil Self:nLinea, 2.2 SAY STR(aGT[01],5) + " FACTURAS"
      UTILPRN ::oUtil Self:nLinea, 6.8 SAY TRANSFORM( aGT[02],aGT[10] ) RIGHT
      UTILPRN ::oUtil Self:nLinea, 8.6 SAY TRANSFORM( aGT[03],aGT[10] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,10.4 SAY TRANSFORM( aGT[04],aGT[10] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,12.2 SAY TRANSFORM( aGT[05],aGT[10] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,14.0 SAY TRANSFORM( aGT[06],aGT[10] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,15.8 SAY TRANSFORM( aGT[07],aGT[10] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,17.6 SAY TRANSFORM( aGT[08],aGT[10] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,19.4 SAY TRANSFORM( aGT[09],aGT[10] ) RIGHT
  ENDPAGE
 ::EndInit( .F. )
RETURN NIL

//------------------------------------//
METHOD ListoCar() CLASS TLived
   LOCAL oRpt, aGT
   LOCAL aRes, hRes, cQry, nL, nFP, nSaldo, nTotal := 0
hRes := ::NEW( "RESUMEN DE INGRESOS DIARIOS",5 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
EndIf
If ::aLS[2] == ::aLS[1]
   ::aEnc[5] := NtChr(::aLS[1],"3")
EndIf
oApl:cPer := NtChr(::aLS[2],"1" )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{::aEnc[4],::aEnc[5],SPACE(20) +;
          "NRO FACTURA  MONTO DEL ABONO  SALDO FACTURA  "   +;
          "BANCO NUMERO DEL CHEQUE" },::aLS[7],,2 )
 aGT := { 0,0,0,0,0,0,0,"E F E C T I V O    ","C H E Q U E S      ",;
          "TARJETAS DEBITO    ","TARJETAS DE CREDITO","TARJETA DE AHORROS " }
 aRes:= MyReadRow( hRes )
 AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
While nL > 0
   oRpt:Titulo( 126 )
   If nTotal == 0
      nFP := aRes[1]
      oRpt:Say( oRpt:nL,01,aGT[nFP+8] + ":" )
   EndIf
   nSaldo := SaldoFac( aRes[02],1 )
   oRpt:Say( oRpt:nL,21,STR( aRes[02],10 ) )
   oRpt:Say( oRpt:nL,31,aRes[10] )
   oRpt:Say( oRpt:nL,34,TRANSFORM(aRes[05],"99,999,999.99") )
   oRpt:Say( oRpt:nL,50,TRANSFORM(nSaldo  ,"99,999,999.99") )
   oRpt:Say( oRpt:nL,67,aRes[03] )  //CodBanco
   oRpt:Say( oRpt:nL,71,aRes[04] )  //NumCheque
   oRpt:Say( oRpt:nL,88,aRes[09] )  //Cliente
   oRpt:nL ++
   aGT[2] += aRes[06]  //Deduccion
   aGT[3] += aRes[07]  //Descuento
   aGT[4] += aRes[08]  //Retencion
   //aGT[5] += aRes[09]  //Retica
   //aGT[6] += aRes[10]  //Retiva
   //aGT[7] += aRes[11]  //Retfte
   nTotal += aRes[05]  //Abono
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. nFP # aRes[1]
      oRpt:Titulo( 126 )
      oRpt:Say(++oRpt:nL,01,oRpt:CPIBold + "TOTAL "+ aGT[nFP+8]+ ":",,,1 )
      oRpt:Say(  oRpt:nL,34,TransForm( nTotal,"99,999,999.99" )+oRpt:CPIBoldN )
      oRpt:nL += 2
      aGT[1] += nTotal
      nTotal := 0
   EndIf
EndDo
MSFreeResult( hRes )
cQry   := SPACE(17)
nTotal := aGT[1] + aGT[2] + aGT[3] + aGT[4] + aGT[5] + aGT[6] + aGT[7]
oRpt:Separator( 0,8 )
oRpt:SetFont( oRpt:cFontI+oRpt:CPIBold,82,2 )
oRpt:Say( oRpt:nL++,01,"TOTAL INGRESOS :"+cQry+ TRANSFORM(aGT[1],"99,999,999.99") )
oRpt:Say( oRpt:nL++,01,"TOTAL DEDUCCION:"+cQry+ TRANSFORM(aGT[2],"99,999,999.99") )
oRpt:Say( oRpt:nL++,01,"TOTAL DESCUENTO:"+cQry+ TRANSFORM(aGT[3],"99,999,999.99") )
oRpt:Say( oRpt:nL++,01,"TOTAL RETENCION:"+cQry+ TRANSFORM(aGT[4],"99,999,999.99") )
//oRpt:Say( oRpt:nL++,01,"TOTAL RET.ICA  :"+cQry+ TransForm(aGT[5],"99,999,999.99") )
//oRpt:Say( oRpt:nL++,01,"TOTAL RET.IVA  :"+cQry+ TransForm(aGT[6],"99,999,999.99") )
//oRpt:Say( oRpt:nL++,01,"TOTAL RET.FUENT:"+cQry+ TransForm(aGT[7],"99,999,999.99") )
oRpt:Say( oRpt:nL++,34,"=============" )
oRpt:Say( oRpt:nL++,01,"TOTAL CARTERA  :"+cQry+ TRANSFORM(nTotal,"99,999,999.99") )
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD ListoRes() CLASS TLived
   LOCAL aRes, cQry, hRes, nL, nK, oRpt
If EMPTY( ::aLS[10] )
   ::aLS[10] := ""
Else
   ::aLS[10] := ALLTRIM( ::aLS[10] )
   ::aLS[10] := "LEFT(d.codigo," + STR( LEN(::aLS[10]),1 ) + ") = '" + ::aLS[10] +;
               "' AND "
EndIf
If ::aLS[4] == "S"
   ::TotalCod()
   RETURN NIL
EndIf
hRes := ::NEW( "LISTADO DE VENTAS",6 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[9] == 2
   ::LaserRes( hRes,nL )
   RETURN NIL
EndIf
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
 ::aMV := { aRes[1],0,"999,999,999",0,0,0,0,0,0,0,0 }
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4],::aEnc[5],;
         "--FACTURA --CODIGO---  D E S C R I P C I O N----"+ SPACE(17) +;
         "--CANTIDAD---  VALOR VENTA"},::aLS[7],::aLS[5],2 )
While nL > 0
    nK     := If( aRes[10] == 0, 8, 7 )
   ::aMV[02] := If( aRes[11] $ "AD" .AND. aRes[12] <= ::aLS[2], 0, aRes[06] )
   ::aMV[04] ++
   ::aMV[05] += aRes[08]
   ::aMV[06] += aRes[09]
   ::aMV[nK] += aRes[08]
   ::aMV[09] += aRes[10]
   ::aMV[10] += If( ::aMV[2] == 0, 0, aRes[08] )
   If ::aLS[3] == 1
      oRpt:Titulo( 99 )
      If oRpt:nPage >= oRpt:nPagI
         If aRes[13] == 0
            aRes[13] := aRes[14]
         EndIf
         aRes[16] := AFormula( aRes[06],aRes[07],aRes[15],aRes[16] )
         aRes[13] *= aRes[16]
         aRes[14] := ROUND( ((aRes[08] - aRes[13]) / aRes[13]) * 100,2 )
/*
         If aRes[14] <= 0
            ActuSaldo( { ::aMV[1],,0,0,aRes[04],aRes[13],.f. } )
            cQry := "SELECT pcosto FROM cadfactd "                +;
                    "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
                     " AND numfac  = " + LTRIM(STR(aRes[03]))     +;
                     " AND tipo    = '"+           aRes[02]       +;
                    "' AND codigo  = " + xValToChar( aRes[04] )
            aRes[13] := Buscar( cQry,"CM",,8,,4 ) * aRes[16]
            aRes[14] := ROUND( ((aRes[08] - aRes[13]) / aRes[08]) * 100,2 )
         EndIf
*/
         oRpt:Say( oRpt:nL,00,If( aRes[02] == "C", " ", aRes[02] ) + STR(aRes[03],8) )
         oRpt:Say( oRpt:nL,11,aRes[04] )
         oRpt:Say( oRpt:nL,23,aRes[05] )
         oRpt:Say( oRpt:nL,64,TRANSFORM(aRes[06],"999,999.99" ))
         oRpt:Say( oRpt:nL,76,aRes[07] )
         oRpt:Say( oRpt:nL,80,TRANSFORM(aRes[08],::aMV[3] ))
         oRpt:Say( oRpt:nL,92,TRANSFORM(aRes[14],"999.99%" ))
       //oRpt:Say( oRpt:nL,92,If( ::aMV[2] == 0, aRes[10], " " ))
      EndIf
      oRpt:nL++
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If (nL == 0 .OR. ::aMV[1] # aRes[1]) .AND. ::aMV[10] > 0
      If oRpt:nPage >= oRpt:nPagI .AND. ::aLS[3] == 1
         oRpt:Say(  oRpt:nL,00,REPLICATE("_",99),,,1 )
         oRpt:Say(++oRpt:nL,11,"TOTAL DEL DIA " +LEFT( NtChr(::aMV[1],"2"),6 ),,,1)
         oRpt:Say(  oRpt:nL,80,TRANSFORM( ::aMV[10],::aMV[3] ))
      EndIf
      oRpt:nL+= If( ::aLS[3] == 1, 3, 0 )
      ::aMV[01] := aRes[1]
      ::aMV[11] += ::aMV[10]
      ::aMV[10] := 0
   EndIf
EndDo
MSFreeResult( hRes )
   ::aMV[2] := ::aMV[5] + ::aMV[9] - ::aMV[6]
If ::aLS[3] == 1
   oRpt:Titulo( 99 )
   oRpt:Say(  oRpt:nL,00,REPLICATE("_",99) )
   oRpt:Say(++oRpt:nL,10,"TOTAL VENTA................."+ TRANSFORM(::aMV[11],::aMV[3]) )
   oRpt:NewPage()
   oRpt:nL := 67
EndIf
   ASIZE( oRpt:aEnc,2 )
   oRpt:cFontI := oRpt:CPINormal
   oRpt:aEnc[1]:= "MOVIMIENTO  DE  VENTAS"
   oRpt:Titulo( 78 )

   oRpt:Say(++oRpt:nL,01,STR(::aMV[04],5) + " FACTURAS" )
   oRpt:Say(++oRpt:nL,10,"Valor    Venta................"+ TRANSFORM(::aMV[05],::aMV[3]) )
   oRpt:Say(++oRpt:nL,10,"Cuentas por Cobrar            "+ TRANSFORM(::aMV[02],::aMV[3]) )
   oRpt:Say(++oRpt:nL,10,"Descuento                     "+ TRANSFORM(::aMV[06],::aMV[3]) )
   oRpt:Say(++oRpt:nL,10,"Ventas    Gravadas" + SPACE(23)+ TRANSFORM(::aMV[07],::aMV[3]) )
   oRpt:Say(++oRpt:nL,10,"Ventas NO Gravadas" + SPACE(23)+ TRANSFORM(::aMV[08],::aMV[3]) )
   oRpt:Say(++oRpt:nL,10,"I.V.A.            " + SPACE(23)+ TRANSFORM(::aMV[09],::aMV[3]) )
   oRpt:NewPage()
   oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserRes( hRes,nL ) CLASS TLived
   LOCAL aRes, nK
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
 ::aMV := { aRes[1],0,"999,999,999",0,0,0,0,0,0,0,0 }
 ::aEnc:= { ::aEnc[1], ::aEnc[2], ::aEnc[3], ::aEnc[4], ::aEnc[5],;
            { .T., 2.5,"FACTURA" } , { .F., 2.7,"CODIGO" }       ,;
            { .F., 4.7,"D E S C R I P C I O N" }                 ,;
            { .T.,15.8,"CANTIDAD" }, { .T.,18.5,"VALOR VENTA" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[7] ,,,, 5 )
  PAGE
While nL > 0
    nK     := If( aRes[10] == 0, 8, 7 )
   ::aMV[02] := If( aRes[11] $ "AD" .AND. aRes[12] <= ::aLS[2], 0, aRes[06] )
   ::aMV[04] ++
   ::aMV[05] += aRes[08]
   ::aMV[06] += aRes[09]
   ::aMV[nK] += aRes[08]
   ::aMV[09] += aRes[10]
   ::aMV[10] += If( ::aMV[2] == 0, 0, aRes[08] )
   If ::aLS[3] == 1
      If aRes[13] == 0
         aRes[13] := aRes[14]
      EndIf
         aRes[16] := AFormula( aRes[06],aRes[07],aRes[15],aRes[16] )
         aRes[13] *= aRes[16]
         aRes[14] := ROUND( ((aRes[08] - aRes[13]) / aRes[13]) * 100,2 )
      ::Cabecera( .t.,0.42 )
      UTILPRN ::oUtil Self:nLinea, 2.5 SAY STR(aRes[03],8) + aRes[02] RIGHT
     //  oRpt:Say( oRpt:nL,00,If( aRes[02] == "C", " ", aRes[02] ) + STR(aRes[03],8) )
      UTILPRN ::oUtil Self:nLinea, 2.7 SAY aRes[04]
      UTILPRN ::oUtil Self:nLinea, 4.7 SAY aRes[05]
      UTILPRN ::oUtil Self:nLinea,15.8 SAY TRANSFORM( aRes[06],"99,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,16.0 SAY aRes[07]
      UTILPRN ::oUtil Self:nLinea,18.5 SAY TRANSFORM( aRes[08],::aMV[3] )     RIGHT
      UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM( aRes[14],"99,999.99%" ) RIGHT
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If (nL == 0 .OR. ::aMV[1] # aRes[1]) .AND. ::aMV[10] > 0
      If ::aLS[3] == 1
         ::Cabecera( .t.,0.42,1.26,20 )
         UTILPRN ::oUtil Self:nLinea, 6.5 SAY "TOTAL DEL DIA " +LEFT( NtChr(::aMV[1],"2"),6 )
         UTILPRN ::oUtil Self:nLinea,18.8 SAY TRANSFORM( ::aMV[10],::aMV[3] ) RIGHT
         ::nLinea += 0.42
      EndIf
      ::aMV[01] := aRes[1]
      ::aMV[11] += ::aMV[10]
      ::aMV[10] := 0
   EndIf
EndDo
MSFreeResult( hRes )
   ::aMV[2] := ::aMV[5] + ::aMV[9] - ::aMV[6]
If ::aLS[3] == 1
   ::Cabecera( .t.,0.42,1.26,20 )
   UTILPRN ::oUtil Self:nLinea, 6.5 SAY "TOTAL VENTA ======>"
   UTILPRN ::oUtil Self:nLinea,18.8 SAY TRANSFORM( ::aMV[11],::aMV[3] ) RIGHT
   ::nLinea := ::nEndLine
EndIf
   ASIZE( ::aEnc,5 )
   ::aEnc[4] := "MOVIMIENTO  DE  VENTAS"
   ::Cabecera( .t.,0.42 )
   UTILPRN ::oUtil SELECT ::aFnt[2]

   UTILPRN ::oUtil 5.0, 1.0 SAY STR(::aMV[04],5) + " FACTURAS"
   UTILPRN ::oUtil 5.5, 2.5 SAY "Valor    Venta"
   UTILPRN ::oUtil 5.5, 8.5 SAY TRANSFORM( ::aMV[05],::aMV[3] ) RIGHT
   UTILPRN ::oUtil 6.0, 2.5 SAY "Cuentas por Cobrar"
   UTILPRN ::oUtil 6.0, 8.5 SAY TRANSFORM( ::aMV[02],::aMV[3] ) RIGHT
   UTILPRN ::oUtil 6.5, 2.5 SAY "Descuento"
   UTILPRN ::oUtil 6.5, 8.5 SAY TRANSFORM( ::aMV[06],::aMV[3] ) RIGHT
   UTILPRN ::oUtil 7.0, 2.5 SAY "Ventas    Gravadas"
   UTILPRN ::oUtil 7.0,11.0 SAY TRANSFORM( ::aMV[07],::aMV[3] ) RIGHT
   UTILPRN ::oUtil 7.5, 2.5 SAY "Ventas NO Gravadas"
   UTILPRN ::oUtil 7.5,11.0 SAY TRANSFORM( ::aMV[08],::aMV[3] ) RIGHT
   UTILPRN ::oUtil 8.0, 2.5 SAY "I.V.A."
   UTILPRN ::oUtil 8.0,11.0 SAY TRANSFORM( ::aMV[09],::aMV[3] ) RIGHT
  ENDPAGE
 ::EndInit( .F. )
RETURN NIL

//-----------------------------------//
METHOD TotalCod() CLASS TLived
   LOCAL aRes, cQry, hRes, nL, oRpt
If ::aLS[6] <= ::aLS[8]
   aRes := ::aTF[::aLS[6]]
   cQry := " AND c.tipo   = '" + aRes + "'"
Else
   aRes := cQry := ""
   AEVAL( ::aTF, { | xV,nP | aRes += xV },1,::aLS[8] )
EndIf
cQry := "SELECT d.codigo, d.unidadmed, SUM(d.cantidad), SUM(d.precioven), "+;
               "d.pcosto, i.descrip, i.unidadmed, i.codcon "+;
        "FROM cadfactc c LEFT JOIN cadfactd d "          +;
         "USING( empresa, numfac, tipo ) "               +;
                        "LEFT JOIN cadinven i "          +;
         "USING( codigo ) "                              +;
        "WHERE c.empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
         " AND c.fechoy >= " + xValToChar( ::aLS[1] )    +;
         " AND c.fechoy <= " + xValToChar( ::aLS[2] )    + cQry +;
         " GROUP BY d.codigo, d.unidadmed, d.pcosto ORDER BY d.codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes ) ; RETURN NIL
EndIf
 ::NEW( "RESUMEN DE VENTAS POR CODIGO - "+aRes )
If ::aLS[9] == 1
   oRpt := TDosPrint()
   oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4], ::aEnc[5],;
             "--CODIGO--  D E S C R I P C I O N--------------  ---CANTIDAD---" +;
             "    VALOR VENTA   VALOR COSTO      UTILIDAD"},::aLS[7],,2 )
Else
   ::aEnc:= { ::aEnc[1], ::aEnc[2], ::aEnc[3], ::aEnc[4], ::aEnc[5],;
             { .F., 1.0,"CODIGO" }     , { .F., 3.7,"D E S C R I P C I O N" },;
             { .T.,12.5,"CANTIDAD" }   , { .T.,14.5,"VALOR VENTA" },;
             { .T.,16.5,"VALOR COSTO" }, { .T.,18.5,"UTILIDAD" } }
   ::Init( ::aEnc[4], .f. ,, !::aLS[7] ,,,, 5 )
     PAGE
EndIf
 aRes := MyReadRow( hRes )
 AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
 ::aMV := { aRes[1],aRes[6],0,0,0,0,0,0,0,0,0 }
While nL > 0
   If aRes[2]  # aRes[7]
      aRes[3] := AFormula( aRes[3],aRes[2],aRes[7],aRes[8] )
   EndIf
    aRes[5] *= aRes[3]
   ::aMV[3] += aRes[3]
   ::aMV[4] += aRes[4]
   ::aMV[5] += aRes[5]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. ::aMV[1] # aRes[1]
      ::aMV[06] := ::aMV[4] - ::aMV[5]
      ::aMV[11] := ROUND( (::aMV[6] / ::aMV[5]) * 100,2 )
      ::aLS[07] := If( ::aLS[3] # 4, .t., If( ::aMV[06] < 0, .t., .f. ) )
      If ::aLS[9] == 1 .AND. ::aLS[7]
         oRpt:Titulo( 118 )
         oRpt:Say( oRpt:nL, 01,::aMV[1] )
         oRpt:Say( oRpt:nL, 13,::aMV[2],35 )
         oRpt:Say( oRpt:nL, 50,TRANSFORM(::aMV[03],  "9,999,999.9999" ))
         oRpt:Say( oRpt:nL, 66,TRANSFORM(::aMV[04],"999,999,999.99" ))
         oRpt:Say( oRpt:nL, 80,TRANSFORM(::aMV[05],"999,999,999.99" ))
         oRpt:Say( oRpt:nL, 94,TRANSFORM(::aMV[06],"999,999,999.99" ))
         oRpt:Say( oRpt:nL,108,TRANSFORM(::aMV[11],"99,999.99%" ))
         oRpt:nL ++
      ElseIf ::aLS[7]
         ::Cabecera( .t.,0.42 )
         UTILPRN ::oUtil Self:nLinea, 1.0 SAY ::aMV[1]
         UTILPRN ::oUtil Self:nLinea, 3.7 SAY ::aMV[2]
         UTILPRN ::oUtil Self:nLinea,12.5 SAY TRANSFORM(::aMV[03],  "9,999,999.9999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,14.5 SAY TRANSFORM(::aMV[04],"999,999,999.99" )   RIGHT
         UTILPRN ::oUtil Self:nLinea,16.5 SAY TRANSFORM(::aMV[05],"999,999,999.99" )   RIGHT
         UTILPRN ::oUtil Self:nLinea,18.5 SAY TRANSFORM(::aMV[06],"999,999,999.99" )   RIGHT
         UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM(::aMV[11],     "99,999.99%" )  RIGHT
      EndIf
      ::aMV[01] :=  aRes[1]
      ::aMV[02] :=  aRes[6]
      ::aMV[07] += ::aMV[3]
      ::aMV[08] += ::aMV[4]
      ::aMV[09] += ::aMV[5]
      ::aMV[10] += ::aMV[6]
      ::aMV[03] := ::aMV[4] := ::aMV[5] := 0
   EndIf
EndDo
If ::aLS[9] == 1
   oRpt:Say(  oRpt:nL,00,REPLICATE("_",118) )
   oRpt:Say(++oRpt:nL,10,"TOTAL VENTA................." )
   oRpt:Say(  oRpt:nL,50,TRANSFORM(::aMV[07],  "9,999,999.9999") )
   oRpt:Say(  oRpt:nL,66,TRANSFORM(::aMV[08],"999,999,999.99" ) )
   oRpt:Say(  oRpt:nL,80,TRANSFORM(::aMV[09],"999,999,999.99" ) )
   oRpt:Say(  oRpt:nL,94,TRANSFORM(::aMV[10],"999,999,999.99" ) )
   oRpt:NewPage()
   oRpt:End()
Else
   ::Cabecera( .t.,0.42,1.26,20 )
   UTILPRN ::oUtil Self:nLinea, 3.7 SAY "TOTAL VENTA ======>"
   UTILPRN ::oUtil Self:nLinea,12.5 SAY TRANSFORM(::aMV[07],  "9,999,999.9999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,14.5 SAY TRANSFORM(::aMV[08],"999,999,999.99" )   RIGHT
   UTILPRN ::oUtil Self:nLinea,16.5 SAY TRANSFORM(::aMV[09],"999,999,999.99" )   RIGHT
   UTILPRN ::oUtil Self:nLinea,18.5 SAY TRANSFORM(::aMV[10],"999,999,999.99" )   RIGHT
  ENDPAGE
 ::EndInit( .F. )
EndIf
RETURN NIL

//------------------------------------//
METHOD ListoTIZ() CLASS TLived
   LOCAL aCP, aFP, aRes, aVT, hRes, nL, oRpt, nK := 1
 aVT := { { "",0,0,0,0,0,0,0,0 } }
hRes := ::NEW( "TIRILLA Z",7 )
If (nL  := MSNumRows( hRes )) > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   ::aMV := { aRes[1],aRes[2],aRes[3],aRes[4],aRes[5] }
   aVT[1,1] := aRes[1]
   aVT[1,2] := aRes[2]
EndIf
 ::nFC := 0
While nL > 0
   If ::aMV[1]  # aRes[1]
      ::aMV[1] := aRes[1]
      ::aMV[2] := aRes[2]
      If (nK := ASCAN( aVT,{ |aX| aX[1] == aRes[1] } )) == 0
         AADD( aVT,{ aRes[1],aRes[2],0,0,0,0,0,0,0 } )
         nK := LEN( aVT )
      EndIf
   EndIf
   aRes[12] := AFormula( aRes[06],aRes[07],aRes[11],aRes[12] )
   aRes[10] *= aRes[12]
   If aRes[9] > 0
      aVT[nK,5] += aRes[8]   //Gravadas
   Else
      aVT[nK,4] += aRes[8]
   EndIf
      aVT[nK,8] += aRes[10]  //PCosto
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. ::aMV[1] # aRes[1] .OR. ::aMV[2] # aRes[2]
      If ::aMV[5]
         ::nFC += ::aMV[4]
      EndIf
      aVT[nK,3] := ::aMV[2]
      aVT[nK,6] += ::aMV[3]
      aVT[nK,7] += ::aMV[4]
      aVT[nK,9] := aVT[nK,4] + aVT[nK,5] - aVT[nK,8]
      ::aMV := { aRes[1],aRes[2],aRes[3],aRes[4],aRes[5] }
   EndIf
EndDo
   MSFreeResult( hRes )
 aCP := {}
 aFP := ArrayCombo( "CPAGO" )
 AEVAL( aFP, {|x| AADD( aCP, { x[1],0 } ) } )
 aFP := ArrayCombo( "FPAGO" )
 ::aMV := { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 }
// Gastos
 hRes := ::NEW( "TIRILLA Z",9 )
 nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aRes[1] == "99"
      ::aMV[14] += aRes[2]
   Else
      ::aMV[15] += aRes[2]
   EndIf
   nL --
EndDo
   MSFreeResult( hRes )
hRes := ::NEW( "REPORTE DE VENTAS - TIRILLA Z",8 )
If (nL := MSNumRows( hRes )) == 0 .AND. aVT[1,3] == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[9] == 2
   ::LaserTIZ( aCP,aFP,aVT,hRes,nL )
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4],::aEnc[5] },::aLS[7],1,2 )
 oRpt:Titulo( 80 )
 oRpt:Say( 07,30,"VENTAS         VENTAS" )
 oRpt:Say( 08,04,"F A C T U R A S      NO GRAVADAS        GRAVADAS          "+;
                 "I.V.A.    TOTAL VENTAS     TOTAL COSTO        UTILIDAD" )
 oRpt:nL := 09
FOR nK := 1 TO LEN( aVT )
   ::aMV[6] := aVT[nK,7] - aVT[nK,4] - aVT[nK,5] - aVT[nK,6]
   ::aMV[7] := ROUND( (aVT[nK,9] / aVT[nK,8]) * 100,2 )
   oRpt:Say( oRpt:nL, 00,aVT[nK,1] + STR(aVT[nK,2],8) + "  AL" +;
                                     STR(aVT[nK,3],7) + If( ::aMV[6] # 0, " *", "" ) )
   oRpt:Say( oRpt:nL, 22,TRANSFORM( aVT[nK,4],"99,999,999,999" ) )
   oRpt:Say( oRpt:nL, 38,TRANSFORM( aVT[nK,5],"99,999,999,999" ) )
   oRpt:Say( oRpt:nL, 54,TRANSFORM( aVT[nK,6],"99,999,999,999" ) )
   oRpt:Say( oRpt:nL, 70,TRANSFORM( aVT[nK,7],"99,999,999,999" ) )
   oRpt:Say( oRpt:nL, 86,TRANSFORM( aVT[nK,8],"99,999,999,999" ) )
   oRpt:Say( oRpt:nL,102,TRANSFORM( aVT[nK,9],"99,999,999,999" ) )
   oRpt:Say( oRpt:nL,116,TRANSFORM(  ::aMV[7],"99,999.99%" ))
   oRpt:nL ++
NEXT nK
 oRpt:Say( oRpt:nL,20,REPLICATE("_",96) )
 oRpt:nL += 5
 oRpt:Say( oRpt:nL,20,"I N G R E S O S" )
 oRpt:nL += 2
 oRpt:Say( oRpt:nL,56,"DEDUCCION   RET.RENTA   RETEN.IVA   RETEN.ICA     VALOR NETO" )
 oRpt:nL ++
   ::aMV[6] := 0
If nL == 0
   ::aMV[1] := ::aMV[6] := ::nFC
Else
   aRes := MyReadRow( hRes )
   AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   ::aMV[7] := aRes[2]
EndIf
While nL > 0
     nK      :=  aRes[1]
   aCP[nK,2] +=  aRes[8]
   ::aMV[08] +=  aRes[8]
   ::aMV[09] += (aRes[3] + aRes[4])
   ::aMV[10] +=  aRes[5]
   ::aMV[11] +=  aRes[6]
   ::aMV[12] +=  aRes[7]
   ::aMV[13] +=  aRes[8]
   If aRes[2] <= 2
      If aRes[2] == 1
         ::aMV[08] += ::nFC
         ::aMV[13] += ::nFC
         ::nFC := 0
      EndIf
      ::aMV[08] += (aRes[3] + aRes[5] + aRes[6] + aRes[7])
   ElseIf aRes[1] <= 4
      ::aMV[13] -= (aRes[4] + aRes[5] + aRes[6] + aRes[7])
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. ::aMV[7] # aRes[2]
      oRpt:Titulo( 126 )
      oRpt:Say( oRpt:nL, 10,aFP[::aMV[7],1] )
      oRpt:Say( oRpt:nL, 37,TRANSFORM( ::aMV[08],   "99,999,999.99") )
      oRpt:Say( oRpt:nL, 52,TRANSFORM( ::aMV[09],"@Z 99,999,999.99") )
      oRpt:Say( oRpt:nL, 67,TRANSFORM( ::aMV[10],"@Z 99,999,999") )
      oRpt:Say( oRpt:nL, 79,TRANSFORM( ::aMV[11],"@Z 99,999,999") )
      oRpt:Say( oRpt:nL, 91,TRANSFORM( ::aMV[12],"@Z 99,999,999") )
      oRpt:Say( oRpt:nL,103,TRANSFORM( ::aMV[13],   "99,999,999.99") )
      oRpt:nL++
      If ::aMV[7] <= 4
         ::aMV[1] += ::aMV[08]
         ::aMV[2] += ::aMV[09]
         ::aMV[3] += ::aMV[10]
         ::aMV[4] += ::aMV[11]
         ::aMV[5] += ::aMV[12]
         ::aMV[6] += ::aMV[13]
      EndIf
         ::aMV[7] := aRes[2]
      AFILL( ::aMV,0,8,6 )
   EndIf
EndDo
MSFreeResult( hRes )
 oRpt:Say(  oRpt:nL, 10,REPLICATE("=",106) )
 oRpt:Say(++oRpt:nL, 10,"TOTAL INGRESOS" )
 oRpt:Say(  oRpt:nL, 36,TRANSFORM(::aMV[1],"999,999,999.99") )
 oRpt:Say(  oRpt:nL, 52,TRANSFORM(::aMV[2], "99,999,999.99") )
 oRpt:Say(  oRpt:nL, 67,TRANSFORM(::aMV[3], "99,999,999") )
 oRpt:Say(  oRpt:nL, 79,TRANSFORM(::aMV[4], "99,999,999") )
 oRpt:Say(  oRpt:nL, 91,TRANSFORM(::aMV[5], "99,999,999") )
 oRpt:Say(  oRpt:nL,102,TRANSFORM(::aMV[6],"999,999,999.99") )
 oRpt:nL++
FOR nK := 1 TO LEN( aCP )
   If aCP[nK,2] > 0
      oRpt:Say(++oRpt:nL, 10,"POR " + aCP[nK,1] )
      oRpt:Say(  oRpt:nL, 36,TRANSFORM( aCP[nK,2],"999,999,999.99") )
   EndIf
NEXT nK
 oRpt:nL += 5
 oRpt:Say( oRpt:nL,20,"G A S T O S" )
 oRpt:nL += 2
 oRpt:Say(  oRpt:nL, 10,"EN EFECTIVO" )
 oRpt:Say(  oRpt:nL, 36,TRANSFORM(::aMV[14],"999,999,999.99") )
If ::aMV[15] > 0
   ::aMV[14] += ::aMV[15]
 oRpt:Say(++oRpt:nL, 10,"EN CHEQUES" )
 oRpt:Say(  oRpt:nL, 36,TRANSFORM(::aMV[15],"999,999,999.99") )
 oRpt:Say(++oRpt:nL, 10,REPLICATE("=",40) )
 oRpt:Say(++oRpt:nL, 10,"TOTAL GASTOS" )
 oRpt:Say(  oRpt:nL, 36,TRANSFORM(::aMV[14],"999,999,999.99") )
EndIf
 oRpt:NewPage()
 oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserTIZ( aCP,aFP,aVT,hRes,nL ) CLASS TLived
   LOCAL aRes, nK
 ::Init( ::aEnc[4], .f. ,, !::aLS[7] ,,,, 5 )
  PAGE
   ::Cabecera( .t.,0.45 )
   ::nLinea := 5
   UTILPRN ::oUtil 04.0,04.9 SAY "VENTAS             VENTAS"
   UTILPRN ::oUtil 04.5,01.1 SAY "F A C T U R A S"
   UTILPRN ::oUtil 04.5,06.0 SAY "NO GRAVADAS"  RIGHT
   UTILPRN ::oUtil 04.5,08.5 SAY    "GRAVADAS"  RIGHT
   UTILPRN ::oUtil 04.5,11.0 SAY "I.V.A."       RIGHT
   UTILPRN ::oUtil 04.5,13.5 SAY "TOTAL VENTAS" RIGHT
   UTILPRN ::oUtil 04.5,16.0 SAY "TOTAL COSTO"  RIGHT
   UTILPRN ::oUtil 04.5,18.5 SAY "UTILIDAD"     RIGHT
FOR nK := 1 TO LEN( aVT )
   ::aMV[6] := aVT[nK,7] - aVT[nK,4] - aVT[nK,5] - aVT[nK,6]
   ::aMV[7] := ROUND( (aVT[nK,9] / aVT[nK,8]) * 100,2 )
   UTILPRN ::oUtil Self:nLinea,00.6 SAY aVT[nK,1] + STR(aVT[nK,2],8)
   UTILPRN ::oUtil Self:nLinea,02.3 SAY      "AL" + STR(aVT[nK,3],7) +;
                                        If( ::aMV[6] # 0, " *", "" )
   UTILPRN ::oUtil Self:nLinea,06.0 SAY TRANSFORM( aVT[nK,4],"99,999,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,08.5 SAY TRANSFORM( aVT[nK,5],"99,999,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,11.0 SAY TRANSFORM( aVT[nK,6],"99,999,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,13.5 SAY TRANSFORM( aVT[nK,7],"99,999,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,16.0 SAY TRANSFORM( aVT[nK,8],"99,999,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,18.5 SAY TRANSFORM( aVT[nK,9],"99,999,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM(  ::aMV[7],    "99,999.99%" ) RIGHT
   ::nLinea += 0.50
NEXT nK
   UTILPRN ::oUtil LINEA Self:nLinea,3.5 TO Self:nLinea,18.5 PEN ::oPen
   ::nLinea += 1.00
   UTILPRN ::oUtil Self:nLinea,06.0 SAY "I N G R E S O S" FONT ::aFnt[2]
   ::nLinea += 0.50
   UTILPRN ::oUtil Self:nLinea,11.0 SAY "DEDUCCION"  RIGHT
   UTILPRN ::oUtil Self:nLinea,12.8 SAY "RET.RENTA"  RIGHT
   UTILPRN ::oUtil Self:nLinea,14.5 SAY "RETEN.IVA"  RIGHT
   UTILPRN ::oUtil Self:nLinea,16.3 SAY "RETEN.ICA"  RIGHT
   UTILPRN ::oUtil Self:nLinea,18.5 SAY "VALOR NETO" RIGHT
   ::aMV[6] := 0
If nL == 0
   ::aMV[1] := ::aMV[6] := ::nFC
Else
   aRes := MyReadRow( hRes )
   AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   ::aMV[7] := aRes[2]
EndIf
While nL > 0
     nK      :=  aRes[1]
   aCP[nK,2] +=  aRes[8]
   ::aMV[08] +=  aRes[8]
   ::aMV[09] += (aRes[3] + aRes[4])
   ::aMV[10] +=  aRes[5]
   ::aMV[11] +=  aRes[6]
   ::aMV[12] +=  aRes[7]
   ::aMV[13] +=  aRes[8]
   If aRes[2] <= 2
      If aRes[2] == 1
         ::aMV[08] += ::nFC
         ::aMV[13] += ::nFC
         ::nFC := 0
      EndIf
      ::aMV[08] += (aRes[3] + aRes[5] + aRes[6] + aRes[7])
   ElseIf aRes[1] <= 4
      ::aMV[13] -= (aRes[4] + aRes[5] + aRes[6] + aRes[7])
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. ::aMV[7] # aRes[2]
      ::Cabecera( .t.,0.45 )
      UTILPRN ::oUtil Self:nLinea,02.5 SAY aFP[::aMV[7],1]
      UTILPRN ::oUtil Self:nLinea,08.8 SAY TRANSFORM( ::aMV[08],   "99,999,999.99" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,11.0 SAY TRANSFORM( ::aMV[09],"@Z 99,999,999.99" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,12.8 SAY TRANSFORM( ::aMV[10],"@Z 99,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,14.5 SAY TRANSFORM( ::aMV[11],"@Z 99,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,16.3 SAY TRANSFORM( ::aMV[12],"@Z 99,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,18.5 SAY TRANSFORM( ::aMV[13],   "99,999,999.99" ) RIGHT
      If ::aMV[7] <= 4
         ::aMV[1] += ::aMV[08]
         ::aMV[2] += ::aMV[09]
         ::aMV[3] += ::aMV[10]
         ::aMV[4] += ::aMV[11]
         ::aMV[5] += ::aMV[12]
         ::aMV[6] += ::aMV[13]
      EndIf
         ::aMV[7] := aRes[2]
      AFILL( ::aMV,0,8,6 )
   EndIf
EndDo
MSFreeResult( hRes )
    ::nLinea += 0.5
    UTILPRN ::oUtil LINEA Self:nLinea,2.5 TO Self:nLinea,18.5 PEN ::oPen
    UTILPRN ::oUtil Self:nLinea,02.5 SAY "TOTAL INGRESOS"
    UTILPRN ::oUtil Self:nLinea,08.8 SAY TRANSFORM( ::aMV[1],"999,999,999.99" ) RIGHT
    UTILPRN ::oUtil Self:nLinea,11.0 SAY TRANSFORM( ::aMV[2], "99,999,999.99" ) RIGHT
    UTILPRN ::oUtil Self:nLinea,12.8 SAY TRANSFORM( ::aMV[3], "99,999,999" )    RIGHT
    UTILPRN ::oUtil Self:nLinea,14.5 SAY TRANSFORM( ::aMV[4], "99,999,999" )    RIGHT
    UTILPRN ::oUtil Self:nLinea,16.3 SAY TRANSFORM( ::aMV[5], "99,999,999" )    RIGHT
    UTILPRN ::oUtil Self:nLinea,18.5 SAY TRANSFORM( ::aMV[6],"999,999,999.99" ) RIGHT
      ::nLinea += 0.6
FOR nK := 1 TO LEN( aCP )
   If aCP[nK,2] > 0
      ::nLinea += 0.5
      UTILPRN ::oUtil Self:nLinea,02.5 SAY "POR " + aCP[nK,1]
      UTILPRN ::oUtil Self:nLinea,08.8 SAY TRANSFORM( aCP[nK,2],"999,999,999.99" ) RIGHT
   EndIf
NEXT nK
    ::nLinea += 1.00
    UTILPRN ::oUtil Self:nLinea,06.0 SAY "G A S T O S" FONT ::aFnt[2]
    ::nLinea += 0.50
    UTILPRN ::oUtil Self:nLinea,02.5 SAY "EN EFECTIVO"
    UTILPRN ::oUtil Self:nLinea,08.8 SAY TRANSFORM( ::aMV[14],"999,999,999.99" ) RIGHT
 If ::aMV[15] > 0
    ::aMV[14] += ::aMV[15]
    ::nLinea += 0.50
    UTILPRN ::oUtil Self:nLinea,02.5 SAY "EN CHEQUES"
    UTILPRN ::oUtil Self:nLinea,08.8 SAY TRANSFORM( ::aMV[15],"999,999,999.99" ) RIGHT
    ::nLinea += 0.50
    UTILPRN ::oUtil LINEA Self:nLinea,2.5 TO Self:nLinea, 8.8 PEN ::oPen
    UTILPRN ::oUtil Self:nLinea,02.5 SAY "TOTAL GASTOS"
    UTILPRN ::oUtil Self:nLinea,08.8 SAY TRANSFORM( ::aMV[15],"999,999,999.99" ) RIGHT
 EndIf
   ENDPAGE
IMPRIME END .F.
RETURN NIL

//------------------------------------//
FUNCTION TipoFac( lTodas )
   LOCAL aTF := {}, cTipo, cTF, nT
   cTipo := ALLTRIM(oApl:oEmp:TIPOFAC)
   cTF   := Saca( @cTipo,"," )
If !lTodas
   cTipo := cTF
EndIf
FOR nT := 1 TO LEN( cTipo )
  AADD( aTF,SUBSTR( cTipo,nT,1 ) )
NEXT nT
  AADD( aTF,"Todas" )
RETURN aTF