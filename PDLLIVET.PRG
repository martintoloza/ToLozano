// Programa.: CAOLIVET.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Total de venta por Cliente.
#include "FiveWin.ch"
#include "Btnget.ch"

MEMVAR oApl

PROCEDURE CaoLiVet( nOpc )
   LOCAL oDlg, oGet := ARRAY(10), oNi
   LOCAL aVT , aOpc := { DATE(),DATE(),1,"N",.t.,0,"",1 }
   DEFAULT nOpc := 1
oNi := TNits() ; oNi:New()
aVT := { { {|| ListoVet( aOpc ) },"Total de Venta por Cliente" }  ,;
         { {|| ListoCod( aOpc ) },"Venta por Cliente con Codigo" },;
         { {|| ListoMax( aOpc ) },"Fecha de la Ultima Compra" } }
DEFINE DIALOG oDlg TITLE aVT[nOpc,2] FROM 0, 0 TO 16,50
   @ 02, 00 SAY "Nit por Default Todos" OF oDlg RIGHT PIXEL SIZE 86,10
   @ 02, 88 BTNGET oGet[1] VAR aOpc[6] OF oDlg PICTURE "999999999999";
      VALID EVAL( {|| If( EMPTY( aOpc[6] ), .t.                   ,;
              (If( oNi:oDb:Seek( {"codigo",aOpc[6]} )             ,;
              ( oGet[10]:Settext( oNi:oDb:NOMBRE), .t. )          ,;
              ( MsgStop("Este Nit no Existe"),.f.)))) } )          ;
      SIZE 56,12 PIXEL  RESOURCE "BUSCAR"                          ;
      ACTION EVAL({|| If(oNi:Mostrar(), (aOpc[6] := oNi:oDb:CODIGO,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
   @ 16,10 SAY oGet[10] VAR aOpc[7] OF oDlg PIXEL SIZE 130,12 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 30, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 86,10
   @ 30, 88 GET oGet[2] VAR aOpc[1] OF oDlg  SIZE 40,12 PIXEL
   @ 44, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 86,10
   @ 44, 88 GET oGet[3] VAR aOpc[2] OF oDlg ;
      VALID aOpc[2] >= aOpc[1] SIZE 40,12 PIXEL
   @ 58, 00 SAY "PAGINA INICIAL"           OF oDlg RIGHT PIXEL SIZE 86,10
   @ 58, 88 GET oGet[4] VAR aOpc[3] OF oDlg PICTURE "999";
      VALID Rango( aOpc[3],1,999 )  SIZE 24,12 PIXEL
   @ 72, 00 SAY "DESEA  UN  RESUMEN [S/N]" OF oDlg RIGHT PIXEL SIZE 86,10
   @ 72, 88 GET oGet[5] VAR aOpc[4] OF oDlg PICTURE "!";
      VALID aOpc[4] $ "NS"  SIZE 08,12 PIXEL
   @ 86, 00 SAY "CLASE DE PAPEL"            OF oDlg RIGHT PIXEL SIZE 86,10
   @ 86, 88 COMBOBOX oGet[6] VAR aOpc[8] ITEMS ArrayCol( oApl:aPapel,1 );
      SIZE 46,99 OF oDlg PIXEL
   @ 86,138 CHECKBOX oGet[7] VAR aOpc[5] PROMPT "Vista Previa" OF oDlg;
       SIZE 60,12 PIXEL
   @ 102, 50 BUTTON oGet[8] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[8]:Disable(), EVAL( aVT[nOpc,1] ), oDlg:End() ) PIXEL
   @ 102,100 BUTTON oGet[9] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 108, 02 SAY "[CAOLIVET]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED NOMODAL
RETURN

//------------------------------------//
STATIC PROCEDURE ListoVet( aLS )
   LOCAL oRpt, aGT := { 0,0,0,0 }
   LOCAL aRes, hRes, nL, cQry, cPict := "99,999,999,999.99"
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"REPORTE DE TOTAL DE VENTAS"         ,;
         "DESDE " + NtChr( aLS[1],"2" ) + " HASTA " + NtChr( aLS[2],"2" ) ,;
         SPACE(50)+ "--FACTURA-   FECHA FACT.   -NOMBRE DEL CLIENTE-     "+;
         "TOTAL  FACTURA     SALDO  FACTURA"},aLS[5],aLS[3],2,oApl:aPapel[aLS[8],2] )
cQry := "SELECT n.nombre, n.codigo, n.digito, f.numfac, "        +;
               "f.fechoy, f.cliente, f.totalfac, s.saldo "       +;
        "FROM cadfactm s, cadfactu f LEFT JOIN cadclien n "      +;
         "USING( codigo_nit ) "                                  +;
        "WHERE f.empresa = " + LTRIM(STR(oApl:nEmpresa))         +;
         " AND f.fechoy >= " + xValToChar( aLS[1] )              +;
         " AND f.fechoy <= " + xValToChar( aLS[2] )              +;
         " AND f.tipo    = " + xValToChar( oApl:Tipo )           +;
         " AND f.indicador <> 'A'" +     If( aLS[6] > 0          ,;
         " AND f.codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT)), "" )+;
         " AND s.empresa = f.empresa"                            +;
         " AND s.numfac  = f.numfac AND s.tipo = f.tipo"         +;
         " AND s.anomes = (SELECT MAX(m.anomes) FROM cadfactm m "+;
                          "WHERE m.empresa = f.empresa"          +;
                           " AND m.numfac  = f.numfac"           +;
                           " AND m.tipo    = f.tipo"             +;
                           " AND m.anomes <= '" + NtChr( aLS[2],"1" )   +;
         "') ORDER BY n.nombre, f.fechoy, f.numfac"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aLS[6] := aRes[2]
EndIf
While nL > 0
   oRpt:Titulo( 135 )
   If aGT[2] == 0 .AND. oRpt:nPage >= oRpt:nPagI
      oRpt:Say( oRpt:nL,01,aRes[1] )
      oRpt:Say( oRpt:nL,35,FormatoNit( aRes[2],aRes[3] ) )
   EndIf
   If oRpt:nPage >= oRpt:nPagI .AND. aLS[4] == "N"
      oRpt:Say( oRpt:nL, 50,STR(aRes[4]) )
//       @ nLinea, 60 Say If( cTipo = "UD" .And. Tipo = "D", ".", " " )
      oRpt:Say( oRpt:nL, 63,NtChr( aRes[5],"2" ) )
      oRpt:Say( oRpt:nL, 77,aRes[6],20 )
      oRpt:Say( oRpt:nL, 99,TRANSFORM(aRes[7],cPict) )
      oRpt:Say( oRpt:nL,118,TRANSFORM(aRes[8],cPict) )
      oRpt:nL ++
   EndIf
   aGT[2] += aRes[7]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aRes[2] # aLS[6]
      If oRpt:nPage >= oRpt:nPagI
         oRpt:Say( oRpt:nL+1,77,"TOTAL CLIENTE --> $"+oRpt:CPIBold,,,1 )
         oRpt:Say( oRpt:nL+1,99,TRANSFORM( aGT[2],cPict )+oRpt:CPIBoldN )
      EndIF
      oRpt:nL += 3
      aGT[1] ++
      aGT[3] += If( aLS[6] > 0, aGT[2], 0 )
      aGT[4] += aGT[2]
      aGT[2] := 0
      aLS[6] := aRes[2]
   EndIf
EndDo
MSFreeResult( hRes )
If aGT[1] > 0
   oRpt:Titulo( 135 )
   oRpt:Say(  oRpt:nL, 01,REPLICATE("_",134),,,1 )
   oRpt:Say(++oRpt:nL, 01,STR( aGT[1],3 ) + "  SALDOS",,,1 )
   oRpt:Say(  oRpt:nL, 99,TRANSFORM(aGT[4],cPict) )
   oRpt:Say(++oRpt:nL, 01,REPLICATE("_",134),,,1 )
   oRpt:Separator( 2,3 )
   oRpt:Say( oRpt:nL  ,10,"TOTAL EMPRESAS ------------> $" + TRANSFORM( aGT[3],cPict ) )
   oRpt:Say( oRpt:nL+2,10,"TOTAL CUENTAS POR COBRAR --> $" + TRANSFORM( aGT[4],cPict ) )
EndIf
oRpt:NewPage()
oRpt:End()
RETURN

//------------------------------------//
STATIC PROCEDURE ListoCod( aLS )
   LOCAL aRes, hRes, nL, oRpt, aGT := { 0,0 }
aRes := "SELECT d.codigo, i.descrip, SUM(d.cantidad), SUM(d.precioven) "+;
        "FROM cadinven i, cadventa d, cadfactu c "      +;
        "WHERE d.codigo  = i.codigo"                    +;
         " AND c.empresa = d.empresa"                   +;
         " AND c.numfac  = d.numfac"                    +;
         " AND c.tipo    = d.tipo "                     +;
         " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fechoy >= " + xValToChar( aLS[1] )     +;
         " AND c.fechoy <= " + xValToChar( aLS[2] )     +;
         " AND c.tipo    = " + xValToChar(oApl:Tipo)    +;
         " AND c.codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT)) +;
         " AND c.indicador <> 'A'"                      +;
         " GROUP BY d.codigo ORDER BY d.codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"VENTAS A "+oApl:oNit:NOMBRE        ,;
         "DESDE " + NtChr( aLS[1],"2" ) + " HASTA " + NtChr( aLS[2],"2" ),;
         " CODIGO  D E S C R I P C I O N-------------------    CANTIDAD "+;
         "    VALOR VENTA"},aLS[5],aLS[3],1,oApl:aPapel[aLS[8],2] )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   oRpt:Titulo( 77 )
   oRpt:Say( oRpt:nL,01,aRes[1] )
   oRpt:Say( oRpt:nL,09,aRes[2] )
   oRpt:Say( oRpt:nL,51,TRANSFORM(aRes[3],    "999,999.99") )
   oRpt:Say( oRpt:nL,63,TRANSFORM(aRes[4],"999,999,999.99") )
   oRpt:nL++
   aGT[1] += aRes[3]
   aGT[2] += aRes[4]
   nL --
