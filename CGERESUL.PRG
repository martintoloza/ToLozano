// Programa.: CGERESUL.PRG    >>> Martin A. Toloza L. <<<
// Notas....: Estado de Resultados.
#include "Fivewin.ch"
#INCLUDE "Utilprn.CH"

MEMVAR oApl

PROCEDURE CgeResul()
   LOCAL oDlg, oGet := ARRAY(13)
   LOCAL oAC := TCierre()
oAC:New()
DEFINE DIALOG oDlg TITLE oAC:aEnc[2] FROM 0, 0 TO 16,50
   @ 02,00 SAY "CIERRE [0/1/2]"   OF oDlg RIGHT PIXEL SIZE 70,10
   @ 02,72 GET oGet[1] VAR oAC:aLS[2] OF oDlg PICTURE "9" SIZE 08,10 PIXEL ;
      VALID Rango( oAC:aLS[2],0,2 )
   @ 02,110 SAY "0=Solo Imprime 1=Movimiento del Cierre 2=Cierre del Ejercicio";
      OF oDlg PIXEL SIZE 80,30
   @ 14,00 SAY "PERIODO INICIAL"  OF oDlg RIGHT PIXEL SIZE 70,10
   @ 14,72 GET oGet[2] VAR oAC:aLS[1] OF oDlg PICTURE "999999";
      VALID NtChr( oAC:aLS[1],"P" ) ;
      WHEN oAC:aLS[2] == 0  SIZE 28,10 PIXEL
   @ 26,00 SAY "PERIODO   FINAL"  OF oDlg RIGHT PIXEL SIZE 70,10
   @ 26,72 GET oGet[3] VAR oAC:aLS[4] OF oDlg PICTURE "999999" SIZE 28,10 PIXEL;
      VALID NtChr( oAC:aLS[4],"P" )
   @ 38,00 SAY "NIVEL [2/3/4]"    OF oDlg RIGHT PIXEL SIZE 70,10
   @ 38,72 COMBOBOX oGet[4] VAR oAC:aLS[5] ITEMS { "Cuenta(4)","SubCuenta(6)","Auxiliar(8)" };
      SIZE 48,90 OF oDlg PIXEL
// @ 38,72 GET oGet[4] VAR oAC:aLS[5] OF oDlg PICTURE "9" SIZE 08,10 PIXEL ;
//    VALID Rango( oAC:aLS[5],2,4 )
   @ 50,00 SAY "REGISTRADO"       OF oDlg RIGHT PIXEL SIZE 70,10
   @ 49, 72 CHECKBOX oGet[5] VAR oAC:aLS[6]  PROMPT " " OF oDlg SIZE 14,10 PIXEL
   @ 49,144 CHECKBOX oGet[6] VAR oAC:aLS[10] PROMPT "Mostrar Cuenta" OF oDlg ;
      SIZE 60,10 PIXEL
   @ 62,00 SAY "Libro" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 62,72 COMBOBOX oGet[7] VAR oAC:aLS[11] ITEMS { "COLGAAP","IFRS" };
      SIZE 48,90 OF oDlg PIXEL;
      WHEN !EMPTY(oApl:oEmp:NIIF) .AND. oAC:aLS[1] >= oApl:oEmp:NIIF
   @ 74,00 SAY "CLASE DE LISTADO" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 74,72 COMBOBOX oGet[8] VAR oAC:aLS[7] ITEMS { "Matriz","Laser","Excel" };
      SIZE 48,90 OF oDlg PIXEL
   @ 86,72 COMBOBOX oGet[9] VAR oAC:aLS[8] ;
      ITEMS { "","ComparativoX Año","ComparativoX Mes","Comparativo Meses" };
      WHEN oAC:aLS[7] == 3  SIZE 60,90 PIXEL
   @ 86,144 CHECKBOX oGet[10] VAR oAC:aLS[9] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,10 PIXEL

   @ 100, 50 BUTTON oGet[11] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
       ( oGet[11]:Disable(), oAC:NEW( oDlg ), oDlg:End() ) PIXEL
   @ 100,100 BUTTON oGet[12] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 102,02 SAY "[CGERESUL]" OF oDlg PIXEL SIZE 32,10
   @ 114,10 SAY oGet[13] VAR oAC:aLS[3] OF oDlg PIXEL SIZE 90,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT Empresa( .t. )

oAC:oCtl:Destroy()
oAC:oMvc:Destroy()
oAC:oMvd:Destroy()
oAC:oPuc:Destroy()
oAC:oSec:Destroy()
RETURN

//------------------------------------//
FUNCTION ArmarPYG( oSec,cPerI,cPerF,nLib )
/*
   // Version Vieja
   LOCAL aSal, cCta, nLen, lSi := .t.
   LOCAL aPG := { 0,0,0,0,0,0,"99,999,999,999.99" }
oSec:Seek( {"empresa",oApl:nPUC},"consecutiv" )
While !oSec:Eof()
   If oSec:ACUMULA
      aPG[3] := oSec:Recno()
   Else
      cCta := If( EMPTY( oSec:CUENTA_R ), oSec:CUENTA, oSec:CUENTA_R )
      do Case
      Case oSec:PYG == "RESERVA   "
         aSal := SaldoCta( { "3115" }  ,cPerF,cPerI,2 )
         aPG[5] := aSal[3] * .5                           //Capital
         aSal := SaldoCta( {LEFT(cCta,6)},cPerF,cPerI,2 )
         aPG[6] := aSal[3]                                //Reserva 330505
      //Case oSec:PYG == "INVENTARIO"
      Case oSec:CUENTA == "0003      " .OR. ;
           oSec:CUENTA == "0005      "
         aSal := SaldoCta( {LEFT(cCta,2)},cPerF,cPerI,1 )
      //   nInvF   := If( nInvF == 0, aSal[3], nInvF )
         aSal[3] := If( oSec:CUENTA == "0005      ", -nInvF, aSal[3] )
      OtherWise
         aSal := SaldoCta( { cCta }    ,cPerF,cPerI,1 )
      EndCase
      If oSec:PORCENTAJE > 0 .AND. aPG[2] # 0
         If oSec:PYG == "RENTA     "                    //240405
            aSal[3] := ROUND( aPG[2] * oSec:PORCENTAJE * -1/1000, 0 ) * 1000
             aPG[4] := aPG[2]
         Else
            If oSec:PYG == "RESERVA   "
               aSal[3] := 0
               If aPG[5] > aPG[6]
                  aSal[3] := ROUND( aPG[4] * -oSec:PORCENTAJE / 1000,0 ) * 1000
                  If aPG[5] < ( aPG[6] + aSal[3] )
                     aSal[3] := aPG[5] - aPG[6]
                  EndIf
               //   aPG[2] += aSal[3]
               EndIf
            Else
               aSal[3] := ROUND( aPG[4] * -oSec:PORCENTAJE / 1000,0 ) * 1000
            //   aPG[2]*= (1 + oSec:PORCENTAJE)
            EndIf
         EndIf
      EndIf
      //If !Empty( oSec:CUENTA_R )
      //   If oSec:PYG == "UTILIDAD  "                  //360505
      //      aSal[3] := aPG[oSec:TOTALIZO+1]*-1
      //   EndIf
      //EndIf
      oSec:VALOR := aSal[3] ; oSec:Update( .t.,1 )
      aPG[1] += aSal[3]
      aSal[3] := 0
   EndIf
   If oSec:TOTALIZO
      If oSec:ACUMULA
         oSec:VALOR := If( lSi, aPG[2], 0 ) ; oSec:Update( .t.,1 )
      Else
         nLen := oSec:Recno()
         aPG[2] += aPG[1]
         oSec:Go( aPG[3] ):Read()
         oSec:xLoad()
         oSec:VALOR := aPG[1] ; oSec:Update( .t.,1 )
         lSi := If( oSec:CUENTA == "0002      " .AND. oSec:VALOR == 0, .f., .t. )
         oSec:Go( nLen ):Read()
      EndIf
      aPG[1] := 0
   EndIf
   oSec:Skip(1):Read()
   oSec:xLoad()
EndDo
// Fin Version Vieja
*/
   // Version Nueva
   LOCAL aPG, aRes, hRes, nF, nL
