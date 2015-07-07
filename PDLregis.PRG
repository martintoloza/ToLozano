// Programa.: CAOREGIS.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Modulo para las Ventas por Mostrador
#include "Fivewin.ch"
#include "TSBrowse.ch"
#include "Btnget.ch"

MEMVAR oApl

#define CLR_PINK  nRGB( 128, 150, 150) //255, 128, 128
#define CLR_NBLUE nRGB( 128, 128, 192)

FUNCTION CaoRegis()
   LOCAL oDlg, oLbx, aColor[ 2 ], lNoBlink := .f.
   LOCAL aEst := { "Vigente","Cancelada","Anulada" }, nA, oBtn := ARRAY(11)
   LOCAL oAr, oM, oNi
oApl:oEmp:Seek( {"empresa",4} )
nEmpresa( .t. )
If oApl:oEmp:FEC_REM < DATE()
   CaoFactu( oApl:oEmp:FEC_REM,147," ","VENTA POR MOSTRADOR" )
   oApl:oEmp:FEC_REM := DATE() ; oApl:oEmp:REMISION := 0
   oApl:oEmp:Update( .t.,1 )
EndIf
If (aColor[ 1 ] := GetSysColor( COLOR_INACTIVECAPTION ) ) != ;
   GetSysColor( COLOR_ACTIVECAPTION )
   aColor[ 2 ] := GetSysColor( COLOR_INACTCAPTEXT )
   lNoBlink := .t.
   SBNoBlink()
EndIf
 oAr := TInv()  ; oAr:New()
 oM  := TCaja() ; oM:New()
 oNi := TNits() ; oNi:New()
SETKEY( VK_F4,{|| oM:cTipo := If( oM:cTipo == "Remision", "Pedido", "Remision" ),;
                  oM:Iniciar(), oDlg:Update(), oM:oG[2]:SetFocus() } )
oM:Iniciar()
oM:AdicArray()

DEFINE DIALOG oDlg RESOURCE "MOSTRADOR" OF oApl:oWnd
   REDEFINE GET oM:oG[01] VAR oM:dFechoy  ID  1 OF oDlg ;
      WHEN oM:lFecha                                    ;
      VALID ( oM:lFecha := .f. , .t. )
   REDEFINE SAY           VAR oM:cRemi    ID  2 OF oDlg UPDATE
   REDEFINE GET oM:oG[02] VAR oM:aM[2] ID  3 OF oDlg                  ;
      VALID( If( oM:dFecHoy < oApl:oEmp:FEC_REM .AND. oM:aM[2] == 0  ,;
               ( MsgStop("ESTA FECHA YA FUE FACTURADA"), .f. )       ,;
            (If( !oM:oCaj:Seek( { "fechoy",oM:dFecHoy,"remision"     ,;
                    oM:aM[2],"tipo_p",oM:aM[7] } ) .AND. oM:aM[2] # 0,;
               ( MsgStop("NO EXISTE",oM:cTipo), .f. )                ,;
               (oM:AdicArray(),  oLbx:aArray := oM:aV,  oDlg:Update(),;
                oM:Dscto( 0,oLbx ) ,;
                If( oM:oCaj:lOK, (oM:oG[2]:oJump := oLbx), ), .t. )))) )
   REDEFINE SAY           VAR oM:cSgte  ID  4 OF oDlg UPDATE COLOR "B+/W"
   REDEFINE BTNGET oM:oG[03] VAR oM:aM[3]   ID  6 OF oDlg            ;
      RESOURCE "BUSCAR"                                              ;
      ACTION EVAL({|| If( oNi:Mostrar(), ( oM:aM[3] :=               ;
                          oNi:oDb:CODIGO, oM:oG[03]:Refresh() ),) }) ;
      VALID EVAL( {|| If( oNi:Buscar( oM:aM[3],,,,.t. ),             ;
              (oM:oCaj:CODIGO_NIT := oNi:oDb:CODIGO_NIT             ,;
               oM:oCaj:DIRECCI    := oNi:oDb:DIRECCION              ,;
               oM:oCaj:TELEFON    := oNi:oDb:TELEFONO               ,;
               oM:aM[5] := oNi:oDb:NOMBRE, oDlg:Update(), .t. )     ,;
              (If( MsgYesNo("Desea ingresarlo","Este Nit no Existe"),;
                  oNi:Editar( ,.t.,,oM:aM[3] ), ),.f.) ) } ) UPDATE
   REDEFINE SAY           VAR oM:aM[5]         ID  7 OF oDlg UPDATE
   REDEFINE GET oM:oG[04] VAR oM:oCaj:CLIENTE  ID  9 OF oDlg UPDATE PICTURE "@!"
   REDEFINE GET oM:oG[05] VAR oM:oCaj:ENVIADO  ID 11 OF oDlg UPDATE PICTURE "@!"
   REDEFINE GET oM:oG[06] VAR oM:oCaj:DIRECCI  ID 13 OF oDlg UPDATE PICTURE "@!"
   REDEFINE GET oM:oG[07] VAR oM:oCaj:TELEFON  ID 15 OF oDlg UPDATE
   REDEFINE GET oM:oG[08] VAR oM:oCaj:FECHACOB ID 17 OF oDlg UPDATE ;
      WHEN LEFT(oM:cTipo,1) == "P"
   REDEFINE GET oM:oG[09] VAR oM:oCaj:FECHAENT ID 19 OF oDlg UPDATE ;
      WHEN LEFT(oM:cTipo,1) == "P"
   REDEFINE GET oM:oG[10] VAR oM:oCaj:HORA     ID 21 OF oDlg UPDATE PICTURE "99:99";
      WHEN LEFT(oM:cTipo,1) == "P"
   REDEFINE GET oM:oG[11] VAR oM:oCaj:TOMADOP  ID 23 OF oDlg UPDATE ;
      WHEN LEFT(oM:cTipo,1) == "P"
   REDEFINE SAY VAR aEst[oM:oCaj:ESTADO+1] ID 24 OF oDlg ;
      UPDATE COLOR nRGB( 255,0,0 )
   REDEFINE SAY VAR oM:oCaj:SALDO ID 26 OF oDlg PICTURE "999,999,999" UPDATE
   ACTIVAGET(oM:oG)

   REDEFINE BTNBMP oBtn[01] ID 30 OF oDlg RESOURCE "IMPRIMIR" ;
      ACTION oM:Listado( oDlg,oLbx )      MESSAGE "Imprime Remisión (F3)"
   REDEFINE BTNBMP oBtn[02] ID 31 OF oDlg RESOURCE "REINDEZAR";
      ACTION oLbx:KeyDown( VK_DELETE,0 )  MESSAGE "Borrar Código (Supr)"
   REDEFINE BTNBMP oBtn[03] ID 32 OF oDlg RESOURCE "DELREC"   ;
      ACTION oM:DelFactu( oDlg,oLbx )     MESSAGE "Anular Remisión (F6)"
   REDEFINE BTNBMP oBtn[04] ID 33 OF oDlg RESOURCE "NEW"      ;
      ACTION oM:Iniciar( oDlg,oLbx )      MESSAGE "Nueva Remisión (F7)"
   REDEFINE BTNBMP oBtn[05] ID 34 OF oDlg RESOURCE "DEDISCO"  ;
      ACTION oM:Guardar( oDlg,oLbx )      MESSAGE "Guardar Remisión (F11)"
   REDEFINE BTNBMP oBtn[06] ID 35 OF oDlg RESOURCE "OK"       ;
      ACTION oM:Pedido( oDlg,oLbx )       MESSAGE "Pasa Pedido a Remisión (F5)"
   REDEFINE BTNBMP oBtn[07] ID 36 OF oDlg RESOURCE "MIRAR"    ;
      ACTION (oM:Mostrar(), oM:Iniciar( oDlg,oLbx ));
      MESSAGE "Ver los Pagos (F8)"
   REDEFINE BTNBMP oBtn[08] ID 37 OF oDlg RESOURCE "VER"      ;
      ACTION CaoCoRep( 1,{oM:dFechoy,oM:dFechoy,.t.,"R",147,oApl:nTFor} );
      MESSAGE "Remisiones Pendientes"
   REDEFINE BTNBMP oBtn[09] ID 38 OF oDlg RESOURCE "MONEY"    ;
      ACTION CaoCoRep( 2,{oM:dFechoy,,.t.,"R",147,oApl:nTFor} );
      MESSAGE "Total de Ventas"
   REDEFINE BTNBMP oBtn[10] ID 39 OF oDlg RESOURCE "CORREO"   ;
      ACTION If( oM:aM[7] == "P", (oM:oCaj:NOTA :=            ;
                 Notas( oM:oCaj:NOTA,"Notas de PEDIDOS" )), ) ;
      MESSAGE "Notas de PEDIDOS (F9)"
   REDEFINE BTNBMP oBtn[11] ID 40 OF oDlg RESOURCE "SALIR"    ;
      ACTION oDlg:End()                   MESSAGE "Regresar al Menu"
   REDEFINE BROWSE oLbx ID 42 OF oDlg CELLED ;      // CELLED es requerida
      COLORS CLR_BLACK, CLR_NBLUE                   // para editar Celdas
   oLbx:SetArray( oM:aV )     // Esto es necesario para trabajar con arrays