EndDo
MSFreeResult( hRes )
   oRpt:Say(  oRpt:nL,01,REPLICATE("_",76),,,1 )
   oRpt:Say(++oRpt:nL,51,TRANSFORM(aGT[1],    "999,999.99") )
   oRpt:Say(  oRpt:nL,63,TRANSFORM(aGT[2],"999,999,999.99") )
   oRpt:NewPage()
   oRpt:End()
RETURN

//------------------------------------//
STATIC PROCEDURE ListoMax( aLS )
   LOCAL aRes, hRes, nL, oRpt
MSQuery( oApl:oMySql:hConnect,"DROP TABLE ultcompra" )
aRes := "CREATE TEMPORARY TABLE ultcompra ( "   +;
            "codigo_nit INT(5)   NOT NULL, "    +;
            "fecha      DATE     NOT NULL )"    +;
        " ENGINE=MEMORY"
MSQuery( oApl:oMySql:hConnect,aRes )
aRes := "INSERT INTO ultcompra (codigo_nit, fecha) "  +;
        "SELECT codigo_nit, MAX(fechoy) "             +;
        "FROM cadfactu "                              +;
        "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND fechoy >= " + xValToChar( aLS[1]-730 ) +;
         " AND tipo    = " + xValToChar(oApl:Tipo)    +;
         " AND indicador <> 'A' GROUP BY codigo_nit"
