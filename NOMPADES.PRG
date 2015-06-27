// Programa.: NOMTABLA.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Creacion y Manto. de Descuentos Fijos
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

PROCEDURE NomPaDes()
   LOCAL oDlg, oGet := ARRAY(20)
   LOCAL aCon, oPad, oCn := TCon()
aCon := { "", .t. ,;
          {|| aCon[2] := .t. , oPad:Read(), oPad:xLoad()  ,;
              aCon[1] := Buscar({"concepto",oPad:CONCEPTO},;
                                 "nomconce","nombre",8) } }
oCn:New()
oPad := oApl:Abrir( "nompades","concepto",.t. )
oPad:GoTop()
EVAL( aCon[3] )
DEFINE DIALOG oDlg TITLE "PAGOS Y DESCUENTOS FIJOS" FROM 0, 0 TO 17,50
//   OF oApl:oWnd
   @ 02, 70 SAY oGet[01] VAR oPad:EMPRESA  OF oDlg SIZE 20,10 PIXEL UPDATE
   @ 14, 00 SAY "Concepto" OF oDlg RIGHT PIXEL SIZE 68,10
   @ 14, 70 BTNGET oGet[2] VAR oPad:CONCEPTO OF oDlg PICTURE "999";
      VALID If( oApl:oCon:Seek( {"Concepto",oPad:CONCEPTO} )     ,;
              ( aCon[1] := oApl:oCon:NOMBRE, oDlg:Update(), .t. ),;
              ( MsgStop( "Este Concepto NO EXISTE !!!" ), .f. ))  ;
      SIZE 34,12 PIXEL UPDATE  RESOURCE "BUSCAR"                  ;
      ACTION Eval({|| If(oCn:Mostrar(), (oPad:CONCEPTO := oCn:oDb:CONCEPTO,;
                        oGet[2]:Refresh(), oGet[2]:lValid(.f.)),)})
   @ 14,110 SAY oGet[03] VAR aCon[1] OF oDlg SIZE 98,10 PIXEL UPDATE
   @ 26, 00 SAY "Periodo Pago" OF oDlg RIGHT PIXEL SIZE 68,10
   @ 26, 70 GET oGet[04] VAR oPad:PERPAG   OF oDlg PICTURE "9";
      VALID Rango( oPad:PERPAG,1,2 )    SIZE 10,10 PIXEL UPDATE;
      MESSAGE "1_Roll, 2_Quincena"
   @ 38, 00 SAY "Valor Novedad" OF oDlg RIGHT PIXEL SIZE 68,10
   @ 38, 70 GET oGet[05] VAR oPad:VALORNOV OF oDlg PICTURE "999,999,999";
     SIZE 40,10 PIXEL UPDATE
   @ 50, 00 SAY "Forma Liquida" OF oDlg RIGHT PIXEL SIZE 68,10
   @ 50, 70 GET oGet[06] VAR oPad:FORMALIQ OF oDlg PICTURE "9";
      VALID Rango( oPad:FORMALIQ,1,3 )  SIZE 10,10 PIXEL UPDATE;
      MESSAGE "1_Valor, 2_Cantidad, 3_Porcentaje"
   @  62,00 SAY "Fecha Desde" OF oDlg RIGHT PIXEL SIZE 68,10
   @  62,70 GET oGet[07] VAR oPad:FECHADES OF oDlg SIZE 40,10 PIXEL UPDATE
   @  74,70 CHECKBOX oGet[08] VAR oPad:AUTOMATICA PROMPT "Automatica" OF oDlg ;
      SIZE 60,10 PIXEL UPDATE
   @  86,00 SAY "Basico Promedio" OF oDlg RIGHT PIXEL SIZE 68,10
   @  86,70 GET oGet[09] VAR oPad:BASPROM OF oDlg PICTURE "@!" ;
      VALID Rango( oPad:BASPROM,{"B","P"} ) SIZE 10,10 PIXEL UPDATE;
      MESSAGE "B_Basico, P_Promedio"
   @  98,70 CHECKBOX oGet[10] VAR oPad:PERMANENTE PROMPT "Permanente" OF oDlg ;
      SIZE 60,10 PIXEL UPDATE

   @ 112, 01 BUTTON oGet[11] PROMPT "..." OF oDlg PIXEL SIZE 14,10
   @ 112, 16 BUTTON oGet[12] PROMPT "<<"  OF oDlg PIXEL SIZE 14,10;
      ACTION ( oPad:GoTop(), EVAL( aCon[3] ), oDlg:Update() )
   @ 112, 31 BUTTON oGet[13] PROMPT "<"   OF oDlg PIXEL SIZE 14,10;
     ACTION ( oPad:Skip(-1), EVAL( aCon[3] ), oDlg:Update() )
   @ 112, 46 BUTTON oGet[14] PROMPT ">"   OF oDlg PIXEL SIZE 14,10;
     ACTION ( oPad:Skip( 1), EVAL( aCon[3] ), oDlg:Update() )
   @ 112, 61 BUTTON oGet[15] PROMPT ">>"  OF oDlg PIXEL SIZE 14,10;
     ACTION ( oPad:GoBottom(), EVAL( aCon[3] ), oDlg:Update() )
   @ 112, 76 BUTTON oGet[16] PROMPT " + " OF oDlg PIXEL SIZE 14,10;
	    ACTION ( oPad:xBlank(), oDlg:Update(), aCon[2] := .f.,;
		     oGet[ 2 ]:Enable(), oGet[ 2 ]:SetFocus() )
   @ 112, 91 BUTTON oGet[17] PROMPT " X " OF oDlg PIXEL SIZE 14,10;
      ACTION ( If( MsgNoYes( "Este Concepto"+STR(oPad:CONCEPTO),"Elimina" ),;
                 ( oPad:Delete(), oPad:Top(), oDlg:Update() ), ) )
   @ 112,106 BUTTON oGet[18] PROMPT " C " OF oDlg PIXEL SIZE 14,10;
	    ACTION ( oPad:Top(), oDlg:Update(), aCon[2] := .t. )
   @ 112,121 BUTTON oGet[19] PROMPT "Grabar" OF oDlg PIXEL SIZE 24,10;
            ACTION ( If( aCon[2], oPad:Update(.t.,1),;
                       (oPad:EMPRESA := oApl:nEmpresa, oPad:Append(.t.)) ),;
		     aCon[2] := .t. )
   @ 112,146 BUTTON oGet[20 ] PROMPT "Salir"  OF oDlg PIXEL SIZE 24,10;
     CANCEL ACTION ( oDlg:End() )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTER ON INIT;
   ( oGet[11]:cToolTip := "Buscar"            ,;
     oGet[12]:cToolTip := "Primer Registro"   ,;
     oGet[13]:cToolTip := "Registro Anterior" ,;
     oGet[14]:cToolTip := "Registro Siguiente",;
     oGet[15]:cToolTip := "Ultimo Registro"   ,;
     oGet[16]:cToolTip := "Nuevo Registro"    ,;
     oGet[17]:cToolTip := "Borrar Registro"   ,;
     oGet[18]:cToolTip := "Cancelar Cambios"   )
