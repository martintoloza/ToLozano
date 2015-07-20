// Programa.: CSJLIREC.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Ingresos de Liq., Acces. y L.Contacto
#include "FiveWin.ch"
#include "btnget.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE CSJLIREC( nOpc,aLS )
   LOCAL oLF, oDlg, oGet := ARRAY(7)
   DEFAULT nOpc := 1
 oLF := TLTurista()
If aLS # NIL
   oLF:aLS := ACLONE( aLS )
   oLF:ListoRec()
   RETURN
EndIf
oLF:aLS := { DATE(),DATE(),1,oApl:nTFor,.t.,0,"" }
 aLS := { { {|| oLF:ListoRec() },"Listado de Recaudos" } ,;
          { {|| oLF:ListoTur() },"Listado de Turistas" } ,;
          { {|| oLF:ListoTur() },"Resumen de Compras por Proveedor" } }
DEFINE DIALOG oDlg TITLE aLS[nOpc,2] FROM 0, 0 TO 11,60
   @ 02, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 01, 82 GET oGet[1] VAR oLF:aLS[1] OF oDlg SIZE 40,10 PIXEL
   @ 14, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 14, 82 GET oGet[2] VAR oLF:aLS[2] OF oDlg SIZE 40,10 PIXEL;
      VALID oLF:aLS[2] >= oLF:aLS[1]
   @ 26, 00 SAY "Resumen por" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 26, 82 COMBOBOX oGet[3] VAR oLF:aLS[3] ITEMS {"Entradas","Salidas","En el Cabo"};
      SIZE 48,90 OF oDlg PIXEL
   // WHEN nOpc == 2
   @ 38, 00 SAY "TIPO DE IMPRESORA"    OF oDlg RIGHT PIXEL SIZE 80,10
   @ 38, 82 COMBOBOX oGet[4] VAR oLF:aLS[4] ITEMS { "Matriz","Laser" };
      SIZE 40,90 OF oDlg PIXEL
   @ 38,134 CHECKBOX oGet[5] VAR oLF:aLS[5] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 52, 50 BUTTON oGet[6] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[6]:Disable(), EVAL( aLS[nOpc,1] ), oGet[6]:Enable(),;
        oGet[6]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 52,100 BUTTON oGet[7] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 58, 02 SAY "[CSJLITUR]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED

RETURN

//------------------------------------//
CLASS TLTurista FROM TIMPRIME

 DATA aLS, aGT

 METHOD NEW( cTit,hRes ) Constructor
 METHOD ListoRec()
 METHOD LaserRec( hRes,nL )
 METHOD ListoTur( nL )
 METHOD LaserTur( hRes,nL )
ENDCLASS

//------------------------------------//
METHOD NEW( cTit,hRes ) CLASS TLTurista
If hRes == NIL
   ::aGT[2] := Buscar( "SELECT COUNT(*) + CAST(SUM(amigos) AS UNSIGNED INTEGER) FROM cadfactc "+;
                       "WHERE empresa   = " + STR(oApl:nEmpresa)    +;
                        " AND fechacan >= " + xValToChar( ::aLS[1] )+;
                        " AND fechacan <= " + xValToChar( ::aLS[2] )+;
                        " AND tipo = 'A' AND indicador = 'C'","CM",,8,,4 )
   ::aGT[5] := ::aGT[3] + ::aGT[4]
   //En El Cabo
   ::aGT[6] := Buscar( "SELECT COUNT(*) + CAST(SUM(amigos) AS UNSIGNED INTEGER) "+;
                       "FROM cadfactc c, cadfacte e "                            +;
                       "WHERE e.factc_id = c.row_id AND e.estado = 'P'","CM",,8,,4 )
