// Programa.: JVMDEVOL.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Mantenimiento de las Devoluciones a Provedor.
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

PROCEDURE Inodevol()
   LOCAL oLbx, oGet := ARRAY(10), lSalir := .f.
   LOCAL aBarra, aDev := { "" }, oD
oD  := TDevol() ;  oD:New()
oD:oArc:xBlank()
oD:oNit:oDb:xBlank()
aBarra := { {|| oD:Editar( oLbx,.t. ) }, {|| oD:Editar( oLbx,.f. ) } ,;
            {|| oD:Graba( .t. ) }      , {|| oD:Borrar( oLbx ) }     ,;
            {|| oD:ArmarLis(), oD:aCab[1] := 0, oGet[1]:SetFocus() } ,;
            {|| If( oD:aCab[11], oD:Graba(.f.), ), lSalir := .t., oD:oDlg:End() },;
            {|| oD:Borrar( oLbx,oGet ) } }
//            {|| InoLista( 2,{oD:oArc:FECHA,oD:oArc:FECHA,"C",oD:aCab[1],"S" ,;
//                 oApl:nTFor,.t.,""} ), oD:aCab[1] := 0, oGet[1]:SetFocus() },;

AEVAL( oD:aCau, {|aVal| AADD( aDev, aVal[1] ) } )

