// Programa.: CAONITS.PRG     >>> Martin A. Toloza Lozano <<<
// Notas....: Modulo para la manipulacion de Nits
#include "Fivewin.ch"
#include "Objects.ch"

MEMVAR oApl

FUNCTION Nits()
   LOCAL oNits := TNits()
 oNits:New( ,,3 )
 oNits:Activate()
RETURN NIL

//------------------------------------//
CLASS TNits

 DATA cBus          INIT ""
 DATA cWhere        INIT ""
 DATA lBuscar       INIT .f.
 DATA nOrden        INIT 2
 DATA xVar          INIT 0
 DATA oFont         INIT Tfont():New("Ms Sans Serif",0,-10,,.f.)
 DATA aOrden, aEst, aSec, oDb, oCiu, oIndex, oLbx
 DATA bNew, bEditar, bVer
 DATA bBorrar, bBuscar, bPrint, lBorrar

 METHOD NEW( oTabla,lDel,cSec ) Constructor
 METHOD ACTIVATE() INLINE ::Mostrar( .f.,2 )
 METHOD Mostrar( lAyuda,nOrd,nCod )
 METHOD Ordenar( nOrd )
 METHOD Editar( xRec,lNuevo,lView,nNit )
 METHOD Contacto( oLbx,lNew )
 METHOD Muestra()
 METHOD Sector( oBrw,nIt )
 METHOD Guardar( lNew )
 METHOD Barra( lHelp,oDlg )
 METHOD Borrar( xRec )
 METHOD Buscar( uBus,cTabla,cCampo,cLista,lTB )
 METHOD Buscando( cWhere )
 METHOD BuscaInc( nKey,cWhere )
 METHOD ChangeOrder()
 METHOD Cerrar() INLINE ::oDb:Destroy()
 METHOD Listado()

ENDCLASS

//------------------------------------//
METHOD NEW( oTabla,lDel,cSec ) CLASS TNits
   LOCAL nL, hRes
   DEFAULT oTabla := oApl:oNit, lDel := .t.
::aOrden  := { {"<None> "  ,1},{"Código"   ,2},;
               {"Nombre"   ,5},{"CódigoNit",12} }
::oDb     := oTabla
::bNew    := {||::Editar( ::oDb:Recno(),.t. ),    ;
                ::oLbx:SetFocus(),::oLbx:Refresh()  }
::bEditar := {||::Editar( ::oDb:Recno(),.f. ),    ;
                ::oLbx:SetFocus(),::oLbx:Refresh()  }
::bVer    := {||::Editar( ::oDb:Recno(),.f.,.t. ),;
                ::oLbx:SetFocus(),::oLbx:Refresh()  }
::bBorrar := {||::Borrar( ::oDb:Recno() ),        ;
                ::oLbx:SetFocus(),::oLbx:Refresh()  }
::bBuscar := {|| ::cBus := If( EMPTY( ::cBus ), ::Buscando(), "" ),;
                 ::oLbx:SetFocus(),::oLbx:Refresh() }
