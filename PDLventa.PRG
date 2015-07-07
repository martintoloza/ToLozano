// Programa.: CAOVENTA.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Modulo para la Elaboracion de las Facturas
#include "Fivewin.ch"
#include "TSBrowse.ch"
#include "Btnget.ch"

MEMVAR oApl

#define CLR_PINK  nRGB( 128, 150, 150) //255, 128, 128
#define CLR_NBLUE nRGB( 128, 128, 192)

FUNCTION CaoVenta( lCoti )
   LOCAL oDlg, oLbx, aColor[ 2 ], lNoBlink := .f.
   LOCAL bAyuda, cTit, nA, oBtn := ARRAY(9)
   LOCAL oAr, oF, oNi //, oDp
If (aColor[ 1 ] := GetSysColor( COLOR_INACTIVECAPTION ) ) != ;
   GetSysColor( COLOR_ACTIVECAPTION )
   aColor[ 2 ] := GetSysColor( COLOR_INACTCAPTEXT )
   lNoBlink := .t.
   SBNoBlink()
EndIf
 oAr := TInv()     ; oAr:New()
// oDp := TPer()     ; oDp:New()
 oF  := TFactura() ; oF:New()
 oNi := TNits()    ; oNi:New()
oApl:Tipo := oF:cTipo := If( lCoti, "Z", "U" )
cTit := If( lCoti, "Cotizaciones", "Ventas - Facturas" ) + " || "
oApl:oEmp:Seek( {"empresa",4} )
nEmpresa( .t. )
//bAyuda:= {|| If( oDp:Mostrar(), (oDp:xVar := oDp:oDb:NROIDEN   ,;
//                 oF:oG[4]:Refresh(), oF:oG[4]:lValid(.f.)), .f. ) }
oF:Iniciar()
oF:AdicArray()
SETKEY( VK_F4,{|| If( Empresa(), ( oDlg:SetText(cTit + oApl:cEmpresa),;
                      oF:Iniciar(), oDlg:Update() ), ), oF:oG[1]:SetFocus() } )
DEFINE DIALOG oDlg RESOURCE "FACTURAS" TITLE cTit + oApl:cEmpresa OF oApl:oWnd
   REDEFINE SAY           VAR oF:nSigFac  ID  1 OF oDlg UPDATE COLOR "B+/W"
   REDEFINE BTNGET oF:oG[01] VAR oF:aM[2] ID  3 OF oDlg               ;
      RESOURCE "BUSCAR"                                               ;
      ACTION EVAL({|| If(oF:Mostrar(), (oF:aM[2] := oF:oDb:NUMFAC    ,;
                        oApl:nEmpresa := oF:oDb:EMPRESA              ,;
                        oApl:Tipo     := oF:oDb:TIPO                 ,;
                        oF:oG[1]:Refresh(), oF:oG[1]:lValid(.f.)),)}) ;
      VALID( If( !oApl:oFac:Seek( { "empresa",oApl:nEmpresa,"numfac" ,;
                      oF:aM[2],"tipo",oApl:Tipo} ) .AND. oF:aM[2] # 0,;
               ( MsgStop("Factura NO EXISTE"), .f. )                 ,;
               (oF:AdicArray(),  oLbx:aArray := oF:aV,  oDlg:Update(),;
                oF:Dscto( 0,oLbx ) ,;
                If( oApl:oFac:lOK, (oF:oG[1]:oJump := oLbx), ), .t. )))
//                oDp:xVar := oF:aM[4], oDlg:Update(), oF:Dscto( 0,oLbx ) ,;
   REDEFINE GET oF:oG[02] VAR oApl:oFac:FECHOY   ID  5 OF oDlg UPDATE ;
      VALID oF:Fechas( oApl:oFac:lOK,1,oDlg,oLbx ) ;
      WHEN  oF:aPrv[2]
   REDEFINE BTNGET oF:oG[03] VAR oF:aM[3]   ID  7 OF oDlg            ;
      RESOURCE "BUSCAR"                                              ;
      ACTION EVAL({|| If( oNi:Mostrar(), ( oF:aM[3] :=               ;
                          oNi:oDb:CODIGO, oF:oG[03]:Refresh() ),) }) ;
      VALID EVAL( {|| If( oNi:Buscar( oF:aM[3],"codigo",.t. )       ,;
              (oApl:oFac:CODIGO_NIT := oNi:oDb:CODIGO_NIT           ,;
               oApl:oFac:DIRECC     := oNi:oDb:DIRECCION            ,;
               oApl:oFac:TELEFONO   := oNi:oDb:TELEFONO             ,;
               oF:aM[5] := oNi:oDb:NOMBRE, oDlg:Update(), .t. )     ,;
              (If( MsgYesNo("Desea ingresarlo","Este Nit no Existe"),;
                  oNi:Editar( ,.t.,,oF:aM[3] ), ),.f.) ) } ) UPDATE
   REDEFINE SAY           VAR oF:aM[5]      ID  8 OF oDlg UPDATE
   REDEFINE BTNGET oF:oG[04] VAR oApl:oFac:CEDULA  ID 10 OF oDlg
/*      RESOURCE "BUSCAR"      PICTURE "@K9"                               ;
      ACTION EVAL( bAyuda )                                              ;
      VALID EVAL( {|| If( !oDp:oDb:Buscar( oDp:xVar,,,,.t. ) .AND.       ;
                  !EMPTY(oDp:xVar), (EVAL( bAyuda )), ( If( oDp:oDb:lOK ,;
             (oApl:oFac:CLIENTE := LEFT(oDp:oDb:NOMBRES,oDp:oDb:PNOMB+1)+;
                oDp:oDb:APELLIDOS  ,  oF:aM[4] := oDp:xVar              ,;
              oApl:oFac:DIRECC     := oDp:oDb:DIRECCION                 ,;
              oApl:oFac:TELEFONO   := LEFT(oDp:oDb:TEL_RESIDE,8)        ,;
              oApl:oFac:CODIGO_CLI := oDp:oDb:CODIGO_NIT,                ;
              oDlg:Update() ), ), .t. ) ) } ) UPDATE                     ;
      WHEN oApl:lEnlinea*/
   REDEFINE GET oF:oG[05] VAR oApl:oFac:CLIENTE   ID 11 OF oDlg UPDATE PICTURE "@!"
   REDEFINE GET oF:oG[06] VAR oApl:oFac:FECHAVEN  ID 13 OF oDlg UPDATE
   REDEFINE GET oF:oG[07] VAR oApl:oFac:FECHACOB  ID 15 OF oDlg UPDATE
   REDEFINE GET oF:oG[08] VAR oApl:oFac:ENVIADO_A ID 17 OF oDlg UPDATE PICTURE "@!"
   REDEFINE GET oF:oG[09] VAR oApl:oFac:DIRECC    ID 19 OF oDlg UPDATE PICTURE "@!"
   REDEFINE GET oF:oG[10] VAR oApl:oFac:TELEFONO  ID 21 OF oDlg UPDATE
   REDEFINE SAY VAR oF:aM[6]    ID 23 OF oDlg UPDATE
   REDEFINE SAY VAR oApl:nSaldo ID 25 OF oDlg PICTURE "999,999,999" UPDATE
   REDEFINE SAY VAR oF:aM[7]    ID 26 OF oDlg UPDATE COLOR nRGB( 255,0,0 )
   ACTIVAGET(oF:oG)

   REDEFINE BTNBMP oBtn[1] ID 30 OF oDlg RESOURCE "IMPRIMIR" ;
      ACTION oF:Listado( oDlg,oLbx )     MESSAGE "Imprime Factura (F3)"
   REDEFINE BTNBMP oBtn[2] ID 31 OF oDlg RESOURCE "REINDEZAR";
      ACTION ( oF:aM[1] := .t., oLbx:KeyDown( VK_DELETE,0 ) );
      MESSAGE "Borrar Código (F5)"
   REDEFINE BTNBMP oBtn[3] ID 32 OF oDlg RESOURCE "DELREC"   ;
      ACTION oF:DelFactu( oDlg,oLbx )    MESSAGE "Anular Factura (F6)"
   REDEFINE BTNBMP oBtn[4] ID 33 OF oDlg RESOURCE "NEW"      ;
      ACTION oF:Iniciar( oDlg,oLbx )     MESSAGE "Nueva Factura (F7)"
   REDEFINE BTNBMP oBtn[5] ID 34 OF oDlg RESOURCE "DEDISCO"  ;
      ACTION oF:Guardar( oDlg,oLbx )     MESSAGE "Grabar Factura (F11)"
   REDEFINE BTNBMP oBtn[6] ID 35 OF oDlg RESOURCE "MIRAR"    ;
      ACTION (oF:Abonos(), oF:Iniciar( oDlg,oLbx ));
      MESSAGE "Ver los Pagos (F8)"
   REDEFINE BTNBMP oBtn[7] ID 36 OF oDlg RESOURCE "MONEY"    ;
      ACTION (CaoPagos(.t.), oF:Iniciar( oDlg,oLbx ));
      MESSAGE "Pagos a Cartera"
   REDEFINE BTNBMP oBtn[8] ID 37 OF oDlg RESOURCE "CALC"     ;
      ACTION WinExec("Calc")             MESSAGE "Calculadora"
   REDEFINE BTNBMP oBtn[9] ID 38 OF oDlg RESOURCE "SALIR"    ;
      ACTION oDlg:End()                  MESSAGE "Regresar al Menu"
   REDEFINE BROWSE oLbx ID 40 OF oDlg CELLED ;      // CELLED es requerida
      COLORS CLR_BLACK, CLR_NBLUE                   // para editar Celdas
   oLbx:SetArray( oF:aV )     // Esto es necesario para trabajar con arrays
