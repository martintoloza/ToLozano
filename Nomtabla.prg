// Programa.: NOMTABLA.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Mantenimiento Tabla de los Datos Fijos.
#include "FiveWin.ch"

MEMVAR oApl

PROCEDURE NomTaIss()
   LOCAL aBarra, oDlg, oLbx
aBarra := { {|| ValoresG( oLbx,.t. ) }, {|| ValoresG( oLbx,.f. ) },;
            {|| .t. }                 , {|| DelRecord( oApl:oFis,oLbx,.t. ) },;
            {|| .t. }                 , {|| oDlg:End() } }
oApl:oFis:Seek( { "issfami","F" },"periodoi DESC" )
DEFINE DIALOG oDlg TITLE "Valores Generales" FROM 0, 0 TO 240, 580 PIXEL
   @ 20,04 LISTBOX oLbx FIELDS oApl:oFis:PERIODOI         ,;
                               oApl:oFis:PERIODOF         ,;
                    TRANSFORM( oApl:oFis:SALARIOMIN,"999,999,999" ),;
                    TRANSFORM( oApl:oFis:TRANSPORTE,"999,999,999" ),;
                    TRANSFORM( oApl:oFis:EPS_EMP,"999.999" ),;
                    TRANSFORM( oApl:oFis:EPS_TRA,"999.999" ) ;
      HEADERS "Periodo"+CRLF+"Inicial", "Periodo" +CRLF+"Final",;
              "Salario"+CRLF+"Minimo" , "Auxilio" +CRLF+"Transporte",;
              "E.P.S." +CRLF+"Empleador", "E.P.S."+CRLF+"Trabajador" ;
      SIZES 400, 450 SIZE 280,86  ;
      OF oDlg UPDATE PIXEL
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:nHeaderHeight := 28
    oLbx:GoTop()
    oLbx:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:aColSizes   := {80,80,90,90,70,70}
    oLbx:aHjustify   := {2,2,2,2,2,2}
    oLbx:aJustify    := {0,0,1,1,1,2}
    oLbx:ladjbrowse  := oLbx:lCellStyle := .f.
    oLbx:ladjlastcol := .t.
    oLbx:bKeyDown := {|nKey| If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(aBarra[1]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, EVAL(aBarra[2]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE             , EVAL(aBarra[4]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=80 .OR. nKey=VK_F3    , EVAL(aBarra[5]),) ))) }
   MySetBrowse( oLbx,oApl:oFis )
ACTIVATE DIALOG oDlg CENTER ON INIT ;
  (DefineBar( oDlg,oLbx,aBarra,02,18 ))
RETURN

//------------------------------------//
PROCEDURE ValoresG( oLbx,lNuevo )
   LOCAL aEd := { "Modificando Valores",.f.,0,0 }
   LOCAL oDlg, oGet := ARRAY(25)
If lNuevo
   oLbx:GoTop()
   aEd := ACLONE( oApl:oFis:axBuffer )
   aEd[3] := STR( VAL(aEd[3])+100,6 )
   aEd[4] := STR( VAL(aEd[4])+100,6 )
   oApl:oFis:xBlank()
   AEVAL( aEd, { |x,p| oApl:oFis:axBuffer[p] := x },2 )
   aEd := { "Nuevos Valores",.f.,0,0 }