::bPrint  := {|| ::Listado() }
::lBorrar := lDel
If cSec # NIL
   ::aEst := Buscar( "SELECT nombre, sector FROM cadestra "+;
                     "ORDER BY nombre","CM",,9 )
   ::aSec := {}
   cSec := "SELECT nombre, sector FROM sectores ORDER BY "+;
           { "sector","nombre"}[cSec-1]
   hRes := If( MSQuery( oApl:oMySql:hConnect,cSec ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   While nL > 0
      cSec := MyReadRow( hRes )
      AEVAL( cSec, { |xV,nP| cSec[nP] := MyClReadCol( hRes,nP ) } )
      AADD( ::aSec,{ cSec[1],cSec[2] } )
      nL --
   EndDo
   MSFreeResult( hRes )
EndIf
//If ::oDb:cName == "cadclien"
//   ::oCiu := TRip()
//   ::oCiu:New( 1,.f. )
//EndIf
RETURN NIL

//------------------------------------//
METHOD Mostrar( lAyuda,nOrd,nCod ) CLASS TNits
   LOCAL oDlg, oM := Self
   LOCAL cTit := "Ayuda de Nits", bHacer, lReturn := NIL
   DEFAULT lAyuda := .t. , nOrd := 3, nCod := 0
If lAyuda
   bHacer  := {||lReturn := ::lBuscar := .t., oDlg:End()}
   lReturn := .f.
ELSE
   bHacer  := ::bEditar
   cTit    := "Clientes o Proveedores"
ENDIF
::xVar := nCod
nOrd   := ::Ordenar( 3 )

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE cTit
   @ 1.5, 0 LISTBOX ::oLbx FIELDS  ;
         TRANSFORM( ::oDb:CODIGO,"999,999,999,999"),;
         OEMTOANSI( ::oDb:NOMBRE ),;
                   ::oDb:TELEFONO  ;
      HEADERS "Nit ó"+CRLF+"Cédula","Nombre","Telefono" ;
      SIZES 400, 450 SIZE 200,107  ;
      OF oDlg UPDATE               ;
      ON DBLCLICK EVAL(bHacer)
    ::oLbx:nClrBackHead  := oApl:nClrBackHead
    ::oLbx:nClrForeHead  := oApl:nClrForeHead
    ::oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    ::oLbx:nClrBackFocus := oApl:nClrBackFocus
    ::oLbx:nClrForeFocus := oApl:nClrForeFocus
    ::oLbx:GoTop()
    ::oLbx:oFont      := ::oFont
    ::oLbx:nHeaderHeight := 28
    ::oLbx:aColSizes  := {80,240,110}
    ::oLbx:aHjustify  := {2,2,2}
    ::oLbx:aJustify   := {1,0,1}
    ::oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey=VK_RETURN, (EVAL(bHacer)),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, Eval(::BNew),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=69, EVAL(::bEditar)		 ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=86, EVAL(::bVer) 		         ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, EVAL(::bBorrar)	         ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) ))))) }
    ::oLbx:ladjbrowse  := ::oLbx:lCellStyle :=.f.
    ::oLbx:ladjlastcol := .t.
   MySetBrowse( ::oLbx, ::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT (oM:Barra(lAyuda,oDlg))
// VALID ( oDlg := nil, .T. )
::oDb:Setorder(nOrd)

RETURN lReturn

//------------------------------------//
METHOD Ordenar( nOrd ) CLASS TNits

::cBus   := ""
::nOrden := nOrd
nOrd     := ::oDb:Setorder( ::aOrden[ ::nOrden,2 ] )
If ::oDb:RecCount() > 0
   ::oDb:GoTop():Read()  // Hacer siempre un Read() para cargar el buffer interno
   ::oDb:xLoad()
Else
   ::oDb:xBlank():Read()
EndIf

RETURN nOrd

//------------------------------------//
METHOD Editar(xRec,lNuevo,lView,nNit) CLASS TNits
   LOCAL oDlg, oLbx, oGet := ARRAY(13), nEst, nSec
   LOCAL aEd := { ::oDb:Recno(),"Nuevo Nit ",.f.,0 }
   DEFAULT lNuevo := .t. , lView  := .f. ,;
           xRec   :=  0  , nNit := ::xVar
IF lNuevo
   ::oDb:xBlank()
   ::oDb:Read()
   ::oDb:CODIGO := nNit
   ::oDb:SECTOR := ::oDb:SECTORE := 1
ELSE
   lView  := If( ::oDb:CODIGO == 0, .t., lView )
   aEd[2] := IF( lView, "Viendo Nit", "Modificando Nit" )
ENDIF
oApl:oCon:Seek( {"nit",::oDb:CODIGO_NIT},"nombre" )
nNit := ::oDb:CODIGO
nEst := ArrayValor( ::aEst,::oDb:SECTORE,,.t. )
nSec := ArrayValor( ::aSec,::oDb:SECTOR ,,.t. )
aEd[4] := {|| DigitoVerifica( ::oDb ), oDlg:Update()            ,;
              xRec := ::Buscar( ::oDb:CODIGO )                  ,;
              If( (xRec .AND.  lNuevo) .OR.                      ;
                  (xRec .AND. !lNuevo .AND. ::oDb:CODIGO # nNit),;
                ( MsgNoYes("Nit ó Cédula ya existe") ), .t. ) }
DEFINE DIALOG oDlg RESOURCE "NITS" TITLE aEd[2]
   REDEFINE GET oGet[1] VAR ::oDb:CODIGO     ID 01 OF oDlg ;
      PICTURE "999,999,999,999" ;
      VALID EVAL(aEd[4])
   REDEFINE GET oGet[2] VAR ::oDb:DIGITO     ID 03 OF oDlg PICTURE "9" UPDATE
   REDEFINE SAY         VAR ::oDb:CODIGO_NIT ID 05 OF oDlg
   REDEFINE RADIO oGet[3] VAR ::oDb:TIPOCOD  ID 07,08,09 OF oDlg;
      WHEN !lView
   REDEFINE GET oGet[04] VAR ::oDb:NOMBRE    ID 11 OF oDlg PICTURE "@!"
   REDEFINE GET oGet[05] VAR ::oDb:DIRECCION ID 13 OF oDlg PICTURE "@!"
   REDEFINE GET oGet[06] VAR ::oDb:TELEFONO  ID 15 OF oDlg
   REDEFINE GET oGet[07] VAR ::oDb:FAX       ID 17 OF oDlg
   REDEFINE GET oGet[08] VAR ::oDb:EMAIL     ID 19 OF oDlg
   REDEFINE GET oGet[09] VAR ::oDb:CIUDAD    ID 21 OF oDlg PICTURE "@!"
   REDEFINE COMBOBOX oGet[10] VAR nSec ITEMS ArrayCol( ::aSec,1 );
      ID 23 OF oDlg UPDATE;
      VALID EVAL( {|| ::oDb:SECTOR := ::aSec[nSec,2], .t. })
    oGet[10]:bRClicked := {|| ::Muestra() }
   REDEFINE COMBOBOX oGet[11] VAR nEst ITEMS ArrayCol( ::aEst,1 );
      ID 25 OF oDlg UPDATE;
      VALID EVAL( {|| ::oDb:SECTORE := ::aEst[nEst,2], .t. })

   REDEFINE LISTBOX oLbx FIELDS ;
      oApl:oCon:NOMBRE, oApl:oCon:TELCASA ;
      ID 26 OF oDlg ;
      HEADERS "Nombre", "Telefono Casa" UPDATE
   oLbx:nClrBackHead  := oApl:nClrBackHead
   oLbx:nClrForeHead  := oApl:nClrForeHead
   oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
   oLbx:nClrBackFocus := oApl:nClrBackFocus
   oLbx:nClrForeFocus := oApl:nClrForeFocus
   oLbx:nHeaderHeight := 28
   oLbx:GoTop()
   oLbx:oFont       := Tfont():New("Ms Sans Serif",0,-10,,.f.)
   oLbx:aColSizes   := {174,100}
   oLbx:aHjustify   := {2,2}
   oLbx:aJustify    := {0,0}
   oLbx:ladjlastcol := oLbx:lCellStyle  := .f.
   oLbx:ladjbrowse  := .t.
   oLbx:bKeyDown := {|nKey| If(nKey == VK_ESCAPE, ( oGet[3]:SetFocus() ),;
                            If(nKey=VK_F9 , (oApl:oCon:DETALLES :=               ;
                                       Notas(oApl:oCon:DETALLES,"OBSERVACIONES"),;
                                             oApl:oCon:Update(.t.,1) )          ,;
                            If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, ::Contacto( oLbx,.t. ),;
                            If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, ::Contacto( oLbx,.f. ),;
                            If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, DelRecord( oApl:oCon,oLbx ),) )))) }
