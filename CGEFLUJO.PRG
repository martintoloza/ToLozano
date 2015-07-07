// Programa.: CGEFLUJO.PRG    >>> Martin A. Toloza L. <<<
// Notas....: Flujo de Caja.
#include "Fivewin.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE CgeFlujo()
   LOCAL oDlg, oGet := ARRAY(8)
   LOCAL oAC := TFlujo()
oAC:New()
DEFINE DIALOG oDlg TITLE oAC:aEnc[2] FROM 0, 0 TO 12,50
   @ 02,00 SAY "PERIODO INICIAL"  OF oDlg RIGHT PIXEL SIZE 70,10
   @ 02,72 GET oGet[1] VAR oAC:aLS[1] OF oDlg PICTURE "999999" SIZE 28,10 PIXEL;
      VALID NtChr( oAC:aLS[1],"P" )
   @ 14,00 SAY "PERIODO   FINAL"  OF oDlg RIGHT PIXEL SIZE 70,10
   @ 14,72 GET oGet[2] VAR oAC:aLS[2] OF oDlg PICTURE "999999" SIZE 28,10 PIXEL;
      VALID NtChr( oAC:aLS[2],"P" )
   @ 26,00 SAY "NIVEL [1/2/3/4]"  OF oDlg RIGHT PIXEL SIZE 70,10
   @ 26,72 COMBOBOX oGet[3] VAR oAC:aLS[3] ITEMS { "Grupo(2)","Cuenta(4)","SubCuenta(6)","Auxiliar(8)" };
      SIZE 48,90 OF oDlg PIXEL
   @ 38,00 SAY "Libro" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 38,82 COMBOBOX oGet[4] VAR oAC:aLS[6] ITEMS { "COLGAAP","IFRS" };
      SIZE 48,90 OF oDlg PIXEL;
      WHEN !EMPTY(oApl:oEmp:NIIF) .AND. oAC:aLS[1] >= oApl:oEmp:NIIF
   @ 50,00 SAY "CLASE DE LISTADO" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 50,72 COMBOBOX oGet[5] VAR oAC:aLS[4] ITEMS { "Matriz","Laser","Excel" };
      SIZE 48,90 OF oDlg PIXEL
   @ 50,144 CHECKBOX oGet[6] VAR oAC:aLS[5] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,10 PIXEL

   @ 64, 50 BUTTON oGet[7] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
       ( oGet[7]:Disable(), oAC:NEW( oDlg ), oDlg:End() ) PIXEL
   @ 64,100 BUTTON oGet[8] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 67,02 SAY "[CGEFLUJO]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT Empresa( .t. )

oAC:oSec:Destroy()
RETURN

/*
INSERT INTO pygrango
  (empresa, secuencia, cuentapyg, nombre, totaliza, cuenta)
VALUES(4, 1,'C1', 'INGRESOS', 'N', '11'),
      (4, 2,'C2', 'EGRESOS' , 'N', '11'),
      (4, 3,'C3', 'VENTAS'  , 'N', '11,41'),
      (4, 4,'C7', 'VARIOS'  , 'S', '11,21');
*/

//------------------------------------//
CLASS TFlujo FROM TIMPRIME

 DATA aLS, oSec
 DATA cFor INIT "999,999,999,999.99"

 METHOD NEW( oDlg ) Constructor
 METHOD BuscaMov( oDlg )
 METHOD ListoPYG( aPG )
 METHOD Cabecera( lSep,nSpace,nSuma )
 METHOD FCExcel()
 METHOD FCOffice()
 METHOD FCOfficx()

ENDCLASS

//------------------------------------//
METHOD NEW( oDlg ) CLASS TFlujo
   LOCAL aPG
If oDlg == NIL
     aPG  := NtChr( DATE(),"1" )
   ::aLS  := { aPG,aPG,1,oApl:nTFor,.t.,1,"","","",0 }
   ::aEnc := { .t.,"FLUJO DE CAJA","PERIODO : " }
   ::oSec := oApl:Abrir( "pygrango","empresa, secuencia" )
