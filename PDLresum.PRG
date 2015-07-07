// Programa.: CAORESUM.PRG     >>> Martin A. Toloza Lozano <<<
// Notas....: Resumen o Descuadre de la Cartera.
#include "FiveWin.ch"

MEMVAR oApl

PROCEDURE CaoResum()
   LOCAL oDlg, oGet := ARRAY(6), aVta := { oApl:cPer,"R",.f.,.f. }
DEFINE DIALOG oDlg TITLE "Resumen de la Cartera" FROM 1, 2 TO 10,44
   @ 02,00 SAY "DIGITE EL PERIODO"   OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02,92 GET oGet[1] VAR aVta[1] OF oDlg PICTURE "999999" SIZE 36,12 PIXEL;
      VALID NtChr( aVta[1],"P" )
   @ 16,00 SAY "RESUMEN O DESCUADRE" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 16,92 GET oGet[2] VAR aVta[2] OF oDlg PICTURE "!"  SIZE 08,12 PIXEL;
      VALID aVta[2] $ "RD"
   @ 30,20 CHECKBOX oGet[3] VAR aVta[3] PROMPT "Ajusto Saldos" OF oDlg ;
      WHEN aVta[2] == "D"  SIZE 60,12 PIXEL
   @ 30, 92 CHECKBOX oGet[4] VAR aVta[4] PROMPT "Vista &Previa" OF oDlg;
     SIZE 60,12 PIXEL
   @ 46, 60 BUTTON oGet[5] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[5]:Disable(), ListoRes( aVta ), oDlg:End() ) PIXEL
   @ 46,110 BUTTON oGet[6] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 52, 02 SAY "[CAORESUM]" OF oDlg PIXEL SIZE 30,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
STATIC PROCEDURE ListoRes( aVt )
   LOCAL nAnul, nK, cPict := "999,999,999", lSal := aVt[3]
   LOCAL oDPrn := TDosPrint()
ASIZE( aVt,13 )
aVt[6] := aVt[4]
aVt[3] := NtChr( aVt[1],"F" )
aVt[4] := CTOD( NtChr( aVt[3],"4" ) )
aVt[5] := NtChr( aVt[3]-1,"1" )         // Anomes Anterior
oDPrn:New( oApl:cPuerto,oApl:cImpres,{"RESUMEN DE LA CARTERA",;
           "Movimiento a " + NtChr( aVt[4],"3" ) },aVt[6] )
AFILL( aVt,0,6 )
If aVt[2] == "D"
   oDPrn:aEnc[2] := "Descuadre a " + NtChr( aVt[4],"3" )
   oDPrn:Titulo( 80 )
EndIf
oApl:oFac:Seek( { "Empresa",oApl:nEmpresa,"Fechoy <= ",aVt[4],"Tipo",oApl:Tipo } )
While !oApl:oFac:Eof()
   nAnul := 1
   If oApl:oFac:INDICADOR == "A"
      nAnul := If( aVt[5] < LEFT( DTOS( oApl:oFac:FECHAENT ),6 ), 2, 0 )
   EndIf
   If nAnul > 0
      If oApl:oFac:FECHOY >= aVt[3] .AND. ;
         oApl:oFac:FECHOY <= aVt[4] .AND. nAnul == 1
         aVt[08] += oApl:oFac:TOTALFAC
      Else
         oApl:cPer   := aVt[5]
         oApl:nSaldo := SaldoFac( oApl:oFac:NUMFAC,1 )
         aVt[06] += oApl:nSaldo
      EndIf
      If nAnul == 1
         oApl:cPer := aVt[1]
         oApl:lFam := SaldoFac( oApl:oFac:NUMFAC )
         aVt[07] += oApl:nSaldo
         If aVt[2] == "D"
            aVt[6] := If( aVt[08] > 0, aVt[08], aVt[06] )
            Abonos( @aVt,oApl:oFac:NUMFAC )
            aVt[8] := aVt[06] - aVt[09] + aVt[10]
            If ABS( aVt[07] ) # ABS( aVt[08] )
               oDPrn:Say( oDPrn:nL++,01," Fac" + STR(oApl:oFac:NUMFAC) + " Ant"     +;
                          NtChr(aVt[06],cPict) + " Act" + NtChr(aVt[07],cPict) +;
                          " Mov" + NtChr( aVt[08],cPict ) + oApl:oFac:INDICADOR,,,1 )
               aVt[9] -= If( oApl:lFam, oApl:oFam:ABONOS, 0 )
               If lSal .AND. aVt[09] > 0
                  GrabaSal( oApl:oFac:NUMFAC,1,aVt[09] )
                  oApl:nSaldo := SaldoFac( oApl:oFac:NUMFAC,1 )
               EndIf
            EndIf
            AFILL( aVt,0,6,3 )
         EndIf
         If oApl:nSaldo == 0 .AND. oApl:oFac:INDICADOR $ " P"
            FechaCan( aVt,oApl:oFac:NUMFAC )
         EndIf
      EndIf
   EndIf
   oApl:oFac:Skip(1):Read()
   oApl:oFac:xLoad()
