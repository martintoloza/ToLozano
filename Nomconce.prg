// Programa.: NOMCONCE.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Creacion y Manto. de Conceptos.
#include "Fivewin.ch"

MEMVAR oApl

FUNCTION Conceptos()
   LOCAL oCon := TCon()
oCon:New( .f. )
oCon:Activate()
RETURN NIL

//------------------------------------//
CLASS TCon FROM TNits

 DATA aCol AS ARRAY INIT { "SUELDO BASICO","AUXILIO TRANSPORTE",;
                           "OTROS PAGOS"  ,"SALUD","PENSION"   ,;
                           "F.S.P.","PRESTAMOS","OTROS DESCTOS" }
 METHOD NEW( lDel ) Constructor
 METHOD Editar( xRec,lNuevo,lView )
 METHOD Mostrar( lAyuda,nOrd )
 METHOD Listado() INLINE nil

ENDCLASS

//------------------------------------//
METHOD NEW( lDel ) CLASS TCon
   DEFAULT lDel := .t.
Super:New( oApl:oCon,lDel )
::aOrden := { {"<None> ",1},{"Código" ,2},;
              {"Nombre" ,3} }
::xVar  := "  "
RETURN NIL

//------------------------------------//
METHOD Mostrar( lAyuda,nOrd ) CLASS TCon
   LOCAL oDlg, oM := Self
   LOCAL cTit := "Ayuda de Conceptos", bHacer, lReturn := NIL
   DEFAULT lAyuda := .t. , nOrd := 3
If lAyuda
   bHacer  := {||lReturn :=.t., oDlg:End()}
   lReturn := .f.
ELSE
   bHacer  := ::bEditar
   cTit    := "Código de Conceptos"
