// Programa.: CAOFACTU.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Genera Factura de las Remisiones
#include "Fivewin.ch"

MEMVAR oApl

PROCEDURE CaoFactu( dFecI,nNit,cFac,cCli )
   LOCAL aPag, aVen, cQry, hRes, nC, oVen, oMvc, oMvd
oApl:dFec := oApl:oEmp:FEC_REM
cFac := "WHERE c.fechoy >= " + xValToChar(dFecI )   +;
         " AND c.fechoy <= " + xValToChar(oApl:dFec)+;
         " AND c.codigo_nit = " + LTRIM(STR(nNit))  +;
         " AND c.estado <> 2"                       +;
         " AND c.facturado = " + xValToChar(cFac)
cQry := "SELECT d.codigo, SUM(d.cantidad), SUM(d.precioven), SUM(d.desmon), "+;
           "SUM(d.montoiva), c.fechacob FROM cadcajac c, cadcajad d " + cFac +;
         " AND d.fechoy = c.fechoy"    +;
         " AND d.remision = c.remision"+;
         " AND d.tipo_p = c.tipo_p GROUP BY d.codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nC := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   RETURN
EndIf
oVen := oApl:Abrir( "cadventa","empresa, numfac, tipo",.t.,,1 )
oMvc := oApl:Abrir( "cgemovc" ,"empresa, ano_mes, control",.t.,,1 )
oMvd := oApl:Abrir( "cgemovd" ,"empresa, ano_mes, control",.t.,,10 )
oApl:cPer := NtChr( oApl:dFec,"1" )
oApl:oFac:Seek( { "empresa",oApl:nEmpresa,"numfac",0,"tipo",oApl:Tipo} )
If !oApl:oFac:lOK
   oApl:oFac:xBlank()
   oApl:oFac:lOK := .t.
   oApl:oFac:EMPRESA   := oApl:nEmpresa
   oApl:oFac:NUMFAC    := SgteNumero( "numfacu",oApl:nEmpresa,.t. )
   oApl:oFac:TIPO      := oApl:Tipo  ; oApl:oFac:FECHOY   := oApl:dFec
   oApl:oFac:CLIENTE   := cCli       ; oApl:oFac:FECHAVEN := oApl:dFec
   oApl:oFac:CODIGO_NIT:= nNit
   oApl:oFac:Append( .t. )
EndIf
aPag := { 0,0,0,0,0,0,0,CTOD(""),{|| .t. } }
While nC > 0
   aVen := MyReadRow( hRes )
   AEVAL( aVen, { | xV,nP | aVen[nP] := MyClReadCol( hRes,nP ) } )
   aPag[8] := If( aPag[8] <= aVen[6], aPag[8], aVen[6] )
   oApl:oFac:TOTALDES +=  aVen[4]
   oApl:oFac:TOTALIVA +=  aVen[5]
   oApl:oFac:TOTALFAC += (aVen[3] + aVen[5])
   oVen:xBlank()
   oVen:EMPRESA   := oApl:nEmpresa; oVen:NUMFAC   := oApl:oFac:NUMFAC
   oVen:TIPO      := oApl:Tipo    ; oVen:FECFAC   := oApl:dFec
   oVen:CODIGO    := aVen[1]      ; oVen:CANTIDAD := aVen[2]
   oVen:PRECIOVEN := aVen[3]      ; oVen:DESMON   := aVen[4]
   oVen:MONTOIVA  := aVen[5]
   If aVen[4] > 0
      oVen:DESPOR := ROUND( aVen[4] / (aVen[3] + aVen[4]) * 100,2 )
   EndIf
//   oVen:PCOSTO := oApl:aInvme[2]
   oVen:Append( .f. )
   oApl:oInv:Seek( {"codigo",aVen[1]} )
   Actualiz( aVen[1],aVen[2],oApl:dFec,2 )
   nC --