aRes := "SELECT r.cuentapyg, r.row_id, r.db_cr, "        +;
           "SUM(a.valor_deb), SUM(a.valor_cre) "         +;
        "FROM pygrango r LEFT JOIN cgeacumc a"           +;
          " ON r.cuenta   = LEFT(a.cuenta,2)"            +;
         " AND a.empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND a.ano_mes >= " + xValToChar( cPerI )      +;
         " AND a.ano_mes <= " + xValToChar( cPerF )      +;
         " AND a.libro    = " +        STR( nLib,2)      +;
       " WHERE r.empresa  = " + LTRIM(STR(oApl:nPUC))    +;
    " AND LEFT(r.cuentapyg,1) = 'F'"                     +;
       " GROUP BY r.cuentapyg ORDER BY r.secuencia"
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   RETURN NIL
EndIf
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) },2 )
   aPG  := { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,aRes[1],aRes[2] }
   nF   := 1
While nL > 0
   aPG[nF] := If( aRes[3] == 1, (aRes[4]-aRes[5]), (aRes[5]-aRes[4]) )
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) },2 )
   EndIf
   If nL == 0 .OR. aPG[16] # aRes[1]
      If aPG[16] == "F3"
         //Utilidad Bruta
         aPG[03] := aPG[01] - aPG[02]
      ElseIf aPG[16] == "F7"
         //Total Gastos Operacionales
         aPG[07] := aPG[05] + aPG[06]
      ElseIf aPG[16] == "F8"
         //Utilidad o Perdida Operacional
         aPG[08] := aPG[03] - aPG[07]
      ElseIf aPG[16] == "F12"
         //Utilidad o Perdida Antes   de Impuestos
         aPG[12] := aPG[08] + aPG[09] - aPG[10]
      ElseIf aPG[16] == "F14"
         //Utilidad o Perdida Despues de Impuestos
         aPG[14] := aPG[12] - aPG[13]
      EndIf
    //MsgInfo( TRANSFORM( aPG[nF],"999,999,999.99" ),aPG[16] )
      Guardar( "UPDATE pygrango SET valor = " + LTRIM(STR(aPG[nF]))+;
               " WHERE row_id = " + LTRIM(STR(aPG[17])), "pygrango" )
        aPG[16] := aRes[1]
        aPG[17] := aRes[2]
      nF ++
   EndIf
EndDo
 MSFreeResult( hRes )
RETURN aPG

//------------------------------------//
CLASS TCierre FROM TIMPRIME

 DATA aCab  AS ARRAY INIT { "",11,999,.t.,,0 }
 DATA aLS, lNIIF, oCtl, oMvc, oMvd, oPuc, oSec
 DATA cFor INIT "999,999,999,999.99"

 METHOD NEW( oDlg ) Constructor
 METHOD ListoPYG( aPG )
 METHOD Cabecera( lSep,nSpace,nSuma )
 METHOD ExcelPYG()
 METHOD ExcelSAL()
 METHOD BuscaMov( oDlg )
 METHOD Asiento( aMov,nSaldo )
 METHOD Acumula( aTot,oTB )

ENDCLASS

//------------------------------------//
METHOD NEW( oDlg ) CLASS TCierre
   LOCAL aPG
If oDlg == NIL
     aPG  := NtChr( DATE(),"1" )
   ::aLS  := { aPG,0,"",aPG,1,.f.,oApl:nTFor,1,.t.,.t.,1,"","" }
   ::aEnc := { .t.,"ESTADO DE RESULTADOS","PERIODO : " }
   ::oCtl := oApl:Abrir( "cgecntrl","empresa, ano_mes",.f.,,5 )
   ::oMvc := oApl:Abrir( "cgemovc" ,"empresa, ano_mes, control",.f.,,5 )
   ::oMvd := oApl:Abrir( "cgemovd" ,"empresa, ano_mes, control",.t.,,10 )
   ::oPuc := oApl:Abrir( "cgeplan" ,"empresa, cuenta",.f.,,5 )
   ::oSec := oApl:Abrir( "pygrango","empresa, secuencia" )
// ::oSec := oApl:Abrir( "cgesecue","empresa, consecutiv" )
   ::oMvd:nLimit := 2000
