// Programa.: JVMFACTU.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Genera Factura de Remisiones.
#include "FiveWin.ch"
#include "TSBrowse.ch"
#include "btnget.ch"

MEMVAR oApl

#define CLR_PINK  nRGB( 128, 150, 150)
#define CLR_NBLUE nRGB( 128, 128, 192)

PROCEDURE JVMFactu( nOpc )
   LOCAL oF, aRC := { {|| oF:Iniciar() }, {|| oF:Mostrar() } }
   DEFAULT nOpc := 1
oF := TRemisar() ;  oF:New()
EVAL( aRC[nOpc] )

oF:oMvc:Destroy()
oF:oMvd:Destroy()
oF:oVen:Destroy()
RETURN

//------------------------------------//
CLASS TRemisar FROM TFactura

 METHOD NEW() Constructor
 METHOD Iniciar()
 METHOD AdicArray()
 METHOD Guardar( oDlg )
 METHOD Mostrar()
 METHOD Listado()

ENDCLASS

//------------------------------------//
METHOD New() CLASS TRemisar
 Super:New()
 ::aM := { 1,0,DATE(),DATE(),.t.,0,0,0,0,0,"","",0,0,0,0,.f.,0,0,"",.f. }
 ::aV := { { 0, SPACE(10), 0, " ", 0, 0 } }
nEmpresa( .t. )
oApl:Tipo := LEFT(oApl:oEmp:TIPOFAC,1)
RETURN NIL

//------------------------------------//
METHOD Iniciar() CLASS TRemisar
   LOCAL aColor[2], nL, lNoBlink := .f. , oE := Self
   LOCAL oDlg, oLbx, oNi, oGet := ARRAY(4)
If (aColor[ 1 ] := GetSysColor( COLOR_INACTIVECAPTION ) ) != ;
   GetSysColor( COLOR_ACTIVECAPTION )
   aColor[ 2 ] := GetSysColor( COLOR_INACTCAPTEXT )
   lNoBlink := .t.
   SBNoBlink()
EndIf
oNi := TNits() ; oNi:New()
DEFINE DIALOG oDlg TITLE "Facturación de Remisión" FROM 0, 0 TO 400, 430 PIXEL
   @ 02, 00 SAY "Nit o C.C. del Cliente" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 02,102 BTNGET oGet[1] VAR ::aM[1] OF oDlg PICTURE "9999999999" ;
      ACTION EVAL({|| If(oNi:Mostrar(), (oE:aM[1] := oNi:oDb:CODIGO,;
                         oGet[1]:Refresh() ),) })                   ;
      VALID EVAL( {|| If( oNi:Buscar( ::aM[1],"codigo",.t. )       ,;
                        ( ::AdicArray() ,  oLbx:aArray := ::aV     ,;
                          oLbx:Refresh(),  oDlg:Update(), .t. )    ,;
                    (MsgStop("Este Nit ó C.C. no Existe"), .f.) ) });
      SIZE 50,12 PIXEL RESOURCE "BUSCAR"
   @ 16, 30 SAY oGet[4] VAR oNi:oDb:NOMBRE OF oDlg PIXEL SIZE 120,10 ;
      UPDATE COLOR nRGB( 128,0,255 )

   @ 30,10 BROWSE oLbx SIZE 180,150 PIXEL OF oDlg CELLED; // CELLED  es requerida
      ON CLICK ( nL := oLbx:nAt, ::aV[nL,4] := If( ::aV[nL,4] $ "xX", " ", "X" ), oLbx:Refresh() );
      COLORS CLR_BLACK, CLR_NBLUE                         // para editar Celdas
   oLbx:SetArray( ::aV )     // Esto es necesario para trabajar con arrays
   oLbx:nFreeze     := 1
   oLbx:nColPos     := oLbx:nCell := 2
   oLbx:nHeightCell += 4
   oLbx:nHeightHead += 4
   oLbx:bKeyDown := {|nKey| If( nKey== VK_F11,;
                              ( ::Guardar( oDlg ) ), ) }
   oLbx:SetAppendMode( .f. )                         // Activando Auto Append Mode

   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 1;
       TITLE "Numero"+CRLF+"Remisión"            ;
       SIZE  90 ;
       3DLOOK TRUE, TRUE, TRUE;    // Celda, Titulo, Footers
       MOVE DT_MOVE_NEXT;          // Cursor pasa a la Sig.Columna editable
       ALIGN DT_RIGHT, DT_CENTER   // Celda, Titulo, Footer
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 4;
       TITLE "Facturar"      PICTURE "!"         ;
       SIZE 70 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_DOWN;
       ALIGN DT_CENTER, DT_CENTER, DT_RIGHT;
       VALID { |uVar| If( uVar $ " xX", .t., ;
              (MsgStop("Marque con una X o blanco","<<OJO>>"), .f.)) };
       FOOTER "Totales->"
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 3;
       TITLE "Valor"         PICTURE "99,999,999";
       SIZE 110 ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       FOOTER { || TRANSFORM( ::aM[6], "999,999,999" ) }
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 2;
       TITLE "Fecha"                             ;
       SIZE  90 ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_CENTER, DT_CENTER
   oLbx:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbx:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color
   @ 184, 70 BUTTON oGet[2] PROMPT "Facturar" SIZE 44,12 OF oDlg ACTION;
      ( oGet[2]:Disable(), ::Guardar(), oDlg:End() ) PIXEL
   @ 184,120 BUTTON oGet[3] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
   @ 184, 02 SAY "[JVMFACTU]" OF oDlg PIXEL SIZE 32,10