EndDo
MSFreeResult( hRes )
If oApl:oFac:lOK
   If nNit == 147
      oApl:oPag:xBlank()                   ; oApl:oPag:EMPRESA  := oApl:nEmpresa
      oApl:oPag:NUMFAC := oApl:oFac:NUMFAC ; oApl:oPag:TIPO     := oApl:Tipo
      oApl:oPag:FECPAG := oApl:oFac:FECHOY ; oApl:oPag:PORDONDE := "F"
      cQry := "SELECT p.abono, p.pagado, p.retencion, p.deduccion, p.descuento, "+;
              "p.numcheque, p.codbanco, p.formapago, p.indred, p.retica, "       +;
              "p.retiva, p.retfte, p.retcre FROM cadcajac c, cadcajap p " + cFac +;
              " AND p.fecpag = c.fechoy AND p.numfac = c.remision"
      hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      nC   := MSNumRows( hRes )
      While nC > 0
         aVen := MyReadRow( hRes )
         AEVAL( aVen, { | xV,nP | aVen[nP] := MyClReadCol( hRes,nP ) } )
         If aVen[8] == 0
            aPag[1] += aVen[01]
            aPag[2] += aVen[02]
            aPag[3] += aVen[03]
            aPag[4] += aVen[04]
            aPag[5] += aVen[05]
         Else
            oApl:oPag:ABONO     := aVen[01]; oApl:oPag:PAGADO    := aVen[02]
            oApl:oPag:RETENCION := aVen[03]; oApl:oPag:DEDUCCION := aVen[04]
            oApl:oPag:DESCUENTO := aVen[05]; oApl:oPag:NUMCHEQUE := aVen[06]
            oApl:oPag:CODBANCO  := aVen[07]; oApl:oPag:FORMAPAGO := aVen[08]
            oApl:oPag:INDRED    := aVen[09]; oApl:oPag:RETICA    := aVen[10]
            oApl:oPag:RETIVA    := aVen[11]; oApl:oPag:RETFTE    := aVen[12]
            oApl:oPag:RETCRE    := aVen[13]
            oApl:oPag:Append( .f. )
         EndIf
         aPag[6] += aVen[02]
         nC --
      EndDo
      MSFreeResult( hRes )
      If aPag[1] > 0
         oApl:oPag:ABONO     := aPag[1]; oApl:oPag:PAGADO    := aPag[2]
         oApl:oPag:RETENCION := aPag[3]; oApl:oPag:DEDUCCION := aPag[4]
         oApl:oPag:DESCUENTO := aPag[5]
         oApl:oPag:NUMCHEQUE := oApl:oPag:CODBANCO := ""
         oApl:oPag:FORMAPAGO := 0
         oApl:oPag:RETICA    := oApl:oPag:RETIVA := 0
         oApl:oPag:RETFTE    := oApl:oPag:RETCRE := 0
         oApl:oPag:Append( .f. )
      EndIf
      aPag[9] := {|| ContaPag( oMvc,oMvd,dFecI ) }
   EndIf
   cQry := "UPDATE cadcajac SET facturado = 'S', numfac = "+;
           LTRIM( STR(oApl:oFac:NUMFAC) ) + " " + STRTRAN( cFac,"c.","" )
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nC   := MSAffectedRows( oApl:oMySql:hConnect )
   MSFreeResult( hRes )
   oApl:nSaldo := oApl:oFac:TOTALFAC
   oApl:lFam   := .f.
   oApl:oFac:ENVIADO_A := LTRIM( STR(nC) ) + ;
                          If( nNit == 147, " REMISIONES DEL DIA", " PEDIDOS" )
   nC := oApl:nSaldo - aPag[6]
   oApl:oFac:FECHACAN  := If( nC == 0, oApl:dFec, CTOD("") )
   oApl:oFac:INDICADOR := If( nC == 0, "C", "P" )
   oApl:oFac:FECHACOB  := aPag[8]
   oApl:oFac:Update( .f.,1 )
   GrabaSal( oApl:oFac:NUMFAC,1,aPag[6] )
   ContaVta( oMvc,oMvd )
EndIf
EVAL( aPag[9] )
oVen:Destroy()
oMvc:Destroy()
oMvd:Destroy()
MsgStop( TRANSFORM(oApl:oFac:TOTALFAC,"$99,999,999"),"Factura"+STR(oApl:oFac:NUMFAC) )
oApl:oEmp:Seek( {"empresa",4} )
RETURN

//------------------------------------//
PROCEDURE CgeVenta()
   LOCAL oDlg, oGet := ARRAY(6), aOpc := { DATE(),DATE(),0,1 }
