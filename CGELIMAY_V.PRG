// Programa.: CGELIMAY.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listado de Mayor y Balance Ajustado.
#include "Fivewin.ch"
#INCLUDE "Utilprn.CH"

MEMVAR oApl

PROCEDURE CgeLiMay()
   LOCAL oA, oDlg, oGet := ARRAY(6)
 oA := TLimay() ; oA:New()
DEFINE DIALOG oDlg TITLE oA:aTit[1] FROM 0, 0 TO 08,46
   @ 02,00 SAY "PERIODO [AAAAMM]"  OF oDlg RIGHT PIXEL SIZE 70,10
   @ 02,72 GET oGet[1] VAR oA:aLS[1] OF oDlg PICTURE "999999" SIZE 32,10 PIXEL;
      VALID NtChr( oA:aLS[1],"P" )
   @ 14,00 SAY "CLASE DE LISTADO"    OF oDlg RIGHT PIXEL SIZE 70,10
   @ 14,72 COMBOBOX oGet[2] VAR oA:aLS[2] ITEMS { "MS-DOS","Windows" };
      SIZE 48,90 OF oDlg PIXEL
   @ 14,124 CHECKBOX oGet[3] VAR oA:aLS[3] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 26,00 SAY "Escoja la Fuente"  OF oDlg RIGHT PIXEL SIZE 70,10
   @ 26,72 COMBOBOX oGet[4] VAR oA:cFont ITEMS oA:aFont SIZE 80,99 OF oDlg PIXEL;
      WHEN oA:aLS[2] > 1
   @ 40, 50 BUTTON oGet[5] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[5]:Disable(), oA:ArmarMOV( oDlg ), oDlg:End() ) PIXEL
   @ 40,100 BUTTON oGet[6] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 46, 02 SAY "[CGELIMAY]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT ( Empresa( .t. ) )
RETURN

//------------------------------------//
CLASS TLimay FROM TIMPRIME

 DATA aLS, aMV, aTit, hRes, nL
 DATA lTit INIT .T.
 METHOD NEW() Constructor
 METHOD ArmarMOV( oDlg )
 METHOD ListoDOS( oDlg )
 METHOD Lineas()
 METHOD Cabecera( lSep,nSpace )
 METHOD LBalance( aRA,aRS,lOK )

ENDCLASS

//------------------------------------//
METHOD NEW() CLASS TLimay
   LOCAL hDC := GetDC( 0 )
 ::aFont:= GetFontNames( hDC )
 ::aLS  := { NtChr( DATE(),"1" ),oApl:nTFor,.t.,"","" }
 ::aMV  := { 0,0,0,0,0,"","99,999,999,999.99" }
 ::aTit := { "LIBRO DE MAYOR Y BALANCE AJUSTADO","" }
 ::cFont := "Arial"
RETURN NIL

//------------------------------------//
METHOD ArmarMOV( oDlg ) CLASS TLimay
   LOCAL aV, cPerI, cPerF
 ::aTit[2] := NtChr( ::aLS[1],"F" )
 cPerI := STR( VAL( LEFT(::aLS[1],4) )-1,4 ) + "13"
 cPerF := If( RIGHT( ::aLS[1],2 ) == "13", STUFF( ::aLS[1],5,2,"12" ),;
              NtChr( ::aTit[2]-1,"1" ) )
 cPerF := If( cPerF < cPerI, cPerI, cPerF )
aV := "SELECT p.cuenta, p.nivel, p.nombre, SUM(c.valor_deb), SUM(c.valor_cre), 'S' "+;
      "FROM cgeplan p, cgeacumc c "                   +;
      "WHERE p.empresa = " + LTRIM(STR(oApl:nPUC))    +;
       " AND p.nivel > 0 AND p.estado = 'A'"          +;
       " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
       " AND LEFT(c.cuenta,p.nivel*2) = p.cuenta "
aV +=  " AND c.ano_mes >= " + xValToChar( cPerI )     +;
       " AND c.ano_mes <= " + xValToChar( cPerF )     +;
       " GROUP BY p.cuenta UNION " + STRTRAN( aV,"'S'","'M'" ) +;
       " AND c.ano_mes = "  + xValToChar( ::aLS[1] )  +;
       " GROUP BY p.cuenta ORDER BY cuenta"