Else
   aPG      := ::aLS
   Swap( @aPG,1,2 ) //Periodo
   ::aLS    := aPG
   If ::aLS[1]  # ::aLS[2] .AND. ::aLS[4] <= 2
      ::aLS[1] := ::aLS[2]
   EndIf
      ::aLS[7] := STR( VAL( LEFT(::aLS[1],4) )-1,4 ) + "13"
   If RIGHT(::aLS[1],2) == "01"
      ::aLS[8] := STR( VAL( LEFT(::aLS[1],4) )-1,4 ) + "13"
   Else
      ::aLS[8] := STR( VAL( ::aLS[1] )-1,6 )
   EndIf
   ::oSec:Seek( {"empresa",oApl:nPUC,"LEFT(cuentapyg,1)","C"},"secuencia" )
   ::aLS[9]  := LEFT(::oSec:CUENTA,2)
   aPG := SaldoCta( { ::aLS[9] },::aLS[8],::aLS[7],1,::aLS[6] )
   ::aLS[08] := CTOD( NtChr( NtChr( ::aLS[2],"F" ),"4" ) )
   ::aLS[10] := aPG[3]
   ::aEnc[3] += NtChr( ::aLS[8],"3" )
   ::BuscaMov()
   If ::aLS[4] == 1
      ::oPrn := TDosPrint()
      ::oPrn:New( oApl:cPuerto,oApl:cImpres,{::aEnc[2],::aEnc[3]},::aLS[5] )
         ::ListoPYG( aPG )
      ::oPrn:NewPage()
      ::oPrn:End()
   ElseIf ::aLS[4] == 2
      ::Init( ::aEnc[2], .f. ,, !::aLS[5] )
        PAGE
          ::ListoPYG( aPG )
        ENDPAGE
      IMPRIME END .F.
   ElseIf oApl:lOffice
      ::FCOffice()
   Else
      ::FCExcel()
   EndIf
   MSQuery( oApl:oMySql:hConnect,"DROP TABLE flujocaja" )
EndIf
RETURN NIL

//------------------------------------//
METHOD BuscaMov() CLASS TFlujo
   LOCAL aCta, aRes, cFlu, cQry, cMes, hRes, nL
MSQuery( oApl:oMySql:hConnect,"DROP TABLE flujocaja" )
cQry := "CREATE TEMPORARY TABLE flujocaja ( "             +;
            "fuente  INT(2)       NOT NULL, "             +;
            "cuenta  VARCHAR(10)  NOT NULL, "             +;
            "anomes  VARCHAR(06)  NOT NULL, "             +;
            "nombre  VARCHAR(40)  NOT NULL, "             +;
            "debito  DOUBLE(12,2) NOT NULL DEFAULT 0.00, "+;
            "credito DOUBLE(12,2) NOT NULL DEFAULT 0.00 )"+;
        " ENGINE=MEMORY"
MSQuery( oApl:oMySql:hConnect,cQry )

// Introducimos datos en el cursor
aRes := { "2)","4)","6)","8)" }[::aLS[3]]
cQry := "INSERT INTO flujocaja (fuente, cuenta, anomes, nombre, debito, credito) "           +;
        "SELECT c.fuente, p.cuenta, d.ano_mes, p.nombre, SUM(d.valor_deb), SUM(d.valor_cre) "+;
        "FROM cgemovd d, cgeplan p, cgemovc c "          +;
        "WHERE d.empresa  = c.empresa"                   +;
         " AND d.ano_mes  = c.ano_mes"                   +;
         " AND d.control  = c.control"                   +;
         " AND d.libro    = " +       STR(::aLS[6],2)    +;
         " AND p.cuenta   = LEFT(d.cuenta," + aRes       +;
         " AND p.empresa  = " + LTRIM(STR(oApl:nPUC))    +;
         " AND p.nivel    = " + LTRIM(STR(::aLS[3]))     +;
         " AND LEFT(p.cuenta,2) <> '"  +  ::aLS[9]       +;
        "' AND c.empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.ano_mes >= " + xValToChar( ::aLS[1] )   +;
         " AND c.ano_mes <= " + xValToChar( ::aLS[2] )   +;
         " AND c.fuente  <= 2"                           +;
         " AND c.estado  <> 2"                           +;
        " GROUP BY c.fuente, d.ano_mes, p.cuenta"
