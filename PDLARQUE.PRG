// Programa.: INOARQUE.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Arqueo fisico al inventario
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl, oArq

PROCEDURE InoArque()
   LOCAL oDlg, oGet := ARRAY(5)
   LOCAL aOpc := { "   ",NtChr( DATE(),"1" ),oApl:nEmpresa,TInv() }
   PUBLIC oArq
aOpc[4]:New()
oArq := oApl:Abrir( "cadarque","Empresa, Codigo, Anomes",.t. )

DEFINE DIALOG oDlg TITLE "Arqueo Fisico al Inventario" FROM 0, 0 TO 07,42
   @ 02, 00 SAY "Empresa" OF oDlg RIGHT PIXEL SIZE 96,10
   @ 02, 98 GET oGet[1] VAR aOpc[1] OF oDlg PICTURE "!!!"           ;
      VALID Eval( {|| If( oApl:oEmp:Seek( {"localiz",aOpc[1]} )    ,;
                      (oApl:nEmpresa := oApl:oEmp:EMPRESA,.t. )    ,;
                      (MsgStop("Esta Empresa NO EXISTE"), .f.) ) } );
      SIZE 24,12 PIXEL
   @ 16, 00 SAY  "DIGITE AÑO Y MES [AAMM]" OF oDlg RIGHT PIXEL SIZE 96,10
   @ 16, 98 GET oGet[2] VAR aOpc[2] OF oDlg SIZE 36,12 PIXEL;
      VALID NtChr( aOpc[2],"P" )
   @ 32, 10 BUTTON oGet[3] PROMPT "Aceptar"   SIZE 44,12 OF oDlg ACTION;
      ( Arqueos( aOpc ), oGet[3]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 32, 60 BUTTON oGet[4] PROMPT "Cancelar"  SIZE 44,12 OF oDlg CANCEL;
      ACTION ( oDlg:End() ) PIXEL
   @ 32,110 BUTTON oGet[5] PROMPT "Historial" SIZE 44,12 OF oDlg ACTION;
      ( ArqueHis( aOpc ), oGet[5]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED

oArq:Destroy()
RELEASE oArq
RETURN

//------------------------------------//
STATIC PROCEDURE ArqueHis( aLS )
   LOCAL oDlg, oGet := ARRAY(1), oLbx, cCod := SPACE(12)
DEFINE DIALOG oDlg TITLE "HISTORIAL ARQUEO " + aLS[1] FROM 0, 0 TO 15,43
   @ 02,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 66,10
   @ 02,70 GET oGet[1] VAR cCod OF oDlg PICTURE "999999999999"        ;
      VALID If( oApl:oInv:Seek( {"codigo",cCod} )                    ,;
              (oArq:Seek( { "empresa",oApl:nEmpresa,"codigo",cCod } ),;
               oLbx:GoBottom(), oDlg:Update(), .t. )                 ,;
              ( MsgStop( "Este Código NO EXISTE !!!" ), .f. ) )       ;
      SIZE 50,12 PIXEL
   @ 20,06 LISTBOX oLbx FIELDS oArq:ANOMES            ,;
                               oArq:VITRINA           ,;
                    TRANSFORM( oArq:CANTIDAD,"99,999" );
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
   MySetBrowse( oLbx, oArq )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT ;
   (oArq:Seek( { "empresa",oApl:nEmpresa,"codigo",cCod } ))
RETURN

//------------------------------------//
STATIC PROCEDURE Arqueos( aLS )
   LOCAL oDlg, oGet := ARRAY(7), bGrabar
   LOCAL oAr := aLS[4], dFecha := CTOD( NtChr( NtChr( aLS[2],"F" ),"4" ) )
bGrabar := {|| If( oArq:lOK,                          ;
                 ( oArq:Update(), oGet[7]:Disable() ),;
                 ( oArq:Empresa := oApl:nEmpresa     ,;
                   oArq:ANOMES  := aLS[2]            ,;
                   oArq:Append() ) ),  oArq:xBlank() ,;
               oDlg:Update(), oDlg:SetFocus() }
oArq:xBlank()
oAr:oDb:Seek( {"codigo",oArq:CODIGO} )

DEFINE DIALOG oDlg TITLE "ARQUEO " + aLS[1] FROM 0, 0 TO 10,50
   @ 02,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 66,10
   @ 02,70 BTNGET oGet[1] VAR oAr:xVar OF oDlg PICTURE "999999999999";
      VALID If( Buscar( oAr,dFecha,aLS[2] )                         ,;
              (If( oArq:lOK,  oGet[7]:Enable()                      ,;
                 ( oGet[7]:Disable(), oArq:CODIGO := oAr:xVar ) )   ,;
                oDlg:Update(), .t. ), .f. )                          ;
      SIZE 56,12 PIXEL UPDATE  RESOURCE "BUSCAR"                     ;
      ACTION EVAL({|| If(oAr:Mostrar(), (oAr:xVar := oAr:oDb:CODIGO ,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
   @ 16,50 SAY    oGet[2] VAR oAr:oDb:DESCRIP OF oDlg PIXEL SIZE 140,12 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 30,00 SAY "Cantidad" OF oDlg RIGHT PIXEL SIZE 66,8
   @ 30,70    GET oGet[3] VAR oArq:CANTIDAD OF oDlg PICTURE "9,999";
      VALID {|| If( oArq:CANTIDAD <= 0, ;
          (MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>" ), .f.),;
          (If( oAr:oDb:GRUPO == "1" .AND. oArq:CANTIDAD > 1,;
          (MsgStop( "En Montura la Cantidad debe ser 1","<< OJO >>"),.f.), .t.))) };
      SIZE 40,12 PIXEL UPDATE
   @ 44,00 SAY  "Vitrina" OF oDlg RIGHT PIXEL SIZE 66,8
   @ 44,70    GET oGet[4] VAR oArq:VITRINA OF oDlg PICTURE "@!";
      SIZE 30,12 PIXEL UPDATE
   @ 60, 40 BUTTON oGet[5] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION;
      (If( EMPTY( oArq:CODIGO ) .OR. oArq:CANTIDAD <= 0               ,;
         (MsgStop("Imposible grabar este CODIGO"), oGet[1]:SetFocus()),;
          EVAL(bGrabar) )) PIXEL
   @ 60, 90 BUTTON oGet[6] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 60,140 BUTTON oGet[7] PROMPT "Borrar"   SIZE 44,12 OF oDlg ACTION;
      (DelRecord( oArq ), oGet[7]:Disable(), oDlg:SetFocus()) PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT (oGet[7]:Disable(), oDlg:Move(240,200) )
RETURN

//------------------------------------//
STATIC FUNCTION Buscar( oAr,dFecha,cPer )
   LOCAL lSi := oAr:oDb:Seek( {"codigo",oAr:xVar} )
oArq:Seek( { "empresa",oApl:nEmpresa,"codigo",oAr:xVar,"anomes",cPer } )
If !lSi
   If oArq:lOK
      lSi := .t.
   Else
      MsgStop( oAr:xVar + " NO EXISTE","Este Código" )
   EndIf
EndIf
RETURN lSi

//-Listar Arqueo fisico al inventario-//
PROCEDURE InoLiArq( lResu )
   LOCAL oBar, oGet := ARRAY(5), aOpc := { NtChr( DATE(),"1" ),1,.f.,"","" }
   LOCAL aRep := { {|| ListoArq( aOpc,oApl:aWHija[1] ) },"Listo el Arqueo Fisico" }
   DEFAULT lResu := .f.
If lResu
   aRep := { {|| ListoCod( aOpc,oApl:aWHija[1] ) },"Listar Codigos del Arqueo" }
EndIf
If oApl:aWHija[1] == NIL
   DEFINE WINDOW oApl:aWHija[1] OF oApl:oWnd NOMINIMIZE NOMAXIMIZE ;
          TITLE aRep[2] ;
          FROM 0,0 TO 180,400 PIXEL MDICHILD
   DEFINE BUTTONBAR oBar OF oApl:aWHija[1] SIZE 25,25 _3D

   DEFINE BUTTON OF oBar RESOURCE "Exit3" NOBORDER;
          ACTION oApl:aWHija[1]:End() TOOLTIP "Salida"
   @ 30, 00 SAY "DIGITE AÑO Y MES [AAMM]" OF oApl:aWHija[1] RIGHT PIXEL SIZE 180,16
   @ 30,186 GET oGet[1] VAR aOpc[1] OF oApl:aWHija[1] SIZE 54,18 PIXEL;
      VALID NtChr( aOpc[1],"P" )
   @ 30,280 CHECKBOX oGet[2] VAR aOpc[3] PROMPT "Vista &Previa" OF oApl:aWHija[1] ;
      SIZE 94,16 PIXEL
   @ 90,186 BUTTON oGet[3] PROMPT "Aceptar"  SIZE 60,20 OF oApl:aWHija[1] ;
      ACTION ( EVAL( aRep[1] ) ) PIXEL
   @ 120, 10 SAY  oGet[4] VAR aOpc[4] OF oApl:aWHija[1] PIXEL SIZE 180,18 ;
      UPDATE COLOR nRGB( 0,255,0 )
   @ 120,200 SAY  oGet[5] VAR aOpc[5] OF oApl:aWHija[1] PIXEL SIZE  80,18 ;
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
STATIC PROCEDURE ListoArq( aLS,oDlg )
   LOCAL aMes := ARRAY(9)
   LOCAL oRpt, oExt, oArq, nK
oArq := oApl:Abrir( "cadarque","Empresa, Codigo, Anomes" )
oArq:Seek( { "empresa",oApl:nEmpresa,"anomes",aLS[1] } )
If !oArq:lOK
   MsgInfo( "NO HAY ARQUEO","EN "+aLS[1] )
   oArq:Destroy()
   RETURN
EndIf
aLS[4] := "Por Favor Espere Mientras Comparo"
oDlg:Update()
oExt := oApl:Abrir( "cadsaldo","Codigo",,.t. )
oArq:dbEval( {|o| aLS[5] := o:CODIGO, oDlg:Update()       ,;
                  oExt:xBlank() , oExt:CODIGO := o:CODIGO ,;
                  oExt:CANTIDAD := o:CANTIDAD             ,;
                  oExt:Append() } )
oArq:Destroy()
oMes := oApl:Abrir( "cadinvme","Empresa, Codigo, Anomes" )
oApl:oInv:Setorder( 2 ) //Codigo
oApl:oInv:GoTop():Read()
oApl:oInv:xLoad()

While !oApl:oInv:EOF()
   aLS[5] := oApl:oInv:CODIGO
   oDlg:Update()
   oArq:Seek( { "empresa",oApl:nEmpresa,"codigo",aLS[5],;
                "anomes <= ",aLS[1] },,.f. )
   If oArq:lOK
      AFILL( aMes,0 )
         aMes[2] := oArq:EXISTENCIA
      If aLS[1]  == oArq:ANOMES
         aMes[3] := oArq:ENTRADAS
         aMes[4] := oArq:SALIDAS
         aMes[5] := oArq:AJUSTES_E
         aMes[6] := oArq:AJUSTES_S
         aMes[7] := oArq:DEVOL_E
         aMes[8] := oArq:DEVOL_S
         aMes[9] := oArq:DEVOLCLI
      EndIf
      If oArq:nRowCount > 1
         oArq:Skip(-1):Read()
         oArq:xLoad()
         aMes[1] := oArq:EXISTENCIA
      EndIf
      If oExt:Seek( {"codigo",aLS[5]} )
         oExt:EXISTE_AN := aMes[1] ; oExt:EXISTE_AC := aMes[2]
         oExt:ENTRADAS  := aMes[3] ; oExt:SALIDAS   := aMes[4]
         oExt:AJUSTES_E := aMes[5] ; oExt:AJUSTES_S := aMes[6]
         oExt:DEVOL_E   := aMes[7] ; oExt:DEVOL_S   := aMes[8]
         oExt:DEVOLCLI  := aMes[9] ; oExt:Update( .f.,1 )
      ElseIf aMes[2] # 0
         oExt:xBlank()             ; oExt:CODIGO    := aLS[5]
         oExt:EXISTE_AN := aMes[1] ; oExt:EXISTE_AC := aMes[2]
         oExt:ENTRADAS  := aMes[3] ; oExt:SALIDAS   := aMes[4]
         oExt:AJUSTES_E := aMes[5] ; oExt:AJUSTES_S := aMes[6]
         oExt:DEVOL_E   := aMes[7] ; oExt:DEVOL_S   := aMes[8]
         oExt:DEVOLCLI  := aMes[9] ; oExt:Insert()
      EndIf
   EndIf
   oApl:oInv:Skip(1):Read()
   oApl:oInv:xLoad()
EndDo
oArq:Destroy()
AFILL( aMes,0 )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"ARQUEO FISICO DEL INVENTARIO",;
         "EN " + NtChr( NtChr( aLS[1],"F" ),"6" ),SPACE(37) +;
         "SALDO   TOTAL     TOTAL  DEVOLUCI DEVOLUCI  AJUSTE    AJUSTE DEVOLUCI   SALDO    ARQUEO",;
         "C O D I G O- ----DESCRIPCION-----  ANTERIOR ENTRADAS   VENTAS ENTRADAS"+;
         "  SALIDAS ENTRADAS  SALIDAS  CLIENTE   ACTUAL   FISICO FALTANTE SOBRANTE"},;
         aLS[3],,2 )
oExt:Seek( { "codigo >=",aLS[2] } )
While !oExt:EOF()
   aMes[7] := oExt:CANTIDAD - oExt:EXISTE_AC
   If oExt:EXISTE_AN # 0 .OR. ;
      oExt:EXISTE_AC # 0 .OR. aMes[7] > 0
      oApl:oInv:Seek( {"codigo",oExt:CODIGO} )
      oRpt:Titulo( 141 )
      oRpt:Say( oRpt:nL, 00,oExt:CODIGO )
      oRpt:Say( oRpt:nL, 13,oApl:oInv:DESCRIP )
      oRpt:Say( oRpt:nL, 35,TRANSFORM(oExt:EXISTE_AN,   "99,999.9") )
      oRpt:Say( oRpt:nL, 44,TRANSFORM(oExt:ENTRADAS ,"@Z 99,999.9") )
      oRpt:Say( oRpt:nL, 53,TRANSFORM(oExt:SALIDAS  ,"@Z 99,999.9") )
      oRpt:Say( oRpt:nL, 62,TRANSFORM(oExt:DEVOL_E  ,"@Z 99,999.9") )
      oRpt:Say( oRpt:nL, 71,TRANSFORM(oExt:DEVOL_S  ,"@Z 99,999.9") )
      oRpt:Say( oRpt:nL, 80,TRANSFORM(oExt:AJUSTES_E,"@Z 99,999.9") )
      oRpt:Say( oRpt:nL, 89,TRANSFORM(oExt:AJUSTES_S,"@Z 99,999.9") )
      oRpt:Say( oRpt:nL, 98,TRANSFORM(oExt:DEVOLCLI ,"@Z 99,999.9") )
      oRpt:Say( oRpt:nL,107,TRANSFORM(oExt:EXISTE_AC,   "99,999.9") )
      oRpt:Say( oRpt:nL,116,TRANSFORM(oExt:CANTIDAD ,   "99,999.9") )
      If aMes[7] < 0
         oRpt:Say( oRpt:nL,125,TRANSFORM(ABS(aMes[7]),  "99,999.9") )
         aMes[5] += ABS(aMes[7])
      ElseIf aMes[7] > 0
         oRpt:Say( oRpt:nL,134,TRANSFORM(ABS(aMes[7]),  "99,999.9") )
         aMes[6] += ABS(aMes[7])
      EndIf
      oRpt:nL++
      aMes[2] += oExt:EXISTE_AN
      aMes[3] += oExt:EXISTE_AC
      aMes[4] += oExt:CANTIDAD
   EndIf
   oExt:Skip(1):Read()
   oExt:xLoad()
EndDo
If oRpt:nPage > 0
   oRpt:Titulo( 141 )
   oRpt:Say(  oRpt:nL, 00,REPLICATE("_",141),,,1 )
   oRpt:Say(++oRpt:nL, 15,"TOTALES",,,1 )
   oRpt:Say(  oRpt:nL, 35,TRANSFORM(aMes[2],"99,999.9") )
   oRpt:Say(  oRpt:nL,107,TRANSFORM(aMes[3],"99,999.9") )
   oRpt:Say(  oRpt:nL,116,TRANSFORM(aMes[4],"99,999.9") )
   oRpt:Say(  oRpt:nL,125,TRANSFORM(aMes[5],"99,999.9") )
   oRpt:Say(  oRpt:nL,134,TRANSFORM(aMes[6],"99,999.9") )
   oRpt:NewPage()
EndIf
oRpt:End()
oExt:Destroy()
MSQuery( oApl:oMySql:hConnect,"DROP TABLE cadsaldo" )
oApl:oDb:GetTables()
RETURN

//------------------------------------//
STATIC PROCEDURE ListoCod( aLS,oDlg )
   LOCAL oArq, cO, nCol := 1, nTarqu := 0
   LOCAL oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"CODIGOS DEL ARQUEO FISICO",;
           "EN " + NtChr( NtChr( aLS[1],"F" ),"6" ) },aLS[3] )
oArq := oApl:Abrir( "cadarque","Vitrina, Codigo" )
oArq:Seek( { "empresa",oApl:nEmpresa,"LEFT(codigo,2)","01","anomes",aLS[1] } )
While !oArq:EOF()
   cO := If( oApl:oInv:Seek( {"codigo",oArq:CODIGO} ), " ", " N.E" )
//   Etiqueta( oArq:CODIGO )
   oRpt:Titulo( 78 )
   oRpt:Say( oRpt:nL,nCol,oArq:VITRINA +"-" +SUBSTR( oArq:CODIGO,5,6 ) +cO )
   nCol   += 16
   nTarqu += oArq:CANTIDAD
   If nCol > 65
      nCol := 1
      oRpt:nL++
   EndIf
   oArq:Skip(1):Read()
   oArq:xLoad()
EndDo
oArq:Destroy()
If nTarqu > 0
   oRpt:nL += If( nCol == 1, 0, 1 )
   oRpt:Say(  oRpt:nL,01,REPLICATE("_",78) )
   oRpt:Say(++oRpt:nL,15,"TOTALES" )
   oRpt:Say(  oRpt:nL,45,TRANSFORM(nTarqu,"99,999") )
EndIf
oRpt:NewPage()
oRpt:End()
RETURN