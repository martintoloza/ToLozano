// Programa.: NOMCAUSA.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Mantenimiento de las Causaciones
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

FUNCTION Causacion()
   LOCAL oC, oDlg, oLbx, oGet := ARRAY(7)
Empresa( .t. )
oC := TCausa() ; oC:New()

DEFINE DIALOG oDlg FROM 0, 0 TO 330, 580 PIXEL;
   TITLE "Causaciones"
   @ 16, 00 SAY "Secuencia"   OF oDlg RIGHT PIXEL SIZE 50,10
   @ 16, 52 GET oGet[1] VAR oC:nSecue OF oDlg PICTURE "999999";
      VALID oC:Buscar( oDlg,oLbx,oGet )                       ;
      SIZE 30,10 PIXEL UPDATE
   @ 28, 00 SAY "Descripcion" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 28, 52 GET oGet[2] VAR oC:oNc:NOMBRE OF oDlg PICTURE "@!"    ;
      VALID EVAL( { || If( !EMPTY( oC:oNc:NOMBRE ), .t.          ,;
            (MsgStop("Digite un Breve Concepto",">>>OJO<<<"),.f.) ) } );
      SIZE 130,10 PIXEL UPDATE
    oGet[2]:bRClicked = {|| oC:Buscando( 1,oDlg,oLbx ) }
   @ 40, 00 SAY "Cuenta"      OF oDlg RIGHT PIXEL SIZE 50,10
   @ 40, 52 BTNGET oGet[3] VAR oC:oNc:CUENTA OF oDlg PICTURE "9999999999"         ;
      VALID If( oC:oPuc:oDb:Seek( {"Empresa",oApl:nPuc,"Cuenta",oC:oNc:CUENTA} ) ,;
                ( oDlg:Update(), .t. )                                           ,;
                ( MsgStop( "Está Cuenta NO EXISTE !!!" ), .f. ) )                 ;
      SIZE 50,10 PIXEL UPDATE  RESOURCE "BUSCAR"                                  ;
      ACTION EVAL({|| If( oC:oPuc:Mostrar(), (oC:oNc:CUENTA := oC:oPuc:oDb:CUENTA,;
                        oGet[3]:Refresh(), oGet[3]:lValid(.f.)),)})
    oGet[3]:bRClicked = {|| oC:Buscando( 2,oDlg,oLbx ) }
   @ 40,104 SAY oGet[4] VAR oC:oPuc:oDb:NOMBRE OF oDlg PIXEL SIZE 140,10;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 52, 00 SAY "Identifica"  OF oDlg RIGHT PIXEL SIZE 50,10
   @ 52, 52 GET oGet[5] VAR oC:oNc:IDENTIFICA OF oDlg PICTURE "@!"    ;
      VALID EVAL( { || If( !EMPTY( oC:oNc:Identifica ), .t.          ,;
            (MsgStop("Digite un Breve Concepto",">>>OJO<<<"),.f.) ) } );
      SIZE 130,10 PIXEL UPDATE
    oGet[5]:bRClicked = {|| oC:Buscando( 3,oDlg,oLbx ) }
   @ 64, 00 SAY "Procedimiento" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 64, 52 GET oGet[6] VAR oC:oNc:PROCESO OF oDlg PICTURE "@!" ;
      SIZE 100,10 PIXEL UPDATE
    oGet[6]:bRClicked = {|| oC:Buscando( 4,oDlg,oLbx ) }
   @ 76, 00 SAY "Porcentaje"    OF oDlg RIGHT PIXEL SIZE 50,10
   @ 76, 52 GET oGet[7] VAR oC:oNc:PTAJE   OF oDlg PICTURE "999.99999" ;
      SIZE 40,10 PIXEL UPDATE

   @ 90,06 LISTBOX oLbx FIELDS               ;
         TRANSFORM( oC:oNd:CONCEPTO,"9,999"),;
         LeerConce( oC:oNd:CONCEPTO )       ,;
                    oC:oNd:CUENTA            ;
      HEADERS "Concepto", "Nombre"+CRLF+"Concepto","Cuenta";
      SIZES 100, 150 SIZE 280,74  ;
      OF oDlg UPDATE PIXEL        ;
      ON DBLCLICK oC:Editar( oLbx,.f. )
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:nHeaderHeight := 28
    oLbx:GoTop()
    oLbx:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:aColSizes   := {84,260,70}
    oLbx:aHjustify   := {2,2,2}
    oLbx:aJustify    := {0,0,0}
    oLbx:ladjbrowse  := oLbx:lCellStyle := .f.
    oLbx:ladjlastcol := .t.
    oLbx:bKeyDown := {|nKey| If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, oC:Editar( oLbx,.t. ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, oC:Editar( oLbx,.f. ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE             , oC:Borrar( oLbx ), ))) }
   MySetBrowse( oLbx,oC:oNd )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTER ON INIT (oC:Barra( oDlg,oLbx ))
oC:oNc:Destroy()
oC:oNd:Destroy()
oC:oPuc:oDb:Destroy()
RETURN NIL

