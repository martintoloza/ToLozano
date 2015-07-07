// Programa.: JVMLIFAC.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Imprime facturas
#include "FiveWin.ch"
#INCLUDE "Utilprn.CH"

MEMVAR oApl

PROCEDURE CaoLiFac( nFac,aDT,aDF )
   LOCAL oLF
If EMPTY( nFac )
   MsgInfo("No hay Documento para imprimir")
   RETURN
EndIf
oLF := TListFac()
oLF:NEW( nFac,aDT,aDF )
RETURN

//------------------------------------//
CLASS TListFac FROM TIMPRIME

 DATA aPie, aTel, aTit, oFnt7, oFnt8
 DATA lPrev   INIT .f.
 DATA lTit    INIT .t.

 METHOD NEW( nFac,aDT,aF ) Constructor
 METHOD Dialog()
 METHOD CaoLiFad( oRpt,aDT )
 METHOD FactuPos( oRpt,aDT )
 METHOD ListoWIN( aDT )
 METHOD Cabecera( lSep,nSpace,nSuma )
 METHOD PieFactu( nCol,cText,nLine,nSeparator,lFin )
ENDCLASS

//------------------------------------//
METHOD NEW( nFac,aDT,aF ) CLASS TListFac
   LOCAL oRpt, nL
::aTit := { FormatoNit( oApl:oNit:CODIGO,oApl:oNit:DIGITO ),nFac,aF[1],;
            oApl:cEmpresa,"",0,0,aF[2] }
/*
::aPie := Buscar( "SELECT 'A', prefijo, piefactu FROM cademprf "+;
                  "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
                   " AND tipo    = '"+ oApl:Tipo                +;
                  "' AND desde  >= " + LTRIM(STR(nFac))         +;
                   " AND hasta  <= " + LTRIM(STR(nFac)),"CM",,8 )
If LEN( ::aPie ) == 0
   ::aPie := { "",oApl:oEmp:PREFIJO,ALLTRIM( oApl:oEmp:PIEFACTU ) }
Else
   ::aPie[3] := ALLTRIM( ::aPie[3] )
EndIf
*/
aF := "SELECT 'A', prefijo, piefactu FROM cademprf "+;
      "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
       " AND tipo = '"   + oApl:Tipo + "'"
oRpt := If( MSQuery( oApl:oMySql:hConnect,aF )   ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If MSNumRows( oRpt ) > 0
   ::aPie := MyReadRow( oRpt )
   AEVAL( ::aPie, { | xV,nP | ::aPie[nP] := MyClReadCol( oRpt,nP ) } )
  ::aPie[3] := ALLTRIM( ::aPie[3] )
Else
   ::aPie := { "","","" }
EndIf
MSFreeResult( oRpt )
::aPie[1] := "Régimen " + { "Simplificado ","Común ",;
                            "Grandes Contribuyentes " }[oApl:oEmp:TREGIMEN] +;
             ALLTRIM(oApl:oEmp:REGIMEN)
If !EMPTY(oApl:oEmp:NOMBRE2)
   ::aTit[4] := ALLTRIM(oApl:oEmp:NOMBRE2)
   ::aTit[5] := oApl:cEmpresa
EndIf
If oApl:Tipo $ oApl:oEmp:POS
   ::FactuPos( oRpt,aDT )
   RETURN NIL
EndIf
::Dialog()
If oApl:oEmp:PORPC .AND. oApl:Tipo == "C"
   ::ListoWIN( aDT )
   RETURN NIL
EndIf
nL   := If( oApl:Tipo == "C", 66, 33 )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,,::lPrev,,,nL,nL )
//oRpt:nL    := { 19,19,16,19 }[AT(oApl:Tipo,"ABCX")]
oRpt:nL    := If( oApl:Tipo == "C", 16, If( oApl:Tipo == "Z", 38, 19 ) )
oRpt:nPage := 1
oRpt:SetFont( oRpt:CPINormal,82,2 )
If oApl:Tipo == "X"
   ::CaoLiFad( oRpt,aDT )
   RETURN NIL