EndIf
aEd[3] := oApl:oFis:AFP_EMP + oApl:oFis:AFP_TRA
aEd[4] := oApl:oFis:EPS_EMP + oApl:oFis:EPS_TRA
DEFINE DIALOG oDlg FROM 0, 0 TO 350, 560 PIXEL TITLE aEd[1]
   @  02, 00 Say "Periodo Inicial"  OF oDlg RIGHT PIXEL SIZE 60,10
   @  02, 62 GET oGet[01] VAR oApl:oFis:PERIODOI OF oDlg PICTURE "999999";
      VALID NtChr( oApl:oFis:PERIODOI,"P" )  SIZE 30,10 PIXEL
   @  02,100 Say "Periodo Final"    OF oDlg RIGHT PIXEL SIZE 60,10
   @  02,162 GET oGet[02] VAR oApl:oFis:PERIODOF OF oDlg PICTURE "999999";
      VALID NtChr( oApl:oFis:PERIODOF,"P" )  SIZE 30,10 PIXEL
   @  14, 00 SAY "Valores A.F.P."   OF oDlg RIGHT PIXEL SIZE 60,10;
      COLOR nRGB( 128,0,255 )
   @  26, 00 SAY "% Empleador"      OF oDlg RIGHT PIXEL SIZE 40,10
   @  26, 42 GET oGet[03] VAR oApl:oFis:AFP_EMP OF oDlg PICTURE "999.999"        ;
      VALID (aEd[3] := oApl:oFis:AFP_EMP + oApl:oFis:AFP_TRA, oDlg:Update(), .t.);
      SIZE 28,10 PIXEL
   @  38, 00 SAY "% Trabajador"     OF oDlg RIGHT PIXEL SIZE 40,10
   @  38, 42 GET oGet[04] VAR oApl:oFis:AFP_TRA OF oDlg PICTURE "999.999"        ;
      VALID (aEd[3] := oApl:oFis:AFP_EMP + oApl:oFis:AFP_TRA, oDlg:Update(), .t.);
      SIZE 28,10 PIXEL
   @  50, 00 SAY "% Total"          OF oDlg RIGHT PIXEL SIZE 40,10
   @  50, 42 SAY aEd[3]             OF oDlg       PIXEL SIZE 28,10;
      PICTURE "999.999" UPDATE
   @  26, 72 SAY "% Fondo"          OF oDlg RIGHT PIXEL SIZE 42,10
   @  26,116 GET oGet[05] VAR oApl:oFis:AFP_FON OF oDlg PICTURE "999.999" SIZE 28,10 PIXEL
   @  38, 72 SAY "# Mínimos F.S.P." OF oDlg RIGHT PIXEL SIZE 42,10
   @  38,116 GET oGet[06] VAR oApl:oFis:FSP_MIN OF oDlg PICTURE "999.999" SIZE 28,10 PIXEL
   @  14,166 Say "Valores E.P.S."   OF oDlg RIGHT PIXEL SIZE 60,10;
      COLOR nRGB( 128,0,255 )
   @  26,146 SAY "% Empleador"      OF oDlg RIGHT PIXEL SIZE 40,10
   @  26,188 GET oGet[07] VAR oApl:oFis:EPS_EMP OF oDlg PICTURE "999.999"        ;
      VALID (aEd[4] := oApl:oFis:EPS_EMP + oApl:oFis:EPS_TRA, oDlg:Update(), .t.);
      SIZE 28,10 PIXEL
   @  38,146 SAY "% Trabajador"     OF oDlg RIGHT PIXEL SIZE 40,10
   @  38,188 GET oGet[08] VAR oApl:oFis:EPS_TRA OF oDlg PICTURE "999.999"        ;
      VALID (aEd[4] := oApl:oFis:EPS_EMP + oApl:oFis:EPS_TRA, oDlg:Update(), .t.);
      SIZE 28,10 PIXEL
   @  50,146 SAY "% Total"          OF oDlg RIGHT PIXEL SIZE 40,10
   @  50,188 SAY aEd[4]             OF oDlg       PIXEL SIZE 28,10;
      PICTURE "999.999" UPDATE
   @  26,218 SAY "% Fondo"          OF oDlg RIGHT PIXEL SIZE 24,10
   @  26,246 GET oGet[09] VAR oApl:oFis:FSP_FON OF oDlg PICTURE "999.999" SIZE 28,10 PIXEL

   @  62, 00 Say "Valores Parafiscales" OF oDlg RIGHT PIXEL SIZE 60,10;
      COLOR nRGB( 128,0,255 )
   @  74, 00 SAY "% Caja SENA"      OF oDlg RIGHT PIXEL SIZE 40,10
   @  74, 42 GET oGet[10] VAR oApl:oFis:SENA    OF oDlg PICTURE "999.999" SIZE 28,10 PIXEL
   @  86, 00 SAY "% Caja ICBF"      OF oDlg RIGHT PIXEL SIZE 40,10
   @  86, 42 GET oGet[11] VAR oApl:oFis:ICBF    OF oDlg PICTURE "999.999" SIZE 28,10 PIXEL
   @  86, 72 SAY "% Compensación"   OF oDlg RIGHT PIXEL SIZE 42,10
   @  86,116 GET oGet[12] VAR oApl:oFis:CAJA    OF oDlg PICTURE "999.999" SIZE 28,10 PIXEL
   @  62,146 Say "Valores A.R.P."   OF oDlg RIGHT PIXEL SIZE 60,10;
      COLOR nRGB( 128,0,255 )
   @  74,146 SAY "% Fondo"          OF oDlg RIGHT PIXEL SIZE 40,10
   @  74,188 GET oGet[13] VAR oApl:oFis:ARP_FON OF oDlg PICTURE "999.999" SIZE 28,10 PIXEL
   @  98, 00 Say "Valores Generales" OF oDlg RIGHT PIXEL SIZE 60,10;
      COLOR nRGB( 128,0,255 )
   @ 110, 00 SAY "Salario Minimo"    OF oDlg RIGHT PIXEL SIZE 40,10
   @ 110, 42 GET oGet[14] VAR oApl:oFis:SALARIOMIN OF oDlg PICTURE "99,999,999.99";
     SIZE 44,10 PIXEL
   @ 110, 96 SAY "Auxilio Transporte" OF oDlg RIGHT PIXEL SIZE 42,10
   @ 110,140 GET oGet[15] VAR oApl:oFis:TRANSPORTE OF oDlg PICTURE "99,999,999.99";
     SIZE 44,10 PIXEL
   @ 110,198 SAY "% I.V.A." OF oDlg RIGHT PIXEL SIZE 24,10
   @ 110,226 GET oGet[16] VAR oApl:oFis:PIVA OF oDlg PICTURE "999.99";
     SIZE 28,10 PIXEL
   @ 122, 00 SAY "Tope Retención"    OF oDlg RIGHT PIXEL SIZE 40,10
   @ 122, 42 GET oGet[17] VAR oApl:oFis:TOPERET    OF oDlg PICTURE "99,999,999";
     SIZE 44,10 PIXEL
   @ 122, 96 SAY "% Ret.Fuente"     OF oDlg RIGHT PIXEL SIZE 40,10
   @ 122,140 GET oGet[18] VAR oApl:oFis:RETFTE  OF oDlg PICTURE "999.99" SIZE 28,10 PIXEL
   @ 122,194 SAY "% Ret.IVA"        OF oDlg RIGHT PIXEL SIZE 30,10
   @ 122,226 GET oGet[19] VAR oApl:oFis:RETIVA  OF oDlg PICTURE "999.99" SIZE 28,10 PIXEL
   @ 134,194 SAY "% Ret.ICA"        OF oDlg RIGHT PIXEL SIZE 30,10
   @ 134,226 GET oGet[20] VAR oApl:oFis:RETICA  OF oDlg PICTURE "999.99" SIZE 28,10 PIXEL
   @ 134,256 SAY "x Mil"            OF oDlg PIXEL SIZE 18,10
   @ 134, 00 Say "Ptaje para las Tarjetas" OF oDlg RIGHT PIXEL SIZE 60,10;
      COLOR nRGB( 128,0,255 )
   @ 146, 00 SAY "%T. Ret.IVA"      OF oDlg RIGHT PIXEL SIZE 40,10
   @ 146, 42 GET oGet[21] VAR oApl:oFis:IVA2      OF oDlg PICTURE "999.99" SIZE 28,10 PIXEL
   @ 146, 96 SAY "%T. Ret.Fuente"   OF oDlg RIGHT PIXEL SIZE 40,10
   @ 146,140 GET oGet[22] VAR oApl:oFis:RET2    OF oDlg PICTURE "999.99" SIZE 28,10 PIXEL
   @ 146,194 SAY "%T. Ret.ICA"      OF oDlg RIGHT PIXEL SIZE 30,10
   @ 146,226 GET oGet[23] VAR oApl:oFis:ICA2    OF oDlg PICTURE "999.99" SIZE 28,10 PIXEL
   @ 146,256 SAY "x Mil"            OF oDlg PIXEL SIZE 18,10

   @ 160, 50 BUTTON oGet[24] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION ;
      (If( EMPTY(oApl:oFis:PERIODOI) .OR. EMPTY(oApl:oFis:PERIODOF),;
         (MsgStop("No se puede grabar este Registro, debe completar datos"),;
          oGet[1]:SetFocus()), (aEd[2] := .t., oDlg:End()) )) PIXEL
   @ 160,100 BUTTON oGet[25] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTER
