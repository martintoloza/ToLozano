// Programa.: CAOLIPED.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listado de Pedidos para Produccion
#include "FiveWin.ch"

MEMVAR oApl

PROCEDURE CaoLiPed()
   LOCAL oDlg, oGet := ARRAY(5), aOpc := { DATE(),.f.,1 }

DEFINE DIALOG oDlg TITLE "Listar Pedidos de Produccion" FROM 0, 0 TO 08,50
   @ 02, 00 SAY "FECHA DESEADA [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 86,10
   @ 02, 88 GET oGet[1] VAR aOpc[1] OF oDlg  SIZE 44,12 PIXEL
   @ 16, 00 SAY "CLASE DE PAPEL"           OF oDlg RIGHT PIXEL SIZE 86,10
   @ 16, 88 COMBOBOX oGet[2] VAR aOpc[3] ITEMS ArrayCol( oApl:aPapel,1 );
      SIZE 46,99 OF oDlg PIXEL
   @ 16,138 CHECKBOX oGet[3] VAR aOpc[2] PROMPT "Vista &Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 32, 50 BUTTON oGet[4] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[4]:Disable(), ListoPed( aOpc ), oDlg:End() ) PIXEL
   @ 32,100 BUTTON oGet[5] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 38, 02 SAY "[CAOLIPED]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED

RETURN

//------------------------------------//
STATIC PROCEDURE ListoPed( aLS )
   LOCAL aRpt, cT := "Codigo  D e s c r i p c i o n                     Cantid."
   LOCAL aRes, hRes, cQry, nL, nD, nK
aRpt := TDosPrint()
aRpt:New( oApl:cPuerto,oApl:cImpres,{"LISTADO DE PEDIDOS PARA PRODUCCION",;
           NtChr( aLS[1],"3" ) },aLS[2],,1,oApl:aPapel[aLS[3],2] )
cQry := "SELECT n.nombre, c.remision, c.fechoy, c.hora, c.cliente, c.tomadop, c.nota "+;
        "FROM cadcajac c, cadclien n "              +;
        "WHERE c.fechaent = " + xValToChar( aLS[1] )+;
         " AND c.tipo_p   = 'P' AND c.estado <> 2"  +;
         " AND n.codigo_nit = c.codigo_nit"         +;
         " ORDER BY n.nombre, c.remision"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) },1,6 )
   cQry := "SELECT d.codigo, i.descrip, d.cantidad "   +;
           "FROM cadcajad d, cadinven i "              +;
           "WHERE d.fechoy  = " + xValToChar( aRes[3] )+;
           " AND d.remision = " + xValToChar( aRes[2] )+;
           " AND d.tipo_p   = 'P' AND i.codigo = d.codigo"
   aLS := Buscar( cQry,"CM",,9 )
   If LEN( aLS ) == 0
      nL -- ; LOOP
   EndIf
   aRpt:Titulo( 78 )
   aRpt:Say( aRpt:nL  ,01," Pedido No. " + StrZero( aRes[2],8 ) )
   aRpt:Say( aRpt:nL  ,30,NtChr( aRes[3],"2" ) )
   aRpt:Say( aRpt:nL  ,49,"Hora Entrega "+ aRes[4] )
   aRpt:Say( aRpt:nL+1,01,"  Cliente : " + aRes[1] )
   aRpt:Say( aRpt:nL+2,01,"Pedido Por: " + aRes[5] )
   aRpt:Say( aRpt:nL+2,50,"Tomado Por: " + aRes[6] )
   aRpt:SetFont( aRpt:CPICompress,144,1 )
   aRpt:Say( aRpt:nL+3,00,cT + "   " + cT )
   aRpt:nL += 4
       nK := 0
   FOR nD := 1 TO LEN( aLS )
      aRpt:Titulo( 78 )
      aRpt:Say( aRpt:nL,nK   ,aLS[nD,1] + "   " + aLS[nD,2] )
      aRpt:Say( aRpt:nL,nK+50,TRANSFORM(aLS[nD,3],"9,999.9") )
      If nK == 0
         nK := 60
      Else
         nK := 0
         aRpt:nL ++
      EndIf
   NEXT nD
   aRpt:SetFont( aRpt:CPINormal,80,2 )
   If (nD := MLCOUNT( aRes[7],78 )) > 0
      aRpt:Say(++aRpt:nL,42,">> Notas Pedido <<" )
      FOR nK := 0 TO nD
         aRpt:Say(++aRpt:nL,01,MEMOLINE( aRes[7],78,nK+1 ),,,1 )
      NEXT nK
   EndIf
   aRpt:Say(  aRpt:nL,00,REPLICATE("_",79) )
   aRpt:nL ++
   nL --
EndDo
MSFreeResult( hRes )
aRpt:NewPage()
aRpt:End()
RETURN

//------------------------------------//
PROCEDURE CaoAnota()
   LOCAL aFact := {}, aRes, cFac := "", cQry, hRes, nF, nK
   LOCAL oDlg, aRpt, oGet := ARRAY(4), nNF := 0

