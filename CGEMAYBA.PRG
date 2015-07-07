// Programa.: CGEMAYBA.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listado de Mayor y Balances
#include "Fivewin.ch"
#INCLUDE "Utilprn.CH"

MEMVAR oApl

PROCEDURE CgeMayba()
   LOCAL oDlg, oGet := ARRAY(9)
   LOCAL oM := TMayba()
 oM:New()
DEFINE DIALOG oDlg TITLE oM:aEnc[2] FROM 0, 0 TO 13,50
   @ 02,00 SAY "PERIODO [AAAAMM]"    OF oDlg RIGHT PIXEL SIZE 80,10
   @ 02,82 GET oGet[1] VAR oM:aLS[1] OF oDlg PICTURE "999999" SIZE 36,10 PIXEL;
      VALID NtChr( oM:aLS[1],"P" )
   @ 14,00 SAY "Nivel [1/2/3/4]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 14,82 COMBOBOX oGet[2] VAR oM:aLS[2] ITEMS { "Grupo(2)","Cuenta(4)","SubCuenta(6)","Auxiliar(8)" };
      SIZE 48,90 OF oDlg PIXEL
   @ 26,00 SAY "REGISTRADO"          OF oDlg RIGHT PIXEL SIZE 80,10
   @ 25, 82 CHECKBOX oGet[3] VAR oM:aLS[3] PROMPT " " OF oDlg SIZE 14,10 PIXEL
   @ 38,00 SAY "Libro" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 38,82 COMBOBOX oGet[9] VAR oM:aLS[6] ITEMS { "COLGAAP","IFRS" };
      SIZE 48,90 OF oDlg PIXEL;
      WHEN !EMPTY(oApl:oEmp:NIIF) .AND. oM:aLS[1] >= oApl:oEmp:NIIF
   @ 50, 00 SAY "TIPO DE IMPRESORA"  OF oDlg RIGHT PIXEL SIZE 80,10
   @ 50, 82 COMBOBOX oGet[4] VAR oM:aLS[4] ITEMS { "Matriz","Laser" };
      SIZE 48,90 OF oDlg PIXEL
   @ 50,134 CHECKBOX oGet[5] VAR oM:aLS[5] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 62,00 SAY "Escoja la Fuente"  OF oDlg RIGHT PIXEL SIZE 80,10
   @ 62,82 COMBOBOX oGet[6] VAR oM:cFont ITEMS oM:aFont SIZE 80,99 OF oDlg PIXEL;
      WHEN oM:aLS[4] > 1
   @ 76, 50 BUTTON oGet[7] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[7]:Disable(), oM:ArmarMOV( oDlg ), oDlg:End() ) PIXEL
   @ 76,100 BUTTON oGet[8] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 82, 02 SAY "[CGEMAYBA]" OF oDlg PIXEL SIZE 34,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT ( Empresa( .t. ) )
RETURN

//------------------------------------//
CLASS TMayba FROM TIMPRIME

 DATA aLS, aMV, aRes, hRes, nL

 METHOD NEW() Constructor
 METHOD ArmarMOV( oDlg )
 METHOD ListoDOS( oDlg )
 METHOD Lineas()
 METHOD Cabecera( lSep,nSpace,nSuma )
 METHOD LBalance( aRA,aRS,lOK )

ENDCLASS

//------------------------------------//
METHOD NEW() CLASS TMayba
   LOCAL hDC := GetDC( 0 )
 ::aFont := GetFontNames( hDC )
 ::aLS   := { NtChr( DATE(),"1" ),1,.f.,oApl:nTFor,.t.,1 }
 ::aMV   := { 0,0,0,0,0,0,0,0,"99,999,999,999.99" }
 ::aEnc  := { .t.,"LIBRO DE MAYOR Y BALANCES","" }
 ::cFont := "Arial"
RETURN NIL

//------------------------------------//
METHOD ArmarMOV( oDlg ) CLASS TMayba
   LOCAL aV, cPerI, cPerF
 ::aEnc[3]:= NtChr( ::aLS[1],"F" )
 cPerI := STR( VAL( LEFT(::aLS[1],4) )-1,4 ) + "13"
 cPerF := If( RIGHT( ::aLS[1],2 ) == "13", STUFF( ::aLS[1],5,2,"12" ),;
              NtChr( ::aEnc[3]-1,"1" ) )
 cPerF := If( cPerF < cPerI, cPerI, cPerF )
