// Programa.: CGEMEDIO.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Medios Magneticos.
#include "FiveWin.ch"
#include "Xls.ch"

MEMVAR oApl

PROCEDURE MediosMg()
   LOCAL oDlg, oLbx, oM
oM := TMedios() ; oM:New()
DEFINE DIALOG oDlg TITLE "MEDIOS MAGNETICOS" FROM 0, 0 TO 16,50
   @ 16, 00 SAY "FORMATO"  OF oDlg RIGHT PIXEL SIZE 50,10
   @ 16, 52 GET oM:oG[1] VAR oM:aLS[1] OF oDlg PICTURE "9999" SIZE 30,10 PIXEL;
      VALID oM:New( oDlg,oLbx )
//   @ 28, 00 SAY "COLUMNAS" OF oDlg RIGHT PIXEL SIZE 40,10
//   @ 28, 42 GET oM:oG[2] VAR oM:oMgc:COLUMNAS OF oDlg PICTURE "99";
//      SIZE 30,10 PIXEL UPDATE
   @ 16, 94 SAY "PERIODO INICIAL"      OF oDlg RIGHT PIXEL SIZE 50,10
   @ 16,146 GET oM:oG[2] VAR oM:aLS[2] OF oDlg PICTURE "999999" SIZE 32,10 PIXEL;
      VALID NtChr( oM:aLS[2],"P" )
   @ 28, 94 SAY "PERIODO   FINAL"      OF oDlg RIGHT PIXEL SIZE 50,10
   @ 28,146 GET oM:oG[3] VAR oM:aLS[3] OF oDlg PICTURE "999999" SIZE 32,10 PIXEL;
      VALID NtChr( oM:aLS[3],"P" )
   @ 28, 00 SAY "Cuantias Menores"     OF oDlg RIGHT PIXEL SIZE 50,10
   @ 28, 52 GET oM:oG[4] VAR oM:aLS[5] OF oDlg PICTURE "999,999,999" ;
      VALID If( oM:aLS[5] >=  0, .t.                       ,;
          (MsgStop( "El Valor debe ser Mayor o Igual a 0","<< OJO >>"), .f.));
      SIZE 40,10 PIXEL
   @ 42, 06 LISTBOX oLbx FIELDS   ;
            STR(oM:oMgd:CONCEPTO),;
                oM:oMgd:CUENTAI  , oM:oMgd:CUENTAF;
      HEADERS "Concepto", "Cuenta"+CRLF+"Inicial",;
                          "Cuenta"+CRLF+"Final"   ;
      SIZES 400,450 SIZE 182,66 ;
      OF oDlg UPDATE PIXEL
   oLbx:nClrBackHead  := oApl:nClrBackHead
   oLbx:nClrForeHead  := oApl:nClrForeHead
   oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
   oLbx:nClrBackFocus := oApl:nClrBackFocus
   oLbx:nClrForeFocus := oApl:nClrForeFocus
   oLbx:nHeaderHeight := 26
   oLbx:GoTop()
   oLbx:oFont       := Tfont():New("Ms Sans Serif",0,-10,,.f.)
   oLbx:aColSizes   := {72,98,98}
   oLbx:aHjustify   := {2,2,2}
   oLbx:aJustify    := {0,0,0}
   oLbx:ladjlastcol := oLbx:lCellStyle  := .f.
   oLbx:ladjbrowse  := .t.
   oLbx:bKeyDown := {|nKey| If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, oM:Editar( .t.,oLbx ),;
                            If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, oM:Editar( .f.,oLbx ),;
                            If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, oM:Borrar( oLbx ),) )) }
   MySetBrowse( oLbx,oM:oMgd )
   ACTIVAGET(oM:oG)
ACTIVATE DIALOG oDlg CENTERED ;
   ON INIT ( Empresa( .t. ), oM:Barra( oDlg,oLbx ) )
//oM:oMgc:Destroy()
oM:oMgd:Destroy()
oM:oPuc:Destroy()
RETURN

