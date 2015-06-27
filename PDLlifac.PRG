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
                           "PICADAS  CALIENTES -  POSTRES  FRIOS",;
                           "","","","","","","","","","",0,0,0,"9,999,999" }
 DATA lPrev   INIT .t.
 DATA lTit    INIT .t.
 DATA nLis    INIT 1
 DATA cNota, lPrecio, nFac

 METHOD NEW( nFac,aDT,oDb ) Constructor
 METHOD Dialog( cTit )
 METHOD LaserFac( aDT )
 METHOD ListoRem( oRpt,aDT )
 METHOD Cabecera( lSep,nSpace,nSuma )
 METHOD PieFactu( lFin,cMsg,oRpt )
 METHOD Notas( nLin,oRpt )
ENDCLASS

//------------------------------------//
METHOD NEW( nFac,aDT,oDb ) CLASS TListFac
   LOCAL nL, oRpt
   ::nFac := nFac
If oApl:Tipo # "U"
   ::aF[1] := "NOTA  DE  PEDIDO"
   ::aF[2] := "FECHA DEL PEDIDO  "
   ::aF[3] := "ELIAS HANDAL."
   ::aF[4] := SPACE(29)
   ::aF[5] := ::aF[6] := ::aF[7] := SPACE(28)
EndIf
If oApl:oNit:CODIGO > 0
   ::aF[13] := FormatoNit( oApl:oNit:CODIGO,oApl:oNit:DIGITO )
ElseIf oDb == NIL
   ::aF[13] := TRANSFORM( oApl:oFac:CEDULA,"9,999,999,999" )
EndIf
   nL       := { 12,10 }[::nLis]
   ::aF[22] := LEN( aDT )
   ::aF[22] := INT( ::aF[22]/nL ) + If( ::aF[22] % nL > 0, 1, 0 )
::aEnc := { "I.V.A.",oApl:oFac:TOTALDES,oApl:oFac:TOTALIVA,oApl:oFac:TOTALFAC ,;
            "PAGUE A LA FECHA Y NO PIERDA SU CREDITO          "               ,;
            "FAVOR GIRAR CHEQUE CRUZADO A ", "  DEVOLVERSE FIRMADA Y SELLADA.",;
            "DESPUES DEL VENCIMIENTO SE COBRARA EL 3.5% DE MORA POR MES "     +;
            "O FRACCION. ESTA FACTURA SE ASIMILA EN TODOS SUS EFECTOS LEGALES",;
            "A LA LETRA DE CAMBIO (CODIGO DE COMERCIO ART.774).",.t. }
   ::aF[12] := CTOD("01.01.2013")