DEFINE DIALOG oD:oDlg FROM 0, 0 TO 320, 600 PIXEL;
   TITLE "Devolución a Proveedores"
   @ 16, 00 SAY "Empresa"        OF oD:oDlg RIGHT PIXEL SIZE 50,10
   @ 16, 52 GET oGet[1] VAR oD:aCab[2] OF oD:oDlg PICTURE "@!";
      VALID EVAL( {|| If( oApl:oEmp:Seek( {"localiz",oD:aCab[2]} ),;
                        ( nEmpresa( .t. ) , oD:aCab[1] := 0       ,;
                          oD:oArc:xBlank(), oD:oDlg:Update(), .t. )  ,;
                        (MsgStop("Esta Empresa NO EXISTE"), .f.) ) } );
      SIZE 21,10 PIXEL
   @ 16,100 SAY "Nro.Comprobante"  OF oD:oDlg RIGHT PIXEL SIZE 50,10
   @ 16,152 SAY oGet[2] VAR oD:oArc:COMPROBANT OF oD:oDlg PIXEL SIZE  44,10 ;
      UPDATE COLOR nRGB( 0,128,192 )
   @ 28, 00 SAY "Nro.Devolución"   OF oD:oDlg RIGHT PIXEL SIZE 50,10
   @ 28, 52 BTNGET oGet[3] VAR oD:aCab[1] OF oD:oDlg PICTURE "9999999999";
      ACTION EVAL({|| If(oD:Mostrar(), ( oD:aCab[1] := oD:oDb:NUMERO,;
                         oGet[3]:Refresh() ),) })                    ;
      VALID oD:Buscar( oLbx,oGet )                                   ;
      SIZE 40,10 PIXEL UPDATE  RESOURCE "BUSCAR"
   @ 28,100 SAY "Sgte. Devolución" OF oD:oDlg RIGHT PIXEL SIZE 50,10
   @ 28,152 SAY oGet[4] VAR oD:aCab[4] OF oD:oDlg PIXEL SIZE  44,10 ;
      UPDATE COLOR nRGB( 255,0,0 )
   @ 16,200 SAY "Fecha"            OF oD:oDlg RIGHT PIXEL SIZE 50,10
   @ 16,252 GET oGet[5] VAR oD:oArc:FECHA OF oD:oDlg ;
      VALID oD:Fechas( oD:oArc:lOK,1 ) ;
      WHEN oD:aPrv[2]  ;
      SIZE 40,10 PIXEL UPDATE
   @ 40, 00 SAY "Nit Proveedor"    OF oD:oDlg RIGHT PIXEL SIZE 50,10
   @ 40, 52 BTNGET oGet[6] VAR oD:aCab[3] OF oD:oDlg PICTURE "9999999999"   ;
      ACTION EVAL({|| If(oD:oNit:Mostrar(), (oD:aCab[3] := oD:oNit:oDb:CODIGO,;
                         oGet[6]:Refresh() ),) })                       ;
      VALID EVAL( {|| If(!oD:oNit:Buscar( oD:aCab[3],,.t. )            ,;
                        (MsgStop("Este Proveedor no Existe .."), .f.)  ,;
            (oD:oArc:CODIGO_NIT := oD:oNit:oDb:CODIGO_NIT, oD:oDlg:Update(), .t.)) } );
      SIZE 48,10 PIXEL UPDATE  RESOURCE "BUSCAR" ;
      WHEN oD:oArc:SECUENCIA == 0
   @ 40,110 SAY oGet[7] VAR oD:oNit:oDb:NOMBRE OF oD:oDlg PIXEL SIZE 100,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 28,200 SAY "Nro. Factura"     OF oD:oDlg RIGHT PIXEL SIZE 50,10
   @ 28,252 GET oGet[8] VAR oD:oArc:FACTURA  OF oD:oDlg ;
      VALID oD:Facturas( oD:oArc:lOK,oD:oArc:FACTURA,oD:aCab[13] );
      WHEN oD:oArc:SECUENCIA == 0 SIZE 40,10 PIXEL UPDATE
   @ 52, 00 SAY "SubTotal"       OF oD:oDlg RIGHT PIXEL SIZE 50,10
   @ 52, 52 SAY oD:oArc:SUBTOTAL OF oD:oDlg PICTURE "999,999,999.99" PIXEL SIZE 42,10;
      UPDATE COLOR nRGB( 255,0,128 )
   @ 52, 90 SAY "Total IVA"        OF oD:oDlg RIGHT PIXEL SIZE 50,10
   @ 52,142 GET oGet[09] VAR oD:oArc:TOTALIVA OF oD:oDlg PICTURE "999,999,999.99";
      PIXEL SIZE 42,10 UPDATE
   //   VALID oD:New( 10 )
   @ 52,200 SAY "Total Devolucion" OF oD:oDlg RIGHT PIXEL SIZE 50,10
   @ 52,252 GET oGet[10] VAR oD:oArc:TOTALFAC OF oD:oDlg PICTURE "999,999,999.99";
      SIZE 42,10 PIXEL UPDATE
   //   VALID oD:New( 12,oGet )

   @ 69, 06 LISTBOX oLbx FIELDS oD:oArd:CODIGO             ,;
                     LeerCodig( oD:oArd:CODIGO )           ,;
                     TRANSFORM( oD:oArd:CANTIDAD,"99,999.99" )    ,;
                     TRANSFORM( oD:oArd:PCOSTO  ,"99,999,999.99" ),;
                          aDev[ oD:oArd:CAUSADEV+1 ]        ;
      HEADERS "Código"+CRLF+"Artículo", "Descripción", "Cantidad",;
              "Precio"+CRLF+"Costo", "Causa";
      SIZES 400, 450 SIZE 290,90 ;
      OF oD:oDlg UPDATE PIXEL       ;
      ON DBLCLICK EVAL( aBarra[2] )
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:GoTop()
    oLbx:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:nHeaderHeight := 28
    oLbx:aColSizes   := {90,200,90,90,40}
    oLbx:aHjustify   := {2,2,2,2,2}       // .F. ó 0 => Derecha
    oLbx:aJustify    := {0,0,1,1,0}       // .T. ó 1 => Izquierda, 2 => Centro
    oLbx:ladjbrowse  := oLbx:lCellStyle  := .f.
    oLbx:ladjlastcol := .t.
    oLbx:bKeyDown := {|nKey| If(nKey == VK_ESCAPE, (oD:aCab[1] := 0, oGet[1]:SetFocus() ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(aBarra[1]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, EVAL(aBarra[2]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE             , EVAL(aBarra[4]),) ))) }
   MySetBrowse( oLbx,oD:oArd )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oD:oDlg ON INIT ;
  (oD:oDlg:Move(80,1), DefineBar( oD:oDlg,oLbx,aBarra ));
   VALID lSalir
oD:oDb:Destroy()
oD:oArc:Destroy()
oD:oArd:Destroy()
oD:oMvc:Destroy()
oD:oMvd:Destroy()
oApl:oEmp:Seek( {"empresa",oD:aCab[5]} )
nEmpresa( .f. )

RETURN