ACTIVATE DIALOG oDlg CENTERED
If( lNoBlink, SBNoBlink( aColor[1], aColor[2] ), Nil )
RETURN NIL

//------------------------------------//
METHOD AdicArray() CLASS TRemisar
   LOCAL aRes, cQry, hRes, nL
::aV    := {}
::aM[2] := oApl:oNit:CODIGO_NIT
::aM[6] := 0
cQry := "SELECT numero, fecha, totalfac, totaldes, "     +;
        "totaliva FROM cadcotic "                        +;
        "WHERE empresa    = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND codigo_nit = " + LTRIM(STR(::aM[2]))      +;
         " AND indicador = 'P'"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEval( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
   AADD( ::aV,{ aRes[1], aRes[2], aRes[3], " ", aRes[4], aRes[5] } )
   ::aM[6] += aRes[3]
   nL --
EndDo
If LEN( ::aV ) == 0
   AADD( ::aV,{ 0, SPACE(40), 0, " ", 0, 0 } )
EndIf
MSFreeResult( hRes )
SysRefresh()
RETURN NIL

//------------------------------------//
METHOD Guardar( oDlg ) CLASS TRemisar
   LOCAL aRes, cQry, hRes, nL, nR := 0
AEVAL( ::aV, { | e | nR += If( EMPTY( e[4] ), 0, 1 ) } )
If nR == 0 .OR. ::aM[6] == 0
   MsgStop( "NO HAY REMISIONES MARCADAS",">>> OJO <<<" )
   RETURN NIL
EndIf
cQry := "numfac"+oApl:Tipo
nR   := SgteNumero( cQry,oApl:nEmpresa,.f. )
If !MsgYesNo("Factura #"+STR(nR),"Graba esta")
   RETURN NIL
EndIf
oApl:oFac:Seek( {"empresa",oApl:nEmpresa,"numfac",0,"tipo",oApl:Tipo} )
oApl:oFac:EMPRESA := oApl:nEmpresa
oApl:oFac:NUMFAC  := SgteNumero( cQry,oApl:nEmpresa,.t. )
oApl:oFac:TIPO    := oApl:Tipo        ; oApl:oFac:FECHOY    := oApl:oEmp:FEC_HOY
oApl:oFac:CLIENTE := oApl:oNit:NOMBRE ; oApl:oFac:CODIGO_NIT:= ::aM[2]
oApl:oFac:FECHAENT  := oApl:oFac:FECHOY + 30
oApl:oFac:INDICADOR := "P"
//BuscaDup( oApl:oFac:NUMFAC,oApl:Tipo )
Guardar( oApl:oFac,.t.,.t. )
oApl:cPer:= NtChr( oApl:oFac:FECHOY,"1" )
 ::aDF   := PIva( oApl:cPer )
 ::aM[7] := 0
 ::aM[5] := "INSERT INTO cadfactd (empresa, numfac, tipo, "+;
            "codigo, unidadmed, cantidad, precioven, "     +;
            "despor, desmon, montoiva, ppubli, pcosto) "   +;
            "VALUES ( "+ LTRIM(STR(oApl:nEmpresa)) + ", "  +;
                      LTRIM(STR(oApl:oFac:NUMFAC)) + ", '" +;
                                oApl:Tipo          + "', '"
FOR nR := 1 TO LEN( ::aV )
   If !EMPTY( ::aV[nR,4] )
      cQry := "SELECT codigo, unidadmed, cantidad, precioven, "+;
                     "despor, desmon, montoiva, ppubli "       +;
               "FROM cadcotid "                                +;
               "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))  +;
                " AND numero  = " + LTRIM(STR(::aV[nR,1]))
      hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      nL   := MSNumRows( hRes )
      ::aM[7] += nL
      oApl:oFac:TOTALFAC += ::aV[nR,3]
      oApl:oFac:TOTALDES += ::aV[nR,5]
      oApl:oFac:TOTALIVA += ::aV[nR,6]
      While nL > 0
         aRes := MyReadRow( hRes )
         AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
         Actualiz( aRes[1],aRes[3],oApl:oFac:FECHOY,2,,aRes[2] )
         cQry := ::aM[5] + TRIM(aRes[1])  + "', '"+;
               TRIM(    aRes[2])  + "', " + LTRIM(STR(aRes[3])) + ", "+;
              LTRIM(STR(aRes[4])) +  ", " + LTRIM(STR(aRes[5])) + ", "+;
              LTRIM(STR(aRes[6])) +  ", " + LTRIM(STR(aRes[7])) + ", "+;
              LTRIM(STR(aRes[8])) +  ", " + LTRIM(STR(oApl:aInvme[2]))+ " )"
         Guardar( cQry,"cadfactd" )
         nL --
      EndDo
      MSFreeResult( hRes )
      cQry := "UPDATE cadcotic SET indicador = 'F', "           +;
                      "numfac = " + LTRIM(STR(oApl:oFac:NUMFAC))+;
              " WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))   +;
                " AND numero  = " + LTRIM(STR(::aV[nR,1]))
      Guardar( cQry,"cadcotic" )
   EndIf
NEXT nR

 ::aM[10] := oApl:oFac:TOTALIVA
 ::aM[21] := ::FechaDev( "RETEN" )
//MSGINFO( STR(oApl:oNit:CODIGO ),If( ::aM[21], "SI", "NO" ) )
 ::Retencion( (oApl:oFac:TOTALFAC - ::aM[10]) )
oApl:oFac:PAGINAS := ::Paginas( "numfac"+oApl:Tipo,oApl:oFac:NUMFAC,::aM[7] )
Guardar( oApl:oFac,.f.,.t. )
If oApl:Tipo $ "CX"
   oApl:lFam   := .f.
   oApl:nSaldo := oApl:oFac:TOTALFAC -;
                  oApl:oFac:RETFTE - oApl:oFac:RETICA - oApl:oFac:RETIVA - oApl:oFac:RETCRE
   GrabaSal( oApl:oFac:NUMFAC,1,0 )
EndIf
 ContaVta( ::oMvc,::oMvd,.f.,::aCta )
MsgStop( TRANSFORM(oApl:oFac:TOTALFAC,"999,999,999.99"),"FACTURA"+STR(oApl:oFac:NUMFAC) )
RETURN NIL

//------------------------------------//
METHOD Mostrar() CLASS TRemisar
   LOCAL oDlg, oGet := ARRAY(5)
DEFINE DIALOG oDlg TITLE "Remisiones Pendientes" FROM 0, 0 TO 08,50
   @ 02, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02, 92 GET oGet[1] VAR ::aM[3] OF oDlg  SIZE 44,12 PIXEL
   @ 16, 00 SAY "FECHA   FINAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 16, 92 GET oGet[2] VAR ::aM[4] OF oDlg ;
      VALID ::aM[4] >= ::aM[3] SIZE 44,12 PIXEL
   @ 16,140 CHECKBOX oGet[3] VAR ::aM[5] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 30, 50 BUTTON oGet[4] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[4]:Disable(), ::Listado(), oDlg:End() ) PIXEL
   @ 30,100 BUTTON oGet[5] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 36, 02 SAY "[JVMFACTU]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN NIL