aV := "SELECT p.cuenta, p.nombre, SUM(c.valor_deb), SUM(c.valor_cre), 'B' tipo, 0 "+;
      "FROM cgeplan p, cgeacumc c "                   +;
      "WHERE p.empresa = " + LTRIM(STR(oApl:nPUC))    +;
       " AND p.nivel   = " + LTRIM(STR(::aLS[2]))     +;
       " AND p.estado  = 'A'"                         +;
       " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
       " AND LEFT(c.cuenta,p.nivel*2) = p.cuenta "    +;
       " AND c.libro   = " +       STR(::aLS[6],2)
//     " AND p.nivel = "   + LTRIM(STR(::aLS[2]/2))   +;
aV +=  " AND c.ano_mes >= " + xValToChar( cPerI )     +;
       " AND c.ano_mes <= " + xValToChar( cPerF )     +;
       " GROUP BY p.cuenta UNION ALL " + STRTRAN( aV,"'B'","'M'" )+;
       " AND c.ano_mes = "  + xValToChar( ::aLS[1] )  +;
       " GROUP BY p.cuenta ORDER BY cuenta, tipo"
::hRes := If( MSQuery( oApl:oMySql:hConnect,aV ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes ) ; RETURN NIL
EndIf
 ::aEnc[2] += NtChr( ::aLS[6],"CI" )
 ::aEnc[3] := NtChr( ::aEnc[3],"6" )
If ::aLS[4] == 1
   ::ListoDOS( oDlg )
Else
   ::Init( ::aEnc[2], .f. ,, !::aLS[5] ,,,, 5 )
     PAGE
       ::Lineas()
     ENDPAGE
   IMPRIME END .F.
EndIf
 MSFreeResult( ::hRes )
RETURN NIL

//------------------------------------//
METHOD ListoDOS( oDlg ) CLASS TMayba
   LOCAL aRA, aRS, oRpt, lOK := .t.
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[2],::aEnc[3],SPACE(34)+;
         "--------SALDO ANTERIOR--------      --------MOVTOS DEL MES--------      " +;
         "---------SALDO ACTUAL---------"  ,"  NOMBRE DE LA CUENTA" + SPACE(17)     +;
         "DEBITOS          CREDITOS           DEBITOS          CREDITOS           " +;
         "DEBITOS          CREDITOS"},::aLS[5],,2 )
oRpt:lTimbrado := ::aLS[3]
While ::nL > 0
   lOK := ::LBalance( @aRA,@aRS,lOK )
   If ::aMV[7] # 0 .OR. ::aMV[8] # 0 .OR. ;
        aRA[3] # 0 .OR.   aRA[4] # 0
      oRpt:Titulo( 136 )
      oRpt:Say( oRpt:nL, 00,TRIM(aRA[1]) + " " + LEFT(aRA[2],29) )
      oRpt:Say( oRpt:nL, 29,TRANSFORM( ::aMV[7],::aMV[9] ) )
      oRpt:Say( oRpt:nL, 47,TRANSFORM( ::aMV[8],::aMV[9] ) )
      oRpt:Say( oRpt:nL, 65,TRANSFORM(   aRA[3],::aMV[9] ) )
      oRpt:Say( oRpt:nL, 83,TRANSFORM(   aRA[4],::aMV[9] ) )
      oRpt:Say( oRpt:nL,101,TRANSFORM(   aRA[5],::aMV[9] ) )
      oRpt:Say( oRpt:nL,119,TRANSFORM(   aRA[6],::aMV[9] ) )
      oRpt:nL ++
      ::aMV[1] += ::aMV[7]
      ::aMV[2] += ::aMV[8]
      ::aMV[3] += aRA[3]
      ::aMV[4] += aRA[4]
      ::aMV[5] += aRA[5]
      ::aMV[6] += aRA[6]
   EndIf
   If lOK
      ::nL --
   Else
      aRA := aRS
   EndIf