//------------------------------------//
CLASS TDevol FROM TMov

 DATA aCab, aCau, aCta, aDF, aPrv, aUM
 DATA nMed, nSubtotal, oCA, oArc, oArd, oDlg

 METHOD NEW( nFld,oGet ) Constructor
 METHOD Buscar( oLbx,oGet,lNew )
 METHOD Borrar( oLbx,oGet )
 METHOD Editar( oLbx,lNew )
 METHOD EditPVenta( oGet )
 METHOD Grabar( oLbx,lNew )
 METHOD Fechas( lOK,nMsg )
 METHOD Facturas( lNew,cFac,cFV )
 METHOD Mostrar()
 METHOD Graba( lG )
 METHOD ArmarLis()
ENDCLASS

//------------------------------------//
METHOD NEW( nFld,oGet ) CLASS TDevol
   LOCAL nB
If nFld # NIL
   If ::aCab[11]
      ::oArc:Update( .f.,1 )
      ::aCab[12] := .t.
   EndIf
Else
   oGet   := oApl:Abrir( "caddevov","nombre, fecha" )
   Super:New( ,oGet )
   oApl:oEmp:Seek( {"localiz",oApl:oEmp:TITULAR} )
   ::aCab := { 0,oApl:oEmp:TITULAR,0,1,oApl:oEmp:EMPRESA,1,0,0,0,"UN",.f.,.f.,"",.f.,.f.,0,0 }
   ::aCau := Buscar( {"clase","Devolucion"},"cadtipos",;
                      "nombre, tipo_ajust",2,"tipo" )
   ::aCta := Cuentas( 4,1 )
   ::aPrv := Privileg( "COMPRAS" )
   ::oArc := oApl:Abrir( "caddevoc","empresa, numero",,,10 )
   ::oArd := oApl:Abrir( "caddevod","empresa, numero",,,100 )
   ::oArd:Seek( {"empresa",oApl:nEmpresa,"numero",0} )
   ::oFte:oDb:Seek( {"fuente",4} )
   ::aCab[4] := Buscar( {"empresa",oApl:nEmpresa},"caddevoc","MAX(numero)",8,,4 ) + 1
   ::oCA  := TInv() ; ::oCA:New( ,.f. )
   ::aUM  := ACLONE( ::oCA:aMed )
   ::aOrden  := { {"Nombre",5},{"Factura" ,4} }
   ::bEditar := ::bNew := ::bVer := {|| MsgStop( "Solo para Ayuda" ) }
EndIf
RETURN .t.

//------------------------------------//
METHOD Buscar( oLbx,oGet,lNew ) CLASS TDevol
   LOCAL lSi := .f.
If lNew # NIL
   If (lSi := oApl:oInv:Seek( {"codigo",::oArd:CODIGO} ))
      AEVAL( ::aUM, { |x| oGet:Del(1) } )
      ::aUM := UMedidas( ::oCA:aMed,oApl:oInv:UNIDADMED,oApl:oInv:CODCON )
      AEVAL( ::aUM, { |x| oGet:Add( x[1] ) } )
      If lNew
         ::nMed := ArrayValor( ::aUM,oApl:oInv:UNIDADMED,,.t. )
         ::oArd:CANTIDAD := 1
         ::oArd:PCOSTO   := oApl:oInv:PCOSTO
      EndIf
      lNew := ::EditPVenta( ,16 )
      oLbx:Update()
   Else
      MsgStop( "Este Código NO EXISTE !!!" )
   EndIf
ElseIf Rango( ::aCab[1],0,::aCab[4] )
   If ::aCab[11]
      ::Graba( .f. )
   EndIf
   If !::oArc:Seek( {"empresa",oApl:nEmpresa,"numero",::aCab[1]} ) .AND. ::aCab[1] > 0
      MsgStop( "Esta Devolución NO EXISTE !!" )
   Else
      If ::oArc:lOK
         oApl:oNit:Seek( {"codigo_nit",::oArc:CODIGO_NIT} )
         ::aCab[02] := ArrayValor( oApl:aOptic,STR(::oArc:EMPRESA,2) )
         ::aCab[03] := oApl:oNit:CODIGO
         oApl:nEmpresa := ::oArc:EMPRESA
         oGet[3]:oJump := oLbx
         ::nSubtotal:= Buscar( {"empresa",oApl:nEmpresa,"numero",::aCab[1]},"caddevod","SUM(cantidad * pcosto)" )
      Else
         ::aCab[02] := oApl:oEmp:TITULAR
         ::oArc:FECHA := DATE()
         ::nSubtotal:= 0
      EndIf
    //::nSubtotal := ::oArc:SUBTOTAL
      ::oArd:Seek( {"empresa",oApl:nEmpresa,"numero",::aCab[1]} )
      ::oDlg:Update()
      ::aCab[11] := ::oArc:lOK
      ::aCab[12] := !(::oArc:COMPROBANT != 0)
      ::aCab[13] := ::oArc:FACTURA
      ::Fechas( .f. )
      ::oMvc:Seek( {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,"fuente",4,;
                    "comprobant",::oArc:COMPROBANT} )
      oLbx:Refresh()
      lSi := .t.
   EndIf
