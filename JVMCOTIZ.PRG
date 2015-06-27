// Programa.: JVMCOTIZ.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Modulo para la Elaboracion de Cotizaciones
#include "Fivewin.ch"
#include "TSBrowse.ch"
#include "Btnget.ch"

MEMVAR oApl

#define CLR_PINK  nRGB( 128, 150, 150) //255, 128, 128
#define CLR_NBLUE nRGB( 128, 128, 192)

FUNCTION Cotizacion()
   LOCAL oDlg, oLbx, aColor[2], aRect, lNoBlink := .f.
   LOCAL cTit, nA, oBtn := ARRAY(8)
   LOCAL oAr, oF, oNi
If (aColor[ 1 ] := GetSysColor( COLOR_INACTIVECAPTION ) ) != ;
   GetSysColor( COLOR_ACTIVECAPTION )
   aColor[ 2 ] := GetSysColor( COLOR_INACTCAPTEXT )
   lNoBlink := .t.
   SBNoBlink()
EndIf
 oAr := TInv()     ; oAr:New()
 oF  := TCotizar() ;  oF:New()
 oNi := TNits()    ; oNi:New()
cTit := "Cotizaciones || "
oApl:oEmp:Seek( {"localiz",oApl:oEmp:TITULAR} )
nEmpresa( .t. )
oApl:Tipo := LEFT(oApl:oEmp:TIPOFAC,1)
oF:Iniciar()
oF:AdicArray()
SETKEY( VK_F4,{|| If( Empresa(), ( oDlg:SetText(cTit + oApl:cEmpresa),;
                      oF:Iniciar(), oDlg:Update() ), ), oF:oG[1]:SetFocus() } )