If !MSQuery( oApl:oMySql:hConnect,cQry )
   oApl:oMySql:oError:Display( .f. )
Else
   hRes := MSStoreResult( oApl:oMySql:hConnect )
   nL   := MSAffectedRows( oApl:oMySql:hConnect )
   MSFreeResult( hRes )
 //MsgInfo( STR(nL)+" Registros Insertados" )
EndIf

cMes := "SELECT c.fuente, p.cuenta, d.ano_mes, p.nombre, SUM(d.valor_deb), SUM(d.valor_cre) "+;
        "FROM cgemovd d, cgeplan p, cgemovc c "          +;
        "WHERE d.empresa  = c.empresa"                   +;
         " AND d.ano_mes  = c.ano_mes"                   +;
         " AND d.control  = c.control"                   +;
         " AND d.libro    = " +       STR(::aLS[6],2)    +;
         " AND p.cuenta   = LEFT(d.cuenta,LENGTH(p.cuenta))"+;
         " AND p.empresa  = " + LTRIM(STR(oApl:nPUC))    +;
         " AND p.nivel    = " + LTRIM(STR(::aLS[3]))     +;
         " AND c.empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.ano_mes >= " + xValToChar( ::aLS[1] )   +;
         " AND c.ano_mes <= " + xValToChar( ::aLS[2] )   +;
         " AND c.fuente   = [FTE]"                       +;
         " AND c.estado  <> 2"                           +;
        " GROUP BY d.ano_mes, p.cuenta"
While !::oSec:Eof()
   If ::oSec:SECUENCIA >= 3
      aCta := { SUBSTR( ::oSec:CUENTA,1,2 ),SUBSTR( ::oSec:CUENTA,4,2 ),.f.,0,0,;
                ALLTRIM( ::oSec:NOMBRE ),0,"",.f. }
      aRes := STRTRAN( cMes,"[FTE]",SUBSTR( ::oSec:CUENTAPYG,2,2 ) )
      If aCta[6] == "VARIOS"
         aRes := STRTRAN( aRes,"fuente,","comprobant," )
         aRes := STRTRAN( aRes,"BY","BY c.comprobant," )
         aRes += " ORDER BY d.ano_mes, c.comprobant, p.cuenta"
      Else
         aRes += " ORDER BY d.ano_mes, p.cuenta"
      EndIf
      hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      nL   := MSNumRows( hRes )
      While nL > 0
         aRes := MyReadRow( hRes )
         AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
         If aRes[1] # aCta[7] .OR. aRes[3] # aCta[8]
            aCta[3] := aCta[9] := .f.
            aCta[8] := aRes[3]
         EndIf
         If aCta[6] == "VENTAS"
            aCta[7] := aRes[1]
            If aCta[1] == LEFT( aRes[2],2 )
               aCta[4] += aRes[5]
               aCta[5] += aRes[6]
            ElseIf aCta[2] == LEFT( aRes[2],2 )
               aCta[3] := .t.
               aRes[5] := aCta[5]
               aRes[6] := aCta[4]
               aCta[4] := aCta[5] := 0
            EndIf
         ElseIf aCta[6] == "VARIOS"
            If aCta[1] == LEFT( aRes[2],2 ) .AND. aRes[1] # aCta[7]
               aCta[7] := aRes[1]
               aCta[9] := .t.
            ElseIf aCta[9] .AND. aCta[1] # LEFT( aRes[2],2 )
               aCta[3] := .t.
            EndIf
         EndIf
         If aCta[3]
            aCta[3] := .f.
            If ::oSec:TOTALIZA == "S"
               aRes[1] := If( aRes[5] - aRes[6] < 0, 2, 1 )
            Else
               aRes[1] := 1
            EndIf
            cFlu := "SELECT COUNT(*) FROM flujocaja "       +;
                    "WHERE fuente = " + LTRIM(STR( aRes[1]))+;
                     " AND cuenta = " + xValToChar(aRes[2] )+;
                     " AND anomes = " + xValToChar(aRes[3] )
            If Buscar( cFlu,"CM",,8,,4 ) == 0
               cFlu := "INSERT INTO flujocaja VALUES( "+;
                         LTRIM(STR(aRes[1]))  +  ", '" +;
                          ALLTRIM( aRes[2] )  + "', '" +;
                          ALLTRIM( aRes[3] )  + "', '" +;
                          ALLTRIM( aRes[4] )  + "', "  +;
                         LTRIM(STR(aRes[5]))  +  ", "  +;
                         LTRIM(STR(aRes[6]))  +  " )"
            Else
               cFlu := "UPDATE flujocaja SET" +;
                            " debito = debito  + " + LTRIM(STR( aRes[5]))+;
                          ", credito = credito + " + LTRIM(STR( aRes[6]))+;
                      " WHERE fuente = "           + LTRIM(STR( aRes[1]))+;
                        " AND cuenta = "           + xValToChar(aRes[2] )+;
                        " AND anomes = "           + xValToChar(aRes[3] )
            EndIf
         //MsgInfo( cFlu,::oSec:CUENTAPYG )
            MSQuery( oApl:oMySql:hConnect,cFlu )
         EndIf
         nL --
      EndDo
      MSFreeResult( hRes )
   EndIf
   ::oSec:Skip(1):Read()
   ::oSec:xLoad()