//   oLbx:nFreeze     := 2
   oLbx:nHeightCell += 4
   oLbx:nHeightHead += 4
   oLbx:bKeyDown := {|nKey| If(nKey=VK_TAB, oLbx:oJump := oM:oG[3],;
                            If(nKey=VK_F3 , oBtn[01]:Click()      ,;
                            If(nKey=VK_F5 , oBtn[06]:Click()      ,;
                            If(nKey=VK_F6 , oBtn[03]:Click()      ,;
                            If(nKey=VK_F7 , oBtn[04]:Click()      ,;
                            If(nKey=VK_F8 , oBtn[07]:Click()      ,;
                            If(nKey=VK_F9 , oBtn[10]:Click()      ,;
                            If(nKey=VK_F11, oBtn[05]:Click(), )))))))) }
   oLbx:SetAppendMode( oM:lPedido )            // Activando Auto Append Mode
   oLbx:SetDeleteMode( .t.,.f.,{ |nAt,oLbx| oM:DelArray(oLbx) },;
                  {|oLbx| oM:Dscto( 0,oLbx ) } ) // lOnOff, lConfirm, bDelete

   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 1;
       TITLE "Código"+CRLF+"Artículo"            ;
       SIZE  90 EDITABLE;          // Esta columna es editable
       3DLOOK TRUE, TRUE, TRUE;    // Celda, Titulo, Footers
       MOVE DT_MOVE_NEXT;          // Cursor pasa a la Sig.Columna editable
       VALID { | uVar| oM:Buscar( uVar,oLbx ) }; // don't want empty rows
       ALIGN DT_LEFT, DT_CENTER  ; // Celda, Titulo, Footer
       PREEDIT {|uVar| oM:aM[11] := uVar, nA := oLbx:nAt ,;
                       oM:aM[13] := If( nA > LEN(oM:aV), 0, oM:aV[nA,10] ) };
       FOOTER { || STR( oLbx:nLen,4 ) + " Items" };
       WHEN oM:Editar( oLbx )
    oLbx:aColumns[01]:bPostEdit := { |uVar| ;
       oM:aV[nA,01] := oM:aM[11], oM:aV[nA,02] := oM:aM[12],;
       oM:aV[nA,03] := oM:aM[13], oM:aV[nA,05] := oM:aM[15],;
       oM:aV[nA,07] := oM:aM[14], oM:aV[nA,08] := oM:aM[16],;
       oM:aV[nA,11] := oM:aM[14], oM:aV[nA,12] := oM:aM[18], oM:Dscto( 1,oLbx ) }
     // activando BtnGet para la columna 1 y habilitando una Ayuda
    oLbx:SetBtnGet( 1, "Buscar", { | oGet,cVar | If( oAr:Mostrar() ,;
        (cVar := oAr:oDb:CODIGO, oGet:cText( cVar ), oGet:Refresh(),;
         oGet:KeyDown( VK_RETURN, 0 )), ) }, 16 )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 2;
       TITLE "Descripción" ;
       SIZE 180 ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_LEFT, DT_CENTER, DT_RIGHT;
       WHEN oM:Editar( oLbx ) ;
       FOOTER "Totales->"
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 3;
       TITLE "Precio"+CRLF+"Unitario" PICTURE "99,999,999";
       SIZE  74 ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 4;
       TITLE "Cantidad"      PICTURE "9,999.99" ;
       SIZE  58 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER ;
       POSTEDIT { |uVar| If( oLbx:lChanged, oM:Dscto( 4,oLbx,uVar ), ) } ;
       WHEN oM:Editar( oLbx ) ;
       VALID { |uVar| If( uVar > 0, .t. ,;
          (MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>" ), .f.) ) }
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 7;
       TITLE "Precio"+CRLF+"Neto"   PICTURE "99,999,999" ;
       SIZE  76 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       FOOTER { || TransForm( oM:aM[09], "99,999,999" ) };
       POSTEDIT { |uVar| If( oLbx:lChanged, oM:Dscto( 7,oLbx,uVar ), ) };
       WHEN oM:Editar( oLbx )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 5;
       TITLE "%"+CRLF+"Dscto."   PICTURE "999.99" ;
       SIZE  48 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER ;
       VALID { |uVar| If( Rango( uVar,0,100 ), .t., ;
              (MsgStop( "El Porcentaje debe ser entre 0 y 100",">>OJO<<" ), .f.)) };
       POSTEDIT { |uVar| If( oLbx:lChanged, oM:Dscto( 5,oLbx,uVar ), ) };
       WHEN oM:Editar( oLbx )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 6;
       TITLE "Descuento"     PICTURE "99,999,999" ;
       SIZE  74 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       VALID { |uVar| If( uVar >= 0, .t., ;
              (MsgStop("Descuento tiene que ser Positivo","<<OJO>>"), .f.)) };
       FOOTER { || TransForm( oM:aM[08], "99,999,999" ) };
       POSTEDIT { |uVar| If( oLbx:lChanged, oM:Dscto( 6,oLbx,uVar ), ) };
       WHEN oM:Editar( oLbx )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 8;
       TITLE "Monto"+CRLF+"I.V.A"   PICTURE "99,999,999" ;
       SIZE  74 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       FOOTER { || TransForm( oM:aM[10], "99,999,999" ) };
       POSTEDIT { |uVar| If( oLbx:lChanged, oM:Dscto( 0,oLbx,uVar ), ) };
       WHEN oM:Editar( oLbx )
   // Asignando Valores por defaults para nueva Fila creada con Auto Append.
   oLbx:aDefault := { SPACE(05), SPACE(40), 0, 1, 0, 0, 0, 0, " ", 0, 0, 1 }
   oLbx:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbx:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color
ACTIVATE DIALOG oDlg CENTERED ;
   VALID !GetKeyState( VK_ESCAPE )
If( lNoBlink, SBNoBlink( aColor[1], aColor[2] ), Nil )

oM:oCaj:Destroy()
oM:oPag:Destroy()
SETKEY( VK_F4,{||Empresa()} )

RETURN NIL

//------------------------------------//
CLASS TCaja

 DATA aM   AS ARRAY INIT { .f.,0,0,0,"",0,"",0,0,0,"","",0,0,0,0,0,0 }
 DATA aPag AS ARRAY INIT ArrayCombo( "FPAGO" )
 DATA lFecha        INIT .t.
 DATA lPedido       INIT .t.
 DATA dFechoy       INIT oApl:oEmp:FEC_REM
 DATA oG            INIT ARRAY(11)
 DATA oFont         INIT Tfont():New("Ms Sans Serif",0,-10,,.f.)
 DATA aV, cRemi, cTipo, cSgte, nIva, oCaj, oPag

 METHOD NEW() Constructor
 METHOD Iniciar( oDlg,oLbx )
 METHOD AdicArray()
 METHOD Editar( oLbx )
 METHOD Buscar( xBuscar,oLbx )
 METHOD Dscto( nPos,oLbx,mGetVar )
 METHOD DelArray( oLbx )
 METHOD DelFactu( oDlg,oLbx )
 METHOD Guardar( oDlg,oLbx )
 METHOD Listado( oDlg,oLbx )
 METHOD Pedido( oDlg,oLbx )
 METHOD Mostrar()
 METHOD Borrar( oLbx,lBorrar )
// METHOD CaoliRem()
ENDCLASS

//------------------------------------//
METHOD New() CLASS TCaja

::cTipo := "Remision"
::nIva  := ROUND( oApl:oEmp:PIVA/100,2 )
::oCaj  := oApl:Abrir( "cadcajac","Fechoy, Remision, Tipo_P",,,10 )
::oCaj:xBlank()
::oPag  := oApl:Abrir( "cadcajap",,,,10 )

RETURN NIL

//------------------------------------//
METHOD Iniciar( oDlg,oLbx ) CLASS TCaja
If oDlg == NIL
   ::aM[7] := LEFT( ::cTipo,1 )
   ::cRemi := "Nro. de " + ::cTipo
   ::cSgte := "Sgte. " + ::cTipo + STR(SgteNumero( ::cTipo,oApl:nEmpresa,.f. ),5)
Else
   AEVAL( ::aM, {|xV,nI| ::aM[nI] := {"",CTOD(""),.f.,0}[AT(VALTYPE(xV),"CDLN")] } )
   ::aM[7] := LEFT( ::cTipo,1 )
   ::AdicArray() ; oLbx:aArray := ::aV
   ::oCaj:xBlank()
   oDlg:Update() ; oLbx:Refresh()
   ::oG[02]:SetFocus()
EndIf
RETURN NIL

//------------------------------------//
METHOD AdicArray() CLASS TCaja
   LOCAL aRes, hRes, cQry, nL
::aV := {}
If ::aM[2] == 0
   ::aM[3] := 0
   ::lPedido:= .t.
   ::oCaj:lOK       := .f.
   ::oCaj:FECHACOB  := ::oCaj:FECHAENT  := ::dFechoy
   ::oCaj:CODIGO_NIT:= 147
Else
   ::lPedido:= !oApl:lEnLinea
/*   cQry := "SELECT * FROM cadcajad WHERE"      +;
            " FecHoy = '"+ AsMyDate(::dFecHoy) +;
     "' AND Remision = " + LTRIM(STR(::aM[2])) +;
      " AND Tipo_P   = '"+ ::aM[7] + "'"
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   While nL > 0
      aRes := MyReadRow( hRes )
      AEval( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      oApl:oInv:Seek( {"codigo",aRes[4]} )
      ::aM[18] := If( oApl:oInv:INDIVA = 0, 0, If( oApl:oInv:IMPUESTO = 0, ::nIva,;
                      ROUND(oApl:oInv:IMPUESTO/100,2) )) + 1
      ::aM[13] := ROUND( (aRes[6] + aRes[8] + aRes[9])/aRes[5],2 )
      AADD( ::aV,{ aRes[4] , oApl:oInv:DESCRIP ,;
                   ::aM[13], aRes[5]           ,;
                   aRes[7] , aRes[8]           ,;
                   aRes[6] , aRes[9], " "      ,;
                   aRes[1] , ::aM[13], ::aM[18] } )
      nL --
   EndDo*/
   cQry := "SELECT d.codigo, i.descrip, d.cantidad, d.despor, d.desmon, "+;
               "d.precioven, d.montoiva, d.row_id, i.indiva, i.impuesto "+;
           "FROM cadcajad d, cadinven i "            +;
           "WHERE d.fechoy = '"+ AsMyDate(::dFecHoy) +;
         "' AND d.remision = " + LTRIM(STR(::aM[2])) +;
          " AND d.tipo_p   = '"+ ::aM[7]             +;
         "' AND i.codigo   = d.codigo"
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   While nL > 0
      aRes := MyReadRow( hRes )
      AEval( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      ::aM[18] := If( aRes[09] == 0, 0,;
                  If( aRes[10] == 0, ::nIva, ROUND(aRes[10]/100,2) )) + 1
      ::aM[13] := ROUND( (aRes[5] + aRes[6] + aRes[7])/aRes[3],2 )
      AADD( ::aV,{ aRes[01] , aRes[02] , ::aM[13],;
                   aRes[03] , aRes[04] , aRes[05],;
                   aRes[06] , aRes[07] , " "     ,;
                   aRes[08] , ::aM[13] , ::aM[18] } )
      nL --
   EndDo
   MSFreeResult( hRes )
EndIf
If LEN( ::aV ) == 0
   AADD( ::aV,{ SPACE(05), SPACE(40), 0, 1, 0, 0, 0, 0, " ", 0, 0, 1 } )
EndIf
oApl:oNit:Seek( {"codigo_nit",::oCaj:CODIGO_NIT} )
::aM[3] := oApl:oNit:CODIGO ; ::aM[5] := oApl:oNit:NOMBRE //SPACE(35)
SysRefresh()
RETURN NIL

//------------------------------------//
METHOD Editar( oLbx ) CLASS TCaja
   LOCAL lEdit := .t., nA := oLbx:nAt, nF
If nA > LEN(::aV)
   nF := If( nA > 2, 1, nA-1 )
   If EMPTY( ::aV[nF,01] ) .OR. oLbx:nCell # 1
      MsgStop( "Primero Digite Código del Artículo","Nuevo" )
      oLbx:nAt   := oLbx:nLen := oLbx:nRowPos := nA
      oLbx:nCell := 1 ; lEdit := .f.
      oLbx:HiliteCell( 1 ) ; oLbx:Refresh(.t.)
      oLbx:DrawSelect()
   EndIf
Else
   If EMPTY( ::aV[nA,01] ) .AND. oLbx:nCell # 1
      MsgStop( "Primero Digite Código del Artículo" )
      oLbx:nCell := 1 ; lEdit := .f.
      oLbx:HiliteCell( 1 ) ; oLbx:Refresh()
   ElseIf ::oCaj:lOK .AND. ::oCaj:ESTADO > 0     // 1.Cancelada  2.Anulada
      MsgStop( "Este Registro no se Puede Modificar","Lo Siento" )
      lEdit := .f.
   EndIf
EndIf
RETURN lEdit

//------------------------------------//
METHOD Buscar( xBuscar,oLbx ) CLASS TCaja
   LOCAL nA, lExiste := oApl:oInv:Seek( {"codigo",xBuscar} )
If lExiste
   nA := oLbx:nAt
   ::aM[11] := xBuscar
   ::aM[12] := oApl:oInv:DESCRIP
   ::aM[18] := If( oApl:oInv:INDIVA = 0, 0, If( oApl:oInv:IMPUESTO = 0, ::nIva,;
                   ROUND(oApl:oInv:IMPUESTO/100,2) )) + 1
   If ::aM[13] == 0
      ::aM[13] := oApl:oInv:PPUBLI
      ::aM[14] := ROUND( ::aM[13] / ::aM[18],0 )
      ::aM[16] := ::aM[13] - ::aM[14]
   Else
      ::aM[13] := ::aV[nA,3]
      ::aM[14] := ROUND((::aV[nA,7] + ::aV[nA,8]) / ::aM[18],0 )
      ::aM[14] := ROUND((::aV[nA,6] + ::aM[14]) / ::aV[nA,4],0 )
      ::aM[15] := 0
      ::aM[16] := ::aV[nA,8]
   EndIf
ElseIf !EMPTY( xBuscar )
   MsgStop( "Este Código NO EXISTE !!!",xBuscar )
EndIf
RETURN If( EMPTY( xBuscar ), .f., lExiste )

//------------------------------------//
METHOD Dscto( nPos,oLbx,mGetVar ) CLASS TCaja
   LOCAL nSubTot, nA := oLbx:nAt
do Case
Case nPos == 5           // % Descuento
   ::aV[nA,06] := If( mGetVar == 0, 0, ::aV[nA,06] )
Case nPos == 7           // Precio Neto
   If ::aV[nA,04] > 1 .AND. mGetVar > 0
      If !MsgYesNo( "Este es el Precio Unitario","DIVIDIR" )
         mGetVar := ROUND( mGetVar/::aV[nA,04],2 )
      EndIf
   EndIf
   If ::aV[nA,12] > 1 .AND. mGetVar > 0
      If MsgYesNo( "Precio con IVA incluido","I.V.A."+STR(::aV[nA,12]) )
         mGetVar := ROUND( mGetVar / ::aV[nA,12],0 )
      EndIf
   EndIf
   ::aV[nA,11] := mGetVar
EndCase
If Rango( nPos,1,7 )
   nSubTot    := ROUND( ::aV[nA,11] * ::aV[nA,04],0 )
   ::aV[nA,6] := If( nPos == 6, mGetVar, If( ::aV[nA,05] = 0, ::aV[nA,06],;
                     ROUND( nSubTot * ::aV[nA,5] / 100,0 ) ) )
   ::aV[nA,7] := nSubTot - ::aV[nA,6]
   ::aV[nA,8] := ROUND( ::aV[nA,7] * ::aV[nA,12],0 ) - ::aV[nA,7]
EndIf
::aM[08] := ::aM[09] := ::aM[10] := 0
AEVAL( ::aV, { | e | ::aM[08] += e[ 6 ], ::aM[09] += e[ 7 ], ;
                      ::aM[10] += e[ 8 ] } )
::aM[09] += ::aM[10]
If ::oCaj:TOTALDES  # ::aM[08] .OR. ::oCaj:TOTALIVA # ::aM[10] .OR. ;
   ::oCaj:TOTALFAC  # ::aM[09] .OR. oLbx:lChanged
   ::oCaj:TOTALDES := ::aM[08] ; ::oCaj:TOTALIVA := ::aM[10]
   ::oCaj:TOTALFAC := ::aM[09]
EndIf
oLbx:Refresh() ; oLbx:DrawFooters()
RETURN NIL

//------------------------------------//
METHOD DelArray( oLbx ) CLASS TCaja
   LOCAL cQry, nA := oLbx:nAt
If ::aV[nA,10] > 0 .AND. !::aM[1]
   If MsgNoYes( "Elimina este Código",::aV[nA,01] )
      cQry := "DELETE FROM cadcajad WHERE Row_id = " + LTRIM(STR(::aV[nA,10]))
      MSQuery( oApl:oMySql:hConnect,cQry )
   EndIf
EndIf
::aM[1] := .f.
RETURN .t.

//------------------------------------//
METHOD DelFactu( oDlg,oLbx ) CLASS TCaja
   LOCAL cQry
If ::oCaj:lOK
   If ::oCaj:ESTADO == 1
      If MsgNoYes( " esta " + ::cTipo,"Modifica" )
         ::oCaj:ESTADO := 0 ; ::oCaj:SALDO := ::oCaj:TOTALFAC
         ::oCaj:ABONOS := 0 ; ::oCaj:Update(.f.,1)
         cQry := "DELETE FROM cadcajap WHERE " + ;
                 "Fecpag = '"+ AsMyDate(::dFecHoy) +;
           "' AND Numfac = " + LTRIM(STR(::aM[2]))
         MSQuery( oApl:oMySql:hConnect,cQry )
      EndIf
   ElseIf STR( ::oCaj:ESTADO,1 ) $ "02"
      cQry := If( ::oCaj:ESTADO == 0, "Anula", "Activa" )
      If MsgNoYes( " esta " + ::cTipo,cQry )
         ::oCaj:ESTADO := If( ::oCaj:ESTADO == 0, 2, 0 )
         ::oCaj:Update(.f.,1)
         oDlg:Update()
      EndIf
   EndIf
   If ::oCaj:ESTADO == 2
      ::Iniciar( oDlg,oLbx ) // Anulada
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Listado( oDlg,oLbx ) CLASS TCaja
If ::oCaj:lOK
   oApl:Tipo := ::oCaj:TIPO
   CaoLiFac( ::oCaj:REMISION,::aV,::cTipo,::oCaj )
   oApl:Tipo := "U"
   ::Iniciar( oDlg,oLbx )
/*
   If MsgNoYes( "Imprime esta Factura" )
      ::CaoliRem()
      ::Iniciar( oDlg,oLbx )
   EndIf
*/
EndIf
RETURN NIL

//------------------------------------//
METHOD Pedido( oDlg,oLbx ) CLASS TCaja
   LOCAL nA, dFec
If ::oCaj:lOK .AND. ::aM[7] == "P"
   If ::oCaj:FACTURADO == "S"
      MsgInfo( "PEDIDO ya esta Facturado",">>> OJO <<<" )
      RETURN NIL
   EndIf
   ::cTipo := "Remision"
   ::oCaj:NUMFAC    := SgteNumero( ::cTipo,oApl:nEmpresa,.f. )
   ::oCaj:FACTURADO := "S"
   ::oCaj:Update( .f.,1 )
   FOR nA := 1 TO LEN( ::aV )
      ::aV[nA,10] := 0
   NEXT
   ::dFecHoy := If( oApl:oEmp:FEC_REM == ::dFecHoy, ::dFecHoy, oApl:oEmp:FEC_REM )
   ::oCaj:lOK       := .f.; ::aM[7] := "R"
   ::oCaj:NOTA      := "" ; ::oCaj:CODIGO_NIT := 147
   ::oCaj:FECHACOB  := ::oCaj:FECHAENT := ::dFecHoy
   ::oCaj:FACTURADO := ""
   ::Guardar( oDlg,oLbx )
EndIf
RETURN NIL

//------------------------------------//
METHOD Guardar( oDlg,oLbx ) CLASS TCaja
   LOCAL aPago := {}, nPago, nAbono := 0
   LOCAL aRem, cQry, nR
If EMPTY( ::aV[1,1] )
   MsgStop( "no Tiene ningun Items",::cTipo )
   RETURN NIL
EndIf
oApl:nSaldo := ::oCaj:TOTALFAC - ::oCaj:ABONOS
If ::aM[7] == "R"
   oApl:oFac:CLIENTE := ::oCaj:CLIENTE
   While oApl:nSaldo > 0
      If CaoPagos( ,,::aPag,.t. ) .AND. !EMPTY( oApl:oPag:ABONO )
         nPago  := oApl:oPag:ABONO     + oApl:oPag:DEDUCCION +;
                   oApl:oPag:RETENCION + oApl:oPag:DESCUENTO +;
                   oApl:oPag:RETICA    + oApl:oPag:RETIVA    +;
                   oApl:oPag:RETFTE    + oApl:oPag:RETCRE
         nAbono += nPago
         oApl:nSaldo -= nPago
         AADD( aPago, { oApl:oPag:ABONO    , oApl:oPag:PAGADO   ,;
                        oApl:oPag:RETENCION, oApl:oPag:DEDUCCION,;
                        oApl:oPag:DESCUENTO, oApl:oPag:NUMCHEQUE,;
                        oApl:oPag:CODBANCO , oApl:oPag:FORMAPAGO,;
                        oApl:oPag:INDRED   , oApl:oPag:RETICA   ,;
                        oApl:oPag:RETIVA   , oApl:oPag:RETFTE   ,;
                        oApl:oPag:RETCRE   })
      Else
         Exit
      EndIf
   EndDo
   nAbono += ::oCaj:ABONOS
EndIf
::oCaj:ESTADO := If( oApl:nSaldo == 0, 1, 0 )
::oCaj:SALDO  := oApl:nSaldo
::oCaj:ABONOS += nAbono
If !::oCaj:lOK
   nR := SgteNumero( ::cTipo,oApl:nEmpresa,.f. )
   If !MsgYesNo("Factura #"+STR(nR),"Graba esta")
      RETURN NIL
   EndIf
   While .t.
      nR := SgteNumero( ::cTipo,oApl:nEmpresa,.t. )
      If !BuscaDup( nR,::aM[7],::dFechoy )
         EXIT
      EndIf
   EndDo
   ::oCaj:EMPRESA  := oApl:nEmpresa
   ::oCaj:TIPO     := oApl:Tipo
   ::oCaj:REMISION := nR
   ::oCaj:FECHOY   := ::dFecHoy
   ::oCaj:TIPO_P   := ::aM[7]
   ::oCaj:Append( .t. )
   ::cSgte := "Sgte. " + ::cTipo + STR( ::oCaj:REMISION + 1,5 )
Else
   ::oCaj:Update( .f.,1 )
EndIf
aRem := { MyDToMs( DTOS( ::dFechoy ) ),LTRIM(STR(::oCaj:REMISION)) }
FOR nR := 1 TO LEN( ::aV )
   If !EMPTY( ::aV[nR,01] )
      ::aV[nR,5] := If( ::aV[nR,5] # 0, ::aV[nR,5],  ;
                 ROUND( (::aV[nR,6] / (::aV[nR,6]+::aV[nR,7]))*100,2 ) )
      If ::aV[nR,10] == 0
         cQry := "INSERT INTO cadcajad VALUES ( null, '" +;
                 aRem[1] + "', " + aRem[2] + ", '" + TRIM(::aV[nR,1])   + "', "+;
                 LTRIM(STR(::aV[nR,4])) + ", " + LTRIM(STR(::aV[nR,7])) + ", "+;
                 LTRIM(STR(::aV[nR,5])) + ", " + LTRIM(STR(::aV[nR,6])) + ", "+;
                 LTRIM(STR(::aV[nR,8])) + ", '" + ::aM[7] + "' ) "
         MSQuery( oApl:oMySql:hConnect,cQry )
      Else
         cQry := "UPDATE cadcajad SET codigo = '" + TRIM(::aV[nR,1]) + "', " +;
                 "cantidad  = " + LTRIM(STR(::aV[nR,4])) + ", " +;
                 "precioven = " + LTRIM(STR(::aV[nR,7])) + ", " +;
                 "despor    = " + LTRIM(STR(::aV[nR,5])) + ", " +;
                 "desmon    = " + LTRIM(STR(::aV[nR,6])) + ", " +;
                 "montoiva  = " + LTRIM(STR(::aV[nR,8])) +;
                 " WHERE row_id = " + LTRIM(STR(::aV[nR,10]))
         MSQuery( oApl:oMySql:hConnect,cQry )
      EndIf
   EndIf
NEXT
If ::aM[7] == "R"
   aRem := LTRIM(STR(oApl:nEmpresa)) + ", " + aRem[2] + ", '" + ;
           oApl:Tipo + "', '" +  aRem[1] + "', "
   FOR nR := 1 TO LEN( aPago )
      cQry := "INSERT INTO cadcajap VALUES ( null, " + aRem +;
              LTRIM(STR(aPago[nR,01])) + ", " + LTRIM(STR(aPago[nR,02])) + ", " + ;
              LTRIM(STR(aPago[nR,03])) + ", " + LTRIM(STR(aPago[nR,04])) + ", " + ;
              LTRIM(STR(aPago[nR,05])) + ", '" + TRIM( aPago[nR,06] )  + "', '" + ;
               TRIM( aPago[nR,07] )  +  "', " + LTRIM(STR(aPago[nR,08])) + ;
              ", '', '" + MyLToMs( aPago[nR,09] ) + "', 'F', "           +;
              LTRIM(STR(aPago[nR,10])) + ", " + LTRIM(STR(aPago[nR,11])) + ", " + ;
              LTRIM(STR(aPago[nR,12])) + ", " + LTRIM(STR(aPago[nR,13])) +  " )"
      MSQuery( oApl:oMySql:hConnect,cQry )
   NEXT
// AbreCaja( "COM2:" )
EndIf
If MsgYesNo( "esta Remisión","Quiere Imprimir")
   oApl:Tipo := ::oCaj:TIPO
   CaoLiFac( ::oCaj:REMISION,::aV,::cTipo,::oCaj )
   oApl:Tipo := "U"
   //::CaoliRem()
EndIf
oLbx:nCell := oLbx:nColPos := 1
oLbx:HiliteCell( 1 )
::Iniciar( oDlg,oLbx )
RETURN NIL

//------------------------------------//
METHOD Mostrar() CLASS TCaja
   LOCAL oDlg, oLbp, cPict := "999,999,999.99"
::oPag:Seek( {"empresa",oApl:nEmpresa,"numfac",::aM[2],"fecpag",::dFecHoy} )
DEFINE DIALOG oDlg FROM 0, 3 TO 14,90 TITLE "Abonos de Remisiones"
   @ 0.5, 1 SAY ::oCaj:CLIENTE OF oDlg UPDATE COLOR CLR_BLACK, NIL;
      SIZE 100,18 FONT ::oFont
   @ 1.5,.5 LISTBOX oLbp FIELDS             DTOC( ::oPag:FECPAG )        ,;
        ::aPag[::oPag:FORMAPAGO+1,1]  ,           ::oPag:CODBANCO        ,;
     TRANSFORM(::oPag:PAGADO   ,cPict), TRANSFORM(::oPag:ABONO    ,cPict),;
     TRANSFORM(::oPag:DEDUCCION,cPict), TRANSFORM(::oPag:RETENCION,cPict),;
     TRANSFORM(::oPag:DESCUENTO,cPict),           ::oPag:NUMCHEQUE        ;
      HEADERS "Fecha", "FormaPago", "Banco", "Total Pago", "Monto Pago",;
              "DEDUCCION", "RETENCION", "DESCUENTO", "DOCUMENTO" ;
      SIZES 400,450 SIZE 338,70
    oLbp:nClrBackHead  := oApl:nClrBackHead
    oLbp:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbp:nClrBackFocus := oApl:nClrBackFocus
    oLbp:nClrForeFocus := oApl:nClrForeFocus
    oLbp:nHeaderHeight := 28
    oLbp:GoTop()
    oLbp:oFont     := ::oFont
    oLbp:aColSizes := {60,64,40,82,82,82,82,82,90}
    oLbp:aHjustify := {2,2,2,2,2,2,2,2,2}
    oLbp:aJustify  := {1,0,2,1,1,1,1,1,0}
    oLbp:bKeyDown  := {|nKey| If(nKey = VK_RETURN, ::Borrar( oLbp ),;
                              If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, ::Borrar(oLbp,.t.), ) ) }
    oLbp:lCellStyle  := oLbp:ladjbrowse  := .f.
    oLbp:ladjlastcol := .t.
   MySetBrowse( oLbp,::oPag )
ACTIVATE DIALOG oDlg CENTER
RETURN NIL

//------------------------------------//
METHOD Borrar( oLbx,lBorrar ) CLASS TCaja
   LOCAL nPG
If ::oCaj:FACTURADO == "S"
   MsgInfo( "REMISION ya esta Facturada",">>> OJO <<<" )
   RETURN NIL
EndIf
nPG := ::oPag:ABONO  + ::oPag:DEDUCCION + ::oPag:RETENCION + ::oPag:DESCUENTO +;
       ::oPag:RETICA + ::oPag:RETIVA    + ::oPag:RETFTE    + ::oPag:RETCRE
If lBorrar == NIL
   AEVAL( ::oPag:axBuffer, { |x,p| oApl:oPag:axBuffer[p] := x } )
   oApl:nSaldo := ::oCaj:SALDO + nPG
   If CaoPagos( .f.,.f.,::aPag,.t. )
      AEVAL( oApl:oPag:axBuffer, { |x,p| ::oPag:axBuffer[p] := x },6 )
      nPG := ::oPag:ABONO  + ::oPag:DEDUCCION + ::oPag:RETENCION + ::oPag:DESCUENTO+;
             ::oPag:RETICA + ::oPag:RETIVA    + ::oPag:RETFTE    + ::oPag:RETCRE - nPG
      ::oPag:Update(.t.,1)
      ::oCaj:SALDO  -= nPG
      ::oCaj:ABONOS += nPG
      ::oCaj:ESTADO := If( ::oCaj:SALDO == 0, 1, 0 )
      ::oCaj:Update(.t.,1)
   EndIf
Else
   If MsgNoYes("Eliminar este Pago","Quiere")
      If nPG # 0
         ::oCaj:ESTADO := 0
         ::oCaj:ABONOS -= nPG
         ::oCaj:SALDO  += nPG
         ::oCaj:Update(.t.,1)
      EndIf
      ::oPag:Delete(.t.,1)
   EndIf
EndIf
oLbx:Refresh()
RETURN NIL
/*
//------------------------------------//
METHOD CaoLiRem() CLASS TCaja
   LOCAL aRem, lPrecio, nL, nNeto, oRpt
If ::oCaj:TIPO == "U"
   aRem := { "PRODUCTOS  DO\A  LINDA S.A.S.","CARRERA 50 # 80-237         ",;
             "TEL: 3561508 - 586312- 458002","B/QUILLA  Nit. 890.114.941-5",;
             "PRODUCTOS  DO\A  LINDA S.A.S.",,0 }
Else
   aRem := { SPACE(29),SPACE(28),SPACE(29),SPACE(28),"ELIAS HANDAL.",,0 }
EndIf
If ::oCaj:TIPO_P == "P"
   aRem[6] :=  "  PEDIDO "
   aRem[7] := MlCount( TRIM(::oCaj:NOTA),78 )
Else
   aRem[6] :=  "REMISION "
EndIf
lPrecio := MsgNoYes( "Remision Con Precio ?",">>> LISTAR <<<" )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,,.f.,,,33,33 )
oRpt:nPage := 1
oRpt:SetFont( oRpt:CPINormal,82,1 )
oRpt:Say( 01,00,aRem[1] +  "              DULCES   ARABES   E  INTERNACIONALES" )
oRpt:Say( 02,00,aRem[2] + "               COMIDAS  ARABES  RAPIDAS   CALIENTES" )
oRpt:Say( 03,00,aRem[3] +  "              TARTALETAS - PUDINES - PIE - HELADOS" )
oRpt:Say( 04,00,aRem[4] + "               PICADAS  CALIENTES -  POSTRES  FRIOS" )
oRpt:SetFont( oRpt:CPICompress,144,1 )
oRpt:Say( 05,01,"  Cliente : " + oApl:oNit:NOMBRE + "  Nit. o C.C." )
oRpt:Say( 05,87,oRpt:CPINormal + aRem[6] + "No."  )
oRpt:Say( 06,01,"Pedido Por: " + ::oCaj:CLIENTE )
oRpt:Say( 06,45,FormatoNit( oApl:oNit:CODIGO,oApl:oNit:DIGITO ) )
oRpt:Say( 06,89,oRpt:CPINormal + STRZERO( ::oCaj:REMISION,8 ) )
oRpt:Say( 07,01,"Direccion : " + oApl:oNit:DIRECCION + ;
                 "  Telef. " + oApl:oNit:TELEFONO )
oRpt:Say( 07,81,oRpt:CPINormal+ "FECHA " + aRem[6] + NtChr( ::oCaj:FECHOY,"2" ) )
oRpt:Say( 08,13,::oCaj:DIRECCI + SPACE(09) + ::oCaj:TELEFON )
oRpt:Say( 08,81,oRpt:CPINormal+ "FECHA    COBRO " + NtChr( ::oCaj:FECHACOB,"2" ) )
oRpt:Say( 09,01,"   Ciudad : " + oApl:oNit:CIUDAD )
oRpt:Say( 09,45,"Enviado A " + ::oCaj:ENVIADO )
oRpt:Say( 09,81,oRpt:CPINormal+ "FECHA  ENTREGA " + NtChr( ::oCaj:FECHAENT,"2" ) )
oRpt:Say( 10,01,"Tomado Por: " + ::oCaj:TOMADOP )
oRpt:Say( 10,81,oRpt:CPINormal+ " HORA  ENTREGA " + ::oCaj:HORA )
oRpt:SetFont( oRpt:CPINormal,82,2 )
oRpt:Say( 11,01,"Codigo  Descripcion del Articulo        Cantidad  " + ;
             "Vr/Unitario  Valor Total" )
oRpt:Say( 12,01,REPLICATE( "_",74 ) )
oRpt:nL := 13
FOR nL := 1 TO LEN( ::aV )
   oRpt:Say( oRpt:nL,02,::aV[nL,01] )
   oRpt:Say( oRpt:nL,09,::aV[nL,02],34 )
   oRpt:Say( oRpt:nL,42,TRANSFORM(::aV[nL,04],"9,999.9") )
   If lPrecio
      nNeto := ::aV[nL,06] + ::aV[nL,07]    // DESMON + PRECIOVEN
      oRpt:Say( oRpt:nL,52,TRANSFORM(::aV[nL,03],"9,999,999") )
      oRpt:Say( oRpt:nL,65,TRANSFORM( nNeto     ,"9,999,999") )
   EndIf
   oRpt:nL ++
NEXT nL
If oRpt:nL <= (27 - aRem[7]) .AND. aRem[7] > 0
   oRpt:Say( oRpt:nL,06,">> Notas Pedido <<" )
   oRpt:SetFont( oRpt:CPICompress,144,1 )
   FOR nL := 1 TO aRem[7]
      oRpt:Say(++oRpt:nL,01,MEMOLINE( ::oCaj:NOTA,78,nL ) )
   NEXT nL
   oRpt:SetFont( oRpt:CPINormal,82,2 )
EndIf
If lPrecio
   nNeto := ::oCaj:TOTALFAC - ::oCaj:TOTALIVA + ::oCaj:TOTALDES
   oRpt:Say( 27,01,"Subtotal $"+ TRANSFORM(nNeto,"9,999,999") )
   If ::oCaj:TOTALDES > 0
      oRpt:Say( 27,22,"Dsto."+ TRANSFORM(::oCaj:TOTALDES,"9,999,999") )
   EndIf
    If ::oCaj:FECHOY >= CTOD("01.01.2013")
       oRpt:Say( 27,38,"ImpoConsumo" + TRANSFORM(::oCaj:TOTALIVA,"9,999,999") )
    Else
       oRpt:Say( 27,38,"I.V.A." + TRANSFORM(::oCaj:TOTALIVA,"9,999,999") )
    EndIf
   oRpt:Say( 27,60,"Total $"+ TRANSFORM(::oCaj:TOTALFAC,"9,999,999") )
   oRpt:Say( 28,10,"PAGUE A LA FECHA Y NO PIERDA SU CREDITO          "+;
                    REPLICATE( "=",19 ) )
EndIf
oRpt:SetFont( oRpt:CPICompress,144,1 )
oRpt:Say( 29,01,"DESPUES DEL VENCIMIENTO SE COBRARA EL 3.5% DE MORA POR MES "+;
            "O FRACCION. ESTA REMISION SE ASIMILA EN TODOS SUS EFECTOS "      +;
            "LEGALES A LA LETRA" )
oRpt:Say( 30,01,"DE CAMBIO ( CODIGO DE COMERCIO ART.774 ). FAVOR GIRAR CHEQUE "+;
            "CRUZADO A " + aRem[5] + "  DEVOLVERSE FIRMADA Y SELLADA." )
oRpt:NewPage()
oRpt:End()
RETURN NIL
*/
//------------------------------------//
STATIC FUNCTION AbreCaja( cPort )
   LOCAL oPuerto
   DEFAULT cPort := "COM2:"
/*
   oPuerto:Say( 1,01,CHR(27)+CHR(112)+CHR(0)+CHR(20)+CHR(80) )
   Run Mode com2:24,n,8,1
   Run Type D:\Inven\x.cop > com2
   WAITRUN( 'Caja.bat' )
   MsgInfo( ">>> Pulse Cualquier Tecla para Continar <<<" )
*/
oPuerto := TDosPrint():New( cPort )
oPuerto:Say( 1,01,CHR(130) )
oPuerto:End()
RETURN NIL