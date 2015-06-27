// Programa.: JVMLIEXT.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Extracto de un Cliente
#include "FiveWin.ch"
#include "btnget.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE CaoLiExt( nOpc )
   LOCAL aTF, aVT, oLF, oNi, oDlg, oGet := ARRAY(11)
   DEFAULT nOpc := 1
aTF := TipoFac( .t. )
oLF := TExtra()
oNi := TNits() ; oNi:New()
oLF:aLS[10] := LEN( aTF ) -1
aVT := { { {|| oLF:ListoExt( aTF ) },"Extracto de un Cliente" },;
         { {|| oLF:ListoVet( aTF ) },"Venta por Cliente" }     ,;
         { {|| oLF:ListoCod( aTF ) },"Venta por Cliente con Codigo" } }
DEFINE DIALOG oDlg TITLE aVT[nOpc,2] FROM 0, 0 TO 15,50
   @ 02,00 SAY "Nit o C.C. del Cliente" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02,92 BTNGET oGet[1] VAR oLF:aLS[1] OF oDlg PICTURE "999999999999";
      VALID EVAL( {|| If( nOpc == 2 .AND. EMPTY( oLF:aLS[1] ), .t.    ,;
                     (If( oNi:oDb:Seek( {"codigo",oLF:aLS[1]} )       ,;
                        ( oGet[09]:Settext( oNi:oDb:NOMBRE), .t. )    ,;
                        ( MsgStop("Este Nit no Existe"), .f.) )) ) } ) ;
      RESOURCE "BUSCAR"                            SIZE 58,10 PIXEL    ;
      ACTION EVAL({|| If(oNi:Mostrar(), (oLF:aLS[1] := oNi:oDb:CODIGO ,;
                         oGet[1]:Refresh() ), ) })
   @ 14,40 SAY oGet[9] VAR oLF:aLS[9] OF oDlg PIXEL SIZE 130,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 26,00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 26,92 GET oGet[2] VAR oLF:aLS[2] OF oDlg  SIZE 40,10 PIXEL
   @ 38,00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 38,92 GET oGet[3] VAR oLF:aLS[3] OF oDlg ;
      VALID oLF:aLS[3] >= oLF:aLS[2] SIZE 40,10 PIXEL
   @ 50,00 SAY "PAGINA INICIAL"           OF oDlg RIGHT PIXEL SIZE 90,10
   @ 50,92 GET oGet[4] VAR oLF:aLS[4] OF oDlg PICTURE "999";
      VALID Rango( oLF:aLS[4],1,999 ) ;
      WHEN nOpc  # 1         SIZE 24,10 PIXEL
   @ 62,00 SAY "DESEA  UN  RESUMEN [S/N]" OF oDlg RIGHT PIXEL SIZE 86,10
   @ 62,92 GET oGet[5] VAR oLF:aLS[5] OF oDlg PICTURE "!";
      VALID If( oLF:aLS[5] $ "NS", .t., .f. ) ;
      WHEN nOpc == 2         SIZE 08,10 PIXEL
   @ 74,00 SAY "TIPO DE FACTURA"          OF oDlg RIGHT PIXEL SIZE 90,10
   @ 74,92 COMBOBOX oGet[6] VAR oLF:aLS[6] ITEMS aTF SIZE 40,99 OF oDlg PIXEL
   @ 86,00 SAY "TIPO DE IMPRESORA"    OF oDlg RIGHT PIXEL SIZE 90,10
   @ 86,92 COMBOBOX oGet[7] VAR oLF:aLS[7] ITEMS { "Matriz","Laser" };
      SIZE 40,90 OF oDlg PIXEL
   @ 86,150 CHECKBOX oGet[8] VAR oLF:aLS[8] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 100, 50 BUTTON oGet[10] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[10]:Disable(), EVAL( aVT[nOpc,1] ), oDlg:End() ) PIXEL
   @ 100,110 BUTTON oGet[11] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 106, 02 SAY "[JVMLIEXT]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT Empresa()
RETURN