EndDo
RETURN NIL

//------------------------------------//
METHOD ListoPYG( aPG ) CLASS TFlujo
   LOCAL aRes, hRes, nL
aRes := "SELECT * FROM flujocaja ORDER BY fuente, cuenta"
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   RETURN NIL
EndIf
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aPG  := { 0,0,0,"INGRESOS" }
While nL > 0
   If aRes[1] == 1
      aPG[2] := aRes[6] - aRes[5]
   Else
      aPG[2] := aRes[5] - aRes[6]
   EndIf
   If aPG[2] # 0
      If ::aLS[4] == 1
         ::oPrn:Titulo( 80,,1 )
         If aPG[1] == 0
            ::oPrn:Say( ::oPrn:nL,13,::oPrn:CPIBold + "SALDO INICIAL" )
            ::oPrn:Say( ::oPrn:nL,63,TRANSFORM( ::aLS[10],::cFor ) + ::oPrn:CPIBoldN )
            ::oPrn:nL += 2
         EndIf
         If aPG[1]  # aRes[1]
            aPG[1] := aRes[1]
            ::oPrn:Say( ::oPrn:nL,13,::oPrn:CPIBold + aPG[4] + ::oPrn:CPIBoldN )
            ::oPrn:nL ++
         EndIf
            ::oPrn:Say( ::oPrn:nL,01,aRes[2] )
            ::oPrn:Say( ::oPrn:nL,13,aRes[4] )
            ::oPrn:Say( ::oPrn:nL,61,TRANSFORM( aPG[2],::cFor ) )
            ::oPrn:nL ++
      Else
         ::Cabecera( .t. )
         If aPG[1] == 0
            UTILPRN ::oUtil SELECT ::aFnt[1]
            UTILPRN ::oUtil Self:nLinea, 3.8 SAY "SALDO INICIAL"
            UTILPRN ::oUtil Self:nLinea,16.5 SAY TRANSFORM( ::aLS[10],::cFor ) RIGHT
            UTILPRN ::oUtil SELECT ::aFnt[2]
            ::nLinea ++
         EndIf
         If aPG[1]  # aRes[1]
            aPG[1] := aRes[1]
            UTILPRN ::oUtil Self:nLinea, 3.8 SAY aPG[4] FONT ::aFnt[1]
            ::nLinea += .5
         EndIf
            UTILPRN ::oUtil Self:nLinea, 2.0 SAY aRes[2]
            UTILPRN ::oUtil Self:nLinea, 3.8 SAY aRes[4]
            UTILPRN ::oUtil Self:nLinea,16.5 SAY TRANSFORM( aPG[2],::cFor )   RIGHT
      EndIf
      aPG[3] += aPG[2]
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aPG[1] # aRes[1]
      If ::aLS[4] == 1
      //   ::oPrn:Separator( 2 )
         ::oPrn:Say( ::oPrn:nL,61,REPLICATE("_",18),,,1 )
         ::oPrn:nL ++
         ::oPrn:Say( ::oPrn:nL,13,::oPrn:CPIBold + "TOTAL " + aPG[4] + "====>" )
         ::oPrn:Say( ::oPrn:nL,63,TRANSFORM( aPG[3],::cFor ) + ::oPrn:CPIBoldN )
         ::oPrn:nL += 3
      Else
         ::Cabecera( .t. )
         UTILPRN ::oUtil Self:nLinea,16.5 SAY REPLICATE("_",18) RIGHT
         ::nLinea += .5
         UTILPRN ::oUtil SELECT ::aFnt[1]
         UTILPRN ::oUtil Self:nLinea, 3.8 SAY "TOTAL " + aPG[4] + "====>"
         UTILPRN ::oUtil Self:nLinea,16.5 SAY TRANSFORM( aPG[3],::cFor ) RIGHT
         UTILPRN ::oUtil SELECT ::aFnt[2]
         ::nLinea += .5
      EndIf
      If aPG[1] == 1
         ::aLS[10] += aPG[3]
      Else
         ::aLS[10] -= aPG[3]
      EndIf
      aPG[3] := 0
      aPG[4] := "EGRESOS"
   EndIf
