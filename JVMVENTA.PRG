// Programa.: CAOVENTA.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Modulo para la Elaboracion de las Facturas
#include "Fivewin.ch"
#include "TSBrowse.ch"
#include "Btnget.ch"

MEMVAR oApl

#define CLR_PINK  nRGB( 128, 150, 150) //255, 128, 128
#define CLR_NBLUE nRGB( 128, 128, 192)

FUNCTION CaoVenta()
   LOCAL oDlg, oLbx, aColor[2], aRect, lNoBlink := .f.
   LOCAL cTit, nA, oBtn := ARRAY(9)
   LOCAL oAr, oF, oNi
If (aColor[ 1 ] := GetSysColor( COLOR_INACTIVECAPTION ) ) != ;
   GetSysColor( COLOR_ACTIVECAPTION )
   aColor[ 2 ] := GetSysColor( COLOR_INACTCAPTEXT )
   lNoBlink := .t.
   SBNoBlink()
EndIf
Empresa( .t. )
 oAr := TInv()     ; oAr:New()
 oF  := TFactura() ;  oF:New()
 oNi := TNits()    ; oNi:New()
cTit := "Ventas - Facturas || "
oApl:oFac:nLimit := 200
oF:Iniciar()
oF:AdicArray()
SETKEY( VK_F4,{|| If( Empresa(), ( oDlg:SetText(cTit + oApl:cEmpresa),;
                      oF:Iniciar(), oDlg:Update() ), ), oF:oG[1]:SetFocus() } )
DEFINE DIALOG oDlg RESOURCE "FACTURAS" TITLE cTit + oApl:cEmpresa OF oApl:oWnd
   REDEFINE SAY           VAR oF:nSigFac  ID  1 OF oDlg UPDATE COLOR "B+/W"
   REDEFINE GET oF:oG[01] VAR oApl:Tipo   ID  3 OF oDlg UPDATE PICTURE "!";
      VALID( If( oApl:Tipo $ oF:cTipo, ( oF:nSigFac := ;
                 SgteNumero( "NUMFAC"+oApl:Tipo,oApl:nEmpresa,.f. ),;
                 oDlg:Update(), .t. )                              ,;
               ( MsgStop( "El Tipo es ["+oF:cTipo+"]","<< OJO >>" ), .f. ) ) )
   REDEFINE BTNGET oF:oG[02] VAR oF:aM[2] ID  4 OF oDlg               ;
      RESOURCE "BUSCAR"                                               ;
      ACTION EVAL({|| If(oF:Mostrar(), (oF:aM[2] := oF:oDb:NUMFAC    ,;
                        oApl:nEmpresa := oF:oDb:EMPRESA              ,;
                        oApl:Tipo     := oF:oDb:TIPO                 ,;
                        oF:oG[1]:Refresh(), oF:oG[2]:lValid(.f.)),)}) ;
      VALID( If( !oApl:oFac:Seek( { "empresa",oApl:nEmpresa,"numfac" ,;
                      oF:aM[2],"tipo",oApl:Tipo} ) .AND. oF:aM[2] # 0,;
               ( MsgStop("Factura NO EXISTE"), .f. )                 ,;
               (oF:AdicArray(),  oLbx:aArray := oF:aV,  oDlg:Update(),;
                oF:Dscto( 0,oLbx ) ,;
                If( oApl:oFac:lOK, (oF:oG[2]:oJump := oLbx), ), .t. )))
   REDEFINE GET oF:oG[03] VAR oApl:oFac:FECHOY   ID  6 OF oDlg UPDATE ;
      VALID oF:Fechas( oApl:oFac:lOK,1 ) ;
      WHEN oApl:cFecha == "SI"
   REDEFINE BTNGET oF:oG[04] VAR oF:aM[3]   ID  8 OF oDlg            ;
      RESOURCE "BUSCAR"                                              ;
      ACTION EVAL({|| If( oNi:Mostrar(), (oF:aM[3] := oNi:oDb:CODIGO,;
                          oF:oG[4]:Refresh() ), ) })                 ;
      VALID EVAL( {|| If( oNi:Buscar( oF:aM[3],,.t. )               ,;
                 (oApl:oFac:CODIGO_NIT := oNi:oDb:CODIGO_NIT        ,;
                  oApl:oFac:CLIENTE    := oF:aM[4] := oNi:oDb:NOMBRE,;
                  oF:aM[21] := oF:FechaDev( "RETEN" )               ,;
                  oDlg:Update(), .t. )                              ,;
              (If( MsgYesNo("Desea ingresarlo","Este Nit no Existe"),;
                  oNi:Editar( ,.t.,,oF:aM[3] ), ),.f.) ) } ) UPDATE
   REDEFINE SAY           VAR oF:aM[4]           ID  9 OF oDlg UPDATE
   REDEFINE GET oF:oG[05] VAR oApl:oFac:CLIENTE  ID 11 OF oDlg UPDATE PICTURE "@!"
   REDEFINE GET oF:oG[06] VAR oApl:oFac:FECHAENT ID 13 OF oDlg UPDATE;
      WHEN oApl:Tipo $ oApl:cTF
   REDEFINE SAY VAR oApl:oFac:PAGINAS  ID 15 OF oDlg UPDATE PICTURE "99"
   REDEFINE CHECKBOX oF:oG[07] VAR oApl:oFac:EFECTIVO ID 31 OF oDlg UPDATE;
      VALID ( oDlg:GoNextCtrl( oF:oG[08]:hWnd ), .t. );
      WHEN oApl:oEmp:PAGOS
   REDEFINE COMBOBOX oF:oG[08] VAR oF:cVende ITEMS ArrayCol( oF:aVen,1 );
      ID 33 OF oDlg UPDATE;
      VALID ( oApl:oFac:CODIGO_VEN := oF:aVen[oF:oG[08]:nAt,2],;
              oDlg:GoNextCtrl( oF:oG[09]:hWnd ), .t. )         ;
      WHEN oF:aM[2] == 0
   REDEFINE GET oF:oG[09] VAR oApl:oFac:ORDEN    ID 17 OF oDlg UPDATE PICTURE "@!";
      WHEN oApl:Tipo == "C"
   REDEFINE COMBOBOX oF:oG[14] VAR oApl:oFac:CLASECLI ITEMS oF:aCli ;
      ID 45 OF oDlg UPDATE;
      ON CHANGE ( oF:Dscto( 99,oLbx ) )               ;
      VALID ( oDlg:GoNextCtrl( oF:oG[10]:hWnd ), .t. );
      WHEN oF:aM[2] == 0
  //  VALID ( If( oApl:oFac:CLASECLI # nA, oF:Dscto( 99,oLbx ), ),;
  //          oDlg:GoNextCtrl( oF:oG[10]:hWnd ), .t. )       ;
  //oF:oG[14]:bGotFocus := { || nA := oApl:oFac:CLASECLI }
   REDEFINE GET oF:oG[10] VAR oApl:oFac:RETFTE   ID 19 OF oDlg UPDATE PICTURE "99,999,999";
      WHEN oF:aM[21]
   REDEFINE GET oF:oG[11] VAR oApl:oFac:RETICA   ID 21 OF oDlg UPDATE PICTURE "99,999,999";
      WHEN oF:aM[21]
   REDEFINE GET oF:oG[12] VAR oApl:oFac:RETIVA   ID 23 OF oDlg UPDATE PICTURE "99,999,999";
      WHEN oF:aM[21]
   REDEFINE GET oF:oG[13] VAR oApl:oFac:RETCRE   ID 25 OF oDlg UPDATE PICTURE "99,999,999";
      WHEN oF:aM[21]
   REDEFINE SAY VAR oF:aM[6]    ID 27 OF oDlg PICTURE "999,999,999" UPDATE
   REDEFINE SAY VAR oApl:nSaldo ID 29 OF oDlg PICTURE "999,999,999" UPDATE
   REDEFINE SAY VAR oF:aM[7]    ID 30 OF oDlg UPDATE COLOR nRGB( 255,0,0 )
   ACTIVAGET(oF:oG)

   REDEFINE BTNBMP oBtn[1] ID 34 OF oDlg RESOURCE "IMPRIMIR" ;
      ACTION oF:Listado( oDlg,oLbx )     MESSAGE "Imprime Factura (F3)"
   REDEFINE BTNBMP oBtn[2] ID 35 OF oDlg RESOURCE "REINDEZAR";
      ACTION ( oF:aM[1] := .t., oLbx:KeyDown( VK_DELETE,0 ) );
      MESSAGE "Borrar Código (F5)"
   REDEFINE BTNBMP oBtn[3] ID 36 OF oDlg RESOURCE "DELREC"   ;
      ACTION oF:DelFactu( oDlg,oLbx )    MESSAGE "Anular Factura (F6)"
   REDEFINE BTNBMP oBtn[4] ID 37 OF oDlg RESOURCE "NEW"      ;
      ACTION oF:Iniciar( oDlg,oLbx )     MESSAGE "Nueva Factura (F7)"
   REDEFINE BTNBMP oBtn[5] ID 38 OF oDlg RESOURCE "DEDISCO"  ;
      ACTION oF:Guardar( oDlg,oLbx )     MESSAGE "Grabar Factura (F11)"
   REDEFINE BTNBMP oBtn[6] ID 39 OF oDlg RESOURCE "MIRAR"    ;
      ACTION (oF:Abonos(), oF:Iniciar( oDlg,oLbx ));
      MESSAGE "Ver los Pagos (F8)"
   REDEFINE BTNBMP oBtn[7] ID 40 OF oDlg RESOURCE "MONEY"    ;
      ACTION MsgInfo( "Dispobible para lo que SEA" );
      MESSAGE "Pagos a Cartera"
   REDEFINE BTNBMP oBtn[8] ID 41 OF oDlg RESOURCE "CALC"     ;
      ACTION WinExec("Calc")             MESSAGE "Calculadora"
   REDEFINE BTNBMP oBtn[9] ID 42 OF oDlg RESOURCE "SALIR"    ;
      ACTION oDlg:End()                  MESSAGE "Regresar al Menu"
   REDEFINE BROWSE oLbx ID 44 OF oDlg CELLED ;      // CELLED es requerida
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
                            If(nKey=VK_F11, oBtn[5]:Click() ,;
                            If(GetKeyState(VK_CONTROL) .AND. nKey=65, oF:Borrar(), )))))))) }
