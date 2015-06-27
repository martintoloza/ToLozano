// Programa.: JVMLIFAC.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Imprime facturas
#include "FiveWin.ch"
#INCLUDE "Utilprn.CH"

MEMVAR oApl

PROCEDURE CaoLiFac( aDF,aDT,oDb )
   LOCAL oLF
If EMPTY( aDF[1] )
   MsgInfo("No hay Documento para imprimir")
   RETURN
EndIf
oLF := TListFac()
If oLF:Dialog( aDF )
   oLF:NEW( aDF,aDT,oDb )
EndIf
RETURN

//------------------------------------//
CLASS TListFac FROM TIMPRIME

 DATA aPie, aTel, nTL, sNom
 DATA lPrev   INIT .f.

 METHOD NEW( aF,aDT,oDb ) Constructor
 METHOD Dialog( aF )
 METHOD CaoLiFad( oRpt,aDT )
 METHOD FactuPos( oRpt,aDT )
 METHOD LaserFac( aDT )
 METHOD Cabecera( lSep,nSpace,nSuma )
 METHOD PieFactu( nCol,nLine,nSeparator,lFin )
 METHOD LaserNCR( aM,aD,aP,nCtl )
 METHOD ListoCot( oRpt,aDT )
 METHOD LaserCot( aDT )
ENDCLASS

//------------------------------------//
METHOD NEW( aF,aDT,oDb ) CLASS TListFac
   LOCAL oRpt, nFac, nL