DEFINE DIALOG oDlg RESOURCE "COTIZACION" TITLE cTit + oApl:cEmpresa OF oApl:oWnd
   REDEFINE SAY           VAR oF:nSigFac  ID  1 OF oDlg UPDATE COLOR "B+/W"
   REDEFINE BTNGET oF:oG[01] VAR oF:aM[2] ID  3 OF oDlg               ;
      RESOURCE "BUSCAR"                                               ;
      ACTION EVAL({|| If(oF:Mostrar(), (oF:aM[2] := oF:oDb:NUMERO    ,;
                        oApl:nEmpresa := oF:oDb:EMPRESA              ,;
                        oF:oG[1]:Refresh(), oF:oG[1]:lValid(.f.)),)}) ;
      VALID( If( !oF:oDb:Seek( { "empresa",oApl:nEmpresa,"numero"    ,;
                                 oF:aM[2]} ) .AND. oF:aM[2] # 0      ,;
               ( MsgStop("Cotización NO EXISTE"), .f. )              ,;
               (oF:AdicArray(),  oLbx:aArray := oF:aV,  oDlg:Update(),;
                oF:Dscto( 0,oLbx ) ,;
                If( oF:oDb:lOK, (oF:oG[1]:oJump := oLbx), ), .t. )))
   REDEFINE GET oF:oG[02] VAR oF:oDb:FECHA  ID  5 OF oDlg UPDATE ;
      WHEN !oApl:lEnLinea ;
      VALID oF:CambiaFec()
   REDEFINE BTNGET oF:oG[03] VAR oF:aM[3]   ID  7 OF oDlg            ;
      RESOURCE "BUSCAR"                                              ;
      ACTION EVAL({|| If( oNi:Mostrar(), (oF:aM[3] := oNi:oDb:CODIGO,;
                          oF:oG[3]:Refresh() ), ) })                 ;
      VALID EVAL( {|| If( oNi:Buscar( oF:aM[3],,.t. )               ,;
                 (oF:oDb:CODIGO_NIT := oNi:oDb:CODIGO_NIT        ,;
                  oF:oDb:CLIENTE    := oF:aM[4] := oNi:oDb:NOMBRE,;
                  oDlg:Update(), .t. )                              ,;
              (If( MsgYesNo("Desea ingresarlo","Este Nit no Existe"),;
                  oNi:Editar( ,.t.,,oF:aM[3] ), ),.f.) ) } ) UPDATE
   REDEFINE SAY           VAR oF:aM[4]        ID  8 OF oDlg UPDATE
   REDEFINE GET oF:oG[04] VAR oF:oDb:CLIENTE  ID 11 OF oDlg UPDATE PICTURE "@!"
   REDEFINE GET oF:oG[05] VAR oF:oDb:FECHAENT ID 13 OF oDlg UPDATE
   REDEFINE COMBOBOX oF:oG[06] VAR oF:oDb:CLASE ITEMS {"Remisión","Cotización"};
      ID 15 OF oDlg UPDATE;
      VALID ( oDlg:GoNextCtrl( oF:oG[06]:hWnd ), .t. )
   REDEFINE GET oF:oG[07] VAR oF:oDb:ORDEN    ID 17 OF oDlg UPDATE PICTURE "@!"
   REDEFINE SAY VAR oF:aM[6]      ID 19 OF oDlg PICTURE "999,999,999" UPDATE
   REDEFINE SAY VAR oF:oDb:NUMFAC ID 21 OF oDlg UPDATE
   REDEFINE SAY VAR oF:aM[7]      ID 22 OF oDlg UPDATE COLOR nRGB( 255,0,0 )
   ACTIVAGET(oF:oG)

   REDEFINE BTNBMP oBtn[1] ID 30 OF oDlg RESOURCE "IMPRIMIR" ;
      ACTION oF:Listado( oDlg,oLbx )     MESSAGE "Imprime Cotización (F3)"
   REDEFINE BTNBMP oBtn[2] ID 31 OF oDlg RESOURCE "REINDEZAR";
      ACTION oLbx:KeyDown( VK_DELETE,0 ) ;
      MESSAGE "Borrar Código (F5)"
   REDEFINE BTNBMP oBtn[3] ID 32 OF oDlg RESOURCE "DELREC"   ;
      ACTION oF:DelFactu( oDlg,oLbx )    MESSAGE "Anular Cotización (F6)"
   REDEFINE BTNBMP oBtn[4] ID 33 OF oDlg RESOURCE "NEW"      ;
      ACTION oF:Iniciar( oDlg,oLbx )     MESSAGE "Nueva Cotización (F7)"
   REDEFINE BTNBMP oBtn[5] ID 34 OF oDlg RESOURCE "DEDISCO"  ;
      ACTION oF:Guardar( oDlg,oLbx )     MESSAGE "Grabar Cotización (F11)"
   REDEFINE BTNBMP oBtn[6] ID 35 OF oDlg RESOURCE "OK"       ;
      ACTION oF:Facturar( oDlg,oLbx )    MESSAGE "Pasar Cotización a Factura"
   REDEFINE BTNBMP oBtn[7] ID 36 OF oDlg RESOURCE "CALC"     ;
      ACTION WinExec("Calc")             MESSAGE "Calculadora"
   REDEFINE BTNBMP oBtn[8] ID 37 OF oDlg RESOURCE "SALIR"    ;
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
                            If(nKey=VK_F11, oBtn[5]:Click() , )))))) }
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
                       oF:aM[13] := If( nA > LEN(oF:aV), 0, oF:aV[nA,10] ) };
       FOOTER { || STR( oLbx:nLen,4 ) + " Items" };
       WHEN oF:EditArray( oLbx )
    oLbx:aColumns[01]:bPostEdit := { |uVar| oF:aV[nA,05] := oF:aM[05],;
       oF:aV[nA,01] := oF:aM[11], oF:aV[nA,02] := oF:aM[12],;
       oF:aV[nA,03] := oF:aM[13], oF:aV[nA,06] := oF:aM[15],;
       oF:aV[nA,08] := oF:aM[14], oF:aV[nA,09] := oF:aM[16],;
       oF:aV[nA,11] := oF:aM[17], oF:aV[nA,12] := oF:aM[18],;
       oF:aV[nA,13] := oF:aM[14], oF:aV[nA,14] := oF:aM[19],;
       oF:aV[nA,15] := oF:aM[20], oF:aV[nA,16] := oF:aM[23], oF:Dscto( 1,oLbx ) }
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
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 5;
       TITLE "Unidad"+CRLF+"Medida"              ;
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
                If( oGet:Value() != CHR(27)      ,;
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
       VALID { |uVar| If( uVar >= 0, .t., ;
              (MsgStop("Descuento tiene que ser Positivo","<<OJO>>"), .f.)) };
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
   // Asignando Valores por defaults para nueva Fila creada con Auto Append.
   oLbx:aDefault := { SPACE(12), SPACE(40), 0, 1, "UN", 0, 0, 0, 0, 0, .f., 1, 0, 1, "", ""  }

   oLbx:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbx:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color
ACTIVATE DIALOG oDlg CENTERED ;
   VALID !GetKeyState( VK_ESCAPE )
If( lNoBlink, SBNoBlink( aColor[1], aColor[2] ), Nil )
oApl:oEmp:Seek( {"empresa",oF:nOptica} )
oF:oDb:Destroy()
oF:oMvc:Destroy()
oF:oMvd:Destroy()
oF:oVen:Destroy()
SETKEY( VK_F4,{||Empresa()} )
nEmpresa( .f. )
RETURN NIL

//------------------------------------//
CLASS TCotizar FROM TFactura

 METHOD NEW() Constructor
 METHOD Iniciar( oDlg,oLbx )
 METHOD AdicArray()
 METHOD EditArray( oLbx )
 METHOD Dscto( nPos,oLbx,mGetVar )
 METHOD DelArray( oLbx )
 METHOD DelFactu( oDlg,oLbx )
 METHOD CambiaFec()
 METHOD Guardar( oDlg,oLbx )
 METHOD Especial( nR,lNew,lCam )
 METHOD Borrar( nR,nT )
 METHOD Listado( oDlg,oLbx )
 METHOD Mostrar( lAyuda,nOrd )
 METHOD Facturar( oDlg,oLbx )

ENDCLASS

//------------------------------------//
METHOD New() CLASS TCotizar
   LOCAL oTB := oApl:Abrir( "cadcotic","empresa, numero",,,50 )
 Super:New( oTB )
 ::oDb:xBlank()
RETURN NIL

//------------------------------------//
METHOD Iniciar( oDlg,oLbx ) CLASS TCotizar
   LOCAL cQry, hRes
If oDlg == NIL
   ::nOptica := oApl:nEmpresa
   ::nSigFac := 1
   cQry := "SELECT MAX(numero) FROM cadcotic WHERE empresa = " +LTRIM(STR(::nOptica))
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   If MSNumRows( hRes ) > 0
      cQry := MyReadRow( hRes )
      AEval( cQry, { | xV,nP | cQry[nP] := MyClReadCol( hRes,nP ) } )
      ::nSigFac += cQry[1]
   EndIf
   MSFreeResult( hRes )
ElseIf VALTYPE( oDlg ) == "O"
   AEVAL( ::aM, {|xV,nI| ::aM[nI] := {"",CTOD(""),.f.,0}[AT(VALTYPE(xV),"CDLN")] } )
   ::AdicArray() ; oLbx:aArray := ::aV
   ::oDb:xBlank()
   oDlg:Update() ; oLbx:Refresh()
   oLbx:nCell := oLbx:nColPos := 1
   oLbx:HiliteCell( 1 )
   ::oG[01]:SetFocus()
Else
   ::aM[13] := oApl:oInv:PPUBLI
EndIf
RETURN NIL

//------------------------------------//
METHOD AdicArray() CLASS TCotizar
   LOCAL cOpt := ""
If ::aM[2] == 0
   ::lNuevo:= .t.
   oApl:oNit:Seek( {"codigo",1} )
   oApl:nEmpresa   := ::nOptica
   ::oDb:lOK       := .f.
   ::oDb:FECHA     := oApl:dFec
   ::oDb:CODIGO_NIT:= oApl:oNit:CODIGO_NIT
   ::oDb:CLASE     := 1
   ::oDb:INDICADOR := "P"
Else
   oApl:oNit:Seek( {"codigo_nit",::oDb:CODIGO_NIT} )
   ::lNuevo := !oApl:lEnLinea
   cOpt := If( ::nOptica == ::oDb:EMPRESA, "",;
               ArrayValor( oApl:aOptic,STR(::oDb:EMPRESA,2) ) )
EndIf
oApl:cPer:= NtChr( ::oDb:FECHA,"1" )
 ::aDF := PIva( oApl:cPer )
 ::aV  := {}
 ::oVen:Seek( {"empresa",oApl:nEmpresa,"numero",::aM[2]} )
While !::oVen:Eof()
   ::Buscar( ::oVen:CODIGO )
   ::aM[14] := ROUND( (::oVen:PRECIOVEN + ::oVen:DESMON) / ::oVen:CANTIDAD,2 )
   AADD( ::aV,{ ::oVen:CODIGO   , oApl:oInv:DESCRIP , ::oVen:PPUBLI  ,;
                ::oVen:CANTIDAD , ::oVen:UNIDADMED  , ::oVen:DESPOR  ,;
                ::oVen:DESMON   , ::oVen:PRECIOVEN  , ::oVen:MONTOIVA,;
                ::oVen:ROW_ID   , ::aM[17], ::aM[18], ::aM[14]       ,;
                ::aM[19]        , ::aM[20], ::aM[23] } )
::oVen:Skip(1):Read()
   ::oVen:xLoad()
EndDo
If LEN( ::aV ) == 0
   AADD( ::aV,{ SPACE(12), SPACE(40), 0, 1, "UN", 0, 0, 0, 0, 0, .f., 1, 0, 1, "", "" } )
EndIf
 ::aM[3] := oApl:oNit:CODIGO ; ::aM[4] := oApl:oNit:NOMBRE
 ::aM[6] := ::oDb:TOTALFAC
 ::aM[7] := { "ANULADA","PENDIENTE","FACTURADA" }[AT( ::oDb:INDICADOR,"APF" )]
SysRefresh()
RETURN NIL

//------------------------------------//
METHOD EditArray( oLbx ) CLASS TCotizar
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
   ElseIf ::oDb:lOK .AND.;
         (::oDb:NUMFAC # 0 .OR. !::aPrv[2])
      MsgStop( "Este Registro no se Puede Modificar","Lo Siento" )
      lEdit := .f.
   EndIf
EndIf
RETURN lEdit

//------------------------------------//
METHOD Dscto( nPos,oLbx,mGetVar ) CLASS TCotizar
   LOCAL nSubTot, nA := oLbx:nAt
do Case
Case nPos == 5           // UnidadMed
   ::aM[13]    := AFormula( ::aV[nA,3],mGetVar,::aM[05],::aV[nA,14] )
   ::aV[nA,03] := ROUND( ::aM[13] / If( ::aV[nA,11], 1, ::aV[nA,12] ),0 )
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
   If oApl:oEmp:PRINTIVA .AND. ::aV[nA,11] .AND. mGetVar > 0
      //If MsgYesNo( "Precio con IVA incluido","I.V.A."+STR(::aV[nA,12],5,2) )
      mGetVar := ROUND( mGetVar / ::aV[nA,12],2 )
      //EndIf
   EndIf
   ::aV[nA,13] := mGetVar
EndCase
If Rango( nPos,1,8 )
   nSubTot    := ROUND( ::aV[nA,13] * ::aV[nA,04],0 )
   ::aV[nA,7] := If( nPos == 7, mGetVar, If( ::aV[nA,06] = 0, ::aV[nA,07],;
                     ROUND( nSubTot * ::aV[nA,6] / 100,0 ) ) )
   ::aV[nA,8] := nSubTot - ::aV[nA,7]
   If ::aV[nA,7] == 0 .AND. oApl:oEmp:PRINTIVA
      ::aV[nA,9] := ROUND( ::aV[nA,3] * ::aV[nA,04],0 ) - ::aV[nA,8]
   Else
      ::aV[nA,9] := ROUND( ::aV[nA,8] * ::aV[nA,12],0 ) - ::aV[nA,8]
   EndIf
EndIf
::aM[08] := ::aM[09] := ::aM[10] := 0
AEVAL( ::aV, { | e | ::aM[08] += e[ 7 ], ::aM[09] += e[ 8 ], ::aM[10] += e[ 9 ] } )
::aM[09] += ::aM[10]
If ::oDb:TOTALDES  # ::aM[08] .OR. ::oDb:TOTALIVA # ::aM[10] .OR. ;
   ::oDb:TOTALFAC  # ::aM[09] .OR. oLbx:lChanged
   ::oDb:TOTALDES := ::aM[08] ; ::oDb:TOTALIVA := ::aM[10]
   ::oDb:TOTALFAC := ::aM[09]
EndIf
oLbx:Refresh() ; oLbx:DrawFooters()
RETURN NIL

//------------------------------------//
METHOD DelArray( oLbx ) CLASS TCotizar
   LOCAL lSi := .f., nA := oLbx:nAt
do Case
Case ::aV[nA,10] == 0
   lSi := .t.
Case ::aM[1] .AND. ::oDb:lOK .AND. ::aPrv[3]
   If MsgNoYes( "Elimina este Código",::aV[nA,01] )
      MSQuery( oApl:oMySql:hConnect,;
               "DELETE FROM cadcotid WHERE row_id ="+;
               LTRIM(STR(::aV[nA,10])) )
      //::Borrar( nA )
      lSi := .t.
   EndIf
EndCase
RETURN lSi

//------------------------------------//
METHOD DelFactu( oDlg,oLbx ) CLASS TCotizar
   LOCAL cQry, nR
If !::oDb:lOK
   If EMPTY( ::aV[1,01] )
      ::oDb:INDICADOR := "A"
      ::Guardar( oDlg,oLbx )
   EndIf
ElseIf ::oDb:INDICADOR # "A"
   If oApl:lEnLinea .AND. ::oDb:NUMFAC > 0
      MsgStop( "Esta Cotización ya Tiene Factura","<<< OJO >>>" )
   ElseIf Login( "Desea Anular esta Cotización" )
      ::oDb:FECHAENT  := ::FechaDev( "Fecha Anulación" )
      ::oDb:INDICADOR := "A"
      ::oDb:Update(.f.,1)
      cQry := "DELETE FROM cadcotid WHERE empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
                                     " AND numero = " + LTRIM(STR(::aM[2]))
      MSQuery( oApl:oMySql:hConnect,cQry )
      //::Borrar( 1 )
      ::Iniciar( oDlg,oLbx )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD CambiaFec() CLASS TCotizar

If ::oDb:lOK
   If ::oDb:FECHA # ::oDb:XColumn( 3 )
      If ::oDb:NUMFAC == 0
         Guardar( ::oDb,.f.,.f. )
      Else
         MsgStop( "YA esta Facturada"+STR(::oDb:NUMFAC),"COTIZACION" )
         ::oDb:FECHA := ::oDb:XColumn( 3 )
      EndIf
   EndIf
EndIf
::aDF := PIva( ::oDb:FECHA )
RETURN .t.

//------------------------------------//
METHOD Guardar( oDlg,oLbx ) CLASS TCotizar
   LOCAL lCambio, nAbono := 0, nR
If EMPTY( ::aV[1,1] ) .AND. ::oDb:INDICADOR # "A"
   MsgInfo( "Cotización no Tiene ningun Items" )
   RETURN NIL
EndIf
If !::oDb:lOK
   If !MsgYesNo("Cotización #"+STR(::nSigFac),"Graba está")
      RETURN NIL
   EndIf
   If !oApl:lEnLinea
      oApl:dFec := ::oDb:FECHA
   ElseIf ::oDb:FECHA < oApl:oEmp:FEC_HOY
      ::oDb:FECHA    := oApl:oEmp:FEC_HOY
      ::oDb:FECHAENT := oApl:oEmp:FEC_HOY + 3
   EndIf
   ::oDb:EMPRESA := oApl:nEmpresa
   Guardar( ::oDb,.t.,.t. )
   ::nSigFac := ::oDb:NUMERO + 1
   lCambio   := .t.
Else
   If (lCambio := ::oDb:TOTALFAC # ::aM[6])
      If !MsgNoYes( TRANSFORM( ::oDb:TOTALFAC,"NUEVO 999,999,999" ) +;
         TRANSFORM( ::aM[6]," - VIEJO 999,999,999" ),"EL TOTAL ES DIFERENTE" )
         RETURN NIL
      EndIf
   EndIf
EndIf
Guardar( ::oDb,.f.,.f. )
FOR nR := 1 TO LEN( ::aV )
   If !EMPTY( ::aV[nR,01] )
      ::aV[nR,1] := UPPER( LTRIM(::aV[nR,1]) )
      ::aV[nR,6] := If( ::aV[nR,6] # 0, ::aV[nR,6],  ;
                 ROUND( (::aV[nR,7] / (::aV[nR,7]+::aV[nR,8]))*100,2 ) )
      If ::aV[nR,10] == 0
         ::oVen:xBlank()                ; ::oVen:EMPRESA  := oApl:nEmpresa
         ::oVen:NUMERO   := ::oDb:NUMERO; ::oVen:CODIGO   := ::aV[nR,1]
         ::oVen:CANTIDAD := ::aV[nR,4]  ; ::oVen:UNIDADMED:= ::aV[nR,5]
         ::oVen:DESPOR   := ::aV[nR,6]  ; ::oVen:DESMON   := ::aV[nR,7]
         ::oVen:PRECIOVEN:= ::aV[nR,8]  ; ::oVen:MONTOIVA := ::aV[nR,9]
         ::oVen:PPUBLI   := ::aV[nR,3]
         Guardar( ::oVen,.t.,.f. )
         ::Especial( nR,.t. )
      Else
         ::oVen:Seek( {"row_id",::aV[nR,10]} )
         lCambio := If( ::oVen:CODIGO # ::aV[nR,1] .OR. ::oVen:CANTIDAD # ::aV[nR,4], .t., .f. )
         ::oVen:CODIGO   := ::aV[nR,1]
         ::oVen:CANTIDAD := ::aV[nR,4]  ; ::oVen:UNIDADMED:= ::aV[nR,5]
         ::oVen:DESPOR   := ::aV[nR,6]  ; ::oVen:DESMON   := ::aV[nR,7]
         ::oVen:PRECIOVEN:= ::aV[nR,8]  ; ::oVen:MONTOIVA := ::aV[nR,9]
         ::oVen:PPUBLI   := ::aV[nR,3]
         Guardar( ::oVen,.f.,.f. )
         ::Especial( nR,.f.,lCambio )
      EndIf
   EndIf
NEXT nR
If ::oDb:NUMERO # ::aM[2] .AND. oApl:lEnLinea
   ::Listado( oDlg,oLbx )
Else
   ::Iniciar( oDlg,oLbx )
EndIf
RETURN NIL

//------------------------------------//
METHOD Especial( nR,lNew,lCam ) CLASS TCotizar
   LOCAL aE, aEsp, aSal, nE, nCan, nEsp, nSal
If ::oDb:CLASE == 1 .AND. ::aV[nR,16] == "M"
   oApl:cPer:= NtChr( ::oDb:FECHA,"1" )
   aSal := Especiales( ::aV[nR,01] )
   nSal := LEN( aSal )
   aE := { "INSERT INTO cadcotie VALUES ( null, "  + LTRIM(STR(::oVen:ROW_ID)) +;
           ", " + LTRIM(STR(oApl:nEmpresa)) + ", " + LTRIM(STR(::oVen:NUMERO)) + ", ","",0 }
   If lNew
      FOR nE := 1 TO nSal
         aSal[nE,2] *= ::aV[nR,4]
         aE[2] := xValToChar(aSal[nE,1])  + ", "  + LTRIM(STR(aSal[nE,2])) + ", " +;
                  xValToChar(aSal[nE,3])  + ", "  + LTRIM(STR(aSal[nE,4])) + ", " +;
                  LTRIM(STR(aSal[nE,5])) + " )"
         Guardar( aE[1] + aE[2],"cadcotie" )
         Actualiz( aSal[nE,1],aSal[nE,2],::oDb:FECHA,2,aSal[nE,4],aSal[nE,3] )
      NEXT nE
   Else
      aEsp := Buscar( { "cotid_id",::oVen:ROW_ID},"cadcotie",;
                        "row_id, codigo, cantidad, pcosto, unidadmed",9 )
      nEsp := LEN( aEsp )
      If lCam
         AEVAL( aEsp, {|a| Actualiz( a[2],-a[3],::oDb:FECHA,2,a[4],a[5] ), a[3] := 0 } )
      EndIf
      nCan := MIN( nEsp,nSal )
      FOR nE := 1 TO nCan
           aE[3]    := aSal[nE,2] * ::aV[nR,4] - aEsp[nE,3]
         aEsp[nE,3] := aSal[nE,2] * ::aV[nR,4]
         Actualiz( aSal[nE,1],aE[3],::oDb:FECHA,2,aSal[nE,4],aSal[nE,3] )
         aE[2] := "UPDATE cadcotie SET codigo = " + xValToChar(aSal[nE,1]) +;
                 ", cantidad = " + LTRIM(STR(aEsp[nE,3])) +;
                ", unidadmed = " + xValToChar(aSal[nE,3]) +;
                   ", pcosto = " + LTRIM(STR(aSal[nE,4])) +;
                   ", pventa = " + LTRIM(STR(aSal[nE,5])) +;
              " WHERE row_id = " + LTRIM(STR(aEsp[nE,1]))
         Guardar( aE[2],"cadcotie" )
      NEXT nE
      If nEsp > nSal
         FOR nE := nCan+1 TO nEsp
            Actualiz( aEsp[nE,2],aEsp[nE,3],::oDb:FECHA,2,aEsp[nE,4],aEsp[nE,5] )
            Guardar( "DELETE FROM cadcotie WHERE row_id = " + LTRIM(STR(aEsp[nE,1])),"cadcotie" )
         NEXT nE
      ElseIf nSal > nEsp
         FOR nE := nCan+1 TO nSal
            aSal[nE,2] *= ::aV[nR,4]
            aE[2] := xValToChar(aSal[nE,1])  + ", "  + LTRIM(STR(aSal[nE,2])) + ", " +;
                     xValToChar(aSal[nE,3])  + ", "  + LTRIM(STR(aSal[nE,4])) + ", " +;
                      LTRIM(STR(aSal[nE,5])) + " )"
            Guardar( aE[1] + aE[2],"cadcotie" )
            Actualiz( aSal[nE,1],aSal[nE,2],::oDb:FECHA,2,aSal[nE,4],aSal[nE,3] )
         NEXT nE
      EndIf
   EndIf
   //Calcular el Precio Costo para la Minuta
   aE[2] := "SELECT e.cantidad, e.pcosto, e.unidadmed, i.unidadmed, i.codcon "+;
            "FROM cadinven i, cadcotie e " +;
            "WHERE e.codigo   = i.codigo"  +;
             " AND e.cotid_id = " + LTRIM(STR(::oVen:ROW_ID))
   nSal := Especiales( aE[2],::aV[nR,4] )
   If nSal # 0 .AND. nSal # ::oVen:PCOSTO
      ::oVen:PCOSTO := nSal
      ::oVen:Update( .f.,1 )
   EndIf
EndIf
RETURN NIL

METHOD Borrar( nA,nT ) CLASS TCotizar
   LOCAL aEsp, nR
If ::oDb:CLASE == 1
   nT := If( nT == NIL, LEN( ::aV ), nA )
   FOR nR := nA TO nT
      If ::aV[nR,10] > 0 .AND. ::aV[nR,16] == "M"
         aEsp := Buscar( { "cotid_id",::aV[nR,10] },"cadcotie",;
                        "row_id, codigo, cantidad, pcosto, unidadmed",9 )
         AEVAL( aEsp, {|a| Actualiz( a[2],-a[3],::oDb:FECHA,2,a[4] ) ,;
                         Guardar( "DELETE FROM cadcotie WHERE row_id = "+;
                                  LTRIM(STR(a[1])),"cadcotie" ) } )
      EndIf
   NEXT nA
EndIf
RETURN NIL

//------------------------------------//
METHOD Listado( oDlg,oLbx ) CLASS TCotizar
If ::oDb:lOK
   ::cVende := {"REMISION","COTIZACION"}[::oDb:CLASE]
   CaoLiFac( {::oDb:NUMERO,::aDF[1],"",::cVende},::aV,::oDb )
   ::Iniciar( oDlg,oLbx )
EndIf
RETURN NIL

//------------------------------------//
METHOD Mostrar( lAyuda,nOrd ) CLASS TCotizar
   LOCAL oDlg, oM := Self, lReturn := .f.
   LOCAL bHacer := {|| lReturn := .t., oDlg:End() }
   DEFAULT lAyuda := .t. , nOrd := 3
nOrd := ::Ordenar( nOrd )

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE "Ayuda de Facturas"
   @ 1.5, 0 LISTBOX ::oLbx FIELDS  ;
               STR( ::oDb:NUMERO ),;
              DTOC( ::oDb:FECHA ) ,;
                    ::oDb:CLIENTE ,;
        ArrayValor( oApl:aOptic,STR(::oDb:Empresa,2) );
      HEADERS "Número"+CRLF+"Cotizacion","Fecha","Cliente", "Empresa" ;
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
METHOD Facturar( oDlg,oLbx ) CLASS TCotizar
   LOCAL cQry, nR
If ::oDb:NUMFAC > 0 .OR. ::oDb:INDICADOR == "A"
   RETURN NIL
EndIf
cQry := "Numfac"+oApl:Tipo
nR := SgteNumero( cQry,oApl:nEmpresa,.f. )
If !MsgYesNo("Factura #"+STR(nR),"Graba esta")
   RETURN NIL
EndIf
nR := SgteNumero( cQry,oApl:nEmpresa,.t. )
oApl:oFac:Seek( {"empresa",oApl:nEmpresa,"numfac",0,"tipo",oApl:Tipo} )
oApl:oFac:EMPRESA   := oApl:nEmpresa    ; oApl:oFac:NUMFAC    := nR
oApl:oFac:TIPO      := oApl:Tipo        ; oApl:oFac:FECHOY    := oApl:oEmp:FEC_HOY
oApl:oFac:CLIENTE   := ::oDb:CLIENTE    ; oApl:oFac:ORDEN     := ::oDb:ORDEN
oApl:oFac:CODIGO_NIT:= ::oDb:CODIGO_NIT ; oApl:oFac:FECHAENT  := ::oDb:FECHAENT
oApl:oFac:TOTALDES  := ::oDb:TOTALDES   ; oApl:oFac:TOTALIVA  := ::oDb:TOTALIVA
oApl:oFac:TOTALFAC  := ::oDb:TOTALFAC   ; oApl:oFac:INDICADOR := "P"
oApl:oFac:REMISION  := ::oDb:NUMERO     ; oApl:oFac:FECHAENT  := oApl:oFac:FECHOY + 30
oApl:oFac:PAGINAS   := ::Paginas( cQry,nR )

 ::aM[21] := ::FechaDev( "RETEN" )
 ::Retencion( (::oDb:TOTALFAC - ::oDb:TOTALIVA) )

//BuscaDup( oApl:oFac:NUMFAC,oApl:Tipo )
Guardar( oApl:oFac,.t.,.t. )
::oDb:INDICADOR := "F" ; ::oDb:NUMFAC := oApl:oFac:NUMFAC
Guardar( ::oDb,.f.,.f. )
If oApl:Tipo $ oApl:cTF
   oApl:cPer   := NtChr( oApl:oFac:FECHOY,"1" )
   oApl:lFam   := .f.
   oApl:nSaldo := oApl:oFac:TOTALFAC -;
                  oApl:oFac:RETFTE - oApl:oFac:RETICA - oApl:oFac:RETIVA - oApl:oFac:RETCRE
   GrabaSal( oApl:oFac:NUMFAC,1,0 )
EndIf
/*
  `row_id`    int(11) NOT NULL auto_increment,
  `empresa`   int(2) default NULL,
  `numfac`    int(10) default NULL,
  `tipo`      char(1) default NULL,
1 `codigo` varchar(10) default NULL,
4 `cantidad`  double(6,2) default NULL,
5 `unidadmed` char(2) default NULL,
8 `precioven` double(9,2) default NULL,
6 `despor`    double(4,2) default NULL,
7 `desmon`    double(8,2) default NULL,
9 `montoiva`  double(8,2) default NULL,
3 `ppubli`    double(8,2) default NULL,
  `pcosto`    double(8,2) default NULL,
  `indicador` char(1) default NULL,
  `fecdev`    date default NULL,
*/
::aM[5] := "INSERT INTO cadfactd (empresa, numfac, tipo, "+;
           "codigo, cantidad, unidadmed, precioven, "     +;
           "despor, desmon, montoiva, ppubli, pcosto) "   +;
           "VALUES ( "+ LTRIM(STR(oApl:nEmpresa)) + ", "  +;
                     LTRIM(STR(oApl:oFac:NUMFAC)) + ", '" +;
                               oApl:Tipo          + "', '"
FOR nR := 1 TO LEN( ::aV )
   If !EMPTY( ::aV[nR,1] )
      Actualiz( ::aV[nR,1],::aV[nR,4],oApl:oFac:FECHOY,2,,::aV[nR,5] )
      cQry :=      TRIM(::aV[nR,1])  + "', " + LTRIM(STR(::aV[nR,4])) +  ", '"+;
                   TRIM(::aV[nR,5])  + "', " + LTRIM(STR(::aV[nR,8])) +  ", " +;
              LTRIM(STR(::aV[nR,6])) +  ", " + LTRIM(STR(::aV[nR,7])) +  ", " +;
              LTRIM(STR(::aV[nR,9])) +  ", " + LTRIM(STR(::aV[nR,3])) +  ", " +;
              LTRIM(STR(oApl:aInvme[2]))     + " )"
      Guardar( ::aM[5]+cQry,"cadfactd" )
   EndIf
NEXT
 //CaoLiFac( {oApl:oFac:NUMFAC,::aDF[1],::cVende,"Factura"},::aV )
 ContaVta( ::oMvc,::oMvd,.f.,::aCta )
 ::Iniciar( oDlg,oLbx )
RETURN NIL