//------------------------------------//
CLASS TExtra FROM TIMPRIME

 DATA aLS  AS ARRAY INIT { 0,NtChr( LEFT( DTOS(DATE()),6 ),"F" ),;
                           DATE(),1,"N",1,oApl:nTFor,.t.,"",0 }
 METHOD CrearExt( cQry )
 METHOD ListoExt( aTF )
 METHOD LaserExt( aVence,hRes,nL )
 METHOD ListoVet( aTF )
 METHOD LaserVet( hRes,nL )
 METHOD ListoCod( aTF )
 METHOD LaserCod( hRes,nL )
ENDCLASS

//------------------------------------//
METHOD CrearExt( cQry ) CLASS TExtra
MSQuery( oApl:oMySql:hConnect,"DROP TABLE extracli" )
If cQry # NIL
   cQry := "CREATE TEMPORARY TABLE extracli ( "   +;
               "fecha    DATE         NOT NULL, " +;
               "numfac   INT(10)      NOT NULL, " +;
               "tipo     CHAR(1)      NOT NULL, " +;
               "clase    CHAR(1)      NOT NULL, " +;
               "cliente  VARCHAR(40)  NOT NULL, " +;
               "debito   DOUBLE(12,2), "          +;
               "credito  DOUBLE(12,2) ) "         +;
           " ENGINE=MEMORY"
   MSQuery( oApl:oMySql:hConnect,cQry )
EndIf
RETURN NIL

//------------------------------------//
METHOD ListoExt( aTF ) CLASS TExtra
   LOCAL aRes, cQry, hRes, nL
   LOCAL aVence := ARRAY(9), oRpt
 ::aLS[1] := oApl:oNit:CODIGO_NIT
 ::aLS[9] := If( ::aLS[4] <= ::aLS[10], " AND tipo       = '"+ aTF[::aLS[4]] + "'", "" )
If DAY( ::aLS[2] ) > 1
   ::aLS[2] := NtChr( LEFT( DTOS( ::aLS[2] ),6 ),"F" )
EndIf
 ::CrearExt( "C" )
// Introducimos datos en el cursor
cQry := "INSERT INTO extracli (fecha, numfac, tipo, clase, cliente, debito) "  +;
        "SELECT fechoy, numfac, tipo, 'F', cliente, totalfac -IFNULL(retfte,0)"+;
                   " - IFNULL(retica,0) - IFNULL(retiva,0) - IFNULL(retcre,0) "+;
        "FROM cadfactc "                                 +;
        "WHERE empresa    = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND codigo_nit = " + LTRIM(STR( ::aLS[1] ) )  +;
         " AND fechoy    >= " + xValToChar( ::aLS[2] )   +;
         " AND fechoy    <= " + xValToChar( ::aLS[3] )   + ::aLS[9] +;
         " AND indicador <> 'A'"
MSQuery( oApl:oMySql:hConnect,cQry )

cQry := "INSERT INTO extracli (fecha, numfac, tipo, clase, cliente, credito) "+;
        "SELECT p.fecpag, p.numfac, p.tipo, p.tipo_pag, "  +;
        "CONCAT(p.tipo_pag, '_', p.documento), p.pagado "  +;
        "FROM cadfactc c, cadpagos p "                     +;
        "WHERE c.codigo_nit = " + LTRIM(STR( ::aLS[1] ) )  +;
         " AND c.indicador <> 'A'"                         +;
         " AND c.empresa    = p.empresa"                   +;
         " AND c.numfac     = p.numfac"                    +;
         " AND c.tipo       = p.tipo"                      +;
         " AND p.empresa    = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND p.fecpag    >= " + xValToChar( ::aLS[2] )   +;
         " AND p.fecpag    <= " + xValToChar( ::aLS[3] )   +;
         STRTRAN( ::aLS[9],"ti", "p.ti" )
If !MSQuery( oApl:oMySql:hConnect,cQry )
   oApl:oMySql:oError:Display( .f. )
Else
   hRes := MSStoreResult( oApl:oMySql:hConnect )
   nL   := MSAffectedRows( oApl:oMySql:hConnect )
   MSFreeResult( hRes )
EndIf

