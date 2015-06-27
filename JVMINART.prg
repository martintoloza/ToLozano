// Programa.: INOINART.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Mantenimiento de las Comparas al Inventario.
#include "FiveWin.ch"
#include "TSBrowse.ch"
#include "btnget.ch"

MEMVAR oApl

#define CLR_PINK  nRGB( 128, 150, 150)
#define CLR_NBLUE nRGB( 255, 255, 235)

PROCEDURE InoinArt()
   LOCAL oLbd, oLbx, oGet := ARRAY(11), lSalir := .f.
   LOCAL aBarra, oC
oC  := TCompra() ;  oC:New()
oC:oNit:oDb:xBlank()
aBarra := { {|| oC:Editar( oLbx,.t. ) }, {|| oC:Editar( oLbx,.f. ) },;
            {|| oC:Graba( .t. ) }      , {|| oC:Borrar( oLbx ), oGet[10]:Refresh() },;
            {|| oC:ArmarLis()          ,   oC:aCab[1] := 0, oGet[1]:SetFocus() },;
            {|| If( oC:aCab[11],  oC:Graba(.f.), ), lSalir := .t., oC:oDlg:End() } ,;
            {|| oC:Borrar( oLbx,oGet ) } }
DEFINE DIALOG oC:oDlg FROM 0, 0 TO 376, 580 PIXEL;
   TITLE "Ingresos de Compras al Inventario"
   @ 16, 00 SAY "Nro. de Ingreso" OF oC:oDlg RIGHT PIXEL SIZE 60,10
   @ 16, 62 BTNGET oGet[1] VAR oC:aCab[1] OF oC:oDlg  PICTURE "999999" ;
      ACTION EVAL({|| If( oC:Mostrar(), ( oC:aCab[1] := oC:oDb:INGRESO,;
                          oGet[1]:Refresh() ), ) })                    ;
      VALID oC:Buscar( oLbx,oGet,oLbd )                                ;
      SIZE 38,10 PIXEL UPDATE  RESOURCE "BUSCAR"
   @ 16,110 SAY "Sgte. Ingreso" + STR( oC:aCab[4],6 ) OF oC:oDlg PIXEL SIZE 70,10;
      UPDATE COLOR nRGB( 255,0,0 )
   @ 28, 00 SAY "Empresa" OF oC:oDlg RIGHT PIXEL SIZE 60,10
   @ 28, 62 GET oGet[2] VAR oC:aCab[2] OF oC:oDlg PICTURE "@!"     ;
      VALID EVAL( {|| If( oApl:oEmp:Seek( {"localiz",oC:aCab[2]} ),;
                        ( oApl:nEmpresa := oApl:oEmp:EMPRESA      ,;
                          oC:Facturas() , .t. )                   ,;
                        (MsgStop("Esta Empresa NO EXISTE"), .f.) ) } );
      WHEN oC:aPrv[2] SIZE 24,10 PIXEL UPDATE
   @ 28,114 SAY oC:oArc:COMPROBANT OF oC:oDlg PIXEL SIZE 30,10;
      UPDATE COLOR nRGB( 0,128,192 )
   @ 40, 00 SAY "Nit Proveedor" OF oC:oDlg RIGHT PIXEL SIZE 60,10
   @ 40, 62 BTNGET oGet[3] VAR oC:aCab[3] OF oC:oDlg PICTURE "9999999999";
      ACTION EVAL({|| If(oC:oNit:Mostrar( ,,oC:aCab[3] ), (oC:aCab[3] := ;
                         oC:oNit:oDb:CODIGO,  oGet[3]:Refresh() ),) })   ;
      VALID EVAL( {|| If( oC:oNit:Buscar( oC:aCab[3],,.t. )             ,;
                        ( oC:aCab[17] := oC:Fechas( .f.,2 )             ,;
                    oC:aCab[14] := oC:oNit:oDb:CODIGO_NIT, oC:oDlg:Update(),;
                If( oC:oArc:lOK .AND. oC:oArc:CODIGO_NIT # oC:aCab[14]  ,;
                  ( oC:oArc:CODIGO_NIT := oC:aCab[14]                   ,;
                    oC:oArc:Update( .f.,1 ), MsgInfo("HECHO EL CAMBIO") ,;
                    oC:aCab[11] := .t., oGet[3]:oJump := oLbx), ) ,.t. ),;
               (If( MsgYesNo( "Desea ingresarlo","Este Nit no Existe" ) ,;
                    oC:oNit:Editar( ,.t.,,oC:aCab[3] ), ),.f.) ) } )     ;
      SIZE 48,10 PIXEL UPDATE  RESOURCE "BUSCAR"
   @ 40,114 SAY oGet[4] VAR oC:oNit:oDb:NOMBRE OF oC:oDlg PIXEL SIZE 130,12;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 16,172 SAY "Fecha [DD.MM.AA]" OF oC:oDlg RIGHT PIXEL SIZE 60,10
   @ 16,236 GET oGet[5] VAR oC:oArc:FECINGRE OF oC:oDlg ;
      VALID oC:Fechas( oC:oArc:lOK,1 ) ;
      WHEN oC:aPrv[2] SIZE 40,10 PIXEL UPDATE
   @ 28,172 SAY     "Nro. Factura" OF oC:oDlg RIGHT PIXEL SIZE 60,10
   @ 28,236 GET oGet[6] VAR oC:oArc:FACTURA  OF oC:oDlg           ;
      VALID oC:Facturas( oC:oArc:lOK,oC:oArc:FACTURA,oC:aCab[13] );
      SIZE 40,10 PIXEL UPDATE
   @ 52,172 SAY "Total Factura"    OF oC:oDlg RIGHT PIXEL SIZE 60,10
   @ 52,236 GET oGet[7] VAR oC:oArc:TOTALFAC OF oC:oDlg PICTURE "999,999,999.99";
      VALID oC:BuscaDet( .t.,oLbd,6 );
      SIZE 42,10 PIXEL UPDATE
   @ 64,172 SAY "Factor CIF"       OF oC:oDlg RIGHT PIXEL SIZE 60,10
   @ 64,236 GET oGet[8] VAR oC:oArc:CIF OF oC:oDlg PICTURE "999,999.99";
      VALID oC:New( 15 ) ;
      SIZE 42,10 PIXEL UPDATE
   @ 76,172 SAY "Factor de Venta"  OF oC:oDlg RIGHT PIXEL SIZE 60,10
   @ 76,236 GET oGet[9] VAR oC:oArc:FFV OF oC:oDlg PICTURE "999,999.99";
      VALID oC:New( 15 ) ;
      SIZE 42,10 PIXEL UPDATE
   @ 64,122 BUTTON oGet[11] PROMPT "Dscto Condicionado" SIZE 52,12 OF oC:oDlg;
      ACTION ( oGet[11]:Disable(), oC:Dsctos( oLbd,oC:oArc:ROW_ID ),;
               oGet[11]:Enable() , oGet[11]:oJump := oLbd );
      WHEN !EMPTY(oApl:oEmp:NIIF) .AND. oApl:cPer >= oApl:oEmp:NIIF PIXEL
   @ 88,194 SAY "SubTotal"    OF oC:oDlg RIGHT PIXEL SIZE 40,10
   @ 88,236 SAY oGet[10] VAR oC:oArc:SUBTOTAL OF oC:oDlg PICTURE "999,999,999.99" PIXEL SIZE 42,10;
      UPDATE COLOR nRGB( 255,0,128 )

   @ 52.0,06 BROWSE oLbd SIZE 110,40 PIXEL OF oC:oDlg CELLED;
      COLORS CLR_BLACK, CLR_NBLUE
   oLbd:SetArray( oC:aDC )
   oLbd:nFreeze     := 1
   oLbd:nRowPos     := oLbd:nAt   := 4
   oLbd:nColPos     := oLbd:nCell := 2
   oLbd:nHeightCell += 4
   oLbd:nHeightHead += 4
   oLbd:bKeyDown := {|nKey| If( nKey== VK_TAB, oLbd:oJump := oLbx, ) }
   oLbd:SetAppendMode( .f. )

   ADD COLUMN TO BROWSE oLbd DATA ARRAY ELEMENT 2;
       TITLE "Cuenta"                            ;
       SIZE  100;
       3DLOOK TRUE, TRUE, TRUE;    // Celda, Titulo, Footers
       MOVE DT_MOVE_NEXT;          // Cursor pasa a la Sig.Columna editable
       ALIGN DT_LEFT, DT_CENTER    // Celda, Titulo, Footer
   ADD COLUMN TO BROWSE oLbd DATA ARRAY ELEMENT 4;
       TITLE "Valor"       PICTURE "999,999,999" ;
       SIZE  94 EDITABLE;          // Esta columna es editable
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER;
       POSTEDIT { |uVar| If( oLbd:lChanged, oC:BuscaDet( .t.,oLbd,oLbd:nAt ), ) };
       WHEN oC:BuscaDet( .f.,oLbd,oLbd:nAt )
   oLbd:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbd:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color
