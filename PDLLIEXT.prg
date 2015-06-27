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
      VALID EVAL( {|| If( oNi:oDb:Seek( {"codigo",aOpc[1]} )        ,;
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
   LOCAL aVence := ARRAY(9), oRpt, oExt
   LOCAL aPago := { "Efectivo ","Cheque   ","T.Debito ","T.Credito","Bono","","",;
                    "N.Credito","N.Debito ","Anulada  " }
aLS[1] := oApl:oNit:CODIGO_NIT
oExt := oApl:Abrir( "extracto","Fechoy",,.t. )
oApl:Tipo := "U"
AFILL( aVence,0 )
/*
aRes := "SELECT u.numfac, u.fechoy, u.cliente, u.totalfac, "     +;
        "p.fecpag, p.abono, p.retencion, p.deduccion, "  +;
        "p.descuento, p.pagado, p.formapago "                           +;
        "FROM cadfactu u LEFT JOIN cadpagos p ON u.empresa = p.empresa "+;
          "AND u.numfac = p.numfac AND u.tipo = p.tipo "+;
          "AND p.indicador <> 'A' "                     +;
        "WHERE u.empresa = " +  LTRIM(STR(oApl:nEmpresa)+;
         " AND u.codigo_nit = "+LTRIM(STR( aLS[1] ) )   +;
         " AND u.fechoy <= " + xValToChar( aLS[3] )     +;
         " AND u.tipo   = "  + xValToChar(oApl:Tipo)    +;
         " AND u.indicador <> 'A'"                      +;
         " ORDER BY u.fechoy, u.numfac"*/
oApl:oFac:Seek( {"empresa",oApl:nEmpresa,"codigo_nit",aLS[1],"fechoy <= ",aLS[3],;
                 "tipo",oApl:Tipo,"indicador <> ","A"} )
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
   oApl:oPag:Seek( {"empresa",oApl:nEmpresa,"numfac",oApl:oFac:NUMFAC,;
                    "tipo",oApl:oFac:TIPO,"indicador <> ","A"} )
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
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"EXTRACTO DE CUENTAS POR COBRAR" ,;
         ALLTRIM( oApl:oNit:NOMBRE ) + "  DESDE " + NtChr( aLS[2],"2" )+;
         " HASTA " + NtChr( aLS[3],"2" ),"-F E C H A- DOCUMENTO ----"  +;
         "DESCRIPCION-----     DEBITOS    CREDITOS  -S A L D O-"},aLS[4] )
oExt:Seek( { "fechoy >=",aLS[2],"fechoy <=",aLS[3] } )
While !oExt:EOF()
   oApl:nSaldo += oExt:VALOR
   oRpt:Titulo( 79 )
   oRpt:Say( oRpt:nL,00,NtChr( oExt:FECHOY,"2" ) )
   oRpt:Say( oRpt:nL,12,STR(oExt:NUMFAC,8) )
   oRpt:Say( oRpt:nL,22,oExt:CLIENTE )
   oRpt:Say( oRpt:nL,43,TRANSFORM(oExt:DEBITOS ,"@Z 999,999,999") )
   oRpt:Say( oRpt:nL,55,TRANSFORM(oExt:CREDITOS,"@Z 999,999,999") )
   oRpt:Say( oRpt:nL,68,TRANSFORM( oApl:nSaldo ,   "999,999,999") )
   oRpt:nL ++
   aVence[8] += oExt:DEBITOS
   aVence[9] += oExt:CREDITOS
   oExt:Skip(1):Read()
   oExt:xLoad()
EndDo
If oRpt:nPage > 0
   oRpt:Separator( 0,8 )
   oRpt:Say( oRpt:nL++,29,REPLICATE("=",50) )
   oRpt:Say( oRpt:nL++,29,"SALDO ANTER   TOT.DEBITOS TOT.CREDITO  NUEVO SALDO" )
   oRpt:Say( oRpt:nL  ,29,TRANSFORM( aVence[7] ,"999,999,999") )
   oRpt:Say( oRpt:nL  ,43,TRANSFORM( aVence[8] ,"999,999,999") )
   oRpt:Say( oRpt:nL  ,55,TRANSFORM( aVence[9] ,"999,999,999") )
   oRpt:Say( oRpt:nL++,68,TRANSFORM(oApl:nSaldo,"999,999,999") )
   oRpt:nL ++
   oRpt:Say( oRpt:nL++,25,"* * *  V E N C I M I E N T O S  * * *" )
   Vence( 0,aVence,10,oRpt )
EndIf
oRpt:NewPage()
oRpt:End()
oExt:Destroy()
MSQuery( oApl:oMySql:hConnect,"DROP TABLE extracto" )
oApl:oDb:GetTables()
RETURN

//-------Movimento de un Codigo-------//
PROCEDURE InoLiExt()
   LOCAL oDlg, oGet := ARRAY(7), oAr := TInv()
   LOCAL aVta := { SPACE(12),DATE(),DATE(),.t.,"" }
oAr:New()
DEFINE DIALOG oDlg TITLE "Extracto de un Código" FROM 0, 0 TO 11,52
   @ 02, 00 SAY "CODIGO DEL ARTICULO" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 02,102 BTNGET oGet[1] VAR aVta[1] OF oDlg PICTURE "!9999999!!";
      VALID EVAL( {|| If( oAr:oDb:Seek( {"codigo",aVta[1]} )      ,;
                ( oGet[2]:Settext( oAr:oDb:DESCRIP ), .t. )       ,;
                ( MsgStop("Este Código no Existe"),.f.)) } )       ;
      SIZE 58,12 PIXEL  RESOURCE "BUSCAR"                          ;
      ACTION Eval({|| If(oAr:Mostrar(), (aVta[1] := oAr:oDb:CODIGO,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
   @ 16, 40 SAY oGet[2] VAR aVta[5] OF oDlg PIXEL SIZE 120,12;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 30, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 30,102 GET oGet[3] VAR aVta[2] OF oDlg  SIZE 40,12 PIXEL
   @ 44, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 44,102 GET oGet[4] VAR aVta[3] OF oDlg ;
      VALID aVta[3] >= aVta[2] SIZE 40,12 PIXEL
   @ 44,150 CHECKBOX oGet[5] VAR aVta[4] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 60, 50 BUTTON oGet[6] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[6]:Disable(), Extracto( aVta ), oGet[6]:Enable(),;
        oGet[6]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 60,100 BUTTON oGet[7] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 66, 02 SAY "[CAOLIEXT]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
PROCEDURE Extracto( aLS )
   LOCAL oRpt, cQry, nL, nK := DAY(aLS[2])
   LOCAL aRes, aExt := { 0,aLS[1],0,0,0,0,0,0,0 }, hRes
cQry    := NtChr( aLS[2] - nK,"1" )
aExt[1] := aExt[7] := SaldoInv( aLS[1],cQry,1 )
oRpt := TDosPrint()
oRpt:New(oApl:cPuerto,oApl:cImpres,{"MOVIMIENTO DEL CODIGO "+aLS[1],;
         oApl:oInv:DESCRIP + "  DESDE " +NtChr(aLS[2],"2") +" HASTA " +NtChr(aLS[3],"2"),;
         "         EXISTENCIA ANTERIOR " + TRANSFORM( aExt[1],"99,999.99999" ),;
         "     -FECHA--   No.DOCUMEN   CANTIDAD     P.VENDIDO"},aLS[4] )
cQry := "SELECT c.fechoy, c.numfac, c.tipo, c.codigo_nit"+;
             ", d.cantidad, d.precioven "   +;
        "FROM cadventa d, cadfactu c "                   +;
        "WHERE d.codigo  = " + xValToChar( aLS[1] )      +;
         " AND c.empresa = d.empresa"                    +;
         " AND c.numfac  = d.numfac AND c.tipo = d.tipo "+;
         " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
         " AND c.fechoy >= " + xValToChar( aLS[2] )      +;
         " AND c.fechoy <= " + xValToChar( aLS[3] )      +;
         " AND c.tipo   <> 'Z' AND c.indicador <> 'A'"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
// aRes[5] := AFormula( aRes[5],aRes[7] )
   oApl:oNit:Seek( {"codigo_nit",aRes[4]} )
   oRpt:Titulo( 73,10 )
   oRpt:Say( oRpt:nL,05,aRes[1] )
   oRpt:Say( oRpt:nL,16,STR(aRes[2],10)+aRes[3] )
   oRpt:Say( oRpt:nL,28,TRANSFORM(aRes[5], "99,999.99999") )
   oRpt:Say( oRpt:nL,40,TRANSFORM(aRes[6],"999,999,999") )
   oRpt:Say( oRpt:nL,52,oApl:oNit:NOMBRE )
   oRpt:nL++
   aExt[8] += aRes[5]
   aExt[9] += aRes[6]
   nL --
EndDo
MSFreeResult( hRes )
   oRpt:Say( oRpt:nL++,05,REPLICATE("_",68) )
   oRpt:Say( oRpt:nL  ,06,"TOTAL VENTA          :" + TRANSFORM( aExt[8],"99,999.99999" ) )
   oRpt:Say( oRpt:nL++,40,TRANSFORM( aExt[9],"999,999,999" ) )
   aExt[7] -= aExt[8]
   aExt[8] := aExt[9] := 0
oRpt:aEnc[4] := STRTRAN( oRpt:aEnc[4],"VENDIDO","COSTO" )

cQry := "SELECT c.fecingre, c.ingreso, d.cantidad, d.pcosto, d.unidadmed "+;
        "FROM cadartid d, cadartic c "                  +;
        "WHERE d.codigo  = "   + xValToChar( aLS[1] )   +;
         " AND c.ingreso = d.ingreso"                   +;
         " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fecingre >= " + xValToChar( aLS[2] )   +;
         " AND c.fecingre <= " + xValToChar( aLS[3] )
Lineas( cQry,@aExt,oRpt,"C O M P R A S",2,1 )

cQry := "SELECT a.fecajus, a.documen, a.cantidad, "      +;
         "a.pcosto, a.unidadmed, t.tipo_ajust, t.nombre "+;
        "FROM cadtipos t, cadajust a "                   +;
        "WHERE a.tipo = t.Tipo"                          +;
         " AND a.empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND a.fecajus >= " + xValToChar( aLS[2] )     +;
         " AND a.fecajus <= " + xValToChar( aLS[3] )     +;
         " AND a.codigo = "   + xValToChar( aLS[1] )     +;
         " ORDER BY a.fecajus"
Lineas( cQry,@aExt,oRpt,"A J U S T E S",3,0 )
aExt[8] := aExt[9] := 0
/*
cQry := "SELECT Fechad, Documen, Cantidad, Pcosto, Localiz "+;
        "FROM caddevod d, cadempre e "               +;
        "WHERE Destino = "+ LTRIM(STR(oApl:nEmpresa))+;
        " AND Codigo = "  + xValToChar( aLS[1] )     +;
        " AND Fechad >= " + xValToChar( aLS[2] )     +;
        " AND Fechad <= " + xValToChar( aLS[3] )     +;
        " AND d.Empresa <> Destino"                   +;
        " AND Causadev <= 4 AND Indica <> 'B'"       +;
        " AND e.Empresa = d.Empresa"
Lineas( cQry,@aExt,oRpt,"T R A S L A D O S",4,1 )

cQry := "SELECT Fechad, Documen, Cantidad, Pcosto, Causadev, e.Localiz "+;
        "FROM caddevod d, cadempre e "               +;
        "WHERE d.Empresa = "+ LTRIM(STR(oApl:nEmpresa))+;
        " AND Codigo = "  + xValToChar( aLS[1] )     +;
        " AND Fechad >= " + xValToChar( aLS[2] )     +;
        " AND Fechad <= " + xValToChar( aLS[3] )     +;
        " AND Causadev <= 5 AND Indica <> 'B'"       +;
        " AND e.Empresa = d.Destino"
Lineas( cQry,@aExt,oRpt,"D E V O L U C I O N E S",5,-1 )

cQry := "SELECT Fechad, CONCAT('DEV.',Documen), "      +;
        "Cantidad, Pcosto, Numrep FROM caddevod "      +;
        "WHERE Empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
         " AND Codigo  = " + xValToChar( aLS[1] )      +;
         " AND Fechad >= " + xValToChar( aLS[2] )      +;
         " AND Fechad <= " + xValToChar( aLS[3] )      +;
         " AND Causadev >= 6 AND Indica <> 'B'"        +;
        " UNION ALL "                                  +;
        "SELECT c.Fecha, CONCAT('N.C.',c.Numero), "    +;
               "d.Cantidad, d.Pcosto, c.Numfac "       +;
       "FROM cadnotac c, cadnotad d "                  +;
       "WHERE c.Empresa = " + LTRIM(STR(oApl:nEmpresa))+;
        " AND c.Fecha >= " + xValToChar( aLS[2] )      +;
        " AND c.Fecha <= " + xValToChar( aLS[3] )      +;
        " AND c.Tipo   = " + xValToChar(oApl:Tipo)     +;
        " AND d.Optica = c.Optica"                     +;
        " AND d.Numero = c.Numero"                     +;
        " AND d.Tipo   = c.Tipo"                       +;
        " AND d.Codigo = " + xValToChar( aLS[1] )
Lineas( cQry,@aExt,oRpt,"DEVOLUCION DE CLIENTES",6,1 )
*/
cQry := Buscar( {"empresa",oApl:nEmpresa,"codigo",aLS[1],"anomes",NtChr(aLS[2],"1")},;
                 "cadinvme","devol_s, devolcli",8 )
If LEN( cQry ) > 0
   aExt[3] := cQry[1]
   aExt[6] := cQry[2]
EndIf
/*
If oApl:oMes:Seek( {"empresa",oApl:nEmpresa,"codigo",aLS[1],"anomes",NtChr(aLS[2],"1")} )
   aExt[3] := oApl:oMes:DEVOL_S
   aExt[6] := oApl:oMes:DEVOLCLI
EndIf
*/
aExt[7] += (aExt[4] - aExt[5] - aExt[3] - aExt[6])
oRpt:Titulo( 73,10 )
oRpt:Say( oRpt:nL  ,05,REPLICATE("_",68),,,1 )
oRpt:Say( oRpt:nL+1,07,"DEVOLUCIONES A PROVEE:" + TRANSFORM(aExt[3],"99,999.99999"),,,1)
oRpt:Say( oRpt:nL+2,07,"DEVOLUCION DE CLIENTES" + TRANSFORM(aExt[6],"99,999.99999"),,,1)
oRpt:Say( oRpt:nL+3,07,"AJUSTE POR FALTANTES :" + TRANSFORM(aExt[5],"99,999.99999"),,,1)
oRpt:Say( oRpt:nL+4,07,"AJUSTE POR SOBRANTES :" + TRANSFORM(aExt[4],"99,999.99999"),,,1)
oRpt:Say( oRpt:nL+6,07,"EXISTENCIA ACTUAL    :" + TRANSFORM(aExt[7],"99,999.99999"),,,1)
oRpt:NewPage()
oRpt:End()
RETURN

//------------------------------------//
STATIC FUNCTION Lineas( cQry,aExt,oRpt,cTit,nX,nV )
   LOCAL aRes, hRes, nA, nL, bExt
If nX == 3
   bExt := {|| cQry := aRes[7], nA := If( aRes[6] == 5, 4, 5 ),;
               aExt[nA] += aRes[3] }
ElseIf nX == 4
   bExt := {|| aRes[2] := STR(aRes[2],6) + "-" + aRes[6], cQry := "" }
ElseIf nX == 5
   bExt := {|| aRes[2] := STR(aRes[2],6) + "-" +;
               If( aRes[6] == 5, "S.C", aRes[7] ), cQry := "" }
ElseIf nX == 6
   bExt := {|| cQry := aRes[6] + " " + DTOC(aRes[7]) }
ElseIf nX == 6 .AND. nV == 0
   bExt := {|| cQry := "Fac."+STR(aRes[6],7) }
Else
   bExt := {|| cQry := "" }
EndIf

hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
//MsgInfo( cQry,STR(nL) )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[3] := AFormula( aRes[3],aRes[5] )
   EVAL( bExt )
   oRpt:Titulo( 73,10 )
   If aExt[8] == 0
      oRpt:Say( oRpt:nL+1,05,PADC( cTit,68,"=" ) )
      oRpt:nL += 2
   EndIf
   oRpt:Say( oRpt:nL,05,aRes[1] )
   oRpt:Say( oRpt:nL,16,aRes[2] )
   oRpt:Say( oRpt:nL,28,TRANSFORM(aRes[3], "99,999.99999") )
   oRpt:Say( oRpt:nL,40,TRANSFORM(aRes[4],"999,999,999") )
   oRpt:Say( oRpt:nL,52,cQry )
   oRpt:nL++
   aExt[8] += aRes[3]
   aExt[9] += aRes[4] * If( nX == 1, 1, aRes[3] )
   nL --
EndDo
MSFreeResult( hRes )
If aExt[8] > 0 .AND. nV # 0
   aRes := { "TOTAL VENTA           :","TOTAL INGRESOS(COMPRA):",;
             "TOTAL AJUSTES         :","ENTRADAS POR TRASLADO :",;
             "DEVOLUCIONES A PROVEE :","DEVOLUCION DE CLIENTES:" }
   oRpt:Say( oRpt:nL++,05,REPLICATE("_",68) )
   oRpt:Say( oRpt:nL  ,06,aRes[nX] + TRANSFORM( aExt[8],"99,999.99999" ) )
   oRpt:Say( oRpt:nL++,40,TRANSFORM( aExt[9],"999,999,999" ) )
   aExt[7] += aExt[8] * nV
   aExt[8] := aExt[9] := 0
EndIf
RETURN NIL