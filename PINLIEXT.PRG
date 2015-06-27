// Programa.: INOLIEXT.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Movimento de un Codigo por Mes
#include "FiveWin.ch"
#include "Btnget.ch"

MEMVAR oApl

PROCEDURE InoLiExt()
   LOCAL oDlg, oGet := ARRAY(7), oAr := TInv()
   LOCAL aVta := { SPACE(12),DATE(),DATE(),.t.,"" }
oAr:New()
DEFINE DIALOG oDlg TITLE "Extracto de un Código" FROM 0, 0 TO 11,52
   @ 02, 00 SAY "CODIGO DEL ARTICULO" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 02,102 BTNGET oGet[1] VAR aVta[1] OF oDlg PICTURE "!9999999!!";
      VALID EVAL( {|| If( oAr:oDb:Seek( {"Codigo",aVta[1]} )      ,;
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
   @ 66, 02 SAY "[INOLIEXT]" OF oDlg PIXEL SIZE 32,10
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
         "         EXISTENCIA ANTERIOR " + TransForm( aExt[1],"99,999.99999" ),;
         "     -FECHA--   No.DOCUMEN   CANTIDAD     P.VENDIDO"},aLS[4] )
cQry := "SELECT c.Fechoy, c.Numfac, c.Tipo, c.Codigo_nit"+;
             ", d.Cantidad, d.Precioven, d.Unidadmed "   +;
        "FROM cadfactc c, cadfactd d "                   +;
        "WHERE c.Empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
         " AND c.Fechoy >= " + xValToChar( aLS[2] )      +;
         " AND c.Fechoy <= " + xValToChar( aLS[3] )      +;
         " AND c.Tipo   <> 'Z' AND c.Indicador <> 'A'"   +;
         " AND d.Empresa = c.Empresa"                    +;
         " AND d.Numfac  = c.Numfac AND d.Tipo = c.Tipo "+;
         " AND d.Codigo  = " + xValToChar( aLS[1] )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEval( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[5] := AFormula( aRes[5],aRes[7] )
   oApl:oNit:Seek( {"Codigo_nit",aRes[4]} )
   oRpt:Titulo( 73,10 )
   oRpt:Say( oRpt:nL,05,aRes[1] )
   oRpt:Say( oRpt:nL,16,STR(aRes[2],10)+aRes[3] )
   oRpt:Say( oRpt:nL,28,TransForm(aRes[5], "99,999.99999") )
   oRpt:Say( oRpt:nL,40,TransForm(aRes[6],"999,999,999") )
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

cQry := "SELECT c.Fecingre, c.Ingreso, d.Cantidad, d.Pcosto, d.Unidadmed "+;
        "FROM cadartic c, cadartid d "                  +;
        "WHERE c.Empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.Fecingre >= " + xValToChar( aLS[2] )   +;
         " AND c.Fecingre <= " + xValToChar( aLS[3] )   +;
         " AND d.Ingreso = c.Ingreso"                   +;
         " AND d.Codigo  = "   + xValToChar( aLS[1] )
       //" AND d.Indica <> 'B'"
Lineas( cQry,@aExt,oRpt,"C O M P R A S",2,1 )

cQry := "SELECT a.Fecajus, a.Documen, a.Cantidad, "      +;
         "a.Pcosto, a.Unidadmed, t.Tipo_ajust, t.Nombre "+;
        "FROM cadajust a, cadtipos t "                   +;
        "WHERE a.Empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND a.Fecajus >= " + xValToChar( aLS[2] )     +;
         " AND a.Fecajus <= " + xValToChar( aLS[3] )     +;
         " AND a.Codigo = "   + xValToChar( aLS[1] )     +;
         " AND a.Tipo = t.Tipo ORDER BY a.Fecajus"
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
Lineas( cQry,@aExt,oDPrn,"DEVOLUCION DE CLIENTES",6,1 )
*/
If oApl:oMes:Seek( {"Empresa",oApl:nEmpresa,"Codigo",aLS[1],"Anomes",NtChr(aLS[2],"1")} )
   aExt[3] := oApl:oMes:DEVOL_S
   aExt[6] := oApl:oMes:DEVOLCLI
EndIf
aExt[7] += (aExt[4] - aExt[5] - aExt[3] - aExt[6])
oRpt:Titulo( 73,10 )
oRpt:Say( oRpt:nL  ,05,Replicate("_",68),,,1 )
oRpt:Say( oRpt:nL+1,07,"DEVOLUCIONES A PROVEE:" + TRANSFORM(aExt[3],"99,999.99999"),,,1)
oRpt:Say( oRpt:nL+2,07,"DEVOLUCION DE CLIENTES" + TRANSFORM(aExt[6],"99,999.99999"),,,1)
oRpt:Say( oRpt:nL+3,07,"AJUSTE POR FALTANTES :" + TransForm(aExt[5],"99,999.99999"),,,1)
oRpt:Say( oRpt:nL+4,07,"AJUSTE POR SOBRANTES :" + TransForm(aExt[4],"99,999.99999"),,,1)
oRpt:Say( oRpt:nL+6,07,"EXISTENCIA ACTUAL    :" + TransForm(aExt[7],"99,999.99999"),,,1)
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
   AEval( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[3] := AFormula( aRes[3],aRes[5] )
   EVAL( bExt )
   oRpt:Titulo( 73,10 )
   If aExt[8] == 0
      oRpt:Say( oRpt:nL+1,05,PADC( cTit,68,"=" ) )
      oRpt:nL += 2
   EndIf
   oRpt:Say( oRpt:nL,05,aRes[1] )
   oRpt:Say( oRpt:nL,16,aRes[2] )
   oRpt:Say( oRpt:nL,28,TransForm(aRes[3], "99,999.99999") )
   oRpt:Say( oRpt:nL,40,TransForm(aRes[4],"999,999,999") )
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
   oRpt:Say( oRpt:nL++,05,Replicate("_",68) )
   oRpt:Say( oRpt:nL  ,06,aRes[nX] + TransForm( aExt[8],"99,999.99999" ) )
   oRpt:Say( oRpt:nL++,40,TransForm( aExt[9],"999,999,999" ) )
   aExt[7] += aExt[8] * nV
   aExt[8] := aExt[9] := 0
EndIf
RETURN NIL
