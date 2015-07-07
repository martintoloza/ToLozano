// Programa.: PDLLISAL.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Saldos de Cartera y Facturas Canceladas.
#include "FiveWin.ch"
#include "Btnget.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE CaoLiSal( nOpc )
   LOCAL aVT, oDlg, oLC, oNi, oGet := ARRAY(11)
   DEFAULT nOpc := 1
oLC := TCarte()
oNi := TNits() ; oNi:New()

aVT := { { {|| oLC:ListoSal() },"Listo Saldos de Cartera" }  ,;
         { {|| oLC:ListoSal() },"Listo Facturas Canceladas" } }
DEFINE DIALOG oDlg TITLE aVT[nOpc,2] FROM 0, 0 TO 16,50
   @ 02, 00 SAY "Nit por Default Todos" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02, 92 BTNGET oGet[1] VAR oLC:aLS[6] OF oDlg PICTURE "999999999999";
      ACTION EVAL({|| If(oNi:Mostrar(), (oLC:aLS[6] := oNi:oDb:CODIGO  ,;
                         oGet[1]:Refresh(), oGet[1]:lValid(.f.)),) } )  ;
      VALID EVAL( {|| If( EMPTY( oLC:aLS[6] ), .t.                     ,;
                     (If( oNi:oDb:Seek( {"codigo",oLC:aLS[6]} )        ,;
                        ( oGet[2]:Settext( oNi:oDb:NOMBRE), .t. )      ,;
                        ( MsgStop("Este Nit no Existe"),.f.)))) } )     ;
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"
   @ 14, 10 SAY oGet[2] VAR oLC:aLS[7] OF oDlg PIXEL SIZE 130,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 26, 00 SAY "FECHA DE CORTE [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 26, 92 GET oGet[3] VAR oLC:aLS[1] OF oDlg  SIZE 40,10 PIXEL
   @ 38, 00 SAY "PAGINA INICIAL"            OF oDlg RIGHT PIXEL SIZE 90,10
   @ 38, 92 GET oGet[4] VAR oLC:aLS[2] OF oDlg PICTURE "999";
      VALID Rango( oLC:aLS[2],1,999 )  SIZE 24,10 PIXEL
   @ 50, 00 SAY "DESEA  UN  RESUMEN [S/N]"  OF oDlg RIGHT PIXEL SIZE 90,10
   @ 50, 92 GET oGet[5] VAR oLC:aLS[3] OF oDlg PICTURE "!";
      VALID oLC:aLS[3] $ "NS"  SIZE 08,10 PIXEL
   @ 62, 00 SAY "ORDENAR POR CLIENTE [S/N]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 62, 92 GET oGet[6] VAR oLC:aLS[4] OF oDlg PICTURE "!";
      VALID oLC:aLS[4] $ "NS" ;
      WHEN  oLC:aLS[3] == "N"  SIZE 08,10 PIXEL
   @ 74, 00 SAY "CLASE DE PAPEL"            OF oDlg RIGHT PIXEL SIZE 90,10
   @ 74, 92 COMBOBOX oGet[7] VAR oLC:aLS[8] ITEMS ArrayCol( oApl:aPapel,1 );
      SIZE 46,99 OF oDlg PIXEL
   @ 74,142 CHECKBOX oGet[8] VAR oLC:aLS[5] PROMPT "Vista &Previa" OF oDlg;
       SIZE 60,10 PIXEL
   @ 86, 00 SAY "TIPO DE IMPRESORA"   OF oDlg RIGHT PIXEL SIZE 90,10
   @ 86, 92 COMBOBOX oGet[9] VAR oLC:aLS[9] ITEMS { "Matriz","Laser" };
      SIZE 40,90 OF oDlg PIXEL

   @ 102, 50 BUTTON oGet[10] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[10]:Disable(), EVAL( aVT[nOpc,1] ), oGet[10]:Enable(),;
        oGet[10]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 102,100 BUTTON oGet[11] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 108, 02 SAY "[PDLLISAL]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED NOMODAL
