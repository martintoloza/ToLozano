// Programa.: CAOBANCO.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Creacion y Manto. de Bancos al Sistema
#include "Fivewin.ch"
#include "Btnget.ch"

MEMVAR oApl

FUNCTION Bancos()
   LOCAL oBan := TBan()
oBan:New()
oBan:Activate()
oBan:Cerrar()
oBan:oPuc:Cerrar()
RETURN NIL

//------------------------------------//
CLASS TBan FROM TNits
 DATA aPrv, oNit, oPuc
 METHOD NEW( oTabla ) Constructor
 METHOD Mostrar( lAyuda,nOrd )
 METHOD MostrarB( lAyuda,nOrd )
 METHOD Editar( xRec,lNuevo,lView )
 METHOD EditarB( xRec,lNuevo,lView )
 METHOD Buscar( lTB )
 METHOD Listado() INLINE NIL
ENDCLASS

//------------------------------------//
METHOD NEW( oTabla ) CLASS TBan
If oTabla == NIL
   oTabla := oApl:Abrir( "cgebanco","empresa, banco, cta_cte" )
   oTabla:cWhere := "empresa = " + LTRIM(STR(oApl:nEmpresa))
   Super:NEW( oTabla )
   ::aPrv := Privileg( "BANCOS" )
   ::oNit := TNits() ; ::oNit:New()
   ::oPuc := TPuc()  ; ::oPuc:New()
Else
   oTabla := oApl:Abrir( "cadbanco","codigo" )
   Super:NEW( oTabla )
   ::bEditar := {||::EditarB( ::oDb:Recno(),.f. ) ,;
                   ::oLbx:SetFocus(),::oLbx:Refresh()  }
EndIf
::aOrden := { {"<None> ",1},;
              {"Código" ,2},;
              {"Nombre" ,3} }
::xVar   := "  "
RETURN NIL

//------------------------------------//
METHOD Mostrar( lAyuda,nOrd ) CLASS TBan
   LOCAL oDlg, oM := Self
   LOCAL cTit := "Ayuda de Bancos", bHacer, lReturn := NIL
DEFAULT lAyuda := .t. , nOrd := 2
If lAyuda
   bHacer  := {||lReturn :=.t., oDlg:End()}
   lReturn := .f.
ELSE
   bHacer  := ::bEditar
   cTit    := "Código de Bancos"
