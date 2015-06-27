// Programa.: CGECTAXP.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Cuentas por Pagar
#include "FiveWin.ch"
#include "btnget.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE Cgectaxp()
   LOCAL oC, oBrw, oDlg, oFont, oGet := ARRAY(3)
 oC := TCtasxp() ; oC:NEW()
//oNi := TNits() ; oNi:New()
DEFINE FONT oFont NAME "Ms Sans Serif" SIZE 0, -8

DEFINE DIALOG oDLG TITLE "Cuentas por Pagar" FONT oFont FROM 4,10 TO 30,70
   @ 1.2, 1.0 SAY  "Nro. Factura" RIGHT SIZE 50,NIL
   @ 1.2, 8.0 GET oGet[1] VAR oC:aLS[1] SIZE 40, NIL;
      VALID( If( !oC:oCxp:Seek( {"empresa",oApl:nEmpresa,"numero",;
                             oC:aLS[1]} ) .AND. !EMPTY(oC:aLS[1]),;
               ( MsgStop( "Factura NO EXISTE" ), .f. )        ,;
               ( oC:NEW( oDlg ), oBrw:Refresh(), .t. ) ) )
/*
      ACTION EVAL({|| If(oNi:Mostrar( ,,aLS[1] ), ( aLS[1] :=     ;
                         oNi:oDb:CODIGO,  oGet[1]:Refresh() ),) });
      VALID EVAL( {|| If( oNi:Buscar( aLS[1],"codigo",.t. )      ,;
                        ( oGet[3]:Settext( oNi:oDb:NOMBRE), .t. ),;
                  (MsgStop("Este Proveedor no Existe"), .f.) ) } );
      SIZE 48,10  RESOURCE "BUSCAR"
*/
   @ 2.1, 1.0 SAY "Nit Proveedor" RIGHT SIZE 50,NIL
   @ 2.1, 9.8 SAY oGet[2] VAR oC:aLS[2] SIZE  50,NIL UPDATE
   @ 3.0, 1.0 SAY oGet[3] VAR oC:aLS[3] SIZE 220,NIL UPDATE ;
      COLOR nRGB( 128,0,255 )

   @ 4.1,0.6 LISTBOX oBrw ;
      FIELDS "", "", "", "", "" ;
      HEADERS "Comprobante", "Fecha", "Debito", "Credito", "";
      FIELDSIZES 72, 68, 74, 74, 90;
      OF oDlg      SIZE 230, 64;
      ON DBLCLICK MsgInfo( "Array row: " + STR( oBrw:nAt ) + CRLF + ;
                           "Array col: " + STR( oBrw:nAtCol( nCol ) ) )
   oBrw:nAt       := 1
   oBrw:bLine     := { || { oC:aCXP[oBrw:nAt][1],  oC:aCXP[oBrw:nAt][2],;
                 TRANSFORM( oC:aCXP[oBrw:nAt][3],"@Z 9,999,999,999.99"),;
                 TRANSFORM( oC:aCXP[oBrw:nAt][4],"@Z 9,999,999,999.99"),;
                            oC:aCXP[oBrw:nAt][5] } }
   oBrw:bGoTop    := { || oBrw:nAt := 1 }
   oBrw:bGoBottom := { || oBrw:nAt := EVAL( oBrw:bLogicLen ) }
   oBrw:bSkip     := { | nWant, nOld | nOld := oBrw:nAt, oBrw:nAt += nWant,;
                        oBrw:nAt := MAX( 1, MIN( oBrw:nAt, EVAL( oBrw:bLogicLen ) ) ),;
                        oBrw:nAt - nOld }
   oBrw:bLogicLen := { || LEN( oC:aCXP ) }
   oBrw:cAlias    := "Array"

//    SIZES 400,450 SIZE 200,60;
//    OF oDlg PIXEL

   @ 8.8,0.6 LISTBOX oC:oLbs FIELDS oC:oSal:ANO_MES,;
                      TRANSFORM( oC:oSal:SALDO ,"999,999,999.99" ),;
                      TRANSFORM( oC:oSal:ABONOS,"999,999,999.99" ) ;
      HEADERS "AñoMes", "Saldo", "Abonos" ;
      FIELDSIZES 72, 100, 100;
      OF oDlg      SIZE 160, 70
    oC:oLbs:nClrBackHead  := oApl:nClrBackHead
    oC:oLbs:nClrForeHead  := oApl:nClrForeHead
    oC:oLbs:SetColor(oApl:nClrFore,oApl:nClrBack)
    oC:oLbs:nClrBackFocus := oApl:nClrBackFocus
    oC:oLbs:nClrForeFocus := oApl:nClrForeFocus
    oC:oLbs:nHeaderHeight := 28
    oC:oLbs:GoTop()
    oC:oLbs:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oC:oLbs:aColSizes  := {70,100,100}
    oC:oLbs:aHjustify  := {2,2,2}
    oC:oLbs:aJustify   := {0,1,1}  // O Derecha, 1 Izquierda, 2 Centro
    oC:oLbs:bKeyDown := {|nKey| If(nKey == VK_RETURN, oC:Editar( .f. ),;
                                If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, oC:Editar( .t. ),;
                                If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, oC:Borrar(), ))) }

    oC:oLbs:lCellStyle  := oC:oLbs:ladjbrowse  := .f.
    oC:oLbs:ladjlastcol := .t.
   MySetBrowse( oC:oLbs,oC:oSal )