Else
   ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit, cTit , "" }
   If ::aLS[1] == ::aLS[2]
      ::aEnc[5] := NtChr( ::aLS[1],"3" )
   Else
      ::aEnc[5] := "DESDE " + NtChr(::aLS[1],"2" ) + " HASTA " + NtChr(::aLS[2],"2" )
   EndIf
   If hRes == 1
      ::aGT := { 0,0,0,0,0,"F"  }
      cTit := "SELECT numfac FAC, 'F' CLA, cliente, totalfac, amigos "+;
              "FROM cadfactc "                              +;
              "WHERE empresa    = " + STR(oApl:nEmpresa)    +;
               " AND fechoy    >= " + xValToChar( ::aLS[1] )+;
               " AND fechoy    <= " + xValToChar( ::aLS[2] )+;
               " AND tipo       = 'A'"                      +;
               " AND indicador <> 'A'"                      +;
               " UNION ALL "                                +;
              "SELECT c.numfac FAC, 'P' CLA, c.cliente, p.pagado, 0 "+;
              "FROM cadpagos p LEFT JOIN cadfactc c "       +;
             "USING( empresa, numfac, tipo )"               +;
              "WHERE p.empresa  = " + STR(oApl:nEmpresa)    +;
               " AND p.fecpag  >= " + xValToChar( ::aLS[1] )+;
               " AND p.fecpag  <= " + xValToChar( ::aLS[2] )+;
               " AND p.tipo     = 'A' ORDER BY CLA, FAC"
   ElseIf hRes == 2
