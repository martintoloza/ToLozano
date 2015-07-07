// Programa.: INOINART.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Mantenimiento de las Comparas al Inventario.
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

PROCEDURE InoinArt()
   LOCAL oDlg, oLbx, oGet := ARRAY(14), lSalir := .f.
   LOCAL aBarra, oC
oC  := TCompra() ;  oC:New()
oC:oNit:oDb:xBlank()
aBarra := { {|| oC:Editar( oLbx,.t. ) }, {|| oC:Editar( oLbx,.f. ) },;
            {|| oC:Graba( .t. ) }      , {|| oC:Borrar( oLbx ), oGet[14]:Refresh() },;
            {|| oC:ArmarLis()          ,   oC:aCab[1] := 0, oGet[1]:SetFocus() },;
            {|| If( oC:aCab[11],  oC:Graba(.f.), ), lSalir := .t., oDlg:End() } ,;
            {|| oC:Borrar( oLbx,oGet ) } }
DEFINE DIALOG oDlg RESOURCE "COMPRAS"
   REDEFINE BTNGET oGet[1] VAR oC:aCab[1] ID  1 OF oDlg RESOURCE "BUSCAR";
      VALID oC:Buscar( oLbx,oGet ) UPDATE ;
      ACTION EVAL({|| If( oC:Mostrar(), ( oC:aCab[1] := oC:oDb:INGRESO  ,;
                          oGet[1]:Refresh() ), ) })
   REDEFINE SAY VAR oC:aCab[4]         ID  3 OF oDlg UPDATE COLOR nRGB( 255,0,0 )
   REDEFINE GET oGet[2] VAR oC:aCab[2] ID  5 OF oDlg PICTURE "@!"  ;
      VALID EVAL( {|| If( oApl:oEmp:Seek( {"localiz",oC:aCab[2]} ),;
                        ( oApl:nEmpresa := oApl:oEmp:EMPRESA      ,;
                          oC:Facturas() , .t. )                   ,;
                        (MsgStop("Esta Empresa NO EXISTE"), .f.) ) } ) UPDATE
   REDEFINE SAY VAR oC:oArc:COMPROBANT ID  7 OF oDlg UPDATE COLOR nRGB( 0,128,192 )
   REDEFINE GET oGet[3] VAR oC:oArc:FECINGRE ID  9 OF oDlg ;
      VALID oC:Fechas( oC:oArc:lOK,1 ) ;
      WHEN  oC:aPrv[2] UPDATE
   REDEFINE BTNGET oGet[4] VAR oC:aCab[3] ID 11 OF oDlg RESOURCE "BUSCAR";
      VALID EVAL( {|| If( oC:oNit:Buscar( oC:aCab[3],,.t. )          ,;
                        ( oC:aCab[17] := oC:Fechas( .f.,2 )          ,;
                 oC:aCab[14] := oC:oNit:oDb:CODIGO_NIT, oDlg:Update(),;
             If( oC:oArc:lOK .AND. oC:oArc:CODIGO_NIT # oC:aCab[14]  ,;
               ( oC:oArc:CODIGO_NIT := oC:aCab[14]                   ,;
                 oC:oArc:Update( .f.,1 ), MsgInfo("HECHO EL CAMBIO") ,;
                 oC:aCab[11] := .t., oGet[4]:oJump := oLbx), ) ,.t. ),;
            (If( MsgYesNo( "Desea ingresarlo","Este Nit no Existe" ) ,;
               oC:oNit:Editar( ,.t.,,oC:aCab[3] ), ),.f.) ) } ) UPDATE;
      ACTION EVAL({|| If(oC:oNit:Mostrar(), (oC:aCab[3] := oC:oNit:oDb:CODIGO,;
                        oGet[4]:Refresh(), oGet[4]:lValid(.f.)),)})
   REDEFINE SAY VAR oC:oNit:oDb:NOMBRE ID 12 OF oDlg UPDATE COLOR nRGB( 128,0,255 )
   REDEFINE GET oGet[05] VAR oC:oArc:FACTURA  ID 14 OF oDlg ;
      VALID oC:Facturas( oC:oArc:lOK,oC:oArc:FACTURA,oC:aCab[13] ) UPDATE
   REDEFINE GET oGet[06] VAR oC:oArc:TOTALIVA ID 16 OF oDlg PICTURE "999,999,999.99";
      VALID oC:New( 10 ) UPDATE
   REDEFINE GET oGet[07] VAR oC:oArc:TOTALFAC ID 18 OF oDlg PICTURE "999,999,999.99";
      VALID oC:New( 12,oGet ) UPDATE
   REDEFINE GET oGet[08] VAR oC:oArc:TOTALDES ID 20 OF oDlg PICTURE "999,999,999.99";
      VALID oC:New(  8 ) UPDATE
   REDEFINE GET oGet[09] VAR oC:oArc:TOTALFLE ID 22 OF oDlg PICTURE "999,999,999.99";
      VALID oC:New(  9 ) UPDATE
   REDEFINE GET oGet[10] VAR oC:oArc:TOTALRET ID 24 OF oDlg PICTURE "999,999,999.99";
      WHEN !oApl:oNit:RETENEDOR UPDATE ;
      VALID oC:New( 11 )
   REDEFINE GET oGet[11] VAR oC:oArc:TOTALICA ID 26 OF oDlg PICTURE "999,999,999.99";
      WHEN !oApl:oNit:GRANCONTR UPDATE ;
      VALID oC:New( 15 )
   REDEFINE GET oGet[12] VAR oC:oArc:CIF      ID 28 OF oDlg PICTURE "999,999.99";
      VALID oC:New( 15 ) UPDATE
   REDEFINE GET oGet[13] VAR oC:oArc:FFV      ID 30 OF oDlg PICTURE "999,999.99";
      VALID oC:New( 15 ) UPDATE
   REDEFINE SAY oGet[14] VAR oC:oArc:SUBTOTAL ID 32 OF oDlg PICTURE "999,999,999.99";
      UPDATE
   REDEFINE LISTBOX oLbx FIELDS oC:oArd:CODIGO             ,;
                     LeerCodig( oC:oArd:CODIGO )           ,;
                     TRANSFORM( oC:oArd:CANTIDAD,   "999,999.99" ),;
                     TRANSFORM( oC:oArd:PCOSTO  ,"99,999,999.99" ),;
                     TRANSFORM( oC:oArd:PPUBLI  ,"99,999,999.99" ) ;
      HEADERS "Código"+CRLF+"Artículo", "Descripción", "Cantidad",;
              "Precio"+CRLF+"Costo", "Precio"+CRLF+"Público"      ;
      ID 34 OF oDlg UPDATE                ;
      ON DBLCLICK EVAL( aBarra[2] )
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:nHeaderHeight := 28
    oLbx:GoTop()
    oLbx:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:aColSizes := {84,260,60,86,86}
    oLbx:aHjustify := {2,2,2,2,2}
    oLbx:aJustify  := {0,0,1,1,1}
    oLbx:lCellStyle  := oLbx:ladjbrowse := .f.
    oLbx:ladjlastcol := .t.