//   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT ( oC:BarraCXP( oDlg,oBrw ), PutFont( oDlg ) )
   oFont:End()
oC:oCxp:Destroy()
oC:oSal:Destroy()
RETURN

//------------------------------------//
PROCEDURE CgeLiCxp( nOpc )
   LOCAL aCXP, oC, oNi, oDlg, oGet := ARRAY(9)
   DEFAULT nOpc := 1
 oC := TCtasxp()
oNi := TNits() ; oNi:New()
oC:aLS := { 0,DATE(),1,oApl:nTFor,.t.,1,"","" }
aCXP := { { {|| oC:ListoCXP() },"REPORTE DE CTAS X PAGAR" }       ,;
          { {|| oC:VenceCxp() },"REPORTE DE CTAS X PAGAR VENCIDAS" } }
DEFINE DIALOG oDlg TITLE aCXP[nOpc,2] FROM 0, 0 TO 12,46
   @ 02, 00 SAY "Nit por Default Todos" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02, 92 BTNGET oGet[1] VAR oC:aLS[1] OF oDlg PICTURE "9999999999";
      ACTION EVAL({|| If(oNi:Mostrar( ,,oC:aLS[1] ), ( oC:aLS[1] :=  ;
                         oNi:oDb:CODIGO,  oGet[1]:Refresh() ),) })   ;
      VALID EVAL( {|| If( EMPTY( oC:aLS[1] ), .t.                   ,;
                    ( If( oNi:Buscar( oC:aLS[1],"codigo",.t. )      ,;
                        ( oGet[2]:Settext( oNi:oDb:NOMBRE), .t. )   ,;
                        ( MsgStop("Este Nit no Existe"),.f.) ))) } ) ;
      WHEN nOpc == 1  SIZE 48,10 PIXEL RESOURCE "BUSCAR"
   @ 14, 10 SAY oGet[2] VAR oC:aLS[7] OF oDlg PIXEL SIZE 130,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 26, 00 SAY "FECHA DE CORTE [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 26, 92 GET oGet[3] VAR oC:aLS[2] OF oDlg  SIZE 40,10 PIXEL
   @ 38, 00 SAY "PAGINA INICIAL"            OF oDlg RIGHT PIXEL SIZE 90,10
   @ 38, 92 GET oGet[4] VAR oC:aLS[3] OF oDlg PICTURE "999";
      VALID Rango( oC:aLS[3],1,999 )  SIZE 24,10 PIXEL
   @ 50, 00 SAY "Libro" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 50, 92 COMBOBOX oGet[5] VAR oC:aLS[6] ITEMS { "COLGAAP","IFRS" };
      SIZE 48,90 OF oDlg PIXEL;
      WHEN !EMPTY(oApl:oEmp:NIIF)
//      WHEN !EMPTY(oApl:oEmp:NIIF) .AND. oA:aLS[3] >= oApl:oEmp:NIIF
   @ 62, 00 SAY "TIPO DE IMPRESORA"    OF oDlg RIGHT PIXEL SIZE 90,10
   @ 62, 92 COMBOBOX oGet[6] VAR oC:aLS[4] ITEMS { "Matriz","Laser" };
      SIZE 40,90 OF oDlg PIXEL
   @ 62,138 CHECKBOX oGet[7] VAR oC:aLS[5] PROMPT "Vista Previa" OF oDlg;
       SIZE 54,12 PIXEL
   @ 76, 50 BUTTON oGet[8] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[8]:Disable(), EVAL( aCXP[nOpc,1] ), oGet[8]:Enable(),;
        oGet[8]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 76,100 BUTTON oGet[9] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 80, 02 SAY "[CGECTAXP]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED NOMODAL
RETURN

//------------------------------------//
CLASS TCtasxp FROM TIMPRIME

 DATA aCXP, aLS, aPrv, oCxp, oSal, oLbs

 METHOD NEW() Constructor
 METHOD Avanza( oDlg,oLbx,nSkip,lSkip )
 METHOD BuscaFac()
 METHOD Borrar()
 METHOD Editar( lNuevo )
 METHOD BarraCXP( oDlg,oLbx )
 METHOD ListoCXP()
 METHOD LaserCXP( hRes,nL )
 METHOD VenceCXP()
 METHOD LaserVCP( hRes,nL )
