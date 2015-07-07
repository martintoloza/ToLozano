// Programa.: CGESOCIO.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Creacion y Manto. de Socios.
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

PROCEDURE CgeSocio()
   LOCAL oDlg, oGet := ARRAY(7), aSoc := { 0,0,"",0 }
   LOCAL bGrabar, oSoc, oNi := TNits()
oNi:New()
oSoc := oApl:Abrir( "cgesocio","empresa, codigo_nit" )
oSoc:dbEval( {|o| aSoc[1] += o:PORCENTAJE }, {"empresa",oApl:nEmpresa} )
oSoc:xBlank()
bGrabar := { || If( EMPTY( aSoc[2] )                   ,;
                MsgStop("Imposible grabar este Socio") ,;
               (oSoc:CODIGO_NIT := oNi:oDb:CODIGO_NIT  ,;
                If( oSoc:lOK      ,                     ;
                  ( oSoc:Update(.t.,1), oGet[7]:Disable() ),;
                  ( oSoc:EMPRESA := oApl:nEmpresa          ,;
                    oSoc:Append(.t.) ) ), oSoc:xBlank()    ,;
                   oDlg:Update() ) ), oDlg:SetFocus()   }
DEFINE DIALOG oDlg TITLE "MANTENIMIENTO DE SOCIOS" FROM 0, 0 TO 11,50
   @ 02,00 SAY "Porcentaje Total" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 02,82 SAY oGet[1] VAR aSoc[1] OF oDlg PICTURE "999.99" COLOR nRGB( 255,0,0 );
      SIZE 40,12 PIXEL UPDATE
   @ 16,00 SAY "NIT o C.C. del Socio" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 16,82 BTNGET oGet[2] VAR aSoc[2] OF oDlg PICTURE "9999999999" ;
      VALID EVAL( {|| If( oNi:oDb:Seek( {"codigo",aSoc[2]} )      ,;
                ( If( oSoc:Seek( {"empresa",oApl:nEmpresa,         ;
                                "codigo_nit",oNi:oDb:CODIGO_NIT} ),;
                      oGet[7]:Enable()                            ,;
                     (oGet[7]:Disable(), oSoc:xBlank()) )         ,;
                  aSoc[3] := oNi:oDb:NOMBRE                       ,;
                  aSoc[4] := oSoc:PORCENTAJE, oDlg:Update(), .t. ),;
                ( MsgStop("Este Nit no Existe"),.f. )) } )         ;
      SIZE 56,12 PIXEL  RESOURCE "BUSCAR"                          ;
      ACTION EVAL({|| If(oNi:Mostrar(), (aSoc[2] := oNi:oDb:CODIGO,;
                        oGet[2]:Refresh(), oGet[2]:lValid(.f.)),)})
   @ 30,40 SAY    oGet[3] VAR aSoc[3] OF oDlg PIXEL SIZE 140,12 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 44,00 SAY "Porcentaje del Socio" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 44,82    GET oGet[4] VAR oSoc:PORCENTAJE OF oDlg PICTURE "999.99";
      VALID {|| If( oSoc:PORCENTAJE <= 0, ;
          (MsgStop( "El Porcentaje debe ser Mayor de 0","<< OJO >>" ), .f.),;
          (aSoc[1] += oSoc:PORCENTAJE - aSoc[4], If( aSoc[1] > 100,;
          (MsgStop( "El Porcentaje de esta Empresa es Mayor del 100%",;
           STR(aSoc[1],7,2)), aSoc[1] += aSoc[4] - oSoc:PORCENTAJE, .f.), .t.))) };
      SIZE 34,12 PIXEL UPDATE
   @ 60, 40 BUTTON oGet[5] PROMPT "Grabar"   SIZE 44,12 OF oDlg ;
      ACTION EVAL(bGrabar) PIXEL
   @ 60, 90 BUTTON oGet[6] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 60,140 BUTTON oGet[7] PROMPT "Borrar"   SIZE 44,12 OF oDlg ACTION;
      (If( MsgYesNo( "Eliminar este Socio","Quiere" )         ,;
         ( aSoc[1] -= oSoc:PORCENTAJE, oSoc:Delete(.t.,1) ), ),;
           oDlg:Update(), oDlg:SetFocus() ) PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT ( oGet[7]:Disable() )
oSoc:Destroy()

RETURN

//------------------------------------//
PROCEDURE Ajustes( nA )
   LOCAL aBar, oAju, oDlg, oLbx, oNi
   LOCAL aMtl := { "AJUSTE POR INFLACION","AJUSTE POR DEPRECIACION",;
                   "CUENTAS DE RETENCION",9,10,11 }
   DEFAULT nA := 1
oNi  := TNits() ; oNi:New()
oAju := oApl:Abrir( "cgeajust","fuente" )
oAju:Seek( {"empresa",oApl:nPUC,"fuente",aMtl[nA+3]},"cuenta_db" )
aBar := { {|| AjustEdita( oLbx,oAju,aMtl[nA+3],oNi,.t. ) },;
          {|| AjustEdita( oLbx,oAju,aMtl[nA+3],oNi,.f. ) },;
          {|| .t. }                    ,;
          {|| AjustBorra( oLbx,oAju ) },;
          {|| .t. }                    ,;
          {|| oDlg:End() } }
