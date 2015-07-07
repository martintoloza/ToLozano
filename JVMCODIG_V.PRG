// Programa.: CAOCODIG.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Creacion y Manto. de Codigos
#include "Objects.ch"
#include "Fivewin.ch"
#include "btnget.ch"

MEMVAR oApl

FUNCTION Articulos( lConsu )
   LOCAL aEst, oInv, oDlg, oLbs, oMes, oGet := ARRAY(2)
   DEFAULT lConsu := .f.
oInv := TInv()
oInv:New(,.f.)
If !lConsu
   oInv:Mostrar( .f.,3 )
   oInv:Cerrar()
   RETURN NIL
EndIf
aEst := { "","","999,999.99999","999,999,999.99","","" }
oMes := oApl:Abrir( "cadinvme","empresa, codigo, anomes",,,30 )
oMes:Seek( { "empresa",oApl:nEmpresa,"codigo",oInv:xVar,"anomes >= ","199401" },"anomes DESC" )
oApl:oInv:xBlank()

DEFINE DIALOG oDlg RESOURCE "CODIGOS"
   REDEFINE BTNGET oGet[1] VAR oInv:xVar ID  1 OF oDlg PICTURE "@!"          ;
      RESOURCE "BUSCAR"     ;
      ACTION EVAL({|| If( oInv:Mostrar(), ( oInv:xVar := oInv:oDb:CODIGO    ,;
                          oGet[1]:Refresh(), oGet[1]:lValid(.f.) ), ) })     ;
      VALID( If( BuscaCod( oInv,oMes,@aEst ), (oLbs:Refresh(), oDlg:Update(),;
                 oLbs:GoTop(), oGet[1]:oJump := oLbs, .t. ), .f. ))
   REDEFINE SAY VAR oApl:oInv:DESCRIP    ID  2 OF oDlg UPDATE
   REDEFINE SAY VAR oApl:oInv:LINEA      ID  4 OF oDlg UPDATE
   REDEFINE SAY VAR aEst[2]              ID  5 OF oDlg UPDATE
   REDEFINE SAY VAR oApl:oInv:PCOSTO     ID  7 OF oDlg PICTURE aEst[4] UPDATE
   REDEFINE SAY VAR oApl:oInv:PVENTA     ID  9 OF oDlg PICTURE aEst[4] UPDATE
   REDEFINE SAY VAR oApl:oInv:PPUBLI     ID 11 OF oDlg PICTURE aEst[4] UPDATE
   REDEFINE SAY VAR oApl:oInv:AJUSTE_ESP ID 13 OF oDlg UPDATE
   REDEFINE SAY VAR aEst[5]              ID 15 OF oDlg UPDATE
   REDEFINE SAY VAR aEst[6]              ID 17 OF oDlg UPDATE

   REDEFINE LISTBOX oLbs FIELDS           ;
                 oMes:ANOMES             ,;
      TRANSFORM( oMes:EXISTENCIA,aEst[3]),;
      TRANSFORM( oMes:ENTRADAS  ,aEst[3]),;
      TRANSFORM( oMes:SALIDAS   ,aEst[3]),;
      TRANSFORM( oMes:AJUSTES_E ,aEst[3]),;
      TRANSFORM( oMes:AJUSTES_S ,aEst[3]),;
      TRANSFORM( oMes:DEVOL_E   ,aEst[3]),;
      TRANSFORM( oMes:DEVOL_S   ,aEst[3]),;
      TRANSFORM( oMes:DEVOLCLI  ,aEst[3]),;
      TRANSFORM( oMes:PCOSTO    ,aEst[4]) ;
      ID 18 OF oDlg UPDATE                ;
      HEADERS "AñoMes", "Existencia", "Entradas", "Salidas"     ,;
              "Ajustes"+CRLF+"Entradas","Ajustes"+CRLF+"Salidas",;
              "Devoluc"+CRLF+"Entradas","Devoluc"+CRLF+"Salidas",;
              "Devoluc"+CRLF+"Cliente" ,"Precio" +CRLF+"Costo"
    oLbs:nClrBackHead  := oApl:nClrBackHead
    oLbs:nClrForeHead  := oApl:nClrForeHead
    oLbs:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbs:nClrBackFocus := oApl:nClrBackFocus
    oLbs:nClrForeFocus := oApl:nClrForeFocus
    oLbs:GoTop()
    oLbs:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbs:nHeaderHeight := 28
    oLbs:aColSizes   := {50,60,60,60,60,60,54,54,54,80}
    oLbs:aHjustify   := {2,2,2,2,2,2,2,2,2,2}
    oLbs:aJustify    := {0,1,1,1,1,1,1,1,1,1}
    oLbs:ladjbrowse  := oLbs:lCellStyle := .f.
    oLbs:ladjlastcol := .t.
    oLbs:bKeyDown := {|nKey| If(nKey == VK_F3, oInv:Extrac( oMes ),;
                             If(nKey == VK_F5, ActuSaldo( {NtChr( oMes:ANOMES,"F" ),,0,0,oMes:CODIGO,;
                                                                  oMes:PCOSTO,.t.} ),;
                             If(nKey == VK_F7 .OR. nKey == VK_ESCAPE, (oLbs:oJump := oGet[1], oGet[1]:SetFocus() ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, Insertar(oMes,oLbs,.f.),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, Insertar(oMes,oLbs,.t.),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, DelRecord(oMes,oLbs), ) ))))) }
   MySetBrowse( oLbs, oMes )
   REDEFINE BUTTON oGet[02] ID 19 OF oDlg ACTION oDlg:End() CANCEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT ( oDlg:Move(80,1) );
   VALID !GetKeyState(VK_ESCAPE)