ENDCLASS

//------------------------------------//
METHOD NEW( oDlg ) CLASS TCtasxp

If oDlg == NIL
   ::aCXP := { { "Comprobante","Fecha", 0, 0, "" } }
   ::aLS  := { SPACE(10),0,"",1,"","",0,.f. }
   ::aPrv := Privileg( "CTASXP" )
   ::oCxp := oApl:Abrir( "ctasxpc" ,"empresa, codigo_nit, numero",.t.,,10 )
   ::oSal := oApl:Abrir( "ctasxpm" ,"cxpc_id",,,100 )
   ::oSal:Seek( { "cxpc_id",0 } )
Else
   ::aLS[4] := ::oCxp:CODIGO_NIT
   ::aLS[5] := ::oCxp:ANO_MES
   ::aLS[6] := ::oCxp:CUENTA
   ::aLS[7] := 1
   ::aLS[8] := If( ::oCxp:nRowCount > 1, .t., .f. )
   ::BuscaFac()
   Botones( oDlg,{5,6},::aLS[8] )
   oDlg:Update()
   ::oLbs:Setfocus()
EndIf
RETURN NIL

//------------------------------------//
METHOD Avanza( oDlg,oLbx,nSkip,lSkip ) CLASS TCtasxp

If ::aLS[8]
   lSkip := .f.
   If (nSkip ==  1 .AND. ::aLS[7] < ::oCxp:nRowCount) .OR.;
      (nSkip == -1 .AND. ::aLS[7] > 1)
      lSkip := .t.
   EndIf
   If lSkip
      ::oCxp:Skip(nSkip):Read()
      ::oCxp:xLoad()
      ::aLS[4] := ::oCxp:CODIGO_NIT
      ::aLS[5] := ::oCxp:ANO_MES
      ::aLS[6] := ::oCxp:CUENTA
      ::aLS[7] += nSkip
      ::BuscaFac()
      oDlg:Update()
      oLbx:Refresh()
      ::oLbs:Setfocus()
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD BuscaFac() CLASS TCtasxp
   LOCAL aRes, cQry, hRes, nL
If InfAc( ::aLS[6],@nL,"DOCUMENTO " )
   cQry := { "infa","infb","infc","infd" }[nL]
   cQry := "SELECT CONCAT(c.fuente, '-', c.comprobant), c.fecha, d.valor_deb, d.valor_cre, c.concepto "+;
           "FROM cgemovc c, cgemovd d "     +;
           "WHERE d.empresa    = c.empresa" +;
            " AND d.ano_mes    = c.ano_mes" +;
            " AND d.control    = c.control" +;
            " AND d.empresa    = " + LTRIM(STR(oApl:nEmpresa))+;
			      " AND d.ano_mes   >= '"+         ::aLS[5]         +;
           "' AND d.cuenta     = '"+ ALLTRIM(::aLS[6])        +;
           "' AND d." + cQry+" = '"+ ALLTRIM(::aLS[1])        +;
           "' AND d.libro      = 1"                           +;
           " ORDER BY c.fecha"
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   If (nL := MSNumRows( hRes )) == 0
      MSFreeResult( hRes )
      RETURN .f.
   EndIf
   ::aCXP := {}
   cQry := { 0,0 }
   While nL > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      AADD( ::aCXP,{ aRes[1], NtChr( aRes[2],"2" ), aRes[3], aRes[4], aRes[5] } )
      cQry[1] += aRes[3]
      cQry[2] += aRes[4]
      nL --
   EndDo
   MSFreeResult( hRes )
   If LEN( ::aCXP ) == 0
      ::aCXP := { { "Comprobante","Fecha", 0, 0, "" } }
   Else
      AADD( ::aCXP,{ "","TOTALES =>", cQry[1], cQry[2], "" } )
   EndIf

   oApl:oNit:Seek( {"codigo_nit",::aLS[4]} )
   ::oSal:Seek( { "cxpc_id",::oCxp:CXPC_ID },"ano_mes" )
   ::aLS[2] := oApl:oNit:CODIGO
   ::aLS[3] := oApl:oNit:NOMBRE
   ::oLbs:Refresh()
EndIf
RETURN NIL

//------------------------------------//
METHOD Borrar() CLASS TCtasxp
If ::aPrv[3]
   DelRecord( ::oSal,::oLbs,.f. )
EndIf
RETURN NIL

//------------------------------------//
METHOD Editar( lNuevo ) CLASS TCtasxp
   LOCAL oDlg, oGet := ARRAY(5)
   LOCAL aED := { .f.,"Modificando Saldo","999,999,999" }