oPad:Destroy()
RETURN

//------------------------------------//
PROCEDURE NomDesFi()
   LOCAL oDlg, oLbx, oGet := ARRAY(4)
   LOCAL aBar, aDef := { 0,"",25,"" }, oCn, oDef, oEp
aBar := { {|| Insertar( aDef,oDef,oLbx,.t. ) }, {|| Insertar( aDef,oDef,oLbx,.f. ) },;
          {|| .t. }                           , {|| DelRecord( oDef,oLbx,.t. ) },;
          {|| .t. }                           , {|| oDlg:End() } }
oDef := oApl:Abrir( "nomdesfi","empresa, codigo, concepto",,,30 )
oDef:Seek( { "empresa",oApl:nEmpresa,"codigo",aDef[1],"anomes >= ","199401" },"anomes DESC" )
oEp  := TEpl() ; oEp:New()
oCn  := TCon() ; oCn:New()

DEFINE DIALOG oDlg FROM 0, 0 TO 300,560 PIXEL;
   TITLE "MANTENIMIENTO DE DESCUENTOS FIJOS"
   @ 16, 00 SAY "Nota Credito" OF oDlg RIGHT PIXEL SIZE 52,10
   @ 16, 00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 50,10
   @ 16, 52 BTNGET oGet[1] VAR aDef[1]   OF oDlg PICTURE "99999" ;
      VALID If( oEp:oDb:Seek( {"empresa",oApl:nEmpresa,"codigo" ,;
                               aDef[1]} )                       ,;
              ( aDef[2] := oEp:oDb:NOMBRE, oDlg:Update(), .t. ) ,;
              ( MsgStop( "Este Empleado NO EXISTE !!!" ), .f. )) ;
      SIZE 40,10 PIXEL  RESOURCE "BUSCAR"                        ;
      ACTION EVAL({|| If(oEp:Mostrar(), (aDef[1] := oEp:oDb:CODIGO,;
                         oGet[1]:Refresh() ), ) })
   @ 16,100 SAY oGet[2] VAR aDef[2] OF oDlg PIXEL SIZE 130,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 30, 00 SAY "Concepto" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 30, 52 BTNGET oGet[3] VAR aDef[3]   OF oDlg PICTURE "999"       ;
      VALID If( oCn:oDb:Seek( {"concepto",aDef[3]} )                ,;
              ( oDef:Seek( {"empresa",oApl:nEmpresa,"codigo",aDef[1],;
                            "concepto",aDef[3] },"anomes DESC" )    ,;
                aDef[4] := oCn:oDb:NOMBRE, oLbx:Refresh()           ,;
                oDlg:Update(), oLbx:GoTop(), oGet[3]:oJump := oLbx, .t. ),;
              ( MsgStop( "Este Concepto NO EXISTE !!!" ), .f. ) )    ;
      SIZE 40,10 PIXEL  RESOURCE "BUSCAR"                            ;
      ACTION EVAL({|| If(oCn:Mostrar(), (aDef[3] := oCn:oDb:CONCEPTO,;
                         oGet[3]:Refresh() ), ) })
   @ 30,100 SAY oGet[4] VAR aDef[4] OF oDlg SIZE 98,10 PIXEL UPDATE

   @ 50,30 LISTBOX oLbx FIELDS oDef:ANOMES                   ,;
                    TRANSFORM( oDef:SALDOACT ,"999,999,999" ),;
                    TRANSFORM( oDef:CUOTADESC,"999,999,999" ) ;
      HEADERS "Periodo", "Saldo"+CRLF+"Actual",;
              "Cuota"+CRLF+"Descuento" ;
      SIZES 400, 450 SIZE 160,86  ;
      OF oDlg UPDATE PIXEL
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:nHeaderHeight := 28
    oLbx:GoTop()
    oLbx:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:aColSizes   := {70,120,120}
    oLbx:aHjustify   := {2,2,2}
    oLbx:aJustify    := {0,1,1}
    oLbx:ladjbrowse  := oLbx:lCellStyle  := .f.
    oLbx:ladjlastcol := .t.
    oLbx:bKeyDown := {|nKey| If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(aBar[1]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, EVAL(aBar[2]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE             , EVAL(aBar[4]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=80 .OR. nKey=VK_F3    , EVAL(aBar[5]),) ))) }
   MySetBrowse( oLbx,oDef )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTER ON INIT (DefineBar( oDlg,oLbx,aBar ))
