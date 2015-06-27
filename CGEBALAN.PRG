// Programa.: CGEBALAN.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Balance de Pruebas
#include "Fivewin.ch"
#INCLUDE "Utilprn.CH"

MEMVAR oApl

PROCEDURE CgeBalan( nOpc )
   LOCAL oB, oDlg, oGet := ARRAY(10)
   DEFAULT nOpc := 1
If VALTYPE( nOpc ) == "L"
   nOpc := If( nOpc, 2, 1 )
EndIf
 oB := TBalan()
 oB:New( nOpc )
DEFINE DIALOG oDlg TITLE oB:aEnc[2] FROM 0, 0 TO 13,46
   @ 02, 00 SAY "PERIODO INICIAL"  OF oDlg RIGHT PIXEL SIZE 70,10
   @ 02, 72 GET oGet[1] VAR oB:aLS[2] OF oDlg PICTURE "999999" SIZE 28,10 PIXEL;
      VALID NtChr( oB:aLS[2],"P" );
      WHEN nOpc == 2
   @ 02,110 SAY "Periodos Diferentes Imprime Balance General Comparativo";
      OF oDlg PIXEL SIZE 80,30
   @ 14, 00 SAY "PERIODO   FINAL"  OF oDlg RIGHT PIXEL SIZE 70,10
   @ 14, 72 GET oGet[2] VAR oB:aLS[4] OF oDlg PICTURE "999999" SIZE 28,10 PIXEL;
      VALID NtChr( oB:aLS[4],"P" )
   @ 26, 00 SAY "NIVEL [1/2/3/4]"  OF oDlg RIGHT PIXEL SIZE 70,10
   @ 26, 72 COMBOBOX oGet[3] VAR oB:aLS[5] ITEMS { "Grupo(2)","Cuenta(4)","SubCuenta(6)","Auxiliar(8)" };
      SIZE 48,90 OF oDlg PIXEL
// @ 26, 72 GET oGet[3] VAR oB:aLS[5] OF oDlg PICTURE "9" SIZE 08,10 PIXEL;
//    VALID Rango( oB:aLS[5],2,4 )
   @ 38, 00 SAY "REGISTRADO"       OF oDlg RIGHT PIXEL SIZE 70,10
   @ 37, 72 CHECKBOX oGet[4] VAR oB:aLS[6] PROMPT " " OF oDlg SIZE 14,10 PIXEL
   @ 37,134 CHECKBOX oGet[5] VAR oB:aLS[7] PROMPT "Mostrar Cuenta" OF oDlg ;
      SIZE 60,10 PIXEL
   @ 50, 00 SAY "Libro" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 50, 72 COMBOBOX oGet[6] VAR oB:aLS[12] ITEMS { "COLGAAP","IFRS" };
      SIZE 48,90 OF oDlg PIXEL;
      WHEN !EMPTY(oApl:oEmp:NIIF) .AND. oB:aLS[4] >= oApl:oEmp:NIIF
   @ 62, 00 SAY "CLASE DE LISTADO" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 62, 72 COMBOBOX oGet[7] VAR oB:aLS[8] ITEMS { "Matriz","Laser","Excel" };
      SIZE 48,90 OF oDlg PIXEL
   @ 62,134 CHECKBOX oGet[8] VAR oB:aLS[9] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,10 PIXEL
   @ 76, 50 BUTTON oGet[09] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[9]:Disable(), oB:ArmarMOV( oDlg ), oGet[9]:Enable()     ,;
        oGet[9]:oJump := oGet[2], oGet[2]:SetFocus() ) PIXEL
   @ 76,100 BUTTON oGet[10] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 82, 02 SAY "[CGEBALAN]" OF oDlg PIXEL SIZE 34,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
CLASS TBalan FROM TIMPRIME

 DATA aBG, aLS, aRB

 METHOD NEW( nOpc ) Constructor
 METHOD ArmarMOV( oDlg )
 METHOD ListoBAP( oRpt )
 METHOD ListoBAG( oRpt,cMes )
 METHOD ExcelBal( cMes )
 METHOD Cabecera( lSep,nSpace,nSuma )
ENDCLASS

//------------------------------------//
METHOD NEW( nOpc ) CLASS TBalan
 ::aEnc := { .t.,"BALANCE "+{ "DE PRUEBA","GENERAL" }[nOpc],;
             "","","","","" }
 ::aBG  := NtChr( DATE(),"1" )
 ::aLS  := { "",::aBG,"",::aBG,2,.f.,.f.,oApl:nTFor,.t.,nOpc,.f.,1 }
 Empresa( .t. )
RETURN NIL

//------------------------------------//
METHOD ArmarMOV( oDlg ) CLASS TBalan
   LOCAL aV, cMes, oRpt
//If ::aLS[6]
//   oApl:aEmp := { oApl:nEmpresa }
//EndIf
   ::aLS[1] := STR( VAL( LEFT(::aLS[2],4) )-1,4 ) + "13"
   ::aLS[3] := STR( VAL( LEFT(::aLS[4],4) )-1,4 ) + "13"
   ::aBG    := { 0,0,0,0,0,0,0,1,"99,999,999,999.99" }
