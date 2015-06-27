// Programa.: NOMPERSO.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Datos personales de un Empleado.
#include "Fivewin.ch"
#INCLUDE "Utilprn.CH"
#include "btnget.ch"
#DEFINE CLR_GREY 14671839

MEMVAR oApl

PROCEDURE Personal( nOpc )
   LOCAL aDP, oDlg, oEp, oP, oGet := ARRAY(6)
   DEFAULT nOpc := 1
 oP  := TPerso() ; oP:New()
 oEp := TEpl()   ; oEp:New()
 aDP := { { {|| oP:DatosPer( oDlg ) },"DATOS PERSONALES" }  ,;
          { {|| oP:Liquidar( oDlg ) },"Listar Liquidación" } }
DEFINE DIALOG oDlg TITLE aDP[nOpc,2] FROM 0, 0 TO 08,54
   @ 02, 00 SAY "Código Empleado"  OF oDlg RIGHT PIXEL SIZE 60,10
   @ 02, 62 BTNGET oGet[1] VAR oP:aLS[1] OF oDlg PICTURE "99999";
      ACTION EVAL({|| If(oEp:Mostrar(), (oP:aLS[1] := oEp:oDb:CODIGO,;
                         oGet[1]:Refresh() ), ) })              ;
      VALID( If( oP:NEW( 1 ), ( oDlg:Update(), .t. ), .f. ) )   ;
      SIZE 40,10 PIXEL RESOURCE "BUSCAR"
   @ 14, 62 SAY    oGet[2] VAR oApl:oEpl:NOMBRE OF oDlg PIXEL SIZE 130,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 26, 00 SAY "TIPO DE IMPRESORA" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 26, 62 COMBOBOX oGet[3] VAR oP:aLS[2] ITEMS { "Matriz","Laser" };
      SIZE 48,90 OF oDlg PIXEL
   @ 26,134 CHECKBOX oGet[4] VAR oP:aLS[3] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,10 PIXEL
   @ 40, 50 BUTTON oGet[5] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[5]:Disable(), EVAL( aDP[nOpc,1] ), oDlg:End() ) PIXEL
   @ 40,100 BUTTON oGet[6] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 46, 02 SAY "[NOMPERSO]" OF oDlg PIXEL SIZE 30,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
CLASS TPerso FROM TIMPRIME
 DATA aLS AS ARRAY INIT { 1,oApl:nTFor,.f. }
 METHOD NEW() Constructor
 METHOD DatosPer( oDlg )
 METHOD Liquidar( oDlg )
 METHOD Fechas( nL,dFecI,dFecF )
ENDCLASS

//------------------------------------//
METHOD NEW( xBus ) CLASS TPerso
 If xBus == NIL
    Empresa( .t. )
 Else
    xBus := oApl:oEpl:Seek( {"empresa",oApl:nEmpresa,"codigo",::aLS[1]} )
    If xBus
       oApl:oNit:Seek( {"codigo_nit",oApl:oEpl:CODIGO_NIT} )
    Else
       MsgStop( "Este Empleado no Existe ..",">>> OJO <<<" )
    EndIf
 EndIf
RETURN xBus

//------------------------------------//
METHOD DatosPer( oDlg ) CLASS TPerso

If ::aLS[2] == 1
   ::oPrn := TDosPrint()
   ::oPrn:New( oApl:cPuerto,oApl:cImpres,,::aLS[5] )
   ::oPrn:nPage := 1
   ::oPrn:SetFont( ::oPrn:CPINormal,82,2 )
//      ::oPrn:Say( 01,00,::oPrn:CPILarge + cEmp )
//      ::oPrn:Say( 03,20,cLib + STR( ::aLS[2],6 ) )
//      ::oPrn:NewPage()
   ::oPrn:End()
Else
   ::Init( ::oCen:NOMBRE, .f. ,, !::aLS[3] )
   PAGE