//                          If(nKey=VK_F11, oBtn[5]:Click() , ))))))) }
   oLbx:SetAppendMode( oF:lNuevo )            // Activando Auto Append Mode
   oLbx:SetDeleteMode( .t.,.f.,{ |nAt,oLbx| oF:DelArray(oLbx) },;
                  {|oLbx| oF:Dscto( 0,oLbx ) } ) // lOnOff, lConfirm, bDelete

   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 1;
       TITLE "Código"+CRLF+"Artículo"            ;
       SIZE  90 EDITABLE;          // Esta columna es editable
       3DLOOK TRUE, TRUE, TRUE;    // Celda, Titulo, Footers
       MOVE DT_MOVE_NEXT;          // Cursor pasa a la Sig.Columna editable
       VALID { |uVar| oF:Buscar( uVar,oLbx ) }; // don't want empty rows
       ALIGN DT_LEFT, DT_CENTER  ; // Celda, Titulo, Footer
       PREEDIT {|uVar| oF:aM[11] := uVar, nA := oLbx:nAt ,;
                       oF:aM[13] := If( nA > LEN(oF:aV), 0, oF:aV[nA,11] ) };
       FOOTER { || STR( oLbx:nLen,4 ) + " Items" };
       WHEN oF:EditArray( oLbx )
    oLbx:aColumns[01]:bPostEdit := { |uVar| oF:aV[nA,05] := oF:aM[05],;
       oF:aV[nA,01] := oF:aM[11], oF:aV[nA,02] := oF:aM[12],;
       oF:aV[nA,03] := oF:aM[13], oF:aV[nA,06] := oF:aM[15],;
       oF:aV[nA,08] := oF:aM[14], oF:aV[nA,09] := oF:aM[16],;
       oF:aV[nA,12] := oF:aM[17], oF:aV[nA,13] := oF:aM[18],;
       oF:aV[nA,14] := oF:aM[14], oF:aV[nA,15] := oF:aM[19],;
       oF:aV[nA,16] := oF:aM[20], oF:aV[nA,17] := oApl:aInvme[2],;
       oF:Dscto( 1,oLbx ) }
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
       TITLE "Cantidad"     PICTURE "999,999.999";
       SIZE  58 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER ;
       POSTEDIT { |uVar| If( oLbx:lChanged, oF:Dscto( 4,oLbx,uVar ), ) } ;
       VALID { |uVar| oF:DelArray( oLbx,4,uVar ) } ;
       WHEN oF:EditArray( oLbx )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 5;
       TITLE "Unidad"+CRLF+"Medida"  PICTURE "!!";
       SIZE  50 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_LEFT, DT_CENTER;
       PREEDIT  {|uVar| oF:aM[05] := uVar, nA := oLbx:nAt }      ;
       POSTEDIT {|uVar| If( oLbx:lChanged .AND. oF:aM[05] # uVar,;
                            oF:Dscto( 5,oLbx,uVar ), ) }         ;
       WHEN oF:EditArray( oLbx ) ;
       VALID { |uVar| oF:Buscar( uVar,,nA ) }
    // activando BtnGet para la columna 5 y habilitando (Combo Browse)
    oLbx:SetBtnGet( 5, "This", { | oGet, cVar |   ;
                If( !GetKeyState( VK_ESCAPE )    ,;
                  (aRect := GetCoors( oGet:hWnd ),;
                   cVar  := oGet:Value()         ,;
                   cVar  := oF:ComboBrowse( cVar,aRect[1],aRect[4],oGet:oWnd,oLbx:nAt ),;
                   oGet:cText( cVar ), oGet:Refresh(),;
                   oGet:KeyDown( VK_RETURN, 0 ) ), ) }, 16 )
     oLbx:aColumns[ 5 ]:cMsg := "Presione F2 o Click boton para ver la lista"

   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 8;
       TITLE "Precio"+CRLF+"Neto"   PICTURE "99,999,999" ;
       SIZE  76 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       VALID { |uVar| oF:DelArray( oLbx,8,uVar ) } ;
       FOOTER { || TRANSFORM( oF:aM[09], "99,999,999" ) };
       PREEDIT  {|uVar| nA := oLbx:nAt, oF:aM[13] := oF:aV[nA,03] };
       POSTEDIT {|uVar| If( oLbx:lChanged .OR. oF:aM[13] # uVar   ,;
                            oF:Dscto( 8,oLbx,uVar ), ) }           ;
       WHEN oF:EditArray( oLbx )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 6;
       TITLE "%"+CRLF+"Dscto."   PICTURE "999.99" ;
       SIZE  48 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER ;
       VALID { |uVar| If( Rango( uVar,0,100 ), .t., ;
              (MsgStop( "El Porcentaje debe ser entre 0 y 100",">>OJO<<" ), .f.)) };
       POSTEDIT { |uVar| If( oLbx:lChanged, oF:Dscto( 6,oLbx,uVar ), ) };
       WHEN oF:EditArray( oLbx )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 7;
       TITLE "Descuento"     PICTURE "99,999,999" ;
       SIZE  74 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       VALID { |uVar| oF:DelArray( oLbx,7,uVar ) };
       FOOTER { || TRANSFORM( oF:aM[08], "99,999,999" ) };
       POSTEDIT { |uVar| If( oLbx:lChanged, oF:Dscto( 7,oLbx,uVar ), ) };
       WHEN oF:EditArray( oLbx )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 9;
       TITLE "Monto"+CRLF+"I.V.A"   PICTURE "99,999,999" ;
       SIZE  74 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       FOOTER { || TRANSFORM( oF:aM[10], "99,999,999" ) };
       POSTEDIT { |uVar| If( oLbx:lChanged, oF:Dscto( 0,oLbx,uVar ), ) };
       WHEN oF:EditArray( oLbx )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 10;
       TITLE "Indicador" ;
       SIZE  80 ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_LEFT, DT_CENTER
   // Asignando Valores por defaults para nueva Fila creada con Auto Append.
   oLbx:aDefault := { SPACE(12), SPACE(40), 0, 1, "UN", 0, 0, 0, 0, " ", 0, .f., 1, 0, 1, "", 0 }
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

 DATA aDF  AS ARRAY INIT { .16,595000,.035,.0045,.75 }
 DATA aM   AS ARRAY INIT { .f.,0,0,"",0,0,"",0,0,0,"","",0,0,0,0,.f.,0,0,"",.f.,.f.,"" }
 DATA aCli AS ARRAY INIT { " " }
 DATA aPag AS ARRAY INIT ArrayCombo( "FPAGO" )
 DATA aVen AS ARRAY INIT { {" ",0} }
 DATA cVende        INIT " "
 DATA lNuevo        INIT .t.
 DATA oG            INIT ARRAY(14)
 DATA aCta, aPrv, aV, aUM, cTipo, lCierre, nSigFac, nOptica
 DATA oMvc, oMvd, oVen

 METHOD NEW( xCoti ) Constructor
 METHOD Iniciar( oDlg,oLbx )
 METHOD AdicArray()
 METHOD EditArray( oLbx )
 METHOD Buscar( xBuscar,oLbx,nA )
 METHOD Dscto( nPos,oLbx,mGetVar )
 METHOD DelArray( oLbx,nCol,uVar )
 METHOD DelFactu( oDlg,oLbx )
 METHOD FechaDev( cMsg,dFec )
 METHOD Fechas( lOK,nMsg )
 METHOD Guardar( oDlg,oLbx )
 METHOD Listado( oDlg,oLbx )
 METHOD Abonos()
 METHOD Borrar( oLbx,oLbf )
 METHOD Editar( lNuevo,oLbx )
 METHOD Mostrar( lAyuda,nOrd )
 METHOD Cambios( lCambio,nAbono,nPago )
 METHOD ComboBrowse( cState,nRow,nCol,oWnd,nA )
 METHOD Paginas( cFac,nFac )
 METHOD Retencion( nSubTot )
ENDCLASS

//------------------------------------//
METHOD New( xCoti ) CLASS TFactura
 If xCoti == NIL
    Super:New( oApl:oFac )
    ::oVen := oApl:Abrir( "cadfactd","empresa, numfac, tipo",,,50 )
 Else
    Super:New( xCoti )
    :: oG  := ARRAY(7)
    ::oVen := oApl:Abrir( "cadcotid","empresa, numero",,,50 )
 EndIf
 ::aOrden := { {"<None> ",1},{"Factura",3},;
               {"Nombre" ,6},{"Fecha"  ,5} }
 ::bNew := ::bEditar := ::bVer := {||.t. }
 ::aCta := Cuentas( 3,1 )
 ::oMvc := oApl:Abrir( "cgemovc" ,"empresa, ano_mes, control",.t.,,5 )
 ::oMvd := oApl:Abrir( "cgemovd" ,"empresa, ano_mes, control",.t.,,10 )
 ::aPrv := Privileg( "FACTURAS" )
 ::aCli := Buscar( "SELECT desplegar FROM cadcombo WHERE tipo = 'CLIENTE' ORDER BY retornar","CM",,9 )
 If LEN( ::aCli ) == 0
    ::aCli := { "" }
 EndIf
 ::aUM  := Buscar( "SELECT nombre, codigo_nit FROM vendedor ORDER BY nombre","CM",,9 )
 If LEN( ::aUM ) > 0
    AEVAL( ::aUM, {| e | AADD( ::aVen,{ e[1],e[2] } ) } )
 EndIf
 ::aUM  := ArrayCombo( "MEDIDAS",1 )
 oApl:oFac:xBlank()
RETURN NIL

//------------------------------------//
METHOD Iniciar( oDlg,oLbx ) CLASS TFactura
   LOCAL cTipo
If oDlg == NIL
   ::nOptica := oApl:nEmpresa
   ::nSigFac := SgteNumero( "NUMFAC"+oApl:Tipo,::nOptica,.f. )
   cTipo     := ALLTRIM(oApl:oEmp:TIPOFAC)
   oApl:Tipo := LEFT( Saca( @cTipo,"," ),1 )
   oApl:Tipo := oApl:cFT
   ::cTipo   := cTipo
ElseIf VALTYPE( oDlg ) == "O"
   AEVAL( ::aM, {|xV,nI| ::aM[nI] := {"",CTOD(""),.f.,0}[AT(VALTYPE(xV),"CDLN")] } )
   ::AdicArray() ; oLbx:aArray := ::aV
   oApl:oFac:xBlank()
   oDlg:Update() ; oLbx:Refresh()
   ::oG[01]:SetFocus()
Else
   If oApl:oFac:CLASECLI == 2 .AND. oApl:oInv:PUNIDAD > 0
      //Mayorista
      ::aM[13] := oApl:oInv:PUNIDAD
   ElseIf oApl:oFac:CLASECLI == 3
      //Especial
      ::aM[13] := oApl:oInv:PCOSTO +;
                  ROUND( oApl:oInv:PCOSTO * 3/100,0 )
   Else
      ::aM[13] := oApl:oInv:PPUBLI
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD AdicArray() CLASS TFactura
   LOCAL aRes, hRes, nL
