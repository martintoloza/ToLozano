// Programa.: CGEINFLA.PRG    >>> Martin A. Toloza L. <<<
// Notas....: Ajustes por Inflacion y Depreciacion.
#include "Fivewin.ch"

MEMVAR oApl

PROCEDURE CgeInfla( nOpc )
   LOCAL oAj, oDlg, oGet := ARRAY(6)
   LOCAL aRep, aOpc := { NtChr( DATE(),"1" ),0,5,"" }
   DEFAULT nOpc := 1
oAj := TAjustes() ; oAj:New()
nOpc := If( VALTYPE( nOpc ) == "L", 2, nOpc )
aOpc[3] := { 5,1,99 }[nOpc]
aRep := { { {|| oAj:Inflacion( aOpc,oDlg ) },"AJUSTE POR INFLACION" }   ,;
          { {|| oAj:Depreciar( aOpc,oDlg ) },"AJUSTE POR DEPRECIACION" },;
          { {|| oAj:RetenDian( aOpc,oDlg ) },"CIERRE DE CUENTAS" } }
DEFINE DIALOG oDlg TITLE aRep[nOpc,2] FROM 0, 0 TO 09,42
   @ 02, 00 SAY "PERIODO [AAAAMM]"  OF oDlg RIGHT PIXEL SIZE 80,10
   @ 02, 82 GET oGet[1] VAR aOpc[1] OF oDlg PICTURE "999999" SIZE 34,12 PIXEL;
      VALID If( !NtChr( aOpc[1],"P" ), .f.                                  ,;
              (oAj:oCtl:Seek( {"empresa",oApl:nEmpresa,"ano_mes",aOpc[1]} ), .t. ) )
   @ 16, 00 SAY       "PORCENTAJE"  OF oDlg RIGHT PIXEL SIZE 80,10
   @ 16, 82 GET oGet[2] VAR aOpc[2] OF oDlg PICTURE "###.##" SIZE 34,12 PIXEL;
      WHEN nOpc == 1
   @ 30, 00 SAY "Nro. COMPROBANTE"  OF oDlg RIGHT PIXEL SIZE 80,10
   @ 30, 82 GET oGet[3] VAR aOpc[3] OF oDlg PICTURE "######" SIZE 34,12 PIXEL
   @ 30,120 SAY oGet[4] VAR aOpc[4] OF oDlg PIXEL SIZE 70,10 ;
      UPDATE COLOR nRGB( 160,19,132 )
   @ 46, 50 BUTTON oGet[5] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[5]:Disable(), EVAL( aRep[nOpc,1] ), oDlg:End() ) PIXEL
   @ 46,100 BUTTON oGet[6] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 52, 02 SAY "[CGEINFLA]" OF oDlg PIXEL SIZE 34,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED

oAj:oCtl:Destroy()
oAj:oMvc:Destroy()
oAj:oMvd:Destroy()
oAj:oPuc:Destroy()
RETURN

//------------------------------------//
CLASS TAjustes

 DATA aCab  AS ARRAY INIT { "",9,0,.f. }
 DATA nNit, oCtl, oMvc, oMvd, oPuc

 METHOD NEW() Constructor
 METHOD Inflacion( aLS,oDlg )
 METHOD Depreciar( aLS,oDlg )
 METHOD RetenDian( aLS,oDlg )
 METHOD BuscaMov( nCtl,aLS,oDlg,nFte )
 METHOD Asiento( aMov,nSaldo )

ENDCLASS

//------------------------------------//
METHOD New() CLASS TAjustes

 ::oCtl := oApl:Abrir( "cgecntrl","empresa, ano_mes",.f.,,5 )
 ::oMvc := oApl:Abrir( "cgemovc" ,"empresa, ano_mes, control",.f.,,5 )
 ::oMvd := oApl:Abrir( "cgemovd" ,"empresa, ano_mes, control",.t.,,1000 )
 ::oPuc := oApl:Abrir( "cgeplan" ,"empresa, cuenta",.f.,,5 )
 ::oPuc:xBlank()
 oApl:oNit:Seek( {"codigo",1} )
 ::nNit := oApl:oNit:CODIGO_NIT
RETURN NIL

//------------------------------------//
METHOD Inflacion( aLS,oDlg ) CLASS TAjustes
   LOCAL aCta, aSal, cPerI, cPerF, lDeb, nL, nSaldo
If ::BuscaMov( ::oCtl:CONTROL_IN,aLS,oDlg,9 ) == 0
   RETURN NIL
