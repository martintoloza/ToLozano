// Programa.: CAORECAU.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Modulo para los Recaudos por cobrador.
#include "Fivewin.ch"
#include "TSBrowse.ch"
#include "Btnget.ch"

MEMVAR oApl

#define CLR_PINK  nRGB( 128, 150, 150) //255, 128, 128
#define CLR_NBLUE nRGB( 128, 128, 192)

FUNCTION Recaudos()
   LOCAL oDlg, oLbx, aColor[ 2 ], lNoBlink := .f.
   LOCAL nA, oP, oNi, oGet := ARRAY(3)
If (aColor[ 1 ] := GetSysColor( COLOR_INACTIVECAPTION ) ) != ;
   GetSysColor( COLOR_ACTIVECAPTION )
   aColor[ 2 ] := GetSysColor( COLOR_INACTCAPTEXT )
   lNoBlink := .t.
   SBNoBlink()
EndIf
oApl:oEmp:Seek( {"empresa",4} )
nEmpresa( .t. )
 oP  := TCobro();  oP:New()
 oNi := TNits() ; oNi:New()
oP:AdicArray()
DEFINE DIALOG oDlg FROM 0, 0 TO 360,560 PIXEL TITLE "Recaudos || " + oApl:cEmpresa
   @ 16, 08 SAY "C.C. Cobrador" OF oDlg RIGHT PIXEL SIZE 40,10
   @ 16, 50 BTNGET oGet[1] VAR oP:aM[1] OF oDlg PICTURE "9999999999";
      VALID EVAL( {|| If(!oNi:oDb:Seek( {"codigo",oP:aM[1]} )      ,;
             ( MsgStop("Este Cobrador no Existe..."), .f. )        ,;
             ( oDlg:Update(), .t. )) } )  SIZE 44,10 PIXEL          ;
      RESOURCE "BUSCAR"                                             ;
      ACTION EVAL({|| If(oNi:Mostrar(), (oP:aM[1] := oNi:oDb:CODIGO,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
   @ 16,120 SAY oGet[2] VAR oNi:oDb:NOMBRE OF oDlg PIXEL SIZE 88,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 28, 08 SAY "Fecha de Cobro" OF oDlg RIGHT PIXEL SIZE 40,10
   @ 28, 50 GET oGet[3] VAR oP:aM[2] OF oDlg                 ;
      VALID( oP:oRec:Seek( { "codigo_nit",oNi:oDb:CODIGO_NIT,;
                             "fecha",oP:aM[2]} )            ,;
             oP:AdicArray(),  oLbx:aArray := oP:aP          ,;
             oLbx:Refresh(),  oP:cHora := LEFT( TIME(),5 )  ,;
             oGet[3]:oJump := oLbx, .t. )                    ;
      SIZE 40,10 PIXEL
   ACTIVAGET(oGet)

   @ 44,16 BROWSE oLbx SIZE 244,130 PIXEL OF oDlg CELLED; // CELLED  es requerida
      COLORS CLR_BLACK, CLR_NBLUE                         // para editar Celdas
   oLbx:SetArray( oP:aP )     // Esto es necesario para trabajar con arrays
   oLbx:nHeightCell += 4
   oLbx:nHeightHead += 4
   oLbx:bKeyDown := {|nKey| If(nKey=VK_F3 , oP:Listado( oDlg,oLbx ),;
                            If(nKey=VK_F5 , oLbx:KeyDown( VK_DELETE,0 ),;
                            If(nKey=VK_F6 , oP:Asentar( oLbx )     ,;
                            If(nKey=VK_F11, oP:Guardar( oDlg,oLbx ), )))) }
   oLbx:SetAppendMode( .t. )                   // Activando Auto Append Mode
   oLbx:SetDeleteMode( .t.,.f.,{ |nAt,oLbx| oP:DelArray(oLbx) },;
                  {|oLbx| oP:Dscto( oLbx ) } ) // lOnOff, lConfirm, bDelete

   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 1;
       TITLE "Numero"+CRLF+"Factura"             ;
       SIZE  70 EDITABLE ;         // Esta columna es editable
       3DLOOK TRUE, TRUE, TRUE;    // Celda, Titulo, Footers
       MOVE DT_MOVE_NEXT;          // Cursor pasa a la Sig.Columna editable
       VALID { | uVar| oP:Buscar( uVar,oLbx ) }; // don't want empty rows
       ALIGN DT_LEFT, DT_CENTER  ; // Celda, Titulo, Footer
       PREEDIT {|uVar| oP:aM[3] := uVar, nA := oLbx:nAt ,;
                       oP:aM[4] := If( nA > LEN(oP:aP), 0, oP:aP[nA,7] ) };
       FOOTER { || STR( oLbx:nLen,4 ) + " Items" };
       WHEN oP:EditArray( oLbx )
    oLbx:aColumns[01]:bPostEdit := { |uVar| ;
       oP:aP[nA,1] := oP:aM[3], oP:aP[nA,2] := oP:aM[5],;
       oP:aP[nA,3] := oP:aM[6], oP:aP[nA,4] := oP:aM[7],;
       oP:aP[nA,8] := oP:aM[8], oP:Dscto( oLbx ) }

   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 3;
       TITLE "Cliente" ;
       SIZE 260 ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_LEFT, DT_CENTER, DT_RIGHT;
       FOOTER "Total Recaudo->"
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 4;
       TITLE "Valor"         PICTURE "99,999,999" ;
       SIZE 100 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       VALID { |uVar| If( uVar >= 0, .t., ;
              (MsgStop("Valor tiene que ser Positivo","<<OJO>>"), .f.)) };
       FOOTER { || TransForm( oP:aM[9], "99,999,999" ) };
       POSTEDIT { |uVar| If( oLbx:lChanged, oP:Dscto( oLbx ), ) };
       WHEN oP:EditArray( oLbx )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 9;
       TITLE "Aplicada";
       SIZE 52 ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_CENTER, DT_CENTER, DT_RIGHT
   // Asignando Valores por defaults para nueva Fila creada con Auto Append.
   oLbx:aDefault := { 0, "U", SPACE(30), 0, .f., 0, 0, 0, "NO" }
   oLbx:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbx:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color
ACTIVATE DIALOG oDlg CENTER ON INIT (oP:Barra( oDlg,oLbx ))

If( lNoBlink, SBNoBlink( aColor[1], aColor[2] ), Nil )
oP:oRec:Destroy()
RETURN NIL

//------------------------------------//
CLASS TCobro

 DATA aM   AS ARRAY INIT { 0,DATE(),0,0,0,0,0,0,0,0,0,0,0 }
 DATA aP, cHora, oRec

 METHOD NEW() Constructor
 METHOD AdicArray()
 METHOD EditArray( oLbx )
 METHOD Buscar( xBuscar,oLbx )
 METHOD Dscto( oLbx )
 METHOD DelArray( oLbx )
 METHOD Guardar( oDlg,oLbx )
 METHOD Listado( oDlg,oLbx )
 METHOD Asentar( oLbx )
 METHOD Barra( oDlg,oLbx )
ENDCLASS

//------------------------------------//
METHOD New() CLASS TCobro

::oRec  := oApl:Abrir( "recaudoc","Codigo_nit, Fecha",,,10 )
::oRec:xBlank()
::oRec:lOK := .f.

RETURN NIL

//------------------------------------//
METHOD AdicArray() CLASS TCobro
   LOCAL aRes, hRes, cQry, nL
::aP    := {}
::aM[9] := 0
If ::oRec:lOK
   cQry := "SELECT d.numfac, d.tipo, u.cliente, d.valor, d.aplica"+;
           ", d.row_id FROM recaudod d, cadfactu u "              +;
           "WHERE d.control = "+ LTRIM(STR(::oRec:CONTROL))+;
            " AND u.empresa = "+ LTRIM(STR(oApl:nEmpresa)) +;
            " AND u.numfac  = d.numfac"                    +;
            " AND u.tipo    = d.tipo"
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   While nL > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      oApl:lFam:= SaldoFac( aRes[1] )
      AADD( ::aP,{ aRes[1] , aRes[2] , aRes[3],;
                   aRes[4] , aRes[5] , aRes[4],;
                   aRes[6] , aRes[4] + oApl:nSaldo,;
                   If( aRes[5], "SI", "NO" ) } )
      ::aM[9] += aRes[4]
      nL --
   EndDo
   MSFreeResult( hRes )
EndIf
If LEN( ::aP ) == 0
   AADD( ::aP,{ 0, "U", SPACE(30), 0, .f., 0, 0, 0, "NO" } )
EndIf
SysRefresh()
oApl:cPer:= NtChr( ::aM[2],"1" )
RETURN NIL

//------------------------------------//
METHOD EditArray( oLbx ) CLASS TCobro
   LOCAL lEdit := .t., nA := oLbx:nAt, nF
If nA > LEN(::aP)
   nF := If( nA > 2, 1, nA-1 )
   If EMPTY( ::aP[nF,01] ) .OR. oLbx:nCell # 1
      MsgStop( "Primero Digite Número de la Factura","Nuevo" )
      oLbx:nAt   := oLbx:nLen := oLbx:nRowPos := nA
      oLbx:nCell := 1 ; lEdit := .f.
      oLbx:HiliteCell( 1 ) ; oLbx:Refresh(.t.)
      oLbx:DrawSelect()
   EndIf
Else
   If EMPTY( ::aP[nA,01] ) .AND. oLbx:nCell # 1
      MsgStop( "Primero Digite Número de la Factura" )
      oLbx:nCell := 1 ; lEdit := .f.
      oLbx:HiliteCell( 1 ) ; oLbx:Refresh()
   EndIf
EndIf
RETURN lEdit

//------------------------------------//
METHOD Buscar( xBuscar,oLbx ) CLASS TCobro
   LOCAL nA, lExiste
lExiste := oApl:oFac:Seek( {"empresa",oApl:nEmpresa,"numfac",;
                            xBuscar,"tipo",oApl:Tipo} )
If lExiste
   nA := oLbx:nAt
   ::aM[3]  := xBuscar
   ::aM[5]  := oApl:Tipo
   ::aM[6]  := oApl:oFac:CLIENTE
   oApl:lFam:= SaldoFac( ::aM[3] )
   If ::aM[4] == 0
      ::aM[7] := ::aM[8] := oApl:nSaldo
   Else
      ::aM[8] := oApl:nSaldo + ::aP[nA,6]
   EndIf
ElseIf !EMPTY( xBuscar )
   MsgStop( "Está Factura NO EXISTE !!!",xBuscar )
EndIf
RETURN If( EMPTY( xBuscar ), .f., lExiste )

//------------------------------------//
METHOD Dscto( oLbx ) CLASS TCobro
   LOCAL nSubTot, nA := oLbx:nAt
::aM[9] := 0
AEval( ::aP, { | e | ::aM[09] += e[ 4 ] } )
oLbx:Refresh() ; oLbx:DrawFooters()
RETURN NIL

//------------------------------------//
METHOD DelArray( oLbx ) CLASS TCobro
   LOCAL cQry, nA := oLbx:nAt
If ::aP[nA,7] > 0
   If MsgNoYes( "Elimina este Pago",::aP[nA,1] )
      If ::aP[nA,5]
         GrabaPago( ,::aP[nA,1],-::aP[nA,4],::aM[2] )
         cQry := "DELETE FROM cadpagos "                           +;
                 "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))    +;
                  " AND numfac  = " + LTRIM(STR(::aP[nA,1]))       +;
                  " AND tipo   = " + xValToChar( oApl:Tipo )       +;
                  " AND numcheque = '" + LTRIM(STR(::oRec:CONTROL))+;
                 "' AND formapago = 0 AND pordonde = 'R'"
         MSQuery( oApl:oMySql:hConnect,cQry )
      EndIf
      Guardar( "DELETE FROM recaudod WHERE row_id = " +;
               LTRIM(STR(::aP[nA,7])), "recaudod" )
   EndIf
EndIf
RETURN .t.

//------------------------------------//
METHOD Listado( oDlg,oLbx ) CLASS TCobro
   LOCAL nR, oRpt
If ::oRec:lOK
   oRpt := TDosPrint()
   oRpt:New( oApl:cPuerto,oApl:cImpres,{"RECAUDOS DEL "+;
             NtChr( ::aM[2],"3" ), oApl:oNit:NOMBRE    ,;
            "No.FACTURA  NOMBRE DEL CLIENTE                RECAUDADO"},.t. )
   FOR nR := 1 TO LEN( ::aP )
      If !EMPTY( ::aP[nR,1] )
         oRpt:Titulo( 60 )
         oRpt:Say( oRpt:nL,00,STR(::aP[nR,1],10) )
         oRpt:Say( oRpt:nL,12,::aP[nR,3] )
         oRpt:Say( oRpt:nL,44,TransForm(::aP[nR,4],"999,999,999") )
         oRpt:nL ++
      EndIf
   NEXT nR
   oRpt:Say(++oRpt:nL,25,"Total Recaudo ==>" )
   oRpt:Say(  oRpt:nL,42,TransForm(::aM[9],"9,999,999,999" ))
   oRpt:NewPage()
   oRpt:End()
EndIf
RETURN NIL

//------------------------------------//
METHOD Guardar( oDlg,oLbx ) CLASS TCobro
   LOCAL cQry, nR, lOK := .f.
If EMPTY( ::aP[1,1] )
   MsgStop( "no Tiene ningun Items",::cTipo )
   RETURN NIL
EndIf
If !::oRec:lOK
   If !MsgYesNo("Grabar estos Pagos","QUIERE")
      RETURN NIL
   EndIf
   ::oRec:CODIGO_NIT := oApl:oNit:CODIGO_NIT
   ::oRec:FECHA      := ::aM[2]
   ::oRec:Append( .t. )
   ::oRec:lOK  := .t.
EndIf
FOR nR := 1 TO LEN( ::aP )
   If !EMPTY( ::aP[nR,01] )
      If ::aP[nR,7] == 0
         cQry := "INSERT INTO recaudod VALUES ( null, " + LTRIM(STR(::oRec:CONTROL)) +;
                 ", " + LTRIM(STR(::aP[nR,1])) + ", '"  + ::aP[nR,2] +;
                "', " + LTRIM(STR(::aP[nR,4])) + ", '0' )"
         lOK  := .t.
      Else
         cQry := "UPDATE recaudod SET numfac = " + LTRIM(STR(::aP[nR,1])) +;
                 ", tipo  = '" + ::aP[nR,2]            +;
                "', valor = " + LTRIM(STR(::aP[nR,4])) +;
                 " WHERE row_id = " + LTRIM(STR(::aP[nR,7]))
      EndIf
      MSQuery( oApl:oMySql:hConnect,cQry )
      If ::aP[nR,5]
         GrabaPago( ,::aP[nR,1],(::aP[nR,4]-::aP[nR,6]),::aM[2] )
      EndIf
   EndIf
NEXT
If lOK
   ::AdicArray()
   oLbx:aArray := ::aP
   oLbx:Refresh()
EndIf
RETURN NIL

//------------------------------------//
METHOD Asentar( oLbx ) CLASS TCobro
   LOCAL cQry, cDoc := LTRIM(STR(::oRec:CONTROL)), nR
If MsgYesNo("Aplicar estos Pagos","QUIERE")
   FOR nR := 1 TO LEN( ::aP )
      If oApl:oPag:Seek( {"empresa",oApl:nEmpresa,"numfac",::aP[nR,1],;
                          "tipo",::aP[nR,2],"numcheque",cDoc,;
                          "formapago",0,"pordonde","R"} )
         oApl:oPag:ABONO  := oApl:oPag:PAGADO := ::aP[nR,4]
         Guardar( oApl:oPag,.f.,.f. )
         GrabaPago( ,::aP[nR,1],(::aP[nR,4]-::aP[nR,6]),::aM[2] )
      Else
         oApl:oPag:EMPRESA  := oApl:nEmpresa; oApl:oPag:FECPAG   := ::aM[2]
         oApl:oPag:FORMAPAGO:= 0            ; oApl:oPag:PORDONDE := "R"
         oApl:oPag:NUMCHEQUE:= cDoc
         oApl:oPag:NUMFAC   := ::aP[nR,1]   ; oApl:oPag:TIPO     := ::aP[nR,2]
         oApl:oPag:ABONO    := oApl:oPag:PAGADO := ::aP[nR,4]
         Guardar( oApl:oPag,.t.,.f. )
         Guardar( "UPDATE recaudod SET aplica = '1' WHERE row_id = " +;
                  LTRIM(STR(::aP[nR,7])), "recaudod" )
         GrabaPago( ,::aP[nR,1],::aP[nR,4],::aM[2] )
      EndIf
      ::aP[nR,5] := .t.
      ::aP[nR,9] := "SI"
   NEXT nR
EndIf
oLbx:Refresh()
RETURN NIL

//------------------------------------//
METHOD Barra( oDlg,oLbx ) CLASS TCobro
   LOCAL oBar, oBot := ARRAY(7)
DEFINE BUTTONBAR oBar OF oDlg 3DLOOK SIZE 28,28

DEFINE BUTTON RESOURCE "DEDISCO" OF oBar NOBORDER TOOLTIP "Grabar (F11)";
   ACTION ::Guardar( oDlg,oLbx,.t. )
DEFINE BUTTON RESOURCE "DELREC"  OF oBar NOBORDER TOOLTIP "Aplicar Pagos (F6)";
   ACTION ::Asentar( oLbx ) GROUP
DEFINE BUTTON oBot[4] RESOURCE "ELIMINAR" OF oBar NOBORDER ;
   TOOLTIP "Eliminar (Ctrl+DEL)" ;
   ACTION oLbx:KeyDown( VK_DELETE, 0 )
DEFINE BUTTON oBot[6] RESOURCE "PRINT"    OF oBar NOBORDER ;
   TOOLTIP "Imprimir" ;
   ACTION ::Listado( oDlg,oLbx )
DEFINE BUTTON oBot[7] RESOURCE "QUIT"     OF oBar NOBORDER ;
   TOOLTIP "Salir"    ;
   ACTION oDlg:End()    GROUP
 oBar:bRClicked := {|| NIL }
 oBar:bLClicked := {|| NIL }
RETURN oBar