oInv:Cerrar()
oMes:Destroy()
RETURN NIL

//------------------------------------//
STATIC FUNCTION BuscaCod( oInv,oMes,aEst )
   LOCAL lSi := .t.
If oApl:oInv:Seek( {"codigo",oInv:xVar} )
   oMes:Seek( {"empresa",oApl:nEmpresa,"codigo",oInv:xVar,"anomes >= ","199401"},"anomes DESC" )
   aEst[2] := Buscar( {"linea",oApl:oInv:LINEA},"cadlinea","nombre",8 )
   aEst[5] := ArrayValor( oInv:aMed,oApl:oInv:UNIDADMED,,.f. )
   aEst[6] := ArrayValor( oInv:aCon,oApl:oInv:CODCON,,.f. )
Else
   MsgStop( "Este Código NO EXISTE !!!" )
   lSi := .f.
EndIf
RETURN lSi

//------------------------------------//
STATIC PROCEDURE Insertar( oMes,oLbx,lNew )
   LOCAL oDlg, oGet := ARRAY(14)
   LOCAL aED := { .f.,"Modificando Saldo ","999,999.9","999,999,999" }
If !oApl:lEnLinea .AND. oLbx # NIL
   If lNew
      aED[2] := "Nuevo Saldo "
      oMes:xBlank()
      oMes:Read()
      oMes:EMPRESA := oApl:nEmpresa ; oMes:CODIGO := oApl:oInv:CODIGO
      oMes:ANOMES  := oApl:cPer     ; oMes:PCOSTO := oApl:oInv:PCOSTO
   Else
      oMes:xLoad()
   EndIf
EndIf