If (oDb # NIL .AND. oDb:FECHOY >= ::aF[12]) .OR.;
   oApl:oFac:FECHOY >= ::aF[12]
   ::aEnc[1] := "ImpoConsumo"
EndIf
If oDb # NIL
   ::aF[01] := If( oDb:TIPO_P == "P", "  PEDIDO ", "REMISION " )
   ::aF[02] := "FECHA " + PADL( ::aF[01],9," " ) + ": "
   ::aF[12] := oDb:CLIENTE
   ::aF[14] := NtChr(oDb:FECHOY,"2")
   ::aF[15] := oDb:DIRECCI
   ::aF[16] := oDb:TELEFON
   ::aF[17] := NtChr(oDb:FECHACOB,"2")
   ::aF[18] := oDb:ENVIADO
   ::aF[19] := NtChr(oDb:FECHAENT,"2")
   ::aF[20] := oDb:TOMADOP
   ::aF[21] := oDb:HORA

   ::aEnc[02] := oDb:TOTALDES
   ::aEnc[03] := oDb:TOTALIVA
   ::aEnc[04] := oDb:TOTALFAC
   ::aEnc[08] := STRTRAN( ::aEnc[08],"FACTURA","REMISION" )
   ::aEnc[10] := .f.
   ::cNota    := TRIM( oDb:NOTA )
   ::lPrecio  := MsgNoYes( "Remision Con Precio ?",">>> LISTAR <<<" )
   If ::nLis == 2
      ::aF[3] := STRTRAN( ::aF[3],"\A","ÑA" )
      ::aF[4] := STRTRAN( ::aF[4],"\A","ÑA" )
      ::LaserFac( aDT )
   Else
      ::ListoRem( oRpt,aDT )
   EndIf
   RETURN NIL
EndIf
//Facturas
   ::aF[12] := oApl:oFac:CLIENTE
   ::aF[14] := NtChr(oApl:oFac:FECHOY,"2")
   ::aF[17] := NtChr(oApl:oFac:FECHAVEN,"2")
   ::aF[15] := oApl:oFac:DIRECC
   ::aF[16] := oApl:oFac:TELEFONO
   ::aF[18] := oApl:oFac:ENVIADO_A
   ::cNota  := TRIM( oApl:oEmp:NOTA )
   ::lPrecio:= .t.
If ::nLis == 2
   ::aF[3] := STRTRAN( ::aF[3],"\A","ÑA" )
   ::aF[4] := STRTRAN( ::aF[4],"\A","ÑA" )
   ::LaserFac( aDT )
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
      oRpt:Say( 06,01,"Pedido Por: " + ::aF[12] )
      oRpt:Say( 06,45,::aF[13] )
      oRpt:Say( 06,85,oRpt:CPINormal+ "    No. " + STRZERO( nFac,8 ) )
      oRpt:Say( 07,01,"Direccion : " + oApl:oNit:DIRECCION + ;
                       "  Telefono " + oApl:oNit:TELEFONO )
      oRpt:Say( 08,13,::aF[15] + SPACE(13) + ::aF[16] )
      oRpt:Say( 08,81,oRpt:CPINormal+ ::aF[2] + ::aF[14] )
      oRpt:Say( 09,01,"   Ciudad : " + oApl:oNit:CIUDAD )
      oRpt:Say( 09,45,"Enviado A: " + ::aF[18] )
      oRpt:Say( 09,81,oRpt:CPINormal+ "FECHA VENCIMIENTO " + ::aF[17] )
      oRpt:SetFont( oRpt:CPINormal,82,2 )
      oRpt:Say( 10,60,"Pagina" + STR( oRpt:nPage,3 ) + " DE" + STR( ::aF[22],3 ) )
      oRpt:Say( 11,01,"Codigo  Descripcion del Articulo        Cantidad  " + ;
                   "Vr/Unitario  Valor Total" )
      oRpt:Say( 12,01,REPLICATE( "_",74 ) )
   EndIf
   ::aF[24] := aDT[nL,06] + aDT[nL,07]    // DESMON + PRECIOVEN
   oRpt:Say( oRpt:nL,02,aDT[nL,01] )
   oRpt:Say( oRpt:nL,09,aDT[nL,02],34 )
   oRpt:Say( oRpt:nL,41,TRANSFORM(aDT[nL,04],"9,999.99") )
   oRpt:Say( oRpt:nL,52,TRANSFORM(aDT[nL,03],::aF[25]) )
   oRpt:Say( oRpt:nL,65,TRANSFORM( ::aF[24] ,::aF[25]) )
/*
//                                                              9,999,999
Subtotal $9,999,999  Dsto.9,999,999  I.V.A.9,999,999  Total $999,999,999
Subtotal $9,999,999  Dsto.9,999,999  ImpoConsumo9,999,999  Total $999,999,999
   ::aF[23] := ROUND((aDT[nL,6] + aDT[nL,7]) / aDT[nL,4],0)
   ::aF[24] := aDT[nL,7] + aDT[nL,8]              //PRECIOVEN + MONTOIVA
   oRpt:Say( oRpt:nL, 02,aDt[nL,1] )
   oRpt:Say( oRpt:nL, 11,aDT[nL,2] )
   oRpt:Say( oRpt:nL, 62,TransForm(aDT[nL,4],"9,999.99" ) )
   oRpt:Say( oRpt:nL, 70,TransForm(::aF[23],::aF[25] ) )
   oRpt:Say( oRpt:nL, 85,TransForm(aDT[nL,6],"@Z 9,999,999") )
   oRpt:Say( oRpt:nL,100,TransForm(aDT[nL,7], ::aF[25]    ) )
   oRpt:Say( oRpt:nL,114,TransForm(aDT[nL,8],"9,999,999") )
   oRpt:Say( oRpt:nL,127,TransForm(::aF[24]   , ::aF[25]    ) )
*/
   oRpt:nL ++
   If oRpt:nL == 26 .AND. oRpt:nPage < ::aF[22]
    //::PieFactu( .f.,"Pasan ....",oRpt )
      oRpt:NewPage()
      oRpt:nL :=  0
   EndIf
NEXT nL
/*
::aF[24] := oApl:oFac:TOTALFAC - oApl:oFac:TOTALIVA
oRpt:Say(++oRpt:nL, 70,"TOTALES =>" )
oRpt:Say(  oRpt:nL, 85,TransForm(oApl:oFac:TOTALDES,"@Z 9,999,999") )
oRpt:Say(  oRpt:nL,100,TransForm( ::aF[24]           ,  "99,999,999") )
oRpt:Say(  oRpt:nL,114,TransForm(oApl:oFac:TOTALIVA,   "9,999,999") )
oRpt:Say(  oRpt:nL,127,TransForm(oApl:oFac:TOTALFAC,aLC[4] ) )
*/
 ::PieFactu( .t.,,oRpt )
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
METHOD LaserFac( aDT ) CLASS TListFac
   LOCAL nL, nTL := LEN( aDT )
 ::Init( ::aF[1]+STR(::nFac), .t. ,, !::lPrev ,,, ::lPrev, 5 )
 ::nPage := 0
 ASIZE( ::aFnt,9 )

 DEFINE FONT ::aFnt[7] NAME ::cFont SIZE 0,-16 BOLD OF ::oPrn
 DEFINE FONT ::aFnt[8] NAME ::cFont SIZE 0,-6       OF ::oPrn
 DEFINE FONT ::aFnt[9] NAME ::cFont SIZE 0,-7       OF ::oPrn

 PAGE
    FOR nL := 1 TO nTL
       If !EMPTY( aDT[nL,1] )
          ::aF[24] := aDT[nL,06] + aDT[nL,07]    // DESMON + PRECIOVEN
          ::Cabecera( .t.,0.5 )
          UTILPRN ::oUtil Self:nLinea, 1.2 SAY aDT[nL,1]
          UTILPRN ::oUtil Self:nLinea, 3.0 SAY aDT[nL,2]
          UTILPRN ::oUtil Self:nLinea,13.0 SAY TRANSFORM( aDT[nL,4],"9,999.99" )  RIGHT
          If ::lPrecio
             UTILPRN ::oUtil Self:nLinea,16.0 SAY TRANSFORM( aDT[nL,3],::aF[25] ) RIGHT
             UTILPRN ::oUtil Self:nLinea,19.4 SAY TRANSFORM(  ::aF[24],::aF[25] ) RIGHT
          EndIf
             ::aF[23] ++
          If ::aF[23] == 10 .AND. nL < nTL
             ::PieFactu( .f.,"Pasan ...." )
             ::nLinea += 3.0
          EndIf
       ElseIf nL == 1
          ::Cabecera( .t. )
          UTILPRN ::oUtil 7.5, 4.0 SAY "ANULADA" FONT ::aFnt[4]
       EndIf
    NEXT nL
    ::nLinea += 0.5
    ::PieFactu( .t. )
 ENDPAGE
IMPRIME END .F.

RETURN NIL

//------------------------------------//
METHOD ListoRem( oRpt,aDT ) CLASS TListFac
   LOCAL nL
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,,::lPrev,,,33,33 )
oRpt:nL := 0
FOR nL := 1 TO LEN( aDT )
   If oRpt:nL ==  0
      oRpt:nL := 13
      oRpt:nPage ++
      oRpt:SetFont( oRpt:CPINormal,82,1 )
      oRpt:Say( 01,00,::aF[4]+ SPACE(14) + ::aF[08] )
      oRpt:Say( 02,00,::aF[5]+ SPACE(15) + ::aF[09] )
      oRpt:Say( 03,00,::aF[6]+ SPACE(15) + ::aF[10] )
      oRpt:Say( 04,00,::aF[7]+ SPACE(15) + ::aF[11] )
      oRpt:SetFont( oRpt:CPICompress,144,1 )
      oRpt:Say( 05,01,"  Cliente : " + oApl:oNit:NOMBRE + "  Nit. o C.C." )
      oRpt:Say( 05,87,oRpt:CPINormal + ::aF[01] + "No."  )
      oRpt:Say( 06,01,"Pedido Por: " + ::aF[12] )
      oRpt:Say( 06,45,::aF[13] )
      oRpt:Say( 06,89,oRpt:CPINormal + STRZERO( ::nFac,8 ) )
      oRpt:Say( 07,01,"Direccion : " + oApl:oNit:DIRECCION +;
                         "  Telef. " + oApl:oNit:TELEFONO )
      oRpt:Say( 07,81,oRpt:CPINormal + "FECHA " + ::aF[01] + ::aF[14] )
      oRpt:Say( 08,13,::aF[15] + SPACE(09) + ::aF[16] )
      oRpt:Say( 08,81,oRpt:CPINormal+ "FECHA    COBRO " + ::aF[17] )
      oRpt:Say( 09,01,"   Ciudad : " + oApl:oNit:CIUDAD )
      oRpt:Say( 09,45,"Enviado A " + ::aF[18] )
      oRpt:Say( 09,81,oRpt:CPINormal + "FECHA  ENTREGA " + ::aF[19] )
      oRpt:Say( 10,01,"Tomado Por: " + ::aF[20] )
      oRpt:Say( 10,81,oRpt:CPINormal + " HORA  ENTREGA " + ::aF[21] )
      oRpt:SetFont( oRpt:CPINormal,82,2 )
      oRpt:Say( 11,01,"Codigo  Descripcion del Articulo        Cantidad  " + ;
                   "Vr/Unitario  Valor Total" )
      oRpt:Say( 12,01,REPLICATE( "_",74 ) )
   EndIf
   oRpt:Say( oRpt:nL,02,aDT[nL,01] )
   oRpt:Say( oRpt:nL,09,aDT[nL,02],34 )
   oRpt:Say( oRpt:nL,42,TRANSFORM(aDT[nL,04],"9,999.9") )
   If ::lPrecio
      ::aF[24] := aDT[nL,06] + aDT[nL,07]    // DESMON + PRECIOVEN
      oRpt:Say( oRpt:nL,52,TRANSFORM(aDT[nL,03],::aF[25]) )
      oRpt:Say( oRpt:nL,65,TRANSFORM( ::aF[24] ,::aF[25]) )
   EndIf
   oRpt:nL ++
   If oRpt:nL == 26 .AND. oRpt:nPage < ::aF[22]
      oRpt:Say( 28,60,"Pagina" + STR( oRpt:nPage,3 ) + " DE" + STR( ::aF[22],3 ) )
    //::PieFactu( .f.,"Pasan ....",oRpt )
      oRpt:NewPage()
      oRpt:nL :=  0
   EndIf