Else
   If MsgYesNo( "Que todo este Actualizado","REVISAR" )
      aPG := Vigente( LEFT(::aLS[4],4) )
   EndIf
   ::aLS[13] := ::aLS[1]
   ::aLS[4]  := If( RIGHT(::aLS[4],2) == "13", STUFF( ::aLS[4],5,2,"12" ), ::aLS[4] )
   ::aLS[1]  := STR( VAL( LEFT(::aLS[4],4) )-1,4 ) + "13"
   ::aCab[5] := CTOD( NtChr( NtChr( ::aLS[4],"F" ),"4" ) )
   ::aEnc[3] += NtChr( ::aCab[5],"3" )
   If ::aLS[2] > 0
      If RIGHT(::aLS[4],2) == "12"
           aPG    := ArmarPYG( ::oSec,::aLS[1],::aLS[4],::aLS[11] )
         ::aCab[1]:= STUFF( ::aLS[4],5,2,"13" )
         ::BuscaMov( oDlg )
      Else
         aPG := ">>>>> NO PUEDO HACER EL <<<<<"                          + CRLF +;
               {"Movimiento del Cierre","Cierre del Ejercicio"}[::aLS[2]]+ CRLF +;
                "Si el mes en el PERIODO FINAL es diferente de 12"
         MsgStop( aPG,"<<< OJO >>>" )
      EndIf
   ElseIf ::aLS[7] == 1
      ::oPrn := TDosPrint()
      ::oPrn:New( oApl:cPuerto,oApl:cImpres,{::aEnc[2],::aEnc[3]},::aLS[9] )
      ::oPrn:lTimbrado := ::aLS[6]
         ::ListoPYG( aPG )
      ::oPrn:NewPage()
      ::oPrn:End()
   ElseIf ::aLS[7] == 2
      ::Init( ::aEnc[2], .f. ,, !::aLS[9] )
        PAGE
          ::ListoPYG( aPG )
        ENDPAGE
      IMPRIME END .F.
   Else
      If ::aLS[8] >= 3
         ::aLS[1] := ::aLS[13]
      EndIf
      ::ExcelPYG()
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD ListoPYG( aPG ) CLASS TCierre
   LOCAL aRes, hRes, nF, nL
//nF   := (::aLS[5] + 1) * 2
aRes := { "4","6","8" }[::aLS[5]]
aRes := "SELECT r.cuentapyg, r.nombre, r.titulo, r.salto, r.db_cr, "+;
           "p.cuenta, p.nombre, SUM(a.valor_deb), SUM(a.valor_cre) "+;
        "FROM pygrango r LEFT JOIN cgeplan p"            +;
          " ON p.nivel    = " + LTRIM(STR(::aLS[5]+1))   +;
         " AND r.empresa  = p.empresa"                   +;
         " AND r.cuenta   = LEFT(p.cuenta,2) "           +;
                       " LEFT JOIN cgeacumc a"           +;
          " ON p.cuenta   = LEFT(a.cuenta," + aRes       +;
        ") AND a.empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND a.ano_mes >= " + xValToChar( ::aLS[1] )   +;
         " AND a.ano_mes <= " + xValToChar( ::aLS[4] )   +;
         " AND a.libro    = " +       STR(::aLS[11],2)   +;
       " WHERE r.empresa = " + LTRIM(STR(oApl:nPUC))     +;
         " AND LEFT(r.cuentapyg,1) NOT IN('B', 'C') "    +;
        "GROUP BY r.cuentapyg, p.cuenta ORDER BY r.secuencia, p.cuenta"
//       " AND LEFT(r.cuentapyg,1) <> 'B' "              +;
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   RETURN NIL
EndIf
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) },3 )
   aPG  := { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,aRes[1],aRes[2],.f.,0,"","" }
   nF   := 1
While nL > 0
   If aRes[3] == "S"
      aPG[16] := aPG[20] := aRes[1]
      aPG[18] := .t.
      aPG[19] := aRes[4]
      aPG[21] := aRes[2]
   ElseIf !EMPTY( aRes[6] )
      //      SaldoCta( aCue,cPerF,cPerI,nD )
      //aSal := SaldoCta( { aRes[8] },::aLS[4],::aLS[1],aRes[7] )
      aRes[8] := If( aRes[5] == 1, (aRes[8]-aRes[9]), (aRes[9]-aRes[8]) )
   EndIf
   If aRes[8] # 0
      If !::aLS[10]
         aPG[20] := aRes[6] := ""
      EndIf
      If ::aLS[7] == 1
         ::oPrn:Titulo( 80,,1 )
         If aPG[18]
            aPG[18] := .f.
            ::oPrn:Separator( aPG[19] )
            ::oPrn:Say( ::oPrn:nL,01,::oPrn:CPIBold + aPG[20] )
            ::oPrn:Say( ::oPrn:nL,13,aPG[21] + ::oPrn:CPIBoldN )
            ::oPrn:nL ++
         EndIf
            ::oPrn:Say( ::oPrn:nL,01,aRes[6] )
            ::oPrn:Say( ::oPrn:nL,13,aRes[7] )
            ::oPrn:Say( ::oPrn:nL,61,TRANSFORM( aRes[8],::cFor ) )
            ::oPrn:nL ++
      Else
         ::Cabecera( .t.,0 )
         If aPG[18]
            aPG[18] := .f.
            ::Cabecera( .t.,(aRes[4] / 2) )
            UTILPRN ::oUtil Self:nLinea, 2.0 SAY aPG[20] FONT ::aFnt[1]
            UTILPRN ::oUtil Self:nLinea, 3.0 SAY aPG[21] FONT ::aFnt[1]
            ::nLinea += .5
         EndIf
            UTILPRN ::oUtil Self:nLinea, 2.0 SAY aRes[6]
            UTILPRN ::oUtil Self:nLinea, 3.0 SAY aRes[7]
            UTILPRN ::oUtil Self:nLinea,16.5 SAY TRANSFORM( aRes[8],::cFor ) RIGHT
            ::nLinea += .5
      EndIf
      aPG[nF] += aRes[8]
      aRes[8] := 0
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) },3 )
   EndIf
   If nL == 0 .OR. aPG[16] # aRes[1]
      If aPG[16] == "F3"
         aPG[03] := aPG[01] - aPG[02]
      ElseIf aPG[16] == "F4" .AND. aPG[3] # 0
         If ::aLS[7] == 1
            ::oPrn:Separator( aPG[19] )
            ::oPrn:Say( ::oPrn:nL,13,::oPrn:CPIBold + aPG[21] + ::oPrn:CPIBoldN )
            ::oPrn:nL ++
         Else
            ::Cabecera( .t.,(aPG[19] / 2) )
            UTILPRN ::oUtil Self:nLinea, 3.0 SAY aPG[21] FONT ::aFnt[1]
            ::nLinea += .5
         EndIf
      ElseIf aPG[16] == "F7"
         aPG[07] := aPG[05] + aPG[06]
      ElseIf aPG[16] == "F8"
         aPG[08] := aPG[03] - aPG[07]
      ElseIf aPG[16] == "F12"
         aPG[12] := aPG[08] + aPG[09] - aPG[10]
      ElseIf aPG[16] == "F14"
         aPG[14] := aPG[12] - aPG[13]
      EndIf
      If aPG[nF] # 0
         If ::aLS[7] == 1
            If aPG[18]
               ::oPrn:Separator( aPG[19] )
               ::oPrn:Say( ::oPrn:nL,01,::oPrn:CPIBold + aPG[20] )
               ::oPrn:Say( ::oPrn:nL,13,aPG[21] + ::oPrn:CPIBoldN )
               ::oPrn:nL ++
            EndIf
            ::oPrn:Titulo( 80,,1 )
            ::oPrn:Say( ::oPrn:nL,00,::oPrn:CPIBold )
            ::oPrn:Say( ::oPrn:nL,13,aPG[17] )
            ::oPrn:Say( ::oPrn:nL,63,TRANSFORM( aPG[nF],::cFor ) + ::oPrn:CPIBoldN )
            ::oPrn:nL += 2
         Else
            If aPG[18]
               ::Cabecera( .t.,(aPG[19] / 2) )
               UTILPRN ::oUtil Self:nLinea, 2.0 SAY aPG[20] FONT ::aFnt[1]
               UTILPRN ::oUtil Self:nLinea, 3.0 SAY aPG[21] FONT ::aFnt[1]
               ::nLinea += .5
            EndIf
            ::Cabecera( .t.,0 )
            UTILPRN ::oUtil Self:nLinea, 3.0 SAY aPG[17] FONT ::aFnt[1]
            UTILPRN ::oUtil Self:nLinea,16.5 SAY TRANSFORM( aPG[nF],::cFor ) RIGHT
            ::nLinea ++
         EndIf
         aPG[18] := .f.
      EndIf
      If LEFT(aPG[16],1) == "F"
         aPG[18] := .f.
         nF ++