//                            If(nKey=VK_F9 , Notas( oApl:oCon:DETALLES,"OBSERVACIONES" ),;
   MySetBrowse( oLbx,oApl:oCon )

   REDEFINE BUTTON oGet[12] ID 27 OF oDlg ACTION ;
      (If( EMPTY(::oDb:CODIGO) .OR. EMPTY(::oDb:NOMBRE),;
         (MsgStop("No se puede grabar este Registro, debe completar datos"),;
          oGet[1]:SetFocus()), (aEd[3] := .t., oDlg:End()) ))
   REDEFINE BUTTON oGet[13] ID 28 OF oDlg CANCEL;
      ACTION oDlg:End()
   ACTIVAGET(oGet)
   IF lView                     // Solo Consulta
      DesactivaALLGET(oGet)
      oGet[12]:Disable()
      oGet[13]:Enable()
      oGet[13]:SetFocus()
   ENDIF
ACTIVATE DIALOG oDlg CENTER

If aEd[3]
   If lNuevo
      ::oDb:CODIGO_NIT := Buscar( "SELECT MAX(codigo_nit) FROM cadclien","CM" ) + 1
   EndIf
   ::Guardar( lNuevo )
   aEd[1] := ::oDb:Recno()
EndIf
::oDb:Go( aEd[1] ):Read()

