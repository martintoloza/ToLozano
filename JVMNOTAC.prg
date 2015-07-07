// Programa.: JVMNOTAC.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Modulo para la Elaboracion de Notas Credito
#include "FiveWin.ch"
#include "TSBrowse.ch"

MEMVAR oApl

#define CLR_PINK  nRGB( 128, 150, 150 )
#define CLR_NBLUE nRGB( 128, 128, 192 )

PROCEDURE NCredito()
   LOCAL oDlg, oLbx, oLbp, aColor[ 2 ], lNoBlink := .f.
   LOCAL nA, oN, oGet := ARRAY(5)
If (aColor[ 1 ] := GetSysColor( COLOR_INACTIVECAPTION ) ) != ;
   GetSysColor( COLOR_ACTIVECAPTION )
   aColor[ 2 ] := GetSysColor( COLOR_INACTCAPTEXT )
   lNoBlink := .t.
   SBNoBlink()
EndIf
 oN := TNotasc() ; oN:NEW()
oN:AdicArray()
DEFINE DIALOG oDlg FROM 0, 0 TO 360,560 PIXEL;
   TITLE "Nota Credito"
   @ 16, 00 SAY "Nota Credito" OF oDlg RIGHT PIXEL SIZE 52,10
   @ 16, 54 GET oGet[1] VAR oN:aMov[3] OF oDlg PICTURE "99999999"     ;
      VALID( If( !oN:oNvc:Seek( { "empresa",oApl:nEmpresa,"numero"   ,;
                  oN:aMov[3],"tipo",oApl:Tipo} ) .AND. oN:aMov[3] # 0,;
               ( MsgStop("Nota Credito NO EXISTE"), .f. )            ,;
               (oN:AdicArray(),  oLbx:aArray := oN:aD, oLbx:Refresh(),;
                oLbp:aArray := oN:aP, oLbp:Refresh(),  oDlg:Update() ,;
                If( oN:oNvc:lOK, (oGet[1]:oJump := oLbx), ), .t. )) ) ;
      SIZE 40,10 PIXEL UPDATE
   @ 16,100 SAY "Siguiente" + STR( oN:nSigFac,6 ) OF oDlg PIXEL SIZE 70,10;
      UPDATE COLOR nRGB( 255,0,0 )
   @ 16,180 SAY "N.Credito POR" OF oDlg RIGHT PIXEL SIZE 42,10
   @ 16,224 COMBOBOX oGet[2] VAR oN:oNvc:CLASE      ;
      ITEMS {"Anulación","Devolución","Saldo","Cruce Cuenta"};
      SIZE 50,99 OF oDlg PIXEL UPDATE;
      WHEN !oN:oNvc:lOK
   @ 30,180 SAY "Fecha N.C."   OF oDlg RIGHT PIXEL SIZE 42,10
   @ 30,224 GET oGet[3] VAR oN:oNvc:FECHA OF oDlg ;
      VALID oN:Fechas( oN:oNvc:lOK,1 ) SIZE 40,10 PIXEL UPDATE
   @ 30, 00 SAY "Factura Nro." OF oDlg RIGHT PIXEL SIZE 52,10
   @ 30, 54 GET oGet[4] VAR oN:oNvc:NUMFAC OF oDlg PICTURE "999999999";
      WHEN !oN:oNvc:lOK                                               ;
      VALID( If( !oN:BuscaFac((oN:oNvc:CLASE # 4),oN:oNvc:NUMFAC),.f.,;
               ( oN:Detalle(), oLbx:aArray := oN:aD, oLbx:Refresh()  ,;
                 oLbp:aArray := oN:aP, oLbp:Refresh(), oDlg:Update() ,;
                 oGet[4]:oJump := oLbx, .t. ) ) )                     ;
      SIZE 40,10 PIXEL UPDATE
   @ 44, 00 SAY "Concepto"     OF oDlg RIGHT PIXEL SIZE 52,10
   @ 44, 54 SAY oGet[5] VAR oN:oNvc:CONCEPTO OF oDlg PIXEL SIZE 130,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   ACTIVAGET(oGet)

   @ 58,06 BROWSE oLbx SIZE 262, 60 PIXEL OF oDlg CELLED; // CELLED  es requerida
      COLORS CLR_BLACK, CLR_NBLUE                         // para editar Celdas
   oLbx:SetArray( oN:aD )     // Esto es necesario para trabajar con arrays
   oLbx:nHeightCell += 4
   oLbx:nHeightHead += 4
   oLbx:bKeyDown := {|nKey| If(nKey=VK_F3 , oN:ArmarLis( oDlg,oLbx ) ,;
                            If(nKey=VK_F5 , oLbx:KeyDown( VK_DELETE,0 ),;
                            If(nKey=VK_F11, oN:Guardar( oDlg,oLbx ) , ))) }

   oLbx:SetAppendMode( .f. )                         // Activando Auto Append Mode
   oLbx:SetDeleteMode( .t.,.f.,{ |nAt,oLbx| oN:BorraDeta(oLbx,.f.) },;
                               { |oLbx| oN:Dscto( oLbx ) } ) // lOnOff, lConfirm, bDelete
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 1;
       TITLE "Código"+CRLF+"Artículo"            ;
       SIZE  80 ;                  // Esta columna es editable
       3DLOOK TRUE, TRUE, TRUE;    // Celda, Titulo, Footers
       MOVE DT_MOVE_NEXT;          // Cursor pasa a la Sig.Columna editable
       ALIGN DT_LEFT, DT_CENTER  ; // Celda, Titulo, Footer
       FOOTER { || STR( oLbx:nLen,4 ) + " Items" }
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 2;
       TITLE "Descripción";
       SIZE 220           ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_LEFT, DT_CENTER, DT_RIGHT;
       FOOTER "SUBTOTAL ->"
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 3;
       TITLE "Cantidad"       PICTURE "999,999.9";
       SIZE  74 EDITABLE ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       POSTEDIT { |uVar| If( oLbx:lChanged, oN:Dscto( oLbx,uVar ), ) } ;
       WHEN oN:oNvc:CLASE == 2;
       VALID { |uVar| If( uVar > 0, .T.,;
          (MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>" ), .f.) ) }
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 5 ;
       TITLE "Valor"         PICTURE "99,999,999" ;
       SIZE 76 ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       FOOTER { || TRANSFORM( oN:aMov[7], "99,999,999" ) }
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 7      ;
       TITLE "Monto"+CRLF+"I.V.A" PICTURE "99,999,999" ;
       SIZE 74 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       FOOTER { || TRANSFORM( oN:aMov[8], "99,999,999" ) }
   // Asignando Valores por defaults para nueva Fila creada con Auto Append.
   oLbx:aDefault := { SPACE(12), SPACE(30), 1, "UN", 0, 0, 0, 0, 0, 0 }
   oLbx:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbx:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color

   @ 120,06 BROWSE oLbp SIZE 200, 60 PIXEL OF oDlg CELLED;
      COLORS CLR_BLACK, CLR_NBLUE
   oLbp:SetArray( oN:aP )
   oLbp:nHeightCell += 4
   oLbp:nHeightHead += 4
   oLbp:bKeyDown := {|nKey| If(nKey=VK_F3 , oN:ArmarLis( oDlg,oLbp ) ,;
                            If(nKey=VK_F5 , oLbp:KeyDown( VK_DELETE,0 ),;
                            If(nKey=VK_F11, oN:Guardar( oDlg,oLbp ) , ))) }

   oLbp:SetAppendMode( .t. )                         // Activando Auto Append Mode
   oLbp:SetDeleteMode( .t.,.f.,{ |nAt,oLbp| oN:BorraDeta(oLbp,.t.) },;
                               { |oLbp| oN:Dscto( oLbp ) } ) // lOnOff, lConfirm, bDelete
   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 1;
       TITLE "Numero"+CRLF+"Factura"             ;
       PICTURE "9999999999" ;
       SIZE  80 EDITABLE ;         // Esta columna es editable
       3DLOOK TRUE, TRUE, TRUE;    // Celda, Titulo, Footers
       MOVE DT_MOVE_NEXT;          // Cursor pasa a la Sig.Columna editable
       VALID { | uVar| oN:BuscaFac( .t.,uVar,oLbp ) }; // don't want empty rows
       ALIGN DT_RIGHT, DT_CENTER  ; // Celda, Titulo, Footer
       PREEDIT {|uVar| oN:aMov[23] := uVar, nA := oLbp:nAt ,;
                       oN:aMov[24] := If( nA > LEN(oN:aP), 0, oN:aP[nA,3] ) };
       FOOTER { || STR( oLbp:nLen,4 ) + " Items" };
       WHEN oN:oNvc:CLASE >= 3
    oLbp:aColumns[01]:bPostEdit := { |uVar| ;
       oN:aP[nA,1] := oN:aMov[23], oN:aP[nA,2] := oN:aMov[24],;
       oN:aP[nA,3] := oN:aMov[25], oN:aP[nA,5] := oN:aMov[11], oN:Dscto( oLbp ) }
   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 5;
       TITLE "Cliente"    ;
       SIZE 220           ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_LEFT, DT_CENTER, DT_RIGHT;
       FOOTER "TOTAL PAGOS ->"
   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 2;
       TITLE "Valor" +CRLF +"Pago NC"            ;
       PICTURE "999,999,999" ;
       SIZE 90 EDITABLE ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       POSTEDIT { |uVar| If( oLbp:lChanged, oN:Dscto( oLbp ), ) } ;
       VALID { |uVar| If( uVar <= 0, ;
          (MsgStop( "El Pago debe ser Mayor de 0","<< OJO >>" ), .f.),;
          (If( uVar > oN:aP[oLbx:nAt,3],;
          (MsgStop( "Pago Mayor que el Saldo","<< OJO >>" ), .f.), .t. ))) };
       FOOTER { || TransForm( oN:oNvc:PAGADO,"999,999,999" ) }
   oLbp:aDefault := { 0, 0, 0, 0,SPACE(30) }
   oLbp:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbp:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color

ACTIVATE DIALOG oDlg CENTER ON INIT (oN:Barram( oDlg,oLbx ))

If( lNoBlink, SBNoBlink( aColor[1], aColor[2] ), Nil )
oN:NEW( 1 )
RETURN

//------------------------------------//
CLASS TNotasc FROM TMov
 DATA aCta, aD, aDF, aP, nL
 DATA nSigFac, oNvc, oNvd
 DATA lCar          INIT .f.

 METHOD NEW( xFin ) Constructor
 METHOD Fechas( lOK,nMsg )
 METHOD AdicArray( xBus )
 METHOD BuscaFac( lBus,xBus,oLbp )
 METHOD BorraDeta( oLbx,lPago )
 METHOD DelDeta( nA,nRow )
 METHOD AnulaCpte( oDlg,oLbx )
 METHOD Dscto( oLbx,mGetVar )
 METHOD Detalle()
 METHOD DetaVta( aMov )
 METHOD Guardar( oDlg,oLbx )
 METHOD ArmarLis( oDlg,oLbx )
 METHOD Barram( oDlg,oLbx )
ENDCLASS

//------------------------------------//
METHOD NEW( xFin ) CLASS TNotasc
If xFin == NIL
   Super:NEW( 6 )
   ::nSigFac := SgteNumero( "notasc",oApl:nEmpresa,.f. )
   ::oNvc := oApl:Abrir( "cadnotac","empresa, numero, tipo",.t.,,10 )
   ::oNvd := oApl:Abrir( "cadnotad","empresa, numero, tipo",,,50 )
   ::oFte:oDb:Seek( {"fuente",::aMov[2]} )
   ::aCta := Cuentas( 3,1 )
   ::aMov[6] := oApl:oEmp:PIVA
Else
   ::oFte:Cerrar()
   ::oPuc:Cerrar()
   ::oVar:Cerrar()
   ::oCtl:Destroy()
   ::oMvc:Destroy()
   ::oMvd:Destroy()
   ::oNvc:Destroy()
   ::oNvd:Destroy()
EndIf
RETURN NIL

//------------------------------------//
METHOD Fechas( lOK,nMsg ) CLASS TNotasc
   LOCAL aF, lSI := .t.
If lOK
   aF := { ::oNvc:XColumn( 5 ),::oNvc:FECHA,oApl:cPer,::lCierre,.t. }
   If (aF[5] := ::Fechas( .f.,1 ))
      If (aF[3] == LEFT( DTOS(aF[2]),6 ))
         If ::oMvc:lOK
            ::oMvc:FECHA   := aF[2]
            Guardar( ::oMvc,.f.,.f. )
         EndIf
         Guardar( ::oNvc,.f.,.f. )
      ElseIf MsgYesNo( "QUIERE HACER EL CAMBIO","VA A CAMBIAR DE MES" )
         If ::oMvc:lOK > 0
            ::oMvc:ANO_MES := oApl:cPer
            ::oMvc:FECHA   := aF[2]
            ::oMvc:CONTROL := SgteCntrl( "control",oApl:cPer,.t. )
            Guardar( ::oMvc,.f.,.f. )
            ::oMvd:dbEval( {|o| ::Avanza( ,o:CUENTA )                                ,;
                                ::GrabaPago( o:CUENTA,::aTL[4],-::aTL[5],::aTL[6],1 ),;
                                Acumular( ::oMvc:ESTADO,o,5,5,.f.,.f. )              ,;
                                o:ANO_MES := oApl:cPer, o:CONTROL := ::oMvc:CONTROL  ,;
                                ::GrabaPago( o:CUENTA,::aTL[4], ::aTL[5],::aTL[6],2 ),;
                                Acumular( ::oMvc:ESTADO,o,2,2,.f.,.f. ) } )
         EndIf
         Guardar( ::oNvc,.f.,.f. )
      Else
         aF[5] := .f.
      EndIf
   EndIf
   If (lSI := aF[5])
      MsgInfo( "El cambio de Fecha","HECHO" )
   Else
      lSI := If( EMPTY( aF[2] ) .OR. ::lCierre, .t., .f. )
      ::oNvc:FECHA := aF[1]
      oApl:cPer := aF[3]
      ::lCierre := aF[4]
   EndIf
ElseIf EMPTY( ::oNvc:FECHA )
   MsgStop( "No puede ir en Blanco","FECHA" )
   lSI := .f.
Else
   ::aMov[12]:= oApl:cPer := NtChr( ::oNvc:FECHA,"1" )
   ::lCierre := Buscar( {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer},;
                        "cgecntrl","cierre",8,,3 )
   If ::lCierre .AND. nMsg # NIL
      MsgStop( "Ya esta CERRADO","Periodo "+oApl:cPer )
      lSI := .f.
   Else
      ::aDF  := PIva( oApl:cPer )
   EndIf
EndIf
RETURN lSI

//------------------------------------//
METHOD AdicArray( xBus ) CLASS TNotasc
   LOCAL aRes, hRes, nL
If ::aMov[3] == 0
   ::aMov[7] := ::aMov[8] := ::aMov[9] := 0
   ::oNvc:lOK   := .f.
   ::oNvc:FECHA := DATE()
   ::oNvc:CLASE := 1
Else
   ::aMov[8] := ::oNvc:TOTALIVA
   ::aMov[9] := ::oNvc:TOTALFAC
   ::aMov[7] := ::aMov[9] - ::aMov[8]
EndIf
   ::Fechas( .f. )
   ::BuscarMov()
   ::oMvd:Seek( {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,;
                 "control",::oMvc:CONTROL} )
If xBus == NIL
   ::aD := {}
   ::aP := {}
   aRes := "SELECT d.codigo, i.descrip, d.cantidad, d.unidadmed, d.precioven"+;
                ", d.pcosto, d.montoiva, d.row_id, i.indiva, i.impuesto "    +;
           "FROM cadnotad d LEFT JOIN cadinven i "         +;
            "USING( codigo ) "                             +;
           "WHERE d.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND d.numero  = " + LTRIM(STR( ::aMov[3] ))  +;
            " AND d.tipo    = " + xValToChar( oApl:Tipo )
   hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   While nL > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      xBus := If( oApl:oEmp:TREGIMEN == 1 .OR. !aRes[9], 0,;
              If( aRes[10] == 0, ::aDF[1], ROUND(aRes[10]/100,2) ))
      aRes[9] := ROUND( aRes[5] / aRes[03],2 )
      AADD( ::aD,{ aRes[1], aRes[2], aRes[3], aRes[4], aRes[5],;
                   aRes[6], aRes[7], aRes[8], aRes[9], xBus } )
      nL --
   EndDo
   MSFreeResult( hRes )
   If LEN( ::aD ) == 0
      AADD( ::aD,{ SPACE(12), SPACE(30), 1, "UN", 0, 0, 0, 0, 0, 0 } )
   EndIf
   aRes := "SELECT p.numfac, p.pagado, p.row_id, c.cliente " +;
           "FROM cadpagos p LEFT JOIN cadfactc c "           +;
            "USING( empresa, numfac, tipo ) "                +;
           "WHERE p.empresa   = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND p.fecpag    = " + xValToChar(::oNvc:FECHA) +;
            " AND p.tipo      = " + xValToChar( oApl:Tipo )  +;
            " AND p.documento = " + LTRIM(STR( ::aMov[3] ))  +;
            " AND p.tipo_pag  = 'C'"
   hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   ::lCar := If( nL > 0, .t., .f. )
   While nL > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      AADD( ::aP,{ aRes[1], aRes[2], 0, aRes[3],aRes[4]} )
      nL --
   EndDo
   MSFreeResult( hRes )
   If LEN( ::aP ) == 0
      ::oMvd:dbEval( {|o| If( o:CUENTA == oApl:oEmp:CARTERA .AND. o:VALOR_CRE # 0,;
                            ( nL := INT( VAL(NtChr( o:INFC,"N" )) )              ,;
                              AADD( ::aP,{ nL, o:VALOR_CRE, 0, 0, SPACE(30) } ) ), ) } )
      AADD( ::aP,{ 0, 0, 0, 0, SPACE(30) } )
   EndIf
   SysRefresh()
Else
   ::aD := { { SPACE(12), SPACE(30), 1, "UN", 0, 0, 0, 0, 0, 0 } }
   ::aP := { {0,0,0,0,SPACE(30)} }
EndIf
RETURN NIL

//------------------------------------//
METHOD BuscaFac( lBus,xBus,oLbp ) CLASS TNotasc
   LOCAL nA, lOK := .t.
If lBus
   lOK := oApl:oFac:Seek( {"empresa",oApl:nEmpresa,"numfac",;
                           xBus,"tipo",oApl:Tipo} )
   If !lOK
      MsgStop( "Factura NO EXISTE",">>> OJO <<<" )
   ElseIf ::oNvc:CLASE == 1 .AND. oApl:oFac:FECHOY == oApl:dFec
      MsgStop( "Se anula como siempre",">>> Factura de HOY <<<" )
      lOK := .f.
   ElseIf oApl:oFac:INDICADOR $ "AN"
      MsgStop( "Anulada o con N.Credito",">>> Factura <<<" )
      lOK := .f.
   Else
      If ::oNvc:CODIGO_NIT == 0
         ::oNvc:CODIGO_NIT := oApl:oFac:CODIGO_NIT
         oApl:oNit:Seek( {"codigo_nit",::oNvc:CODIGO_NIT} )
      EndIf
      oApl:lFam := SaldoFac( xBus )
      ::aMov[11]:= oApl:oFac:CLIENTE
      If oLbp # NIL
         nA := oLbp:nAt
         ::aMov[23] := xBus
         If ::aMov[24] == 0
            ::aMov[24] := ::aMov[25] := oApl:nSaldo
         Else
            ::aMov[24] := ::aP[nA,2]
            ::aMov[25] := ::aP[nA,2] + oApl:nSaldo
         EndIf
      EndIf
   EndIf
Else
   ::aMov[11]  := SPACE(30)
   oApl:nSaldo := 0
EndIf
RETURN lOK

//------------------------------------//
METHOD BorraDeta( oLbx,lPago ) CLASS TNotasc
   LOCAL aF, lSi := .t., nA := oLbx:nAt
If lPago
   If ::aP[nA,4] > 0
      If (lSi := MsgNoYes( "Elimina este Pago",::aP[nA,1] ))
         aF   := { "",LTRIM(STR(::aP[nA,1])) }
         ::oMvd:dbEval( {|o| aF[1] := ALLTRIM(o:INFC)                         ,;
                             If( o:CUENTA == oApl:oEmp:CARTERA .AND.           ;
                                (aF[1] == aF[2] .OR. aF[1] == aF[2]+oApl:Tipo),;
                               (::GrabaPago( o:CUENTA,o:INFC,-::aP[nA,2],1,1 ),;
                                o:EMPRESA := -6                               ,;
                                Acumular( ::oMvc:ESTADO, o, 3, 3, .f., .f. )  ,;
                                ::oMvc:CONSECUTIV --, ::oMvc:Update(.t.,1) ), ) } )
      EndIf
   EndIf
Else
   lSi := !(::oNvc:CLASE != 2)
   If ::aD[nA,7] > 0
      If (lSi := MsgNoYes( "Elimina este Código",::aD[nA,1] ))
         ::DelDeta( nA,2 )
      EndIf
   EndIf
EndIf
RETURN lSi

//------------------------------------//
METHOD DelDeta( nA,nRow ) CLASS TNotasc
   LOCAL cQry
   Actualiz( ::aD[nA,1],-::aD[nA,3],::oNvc:FECHA,7,::aD[nA,6],::aD[nA,4] )
   cQry := "UPDATE cadfactd SET indicador = '' "        +;
           "WHERE empresa = "+ LTRIM(STR(oApl:nEmpresa))+;
            " AND numfac = " + LTRIM(STR(::oNvc:NUMFAC))+;
            " AND tipo   = " + xValToChar( oApl:Tipo )  +;
            " AND codigo = " + xValToChar( ::aD[nA,1] )
   MSQuery( oApl:oMySql:hConnect,cQry )
If nRow # 1
   MSQuery( oApl:oMySql:hConnect,"DELETE FROM cadnotad WHERE row_id ="+;
            LTRIM(STR(::aD[nA,8])) )
EndIf
RETURN NIL

//------------------------------------//
METHOD AnulaCpte( oDlg,oLbx ) CLASS TNotasc
   LOCAL nR
If ::lCierre
   MsgStop( "YA ESTA CERRADO","Periodo "+oApl:cPer )
   RETURN NIL
ElseIf !Login( "Desea Anular esta Nota Credito" )
   RETURN NIL
EndIf
FOR nR := 1 TO LEN( ::aD )
   If ::aD[nR,7] > 0
      ::DelDeta( nR,nR )
      If nR == 1
         ::oNvd:Seek( {"row_id",::aD[nR,8]} )
         ::oNvd:CODIGO    := "05990004"
         ::oNvd:CANTIDAD  := 1
         ::oNvd:PRECIOVEN := ::oNvd:PCOSTO := ::oNvd:MONTOIVA := 0
         Guardar( ::oNvd,.f.,.f. )
      EndIf
      ::aD[nR,7] := 0
   EndIf
NEXT nR

::oMvd:dbEval( {|o| ::Avanza( ,o:CUENTA )                       ,;
                    If( ::oMvc:ESTADO == 1                      ,;
                      (      o:EMPRESA := -6                    ,;
                        ::GrabaPago( o:CUENTA,::aTL[4],-::aTL[5],::aTL[6],1 ),;
                        Acumular( 2, o, 3, 3, .f., .f. ) ), ) } ,;
               {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,"control",::oMvc:CONTROL} )
::oMvc:ESTADO     := 2
::oMvc:CONSECUTIV := 0
::oMvc:Update(.t.,1)
If ::oNvc:lOK
   ::oNvc:TOTALFAC := ::oNvc:TOTALIVA := ::oNvc:PAGADO := 0
   ::oNvc:ANULAP   := '0'
   Guardar( ::oNvc,.f.,.f. )
EndIf
::aMov[3] := ::oNvc:NUMFAC := 0
::AdicArray()
oLbx:aArray := ::aD ; oLbx:Refresh()
oDlg:Update()
SetFocus( oDlg:aControls[ 4 ]:hWnd )
RETURN NIL

//------------------------------------//
METHOD Dscto( oLbx,mGetVar ) CLASS TNotasc
   LOCAL nPrecio, nA := oLbx:nAt
If ::oNvc:CLASE <= 2
   If mGetVar # NIL
      ::aD[nA,5] := ROUND( ::aD[nA,9] * mGetVar,0 )
      ::aD[nA,7] := ROUND( ::aD[nA,5] * ::aD[nA,10],0 )
   EndIf
   ::aMov[7] := ::aMov[8] := 0
   AEVAL( ::aD, { | e | ::aMov[7] += e[ 5 ], ::aMov[8] += e[ 7 ] } )
   ::aMov[9] := ::aMov[7] + ::aMov[8]
   If ::oNvc:TOTALIVA  # ::aMov[8] .OR. ;
      ::oNvc:TOTALFAC  # ::aMov[9] .OR. oLbx:lChanged
      ::oNvc:TOTALIVA := ::aMov[8]
      ::oNvc:TOTALFAC := ::aMov[9]
      If ::oNvc:lOK
         ::oNvc:Update( .f.,1 )
      EndIf
   EndIf
EndIf
 ::oNvc:PAGADO := 0
 AEVAL( ::aP, { | e | ::oNvc:PAGADO += e[ 2 ] } )
oLbx:Refresh() ; oLbx:DrawFooters()
RETURN NIL

//------------------------------------//
METHOD Detalle() CLASS TNotasc
   LOCAL aRes, hRes, nIva
 ::aMov[7] := ::aMov[8] := 0
   ::oNvc:CONCEPTO := {"ANULACION DE LA FACTURA ","DEVOLUCION MERCANCIA FACT.",;
                       "CANCELACION DE LAS SIG.FACTURAS",;
                       "CANCELACION POR CRUCE DE CUENTA" }[::oNvc:CLASE]
aRes := "SELECT d.codigo, i.descrip, d.cantidad, d.unidadmed, "          +;
               "d.precioven, d.pcosto, d.montoiva, i.indiva, i.impuesto "+;
        "FROM cadfactd d LEFT JOIN cadinven i "         +;
         "USING( codigo ) "                             +;
        "WHERE d.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND d.numfac  = " + LTRIM(STR(::oNvc:NUMFAC))+;
         " AND d.tipo    = " + xValToChar( oApl:Tipo )
   ::aD := {}
If ::oNvc:CLASE == 1
   hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   ::nL := MSNumRows( hRes )
// MsgInfo( aRes,STR(::nL) )
   While ::nL > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      If aRes[5] > 0
         nIva := If( oApl:oEmp:TREGIMEN == 1 .OR. !aRes[8], 0,;
                 If( aRes[9] == 0, ::aDF[1], ROUND(aRes[9]/100,2) ))
         aRes[8] := ROUND( aRes[5] / aRes[3],2 )
         AADD( ::aD,{ aRes[1], aRes[2], aRes[3], aRes[4], aRes[5],;
                      aRes[6], aRes[7],       0, aRes[8], nIva } )
         ::aMov[7] += aRes[5]
         ::aMov[8] += aRes[7]
      EndIf
      ::nL --
   EndDo
   MSFreeResult( hRes )
   ::oNvc:CONCEPTO += LTRIM(STR(::oNvc:NUMFAC))
ElseIf ::oNvc:CLASE == 2
   ::DetaVta( aRes )
   ::oNvc:CONCEPTO += LTRIM(STR(::oNvc:NUMFAC))
EndIf
   If LEN( ::aD ) == 0
      AADD( ::aD,{ SPACE(12), SPACE(30), 1, "UN", 0, 0, 0, 0, 0, 0 } )
   EndIf
   ::aMov[9] := ::aMov[7] + ::aMov[8]
   ::oNvc:TOTALIVA := ::aMov[8]
   ::oNvc:TOTALFAC := ::aMov[9]
 If oApl:nSaldo > 0 .AND. ::oNvc:CLASE # 2
    ::aP := {{ ::oNvc:NUMFAC,oApl:nSaldo,oApl:nSaldo,0,::aMov[11] }}
    ::oNvc:PAGADO := oApl:nSaldo
 Else
    ::aP := {{ 0, 0, 0, 0, SPACE(30) }}
 EndIf
 SysRefresh()
RETURN NIL

//------------------------------------//
METHOD DetaVta( aMov ) CLASS TNotasc
   LOCAL bCod, oDlg, oLbx, nIva
aMov := Buscar( aMov + " ORDER BY i.descrip","CM",,9 )
bCod := { |nL| nIva := If( oApl:oEmp:TREGIMEN == 1 .OR. !aMov[nL,8], 0                ,;
                       If( aMov[nL,9] == 0, ::aDF[1], ROUND(aMov[nL,9]/100,2) ))      ,;
               ::nL := ROUND( aMov[nL,5] / aMov[nL,3],2 )                             ,;
               AADD( ::aD,{ aMov[nL,1], aMov[nL,2], aMov[nL,3], aMov[nL,4], aMov[nL,5],;
                            aMov[nL,6], aMov[nL,7],          0,    ::nL   , nIva } )  ,;
               ::aMov[7] += aMov[nL,5], ::aMov[8] += aMov[nL,7], oLbx:Refresh() }
DEFINE DIALOG oDlg FROM 0, 0 TO 20,54 ;
   TITLE "Escoja los Artículos a Devolver"
   @ 10.0,04 BROWSE oLbx SIZE 200,150 PIXEL OF oDlg CELLED;
      ON CLICK ( EVAL( bCod,oLbx:nAt ) );
      COLORS CLR_BLACK, CLR_NBLUE
   oLbx:SetArray( aMov )
   oLbx:nHeightCell += 4
   oLbx:nHeightHead += 4
   oLbx:SetAppendMode( .f. )

   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 1;
       TITLE "Código"+CRLF+"Artículo"            ;
       SIZE  88 ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_LEFT, DT_CENTER, DT_RIGHT
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 2;
       TITLE "Descripción" ;
       SIZE 180 ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_LEFT, DT_CENTER, DT_RIGHT
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 3;
       TITLE "Cantidad"     PICTURE "999,999.999";
       SIZE  58 ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 5;
       TITLE "Precio"+CRLF+"Neto"  PICTURE "99,999,999";
       SIZE  76 ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       FOOTER { || TRANSFORM( ::aMov[7], "99,999,999" ) }
   oLbx:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbx:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color
ACTIVATE DIALOG oDlg CENTER
RETURN NIL

//------------------------------------//
METHOD Guardar( oDlg,oLbx ) CLASS TNotasc
   LOCAL aCta, aInf, cSql, hRes, nK, nP, nR
If EMPTY( ::aD[1,1] ) .AND. EMPTY( ::aP[1,1] )
   MsgInfo( "Nota Credito no Tiene ningun Items" )
   RETURN NIL
EndIf
If ::oNvc:CLASE >= 3
   ::oNvc:TOTALFAC := ::aMov[9] := ::oNvc:PAGADO
ElseIf ::oNvc:CLASE == 2 .AND. !::oNvc:ANULAP
   If ::lCar .OR. ::aP[1,2] == 0
      ::aP[1,1] := ::oNvc:NUMFAC
      ::aP[1,2] := ::oNvc:PAGADO := ::oNvc:TOTALFAC
   EndIf
EndIf
If !::oNvc:lOK
   nR := SgteNumero( "notasc",oApl:nEmpresa,.f. )
   If !MsgYesNo("Nota Credito #"+STR(nR),"Graba esta")
      RETURN NIL
   EndIf
   ::aMov[3] := SgteNumero( "notasc",oApl:nEmpresa )
   ::oNvc:EMPRESA := oApl:nEmpresa
   ::oNvc:NUMERO  := ::aMov[3]
   ::oNvc:TIPO    := oApl:Tipo
   ::oNvc:Append( .t. )
   ::nSigFac   := ::aMov[3] + 1
   oDlg:Update()
Else
   ::oNvc:Update( .f.,1 )
EndIf
FOR nR := 1 TO LEN( ::aD )
   If ::aD[nR,3] > 0
      nK := 0
      If ::oNvd:Seek( {"row_id",::aD[nR,8]} )
         nK := -::oNvd:CANTIDAD
      Else
         ::oNvd:EMPRESA := oApl:nEmpresa
         ::oNvd:NUMERO  := ::aMov[3]    ; ::oNvd:TIPO      := oApl:Tipo
         ::oNvd:CODIGO  := ::aD[nR,1]
      EndIf
         ::oNvd:CANTIDAD  := ::aD[nR,3] ; ::oNvd:UNIDADMED := ::aD[nR,4]
         ::oNvd:PRECIOVEN := ::aD[nR,5] ; ::oNvd:PCOSTO    := ::aD[nR,6]
         ::oNvd:MONTOIVA  := ::aD[nR,7]
         Guardar( ::oNvd,!::oNvd:lOK,.t. )
      If ::aD[nR,8] == 0
         ::aD[nR,8] := ::oNvd:ROW_ID
      EndIf
         nK += ::aD[nR,3]
         Actualiz( ::aD[nR,1],nK,::oNvc:FECHA,7,::aD[nR,6],::aD[nR,4] )
   EndIf
NEXT nR

//-------CONTABILIDAD-----------------//
aCta := { {::aCta[09,1],"","","","",::aMov[7],0,0,0 ,0 },;
          {::aCta[06,1],"","","","",       0 ,0,0,16,0 } }
cSql := "SELECT d.montoiva, d.precioven, d.cantidad, d.pcosto, "+;
               "d.unidadmed, i.unidadmed, i.codcon, i.impuesto "+;
        "FROM cadnotad d LEFT JOIN cadinven i "         +;
         "USING( codigo ) "                             +;
        "WHERE d.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND d.numero  = " + LTRIM(STR( ::aMov[3] ))  +;
         " AND d.tipo    = " + xValToChar( oApl:Tipo )
hRes := If( MSQuery( oApl:oMySql:hConnect,cSql ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nR   := MSNumRows( hRes )
nK   := LEN( ::aCta )
While nR > 0
   aInf := MyReadRow( hRes )
   AEVAL( aInf, { | xV,nP | aInf[nP] := MyClReadCol( hRes,nP ) } )
   If aInf[1] > 0
      If oApl:oEmp:PRINTIVA .AND. aInf[8] > 1
         If (nP := ASCAN( aCta,{ |aX| aX[9] == aInf[8] } )) == 0
            cSql := LEFT( ::aCta[6,1],6 ) + STRZERO( aInf[8],2 )
            CreaCta( cSql,"IVA GRAVADO " + STR(aInf[8],2) )
            AADD( aCta, { cSql,"","","","",0,0,0,aInf[8],0 } )
            nP := LEN( aCta )
         EndIf
      Else
         nP := 2
      EndIf
      aCta[nP,06] += aInf[1]
      aCta[nP,10] += aInf[2]
   EndIf
   If nK >= 12
      If aInf[5] # aInf[6]
         aInf[4] := AFormula( aInf[4],aInf[5],aInf[6],aInf[7] )
      EndIf
      ::aCta[13,6] += ROUND( aInf[3] * aInf[4],2 )
   EndIf
   nR --
EndDo
   MSFreeResult( hRes )
If ::oNvc:CLASE == 1
   oApl:oFac:Seek( {"empresa",oApl:nEmpresa,"numfac",;
                    ::oNvc:NUMFAC,"tipo",oApl:Tipo} )
   AADD( aCta,{ ::aCta[3,1],"","","","",0,oApl:oFac:RETFTE,0,0,0 } )
   AADD( aCta,{ ::aCta[4,1],"","","","",0,oApl:oFac:RETIVA,0,0,0 } )
   AADD( aCta,{ ::aCta[5,1],"","","","",0,oApl:oFac:RETICA,0,0,0 } )
EndIf
nR := 0
AEVAL( ::aP, { | e | nR += e[ 2 ] } )
If nR == 0
   ::aP[1,1] := ::oNvc:NUMFAC
   ::aP[1,2] := ::oNvc:TOTALFAC
EndIf
FOR nR := 1 TO LEN( ::aP )
   If ::aP[nR,2] > 0
      AADD( aCta,{::aCta[1,1],"","",LTRIM(STR(::aP[nR,1]))+oApl:Tipo,;
                   "",0,::aP[nR,2],0,0,0 } )
   EndIf
NEXT nR
If nK >= 12
   AADD( aCta,{ ::aCta[13,1],"","","","",::aCta[13,6],0,::aCta[13,8],0,0 } )
   AADD( aCta,{ ::aCta[12,1],"","","","",0,::aCta[13,6],::aCta[12,8],0,0 } )
   ::aCta[13,6] := 0
EndIf
If oApl:oEmp:RETCREE .AND. ::oNvc:FECHA >= CTOD("01.09.2013")
   nP := ROUND( ::aMov[7] * .003,0 )
   AADD( aCta,{ ::aCta[11,1],"","","","",nP,0,0,0.30,::aMov[7] } )
   AADD( aCta,{ ::aCta[10,1],"","","","",0,nP,0,0.30,::aMov[7] } )
EndIf

If ::oMvc:lOK
   ::oMvd:dbEval( {|o| o:EMPRESA := -6                        ,;
                       nK   := o:VALOR_DEB + o:VALOR_CRE      ,;
                       ::GrabaPago( o:CUENTA,o:INFC,-nK,1,1 ) ,;
                       Acumular( ::oMvc:ESTADO,o,3,3,.f.,.f. ) } )
   ::oMvc:CONSECUTIV := 0 ; ::oMvc:ESTADO := 1
   ::oMvc:CODIGONIT  := ::oNvc:CODIGO_NIT
Else
   ::oMvc:EMPRESA    := oApl:nEmpresa ; ::oMvc:ANO_MES  := oApl:cPer
   ::oMvc:FECHA      := ::oNvc:FECHA  ; ::oMvc:FUENTE   := ::aMov[2]
   ::oMvc:COMPROBANT := ::aMov[3]     ; ::oMvc:CONCEPTO := ::oNvc:CONCEPTO
   ::oMvc:CODIGONIT  := ::oNvc:CODIGO_NIT
   ::oMvc:CONTROL    := SgteCntrl( "control",oApl:cPer,.t. )
   ::oMvc:ESTADO     := 1
   ::oMvc:Append(.t.)
EndIf
   ::aTL := { 0,0,"","",0,1,::oNvc:CODIGO_NIT }
FOR nR := 1 TO LEN( aCta )
   If aCta[nR,6] > 0 .OR. aCta[nR,7] > 0
      aInf := Buscar( { "empresa",oApl:nPuc,"cuenta",aCta[nR,1] },"cgeplan",;
                        "infa, infb, infc, infd",8 )
      FOR nK := 1 TO LEN( aInf )
         cSql := TRIM( aInf[nK] )
         do case
         Case cSql == "BASE"      .AND. aCta[nR,6] > 0
            nP := If( aCta[nR,10] > 0, aCta[nR,10], ::aMov[7] )
            aCta[nR,nK+1] := LTRIM(STR(nP,10,0))
         Case cSql == "COD-VAR"
            aCta[nR,nK+1] := aCta[nR,1]
         Case cSql == "DOCUMENTO" .OR.;
              cSql == "FACTURA"   .AND. EMPTY(aCta[nR,nK+1])
            aCta[nR,nK+1] := LTRIM(STR(::aMov[3]))
         Case cSql == "FECHA"
            aCta[nR,nK+1] := DTOC(::oMvc:FECHA)
         Case cSql == "NIT"
            If LEFT( aCta[nR,1],4 ) == "1435" .OR. LEFT( aCta[nR,1],4 ) == "6135"
               aCta[nR,nK+1] := ::aCta[12,1]
            Else
               aCta[nR,nK+1] := LTRIM(STR(oApl:oNit:CODIGO))
               aCta[nR,8]    := ::oNvc:CODIGO_NIT
            EndIf
         EndCase
      NEXT nK
      ::oMvd:Seek( "empresa = -6 LIMIT 1","CM" )
      If !::oMvd:lOK
         ::oMvc:CONSECUTIV ++
         ::oMvd:EMPRESA := oApl:nEmpresa ; ::oMvd:ANO_MES  := oApl:cPer
         ::oMvd:CONTROL := ::oMvc:CONTROL
      EndIf
      ::oMvd:CUENTA     := aCta[nR,1]
      ::oMvd:INFA       := aCta[nR,2] ; ::oMvd:INFB     := aCta[nR,3]
      ::oMvd:INFC       := aCta[nR,4] ; ::oMvd:INFD     := aCta[nR,5]
      ::oMvd:VALOR_DEB  := aCta[nR,6] ; ::oMvd:VALOR_CRE:= aCta[nR,7]
      ::oMvd:CODIGO_NIT := aCta[nR,8] ; ::oMvd:PTAJE    := aCta[nR,9]
      ::Graba( ::oMvd:lOK,1 )
   EndIf
NEXT nR
::oMvc:Update(.f.,1)
RETURN NIL

//------------------------------------//
METHOD ArmarLis( oDlg,oLbx ) CLASS TNotasc
   LOCAL aNC, cF, nL, hRes, oLF
If ::aMov[3] == 0
   MsgStop( "Grabar la Nota Credito","Primero tienes que" )
   RETURN NIL
EndIf
oLF := TListFac()
If oLF:Dialog( {::aMov[3],::aDF[1],"","Nota Credito"} )
   ::aMov[14] := ::oNvc:CLASE
   ::aMov[17] := ::oNvc:CONCEPTO
   ::aMov[18] := ::oNvc:FECHA
   ::aMov[19] := If( oApl:oEmp:PRINTIVA, "", TRANSFORM( ::aDF[1]*100,"99.9%" ) )
   oLF:LaserNCR( ::aMov,::aD,::aP,::oMvc:CONTROL )
   ::aMov[14] := 1
EndIf
RETURN NIL

//------------------------------------//
METHOD Barram( oDlg,oLbx ) CLASS TNotasc
   LOCAL oBar, oBot := ARRAY(7)
DEFINE BUTTONBAR oBar OF oDlg 3DLOOK SIZE 28,28

DEFINE BUTTON RESOURCE "DEDISCO" OF oBar NOBORDER TOOLTIP "Grabar (F11)";
   ACTION ::Guardar( oDlg,oLbx,.t. )
DEFINE BUTTON RESOURCE "DELREC"  OF oBar NOBORDER TOOLTIP "Anular Nota (F6)";
   ACTION ::AnulaCpte( oDlg,oLbx ) GROUP
DEFINE BUTTON oBot[4] RESOURCE "ELIMINAR" OF oBar NOBORDER ;
   TOOLTIP "Eliminar (Ctrl+DEL)" ;
   ACTION oLbx:KeyDown( VK_DELETE, 0 )
DEFINE BUTTON oBot[6] RESOURCE "PRINT"    OF oBar NOBORDER ;
   TOOLTIP "Imprimir" ;
   ACTION ::ArmarLis( oDlg,oLbx )
DEFINE BUTTON oBot[7] RESOURCE "QUIT"     OF oBar NOBORDER ;
   ACTION oDlg:End()             GROUP   TOOLTIP "Salir"
 oBar:bRClicked := {|| NIL }
 oBar:bLClicked := {|| NIL }
RETURN oBar

//------------------------------------//
PROCEDURE CreaCta( sCta,sNom,cQry,hRes )
cQry := "SELECT 1 FROM cgeplan "  +;
        "WHERE empresa = " + LTRIM(STR(oApl:nPUC))+;
         " AND cuenta  = '"+ sCta + "'"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If MSNumRows( hRes ) == 0
   cQry := "INSERT INTO cgeplan VALUES ( null, " +;
             LTRIM(STR(oApl:nPUC)) + ", '" + sCta + "', 4, '" + sNom +;
                   "%', 'NIT', 'DOCUMENTO', '', 'BASE', '0', 2, 'A' )"
   MSQuery( oApl:oMySql:hConnect,cQry )
EndIf
MSFreeResult( hRes )
RETURN