ENDIF
nOrd := ::Ordenar( nOrd )

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE cTit
   @ 1.5, 0 LISTBOX ::oLbx FIELDS ;
                    ::oDb:BANCO  ,;
                    ::oDb:NOMBRE ,;
                    ::oDb:CTA_CTE ;
      HEADERS "Banco", "Nombre", "Cuenta"+CRLF+"Corriente";
      SIZES 400, 450 SIZE 200,107 ;
      OF oDlg UPDATE              ;
      ON DBLCLICK EVAL(bHacer)
    ::oLbx:nClrBackHead  := oApl:nClrBackHead
    ::oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    ::oLbx:nClrBackFocus := oApl:nClrBackFocus
    ::oLbx:GoTop()
    ::oLbx:oFont      := ::oFont
    ::oLbx:nHeaderHeight := 28
    ::oLbx:aColSizes   := {50,250,60}
    ::oLbx:aHjustify   := {2,2,2}
    ::oLbx:aJustify    := {0,0,0}
    ::oLbx:ladjbrowse  := ::oLbx:lCellStyle :=.f.
    ::oLbx:ladjlastcol := .t.
    ::oLbx:bKeyChar := { | nKey, nFlags | ::cBus :=         ;
                          ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey=VK_RETURN, (EVAL(bHacer)),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(::BNew),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=69, EVAL(::bEditar)		 ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=86, EVAL(::bVer) 		         ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) )))) }
   MySetBrowse( ::oLbx,::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT ( oM:Barra(lAyuda,oDlg) )
::oDb:Setorder(nOrd)

RETURN lReturn

//------------------------------------//
METHOD MostrarB( lAyuda,nOrd ) CLASS TBan
   LOCAL oDlg, oM := Self
   LOCAL cTit := "Ayuda de Bancos", bHacer, lReturn := NIL
DEFAULT lAyuda := .t. , nOrd := 2
If lAyuda
   bHacer  := {||lReturn :=.t., oDlg:End()}
   lReturn := .f.
ELSE
   bHacer  := ::bEditar
   cTit    := "Código de Bancos"
ENDIF
nOrd := ::Ordenar( nOrd )

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE cTit
   @ 1.5, 0 LISTBOX ::oLbx FIELDS ;
                    ::oDb:CODIGO ,;
         OEMTOANSI( ::oDb:NOMBRE );
      HEADERS "Código", "Nombre"  ;
      SIZES 400, 450 SIZE 200,107 ;
      OF oDlg UPDATE              ;
      ON DBLCLICK EVAL(bHacer)
    ::oLbx:nClrBackHead  := oApl:nClrBackHead
    ::oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    ::oLbx:nClrBackFocus := oApl:nClrBackFocus
    ::oLbx:GoTop()
    ::oLbx:oFont      := ::oFont
    ::oLbx:nHeaderHeight := 28
    ::oLbx:aColSizes  := {50,460}
    ::oLbx:lCellStyle :=.f.
    ::oLbx:aHjustify  := {2,2}
    ::oLbx:aJustify := {.f.,.f.}
    ::oLbx:bKeyChar := { | nKey, nFlags | ::cBus :=         ;
                          ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey=VK_RETURN, (EVAL(bHacer)),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(::BNew),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=69, EVAL(::bEditar)		 ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=86, EVAL(::bVer) 		         ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) )))) }
    ::oLbx:ladjlastcol := .t.
    ::oLbx:ladjbrowse  := .f.
   MySetBrowse( ::oLbx, ::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT ( oM:Barra(lAyuda,oDlg) )
::oDb:Setorder(nOrd)

RETURN lReturn

//------------------------------------//
METHOD Editar( xRec,lNuevo,lView ) CLASS TBan
   LOCAL oDlg, oGet := ARRAY(18), oB := Self
   LOCAL aEd := { "Nuevo Banco",.f.,::oPuc,::oNit }
   DEFAULT lNuevo := .t. , lView  := .f.
If lNuevo
   ::aOld := ACLONE( ::oDb:axBuffer )
   ::oDb:xBlank():Read()
   ::oDb:FF := ::oDb:FV := ::oDb:CB := 2
   ::oDb:FM := ::oDb:CM := 6
   ::oDb:CF := 38       ;  ::oDb:CV := 50
   ::oDb:FB :=  4       ;  ::oDb:LM := 60
   ::oDb:TF := "D"
   ::oDb:INGRESO := ::aOld[19]
   ::oDb:EGRESO  := ::aOld[20]
Else
   aEd[1] := If( lView, "Viendo", "Modificando" ) + " Banco"
EndIf
   ::oNit:oDb:Seek( {"codigo_nit",::oDb:CODIGO_NIT} )
   xRec   := ::oNit:oDb:CODIGO
DEFINE DIALOG oDlg TITLE aEd[1] FROM 0, 0 TO 19,50
   @ 02,00 SAY "Código BCO"    OF oDlg RIGHT PIXEL SIZE 54,10
   @ 02,56 GET oGet[1] VAR ::oDb:BANCO  OF oDlg PICTURE "!!";
      SIZE 18,10 PIXEL WHEN lNuevo
   @ 14,00 SAY "Nombre BCO"    OF oDlg RIGHT PIXEL SIZE 54,10
   @ 14,56 GET oGet[2] VAR ::oDb:NOMBRE  OF oDlg PICTURE "@!";
      VALID !EMPTY(::oDb:NOMBRE)  SIZE 100,10 PIXEL
   @ 26,00 SAY "Cta_Corriente" OF oDlg RIGHT PIXEL SIZE 54,10
   @ 26,56 GET oGet[3] VAR ::oDb:CTA_CTE OF oDlg PICTURE "@!"         ;
      VALID EVAL( {|| If( EMPTY( ::oDb:CTA_CTE ),                     ;
                   (MsgStop("CTA_CTE no puede quedar vacía"),.f.)    ,;
                   (If( ::Buscar( lNuevo ) .AND. lNuevo              ,;
                   (MsgStop("Esta CTA_CTE ya existe"),.f.),.t.) )) } );
      SIZE 40,10 PIXEL
   @ 26, 98 SAY "Cuenta PUC"    OF oDlg RIGHT PIXEL SIZE 40,10
   @ 26,140 BTNGET oGet[4] VAR oB:oDb:CUENTA OF oDlg PICTURE "9999999999";
      ACTION EVAL({|| If( aEd[3]:Mostrar()                      ,;
                        ( oB:oDb:CUENTA := aEd[3]:oDb:CUENTA    ,;
                          oGet[4]:Refresh() ) ,) })              ;
      VALID If( aEd[3]:oDb:Seek( {"empresa",oApl:nPUC,           ;
                                  "cuenta",oB:oDb:CUENTA} ), .t.,;
              ( MsgStop( "Está Cuenta NO EXISTE !!!" ), .f. ) )  ;
      SIZE 52,10 PIXEL  RESOURCE "BUSCAR"
   @  38, 00 SAY "Nit Banco"     OF oDlg RIGHT PIXEL SIZE 54,10
   @  37, 56 BTNGET oGet[5] VAR xRec OF oDlg PICTURE "9999999999";
      ACTION EVAL({|| If( aEd[4]:Mostrar()                 ,;
                        ( xRec := aEd[4]:oDb:Codigo        ,;
                          oGet[5]:Refresh() ) ,) })         ;
      VALID If( aEd[4]:oDb:Seek( {"codigo",xRec} ), .t.    ,;
              ( MsgStop( "Este Nit NO EXISTE !!!" ), .f. ) );
      SIZE 52,10 PIXEL  RESOURCE "BUSCAR"
   @  50, 00 SAY "Ultimo Cheque" OF oDlg RIGHT PIXEL SIZE 54,10
   @  50, 56 GET oGet[06] VAR ::oDb:NUM_CHEQUE OF oDlg PICTURE "9999999999" SIZE 40,10 PIXEL
   @  62, 00 SAY "Linea   Fecha" OF oDlg RIGHT PIXEL SIZE 54,10
   @  62, 56 GET oGet[07] VAR ::oDb:FF OF oDlg PICTURE "99" SIZE 24,10 PIXEL
//      WHEN ::aPrv[2]
   @  62, 84 SAY "Columna Fecha" OF oDlg RIGHT PIXEL SIZE 54,10
   @  62,140 GET oGet[08] VAR ::oDb:CF OF oDlg PICTURE "99" SIZE 24,10 PIXEL
   @  74, 00 SAY "Linea   Valor" OF oDlg RIGHT PIXEL SIZE 54,10
   @  74, 56 GET oGet[09] VAR ::oDb:FV OF oDlg PICTURE "99"  SIZE 24,10 PIXEL
   @  74, 84 SAY "Columna Valor" OF oDlg RIGHT PIXEL SIZE 54,10
   @  74,140 GET oGet[10] VAR ::oDb:CV OF oDlg PICTURE "99"  SIZE 24,10 PIXEL
   @  86, 00 SAY "Linea   Benef" OF oDlg RIGHT PIXEL SIZE 54,10
   @  86, 56 GET oGet[11] VAR ::oDb:FB OF oDlg PICTURE "99"  SIZE 24,10 PIXEL
   @  86, 84 SAY "Columna Benef" OF oDlg RIGHT PIXEL SIZE 54,10
   @  86,140 GET oGet[12] VAR ::oDb:CB OF oDlg PICTURE "99"  SIZE 24,10 PIXEL
   @  98, 00 SAY "Linea   Monto" OF oDlg RIGHT PIXEL SIZE 54,10
   @  98, 56 GET oGet[13] VAR ::oDb:FM OF oDlg PICTURE "99"  SIZE 24,10 PIXEL
   @  98, 84 SAY "Columna Monto" OF oDlg RIGHT PIXEL SIZE 54,10
   @  98,140 GET oGet[14] VAR ::oDb:CM OF oDlg PICTURE "99"  SIZE 24,10 PIXEL
   @ 110, 00 SAY "Largo   Monto" OF oDlg RIGHT PIXEL SIZE 54,10
   @ 110, 56 GET oGet[15] VAR ::oDb:LM OF oDlg PICTURE "999" SIZE 24,10 PIXEL
   @ 110,140 CHECKBOX oGet[16] VAR ::oDb:IMPRIMO PROMPT "Imprimo Cheque" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 124, 60 BUTTON oGet[17] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION;
      (If( EMPTY(::oDb:BANCO) .OR. EMPTY(::oDb:NOMBRE),;
         (MsgStop("No se puede grabar este BANCO, debe completar datos"),;
          oGet[1]:SetFocus()), (aEd[2] := .t.,oDlg:End()) )) PIXEL
   @ 124,110 BUTTON oGet[18] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
   IF lView                     // Solo Consulta
      DesactivaALLGET(oGet)
      oGet[17]:Disable()
      oGet[18]:Enable()
      oGet[18]:SetFocus()
   ENDIF
ACTIVATE DIALOG oDlg CENTER
If aEd[2]
   If lNuevo
      ::oDb:EMPRESA := oApl:nEmpresa
   EndIf
   ::oDb:CODIGO_NIT := ::oNit:oDb:CODIGO_NIT
   ::Guardar(lNuevo)
ElseIf lNuevo
   ::oDb:GoTop():Read()
   ::oDb:xLoad()
EndIf

RETURN NIL

//------------------------------------//
METHOD EditarB( xRec,lNuevo,lView ) CLASS TBan
   LOCAL oDlg, oGet := ARRAY(7)
   LOCAL aEd := { ::oDb:Recno(),"Nuevo Código",.f. }
   DEFAULT lNuevo := .t. , lView  := .f.
If lNuevo
   ::oDb:xBlank()
   ::oDb:Read()
Else
   aEd[2] := If( lView, "Viendo", "Modificando" ) + " Código"
EndIf

DEFINE DIALOG oDlg TITLE aEd[2] FROM 0, 0 TO 12,50
   @ 02,10 SAY "Código"    OF oDlg RIGHT PIXEL SIZE 56,10
   @ 02,70 GET oGet[1] VAR ::oDb:CODIGO OF oDlg PICTURE "!!"         ;
      VALID EVAL( {|| If( EMPTY( ::oDb:CODIGO ),                     ;
                   (MsgStop("El Código no puede quedar vacío"),.f.) ,;
                   (If( ::Buscar( ::oDb:CODIGO ) .AND. lNuevo       ,;
                   (MsgStop("Este Código ya existe"),.f.),.t.) )) } );
      SIZE 18,12 PIXEL  // WHEN lNuevo
   @ 16,10 SAY "Nombre"    OF oDlg RIGHT PIXEL SIZE 56,10
   @ 16,70 GET oGet[2] VAR ::oDb:NOMBRE  OF oDlg PICTURE "@!";
      VALID !EMPTY(::oDb:NOMBRE)  SIZE 100,12 PIXEL
   @ 30,10 SAY "%  Debito" OF oDlg RIGHT PIXEL SIZE 56,10
   @ 30,70 GET oGet[3] VAR ::oDb:DEBITO  OF oDlg PICTURE "99.99" SIZE 24,12 PIXEL
   @ 44,10 SAY "% Credito" OF oDlg RIGHT PIXEL SIZE 56,10
   @ 44,70 GET oGet[4] VAR ::oDb:CREDITO OF oDlg PICTURE "99.99" SIZE 24,12 PIXEL
   @ 58,70 CHECKBOX oGet[5] VAR ::oDb:EN_ESPERA PROMPT "&Esperar Cheque" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 74, 60 BUTTON oGet[6] PROMPT "&Grabar"   SIZE 44,12 OF oDlg ACTION;
      (If( EMPTY(::oDb:CODIGO) .OR. EMPTY(::oDb:NOMBRE),;
         (MsgStop("No se puede grabar este BANCO, debe completar datos"),;
          oGet[1]:SetFocus()), (aEd[3] := .t., oDlg:End()) )) PIXEL
   @ 74,110 BUTTON oGet[7] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
   IF lView                     // Solo Consulta
      DesactivaALLGET(oGet)
      oGet[6]:Disable()
      oGet[7]:Enable()
      oGet[7]:SetFocus()
   ENDIF
ACTIVATE DIALOG oDlg CENTER

If aEd[3]
   ::Guardar(lNuevo)
   aEd[1] := ::oDb:Recno()
Endif
::oDb:Go( aEd[1] ):Read()

RETURN NIL

//------------------------------------//
METHOD Buscar( lTB ) CLASS TBan
   LOCAL cQry, hRes, lSi := .t.
If lTB
   cQry := "SELECT cta_cte FROM cgebanco "               +;
           "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND banco   = " + xValToChar( ::oDb:BANCO )+;
            " AND cta_cte = " + xValToChar( ::oDb:CTA_CTE )
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   lSi  := (MSNumRows( hRes ) != 0)
   MSFreeResult( hRes )
EndIf
RETURN lSi