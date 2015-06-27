// Programa.: NOMCIERR.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Hago el Cierre de la Nomina.
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

PROCEDURE DatosFijos()
   LOCAL oCC, oDlg, oGet := ARRAY(17)
   LOCAL aEd := { 0,"",0,"",0,"",0,"",.f. }
oCC := TNits() ; oCC:New()
 Empresa( .t.,1 )
 Nitsx( oApl:oFie:CNIT_ARP ,@aEd,1,2 )
 Nitsx( oApl:oFie:CNIT_CAJA,@aEd,3,4 )
 Nitsx( oApl:oFie:CNIT_SENA,@aEd,5,6 )
 Nitsx( oApl:oFie:CNIT_ICBF,@aEd,7,8 )
DEFINE DIALOG oDlg FROM 0, 0 TO 370, 560 PIXEL;
   TITLE "Datos Fijos || " + oApl:cEmpresa
   @  02, 00 SAY "Cobertura Salud" OF oDlg RIGHT PIXEL SIZE 60,10
   @  02, 62 COMBOBOX oGet[01] VAR oApl:oFie:COB_SALUD ITEMS {"Familiar","Clasica"};
      SIZE 50,99 OF oDlg PIXEL
   @  02,138 SAY "Trabajador Inde" OF oDlg RIGHT PIXEL SIZE 60,10
   @  02,200 GET oGet[02] VAR oApl:oFie:TRAB_INDEP OF oDlg PICTURE "9";
      SIZE 24,10 PIXEL
   @  14, 10 SAY "VALORES GENERALES" OF oDlg PIXEL SIZE 60,10;
      COLOR nRGB( 128,0,255 )
   @  26, 00 SAY "Días Descanso" OF oDlg RIGHT PIXEL SIZE 60,10
   @  26, 62 GET oGet[03] VAR oApl:oFie:DIASDESCAN OF oDlg PICTURE "99";
      SIZE 12,10 PIXEL
   @  26,138 SAY "Veces Pago"    OF oDlg RIGHT PIXEL SIZE 60,10
   @  26,200 GET oGet[04] VAR oApl:oFie:VECES_PAGO OF oDlg PICTURE "9";
      SIZE 12,10 PIXEL
   @  38, 00 SAY "# Minimos F.S.P" OF oDlg RIGHT PIXEL SIZE 60,10
   @  38, 62 GET oGet[05] VAR oApl:oFie:MINIMOS    OF oDlg PICTURE "99";
      SIZE 12,10 PIXEL
   @  38,138 SAY "Tasa de Interes" OF oDlg RIGHT PIXEL SIZE 60,10
   @  38,200 GET oGet[06] VAR oApl:oFie:TASA       OF oDlg PICTURE "99.999";
      SIZE 30,10 PIXEL
   @  50, 00 SAY "Cuenta Ahorros"  OF oDlg RIGHT PIXEL SIZE 60,10
   @  50, 62 GET oGet[07] VAR oApl:oFie:CTACTE     OF oDlg PICTURE "@!";
      SIZE 60,10 PIXEL
   @  50,138 SAY "Número Patronal" OF oDlg RIGHT PIXEL SIZE 60,10
   @  50,200 GET oGet[08] VAR oApl:oFie:PATRONAL   OF oDlg PICTURE "@!";
      SIZE 60,10 PIXEL
   @  62, 10 SAY "FECHAS LIMITES"  OF oDlg PIXEL SIZE 60,10;
      COLOR nRGB( 128,0,255 )
   @  74, 00 SAY "Fecha Desde"     OF oDlg RIGHT PIXEL SIZE 60,10
   @  74, 62 GET oGet[09] VAR oApl:oFie:FECHA_DES  OF oDlg SIZE 40,10 PIXEL
   @  74,138 SAY "Fecha Hasta"     OF oDlg RIGHT PIXEL SIZE 60,10
   @  74,200 GET oGet[09] VAR oApl:oFie:FECHA_HAS  OF oDlg SIZE 40,10 PIXEL
   @  86, 00 SAY "Ultimo Cierre"   OF oDlg RIGHT PIXEL SIZE 60,10
   @  86, 62 SAY              oApl:oFie:FECHACIERR OF oDlg SIZE 40,10 PIXEL
   @  98, 10 SAY "VALORES A.R.P"   OF oDlg PIXEL SIZE 60,10;
      COLOR nRGB( 128,0,255 )
   @ 110, 00 SAY "Riesgos Profesionales" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 110, 62 CHECKBOX oGet[10] VAR oApl:oFie:RP_ISS PROMPT " " OF oDlg SIZE 12,12 PIXEL
   @ 110,138 SAY "% Riesgos Profesionales" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 110,200 GET oGet[11] VAR oApl:oFie:POR_R_PROF OF oDlg PICTURE "99.999";
      SIZE 30,10 PIXEL
   @ 122, 00 SAY "Nit A.R.P" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 122, 62 BTNGET oGet[12] VAR aEd[1] OF oDlg PICTURE "9999999999" ;
      ACTION EVAL({|| If(oCC:Mostrar(), (aEd[1] := oCC:oDb:CODIGO   ,;
                         oGet[12]:Refresh() ),) })                   ;
      VALID EVAL( {|| If( oCC:oDb:Seek( {"Codigo",aEd[1]} )         ,;
                        ( aEd[02]         := oCC:oDb:NOMBRE         ,;
                          oApl:oFie:CNIT_ARP := oCC:oDb:CODIGO_NIT  ,;
                          oDlg:Update(), .t. )                      ,;
                  (MsgStop("Este Nit ó C.C. no Existe .."), .f. )) });
      SIZE 48,12 PIXEL UPDATE  RESOURCE "BUSCAR" ;
      WHEN oApl:oFie:RP_ISS
   @ 122,116 SAY aEd[02] OF oDlg PIXEL SIZE 110,10 UPDATE
   @ 134, 00 SAY "Nit Caja"  OF oDlg RIGHT PIXEL SIZE 60,10
   @ 134, 62 BTNGET oGet[13] VAR aEd[3] OF oDlg PICTURE "9999999999" ;
      ACTION EVAL({|| If(oCC:Mostrar(), (aEd[3] := oCC:oDb:CODIGO   ,;
                         oGet[13]:Refresh() ),) })                   ;
      VALID EVAL( {|| If( oCC:oDb:Seek( {"Codigo",aEd[3]} )         ,;
                        ( aEd[04]         := oCC:oDb:NOMBRE         ,;
                          oApl:oFie:CNIT_CAJA:= oCC:oDb:CODIGO_NIT  ,;
                          oDlg:Update(), .t. )                      ,;
                  (MsgStop("Este Nit ó C.C. no Existe .."), .f. )) });
      SIZE 48,12 PIXEL UPDATE  RESOURCE "BUSCAR"
   @ 134,116 SAY aEd[04] OF oDlg PIXEL SIZE 110,10 UPDATE
   @ 146, 00 SAY "Nit Sena"  OF oDlg RIGHT PIXEL SIZE 60,10
   @ 146, 62 BTNGET oGet[14] VAR aEd[5] OF oDlg PICTURE "9999999999" ;
      ACTION EVAL({|| If(oCC:Mostrar(), (aEd[5] := oCC:oDb:CODIGO   ,;
                         oGet[14]:Refresh() ),) })                   ;
      VALID EVAL( {|| If( oCC:oDb:Seek( {"Codigo",aEd[5]} )         ,;
                        ( aEd[06]         := oCC:oDb:NOMBRE         ,;
                          oApl:oFie:CNIT_SENA:= oCC:oDb:CODIGO_NIT  ,;
                          oDlg:Update(), .t. )                      ,;
                  (MsgStop("Este Nit ó C.C. no Existe .."), .f. )) });
      SIZE 48,12 PIXEL UPDATE  RESOURCE "BUSCAR"
   @ 146,116 SAY aEd[06] OF oDlg PIXEL SIZE 110,10 UPDATE
   @ 158, 00 SAY "Nit ICBF"  OF oDlg RIGHT PIXEL SIZE 60,10
   @ 158, 62 BTNGET oGet[15] VAR aEd[7] OF oDlg PICTURE "9999999999" ;
      ACTION EVAL({|| If(oCC:Mostrar(), (aEd[7] := oCC:oDb:CODIGO   ,;
                         oGet[15]:Refresh() ),) })                   ;
      VALID EVAL( {|| If( oCC:oDb:Seek( {"Codigo",aEd[7]} )         ,;
                        ( aEd[08]         := oCC:oDb:NOMBRE         ,;
                          oApl:oFie:CNIT_ICBF:= oCC:oDb:CODIGO_NIT  ,;
                          oDlg:Update(), .t. )                      ,;
                  (MsgStop("Este Nit ó C.C. no Existe .."), .f. )) });
      SIZE 48,12 PIXEL UPDATE  RESOURCE "BUSCAR"
   @ 158,116 SAY aEd[08] OF oDlg PIXEL SIZE 110,10 UPDATE

   @ 150,230 BUTTON oGet[16] PROMPT "&Grabar"   SIZE 40,12 OF oDlg ACTION ;
      (If( EMPTY(oApl:oFie:FECHA_DES) .OR. EMPTY(oApl:oFie:FECHA_HAS)    ,;
         (MsgStop("No se puede grabar estos DATOS, debe completar datos"),;
          oGet[1]:SetFocus()), (aEd[9] := .t., oDlg:End()) )) PIXEL
   @ 164,230 BUTTON oGet[17]PROMPT "&Cancelar" SIZE 40,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
