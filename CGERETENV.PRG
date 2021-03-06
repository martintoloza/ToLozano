// Programa.: CGERETEN.PRG    >>> Martin A. Toloza L. <<<
// Notas....: Certificado de Retencion en la Fuente.
#include "Fivewin.ch"
#include "btnget.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE CgeReten()
   LOCAL oDlg, oM, oNi, oGet := ARRAY(10)
 oM  := TReten();  oM:New()
 oNi := TNits() ; oNi:New()
oNi:oDb:GoBottom():Read()
oNi:oDb:xLoad()
oM:aLS[2] := oNi:oDb:CODIGO
DEFINE DIALOG oDlg TITLE "CERTIFICADO DE RETENCION" FROM 0, 0 TO 14,60
   @ 02,00 SAY "NIT INICIAL" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 02,72 BTNGET oGet[1] VAR oM:aLS[1] OF oDlg PICTURE "9999999999" ;
      VALID EVAL( {|| If( EMPTY( oM:aLS[1] ), .t.                   ,;
              (If( oNi:oDb:Seek( { "codigo",oM:aLS[1] } )           ,;
              ( oM:aLS[8] := oNi:oDb:NOMBRE, oDlg:Update(), .t. )   ,;
              ( MsgStop("Este Nit no Existe"),.f.)))) } )            ;
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"                            ;
      ACTION EVAL({|| If(oNi:Mostrar(), (oM:aLS[1] := oNi:oDb:CODIGO,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
   @ 02,130 SAY oM:aLS[8] OF oDlg PIXEL SIZE 160,10 UPDATE COLOR nRGB( 128,0,255 )
   @ 14,00 SAY "NIT   FINAL" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 14,72 BTNGET oGet[2] VAR oM:aLS[2] OF oDlg PICTURE "9999999999" ;
      VALID EVAL( {|| If( EMPTY( oM:aLS[2] ), .t.                   ,;
              (If( oNi:oDb:Seek( { "codigo",oM:aLS[2] } )           ,;
              ( oM:aLS[9] := oNi:oDb:NOMBRE, oDlg:Update(), .t. )   ,;
              ( MsgStop("Este Nit no Existe"),.f.)))) } )            ;
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"                            ;
      ACTION EVAL({|| If(oNi:Mostrar(), (oM:aLS[2] := oNi:oDb:CODIGO,;
                        oGet[2]:Refresh(), oGet[2]:lValid(.f.)),)})
   @ 14,130 SAY oM:aLS[8] OF oDlg PIXEL SIZE 160,10 UPDATE COLOR nRGB( 128,0,255 )
   @ 26,00 SAY "PERIODO INICIAL" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 26,72 GET oGet[3] VAR oM:aLS[3] OF oDlg PICTURE "999999" SIZE 32,10 PIXEL;
      VALID NtChr( oM:aLS[3],"P" )
   @ 38,00 SAY "PERIODO   FINAL" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 38,72 GET oGet[4] VAR oM:aLS[4] OF oDlg PICTURE "999999" SIZE 32,10 PIXEL;
      VALID NtChr( oM:aLS[4],"P" )
   @ 50,00 SAY "Retenci�n"      OF oDlg RIGHT PIXEL SIZE 70,10
   @ 50,72 COMBOBOX oGet[5] VAR oM:aLS[5] ITEMS oM:aRet SIZE 60,99 OF oDlg PIXEL
   @ 62,00 SAY "TIPO DE IMPRESORA"   OF oDlg RIGHT PIXEL SIZE 70,10
   @ 62,72 COMBOBOX oGet[6] VAR oM:aLS[6] ITEMS { "Matriz","Laser" };
      SIZE 48,90 OF oDlg PIXEL
   @ 62,124 CHECKBOX oGet[7] VAR oM:aLS[7] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,10 PIXEL
   @ 74,00 SAY "Escoja la Fuente"  OF oDlg RIGHT PIXEL SIZE 70,10
   @ 74,72 COMBOBOX oGet[8] VAR oM:cFont ITEMS oM:aFont SIZE 80,99 OF oDlg PIXEL;
      WHEN oM:aLS[6] > 1

   @ 88, 50 BUTTON oGet[09] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[09]:Disable(), oM:ArmarMOV( oDlg ), oGet[09]:Enable(),;
        oGet[09]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 88,100 BUTTON oGet[10] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 92, 02 SAY "[CGERETEN]" OF oDlg PIXEL SIZE 34,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
//ACTIVATE DIALOG oDlg CENTERED ON INIT ( Empresa( .t. ) )
RETURN

CLASS TReten FROM TIMPRIME

 DATA aRet AS ARRAY INIT { "en la fuente","de ica" }
 DATA aLS, aMV, aRes, aMes, hRes, nL
 DATA lTit INIT .T.

   METHOD NEW() Constructor
   METHOD ArmarMOV( oDlg )
   METHOD BuscaFte( lFte )
   METHOD ListoDOS( oDlg )
   METHOD Lineas()
ENDCLASS

//------------------------------------//
METHOD NEW() CLASS TReten
   LOCAL hDC := GetDC( 0 )
 ::aFont := GetFontNames( hDC )
 ::cFont := STR( YEAR(DATE())-1,4 )
 ::aLS   := { 0,99,::cFont+"01",::cFont+"12",1,oApl:nTFor,.t.,"","" }
 ::aMV   := { -1,0,0,0,ALLTRIM( oApl:oEmp:NOMBRE2 ),""       ,;
              PADC( ALLTRIM( oApl:cCiu ) + " - COLOMBIA",79 ),;
              "",NtChr( DATE(),"6" ) }
 ::aMes  := { {"Ene-Feb",0,0,0},;
              {"Mar-Abr",0,0,0},;
              {"May-Jun",0,0,0},;
              {"Jul-Ago",0,0,0},;
              {"Sep-Oct",0,0,0},;
              {"Nov-Dic",0,0,0} }
 ::cFont := "Arial"
RETURN NIL

//------------------------------------//
METHOD ArmarMOV( oDlg ) CLASS TReten
   LOCAL cQry := ::aLS
Swap( @cQry,1,2 ) //Nit
Swap( @cQry,3,4 ) //Periodo
::aLS := cQry

MSQuery( oApl:oMySql:hConnect,"DROP TABLE retencion" )
cQry := "CREATE TEMPORARY TABLE retencion ( "             +;
            "codigo      INT(12)  NOT NULL, "             +;
            "digito      INT(01)  NOT NULL, "             +;
            "nombre  VARCHAR(40)  NOT NULL, "             +;
            "cuenta  VARCHAR(10)  NOT NULL, "             +;
            "base    DOUBLE(12,2) NOT NULL DEFAULT 0.00, "+;
            "ptaje   DOUBLE(06,2) NOT NULL DEFAULT 0.00, "+;
            "debito  DOUBLE(12,2) NOT NULL DEFAULT 0.00, "+;
            "credito DOUBLE(12,2) NOT NULL DEFAULT 0.00 )"+;
        " ENGINE=MEMORY"
MSQuery( oApl:oMySql:hConnect,cQry )

// Introducimos datos en el cursor
cQry := "INSERT INTO retencion (codigo, digito, nombre, cuenta, base, ptaje, debito, credito) "+;
        "SELECT n.codigo, n.digito, n.nombre, d.cuenta, "  +;
               "CAST(SUM(d.infd) AS UNSIGNED INTEGER), "   +;
               "d.ptaje, SUM(d.valor_deb), SUM(d.valor_cre) "+;
         "FROM cgemovc c, cgemovd d LEFT JOIN cadclien n" +;
         " USING( codigo_nit ) "                          +;
         "WHERE d.empresa  = c.empresa"                   +;
          " AND d.ano_mes  = c.ano_mes"                   +;
          " AND d.control  = c.control AND c.estado <> 2" +;
          " AND d.empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
          " AND d.cuenta  >= '23'"                        +;
          " AND d.cuenta  <= '23999999'"                  +;
          " AND d.ano_mes >= " + xValToChar( ::aLS[1] )   +;
          " AND d.ano_mes <= " + xValToChar( ::aLS[2] )   +;
         "GROUP BY d.cuenta, n.codigo, d.ptaje "          +;
         "ORDER BY d.cuenta, n.codigo, d.ptaje"
If !MSQuery( oApl:oMySql:hConnect,cQry )
   oApl:oMySql:oError:Display( .f. )
Else
   hRes := MSStoreResult( oApl:oMySql:hConnect )
   nL   := MSAffectedRows( oApl:oMySql:hConnect )
   MSFreeResult( hRes )
 //MsgInfo( STR(nL)+" Registros Insertados" )
EndIf

cQry := If( ::aLS[5] == 1, "", ", a.ano_mes "  )
cQry := "SELECT r.nombre, n.nombre, n.codigo, n.digito, r.porcentaje, "+;
            "a.cuenta, SUM(a.valor_cre-a.valor_deb), SUM(a.valor_ret) "+;
        "FROM cgeacumn a, cgereten r, cadclien n "      +;
        "WHERE n.codigo >= " + LTRIM(STR(::aLS[1]))     +;
         " AND n.codigo <= " + LTRIM(STR(::aLS[2]))     +;
         " AND n.codigo_nit = a.codigo_nit"             +;
         " AND a.ano_mes >= " + xValToChar( ::aLS[3] )  +;
         " AND a.ano_mes <= " + xValToChar( ::aLS[4] )  +;
         " AND a.empresa  = "+ LTRIM(STR(oApl:nEmpresa))+;
         " AND r.cuenta   = LEFT(a.cuenta,6)"           +;
         " AND r.empresa  = "+ LTRIM(STR(oApl:nPuc))    +;
         " AND r.clase    = "+ LTRIM(STR(::aLS[5]))     +;
        " GROUP BY r.nombre, n.nombre, n.codigo_nit, "  +;
                  "r.porcentaje, a.cuenta "             +;
        "ORDER BY n.codigo, a.cuenta"
::hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes )
   RETURN NIL
EndIf
oDlg:SetText( "<< ESPERE >> A C T U A L I Z A N D O" )

 ::aMV[6] := RIGHT( NtChr( NtChr( ::aLS[3],"F" ),"6" ),5 )
 ::aMV[8] := "CERTIFICADO DE RETENCION " + UPPER( ::aRet[ ::aLS[5] ] )
 ::aRes := MyReadRow( ::hRes )
 AEVAL( ::aRes, {| xV,nP | ::aRes[nP] := MyClReadCol( ::hRes,nP ) } )
If ::aLS[6] == 1
   ::ListoDOS( oDlg )
Else
   ::Init( ::aMV[8], .f. ,, !::aLS[7] )
    ::Lineas()
   IMPRIME END .F.
   ::lTit   := .T.
EndIf
MSFreeResult( ::hRes )
RETURN NIL

//------------------------------------//
METHOD BuscaFte( lFte ) CLASS TReten

 ::aRes[7] := ::aRes[7] * If( LEFT( ::aRes[6],6 ) == "510506", -1, 1 )
// If ::aRes[8] == 0
    ::aRes[8] := If( ::aRes[5] == 0, 1, ::aRes[5]*100 )
    ::aRes[8] := ROUND( ::aRes[7]*100 / ::aRes[8],2 )
// EndIf
 /*
 If ::aLS[5] >= 2
    lFte := { 1,1,2,2,3,3,4,4,5,5,6,6 }[VAL( RIGHT(::aRes[9],2) )]
    ::aMes[lFte,2] := ::aRes[5]
    ::aMes[lFte,3] += ::aRes[7]
    ::aMes[lFte,4] += ::aRes[8]
 EndIf
*/
RETURN NIL

//------------------------------------//
METHOD ListoDOS( oDlg ) CLASS TReten
   LOCAL oRpt
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,,::aLS[7] )
oRpt:nPage := 1
While ::nL > 0
   If ::aRes[7]  # 0
      ::BuscaFte( .f. )
      If ::aMV[1]  # ::aRes[3]
         ::aMV[1] := ::aRes[3]
         oRpt:Say(  2,00,oRpt:CPILarge+PADC( oApl:cEmpresa,43 ) )
         oRpt:Say(  3,00,oRpt:CPILarge+PADC( ::aMV[5],43 ) )
         oRpt:Say(  4,00,oRpt:CPIBold+PADC( "NIT: " + TRIM(oApl:oEmp:NIT),79 ) )
         oRpt:Say(  5,00,::aMV[7] )
         oRpt:Say(  6,00,PADC( TRIM(oApl:oEmp:DIRECCION),79 ) )
         oRpt:Say(  7,21,"Tels. "+ oApl:oEmp:TELEFONO + "  Fax " +  oApl:oEmp:FAX )
         oRpt:Say( 10,00,oRpt:CPIBold+ ::aMV[8] +oRpt:CPIBoldN )
         oRpt:Say( 14,00,"Certificamos que durante el a|o gravable de " + ::aMV[6] +;
                          " practicamos retencion" )
         oRpt:Say( 15,00,::aRet[ ::aLS[5] ] + " a los se|ores :" )
         oRpt:Say( 17,00,oRpt:CPIBold+"RAZON SOCIAL" + SPACE(45) + "NIT"+oRpt:CPIBoldN )
         oRpt:Say( 18,00,"------------" + SPACE(41) + "-----------" )
         oRpt:Say( 19,00,::aRes[2] )
         oRpt:Say( 19,53,FormatoNit( ::aRes[3],::aRes[4] ) )
         oRpt:Say( 21,44,oRpt:CPIBold+" BASE SOMETIDA" )
         oRpt:Say( 22,00,"CONCEPTO" + SPACE(30) + "%    A LA RETENCION   VALOR RETENIDO"+oRpt:CPIBoldN )
         oRpt:Say( 23,00,"--------" + SPACE(28) + "------ --------------   --------------" )
         oRpt:nL := 24
      EndIf
//    If ::aLS[5] == 2
         oRpt:Say( oRpt:nL,00,::aRes[1] )
         oRpt:Say( oRpt:nL,36,TRANSFORM( ::aRes[5]*100,"@Z 999.99" ) )
         oRpt:Say( oRpt:nL,45,TRANSFORM( ::aRes[8],"$999,999,999" ) )
         oRpt:Say( oRpt:nL,59,TRANSFORM( ::aRes[7],"$999,999,999.99" ) )
         oRpt:nL ++
//    EndIf
      ::aMV[4] += ::aRes[7]
   EndIf
   If (::nL --) > 1
      ::aRes := MyReadRow( ::hRes )
      AEVAL( ::aRes, { | xV,nP | ::aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aMV[1] # ::aRes[3]
      If ::aMV[4] # 0
//       If ::aLS[5] >= 2
//       EndIf
         oRpt:Say( 43,25,"VALOR DE LA RETENCION =======>" )
         oRpt:Say( 43,59,TRANSFORM( ::aMV[4],"$999,999,999.99" ) )
         oRpt:Say( 48,00,oRpt:CPIBold+"LUGAR DONDE SE PRACTICO LA RETENCION : " + oRpt:CPIBoldN +;
                    TRIM( oApl:cCiu ) + "." )
         oRpt:Say( 50,00,"No requiere firma : Art. 10 decreto 836/91" )
/*       oRpt:Say( 50,00,"Para constancia, firmamos en "+ TRIM( oApl:cCiu ) + " a los " +;
                    STR( DAY( DATE() ),2 ) + " dias del mes de" )
         oRpt:Say( 51,00,::aMV[9] + "." )
         oRpt:Say( 56,00,REPLICATE( "_",30 ) )*/
         oRpt:NewPage()
      EndIf
      ::aMV[4] := 0
   EndIf
EndDo
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD Lineas() CLASS TReten

While ::nL > 0
   If ::aRes[7]  # 0
      ::BuscaFte( .f. )
      If ::aMV[1]  # ::aRes[3]
         ::aMV[1] := ::aRes[3]
         PAGE
         ::Centrar( oApl:cEmpresa,::aFnt[4],1.0 )
         ::Centrar( ::aMV[5]     ,::aFnt[4],2.0 )
         ::Centrar( "NIT: " + TRIM(oApl:oEmp:NIT),,2.8 )
         ::Centrar( ::aMV[7],,3.4 )
         ::Centrar( TRIM(oApl:oEmp:DIRECCION),,4.0 )
         ::Centrar( "Tels. "+ oApl:oEmp:TELEFONO + "  Fax " +  oApl:oEmp:FAX,,4.6 )

         UTILPRN ::oUtil  7.0, 1.5 SAY ::aMV[8] FONT ::aFnt[1]
         UTILPRN ::oUtil 09.0, 1.5 SAY "Certificamos que durante el a�o gravable de " +;
                                       ::aMV[6] + " practicamos retenci�n en"
         UTILPRN ::oUtil 09.5, 1.5 SAY ::aRet[ ::aLS[5] ] + " a los se�ores :"
         UTILPRN ::oUtil 10.5, 1.5 SAY "RAZON SOCIAL" FONT ::aFnt[1]
         UTILPRN ::oUtil 10.5,13.0 SAY "N I T"        FONT ::aFnt[1]
         UTILPRN ::oUtil 10.6, 1.5 SAY "_______________________"
         UTILPRN ::oUtil 10.6,13.0 SAY "____________"
         UTILPRN ::oUtil 11.0, 1.5 SAY ::aRes[2]
         UTILPRN ::oUtil 11.0,13.0 SAY FormatoNit( ::aRes[3],::aRes[4] )

         UTILPRN ::oUtil 12.5,13.0 SAY "BASE SOMETIDA"       FONT ::aFnt[1] RIGHT
         UTILPRN ::oUtil 13.0, 1.5 SAY "CONCEPTO"
         UTILPRN ::oUtil 13.0,13.0 SAY "%    A LA RETENCION" FONT ::aFnt[1] RIGHT
         UTILPRN ::oUtil 13.0,17.0 SAY "VALOR RETENIDO"      FONT ::aFnt[1] RIGHT
         UTILPRN ::oUtil SELECT ::aFnt[2]
         UTILPRN ::oUtil 13.1, 1.5 SAY "_____________"
         UTILPRN ::oUtil 13.1, 9.0 SAY "______ ______________            ______________"
         ::nLinea := 14.0
      EndIf
      UTILPRN ::oUtil Self:nLinea, 1.5 SAY ::aRes[1]
      UTILPRN ::oUtil Self:nLinea,10.0 SAY TRANSFORM( ::aRes[5]*100,"@Z 999.99" )   RIGHT
      UTILPRN ::oUtil Self:nLinea,13.0 SAY TRANSFORM( ::aRes[8],"$999,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,17.0 SAY TRANSFORM( ::aRes[7],"$999,999,999.99" ) RIGHT
      ::nLinea += 0.5
      ::aMV[4] += ::aRes[7]
   EndIf
   If (::nL --) > 1
      ::aRes := MyReadRow( ::hRes )
      AEVAL( ::aRes, { | xV,nP | ::aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aMV[1] # ::aRes[3]
      If ::aMV[4] # 0
         UTILPRN ::oUtil 20.0,08.0 SAY "VALOR DE LA RETENCION =======>"
         UTILPRN ::oUtil 20.0,17.0 SAY TRANSFORM( ::aMV[4],"$999,999,999.99" ) RIGHT
         UTILPRN ::oUtil 22.0, 1.5 SAY "LUGAR DONDE SE PRACTICO LA RETENCION : " FONT ::aFnt[1]
         UTILPRN ::oUtil 22.0,11.0 SAY TRIM( oApl:cCiu ) + "."
         UTILPRN ::oUtil 23.5, 1.5 SAY "No requiere firma : Art. 10 decreto 836/91"
         ENDPAGE
      EndIf
      ::aMV[4] := 0
   EndIf
EndDo
RETURN NIL