If ::aM[2] == 0
   ::aM[7] := ""
   ::lNuevo:= .t.
   oApl:nSaldo := 0
   oApl:nEmpresa := ::nOptica
   oApl:oFac:lOK       := .f.
   oApl:oFac:FECHOY    := oApl:dFec
   oApl:oFac:FECHAENT  := oApl:dFec + 30
   oApl:oFac:CODIGO_NIT:= 1
   oApl:oFac:PAGINAS   := 1
   oApl:oFac:CLASECLI  := 1
   If oApl:oEmp:PAGOS .AND. oApl:Tipo # "C"
      oApl:oFac:EFECTIVO := .T.
   EndIf
   oApl:oFac:INDICADOR := If( oApl:oFac:EFECTIVO  , "C", "P" )
 //oApl:oFac:INDICADOR := If( oApl:Tipo $ oApl:cTF, "P", "C" )
Else
   oApl:cPer:= NtChr( oApl:dFec,"1" )
   oApl:lFam:= SaldoFac( ::aM[2] )
   ::lNuevo := !oApl:lEnLinea
   If ::nOptica == oApl:oFac:EMPRESA
      nL := AT( oApl:oFac:INDICADOR,"APCN" ) +1
      ::aM[7] := {"","ANULADA","PENDIENTE","CANCELADA","N.Credito"}[nL]
   Else
      ::aM[7] := ArrayValor( oApl:aOptic,STR(oApl:oFac:EMPRESA,2) )
   EndIf
EndIf
 ::aM[22] := oApl:oFac:EFECTIVO
 ::Fechas( .f. )
 ::aV := {}
aRes := "SELECT v.codigo, v.ppubli, v.cantidad, v.unidadmed, v.despor, v.desmon,"   +;
              " v.precioven, v.montoiva, v.indicador, v.row_id, v.pcosto, c.numero "+;
        "FROM cadfactd v LEFT JOIN cadnotac c USING(empresa, numfac)"               +;
                       " LEFT JOIN cadnotad d"          +;
          " ON c.empresa = d.empresa"                   +;
         " AND c.numero  = d.numero"                    +;
         " AND v.codigo  = d.codigo "                   +;
        "WHERE v.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND v.numfac  = " + LTRIM(STR(::aM[2]))      +;
         " AND v.tipo    = " + xValToChar( oApl:Tipo )  +;
         " GROUP BY v.row_id"
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aRes[09] == "N"
      aRes[09] += "C." + LTRIM(STR(aRes[12]))
   EndIf
   ::Buscar( aRes[01] )
   ::aM[14] := ROUND( (aRes[07] + aRes[06]) / aRes[03],2 )
   AADD( ::aV,{ aRes[01], ::aM[12]          , aRes[02],;
                aRes[03], aRes[04]          , aRes[05],;
                aRes[06], aRes[07]          , aRes[08],;
                aRes[09], aRes[10], ::aM[17], ::aM[18],;
                ::aM[14], ::aM[19], ::aM[20], aRes[11] } )
   nL --
EndDo
MSFreeResult( hRes )
If LEN( ::aV ) == 0
   AADD( ::aV,{ SPACE(12), SPACE(40), 0, 1, "UN", 0, 0, 0, 0, " ", 0, .f., 1, 0, 1, "", 0 } )
EndIf
oApl:oNit:Seek( {"codigo_nit",oApl:oFac:CODIGO_NIT} )
 ::aM[03] := oApl:oNit:CODIGO ; ::aM[4] := oApl:oNit:NOMBRE
 ::aM[06] := oApl:oFac:TOTALFAC
 ::aM[21] := ::FechaDev( "RETEN" )
 ::cVende := ArrayValor( ::aVen,oApl:oFac:CODIGO_VEN )
//::cVende := ArrayValor( ::aVen,oApl:oFac:CODIGO_VEN,{|xV| oApl:oFac:CODIGO_VEN := xV} )
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
   ElseIf oApl:oFac:lOK .AND. (!::aPrv[2] .OR. LEFT( ::aV[nA,10],1 ) $ "AD")
      MsgStop( "Este Registro no se Puede Modificar","Lo Siento" )
      lEdit := .f.
   ElseIf oLbx:nCell == 6 .AND. !::aPrv[1]
      oLbx:nCell := 7 ; lEdit := .f.
      oLbx:HiliteCell( 7 ) ; oLbx:Refresh( .F. )
   EndIf
EndIf
RETURN lEdit

//------------------------------------//
METHOD Buscar( xBuscar,oLbx,nA ) CLASS TFactura
   LOCAL lOK := .t.
If nA # NIL
   If ::aV[nA,16] # xBuscar
      If Buscar( {"codcon",::aV[nA,15],"de",xBuscar},"convertir","multipor",8,,4 ) == 0
         MsgStop( "No Existe Unidad de Medida","<< OJO >>" )
         lOK := .f.
      EndIf
   EndIf
Else
 //If (lOK := oApl:oInv:Seek( {"codigo",xBuscar} ))
   If (lOK := BuscaCob( @xBuscar ))
      If oApl:Tipo # "X"
         ::aM[18] := If( oApl:oEmp:TREGIMEN == 1 .OR. !oApl:oInv:INDIVA, 0,;
                     If( oApl:oInv:IMPUESTO == 0, ::aDF[1],;
                         ROUND(oApl:oInv:IMPUESTO/100,2) )) + 1
      Else
         ::aM[18] := 1
      EndIf
      ::aM[17] := If( ::aM[18] > 1 .AND. oApl:Tipo $ "CZ", .t., .f. )
      ::aM[11] := xBuscar
      ::aM[12] := oApl:oInv:DESCRIP
      ::aM[19] := oApl:oInv:CODCON
      ::aM[20] := oApl:oInv:UNIDADMED
      ::aM[23] := oApl:oInv:AJUSTE_ESP
      If oLbx == NIL
         RETURN NIL
      EndIf
      nA := oLbx:nAt
      If nA > LEN(::aV) .OR. ::aV[nA,1] # xBuscar
         If NtChr( xBuscar ) >= oApl:oEmp:LENCOD
            If SaldoInv( xBuscar,oApl:cPer,1 ) <= 0
               If !MsgNoYes( "SIN Existencia="+STR(oApl:aInvme[1])+" CONTINUA ?",::aM[12] )
                  RETURN .f.
               EndIf
            EndIf
         Else
            oApl:aInvme[2] := 0
         EndIf
     //  oApl:aInvme[2] := Buscar( "SELECT sf_pcosto(" + LTRIM(STR(oApl:nEmpresa))+;
     //                                           ", " + ALLTRIM( xBuscar )       +;
     //                                       ", " + xValToChar(oApl:oFac:FECHOY) +;
     //                                       ") FROM DUAL","CM",,,,4 )
         If oApl:aInvme[2] == 0 .OR. oApl:aInvme[2] > oApl:oInv:PCOSTO
            oApl:aInvme[2] := oApl:oInv:PCOSTO
         EndIf
         If oApl:oInv:DESPOR > 0
            ::aM[15] := If( MsgNoYes( TRANSFORM(oApl:oInv:DESPOR,"999.99%"),;
                            "Le Aplico este Descuento" ), oApl:oInv:DESPOR, 0 )
         EndIf
         ::aM[05] := oApl:oInv:UNIDADMED
       //::aM[13] := oApl:oInv:PPUBLI
         ::Iniciar( 1 )
       //MsgInfo( TRANSFORM(::aM[18],"999.99"),"NUEVO" )
         If ::aM[17]
            ::aM[14] := ROUND( ::aM[13] / ::aM[18],2 )
         Else
            ::aM[14] := ::aM[13]
         EndIf
/*
         If ::aM[17]
            ::aM[13] := ROUND( ::aM[13] / ::aM[18],0 )
            ::aM[14] := ::aM[13]
         Else
            ::aM[14] := ROUND( ::aM[13] / ::aM[18],0 )
         EndIf
*/
         ::aM[16] := ::aM[13] - ::aM[14]
      Else
         ::aM[05] := ::aV[nA,5]
         ::aM[13] := ::aV[nA,3]
         ::aM[14] := ROUND((::aV[nA,8] + ::aV[nA,9]) / ::aM[18],2 )
         ::aM[14] := ROUND((::aV[nA,7] + ::aM[14]) / ::aV[nA,4],2 )
         ::aM[15] := ::aV[nA,6]
         ::aM[16] := ::aV[nA,9]
      EndIf
   ElseIf !EMPTY( xBuscar )
      MsgStop( "Este Código NO EXISTE !!!",xBuscar )
   EndIf
EndIf
RETURN If( EMPTY( xBuscar ), .f., lOK )

//------------------------------------//
METHOD Dscto( nPos,oLbx,mGetVar ) CLASS TFactura
   LOCAL nSubTot, nA := oLbx:nAt
do Case
Case nPos == 5           // UnidadMed
   If oApl:oInv:CODIGO # ::aV[nA,1]
      oApl:oInv:Seek( {"codigo",::aV[nA,1]} )
   EndIf
   If oApl:oInv:PUNIDAD > 0
      ::aM[13] := oApl:oInv:PUNIDAD
   Else
      ::aM[13] := AFormula( ::aV[nA,3],mGetVar,::aV[nA,16],::aV[nA,15] )
   EndIf
   ::aV[nA,03] := ROUND( ::aM[13] / If( ::aV[nA,12], 1, ::aV[nA,13] ),0 )
   ::aV[nA,05] := mGetVar
Case nPos == 6           // % Descuento
   ::aV[nA,06] := If( mGetVar == 0, 0, ::aV[nA,06] )
Case nPos == 8           // Precio Neto
   If ::aV[nA,04] > 1 .AND. mGetVar > 0
      If !MsgYesNo( "Este es el Precio Unitario","DIVIDIR" )
         mGetVar := ROUND( mGetVar/::aV[nA,04],2 )
      EndIf
   EndIf
   ::aV[nA,03] := mGetVar
   If oApl:oEmp:PRINTIVA .AND. ::aV[nA,12] .AND. mGetVar > 0
      //If MsgYesNo( "Precio con IVA incluido","I.V.A."+STR(::aV[nA,13],5,2) )
         mGetVar := ROUND( mGetVar / ::aV[nA,13],2 )
      //EndIf
   EndIf
   ::aV[nA,14] := mGetVar