If ::aLS[10] == 1
   ::aEnc[3] := NtChr( NtChr( ::aLS[4],"F" ),"6" )
   If ::aLS[8] == 3
      ::aLS[8] := oApl:nTFor
      ::aLS[9] := .t.
      MsgStop( "NO esta disponible en EXCEL",">>> BALANCE DE PRUEBA <<<" )
   EndIf
Else
   aV   := NtChr( NtChr( ::aLS[4],"F" ),"4" )
   cMes := "SELECT p.cuenta, p.nombre, SUM(a.valor_deb) - SUM(a.valor_cre), 'S' "+;
           "FROM cgeacumc a, cgeplan p "                      +;
           "WHERE a.empresa  = " + LTRIM(STR(oApl:nEmpresa))  +;
            " AND a.ano_mes >= " + xValToChar( ::aLS[3] )     +;
            " AND a.ano_mes <= " + xValToChar( ::aLS[4] )     +;
            " AND LEFT(a.cuenta,LENGTH(p.cuenta)) = p.cuenta "+;
            " AND a.libro    = " + LTRIM(STR(::aLS[12]))      +;
            " AND p.empresa  = " + LTRIM(STR(oApl:nPUC))      +;
            " AND p.nivel    = " + LTRIM(STR(::aLS[5]))       +;
            " AND p.estado   = 'A'"                           +;
            " AND LEFT(p.cuenta,2) = [CTA] "                  +;
          "GROUP BY p.cuenta"
//          " AND p.nivel    = " + LTRIM(STR(::aLS[5]))       +;
   ::aEnc[3] := NtChr( CTOD( aV ),"3" )
   If ::aLS[2] # ::aLS[4]
      aV   := {"ENE","FEB","MAR","ABR","MAY","JUN","JUL","AGO","SEP","OCT","NOV","DIC" }
      ::aEnc[2] += " COMPARATIVO"
      ::aEnc[4] := aV[VAL(RIGHT(::aLS[4],2))]  + ". " + LEFT(::aLS[4],4)
      ::aEnc[5] := aV[VAL(RIGHT(::aLS[2],2))]  + ". " + LEFT(::aLS[2],4)
      ::aEnc[6] := "----------------"
      ::aLS[11] := .t.
      aV   := " UNION " + STRTRAN( cMes,"'S'","'M'" )
      aV   := STRTRAN( aV,::aLS[3],::aLS[1] )
      cMes += STRTRAN( aV,::aLS[4],::aLS[2] )
   EndIf
   cMes += " ORDER BY cuenta"
   aV   := "SELECT cuentapyg, nombre, titulo, salto, db_cr, cuenta, 0, 0 "+;
           "FROM pygrango "                           +;
           "WHERE empresa  = " + LTRIM(STR(oApl:nPUC))+;
            " AND LEFT(cuentapyg,1) = 'B' "           +;
           "ORDER BY secuencia"
   ::aRB:= Buscar( aV,"CM",,9 )
EndIf
 aV := { {|| ::ListoBAP( oRpt ) },{|| ::ListoBAG( oRpt,cMes ) } }
 ::aEnc[2] += { " COLGAAP"," IFRS" }[::aLS[12]]
If ::aLS[8] == 1
   oRpt := TDosPrint()
   If ::aLS[10] == 1
      oRpt:New( oApl:cPuerto,oApl:cImpres,{::aEnc[2],::aEnc[3],;
                "   NOMBRE  DE  LA  CUENTA" + SPACE(28)       +;
                "DEBITOS           CREDITOS"},::aLS[9] )
   Else
      oRpt:New( oApl:cPuerto,oApl:cImpres,{::aEnc[2],::aEnc[3]},::aLS[9] )
   EndIf
   oRpt:lTimbrado := ::aLS[6]
   EVAL( aV[ ::aLS[10] ] )
   oRpt:NewPage()
   oRpt:End()
Else
   If ::aLS[8] == 3
      ::ExcelBal( cMes )
   Else
      ::Init( ::aEnc[2], .f. ,, !::aLS[9] )
        PAGE
          EVAL( aV[ ::aLS[10] ] )
        ENDPAGE
      IMPRIME END .F.
   EndIf
EndIf
If ::aLS[11]
   ::aLS[11] := .f.
EndIf
 ::aEnc[1] := .t.
 ::aEnc[2] := "BALANCE " + { "DE PRUEBA","GENERAL" }[::aLS[10]]
 AFILL( ::aEnc,"",3 )
RETURN NIL

//------------------------------------//
METHOD ListoBAP( oRpt ) CLASS TBalan
   LOCAL aRes, hRes, cQry, nL
cQry := "SELECT p.cuenta, p.nombre, p.db_cr, SUM(c.valor_deb), SUM(c.valor_cre) "+;
        "FROM cgeacumc c, cgeplan p "                        +;
        "WHERE c.empresa  = " + LTRIM(STR(oApl:nEmpresa))    +;
         " AND c.ano_mes >= " + xValToChar( ::aLS[3] )       +;
         " AND c.ano_mes <= " + xValToChar( ::aLS[4] )       +;
         " AND LEFT( c.cuenta,LENGTH(p.cuenta) ) = p.cuenta "+;
         " AND c.libro    = " + LTRIM(STR(::aLS[12]))        +;
         " AND p.empresa  = " + LTRIM(STR(oApl:nPUC))        +;
         " AND p.nivel    = " + LTRIM(STR(::aLS[5]))         +;
         " AND p.estado   = 'A'"                             +;
       " GROUP BY p.cuenta ORDER BY cuenta"