If aEd[2]
   If lNuevo
      oApl:oFis:Append(.t.)
      oApl:oFis:Seek( { "issfami","F" },"periodoi DESC" )
      oLbx:Refresh()
      oLbx:GoTop()
   Else
      oApl:oFis:Update(.t.,1)
   EndIf
   oLbx:Refresh()
EndIf
RETURN

//------------------------------------//
PROCEDURE NomReten()
   LOCAL aBarra, oDlg, oLbx, oRet
aBarra := { {|| ValoresR( oRet,oLbx,.t. ) }, {|| ValoresR( oRet,oLbx,.f. ) },;
            {|| .t. }                      , {|| DelRecord( oRet,oLbx,.t.) },;
            {|| .t. }                      , {|| oDlg:End() } }
oRet := oApl:Abrir( "nomreten","valormen",.t. )
oRet:Seek( { "valormen >= ",0 },"valormen" )
DEFINE DIALOG oDlg TITLE "TABLA DE RETENCIONES" FROM 0, 0 TO 240,400 PIXEL
   @ 20,04 LISTBOX oLbx FIELDS ;
           TRANSFORM( oRet:VALORMEN,"999,999,999.99" ),;
           TRANSFORM( oRet:VALORMAY,"999,999,999.99" ),;
           TRANSFORM( oRet:VALORRET,"999,999,999.99" ),;
           TRANSFORM( oRet:PTAJE   ,"999.999" ) ;
      HEADERS "Valor"+CRLF+"Menor", "Valor"+CRLF+"Mayor",;
              "Valor"+CRLF+"Retención", "% Retención"    ;
      SIZES 400, 450 SIZE 190,86 ;
      OF oDlg UPDATE PIXEL
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:nHeaderHeight := 28
    oLbx:GoTop()
    oLbx:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:aColSizes  := {90,90,90,60}
    oLbx:aHjustify  := {2,2,2,2}
    oLbx:aJustify   := {1,1,1,1}
    oLbx:bKeyDown := {|nKey| If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(aBarra[1]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, EVAL(aBarra[2]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE             , EVAL(aBarra[4]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=80 .OR. nKey=VK_F3    , EVAL(aBarra[5]),) ))) }
    oLbx:ladjbrowse  := oLbx:lCellStyle  := .f.
    oLbx:ladjlastcol := .t.
   MySetBrowse( oLbx,oRet )
