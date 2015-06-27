// Programa.: NOMCPBTE.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Genera los Asientos de la Nomina.
#include "FiveWin.ch"
#include "Btnget.ch"

MEMVAR oApl

PROCEDURE AsientosCge( nOpc )
   LOCAL oDlg, oGet := ARRAY(5), aOP, oA := TAsientos()
   DEFAULT nOpc := 1
oA:NEW( nOpc,{"","APORTES SOCIALES Y PARAFISCALES",;
              "PROVISION PRESTACIONES LABORALES","APORTES ASOCIADOS"}[nOpc] )
aOP := { { {|| oA:Asientos( oDlg ) } ,"Asiento pago Nomina" },;
         { {|| oA:Aportes( oDlg ) }  ,"Aportes Sociales" }   ,;
         { {|| oA:Provision( oDlg ) },"Provision" }          ,;
         { {|| oA:ASociales( oDlg ) },"APORTE SOCIAL" } }
DEFINE DIALOG oDlg TITLE aOP[nOpc,2] FROM 0, 0 TO 11,58
   @ 02, 00 SAY "FECHA [DD.MM.AA]"    OF oDlg RIGHT PIXEL SIZE 80,10
   @  02, 82 BTNGET oGet[1] VAR oA:aLS[1] OF oDlg             ;
      ACTION EVAL({|| If( oA:Fechas(), oGet[1]:Refresh(), ) });
      VALID {|| oA:New( nOpc,oA:aLS[1] )     ,;
                oGet[2]:Refresh(), .t. }      ;
      SIZE 44,10 PIXEL RESOURCE "BUSCAR"
   @ 14, 00 SAY "No. DE COMPRBANTE"   OF oDlg RIGHT PIXEL SIZE 80,10
   @ 14, 82 GET oGet[2] VAR oA:aLS[2] OF oDlg SIZE  40,10 PIXEL;
      VALID( If( oA:aLS[2] > 0 , .t.                          ,;
               ( MsgStop("COMPRBANTE TIENE QUE SER MAYOR DE 0 "), .f. ) ) )
   @ 26, 00 SAY "CONCEPTO"            OF oDlg RIGHT PIXEL SIZE 80,10
   @ 26, 82 GET oGet[3] VAR oA:aLS[3] OF oDlg SIZE 126,10 PIXEL

   @ 40, 50 BUTTON oGet[4] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[4]:Disable(), EVAL( aOP[ nOpc,1 ] ), oDlg:End() ) PIXEL
   @ 40,100 BUTTON oGet[5] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 46, 02 SAY "[NOMCPBTE]" OF oDlg PIXEL SIZE 32,10
   @ 58, 52 METER oA:oGet1 VAR oA:nHora TOTAL 100 SIZE 46,10 OF oDlg PIXEL
   @ 70, 04   SAY oA:oGet2 VAR oA:aLS[5] OF oDlg PIXEL SIZE 170,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
oA:oMvc:Destroy()
oA:oMvd:Destroy()
 MSQuery( oApl:oMySql:hConnect,"DROP TABLE "+oA:cTB )
 oApl:oDb:GetTables()
RETURN

//------------------------------------//
CLASS TAsientos

 DATA aRP AS ARRAY INIT {}
 DATA nHora        INIT 0
 DATA aLS, aPF, cTB, nFte, oGet1, oGet2, oMvc, oMvd

 METHOD NEW( nOpc,dFec ) Constructor
 METHOD Fechas()
 METHOD Asientos( oDlg )
 METHOD Aportes( oDlg )
 METHOD Provision( oDlg )
 METHOD ASociales( oDlg )
 METHOD Grabar( aLS )
 METHOD BuscaMov( oDlg,nX,nFte )
 METHOD BuscaNit( cCencos,aRes )
 METHOD Detalle( aDet )

ENDCLASS

//------------------------------------//
METHOD New( nOpc,dFec ) CLASS TAsientos
   LOCAL cQry, hRes, nL, nTC
If VALTYPE( dFec ) == "C"
   Empresa( .t.,1 )
   ::aLS  := { oApl:oFie:FECHA_HAS,{ 1,99,100,1 }[nOpc],PADR(dFec,40),0,"T" }
   ::cTB  := "movto" + oApl:oEmp:LOCALIZ
   ::nFte := Buscar( "SELECT fuente FROM cgefntes WHERE descripcio LIKE '%NOMINA%'","CM","*",8 )
   ::oMvc := oApl:Abrir( "cgemovc","empresa, ano_mes, control",.t.,,1 )
   ::oMvd := oApl:Abrir( "cgemovd","empresa, ano_mes, control",.t.,,10 )
   ::oMvd:nLimit := 2000
   cQry := "SELECT inicial FROM riesgos ORDER BY nivelarp"
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   While nL > 0
      cQry := MyReadRow( hRes )
      AADD( ::aRP,MyClReadCol( hRes,1 ) )
      nL --
   EndDo
   MSFreeResult( hRes )
   If LEN( ::aRP ) == 0
      AADD( ::aRP,0.522 )
   EndIf
   If oApl:oDb:ExistTable( ::cTB )
      MSQuery( oApl:oMySql:hConnect,"DELETE FROM " + ::cTB )
   Else
      Diccionario( "cgemovd",::cTB )
   EndIf
   If nOpc == 4
      ::aLS[2] := oApl:oEmp:INGRESO
   EndIf