//------------------------------------//
CLASS TMedios

 DATA aLS AS ARRAY INIT { 1001,NtChr( DATE(),"1" ),"",0,0,"","" }
 DATA oG           INIT ARRAY(4)
 DATA cNit, oMed, oMgc, oMgd, oPuc

 METHOD NEW( oDlg,oLbx ) Constructor
 METHOD Editar( lNew,oLbx )
 METHOD Grabar( lNew,oLbx )
 METHOD Borrar( oLbx )
 METHOD MediosDT( lDBF )
 METHOD GrabarDT( aRes )
 METHOD SaldosDT()
 METHOD SumarCon( lSum )
 METHOD ArmoQuery( lDBF )
 METHOD Barra( oDlg,oLbx )

ENDCLASS

//------------------------------------//
METHOD New( oDlg,oLbx ) CLASS TMedios
 If oLbx == NIL
    ::aLS[3] := ::aLS[2]
  //::oMgc := oApl:Abrir( "mediosmc" ,"formato" ,.t.,,5 )
    ::oMgd := oApl:Abrir( "mediosmd" ,"concepto",.t.,,10 )
    ::oPuc := oApl:Abrir( "cgeplan","empresa, cuenta" )
    ::oMgd:Seek( {"formato",::aLS[1]},"concepto, cuentai" )
 Else
    If ::oMgd:Seek( {"empresa",oApl:nPUC,"formato",::aLS[1]},"concepto, columna, cuentai" )
       oDlg:Update()
       oLbx:Refresh()
    Else
       If MsgYesNo("Desea Crearlo","Este Formato NO EXISTE")
          ::Editar( .t.,oLbx )
       Else
          MsgStop( "Este Formato NO EXISTE" )
       EndIf
    EndIf
 EndIf
RETURN ::oMgd:lOK

//------------------------------------//
METHOD Editar( lNew,oLbx ) CLASS TMedios
   LOCAL aE := { "Modificando Concepto","","" }
   LOCAL bGrabar, oDlg, oGet := ARRAY(12)
If lNew
   aE[1]   := "Nuevo Concepto"
   bGrabar := {|| ::Grabar( lNew,oLbx )         ,;
                  ::oMgd:xBlanK()               ,;
                  oDlg:Update(), oDlg:SetFocus() }
   oLbx:GoBottom() ; ::oMgd:xBlank()
Else
   bGrabar := {|| ::Grabar( lNew,oLbx ), oLbx:Refresh(), oDlg:End() }
   ::oPuc:Seek( {"empresa",oApl:nPUC,"cuenta",::oMgd:CUENTAI} )
   aE[2] := ::oPuc:NOMBRE
   ::oPuc:Seek( {"empresa",oApl:nPUC,"cuenta",::oMgd:CUENTAF} )
   aE[3] := ::oPuc:NOMBRE
EndIf