RETURN

//------------------------------------//
CLASS TCarte FROM TIMPRIME
              //         { 0,"",DATE(),1,"N","S",1,.t.,oApl:nTFor }
 DATA aLS  AS ARRAY INIT { DATE(),1,"N","S",.t.,0,"",1,oApl:nTFor,"999,999,999.99" }
 DATA hRes, nL

 METHOD ListoSal()
 METHOD LaserSal( aGT,aVence )
// METHOD ListoCan()
// METHOD LaserCan( nL,hRes )
// METHOD Query( nH,aGT )
ENDCLASS

//------------------------------------//
METHOD ListoSal() CLASS TCarte
   LOCAL aRes, aVence, cQry, nL
   LOCAL oRpt, aGT := ARRAY(2,6)
AEVAL( aGT, {|x| AFILL( x,0 ) } )
aVence := { 0,0,0,0,0,0 }
cQry := "SELECT n.nombre, n.codigo, n.digito, f.fechacob, f.hora, "      +;
        "f.numfac, f.fechoy, f.cliente, f.telefono, f.totalfac, s.saldo "+;
        "FROM cadfactm s, cadfactu f LEFT JOIN cadclien n "      +;
         "USING( codigo_nit ) "                                  +;
        "WHERE f.empresa = " + LTRIM(STR(oApl:nEmpresa))         +;
         " AND f.fechoy <= " + xValToChar( ::aLS[1] )            +;
         " AND f.tipo    = " + xValToChar( oApl:Tipo )           +;
         " AND f.indicador <> 'A'" +     If( ::aLS[6] > 0        ,;
         " AND f.codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT)), "" ) +;
         " AND s.empresa = f.empresa"                            +;
         " AND s.numfac = f.numfac AND s.tipo = f.tipo"          +;
         " AND s.anomes = (SELECT MAX(m.anomes) FROM cadfactm m "+;
                          "WHERE m.empresa = f.empresa"          +;
            	             " AND m.numfac  = f.numfac"           +;
                           " AND m.tipo    = f.tipo"             +;
                           " AND m.anomes <= '" + NtChr( ::aLS[1],"1" )  +;
       "') AND s.saldo <> 0  ORDER BY n.nombre, " +;
        If( ::aLS[4] == "S", "f.cliente, ", "" ) + "f.fechoy, f.numfac"
::hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) == 0
   MsgInfo( cQry,"NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes )
   RETURN NIL
ElseIf ::aLS[9] == 2
   ::LaserSal( aGT,aVence )
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"REPORTE DE CUENTAS POR COBRAR"  ,;
         NtChr( ::aLS[1],"3" ), "          FECHA DE COBRO" + SPACE(21)+;
        "--FACTURA-  FEC.FACTURA  N O M B R E  DEL C L I E N T E ---" +;
        "T E L E F O N O S--- SALDO FACT."},::aLS[5],::aLS[2],2,oApl:aPapel[::aLS[8],2] )
   aRes := MyReadRow( ::hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   ::aLS[7] := aRes[1]
   ::aLS[6] := aRes[2]
   cQry   := PADR(aRes[1],30) + " " + FormatoNit( aRes[2],aRes[3] )
While ::nL > 0
   oApl:nSaldo := aRes[11]
   Vence( ::aLS[1]- aRes[7],@aVence )
      oRpt:Titulo( 136 )
   If oRpt:nPage >= oRpt:nPagI .AND. ::aLS[3] == "N"
      If aGT[1,5] == 0
         oRpt:Say( oRpt:nL,01,cQry )
         oRpt:nL += If( EMPTY( aRes[4] ), 0, 1 )
      EndIf
      If !EMPTY( aRes[4] )
         oRpt:Say( oRpt:nL,10,NtChr( aRes[4],"2" ) + "  " + aRes[5] )
      EndIf
      oRpt:Say( oRpt:nL, 45,STR(aRes[6]) )
//    oRpt:Say( oRpt:nL, 55,If( cTipo = "UD" .And. Tipo = "D", ".", " " ))
      oRpt:Say( oRpt:nL, 57,NtChr( aRes[7],"2" ) )
//    oRpt:Say( oRpt:nL, 75,NtChr( FechaVen,"2" ))
      oRpt:Say( oRpt:nL, 70,aRes[8] )
      oRpt:Say( oRpt:nL,101,aRes[9],20 )
      oRpt:Say( oRpt:nL,122,TRANSFORM(aRes[11],::aLS[10]) )
      oRpt:nL ++
   EndIf
   aGT[1,5] += aRes[11]
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. aRes[1] # ::aLS[7]
      oRpt:Titulo( 136 )
      If oRpt:nPage >= oRpt:nPagI
         AEVAL( aVence, {|nVal,nP| aGT[2,nP] += nVal } )
         If ::aLS[3] == "N"
            oRpt:Say(++oRpt:nL, 97,"TOTAL CLIENTE --> $"+oRpt:CPIBold,,,1 )
            oRpt:Say(  oRpt:nL,116,TRANSFORM( aGT[1,5],::aLS[10] )+oRpt:CPIBoldN )
         Else
            oRpt:Say(  oRpt:nL,01,cQry,,,1 )
            oRpt:Say(  oRpt:nL,116,TRANSFORM( aGT[1,5],::aLS[10] ) )
            oRpt:nL ++
         //   Vence( 0,aVence,50,oRpt )
         EndIf
      EndIF
      oRpt:nL += 2
      If ::aLS[6] > 0
         aGT[1,2] += aGT[1,5]
      EndIf
      AFILL( aVence,0 )
      aGT[1,4] ++
      aGT[1,5] := 0
      ::aLS[7] := aRes[1]
      ::aLS[6] := aRes[2]
      cQry   := PADR(aRes[1],30) + " " + FormatoNit( aRes[2],aRes[3] )
   EndIf
EndDo
MSFreeResult( ::hRes )
If aGT[1,4] > 0
   FOR nL := 1 TO 6
      aVence[nL] := aGT[2,nL]
   NEXT nL
   oRpt:Titulo( 136 )
   oRpt:Say(  oRpt:nL, 01,REPLICATE("_",136),,,1 )
   oRpt:Say(++oRpt:nL, 01,STR( aGT[1,4],3 ) + "  SALDOS",,,1 )
   oRpt:Say(  oRpt:nL,116,TRANSFORM(aGT[2,6],::aLS[10]) )
   oRpt:Say(++oRpt:nL, 01,REPLICATE("_",136),,,1 )
   oRpt:Separator( 2,10 )
   oRpt:Say( oRpt:nL  ,10,"TOTAL EMPRESAS ------------> $" + NtChr( aGT[1,2],::aLS[10] ) )
   oRpt:Say( oRpt:nL+2,10,"TOTAL CUENTAS POR COBRAR --> $" + NtChr( aGT[2,6],::aLS[10] ) )
   oRpt:nL += 4
   Vence( 0,aVence,10,oRpt )
EndIf
oRpt:NewPage()
oRpt:End()
 ::aLS[6] := 0
 ::aLS[7] := ""
RETURN NIL

//------------------------------------//
METHOD LaserSal( aGT,aVence ) CLASS TCarte
   LOCAL aLC, aRes, nL
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit      ,;
             "REPORTE DE CUENTAS POR COBRAR", NtChr( ::aLS[1],"3" )          ,;
             { .F.,01.8,"FECHA DE COBRO" }, { .T., 9.4,"FACTURA" }           ,;
             { .F.,10.0,"F E C H A" }     , { .F.,11.7,"NOMBRE DEL CLIENTE" },;
             { .F.,15.2,"TELEFONOS" }     , { .T.,20.5,"SALDO FACTURA" } }
   aRes := MyReadRow( ::hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   ::aLS[7] := aRes[1]
   ::aLS[6] := aRes[2]
     aLC    := { FormatoNit( aRes[2],aRes[3] ),0 }
 ::TamanoHoja( oApl:aPapel[::aLS[8],2] )
 ::Init( ::aEnc[4], .f. ,, !::aLS[5] ,,, ::aLS[5], 5 )
 ::nMD := 20.5
  PAGE
While ::nL > 0
   oApl:nSaldo := aRes[11]
   Vence( ::aLS[1]- aRes[7],@aVence )
   If ::aLS[3] == "N"
      ::Cabecera( .t.,0.42 )
      If aGT[1,5] == 0
         UTILPRN ::oUtil Self:nLinea, 0.5 SAY LEFT(::aLS[7],36)
         UTILPRN ::oUtil Self:nLinea, 5.9 SAY aLC[1]
         If !EMPTY( aRes[4] )
            ::Cabecera( .t.,0.42 )
            UTILPRN ::oUtil Self:nLinea, 1.8 SAY NtChr( aRes[4],"2" ) + "  " + aRes[5]
         EndIf
      ElseIf !EMPTY( aRes[4] )
         UTILPRN ::oUtil Self:nLinea, 1.8 SAY NtChr( aRes[4],"2" ) + "  " + aRes[5]
      EndIf
      UTILPRN ::oUtil Self:nLinea, 9.4 SAY STR(aRes[6])                    RIGHT
      UTILPRN ::oUtil Self:nLinea, 9.7 SAY NtChr( aRes[7],"2" )
      UTILPRN ::oUtil Self:nLinea,11.7 SAY LEFT( aRes[8],20 )
      UTILPRN ::oUtil Self:nLinea,15.2 SAY LEFT( aRes[9],20 )
      UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aRes[11],::aLS[10] ) RIGHT
   EndIf
   aGT[1,5] += aRes[11]
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. aRes[1] # ::aLS[7]
      AEVAL( aVence, {|nVal,nP| aGT[2,nP] += nVal } )
      If ::aLS[3] == "N"
         ::Cabecera( .t.,0.84 )
         UTILPRN ::oUtil SELECT ::aFnt[6]
         UTILPRN ::oUtil Self:nLinea,15.2 SAY "TOTAL CLIENTE --> $"
         UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aGT[1,5],::aLS[10] ) RIGHT
         UTILPRN ::oUtil SELECT ::aFnt[5]
      Else
         ::Cabecera( .t.,0.42 )
         UTILPRN ::oUtil Self:nLinea, 0.5 SAY LEFT(::aLS[7],36)
         UTILPRN ::oUtil Self:nLinea, 5.9 SAY aLC[1]
         UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aGT[1,5],::aLS[10] ) RIGHT
         //   Vence( 0,aVence,50,oRpt )
      EndIf
      ::nLinea += 0.42
      If ::aLS[6] > 0
         aGT[1,2] += aGT[1,5]
      EndIf
      AFILL( aVence,0 )
      aGT[1,4] ++
      aGT[1,5] := 0
      ::aLS[7] := aRes[1]
      ::aLS[6] := aRes[2]
        aLC[1] := FormatoNit( aRes[2],aRes[3] )
   EndIf