DEFINE DIALOG oDlg TITLE aED[2]+oMes:CODIGO FROM 00,02 TO 16,50
   @ 02, 00 SAY "Año y Mes"    OF oDlg RIGHT PIXEL SIZE 46,10
   @ 02, 50 GET oGet[01] VAR oMes:ANOMES OF oDlg PICTURE "999999";
      SIZE 30,10 PIXEL
   @ 14, 00 SAY "Existencia"   OF oDlg RIGHT PIXEL SIZE 46,10
   @ 14, 50 GET oGet[02] VAR oMes:EXISTENCIA OF oDlg PICTURE aED[3];
      SIZE 30,10 PIXEL
   @ 28, 00 SAY "Entradas"     OF oDlg RIGHT PIXEL SIZE 46,10
   @ 28, 50 GET oGet[03] VAR oMes:ENTRADAS   OF oDlg PICTURE aED[3];
      SIZE 30,10 PIXEL
   @ 28, 84 SAY "Salidas"      OF oDlg RIGHT PIXEL SIZE 46,10
   @ 28,134 GET oGet[04] VAR oMes:SALIDAS    OF oDlg PICTURE aED[3];
      SIZE 30,10 PIXEL
   @ 40, 00 SAY "Sobrantes"    OF oDlg RIGHT PIXEL SIZE 46,10
   @ 40, 50 GET oGet[05] VAR oMes:AJUSTES_E  OF oDlg PICTURE aED[3];
      SIZE 30,10 PIXEL
   @ 40, 84 SAY "Faltantes"    OF oDlg RIGHT PIXEL SIZE 46,10
   @ 40,134 GET oGet[06] VAR oMes:AJUSTES_S  OF oDlg PICTURE aED[3];
      SIZE 30,10 PIXEL
   @ 52, 00 SAY "Devol_Ent"    OF oDlg RIGHT PIXEL SIZE 46,10
   @ 52, 50 GET oGet[07] VAR oMes:DEVOL_E    OF oDlg PICTURE aED[3];
      SIZE 30,10 PIXEL
   @ 52, 84 SAY "Devol_Sal"    OF oDlg RIGHT PIXEL SIZE 46,10
   @ 52,134 GET oGet[08] VAR oMes:DEVOL_S    OF oDlg PICTURE aED[3];
      SIZE 30,10 PIXEL
   @ 64, 00 SAY "Devol_Cli"    OF oDlg RIGHT PIXEL SIZE 46,10
   @ 64, 50 GET oGet[09] VAR oMes:DEVOLCLI   OF oDlg PICTURE aED[3];
      SIZE 30,10 PIXEL
   @ 64, 84 SAY "Precio Costo" OF oDlg RIGHT PIXEL SIZE 46,10
   @ 64,134 GET oGet[10] VAR oMes:PCOSTO     OF oDlg PICTURE aED[4];
      SIZE 32,10 PIXEL
   @ 76, 00 SAY "FULT_Entrada" OF oDlg RIGHT PIXEL SIZE 46,10
   @ 76, 50 GET oGet[11] VAR oMes:FEC_ULTE   OF oDlg SIZE 32,12 PIXEL
   @ 76, 84 SAY "FULT_Salida"  OF oDlg RIGHT PIXEL SIZE 46,10
   @ 76,134 GET oGet[12] VAR oMes:FEC_ULTS   OF oDlg SIZE 32,12 PIXEL

   @ 94, 60 BUTTON oGet[13] PROMPT "&Grabar"   SIZE 44,12 OF oDlg ACTION ;
      (If( EMPTY(oMes:ANOMES) .OR. oMes:PCOSTO <= 0                     ,;
         ( MsgStop("Imposible grabar este Código"), oGet[1]:SetFocus() ),;
         ( aEd[1] := .t., oDlg:End() ))) PIXEL
   @ 94,110 BUTTON oGet[14] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL ;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTER;
   WHEN !oApl:lEnLinea
If aEd[1]
   If lNew
      oMes:Append()
      oLbx:Refresh()
   Else
      oMes:Update(.t.,1)
   EndIf
EndIf

RETURN

//------------------------------------//
STATIC FUNCTION Consecut( lActual,cLinea )
   LOCAL hRes, cQry := " WHERE linea = " + xValToChar( cLinea )
If lActual
   Guardar( "UPDATE cadlinea SET conse = IFNULL( conse,0 ) +1" + cQry, "cadlinea" )
Else
   cQry := "SELECT IFNULL( conse,0 ) +1 FROM cadlinea" + cQry
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   If MSNumRows( hRes ) == 0
      cQry := { "1" }
   Else
      cQry := MyReadRow( hRes )
   EndIf
   MSFreeResult( hRes )
   cLinea += STRZERO( VAL(cQry[1]),7 )
 //cLinea += SPACE(7)
EndIf
RETURN cLinea