AFILL( aVence,0 )
// Saldo Anterior
cQry := "SELECT c.fechoy, s.saldo "                        +;
        "FROM cadfactm s, cadfactc c "                     +;
        "WHERE c.empresa    = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fechoy    <= " + xValToChar( ::aLS[3] )   +;
         " AND c.codigo_nit = " + LTRIM(STR( ::aLS[1] ) )  +;
         STRTRAN( ::aLS[9],"ti", "c.ti" )                  +;
         " AND c.indicador <> 'A'"                                      +;
         " AND s.empresa = c.empresa"                                   +;
         " AND s.numfac  = c.numfac AND s.tipo = c.tipo"                +;
         " AND s.anomes  = (SELECT MAX(m.anomes) FROM cadfactm m "      +;
                           "WHERE m.empresa = c.empresa"                +;
                            " AND m.numfac  = c.numfac"                 +;
                            " AND m.tipo    = c.tipo"                   +;
                            " AND m.anomes <= '" + NtChr( ::aLS[3],"1" )+;
       "') AND s.saldo <> 0"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aVence[7]   += aRes[2]
   oApl:nSaldo := aRes[2]
   Vence( ::aLS[3] - aRes[1],@aVence )
   nL --
EndDo
   MSFreeResult( hRes )

cQry := "UPDATE extracli SET debito = credito, credito = 0 "+;
        "WHERE clase = 'D'"
MSQuery( oApl:oMySql:hConnect,cQry )

aVence[7] += Buscar( "SELECT SUM(credito) - SUM(debito) FROM extracli","CM",,8,,4 )
 ::aLS[10] := aVence[7]

cQry := "SELECT * FROM extracli ORDER BY fecha, numfac"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   ::CrearExt()
   RETURN NIL
ElseIf ::aLS[7] == 2
   ::LaserExt( aVence,hRes,nL )
   ::CrearExt()
   RETURN NIL
EndIf

oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"EXTRACTO DE CUENTAS POR COBRAR" ,;
         ALLTRIM( oApl:oNit:NOMBRE ) + "  DESDE " + NtChr( ::aLS[2],"2" )+;
         " HASTA " + NtChr( ::aLS[3],"2" ),"-F E C H A- DOCUMENTO ----"  +;
         "DESCRIPCION-----     DEBITOS    CREDITOS  -S A L D O-"},::aLS[8] )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   ::aLS[10] += aRes[6] - aRes[7]
   oRpt:Titulo( 79 )
   oRpt:Say( oRpt:nL,00,NtChr( aRes[1],"2" ) )
   oRpt:Say( oRpt:nL,12,STR(aRes[2],8) )
   oRpt:Say( oRpt:nL,22,aRes[5] )
   oRpt:Say( oRpt:nL,43,TRANSFORM( aRes[6],"@Z 999,999,999") )
   oRpt:Say( oRpt:nL,55,TRANSFORM( aRes[7],"@Z 999,999,999") )
   oRpt:Say( oRpt:nL,68,TRANSFORM(::aLS[10],  "999,999,999") )
   oRpt:nL ++
   aVence[8] += aRes[6]
   aVence[9] += aRes[7]
   nL --
EndDo
   MSFreeResult( hRes )
If oRpt:nPage > 0
   oRpt:Separator( 0,8 )
   oRpt:Say( oRpt:nL++,29,REPLICATE("=",50) )
   oRpt:Say( oRpt:nL++,29,"SALDO ANTER   TOT.DEBITOS TOT.CREDITO  NUEVO SALDO" )
   oRpt:Say( oRpt:nL  ,29,TRANSFORM( aVence[7],"999,999,999") )
   oRpt:Say( oRpt:nL  ,43,TRANSFORM( aVence[8],"999,999,999") )
   oRpt:Say( oRpt:nL  ,55,TRANSFORM( aVence[9],"999,999,999") )
   oRpt:Say( oRpt:nL++,68,TRANSFORM( ::aLS[10],"999,999,999") )
   oRpt:nL ++
   oRpt:Say( oRpt:nL++,25,"* * *  V E N C I M I E N T O S  * * *" )
   Vence( 0,aVence,10,oRpt )
EndIf
oRpt:NewPage()
oRpt:End()
 ::CrearExt()
RETURN NIL