EndDo
MSFreeResult( ::hRes )
If aGT[1,4] > 0
   FOR nL := 1 TO 6
      aVence[nL] := aGT[2,nL]
   NEXT nL
   ::Cabecera( .t.,0.1,3.26,20.5 )
   UTILPRN ::oUtil Self:nLinea, 0.6 SAY STR( aGT[1,4],3 ) + "  SALDOS"
   UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aGT[2,6],::aLS[10] ) RIGHT
   ::nLinea += 0.84
   UTILPRN ::oUtil Self:nLinea, 2.0 SAY "TOTAL EMPRESAS ------------> $"
   UTILPRN ::oUtil Self:nLinea, 9.0 SAY TRANSFORM( aGT[1,2],::aLS[10] ) RIGHT
   ::nLinea += 0.84
   UTILPRN ::oUtil Self:nLinea, 2.0 SAY "TOTAL CUENTAS POR COBRAR --> $"
   UTILPRN ::oUtil Self:nLinea, 9.0 SAY TRANSFORM( aGT[2,6],::aLS[10] ) RIGHT

// Vence( 0,aVence,10,oRpt )
   aRes := { "A 15 Dias","A 30 Dias","A 45 Dias","A 60 Dias","Sobre 60 Dias",;
             ::nLinea+0.84, 3.5 }
   ::nLinea += 1.26
   FOR nL := 1 TO 5
      UTILPRN ::oUtil aRes[6]    , aRes[7] SAY aRes[nL]                            RIGHT
      UTILPRN ::oUtil Self:nLinea, aRes[7] SAY TRANSFORM(aVence[nL],"999,999,999") RIGHT
      If aVence[6]  > 0
         aVence[nL] := ROUND( aVence[nL]/aVence[6]*100,2 )
         UTILPRN ::oUtil aRes[6]+0.84, aRes[7] SAY TRANSFORM(aVence[nL],"999.99%") RIGHT
      EndIf
      aRes[7] += 2
   NEXT nL