DEFINE DIALOG oDlg TITLE "ASIENTO DE VENTAS E INGRESOS";
   FROM 0, 0 TO 11,44 OF oApl:oWnd
   @ 02,00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 02,82 GET oGet[1] VAR aOpc[1] OF oDlg  SIZE 40,12 PIXEL
   @ 16,00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 16,82 GET oGet[2] VAR aOpc[2] OF oDlg ;
      VALID aOpc[2] >= aOpc[1] SIZE 40,12 PIXEL
   @ 30,00 SAY "Nro. COMPROBANTE"  OF oDlg RIGHT PIXEL SIZE 80,10
   @ 30,82 GET oGet[3] VAR aOpc[3] OF oDlg PICTURE "999999" SIZE 30,12 PIXEL;
     MESSAGE "Digite 0 si es un Nuevo Comprobante"
   @ 44,00 SAY "CLASE DE ASIENTO"  OF oDlg RIGHT PIXEL SIZE 80,10
   @ 44,82 COMBOBOX oGet[4] VAR aOpc[4] ITEMS { "Ventas","Ingresos" };
      SIZE 48,90 OF oDlg PIXEL
   @ 60, 50 BUTTON oGet[5] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[5]:Disable(), Asientos( aOpc ), oDlg:End() ) PIXEL
   @ 60,100 BUTTON oGet[6] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 66, 02 SAY "[CAOFACTU]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
STATIC PROCEDURE Asientos( aLS )
   LOCAL aCta, aVta, lFac, nK, oMvc, oMvd
oMvc := oApl:Abrir( "cgemovc" ,"empresa, ano_mes, control",.t.,,1 )
oMvd := oApl:Abrir( "cgemovd" ,"empresa, ano_mes, control",.t.,,10 )
oApl:cPer := NtChr( aLS[1],"1" )
If aLS[4] == 1
   lFac := If( aLS[1] < CTOD("01.01.2006"), .t., .f. )
   If lFac
      If oMvc:Seek( {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,"fuente",3,;
                     "comprobant",aLS[3]} )
         oMvd:dbEval( {|o| o:EMPRESA := -9, Acumular( oMvc:ESTADO,o,3,3,.f.,.f. ) },;
                      {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,"control",oMvc:CONTROL} )
         oMvc:CONSECUTIV := 0 ; oMvc:ESTADO := 1
      Else
         oMvc:EMPRESA   := oApl:nEmpresa   ; oMvc:ANO_MES  := oApl:cPer
         oMvc:FECHA     := aLS[2]          ; oMvc:FUENTE   := 3
         oMvc:COMPROBANT:= aLS[3] := SgteCntrl( "compro_prv",oApl:cPer,.t. )
         oMvc:CONCEPTO  := "MOVTO. DE VENTAS EN " + NtChr( aLS[1],"6" )
         oMvc:CODIGONIT := 1
         oMvc:CONTROL   := SgteCntrl( "control",oApl:cPer,.t. )
         Guardar( oMvc,.t.,.t. )
      EndIf
      oApl:oNit:Seek( {"codigo_nit",oApl:oFac:CODIGO_NIT} )
      aCta := { { "41750101","","","","",0,0,0 },{ "24080101","","","","",0,0,0 },;
                { "41201401","","","","",0,0,0 },{ "41201402","","","","",0,0,0 } }
      aVta := { { 0,"",oApl:oNit:CODIGO,oApl:oFac:CODIGO_NIT },;
                { "11050502","","","","",0,0,0 } }
   EndIf
   oApl:oFac:Seek( {"empresa",oApl:nEmpresa,"fechoy >= ",aLS[1],"fechoy <= ",aLS[2],;
                    "tipo",oApl:Tipo,"indicador <> ","A"},;
                   If( lFac, "codigo_nit, numfac", "numfac" ) )
   While !oApl:oFac:Eof()
      If !lFac .OR. Rango( oApl:oFac:CONTROL,{ 0,aLS[3] } )
         oApl:oWnd:SetMsg( "Factura "+STR(oApl:oFac:NUMFAC) )
         If lFac
            If oApl:oFac:CODIGO_NIT == 147
               aVta[2,1] := "11050502"
               nK := 4
            Else
               aVta[2,1] := "13050501"
               nK := 3
            EndIf
            aCta[ 1,6] += oApl:oFac:TOTALDES
            aCta[ 2,7] += oApl:oFac:TOTALIVA
            aCta[nK,7] += (oApl:oFac:TOTALFAC + oApl:oFac:TOTALDES - oApl:oFac:TOTALIVA)
            aVta[ 1,1] := oApl:oFac:NUMFAC
            aVta[ 2,6] := oApl:oFac:TOTALFAC
            Detalle( oMvc,oMvd,aVta[1],aVta[2] )
            oApl:oFac:CONTROL := oMvc:COMPROBANT ; oApl:oFac:Update(.f.,1)
         Else
            ContaVta( oMvc,oMvd )
         EndIf
      EndIf
      oApl:oFac:Skip(1):Read()
      oApl:oFac:xLoad()
      If lFac
         If aVta[1,4]  # oApl:oFac:CODIGO_NIT
            Detalle( oMvc,oMvd,aVta[1],aCta )
            oApl:oNit:Seek( {"codigo_nit",oApl:oFac:CODIGO_NIT} )
            aVta[1,3] := oApl:oNit:CODIGO
            aVta[1,4] := oApl:oFac:CODIGO_NIT
            AEval( aCta, {|x| AFILL( x,0,6 ) } )
         EndIf
      EndIf
   EndDo
   MsgInfo( "Pulse cualquier Tecla para Continuar"+Str(oMvc:COMPROBANT) )