/*
   REDEFINE GET oGet[06] VAR oC:oArc:TOTALIVA ID 16 OF oDlg PICTURE "999,999,999.99";
      VALID oC:New( 10 ) UPDATE
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
*/
   @ 100,06 LISTBOX oLbx FIELDS oC:oArd:CODIGO             ,;
                     LeerCodig( oC:oArd:CODIGO )           ,;
                     TRANSFORM( oC:oArd:CANTIDAD,   "999,999.99" ),;
                     TRANSFORM( oC:oArd:PCOSTO  ,"99,999,999.99" ),;
                     TRANSFORM( oC:oArd:PPUBLI  ,"99,999,999.99" ) ;
      HEADERS "Código"+CRLF+"Artículo", "Descripción", "Cantidad",;
              "Precio"+CRLF+"Costo", "Precio"+CRLF+"Público"      ;
      SIZES 400, 450 SIZE 280,86  ;
      OF oC:oDlg UPDATE PIXEL     ;
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
    oLbx:ladjbrowse  := oLbx:lCellStyle  := .f.
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
ACTIVATE DIALOG oC:oDlg ON INIT ;
  ( oC:oDlg:Move(80,1), DefineBar( oC:oDlg,oLbx,aBarra ) );
   VALID lSalir
// oC:aCab[6] := oC:oDlg);
oC:oDb:Destroy()
oC:oArc:Destroy()
oC:oArd:Destroy()
oC:oArf:Destroy()
oC:oMvc:Destroy()
oC:oMvd:Destroy()
oApl:oEmp:Seek( {"empresa",oC:aCab[5]} )
nEmpresa( .f. )