//------------------------------------//
METHOD LaserExt( aVence,hRes,nL ) CLASS TExtra
   LOCAL aRes
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit                     ,;
             "EXTRACTO DE CUENTAS POR COBRAR"                      ,;
             ALLTRIM( oApl:oNit:NOMBRE ) + "  DESDE "              +;
             NtChr( ::aLS[2],"2" )+" HASTA "+ NtChr( ::aLS[3],"2" ),;
             { .F., 0.8,"F E C H A" }  , { .F., 3.0,"DOCUMENTO" },;
             { .F., 5.5,"DESCRIPCION" }, { .T.,14.5,"DEBITOS" }  ,;
             { .T.,17.5,"CREDITOS" }   , { .T.,20.5,"S A L D O" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[8] ,,, ::aLS[8] )
 ::nMD := 20.5
  PAGE
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   ::aLS[10] += aRes[6] - aRes[7]
   ::Cabecera( .t.,0.42 )
   UTILPRN ::oUtil Self:nLinea, 0.6 SAY NtChr( aRes[1],"2" )
   UTILPRN ::oUtil Self:nLinea, 4.0 SAY STR(aRes[2],8)
   UTILPRN ::oUtil Self:nLinea, 5.5 SAY aRes[5]
   UTILPRN ::oUtil Self:nLinea,14.5 SAY TRANSFORM( aRes[6],"@Z 999,999,999") RIGHT
   UTILPRN ::oUtil Self:nLinea,17.5 SAY TRANSFORM( aRes[7],"@Z 999,999,999") RIGHT
   UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM(::aLS[10],  "999,999,999") RIGHT
   aVence[8] += aRes[6]
   aVence[9] += aRes[7]
   nL --
EndDo
   MSFreeResult( hRes )
   ::Cabecera( .t.,0.42,3.78,20.5 )
   UTILPRN ::oUtil Self:nLinea,11.5 SAY "SALDO ANTER" RIGHT
   UTILPRN ::oUtil Self:nLinea,14.5 SAY "TOT.DEBITOS" RIGHT
   UTILPRN ::oUtil Self:nLinea,17.5 SAY "TOT.CREDITO" RIGHT
   UTILPRN ::oUtil Self:nLinea,20.5 SAY "NUEVO SALDO" RIGHT
   ::nLinea += 0.42
   UTILPRN ::oUtil Self:nLinea,11.5 SAY TRANSFORM(aVence[7],"999,999,999") RIGHT
   UTILPRN ::oUtil Self:nLinea,14.5 SAY TRANSFORM(aVence[8],"999,999,999") RIGHT
   UTILPRN ::oUtil Self:nLinea,17.5 SAY TRANSFORM(aVence[9],"999,999,999") RIGHT
   UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM(::aLS[10],"999,999,999") RIGHT
   ::nLinea += 0.84
   UTILPRN ::oUtil Self:nLinea,10.5 SAY "* * *  V E N C I M I E N T O S  * * *"
   ::nLinea += 0.42
   aRes := { "A 15 Dias","A 30 Dias","A 45 Dias","A 60 Dias","Sobre 60 Dias",;
             ::nLinea+0.42, 8.0 }
   FOR nL := 1 TO 5
      UTILPRN ::oUtil Self:nLinea, aRes[7] SAY aRes[nL]                            RIGHT
      UTILPRN ::oUtil aRes[6]    , aRes[7] SAY TRANSFORM(aVence[nL],"999,999,999") RIGHT
      If aVence[6]  > 0
         aVence[nL] := ROUND( aVence[nL]/aVence[6]*100,2 )
         UTILPRN ::oUtil aRes[6]+0.42, aRes[7] SAY TRANSFORM(aVence[nL],"999.99%") RIGHT
      EndIf
      aRes[7] += 3
   NEXT nL
  ENDPAGE
 ::EndInit( .F. )
RETURN NIL

//------------------------------------//
METHOD ListoVet( aTF ) CLASS TExtra
   LOCAL oRpt, aGT := { 0,0,0,0,0,"99,999,999,999.99" }
   LOCAL aRes, hRes, nL, cQry