RETURN NIL

//------------------------------------//
METHOD Contacto( oLbx,lNew ) CLASS TNits
   LOCAL oDlg, oCet := ARRAY(9), aCT := { "Modificando Contacto",.f. }
If lNew
   aCT[1] := "Nuevo Contacto"
   oApl:oCon:xBlank()
EndIf
aCT[1] += " en " + TRIM(::oDb:NOMBRE)

DEFINE DIALOG oDlg RESOURCE "CONTACTOS" TITLE aCT[1]
   REDEFINE GET oCet[1] VAR oApl:oCon:NOMBRE   ID  1 OF oDlg PICTURE "@!"
   REDEFINE GET oCet[2] VAR oApl:oCon:TELCASA  ID  3 OF oDlg PICTURE "@!"
   REDEFINE GET oCet[3] VAR oApl:oCon:TELOFIC  ID  5 OF oDlg PICTURE "@!"
   REDEFINE GET oCet[4] VAR oApl:oCon:DIRCASA  ID  7 OF oDlg PICTURE "@!"
   REDEFINE GET oCet[5] VAR oApl:oCon:DIROFIC  ID  9 OF oDlg PICTURE "@!"
   REDEFINE GET oCet[6] VAR oApl:oCon:EMAIL    ID 11 OF oDlg
   REDEFINE GET oCet[7] VAR oApl:oCon:DETALLES ID 13 OF oDlg
//   REDEFINE BUTTON oGet[7] ID 13 OF oDlg ACTION ;
//      (oApl:oCon:DETALLES := Notas( oApl:oCon:DETALLES,"NOTAS DE CLIENTES" ))
   REDEFINE BUTTON oCet[8] ID 14 OF oDlg ACTION ;
      (If( EMPTY(oApl:oCon:NOMBRE),;
         ( MsgStop("Imposible grabar este Contacto"), oCet[1]:SetFocus()),;
         ( aCT[2] := .t., oDlg:End() )))
   REDEFINE BUTTON oCet[9] ID 15 OF oDlg CANCEL ACTION oDlg:End()
   ACTIVAGET(oCet)
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
If aCT[2]
   If lNew
      oApl:oCon:NIT := ::oDb:CODIGO_NIT
      oApl:oCon:Append(.t.)
   Else
      oApl:oCon:Update(.t.,1)
   EndIf
   oLbx:Refresh()
