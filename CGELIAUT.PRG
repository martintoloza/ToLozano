// Programa.: CGELIAUT.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: COMPROBANTE DE DIARIO DE CONTABILIDAD
#include "Fivewin.ch"
#include "btnget.ch"
#INCLUDE "Utilprn.CH"

MEMVAR oApl

PROCEDURE CgeLiAut()
   LOCAL oDlg, oGet := ARRAY(12)
   LOCAL oFt, oM
 oFt := TFte()  ; oFt:New()
 oM  := TLiaut();  oM:New()
DEFINE DIALOG oDlg TITLE "COMPROBANTE DE DIARIO POR FUENTE" FROM 0, 0 TO 16,60
   @ 02,00 SAY "COMPROBANTE INICIAL" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 02,82 BTNGET oGet[1] VAR oM:aLS[1] OF oDlg PICTURE "99";
      ACTION EVAL({|| If(oFt:Mostrar(), (oM:aLS[1] := oFt:oDb:FUENTE,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)}) ;
      VALID EVAL( {|| If( oFt:oDb:Seek( {"fuente",oM:aLS[1]} )     ,;
            (oM:aLS[10] := oFt:oDb:DESCRIPCIO, oDlg:Update(), .t. ),;
            (MsgStop("Esta Fuente no Existe .."), .f.) ) } )        ;
      SIZE 32,10 PIXEL RESOURCE "BUSCAR"
   @ 02,116 SAY oM:aLS[10] OF oDlg PIXEL SIZE 120,10 UPDATE COLOR nRGB( 128,0,255 )
   @ 14, 00 SAY "COMPROBANTE   FINAL" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 14, 82 BTNGET oGet[2] VAR oM:aLS[2] OF oDlg PICTURE "99";
      ACTION EVAL({|| If(oFt:Mostrar(), (oM:aLS[2] := oFt:oDb:FUENTE,;
                        oGet[2]:Refresh(), oGet[2]:lValid(.f.)),)}) ;
      VALID EVAL( {|| If(oFt:oDb:Seek( {"fuente",oM:aLS[2]} )      ,;
            (oM:aLS[11] := oFt:oDb:DESCRIPCIO, oDlg:Update(), .t. ),;
            (MsgStop("Esta Fuente no Existe .."), .f.) ) } )        ;
      SIZE 32,10 PIXEL RESOURCE "BUSCAR"
   @ 14,116 SAY oM:aLS[11] OF oDlg PIXEL SIZE 120,10 UPDATE COLOR nRGB( 128,0,255 )
   @ 26, 00 SAY "PERIODO INICIAL"   OF oDlg RIGHT PIXEL SIZE 80,10
   @ 26, 82 GET oGet[3] VAR oM:aLS[3] OF oDlg PICTURE "999999" SIZE 32,10 PIXEL;
      VALID NtChr( oM:aLS[3],"P" )
   @ 38, 00 SAY "PERIODO   FINAL"   OF oDlg RIGHT PIXEL SIZE 80,10
   @ 38, 82 GET oGet[4] VAR oM:aLS[4] OF oDlg PICTURE "999999" SIZE 32,10 PIXEL;
      VALID NtChr( oM:aLS[4],"P" )
   @ 50, 00 SAY "Nivel [1/2/3/4]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 50, 82 COMBOBOX oGet[5] VAR oM:aLS[5] ITEMS { "Grupo(2)","Cuenta(4)","SubCuenta(6)","Auxiliar(8)" };
      SIZE 48,90 OF oDlg PIXEL
   @ 50,134 CHECKBOX oGet[6] VAR oM:aLS[6] PROMPT "REGISTRADO" OF oDlg ;
      SIZE 60,10 PIXEL
   @ 62, 00 SAY "Libro" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 62, 82 COMBOBOX oGet[7] VAR oM:aLS[9] ITEMS { "COLGAAP","IFRS" };
      SIZE 48,90 OF oDlg PIXEL;
      WHEN !EMPTY(oApl:oEmp:NIIF) .AND. oM:aLS[3] >= oApl:oEmp:NIIF
   @ 74, 00 SAY "TIPO DE IMPRESORA" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 74, 82 COMBOBOX oGet[8] VAR oM:aLS[7] ITEMS { "Matriz","Laser" };
      SIZE 48,90 OF oDlg PIXEL
   @ 74,134 CHECKBOX oGet[9] VAR oM:aLS[8] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,10 PIXEL
   @ 86, 00 SAY "Escoja la Fuente"  OF oDlg RIGHT PIXEL SIZE 80,10
   @ 86, 82 COMBOBOX oGet[10] VAR oM:cFont ITEMS oM:aFont SIZE 80,99 OF oDlg PIXEL;
      WHEN oM:aLS[7] > 1
   @ 100, 50 BUTTON oGet[11] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
       ( oGet[11]:Disable(), oM:ArmarMOV( oDlg ), oGet[11]:Enable(),;
         oGet[11]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 100,100 BUTTON oGet[12] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 106, 02 SAY "[CGELIAUT]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT ( Empresa( .t. ) )
oFt:Cerrar()
RETURN

CLASS TLiaut FROM TIMPRIME

 DATA aLS, aMV, aRes, hRes, nL

   METHOD NEW() Constructor
   METHOD ArmarMOV( oDlg )
   METHOD BuscaFte( lFte )
   METHOD ListoDOS( oDlg )
   METHOD Cabecera( lSep,nSpace )
   METHOD Lineas()
ENDCLASS

//------------------------------------//
METHOD NEW() CLASS TLiaut
   LOCAL hDC := GetDC( 0 )
 ::aFont := GetFontNames( hDC )
 ::aLS   := { 1,1,NtChr( DATE(),"1" ),NtChr( DATE(),"1" ),2,.f.,oApl:nTFor,.t.,1,"","" }
 ::aMV   := { 0,0,0,"#,###,###,###.##","F",0 }
 ::cFont := "Arial"
RETURN NIL

//------------------------------------//
METHOD ArmarMOV( oDlg ) CLASS TLiaut
   LOCAL cQry
oDlg:SetText( "<< ESPERE >> A C T U A L I Z A N D O" )
cQry := "SELECT c.fuente, LEFT(d.cuenta," + LTRIM(STR(::aLS[5]*2))+;
            ") CTA, SUM(d.valor_deb), SUM(d.valor_cre) " +;
        "FROM cgemovd d, cgemovc c "   +;
        "WHERE d.empresa  = c.empresa" +;
         " AND d.ano_mes  = c.ano_mes" +;
         " AND d.control  = c.control" +;
         " AND d.libro    = " + LTRIM(STR(::aLS[9]))     +;
         " AND c.empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.ano_mes >= " + xValToChar( ::aLS[3] )   +;
         " AND c.ano_mes <= " + xValToChar( ::aLS[4] )   +;
         " AND c.fuente  >= " + LTRIM(STR(::aLS[1]))     +;
         " AND c.fuente  <= " + LTRIM(STR(::aLS[2]))     +;
         " AND c.estado  <> 2"                           +;
         " GROUP BY c.fuente, CTA ORDER BY c.fuente, CTA"
::hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes )
   RETURN NIL
EndIf
 ::aMV[5] := NtChr( ::aLS[3],"F" )
 ::aMV[6] := CTOD( NtChr( NtChr( ::aLS[4],"F" ),"4" ) )
 ::aEnc := { .t.,"COMPROBANTE DE DIARIO DE CONTABILIDAD"+NtChr(::aLS[9],"CI" ),;
             "PERIODO DE : "+NtChr( ::aMV[5],"6" ) + " A " + NtChr( ::aMV[6],"6" ),"" }
 ::aRes := MyReadRow( ::hRes )
 AEVAL( ::aRes, {| xV,nP | ::aRes[nP] := MyClReadCol( ::hRes,nP ) } )
 ::BuscaFte( .t. )
If ::aLS[7] == 1
   ::ListoDOS( oDlg )
Else
   ::Init( ::aEnc[2], .f. ,, !::aLS[8] )
     PAGE
       ::Lineas()
     ENDPAGE
   IMPRIME END .F.
EndIf
MSFreeResult( ::hRes )
RETURN NIL

//------------------------------------//
METHOD BuscaFte( lFte ) CLASS TLiaut

If lFte
   ::aMV[3] := ::aRes[1]
   ::aEnc[4]:= STR(::aMV[3]) + "  " +;
               Buscar( { "fuente",::aMV[3] },"cgefntes","descripcio",8 )
Else
   ::aMV[6] := Buscar( { "empresa",oApl:nPUC,"cuenta",::aRes[2] },"cgeplan","nombre",8 )
EndIf
RETURN NIL

//------------------------------------//
METHOD ListoDOS( oDlg ) CLASS TLiaut
   LOCAL oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{::aEnc[2],::aEnc[3],::aEnc[4],;
         "CUENTA     NOMBRE CUENTA" + SPACE(29)+ "Debitos         Creditos"},::aLS[8] )