EndIf
RETURN lSi

//------------------------------------//
METHOD Borrar( oLbx,oGet ) CLASS TDevol
   LOCAL aBor
If ::aPrv[3] .AND. ::oArc:SECUENCIA > 0
   If oGet == NIL
      If MsgNoYes( "Este Código "+::oArd:CODIGO,"Elimina" )
         aBor := { ::oArd:CODIGO,-::oArd:CANTIDAD,::oArd:PCOSTO,::oArd:UNIDADMED,;
                   ::aCau[::oArd:CAUSADEV,2],.f. }
         If (aBor[6] := ::oArd:Delete( .t.,1 ))
            PListbox( oLbx,::oArd )
         EndIf
         If aBor[6]
            Actualiz( aBor[1],aBor[2],::oArc:FECHA,aBor[5],aBor[3],aBor[4] )
            oApl:oInv:Seek( {"codigo",aBor[1]} )
            ::aCab[8] := aBor[2]
            ::EditPVenta( ,16 )
            ::oArc:SUBTOTAL += (aBor[2] * aBor[3])
            ::Facturas()
         EndIf
      EndIf
   Else
      If Login( "Desea Anular esta Devolución" )
         ::oMvc:Seek( {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,"fuente",4,;
                       "comprobant",::oArc:COMPROBANT} )
         aBor := "empresa = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND ano_mes = " + xValToChar(oApl:cPer )   +;
            " AND control = " + LTRIM(STR(::oMvc:CONTROL))
         ::oMvd:dbEval( {|o| ::Avanza( ,o:CUENTA ), o:EMPRESA := -4               ,;
                             ::GrabaPago( o:CUENTA,::aTL[4],-::aTL[5],::aTL[6],1 ),;
                             Acumular( ::oMvc:ESTADO,o,3,3,.f.,.f. ) },aBor )
         Guardar( "UPDATE cgemovc SET estado = 2 WHERE " + aBor,"cgemovc" )
         ::oArd:dbEval( {|o| Actualiz( o:CODIGO,-o:CANTIDAD,::oArc:FECHA,::aCau[o:CAUSADEV,2],;
                                       o:PCOSTO,o:UNIDADMED ),o:Delete( .f.,1 ) } )
         ::aCab[11] := .f.
         ::oArc:SUBTOTAL := ::oArc:TOTALIVA  := 0
         ::oArc:TOTALFAC := ::oArc:SECUENCIA := ::nSubtotal := 0
         Guardar( ::oArc,.f.,.f. )
         oGet[1]:SetFocus()
      EndIf
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Editar( oLbx,lNew ) CLASS TDevol
   LOCAL oDlg, cTit := "Modificando Devolución"
   LOCAL bGrabar, oGet := ARRAY(8), oE := Self
lNew := If( ::oArc:SECUENCIA == 0, .t., lNew )
If lNew
   cTit    := "Nueva Devolución"
   bGrabar := {|| ::Grabar( oLbx,lNew )         ,;
                  ::oArd:xBlanK()               ,;
                  oDlg:Update(), oDlg:SetFocus() }
   oLbx:GoBottom() ; ::oArd:xBlank()
Else
   If !::aPrv[2]
      MsgStop( "Este Registro no se Puede Modificar","Lo Siento" )
      RETURN NIL
   EndIf
   bGrabar := {|| ::Grabar( oLbx,lNew ), oLbx:Refresh(), oDlg:End() }
   ::aCab[06]:= ::aCau[::oArd:CAUSADEV,2]
   ::aCab[07]:= ::oArd:CODIGO
   ::aCab[08]:= ::oArd:CANTIDAD
   ::aCab[09]:= ::oArd:PCOSTO
   ::aCab[10]:= ::oArd:UNIDADMED