DEFINE DIALOG oDlg TITLE aE[1] FROM 0, 0 TO 14,50
   @ 02,00 SAY "FORMATO"        OF oDlg RIGHT PIXEL SIZE 40,10
   @ 02,42 SAY oGet[1] VAR ::aLS[1]        OF oDlg PICTURE "9999";
      SIZE 30,10 PIXEL
   @ 14,00 SAY "Concepto"       OF oDlg RIGHT PIXEL SIZE 40,10
   @ 14,42 GET oGet[2] VAR ::oMgd:CONCEPTO OF oDlg PICTURE "9999";
      SIZE 30,10 PIXEL
   @ 26,00 SAY "Cuenta Inicial" OF oDlg RIGHT PIXEL SIZE 40,10
   @ 26,42 GET oGet[3] VAR ::oMgd:CUENTAI OF oDlg PICTURE "9999999999"       ;
      VALID If( ::oPuc:Seek( {"empresa",oApl:nPUC,"cuenta",::oMgd:CUENTAI} ),;
              ( oGet[4]:Settext( ::oPuc:NOMBRE ), .t. )       ,;
              ( MsgStop( "Está Cuenta NO EXISTE !!!" ), .f. ) );
      SIZE 40,10 PIXEL
   @ 26,90 SAY oGet[4] VAR aE[2] OF oDlg PIXEL SIZE 120,10;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 38,00 SAY "Cuenta   Final" OF oDlg RIGHT PIXEL SIZE 40,10
   @ 38,42 GET oGet[5] VAR ::oMgd:CUENTAF OF oDlg PICTURE "9999999999"       ;
      VALID If( ::oPuc:Seek( {"empresa",oApl:nPUC,"cuenta",::oMgd:CUENTAF} ),;
              ( oGet[6]:Settext( ::oPuc:NOMBRE ), .t. )       ,;
              ( MsgStop( "Está Cuenta NO EXISTE !!!" ), .f. ) );
      SIZE 40,10 PIXEL
   @ 38,90 SAY oGet[6] VAR aE[3] OF oDlg PIXEL SIZE 120,10;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 50,00 SAY "Porcentaje"       OF oDlg RIGHT PIXEL SIZE 40,10
   @ 50,42 GET oGet[7] VAR ::oMgd:PTAJE   OF oDlg PICTURE "999.99";
      SIZE 30,10 PIXEL
   @ 50,90 CHECKBOX oGet[8] VAR ::oMgd:SALDO PROMPT "Con Saldo Anterior" OF oDlg;
      SIZE 60,10 PIXEL
   @ 62,00 SAY "Movimiento"       OF oDlg RIGHT PIXEL SIZE 40,10
   @ 62,42 COMBOBOX oGet[9] VAR ::oMgd:MOVTO ITEMS { "Debito","Credito","Sumatoria" };
      SIZE 40,99 OF oDlg PIXEL
   @ 74,00 SAY "Columna Nro." OF oDlg RIGHT PIXEL SIZE 40,10
   @ 74,42 GET oGet[10] VAR ::oMgd:COLUMNA OF oDlg PICTURE "99";
      VALID Rango( ::oMgd:COLUMNA,14,22 )  SIZE 24,10 PIXEL

   @ 84, 70 BUTTON oGet[11] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION;
      (If( EMPTY(::oMgd:CUENTAF) .OR. EMPTY(::oMgd:CUENTAF)          ,;
         ( MsgStop("Imposible grabar este Concepto"), oGet[3]:SetFocus()),;
         ( oGet[11]:Disable(), EVAL( bGrabar ), oGet[11]:Enable() ))) PIXEL
   @ 84,120 BUTTON oGet[12] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION ( oDlg:End() ) PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
 oLbx:SetFocus()
RETURN NIL

//------------------------------------//
METHOD Grabar( lNew,oLbx ) CLASS TMedios

 If lNew
    ::oMgd:EMPRESA := oApl:nPUC
    ::oMgd:FORMATO := ::aLS[1]
    ::oMgd:Append( .t. )
    PListbox( oLbx,::oMgd )
 Else
    ::oMgd:Update(.t.,1)
 EndIf
RETURN NIL

//------------------------------------//
METHOD Borrar( oLbx ) CLASS TMedios

 If MsgNoYes( "Este Concepto"+STR(::oMgd:CONCEPTO),"Elimina" )
    If ::oMgd:Delete( .t.,1 )
       PListbox( oLbx,::oMgd )
    EndIf
 EndIf
RETURN NIL

//------------------------------------//
METHOD MediosDT( lDBF ) CLASS TMedios
   LOCAL aRes, cQry, hRes, nL
 ::oMed := oApl:Abrir( "mediosmg","conce",,.t. )
If ::aLS[2]  > ::aLS[3]
   aRes     := ::aLS[2]
   ::aLS[3] := ::aLS[2]
   ::aLS[2] := aRes
EndIf
 ::aLS[6] := STR( VAL( LEFT(::aLS[2],4) )-1,4 ) + "13"
 ::aLS[7] := If( RIGHT( ::aLS[2],2 ) == "01", ::aLS[6],;
              STR( VAL( ::aLS[2] )-1,6 ) )