ElseIf nOpc == 1
   cQry := "SELECT fechahas, comprobante, cuantos, row_id FROM nomfecha "+;
           "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
           " AND EXTRACT(YEAR_MONTH FROM fechahas) = '"  + NtChr(dFec,"1")+;
           "' ORDER BY fechahas"
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   nTC  := 0
   While nL > 0
      cQry := MyReadRow( hRes )
      AEVAL( cQry,{|xV,nP| cQry[nP] := MyClReadCol( hRes,nP ) } )
         ::aLS[2] := cQry[2]
         nTC      += cQry[3]
      If cQry[1] == dFec
         ::aLS[2] += If( cQry[2] == 0, nTC+1, 0 )
         ::aLS[4] := cQry[4]
         EXIT
      EndIf
      nL --
   EndDo
   MSFreeResult( hRes )
EndIf
RETURN NIL

//------------------------------------//
METHOD Fechas() CLASS TAsientos
   LOCAL aFec, aRes, hRes, nL
   LOCAL oBrw, oDlg, lReturn
aRes := "SELECT fechades, fechahas, comprobante, cuantos FROM nomfecha "    +;
        "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))                      +;
         " AND EXTRACT(YEAR_MONTH FROM fechahas) = '"  + NtChr(::aLS[1],"1")+;
        "' ORDER BY fechahas"
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If(nL := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   RETURN .f.
EndIf
aFec := {}
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
   AADD( aFec, { aRes[1],aRes[2],aRes[3],aRes[4] } )
   nL --
EndDo
MSFreeResult( hRes )

hRes := {|| lReturn := .t., ::aLS[1] := aFec[oBrw:nAt][2], oDlg:End() }
lReturn := .f.
DEFINE DIALOG oDlg FROM 3, 3 TO 16, 42 TITLE "Ayuda de Fechas"
   @ 1.0,0.6 LISTBOX oBrw ;
      FIELDS "", "", "", "" ;
      HEADERS "FECHA INICIAL", "FECHA FINAL", "COMPROBANTE", "CUANTOS";
      FIELDSIZES 73, 73, 72, 70;
      OF oDlg      SIZE 150, 80;
      ON DBLCLICK EVAL( hRes )
   oBrw:nAt       := 1
   oBrw:bLine     := { || { DTOC(aFec[oBrw:nAt][1]), DTOC(aFec[oBrw:nAt][2]),;
                      TRANSFORM( aFec[oBrw:nAt][3],"999,999" )              ,;
                      TRANSFORM( aFec[oBrw:nAt][4],"999,999" ) } }
   oBrw:bGoTop    := { || oBrw:nAt := 1 }
   oBrw:bGoBottom := { || oBrw:nAt := EVAL( oBrw:bLogicLen ) }
   oBrw:bSkip     := { | nWant, nOld | nOld := oBrw:nAt, oBrw:nAt += nWant,;
                        oBrw:nAt := MAX( 1, MIN( oBrw:nAt, EVAL( oBrw:bLogicLen ) ) ),;
                        oBrw:nAt - nOld }
   oBrw:bLogicLen := { || LEN( aFec ) }
   oBrw:bKeyDown  := {|nKey| If( nKey=VK_RETURN, EVAL( hRes ), ) }
   oBrw:cAlias    := "Array"
ACTIVATE DIALOG oDlg CENTER

RETURN lReturn

//------------------------------------//
METHOD Asientos( oDlg ) CLASS TAsientos
   LOCAL aCta, aRes, cQry, hRes, nK, nL, nSec, nT
   LOCAL cMis, hMis, aM, nCNit
cQry := "SELECT e.cencos, m.nomcor, m.codigo_nit "      +;
        "FROM nomnovec c, nomemple e, cencosto m "      +;
        "WHERE c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fechahas = " + xValToChar( ::aLS[1] )  +;
         " AND e.empresa = c.empresa"                   +;
         " AND e.codigo  = c.codigo"                    +;
         " AND m.cencos  = e.cencos"                    +;
         " GROUP BY e.cencos ORDER BY e.cencos"
hMis := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hMis )) == 0
   MsgInfo( "Error no hay novedades" )
   MSFreeResult( hMis ) ; RETURN NIL