ACTIVATE DIALOG oDlg CENTER ON INIT ;
  (DefineBar( oDlg,oLbx,aBarra,02,16 ))
oRet:Destroy()
RETURN

//------------------------------------//
PROCEDURE ValoresR( oRet,oLbx,lNuevo )
   LOCAL aEd := { "Modificando Valores",.f.,0,0 }
   LOCAL oDlg, oGet := ARRAY(6)
If lNuevo
   oRet:xBlank()
   aEd[1] := "Nuevos Valores"
EndIf
DEFINE DIALOG oDlg TITLE aEd[1] FROM 0, 0 TO 10,46
   @  02, 00 SAY "Valor Menor" OF oDlg RIGHT PIXEL SIZE 78,10
   @  02, 80 GET oGet[1] VAR oRet:VALORMEN OF oDlg PICTURE "999,999,999.99";
      SIZE 42,12 PIXEL
   @  16, 00 SAY "Valor Mayor" OF oDlg RIGHT PIXEL SIZE 78,10
   @  16, 80 GET oGet[2] VAR oRet:VALORMAY OF oDlg PICTURE "999,999,999.99";
      SIZE 42,12 PIXEL
   @  30, 00 SAY "Valor Reten" OF oDlg RIGHT PIXEL SIZE 78,10
   @  30, 80 GET oGet[3] VAR oRet:VALORRET OF oDlg PICTURE "999,999,999.99";
      SIZE 42,12 PIXEL
   @  44, 00 SAY "Ptaje Reten" OF oDlg RIGHT PIXEL SIZE 78,10
   @  44, 80 GET oGet[4] VAR oRet:PTAJE    OF oDlg PICTURE "999.99" ;
      SIZE 30,12 PIXEL

   @  60, 50 BUTTON oGet[5] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION ;
      (If( oRet:VALORMAY <= 0 .OR. oRet:VALORMEN > oRet:VALORMAY,;
         (MsgStop("No se puede grabar este Registro, debe completar datos"),;
          oGet[1]:SetFocus()), (aEd[2] := .t., oDlg:End()) )) PIXEL
   @  60,100 BUTTON oGet[6] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTER
If aEd[2]
   If lNuevo
      oRet:Append(.t.)
   Else
      oRet:Update(.t.,1)
   EndIf
   oLbx:Refresh()
EndIf
RETURN

//------------------------------------//
PROCEDURE NomTrafi()
   LOCAL aCon, oTra, oDlg, oGet := ARRAY(15)