NEXT nL
 ::PieFactu( .t.,,oRpt )
oRpt:NewPage()
oRpt:End()
RETURN NIL

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
   UTILPRN ::oUtil 3.3, 0.5 SAY "Pedido Por: " + ::aF[12]
   UTILPRN ::oUtil 3.3, 8.6 SAY ::aF[13]
   UTILPRN ::oUtil 3.3,14.1 SAY "No. " + STRZERO(::nFac,8)      FONT ::aFnt[2]
   UTILPRN ::oUtil 3.8, 0.5 SAY "Direccion : " + oApl:oNit:DIRECCION
   UTILPRN ::oUtil 3.8, 8.6 SAY "Telefono "    + oApl:oNit:TELEFONO
   UTILPRN ::oUtil 4.3, 2.7 SAY ::aF[15]
   UTILPRN ::oUtil 4.3, 8.6 SAY ::aF[16]

   UTILPRN ::oUtil 4.8, 0.5 SAY "   Ciudad : " + oApl:oNit:CIUDAD
   UTILPRN ::oUtil 4.8, 7.1 SAY "Enviado A: " + ::aF[18]
   If ::aEnc[10]
      UTILPRN ::oUtil 4.3,13.4 SAY ::aF[2] + ::aF[14]              FONT ::aFnt[2]
      UTILPRN ::oUtil 4.8,13.4 SAY "FECHA VENCIMIENTO " + ::aF[17] FONT ::aFnt[2]
      UTILPRN ::oUtil 5.3,15.8 SAY "Pagina" + STR( ::nPage,3 ) + " DE" + STR( ::aF[22],3 )
   Else
      UTILPRN ::oUtil 3.8,13.4 SAY ::aF[2] + ::aF[14]              FONT ::aFnt[2]
      UTILPRN ::oUtil 4.3,13.4 SAY "FECHA  DE  COBRO  " + ::aF[17] FONT ::aFnt[2]
      UTILPRN ::oUtil 4.8,13.4 SAY "FECHA DE ENTREGA  " + ::aF[19] FONT ::aFnt[2]
      UTILPRN ::oUtil 5.3, 0.5 SAY "Tomado Por: " + ::aF[20]
      UTILPRN ::oUtil 5.3,13.4 SAY "HORA  DE ENTREGA  " + ::aF[21] FONT ::aFnt[2]
   EndIf
   UTILPRN ::oUtil SELECT ::aFnt[2]
   UTILPRN ::oUtil 5.8, 0.5 SAY "Codigo      Descripcion del Articulo"
   UTILPRN ::oUtil 5.8,13.0 SAY "Cantidad"    RIGHT
   UTILPRN ::oUtil 5.8,16.0 SAY "Vr/Unitario" RIGHT
   UTILPRN ::oUtil 5.8,19.4 SAY "Valor Total" RIGHT

   UTILPRN ::oUtil LINEA 6.2, 0.5 TO  6.2 ,19.4
   ::aF[23] := 0
   ::lTit   := .F.
   ::nLinea := 6.5
