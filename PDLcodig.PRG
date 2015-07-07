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
   oInv:Activate()
   RETURN NIL
EndIf
aEst := { "","","999,999","999,999,999","" }
oMes := oApl:Abrir( "cadinvme","empresa, codigo, anomes",,,30 )
oMes:Seek( { "empresa",oApl:nEmpresa,"codigo",oInv:xVar,"anomes >= ","199401" } )
oApl:oInv:xBlank()

DEFINE DIALOG oDlg RESOURCE "CODIGOS"
   REDEFINE BTNGET oGet[1] VAR oInv:xVar ID  1 OF oDlg RESOURCE "BUSCAR"     ;
      ACTION EVAL({|| If( oInv:Mostrar(), ( oInv:xVar := oInv:oDb:CODIGO    ,;
                          oGet[1]:Refresh(), oGet[1]:lValid(.f.) ), ) })     ;
      VALID( If( BuscaCod( oInv,oMes,@aEst ), (oLbs:Refresh(), oDlg:Update(),;
                 oLbs:GoBottom(), oGet[1]:oJump := oLbs, .t. ), .f. ))
   REDEFINE SAY VAR oApl:oInv:DESCRIP    ID  2 OF oDlg UPDATE
   REDEFINE SAY VAR oApl:oInv:CATEGORIA  ID  4 OF oDlg PICTURE "999" UPDATE
   REDEFINE SAY VAR aEst[2]              ID  5 OF oDlg UPDATE
   REDEFINE SAY VAR oApl:oInv:PCOSTO     ID  7 OF oDlg PICTURE aEst[4] UPDATE
   REDEFINE SAY VAR oApl:oInv:PVENTA     ID  9 OF oDlg PICTURE aEst[4] UPDATE
   REDEFINE SAY VAR oApl:oInv:PPUBLI     ID 11 OF oDlg PICTURE aEst[4] UPDATE
   REDEFINE SAY VAR aEst[5]              ID 13 OF oDlg UPDATE
   REDEFINE SAY VAR oApl:oInv:AJUSTE_ESP ID 15 OF oDlg UPDATE

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
      ID 16 OF oDlg UPDATE                ;
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
    oLbs:aColSizes  := {50,60,60,60,60,60,54,54,54,80}
    oLbs:aHjustify  := {2,2,2,2,2,2,2,2,2,2}
    oLbs:aJustify   := {0,1,1,1,1,1,1,1,1,1}
    oLbs:bKeyDown := {|nKey| If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, Insertar(oMes,oLbs,.f.),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, Insertar(oMes,oLbs,.t.),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, DelRecord(oMes,oLbs),;
                             If(nKey=VK_F7, (oLbs:oJump := oGet[1], oGet[1]:SetFocus()), ) ) ) ) }
    oLbs:ladjlastcol := .t.
    oLbs:ladjbrowse  := oLbs:lCellStyle  := .f.
   MySetBrowse( oLbs, oMes )
   REDEFINE BUTTON oGet[02] ID 17 OF oDlg ACTION oDlg:End() CANCEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT ( oDlg:Move(80,1) );
   VALID !GetKeyState(VK_ESCAPE)
oMes:Destroy()

RETURN NIL

//------------------------------------//
STATIC FUNCTION BuscaCod( oInv,oMes,aEst )
   LOCAL lSi := .t.
If oApl:oInv:Seek( {"codigo",oInv:xVar} )
   oMes:Seek( { "empresa",oApl:nEmpresa,"codigo",oInv:xVar,"anomes >= ","199401" } )
   aEst[2] := Buscar( { "categoria",oApl:oInv:CATEGORIA },"cadcateg","nombre" )
   aEst[5] := ArrayValor( oInv:aMed,oApl:oInv:UNIDADMED,,.f. )
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
CLASS TInv FROM TNits

DATA aMed, oCg

METHOD NEW( oTabla,lDel ) Constructor
METHOD Editar( xRec,lNuevo,lView,cCod )
METHOD PrecioVenta( oGet,xRec )
METHOD Mostrar( lAyuda,nOrd )
METHOD Actuliza()
METHOD Cambiarp()
METHOD Listado()

ENDCLASS

