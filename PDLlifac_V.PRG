// Programa.: CAOLIFAC.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Imprime facturas
#include "FiveWin.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE CaoLiFac( nFac,aDT,cTit,oDb )
   LOCAL oLF
If EMPTY( nFac )
   MsgInfo("No hay Documento para imprimir")
   RETURN
EndIf
oLF := TListFac()
oLF:nLis := oApl:nTFor
If oLF:Dialog( cTit )
   oLF:NEW( nFac,aDT,oDb )
EndIf
RETURN

//------------------------------------//
CLASS TListFac FROM TIMPRIME

 DATA aF   AS ARRAY INIT { "FACTURA DE VENTA", "FECHA FACTURA   : ",        oApl:cEmpresa,;
                           "PRODUCTOS  DO\A  LINDA S.A.S.","CRA. 50 # 80-237 FAX 3561508",;
                           "TEL:3561508 -3586312-3458002" ,"B/QUILLA  Nit. 890.114.941-5",;
                           "DULCES   ARABES   E  INTERNACIONALES",;
                           "COMIDAS  ARABES  RAPIDAS   CALIENTES",;
                           "TARTALETAS - PUDINES - PIE - HELADOS",;
                           "PICADAS  CALIENTES -  POSTRES  FRIOS","","","",0,0,0,"99,999,999" }
 DATA lPrev   INIT .t.
 DATA lTit    INIT .t.
 DATA nLis    INIT 1
 DATA lPrecio, nFac

 METHOD NEW( nFac,aDT,oDb ) Constructor
 METHOD Dialog( cTit )
 METHOD ListoWIN( aDT )
// METHOD ListoRem( oRpt,aDT,aM )
 METHOD Cabecera( lSep,nSpace,nSuma )
 METHOD PieFactu( cText,lFin,oRpt )
 METHOD Notas( nLin,oRpt )
ENDCLASS

//------------------------------------//
METHOD NEW( nFac,aDT,oDb ) CLASS TListFac
   LOCAL cPort, nL, oRpt
   ::nFac := nFac
If oApl:oNit:CODIGO > 0
   ::aF[12] := FormatoNit( oApl:oNit:CODIGO,oApl:oNit:DIGITO )
Else
   ::aF[12] := TRANSFORM( oApl:oFac:CEDULA,"9,999,999,999" )
EndIf
If oDb # NIL
   If oDb:TIPO # "U"
      ::aF[3] := "ELIAS HANDAL."
      ::aF[4] := SPACE(29)
      ::aF[5] := ::aF[6] := ::aF[7] := SPACE(28)
   EndIf
   If oDb:TIPO_P == "P"
      ::aF[1] :=  "  PEDIDO "
      aRem[7] := MlCount( TRIM(oDb:NOTA),78 )
   Else
      ::aF[1] :=  "REMISION "
   EndIf
   ::aF[13] := NtChr(oDb:FECHOY,"2")
   ::aF[14] := NtChr(oDb:FECHACOB,"2")

   AFILL( ::aPie,0,7 )
   ::aEnc[04] := TRANSFORM( aF[1]*100,"99.9%" )
   ::aEnc[10] := If( oApl:oNit:CODIGO == 1, oDb:CLIENTE, "" )
   ::aEnc[11] := aF[3]
   ::aEnc[13] := ::aEnc[14] := oDb:FECHA
   ::aEnc[16] := oDb:ORDEN
   ::aPie[05] := oDb:TOTALDES
   ::aPie[06] := oDb:TOTALIVA
   ::aPie[11] := oDb:TOTALFAC
   ::lPrecio  := MsgNoYes( "Remision Con Precio ?",">>> LISTAR <<<" )
   If ::nLis == 2
      ::aF[3] := STRTRAN( ::aF[3],"\A","ÑA" )
      ::aF[4] := STRTRAN( ::aF[4],"\A","ÑA" )
      ::aEnc[15] := INT( ::nTL/25 ) + If( ::nTL % 25 > 0, 1, 0 )
      ::LaserRem( aDT )
   Else
      ::aEnc[08] := 26
      ::aEnc[15] := INT( ::nTL/14 ) + If( ::nTL % 14 > 0, 1, 0 )
      ::ListoRem( oRpt,aDT )
   EndIf
   RETURN NIL