RETURN
/*
CREATE TABLE `ctasfase` (
  `row_id` int(11) NOT NULL AUTO_INCREMENT,
  `empresa` int(2) NOT NULL DEFAULT '0',
  `fuente` int(2) NOT NULL DEFAULT '0',
  `orden` smallint(2) NOT NULL DEFAULT '1',
  `cuenta` varchar(10) NOT NULL DEFAULT '',
  `nombre` varchar(30) NOT NULL DEFAULT '',
  `codigo_nit` int(6) DEFAULT '0',
  `editar` tinyint(1) DEFAULT '0',
  `db_cr` smallint(1) NOT NULL DEFAULT '1',
  `rutina` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`row_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

INSERT INTO ctasfase
(empresa, fuente, orden, cuenta, nombre, codigo_nit)
SELECT e.empresa, e.fuente, e.orden, e.cuenta, e.nombre, e.codigo_nit
FROM cgcuenta e

CREATE TABLE `comprasd` (
  `row_id` int(11) NOT NULL auto_increment,
  `comprasc_id` int(11) unsigned NOT NULL,
  `orden` smallint(2) default NULL,
  `valor` double(12,2) default NULL,
  PRIMARY KEY  (`row_id`),
  KEY `comprasd_FKIndex1` (`comprasc_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1;

INSERT INTO comprasd (comprasc_id, orden, valor)
SELECT c.comprasc_id, 2, c.totalfle
FROM cadartic c
WHERE c.totalfle > 0

CREATE TABLE `comprasf` (
  `row_id` int(11) unsigned NOT NULL auto_increment,
  `comprasc_id` int(11) unsigned NOT NULL,
  `fecha` date NOT NULL,
  `dscto` double(11,2) NOT NULL,
  `dscto_us` double(11,2) default NULL,
  `ptaje` double(6,2) NOT NULL,
  PRIMARY KEY  (`row_id`),
  KEY `comprasf_FKIndex1` (`comprasc_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
*/

//------------------------------------//
CLASS TCompra FROM TMov

 DATA aCab, aDC, aDF, aPrv, cBus, nMed, nSubtotal
 DATA oArc, oArd, oCA, oDlg

 METHOD NEW( nFld,oGet ) Constructor
 METHOD Buscar( oLbx,oGet,oLbd )
 METHOD BuscaDet( lEdit,oLbd,nA )
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
   If ::aCab[11]
      ::oArc:Update( .f.,1 )
      ::aCab[12] := .t.
   EndIf
Else
   oGet   := oApl:Abrir( "cadartiv","nombre, fecingre" )
   Super:New( ,oGet )
   oApl:oEmp:Seek( {"localiz",oApl:oEmp:TITULAR} )
   ::oFte:oDb:Seek( {"fuente",4} )
   ::aCab := { 0,oApl:oEmp:TITULAR,0,oApl:oEmp:NUMINGRESO + 1,;
               oApl:oEmp:EMPRESA,"",0,0,0,"UN",.f.,.f.,"",0,.f.,0,.t. }
   ::aCab[4] := SgteNumero( "NUMINGRESO",oApl:nEmpresa,.f. )
   ::aMov[2] := 4
   ::aMov[13]:= ::oFte:oDb:CONTADOR
 //::aMov[13]:= Buscar( {"fuente",::aMov[2]},"cgefntes","contador",8,,1 )
   ::aDC  := Cuentas( 4 )
   ::aPrv := Privileg( "COMPRAS" )
   ::cBus := ""
   ::oArc := oApl:Abrir( "cadartic","ingreso",.t.,,10 )
   ::oArd := oApl:Abrir( "cadartid","ingreso",,,100 )
   ::oArf := oApl:Abrir( "comprasf","fecha",.t.,,10 )
   ::oCA  := TInv() ; ::oCA:New( ,.f. )
   ::aOrden  := { {"Nombre",5},{"Factura" ,4} }
   ::bEditar := ::bNew := ::bVer := {|| MsgStop( "Solo para Ayuda" ) }
   ::oArd:Seek( { "ingreso",0 } )
EndIf
RETURN .t.

//------------------------------------//
METHOD Buscar( oLbx,oGet,oLbd ) CLASS TCompra
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
//  (::oArc:SUBTOTAL # ::nSubtotal .OR. ::aCab[12])
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
      ::oDlg:Update()
      ::aCab[11] := ::oArc:lOK
      ::aCab[12] := !(::oArc:COMPROBANT != 0)
      ::aCab[13] := ::oArc:FACTURA
      ::aMov[03] := ::oArc:COMPROBANT
      ::Fechas( .f.,0 )
      ::oMvc:Seek( {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,"fuente",4,;
                    "comprobant",::oArc:COMPROBANT} )
      ::aDC      := Detalles( ::aDC,::oArc:ROW_ID,.f. )
      oLbd:Refresh() ; oLbx:Refresh()
      lSi := .t.
   EndIf
EndIf
RETURN lSi

//------------------------------------//
METHOD BuscaDet( lEdit,oLbd,nA ) CLASS TCompra
   LOCAL nB
If lEdit
   If oApl:oEmp:TREGIMEN > 1  .AND. (nA == 4 .OR. nA == 6)
         nB := ::oArc:TOTALFAC - ::aDC[4,4]
      If !oApl:oNit:RETENEDOR
         If nB >= ::aDF[2]
            //Retencion (TOTALRET)
            ::aDC[6,4] := ROUND( nB * ::aDF[3],0 )
         EndIf
         If ::oArc:FECINGRE >= CTOD("01.05.2013") .AND.;
            ::oArc:FECINGRE <= CTOD("31.08.2013") .AND. ::aCab[17]
            //Cree      (TOTALCRE)
            ::aDC[8,4] := ROUND( nB * If( oApl:oNit:PCREE > 0,;
                                 oApl:oNit:PCREE/100, ::aDF[9] ),0 )
         EndIf
      EndIf
      If !oApl:oNit:GRANCONTR .AND. nB >= ::aDF[2]
            //Ica       (TOTALICA)
         ::aDC[7,4] := ROUND( nB * If( oApl:oNit:PICA > 0, oApl:oNit:PICA/1000, ::aDF[4] ),0 )
          //::oArc:RETIVA   := ROUND( ::aM[10]* ::aDF[5],0 )
      EndIf
   EndIf
   If ::aCab[11]
      ::aCab[12] := .t.
      If nA == 6
         ::oArc:Update( .f.,1 )
         oLbd:Refresh()
      EndIf
      ::aDC := Detalles( ::aDC,::oArc:ROW_ID,.t. )
   EndIf