EndDo

If aVt[2] == "D"
   oDPrn:NewPage()
   oDPrn:End() ; RETURN
EndIf
oApl:oPag:dbEval( {|o| If( o:FORMAPAGO >= 7                                      ,;
                         ( aVt[10] += (o:PAGADO * {-1,1,-1}[o:FORMAPAGO-6]) )    ,;
                         (nK      := o:ABONO + o:RETENCION + o:DEDUCCION +        ;
                                     If( oApl:cPer < "199604", 0, o:DESCUENTO )  ,;
                          nAnul   := o:DEDUCCION + o:DESCUENTO                   ,;
                          aVt[09] += (nK - If(o:INDICADOR = "-", o:DESCUENTO, 0)),;
                          If( o:FORMAPAGO == 3 .AND. o:PAGADO < nK               ,;
                            (aVt[11] += o:ABONO + o:DEDUCCION                    ,;
                             aVt[12] += If( o:INDICADOR = ".", 0, nAnul )        ,;
                             aVt[13] += o:RETENCION ), ) ) ) }                   ,;
                  {"Empresa",oApl:nEmpresa,"Fecpag >= ",aVt[3],"Fecpag <= ",aVt[4],;
                   "Tipo",oApl:Tipo,"Indicador <>","A"} )
aVt[09] := aVt[09] - aVt[11] - If( oApl:cPer < "199604", 0, aVt[12] )
aVt[11] := aVt[06] + aVt[08] - aVt[09] + aVt[10] + aVt[13]
aVt[12] := aVt[07] - aVt[11]
oDPrn:Titulo( 80 )
oDPrn:Say( 10,10,"Saldo Anterior............" + NtChr( aVt[06],cPict ) )
oDPrn:Say( 12,10,"Cargos del Mes............" + NtChr( aVt[08],cPict ) )
oDPrn:Say( 14,10,"Abonos del Mes............" + NtChr( aVt[09],cPict ) )
oDPrn:Say( 16,10,"Notas Debitos y Creditos.." + NtChr( aVt[10],cPict ) )
oDPrn:Say( 18,10,"Saldo Actual.............." + NtChr( aVt[07],cPict ) )
oDPrn:Say( 20,10,"Saldo Matematico.........." + NtChr( aVt[11],cPict ) )
oDPrn:Say( 22,10,"Diferencia................" + NtChr( aVt[12],cPict ) )
oDPrn:NewPage()
oDPrn:End()
RETURN

//------------------------------------//
STATIC PROCEDURE Abonos( aVt,nNumfac )
   LOCAL nK
AFILL( aVt,0,9,3 )
oApl:oPag:dbEval( {|o| If( o:FORMAPAGO >= 7                                       ,;
                         (aVt[10] += (o:PAGADO * {-1,1,-1}[o:FORMAPAGO-6]) )      ,;
                         (nK      := o:ABONO + o:RETENCION + o:DEDUCCION +         ;
                                     o:DESCUENTO                                  ,;
                          aVt[09] += nK, If( o:FORMAPAGO == 3 .AND. o:PAGADO < nK ,;
                         (aVt[11] += o:ABONO + o:DEDUCCION + o:DESCUENTO), ) ) ) },;
                  {"Empresa",oApl:nEmpresa,"Numfac",nNumfac,"Tipo",oApl:Tipo       ,;
                   "Fecpag >= ",aVt[3],"Fecpag <= ",aVt[4],"Indicador <>","A"} )