/*
      cTit := "SELECT c.numfac, g.row_id, c.fechoy, c.totalfac, t.nombres, u.nombres " +;
              "FROM ((cadfactg g LEFT JOIN turista  t ON g.turista_id = t.turista_id) "+;
                               "RIGHT JOIN cadfactc c ON c.row_id = g.factc_id) "      +;
                               "INNER JOIN turista  u ON c.turista_id = u.turista_id " +;
              "GROUP BY c.numfac, g.row_id ORDER BY c.numfac, g.row_id"
*/
      cTit := "SELECT c.numfac FAC, 'F' CLA, c.fechoy, c.totalfac, t.nombres TUR "    +;
              "FROM cadfactc c LEFT JOIN turista  t ON c.turista_id = t.turista_id "  +;
              "WHERE empresa    = " + STR(oApl:nEmpresa)    +;
               " AND fechoy    >= " + xValToChar( ::aLS[1] )+;
               " AND fechoy    <= " + xValToChar( ::aLS[2] )+;
               " AND tipo       = 'A'"                      +;
               " AND indicador <> 'A' "                     +;
              "UNION ALL "                                  +;
              "SELECT c.numfac FAC, 'G' CLA, c.fechoy, c.totalfac, t.nombres TUR "    +;
              "FROM ((cadfactg g LEFT JOIN turista  t ON g.turista_id = t.turista_id)"+;
                              " INNER JOIN cadfactc c ON c.row_id = g.factc_id) "     +;
              "WHERE empresa    = " + STR(oApl:nEmpresa)    +;
               " AND fechoy    >= " + xValToChar( ::aLS[1] )+;
               " AND fechoy    <= " + xValToChar( ::aLS[2] )+;
               " AND tipo       = 'A'"                      +;
               " AND indicador <> 'A' ORDER BY FAC, CLA, TUR"
   ElseIf hRes == 3
      cTit := "SELECT c.numfac FAC, 'F' CLA, c.fechacan, c.totalfac, t.nombres TUR "  +;
              "FROM cadfactc c LEFT JOIN turista  t ON c.turista_id = t.turista_id "  +;
              "WHERE empresa    = " + STR(oApl:nEmpresa)    +;
               " AND fechacan  >= " + xValToChar( ::aLS[1] )+;
               " AND fechacan  <= " + xValToChar( ::aLS[2] )+;
               " AND tipo       = 'A'"                      +;
               " AND indicador  = 'C' "                     +;
              "UNION ALL "                                  +;
              "SELECT c.numfac FAC, 'G' CLA, c.fechacan, c.totalfac, t.nombres TUR "  +;
              "FROM ((cadfactg g LEFT JOIN turista  t ON g.turista_id = t.turista_id)"+;
                              " INNER JOIN cadfactc c ON c.row_id = g.factc_id) "     +;
              "WHERE empresa    = " + STR(oApl:nEmpresa)    +;
               " AND fechacan  >= " + xValToChar( ::aLS[1] )+;
               " AND fechacan  <= " + xValToChar( ::aLS[2] )+;
               " AND tipo       = 'A'"                      +;
               " AND indicador  = 'C' ORDER BY FAC, CLA, TUR"
   ElseIf hRes == 4
      cTit := "SELECT c.numfac FAC, 'F' CLA, CAST(e.fecha_sal AS DATE) FEC, c.totalfac, t.nombres "+;
              "FROM ((cadfacte e INNER JOIN cadfactc c ON e.factc_id   = c.row_id) "    +;
                                "INNER JOIN turista  t ON c.turista_id = t.turista_id) "+;
              "WHERE e.estado  = 'P' "+;
              "UNION ALL "            +;
              "SELECT c.numfac FAC, 'F' CLA, CAST(e.fecha_sal AS DATE) FEC, c.totalfac, t.nombres "+;
              "FROM ((cadfacte e INNER JOIN cadfactg g ON g.factc_id   = e.factc_id "   +;
                                "INNER JOIN turista  t ON g.turista_id = t.turista_id) "+;
                                "INNER JOIN cadfactc c ON e.factc_id   = c.row_id) "    +;
              "WHERE e.estado  = 'P' "+;
              "ORDER BY FEC, FAC, CLA"
   ElseIf hRes == 5
      cTit := "SELECT n.codigo, n.digito, n.nombre, c.ingreso, "+;
                     "c.totalfac, d.orden, d.valor "            +;
              "FROM cadartic c LEFT JOIN cadclien n USING( codigo_nit ) " +;
                              "LEFT JOIN comprasd d "                     +;
                 "ON c.row_id    = d.comprasc_id AND d.orden IN(4, 6, 7, 8) "+;
              "WHERE c.empresa   = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND c.fecingre >= " + xValToChar( ::aLS[1] )  +;
               " AND c.fecingre <= " + xValToChar( ::aLS[2] )  +;
               " AND c.totalfac  > 0 ORDER BY n.codigo, c.ingreso"
   EndIf
   hRes := If( MSQuery( oApl:oMySql:hConnect,cTit ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
EndIf
RETURN hRes

//------------------------------------//
METHOD ListoRec() CLASS TLTurista
   LOCAL aRes, hRes, nL, oRpt
hRes := ::NEW( "RECAUDOS",1 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[4] == 2
   ::LaserRec( hRes,nL )
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4], ::aEnc[5],;
          "   FACTURA  T U R I S T A                              VALOR PAGO"},::aLS[5] )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
   oRpt:Titulo( 79 )
   If ::aGT[6]  # aRes[2]
      ::aGT[6] := aRes[2]
      oRpt:Say( oRpt:nL,00,"======P A G O S======" )
      oRpt:nL++
   EndIf
   oRpt:Say( oRpt:nL,00,STR(aRes[1]) )
   oRpt:Say( oRpt:nL,12,aRes[3] )
   oRpt:Say( oRpt:nL,54,TRANSFORM(aRes[4],"999,999,999" ))
   oRpt:nL++
   If aRes[2] == "F"
      ::aGT[1] += (aRes[5] + 1)
      ::aGT[3] +=  aRes[4]
   Else
      ::aGT[4] +=  aRes[4]
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
 ::NEW( "RECAUDOS" )
