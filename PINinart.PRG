// Programa.: INOINART.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Mantenimiento de las Comparas al Inventario.
#include "FiveWin.ch"
#include "Objects.ch"
#include "btnget.ch"

MEMVAR oApl

PROCEDURE InoinArt()
   LOCAL oDlg, oLbx, oGet := ARRAY(11), lSalir := .f.
   LOCAL aBarra, aCab, oNi := TNits()
   LOCAL oC := TCompra()
oC:New()
aBarra := { {|| oC:Editar( oLbx,.t. ) }, {|| oC:Editar( oLbx,.f. ) },;
            {|| .t. }                  , {|| oC:Borrar( oLbx ) }    ,;
            {|| ListoArt( {oC:oArc:FECINGRE,oC:oArc:FECINGRE,oC:aCab[1],;
                   "C",.f.,0} ),oC:aCab[1] := 0, oGet[1]:SetFocus() },;
            {|| If( oC:aCab[13], oC:Contabil(), ), lSalir := .t., oDlg:End() } }
oNi:New()
oNi:oDb:xBlank()

DEFINE DIALOG oDlg RESOURCE "COMPRAS"
   REDEFINE GET oGet[1] VAR oC:aCab[1] ID  1 OF oDlg PICTURE "999999";
      VALID oC:Buscar( oLbx,oGet ) UPDATE
   REDEFINE SAY VAR oC:aCab[4]         ID  3 OF oDlg UPDATE COLOR nRGB( 255,0,0 )
   REDEFINE GET oGet[2] VAR oC:aCab[2] ID  5 OF oDlg PICTURE "@!"  ;
      VALID EVAL( {|| If( oApl:oEmp:Seek( {"Localiz",oC:aCab[2]} ),;
                        ( oApl:nEmpresa := oApl:oEmp:EMPRESA      ,;
                          oC:CambiaOptica() , .t. )               ,;
                        (MsgStop("Esta Empresa NO EXISTE"), .f.) ) } ) UPDATE
   REDEFINE GET oGet[3] VAR oC:oArc:FECINGRE ID  7 OF oDlg ;
      WHEN oC:oArc:SECUENCIA == 0  UPDATE
   REDEFINE BTNGET oGet[4] VAR oC:aCab[3] ID  9 OF oDlg RESOURCE "BUSCAR";
      VALID EVAL( {|| If(!oNi:oDb:Seek( {"Codigo",oC:aCab[3]} )         ,;
            (MsgStop("Este Proveedor no Existe .."), .f.)               ,;
            (oC:oArc:CODIGO_NIT := oNi:oDb:CODIGO_NIT, oDlg:Update(), .t.)) } );
      WHEN oC:oArc:SECUENCIA == 0 UPDATE         ;
      ACTION EVAL({|| If(oNi:Mostrar(), (oC:aCab[3] := oNi:oDb:CODIGO,;
                        oGet[4]:Refresh(), oGet[4]:lValid(.f.)),)})
   REDEFINE SAY VAR oNi:oDb:NOMBRE ID 10 OF oDlg UPDATE COLOR nRGB( 128,0,255 )
   REDEFINE GET oGet[05] VAR oC:oArc:FACTURA  ID 12 OF oDlg ;
      WHEN oC:oArc:SECUENCIA == 0  UPDATE
   REDEFINE GET oGet[06] VAR oC:oArc:TOTALDES ID 14 OF oDlg PICTURE "999,999,999";
      WHEN oC:oArc:SECUENCIA == 0  UPDATE
   REDEFINE GET oGet[07] VAR oC:oArc:TOTALIVA ID 16 OF oDlg PICTURE "999,999,999";
      WHEN oC:oArc:SECUENCIA == 0  UPDATE
   REDEFINE GET oGet[08] VAR oC:oArc:TOTALFLE ID 18 OF oDlg PICTURE "999,999,999";
      WHEN oC:oArc:SECUENCIA == 0  UPDATE
   REDEFINE GET oGet[09] VAR oC:oArc:TOTALRET ID 20 OF oDlg PICTURE "999,999,999";
      WHEN oC:oArc:SECUENCIA == 0  UPDATE
   REDEFINE GET oGet[10] VAR oC:oArc:TOTALFAC ID 22 OF oDlg PICTURE "999,999,999";
      WHEN oC:oArc:SECUENCIA == 0  UPDATE
   REDEFINE SAY oGet[11] VAR oC:oArc:SUBTOTAL ID 24 OF oDlg PICTURE "999,999,999";
      UPDATE
   REDEFINE LISTBOX oLbx FIELDS oC:oArd:CODIGO             ,;
                     LeerCodig( oC:oArd:CODIGO )           ,;
                     TRANSFORM( oC:oArd:CANTIDAD,"99,999" ),;
                     TRANSFORM( oC:oArd:PCOSTO  ,"99,999,999" ),;
                     TRANSFORM( oC:oArd:PVENTA  ,"99,999,999" ),;
                                oC:oArd:INDICA              ;
      HEADERS "Código"+CRLF+"Artículo", "Descripción", "Cantidad",;
              "Precio"+CRLF+"Costo", "Precio"+CRLF+"Venta", "Ind" ;
      ID 25 OF oDlg UPDATE                ;
      ON DBLCLICK EVAL( aBarra[2] )
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:nHeaderHeight := 28
    oLbx:GoTop()
    oLbx:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:aColSizes := {84,200,60,86,86,10}
    oLbx:aHjustify := {2,2,2,2,2,2}
    oLbx:aJustify  := {0,0,1,1,1,2}
    oLbx:bKeyDown := {|nKey| If(nKey == VK_ESCAPE, ( oC:aCab[1] := 0, oGet[1]:SetFocus() ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(aBarra[1]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, EVAL(aBarra[2]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, EVAL(aBarra[4]),) ))) }
    oLbx:lCellStyle  := oLbx:ladjbrowse  := .f.
    oLbx:ladjlastcol := .t.
   MySetBrowse( oLbx,oC:oArd )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT ;
  (oDlg:Move(80,1), DefineBar( oDlg,oLbx,aBarra,134,18 ),;
   oC:aCab[8] := oDlg);
   VALID lSalir
