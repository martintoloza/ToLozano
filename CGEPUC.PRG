// Programa.: CGEPUC.PRG      >>> Martin A. Toloza Lozano <<<
// Notas....: Creacion y Manto. del Plan Unico de Cuentas
#include "Fivewin.ch"
#include "Objects.ch"

MEMVAR oApl

FUNCTION PlanCtas()
   LOCAL oCta := TPuc()
oCta:New()
Empresa( .t. )
oCta:Activate()
oCta:Cerrar()
RETURN NIL

//------------------------------------//
CLASS TPuc FROM TNits
 DATA aNivel AS ARRAY INIT { "Clase","Grupo","Cuenta","SubCuenta","Auxiliar" }

METHOD NEW( oBase ) Constructor
METHOD Guardar( oDlg,lSi )
METHOD Editar( xRec,lNuevo,lView,cCta )
METHOD Mostrar( lAyuda,nOrd )
METHOD Buscar( cCta )
METHOD Listado()

ENDCLASS

//------------------------------------//
METHOD NEW( oBase ) CLASS TPuc
   DEFAULT oBase := oApl:Abrir( "cgeplan","empresa, cuenta" )
Super:New( oBase )
::aOrden  := Buscar( "SELECT inf FROM cgeinfac ORDER BY inf","CM",,9 )
oApl:aInf := { SPACE(10) }
AEVAL( ::aOrden, {|cVal| AADD( oApl:aInf,cVal ) } )
::aOrden  := { {"<None> ",1},;
               {"Cuenta" ,3},;
               {"Nombre" ,5} }
::xVar := SPACE(10)
RETURN NIL

//------------------------------------//
METHOD Mostrar( lAyuda,nOrd ) CLASS TPuc
   LOCAL oDlg, oM := Self
   LOCAL cTit := "Ayuda del Plan de Cuentas", bHacer, lReturn := NIL
   DEFAULT lAyuda := .t. , nOrd := 3
If lAyuda
   bHacer  := {||lReturn :=.t., oDlg:End()}
   lReturn := .f.
ELSE
   bHacer  := ::bEditar
   cTit    := "Código de Cuentas"
ENDIF
//If !EMPTY( cFiltro )
   ::oDb:cWhere := " empresa = " + LTRIM(STR(oApl:nPuc))