EndDo
 MSFreeResult( hRes )
If ::aLS[4] == 1
   ::oPrn:nL -= 2
   ::oPrn:Say( ::oPrn:nL,61,REPLICATE("_",18),,,1 )
   ::oPrn:nL ++
   ::oPrn:Say( ::oPrn:nL,13,::oPrn:CPIBold + "SALDO BANCOS=====>" )
   ::oPrn:Say( ::oPrn:nL,63,TRANSFORM( ::aLS[10],::cFor ) + ::oPrn:CPIBoldN )
Else
   ::Cabecera( .t. )
   UTILPRN ::oUtil Self:nLinea,16.5 SAY REPLICATE("_",18) RIGHT
   ::nLinea += .5
   UTILPRN ::oUtil SELECT ::aFnt[1]
   UTILPRN ::oUtil Self:nLinea, 3.8 SAY "SALDO BANCOS=====>"
   UTILPRN ::oUtil Self:nLinea,16.5 SAY TRANSFORM( ::aLS[10],::cFor ) RIGHT
   UTILPRN ::oUtil SELECT ::aFnt[2]
EndIf

RETURN NIL

//------------------------------------//
METHOD Cabecera( lSep,nSpace,nSuma ) CLASS TFlujo
If lSep .AND. !::aEnc[1]
   ::aEnc[1] := ::Separator( nSpace,nSuma )
EndIf
If ::aEnc[1]
   ::aEnc[1] := .F.
   ::Centrar( oApl:cEmpresa,::aFnt[4],1.0 )
   UTILPRN ::oUtil 1.5, 8.2 SAY "NIT: " + oApl:oEmp:Nit
   ::Centrar( ::aEnc[2],,2.0 )
   ::Centrar( ::aEnc[3],,2.5 )
   ::nLinea := 3.5
EndIf
RETURN NIL

//------------------------------------//
METHOD FCExcel() CLASS TFlujo
   LOCAL aEX, aPG, aRes, hRes, nF, nE, nL
   LOCAL cQry, oExcel
cQry := "SELECT * FROM flujocaja ORDER BY fuente, cuenta, anomes"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   RETURN NIL
EndIf
 aEX := cFilePath( GetModuleFileName( GetInstance() )) + "FLUJO CAJA.xls"
If EMPTY(aEX)
   MSFreeResult( hRes )
   RETURN NIL
EndIf
aRes := {"ENE","FEB","MAR","ABR","MAY","JUN","JUL","AGO","SEP","OCT","NOV","DIC" }
aPG  := { VAL(LEFT( ::aLS[1],4 )),VAL(RIGHT( ::aLS[1],2 )),;
          1,"INGRESOS",0,1,"",10,0,0,0,0 }
