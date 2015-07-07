// Programa.: CAONOTAS.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Captura las notas DB Y CR a facturas
#include "FiveWin.ch"

MEMVAR oApl

PROCEDURE CaoNotas()
   LOCAL oDlg, oLbx, oGet := ARRAY(1), lSalir := .f.
   LOCAL aBarra, aN := { oApl:dFec,0,1,0,0,0 }, bSum
   LOCAL aDev := { "","","","","","","","CREDITO","DEBITO","ANULADA" }
aBarra := { {|| NotasEdita( oLbx,@aN,.t. ) } ,;
            {|| NotasEdita( oLbx,@aN,.f. ) } ,;
            {|| .t. }                        ,;
            {|| NotasBorra( oLbx,aN ) }      ,;
            {|| ListNota( {aN[1],0,1,.f.} ) },;
            {|| lSalir := .t., oDlg:End() } }
bSum := {|| oApl:oPag:Seek( { "Empresa",oApl:nEmpresa,"Fecpag",aN[1],;
                              "Formapago >= ",7,"Formapago <=",9 } ),;
            aN[2] := oApl:oPag:RecCount(), oApl:cPer := NtChr( aN[1],"1" ) }
DEFINE DIALOG oDlg FROM 0, 0 TO 320, 580 PIXEL;
   TITLE "Notas Debitos y Creditos"
   @ 02,00 SAY "Fecha [DD.MM.AAAA]" OF oDlg RIGHT PIXEL SIZE 76,10
   @ 02,80 GET oGet[1] VAR aN[1]    OF oDlg SIZE 40,12 PIXEL ;
      VALID ( EVAL( bSum ), oLbx:GoTop(), oDlg:Update(), .t. )
   @ 50,06 LISTBOX oLbx FIELDS                   ;
             STR(oApl:oPag:NUMFAC)              ,;
         Buscar( oApl:oPag:NUMFAC )             ,;
           aDev[ oApl:oPag:FORMAPAGO+1]         ,;
                 oApl:oPag:NUMCHEQUE            ,;
      TRANSFORM( oApl:oPag:PAGADO ,"99,999,999" );
      HEADERS "Número"+CRLF+"Factura", "Cliente", "Tipo",;
              "Nro.Documento", "Valor Nota";
      SIZES 400, 450 SIZE 280,100 ;
      OF oDlg UPDATE PIXEL        ;
      ON DBLCLICK EVAL( aBarra[2] )
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:GoTop()
    oLbx:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:nHeaderHeight := 28
    oLbx:aColSizes  := {90,200,90,90,100}
    oLbx:aHjustify  := {2,2,2,2,2}
    oLbx:aJustify   := {0,0,0,0,1}
    oLbx:bKeyDown := {|nKey| If(nKey == VK_ESCAPE, ( oGet[1]:SetFocus() ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(aBarra[1]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, EVAL(aBarra[2]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, EVAL(aBarra[4]),) ))) }
    oLbx:lCellStyle  := .f.
    oLbx:ladjlastcol := .t.
    oLbx:ladjbrowse  := .f.
   MySetBrowse( oLbx, oApl:oPag )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT     ;
  (EVAL( bSum ), oDlg:Move(80,1),;
   DefineBar( oDlg,oLbx,aBarra,66,18 ) );
   VALID lSalir
RETURN

//------------------------------------//
STATIC PROCEDURE NotasBorra( oLbx,aNot )
   LOCAL nRecNo := oApl:oPag:RecNo()
If aNot[2] > 0
   If MsgNoYes( "Está Nota"+STR(oApl:oPag:NUMFAC),"Elimina" )
      oApl:lFam := SaldoFac( oApl:oPag:NUMFAC )
      GrabaV( oApl:oPag:NUMFAC,oApl:oPag:FORMAPAGO,-oApl:oPag:PAGADO,.t. )
      If oApl:oPag:Delete( .t.,1 )
         oApl:oPag:GoTo( nRecNo ):Read()
      EndIf
      oLbx:SetFocus() ; oLbx:Refresh()
   EndIf
EndIf
RETURN

//------------------------------------//
STATIC FUNCTION NotasEdita( oLbx,aEst,lNew )
   LOCAL oDlg, aTip := { "CREDITO","DEBITO","ANULADA" }
   LOCAL bGrabar, oGet := ARRAY(8)
   LOCAL aEd := { oApl:oPag:Recno(),"Modificando Nota" }
lNew := If( aEst[2] == 0, .t., lNew )
If lNew
   oApl:oPag:xBlank()
   bGrabar := {|| Nuevo( aEst,lNew )             ,;
                  oLbx:Refresh(), oLbx:GoBottom(),;
                  oApl:oPag:xBlanK()             ,;
                  oDlg:Update() , oDlg:SetFocus(),;
                  aEst[2] ++ }
   aEd[2]  := "Nueva Nota"
   aEst[3] := 1
Else
   bGrabar := {|| Nuevo( aEst,lNew )             ,;
                  oApl:oPag:Go( aEd[1] ):Read()  ,;
                  oLbx:Refresh(), oDlg:End() }
   aEst[3] := oApl:oPag:FORMAPAGO - 6
   aEst[4] := oApl:oPag:NUMFAC
   aEst[5] := oApl:oPag:FORMAPAGO
   aEst[6] := oApl:oPag:PAGADO
EndIf
oApl:nSaldo := 0

DEFINE DIALOG oDlg TITLE aEd[2] FROM 0, 0 TO 14,50
   @ 02,00 SAY "Nro.Factura" OF oDlg RIGHT PIXEL SIZE 66,10
   @ 02,70 GET oGet[1] VAR oApl:oPag:NUMFAC OF oDlg PICTURE "9999999999";
      VALID If( Buscar( oApl:oPag:NUMFAC,lNew ), ;
                ( oDlg:Update(), .t. ), .f. )    ;
      SIZE 56,12 PIXEL
   @ 16,50 SAY oGet[2] VAR oApl:oFac:CLIENTE OF oDlg PIXEL SIZE 90,12 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 30,00 SAY "Saldo Fact."  OF oDlg RIGHT PIXEL SIZE 66,8
   @ 30,70 SAY oGet[3] VAR oApl:nSaldo  OF oDlg PICTURE "99,999,999.99";
      SIZE 50,12 PIXEL UPDATE COLOR nRGB( 128,0,255 )
   @ 44,00 SAY "Tipo de Nota" OF oDlg RIGHT PIXEL SIZE 66,8
   @ 44,70 COMBOBOX oGet[4] VAR aEst[3] ITEMS aTip SIZE 68,99;
      OF oDlg PIXEL UPDATE
   @ 58,00 SAY "Nro. Docum."  OF oDlg RIGHT PIXEL SIZE 66,8
   @ 58,70 GET oGet[5] VAR oApl:oPag:NUMCHEQUE OF oDlg PICTURE "999999";
      SIZE 50,12 PIXEL UPDATE
   @ 72,00 SAY "Valor  Nota"  OF oDlg RIGHT PIXEL SIZE 66,8
   @ 72,70 GET oGet[6] VAR oApl:oPag:PAGADO OF oDlg PICTURE "99,999,999.99";
      VALID {|| If( aEst[3] == 2,                               ;
          (If( oApl:oPag:PAGADO > oApl:oFac:TOTALFAC, (MsgStop( ;
           "Monto de la nota DEBITO > Total Factura" ),.f.),.t.)),;
          (If( oApl:oPag:PAGADO > oApl:nSaldo  , (MsgStop( ;
           "Monto de la nota CREDITO > Saldo" ),.f.),.t.)) ) } ;
      SIZE 50,12 PIXEL UPDATE
   @ 88, 70 BUTTON oGet[7] PROMPT "&Grabar"   SIZE 44,12 OF oDlg ACTION;
      (If( EMPTY(oApl:oPag:NUMFAC) .OR. oApl:oPag:PAGADO <= 0         ,;
         ( MsgStop("Imposible grabar está NOTA"), oGet[1]:SetFocus() ),;
          EVAL(bGrabar) )) PIXEL
   @ 88,120 BUTTON oGet[8] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
RETURN NIL

//------------------------------------//
STATIC FUNCTION Buscar( nFac,lNew )
   LOCAL lBuscar