//         nF := VAL( SUBSTR(aRes[1],2,4) )
      EndIf
      aPG[16] := aRes[1]
      aPG[17] := aRes[2]
   EndIf
EndDo
 MSFreeResult( hRes )
If ::aLS[7] == 1
   ::oPrn:nL += 5
   ::oPrn:Say(  ::oPrn:nL,01,REPLICATE("_",30) + SPACE(15) + REPLICATE("_",30),,,1 )
   ::oPrn:Say(++::oPrn:nL,01,oApl:oEmp:GERENTE + SPACE(15) + oApl:oEmp:CONTADOR,,,1 )
   ::oPrn:Say(++::oPrn:nL,01,"        GERENTE" + SPACE(40) + "CONTADOR",,,1 )
Else
   ::Cabecera( .t.,1,2.0 )
   UTILPRN ::oUtil Self:nLinea,02.0 SAY REPLICATE("_",30) + SPACE(15) + REPLICATE("_",30)
   ::nLinea += 0.5
   UTILPRN ::oUtil Self:nLinea,02.0 SAY oApl:oEmp:GERENTE + SPACE(15) + oApl:oEmp:CONTADOR
   ::nLinea += 0.5
   UTILPRN ::oUtil Self:nLinea,02.0 SAY "        GERENTE" + SPACE(40) + "CONTADOR"
EndIf
RETURN NIL

//------------------------------------//
METHOD Cabecera( lSep,nSpace,nSuma ) CLASS TCierre
If lSep .AND. !::aEnc[1]
   ::aEnc[1] := ::Separator( nSpace,nSuma )
EndIf
If ::aEnc[1]
   ::aEnc[1] := .F.
   If !::aLS[6]
      ::Centrar( oApl:cEmpresa,::aFnt[4],1.0 )
      UTILPRN ::oUtil 1.5, 8.2 SAY "NIT: " + oApl:oEmp:Nit
      ::Centrar( ::aEnc[2],,2.0 )
   EndIf
      ::Centrar( ::aEnc[3],,2.5 )
   ::nLinea := 3.5
EndIf
RETURN NIL

//------------------------------------//
METHOD ExcelPYG() CLASS TCierre
   LOCAL aEX, aPG, aRes, aSal, hRes, nF, nE, nL
   LOCAL cQry, oExcel
aSal := "SELECT r.cuentapyg, r.nombre, r.titulo, r.salto, r.db_cr, p.cuenta, p.nombre "+;
        "FROM pygrango r LEFT JOIN cgeplan p"        +;
          " ON p.nivel   = " + LTRIM(STR(::aLS[5]+1))+;
         " AND r.empresa = p.empresa"                +;
         " AND r.cuenta  = LEFT(p.cuenta,2) "        +;
        "WHERE r.empresa = " + LTRIM(STR(oApl:nPUC)) +;
         " AND LEFT(r.cuentapyg,1) NOT IN('B', 'C') "+;
        "ORDER BY r.secuencia, p.cuenta"
hRes := If( MSQuery( oApl:oMySql:hConnect,aSal ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   RETURN NIL
EndIf
 aEX := cFilePath( GetModuleFileName( GetInstance() )) + "PYG.xls"
If EMPTY(aEX)
   MSFreeResult( hRes )
   RETURN NIL
EndIf
aRes := {"ENE","FEB","MAR","ABR","MAY","JUN","JUL","AGO","SEP","OCT","NOV","DIC" }
aSal := "SELECT SUM(valor_deb), SUM(valor_cre) "
cQry := "FROM cgeacumc "                               +;
        "WHERE empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND libro    = " +       STR(::aLS[11],2)   +;
         " AND LEFT(cuenta,"+ { "4","6","8" }[::aLS[5]]+ ") = '[CTA]'"
If ::aLS[8] <= 2
   cQry := aSal + cQry +;
         " AND ano_mes >= " + xValToChar( ::aLS[1] )   +;
         " AND ano_mes <= " + xValToChar( ::aLS[4] )
   nE   := { 2,3 }[::aLS[8]]
   aPG  := { aRes[VAL(RIGHT(::aLS[4],2))]  + ". " + LEFT(::aLS[4],4) }
   If nE == 3
      ::aLS[12] := STR( VAL( LEFT(::aLS[13],4) )-1,4 ) + "13"
      AADD( aPG,STRTRAN( aPG[1],LEFT(::aLS[4],4),LEFT(::aLS[13],4) ) )
   EndIf
ElseIf ::aLS[8] == 3
   cQry := aSal + ", ano_mes " + cQry +;
         " AND ano_mes IN(" + xValToChar( ::aLS[1] )   +;
                       ", " + xValToChar( ::aLS[4] )   +;
        ") GROUP BY ano_mes"
   aPG  := { aRes[VAL(RIGHT(::aLS[4],2))]  + ". " + LEFT(::aLS[4],4),;
             aRes[VAL(RIGHT(::aLS[1],2))]  + ". " + LEFT(::aLS[1],4) }
   nE   := 3
Else
   cQry := aSal + ", ano_mes " + cQry +;
         " AND ano_mes >= " + xValToChar( ::aLS[1] )   +;
         " AND ano_mes <= " + xValToChar( ::aLS[4] )   +;
         " GROUP BY ano_mes ORDER BY ano_mes"
   nE   := VAL( RIGHT(::aLS[4],2) )+1
   aPG  := {}
   FOR nF := 1 TO nE - 1
      AADD( aPG,aRes[nF] + ". " + LEFT(::aLS[4],4) )
   NEXT nF
EndIf
   oApl:oWnd:SetMsg( "Exportando hacia "+aEX )
   oExcel := TExcelScript():New()
   oExcel:Create( aEX )
   oExcel:Font("Verdana")
 //oExcel:Size(10)
 //oExcel:Align(1)
   oExcel:Visualizar(.F.)
/*
   oExcel:Say( nRow, nCol, xValue, cFont, nSize, lBold, lItalic, ;
               lUnderLine, nAlign, nColor, nFondo , nOrien , nStyle , cFormat )
*/
   oExcel:Say(  1 , 2 , oApl:cEmpresa, , 14 ,,,,,,,, 0  )
   oExcel:Say(  2 , 2 , "NIT: " + oApl:oEmp:Nit, ,12 ,,,, 7,,,, 0 )
   oExcel:Say(  3 , 2 , ::aEnc[2], , 12 ,,,, 7,,,, 0  )
   oExcel:Say(  4 , 2 , ::aEnc[3], , 12 ,,,, 7,,,, 0  )
   FOR nF := 1 TO LEN( aPG )
      oExcel:ColumnWidth( nF+2 , 16 )
      oExcel:Say( 5, nF+2, aPG[nF],,,,,, 7,,,, 0, "Text" )
   NEXT nF
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) },3 )
   aEX  := { "","","","","","","","","","","","","","","" }
   aPG  := { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,aRes[1],aRes[2],.f.,0,"","" }
   aSal := ARRAY(nE)
   nE   := 6
   nF   := 1
 ::cFor := "#.##0,00"