//------------------------------------//
CLASS TInv FROM TNits

 DATA aCon, aMed, oCg, oVt

 METHOD NEW( oTabla,lDel ) Constructor
 METHOD Cerrar()
 METHOD Editar( xRec,lNuevo,lView,cCod )
 METHOD Mostrar( lAyuda,nOrd )
 METHOD Muestra()
 METHOD Codcon( oBrw,lNew,nIt )
 METHOD Extrac( oMes,aEd )

ENDCLASS

//------------------------------------//
METHOD NEW( oTabla,lDel ) CLASS TInv
   DEFAULT oTabla := oApl:oInv
Super:New( oTabla,lDel )
 ::aCon   := Buscar( "SELECT nombre, codcon FROM convertir GROUP BY codcon"+;
                     " ORDER BY nombre","CM",,9 )
 ::aMed   := ArrayCombo( "MEDIDAS",1 )
 ::aOrden := { {"<None> "  ,1},;
               {"Código"   ,2},;
               {"Nombre"   ,3} }
 ::bPrint := {|| Listados( 1,::oDb:FieldName( ::aOrden[ ::nOrden,2 ] ) ) }
 ::oCg   := TCat() ; ::oCg:New()
 ::oVt   := TRip() ; ::oVt:New( 8 )
 ::xVar  := SPACE(10)
RETURN NIL

//------------------------------------//
METHOD Cerrar() CLASS TInv
 ::oCg:oDb:Destroy()
 ::oVt:oDb:Destroy()
RETURN NIL

//------------------------------------//
METHOD Mostrar(lAyuda,nOrd) CLASS TInv
   LOCAL oDlg, oM := Self
   LOCAL cTit := "Ayuda de Artículos", bHacer, lReturn := NIL
   DEFAULT lAyuda := .t. , nOrd := 3
If lAyuda
   bHacer  := {||lReturn :=.t., oDlg:End()}
   lReturn := .f.
ELSE
   bHacer  := ::bEditar
   cTit    := "Código de Artículos"