EndIf
//Facturas
If oApl:Tipo == "D"
   ::aF[1] := "NOTA  DE  PEDIDO"
   ::aF[2] := "FECHA DEL PEDIDO  "
   ::aF[3] := "ELIAS HANDAL."
   ::aF[4] := SPACE(29)
   ::aF[5] := ::aF[6] := ::aF[7] := SPACE(28)
EndIf
   nL       := { 12,10 }[::nLis]
   ::aF[13] := NtChr(oApl:oFac:FECHOY,"2")
   ::aF[14] := NtChr(oApl:oFac:FECHAVEN,"2")
   ::aF[15] := LEN( aDT )
   ::aF[15] := INT( ::aF[15]/nL ) + If( ::aF[15] % nL > 0, 1, 0 )
If ::nLis == 2
   ::aF[3] := STRTRAN( ::aF[3],"\A","ÑA" )
   ::aF[4] := STRTRAN( ::aF[4],"\A","ÑA" )
   ::ListoWIN( aDT )
   RETURN NIL
EndIf

oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ "" },::lPrev,,,33,33 )
oRpt:nL := 0
FOR nL := 1 TO LEN( aDT )
   If oRpt:nL ==  0
      oRpt:nL := 13
      oRpt:nPage ++
      oRpt:SetFont( oRpt:CPINormal,82,2 )
      oRpt:Say( 01,00,::aF[4]+ SPACE(14) + ::aF[08] )
      oRpt:Say( 02,00,::aF[5]+ SPACE(15) + ::aF[09] )
      oRpt:Say( 03,00,::aF[6]+ SPACE(15) + ::aF[10] )
      oRpt:Say( 04,00,::aF[7]+ SPACE(15) + ::aF[11] )

      oRpt:SetFont( oRpt:CPICompress,144,1 )
      oRpt:Say( 05,01,"Cliente   : " + oApl:oNit:NOMBRE + "  Nit. o C.C." )
      oRpt:Say( 05,87,oRpt:CPINormal+ ::aF[1] )
      oRpt:Say( 06,01,"Pedido Por: " + oApl:oFac:CLIENTE )
      oRpt:Say( 06,45,::aF[12] )
      oRpt:Say( 06,85,oRpt:CPINormal+ "    No. " + STRZERO( nFac,8 ) )
      oRpt:Say( 07,01,"Direccion : " + oApl:oNit:DIRECCION + ;
                       "  Telefono " + oApl:oNit:TELEFONO )
      oRpt:Say( 08,13,oApl:oFac:DIRECC + SPACE(13) + oApl:oFac:TELEFONO )
      oRpt:Say( 08,81,oRpt:CPINormal+ ::aF[2] + ::aF[13] )
      oRpt:Say( 09,01,"   Ciudad : " + oApl:oNit:CIUDAD )
      oRpt:Say( 09,45,"Enviado A: " + oApl:oFac:ENVIADO_A )
      oRpt:Say( 09,81,oRpt:CPINormal+ "FECHA VENCIMIENTO " + ::aF[14] )
      oRpt:SetFont( oRpt:CPINormal,82,2 )
      oRpt:Say( 10,60,"Pagina" + STR( oRpt:nPage,3 ) + " DE" + STR( ::aF[15],3 ) )
      oRpt:Say( 11,01,"Codigo  Descripcion del Articulo        Cantidad  " + ;
                   "Vr/Unitario  Valor Total" )
      oRpt:Say( 12,01,REPLICATE( "_",74 ) )
   EndIf
   ::aF[17] := aDT[nL,06] + aDT[nL,07]    // DESMON + PRECIOVEN
   oRpt:Say( oRpt:nL,02,aDT[nL,01] )
   oRpt:Say( oRpt:nL,09,aDT[nL,02],34 )
   oRpt:Say( oRpt:nL,41,TRANSFORM(aDT[nL,04],"9,999.99") )
   oRpt:Say( oRpt:nL,52,TRANSFORM(aDT[nL,03],"9,999,999") )
   oRpt:Say( oRpt:nL,65,TRANSFORM( ::aF[17] ,"9,999,999") )
