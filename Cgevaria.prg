// Programa.: CGEFNTES.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Creacion y Manto. CTA-CTE Y COD-VAR
#include "Fivewin.ch"
#include "Objects.ch"

MEMVAR oApl

//------------------------------------//
CLASS TVar FROM TNits

   DATA aCta AS ARRAY INIT { "B","","" }

   METHOD NEW( oBase ) Constructor
   METHOD Mostrar( lAyuda,nOrd,cFiltro )
   METHOD Editar( xRec,lNuevo,lView )
   METHOD Buscar()
   METHOD Listado() INLINE Nil

ENDCLASS

//------------------------------------//
METHOD NEW( oBase ) CLASS TVar
   DEFAULT oBase := oApl:Abrir( "cgevaria","empresa, cuenta" )
Super:New( oBase )
::aOrden := { {"<None> ",1},;
              {"Cuenta" ,4},;
              {"Nombre" ,6} }
RETURN NIL

//------------------------------------//
METHOD Mostrar( lAyuda,nOrd,cFiltro ) CLASS TVar
   LOCAL oDlg, oM := Self
   LOCAL cTit := "Ayuda de Varios", bHacer, lReturn := NIL
   DEFAULT lAyuda := .t. , nOrd := 2
If lAyuda
   bHacer  := {||lReturn :=.t., oDlg:End()}
   lReturn := .f.
ELSE
   bHacer  := ::bEditar
   cTit    := "CTA-CTE o COD-VAR"
ENDIF
If !EMPTY( cFiltro )
   ::oDb:cWhere := " empresa = " + LTRIM( STR(oApl:nEmpresa) ) +;
                " AND cuenta = '" + TRIM( cFiltro ) + "'"
EndIf
nOrd := ::Ordenar( nOrd )

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE cTit
   @ 1.5, 0 LISTBOX ::oLbx FIELDS ;
                    ::oDb:CODIGO  , ::oDb:NOMBRE;
      HEADERS "Código", "Nombre"  ;
      SIZES 400, 450 SIZE 200,107 ;
      OF oDlg UPDATE              ;
      ON DBLCLICK EVAL(bHacer)
    ::oLbx:nClrBackHead  := oApl:nClrBackHead
    ::oLbx:nClrForeHead  := oApl:nClrForeHead
    ::oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    ::oLbx:nClrBackFocus := oApl:nClrBackFocus
    ::oLbx:nClrForeFocus := oApl:nClrForeFocus
    ::oLbx:nHeaderHeight := 28
    ::oLbx:GoTop()
    ::oLbx:oFont       := ::oFont
    ::oLbx:aColSizes   := {50,460}
    ::oLbx:aHjustify   := {2,2}
    ::oLbx:aJustify    := {0,0}
    ::oLbx:ladjbrowse  := ::oLbx:lCellStyle  := .f.
    ::oLbx:ladjlastcol := .t.
    ::oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey,::cWhere ),;
                         oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey=VK_RETURN, (EVAL(bHacer)),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, Eval(::BNew),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=69, EVAL(::bEditar)		 ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=86, EVAL(::bVer) 		         ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) )))) }
   MySetBrowse( ::oLbx, ::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT (oM:Barra( lAyuda,oDlg ))
::oDb:Setorder( nOrd )

RETURN lReturn

//------------------------------------//
METHOD Editar( xRec,lNuevo,lView ) CLASS TVar
   LOCAL oDlg, oGet := ARRAY(4)
   LOCAL aEd := { ::oDb:Recno(),"Nueva ",.f.,"Cuenta ","Cod_Var " }
   DEFAULT lNuevo := .t. , lView := .f.
If ::aCta[1] == "B"
   aEd[4] := "Banco "
   aEd[5] := "Cuenta Cte "
EndIf
IF lNuevo
   ::oDb:xBlank()
   ::oDb:EMPRESA := oApl:nEmpresa
   ::oDb:TIPO    := ::aCta[1]
   ::oDb:CUENTA  := ::aCta[2]
   ::oDb:CODIGO  := ::xVar
   ::oDb:NOMBRE  := ::aCta[3]
ELSE
   aEd[2] := IF( lView, "Viendo ", "Modificando " )
ENDIF

DEFINE DIALOG oDlg TITLE aEd[2] + aEd[5] FROM 0, 0 TO 09,50
   @ 02,00 SAY aEd[4]+::oDb:CUENTA OF oDlg RIGHT PIXEL SIZE 70,10
   @ 16,00 SAY aEd[5]              OF oDlg RIGHT PIXEL SIZE 46,10
   @ 16,50 GET oGet[1] VAR ::oDb:CODIGO OF oDlg PICTURE "9999999999" ;
      VALID EVAL( {|| If( EMPTY( ::oDb:CODIGO ),                     ;
                   (MsgStop("El Código no puede quedar vacío"),.f.) ,;
                   (If( ::Buscar() .AND. lNuevo                     ,;
                   (MsgStop("Este Código ya existe"),.f.),.t.) )) } );
      SIZE 50,12 PIXEL
   @ 30,00 SAY "&Nombre"   OF oDlg RIGHT PIXEL SIZE 46,10
   @ 30,50 GET oGet[2] VAR ::oDb:NOMBRE OF oDlg PICTURE "@!";
      VALID !EMPTY(::oDb:NOMBRE)  SIZE 130,12 PIXEL

   @ 46, 60 BUTTON oGet[3] PROMPT "&Grabar"   SIZE 44,12 OF oDlg ACTION ;
      (IF( EMPTY( ::oDb:CODIGO ) .OR. EMPTY( ::oDb:NOMBRE )            ,;
         (MsgStop("No se puede grabar este Registro, debe completar datos"),;
          oGet[1]:SetFocus()), (aEd[3] := .t., oDlg:End()) )) PIXEL
   @ 46,110 BUTTON oGet[4] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
   IF lView                     // Solo Consulta
      DesactivaALLGET(oGet)
      oGet[4]:Disable()
      oGet[5]:Enable()
      oGet[5]:SetFocus()
   ENDIF
ACTIVATE DIALOG oDlg CENTER

If aEd[3]
   ::Guardar( lNuevo )
   aEd[1] := ::oDb:Recno()
Endif
::oDb:Go( aEd[1] ):Read()

RETURN NIL

//------------------------------------//
METHOD Buscar() CLASS TVar
   LOCAL cQry, hRes
cQry := "SELECT codigo FROM cgevaria WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
        " AND cuenta = " +xValToChar(::oDb:CUENTA) +;
        " AND codigo = " +xValToChar(::oDb:CODIGO)
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
RETURN ( MSNumRows( hRes ) != 0 )