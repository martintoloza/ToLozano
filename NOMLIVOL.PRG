// Programa.: NOMLIVOL.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo volantes de Pago.
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

PROCEDURE NomLiVol()
   LOCAL aCos, aOpc, oDlg, oEp, oGet := ARRAY(9)
 Empresa( .t.,1 )
 oEp := TEpl() ; oEp:New()
aCos := CCosto()
aOpc := { 1,9,oApl:oFie:FECHA_HAS,.f.,"","",1,.t. }
aOpc[2] := Buscar( "SELECT MAX(codigo) FROM nomemple WHERE empresa = "+;
                  LTRIM(STR(oApl:nEmpresa)),"CM",,8 )
DEFINE DIALOG oDlg TITLE "Listar Volantes de Pago" FROM 0, 0 TO 09,60
   @ 02, 00 SAY "EN Mision" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 02, 72 COMBOBOX oGet[1] VAR aOpc[7] ITEMS ArrayCol( aCos,1 );
     SIZE 150,99 OF oDlg PIXEL
   @ 14, 00 SAY "EMPLEADO INICIAL" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 14, 72 BTNGET oGet[2] VAR aOpc[1] OF oDlg PICTURE "99999"  ;
      VALID( If( oEp:oDb:Seek( {"empresa",oApl:nEmpresa        ,;
                                "codigo",aOpc[1]} )            ,;
               (aOpc[5] := oEp:oDb:NOMBRE, oDlg:Update(), .t. ),;
               ( MsgStop("Este Empleado no Existe .."),.f.))  ) ;
      SIZE 40,10 PIXEL   RESOURCE "BUSCAR"                      ;
      ACTION EVAL({|| If(oEp:Mostrar(), (aOpc[1] := oEp:oDb:CODIGO,;
                        oGet[2]:Refresh(), oGet[2]:lValid(.f.)),)})
   @ 14,118 SAY oGet[6] VAR aOpc[5] OF oDlg PIXEL SIZE 86,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 26, 00 SAY "EMPLEADO   FINAL" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 26, 72 BTNGET oGet[3] VAR aOpc[2] OF oDlg PICTURE "99999"  ;
      VALID( If( oEp:oDb:Seek( {"empresa",oApl:nEmpresa        ,;
                                "codigo",aOpc[2]} )            ,;
               (aOpc[6] := oEp:oDb:NOMBRE, oDlg:Update(), .t. ),;
               ( MsgStop("Este Empleado no Existe .."),.f.))  ) ;
      SIZE 40,12 PIXEL   RESOURCE "BUSCAR"                      ;
      ACTION EVAL({|| If(oEp:Mostrar(), (aOpc[2] := oEp:oDb:CODIGO,;
                        oGet[3]:Refresh(), oGet[3]:lValid(.f.)),)})
   @ 26,118 SAY oGet[7] VAR aOpc[6] OF oDlg PIXEL SIZE 86,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 38, 00 SAY "FECHA [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 38, 72 GET oGet[4] VAR aOpc[3] OF oDlg SIZE 40,10 PIXEL
   @ 38,140 CHECKBOX oGet[5] VAR aOpc[4] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,12 PIXEL
//   @ 50,144 CHECKBOX oGet[6] VAR aOpc[8] PROMPT "REGISTRADO" OF oDlg ;
//      SIZE 60,10 PIXEL
   @ 52, 60 BUTTON oGet[8] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[8]:Disable(), ListoVol( aOpc,aCos ), oDlg:End() ) PIXEL
   @ 52,110 BUTTON oGet[9] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 58, 02 SAY "[NOMLIAUX]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
PROCEDURE ListoVol( aLS,aCos )
   LOCAL oRpt, aPG := { 0,0,0 }
   LOCAL aRes, cQry, hRes, nK, nL
cQry := "SELECT e.codigo, n.codigo, n.nombre, e.sueldoact, "  +;
                "d.concepto, c.nombre, d.clasepd, d.horas, "  +;
                "d.valornoved, e.cencos "                     +;
        "FROM nomnoved d, nomconce c, nomemple e, cadclien n "+;
        "WHERE d.empresa = "  + LTRIM(STR(oApl:nEmpresa))     +;
         " AND d.codigo >= "  + LTRIM(STR( aLS[1] ))          +;
         " AND d.codigo <= "  + LTRIM(STR( aLS[2] ))          +;
         " AND d.fechahas = " + xValToChar( aLS[3] )          +;
         " AND d.concepto = c.concepto"                       +;
         " AND d.empresa = e.empresa AND d.codigo = e.codigo" +;
         " AND e.codigo_nit = n.codigo_nit" + If( aLS[7] == 1, "",;
         " AND e.cencos = '" + aCos[aLS[7],2] + "'" )         +;
         " ORDER BY e.codigo, d.clasepd, d.concepto"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MSFreeResult( hRes ) ; RETURN