/*
  * Con la nueva clausula MSG podemos poner un texto , y automaticamente nos monta un caja
  * alrededor.
  * Podemos jugar con la anchura de la caja, el texto a poner, y la caja puede ser con sombras!
     UTILPRN oUtils ;
            MSG "Listado de Pendientes de Cobro" TEXTFONT oFont AT 1.25,6.2 TEXTCOLOR CLR_HBLUE ;
            BRUSH oBrush ;
            ROUND  1220,1120 ;
            SHADOW WIDTH 0.15 ;
            EXPANDBOX 0.1,1

  * Para poner una caja con shadows , simplemente no le pasamos el texto y ya esta
     UTILPRN oUtils ;
            MSG 5,5 TO 10,10 ;
            BRUSH oBrush ;
            SHADOW WIDTH .3 EXPANDBOX 0,0
     UTILPRN oUtils ;
            MSG "Jugando haber como quedaria Esto!" TEXTFONT oFontGrande AT 12,4 TEXTCOLOR CLR_YELLOW ;
            BRUSH oBrushImage PEN oPen;
            ROUND  50,50 ;
            SHADOW WIDTH 0.3 SHADOWBRUSH oBrush2 SHADOWPEN oPen2 ;
            EXPANDBOX 1,1
*/
      //UTILPRN ::oUtil  4.0,19.0 SAY aTL[03] RIGHT FONT ::aFnt[4]
      UTILPRN ::oUtil SELECT ::aFnt[2]
      UTILPRN ::oUtil  5.0, 3.0 SAY "Barranquilla, " + NtChr( DATE(),"2")
      UTILPRN ::oUtil  6.0, 3.0 SAY "Señores :"
      UTILPRN ::oUtil  6.7, 3.0 SAY "xxx"
      UTILPRN ::oUtil  7.2, 3.0 SAY "Ciudad"
      UTILPRN ::oUtil  9.2, 3.0 SAY "DATOS PERSONALES"
      UTILPRN ::oUtil 10.0, 3.0 SAY "NOMBRES"
      UTILPRN ::oUtil 10.5, 3.0 SAY "APELLIDOS"
      UTILPRN ::oUtil 11.0, 3.0 SAY "C.C."
      UTILPRN ::oUtil 11.0, 5.0 SAY FormatoNit( oApl:oNit:CODIGO,oApl:oNit:DIGITO )
      UTILPRN ::oUtil 11.5, 3.0 SAY "DIRECCION"
      UTILPRN ::oUtil 11.5, 5.0 SAY oApl:oNit:DIRECCION
      UTILPRN ::oUtil 12.0, 3.0 SAY "TELEFONO"
      UTILPRN ::oUtil 12.5, 3.0 SAY "CELULAR"
      UTILPRN ::oUtil 13.0, 3.0 SAY "FECHA NACIMIENTO"
      UTILPRN ::oUtil 13.0, 5.0 SAY NtChr(oApl:oFac:FECHADES,"2")
      UTILPRN ::oUtil 13.5, 3.0 SAY "COMPENSACION"
      UTILPRN ::oUtil 13.5, 5.0 SAY TRANSFORM( ::aD[1,3],"999,999,999.99" ) RIGHT
      UTILPRN ::oUtil 14.0, 3.0 SAY "FECHA VINCULACION"
      UTILPRN ::oUtil 14.0, 5.0 SAY NtChr(oApl:oFac:FECHADES,"2")
      UTILPRN ::oUtil 14.5, 3.0 SAY "ESTADO CIVIL"
      UTILPRN ::oUtil 15.0, 3.0 SAY "No. DE HIJOS"
      UTILPRN ::oUtil 16.0, 3.0 SAY "EDUCACION"

      UTILPRN ::oUtil 17.5, 3.0 SAY "OCUPACION/CARGO"
      UTILPRN ::oUtil 18.0, 3.0 SAY "RECOMIENDA"
      UTILPRN ::oUtil 18.0, 6.0 SAY REPLICATE( "_",20 )

// UTILPRN ::oUtil LINEA 3.5,1.0 TO 3.5,20.5 PEN ::oPen
// UTILPRN ::oUtil BOX nLinea+2,1 TO nLinea+3,5

      UTILPRN ::oUtil 18.5, 3.0 SAY "TELEFONO"
      UTILPRN ::oUtil 19.0, 3.0 SAY "PRESTA SERVICIO EN"
      UTILPRN ::oUtil 19.5, 3.0 SAY "E.P.S."
      UTILPRN ::oUtil 20.0, 3.0 SAY "FECHA AFILIACION"
      UTILPRN ::oUtil 20.5, 3.0 SAY "COTIZANTE P."
      UTILPRN ::oUtil 21.5, 3.0 SAY "PENSION"
      UTILPRN ::oUtil 21.5, 3.0 SAY "FECHA AFILIACION"
      UTILPRN ::oUtil 22.0, 3.0 SAY "CUENTA BANCARIA #"
      UTILPRN ::oUtil 22.5, 3.0 SAY "CERTIFICO :"
      UTILPRN ::oUtil 23.0, 3.1 SAY "Que los datos anteriores son ciertos y doy fe de su veracidad, lo cual"
      UTILPRN ::oUtil 23.5, 3.1 SAY "puedo aportar los documentos necesarios para la prueba de estos."

      UTILPRN ::oUtil 28.0, 3.0 SAY "FIRMA:" + REPLICATE( "_",20 )
      UTILPRN ::oUtil 30.0, 3.0 SAY "c.c. No.____________________DE____________________"
   ENDPAGE
   IMPRIME END .F.
EndIf
RETURN NIL