EndIf
/*
//Factura Forma Preimpresa
aF := { "Contado","45 Dias" }
oRpt:Say( 09,09,oRpt:CPICompress + NtChr( oApl:oNit:NOMBRE,"\" ) )
oRpt:Say( 10,10,oRpt:CPICompress + oApl:oNit:DIRECCION )
oRpt:Say( 10,68,aF[oApl:oNit:FORMAPAGO+1] )
oRpt:Say( 12,05,FormatoNit( oApl:oNit:CODIGO,oApl:oNit:DIGITO ) )
oRpt:Say( 12,52,STRTRAN( DTOC(oApl:oFac:FECHOY),".","  " ) )
oRpt:Say( 14,41,STR(nFac,10) )

FOR nL := 1 TO LEN( aDT )
   If !EMPTY( aDT[nL,1] )
      aF := UMedidas( aDT[nL,5]," DE " ) + NtChr( aDT[nL,2],"\" )
      oRpt:Say( oRpt:nL,00,TRANSFORM( aDT[nL,4],"999,999.99" ) )
      oRpt:Say( oRpt:nL,13,LEFT( aF,41 ) )
      oRpt:Say( oRpt:nL,53,TRANSFORM( aDT[nL,3],"9,999,999" ) )
      oRpt:Say( oRpt:nL,64,TRANSFORM( aDT[nL,7]+aDT[nL,8],"99,999,999" ) )
      oRpt:nL ++
   EndIf
NEXT nL
aF   := Letras( oApl:oFac:TOTALFAC )
nFac := oApl:oFac:TOTALFAC - oApl:oFac:TOTALIVA + oApl:oFac:TOTALDES
If !EMPTY( oApl:oFac:ORDEN )
   oRpt:Say( 49,10,"Orden de Compra No. " + oApl:oFac:ORDEN )
EndIf
   oRpt:Say( 51,64,TRANSFORM( nFac,"99,999,999" ) )
If oApl:oFac:TOTALDES > 0
   nFac := oApl:oFac:TOTALDES / nFac * 100
   oRpt:Say( 52,45,"Menos Dscto." + TRANSFORM( nFac,"999%" ) )
   oRpt:Say( 52,64,TRANSFORM( oApl:oFac:TOTALDES,"99,999,999" ) )
EndIf
   oRpt:Say( 53,59,TRANSFORM( ::aTit[3]*100,"99.9" ) )
   oRpt:Say( 53,64,TRANSFORM( oApl:oFac:TOTALIVA,"99,999,999" ) )
   oRpt:Say( 55,64,TRANSFORM( oApl:oFac:TOTALFAC,"99,999,999" ) )
   oRpt:Say( 57,07,oRpt:CPICompress + aF[1] )
// Parte 1
nL   := aF[6] + 13
nFac := LEN( aDT )
nFac := INT( nFac/nL ) + If( nFac % nL > 0, 1, 0 )
FOR nL := 1 TO LEN( aDT )
   If oRpt:nL == 0
      oRpt:SetFont( oRpt:CPINormal,82,2 )
      oRpt:Say( 1,02,oRpt:CPILarge + ::aTit[4] )
      oRpt:Say( 2,00,"Materiales y Accesorios Electricos" + SPACE(12) +;
                     oApl:oEmp:DIRECCION )
      oRpt:Say( 3,04,"NIT. " + oApl:oEmp:Nit )
      oRpt:Say( 3,46,"Telefonos: " + oApl:oEmp:TELEFONO )
      oRpt:Say( 4,00,::aTit[5] )
      oRpt:Say( 4,46,"      Fax: " + oApl:oEmp:FAX )
      oRpt:Say( 5,46,"Barranquilla-Colombia" )    //oApl:cCiu
      oRpt:nL := 6
      FOR aF[5] := 1 TO aF[6]
          aF[2] := MEMOLINE( ::aPie[3],72,aF[5] )
         oRpt:Say( oRpt:nL,01,oRpt:CPICompress + aF[2] )
         oRpt:nL ++
      NEXT aF[5]
// Parte 1 Fin
*/
//---Formato MS-DOS-------------------//
oRpt:nL    := 0
::aTel := Telefonos( oApl:oNit:CODIGO_NIT )
aF   := { 26,"",If( oApl:oNit:CODIGO == 1, oApl:oFac:CLIENTE, oApl:oNit:NOMBRE ),;
          "FACTURA ",0,MLCOUNT( ::aPie[3],72 ),;
          Buscar( {"codigo",oApl:oNit:CODIGO_CIU},"ciudades","nombre",8 ) }