EndIf
oApl:oNit:Seek( {"codigo",25050101} )
nCNit:= oApl:oNit:CODIGO_NIT
cMis := "SELECT e.codigo_nit, c.ptaje, IFNULL(s.cuenta,c.cuenta) CTA, c.db_cr, "+;
               "SUM(IF(d.clasepd = 1,d.valornoved,0)) - "     +;
               "SUM(IF(d.clasepd = 2,d.valornoved,0)), "      +;
               "c.identifica, c.proceso, e.cnit_eps, e.cnit_afp, e.cencos "+;
        "FROM nomnoved d, nocausad s, nocausac c, nomemple e "+;
        "WHERE c.empresa   = " + LTRIM(STR(oApl:nPuc))        +;
         " AND c.secuencia = [nK]"                            +;
         " AND c.secuencia = s.secuencia"                     +;
         " AND d.concepto  = s.concepto"                      +;
         " AND d.fechahas  = " + xValToChar( ::aLS[1] )       +;
         " AND d.empresa   = " + LTRIM(STR(oApl:nEmpresa))    +;
         " AND e.empresa   = d.empresa"                       +;
         " AND e.codigo    = d.codigo"                        +;
         " AND e.cencos    = '[nM]'"                          +;
       " GROUP BY e.codigo_nit, cta, c.db_cr, c.identifica, " +;
                 "c.proceso, c.ptaje, e.cnit_eps, "           +;
                 "e.cencos ORDER BY e.codigo"
aM   := { nL,::aLS[2],nL,.f.,0 }
While aM[1] > 0
   If ::BuscaMov( oDlg,aM[5] )
      MSFreeResult( hMis ) ; RETURN NIL
   EndIf
   aRes := MyReadRow( hMis )
   AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hMis,nP ) } )
   cQry := STRTRAN( cMis,"[nM]",ALLTRIM(aRes[1]) )
   ::oMvc:CONCEPTO  := ALLTRIM(::aLS[3]) + " - " + aRes[2]
   ::oMvc:CODIGONIT := aRes[3]
   FOR nK := 1 TO 25
      aM[4]:= .t.
      aRes := STRTRAN( cQry,"[nK]",LTRIM(STR(nK)) )
      hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      If (nL := MSNumRows( hRes )) > 0
         ::oGet2:SetText( ::oMvc:CONCEPTO+STR(nK,3)+" DE 25="+STR(nL,5) )
         nSec    := 100 / nL
         ::nHora := nT := 0
      EndIf
      While nL > 0
         If INT(nT +=nSec) >= 1
            ::nHora += INT(nT) ; ::oGet1:Refresh() ; SysRefresh()
            nT      -= INT(nT)
         EndIf
         aRes := MyReadRow( hRes )
         AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )

         If ABS(aRes[05]) > 0
            If aM[4]
               aM[4]:= .f.
               aCta := { aRes[3],"","","",STR(nK,2),0,0,0,0,.f. }
            EndIf
            aRes[07] := UPPER( ALLTRIM(aRes[07]) )  //Proceso
            If aRes[07] == "EPS" .AND. aRes[08] > 0
               aCta[08] := aRes[08]
               aCta[10] := .t.
            ElseIf (aRes[07] == "AFP" .OR. aRes[07] == "FSP") .AND. aRes[09] > 0
               aCta[08] := aRes[09]
               aCta[10] := .t.
            ElseIf aRes[07] == "NIT"
               If EMPTY( aRes[10] )
                  aRes[01] := nCNit
               Else
                  ::BuscaNit( aRes[10],@aRes )
               EndIf
            EndIf
            If !aCta[10]
               aCta[08] := aRes[01]
            EndIf
               oApl:oNit:Seek( {"codigo_nit",aCta[08]} )
               aCta[09] := oApl:oNit:CODIGO
            If aRes[04] == 0
               aCta[06] += ABS(aRes[05])      //Debito
            Else
               aCta[07] += ABS(aRes[05])      //Credito
            EndIf
            If nK # 25 .OR. nL == 1
               ::Detalle( aCta )
               aM[4]:= .t.
            EndIf
         EndIf
         nL --
      EndDo
      MSFreeResult( hRes )
   NEXT nK
   ::Grabar( 1 )
//   MsgStop( ::oMvc:CONCEPTO,"Vengo de Grabar "+::cTB )
   ::aLS[2] ++
   MSQuery( oApl:oMySql:hConnect,"DELETE FROM " + ::cTB )
   aM[1] --
   aM[5] ++
EndDo
MSFreeResult( hMis )
cQry := "UPDATE nomfecha SET comprobante = "+ LTRIM(STR(aM[2]))+;
        ", cuantos = "+ LTRIM(STR(aM[3]))+;
        " WHERE row_id = " + LTRIM(STR(::aLS[4]))
MSQuery( oApl:oMySql:hConnect,cQry )
RETURN NIL

//------------------------------------//
METHOD Aportes( oDlg ) CLASS TAsientos
   LOCAL aCta, aRes, cQry, hRes, nK, nL, nSec, nT
aRes := NtChr( LEFT( DTOS(::aLS[1]),6 ),"F" )
cQry := "SELECT COUNT(*) FROM nomnoved "+;
        "WHERE empresa   = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND fechahas >= " + xValToChar( aRes )       +;
         " AND fechahas <= " + xValToChar( ::aLS[1] )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ),0 )
If MSNumRows( hRes ) == 0
   MsgInfo( "Error no hay novedades" )
   MSFreeResult( hRes ) ; RETURN NIL
