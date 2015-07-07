// Programa.: JVMLISAL.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Saldos de Cartera y Facturas Canceladas.
#include "FiveWin.ch"
#include "Btnget.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE CaoLiSal( nOpc )
   LOCAL aTF, aVT, oDlg, oLC, oNi, oGet := ARRAY(10)
   DEFAULT nOpc := 1
oLC := TCarte()
oNi := TNits() ; oNi:New()
aTF := TipoFac( .f. )
aVT := { { {|| oLC:ListoSal( aTF ) },"Listo Saldos de Cartera" }  ,;
         { {|| ListoCan( oLC:aLS,aTF ) },"Listo Facturas Canceladas" } }
oLC:aLS[9] := LEN( aTF ) -1
DEFINE DIALOG oDlg TITLE aVT[nOpc,2] FROM 0, 0 TO 14,50
   @ 02, 00 SAY "Nit por Default Todos" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02, 92 BTNGET oGet[1] VAR oLC:aLS[1] OF oDlg PICTURE "999999999999";
      VALID EVAL( {|| If( EMPTY( oLC:aLS[1] ), .t.                     ,;
                ( If( oNi:oDb:Seek( {"codigo",oLC:aLS[1]} )            ,;
                    ( oGet[2]:Settext( oNi:oDb:NOMBRE), .t. )          ,;
                    ( MsgStop("Este Nit no Existe"),.f.)))) } )         ;
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"                               ;
      ACTION EVAL({|| If(oNi:Mostrar(), (oLC:aLS[1] := oNi:oDb:CODIGO,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
   @ 14, 10 SAY oGet[2] VAR oLC:aLS[2] OF oDlg PIXEL SIZE 130,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 26, 00 SAY "FECHA DE CORTE [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 26, 92 GET oGet[3] VAR oLC:aLS[3] OF oDlg  SIZE 40,10 PIXEL
   @ 38, 00 SAY "PAGINA INICIAL"            OF oDlg RIGHT PIXEL SIZE 90,10
   @ 38, 92 GET oGet[4] VAR oLC:aLS[4] OF oDlg PICTURE "999";
      VALID Rango( oLC:aLS[4],1,999 )  SIZE 24,10 PIXEL
   @ 50, 00 SAY "DESEA  UN  RESUMEN [S/N]"  OF oDlg RIGHT PIXEL SIZE 90,10
   @ 50, 92 GET oGet[5] VAR oLC:aLS[5] OF oDlg PICTURE "!";
      VALID oLC:aLS[5] $ "NS"  SIZE 08,10 PIXEL
   @ 62, 00 SAY "TIPO DE FACTURA"           OF oDlg RIGHT PIXEL SIZE 90,10
   @ 62, 92 COMBOBOX oGet[6] VAR oLC:aLS[6] ITEMS aTF;
      SIZE 40,99 OF oDlg PIXEL
   @ 74, 00 SAY "TIPO DE IMPRESORA"   OF oDlg RIGHT PIXEL SIZE 90,10
   @ 74, 92 COMBOBOX oGet[7] VAR oLC:aLS[7] ITEMS { "Matriz","Laser" };
      SIZE 40,90 OF oDlg PIXEL
   @ 74,142 CHECKBOX oGet[8] VAR oLC:aLS[8] PROMPT "Vista Previa" OF oDlg;
       SIZE 60,10 PIXEL
   @ 88, 50 BUTTON oGet[09] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[9]:Disable(), EVAL( aVT[nOpc,1] ), oGet[9]:Enable(),;
        oGet[9]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 88,100 BUTTON oGet[10] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 92, 02 SAY "[JVMLISAL]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED NOMODAL
RETURN

//------------------------------------//
CLASS TCarte FROM TIMPRIME

 DATA aLS  AS ARRAY INIT { 0,"",DATE(),1,"N",1,oApl:nTFor,.t.,1,"" }
                  //     { DATE(),1,"N",.t.,0,"",1,1 }
 METHOD ListoSal( aTF )
 METHOD LaserSal( nL,hRes )
// METHOD ListoCan()
// METHOD LaserCan( nL,hRes )
// METHOD Query( nH,aGT )
ENDCLASS

//------------------------------------//
METHOD ListoSal( aTF ) CLASS TCarte
   LOCAL oRpt, aGT := ARRAY(2,6), aVence := ARRAY(6)
   LOCAL aRes, hRes, nL, cQry, cPict := "999,999,999.99"
cQry := "SELECT n.nombre, n.codigo, n.digito, c.numfac, c.tipo, "+;
          "c.fechoy, c.cliente, c.codigo_nit, c.totalfac, s.saldo "+;
        "FROM cadfactm s, cadfactc c LEFT JOIN cadclien n "      +;
         "USING( codigo_nit ) "                                  +;
        "WHERE c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fechoy <= " + xValToChar( ::aLS[3] )   + If( ::aLS[6] <= ::aLS[9],;
         " AND c.tipo   = '" + aTF[::aLS[6]] + "'", "" )+;
         " AND c.indicador <> 'A'"                      + If( ::aLS[1] > 0,;
         " AND c.codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT)), "" )  +;
         " AND s.empresa = c.empresa"                                     +;
         " AND s.numfac =  c.numfac AND s.tipo = c.tipo"                  +;
         " AND s.anomes = (SELECT MAX(m.anomes) FROM cadfactm m "         +;
                          "WHERE m.empresa = c.empresa"                   +;
                           " AND m.numfac  = c.numfac"                    +;
                           " AND m.tipo    = c.tipo"                      +;
                           " AND m.anomes <= '" + NtChr( ::aLS[3],"1" )   +;
       "') AND s.saldo <> 0  ORDER BY n.nombre, c.fechoy, c.numfac"
//       " AND c.Tipo    = " + {"'C'","'X'"}[::aLS[6]], "" )               +;
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( cQry,"NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[7] == 2
   ::LaserSal( nL,hRes )
   RETURN NIL
EndIf
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   ::aLS[2] := aRes[1]
     cQry   := PADR(aRes[1],36) + " " + FormatoNit( aRes[2],aRes[3] )
AEVAL( aGT, {|x| AFILL( x,0 ) } )
AFILL( aVence,0 )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"REPORTE DE CUENTAS POR COBRAR",;
         NtChr( ::aLS[3],"3" ),SPACE(50) + "--FACTURA-   ---FECHA---   -NOMBRE"+;
         " DEL CLIENTE-    TOTAL FACTURA   SALDO FACTURA"},::aLS[8],::aLS[4],2 )
While nL > 0
   oApl:nSaldo := aRes[10]
   Vence( ::aLS[3]- aRes[6],@aVence )
      oRpt:Titulo( 136 )
   If oRpt:nPage >= oRpt:nPagI .AND. ::aLS[5] == "N"
      If aGT[1,5] == 0
         aRes[8] := Telefono( .f.,aRes[8],"" )
         oRpt:Say( oRpt:nL  ,01,cQry )
         oRpt:Say( oRpt:nL+1,05,aRes[8] )
      EndIf
      oRpt:Say( oRpt:nL, 50,STR(aRes[4])+aRes[5] )
      oRpt:Say( oRpt:nL, 63,NtChr( aRes[6],"2" ) )
      oRpt:Say( oRpt:nL, 77,aRes[7],20 )
      oRpt:Say( oRpt:nL,100,TRANSFORM(aRes[09],cPict) )
      oRpt:Say( oRpt:nL,116,TRANSFORM(aRes[10],cPict) )
      oRpt:nL ++
   EndIf
   aGT[1,3] ++
   aGT[1,5] += aRes[10]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aRes[1] # ::aLS[2]
      oRpt:Titulo( 136 )
      If oRpt:nPage >= oRpt:nPagI
         AEVAL( aVence, {|nVal,nP| aGT[2][nP] += nVal } )
         If ::aLS[5] == "N"
            oRpt:Say(++oRpt:nL, 97,"TOTAL CLIENTE --> $"+oRpt:CPIBold,,,1 )
            oRpt:Say(  oRpt:nL,116,TRANSFORM( aGT[1,5],cPict )+oRpt:CPIBoldN )
         Else
            oRpt:Say(  oRpt:nL,01,cQry,,,1 )
            oRpt:Say(  oRpt:nL,116,TRANSFORM( aGT[1,5],cPict ) )
            oRpt:nL ++
         //   Vence( 0,aVence,50,oRpt )
         EndIf
      EndIF
      oRpt:nL += 2
      If ::aLS[1] > 0
         aGT[1,2] += aGT[1,5]
      EndIf
      AFILL( aVence,0 )
      aGT[1,4] ++
      aGT[1,3] := aGT[1,5] := 0
      ::aLS[2] := aRes[1]
      ::aLS[1] := aRes[2]
      cQry   := PADR(aRes[1],36) + " " + FormatoNit( aRes[2],aRes[3] )
   EndIf
EndDo
MSFreeResult( hRes )
If aGT[1,4] > 0
   FOR nL := 1 TO 6
      aVence[nL] := aGT[2,nL]
   NEXT
   oRpt:Titulo( 136 )
   oRpt:Say(  oRpt:nL, 01,REPLICATE("_",136),,,1 )
   oRpt:Say(++oRpt:nL, 01,STR( aGT[1,4],3 ) + "  SALDOS",,,1 )
   oRpt:Say(  oRpt:nL,116,TRANSFORM(aGT[2,6],cPict) )
   oRpt:Say(++oRpt:nL, 01,REPLICATE("_",136),,,1 )
   oRpt:Separator( 2,10 )
   oRpt:Say( oRpt:nL  ,10,"TOTAL EMPRESAS ------------> $" + NtChr( aGT[1,2],cPict ) )
   oRpt:Say( oRpt:nL+2,10,"TOTAL CUENTAS POR COBRAR --> $" + NtChr( aGT[2,6],cPict ) )
   oRpt:nL += 4
   Vence( 0,aVence,10,oRpt )
EndIf
oRpt:NewPage()
oRpt:End()
::aLS[1] := 0
RETURN NIL

//------------------------------------//
METHOD LaserSal( nL,hRes ) CLASS TCarte
   LOCAL aLC, aRes, aGT := ARRAY(2,6), aVence := ARRAY(6)
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit      ,;
             "REPORTE DE CUENTAS POR COBRAR",NtChr( ::aLS[3],"3" )  ,;
             { .T., 9.4,"FACTURA" }           , { .F.,10.0,"F E C H A" }    ,;
             { .F.,11.7,"NOMBRE DEL CLIENTE" }, { .T.,18.0,"TOTAL FACTURA" },;
             { .T.,20.5,"SALDO FACTURA" } }
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   ::aLS[2] := aRes[1]
     aLC    := { FormatoNit( aRes[2],aRes[3] ),0,"999,999,999.99" }
AEVAL( aGT, {|x| AFILL( x,0 ) } )
AFILL( aVence,0 )
  ::Init( ::aEnc[4], .f. ,, !::aLS[8] ,,, ::aLS[8], 5 )
 ::nMD := 20.5
  PAGE
While nL > 0
   oApl:nSaldo := aRes[10]
   Vence( ::aLS[3]- aRes[6],@aVence )
   If ::aLS[5] == "N"
      ::Cabecera( .t.,0.42 )
      If aGT[1,5] == 0
          aLC[2] := ::nLinea + 0.5
         aRes[8] := Telefono( .f.,aRes[8],"" )
         UTILPRN ::oUtil Self:nLinea, 0.5 SAY LEFT(::aLS[2],36)
         UTILPRN ::oUtil Self:nLinea, 5.9 SAY aLC[1]
         UTILPRN ::oUtil      aLC[2], 2.0 SAY aRes[8]
      EndIf
      UTILPRN ::oUtil Self:nLinea, 9.4 SAY STR(aRes[4])+aRes[5]         RIGHT
      UTILPRN ::oUtil Self:nLinea, 9.7 SAY NtChr( aRes[6],"2" )
      UTILPRN ::oUtil Self:nLinea,11.7 SAY LEFT( aRes[7],20 )
      UTILPRN ::oUtil Self:nLinea,18.0 SAY TRANSFORM( aRes[09],aLC[3] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aRes[10],aLC[3] ) RIGHT
   EndIf
   aGT[1,3] ++
   aGT[1,5] += aRes[10]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aRes[1] # ::aLS[2]
      AEVAL( aVence, {|nVal,nP| aGT[2][nP] += nVal } )
      If ::aLS[5] == "N"
         ::Cabecera( .t.,0.84 )
         UTILPRN ::oUtil SELECT ::aFnt[6]
         UTILPRN ::oUtil Self:nLinea,15.2 SAY "TOTAL CLIENTE --> $"
         UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aGT[1,5],aLC[3] ) RIGHT
         UTILPRN ::oUtil SELECT ::aFnt[5]
      Else
         ::Cabecera( .t.,0.42 )
         UTILPRN ::oUtil Self:nLinea, 0.5 SAY LEFT(::aLS[2],36)
         UTILPRN ::oUtil Self:nLinea, 5.7 SAY aLC[1]
         UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aGT[1,5],aLC[3] ) RIGHT
         //   Vence( 0,aVence,50,oRpt )
      EndIF
      ::nLinea += 0.42
      If ::aLS[1] > 0
         aGT[1,2] += aGT[1,5]
      EndIf
      AFILL( aVence,0 )
      aGT[1,4] ++
      aGT[1,3] := aGT[1,5] := 0
      ::aLS[2] := aRes[1]
      ::aLS[1] := aRes[2]
        aLC[1] := FormatoNit( aRes[2],aRes[3] )
   EndIf
EndDo
MSFreeResult( hRes )
If aGT[1,4] > 0
   FOR nL := 1 TO 6
      aVence[nL] := aGT[2,nL]
   NEXT
   ::Cabecera( .t.,0.1,3.26,20.5 )
   UTILPRN ::oUtil Self:nLinea, 0.6 SAY STR( aGT[1,4],3 ) + "  SALDOS"
   UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aGT[2,6],aLC[3] ) RIGHT
   ::nLinea += 0.84
   UTILPRN ::oUtil Self:nLinea, 2.0 SAY "TOTAL EMPRESAS ------------> $"
   UTILPRN ::oUtil Self:nLinea, 9.0 SAY TRANSFORM( aGT[1,2],aLC[3] ) RIGHT
   ::nLinea += 0.84
   UTILPRN ::oUtil Self:nLinea, 2.0 SAY "TOTAL CUENTAS POR COBRAR --> $"
   UTILPRN ::oUtil Self:nLinea, 9.0 SAY TRANSFORM( aGT[2,6],aLC[3] ) RIGHT

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
 ::aLS[1] := 0