/*
//                                                              9,999,999
Subtotal $9,999,999  Dsto.9,999,999  I.V.A.9,999,999  Total $999,999,999
Subtotal $9,999,999  Dsto.9,999,999  ImpoConsumo9,999,999  Total $999,999,999
   ::aF[16] := ROUND((aDT[nL,6] + aDT[nL,7]) / aDT[nL,4],0)
   ::aF[17] := aDT[nL,7] + aDT[nL,8]              //PRECIOVEN + MONTOIVA
   oRpt:Say( oRpt:nL, 02,aDt[nL,1] )
   oRpt:Say( oRpt:nL, 11,aDT[nL,2] )
   oRpt:Say( oRpt:nL, 62,TransForm(aDT[nL,4],"9,999.99" ) )
   oRpt:Say( oRpt:nL, 70,TransForm(::aF[16],::aF[18] ) )
   oRpt:Say( oRpt:nL, 85,TransForm(aDT[nL,6],"@Z 9,999,999") )
   oRpt:Say( oRpt:nL,100,TransForm(aDT[nL,7], ::aF[18]    ) )
   oRpt:Say( oRpt:nL,114,TransForm(aDT[nL,8],"9,999,999") )
   oRpt:Say( oRpt:nL,127,TransForm(::aF[17]   , ::aF[18]    ) )
*/
   oRpt:nL ++
   If oRpt:nL == 26 .AND. oRpt:nPage < ::aF[15]
    //::PieFactu( "Pasan ....",.f.,oRpt )
      oRpt:NewPage()
      oRpt:nL :=  0
   EndIf
NEXT nL
/*
::aF[17] := oApl:oFac:TOTALFAC - oApl:oFac:TOTALIVA
oRpt:Say(++oRpt:nL, 70,"TOTALES =>" )
oRpt:Say(  oRpt:nL, 85,TransForm(oApl:oFac:TOTALDES,"@Z 9,999,999") )
oRpt:Say(  oRpt:nL,100,TransForm( ::aF[17]           ,  "99,999,999") )
oRpt:Say(  oRpt:nL,114,TransForm(oApl:oFac:TOTALIVA,   "9,999,999") )
oRpt:Say(  oRpt:nL,127,TransForm(oApl:oFac:TOTALFAC,aLC[4] ) )
*/
::aF[17] := oApl:oFac:TOTALFAC - oApl:oFac:TOTALIVA + oApl:oFac:TOTALDES
oRpt:Say( 25,01,"Subtotal $" + TRANSFORM( ::aF[17],"9,999,999") )
If oApl:oFac:TOTALDES > 0
   oRpt:Say( 25,22,"Dsto." + TRANSFORM(oApl:oFac:TOTALDES,"9,999,999") )
EndIf
If oApl:oFac:FECHOY >= CTOD("01.01.2013")
   oRpt:Say( 25,38,"ImpoConsumo" + TRANSFORM(oApl:oFac:TOTALIVA,"9,999,999") )
Else
   oRpt:Say( 25,38,"I.V.A." + TRANSFORM(oApl:oFac:TOTALIVA,"9,999,999") )
EndIf
 ::PieFactu( "Total $"+ TRANSFORM( oApl:oFac:TOTALFAC,"999,999,999" ),.t.,oRpt )
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD Dialog( cTit ) CLASS TListFac
   LOCAL aOK, hDC := GetDC( 0 )
   DEFAULT cTit := "Factura"
 ::aFont  := GetFontNames( hDC )
 ::cFont  := "Courier New"
 ::nAncho := 0
 ::nAlto  := 1600