DEFINE DIALOG oDlg TITLE "Listar Anotaciones" FROM 0, 0 TO 10,44
   @ 02,00 SAY "Nro. de Factura" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 02,82 GET oGet[1] VAR nNF OF oDlg PICTURE "9999999999";
      VALID EVAL( {|| cQry := "SELECT 'SI' FROM cadfactu u, cadfacth h "      +;
                              "WHERE u.empresa = " + xValToChar(oApl:nEmpresa)+;
                               " AND u.numfac = " + xValToChar( nNF )         +;
                               " AND u.tipo   = " + xValToChar(oApl:Tipo )    +;
                               " AND u.numfac = h.numfac AND u.tipo = h.tipo" ,;
                      cQry := Buscar( cQry,"CM",,8 )                         ,;
                      If( EMPTY( cQry )                                      ,;
                        ( MsgStop("Está Factura NO tiene Anotaciones"),.f.)  ,;
                        ( cFac += STR( nNF ), AADD( aFact,nNF )              ,;
                          oGet[2]:Refresh(), .t. ) ) } )                      ;
      SIZE 40,12 PIXEL
   @ 16,10 SAY oGet[2] VAR cFac OF oDlg PIXEL SIZE 130,26 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 50, 50 BUTTON oGet[3] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ;
      ACTION oDlg:End() PIXEL
   @ 50,100 BUTTON oGet[4] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION ( cFac := "FIN", oDlg:End() ) PIXEL
   @ 56, 02 SAY "[CAOLIPED]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED

If cFac == "FIN" .OR. LEN(aFact) == 0
   RETURN
EndIf
cFac := " AND u.tipo = "   + xValToChar(oApl:Tipo )           +;
        " AND n.codigo_nit = u.codigo_nit"                    +;
        " AND u.numfac = h.numfac AND u.tipo = h.tipo"        +;
        " AND u.numfac = s.numfac AND u.tipo = s.tipo"        +;
        " AND s.anomes = (SELECT MAX(anomes) FROM cadfactm m "+;
                          "WHERE m.empresa = u.empresa"       +;
                           " AND m.numfac  = u.numfac"        +;
                           " AND m.tipo    = u.tipo"          +;
                           " AND m.anomes <= '"               +;
                           NtChr( oApl:oEmp:FEC_HOY,"1" ) + "')"
aRpt := TDosPrint()
aRpt:New( oApl:cPuerto,oApl:cImpres,{"LISTADO DE ANOTACIONES DE CLIENTES",;
           NtChr( DATE(),"3" ) },.t. )
FOR nF := 1 TO LEN( aFact )
   cQry := "SELECT u.fechoy, u.cliente, u.direcc, u.telefono, "  +;
           "n.nombre, n.direccion, n.telefono, s.saldo, h.nota " +;
           "FROM cadfactu u, cadclien n, cadfacth h, cadfactm s "+;
           "WHERE u.empresa = " + xValToChar(oApl:nEmpresa)      +;
            " AND u.numfac  = " + xValToChar( aFact[nF] )        + cFac
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) },1,8 )
   nNF := MLCOUNT( aRes[9],78 )
   If nF > 1
      aRpt:Separator( 0,nNF+4 )
   EndIf
   aRpt:Titulo( 78 )
   aRpt:Say(  aRpt:nL,01,"Factura No. " + STRZERO( aFact[nF],8 ) )
   aRpt:Say(  aRpt:nL,34,NtChr( aRes[1],"2" ) )
   aRpt:Say(  aRpt:nL,62,"Saldo "+ TRANSFORM( aRes[8],"$99,999,999" ) )
   aRpt:Say(++aRpt:nL,01,"  Cliente : " + aRes[5] + "      " + aRes[6] )
   aRpt:Say(++aRpt:nL,01,"Pedido Por: " + aRes[2] + "      " + aRes[3] )
   aRpt:Say(++aRpt:nL,01,"Telefonos : " + aRes[7] + "      " + aRes[4] )
   aRpt:Say(++aRpt:nL,42,">> Anotaciones <<" )
   FOR nK := 0 TO nNF
      aRpt:Say(++aRpt:nL,01,MEMOLINE( aRes[9],78,nK+1 ) )
   NEXT nK
   aRpt:Say( aRpt:nL,00,REPLICATE("_",79) )
   aRpt:nL ++
NEXT nF
MSFreeResult( hRes )
aRpt:NewPage()
aRpt:End()
RETURN

//------------------------------------//
PROCEDURE FechaCobro()
   LOCAL oDlg, oGet := ARRAY(5), aFC := { 0,CTOD("") }
DEFINE DIALOG oDlg TITLE "CAMBIAR FECHA DE COBRO" FROM 0, 0 TO 10,44
   @ 02,00 SAY "Nro. de Factura" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 02,82 GET oGet[1] VAR aFC[1] OF oDlg PICTURE "9999999999"       ;
      VALID( If( !oApl:oFac:Seek( { "empresa",oApl:nEmpresa,"numfac",;
                                    aFC[1],"tipo",oApl:Tipo} )      ,;
               ( MsgStop("Factura NO EXISTE"), .f. )                ,;
               ( oDlg:Update(), .t. ))) SIZE 40,12 PIXEL
   @ 16,10 SAY oGet[2] VAR oApl:oFac:CLIENTE OF oDlg PIXEL SIZE 130,10;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 30, 00 SAY "FECHA COBRO [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 30, 82 GET oGet[3] VAR aFC[2] OF oDlg SIZE 36,12 PIXEL
   @ 30,124 SAY oApl:oFac:FECHACOB OF oDlg SIZE 30,12 PIXEL UPDATE

   @ 50, 50 BUTTON oGet[4] PROMPT "&Grabar"   SIZE 44,12 OF oDlg ACTION;
      ( If( oApl:oFac:FECHACOB  # aFC[2],;
          ( oApl:oFac:FECHACOB := aFC[2], oApl:oFac:Update(.f.,1) ), ),;
        oGet[4]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 50,100 BUTTON oGet[5] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 56, 02 SAY "[CAOLIPED]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN