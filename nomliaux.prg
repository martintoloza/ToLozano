// Programa.: NOMLIAUX.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listar Descuentos por Conceptos.
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

PROCEDURE NomLiAux()
   LOCAL aOpc, oDlg, oCn, oGet := ARRAY(6)
Empresa( .t.,1 )
aOpc := { 26,oApl:oFie:FECHA_HAS,.f. }
oCn  := TCon() ; oCn:New()
DEFINE DIALOG oDlg TITLE "Listar Auxilares de Descuento" FROM 0, 0 TO 08,46
   @ 02,00 SAY "CONCEPTO" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 02,82 BTNGET oGet[1] VAR aOpc[1] OF oDlg PICTURE "999"          ;
      VALID EVAL( {|| If( oApl:oCon:Seek( {"Concepto",aOpc[1]} )    ,;
                        ( oDlg:Update(), .t. )                      ,;
                 ( MsgStop("Este Concepto NO EXISTE !!!"), .f. )) } );
      SIZE 30,12 PIXEL  RESOURCE "BUSCAR"                            ;
      ACTION Eval({|| If(oCn:Mostrar(), (aOpc[1] := oCn:oDb:CONCEPTO,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
   @ 14,50 SAY    oGet[2] VAR oApl:oCon:NOMBRE OF oDlg PIXEL SIZE 120,10;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 26, 00 SAY "FECHA [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 26, 82 GET oGet[3] VAR aOpc[2] OF oDlg SIZE 40,10 PIXEL
   @ 26,130 CHECKBOX oGet[4] VAR aOpc[3] PROMPT "Vista &Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 40, 50 BUTTON oGet[5] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[5]:Disable(), ListoAux( aOpc ), oDlg:End() ) PIXEL
   @ 40,100 BUTTON oGet[6] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 46, 02 SAY "[NOMLIAUX]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
PROCEDURE ListoAux( aLS )
   LOCAL aRes, aSal, cQry, hRes, nL
   LOCAL oDPrn, aPG := ARRAY(5), aGT := ARRAY(5)
oDPrn := TDosPrint()
oDPrn:New( oApl:cPuerto,oApl:cImpres,{ oApl:oCon:NOMBRE,;
         NtChr( oApl:oFie:FECHA_DES,"2" ) + " HASTA " + NtChr( aLS[2],"2" ),;
         "                                          SALDO       VALOR       VALOR       NUEVO" ,;
         "CODIGO  NOMBRE                         ANTERIOR     CARGADO   DESCUENTO       SALDO"},;
         aLS[3],,2 )
AFILL( aGT,0 )
AFILL( aPG,0 )
cQry := "SELECT d.Codigo, e.Nombre, SUM(d.Valornoved) " +;
        "FROM nomnoved d, nomemple e "                  +;
        "WHERE d.Empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND d.Fechahas = " + xValToChar( aLS[2] )    +;
         " AND d.Concepto = "+ LTRIM(STR(aLS[1]))       +;
         " AND d.Empresa = e.Empresa"                   +;
         " AND d.Codigo = e.Codigo"                     +;
         " GROUP BY d.Codigo ORDER BY d.Codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
cQry := Buscar( {"Condes",aLS[1]},"nomtrafi","Concepto",8 )
If !EMPTY( cQry )
   aRes := NtChr( aLS[2],"1" ) + If( DAY(aLS[2]) >= 16, "2", "1" )
   cQry := "SELECT d.Saldoact, d.Valorcargo "              +;
           "FROM nomdesfi d "                              +;
           "WHERE d.Empresa = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND d.Codigo  = [nC]"                        +;
            " AND d.Concepto = "+ LTRIM(STR( cQry ))       +;
            " AND d.Anomes = (SELECT MAX(m.Anomes) FROM nomdesfi m "+;
                             "WHERE m.Empresa  = d.Empresa"         +;
                              " AND m.Codigo   = d.Codigo"          +;
                              " AND m.Concepto = d.Concepto"        +;
                              " AND m.Anomes <= '" + aRes + "')"
EndIf
cQry := If( aLS[1] # 30, cQry, "" )
While nL > 0
   aRes := MyReadRow( hRes )
   AEval( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aPG[3] += aRes[3]
   If !EMPTY( cQry )
      aSal := Buscar( STRTRAN( cQry,"[nC]",LTRIM(STR(aRes[1])) ),"CM" )
      If LEN( aSal ) > 0
         aPG[1] := aSal[1] + aPG[3]
         aPG[2] := aSal[2]
         aPG[4] := aPG[1] + aPG[2] - aPG[3]
      EndIf
   EndIf
   If aPG[3] > 0 .OR. aPG[1] # 0 .OR. aPG[2] # 0
      oDPrn:Titulo( 90 )
      oDPrn:Say( oDPrn:nL,02,STR(aRes[1],5) )
      oDPrn:Say( oDPrn:nL,08,aRes[2] )
      oDPrn:Say( oDPrn:nL,36,TRANSFORM(aPG[1],"@Z 999,999,999") )
      oDPrn:Say( oDPrn:nL,48,TRANSFORM(aPG[2],"@Z 999,999,999") )
      oDPrn:Say( oDPrn:nL,60,TRANSFORM(aPG[3],   "999,999,999") )
      oDPrn:Say( oDPrn:nL,72,TRANSFORM(aPG[4],"@Z 999,999,999") )
      oDPrn:nL ++
   EndIf
   AEval( aPG, {|nVal,nPos| aGT[nPos] += nVal } )
   AFILL( aPG,0 )
   nL --
EndDo
MSFreeResult( hRes )
oDPrn:Say( oDPrn:nL,10,"Totales ======>" )
oDPrn:Say( oDPrn:nL,36,Transform(aGT[1],"999,999,999") )
oDPrn:Say( oDPrn:nL,48,Transform(aGT[2],"999,999,999") )
oDPrn:Say( oDPrn:nL,60,Transform(aGT[3],"999,999,999") )
oDPrn:Say( oDPrn:nL,72,Transform(aGT[4],"999,999,999") )
oDPrn:NewPage()
oDPrn:End()
RETURN

//------------------------------------//
PROCEDURE ArchPlano( nOpc )
   LOCAL aCCos, aOpc, aRep, oDlg, oGet := ARRAY(7)
   DEFAULT nOpc := 1
Empresa( .t.,1 )
aCCos:= CCosto()
aOpc := { 1,NtChr( NtChr( oApl:oFie:FECHA_HAS,"1" ),"F" ),;
          oApl:oFie:FECHA_HAS,.f.,0,0,.f.,;
          If( nOpc == 1, "Con Prima", "Vista Previa" ) }
aRep := { { {|| ArcPlano( aOpc,aCCos ) },"Archivo Plano" }    ,;
          { {|| ListoRes( aOpc,aCCos ) },"Resumen de Nomina"} ,;
          { {|| Parafisc( aOpc,aCCos ) },"Cuadre Parafiscal"} ,;
          { {|| Resumenp( aOpc,aCCos ) },"Cuadre para Pagos"} ,;
          { {|| Resumenm( aOpc,aCCos ) },"Resumen por Mision"},;
          { {|| Resumenc( aOpc,aCCos ) },"Resumen por Concepto"},;
          { {|| Reprimas( aOpc,aCCos ) },"Calculo de Primas"} ,;
          { {|| Recesant( aOpc,aCCos ) },"Calculo de Cesantias"} }
DEFINE DIALOG oDlg TITLE aRep[nOpc,2] FROM 0, 0 TO 08,50
   @ 02, 00 SAY "EN Mision" OF oDlg RIGHT PIXEL SIZE 30,10
   @ 02, 32 COMBOBOX oGet[1] VAR aOpc[1] ITEMS ArrayCol( aCCos,1 );
     SIZE 150,99 OF oDlg PIXEL
   @ 14, 00 SAY "FECHA INICIAL"    OF oDlg RIGHT PIXEL SIZE 80,10
   @ 14, 82 GET oGet[2] VAR aOpc[2] OF oDlg SIZE 40,10 PIXEL;
     WHEN Rango( nOpc,{3,4} )
   @ 26, 00 SAY "FECHA [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 26, 82 GET oGet[3] VAR aOpc[3] OF oDlg SIZE 40,10 PIXEL
   @ 14,130 CHECKBOX oGet[4] VAR aOpc[7] PROMPT "Dias Trabajados" OF oDlg;
      SIZE 60,10 PIXEL
   @ 26,130 CHECKBOX oGet[5] VAR aOpc[4] PROMPT aOpc[8] OF oDlg;
      SIZE 60,10 PIXEL
   @ 40, 50 BUTTON oGet[6] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[6]:Disable(), EVAL( aRep[nOpc,1] ), oGet[6]:Enable(),;
        oGet[6]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 40,100 BUTTON oGet[7] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 46, 02 SAY "[NOMLIAUX]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
STATIC PROCEDURE ArcPlano( aLS,aMis )
   LOCAL aPLN := { "RC" }, aRes, hRes, cQry, nL
aLS[5] := aLS[6] := 0
cQry := "SELECT n.Codigo, e.Ctacte, e.Tipocta, "         +;
               "SUM(IF(d.Clasepd = 1,d.Valornoved,0)) - "+;
               "SUM(IF(d.Clasepd = 2,d.Valornoved,0)) "  +;
        "FROM nomnoved d, nomemple e, cadclien n "       +;
        "WHERE d.Empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND d.Fechahas = " + xValToChar( aLS[3] )     +;
         " AND e.Empresa  = d.Empresa"                   +;
         " AND e.Codigo   = d.Codigo"+If( aLS[1] == 1, "",;
         " AND e.Cencos = '" + aMis[aLS[1],2] + "'" )    +;
         " AND n.Codigo_nit = e.Codigo_nit"              +;
       " GROUP BY n.Codigo ORDER BY e.Codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEval( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If !EMPTY( aRes[2] )
      aLS[5] += aRes[4]
      aLS[6] ++
      aRes[2]:= ALLTRIM( aRes[2] )
      cQry   := "TR" + STRZERO(aRes[1],16)           +;
                "0000000000000000"                   +;
                PADL( STRTRAN(aRes[2],"-"),16,"0" )  +;
                aRes[3] + "000051"                   +;
                STRTRAN( STRZERO(aRes[4],19,2),"." ) +;
                "0000000209999"                      +;
                STRZERO(0,40)                        +;
                STRZERO(0,18)                        +;
                "00000000"                           +;
                "00000000"                           +;
                "0000000"
      AADD( aPLN,cQry )
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
cQry := STRTRAN( oApl:oEmp:NIT,"." )
cQry := STRTRAN( cQry,"-" )
aRes := ALLTRIM( oApl:oFie:CTACTE )
aPLN[1] += STRZERO( VAL( cQry ),16 )           +;
           "NOMIP" + If( aLS[4], "P", "N" )    +;
           STRZERO( oApl:nEmpresa,2 )          +;
           PADL( STRTRAN( aRes,"-" ),16,"0" )  +;
           oApl:oFie:TIPOCTA + "000051"        +;
           STRTRAN( STRZERO(aLS[5],19,2),"." ) +;
           STRZERO( aLS[6],6 )                 +;
           "00000000" + "000000"               +;
           "00009999" + "00000000"             +;
           "000000"   + "0001"                 +;
           "0000000005890000"                  +;
           STRZERO( 0,40 )
cQry := "NOMI" + oApl:oEmp:LOCALIZ + ".PLN"
FERASE( cQry )
hRes := FCREATE( cQry,0 )
AEval( aPLN, { | xV,nP | FWRITE( hRes, xV + CRLF ) } )
FCLOSE( hRes )
aRes := STR(aLS[6]) + " Registros" + CRLF + TRANSFORM( aLS[5],"9,999,999,999.99" )
MsgInfo( aRes,cQry )
RETURN

//------------------------------------//
STATIC PROCEDURE ListoRes( aLS,aMis )
   LOCAL aRes, hRes, cQry, nL
   LOCAL oDPrn, aPG := { 0,0 }
cQry := Buscar( {"Empresa",oApl:nEmpresa,"Fechahas",aLS[3]},;
                 "nomfecha","Fechades",8 )
oDPrn := TDosPrint()
oDPrn:New( oApl:cPuerto,oApl:cImpres,{ "LISTADO DE NOMINA",aMis[aLS[1],1],;
         "DESDE " + NtChr( cQry,"3" ) + " HASTA " + NtChr( aLS[3],"3" ),;
         "  NRO. CEDULA  NOMBRE                              NRO. CUENTA       V A L O R"},aLS[4] )
cQry := "SELECT n.Codigo, e.Nombre, e.Ctacte, "            +;
               "SUM(IF(d.Clasepd = 1,d.Valornoved,0)) - "  +;
               "SUM(IF(d.Clasepd = 2,d.Valornoved,0)) "    +;
        "FROM nomnoved d, nomemple e, cadclien n "         +;
        "WHERE d.Empresa    = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND d.Fechahas   = " + xValToChar( aLS[3] )     +;
         " AND e.Empresa    = d.Empresa"                   +;
         " AND e.Codigo     = d.Codigo"+If( aLS[1] == 1, "",;
         " AND e.Cencos = '" + aMis[aLS[1],2] + "'" )      +;
         " AND n.Codigo_nit = e.Codigo_nit"                +;
       " GROUP BY n.Codigo ORDER BY e.Nombre"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEval( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   oDPrn:Titulo( 78 )
   oDPrn:Say( oDPrn:nL,00,TRANSFORM(aRes[1],"9,999,999,999") )
   oDPrn:Say( oDPrn:nL,15,aRes[2],35 )
   oDPrn:Say( oDPrn:nL,49,aRes[3] )
   oDPrn:Say( oDPrn:nL,67,TRANSFORM(aRes[4],"999,999,999") )
   oDPrn:nL ++
   aPG[1] ++
   aPG[2] += aRes[4]
   nL --
EndDo
MSFreeResult( hRes )
oDPrn:Say( oDPrn:nL,15,STR(aPG[1])+" Totales ======>" )
oDPrn:Say( oDPrn:nL,67,Transform(aPG[2],"999,999,999") )
oDPrn:NewPage()
oDPrn:End()
RETURN

//------------------------------------//
STATIC PROCEDURE Parafisc( aLS,aMis )
   LOCAL aGT, aPG, aRes, hRes, cQry, nL, oRpt
cQry := "SELECT n.Codigo, e.Nombre, e.Sueldoact, d.Clasepd,"+;
           " d.Concepto, d.Horas, d.Valornoved, e.Fechaing,"+;
                                 " e.Fechaest, e.Estadolab "+;
        "FROM nomnoved d, nomemple e, cadclien n "          +;
        "WHERE d.Empresa   = " + LTRIM(STR(oApl:nEmpresa))  +;
         " AND d.Fechahas >= " + xValToChar( aLS[2] )       +;
         " AND d.Fechahas <= " + xValToChar( aLS[3] )       +;
         " AND e.Empresa   = d.Empresa"                     +;
         " AND e.Codigo    = d.Codigo"+If( aLS[1] == 1, ""  ,;
         " AND e.Cencos = '" + aMis[aLS[1],2] + "'" )       +;
         " AND n.Codigo_nit = e.Codigo_nit"                 +;
       " ORDER BY n.Codigo,  d.Concepto"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes ) ; RETURN
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ "CUADRE DE PARAFICALES",;
         "DESDE " + NtChr( aLS[2],"3" ) + " HASTA " + NtChr( aLS[3],"3" ),aMis[aLS[1],1],;
         "  NRO. CEDULA  N O M B R E                   B A S I C O  DIAS"+;
         "    DEVENGADO    VARIACION  DI   PAGADA EMP  PAGADA EPS"},aLS[4],,2 )
aRes := MyReadRow( hRes )
AEval( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
aPG := { aRes[1],aRes[2],aRes[3],0,0,0,0,0,0,aRes[08],aRes[09],aRes[10] }
aGT := { 0,0,0,0,0,"@Z 999,999,999",0 }
cQry:= Conce( "Caja",.t. )
//{3,4,5,6,7,8,13,34,35,37,40,53,56,57}
While nL > 0
   If aRes[4] == 1
      If aRes[5] <= 2
         aPG[4] += (aRes[6] / 8)
         aPG[5] += aRes[7]
      ElseIf Rango( aRes[5],cQry )
         aPG[6] += aRes[7]
      ElseIf Rango( aRes[5],{9,10,11,24} )
         // Incapacidad
         aPG[7] += aRes[6]
         If aRes[5] == 10
            aPG[8] += aRes[7]
         Else
            aPG[9] += aRes[7]
         EndIf
      EndIf
   //Else
   //   aPG[5] -= aRes[7]
   // If Rango( aRes[5],47,52 )
   //    aPG[7] += aRes[7]  // Salud, Pension, F.S.P.
   // EndIf
   EndIF
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEval( aRes, {|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aPG[1] # aRes[1]
      aGT[7] := aPG[5] + aPG[6]
      oRpt:Titulo( 120 )
      oRpt:Say( oRpt:nL, 00,TRANSFORM(aPG[1],"9,999,999,999") )
      oRpt:Say( oRpt:nL, 14,aPG[2],30 )
      oRpt:Say( oRpt:nL, 45,TRANSFORM(aPG[3],aGT[6]) )
      oRpt:Say( oRpt:nL, 57,Transform(aPG[4],"999.9") )
      oRpt:Say( oRpt:nL, 64,TRANSFORM(aPG[5],aGT[6]) )
      oRpt:Say( oRpt:nL, 77,TRANSFORM(aPG[6],aGT[6]) )
      oRpt:Say( oRpt:nL, 90,Transform(aPG[7],"@Z 999") )
      oRpt:Say( oRpt:nL, 94,TRANSFORM(aPG[8],aGT[6]) )
      oRpt:Say( oRpt:nL,106,TRANSFORM(aPG[9],aGT[6]) )
      oRpt:Say( oRpt:nL,118,If( aPG[6] > 0, "SI", "" ) )
      oRpt:Say( oRpt:nL,121,TRANSFORM(aGT[7],aGT[6]) )
   /* If aPG[12] == "R" .AND. Rango( aPG[11],aLS[2],aLS[3] )
         oRpt:Say( oRpt:nL,121,"R_"+DTOC(aPG[11]) )
      ElseIf Rango( aPG[10],aLS[2],aLS[3] )
         oRpt:Say( oRpt:nL,121,"N_"+DTOC(aPG[10]) )
      EndIf*/
      oRpt:nL ++
      aGT[1] ++
      aGT[2] += aPG[5]
      aGT[3] += aPG[6]
      aGT[4] += aPG[8]
      aGT[5] += aPG[9]
      aPG := { aRes[1],aRes[2],aRes[3],0,0,0,0,0,0,aRes[08],aRes[09],aRes[10] }
   EndIf
EndDo
MSFreeResult( hRes )
oRpt:Say( oRpt:nL, 40,STR(aGT[1],5)+" Totales ======>" )
oRpt:Say( oRpt:nL, 64,Transform(aGT[2],aGT[6]) )
oRpt:Say( oRpt:nL, 77,Transform(aGT[3],aGT[6]) )
oRpt:Say( oRpt:nL, 94,Transform(aGT[4],aGT[6]) )
oRpt:Say( oRpt:nL,106,Transform(aGT[5],aGT[6]) )
oRpt:NewPage()
oRpt:End()
RETURN

//------------------------------------//
STATIC PROCEDURE Resumenm( aLS )
   LOCAL aGT, aRes, hRes, cQry, nL, oDPrn
aLS[2] := CTOD( STUFF( DTOC( aLS[3] ),1,2,"15" ) )
aLS[3] := CTOD( NtChr( aLS[3],"4" ) )
cQry := "SELECT c.Nombre, SUM(IF(d.Clasepd = 1,d.Valornoved,0))" +;
                      " - SUM(IF(d.Clasepd = 2,d.Valornoved,0)),"+;
              " c.Cencos, d.Fechahas "                   +;
        "FROM nomnoved d, nomemple e, cencosto c "       +;
        "WHERE d.Empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
        " AND (d.Fechahas = " + xValToChar( aLS[2] )     +;
         " OR  d.Fechahas = " + xValToChar( aLS[3] )     +;
        ") AND e.Empresa  = d.Empresa"                   +;
         " AND e.Codigo   = d.Codigo"                    +;
         " AND c.Cencos   = e.Cencos"                    +;
       " GROUP BY c.Cencos, d.Fechahas ORDER BY c.Cencos"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes ) ; RETURN
EndIf
oDPrn := TDosPrint()
oDPrn:New( oApl:cPuerto,oApl:cImpres,{"RESUMEN DE NOMINA POR MISION",;
           "NOMINA DE " + NtChr( aLS[3],"6" ),"M I S I O N" + ;
           SPACE(38) + NtChr( aLS[2],"2" )+ "     " + NtChr( aLS[3],"2" )},aLS[4] )
aRes := MyReadRow( hRes )
AEval( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
aGT := { aRes[1],0,0,0,0,0,aRes[3],"@Z 9,999,999,999" }
cQry:= CCosto( 0 )
While nL > 0
   If DAY( aRes[4] ) == 15
      aGT[2] += aRes[2]
   Else
      aGT[3] += aRes[2]
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEval( aRes, {|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aGT[1] # aRes[1]
      oDPrn:Titulo( 78 )
      oDPrn:Say( oDPrn:nL, 00,aGT[1] )
      oDPrn:Say( oDPrn:nL, 47,TRANSFORM(aGT[2],aGT[8]) )
      oDPrn:Say( oDPrn:nL, 63,TRANSFORM(aGT[3],aGT[8]) )
      oDPrn:nL ++
      aGT[7] := ArrayValor( cQry,aGT[7],,.t. )
      cQry[aGT[7],2] := ""
      aGT[1] := aRes[1]
      aGT[4] ++
      aGT[5] += aGT[2]
      aGT[6] += aGT[3]
      aGT[7] := aRes[3]
      aGT[2] := aGT[3] := 0
   EndIf
EndDo
MSFreeResult( hRes )
FOR nL := 1 TO LEN( cQry )
   If !EMPTY( cQry[nL,2] )
      oDPrn:Titulo( 78 )
      oDPrn:Say( oDPrn:nL, 00,cQry[nL,1] )
      oDPrn:nL ++
   EndIf
NEXT nL
oDPrn:Say(++oDPrn:nL, 20,STR(aGT[4],5)+" Totales ======>" )
oDPrn:Say(  oDPrn:nL, 47,Transform(aGT[5],aGT[8]) )
oDPrn:Say(  oDPrn:nL, 63,Transform(aGT[6],aGT[8]) )
oDPrn:NewPage()
oDPrn:End()
RETURN

//------------------------------------//
PROCEDURE Resumenc( aLS,aMis )
   LOCAL aGT, aRes, hRes, cQry, nL, oDPrn
cQry := "SELECT c.Concepto, c.Nombre, d.Clasepd, SUM(d.Valornoved) "+;
        "FROM nomnoved d, nomemple e, nomconce c "       +;
        "WHERE d.Empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND d.Fechahas = " + xValToChar( aLS[3] )     +;
         " AND e.Empresa  = d.Empresa"                   +;
         " AND e.Codigo   = d.Codigo"+If( aLS[1] == 1, "",;
         " AND e.Cencos   = '" + aMis[aLS[1],2] + "'" )  +;
         " AND c.Concepto = d.Concepto"                  +;
       " GROUP BY d.Concepto ORDER BY d.Clasepd, d.Concepto"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes ) ; RETURN
EndIf
oDPrn := TDosPrint()
oDPrn:New( oApl:cPuerto,oApl:cImpres,{ "RESUMEN DE NOMINA POR CONCEPTO",;
           "NOMINA DEL " + NtChr( aLS[3],"3" ),aMis[aLS[1],1],;
           " C O N C E P T O" + SPACE(34) + "V A L O R"},aLS[4] )
aGT  := { 1,0,0,"9,999,999,999" }
aRes := MyReadRow( hRes )
AEval( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
While nL > 0
   oDPrn:Titulo( 78 )
   oDPrn:Say( oDPrn:nL, 00,STR(aRes[1],2)+" "+aRes[2] )
   oDPrn:Say( oDPrn:nL, 46,TRANSFORM(aRes[4],aGT[4]) )
   aGT[2] += aRes[4]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEval( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aGT[1] # aRes[3]
      oDPrn:Say( oDPrn:nL, 62,TRANSFORM(aGT[2],aGT[4]) )
      oDPrn:nL ++
      aGT[3] += If( aGT[1] == 1, aGT[2], -aGT[2] )
      aGT[1] := 2
      aGT[2] := 0
   EndIf
   oDPrn:nL ++
EndDo
MSFreeResult( hRes )
oDPrn:Say( oDPrn:nL, 20," Totales ======>" )
oDPrn:Say( oDPrn:nL, 62,Transform(aGT[3],aGT[4]) )
oDPrn:NewPage()
oDPrn:End()
RETURN

//------------------------------------//
STATIC PROCEDURE Resumenp( aLS,aMis )
   LOCAL aGT, aSA, aRes, hRes, cQry, nK, nL, oDPrn
aGT := Conce( "Caja" )
//aGT := (1, 2, 3, 4, 5, 6, 7, 8, 13, 34, 35, 37, 40, 53, 56, 57)"
If aLS[1] == 1
   cQry := "SELECT e.Cencos, SUM(d.Valornoved) "     +;
           "FROM cadclien n, nomemple e, nomnoved d "+;
           "WHERE n.Codigo    = 32720603"            +;
            " AND e.Empresa   = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND e.Codigo_nit = n.Codigo_nit "              +;
            " AND d.Empresa   = e.Empresa"                   +;
            " AND d.Codigo    = e.Codigo"                    +;
            " AND d.Fechahas >= " + xValToChar( aLS[2] )     +;
            " AND d.Fechahas <= " + xValToChar( aLS[3] )     +;
            " AND d.Concepto IN"  + aGT                      +;
           "GROUP BY e.Cencos"
   aSA  := Buscar( cQry,"CM",,8 )
   cQry := "SELECT c.Cencos, c.Nombre, 9, n.Codigo, SUM(d.Valornoved) "+;
           "FROM nomnoved d, nomemple e, cencosto c, cadclien n "+;
           "WHERE d.Empresa   = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND d.Fechahas >= " + xValToChar( aLS[2] )     +;
            " AND d.Fechahas <= " + xValToChar( aLS[3] )     +;
            " AND d.Concepto IN"  + aGT                      +;
            " AND e.Empresa   = d.Empresa"                   +;
            " AND e.Codigo    = d.Codigo"                    +;
            " AND c.Cencos    = e.Cencos"                    +;
            " AND n.Codigo_nit = c.Codigo_nit "              +;
           "GROUP BY c.Cencos ORDER BY c.Cencos"
//            " AND d.Concepto  = o.Concepto"                  +;
//            " AND o.Caja      = '1'"                         +;
   If LEN( aSA ) == 0
      aSA := { "X",0 }
   EndIf
   aGT  := Buscar( "SELECT Inicial FROM riesgos ORDER BY Nivelarp","CM",,9 )
   AEVAL( aGT, { |xV,nP| nK := xV[1], AADD( aSA,nK ) } )
Else
   cQry := "SELECT n.Codigo, e.Nombre, d.Concepto, d.Horas, d.Valornoved "+;
           "FROM nomnoved d, nomemple e, cadclien n "        +;
           "WHERE d.Empresa   = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND d.Fechahas >= " + xValToChar( aLS[2] )     +;
            " AND d.Fechahas <= " + xValToChar( aLS[3] )     +;
            " AND d.Concepto IN"  + aGT                      +;
            " AND e.Empresa   = d.Empresa"                   +;
            " AND e.Codigo    = d.Codigo"                    +;
            " AND e.Cencos    = '" + aMis[aLS[1],2]          +;
           "' AND n.Codigo_nit = e.Codigo_nit "              +;
           "ORDER BY n.Codigo, d.Concepto"
EndIf
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes ) ; RETURN
EndIf
aRes := MyReadRow( hRes )
AEval( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
cQry := NtChr( aLS[3],"1" )
oApl:oFis:Seek( {"Periodoi <= ",cQry,"Periodof >= ",cQry} )
aGT := { oApl:oFis:AFP_EMP + oApl:oFis:AFP_TRA,;
         oApl:oFis:EPS_EMP + oApl:oFis:EPS_TRA,;
         oApl:oFis:CAJA,0,0,0,0,0,aRes[1],aRes[2],aRes[4],0 }
oDPrn := TDosPrint()
oDPrn:New( oApl:cPuerto,oApl:cImpres,{ "CUADRE DE PAGOS PARA COMBARRANQUILLA",;
         "DESDE " + NtChr( aLS[2],"3" ) + " HASTA " + NtChr( aLS[3],"3" )    ,;
         aMis[aLS[1],1], "  NRO. CEDULA  N O M B R E                       " +;
         "    DEVENGADO  APORTES" + TransForm( aGT[3],"999.9%" )+"       ARP"},aLS[4],,2 )
cQry:= "@Z 999,999,999"
While nL > 0
      aGT[5] += aRes[5]
   If aRes[3] <= 2
      aGT[6] += (aRes[4] / 8)
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEval( aRes, {|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aGT[9] # aRes[1]
      If aLS[1] == 1
         nK := aMis[ ArrayValor( aMis,aGT[9],,.t. ),3 ] +2
         If aGT[9] == aSA[1]
            aGT[5] := aGT[5] + oApl:oFis:SALARIOMIN - aSA[2]
         EndIf
         aGT[6] := ROUND( aGT[5] * aGT[3] / 100, 0  )
         aGT[7] := ROUND( aGT[5] * aSA[nK]/ 100, 0  )
         aGT[9] := aGT[11]
      Else
         If aGT[9] == 32720603
            If aGT[6] < 30
               aGT[5] := ROUND( oApl:oFis:SALARIOMIN / 30 * aGT[6],0 )
            Else
               aGT[5] := oApl:oFis:SALARIOMIN  //Angela Salgado
            EndIf
         EndIf
      EndIf
      oDPrn:Titulo( 88 )
      oDPrn:Say( oDPrn:nL,00,TRANSFORM(aGT[9],"9,999,999,999") )
      oDPrn:Say( oDPrn:nL,15,aGT[10],36 )
      oDPrn:Say( oDPrn:nL,51,TRANSFORM(aGT[5],cQry) )
      oDPrn:Say( oDPrn:nL,64,TRANSFORM(aGT[6],cQry) )
      oDPrn:Say( oDPrn:nL,77,TRANSFORM(aGT[7],cQry) )
      oDPrn:nL ++
      aGT[04] += aGT[5]
      aGT[12] += aGT[7]
      aGT[05] := aGT[06] := 0
      aGT[09] := aRes[1]
      aGT[10] := aRes[2]
      aGT[11] := aRes[4]
   EndIf
EndDo
MSFreeResult( hRes )
aGT[6] := ROUND( aGT[4] * aGT[3] / 100, 0  )
aGT[7] := ROUND( aGT[4] * aGT[1] / 100, 0  )
aGT[8] := ROUND( aGT[4] * aGT[2] / 100, 0  )

oDPrn:Say(++oDPrn:nL,24,"Totales ======>" )
oDPrn:Say(  oDPrn:nL,51,Transform(aGT[04],cQry) )
oDPrn:Say(  oDPrn:nL,64,Transform(aGT[06],cQry) )
oDPrn:Say(  oDPrn:nL,77,Transform(aGT[12],cQry) )
oDPrn:Say(++oDPrn:nL,24,"PENSION"+TransForm( aGT[1],"999.9%" ) )
oDPrn:Say(  oDPrn:nL,51,Transform(aGT[7],cQry) )
oDPrn:Say(++oDPrn:nL,24,"SALUD  "+TransForm( aGT[2],"999.9%" ) )
oDPrn:Say(  oDPrn:nL,51,Transform(aGT[8],cQry) )
oDPrn:NewPage()
oDPrn:End()
RETURN

//------------------------------------//
STATIC PROCEDURE RePrimas( aLS,aMis )
   LOCAL aGT, aRes, cQry, hRes, nL, oRpt
cQry := "SELECT e.Codigo, n.Codigo, e.Nombre, "+;
               "e.Sueldoact, e.Fechaing "      +;
        "FROM nomemple e, cadclien n "         +;
        "WHERE e.Empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND e.Fechaing <= " + xValToChar( aLS[3] )   +;
         " AND e.Estadolab <> 'R'" + If( aLS[1] == 1, "",;
         " AND e.Cencos  = '" + aMis[aLS[1],2] + "'" )  +;
         " AND n.Codigo_nit = e.Codigo_nit "            +;
        "ORDER BY e.Codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes ) ; RETURN
EndIf
If MONTH( aLS[3] ) <= 6
   aLS[2] := CTOD( "01.01."+STR(YEAR(aLS[3]),4) )
   aLS[3] := CTOD( "30.06."+STR(YEAR(aLS[3]),4) )
Else
   aLS[2] := CTOD( "01.07."+STR(YEAR(aLS[3]),4) )
   aLS[3] := CTOD( "30.12."+STR(YEAR(aLS[3]),4) ) + If( aLS[7], 1, 0 )
EndIf
cQry := NtChr( aLS[3],"1" )
oApl:oFis:Seek( {"Periodoi <= ",cQry,"Periodof >= ",cQry} )
aGT  := { oApl:oFis:SALARIOMIN*2,0,0,0,0,0 }
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ aMis[aLS[1],1],"COMPENSACION SEMESTRAL "+;
         NtChr( aLS[2],"2" ) + " HASTA " + NtChr( aLS[3],"2" ),;
         SPACE(42)+"HORAS    COMPENSACI.  COMPENSACI.",;
         SPACE(42)+"EXTRAS    BASICA Y      BASE DE               TOTAL   V A L O R",;
         " COD. N O M B R E                        PROMEDIO  AUX.TRANSP.  LIQUIDACI"+;
         "ON  FEC.INICIAL DIAS COMP.SEMTRAL" },aLS[4],,2 )
cQry := Conce( "Primas" )
//cQry := "(3,4,5,6,7,8,34,35,37,40,53,56,57)"
While nL > 0
   aRes := MyReadRow( hRes )
   AEval( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aRes[4] <= aGT[1]
      aRes[4] += oApl:oFis:TRANSPORTE
    //  aRes[4] += ValorConce( aRes[1],aLS[2],aLS[3],12 )
   EndIf
   aGT[2] := ValorConce( aRes[1],aLS[2],aLS[3]+1,cQry )
   If aLS[7]
      aGT[4] := Dias(  aLS[2],aLS[3],aRes[1] )
   ElseIf aRes[5] > aLS[2]
      aGT[4] := Dias( aRes[5],aLS[3] )
   Else
      aGT[4] := 180
      aRes[5]:= aLS[2]
   EndIf
   aGT[2] := ROUND( aGT[2] / aGT[4] * 30, 0 )
   aGT[3] := aRes[4] + aGT[2]
   aGT[5] := ROUND( aGT[3] / 360 * aGT[4], 0 )
   aGT[6] += aGT[5]
   oRpt:Titulo( 106 )
   oRpt:Say( oRpt:nL, 00,Transform(aRes[1],"9,999") )
   oRpt:Say( oRpt:nL, 06,aRes[3],30 )
   oRpt:Say( oRpt:nL, 38,Transform( aGT[2],"999,999,999") )
   oRpt:Say( oRpt:nL, 51,Transform(aRes[4],"999,999,999") )
   oRpt:Say( oRpt:nL, 64,Transform( aGT[3],"999,999,999") )
   oRpt:Say( oRpt:nL, 77,NtChr( aRes[5],"2" ) )
   oRpt:Say( oRpt:nL, 90,Transform( aGT[4],"999") )
   oRpt:Say( oRpt:nL, 95,Transform( aGT[5],"999,999,999") )
   oRpt:nL ++
   nL --
EndDo
MSFreeResult( hRes )
oRpt:Say(++oRpt:nL, 77,"Totales ======>" )
oRpt:Say(  oRpt:nL, 95,Transform( aGT[6],"999,999,999") )
oRpt:NewPage()
oRpt:End()
RETURN

//------------------------------------//
STATIC PROCEDURE ReCesant( aLS,aMis )
   LOCAL aGT, aRes, cQry, hRes, nL, oRpt
cQry := "SELECT e.Codigo, n.Codigo, e.Nombre, e.Sueldoact"+;
             ", e.Fechaing, e.Fechasuact, e.Sueldoant "   +;
        "FROM nomemple e, cadclien n "                    +;
        "WHERE e.Empresa = " + LTRIM(STR(oApl:nEmpresa))  +;
         " AND e.Fechaing <= " + xValToChar( aLS[3] )     +;
         " AND e.Estadolab <> 'R'" + If( aLS[1] == 1, ""  ,;
         " AND e.Cencos  = '" + aMis[aLS[1],2] + "'" )    +;
         " AND n.Codigo_nit = e.Codigo_nit "              +;
        "ORDER BY n.Codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes ) ; RETURN
EndIf
aLS[2] := CTOD( "01.01."+STR(YEAR(aLS[3]),4) )
aLS[3] := CTOD( "30.12."+STR(YEAR(aLS[3]),4) ) + If( aLS[7], 1, 0 )
cQry := NtChr( aLS[3],"1" )
oApl:oFis:Seek( {"Periodoi <= ",cQry,"Periodof >= ",cQry} )
aGT  := { oApl:oFis:SALARIOMIN*2,0,0,0,0,0,0,0 }
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ aMis[aLS[1],1],"CESANTIAS E INTERESES "+;
         NtChr( aLS[2],"2" ) + " HASTA " + NtChr( aLS[3],"2" ),;
         SPACE(50)+"HORAS    COMPENSACI.  COMPENSACI.",;
         SPACE(50)+"EXTRAS    BASICA Y      BASE DE      TOTAL    V A L O R    V A L O R",;
         " Nro. CEDULA  N O M B R E                        PROMEDIO  AUX.TRANSP.  LIQUID"+;
         "ACION     DIAS    CESANTIAS    INTERESES" },aLS[4],,2 )
cQry := Conce( "Cesantias" )
While nL > 0
   aRes := MyReadRow( hRes )
   AEval( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aRes[6] >   aLS[3] .AND. aRes[7] > 0
      aRes[4] := aRes[7]
   EndIf
   If aRes[4] <= aGT[1]
      aRes[4] += oApl:oFis:TRANSPORTE
   EndIf
 //aGT[2] := ValorConce( aRes[1],aLS[2],aLS[3]+1,cQry )
   aGT[2] := ValorConce( aRes[1],If( aRes[5] > aLS[2], aRes[5], aLS[2] ),;
                         aLS[3]+1,cQry )
   If aLS[7]
      aGT[4] := Dias(  aLS[2],aLS[3],aRes[1] )
   ElseIf aRes[5] > aLS[2]
      aGT[4] := Dias( aRes[5],aLS[3] )
   Else
      aGT[4] := 360
      aRes[5]:= aLS[2]
   EndIf
   aGT[2] := ROUND( aGT[2] / aGT[4] * 30, 0 )
   aGT[3] := aRes[4] + aGT[2]
   aGT[5] := ROUND(  aGT[3]      / 360 * aGT[4],0 )
   aGT[6] := ROUND( (aGT[5]*.12) / 360 * aGT[4],0 )
   aGT[7] += aGT[5]
   aGT[8] += aGT[6]
   oRpt:Titulo( 118 )
 //oRpt:Say( oRpt:nL, 00,Transform(aRes[1],"9,999") )
   oRpt:Say( oRpt:nL, 00,TRANSFORM(aRes[2],"9,999,999,999") )
   oRpt:Say( oRpt:nL, 14,aRes[3],30 )
   oRpt:Say( oRpt:nL, 46,Transform( aGT[2],"999,999,999") )
   oRpt:Say( oRpt:nL, 59,Transform(aRes[4],"999,999,999") )
   oRpt:Say( oRpt:nL, 72,Transform( aGT[3],"999,999,999") )
   oRpt:Say( oRpt:nL, 86,Transform( aGT[4],"999.99") )
   oRpt:Say( oRpt:nL, 94,Transform( aGT[5],"999,999,999") )
   oRpt:Say( oRpt:nL,107,Transform( aGT[6],"999,999,999") )
   oRpt:Say( oRpt:nL,119,NtChr( aRes[5],"2" ) )
   oRpt:nL ++
   nL --
EndDo
MSFreeResult( hRes )
oRpt:Say(++oRpt:nL, 70,"Totales ======>" )
oRpt:Say(  oRpt:nL, 94,Transform( aGT[7],"999,999,999") )
oRpt:Say(  oRpt:nL,107,Transform( aGT[8],"999,999,999") )
oRpt:NewPage()
oRpt:End()
RETURN

//------------------------------------//
FUNCTION CCosto( xAct )
   LOCAL aCCos := { {" ","  ",1} }, aRes, nL, oTB
xAct:= If( xAct == NIL, "", " WHERE Activa = '0'" ) + " ORDER BY Nombre"
oTB := TMsQuery():Query( oApl:oDb,"SELECT Nombre, Cencos, Nivelarp FROM cencosto" + xAct )
If oTB:Open()
   oTB:GoTop()
   FOR nL := 1 TO oTB:nRowCount
      aRes := oTB:Read()
      AADD( aCCos, { aRes[1],aRes[2],VAL(aRes[3]) } )
      oTB:Skip(1)
   NEXT nL
EndIf
oTB:Close()
RETURN aCCos

//------------------------------------//
FUNCTION Conce( cField,lArray )
   LOCAL aRes, cQry, hRes, nL
   DEFAULT lArray := .f.
cQry := "SELECT Concepto FROM nomconce WHERE "+;
         cField + " = '1' ORDER BY Concepto"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
cQry := If( lArray, {}, "(" )
While nL > 0
   aRes := MyReadRow( hRes )
   If lArray
      AADD( cQry, MyClReadCol( hRes,1 ) )
   Else
      cQry += aRes[1] + ", "
   EndIf
     nL --
EndDo
MSFreeResult( hRes )
If !lArray
   cQry := LEFT( cQry,LEN(cQry)-2 ) + ")"
EndIf
RETURN cQry

//------------------------------------//
FUNCTION Dias( dFecI,dFecF,nCod )
   LOCAL aDia, nDia, nL, hRes
/*
    aDia := { YEAR(dFecF),MONTH(dFecF),DAY(dFecF),;
              YEAR(dFecI),MONTH(dFecI),DAY(dFecI) }
 If aDia[3]  < aDia[6]
    aDia[2] --
    aDia[3] += 30
 EndIf
 If aDia[2]  < aDia[5]
    aDia[1] --
    aDia[2] += 12
 EndIf
    nDia := (aDia[3] - aDia[6])       +;
           ((aDia[2] - aDia[5]) * 30) +;
           ((aDia[1] - aDia[4]) * 360)+ 1
*/
If nCod == NIL
   aDia := {  YEAR(dFecF) -  YEAR(dFecI),;
             MONTH(dFecF) - MONTH(dFecI),;
               DAY(dFecF) -   DAY(dFecI) }
   nDia := (aDia[1] * 360) + (aDia[2] * 30) + aDia[3] +1
Else
   aDia := "SELECT Concepto, SUM(Horas) FROM nomnoved "  +;
           "WHERE Empresa = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND Codigo  = " + LTRIM(STR(nCod))         +;
            " AND Fechahas >= " + xValToChar( dFecI )    +;
            " AND Fechahas <= " + xValToChar( dFecF )    +;
            " AND Concepto IN(1, 2, 9, 10, 11, 17)"      +;
            " GROUP BY Concepto"
   hRes := If( MSQuery( oApl:oMySql:hConnect,aDia ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nDia := 0
   nL   := MSNumRows( hRes )
   While nL > 0
      aDia := MyReadRow( hRes )
      AEval( aDia,{|xV,nP| aDia[nP] := MyClReadCol( hRes,nP ) } )
      If aDia[1] <= 2
         aDia[2] := aDia[2] / 8
      EndIf
      nDia += aDia[2]
      nL --
   EndDo
   MSFreeResult( hRes )
EndIf
RETURN nDia