EndDo
oRpt:nL += If( oRpt:nL+3 > oRpt:nLength, oRpt:nLength-oRpt:nL, 0 )
oRpt:Titulo( 136 )
oRpt:Say(  oRpt:nL, 29,"----------------- ----------------- -----------------"+;
                      " ----------------- ----------------- -----------------" )
oRpt:Say(++oRpt:nL, 29,TRANSFORM( ::aMV[1],::aMV[9] ) )
oRpt:Say(  oRpt:nL, 47,TRANSFORM( ::aMV[2],::aMV[9] ) )
oRpt:Say(  oRpt:nL, 65,TRANSFORM( ::aMV[3],::aMV[9] ) )
oRpt:Say(  oRpt:nL, 83,TRANSFORM( ::aMV[4],::aMV[9] ) )
oRpt:Say(  oRpt:nL,101,TRANSFORM( ::aMV[5],::aMV[9] ) )
oRpt:Say(  oRpt:nL,119,TRANSFORM( ::aMV[6],::aMV[9] ) )
oRpt:Say(++oRpt:nL, 29,"================= ================= ================="+;
                      " ================= ================= =================" )
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD Lineas() CLASS TMayba
   LOCAL aRA, aRS, lOK := .t.
While ::nL > 0
   lOK := ::LBalance( @aRA,@aRS,lOK )
   If ::aMV[7] # 0 .OR. ::aMV[8] # 0 .OR. ;
        aRA[3] # 0 .OR.   aRA[4] # 0
      ::Cabecera( .t. )
      UTILPRN ::oUtil Self:nLinea,01.0 SAY TRIM(aRA[1]) + " " + LEFT(aRA[2],29)
      UTILPRN ::oUtil Self:nLinea,09.1 SAY TRANSFORM( ::aMV[7],::aMV[9] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,11.4 SAY TRANSFORM( ::aMV[8],::aMV[9] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,13.7 SAY TRANSFORM(   aRA[3],::aMV[9] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,16.0 SAY TRANSFORM(   aRA[4],::aMV[9] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,18.3 SAY TRANSFORM(   aRA[5],::aMV[9] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,20.6 SAY TRANSFORM(   aRA[6],::aMV[9] ) RIGHT
      ::aMV[1] += ::aMV[7]
      ::aMV[2] += ::aMV[8]
      ::aMV[3] += aRA[3]
      ::aMV[4] += aRA[4]
      ::aMV[5] += aRA[5]
      ::aMV[6] += aRA[6]
   EndIf
   If lOK
      ::nL --
   Else
      aRA := aRS
   EndIf
EndDo
aRA := REPLICATE("-",20)
aRS := REPLICATE("=",13)
::Cabecera( .t.,0.5,1.5 )
UTILPRN ::oUtil Self:nLinea,09.1 SAY aRA RIGHT
UTILPRN ::oUtil Self:nLinea,11.4 SAY aRA RIGHT
UTILPRN ::oUtil Self:nLinea,13.7 SAY aRA RIGHT
UTILPRN ::oUtil Self:nLinea,16.0 SAY aRA RIGHT
UTILPRN ::oUtil Self:nLinea,18.3 SAY aRA RIGHT
UTILPRN ::oUtil Self:nLinea,20.6 SAY aRA RIGHT
::nLinea += 0.5
UTILPRN ::oUtil Self:nLinea,09.1 SAY TRANSFORM( ::aMV[1],::aMV[9] ) RIGHT
UTILPRN ::oUtil Self:nLinea,11.4 SAY TRANSFORM( ::aMV[2],::aMV[9] ) RIGHT
UTILPRN ::oUtil Self:nLinea,13.7 SAY TRANSFORM( ::aMV[3],::aMV[9] ) RIGHT
UTILPRN ::oUtil Self:nLinea,16.0 SAY TRANSFORM( ::aMV[4],::aMV[9] ) RIGHT
UTILPRN ::oUtil Self:nLinea,18.3 SAY TRANSFORM( ::aMV[5],::aMV[9] ) RIGHT
UTILPRN ::oUtil Self:nLinea,20.6 SAY TRANSFORM( ::aMV[6],::aMV[9] ) RIGHT
::nLinea += 0.5
UTILPRN ::oUtil Self:nLinea,09.1 SAY aRS RIGHT
UTILPRN ::oUtil Self:nLinea,11.4 SAY aRS RIGHT
UTILPRN ::oUtil Self:nLinea,13.7 SAY aRS RIGHT
UTILPRN ::oUtil Self:nLinea,16.0 SAY aRS RIGHT
UTILPRN ::oUtil Self:nLinea,18.3 SAY aRS RIGHT
UTILPRN ::oUtil Self:nLinea,20.6 SAY aRS RIGHT
RETURN NIL

//------------------------------------//
METHOD Cabecera( lSep,nSpace,nSuma ) CLASS TMayba
If lSep .AND. !::aEnc[1]
   ::aEnc[1] := ::Separator( nSpace,nSuma )
EndIf
If ::aEnc[1]
   ::aEnc[1] := .F.
   If !::aLS[3]
      ::Centrar( oApl:cEmpresa,::aFnt[4],1.0 )
      UTILPRN ::oUtil 1.5, 0.5 SAY "FEC.PROC:"+DTOC( DATE() ) FONT ::aFnt[2]
      UTILPRN ::oUtil 1.5, 8.2 SAY "NIT: " + oApl:oEmp:Nit    FONT ::aFnt[2]
      UTILPRN ::oUtil 1.5,16.4 SAY "HORA: " + AmPm( TIME() )  FONT ::aFnt[2]
      ::Centrar( ::aEnc[2],,2.0 )
    //UTILPRN ::oUtil 2.0,16.5 SAY "PAGINA" + STR(::nPage,4 ) FONT ::aFnt[2]
   EndIf
      ::Centrar( ::aEnc[3],,2.5 )
      UTILPRN ::oUtil 3.0,11.4 SAY "-------SALDO ANTERIOR-------" RIGHT
      UTILPRN ::oUtil 3.0,16.0 SAY "-------MOVTOS DEL MES-------" RIGHT
      UTILPRN ::oUtil 3.0,20.6 SAY "--------SALDO ACTUAL--------" RIGHT
      UTILPRN ::oUtil 3.5, 1.0 SAY "NOMBRE CUENTA"
      UTILPRN ::oUtil 3.5,09.1 SAY "DEBITOS"      RIGHT
      UTILPRN ::oUtil 3.5,11.4 SAY "CREDITOS"     RIGHT
      UTILPRN ::oUtil 3.5,13.7 SAY "DEBITOS"      RIGHT
      UTILPRN ::oUtil 3.5,16.0 SAY "CREDITOS"     RIGHT
      UTILPRN ::oUtil 3.5,18.3 SAY "DEBITOS"      RIGHT
      UTILPRN ::oUtil 3.5,20.6 SAY "CREDITOS"     RIGHT
      UTILPRN ::oUtil LINEA 4.0,1.0 TO 4.0,20.6 PEN ::oPen
   ::nLinea := 4.0
EndIf
RETURN NIL

//------------------------------------//
METHOD LBalance( aRA,aRS,lOK ) CLASS TMayba
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
 ::aMV[7] := ::aMV[8] := 0
 If aRA[1] == aRS[1]
    If aRA[5] == "B"
       ::aMV[7] := aRA[3] - aRA[4]
       If aRS[5] == "M"
          aRA[3] := aRS[3]
          aRA[4] := aRS[4]
       Else
          aRA[3] := aRA[4] := 0
       EndIf
    EndIf
    lOK := .t.
 Else
    If aRA[5] == "B"
       ::aMV[7] := aRA[3] - aRA[4]
       aRA[3] := aRA[4] := 0
    EndIf
    lOK := .f.
 EndIf
 If ::aMV[7] < 0
    ::aMV[8] := ::aMV[7] * -1
    ::aMV[7] := 0
 EndIf
 aRA[5] := ::aMV[7] - ::aMV[8] + aRA[3] - aRA[4]
 aRA[6] := 0
 If aRA[5] < 0
    aRA[6] := aRA[5] * -1
    aRA[5] := 0
 EndIf
RETURN lOK