// Programa.: HISRIPS.PRG     >>> Martin A. Toloza Lozano <<<
// Notas....: Creacion y Manto. de Codigos
#include "Fivewin.ch"
#include "Objects.ch"

MEMVAR oApl

FUNCTION BrowseRips( nX )
   LOCAL oRip := TRip()
oRip:New( nX )
oRip:Activate()
If nX # 1
   oRip:Cerrar()
EndIf
RETURN NIL

//------------------------------------//
CLASS TRip FROM TNits

 DATA aRip  INIT { {"ciudades","Municipios"     },{"ridars"  ,"Administradoras"},;
                   {"ridespec","Especialidades" },{"ridocupa","Ocupaciones"    },;
                   {"ridclpro","Procedimientos" },{"riddiagn","Diagnosticos"   },;
                   {"pais"    ,"Paises"         },{"vitrinas","Vitrinas"       },;
                   {"marcas"  ,"Marcas" } }
 DATA nRip

 METHOD NEW( nRip,lDel ) Constructor
 METHOD Editar( xRec,lNuevo,lView )
 METHOD Mostrar( lAyuda,nOrd )
 METHOD Listado()

ENDCLASS

//------------------------------------//
METHOD NEW( nRip,lDel ) CLASS TRip
   LOCAL oTabla := oApl:oHab
   DEFAULT nRip := 1
If nRip # 1
   oTabla := oApl:Abrir( ::aRip[nRip,1],"codigo",.t.,,100 )
EndIf
Super:New( oTabla,lDel )
::aOrden  := { {"<None> ",1},{"Código" ,2},{"Nombre" ,"nombre"} }
::nRip    := nRip
::xVar    := ::oDb:CODIGO
RETURN NIL

//------------------------------------//
METHOD Mostrar( lAyuda,nOrd ) CLASS TRip
   LOCAL oDlg, oM := Self
   LOCAL cTit := ::aRip[::nRip,2], bHacer, lReturn := NIL
   DEFAULT lAyuda := .t. , nOrd := 3
If lAyuda
   bHacer  := {||lReturn :=.t., oDlg:End()}
   cTit    := "Ayuda de " + ::aRip[::nRip,2]
   lReturn := .f.
ELSE
   bHacer  := ::bEditar
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
    ::oLbx:oFont       := ::oFont
    ::oLbx:nHeaderHeight := 28
    ::oLbx:aColSizes   := {50,460}
    ::oLbx:aHjustify   := {2,2}
    ::oLbx:aJustify    := {0,0}
    ::oLbx:ladjbrowse  := ::oLbx:lCellStyle  := .f.
    ::oLbx:ladjlastcol := .t.
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
METHOD Editar(xRec,lNuevo,lView) CLASS TRip
   LOCAL oDlg, oGet := ARRAY(4)
   LOCAL aEd := { ::oDb:Recno(),"Nuevo Código",.f.,0 }
   DEFAULT lNuevo := .t. , lView  := .f.
If Rango( ::nRip,{ 2,5,7 } )
   oGet := ARRAY(5)
EndIf
If lNuevo
   ::oDb:xBlank()
   ::oDb:Read()
Else
   aEd[2] := If( lView, "Viendo", "Modificando" ) + " Código"
EndIf