lBuscar := oApl:oFac:Seek( { "Empresa",oApl:nEmpresa,"Numfac",nFac,"Tipo",oApl:Tipo } )
If lNew == nil
   lBuscar := oApl:oFac:CLIENTE
Else
   If lBuscar .AND. oApl:oFac:INDICADOR # "A"
      oApl:lFam := SaldoFac( nFac )
      oApl:oPag:PAGADO := If( lNew, oApl:nSaldo, oApl:oPag:PAGADO )
   Else
      MsgStop( If( oApl:oFac:INDICADOR == "A", "está Anulada", ;
               "NO EXISTE !!" ),"Factura" )
      lBuscar := .f.
   EndIf
EndIf
RETURN lBuscar

//------------------------------------//
STATIC FUNCTION Nuevo( aEst,lNew )
   LOCAL nPago := 0
oApl:oPag:FORMAPAGO := aEst[3]+6
If lNew
   oApl:oPag:EMPRESA := oApl:nEmpresa
   oApl:oPag:TIPO    := oApl:Tipo
   oApl:oPag:FECPAG  := aEst[1]
   oApl:oPag:Append( .t. )
Else
   nPago := -aEst[6] //PAGADO
   If aEst[4] # oApl:oPag:NUMFAC .OR.;
      aEst[5] # oApl:oPag:FORMAPAGO
      If aEst[4] # oApl:oPag:NUMFAC
         oApl:lFam := SaldoFac( aEst[4] )
         GrabaV( aEst[4],aEst[5],nPago,.t. )
      Else
         GrabaSal( oApl:oPag:NUMFAC,If( aEst[5] == 8, 2, 1 ),nPago )
      EndIf
      oApl:lFam := SaldoFac( oApl:oPag:NUMFAC )
      nPago     := 0
   EndIf
   oApl:oPag:Update( .f.,1 )
EndIf
nPago += oApl:oPag:PAGADO
GrabaV( oApl:oPag:NUMFAC,oApl:oPag:FORMAPAGO,nPago,.f. )
RETURN NIL

//------------------------------------//
STATIC PROCEDURE GrabaV( nNumfac,nMov,nPago,lCambia )
   LOCAL aCan := { "P",CTOD("") }, nSald
   LOCAL aD := { "D",oApl:oPag:FECPAG," " }
nMov := If( nMov == 8, 2, 1 )
If lCambia
   aD    := { " ",CTOD(""),"D" }
   nSald := oApl:nSaldo + If( nMov == 2, -nPago, nPago )
Else
   nSald := oApl:nSaldo + If( nMov == 2, nPago, -nPago )
EndIf
If nSald == 0
   aCan := { "C",oApl:oPag:FECPAG }
EndIf
oApl:oFac:Seek( { "Empresa",oApl:nEmpresa,"Numfac",nNumfac,"Tipo",oApl:Tipo } )
oApl:oFac:INDICADOR := aCan[1] ; oApl:oFac:FECHACAN := aCan[2]
oApl:oFac:Update( .f.,1 )
If nPago # 0
   GrabaSal( nNumfac,nMov,nPago )
EndIf
oApl:oVen:Seek( { "Empresa",oApl:nEmpresa,"Numfac",nNumfac,;
                  "Tipo",oApl:Tipo,"Indicador",aD[3] } )
While oApl:oPag:FORMAPAGO == 9 .AND. !oApl:oVen:EOF()
   oApl:oInv:Seek( {"Codigo",oApl:oVen:CODART} )
   nSald := oApl:oVen:CANTIDAD * If( lCambia, -1, 1 )
   oApl:oVen:INDICADOR := aD[1] ; oApl:oVen:FECDEV := aD[2]
   oApl:oVen:Update( .f.,1 )
   Actualiz( oApl:oVen:CODART,nSald,oApl:oPag:FECPAG,7 )
   oApl:oVen:Skip(1):Read()
   oApl:oVen:xLoad()
EndDo
RETURN

//------------------------------------//
PROCEDURE CaoLiNot()
   LOCAL oDlg, oGet := ARRAY(6), aNot := { DATE(),0,1,.f. }