cQry := "SELECT n.nombre, n.codigo, n.digito, f.numfac, "+;
               "f.fechoy, f.cliente, f.totalfac, f.tipo "+;
        "FROM cadfactc f, cadclien n "                   +;
        "WHERE f.empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
         " AND f.fechoy >= " + xValToChar( ::aLS[2] )    +;
         " AND f.fechoy <= " + xValToChar( ::aLS[3] )    + If( ::aLS[6] <= ::aLS[10],;
         " AND f.tipo   = '" + aTF[::aLS[6]] + "'", "" )   +;
         " AND f.indicador <> 'A'" +     If( ::aLS[1] > 0  ,;
         " AND f.codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT)), "" ) +;
         " AND n.codigo_nit = f.codigo_nit"              +;
         " ORDER BY n.nombre, f.fechoy, f.numfac"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[7] == 2
   ::LaserVet( hRes,nL )
   RETURN NIL
EndIf
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   ::aLS[1] := aRes[2]
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"REPORTE DE TOTAL DE VENTAS"        ,;
         "DESDE " + NtChr( ::aLS[2],"2" ) + " HASTA " + NtChr( ::aLS[3],"2" ),;
         SPACE(50)+ "--FACTURA-   FECHA FACT.   -NOMBRE DEL CLIENTE-     "+;
         "TOTAL  FACTURA     SALDO  FACTURA"},::aLS[8],::aLS[4],2 )
While nL > 0
   oRpt:Titulo( 135 )
   If aGT[2] == 0 .AND. oRpt:nPage >= oRpt:nPagI
      oRpt:Say( oRpt:nL,01,aRes[1] )
      oRpt:Say( oRpt:nL,35,FormatoNit( aRes[2],aRes[3] ) )
   EndIf
   If oRpt:nPage >= oRpt:nPagI .AND. ::aLS[5] == "N"
      aGT[5] := SaldoFac( aRes[4],aRes[8] )
      oRpt:Say( oRpt:nL, 50,STR(aRes[4],9)+aRes[8] )
      oRpt:Say( oRpt:nL, 63,NtChr( aRes[5],"2" ) )
      oRpt:Say( oRpt:nL, 77,aRes[6],20 )
      oRpt:Say( oRpt:nL, 99,TRANSFORM(aRes[7],aGT[6]) )
      oRpt:Say( oRpt:nL,118,TRANSFORM( aGT[5],aGT[6]) )
      oRpt:nL ++
   EndIf
   aGT[2] += aRes[7]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aRes[2] # ::aLS[1]
      If oRpt:nPage >= oRpt:nPagI
         oRpt:Say( oRpt:nL+1,77,"TOTAL CLIENTE --> $"+oRpt:CPIBold,,,1 )
         oRpt:Say( oRpt:nL+1,99,TRANSFORM( aGT[2],aGT[6] )+oRpt:CPIBoldN )
      EndIF
      oRpt:nL += 3
      aGT[1] ++
      aGT[3] += If( ::aLS[1] > 1, aGT[2], 0 )
      aGT[4] += aGT[2]
      aGT[2] := 0
      ::aLS[1] := aRes[2]
   EndIf
EndDo
MSFreeResult( hRes )
   oRpt:Titulo( 135 )
   oRpt:Say(  oRpt:nL, 01,REPLICATE("_",134),,,1 )
   oRpt:Say(++oRpt:nL, 01,STR( aGT[1],3 ) + "  SALDOS",,,1 )
   oRpt:Say(  oRpt:nL, 99,TRANSFORM(aGT[4],aGT[6]) )
   oRpt:Say(++oRpt:nL, 01,REPLICATE("_",134),,,1 )
   oRpt:Separator( 2,3 )
   oRpt:Say( oRpt:nL  ,10,"TOTAL EMPRESAS ------------> $" + NtChr( aGT[3],aGT[6] ) )
   oRpt:Say( oRpt:nL+2,10,"TOTAL CUENTAS POR COBRAR --> $" + NtChr( aGT[4],aGT[6] ) )
   oRpt:NewPage()
   oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserVet( hRes,nL ) CLASS TExtra
   LOCAL aRes, aGT := { 0,0,0,0,0,"99,999,999,999.99" }
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit      ,;
             "REPORTE DE TOTAL DE VENTAS","DESDE " + ;
             NtChr( ::aLS[2],"2" ) + " HASTA " + NtChr( ::aLS[3],"2" ),;
             { .t., 9.4,"FACTURA" }           , { .F., 9.7,"F E C H A" }  ,;
             { .F.,11.7,"NOMBRE DEL CLIENTE" }, { .T.,18.0,"TOTAL FACTURA" },;
             { .T.,20.5,"SALDO FACTURA" } }
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   ::aLS[1] := aRes[2]
  ::Init( ::aEnc[4], .f. ,, !::aLS[8] ,,, ::aLS[8], 5 )
 ::nMD := 20.5
  PAGE