//    oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::Buscax( nKey,oLbx ), oDlg:Update() }
    oLbx:bKeyDown := {|nKey| If(nKey == VK_ESCAPE, ( oC:aCab[1] := 0, oGet[1]:SetFocus() ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=82, oC:Facturas( ,oLbx ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(aBarra[1]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, EVAL(aBarra[2]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE             , EVAL(aBarra[4]),) )))) }
   MySetBrowse( oLbx,oC:oArd )
//   @ 8.7,1 SAY ": " + ::cBus OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT oNi:oFont
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT ;
  (oDlg:Move(80,1), DefineBar( oDlg,oLbx,aBarra,134,18 ),;
   oC:aCab[6] := oDlg);
   VALID lSalir
oC:oDb:Destroy()
oC:oArc:Destroy()
oC:oArd:Destroy()
oC:oMvc:Destroy()
oC:oMvd:Destroy()
oApl:oEmp:Seek( {"empresa",oC:aCab[5]} )
nEmpresa( .f. )

RETURN

//------------------------------------//
CLASS TCompra FROM TMov

 DATA aCab, aCta, aDF, aPrv, cBus, nMed, nSubtotal
 DATA oCA, oArc, oArd

 METHOD NEW( nFld,oGet ) Constructor
 METHOD Buscar( oLbx,oGet )
// METHOD Buscax( nKey,oLbx )
 METHOD Borrar( oLbx,oGet )
 METHOD Editar( oLbx,lNew )
 METHOD EditPVenta( oGet )
 METHOD Guardar( oLbx,lNew )
 METHOD Fechas( lOK,nMsg )
 METHOD Facturas( lNew,cFac,cFV )
 METHOD Mostrar()
 METHOD Graba( lG )
 METHOD ArmarLis()
ENDCLASS

//------------------------------------//
METHOD New( nFld,oGet ) CLASS TCompra
   LOCAL nB
If nFld # NIL
   If oGet # NIL .AND. oApl:oEmp:TREGIMEN > 1
         nB := ::oArc:TOTALFAC - ::oArc:TOTALIVA
      If !oApl:oNit:RETENEDOR
         If nB >= ::aDF[2]
            ::oArc:TOTALRET := ROUND( nB * ::aDF[3],0 )
            oGet[10]:Refresh()
         EndIf
         If ::oArc:FECINGRE >= CTOD("01.05.2013") .AND.;
            ::oArc:FECINGRE <= CTOD("31.08.2013") .AND. ::aCab[17]
            ::oArc:TOTALCRE := ROUND( nB * If( oApl:oNit:PCREE > 0,;
                                     oApl:oNit:PCREE/100, ::aDF[9] ),0 )
            oGet[12]:Refresh()
         EndIf
      EndIf
      If !oApl:oNit:GRANCONTR .AND. nB >= ::aDF[2]
            ::oArc:TOTALICA := ROUND( nB * ;
                                  If( oApl:oNit:PICA > 0, oApl:oNit:PICA/1000, ::aDF[4] ),0 )
          //::oArc:RETIVA   := ROUND( ::aM[10]* ::aDF[5],0 )
            oGet[11]:Refresh()
      EndIf
   EndIf
   If ::aCab[11]
      ::oArc:Update( .f.,1 )
      ::aCab[12] := .t.
   EndIf
Else
   oGet   := oApl:Abrir( "cadartiv","nombre, fecingre" )
   Super:New( ,oGet )
   oApl:oEmp:Seek( {"localiz",oApl:oEmp:TITULAR} )
   ::aCab := { 0,oApl:oEmp:TITULAR,0,oApl:oEmp:NUMINGRESO + 1,;
               oApl:oEmp:EMPRESA,"",0,0,0,"UN",.f.,.f.,"",0,.f.,0,.t. }
   ::aCab[4] := SgteNumero( "NUMINGRESO",oApl:nEmpresa,.f. )
   ::aCta := Cuentas( 4,1 )
   ::aPrv := Privileg( "COMPRAS" )
   ::cBus := ""
   ::oArc := oApl:Abrir( "cadartic","ingreso",.t.,,10 )
   ::oArd := oApl:Abrir( "cadartid","ingreso",,,100 )
   ::oCA  := TInv() ; ::oCA:New( ,.f. )
   ::aOrden  := { {"Nombre",5},{"Factura" ,4} }
   ::bEditar := ::bNew := ::bVer := {|| MsgStop( "Solo para Ayuda" ) }
   ::oArd:Seek( { "ingreso",0 } )
   ::oFte:oDb:Seek( {"fuente",4} )