//       " AND p.nivel   = " + LTRIM(STR(::aLS[5]))          +;
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aRes[3] == 1
      aRes[4] -= aRes[5]
      If aRes[4] > 0
         aRes[5] := 0
      Else
         aRes[5] := -aRes[4]
         aRes[4] := 0
      EndIf
   Else
      aRes[5] -= aRes[4]
      If aRes[5] > 0
         aRes[4] := 0
      Else
         aRes[4] := -aRes[5]
         aRes[5] := 0
      EndIf
   EndIf
   If aRes[4] # 0 .OR. aRes[5] # 0
      If ::aLS[8] == 1
         oRpt:Titulo( 79 )
         oRpt:Say( oRpt:nL,00,TRIM(aRes[1]) + " " + LEFT(aRes[2],34) )
         oRpt:Say( oRpt:nL,43,TRANSFORM( aRes[4],::aBG[9] ) )
         oRpt:Say( oRpt:nL,62,TRANSFORM( aRes[5],::aBG[9] ) )
         oRpt:nL ++
      Else
         ::Cabecera( .t. )
         UTILPRN ::oUtil Self:nLinea,01.0 SAY TRIM(aRes[1]) + "  " + LEFT(aRes[2],34)
         UTILPRN ::oUtil Self:nLinea,16.0 SAY TRANSFORM( aRes[4],::aBG[9] ) RIGHT
         UTILPRN ::oUtil Self:nLinea,20.4 SAY TRANSFORM( aRes[5],::aBG[9] ) RIGHT
      EndIf
      ::aBG[1] += aRes[4]
      ::aBG[2] += aRes[5]
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
If ::aLS[8] == 1
   oRpt:Separator( 0,3 )
   oRpt:Say(  oRpt:nL,44,"----------------- -----------------",,,1 )
   oRpt:Say(++oRpt:nL,43,TRANSFORM( ::aBG[1],::aBG[9] ) )
   oRpt:Say(  oRpt:nL,62,TRANSFORM( ::aBG[2],::aBG[9] ) )
   oRpt:Say(++oRpt:nL,44,"================= =================" )