EndIf
  ENDPAGE
 ::EndInit( .F. )
 ::aLS[6] := 0
 ::aLS[7] := ""
RETURN NIL

//------------------------------------//
PROCEDURE Vence( nDias,aVence,nC,oRpt )
If nC == NIL
   do Case
   Case nDias < 16
      aVence[1] += oApl:nSaldo
   Case nDias >= 16 .AND. nDias <= 30
      aVence[2] += oApl:nSaldo
   Case nDias >= 31 .AND. nDias <= 45
      aVence[3] += oApl:nSaldo
   Case nDias >= 46 .AND. nDias <= 60
      aVence[4] += oApl:nSaldo
   OtherWise
      aVence[5] += oApl:nSaldo
   EndCase
      aVence[6] += oApl:nSaldo
Else
   oRpt:Say( oRpt:nL,nC," A 15 Dias     A 30 Dias     A 45 Dias     A 60 Dias   Sobre 60 Dias",,,1 )
   oRpt:nL ++
   oRpt:Say( oRpt:nL,nC   ,TRANSFORM(aVence[1],"999,999,999"),,,1 )
   oRpt:Say( oRpt:nL,nC+14,TRANSFORM(aVence[2],"999,999,999") )
   oRpt:Say( oRpt:nL,nC+28,TRANSFORM(aVence[3],"999,999,999") )
   oRpt:Say( oRpt:nL,nC+42,TRANSFORM(aVence[4],"999,999,999") )
   oRpt:Say( oRpt:nL,nC+56,TRANSFORM(aVence[5],"999,999,999") )
   If aVence[6] > 0
      oRpt:nL ++ //:= (++nLi)
      oRpt:Say( oRpt:nL,nC+04,NtChr( ROUND( aVence[1]/aVence[6]*100,2 ),"999.99%" ),,,1)
      oRpt:Say( oRpt:nL,nC+18,NtChr( ROUND( aVence[2]/aVence[6]*100,2 ),"999.99%" ))
      oRpt:Say( oRpt:nL,nC+32,NtChr( ROUND( aVence[3]/aVence[6]*100,2 ),"999.99%" ))
      oRpt:Say( oRpt:nL,nC+46,NtChr( ROUND( aVence[4]/aVence[6]*100,2 ),"999.99%" ))
      oRpt:Say( oRpt:nL,nC+60,NtChr( ROUND( aVence[5]/aVence[6]*100,2 ),"999.99%" ))
   EndIf
   oRpt:nL += 2
EndIf
RETURN