EndIf
   oLbx:SetFocus()
RETURN NIL

//------------------------------------//
METHOD Muestra() CLASS TNits
   LOCAL oDlg, oBrw, nIt := 1
DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE "Código de Sectores"
   @ 1.5, 0 LISTBOX oBrw FIELDS ;
             ::aSec[nIt][1]    ,;
         STR(::aSec[nIt][2],6,0);
      HEADERS "Nombre","Código"+CRLF+"Sector";
      FIELDSIZES 200,80 ;
      OF oDlg UPDATE    ;
      SIZE 200,107      ;
      ON DBLCLICK ::Sector( oBrw,nIt )
   oBrw:bGotop    := { || nIt := 1 }
   oBrw:bGoBottom := { || nIt := EVAL( oBrw:bLogicLen ) }
   oBrw:bSkip     := { | nWant,nOld | nOld := nIt , nIt += nWant,;
              nIt := MAX( 1, MIN( nIt, EVAL( oBrw:bLogicLen ))),;
              nIt - nOld }
   oBrw:bLogicLen := { || LEN( ::aSec ) }
   oBrw:cAlias    := "Array"
   oBrw:bKeyDown  := {|nKey| If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, ::Sector( oBrw,0 ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, ::Sector( oBrw,nIt ), )) }
ACTIVATE DIALOG oDlg CENTERED
RETURN NIL

//------------------------------------//
METHOD Sector( oBrw,nIt ) CLASS TNits
   LOCAL oDlg, oGet := ARRAY(4)
   LOCAL aEd := { 0,SPACE(30),"Nuevo Sector",.f. }
If nIt > 0
   aEd := { ::aSec[nIt][2],::aSec[nIt][1],"Modificando Sector",.f. }
EndIf

DEFINE DIALOG oDlg TITLE aEd[3] FROM 0, 0 TO 08,50
   @ 02,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 50,10
   @ 02,52 GET oGet[1] VAR aEd[1] OF oDlg PICTURE "999"        ;
      VALID If( ::Buscar( aEd[1],"sectores","sector","*",.f. ),;
              ( MsgStop( "Ya Existe","SECTOR" ), .f. ), .t. )  ;
      WHEN nIt == 0 SIZE 40,10 PIXEL
   @ 16,00 SAY "Nombre"   OF oDlg RIGHT PIXEL SIZE 50,10
   @ 16,52 GET oGet[2] VAR aEd[2] OF oDlg PICTURE "@!";
      VALID !EMPTY(aEd[2])  SIZE 120,10 PIXEL UPDATE
   @ 32, 60 BUTTON oGet[3] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION;
      (IF( EMPTY(aEd[1]) .OR. EMPTY(aEd[2]),;
         (MsgStop("No se puede grabar este Sector, debe completar datos"),;
          oGet[1]:SetFocus()), (aEd[4] := .t., oDlg:End()) )) PIXEL
   @ 32,110 BUTTON oGet[4] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTER
If aEd[4]
   If nIt == 0
      aEd[3] := "INSERT INTO sectores VALUES( null, "+;
                LTRIM(STR(aEd[1])) + ", '" +;
                  ALLTRIM(aEd[2])  + "' )"
      AADD( ::aSec, { aEd[2],aEd[1] } )
   Else
      aEd[3] := "UPDATE sectores SET nombre = '"+;
                ALLTRIM(aEd[2]) + "' WHERE sector = " +;
                  LTRIM(STR(aEd[1]))
      ::aSec[nIt,1] := aEd[2]
   EndIf
   MSQuery( oApl:oMySql:hConnect,aEd[3] )
   ASORT( ::aSec,,, { |x,y| x[1] < y[1] } )
   oBrw:Refresh()
EndIf
RETURN NIL

//------------------------------------//
METHOD Guardar( lNew ) CLASS TNits

   If lNew
      ::oDb:Append(.t.)
   Else
      ::oDb:Update(.t.,1)
   EndIf