//------------------------------------//
CLASS TCausa

 DATA nSecue        INIT 1
 DATA nSkip, oCn, oNc, oNd, oPuc

 METHOD NEW() Constructor
 METHOD Buscar( oDlg,oLbx,oGet )
 METHOD Buscando( nTab,oDlg,oLbx )
 METHOD Avanza( oDlg,oLbx,nSkip )
 METHOD Borrar( oLbx )
 METHOD Editar( oLbx,lNew )
 METHOD Grabar( oLbx,lNew )
 METHOD Barra( oDlg,oLbx )
ENDCLASS

//------------------------------------//
METHOD New() CLASS TCausa

 ::oNc := oApl:Abrir( "nocausac","Empresa, Secuencia",.t.,,50 )
 ::oNd := oApl:Abrir( "nocausad","Secuencia, Concepto",,,100 )
 ::oCn := TCon() ; ::oCn:New()
 ::oPuc:= TPuc() ; ::oPuc:New()
 ::Buscar()

RETURN NIL

//------------------------------------//
METHOD Buscar( oDlg,oLbx,oGet ) CLASS TCausa
   LOCAL lSi := .f.
 ::nSkip := 1
 ::oNc:Seek( {"Empresa",oApl:nPuc,"Secuencia",::nSecue} )
 ::oNd:Seek( {"Secuencia",::nSecue},"Concepto" )
 If oLbx # NIL
    ::oPuc:oDb:Seek( {"Empresa",oApl:nPuc,"Cuenta",::oNc:CUENTA} )
    oDlg:Update()
    oGet[1]:oJump := oLbx
    oLbx:Refresh()
    lSi := .t.
 EndIf
RETURN lSi

//------------------------------------//
METHOD Buscando( nTab,oDlg,oLbx ) CLASS TCausa
   LOCAL aBus := { "Nombre","Cuenta","Identifica","Proceso" }
   LOCAL cBus := "%" + SPACE(24), nOldRec := ::oNc:Recno()
If MsgGet( aBus[ nTab ],"Buscar",@cBus )
   cBus := UPPER( ALLTRIM( cBus ) )
   cBus += If( RIGHT( cBus ) == "%", "", "%" )
   If ::oNc:Find( aBus[ nTab ],cBus,"" ) == 0
      MessageBeep()
      Msginfo( "Termino la busqueda"+ CRLF +"Examine o corrija","Advertencia!!!" )
      ::oNc:Go(nOldRec):Read()
   Else
      ::oNc:GoTop():Read()
      ::oNc:xLoad()
      ::nSkip  := 1
      ::nSecue := ::oNc:SECUENCIA
      ::oNd:Seek( { "Secuencia",::nSecue } )
      oDlg:Update()
      oLbx:Refresh()
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Avanza( oDlg,oLbx,nSkip ) CLASS TCausa
   LOCAL lSkip := .f.
If ::oNc:nRowCount > 1
   If (nSkip ==  1 .AND. ::nSkip < ::oNc:nRowCount) .OR.;
      (nSkip == -1 .AND. ::nSkip > 1)
      lSkip := .t.
   EndIf
   If lSkip
      ::oNc:Skip(nSkip):Read()
      ::oNc:xLoad()
      ::oPuc:oDb:Seek( {"Empresa",oApl:nPuc,"Cuenta",::oNc:CUENTA} )
      ::nSkip  += nSkip
      ::nSecue := ::oNc:SECUENCIA
      ::oNd:Seek( { "Secuencia",::nSecue } )
      oDlg:Update()
      oLbx:Refresh() ; oLbx:Setfocus()
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Borrar( oLbx ) CLASS TCausa

If MsgNoYes( "Este Concepto"+STR(::oNd:CONCEPTO,4),"Elimina" )
   If ::oNd:Delete( .t.,1 )
      ::oNd:nRowCount --
      PListbox( oLbx,::oNd )
   EndIf
   oLbx:SetFocus()
EndIf
RETURN NIL

//------------------------------------//
METHOD Editar( oLbx,lNew ) CLASS TCausa
   LOCAL oDlg, cTit := "Modificando Concepto"
   LOCAL bGrabar, oGet := ARRAY(6), oE := Self
If lNew
   cTit    := "Nuevo Concepto"
   bGrabar := {|| ::Grabar( oLbx,lNew )        ,;
                  ::oNd:xBlanK()               ,;
                  oDlg:Update(), oDlg:SetFocus() }
   oLbx:GoBottom() ; ::oNd:xBlank()
Else
   bGrabar := {|| ::Grabar( oLbx,lNew ), oLbx:Refresh(), oDlg:End() }
EndIf
 ::oCn:oDb:Seek( {"Concepto",oE:oNd:CONCEPTO} )
::oPuc:oDb:Seek( {"Empresa",oApl:nPuc,"Cuenta",::oNd:CUENTA} )