//------------------------------------//
METHOD NEW( oTabla,lDel ) CLASS TInv
   DEFAULT oTabla := oApl:oInv  //oApl:Abrir( "cadinven",3 )
Super:New( oTabla,lDel )
::aMed   := Buscar( { "tipo","INV" },"cadmedid","nombre, codigo",2,"nombre" )
::aOrden := { {"<None> "  ,1},;
              {"Código"   ,2},;
              {"Nombre"   ,3} }
::oCg   := TCat()
::xVar  := SPACE(5)
::oCg:New()
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
DEFINE DIALOG oDlg FROM 0, 0 TO 20, 60 TITLE cTit
   @ 1.5, 0 LISTBOX ::oLbx FIELDS   ;
                    ::oDb:CODIGO    , ::oDb:DESCRIP ,;
         TRANSFORM( ::oDb:PPUBLI,"999,999,999" ),;
         TRANSFORM( ::oDb:PNUEVO,"999,999,999" ) ;
      HEADERS "Código"+CRLF+"Artículo","Nombre","Precio"+CRLF+"Público",;
              "Precio"+CRLF+"Nuevo";
      SIZES 400, 450 SIZE 238,107  ;
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
    ::oLbx:aColSizes   := {50,250,70,70}
    ::oLbx:aHjustify   := {2,2,2,2}
    ::oLbx:aJustify    := {0,0,2,2}
    ::oLbx:cToolTip    := "[F8] Cambiar Precio [F9] Actualizar"
    ::oLbx:ladjbrowse  := ::oLbx:lCellStyle := .f.
    ::oLbx:ladjlastcol := .t.
    ::oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey = VK_RETURN, EVAL( bHacer )                   ,;
                               If(nKey = VK_F8    , (::Cambiarp(), ::oLbx:SetFocus()),;
                               If(nKey = VK_F9    , (::Actuliza(), ::oLbx:SetFocus()),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, Eval(::BNew),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=69, EVAL(::bEditar)		 ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=86, EVAL(::bVer) 		         ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) )))))) }
   MySetBrowse( ::oLbx, ::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT (oM:Barra(lAyuda,oDlg))
::oDb:Setorder(nOrd)

RETURN lReturn

//------------------------------------//
METHOD Editar(xRec,lNuevo,lView,cCod) CLASS TInv
   LOCAL oDlg, oGet := ARRAY(13), bValid, nMed, cPict := "999,999,999.99"
   LOCAL aEd := { ::oDb:Recno(),"Nuevo Código","",::oDb:CATEGORIA,0,0,.f. }
DEFAULT lNuevo := .t. ,;
        lView  := .f. ,;
        xRec   :=  0  , cCod := ::xVar
If lNuevo
   ::oDb:xBlank()
   ::oDb:CODIGO    := cCod
   ::oDb:CATEGORIA := aEd[4]
   ::oDb:UNIDADMED := "UN"
ELSE
   cCod   := NtChr( oApl:dFec,"1" )
   aEd[2] := If( lView, "Viendo", "Modificando" ) + " Código"
   aEd[3] := Buscar( { "categoria",::oDb:CATEGORIA },"cadcateg","nombre" )
   aEd[5] := ::oDb:PVENTA
   aEd[6] := SaldoInv( ::oDb:CODIGO,cCod,1 )
ENDIF
bValid := {|| If( ::Buscar( ::oDb:CODIGO,"codigo" ),;
              (MsgStop("Código ya existe .."),.f.), .t. ) }
nMed   := ArrayValor( ::aMed,::oDb:UNIDADMED,,.t. )
xRec   := ::oDb:INDIVA + 1

DEFINE DIALOG oDlg RESOURCE "ARTICULOS" TITLE aEd[2]
   REDEFINE GET oGet[01] VAR ::oDb:CODIGO       ID  1 OF oDlg ;
      VALID EVAL(bValid) ;
      WHEN lNuevo
   REDEFINE BTNGET oGet[02] VAR ::oDb:CATEGORIA ID  3 OF oDlg RESOURCE "BUSCAR";
      ACTION EVAL({|| If( ::oCg:Mostrar(), ( ::oDb:CATEGORIA :=                ;
                          ::oCg:oDb:CATEGORIA, oGet[02]:Refresh() ), ) })      ;
      VALID EVAL( {|| If( ::oCg:oDb:Seek( {"categoria",::oDb:CATEGORIA} )     ,;
                        ( aEd[3] := ::oCg:oDb:NOMBRE, oDlg:Update(), .t. )    ,;
                        ( MsgStop("Esta Categoria no Existe .."), .f. ) ) } )
   REDEFINE SAY VAR aEd[3] ID  4 OF oDlg UPDATE
   REDEFINE GET oGet[03] VAR ::oDb:DESCRIP    ID  6 OF oDlg PICTURE "@!"
   REDEFINE RADIO oGet[4] VAR xRec            ID  8,9 OF oDlg    ;
      WHEN !lView
   REDEFINE GET oGet[05] VAR ::oDb:IMPUESTO   ID 11 OF oDlg PICTURE "999.99";
      WHEN xRec == 2
   REDEFINE GET oGet[06] VAR ::oDb:PCOSTO     ID 13 OF oDlg PICTURE cPict
   REDEFINE GET oGet[07] VAR ::oDb:PVENTA     ID 15 OF oDlg PICTURE cPict;
      VALID ::PrecioVenta( oGet,xRec )
   REDEFINE SAY oGet[08] VAR ::oDb:PPUBLI     ID 17 OF oDlg PICTURE cPict UPDATE
   REDEFINE COMBOBOX oGet[09] VAR nMed ITEMS ArrayCol( ::aMed,1 ) ID 19 OF oDlg
   REDEFINE GET oGet[10] VAR ::oDb:AJUSTE_ESP ID 21 OF oDlg PICTURE "!" ;
      VALID ::oDb:AJUSTE_ESP $ "S "
   REDEFINE SAY oGet[11] VAR aEd[6]           ID 23 OF oDlg PICTURE "999,999.9"
   REDEFINE CHECKBOX ::oDb:LISTAR             ID 24 OF oDlg

   REDEFINE BUTTON oGet[12] ID 25 OF oDlg ACTION ;
      (If( EMPTY(::oDb:CODIGO) .OR. EMPTY(::oDb:DESCRIP),;
         (MsgStop("No se puede grabar este CODIGO, debe completar datos"),;
          oGet[1]:SetFocus()), (aEd[7] := .t., oDlg:End()) ))
   REDEFINE BUTTON oGet[13] ID 26 OF oDlg CANCEL ;
      ACTION oDlg:End()
   ACTIVAGET(oGet)
   IF lView                     // Solo Consulta
      DesactivaALLGET(oGet)
      oGet[12]:Disable()
      oGet[13]:Enable()
      oGet[13]:SetFocus()
   ENDIF
ACTIVATE DIALOG oDlg CENTER
If aEd[7]
   ::oDb:INDIVA    := xRec - 1
   ::oDb:UNIDADMED := ::aMed[nMed,2]
   ::Guardar(lNuevo)
   aEd[1] := ::oDb:Recno()
EndIf
::oDb:Go( aEd[1] ):Read()
RETURN NIL

//------------------------------------//
METHOD PrecioVenta( oGet,xRec ) CLASS TInv
   LOCAL nIva := 1
If xRec == 1
   ::oDb:IMPUESTO := 0
Else
   ::oDb:IMPUESTO := If( ::oDb:IMPUESTO == 0, oApl:oEmp:PIVA, ::oDb:IMPUESTO )
   nIva += ROUND( ::oDb:IMPUESTO / 100,2 )
   If MsgYesNo( "Precio con IVA incluido","I.V.A." )
      ::oDb:PVENTA := ROUND( ::oDb:PVENTA / nIva,2 )
      oGet[7]:Refresh()
   EndIf
EndIf
   ::oDb:PPUBLI   := ROUND( ::oDb:PVENTA * nIva,0 )
   oGet[5]:Refresh()
   oGet[8]:Refresh()
RETURN .t.

//------------------------------------//
METHOD Actuliza() CLASS TInv
   LOCAL aFor, cQry, hRes, nL, nPventa
If !MsgNoYes( "Actualizar los Precios","D E S E A" )
   RETURN NIL
EndIf
cQry := "SELECT Pnuevo, Impuesto, Indiva, Row_id "+;
        "FROM cadinven WHERE Ppubli <> Pnuevo"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
 oApl:oWnd:SetMsg( "Por Favor ESPERE estoy Actualizando"+ STR(nL,6) )
While nL > 0
   aFor := MyReadRow( hRes )
   AEval( aFor, { | xV,nP | aFor[nP] := MyClReadCol( hRes,nP ) } )
   If aFor[3] == 0
      aFor[2] := 0
      nPventa := aFor[1]
   Else
      aFor[2] := If( aFor[2] == 0, oApl:oEmp:PIVA, aFor[2] )
      nPventa := ROUND( aFor[1] / (1+aFor[2]/100),0 )
   EndIf
   cQry := "UPDATE cadinven SET "            +;
           "Pventa = " + LTRIM(STR(nPventa)) +;
         ", Ppubli = " + LTRIM(STR(aFor[1])) +;
         ", Impuesto = "+LTRIM(STR(aFor[2])) +;
          " WHERE row_id = " + LTRIM(STR(aFor[4]))
   MSQuery( oApl:oMySql:hConnect,cQry )
   nL --
EndDo
MSFreeResult( hRes )
MsgInfo( "Hecho los Cambios","LISTO" )
RETURN NIL

//------------------------------------//
METHOD Cambiarp() CLASS TInv
   LOCAL oDlg, oGet := ARRAY(5)
DEFINE DIALOG oDlg TITLE "CODIGO "+::oDb:CODIGO FROM 0, 0 TO 08,40
   @ 02,02 SAY oGet[1] VAR ::oDb:DESCRIP OF oDlg PIXEL SIZE 110,10;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 14,00 SAY "Precio Publico" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 14,62 SAY oGet[2] VAR ::oDb:PPUBLI OF oDlg PICTURE "999,999,999";
      SIZE 40,12 PIXEL
   @ 28,00 SAY "Precio Nuevo"   OF oDlg RIGHT PIXEL SIZE 60,10
   @ 28,62 GET oGet[3] VAR ::oDb:PNUEVO OF oDlg PICTURE "999,999,999";
      VALID {|| If( ::oDb:PNUEVO >  0, .t.                          ,;
        (MsgStop( "El Precio debe ser Mayor de 0","<< OJO >>" ), .f.)) };
      SIZE 40,12 PIXEL
   @ 46, 50 BUTTON oGet[4] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION ;
      (If( ::oDb:PNUEVO <= 0           ,;
         (MsgStop("Imposible grabar este Precio"), oGet[3]:SetFocus()),;
         ( ::Guardar( .f. ), ::oLbx:Refresh(), oDlg:End() ))) PIXEL
   @ 46,100 BUTTON oGet[5] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTER
RETURN NIL

//------------------------------------//
METHOD Listado() CLASS TInv
   LOCAL aLI, cQry, hRes, nL, oDPrn := TDosPrint()
oDPrn:New( oApl:cPuerto,oApl:cImpres,{"PRECIOS AL PUBLICO",NtChr( DATE(),"3" ),;
           " C O D I G O-  D E S C R I P C I O N----      PRECIO PUBLICO"},.t. )
aLI  := MsgYesNo( "Para Listar","LOS MARCADOS" )
cQry := "SELECT Codigo, Descrip, Ppubli FROM cadinven "+;
        If( aLI, "WHERE Listar = '1' ", "" )           +;
        "ORDER BY Codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aLI := MyReadRow( hRes )
   AEval( aLI, { | xV,nP | aLI[nP] := MyClReadCol( hRes,nP ) } )
      oDPrn:Titulo( 70 )
   If RIGHT( aLI[1],2 ) == "DP"
      oDPrn:nL++
      oDPrn:Say( oDPrn:nL,12,aLI[2] )
   Else
      oDPrn:Say( oDPrn:nL,03,aLI[1] )
      oDPrn:Say( oDPrn:nL,15,aLI[2] )
      oDPrn:Say( oDPrn:nL,46,TransForm(aLI[3],"999,999,999.99") )
   EndIf
      oDPrn:nL++
   nL --
EndDo
MSFreeResult( hRes )
oDPrn:NewPage()
oDPrn:End()
RETURN NIL
