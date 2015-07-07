// Programa.: NOMLINOV.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo volantes de Pago.
#include "FiveWin.ch"
#INCLUDE "Utilprn.CH"

MEMVAR oApl

PROCEDURE NomLiNov( nOpc,dFec )
   LOCAL oA, oDlg, oGet := ARRAY(7)
oA := TLinov() ; oA:NEW( nOpc )
If nOpc # NIL
   oGet := { {|| oA:DatosPer() }, {|| oA:Liquidar( dFec ) } }
   oA:Init( oApl:oEpl:NOMBRE, .f. ,, .f. )
     PAGE
        EVAL( oGet[nOpc] )
   RETURN
EndIf
DEFINE DIALOG oDlg TITLE "Listar Liquidacion de Novedades" FROM 0, 0 TO 09,50
   @ 02, 00 SAY "EN Mision" OF oDlg RIGHT PIXEL SIZE 40,10
   @ 02, 42 COMBOBOX oGet[1] VAR oA:aLS[1] ITEMS ArrayCol( oA:aCCos,1 );
     SIZE 150,99 OF oDlg PIXEL
   @ 14, 00 SAY "FECHA [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 14, 82 GET oGet[2] VAR oA:aLS[2] OF oDlg SIZE 40,10 PIXEL
   @ 28, 00 SAY "Totalizar por C.Costo" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 28, 82 CHECKBOX oGet[3] VAR oA:aLS[3] PROMPT " " OF oDlg SIZE 12,10 PIXEL
   @ 40, 00 SAY "CLASE DE LISTADO"    OF oDlg RIGHT PIXEL SIZE 80,10
   @ 40, 82 COMBOBOX oGet[4] VAR oA:aLS[4] ITEMS { "Matriz","Laser","Excel" };
      SIZE 48,90 OF oDlg PIXEL
   @ 40,130 CHECKBOX oGet[5] VAR oA:aLS[5] PROMPT "Vista Previa" OF oDlg;
     SIZE 60,12 PIXEL
   @ 54, 50 BUTTON oGet[6] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[6]:Disable(), oA:ArmarMOV( oDlg ), oDlg:End() ) PIXEL
   @ 54,100 BUTTON oGet[7] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 60, 02 SAY "[NOMLINOV]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
CLASS TLinov FROM TIMPRIME

 DATA aCCos, aEpl, aLS, aMV
 DATA hRes, nL,  nF

 METHOD NEW( nOpc ) Constructor
 METHOD ArmarMOV( oDlg )
 METHOD ListoDOS( oDlg )
 METHOD Cabecera( lSep,nSpace,nSuma )
 METHOD Lineas()
 METHOD CicloExcel()
 METHOD Novedad( oRpt )
 METHOD DatosPer()
 METHOD Liquidar( dFec )

ENDCLASS

//------------------------------------//
METHOD NEW( nOpc ) CLASS TLinov

If nOpc == NIL
   Empresa( .t.,1 )
   ::aLS   := { 1,oApl:oFie:FECHA_HAS,.f.,oApl:nTFor,.f.,"","X" }
   ::aMV   := ARRAY(2,13)
   ::aEnc  := { .t.,"LISTADO DE NOMINA","","",0,{} }
   AEVAL( ::aMV, {|x| AFILL( x,0 ) } )
EndIf
 ::aCCos := CCosto()
RETURN NIL

//------------------------------------//
METHOD ArmarMOV( oDlg ) CLASS TLinov
   LOCAL aV
oDlg:SetText( "POR FAVOR << ESPERE >>" )
aV := "SELECT e.codigo, n.codigo, n.nombre, e.sueldoact, e.estadolab, e.cencos "+;
      "FROM nomemple e, cadclien n "                    +;
      "WHERE e.empresa = " + LTRIM(STR(oApl:nEmpresa))  +;
       " AND e.estadolab <> 'R'" + If( ::aLS[1] == 1, "",;
       " AND e.cencos = '" + ::aCCos[::aLS[1],2] + "'" )+;
       " AND e.codigo_nit = n.codigo_nit"               +;
       " ORDER BY e.cencos, e.codigo"
::hRes := If( MSQuery( oApl:oMySql:hConnect,aV )   ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes ) ; RETURN NIL
EndIf
::aEpl := MyReadRow( ::hRes )
AEVAL( ::aEpl,{|xV,nP| ::aEpl[nP] := MyClReadCol( ::hRes,nP ) } )
::aLS[6] := "SELECT d.clasepd, d.concepto, d.horas, d.valornoved,"+;
            " c.columna FROM nomnoved d, nomconce c "             +;
            "WHERE d.empresa = "  + LTRIM(STR(oApl:nEmpresa))+;
             " AND d.codigo   = [CODIGO]"                    +;
             " AND d.fechahas = " + xValToChar( ::aLS[2] )   +;
             " AND c.concepto = d.concepto"                  +;
             " ORDER BY d.clasepd, d.concepto"
 aV := Buscar( {"empresa",oApl:nEmpresa,"fechahas",::aLS[2]},;
                "nomfecha","fechades",8 )
 aV := If( EMPTY(aV), oApl:oFie:FECHA_DES, aV )
 ::aEnc[3]:= NtChr( aV,"3" ) + " hasta " + NtChr( ::aLS[2],"3" )
 ::aEnc[4]:= ::aCCos[::aLS[1],1]
If ::aLS[4] == 1
   ::ListoDOS( oDlg )
ElseIf ::aLS[4] == 3
   ::CicloExcel()
Else
   ::Init( ::aEnc[2], .f. ,, !::aLS[5] ,,,, 5 )
   ::oPrn:SetPage(14)     //Oficio 8 1/2 x 13 in
   ::SetLandScape()
     PAGE
       ::Lineas()
     ENDPAGE
   IMPRIME END .F.
EndIf
MSFreeResult( ::hRes )
RETURN NIL

//------------------------------------//
METHOD ListoDOS( oDlg ) CLASS TLinov
   LOCAL oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[2],::aEnc[3],::aEnc[4],;
         SPACE(63)+                   "S.BASICO/      SALUD/  PRESTAMOS/  DEVENGADO/",;
         SPACE(45)+ "SALARIO           A.TRANSP/    PENSION/  O.DESCTOS   DEDUCCION/",;
         "CEDULA        N O M B R E                    MENSUAL DI DIAS      OTROS   "+;
                               "    F.S.P.                   NETO  EPL" },::aLS[5],,2 )