aVt[09] -= aVt[11]
RETURN

//------------------------------------//
STATIC PROCEDURE FechaCan( aVt,nNumfac )
   LOCAL dFec //nK := SECONDS()
dFec := Buscar( { "Empresa",oApl:nEmpresa,"Numfac",nNumfac,"Tipo",oApl:Tipo },;
                "CadPagos","MAX(Fecpag)",9 )
dFec := MAX( dFec,oApl:oFac:FECHOY )
If dFec <= aVt[4]
   oApl:oFac:INDICADOR := "C" ; oApl:oFac:FECHACAN := dFec
   oApl:oFac:Update(.f.,1)
EndIf
RETURN

//------------------------------------//
PROCEDURE CaoAsien()
   LOCAL oDlg, oGet := ARRAY(7), aFile := { "CADFACTU","CADPAGOS","CADVENTA" }
   LOCAL aTin := { 0,CTOD(""),CTOD(""),0,.f.,oApl:nEmpresa,9999999999 }
If MsgYesNo( "Si esta todo Ok.", "Inserte el DISKETTE con las Ventas" )
   FOR aTin[4] := 1 TO 3
      If !AbreDbf( "Tem",aFile[aTin[4]],,"A:" )
         EXIT ; EndIf
      MsgMeter( { | oMeter, oText, oDlg, lEnd | ;
                Revisar( oMeter,oText,oDlg,@lEnd,@aTin ) },;
                aFile[aTin[4]],"Revisando" )
      Tem->(dbCloseArea())
   NEXT
   aTin[5] := .t.
   oApl:oEmp:Seek( { "Empresa",aTin[1] } )
EndIf
DEFINE DIALOG oDlg TITLE "Pegar y Actualizar las Ventas" FROM 1, 2 TO 10,46 //OF oApl:oWnd
   @ 02, 10 SAY oGet[1] VAR oApl:oEmp:NOMBRE OF oDlg PIXEL SIZE 140,12
   @ 16, 00 SAY "Fecha Inicial [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 16, 92 GET oGet[2] VAR aTin[2] OF oDlg SIZE 40,12 PIXEL
   @ 16,140 SAY oGet[6] VAR oApl:oEmp:NUMFACU OF oDlg PIXEL SIZE 60,12
   @ 30, 00 SAY "Fecha   Final [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 30, 92 GET oGet[3] VAR aTin[3] OF oDlg ;
      VALID aTin[3] >= aTin[2] SIZE 40,12 PIXEL
   @ 30,140 SAY oGet[7] VAR aTin[7] OF oDlg PIXEL SIZE 60,12 ;
      UPDATE COLOR nRGB( 160,19,132 )
   @ 46, 60 BUTTON oGet[4] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ;
      ACTION ( MsgRun( "Adicionando CADFACTU","Por favor Espere",;
               { |oDlg| PegoVenta(aTin,oDlg) } ), oDlg:End() ) PIXEL
   @ 46,110 BUTTON oGet[5] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ;
   WHEN aTin[5]               //NOWAIT
oApl:oEmp:Seek( { "Empresa",aTin[6] } )
oApl:nEmpresa := aTin[6]
RETURN

//------------------------------------//
STATIC FUNCTION PegoVenta( aTin,oDlg )
   LOCAL cCod, nPago, nNumFac := 0
ERASE A:CadFactu.Ult
ERASE A:CadPagos.Ult
ERASE A:CadVenta.Ult
CopyaSQL( oApl:oFac )
ReName A:CadFactu.dbf To A:CadFactu.Ult

oDlg:cMsg := "Adicionando CADPAGOS"
oDlg:Refresh() ; SysRefresh()
CopyaSQL( oApl:oPag )
ReName A:CadPagos.dbf To A:CadPagos.Ult

