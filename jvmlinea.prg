// Programa.: JVMLINEA.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Creacion y Manto. de Lineas de Articulos.
#include "Fivewin.ch"
#include "Objects.ch"
//#include "btnget.ch"

MEMVAR oApl

FUNCTION Categoria( nVen )
   LOCAL oCat := TCat()
oCat:New( ,nVen )
If nVen == NIL
   oCat:Activate()
Else
   oCat:Muestra( .f. )
   oCat:Cerrar()
EndIf
RETURN NIL

//------------------------------------//
CLASS TCat FROM TNits
 DATA cCla

 METHOD NEW( oTabla,nVen,cCla ) Constructor
 METHOD Mostrar( lAyuda,nOrd )
 METHOD Editar( xRec,lNuevo,lView )
 METHOD Mostrag( lAyuda,nOrd )
 METHOD Editag( lNuevo,lView )
 METHOD Muestra( lAyuda,nOrd )
 METHOD Editav( lNuevo,lView )
 METHOD Listado()

ENDCLASS

//------------------------------------//
METHOD NEW( oTabla,nVen,cCla ) CLASS TCat

If nVen == NIL
   Super:New( oApl:oLin )
   ::aOrden := { {"<None> ",1},{"Linea"  ,2},{"Nombre" ,3} }
ElseIf nVen == 1
   oTabla := oApl:Abrir( "actclase","nombre",.t.,,100 )
   Super:New( oTabla,.f. )
   ::aOrden  := { {"<None> ",1},{"Grupo"  ,3},{"Nombre" ,4} }
   ::cCla    := cCla
   ::bNew    := {||::Editag( .t. ) }
   ::bEditar := {||::Editag( .f. ) }
   ::bVer    := {||::Editag( .f.,.t. ) }
Else
   oTabla := oApl:Abrir( "vendedor","nombre",.t.,,100 )
   Super:New( oTabla,.f. )
   ::aOrden  := { {"<None> ",1},{"Codigo" ,1},{"Nombre" ,3} }
   ::bNew    := {||::Editav( .t. ),    ;
                   ::oLbx:SetFocus(),::oLbx:Refresh()  }
   ::bEditar := {||::Editav( .f. ),    ;
                   ::oLbx:SetFocus(),::oLbx:Refresh()  }
   ::bVer    := {||::Editav( .f.,.t. ),;
                   ::oLbx:SetFocus(),::oLbx:Refresh()  }
   //If nVen == 2
   //   ::oCiu := TNits() ; ::oCiu:New()
   //EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Mostrar( lAyuda,nOrd ) CLASS TCat
   LOCAL oDlg, oM := Self
   LOCAL cTit := "Ayuda de Líneas", bHacer, lReturn := NIL
   DEFAULT lAyuda := .t. , nOrd := 3
If lAyuda
   bHacer  := {||lReturn :=.t., oDlg:End()}
   lReturn := .f.
ELSE
   bHacer  := ::bEditar
   cTit    := "Código de Línea"