DEFINE DIALOG oDlg TITLE aEd[2] + " // " + ::aRip[::nRip,2] FROM 0, 0 TO 10, 80
   @ 02,00 SAY "&Código"  OF oDlg RIGHT PIXEL SIZE 40,10
   @ 02,42 GET oGet[1] VAR ::oDb:CODIGO OF oDlg PICTURE "!!!!!!"     ;
      VALID EVAL( {|| If( EMPTY( ::oDb:CODIGO ),                     ;
                   (MsgStop("El Código no puede quedar vacío"),.f.) ,;
                   (If( ::Buscar( ::oDb:CODIGO ) .AND. lNuevo       ,;
                   (MsgStop("Este Código ya existe"),.f.),.t.) )) } );
      SIZE 30,12 PIXEL // WHEN lNuevo
   @ 16,00 SAY "&Nombre"  OF oDlg RIGHT PIXEL SIZE 40,10
   @ 16,42 GET oGet[2] VAR ::oDb:NOMBRE OF oDlg PICTURE "@!";
      VALID !EMPTY(::oDb:NOMBRE) SIZE 270,12 PIXEL
   If ::nRip == 2      //ARS
      @ 30,00 SAY "&SGSSS :" OF oDlg RIGHT PIXEL SIZE 40,10
      @ 30,42 GET oGet[5] VAR ::oDb:SGSSS OF oDlg PICTURE "@!" SIZE 45,12 PIXEL
   ElseIf ::nRip == 5  //CLPRO
      @ 30,00 SAY "&Valor :" OF oDlg RIGHT PIXEL SIZE 40,10
      @ 30,42 GET oGet[5] VAR ::oDb:VALOR OF oDlg PICTURE "999,999" SIZE 45,12 PIXEL
   ElseIf ::nRip == 7  //LENTES
      aEd[4] := MAX( 1,AT( ::oDb:TIPO_LENTE,"OC" ) )
      @ 02,06 TO 05,15 LABEL "Tipo &Lente" OF oDlg
      @ 03,07 RADIO oGet[5] VAR aEd[4] PROMPT "&Oftalmico", "&Contacto" OF oDlg;
         SIZE 40,12
   EndIf
   @ 50,130 BUTTON oGet[3] PROMPT "&Grabar"   SIZE 44,12 OF oDlg ACTION;
       (IF( EMPTY(::oDb:CODIGO) .OR. EMPTY(::oDb:NOMBRE),;
          ( MsgStop("No se puede grabar este Registro, debe completar datos"),;
            oGet[1]:SetFocus()), (aEd[3] := .t.,oDlg:End()) )) PIXEL
   @ 50,180 BUTTON oGet[4] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION (aEd[3] := .f.,oDlg:End()) PIXEL
   ACTIVAGET(oGet)
   IF lView                     // Solo Consulta
      DesactivaALLGET(oGet)
      oGet[3]:Disable()
      oGet[4]:Enable()
      oGet[4]:SetFocus()
   ENDIF
ACTIVATE DIALOG oDlg CENTER

If aEd[3]
   If ::nRip == 7
      ::oDb:TIPO_LENTE := If( aEd[4] == 1, "O", "C" )
   Endif
   ::Guardar(lNuevo)
   aEd[1] := ::oDb:Recno()
Endif
::oDb:Go( aEd[1] ):Read()

RETURN NIL

//------------------------------------//
METHOD Listado() CLASS TRip
   LOCAL oRpt, aLis := { 0,::oDb:Recno() }
//DEFINE FONT oFont1 NAME "COURIER" SIZE 0,-10
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"LISTADO DE "+::aRip[::nRip,2],"",;
           "CODIGO   N O M B R E"},.t.,,2 )
::oDb:GoTop():Read()
::oDb:xLoad()
While !::oDb:Eof()
   oRpt:Titulo( 72 )
   oRpt:Say( oRpt:nL,01,::oDb:CODIGO )
   oRpt:Say( oRpt:nL,09,::oDb:NOMBRE )
   oRpt:nL ++
   aLis[1]  ++
   ::oDb:Skip(1):Read()
   ::oDb:xLoad()
EndDo
If aLis[1] > 0
   oRpt:Say( oRpt:nL++,10,REPLICATE ("_",62) )
   oRpt:Say( oRpt:nL  ,10,"TOTAL ESTE LISTADO...." + STR( aLis[1],4 ) )
EndIf
oRpt:NewPage()
oRpt:End()
::oDb:Go(aLis[2]):Read()
::oLbx:GoTop()
::oLbx:Refresh()
RETURN NIL