oDlg:cMsg := "Adicionando CADVENTA"
oDlg:Refresh() ; SysRefresh()
CopyaSQL( oApl:oVen )
ReName A:CadVenta.dbf To A:CadVenta.Ult

oApl:nEmpresa := aTin[1]
oApl:oFac:Seek( { "Empresa",aTin[1],"Fechoy >= ",aTin[2],"Fechoy <= ",aTin[3],;
                  "Tipo <> ","Z","Indicador <> ","A" } )
While !oApl:oFac:Eof()
   nNumFac := oApl:oFac:NUMFAC
   oApl:oVen:dbEval( {|o| If( !LEFT(o:CODART,2) $ "02 05"             ,;
                              GrabaV( o:CANTIDAD,"N",2,o:FECFAC ), ) },;
                     {"Empresa",aTin[1],"Numfac",nNumFac,"Tipo",oApl:oFac:TIPO,;
                      "Fecfac",oApl:oFac:FECHOY,"Indicador NOT IN ","('A','D')"} )
   nPago := 0
   oApl:oPag:dbEval( {|o|  nPago += o:PAGADO },;
                     {"Empresa",aTin[1],"Numfac",nNumFac,"Tipo",oApl:oFac:TIPO,;
                      "Formapago <= ",4,"Indicador NOT IN ","('A','*')"} )
   oApl:nSaldo := oApl:oFac:TOTALFAC
   If oApl:nSaldo - nPago # 0
      oApl:cPer := NtChr( oApl:oFac:FECHOY,"1" )
      oApl:Tipo := oApl:oFac:TIPO
      oApl:lFam := .f.
      GrabaSal( nNumFac,1,nPago )
   EndIf
   oApl:oFac:Skip(1):Read()
   oApl:oFac:xLoad()
EndDo
If nNumFac > oApl:oEmp:NUMFACU
   oApl:oEmp:NUMFACU := nNumFac ; oApl:oEmp:Update(.f.,1)
EndIf

oApl:oPag:Seek( { "Empresa",aTin[1],"Fecpag >= ",aTin[2],"Fecpag <= ",aTin[3],;
                  "Formapago <= ",4,"Indicador NOT IN ","('A','*')" } )
While !oApl:oPag:Eof()
   oDlg:cMsg := "Actualizo PAGOS" + STR(oApl:oPag:NUMFAC)
   oDlg:Refresh() ; SysRefresh()
   oApl:oFac:Seek( { "Empresa",aTin[1],"Numfac",oApl:oPag:NUMFAC,"Tipo",oApl:oPag:TIPO } )
   If oApl:oPag:PAGADO > 0 .AND. oApl:oFac:FECHOY < aTin[2]
      oApl:cPer := NtChr( oApl:oPag:FECPAG,"1" )
      oApl:Tipo := oApl:oPag:TIPO
      oApl:lFam := SaldoFac( oApl:oPag:NUMFAC )
      If oApl:nSaldo - oApl:oPag:PAGADO = 0
         oApl:oFac:INDICADOR := "C" ; oApl:oFac:FECHACAN := oApl:oPag:FECPAG
         oApl:oFac:Update(.f.,1)
      EndIf
      GrabaSal( oApl:oPag:NUMFAC,1,oApl:oPag:PAGADO )
   EndIf
   oApl:oPag:Skip(1):Read()
   oApl:oPag:xLoad()
EndDo

ActuCliente( oDlg )
MsgInfo( "Ventas Actualizadas","HECHO" )
RETURN NIL

//------------------------------------//
PROCEDURE CopyaSQL( oTb,cRuta )
   LOCAL cFile, cQry, n, nFldCount := oTb:FieldCount()
   DEFAULT cRuta := oApl:cRuta2
BorraFile( oTb:cName,{"DBF"},cRuta )
cQry  := "A:" + oTb:cName + ".DBF"
cFile := cRuta+ oTb:cName + ".DBF"
COPY FILE &(cQry) TO &(cFile)
dbUseArea( .t.,, cRuta+oTb:cName,"Tmp" )