EndIf
RETURN .t.

//------------------------------------//
METHOD Buscar( oLbx,oGet ) CLASS TCompra
   LOCAL lSi := .f.
If VALTYPE( oGet ) == "L"
   If (lSi := oApl:oInv:Seek( {"codigo",::oArd:CODIGO} ))
      If oGet
         ::nMed := ArrayValor( ::oCA:aMed,oApl:oInv:UNIDADMED,,.t. )
         ::oArd:CANTIDAD := 1
         ::oArd:PCOSTO   := oApl:oInv:PCOSTO
         ::oArd:PPUBLI   := oApl:oInv:PPUBLI
      EndIf
      ::aCab[16] := If( oApl:oEmp:TREGIMEN == 1 .OR. !oApl:oInv:INDIVA, 0,;
                    If( oApl:oInv:IMPUESTO == 0, ::aDF[1],;
                        ROUND(oApl:oInv:IMPUESTO/100,2) )) + 1
      oLbx:Update()
   Else
      MsgStop( "Este Código NO EXISTE !!!" )
   EndIf
ElseIf Rango( ::aCab[1],0,::aCab[4] )
   If ::aCab[11]
      ::Graba( .f. )
   EndIf
   If !::oArc:Seek( {"ingreso",::aCab[1]} ) .AND. ::aCab[1] > 0
      MsgStop( "Este Ingreso NO EXISTE !!" )
   Else
      If ::oArc:lOK .AND. ::aCab[1] > 0
         oApl:oNit:Seek( {"codigo_nit",::oArc:CODIGO_NIT} )
         ::aCab[02] := ArrayValor( oApl:aOptic,STR(::oArc:EMPRESA,2) )
         ::aCab[03] := oApl:oNit:CODIGO
         ::aCab[14] := ::oArc:CODIGO_NIT
         ::aCab[17] := ::Fechas( .f.,2 )
         oApl:nEmpresa := ::oArc:EMPRESA
         oGet[1]:oJump := oLbx
         ::nSubtotal:= Buscar( {"ingreso",::aCab[1]},"cadartid","SUM(cantidad * pcosto)" )
         If ::oArc:SUBTOTAL  # 0 .AND. ::nSubtotal == 0
            ::oArc:SUBTOTAL := ::oArc:SECUENCIA := 0
         EndIf
      Else
         ::aCab[02] := oApl:oEmp:TITULAR
         ::oArc:lOK := .f.
         ::oArc:FECINGRE := DATE()
         ::nSubtotal:= 0
      EndIf
      ::oArd:Seek( {"ingreso",::aCab[1]} )
      If ::oArd:lOK .AND. ::oArd:INGRESO == 0
         Guardar( "UPDATE cadartid SET ingreso = -99 WHERE ingreso = 0","cadartid" )
         ::oArd:Seek( {"ingreso",::aCab[1]} )
      EndIf
      ::aCab[06]:Update()
      ::aCab[11] := ::oArc:lOK
      ::aCab[12] := !(::oArc:COMPROBANT != 0)
      ::aCab[13] := ::oArc:FACTURA
      ::Fechas( .f.,0 )
      ::oMvc:Seek( {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,"fuente",4,;
                    "comprobant",::oArc:COMPROBANT} )
      oLbx:Refresh()
      lSi := .t.
   EndIf
EndIf
RETURN lSi
/*
METHOD Buscax( nKey,oLbx ) CLASS TCompra
   LOCAL cQry
If nKey # VK_RETURN
   ::cBus := STRTRAN(::cBus,"%","")
   do Case
      Case nKey == VK_BACK
         ::cBus := LEFT( ::cBus,LEN( ALLTRIM( ::cBus ) )-1 ) + "%"
      Case nKey == VK_ESCAPE
         ::cBus := "%"
      Case nKey >= 32
         ::cBus += UPPER( CHR( nKey ) )+"%"
   EndCase
   If LEN( ::cBus ) >= 4
      cQry := "SELECT d.row_id FROM cadartid d, cadinven i "+;
              "WHERE d.ingreso = " + LTRIM(STR(::aCab[1]))  +;
               " AND i.codigo  = d.codigo"                  +;
               " AND i.descrip LIKE '" + ::cBus + "%'"
      nKey := Buscar( cQry,"CM",,8,,4 )
      If nKey > 0
         oLbx:GoTop(), oLbx:Refresh()
      EndIf
   EndIf
EndIf

RETURN ::cBus
*/
//------------------------------------//
METHOD Borrar( oLbx,oGet ) CLASS TCompra
   LOCAL aBor