Else
   ContaPag( oMvc,oMvd,aLS[1],aLS[3] )
EndIf
oApl:cPer := NtChr( oApl:dFec,"1" )
oMvc:Destroy()
oMvd:Destroy()
RETURN

//------------------------------------//
PROCEDURE ContaVta( oMvc,oMvd )
   LOCAL aCta, aInf, cSql, nE, nK, hRes
// aCta := Buscar( {"Empresa",oApl:nEmpresa,"Tipo","3"},"cuentas",;
//                  "Cuenta, Cta_cte",9,"Nivel" )
aCta := { { "13050501","","","","",0,0,0 },{ "11050502","","","","",0,0,0 },;
          { "24080101","","","","",0,0,0 },{ "41201401","","","","",0,0,0 },;
          { "41201402","","","","",0,0,0 },{ "41201403","","","","",0,0,0 },;
          { "41201404","","","","",0,0,0 },{ "24950101","","","","",0,0,0 } }
nK   := If( oApl:oFac:CODIGO_NIT == 147, 2, 1 )
nE   := If( oApl:oFac:FECHOY >= CTOD("01.01.2013"), 8, 3 )
aCta[nK,6] := oApl:oFac:TOTALFAC
aCta[nE,7] := oApl:oFac:TOTALIVA
cSql := "SELECT montoiva, precioven FROM cadventa "      +;
        "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))   +;
         " AND numfac  = " + LTRIM(STR(oApl:oFac:NUMFAC))+;
         " AND tipo    = " + xValToChar(oApl:Tipo)