// ::nAncho := oApl:oEmp:ANCHO    //2400 215.9
// ::nAlto  := oApl:oEmp:ALTURA   //1600 139.7
//If TRIM( oApl:cUser ) == "MARIO" .OR.;
//   TRIM( oApl:cUser ) == "Martin"
   aOK   := { .f.,If( TRIM( oApl:cUser ) == "Martin", .t., .f. ) }
DEFINE DIALOG ::oDlg TITLE "Imprime está " + cTit
   @ 02,00 SAY "Clase de Impresora" OF ::oDlg RIGHT PIXEL SIZE 60,10
   @ 02,62 COMBOBOX ::nLis ITEMS { "Matriz Punto","Laser" } ;
      SIZE 80,99 OF ::oDlg PIXEL
   @ 14,62 CHECKBOX ::lPrev PROMPT "Vista Previa" OF ::oDlg ;
      SIZE 60,10 PIXEL
   @ 26,00 SAY "Escoja la Fuente" OF ::oDlg RIGHT PIXEL SIZE 60,10
   @ 26,62 COMBOBOX ::cFont ITEMS ::aFont SIZE 80,99 OF ::oDlg PIXEL;
      WHEN ::nLis == 2
   @ 38, 00 SAY "Altura en mm"    OF ::oDlg RIGHT PIXEL SIZE 60,10
   @ 38, 62 GET ::nAlto           OF ::oDlg PICTURE "99,999.99" SIZE 42,10 PIXEL;
      WHEN aOK[2]
   @ 50, 00 SAY "Ancho  en mm"    OF ::oDlg RIGHT PIXEL SIZE 60,10
   @ 50, 62 GET ::nAncho          OF ::oDlg PICTURE "99,999.99" SIZE 42,10 PIXEL;
      WHEN aOK[2]
 //@ 38,106 GET oApl:nX           OF ::oDlg PICTURE "99.9"      SIZE 20,10 PIXEL
 //@ 50,106 GET oApl:nY           OF ::oDlg PICTURE "99.9"      SIZE 20,10 PIXEL

   @ 63,70 BUTTON hDC PROMPT "Imprimir" SIZE 44,12 OF ::oDlg;
      ACTION ( aOK[1] := .t., ::oDlg:End() ) PIXEL
ACTIVATE DIALOG ::oDlg CENTER
RETURN aOK[1]