AFILL( aSal,0 )
While nL > 0
   If aRes[3] == "S"
      aPG[16] := aPG[20] := aRes[1]
      aPG[18] := .t.
      aPG[19] := aRes[4]
      aPG[21] := aRes[2]
   ElseIf !EMPTY( aRes[6] )
      ::ExcelSAL( STRTRAN( cQry,"[CTA]",ALLTRIM( aRes[6] ) ),@aSal,aRes[5] )
   EndIf

   If aSal[1] > 0
      If !::aLS[10]
         aPG[20] := aRes[6] := ""
      EndIf
      If aPG[18]
         aPG[18] := .f.
         nE += aPG[19]
         oExcel:Say( nE, 1, aPG[20],,, .t.,,, 2,,,,, "Text" )
         oExcel:Say( nE, 2, aPG[21],,, .t. )
         nE ++
      EndIf
      If aEX[nF] == ""
         aEX[nF] := "C" + LTRIM(STR(nE))
      EndIf
         oExcel:Say( nE, 1, aRes[6],,,,,, 2 )
         oExcel:Say( nE, 2, aRes[7] )
         AEVAL( aSal, {| xV,nP | oExcel:Say( nE, nP+1, xV,,,,,,,,,,, ::cFor ) },2 )
       //oExcel:Say( nE, 3, aRes[8],,,,,,,,,,, ::cFor )
         nE ++
      aPG[nF] += aSal[2]
      aSal[1] := 0
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) },3 )
   EndIf
   If nL == 0 .OR. aPG[16] # aRes[1]
      If aPG[16] == "F3"
         aPG[03] := aPG[01] - aPG[02]
         aEX[15] := If( aEX[01] == "", "",       aEX[01] )+;
                    If( aEX[02] == "", "", "-" + aEX[02] )
      ElseIf aPG[16] == "F4" .AND. aPG[3] # 0
         If ::aLS[7] == 1
            nE += aPG[19]
            oExcel:Say( nE, 2, aPG[21] )
            nE ++
         EndIf
      ElseIf aPG[16] == "F7"
         aPG[07] := aPG[05] + aPG[06]
         aEX[15] := If( aEX[05] == "", "",       aEX[05] )+;
                    If( aEX[06] == "", "", "+" + aEX[06] )
      ElseIf aPG[16] == "F8"
         aPG[08] := aPG[03] - aPG[07]
         aEX[15] := If( aEX[03] == "", "",       aEX[03] )+;
                    If( aEX[07] == "", "", "-" + aEX[07] )
      ElseIf aPG[16] == "F12"
         aPG[12] := aPG[08] + aPG[09] - aPG[10]
         aEX[15] := If( aEX[08] == "", "",       aEX[08] )+;
                    If( aEX[09] == "", "", "+" + aEX[09] )+;
                    If( aEX[10] == "", "", "-" + aEX[10] )
      ElseIf aPG[16] == "F14"
         aPG[14] := aPG[12] - aPG[13]
         aEX[15] := If( aEX[12] == "", "",       aEX[12] )+;
                    If( aEX[13] == "", "", "-" + aEX[13] )
      EndIf
      If aPG[nF] # 0
         If aPG[18]
            nE += aPG[19]
            oExcel:Say( nE, 1, aPG[20],,, .t.,,, 2 )
            oExcel:Say( nE, 2, aPG[21],,, .t. )
            nE ++
            aEX[nF] := "C" + LTRIM(STR(nE))
         EndIf
         If !Rango( nF,{3,7,8,12,14} )
            aEX[15] := "SUMA(" + aEX[nF] + ":C" + LTRIM(STR(nE-1)) + ")"
         EndIf
            oExcel:Say( nE, 2, aPG[17],,, .t. )
         AEVAL( aSal, {| xV,nP | oExcel:Say( nE, nP+1, "="+aEX[15],,, .t.,,,,,,,, ::cFor ),;
                         aEX[15] := STRTRAN( aEX[15],CHR(nP+65),CHR(nP+66) ) },2 )
          //oExcel:Say( nE, 3, "="+aEX[15],,, .t. )
          //oExcel:Say( nE, 3, "=SUMA(C12:C14)")
         aEX[nF] := "C" + LTRIM(STR(nE))
         aPG[18] := .f.
              nE += 2
      EndIf
      If LEFT(aPG[16],1) == "F"
         aPG[18] := .f.
         nF ++
      EndIf
      aPG[16] := aRes[1]
      aPG[17] := aRes[2]
   EndIf
EndDo
 MSFreeResult( hRes )
   nF := LEN( aSal ) + 65
   oExcel:Borders("A1:" + CHR(nF) + LTRIM(STR(nE)) ,,, 3 )
   oExcel:ColumnWidth( 2 , 45 )
   oExcel:Visualizar(.T.)
 //oExcel:Save()
   oExcel:End(.f.) ; oExcel := NIL
RETURN NIL