EndCase
If Rango( nPos,1,8 )
   nSubTot    := ROUND( ::aV[nA,14] * ::aV[nA,04],0 )
   ::aV[nA,7] := If( nPos == 7, mGetVar, If( ::aV[nA,06] = 0, ::aV[nA,07],;
                     ROUND( nSubTot * ::aV[nA,6] / 100,0 ) ) )
   nSubTot    -= ::aV[nA,7]
   ::aV[nA,8] := ROUND( nSubTot / If( ::aV[nA,12], 1, ::aV[nA,13] ),0 )
   If ::aV[nA,7] == 0 .AND. oApl:oEmp:PRINTIVA
      ::aV[nA,9] := ROUND( ::aV[nA,3] * ::aV[nA,04],0 ) - ::aV[nA,8]
   Else
      ::aV[nA,9] := ROUND( ::aV[nA,8] * ::aV[nA,13],0 ) - ::aV[nA,8]
   EndIf
/*
   nSubTot    := ROUND( ::aV[nA,03] * ::aV[nA,04],0 )
   ::aV[nA,7] := If( nPos == 7, mGetVar, If( ::aV[nA,06] = 0, ::aV[nA,07],;
                     ROUND( nSubTot * ::aV[nA,6] / 100,0 ) ) )
   nSubTot     -= ::aV[nA,7]
   ::aV[nA,8] := ROUND( nSubTot / If( ::aV[nA,12], 1, ::aV[nA,13] ),0 )
   ::aV[nA,9] := ROUND( ::aV[nA,8] * ::aV[nA,13],0 ) - ::aV[nA,8]
//   ::aV[nA,8] := nSubTot - ::aV[nA,7]
//   ::aV[nA,9] := If( ::aV[nA,12], ROUND( ::aV[nA,8] * ::aV[nA,13],0 ), nSubTot - ::aV[nA,8] )
*/
ElseIf nPos == 99
   //MsgInfo( "Recalcular" )
   FOR nA := 1 TO LEN( ::aV )
      If !EMPTY( ::aV[nA,01] ) .AND. LEFT( ::aV[nA,10],1 ) == " "
         oApl:oInv:Seek( {"codigo",::aV[nA,01]} )
         ::Iniciar( 1 )
         If ::aV[nA,12]
            ::aM[14] := ROUND( ::aM[13] / ::aV[nA,13],2 )
         Else
            ::aM[14] := ::aM[13]
         EndIf
         ::aV[nA,03] := ::aM[13]
         ::aV[nA,08] := ::aM[14]
         ::aV[nA,09] := ::aM[13] - ::aM[14]
         ::aV[nA,14] := ::aM[14]
      EndIf
   NEXT nA
EndIf
 ::aM[08] := ::aM[09] := ::aM[10] := 0
AEVAL( ::aV, { | e | ::aM[08] += e[ 7 ], ::aM[09] += e[ 8 ], ::aM[10] += e[ 9 ] } )
 ::aM[09] += ::aM[10]
If oApl:oFac:TOTALDES  # ::aM[08] .OR. oApl:oFac:TOTALIVA # ::aM[10] .OR. ;
   oApl:oFac:TOTALFAC  # ::aM[09] .OR. oLbx:lChanged
   oApl:oFac:TOTALDES := ::aM[08] ; oApl:oFac:TOTALIVA := ::aM[10]
   oApl:oFac:TOTALFAC := ::aM[09]
   ::Retencion( (::aM[09] - ::aM[10]) )
   AEVAL( ::oG, {|o| o:Refresh() },10,4 )
EndIf
oLbx:Refresh() ; oLbx:DrawFooters()
RETURN NIL

//------------------------------------//
METHOD DelArray( oLbx,nCol,uVar ) CLASS TFactura
   LOCAL lSi := .t., nA := oLbx:nAt
If nCol == NIL
    lSi := .f.
   If ::aV[nA,11] == 0
      lSi := .t.
   ElseIf ::aM[1] .AND. oApl:oFac:lOK .AND. ::aPrv[3]
      If MsgNoYes( "Elimina este Código",::aV[nA,01] )
         ::oVen:Seek( {"row_id",::aV[nA,11]} )
         If LEFT( ::aV[nA,10],1 ) $ "AD"
            Actualiz( ::aV[nA,1],-::aV[nA,4],::oVen:FECDEV,7,,::aV[nA,5] )
         EndIf
            Actualiz( ::aV[nA,1],-::aV[nA,4],oApl:oFac:FECHOY,2,,::aV[nA,5] )
         ::oVen:Delete(.f.,1)
         lSi := .t.
      EndIf
   EndIf
   ::aM[1] := .f.
ElseIf nCol == 4
   If uVar <= 0
      MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>" )
      lSi := .f.
   EndIf
ElseIf nCol == 7
   If uVar < 0
      MsgStop( "Descuento tiene que ser Positivo","<<OJO>>" )
      lSi := .f.
   ElseIf uVar > ::aV[nA,08]
      uVar := "  Descuento" + TRANSFORM( uVar,"$999,999,999" ) + CRLF +;
              "Precio Neto" + TRANSFORM( ::aV[nA,07]+::aV[nA,08],"$999,999,999" )
      MsgStop( uVar,"Descuento MAYOR que el Precio Neto" )
      lSi := .f.
   EndIf
ElseIf nCol == 8
   oApl:aInvme[2] := AFormula( ::aV[nA,17],::aV[nA,05],::aV[nA,16],::aV[nA,15] )
   oApl:aInvme[2] := ROUND( ::aV[nA,4] * oApl:aInvme[2],2 )
   If uVar < 0
      MsgStop( "Precio Neto tiene que ser Positivo","<<OJO>>" )
      lSi := .f.
   ElseIf uVar < oApl:aInvme[2]
      uVar := "Precio  Neto" + TRANSFORM( uVar,"$999,999,999" ) + CRLF +;
              "Precio Costo" + TRANSFORM( oApl:aInvme[2],"$999,999,999" )
      MsgStop( uVar,"Precio Costo MAYOR que el Precio Neto" )
      lSi := .f.
   EndIf
EndIf
RETURN lSi

//------------------------------------//
METHOD DelFactu( oDlg,oLbx ) CLASS TFactura
   LOCAL dFecdev, cPerF := oApl:cPer, mCant, nTipo, nR
If !oApl:oFac:lOK
   If EMPTY( ::aV[1,01] )
      oApl:oFac:INDICADOR := "A"
      ::Guardar( oDlg,oLbx )
   EndIf
ElseIf oApl:oFac:INDICADOR == "A"
   If MsgNoYes( "Está Factura","ACTIVA" )
      oApl:oFac:INDICADOR := If( oApl:oFac:EFECTIVO, "C", "P" )
      oApl:oFac:Update(.f.,1)
      If !oApl:oFac:EFECTIVO
         oApl:lFam := SaldoFac( ::aM[2] )
         GrabaSal( ::aM[2],1,-oApl:oFam:ABONOS )
      EndIf
      If oApl:oFac:FECHOY >= CTOD("01.01.2008")
         cPerF := "empresa = " + LTRIM(STR(oApl:nEmpresa))+;
             " AND ano_mes = " + xValToChar(oApl:cPer )   +;
             " AND fuente  = 3"                           +;
             " AND control = " + LTRIM(STR(oApl:oFac:CONTROL))
         MSQuery( oApl:oMySql:hConnect,"UPDATE cgemovc SET estado = 1 WHERE " + cPerF )
      EndIf
   EndIf
Else
   If Login( "Desea Anular esta Factura" )
      dFecdev   := ::FechaDev( "Fecha Anulación" )
      oApl:cPer := NtChr( dFecdev,"1" )
      nTipo     := If( oApl:cPer > cPerF, 7, 2 )
      If oApl:oFac:FECHOY >= CTOD("01.01.2008")
         cPerF := "empresa = " + LTRIM(STR(oApl:nEmpresa))+;
             " AND ano_mes = " + xValToChar( cPerF )      +;
             " AND control = " + LTRIM(STR(oApl:oFac:CONTROL))
         ::oMvc:Seek( cPerF,"CM" )
         ::oMvd:dbEval( {|o| o:EMPRESA := -9, Acumular( ::oMvc:ESTADO,o,3,3,.f.,.f. ) },cPerF )
         Guardar( "UPDATE cgemovc SET estado = 2 WHERE " + cPerF,"cgemovc" )
      EndIf
      oApl:oFac:INDICADOR := "A" ; oApl:oFac:FECHAENT := dFecdev
      oApl:oFac:Update(.f.,1)
      If oApl:oEmp:PAGOS .AND. !oApl:oFac:EFECTIVO
         PagosFac( "A" )
      EndIf
      If !oApl:oFac:EFECTIVO
         oApl:lFam := SaldoFac( ::aM[2] )
         GrabaSal( ::aM[2],1,oApl:nSaldo )
         cPerF := If( oApl:lEnLinea, "DELETE FROM cadpagos"    ,;
                       "UPDATE cadpagos SET indicador = 'A'" ) +;
                " WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
                  " AND numfac = "  + LTRIM(STR(::aM[2]))      +;
                  " AND tipo  = '" + oApl:Tipo + "'"
         MSQuery( oApl:oMySql:hConnect,cPerF )
      EndIf
      FOR nR := 1 TO LEN( ::aV )
         If ::aV[nR,11] > 0 .AND. LEFT( ::aV[nR,10],1 ) == " "
            ::oVen:Seek( {"row_id",::aV[nR,11]} )
            mCant := ::aV[nR,4] * If( nTipo = 2, -1, 1 )
            Actualiz( ::aV[nR,1],mCant,dFecdev,nTipo,,::aV[nR,5] )
            If oApl:lEnLinea .AND. nTipo == 2
               ::oVen:Delete(.f.,1)
            Else
               ::oVen:INDICADOR := If( nTipo == 2, "A", "D" )
               ::oVen:FECDEV    := dFecdev ; ::oVen:Update(.f.,1)
            EndIf
         EndIf
      NEXT nR
      ::Iniciar( oDlg,oLbx )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD FechaDev( cMsg,dFec ) CLASS TFactura
If cMsg == "RETEN"
   If (oApl:oNit:CODIGO > 800000000  .AND.;
       oApl:oNit:CODIGO < 999999999) .AND. oApl:Tipo == "C"
      dFec := .t.
   Else
      dFec := .f.
   EndIf
Else
      dFec := oApl:dFec
   WHILE !oApl:lEnLinea
      dFec := MsgDate( dFec,cMsg )
      If dFec >= oApl:oFac:FECHOY
         If MsgYesNo( DTOC(dFec)+" Es Correcta Fecha",cMsg )
            EXIT
         EndIf
      EndIf
   EndDo
EndIf
RETURN dFec