ENDIF
nOrd := ::Ordenar( nOrd )
DEFINE DIALOG oDlg FROM 3, 3 TO 22, 68 TITLE cTit
   @ 1.5,.5 LISTBOX ::oLbx FIELDS   ;
                    ::oDb:CODIGO    , ::oDb:DESCRIP ,;
         TRANSFORM( ::oDb:PCOSTO,"999,999,999" ),;
         TRANSFORM( ::oDb:PPUBLI,"999,999,999" ) ;
      HEADERS "Código"+CRLF+"Artículo","Nombre" ,;
      "Precio"+CRLF+"Costo", "Precio"+CRLF+"Público" ;
      SIZES 400, 450 SIZE 250,107  ;
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
    ::oLbx:aColSizes   := {70,260,70,70}
    ::oLbx:aHjustify   := {2,2,2,2}
    ::oLbx:aJustify    := {0,0,1,1}
    ::oLbx:ladjbrowse  := ::oLbx:lCellStyle := .f.
    ::oLbx:ladjlastcol := .t.
    ::oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey == VK_RETURN, (EVAL(bHacer)),;
                               If(nKey == VK_F5    , (::Editar( -1,.t. ),;
                                                      ::oLbx:SetFocus() , ::oLbx:Refresh() ),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(::BNew),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=69, EVAL(::bEditar)		 ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=86, EVAL(::bVer) 		         ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) ))))) }
   MySetBrowse( ::oLbx, ::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT (oM:Barra(lAyuda,oDlg))
::oDb:Setorder(nOrd)

RETURN lReturn

//------------------------------------//
METHOD Editar( xRec,lNuevo,lView,cCod ) CLASS TInv
   LOCAL aEd := { "Nuevo Código","",0,"999,999,999.99","",.f. }
   LOCAL nCon, nMed, oDlg, oGet := ARRAY(19)
   DEFAULT lNuevo := .t. , lView := .f. ,;
           xRec   :=  0  , cCod  := ::xVar
If lNuevo
   If xRec == -1
      cCod := ACLONE( ::oDb:axBuffer )
      ::oDb:xBlank()
      AEVAL( cCod, { |x,p| ::oDb:axBuffer[p] := x },2 )
      ::oDb:CODIGO    := Consecut( .f.,::oDb:LINEA )
   Else
      ::oDb:xBlank()
      ::oDb:CODIGO    := cCod
      ::oDb:LINEA     := LEFT( cCod,3 )
      ::oDb:IMPUESTO  := oApl:oEmp:PIVA
      ::oDb:UNIDADMED := "UN"
      ::oDb:CODCON    := 1
      ::oDb:STOCKM    := 5
   EndIf
ELSE
   cCod   := NtChr( oApl:dFec,"1" )
   aEd[1] := If( lView, "Viendo", "Modificando" ) + " Código"
   aEd[2] := Buscar( { "linea",::oDb:LINEA },"cadlinea","nombre",8 )
   aEd[3] := SaldoInv( ::oDb:CODIGO,cCod,1 )
ENDIF
nMed := ArrayValor( ::aMed,::oDb:UNIDADMED,,.t. )
nCon := ArrayValor( ::aCon,::oDb:CODCON,,.t. )

DEFINE DIALOG oDlg RESOURCE "ARTICULOS" TITLE aEd[1]
   REDEFINE BTNGET oGet[01] VAR ::oDb:LINEA ID  1 OF oDlg RESOURCE "BUSCAR" ;
      ACTION EVAL({|| If( ::oCg:Mostrar(), ( ::oDb:LINEA := ::oCg:oDb:LINEA,;
                          oGet[01]:Refresh() ), ) })                        ;
      VALID EVAL( {|| ::oDb:LINEA := UPPER( ::oDb:LINEA )                  ,;
                      If( ::oCg:oDb:Seek( {"linea",::oDb:LINEA} )          ,;
                        ( If( lNuevo .AND. EMPTY( ::oDb:CODIGO )           ,;
                            ( ::oDb:CODIGO := Consecut( .f.,::oDb:LINEA )  ,;
                              oGet[2]:Refresh() ), )                       ,;
                          aEd[2] := ::oCg:oDb:NOMBRE, oDlg:Update(), .t. ) ,;
                        ( MsgStop("Esta Línea no Existe .."), .f. ) ) } )   ;
      WHEN lNuevo
   REDEFINE SAY VAR aEd[2] ID  2 OF oDlg UPDATE
   REDEFINE GET oGet[02] VAR ::oDb:CODIGO   ID  4 OF oDlg PICTURE "@!"   ;
      VALID EVAL( {|| If( ::Buscar( ::oDb:CODIGO,"codigo" )             ,;
                        ( MsgStop("Código ya existe .."),.f. ), .t. ) } );
      WHEN lNuevo
   REDEFINE GET oGet[03] VAR ::oDb:DESCRIP    ID  6 OF oDlg PICTURE "@!"
   REDEFINE CHECKBOX ::oDb:INDIVA             ID  8 OF oDlg ;
      WHEN !lView  ON CHANGE PrecioVenta( oGet,4 )
   REDEFINE GET oGet[04] VAR ::oDb:IMPUESTO   ID 11 OF oDlg PICTURE "999.99";
      WHEN ::oDb:INDIVA
   REDEFINE GET oGet[05] VAR ::oDb:PCOSTO     ID 13 OF oDlg PICTURE aEd[4]
   REDEFINE GET oGet[06] VAR ::oDb:PUTIL      ID 15 OF oDlg PICTURE "999.99";
      VALID PrecioVenta( oGet,6 )
   REDEFINE GET oGet[07] VAR ::oDb:PVENTA     ID 17 OF oDlg PICTURE aEd[4];
      VALID PrecioVenta( oGet,7 )
   REDEFINE SAY oGet[08] VAR ::oDb:PPUBLI     ID 19 OF oDlg PICTURE aEd[4] UPDATE
   REDEFINE COMBOBOX oGet[09] VAR nMed ITEMS ArrayCol( ::aMed,1 ) ID 21 OF oDlg
   REDEFINE GET oGet[10] VAR ::oDb:PUNIDAD    ID 23 OF oDlg PICTURE aEd[4]
   REDEFINE BTNGET oGet[11] VAR ::oDb:VITRINA ID 25 OF oDlg RESOURCE "BUSCAR" ;
      ACTION EVAL({|| If( ::oVt:Mostrar(), (::oDb:VITRINA := ::oVt:oDb:CODIGO,;
                          oGet[11]:Refresh() ), ) })                    ;
      VALID EVAL( {|| If( EMPTY( ::oDb:VITRINA ), .t.                  ,;
                    ( If( ::oVt:oDb:Seek( {"codigo",::oDb:VITRINA} )   ,;
                        ( oGet[12]:Settext( ::oVt:oDb:NOMBRE ), .t. )  ,;
                        (MsgStop("Está Vitrina no Existe"), .f.) ) )) } )
   REDEFINE SAY oGet[12] VAR aEd[5] ID  26 OF oDlg UPDATE
   REDEFINE GET oGet[13] VAR ::oDb:AJUSTE_ESP ID 28 OF oDlg PICTURE "!" ;
      VALID ::oDb:AJUSTE_ESP $ "S "
   REDEFINE GET oGet[14] VAR ::oDb:DESPOR     ID 30 OF oDlg PICTURE "999.99";
      VALID Rango( ::oDb:DESPOR,0,100 )
   REDEFINE GET oGet[15] VAR ::oDb:STOCKM     ID 32 OF oDlg PICTURE "999,999";
      VALID ::oDb:STOCKM > 1
   REDEFINE COMBOBOX oGet[16] VAR nCon ITEMS ArrayCol( ::aCon,1 ) ID 34 OF oDlg
    oGet[16]:bRClicked = {|| ::Muestra() }
//   REDEFINE GET oGet[16] VAR ::oDb:PAQUETE    ID 34 OF oDlg PICTURE "999,999";
//      VALID ::oDb:PAQUETE > 1
   REDEFINE SAY oGet[17] VAR aEd[3]           ID 36 OF oDlg PICTURE "999,999.99999"

   REDEFINE BUTTON oGet[18] ID 37 OF oDlg ACTION ;
      (If( EMPTY(::oDb:CODIGO) .OR. EMPTY(::oDb:DESCRIP),;
         (MsgStop("No se puede grabar este CODIGO, debe completar datos"),;
          oGet[1]:SetFocus()), (aEd[6] := .t., oDlg:End()) ))
   REDEFINE BUTTON oGet[19] ID 38 OF oDlg CANCEL ;
      ACTION oDlg:End()
   ACTIVAGET(oGet)
   IF lView                     // Solo Consulta
      DesactivaALLGET(oGet)
      oGet[18]:Disable()
      oGet[19]:Enable()
      oGet[19]:SetFocus()
   ENDIF
ACTIVATE DIALOG oDlg CENTER
If aEd[6]
   ::oDb:UNIDADMED := ::aMed[nMed,2]
   ::oDb:CODCON    := ::aCon[nCon,2]
   ::oDb:VITRINA   := UPPER(::oDb:VITRINA)
   ::Guardar(lNuevo)
   If lNuevo
      ::oDb:Seek( {"codigo",::oDb:CODIGO} )
      Consecut( .t.,::oDb:LINEA )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Muestra() CLASS TInv
   LOCAL oDlg, oBrw, nIt := 1
 ::Extrac()
DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE "Tabla de Conversión"
   @ 1.5, 0 LISTBOX oBrw FIELDS ;
             ::aV[nIt][3],      ::aV[nIt][4],;
             ::aV[nIt][5], STR( ::aV[nIt][6],12,6 );
    HEADERS "Nombre","Convertir DE","[ A ]","Multiplicar POR" ;
      FIELDSIZES 110,70,70,70;
      OF oDlg UPDATE         ;
      SIZE 200,107           ;
      ON DBLCLICK ::Codcon( oBrw,nIt )
   oBrw:bGotop    := { || nIt := 1 }
   oBrw:bGoBottom := { || nIt := EVAL( oBrw:bLogicLen ) }
   oBrw:bSkip     := { | nWant,nOld | nOld := nIt , nIt += nWant,;
              nIt := MAX( 1, MIN( nIt, EVAL( oBrw:bLogicLen ))),;
              nIt - nOld }
   oBrw:bLogicLen := { || LEN( ::aV ) }
   oBrw:cAlias    := "Array"
   oBrw:bKeyDown  := {|nKey| If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT,;
                                                                 ::Codcon( oBrw,.t.,nIt ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN,;
                                                                 ::Codcon( oBrw,.f.,nIt ), )) }