aPG[3] += (VAL(LEFT( ::aLS[2],4 )) - aPG[1]) * 12 + (VAL(RIGHT(::aLS[2],2 )) - aPG[2])
cQry := "_" + LEFT( ::aLS[1],4 )
nE   := aPG[2]
::cFor := "#.##0,00"
   oApl:oWnd:SetMsg( "Exportando hacia "+aEX )
   oExcel := TExcelScript():New()
   oExcel:Create( aEX )
   oExcel:Font("Verdana")
 //oExcel:Size(10)
 //oExcel:Align(1)
   oExcel:Visualizar(.F.)
// oExcel:Say( nRow, nCol, xValue, cFont, nSize, lBold, lItalic, ;
//             lUnderLine, nAlign, nColor, nFondo , nOrien , nStyle , cFormat )
   oExcel:Say(  1 , 2 , oApl:cEmpresa, , 14 ,,,,,,,, 0  )
   oExcel:Say(  2 , 2 , "NIT: " + oApl:oEmp:Nit, ,12 ,,,, 7,,,, 0 )
   oExcel:Say(  3 , 2 , ::aEnc[2], , 12 ,,,, 7,,,, 0  )
   oExcel:Say(  4 , 2 , ::aEnc[3], , 12 ,,,, 7,,,, 0  )
FOR nF := 1 TO aPG[3]
   oExcel:ColumnWidth( nF+2 , 16 )
   oExcel:Say( 5, nF+2, aRes[nE] + cQry,,,,,, 7,,,, 0, "Text" )
   nE ++
   If nE == 13
      nE := 1
      cQry := "_" + LEFT(::aLS[2],4)
   EndIf
NEXT nF
   oExcel:Say(  7, 2, "SALDO INICIAL",,, .t.,,, 2,,,,, "Text" )
   oExcel:Say(  7, 3, ::aLS[10],,, .t.,,,,,,,, ::cFor )
   oExcel:Say(  9, 2, aPG[4],,, .t.,,, 2,,,,, "Text" )
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aEX  := { "","","","","" }
   nF   := 9
While nL > 0
   If aRes[1] == 1
      aPG[5] := aRes[6] - aRes[5]
   Else
      aPG[5] := aRes[5] - aRes[6]
   EndIf
   If aPG[5] # 0
      If aEX[5]  # aRes[3]
         aEX[5] := aRes[3]
         nE := (VAL(LEFT( aRes[3],4 )) - aPG[1]) * 12 + (VAL(RIGHT(aRes[3],2 )) - aPG[2]) + 3
       //MsgInfo( aRes[2]+aRes[3],STR(nE) )
      EndIf
      If aPG[6]  # aRes[1]
         aPG[6] := aRes[1]
         nF ++
         oExcel:Say( nF, 2, aPG[4],,, .t.,,, 2,,,,, "Text" )
      EndIf
      If aPG[7]  # aRes[2]
         aPG[7] := aRes[2]
         nF ++
         oExcel:Say( nF, 1, aRes[2] ,,,,,, 2,,,, 0, "Text" )
         oExcel:Say( nF, 2, aRes[4] ,,,,,, 2,,,, 0, "Text" )
      EndIf
         oExcel:Say( nF, nE, aPG[5],,,,,,,,,,, ::cFor )
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aPG[6] # aRes[1]
      If aPG[06] == 1
         aPG[09] := nF
         aPG[10] := nF + 6
      Else
         aPG[11] := nF
      EndIf
//    oExcel:Say( nF+1, 2, REPLICATE("_",18),,, .t.,,, 2,,,, 0, "Text" )
      oExcel:Say( nF+2, 2, "TOTAL " + aPG[4] + "====>",,, .t.,,, 2,,,, 0, "Text" )
      nF += 4
         aPG[04] := "EGRESOS"
   EndIf
EndDo
 MSFreeResult( hRes )
aEX[1] := "SUMA(X" + LTRIM(STR(aPG[08])) + ":X" + LTRIM(STR(aPG[09])) + ")"
aEX[2] := "SUMA(Z" + LTRIM(STR(aPG[10])) + ":Z" + LTRIM(STR(aPG[11])) + ")"
aEX[3] := "SUMA(T7 + T" + LTRIM(STR(aPG[09]+2)) + " - T" + LTRIM(STR(aPG[11]+2))
aEX[4] := "I" + LTRIM(STR(nF))
cQry   := "C"
   oExcel:Say( nF, 2, "SALDO BANCOS=====>",,, .t.,,, 2,,,,, "Text" )