Else
   ::Cabecera( .t.,0.5,1.5 )
   UTILPRN ::oUtil Self:nLinea,16.0 SAY "-----------------"        RIGHT
   UTILPRN ::oUtil Self:nLinea,20.4 SAY "-----------------"        RIGHT
   ::nLinea += 0.5
   UTILPRN ::oUtil Self:nLinea,16.0 SAY TRANSFORM( ::aBG[1],::aBG[9] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,20.4 SAY TRANSFORM( ::aBG[2],::aBG[9] ) RIGHT
   ::nLinea += 0.5
   UTILPRN ::oUtil Self:nLinea,16.0 SAY "================="        RIGHT
   UTILPRN ::oUtil Self:nLinea,20.4 SAY "================="        RIGHT
EndIf
RETURN NIL

//----------Balance General-----------//
METHOD ListoBAG( oRpt,cMes ) CLASS TBalan
   LOCAL aSal, cQry, hRes, nL, nK
FOR nK := 1 TO LEN( ::aRB )
   ::aBG := { "","",0,0,.t.,"",0,1,"99,999,999,999.99" }
   If ::aRB[nK,1] == "B1        "
      ::aBG[6] := "ACTIVO"
   ElseIf ::aRB[nK,1] == "B11       "
      ::aBG[6] := "PASIVO Y PATRIMONIO"
      ::aBG[7] := 1
   EndIf
   cQry := ALLTRIM( ::aRB[nK,6] )
   While !EMPTY(cQry)
      aSal := Saca( @cQry,"," )
      aSal := STRTRAN( cMes,"[CTA]",aSal )
      hRes := If( MSQuery( oApl:oMySql:hConnect,aSal ) ,;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      If (nL := MSNumRows( hRes )) > 0
         aSal := MyReadRow( hRes )
         AEVAL( aSal, { | xV,nP | aSal[nP] := MyClReadCol( hRes,nP ) } )
         ::aBG[1] := aSal[1]
         ::aBG[2] := aSal[2]
      EndIf
      While nL > 0
         aSal[3] *= If( ::aRB[nK,5] == 0, 1, -1 )
         If aSal[4] == "S"
            ::aBG[3] := aSal[3]
         Else
            ::aBG[4] := aSal[3]
         EndIf
         If (nL --) > 1
            aSal := MyReadRow( hRes )
            AEVAL( aSal, {| xV,nP | aSal[nP] := MyClReadCol( hRes,nP ) } )
         EndIf
         If nL == 0 .OR. ::aBG[1] # aSal[1]
            If ::aBG[3] # 0 .OR. ::aBG[4] # 0
               If ::aLS[7]
                  ::aBG[2] := TRIM(::aBG[1]) + "  " + ::aBG[2]
               EndIf
               If ::aLS[11]
                  ::aEnc[7] := TRANSFORM( ::aBG[4],::aBG[9] )
               EndIf
               If ::aLS[8] == 1
                  oRpt:Titulo( 79 )
                  If ::aLS[11] .AND. oRpt:nL == 6
                     oRpt:Say( oRpt:nL,52,::aEnc[4] )
                     oRpt:Say( oRpt:nL,70,::aEnc[5] )
                     oRpt:nL ++
                  EndIf
                  If ::aBG[5]
                     oRpt:SetFont( oRpt:cFontI+oRpt:CPIBold )
                     If !EMPTY(::aBG[6])
                        oRpt:nL += ::aBG[7]
                        oRpt:Say( oRpt:nL, 00,::aBG[6] )
                        oRpt:nL ++
                     EndIf
                        oRpt:Say( oRpt:nL, 00,::aRB[nK,2] + oRpt:CPIBoldN  )
                        oRpt:SetFont( oRpt:cFontI )
                        oRpt:nL ++
                        ::aBG[5] := .f.
                  EndIf
                  oRpt:Say( oRpt:nL,01,::aBG[2] )
                  oRpt:Say( oRpt:nL,45,TRANSFORM( ::aBG[3],::aBG[9] ) )
                  oRpt:Say( oRpt:nL,63,::aEnc[7] )
                  oRpt:nL ++
               Else
                  ::Cabecera( .t. )
                  If ::aBG[5]
                     If !EMPTY(::aBG[6])
                        ::nLinea += (::aBG[7] / 2)
                        UTILPRN ::oUtil Self:nLinea, 1.0 SAY ::aBG[6]    FONT ::aFnt[1]
                        ::nLinea += 0.5
                     EndIf
                        UTILPRN ::oUtil Self:nLinea, 1.0 SAY ::aRB[nK,2] FONT ::aFnt[1]
                        ::nLinea += 0.5
                        ::aBG[5] := .f.
                  EndIf
                  UTILPRN ::oUtil Self:nLinea,01.2 SAY ::aBG[2]
                  UTILPRN ::oUtil Self:nLinea,16.5 SAY TRANSFORM( ::aBG[3],::aBG[9] ) RIGHT
                  UTILPRN ::oUtil Self:nLinea,20.4 SAY ::aEnc[7]                      RIGHT
               EndIf
            EndIf
            ::aRB[nK+1,7] += ::aBG[3]
            ::aRB[nK+1,8] += ::aBG[4]
            ::aBG[1] := aSal[1]
            ::aBG[2] := aSal[2]
            ::aBG[3] := ::aBG[4] := 0
         EndIf
      EndDo
      MSFreeResult( hRes )
   EndDo
   If ::aRB[nK,7] # 0 .OR. ::aRB[nK,8] # 0
      If ::aLS[11]
         ::aEnc[7] := TRANSFORM( ::aRB[nK,8],::aBG[9] )
      EndIf
      If ::aLS[8] == 1
         oRpt:nL += ::aRB[nK,4]
      // oRpt:Titulo( 79 )
         If ::aRB[nK,3] == "N"
            oRpt:Separator( 0,3 )
            oRpt:Say(  oRpt:nL,44,"-----------------" )
            oRpt:Say(  oRpt:nL,63,::aEnc[7] )
         EndIf
         oRpt:SetFont( oRpt:cFontI+oRpt:CPIBold )
         oRpt:Say(++oRpt:nL, 00,::aRB[nK,2] )
         oRpt:Say(  oRpt:nL,45,TRANSFORM( ::aRB[nK,7],::aBG[9] ) )
         oRpt:Say(  oRpt:nL,63,::aEnc[7] + oRpt:CPIBoldN  )
         oRpt:nL ++
      Else
         ::nLinea += (::aRB[nK,4] / 2)
         If ::aRB[nK,3] == "N"
            ::Cabecera( .t. )
            UTILPRN ::oUtil Self:nLinea,16.5 SAY "----------------"           RIGHT
            UTILPRN ::oUtil Self:nLinea,20.4 SAY ::aEnc[6]                    RIGHT
         EndIf
         ::Cabecera( .t. )
         UTILPRN ::oUtil SELECT ::aFnt[1]
         UTILPRN ::oUtil Self:nLinea,01.2 SAY ::aRB[nK,2]
         UTILPRN ::oUtil Self:nLinea,16.5 SAY TRANSFORM( ::aRB[nK,7],::aBG[9] ) RIGHT
         UTILPRN ::oUtil Self:nLinea,20.4 SAY ::aEnc[7]                       RIGHT
         UTILPRN ::oUtil SELECT ::aFnt[2]
      EndIf
      If nK <= 8
         ::aRB[09,7] += ::aRB[nK,7]
         ::aRB[09,8] += ::aRB[nK,8]
      ElseIf nK >= 10
         ::aRB[17,7] += ::aRB[nK,7]
         ::aRB[17,8] += ::aRB[nK,8]
      EndIf
   EndIf
NEXT nK

If ::aLS[8] == 1
   oRpt:Separator( 2,6 )
   oRpt:Say(++oRpt:nL,04,oApl:oEmp:GERENTE + SPACE(14) + oApl:oEmp:CONTADOR )
   oRpt:Say(++oRpt:nL,04,oApl:oEmp:CC      + SPACE(29) + "CONTADOR" )
   oRpt:Say(++oRpt:nL,04,                    SPACE(44) + oApl:oEmp:TP )
Else
   ::Cabecera( .t.,1,4.5 )
   UTILPRN ::oUtil Self:nLinea,02.0 SAY oApl:oEmp:GERENTE
   UTILPRN ::oUtil Self:nLinea,12.0 SAY oApl:oEmp:CONTADOR
   ::nLinea += 0.5
   UTILPRN ::oUtil Self:nLinea,02.0 SAY oApl:oEmp:CC
   UTILPRN ::oUtil Self:nLinea,12.0 SAY "CONTADOR"
   ::nLinea += 0.5
   UTILPRN ::oUtil Self:nLinea,02.0 SAY oApl:oEmp:TP
EndIf
RETURN NIL
/*
   LOCAL aSal, cMes, nK, oBal, lSi := .t.
cMes := RIGHT( ::aLS[4],2 )
//aSal := ArmarPYG( oBal,::aLS[3],::aLS[4],0 )
oBal := oApl:Abrir( "cgebalge","consecutiv",.f. )
oBal:Seek( {"empresa",oApl:nPUC},"consecutiv" )
While !oBal:Eof()
   oBal:VALOR := 0 ; oBal:Update(.t.,1)
   If oBal:ACUMULA
      ::aBG[4] := oBal:Recno()
      ::aBG[8] := If( TRIM( oBal:NOMBRE ) == "A C T I V O S",  1, ;
                  If( TRIM( oBal:NOMBRE ) == "P A S I V O S", -1, ::aBG[8] ))
   Else
      do Case
      Case oBal:BG == "INVENTARIO"                         //Activo "1435      "
         aSal[3] := Buscar( { "LEFT(cuenta_r,4)",LEFT(oBal:CUENTA,4) },;
                              "cgesecue","SUM(valor)",8 )
      Case oBal:BG == "RENTA     " .AND. cMes # "13"       //Pasivo "2404      "
         ::aBG[5] := Buscar( { "LEFT(cuenta_r,4)",LEFT(oBal:CUENTA,4) },;
                               "cgesecue","SUM(valor)",8 )
         aSal[3] += (::aBG[5] * -1)
//    Case oBal:BG == "RENTA     " .AND. cMes # "13"       //Pasivo "2615      "
//       aSal := SaldoCta( { LEFT(oBal:CUENTA,4) },::aLS[4],::aLS[3],2 )
//       aSal[3] *= -1
//       aSal[3] += ::aBG[5]
      Case oBal:BG == "UTILIDAD  " .AND. cMes # "13"       //Pasivo "3605      "
         aSal := SaldoCta( { LEFT(oBal:CUENTA,4) },::aLS[4],::aLS[3],2 )
         aSal[3] *= -1
         ::aBG[6] := Buscar( { "LEFT(cuenta_r,4)",LEFT(oBal:CUENTA,4) },;
                               "cgesecue","SUM(valor)",8 )
         aSal[3] += ::aBG[6]
      Case oBal:BG == "RESERVA   " .AND. cMes # "13"       //Pasivo "3305      "
         aSal := SaldoCta( { LEFT(oBal:CUENTA,4) },::aLS[4],::aLS[3],2 )
         aSal[3] *= -1
         ::aBG[7] := Buscar( { "LEFT(cuenta_r,4)",LEFT(oBal:CUENTA,4) },;
                               "cgesecue","SUM(valor)",8 )
         aSal[3] += (::aBG[7] * -1)
      OtherWise
         aSal := SaldoCta( { oBal:CUENTA },::aLS[4],::aLS[3],1 )
      EndCase
      If oBal:BG == "BANCOS    "                         //"1110      "
         If ::aBG[8] == 1
            aSal[3] := If( aSal[3] < 0, 0, aSal[3] )
         Else
            aSal[3] := If( aSal[3] > 0, 0, aSal[3] )
         EndIf
      EndIf
      aSal[3] *= ::aBG[8]
      oBal:VALOR := aSal[3] ; oBal:Update( .t.,1 )
      ::aBG[1] += aSal[3]
      aSal[3] := 0
   EndIf
   If oBal:TOTALIZO
      If oBal:ACUMULA
         oBal:VALOR := If( lSi, ::aBG[2], 0 ) ; oBal:Update( .t.,1 )
         ::aBG[2] := If( oBal:CUENTA == "0020      ", 0, ::aBG[2] )
      Else
         nK := oBal:RecNo()
         oBal:Go( ::aBG[4] ):Read()
         oBal:xLoad()
         oBal:VALOR := ::aBG[1] ; oBal:Update( .t.,1 )
         ::aBG[2] += ::aBG[1]
         ::aBG[3] += If( oBal:VALOR # 0, oBal:SALTO+1, 0 )
         lSi := If( oBal:CUENTA == "0019      " .AND. oBal:VALOR == 0, .f., .t. )
         oBal:Go( nK ):Read()
      EndIf
      ::aBG[1] := 0
   EndIf
   If oBal:VALOR # 0
      ::aBG[3] += oBal:SALTO
   EndIf
   oBal:Skip(1):Read()
   oBal:xLoad()
EndDo

lSi   := .f.
oBal:Seek( {"empresa",oApl:nPUC},"consecutiv" )
If ::aLS[8] == 2
   ::aEnc[3] := ::aEnc[4]
   ::aBG[3] := (::aBG[3] / 2) + 7.5
   While !oBal:Eof()
      If TRIM( oBal:NOMBRE ) == "A C T I V O S"
         ::Cabecera( .t. )
         UTILPRN ::oUtil  3.5, 8.5 SAY oBal:NOMBRE  FONT ::aFnt[1]
         ::nLinea := 4.0
      EndIf
      If oBal:VALOR # 0
         aSal := Buscar( {"empresa",oApl:nPUC,"cuenta",oBal:CUENTA },;
                         "cgeplan","nombre",8 )
         ::Cabecera( .t.,0 )
         If oBal:IMPRIME_CA
            UTILPRN ::oUtil Self:nLinea,01.2 SAY LEFT( oBal:CUENTA,4 ) + " " + aSal
            UTILPRN ::oUtil Self:nLinea,16.5 SAY TRANSFORM( oBal:VALOR,::aBG[9] ) RIGHT
            lSi := .t.
         Else
            If lSi
               lSi := .f.
               UTILPRN ::oUtil Self:nLinea,16.5 SAY "----------------"          RIGHT
               ::nLinea += 0.5
            EndIf
            UTILPRN ::oUtil Self:nLinea+.5,01.0 SAY aSal      FONT ::aFnt[1]
            UTILPRN ::oUtil Self:nLinea+.5,20.5 SAY TRANSFORM( oBal:VALOR,::aBG[9] ) RIGHT
            If oBal:TOTALIZO .AND. oBal:ACUMULA
               UTILPRN ::oUtil Self:nLinea+1,20.5 SAY "================"        RIGHT
            EndIf
         EndIf
         ::nLinea += (oBal:SALTO / 2)
      EndIf
      oBal:Skip(1):Read()
      oBal:xLoad()
      If TRIM( oBal:NOMBRE ) == "P A S I V O S"
         ::nLinea := If( ::aBG[3] > ::nEndLine, ::nEndLine, ::nLinea )
         ::Cabecera( .t. )
         UTILPRN ::oUtil Self:nLinea, 8.5 SAY oBal:NOMBRE  FONT ::aFnt[1]
         ::nLinea += (oBal:SALTO / 2)
      EndIf
   EndDo
   ::Cabecera( .t.,1,1.5 )
   UTILPRN ::oUtil Self:nLinea,02.0 SAY Replicate("_",30) + SPACE(14) + Replicate("_",30)
   ::nLinea += 0.5
   UTILPRN ::oUtil Self:nLinea,02.0 SAY oApl:oEmp:GERENTE + SPACE(14) + oApl:oEmp:CONTADOR
   ::nLinea += 0.5
   UTILPRN ::oUtil Self:nLinea,02.0 SAY "        GERENTE" + SPACE(40) + "CONTADOR"
Else
   ::aBG[3] += 15
   While !oBal:Eof()
      oRpt:Titulo( 80,,1 )
      If TRIM( oBal:NOMBRE ) == "A C T I V O S"
         oRpt:Say( 08,31,oRpt:CPIBOLD + oBal:NOMBRE )
         oRpt:nL := 9
      EndIf
      If oBal:VALOR # 0
         aSal := Buscar( {"empresa",oApl:nPUC,"cuenta",oBal:CUENTA },;
                         "cgeplan","nombre",8 )
         If oBal:IMPRIME_CA
            oRpt:Say( oRpt:nL,01,LEFT( oBal:CUENTA,4 ) + " " + aSal )
            oRpt:Say( oRpt:nL,46,TRANSFORM( oBal:VALOR,::aBG[9] ) )
            lSi := .t.
         Else
            If lSi
               lSi := .f.
               oRpt:Say( oRpt:nL++,46,"----------------" )
            EndIf
            oRpt:Say( oRpt:nL+1,00,oRpt:CPIBOLD + aSal )
            oRpt:Say( oRpt:nL+1,66,TRANSFORM( oBal:VALOR,::aBG[9] ) )
            If oBal:TOTALIZO .AND. oBal:ACUMULA
               oRpt:Say( oRpt:nL+2,64,"================" )
            EndIf
         EndIf
         oRpt:nL += oBal:SALTO
      EndIf
      oBal:Skip(1):Read()
      oBal:xLoad()
      If TRIM( oBal:NOMBRE ) == "P A S I V O S"
         oRpt:nL := If( ::aBG[3] > oRpt:nLength, oRpt:nLength+1, oRpt:nL )
         oRpt:Titulo( 80,,1 )
         oRpt:Say( oRpt:nL,31,oRpt:CPIBOLD + oBal:NOMBRE )
         oRpt:nL += oBal:SALTO
      EndIf
   EndDo
   oRpt:Separator( 2,3 )
   oRpt:Say(  oRpt:nL,04,Replicate("_",30) + SPACE(14) + Replicate("_",30),,,1 )
   oRpt:Say(++oRpt:nL,04,oApl:oEmp:GERENTE + SPACE(14) + oApl:oEmp:CONTADOR )
   oRpt:Say(++oRpt:nL,04,"        GERENTE" + SPACE(40) + "CONTADOR" )
EndIf
oBal:Destroy()
*/
//------------------------------------//
METHOD ExcelBal( cMes ) CLASS TBalan
   LOCAL aGT, aSal, cQry, nF, nL, nK, hRes, hRez, oExcel
If oApl:lOffice
   aGT := { cFilePath( GetModuleFileName( GetInstance() )) + "Balance.csv",;
            "",CHR(13) + CHR(10) }
               //CRLF
   FERASE( aGT[1] )
   hRes := FCREATE(aGT[1],0) //, FC_NORMAL)
   If FERROR() != 0
      Msginfo(FERROR(),"No se pudo crear el archivo "+aGT[1] )
      RETURN NIL
   EndIf
   FWRITE( hRes,'"'+oApl:cEmpresa+'"'+aGT[3] )
   FWRITE( hRes,'"NIT: ' + oApl:oEmp:Nit + '"' +aGT[3] )
   FWRITE( hRes,'"'+::aEnc[2]+'"'+aGT[3] )
   FWRITE( hRes,'"'+::aEnc[3]+'"'+aGT[3] )
   FWRITE( hRes,'"","'+::aEnc[4]+'","'+::aEnc[5]+'"'+aGT[3] )
   nF  := 6
Else
   cQry := cFilePath( GetModuleFileName( GetInstance() )) + "Balance.xls"
   oApl:oWnd:SetMsg( "Exportando hacia "+cQry )
   oExcel := TExcelScript():New()
   oExcel:Create( cQry )
   oExcel:Font("Verdana")
   oExcel:Visualizar(.F.)
// oExcel:Say( nRow, nCol, xValue, cFont, nSize, lBold, lItalic, ;
//             lUnderLine, nAlign, nColor, nFondo , nOrien , nStyle , cFormat )
   oExcel:Say(  1 , 1 , oApl:cEmpresa, , 14 ,,,,,,,, 0  )
   oExcel:Say(  2 , 1 , "NIT: " + oApl:oEmp:Nit, ,12 ,,,, 7,,,, 0 )
   oExcel:Say(  3 , 1 , ::aEnc[2], , 12 ,,,, 7,,,, 0  )
   oExcel:Say(  4 , 1 , ::aEnc[3], , 12 ,,,, 7,,,, 0  )
   oExcel:Say(  5 , 2 , ::aEnc[4], , 12 ,,,, 7,,,, 0  )
   oExcel:Say(  5 , 3 , ::aEnc[5], , 12 ,,,, 7,,,, 0  )
   nF := 6
EndIf
FOR nK := 1 TO LEN( ::aRB )
   ::aBG := { "","",0,0,.t.,"",0,1,"#.##0,00" }
   If ::aRB[nK,1] == "B1        "
      ::aBG[6] := "ACTIVO"
   ElseIf ::aRB[nK,1] == "B11       "
      ::aBG[6] := "PASIVO Y PATRIMONIO"
   EndIf
   cQry := ALLTRIM( ::aRB[nK,6] )
   While !EMPTY(cQry)
      aSal := Saca( @cQry,"," )
      aSal := STRTRAN( cMes,"[CTA]",aSal )
      hRez := If( MSQuery( oApl:oMySql:hConnect,aSal ) ,;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      If (nL := MSNumRows( hRez )) > 0
         aSal := MyReadRow( hRez )
         AEVAL( aSal, { | xV,nP | aSal[nP] := MyClReadCol( hRez,nP ) } )
         ::aBG[1] := aSal[1]
         ::aBG[2] := aSal[2]
      EndIf
      While nL > 0
         aSal[3] *= If( ::aRB[nK,5] == 0, 1, -1 )
         If aSal[4] == "S"
            ::aBG[3] := aSal[3]
         Else
            ::aBG[4] := aSal[3]
         EndIf
         If (nL --) > 1
            aSal := MyReadRow( hRez )
            AEVAL( aSal, {| xV,nP | aSal[nP] := MyClReadCol( hRez,nP ) } )
         EndIf
         If nL == 0 .OR. ::aBG[1] # aSal[1]
            If ::aBG[3] # 0 .OR. ::aBG[4] # 0
               If ::aLS[7]
                  ::aBG[2] := TRIM(::aBG[1]) + "  " + ::aBG[2]
               EndIf
               If ::aLS[11]
                  ::aEnc[7] := ::aBG[4]
               EndIf
               If oApl:lOffice
                  If ::aBG[5]
                     If !EMPTY(::aBG[6])
                        FWRITE( hRes,'"'+::aBG[6]+'"'+aGT[3] )
                     EndIf
                        FWRITE( hRes,'"'+::aRB[nK,2]+'"'+aGT[3] )
                        ::aBG[5] := .f.
                  EndIf
                  aGT[2] := '"' + ::aBG[2] +'",' + XTrim( ::aBG[3],-9 ) + XTrim( ::aEnc[7],-9 )
                  FWRITE( hRes,aGT[2] + aGT[3] )
               Else
                  If ::aBG[5]
                     If !EMPTY(::aBG[6])
                        oExcel:Say( nF, 1, ::aBG[6],,, .t.,,, 2,,,,, "Text" )
                        nF ++
                     EndIf
                        oExcel:Say( nF, 1, ::aRB[nK,2],,, .t.,,, 2,,,,, "Text" )
                        nF ++
                        ::aBG[5] := .f.
                  EndIf
                  oExcel:Say( nF, 1, ::aBG[2] ,,, .f.,,, 2,,,,, "Text" )
                  oExcel:Say( nF, 2, ::aBG[3] ,,, .f.,,,,,,,, ::aBG[9] )
                  oExcel:Say( nF, 3, ::aEnc[7],,, .f.,,,,,,,, ::aBG[9] )
                  nF ++
               EndIf
            EndIf
            ::aRB[nK+1,7] += ::aBG[3]
            ::aRB[nK+1,8] += ::aBG[4]
            ::aBG[1] := aSal[1]
            ::aBG[2] := aSal[2]
            ::aBG[3] := ::aBG[4] := 0
         EndIf
      EndDo
      MSFreeResult( hRez )
   EndDo
   If ::aRB[nK,7] # 0 .OR. ::aRB[nK,8] # 0
      If ::aLS[11]
         ::aEnc[7] := ::aRB[nK,8]
      EndIf
      If oApl:lOffice
         If ::aRB[nK,4] > 0
            FWRITE( hRes,'""'+aGT[3] )
         EndIf
         If ::aRB[nK,3] == "N"
            FWRITE( hRes,'"","-----------------","' + ::aEnc[6] + '"'+aGT[3] )
         EndIf
         aGT[2] := '"' + ::aRB[nK,2] +'",' + XTrim( ::aRB[nK,7],-9 ) + XTrim( ::aEnc[7],-9 )
         FWRITE( hRes,aGT[2] + aGT[3] )
         FWRITE( hRes,'""'+aGT[3] )
      Else
         nF += ::aRB[nK,4]
         If ::aRB[nK,3] == "N"
            oExcel:Say( nF, 2, "----------------" ,,, .f.,,, 2,,,,, "Text" )
            oExcel:Say( nF, 3, ::aEnc[6]          ,,, .f.,,, 2,,,,, "Text" )
            nF ++
         EndIf
         oExcel:Say( nF, 1, ::aRB[nK,2] ,,, .t.,,, 2,,,,, "Text" )
         oExcel:Say( nF, 2, ::aRB[nK,7] ,,, .t.,,,,,,,, ::aBG[9] )
         oExcel:Say( nF, 3, ::aEnc[7]   ,,, .t.,,,,,,,, ::aBG[9] )
         nF ++
      EndIf
      If nK <= 8
         ::aRB[09,7] += ::aRB[nK,7]
         ::aRB[09,8] += ::aRB[nK,8]
      ElseIf nK >= 10
         ::aRB[17,7] += ::aRB[nK,7]
         ::aRB[17,8] += ::aRB[nK,8]
      EndIf
   EndIf
NEXT nK
If oApl:lOffice
   FWRITE( hRes,'""'+aGT[3] )
   FWRITE( hRes,'""'+aGT[3] )
   FWRITE( hRes,'""'+aGT[3] )
   FWRITE( hRes,'"'+oApl:oEmp:GERENTE+'","'+oApl:oEmp:CONTADOR+'"'+aGT[3] )
   FWRITE( hRes,'"'+oApl:oEmp:CC+'","CONTADOR"'+aGT[3] )
   FWRITE( hRes,'"","'+oApl:oEmp:TP+'"'+aGT[3] )
   If !FCLOSE(hRes)
      Msginfo(FERROR(),"Error cerrando el archivo "+aGT[1])
   EndIf
   WAITRUN("OPENOFICE.BAT " + aGT[1], 0 )
Else
   nF += 3
   oExcel:Say(  nF, 1, oApl:oEmp:GERENTE ,,, .f.,,, 2,,,,, "Text" )
   oExcel:Say(  nF, 2, oApl:oEmp:CONTADOR,,, .f.,,, 2,,,,, "Text" )
   oExcel:Say(++nF, 1, oApl:oEmp:CC      ,,, .f.,,, 2,,,,, "Text" )
   oExcel:Say(  nF, 2, "CONTADOR"        ,,, .f.,,, 2,,,,, "Text" )
   oExcel:Say(++nF, 2, oApl:oEmp:TP      ,,, .f.,,, 2,,,,, "Text" )
   oExcel:Borders("A1:C" + LTRIM(STR(nF)) ,,, 3 )
   oExcel:ColumnWidth( 1 , 45 )
   oExcel:ColumnWidth( 2 , 16 )
   oExcel:ColumnWidth( 3 , 16 )
   oExcel:Visualizar(.T.)
   oExcel:End(.f.) ; oExcel := NIL
EndIf
RETURN NIL

//------------------------------------//
METHOD Cabecera( lSep,nSpace,nSuma ) CLASS TBalan
If lSep .AND. !::aEnc[1]
   ::aEnc[1] := ::Separator( nSpace,nSuma )
EndIf
If ::aEnc[1]
   ::aEnc[1] := .f.
   If !::aLS[6]
      ::Centrar( oApl:cEmpresa,::aFnt[4],1.0 )
      UTILPRN ::oUtil 1.5, 8.2 SAY "NIT: " + oApl:oEmp:Nit
      ::Centrar( ::aEnc[2],,2.0 )
   EndIf
      ::Centrar( ::aEnc[3],,2.5 )
   ::nLinea := 3.5
   If ::aLS[10] == 1
      UTILPRN ::oUtil 3.0, 1.2 SAY "NOMBRE CUENTA"
      UTILPRN ::oUtil 3.0,16.0 SAY "DEBITOS"      RIGHT
      UTILPRN ::oUtil 3.0,20.4 SAY "CREDITOS"     RIGHT
      UTILPRN ::oUtil LINEA 3.5,1.0 TO 3.5,20.0 PEN ::oPen
   ElseIf ::aLS[11]
      UTILPRN ::oUtil 3.5,16.0 SAY ::aEnc[4]      RIGHT
      UTILPRN ::oUtil 3.5,20.4 SAY ::aEnc[5]      RIGHT
      ::nLinea += 0.5
   EndIf
EndIf
RETURN NIL