/*
SELECT SUM(d.valor_deb), SUM(d.valor_cre)
FROM cgemovc c, cgemovd d
WHERE c.empresa  = 1
  AND c.ano_mes >= '201101'
  AND c.ano_mes <= '201112'
  AND c.estado  <> 2
  AND d.empresa  = c.empresa
  AND d.ano_mes  = c.ano_mes
  AND d.control  = c.control
  AND d.cuenta  >= '1435'
  AND d.cuenta  <= '14359999'
*/
cQry := "SELECT n.codigo, n.digito, n.nombre, n.direccion"+;
             ", n.codigo_ciu,    0,    0,    0,    0, "   +;
             "SUM(d.valor_deb), SUM(d.valor_cre) "        +;
         "FROM cgemovc c, cgemovd d LEFT JOIN cadclien n "+;
            "ON d.codigo_nit = n.codigo_nit "             +;
         "WHERE c.empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
          " AND c.ano_mes >= " + xValToChar( ::aLS[2] )   +;
          " AND c.ano_mes <= " + xValToChar( ::aLS[3] )   +;
          " AND c.estado  <> 2"                           +;
          " AND d.empresa  = c.empresa"                   +;
          " AND d.ano_mes  = c.ano_mes"                   +;
          " AND d.control  = c.control"                   +;
          " AND d.cuenta  >= '[CTAI]'"                    +;
          " AND d.cuenta  <= '[CTAF]'"                    +;
         " GROUP BY d.codigo_nit ORDER BY n.codigo"
//oDlg:SetText( "<< ESPERE >> GENERANDO INFORMACION" )
 ::oMgd:GoTop():Read()
 ::oMgd:xLoad()
While !::oMgd:Eof()
   If ::oMgd:FORMATO # 1401
      aRes := STRTRAN( cQry,"[CTAI]",ALLTRIM(::oMgd:CUENTAI) )
      aRes := STRTRAN( aRes,"[CTAF]",XTRIM(::oMgd:CUENTAF,8,"9") )
      hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      nL   := MSNumRows( hRes )
      oApl:oWnd:SetMsg( STR(::oMgd:CONCEPTO)+STR(nL)+" Registros" )
      While nL > 0
         aRes := MyReadRow( hRes )
         AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
         ::GrabarDT( aRes )
         nL --
      EndDo
      MSFreeResult( hRes )
   EndIf
   If ::oMgd:SALDO
      ::SaldosDT()
   EndIf
   ::oMgd:Skip(1):Read()
   ::oMgd:xLoad()
EndDo
/*
   If ::aLS[1] == 1001
      ::SumarCon( .t. )
   ElseIf ::aLS[1] == 1007
      ::SumarCon( .f. )
   EndIf
*/
 ::oMed:Destroy()
 ::ArmoQuery( lDBF )
 ::oG[1]:SetFocus()
RETURN NIL