RETURN NIL

//------------------------------------//
METHOD Borrar(xRec) CLASS TNits
   LOCAL nRecNo := ::oDb:RecNo()
If ::lBorrar
   If MsgNoYes( "Esta seguro que desea"+ CRLF + "eliminar este registro "+;
                STR(::oDb:row_id)+"?", "MySQL" )
      ::oDb:GoTo(xRec)
      ::oDb:Read()
      If ::oDb:Delete(.t.,1)
         MsgInfo("Borrado exitoso!!!","Borrado en el servidor")
         ::oDb:Refresh()
         ::oDb:GoTo(nRecNo)
         If ::oDb:lEof
            ::oDb:Read()
         Else
            ::oDb:Read()
            ::oDb:xLoad()
         EndIf
         ::oLbx:Refresh()
      EndIf
   EndIf
Else
   MsgStop( "Esta Prohibido Borrar","IMPOSIBLE" )
EndIf
RETURN NIL

//------------------------------------//
METHOD Buscar( uBus,cCampo,lTB ) CLASS TNits
   LOCAL cQry, hRes, lSi := .t., nRow := 0
   DEFAULT cCampo := "codigo", lTB := .f.
If !::lBuscar
   If !lTB
      cQry := "SELECT " + (cCampo) + " FROM " + ::oDb:cName +;
              " WHERE " + (cCampo) + " = " + xValToChar( uBus )
      hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      nRow := MSNumRows( hRes )
      MSFreeResult( hRes )
   Else
      ::oDb:Seek( {cCampo,uBus} )
      nRow := ::oDb:RecCount()
   EndIf
   lSi := ( nRow != 0 )
   If nRow > 1
      MsgStop( cCampo+" Está en (" + STR(nRow) + " ) Registros","Buscar por AYUDA" )
      lSi := .f.
   EndIf
EndIf
::lBuscar := .f.
RETURN lSi

//------------------------------------//
METHOD Buscando( cWhere ) CLASS TNits
   LOCAL cBus := "%" + SPACE(24), nOldRec := ::oDb:Recno()
   LOCAL nTab := ::aOrden[ ::nOrden,2 ]
   DEFAULT cWhere := ""
If MsgGet( ::aOrden[ ::nOrden,1 ],"Buscar",@cBus )
   cBus := UPPER( ALLTRIM( cBus ) )
   cBus += If( RIGHT( cBus ) == "%", "", "%" )
   If ::oDb:Find( nTab, cBus, cWhere ) == 0
      MessageBeep()
      Msginfo( "Termino la busqueda"+ CRLF +"Examine o corrija","Advertencia!!!" )
      ::oDb:Go(nOldRec):Read()
   Else
      ::cBus := cBus
      ::oDb:GoTop():Read()
   EndIf
EndIf

RETURN ::cBus

//------------------------------------//
METHOD BuscaInc( nKey,cWhere ) CLASS TNits
   LOCAL bSeek, nOldRec := ::oDb:Recno()
   LOCAL nTab := ::aOrden[ ::nOrden,2 ]
   DEFAULT cWhere := ""
bSeek := {|| If( ::oDb:Find( nTab, ALLTRIM(::cBus), cWhere ) = 0          ,;
               ( MessageBeep()                                            ,;
                 Msginfo( "Termino la busqueda"+ CRLF +"Examine o corrija",;
                          "Advertencia!!!" )                              ,;
                 ::cBus := LEFT( ::cBus,LEN( ALLTRIM( ::cBus ) )-2 ) + "%",;
                 ::oDb:Find( nTab, ALLTRIM(::cBus), cWhere ) ), )         ,;
                 ::oDb:GoTop():Read()                                     ,;
                 ::oLbx:GoTop(), ::oLbx:Refresh() }
