// Programa.: CAOCATEG.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Creacion y Manto. de Categorias.
#include "Fivewin.ch"
#include "Objects.ch"

MEMVAR oApl

FUNCTION Categoria()
   LOCAL oCat := TCat()
oCat:New()
oCat:Activate()
RETURN NIL

//------------------------------------//
CLASS TCat FROM TNits

METHOD NEW( oTabla ) Constructor
METHOD Editar( xRec,lNuevo,lView )
METHOD Mostrar( lAyuda,nOrd )
METHOD Listado()

ENDCLASS

//------------------------------------//
METHOD NEW( oTabla ) CLASS TCat
   DEFAULT oTabla := oApl:oCat
Super:New(oTabla)
::aOrden := { {"<None> ",1},;
              {"Código" ,2},;
              {"Nombre" ,3} }
RETURN NIL

//------------------------------------//
METHOD Mostrar( lAyuda,nOrd ) CLASS TCat
   LOCAL oDlg, oM := Self
   LOCAL cTit := "Ayuda de Categorias", bHacer, lReturn := NIL
DEFAULT lAyuda := .t. , nOrd := 2
If lAyuda
   bHacer  := {||lReturn :=.t., oDlg:End()}
   lReturn := .f.
ELSE
   bHacer  := ::bEditar
   cTit    := "Código de Categoria"
ENDIF
nOrd := ::Ordenar( nOrd )

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE cTit
   @ 1.5, 0 LISTBOX ::oLbx FIELDS ;
               STR( ::oDb:CATEGORIA ),;
                    ::oDb:NOMBRE , ::oDb:GRUPO;
      HEADERS "Categoria", "Nombre", "Grupo" ;
      SIZES 400, 450 SIZE 200,107 ;
      OF oDlg UPDATE              ;
      ON DBLCLICK EVAL(bHacer)
    ::oLbx:nClrBackHead  := oApl:nClrBackHead
    ::oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    ::oLbx:nClrBackFocus := oApl:nClrBackFocus
    ::oLbx:nHeaderHeight := 28
    ::oLbx:GoTop()
    ::oLbx:oFont       := ::oFont
    ::oLbx:aColSizes   := {50,250,100}
    ::oLbx:aHjustify   := {2,2,2}
    ::oLbx:aJustify    := {0,0,0}
    ::oLbx:lCellStyle  := .f.
    ::oLbx:ladjlastcol := .t.
    ::oLbx:ladjbrowse  := .f.
    ::oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey=VK_RETURN, (Eval(bHacer)),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, Eval(::BNew),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=69, Eval(::bEditar)		 ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=86, Eval(::bVer) 		         ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, Eval(::bBuscar),) )))) }
   MySetBrowse( ::oLbx, ::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT ( oM:Barra(lAyuda,oDlg) )
::oDb:Setorder(nOrd)

RETURN lReturn

//------------------------------------//
METHOD Editar(xRec,lNuevo,lView) CLASS TCat
   LOCAL oDlg, oGet := ARRAY(5)
   LOCAL aEd := { ::oDb:Recno(),"Nueva Categoria",.f. }
DEFAULT lNuevo := .t. ,;
        lView  := .f. ,;
        xRec   :=  0
If lNuevo
   ::oDb:xBlank()
   ::oDb:Read()
Else
   aEd[2] := If( lView, "Viendo", "Modificando" ) + " Categoria"
EndIf

DEFINE DIALOG oDlg TITLE aEd[2] FROM 0, 0 TO 10,50
   @ 02,10 SAY "&Categoria" OF oDlg RIGHT PIXEL SIZE 56,10
   @ 02,70 GET oGet[1] VAR ::oDb:CATEGORIA OF oDlg PICTURE "999"     ;
      VALID EVAL( {|| If( EMPTY( ::oDb:CATEGORIA ),                  ;
                   (MsgStop("El Código no puede quedar vacío"),.f.) ,;
                   (If( ::Buscar( ::oDb:CATEGORIA ) .AND. lNuevo    ,;
                   (MsgStop("Este Código ya existe"),.f.),.t.) )) } );
      SIZE 18,12 PIXEL  // WHEN lNuevo
   @ 16,10 SAY "&Nombre"    OF oDlg RIGHT PIXEL SIZE 56,10
   @ 16,70 GET oGet[2] VAR ::oDb:NOMBRE  OF oDlg PICTURE "@!";
      VALID !EMPTY(::oDb:NOMBRE)  SIZE 100,12 PIXEL
   @ 30,10 SAY "&Grupo"     OF oDlg RIGHT PIXEL SIZE 56,10
   @ 30,70 GET oGet[3] VAR ::oDb:GRUPO   OF oDlg SIZE 24,12 PIXEL

   @ 46, 60 BUTTON oGet[4] PROMPT "&Grabar"   SIZE 44,12 OF oDlg ACTION;
      (If( EMPTY(::oDb:CATEGORIA) .OR. EMPTY(::oDb:NOMBRE),;
         (MsgStop("No se puede grabar esta CATEGORIA, debe completar datos"),;
          oGet[1]:SetFocus()), (aEd[3] := .t.,oDlg:End()) )) PIXEL
   @ 46,110 BUTTON oGet[5] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION (aEd[3] := .f.,oDlg:End()) PIXEL
   ACTIVAGET(oGet)
   IF lView                     // Solo Consulta
      DesactivaALLGET(oGet)
      oGet[4]:Disable()
      oGet[5]:Enable()
      oGet[5]:SetFocus()
   ENDIF
ACTIVATE DIALOG oDlg CENTER

If aEd[3]
   ::Guardar(lNuevo)
   aEd[1] := ::oDb:Recno()
Endif
::oDb:Go( aEd[1] ):Read()

RETURN NIL

//------------------------------------//
METHOD Listado() CLASS TCat
   LOCAL oDPrn, nConta := 0, nReg := ::oDb:Recno()
oDPrn := TDosPrint()
oDPrn:New( oApl:cPuerto,oApl:cImpres,{"LISTADO DE CATEGORIAS","",;
           "CODIGO   NOMBRE   DE  LA   CATEGORIA               G R U P O"},.t. )
::oDb:GoTop():Read()
::oDb:xLoad()
While !::oDb:Eof()
   oDPrn:Titulo( 72 )
   oDPrn:Say( oDPrn:nL,02,::oDb:CATEGORIA )
   oDPrn:Say( oDPrn:nL,09,::oDb:NOMBRE )
   oDPrn:Say( oDPrn:nL,51,::oDb:GRUPO )
   oDPrn:nL ++
   nConta   ++
   ::oDb:Skip(1):Read()
   ::oDb:xLoad()
EndDo
If nConta > 0
   oDPrn:Say( oDPrn:nL++,10,Replicate ("_",62) )
   oDPrn:Say( oDPrn:nL  ,10,"TOTAL CATEGORIAS ESTE LISTADO...." + STR( nConta,4 ) )
EndIf
oDPrn:NewPage()
oDPrn:End()
::oDb:Go(nReg):Read()
::oLbx:GoTop()
::oLbx:Refresh()
RETURN NIL