RETURN NIL

//------------------------------------//
PROCEDURE ListoCan( aLS,aTF )
   LOCAL aCan := { 0,0,0,0 }, oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"REPORTE DE FACTURAS CANCELADAS",;
         "EN " + NtChr( aLS[3],"6" ),SPACE(10) + "--FACTURA-   FECHA "+;
         "CANCELACION      VALOR FACTURA   LENTE CONTACTO"},aLS[8]    ,;
         aLS[4],1,oApl:aPapel[aLS[9],2] )
oApl:oFac:Seek( {"empresa",oApl:nEmpresa,"YEAR(fechacan)",YEAR(aLS[3]),;
                 "MONTH(fechacan)",MONTH(aLS[3]),"tipo",oApl:Tipo,"indicador","C"} )
While !oApl:oFac:Eof()
   aCan[4] := 0
   oApl:oVen:dbEval( {|o| aCan[4] += o:PRECIOVEN + o:MONTOIVA },;
                     {"empresa",oApl:nEmpresa,"numfac",oApl:oFac:NUMFAC,;
                      "tipo",oApl:Tipo,"indicador NOT IN ","('A','D')",;
                      "LEFT(codigo,2) >= ","60" } )
   oRpt:Titulo( 76 )
   If oRpt:nPage >= oRpt:nPagI
      oRpt:Say( oRpt:nL,10,STR(oApl:oFac:NUMFAC) )
      oRpt:Say( oRpt:nL,27,NtChr( oApl:oFac:FECHACAN,"2" ) )
      oRpt:Say( oRpt:nL,45,TRANSFORM(oApl:oFac:TOTALFAC,"999,999,999.99") )
      oRpt:Say( oRpt:nL,62,TRANSFORM(aCan[4] ,  "@Z 999,999,999.99") )
   EndIf
   oRpt:nL++
   aCan[1] ++
   aCan[2] += oApl:oFac:TOTALFAC
   aCan[3] += aCan[4]
   oApl:oFac:Skip(1):Read()
   oApl:oFac:xLoad()
EndDo
If aCan[1] > 0
   oRpt:Say(  oRpt:nL,01,REPLICATE("_",76),,,1 )
   oRpt:Say(++oRpt:nL,01,STR(aCan[1])+" TOTAL FACTURAS CANCELADAS :",,,1 )
   oRpt:Say(  oRpt:nL,43,TRANSFORM(aCan[2],"9,999,999,999.99") )
   oRpt:Say(  oRpt:nL,60,TRANSFORM(aCan[3],"9,999,999,999.99") )
EndIf
oRpt:NewPage()
oRpt:End()
RETURN

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