//------------------------------------//
METHOD ListoWIN( aDT ) CLASS TListFac
   LOCAL nL, nTL := LEN( aDT )
 ::Init( "Factura"+STR(::nFac), .t. ,, !::lPrev ,,, ::lPrev, 5 )
 ::nPage := 0
 ASIZE( ::aFnt,9 )

 DEFINE FONT ::aFnt[7] NAME ::cFont SIZE 0,-16 BOLD OF ::oPrn
 DEFINE FONT ::aFnt[8] NAME ::cFont SIZE 0,-6       OF ::oPrn
 DEFINE FONT ::aFnt[9] NAME ::cFont SIZE 0,-7       OF ::oPrn

 PAGE
    FOR nL := 1 TO nTL
       If !EMPTY( aDT[nL,1] )
          ::aF[17] := aDT[nL,06] + aDT[nL,07]    // DESMON + PRECIOVEN
          ::Cabecera( .t.,0.5 )
          UTILPRN ::oUtil Self:nLinea, 1.2 SAY aDT[nL,1]
          UTILPRN ::oUtil Self:nLinea, 3.0 SAY aDT[nL,2]
          UTILPRN ::oUtil Self:nLinea,13.0 SAY TRANSFORM( aDT[nL,4],"9,999.99" )  RIGHT
          UTILPRN ::oUtil Self:nLinea,16.0 SAY TRANSFORM( aDT[nL,3],"9,999,999" ) RIGHT
          UTILPRN ::oUtil Self:nLinea,19.4 SAY TRANSFORM(  ::aF[17],"9,999,999" ) RIGHT
             ::aF[16] ++
          If ::aF[16] == 10 .AND. nL < nTL
             ::PieFactu( "Pasan ....",.f. )
             ::nLinea += 3.0
          EndIf
       ElseIf nL == 1
          ::Cabecera( .t. )
          UTILPRN ::oUtil 7.5, 4.0 SAY "ANULADA" FONT ::aFnt[4]
       EndIf
    NEXT nL
    ::nLinea += 0.5
    ::aF[17] := oApl:oFac:TOTALFAC - oApl:oFac:TOTALIVA + oApl:oFac:TOTALDES
    UTILPRN ::oUtil 11.5, 1.0 SAY "Subtotal $" + TRANSFORM( ::aF[17],"9,999,999" )
    If oApl:oFac:TOTALDES > 0
       UTILPRN ::oUtil 11.5, 6.5 SAY "Dsto." + TRANSFORM(oApl:oFac:TOTALDES,"9,999,999")
    EndIf
    If oApl:oFac:FECHOY >= CTOD("01.01.2013")
       UTILPRN ::oUtil 11.5,10.5 SAY "ImpoConsumo" + TRANSFORM(oApl:oFac:TOTALIVA,"9,999,999")
    Else
       UTILPRN ::oUtil 11.5,10.5 SAY "I.V.A." + TRANSFORM(oApl:oFac:TOTALIVA,"9,999,999")
    EndIf
    ::PieFactu( "Total $"+ TRANSFORM( oApl:oFac:TOTALFAC,"999,999,999" ),.t. )
 ENDPAGE
IMPRIME END .F.