::hRes := If( MSQuery( oApl:oMySql:hConnect,aV ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes ) ; RETURN NIL
EndIf
 ::aTit[2]:= NtChr( ::aTit[2],"6" )
If ::aLS[2] == 1
   ::ListoDOS( oDlg )
Else
   ::Init( ::aTit[1], .f. ,, !::aLS[3] )
   UTILPRN ::oUtil SELECT ::oFnt5
     PAGE
       ::Lineas()
     ENDPAGE
   IMPRIME END .F.
EndIf
 MSFreeResult( ::hRes )
RETURN NIL

//------------------------------------//
METHOD ListoDOS( oDlg ) CLASS TLimay
   LOCAL aRA, aRS, oRpt, lOK := .t.
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aTit[1],::aTit[2],;
         SPACE(71) + "M O V I M I E N T O S",;
         "--CUENTA--  -----NOMBRE DE LA CUENTA------    SALDO  ANTERIOR    " +;
         "D E B I T O S    C R E D I T O S         NUEVO  SALDO"},::aLS[3],,2 )
While ::nL > 0
   lOK := ::LBalance( @aRA,@aRS,lOK )
   If ::aMV[5] # 0 .OR. aRA[4] # 0 .OR.;
        aRA[5] # 0 .OR. aRA[6] # 0
      If aRA[2] == 1
         ::aMV[6] := oRpt:CPIBold
         oRpt:nL++
      EndIf
      oRpt:Titulo( 118 )
      oRpt:Say( oRpt:nL, 00,::aMV[6]+ aRA[1] + "  " + LEFT( aRA[3],30 ) )
      oRpt:Say( oRpt:nL, 44,TRANSFORM( ::aMV[5],::aMV[7] ) )
      oRpt:Say( oRpt:nL, 63,TRANSFORM(   aRA[4],::aMV[7] ) )
      oRpt:Say( oRpt:nL, 82,TRANSFORM(   aRA[5],::aMV[7] ) )
      oRpt:Say( oRpt:nL,101,TRANSFORM(   aRA[6],::aMV[7] ) )
      If aRA[2] == 1
         oRpt:Say( oRpt:nL,119,oRpt:CPIBoldN )
         oRpt:nL++
         ::aMV[1] += ::aMV[5]
         ::aMV[2] += aRA[4]
         ::aMV[3] += aRA[5]
         ::aMV[4] += aRA[6]
         ::aMV[6] := ""
      EndIf
      oRpt:nL++
   EndIf
   If lOK
      ::nL --
   Else
      aRA := aRS
   EndIf
EndDo
oRpt:Say(  oRpt:nL, 00,REPLICATE("_",118) )
oRpt:Say(++oRpt:nL, 12,"T O T A L E S ------->" )
oRpt:Say(  oRpt:nL, 44,TRANSFORM( ::aMV[1],::aMV[7] ) )
oRpt:Say(  oRpt:nL, 63,TRANSFORM( ::aMV[2],::aMV[7] ) )
oRpt:Say(  oRpt:nL, 82,TRANSFORM( ::aMV[3],::aMV[7] ) )
oRpt:Say(  oRpt:nL,101,TRANSFORM( ::aMV[4],::aMV[7] ) )
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD Lineas() CLASS TLimay
   LOCAL aRA, aRS, lOK := .t.
