// Programa.: CAOLIEXT.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Extracto de un Cliente
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

PROCEDURE CaoLiExt()
   LOCAL oDlg, oGet := ARRAY(7), aOpc := { 0,CTOD(""),DATE(),.f.,"" }
   LOCAL oNi := TNits()
oNi:New()
DEFINE DIALOG oDlg TITLE "Listo Extracto de un Cliente" FROM 0, 0 TO 10,50
   @ 02,00 SAY "Nit o C.C. del Cliente" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02,92 BTNGET oGet[1] VAR aOpc[1] OF oDlg PICTURE "999999999999";
      VALID EVAL( {|| If( oNi:oDb:Seek( {"Codigo",aOpc[1]} )        ,;
                        ( oGet[7]:Settext( oNi:oDb:NOMBRE ), .t. )  ,;
                    (MsgStop("Este Nit ó C.C. no Existe.."),.f.)) }) ;
      RESOURCE "BUSCAR"                            SIZE 58,12 PIXEL  ;
      ACTION EVAL({|| If(oNi:Mostrar(), (aOpc[1] := oNi:oDb:CODIGO  ,;
                         oGet[1]:Refresh() ), ) })
   @ 16, 40 SAY oGet[7] VAR aOpc[5] OF oDlg PIXEL SIZE 130,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 30,00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 30,92 GET oGet[2] VAR aOpc[2] OF oDlg  SIZE 40,12 PIXEL
   @ 44,00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 44,92 GET oGet[3] VAR aOpc[3] OF oDlg ;
      VALID aOpc[3] >= aOpc[2] SIZE 40,12 PIXEL
   @ 44,150 CHECKBOX oGet[4] VAR aOpc[4] PROMPT "Vista &Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 60, 50 BUTTON oGet[5] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( ListoExt( aOpc ), oDlg:End() ) PIXEL
   @ 60,110 BUTTON oGet[6] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 66, 02 SAY "[CAOLIEXT]" OF oDlg PIXEL SIZE 30,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT Empresa()
RETURN

//------------------------------------//
STATIC PROCEDURE ListoExt( aLS )
   LOCAL aVence := ARRAY(9), oDPrn, oExt
   LOCAL aPago := { "Efectivo ","Cheque   ","T.Debito ","T.Credito","Bono","","",;
                    "N.Credito","N.Debito ","Anulada  " }
aLS[1] := oApl:oNit:CODIGO_NIT
oExt := oApl:Abrir( "extracto","Fechoy",,.t. )
oApl:Tipo := "U"
AFILL( aVence,0 )
/*
aRes := "SELECT u.Numfac, u.Fechoy, u.Cliente, u.Totalfac, "     +;
        "p.Fecpag, p.Abono, p.Retencion, p.Deduccion, "  +;
        "p.Descuento, p.Pagado, p.Formapago "                           +;
        "FROM cadfactu u LEFT JOIN cadpagos p ON u.Empresa = p.Empresa "+;
          "AND u.Numfac = p.Numfac AND u.Tipo = p.Tipo "+;
          "AND p.Indicador <> 'A' "                     +;
        "WHERE u.Empresa = " +  LTRIM(STR(oApl:nEmpresa)+;
         " AND u.Codigo_nit = "+LTRIM(STR( aLS[1] ) )   +;
         " AND u.Fechoy <= " + xValToChar( aLS[3] )     +;
         " AND u.Tipo   = "  + xValToChar(oApl:Tipo)    +;
         " AND u.Indicador <> 'A'"                      +;
         " ORDER BY u.Fechoy, u.Numfac"*/
oApl:oFac:Seek( {"Empresa",oApl:nEmpresa,"Codigo_nit",aLS[1],"Fechoy <= ",aLS[3],;
                 "Tipo",oApl:Tipo,"Indicador <> ","A"} )