EndIf
If ::BuscaMov( oDlg,0 )
   MSFreeResult( hRes ) ; RETURN NIL
EndIf
/*
SELECT e.codigo_nit, c.ptaje, c.cuenta, c.db_cr,
   SUM(IF(d.clasepd = 1, d.valornoved, 0)) -
   SUM(IF(d.clasepd = 2, d.valornoved, 0)),
       c.proceso, e.cnit_eps, e.cnit_afp, e.eps,
       e.afp, e.sueldoact, e.nivelarp, c.verbasico
FROM nomnoved d, nocausad s, nocausac c, nomemple e
WHERE c.empresa    = 1
  AND c.secuencia  = 43
  AND c.secuencia  = s.secuencia
  AND d.concepto   = s.concepto
  AND d.fechahas  >= '2014-01-01'
  AND d.fechahas  <= '2014-01-31'
  AND e.empresa    = 1
  AND d.empresa    = e.empresa
  AND d.codigo     = e.codigo
GROUP BY e.codigo_nit, e.codigo
ORDER BY e.codigo
*/
cQry := "SELECT e.codigo_nit, c.ptaje, c.cuenta, c.db_cr, "   +;
               "SUM(IF(d.clasepd = 1, d.valornoved, 0)) - "   +;
               "SUM(IF(d.clasepd = 2, d.valornoved, 0)), "    +;
               "c.proceso, e.cnit_eps, e.cnit_afp, e.eps, "   +;
               "e.afp, e.sueldoact, e.nivelarp, c.verbasico, e.cnit_caja "+;
        "FROM nomnoved d, nocausad s, nocausac c, nomemple e "+;
        "WHERE c.empresa    = " + LTRIM(STR(oApl:nPuc))       +;
         " AND c.secuencia  = [nK]"                           +;
         " AND c.secuencia  = s.secuencia"                    +;
         " AND d.concepto   = s.concepto"                     +;
         " AND d.fechahas  >= " + xValToChar( aRes )          +;
         " AND d.fechahas  <= " + xValToChar( ::aLS[1] )      +;
         " AND e.empresa    = " + LTRIM(STR(oApl:nEmpresa))   +;
         " AND d.empresa    = e.empresa"                      +;
         " AND d.codigo     = e.codigo "                      +;
        "GROUP BY e.codigo_nit, e.codigo "                    +;
        "ORDER BY e.codigo"
FOR nK := 34 TO 45
   hRes := If( MSQuery( oApl:oMySql:hConnect,STRTRAN( cQry,"[nK]",LTRIM(STR(nK)) ) ),;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   If (nL := MSNumRows( hRes )) > 0
      ::oGet2:SetText( "Secuencia"+STR(nK,3)+" DE 45="+STR(nL,5) )
      nSec   := 100 / nL
   EndIf
    ::aPF[4] := ::nHora := nT := 0
   While nL > 0
      If INT(nT +=nSec) >= 1
         ::nHora += INT(nT) ; ::oGet1:Refresh() ; SysRefresh()
         nT      -= INT(nT)
      EndIf
      aRes := MyReadRow( hRes )
      AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
      aRes[5] := ABS(aRes[5])    //Valor
      If aRes[05] > 0
         aCta := { aRes[3],"","","",STR(nK,2),0,0,0,0,.f.,.t. }
         aRes[06] := UPPER( ALLTRIM(aRes[06]) )  //Proceso
         If aRes[06] == "EPS"
            aRes[02] := EVAL( ::aPF[5],oApl:oFis:EPS_EMP,aRes[11] )
          //aRes[02] := oApl:oFis:EPS_EMP
            If aRes[07] > 0
               aCta[08] := aRes[07]
               aCta[10] := .t.
               aCta[11] := aRes[09]
            Else
               aCta[11] := .f.
            EndIf
         ElseIf aRes[06] == "AFP" .OR. aRes[06] == "FSP"
            aRes[02] := If( aRes[06] == "AFP", oApl:oFis:AFP_EMP, oApl:oFis:AFP_FON )
            If aRes[08] > 0
               aCta[08] := aRes[08]
               aCta[10] := .t.
               aCta[11] := aRes[10]
            Else
               aCta[11] := .f.
            EndIf
          //aRes[02] := EVAL( bPF,aRes[02],aRes[11] )
         ElseIf aRes[06] == "ARP"
            aCta[08] := oApl:oFie:CNIT_ARP
            aCta[10] := .t.
            aRes[02] := ::aRP[ aRes[12] ]
         ElseIf aRes[06] == "CAJA"
            //aRes[02] := EVAL( ::aPF[5],oApl:oFis:CAJA,aRes[11] )
            aRes[02] := oApl:oFis:CAJA
            aCta[08] := If( aRes[14] == 0, oApl:oFie:CNIT_CAJA, aRes[14] )
            aCta[10] := .t.
         ElseIf aRes[06] == "ICBF"
            aRes[02] := EVAL( ::aPF[5],oApl:oFis:ICBF,aRes[11] )
            aCta[08] := oApl:oFie:CNIT_ICBF
            aCta[10] := .t.
         ElseIf aRes[06] == "SENA"
            aRes[02] := EVAL( ::aPF[5],oApl:oFis:SENA,aRes[11] )
            aCta[08] := oApl:oFie:CNIT_SENA
            aCta[10] := .t.
         EndIf

         If aCta[11]
            If !aCta[10]
               aCta[08] := aRes[01]
            EndIf
               oApl:oNit:Seek( {"codigo_nit",aCta[08]} )
               aCta[09] := oApl:oNit:CODIGO

            If aRes[13] == 1       //Verbasico
               If aRes[11] > aRes[05]
                  aRes[05] := ROUND( aRes[11]*aRes[02]/100,0 )
               Else
                  aRes[05] := ROUND( aRes[05]*aRes[02]/100,0 )
               EndIf
            Else
                  aRes[05] := ROUND( aRes[05]*aRes[02]/100,0 )
            EndIf
            If aRes[04] == 0
               aCta[06] := aRes[05]      //Debito
            Else
               aCta[07] := aRes[05]      //Credito
            EndIf
            ::Detalle( aCta )
         EndIf
      EndIf
      nL --
   EndDo
   MSFreeResult( hRes )
NEXT nK
::Grabar()
RETURN NIL

//------------------------------------//
METHOD Provision( oDlg ) CLASS TAsientos
   LOCAL aCta, aRes, cQry, hRes, nK, nL, nSec, nT
aRes := NtChr( LEFT( DTOS(::aLS[1]),6 ),"F" )
cQry := "SELECT COUNT(*) FROM nomnoved "+;
        "WHERE empresa   = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND fechahas >= " + xValToChar( aRes )       +;
         " AND fechahas <= " + xValToChar( ::aLS[1] )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ),0 )