While ::nL > 0
   lOK := ::LBalance( @aRA,@aRS,lOK )
   If ::aMV[5] # 0 .OR. aRA[4] # 0 .OR.;
        aRA[5] # 0 .OR. aRA[6] # 0
      ::Cabecera( .t. )
      If aRA[2] == 1
         If ::nLinea > 4
            ::Cabecera( .t. )
         EndIf
         UTILPRN ::oUtil SELECT ::oFnt6
      EndIf
      UTILPRN ::oUtil Self:nLinea, 1.0 SAY aRA[1]
      UTILPRN ::oUtil Self:nLinea, 2.5 SAY LEFT(aRA[3],34)
      UTILPRN ::oUtil Self:nLinea,11.9 SAY TRANSFORM(::aMV[5],::aMV[7] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,14.6 SAY TRANSFORM(  aRA[4],::aMV[7] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,17.3 SAY TRANSFORM(  aRA[5],::aMV[7] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM(  aRA[6],::aMV[7] ) RIGHT
      If aRA[2] == 1
         UTILPRN ::oUtil SELECT ::oFnt5
         ::nLinea += .5
         ::aMV[1] += ::aMV[5]
         ::aMV[2] += aRA[4]
         ::aMV[3] += aRA[5]
         ::aMV[4] += aRA[6]
      EndIf
   EndIf
   If lOK
      ::nL --
   Else
      aRA := aRS
   EndIf
EndDo
UTILPRN ::oUtil LINEA Self:nLinea,1.0 TO Self:nLinea,20.0 PEN ::oPen
        ::nLinea += .5
UTILPRN ::oUtil Self:nLinea, 2.5 SAY "T O T A L E S ------->"
UTILPRN ::oUtil Self:nLinea,11.9 SAY TRANSFORM(::aMV[1],::aMV[7] ) RIGHT
UTILPRN ::oUtil Self:nLinea,14.6 SAY TRANSFORM(::aMV[2],::aMV[7] ) RIGHT
UTILPRN ::oUtil Self:nLinea,17.3 SAY TRANSFORM(::aMV[3],::aMV[7] ) RIGHT
UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM(::aMV[4],::aMV[7] ) RIGHT
RETURN NIL

//------------------------------------//
METHOD Cabecera( lSep,nSpace ) CLASS TLimay
If lSep .AND. !::lTit
   ::lTit := ::Separator( nSpace )
EndIf
If ::lTit
   ::Centrar( oApl:cEmpresa,::oFnt4,1.0 )
   UTILPRN ::oUtil 1.5, 0.5 SAY "FEC.PROC:"+DTOC( DATE() )
   UTILPRN ::oUtil 1.5, 8.2 SAY "NIT: " + oApl:oEmp:Nit
   UTILPRN ::oUtil 1.5,16.4 SAY "HORA: " + AmPm( TIME() )
   ::Centrar( ::aTit[1],,2.0 )
   UTILPRN ::oUtil 2.0,16.5 SAY "PAGINA" + STR(::nPage,4 )
   ::Centrar( ::aTit[2],,2.5 )

   UTILPRN ::oUtil 3.0,13.7 SAY "M O V I M I E N T O S"
   UTILPRN ::oUtil 3.5, 1.0 SAY "CUENTA"
   UTILPRN ::oUtil 3.5, 2.5 SAY "NOMBRE CUENTA"
   UTILPRN ::oUtil 3.5,11.9 SAY "SALDO ANTERIOR"  RIGHT
   UTILPRN ::oUtil 3.5,14.6 SAY "D E B I T O S"   RIGHT
   UTILPRN ::oUtil 3.5,17.3 SAY "C R E D I T O S" RIGHT
   UTILPRN ::oUtil 3.5,20.0 SAY "NUEVO  SALDO"    RIGHT
   UTILPRN ::oUtil LINEA 4.0,1.0 TO 4.0,20.0 PEN ::oPen
   ::lTit   := .F.
   ::nLinea := 4.0
EndIf
RETURN NIL

//------------------------------------//
METHOD LBalance( aRA,aRS,lOK ) CLASS TLimay
 If lOK
    aRA := MyReadRow( ::hRes )
    AEVAL( aRA, {| xV,nP | aRA[nP] := MyClReadCol( ::hRes,nP ) } )
 EndIf
 If (::nL --) > 1
    aRS := MyReadRow( ::hRes )
    AEVAL( aRS, {| xV,nP | aRS[nP] := MyClReadCol( ::hRes,nP ) } )
 Else
    aRS := aRA
 EndIf
 ::aMV[5] := 0
 If aRA[1] == aRS[1]
    If aRA[6] == "S"
       ::aMV[5] := aRA[4] - aRA[5]
       AEVAL( aRS, {|xV,nP| aRA[nP] := xV },4,2 )
    EndIf
    lOK := .t.
 Else
    If aRA[6] == "S"
       ::aMV[5] := aRA[4] - aRA[5]
       AEVAL( aRA, {|xV,nP| aRA[nP] := 0 },4,2 )
    EndIf
    lOK := .f.
 EndIf
 aRA[6] := ::aMV[5] + aRA[4] - aRA[5]
RETURN lOK