While nL > 0
   If ::aLS[5] == "N"
      ::Cabecera( .t.,0.42 )
      If aGT[2] == 0
         UTILPRN ::oUtil Self:nLinea, 0.5 SAY LEFT(aRes[1],36)
         UTILPRN ::oUtil Self:nLinea, 5.9 SAY FormatoNit( aRes[2],aRes[3] )
      EndIf
      aGT[5] := SaldoFac( aRes[4],aRes[8] )
      UTILPRN ::oUtil Self:nLinea, 9.4 SAY STR(aRes[4],9)+aRes[8]      RIGHT
      UTILPRN ::oUtil Self:nLinea, 9.7 SAY NtChr( aRes[5],"2" )
      UTILPRN ::oUtil Self:nLinea,11.7 SAY LEFT( aRes[6],20 )
      UTILPRN ::oUtil Self:nLinea,18.0 SAY TRANSFORM( aRes[7],aGT[6] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM(  aGT[5],aGT[6] ) RIGHT
   ElseIf aGT[2] == 0
      ::Cabecera( .t.,0.42 )
      UTILPRN ::oUtil Self:nLinea, 0.5 SAY LEFT(aRes[1],36)
      UTILPRN ::oUtil Self:nLinea, 5.7 SAY FormatoNit( aRes[2],aRes[3] )
   EndIf
   aGT[2] += aRes[7]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aRes[2] # ::aLS[1]
      ::Cabecera( .t.,0.42 )
      UTILPRN ::oUtil SELECT ::aFnt[6]
      UTILPRN ::oUtil Self:nLinea,15.2 SAY "TOTAL CLIENTE --> $"
      UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aGT[2],aGT[6] ) RIGHT
      UTILPRN ::oUtil SELECT ::aFnt[5]
      ::nLinea += 0.42
      aGT[1] ++
      aGT[3] += If( ::aLS[1] > 1, aGT[2], 0 )
      aGT[4] += aGT[2]
      aGT[2] := 0
      ::aLS[1] := aRes[2]
   EndIf
EndDo
MSFreeResult( hRes )
   ::Cabecera( .t.,0.1,3.26,20.5 )
   UTILPRN ::oUtil Self:nLinea, 0.6 SAY STR( aGT[1],3 ) + "  SALDOS"
   UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aGT[4],aGT[6] ) RIGHT
   ::nLinea += 0.84
   UTILPRN ::oUtil Self:nLinea, 2.0 SAY "TOTAL EMPRESAS ------------> $"
   UTILPRN ::oUtil Self:nLinea, 9.0 SAY TRANSFORM( aGT[3],aGT[6] ) RIGHT
   ::nLinea += 0.84
   UTILPRN ::oUtil Self:nLinea, 2.0 SAY "TOTAL CUENTAS POR COBRAR --> $"
   UTILPRN ::oUtil Self:nLinea, 9.0 SAY TRANSFORM( aGT[4],aGT[6] ) RIGHT
  ENDPAGE
 ::EndInit( .F. )
RETURN NIL

//------------------------------------//
METHOD ListoCod( aTF ) CLASS TExtra
   LOCAL aRes, aVT, cQry, hRes, nL, oRpt
cQry := "SELECT c.numfac, c.tipo, c.fechoy, d.codigo, i.descrip, d.cantidad, "+;
               "d.unidadmed, d.ppubli, d.precioven + d.montoiva "+;
        "FROM cadfactc c, cadfactd d LEFT JOIN cadinven i "+;
         "USING( codigo ) "                              +;
        "WHERE c.empresa = d.empresa"                    +;
         " AND c.numfac  = d.numfac"                     +;
         " AND c.tipo    = d.tipo"                       +;
         " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
         " AND c.fechoy >= " + xValToChar( ::aLS[2] )    +;
         " AND c.fechoy <= " + xValToChar( ::aLS[3] )    + If( ::aLS[6] <= ::aLS[10],;
         " AND c.tipo   = '" + aTF[::aLS[6]] + "'", "" ) +;
         " AND c.codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT)) +;
         " AND c.indicador <> 'A'"                       +;
         " ORDER BY c.numfac, c.tipo, i.descrip"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[7] == 2
   ::LaserCod( hRes,nL )
   RETURN NIL