If nKey # VK_RETURN
   ::cBus := STRTRAN(::cBus,"%","")
   do Case
      Case nKey == VK_BACK
         ::cBus := LEFT( ::cBus,LEN( ALLTRIM( ::cBus ) )-1 ) + "%"
      Case nKey == VK_ESCAPE
         ::cBus := "%"
      Case nKey >= 32
         ::cBus += Upper( Chr( nKey ) )+"%"
   EndCase
   Eval(bSeek)
EndIf

RETURN ::cBus

//------------------------------------//
METHOD Listado() CLASS TNits
   LOCAL oDPrn, nConta := 0, nReg := ::oDb:Recno(), cPict
oDPrn := TDosPrint()
oDPrn:New( oApl:cPuerto,oApl:cImpres,{"LISTADO DE NITS","",;
         "N O M B R E-------------------- DOC No. DOCUMENTO  CODIGO  "+;
         "TELEFONOS-------  F A X     D I R E C C I O N"},,,2 )
oDPrn:lPreview := MsgNoYes( "Vista Previa", ">>> Desea Ver <<<" )
::oDb:GoTop():Read()
::oDb:xLoad()
While !::oDb:Eof()
   If ::oDb:TIPOCOD # 2
/*    ::oDb:Go( Nits->(RECNO()) ) ; ::oDb:Read()
      If LenNum(Nits->CODIGO) == 10
         cPict := LEFT( STR(Nits->CODIGO),11 )
         ::oDb:CODIGO := VAL( cPict )
      EndIf
      DigitoVerifica( ::oDb ); ::oDb:Replace() */
      oDPrn:Titulo( 130 )
      oDPrn:Say( oDPrn:nL,00,::oDb:NOMBRE,31 )
      oDPrn:Say( oDPrn:nL,32,If( ::oDb:TIPOCOD = 0, " CC", "NIT" ))
      oDPrn:Say( oDPrn:nL,36,FormatoNit( ::oDb:CODIGO,::oDb:DIGITO ) )
      oDPrn:Say( oDPrn:nL,51,TransForm( ::oDb:CODIGO_NIT,"99,999" ))
      oDPrn:Say( oDPrn:nL,59,::oDb:TELEFONO )
      oDPrn:Say( oDPrn:nL,77,::oDb:FAX )
      oDPrn:Say( oDPrn:nL,87,::oDb:DIRECCION )
      oDPrn:nL ++
      nConta   ++
   EndIf
   ::oDb:Skip(1):Read()
   ::oDb:xLoad()
EndDo
If nConta > 0
   oDPrn:Say( oDPrn:nL++,00,Replicate ("_",130) )
   oDPrn:Say( oDPrn:nL  ,10,"TOTAL NITS ESTE LISTADO...." + STR( nConta,4 ) )
EndIf
oDPrn:NewPage()
oDPrn:End()
::oDb:Go(nReg):Read()
::oLbx:GoTop()
::oLbx:Refresh()
RETURN NIL

//------------------------------------//
METHOD Barra(lHelp,oDlg) CLASS TNits
   LOCAL oBar, oBot := ARRAY(7)
DEFINE BUTTONBAR oBar OF oDlg 3DLOOK SIZE 28,28

DEFINE BUTTON oBot[1] RESOURCE "NUEVO"    OF oBar NOBORDER ;
   TOOLTIP "Nuevo Registro (Ctrl+N)" ;
   ACTION Eval(::bNew)
DEFINE BUTTON oBot[2] RESOURCE "EDIT"     OF oBar NOBORDER ;
   TOOLTIP "Editar Registro (Ctrl+E)";
   ACTION Eval(::bEditar)
DEFINE BUTTON oBot[3] RESOURCE "VER"      OF oBar NOBORDER ;
   TOOLTIP "Ver datos (Ctrl+V)" ;
   ACTION Eval(::bVer)
DEFINE BUTTON oBot[4] RESOURCE "ELIMINAR" OF oBar NOBORDER ;
   TOOLTIP "Eliminar (Ctrl+DEL)" ;
   ACTION Eval(::bBorrar)