//------------------------------------//
METHOD ExcelSAL( cQry,aSal,nD ) CLASS TCierre
   LOCAL aRes, hRes, nL, nM := 2
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
AFILL( aSal,0 )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If ::aLS[8] == 3
      nM := If( aRes[3] == ::aLS[4], 2, 3 )
   ElseIf ::aLS[8] == 4
      nM := VAL( RIGHT(aRes[3],2) ) + 1
   EndIf
   aRes[01] := If( nD == 1, (aRes[1]-aRes[2]), (aRes[2]-aRes[1]) )
   aSal[nM] += aRes[1]
   aSal[01] += If( aRes[1] # 0, 1 , 0 )
   nL --
EndDo
 MSFreeResult( hRes )
If ::aLS[8] == 2
   cQry := STRTRAN( cQry,"= '" +::aLS[1],"= '" +::aLS[12] )
   cQry := STRTRAN( cQry,"= '" +::aLS[4],"= '" +::aLS[13] )
   aRes := Buscar( cQry,"CM",,8 )
   If LEN( aRes ) > 0
      aRes[1] := If( nD == 1, (aRes[1]-aRes[2]), (aRes[2]-aRes[1]) )
      aSal[3] += aRes[1]
      aSal[1] += If( aRes[1] # 0, 1 , 0 )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD BuscaMov( oDlg ) CLASS TCierre
   LOCAL aRes, cQry, hRes, nL, nReser := 0, nSaldo, oTB
 ::oCtl:Seek( {"empresa",oApl:nEmpresa,"ano_mes",::aCab[1]} )
 oApl:oNit:Seek( {"codigo",1} )
 ::aCab[6] := oApl:oNit:CODIGO_NIT
If ::aLS[2] == 1
   If ::oMvc:Seek( {"empresa",oApl:nEmpresa,"ano_mes",::aCab[1],;
                    "fuente",11,"comprobant",999} )
      If ::oMvc:ESTADO == 1
         cQry := "El Movimiento de Cierre en "+::aCab[1]+" ya esta Hecho" + CRLF +;
                 "y fue Actualizado.  Si lo quiere hacer de nuevo tiene"  + CRLF +;
                 "que reversarlo en la opcion ACTUALIZA MOVIMIENTO."      + CRLF +;
                 "Sino lo que tiene que hacer es el Cierre Definitivo"
         MsgStop( cQry,"<<< OJO >>>" )
         RETURN NIL
      EndIf
      oDlg:SetText( "<< ESPERE >> BORRANDO ASIENTO" )
      cQry := "UPDATE cgemovd SET empresa = -9 "            +;
              "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND ano_mes = " + xValToChar( ::aCab[1] )  +;
               " AND control = " + LTRIM( STR( ::oMvc:CONTROL ) )
      MSQuery( oApl:oMySql:hConnect,cQry )
    //  ::oMvd:dbEval( {|o| o:EMPRESA := -9, Acumular( o,3,3,.f.,.f. ) },;
    //                 {"empresa",oApl:nEmpresa,"ano_mes",::aCab[1],"control",::oMvc:CONTROL} )
      ::oMvc:CONSECUTIV := 0 ; ::oMvc:Update( .t.,1 )
   Else
      ::aCab[4] := .f.
      ::oMvc:xBlank()
      ::oMvc:FECHA    := ::aCab[5]
      ::oMvc:CONCEPTO := "MOVIMIENTO DE CIERRE DEL EJERCICIO"
   EndIf
   oDlg:SetText( "<< ESPERE >> GENERANDO MOVIMIENTO" )
   ::aLS[5] := 0
   // Version Nueva Cierre
   ::lNIIF := If( !EMPTY(oApl:oEmp:NIIF) .AND. ::aCab[1] >= oApl:oEmp:NIIF, .t., .f. )
   ::oSec:Seek( {"empresa",oApl:nPUC,"LEFT(cuentapyg,1)","F"},"secuencia" )
   While !::oSec:Eof()
      If !EMPTY( ::oSec:CUENTA )
         ::aLS[3] := RTRIM( ::oSec:CUENTA )
         oDlg:Update()
         cQry := "SELECT cuenta, codigo, codigo_nit, libro, "                   +;
                    "SUM(valor_deb)-SUM(valor_cre) "                            +;
                 "FROM cgeacumn "                                               +;
                 "WHERE empresa = "  + LTRIM(STR(oApl:nEmpresa))                +;
                 " AND LEFT(cuenta," + STR(LEN(::aLS[3]),2) + ") = '" + ::aLS[3]+;
                "' AND ano_mes >= '" +     ::aLS[1]    +;
                "' AND ano_mes <= '" +     ::aLS[4]    +;
                "' GROUP BY cuenta, codigo, codigo_nit, libro" +;
                 " ORDER BY cuenta, codigo, codigo_nit, libro"
         hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
                     MSStoreResult( oApl:oMySql:hConnect ), 0 )
         nL   := MSNumRows( hRes )
         While nL > 0
            aRes := MyReadRow( hRes )
            AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
            If aRes[5] # 0
               ::Asiento( { aRes[1],aRes[2],aRes[3],aRes[4] },aRes[5] )
            EndIf
            nL --
         EndDo
         MSFreeResult( hRes )
      ElseIf !EMPTY( ::oSec:CUENTA_R )
         If ::oSec:VALOR # 0
            nSaldo    := ::oSec:VALOR
            If ::oSec:CUENTAPYG == "F14       "
               //Utilidad Repartirla entre los socios
               cQry := "SELECT codigo_nit, porcentaje FROM cgesocio " +;
                       "WHERE empresa = "  + LTRIM(STR(oApl:nEmpresa))
               hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
                           MSStoreResult( oApl:oMySql:hConnect ), 0 )
               nL   := MSNumRows( hRes )
               cQry := If( nSaldo > 0, ::oSec:CUENTA_R, ::oSec:CODIGO_R )
               While nL > 0
                  aRes := MyReadRow( hRes )
                  AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
                  nSaldo := ROUND( ::oSec:VALOR*aRes[2]/100,2 )
                  nL --
                  If nL == 0
                     nSaldo := ::oSec:VALOR - nReser
                  EndIf
                  nReser += ABS(nSaldo)
                //nSaldo *= -1
                  ::Asiento( { cQry,::oSec:CODIGO_R,aRes[1],1 },nSaldo )
                  If ::lNIIF
                     ::Asiento( { cQry,::oSec:CODIGO_R,aRes[1],2 },nSaldo )
                  EndIf
               EndDo
               MSFreeResult( hRes )
            Else
               ::Asiento( {::oSec:CUENTA_R,::oSec:CODIGO_R,::oSec:CODIGO_NIT,1},nSaldo )
               If ::lNIIF
                  ::Asiento( {::oSec:CUENTA_R,::oSec:CODIGO_R,::oSec:CODIGO_NIT,2},nSaldo )
               EndIf
            EndIf
         EndIf
      EndIf
      ::oSec:Skip(1):Read()
      ::oSec:xLoad()
   EndDo
   oDlg:SetText( "<< ESPERE >> R E V E R S A N D O" )
   ::aLS[1] := ::aCab[1]
   ::aLS[2] := 2
   Actualiza( ::aLS,oDlg )     //REVERSAR
   ::aLS[2] := 1
   Actualiza( ::aLS,oDlg )     //ACTUALIZAR
   cQry := "1. Revisar Movimiento del Cierre en "  + ::aCab[1] + CRLF +;
           "2. LISTAR BALANCE DE PRUEBA A "        + ::aCab[1] + CRLF +;
           "3. LISTAR ANEXOS AL BALANCE A "        + ::aCab[1] + CRLF +;
           "4. LISTAR LIBRO DE MAYOR Y BALANCES A "+ ::aCab[1] + CRLF +;
           "5. LISTAR BALANCE GENERAL A "          + ::aCab[1] + CRLF +;
           "Estoy listo para hacer el Cierre Definitivo"
    MsgStop( cQry,">>> OJO <<<" )