If aEd[9]
   If oApl:oFie:lOK
      oApl:oFie:Update( .t.,1 )
   Else
      oApl:oFie:EMPRESA := oApl:nEmpresa
      oApl:oFie:Append( .t. )
   EndIf
EndIf
RETURN

//------------------------------------//
PROCEDURE Misiones()
   LOCAL aBarra, oCC, oCen, oDlg, oLbx
aBarra := { {|| Cencosto( oLbx,oCC,oCen,.t. ) },          ;
            {|| Cencosto( oLbx,oCC,oCen,.f. ) },{|| .t. },;
            {|| DelRecord( oCen,oLbx,.t. ) }   ,{|| .t. },{|| oDlg:End() } }
oCC  := TNits()
oCC:New()
oCen := oApl:Abrir( "cencosto","Cencos" )
oCen:Seek( {"Cencos >= ","01"} )

DEFINE DIALOG oDlg TITLE "M I S I O N E S" FROM 0, 0 TO 240, 580 PIXEL
   @ 20,04 LISTBOX oLbx FIELDS oCen:CENCOS ,;
                               oCen:NOMBRE  ;
      HEADERS "Centro"+CRLF+"Costo", "Nombre" ;
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
    oLbx:aColSizes  := {80,300}
    oLbx:aHjustify  := {2,2}
    oLbx:aJustify   := {0,0}
    oLbx:bKeyDown := {|nKey| If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(aBarra[1]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, EVAL(aBarra[2]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE             , EVAL(aBarra[4]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=80 .OR. nKey=VK_F3    , EVAL(aBarra[5]),) ))) }
    oLbx:ladjbrowse  := oLbx:lCellStyle  := .f.
    oLbx:ladjlastcol := .t.
   MySetBrowse( oLbx,oCen )