//------------------------------------//
METHOD Fechas( lOK,nMsg ) CLASS TFactura
   LOCAL aFec, nR, lSI := .t.
If lOK
   aFec := { oApl:oFac:XColumn( 5 ),oApl:oFac:FECHOY,oApl:cPer,::lCierre,.t.,;
             "empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
        " AND ano_mes = " + xValToChar(oApl:cPer )    +;
        " AND control = " + LTRIM(STR(oApl:oFac:CONTROL)) }
   If (aFec[5] := ::Fechas( .f.,1 ))
      If (aFec[3] == LEFT( DTOS(aFec[2]),6 ))
         If oApl:oFac:FECHOY >= CTOD("01.01.2008")
            Guardar( "UPDATE cgemovc SET fecha = " + xValToChar(aFec[2]) +;
                     " WHERE " + aFec[6],"cgemovc" )
         EndIf
         Guardar( oApl:oFac,.f.,.f. )
      ElseIf MsgYesNo( "QUIERE HACER EL CAMBIO","VA A CAMBIAR DE MES" )
         FOR nR := 1 TO LEN( ::aV )
            If ::aV[nR,11] > 0
               ::oVen:Seek( {"row_id",::aV[nR,11]} )
               Actualiz( ::aV[nR,1],-::aV[nR,4],aFec[1],2,,::aV[nR,5] )
               Actualiz( ::aV[nR,1], ::aV[nR,4],aFec[2],2,,::aV[nR,5] )
            EndIf
         NEXT nR
         If oApl:oFac:CONTROL  > 0 .AND. oApl:oFac:FECHOY >= CTOD("01.01.2008")
            oApl:oFac:CONTROL := SgteCntrl( "Control",oApl:cPer,.t. )
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
         If !oApl:oFac:EFECTIVO
            If oApl:oFam:Seek( { "empresa",oApl:nEmpresa,"numfac",::aM[2],;
                                 "tipo",oApl:Tipo,"anomes",aFec[3] } )
               oApl:oFam:ANOMES := oApl:cPer
               Guardar( oApl:oFam,.f.,.f. )
            EndIf
         EndIf
         Guardar( oApl:oFac,.f.,.f. )
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
   Else
      ::aDF := PIva( oApl:cPer )
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
nAbono := oApl:oFac:TOTALFAC -;
          oApl:oFac:RETFTE - oApl:oFac:RETICA - oApl:oFac:RETIVA - oApl:oFac:RETCRE
nPago  := nR := 0
oApl:cPer := NtChr( oApl:oFac:FECHOY,"1" )
If !oApl:oFac:lOK
   nR := SgteNumero( cFactu,oApl:nEmpresa,.f. )
   If !MsgYesNo("Factura #"+STR(nR),"Graba esta")
      RETURN NIL
   EndIf
//   While .t.
      nR := SgteNumero( cFactu,oApl:nEmpresa,.t. )
//      If !BuscaDup( nR )
//         EXIT
//      EndIf
//   EndDo
   If !oApl:lEnLinea
      oApl:dFec := oApl:oFac:FECHOY
   ElseIf oApl:oFac:FECHOY < oApl:oEmp:FEC_HOY
      oApl:oFac:FECHOY   := oApl:oEmp:FEC_HOY
      oApl:oFac:FECHAENT := oApl:oEmp:FEC_HOY + 3
      oApl:cPer:= NtChr( oApl:oFac:FECHOY,"1" )
   EndIf
   oApl:oFac:EMPRESA := oApl:nEmpresa
   oApl:oFac:TIPO    := oApl:Tipo
   oApl:oFac:NUMFAC  := nR
   oApl:oFac:Append( .t. )
   oApl:nSaldo := nAbono
   ::nSigFac   := oApl:oFac:NUMFAC + 1
   oApl:oFac:PAGINAS := ::Paginas( cFactu,nR )
   cFactu  := "SI"
   lCambio := .t. ; oApl:lFam := .f.