/*
   // Version Vieja Cierre
   ::oSec:Seek( {"empresa",oApl:nPUC},"consecutiv" )
   While !::oSec:Eof()
      If LEFT( ::oSec:CUENTA,1 ) # "0"
         ::aLS[3] := RTRIM( ::oSec:CUENTA )
         oDlg:Update()
         cQry := "SELECT cuenta, codigo, codigo_nit, SUM(valor_deb)-SUM(valor_cre) "+;
                 "FROM cgeacumn "                                                   +;
                 "WHERE empresa = "  + LTRIM(STR(oApl:nEmpresa))                    +;
                 " AND LEFT(cuenta," + STR(LEN(::aLS[3]),2) + ") = '" + ::aLS[3]    +;
                "' AND ano_mes >= '" + ::aLS[1] +;
                "' AND ano_mes <= '" + ::aLS[4] +;
                "' GROUP BY cuenta, codigo, codigo_nit"+;
                 " ORDER BY cuenta, codigo, codigo_nit"
         hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
                     MSStoreResult( oApl:oMySql:hConnect ), 0 )
         nL   := MSNumRows( hRes )
         While nL > 0
            aRes := MyReadRow( hRes )
            AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
            If aRes[4] # 0
               ::Asiento( { aRes[1],aRes[2],aRes[3] },aRes[4] )
            EndIf
            nL --
         EndDo
         MSFreeResult( hRes )
      Else
         ::aLS[5] := If( ::oSec:CUENTA == "0003      ", ::oSec:VALOR, ::aLS[5] )
         If !EMPTY( ::oSec:CUENTA_R ) .AND. ::oSec:VALOR # 0
            nSaldo    := ::oSec:VALOR
            If ::oSec:CUENTA == "0005      " .AND. ;
               ABS(nSaldo)  == ABS(::aLS[5])
               nSaldo := 0
            EndIf
            If ::oSec:PYG == "UTILIDAD  "                 //36050501
               cQry := "SELECT codigo_nit, porcentaje FROM cgesocio " +;
                       "WHERE empresa = "  + LTRIM(STR(oApl:nEmpresa))
               hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
                           MSStoreResult( oApl:oMySql:hConnect ), 0 )
               nL   := MSNumRows( hRes )
             //cQry := If( nSaldo > 0, ::oSec:CUENTA_R, STUFF( ::oSec:CUENTA_R,3,2,"10" ) )
               cQry := If( ::oSec:CUENTA_R == "36050501  ", "37", "36" )
               While nL > 0
                  aRes := MyReadRow( hRes )
                  AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
                  nSaldo := ROUND( ::oSec:VALOR*aRes[2]/100,2 )
                  nL --
                  If nL == 0
                     nSaldo := ::oSec:VALOR - nReser
                  EndIf
                  nReser += nSaldo
                  nSaldo *= -1
                  ::Asiento( { cQry+"050501",::oSec:CODIGO_R,aRes[1] },nSaldo )
               // ::Asiento( { ::oSec:CUENTA_R,::oSec:CODIGO_R,aRes[1]} )
               EndDo
               MSFreeResult( hRes )
            Else
               ::Asiento( {::oSec:CUENTA_R,::oSec:CODIGO_R,::oSec:CODIGO_NIR},nSaldo )
            EndIf
         EndIf
      EndIf
      ::oSec:Skip(1):Read()
      ::oSec:xLoad()
   EndDo
*/
ELse
   If !::oCtl:lOK .AND. RIGHT( ::aCab[1],2 ) == "13"
      ::oCtl:xBlank()
      ::oCtl:lOK     := .t.
      ::oCtl:EMPRESA := oApl:nEmpresa
      ::oCtl:ANO_MES := ::aCab[1]
      ::oCtl:Append( .t. )
   ElseIf ::oCtl:lOK .AND. ::oCtl:CIERRE
      MsgStop( "El Cierre ya fue Hecho, Si quiere hacerlo de nuevo Desactualice" )
      RETURN NIL
   EndIf
// cQry := "1. Hacer Movimiento del Cierre y Actualizarlo en "+ ::aCab[1] + CRLF +;
   cQry := "1. Hacer Movimiento del Cierre en "    + ::aCab[1] + CRLF +;
           "2. LISTAR BALANCE DE PRUEBA A "        + ::aCab[1] + CRLF +;
           "3. LISTAR ANEXOS AL BALANCE A "        + ::aCab[1] + CRLF +;
           "4. LISTAR LIBRO DE MAYOR Y BALANCES A "+ ::aCab[1] + CRLF +;
           "5. LISTAR BALANCE GENERAL A "          + ::aCab[1] + CRLF +;
           "Estoy listo para hacer el Cierre Definitivo"
   If !MsgYesNo( cQry,"Si ya Hizo los siguientes Pasos" )
      RETURN NIL
   EndIf
   oDlg:SetText( "<< ESPERE >> HACIENDO EL CIERRE" )
