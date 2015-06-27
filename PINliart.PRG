// Programa.: INOLIART.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Ingresos de Liq., Acces. y L.Contacto
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

PROCEDURE InoLiArt( nOpc )
   LOCAL oDlg, oGet := ARRAY(09), oNi := TNits()
   LOCAL aRep, aOpc := { DATE(),DATE(),0,"C",.f.,0 }
   DEFAULT nOpc := 1
aRep := { { {|| ListoArt( aOpc ) },"Listado de Compras" }  ,;
          { {|| ListoRes( aOpc,2 ) },"Resumen de Compras" },;
          { {|| ListoRes( aOpc,3 ) },"Resumen de Ventas" } ,;
          { {|| InoEstAr( aOpc ) },"Resumen de Compras por Proveedor" } }
oNi:New()
DEFINE DIALOG oDlg TITLE aRep[nOpc,2] FROM 0, 0 TO 13,60
   @ 02, 00 SAY "CODIGO DEL PROVEEDOR" OF oDlg RIGHT PIXEL SIZE 90,08
   @ 02, 92 BTNGET oGet[1] VAR aOpc[6] OF oDlg PICTURE "9999999999";
      VALID EVAL( {|| If(!oNi:oDb:Seek( {"Codigo",aOpc[6]} )      ,;
            ( MsgStop("Este Proveedor no Existe..."),.f. )        ,;
            ( oDlg:Update(), .t. )) } )  SIZE 44,12 PIXEL          ;
      WHEN nOpc == 4  RESOURCE "BUSCAR"                            ;
      ACTION EVAL({|| If(oNi:Mostrar(), (aOpc[6] := oNi:oDb:CODIGO,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
   @ 02,142 SAY oGet[2] VAR oNi:oDb:NOMBRE OF oDlg PIXEL SIZE 88,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 16, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 16, 92 GET oGet[3] VAR aOpc[1] OF oDlg SIZE 40,12 PIXEL
   @ 30, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 30, 92 GET oGet[4] VAR aOpc[2] OF oDlg SIZE 40,12 PIXEL;
      VALID aOpc[2] >= aOpc[1]
   @ 44, 00 SAY       "NUMERO DEL INGRESO" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 44, 92 GET oGet[5] VAR aOpc[3] OF oDlg PICTURE "99999" SIZE 40,12 PIXEL;
      WHEN nOpc == 1
   @ 58, 00 SAY "A PRECIO COSTO O PUBLICO" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 58, 92 GET oGet[6] VAR aOpc[4] OF oDlg PICTURE "!";
      VALID If( aOpc[4] $ "CP", .t., .f. )             ;
      WHEN nOpc == 4  SIZE 08,12 PIXEL
   @ 58,130 CHECKBOX oGet[7] VAR aOpc[5] PROMPT "Vista &Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 74, 50 BUTTON oGet[8] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[8]:Disable(), EVAL( aRep[nOpc,1] ), oDlg:End() ) PIXEL
   @ 74,100 BUTTON oGet[9] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 80, 02 SAY "[INOLIART]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT (If( nOpc == 4, Empresa(), ))

RETURN

//------------------------------------//
PROCEDURE ListoArt( aLS )
   LOCAL oDPrn, aMon := ARRAY(3)
   LOCAL aRes, hRes, cQry, nL, nK
oDPrn := TDosPrint()
oDPrn:New( oApl:cPuerto,oApl:cImpres,{"","","",;
         "  C O D I G O-  D E S C R I P C I O N--------------     FACT" + ;
         "URA  CANTIDAD  PRECIO COSTO  PRECIO VENTA  PREC.PUBLICO" },aLS[5],,2 )
cQry := "SELECT c.Empresa, c.Ingreso, c.Codigo_nit, c.Fecingre, c.Factura, "+;
        "d.Codigo, d.Cantidad, d.Pcosto, d.Pventa, d.Ppubli, i.Descrip "    +;
        "FROM cadartic c, cadartid d, cadinven i "    +;
        "WHERE c.Fecingre >= " + xValToChar( aLS[1] ) +;
         " AND c.Fecingre <= " + xValToChar( aLS[2] ) + If( aLS[3] > 0,;
         " AND c.Ingreso = " + LTRIM(STR(aLS[3])), "" ) +;
         " AND c.Ingreso = d.Ingreso"               +;
         " AND d.Indica <> 'B'"                     +;
         " AND d.Codigo  = i.Codigo ORDER BY c.Ingreso"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) > 0
   aRes := MyReadRow( hRes )
   AEval( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aLS[3] := 0
EndIf
While nL > 0
   If aLS[3]  # aRes[2]
      aLS[3] := aRes[2]
      AFILL( aMon,0 )
      oApl:oEmp:Seek( {"Empresa",aRes[01]} )
      oApl:oNit:Seek( {"Codigo_nit",aRes[03]} )
      oApl:cEmpresa := ALLTRIM( oApl:oEmp:NOMBRE )
      oDPrn:aEnc[1] := "INGRESO DE ARTICULO" + STR(aRes[02],6)
      oDPrn:aEnc[2] := NtChr( aRes[04],"3" )
      oDPrn:aEnc[3] := "PROVEEDOR : " + STR(oApl:oNit:CODIGO) + "  " + oApl:oNit:NOMBRE
      oDPrn:nL    := 67
      oDPrn:nPage := 0
   EndIf
// aMon[3] := aRes[7] * aRes[9]
//1234567890  1234567890123456789012345678901234567890  123456  9,999.99 MT  999,999,999  999,999,999  999,999,999
   oDPrn:Titulo( 116 )
   oDPrn:Say( oDPrn:nL, 02,aRes[06] )
   oDPrn:Say( oDPrn:nL, 16,aRes[11] )
   oDPrn:Say( oDPrn:nL, 57,aRes[05] )
   oDPrn:Say( oDPrn:nL, 66,TransForm(aRes[07],"99,999.99") )
//   oDPrn:Say( oDPrn:nL, 67,UnidadMed )
   oDPrn:Say( oDPrn:nL, 76,TransForm(aRes[08],"999,999,999") )
   oDPrn:Say( oDPrn:nL, 90,TransForm(aRes[09],"999,999,999") )
   oDPrn:Say( oDPrn:nL,104,TransForm(aRes[10],"999,999,999") )
   oDPrn:nL++
   aMon[1] +=  aRes[7]
   aMon[2] += (aRes[7] * aRes[8])
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEval( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aLS[3] # aRes[2]
      If aMon[1] > 0
         oDPrn:Say(  oDPrn:nL,00,Replicate("_",116) )
         oDPrn:Say(++oDPrn:nL,65,TransForm(aMon[1],"999,999") )
         oDPrn:Say(  oDPrn:nL,76,TransForm(aMon[2],"999,999,999" ) )
         oDPrn:NewPage()
      EndIf
   EndIf
EndDo
MSFreeResult( hRes )
oDPrn:End()
oApl:oEmp:Seek( {"Empresa",oApl:nEmpresa} )
oApl:cEmpresa := ALLTRIM( oApl:oEmp:NOMBRE )
RETURN

//------------------------------------//
STATIC PROCEDURE ListoRes( aLS,nK )
   LOCAL aRes, cCod, cQry, hRes, nL
   LOCAL aGT := ARRAY(14), oDPrn := TDosPrint()
If nK == 2
   cCod := "PRODUCCION DE ARTICULOS"
   cQry := "SELECT d.Codigo, MONTH(c.Fecingre) MES, SUM(d.Cantidad) "+;
           "FROM cadartic c, cadartid d "               +;
           "WHERE c.Fecingre >= " + xValToChar( aLS[1] )+;
            " AND c.Fecingre <= " + xValToChar( aLS[2] )+;
            " AND d.Ingreso = c.Ingreso"                +;
            " AND d.Indica <> 'B' GROUP BY d.Codigo, MES ORDER BY d.Codigo, MES"
Else
   cCod := "VENTAS DE ARTICULOS"
   cQry := "SELECT Codigo, MONTH(Fecfac) MES, SUM(Cantidad) FROM cadventa "+;
           "WHERE Empresa = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND Fecfac >= " + xValToChar( aLS[1] )     +;
            " AND Fecfac <= " + xValToChar( aLS[2] )     +;
            " AND Tipo = "    + xValToChar( oApl:Tipo )  +;
            " GROUP BY Codigo, MES ORDER BY Codigo, MES"
EndIf
oDPrn:New( oApl:cPuerto,oApl:cImpres,{cCod,"PERIODO : "+;
           TransForm( YEAR(aLS[2]),"#,###" )           ,;
           "CODIGO D E S C R I P C I O N            ENE.   FEB.   MAR.   ABR.   "+;
           "MAY.   JUN.   JUL.   AGO.   SEP.   OCT.   NOV.   DIC.  TOTAL" },aLS[5] )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) > 0
   aRes := MyReadRow( hRes )
   cCod := ""
   AEval( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
EndIf
AFILL( aGT,0 )
While nL > 0
   nK := aRes[2]
   If cCod  # aRes[1]
      cCod := aRes[1]
      oApl:oInv:Seek( {"Codigo",aRes[1]} )
      oDPrn:Titulo( 116 )
      oDPrn:Say( oDPrn:nL,01,aRes[1] )
      oDPrn:Say( oDPrn:nL,07,oApl:oInv:DESCRIP,30 )
   EndIf
   oDPrn:Say( oDPrn:nL,(nK * 7 + 31),TransForm(aRes[3],"999,999") )
   aGT[nK] += aRes[3]
   aGT[14] += aRes[3]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEval( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. cCod # aRes[1]
      oDPrn:Say( oDPrn:nL,122,TransForm(aGT[14],"999,999") )
      oDPrn:nL ++
      aGT[13] += aGT[14]
      aGT[14] := 0
   EndIf
EndDo
MSFreeResult( hRes )
If aGT[13] > 0
   oDPrn:Say(  oDPrn:nL,00,Replicate("_",116) )
   oDPrn:Say(++oDPrn:nL,14,"GRAN TOTAL ==>" )
   FOR nL := 1 TO 13
      nK  := nL * 7 + 31
      oDPrn:Say( oDPrn:nL,nK,TransForm(aGT[nL],"999,999") )
   NEXT
EndIf
oDPrn:NewPage()
oDPrn:End()
RETURN

//------------------------------------//
STATIC PROCEDURE InoEstAr( aLS )
   LOCAL oDPrn, aGT := { 0,0,0,"" }
   LOCAL aRes, hRes, cQry, nL
aGT[4]:= If( aLS[4] == "C", "PCOSTO", "PPUBLI")
oDPrn := TDosPrint()
oDPrn:New( oApl:cPuerto,oApl:cImpres,{"COMPRAS DISCRIMINADAS POR PRODUCTO",;
          "DESDE " + NtChr( aLS[1],"2" ) + " HASTA " + NtChr( aLS[2],"2" ),;
          "        PROVEEDOR : " + STR(aLS[7]) + "  " + oApl:oNit:NOMBRE  ,;
          "  C O D I G O-  D E S C R I P C I O N    CANTIDAD   PRECIO " +  ;
          RIGHT(aGT[4],5) },aLS[5] )
cQry := "SELECT d.Codigo, SUM(d.Cantidad), SUM(d.Cantidad*d." + aGT[4]+;
        ") FROM cadartic c, cadartid d "                +;
        "WHERE c.Empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.Fecingre >= " + xValToChar( aLS[1] )   +;
         " AND c.Fecingre <= " + xValToChar( aLS[2] )   +;
         " AND c.Codigo_nit = "+ LTRIM(STR(oApl:oNit:CODIGO_NIT))+;
         " AND c.Ingreso = d.Ingreso "                  +;
        "GROUP BY d.Codigo ORDER BY d.Codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEval( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   oApl:oInv:Seek( {"Codigo",aRes[1]} )
   oDPrn:Titulo( 70 )
   oDPrn:Say( oDPrn:nL  ,02,aRes[1] )
   oDPrn:Say( oDPrn:nL  ,16,oApl:oInv:DESCRIP )
   oDPrn:Say( oDPrn:nL  ,40,TransForm( aRes[2],  "9,999,999") )
   oDPrn:Say( oDPrn:nL++,53,TransForm( aRes[3],"999,999,999") )
   aGT[1] += aRes[2]
   aGT[2] += aRes[3]
   aGT[3] ++
   nL --
EndDo
MSFreeResult( hRes )
If aGT[3] > 0
   oDPrn:Say(  oDPrn:nL,00,Replicate("_",70) )
   oDPrn:Say(++oDPrn:nL,16,"GRAN TOTAL ==>" )
   oDPrn:Say(  oDPrn:nL,39,TransForm(aGT[1],   "99,999,999" ) )
   oDPrn:Say(  oDPrn:nL,51,TransForm(aGT[2],"9,999,999,999" ) )
EndIf
oDPrn:NewPage()
oDPrn:End()
RETURN