::sNom := If( oDb # NIL, "Z", oApl:Tipo )
::aPie := Buscar( "SELECT '', prefijo, piefactu, observa FROM cademprf "+;
                  "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
                   " AND tipo    = '"+ ::sNom                   +;
                  "' AND ("          + LTRIM(STR(aF[1]))        +;
                   " BETWEEN desde AND hasta)","CM",,8 )
If LEN( ::aPie ) == 0
   ::aPie := { "",oApl:oEmp:PREFIJO,ALLTRIM( oApl:oEmp:PIEFACTU ),;
               "MATERIALES Y ACCESORIOS ELECTRICOS",0,0,0,0,0,0,0 }
Else
   ::aPie[3] := ALLTRIM( ::aPie[3] )
   ASIZE( ::aPie,11 )
EndIf
 ::nTL := LEN( aDT )
If oDb # NIL
   AFILL( ::aPie,0,7 )
   ::aEnc[04] := TRANSFORM( aF[1]*100,"99.9%" )
   ::aEnc[10] := If( oApl:oNit:CODIGO == 1, oDb:CLIENTE, "" )
   ::aEnc[11] := aF[3]
   ::aEnc[13] := ::aEnc[14] := oDb:FECHA
   ::aEnc[16] := oDb:ORDEN
   ::aTel := Telefonos( oApl:oNit:CODIGO_NIT )
   ::aPie[05] := oDb:TOTALDES
   ::aPie[06] := oDb:TOTALIVA
   ::aPie[11] := oDb:TOTALFAC
   If oApl:nTFor == 2
      ::aEnc[15] := INT( ::nTL/25 ) + If( ::nTL % 25 > 0, 1, 0 )
      ::LaserCot( aDT )
   Else
      ::aEnc[08] := 26
      ::aEnc[15] := INT( ::nTL/14 ) + If( ::nTL % 14 > 0, 1, 0 )
      ::ListoCot( oRpt,aDT )
   EndIf
   RETURN NIL
EndIf
If oApl:oEmp:PRINTIVA
   ::aEnc[10] := oApl:oFac:CLIENTE
Else
   ::aEnc[04] := TRANSFORM( aF[1]*100,"99.9%" )
EndIf
   ::aEnc[13] := oApl:oFac:FECHOY
   ::aEnc[14] := oApl:oFac:FECHAENT
   ::aEnc[15] := oApl:oFac:PAGINAS
   ::aEnc[16] := oApl:oFac:ORDEN
::aPie[1] := "Régimen " + { "Simplificado ","Común ",;
                            "Grandes Contribuyentes " }[oApl:oEmp:TREGIMEN] +;
             ALLTRIM(oApl:oEmp:REGIMEN)
::aPie[05] := oApl:oFac:TOTALDES
::aPie[06] := oApl:oFac:TOTALIVA
::aPie[07] := oApl:oFac:RETFTE
::aPie[08] := oApl:oFac:RETIVA
::aPie[09] := oApl:oFac:RETICA
::aPie[10] := oApl:oFac:RETCRE
::aPie[11] := oApl:oFac:TOTALFAC
If oApl:Tipo $ oApl:oEmp:POS
   ::FactuPos( oRpt,aDT )
   RETURN NIL
EndIf
If oApl:oEmp:PORPC .AND. oApl:Tipo == "C"
   ::LaserFac( aDT )
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
   oRpt:Say( 53,59,TRANSFORM( ::aEnc[4]*100,"99.9" ) )
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
      oRpt:Say( 1,02,oRpt:CPILarge + ::aEnc[5] )
      oRpt:Say( 2,00,"Materiales y Accesorios Electricos" + SPACE(12) +;
                     oApl:oEmp:DIRECCION )
      oRpt:Say( 3,04,"NIT. " + oApl:oEmp:Nit )
      oRpt:Say( 3,46,"Telefonos: " + oApl:oEmp:TELEFONO )
      oRpt:Say( 4,00,::aEnc[6] )
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
nFac := INT( ::nTL/nL ) + If( ::nTL % nL > 0, 1, 0 )
FOR nL := 1 TO ::nTL
   If oRpt:nL == 0
      oRpt:SetFont( oRpt:CPINormal,82,2 )
      oRpt:Say( 1,02,oRpt:CPILarge + ::aEnc[5] )
      oRpt:Say( 2,00,PADC( ::aEnc[6],40 ) )
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
      oRpt:Say(  oRpt:nL,47,aF[4] + "DE VENTA No. " + ::aPie[2] + STRZERO(::aEnc[3],8) )
      oRpt:SetFont( oRpt:CPICompress,144,1 )
      oRpt:Say(++oRpt:nL,01,"Direccion : " + oApl:oNit:DIRECCION )
      oRpt:Say(  oRpt:nL,82,oRpt:CPINormal+"FECHA DE " + aF[4] + NtChr( oApl:oFac:FECHOY,"2" ) )
      oRpt:Say(++oRpt:nL,01,"Telefono  : " + ::aTel[1,1] )
      oRpt:Say(  oRpt:nL,40,"   Ciudad : " + aF[7] )
      oRpt:Say(  oRpt:nL,90,"Vendedor : "  + ::aEnc[9])
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
 oRpt:Say(++oRpt:nL,46,"IMPOVENTAS " + TRANSFORM(::aEnc[4]*100,"99.9%") )
 oRpt:Say(  oRpt:nL,63,TRANSFORM(oApl:oFac:TOTALIVA,"999,999,999") )
 oRpt:Say(++oRpt:nL,01,"Son: " +oRpt:CPICompress + aF[1] )
 oRpt:Say(  oRpt:nL,95,oRpt:CPINormal + "TOTAL $" + TRANSFORM(oApl:oFac:TOTALFAC,"999,999,999") )
 oRpt:NewPage()
 oRpt:End()
RETURN NIL

//------------------------------------//
METHOD Dialog( aF ) CLASS TListFac
   LOCAL aOK, hDC := GetDC( 0 )
 //  DEFAULT cTit := "Factura"
 ::aFont := GetFontNames( hDC )
 ::cFont := "Courier New"
   aOK   := { .f.,If( TRIM( oApl:cUser ) == "Martin", .t., .f. ) }
DEFINE DIALOG ::oDlg TITLE "Imprime está " + aF[4]
   @ 02,62 CHECKBOX ::lPrev PROMPT "Vista Previa" OF ::oDlg ;
      SIZE 60,10 PIXEL
   @ 14,00 SAY "Número de Copias"  OF ::oDlg RIGHT PIXEL SIZE 60,10
   @ 14,62 GET ::nCopia OF ::oDlg PICTURE "99" SIZE 12,10 PIXEL;
      VALID Rango( ::nCopia,1,10 ) ;
      WHEN oApl:oEmp:PORPC
   @ 26,00 SAY "Escoja la Fuente"  OF ::oDlg RIGHT PIXEL SIZE 60,10
   @ 26,62 COMBOBOX ::cFont ITEMS ::aFont SIZE 80,99 OF ::oDlg PIXEL;
      WHEN oApl:oEmp:PORPC
   @ 38,62 GET oApl:nX             OF ::oDlg PICTURE "99.9" SIZE 20,10 PIXEL;
      WHEN aOK[2]
   @ 38,92 GET oApl:nY             OF ::oDlg PICTURE "99.9" SIZE 20,10 PIXEL;
      WHEN aOK[2]
   @ 52,70 BUTTON hDC PROMPT "Imprimir" SIZE 44,12 OF ::oDlg;
      ACTION ( aOK[1] := .t., ::oDlg:End() ) PIXEL
ACTIVATE DIALOG ::oDlg CENTER
If aOK[1]
   ::aEnc := { .t.,FormatoNit( oApl:oNit:CODIGO,oApl:oNit:DIGITO ),aF[1],"",;
               oApl:cEmpresa,"",0,0,aF[2],"","FACTURA DE VENTA", aF[3],,,0,,;
               Buscar( {"codigo",oApl:oNit:CODIGO_CIU},"ciudades","nombre",8 ) }
   If !EMPTY(oApl:oEmp:NOMBRE2)
      ::aEnc[5] := ALLTRIM(oApl:oEmp:NOMBRE2)
      ::aEnc[6] := oApl:cEmpresa
   EndIf
EndIf
RETURN aOK[1]

//------------------------------------//
METHOD CaoLiFad( oRpt,aDT ) CLASS TListFac
   LOCAL aL, nL, nPag
aL := { 26,"",If( oApl:oNit:CODIGO == 1, oApl:oFac:CLIENTE, oApl:oNit:NOMBRE ) }
nPAG := INT( ::nTL/19 ) + If( ::nTL % 19 > 0, 1, 0 )
oRpt:nL := 0
FOR nL := 1 TO ::nTL
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
   LOCAL aL, nL, nPAG, nP
aL := { If( oApl:oNit:CODIGO == 1, oApl:oFac:CLIENTE, oApl:oNit:NOMBRE ),26,"" }
nL := ::nTL * 2 + 27
::Init( "Factura"+STR(::aEnc[3]), .t. ,, !::lPrev ,,,, 5 )
ASIZE( ::aFnt,7 )
 DEFINE FONT ::aFnt[7] NAME ::cFont SIZE 0,-7  OF ::oPrn
PAGE
   UTILPRN ::oUtil 1.0, 0.1 SAY PADC( ::aEnc[5],42 )
   UTILPRN ::oUtil 1.4, 0.1 SAY PADC( "NIT: " + oApl:oEmp:NIT,42 )
   UTILPRN ::oUtil 1.8, 0.1 SAY PADC( ::aPie[1],42 )
   UTILPRN ::oUtil 2.2, 0.3 SAY oApl:oEmp:DIRECCION
   UTILPRN ::oUtil 2.2, 4.3 SAY "Tel." + oApl:oEmp:TELEFONO
   UTILPRN ::oUtil 2.6, 1.2 SAY "Barranquilla - Colombia"
   UTILPRN ::oUtil 3.0, 0.2 SAY REPLICATE("*",40)
   UTILPRN ::oUtil 3.4, 0.5 SAY "Documento impreso por computador por:"
   UTILPRN ::oUtil 3.8, 0.1 SAY PADC( ::aEnc[5],42 )
   UTILPRN ::oUtil 4.2, 0.2 SAY REPLICATE("*",40)
   UTILPRN ::oUtil 4.6, 0.1 SAY PADC( "Contado",42 )
   UTILPRN ::oUtil 5.0, 0.8 SAY "FACTURA DE VENTA No." + ::aPie[2] + STR(::aEnc[3],10)
   UTILPRN ::oUtil 5.4, 0.2 SAY "Fecha: " + NtChr( oApl:oFac:FECHOY,"2" )
   UTILPRN ::oUtil 5.8, 0.2 SAY "SR(a): " + aL[1]
   UTILPRN ::oUtil 6.2, 0.2 SAY "Dirección:"+ oApl:oNit:DIRECCION
   UTILPRN ::oUtil 6.6, 0.2 SAY "Nit o C.C.:"+ ::aEnc[2]
   UTILPRN ::oUtil 7.0, 0.2 SAY REPLICATE("-",40)
   UTILPRN ::oUtil 7.4, 0.2 SAY " Descripcion"
   UTILPRN ::oUtil 7.4, 4.8 SAY "Pre.Uni"   RIGHT
   UTILPRN ::oUtil 7.4, 7.0 SAY "Vlr.Total" RIGHT
   ::nLinea := 7.8
   FOR nL := 1 TO ::nTL
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
/*
MsgInfo( nL,"nL" )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,,.t.,,2,nL,nL )
oRpt:nPage := 1
   oRpt:Say(  1,01,PADC( ::aEnc[5],50 ) )
   oRpt:Say(  2,01,PADC( "NIT: " + oApl:oEmp:NIT,50 ) )
   oRpt:Say(  3,01,oApl:oEmp:DIRECCION )
   oRpt:Say(  3,31,"Tel." + oApl:oEmp:TELEFONO )
   oRpt:Say(  4,10,"Barranquilla - Colombia" )
   oRpt:Say(  5,10,REPLICATE("*",40) )
   oRpt:Say(  6,01,"Documento impreso por computador por:" )
   oRpt:Say(  7,01,PADC( ::aEnc[5],50 ) )
   oRpt:Say(  8,10,REPLICATE("*",40) )
   oRpt:Say(  9,01,PADC( "Contado",50 ) )
   oRpt:Say( 10,10,"FACTURA DE VENTA No."+oApl:oEmp:PREFIJO+STR(::aEnc[3],10) )
   oRpt:Say( 11,01,"Fecha: " + NtChr( oApl:oFac:FECHOY,"2" ) )
   oRpt:Say( 12,01,"SR(a): " + aL[1] )
   oRpt:Say( 13,01,"Dirección:"+ oApl:oNit:DIRECCION )
   oRpt:Say( 14,01,"Nit o C.C.:"+ ::aEnc[2] )
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
METHOD LaserFac( aDT ) CLASS TListFac
   LOCAL nIva, nL
::Init( "Factura"+STR(::aEnc[3]), .t. ,, !::lPrev ,,, ::lPrev, 5 )
//MsgInfo( ::nEndLine,"FIN" )
ASIZE( ::aFnt,8 )
 DEFINE FONT ::aFnt[7] NAME ::cFont SIZE 0,-20 BOLD OF ::oPrn
 DEFINE FONT ::aFnt[8] NAME ::cFont SIZE 0,-7       OF ::oPrn

 PAGE
    FOR nL := 1 TO ::nTL
       If !EMPTY( aDT[nL,1] )
             aDT[nL,7] += aDT[nL,8]   //DESMON + PRECIOVEN
          ::sNom := UMedidas( aDT[nL,5]," DE " ) + aDT[nL,2]
          ::Cabecera( .t. )
          UTILPRN ::oUtil Self:nLinea, 3.8 SAY TRANSFORM( aDT[nL,4],"999,999.99" )     RIGHT
          UTILPRN ::oUtil Self:nLinea, 4.1 SAY LEFT( ::sNom,41 )
          If oApl:oEmp:PRINTIVA
             aDT[nL,7] += aDT[nL,9]   //+ MONTOIVA
             nIva := aDT[nL,13] * 100 - 100
             UTILPRN ::oUtil Self:nLinea,14.8 SAY TRANSFORM( nIva,"99%" )              RIGHT
             UTILPRN ::oUtil Self:nLinea,16.9 SAY TRANSFORM( aDT[nL,03],"9,999,999" )  RIGHT
          Else
             UTILPRN ::oUtil Self:nLinea,16.9 SAY TRANSFORM( aDT[nL,14],"9,999,999" )  RIGHT
          EndIf
             UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM( aDT[nL,07],"99,999,999" ) RIGHT
          ::aEnc[8] ++
          If ::aEnc[8] == 25 .AND. nL < ::nTL
             ::PieFactu( 1.1,80,.4,.f. )
             ::nLinea += 3.0
          EndIf
       ElseIf nL == 1
          ::Cabecera( .t. )
          UTILPRN ::oUtil 9.5, 4.0 SAY "A N U L A D A" FONT ::aFnt[4]
       EndIf
    NEXT nL
    ::PieFactu( 1.1,80,.4,.t. )
 ENDPAGE
IMPRIME END .F.
RETURN NIL

//------------------------------------//
METHOD Cabecera( lSep,nSpace,nSuma ) CLASS TListFac

If lSep .AND. !::aEnc[1]
   ::aEnc[1] := ::Separator( nSpace )
EndIf
If ::aEnc[1]
   ::aEnc[1] := .F.
// Para imprimir una imagen en el formato actual de papel ,
//simplemente le decimos la imagen que es y la clausula PAGE y yasta!
//   UTILPRN ::oUtil 0.5,1 IMAGE oApl:cIco+"logotipo.jpg" JPG PAGE
// Podemos usar tambien la clausula JPG para poner Bitmaps
   If FILE( oApl:cIco+"logotipo.jpg" )
      //MsgInfo( "Hola Logo" )
      UTILPRN ::oUtil 1.3,1 IMAGE oApl:cIco+"logotipo.jpg" SIZE oApl:nX,oApl:nY JPG
   EndIf
   UTILPRN ::oUtil SELECT ::aFnt[2]

   UTILPRN ::oUtil 1.5, 5.0 SAY ::aEnc[5]                     FONT ::aFnt[7]
   UTILPRN ::oUtil 2.5, 5.7 SAY ::aEnc[6]
   UTILPRN ::oUtil 2.5,13.0 SAY ::aPie[4]
   UTILPRN ::oUtil 3.0, 6.3 SAY "NIT: " + oApl:oEmp:NIT
   UTILPRN ::oUtil 3.0,15.0 SAY oApl:oEmp:DIRECCION
   UTILPRN ::oUtil 3.5, 5.0 SAY ::aPie[1]
   UTILPRN ::oUtil 3.5,14.2 SAY "Teléfonos: " + oApl:oEmp:TELEFONO
   UTILPRN ::oUtil 4.0, 5.0 SAY oApl:oEmp:ICA
   UTILPRN ::oUtil 4.0,14.6 SAY "TeleFax: "+ oApl:oEmp:FAX
   UTILPRN ::oUtil 4.5,14.4 SAY "E-mail: " + oApl:oEmp:EMAIL  FONT ::aFnt[8]
   UTILPRN ::oUtil 4.8,14.6 SAY "Barranquilla - Colombia"

   UTILPRN ::oUtil SELECT ::aFnt[5]
   UTILPRN ::oUtil 5.0, 3.2 SAY "SEÑORES:"                    FONT ::aFnt[2] RIGHT
   UTILPRN ::oUtil 5.0, 3.4 SAY oApl:oNit:NOMBRE              FONT ::aFnt[2]
   UTILPRN ::oUtil 5.5, 3.2 SAY "NIT:"                        FONT ::aFnt[2] RIGHT
   UTILPRN ::oUtil 5.5, 3.4 SAY ::aEnc[2]
   UTILPRN ::oUtil 5.5,15.5 SAY ::aEnc[11]                    FONT ::aFnt[4]
   UTILPRN ::oUtil 6.0, 3.2 SAY "Dirección:"                  FONT ::aFnt[2] RIGHT
   UTILPRN ::oUtil 6.0, 3.4 SAY oApl:oNit:DIRECCION
   UTILPRN ::oUtil 6.0,15.7 SAY "No." + ::aPie[2] + STR(::aEnc[3],10) FONT ::aFnt[4]
   UTILPRN ::oUtil 6.5, 3.4 SAY ::aEnc[17]
   UTILPRN ::oUtil 6.5,13.7 SAY "Fecha " + ::aEnc[12]
   UTILPRN ::oUtil 6.5,17.4 SAY DTOC(::aEnc[13])              FONT ::aFnt[6]
   If LEFT( ::aEnc[11],4 ) == "Nota"
      UTILPRN ::oUtil 7.0, 4.2 SAY "Por Concepto de:"         FONT ::aFnt[2] RIGHT
      UTILPRN ::oUtil 7.0, 4.5 SAY ::aEnc[10]                 FONT ::aFnt[2]

      UTILPRN ::oUtil BOX  7.4 , 1.0 TO  7.9 ,20.1 ROUND 25,25
      UTILPRN ::oUtil 7.5, 2.0 SAY "Le(s) rogamos tomar nota de los sigientes abonos "+;
                                   "hechos a su apreciable cuenta"  FONT ::aFnt[5]
      UTILPRN ::oUtil 7.5,17.5 SAY "V A L O R"                FONT ::aFnt[2]
   Else
      UTILPRN ::oUtil 7.0, 3.4 SAY ::aEnc[10]
      If ::aEnc[12] == "Factura"
         UTILPRN ::oUtil 7.0,13.7 SAY "Fecha Vencimiento"
         UTILPRN ::oUtil 7.0,17.4 SAY DTOC(::aEnc[14])           FONT ::aFnt[6]
      EndIf
      UTILPRN ::oUtil BOX  7.4 , 1.0 TO  7.9 ,20.1 ROUND 25,25
      UTILPRN ::oUtil 7.5, 2.0 SAY "CANTIDAD"                 FONT ::aFnt[2]
      UTILPRN ::oUtil 7.5, 7.0 SAY "DESCRIPCION ARTICULO"     FONT ::aFnt[2]
      If oApl:oEmp:PRINTIVA
         UTILPRN ::oUtil 7.5,14.8 SAY "IVA" RIGHT
      EndIf
      UTILPRN ::oUtil 7.5,15.4 SAY "V.UNIT."                  FONT ::aFnt[2]
      UTILPRN ::oUtil 7.5,17.5 SAY "VALOR TOTAL"              FONT ::aFnt[2]
      ::aEnc[7]++
      ::aEnc[8]:= 0
   EndIf
   ::nLinea := 8.0
EndIf
RETURN NIL

//------------------------------------//
METHOD PieFactu( nCol,nLine,nSeparator,lFin ) CLASS TListFac
   LOCAL cLinea, nL, nF
   DEFAULT nLine := 75,;
            nCol := 1.1
 UTILPRN ::oUtil BOX  20.5 , 1.0 TO 21.5 ,15.0 ROUND 25,25
 UTILPRN ::oUtil BOX  20.5 ,15.0 TO 24.6 ,20.1 ROUND 25,25
 UTILPRN ::oUtil BOX  21.5 , 1.0 TO 24.6 ,15.0 ROUND 25,25
 FOR nL := 21.5  TO 24.0  STEP .5
    UTILPRN ::oUtil LINEA nL,15.0 TO nL,20.1
 NEXT nL
 ::nLinea := 21.7
 FOR nL := 1 TO  MLCOUNT( ::aPie[3],nLine )
    cLinea := MEMOLINE( ::aPie[3],nLine,nL )
    UTILPRN ::oUtil Self:nLinea,nCol SAY cLinea FONT ::aFnt[5]
    ::Separator( nSeparator )
 NEXT nL

   UTILPRN ::oUtil 20.6, 1.1 SAY "SON"           FONT ::aFnt[5]
   UTILPRN ::oUtil 20.6,17.3 SAY "SUBTOTAL"      FONT ::aFnt[5] RIGHT
   UTILPRN ::oUtil 21.6,15.5 SAY "I.V.A."        FONT ::aFnt[5]
   UTILPRN ::oUtil 22.1,17.3 SAY "ReteFuente"    FONT ::aFnt[5] RIGHT
   UTILPRN ::oUtil 22.6,17.3 SAY "ReteIVA"       FONT ::aFnt[5] RIGHT
   UTILPRN ::oUtil 23.1,17.3 SAY "ReteICA"       FONT ::aFnt[5] RIGHT
If ::aPie[10] > 0
   UTILPRN ::oUtil 23.6,17.3 SAY "ReteCREE"      FONT ::aFnt[5] RIGHT
EndIf
   UTILPRN ::oUtil 24.1,17.3 SAY "TOTAL A PAGAR" FONT ::aFnt[5] RIGHT
If !EMPTY( ::aEnc[16] )
   UTILPRN ::oUtil 25.0, 1.1 SAY "Orden de Compra No. " + ::aEnc[16]
EndIf
 UTILPRN ::oUtil 24.7, 6.5 SAY "Pagina" +STR(::aEnc[7],3) +" DE" +STR(::aEnc[15],3)

// UTILPRN ::oUtil LINEA Self:nEndLine-.9,11.0 TO Self:nEndLine-.9,15.0
// UTILPRN ::oUtil Self:nEndLine-.8,11.0 SAY "RECIBI, Firma C.C. o NIT" FONT ::aFnt[5]
 UTILPRN ::oUtil LINEA 25.9, 9.0 TO 25.9,15.0
 UTILPRN ::oUtil 26.0, 9.0 SAY "RECIBI, Firma C.C. o NIT" FONT ::aFnt[5]

If lFin
   nCol := ::aPie[11] - ::aPie[06] + ::aPie[05]
   ::aPie[11] -= (::aPie[07] + ::aPie[08] + ::aPie[09] + ::aPie[10])
   cLinea := Letras( ::aPie[11],76 )
   UTILPRN ::oUtil 20.6, 1.8 SAY cLinea[1]                             FONT ::aFnt[5]
   UTILPRN ::oUtil 21.0, 1.8 SAY cLinea[2]                             FONT ::aFnt[5]
   UTILPRN ::oUtil 20.6,20.0 SAY TRANSFORM( nCol      ,"999,999,999" ) FONT ::aFnt[2] RIGHT
   If ::aPie[05] > 0
      nCol := (::aPie[05] / nCol) * 100
      UTILPRN ::oUtil 21.5,15.5 SAY "Dscto."        FONT ::aFnt[5]
      UTILPRN ::oUtil 21.5,16.5 SAY TRANSFORM( nCol,"99.9%" )
      UTILPRN ::oUtil 21.5,20.0 SAY TRANSFORM( ::aPie[05],"999,999,999" ) FONT ::aFnt[2] RIGHT
   EndIf
   UTILPRN ::oUtil 21.6,16.5 SAY ::aEnc[4]
   UTILPRN ::oUtil 21.6,20.0 SAY TRANSFORM( ::aPie[06],"999,999,999" ) FONT ::aFnt[2] RIGHT
   UTILPRN ::oUtil 22.1,20.0 SAY TRANSFORM( ::aPie[07],"999,999,999" ) FONT ::aFnt[2] RIGHT
   UTILPRN ::oUtil 22.6,20.0 SAY TRANSFORM( ::aPie[08],"999,999,999" ) FONT ::aFnt[2] RIGHT
   UTILPRN ::oUtil 23.1,20.0 SAY TRANSFORM( ::aPie[09],"999,999,999" ) FONT ::aFnt[2] RIGHT
   UTILPRN ::oUtil 23.6,20.0 SAY TRANSFORM( ::aPie[10],"999,999,999" ) FONT ::aFnt[2] RIGHT
   UTILPRN ::oUtil 24.1,20.0 SAY TRANSFORM( ::aPie[11],"999,999,999" ) FONT ::aFnt[2] RIGHT
Else
   UTILPRN ::oUtil 24.1,20.0 SAY "PASAN .." FONT ::aFnt[2] RIGHT
   ::nLinea := ::nEndLine
EndIf

RETURN NIL

//------------------------------------//
METHOD ListoCot( oRpt,aDT ) CLASS TListFac
   LOCAL nL
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,,::lPrev,,,33,33 )
oRpt:nPage := 1
oRpt:nL    := 0
FOR nL := 1 TO ::nTL
   If oRpt:nL == 0
      oRpt:nL := 12
      oRpt:SetFont( oRpt:CPINormal,82,2 )
      oRpt:Say( 1,02,oRpt:CPILarge + ::aEnc[5] )
      oRpt:Say( 2,00,"Materiales y Accesorios Electricos" )
      oRpt:Say( 2,46,oApl:oEmp:DIRECCION )
      oRpt:Say( 3,04,"NIT. " + oApl:oEmp:Nit )
      oRpt:Say( 3,46,"Telefonos: " + oApl:oEmp:TELEFONO )
      oRpt:Say( 4,00,::aEnc[6] )
      oRpt:Say( 4,46,"      Fax: " + oApl:oEmp:FAX )
      oRpt:Say( 5,46,"Barranquilla-Colombia" )    //oApl:cCiu
      oRpt:Say( 6,01,"Se\or(es) : " + NtChr( ::aEnc[10],"\" ) )
      oRpt:Say( 7,01,"Nit. o C.C. " + ::aEnc[2] )
      oRpt:Say( 7,50,::aEnc[12] + " No. " + STRZERO(::aEnc[3],8) )
      oRpt:SetFont( oRpt:CPICompress,144,1 )
      oRpt:Say( 8,01,"Direccion : " + oApl:oNit:DIRECCION )
      oRpt:Say( 8,78,oRpt:CPINormal+"FECHA DE " + ::aEnc[12] + " " + NtChr( ::aEnc[13],"2" ) )
      oRpt:Say( 9,01,"Telefono  : " + ::aTel[1,1] )
      oRpt:Say( 9,50,"   Ciudad : " + ::aEnc[17] )
      oRpt:Say( 9,94,"O.C.: " + ::aEnc[16] )
      oRpt:SetFont( oRpt:CPINormal,82,2 )
      oRpt:Say(10,01," Cantidad  Descripcion del Articulo               " +;
                  "Vr/Unitario  Valor Total" )
      oRpt:Say(11,01,REPLICATE( "_",74 ) )
   EndIf
   If !EMPTY( aDT[nL,1] )
      ::sNom := UMedidas( aDT[nL,5]," DE " ) + NtChr( aDT[nL,2],"\" )
      oRpt:Say( oRpt:nL,00,TRANSFORM( aDT[nL,4],"999,999.99" ) )
      oRpt:Say( oRpt:nL,11,LEFT( ::sNom,41 ) )
      oRpt:Say( oRpt:nL,52,TRANSFORM( aDT[nL,3],"9,999,999" ) )
      oRpt:Say( oRpt:nL,63,TRANSFORM( aDT[nL,7]+aDT[nL,8],"999,999,999" ) )
      oRpt:nL ++
   EndIf
   If oRpt:nL == ::aEnc[8] .AND. oRpt:nPage < ::aEnc[15]
      oRpt:nL :=  0
      oRpt:Say( ::aEnc[8]  ,55,REPLICATE("=",20) )
      oRpt:Say( ::aEnc[8]+1,01,"Pagina" + STR( oRpt:nPage,3 ) + " DE" + STR( ::aEnc[15],3 ) )
      oRpt:Say( ::aEnc[8]+1,55,"Pasan .............." )
      oRpt:nPage++
      oRpt:NewPage()
   EndIf
NEXT nL
 oRpt:nL := ::aEnc[8]
 oRpt:Say(  oRpt:nL,55,REPLICATE("=",20) )
 oRpt:Say(++oRpt:nL,01,"Pagina" + STR( oRpt:nPage,3 ) + " DE" + STR( ::aEnc[15],3 ) )
 oRpt:Say(  oRpt:nL,52,"SUB-TOTAL  " + TRANSFORM(nL,"999,999,999") )
 If ::aPie[05] > 0
    nL := ::aPie[11] - ::aPie[06] + ::aPie[05]
    nL := ::aPie[05] / nL * 100
    oRpt:Say(++oRpt:nL,45,"Menos Dscto." + TRANSFORM(nL,"999%") )
    oRpt:Say(  oRpt:nL,64,TRANSFORM(::aPie[05],"99,999,999") )
 EndIf
 aDT := Letras( ::aPie[11] )
 oRpt:Say(++oRpt:nL,46,"IMPOVENTAS " + ::aEnc[4] )
 oRpt:Say(  oRpt:nL,63,TRANSFORM(::aPie[06],"999,999,999") )
 oRpt:Say(++oRpt:nL,01,"Son: " +oRpt:CPICompress + aDT[1] )
 oRpt:Say(  oRpt:nL,95,oRpt:CPINormal + "TOTAL $" + TRANSFORM(::aPie[11],"999,999,999") )
 oRpt:NewPage()
 oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserCot( aDT ) CLASS TListFac
   LOCAL nIva, nL
 ::Init( ::aEnc[12] + STR(::aEnc[3]), .t. ,, !::lPrev ,,, ::lPrev, 5 )
ASIZE( ::aFnt,8 )
 DEFINE FONT ::aFnt[7] NAME ::cFont SIZE 0,-20 BOLD OF ::oPrn
 DEFINE FONT ::aFnt[8] NAME ::cFont SIZE 0,-7       OF ::oPrn

 PAGE
    FOR nL := 1 TO ::nTL
       If !EMPTY( aDT[nL,1] )
             aDT[nL,7] += aDT[nL,8]   //DESMON + PRECIOVEN
          ::sNom := UMedidas( aDT[nL,5]," DE " ) + aDT[nL,2]
          ::Cabecera( .t. )
          UTILPRN ::oUtil Self:nLinea, 3.8 SAY TRANSFORM( aDT[nL,4],"999,999.99" )     RIGHT
          UTILPRN ::oUtil Self:nLinea, 4.1 SAY LEFT( ::sNom,41 )
          If oApl:oEmp:PRINTIVA
             aDT[nL,7] += aDT[nL,9]   //+ MONTOIVA
             nIva := aDT[nL,12] * 100 - 100
             UTILPRN ::oUtil Self:nLinea,14.8 SAY TRANSFORM( nIva,"99%" )              RIGHT
             UTILPRN ::oUtil Self:nLinea,16.9 SAY TRANSFORM( aDT[nL,03],"9,999,999" )  RIGHT
          Else
             UTILPRN ::oUtil Self:nLinea,16.9 SAY TRANSFORM( aDT[nL,13],"9,999,999" )  RIGHT
          EndIf
             UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM( aDT[nL,07],"99,999,999" ) RIGHT
          ::aEnc[8] ++
          If ::aEnc[8] == 25 .AND. nL < ::nTL
             ::PieFactu( 1.1,80,.4,.f. )
             ::nLinea += 3.0
          EndIf
       ElseIf nL == 1
          ::Cabecera( .t. )
          UTILPRN ::oUtil 9.5, 4.0 SAY "A N U L A D A" FONT ::aFnt[4]
       EndIf
    NEXT nL
    ::PieFactu( 1.1,80,.4,.t. )
 ENDPAGE
IMPRIME END .F.
RETURN NIL

//------------------------------------//
METHOD LaserNCR( aM,aD,aP,nCtl ) CLASS TListFac
   LOCAL aNC, nL, hRes
::aEnc[10] := aM[17]
::aEnc[11] := "Nota Crédito"
::aEnc[12] := "N.Crédito"
::aEnc[13] := ::aEnc[14] := aM[18]
::aPie := { "","","","" }

::Init( "N.Credito"+STR(aM[2]), .t. ,, !::lPrev ,,, ::lPrev )
ASIZE( ::aFnt,8 )
 DEFINE FONT ::aFnt[7] NAME ::cFont SIZE 0,-20 BOLD OF ::oPrn
 DEFINE FONT ::aFnt[8] NAME ::cFont SIZE 0,-7       OF ::oPrn

 PAGE
 If aM[14] <= 2
    FOR nL := 1 TO LEN( aD )
       ::sNom := UMedidas( aD[nL,4]," DE " ) + aD[nL,2]
       ::Cabecera( .t. )
       UTILPRN ::oUtil Self:nLinea, 3.8 SAY TRANSFORM( aD[nL,3],  "999,999.99" ) RIGHT
       UTILPRN ::oUtil Self:nLinea, 4.1 SAY LEFT( ::sNom,41 )
     //UTILPRN ::oUtil Self:nLinea,16.9 SAY TRANSFORM( aD[nL,7],"@Z 9,999,999" ) RIGHT
       UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM( aD[nL,5],  "99,999,999" ) RIGHT
    NEXT nL
 Else
    FOR nL := 1 TO LEN( aP )
       ::Cabecera( .t. )
       UTILPRN ::oUtil Self:nLinea, 3.8 SAY TRANSFORM( aP[nL,1],  "9999999999" ) RIGHT
       UTILPRN ::oUtil Self:nLinea, 4.1 SAY LEFT( aP[nL,5],41 )
       UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM( aP[nL,2], "999,999,999" ) RIGHT
    NEXT nL
 EndIf
 aD := Letras( aM[9],76 )  //TOTALFAC
       ::nLinea += 0.5
       UTILPRN ::oUtil BOX Self:nLinea, 1.0 TO Self:nLinea+1,15.0 ROUND 25,25
       ::nLinea += 0.1
       UTILPRN ::oUtil Self:nLinea, 1.1 SAY "SON"           FONT ::aFnt[5]
       UTILPRN ::oUtil Self:nLinea, 1.8 SAY aD[1]           FONT ::aFnt[5]
       UTILPRN ::oUtil Self:nLinea,17.3 SAY "SUBTOTAL"      FONT ::aFnt[5]         RIGHT
       UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM( aM[7],  "99,999,999" )      FONT ::aFnt[2] RIGHT
       ::nLinea += 0.5
       UTILPRN ::oUtil Self:nLinea, 1.8 SAY aD[2]           FONT ::aFnt[5]
    If aM[8] > 0
       UTILPRN ::oUtil Self:nLinea,15.5 SAY "I.V.A."        FONT ::aFnt[5]
       UTILPRN ::oUtil Self:nLinea,16.5 SAY aM[19]
       UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM( aM[8],"99,999,999" ) FONT ::aFnt[2] RIGHT
       ::nLinea += 0.5
    EndIf
       UTILPRN ::oUtil Self:nLinea,17.3 SAY "TOTAL ==> $"   FONT ::aFnt[5]         RIGHT
       UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM( aM[9],"99,999,999" ) FONT ::aFnt[2] RIGHT
       ::nLinea += 0.5

   ::sNom := "SELECT cuenta, SUM(valor_deb), SUM(valor_cre) "+;
             "FROM cgemovd "                                 +;
             "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))  +;
              " AND ano_mes = " + xValToChar( oApl:cPer )    +;
              " AND control = " + LTRIM(STR( nCtl ))         +;
              " GROUP BY cuenta"
   hRes := If( MSQuery( oApl:oMySql:hConnect,::sNom ),;
               MSStoreResult( oApl:oMySql:hConnect ) , 0 )
   nL   := MSNumRows( hRes )
   While nL > 0
      aNC := MyReadRow( hRes )
      AEVAL( aNC, { | xV,nP | aNC[nP] := MyClReadCol( hRes,nP ) } )
      UTILPRN ::oUtil Self:nLinea, 1.1 SAY aNC[1]
      UTILPRN ::oUtil Self:nLinea, 6.0 SAY TRANSFORM( aNC[2],"@Z 999,999,999.99" ) RIGHT
      UTILPRN ::oUtil Self:nLinea, 9.1 SAY TRANSFORM( aNC[3],"@Z 999,999,999.99" ) RIGHT
      ::nLinea += 0.5
      nL --
   EndDo
   MSFreeResult( hRes )
// oRpt:Say( 26,40,oApl:cUser )
 ENDPAGE
IMPRIME END .F.
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