EndIf
RETURN NIL

//------------------------------------//
METHOD PieFactu( lFin,cMsg,oRpt ) CLASS TListFac
If lFin
   ::aF[24] := If( ::nLis == 1, oRpt:nL, ::nLinea )
   ::Notas( {24,11}[::nLis],oRpt )
   ::aF[24] := ::aEnc[4] - ::aEnc[3] + ::aEnc[2]
   cMsg     := "Total $" + TRANSFORM( ::aEnc[4],"999,999,999" )
   lFin     := ::lPrecio
EndIf
If ::nLis == 1
   If lFin
         oRpt:Say( 25,01,"Subtotal $" + TRANSFORM(::aF[24],::aF[25]) )
      If ::aEnc[2] > 0
         oRpt:Say( 25,22,"Dsto." + TRANSFORM(::aEnc[2],::aF[25]) )
      EndIf
         oRpt:Say( 25,38,::aEnc[1] + TRANSFORM(::aEnc[3],::aF[25]) )
   EndIf
   oRpt:Say( 25,60,cMsg )
   oRpt:Say( 26,11,::aEnc[5] + REPLICATE( "=",19 ) )
   oRpt:SetFont( oRpt:CPICompress,144,1 )
   oRpt:Say( 27,01,::aEnc[6] + ::aF[03] + ::aEnc[7] )
   oRpt:Say( 28,01,If( ::aEnc[10] .AND. oApl:Tipo == "U", oApl:oEmp:DIAN, "" ) )
   oRpt:Say( 29,01,::aEnc[8] )
   oRpt:Say( 30,01,::aEnc[9] )