nL   := 13 + If( aF[6] > 5, aF[6], 5 )
nFac := LEN( aDT )
nFac := INT( nFac/nL ) + If( nFac % nL > 0, 1, 0 )
FOR nL := 1 TO LEN( aDT )
   If oRpt:nL == 0
      oRpt:SetFont( oRpt:CPINormal,82,2 )
      oRpt:Say( 1,02,oRpt:CPILarge + ::aTit[4] )
      oRpt:Say( 2,00,PADC( ::aTit[5],40 ) )
      oRpt:Say( 3,00,PADC( "NIT. " + oApl:oEmp:Nit,40 ) )
      oRpt:Say( 4,00,oApl:oEmp:DIRECCION )
      oRpt:Say( 5,00,"Telefonos: " + oApl:oEmp:TELEFONO )
      oRpt:Say( 6,00,"      Fax: " + oApl:oEmp:FAX )
      oRpt:Say( 7,00,"Barranquilla-Colombia" )    //oApl:cCiu
      oRpt:nL := 2
      FOR aF[5] := 1 TO aF[6]
          aF[2] := MEMOLINE( ::aPie[3],72,aF[5] )
         oRpt:Say( oRpt:nL,41,oRpt:CPICompress + aF[2] )
         oRpt:nL ++
      NEXT aF[5]
      oRpt:nL := If( oRpt:nL < 8, 8, oRpt:nL )
      oRpt:Say(  oRpt:nL,00,REPLICATE( "_",78 ) )
      oRpt:Say(++oRpt:nL,01,"Se\or(es) : " + NtChr( aF[3],"\" ) )
      oRpt:Say(++oRpt:nL,01,"Nit. o C.C. " + FormatoNit( oApl:oNit:CODIGO,oApl:oNit:DIGITO ) )
      oRpt:Say(  oRpt:nL,47,aF[4] + "DE VENTA No. " + ::aPie[2] + STRZERO(::aTit[2],8) )
      oRpt:SetFont( oRpt:CPICompress,144,1 )
      oRpt:Say(++oRpt:nL,01,"Direccion : " + oApl:oNit:DIRECCION )
      oRpt:Say(  oRpt:nL,82,oRpt:CPINormal+"FECHA DE " + aF[4] + NtChr( oApl:oFac:FECHOY,"2" ) )
      oRpt:Say(++oRpt:nL,01,"Telefono  : " + ::aTel[1,1] )
      oRpt:Say(  oRpt:nL,40,"   Ciudad : " + aF[7] )
      oRpt:Say(  oRpt:nL,90,"Vendedor : "  + ::aTit[8])
      oRpt:SetFont( oRpt:CPINormal,82,2 )
      oRpt:Say(++oRpt:nL,02,"Cantidad  Descripcion del Articulo               " +;
                  "Vr/Unitario  Valor Total" )
      oRpt:Say(++oRpt:nL,01,REPLICATE( "_",74 ) )
      oRpt:nL ++
   EndIf
   If !EMPTY( aDT[nL,1] )
      aF[2] := UMedidas( aDT[nL,5]," DE " ) + NtChr( aDT[nL,2],"\" )
      oRpt:Say( oRpt:nL,00,TRANSFORM( aDT[nL,4],"999,999.99" ) )
      oRpt:Say( oRpt:nL,11,LEFT( aF[2],41 ) )
      oRpt:Say( oRpt:nL,52,TRANSFORM( aDT[nL,3],"9,999,999" ) )
      oRpt:Say( oRpt:nL,63,TRANSFORM( aDT[nL,7]+aDT[nL,8],"999,999,999" ) )
      oRpt:nL ++
   EndIf
   If oRpt:nL == aF[1] .AND. oRpt:nPage < nFac
      oRpt:nL :=  0
      oRpt:Say( aF[1]  ,55,REPLICATE("=",20) )
      oRpt:Say( aF[1]+1,01,"Pagina" + STR( oRpt:nPage,3 ) + " DE" + STR( nFac,3 ) )
      oRpt:Say( aF[1]+1,55,"Pasan .............." )
      oRpt:nPage++
      oRpt:NewPage()
   EndIf
NEXT nL
 nL := oApl:oFac:TOTALFAC - oApl:oFac:TOTALIVA + oApl:oFac:TOTALDES
 oRpt:nL := aF[1]
 oRpt:Say(  oRpt:nL,55,REPLICATE("=",20) )
 oRpt:Say(++oRpt:nL,01,"Pagina" + STR( oRpt:nPage,3 ) + " DE" + STR( nFac,3 ) )
 oRpt:Say(  oRpt:nL,52,"SUB-TOTAL  " + TRANSFORM(nL,"999,999,999") )
 If oApl:oFac:TOTALDES > 0
    nFac := (oApl:oFac:TOTALDES / nL) * 100
    oRpt:Say(++oRpt:nL,45,"Menos Dscto." + TRANSFORM(nFac,"99.9%") )
    oRpt:Say(  oRpt:nL,64,TRANSFORM(oApl:oFac:TOTALDES,"99,999,999") )
 EndIf
 aF := Letras( oApl:oFac:TOTALFAC )
 oRpt:Say(++oRpt:nL,46,"IMPOVENTAS " + TRANSFORM(::aTit[3]*100,"99.9%") )
 oRpt:Say(  oRpt:nL,63,TRANSFORM(oApl:oFac:TOTALIVA,"999,999,999") )
 oRpt:Say(++oRpt:nL,01,"Son: " +oRpt:CPICompress + aF[1] )
 oRpt:Say(  oRpt:nL,95,oRpt:CPINormal + "TOTAL $" + TRANSFORM(oApl:oFac:TOTALFAC,"999,999,999") )
//
 oRpt:NewPage()
 oRpt:End()
RETURN NIL

//------------------------------------//
METHOD Dialog() CLASS TListFac
   LOCAL hDC := GetDC( 0 )
 ::aFont := GetFontNames( hDC )
 ::cFont := "Courier New"
DEFINE DIALOG ::oDlg TITLE "Impresion"
   @ 02,62 CHECKBOX ::lPrev PROMPT "Vista Previa" OF ::oDlg ;
      SIZE 60,10 PIXEL
   @ 14,00 SAY "Escoja la Fuente"  OF ::oDlg RIGHT PIXEL SIZE 60,10
   @ 14,62 COMBOBOX ::cFont ITEMS ::aFont SIZE 80,99 OF ::oDlg PIXEL;
      WHEN oApl:oEmp:PORPC
   @ 30,70 BUTTON hDC PROMPT "Imprimir" SIZE 44,12 OF ::oDlg;
      ACTION ::oDlg:End() PIXEL
ACTIVATE DIALOG ::oDlg CENTER
/*
      MENUITEM "P&rinter Setup..." + Chr( 9 ) + "Alt+P" ;
         MESSAGE "Select and setup the printer" ;
         ACCELERATOR ACC_ALT, Asc( "P" ) ;
         ACTION PrinterSetup()
//GetPrintDefault( GetActiveWindow() )
*/
RETURN NIL

//------------------------------------//
METHOD CaoLiFad( oRpt,aDT ) CLASS TListFac
   LOCAL aL, nL, nPAG := LEN( aDT )
aL := { 26,"",If( oApl:oNit:CODIGO == 1, oApl:oFac:CLIENTE, oApl:oNit:NOMBRE ) }
nPAG := INT( nPAG/19 ) + If( nPAG % 19 > 0, 1, 0 )
oRpt:nL := 0
FOR nL := 1 TO LEN( aDT )
   If oRpt:nL == 0
      oRpt:nL := 7
      oRpt:SetFont( oRpt:CPICompress,144,1 )
      oRpt:Say( 1,01,"Se\or(es) : " + NtChr( aL[3],"\" ) + "  Nit. o C.C." )
      oRpt:Say( 1,81,oRpt:CPINormal+ "R E M I S I O N" )
      oRpt:Say( 2,01,"Direccion : " + oApl:oNit:DIRECCION )
      oRpt:Say( 2,45,FormatoNit( oApl:oNit:CODIGO,oApl:oNit:DIGITO ) )
      oRpt:Say( 2,79,oRpt:CPINormal+ "   No. " + StrZero(oApl:oFac:NUMFAC,8) )
      oRpt:Say( 3,01,"Telefono  : " + oApl:oNit:TELEFONO )
      oRpt:Say( 3,74,oRpt:CPINormal+ "FECHA DE REMISION " + NtChr( oApl:oFac:FECHOY,"2" ) )
      oRpt:Say( 4,01,"   Ciudad : " + oApl:cCiu )
      oRpt:Say( 4,85,oRpt:CPINormal+ "Pagina" + STR( oRpt:nPage,3 ) + " DE" + STR( nPAG,3 ) )
      oRpt:SetFont( oRpt:CPINormal,82,2 )
      oRpt:Say( 5,01,"Cantidad  Descripcion del Articulo                " +;
                  "Vr/Unitario  Valor Total" )
      oRpt:Say( 6,01,REPLICATE( "_",74 ) )
   EndIf
   If !EMPTY( aDT[nL,1] )
      aL[2] := UMedidas( aDT[nL,5]," DE " ) + NtChr( aDT[nL,2],"\" )
      oRpt:Say( oRpt:nL,00,TRANSFORM( aDT[nL,4],"999,999.99" ) )
      oRpt:Say( oRpt:nL,11,LEFT( aL[2],41 ) )
      oRpt:Say( oRpt:nL,52,TRANSFORM( aDT[nL,3],"9,999,999" ) )
      oRpt:Say( oRpt:nL,63,TRANSFORM( aDT[nL,7]+aDT[nL,8],"999,999,999" ) )
      oRpt:nL ++
   EndIf
   If oRpt:nL == aL[1] .AND. oRpt:nPage < nPAG
      oRpt:nL :=  0
      oRpt:nPage++
      oRpt:Say( aL[1]  ,55,REPLICATE("=",20) )
      oRpt:Say( aL[1]+1,55,"Pasan .............." )
      oRpt:NewPage()
   EndIf
NEXT nL
 oRpt:Say( aL[1],55,REPLICATE("=",20) )
aL   := Letras( oApl:oFac:TOTALFAC )
nPAG := oApl:oFac:TOTALFAC - oApl:oFac:TOTALIVA + oApl:oFac:TOTALDES
 If oApl:oFac:TOTALDES > 0
    oRpt:Say( 27,02,"Subtotal $" + TRANSFORM(nPAG ,"9,999,999") )
    oRpt:Say( 27,30,"Descuento " + TRANSFORM(oApl:oFac:TOTALDES,"9,999,999") )
 EndIf
 oRpt:Say( 27,55,"Total   $" + TRANSFORM(oApl:oFac:TOTALFAC,"999,999,999") )
 oRpt:Say( 28,01,"Son: " +oRpt:CPICompress + aL[1] )
 oRpt:Say( 29,20,"Recibi a Satisfaccion :" )
 oRpt:Say( 30,20,REPLICATE("_",45) )
 oRpt:NewPage()
 oRpt:End()
RETURN NIL

//------------------------------------//
METHOD FactuPos( oRpt,aDT ) CLASS TListFac
   LOCAL aL, nL, nPAG, nP := LEN( aDT )
aL := { If( oApl:oNit:CODIGO == 1, oApl:oFac:CLIENTE, oApl:oNit:NOMBRE ),26,"" }
nL := nP * 2 + 27
::Init( "Factura"+STR(::aTit[2]), .t. ,, !::lPrev )
 DEFINE FONT ::oFnt7 NAME ::cFont SIZE 0,-7  OF ::oPrn
UTILPRN ::oUtil SELECT ::oFnt5
PAGE
   UTILPRN ::oUtil 1.0, 0.1 SAY PADC( ::aTit[4],42 )
   UTILPRN ::oUtil 1.4, 0.1 SAY PADC( "NIT: " + oApl:oEmp:NIT,42 )
   UTILPRN ::oUtil 1.8, 0.1 SAY PADC( ::aPie[1],42 )
   UTILPRN ::oUtil 2.2, 0.3 SAY oApl:oEmp:DIRECCION
   UTILPRN ::oUtil 2.2, 4.3 SAY "Tel." + oApl:oEmp:TELEFONO
   UTILPRN ::oUtil 2.6, 1.2 SAY "Barranquilla - Colombia"
   UTILPRN ::oUtil 3.0, 0.2 SAY REPLICATE("*",40)
   UTILPRN ::oUtil 3.4, 0.5 SAY "Documento impreso por computador por:"
   UTILPRN ::oUtil 3.8, 0.1 SAY PADC( ::aTit[4],42 )
   UTILPRN ::oUtil 4.2, 0.2 SAY REPLICATE("*",40)
   UTILPRN ::oUtil 4.6, 0.1 SAY PADC( "Contado",42 )
   UTILPRN ::oUtil 5.0, 0.8 SAY "FACTURA DE VENTA No."+oApl:oEmp:PREFIJO+STR(::aTit[2],10)
   UTILPRN ::oUtil 5.4, 0.2 SAY "Fecha: " + NtChr( oApl:oFac:FECHOY,"2" )
   UTILPRN ::oUtil 5.8, 0.2 SAY "SR(a): " + aL[1]
   UTILPRN ::oUtil 6.2, 0.2 SAY "Dirección:"+ oApl:oNit:DIRECCION
   UTILPRN ::oUtil 6.6, 0.2 SAY "Nit o C.C.:"+ ::aTit[1]
   UTILPRN ::oUtil 7.0, 0.2 SAY REPLICATE("-",40)
   UTILPRN ::oUtil 7.4, 0.2 SAY " Descripcion"
   UTILPRN ::oUtil 7.4, 4.8 SAY "Pre.Uni"   RIGHT
   UTILPRN ::oUtil 7.4, 7.0 SAY "Vlr.Total" RIGHT
   ::nLinea := 7.8
   FOR nL := 1 TO nP
      aL[3] := UMedidas( aDT[nL,5],"" )
      UTILPRN ::oUtil Self:nLinea, 0.2 SAY aDT[nL,2]
      ::nLinea += 0.3
      UTILPRN ::oUtil Self:nLinea, 2.2 SAY TRANSFORM( aDT[nL,4],"999,999.99" )           RIGHT
      UTILPRN ::oUtil Self:nLinea, 2.3 SAY aL[3]
      UTILPRN ::oUtil Self:nLinea, 4.8 SAY TRANSFORM( aDT[nL,3],"9,999,999" )            RIGHT
      UTILPRN ::oUtil Self:nLinea, 7.0 SAY TRANSFORM( aDT[nL,7]+aDT[nL,8],"99,999,999" ) RIGHT
      ::nLinea += 0.3
   NEXT nL
   nP := oApl:oFac:TOTALFAC - oApl:oFac:TOTALIVA + oApl:oFac:TOTALDES
   aL := Letras( oApl:oFac:TOTALFAC,40 )
   UTILPRN ::oUtil Self:nLinea, 0.2 SAY REPLICATE("-",40)
   ::nLinea += 0.4
   UTILPRN ::oUtil Self:nLinea, 0.2 SAY "TOTAL PARCIALES.:"
   UTILPRN ::oUtil Self:nLinea, 7.0 SAY TRANSFORM( nP,"999,999,999" ) RIGHT
   ::nLinea += 0.4
   If oApl:oFac:TOTALDES > 0
      UTILPRN ::oUtil Self:nLinea, 0.2 SAY "Dscto.:"
      UTILPRN ::oUtil Self:nLinea, 7.0 SAY TRANSFORM( oApl:oFac:TOTALDES,"999,999,999" ) RIGHT
      ::nLinea += 0.4
   EndIf
   UTILPRN ::oUtil Self:nLinea, 0.2 SAY "IVA.:"
   UTILPRN ::oUtil Self:nLinea, 7.0 SAY TRANSFORM( oApl:oFac:TOTALIVA,"999,999,999" ) RIGHT
   ::nLinea += 0.4
   UTILPRN ::oUtil Self:nLinea, 0.2 SAY "NETO A PAGAR.:"
   UTILPRN ::oUtil Self:nLinea, 7.0 SAY TRANSFORM( oApl:oFac:TOTALFAC,"999,999,999" ) RIGHT
   ::nLinea += 0.4
   UTILPRN ::oUtil Self:nLinea, 0.2 SAY REPLICATE("-",40)
   ::nLinea += 0.4
   UTILPRN ::oUtil Self:nLinea, 0.2 SAY "Son:"+ aL[1]
   ::nLinea += 0.4
   UTILPRN ::oUtil Self:nLinea, 0.2 SAY aL[2]
   ::nLinea += 0.4
   UTILPRN ::oUtil Self:nLinea, 0.2 SAY PADC( "GRACIAS POR SU COMPRA",40 )
 ENDPAGE
IMPRIME END .F.
 ::oFnt7:End()
/*
MsgInfo( nL,"nL" )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,,.t.,,2,nL,nL )
oRpt:nPage := 1
   oRpt:Say(  1,01,PADC( ::aTit[4],50 ) )
   oRpt:Say(  2,01,PADC( "NIT: " + oApl:oEmp:NIT,50 ) )
   oRpt:Say(  3,01,oApl:oEmp:DIRECCION )
   oRpt:Say(  3,31,"Tel." + oApl:oEmp:TELEFONO )
   oRpt:Say(  4,10,"Barranquilla - Colombia" )
   oRpt:Say(  5,10,REPLICATE("*",40) )
   oRpt:Say(  6,01,"Documento impreso por computador por:" )
   oRpt:Say(  7,01,PADC( ::aTit[4],50 ) )
   oRpt:Say(  8,10,REPLICATE("*",40) )
   oRpt:Say(  9,01,PADC( "Contado",50 ) )
   oRpt:Say( 10,10,"FACTURA DE VENTA No."+oApl:oEmp:PREFIJO+STR(::aTit[2],10) )
   oRpt:Say( 11,01,"Fecha: " + NtChr( oApl:oFac:FECHOY,"2" ) )
   oRpt:Say( 12,01,"SR(a): " + aL[1] )
   oRpt:Say( 13,01,"Dirección:"+ oApl:oNit:DIRECCION )
   oRpt:Say( 14,01,"Nit o C.C.:"+ ::aTit[1] )
   oRpt:Say( 15,01,REPLICATE("-",50) )
   oRpt:Say( 16,01," Descripcion        Uni   Pre.Uni    Vlr.Total" )
//34567890123 999,999.99 9,999,999  9,999,999
   oRpt:nL := 17
FOR nL := 1 TO LEN( aDT )
   If !EMPTY( aDT[nL,1] )
      oRpt:Say(  oRpt:nL,00,aDT[nL,2] )
   // oRpt:Say(++oRpt:nL,00,SUBSTR( aDT[nL,2],14,13 ) )
      oRpt:Say(++oRpt:nL,14,TRANSFORM( aDT[nL,4],"999,999.99" ) )
      oRpt:Say(  oRpt:nL,25,TRANSFORM( aDT[nL,3],"9,999,999" ) )
      oRpt:Say(  oRpt:nL,36,TRANSFORM( aDT[nL,7]+aDT[nL,8],"999,999,999" ) )
      oRpt:nL ++
   EndIf
NEXT nL
   nP := oApl:oFac:TOTALFAC - oApl:oFac:TOTALIVA + oApl:oFac:TOTALDES
   nL := oApl:oFac:TOTALFAC - oApl:oFac:RETFTE - oApl:oFac:RETICA - oApl:oFac:RETIVA
   aL := Letras( nL,50 )
   oRpt:Say(  oRpt:nL,01,REPLICATE("-",50) )
   oRpt:Say(++oRpt:nL,01,"TOTAL PARCIALES.:" )
   oRpt:Say(  oRpt:nL,36,TRANSFORM( nP,"999,999,999" ) )
   If oApl:oFac:TOTALDES > 0
      oRpt:Say(++oRpt:nL,01,"Dscto.:" )
      oRpt:Say(  oRpt:nL,36,TRANSFORM( oApl:oFac:TOTALDES,"999,999,999" ) )
   EndIf
   oRpt:Say(++oRpt:nL,01,"IVA.:" )
   oRpt:Say(  oRpt:nL,36,TRANSFORM( oApl:oFac:TOTALIVA,"999,999,999" ) )
   oRpt:Say(++oRpt:nL,01,"RETEFUENTE.:" )
   oRpt:Say(  oRpt:nL,36,TRANSFORM( oApl:oFac:RETFTE  ,"999,999,999" ) )
   oRpt:Say(++oRpt:nL,01,"NETO A PAGAR.:" )
   oRpt:Say(  oRpt:nL,36,TRANSFORM( oApl:oFac:TOTALFAC,"999,999,999" ) )
   oRpt:Say(++oRpt:nL,01,REPLICATE("-",50) )
   oRpt:Say(++oRpt:nL,01,"Son:"+ aL[1] )
   oRpt:Say(++oRpt:nL,02,aL[2] )
   oRpt:Say(++oRpt:nL,01,PADC( "GRACIAS POR SU COMPRA",50 ) )
 oRpt:NewPage()
 oRpt:End()
*/
RETURN NIL

//------------------------------------//
METHOD ListoWIN( aDT ) CLASS TListFac
   LOCAL cF, nL, nTL := LEN( aDT )
::Init( "Factura"+STR(::aTit[2]), .t. ,, !::lPrev ,,, ::lPrev )
//MsgInfo( ::nEndLine,"FIN" )
 DEFINE FONT ::oFnt7 NAME ::cFont SIZE 0,-20 BOLD OF ::oPrn
 DEFINE FONT ::oFnt8 NAME ::cFont SIZE 0,-7       OF ::oPrn

 UTILPRN ::oUtil SELECT ::oFnt5
 PAGE
    FOR nL := 1 TO nTL
       If !EMPTY( aDT[nL,1] )
          cF := UMedidas( aDT[nL,5]," DE " ) + aDT[nL,2]
          ::Cabecera( .t. )
          UTILPRN ::oUtil Self:nLinea, 3.8 SAY TRANSFORM( aDT[nL,4],"999,999.99" )           RIGHT
          UTILPRN ::oUtil Self:nLinea, 4.1 SAY LEFT( cF,41 )
          UTILPRN ::oUtil Self:nLinea,16.9 SAY TRANSFORM( aDT[nL,3],"9,999,999" )            RIGHT
          UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM( aDT[nL,7]+aDT[nL,8],"99,999,999" ) RIGHT
          ::aTit[7] ++
          If ::aTit[7] == 26 .AND. nL < nTL
             ::PieFactu( 1.1,oApl:oEmp:PIEFACTU,80,.4,.f. )
           //::Cabecera( .t.,3.0 )
             ::nLinea += 3.0
          EndIf
       ElseIf nL == 1
          ::Cabecera( .t. )
          UTILPRN ::oUtil 9.5, 4.0 SAY "A N U L A D A" FONT ::oFnt4
       EndIf
    NEXT nL
    ::PieFactu( 1.1,oApl:oEmp:PIEFACTU,80,.4,.t. )
 ENDPAGE
IMPRIME END .F.
 ::oFnt7:End() ; ::oFnt8:End()
RETURN NIL

//------------------------------------//
METHOD Cabecera( lSep,nSpace,nSuma,lFin ) CLASS TListFac

If lSep .AND. !::lTit
   ::lTit := ::Separator( nSpace )
EndIf
If ::lTit
// Para imprimir una imagen en el formato actual de papel ,
//simplemente le decimos la imagen que es y la clausula PAGE y yasta!
//   UTILPRN ::oUtil 0.5,1 IMAGE oApl:cIco+"logotipo.jpg" JPG PAGE
// Podemos usar tambien la clausula JPG para poner Bitmaps
   If FILE( oApl:cIco+"logotipo.jpg" )
      UTILPRN ::oUtil 0.6,1 IMAGE oApl:cIco+"logotipo.jpg" SIZE 03,03 JPG
   EndIf
   UTILPRN ::oUtil SELECT ::oFnt2

   UTILPRN ::oUtil 1.5, 5.0 SAY ::aTit[4]                           FONT ::oFnt7
   UTILPRN ::oUtil 2.5, 5.7 SAY ::aTit[5]
   UTILPRN ::oUtil 2.5,13.0 SAY "MATERIALES Y ACCESORIOS ELECTRICOS"
   UTILPRN ::oUtil 3.0, 6.3 SAY "NIT: " + oApl:oEmp:NIT
   UTILPRN ::oUtil 3.0,15.0 SAY oApl:oEmp:DIRECCION
   UTILPRN ::oUtil 3.5, 5.0 SAY ::aPie[1]
   UTILPRN ::oUtil 3.5,14.2 SAY "Teléfonos: " + oApl:oEmp:TELEFONO
   UTILPRN ::oUtil 4.0, 5.0 SAY oApl:oEmp:ICA
   UTILPRN ::oUtil 4.0,14.8 SAY "TeleFax: "+ oApl:oEmp:FAX
   UTILPRN ::oUtil 4.5,14.8 SAY "E-mail: " + oApl:oEmp:EMAIL        FONT ::oFnt8
   UTILPRN ::oUtil 4.8,14.8 SAY "Barranquilla - Colombia"

   UTILPRN ::oUtil SELECT ::oFnt5
   UTILPRN ::oUtil 5.5, 3.2 SAY "SEÑORES:"                          FONT ::oFnt2 RIGHT
   UTILPRN ::oUtil 5.5, 3.4 SAY oApl:oNit:NOMBRE                    FONT ::oFnt2
   UTILPRN ::oUtil 5.5,15.5 SAY "FACTURA DE VENTA"                  FONT ::oFnt4
   UTILPRN ::oUtil 6.0, 3.2 SAY "Dirección:"                        FONT ::oFnt2 RIGHT
   UTILPRN ::oUtil 6.0, 3.4 SAY oApl:oNit:DIRECCION
   UTILPRN ::oUtil 6.0,15.7 SAY "No."+oApl:oEmp:PREFIJO+STR(::aTit[2],10) FONT ::oFnt4
   UTILPRN ::oUtil 6.5, 3.2 SAY "NIT:"                              FONT ::oFnt2 RIGHT
   UTILPRN ::oUtil 6.5, 3.4 SAY ::aTit[1]
   UTILPRN ::oUtil 6.5,13.8 SAY "Fecha Factura"
   UTILPRN ::oUtil 6.5,17.4 SAY DTOC(oApl:oFac:FECHOY)              FONT ::oFnt6
   UTILPRN ::oUtil 7.0,13.8 SAY "Fecha Vencimiento"
   UTILPRN ::oUtil 7.0,17.4 SAY DTOC(oApl:oFac:FECHAENT)            FONT ::oFnt6

   UTILPRN ::oUtil BOX  7.4 , 1.0 TO  7.9 ,20.1 ROUND 25,25
   UTILPRN ::oUtil 7.5, 2.0 SAY "CANTIDAD"                          FONT ::oFnt2
   UTILPRN ::oUtil 7.5, 7.0 SAY "DESCRIPCION ARTICULO"              FONT ::oFnt2
   UTILPRN ::oUtil 7.5,15.4 SAY "V.UNIT."                           FONT ::oFnt2
   UTILPRN ::oUtil 7.5,17.5 SAY "VALOR TOTAL"                       FONT ::oFnt2
   ::aTit[6]++
   ::aTit[7]:= 0
   ::lTit   := .F.
   ::nLinea := 8.0
EndIf
RETURN NIL

//------------------------------------//
METHOD PieFactu( nCol,cText,nLine,nSeparator,lFin ) CLASS TListFac
   LOCAL cLinea, nL, nF
   DEFAULT nLine := 75,;
            nCol := 1.1
 UTILPRN ::oUtil BOX  21.0 , 1.0 TO 22.0 ,15.0 ROUND 25,25
 UTILPRN ::oUtil BOX  21.0 ,15.0 TO 24.6 ,20.1 ROUND 25,25
 UTILPRN ::oUtil BOX  22.0 , 1.0 TO 24.6 ,15.0 ROUND 25,25
 FOR nL := 22.0  TO 24.0  STEP .5
    UTILPRN ::oUtil LINEA nL,15.0 TO nL,20.1
 NEXT nL
 ::nLinea := 22.2
  cText := ALLTRIM( cText )
 FOR nL := 1 TO  MLCOUNT( cText,nLine )
    cLinea := MEMOLINE( cText,nLine,nL )
    UTILPRN ::oUtil Self:nLinea,nCol SAY cLinea FONT ::oFnt5
    ::Separator( nSeparator )
 NEXT nL

 UTILPRN ::oUtil 21.1, 1.1 SAY "SON"           FONT ::oFnt5
 UTILPRN ::oUtil 21.1,17.3 SAY "SUBTOTAL"      FONT ::oFnt5 RIGHT
 UTILPRN ::oUtil 22.1,15.5 SAY "I.V.A."        FONT ::oFnt5
 UTILPRN ::oUtil 22.6,17.3 SAY "ReteFuente"    FONT ::oFnt5 RIGHT
 UTILPRN ::oUtil 23.1,17.3 SAY "ReteIVA"       FONT ::oFnt5 RIGHT
 UTILPRN ::oUtil 23.6,17.3 SAY "ReteICA"       FONT ::oFnt5 RIGHT
 UTILPRN ::oUtil 24.1,17.3 SAY "TOTAL A PAGAR" FONT ::oFnt5 RIGHT
If !EMPTY( oApl:oFac:ORDEN )
   UTILPRN ::oUtil 25.0, 1.1 SAY "Orden de Compra No. " + oApl:oFac:ORDEN
EndIf
 UTILPRN ::oUtil 24.7, 4.0 SAY "Pagina" +STR(::aTit[6],3) +" DE" +STR(oApl:oFac:PAGINAS,3)

// UTILPRN ::oUtil LINEA Self:nEndLine-.9,11.0 TO Self:nEndLine-.9,15.0
// UTILPRN ::oUtil Self:nEndLine-.8,11.0 SAY "RECIBI, Firma C.C. o NIT" FONT ::oFnt5
 UTILPRN ::oUtil LINEA 25.9, 9.0 TO 25.9,15.0
 UTILPRN ::oUtil 26.0, 9.0 SAY "RECIBI, Firma C.C. o NIT" FONT ::oFnt5

If lFin
   nCol := oApl:oFac:TOTALFAC - oApl:oFac:TOTALIVA + oApl:oFac:TOTALDES
   nL   := oApl:oFac:TOTALFAC - oApl:oFac:RETFTE - oApl:oFac:RETICA - oApl:oFac:RETIVA
   cLinea := Letras( nL,76 )
   UTILPRN ::oUtil 21.1, 1.8 SAY cLinea[1]                                     FONT ::oFnt5
   UTILPRN ::oUtil 21.5, 1.8 SAY cLinea[2]                                     FONT ::oFnt5
   UTILPRN ::oUtil 21.1,20.0 SAY TRANSFORM( nCol              ,"999,999,999" ) FONT ::oFnt2 RIGHT
   If oApl:oFac:TOTALDES > 0
      nCol := (oApl:oFac:TOTALDES / nCol) * 100
      UTILPRN ::oUtil 21.6,15.5 SAY "Dscto."        FONT ::oFnt5
      UTILPRN ::oUtil 21.6,16.5 SAY TRANSFORM( nCol,"99.9%" )
      UTILPRN ::oUtil 21.6,20.0 SAY TRANSFORM( oApl:oFac:TOTALDES,"999,999,999" ) FONT ::oFnt2 RIGHT
   EndIf
   UTILPRN ::oUtil 22.1,16.5 SAY TRANSFORM( ::aTit[3]*100,"99.9%" )
   UTILPRN ::oUtil 22.1,20.0 SAY TRANSFORM( oApl:oFac:TOTALIVA,"999,999,999" ) FONT ::oFnt2 RIGHT
   UTILPRN ::oUtil 22.6,20.0 SAY TRANSFORM( oApl:oFac:RETFTE  ,"999,999,999" ) FONT ::oFnt2 RIGHT
   UTILPRN ::oUtil 23.1,20.0 SAY TRANSFORM( oApl:oFac:RETIVA  ,"999,999,999" ) FONT ::oFnt2 RIGHT
   UTILPRN ::oUtil 23.6,20.0 SAY TRANSFORM( oApl:oFac:RETICA  ,"999,999,999" ) FONT ::oFnt2 RIGHT
   UTILPRN ::oUtil 24.1,20.0 SAY TRANSFORM( nL                ,"999,999,999" ) FONT ::oFnt2 RIGHT
Else
   UTILPRN ::oUtil 24.1,20.0 SAY "PASAN .." FONT ::oFnt2 RIGHT
   ::nLinea := ::nEndLine
EndIf

RETURN NIL

//------------------------------------//
FUNCTION Telefonos( nNit )
   LOCAL aTel := {}, cQry, hRes, nR
cQry := "SELECT numero, extencion, tipo FROM telefonos "+;
        "WHERE codigo_nit = " + LTRIM(STR(nNit))        +;
        " ORDER BY orden"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nR   := MSNumRows( hRes )
While nR > 0
   cQry := MyReadRow( hRes )
   AEVAL( cQry, { |xV,nP| cQry[nP] := MyClReadCol( hRes,nP ) } )
   AADD( aTel,{ cQry[1],cQry[2],cQry[3] } )
   nR --
EndDo
   MSFreeResult( hRes )
If LEN( aTel ) == 0
   AADD( aTel,{ SPACE(16),SPACE(40),"T" } )
EndIf
RETURN aTel