EndIf
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aVT  := { aRes[1],aRes[2],.t. }
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"VENTAS A "+oApl:oNit:NOMBRE         ,;
         "DESDE " + NtChr( ::aLS[2],"2" ) + " HASTA " + NtChr( ::aLS[3],"2" ) ,;
         "--FACTURA --F E C H A CODIGO---- D E S C R I P C I O N---------"+;
         " --CANTIDAD     V. UNITARIO"},::aLS[8],::aLS[4],2 )
While nL > 0
   oRpt:Titulo( 90 )
   If aVT[3]
      aVT[3] := .f.
      oRpt:Say( oRpt:nL,00,STR(aRes[1],8)+aRes[2] )
      oRpt:Say( oRpt:nL,10,NtChr( aRes[3],"2" ) )
   EndIf
   If aRes[8] <= 0
      aRes[8] := ROUND( aRes[9] / aRes[6],0 )
   EndIf
   oRpt:Say( oRpt:nL,22,aRes[4] )
   oRpt:Say( oRpt:nL,33,aRes[5],30 )
   oRpt:Say( oRpt:nL,64,TRANSFORM(aRes[6],"999,999.99" ))
   oRpt:Say( oRpt:nL,75,aRes[7] )
   oRpt:Say( oRpt:nL,79,TRANSFORM(aRes[8],"999,999,999" ))
   oRpt:nL ++
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aVT[1] # aRes[1] .OR. aVT[2] # aRes[2]
      oRpt:Say(  oRpt:nL,22,REPLICATE("_",68),,,1 )
      oRpt:nL ++
      aVT  := { aRes[1],aRes[2],.t. }
   EndIf
EndDo
MSFreeResult( hRes )
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserCod( hRes,nL ) CLASS TExtra
   LOCAL aRes, aVT
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit      ,;
             "VENTAS A "+oApl:oNit:NOMBRE ,"DESDE " +;
             NtChr( ::aLS[2],"2" ) + " HASTA " + NtChr( ::aLS[3],"2" ),;
             { .T., 2.0,"FACTURA" } , { .F., 2.3,"F E C H A" }        ,;
             { .F., 4.0,"CODIGO" }  , { .F., 6.0,"D E S C R I P C I O N" },;
             { .T.,17.3,"CANTIDAD" }, { .T.,20.0,"V. UNITARIO" } }
aRes := MyReadRow( hRes )
AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
aVT  := { aRes[1],aRes[2],.t. }
 ::Init( ::aEnc[4], .f. ,, !::aLS[8] ,,, ::aLS[8], 5 )
  PAGE
While nL > 0
   If aRes[8] <= 0
      aRes[8] := ROUND( aRes[9] / aRes[6],0 )
   EndIf
      ::Cabecera( .t.,0.42 )
   If aVT[3]
      aVT[3] := .f.
      UTILPRN ::oUtil Self:nLinea, 2.0 SAY STR(aRes[1],9)+aRes[2]             RIGHT
      UTILPRN ::oUtil Self:nLinea, 2.2 SAY NtChr( aRes[3],"2" )
   EndIf
      UTILPRN ::oUtil Self:nLinea, 4.0 SAY aRes[4]
      UTILPRN ::oUtil Self:nLinea, 6.0 SAY LEFT( aRes[5],30 )
      UTILPRN ::oUtil Self:nLinea,17.3 SAY TRANSFORM( aRes[6],"999,999.99" )  RIGHT
      UTILPRN ::oUtil Self:nLinea,17.5 SAY aRes[7]
      UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM( aRes[8],"999,999,999" ) RIGHT
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aVT[1] # aRes[1] .OR. aVT[2] # aRes[2]
      aVT := { aRes[1],aRes[2],.t. }
     ::nLinea += 0.3
     UTILPRN ::oUtil LINEA Self:nLinea,4.0 TO Self:nLinea,20 PEN ::oPen
   EndIf
EndDo
MSFreeResult( hRes )
  ENDPAGE
 ::EndInit( .F. )
RETURN NIL