If MSNumRows( hRes ) == 0
   MsgInfo( "Error no hay novedades" )
   MSFreeResult( hRes ) ; RETURN NIL
EndIf
If ::BuscaMov( oDlg,0 )
   RETURN NIL
EndIf
cQry := "SELECT e.codigo_nit, c.ptaje, c.cuenta, c.db_cr, "    +;
               "SUM(IF(d.clasepd = 1, d.valornoved, 0)) - "    +;
               "SUM(IF(d.clasepd = 2, d.valornoved, 0)), "     +;
               "c.proceso, e.cnit_eps, e.cnit_afp, e.nivelarp, e.cnit_caja "+;
        "FROM nomnoved d, nocausad s, nocausac c, nomemple e " +;
        "WHERE c.empresa    = " + LTRIM(STR(oApl:nPuc))        +;
         " AND c.secuencia  = [nK]"                            +;
         " AND c.secuencia  = s.secuencia"                     +;
         " AND d.concepto   = s.concepto"                      +;
         " AND d.fechahas  >= " + xValToChar( aRes )           +;
         " AND d.fechahas  <= " + xValToChar( ::aLS[1] )       +;
         " AND e.empresa    = " + LTRIM(STR(oApl:nEmpresa))    +;
         " AND d.empresa    = e.empresa"                       +;
         " AND d.codigo     = e.codigo "                       +;
        "GROUP BY e.codigo_nit, e.codigo "                     +;
        "ORDER BY e.codigo"