Else
   If ::aDC[nA,7]
      If (nA == 6 .AND. oApl:oNit:RETENEDOR) .OR.;
         (nA == 7 .AND. oApl:oNit:GRANCONTR)
         //6_Retencion, 7_ICA
         lEdit := .f.
      Else
         lEdit := .t.
      EndIf
   Else
      MsgStop( "Este Registro no se Puede Modificar","Lo Siento" )
   EndIf
EndIf
RETURN lEdit
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
         // If !oApl:oEmp:TACTUCON
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
   ::aDC     := Detalles( ::aDC,::oArc:ROW_ID,.t. )
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
 ::oDlg:Update()
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
//         If oApl:oEmp:TACTUCON
//            ::oArc:CONTABIL := .t.
//            Guardar( ::oArc,.f.,.f. )
//         Else
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
         ::oDlg:Update()
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
   ::aCab[6] := {|nX,nVal| If( nX == 1,;
                             ( nE := nVal, nK := 0),;
                             ( nK := nVal, nE := 0) ) }
    ::aDC[1,4] := ::oArc:SUBTOTAL - ::aDC[9,4]
   If oApl:oEmp:TREGIMEN == 1
      aCta := { {::aDC[1,1],"","","","",::aDC[1,4]     ,0,0,0,0 },;
                {::aDC[2,1],"","","","",::aDC[2,4]     ,0,0,0,0 },;
                {::aDC[3,1],"","","","",0              ,0,0,0,0 },;
                {::aDC[5,1],"","","","",0,::oArc:TOTALFAC,0,0,0 },;
                {::aDC[9,1],"","","","",::aDC[9,4]     ,0,0,0,0 } }
   Else
      ::aDC[4,5] := ROUND( (::aDF[1]-1) * 100,2 )  //IVA
      ::aDC[5,4] := ::oArc:TOTALFAC - ::aDC[6,4] - ::aDC[7,4] - ::aDC[8,4]
      ::aDC[6,5] := ::aDF[3] * 100                 //Retencion
      ::aDC[7,5] := ::aDF[4] * 1000                //ICA
      ::aDC[8,5] := ::aDF[9] * 100                 //CREE
      ::aDC[6,6] := ::aDC[7,6] := ::aDC[8,6] := (::oArc:TOTALFAC - ::aDC[4,4])
      If oApl:oEmp:PRINTIVA
         AEVAL( ::aDC, {| x | EVAL( ::aCab[6],x[8],x[4] ),;
                              AADD( aCta, { x[1],"","","","",nE,nK,0,x[5],x[6] } ) },1,4 )
         aCta[4,6] := 0
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
               AADD( aCta, { cSql,"","","","",0,0,0,aInf[2],0,1 } )
               nK := LEN( aCta )
            EndIf
            aCta[nK,06] += ROUND( aInf[1] * aInf[2] / 100,2 )
            aCta[nK,10] += aInf[1]
            nE --
         EndDo
         MSFreeResult( hRes )
         nE := ::aDC[4,4]
         AEVAL( aCta, {| x | nE -= x[6] },4 )
         If nE # 0
            If aCta[04,6] > 0
               aCta[04,6] += nE
            Else
               nK := LEN( aCta )
               aCta[nK,6] += nE
            EndIf
         EndIf
         AEVAL( ::aDC, {| x | EVAL( ::aCab[6],x[8],x[4] ),;
                              AADD( aCta, { x[1],"","","","",nE,nK,0,x[5],x[6] } ) },5 )
      Else
         AEVAL( ::aDC, {| x | EVAL( ::aCab[6],x[8],x[4] ),;
                              AADD( aCta, { x[1],"","","","",nE,nK,0,x[5],x[6] } ) } )
      EndIf
   EndIf
   nK := 0
   AEVAL( aCta, {| x | nK += (x[6] - x[7]) } )
   If nK > 0
      aCta[3,7] := nK
   Else
      aCta[3,6] := ABS(nK)
   EndIf

   If !EMPTY(oApl:oEmp:NIIF) .AND. oApl:cPer >= oApl:oEmp:NIIF
      nE   := Buscar( {"comprasc_id",::oArc:ROW_ID},"comprasf",;
                       "dscto",8,"fecha",4 )
      nK   := ASCAN( aInf,{ |aX| aX[1] == ::aDC[5,1] } )
      aInf := { nE,1,nK }
   Else
      aInf := { 0 }
   EndIf
 //AEVAL( aCta, {| x | MsgInfo( TRANSFORM(x[6],"999,999.99")+TRANSFORM(x[7],"999,999.99"),;
 //                             x[1]+STR(x[11],4) ) } )
 //cSql := "FACTURA # " + TRIM(::oArc:FACTURA) + " INGRESO # " + LTRIM(STR(::oArc:INGRESO))
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
   /*
      If ::aMov[3] == 0
         If !EMPTY( ::aMov[4] )
            ::aMov[3] := SgteNumero( ::aMov[4],oApl:nEmpresa,.t. )
         ElseIf !EMPTY( ::aMov[13] )
            ::aMov[3] := SgteCntrl( ::aMov[13],::aMov[1],.t. )
         EndIf
      EndIf
   */
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
   ActuaINF( @aCta,{::oArc:FACTURA,"","",::oArc:FECINGRE+30,;
                    ::aCab[3],::oArc:CODIGO_NIT,"",0},aInf )
   FOR nE := 1 TO LEN( aCta )
      If aCta[nE,10] > 0
         ::oMvd:Seek( "empresa = -4 LIMIT 1","CM" )
         ::oMvd:EMPRESA   := oApl:nEmpresa  ; ::oMvd:ANO_MES  := oApl:cPer
         ::oMvd:CONTROL   := ::oMvc:CONTROL ; ::oMvd:CUENTA   := aCta[nE,1]
         ::oMvd:INFA      := aCta[nE,2]     ; ::oMvd:INFB     := aCta[nE,3]
         ::oMvd:INFC      := aCta[nE,4]     ; ::oMvd:INFD     := aCta[nE,5]
         ::oMvd:VALOR_DEB := aCta[nE,6]     ; ::oMvd:VALOR_CRE:= aCta[nE,7]
         ::oMvd:CODIGO_NIT:= aCta[nE,8]     ; ::oMvd:PTAJE    := aCta[nE,9]
         ::oMvd:LIBRO     := aCta[nE,10]
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