//EndIf
nOrd := ::Ordenar( nOrd )

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE cTit
   @ 1.5, 0 LISTBOX ::oLbx FIELDS   ;
                    ::oDb:CUENTA    , ::oDb:NOMBRE,;
                    ::oDb:INFA      , ::oDb:INFB   ;
      HEADERS "Código"+CRLF+"Cuenta","Nombre","InfA", "InfB" ;
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
    ::oLbx:aColSizes   := {70,250,60,60}
    ::oLbx:aHjustify   := {2,2,2,2}
    ::oLbx:aJustify    := {0,0,0,0}
    ::oLbx:lCellStyle  := .f.
    ::oLbx:ladjlastcol := .t.
    ::oLbx:ladjbrowse  := .f.
    ::oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey=VK_RETURN, (EVAL(bHacer)),;
                               If(nKey == VK_F5 , (::Editar( -1,.t. ), ::oLbx:SetFocus(), ::oLbx:Refresh() ),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(::BNew),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=69, EVAL(::bEditar)		 ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=86, EVAL(::bVer) 		         ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) ))))) }
   MySetBrowse( ::oLbx, ::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT (oM:Barra(lAyuda,oDlg))
::oDb:Setorder( nOrd )

RETURN lReturn

//------------------------------------//
METHOD Editar( xRec,lNuevo,lView,cCta ) CLASS TPuc
   LOCAL oDlg, oGet := ARRAY(12), bGrabar
   LOCAL aEd := { .f.,"Nuevo Cuenta","" }
   DEFAULT lNuevo := .t. , lView  := .f. ,;
           cCta   := ::xVar
IF lNuevo
   If xRec == -1
      cCta := ACLONE( ::oDb:axBuffer )
      ::oDb:xBlank()
      AEVAL( cCta, { |x,p| ::oDb:axBuffer[p] := x },2 )
   Else
      ::oDb:xBlank()
      ::oDb:CUENTA := cCta
      ::oDb:ESTADO := "A"
   EndIf
   bGrabar := {|| ::Guardar( oDlg,.f. ), aEd[1] := .t.,;
                  oDlg:Update(), oDlg:SetFocus() }
ELSE
   aEd[2]  := If( lView, "Viendo", "Modificando" ) + " Cuenta"
   bGrabar := {|| ::oDb:Update(.t.,1), oDlg:End() }
ENDIF
aEd[3] := { "Activa","Retirada" }[AT(::oDb:ESTADO,"AR")]

DEFINE DIALOG oDlg TITLE aEd[2] FROM 0, 0 TO 15,60
   @ 02, 00 SAY "Nro. Cuenta" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 02, 54 GET oGet[1] VAR ::oDb:CUENTA OF oDlg PICTURE "9999999999";
      VALID ::Guardar( oDlg,.t. )                                    ;
      WHEN lNuevo  SIZE 40,12 PIXEL UPDATE
   @ 02,110 SAY "Nivel"       OF oDlg RIGHT PIXEL SIZE 50,10
   @ 02,164 SAY oGet[2] VAR ::aNivel[ ::oDb:NIVEL+1 ] OF oDlg PIXEL SIZE 30,12 UPDATE
   @ 16, 00 SAY "Nombre"      OF oDlg RIGHT PIXEL SIZE 50,10
   @ 16, 54 GET oGet[3] VAR ::oDb:NOMBRE OF oDlg PICTURE "@!";
      SIZE 130,12 PIXEL UPDATE
   @ 30, 00 SAY "InfA"        OF oDlg RIGHT PIXEL SIZE 50,10
   @ 30, 54 COMBOBOX oGet[4] VAR ::oDb:INFA ITEMS oApl:aInf SIZE 50,99 ;
      OF oDlg PIXEL UPDATE
   @ 30,110 SAY "InfB"        OF oDlg RIGHT PIXEL SIZE 50,10
   @ 30,164 COMBOBOX oGet[5] VAR ::oDb:INFB ITEMS oApl:aInf SIZE 50,99 ;
      OF oDlg PIXEL UPDATE
   @ 44, 00 SAY "InfC"        OF oDlg RIGHT PIXEL SIZE 50,10
   @ 44, 54 COMBOBOX oGet[6] VAR ::oDb:INFC ITEMS oApl:aInf SIZE 50,99 ;
      OF oDlg PIXEL UPDATE
   @ 44,110 SAY "InfD"        OF oDlg RIGHT PIXEL SIZE 50,10
   @ 44,164 COMBOBOX oGet[7] VAR ::oDb:INFD ITEMS oApl:aInf SIZE 50,99 ;
      OF oDlg PIXEL UPDATE
   @ 58, 54 TO 94, 104 LABEL "Modalidad" OF oDlg PIXEL
   @ 64, 56 RADIO oGet[08] VAR ::oDb:DB_CR PROMPT "&Credito", "&Debito" OF oDlg;
      SIZE 40,12 PIXEL UPDATE
   @ 58,164 CHECKBOX oGet[09] VAR ::oDb:PAGOS_TERC PROMPT "Pagos a Terceros" ;
      OF oDlg SIZE 60,12 PIXEL UPDATE
   @ 72,110 SAY "Estado"           OF oDlg RIGHT PIXEL SIZE 50,10
   @ 72,164 COMBOBOX oGet[10] VAR aEd[3] ITEMS { "Activa","Retirada" } ;
      SIZE 50,99 OF oDlg PIXEL UPDATE
/*
   @ 72,110 SAY "Libro"            OF oDlg RIGHT PIXEL SIZE 50,10
   @ 72,164 COMBOBOX oGet[11] VAR ::oDb:LIBRO ITEMS { "ColGaap","IFRS" } ;
      SIZE 50,99 OF oDlg PIXEL UPDATE
*/

   @ 90,120 BUTTON oGet[11] PROMPT "&Grabar"  SIZE 44,12 OF oDlg ACTION ;
      (If( EMPTY(::oDb:CUENTA) .OR. EMPTY(::oDb:NOMBRE)                ,;
       (MsgStop("No se puede grabar esta CUENTA, debe completar datos"),;
        oGet[3]:SetFocus() ), ( ::oDb:ESTADO := LEFT( aEd[3],1 )       ,;
           EVAL(bGrabar)) )) PIXEL
   @ 90,170 BUTTON oGet[12] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
   IF lView                     // Solo Consulta
      DesactivaALLGET(oGet)
      oGet[11]:Disable()
      oGet[12]:Enable()
      oGet[12]:SetFocus()
   ENDIF
ACTIVATE DIALOG oDlg CENTER
If aEd[1]
   ::oDb:Seek( {"empresa",oApl:nPuc,"cuenta",::xVar} )
EndIf
::oLbx:Refresh()
RETURN NIL

//------------------------------------//
METHOD Guardar( oDlg,lSi ) CLASS TPuc
   LOCAL aCta, nLen := LEN( ALLTRIM( ::oDb:CUENTA ))
If lSi
   If !STR( nLen,1 ) $ "12468"
      MsgStop("Esta Cuenta no Tiene los Digitos Correctos", ">>> Ojo <<<" )
      lSi := .f.
   ElseIf ::Buscar( ::oDb:CUENTA )
      MsgStop( "Este Cuenta ya existe .." )
      lSi := .f.
   EndIf
Else
   If EMPTY(::oDb:INFA) .AND. EMPTY(::oDb:INFB) .AND. ;
      EMPTY(::oDb:INFC) .AND. EMPTY(::oDb:INFD) .AND. ::oDb:NIVEL == 4
      MsgStop( "Esta Cuenta necesita minimo un Requerimiento",">>> Ojo <<<" )
      ::oDb:INFA := "COD-VAR   "
   Else
      aCta := { ::oDb:CUENTA,::oDb:NOMBRE }
      nLen -= 2
      ::xVar := aCta[1]
      ::oDb:EMPRESA := oApl:nPuc
      ::oDb:Insert( .f. )
      ::oDb:xBlanK()
      ::oDb:ESTADO := "A"
      While nLen > 0 .AND. SUBSTR( aCta[1],01 ) # "0"
         aCta[1] := STUFF( aCta[1],nLen+1,10-nLen,SPACE(10-nLen) )
         If !::Buscar( aCta[1] )
            MsgStop("Error, No existe Cuenta "+aCta[1], ">>Debe Grabarla<<" )
            ::oDb:CUENTA := aCta[1] ; ::oDb:NOMBRE := aCta[2]
            Exit
         EndIf
         nLen -= If( nLen == 2, 1, 2 )
      EndDo
      lSi := !EMPTY(aCta[1])
   EndIf
EndIf
If lSi
   ::oDb:NIVEL := If( nLen <= 1, 0, nLen/2 )
   ::oDb:DB_CR := If( LEFT( ::oDb:CUENTA,1 ) $ "234", 2, 1 )
   oDlg:Update()
EndIf
RETURN lSi

//------------------------------------//
METHOD Buscar( cCta ) CLASS TPuc
   LOCAL cQry, hRes
cQry := "SELECT cuenta FROM cgeplan WHERE empresa = " +;
        LTRIM( STR(oApl:nPuc) ) + " AND cuenta = '" + TRIM( cCta ) + "'"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
RETURN ( MSNumRows( hRes ) != 0 )

//------------------------------------//
METHOD Listado() CLASS TPuc
   LOCAL aLI, cQry, hRes, nC, nL, oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"PLAN UNICO DE CUENTAS",;
         NtChr( DATE(),"3" ),"CUENTA      NOMBRE DE LA CUENTA" + SPACE(32) + ;
         "PT CC INFA        INFB        INFC        INFD"},,,2 )