oC:oArc:Destroy()
oC:oArd:Destroy()
oC:oMvc:Destroy()
oC:oMvd:Destroy()
oApl:oEmp:Seek( {"Empresa",oC:aCab[6]} )
nEmpresa( .f. )

RETURN

//------------------------------------//
CLASS TCompra

 DATA aCab, aCta, nSubtotal, oArc, oArd, oMvc, oMvd

 METHOD NEW() Constructor
 METHOD Buscar( oLbx,oGet )
 METHOD Borrar( oLbx )
 METHOD Editar( oLbx,lNew )
 METHOD Grabar( oLbx,lNew )
 METHOD CambiaOptica()
 METHOD Contabil()

ENDCLASS

//------------------------------------//
METHOD New() CLASS TCompra

 oApl:oEmp:Seek( {"Empresa",4} )
 ::aCab := { 0,oApl:oEmp:TITULAR,0,oApl:oEmp:NUMINGRESO + 1,;
             oApl:oEmp:PIVA / 100 + 1,oApl:nEmpresa,TInv(),"",0,0,0,"UN",.f. }
 ::aCta := Buscar( {"Empresa",oApl:nEmpresa,"Tipo","4"},"cuentas",;
                    "Cuenta, Cta_cte",9,"Nivel" )
 ::oArc := oApl:Abrir( "cadartic","Ingreso",.t.,,10 )
 ::oArd := oApl:Abrir( "cadartid","Ingreso",,,100 )
 ::oMvc := oApl:Abrir( "cgemovc" ,"Empresa, ano_mes, control",.t.,,5 )
 ::oMvd := oApl:Abrir( "cgemovd" ,"Empresa, ano_mes, control",.t.,,10 )
 ::oArd:Seek( { "Ingreso",0 } )
 ::aCab[7]:New( ,.f. )

RETURN NIL

//------------------------------------//
METHOD Buscar( oLbx,oGet ) CLASS TCompra
   LOCAL lSi := .f.
If Rango( ::aCab[1],0,::aCab[4] )
   If ::aCab[13]
      ::Contabil()
   EndIf
   If !::oArc:Seek( { "Ingreso",::aCab[1] } ) .AND. ::aCab[1] > 0
      MsgStop( "Este Ingreso NO EXISTE !!" )
   Else
      If ::oArc:lOK
         oApl:oNit:Seek( {"Codigo_nit",::oArc:CODIGO_NIT} )
         ::aCab[02] := ArrayValor( oApl:aOptic,STR(::oArc:EMPRESA,2) )
         ::aCab[03] := oApl:oNit:CODIGO
         //::aCab[11] := ::oArc:CODIGO_NIT
         oApl:nEmpresa := ::oArc:EMPRESA
         oGet[1]:oJump := oLbx
      Else
         ::aCab[02] := oApl:oEmp:TITULAR
         ::oArc:FECINGRE := DATE()
      EndIf
      ::nSubtotal := ::oArc:SUBTOTAL
      ::oArd:Seek( { "Ingreso",::aCab[1] } )
      ::aCab[08]:Update()
      ::aCab[13] := ::oArc:lOK