Else
   If (lCambio := oApl:oFac:TOTALFAC # ::aM[6])
      If !MsgNoYes( TRANSFORM( oApl:oFac:TOTALFAC,"NUEVO 999,999,999" ) +;
         TRANSFORM( ::aM[6]," - VIEJO 999,999,999" ),"EL TOTAL ES DIFERENTE" )
         RETURN NIL
      EndIf
   EndIf
/*
   If !oApl:oFac:EFECTIVO .OR. oApl:Tipo $ oApl:cTF
      If (oApl:lFam := SaldoFac( ::aM[2] ))
         nPago := nAbono - (oApl:nSaldo + oApl:oFam:ABONOS - oApl:oFam:DEBITO)
         If nPago # 0
          //oApl:oFam:SALDO += oApl:nSaldo := nAbono - oApl:oFam:ABONOS + oApl:oFam:DEBITO
          //Guardar( oApl:oFam,.f.,.f. )
            cFactu := "UPDATE cadfactm SET saldo = saldo + " + LTRIM(STR(nPago))+;
                     " WHERE empresa = "  + LTRIM(STR(oApl:nEmpresa))           +;
                       " AND numfac  = "  + LTRIM(STR(oApl:oFac:NUMFAC))        +;
                       " AND tipo    = '" + oApl:Tipo                           +;
                      "' AND anomes >= '" + oApl:cPer + "'"
            MSQuery( oApl:oMySql:hConnect,cFactu )
         EndIf
         oApl:nSaldo += nPago
         nPago := 0
      Else
         oApl:nSaldo := nAbono
      EndIf
   EndIf
*/
EndIf
 ::Cambios( lCambio,nAbono,nPago )
/*
If lCambio .AND. oApl:Tipo $ oApl:cTF
   nAbono := oApl:nSaldo - nPago
   oApl:oFac:INDICADOR:= If( nAbono == 0, oApl:oFac:INDICADOR, "P" )
   oApl:oFac:FECHACAN := If( nAbono == 0, oApl:oFac:FECHOY, CTOD("") )
   oApl:oFac:FECHAENT := If( oApl:oFac:INDICADOR == "A", oApl:dFec, oApl:oFac:FECHAENT )
   GrabaSal( oApl:oFac:NUMFAC,1,nPago )
EndIf
*/
oApl:oFac:Update( .f.,1 )
FOR nR := 1 TO LEN( ::aV )
   If !EMPTY( ::aV[nR,01] ) .AND. LEFT( ::aV[nR,10],1 ) == " "
      nAbono := 0
      ::aV[nR,1] := UPPER( LTRIM(::aV[nR,1]) )
      ::aV[nR,6] := If( ::aV[nR,6] # 0, ::aV[nR,6],  ;
                 ROUND( (::aV[nR,7] / (::aV[nR,7]+::aV[nR,8]))*100,2 ) )
         ::oVen:Seek( {"row_id",::aV[nR,11]} )
      If (lCambio := (::aV[nR,11] == 0))
         ::oVen:EMPRESA  := oApl:nEmpresa
         ::oVen:NUMFAC   := oApl:oFac:NUMFAC
         ::oVen:TIPO     := oApl:Tipo
      Else
         nAbono    := ::oVen:CANTIDAD * -1
         If oApl:Tipo # "Z" .AND. (::oVen:CODIGO # ::aV[nR,1] .OR. ::oVen:UNIDADMED # ::aV[nR,5])
            Actualiz( ::oVen:CODIGO,nAbono,oApl:oFac:FECHOY,2,,::oVen:UNIDADMED )
            nAbono := 0
         EndIf
      EndIf
         ::oVen:CODIGO   := ::aV[nR,1] ; ::oVen:PPUBLI   := ::aV[nR,3]
         ::oVen:CANTIDAD := ::aV[nR,4] ; ::oVen:UNIDADMED:= ::aV[nR,5]
         ::oVen:DESPOR   := ::aV[nR,6] ; ::oVen:DESMON   := ::aV[nR,7]
         ::oVen:PRECIOVEN:= ::aV[nR,8] ; ::oVen:MONTOIVA := ::aV[nR,9]
         Guardar( ::oVen,lCambio,lCambio )
      If oApl:Tipo # "Z"
         nAbono += ::aV[nR,4]
         Actualiz( ::oVen:CODIGO,nAbono,oApl:oFac:FECHOY,2,,::oVen:UNIDADMED )
         If oApl:aInvme[2] # 0 .AND. oApl:aInvme[2] # ::oVen:PCOSTO
            ::oVen:PCOSTO := oApl:aInvme[2]
            ::oVen:Update( .f.,1 )
         EndIf
      EndIf
   EndIf
NEXT nR
If oApl:lEnLinea .AND. cFactu == "SI"
   CaoLiFac( {oApl:oFac:NUMFAC,::aDF[1],::cVende,"Factura"},::aV )
EndIf
oLbx:nCell := oLbx:nColPos := 1
oLbx:HiliteCell( 1 )
If oApl:oFac:FECHOY >= CTOD("01.01.2008") .AND. oApl:oFac:INDICADOR # "A" .AND.;
   oApl:Tipo $ oApl:oEmp:CONTAFAC
   ContaVta( ::oMvc,::oMvd,.f.,::aCta )
   If oApl:oEmp:PAGOS .AND. !oApl:oFac:EFECTIVO
      PagosFac( "" )
   EndIf
EndIf
 ::Iniciar( oDlg,oLbx )
RETURN NIL

//------------------------------------//
METHOD Listado( oDlg,oLbx ) CLASS TFactura
If oApl:oFac:lOK
  // If MsgNoYes( "Imprime esta Factura" )
      CaoLiFac( {oApl:oFac:NUMFAC,::aDF[1],::cVende,"Factura"},::aV )
      ::Iniciar( oDlg,oLbx )
  // EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Abonos() CLASS TFactura
   LOCAL oDlg, oLbp, oLbf, oGet := ARRAY(5), aEst, aFac, nEst
If ::aM[2] == 0 .OR. !oApl:oFac:lOK
   RETURN NIL
EndIf
aEst := { "","ANULADA","PENDIENTE","CANCELADA","N.Credito","999,999,999.99",;
          oApl:oFac:TOTALFAC - oApl:oFac:RETFTE - oApl:oFac:RETICA -        ;
          oApl:oFac:RETIVA, oApl:oFac:FECHACAN }
aFac := ArrayCol( ::aPag,1 )
nEst := AT( oApl:oFac:INDICADOR,"APCN" )
AEval( { "","","N.Credito","N.Debito","Anulada" }, {|cVal| AADD( aFac,cVal ) } )
oApl:oFam:Seek( {"empresa",oApl:nEmpresa,"numfac",::aM[2],"tipo",oApl:Tipo,;
                 "anomes >= ",NtChr( oApl:oFac:FECHOY,"1" )},"anomes",.f. )
oApl:cPer   := NtChr( DATE(),"1" )
oApl:nSaldo := oApl:oFam:SALDO
oApl:oPag:Seek( {"empresa",oApl:nEmpresa,"numfac",::aM[2],"tipo",oApl:Tipo},;
                 "fecpag" )
DEFINE DIALOG oDlg RESOURCE "PAGOSFAC"
   REDEFINE SAY VAR oApl:oFac:NUMFAC   ID  1 OF oDlg
   REDEFINE SAY VAR oApl:oFac:CLIENTE  ID  2 OF oDlg
   REDEFINE SAY VAR oApl:oFac:FECHOY   ID  4 OF oDlg
   REDEFINE SAY VAR oApl:oFac:FECHAENT ID  6 OF oDlg
   REDEFINE SAY VAR aEst[nEst+1]       ID  8 OF oDlg UPDATE COLOR nRGB( 255,0,0 )
   REDEFINE GET oGet[1] VAR oApl:oFac:FECHACAN ID  9 OF oDlg        ;
      WHEN Rango( nEst,2,3 )                                        ;
      VALID EVAL({|| If( oApl:oFac:FECHACAN # aEst[8]              ,;
                       ( oApl:oFac:INDICADOR :=                     ;
                        If( EMPTY( oApl:oFac:FECHACAN ), "P", "C" ),;
                        nEst := AT( oApl:oFac:INDICADOR, "APCN" )  ,;
                        oApl:oFac:Update(.f.,1), oDlg:Update() ), ),;
                        oGet[1]:oJump := oLbp, .t. } )
 //REDEFINE SAY VAR oApl:oFac:TOTALFAC ID 11 OF oDlg PICTURE aEst[6]
   REDEFINE SAY VAR aEst[7]            ID 11 OF oDlg PICTURE aEst[6]
   REDEFINE SAY VAR oApl:nSaldo        ID 13 OF oDlg PICTURE aEst[6] UPDATE

   REDEFINE LISTBOX oLbp FIELDS       ;
         DTOC( oApl:oPag:FECPAG )    ,;
          aFac[oApl:oPag:FORMAPAGO+1],;
               oApl:oPag:CODBANCO    ,;
    TRANSFORM( oApl:oPag:PAGADO,aEst[6]),;
    TRANSFORM( oApl:oPag:ABONO ,aEst[6]),;
          STR( oApl:oPag:DOCUMENTO ) ,;
               oApl:oPag:NUMCHEQUE    ;
      HEADERS "Fecha", "FormaPago", "Banco", "Total Pago", "Monto Pago",;
              "Comprobante", "Num.Cheque" ;
      ID 20 OF oDlg UPDATE
    oLbp:nClrBackHead  := oApl:nClrBackHead
    oLbp:nClrForeHead  := oApl:nClrForeHead
    oLbp:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbp:nClrBackFocus := oApl:nClrBackFocus
    oLbp:nClrForeFocus := oApl:nClrForeFocus
    oLbp:nHeaderHeight := 28
    oLbp:GoTop()
    oLbp:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbp:aColSizes  := {60,64,40,82,82,82,82}
    oLbp:aHjustify  := {2,2,2,2,2,2,2}
    oLbp:aJustify   := {1,0,2,1,1,1,0}
    oLbp:cToolTip := "[Ctrl] + [Supr] Borrar Pago"
/*
    oLbp:bKeyDown := {|nKey| If(nKey=VK_RETURN .AND. oApl:oPag:FORMAPAGO < 5 .AND.  ;
                                     (::aPrv[2] .OR. oApl:oPag:FECPAG == oApl:dFec),;
                                     (CaoPagos(.t.,.f.,::aPag), oLbf:Refresh()),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, ::Borrar(oLbp,oLbf), ) ) }
*/
    oLbp:lCellStyle := oLbp:ladjbrowse := .f.
    oLbp:ladjlastcol:= .t.
   MySetBrowse( oLbp, oApl:oPag )

   REDEFINE LISTBOX oLbf FIELDS  ;
               oApl:oFam:ANOMES ,;
    TRANSFORM( oApl:oFam:SALDO  ,aEst[6]),;
    TRANSFORM( oApl:oFam:ABONOS ,aEst[6]),;
    TRANSFORM( oApl:oFam:DEBITO ,aEst[6]) ;
      HEADERS "AñoMes", "Saldo", "Abonos", "Debitos" ;
      ID 22 OF oDlg UPDATE ;
      ON LEFT DBLCLICK ::Editar( .t.,oLbf )
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
   MySetBrowse( oLbf,oApl:oFam )
   REDEFINE BUTTON oGet[4] ID 27 OF oDlg
     //ACTION
   REDEFINE BUTTON oGet[5] ID 28 OF oDlg ACTION oDlg:End()
ACTIVATE DIALOG oDlg CENTER

RETURN NIL

//------------------------------------//
METHOD Borrar( oLbp,oLbf ) CLASS TFactura
   LOCAL aF, aRes, hRes, nL
If TRIM( oApl:cUser ) # "Martin"
   RETURN NIL
EndIf
aRes := "UPDATE cadfactd d, cadinvme m "+;
          "SET d.pcosto  = m.pcosto "   +;
        "WHERE d.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND d.numfac  = " + LTRIM(STR(::aM[2]))      +;
         " AND d.tipo    = " + xValToChar( oApl:Tipo )  +;
         " AND d.empresa = m.empresa"                   +;
         " AND d.codigo  = m.codigo"                    +;
         " AND d.pcosto <> m.pcosto"                    +;
         " AND m.anomes  = " + xValToChar(oApl:cPer )   +;
         " AND m.pcosto <> 0"
//       " AND m.anomes = EXTRACT(YEAR_MONTH FROM d.fecfac)""
If !MSQuery( oApl:oMySql:hConnect,aRes )
   oApl:oMySql:oError:Display( .f. )
Else
   hRes := MSStoreResult( oApl:oMySql:hConnect )
   nL   := MSAffectedRows( oApl:oMySql:hConnect )
   If nL > 0
      ContaVta( ::oMvc,::oMvd,.f.,::aCta )
      MsgStop( "Actualizado el P.Costo",STR(nL) )
   EndIf
   MSFreeResult( hRes )
EndIf
/* 1
aRes := "SELECT d.numfac, d.tipo, d.row_id, d.codigo, d.cantidad, "+;
               "d.unidadmed, d.pcosto, i.unidadmed "+;
        "FROM cadinven i, cadfactd d "    +;
        "WHERE d.codigo     = i.codigo"   +;
         " AND d.unidadmed <> i.unidadmed"+;
         " AND d.tipo      <> 'Z' ORDER BY d.numfac, d.tipo"
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   RETURN NIL
EndIf
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) },3 )
   oApl:oFac:Seek( { "empresa",oApl:nEmpresa,"numfac",aRes[1],"tipo",aRes[2]} )
   aF   := { aRes[1],aRes[2],aRes[3],NtChr( oApl:oFac:FECHOY,"1" ),.f. }
While nL > 0
   If oApl:oFac:INDICADOR # "A"
      SaldoInv( aRes[4],aF[4] )
      If oApl:aInvme[2] # 0 .AND. oApl:aInvme[2] # aRes[7]
         Guardar( "UPDATE cadfactd SET pcosto = " + LTRIM(STR(oApl:aInvme[2]))+;
                  " WHERE row_id = " + LTRIM(STR(aF[3])),"cadfactd" )
         aF[5] := .t.
      EndIf
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) },3 )
   EndIf
   If nL == 0 .OR. aF[1] # aRes[1]
      If oApl:oFac:INDICADOR # "A" .AND. aF[5]
         oApl:Tipo := aF[2]
         ContaVta( ::oMvc,::oMvd,.f.,::aCta )
      EndIf
      oApl:oFac:Seek( { "empresa",oApl:nEmpresa,"numfac",aRes[1],"tipo",aRes[2]} )
      aF   := { aRes[1],aRes[2],aRes[3],NtChr( oApl:oFac:FECHOY,"1" ),.f. }
   EndIf
EndDo
   MSFreeResult( hRes )
*/
/* 2
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
*/
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
   @ 58,30 BUTTON oGet[05] PROMPT "&Grabar"   SIZE 44,12 OF oDlg ACTION ;
      (If( EMPTY(oApl:oFam:ANOMES) .OR. oApl:oFam:ABONOS < 0           ,;
         ( MsgStop("Imposible grabar este Saldo"), oGet[1]:SetFocus() ),;
         ( aEd[1] := .t., oDlg:End() ))) PIXEL
   @ 58,80 BUTTON oGet[06] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL ;
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
METHOD Cambios( lCambio,nAbono,nPago ) CLASS TFactura
   LOCAL cQry
If ::aM[2] > 0
   cQry := "UPDATE cadfactm SET saldo = saldo + [PAG] "    +;
           "WHERE empresa = "  + LTRIM(STR(oApl:nEmpresa)) +;
            " AND numfac  = "  + LTRIM(STR(::aM[2]))       +;
            " AND tipo    = '" + oApl:Tipo                 +;
           "' AND anomes >= '" + oApl:cPer + "'"
   If !::aM[22] .AND. oApl:oFac:EFECTIVO
      //Reversar Saldo
      If oApl:oFac:INGRE_ID > 0
         PagosFac( "A" )
      EndIf
      oApl:lFam := SaldoFac( ::aM[2] )
      GrabaSal( ::aM[2],1,oApl:nSaldo )
      oApl:oFac:INDICADOR:= "C"
      oApl:oFac:FECHACAN := oApl:oFac:FECHOY
   EndIf
   If !oApl:oFac:EFECTIVO
      If (oApl:lFam := SaldoFac( ::aM[2] ))
         nPago := nAbono - (oApl:nSaldo + oApl:oFam:ABONOS - oApl:oFam:DEBITO)
         If nPago # 0
            MSQuery( oApl:oMySql:hConnect,STRTRAN( cQry,"[PAG]",LTRIM(STR(nPago)) ) )
         EndIf
         oApl:nSaldo += nPago
         nPago := 0
      Else
         lCambio     := If( ::aM[22], .t., lCambio )
         oApl:nSaldo := nAbono
      EndIf
   EndIf
EndIf
If lCambio .AND. !oApl:oFac:EFECTIVO
   nAbono := oApl:nSaldo - nPago
   oApl:oFac:INDICADOR:= If( nAbono == 0, oApl:oFac:INDICADOR, "P" )
   oApl:oFac:FECHACAN := If( nAbono == 0, oApl:oFac:FECHOY, CTOD("") )
   oApl:oFac:FECHAENT := If( oApl:oFac:INDICADOR == "A", oApl:dFec, oApl:oFac:FECHAENT )
   GrabaSal( oApl:oFac:NUMFAC,1,nPago )
EndIf

RETURN NIL

//------------------------------------//
METHOD ComboBrowse( cState,nRow,nCol,oWnd,nA ) CLASS TFactura
   LOCAL aUM, oDlg, oBrw, oFont, oRect, lOk := .f.
   DEFAULT nRow := 0, nCol := 0
aUM := UMedidas( ::aUM,::aV[nA,16],::aV[nA,15] )
   If VALTYPE( oWnd ) = "O"

      oRect := oWnd:GetRect()

      If VALTYPE( nRow ) = "N"
         nRow += oRect:nTop
         nCol += oRect:nLeft
      EndIf

      If ( nA := ( GetSysMetrics( 1 ) - ( nRow + 254 ) ) ) < 0
         nRow += nA
      EndIf

      If ( nA := ( GetSysMetrics( 0 ) - ( nCol + 158 ) ) ) < 0
         nCol += nA
      EndIf

   Else
      nRow := NIL
   EndIf

   DEFINE FONT oFont NAME "MS Sans Serif" SIZE 0, -10

   DEFINE DIALOG oDlg FROM nRow, nCol TO nRow + 197, nCol + 157 PIXEL ;
          STYLE nOr( WS_VISIBLE, WS_POPUP )

   @0,0 BROWSE oBrw OF oDlg CELLED SIZE 79, 99 PIXEL FONT oFont ;
        ON DBLCLICK ( lOk := .T., oDlg:End() ) ;
        COLORS CLR_WHITE, nRGB(128,0,255)

   oBrw:SetArray( aUM )     // Esto es necesario para trabajar con arrays
   oBrw:aDefault := { SPACE(5), SPACE(30) }

   ADD COLUMN TO BROWSE oBrw DATA ARRAY ELEMENT 2;
       TITLE "Código" ;
       SIZE 40 PIXELS ;
       COLORS CLR_WHITE, nRGB(128,0,255),,, CLR_WHITE, CLR_BLACK

   ADD COLUMN TO BROWSE oBrw DATA ARRAY ELEMENT 1;
       TITLE "Nombre"  ;
       SIZE 500 PIXELS ;
       COLORS CLR_WHITE, nRGB(128,0,255),,, CLR_WHITE, CLR_BLACK

   oBrw:bKeyDown := { | nKey | If( nKey == VK_RETURN .or. nKey == VK_ESCAPE, ;
                                oDlg:End(), Nil ), lOk := nKey != VK_ESCAPE }
   oBrw:lSeek       := .T.
   oBrw:lNoHScroll  := .T.
   oBrw:lNoResetPos := .T.
   oBrw:nLineStyle  := 0
   oBrw:SetColor( { 15 }, { CLR_BLACK } )

   ACTIVATE DIALOG oDlg ;
         ON PAINT ( If( VALTYPE( nRow ) != "N", WndCenter( oDlg:hWnd ), ;
                    oDlg:Move( nRow, nCol ) ) ) ;
         VALID ( oFont:End(), .T. )

RETURN If( lOk, aUM[oBrw:nAt,2], cState )

//------------------------------------//
METHOD Paginas( cFac,nFac,nTL ) CLASS TFactura
   LOCAL nPag, nL := If( oApl:oEmp:PORPC, 25, 39 )
   DEFAULT nTL := LEN( ::aV )
   nPag := INT( nTL/nL ) + If( nTL % nL > 0, 1, 0 )
If nPag > 1 .AND. !oApl:oEmp:PORPC
   nFac += (nPag -1)
   cFac := "UPDATE cadempre SET " + cFac +" = " + LTRIM( STR(nFac) )+;
           " WHERE empresa = " + LTRIM( STR(oApl:nEmpresa) )
   MSQuery( oApl:oMySql:hConnect,cFac )
EndIf
RETURN nPag

//------------------------------------//
METHOD Retencion( nSubTot ) CLASS TFactura
If oApl:oEmp:TREGIMEN > 1 .AND. oApl:Tipo $ oApl:oEmp:RETENFAC
   If nSubTot >= ::aDF[2] .OR. oApl:oNit:TOPERET
      If oApl:oNit:RETENEDOR
         oApl:oFac:RETFTE := ROUND( nSubTot * ::aDF[3],0 )
      EndIf
      If oApl:oNit:GRANCONTR
         oApl:oFac:RETICA := ROUND( nSubTot *;
                                If( oApl:oNit:PICA > 0, oApl:oNit:PICA/1000, ::aDF[4] ),0 )
         oApl:oFac:RETIVA := ROUND( ::aM[10]*;
                                If( oApl:oNit:PIVA > 0, oApl:oNit:PIVA/100 , ::aDF[5] ),0 )
      EndIf
   EndIf
   If oApl:oEmp:RETCREE .AND. ::aM[21]       .AND.;
      oApl:oFac:FECHOY >= CTOD("01.05.2013") .AND. oApl:oFac:FECHOY <= CTOD("31.08.2013")
      oApl:oFac:RETCRE := ROUND( nSubTot * If( oApl:oNit:PCREE > 0,;
                                 oApl:oNit:PCREE/100, ::aDF[9] ),0 )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
PROCEDURE CgeVenta()
   LOCAL oDlg, oGet := ARRAY(11), aOpc := { DATE(),DATE(),0,0,0,.f.,.f.,.f. }
   LOCAL cTipo := ALLTRIM(oApl:oEmp:TIPOFAC)
oDlg := Saca( @cTipo,"," )
DEFINE DIALOG oDlg TITLE "ASIENTO DE VENTAS";
   FROM 0, 0 TO 12,44 OF oApl:oWnd
   @ 02,00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 72,10
   @ 02,74 GET oGet[1] VAR aOpc[1] OF oDlg  SIZE 40,10 PIXEL
   @ 14,00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 72,10
   @ 14,74 GET oGet[2] VAR aOpc[2] OF oDlg ;
      VALID aOpc[2] >= aOpc[1] SIZE 40,10 PIXEL
   @ 26,00 SAY "Nro. COMPROBANTE"  OF oDlg RIGHT PIXEL SIZE 72,10
   @ 26,74 GET oGet[3] VAR aOpc[3] OF oDlg PICTURE "999999" SIZE 30,10 PIXEL;
     MESSAGE "Digite 0 si es un Nuevo Comprobante"
   @ 38,00 SAY "Tipo de Factura"   OF oDlg RIGHT PIXEL SIZE 72,10
   @ 38,74 GET oGet[4] VAR oApl:Tipo OF oDlg PICTURE "!" SIZE 10,10 PIXEL;
      VALID( If( oApl:Tipo $ cTipo, .t.                                 ,;
               ( MsgStop( "El Tipo es ["+cTipo+"]","<< OJO >>" ), .f. ) ) )
   @ 38,116 CHECKBOX oGet[5] VAR aOpc[6] PROMPT "BORRAR" OF oDlg;
       SIZE 60,12 PIXEL
   @ 50,00 SAY "Nro. FACTURA INICIAL"     OF oDlg RIGHT PIXEL SIZE 72,10
   @ 50,74 GET oGet[6] VAR aOpc[4] OF oDlg PICTURE "9999999999" ;
      VALID aOpc[4] >= 0       SIZE 40,10 PIXEL
   @ 62,00 SAY "Nro. FACTURA   FINAL"     OF oDlg RIGHT PIXEL SIZE 72,10
   @ 62,74 GET oGet[7] VAR aOpc[5] OF oDlg PICTURE "9999999999" ;
      VALID aOpc[5] >= aOpc[4] SIZE 40,10 PIXEL
   @ 50,116 CHECKBOX oGet[8] VAR aOpc[7] PROMPT "Cambiar Cuenta" OF oDlg;
       SIZE 60,12 PIXEL
   @ 62,116 CHECKBOX oGet[9] VAR aOpc[8] PROMPT "Contabilizar Ajustes" OF oDlg;
       SIZE 60,12 PIXEL
   @ 76, 50 BUTTON oGet[10] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[10]:Disable(), Asientos( aOpc ), oDlg:End() ) PIXEL
   @ 76,100 BUTTON oGet[11] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 82, 02 SAY "[JVMVENTA]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