oRpt:lPreview := MsgNoYes( "Vista Previa", ">>> Desea Ver <<<" )
cQry := "SELECT cuenta, nombre, pagos_terc, infa, infb, infc, infd, nivel "+;
        "FROM cgeplan WHERE empresa = " + LTRIM( STR(oApl:nPuc) ) +;
        " AND estado = 'A' ORDER BY cuenta"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aLI := MyReadRow( hRes )
   AEval( aLI, { | xV,nP | aLI[nP] := MyClReadCol( hRes,nP ) } )
   nC  := 12 + aLI[8] * 2
   oRpt:Titulo( 112 )
   oRpt:Say( oRpt:nL,00,aLI[1] )
   oRpt:Say( oRpt:nL,nC,aLI[2] )
   oRpt:Say( oRpt:nL,63,If( aLI[3], "Si", "No" ) )
   //oRpt:Say( oRpt:nL,66,If( Cta->CENTROCOST, "Si", "No" ) )
   oRpt:Say( oRpt:nL,69,aLI[4] + " " + aLI[5] + " " +;
                          aLI[6] + " " + aLI[7] )
   oRpt:nL ++
   nL --
EndDo
MSFreeResult( hRes )
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
FUNCTION InfAc( oPuc,nP,cVar )
   LOCAL aInf, lAcu, lSi := .f.
   DEFAULT cVar := ""
If VALTYPE( oPuc ) == "C"
   aInf := Buscar( {"empresa",oApl:nPuc,"cuenta",oPuc},;
                    "cgeplan","infa, infb, infc, infd",8 )
   If LEN( aInf ) == 0
      aInf := { "","","","" }
   EndIf
Else
   aInf := { TRIM(oPuc:INFA),TRIM(oPuc:INFB),TRIM(oPuc:INFC),TRIM(oPuc:INFD) }
EndIf
FOR nP := 1 TO 4
   If EMPTY( cVar )
      lAcu := Buscar( "SELECT 'X' FROM cgeinfac WHERE inf = '" +;
                      aInf[nP] + "' AND acumula = '1'","CM",,8 )
      If !EMPTY( lAcu )
         lSi := .t.
         Exit
      EndIf
   ElseIf aInf[nP] == cVar
      lSi := .t.
      Exit
   Endif
NEXT
RETURN lSi