DEFINE DIALOG oDlg FROM 0, 0 TO 160,370 PIXEL;
   TITLE "Listo Notas Creditos y Debitos"
   @ 02,00 SAY "Fecha [DD.MM.AAAA]" OF oDlg RIGHT PIXEL SIZE 96,10
   @ 02,98 GET oGet[1] VAR aNot[1] OF oDlg SIZE 40,12 PIXEL
   @ 16,00 SAY "Documento  0 Todos" OF oDlg RIGHT PIXEL SIZE 96,10
   @ 16,98 GET oGet[2] VAR aNot[2] OF oDlg PICTURE "9,999" SIZE 30,12 PIXEL
   @ 30,00 SAY "Pagina Inicial" OF oDlg RIGHT PIXEL SIZE 96,10
   @ 30,98 GET oGet[3] VAR aNot[3] OF oDlg PICTURE "999"   SIZE 12,12 PIXEL;
      VALID Rango( aNot[3],1,999 )
   @ 44,98 CHECKBOX oGet[4] VAR aNot[4] PROMPT "Vista &Previa" OF oDlg SIZE 60,12 PIXEL
   @ 60, 70 BUTTON oGet[5] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ;
      ACTION ( ListNota( aNot ), oDlg:End() ) PIXEL
   @ 60,120 BUTTON oGet[6] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION ( oDlg:End() ) PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
STATIC PROCEDURE ListNota( aLS )
   LOCAL aDC := { 0,0,0,"",.f.,"",oApl:oPag:cStatement }, nK, nC
   LOCAL oDPrn := TDosPrint()
oDPrn:New( oApl:cPuerto,oApl:cImpres,{"LISTADO DE COMPROBANTES DE DIARIO",;
         "EN " + NtChr( aLS[1],"6" ),"--FACTURA- DOCUM.  F E C H A  C L I " +;
         "E N T E           D E B I T O  C R E D I T O"},aLS[4],aLS[3] )
aDC[6]:= NtChr( LEFT( DTOS(aLS[1]),6 ),"F" )
aLS[2]:= ALLTRIM( STR(aLS[2]) )
oApl:oPag:Seek( { "Empresa",oApl:nEmpresa,"Tipo",oApl:Tipo,"Fecpag >= ",aDC[6],;
                  "Fecpag <= ",aLS[1],"Formapago >= ",7 } )
While !oApl:oPag:EOF()
   aDC[4] := ALLTRIM(oApl:oPag:NUMCHEQUE)
   If aLS[2] == "0" .OR. aLS[2] == aDC[4]
      nK := If( oApl:oPag:FORMAPAGO == 8, 1, 2 )
      oDPrn:Titulo( 80 )
      If oDPrn:nPage >= aLS[3]
         nC := If( nK == 1, 52, 67 )
         oApl:oFac:Seek( { "Empresa",oApl:nEmpresa,"Numfac",oApl:oPag:NUMFAC,;
                           "Tipo",oApl:Tipo } )
         oDPrn:Say( oDPrn:nL,00,STR(oApl:oPag:NUMFAC) )
         oDPrn:Say( oDPrn:nL,13,aDC[4] )
         oDPrn:Say( oDPrn:nL,18,NtChr( oApl:oPag:FECPAG,"2" ) )
         oDPrn:Say( oDPrn:nL,30,oApl:oFac:CLIENTE,20 )
         oDPrn:Say( oDPrn:nL,nC,TransForm(oApl:oPag:PAGADO,"99,999,999.99" ))
      EndIf
      aDC[nK] += oApl:oPag:PAGADO
      aDC[03] ++
      oDPrn:nL ++
   EndIf
   oApl:oPag:Skip(1):Read()
   oApl:oPag:xLoad()
EndDo
If oDPrn:nPage > 0
   aDC[4] := aDC[1] - aDC[2]
   oDPrn:Say( oDPrn:nL++,00,Replicate("_",80) )
   oDPrn:Say( oDPrn:nL  ,13,STR(aDC[3],4) + "  TOTALES" )
   oDPrn:Say( oDPrn:nL  ,52,TransForm(aDC[1],"99,999,999.99" ))
   oDPrn:Say( oDPrn:nL++,67,TransForm(aDC[2],"99,999,999.99" ))
EndIf
oDPrn:NewPage()
oDPrn:End()
oApl:oPag:Open( aDC[7],.f. )
oApl:oPag:Read()
RETURN