//                                                     S.BASICO/      SALUD/  PRESTAMOS/  DEVENGADO/
//                                   SALARIO           A.TRANSP/    PENSION/  O.DESCTOS   DEDUCCION/
//CEDULA        NOMBRE               MENSUAL DI DIAS      OTROS       F.S.P.                   NETO
//9,999,999,999 1234567890123456 999,999,999 99 9999  99,999,999  99,999,999  99,999,999  99,999,999
While ::nL > 0
   ::Novedad( oRpt )
   If ::aLS[5] .OR. VALTYPE( ::aEpl[5] ) == "C"
      oRpt:Titulo( 120 )
      oRpt:Say( oRpt:nL, 00,TRANSFORM(::aEpl[2],"9,999,999,999") )
      oRpt:Say( oRpt:nL, 14,::aEpl[3],26 )
      oRpt:Say( oRpt:nL, 41,TRANSFORM(::aEpl[4],"999,999,999") )
      oRpt:Say( oRpt:nL, 53,TRANSFORM(::aMV[1,01],"99") )
      oRpt:Say( oRpt:nL, 56,TRANSFORM(::aMV[1,02],"9999") )
      oRpt:Say( oRpt:nL, 62,TRANSFORM(::aMV[1,03],"99,999,999") )
      oRpt:Say( oRpt:nL, 74,TRANSFORM(::aMV[1,07],"99,999,999") )
      oRpt:Say( oRpt:nL, 86,TRANSFORM(::aMV[1,10],"99,999,999") )
      oRpt:Say( oRpt:nL, 98,TRANSFORM(::aMV[1,06],"99,999,999") )
      oRpt:Say( oRpt:nL,109,::aEpl[5] )
      oRpt:nL ++
      oRpt:Say( oRpt:nL, 62,TRANSFORM(::aMV[1,04],"99,999,999") )
      oRpt:Say( oRpt:nL, 74,TRANSFORM(::aMV[1,08],"99,999,999") )
      oRpt:Say( oRpt:nL, 86,TRANSFORM(::aMV[1,11],"99,999,999") )
      oRpt:Say( oRpt:nL, 98,TRANSFORM(::aMV[1,12],"99,999,999") )
      oRpt:nL ++
      oRpt:Say( oRpt:nL, 62,TRANSFORM(::aMV[1,05],"99,999,999") )
      oRpt:Say( oRpt:nL, 74,TRANSFORM(::aMV[1,09],"99,999,999") )
      oRpt:Say( oRpt:nL, 98,TRANSFORM(::aMV[1,13],"99,999,999") )
      oRpt:nL ++
   EndIf
   AEVAL( ::aMV[1], {|nVal,nPos| ::aMV[2,nPos] += nVal, ::aMV[1,nPos] := 0 },3 )
   If (::nL --) > 1
      ::aEpl := MyReadRow( ::hRes )
      AEVAL( ::aEpl, {|xV,nP| ::aEpl[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aLS[7] # ::aEpl[6]
      If ::nL == 0 .OR. ::aLS[3]
         oRpt:Say(++oRpt:nL, 11,"Totales =====>" )
         oRpt:Say(  oRpt:nL, 62,TRANSFORM(::aMV[2,03],"99,999,999") )
         oRpt:Say(  oRpt:nL, 74,TRANSFORM(::aMV[2,07],"99,999,999") )
         oRpt:Say(  oRpt:nL, 86,TRANSFORM(::aMV[2,10],"99,999,999") )
         oRpt:Say(  oRpt:nL, 98,TRANSFORM(::aMV[2,06],"99,999,999") )
         oRpt:Say(++oRpt:nL, 62,TRANSFORM(::aMV[2,04],"99,999,999") )
         oRpt:Say(  oRpt:nL, 74,TRANSFORM(::aMV[2,08],"99,999,999") )
         oRpt:Say(  oRpt:nL, 86,TRANSFORM(::aMV[2,11],"99,999,999") )
         oRpt:Say(  oRpt:nL, 98,TRANSFORM(::aMV[2,12],"99,999,999") )
         oRpt:Say(++oRpt:nL, 62,TRANSFORM(::aMV[2,05],"99,999,999") )
         oRpt:Say(  oRpt:nL, 74,TRANSFORM(::aMV[2,09],"99,999,999") )
         oRpt:Say(  oRpt:nL, 98,TRANSFORM(::aMV[2,13],"99,999,999") )
         If LEN( ::aEnc[6] ) > 0
            oRpt:Separator( 2,LEN( ::aEnc[6] ) )
            oRpt:Say( oRpt:nL, 11,"Notas" )
            AEVAL( ::aEnc[6], {|x| oRpt:Say( oRpt:nL++,17,x ) } )
            ::aEnc[5] := 0
            ::aEnc[6] := {}
         EndIf
         oRpt:Separator( 2,5 )
         oRpt:Say(  oRpt:nL,12,"Elaborado Por:" + REPLICATE("_",15) +;
                              "  Aprobado Por:" + REPLICATE("_",15) )
         oRpt:Say(++oRpt:nL,26,oApl:cUser )
         oRpt:Say(++oRpt:nL,05,"Factura ( )" )
         oRpt:Say(++oRpt:nL,05,"C.E.    ( )" )
         oRpt:Say(++oRpt:nL,05,"Folder  ( )" )
         oRpt:NewPage()
         AEVAL( ::aMV, {|x| AFILL( x,0 ) } )
      EndIf
   EndIf
EndDo

/*
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[2],::aEnc[3],::aEnc[4],;
         SPACE(34)+"SALARIO            SUELDO AUXILIO                TOTAL ---APOR"+;
         "TES SOCIALES---                OTROS     TOTAL       NETO COD"           ,;
         "CEDULA        NOMBRE              MENSUAL DI DIAS    BASICO TRANSP.     "+;
         "OTROS  DEVENGADO   SALUD PENSION  F.S.P. PRESTAMOS   DESCTOS DEDUCCION  "+;
         "  A PAGAR EPL" },::aLS[5],,2 )
While ::nL > 0
   ::Novedad( oRpt )
   If ::aLS[5] .OR. VALTYPE( ::aEpl[5] ) == "C"
      oRpt:Titulo( 160 )
      oRpt:Say( oRpt:nL,00,TRANSFORM(::aEpl[2],"9,999,999,999") )
      oRpt:Say( oRpt:nL,14,::aEpl[3],16 )
      oRpt:Say( oRpt:nL, 31,TRANSFORM(::aEpl[4],"999,999,999") )
      oRpt:Say( oRpt:nL, 42,TRANSFORM(::aMV[1,01],"99") )
      oRpt:Say( oRpt:nL, 45,TRANSFORM(::aMV[1,02],"9999") )
      oRpt:Say( oRpt:nL, 50,TRANSFORM(::aMV[1,03], "9,999,999") )
      oRpt:Say( oRpt:nL, 60,TRANSFORM(::aMV[1,04],   "999,999") )
      oRpt:Say( oRpt:nL, 68,TRANSFORM(::aMV[1,05], "9,999,999") )
      oRpt:Say( oRpt:nL, 78,TRANSFORM(::aMV[1,06],"99,999,999") )
      oRpt:Say( oRpt:nL, 89,TRANSFORM(::aMV[1,07],   "999,999") )
      oRpt:Say( oRpt:nL, 97,TRANSFORM(::aMV[1,08],   "999,999") )
      oRpt:Say( oRpt:nL,105,TRANSFORM(::aMV[1,09],   "999,999") )
      oRpt:Say( oRpt:nL,113,TRANSFORM(::aMV[1,10], "9,999,999") )
      oRpt:Say( oRpt:nL,123,TRANSFORM(::aMV[1,11], "9,999,999") )
      oRpt:Say( oRpt:nL,133,TRANSFORM(::aMV[1,12], "9,999,999") )
      oRpt:Say( oRpt:nL,143,TRANSFORM(::aMV[1,13],"99,999,999") )
      oRpt:Say( oRpt:nL,154,::aEpl[5] )
      oRpt:nL ++
   EndIf
   AEval( ::aMV[1], {|nVal,nPos| ::aMV[2,nPos] += nVal, ::aMV[1,nPos] := 0 },3 )
   If (::nL --) > 1
      ::aEpl := MyReadRow( ::hRes )
      AEVAL( ::aEpl, {|xV,nP| ::aEpl[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aLS[7] # ::aEpl[6]
      If ::nL == 0 .OR. ::aLS[3]
         oRpt:nL ++
         oRpt:Say( oRpt:nL, 11,"Totales =====>" )
         oRpt:Say( oRpt:nL, 49,TRANSFORM(::aMV[2,03],"99,999,999") )
         oRpt:Say( oRpt:nL, 60,TRANSFORM(::aMV[2,04],   "999,999") )
         oRpt:Say( oRpt:nL, 67,TRANSFORM(::aMV[2,05],"99,999,999") )
         oRpt:Say( oRpt:nL, 78,TRANSFORM(::aMV[2,06],"99,999,999") )
         oRpt:Say( oRpt:nL, 89,TRANSFORM(::aMV[2,07],   "999,999") )
         oRpt:Say( oRpt:nL, 97,TRANSFORM(::aMV[2,08],   "999,999") )
         oRpt:Say( oRpt:nL,105,TRANSFORM(::aMV[2,09],   "999,999") )
         oRpt:Say( oRpt:nL,113,TRANSFORM(::aMV[2,10], "9,999,999") )
         oRpt:Say( oRpt:nL,123,TRANSFORM(::aMV[2,11], "9,999,999") )
         oRpt:Say( oRpt:nL,133,TRANSFORM(::aMV[2,12], "9,999,999") )
         oRpt:Say( oRpt:nL,143,TRANSFORM(::aMV[2,13],"99,999,999") )
         If LEN( ::aEnc[6] ) > 0
            oRpt:Separator( 2,LEN( ::aEnc[6] ) )
            oRpt:Say( oRpt:nL, 11,"Notas" )
            AEVAL( ::aEnc[6], {|x| oRpt:Say( oRpt:nL++,17,x ) } )
            ::aEnc[5] := 0
            ::aEnc[6] := {}
         EndIf
         oRpt:Say(++oRpt:nL,12,"Elaborado Por:" + REPLICATE("_",15) +;
                              "  Aprobado Por:" + REPLICATE("_",15) )
         oRpt:Say(++oRpt:nL,26,oApl:cUser )
         oRpt:Say(++oRpt:nL,05,"Factura ( )" )
         oRpt:Say(++oRpt:nL,05,"C.E.    ( )" )
         oRpt:Say(++oRpt:nL,05,"Folder  ( )" )
         oRpt:NewPage()
         AEVAL( ::aMV, {|x| AFILL( x,0 ) } )
      EndIf
   EndIf
EndDo
*/
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD Cabecera( lSep,nSpace,nSuma ) CLASS TLinov
If lSep .AND. !::aEnc[1]
   ::aEnc[1] := ::Separator( nSpace,nSuma )
EndIf
If ::aEnc[1]
   ::aEnc[1] := .F.
   UTILPRN ::oUtil 1.0, 4   SAY oApl:cEmpresa    FONT ::aFnt[4]
   UTILPRN ::oUtil 1.5, 0.5 SAY "FEC.PROC:"+DTOC( DATE() )
   UTILPRN ::oUtil 1.5, 8.2 SAY "NIT: " + oApl:oEmp:Nit
   UTILPRN ::oUtil 1.5,16.4 SAY "HORA: " + AmPm( TIME() )
   UTILPRN ::oUtil 2.0, 4.0 SAY ::aEnc[2]
   UTILPRN ::oUtil 2.0,16.5 SAY "PAGINA" + STR(::nPage,4 )
   UTILPRN ::oUtil 2.5, 4.5 SAY ::aEnc[3]
   UTILPRN ::oUtil 3.0, 3.5 SAY ::aEnc[4]

   UTILPRN ::oUtil 3.5, 8.5 SAY "SALARIO"   RIGHT
   UTILPRN ::oUtil 3.5,11.4 SAY "SUELDO"    RIGHT
   UTILPRN ::oUtil 3.5,12.9 SAY "AUXILIO"   RIGHT
   UTILPRN ::oUtil 3.5,16.9 SAY "TOTAL"     RIGHT
   UTILPRN ::oUtil 3.5,18.6 SAY "---APORTES SOCIALES---"
   UTILPRN ::oUtil 3.5,25.6 SAY "OTROS"     RIGHT
   UTILPRN ::oUtil 3.5,27.4 SAY "TOTAL"     RIGHT
   UTILPRN ::oUtil 3.5,29.2 SAY "NETO"      RIGHT

   UTILPRN ::oUtil 4.0, 2.0 SAY "CEDULA"
   UTILPRN ::oUtil 4.0, 3.5 SAY "NOMBRE"
   UTILPRN ::oUtil 4.0, 8.5 SAY "MENSUAL"   RIGHT
   UTILPRN ::oUtil 4.0, 8.8 SAY "DI DIAS"
   UTILPRN ::oUtil 4.0,11.4 SAY "BASICO"    RIGHT
   UTILPRN ::oUtil 4.0,13.2 SAY "TRANSP."   RIGHT
   UTILPRN ::oUtil 4.0,15.0 SAY "OTROS"     RIGHT
   UTILPRN ::oUtil 4.0,16.9 SAY "DEVENGADO" RIGHT
   UTILPRN ::oUtil 4.0,18.6 SAY "SALUD"     RIGHT
   UTILPRN ::oUtil 4.0,20.3 SAY "PENSION"   RIGHT
   UTILPRN ::oUtil 4.0,22.0 SAY "F.S.P."    RIGHT
   UTILPRN ::oUtil 4.0,23.8 SAY "PRESTAMO"  RIGHT
   UTILPRN ::oUtil 4.0,25.6 SAY "DESCTOS"   RIGHT
   UTILPRN ::oUtil 4.0,27.4 SAY "DEDUCCION" RIGHT
   UTILPRN ::oUtil 4.0,29.2 SAY "A PAGAR"   RIGHT
   UTILPRN ::oUtil LINEA 4.5,1.0 TO 4.5,29.2 PEN ::oPen
   ::nLinea := 4.5
EndIf
RETURN NIL

//------------------------------------//
METHOD Lineas() CLASS TLinov
   LOCAL nF
While ::nL > 0
   ::Novedad()
   If ::aLS[5] .OR. VALTYPE( ::aEpl[5] ) == "C"
      ::Cabecera( .t. )
      UTILPRN ::oUtil Self:nLinea,03.2 SAY TRANSFORM(::aEpl[2],"9,999,999,999") RIGHT
      UTILPRN ::oUtil Self:nLinea,03.5 SAY LEFT(::aEpl[3],18)
      UTILPRN ::oUtil Self:nLinea,08.5 SAY TRANSFORM(::aEpl[4],"999,999,999" )  RIGHT
      UTILPRN ::oUtil Self:nLinea,09.0 SAY TRANSFORM(::aMV[1,01],"99" )         RIGHT
      UTILPRN ::oUtil Self:nLinea,09.7 SAY TRANSFORM(::aMV[1,02],"9999" )       RIGHT
      UTILPRN ::oUtil Self:nLinea,11.4 SAY TRANSFORM(::aMV[1,03], "9,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,13.2 SAY TRANSFORM(::aMV[1,04],   "999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,15.0 SAY TRANSFORM(::aMV[1,05], "9,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,16.9 SAY TRANSFORM(::aMV[1,06],"99,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,18.6 SAY TRANSFORM(::aMV[1,07],   "999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,20.3 SAY TRANSFORM(::aMV[1,08],   "999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,22.0 SAY TRANSFORM(::aMV[1,09],   "999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,23.8 SAY TRANSFORM(::aMV[1,10], "9,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,25.6 SAY TRANSFORM(::aMV[1,11], "9,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,27.4 SAY TRANSFORM(::aMV[1,12], "9,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,29.2 SAY TRANSFORM(::aMV[1,13],"99,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,29.4 SAY ::aEpl[5]
   EndIf
   AEVAL( ::aMV[1], {|nVal,nPos| ::aMV[2,nPos] += nVal, ::aMV[1,nPos] := 0 },3 )
   If (::nL --) > 1
      ::aEpl := MyReadRow( ::hRes )
      AEVAL( ::aEpl, {|xV,nP| ::aEpl[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aLS[7] # ::aEpl[6]
      If ::nL == 0 .OR. ::aLS[3]
         ::Cabecera( .t. )
         UTILPRN ::oUtil Self:nLinea,07.3 SAY "TOTALES =====>"
         UTILPRN ::oUtil Self:nLinea,11.4 SAY TRANSFORM(::aMV[2,03],"99,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,13.2 SAY TRANSFORM(::aMV[2,04],   "999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,15.0 SAY TRANSFORM(::aMV[2,05],"99,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,16.9 SAY TRANSFORM(::aMV[2,06],"99,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,18.6 SAY TRANSFORM(::aMV[2,07],   "999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,20.3 SAY TRANSFORM(::aMV[2,08],   "999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,22.0 SAY TRANSFORM(::aMV[2,09],   "999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,23.8 SAY TRANSFORM(::aMV[2,10], "9,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,25.6 SAY TRANSFORM(::aMV[2,11], "9,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,27.4 SAY TRANSFORM(::aMV[2,12], "9,999,999" ) RIGHT
         UTILPRN ::oUtil Self:nLinea,29.2 SAY TRANSFORM(::aMV[2,13],"99,999,999" ) RIGHT
         If LEN( ::aEnc[6] ) > 0
            ::Cabecera( .t.,1,LEN( ::aEnc[6] )/2 )
            UTILPRN ::oUtil Self:nLinea,07.3 SAY "Notas"
            FOR nF := 1 TO LEN( ::aEnc[6] )
               UTILPRN ::oUtil Self:nLinea,08.2 SAY ::aEnc[6,nF]
               ::nLinea += .5
            NEXT nF
            ::aEnc[5] := 0
            ::aEnc[6] := {}
         EndIf
         ::nLinea := ::nEndLine + .5
         AEVAL( ::aMV, {|x| AFILL( x,0 ) } )
      EndIf
   EndIf
EndDo
RETURN .f.

//------------------------------------//
METHOD CicloExcel() CLASS TLinov
    LOCAL cQry := cFilePath( GetModuleFileName( GetInstance() )) + "Test1.xls"
    LOCAL oRpt := TExcelScript():New()
oRpt:Create( cQry )
oRpt:Font("Verdana")
oRpt:Size(10)
//oRpt:ColumnWidth( 2, 27.00 )
//oRpt:ColumnWidth( 4, 05.00 )
//oRpt:ColumnWidth( 5, 05.00 )
oRpt:Align(1)
oRpt:Visualizar(.F.)
::nF := 1
While ::nL > 0
   ::Novedad( oRpt )
   If ::aEnc[1]
      ::aEnc[1] := .F.
      oRpt:Say(  ::nF, 2 , oApl:cEmpresa )
      oRpt:Say(++::nF, 2 , "NIT: " + oApl:oEmp:Nit )
      oRpt:Say(++::nF, 2 , "LISTADO DE NOMINA" )
      oRpt:Say(++::nF, 2 , ::aEnc[3] )
      oRpt:Say(++::nF, 1 , ::aEnc[4] )

      oRpt:Say(++::nF, 3 , "SALARIO" )
      oRpt:Say(  ::nF, 6 , "SUELDO" )
      oRpt:Say(  ::nF, 7 , "AUXILIO" )
      oRpt:Say(  ::nF, 9 , "TOTAL" )
      oRpt:Say(  ::nF,10 , "---APORTES SOCIALES---" )
      oRpt:Say(  ::nF,14 , "OTROS" )
      oRpt:Say(  ::nF,15 , "TOTAL" )
      oRpt:Say(  ::nF,16 , "NETO" )

      oRpt:Say(++::nF, 1 , "CEDULA" )
      oRpt:Say(  ::nF, 2 , "NOMBRE" )
      oRpt:Say(  ::nF, 3 , "MENSUAL" )
      oRpt:Say(  ::nF, 4 , "DI" )
      oRpt:Say(  ::nF, 5 , "DIAS" )
      oRpt:Say(  ::nF, 6 , "BASICO" )
      oRpt:Say(  ::nF, 7 , "TRANSP." )
      oRpt:Say(  ::nF, 8 , "OTROS" )
      oRpt:Say(  ::nF, 9 , "DEVENGADO" )
      oRpt:Say(  ::nF,10 , "SALUD" )
      oRpt:Say(  ::nF,11 , "PENSION" )
      oRpt:Say(  ::nF,12 , "F.S.P." )
      oRpt:Say(  ::nF,13 , "PRESTAMOS" )
      oRpt:Say(  ::nF,14 , "DESCTOS" )
      oRpt:Say(  ::nF,15 , "DEDUCCION" )
      oRpt:Say(  ::nF,16 , "A PAGAR" )
      ::nF ++
   EndIf
   oRpt:Say( ::nF, 1, ::aEpl[2] )
   oRpt:Say( ::nF, 2, ::aEpl[3] )
   oRpt:Say( ::nF, 3, ::aEpl[4] )
   oRpt:Say( ::nF, 4, ::aMV[1,01] )
   oRpt:Say( ::nF, 5, ::aMV[1,02] )
   oRpt:Say( ::nF, 6, ::aMV[1,03] )
   oRpt:Say( ::nF, 7, ::aMV[1,04] )
   oRpt:Say( ::nF, 8, ::aMV[1,05] )
   oRpt:Say( ::nF, 9, ::aMV[1,06] )
   oRpt:Say( ::nF,10, ::aMV[1,07] )
   oRpt:Say( ::nF,11, ::aMV[1,08] )
   oRpt:Say( ::nF,12, ::aMV[1,09] )
   oRpt:Say( ::nF,13, ::aMV[1,10] )
   oRpt:Say( ::nF,14, ::aMV[1,11] )
   oRpt:Say( ::nF,15, ::aMV[1,12] )
   oRpt:Say( ::nF,16, ::aMV[1,13] )
   oRpt:Say( ::nF,17, ::aEpl[5] )
   ::nF ++
   AEVAL( ::aMV[1], {|nVal,nPos| ::aMV[2,nPos] += nVal, ::aMV[1,nPos] := 0 },3 )
   If (::nL --) > 1
      ::aEpl := MyReadRow( ::hRes )
      AEVAL( ::aEpl, {|xV,nP| ::aEpl[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aLS[7] # ::aEpl[6]
      If ::nL == 0 .OR. ::aLS[3]
         oRpt:Say(++::nF,2,"Totales =====>" )
         oRpt:Say( ::nF, 6, ::aMV[2,03] )
         oRpt:Say( ::nF, 7, ::aMV[2,04] )
         oRpt:Say( ::nF, 8, ::aMV[2,05] )
         oRpt:Say( ::nF, 9, ::aMV[2,06] )
         oRpt:Say( ::nF,10, ::aMV[2,07] )
         oRpt:Say( ::nF,11, ::aMV[2,08] )
         oRpt:Say( ::nF,12, ::aMV[2,09] )
         oRpt:Say( ::nF,13, ::aMV[2,10] )
         oRpt:Say( ::nF,14, ::aMV[2,11] )
         oRpt:Say( ::nF,15, ::aMV[2,12] )
         oRpt:Say( ::nF,16, ::aMV[2,13] )
         ::nF += 5
         AEVAL( ::aMV, {|x| AFILL( x,0 ) } )
      EndIf
   EndIf
EndDo
  oRpt:Visualizar(.T.)
  oRpt:End(.F.) ; oRpt := NIL
RETURN NIL

//------------------------------------//
METHOD Novedad( oRpt ) CLASS TLinov
   LOCAL aRes, hRes, nL
If ::aLS[7]  # ::aEpl[6] .AND. ::aLS[3]
   ::aLS[7] := ::aEpl[6]
   ::aEnc[4]:= "EN MISION " +;
               Buscar( { "cencos",::aEpl[6] },"cencosto","combre",8 )
   If ::aLS[4] == 1
      oRpt:aEnc[3] := ::aEnc[4]
      oRpt:nL    := 67
      oRpt:nPage := 0
   ElseIf ::aLS[4] == 3
      ::aEnc[1]  := .t.
   EndIf
EndIf
If (nL := AT(::aEpl[5],"IVL")) > 0
   ::aEpl[5] := { "INCAPACI","VACACION","LICENCIA" }[nL]
Else
   ::aEpl[5] := ::aEpl[1]
EndIf
::aMV[1,01] := ::aMV[1,02] := 0
aRes := STRTRAN( ::aLS[6],"[CODIGO]",LTRIM(STR(::aEpl[1])) )
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
::aLS[5] := (nL != 0)
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aRes[1] == 1
      If Rango( aRes[2],{1,2,9,10,11} )
         If aRes[2] >= 9
            ::aMV[1,01] += aRes[3]
         Else
            ::aMV[1,02] += (aRes[3] / 8)
         EndIf
/*            ::aMV[1,03] += aRes[4]  // Basico
      ElseIf aRes[2] == 12
            ::aMV[1,04] += aRes[4]  // Transporte
      Else
            ::aMV[1,05] += aRes[4]  // Otros Pagos*/
      EndIf
      ::aMV[1,aRes[5]+2] += aRes[4]
   Else
      ::aMV[1,aRes[5]+3] += aRes[4]
/*    If Rango( aRes[2],{47,50} )
            ::aMV[1,07] += aRes[4]  // Salud
      ElseIf Rango( aRes[2],{48,51} )
            ::aMV[1,08] += aRes[4]  // Pension
      ElseIf Rango( aRes[2],{49,52} )
            ::aMV[1,09] += aRes[4]  // F.S.P.
      ElseIf aRes[2] == 26
            ::aMV[1,10] += aRes[4]  // Prestamos
      Else
            ::aMV[1,11] += aRes[4]  // Otros Descuentos
      EndIf*/
   EndIF
   nL --
EndDo
MSFreeResult( hRes )
If ::aLS[5]
   aRes := "SELECT notas FROM nomnovec "                  +;
           "WHERE empresa = "  + LTRIM(STR(oApl:nEmpresa))+;
            " AND codigo = "   + LTRIM(STR(::aEpl[1]))    +;
            " AND fechahas = " + xValToChar( ::aLS[2] )
   hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   If MSNumRows( hRes ) > 0
      aRes := MyReadRow( hRes )
      If !EMPTY(aRes[1])
         ::aEnc[5] ++
//       nL := If( ::aLS[4] == 1, 13, 15 )
         nL := If( ::aLS[4] == 1, 23, 15 )
         ::aEpl[3] := LEFT( ::aEpl[3],nL ) + "(" + LTRIM(STR(::aEnc[5])) + ")"
//         ::aEpl[5] := "(" + LTRIM(STR(::aEnc[5])) + ") "
/*       If (::aEnc[5] % 2) == 1
            AADD( ::aEnc[6], ::aEpl[5] + ALLTRIM(aRes[1]) )
         Else
            nL := LEN( ::aEnc[6] )
            ::aEnc[6,nL] += " " + ::aEpl[5] + ALLTRIM(aRes[1])
         EndIf*/
         AADD( ::aEnc[6], STR(::aEnc[5],3) + " " + ALLTRIM(aRes[1]) )
      EndIf
   EndIf
   MSFreeResult( hRes )
EndIf
::aMV[1,06] := ::aMV[1,03] + ::aMV[1,04] + ::aMV[1,05]
::aMV[1,12] := ::aMV[1,07] + ::aMV[1,08] + ::aMV[1,09] + ::aMV[1,10] + ::aMV[1,11]
::aMV[1,13] := ::aMV[1,06] - ::aMV[1,12]
RETURN NIL

//------------------------------------//
METHOD DatosPer() CLASS TLinov
   LOCAL aEd := { 0,"",0,"","" }
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
 Nitsx( oApl:oEpl:CNIT_EPS,@aEd,1,2 )
 Nitsx( oApl:oEpl:CNIT_AFP,@aEd,3,4 )
 oApl:oNit:Seek( {"codigo_nit",oApl:oEpl:CODIGO_NIT} )
//::aLS := Separar( oApl:oNit:NOMBRE,oApl:oNit:PA,oApl:oNit:SA,oApl:oNit:PN,oApl:oNit:SN )
aEd[5]:= {"Soltero(a)","Casado(a)","Union Libre","Divorciado(a)"}[AT( oApl:oEpl:ESTADOCIV,"SCUD" )]

    UTILPRN ::oUtil SELECT ::aFnt[2]
    UTILPRN ::oUtil  3.0, 3.0 SAY "Barranquilla, " + NtChr( DATE(),"3")
    UTILPRN ::oUtil  4.0, 3.0 SAY "Señores :"
    UTILPRN ::oUtil LINEA 4.9,3.0 TO 4.9,15.0
    UTILPRN ::oUtil  5.5, 3.0 SAY "Ciudad"
    UTILPRN ::oUtil ;
           MSG "DATOS PERSONALES" AT 7.00,3.0 ;
           EXPANDBOX 0.1,1
    UTILPRN ::oUtil  8.0, 3.0 SAY "NOMBRES"
    UTILPRN ::oUtil  8.0, 7.5 SAY XTRIM( oApl:oNit:PRI_NOM ) + ALLTRIM( oApl:oNit:SEG_NOM )
    UTILPRN ::oUtil  8.5, 3.0 SAY "APELLIDOS"
    UTILPRN ::oUtil  8.5, 7.5 SAY XTRIM( oApl:oNit:PRI_APE ) + ALLTRIM( oApl:oNit:SEG_APE )
    UTILPRN ::oUtil  9.0, 3.0 SAY "C.C."
    UTILPRN ::oUtil  9.0, 7.5 SAY FormatoNit( oApl:oNit:CODIGO,oApl:oNit:DIGITO )
    UTILPRN ::oUtil  9.5, 3.0 SAY "DIRECCION"
    UTILPRN ::oUtil  9.5, 7.5 SAY oApl:oNit:DIRECCION
    UTILPRN ::oUtil 10.0, 3.0 SAY "TELEFONO"
    UTILPRN ::oUtil 10.5, 3.0 SAY "CELULAR"
    UTILPRN ::oUtil 11.0, 3.0 SAY "FECHA NACIMIENTO"
    UTILPRN ::oUtil 11.0, 7.5 SAY NtChr(oApl:oEpl:FECHANAC,"2")
    UTILPRN ::oUtil 11.5, 3.0 SAY "COMPENSACION"
    UTILPRN ::oUtil 11.5, 9.8 SAY TRANSFORM(oApl:oEpl:SUELDOACT,"999,999,999.99" ) RIGHT
    UTILPRN ::oUtil 12.0, 3.0 SAY "FECHA VINCULACION"
    UTILPRN ::oUtil 12.0, 7.5 SAY NtChr(oApl:oEpl:FECHAING,"2")
    UTILPRN ::oUtil 12.5, 3.0 SAY "ESTADO CIVIL"
    UTILPRN ::oUtil 12.5, 7.5 SAY aEd[5]
    UTILPRN ::oUtil 13.0, 3.0 SAY "No. DE HIJOS"
//  UTILPRN ::oUtil 13.0, 7.5 SAY TRANSFORM(oApl:oEpl:NROHIJOS,"999,999,999.99" ) RIGHT
    UTILPRN ::oUtil 14.0, 3.0 SAY "EDUCACION"
    UTILPRN ::oUtil 14.0, 7.5 SAY "Primaria"
    UTILPRN ::oUtil 14.5, 7.5 SAY "Tecnica"
    UTILPRN ::oUtil 15.0, 7.5 SAY "Universitaria"
    UTILPRN ::oUtil BOX   14.0,10.0 TO 15.5,10.5
    UTILPRN ::oUtil LINEA 14.5,10.0 TO 14.5,10.5
    UTILPRN ::oUtil LINEA 15.0,10.0 TO 15.0,10.5

    UTILPRN ::oUtil 14.0,11.0 SAY "Secundaria"
    UTILPRN ::oUtil 14.5,11.0 SAY "Tecnologo"
    UTILPRN ::oUtil 15.0,11.0 SAY "Magister"
    UTILPRN ::oUtil BOX   14.0,13.5 TO 15.5,14.0
    UTILPRN ::oUtil LINEA 14.5,13.5 TO 14.5,14.0
    UTILPRN ::oUtil LINEA 15.0,13.5 TO 15.0,14.0

    UTILPRN ::oUtil 15.5, 3.0 SAY "OCUPACION/CARGO"
    UTILPRN ::oUtil 15.5, 7.5 SAY oApl:oEpl:OCUPACION
    UTILPRN ::oUtil 16.0, 3.0 SAY "RECOMIENDA"
    UTILPRN ::oUtil 16.0, 7.5 SAY REPLICATE( "_",20 )
    UTILPRN ::oUtil 16.5, 3.0 SAY "TELEFONO"
    UTILPRN ::oUtil 17.0, 3.0 SAY "PRESTA SERVICIO EN"
    UTILPRN ::oUtil 17.0, 7.5 SAY ArrayValor( ::aCCos,oApl:oEpl:CENCOS,,.f. )
    UTILPRN ::oUtil 17.5, 3.0 SAY "E.P.S."
    UTILPRN ::oUtil 17.5, 7.5 SAY aEd[2]
    UTILPRN ::oUtil 18.0, 3.0 SAY "FECHA AFILIACION"
    UTILPRN ::oUtil 18.5, 3.0 SAY "COTIZANTE P."
    UTILPRN ::oUtil BOX   18.5, 8.0 TO 18.9,8.5
    UTILPRN ::oUtil 18.5, 9.0 SAY "BENEFICIARIO"
    UTILPRN ::oUtil BOX   18.5,11.5 TO 18.9,12.0
    UTILPRN ::oUtil 18.5,12.5 SAY "PADRE"
    UTILPRN ::oUtil BOX   18.5,14.0 TO 18.9,14.5

    UTILPRN ::oUtil 19.5, 3.0 SAY "PENSION"
    UTILPRN ::oUtil 19.5, 7.5 SAY aEd[4]
    UTILPRN ::oUtil 20.0, 3.0 SAY "FECHA AFILIACION"
    UTILPRN ::oUtil 20.5, 3.0 SAY "CUENTA BANCARIA #"
    UTILPRN ::oUtil 20.5, 7.5 SAY oApl:oEpl:CTACTE
    UTILPRN ::oUtil 21.0, 3.0 SAY "CERTIFICO :"
    UTILPRN ::oUtil 21.5, 3.1 SAY "Que los datos anteriores son ciertos y doy fe de su veracidad, lo cual"
    UTILPRN ::oUtil 22.0, 3.1 SAY "puedo aportar los documentos necesarios para la prueba de estos."

    UTILPRN ::oUtil 24.5, 3.0 SAY "FIRMA:" + REPLICATE( "_",25 )
    UTILPRN ::oUtil 25.3, 3.0 SAY "c.c. No.____________________DE____________________"
    UTILPRN ::oUtil BOX  22.5 ,13.0 TO 25.2,15.0 ROUND 90,90
    UTILPRN ::oUtil 25.3,13.5 SAY "Huella"
 ENDPAGE
IMPRIME END .F.
RETURN NIL

//------------------------------------//
METHOD Liquidar( dFec ) CLASS TLinov
   LOCAL cQry, nF
cQry := "SELECT c.fechai, c.fechaf, c.basico, c.dias, "     +;
            "d.clasepd, d.concepto, d.valornoved, d.horas " +;
        "FROM nomnovec c, nomnoved d "                      +;
        "WHERE c.empresa  = " + LTRIM(STR(oApl:nEmpresa))   +;
         " AND c.codigo   = " + LTRIM(STR(oApl:oEpl:CODIGO))+;
         " AND c.fechahas = " + xValToChar( dFec )          +;
         " AND d.empresa  = c.empresa"                      +;
         " AND d.codigo   = c.codigo"                       +;
         " AND d.fechahas = c.fechahas"
::hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes ) ; RETURN NIL
EndIf
::aLS := ARRAY(26)
AFILL( ::aLS,0 )
While ::nL > 0
   ::aEpl := MyReadRow( ::hRes )
   AEVAL( ::aEpl,{|xV,nP| ::aEpl[nP] := MyClReadCol( ::hRes,nP ) } )
   If ::aMV == NIL
      ::aMV := { ::aEpl[1],::aEpl[2],::aEpl[3],::aEpl[4],;
                 YEAR( ::aEpl[2] ) -  YEAR( ::aEpl[1] ) ,;
                MONTH( ::aEpl[2] ) - MONTH( ::aEpl[1] ) ,;
                  DAY( ::aEpl[2] ) -   DAY( ::aEpl[1] ),0,0,0,0,0,0 }
      ::aMV[8] := (::aMV[5] * 360) + (::aMV[6] * 30) + ::aMV[7]
   EndIf
   If ::aEpl[5] == 1
      If ::aEpl[6] == 21
         ::aLS[01] += ::aEpl[7]
      ElseIf Rango( ::aEpl[6],{18,19,20} )
         ::aLS[03] += ::aEpl[7]
      ElseIf Rango( ::aEpl[6],{1,2} )
         ::aLS[07] += ::aEpl[7]
       //::aLS[1] += (::aEpl[8] / 8)
      ElseIf ::aEpl[6] == 17
         ::aLS[09] += ::aEpl[7]
      ElseIf ::aEpl[6] == 15
         ::aLS[11] += ::aEpl[7]
      ElseIf ::aEpl[6] == 23
         ::aLS[13] += ::aEpl[7]
      ElseIf ::aEpl[6] == 12
         ::aLS[15] += ::aEpl[7]
      ElseIf ::aEpl[6] == 22
         ::aLS[17] += ::aEpl[7]
      Else
         ::aLS[21] += ::aEpl[7]
      EndIf
      ::aLS[24] += ::aEpl[7]
   Else
      If ::aEpl[6] == 48
         ::aLS[02] += ::aEpl[7]
      ElseIf ::aEpl[6] == 47
         ::aLS[04] += ::aEpl[7]
      ElseIf ::aEpl[6] == 31
         ::aLS[06] += ::aEpl[7]
      ElseIf ::aEpl[6] == 26
         ::aLS[08] += ::aEpl[7]
      ElseIf ::aEpl[6] == 46
         ::aLS[14] += ::aEpl[7]
      Else
         ::aLS[18] += ::aEpl[7]
      EndIf
      ::aLS[23] += ::aEpl[7]
   EndIF
   ::nL --
EndDo
MSFreeResult( ::hRes )
      ::aLS[25] := ::aLS[24] - ::aLS[23]
cQry := "SELECT concepto, SUM(valornoved) FROM nomnoved "+;
        "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))   +;
         " AND codigo  = " + LTRIM(STR(oApl:oEpl:CODIGO))+;
         " AND fechahas >= "+ xValToChar( ::aMV[1] )     +;
         " AND fechahas <= "+ xValToChar( ::aMV[2] )     +;
         " GROUP BY concepto"
::hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
::nL   := MSNumRows( ::hRes )
While ::nL > 0
   ::aEpl := MyReadRow( ::hRes )
   AEVAL( ::aEpl,{|xV,nP| ::aEpl[nP] := MyClReadCol( ::hRes,nP ) } )
      ::aEpl[2] := ROUND( ::aEpl[2] / ::aMV[8] * 30, 0 )
   If ::aEpl[1] == 37
      ::aMV[09] += ::aEpl[2]
   ElseIf Rango( ::aEpl[1],{3,4} )
      ::aMV[10] += ::aEpl[2]
   ElseIf Rango( ::aEpl[1],{5,6,7,8,53,56} )
      ::aMV[11] += ::aEpl[2]
   ElseIf ::aEpl[1] == 34
      ::aMV[12] += ::aEpl[2]
   EndIf
   ::nL --
EndDo
MSFreeResult( ::hRes )
If oApl:oEpl:SUELDOACT > (oApl:oFis:SALARIOMIN * oApl:oFie:MINIMOS)
   ::aMV[13] := oApl:oFis:TRANSPORTE
EndIf
 oApl:oNit:Seek( {"codigo_nit",oApl:oEpl:CODIGO_NIT} )
::aLS[26] := FormatoNit( oApl:oNit:CODIGO,oApl:oNit:DIGITO )
cQry := "999,999,999"
    UTILPRN ::oUtil  2.0, 5.0 SAY "LIQUIDACION PRESTACIONES SOCIALES"
    UTILPRN ::oUtil  2.5, 1.5 SAY "En mision : " + ArrayValor( ::aCCos,oApl:oEpl:CENCOS,,.f. )
    UTILPRN ::oUtil  3.0, 1.5 SAY oApl:oEpl:NOMBRE
    UTILPRN ::oUtil  3.5, 1.5 SAY "C.C. No." + ::aLS[26]
    UTILPRN ::oUtil BOX    4.0 , 1.0 TO 11.8 ,20.0 ROUND 25,25
    UTILPRN ::oUtil BOX   11.8 , 1.0 TO 21.55,20.0 ROUND 25,25
    UTILPRN ::oUtil LINEA  4.65, 1.0 TO  4.65,10.5
    UTILPRN ::oUtil LINEA  4.65, 7.0 TO 11.15, 7.0
    UTILPRN ::oUtil LINEA  4.65, 8.5 TO 11.15, 8.5
    UTILPRN ::oUtil LINEA  4.65, 9.5 TO 11.15, 9.5
    UTILPRN ::oUtil LINEA  4.0 ,10.5 TO 21.55,10.5
    UTILPRN ::oUtil LINEA  5.3 ,16.7 TO 11.15,16.7
    UTILPRN ::oUtil LINEA 12.45, 7.2 TO 21.55, 7.2
    UTILPRN ::oUtil LINEA 12.45,16.7 TO 21.55,16.7
 FOR nF :=  5.3  TO 11.8  STEP .65
    UTILPRN ::oUtil LINEA nF, 1.0 TO nF,20.0
 NEXT nF
 FOR nF := 12.45 TO 20.9  STEP .65
    UTILPRN ::oUtil LINEA nF, 1.0 TO nF,20.0
 NEXT nF
    UTILPRN ::oUtil  4.2 ,11.5 SAY "Base Salarial para Liquidar Cesantia,"
    UTILPRN ::oUtil  4.85, 2.5 SAY "Tiempo Trabajado"
    UTILPRN ::oUtil  4.85, 7.1 SAY "Año"
    UTILPRN ::oUtil  4.85, 8.6 SAY "Mes"
    UTILPRN ::oUtil  4.85, 9.6 SAY "Dia"
    UTILPRN ::oUtil  4.85,11.5 SAY "Prima de Servicios y Vacaciones en Dinero"
    UTILPRN ::oUtil  5.5 , 1.1 SAY "Fecha " +;
       If( oApl:oEpl:ESTADOLAB == "V", "final", "de retiro" )
    UTILPRN ::oUtil  5.5 , 8.4 SAY TRANSFORM(  YEAR( ::aMV[2] ),"9999" ) RIGHT
    UTILPRN ::oUtil  5.5 , 9.4 SAY TRANSFORM( MONTH( ::aMV[2] ), "999" ) RIGHT
    UTILPRN ::oUtil  5.5 ,10.4 SAY TRANSFORM(   DAY( ::aMV[2] ), "999" ) RIGHT
    UTILPRN ::oUtil  5.5 ,10.6 SAY "Periodo Promediado"

    UTILPRN ::oUtil  6.15, 1.1 SAY "Fecha " +;
       If( oApl:oEpl:ESTADOLAB == "V", "incial", "de ingreso" )
    UTILPRN ::oUtil  6.15, 8.4 SAY TRANSFORM(  YEAR( ::aMV[1] ),"9999" ) RIGHT
    UTILPRN ::oUtil  6.15, 9.4 SAY TRANSFORM( MONTH( ::aMV[1] ), "999" ) RIGHT
    UTILPRN ::oUtil  6.15,10.4 SAY TRANSFORM(   DAY( ::aMV[1] ), "999" ) RIGHT
    UTILPRN ::oUtil  6.15,10.6 SAY "Ultimo sueldo o promedio suledo"
    UTILPRN ::oUtil  6.15,19.8 SAY TRANSFORM( ::aMV[3],cQry )            RIGHT

    UTILPRN ::oUtil  6.8 , 1.1 SAY "Sub-total (tiempo)"
    UTILPRN ::oUtil  6.8 , 8.4 SAY TRANSFORM( ::aMV[5],"9999" ) RIGHT
    UTILPRN ::oUtil  6.8 , 9.4 SAY TRANSFORM( ::aMV[6], "999" ) RIGHT
    UTILPRN ::oUtil  6.8 ,10.4 SAY TRANSFORM( ::aMV[7], "999" ) RIGHT
    UTILPRN ::oUtil  6.8 ,10.6 SAY "Promedio recargos nocturnos"
    UTILPRN ::oUtil  6.8 ,19.8 SAY TRANSFORM( ::aMV[9],cQry )   RIGHT
    ::aMV[1] :=  ::aMV[2] := 0
 If (nF := ::aMV[4] - ::aMV[8]) > 0
    ::aMV[1] :=  INT(nF / 360)
    nF       -= (::aMV[1]*360)
    ::aMV[2] :=  INT(nF / 30)
    nF       -= (::aMV[2]*30)
    ::aMV[5] -= ::aMV[1]
    ::aMV[6] -= ::aMV[2]
    ::aMV[7] -= nF
 EndIf
    UTILPRN ::oUtil  7.45, 1.1 SAY "Menos suspensiones del contrato"
    UTILPRN ::oUtil  7.45, 8.4 SAY TRANSFORM( ::aMV[1],"9999" ) RIGHT
    UTILPRN ::oUtil  7.45, 9.4 SAY TRANSFORM( ::aMV[2], "999" ) RIGHT
    UTILPRN ::oUtil  7.45,10.4 SAY TRANSFORM( nF      , "999" ) RIGHT
    UTILPRN ::oUtil  7.45,10.6 SAY "Promedio horas extras"
    UTILPRN ::oUtil  7.45,19.8 SAY TRANSFORM( ::aMV[10],cQry )  RIGHT

    UTILPRN ::oUtil  8.1 , 1.1 SAY "Tiempo neto"
    UTILPRN ::oUtil  8.1 , 8.4 SAY TRANSFORM( ::aMV[5],"9999" ) RIGHT
    UTILPRN ::oUtil  8.1 , 9.4 SAY TRANSFORM( ::aMV[6], "999" ) RIGHT
    UTILPRN ::oUtil  8.1 ,10.4 SAY TRANSFORM( ::aMV[7], "999" ) RIGHT
    UTILPRN ::oUtil  8.1 ,10.6 SAY "Promedio dominicales y/o festivos tr."
    UTILPRN ::oUtil  8.1 ,19.8 SAY TRANSFORM( ::aMV[11],cQry )  RIGHT

    UTILPRN ::oUtil  8.75,10.6 SAY "Promedio comisiones"
    UTILPRN ::oUtil  8.75,19.8 SAY TRANSFORM( ::aMV[12],cQry )  RIGHT

    UTILPRN ::oUtil  9.4 ,10.6 SAY "Viaticos perm. para alojamiento y man."

    UTILPRN ::oUtil 10.05,10.6 SAY "Auxilio de transporte"
    UTILPRN ::oUtil 10.05,19.8 SAY TRANSFORM( ::aMV[13],cQry )  RIGHT

    UTILPRN ::oUtil 10.7 ,10.6 SAY "Promedio otros factores salariales"
 ::aMV[3] += (::aMV[09] + ::aMV[10] + ::aMV[11] + ::aMV[12] + ::aMV[13])
    UTILPRN ::oUtil 11.35, 1.1 SAY "Numero de dias"
    UTILPRN ::oUtil 11.35, 8.4 SAY TRANSFORM( ::aMV[4],"9999" ) RIGHT
    UTILPRN ::oUtil 11.35,16.5 SAY "Base Liquidacion $" RIGHT
    UTILPRN ::oUtil 11.35,19.8 SAY TRANSFORM( ::aMV[3],cQry ) RIGHT
/*
    UTILPRN ::oUtil 10.35, 2.0 SAY "Base Salarial para Liquidar Prima de Servicios"
    UTILPRN ::oUtil 10.35,10.9 SAY "Base Salarial para Liquidar Vacaciones en Dinero e Ind."
    UTILPRN ::oUtil 11.0 , 1.1 SAY "Periodo Promediado"
    UTILPRN ::oUtil 11.0 ,10.6 SAY "Periodo Promediado"
    UTILPRN ::oUtil 11.65, 1.1 SAY "Sueldo promedio"
    UTILPRN ::oUtil 11.65,10.6 SAY "Ultimo salario fijo"
    UTILPRN ::oUtil 12.3 , 1.1 SAY "Promedio recargos nocturnos"
    UTILPRN ::oUtil 12.3 ,10.6 SAY "Promedio recargos nocturnos"
    UTILPRN ::oUtil 12.95, 1.1 SAY "Promedio horas extras"
    UTILPRN ::oUtil 12.95,10.6 SAY "Promedio horas extras"
    UTILPRN ::oUtil 13.6 , 1.1 SAY "Promedio dominicales y/o festivos tr."
    UTILPRN ::oUtil 13.6 ,10.6 SAY "Promedio dominicales y/o festivos tr."
    UTILPRN ::oUtil 14.25, 1.1 SAY "Promedio comisiones"
    UTILPRN ::oUtil 14.25,10.6 SAY "Promedio comisiones"
    UTILPRN ::oUtil 14.9 , 1.1 SAY "Viaticos perm. para alojamiento y man."
    UTILPRN ::oUtil 14.9 ,10.6 SAY "Viaticos perm. para alojamiento y man."
    UTILPRN ::oUtil 15.55, 1.1 SAY "Auxilio de transporte"
    UTILPRN ::oUtil 15.55,10.6 SAY "Promedio otros factores salariales"
    UTILPRN ::oUtil 16.2 , 1.1 SAY "Promedio otros factores salariales"
    UTILPRN ::oUtil 16.85, 7.0 SAY "Base Liquidacion $" RIGHT
    UTILPRN ::oUtil 16.85,16.5 SAY "Base Liquidacion $" RIGHT
*/
    UTILPRN ::oUtil 12.0 , 3.0 SAY "L i q u i d a c i o n"
    UTILPRN ::oUtil 12.0 ,12.0 SAY "D e d u c c i o n e s"
    UTILPRN ::oUtil 12.65, 1.1 SAY "Cesantia Total"
    UTILPRN ::oUtil 12.65,10.3 SAY TRANSFORM( ::aLS[01],cQry ) RIGHT
    UTILPRN ::oUtil 12.65,10.6 SAY "Aportes pensiones"
    UTILPRN ::oUtil 12.65,19.8 SAY TRANSFORM( ::aLS[02],cQry ) RIGHT

    UTILPRN ::oUtil 13.3 , 1.1 SAY "Menos cesantias parciales"
    UTILPRN ::oUtil 13.3 ,10.3 SAY TRANSFORM( ::aLS[03],cQry ) RIGHT
    UTILPRN ::oUtil 13.3 ,10.6 SAY "Aportes salud"
    UTILPRN ::oUtil 13.3 ,19.8 SAY TRANSFORM( ::aLS[04],cQry ) RIGHT

    UTILPRN ::oUtil 13.95, 1.1 SAY "Cesantia neta"
    UTILPRN ::oUtil 13.95,10.3 SAY TRANSFORM( ::aLS[05],cQry ) RIGHT
    UTILPRN ::oUtil 13.95,10.6 SAY "Retencion en la fuente"
    UTILPRN ::oUtil 13.95,19.8 SAY TRANSFORM( ::aLS[06],cQry ) RIGHT

    UTILPRN ::oUtil 14.6 , 1.1 SAY "Sueldo"
    UTILPRN ::oUtil 14.6 ,10.3 SAY TRANSFORM( ::aLS[07],cQry ) RIGHT
    UTILPRN ::oUtil 14.6 ,10.6 SAY "Anticipos y prestamos autorizados"
    UTILPRN ::oUtil 14.6 ,19.8 SAY TRANSFORM( ::aLS[08],cQry ) RIGHT

    UTILPRN ::oUtil 15.25, 1.1 SAY "Vacaciones"
    UTILPRN ::oUtil 15.25,10.3 SAY TRANSFORM( ::aLS[09],cQry ) RIGHT
    UTILPRN ::oUtil 15.25,10.6 SAY "Fondo de empleados - aportes"
    UTILPRN ::oUtil 15.25,19.8 SAY TRANSFORM( ::aLS[10],cQry ) RIGHT

    UTILPRN ::oUtil 15.9 , 1.1 SAY "Prima servicios"
    UTILPRN ::oUtil 15.9 ,10.3 SAY TRANSFORM( ::aLS[11],cQry ) RIGHT
    UTILPRN ::oUtil 15.9 ,10.6 SAY "Fondo de empleados - prestamos"
    UTILPRN ::oUtil 15.9 ,19.8 SAY TRANSFORM( ::aLS[12],cQry ) RIGHT

    UTILPRN ::oUtil 16.55, 1.1 SAY "Indemnizacion"
    UTILPRN ::oUtil 16.55,10.3 SAY TRANSFORM( ::aLS[13],cQry ) RIGHT
    UTILPRN ::oUtil 16.55,10.6 SAY "Cooperativas"
    UTILPRN ::oUtil 16.55,19.8 SAY TRANSFORM( ::aLS[14],cQry ) RIGHT

    UTILPRN ::oUtil 17.2 , 1.1 SAY "Auxilio de transporte"
    UTILPRN ::oUtil 17.2 ,10.3 SAY TRANSFORM( ::aLS[15],cQry ) RIGHT
    UTILPRN ::oUtil 17.2 ,10.6 SAY "Preaviso"
    UTILPRN ::oUtil 17.2 ,19.8 SAY TRANSFORM( ::aLS[16],cQry ) RIGHT

    UTILPRN ::oUtil 17.85, 1.1 SAY "Intereses de cesantia"
    UTILPRN ::oUtil 17.85,10.3 SAY TRANSFORM( ::aLS[17],cQry ) RIGHT
    UTILPRN ::oUtil 17.85,10.6 SAY "Otros"
    UTILPRN ::oUtil 17.85,19.8 SAY TRANSFORM( ::aLS[18],cQry ) RIGHT

    UTILPRN ::oUtil 18.5 , 1.1 SAY "Valor proporcional descanso dominical"
    UTILPRN ::oUtil 18.5 ,10.3 SAY TRANSFORM( ::aLS[19],cQry ) RIGHT

    UTILPRN ::oUtil 19.15, 1.1 SAY "Otros"
    UTILPRN ::oUtil 19.15,10.3 SAY TRANSFORM( ::aLS[21],cQry ) RIGHT

    UTILPRN ::oUtil 19.8 ,16.5 SAY "Total Deducciones (b)"     RIGHT
    UTILPRN ::oUtil 19.8 ,19.8 SAY TRANSFORM( ::aLS[23],cQry ) RIGHT

    UTILPRN ::oUtil 21.1 , 7.0 SAY "Total Liquidado (a)"       RIGHT
    UTILPRN ::oUtil 21.1 ,10.3 SAY TRANSFORM( ::aLS[24],cQry ) RIGHT
    UTILPRN ::oUtil 21.1 ,16.5 SAY "Total Neto Liquidado (a - b)" RIGHT
    UTILPRN ::oUtil 21.1 ,19.8 SAY TRANSFORM( ::aLS[25],cQry ) RIGHT

    UTILPRN ::oUtil 25.0, 1.5 SAY "RECIBI CONFORME:" + REPLICATE( "_",20 )
    UTILPRN ::oUtil 25.5, 1.5 SAY oApl:oEpl:NOMBRE
    UTILPRN ::oUtil 26.0, 1.5 SAY "C.C. No." + ::aLS[26]
 ENDPAGE
IMPRIME END .F.
RETURN NIL