//                 "c.Cuenta, c.Db_cr, c.Identifica, c.Proceso, "  +;
//                 "c.Ptaje, e.Cnit_eps, e.Cnit_afp "              +;
FOR nK := 26 TO 33
   hRes := If( MSQuery( oApl:oMySql:hConnect,STRTRAN( cQry,"[nK]",LTRIM(STR(nK)) ) ),;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   If (nL := MSNumRows( hRes )) > 0
      ::oGet2:SetText( "Secuencia"+STR(nK,3)+" DE 33="+STR(nL,5) )
      nSec    := 100 / nL
      ::nHora := nT := 0
   EndIf
   While nL > 0
      If INT(nT +=nSec) >= 1
         ::nHora += INT(nT) ; ::oGet1:Refresh() ; SysRefresh()
         nT      -= INT(nT)
      EndIf
      aRes := MyReadRow( hRes )
      AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
      aRes[5] := ABS(aRes[5])    //Valor
      If aRes[05] > 0
         aCta := { aRes[3],"","","","",0,0,0,0,.f.,.t. }
         aRes[06] := UPPER( ALLTRIM(aRes[06]) )  //Proceso
         If aRes[06] == "EPS"
            aCta[02] := oApl:oFis:EPS_EMP
            If aRes[07] > 0
               aCta[08] := aRes[07]
               aCta[10] := .t.
            EndIf
         ElseIf aRes[06] == "AFP" .OR. aRes[06] == "FSP"
         // aRes[02] := If( aRes[06] == "AFP", oApl:oFis:AFP_EMP, oApl:oFis:AFP_FON )
            If aRes[08] > 0
               aCta[08] := aRes[08]
               aCta[10] := .t.
            EndIf
         ElseIf aRes[06] == "ARP"
            aCta[08] := oApl:oFie:CNIT_ARP
            aCta[10] := .t.
            aRes[02] := ::aRP[ aRes[09] ]
         ElseIf aRes[06] == "CAJA"
         // aRes[02] := oApl:oFis:CAJA
            aCta[08] := If( aRes[10] == 0, oApl:oFie:CNIT_CAJA, aRes[10] )
            aCta[10] := .t.
         ElseIf aRes[06] == "SENA"
          //aRes[02] := EVAL( ::aPF[5],oApl:oFis:SENA,aRes[11] )
            aCta[08] := oApl:oFie:CNIT_SENA
            aCta[10] := .t.
         ElseIf aRes[06] == "ICBF"
         // aRes[02] := oApl:oFis:ICBF
            aCta[08] := oApl:oFie:CNIT_ICBF
            aCta[10] := .t.
         EndIf

         If !aCta[10]
            aCta[08] := aRes[01]
         EndIf
            oApl:oNit:Seek( {"codigo_nit",aCta[08]} )
            aCta[09] := oApl:oNit:CODIGO
            aRes[05] := ROUND( aRes[05]*aRes[02]/100,0 )
         If aRes[04] == 0
            aCta[06] := aRes[05]      //Debito
         Else
            aCta[07] := aRes[05]      //Credito
         EndIf
         ::Detalle( aCta )
      EndIf
      nL --
   EndDo
   MSFreeResult( hRes )
NEXT nK
::Grabar()
RETURN NIL

//------------------------------------//
METHOD ASociales( oDlg ) CLASS TAsientos
   LOCAL aPT, aRes, cQry, hRes, nL, nSec, nT
::aLS[1] := CTOD( NtChr(::aLS[1],"4" ) )
If ::BuscaMov( oDlg,0,1 )
   RETURN NIL
EndIf
 aPT := { ROUND( oApl:oFis:SALARIOMIN * .001,0 ),;
          ROUND( oApl:oFis:SALARIOMIN * .002,0 ),;
          ROUND( oApl:oFis:SALARIOMIN * .003,0 ),0 }
aRes := NtChr( LEFT( DTOS(::aLS[1]),6 ),"F" )
cQry := "SELECT n.codigo, n.codigo_nit FROM nomemple e, cadclien n "+;
        "WHERE e.empresa   = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND e.fechaing >= " + xValToChar( aRes )       +;
         " AND e.fechaing <= " + xValToChar( ::aLS[1] )   +;
         " AND n.codigo_nit = e.codigo_nit "              +;
        "GROUP BY n.codigo_nit ORDER BY n.codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ),0 )
If (nL := MSNumRows( hRes )) > 0
   ::oGet2:SetText( "Nuevos = "+STR(nL,5) )
   nSec    := 100 / nL
   ::nHora := nT := 0
   If ::aLS[2] > oApl:oEmp:INGRESO
      oApl:oEmp:INGRESO := ::aLS[2] ; oApl:oEmp:Update(.f.,1)
   EndIf
EndIf
While nL > 0
   If INT(nT +=nSec) >= 1
      ::nHora += INT(nT) ; ::oGet1:Refresh() ; SysRefresh()
      nT      -= INT(nT)
   EndIf
   aRes := MyReadRow( hRes )
   AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
   ::Detalle( { "31100501","","","","",0,aPT[1],aRes[2],aRes[1] } )
   ::Detalle( { "31100503","","","","",0,aPT[2],aRes[2],aRes[1] } )
   aPT[4] += (aPT[1] + aPT[2])
   nL --
EndDo
MSFreeResult( hRes )

aRes := CTOD( STUFF( DTOC( ::aLS[1] ),1,2,"15" ) )
cQry := "SELECT n.codigo, n.codigo_nit "                 +;
        "FROM nomnoved d, nomemple e, cadclien n "       +;
        "WHERE d.empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
        " AND (d.fechahas = " + xValToChar( aRes )       +;
         " OR  d.fechahas = " + xValToChar(::aLS[1] )    +;
        ") AND e.empresa  = d.empresa"                   +;
         " AND e.codigo   = d.codigo"                    +;
         " AND n.codigo_nit = e.codigo_nit "             +;
       " GROUP BY n.codigo_nit"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ),0 )
If (nL := MSNumRows( hRes )) > 0
   ::oGet2:SetText( "Viejos = "+STR(nL,5) )
   nSec    := 100 / nL
   ::nHora := nT := 0
   If ::aLS[2] > oApl:oEmp:INGRESO
      oApl:oEmp:INGRESO := ::aLS[2] ; oApl:oEmp:Update(.f.,1)
   EndIf
EndIf
While nL > 0
   If INT(nT +=nSec) >= 1
      ::nHora += INT(nT) ; ::oGet1:Refresh() ; SysRefresh()
      nT      -= INT(nT)
   EndIf
   aRes := MyReadRow( hRes )
   AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
   ::Detalle( { "31100502","","","","",0,aPT[3],aRes[2],aRes[1] } )
   aPT[4] += aPT[3]
   nL --