RETURN NIL
/*
//------------------------------------//
METHOD ListoRem( oRpt,aDT ) CLASS TListFac
   LOCAL aRem, nL, nNeto
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,,.f.,,,33,33 )
oRpt:nPage := 1
oRpt:SetFont( oRpt:CPINormal,82,1 )
oRpt:Say( 01,00,::aF[4]+ SPACE(14) + ::aF[08] )
oRpt:Say( 02,00,::aF[5]+ SPACE(15) + ::aF[09] )
oRpt:Say( 03,00,::aF[6]+ SPACE(15) + ::aF[10] )
oRpt:Say( 04,00,::aF[7]+ SPACE(15) + ::aF[11] )
oRpt:SetFont( oRpt:CPICompress,144,1 )
oRpt:Say( 05,01,"  Cliente : " + oApl:oNit:NOMBRE + "  Nit. o C.C." )
oRpt:Say( 05,87,oRpt:CPINormal + ::aF[1] + "No."  )
oRpt:Say( 06,01,"Pedido Por: " + ::oCaj:CLIENTE )
oRpt:Say( 06,45,::aF[12] )
oRpt:Say( 06,89,oRpt:CPINormal + STRZERO( ::nFac,8 ) )
oRpt:Say( 07,01,"Direccion : " + oApl:oNit:DIRECCION + ;
                 "  Telef. " + oApl:oNit:TELEFONO )
oRpt:Say( 07,81,oRpt:CPINormal+ "FECHA " + ::aF[1] + NtChr( ::oCaj:FECHOY,"2" ) )
oRpt:Say( 08,13,::oCaj:DIRECCI + SPACE(09) + ::oCaj:TELEFON )
oRpt:Say( 08,81,oRpt:CPINormal+ "FECHA    COBRO " + NtChr( ::oCaj:FECHACOB,"2" ) )
oRpt:Say( 09,01,"   Ciudad : " + oApl:oNit:CIUDAD )
oRpt:Say( 09,45,"Enviado A " + ::oCaj:ENVIADO )
oRpt:Say( 09,81,oRpt:CPINormal+ "FECHA  ENTREGA " + NtChr( ::oCaj:FECHAENT,"2" ) )
oRpt:Say( 10,01,"Tomado Por: " + ::oCaj:TOMADOP )
oRpt:Say( 10,81,oRpt:CPINormal+ " HORA  ENTREGA " + ::oCaj:HORA )
oRpt:SetFont( oRpt:CPINormal,82,2 )
oRpt:Say( 11,01,"Codigo  Descripcion del Articulo        Cantidad  " + ;
             "Vr/Unitario  Valor Total" )
oRpt:Say( 12,01,REPLICATE( "_",74 ) )
oRpt:nL := 13
FOR nL := 1 TO LEN( aDT )
   oRpt:Say( oRpt:nL,02,aDT[nL,01] )
   oRpt:Say( oRpt:nL,09,aDT[nL,02],34 )
   oRpt:Say( oRpt:nL,42,TRANSFORM(aDT[nL,04],"9,999.9") )
   If ::lPrecio
      nNeto := aDT[nL,06] + aDT[nL,07]    // DESMON + PRECIOVEN
//      oApl:oInv:Seek( {"codigo",aDT[nL,01]} )
//      oRpt:Say( oRpt:nL,52,TransForm(oApl:oInv:PPUBLI,"9,999,999") )
      oRpt:Say( oRpt:nL,52,TRANSFORM(aDT[nL,03],"9,999,999") )
      oRpt:Say( oRpt:nL,65,TRANSFORM( nNeto     ,"9,999,999") )
   EndIf
   oRpt:nL ++
NEXT nL
If oRpt:nL <= (27 - aRem[7]) .AND. aRem[7] > 0
   oRpt:Say( oRpt:nL,06,">> Notas Pedido <<" )
   oRpt:SetFont( oRpt:CPICompress,144,1 )
   FOR nL := 1 TO aRem[7]
      oRpt:Say(++oRpt:nL,01,MEMOLINE( ::oCaj:NOTA,78,nL ) )
   NEXT nL
   oRpt:SetFont( oRpt:CPINormal,82,2 )
EndIf
If ::lPrecio
   nNeto := ::oCaj:TOTALFAC - ::oCaj:TOTALIVA + ::oCaj:TOTALDES
   oRpt:Say( 27,01,"Subtotal $"+ TRANSFORM(nNeto,"9,999,999") )
   If ::oCaj:TOTALDES > 0
      oRpt:Say( 27,22,"Dsto."+ TRANSFORM(::oCaj:TOTALDES,"9,999,999") )
   EndIf
    If ::oCaj:FECHOY >= CTOD("01.01.2013")
       oRpt:Say( 27,38,"ImpoConsumo" + TRANSFORM(::oCaj:TOTALIVA,"9,999,999") )
    Else
       oRpt:Say( 27,38,"I.V.A." + TRANSFORM(::oCaj:TOTALIVA,"9,999,999") )
    EndIf
   oRpt:Say( 27,60,"Total $"+ TRANSFORM(::oCaj:TOTALFAC,"9,999,999") )
   oRpt:Say( 28,10,"PAGUE A LA FECHA Y NO PIERDA SU CREDITO          "+;
                    REPLICATE( "=",19 ) )
EndIf
oRpt:SetFont( oRpt:CPICompress,144,1 )
oRpt:Say( 29,01,"DESPUES DEL VENCIMIENTO SE COBRARA EL 3.5% DE MORA POR MES "+;
            "O FRACCION. ESTA REMISION SE ASIMILA EN TODOS SUS EFECTOS "      +;
            "LEGALES A LA LETRA" )
oRpt:Say( 30,01,"DE CAMBIO ( CODIGO DE COMERCIO ART.774 ). FAVOR GIRAR CHEQUE "+;
            "CRUZADO A " + ::aF[3] + "  DEVOLVERSE FIRMADA Y SELLADA." )
oRpt:NewPage()
oRpt:End()
RETURN NIL
*/
//------------------------------------//
METHOD Cabecera( lSep,nSpace,nSuma ) CLASS TListFac

