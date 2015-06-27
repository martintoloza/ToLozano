// Programa.: JVMLINEA.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Creacion y Manto. de Activos.
#include "Fivewin.ch"
#include "Objects.ch"
#include "btnget.ch"

MEMVAR oApl

FUNCTION Activosf( cCla )
   LOCAL oAct := TAct()
 oAct:New( ,cCla )
 oAct:Activate()
 oAct:New( "FIN" )
RETURN NIL

//------------------------------------//
CLASS TAct FROM TNits
 DATA oCl, oNi

 METHOD NEW( oTB,cCla ) Constructor
 METHOD Mostrar( lAyuda,nOrd )
 METHOD Editar( xRec,lNuevo,lView )
 METHOD Listado()

ENDCLASS

//------------------------------------//
METHOD NEW( oTB,cCla ) CLASS TAct
   DEFAULT cCla := "A"
If oTB == NIL
   oTB := oApl:Abrir( "actfijos","nombre",.t.,,100 )
   Super:New( oTB )
   ::aOrden := { {"<None> ",1},{"Codigo" ,4},{"Nombre" ,5} }
   ::oCl    := TCat() ; ::oCl:New( ,1,cCla )
   ::oNi    := TNits(); ::oNi:New()
// ::xVar  := SPACE(12)
Else
   ::oDb:Destroy()
   ::oCl:oDb:Destroy()
EndIf
RETURN NIL

//------------------------------------//
METHOD Mostrar( lAyuda,nOrd ) CLASS TAct
   LOCAL oDlg, oM := Self
   LOCAL cTit := "Ayuda de Activos", bHacer, lReturn := NIL
   DEFAULT lAyuda := .t. , nOrd := 3
If lAyuda
   bHacer  := {||lReturn :=.t., oDlg:End()}
   lReturn := .f.
ELSE
   bHacer  := ::bEditar
   cTit    := "Código de Activos"
ENDIF
nOrd := ::Ordenar( nOrd )

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE cTit
   @ 1.5, 0 LISTBOX ::oLbx FIELDS ;
         TRANSFORM( ::oDb:CODIGO,"9999999999"),;
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
    ::oLbx:aColSizes   := {60,240}
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
METHOD Editar(xRec,lNuevo,lView) CLASS TAct
   LOCAL oDlg, oGet := ARRAY(10), oE := Self
   LOCAL aEd := { ::oDb:Recno(),"Nuevo Código",.f.,"","",0,"" }
   DEFAULT lNuevo := .t. , lView  := .f.
If lNuevo
   ::oDb:xBlank()
   ::oDb:Read()
Else
   aEd[2] := If( lView, "Viendo", "Modificando" ) + " Código"
EndIf
 ::oCl:oDb:Seek( { "clase_id",::oDb:CLASE_ID } )
 aEd[4] := ::oCl:oDb:GRUPO
 aEd[5] := ::oCl:oDb:NOMBRE
 Nitsx( ::oDb:CODIGO_NIT,@aEd,6,7 )

DEFINE DIALOG oDlg TITLE aEd[2] FROM 0, 0 TO 25,70
   @ 02,00 SAY "Grupo Activo" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 02,52 BTNGET oGet[1] VAR aEd[4] OF oDlg PICTURE "9999"             ;
      ACTION EVAL({|| If( oE:oCl:Mostrag(), (aEd[4] := oE:oCl:oDb:GRUPO,;
                          oGet[1]:Refresh() ),) })                      ;
      VALID EVAL( {|| If( NtChr( aEd[4] ) < 4                          ,;
                        ( MsgStop("Grupo debe tener 4 Digitos"),.f.)   ,;
                     (If( oE:oCl:oDb:Seek( { "grupo",aEd[4] } )        ,;
                        ( ::oDb:CLASE_ID   := oE:oCl:oDb:CLASE_ID      ,;
                          oGet[2]:Settext(oE:oCl:oDb:NOMBRE), .t. )    ,;
                        (MsgStop("Este Grupo no Existe"), .f.) )))} )   ;
      SIZE 36,10 PIXEL RESOURCE "BUSCAR" ;
      WHEN lNuevo
   @ 02,100 SAY oGet[2] VAR aEd[5] OF oDlg PIXEL SIZE 130,10 UPDATE
   // UPDATE COLOR nRGB( 128,0,255 )
   @ 14,00 SAY "Nit Proveedor" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 14,52 BTNGET oGet[3] VAR aEd[6] OF oDlg PICTURE "999999999999"     ;
      ACTION EVAL({|| If(oE:oNi:Mostrar(), (aEd[6] := oE:oNi:oDb:CODIGO,;
                         oGet[3]:Refresh() ), ) })                      ;
      VALID EVAL( {|| If( oE:oNi:Buscar( aEd[6],,.t. )                 ,;
                        ( ::oDb:CODIGO_NIT := oE:oNi:oDb:CODIGO_NIT    ,;
                          oGet[4]:Settext( oE:oNi:oDb:NOMBRE ), .t. )  ,;
                 (If( MsgYesNo("Desea ingresarlo","Este Nit no Existe"),;
                      oE:oNi:Editar( ,.t.,,aEd[6] ), ),.f.) ) } )       ;
      SIZE 44,10 PIXEL RESOURCE "BUSCAR"
   @ 14,100 SAY oGet[4] VAR aEd[7] OF oDlg PIXEL SIZE 130,10 UPDATE
   @ 26,00 SAY "Nombre"    OF oDlg RIGHT PIXEL SIZE 50,10
   @ 26,52 GET oGet[5] VAR ::oDb:NOMBRE  OF oDlg PICTURE "@!";
      SIZE 120,10 PIXEL
   @ 38,00 SAY "Marca"     OF oDlg RIGHT PIXEL SIZE 50,10
   @ 38,52 GET oGet[6] VAR ::oDb:MARCA   OF oDlg PICTURE "@!";
      SIZE 120,10 PIXEL
   @ 50,00 SAY "Modelo"    OF oDlg RIGHT PIXEL SIZE 50,10
   @ 50,52 GET oGet[7] VAR ::oDb:MODELO  OF oDlg PICTURE "@!";
      SIZE 120,10 PIXEL
   @ 62,00 SAY "Serial"    OF oDlg RIGHT PIXEL SIZE 50,10
   @ 62,52 GET oGet[8] VAR ::oDb:SERIAL  OF oDlg PICTURE "@!";
      SIZE 120,10 PIXEL

   @ 76, 60 BUTTON oGet[09] PROMPT "&Grabar"   SIZE 44,12 OF oDlg ACTION;
      (If( EMPTY(::oDb:CODIGO_NIT) .OR. EMPTY(::oDb:NOMBRE),;
         (MsgStop("No se puede grabar este Activo, debe completar datos"),;
          oGet[1]:SetFocus()), (aEd[3] := .t.,oDlg:End()) )) PIXEL
   @ 76,110 BUTTON oGet[10] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