Else
   If lFin
      UTILPRN ::oUtil 11.5, 1.0 SAY "Subtotal $" + TRANSFORM( ::aF[24],::aF[25] )
      If ::aEnc[2] > 0
         UTILPRN ::oUtil 11.5, 6.5 SAY "Dsto." + TRANSFORM(::aEnc[2],::aF[25])
      EndIf
      UTILPRN ::oUtil 11.5,10.5 SAY ::aEnc[1]  + TRANSFORM(::aEnc[3],::aF[25])
   EndIf
   UTILPRN ::oUtil 11.5,15.4 SAY cMsg
 //UTILPRN ::oUtil 12.0, 3.5 SAY ::aEnc[5]
   UTILPRN ::oUtil SELECT ::aFnt[5]
   UTILPRN ::oUtil 12.0, 0.6 SAY ::aEnc[6] + ::aF[03] + ::aEnc[7]
   UTILPRN ::oUtil 12.0,19.4 SAY REPLICATE( "=",19 ) RIGHT
   UTILPRN ::oUtil 12.5, 0.6 SAY If( ::aEnc[10] .AND. oApl:Tipo == "U", oApl:oEmp:DIAN, "" )
   UTILPRN ::oUtil 12.9, 0.6 SAY ::aEnc[8]
   UTILPRN ::oUtil 13.3, 0.6 SAY ::aEnc[9]
   UTILPRN ::oUtil SELECT ::aFnt[2]
   ::nLinea := ::nEndLine
EndIf

RETURN NIL

//------------------------------------//
METHOD Notas( nLin,oRpt ) CLASS TListFac
   LOCAL cMsg, nK, nTl := MLCOUNT( ::cNota,78 )
If ::aF[24] <= (nLin - nTl) .AND. nTl > 0
   cMsg := ">>> Nota " + If( ::aEnc[10], "Factura <<<", "Pedido <<<" )
   If ::nLis == 1
      oRpt:Say( oRpt:nL,01,oRpt:CPIBold + PADC( cMsg,78,"=" ) )
      FOR nK := 1 TO nTl
         oRpt:nL++
         oRpt:Say( oRpt:nL,01,oRpt:CPIBold + MEMOLINE( ::cNota,78,nK ) )
      NEXT nK
   Else
      UTILPRN ::oUtil Self:nLinea, 1.0 SAY PADC( cMsg,78,"=" ) FONT ::aFnt[2]
      ::nLinea += .5
      ::MEMO( 1.5,ALLTRIM( ::cNota ),180,.26,::aFnt[5] )
   EndIf
EndIf
RETURN NIL