ACTIVATE DIALOG oDlg CENTERED
RETURN NIL

//------------------------------------//
METHOD Codcon( oBrw,lNew,nIt ) CLASS TInv
   LOCAL aEd, bMed, oDlg, oGet := ARRAY(8)
If lNew
   aEd := { ::aV[nIt,2],::aV[nIt,3],"  ","  ",0,"Nuevo Código",.f.,1,0,"" }
Else
   aEd := { ::aV[nIt,2],::aV[nIt,3],::aV[nIt,4],::aV[nIt,5],::aV[nIt,6],;
            "Modificando Código",.f.,1,0,"" }
EndIf
aEd[8] += Buscar( "SELECT MAX(codcon) FROM convertir","CM",,8,,4 )
bMed := {|sUM| If( Buscar( {"tipo","MEDIDAS","retornar",sUM},;
                            "cadcombo","1",8,,4 ) == 1, .t. ,;
                  ( MsgStop("Esta Unidad Medida no Existe"),.f. )) }
DEFINE DIALOG oDlg TITLE aEd[6] FROM 0, 0 TO 11,50
   @ 02,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 50,10
   @ 02,52 GET oGet[1] VAR aEd[1] OF oDlg PICTURE "999"            ;
      VALID EVAL( {|| If( Buscar( {"codcon",aEd[1]},"convertir"   ,;
                                   "1",8,,4 ) == 0                ,;
                     (If( MsgYesNo("Esta CATEGORIA","Desea Crear"),;
                          .t., .f. ) ), .t. ) } )                  ;
      WHEN lNew  SIZE 20,10 PIXEL
   @ 02,100 SAY "Sgte. Código"     OF oDlg RIGHT PIXEL SIZE 46,10
   @ 02,148 SAY oGet[8] VAR aEd[8] OF oDlg PIXEL SIZE  44,10 ;
      UPDATE COLOR nRGB( 255,0,0 )
   @ 14,00 SAY "Nombre"   OF oDlg RIGHT PIXEL SIZE 50,10
   @ 14,52 GET oGet[2] VAR aEd[2] OF oDlg PICTURE "@!";
      VALID !EMPTY(aEd[2])  SIZE 80,10 PIXEL
   @ 26,00 SAY "Convertir DE" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 26,52 GET oGet[3] VAR aEd[3] OF oDlg PICTURE "!!";
      VALID EVAL( bMed,aEd[3] ) SIZE 20,10 PIXEL
   @ 38,00 SAY "[ A ]"       OF oDlg RIGHT PIXEL SIZE 50,10
   @ 38,52 GET oGet[4] VAR aEd[4] OF oDlg PICTURE "!!";
      VALID EVAL( bMed,aEd[4] ) SIZE 20,10 PIXEL
   @ 50,00 SAY "Multiplicar POR"   OF oDlg RIGHT PIXEL SIZE 50,10
   @ 50,52 GET oGet[5] VAR aEd[5] OF oDlg PICTURE "9,999.999999";
      VALID {|| If( aEd[5] >  0, .t.                           ,;
          (MsgStop( "El Valor debe ser Mayor de 0","<< OJO >>"), .f.)) };
      SIZE 40,10 PIXEL
   @ 64, 60 BUTTON oGet[6] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION;
     ( ::Extrac( lNew,@aEd )                          ,;
        If( aEd[9] == 0, ( aEd[7] := .t., oDlg:End() ),;
          ( MsgStop( aEd[10],">>> OJO <<<" ), oGet[2]:SetFocus() ) ) ) PIXEL
   @ 64,110 BUTTON oGet[7] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTER
If aEd[7]
   If lNew
      aEd[6] := "INSERT INTO convertir VALUES( null, "+;
                LTRIM(STR(aEd[1])) +  ", '" +;
                  ALLTRIM(aEd[2])  + "', '" +;
                  ALLTRIM(aEd[3])  + "', '" +;
                  ALLTRIM(aEd[4])  + "', "  +;
                LTRIM(STR(aEd[5])) + " )"
   Else
      aEd[6] := "UPDATE convertir SET nombre = '" +   ALLTRIM(aEd[2]) +;
                                       "' de = '" +   ALLTRIM(aEd[3]) +;
                                        "' a = '" +   ALLTRIM(aEd[4]) +;
                                 "' multipor = "  + LTRIM(STR(aEd[5]))+;
                              " WHERE row_id = "  + LTRIM(STR(::aV[nIt,1]))
   EndIf
   MSQuery( oApl:oMySql:hConnect,aEd[6] )
   ::Extrac()
   //ASORT( ::aV,,, { |x,y| x[1] < y[1] } )
   oBrw:Refresh()
EndIf
RETURN NIL

//------------------------------------//
METHOD Extrac( oMes,aEd ) CLASS TInv

If oMes == NIL
   ::aV := Buscar( "SELECT * FROM convertir ORDER BY nombre, de","CM",,9 )