//------------------------------------//
METHOD GrabarDT( aRes ) CLASS TMedios

 If ::oMgd:MOVTO == 2
    aRes[10] := aRes[11]   //VALOR_CRE
 ElseIf ::oMgd:MOVTO == 3
    aRes[10] -= aRes[11]   //VALOR_DEB - VALOR_CRE
 EndIf
 If ::oMgd:PTAJE > 0
    ::aLS[4] :=   ABS( aRes[10] )
    If ::oMgd:CONCEPTO == 8211
       aRes[10] := ROUND( ::aLS[4] * ::oMgd:PTAJE / 100,0 )
       ::aLS[4] := 0
    Else
       ::aLS[4] := ROUND( ::aLS[4] * 100 / ::oMgd:PTAJE,0 )
    EndIf
 Else
    ::aLS[4] := 0
 EndIf
 If ::oMgd:RESTAR
    aRes[10] *= -1
 EndIf
 If ABS( aRes[10] ) < ::aLS[5]
    ::cNit := "222222222"
    aRes[2] := 0
    aRes[4] := ""
    aRes[5] := oApl:oEmp:RESHABIT
 Else
    ::cNit := LTRIM(STR(aRes[1],11,0))
 EndIf
 If !::oMed:Seek( {"conce",::oMgd:CONCEPTO,"nit",::cNit} )
    ::oMed:CONCE := ::oMgd:CONCEPTO ; ::oMed:NIT       := ::cNit
    ::oMed:DV    :=  STR(aRes[2],1) ; ::oMed:DIRECCION := aRes[4]
    ::oMed:DPTO  := LEFT(aRes[5],2) ; ::oMed:MCP       := RIGHT(aRes[5],3)
    ::oMed:PAIS  := "169"
    If ::cNit == "222222222"
       ::oMed:TD        := "43"
       ::oMed:RAZONSO   := "CUANTIAS MENORES"
    ElseIf aRes[1] >= 800000000 .AND.;
           aRes[1] <= 999999999
       ::oMed:TD        := "31"
       ::oMed:RAZONSO   := aRes[3]
    Else
       ::oMed:TD        := "13"
     //::oMed:APELLIDO1 := SUBSTR( aRes[3],  1    ,aRes[6] )
     //aRes[6] += 2  //PA
     //::oMed:APELLIDO2 := SUBSTR( aRes[3],aRes[6],aRes[7] )
     //aRes[6] += aRes[7] + 1
     //::oMed:NOMBRE1   := SUBSTR( aRes[3],aRes[6],aRes[8] )
     //aRes[6] += aRes[8] + 1
     //::oMed:NOMBRE2   := SUBSTR( aRes[3],aRes[6],aRes[9] )
       ::oMed:APELLIDO1 := ::oMed:APELLIDO2 := ""
       ::oMed:NOMBRE1   := SUBSTR( aRes[3], 1,29 )
       ::oMed:NOMBRE2   := SUBSTR( aRes[3],30 )
    EndIf
    ::oMed:Append( .t. )
 EndIf
 //::Med:axBuffer[::oMgd:COLUMNA+1]
 If ::oMgd:COLUMNA == 14
    ::oMed:COLUM14 += aRes[10]
 ElseIf ::oMgd:COLUMNA == 15
    ::oMed:COLUM15 += aRes[10]
 ElseIf ::oMgd:COLUMNA == 16
    ::oMed:COLUM16 += aRes[10]
 ElseIf ::oMgd:COLUMNA == 18
    ::oMed:COLUM18 += aRes[10]
 ElseIf ::oMgd:COLUMNA == 19
    ::oMed:COLUM19 += aRes[10]
 ElseIf ::oMgd:COLUMNA == 20
    ::oMed:COLUM20 += aRes[10]
 ElseIf ::oMgd:COLUMNA == 21
    ::oMed:COLUM21 += aRes[10]
 ElseIf ::oMgd:COLUMNA == 22
    ::oMed:COLUM22 += aRes[10]
 EndIf
    ::oMed:COLUM17 += ::aLS[4]
    ::oMed:Update(.f.,1)
RETURN NIL

//------------------------------------//
METHOD SaldosDT() CLASS TMedios
   LOCAL aRes, cQry, hRes, nL
cQry := "SELECT n.codigo, n.digito, n.nombre, n.direccion, "+;
               "n.codigo_ciu,    0,    0,    0,    0, "     +;
             "SUM(d.valor_deb), SUM(d.valor_cre) "          +;
         "FROM cgeacumn d LEFT JOIN cadclien n "            +;
            "ON d.codigo_nit = n.codigo_nit "               +;
         "WHERE d.empresa  = " + LTRIM(STR(oApl:nEmpresa))  +;
          " AND d.cuenta  >= " + xValToChar(::oMgd:CUENTAI) +;
          " AND d.cuenta  <= '"+ XTRIM(::oMgd:CUENTAF,8,"9")+;
         "' AND d.ano_mes >= " + xValToChar( ::aLS[6] )     +;
          " AND d.ano_mes <= " + xValToChar( ::aLS[7] )     +;
         " GROUP BY d.codigo_nit ORDER BY n.codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
   If ABS(aRes[10] - aRes[11]) > 0
      ::GrabarDT( aRes )
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
RETURN NIL

//------------------------------------//
METHOD SumarCon( lSum ) CLASS TMedios
   LOCAL aRes, cQry, hRes, nL
If lSum
   cQry := "CREATE TABLE temporalx AS "                +;
           "SELECT nit, SUM(colum14) valor "           +;
           "FROM mediosmg "                            +;
           "WHERE conce NOT IN(5007, 5008, 5009, 5016)"+;
           " GROUP BY nit"
   MSQuery( oApl:oMySql:hConnect,cQry )
   cQry := "UPDATE mediosmg g, temporalx s "           +;
           "SET g.colum14 = g.colum14 - s.valor "      +;
           "WHERE g.conce = 5016 AND g.nit = s.nit"
   MSQuery( oApl:oMySql:hConnect,cQry )
   MSQuery( oApl:oMySql:hConnect,"DROP TABLE temporalx" )