STATIC PROCEDURE Asientos( aLS )
   LOCAL aCta, cQry, lFac, nL, oMvc, oMvd
aCta := Cuentas( 3,1 )
oMvc := oApl:Abrir( "cgemovc" ,"empresa, ano_mes, control",.t.,,1 )
oMvd := oApl:Abrir( "cgemovd" ,"empresa, ano_mes, control",.t.,,100 )
//If aLS[8] .AND. LEN( aCta ) >= 10
If aLS[8]
   aCta := Cuentas( 13,1 )
   If LEN( aCta ) == 0
      oMvc:Destroy()
      oMvd:Destroy()
      RETURN
   EndIf
   cQry := STRTRAN( LEFT( oApl:oEmp:NIT,AT("-",oApl:oEmp:NIT)-1 ),".","" )
   oApl:oNit:Seek( {"codigo",INT(VAL(cQry))} )
   //cQry := ACLONE( aCta )
   //aCta := {}
   //AEVAL( cQry, {| x | AADD( aCta, x[1] ) },10 )
   //AEVAL( cQry, {| x | AADD( aCta, LEFT(x[1],6) ) },10 )
   cQry := "SELECT numero FROM cadajust "           +;
           "WHERE fecha >= " + xValToChar( aLS[1] ) +;
            " AND fecha <= " + xValToChar( aLS[2] ) +;
           " GROUP BY numero ORDER BY numero"
   cQry := Buscar( cQry,"CM",,9 )
   FOR nL := 1 TO LEN( cQry )
      ContAjuste( oMvc,oMvd,cQry[nL],aCta )
   NEXT nL