ElseIf aEd == NIL
   aEd := { oMes:CODIGO,NtChr( oMes:ANOMES,"F" ),2,oApl:nTFor,.t.,"" }
   aEd[3] := CTOD( NtChr( aEd[2],"4" ) )
   oApl:oWnd:SetMsg( "Extracto del Periodo "+oMes:ANOMES )
   InoLiExt( aEd )
Else
   aEd[9] := 0
   AEVAL( aEd,{|x| aEd[9] += If( EMPTY(x), 1, 0 ) },1,5 )
   If aEd[09] > 0
      aEd[10] := "Debe completar datos para Grabar este Código"
   ElseIf Buscar( {"codcon",aEd[1],"de",aEd[3],"a",aEd[4]},;
                   "convertir","1",8,,4 ) == 1 .AND. oMes
      aEd[09] := 1
      aEd[10] := "Esta CATEGORIA, ya Existe"
   EndIf
EndIf
RETURN NIL

//------------------------------------//
FUNCTION PrecioVenta( oGet,xUtil )
   LOCAL nIva
If xUtil == 6
   oApl:oInv:PVENTA   := ROUND(oApl:oInv:PCOSTO * (1+oApl:oInv:PUTIL/100),0 )
   oGet[7]:Refresh()
EndIf
   oApl:oInv:IMPUESTO := If(!oApl:oInv:INDIVA, 0,;
                         If( oApl:oInv:IMPUESTO == 0, oApl:oEmp:PIVA, oApl:oInv:IMPUESTO ) )
   nIva := 1 + ROUND( oApl:oInv:IMPUESTO / 100,2 )
If xUtil == 7 .AND. oApl:oInv:INDIVA
   If MsgYesNo( "Precio con IVA incluido","I.V.A." )
      oApl:oInv:PVENTA := ROUND(oApl:oInv:PVENTA / nIva,2 )
      oGet[7]:Refresh()
   EndIf
EndIf
   oApl:oInv:PUTIL    := If( oApl:oInv:PVENTA == 0, oApl:oInv:PUTIL,;
                    ROUND( ((oApl:oInv:PVENTA - oApl:oInv:PCOSTO) / oApl:oInv:PCOSTO) * 100,2 ) )
   oApl:oInv:PPUBLI   := ROUND(oApl:oInv:PVENTA * nIva,0 )
If oGet # NIL
   oGet[6]:Refresh()
   oGet[8]:Refresh()
   If xUtil == 4 .AND. oApl:oInv:INDIVA
      oGet[4]:Refresh()
      oGet[4]:SetFocus()
   EndIf
EndIf
RETURN .t.