Else
   cQry := "SELECT SUM(d.valor_deb), SUM(d.valor_cre) "     +;
           "FROM cgemovc c, cgemovd d, cadclien n "         +;
           "WHERE c.empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND c.ano_mes >= " + xValToChar( ::aLS[2] )   +;
            " AND c.ano_mes <= " + xValToChar( ::aLS[3] )   +;
            " AND c.estado  <> 2"                           +;
            " AND d.empresa  = c.empresa"                   +;
            " AND d.ano_mes  = c.ano_mes"                   +;
            " AND d.control  = c.control"                   +;
            " AND d.cuenta  >= '4175'"                      +;
            " AND d.cuenta  <= '41759999'"                  +;
            " AND d.codigo_nit = n.codigo_nit"              +;
            " AND n.codigo   = [NIT]"
   ::oMed:Seek( {"conce",4001} )
   While !::oMed:Eof()
      aRes := STRTRAN( cQry,"[NIT]",ALLTRIM(::oMed:NIT) )
      hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      If MSNumRows( hRes ) > 0
         aRes := MyReadRow( hRes )
         AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
         ::oMed:COLUM17 += ABS( aRes[1] - aRes[2] )
         ::oMed:Update(.f.,1)
      EndIf
      MSFreeResult( hRes )
      ::oMed:Skip(1):Read()
      ::oMed:xLoad()
   EndDo
EndIf
RETURN NIL

//------------------------------------//
METHOD ArmoQuery( lDBF ) CLASS TMedios
   LOCAL aTxt, cQry, cTexto, nC, nF, oExcel, oTb, ptrHandle
   LOCAL aSum := { "","N",3,0,.t. }
   LOCAL cFile := cFilePath( GetModuleFileName( GetInstance() ))
   cQry := "SELECT conce, td, nit, dv, apellido1, apellido2, nombre1, nombre2, "
If ::aLS[1] == 1001
   //22 Columnas
   aTxt := { .f.,.t.,.t.,.t.,.f.,.f.,.f.,.f.,.f.,.f.,.t.,;
             .t.,.t.,.f.,.f.,.f.,.f.,.f.,.f.,.f.,.f.,.f. }
   cQry += "razonso, direccion, dpto, mcp, pais, ABS(colum14) valor, 0 pandedu, 0 ivamay, "+;
           "0 ivamaynd, ABS(colum18) retftep, 0 retftea, 0 retfteirc, 0 retfteirs, 0 retfteind"
ElseIf ::aLS[1] == 1008 .OR. ::aLS[1] == 1009
   //14 Columnas
   aTxt := { .f.,.t.,.t.,.t.,.f.,.f.,.f.,.f.,.f.,.f.,.t.,.t.,.t.,.f. }
   cQry += "razonso, direccion, dpto, mcp, pais, ABS(colum14) valor"
ElseIf ::aLS[1] == 1003
   //14 Columnas
   aTxt := { .f.,.t.,.t.,.t.,.f.,.f.,.f.,.f.,.f.,.f.,.f.,.f.,.f.,.f. }
   cQry += "razonso, direccion, dpto, mcp, ABS(colum17) valor, ABS(colum14) retfte"
ElseIf ::aLS[1] == 1005 .OR. ::aLS[1] == 1006
   // 10 Columnas
   aSum[5] := .f.
   aTxt := { .t.,.t.,.t.,.f.,.f.,.f.,.f.,.f.,.f.,.f. }
   cQry := "SELECT td, nit, dv, apellido1, apellido2, nombre1, nombre2, "+;
           "razonso, ABS(colum14) ivades, ABS(colum15) devol"
ElseIf ::aLS[1] == 1007
   //17 Columnas
   aSum[2] := "K"
   aTxt := { .f.,.t.,.t.,.t.,.f.,.f.,.f.,.f.,.f.,.f.,.f.,.f.,.f.,.f.,.f.,.f.,.f. }
   cQry += "razonso, pais, ABS(colum14) valor, 0, 0, 0, 0, 0, ABS(colum15) devol"
