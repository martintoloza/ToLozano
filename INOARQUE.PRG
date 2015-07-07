// Programa.: INOARQUE.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Arqueo fisico al inventario
#include "FiveWin.ch"
#include "btnget.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE InoArque()
   LOCAL oA, oDlg, oGet := ARRAY(5)
 oA := TArqueo() ; oA:New()
DEFINE DIALOG oDlg TITLE "Arqueo Fisico al Inventario" FROM 0, 0 TO 07,42
   @ 02, 00 SAY "Empresa" OF oDlg RIGHT PIXEL SIZE 96,10
   @ 02, 98 GET oGet[1] VAR oA:aLS[1] OF oDlg PICTURE "@!"         ;
      VALID Eval( {|| If( oApl:oEmp:Seek( {"localiz",oA:aLS[1]} ) ,;
                      (oApl:nEmpresa := oApl:oEmp:EMPRESA,.t. )   ,;
                      (MsgStop("Esta Empresa NO EXISTE"), .f.) ) } );
      SIZE 24,12 PIXEL
   @ 16, 00 SAY  "DIGITE AÑO Y MES [AAMM]" OF oDlg RIGHT PIXEL SIZE 96,10
   @ 16, 98 GET oGet[2] VAR oA:aLS[2] OF oDlg SIZE 36,12 PIXEL;
      VALID NtChr( oA:aLS[2],"P" )
   @ 32, 10 BUTTON oGet[3] PROMPT "&Aceptar"   SIZE 44,12 OF oDlg ACTION;
      ( oA:Arqueos(), oGet[3]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 32, 60 BUTTON oGet[4] PROMPT "&Cancelar"  SIZE 44,12 OF oDlg CANCEL;
      ACTION ( oDlg:End() ) PIXEL
   @ 32,110 BUTTON oGet[5] PROMPT "&Historial" SIZE 44,12 OF oDlg ACTION;
      ( oA:ArqueHis(), oGet[5]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED

oA:oArq:Destroy()
RETURN

//----Listado del Arqueo fisico al Inventario----//
PROCEDURE InoLiArq()
   LOCAL aRep, nOpc, oA, oBar, oGet := ARRAY(8)
 oA := TArqueo()
 oA:aLS := { NtChr( DATE(),"1" ),1,"S",oApl:nTFor,.t.,"","" }
aRep := { { {|| oA:ListoArq( oApl:aWHija[1] ) },"Listo el Arqueo Fisico" },;
          { {|| oA:ListoCod() },"Listar Codigos del Arqueo" } }
If oApl:aWHija[1] == NIL
   DEFINE WINDOW oApl:aWHija[1] OF oApl:oWnd NOMINIMIZE NOMAXIMIZE ;
          TITLE aRep[1,2] ;
          FROM 0,0 TO 220,400 PIXEL MDICHILD
   DEFINE BUTTONBAR oBar OF oApl:aWHija[1] SIZE 25,25 _3D

   DEFINE BUTTON OF oBar RESOURCE "Exit3" NOBORDER;
          ACTION oApl:aWHija[1]:End() TOOLTIP "Salida"
   @ 30, 00 SAY "DIGITE AÑO Y MES [AAMM]" OF oApl:aWHija[1] RIGHT PIXEL SIZE 180,16
   @ 30,186 GET oGet[1] VAR oA:aLS[1] OF oApl:aWHija[1] SIZE 54,18 PIXEL;
      VALID NtChr( oA:aLS[1],"P" )
   @ 54, 00 SAY "ORDENADO POR" OF oApl:aWHija[1] RIGHT PIXEL SIZE 180,16
   @ 54,186 COMBOBOX oGet[2] VAR oA:aLS[2] ITEMS { "Codigo","Nombre" } SIZE 80,90 ;
      OF oApl:aWHija[ 1 ] PIXEL
   @ 78, 00 SAY "LISTO COMPARACION [S/N]" OF oApl:aWHija[1] RIGHT PIXEL SIZE 180,16
   @ 78,186 GET oGet[3] VAR oA:aLS[3] OF oApl:aWHija[1] PICTURE "!";
      VALID oA:aLS[3] $ "SN"  SIZE 20,18 PIXEL
   @ 102, 00 SAY "TIPO DE IMPRESORA"   OF oApl:aWHija[1] RIGHT PIXEL SIZE 180,16
   @ 102,186 COMBOBOX oGet[4] VAR oA:aLS[4] ITEMS { "Matriz","Laser" } SIZE 80,90 ;
      OF oApl:aWHija[1] PIXEL
   @ 102,280 CHECKBOX oGet[5] VAR oA:aLS[5] PROMPT "Vista &Previa" OF oApl:aWHija[1] ;
      SIZE 94,16 PIXEL
   @ 130,186 BUTTON oGet[6] PROMPT "&Aceptar"  SIZE 60,20 OF oApl:aWHija[1] ACTION;
      ( nOpc := {1,2}[AT(oA:aLS[3],"SN")], oGet[6]:Disable(),;
        EVAL( aRep[nOpc,1] )           , oGet[6]:Enable() ,;
        oGet[6]:oJump := oGet[1]       , oGet[2]:SetFocus() ) PIXEL

   @ 156, 10 SAY  oGet[7] VAR oA:aLS[6] OF oApl:aWHija[1] PIXEL SIZE 180,18 ;
      UPDATE COLOR nRGB( 0,255,0 )
   @ 156,200 SAY  oGet[8] VAR oA:aLS[7] OF oApl:aWHija[1] PIXEL SIZE  80,18 ;
      UPDATE COLOR nRGB( 160,19,132 )
   ACTIVAGET(oGet)

   ACTIVATE WINDOW oApl:aWHija[1] ;
      ON INIT (oGet[1]:SetFocus());
      VALID ( oApl:aWHija[1] := NIL, .t. )
Else
   oApl:aWHija[1]:SetFocus()
EndIf
RETURN

//------------------------------------//
CLASS TArqueo FROM TIMPRIME

 DATA aLS, oArq

 METHOD NEW() Constructor
 METHOD ArqueHis()
 METHOD Arqueos()
 METHOD Buscar( oAr )
 METHOD ListoArq( oDlg )
 METHOD LaserArq( cQry,oDlg )
 METHOD ListoCod()
 METHOD LaserCod( hRes, nL )
 METHOD Query( nH,cQry )
ENDCLASS

//------------------------------------//
METHOD New() CLASS TArqueo

 ::aLS  := { "   ",NtChr( DATE(),"1" ),oApl:nEmpresa,TInv(), }
 ::oArq := oApl:Abrir( "cadarque","empresa, codigo, anomes",.t.,,50 )
 ::aLS[4]:New( ,.f. )

RETURN NIL

//------------------------------------//
METHOD ArqueHis() CLASS TArqueo
   LOCAL oDlg, oGet := ARRAY(1), oLbx, cCod := SPACE(12)
::oArq:Seek( { "empresa",oApl:nEmpresa,"codigo",cCod } )
DEFINE DIALOG oDlg TITLE "HISTORIAL ARQUEO " + ::aLS[1] FROM 0, 0 TO 15,43
   @ 02,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 66,10
   @ 02,70 GET oGet[1] VAR cCod OF oDlg PICTURE "@!"                  ;
      VALID If( oApl:oInv:Seek( {"codigo",cCod} )                    ,;
              (::oArq:Seek( {"empresa",oApl:nEmpresa,"codigo",cCod} ),;
               oLbx:GoBottom(), oDlg:Update(), .t. )                 ,;
              ( MsgStop( "Este Código NO EXISTE !!!" ), .f. ) )       ;
      SIZE 50,12 PIXEL
   @ 20,06 LISTBOX oLbx FIELDS ::oArq:ANOMES                ,;
                               ::oArq:VITRINA               ,;
                    TRANSFORM( ::oArq:CANTIDAD,"999,999.99" );
      HEADERS "Periodo", "Vitrina", "Cantidad";
      SIZE 150,90 OF oDlg UPDATE PIXEL
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:nHeaderHeight := 28
    oLbx:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:aColSizes  := {60,60,60}
    oLbx:aHjustify  := {2,2,2}
    oLbx:aJustify   := {0,0,1}
    oLbx:lCellStyle := oLbx:ladjbrowse := .f.
    oLbx:ladjlastcol:= .t.
   MySetBrowse( oLbx, ::oArq )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN NIL

//------------------------------------//
METHOD Arqueos() CLASS TArqueo
   LOCAL oDlg, oGet := ARRAY(7), bGrabar
   LOCAL oAr := ::aLS[4]
bGrabar := {|| If( ::oArq:lOK,                          ;
                 ( ::oArq:Update(), oGet[7]:Disable() ),;
                 ( ::oArq:EMPRESA := oApl:nEmpresa     ,;
                   ::oArq:ANOMES  := ::aLS[2]          ,;
                   ::oArq:Append() ) ), ::oArq:xBlank(),;
               oDlg:Update(), oDlg:SetFocus() }
::aLS[5] := CTOD( NtChr( NtChr( ::aLS[2],"F" ),"4" ) )
::oArq:xBlank()
oAr:oDb:Seek( {"codigo",::oArq:CODIGO} )
DEFINE DIALOG oDlg TITLE "ARQUEO " + ::aLS[1] FROM 0, 0 TO 10,50
   @ 02,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 66,10
   @ 02,70 BTNGET oGet[1] VAR oAr:xVar OF oDlg PICTURE "@!"         ;
      VALID If( ::Buscar( oAr )                                    ,;
              (If( ::oArq:lOK,  oGet[7]:Enable()                   ,;
                 ( oGet[7]:Disable(), ::oArq:CODIGO := oAr:xVar ) ),;
                oDlg:Update(), .t. ), .f. )                         ;
      SIZE 56,12 PIXEL UPDATE  RESOURCE "BUSCAR"                    ;
      ACTION EVAL({|| If(oAr:Mostrar(), (oAr:xVar := oAr:oDb:CODIGO,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
   @ 16,50 SAY oGet[2] VAR oAr:oDb:DESCRIP OF oDlg PIXEL SIZE 140,12 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 30,00 SAY "Cantidad" OF oDlg RIGHT PIXEL SIZE 66,8
   @ 30,70 GET oGet[3] VAR ::oArq:CANTIDAD OF oDlg PICTURE "9,999.99";
      VALID {|| If( ::oArq:CANTIDAD >  0, .t.                       ,;
          (MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>"), .f.)) };
      SIZE 40,10 PIXEL UPDATE
   @ 44,00 SAY  "Vitrina" OF oDlg RIGHT PIXEL SIZE 66,8
   @ 44,70 GET oGet[4] VAR ::oArq:VITRINA OF oDlg PICTURE "@!";
      SIZE 30,12 PIXEL UPDATE
   @ 60, 40 BUTTON oGet[5] PROMPT "&Grabar"   SIZE 44,12 OF oDlg ACTION;
      (If( EMPTY( ::oArq:CODIGO ) .OR. ::oArq:CANTIDAD <= 0           ,;
         (MsgStop("Imposible grabar este CODIGO"), oGet[1]:SetFocus()),;
          EVAL(bGrabar) )) PIXEL
   @ 60, 90 BUTTON oGet[6] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 60,140 BUTTON oGet[7] PROMPT "&Borrar"   SIZE 44,12 OF oDlg ACTION;
      (DelRecord( ::oArq ), oGet[7]:Disable(), oDlg:SetFocus()) PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT (oGet[7]:Disable(), oDlg:Move(240,200) )
RETURN NIL

//------------------------------------//
METHOD Buscar( oAr ) CLASS TArqueo
   LOCAL lSi := oAr:oDb:Seek( {"codigo",oAr:xVar} )
::oArq:Seek( {"empresa",oApl:nEmpresa,"codigo",oAr:xVar,"anomes",::aLS[2]} )
If !lSi
   If ::oArq:lOK
      lSi := .t.
   Else
      MsgStop( oAr:xVar + " NO EXISTE","Este Código" )
   EndIf
EndIf
RETURN lSi

//------------------------------------//
METHOD ListoArq( oDlg ) CLASS TArqueo
   LOCAL aRA, aRS, cQry, hRes, nL, lOK := .t.
   LOCAL oRpt, aCA := { 0,0,0,0,0,0,0,.f.,0,"" }
cQry := "SELECT codigo, 0, 0, 0, 0, 0, 0, 0, 0, 'A', cantidad FROM cadarque "+;
        "WHERE empresa = "  + LTRIM(STR(oApl:nEmpresa))+;
         " AND anomes  = '" + ::aLS[1] + "'"
hRes := ::Query( 0,cQry )
If MSNumRows( hRes ) == 0
   MsgInfo( "NO HAY ARQUEO","EN "+::aLS[1] )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[4] == 2
   MSFreeResult( hRes )
   ::LaserArq( cQry,oDlg )
   RETURN NIL
EndIf
MSFreeResult( hRes )
aCA[09] := Seconds()
aCA[10] := NtChr( NtChr( ::aLS[1],"F" )-1,"1" )
hRes := ::Query( 1,cQry )
nL   := MSNumRows( hRes )
::aLS[6] := "Por Favor Espere Mientras Comparo" + STR(nL)
oDlg:Update()
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"ARQUEO FISICO DEL INVENTARIO",;
         "EN " + NtChr( NtChr( ::aLS[1],"F" ),"6" ),SPACE(37) +;
         "  SALDO   TOTAL    TOTAL DEVOLUC DEVOLUC  AJUSTE  AJUSTE DEVOLUC   SALDO   ARQUEO",;
         "C O D I G O- -D E S C R P C I O N--  ANTERIOR ENTRADA  VENTAS ENTRADA"+;
         " SALIDAS ENTRADA SALIDAS CLIENTE   ACTUAL  FISICO FALTANTE SOBRANTE"},::aLS[5],,2 )
While nL > 0
   If lOK
      aRA := MyReadRow( hRes )
      AEVAL( aRA, {| xV,nP | aRA[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If (nL --) > 1
      aRS := MyReadRow( hRes )
      AEVAL( aRS, {| xV,nP | aRS[nP] := MyClReadCol( hRes,nP ) } )
   Else
      aRS := aRA
   EndIf
   If aRA[1] == aRS[1]
      If TRIM(aRA[10]) == "A"
         AEVAL( aRS, {| xV,nP | aRA[nP] := xV },2,9 )
      Else
         aRA[11] := aRS[11]
      EndIf
      lOK := .t.
   Else
      lOK := .f.
   EndIf
   ::aLS[7] := aRA[1] ; oDlg:Update()
   If ::aLS[1] == aRA[10]
      aCA[6] := SaldoInv( aRA[1],aCA[10],1 )
   Else
      aCA[6] := aRA[9]             //Existencia Anterior
      AFILL( aRA,0,2,7 )
   EndIf

   aCA[7] := aRA[11] - aRA[9]      //Cantidad - Existencia
   aCA[8] := If( aCA[7] == 0, .f., .t. )
   If aCA[6] # 0 .OR. aRA[9] # 0 .OR. aCA[7] # 0
      oRpt:Titulo( 136 )
      If aCA[8]
         oApl:oInv:Seek( {"codigo",aRA[01]} )
         oRpt:Say( oRpt:nL, 00,aRA[01] )
         oRpt:Say( oRpt:nL, 12,oApl:oInv:DESCRIP )
         oRpt:Say( oRpt:nL, 39,TRANSFORM(aCA[06],   "99,999") )
         oRpt:Say( oRpt:nL, 47,TRANSFORM(aRA[02],"@Z 99,999") )
         oRpt:Say( oRpt:nL, 55,TRANSFORM(aRA[03],"@Z 99,999") )
         oRpt:Say( oRpt:nL, 63,TRANSFORM(aRA[04],"@Z 99,999") )
         oRpt:Say( oRpt:nL, 71,TRANSFORM(aRA[05],"@Z 99,999") )
         oRpt:Say( oRpt:nL, 79,TRANSFORM(aRA[06],"@Z 99,999") )
         oRpt:Say( oRpt:nL, 87,TRANSFORM(aRA[07],"@Z 99,999") )
         oRpt:Say( oRpt:nL, 95,TRANSFORM(aRA[08],"@Z 99,999") )
         oRpt:Say( oRpt:nL,104,TRANSFORM(aRA[09],   "99,999") )
         oRpt:Say( oRpt:nL,112,TRANSFORM(aRA[11],   "99,999") )
         If aCA[7] < 0
            oRpt:Say( oRpt:nL,121,TRANSFORM(ABS(aCA[7]),"99,999") )
            aCA[4] += ABS(aCA[7])
         ElseIf aCA[7] > 0
            oRpt:Say( oRpt:nL,130,TRANSFORM(ABS(aCA[7]),"99,999") )
            aCA[5] += ABS(aCA[7])
         EndIf
         oRpt:nL++
      EndIf
      aCA[1] += aCA[06]
      aCA[2] += aRA[09]
      aCA[3] += aRA[11]
   EndIf
   If lOK
      nL --
   Else
      aRA := aRS
   EndIf
EndDo
::aLS[6] := "Ha tardado " + STR( Seconds() - aCA[9] )
oDlg:Update()
If oRpt:nPage > 0
   oRpt:Titulo( 136 )
   oRpt:Say(  oRpt:nL, 00,REPLICATE("_",136),,,1 )
   oRpt:Say(++oRpt:nL, 15,"TOTALES",,,1 )
   oRpt:Say(  oRpt:nL, 39,TRANSFORM(aCA[1],"99,999") )
   oRpt:Say(  oRpt:nL,104,TRANSFORM(aCA[2],"99,999") )
   oRpt:Say(  oRpt:nL,112,TRANSFORM(aCA[3],"99,999") )
   oRpt:Say(  oRpt:nL,121,TRANSFORM(aCA[4],"99,999") )
   oRpt:Say(  oRpt:nL,130,TRANSFORM(aCA[5],"99,999") )
EndIf
oRpt:NewPage()
oRpt:End()
MSFreeResult( hRes )
RETURN NIL

//------------------------------------//
METHOD LaserArq( cQry,oDlg ) CLASS TArqueo
   LOCAL aRA, aRS, hRes, nL, lOK := .t.
   LOCAL aCA := { 0,0,0,0,0,0,0,.f.,0,"" }
aCA[09] := Seconds()
aCA[10] := NtChr( NtChr( ::aLS[1],"F" )-1,"1" )
hRes := ::Query( 1,cQry )
nL   := MSNumRows( hRes )
 ::aLS[6] := "Por Favor Espere Mientras Comparo" + STR(nL)
oDlg:Update()
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit,;
             "ARQUEO FISICO DEL INVENTARIO","EN "+NtChr( NtChr( ::aLS[1],"F" ),"6" ),;
             { .F., 0.5,"","C O D I G O" }       , { .F., 2.6,"","D E S C R I P C I O N" },;
             { .T., 8.6,"   SALDO","ANTERIOR" }  , { .T.,10.3,"COMPRAS","   VENTAS" }     ,;
             { .T.,12.0,"DEV.ENTRA","DEV.SALID" }, { .T.,13.7,"AJU.ENTRA" ,"AJU.SALID" }  ,;
             { .T.,15.4,"DEVOLUCI.","  CLIENTE" }, { .T.,17.1,"SAL.ACTUAL","ARQ.FISICO" } ,;
             { .T.,18.7,"","FALTANTE" }          , { .T.,20.5,"","SOBRANTE" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[5] ,,, ::aLS[5], 5 )
 ::nMD := 20.5
  PAGE
While nL > 0
   If lOK
      aRA := MyReadRow( hRes )
      AEVAL( aRA, {| xV,nP | aRA[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If (nL --) > 1
      aRS := MyReadRow( hRes )
      AEVAL( aRS, {| xV,nP | aRS[nP] := MyClReadCol( hRes,nP ) } )
   Else
      aRS := aRA
   EndIf
   If aRA[1] == aRS[1]
      If TRIM(aRA[10]) == "A"
         AEVAL( aRS, {| xV,nP | aRA[nP] := xV },2,9 )
      Else
         aRA[11] := aRS[11]
      EndIf
      lOK := .t.
   Else
      lOK := .f.
   EndIf
   ::aLS[7] := aRA[1] ; oDlg:Update()
   If ::aLS[1] == aRA[10]
      aCA[6] := SaldoInv( aRA[1],aCA[10],1 )
   Else
      aCA[6] := aRA[9]             //Existencia Anterior
      AFILL( aRA,0,2,7 )
   EndIf

   aCA[7] := aRA[11] - aRA[9]      //Cantidad - Existencia
   aCA[8] := If( aCA[7] == 0, .f., .t. )
   If aCA[6] # 0 .OR. aRA[9] # 0 .OR. aCA[7] # 0
      If aCA[8]
         oApl:oInv:Seek( {"codigo",aRA[01]} )
         ::Cabecera( .t.,0.42,0.84 )
         UTILPRN ::oUtil Self:nLinea, 0.5 SAY aRA[01]
         UTILPRN ::oUtil Self:nLinea, 2.6 SAY oApl:oInv:DESCRIP
         UTILPRN ::oUtil Self:nLinea, 8.6 SAY TRANSFORM(aCA[06],   "99,999.999") RIGHT
         UTILPRN ::oUtil Self:nLinea,10.3 SAY TRANSFORM(aRA[02],"@Z 99,999.999") RIGHT
         UTILPRN ::oUtil Self:nLinea,12.0 SAY TRANSFORM(aRA[04],"@Z 99,999.999") RIGHT
         UTILPRN ::oUtil Self:nLinea,13.7 SAY TRANSFORM(aRA[06],"@Z 99,999.999") RIGHT
         UTILPRN ::oUtil Self:nLinea,15.4 SAY TRANSFORM(aRA[08],"@Z 99,999.999") RIGHT
         UTILPRN ::oUtil Self:nLinea,17.1 SAY TRANSFORM(aRA[09],   "99,999.999") RIGHT
         ::nLinea += 0.42
         UTILPRN ::oUtil Self:nLinea,10.3 SAY TRANSFORM(aRA[03],"@Z 99,999.999") RIGHT
         UTILPRN ::oUtil Self:nLinea,12.0 SAY TRANSFORM(aRA[05],"@Z 99,999.999") RIGHT
         UTILPRN ::oUtil Self:nLinea,13.7 SAY TRANSFORM(aRA[07],"@Z 99,999.999") RIGHT
         UTILPRN ::oUtil Self:nLinea,17.1 SAY TRANSFORM(aRA[11],   "99,999.999") RIGHT
         If aCA[7] < 0
            UTILPRN ::oUtil Self:nLinea,18.7 SAY TRANSFORM(ABS(aCA[7]),"99,999.999") RIGHT
            aCA[4] += ABS(aCA[7])
         ElseIf aCA[7] > 0
            UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM(ABS(aCA[7]),"99,999.999") RIGHT
            aCA[5] += ABS(aCA[7])
         EndIf
      EndIf
      aCA[1] += aCA[06]
      aCA[2] += aRA[09]
      aCA[3] += aRA[11]
   EndIf
   If lOK
      nL --
   Else
      aRA := aRS
   EndIf
EndDo
MSFreeResult( hRes )
::aLS[6] := "Ha tardado " + STR( Seconds() - aCA[9] )
oDlg:Update()
If ::nPage > 0
   ::Cabecera( .t.,0.3,1.44,20.5 )
   UTILPRN ::oUtil Self:nLinea, 3.0 SAY "T O T A L E S ======>"
   UTILPRN ::oUtil Self:nLinea, 8.6 SAY TRANSFORM(aCA[1],"99,999.999") RIGHT
   UTILPRN ::oUtil Self:nLinea,17.1 SAY TRANSFORM(aCA[2],"99,999.999") RIGHT
   ::nLinea += 0.42
   UTILPRN ::oUtil Self:nLinea,17.1 SAY TRANSFORM(aCA[3],"99,999.999") RIGHT
   UTILPRN ::oUtil Self:nLinea,18.7 SAY TRANSFORM(aCA[4],"99,999.999") RIGHT
   UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM(aCA[5],"99,999.999") RIGHT
EndIf
  ENDPAGE
 ::EndInit( .F. )
RETURN NIL
/*
   LOCAL aLS := { "S",1,CTOD(""),"N", }, nK
   LOCAL aMes := ARRAY(9)
COPY FILE Temporal.Mtl TO &cTemp..Dbf
Indexa( cTemp,cTemp,"Codigo" )
If !AbreArch( "Tem",cTemp,cTemp,,,,.f. )
   Erase &cTemp..Dbf
   Erase &cTemp..Ntx
   Retu
EndIf
APPEND FROM CadArque FOR Empresa = nEmpresa .AND. AnoMes = cPer
If !EMPTY( aLS[3] )
   aLS[5] := NtChr( LEFT( DTOS( aLS[3] ),6 ),"F" )
   Ven->(dbSeek( STR(nEmpresa,2) + DTOS(aLS[5]), .t. ))
   While Ven->EMPRESA == nEmpresa .AND. ;
         Ven->FECHOY  >= aLS[5]   .AND. ;
         Ven->FECHOY  <= aLS[3]   .AND. !Ven->(EOF())
      If Ven->TIPO == Tipocge .AND. !Ven->INDICADOR $ "AD"
         If dbSeek( Ven->CODIGO )
            REPLACE CANTIDAD WITH CANTIDAD + Ven->CANTIDAD
         Else
            APPEND BLANK
            REPLACE Empresa  WITH nEmpresa, Codigo   WITH Ven->CODIGO,;
                    AnoMes   WITH cPer    , CANTIDAD WITH Ven->CANTIDAD
         EndIf
      EndIf
      Ven->(dbSkip())
   EndDo
EndIf
nCant := 0
dbSelectArea( "Inv" )
While !Eof()
   @ 21,35 Say Codigo
   AFILL( aMes,0 )
   dbSelectArea( "Mes" )
   If SaldoInv( Inv->Codigo )
      aMes[2] := Entradas
      aMes[3] := Salidas
      aMes[4] := Ajustes_E
      aMes[5] := Ajustes_S
      aMes[6] := Devol_E
      aMes[7] := Devol_S
      aMes[8] := DevolCli
      dbSkip(-1)
      If Empresa = nEmpresa .And. Codigo = Inv->Codigo .And. !Bof()
         aMes[1] := Existencia
      EndIf
   Else
      aMes[1] := nCant
   EndIf
   dbSelectArea( "Tem" )
   If ( dbSeek( Inv->Codigo ) )
      Replace Anterior  With aMes[1] ,;
              Entradas  With aMes[2] , Salidas   With aMes[3]  , ;
              Ajustes_E With aMes[4] , Ajustes_S With aMes[5]  , ;
              Devol_E   With aMes[6] , Devol_S   With aMes[7]  , ;
              DevolCli  With aMes[8] , Actual    With nCant
   ElseIf nCant <> 0
      Append Blank
      Replace Empresa   With nEmpresa, Codigo    With Inv->Codigo,;
              AnoMes    With cPer    , Anterior  With aMes[1]  , ;
              Entradas  With aMes[2] , Salidas   With aMes[3]  , ;
              Ajustes_E With aMes[4] , Ajustes_S With aMes[5]  , ;
              Devol_E   With aMes[6] , Devol_S   With aMes[7]  , ;
              DevolCli  With aMes[8] , Actual    With nCant
   EndIf
   dbSelectArea( "Inv" )
   dbSkip()
EndDo
nLinea := nTante := nTexis := nTarqu := nFalta := nSobra := PAG := nK := 0
dbSelectArea( "Tem" )
dbGoTop()
While !Eof()
   If Titulo( "ARQUEO FISICO DEL INVENTARIO",141 )
      @ 6,00 Say Chr(15) + Replicate("_",141)
      @ 7,00 Say "                                    SALDO   TOTAL     TOTAL  DEVOLUCI DEVOLUCI  AJUSTE    AJUSTE DEVOLUCI   SALDO    ARQUEO FALTANTE SOBRANTE"
      @ 8,00 Say "CODIGO---- D E S C R I P C I O N  ANTERIOR ENTRADAS   VENTAS ENTRADAS  SALIDAS ENTRADAS  SALIDAS  CLIENTE   ACTUAL   FISICO"
      @ 9,00 Say Replicate("_",141)
      nLinea := 10
   EndIf
   aMes[1] := Anterior
   nDife := Cantidad - Actual
   If aMes[1] # 0 .OR. ;
      Actual  # 0 .OR. ;
      nDife  > 0
      Inv->(dbSeek( Tem->Codigo ))
      @ nLinea, 00 Say Codigo
      @ nLinea, 11 Say Left( Inv->Descrip,22 )
      @ nLinea, 34 Say Anterior  Pict "99,999.9"
      @ nLinea, 43 Say Entradas  Pict "@Z 99,999.9"
      @ nLinea, 52 Say Salidas   Pict "@Z 99,999.9"
      @ nLinea, 61 Say Ajustes_E Pict "@Z 99,999.9"
      @ nLinea, 70 Say Ajustes_S Pict "@Z 99,999.9"
      @ nLinea, 79 Say Devol_E   Pict "@Z 99,999.9"
      @ nLinea, 88 Say Devol_S   Pict "@Z 99,999.9"
      @ nLinea, 97 Say DevolCli  Pict "@Z 99,999.9"
      @ nLinea,106 Say Actual    Pict "99,999.9"
      @ nLinea,115 Say Cantidad  Pict "99,999.9"
      If nDife < 0
         @ nLinea,124 Say Abs(nDife) Pict "99,999.9"
         nFalta += Abs(nDife)
      ElseIf nDife > 0
         @ nLinea,133 Say Abs(nDife) Pict "99,999.9"
         nSobra += Abs(nDife)
      EndIf
      nLinea ++
      nTante += aMes[1]
      nTexis += Actual
      nTarqu += Cantidad
   EndIf
   dbSkip()
EndDo
If nK # 27
   @ nLinea  , 00 Say Replicate("_",141)
   @ nLinea+1, 06 Say "TOTALES"
   @ nLinea+1, 34 Say nTante  Pict "99,999.9"
   @ nLinea+1,106 Say nTexis  Pict "99,999.9"
   @ nLinea+1,115 Say nTarqu  Pict "99,999.9"
   @ nLinea+1,124 Say nFalta  Pict "99,999.9"
   @ nLinea+1,133 Say nSobra  Pict "99,999.9"
   @ nLinea+2, 00 Say Replicate("_",141)
EndIf
Retu */

//------------------------------------//
METHOD ListoCod() CLASS TArqueo
   LOCAL aRes, aTot, hRes, nL, oRpt
hRes := ::Query( 2 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY ARQUEO","EN "+::aLS[1] )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[4] == 2
   ::LaserCod( hRes, nL )
   RETURN NIL
EndIf
aTot := { 0,0,0,0 }
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"CODIGOS DEL ARQUEO FISICO",;
          "EN " + NtChr( NtChr( ::aLS[1],"F" ),"6" )            ,;
          "CODIGO----  D E S C R I P C I O N                   "+;
          "  EXISTENCIA   PREC.COSTO   TOTAL COSTO" },::aLS[5],,2 )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aTot[4] := aRes[3] * aRes[4]
   oRpt:Titulo( 91 )
   oRpt:Say( oRpt:nL,00,aRes[1] )
   oRpt:Say( oRpt:nL,12,aRes[2] )
   oRpt:Say( oRpt:nL,52,TRANSFORM(aRes[3],"999,999.9999") )
   oRpt:Say( oRpt:nL,67,TRANSFORM(aRes[4],"999,999.99") )
   oRpt:Say( oRpt:nL,79,TRANSFORM(aTot[4],"999,999.9999") )
   oRpt:nL ++
   aTot[1] += aRes[3]
   aTot[2] += aTot[4]
   aTot[3] ++
   nL --
EndDo
MSFreeResult( hRes )
   oRpt:Say(  oRpt:nL,00,REPLICATE("_",91) )
   oRpt:Say(++oRpt:nL,15,"TOTALES" + STR(aTot[3]) )
   oRpt:Say(  oRpt:nL,52,TRANSFORM(aTot[1],"999,999.9999") )
   oRpt:Say(  oRpt:nL,79,TRANSFORM(aTot[2],"999,999.9999") )
   oRpt:NewPage()
   oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserCod( hRes, nL ) CLASS TArqueo
   LOCAL aRes, aTot := { 0,0,0,0 }
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit,;
             "CODIGOS DEL ARQUEO FISICO","EN "+NtChr( NtChr( ::aLS[1],"F" ),"6" ),;
             { .F., 0.5,"C O D I G O" }, { .F., 3.0,"D E S C R I P C I O N" },;
             { .T.,14.0,"EXISTENCIA" } , { .T.,17.0,"PRECIO COSTO" }         ,;
             { .T.,20.0,"TOTAL COSTO" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[5] ,,, ::aLS[5] )
 ::nMD := 20
  PAGE
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aTot[4] := aRes[3] * aRes[4]
   ::Cabecera( .t.,0.42 )
   UTILPRN ::oUtil Self:nLinea, 0.5 SAY aRes[1]
   UTILPRN ::oUtil Self:nLinea, 3.0 SAY aRes[2]
   UTILPRN ::oUtil Self:nLinea,14.0 SAY TRANSFORM(aRes[3],   "999,999.9999") RIGHT
   UTILPRN ::oUtil Self:nLinea,17.0 SAY TRANSFORM(aRes[4],   "999,999.99")   RIGHT
   UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM(aTot[4],"99,999,999.99")   RIGHT
   aTot[1] += aRes[3]
   aTot[2] += aTot[4]
   aTot[3] ++
   nL --
EndDo
MSFreeResult( hRes )
   ::Cabecera( .t.,0.4,1.30,20 )
   UTILPRN ::oUtil Self:nLinea, 3.0 SAY "T O T A L E S" + STR(aTot[3])
   UTILPRN ::oUtil Self:nLinea,14.0 SAY TRANSFORM(aTot[1], "9,999,999.9999") RIGHT
   UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM(aTot[2],"99,999,999.99")   RIGHT
  ENDPAGE
 ::EndInit( .F. )
RETURN NIL

//------------------------------------//
METHOD Query( nH,cQry ) CLASS TArqueo
   LOCAL hRes
If nH == 1
   cQry := "SELECT s.codigo, s.entradas, s.salidas, s.devol_e, s.devol_s, "  +;
           "s.ajustes_e, s.ajustes_s, s.devolcli, s.existencia, s.anomes, 0 "+;
           "FROM cadinvme s "                                        +;
           "WHERE s.empresa = " + LTRIM(STR(oApl:nEmpresa))          +;
            " AND s.anomes  = (SELECT MAX(m.anomes) FROM cadinvme m "+;
                              "WHERE m.empresa = s.empresa"          +;
                               " AND m.codigo  = s.codigo"           +;
                               " AND m.anomes <= '" + ::aLS[1] + "')"+;
       " AND (s.existencia <> 0 OR s.anomes = '" + ::aLS[1] + "')"   +;
       " UNION " + cQry + " ORDER BY codigo"
ElseIf nH == 2
   cQry := "SELECT a.codigo, i.descrip, a.cantidad, i.pcosto, a.vitrina "+;
           "FROM cadarque a LEFT JOIN cadinven i "         +;
            "USING( codigo ) "                             +;
           "WHERE a.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND a.anomes  = '" + ::aLS[1] + "' ORDER BY vitrina"
EndIf
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry, ),;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
RETURN hRes