//------------------------------------//
FUNCTION Detalles( aV,nID,lNew )
   LOCAL cQry, hRes, nR
If oApl:lEnLinea
   RETURN aV
EndIf
If lNew
   FOR nR := 1 TO LEN( aV )
      If aV[nR,4] > 0 .AND. aV[nR,7]
         If aV[nR,9] == 0
            cQry := "INSERT INTO comprasd VALUES ( null, "+ LTRIM(STR(nID))+;
                    ", " + LTRIM(STR(aV[nR,3]))           +;
                    ", " + LTRIM(STR(aV[nR,4]))           +" )"
           //       ", " + If( aV[nR,7] > 0, LTRIM(STR(aV[nR,7])), "null" ) + " )"
         Else
            cQry := "UPDATE comprasd SET valor = " + LTRIM(STR(aV[nR,4])) +;
                   " WHERE row_id = " + LTRIM(STR(aV[nR,9]))
         EndIf
         MSQuery( oApl:oMySql:hConnect,cQry )
      ElseIf aV[nR,9] > 0
            cQry := "DELETE FROM comprasd WHERE row_id = " +;
                    LTRIM(STR(aV[nR,9]))
         MSQuery( oApl:oMySql:hConnect,cQry )
         aV[nR,4] := aV[nR,9] := 0
      EndIf
   NEXT nR
EndIf
FOR nR := 1 TO LEN( aV )
   aV[nR,4] := aV[nR,5] := aV[nR,9] := 0
NEXT nR
cQry := "SELECT orden, valor, row_id " +;
        "FROM comprasd WHERE comprasc_id = " + LTRIM(STR(nID))
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nR   := MSNumRows( hRes )
While nR > 0
   cQry := MyReadRow( hRes )
   AEVAL( cQry, { |xV,nP| cQry[nP] := MyClReadCol( hRes,nP ) } )
   aV[cQry[1],4] := cQry[2]
   aV[cQry[1],9] := cQry[3]
   nR --
EndDo
MSFreeResult( hRes )
RETURN aV