ElseIf ::aLS[1] == 1011
   // 2 Columnas
   aSum[2] := "B"
   aTxt := { .f.,.f. }
   cQry := "SELECT conce, ABS(colum14) saldos"
ElseIf ::aLS[1] == 1012
   //11 Columnas
   aSum[2] := "K"
   aTxt := { .f.,.t.,.t.,.t.,.f.,.f.,.f.,.f.,.f.,.f.,.f. }
   cQry += "razonso, pais, ABS(colum14) valor"
EndIf
   cQry += " FROM mediosmg WHERE ABS(colum14) > 0 ORDER BY conce"
   cTexto := "FORM"+STR(::aLS[1],4)
If lDBF
   ExportDBF( cTexto,cQry,,1 )
Else
   cTexto := cFile + cTexto + ".txt"
   FERASE(cTexto)
   ptrHandle := FCREATE(cTexto,0) //, FC_NORMAL)
   If FERROR() != 0
      Msginfo(FERROR(),"No se pudo crear el archivo "+cTexto )
      RETURN nil
   EndIf

   oTb := TMsQuery():Query( oApl:oDb,cQry )
   If oTb:Open()
      oApl:oWnd:SetMsg( "Exportando hacia "+cTexto )
      cQry := ""
      FOR nC := 1 TO oTb:nFieldCount
         cQry += '"'+STRTRAN(UPPER(oTb:FieldName(nC)),"'",'')+'",'
      NEXT nC
         FWRITE( ptrHandle,'"FORMATO","'+STR(::aLS[1],4)+'","","'+oApl:cEmpresa+'"'+CHR(13)+CHR(10) )
         FWRITE( ptrHandle,LEFT( cQry,LEN(cQry)-1 )+CHR(13)+CHR(10) )

      oTb:GoTop()
      FOR nF := 1 TO oTb:nRowCount
         aTxt := oTb:Read()
         cQry := ""
         AEVAL( aTxt, { |xV,nP| xV := MyClReadCol( oTb:hResult,nP ),;
                                cQry += XTrim( xV,-9 )          } )
/*
                        If( aSum[5] .AND. aSum[4] == 0             ,;
                          ( aSum[1] := aTxt[1] := xV ), )       } )
                            If( VALTYPE( xV ) == "N"               ,;
                              ( xV := STRTRAN( STR(xV),".","," )   ,;
                                If( RIGHT(xV,3) == ",00"           ,;
                                   xV := LEFT( xV,LEN(xV)-3 ), )),),;
                                cQry += ('"'+    xV +'",' ) } )
*/
         FWRITE( ptrHandle,LEFT( cQry,LEN(cQry)-1 )+CHR(13)+CHR(10) )
/*
         If aSum[5]
            aSum[4] ++
            If nF == oTb:nRowCount .OR. aSum[1] # aTxt[1]
               cQry := "SUMA(" + aSum[2] + LTRIM(STR(aSum[3])) + ":" +;
                                 aSum[2] + LTRIM(STR(aSum[4])) + ")"
               FWRITE( ptrHandle,cQry +CHR(13)+CHR(10) )
               aSum[1] := aTxt[1]
               aSum[3] := aSum[4] + 2
               aSum[4] := 0
            EndIf
         EndIf
*/
         oTb:Skip(1)
      NEXT nF
      If FCLOSE(ptrHandle)
         If oApl:lOffice
            cQry := STRTRAN( cTexto,".txt",".csv" )
            FERASE(cQry)
            RENAME &(cTexto) TO &(cQry)
            WAITRUN("OPENOFICE.BAT " + cQry, 0 )
         Else
            XLS( cTexto )
         EndIf
      Else
         Msginfo(FERROR(),"Error cerrando el archivo "+cTexto)
      EndIf
   EndIf
   oTb:Close()
EndIf
RETURN NIL

//------------------------------------//
METHOD Barra( oDlg,oLbx ) CLASS TMedios
   LOCAL oBar, oBot := ARRAY(6)