If ::aPrv[2]
   If lNuevo
      If MsgYesNo("Adicionar un Registro","Quiere")
         aED[2] := "Nuevo Saldo"
         ::oSal:xBlank()
         ::oSal:CXPC_ID := ::oCxp:CXPC_ID
         ::oSal:ANO_MES := oApl:cPer
      EndIf
   Else
      ::oSal:xLoad()
   EndIf
EndIf
DEFINE DIALOG oDlg TITLE aED[2] FROM 00,02 TO 09,40
   @ 02,00 SAY "Año y Mes"     OF oDlg RIGHT PIXEL SIZE 46,10
   @ 02,50 GET oGet[1] VAR ::oSal:ANO_MES OF oDlg PICTURE "999999";
      SIZE 30,10 PIXEL
   @ 14,00 SAY "Saldo Factura" OF oDlg RIGHT PIXEL SIZE 46,10
   @ 14,50 GET oGet[2] VAR ::oSal:SALDO  OF oDlg PICTURE aED[3];
      SIZE 40,10 PIXEL
   @ 26,00 SAY "Total Abonos"  OF oDlg RIGHT PIXEL SIZE 46,10
   @ 26,50 GET oGet[3] VAR ::oSal:ABONOS OF oDlg PICTURE aED[3];
      SIZE 40,10 PIXEL
   @ 40,30 BUTTON oGet[4] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION   ;
      (If( EMPTY(::oSal:ANO_MES) .OR. ::oSal:ABONOS < 0                ,;
         ( MsgStop("Imposible grabar este Saldo"), oGet[1]:SetFocus() ),;
         ( aEd[1] := .t., oDlg:End() ))) PIXEL
   @ 40,80 BUTTON oGet[5] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL ;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTER
// WHEN ::aPrv[1]
If aEd[1]
   If lNuevo
      ::oSal:Append(.t.)
   Else
      ::oSal:Update(.t.,1)
   EndIf
   ::oLbs:Refresh()
EndIf
RETURN NIL

//------------------------------------//
METHOD BarraCXP( oDlg,oLbx ) CLASS TCtasxp
   LOCAL oBar, oBot := ARRAY(8)
DEFINE BUTTONBAR oBar OF oDlg 3DLOOK SIZE 28,28

DEFINE BUTTON oBot[1] RESOURCE "ADD"       OF oBar NOBORDER ;
   ACTION ::Editar( .t. )                  TOOLTIP "Nuevo Registro (Ctrl+N)"
DEFINE BUTTON oBot[2] RESOURCE "MODIFY"    OF oBar NOBORDER ;
   ACTION ::Editar( .f. )                  TOOLTIP "Editar Registro (Ctrl+E)"
DEFINE BUTTON oBot[3] RESOURCE "DELREC"    OF oBar NOBORDER ;
   ACTION ::Borrar()                       TOOLTIP "Borrar  (Ctrl+DEL)"
DEFINE BUTTON oBot[4] RESOURCE "IMPRIMIR"  OF oBar NOBORDER ;
   ACTION MsgInfo( "Sin Funcion" ) ;
   TOOLTIP "Imprimir Nota"
DEFINE BUTTON oBot[5] RESOURCE "ANTERIOR"  OF oBar NOBORDER ;
   ACTION ::Avanza( oDlg,oLbx,-1 ) GROUP   TOOLTIP "Factura Anterior"
DEFINE BUTTON oBot[6] RESOURCE "SIGUIENTE" OF oBar NOBORDER ;
   ACTION ::Avanza( oDlg,oLbx,1 )          TOOLTIP "Siguiente Factura"
DEFINE BUTTON oBot[7] RESOURCE "CALC"      OF oBar NOBORDER ;
   ACTION WinExec("Calc")                  TOOLTIP "Calculadora"
DEFINE BUTTON oBot[8] RESOURCE "CLOSE"     OF oBar NOBORDER ;
   GROUP ACTION oDlg:End()         GROUP   TOOLTIP "Salir"
RETURN oBar