While !oApl:oFac:Eof()
   If oApl:oFac:FECHOY < aLS[2] .AND. DAY( aLS[2] ) == 1
      oApl:cPer := NtChr( aLS[2]-1,"1" )
      aVence[7] += SaldoFac( oApl:oFac:NUMFAC,oApl:oFac:TIPO )
   EndIf
   oApl:cPer    := NtChr( aLS[3],"1" )
   oApl:nSaldo  := SaldoFac( oApl:oFac:NUMFAC,1 )
   Vence( aLS[3] - oApl:oFac:FECHOY,@aVence )
   oExt:xBlank()
   oExt:NUMFAC  := oApl:oFac:NUMFAC  ; oExt:TIPO    := oApl:oFac:TIPO
   oExt:FECHOY  := oApl:oFac:FECHOY  ; oExt:CLIENTE := oApl:oFac:CLIENTE
   oExt:VALOR   := oApl:oFac:TOTALFAC; oExt:DEBITOS := oApl:oFac:TOTALFAC
   oExt:CREDITOS:= 0                 ; oExt:Insert()
   oApl:oPag:Seek( {"Empresa",oApl:nEmpresa,"Numfac",oApl:oFac:NUMFAC,;
                    "Tipo",oApl:oFac:TIPO,"Indicador <> ","A"} )
   While !oApl:oPag:Eof()
      oExt:xBlank()               ; oExt:NUMFAC := oApl:oPag:NUMFAC
      oExt:TIPO := oApl:oPag:TIPO ; oExt:FECHOY := oApl:oPag:FECPAG
      If oApl:oPag:FORMAPAGO >= 7
         oExt:CLIENTE  := aPago[oApl:oPag:FORMAPAGO+1] + oApl:oPag:NUMCHEQUE
         oExt:VALOR    := oApl:oPag:PAGADO * If( oApl:oPag:FORMAPAGO == 8, 1, -1 )
         oExt:DEBITOS  := If( oExt:VALOR > 0, oApl:oPag:PAGADO, 0 )
         oExt:CREDITOS := If( oExt:VALOR < 0, oApl:oPag:PAGADO, 0 )
      Else
         oExt:CLIENTE  := aPago[oApl:oPag:FORMAPAGO+1] + oApl:oPag:CODBANCO
         oExt:CREDITOS := oApl:oPag:ABONO    + oApl:oPag:RETENCION + ;
                          oApl:oPag:DEDUCCION+ oApl:oPag:DESCUENTO + ;
                          oApl:oPag:RETICA   + oApl:oPag:RETIVA    +oApl:oPag:RETFTE
         oExt:VALOR    := -oExt:CREDITOS
      EndIf
         oExt:Insert()
      oApl:oPag:Skip(1):Read()
      oApl:oPag:xLoad()
   EndDo
   oApl:oFac:Skip(1):Read()
   oApl:oFac:xLoad()
EndDo
oApl:nSaldo := aVence[7]
oDPrn := TDosPrint()
oDPrn:New( oApl:cPuerto,oApl:cImpres,{"EXTRACTO DE CUENTAS POR COBRAR" ,;
         ALLTRIM( oApl:oNit:NOMBRE ) + "  DESDE " + NtChr( aLS[2],"2" )+;
         " HASTA " + NtChr( aLS[3],"2" ),"-F E C H A- DOCUMENTO ----"  +;
         "DESCRIPCION-----     DEBITOS    CREDITOS  -S A L D O-"},aLS[4] )
oExt:Seek( { "Fechoy >=",aLS[2],"Fechoy <=",aLS[3] } )
While !oExt:EOF()
   oApl:nSaldo += oExt:VALOR
   oDPrn:Titulo( 79 )
   oDPrn:Say( oDPrn:nL,00,NtChr( oExt:FECHOY,"2" ) )
   oDPrn:Say( oDPrn:nL,12,STR(oExt:NUMFAC,8) )
   oDPrn:Say( oDPrn:nL,22,oExt:CLIENTE )
   oDPrn:Say( oDPrn:nL,43,TransForm(oExt:DEBITOS ,"@Z 999,999,999") )
   oDPrn:Say( oDPrn:nL,55,TransForm(oExt:CREDITOS,"@Z 999,999,999") )
   oDPrn:Say( oDPrn:nL,68,TransForm( oApl:nSaldo ,   "999,999,999") )
   oDPrn:nL ++
   aVence[8] += oExt:DEBITOS
   aVence[9] += oExt:CREDITOS
   oExt:Skip(1):Read()
   oExt:xLoad()
EndDo
If oDPrn:nPage > 0
   oDPrn:Separator( 0,8 )
   oDPrn:Say( oDPrn:nL++,29,REPLICATE("=",50) )
   oDPrn:Say( oDPrn:nL++,29,"SALDO ANTER   TOT.DEBITOS TOT.CREDITO  NUEVO SALDO" )
   oDPrn:Say( oDPrn:nL  ,29,TransForm( aVence[7] ,"999,999,999") )
   oDPrn:Say( oDPrn:nL  ,43,TransForm( aVence[8] ,"999,999,999") )
   oDPrn:Say( oDPrn:nL  ,55,TransForm( aVence[9] ,"999,999,999") )
   oDPrn:Say( oDPrn:nL++,68,TransForm(oApl:nSaldo,"999,999,999") )
   oDPrn:nL ++
   oDPrn:Say( oDPrn:nL++,25,"* * *  V E N C I M I E N T O S  * * *" )
   Vence( 0,aVence,10,oDPrn )
EndIf
oDPrn:NewPage()
oDPrn:End()
oExt:Destroy()
MSQuery( oApl:oMySql:hConnect,"DROP TABLE extracto" )
oApl:oDb:GetTables()
RETURN