If ::aPrv[3] .AND. ::oArc:SECUENCIA > 0
   If oGet == NIL
      If MsgNoYes( "Este Código "+::oArd:CODIGO,"Elimina" )
         aBor := { ::oArd:CODIGO,-::oArd:CANTIDAD,::oArd:PCOSTO,::oArd:UNIDADMED,.f. }
         If (aBor[5] := ::oArd:Delete( .t.,1 ))
            PListbox( oLbx,::oArd )
         EndIf
         If aBor[5]
            Actualiz( aBor[1],aBor[2],::oArc:FECINGRE,1,aBor[3],aBor[4] )
            ::oArc:SUBTOTAL += (aBor[2] * aBor[3])
            Guardar( ::oArc,.f.,.f. )
         EndIf
      EndIf
   Else
      If Login( "Desea Anular este Ingreso" )
         ::oMvc:Seek( {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,"fuente",4,;
                       "comprobant",::oArc:COMPROBANT} )
         aBor := "empresa = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND ano_mes = " + xValToChar(oApl:cPer )   +;
            " AND control = " + LTRIM(STR(::oMvc:CONTROL))
         ::oMvd:dbEval( {|o| ::Avanza( ,o:CUENTA ), o:EMPRESA := -4               ,;
                             ::GrabaPago( o:CUENTA,::aTL[4],-::aTL[5],::aTL[6],1 ),;
                             Acumular( ::oMvc:ESTADO,o,3,3,.f.,.f. ) },aBor )
         Guardar( "UPDATE cgemovc SET estado = 2 WHERE " + aBor,"cgemovc" )
         ::oArd:dbEval( {|o| Actualiz( o:CODIGO,-o:CANTIDAD,::oArc:FECINGRE,1,o:PCOSTO,o:UNIDADMED ),;
                             o:Delete( .f.,1 ) } )
         ::aCab[11] := .f.
         ::oArc:TOTALDES := ::oArc:TOTALIVA := ::oArc:TOTALFLE  := 0
         ::oArc:TOTALRET := ::oArc:TOTALICA := ::oArc:TOTALCRE  := 0
         ::oArc:TOTALFAC := ::oArc:SUBTOTAL := ::oArc:SECUENCIA := ::nSubtotal := 0
         Guardar( ::oArc,.f.,.f. )
         oGet[1]:SetFocus()
      EndIf
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Editar( oLbx,lNew ) CLASS TCompra
   LOCAL oDlg, cTit := "Modificando Ingreso"
   LOCAL bGrabar, oGet := ARRAY(14), oE := Self
lNew := If( ::oArc:SECUENCIA == 0, .t., lNew )
If lNew
   cTit    := "Nuevo Ingreso"
   bGrabar := {|| ::Guardar( oLbx,lNew )        ,;
                  ::oArd:xBlanK()               ,;
                  oDlg:Update(), oDlg:SetFocus() }
   oLbx:GoBottom() ; ::oArd:xBlank()
Else
   If !::aPrv[2]
      MsgStop( "Este Registro no se Puede Modificar","Lo Siento" )
      RETURN NIL
   EndIf
   bGrabar := {|| ::Guardar( oLbx,lNew ), oLbx:Refresh(), oDlg:End() }
   ::aCab[07]:= ::oArd:CODIGO
   ::aCab[08]:= ::oArd:CANTIDAD
   ::aCab[09]:= ::oArd:PCOSTO
   ::aCab[10]:= ::oArd:UNIDADMED
EndIf
oApl:oInv:Seek( {"codigo",::oArd:CODIGO} )
   ::nMed := ArrayValor( ::oCA:aMed,::oArd:UNIDADMED,,.t. )
   ::aCab[16] := If( oApl:oEmp:TREGIMEN == 1 .OR. !oApl:oInv:INDIVA, 0,;
                 If( oApl:oInv:IMPUESTO == 0, ::aDF[1],;
                     ROUND(oApl:oInv:IMPUESTO/100,2) )) + 1