If lSep .AND. !::lTit
   ::lTit := ::Separator( nSpace )
EndIf
If ::lTit
// Para imprimir una imagen en el formato actual de papel ,
//simplemente le decimos la imagen que es y la clausula PAGE y yasta!
//   UTILPRN ::oUtil 0.5,1 IMAGE oApl:cIco+"logotipo.jpg" JPG PAGE
// Podemos usar tambien la clausula JPG para poner Bitmaps
   If FILE( oApl:cIco+"logo.jpg" )
      UTILPRN ::oUtil 0.2,1 IMAGE oApl:cIco+"logo.jpg" SIZE oApl:nX,oApl:nY JPG
   Else
      UTILPRN ::oUtil 0.8, 0.5 SAY ::aF[4]   FONT ::aFnt[7]
   EndIf
   ::nPage ++
   UTILPRN ::oUtil SELECT ::aFnt[2]
   UTILPRN ::oUtil 0.8,11.8 SAY ::aF[08]
   UTILPRN ::oUtil 1.3, 0.5 SAY ::aF[05]
   UTILPRN ::oUtil 1.3,11.8 SAY ::aF[09]
   UTILPRN ::oUtil 1.8, 0.5 SAY ::aF[06]
   UTILPRN ::oUtil 1.8,11.8 SAY ::aF[10]
   UTILPRN ::oUtil 2.3, 0.5 SAY ::aF[07]
   UTILPRN ::oUtil 2.3,11.8 SAY ::aF[11]

   UTILPRN ::oUtil SELECT ::aFnt[5]
   UTILPRN ::oUtil 2.8, 0.5 SAY "Cliente   : " + oApl:oNit:NOMBRE
   UTILPRN ::oUtil 2.8, 8.6 SAY "Nit. o C.C."
   UTILPRN ::oUtil 2.8,13.4 SAY ::aF[1]                         FONT ::aFnt[2]
   UTILPRN ::oUtil 3.3, 0.5 SAY "Pedido Por: " + oApl:oFac:CLIENTE
   UTILPRN ::oUtil 3.3, 8.6 SAY ::aF[12]
   UTILPRN ::oUtil 3.3,14.1 SAY "No. " + STRZERO(::nFac,8)      FONT ::aFnt[2]
   UTILPRN ::oUtil 3.8, 0.5 SAY "Direccion : " + oApl:oNit:DIRECCION
   UTILPRN ::oUtil 3.8, 8.6 SAY "Telefono "    + oApl:oNit:TELEFONO
   UTILPRN ::oUtil 4.3, 2.7 SAY oApl:oFac:DIRECC
   UTILPRN ::oUtil 4.3, 8.6 SAY oApl:oFac:TELEFONO
   UTILPRN ::oUtil 4.3,13.4 SAY ::aF[2] + ::aF[13]              FONT ::aFnt[2]
   UTILPRN ::oUtil 4.8, 0.5 SAY "   Ciudad : " + oApl:oNit:CIUDAD
   UTILPRN ::oUtil 4.8, 7.1 SAY "Enviado A: " + oApl:oFac:ENVIADO_A
   UTILPRN ::oUtil 4.8,13.4 SAY "FECHA VENCIMIENTO " + ::aF[14] FONT ::aFnt[2]

   UTILPRN ::oUtil SELECT ::aFnt[2]
   UTILPRN ::oUtil 5.3,15.8 SAY "Pagina" + STR( ::nPage,3 ) + " DE" + STR( ::aF[15],3 )
   UTILPRN ::oUtil 5.8, 0.5 SAY "Codigo      Descripcion del Articulo"
   UTILPRN ::oUtil 5.8,13.0 SAY "Cantidad"    RIGHT
   UTILPRN ::oUtil 5.8,16.0 SAY "Vr/Unitario" RIGHT
   UTILPRN ::oUtil 5.8,19.4 SAY "Valor Total" RIGHT

   UTILPRN ::oUtil LINEA 6.2, 0.5 TO  6.2 ,19.4
   ::aF[16] := 0
   ::lTit   := .F.
   ::nLinea := 6.5