oTra := oApl:Abrir( "nomtrafi","concepto",.t. )
aCon := { "","", .t. ,;
          {|nCon,nP| If( oApl:oCon:Seek( {"concepto",nCon} )   ,;
            (aCon[nP] := oApl:oCon:NOMBRE, oDlg:Update(), .t. ),;
            (MsgStop( "Este Concepto no Existe" ), .f. ) ) }   ,;
          {|| oTra:Read(), oTra:xLoad()            ,;
              aCon[1] := Buscar({"concepto",oTra:CONCEPTO},"nomconce","nombre",8),;
              aCon[2] := Buscar({"concepto",oTra:CONDES  },"nomconce","nombre",8) } }
oTra:GoTop()
EVAL( aCon[5] )
DEFINE DIALOG oDlg TITLE "TRAFICO DE CONCEPTOS" FROM 0, 0 TO 08,60
   @ 02, 80 SAY oGet[01] VAR oTra:EMPRESA  OF oDlg SIZE 20,10 PIXEL UPDATE
   @ 14, 00 SAY "Concepto" OF oDlg RIGHT PIXEL SIZE 78,10
   @ 14, 80 GET oGet[02] VAR oTra:CONCEPTO OF oDlg PICTURE "999";
     VALID EVAL( aCon[4],oTra:CONCEPTO,1 ) SIZE 20,10 PIXEL UPDATE
   @ 14,110 SAY oGet[03] VAR aCon[1] OF oDlg SIZE 98,10 PIXEL UPDATE
   @ 26, 00 SAY "Concepto de Descuento" OF oDlg RIGHT PIXEL SIZE 78,10
   @ 26, 80 GET oGet[04] VAR oTra:CONDES   OF oDlg PICTURE "999";
     VALID EVAL( aCon[4],oTra:CONDES,2 )   SIZE 20,10 PIXEL UPDATE
   @ 26,110 SAY oGet[05] VAR aCon[2] OF oDlg SIZE 98,10 PIXEL UPDATE

   @ 40, 01 BUTTON oGet[06] PROMPT "..." OF oDlg PIXEL SIZE 14,10
   @ 40, 16 BUTTON oGet[07] PROMPT "<<"  OF oDlg PIXEL SIZE 14,10;
      ACTION ( oTra:GoTop(), EVAL( aCon[5] ), oDlg:Update() )
   @ 40, 31 BUTTON oGet[08] PROMPT "<"   OF oDlg PIXEL SIZE 14,10;
     ACTION ( oTra:Skip(-1), EVAL( aCon[5] ), oDlg:Update() )
   @ 40, 46 BUTTON oGet[09] PROMPT ">"   OF oDlg PIXEL SIZE 14,10;
     ACTION ( oTra:Skip(1 ), EVAL( aCon[5] ), oDlg:Update() )
   @ 40, 61 BUTTON oGet[10] PROMPT ">>"  OF oDlg PIXEL SIZE 14,10;
     ACTION ( oTra:GoBottom(), EVAL( aCon[5] ), oDlg:Update() )
   @ 40, 76 BUTTON oGet[11] PROMPT " + " OF oDlg PIXEL SIZE 14,10;
	    ACTION ( oTra:xBlank(), oDlg:Update(),;
	            aCon[3] := .t.,;
		    oGet[01]:Enable(),;
		    oGet[01]:SetFocus() )
   @ 40, 91 BUTTON oGet[12] PROMPT " X " OF oDlg PIXEL SIZE 14,10
   @ 40,106 BUTTON oGet[13] PROMPT " C " OF oDlg PIXEL SIZE 14,10;
	    ACTION ( oTra:Top(), oDlg:Update(), aCon[3] := .f. )
   @ 40,121 BUTTON oGet[14] PROMPT "Grabar" OF oDlg PIXEL SIZE 24,10;
            ACTION ( If( !aCon[3], oTra:Update(.t.,1),;
                       (oTra:EMPRESA := oApl:nEmpresa, oTra:Append(.t.)) ),;
		     aCon[3] := .f. )
   @ 40,146 BUTTON oGet[15] PROMPT "Salir"  OF oDlg PIXEL SIZE 24,10;
	    ACTION oDlg:End()
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTER ON INIT;
   ( oGet[06]:cToolTip := "Buscar"            ,;
     oGet[07]:cToolTip := "Primer Registro"   ,;
     oGet[08]:cToolTip := "Registro Anterior" ,;
     oGet[09]:cToolTip := "Registro Siguiente",;
     oGet[10]:cToolTip := "Ultimo Registro"   ,;
     oGet[11]:cToolTip := "Nuevo Registro"    ,;
     oGet[12]:cToolTip := "Borrar Registro"   ,;
     oGet[13]:cToolTip := "Cancelar Cambios"   )
oTra:Destroy()
RETURN