If !MSQuery( oApl:oMySql:hConnect,aRes )
   oApl:oMySql:oError:Display( .f. )
   RETURN
Else
   hRes := MSStoreResult( oApl:oMySql:hConnect )
   nL   := MSAffectedRows( oApl:oMySql:hConnect )
   MSFreeResult( hRes )
   If nL == 0
      MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
      RETURN
   EndIf
 //MsgInfo( STR(nL)+" Registros Insertados" )
EndIf
aRes := "SELECT n.codigo, n.digito, n.nombre, fecha "+;
        "FROM ultcompra c LEFT JOIN cadclien n "     +;
        "USING( codigo_nit )  ORDER BY fecha"
/*
aRes := "SELECT n.codigo, n.digito, n.nombre, MAX(c.fechoy) FECHA "+;
        "FROM cadfactu c LEFT JOIN cadclien n "         +;
         "USING( codigo_nit ) "                         +;
        "WHERE c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fechoy >= " + xValToChar( aLS[1]-730 ) +;
         " AND c.tipo    = " + xValToChar(oApl:Tipo)    +;
         " AND c.indicador <> 'A' "                     +;
         "GROUP BY c.codigo_nit ORDER BY FECHA"
*/
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"FECHA DE LA ULTIMA COMPRA DE LOS CLIENTES"   ,;
         "DESDE " + NtChr( aLS[1]-730,"2" ) + " HASTA " + NtChr( aLS[2],"2" )      ,;
         "     NIT o CC     N O M B R R E---------------------------    ULT.FECHA"},;
         aLS[5],aLS[3],1,oApl:aPapel[aLS[8],2] )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   oRpt:Titulo( 76 )
   oRpt:Say( oRpt:nL,01,FormatoNit( aRes[1],aRes[2] ) )
   oRpt:Say( oRpt:nL,18,aRes[3] )
   oRpt:Say( oRpt:nL,62,NtChr( aRes[4],"2" ) )
   oRpt:nL++
   nL --
EndDo
MSFreeResult( hRes )
MSQuery( oApl:oMySql:hConnect,"DROP TABLE ultcompra" )
   oRpt:NewPage()
   oRpt:End()
RETURN