DEFINE DIALOG oDlg TITLE cTit FROM 0, 0 TO 16,50
   @ 02,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 66,10
   @ 02,70 BTNGET oGet[1] VAR oE:oArd:CODIGO OF oDlg PICTURE "@!";
      VALID oE:Buscar( oDlg,lNew )        ;
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR" ;
      ACTION EVAL({|| If(oE:oCA:Mostrar(), (oE:oArd:CODIGO := oE:oCA:oDb:CODIGO,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
   @ 14,50 SAY    oGet[2] VAR oApl:oInv:DESCRIP OF oDlg PIXEL SIZE 120,10;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 26,130 SAY oGet[3] VAR oApl:oInv:PUTIL OF oDlg PICTURE "999.99%U";
      PIXEL SIZE 30,10 UPDATE
   @ 26,00 SAY "Cantidad" OF oDlg RIGHT PIXEL SIZE 66,10
   @ 26,70 GET oGet[4] VAR ::oArd:CANTIDAD OF oDlg PICTURE "999,999.99";
      VALID {|| If( ::oArd:CANTIDAD >  0, .t.                       ,;
          (MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>"), .f.)) };
      SIZE 40,10 PIXEL UPDATE
   @ 38,00 SAY "% Descuento"   OF oDlg RIGHT PIXEL SIZE 66,10
   @ 38,70 GET oGet[5] VAR ::oArd:DESPOR   OF oDlg PICTURE "999.99";
      VALID Rango( ::oArd:DESPOR,0,100 )   SIZE 24,10 PIXEL UPDATE
   @ 38,110 CHECKBOX oGet[6] VAR ::oArd:INDIVA PROMPT "Tiene I.V.A." OF oDlg ;
      SIZE 50,10 PIXEL UPDATE ;
      WHEN oApl:oEmp:TREGIMEN == 1
   @  50,00 SAY "Costo USD" OF oDlg RIGHT PIXEL SIZE 66,10
   @  50,70 GET oGet[7] VAR ::oArd:USD    OF oDlg PICTURE "99,999.9999";
      VALID (::oArd:PCOSTO := ROUND( ::oArc:CIF * ::oArd:USD,2 )   ,;
             ::oArd:PPUBLI := ROUND( ::oArc:FFV * ::oArd:PCOSTO,0 ),;
             ::oArd:PPUBLI := Redondear( ::oArd:PPUBLI,500,1000 )  ,;
             oGet[08]:Refresh(), oGet[10]:Refresh()                ,;
             oGet[07]:oJump := oGet[10], .t. )                      ;
      WHEN ::oArc:CIF > 0  SIZE 30,10 PIXEL UPDATE
   @ 62,00 SAY "Precio Costo"   OF oDlg RIGHT PIXEL SIZE 66,10
   @ 62,70 GET oGet[8] VAR ::oArd:PCOSTO   OF oDlg PICTURE "999,999,999.99";
      VALID ::EditPVenta( oGet )           SIZE 40,10 PIXEL UPDATE
   @ 62,130 SAY oGet[9] VAR ::aCab[16] OF oDlg PIXEL SIZE 30,10
   @ 74,00 SAY "Precio Público" OF oDlg RIGHT PIXEL SIZE 66,10
   @ 74,70 GET oGet[10] VAR ::oArd:PPUBLI  OF oDlg PICTURE "999,999,999";
      SIZE 40,10 PIXEL UPDATE ON CHANGE ( oE:aCab[15] := .t. )
   @ 74,130 SAY oGet[11] VAR oApl:oInv:PPUBLI OF oDlg PICTURE "999,999,999";
      PIXEL SIZE 40,10 UPDATE
   @ 86,00 SAY "Unidad Medida" OF oDlg RIGHT PIXEL SIZE 66,10
   @ 86,70 COMBOBOX oGet[12] VAR ::nMed ITEMS ArrayCol( oE:oCA:aMed,1 ) SIZE 68,99 ;
      OF oDlg PIXEL UPDATE

   @ 100, 70 BUTTON oGet[13] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION ;
      (If( EMPTY(::oArd:CODIGO) .OR. ::oArd:CANTIDAD <= 0              ,;
         (MsgStop("Imposible grabar este Código"), oGet[1]:SetFocus() ),;
         ( oGet[13]:Disable(), ::oArd:UNIDADMED := oE:oCA:aMed[::nMed,2],;
           EVAL( bGrabar ), oGet[11]:Enable() ))) PIXEL
   @ 100,120 BUTTON oGet[14] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL ;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
   If !::aPrv[1]
      oGet[13]:Disable()
   EndIf
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
 oLbx:SetFocus()
RETURN NIL

//------------------------------------//
METHOD EditPVenta( oGet ) CLASS TCompra
 If ::oArd:CANTIDAD > 1
    If !MsgYesNo( "Este es el Precio Unitario","DIVIDIR" )
       ::oArd:PCOSTO := ROUND( ::oArd:PCOSTO / ::oArd:CANTIDAD,2 )
    EndIf
 EndIf
 If ::oArd:DESPOR > 0
    ::oArd:PCOSTO -= ROUND( ::oArd:PCOSTO * ::oArd:DESPOR / 100,2 )
 EndIf
 If oApl:oEmp:TREGIMEN == 1 .AND. ::oArd:INDIVA
    ::oArd:PCOSTO := ROUND( ::oArd:PCOSTO * ::aDF[1],2 )
    ::oArd:PPUBLI := ROUND( ::oArd:PCOSTO * (1+oApl:oInv:PUTIL/100),0 )
    ::aCab[15]    := (::oArd:PPUBLI != oApl:oInv:PPUBLI)
    oGet[10]:Refresh()
 ElseIf oApl:oInv:INDIVA .AND. oApl:oEmp:TREGIMEN >= 2
    If MsgYesNo( "Precio con IVA incluido","I.V.A." )
       ::oArd:PCOSTO := ROUND( ::oArd:PCOSTO / ::aCab[16],2 )
    EndIf
 EndIf
 oGet[8]:Refresh()
 oGet[9]:Refresh()
RETURN .t.

//------------------------------------//
METHOD Guardar( oLbx,lNew ) CLASS TCompra

If ::aCab[1] == 0
   ::aCab[1] := SgteNumero( "numingreso",::aCab[5],.t. )
   ::oArc:EMPRESA   := oApl:nEmpresa
   ::oArc:INGRESO   := ::aCab[1]
   ::oArc:CODIGO_NIT:= ::aCab[14]
   ::oArc:Append( .t. )
   ::aCab[4] := ::aCab[1] + 1
   ::aCab[11]:= .t.
EndIf
 ::oArd:PVENTA := If( !oApl:oInv:INDIVA, ::oArd:PPUBLI,;
                     ROUND( ::oArd:PPUBLI / ::aCab[16],2 ) )
If lNew
   ::oArc:SECUENCIA ++
   ::oArc:SUBTOTAL  += (::oArd:CANTIDAD * ::oArd:PCOSTO)
   ::oArd:INGRESO   := ::aCab[1]
   ::oArd:SECUENCIA := ::oArc:SECUENCIA
   ::oArd:Append( .t. )
   ::oArc:Update( .f.,1 )
   Actualiz( ::oArd:CODIGO,::oArd:CANTIDAD,::oArc:FECINGRE,1,;
             ::oArd:PCOSTO,::oArd:UNIDADMED )
   PListbox( oLbx,::oArd )
Else
   ::oArc:SUBTOTAL  += (::oArd:CANTIDAD * ::oArd:PCOSTO - ::aCab[08] * ::aCab[09])
   ::oArc:Update( .f.,1 )
   If ::aCab[07] # ::oArd:CODIGO .OR. ::aCab[10] # ::oArd:UNIDADMED
      Actualiz( ::aCab[07],-::aCab[08],::oArc:FECINGRE,1,::aCab[09],::aCab[10] )
      ::aCab[08] := 0
   EndIf
   ::oArd:Update( .t.,1 )
   Actualiz( ::oArd:CODIGO,::oArd:CANTIDAD-::aCab[08],::oArc:FECINGRE,1,;
             ::oArd:PCOSTO,::oArd:UNIDADMED )
EndIf
lNew := .f.
If oApl:oInv:PCOSTO  # ::oArd:PCOSTO .AND. ::oArd:PCOSTO > 1
   oApl:oInv:PCOSTO := ::oArd:PCOSTO
   oApl:oInv:DESPOR := If( ::oArd:DESPOR > 0 , ::oArd:DESPOR, oApl:oInv:DESPOR )
   lNew := .t.
EndIf
If ::aCab[15]
   ::aCab[15] := .f.
   oApl:oInv:PVENTA := ::oArd:PVENTA
   lNew := .t.
   PrecioVenta()
EndIf
If lNew
   oApl:oInv:Update( .f.,1 )
EndIf
 ::aCab[6]:Update()
RETURN NIL

//------------------------------------//
METHOD Fechas( lOK,nMsg ) CLASS TCompra
   LOCAL aFec, lSI := .t.
If lOK
   aFec := { ::oArc:XColumn( 4 ),::oArc:FECINGRE,oApl:cPer,::lCierre,.t.,;
             "empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
        " AND ano_mes = " + xValToChar(oApl:cPer )    +;
        " AND control = " + LTRIM(STR(::oMvc:CONTROL)) }
   If (aFec[5] := ::Fechas( .f.,1 ))
      If (aFec[3] == LEFT( DTOS(aFec[2]),6 ))
         Guardar( "UPDATE cgemovc SET fecha = " + xValToChar(aFec[2]) +;
                  " WHERE " + aFec[6],"cgemovc" )
         Guardar( ::oArc,.f.,.f. )
      ElseIf MsgYesNo( "QUIERE HACER EL CAMBIO","VA A CAMBIAR DE MES" )
         ::oArd:dbEval( {|o| Actualiz( o:CODIGO,-o:CANTIDAD,aFec[1],1,o:PCOSTO,o:UNIDADMED ),;
                             Actualiz( o:CODIGO, o:CANTIDAD,aFec[2],1,o:PCOSTO,o:UNIDADMED ) } )
         If ::oMvc:lOK
            ::oMvc:ANO_MES   := oApl:cPer
            ::oMvc:FECHA     := aFec[2]
            ::oMvc:COMPROBANT:= SgteCntrl( "compro_prv",oApl:cPer,.t. )
            ::oMvc:CONTROL   := SgteCntrl( "control",oApl:cPer,.t. )
            ::oArc:COMPROBANT:= ::oMvc:COMPROBANT
            Guardar( ::oMvc,.f.,.f. )
            ::oMvd:dbEval( {|o| ::Avanza( ,o:CUENTA )                                ,;
                                ::GrabaPago( o:CUENTA,::aTL[4],-::aTL[5],::aTL[6],1 ),;
                                Acumular( ::oMvc:ESTADO,o,5,5,.f.,.f. )              ,;
                                o:ANO_MES := oApl:cPer, o:CONTROL := ::oMvc:CONTROL  ,;
                                ::GrabaPago( o:CUENTA,::aTL[4], ::aTL[5],::aTL[6],2 ),;
                                Acumular( ::oMvc:ESTADO,o,2,2,.f.,.f. ) }, aFec[6] )
         EndIf
         Guardar( ::oArc,.f.,.f. )
      Else
         aFec[5] := .f.
      EndIf
   EndIf
   If (lSI := aFec[5])
      MsgInfo( "El cambio de Fecha","HECHO" )
   Else
      lSI := If( EMPTY( aFec[2] ) .OR. ::lCierre, .t., .f. )
      ::oArc:FECINGRE := aFec[1]
      oApl:cPer := aFec[3]
      ::lCierre := aFec[4]
   EndIf
ElseIf nMsg == 2
   If oApl:oNit:CODIGO > 800000000 .AND.;
      oApl:oNit:CODIGO < 999999999
      lSI := !oApl:oNit:RETENEDOR
   Else
      lSI := .f.
   EndIf
ElseIf EMPTY( ::oArc:FECINGRE )
   MsgStop( "No puede ir en Blanco","FECHA" )
   lSI := .f.
Else
   oApl:cPer := NtChr( ::oArc:FECINGRE,"1" )
   ::lCierre := Buscar( {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer},;
                        "cgecntrl","cierre",8,,3 )
   If ::lCierre .AND. nMsg == 0
      MsgStop( "Ya esta CERRADO","Periodo "+oApl:cPer )
      lSI := .f.
   Else
      ::aDF := PIva( oApl:cPer )
      ::aDF[1] += 1
   EndIf
EndIf
RETURN lSI

//------------------------------------//
METHOD Facturas( lNew,cFac,cFV ) CLASS TCompra
   LOCAL cQry, hRes, nR, lOK := .t.
If lNew == NIL
   hRes := ::oArc:EMPRESA
   If ::oArc:SECUENCIA > 0 .AND. (hRes # oApl:nEmpresa .OR. cFac # NIL)
      nR := ::oArd:Recno()
      ::oArc:EMPRESA := oApl:nEmpresa
      ::oArc:Update( .f.,1 )
      ::oArd:GoTop():Read()
      ::oArd:xLoad()
      While !::oArd:Eof()
         oApl:nEmpresa := hRes
         Actualiz( ::oArd:CODIGO,-::oArd:CANTIDAD,::oArc:FECINGRE,1,::oArd:PCOSTO,::oArd:UNIDADMED )
         oApl:nEmpresa := ::oArc:EMPRESA
         If cFac # NIL .AND. oApl:oEmp:TREGIMEN == 1
            ::oArd:PCOSTO := ROUND( ::oArd:PCOSTO * ::aDF[1],2 )
            ::oArd:INDIVA := 1
            ::oArd:Update( .f.,1 )
            Guardar( "UPDATE cadinven SET pcosto = " + LTRIM(STR(::oArd:PCOSTO)) +;
                    " WHERE codigo = " + xValToChar(::oArd:CODIGO),"cadinven" )
         EndIf
         Actualiz( ::oArd:CODIGO, ::oArd:CANTIDAD,::oArc:FECINGRE,1,::oArd:PCOSTO,::oArd:UNIDADMED )
         ::oArd:Skip(1):Read()
         ::oArd:xLoad()
      EndDo
      If cFac # NIL
         ::oArc:SUBTOTAL := Buscar( {"ingreso",::aCab[1]},"cadartid","SUM(cantidad * pcosto)" )
         ::oArc:Update( .f.,1 )
         ::aCab[6]:Update()
         cFac:Refresh()
      EndIf
      ::oArd:Go( nR ):Read()
   EndIf
ElseIf lNew
   If cFac # cFV
      ::oArc:Update( .f.,1 )
   EndIf
Else
   cFV  := ""
   cQry := "SELECT c.ingreso, e.localiz FROM cadempre e, cadartic c "+;
           "WHERE c.empresa = e.empresa"             +;
            " AND c.factura = " + xValToChar( cFac ) +;
            " AND c.codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT))
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nR   := MSNumRows( hRes )
   While nR > 0
      cQry := MyReadRow( hRes )
      cFV  += ("Ing." + cQry[1] + " EN " + cQry[2]) +;
              If( nR > 1, CRLF, "" )
      nR --
   EndDo
   MSFreeResult( hRes )
   If !EMPTY( cFV )
      lOK := MsgNoYes( cFV,"Factura "+cFac+" YA esta en" )
   EndIf
EndIf
RETURN lOK

//------------------------------------//
METHOD Mostrar() CLASS TCompra
   LOCAL bHacer, nOrd, oDlg, oM := Self
   LOCAL lReturn := .f.
::oDb:cWhere := " empresa = " + LTRIM(STR(oApl:nEmpresa))
bHacer := {||lReturn := ::lBuscar := .t., oDlg:End()}
nOrd   := ::Ordenar( 1 )

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE "Ayuda de las Compras"
   @ 1.5, 0 LISTBOX ::oLbx FIELDS ;
                    ::oDb:NOMBRE  , ::oDb:FACTURA,;
                    DTOC(::oDb:FECINGRE);
      HEADERS "Nombre", "Numero"+CRLF+"Factura", "Fecha";
      SIZES 400, 450 SIZE 200,107  ;
      OF oDlg UPDATE               ;
      ON DBLCLICK EVAL(bHacer)
    ::oLbx:nClrBackHead  := oApl:nClrBackHead
    ::oLbx:nClrForeHead  := oApl:nClrForeHead
    ::oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    ::oLbx:nClrBackFocus := oApl:nClrBackFocus
    ::oLbx:nClrForeFocus := oApl:nClrForeFocus
    ::oLbx:nHeaderHeight := 28
    ::oLbx:GoTop()
    ::oLbx:oFont       := ::oFont
    ::oLbx:aColSizes   := {200,70,60}
    ::oLbx:aHjustify   := {2,2,2}
    ::oLbx:aJustify    := {0,0,0}
    ::oLbx:ladjbrowse  := ::oLbx:lCellStyle  := .f.
    ::oLbx:ladjlastcol := .t.
    ::oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey==VK_RETURN                      , EVAL(bHacer),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) ) }
   MySetBrowse( ::oLbx, ::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT (oM:Barra( .t.,oDlg ))

RETURN lReturn

//-----CONTABILIZAR-------------------//
METHOD Graba( lG ) CLASS TCompra
   LOCAL aCta := {}, aInf, cSql, hRes, nE, nK
If ::oArc:SECUENCIA > 0 .AND. oApl:oNit:CODIGO # 2 .AND.;
  (::oArc:COMPROBANT == 0 .OR. ::oArc:SUBTOTAL # ::nSubtotal .OR. ::aCab[12] .OR. lG)
// AEVAL( ::aCta, {| x | AADD( aCta, { x[1],"","","","",0,0,0,0 } ) } )
      ::aCta[1,6] := ::oArc:SUBTOTAL - ::oArc:TOTALDES
      ::aCta[2,6] := ::oArc:TOTALFLE
      ::aCta[9,6] := ::oArc:TOTALDES
   If oApl:oEmp:TREGIMEN == 1
      aCta := { {::aCta[1,1],"","","","",::aCta[1,6]    ,0,0,0,0 },;
                {::aCta[2,1],"","","","",::aCta[2,6]    ,0,0,0,0 },;
                {::aCta[3,1],"","","","",0              ,0,0,0,0 },;
                {::aCta[5,1],"","","","",0,::oArc:TOTALFAC,0,0,0 },;
                {::aCta[9,1],"","","","",::aCta[9,6]    ,0,0,0,0 } }
   Else
      ::aCta[4,06] := ::oArc:TOTALIVA
      ::aCta[4,09] := ROUND( (::aDF[1]-1) * 100,2 )
      ::aCta[5,07] := ::oArc:TOTALFAC - ::oArc:TOTALRET - ::oArc:TOTALICA - ::oArc:TOTALCRE
      ::aCta[6,07] := ::oArc:TOTALRET
      ::aCta[6,09] := ::aDF[3] * 100
      ::aCta[7,07] := ::oArc:TOTALICA
      ::aCta[7,09] := ::aDF[4] * 1000
      ::aCta[8,07] := ::oArc:TOTALCRE
      ::aCta[8,09] := ::aDF[9] * 100
      ::aCta[6,10] := ::aCta[7,10] := ::aCta[8,10] := (::oArc:TOTALFAC - ::oArc:TOTALIVA)
      If oApl:oEmp:PRINTIVA
         ::aCta[4,6] := 0
         AEVAL( ::aCta, {| x | AADD( aCta, { x[1],"","","","",x[6],x[7],x[8],x[9],x[10] } ) },1,4 )
         cSql := "SELECT d.cantidad * d.pcosto, i.impuesto "+;
                 "FROM cadartid d LEFT JOIN cadinven i "    +;
                  "USING( codigo ) "                        +;
                 "WHERE i.impuesto > 0"                     +;
                  " AND d.ingreso = " + LTRIM(STR(::aCab[1]))
         hRes := If( MSQuery( oApl:oMySql:hConnect,cSql ) ,;
                     MSStoreResult( oApl:oMySql:hConnect ), 0 )
         nE   := MSNumRows( hRes )
         While nE > 0
            aInf := MyReadRow( hRes )
            AEVAL( aInf, { | xV,nP | aInf[nP] := MyClReadCol( hRes,nP ) } )
            If (nK := ASCAN( aCta,{ |aX| aX[9] == aInf[2] } )) == 0
               cSql := LEFT( aCta[4,1],6 ) + STRZERO( aInf[2],2 )
               CreaCta( cSql,"IVA DESCONTADO " + STR(aInf[2],2) )
               AADD( aCta, { cSql,"","","","",0,0,0,aInf[2],0 } )
               nK := LEN( aCta )
            EndIf
            aCta[nK,06] += ROUND( aInf[1] * aInf[2] / 100,2 )
            aCta[nK,10] += aInf[1]
            nE --
         EndDo
         MSFreeResult( hRes )
         nE := ::oArc:TOTALIVA
         AEVAL( aCta, {| x | nE -= x[6] },4 )
         If nE # 0
            If aCta[04,6] > 0
               aCta[04,6] += nE
            Else
               nK := LEN( aCta )
               aCta[nK,6] += nE
            EndIf
         EndIf
         AEVAL( ::aCta, {| x | AADD( aCta, { x[1],"","","","",x[6],x[7],x[8],x[9],x[10] } ) },5 )
      Else
         AEVAL( ::aCta, {| x | AADD( aCta, { x[1],"","","","",x[6],x[7],x[8],x[9],x[10] } ) } )
      EndIf
   EndIf
   nK := 0
   AEVAL( aCta, {| x | nK += (x[6] - x[7]) } )
   If nK > 0
      aCta[3,7] := nK
   Else
      aCta[3,6] := ABS(nK)
   EndIf

   If ::oMvc:Seek( {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,"fuente",4,;
                    "comprobant",::oArc:COMPROBANT} )
      ::oMvc:CONSECUTIV:= 0
      ::oMvc:ESTADO    := 1
      ::oMvd:dbEval( {|o| ::Avanza( ,o:CUENTA ),  o:EMPRESA := -4              ,;
                          ::GrabaPago( o:CUENTA,::aTL[4],-::aTL[5],::aTL[6],1 ),;
                          Acumular( ::oMvc:ESTADO,o,3,3,.f.,.f. ) }            ,;
                     {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,;
                      "control",::oMvc:CONTROL} )
   Else
      ::oMvc:EMPRESA   := oApl:nEmpresa    ; ::oMvc:ANO_MES  := oApl:cPer
      ::oMvc:FECHA     := ::oArc:FECINGRE  ; ::oMvc:FUENTE   := 4
      ::oMvc:COMPROBANT:= SgteCntrl( "compro_prv",oApl:cPer,.t. )
      ::oMvc:CONCEPTO  := "FACTURA # " + TRIM(::oArc:FACTURA) + " INGRESO # " + LTRIM(STR(::oArc:INGRESO))
      ::oMvc:CODIGONIT := ::oArc:CODIGO_NIT
      ::oMvc:CONTROL   := SgteCntrl( "control",oApl:cPer,.t. )
      ::oMvc:ESTADO    := 1
      ::oMvc:Append(.t.)
      ::oArc:COMPROBANT:= ::oMvc:COMPROBANT; ::oArc:Update( .f.,1 )
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
            Case cSql == "DOCUMENTO"
               aCta[nE,nK+1] := ::oArc:FACTURA
            Case cSql == "FECHA"
               aCta[nE,nK+1] := DTOC(::oArc:FECINGRE+30)
            Case cSql == "NIT"
               aCta[nE,nK+1] := LTRIM(STR(::aCab[3]))
               aCta[nE,8]    := ::oArc:CODIGO_NIT
            EndCase
         NEXT nK
         ::oMvd:Seek( "empresa = -4 LIMIT 1","CM" )
         ::oMvd:EMPRESA   := oApl:nEmpresa  ; ::oMvd:ANO_MES  := oApl:cPer
         ::oMvd:CONTROL   := ::oMvc:CONTROL ; ::oMvd:CUENTA   := aCta[nE,1]
         ::oMvd:INFA      := aCta[nE,2]     ; ::oMvd:INFB     := aCta[nE,3]
         ::oMvd:INFC      := aCta[nE,4]     ; ::oMvd:INFD     := aCta[nE,5]
         ::oMvd:VALOR_DEB := aCta[nE,6]     ; ::oMvd:VALOR_CRE:= aCta[nE,7]
         ::oMvd:CODIGO_NIT:= aCta[nE,8]     ; ::oMvd:PTAJE    := aCta[nE,9]
         Acumular( ::oMvc:ESTADO,::oMvd,2,2,!::oMvd:lOK,.f. )
         ::Avanza( ,aCta[nE,1] )
         ::GrabaPago( ::oMvd:CUENTA,::aTL[4],::aTL[5],::aTL[6],2 )
         ::oMvc:CONSECUTIV ++
      EndIf
   NEXT nE
   ::oMvc:Update(.f.,1)
   If lG
      MsgInfo( "Compra CONTABILIZADA","LISTO" )
   EndIf
EndIf
 ::nSubtotal := ::oArc:SUBTOTAL
RETURN NIL

//------------------------------------//
METHOD ArmarLis() CLASS TCompra
   LOCAL nOpc := 1
If ::aCab[1] == 0
   MsgStop( "Grabar la Compra","Primero tienes que" )
   RETURN NIL
EndIf
MsgGet( "Listar Compras","1_Movto Contable, 2_Codigos",@nOpc )
If nOpc == 1
   If ::oMvc:CONTROL > 0 .AND. ::oMvc:ESTADO # 2
      CgeLista( ::oMvc:CONTROL,,::oFte:oDb:DESCRIPCIO )
   EndIf
ElseIf nOpc == 2
   InoLiArt( 1,{::oArc:FECINGRE,::oArc:FECINGRE,::aCab[1], "",.f.,;
                oApl:nTFor,.t.,0,""} )
EndIf
RETURN NIL