FOR nL := 1 TO aPG[3]
   If nL >= 2
      oExcel:Say( 7, nL+2, "="+STRTRAN( aEX[4],"I",cQry ),,, .t.,,,,,,,, ::cFor )
   EndIf
   cQry := CHR(nL+66)
   oExcel:Say( aPG[09]+2, nL+2, "="+STRTRAN( aEX[1],"X",cQry ),,, .t.,,,,,,,, ::cFor )
   oExcel:Say( aPG[11]+2, nL+2, "="+STRTRAN( aEX[2],"Z",cQry ),,, .t.,,,,,,,, ::cFor )
   oExcel:Say( nF       , nL+2, "="+STRTRAN( aEX[3],"T",cQry ),,, .t.,,,,,,,, ::cFor )
NEXT nL
   nE := aPG[3] + 66
   oExcel:Borders("A1:" + CHR(nE) + LTRIM(STR(nF)) ,,, 3 )
   oExcel:ColumnWidth( 2 , 45 )
   oExcel:Visualizar(.T.)
   oExcel:End(.f.) ; oExcel := NIL
RETURN NIL

//------------------------------------//
METHOD FCOffice() CLASS TFlujo
   LOCAL aEX, aPG, aRes, aVC, hRes, hRez, nC, nF, nE, nL