// CALL sp_cierre( oApl:nEmpresa, ::aLS[1], ::aLS[4],::aCab[1] )
   oTB  := oApl:Abrir( "cgeacumc","empresa",.f.,,2 )
   cQry := "SELECT cuenta, libro, SUM(valor_deb), SUM(valor_cre) "+;
           "FROM cgeacumc "                                +;
           "WHERE empresa = "  + LTRIM(STR(oApl:nEmpresa)) +;
           " AND ano_mes >= '" + ::aLS[1] +;
          "' AND ano_mes <= '" + ::aLS[4] +;
          "' GROUP BY cuenta, libro ORDER BY cuenta, libro"
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   While nL > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      ::aLS[3] := aRes[1] ; oDlg:Update()
      oTB:Seek( {"empresa",oApl:nEmpresa,"cuenta",aRes[1],"ano_mes",::aCab[1]} )
      ::Acumula( aRes,oTB )
      nL --
   EndDo
   MSFreeResult( hRes ) ; oTB:Destroy()
   oTB  := oApl:Abrir( "cgeacumn","empresa",.f.,,2 )
   cQry := "SELECT cuenta, codigo, codigo_nit, libro, SUM(valor_deb), SUM(valor_cre) "+;
           "FROM cgeacumn "                               +;
           "WHERE empresa = "  + LTRIM(STR(oApl:nEmpresa))+;
           " AND ano_mes >= '" + ::aLS[1]                 +;
          "' AND ano_mes <= '" + ::aLS[4]                 +;
          "' GROUP BY cuenta, codigo, codigo_nit, libro"  +;
           " ORDER BY cuenta, codigo, codigo_nit, libro"
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   While nL > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      ::aLS[3] := aRes[1] ; oDlg:Update()
      oTB:Seek( {"empresa",oApl:nEmpresa,"cuenta",aRes[1],"codigo",aRes[2],;
                 "codigo_nit",aRes[3],"ano_mes",::aCab[1]} )
      ::Acumula( aRes,oTB )
      nL --
   EndDo
   MSFreeResult( hRes ) ; oTB:Destroy()
   Guardar( "UPDATE cgecntrl SET cierre = '1' "            +;
            "WHERE empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
             " AND ano_mes <= '"+ ::aCab[1] + "'", "cgecntrl" )
EndIf
RETURN NIL

//------------------------------------//
METHOD Asiento( aMov,nSaldo ) CLASS TCierre
   LOCAL aR := { "","","","",0,0 }, cQry, nP
If nSaldo = 0
   RETURN NIL
EndIf
If aMov[1] # ::oPuc:CUENTA
   If !::oPuc:Seek( {"empresa",oApl:nPuc,"cuenta",aMov[1]} )
      MsgInfo( "Cuenta no EXISTE",aMov[1] )
   EndIf
EndIf
If EMPTY( aMov[2] )
   If InfAc( ::oPuc,@nP,"NIT" )
      aMov[3] := If( aMov[3] == 0, ::aCab[6], aMov[3] )
      If !oApl:oNit:Seek( {"codigo_nit",aMov[3]} )
         MsgInfo( "Codigo_nit no EXISTE",aMov[3] )
      EndIf
      aR[nP] := LTRIM(STR(oApl:oNit:CODIGO))
   EndIf
ElseIf InfAc( ::oPuc,@nP )
   aR[nP] := aMov[2]
EndIf

If !::aCab[4]
   If !::oCtl:lOK
      ::oCtl:xBlank()
      ::oCtl:lOK     := .t.
      ::oCtl:EMPRESA := oApl:nEmpresa
      ::oCtl:ANO_MES := ::aCab[1]
      ::oCtl:Append( .t. )
   EndIf
   ::aCab[4]         := .t.
   ::oMvc:EMPRESA    := oApl:nEmpresa
   ::oMvc:ANO_MES    := ::aCab[1]
   ::oMvc:FUENTE     := ::aCab[2]
   ::oMvc:COMPROBANT := ::aCab[3]
   ::oMvc:CONTROL    := SgteCntrl( "control",::aCab[1],.t. )
 //::oMvc:ESTADO     := 1
   ::oMvc:Append( .t. )
EndIf
If nSaldo < 0
   aR[5] := nSaldo * -1
Else
   aR[6] := nSaldo
EndIf
   cQry := "INSERT INTO cgemovd VALUES ( null, "+ LTRIM(STR(oApl:nEmpresa))+ ", '"+;
           ::aCab[1]     + "', "  + LTRIM(STR(::oMvc:CONTROL))             + ", '"+;
           TRIM(aMov[1]) + "', '" + TRIM(aR[1]) + "', '" + TRIM(aR[2])    + "', '"+;
           TRIM(aR[3])   + "', '" + TRIM(aR[4]) + "', "  + LTRIM(STR(aMov[3]))    +;
           ", " + LTRIM(STR(aR[5])) + ", " + LTRIM(STR(aR[6]))             + ", " +;
           STR(aMov[4],1) + ", NULL )"
If !MSQuery( oApl:oMySql:hConnect,cQry )
   oApl:oMySql:oError:Display( .f. )
//Else
//   oApl:oWnd:SetMsg( "Cuenta = "+aMov[1] )
EndIf
/*
 ::oMvd:Seek( "empresa = -9 LIMIT 1","CM" )
 ::oMvd:EMPRESA   := oApl:nEmpresa ; ::oMvd:ANO_MES  := ::aCab[1]
 ::oMvd:CONTROL   := ::oMvc:CONTROL; ::oMvd:CUENTA   := aMov[1]
 ::oMvd:INFA      := aR[1]         ; ::oMvd:INFB     := aR[2]
 ::oMvd:INFC      := aR[3]         ; ::oMvd:INFD     := aR[4]
 ::oMvd:CODIGO_NIT:= aMov[3]
 ::oMvd:VALOR_DEB := aR[5]         ; ::oMvd:VALOR_CRE:= aR[6]
 Acumular( ::oMvd,2,2,!::oMvd:lOK,.f. )
*/
 ::oMvc:CONSECUTIV ++
 ::oMvc:Update( .t.,1 )

RETURN NIL

//------------------------------------//
METHOD Acumula( aTot,oTB ) CLASS TCierre
   LOCAL nT := LEN( aTot )
If aTot[nT-1] # 0 .OR. aTot[nT] # 0
   aTot[nT-1] -= aTot[nT]
   If aTot[nT-1] > 0
      aTot[nT]  := 0
   Else
      aTot[nT]  := aTot[nT-1] * -1
      aTot[nT-1]:= 0
   EndIf
   If oTB:lOK
      oTB:VALOR_DEB += aTot[nT-1] ; oTB:VALOR_CRE += aTot[nT]
      oTB:Update( .t.,1 )
   Else
      oTB:EMPRESA := oApl:nEmpresa; oTB:ANO_MES := ::aCab[1]
      oTB:CUENTA  := aTot[1]      ; oTB:LIBRO   := aTot[nT-2]
      If nT == 6
         oTB:CODIGO := aTot[2] ; oTB:CODIGO_NIT := aTot[3]
      EndIf
      oTB:VALOR_DEB := aTot[nT-1] ; oTB:VALOR_CRE := aTot[nT]
      oTB:Append(.f.)
   EndIf
EndIf
RETURN NIL