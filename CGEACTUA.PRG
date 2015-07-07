// Programa.: CGEACTUA.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Actualizacion y Reversion de Movto. Diario.
#include "Fivewin.ch"

MEMVAR oApl

PROCEDURE CgeActua()
   LOCAL oDlg, oFont, oGet := ARRAY(7), aOpc := { NtChr( DATE(),"1" ),1,"" }
   LOCAL aPrv := Privileg( "CIERRE" )
DEFINE FONT oFont NAME "Times New Roman" SIZE 0,-18
DEFINE DIALOG oDlg TITLE "ACTUALIZA MOVIMIENTO" FROM 0, 0 TO 10,50
   @ 02,00 SAY "PERIODO [AAAAMM]"  OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02,92 GET oGet[1] VAR aOpc[1] OF oDlg PICTURE "999999" SIZE 32,12 PIXEL;
      VALID NtChr( aOpc[1],"P" )
   @ 16,00 SAY   "PROCESO  [A/R]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 16,92 COMBOBOX oGet[2] VAR aOpc[2] ITEMS {"Actualiza","Reversa"} SIZE 60,99;
      OF oDlg PIXEL
   @ 32, 10 BUTTON oGet[3] PROMPT "Aceptar"   SIZE 40,12 OF oDlg ACTION;
      ( oGet[3]:Disable(), Actualiza( aOpc,oDlg ), oGet[3]:Enable(),;
        oGet[3]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 32, 53 BUTTON oGet[4] PROMPT "Cancelar"  SIZE 40,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 32, 96 BUTTON oGet[6] PROMPT "Descuadre" SIZE 40,12 OF oDlg ACTION;
      ( oGet[6]:Disable(), CuadreACU( aOpc,oDlg ), oGet[6]:Enable(),;
        oGet[6]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 32,139 BUTTON oGet[7] PROMPT "Cerrar Periodo" SIZE 44,12 OF oDlg ACTION;
      ( oGet[7]:Disable(), CierrePer( aOpc,oDlg ), oGet[7]:Enable(),;
        oGet[7]:oJump := oGet[1], oGet[1]:SetFocus() ) ;
      WHEN aPrv[1] PIXEL
   @ 47, 01 SAY "[CGEACTUA]" OF oDlg PIXEL SIZE 32,10
   @ 47, 34 SAY oGet[5] VAR aOpc[3] OF oDlg PIXEL SIZE 100,20 ;
      UPDATE COLOR nRGB( 160,19,132 ) FONT oFont
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT Empresa( .t. )
oFont:End()
RETURN

//------------------------------------//
PROCEDURE Actualiza( aLS,oDlg )
   LOCAL aRes, cQry, hRes, nL, nSec, oMvd
 //LOCAL cPro, nP, oAuc, oAun
If RIGHT(aLS[1],2) # "13"
   If Buscar( {"empresa",oApl:nEmpresa,"ano_mes",STUFF( aLS[1],5,2,"13" )},;
              "cgecntrl","cierre",8,,3 )
      MsgStop( "El Cierre ya fue Hecho",">>> OJO <<<" )
      RETURN
   EndIf
EndIf
If Buscar( {"empresa",oApl:nEmpresa,"ano_mes",aLS[1]},;
           "cgecntrl","cierre",8,,3 )
   MsgStop( "Periodo ya esta CERRADO",aLS[1] )
   RETURN
EndIf
If aLS[2] == 2
   aLS[3] := "R E V E R S A N D O" ; oDlg:Update()
   aRes := "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND ano_mes = " + xValToChar( aLS[1] )
   cQry := "UPDATE cgemovc SET estado = 0 " + aRes + " AND estado = 1"
   MSQuery( oApl:oMySql:hConnect,cQry )
   cQry := "UPDATE cgeacumc SET valor_deb = 0, valor_cre = 0 " + aRes
   MSQuery( oApl:oMySql:hConnect,cQry )
   cQry := "UPDATE cgeacumn SET valor_deb = 0, valor_cre = 0, valor_ret = 0 " +aRes
   MSQuery( oApl:oMySql:hConnect,cQry )
/*   If RIGHT(aLS[1],2) == "13"
      cQry := "UPDATE cgecntrl SET cierre = '0' " + aRes
      MSQuery( oApl:oMySql:hConnect,cQry )
   EndIf*/
   RETURN
EndIf
oDlg:SetText( "<< ESPERE >> A C T U A L I Z A N D O" )
/*
oAuc := oApl:Abrir( "cgeacumc","empresa, ano_mes",,,5 )
oAun := oApl:Abrir( "cgeacumn","empresa, ano_mes",,,5 )
oPuc := oApl:Abrir( "cgeplan" ,"empresa, cuenta",,,5 )
*/
oMvd := oApl:Abrir( "cgemovd" ,"empresa, ano_mes, control",.t.,,5 )
oMvd:ANO_MES := aLS[1]
cQry := "SELECT d.cuenta, d.infa, d.infb, d.infc, d.infd, d.codigo_nit"+;
             ", d.valor_deb, d.valor_cre, d.libro, c.row_id "          +;
        "FROM cgemovc c LEFT JOIN cgemovd d "  +;
         "USING( empresa, ano_mes, control ) " +;
        "WHERE c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.ano_mes = " + xValToChar( aLS[1] )     +;
         " AND c.estado  = 0"
nSec := SECONDS()
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
aLS[2] := 0
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aLS[3] := aRes[1] + STR(nL,7)
   oDlg:Update()
   Acumular( 1,oMvd,4,4,aRes,.f.,.f. )
/*
   oDlg:Update()
   oPuc:Seek( {"empresa",oApl:nPuc,"cuenta",aRes[1]} )
   cPro := If( InfAc( oPuc,@nP ), aRes[nP+1], "" )
   If !oAuc:Seek( {"empresa",oApl:nEmpresa,"cuenta",aRes[1],"ano_mes",aLS[1]} )
      oAuc:EMPRESA := oApl:nEmpresa
      oAuc:ANO_MES := aLS[1] ; oAuc:CUENTA  := aRes[1]
      oAuc:Append(.t.)
   EndIf
   oAuc:VALOR_DEB += aRes[7]
   oAuc:VALOR_CRE += aRes[8]
   oAuc:Update(.f.,1)
   If !oAun:Seek( {"empresa",oApl:nEmpresa,"cuenta",aRes[1],"codigo",cPro,;
                   "codigo_nit",aRes[6],"ano_mes",aLS[1]} )
      oAun:EMPRESA := oApl:nEmpresa
      oAun:ANO_MES := aLS[1] ; oAun:CUENTA     := aRes[1]
      oAun:CODIGO  := cPro   ; oAun:CODIGO_NIT := aRes[6]
      oAun:Append(.t.)
   EndIf
   oAun:VALOR_DEB += aRes[7]
   oAun:VALOR_CRE += aRes[8]
   oAun:VALOR_RET += If( InfAc( oPuc,@nP,"BASE" ), VAL(aRes[nP+1]), 0 )
   oAun:Update(.f.,1)
*/
   If aLS[2]  # aRes[10]
      aLS[2] := aRes[10]
      MSQuery( oApl:oMySql:hConnect,"UPDATE cgemovc SET estado = 1 WHERE row_id = "+;
               LTRIM(STR(aLS[2])) )
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
aLS[3] := "DEMORE " + STR(SECONDS() - nSec) + " Seg"
 oDlg:Update()
//oAuc:Destroy()
//oAun:Destroy()
//oPuc:Destroy()
oMvd:Destroy()
cQry := "DELETE FROM cgeacumc "                       +;
        "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND ano_mes = " + xValToChar( aLS[1] )     +;
         " AND valor_deb = 0 and valor_cre = 0"
MSQuery( oApl:oMySql:hConnect,cQry )
cQry := STRTRAN( cQry,"acumc","acumn" )
MSQuery( oApl:oMySql:hConnect,cQry )
aLS[2] := 1
RETURN

//INSERT nI=2, nF=2
//UPDATE nI=1, nF=2
//DELETE nI=3, nF=3 || REVERSAR 5
//1_row_id, 2_empresa, 3_ano_mes, 4_control, 5_cuenta,
//6_infa, 7_infb, 8_infc, 9_infd, 10_codigo_nit, 11_valor_deb, 12_valor_cre
FUNCTION Acumular( nEstado,oMvd,nI,nF,lInsert,lRefresh,lActucon )
   LOCAL aMvd, aQry, cQry, nC, nP, hRes
   DEFAULT lActucon := oApl:oEmp:TACTUCON
If nEstado # 0 .AND. !lActucon
   aQry := { "WHERE empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND cuenta  = '[CTA]'"                     +;
               " AND libro   =  [LIB]"                      +;
               " AND ano_mes = "+ xValToChar( oMvd:ANO_MES ),;
             "",0,"",.t.,"" }
   FOR nC := nI TO nF
      If nC == 1
         aQry[5] := .f.
         cQry := "SELECT cuenta, infa, infb, infc, infd, "    +;
                  "codigo_nit, -valor_deb, -valor_cre, libro "+;
                 "FROM cgemovd "                              +;
                 "WHERE row_id = " + LTRIM(STR(oMvd:ROW_ID))
         hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
                     MSStoreResult( oApl:oMySql:hConnect ), 0 )
         aMvd := MyReadRow( hRes )
         AEVAL( aMvd, { | xV,nP | aMvd[nP] := MyClReadCol( hRes,nP ) } )
         MSFreeResult( hRes )
      Else
         If VALTYPE( lInsert ) == "A"
            aMvd := lInsert
         Else
            aMvd := {}
            AEVAL( oMvd:axBuffer,{ |xVal,nP| AADD( aMvd, xVal ) },5 )
         EndIf
         If nC == 3 .OR. nC == 5
            aQry[5] := .f.
            aMvd[7] *= -1
            aMvd[8] *= -1
         EndIf
      EndIf
      aMvd[1] := ALLTRIM( aMvd[1] )
      aQry[2] := "" ; aQry[3] := 0
      aQry[6] := Buscar( {"empresa",oApl:nPuc,"cuenta",aMvd[1]},;
                          "cgeplan","infa, infb, infc, infd",8 )
      If LEN( aQry[6] ) == 0
         aQry[6] := { "","","","" }
      EndIf
      FOR nP := 1 TO 4
         If TRIM(aQry[6,nP]) == "BASE"
            aQry[3] := VAL(aMvd[nP+1])
         Else
            cQry := Buscar( "SELECT 'X' FROM cgeinfac WHERE inf = '" +;
                           aQry[6,nP] + "' AND acumula = '1'","CM",,8 )
            If !EMPTY( cQry )
               aQry[2] := ALLTRIM( aMvd[nP+1] )
            EndIf
         EndIf
      NEXT nP
    //aQry[2] := ALLTRIM( If( InfAc( aMvd[1],@nP ), aMvd[nP+1], "" ) )
    //aQry[3] := If( InfAc( aMvd[1],@nP,"BASE" ), VAL(aMvd[nP+1]), 0 )
      aQry[4] := "SELECT row_id FROM cgeacumc " +;
                 STRTRAN( aQry[1],"[CTA]",    aMvd[1] )
      aQry[4] := STRTRAN( aQry[4],"[LIB]",STR(aMvd[9],2) )
      hRes := If( MSQuery( oApl:oMySql:hConnect,aQry[4] ) ,;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      If MSNumRows( hRes ) > 0
         cQry := MyReadRow( hRes )
         cQry := "UPDATE cgeacumc SET"                             +;
                  " valor_deb = valor_deb + " + LTRIM(STR(aMvd[7]))+;
                 ", valor_cre = valor_cre + " + LTRIM(STR(aMvd[8]))+;
                 " WHERE row_id = " + cQry[1]
         Guardar( cQry,"cgeacumc" )
      ElseIf aQry[5]
         //row_id, empresa, ano_mes, cuenta, libro, valor_deb, valor_cre
         cQry := "INSERT INTO cgeacumc VALUES( null, "+;
                  LTRIM(STR(oApl:nEmpresa)) +  ", '" +;
                  oMvd:ANO_MES              + "', '" +;
                            aMvd[1]         + "', "  +;
                  LTRIM(STR(aMvd[9]))       +  ", "  +;
                  LTRIM(STR(aMvd[7]))       +  ", "  +;
                  LTRIM(STR(aMvd[8]))       +  " )"
         Guardar( cQry,"cgeacumc" )
      EndIf
      MSFreeResult( hRes )
      aQry[4] := STRTRAN( aQry[4],"acumc","acumn" )      +;
                 " AND codigo = '"    + aQry[2]          +;
                "' AND codigo_nit = " + LTRIM(STR(aMvd[6]))
      hRes := If( MSQuery( oApl:oMySql:hConnect,aQry[4] ) ,;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      If MSNumRows( hRes ) > 0
         cQry := MyReadRow( hRes )
         cQry := "UPDATE cgeacumn SET"                             +;
                  " valor_deb = valor_deb + " + LTRIM(STR(aMvd[7]))+;
                 ", valor_cre = valor_cre + " + LTRIM(STR(aMvd[8]))+;
                 ", valor_ret = valor_ret + " + LTRIM(STR(aQry[3]))+;
                 " WHERE row_id = " + cQry[1]
         Guardar( cQry,"cgeacumn" )
      ElseIf aQry[5]
         //row_id, empresa, ano_mes, cuenta, libro, codigo, codigo_nit, valor_deb, valor_cre, valor_ret
         cQry := "INSERT INTO cgeacumn VALUES( null, "+;
                  LTRIM(STR(oApl:nEmpresa)) +  ", '" +;
                  oMvd:ANO_MES              + "', '" +;
                            aMvd[1]         + "', "  +;
                  LTRIM(STR(aMvd[9]))       +  ", '" +;
                            aQry[2]         + "', "  +;
                  LTRIM(STR(aMvd[6]))       +  ", "  +;
                  LTRIM(STR(aMvd[7]))       +  ", "  +;
                  LTRIM(STR(aMvd[8]))       +  ", "  +;
                  LTRIM(STR(aQry[3]))       +  " )"
         Guardar( cQry,"cgeacumn" )
      EndIf
      MSFreeResult( hRes )
      aQry[5] := .t.
   NEXT nC
EndIf
 If nF >= 2 .AND. nF <= 3
    Guardar( oMvd,lInsert,lRefresh )
 EndIf
RETURN NIL

//------------------------------------//
FUNCTION ActuaINF( aCta,aDet,aDes )
   LOCAL aInf, cSql, nE, nK
/*
 aDet[1] Comprobante
     [2] Factura
     [3] Cta_cte
     [4] Fecha
     [5] Nit
     [6] Codigo_nit
     [7] Cheque
     [8] Nit2
*/
FOR nE := 1 TO LEN( aDet )
   If VALTYPE( aDet[nE] ) == "N" .AND. nE # 6
      aDet[nE] := LTRIM(STR(aDet[nE]))
   EndIf
NEXT nE
FOR nE := 1 TO LEN( aCta )
   If aCta[nE,6] > 0 .OR. aCta[nE,7] > 0
      aInf := Buscar( { "empresa",oApl:nPuc,"cuenta",aCta[nE,1] },"cgeplan",;
                        "infa, infb, infc, infd",8 )
      If LEN( aInf ) == 0
         aInf := { "NIT" }
      EndIf
      FOR nK := 1 TO LEN( aInf )
         cSql := TRIM( aInf[nK] )
         do case
         Case cSql == "BASE"
            aCta[nE,nK+1] := LTRIM(STR(aCta[nE,10],10,0))
         Case cSql == "CHEQUE"
            aCta[nE,nK+1] := aDet[7]
         Case cSql == "COD-VAR"
            aCta[nE,nK+1] := aCta[nE,1]
         Case cSql == "CTA-CTE"
            aCta[nE,nK+1] := aDet[3]
         Case cSql == "DOCUMENTO"
            If aCta[nE,5] == ""
               aCta[nE,nK+1] := aDet[1]
            Else
               aCta[nE,nK+1] := aCta[nE,5]
               aCta[nE,5]    := ""
            EndIf
         Case cSql == "FACTURA"
            aCta[nE,nK+1] := aDet[2]
         Case cSql == "FECHA"
            aCta[nE,nK+1] := DTOC(aDet[4])
         Case cSql == "NIT"
            If aCta[nE,8] == 0
               aCta[nE,nK+1] := aDet[5]
               aCta[nE,8]    := aDet[6]
            Else
               aCta[nE,nK+1] := If( aDet[8] == "0", aCta[nE,1], aDet[8] )
            EndIf
         EndCase
      NEXT nK
      aCta[nE,10] := 1
//CGECHEQU
    //Case cNom[nC] == "DOCUMENTO"
    //   cNom[4+nC] :=  If( lCXP .AND. aCta[nJ,1] == ::oChq:SERVICIO,;
    //                      aCta[nJ,5], ::aMov[18] )
//
   Else
      aCta[nE,10] := 0
   EndIf
NEXT nE
   //Aqui Duplico los registros para las NIIF
//If oApl:oEmp:NIIF .AND. oApl:cPer >= "201501"
If !EMPTY(oApl:oEmp:NIIF) .AND. oApl:cPer >= oApl:oEmp:NIIF
   If aDes == NIL .OR. LEN( aDes ) == 0
      aDes := { 0 }
   EndIf
   aInf := ACLONE( aCta )
   nK   := 2
   FOR nE := 1 TO LEN( aInf )
      If aCta[nE,10] == 1
         If aDes[1] > 0
            If nE == aDes[nK]
               If aCta[nE,6] > 0
                  aCta[nE,6] -= aDes[1]
               Else
                  aCta[nE,7] -= aDes[1]
               EndIf
               nK ++
               If nK > LEN( aDes )
                  aDes[1] := 0
               EndIf
            EndIf
         EndIf
         AADD( aCta, { aInf[nE,1],aInf[nE,2],aInf[nE,3],aInf[nE,4],aInf[nE,5],;
                       aInf[nE,6],aInf[nE,7],aInf[nE,8],aInf[nE,9], 2 } )
      EndIf
   NEXT nE
EndIf

RETURN NIL

//------------------------------------//
STATIC PROCEDURE CierrePer( aLS,oDlg )
   LOCAL aRes, cQry, nL := 0
If Buscar( {"empresa",oApl:nEmpresa,"ano_mes",aLS[1]},;
           "cgecntrl","cierre",8,,3 )
   aRes := { "ACTIVAR","0" }
Else
   aRes := { "CERRAR" ,"1" }
     nL := Vigente( aLS[1] )
EndIf
If nL == 0
   If MsgNoYes( "Este Periodo "+aLS[1],"QUIERE "+aRes[1] )
      cQry := "UPDATE cgecntrl SET cierre = '" + aRes[2]    +;
            "' WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
              " AND ano_mes = "  + xValToChar( aLS[1] )
     MSQuery( oApl:oMySql:hConnect,cQry )
   EndIf
Else
   MsgStop( "Debe ser Actualizado Primero","Periodo "+aLS[1] )
EndIf
RETURN

//------------------------------------//
STATIC PROCEDURE CuadreACU( aLS,oDlg )
   LOCAL aRes, cQry, hRes, nL, nC := 0, oRpt
MSQuery( oApl:oMySql:hConnect,"DROP TABLE temporalm" )
cQry := "CREATE TABLE temporalm AS "                    +;
        "SELECT d.empresa, d.ano_mes, cuenta, "         +;
        "SUM(IFNULL(valor_deb,0)) valor_deb, SUM(IFNULL(valor_cre,0)) valor_cre "+;
        "FROM cgemovc c LEFT JOIN cgemovd d "           +;
         "USING( empresa, ano_mes, control ) "          +;
        "WHERE c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.ano_mes = " + xValToChar( aLS[1] )     +;
         " AND c.estado <> 2 "                          +;
        "GROUP BY d.cuenta"
MSQuery( oApl:oMySql:hConnect,cQry )

MSQuery( oApl:oMySql:hConnect,"DROP TABLE temporalc" )
cQry := "CREATE TABLE temporalc AS "                     +;
        "SELECT m.empresa, m.ano_mes, m.cuenta, m.valor_deb, m.valor_cre "+;
        "FROM temporalm m "                              +;
        "WHERE NOT EXISTS ( SELECT 'x' FROM cgeacumc t " +;
                           "WHERE t.empresa = m.empresa" +;
                            " AND t.ano_mes = m.ano_mes" +;
                            " AND t.cuenta  = m.cuenta"  +;
                            " AND IFNULL(t.valor_deb,0) = m.valor_deb"+;
                            " AND IFNULL(t.valor_cre,0) = m.valor_cre)"
MSQuery( oApl:oMySql:hConnect,cQry )

MSQuery( oApl:oMySql:hConnect,"DROP TABLE temporaln" )
cQry := "CREATE TABLE temporaln AS "                     +;
        "SELECT empresa, ano_mes, cuenta, "              +;
        "SUM(IFNULL(valor_deb,0)) valor_deb, SUM(IFNULL(valor_cre,0)) valor_cre "+;
        "FROM cgeacumn "                                 +;
        "WHERE empresa  = " + LTRIM(STR(oApl:nEmpresa))  +;
         " AND ano_mes  = " + xValToChar( aLS[1] )       +;
        " GROUP BY cuenta"
MSQuery( oApl:oMySql:hConnect,cQry )

cQry := "SELECT 'C', cuenta, valor_deb, valor_cre "          +;
        "FROM temporalc UNION ALL "                          +;
        "SELECT 'N', m.cuenta, m.valor_deb, m.valor_cre "    +;
        "FROM temporalm m "                                  +;
        "WHERE NOT EXISTS ( SELECT 'x' FROM temporaln t "    +;
                           "WHERE t.empresa   = m.empresa"   +;
                            " AND t.ano_mes   = m.ano_mes"   +;
                            " AND t.cuenta    = m.cuenta"    +;
                            " AND t.valor_deb = m.valor_deb" +;
                            " AND t.valor_cre = m.valor_cre)"+;
        " ORDER BY cuenta"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "PERIODO ESTA CUADRADO",aLS[1] )
   MSFreeResult( hRes )
   RETURN
EndIf
   oRpt := TDosPrint()
   oRpt:New( oApl:cPuerto,oApl:cImpres,{"DESCUADRE EN LOS ACUMULADOS",;
             "PERIODO : " + aLS[1],;
             " X  CUENTA            D E B I T O S      C R E D I T O S"},.t.,1,2 )
While nL > 0
   aRes := MyReadRow( hRes )
   AEval( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   cQry := "SELECT valor_deb, valor_cre FROM temporal" + LOWER(aRes[1]) +;
          " WHERE cuenta = " + xValToChar( aRes[2] )
   cQry := Buscar( cQry,"CM",,8 )
   If LEN( cQry ) == 0
      cQry := { 0,0 }
   EndIf
   If cQry[1] # aRes[3] .OR. cQry[2] # aRes[4]
      oRpt:Titulo( 96 )
      oRpt:Say( oRpt:nL,01,aRes[1] + "  " + aRes[2] )
      oRpt:Say( oRpt:nL,17,TRANSFORM( cQry[1],"999,999,999,999.99" ) )
      oRpt:Say( oRpt:nL,38,TRANSFORM( cQry[2],"999,999,999,999.99" ) )
      oRpt:Say( oRpt:nL,59,TRANSFORM( aRes[3],"999,999,999,999.99" ) )
      oRpt:Say( oRpt:nL,80,TRANSFORM( aRes[4],"999,999,999,999.99" ) )
      oRpt:nL ++
      nC ++
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
If nC == 0
   MsgInfo( "PERIODO ESTA CUADRADO",aLS[1] )
   oRpt:End()
Else
   oRpt:NewPage()
   oRpt:End()
EndIf
RETURN