/*
//------------------------------------//
PROCEDURE ListoCXP( aLS )
   LOCAL oRpt, aGT := { 0,0,0,0,"@Z 9,999,999,999.99","inf" }
   LOCAL aRes, cQry, hRes, nL, nP
If InfAc( "22050101",@nP,"DOCUMENTO" )
   aGT[6] += { "a","b","c","d" }[nP]
Else
   aGT[6] += "b"
   nP     := 2
EndIf
cQry := "SELECT c.fecha, c.comprobant, c.concepto, d.infa, "+;
         "d.infb, d.infc, d.infd, d.valor_deb, d.valor_cre "+;
        "FROM cgemovc c, cgemovd d "      +;
        "WHERE d.empresa    = c.empresa " +;
         " AND d.ano_mes    = c.ano_mes " +;
         " AND d.control    = c.control " +;
         " AND d.empresa    = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND d.ano_mes   <= " + NtChr( aLS[2],"1" )      +;
         " AND d.cuenta     = '22050101'" +;
         " AND d.codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT))+;
         " ORDER BY d." + aGT[6] + ", c.fecha"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN
EndIf

oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"REPORTE DE CUENTAS POR PAGAR",NtChr( aLS[2],"3" ),;
          oApl:oNit:NOMBRE,"FACTURA---   F E C H A  COMPROBANTE  C O N C E P T O"+;
          "                               VALOR DEBITO     VALOR CREDITO"},aLS[4],aLS[3],2 )
//234567890  12-ago-2011      123456  1234567890123456789012345678901234567890  9,999,999,999.99  9,999,999,999.99
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   oRpt:Titulo( 114 )
   If oRpt:nPage >= oRpt:nPagI
      oRpt:Say( oRpt:nL, 00,aRes[nP+3] )
      oRpt:Say( oRpt:nL, 12,NtChr( aRes[1],"2" ) )
      oRpt:Say( oRpt:nL, 28,STR(aRes[2],7) )
      oRpt:Say( oRpt:nL, 37,aRes[3] )
      oRpt:Say( oRpt:nL, 79,TRANSFORM(aRes[8],aGT[5]) )
      oRpt:Say( oRpt:nL, 97,TRANSFORM(aRes[9],aGT[5]) )
   EndIf
   oRpt:nL ++
   aGT[3] += aRes[8]
   aGT[4] += aRes[9]
   nL --
EndDo
MSFreeResult( hRes )
   aGT[2] := aGT[3] - aGT[4]
   nP     := If( aGT[2] > 0, 79, 97 )
   oRpt:Titulo( 114 )
   oRpt:Say(  oRpt:nL, 00,REPLICATE("_",114),,,1 )
   oRpt:Say(++oRpt:nL, 37,"TOTAL CUENTAS POR PAGAR ---> $" )
   oRpt:Say(  oRpt:nL, 79,TRANSFORM( aGT[3],aGT[5] ) )
   oRpt:Say(  oRpt:nL, 97,TRANSFORM( aGT[4],aGT[5] ) )
   oRpt:Say(++oRpt:nL, 54,"SALDO ====> $",,,1 )
   oRpt:Say(  oRpt:nL, nP,TRANSFORM( aGT[2],aGT[5] ) )
   oRpt:NewPage()
   oRpt:End()
RETURN
*/
//------------------------------------//
METHOD ListoCXP() CLASS TCtasxp
   LOCAL aRes, cQry, hRes, nL, oRpt
   LOCAL aGT := { 0,0,0,0,"99,999,999.99" }
cQry := "SELECT n.nombre, n.codigo, n.digito, c.numero, "+;
              "c.fecha, c.fechaven, c.cuenta, s.MTL "    +;
        "FROM ctasxpm s, ctasxpc c LEFT JOIN cadclien n "+;
         "USING( codigo_nit ) "                          +;
        "WHERE c.empresa    = " + LTRIM(STR(oApl:nEmpresa)) + If( ::aLS[1] > 0,;
         " AND c.codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT)), "" )+;
         " AND c.cxpc_id    = s.cxpc_id"                 +;
         " AND s.ano_mes = (SELECT MAX(m.ano_mes) FROM ctasxpm m "+;
                           "WHERE m.cxpc_id  = c.cxpc_id"         +;
                            " AND m.ano_mes <= '" + NtChr( ::aLS[2],"1" ) +;
       "') AND s.MTL <> 0 ORDER BY n.nombre, c.fecha, c.numero"
cQry := STRTRAN( cQry,"MTL",{ "saldo","saldon" }[::aLS[6]] )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
::aLS[8] := "REPORTE DE CUENTAS POR PAGAR" + NtChr( ::aLS[6],"CI" )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[4] == 2
   ::LaserCXP( hRes,nL )
   RETURN NIL
EndIf
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   ::aLS[1] := aRes[2]
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aLS[8],NtChr( ::aLS[2],"3" ),;
          SPACE(50) +"FACTURA-  FEC.FACTU   FEC.VENCE   NOMBRE DE " +;
          "LA CUENTA---  CUENTA    SALDO FACTURA"},::aLS[5],::aLS[3],2 )