ACTIVATE DIALOG oDlg CENTER ON INIT ;
  (DefineBar( oDlg,oLbx,aBarra,02,18 ))
oCen:Destroy()
RETURN

//------------------------------------//
PROCEDURE Cencosto( oLbx,oCC,oCen,lNuevo )
   LOCAL aEd := { "Modificando Misión",.f.,0 }
   LOCAL oDlg, oGet := ARRAY(15)
   LOCAL aNive := { "Minimo 0.522","Bajo 1.044","Medio 2.436","Alto 4.350","Maximo 6.960"}
If lNuevo
   oLbx:GoBottom()
   aEd[3] := STRZERO( VAL(oCen:CENCOS)+1,2 )
   oCen:xBlank()
   oCen:CENCOS  := aEd[3]
   oCen:NIVELARP:= 1
   aEd := { "Nueva Misión",.f.,0 }
EndIf
 Nitsx( oCen:CODIGO_NIT,@aEd,3 )
DEFINE DIALOG oDlg TITLE aEd[1] FROM 0, 0 TO 15,54
   @ 02,00 SAY "Nit o C.C"  OF oDlg RIGHT PIXEL SIZE 50,10
   @ 02,52 BTNGET oGet[1] VAR aEd[3] OF oDlg PICTURE "9999999999"    ;
      ACTION EVAL({|| If(oCC:Mostrar(), (aEd[3] := oCC:oDb:CODIGO   ,;
                         oGet[1]:Refresh() ),) })                    ;
      VALID EVAL( {|| If( oCC:oDb:Seek( {"Codigo",aEd[3]} )         ,;
                        ( oCen:NOMBRE    := If( lNuevo              ,;
                                       oCC:oDb:NOMBRE, oCen:NOMBRE ),;
                          oCen:CODIGO_NIT:= oCC:oDb:CODIGO_NIT      ,;
                          oDlg:Update(), .t. )                      ,;
                  (MsgStop("Este Nit ó C.C. no Existe .."), .f. )) });
      SIZE 48,12 PIXEL UPDATE  RESOURCE "BUSCAR"
   @ 02,110 SAY "Centro de Costo" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 02,162 GET oGet[2] VAR oCen:CENCOS OF oDlg PICTURE "99";
      SIZE 24,10 PIXEL WHEN lNuevo
   @ 14, 00 SAY "Nombre" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 14, 52 GET oGet[3] VAR oCen:NOMBRE OF oDlg PICTURE "@!";
      SIZE 140,10 PIXEL UPDATE
   @ 26, 00 SAY "Nombre Corto" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 26, 52 GET oGet[4] VAR oCen:NOMCOR OF oDlg PICTURE "@!";
      SIZE  80,10 PIXEL UPDATE
   @ 38, 00 SAY "% Parafiscales"   OF oDlg RIGHT PIXEL SIZE 50,10
   @ 38, 52 GET oGet[5] VAR oCen:PARAF  OF oDlg PICTURE "999.99" SIZE 30,10 PIXEL
   @ 38,110 SAY "% Producción"   OF oDlg RIGHT PIXEL SIZE 50,10
   @ 38,162 GET oGet[6] VAR oCen:PARAF2 OF oDlg PICTURE "999.99" SIZE 30,10 PIXEL
   @ 50, 00 SAY "% Administracion" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 50, 52 GET oGet[7] VAR oCen:ADMON OF oDlg PICTURE "999.99" SIZE 30,10 PIXEL
   @ 62, 00 SAY "Clase de Riesgo" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 62, 52 COMBOBOX oGet[8] VAR oCen:NIVELARP ITEMS aNive ;
      SIZE 52,99 OF oDlg PIXEL
   @ 50,110 SAY "Tiene Rete Fuente" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 50,162 CHECKBOX oGet[09] VAR oCen:RETFTE PROMPT " " OF oDlg SIZE 12,10 PIXEL
   @ 62,110 SAY "Tiene Rete I.V.A." OF oDlg RIGHT PIXEL SIZE 50,10
   @ 62,162 CHECKBOX oGet[10] VAR oCen:RETIVA PROMPT " " OF oDlg SIZE 12,10 PIXEL
   @ 74,110 SAY "Tiene Rete I.C.A." OF oDlg RIGHT PIXEL SIZE 50,10
   @ 74,162 CHECKBOX oGet[11] VAR oCen:RETICA PROMPT " " OF oDlg SIZE 12,10 PIXEL
   @ 74, 00 SAY "Desactivar Mision" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 74, 52 CHECKBOX oGet[12] VAR oCen:ACTIVA PROMPT " " OF oDlg SIZE 12,10 PIXEL
   @ 86,100 SAY "Parafiscales Completos" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 86,162 CHECKBOX oGet[13] VAR oCen:PARAFAT PROMPT " " OF oDlg SIZE 12,10 PIXEL

   @ 99, 50 BUTTON oGet[14] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION ;
      (If( EMPTY(oCen:CENCOS) .OR. EMPTY(oCen:NOMBRE) .OR.;
           EMPTY(oCen:PARAF ) .OR. EMPTY(oCen:ADMON )    ,;
         (MsgStop("No se puede grabar este Registro, debe completar datos"),;
          oGet[1]:SetFocus()), (aEd[2] := .t., oDlg:End()) )) PIXEL
   @ 99,100 BUTTON oGet[15] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTER
If aEd[2]
   If lNuevo
      oCen:Append(.t.)
   Else
      oCen:Update(.t.,1)
   EndIf
   oLbx:Refresh()
EndIf
RETURN

//------------------------------------//
PROCEDURE NomCierre()
   LOCAL aCie, nDF := 0
 Empresa( .t.,1 )
aCie := { oApl:oFie:FECHA_HAS,0,0 }
If !MsgNoYes( NtChr( aCie[1],"2" ),"Cierro esta Quincena" )
   RETURN
EndIf

aCie[2] := oApl:oFie:FECHA_DES
oApl:oFie:FECHACIERR:=oApl:oFie:FECHA_HAS
oApl:oFie:FECHA_HAS := If( DAY(aCie[1]) # 15, aCie[1]+15,;
                           CTOD(NtChr( aCie[1],"4" )) )
oApl:oFie:VECES_PAGO:= If( oApl:oFie:VECES_PAGO == 1, 2, 1 )
oApl:oFie:FECHA_DES += If( DAY(aCie[2]) == 1, 15 ,;
                           DAY(CTOD(NtChr( aCie[2],"4" ))) -15 )
If oApl:oEmp:DESCANSO
   aCie := { oApl:oFie:FECHA_DES,DOW( oApl:oFie:FECHA_DES ),0 }
   aCie[1] += If( aCie[2] == 1, 0, 8-aCie[2] )
   WHILE aCie[1] <= oApl:oFie:FECHA_HAS
      If DOW( aCie[1] ) == 1
         aCie[3] ++
      EndIf
      aCie[1] += 7
   EndDo
   MsgGet( "EN ESTA QUINCENA","Cuantos Festivos",@nDF )
   oApl:oFie:DIASDESCAN := aCie[3] + nDF
Else
   oApl:oFie:DIASDESCAN := 0
EndIf
oApl:oFie:Update( .t.,1 )
RETURN