DEFINE DIALOG oDlg FROM 3, 3 TO 22, 56 TITLE aMtl[nA]
   @ 20,02 LISTBOX oLbx FIELDS oAju:CUENTA    ,;
                               oAju:CUENTA_DB ,;
                               oAju:CUENTA_CR  ;
      HEADERS "Cuenta"+CRLF+"Saldo", "Cuenta"+CRLF+"Debito",;
              "Cuenta"+CRLF+"Credito";
      SIZES 400, 450 SIZE 200,107    ;
      OF oDlg UPDATE PIXEL           ;
      ON DBLCLICK EVAL( aBar[2] )
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:nHeaderHeight := 28
    oLbx:GoTop()
    oLbx:oFont       := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:aColSizes   := {110,110,110}
    oLbx:aHjustify   := {2,2,2}
    oLbx:aJustify    := {0,0,0}
    oLbx:ladjlastcol := .t.
    oLbx:ladjbrowse  := oLbx:lCellStyle  := .f.
    oLbx:bKeyDown := {|nKey| If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(aBar[1]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, EVAL(aBar[2]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, EVAL(aBar[4]),) )) }
   MySetBrowse( oLbx, oAju )

ACTIVATE DIALOG oDlg ON INIT ;
  ( oDlg:Move(80,1), DefineBar( oDlg,oLbx,aBar,02,18 ) )
oAju:Destroy()
RETURN

//------------------------------------//
STATIC PROCEDURE AjustBorra( oLbx,oAju )
If MsgNoYes( "Está Cuenta "+oAju:CUENTA,"Elimina" )
   oAju:Read()
   oAju:Delete(.t.,1)
   oLbx:Refresh()
EndIf
RETURN

//------------------------------------//
STATIC PROCEDURE AjustEdita( oLbx,oAju,nFte,oNi,lNew )
   LOCAL bPuc, oDlg, oGet := ARRAY(8), cText := "Modificando Cuenta"
   LOCAL bGrabar := {|| oAju:Update(.t.,1), oDlg:End() }
If lNew
   oAju:xBlank()
   bGrabar := {|| oAju:EMPRESA := oApl:nPUC      ,;
                  oAju:FUENTE  := nFte           ,;
                  oAju:Append(.t.)               ,;
                  PListbox( oLbx,oAju )          ,;
                  oAju:xBlanK()                  ,;
                  oDlg:Update()  , oDlg:SetFocus() }
   //               oLbx:UpStable(), oLbx:Refresh(),;
   cText := "Nueva Cuenta"
EndIf
bPuc := {|sCta| If( Buscar( {"empresa",oApl:nPUC,"cuenta",sCta},;
                             "cgeplan","1",8,,4 ) == 1, .t.    ,;
                  ( MsgStop("Esta Cuenta no Existe"),.f. )) }
DEFINE DIALOG oDlg TITLE cText FROM 0, 0 TO 12,40
   @ 02,00 SAY "Cuenta Saldo"   OF oDlg RIGHT PIXEL SIZE 66,10
   @ 02,70 GET oGet[1] VAR oAju:CUENTA     OF oDlg PICTURE "9999999999";
      VALID EVAL( bPuc,oAju:CUENTA ) ;
      WHEN nFte <= 10  SIZE 30,10 PIXEL UPDATE
   @ 14,00 SAY "Cuenta  Debito" OF oDlg RIGHT PIXEL SIZE 66,10
   @ 14,70 GET oGet[2] VAR oAju:CUENTA_DB  OF oDlg PICTURE "9999999999";
      VALID EVAL( bPuc,oAju:CUENTA_DB ) ;
      SIZE 50,10 PIXEL UPDATE
   @ 26,00 SAY "Cuenta Credito" OF oDlg RIGHT PIXEL SIZE 66,10
   @ 26,70 GET oGet[3] VAR oAju:CUENTA_CR  OF oDlg PICTURE "9999999999";
      VALID EVAL( bPuc,oAju:CUENTA_CR ) ;
      SIZE 50,10 PIXEL UPDATE
   @ 38,00 SAY "Porcentaje"     OF oDlg RIGHT PIXEL SIZE 66,10
   @ 38,70 GET oGet[4] VAR oAju:PORCENTAJE OF oDlg PICTURE "999.99";
      WHEN nFte == 10  SIZE 30,10 PIXEL UPDATE
   @ 50,00 SAY "Código Depre."  OF oDlg RIGHT PIXEL SIZE 66,10
   @ 50,70 GET oGet[5] VAR oAju:CODIGO     OF oDlg PICTURE "9999999999";
      WHEN nFte == 10  SIZE 50,10 PIXEL UPDATE
   @ 62,00 SAY "NIT o C.C. Retención" OF oDlg RIGHT PIXEL SIZE 66,10
   @ 62,70 BTNGET oGet[6] VAR oAju:CODIGO OF oDlg PICTURE "9999999999";
      ACTION EVAL({|| If(oNi:Mostrar(), (oAju:CODIGO :=               ;
                         STR(oNi:oDb:CODIGO), oGet[6]:Refresh() ),) });
      VALID EVAL( {|| If( oNi:oDb:Seek( {"codigo",oAju:CODIGO} ), .t.,;
                        ( MsgStop("Este Nit no Existe"),.f. )) } )    ;
      WHEN nFte == 11  SIZE 50,10 PIXEL RESOURCE "BUSCAR"
   @ 76, 50 BUTTON oGet[7] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION;
      (If( (EMPTY(oAju:CUENTA)   .AND. nFte # 11) .OR.       ;
            EMPTY(oAju:CUENTA_DB) .OR. EMPTY(oAju:CUENTA_CR),;
         ( MsgStop("Imposible grabar CUENTA"), oGet[1]:SetFocus() )  ,;
          EVAL(bGrabar) )) PIXEL
   @ 76,100 BUTTON oGet[8] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)

RETURN