ENDIF
nOrd := ::Ordenar( nOrd )

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE cTit
   @ 1.5, 0 LISTBOX ::oLbx FIELDS ;
                    ::oDb:LINEA, ::oDb:NOMBRE ;
      HEADERS "Código", "Nombre" ;
      SIZES 400, 450 SIZE 200,107 ;
      OF oDlg UPDATE              ;
      ON DBLCLICK EVAL(bHacer)
    ::oLbx:nClrBackHead  := oApl:nClrBackHead
    ::oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    ::oLbx:nClrBackFocus := oApl:nClrBackFocus
    ::oLbx:nHeaderHeight := 28
    ::oLbx:GoTop()
    ::oLbx:oFont       := ::oFont
    ::oLbx:aColSizes   := {50,250}
    ::oLbx:aHjustify   := {2,2}
    ::oLbx:aJustify    := {0,0}
    ::oLbx:ladjbrowse  := ::oLbx:lCellStyle  := .f.
    ::oLbx:ladjlastcol := .t.
    ::oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey=VK_RETURN, (EVAL(bHacer)),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(::bNew),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=69, EVAL(::bEditar)	 ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=86, EVAL(::bVer) 		 ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) )))) }
   MySetBrowse( ::oLbx, ::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT ( oM:Barra(lAyuda,oDlg) )
::oDb:Setorder(nOrd)

RETURN lReturn

//------------------------------------//
METHOD Editar(xRec,lNuevo,lView) CLASS TCat
   LOCAL oDlg, oGet := ARRAY(4)
   LOCAL aEd := { ::oDb:Recno(),"Nueva Línea",.f. }
   DEFAULT lNuevo := .t. , lView  := .f.
If lNuevo
   ::oDb:xBlank()
   ::oDb:Read()
Else
   aEd[2] := If( lView, "Viendo", "Modificando" ) + " Línea"
EndIf

DEFINE DIALOG oDlg TITLE aEd[2] FROM 0, 0 TO 08,60
   @ 02,00 SAY "Línea" OF oDlg RIGHT PIXEL SIZE 40,10
   @ 02,42 GET oGet[1] VAR ::oDb:LINEA OF oDlg PICTURE "@!"      ;
      VALID EVAL( {|| If( EMPTY( ::oDb:LINEA ),                  ;
                   (MsgStop("El Código no puede quedar vacío"),.f.) ,;
                   (If( ::Buscar( ::oDb:LINEA,"Linea" ) .AND. lNuevo,;
                   (MsgStop("Esta Línea ya existe"),.f.),.t.) )) } ) ;
      SIZE 18,12 PIXEL  // WHEN lNuevo
   @ 16,00 SAY "Nombre"    OF oDlg RIGHT PIXEL SIZE 40,10
   @ 16,42 GET oGet[2] VAR ::oDb:NOMBRE  OF oDlg PICTURE "@!";
      VALID !EMPTY(::oDb:NOMBRE)  SIZE 190,12 PIXEL

   @ 32, 60 BUTTON oGet[3] PROMPT "&Grabar"   SIZE 44,12 OF oDlg ACTION;
      (If( EMPTY(::oDb:LINEA) .OR. EMPTY(::oDb:NOMBRE),;
         (MsgStop("No se puede grabar esta LINEA, debe completar datos"),;
          oGet[1]:SetFocus()), (aEd[3] := .t.,oDlg:End()) )) PIXEL
   @ 32,110 BUTTON oGet[4] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
   IF lView                     // Solo Consulta
      DesactivaALLGET(oGet)
      oGet[3]:Disable()
      oGet[4]:Enable()
      oGet[4]:SetFocus()
   ENDIF
ACTIVATE DIALOG oDlg CENTER

If aEd[3]
   ::Guardar(lNuevo)
   aEd[1] := ::oDb:Recno()
Endif
::oDb:Go( aEd[1] ):Read()

RETURN NIL

//------------------------------------//
METHOD Mostrag( lAyuda,nOrd ) CLASS TCat
   LOCAL oDlg, oM := Self
   LOCAL cTit := "Ayuda de Grupos", bHacer, lReturn := NIL
   DEFAULT lAyuda := .t. , nOrd := 3
If lAyuda
   bHacer  := {||lReturn :=.t., oDlg:End()}
   lReturn := .f.
ELSE
   bHacer  := ::bEditar
   cTit    := "Grupos de Activos"
ENDIF
::oDb:cWhere := " clase = '" + ::cCla + "'"
nOrd := ::Ordenar( nOrd )

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE cTit
   @ 1.5, 0 LISTBOX ::oLbx FIELDS ;
                    ::oDb:GRUPO, ::oDb:NOMBRE ;
      HEADERS "Grupo", "Nombre" ;
      SIZES 400, 450 SIZE 200,107 ;
      OF oDlg UPDATE              ;
      ON DBLCLICK EVAL(bHacer)
    ::oLbx:nClrBackHead  := oApl:nClrBackHead
    ::oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    ::oLbx:nClrBackFocus := oApl:nClrBackFocus
    ::oLbx:nHeaderHeight := 28
    ::oLbx:GoTop()
    ::oLbx:oFont       := ::oFont
    ::oLbx:aColSizes   := {50,250}
    ::oLbx:aHjustify   := {2,2}
    ::oLbx:aJustify    := {0,0}
    ::oLbx:ladjbrowse  := ::oLbx:lCellStyle  := .f.
    ::oLbx:ladjlastcol := .t.
    ::oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey=VK_RETURN, (EVAL(bHacer)),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(::bNew),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=69, EVAL(::bEditar)   ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=86, EVAL(::bVer) 		 ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) )))) }
   MySetBrowse( ::oLbx, ::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT ( oM:Barra(lAyuda,oDlg) )
::oDb:Setorder(nOrd)

RETURN lReturn

//------------------------------------//
METHOD Editag( lNuevo,lView ) CLASS TCat
   LOCAL oDlg, oGet := ARRAY(6)
   LOCAL aEd := { ::oDb:Recno(),"Nueva Grupo",.f. }
   DEFAULT lNuevo := .t. , lView  := .f.
If lNuevo
   ::oDb:xBlank()
   ::oDb:Read()
Else
   aEd[2] := If( lView, "Viendo", "Modificando" ) + " Grupo"
EndIf

DEFINE DIALOG oDlg TITLE aEd[2] FROM 0, 0 TO 09,60
   @ 02,00 SAY "Grupo" OF oDlg RIGHT PIXEL SIZE 40,10
   @ 02,42 GET oGet[1] VAR ::oDb:GRUPO OF oDlg PICTURE "9999"    ;
      VALID EVAL( {|| If( EMPTY( ::oDb:GRUPO ),                  ;
                   (MsgStop("El Grupo no puede quedar vacío"), .f.) ,;
                   (If( ::Buscar( ::oDb:GRUPO,"grupo" ) .AND. lNuevo,;
                   (MsgStop("Este Grupo ya existe"),.f.),.t.) )) } ) ;
      SIZE 18,10 PIXEL
   @ 14,00 SAY "Nombre"    OF oDlg RIGHT PIXEL SIZE 40,10
   @ 14,42 GET oGet[2] VAR ::oDb:NOMBRE  OF oDlg PICTURE "@!";
      VALID !EMPTY(::oDb:NOMBRE)  SIZE 190,10 PIXEL
   @ 26,00 SAY "Vida Util" OF oDlg RIGHT PIXEL SIZE 40,10
   @ 26,42 GET oGet[3] VAR ::oDb:VUTIL   OF oDlg PICTURE "99";
      SIZE 18,10 PIXEL
   @ 38,00 SAY "Vida Util IFRS" OF oDlg RIGHT PIXEL SIZE 40,10
   @ 38,42 GET oGet[4] VAR ::oDb:VIFRS   OF oDlg PICTURE "99";
      SIZE 18,10 PIXEL

   @ 52, 60 BUTTON oGet[5] PROMPT "&Grabar"   SIZE 44,12 OF oDlg ACTION;
      (If( EMPTY(::oDb:GRUPO) .OR. EMPTY(::oDb:NOMBRE),;
         (MsgStop("No se puede grabar este Grupo, debe completar datos"),;
          oGet[1]:SetFocus()), (aEd[3] := .t.,oDlg:End()) )) PIXEL
   @ 52,110 BUTTON oGet[6] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
   IF lView                     // Solo Consulta
      DesactivaALLGET(oGet)
      oGet[5]:Disable()
      oGet[6]:Enable()
      oGet[6]:SetFocus()
   ENDIF
ACTIVATE DIALOG oDlg CENTER

If aEd[3]
   If lNuevo
      ::oDb:CLASE := ::cCla
      ::oDb:Append( .t. )
      aEd[1] := ::oDb:Recno()
   Else
      ::oDb:Update(.t.,1)
   EndIf
   ::oDb:Go( aEd[1] ):Read()
   ::oLbx:SetFocus()
   ::oLbx:Refresh()
EndIf
RETURN NIL

//------------------------------------//
METHOD Muestra( lAyuda,nOrd ) CLASS TCat
   LOCAL oDlg, oM := Self
   LOCAL cTit := "Ayuda de Vendedores", bHacer, lReturn := NIL
   DEFAULT lAyuda := .t. , nOrd := 3
If lAyuda
   bHacer  := {||lReturn :=.t., oDlg:End()}
   lReturn := .f.
ELSE
   bHacer  := ::bEditar
   cTit    := "Código de Vendedores"
ENDIF
nOrd := ::Ordenar( nOrd )

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE cTit
   @ 1.5, 0 LISTBOX ::oLbx FIELDS ;
         TRANSFORM( ::oDb:CODIGO_VEN,"999,999"),;
                    ::oDb:NOMBRE ;
      HEADERS "Código", "Nombre" ;
      SIZES 400, 450 SIZE 200,107 ;
      OF oDlg UPDATE              ;
      ON DBLCLICK EVAL(bHacer)
    ::oLbx:nClrBackHead  := oApl:nClrBackHead
    ::oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    ::oLbx:nClrBackFocus := oApl:nClrBackFocus
    ::oLbx:nHeaderHeight := 28
    ::oLbx:GoTop()
    ::oLbx:oFont       := ::oFont
    ::oLbx:aColSizes   := {50,250}
    ::oLbx:aHjustify   := {2,2}
    ::oLbx:aJustify    := {1,0}
    ::oLbx:ladjbrowse  := ::oLbx:lCellStyle  := .f.
    ::oLbx:ladjlastcol := .t.
    ::oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey=VK_RETURN, (EVAL(bHacer)),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(::BNew),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=69, EVAL(::bEditar)	 ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=86, EVAL(::bVer) 		 ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) )))) }
   MySetBrowse( ::oLbx, ::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT ( oM:Barra(lAyuda,oDlg) )
::oDb:Setorder(nOrd)

RETURN lReturn

//------------------------------------//
METHOD Editav( lNuevo,lView ) CLASS TCat
   LOCAL oDlg, oGet := ARRAY(5)
   LOCAL aEd := { ::oDb:Recno(),"Nuevo Código",.f.,0 }
   DEFAULT lNuevo := .t. , lView  := .f.
If lNuevo
   ::oDb:xBlank()
   ::oDb:Read()
Else
   aEd[2] := If( lView, "Viendo", "Modificando" ) + " Código"
EndIf
   Nitsx( ::oDb:CODIGO_NIT,@aEd,4 )

DEFINE DIALOG oDlg TITLE aEd[2] FROM 0, 0 TO 08,50
   @ 02,00 SAY "Código Vendedor" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 02,52 SAY oGet[1] VAR ::oDb:CODIGO_VEN OF oDlg ;
      PICTURE "999,999" SIZE 30,10 PIXEL
   @ 14,00 SAY "Cédula Vendedor" OF oDlg RIGHT PIXEL SIZE 50,10
// @ 14,52 BTNGET oGet[2] VAR aEd[4] OF oDlg PICTURE "9999999999";
//    ACTION EVAL({|| If(oNi:Mostrar(), (aEd[4] := oNi:oDb:CODIGO ,;
//                       oGet[2]:Refresh() ),) })                  ;
//    VALID EVAL( {|| If( oNi:Buscar( aEd[4],"codigo",.t. )       ,;
   @ 14,52 GET oGet[2] VAR aEd[4] OF oDlg PICTURE "9999999999"     ;
      VALID EVAL( {|| If( oApl:oNit:Seek( {"codigo",aEd[4]} )     ,;
                        ( ::oDb:NOMBRE     := oApl:oNit:NOMBRE    ,;
                          ::oDb:CODIGO_NIT := oApl:oNit:CODIGO_NIT,;
                          oGet[3]:Settext(::oDb:NOMBRE), .t. )    ,;
                    (MsgStop("Está Cédula no Existe"), .f.) ) } )  ;
      SIZE 44,10 PIXEL
//    SIZE 44,10 PIXEL RESOURCE "BUSCAR"
   @ 26,00 SAY "Nombre"    OF oDlg RIGHT PIXEL SIZE 50,10
   @ 26,52 GET oGet[3] VAR ::oDb:NOMBRE  OF oDlg PICTURE "@!";
      VALID !EMPTY(::oDb:NOMBRE)  SIZE 120,10 PIXEL

   @ 40, 60 BUTTON oGet[4] PROMPT "&Grabar"   SIZE 44,12 OF oDlg ACTION;
      (If( EMPTY(::oDb:CODIGO_NIT) .OR. EMPTY(::oDb:NOMBRE),;
         (MsgStop("No se puede grabar este Vendedor, debe completar datos"),;
          oGet[2]:SetFocus()), (aEd[3] := .t.,oDlg:End()) )) PIXEL
   @ 40,110 BUTTON oGet[5] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
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
   ::Guardar(lNuevo)
   aEd[1] := ::oDb:Recno()
Endif
::oDb:Go( aEd[1] ):Read()

RETURN NIL

//------------------------------------//
METHOD Listado() CLASS TCat
   LOCAL oRpt, nConta := 0, nReg := ::oDb:Recno()
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"LISTADO DE LINEAS","",;
          "CODIGO   NOMBRE   DE  LA  LINEA  DEL  ARTICULO"},.t. )
::oDb:GoTop():Read()
::oDb:xLoad()
While !::oDb:Eof()
   oRpt:Titulo( 72 )
   oRpt:Say( oRpt:nL,02,::oDb:LINEA )
   oRpt:Say( oRpt:nL,09,::oDb:NOMBRE )
   oRpt:nL ++
   nConta   ++
   ::oDb:Skip(1):Read()
   ::oDb:xLoad()
EndDo
If nConta > 0
   oRpt:Say( oRpt:nL++,10,REPLICATE ("_",62) )
   oRpt:Say( oRpt:nL  ,10,"TOTAL CODIGOS ESTE LISTADO...." + STR( nConta,4 ) )
EndIf
oRpt:NewPage()
oRpt:End()
::oDb:Go(nReg):Read()
::oLbx:GoTop()
::oLbx:Refresh()
RETURN NIL