ElseIf !aLS[8]
   lFac := If( aLS[1] < CTOD("01.01.2008"), .t., .f. )
   oApl:cPer := NtChr( aLS[1],"1" )
   If lFac
      If oMvc:Seek( {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,"fuente",3,;
                     "comprobant",aLS[3]} )
         oMvd:dbEval( {|o| o:EMPRESA := -9, Acumular( oMvc:ESTADO,o,3,3,.f.,.f. ) },;
                      {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,"control",oMvc:CONTROL} )
         oMvc:CONSECUTIV := 0 ; oMvc:ESTADO := 1
      Else
         oMvc:EMPRESA   := oApl:nEmpresa   ; oMvc:ANO_MES  := oApl:cPer
         oMvc:FECHA     := aLS[2]          ; oMvc:FUENTE   := 3
         oMvc:COMPROBANT:= aLS[3] := SgteCntrl( "Compro_prv",oApl:cPer,.t. )
         oMvc:CONCEPTO  := "MOVTO. DE VENTAS EN " + NtChr( aLS[1],"6" )
         oMvc:CODIGONIT := 1
         oMvc:CONTROL   := SgteCntrl( "Control",oApl:cPer,.t. )
         Guardar( oMvc,.t.,.t. )
      EndIf
   EndIf
   cQry := ""
   If aLS[4] > 0
      cQry := " AND numfac >= " + LTRIM( STR(aLS[4]) )+;
              " AND numfac <= " + LTRIM( STR(aLS[5]) )
   EndIf
   cQry := "empresa = " + LTRIM( STR(oApl:nEmpresa) )+ cQry +;
      " AND fechoy >= " + xValToChar( aLS[1] )       +;
      " AND fechoy <= " + xValToChar( aLS[2] )       +;
      " AND tipo    = " + xValToChar( oApl:Tipo )    +;
      " AND indicador <> 'A'"
   oApl:oFac:Seek( cQry,"CM" )
   aCta[7,1] := If( aLS[7], "42104001", "41359501" )

   While !oApl:oFac:Eof()
      If !lFac .OR. Rango( oApl:oFac:CONTROL,{ 0,aLS[3] } )
         oApl:oWnd:SetMsg( "Factura "+STR(oApl:oFac:NUMFAC) )
         If aLS[6]
            If oMvc:Seek( {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,;
                           "fuente",3,"control",oApl:oFac:CONTROL} )
               oMvd:dbEval( {|o| o:EMPRESA := -9, Acumular( oMvc:ESTADO,o,3,3,.f.,.f. ) },;
                            {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,"control",oMvc:CONTROL} )
               oMvc:CONSECUTIV := 0 ; oMvc:ESTADO := 2
               Guardar( oMvc,.f.,.f. )
            EndIf
         Else
            oApl:oNit:Seek( {"codigo_nit",oApl:oFac:CODIGO_NIT} )
            ContaVta( oMvc,oMvd,lFac,aCta )
            If lFac
               oApl:oFac:CONTROL := oMvc:COMPROBANT ; oApl:oFac:Update(.f.,1)
            EndIf
         EndIf
      EndIf
      oApl:oFac:Skip(1):Read()
      oApl:oFac:xLoad()
   EndDo
   If lFac
      MsgInfo( "Pulse cualquier Tecla para Continuar"+STR(oMvc:COMPROBANT) )
   EndIf
EndIf
oApl:cPer := NtChr( oApl:dFec,"1" )
oMvc:Destroy()
oMvd:Destroy()
RETURN

//------------------------------------//
PROCEDURE ContaVta( oMvc,oMvd,lFac,aCta )
   LOCAL aInf, cSql, nE, nI, nK, hRes
   LOCAL aVT := { { 16,0,0 } }
 AEVAL( aCta, {|x| AFILL( x,0,6,5 ) } )
//nK := If( oApl:Tipo $ oApl:cTF, 1, 2 )
nK := If( oApl:oFac:EFECTIVO, 2, 1 )
aCta[nK,6] := oApl:oFac:TOTALFAC -;
              oApl:oFac:RETFTE - oApl:oFac:RETICA - oApl:oFac:RETIVA - oApl:oFac:RETCRE
aCta[03,6] := oApl:oFac:RETFTE
aCta[04,6] := oApl:oFac:RETIVA
aCta[05,6] := oApl:oFac:RETICA
aCta[06,7] := oApl:oFac:TOTALIVA
aCta[10,6] := oApl:oFac:RETCRE
If oApl:oEmp:RETCREE .AND. oApl:oFac:FECHOY >= CTOD("01.09.2013")
   aCta[10,10] := aCta[11,10] := oApl:oFac:TOTALFAC - oApl:oFac:TOTALIVA
   aCta[10,06] := aCta[11,07] := ROUND( aCta[10,10] * .003,0 )
   aCta[10,09] := aCta[11,09] := 0.30
EndIf
cSql := "SELECT d.montoiva, d.precioven, d.cantidad, d.pcosto, "+;
               "d.unidadmed, i.unidadmed, i.codcon, i.impuesto "+;
        "FROM cadinven i, cadfactd d " +;
        "WHERE d.codigo  = i.codigo"   +;
         " AND d.empresa = " + LTRIM(STR(oApl:nEmpresa))   +;
         " AND d.numfac  = " + LTRIM(STR(oApl:oFac:NUMFAC))+;
         " AND d.tipo    = " + xValToChar(oApl:Tipo)
hRes := If( MSQuery( oApl:oMySql:hConnect,cSql ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nE   := MSNumRows( hRes )
nK   := LEN( aCta )
While nE > 0
   aInf := MyReadRow( hRes )
   AEVAL( aInf, { | xV,nP | aInf[nP] := MyClReadCol( hRes,nP ) } )
   If aInf[1] > 0
      If oApl:oEmp:PRINTIVA .AND. aInf[8] > 1
         If (nI := ASCAN( aVT,{ |aX| aX[1] == aInf[8] } )) == 0
            AADD( aVT,{ aInf[8],0,0 } )
            nI := LEN( aVT )
         EndIf
      Else
         nI := 1
      EndIf
      aVT[nI,2] += aInf[1]
      aVT[nI,3] += aInf[2]
      aCta[7,7] += aInf[2]   //   Gravadas
   Else
      aCta[8,7] += aInf[2]   //NO Gravadas
   EndIf
   If nK >= 12
      If aInf[5] # aInf[6]
         aInf[4] := AFormula( aInf[4],aInf[5],aInf[6],aInf[7] )
      EndIf
      aInf[4] := ROUND( aInf[3] * aInf[4],2 )
      aCta[12,6] += aInf[4]
      aCta[13,7] += aInf[4]
   EndIf
   nE --
EndDo
MSFreeResult( hRes )
If !lFac
   If oMvc:Seek( {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,;
                   "fuente",3,"control",oApl:oFac:CONTROL} )
      oMvd:dbEval( {|o| o:EMPRESA := -9, Acumular( oMvc:ESTADO,o,3,3,.f.,.f. ) },;
                   {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,"control",oMvc:CONTROL} )
      oMvc:CONSECUTIV := 0 ; oMvc:ESTADO := 1
      oMvc:CODIGONIT  := oApl:oFac:CODIGO_NIT
   Else
      oMvc:EMPRESA   := oApl:nEmpresa   ; oMvc:ANO_MES  := oApl:cPer
      oMvc:FECHA     := oApl:oFac:FECHOY; oMvc:FUENTE   := 3
      oMvc:COMPROBANT:= oApl:oFac:NUMFAC; oMvc:CONCEPTO := oApl:oFac:CLIENTE
      oMvc:CODIGONIT := oApl:oFac:CODIGO_NIT
      oMvc:CONTROL   := SgteCntrl( "control",oApl:cPer,.t. )
      oMvc:ESTADO    := 1
      cSql := "UPDATE cadfactc SET control = " + LTRIM(STR(oMvc:CONTROL)) +;
             " WHERE row_id = " + LTRIM(STR(oApl:oFac:ROW_ID))
      Guardar( oMvc,.t.,.t. )
      MSQuery( oApl:oMySql:hConnect,cSql )
   EndIf
EndIf
   aCta[6,09] := aVT[1,1]
   aCta[6,10] := aVT[1,3]
If LEN( aVT ) > 1
   aCta[6,07] := aVT[1,2]
   aInf := ACLONE( aCta )
   aCta := {}
   AEVAL( aInf, {| x | AADD( aCta, { x[1],"","","","",x[6],x[7],x[8],x[9],x[10] } ) },1,6 )
   FOR nE := 2 TO LEN( aVT )
      aInf[6,1] := LEFT( aInf[6,1],6 ) + STRZERO( aVT[nE,1],2 )
      CreaCta( aInf[6,1],"IVA GRAVADO " + STR(aVT[nE,1],2) )
      AADD( aCta, { aInf[6,1],"","","","",  0 ,aVT[nE,2],0,aVT[nE,1],aVT[nE,3] } )
   NEXT nE
   AEVAL( aInf, {| x | AADD( aCta, { x[1],"","","","",x[6],x[7],x[8],x[9],x[10] } ) },7 )
EndIf
FOR nE := 1 TO LEN( aCta )
   If aCta[nE,6] > 0 .OR. aCta[nE,7] > 0
      aInf := Buscar( { "empresa",oApl:nPuc,"cuenta",aCta[nE,1] },"cgeplan",;
                        "infa, infb, infc, infd",8 )
      FOR nK := 1 TO 4
         cSql := TRIM( aInf[nK] )
         do case
         Case cSql == "BASE"
            aCta[nE,nK+1] := LTRIM(STR(aCta[nE,10],10,0))
         Case cSql == "COD-VAR"
            aCta[nE,nK+1] := aCta[nE,1]
         Case cSql == "DOCUMENTO" .OR.;
              cSql == "FACTURA"
            aCta[nE,nK+1] := LTRIM(STR(oApl:oFac:NUMFAC)) + oApl:Tipo
         Case cSql == "FECHA"
            aCta[nE,nK+1] := DTOC(oMvc:FECHA)
         Case cSql == "NIT"
            If LEFT( aCta[nE,1],4 ) == "1435" .OR. LEFT( aCta[nE,1],4 ) == "6135"
               aCta[nE,nK+1] := aCta[12,1]
            Else
               aCta[nE,nK+1] := LTRIM(STR(oApl:oNit:CODIGO))
               aCta[nE,8]    := oApl:oFac:CODIGO_NIT
            EndIf
         EndCase
      NEXT nK
      oMvc:CONSECUTIV ++
      oMvd:Seek( "empresa = -9 LIMIT 1","CM" )
      oMvd:EMPRESA   := oApl:nEmpresa; oMvd:ANO_MES  := oApl:cPer
      oMvd:CONTROL   := oMvc:CONTROL ; oMvd:CUENTA   := aCta[nE,1]
      oMvd:INFA      := aCta[nE,2]   ; oMvd:INFB     := aCta[nE,3]
      oMvd:INFC      := aCta[nE,4]   ; oMvd:INFD     := aCta[nE,5]
      oMvd:VALOR_DEB := aCta[nE,6]   ; oMvd:VALOR_CRE:= aCta[nE,7]
      oMvd:CODIGO_NIT:= aCta[nE,8]   ; oMvd:PTAJE    := aCta[nE,9]
      Acumular( oMvc:ESTADO,oMvd,2,2,!oMvd:lOK,.f. )
   EndIf
NEXT nE
oMvc:Update(.f.,1)
RETURN