//    ::aCab[12] := ::oArc:FACTURA
      oLbx:Refresh()
      lSi := .t.
   EndIf
EndIf
RETURN lSi

//------------------------------------//
METHOD Borrar( oLbx ) CLASS TCompra
//   LOCAL nRecNo := ::oArd:RecNo()
If ::oArc:SECUENCIA > 0
   If ::oArd:INDICA == "B"
      MsgInfo( "Ya esta Borrado",::oArd:CODIGO )
   ElseIf MsgNoYes( "Este Código "+::oArd:CODIGO,"Elimina" )
      oApl:oInv:Seek( {"Codigo",::oArd:CODIGO} )
      Actualiz( ::oArd:CODIGO,-::oArd:CANTIDAD,::oArc:FECINGRE,1,;
                ::oArd:PCOSTO,::oArd:UNIDADMED )
      ::oArc:SUBTOTAL -= (::oArd:CANTIDAD * ::oArd:PCOSTO)
      ::oArc:Update( .f.,1 )
      If ::oArd:INDICA == "E"
         ::oArd:INDICA := "B" ; ::oArd:Update( .f.,1 )
      ElseIf ::oArd:Delete( .t.,1 )
         oLbx:GoBottom()
      EndIf
      oLbx:SetFocus() ; oLbx:Refresh()
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Editar( oLbx,lNew ) CLASS TCompra
   LOCAL oDlg, cTit := "Modificando Ingreso"
   LOCAL bGrabar, nMed, oGet := ARRAY(8), oE := Self
   LOCAL oAr := ::aCab[7]
   LOCAL bMed := {|cUMed| nMed := ArrayValor( oAr:aMed,cUMed,,.t. ) }
lNew := If( ::oArc:SECUENCIA == 0, .t., lNew )
If lNew
   cTit    := "Nuevo Ingreso"
   bGrabar := {|| ::Grabar( oLbx,lNew )         ,;
                  ::oArd:xBlanK()               ,;
                  oDlg:Update(), oDlg:SetFocus() }
   oLbx:GoBottom() ; ::oArd:xBlank()
Else
   If oApl:lEnLinea
      MsgStop( "Este Registro no se Puede Modificar","Lo Siento" )
      RETURN NIL
   EndIf
   bGrabar := {|| ::Grabar( oLbx,lNew ), oLbx:Refresh(), oDlg:End() }
   ::aCab[09]:= ::oArd:CODIGO
   ::aCab[10]:= ::oArd:CANTIDAD
   ::aCab[11]:= ::oArd:PCOSTO
   ::aCab[12]:= ::oArd:UNIDADMED
EndIf
oAr:oDb:Seek( {"Codigo",oE:oArd:CODIGO} )
EVAL( bMed,::oArd:UNIDADMED )