oDef:Destroy()
oEp:Cerrar()
oCn:Cerrar()
RETURN


//------------------------------------//
STATIC PROCEDURE Insertar( aDef,oDef,oLbx,lNew )
   LOCAL oDlg, oGet := ARRAY(15)
   LOCAL aED := { .f.,"Modificando Saldo","999,999,999" }
If !oApl:lEnLinea .AND. oLbx # NIL
   If lNew
      aED[2] := "Nuevo Saldo"
      oDef:xBlank()
      oDef:Read()
      oDef:EMPRESA  := oApl:nEmpresa ; oDef:CODIGO := aDef[1]
      oDef:CONCEPTO := aDef[3]
      oDef:ANOMES   := oApl:cPer + If( DAY(oApl:dFec) >= 16, "2", "1" )
   Else
      oDef:xLoad()
   EndIf
EndIf

DEFINE DIALOG oDlg TITLE aED[2] FROM 0, 0 TO 20,44
   @  02, 30 SAY oGet[01] VAR aDef[2] OF oDlg PIXEL SIZE 130,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @  14, 30 SAY oGet[02] VAR aDef[4] OF oDlg SIZE 98,10 PIXEL
   @  26, 00 SAY "Periodo"  OF oDlg RIGHT PIXEL SIZE 50,10
   @  26, 52 GET oGet[03] VAR oDef:ANOMES  OF oDlg PICTURE "9999999" SIZE 32,10 PIXEL;
      VALID NtChr( LEFT(oDef:ANOMES,6),"P" )
   @  38, 00 SAY "Valor Inicial" OF oDlg RIGHT PIXEL SIZE 50,10
   @  38, 52 GET oGet[04] VAR oDef:VALORINIC  OF oDlg PICTURE aED[3];
      SIZE 40,10 PIXEL
   @  50, 00 SAY "Saldo Actual" OF oDlg RIGHT PIXEL SIZE 50,10
   @  50, 52 GET oGet[05] VAR oDef:SALDOACT   OF oDlg PICTURE aED[3];
      SIZE 40,10 PIXEL
   @  62, 00 SAY "Cuota Dscto." OF oDlg RIGHT PIXEL SIZE 50,10
   @  62, 52 GET oGet[06] VAR oDef:CUOTADESC  OF oDlg PICTURE aED[3];
      SIZE 40,10 PIXEL
   @  62,100 CHECKBOX oGet[07] VAR oDef:ACUMULAR PROMPT "Llevar Acumulado" OF oDlg ;
      SIZE 60,10 PIXEL
   @  74, 00 SAY "Valor Cargo" OF oDlg RIGHT PIXEL SIZE 50,10
   @  74, 52 GET oGet[08] VAR oDef:VALORCARGO OF oDlg PICTURE aED[3];
      SIZE 40,10 PIXEL
   @  86, 00 SAY "Fecha Inicial" OF oDlg RIGHT PIXEL SIZE 50,10
   @  86, 52 GET oGet[09] VAR oDef:FECHAINIC  OF oDlg SIZE 40,10 PIXEL
   @  98, 00 SAY "Tipo Dscto." OF oDlg RIGHT PIXEL SIZE 50,10
   @  98, 52 GET oGet[10] VAR oDef:TIPODESC OF oDlg PICTURE "!";
      VALID Rango( oDef:TIPODESC,{"P","V"} ) SIZE 10,10 PIXEL  ;
      MESSAGE "P_Porcentaje, V_Valor"
   @ 110, 00 SAY "Forma Dscto." OF oDlg RIGHT PIXEL SIZE 50,10
   @ 110, 52 GET oGet[11] VAR oDef:FORMADESC OF oDlg PICTURE "9";
      VALID Rango( oDef:FORMADESC,0,2 )  SIZE 10,10 PIXEL       ;
      MESSAGE "0_Cada vez que paguen, 1_Primer Pago, 2_Segundo Pago"
   @ 110,100 CHECKBOX oGet[12] VAR oDef:HACERDESC PROMPT "Hacer Dscto." OF oDlg ;
      SIZE 60,10 PIXEL
   @ 122, 00 SAY "Fecha Cpbte" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 122, 52 GET oGet[13] VAR oDef:FECHACOMP  OF oDlg SIZE 40,10 PIXEL

   @ 136, 60 BUTTON oGet[14] PROMPT "Grabar"   SIZE 30,12 OF oDlg ACTION ;
      (If( EMPTY(oDef:ANOMES) .OR. oDef:CUOTADESC <= 0                  ,;
         ( MsgStop("Imposible grabar este Código"), oGet[1]:SetFocus() ),;
         ( aEd[1] := .t., oDlg:End() ))) PIXEL
   @ 136, 94 BUTTON oGet[15] PROMPT "Salir"  OF oDlg PIXEL SIZE 30,12 CANCEL;
     ACTION oDlg:End()
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTER ON INIT;
   ( oGet[10]:cToolTip := "P_Porcentaje, V_Valor",;
     oGet[11]:cToolTip := "0_Cada vez que paguen, 1_Primer Pago, 2_Segundo Pago" )
If aEd[1]
   If lNew
      oDef:Append()
      oLbx:Refresh()
   Else
      oDef:Update(.t.,1)
   EndIf
EndIf
RETURN