EndIf
 ::nMed := ArrayValor( ::aUM,::oArd:UNIDADMED,,.t. )
oApl:oInv:Seek( {"codigo",::oArd:CODIGO} )
 ::EditPVenta( ,17 )

DEFINE DIALOG oDlg TITLE cTit FROM 0, 0 TO 13,50
   @ 02,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 66,10
   @ 02,70 BTNGET oGet[1] VAR oE:oArd:CODIGO OF oDlg PICTURE "@!";
      VALID oE:Buscar( oDlg,oGet[5],lNew );
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR" ;
      ACTION EVAL({|| If(oE:oCA:Mostrar(), (oE:oArd:CODIGO := oE:oCA:oDb:CODIGO,;
                        oGet[1]:Refresh() ), )})
   @ 14,50 SAY    oGet[2] VAR oApl:oInv:DESCRIP OF oDlg PIXEL SIZE 120,10;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 26,00 SAY "Cantidad" OF oDlg RIGHT PIXEL SIZE 66,10
   @ 26,70 GET oGet[3] VAR ::oArd:CANTIDAD OF oDlg PICTURE "9,999.99";
      VALID {|| If( ::oArd:CANTIDAD >  0, .t.                       ,;
          (MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>"), .f.)) };
      SIZE 40,10 PIXEL UPDATE
   @ 38,00 SAY "Precio Costo"  OF oDlg RIGHT PIXEL SIZE 66,10
   @ 38,70 GET oGet[4] VAR ::oArd:PCOSTO   OF oDlg PICTURE "999,999,999.99";
      VALID ::EditPVenta( oGet )           SIZE 40,10 PIXEL UPDATE
   @ 50,00 SAY "Unidad Medida" OF oDlg RIGHT PIXEL SIZE 66,10
   @ 50,70 COMBOBOX oGet[5] VAR ::nMed ITEMS ArrayCol( ::aUM,1 ) SIZE 68,99 ;
      OF oDlg PIXEL UPDATE
   @ 62,00 SAY "Causa Devolución" OF oDlg RIGHT PIXEL SIZE 66,10
   @ 62,70 COMBOBOX oGet[6] VAR ::oArd:CAUSADEV ITEMS ArrayCol( ::aCau,1 );
      SIZE 68,99 OF oDlg PIXEL UPDATE

   @ 76, 70 BUTTON oGet[7] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION ;
      (If( EMPTY(::oArd:CODIGO) .OR. ::oArd:CANTIDAD <= 0              ,;
         (MsgStop("Imposible grabar este Código"), oGet[1]:SetFocus() ),;
         ( oGet[7]:Disable(), ::oArd:UNIDADMED := ::aUM[::nMed,2]      ,;
           EVAL( bGrabar ), oGet[7]:Enable() ))) PIXEL
   @ 76,120 BUTTON oGet[8] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL ;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
   If !::aPrv[1]
      oGet[7]:Disable()
   EndIf
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
 oLbx:SetFocus()
RETURN NIL

//------------------------------------//
METHOD EditPVenta( oGet,nC ) CLASS TDevol
If oGet == NIL
   ::aCab[nC] := If( oApl:oEmp:TREGIMEN == 1 .OR. !oApl:oInv:INDIVA, 0,;
                 If( oApl:oInv:IMPUESTO == 0, ::aDF[1],;
                     ROUND(oApl:oInv:IMPUESTO/100,2) )) + 1
Else
   If ::oArd:CANTIDAD > 1
      If !MsgYesNo( "Este es el Precio Unitario","DIVIDIR" )
         ::oArd:PCOSTO := ROUND( ::oArd:PCOSTO / ::oArd:CANTIDAD,2 )
      EndIf
   EndIf
   If oApl:oInv:INDIVA .AND. oApl:oEmp:TREGIMEN >= 2
      If MsgYesNo( "Precio con IVA incluido","I.V.A."+STR(::aCab[16],6,2) )
         ::oArd:PCOSTO := ROUND( ::oArd:PCOSTO / ::aCab[16],2 )
      EndIf
   EndIf
   oGet[4]:Refresh()
EndIf
RETURN .t.

//------------------------------------//
METHOD Grabar( oLbx,lNew ) CLASS TDevol

If ::aCab[1] == 0
   ::oArc:EMPRESA := oApl:nEmpresa
   ::oArc:Append( .t. )
   ::aCab[1] := ::oArc:NUMERO
   ::aCab[4] := ::aCab[1] + 1
   ::aCab[11]:= .t.
EndIf
If lNew
   ::oArc:SECUENCIA ++
   ::oArc:SUBTOTAL  += ROUND( ::oArd:CANTIDAD * ::oArd:PCOSTO,0 )
   ::oArd:EMPRESA   := oApl:nEmpresa
   ::oArd:NUMERO    := ::aCab[1]
   ::oArd:SECUENCIA := ::oArc:SECUENCIA
   ::oArd:Append( .t. )
   ::oArc:Update( .f.,1 )
   Actualiz( ::oArd:CODIGO,::oArd:CANTIDAD,::oArc:FECHA,::aCau[::oArd:CAUSADEV,2],;
             ::oArd:PCOSTO,::oArd:UNIDADMED )
   PListbox( oLbx,::oArd )
Else
   ::oArc:SUBTOTAL  += ROUND( ::oArd:CANTIDAD * ::oArd:PCOSTO - ::aCab[08] * ::aCab[09],0 )
   ::oArc:TOTALIVA  -= ROUND( ::aCab[08] * ::aCab[09] * (::aCab[17]-1),0 )
   ::oArc:Update( .f.,1 )
   If ::aCab[07] # ::oArd:CODIGO .OR. ::aCab[10] # ::oArd:UNIDADMED .OR.;
      ::aCab[06] # ::oArd:CAUSADEV
      Actualiz( ::aCab[07],-::aCab[08],::oArc:FECHA,::aCab[06],::aCab[09],::aCab[10] )
      ::aCab[08] := 0
   EndIf
   ::oArd:Update( .t.,1 )
   Actualiz( ::oArd:CODIGO,::oArd:CANTIDAD-::aCab[08],::oArc:FECHA,::aCau[::oArd:CAUSADEV,2],;
             ::oArd:PCOSTO,::oArd:UNIDADMED )
EndIf
::aCab[08]:= ::oArd:CANTIDAD
::Facturas()
::oDlg:Update()
RETURN NIL

//------------------------------------//
METHOD Fechas( lOK,nMsg ) CLASS TDevol
   LOCAL aFec, nDev, lSI := .t.
If lOK
   aFec := { ::oArc:XColumn( 3 ),::oArc:FECHA,oApl:cPer,::lCierre,.t.,;
             "empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
        " AND ano_mes = " + xValToChar(oApl:cPer )    +;
        " AND control = " + LTRIM(STR(::oMvc:CONTROL)) }
   If (aFec[5] := ::Fechas( .f.,1 ))
      If (aFec[3] == LEFT( DTOS(aFec[2]),6 ))
         Guardar( "UPDATE cgemovc SET fecha = " + xValToChar(aFec[2]) +;
                  " WHERE " + aFec[6],"cgemovc" )
         Guardar( ::oArc,.f.,.f. )
      ElseIf MsgYesNo( "QUIERE HACER EL CAMBIO","VA A CAMBIAR DE MES" )
         ::oArd:dbEval( {|o| nDev := ::aCau[o:CAUSADEV,2]                                      ,;
                             Actualiz( o:CODIGO,-o:CANTIDAD,aFec[1],nDev,o:PCOSTO,o:UNIDADMED ),;
                             Actualiz( o:CODIGO, o:CANTIDAD,aFec[2],nDev,o:PCOSTO,o:UNIDADMED ) } )
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
      ::oArc:FECHA := aFec[1]
      oApl:cPer := aFec[3]
      ::lCierre := aFec[4]
   EndIf
ElseIf EMPTY( ::oArc:FECHA )
   MsgStop( "No puede ir en Blanco","FECHA" )
   lSI := .f.
Else
   oApl:cPer := NtChr( ::oArc:FECHA,"1" )
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
METHOD Facturas( lNew,cFac,cFV ) CLASS TDevol
   LOCAL cQry, hRes, nR, lOK := .t.
If lNew == NIL
   If oApl:oEmp:TREGIMEN > 1
       //::oArc:TOTALIVA := ROUND( ::oArc:SUBTOTAL * ::aDF[1],0 )
         ::oArc:TOTALIVA += ROUND( ::aCab[08] * ::oArd:PCOSTO * (::aCab[16]-1),0 )
      If ::aCab[14]
         ::oArc:TOTALRET := ROUND( ::oArc:SUBTOTAL * ::aDF[3],0 )
      EndIf
      If ::aCab[15]
         ::oArc:TOTALICA := ROUND( ::oArc:SUBTOTAL * ::aDF[4],0 )
      EndIf
   EndIf
   nR := ::oArc:SUBTOTAL + ::oArc:TOTALIVA
   If ::oArc:TOTALFAC  # nR
      ::oArc:TOTALFAC := nR
   EndIf
   Guardar( ::oArc,.f.,.f. )
ElseIf lNew
   If cFac # cFV
      ::oArc:Update( .f.,1 )
   EndIf
Else
   If ::aCXP[1] # "NADA"
      cQry := "SELECT 1 FROM ctasxpc " +;
              "WHERE empresa    = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND numero     = " + xValToChar( cFac )       +;
               " AND codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT))
      If Buscar( cQry,"CM",,8,,4 ) == 0
         MsgStop( "Factura no Existe",cFac )
         RETURN .f.
      EndIf
   EndIf
   cQry := "SELECT totalret, totalica FROM cadartic " +;
           "WHERE factura = "    + xValToChar( cFac ) +;
            " AND codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT))
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nR   := MSNumRows( hRes )
   While nR > 0
      cQry := MyReadRow( hRes )
      AEVAL( cQry,{|xV,nP| cQry[nP] := MyClReadCol( hRes,nP ) } )
      ::aCab[14] := (cQry[1] != 0)
      ::aCab[15] := (cQry[2] != 0)
      nR --
   EndDo
   MSFreeResult( hRes )
EndIf
RETURN lOK

//------------------------------------//
METHOD Mostrar() CLASS TDevol
   LOCAL bHacer, nOrd, oDlg, oM := Self
   LOCAL lReturn := .f.
 ::oDb:cWhere := " empresa = " + LTRIM(STR(oApl:nEmpresa))
bHacer := {||lReturn := ::lBuscar := .t., oDlg:End()}
nOrd   := ::Ordenar( 1 )

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE "Ayuda de las Devoluciones"
   @ 1.5, 0 LISTBOX ::oLbx FIELDS ;
                    ::oDb:NOMBRE  , ::oDb:FACTURA,;
                    DTOC(::oDb:FECHA);
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
METHOD Graba( lG ) CLASS TDevol
   LOCAL aCta := {}, aInf, cSql, hRes, nE, nK
If ::oArc:SECUENCIA > 0 .AND. oApl:oNit:CODIGO # 2 .AND.;
  (::oArc:COMPROBANT == 0 .OR. ::oArc:SUBTOTAL # ::nSubtotal .OR. ::aCab[12] .OR. lG)
 //AEVAL( ::aCta, {| x | AADD( aCta, { x[1],"","","","",0,0,0,0 } ) } )
      ::aCta[1,7] := ::oArc:SUBTOTAL
   If oApl:oEmp:TREGIMEN == 1
      aCta := { {::aCta[1,1],"","","","",0,::aCta[1,7]    ,0,0,0 },;
                {::aCta[5,1],"","","","",::oArc:TOTALFAC,0,0,0,0 } }
   Else
      ::aCta[4,07] := ::oArc:TOTALIVA
      ::aCta[4,09] := ROUND( ::aDF[1] * 100,2 )
      ::aCta[5,06] := ::oArc:TOTALFAC - ::oArc:TOTALRET - ::oArc:TOTALICA
      ::aCta[6,06] := ::oArc:TOTALRET
      ::aCta[6,09] := ::aDF[3] * 100
      ::aCta[7,06] := ::oArc:TOTALICA
      ::aCta[7,09] := ::aDF[4] * 1000
      ::aCta[6,10] := ::aCta[7,10] := (::oArc:TOTALFAC - ::oArc:TOTALIVA)
      If oApl:oEmp:PRINTIVA
         ::aCta[4,7] := 0
         AEVAL( ::aCta, {| x | AADD( aCta, { x[1],"","","","",x[6],x[7],x[8],x[9],x[10] } ) },1,4 )
         cSql := "SELECT d.cantidad * d.pcosto, i.impuesto "+;
                 "FROM caddevod d LEFT JOIN cadinven i "    +;
                  "USING( codigo ) "                        +;
                 "WHERE i.impuesto > 0"                     +;
                  " AND d.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
                  " AND d.numero  = " + LTRIM(STR(::aCab[1]))
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
            aCta[nK,07] += ROUND( aInf[1] * aInf[2] / 100,2 )
            aCta[nK,10] += aInf[1]
            nE --
         EndDo
         MSFreeResult( hRes )
         nE := ::oArc:TOTALIVA
         AEVAL( aCta, {| x | nE -= x[7] },4 )
         If nE # 0
            If aCta[04,7] > 0
               aCta[04,7] += nE
            Else
               nK := LEN( aCta )
               aCta[nK,7] += nE
            EndIf
         EndIf
         AEVAL( ::aCta, {| x | AADD( aCta, { x[1],"","","","",x[6],x[7],x[8],x[9],x[10] } ) },5,3 )
      Else
         AEVAL( ::aCta, {| x | AADD( aCta, { x[1],"","","","",x[6],x[7],x[8],x[9],x[10] } ) },1,7 )
      EndIf
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
      ::oMvc:EMPRESA   := oApl:nEmpresa ; ::oMvc:ANO_MES  := oApl:cPer
      ::oMvc:FECHA     := ::oArc:FECHA  ; ::oMvc:FUENTE   := 4
      ::oMvc:COMPROBANT:= SgteCntrl( "compro_prv",oApl:cPer,.t. )
      ::oMvc:CONCEPTO  := "FACTURA # " + TRIM(::oArc:FACTURA) + " DEVOL. # " + LTRIM(STR(::oArc:NUMERO))
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
               aCta[nE,nK+1] := DTOC(::oArc:FECHA)
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
      MsgInfo( "Devolución CONTABILIZADA","LISTO" )
   EndIf
EndIf
::nSubtotal := ::oArc:SUBTOTAL
RETURN NIL

//------------------------------------//
METHOD ArmarLis() CLASS TDevol
   LOCAL nOpc := 1
If ::aCab[1] == 0
   MsgStop( "Grabar la Devolución","Primero tienes que" )
   RETURN NIL
EndIf
MsgGet( "Listar Devolución","1_Movto Contable, 2_Codigos",@nOpc )
If nOpc == 1
   If ::oMvc:CONTROL > 0 .AND. ::oMvc:ESTADO # 2
      CgeLista( ::oMvc:CONTROL,,::oFte:oDb:DESCRIPCIO )
   EndIf
ElseIf nOpc == 2
   InoLista( 2,{ ::oArc:FECHA,::oArc:FECHA,"C",::aCab[1],"S",oApl:nTFor,.t.,"" } )
EndIf
RETURN NIL

//------------------------------------//
FUNCTION UMedidas( cUnd,cSep,nCod )
   LOCAL hRes
If nCod # NIL
   If nCod > 1
      hRes := ASCAN( cUnd, { |aX| aX[2] == cSep } )
      cSep := ACLONE( cUnd )
      cUnd := Buscar( "SELECT b.desplegar, b.retornar "+;
                      "FROM cadcombo b, convertir c "  +;
                      "WHERE b.tipo   = 'MEDIDAS'"     +;
                       " AND c.de     = b.retornar "   +;
                       " AND c.codcon = " + LTRIM(STR(nCod)),"CM",,9 )
      AADD( cUnd,{ cSep[hRes,1],cSep[hRes,2] } )
   EndIf
Else
   If cUnd # "UN"
      cUnd := "SELECT desplegar FROM cadcombo "+;
              "WHERE tipo     = 'MEDIDAS'"     +;
               " AND retornar = '" + cUnd + "'"
      hRes := If( MSQuery( oApl:oMySql:hConnect,cUnd ) ,;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      If MSNumRows( hRes ) == 0
         cUnd := ""
      Else
         cUnd := MyReadRow( hRes )
         cUnd := TRIM( cUnd[1] ) + cSep
      EndIf
      MSFreeResult( hRes )
   Else
      cUnd := ""
   EndIf
EndIf
RETURN cUnd