While nL > 0
   oRpt:Titulo( 131 )
   If oRpt:nPage >= oRpt:nPagI
      If aGT[4] == 0
         oRpt:Say( oRpt:nL,00,aRes[1] )
         oRpt:Say( oRpt:nL,35,TRANSFORM(aRes[2],"999,999,999-") + STR(aRes[3],1) )
      EndIf
      cQry := Buscar( {"empresa",oApl:nPUC,"cuenta",aRes[7]},"cgeplan","nombre",8 )
      oRpt:Say( oRpt:nL, 50,aRes[4] )
      oRpt:Say( oRpt:nL, 60,NtChr( aRes[5],"2" ) )
      oRpt:Say( oRpt:nL, 72,NtChr( aRes[6],"2" ) )
      oRpt:Say( oRpt:nL, 84,cQry,22 )
      oRpt:Say( oRpt:nL,108,aRes[7] )
      oRpt:Say( oRpt:nL,118,TRANSFORM(aRes[8],aGT[5]) )
   EndIf
   oRpt:nL ++
   aGT[4] += aRes[8]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aRes[2] # ::aLS[1]
      If oRpt:nPage >= oRpt:nPagI
         oRpt:Say( oRpt:nL+1, 94,"TOTAL PROVEEDOR --> $"+oRpt:CPIBold,,,1 )
         oRpt:Say( oRpt:nL+1,118,TRANSFORM( aGT[4],aGT[5] )+oRpt:CPIBoldN )
      EndIf
      oRpt:nL += 3
      aGT[1] ++
      aGT[2] += If( ::aLS[1] > 0, aGT[4], 0 )
      aGT[3] += aGT[4]
      aGT[4] := 0
      ::aLS[1] := aRes[2]
   EndIf
EndDo
MSFreeResult( hRes )
   oRpt:Titulo( 131 )
   oRpt:Say(  oRpt:nL, 01,REPLICATE("_",130),,,1 )
   oRpt:Say(++oRpt:nL, 01,STR( aGT[1],3 ) + "  SALDOS",,,1 )
   oRpt:Say(  oRpt:nL,118,TRANSFORM(aGT[3],aGT[5]) )
   oRpt:Say(++oRpt:nL, 01,REPLICATE("_",130),,,1 )
   oRpt:Separator( 2,10 )
   oRpt:Say( oRpt:nL  ,10,"TOTAL EMPRESAS ------------> $" + TRANSFORM( aGT[2],aGT[5] ) )
   oRpt:Say( oRpt:nL+2,10,"TOTAL CUENTAS POR PAGAR ---> $" + TRANSFORM( aGT[3],aGT[5] ) )
   oRpt:NewPage()
   oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserCXP( hRes,nL ) CLASS TCtasxp
   LOCAL aRes, aGT := { 0,0,0,0,"99,999,999.99" }
aRes := MyReadRow( hRes )
AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
 ::aLS[1] := aRes[2]
 ::aEnc := { .t.,oApl:cEmpresa,oApl:oEmp:Nit,::aLS[8],NtChr( ::aLS[2],"3" ),;
             { .F.,10.0,"FACTURA" }  , { .F.,12.0,"FEC.FACTU" },;
             { .F.,14.0,"FEC.VENCE" }, { .F.,16.0,"CUENTA" }   ,;
             { .T.,20.5,"SALDO FACTURA" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[5] ,,, ::aLS[5], 5 )
 ::nMD := 20.5
  PAGE
While nL > 0
      ::Cabecera( .t.,0.42 )
// If oRpt:nPage >= oRpt:nPagI
      If aGT[4] == 0
         UTILPRN ::oUtil Self:nLinea, 0.5 SAY aRes[1]
         UTILPRN ::oUtil Self:nLinea, 7.8 SAY FormatoNit( aRes[2],aRes[3] )
      EndIf
      UTILPRN ::oUtil Self:nLinea,10.0 SAY aRes[4]
      UTILPRN ::oUtil Self:nLinea,12.0 SAY NtChr( aRes[5],"2" )
      UTILPRN ::oUtil Self:nLinea,14.0 SAY NtChr( aRes[6],"2" )
      UTILPRN ::oUtil Self:nLinea,16.0 SAY aRes[7]
      UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aRes[8],aGT[5] ) RIGHT
// EndIf
   aGT[4] += aRes[8]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aRes[2] # ::aLS[1]
    //If oRpt:nPage >= oRpt:nPagI
         ::Cabecera( .t.,0.84 )
         UTILPRN ::oUtil Self:nLinea,15.2 SAY "TOTAL PROVEEDOR --> $"
         UTILPRN ::oUtil SELECT ::aFnt[6]
         UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aGT[4],aGT[5] ) RIGHT
         UTILPRN ::oUtil SELECT ::aFnt[5]
    //EndIf
      ::nLinea += 0.42
      aGT[1] ++
      aGT[2] += If( ::aLS[1] > 0, aGT[4], 0 )
      aGT[3] += aGT[4]
      aGT[4] := 0
      ::aLS[1] := aRes[2]
   EndIf