EndIf
cPerI := STR( VAL( LEFT(aLS[1],4) )-1,4 ) + "13"
cPerF := NtChr( NtChr( aLS[1],"F" )-1,"1" )
cPerF := If( cPerF < cPerI, cPerI, cPerF )
aCta  := Buscar( {"empresa",oApl:nPUC,"fuente",9},"cgeajust","cuenta, cuenta_db, cuenta_cr",9 )
FOR nL := 1 TO LEN( aCta )
   aLS[4] := aCta[nL,1]  //Cuenta
   oDlg:Update()
   aSal := SaldoCta( { aLS[4] },cPerF,cPerI )
   nSaldo := aSal[1] - aSal[2]
   nSaldo *= If( nSaldo < 0, -1, 1 )
   nSaldo := ROUND( nSaldo * aLS[2] / 100, 2 )
   If nSaldo # 0
      lDeb   := If( nSaldo > 0, .t., .f. )
      nSaldo *= If( nSaldo < 0, -1, 1 )
      ::Asiento( { aCta[nL,2], lDeb,aCta[nL,2],1 },nSaldo )
      ::Asiento( { aCta[nL,3],!lDeb,aCta[nL,3],1 },nSaldo )
   EndIf
NEXT
If ::oMvc:CONTROL > 0
   ::oCtl:CONTROL_IN := ::oMvc:CONTROL ; ::oCtl:Update( .t.,1 )
EndIf
RETURN NIL

//------------------------------------//
METHOD Depreciar( aLS,oDlg ) CLASS TAjustes
   LOCAL aCta, aSal, cPerI, cPerF, nL, nSaldo
If ::BuscaMov( ::oCtl:CONTROL_DE,aLS,oDlg,10 ) == 0
   RETURN NIL
EndIf
cPerI := STR( VAL( LEFT(aLS[1],4) )-1,4 ) + "13"
cPerF := NtChr( NtChr( aLS[1],"F" )-1,"1" )
cPerF := If( cPerF < cPerI, cPerI, cPerF )
aCta  := Buscar( {"empresa",oApl:nPUC,"fuente",10},"cgeajust",;
                 "cuenta, cuenta_db, cuenta_cr, porcentaje/12, codigo",9 )
FOR nL := 1 TO LEN( aCta )
   aLS[4] := aCta[nL,1]  //Cuenta
   oDlg:Update()
   aSal := SaldoCta( { aLS[4] },cPerF,cPerI )
   nSaldo := aSal[1] - aSal[2]
   nSaldo *= If( nSaldo < 0, -1, 1 )
   nSaldo := ROUND( nSaldo * aCta[nL,4] / 100, 2 )
   If nSaldo > 0
      ::Asiento( { aCta[nL,2],.t.,aCta[nL,2],0 },nSaldo )
      ::Asiento( { aCta[nL,3],.f.,aCta[nL,5],0 },nSaldo )
   EndIf
NEXT
If ::oMvc:CONTROL > 0
   ::oCtl:CONTROL_DE := ::oMvc:CONTROL ; ::oCtl:Update( .t.,1 )
EndIf
RETURN NIL

//------------------------------------//
METHOD RetenDian( aLS,oDlg ) CLASS TAjustes
   LOCAL aCta, aMV, cQry, cPerI, cPerF, nL, hRes
   LOCAL nC := VAL( LEFT(aLS[1],4) )
aLS[1] := STR( nC,4 ) + "13"
If ::BuscaMov( 1,aLS,oDlg,11 ) == 0
   RETURN NIL
EndIf
cPerI := STR( nC-1,4 ) + "13"
cPerF := STR( nC  ,4 ) + "12"
aCta  := Buscar( "SELECT cuenta_db, cuenta_cr, codigo FROM cgeajust "+;
                 "WHERE empresa = " + LTRIM(STR(oApl:nPUC))          +;
                  " AND fuente  = 11","CM","*",9 )
FOR nC := 1 TO LEN( aCta )
   aLS[4] := aCta[nC,1] ; oDlg:Update()
   aMV  := { .t.,0,0,0 }
   cQry := "SELECT codigo, codigo_nit, SUM(valor_deb), SUM(valor_cre) "+;
           "FROM cgeacumn "   +;
           "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND cuenta = "  + xValToChar( aLS[4] )     +;
            " AND ano_mes >= "+ xValToChar( cPerI )      +;
            " AND ano_mes <= "+ xValToChar( cPerF )      +;
           " GROUP BY codigo, codigo_nit"
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
//   MsgInfo( cQry,STR(nL) )
   While nL > 0
      cQry := MyReadRow( hRes )
      AEVAL( cQry, { |xV,nP| cQry[nP] := MyClReadCol( hRes,nP ) } )
      aMV[2] := cQry[3] - cQry[4]
      If aMV[2] # 0
         If aMV[2] > 0
            aMV[1] := .f.
            aMV[3] += aMV[2]
         Else
            aMV[1] := .t.
            aMV[2] *= -1
            aMV[4] += aMV[2]
         EndIf
         ::Asiento( { aLS[4],aMV[1],cQry[1],cQry[2] },aMV[2] )
      EndIf
      nL --
   EndDo
   MSFreeResult( hRes )
   oApl:oNit:Seek( {"codigo",aCta[nC,3]} )
   If aMV[3] # 0
      ::Asiento( { aCta[nC,2],.t.,"",oApl:oNit:CODIGO_NIT },aMV[3] )
   EndIf
   If aMV[4] # 0
      ::Asiento( { aCta[nC,2],.f.,"",oApl:oNit:CODIGO_NIT },aMV[4] )
   EndIf