DEFINE DIALOG oDlg TITLE cTit FROM 0, 0 TO 09,40
   @ 02,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 50,10
   @ 02,52 BTNGET oGet[1] VAR oE:oNd:CONCEPTO OF oDlg PICTURE "999";
      VALID If( oE:oCn:oDb:Seek( {"Concepto",oE:oNd:CONCEPTO} )   ,;
                ( oDlg:Update(), .t. )                            ,;
                ( MsgStop( "Este Concepto NO EXISTE !!!" ), .f. ) );
      SIZE 40,10 PIXEL  RESOURCE "BUSCAR"                          ;
      ACTION EVAL({|| If(oE:oCn:Mostrar(), (oE:oNd:CONCEPTO := oE:oCn:oDb:CONCEPTO,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)), )})
   @ 14,44 SAY oGet[2] VAR ::oCn:oDb:NOMBRE OF oDlg PIXEL SIZE 120,10;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 26,00 SAY "Cuenta"      OF oDlg RIGHT PIXEL SIZE 50,10
   @ 26,52 BTNGET oGet[3] VAR oE:oNd:CUENTA OF oDlg PICTURE "9999999999"          ;
      VALID EVAL( {|| If( EMPTY( oE:oNd:CUENTA ), .t.                            ,;
                    ( If( oE:oPuc:oDb:Seek( {"Empresa",oApl:nPuc,"Cuenta"        ,;
                          oE:oNd:CUENTA} ), ( oDlg:Update(), .t. )               ,;
                        ( MsgStop( "Está Cuenta NO EXISTE !!!" ), .f. ) ) ) ) } ) ;
      SIZE 50,10 PIXEL  RESOURCE "BUSCAR"                                         ;
      ACTION EVAL({|| If( oE:oPuc:Mostrar(), (oE:oNd:CUENTA := oE:oPuc:oDb:CUENTA,;
                        oGet[3]:Refresh(), oGet[3]:lValid(.f.)),)})
   @ 38,44 SAY oGet[4] VAR ::oPuc:oDb:NOMBRE OF oDlg PIXEL SIZE 120,10;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 52, 60 BUTTON oGet[5] PROMPT "Grabar"   SIZE 40,12 OF oDlg ACTION;
      (If( EMPTY( ::oNd:CONCEPTO )     ,;
         ( MsgStop("Imposible grabar este Concepto"), oGet[1]:SetFocus()),;
         ( oGet[5]:Disable(), EVAL( bGrabar ), oGet[5]:Enable() ))) PIXEL
   @ 52,104 BUTTON oGet[6] PROMPT "Cancelar" SIZE 40,12 OF oDlg CANCEL;
      ACTION ( oDlg:End() ) PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTER
 oLbx:SetFocus()
RETURN NIL

//------------------------------------//
METHOD Grabar( oLbx,lNew ) CLASS TCausa
   LOCAL cQry
If ::oNc:lOK
   ::oNc:Update( .f.,1 )
Else
   ::oNc:EMPRESA   := oApl:nPuc
   ::oNc:SECUENCIA := ::nSecue
   ::oNc:Append( .t. )
   ::oNc:lOK := .t.
EndIf
If oLbx # NIL
   If lNew
      ::oNd:SECUENCIA := ::nSecue
      ::oNd:Append( .t. )
      PListbox( oLbx,::oNd )
   Else
      ::oNd:Update( .t.,1 )
   EndIf
   If ::oNd:CUENTA == ::oNc:CUENTA .OR. EMPTY( ::oNd:CUENTA )
      cQry := "UPDATE nocausad SET cuenta = NULL WHERE row_id = "
      MSQuery( oApl:oMySql:hConnect,cQry+LTRIM(STR(::oNd:ROW_ID)) )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Barra( oDlg,oLbx ) CLASS TCausa
   LOCAL oBar, oBot := ARRAY(7)
DEFINE BUTTONBAR oBar OF oDlg 3DLOOK SIZE 28,28

DEFINE BUTTON RESOURCE "DEDISCO" OF oBar NOBORDER TOOLTIP "Grabar (F11)";
   ACTION ::Grabar()
DEFINE BUTTON oBot[4] RESOURCE "ELIMINAR" OF oBar NOBORDER ;
   TOOLTIP "Eliminar (Ctrl+DEL)" ;
   ACTION ::Borrar( oLbx )
DEFINE BUTTON RESOURCE "ANTERIOR"  OF oBar NOBORDER TOOLTIP "Registro Anterior";
   ACTION ::Avanza( oDlg,oLbx,-1 ) GROUP
DEFINE BUTTON RESOURCE "SIGUIENTE" OF oBar NOBORDER TOOLTIP "Siguiente Registro";
   ACTION ::Avanza( oDlg,oLbx, 1 )
DEFINE BUTTON oBot[7] RESOURCE "QUIT"     OF oBar NOBORDER ;
   TOOLTIP "Salir"    ;
   ACTION oDlg:End()   GROUP
 oBar:bRClicked := {|| NIL }
 oBar:bLClicked := {|| NIL }
RETURN oBar

//------------------------------------//
FUNCTION LeerConce( cCod )
   oApl:oCon:Seek( {"Concepto",cCod} )
RETURN oApl:oCon:NOMBRE