EndIf
cQry := Buscar( {"empresa",oApl:nEmpresa,"fechahas",aLS[3]},;
                "nomfecha","fechades",8 )
cQry := If( EMPTY(cQry), oApl:oFie:FECHA_DES, cQry )
oRpt:= TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"VOLANTE DE PAGO DE NOMINA",;
         NtChr( cQry,"3" ) + " hasta " + NtChr( aLS[3],"3" ) },aLS[4],,,33,33 )
oRpt:lTimbrado := .t.
//cPer := NtChr( aLS[3],"1" ) + If( DAY(aLS[3]) >= 16, "2", "1" )
aRes := MyReadRow( hRes )
AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
While nL > 0
   If aPG[1]  # aRes[1]
      aPG[1] := aRes[1]
      //nK := ArrayValor( aCos,aRes[10],,.t. )
      oRpt:Titulo( 79 )
      //oRpt:Say( 06,01,oRpt:CPIBOLD + "CODIGO :" + STR(aPG[1],5) )
      //oRpt:Say( 06,01,oRpt:CPIBOLD + aCos[nK,1] )
      oRpt:Say( 07,01,TRANSFORM(aRes[2],"9,999,999,999") + " " +aRes[3] )
      oRpt:Say( 07,50,oRpt:CPIBOLD + "SUELDO :" +TRANSFORM(aRes[4],"999,999,999") )
      oRpt:Say( 09,01,oRpt:CPIBOLD + "CODIGO  DESCRIPCION      HORAS/DIAS  DEVENGADOS    DEDUCIONES         SALDO" )
      oRpt:nL := 11
   EndIf
   If aRes[7] == 1
      nK := 37
      aPG[2] += aRes[9]
   Else
      nK := 51
      aPG[3] += aRes[9]
   EndIf
   oRpt:Say( oRpt:nL,04,aRes[5] )
   oRpt:Say( oRpt:nL,09,aRes[6] )
   oRpt:Say( oRpt:nL,32,TRANSFORM(aRes[8]     ,"@Z 999.9") )
   oRpt:Say( oRpt:nL,nK,TRANSFORM(aRes[9],"999,999,999") )
/*
cQry := "SELECT d.Saldoact FROM nomdesfi d "            +;
        "WHERE d.Empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND d.Codigo  = " + LTRIM(STR( ::aM[3] ))    +;
         " AND d.Concepto = "+ LTRIM(STR( nCon ))       +;
         " AND d.Anomes = (SELECT MAX(m.Anomes) FROM nomdesfi m "+;
                          "WHERE m.Empresa  = d.Empresa"         +;
                           " AND m.Codigo   = d.Codigo"          +;
                           " AND m.Concepto = d.Concepto"        +;
                           " AND m.Anomes <= '" + cPer + "')"
   If Tra->(dbSeek( STR(Nov->EMPRESA)+STR(Nov->CONCEPTO) ))
      Def->(dbSeek( STR(Nov->EMPRESA)+STR(Nov->CODIGO)+STR(Tra->CONCEPTO) ))
      If Nov->CONCEPTO # 30
         nK := Def->SALDOACT + Def->VALORCARGO - Nov->VALORNOVED
         oRpt:Say( oRpt:nL,66,TransForm(nK,"999,999,999") )
      EndIf
   EndIf
*/
   oRpt:nL++
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEval( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aPG[1] # aRes[1]
      nK := aPG[2] - aPG[3]
      oRpt:Say(++oRpt:nL,09,oRpt:CPIBOLD + "Totales Novedades ====>" )
      oRpt:Say(  oRpt:nL,39,TRANSFORM(aPG[2],"999,999,999") )
      oRpt:Say(  oRpt:nL,53,TRANSFORM(aPG[3],"999,999,999") )
      oRpt:Say(++oRpt:nL,09,oRpt:CPIBOLD + "Total Pagado      ====>" )
      oRpt:Say(  oRpt:nL,39,TRANSFORM(nK,"999,999,999") )
      oRpt:NewPage()
      oRpt:nL := oRpt:nLength + 1
      //oRpt:Say(        29,09,"-----------------------" )
      //oRpt:Say(        30,09,"      RECIBI           " )
      AFILL( aPG,0 )
   EndIf
EndDo
MSFreeResult( hRes )
oRpt:End()
RETURN