While !Tmp->(EOF())
   cQry := 'INSERT INTO ' + oTb:cName + ' VALUES ( '
   FOR n := 1 TO nFldCount
      cQry += If( MyIsAutoInc( oTb:hResult, n ), 'NULL',;
                  xValToChar( FieldGet( n ) ) ) + ", "
   NEXT
   cQry := LEFT( cQry,LEN(cQry)-2 ) + ' )'
   MSQuery( oApl:oMySql:hConnect,cQry )
   Tmp->(dbSkip())
enddo
dbCloseArea()

RETURN

//------------------------------------//
STATIC PROCEDURE ActuCliente( oDlg )
   LOCAL cQry, cTemp := oApl:cRuta2 + "REPLICA.DBF"
If !FILE( "A:CadClien.DBF" )
   RETURN
EndIf
COPY FILE A:CADCLIEN.dbf TO &(cTemp)
If !AbreDbf( "Rep","Replica",,,.f. )
   RETURN ; EndIf
oDlg:cMsg := "Actualizando CLIENTES"
oDlg:Refresh() ; SysRefresh()
While !Rep->(EOF())
   If !oApl:oNit:Seek( {"Codigo",Rep->CODIGO} )
      oApl:oNit:CODIGO    := Rep->CODIGO   ; oApl:oNit:DIGITO    := Rep->DIGITO
      oApl:oNit:TIPOCOD   := Rep->TIPOCOD  ; oApl:oNit:NOMBRE    := Rep->NOMBRE
      oApl:oNit:TELEFONO  := Rep->TELEFONO ; oApl:oNit:FAX       := Rep->FAX
      oApl:oNit:DIRECCION := Rep->DIRECCION; oApl:oNit:EMAIL     := Rep->EMAIL
      oApl:oNit:CIUDAD    := Rep->CIUDAD   ; oApl:oNit:POR_DSCTO := Rep->POR_DSCTO
      oApl:oNit:CONSULTA  := Rep->CONSULTA ; oApl:oNit:EPS       := Rep->EPS
      oApl:oNit:Append(.t.)
      oApl:oNit:CODIGO_NIT:= oApl:oNit:ROW_ID
      oApl:oNit:Update(.f.,1)
   EndIf
   If oApl:oNit:CODIGO_NIT # Rep->CODIGO_NIT
      cQry := "UPDATE CadFactu SET Codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT)) +;
             " WHERE Empresa = " + LTRIM(STR(oApl:nEmpresa)) + ;
           " AND Codigo_nit = " + LTRIM(STR(Rep->CODIGO_NIT))
      MSQuery( oApl:oMySql:hConnect,cQry )
      Rep->CODIGO_NIT := oApl:oNit:CODIGO_NIT
   EndIf
   Rep->(dbSkip())
EndDo
Rep->(dbCloseArea())
COPY FILE &(cTemp) TO A:CADCLIEN.dbf
BorraFile( "REPLICA",{"DBF"} )
RETURN

//------------------------------------//
FUNCTION Revisar( oMeter,oText,oDlg,lEnd,aTin )
   LOCAL cCam := { "FECHOY","FECPAG","FECFAC","FECREPOS" }[aTin[4]]
   LOCAL lFac := If( aTin[4] == 1 .AND. LEN( aTin ) == 7, .t. , .f. )
aTin[2] := If( Empty( aTin[2] ), &(cCam), aTin[2] )
If (oMeter:nTotal := LASTREC()) > 0
   aTin[1] := TeM->Empresa
   aTin[2] := MIN( aTin[2],&(cCam) )
   WHILE !EOF()
      If aTin[4] <= 2
         aTin[3] := MAX( aTin[3],&(cCam) )
         If lFac
            If TeM->TIPO # "Z"
               aTin[7] := MIN( aTin[7],TeM->NUMFAC )
            EndIf
         EndIf
      EndIf
      dbSkip()
      oMeter:Set( RecNo() )
      SysRefresh()
   ENDDO
EndIf
RETURN NIL
