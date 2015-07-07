// Programa.: CGEFNTES.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Creacion y Manto. Tipos de Comprobantes
#include "Fivewin.ch"
#include "Objects.ch"

MEMVAR oApl

FUNCTION Fuentes()
   LOCAL oFte := TFte()
oFte:New()
oFte:Activate()
oFte:Cerrar()
RETURN NIL

//------------------------------------//
CLASS TFte FROM TNits

METHOD NEW( oBase ) Constructor
METHOD Editar( xRec,lNuevo,lView )
METHOD Mostrar( lAyuda,nOrd )
METHOD Buscar()
METHOD Listado()

ENDCLASS

//------------------------------------//
METHOD NEW( oBase ) CLASS TFte
   DEFAULT oBase := oApl:Abrir( "cgefntes","fuente" )
Super:New( oBase )
::aOrden  := { {"<None> ",1},;
               {"Fuente" ,2},;
               {"Nombre" ,3} }
RETURN NIL

//------------------------------------//
METHOD Mostrar( lAyuda,nOrd ) CLASS TFte
   LOCAL oDlg, oM := Self
   LOCAL cTit := "Ayuda de Fuentes", bHacer, lReturn := NIL
DEFAULT lAyuda := .t. , nOrd := 3
If lAyuda
   bHacer  := {||lReturn :=.t., oDlg:End()}
   lReturn := .f.
ELSE
   bHacer  := ::bEditar
   cTit    := "Tipos de Comprobantes"
ENDIF
nOrd := ::Ordenar( nOrd )

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE cTit
   @ 1.5, 0 LISTBOX ::oLbx FIELDS  ;
                STR(::oDb:FUENTE)  , ::oDb:DESCRIPCIO;
      HEADERS "Código", "Descripción" ;
      SIZES 400, 450 SIZE 200,107  ;
      OF oDlg UPDATE               ;
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
    ::oLbx:lCellStyle  := .f.
    ::oLbx:ladjlastcol := .t.
    ::oLbx:ladjbrowse  := .f.
    ::oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey=VK_RETURN, (EVAL(bHacer)),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, Eval(::BNew),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=69, EVAL(::bEditar)		 ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=86, EVAL(::bVer) 		         ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) )))) }
   MySetBrowse( ::oLbx, ::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT (oM:Barra(lAyuda,oDlg))
::oDb:Setorder( nOrd )

RETURN lReturn

//------------------------------------//
METHOD Editar( xRec,lNuevo,lView ) CLASS TFte
   LOCAL oDlg, oGet := ARRAY(5)
   LOCAL aEd := { ::oDb:Recno(),"Nuevo Fuente",.f. }
DEFAULT lNuevo := .t. ,;
        lView  := .f.
IF lNuevo
   ::oDb:GoBottom():Read()
   ::oDb:xLoad()
   xRec := ::oDb:FUENTE
   ::oDb:xBlank()
   ::oDb:FUENTE := xRec + 1
ELSE
   aEd[2] := IF( lView, "Viendo", "Modificando" ) + " Fuentes"
ENDIF

DEFINE DIALOG oDlg TITLE aEd[2] FROM 0, 0 TO 09,50
   @ 02,00 SAY "&Código"   OF oDlg RIGHT PIXEL SIZE 46,10
   @ 02,50 GET oGet[1] VAR ::oDb:FUENTE OF oDlg PICTURE "99"         ;
      VALID EVAL( {|| If( EMPTY( ::oDb:FUENTE ),                     ;
                   (MsgStop("El Código no puede quedar vacío"),.f.), ;
                   (If( ::Buscar() .AND. lNuevo                     ,;
                   (MsgStop("Este Código ya existe"),.f.),.t.) )) } );
      SIZE 18,12 PIXEL  // WHEN lNuevo
   @ 16,00 SAY "&Nombre"   OF oDlg RIGHT PIXEL SIZE 46,10
   @ 16,50 GET oGet[2] VAR ::oDb:DESCRIPCIO OF oDlg PICTURE "@!";
      VALID !EMPTY(::oDb:DESCRIPCIO)  SIZE 130,12 PIXEL
   @ 30,50 CHECKBOX oGet[3] VAR ::oDb:CTRL_CONSE ;
      PROMPT "&Listar Consecutivos Faltantes" OF oDlg SIZE 110,12 PIXEL

   @ 46, 60 BUTTON oGet[4] PROMPT "&Grabar"   SIZE 44,12 OF oDlg ACTION   ;
      (IF( EMPTY( ::oDb:FUENTE ) .OR. EMPTY( ::oDb:DESCRIPCIO )          ,;
         (MsgStop("No se puede grabar esta FUENTE, debe completar datos"),;
          oGet[1]:SetFocus()), (aEd[3] := .t., oDlg:End()) )) PIXEL
   @ 46,110 BUTTON oGet[5] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
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
EndIf
::oDb:Go( aEd[1] ):Read()

RETURN NIL

//------------------------------------//
METHOD Buscar() CLASS TFte
   LOCAL cQry, hRes
cQry := "SELECT fuente FROM cgefntes WHERE fuente = " + LTRIM( STR(::oDb:FUENTE) )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
RETURN ( MSNumRows( hRes ) != 0 )

//------------------------------------//
METHOD Listado() CLASS TFte
   LOCAL aLI, cQry, hRes, nL, oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"TIPOS DE COMPROBANTES","",;
           "CODIGO   NOMBRE DE LA  FUENTE"},.t. )
cQry := "SELECT fuente, descripcio, ctrl_conse FROM cgefntes ORDER BY " +;
        LTRIM(STR(::aOrden[ ::nOrden,2 ]))
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aLI := MyReadRow( hRes )
   AEVAL( aLI, { | xV,nP | aLI[nP] := MyClReadCol( hRes,nP ) } )
   oRpt:Titulo( 72 )
   oRpt:Say( oRpt:nL,02,STR(aLI[1],2) )
   oRpt:Say( oRpt:nL,09,aLI[2] )
   oRpt:Say( oRpt:nL,69,If( aLI[3], "Si", "No" ) )
   oRpt:nL ++
   nL --
EndDo
MSFreeResult( hRes )
oRpt:NewPage()
oRpt:End()
RETURN NIL