EndDo
MSFreeResult( hRes )
::Detalle( { "11050501","11050501","","","",aPT[4],0,0,0 } )
::Grabar()

RETURN NIL

//------------------------------------//
METHOD Grabar( aLS ) CLASS TAsientos
   LOCAL aRes, cQry, hRes, nC, nIFRS, nL, nT, nSec
cQry := "SELECT cuenta, infa, infb, infc, infd, "      +;
          "codigo_nit, SUM(valor_deb), SUM(valor_cre) "+;
        "FROM " + ::cTB                                +;
       " WHERE empresa = 1"                            +;
         " AND ano_mes = '000000'"                     +;
         " AND control = 1"                            +;
         " GROUP BY infd, cuenta, infa, infb, infc, codigo_nit"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) > 0
   ::oGet2:SetText( "Parte Final "+STR(nL,4) )
   nSec    := 100 / nL
   ::nHora := nT := 0
   ::oMvc:CONSECUTIV := nL
   ::oMvc:ESTADO     := 1
   ::oMvc:Update(.f.,1)
EndIf
nIFRS := If( !EMPTY(oApl:oEmp:NIIF) .AND. oApl:cPer >= oApl:oEmp:NIIF, 2, 1 )
While nL > 0
   aRes := MyReadRow( hRes )
   If INT(nT +=nSec) >= 1
      ::nHora += INT(nT) ; ::oGet1:Refresh() ; SysRefresh()
      nT      -= INT(nT)
   EndIf
   AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[5] := If( aLS == NIL, aRes[5], "" )
/*
   nRow := Buscar( "SELECT row_id FROM cgemovd WHERE empresa = -9 LIMIT 1","CM",,8 )
   If EMPTY( nRow )
      cQry := "INSERT INTO cgemovd VALUES( null, "+;
               LTRIM(STR(oApl:nEmpresa)) +  ", '" +;
                         oApl:cPer       + "', "  +;
               LTRIM(STR(::oMvc:CONTROL))+  ", '" +;
                         aRes[1]         + "', '" +;
                         aRes[2]         + "', '" +;
                         aRes[3]         + "', '" +;
                         aRes[4]         + "', '" +;
                         aRes[5]         + "', "  +;
                         aRes[6]         +  ", "  +;
                         aRes[7]         +  ", "  +;
                         aRes[8]         +  " )"
   Else
      cQry := "UPDATE cgemovd SET Empresa = "  + LTRIM(STR(oApl:nEmpresa)) +;
                               ", Ano_mes = '" +          oApl:cPer        +;
                              "', Control = "  + LTRIM(STR(::oMvc:CONTROL))+;
                                ", Cuenta = '" +           aRes[1]         +;
                                 "', Infa = '" +           aRes[2]         +;
                                 "', Infb = '" +           aRes[3]         +;
                                 "', Infc = '" +           aRes[4]         +;
                                 "', Infd = '" +           aRes[5]         +;
                           "', Codigo_nit = "  +           aRes[6]         +;
                             ", Valor_deb = "  +           aRes[7]         +;
                             ", Valor_cre = "  +           aRes[8]         +;
             " WHERE Row_id = " + LTRIM(STR(nRow))
   EndIf
   MSQuery( oApl:oMySql:hConnect,cQry )
*/
   FOR nC := 1 TO nIFRS
      ::oMvd:Seek( "empresa = -9 LIMIT 1","CM" )
      ::oMvd:EMPRESA   := oApl:nEmpresa ; ::oMvd:ANO_MES  := oApl:cPer
      ::oMvd:CONTROL   := ::oMvc:CONTROL; ::oMvd:CUENTA   := aRes[1]
      ::oMvd:INFA      := aRes[2]       ; ::oMvd:INFB     := aRes[3]
      ::oMvd:INFC      := aRes[4]       ; ::oMvd:INFD     := aRes[5]
      ::oMvd:CODIGO_NIT:= aRes[6]
      ::oMvd:VALOR_DEB := aRes[7]       ; ::oMvd:VALOR_CRE:= aRes[8]
      ::oMvd:LIBRO     := nC
      Acumular( 1,::oMvd,2,2,!::oMvd:lOK,.f. )
   NEXT nC
   nL --
EndDo
MSFreeResult( hRes )
RETURN NIL

//------------------------------------//
METHOD BuscaMov( oDlg,nX,nFte ) CLASS TAsientos
   //LOCAL cQry
If nFte == NIL
   nFte := ::nFte
EndIf
oApl:cPer := NtChr( ::aLS[1],"1" )
If ::oMvc:Seek( {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,;
                 "fuente",nFte,"comprobant",::aLS[2]} )
   //If ::oMvc:ESTADO == 1
   //   MsgStop( "Este Comprobante esta Actualizado, Desactualice" )
   //   RETURN .t.
   //ElseIf nX == 0
   If nX == 0
      If !MsgYesNo( ::oMvc:CONCEPTO,"Ya EXISTE QUIERE hacerlo Nuevamente" )
         RETURN .t.
      EndIf
   EndIf