DEFINE BUTTON oBot[5] RESOURCE "BUSCAR"   OF oBar NOBORDER ;
   TOOLTIP "Localizar (Ctrl+L)"  ;
   ACTION Eval(::bBuscar) GROUP
DEFINE BUTTON oBot[6] RESOURCE "PRINT"    OF oBar NOBORDER ;
   TOOLTIP "Imprimir" ;
   ACTION Eval(::bPrint)
DEFINE BUTTON oBot[7] RESOURCE "QUIT"     OF oBar NOBORDER ;
   TOOLTIP "Salir"    ;
   ACTION (oDlg:End())    GROUP
// Crear combobox para indices
   @ .45,36 COMBOBOX ::oIndex VAR ::nOrden;
          ITEMS ArrayCol( ::aOrden,1 )    ;
          SIZE 95, 120 FONT ::oFont ;
          COLOR CLR_BLACK, NIL  OF oBar
   ::oIndex:cTooltip := "Selecione el orden"
   ::oIndex:bChange  := {|| ::cBus := If( !EMPTY(::cBus) .AND. ::nOrden # 1    ;
                                  .AND. VALTYPE( ::aOrden[::nOrden,2] ) == "N",;
                             xValBuscar( ::oDb:FldLoad(::aOrden[::nOrden,2]) ),;
                             "%" ), oDlg:Update(), ::ChangeOrder()   ,;
                            ::oDb:Find( ::aOrden[::nOrden,2],::cBus ),;
                            ::oDb:GoTop():Read()                     ,;
                            ::oLbx:GoTop(), ::oLbx:Refresh() }
   ::oIndex:Set3DLook()
IF lHelp
   oBot[4]:Disable()
   oBot[6]:Disable()
ENDIF
 oBar:bRClicked := {|| NIL }
 oBar:bLClicked := {|| NIL }
RETURN oBar

//------------------------------------//
METHOD ChangeOrder() CLASS TNits
   LOCAL nOrder := ::aOrden[ ::nOrden,2 ]
CursorWait()

::oDb:SetOrder( nOrder )
::oDb:GoTop():Read()

::oIndex:Refresh()
::oLbx:GoTop()
::oLbx:Refresh()
::oLbx:SetFocus()

CursorArrow()

RETURN .T.

//------------------------------------//
FUNCTION DigitoVerifica( oDb )
   LOCAL aP, cNum, nR, nNit, nSuma := 0
If LenNum( oDb:CODIGO ) > 4
   aP := { 71,67,59,53,47,43,41,37,29,23,19,17,13,7,3 }
   cNum := STRZERO( oDb:CODIGO,15 )
   FOR nR := 15 TO 1 STEP -1
      nNit  := VAL(SUBSTR( cNum,nR,1 ))
      nSuma += (nNit * aP[nR])
   NEXT
   nR := nSuma % 11            // Resto
// nR := INT(nSuma / 11)       // Resto
// nR := nSuma - (11*nR)       // Residuo
   If nR > 1
      nR := 11 - nR
   EndIf
   oDb:DIGITO := nR
EndIf
RETURN NIL

//------------------------------------//
FUNCTION FormatoNit( nNit,nDV )
   LOCAL cDV := If( LenNum(nNit) > 4, "-"+STR(nDV,1), "" )
RETURN TransForm( nNit,"9999,999,999" ) + cDV

//------------------------------------//
FUNCTION xValBuscar( uVal )
   LOCAL cType := VALTYPE( uVal ), cValor := ""
do Case
Case cType == "C"
   cValor := ALLTRIM( uVal )
case cType == "D"
   cValor := MyDToMs( DToS( uVal ) )
case cType == "L"
   cValor := MyLToMs( uVal )
Case cType == "N"
   cValor := LTRIM( STR( uVal ) )
EndCase
RETURN cValor + "%"