// Programa.: CGERETEN.PRG    >>> Martin A. Toloza L. <<<
// Notas....: Certificado de Retencion en la Fuente.
#include "Fivewin.ch"
#include "btnget.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE CgeReten()
   LOCAL oDlg, oM, oNi, oGet := ARRAY(12)
 oM  := TReten();  oM:New()
 oNi := TNits() ; oNi:New()
oM:aLS[2] := Buscar( "SELECT MAX(codigo) FROM cadclien","CM",,8 )
DEFINE DIALOG oDlg TITLE "CERTIFICADO DE RETENCION" FROM 0, 0 TO 16,60
   @ 02,00 SAY "NIT INICIAL" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 02,72 BTNGET oGet[1] VAR oM:aLS[1] OF oDlg PICTURE "99999999999";
      VALID EVAL( {|| If( EMPTY( oM:aLS[1] ), .t.                   ,;
              (If( oNi:oDb:Seek( { "codigo",oM:aLS[1] } )           ,;
              ( oM:aLS[10] := oNi:oDb:NOMBRE, oDlg:Update(), .t. )  ,;
              ( MsgStop("Este Nit no Existe"),.f.)))) } )            ;
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"                            ;
      ACTION EVAL({|| If(oNi:Mostrar(), (oM:aLS[1] := oNi:oDb:CODIGO,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
   @ 02,130 SAY oM:aLS[10] OF oDlg PIXEL SIZE 160,10 UPDATE COLOR nRGB( 128,0,255 )
   @ 14,00 SAY "NIT   FINAL" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 14,72 BTNGET oGet[2] VAR oM:aLS[2] OF oDlg PICTURE "99999999999";
      VALID EVAL( {|| If( EMPTY( oM:aLS[2] ), .t.                   ,;
              (If( oNi:oDb:Seek( { "codigo",oM:aLS[2] } )           ,;
              ( oM:aLS[11] := oNi:oDb:NOMBRE, oDlg:Update(), .t. )  ,;
              ( MsgStop("Este Nit no Existe"),.f.)))) } )            ;
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"                            ;
      ACTION EVAL({|| If(oNi:Mostrar(), (oM:aLS[2] := oNi:oDb:CODIGO,;
                        oGet[2]:Refresh(), oGet[2]:lValid(.f.)),)})
   @ 14,130 SAY oM:aLS[11] OF oDlg PIXEL SIZE 160,10 UPDATE COLOR nRGB( 128,0,255 )
   @ 26,00 SAY "PERIODO INICIAL" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 26,72 GET oGet[3] VAR oM:aLS[3] OF oDlg PICTURE "999999" SIZE 32,10 PIXEL;
      VALID NtChr( oM:aLS[3],"P" )
   @ 38,00 SAY "PERIODO   FINAL" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 38,72 GET oGet[4] VAR oM:aLS[4] OF oDlg PICTURE "999999" SIZE 32,10 PIXEL;
      VALID NtChr( oM:aLS[4],"P" )
   @ 38,120 SAY "TIPO DE IMFORME"    OF oDlg RIGHT PIXEL SIZE 50,10
   @ 38,172 COMBOBOX oGet[12] VAR oM:aLS[9] ITEMS { "Certificado","Relación" };
      SIZE 48,90 OF oDlg PIXEL
   @ 50,00 SAY "Retención"      OF oDlg RIGHT PIXEL SIZE 70,10
   @ 50,72 COMBOBOX oGet[5] VAR oM:aLS[5] ITEMS oM:aRet SIZE 60,99 OF oDlg PIXEL
   @ 62,00 SAY "Libro" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 62,72 COMBOBOX oGet[6] VAR oM:aLS[8] ITEMS { "COLGAAP","IFRS" };
      SIZE 48,90 OF oDlg PIXEL;
      WHEN !EMPTY(oApl:oEmp:NIIF) .AND. oM:aLS[3] >= oApl:oEmp:NIIF
   @ 74,00 SAY "TIPO DE IMPRESORA"   OF oDlg RIGHT PIXEL SIZE 70,10
   @ 74,72 COMBOBOX oGet[7] VAR oM:aLS[6] ITEMS { "Matriz","Laser" };
      SIZE 48,90 OF oDlg PIXEL
   @ 74,124 CHECKBOX oGet[8] VAR oM:aLS[7] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,10 PIXEL
   @ 86,00 SAY "Escoja la Fuente"  OF oDlg RIGHT PIXEL SIZE 70,10
   @ 86,72 COMBOBOX oGet[9] VAR oM:cFont ITEMS oM:aFont SIZE 80,99 OF oDlg PIXEL;
      WHEN oM:aLS[6] > 1

   @ 100, 50 BUTTON oGet[10] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[10]:Disable(), oM:ArmarMOV( oDlg ), oGet[10]:Enable(),;
        oGet[10]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 100,100 BUTTON oGet[11] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 104, 02 SAY "[CGERETEN]" OF oDlg PIXEL SIZE 34,10
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
   METHOD DOSCerti( oRpt )
   METHOD DOSRelac( oRpt )
   METHOD LaserCer()
   METHOD LaserRel()
ENDCLASS

//------------------------------------//
METHOD NEW() CLASS TReten
   LOCAL hDC := GetDC( 0 )
 ::aFont := GetFontNames( hDC )
 ::cFont := STR( YEAR(DATE())-1,4 )
 ::aLS   := { 0,99,::cFont+"01",::cFont+"12",1,oApl:nTFor,.t.,1,1,"","" }
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
   LOCAL cQry := ::aLS, oTB
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
        "SELECT n.codigo, n.digito, n.nombre, d.cuenta, " +;
               "CAST(SUM(d.infd) AS UNSIGNED INTEGER), "  +;
               "d.ptaje, SUM(d.valor_deb), SUM(d.valor_cre) "+;
         "FROM cgemovc c, cgemovd d LEFT JOIN cadclien n" +;
         " USING( codigo_nit ) "                          +;
         "WHERE d.empresa  = c.empresa"                   +;
          " AND d.ano_mes  = c.ano_mes"                   +;
          " AND d.control  = c.control AND c.estado <> 2" +;
          " AND d.empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
          " AND d.cuenta  >= '23'"                        +;
          " AND d.cuenta  <= '23999999'"                  +;
          " AND d.ano_mes >= " + xValToChar( ::aLS[3] )   +;
          " AND d.ano_mes <= " + xValToChar( ::aLS[4] )   +;
          " AND d.libro    = " +        STR( ::aLS[8],2)  +;
         " GROUP BY n.codigo, d.cuenta, d.ptaje"
If !MSQuery( oApl:oMySql:hConnect,cQry )
   oApl:oMySql:oError:Display( .f. )
Else
   ::hRes := MSStoreResult( oApl:oMySql:hConnect )
   ::nL   := MSAffectedRows( oApl:oMySql:hConnect )
   MSFreeResult( ::hRes )
 //  MsgInfo( STR(::nL)+" Registros Insertados" )
EndIf

/*
cQry := { { "row_id"   , "N", 11, 00, " auto_increment PRIMARY KEY" },;
          { "codigo"   , "N", 12, 00, },;
          { "digito"   , "N", 01, 00, },;
          { "nombre"   , "C", 40, 00, },;
          { "cuenta"   , "C", 10, 00, },;
          { "base"     , "N", 14, 02, },;
          { "ptaje"    , "N", 06, 02, },;
          { "debito"   , "N", 14, 02, },;
          { "credito"  , "N", 14, 02, } }
If oApl:oDb:ExistTable( "retencion" )
   MSQuery( oApl:oMySql:hConnect,"DELETE FROM retencion" )
Else
   oTB := TMSTable():Create( oApl:oMySql, "retencion", cQry )
   oTB:Destroy()
EndIf
cQry := "SELECT n.codigo, n.digito, n.nombre, d.cuenta, " +;
               "d.ptaje, SUM(d.valor_deb), SUM(d.valor_cre) "+;
         "FROM cgemovc c, cgemovd d LEFT JOIN cadclien n" +;
         " USING( codigo_nit ) "                          +;
         "WHERE d.empresa  = c.empresa"                   +;
          " AND d.ano_mes  = c.ano_mes"                   +;
          " AND d.control  = c.control AND c.estado <> 2" +;
          " AND d.empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
          " AND d.cuenta  >= '23'"                        +;
          " AND d.cuenta  <= '23999999'"                  +;
          " AND d.ano_mes >= " + xValToChar( ::aLS[3] )   +;
          " AND d.ano_mes <= " + xValToChar( ::aLS[4] )   +;
         " GROUP BY n.codigo, d.cuenta, d.ptaje"
::hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR","PASO 1" )
   MSFreeResult( ::hRes )
   RETURN NIL
EndIf
MsgInfo( STR(::nL),"PASO 1" )
While ::nL > 0
   ::aRes := MyReadRow( ::hRes )
   AEVAL( ::aRes, {| xV,nP | ::aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   If ::aRes[1] >= ::aLS[1] .AND.;
      ::aRes[1] <= ::aLS[2]
      cQry := "INSERT INTO retencion VALUES ( null, "           +;
          LTRIM(STR(::aRes[1])) +  ", " + LTRIM(STR(::aRes[2])) +  ", '"  +;
               TRIM(::aRes[3])  + "', '"+      TRIM(::aRes[4])  + "', 0, "+;
          LTRIM(STR(::aRes[5])) + ", "  + LTRIM(STR(::aRes[6])) +  ", "   +;
          LTRIM(STR(::aRes[7])) + " )"
      If !MSQuery( oApl:oMySql:hConnect,cQry )
         oApl:oMySql:oError:Display( .f. )
      EndIf
   EndIf
   ::nL --
EndDo
   MSFreeResult( ::hRes )
cQry := "SELECT r.nombre, r.codigo, r.digito, r.cuenta, b.nombre, "  +;
               "r.ptaje, b.porcentaje, r.base, r.credito - r.debito "+;
        "FROM retencion r, cgereten b "             +;
        "WHERE b.cuenta  = LEFT(r.cuenta,6)"        +;
         " AND b.empresa = "+ LTRIM(STR(oApl:nPuc)) +;
         " AND b.clase   = "+ LTRIM(STR(::aLS[5]))  +;
         " ORDER BY r.codigo, r.cuenta, r.ptaje"
*/
cQry := "SELECT r.nombre, r.codigo, r.digito, r.cuenta, b.nombre, "  +;
               "r.ptaje, b.porcentaje, r.base, r.credito - r.debito "+;
        "FROM retencion r, cgereten b "             +;
        "WHERE r.codigo >= "+ LTRIM(STR(::aLS[1]))  +;
         " AND r.codigo <= "+ LTRIM(STR(::aLS[2]))  +;
         " AND b.cuenta  = LEFT(r.cuenta,6)"        +;
         " AND b.empresa = "+ LTRIM(STR(oApl:nPuc)) +;
         " AND b.clase   = "+ LTRIM(STR(::aLS[5]))  +;
         " ORDER BY r.codigo, r.cuenta, r.ptaje"
::hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR","PASO 2" )
   MSFreeResult( ::hRes )
  // MSQuery( oApl:oMySql:hConnect,"DROP TABLE retencion" )
   RETURN NIL
EndIf
oDlg:SetText( "<< ESPERE >> A C T U A L I Z A N D O" )

 ::aMV[6] := NtChr( ::aLS[4],"F" )
 ::aMV[6] := DTOC( NtChr( ::aLS[3],"F" ) ) + "  AL  " +;
                   NtChr( ::aMV[6],"4" )
// ::aMV[6] := RIGHT( NtChr( NtChr( ::aLS[3],"F" ),"6" ),5 )
 ::aMV[8] := "CERTIFICADO DE RETENCION " + UPPER( ::aRet[ ::aLS[5] ] )
 ::aRes := MyReadRow( ::hRes )
 AEVAL( ::aRes, {| xV,nP | ::aRes[nP] := MyClReadCol( ::hRes,nP ) } )
If ::aLS[6] == 1
   oTB := TDosPrint()
   If ::aLS[9] == 1
      ::DOSCerti( oTB )
   Else
      ::DOSRelac( oTB )
   EndIf
Else
   ::Init( ::aMV[8], .f. ,, !::aLS[7] ,,,, {2,5}[::aLS[9]] )
   If ::aLS[9] == 1
      ::LaserCer()
   Else
      ::LaserRel()
   EndIf
   IMPRIME END .F.
   ::lTit   := .T.
EndIf
 MSFreeResult( ::hRes )
 MSQuery( oApl:oMySql:hConnect,"DROP TABLE retencion" )
//oApl:oDb:GetTables()
RETURN NIL

//------------------------------------//
METHOD BuscaFte( lFte ) CLASS TReten
    ::aRes[9] := ::aRes[9] * If( LEFT( ::aRes[4],6 ) == "510506", -1, 1 )
 If ::aRes[6] >  1 .AND. LEFT( ::aRes[4],6 ) == "236801"
    ::aRes[6] := ::aRes[6] / 10
 ElseIf ::aRes[6] == 0
    ::aRes[6] := If( ::aRes[7] == 0, 1, ::aRes[7]*100 )
 EndIf
    ::aRes[8] := ROUND( ::aRes[9]*100 / ::aRes[6],2 )
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
METHOD DOSCerti( oRpt ) CLASS TReten

oRpt:New( oApl:cPuerto,oApl:cImpres,,::aLS[7] )
oRpt:nPage := 1
While ::nL > 0
   If ::aRes[9]  # 0
      ::BuscaFte( .f. )
      If ::aMV[1]  # ::aRes[2]
         ::aMV[1] := ::aRes[2]
         oRpt:Say(  2,00,oRpt:CPILarge+PADC( oApl:cEmpresa,43 ) )
         oRpt:Say(  3,00,oRpt:CPILarge+PADC( ::aMV[5],43 ) )
         oRpt:Say(  4,00,oRpt:CPIBold+PADC( "NIT: " + TRIM(oApl:oEmp:NIT),79 ) )
         oRpt:Say(  5,00,::aMV[7] )
         oRpt:Say(  6,00,PADC( TRIM(oApl:oEmp:DIRECCION),79 ) )
         oRpt:Say(  7,21,"Tels. "+ oApl:oEmp:TELEFONO + "  Fax " +  oApl:oEmp:FAX )
         oRpt:Say( 10,00,oRpt:CPIBold+ ::aMV[8] +oRpt:CPIBoldN )
         oRpt:Say( 14,00,"CERTIFICAMOS QUE RETUVIMOS A :" )
         oRpt:Say( 14,32,oRpt:CPIBold + ::aRes[1] + oRpt:CPIBoldN )
         oRpt:Say( 15,00,"NIT " + FormatoNit( ::aRes[2],::aRes[3] ) +;
                         "  DURANTE EL PERIODO " + ::aMV[6] )
         oRpt:Say( 18,00,"LOS SIGUIENTES VALORES :" )
         oRpt:Say( 21,44,oRpt:CPIBold+" BASE SOMETIDA" )
         oRpt:Say( 22,00,"CONCEPTO" + SPACE(30) + "%    A LA RETENCION   VALOR RETENIDO"+oRpt:CPIBoldN )
         oRpt:Say( 23,00,"--------" + SPACE(28) + "------ --------------   --------------" )
         oRpt:nL := 24
      EndIf
         oRpt:Say( oRpt:nL,00,::aRes[5] )
         oRpt:Say( oRpt:nL,36,TRANSFORM( ::aRes[6],"@Z 999.99" ) )
         oRpt:Say( oRpt:nL,45,TRANSFORM( ::aRes[8],"$999,999,999" ) )
         oRpt:Say( oRpt:nL,59,TRANSFORM( ::aRes[9],"$999,999,999.99" ) )
         oRpt:nL ++
      ::aMV[4] += ::aRes[9]
   EndIf
   If (::nL --) > 1
      ::aRes := MyReadRow( ::hRes )
      AEVAL( ::aRes, { | xV,nP | ::aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aMV[1] # ::aRes[2]
      If ::aMV[4] # 0
         oRpt:Say( 43,25,"VALOR DE LA RETENCION =======>" )
         oRpt:Say( 43,59,TRANSFORM( ::aMV[4],"$999,999,999.99" ) )
      // oRpt:Say( 46,00,"EL VALOR RETENIDO FUE CONSIGNADO OPORTUNAMENTE EN LA" )
      // oRpt:Say( 47,00,"ADMINISTRACION DE IMPUESTOS NACIONAL O DISTRITAL EN LA" )
      // oRpt:Say( 48,00,"CIUDAD DE " + TRIM( oApl:cCiu ) )
         oRpt:Say( 46,00,oRpt:CPIBold+"LUGAR DONDE SE PRACTICO LA RETENCION : " + oRpt:CPIBoldN +;
                    TRIM( oApl:cCiu ) + "." )
         oRpt:Say( 48,00,"FECHA DE EXPEDICION  " + NtChr( DATE(),"2" ) )
         oRpt:Say( 50,00,"NOTA : EL PRESENTE CERTIFICADO ANULA Y REMPLAZA LOS CERTIFICADOS" )
         oRpt:Say( 51,00,"DE RETENCION PARCIAL Y/O TOTAL QUE HAYAN SIDO EXPEDIDOS POR EL" )
         oRpt:Say( 52,00,"MISMO CONCEPTO Y PERIODO" )
         oRpt:Say( 53,10,"SIN FIRMA AUTOGRAFA SEGUN Art. 10 decreto 836/91" )
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
METHOD DOSRelac( oRpt ) CLASS TReten

oRpt:New( oApl:cPuerto,oApl:cImpres,{ STRTRAN(::aMV[8],"CERTIFICADO","LISTADO"),;
         ::aMV[6],"      NIT o CC  N O M B R E                     "+;
         "A LA RETENCION                  VALOR RETENIDO" },::aLS[7],,2 )
//9999,999,999-0  123456789012345678901234567890 12345678901234567890          999,999,999.99  999,999,999.99
While ::nL > 0
   If ::aRes[9]  # 0
      ::BuscaFte( .f. )
      oRpt:Titulo( 113 )
      If ::aMV[1]  # ::aRes[2]
         ::aMV[1] := ::aRes[2]
         oRpt:Say( oRpt:nL,00,FormatoNit( ::aRes[2],::aRes[3] ) )
         oRpt:Say( oRpt:nL,16,::aRes[1] )
      EndIf
      oRpt:Say( oRpt:nL,48,::aRes[5] )
      oRpt:Say( oRpt:nL,80,TRANSFORM( ::aRes[9],"999,999,999.99" ) )
      oRpt:nL ++
      ::aMV[4] += ::aRes[9]
   EndIf
   If (::nL --) > 1
      ::aRes := MyReadRow( ::hRes )
      AEVAL( ::aRes, { | xV,nP | ::aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aMV[1] # ::aRes[2]
      If ::aMV[4] # 0
         oRpt:Say( oRpt:nL-1,98,TRANSFORM( ::aMV[4],"$999,999,999.99" ) )
      EndIf
      ::aMV[4] := 0
   EndIf
EndDo
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserCer() CLASS TReten

While ::nL > 0
   If ::aRes[9]  # 0
      ::BuscaFte( .f. )
      If ::aMV[1]  # ::aRes[2]
         ::aMV[1] := ::aRes[2]
         PAGE
         ::Centrar( oApl:cEmpresa,::aFnt[4],1.0 )
         ::Centrar( ::aMV[5]     ,::aFnt[4],2.0 )
         ::Centrar( "NIT: " + TRIM(oApl:oEmp:NIT),,2.8 )
         ::Centrar( ::aMV[7],,3.4 )
         ::Centrar( TRIM(oApl:oEmp:DIRECCION),,4.0 )
         ::Centrar( "Tels. "+ oApl:oEmp:TELEFONO + "  Fax " +  oApl:oEmp:FAX,,4.6 )

         UTILPRN ::oUtil 07.0, 1.5 SAY ::aMV[8] FONT ::aFnt[1]
         UTILPRN ::oUtil 09.0, 1.5 SAY "CERTIFICAMOS QUE RETUVIMOS A :"
         UTILPRN ::oUtil 09.0, 7.8 SAY ::aRes[1] FONT ::aFnt[1]
         UTILPRN ::oUtil 09.5, 1.5 SAY "NIT " + FormatoNit( ::aRes[2],::aRes[3] ) +;
                                       "  DURANTE EL PERIODO " + ::aMV[6]
         UTILPRN ::oUtil 11.0, 1.5 SAY "LOS SIGUIENTES VALORES :"
         UTILPRN ::oUtil 12.5,13.0 SAY "BASE SOMETIDA"       FONT ::aFnt[1] RIGHT
         UTILPRN ::oUtil 13.0, 1.5 SAY "CONCEPTO"
         UTILPRN ::oUtil 13.0,13.0 SAY "%    A LA RETENCION" FONT ::aFnt[1] RIGHT
         UTILPRN ::oUtil 13.0,17.0 SAY "VALOR RETENIDO"      FONT ::aFnt[1] RIGHT
         UTILPRN ::oUtil SELECT ::aFnt[2]
         UTILPRN ::oUtil 13.1, 1.5 SAY "_____________"
         UTILPRN ::oUtil 13.1, 9.0 SAY "______ ______________            ______________"
         ::nLinea := 14.0
      EndIf
      UTILPRN ::oUtil Self:nLinea, 1.5 SAY ::aRes[5]
      UTILPRN ::oUtil Self:nLinea,10.0 SAY TRANSFORM( ::aRes[6],"@Z 999.99" )       RIGHT
      UTILPRN ::oUtil Self:nLinea,13.0 SAY TRANSFORM( ::aRes[8],"$999,999,999" )    RIGHT
      UTILPRN ::oUtil Self:nLinea,17.0 SAY TRANSFORM( ::aRes[9],"$999,999,999.99" ) RIGHT
      ::nLinea += 0.5
      ::aMV[4] += ::aRes[9]
   EndIf
   If (::nL --) > 1
      ::aRes := MyReadRow( ::hRes )
      AEVAL( ::aRes, { | xV,nP | ::aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aMV[1] # ::aRes[2]
      If ::aMV[4] # 0
         UTILPRN ::oUtil 20.0,08.0 SAY "VALOR DE LA RETENCION =======>"
         UTILPRN ::oUtil 20.0,17.0 SAY TRANSFORM( ::aMV[4],"$999,999,999.99" ) RIGHT
         UTILPRN ::oUtil 21.5, 1.5 SAY "LUGAR DONDE SE PRACTICO LA RETENCION : " FONT ::aFnt[1]
         UTILPRN ::oUtil 21.5,10.0 SAY TRIM( oApl:cCiu ) + "."
         UTILPRN ::oUtil 22.5, 1.5 SAY "FECHA DE EXPEDICION  " + NtChr( DATE(),"2" )
         UTILPRN ::oUtil 23.5, 2.5 SAY "NOTA : EL PRESENTE CERTIFICADO ANULA Y REMPLAZA LOS CERTIFICADOS"
         UTILPRN ::oUtil 24.0, 2.5 SAY "DE RETENCION PARCIAL Y/O TOTAL QUE HAYAN SIDO EXPEDIDOS POR EL"
         UTILPRN ::oUtil 24.5, 2.5 SAY "MISMO CONCEPTO Y PERIODO."
         UTILPRN ::oUtil 25.0, 4.5 SAY "SIN FIRMA AUTOGRAFA SEGUN Art. 10 decreto 836/91"
         ENDPAGE
      EndIf
      ::aMV[4] := 0
   EndIf
EndDo
RETURN NIL

//------------------------------------//
METHOD LaserRel() CLASS TReten
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit                    ,;
             STRTRAN(::aMV[8],"CERTIFICADO","LISTADO"), ::aMV[6]  ,;
             { .T., 2.8,"NIT o CC" }  , { .F., 3.1,"N O M B R E" },;
             { .F.,10.0,"A LA RETENCION" }, { .T.,18.0,"VALOR RETENIDO" } }
 ::nMD := 20.8
   PAGE
While ::nL > 0
   If ::aRes[9]  # 0
      ::BuscaFte( .f. )
      ::Cabecera( .t.,0.45 )
      If ::aMV[1]  # ::aRes[2]
         ::aMV[1] := ::aRes[2]
         UTILPRN ::oUtil Self:nLinea, 2.8 SAY FormatoNit( ::aRes[2],::aRes[3] ) RIGHT
         UTILPRN ::oUtil Self:nLinea, 3.1 SAY ::aRes[1]
      EndIf
      UTILPRN ::oUtil Self:nLinea,10.0 SAY ::aRes[5]
      UTILPRN ::oUtil Self:nLinea,18.0 SAY TRANSFORM( ::aRes[9],"999,999,999.99" ) RIGHT
      ::aMV[4] += ::aRes[9]
   EndIf
   If (::nL --) > 1
      ::aRes := MyReadRow( ::hRes )
      AEVAL( ::aRes, { | xV,nP | ::aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aMV[1] # ::aRes[2]
      If ::aMV[4] # 0
         UTILPRN ::oUtil Self:nLinea,20.8 SAY TRANSFORM( ::aMV[4],"999,999,999.99" ) RIGHT
      EndIf
      ::aMV[4] := 0
   EndIf
EndDo
   ENDPAGE
RETURN NIL