//------------------------------------//
METHOD Liquidar( oDlg ) CLASS TPerso
    LOCAL nV, nL := 18
   ::Init( ::oCen:NOMBRE, .f. ,, !::aLS[3] )
   PAGE
      UTILPRN ::oUtil SELECT ::aFnt[2]
      UTILPRN ::oUtil  5.0, 3.0 SAY oApl:oEpl:NOMBRE
      UTILPRN ::oUtil  6.0, 3.0 SAY "C.C. No. " + FormatoNit( oApl:oNit:CODIGO,oApl:oNit:DIGITO )
      UTILPRN ::oUtil  6.7, 3.0 SAY "COMPENSACION BASE"
      UTILPRN ::oUtil  7.2, 3.0 SAY "PROMEDIO"
      UTILPRN ::oUtil  7.7, 3.0 SAY "AUXILIO DE MOVILIZACION"
      UTILPRN ::oUtil  8.2, 3.0 SAY "TOTAL"
      ::Fechas(  9.0,, )
      UTILPRN ::oUtil 10.5, 3.0 SAY "TOTAL DIAS TRABAJADOS"

      UTILPRN ::oUtil 11.5, 5.0 SAY "COMPENSACION ANUAL"
      ::Fechas( 12.5,, )
      UTILPRN ::oUtil 14.5, 3.0 SAY "TOTAL DIAS"
      UTILPRN ::oUtil 15.0, 5.0 SAY "COMPENSACION ANUAL"
      UTILPRN ::oUtil 16.0, 3.0 SAY "INTERES COMPENSACION ANUAL"

      UTILPRN ::oUtil 17.0, 5.0 SAY "DESCANSO ANUAL"
      ::Fechas( 18.0,, )
      UTILPRN ::oUtil 19.5, 3.0 SAY "TOTAL DIAS"
      UTILPRN ::oUtil 20.5, 3.0 SAY "VALOR DESCANSO ANUAL"
      UTILPRN ::oUtil 21.0, 3.0 SAY "SUBTOTAL LIQ."
      UTILPRN ::oUtil 21.5, 3.0 SAY "TOTAL NETO LIQUIDADO"

      UTILPRN ::oUtil 13.5, 5.0 SAY TRANSFORM( ::aD[1,3],"999,999,999.99" ) RIGHT
      UTILPRN ::oUtil 14.0, 5.0 SAY NtChr(oApl:oFac:FECHADES,"2")
      UTILPRN ::oUtil 18.0, 6.0 SAY REPLICATE( "_",20 )

// UTILPRN ::oUtil LINEA 3.5,1.0 TO 3.5,20.5 PEN ::oPen

      UTILPRN ::oUtil 28.0, 3.0 SAY "RECIBI CONFORME :" + REPLICATE( "_",20 )
   ENDPAGE
   IMPRIME END .F.
RETURN NIL

//------------------------------------//
METHOD Fechas( nL,dFecI,dFecF ) CLASS TPerso
   LOCAL aFec := { 0,0,0,0 }
 aFec[1] :=  YEAR( dFecF ) -  YEAR( dFecI )
 aFec[2] := MONTH( dFecF ) - MONTH( dFecI )
 aFec[3] :=   DAY( dFecF ) -   DAY( dFecI )
 aFec[4] := (aFec[1] * 360) + (aFec[2] * 30) + aFec[3]
//If ::aLS[2] == 1
   UTILPRN ::oUtil nL, 3.0 SAY "FECHA RETIRO"
   UTILPRN ::oUtil nL,10.0 SAY TRANSFORM(  YEAR( dFecF ),"9999" ) RIGHT
   UTILPRN ::oUtil nL,12.0 SAY TRANSFORM( MONTH( dFecF ),"9999" ) RIGHT
   UTILPRN ::oUtil nL,14.0 SAY TRANSFORM(   DAY( dFecF ),"9999" ) RIGHT
   nL += .5
   UTILPRN ::oUtil nL, 3.0 SAY "FECHA INGRESO"
   UTILPRN ::oUtil nL,10.0 SAY TRANSFORM(  YEAR( dFecI ),"9999" ) RIGHT
   UTILPRN ::oUtil nL,12.0 SAY TRANSFORM( MONTH( dFecI ),"9999" ) RIGHT
   UTILPRN ::oUtil nL,14.0 SAY TRANSFORM(   DAY( dFecI ),"9999" ) RIGHT
   nL += .5
   UTILPRN ::oUtil nL, 3.0 SAY "TOTALES"
   UTILPRN ::oUtil nL,10.0 SAY TRANSFORM( aFec[1],"9999" ) RIGHT
   UTILPRN ::oUtil nL,12.0 SAY TRANSFORM( aFec[2],"9999" ) RIGHT
   UTILPRN ::oUtil nL,14.0 SAY TRANSFORM( aFec[3],"9999" ) RIGHT
   nL += .5
   UTILPRN ::oUtil nL,14.0 SAY TRANSFORM( aFec[4],"9999" ) RIGHT
RETURN aFec