ENDIF
nOrd := ::Ordenar( nOrd )
DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE cTit
   @ 1.5, 0 LISTBOX ::oLbx FIELDS    ;
               STR( ::oDb:CONCEPTO ),;
         OEMTOANSI( ::oDb:NOMBRE )   ;
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
    ::oLbx:aHjustify  := {2,2}
    ::oLbx:aJustify   := {0,0}
    ::oLbx:bKeyChar := { | nKey, nFlags | ::cBus :=         ;
                          ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey=VK_RETURN, (EVAL(bHacer)),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, Eval(::BNew),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=69, EVAL(::bEditar)		 ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=86, EVAL(::bVer) 		         ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) )))) }
    ::oLbx:ladjbrowse  := ::oLbx:lCellStyle := .f.
    ::oLbx:ladjlastcol := .t.
   MySetBrowse( ::oLbx, ::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT ( oM:Barra(lAyuda,oDlg) )
::oDb:Setorder(nOrd)

RETURN lReturn

//------------------------------------//
METHOD Editar(xRec,lNuevo,lView) CLASS TCon
   LOCAL oDlg, oGet := ARRAY(19)
   LOCAL aEd := { ::oDb:Recno(),"Nuevo Código",.f. }
   DEFAULT lNuevo := .t. , lView  := .f. ,;
           xRec   := 0
If lNuevo
   ::oDb:xBlank()
   ::oDb:Read()
Else
   aEd[2] := If( lView, "Viendo", "Modificando" ) + " Código"
EndIf

DEFINE DIALOG oDlg TITLE aEd[2] FROM 0, 0 TO 330, 460 PIXEL;
   OF oApl:oWnd
   @ 02,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 66,10
   @ 02,70 GET oGet[1] VAR ::oDb:CONCEPTO OF oDlg PICTURE "999"      ;
      VALID EVAL( {|| If( EMPTY( ::oDb:CONCEPTO ),                   ;
                   (MsgStop("El Código no puede quedar vacío"),.f.) ,;
                   (If( ::Buscar( ::oDb:CONCEPTO,"concepto" ) .AND. lNuevo,;
                   (MsgStop("Este Código ya existe"),.f.),.t.) )) } );
      SIZE 18,10 PIXEL
   @  14, 00 SAY "Nombre"    OF oDlg RIGHT PIXEL SIZE 66,10
   @  14, 70 GET oGet[02] VAR ::oDb:NOMBRE  OF oDlg PICTURE "@!";
      VALID !EMPTY(::oDb:NOMBRE)  SIZE 110,10 PIXEL
   @  26, 00 SAY "Clase P/D" OF oDlg RIGHT PIXEL SIZE 66,10
   @  26, 70 GET oGet[03] VAR ::oDb:CLASEPD OF oDlg PICTURE "9" ;
      VALID EVAL( {|| If( Rango( ::oDb:CLASEPD,1,2 )           ,;
                        ( If( lNuevo, (::oDb:COLUMNA :=         ;
                                 {3,8}[::oDb:CLASEPD]          ,;
                                 oGet[6]:Refresh() ), ), .t. ) ,;
                   (MsgStop("1_Pagos, 2_Descuentos"),.f.) ) } ) ;
      SIZE 10,10 PIXEL
   @  38, 00 SAY "Cuenta"    OF oDlg RIGHT PIXEL SIZE 68,10
   @  38, 70 GET oGet[04] VAR ::oDb:CUENTA  OF oDlg PICTURE "9999999999";
      SIZE 40,10 PIXEL
   @  50, 00 SAY "Ptaje"     OF oDlg RIGHT PIXEL SIZE 66,10
   @  50, 70 GET oGet[05] VAR ::oDb:PTAJE    OF oDlg PICTURE "999.99" SIZE 28,10 PIXEL
   @  62, 00 SAY "Listar en Columna" OF oDlg RIGHT PIXEL SIZE 66,10
   @  62, 70 COMBOBOX oGet[06] VAR ::oDb:COLUMNA ITEMS ::aCol;
     SIZE 100,99 OF oDlg PIXEL UPDATE
   @  74, 70 CHECKBOX oGet[07] VAR ::oDb:SALARIO    PROMPT "Salario"   OF oDlg ;
      SIZE 60,10 PIXEL
   @  74,170 CHECKBOX oGet[08] VAR ::oDb:CAJA       PROMPT "Caja Comp" OF oDlg ;
      SIZE 60,10 PIXEL
   @  86, 70 CHECKBOX oGet[09] VAR ::oDb:PRIMAS     PROMPT "Primas"    OF oDlg ;
      SIZE 60,10 PIXEL
   @  86,170 CHECKBOX oGet[10] VAR ::oDb:VACACIONES PROMPT "Vacacion"  OF oDlg ;
      SIZE 60,10 PIXEL
   @  98, 70 CHECKBOX oGet[11] VAR ::oDb:CESANTIAS  PROMPT "Cesantias" OF oDlg ;
      SIZE 60,10 PIXEL
   @  98,170 CHECKBOX oGet[12] VAR ::oDb:RETENCION  PROMPT "Retencion" OF oDlg ;
      SIZE 60,10 PIXEL
   @ 110, 00 SAY "Forma Liq" OF oDlg RIGHT PIXEL SIZE 66,10
   @ 110, 70 GET oGet[13] VAR ::oDb:FORMALIQ  OF oDlg PICTURE "9"  SIZE 10,10 PIXEL;
      MESSAGE "1_Cantidad ó Horas, 2_Pesos, 3_Porcentaje"
   @ 110,170 CHECKBOX oGet[14] VAR ::oDb:GSALARIO   PROMPT "Salud_Pen" OF oDlg ;
      SIZE 60,10 PIXEL
   @ 122, 70 CHECKBOX oGet[15] VAR ::oDb:AUTOMATICA PROMPT "Automatic" OF oDlg ;
      SIZE 60,10 PIXEL
   @ 122,170 CHECKBOX oGet[16] VAR ::oDb:ACUMULADIA PROMPT "Acum.Dias" OF oDlg ;
      SIZE 60,10 PIXEL
   @ 134, 00 SAY "Rutina"    OF oDlg RIGHT PIXEL SIZE 66,10
   @ 134, 70 GET oGet[17] VAR ::oDb:RUTINA    OF oDlg PICTURE "@!X" SIZE 100,10 PIXEL
   @ 148, 60 BUTTON oGet[18] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION;
      (IF( EMPTY(::oDb:CONCEPTO) .OR. EMPTY(::oDb:NOMBRE) ,;
         (MsgStop("No se puede grabar este CONCEPTO, debe completar datos"),;
          oGet[1]:SetFocus()), (aEd[3] := .t., oDlg:End()) )) PIXEL
   @ 148,110 BUTTON oGet[19] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
   IF lView                     // Solo Consulta
      DesactivaALLGET(oGet)
      oGet[18]:Disable()
      oGet[19]:Enable()
      oGet[19]:SetFocus()
   ENDIF
ACTIVATE DIALOG oDlg CENTER

If aEd[3]
   ::Guardar( lNuevo )
   aEd[1] := ::oDb:Recno()
Endif
::oDb:Go( aEd[1] ):Read()

RETURN NIL