EndDo
MSFreeResult( hRes )
   ::Cabecera( .t.,0.1,1.78,20.5 )
   UTILPRN ::oUtil Self:nLinea, 0.6 SAY STR( aGT[1],3 ) + "  SALDOS"
   UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aGT[3],aGT[5] ) RIGHT
   ::nLinea += 0.84
   UTILPRN ::oUtil Self:nLinea, 2.0 SAY "TOTAL EMPRESAS ------------> $"
   UTILPRN ::oUtil Self:nLinea, 9.0 SAY TRANSFORM( aGT[2],aGT[5] ) RIGHT
   ::nLinea += 0.84
   UTILPRN ::oUtil Self:nLinea, 2.0 SAY "TOTAL CUENTAS POR PAGAR --> $"
   UTILPRN ::oUtil Self:nLinea, 9.0 SAY TRANSFORM( aGT[3],aGT[5] ) RIGHT
  ENDPAGE
 ::EndInit( .F. )
 ::aLS[1] := 0
RETURN NIL

//------------------------------------//
METHOD VenceCXP() CLASS TCtasxp
   LOCAL oRpt, aGT := { 0,0,0,0,"99,999,999.99" }
   LOCAL aRes, cQry, hRes, nL
cQry := "SELECT n.nombre, n.codigo, n.digito, c.numero, c.fecha, "+;
             "c.fechaven, c.cuenta, s.MTL, c.ano_mes, c.control " +;
        "FROM ctasxpm s, ctasxpc c LEFT JOIN cadclien n "+;
         "USING( codigo_nit ) "                          +;
        "WHERE c.empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fechaven = " + xValToChar( ::aLS[2] )   +;
         " AND c.cxpc_id  = s.cxpc_id"                   +;
         " AND s.ano_mes = (SELECT MAX(m.ano_mes) FROM ctasxpm m "+;
                           "WHERE m.cxpc_id  = c.cxpc_id"         +;
                            " AND m.ano_mes <= '" + NtChr( ::aLS[2],"1" )+;
      "') AND s.MTL <> 0 ORDER BY n.nombre, c.fecha, c.numero"
cQry := STRTRAN( cQry,"MTL",{ "saldo","saldon" }[::aLS[6]] )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
::aLS[8] := "REPORTE DE CUENTAS POR PAGAR" + NtChr( ::aLS[6],"CI" )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[4] == 2
   ::LaserVCP( hRes,nL )
   RETURN NIL
EndIf
aRes := MyReadRow( hRes )
AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
 ::aLS[1] := aRes[2]
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{::aLS[8],"VENCIDAS EN "+NtChr( ::aLS[2],"3" ),;
          SPACE(50) +"FACTURA-  FEC.FACTU   FEC.VENCE   CONCEPTO DEL " +;
          "MOVTO.---  CUENTA    SALDO FACTURA"},::aLS[5],::aLS[3],2 )
While nL > 0
   oRpt:Titulo( 130 )
   If oRpt:nPage >= oRpt:nPagI
      If aGT[4] == 0
         oRpt:Say( oRpt:nL,00,aRes[1] )
         oRpt:Say( oRpt:nL,35,TRANSFORM(aRes[2],"999,999,999-") + STR(aRes[3],1) )
      EndIf
      cQry := Buscar( {"empresa",oApl:nEmpresa,"ano_mes",aRes[9],;
                       "control",aRes[10]},"cgemovc","concepto",8 )
      oRpt:Say( oRpt:nL, 50,aRes[4] )
      oRpt:Say( oRpt:nL, 60,NtChr( aRes[5],"2" ) )
      oRpt:Say( oRpt:nL, 72,NtChr( aRes[6],"2" ) )
      oRpt:Say( oRpt:nL, 84,cQry,22 )
      oRpt:Say( oRpt:nL,108,aRes[7] )
      oRpt:Say( oRpt:nL,118,TRANSFORM(aRes[8],aGT[5]) )
   EndIf
   oRpt:nL ++
   aGT[4] += aRes[8]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aRes[2] # ::aLS[1]
      If oRpt:nPage >= oRpt:nPagI
         oRpt:Say( oRpt:nL+1, 94,"TOTAL PROVEEDOR --> $"+oRpt:CPIBold,,,1 )
         oRpt:Say( oRpt:nL+1,118,TRANSFORM( aGT[4],aGT[5] )+oRpt:CPIBoldN )
      EndIf
      oRpt:nL += 3
      aGT[1] ++
      aGT[2] += If( ::aLS[1] > 0, aGT[4], 0 )
      aGT[3] += aGT[4]
      aGT[4] := 0
      ::aLS[1] := aRes[2]
   EndIf