//   oLbx:nFreeze     := 2
   oLbx:nHeightCell += 4
   oLbx:nHeightHead += 4
   oLbx:bKeyDown := {|nKey| If(nKey=VK_TAB, oLbx:oJump := oF:oG[3],;
                            If(nKey=VK_F3 , oBtn[1]:Click() ,;
                            If(nKey=VK_F5 , oBtn[2]:Click() ,;
                            If(nKey=VK_F6 , oBtn[3]:Click() ,;
                            If(nKey=VK_F7 , oBtn[4]:Click() ,;
                            If(nKey=VK_F8 , oBtn[6]:Click() ,;
                            If(nKey=VK_F9 , Notas( oApl:oEmp:NOTA ),;
                            If(nKey=VK_F11, oBtn[5]:Click() , )))))))) }
   oLbx:SetAppendMode( oF:lNuevo )            // Activando Auto Append Mode
   oLbx:SetDeleteMode( .t.,.f.,{ |nAt,oLbx| oF:DelArray(oLbx) },;
                  {|oLbx| oF:Dscto( 0,oLbx ) } ) // lOnOff, lConfirm, bDelete

   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 1;
       TITLE "Código"+CRLF+"Artículo"            ;
       SIZE  90 EDITABLE;          // Esta columna es editable
       3DLOOK TRUE, TRUE, TRUE;    // Celda, Titulo, Footers
       MOVE DT_MOVE_NEXT;          // Cursor pasa a la Sig.Columna editable
       VALID { | uVar| oF:Buscar( uVar,oLbx ) }; // don't want empty rows
       ALIGN DT_LEFT, DT_CENTER  ; // Celda, Titulo, Footer
       PREEDIT {|uVar| oF:aM[11] := uVar, nA := oLbx:nAt ,;
                       oF:aM[13] := If( nA > LEN(oF:aV), 0, oF:aV[nA,10] ) };
       FOOTER { || STR( oLbx:nLen,4 ) + " Items" };
       WHEN oF:EditArray( oLbx )
    oLbx:aColumns[01]:bPostEdit := { |uVar| ;
       oF:aV[nA,01] := oF:aM[11], oF:aV[nA,02] := oF:aM[12],;
       oF:aV[nA,03] := oF:aM[13], oF:aV[nA,05] := oF:aM[15],;
       oF:aV[nA,07] := oF:aM[14], oF:aV[nA,08] := oF:aM[16],;
       oF:aV[nA,11] := oF:aM[14], oF:aV[nA,12] := oF:aM[18], oF:Dscto( 1,oLbx ) }
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
       WHEN oF:EditArray( oLbx ) ;
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
       POSTEDIT { |uVar| If( oLbx:lChanged, oF:Dscto( 4,oLbx,uVar ), ) } ;
       WHEN oF:EditArray( oLbx ) ;
       VALID { |uVar| If( uVar > 0, .t. ,;
          (MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>" ), .f.) ) }
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 7;
       TITLE "Precio"+CRLF+"Neto"   PICTURE "99,999,999" ;
       SIZE  76 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       FOOTER { || TransForm( oF:aM[09], "99,999,999" ) };
       POSTEDIT { |uVar| If( oLbx:lChanged, oF:Dscto( 7,oLbx,uVar ), ) };
       WHEN oF:EditArray( oLbx )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 5;
       TITLE "%"+CRLF+"Dscto."   PICTURE "999.99" ;
       SIZE  48 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER ;
       VALID { |uVar| If( Rango( uVar,0,100 ), .t., ;
              (MsgStop( "El Porcentaje debe ser entre 0 y 100",">>OJO<<" ), .f.)) };
       POSTEDIT { |uVar| If( oLbx:lChanged, oF:Dscto( 5,oLbx,uVar ), ) };
       WHEN oF:EditArray( oLbx )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 6;
       TITLE "Descuento"     PICTURE "99,999,999" ;
       SIZE  74 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       VALID { |uVar| If( uVar >= 0, .t., ;
              (MsgStop("Descuento tiene que ser Positivo","<<OJO>>"), .f.)) };
       FOOTER { || TransForm( oF:aM[08], "99,999,999" ) };
       POSTEDIT { |uVar| If( oLbx:lChanged, oF:Dscto( 6,oLbx,uVar ), ) };
       WHEN oF:EditArray( oLbx )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 8;
       TITLE "Monto"+CRLF+"I.V.A"   PICTURE "99,999,999" ;
       SIZE  74 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       FOOTER { || TransForm( oF:aM[10], "99,999,999" ) };
       POSTEDIT { |uVar| If( oLbx:lChanged, oF:Dscto( 0,oLbx,uVar ), ) };
       WHEN oF:EditArray( oLbx )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 9;
       TITLE "Indicador" ;
       SIZE  80 ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_LEFT, DT_CENTER
   // Asignando Valores por defaults para nueva Fila creada con Auto Append.
   oLbx:aDefault := { SPACE(12), SPACE(40), 0, 1, 0, 0, 0, 0, " ", 0, 0, 1 }
   oLbx:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbx:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color
ACTIVATE DIALOG oDlg CENTERED ;
   VALID !GetKeyState( VK_ESCAPE )
If( lNoBlink, SBNoBlink( aColor[1], aColor[2] ), Nil )
oApl:oEmp:Seek( {"empresa",oF:nOptica} )
oF:oMvc:Destroy()
oF:oMvd:Destroy()
oF:oVen:Destroy()
SETKEY( VK_F4,{||Empresa()} )
nEmpresa( .f. )
RETURN NIL

//------------------------------------//
CLASS TFactura FROM TNits

 DATA aM   AS ARRAY INIT { .f.,0,0,0,"",0,"",0,0,0,"","",0,0,0,0,0,0 }
 DATA aPag AS ARRAY INIT ArrayCombo( "FPAGO" )
 DATA lNuevo        INIT .t.
 DATA oG            INIT ARRAY(10)
 DATA aPrv, aV, cTipo, nIva, lCierre, nSigFac, nOptica
 DATA oMvc, oMvd, oVen

 METHOD NEW() Constructor
 METHOD Iniciar( oDlg,oLbx )
 METHOD AdicArray()
 METHOD EditArray( oLbx )
 METHOD Buscar( xBuscar,oLbx )
 METHOD Dscto( nPos,oLbx,mGetVar )
 METHOD DelArray( oLbx )
 METHOD DelFactu( oDlg,oLbx )
 METHOD FechaDev( cMsg )
 METHOD Fechas( lOK,nMsg,oDlg,oLbx )
 METHOD Guardar( oDlg,oLbx )
 METHOD Listado( oDlg,oLbx )
 METHOD Abonos()
 METHOD Borrar( oLbx,oLbf )
 METHOD Editar( lNuevo,oLbx )
 METHOD Mostrar( lAyuda,nOrd )

ENDCLASS

//------------------------------------//
METHOD New() CLASS TFactura
 Super:New( oApl:oFac )
 ::aOrden := { {"<None> ",1},{"Factura",3},;
               {"Nombre" ,6},{"Fecha"  ,5} }
 ::bNew := ::bEditar := ::bVer := {||.t. }
 ::oVen := oApl:Abrir( "cadventa","empresa, numfac, tipo",,,50 )
 ::oMvc := oApl:Abrir( "cgemovc" ,"empresa, ano_mes, control",.t.,,5 )
 ::oMvd := oApl:Abrir( "cgemovd" ,"empresa, ano_mes, control",.t.,,10 )
 ::aPrv := Privileg( "FACTURAS" )
 oApl:oFac:xBlank()
RETURN NIL

//------------------------------------//
METHOD Iniciar( oDlg,oLbx ) CLASS TFactura
If oDlg == NIL
   ::nIva    := ROUND( oApl:oEmp:PIVA/100,2 )
   ::nOptica := oApl:nEmpresa
   ::nSigFac := SgteNumero( "NUMFAC"+oApl:Tipo,::nOptica,.f. )
Else
   AEVAL( ::aM, {|xV,nI| ::aM[nI] := {"",CTOD(""),.f.,0}[AT(VALTYPE(xV),"CDLN")] } )
   ::AdicArray() ; oLbx:aArray := ::aV
   oApl:oFac:xBlank()
   oDlg:Update() ; oLbx:Refresh()
   ::oG[01]:SetFocus()
EndIf
RETURN NIL

//------------------------------------//
METHOD AdicArray() CLASS TFactura
   LOCAL cOpt := ""
If ::aM[2] == 0
   ::aM[3] := oApl:nSaldo := 0
   ::aM[4] := SPACE(15)
   ::lNuevo:= .t.
   oApl:oNit:Seek( {"codigo",::aM[3]} )
   oApl:nEmpresa := ::nOptica ; oApl:Tipo := ::cTipo
   oApl:oFac:lOK       := .f.
   oApl:oFac:FECHOY    := oApl:dFec
   oApl:oFac:FECHAVEN  := oApl:dFec + 7
   oApl:oFac:CODIGO_NIT:= oApl:oNit:CODIGO_NIT
   oApl:oFac:INDICADOR := "P"
Else
   oApl:oNit:Seek( {"codigo_nit",oApl:oFac:CODIGO_NIT} )
//   oApl:oHis:Seek( {"codigo_nit",oApl:oFac:CODIGO_CLI} )
   oApl:cPer:= NtChr( oApl:dFec,"1" )
   oApl:lFam:= SaldoFac( ::aM[2] )
   ::aM[4] := SPACE(15) //oApl:oHis:NROIDEN
   ::lNuevo:= !oApl:lEnLinea
   cOpt := If( ::nOptica == oApl:oFac:EMPRESA, "",;
               ArrayValor( oApl:aOptic,STR(oApl:oFac:EMPRESA,2) ) )
EndIf
::Fechas( .f. )
::aV := {}
::oVen:Seek( {"empresa",oApl:nEmpresa,"numfac",::aM[2],"tipo",oApl:Tipo} )
While !::oVen:Eof()
   oApl:oInv:Seek( {"codigo",::oVen:CODIGO} )
   ::aM[18] := If( oApl:oInv:INDIVA = 0, 0, If( oApl:oInv:IMPUESTO = 0, ::nIva,;
                   ROUND(oApl:oInv:IMPUESTO/100,2) )) + 1
   ::aM[13] := ROUND( (::oVen:PRECIOVEN + ::oVen:DESMON + ::oVen:MONTOIVA)/;
                       ::oVen:CANTIDAD,2 )
   AADD( ::aV,{ ::oVen:CODIGO    , oApl:oInv:DESCRIP    ,;
                ::aM[13]         , ::oVen:CANTIDAD      ,;
                ::oVen:DESPOR    , ::oVen:DESMON        ,;
                ::oVen:PRECIOVEN , ::oVen:MONTOIVA      ,;
                ::oVen:INDICADOR+"-"+DTOC(::oVen:FECDEV),;
                ::oVen:ROW_ID    , ::aM[13], ::aM[18] } )
   ::oVen:Skip(1):Read()
   ::oVen:xLoad()
EndDo
If LEN( ::aV ) == 0
   AADD( ::aV,{ SPACE(12), SPACE(40), 0, 1, 0, 0, 0, 0, " ", 0, 0, 1 } )
EndIf
::aM[3] := oApl:oNit:CODIGO ; ::aM[5] := oApl:oNit:NOMBRE
::aM[6] := oApl:oFac:TOTALFAC
//::aM[7] := If( oApl:oFac:INDICADOR == "A", "Factura ANULADA", cOpt )
::aM[7] := { "ANULADA","PENDIENTE","CANCELADA" }[AT( oApl:oFac:INDICADOR,"APC" )]
SysRefresh()
RETURN NIL

//------------------------------------//
METHOD EditArray( oLbx ) CLASS TFactura
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
   ElseIf oApl:oFac:lOK .AND. (!::aPrv[2] .OR. LEFT( ::aV[nA,09],1 ) $ "AD")
      MsgStop( "Este Registro no se Puede Modificar","Lo Siento" )
      lEdit := .f.
   EndIf
EndIf
RETURN lEdit

//------------------------------------//
METHOD Buscar( xBuscar,oLbx ) CLASS TFactura
   LOCAL nA, lExiste := oApl:oInv:Seek( {"codigo",xBuscar} )
If lExiste
   nA := oLbx:nAt
   ::aM[11] := xBuscar
   ::aM[12] := oApl:oInv:DESCRIP
   ::aM[18] := If( oApl:oInv:INDIVA = 0, 0, If( oApl:oInv:IMPUESTO = 0, ::nIva,;
                   ROUND(oApl:oInv:IMPUESTO/100,2) )) + 1
   If ::aM[13] == 0
      ::aM[13] := oApl:oInv:PPUBLI
//      ::aM[14] := ROUND( ::aM[13] - (::aM[13] * ::aM[18]),0 )
      ::aM[14] := ROUND( ::aM[13] / ::aM[18],0 )
      ::aM[16] := ::aM[13] - ::aM[14]
   Else
      ::aM[13] := ::aV[nA,3]
      ::aM[14] := ROUND((::aV[nA,7] + ::aV[nA,8]) / ::aM[18],0 )
      ::aM[14] := ROUND((::aV[nA,6] + ::aM[14]) / ::aV[nA,4],0 )
      ::aM[15] := 0
      ::aM[16] := ::aV[nA,8]
   EndIf
   If nA <= LEN( ::aV )
      ::aM[15] := If( ::aV[nA,06] + ::aV[nA,10] == 0,;
                       oApl:oNit:POR_DSCTO, ::aV[nA,05] )
   EndIf
ElseIf !EMPTY( xBuscar )
   MsgStop( "Este Código NO EXISTE !!!",xBuscar )
EndIf
RETURN If( EMPTY( xBuscar ), .f., lExiste )

//------------------------------------//
METHOD Dscto( nPos,oLbx,mGetVar ) CLASS TFactura
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
   //nSubTot    -= ::aV[nA,6]
   //::aV[nA,7] := ROUND( nSubTot / ::aV[nA,12],0 )
   //::aV[nA,8] := nSubTot - ::aV[nA,7]
EndIf
::aM[08] := ::aM[09] := ::aM[10] := 0
AEVAL( ::aV, { | e | ::aM[08] += e[ 6 ], ::aM[09] += e[ 7 ], ::aM[10] += e[ 8 ] } )
::aM[09] += ::aM[10]
If oApl:oFac:TOTALDES  # ::aM[08] .OR. oApl:oFac:TOTALIVA # ::aM[10] .OR. ;
   oApl:oFac:TOTALFAC  # ::aM[09] .OR. oLbx:lChanged
   oApl:oFac:TOTALDES := ::aM[08] ; oApl:oFac:TOTALIVA := ::aM[10]
   oApl:oFac:TOTALFAC := ::aM[09]
EndIf
oLbx:Refresh() ; oLbx:DrawFooters()
RETURN NIL

//------------------------------------//
METHOD DelArray( oLbx ) CLASS TFactura
   LOCAL dFecdev, lSi := .f., nA := oLbx:nAt
do Case
Case ::aV[nA,10] == 0
   lSi := .t.
Case ::aM[1] .AND. oApl:oFac:lOK .AND. ::aPrv[3]
   If MsgNoYes( "Elimina este Código",::aV[nA,01] )
      ::oVen:Seek( {"row_id",::aV[nA,10]} )
      If LEFT( ::aV[nA,09],1 ) $ "AD"
         Actualiz( ::aV[nA,01],-::aV[nA,04],::oVen:FECDEV,7 )
      EndIf
         Actualiz( ::aV[nA,01],-::aV[nA,04],oApl:oFac:FECHOY,2 )
      ::oVen:Delete(.f.,1)
      lSi := .t.
   EndIf
EndCase
::aM[1] := .f.
RETURN lSi

//------------------------------------//
METHOD DelFactu( oDlg,oLbx ) CLASS TFactura
   LOCAL dFecdev, cPerF := oApl:cPer, mCant, nTipo, nR
If !oApl:oFac:lOK
   If EMPTY( ::aV[1,01] )
      oApl:oFac:INDICADOR := "A"
      ::Guardar( oDlg,oLbx )
   EndIf
ElseIf oApl:oFac:INDICADOR # "A"
   If oApl:lEnLinea .AND. oApl:oFac:FECHOY < oApl:dFec
      MsgStop( "Esta Factura se Anula con un Diario","<<< OJO >>>" )
   ElseIf Login( "Desea Anular esta Factura" )
      dFecdev   := ::FechaDev( "Fecha Anulación" )
      oApl:cPer := NtChr( dFecdev,"1" )
      oApl:lFam := SaldoFac( ::aM[2] )
      nTipo     := If( oApl:cPer > cPerF, 7, 2 )
      oApl:oFac:INDICADOR := "A" ; oApl:oFac:FECHAVEN := dFecdev
      oApl:oFac:Update(.f.,1)
      GrabaSal( ::aM[2],1,oApl:nSaldo )
      cPerF := If( oApl:lEnLinea, "DELETE FROM cadpagos"    ,;
                    "UPDATE cadpagos SET indicador = 'A'" ) +;
             " WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND numfac = "  + LTRIM(STR(::aM[2]))      +;
               " AND tipo  = '" + oApl:Tipo + "'"
      MSQuery( oApl:oMySql:hConnect,cPerF )
      FOR nR := 1 TO LEN( ::aV )
         If ::aV[nR,10] > 0 .AND. LEFT( ::aV[nR,09],1 ) == " "
            ::oVen:Seek( {"row_id",::aV[nR,10]} )
            mCant := ::aV[nR,04] * If( nTipo = 2, -1, 1 )
            Actualiz( ::aV[nR,01],mCant,dFecdev,nTipo )
            If oApl:lEnLinea .AND. nTipo == 2
               ::oVen:Delete(.f.,1)
            Else
               ::oVen:INDICADOR := If( nTipo == 2, "A", "D" )
               ::oVen:FECDEV    := dFecdev ; ::oVen:Update(.f.,1)
            EndIf
         EndIf
      NEXT
      ::Iniciar( oDlg,oLbx )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD FechaDev( cMsg ) CLASS TFactura
   LOCAL dFec := oApl:dFec
WHILE !oApl:lEnLinea
   dFec := MsgDate( dFec,cMsg )
   If dFec >= oApl:oFac:FECHOY
      If MsgYesNo( DTOC(dFec)+" Es Correcta Fecha",cMsg )
         EXIT
      EndIf
   EndIf
EndDo
RETURN dFec

//------------------------------------//
METHOD Fechas( lOK,nMsg,oDlg,oLbx ) CLASS TFactura
   LOCAL aFec, nR, lSI := .t.
If lOK
   aFec := { oApl:oFac:XColumn( 5 ),oApl:oFac:FECHOY,oApl:cPer,::lCierre,.t.,;
             "empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
        " AND ano_mes = " + xValToChar(oApl:cPer )    +;
        " AND control = " + LTRIM(STR(oApl:oFac:CONTROL)) }
   If (aFec[5] := ::Fechas( .f.,1,oDlg,oLbx ))
      If MsgYesNo( "Es Temporal","EL CAMBIO DE FECHA" )
         nR := oApl:oFac:FECHAVEN
         MsgGet( "FECHA DE","Vencimiento",@nR )
         oApl:oFac:FECHAVEN := nR
         ::Listado( oDlg,oLbx )
         RETURN NIL
      EndIf
      nMsg := "UPDATE cadpagos SET fecpag = " + xValToChar(aFec[2]) +;
             " WHERE empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
               " AND numfac  = " + LTRIM(STR(::aM[2]))       +;
               " AND tipo    = " + xValToChar( oApl:Tipo )   +;
               " AND fecpag  = " + xValToChar( aFec[1] )
      If (aFec[3] == LEFT( DTOS(aFec[2]),6 ))
         If oApl:oFac:FECHOY >= CTOD("01.01.2006")
            Guardar( "UPDATE cgemovc SET fecha = " + xValToChar(aFec[2]) +;
                     " WHERE " + aFec[6],"cgemovc" )
         EndIf
         Guardar( oApl:oFac,.f.,.f. )
         Guardar( nMsg,"cadpagos" )
         nMsg :=  STRTRAN( nMsg,"pagos","venta" )
         Guardar( STRTRAN( nMsg,"fecpag","fecfac" ),"cadventa" )
      ElseIf MsgYesNo( "QUIERE HACER EL CAMBIO","VA A CAMBIAR DE MES" )
         Guardar( nMsg,"cadpagos" )
         FOR nR := 1 TO LEN( ::aV )
            If ::aV[nR,10] > 0
               ::oVen:Seek( {"row_id",::aV[nR,10]} )
               ::oVen:FECFAC := aFec[2] ; ::oVen:Update(.f.,1)
               oApl:oInv:Seek( {"codigo",::aV[nR,1]} )
               Actualiz( ::aV[nR,1],-::aV[nR,4],aFec[2],2 ) //Reversa Inventarios
               Actualiz( ::aV[nR,1], ::aV[nR,4],aFec[2],2 )
            EndIf
         NEXT nR

         If oApl:oFac:CONTROL  > 0 .AND. oApl:oFac:FECHOY >= CTOD("01.01.2006")
            oApl:oFac:CONTROL := SgteCntrl( "control",oApl:cPer,.t. )
            ::oMvc:Seek( aFec[6],"CM" )
            ::oMvc:ANO_MES := oApl:cPer
            ::oMvc:FECHA   := aFec[2]
            ::oMvc:CONTROL := oApl:oFac:CONTROL
            Guardar( ::oMvc,.f.,.f. )
            ::oMvd:dbEval( {|o| Acumular( ::oMvc:ESTADO,o,5,5,.f.,.f. )            ,;
                                o:ANO_MES := oApl:cPer, o:CONTROL := ::oMvc:CONTROL,;
                                Acumular( ::oMvc:ESTADO,o,2,2,.f.,.f. ) }, aFec[6] )
         EndIf
         Guardar( oApl:oFac,.f.,.f. )
         If oApl:oFam:Seek( { "empresa",oApl:nEmpresa,"numfac",::aM[2],;
                              "tipo",oApl:Tipo,"anomes",aFec[3] } )
            oApl:oFam:ANOMES := oApl:cPer
            Guardar( oApl:oFam,.f.,.f. )
         EndIf
      Else
         aFec[5] := .f.
      EndIf
   EndIf
   If (lSI := aFec[5])
      MsgInfo( "El cambio de Fecha","HECHO" )
   Else
      lSI := If( EMPTY( aFec[2] ) .OR. ::lCierre, .t., .f. )
      oApl:oFac:FECHOY := aFec[1]
      oApl:cPer := aFec[3]
      ::lCierre := aFec[4]
   EndIf
ElseIf EMPTY( oApl:oFac:FECHOY )
   MsgStop( "No puede ir en Blanco","FECHA" )
   lSI := .f.
Else
   oApl:cPer := NtChr( oApl:oFac:FECHOY,"1" )
   ::lCierre := Buscar( {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer},;
                        "cgecntrl","cierre",8,,3 )
   If ::lCierre .AND. nMsg # NIL
      MsgStop( "Ya esta CERRADO","Periodo "+oApl:cPer )
      lSI := .f.
   EndIf
EndIf
RETURN lSI

//------------------------------------//
METHOD Guardar( oDlg,oLbx ) CLASS TFactura
   LOCAL lCambio, nAbono, nPago, nR, cFactu := "Numfac"+oApl:Tipo
If EMPTY( ::aV[1,1] ) .AND. oApl:oFac:INDICADOR # "A"
   MsgInfo( "Factura no Tiene ningun Items" )
   RETURN NIL
EndIf
nPago := nR := 0
oApl:cPer := NtChr( oApl:oFac:FECHOY,"1" )
If !oApl:oFac:lOK
   nR := SgteNumero( cFactu,oApl:nEmpresa,.f. )
   If !MsgYesNo("Factura #"+STR(nR),"Graba esta")
      RETURN NIL
   EndIf
   While .t.
      nR := SgteNumero( cFactu,oApl:nEmpresa,.t. )
      If !BuscaDup( nR )
         EXIT
      EndIf
   EndDo
   If !oApl:lEnLinea
      oApl:dFec := oApl:oFac:FECHOY
   ElseIf oApl:oFac:FECHOY < oApl:oEmp:FEC_HOY
      oApl:oFac:FECHOY   := oApl:oEmp:FEC_HOY
      oApl:oFac:FECHAVEN := oApl:oEmp:FEC_HOY + 7
      oApl:cPer:= NtChr( oApl:oFac:FECHOY,"1" )
   EndIf
   oApl:oFac:EMPRESA := oApl:nEmpresa
   oApl:oFac:TIPO    := oApl:Tipo
   oApl:oFac:NUMFAC  := nR
   oApl:oFac:Append( .t. )
   oApl:nSaldo := oApl:oFac:TOTALFAC
   ::nSigFac   := oApl:oFac:NUMFAC + 1
   cFactu  := "SI"
   lCambio := .t. ; oApl:lFam := .f.
   nR      := 1
Else
   If (lCambio := oApl:oFac:TOTALFAC # ::aM[6])
      If !MsgNoYes( TransForm( oApl:oFac:TOTALFAC,"NUEVO 999,999,999" ) +;
         TransForm( ::aM[6]," - VIEJO 999,999,999" ),"EL TOTAL ES DIFERENTE" )
         RETURN NIL
      EndIf
   EndIf
   If (oApl:lFam := SaldoFac( ::aM[2] ))
      nPago := oApl:oFac:TOTALFAC - ::aM[6]
      oApl:nSaldo += nPago
   Else
      nPago := oApl:oFac:TOTALFAC
   EndIf
EndIf
If lCambio .AND. oApl:Tipo # "Z"
   nAbono := oApl:nSaldo - nPago
   oApl:oFac:INDICADOR:= If( nAbono == 0, oApl:oFac:INDICADOR, "P" )
   oApl:oFac:FECHACAN := If( nAbono == 0, oApl:oFac:FECHOY, CTOD("") )
   oApl:oFac:FECHAVEN := If( oApl:oFac:INDICADOR == "A", oApl:dFec, oApl:oFac:FECHAVEN )
   GrabaSal( oApl:oFac:NUMFAC,nR,nPago )
EndIf
oApl:oFac:Update( .f.,1 )
FOR nR := 1 TO LEN( ::aV )
   If !EMPTY( ::aV[nR,01] ) .AND. LEFT( ::aV[nR,09],1 ) == " "
      nAbono := 0
      ::aV[nR,2] := UPPER(::aV[nR,2])
      ::aV[nR,5] := If( ::aV[nR,5] # 0, ::aV[nR,5],  ;
                 ROUND( (::aV[nR,6] / (::aV[nR,6]+::aV[nR,7]))*100,2 ) )
      If ::aV[nR,10] == 0
         ::oVen:xBlank()
         ::oVen:EMPRESA  := oApl:nEmpresa
         ::oVen:NUMFAC   := oApl:oFac:NUMFAC
         ::oVen:TIPO     := oApl:Tipo  ; ::oVen:FECFAC   := oApl:oFac:FECHOY
         ::oVen:CODIGO   := ::aV[nR,1] ; ::oVen:CANTIDAD := ::aV[nR,4]
         ::oVen:PRECIOVEN:= ::aV[nR,7] ; ::oVen:DESPOR   := ::aV[nR,5]
         ::oVen:DESMON   := ::aV[nR,6] ; ::oVen:MONTOIVA := ::aV[nR,8]
         ::oVen:Append( .f. )
      Else
         ::oVen:Seek( {"row_id",::aV[nR,10]} )
         nAbono    := ::oVen:CANTIDAD * -1
         If ::oVen:CODIGO # ::aV[nR,01]
            oApl:oInv:Seek( {"codigo",::oVen:CODIGO} )
            Actualiz( ::oVen:CODIGO,nAbono,oApl:oFac:FECHOY,2 )
            nAbono := 0
         EndIf
         ::oVen:CODIGO   := ::aV[nR,1] ; ::oVen:CANTIDAD := ::aV[nR,4]
         ::oVen:PRECIOVEN:= ::aV[nR,7] ; ::oVen:DESPOR   := ::aV[nR,5]
         ::oVen:DESMON   := ::aV[nR,6] ; ::oVen:MONTOIVA := ::aV[nR,8]
         ::oVen:Update( .f.,1 )
      EndIf
      nAbono += ::aV[nR,4]
      oApl:oInv:Seek( {"codigo",::oVen:CODIGO} )
      Actualiz( ::oVen:CODIGO,nAbono,oApl:oFac:FECHOY,2 )
//    If oApl:aInvme[2] # 0 .AND. oApl:aInvme[2] # ::oVen:PCOSTO
//       ::oVen:PCOSTO := oApl:aInvme[2] ; ::oVen:Update( .f.,1 )
//    EndIf
   EndIf
NEXT nR
If oApl:lEnLinea .AND. cFactu == "SI"
   CaoLiFac( oApl:oFac:NUMFAC,::aV )
EndIf
oLbx:nCell := oLbx:nColPos := 1
oLbx:HiliteCell( 1 )
If oApl:oFac:FECHOY >= CTOD("01.01.2006")
   ContaVta( ::oMvc,::oMvd )
EndIf
::Iniciar( oDlg,oLbx )
RETURN NIL

//------------------------------------//
METHOD Listado( oDlg,oLbx ) CLASS TFactura
If oApl:oFac:lOK //.AND. oApl:lEnLinea
   CaoLiFac( oApl:oFac:NUMFAC,::aV )
   ::Iniciar( oDlg,oLbx )
EndIf
RETURN NIL

//------------------------------------//
METHOD Abonos() CLASS TFactura
   LOCAL oDlg, oLbp, oLbf, oGet := ARRAY(5), aEst, aFac, nEst
If ::aM[2] == 0 .OR. !oApl:oFac:lOK
   RETURN NIL
EndIf
aEst := { "","ANULADA","PENDIENTE","CANCELADA","999,999,999.99",;
          oApl:oFac:FECHACOB,oApl:oFac:HORA,oApl:oFac:FECHACAN }
aFac := ArrayCol( ::aPag,1 )
nEst := AT( oApl:oFac:INDICADOR,"APC" )
AEVAL( { "","","N.Credito","N.Debito","Anulada" }, {|cVal| AADD( aFac,cVal ) } )
oApl:oFah:Seek( {"numfac",::aM[2],"tipo",oApl:Tipo} )
oApl:oFam:Seek( {"empresa",oApl:nEmpresa,"numfac",::aM[2],"tipo",oApl:Tipo,;
                 "anomes >= ",NtChr( oApl:oFac:FECHOY,"1" )},"anomes",.f. )
oApl:cPer   := NtChr( DATE(),"1" )
oApl:nSaldo := oApl:oFam:SALDO
oApl:oPag:Seek( {"empresa",oApl:nEmpresa,"numfac",::aM[2],"tipo",oApl:Tipo},;
                 "fecpag" )
DEFINE DIALOG oDlg RESOURCE "PAGOSFAC"
   REDEFINE SAY VAR oApl:oFac:NUMFAC    ID  1 OF oDlg
   REDEFINE SAY VAR oApl:oFac:FECHOY    ID  3 OF oDlg
   REDEFINE SAY VAR oApl:oFac:CLIENTE   ID  5 OF oDlg
   REDEFINE SAY VAR oApl:oFac:FECHAVEN  ID  7 OF oDlg
   REDEFINE SAY VAR oApl:oFac:ENVIADO_A ID  9 OF oDlg
   REDEFINE GET oGet[1] VAR oApl:oFac:FECHACOB ID 11 OF oDlg ;
      VALID EVAL({|| If( oApl:oFac:FECHACOB # aEst[6],;
                       ( oApl:oFac:Update(.f.,1) ), ),;
                     oGet[1]:oJump := oLbp, .t. } )
   REDEFINE GET oGet[2] VAR oApl:oFac:HORA     ID 13 OF oDlg PICTURE "99:99 A";
      VALID EVAL({|| If( oApl:oFac:HORA # aEst[7]    ,;
                       ( oApl:oFac:Update(.f.,1) ), ),;
                     oGet[2]:oJump := oLbp, .t. } )
    oGet[2]:bGotFocus := {|| If( EMPTY(aEst[7]),;
                             oGet[2]:SetText( STUFF( AmPm(TIME()),6,3,"" ) ), )}
   REDEFINE SAY VAR aEst[nEst+1]        ID 15 OF oDlg UPDATE COLOR nRGB( 255,0,0 )
   REDEFINE GET oGet[3] VAR oApl:oFac:FECHACAN ID 16 OF oDlg        ;
      WHEN Rango( nEst,2,3 )                                        ;
      VALID EVAL({|| If( oApl:oFac:FECHACAN # aEst[8]              ,;
                       ( oApl:oFac:INDICADOR :=                     ;
                        If( EMPTY( oApl:oFac:FECHACAN ), "P", "C" ),;
                        nEst := AT( oApl:oFac:INDICADOR, "APC" )   ,;
                        oApl:oFac:Update(.f.,1), oDlg:Update() ), ),;
                     oGet[3]:oJump := oLbp, .t. } )
   REDEFINE SAY VAR oApl:oFac:TOTALFAC ID 18 OF oDlg PICTURE aEst[5]
   REDEFINE SAY VAR oApl:nSaldo        ID 20 OF oDlg PICTURE aEst[5] UPDATE

   REDEFINE LISTBOX oLbp FIELDS       ;
         DTOC( oApl:oPag:FECPAG )    ,;
          aFac[oApl:oPag:FORMAPAGO+1],;
               oApl:oPag:CODBANCO    ,;
    TRANSFORM( oApl:oPag:PAGADO   ,aEst[5]),;
    TRANSFORM( oApl:oPag:ABONO    ,aEst[5]),;
    TRANSFORM( oApl:oPag:DEDUCCION,aEst[5]),;
    TRANSFORM( oApl:oPag:RETENCION,aEst[5]),;
    TRANSFORM( oApl:oPag:DESCUENTO,aEst[5]),;
               oApl:oPag:NUMCHEQUE    ;
      HEADERS "Fecha", "FormaPago", "Banco", "Total Pago", "Monto Pago",;
              "DEDUCCION", "RETENCION", "DESCUENTO", "DOCUMENTO" ;
      ID 22 OF oDlg UPDATE
    oLbp:nClrBackHead  := oApl:nClrBackHead
    oLbp:nClrForeHead  := oApl:nClrForeHead
    oLbp:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbp:nClrBackFocus := oApl:nClrBackFocus
    oLbp:nClrForeFocus := oApl:nClrForeFocus
    oLbp:nHeaderHeight := 28
    oLbp:GoTop()
    oLbp:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbp:aColSizes  := {60,64,40,82,82,82,82,82,94}
    oLbp:aHjustify  := {2,2,2,2,2,2,2,2,2}
    oLbp:aJustify   := {1,0,2,1,1,1,1,1,0}
    oLbp:cToolTip := "[Ctrl] + [Supr] Borrar Pago"
//    oLbp:bKeyDown := {|nKey| If(nKey=VK_RETURN .AND. oApl:oPag:FECPAG == oApl:dFec .AND. oApl:oPag:FORMAPAGO < 5,;
    oLbp:bKeyDown := {|nKey| If(nKey=VK_RETURN .AND. oApl:oPag:FORMAPAGO < 5 .AND.  ;
                                     (::aPrv[2] .OR. oApl:oPag:FECPAG == oApl:dFec),;
                                     (CaoPagos(.t.,.f.,::aPag), oLbf:Refresh()),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, ::Borrar(oLbp,oLbf), ) ) }
    oLbp:lCellStyle := oLbp:ladjbrowse := .f.
    oLbp:ladjlastcol:= .t.
   MySetBrowse( oLbp, oApl:oPag )

   REDEFINE LISTBOX oLbf FIELDS  ;
               oApl:oFam:ANOMES ,;
    TRANSFORM( oApl:oFam:SALDO  ,aEst[5]),;
    TRANSFORM( oApl:oFam:ABONOS ,aEst[5]),;
    TRANSFORM( oApl:oFam:DEBITO ,aEst[5]) ;
      HEADERS "AñoMes", "Saldo", "Abonos", "Debitos" ;
      ID 24 OF oDlg UPDATE
    oLbf:nClrBackHead  := oApl:nClrBackHead
    oLbf:nClrForeHead  := oApl:nClrForeHead
    oLbf:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbf:nClrBackFocus := oApl:nClrBackFocus
    oLbf:nClrForeFocus := oApl:nClrForeFocus
    oLbf:nHeaderHeight := 28
    oLbf:GoTop()
    oLbf:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbf:aColSizes  := {70,100,100,100}
    oLbf:aHjustify  := {2,2,2,2}
    oLbf:aJustify   := {0,1,1,1}  // O Derecha, 1 Izquierda, 2 Centro
    oLbf:lCellStyle := .f.
    oLbf:bKeyDown := {|nKey| If(nKey == VK_RETURN, ::Editar(.f.,oLbf),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, ::Editar(.t.,oLbf),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, DelRecord(oApl:oFam,oLbf), ))) }
   MySetBrowse( oLbf, oApl:oFam )

   REDEFINE BUTTON oGet[4] ID 27 OF oDlg ACTION ;
      Notas( oApl:oFah:NOTA,"ANOTACIONES" )
   REDEFINE BUTTON oGet[5] ID 28 OF oDlg ACTION oDlg:End()
ACTIVATE DIALOG oDlg CENTER

RETURN NIL

//------------------------------------//
METHOD Borrar( oLbp,oLbf ) CLASS TFactura
If ::aPrv[3] .AND. oApl:oPag:FORMAPAGO <= 4
   If Login( "Desea Anular este Pago" )
      If oApl:oPag:PAGADO # 0 .AND. oApl:oFac:INDICADOR # "A"
         oApl:oFac:INDICADOR := "P" ; oApl:oFac:FECHACAN := CTOD("")
         oApl:oFac:Update(.f.,1)
         oApl:cPer := NtChr( oApl:oPag:FECPAG,"1" )
         oApl:lFam := SaldoFac( oApl:oPag:NUMFAC )
         GrabaSal( oApl:oPag:NUMFAC,1,-oApl:oPag:PAGADO )
         oApl:cPer := NtChr( oApl:dFec,"1" )
      EndIf
      oApl:oPag:Delete(.f.,1)
      oLbp:Refresh() ; oLbf:Refresh()
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Editar( lNuevo,oLbx ) CLASS TFactura
   LOCAL oDlg, oGet := ARRAY(6)
   LOCAL aED := { .f.,"Modificando Saldo","999,999,999.99" }
If !::aPrv[1]
   RETURN NIL
EndIf
If lNuevo
   If MsgYesNo("Adicionar un Registro","Quiere")
      aED[2] := "Nuevo Saldo"
      oApl:oFam:xBlank()
      oApl:oFam:EMPRESA := oApl:nEmpresa ; oApl:oFam:NUMFAC := oApl:oFac:NUMFAC
      oApl:oFam:TIPO    := oApl:Tipo     ; oApl:oFam:ANOMES := oApl:cPer
   EndIf
Else
   oApl:oFam:xLoad()
EndIf
DEFINE DIALOG oDlg TITLE aED[2] FROM 00,02 TO 10,40
   @ 02,00 SAY "Año y Mes"     OF oDlg RIGHT PIXEL SIZE 46,10
   @ 02,50 GET oGet[01] VAR oApl:oFam:ANOMES OF oDlg PICTURE "999999";
      SIZE 30,10 PIXEL
   @ 14,00 SAY "Saldo Factura" OF oDlg RIGHT PIXEL SIZE 46,10
   @ 14,50 GET oGet[02] VAR oApl:oFam:SALDO  OF oDlg PICTURE aED[3];
      SIZE 40,10 PIXEL
   @ 28,00 SAY "Total Abonos"  OF oDlg RIGHT PIXEL SIZE 46,10
   @ 28,50 GET oGet[03] VAR oApl:oFam:ABONOS OF oDlg PICTURE aED[3];
      SIZE 40,10 PIXEL
   @ 40,00 SAY "Total Debitos" OF oDlg RIGHT PIXEL SIZE 46,10
   @ 40,50 GET oGet[04] VAR oApl:oFam:DEBITO OF oDlg PICTURE aED[3];
      SIZE 40,10 PIXEL
   @ 58,30 BUTTON oGet[05] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION ;
      (If( EMPTY(oApl:oFam:ANOMES) .OR. oApl:oFam:ABONOS < 0           ,;
         ( MsgStop("Imposible grabar este Saldo"), oGet[1]:SetFocus() ),;
         ( aEd[1] := .t., oDlg:End() ))) PIXEL
   @ 58,80 BUTTON oGet[06] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL ;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTER
If aEd[1]
   If lNuevo
      oApl:oFam:Append(.t.)
   Else
      oApl:oFam:Update(.t.,1)
   EndIf
   oLbx:Refresh()
EndIf

RETURN NIL

//------------------------------------//
METHOD Mostrar( lAyuda,nOrd ) CLASS TFactura
   LOCAL oDlg, oM := Self, lReturn := .f.
   LOCAL bHacer := {|| lReturn := .t., oDlg:End() }
   DEFAULT lAyuda := .t. , nOrd := 3
nOrd := ::Ordenar( nOrd )

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE "Ayuda de Facturas"
   @ 1.5, 0 LISTBOX ::oLbx FIELDS  ;
               STR( ::oDb:NUMFAC ),;
              DTOC( ::oDb:FECHOY ),;
                    ::oDb:CLIENTE ,;
        ArrayValor( oApl:aOptic,STR(::oDb:Empresa,2) );
      HEADERS "Número"+CRLF+"Factura","Fecha","Cliente", "Empresa" ;
      SIZES 400, 450 SIZE 200,107  ;
      ON DBLCLICK EVAL(bHacer)
    ::oLbx:nClrBackHead  := oApl:nClrBackHead
    ::oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    ::oLbx:nClrBackFocus := oApl:nClrBackFocus
    ::oLbx:nClrForeFocus := oApl:nClrForeFocus
    ::oLbx:nHeaderHeight := 28
    ::oLbx:GoTop()
    ::oLbx:oFont      := ::oFont
    ::oLbx:aColSizes  := {70,70,200,60}
    ::oLbx:aHjustify  := {2,2,2,2}
    ::oLbx:aJustify   := {1,0,0,2}
    ::oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey=VK_RETURN, (EVAL(bHacer)),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) ) }
    ::oLbx:lCellStyle  := ::oLbx:ladjbrowse  := .f.
    ::oLbx:ladjlastcol := .t.
   MySetBrowse( ::oLbx, ::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT ( oM:Barra(lAyuda,oDlg) )
::oDb:Setorder(nOrd)

RETURN lReturn

//------------------------------------//
FUNCTION CaoPagos( lPago,lNuevo,aPag,lCaja )
   LOCAL oDlp, oGet := ARRAY(17), aP := { oApl:dFec,"","","99,999,999.99",.f.,0,0,0 }
   LOCAL bGrabar, bSumar, bValid, nFPag, nFactu, nPago := 0
   LOCAL bReten := &(Trim( oApl:oEmp:RETENCION ))
DEFAULT lPago := .f., lNuevo := .t. ,;
        aPag  := ArrayCombo( "FPAGO" ), lCaja := .f.
If lPago
   bGrabar := {|| GrabaPago( lNuevo,,aP[8] )      ,;
                  aP[2] := oApl:oPag:NUMCHEQUE    ,;
                  aP[3] := oApl:oPag:CODBANCO     ,;
                  If( lNuevo, ( oApl:oPag:xBlanK(),;
                  oApl:oPag:FECPAG    := aP[1]    ,;
                  oApl:oPag:NUMCHEQUE := aP[2]    ,;
                  oApl:oPag:CODBANCO  := aP[3]    ,;
                  oDlp:Update(), oGet[11]:oJump := ;
                  oGet[2], oGet[2]:SetFocus() )   ,;
                 (aP[5] := .t., oDlp:End()) ) }
   oApl:nSaldo := 0
   oApl:Tipo   := "U"
Else
   bGrabar := {|| aP[5] := .t., oDlp:End() }
EndIf
If lNuevo
   oApl:oPag:xBlank()
   oApl:oPag:FECPAG := aP[1]
   oApl:oPag:ABONO  := If( lCaja, oApl:nSaldo, 0 )
   oApl:cPer := NtChr( aP[1],"1" )
ElseIf !lCaja
   aP[8]     := oApl:oPag:PAGADO
   oApl:cPer := NtChr( oApl:oPag:FECPAG,"1" )
   oApl:lFam := SaldoFac( oApl:oPag:NUMFAC )
   oApl:nSaldo += oApl:oPag:PAGADO
EndIf
oApl:oBco:Seek( {"codigo",oApl:oPag:CODBANCO} )
bValid := {|| If( !oApl:oFac:Seek( { "empresa",oApl:nEmpresa,"numfac"   ,;
                                     nFactu,"tipo",oApl:Tipo} )         ,;
                ( MsgStop("Factura NO EXISTE"), .f.),;
                (If( (nPago := AT( oApl:oFac:INDICADOR,"AC" )) > 0      ,;
                (MsgStop({"ANULADA","CANCELADA"}[nPago],"Factura"), .f.),;
                (oApl:lFam := SaldoFac( nFactu ), nPago := 0            ,;
                 oApl:oPag:ABONO := oApl:nSaldo, oDlp:Update(), .t.) ))) }
bSumar := {|nVal| If( nVal < 0, (MsgStop( "El Valor debe ser Mayor de 0",;
                     "<< OJO >>" ), .f.), ;
           (If( nFPag > 2 .AND. nPago == 0, ( nPago := oApl:oPag:ABONO  ,;
               aP[6] := If( nFPag == 3, oApl:oBco:DEBITO, oApl:oBco:CREDITO ),;
               aP[7] := If( oApl:oPag:CODBANCO == "CB", 0, 2 )               ,;
               oApl:oPag:DEDUCCION := ROUND( nPago * aP[6] / 100 ,aP[7] )    ,;
               oApl:oPag:RETENCION := ROUND( EVAL( bReten,nPago ),aP[7] )    ,;
               oApl:oPag:ABONO -= (oApl:oPag:DEDUCCION + oApl:oPag:RETENCION) ),),;
            nPago := oApl:oPag:ABONO     + oApl:oPag:DEDUCCION +;
                     oApl:oPag:RETENCION + oApl:oPag:DESCUENTO +;
                     oApl:oPag:RETICA    + oApl:oPag:RETIVA    +;
                     oApl:oPag:RETFTE    + oApl:oPag:RETCRE    ,;
            oDlp:Update(), .t.) ) }
nFactu := oApl:oPag:NUMFAC
nFPag  := ArrayValor( aPag,STR(oApl:oPag:FORMAPAGO,1),,.t. )
SETKEY( VK_ADD,{|| oGet[14]:Click() } )
/*
DEFINE DIALOG oDlp RESOURCE "DLGPAGOS"
   REDEFINE GET oGet[01] VAR oApl:oPag:FECPAG ID  1 OF oDlp;
      VALID (aP[1] := oApl:oPag:FECPAG, oApl:cPer := NtChr( aP[1],"1" ), .t.) ;
      WHEN lPago .AND. lNuevo
   REDEFINE GET oGet[02] VAR nFactu           ID  3 OF oDlp;
      VALID EVAL(bValid) ;
      WHEN lPago .AND. lNuevo
   REDEFINE SAY VAR oApl:oFac:CLIENTE         ID  4 OF oDlp UPDATE
   REDEFINE SAY VAR oApl:nSaldo               ID  6 OF oDlp PICTURE aP[4] UPDATE
   REDEFINE GET oGet[03] VAR oApl:oPag:FORMAPAGO ID  8 OF oDlp PICTURE "9";
      VALID {|| If( Rango( oApl:oPag:FORMAPAGO,0,3 ),;
                  (nFPag := oApl:oPag:FORMAPAGO +1, oDlp:Update(), .t.), .f. ) }
    oGet[03]:cToolTip := "0_Efectivo, 1_Cheque, 2_T.Debito, 3_T.Credito"
   REDEFINE SAY VAR aPag[nFPag,1]             ID 31 OF oDlp UPDATE
//   REDEFINE COMBOBOX oGet[03] VAR nFPag ITEMS ArrayCol( aPag,1 ) ID 8 OF oDlp ;
//      VALID ( oDlp:GoNextCtrl( oGet[03]:hWnd ), .t. )
   REDEFINE GET oGet[04] VAR oApl:oPag:CODBANCO  ID 10 OF oDlp PICTURE "!!";
      VALID EVAL( {|| If( oApl:oBco:Seek( {"codigo",oApl:oPag:CODBANCO} ) ,;
            ( oApl:oPag:INDRED := Rango( nFPag,3,4 ), oDlp:Update(), .t. ),;
            ( MsgStop("Este Banco no Existe .."),.f.) ) } );
      WHEN nFPag >= 2
   REDEFINE SAY VAR oApl:oBco:NOMBRE             ID 11 OF oDlp UPDATE
   REDEFINE GET oGet[05] VAR oApl:oPag:NUMCHEQUE ID 13 OF oDlp PICTURE "@!";
      WHEN Rango( nFPag,2,4 )
   REDEFINE CHECKBOX oGet[06] VAR oApl:oPag:INDRED ID 14 OF oDlp;
      WHEN nFPag == 4 UPDATE
   REDEFINE GET oGet[07] VAR oApl:oPag:ABONO     ID 16 OF oDlp PICTURE aP[4];
      VALID EVAL( bSumar,oApl:oPag:ABONO )     UPDATE
   REDEFINE GET oGet[08] VAR oApl:oPag:DEDUCCION ID 18 OF oDlp PICTURE aP[4];
      VALID EVAL( bSumar,oApl:oPag:DEDUCCION ) UPDATE
   REDEFINE GET oGet[09] VAR oApl:oPag:RETENCION ID 20 OF oDlp PICTURE aP[4];
      VALID EVAL( bSumar,oApl:oPag:RETENCION ) UPDATE
   REDEFINE GET oGet[10] VAR oApl:oPag:DESCUENTO ID 22 OF oDlp PICTURE aP[4];
      VALID EVAL( bSumar,oApl:oPag:DESCUENTO ) UPDATE
   REDEFINE GET oGet[11] VAR oApl:oPag:RETICA    ID 24 OF oDlp PICTURE aP[4];
      VALID EVAL( bSumar,oApl:oPag:RETICA )    UPDATE
   REDEFINE GET oGet[12] VAR oApl:oPag:RETIVA    ID 26 OF oDlp PICTURE aP[4];
      VALID EVAL( bSumar,oApl:oPag:RETIVA )    UPDATE
   REDEFINE GET oGet[13] VAR oApl:oPag:RETFTE    ID 28 OF oDlp PICTURE aP[4];
      VALID EVAL( bSumar,oApl:oPag:RETFTE )    UPDATE
   REDEFINE SAY          VAR nPago       ID 30 OF oDlp PICTURE aP[4] UPDATE
   REDEFINE BUTTON oGet[14] ID 32 OF oDlp ACTION   ;
      (oApl:oPag:FORMAPAGO := VAL(aPag[nFPag,2])  ,;
       If( TotalPagado( nPago,lCaja ), (EVAL( bGrabar )),;
         (oGet[14]:oJump := oGet[3], oGet[3]:SetFocus()) ))
   REDEFINE BUTTON oGet[15] ID 33 OF oDlp CANCEL;
      ACTION (aP[5] := .f., oDlp:End())
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlp CENTER ON INIT;
   (aP[2] := oDlp:cTitle() + " de ",;
    oDlp:SetText( aP[2] + ArrayValor( oApl:aOptic,STR(oApl:nEmpresa,2) ) ))
*/
DEFINE DIALOG oDlp TITLE "Pagos a Facturas de " + ArrayValor( oApl:aOptic,STR(oApl:nEmpresa,2) );
   FROM 0, 0 TO 420, 330 PIXEL
   @  02, 00 SAY "Fecha"         OF oDlp RIGHT PIXEL SIZE 50,10
   @  02, 52 GET oGet[01] VAR oApl:oPag:FECPAG OF oDlp ;
      VALID (aP[1] := oApl:oPag:FECPAG, oApl:cPer := NtChr( aP[1],"1" ), .t.);
      WHEN lPago .AND. lNuevo  SIZE 40,10 PIXEL
   @  14, 00 SAY "Nro.Factura"   OF oDlp RIGHT PIXEL SIZE 50,10
   @  14, 52 GET oGet[02] VAR nFactu OF oDlp;
      VALID EVAL( bValid )                  ;
      WHEN lPago .AND. lNuevo          SIZE 40,10 PIXEL
   @  27, 06 SAY oApl:oFac:CLIENTE OF oDlp PIXEL SIZE 130,10;
      UPDATE COLOR nRGB( 128,0,255 )
   @  38, 00 SAY "Saldo Factura" OF oDlp RIGHT PIXEL SIZE 50,10
   @  38, 52 SAY oApl:nSaldo OF oDlp PICTURE aP[4] SIZE 40,10 PIXEL UPDATE
   @  50, 00 SAY "Forma Pago"    OF oDlp RIGHT PIXEL SIZE 50,10
   @  50, 52 GET oGet[03] VAR oApl:oPag:FORMAPAGO OF oDlp PICTURE "9";
      VALID {|| If( Rango( oApl:oPag:FORMAPAGO,0,3 ),;
                  (nFPag := oApl:oPag:FORMAPAGO +1, oDlp:Update(), .t.), .f. ) };
      SIZE 10,10 PIXEL
    oGet[03]:cToolTip := "0_Efectivo, 1_Cheque, 2_T.Debito, 3_T.Credito"
   @  50, 66 SAY aPag[nFPag,1] OF oDlp PIXEL SIZE 50,10 UPDATE
// @  50, 52 COMBOBOX oGet[03] VAR nFPag ITEMS ArrayCol( aPag,1 ) ;
//    SIZE 52,99 OF oDlp PIXEL ;
//    VALID (aP[7] := Rango( nFPag,2,4 ), .t.)
   @  62, 00 SAY "Código Banco"  OF oDlp RIGHT PIXEL SIZE 50,10
   @  62, 52 GET oGet[04] VAR oApl:oPag:CODBANCO OF oDlp PICTURE "!!"      ;
      VALID EVAL( {|| If( oApl:oBco:Seek( {"codigo",oApl:oPag:CODBANCO} ) ,;
            ( oApl:oPag:INDRED := Rango( nFPag,3,4 ), oDlp:Update(), .t. ),;
            ( MsgStop("Este Banco no Existe .."),.f.) ) } );
      WHEN nFPag >= 2 SIZE 16,10 PIXEL UPDATE
   @  62, 70 SAY oApl:oBco:NOMBRE OF oDlp PIXEL SIZE 100,10 UPDATE
   @  74, 00 SAY "Nro.Documento" OF oDlp RIGHT PIXEL SIZE 50,10
   @  74, 52 GET oGet[05] VAR oApl:oPag:NUMCHEQUE OF oDlp PICTURE "@!";
      WHEN Rango( nFPag,2,4 ) SIZE 58,10 PIXEL UPDATE
//  oGet[10]:cToolTip := "Para Bonos NC ##, SODEXO, BIG PASS"
   @  74,114 CHECKBOX oGet[06] VAR oApl:oPag:INDRED PROMPT "Por Datafono" OF oDlp;
      WHEN nFPag == 4 SIZE 50,12 PIXEL UPDATE
   @  86, 00 SAY "Monto Pago"    OF oDlp RIGHT PIXEL SIZE 50,10
   @  86, 52 GET oGet[07] VAR oApl:oPag:ABONO     OF oDlp PICTURE aP[4];
      VALID EVAL( bSumar,oApl:oPag:ABONO )     ;
      SIZE 40,10 PIXEL UPDATE
   @  98, 00 SAY "Deducción"     OF oDlp RIGHT PIXEL SIZE 50,10
   @  98, 52 GET oGet[08] VAR oApl:oPag:DEDUCCION OF oDlp PICTURE aP[4];
      VALID EVAL( bSumar,oApl:oPag:DEDUCCION ) ;
      SIZE 40,10 PIXEL UPDATE
   @ 110, 00 SAY "Retención"     OF oDlp RIGHT PIXEL SIZE 50,10
   @ 110, 52 GET oGet[09] VAR oApl:oPag:RETENCION OF oDlp PICTURE aP[4];
      VALID EVAL( bSumar,oApl:oPag:RETENCION ) ;
      SIZE 40,10 PIXEL UPDATE
   @ 122, 00 SAY "Descuento"     OF oDlp RIGHT PIXEL SIZE 50,10
   @ 122, 52 GET oGet[10] VAR oApl:oPag:DESCUENTO OF oDlp PICTURE aP[4];
      VALID EVAL( bSumar,oApl:oPag:DESCUENTO ) ;
      SIZE 40,10 PIXEL UPDATE
   @ 134, 00 SAY "Ret.ICA"       OF oDlp RIGHT PIXEL SIZE 50,10
   @ 134, 52 GET oGet[11] VAR oApl:oPag:RETICA    OF oDlp PICTURE aP[4];
      VALID EVAL( bSumar,oApl:oPag:RETICA ) ;
      SIZE 40,10 PIXEL UPDATE
   @ 146, 00 SAY "Ret.IVA."      OF oDlp RIGHT PIXEL SIZE 50,10
   @ 146, 52 GET oGet[12] VAR oApl:oPag:RETIVA    OF oDlp PICTURE aP[4];
      VALID EVAL( bSumar,oApl:oPag:RETIVA ) ;
      SIZE 40,10 PIXEL UPDATE
   @ 158, 00 SAY "Ret.Fuente"    OF oDlp RIGHT PIXEL SIZE 50,10
   @ 158, 52 GET oGet[13] VAR oApl:oPag:RETFTE    OF oDlp PICTURE aP[4];
      VALID EVAL( bSumar,oApl:oPag:RETFTE ) ;
      SIZE 40,10 PIXEL UPDATE
   @ 170, 00 SAY "Ret.CREE"      OF oDlp RIGHT PIXEL SIZE 50,10
   @ 170, 52 GET oGet[14] VAR oApl:oPag:RETCRE    OF oDlp PICTURE aP[4];
      VALID EVAL( bSumar,oApl:oPag:RETCRE ) ;
      SIZE 40,10 PIXEL UPDATE
   @ 182, 00 SAY "Total Pago"    OF oDlp RIGHT PIXEL SIZE 50,10
   @ 182, 52 SAY oGet[15] VAR nPago OF oDlp PICTURE aP[4] SIZE 40,10 PIXEL;
      UPDATE COLOR nRGB( 255,0,128 )

   @ 196, 70 BUTTON oGet[16] PROMPT "Aceptar" SIZE 40,12 OF oDlp CANCEL;
      ACTION ( oApl:oPag:FORMAPAGO := VAL(aPag[nFPag,2])       ,;
              If( TotalPagado( nPago,lCaja ), (EVAL( bGrabar )),;
                (oGet[16]:oJump := oGet[3], oGet[3]:SetFocus()) )) PIXEL
/*
      ACTION ( If( TotalPagado( nFPag,@aP,1 ), (oApl:oPag:NUMCHEQUE := aP[2],;
                   oGet[16]:oJump := oGet[3], oGet[3]:SetFocus() ),;
              (If( aP[7] .AND. EMPTY(oApl:oPag:CODBANCO)    ,;
                 ( MsgStop("Falta el Código del Banco"), oGet[4]:SetFocus()),;
                 ( EVAL( bSumar,0 )                               ,;
                   oApl:oPag:FORMAPAGO := VAL(aPag[nFPag,2])      ,;
                   If( TotalPagado( nPago,aTC ), (EVAL( bGrabar )),;
                     ( oGet[16]:oJump := oGet[3], oGet[3]:SetFocus()) ))) )) ) PIXEL
*/
   @ 196,114 BUTTON oGet[17] PROMPT "Cancelar" SIZE 40,12 OF oDlp CANCEL;
      ACTION (aP[5] := .f., oDlp:End()) PIXEL
// ACTIVAGET(oGet)
ACTIVATE DIALOG oDlp CENTER

SETKEY( VK_ADD,{|| .t. } )
RETURN aP[5]

//------------------------------------//
FUNCTION TotalPagado( nPago,lCaja )
   LOCAL lOk := .f., nCambio
If nPago > 0
   If (lOk := MsgYesNo( "Graba este Pago" ))
      If nPago > oApl:nSaldo
         If lCaja
            nCambio := nPago - oApl:nSaldo
            nPago   := nPago - nCambio
            oApl:oPag:ABONO -= nCambio
            MsgStop( TRANSFORM( nCambio,"$999,999.99" ),"TOTAL CAMBIO" )
         Else
            lOk := MsgNoYes( "Desea Continuar","Pago Mayor que el Saldo" )
         EndIf
      EndIf
   EndIf
EndIf
If lOk
   If oApl:oPag:FORMAPAGO == 0
      oApl:oPag:NUMCHEQUE := oApl:oPag:CODBANCO := ""
   ElseIf oApl:oPag:FORMAPAGO == 3 .AND.;
         (oApl:oBco:EN_ESPERA .OR. !oApl:oPag:INDRED)
      nPago := oApl:oPag:DEDUCCION + oApl:oPag:RETENCION + oApl:oPag:DESCUENTO
//               oApl:oPag:RETICA    + oApl:oPag:RETIVA    + oApl:oPag:RETFTE
   EndIf
   oApl:oPag:PAGADO := nPago
EndIf
RETURN lOk

//------------------------------------//
PROCEDURE GrabaPago( lNuevo,nNumfac,nPagado,dFec )
   LOCAL aCan := { "P",CTOD(""),0 }
If lNuevo == NIL
   If oApl:oFac:Seek( {"empresa",oApl:nEmpresa,"numfac",nNumfac,"tipo",oApl:Tipo} )
      aCan[3] := nPagado
      oApl:lFam:= SaldoFac( nNumfac )
   EndIf
Else
   aCan[3] := oApl:oPag:PAGADO
   dFec    := oApl:oPag:FECPAG
   nNumfac := oApl:oFac:NUMFAC
   If lNuevo
      oApl:oPag:EMPRESA   := oApl:nEmpresa ; oApl:oPag:NUMFAC   := nNumfac
      oApl:oPag:TIPO      := oApl:Tipo     ; oApl:oPag:PORDONDE := "P"
      oApl:oPag:Append()
   Else
      aCan[3]     -= nPagado
      oApl:nSaldo -= nPagado
      oApl:oPag:Update(.f.,1)
   EndIf
EndIf

If aCan[3] # 0
   GrabaSal( nNumfac,1,aCan[3] )
EndIf
If (oApl:nSaldo - aCan[3]) == 0
   aCan := { "C",dFec }
EndIf

Guardar( "UPDATE cadfactu SET indicador = '" + aCan[1]   +;
                "', fechacan = " + xValToChar( aCan[2] ) +;
         " WHERE empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
           " AND numfac  = " + LTRIM(STR(nNumfac))       +;
           " AND tipo    = '"+ oApl:Tipo + "'", "cadfactu" )
//oApl:oFac:INDICADOR := aCan[1] ; oApl:oFac:FECHACAN := aCan[2]
//oApl:oFac:Update(.f.,1)
RETURN

//------------------------------------//
FUNCTION Notas( cText,cMsg )
   DEFAULT cMsg := "NOTAS DE FACTURA"
   cText := TRIM(cText)
If MemoEdit( @cText,cMsg )
   If cMsg == "ANOTACIONES"
      oApl:oFah:NOTA := TRIM(cText)
      If MlCount( oApl:oFah:NOTA,78 ) > 0
         If oApl:oFah:lOK
            oApl:oFah:Update(.f.,1)
         Else
            oApl:oFah:NUMFAC := oApl:oFac:NUMFAC
            oApl:oFah:TIPO   := oApl:Tipo       ; oApl:oFah:Append( .t. )
         EndIf
      EndIf
      cText := nil
   ElseIf cMsg == "NOTAS DE FACTURA"
      oApl:oEmp:NOTA := TRIM(cText)
      cText := "UPDATE cadempre SET nota = '" + oApl:oEmp:NOTA +;
               "' WHERE empresa = 4"
      MSQuery( oApl:oMySql:hConnect,cText )
      cText := nil
   EndIf
EndIf
RETURN cText