/*
   IF lView                     // Solo Consulta
      DesactivaALLGET(oGet)
      oGet[09]:Disable()
      oGet[10]:Enable()
      oGet[10]:SetFocus()
   ENDIF
*/
ACTIVATE DIALOG oDlg CENTER

If aEd[3]
   If lNuevo
      ::oCl:oDb:CONSE ++
      ::oCl:oDb:Update(.t.,1)
      ::oDb:CODIGO := aEd[4] + STRZERO( ::oCl:oDb:CONSE,6 )
   EndIf
   ::Guardar( lNuevo )
   aEd[1] := ::oDb:Recno()
EndIf
::oDb:Go( aEd[1] ):Read()

RETURN NIL

/*
 CREATE TABLE "PRUEBA"."ACTIVOS"
   (	"CODIGO_EMP" NUMBER(3,0),
	"CODIGO" NUMBER(6,0),
	"NOMBRE" VARCHAR2(60 BYTE),
	"MARCA" VARCHAR2(20 BYTE),
	"MODELO" VARCHAR2(20 BYTE),
	"SERIAL" VARCHAR2(20 BYTE),
	"CODIGO_CLA" NUMBER(6,0),
	"CODIGO_UBI" NUMBER(6,0),
	"CODIGO_USU" NUMBER(6,0),
	"CODIGO_EST" NUMBER(2,0),
	"CODIGO_PRV" NUMBER(6,0),
	"CODIGO_PRINC" NUMBER(6,0),
	"COSTO_HIS" NUMBER(18,2),
	"FECHA_ADQ" DATE,
	"DEPRECIA_COS" NUMBER(18,2),
	"COSTO_ATR" NUMBER(18,2),
	"FECHA_ATR" DATE,
	"DEPRECIA_ATR" NUMBER(18,2),
	"VALOR_RAZ" NUMBER(18,2),
	"FECHA_RAZ" DATE,
	"DEPRECIA_RAZ" NUMBER(18,2),
	"SALVAMENTO" NUMBER(18,8),
	"FECHA_SALV" DATE,
	"DETERIORO" NUMBER(18,2),
	"VIDA_UTIL" NUMBER(3,0),
	"CANTIDAD" NUMBER(5,0),
	"PTAJE_DEPRECIA" NUMBER(5,2),
	"VALOR_SALIDA" NUMBER(18,2),
	"FECHA_SALIDA" DATE,
	"TIPO_DEPRECIA" NUMBER(2,0),
	"DEPRECIA_COS_IFRS" NUMBER(18,2),
	"FECHA_COS_IFRS" DATE,
	"VIDA_UTIL_IFRS" NUMBER(3,0),
	"PTAJE_DEPRECIA_IFRS" NUMBER(5,2),
	"TIPO_DEPRECIA_IFRS" NUMBER(2,0),
	"PLACA" VARCHAR2(10 BYTE),
	"OBSERVACIONES" VARCHAR2(250 BYTE),
	"FECHA_DEP" DATE,
	"CODIGO_CAT" NUMBER(6,0),
	"AVALUO_TEC" NUMBER(18,2),
	"VERSION" NUMBER(20,0) DEFAULT 0,
	"CODIGO_GRU" NUMBER(6,0)
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "CONTABILIDAD" ;
*/

//------------------------------------//
METHOD Listado() CLASS TAct
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