// Programa.: CGESALDO.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Saldos de una Cuenta
#include "Fivewin.ch"
#include "Btnget.ch"
#INCLUDE "Utilprn.CH"

MEMVAR oApl

PROCEDURE CgeSaldo()
   LOCAL oDlg, oGet := ARRAY(10), oCt, oNi, oM, nP
 oCt := TPuc()  ; oCt:New()
 oNi := TNits() ; oNi:New()
 oM  := TSaldo();  oM:New()
DEFINE DIALOG oDlg TITLE "SALDOS MENSUALES" FROM 0, 0 TO 13,60
   @ 02, 00 SAY "CUENTA"   OF oDlg RIGHT PIXEL SIZE 60,10
   @ 02, 62 BTNGET oGet[1] VAR oM:aLS[1] OF oDlg PICTURE "9999999999"    ;
      VALID If( oCt:oDb:Seek( {"Empresa",oApl:nPuc,"Cuenta",oM:aLS[1]} ),;
              ( oM:aLS[2] := 0, oM:aLS[3] := SPACE(10)                  ,;
                oM:aLS[8] := InfAc( oCt:oDb,@nP,"NIT" )                 ,;
                If( (oM:aLS[09] := InfAc( oCt:oDb,@nP ))                ,;
                     oM:aLS[12] := TRIM( oCt:oDb:FldLoad( nP+5 ) ), )   ,;
                oM:aLS[10] := oCt:oDb:NOMBRE, oDlg:Update(), .t. )      ,;
              ( MsgStop( "Está Cuenta NO EXISTE !!!" ), .f. ) )          ;
      SIZE 52,10 PIXEL  RESOURCE "BUSCAR"                                ;
      ACTION EVAL({|| If( oCt:Mostrar(), (oM:aLS[1] := oCt:oDb:CUENTA   ,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
   @ 02,116 SAY oM:aLS[10] OF oDlg PIXEL SIZE 130,10 UPDATE COLOR nRGB( 128,0,255 )
   @ 14, 00 SAY "NIT o C.C." OF oDlg RIGHT PIXEL SIZE 60,10
   @ 14, 62 BTNGET oGet[2] VAR oM:aLS[2] OF oDlg PICTURE "9999999999" ;
      VALID EVAL( {|| If( EMPTY( oM:aLS[2] ), .t.                    ,;
              (If( oNi:oDb:Seek( {"Codigo",oM:aLS[2]} )              ,;
                 ( oM:aLS[11] := oNi:oDb:NOMBRE, oDlg:Update(), .t. ),;
                 ( MsgStop("Este Nit no Existe"), .f. ) )) ) } )      ;
      SIZE 52,10 PIXEL  RESOURCE "BUSCAR"                             ;
      ACTION EVAL({|| If(oNi:Mostrar(), (oM:aLS[2] := oNi:oDb:CODIGO ,;
                        oGet[2]:Refresh(), oGet[2]:lValid(.f.)),)})   ;
      WHEN oM:aLS[8]
   @ 14,116 SAY oM:aLS[11] OF oDlg PIXEL SIZE 100,20 UPDATE COLOR nRGB( 128,0,255 )
   @ 26, 00 SAY oM:aLS[12] OF oDlg RIGHT PIXEL SIZE 60,10 UPDATE
   @ 26, 62 GET oGet[3] VAR oM:aLS[3] OF oDlg PICTURE "@KB9"  SIZE 44,10 PIXEL;
      WHEN oM:aLS[9] UPDATE
   @ 38, 00 SAY "PERIODO [AAAA]" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 38, 62 GET oGet[4] VAR oM:aLS[4] OF oDlg PICTURE "9,999" SIZE 28,10 PIXEL;
      VALID oM:aLS[4] > 0
   @ 50, 00 SAY "Libro" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 50, 62 COMBOBOX oGet[5] VAR oM:aLS[7] ITEMS { "COLGAAP","IFRS" };
      SIZE 48,90 OF oDlg PIXEL;
      WHEN !EMPTY(oApl:oEmp:NIIF) .AND. oM:aLS[4] >= LEFT(oApl:oEmp:NIIF,4)
   @ 62, 00 SAY "TIPO DE IMPRESORA" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 62, 62 COMBOBOX oGet[6] VAR oM:aLS[5] ITEMS { "Matriz","Laser" };
      SIZE 48,90 OF oDlg PIXEL
   @ 62,116 CHECKBOX oGet[7] VAR oM:aLS[6] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 76, 50 BUTTON oGet[08] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[8]:Disable(), oM:ArmarMOV( oDlg ), oGet[8]:Enable(),;
        oGet[8]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 76,100 BUTTON oGet[09] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 76,150 BUTTON oGet[10] PROMPT "Revisar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[10]:Disable(), Vigente( STR(oM:aLS[4],4) ), oGet[10]:Enable(),;
        oGet[10]:oJump := oGet[4], oGet[4]:SetFocus() ) PIXEL
   @ 82, 02 SAY "[CGESALDO]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT Empresa( .t. )
oCt:Cerrar()
RETURN

//------------------------------------//
CLASS TSaldo FROM TIMPRIME

 DATA aLS, hRes, nL

 METHOD NEW( cTit ) Constructor
 METHOD ArmarMOV( oDlg,nOpc )
 METHOD Lineas( aRes,oRpt )
 METHOD Cabecera()
ENDCLASS

//------------------------------------//
METHOD NEW( cTit ) CLASS TSaldo
 ::aLS  := { SPACE(10),0,SPACE(10),YEAR( DATE() ),oApl:nTFor,.t.,1,.f.,.f.,"","","" }
 ::aEnc := { .t.,"SALDOS MENSUALES DE CUENTAS","","","" }
RETURN NIL

//------------------------------------//
METHOD ArmarMOV( oDlg ) CLASS TSaldo
   LOCAL aC := { "c ","" }, cQry, oRpt
If !EMPTY( ::aLS[2] ) .OR. !EMPTY( ::aLS[3] )
   ::aLS[2] := If( ::aLS[2] > 0, oApl:oNit:CODIGO_NIT, 0 )
   do Case
   Case ::aLS[2] > 0 .AND. EMPTY( ::aLS[3] )
      ::aLS[10] := "NIT : " + FormatoNit( oApl:oNit:CODIGO,oApl:oNit:DIGITO ) +;
                "  " + oApl:oNit:NOMBRE
   Case ::aLS[2] = 0 .AND. !EMPTY( ::aLS[3] )
      ::aLS[10] := "CODIGO : " + ::aLS[3] + "  " + ::aLS[10]
   OtherWise
      ::aLS[10] := "NIT : " + FormatoNit( oApl:oNit:CODIGO,oApl:oNit:DIGITO ) +;
                "  CODIGO : " + ::aLS[3]+ "  " + ::aLS[10]
   EndCase
   aC := { "n ",;
           " AND codigo = "    +xValToChar( ::aLS[3] ) +;
           " AND codigo_nit = "+xValToChar( ::aLS[2] ) }
EndIf
cQry := "SELECT ano_mes, SUM(valor_deb), SUM(valor_cre) "+;
        "FROM cgeacum" + aC[1]                           +;
        "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))   +;
       " AND LEFT(cuenta," + STR(LEN(TRIM(::aLS[1])),2)  +;
                    ") = " + xValToChar( ::aLS[1] )+aC[2]+;
        " AND ano_mes >= " + STR( ::aLS[4]-1,4 ) + "13"  +;
        " AND ano_mes <= " + STR( ::aLS[4]  ,4 ) + "12"  +;
        " AND libro    = " + STR( ::aLS[7]  ,2 )         +;
        " GROUP BY ano_mes ORDER BY ano_mes"
::hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes )
   RETURN NIL
EndIf
 ::aLS[2] := 0
 ::aLS[8] := .f.
 ::aLS[9] := "999,999,999,999.99"
 aC := MyReadRow( ::hRes )
 AEVAL( aC, { | xV,nP | aC[nP] := MyClReadCol( ::hRes,nP ) } )
 If RIGHT(aC[1],2) == "13"
    ::aLS[2] := aC[2] - aC[3]
    ::aLS[8] := .t.
    ::nL --
 EndIf
 ::aEnc[2] += NtChr( ::aLS[7],"CI" )
 ::aEnc[3] := "PERIODO : " + TRANSFORM( ::aLS[4],"9,999" )
 ::aEnc[4] := "CUENTA : " + ::aLS[1] + "  " + ::aLS[10]
 ::aEnc[5] := "SALDO ANTERIOR : " + TRANSFORM( ::aLS[2],::aLS[9] )
If ::aLS[5] == 1
   oRpt := TDosPrint()
   oRpt:New( oApl:cPuerto,oApl:cImpres,{::aEnc[2],::aEnc[3],::aEnc[4]," ",::aEnc[5],;
             SPACE(30) + "DEBITOS            CREDITOS        Saldo Actual"},::aLS[6] )
   oRpt:Titulo( 78 )
   ::Lineas( aC,oRpt )
   oRpt:NewPage()
   oRpt:End()
Else
   ::Init( ::aEnc[2], .f. ,, !::aLS[6] )
     PAGE
       ::Cabecera()
       ::Lineas( aC )
     ENDPAGE
   IMPRIME END .F.
   ::aEnc[1] := .T.
EndIf
 ::aEnc[2] := "SALDOS MENSUALES DE CUENTAS"
 ::aLS[8] := ::aLS[9] := .f.
RETURN NIL

//------------------------------------//
METHOD Lineas( aRes,oRpt ) CLASS TSaldo
   LOCAL aMes := {"Ene","Feb","Mar","Abr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dic" }
   LOCAL cPer
While ::nL > 0
   If ::aLS[8]
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If aRes[2] # 0 .OR. aRes[3] # 0
      ::aLS[2] += (aRes[2] - aRes[3])
      cPer := aMes[VAL(RIGHT(aRes[1],2))]
      If ::aLS[5] == 1
         oRpt:Say( oRpt:nL,01,aRes[1] + " - " + cPer )
         oRpt:Say( oRpt:nL,19,TRANSFORM(  aRes[2],::aLS[9] ) )
         oRpt:Say( oRpt:nL,39,TRANSFORM(  aRes[3],::aLS[9] ) )
         oRpt:Say( oRpt:nL,59,TRANSFORM( ::aLS[2],::aLS[9] ) )
         oRpt:nL ++
      Else
         UTILPRN ::oUtil Self:nLinea,01.2 SAY aRes[1] + " - " + cPer
         UTILPRN ::oUtil Self:nLinea,14.0 SAY TRANSFORM( aRes[2],::aLS[9] ) RIGHT
         UTILPRN ::oUtil Self:nLinea,17.0 SAY TRANSFORM( aRes[3],::aLS[9] ) RIGHT
         UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM(::aLS[2],::aLS[9] ) RIGHT
         ::nLinea += .5
      EndIf
   EndIf
   ::aLS[8] := .t.
   ::nL --
EndDo
RETURN NIL

//------------------------------------//
METHOD Cabecera() CLASS TSaldo

 ::Centrar( oApl:cEmpresa,::aFnt[4],1.0 )
 UTILPRN ::oUtil 1.5, 8.2 SAY "NIT: " + oApl:oEmp:Nit
 ::Centrar( ::aEnc[2],,2.0 )
 ::Centrar( ::aEnc[3],,2.5 )
 UTILPRN ::oUtil 3.0, 1.0 SAY ::aEnc[4]
 UTILPRN ::oUtil 3.5, 1.0 SAY ::aEnc[5]
 UTILPRN ::oUtil 3.5,14.0 SAY "DEBITOS"      RIGHT
 UTILPRN ::oUtil 3.5,17.0 SAY "CREDITOS"     RIGHT
 UTILPRN ::oUtil 3.5,20.0 SAY "Saldo Actual" RIGHT
 UTILPRN ::oUtil LINEA 4.0,1.0 TO 4.0,20.0 PEN ::oPen
 ::nLinea := 4.5
RETURN NIL

//------------------------------------//
FUNCTION SaldoCta( aCue,cPerF,cPerI,nD,nLib )
   LOCAL aRes, hRes, nL, cQry := " AND "
   DEFAULT cPerI := STR( VAL(LEFT(cPerF,4))-1,4 ) + "13", nD := 1, nLib := 1
FOR nL := 2 TO LEN( aCue )
   cQry += If( nL == 2, "codigo = ", "codigo_nit = " ) +;
           xValToChar( aCue[nL] ) + " AND "
NEXT
/*
AEVAL( oApl:aEmp, {| nE | aRes += LTRIM(STR(nE)) + ", " } )
aRes := LEFT( aRes,LEN(aRes)-2 )
aRes := If( AT(",",aRes) > 0, "IN (" + aRes + ")", " = " + aRes )
*/
cQry := "SELECT SUM(valor_deb), SUM(valor_cre) FROM cge" +;
          If( LEN( aCue ) == 1, "acumc", "acumn" )       +;
        " WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))  +;
        " AND LEFT(cuenta," + STR(LEN(TRIM(aCue[1])),2)  +;
                    ") = " + xValToChar( aCue[1] ) + cQry+;
            " ano_mes >= " + xValToChar( cPerI )         +;
        " AND ano_mes <= " + xValToChar( cPerF )         +;
        " AND libro    = " + STR(nLib,2)
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If MSNumRows( hRes ) > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   AADD( aRes, 0 )
   aRes[3] := If( nD == 1, (aRes[1]-aRes[2]), (aRes[2]-aRes[1]) )
Else
   aRes := { 0,0,0 }
EndIf
MSFreeResult( hRes )

RETURN aRes

//------------------------------------//
FUNCTION Vigente( cAno )
   LOCAL aRes, cQry, hRes, nL, oRpt
If LEN( cAno ) == 6
   aRes := { cAno,cAno }
Else
   aRes := { cAno+"01",cAno+"13" }
EndIf
cQry := "SELECT c.ano_mes, c.fuente, SUM(d.valor_deb), SUM(d.valor_cre) "+;
        "FROM cgemovc c LEFT JOIN cgemovd d "            +;
         "USING( empresa, ano_mes, control ) "           +;
        "WHERE c.empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.ano_mes >= '"+ aRes[1]                  +;
        "' AND c.ano_mes <= '"+ aRes[2]                  +;
        "' AND c.estado   = 0 "                          +;
        "GROUP BY c.ano_mes, c.fuente "                  +;
        "ORDER BY c.ano_mes, c.fuente"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   RETURN 0
EndIf
 oRpt := TDosPrint()
 oRpt:New( oApl:cPuerto,oApl:cImpres,{"PERIODOS SIN ACTUALIZAR","PERIODO : " + cAno,;
           "PERIODO  TIPO DE COMPROBANTE                   D E B I T O S    C R E D I T O S"},.t. )
 cAno := 0
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aRes[3] # 0 .OR. aRes[4] # 0
      cQry := Buscar( "SELECT descripcio FROM cgefntes WHERE fuente = "+;
                      LTRIM(STR(aRes[2])),"CM",,8 )
      oRpt:Titulo( 78 )
      oRpt:Say( oRpt:nL,01,aRes[1] + " - " + cQry )
      oRpt:Say( oRpt:nL,43,TRANSFORM( aRes[3],"999,999,999,999.99" ) )
      oRpt:Say( oRpt:nL,62,TRANSFORM( aRes[4],"999,999,999,999.99" ) )
      oRpt:nL ++
      cAno ++
   EndIf
   nL --
EnddO
MSFreeResult( hRes )
 oRpt:NewPage()
 oRpt:End()
RETURN cAno