NEXT nC
RETURN NIL

//------------------------------------//
METHOD BuscaMov( nCtl,aLS,oDlg,nFte ) CLASS TAjustes
   LOCAL cQry, nSi := 1
If ::oCtl:CIERRE
   MsgStop( "YA ESTA CERRADO",If( RIGHT( aLS[1],2 ) == "13",;
            "AÑO " + LEFT(aLS[1],4), "Periodo " + aLS[1] ) )
   RETURN 0
EndIf

oDlg:SetText( ::oCtl:ANO_MES + If( ::oCtl:lOK, " Si", " No" ) + STR(nCtl) )
If nFte == 11
   cQry := {"empresa",oApl:nEmpresa,"ano_mes",aLS[1],"fuente",11,"comprobant",aLS[3]}
Else
   cQry := {"empresa",oApl:nEmpresa,"ano_mes",aLS[1],"control",nCtl}
EndIf
::aCab := { aLS[1],nFte,aLS[3],.t. }
If ::oMvc:Seek( cQry )
   aLS[4] := "BORRANDO" ; oDlg:Update()
   oDlg:SetText( "<< ESPERE >> BORRANDO ASIENTO" )
   ::oMvd:dbEval( {|o| o:EMPRESA := -9, Acumular( ::oMvc:ESTADO,o,3,3,.f.,.f. ) },;
                  {"empresa",oApl:nEmpresa,"ano_mes",aLS[1],"control",::oMvc:CONTROL} )
/*
   cQry := "UPDATE cgemovd SET empresa = 99 "            +;
           "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND ano_mes = " + xValToChar( aLS[1] )     +;
            " AND control = " + LTRIM( STR(::oMvc:CONTROL) )
   MSQuery( oApl:oMySql:hConnect,cQry )
*/
   ::oMvc:CONSECUTIV := 0
   ::oMvc:Update( .t.,1 )
   nSi := 2
Else
   ::aCab[4] := .f.
   ::oMvc:FECHA    := CTOD( NtChr( NtChr( aLS[1],"F" ),"4" ) )
EndIf
   ::oMvc:ESTADO   := 1
   ::oMvc:CONCEPTO := { "AJUSTE POR INFLACION "+TRANSFORM(aLS[2],"999.99%"),;
                        "APROPIACION PARA DEPRECIACIONES" ,;
                        "MOVIMIENTO DE CIERRE DEL EJERCICIO" }[nFte-8]
oDlg:SetText( "<< ESPERE >> GENERANDO ASIENTO" )
RETURN nSi

//------------------------------------//
METHOD Asiento( aMov,nSaldo ) CLASS TAjustes
   LOCAL aR := { "","","","",0,0,0 }, cQry, nP
If TRIM(aMov[1]) # TRIM(::oPuc:CUENTA)
   If !::oPuc:Seek( {"empresa",oApl:nPuc,"cuenta",aMov[1]} )
      MsgInfo( "Cuenta no EXISTE",aMov[1] )
   EndIf
EndIf
If EMPTY( aMov[3] )
   If InfAc( ::oPuc,@nP,"NIT" )
      aR[05] := If( aMov[4] == 0, ::nNit, aMov[4] )
      If oApl:oNit:CODIGO_NIT # aR[05]
         oApl:oNit:Seek( {"codigo_nit",aR[05]} )
      EndIf
      aR[nP] := LTRIM(STR( oApl:oNit:CODIGO ))
   EndIf
ElseIf InfAc( ::oPuc,@nP )
      aR[nP] := aMov[3]
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
   ::oMvc:Append( .t. )
EndIf
If aMov[2]
   aR[6] := nSaldo
Else
   aR[7] := nSaldo
EndIf
 ::oMvd:Seek( "empresa = -9 LIMIT 1","CM" )
 ::oMvd:EMPRESA   := oApl:nEmpresa  ; ::oMvd:ANO_MES  := ::aCab[1]
 ::oMvd:CONTROL   := ::oMvc:CONTROL ; ::oMvd:CUENTA   := aMov[1]
 ::oMvd:INFA      := aR[1]          ; ::oMvd:INFB     := aR[2]
 ::oMvd:INFC      := aR[3]          ; ::oMvd:INFD     := aR[4]
 ::oMvd:CODIGO_NIT:= aR[5]
 ::oMvd:VALOR_DEB := aR[6]          ; ::oMvd:VALOR_CRE:= aR[7]
 Acumular( ::oMvc:ESTADO,::oMvd,2,2,!::oMvd:lOK,.f. )
 ::oMvc:CONSECUTIV ++
 ::oMvc:Update( .t.,1 )
RETURN NIL