aVC  := "SELECT * FROM flujocaja ORDER BY fuente, cuenta, anomes"
hRes := If( MSQuery( oApl:oMySql:hConnect,aVC ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   RETURN NIL
EndIf
aEX  := { cFilePath( GetModuleFileName( GetInstance() )) + "FLUJOCAJA.csv",;
          "",CHR(13) + CHR(10),"","","" }
               //CRLF
FERASE( aEX[1] )
hRez := FCREATE( aEX[1],0 )
If FERROR() != 0
   Msginfo( FERROR(),"No se pudo crear el archivo "+aEX[1] )
   MSFreeResult( hRes )
   RETURN NIL
EndIf
aRes := {"ENE","FEB","MAR","ABR","MAY","JUN","JUL","AGO","SEP","OCT","NOV","DIC" }
aPG  := { VAL(LEFT( ::aLS[1],4 )),VAL(RIGHT( ::aLS[1],2 )),;
          1,"INGRESOS",0,1,"",10,0,0,0,0 }
aPG[3] += (VAL(LEFT( ::aLS[2],4 )) - aPG[1]) * 12 + (VAL(RIGHT(::aLS[2],2 )) - aPG[2])
aVC  := "_" + LEFT( ::aLS[1],4 )
nE   := aPG[2]
If aPG[3] >= 2
   aEX[6] := ::FCOfficx()
EndIf
aEX[4] := '"","SALDO INICIAL",' + XTrim( ::aLS[10],-9 )
FOR nF := 1 TO aPG[3]
   aEX[2] += (',"' + aRes[nE] + aVC + '"')
   If nF >= 2
      aEX[4] += ('"' + STRTRAN( aEX[6],"B",CHR(nF+65) ) + '",')
   EndIf
   nE ++
   If nE == 13
      nE := 1
      aVC := "_" + LEFT(::aLS[2],4)
   EndIf
NEXT nF
   FWRITE( hRez,'"","'+oApl:cEmpresa+'"'+aEX[3] )
   FWRITE( hRez,'"","NIT: ' + oApl:oEmp:Nit + '"' +aEX[3] )
   FWRITE( hRez,'"","'+::aEnc[2]+'"'+aEX[3] )
   FWRITE( hRez,'"","'+::aEnc[3]+'"'+aEX[3] )
   FWRITE( hRez,'"",""'+  aEX[2]    +aEX[3] )
   FWRITE( hRez,'""'+aEX[3] )
   FWRITE( hRez,aEX[4] + aEX[3] )
   FWRITE( hRez,'""'+aEX[3] )
   FWRITE( hRez,'"","'+aPG[4]+'"'+aEX[3] )
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
 aVC := ARRAY( aPG[3] )
 nF  := 9
AFILL( aVC,0 )
While nL > 0
   If aRes[1] == 1
      aPG[5] := aRes[6] - aRes[5]
   Else
      aPG[5] := aRes[5] - aRes[6]
   EndIf
   If aPG[5] # 0
      If aEX[5]  # aRes[3]
         aEX[5] := aRes[3]
         nE := (VAL(LEFT( aRes[3],4 )) - aPG[1]) * 12 + (VAL(RIGHT(aRes[3],2 )) - aPG[2]) + 1
      EndIf
      If aPG[6]  # aRes[1]
         aPG[6] := aRes[1]
         nF ++
         FWRITE( hRez,'""'+aEX[3] )
         FWRITE( hRez,'"","'+aPG[4]+'"'+aEX[3] )
      EndIf
      If aPG[7]  # aRes[2]
         aPG[7] := aRes[2]
         nF ++
         aEX[2] := '"' + aRes[2] + '","' + aRes[4] + '",'
      EndIf
        aVC[nE] := aPG[5]
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aPG[7] # aRes[2]
      FOR nC := 1 TO aPG[3]
         aEX[2] += XTrim( aVC[nC],-9 )
         aVC[nC]:= 0
      NEXT nC
      FWRITE( hRez,aEX[2] + aEX[3] )
   EndIf
   If nL == 0 .OR. aPG[6] # aRes[1]
      If aPG[06] == 1
         aPG[09] := nF
         aPG[10] := nF + 6
         aEX[4]  := "SUMA(X" + LTRIM(STR(aPG[08])) + ":X" + LTRIM(STR(aPG[09])) + ")"
      Else
         aPG[11] := nF
         aEX[4]  := "SUMA(X" + LTRIM(STR(aPG[10])) + ":X" + LTRIM(STR(aPG[11])) + ")"
      EndIf
      aEX[2] := '"","TOTAL '+aPG[4]+'====>"'
      aPG[4] := "EGRESOS"
      FOR nC := 1 TO aPG[3]
         aEX[2] += ',"='+STRTRAN( aEX[4],"X",CHR(nC+66) ) + '"'
      NEXT nC
      FWRITE( hRez,'""'+aEX[3] )
      FWRITE( hRez,aEX[2] + aEX[3] )
      FWRITE( hRez,'""'+aEX[3] )
      nF += 4
   EndIf
EndDo
 MSFreeResult( hRes )
 aEX[2] := '"","SALDO BANCOS=====>"'
 aVC    := "SUMA(T7 + T" + LTRIM(STR(aPG[09]+2)) + " - T" + LTRIM(STR(aPG[11]+2)) + ")"
 FOR nC := 1 TO aPG[3]
    aEX[2] += ',"='+STRTRAN( aVC,"T",CHR(nC+66) ) + '"'
 NEXT nC
 FWRITE( hRez,aEX[2] + aEX[3] )
If !FCLOSE(hRez)
   Msginfo(FERROR(),"Error cerrando el archivo "+aEX[1])
EndIf
   WAITRUN("OPENOFICE.BAT " + aEX[1], 0 )
RETURN NIL

//------------------------------------//
METHOD FCOfficx() CLASS TFlujo
   LOCAL aRes, hRel, nF, nL
   LOCAL aPG := { 1,"",0,"=B" }
aRes := "SELECT * FROM flujocaja ORDER BY fuente, cuenta, anomes"
hRel := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
 nL  := MSNumRows( hRel )
 nF  := 9
aRes := MyReadRow( hRel )
AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRel,nP ) } )
While nL > 0
   If aRes[1] == 1
      aPG[3] := aRes[6] - aRes[5]
   Else
      aPG[3] := aRes[5] - aRes[6]
   EndIf
   If aPG[3] # 0
      If aPG[1]  # aRes[1]
         aPG[1] := aRes[1]
         nF ++
      EndIf
      If aPG[2]  # aRes[2]
         aPG[2] := aRes[2]
         nF ++
      EndIf
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRel )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRel,nP ) } )
   EndIf
   If nL == 0 .OR. aPG[1] # aRes[1]
      nF += 4
   EndIf
EndDo
 MSFreeResult( hRel )
aPG[4] += LTRIM(STR( nF ))
RETURN aPG[4]