EndDo
MSFreeResult( hRes )
   oRpt:Titulo( 130 )
   oRpt:Say(  oRpt:nL, 01,REPLICATE("_",130),,,1 )
   oRpt:Say(++oRpt:nL, 01,STR( aGT[1],3 ) + "  SALDOS",,,1 )
   oRpt:Say(  oRpt:nL,118,TRANSFORM(aGT[3],aGT[5]) )
   oRpt:Say(++oRpt:nL, 01,REPLICATE("_",130),,,1 )
   oRpt:Separator( 2,10 )
   oRpt:Say( oRpt:nL  ,10,"TOTAL EMPRESAS ------------> $" + TRANSFORM( aGT[2],aGT[5] ) )
   oRpt:Say( oRpt:nL+2,10,"TOTAL CUENTAS POR PAGAR ---> $" + TRANSFORM( aGT[3],aGT[5] ) )
   oRpt:NewPage()
   oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserVCP( hRes,nL ) CLASS TCtasxp
   LOCAL aRes, aGT := { 0,0,0,0,"99,999,999.99" }
aRes := MyReadRow( hRes )
AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
 ::aLS[1] := aRes[2]
 ::aEnc := { .t.,oApl:cEmpresa,oApl:oEmp:Nit,::aLS[8],;
             "VENCIDAS EN " + NtChr( ::aLS[2],"3" )  ,;
             { .F.,10.0,"FACTURA" }    , { .F.,12.0,"FEC.FACTU" },;
             { .T.,15.7,"Comprobante" }, { .F.,16.0,"CUENTA" }   ,;
             { .T.,20.5,"SALDO FACTURA" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[5] ,,, ::aLS[5], 5 )
 ::nMD := 20.5
  PAGE
While nL > 0
   aRes[10] := Buscar( {"empresa",oApl:nEmpresa,"ano_mes",aRes[9],;
                        "control",aRes[10]},"cgemovc","comprobant",8 )
      ::Cabecera( .t.,0.42 )
// If oRpt:nPage >= oRpt:nPagI
      If aGT[4] == 0
         UTILPRN ::oUtil Self:nLinea, 0.5 SAY aRes[1]
         UTILPRN ::oUtil Self:nLinea, 7.8 SAY FormatoNit( aRes[2],aRes[3] )
      EndIf
      UTILPRN ::oUtil Self:nLinea,10.0 SAY aRes[4]
      UTILPRN ::oUtil Self:nLinea,12.0 SAY NtChr( aRes[5],"2" )
      UTILPRN ::oUtil Self:nLinea,15.7 SAY STR( aRes[10] )             RIGHT
      UTILPRN ::oUtil Self:nLinea,16.0 SAY aRes[7]
      UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aRes[8],aGT[5] ) RIGHT
// EndIf
   aGT[4] += aRes[8]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aRes[2] # ::aLS[1]
    //If oRpt:nPage >= oRpt:nPagI
         ::Cabecera( .t.,0.84 )
         UTILPRN ::oUtil Self:nLinea,15.2 SAY "TOTAL PROVEEDOR --> $"
         UTILPRN ::oUtil SELECT ::aFnt[6]
         UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aGT[4],aGT[5] ) RIGHT
         UTILPRN ::oUtil SELECT ::aFnt[5]
    //EndIf
      ::nLinea += 0.42
      aGT[1] ++
      aGT[2] += If( ::aLS[1] > 0, aGT[4], 0 )
      aGT[3] += aGT[4]
      aGT[4] := 0
      ::aLS[1] := aRes[2]
   EndIf
EndDo
MSFreeResult( hRes )
   ::Cabecera( .t.,0.1,1.78,20.5 )
   UTILPRN ::oUtil Self:nLinea, 0.6 SAY STR( aGT[1],3 ) + "  SALDOS"
   UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aGT[3],aGT[5] ) RIGHT
   ::nLinea += 0.84
   UTILPRN ::oUtil Self:nLinea, 2.0 SAY "TOTAL EMPRESAS ------------> $"
   UTILPRN ::oUtil Self:nLinea, 9.0 SAY TRANSFORM( aGT[2],aGT[5] ) RIGHT
   ::nLinea += 0.84
   UTILPRN ::oUtil Self:nLinea, 2.0 SAY "TOTAL CUENTAS POR PAGAR --> $"
   UTILPRN ::oUtil Self:nLinea, 9.0 SAY TRANSFORM( aGT[3],aGT[5] ) RIGHT
  ENDPAGE
 ::EndInit( .F. )
 ::aLS[1] := 0
RETURN NIL

//--Coloca Font a Todos los Controls--//
FUNCTION PutFont( oDlg,oFont )
   DEFAULT oFont := oDlg:oFont
 AEVAL( oDlg:aControls, {|a| a:SetFont(oFont) } )
RETURN NIL