aRes := SPACE(11)
   oRpt:Separator( 1,8 )
   oRpt:Say(++oRpt:nL,26,"INGRESOS FACTURA:" + aRes +;
              TRANSFORM( ::aGT[3],"999,999,999" ))
   oRpt:Say(++oRpt:nL,26,"INGRESOS PAGOS  :" + aRes +;
              TRANSFORM( ::aGT[4],"999,999,999" ))
   oRpt:Say(++oRpt:nL,52,"=============" )
   oRpt:Say(++oRpt:nL,26,"TOTAL INGRESOS  :" + aRes +;
              TRANSFORM( ::aGT[5],"999,999,999" ))
   oRpt:nL++
   oRpt:Say(++oRpt:nL,02,"ENTRADA TURISTAS:" + aRes +;
              TRANSFORM( ::aGT[1],"999,999,999" ))
   oRpt:Say(++oRpt:nL,02,"SALIDAS TURISTAS:" + aRes +;
              TRANSFORM( ::aGT[2],"999,999,999" ))
   oRpt:Say(++oRpt:nL,02,"TURISTAS x SALIR:" + aRes +;
              TRANSFORM( ::aGT[6],"999,999,999" ))
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserRec( hRes,nL ) CLASS TLTurista
   LOCAL aRes
 ::aEnc := { .t., ::aEnc[2], ::aEnc[3] , ::aEnc[4], ::aEnc[5],;
             { .F., 0.5,"","FACTURA" } , { .F., 2.7,"","T U R I S T A" },;
             { .T.,19.5,"","VALOR PAGO" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[5] ,,, ::aLS[5] )
 ::nMD := 19.5
  PAGE
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
   ::Cabecera( .t.,0.42 )
   If ::aGT[6]  # aRes[2]
      ::aGT[6] := aRes[2]
      UTILPRN ::oUtil Self:nLinea, 2.5 SAY "======P A G O S======"
  	  ::nLinea += .50
   EndIf
   UTILPRN ::oUtil Self:nLinea, 2.4 SAY STR(aRes[1]) RIGHT
   UTILPRN ::oUtil Self:nLinea, 2.7 SAY aRes[3]
   UTILPRN ::oUtil Self:nLinea,19.5 SAY TRANSFORM( aRes[4],"999,999,999" ) RIGHT
   If aRes[2] == "F"
      ::aGT[1] += (aRes[5] + 1)
      ::aGT[3] +=  aRes[4]
   Else
      ::aGT[4] +=  aRes[4]
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
 ::NEW( "RECAUDOS" )
   ::Cabecera( .t.,0.40,4.00,19.5 )
   UTILPRN ::oUtil Self:nLinea,13.0 SAY "INGRESOS FACTURA"
   UTILPRN ::oUtil Self:nLinea,19.5 SAY TRANSFORM( ::aGT[3],"999,999,999" ) RIGHT
   ::nLinea += .50
   UTILPRN ::oUtil Self:nLinea,13.0 SAY "INGRESOS PAGOS"
   UTILPRN ::oUtil Self:nLinea,19.5 SAY TRANSFORM( ::aGT[4],"999,999,999" ) RIGHT
   ::nLinea += .50
   UTILPRN ::oUtil Self:nLinea,19.5 SAY "============="                   RIGHT
   ::nLinea += .50
   UTILPRN ::oUtil Self:nLinea,13.0 SAY "TOTAL INGRESOS"
   UTILPRN ::oUtil Self:nLinea,19.5 SAY TRANSFORM( ::aGT[5],"999,999,999" ) RIGHT
   ::nLinea += .50
   UTILPRN ::oUtil Self:nLinea, 2.7 SAY "ENTRADA TURISTAS"
   UTILPRN ::oUtil Self:nLinea, 9.5 SAY TRANSFORM( ::aGT[1],"999,999,999" ) RIGHT
   ::nLinea += .50
   UTILPRN ::oUtil Self:nLinea, 2.7 SAY "SALIDAS TURISTAS"
   UTILPRN ::oUtil Self:nLinea, 9.5 SAY TRANSFORM( ::aGT[2],"999,999,999" ) RIGHT
   ::nLinea += .50
   UTILPRN ::oUtil Self:nLinea, 2.7 SAY "TURISTAS x SALIR"
   UTILPRN ::oUtil Self:nLinea, 9.5 SAY TRANSFORM( ::aGT[6],"999,999,999" ) RIGHT
  ENDPAGE
 ::EndInit( .F. )
RETURN NIL

//------------------------------------//
METHOD ListoTur() CLASS TLTurista
   LOCAL aRes, hRes, nL, oRpt
If ::aLS[3] == 1
   ::aLS[7] := "FEC.FACTURA"
   hRes := ::NEW( "Entradas de Turistas",2 )
ElseIf ::aLS[3] == 2
   ::aLS[7] := "FEC.DE IDA "
   hRes := ::NEW( "Salidas de Turistas",3 )
Else
   ::aLS[7] := "FEC.SALIDA "
   hRes := ::NEW( "Turistas en el CABO",4 )
EndIf
   ::aGT := { 0,0,0,0 }
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[4] == 2
   ::LaserTur( hRes,nL )
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4], ::aEnc[5],;
          "   FACTURA  " + ::aLS[7] + " VALOR FACTURA  T U R I S T A"},::aLS[5] )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      oRpt:Titulo( 94 )
   If ::aGT[1]  # aRes[1]
      ::aGT[1] := aRes[1]
      ::aGT[2] ++
      oRpt:Say( oRpt:nL,00,STR(aRes[1]) )
      oRpt:Say( oRpt:nL,12,NtChr(aRes[3],"2") )
      oRpt:Say( oRpt:nL,26,TRANSFORM(aRes[4],"999,999,999" ))
   EndIf
   oRpt:Say( oRpt:nL,39,aRes[5] )
   oRpt:nL++
   ::aGT[3] ++
   ::aGT[4] += aRes[4]
   nL --