DEFINE BUTTONBAR oBar OF oDlg 3DLOOK SIZE 28,28

DEFINE BUTTON oBot[1] RESOURCE "NUEVO"    OF oBar NOBORDER;
   TOOLTIP "Nuevo Registro (Ctrl+N)" ;
   ACTION ::Editar( .t.,oLbx )
DEFINE BUTTON oBot[2] RESOURCE "EDIT"     OF oBar NOBORDER;
   TOOLTIP "Editar Registro (Ctrl+E)";
   ACTION ::Editar( .f.,oLbx )
DEFINE BUTTON oBot[3] RESOURCE "ELIMINAR" OF oBar NOBORDER;
   TOOLTIP "Eliminar (Ctrl+DEL)" ;
   ACTION ::Borrar( oLbx ) GROUP
DEFINE BUTTON oBot[4]                     OF oBar NOBORDER;
   ACTION ::MediosDT( .t. )       ;
   FILENAME oApl:cIco+"DBF.bmp"   ;
   MESSAGE "Exportar Hacia DBF"   ;
   TOOLTIP "Exportar Hacia DBF"
DEFINE BUTTON oBot[5]                     OF oBar NOBORDER;
   ACTION ::MediosDT( .f. )       ;
   FILENAME oApl:cIco+"EXCEL.bmp" ;
   MESSAGE "Exportar Hacia EXCEL" ;
   TOOLTIP "Exportar Hacia EXCEL"
DEFINE BUTTON oBot[6] RESOURCE "EXIT2"    OF oBar NOBORDER;
   TOOLTIP "Salir"    ;
   ACTION oDlg:End()    GROUP
 oBar:bRClicked := {|| NIL }
 oBar:bLClicked := {|| NIL }
RETURN oBar

//------------------------------------//
FUNCTION XLS( cTexto )
   LOCAL oXls, oFile, cCelda
   LOCAL f, i, j, lAlfa
   LOCAL cExcel := "Excel"
   LOCAL cTxt := cFilePath( GetModuleFileName( GetInstance() ))
//      cTxt := STRTRAN( oApl:cRuta1,"Bitmap","Excel" )
//   cExcel := AbrirFile( 5,cTxt,"*.XLS" )
If cTexto == NIL
   If !MsgGet( "Introduzca nombre del archivo", "Archivo Excel XLS", @cExcel )
      RETURN Nil
   EndIf
Else
   If (j := RAT( "\",cTexto )) > 0
      cTxt   :=  LEFT( cTexto,j )
      cExcel := SUBSTR(cTexto,j+1 )
   Else
      cExcel := cTexto
   EndIf
   If (j := RAT( ".",cExcel )) > 0
      cExcel :=  LEFT( cExcel,j-1 )
   EndIf
EndIf
  cTexto := cTxt + cExcel + ".txt"
  cExcel := cTxt + cExcel + ".xls"
  oFile  := TTxtFile():New(cTexto)
  FERASE(cExcel)

  OPEN XLS oXls ;
    FILENAME cExcel

  f := 1

  WHILE !oFile:lEoF()
     cTxt := oFile:cLine
     If !EMPTY(cTxt)
        i := 1
        WHILE !EMPTY(cTxt)
           cCelda := Saca(@cTxt,'",')
           cCelda := StrTran(cCelda,'"')

           lAlfa := .f.
           FOR j=1 TO LEN(cCelda)
              If ISALPHA( SUBSTR(cCelda,j,1) )
                 lAlfa := .t.
                 Exit
              EndIf
           NEXT j
           If !lAlfa
              cCelda := ALLTRIM(cCelda)
           EndIf
           @ f, i SAY cCelda OF oXls
           i++
        ENDDO
     EndIf
     oFile:Skip( 1 )
     f++
  ENDDO

  CLOSE XLS oXls

  If MSGYESNO("Se ha generado el archivo Excel "+CRLF+CRLF+;
              cExcel+CRLF+CRLF+;
              "¿Desea poner en marcha Excel y visualizar el archivo?","Informe terminado")
     ShellExecute( ,,cExcel,'','',5)  //Ejecutamos Excel
  ENDIF

RETURN NIL