oRpt:lTimbrado := ::aLS[6]
While ::nL > 0
   ::BuscaFte( .f. )
   oRpt:Titulo( 79 )
   oRpt:Say( oRpt:nL,00,::aRes[2] )
   oRpt:Say( oRpt:nL,11,::aMV[6] )
   oRpt:Say( oRpt:nL,46,TRANSFORM( ::aRes[3],::aMV[4] ) )
   oRpt:Say( oRpt:nL,63,TRANSFORM( ::aRes[4],::aMV[4] ) )
   oRpt:nL ++
   ::aMV[1] += ::aRes[3]
   ::aMV[2] += ::aRes[4]
   If (::nL --) > 1
      ::aRes := MyReadRow( ::hRes )
      AEVAL( ::aRes, {| xV,nP | ::aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aMV[3] # ::aRes[1]
      oRpt:Say( oRpt:nL+2,19,"SUMAS IGUALES =========>  $" + ;
              TRANSFORM( ::aMV[1],::aMV[4] ) + " " + TRANSFORM( ::aMV[2],::aMV[4] ) )
      oRpt:NewPage()
      oRpt:nL := oRpt:nLength
      ::aMV[1] := ::aMV[2] := oRpt:nPage := 0
      ::BuscaFte( .t. )
      oRpt:aEnc[3] := ::aEnc[4]
   EndIf
EndDo
 oRpt:NewPage()
 oRpt:End()
RETURN NIL

//------------------------------------//
METHOD Cabecera( lSep,nSpace ) CLASS TLiaut
If lSep .AND. !::aEnc[1]
   ::aEnc[1] := ::Separator( nSpace )
EndIf
If ::aEnc[1]
   ::aEnc[1] := .F.
   If !::aLS[6]
      ::Centrar( oApl:cEmpresa,::aFnt[4],1.0 )
      UTILPRN ::oUtil 1.5, 8.2 SAY "NIT: " + oApl:oEmp:Nit
      ::FechaHora( 1.5, 0.5, 16.4 )
      ::Centrar( ::aEnc[2],,2.0 )
    //UTILPRN ::oUtil 2.0,16.5 SAY "PAGINA" + STR(::nPage,4 ) FONT ::aFnt[2]
   EndIf
      ::Centrar( ::aEnc[3],,2.5 )
      UTILPRN ::oUtil 3.0, 3.5 SAY ::aEnc[4]
      UTILPRN ::oUtil 3.5, 1.0 SAY "CUENTA"
      UTILPRN ::oUtil 3.5, 3.7 SAY "NOMBRE CUENTA"
      UTILPRN ::oUtil 3.5,16.3 SAY "DEBITOS"      RIGHT
      UTILPRN ::oUtil 3.5,20.0 SAY "CREDITOS"     RIGHT
      UTILPRN ::oUtil LINEA 4.0,1.0 TO 4.0,20.0 PEN ::oPen
   ::nLinea := 4.0
EndIf
RETURN NIL

//------------------------------------//
METHOD Lineas() CLASS TLiaut

While ::nL > 0
   ::BuscaFte( .f. )
   ::Cabecera( .t. )
   UTILPRN ::oUtil Self:nLinea,01.0 SAY ::aRes[2]
   UTILPRN ::oUtil Self:nLinea,03.7 SAY ::aMV[6]
   UTILPRN ::oUtil Self:nLinea,16.3 SAY TRANSFORM( ::aRes[3],::aMV[4] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM( ::aRes[4],::aMV[4] ) RIGHT
   ::aMV[1] += ::aRes[3]
   ::aMV[2] += ::aRes[4]
   If (::nL --) > 1
      ::aRes := MyReadRow( ::hRes )
      AEval( ::aRes, {| xV,nP | ::aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aMV[3] # ::aRes[1]
      ::Cabecera( .t.,1 )
      UTILPRN ::oUtil Self:nLinea,06.5 SAY "SUMAS IGUALES =========>  $"
      UTILPRN ::oUtil Self:nLinea,16.3 SAY TRANSFORM( ::aMV[1],::aMV[4] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM( ::aMV[2],::aMV[4] ) RIGHT
      ::nLinea := ::nEndLine + .5
      ::aMV[1] := ::aMV[2] := 0
      ::BuscaFte( .t. )
   EndIf
EndDo
RETURN NIL