EndIf
RETURN NIL

//------------------------------------//
METHOD PieFactu( cText,lFin,oRpt ) CLASS TListFac
   LOCAL aP
If lFin
   ::aF[17] := If( ::nLis == 1, oRpt:nL, ::nLinea )
   ::Notas( {24,11}[::nLis],oRpt )
EndIf
aP := { "PAGUE A LA FECHA Y NO PIERDA SU CREDITO          "               ,;
        "FAVOR GIRAR CHEQUE CRUZADO A ", "  DEVOLVERSE FIRMADA Y SELLADA.",;
        "DESPUES DEL VENCIMIENTO SE COBRARA EL 3.5% DE MORA POR MES "     +;
        "O FRACCION. ESTA FACTURA SE ASIMILA EN TODOS SUS EFECTOS LEGALES",;
        "A LA LETRA DE CAMBIO (CODIGO DE COMERCIO ART.774)." }
If ::nLis == 1
   oRpt:Say( 25,60,cText )
   oRpt:Say( 26,11,aP[1] + REPLICATE( "=",19 ) )
   oRpt:SetFont( oRpt:CPICompress,144,1 )
   //27,01 Say "NO SOMOS RESPONSABLES DE I.V.A. REGIMEN COMUN. FAVOR GIRAR " + ;
   oRpt:Say( 27,01,aP[2] + ::aF[03] + aP[3] )
   oRpt:Say( 28,01,If( oApl:Tipo == "U", oApl:oEmp:DIAN, "" ) )
   oRpt:Say( 29,01,aP[4] )
   oRpt:Say( 30,01,aP[5] )
Else
   UTILPRN ::oUtil 11.5,15.4 SAY cText
 //UTILPRN ::oUtil 12.0, 3.5 SAY aP[1]
   UTILPRN ::oUtil SELECT ::aFnt[5]
   UTILPRN ::oUtil 12.0, 0.6 SAY aP[2] + ::aF[03] + aP[3]
   UTILPRN ::oUtil 12.0,19.4 SAY REPLICATE( "=",19 ) RIGHT
   UTILPRN ::oUtil 12.5, 0.6 SAY If( oApl:Tipo == "U", oApl:oEmp:DIAN, "" )
   UTILPRN ::oUtil 12.9, 0.6 SAY aP[4]
   UTILPRN ::oUtil 13.3, 0.6 SAY aP[5]
   UTILPRN ::oUtil SELECT ::aFnt[2]
   ::nLinea := ::nEndLine
EndIf

RETURN NIL

//------------------------------------//
METHOD Notas( nLin,oRpt ) CLASS TListFac
   LOCAL nK, nTl := MLCOUNT( TRIM(oApl:oEmp:NOTA),78 )
If ::aF[17] <= (nLin - nTl) .AND. nTl > 0
   If ::nLis == 1
      oRpt:Say( oRpt:nL,01,oRpt:CPIBold + PADC( ">>> Nota Factura <<<",78,"=" ) )
      FOR nK := 1 TO nTl
         oRpt:nL++
         oRpt:Say( oRpt:nL,01,oRpt:CPIBold + MEMOLINE( oApl:oEmp:NOTA,78,nK ) )
      NEXT nK
   Else
      UTILPRN ::oUtil Self:nLinea, 1.0 SAY PADC( ">>> Nota Factura <<<",78,"=" ) FONT ::aFnt[2]
      ::nLinea += .5
      ::MEMO( 1.5,ALLTRIM( oApl:oEmp:NOTA ),180,.26,::aFnt[5] )
   EndIf
EndIf
RETURN NIL