hRes := If( MSQuery( oApl:oMySql:hConnect,cSql ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nE   := MSNumRows( hRes )
While nE > 0
   aInf := MyReadRow( hRes )
   AEVAL( aInf, { | xV,nP | aInf[nP] := MyClReadCol( hRes,nP ) } )
   If aInf[1] == 0
      aCta[nK+5,7] += aInf[2]   //NO Gravadas(6,7)
   Else
      aCta[nK+3,7] += aInf[2]   //   Gravadas(4,5)
   EndIf
   nE --
EndDo
MSFreeResult( hRes )
oApl:oNit:Seek( {"codigo_nit",oApl:oFac:CODIGO_NIT} )
If oMvc:Seek( {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,;
               "fuente",3,"control",oApl:oFac:CONTROL} )
   oMvd:dbEval( {|o| o:EMPRESA := -9, Acumular( oMvc:ESTADO,o,3,3,.f.,.f. ) },;
                {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,"control",oMvc:CONTROL} )
   oMvc:CONSECUTIV := 0 ; oMvc:ESTADO := 1
   oMvc:CODIGONIT  := oApl:oFac:CODIGO_NIT
Else
   oMvc:EMPRESA   := oApl:nEmpresa   ; oMvc:ANO_MES  := oApl:cPer
   oMvc:FECHA     := oApl:oFac:FECHOY; oMvc:FUENTE   := 3
   oMvc:COMPROBANT:= oApl:oFac:NUMFAC; oMvc:CONCEPTO := oApl:oFac:CLIENTE
   oMvc:CODIGONIT := oApl:oFac:CODIGO_NIT
   oMvc:CONTROL   := SgteCntrl( "control",oApl:cPer,.t. )
   oMvc:ESTADO    := 1
   Guardar( oMvc,.t.,.t. )
   cSql := "UPDATE cadfactu SET control = " + LTRIM(STR(oMvc:CONTROL)) +;
           " WHERE row_id = " + LTRIM(STR(oApl:oFac:ROW_ID))
   MSQuery( oApl:oMySql:hConnect,cSql )
EndIf

Detalle( oMvc,oMvd,{oApl:oFac:NUMFAC,"",oApl:oNit:CODIGO,oApl:oFac:CODIGO_NIT},aCta )
RETURN

//------------------------------------//
PROCEDURE ContaPag( oMvc,oMvd,dFecI,nK )
   LOCAL aCta, aInf, cSql, nE, hRes
   LOCAL aVta := { 0,0,0,0,0,0,0 }, aTJ := {}
cSql := "SELECT p.formapago, p.codbanco, p.numcheque, p.numfac, "        +;
        "p.abono, p.pagado, p.retencion, p.deduccion, p.descuento, "     +;
        "p.retica, p.retiva, p.retfte, p.retcre, n.codigo, n.codigo_nit "+;
        "FROM cadpagos p, cadfactu u, cadclien n "      +;
        "WHERE p.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND p.fecpag = "  + xValToChar( dFecI )      +;
         " AND p.tipo = "    + xValToChar(oApl:Tipo)    +;
         " AND u.empresa = p.empresa"+;
         " AND u.numfac  = p.numfac" +;
         " AND u.tipo = p.tipo AND n.codigo_nit = u.codigo_nit ORDER BY p.numfac"
hRes := If( MSQuery( oApl:oMySql:hConnect,cSql ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nE := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   RETURN
EndIf
If nK == NIL .OR. nK == 0
   nK := SgteNumero( "ingreso",oApl:nEmpresa )
EndIf
aCta := Buscar( {"empresa",oApl:nEmpresa,"tipo","1"},"cuentas",;
                 "cuenta, cta_cte",9,"nivel" )
oApl:cPer := NtChr( dFecI,"1" )
oApl:oNit:Seek( {"codigo_nit",147} )
If oMvc:Seek( {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,"fuente",1,;
               "comprobant",nK} )
   oMvd:dbEval( {|o| o:EMPRESA := -9, Acumular( oMvc:ESTADO,o,3,3,.f.,.f. ) },;
                {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,"control",oMvc:CONTROL} )
   oMvc:CONSECUTIV := 0 ; oMvc:ESTADO := 1
   oMvc:CODIGONIT  := oApl:oFac:CODIGO_NIT
Else
   oMvc:EMPRESA   := oApl:nEmpresa ; oMvc:ANO_MES  := oApl:cPer
   oMvc:FECHA     := dFecI         ; oMvc:FUENTE   := 1
   oMvc:COMPROBANT:= nK
   oMvc:CONCEPTO  := "INGRESOS DEL " + NtChr( dFecI,"2" )
   oMvc:CODIGONIT := oApl:oNit:CODIGO_NIT
   oMvc:CONTROL   := SgteCntrl( "control",oApl:cPer,.t. )
   oMvc:ESTADO    := 1
   Guardar( oMvc,.t.,.t. )
EndIf

While nE > 0
   aInf := MyReadRow( hRes )
   AEVAL( aInf, { | xV,nP | aInf[nP] := MyClReadCol( hRes,nP ) } )
   nK   := If( aInf[1] == 0, 1,;
           If( aInf[2] == "D ", 5,;
           If( aInf[2] == "AV" .AND. TRIM(aInf[3]) == "111", 4,;
           If( aInf[1] == 1 .OR. aInf[2] == "CB", 2, 3 ))))
   aInf[14]:= INT(aInf[14])
   aVta[nK]+= aInf[5]      //Abono
   aVta[06]:= aInf[4]      //Numfac
   aVta[07]:= aInf[3]      //Numcheque
   nK      := If( aInf[15] == 147, 1, 2 ) //Mostrador 11050502, Cartera 13050501
   Detalle( oMvc,oMvd,{aInf[4],aInf[3],aInf[14],aInf[15]},;
            { { aCta[nK,1],"","","","",0,aInf[06],0 },;
              { aCta[03,1],"","","","",aInf[07],0,0 },;
              { aCta[04,1],"","","","",aInf[08],0,0 },;
              { aCta[05,1],"","","","",aInf[09],0,0 },;
              { aCta[11,1],"","","","",aInf[10],0,0 },;
              { aCta[12,1],"","","","",aInf[11],0,0 },;
              { aCta[13,1],"","","","",aInf[12],0,0 },;
              { aCta[14,1],"","","","",aInf[13],0,0 } } )
   If aInf[1] == 3 .OR. aInf[2] == "CB"
      nK := If( aInf[2] == "CB", 2, If( aInf[2] == "D ", 5, 3 ) )
      AADD( aTJ, { nK+5, aInf[5], aInf[3] } )
      aVta[nK]-= aInf[5]
   EndIf
   nE --
EndDo
MSFreeResult( hRes )
aInf := { { aCta[06,1],"","","",aCta[06,2],aVta[1],0,0 },;
          { aCta[07,1],"","","",aCta[07,2],aVta[2],0,0 },;
          { aCta[08,1],"","","",aCta[08,2],aVta[3],0,0 },;
          { aCta[08,1],"","","",aCta[08,2],aVta[4],0,0 },;
          { aCta[10,1],"","","",aCta[10,2],aVta[5],0,0 } }
FOR nK := 1 TO LEN( aTJ )
   nE := aTJ[nK,1]
   AADD( aInf, { aCta[nE,1],"","",aTJ[nK,3],aCta[nE,2],aTJ[nK,2],0,0 } )
NEXT nK
Detalle( oMvc,oMvd,{aVta[6],aVta[7],oApl:oNit:CODIGO,147},aInf )
 MsgStop( "Pulse cualquier Tecla para Continuar"+STR(oMvc:COMPROBANT) )
RETURN

//------------------------------------//
PROCEDURE Detalle( oMvc,oMvd,aDet,aCta )
   LOCAL aInf, cSql, cCta, nE, nK
FOR nE := 1 TO LEN( aCta )
   If aCta[nE,6] > 0 .OR. aCta[nE,7] > 0
      aInf := Buscar( { "empresa",oApl:nPuc,"cuenta",aCta[nE,1] },"cgeplan",;
                        "infa, infb, infc, infd",8 )
      cCta := aCta[nE,5]
      aDet[2] := If( aCta[nE,4] == "", aDet[2], aCta[nE,4] )
      aCta[nE,4] := aCta[nE,5] := ""
      FOR nK := 1 TO 4
         cSql := TRIM( aInf[nK] )
         do case
         Case cSql == "CHEQUE"
            aCta[nE,nK+1] := aDet[2]
         Case cSql == "COD-VAR"
            aCta[nE,nK+1] := aCta[nE,1]
         Case cSql == "CTA-CTE"
            aCta[nE,nK+1] := cCta
         Case cSql == "DOCUMENTO"
            aCta[nE,nK+1] := LTRIM(STR(oMvc:COMPROBANT))
         Case cSql == "FACTURA"
            aCta[nE,nK+1] := LTRIM(STR(aDet[1]))
         Case cSql == "FECHA"
            aCta[nE,nK+1] := DTOC(oMvc:FECHA)
         Case cSql == "NIT"
            aCta[nE,nK+1] := LTRIM(STR(aDet[3]))
            aCta[nE,8]    := aDet[4]
         EndCase
      NEXT nK
      oMvc:CONSECUTIV ++
      oMvd:Seek( "empresa = -9 LIMIT 1","CM" )
      oMvd:EMPRESA   := oApl:nEmpresa; oMvd:ANO_MES  := oApl:cPer
      oMvd:CONTROL   := oMvc:CONTROL ; oMvd:CUENTA   := aCta[nE,1]
      oMvd:INFA      := aCta[nE,2]   ; oMvd:INFB     := aCta[nE,3]
      oMvd:INFC      := aCta[nE,4]   ; oMvd:INFD     := aCta[nE,5]
      oMvd:VALOR_DEB := aCta[nE,6]   ; oMvd:VALOR_CRE:= aCta[nE,7]
      oMvd:CODIGO_NIT:= aCta[nE,8]
      Acumular( oMvc:ESTADO,oMvd,2,2,!oMvd:lOK,.f. )
   EndIf
NEXT nE
oMvc:Update(.f.,1)
RETURN