//------------------------------------//
METHOD Listado() CLASS TRemisar
   LOCAL aGT, aRes, cQry, hRes, nL, oRpt
cQry := "SELECT n.nombre, n.codigo, n.digito, c.numero, "+;
               "c.fecha, c.cliente, c.totalfac "         +;
        "FROM cadcotic c, cadclien n "                   +;
        "WHERE c.empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
         " AND c.fecha  >= " + xValToChar( ::aM[3] )     +;
         " AND c.fecha  <= " + xValToChar( ::aM[4] )     +;
         " AND c.indicador  = 'P'"                       +;
         " AND n.codigo_nit = c.codigo_nit "             +;
        "ORDER BY n.nombre, c.fecha, c.numero"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgStop( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
EndIf
aRes := MyReadRow( hRes )
AEval( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
aGT  := { aRes[1],0,0,0,"999,999,999.99" }
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"REPORTE DE REMISIONES PENDIENTES",;
          "DESDE "+ NtChr(::aM[3],"2") + " HASTA " + NtChr(::aM[4],"2"),;
          SPACE(50) + "--REMISION   ---FECHA---   -NOMBRE"+;
          " DEL CLIENTE-    TOTAL REMISION"},::aM[5],1,2 )
While nL > 0
      oRpt:Titulo( 130 )
   If aGT[4] == 0
      oRpt:Say( oRpt:nL,01,PADR(aRes[1],36) + " " + FormatoNit( aRes[2],aRes[3] ) )
   EndIf
      oRpt:Say( oRpt:nL, 50,STR(aRes[4]) )
      oRpt:Say( oRpt:nL, 63,NtChr( aRes[5],"2" ) )
      oRpt:Say( oRpt:nL, 77,aRes[6],20 )
      oRpt:Say( oRpt:nL,100,TRANSFORM(aRes[7],aGT[5]) )
      oRpt:nL ++
   aGT[4] += aRes[7]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEval( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aGT[1] # aRes[1]
      oRpt:Titulo( 130 )
      oRpt:Say(++oRpt:nL, 77,"TOTAL CLIENTE --> $"+oRpt:CPIBold,,,1 )
      oRpt:Say(  oRpt:nL,100,TRANSFORM( aGT[4],aGT[5] )+oRpt:CPIBoldN )
      oRpt:nL += 2
      aGT[1] := aRes[1]
      aGT[2] ++
      aGT[3] := aGT[4]
      aGT[4] := 0
   EndIf
EndDo
MSFreeResult( hRes )
oRpt:Titulo( 130 )
oRpt:Say(  oRpt:nL, 01,REPLICATE("_",130),,,1 )
oRpt:Say(++oRpt:nL, 01,STR( aGT[2],3 ) + "  PENDIENTES",,,1 )
oRpt:Say(  oRpt:nL,100,TRANSFORM(aGT[3],aGT[5]) )
oRpt:NewPage()
oRpt:End()
RETURN NIL