EndDo
MSFreeResult( hRes )
oRpt:Separator( 1,3 )
oRpt:Say(  oRpt:nL,00,REPLICATE("_",94) )
oRpt:Say(++oRpt:nL, 6,STR( ::aGT[2],4 ) + " FACTURAS" )
oRpt:Say(  oRpt:nL,26,TRANSFORM(::aGT[4],"999,999,999") )
oRpt:Say(++oRpt:nL, 6,STR( ::aGT[3],4 ) + " TURISTAS" )
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserTur( hRes,nL ) CLASS TLTurista
   LOCAL aRes
 ::aEnc := { .t., ::aEnc[2], ::aEnc[3], ::aEnc[4], ::aEnc[5]     ,;
             { .T., 2.4,"FACTURA" }      , { .F., 2.8,::aLS[7] } ,;
             { .T., 8.0,"VALOR FACTURA" }, { .F., 8.3,"T U R I S T A" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[5] ,,, ::aLS[5], 5 )
 ::nMD := 20.5
  PAGE
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   ::Cabecera( .t.,0.42 )
   If ::aGT[1]  # aRes[1]
      ::aGT[1] := aRes[1]
      ::aGT[2] ++
      UTILPRN ::oUtil Self:nLinea, 2.4 SAY STR(aRes[1]) RIGHT
      UTILPRN ::oUtil Self:nLinea, 2.7 SAY NtChr(aRes[3],"2")
      UTILPRN ::oUtil Self:nLinea, 8.0 SAY TRANSFORM( aRes[4],"999,999,999" ) RIGHT
   EndIf
      UTILPRN ::oUtil Self:nLinea, 8.3 SAY aRes[5]
   ::aGT[3] ++
   ::aGT[4] += aRes[4]
   nL --
EndDo
MSFreeResult( hRes )
   ::Cabecera( .t.,0.40,0.82,20.5 )
      UTILPRN ::oUtil Self:nLinea, 2.4 SAY STR(::aGT[2]) RIGHT
      UTILPRN ::oUtil Self:nLinea, 2.7 SAY "FACTURAS"
      UTILPRN ::oUtil Self:nLinea, 8.0 SAY TRANSFORM( ::aGT[4],"999,999,999" ) RIGHT
      ::nLinea += .41
      UTILPRN ::oUtil Self:nLinea, 2.4 SAY STR(::aGT[3]) RIGHT
      UTILPRN ::oUtil Self:nLinea, 2.7 SAY "TURISTAS"
  ENDPAGE
 ::EndInit( .F. )
RETURN NIL