Else
   ::oMvc:EMPRESA   := oApl:nEmpresa ; ::oMvc:ANO_MES  := oApl:cPer
   ::oMvc:FECHA     := ::aLS[1]      ; ::oMvc:FUENTE   := nFte
   ::oMvc:COMPROBANT:= ::aLS[2]      ; ::oMvc:CONCEPTO := ::aLS[3]
   ::oMvc:CONTROL   := SgteCntrl( "control",oApl:cPer,.t. )
   ::oMvc:ESTADO    := 1
   ::oMvc:Append(.t.)
EndIf
 ::oMvc:CONSECUTIV := 0
 nFte := SECONDS()
 ::oMvd:dbEval( {|o| o:EMPRESA := -9, Acumular( ::oMvc:ESTADO,o,3,3,.f.,.f. ) },;
                {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,"control",::oMvc:CONTROL} )
 oApl:oWnd:SetMsg( "Demore "+STR(SECONDS() - nFte)+" Segundos" )
 oApl:oFis:Seek( {"periodoi <= ",oApl:cPer,"periodof >= ",oApl:cPer} )
// ::aPF := { If( oApl:oEmp:RETCREE .AND. oApl:cPer > "201305", .f., .t. ),;
// ::aPF := { If( oApl:oEmp:TREGIMEN == 4 .OR. oApl:cPer < "201305", .t., .f. ),;
// ::aPF := { If( oApl:oEmp:TREGIMEN == 4 .AND. oApl:cPer > "201305", .f., .t. ),;
 ::aPF := { If( oApl:oEmp:RETCREE .AND. oApl:cPer > "201305", .f., .t. ),;
                oApl:oFis:SALARIOMIN * 10, "", 0,;
            { |nPJ,nSB| If( ::aPF[1]       , nPJ,;
                        If( nSB >= ::aPF[2], nPJ, 0 ) ) } }
/*
 cQry := "UPDATE cgemovd SET Empresa = -9 "            +;
         "WHERE Empresa = " + LTRIM(STR(oApl:nEmpresa))+;
          " AND Ano_mes = " + xValToChar( oApl:cPer )  +;
          " AND Control = " + LTRIM( STR(::oMvc:CONTROL) )
 MSQuery( oApl:oMySql:hConnect,cQry )
*/
oDlg:SetText( "<< ESPERE >> GENERANDO ASIENTO" )
RETURN .f.

//------------------------------------//
METHOD BuscaNit( cCencos,aRes ) CLASS TAsientos
   LOCAL cQry, hRes
cQry := "SELECT codigo_nit FROM cencosto "     +;
        "WHERE cencos = " + xValToChar( cCencos )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If MSNumRows( hRes ) > 0
   cQry     := MyReadRow( hRes )
   aRes[01] := MyClReadCol( hRes,1 )
EndIf
MSFreeResult( hRes )
RETURN NIL

//------------------------------------//
METHOD Detalle( aDet ) CLASS TAsientos
   LOCAL aInf, cInf, cQry, cSql, nK
/*
   row_id     "N", empresa   "N", ano_mes   "C",
   control    "N", cuenta    "C", infa      "C",
   infb       "C", infc      "C", infd      "C",
   codigo_nit "N", valor_deb "N", valor_cre "N", ptaje "N"
*/
If aDet[6] > 0 .OR. aDet[7] > 0
   cQry := "INSERT INTO " + ::cTB + " VALUES( null, 1, '000000', 1, '"+;
           ALLTRIM( aDet[1] ) + "', "
   aInf := Buscar( { "empresa",oApl:nPuc,"cuenta",aDet[1] },"cgeplan",;
                     "infa, infb, infc, infd",8 )
   If LEN( aInf ) == 0
      aInf := { "XXX","","","" }
   EndIf
   FOR nK := 1 TO 4
      cInf := ""
      cSql := TRIM( aInf[nK] )
      do case
      Case nK == 4
         cInf := aDet[5]
      Case cSql == "COD-VAR"
         cInf := aDet[2]
      Case cSql == "CTA-CTE"
         cInf := aDet[1]
      Case cSql == "DOCUMENTO"
         cInf := LTRIM(STR(::oMvc:COMPROBANT))
      Case cSql == "FECHA"
         cInf := MyDToMs( DTOS( ::oMvc:FECHA ) )
      Case cSql == "NIT"
         cInf := LTRIM(STR(aDet[9],10,0))
      EndCase
      cQry += "'" + cInf + "', "
   NEXT nK
      cQry += LTRIM(STR(aDet[8])) + ", " +;
              LTRIM(STR(aDet[6])) + ", " +;
              LTRIM(STR(aDet[7])) + ", 0 )"
   If !MSQuery( oApl:oMySql:hConnect,cQry )
      oApl:oMySql:oError:Display( .f. )
      MsgInfo( cQry,"Grabando" )
   EndIf
 //::aPF[4] ++
EndIf
RETURN NIL