DEFINE DIALOG oDlg TITLE cTit FROM 0, 0 TO 16,50
   @ 02,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 66,10
   @ 02,70 BTNGET oGet[1] VAR oE:oArd:CODIGO OF oDlg PICTURE "999999999!!!";
      VALID If( oAr:oDb:Seek( {"Codigo",oE:oArd:CODIGO} ),;
              ( If( lNew                                 ,;
                  (oE:oArd:CANTIDAD := 1                 ,;
                   oE:oArd:PCOSTO   := oAr:oDb:PCOSTO    ,;
                   oE:oArd:PVENTA   := oAr:oDb:PVENTA    ,;
                   oE:oArd:INDIVA   := oAr:oDb:INDIVA    ,;
                   EVAL( bMed,oApl:oInv:UNIDADMED ) ), ) ,;
                oDlg:Update(), .t. )                     ,;
              ( MsgStop( "Este Código NO EXISTE !!!" ), .f. ));
      SIZE 56,12 PIXEL  RESOURCE "BUSCAR"                     ;
      ACTION EVAL({|| If(oAr:Mostrar(), (oE:oArd:CODIGO := oAr:oDb:CODIGO,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
   @ 16,50 SAY    oGet[2] VAR oApl:oInv:DESCRIP OF oDlg PIXEL SIZE 120,12;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 30,00 SAY "Cantidad" OF oDlg RIGHT PIXEL SIZE 66,8
   @ 30,70 GET oGet[3] VAR ::oArd:CANTIDAD OF oDlg PICTURE "9,999.99";
      VALID {|| If( ::oArd:CANTIDAD >  0, .t.                       ,;
          (MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>"), .f.)) };
      SIZE 40,12 PIXEL UPDATE
   @ 44,00 SAY "Precio Costo"  OF oDlg RIGHT PIXEL SIZE 66,8
   @ 44,70 GET oGet[4] VAR ::oArd:PCOSTO   OF oDlg PICTURE "999,999,999";
      SIZE 40,12 PIXEL UPDATE
   @ 58,00 SAY "Precio Venta"  OF oDlg RIGHT PIXEL SIZE 66,8
   @ 58,70 GET oGet[5] VAR ::oArd:PVENTA   OF oDlg PICTURE "999,999,999";
      SIZE 40,12 PIXEL UPDATE
   @ 72,00 SAY "Indicador IVA" OF oDlg RIGHT PIXEL SIZE 66,8
   @ 72,70 GET oGet[5] VAR ::oArd:INDIVA   OF oDlg PICTURE "9";
      VALID Rango( ::oArd:INDIVA,0,1 )     SIZE 10,12 PIXEL UPDATE
   @ 86,00 SAY "Unidad Medida" OF oDlg RIGHT PIXEL SIZE 66,8
   @ 86,70 COMBOBOX oGet[6] VAR nMed ITEMS ArrayCol( oAr:aMed,1 ) SIZE 68,99 ;
      OF oDlg PIXEL UPDATE

   @ 102, 70 BUTTON oGet[7] PROMPT "&Grabar"   SIZE 44,12 OF oDlg ACTION;
      (If( EMPTY(::oArd:CODIGO) .OR. ::oArd:CANTIDAD <= 0              ,;
         (MsgStop("Imposible grabar este Código"), oGet[1]:SetFocus() ),;
         ( oGet[7]:Disable(), ::oArd:UNIDADMED := oAr:aMed[nMed,2]     ,;
           EVAL( bGrabar ), oGet[7]:Enable() ))) PIXEL
   @ 102,120 BUTTON oGet[8] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
 oLbx:SetFocus()
RETURN NIL

//------------------------------------//
METHOD Grabar( oLbx,lNew ) CLASS TCompra

If ::aCab[1] == 0
   ::aCab[1] := SgteNumero( "NUMINGRESO",4,.t. )
   ::oArc:EMPRESA   := oApl:nEmpresa
   ::oArc:INGRESO   := ::aCab[01]
// ::oArc:CODIGO_NIT:= ::aCab[11]
   ::oArc:Append( .t. )
   ::aCab[4] := ::aCab[1] + 1
   ::aCab[13]:= .t.
EndIf
::oArd:PPUBLI := If( ::oArd:INDIVA == 0, ::oArd:PVENTA,;
                     ROUND( ::oArd:PVENTA*::aCab[5],0 ) )
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
  //oApl:oInv:PCOSTO := oArd:PCOSTO ; oApl:oInv:PVENTA := oArd:PVENTA
  //oApl:oInv:PPUBLI := oArd:PPUBLI ; oApl:oInv:Update( .f.,1 )
Else
   If ::oArd:INDICA == "E" .AND. ;
     (::oArd:CODIGO # ::aCab[09] .OR. ::oArd:CANTIDAD # ::aCab[10])
      ::oArd:INDICA := "C"
   EndIf
   ::oArc:SUBTOTAL  += (::oArd:CANTIDAD * ::oArd:PCOSTO - ::aCab[10] * ::aCab[11])
   ::oArc:Update( .f.,1 )
   If ::aCab[09] # ::oArd:CODIGO .OR. ::aCab[12] # ::oAju:UNIDADMED
      Actualiz( ::aCab[09],-::aCab[10],::oArc:FECINGRE,1,::aCab[11],::aCab[12] )
      ::aCab[10] := 0
   EndIf
   ::oArd:Update( .t.,1 )
   Actualiz( ::oArd:CODIGO,::oArd:CANTIDAD-::aCab[10],::oArc:FECINGRE,1,;
             ::oArd:PCOSTO,::oArd:UNIDADMED )
EndIf
::aCab[8]:Update()
RETURN NIL

//------------------------------------//
METHOD CambiaOptica() CLASS TCompra
   LOCAL nOptica := ::oArc:EMPRESA, nReg := ::oArd:Recno()
If ::oArc:SECUENCIA > 0 .AND. nOptica # oApl:nEmpresa
   ::oArc:EMPRESA := oApl:nEmpresa
   ::oArc:Update( .f.,1 )
   ::oArd:GoTop():Read()
   ::oArd:xLoad()
   While !::oArd:Eof()
      oApl:nEmpresa := nOptica
      Actualiz( ::oArd:CODIGO,-::oArd:CANTIDAD,::oArc:FECINGRE,1,::oArd:PCOSTO )
      oApl:nEmpresa := ::oArc:EMPRESA
      Actualiz( ::oArd:CODIGO, ::oArd:CANTIDAD,::oArc:FECINGRE,1,::oArd:PCOSTO )
      ::oArd:Skip(1):Read()
      ::oArd:xLoad()
   EndDo
   ::oArd:Go( nReg ):Read()
EndIf
RETURN NIL

//------------------------------------//
METHOD Contabil() CLASS TCompra
   LOCAL aCta := {}, aInf, cSql, nE, nK
If ::oArc:INGRESO >= 771 .AND. oApl:oNit:TIPOCOD # 1 .AND.;
   ::oArc:SUBTOTAL # ::nSubtotal
   AEVAL( ::aCta, {| x | AADD( aCta, { TRIM(x[1]),"","","","",0,0,0 } ) } )
   aCta[1,6] := ::oArc:SUBTOTAL - ::oArc:TOTALDES
   aCta[2,6] := ::oArc:TOTALFLE
   aCta[3,6] := ::oArc:TOTALIVA
   aCta[4,7] := ::oArc:TOTALFAC - ::oArc:TOTALRET
   aCta[5,7] := ::oArc:TOTALRET
   oApl:cPer := NtChr( ::oArc:FECINGRE,"1" )
   If ::oMvc:Seek( {"Empresa",oApl:nEmpresa,"Ano_mes",oApl:cPer,"Fuente",4,;
                    "Control",::oArc:CONTROL} )
      cSql := "UPDATE cgemovd SET Empresa = 99 "            +;
              "WHERE Empresa = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND Ano_mes = " + xValToChar(oApl:cPer )   +;
               " AND Control = " + LTRIM(STR(::oMvc:CONTROL))
      MSQuery( oApl:oMySql:hConnect,cSql )
      ::oMvc:CONSECUTIV := 0
   Else
      ::oMvc:EMPRESA   := oApl:nEmpresa    ; ::oMvc:ANO_MES  := oApl:cPer
      ::oMvc:FECHA     := ::oArc:FECINGRE  ; ::oMvc:FUENTE   := 4
      ::oMvc:COMPROBANT:= SgteCntrl( "Compro_prv",oApl:cPer,.t. )
      ::oMvc:CONCEPTO  := oApl:oInv:DESCRIP; ::oMvc:CODIGONIT:= ::oArc:CODIGO_NIT
      ::oMvc:CONTROL   := SgteCntrl( "Control",oApl:cPer,.t. )
      ::oMvc:Append(.t.)
      ::oArc:CONTROL   := ::oMvc:CONTROL   ; ::oArc:Update( .f.,1 )
   EndIf
   FOR nE := 1 TO LEN( aCta )
      If aCta[nE,6] > 0 .OR. aCta[nE,7] > 0
         aInf := Buscar( { "Empresa",oApl:nPuc,"Cuenta",aCta[nE,1] },"cgeplan",;
                           "Infa, Infb, Infc, Infd",8 )
         FOR nK := 1 TO 4
            cSql := TRIM( aInf[nK] )
            do case
            Case cSql == "COD-VAR"
               aCta[nE,nK+1] := aCta[nE,1]
            Case cSql == "DOCUMENTO"
               aCta[nE,nK+1] := ::oArc:FACTURA
            Case cSql == "FECHA"
               aCta[nE,nK+1] := DTOC(::oArc:FECINGRE)
            Case cSql == "NIT"
               aCta[nE,nK+1] := LTRIM(STR(::aCab[3]))
               aCta[nE,8]    := ::oArc:CODIGO_NIT
            EndCase
         NEXT nK
         ::oMvd:Seek( {"Empresa",99} )
         ::oMvd:EMPRESA   := oApl:nEmpresa  ; ::oMvd:ANO_MES  := oApl:cPer
         ::oMvd:CONTROL   := ::oMvc:CONTROL ; ::oMvd:CUENTA   := aCta[nE,1]
         ::oMvd:INFA      := aCta[nE,2]     ; ::oMvd:INFB     := aCta[nE,3]
         ::oMvd:INFC      := aCta[nE,4]     ; ::oMvd:INFD     := aCta[nE,5]
         ::oMvd:VALOR_DEB := aCta[nE,6]     ; ::oMvd:VALOR_CRE:= aCta[nE,7]
         ::oMvd:CODIGO_NIT:= aCta[nE,8]
         If ::oMvd:lOK
            ::oMvd:Update(.f.,1)
         Else
            ::oMvd:Append(.f.)
         EndIf
         ::oMvc:CONSECUTIV ++
      EndIf
   NEXT nE
   ::oMvc:Update(.f.,1)
EndIf
::nSubtotal := ::oArc:SUBTOTAL
RETURN NIL
