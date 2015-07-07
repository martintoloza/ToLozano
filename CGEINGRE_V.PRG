// Programa.: CGEINGRE.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Mantenimiento de los Comprobante de Ingreso.
#include "FiveWin.ch"
#include "TSBrowse.ch"
#include "Btnget.ch"

MEMVAR oApl

#define CLR_PINK  nRGB( 128, 150, 150) //255, 128, 128
#define CLR_NBLUE nRGB( 255, 255, 235)

PROCEDURE CgeIngre()
   LOCAL oDlg, oLbp, oLbx, oM, oGet := ARRAY(13), nBan := 1
   LOCAL aCge := { "Recibos de Caja || ",.t.,.f. }
 oM := TIngre() ; oM:New()
oApl:Tipo := oApl:oEmp:TIPOFAC
SETKEY( VK_F11,{|| oM:GrabaI( oDlg,oLbx ) } )
DEFINE DIALOG oDlg TITLE aCge[1] + oApl:cEmpresa;
   FROM 0, 0 TO 400, 670 PIXEL
   @ 16, 00 SAY "Nro. del Ingreso" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 16, 52 GET oGet[13] VAR oM:cTipo OF oDlg PICTURE "!"  ;
      VALID( If( oM:cTipo $ "NV", .t.                     ,;
               ( MsgStop( "El Tipo es [NV]","<< OJO >>" ), .f. ) ) );
      SIZE 10,10 PIXEL
   @ 16, 62 BTNGET oGet[1] VAR oM:aMov[3] OF oDlg PICTURE "9999999"  ;
      ACTION EVAL({|| If( oM:oAyu:Mostrar()                         ,;
                        ( oM:aMov[3] := oM:oAyu:oDb:COMPROBANT      ,;
                          oGet[1]:Refresh() ), ) })                  ;
      VALID EVAL( {|| nBan := oM:BuscarMov(), aCge[3] := oM:oIng:lOK,;
                      If( aCge[3], (oGet[1]:oJump := oLbx), )       ,;
                      oM:Filtrar(), oLbp:Refresh(), oLbx:Refresh()  ,;
                      oDlg:Update(), .t. });
      SIZE 40,10 PIXEL UPDATE RESOURCE "BUSCAR"
   @ 16,110 SAY "Sgte. Ingreso" + STR(oM:nSgte,7) OF oDlg PIXEL SIZE 60,10;
      UPDATE COLOR nRGB( 255,0,0 )
   @ 16,164 SAY "FECHA" OF oDlg RIGHT PIXEL SIZE 40,10
   @ 16,206 GET oGet[02] VAR oM:oIng:FECHA OF oDlg SIZE 40,10 PIXEL UPDATE;
      VALID oM:Fechas( oM:oIng:lOK,1 ) ;
      WHEN  oM:oIng:ESTADO == 0
   @ 28, 00 SAY "Código del Banco" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 28, 52 COMBOBOX oGet[03] VAR nBan ITEMS ArrayCol( oM:aBan,1 ) SIZE 90,99;
      VALID EVAL( {|| oM:oBan:Seek( {"empresa",oApl:nEmpresa   ,;
                                     "banco",oM:aBan[nBan,2]} ),;
                      oM:oIng:BANCO   := oM:oBan:BANCO         ,;
                      oM:oIng:CTA_CTE := oM:oBan:CTA_CTE       ,;
                      oDlg:Update(), .t. }) OF oDlg PIXEL UPDATE
   @ 28,160 SAY "ESTADO : " + oM:aMov[05] OF oDlg PIXEL SIZE 80,10;
      UPDATE COLOR nRGB( 255,0,128 )
   @ 40, 00 SAY "Cuenta Corriente" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 40, 52 GET oGet[04] VAR oM:oIng:CTA_CTE OF oDlg PICTURE "@!"     ;
      VALID EVAL( {|| If( oM:oBan:Seek( {"empresa",oApl:nEmpresa     ,;
                                         "banco"  ,oM:oIng:BANCO     ,;
                                         "cta_cte",oM:oIng:CTA_CTE} ),;
                        ( oDlg:Update(), .t. )                       ,;
                        ( MsgStop("Está Cuenta NO EXISTE"), .f. ) ) });
      SIZE 30,10 PIXEL UPDATE
   @ 40,160 SAY "CONSECUTIVO" + STR(oM:oIng:CONTROL,7) OF oDlg PIXEL SIZE 80,10 UPDATE
   @ 52, 00 SAY "Nit del Cliente" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 52, 52 BTNGET oGet[05] VAR oM:aMov[10] OF oDlg PICTURE "9999999999"    ;
      ACTION EVAL({|| If( oM:oNit:Mostrar( ,,oM:aMov[10] ), (oM:aMov[10] := ;
                          oM:oNit:oDb:CODIGO, oGet[5]:Refresh() ), )} )     ;
      VALID EVAL( {|| If( oM:oNit:Buscar( oM:aMov[10],,.t. )               ,;
                        ( oM:aMov[11] := oM:oNit:oDb:NOMBRE                ,;
                          oM:oIng:CODIGONIT := oM:oNit:oDb:CODIGO_NIT      ,;
                          oDlg:Update(), .t. )                             ,;
                     (If( MsgYesNo("Desea ingresarlo","Este Nit no Existe"),;
                          oM:oNit:Editar( ,.t.,,oM:aMov[10] ), ),.f.) ) } ) ;
      WHEN oM:oIng:ESTADO == 0 UPDATE                                       ;
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"
   @ 52,116 SAY oGet[06] VAR oM:aMov[11] OF oDlg PIXEL SIZE 100,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 64, 00 SAY "Forma de Pago"  OF oDlg RIGHT PIXEL SIZE 50,10
   @ 64, 52 COMBOBOX oGet[07] VAR oM:oIng:FORMAPAGO ITEMS ArrayCol( oM:aPag,1 ) SIZE 60,99;
      OF oDlg PIXEL UPDATE WHEN oM:oIng:ESTADO == 0
   @ 64,120 SAY "Código Tarjeta" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 64,172 GET oGet[08] VAR oM:oIng:CODIGO OF oDlg PICTURE "!!"           ;
      VALID EVAL( {|| If( Buscar( {"codigo",oM:oIng:CODIGO},"cadbanco","1",;
                                   8,,4 ) == 1, .t.                       ,;
                        ( MsgStop("Está Tarjeta no Existe .."),.f.) ) } )  ;
      WHEN oM:oIng:FORMAPAGO >= 3 SIZE 16,10 PIXEL UPDATE
//      VALID EVAL( {|| If( oApl:oBco:Seek( {"codigo",oM:oIng:CODIGO} ), .t.,;
//                        ( MsgStop("Está Tarjeta no Existe .."),.f.) ) } )  ;
   @  64,190 SAY "Nro.de Documento" OF oDlg RIGHT PIXEL SIZE 60,10
   @  64,252 GET oGet[09] VAR oM:oIng:DOCUMENTO OF oDlg PICTURE "@!";
      WHEN oM:oIng:FORMAPAGO > 1 SIZE 57,10 PIXEL UPDATE
   @  76, 00 SAY "Concepto Ingreso" OF oDlg RIGHT PIXEL SIZE 50,10
   @  76, 52 GET oGet[10] VAR oM:oMvc:CONCEPTO OF oDlg PICTURE "@!" ;
      VALID EVAL( { || If( !aCge[3], oGet[10]:oJump := oLbp, ), .t. } );
      WHEN oM:oIng:ESTADO == 0 SIZE 140,10 PIXEL UPDATE
//    VALID EVAL( { || If( EMPTY( oM:oMvc:CONCEPTO )               ,;
//            (MsgStop("Digite un Breve Concepto",">>>OJO<<<"),.f.),;
//                       (If( !aCge[3], oGet[10]:oJump := oLbp, ), .t. )) } );
   @ 184,226 SAY oGet[11] VAR oM:aMov[7]        OF oDlg PICTURE "9,999,999,999.99";
      SIZE 50,10 PIXEL UPDATE
   @ 184,280 SAY oGet[12] VAR oM:aMov[8]        OF oDlg PICTURE "9,999,999,999.99";
      SIZE 50,10 PIXEL UPDATE
   ACTIVAGET(oGet)

   @ 90,06 BROWSE oLbp SIZE 140,110 PIXEL OF oDlg CELLED; // CELLED  es requerida
      COLORS CLR_BLACK, CLR_NBLUE                         // para editar Celdas
   oLbp:SetArray( oM:aCta )     // Esto es necesario para trabajar con arrays
   oLbp:nFreeze     := 1
   oLbp:nRowPos     := oLbp:nAt   := 2
   oLbp:nColPos     := oLbp:nCell := 2
   oLbp:nHeightCell += 4
   oLbp:nHeightHead += 4
   oLbp:bKeyDown := {|nKey| If( nKey== VK_TAB, oLbp:oJump := oLbx, ;
                            If( nKey== VK_F11 .AND. !aCge[3]       ,;
                              (oM:GrabaI( oDlg,oLbx ), oLbp:oJump:oJump := oLbx), )) }
   oLbp:SetAppendMode( .f. )                         // Activando Auto Append Mode

   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 2;
       TITLE "Nombre"+CRLF+"Concepto"            ;
       SIZE 160 ;
       3DLOOK TRUE, TRUE, TRUE;        // Celda, Titulo, Footers
       MOVE DT_MOVE_NEXT;              // Cursor pasa a la Sig.Columna editable
       ALIGN DT_LEFT, DT_CENTER;       // Celda, Titulo, Footer
       FOOTER "Totales->"
   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 4;
       TITLE "Valor"         PICTURE "99,999,999" ;
       SIZE 100 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       VALID { |uVar| If( uVar >= 0, .t., ;
              (MsgStop("Valor tiene que ser Positivo",">>OJO<<"), .f.)) };
       FOOTER { || TRANSFORM( oM:nDes, "999,999,999" ) } ;
       POSTEDIT { |uVar| If( oLbp:lChanged, oM:Tarjetas( oDlg,oLbp:nAt ), ) }
   oLbp:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbp:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color

   @ 113,150 LISTBOX oLbx FIELDS     ;
      oM:oMvd:CUENTA, oM:oMvd:INFC  ,;
      TRANSFORM( oM:oMvd:VALOR_DEB,"@Z 9,999,999,999.99" ),;
      TRANSFORM( oM:oMvd:VALOR_CRE,"@Z 9,999,999,999.99" ) ;
      HEADERS "Cuenta","InfC"  ,;
              "Debito","Credito";
      SIZES 400,450 SIZE 182,66 ;
      OF oDlg UPDATE PIXEL
   oLbx:nClrBackHead  := oApl:nClrBackHead
   oLbx:nClrForeHead  := oApl:nClrForeHead
   oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
   oLbx:nClrBackFocus := oApl:nClrBackFocus
   oLbx:nClrForeFocus := oApl:nClrForeFocus
   oLbx:nHeaderHeight := 26
   oLbx:GoTop()
   oLbx:oFont       := Tfont():New("Ms Sans Serif",0,-10,,.f.)
   oLbx:aColSizes   := {72,74,98,98}
   oLbx:aHjustify   := {2,2,2,2}
   oLbx:aJustify    := {0,0,1,1}
   oLbx:ladjlastcol := oLbx:lCellStyle  := .f.
   oLbx:ladjbrowse  := .t.
   oLbx:bKeyDown := {|nKey| If(nKey == VK_ESCAPE, (oM:aMov[3] := 0      ,;
                                       oM:oIng:xBlank(), oM:Filtrar(.f.),;
                                       oLbx:Refresh(), oDlg:Update(), oGet[2]:SetFocus()),;
                            If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, oM:Detalle( oDlg,oLbx,.t. ),;
                            If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, oM:Detalle( oDlg,oLbx,.f. ),;
                            If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, oM:BorraDeta( oDlg,oLbx ),) ))) }
   MySetBrowse( oLbx,oM:oMvd )
ACTIVATE DIALOG oDlg CENTERED ;
   ON INIT ( oM:Barra( oDlg,oLbx ), oM:Filtrar() )
SETKEY( VK_F11,{|| .t. } )
oM:New( 1 )
RETURN

//------------------------------------//
PROCEDURE PagosFac()
   LOCAL bSumar, nA, nBan, oDlg, oLbp, oM, oGet := ARRAY(12)
   LOCAL aCge := { "Recibos de Caja || ",0,.f.,"9,999,999,999.99",1 }
 oM := TIngre() ; oM:New()
oApl:oFac:Seek( {"empresa",oApl:nEmpresa,"numfac",45,"tipo",oApl:Tipo} )
If oApl:oFac:INGRE_ID > 0
   oM:oIng:Seek( {"row_id",oApl:oFac:INGRE_ID} )
   oM:aMov[3] := oM:oIng:COMPROBANT
   oM:cTipo   := oM:oIng:TIPO
EndIf
aCge[2] := oApl:oNit:CODIGO
   nBan := oM:BuscarMov()
If oM:oIng:lOK
   If oApl:oFac:INDICADOR == "A"
      oM:AnulaCpte()
   EndIf
Else
   oM:aCta[2,4] := oApl:oFac:TOTALFAC
EndIf
bSumar := {|nVal| If( nVal < 0, (MsgStop( "El Valor debe ser Mayor de 0",;
                     "<< OJO >>" ), .f.), ;
            (oM:aMov[7] := oM:aCta[2,4] - oM:aCta[4,4] ,;
             oGet[10]:Refresh(), .t.) ) }
DEFINE DIALOG oDlg TITLE aCge[1] + oApl:cEmpresa;
   FROM 0, 0 TO 230, 600 PIXEL
   @ 02, 00 SAY "Nro. del Ingreso" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 02, 53 SAY oGet[01] VAR oM:aMov[3] OF oDlg PICTURE "9999999";
      COLOR nRGB( 255,0,0 ) BORDER PIXEL SIZE 50,10
   @ 02,195 SAY "FECHA" OF oDlg RIGHT PIXEL SIZE 40,10
   @ 02,238 SAY oGet[02] VAR oM:oIng:FECHA OF oDlg BORDER PIXEL SIZE 40,10
   @ 14, 00 SAY "Nro. Factura"     OF oDlg RIGHT PIXEL SIZE 40,10
   @ 14, 53 SAY oGet[03] VAR oApl:oFac:NUMFAC  OF oDlg PICTURE "9999999999";
      BORDER PIXEL SIZE 50,10
   @ 14,116 SAY oGet[04] VAR oApl:oFac:CLIENTE OF oDlg ;
      COLOR nRGB( 128,0,255 ) PIXEL SIZE 100,10

   @ 26, 00 SAY "Forma de Pago"    OF oDlg RIGHT PIXEL SIZE 50,10
   @ 26, 53 COMBOBOX oGet[5] VAR oM:oIng:FORMAPAGO ITEMS ArrayCol( oM:aPag,1 ) SIZE 60,99;
      OF oDlg PIXEL UPDATE WHEN oM:oIng:ESTADO == 0
   @ 26,115 SAY "Código Tarjeta"   OF oDlg RIGHT PIXEL SIZE 50,10
   @ 26,168 GET oGet[06] VAR oM:oIng:CODIGO OF oDlg PICTURE "!!"           ;
      VALID EVAL( {|| If( Buscar( {"codigo",oM:oIng:CODIGO},"cadbanco","1",;
                                   8,,4 ) == 1, .t.                       ,;
                        ( MsgStop("Está Tarjeta no Existe .."),.f.) ) } )  ;
      WHEN oM:oIng:FORMAPAGO >= 3 SIZE 16,10 PIXEL UPDATE
   @ 26,185 SAY "Nro.de Documento" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 26,238 GET oGet[07] VAR oM:oIng:DOCUMENTO OF oDlg PICTURE "@!";
      WHEN oM:oIng:FORMAPAGO > 1 SIZE 57,10 PIXEL
   @ 38, 00 SAY "Valor del Pago"   OF oDlg RIGHT PIXEL SIZE 50,10
   @ 38, 53 GET oGet[08] VAR oM:aCta[2,4]     OF oDlg PICTURE aCge[4];
      VALID EVAL( bSumar,oM:aCta[2,4] ) SIZE 40,10 PIXEL
   @ 38,115 SAY "Valor Factura" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 38,168 SAY oApl:oFac:TOTALFAC OF oDlg PICTURE aCge[4] BORDER PIXEL SIZE 40,10
   @ 50, 00 SAY "Valor Descuento"  OF oDlg RIGHT PIXEL SIZE 50,10
   @ 50, 53 GET oGet[09] VAR oM:aCta[4,4]     OF oDlg PICTURE aCge[4];
      VALID EVAL( bSumar,oM:aCta[4,4] ) SIZE 40,10 PIXEL
   @ 50,115 SAY "Total Pagado"     OF oDlg RIGHT PIXEL SIZE 50,10
   @ 50,168 SAY oGet[10] VAR oM:aMov[7]       OF oDlg PICTURE aCge[4];
      BORDER PIXEL SIZE 40,10

   @ 94,100 BUTTON oGet[11] PROMPT "GRABAR"   SIZE 40,12 OF oDlg ACTION;
      (If( oM:aMov[7] > oApl:oFac:TOTALFAC,;
         ( MsgStop("Pago Mayor que el Saldo",">>> OJO <<<" ),;
           oGet[8]:SetFocus()), (aCge[3] := .t., oDlg:End()) )) PIXEL
   @ 94,150 BUTTON oGet[12] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)

ACTIVATE DIALOG oDlg CENTERED
If aCge[3]
   oM:aCar := { { LTRIM(STR(oApl:oFac:NUMFAC))+oApl:Tipo,oM:aCta[2,4] } }
 //If oApl:oFac:TOTALFAC > oM:aMov[7]
 //   AADD( oM:aCar, { "",oApl:oFac:TOTALFAC - oM:aMov[7] } )
 //EndIf
   nBan := If( oM:oIng:FORMAPAGO <= 2, 1, 2 )
   oM:oBan:Seek( {"empresa",oApl:nEmpresa,"banco",oM:aBan[nBan,2]} )
   oM:aMov[10]       := aCge[2]
   oM:aMov[11]       := oApl:oNit:NOMBRE
   oM:oMvc:CONCEPTO  := PADR( "PAGOS A FACT."+oM:aCar[1,1],40 )
   oM:oIng:BANCO     := oM:oBan:BANCO
   oM:oIng:CTA_CTE   := oM:oBan:CTA_CTE
   oM:oIng:CODIGONIT := oApl:oFac:CODIGO_NIT
   oM:Tarjetas( oDlg,0 )
//   MsgInfo( oM:oMvc:CONCEPTO,oM:oIng:BANCO+oM:oIng:CTA_CTE )
   oM:GrabaI( oDlg )
   oApl:oFac:INGRE_ID := oM:oIng:ROW_ID
   oApl:oFac:Update(.f.,1)
EndIf
oM:New( 1 )
RETURN

//------------------------------------//
CLASS TIngre FROM TMov

 DATA aBan AS ARRAY INIT {}
 DATA aCta AS ARRAY INIT {}
 DATA aDF  AS ARRAY INIT { .16,663000,.035,.0054,.50,.015,.10,.0042,.003 }
 DATA aFor AS ARRAY INIT { 0,0,0,0,0,0,0,0,0 }
 DATA aPag AS ARRAY INIT {}
 DATA cTipo   INIT "N"
 DATA nSgte   INIT oApl:oEmp:INGRESO + 1
 DATA nDes    INIT 0
 DATA aCar, oAyu, oBan, oIng, oSay

 METHOD NEW() Constructor
 METHOD BuscarMov()
 METHOD Fechas( lOK,nMsg )
 METHOD BuscarCta( lNew )
 METHOD Tarjetas( oDlg,nA )
 METHOD AnulaCpte( oDlg,oLbx )
 METHOD GrabaI( oDlg,oLbx )
 METHOD Facturas()
 METHOD ValidaFP( aFac,aGT,oLbf )
 METHOD ValidaPG( aGT,nPag,nSal )
 METHOD Listado()
 METHOD Barra( oDlg,oLbx )
ENDCLASS

//------------------------------------//
METHOD NEW( nFin ) CLASS TIngre
   LOCAL aFor, hRes, nL
If nFin == NIL
   Super:NEW( 1 )
   aFor := "SELECT nombre, banco FROM cgebanco "         +;
           "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
           " GROUP BY banco ORDER BY nombre"
   hRes := If( MSQuery( oApl:oMySql:hConnect,aFor ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   While nL > 0
      aFor := MyReadRow( hRes )
      AEVAL( aFor, { | xV,nP | aFor[nP] := MyClReadCol( hRes,nP ) } )
      AADD( ::aBan, { aFor[1],aFor[2] } )
      nL --
   EndDo
   MSFreeResult( hRes )
   aFor := ArrayCombo( "FPAGO" )
   AEVAL( aFor, {|x| AADD( ::aPag, { x[1],INT(VAL(x[2])) } ) } )
/*
aFor := "SELECT formula FROM cadmedid "+;
        "WHERE codigo >= 'Z1'"         +;
         " AND codigo <= 'Z4' ORDER BY codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,aFor ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aFor := MyReadRow( hRes )
   AADD( ::aFor, &(TRIM( aFor[1] )) )
   nL --
EndDo
MSFreeResult( hRes )
*/
   ::aCar := {}
   ::aCta := Cuentas( ::aMov[2] )
   ::oAyu := TChq() ; ::oAyu:New( 1 )
   ::oBan := oApl:Abrir( "cgebanco","empresa, banco, cta_cte",,,10 )
   ::oIng := oApl:Abrir( "cgeingre","empresa, comprobant",,,10 )
   ::oIng:Seek( {"empresa",oApl:nEmpresa,"comprobant",::aMov[3],"tipo",::cTipo} )
   ::oFte:oDb:Seek( {"fuente",::aMov[2]} )
   oApl:oEmp:XLoad()
Else
   ::oFte:Cerrar()
   ::oPuc:Cerrar()
   ::oVar:Cerrar()
   ::oBan:Destroy()
   ::oCtl:Destroy()
   ::oIng:Destroy()
   ::oMvc:Destroy()
   ::oMvd:Destroy()
EndIf
RETURN NIL

//------------------------------------//
METHOD BuscarMov() CLASS TIngre
   LOCAL nBan
If !::oIng:Seek( {"empresa",oApl:nEmpresa,"comprobant",::aMov[3],"tipo",::cTipo} )
   ::oIng:FECHA := DATE()
   ::oIng:FORMAPAGO := 1
EndIf
::BuscarCta( .f. )
::Fechas( .f. )

::oNit:oDb:Seek( {"codigo_nit",::oIng:CODIGONIT} )
::aMov[01] := oApl:cPer
::aMov[05] := {"Sin Imprimir","Impreso","Anulado"}[::oIng:ESTADO+1]
::aMov[10] := ::oNit:oDb:CODIGO
::aMov[11] := ::oNit:oDb:NOMBRE
::aMov[14] := 1
nBan := ArrayValor( ::aBan,::oIng:BANCO,,.t. )

::oBan:Seek( {"empresa",oApl:nEmpresa,"banco",::aBan[nBan,2]} )
::oMvc:Seek( {"empresa",oApl:nEmpresa,"ano_mes",::aMov[1],;
               "fuente",::aMov[2], "comprobant",::aMov[3]} )
RETURN nBan

//------------------------------------//
METHOD Fechas( lOK,nMsg ) CLASS TIngre
   LOCAL aFec, lSI := .t.
If lOK
   aFec := { ::oIng:XColumn( 4 ),::oIng:FECHA,oApl:cPer,::lCierre,.t.,;
             "empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
        " AND ano_mes = " + xValToChar(oApl:cPer )    +;
        " AND control = " + LTRIM(STR(::oIng:CONTROL)) }
   If (aFec[5] := ::Fechas( .f.,1 ))
      If (aFec[3] == LEFT( DTOS(aFec[2]),6 ))
         If ::oIng:CONTROL > 0
            Guardar( "UPDATE cgemovc SET fecha = " + xValToChar(aFec[2]) +;
                     " WHERE " + aFec[6],"cgemovc" )
         EndIf
         Guardar( ::oIng,.f.,.f. )
      ElseIf MsgYesNo( "QUIERE HACER EL CAMBIO","VA A CAMBIAR DE MES" )
         If ::oIng:CONTROL > 0
            ::oIng:CONTROL := SgteCntrl( "control",oApl:cPer,.t. )
            ::oMvc:Seek( aFec[6],"CM" )
            ::oMvc:ANO_MES := oApl:cPer
            ::oMvc:FECHA   := aFec[2]
            ::oMvc:CONTROL := ::oIng:CONTROL
            Guardar( ::oMvc,.f.,.f. )
            ::oMvd:dbEval( {|o| ::Avanza( ,o:CUENTA )                                ,;
                                ::GrabaPago( o:CUENTA,::aTL[4],-::aTL[5],::aTL[6],1 ),;
                                Acumular( ::oMvc:ESTADO,o,5,5,.f.,.f. )              ,;
                                o:ANO_MES := oApl:cPer, o:CONTROL := ::oMvc:CONTROL  ,;
                                ::GrabaPago( o:CUENTA,::aTL[4], ::aTL[5],::aTL[6],2 ),;
                                Acumular( ::oMvc:ESTADO,o,2,2,.f.,.f. ) }, aFec[6] )
         EndIf
         Guardar( ::oIng,.f.,.f. )
         ::aMov[1] := oApl:cPer
      Else
         aFec[5] := .f.
      EndIf
   EndIf
   If (lSI := aFec[5])
      MsgInfo( "El cambio de Fecha","HECHO" )
   Else
      lSI := If( EMPTY( aFec[2] ) .OR. ::lCierre, .t., .f. )
      ::oIng:FECHA := aFec[1]
      oApl:cPer := aFec[3]
      ::lCierre := aFec[4]
   EndIf
ElseIf EMPTY( ::oIng:FECHA )
   MsgStop( "No puede ir en Blanco","FECHA" )
   lSI := .f.
Else
   oApl:cPer := NtChr( ::oIng:FECHA,"1" )
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
METHOD BuscarCta( lNew ) CLASS TIngre
   LOCAL cQry, hRes, nR
If lNew
   FOR nR := 1 TO LEN( ::aCta  )
      If ::aCta[nR,4] > 0
         If ::aCta[nR,5] == 0
            cQry := "INSERT INTO ingresod VALUES ( null, " +;
                  LTRIM(STR(oApl:nEmpresa)) + ", " + LTRIM(STR(::aMov[3])) + ", '"+;
                            ::cTipo         +"', " +;
                  LTRIM(STR(::aCta[nR,3]))  + ", " + LTRIM(STR(::aCta[nR,4])) + " )"
         Else
            cQry := "UPDATE ingresod SET valor = " + LTRIM(STR(::aCta[nR,4])) +;
                    " WHERE row_id = " + LTRIM(STR(::aCta[nR,5]))
         EndIf
         MSQuery( oApl:oMySql:hConnect,cQry )
      ElseIf ::aCta[nR,5] > 0
         MSQuery( oApl:oMySql:hConnect,"DELETE FROM ingresod WHERE row_id = "+;
                  LTRIM(STR(::aCta[nR,5])) )
      EndIf
   NEXT nR
EndIf
::nDes := 0
AEVAL( ::aCta, {|x| AFILL( x,0,4,2 ) } )
cQry := "SELECT orden, valor, row_id FROM ingresod "    +;
        "WHERE empresa = "   + LTRIM(STR(oApl:nEmpresa))+;
         " AND comprobant = "+ LTRIM(STR(::aMov[3]))    +;
         " AND tipo = "      + xValToChar(::cTipo)
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nR   := MSNumRows( hRes )
While nR > 0
   cQry := MyReadRow( hRes )
   AEVAL( cQry, { | xV,nP | cQry[nP] := MyClReadCol( hRes,nP ) } )
   If cQry[1] >= 4
      ::nDes += cQry[2]
   EndIf
   ::aCta[cQry[1],4] := cQry[2]
   ::aCta[cQry[1],5] := cQry[3]
   nR --
EndDo
MSFreeResult( hRes )
RETURN NIL

//------------------------------------//
METHOD Tarjetas( oDlg,nA ) CLASS TIngre
   LOCAL nPorT
If nA == 2
   If ::oFte:oDb:CARTERA .AND. ::oMvc:CONSECUTIV == 0 .AND.;
      ::aCta[2,4] > 0
      ::Facturas()
      oDlg:Update()
   EndIf
EndIf

If (::aCta[2,4] + ::aCta[3,4]) > 0 .AND. ::oIng:FORMAPAGO >= 3
   If nA # 8
      ::aCta[8,4] := ::aCta[8,4] * ::aDF[7] * 100
   EndIf
   nPorT := Buscar( "SELECT " + {"debito","credito"}[::oIng:FORMAPAGO-2] +;
                   " FROM cadbanco WHERE codigo = '" + TRIM(::oIng:CODIGO) + "'","CM",,8,,4 )
   ::aFor[2]    := If( ::aCta[2,4] > 0, ::aCta[2,4], ::aCta[3,4] ) -;
                     ( ::aCta[4,4] + ::aCta[5,4] + ::aCta[8,4] )
   ::aCta[07,4] := ROUND( ::aFor[2] * ::aDF[6],0 )     //Ret.FTE
   ::aCta[08,4] := ROUND(::aCta[8,4]* ::aDF[7],0 )     //Ret.IVA
   ::aCta[09,4] := ROUND( ::aFor[2] * ::aDF[8],0 )     //Ret.ICA
   ::aCta[10,4] := ROUND( ::aFor[2] * nPorT / 100,2 )  //Comision Bancaria
   ::aFor[2]    := ::aCta[07,4] + ::aCta[08,4] + ::aCta[09,4] + ::aCta[10,4]
   oDlg:Update()
EndIf
If ::oIng:lOK
   ::BuscarCta( .t. )
Else
   ::nDes := 0
   FOR nA := 4 TO LEN( ::aCta )
      ::nDes += ::aCta[nA,4]
   NEXT nA
EndIf
RETURN lEdit

//------------------------------------//
METHOD AnulaCpte( oDlg,oLbx ) CLASS TIngre

If ::lCierre
   MsgStop( "YA ESTA CERRADO","Periodo "+oApl:cPer )
   RETURN NIL
Else
   ::aMov[5] := If( ::oIng:ESTADO == 2, "ACTIVAR", "ANULAR" )
   If MsgNoYes( "Este Comprobante","QUIERE "+::aMov[5] )
      If ::oMvc:CONTROL > 0
         ::oMvd:dbEval( {|o| ::Avanza( ,o:CUENTA )                                    ,;
                             If( ::oMvc:ESTADO  <= 1                                  ,;
                               (      o:EMPRESA := -9                                 ,;
                                 ::GrabaPago( o:CUENTA,::aTL[4],-::aTL[5],::aTL[6],1 ),;
                                 Acumular( 2, o, 3, 3, .f., .f. ) ), ) } )
                      //{"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,"control",::oMvc:CONTROL} )
      EndIf
      If ::oMvc:ESTADO == 2
         ::oMvc:ESTADO := 1
         ::oIng:ESTADO := 0
      Else
         ::oMvc:ESTADO := ::oIng:ESTADO := 2
      EndIf
      ::oMvc:CONSECUTIV:= 0
      ::oMvc:Update(.t.,1)
      ::oIng:Update(.t.,1)
   EndIf
   If oDlg # NIL
      ::aMov[5] := {"Sin Imprimir","Impreso","Anulado"}[::oIng:ESTADO+1]
      oLbx:Refresh()
      oDlg:Update()
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD GrabaI( oDlg,oLbx ) CLASS TIngre
   LOCAL aCta, cBan, cNit, cNom, nC, nJ
//If ::oIng:ESTADO # 0 .AND. ::oMvc:CONSECUTIV > 0
If ::oMvc:CONSECUTIV > 0
   RETURN NIL
ElseIf MsgYesNo( "Grabar este Ingreso","QUIERE" )
   If ::aMov[3] == 0 .OR. !::oIng:lOK
      ::aMov[3] := SgteNumero( ::aMov[4],oApl:nEmpresa,.t. )
      ::oIng:EMPRESA    := oApl:nEmpresa
      ::oIng:COMPROBANT := ::aMov[3]
      ::oIng:TIPO       := ::cTipo
      ::nSgte           := ::aMov[3] +1
      ::oIng:Append(.t.)
      oDlg:Update()
   Else
      ::oIng:Update(.t.,1)
   EndIf
   ::BuscarCta( .t. )
   If ::oMvc:CONSECUTIV == 0
      If ::oFte:oDb:CARTERA .AND. LEN( ::aCar ) == 0 .AND.;
         ::aCta[2,4] > 0
         ::Facturas( .f. )
      EndIf
      ::aMov[1] := oApl:cPer := NtChr( ::oIng:FECHA,"1" )
      ::aMov[4] := ""
      ::oMvc:FECHA    := ::oIng:FECHA
      ::oMvc:CODIGONIT:= ::oIng:CODIGONIT
      ::oMvc:VALORB   := ( ::aCta[2,4] + ::aCta[3,4]) -;
                       If( ::aCta[10,4] > 0, (::aCta[5,4] + ::aCta[6,4]), ::nDes )
      cNit := ::oBan:CUENTA
      cNom := { ::aDF[3],::aDF[9],0,::aDF[6],::aDF[7],::aDF[8],0,;
                "RET","IVA","ICA","COM" }
      aCta := { { cNit,::oMvc:VALORB   ,0,"",0 } }
         //AEVAL( <aMatriz> , <bBloque> , <nInicio>, <nPosiciones> )
      If ::oIng:FORMAPAGO >= 3
         nC := 8
         AEVAL( ::aCta,{|x| AADD( aCta,{ cNit,0,x[4],"" ,cNom[nC] } ), nC ++ },7,4 )
         nC := 4
         AEVAL( ::aCta,{|x| AADD( aCta,{ x[1],x[4],0,"X",cNom[nC] } ), nC ++ },7,4 )
         nC := 1
         AEVAL( ::aCta,{|x| AADD( aCta,{ x[1],x[4],0,"" ,cNom[nC] } ), nC ++ },4,3 )
      Else
         nC := 1
         AEVAL( ::aCta,{|x| AADD( aCta,{ x[1],x[4],0,"X",cNom[nC] } ), nC ++ },4 )
      // FOR nC := 4 TO LEN( ::aCta )
      //    AADD( aCta,{ ::aCta[nC,1],::aCta[nC,4],0,"X",cNom[nC-3] } )
      // NEXT nC
         aCta[2,4] := aCta[3,4] := ""
         AADD( aCta,{::oBan:CUENTA,0,::aFor[2]   ,"X",0 } )
      EndIf
         AADD( aCta,{ ::aCta[3,1] ,0,::aCta[3,4] , "",0 } )
      If LEN( ::aCar ) > 0
         AEVAL( ::aCar, {|a| AADD( aCta,{ ::aCta[2,1],0,a[2],a[1],0 } ) } )
      Else
         AADD( aCta,{ ::aCta[2,1],0,::aCta[2,4],"",0 } )
      EndIf
      cNom := ::oMvc:CONCEPTO
      If EMPTY(cNom)
         MsgGet( "Descripcion Ingreso","Concepto",@cNom )
      EndIf
      ::oMvc:CONCEPTO := UPPER( cNom )
      ::oCtl:Seek( {"empresa",oApl:nEmpresa,"ano_mes",::aMov[1]} )
      ::oNit:oDb:Seek( {"codigo_nit",::oBan:CODIGO_NIT} )
      ::aTL := { 0,0,"","",0,1,0 }
      cBan  := ::oIng:CODIGO + "-" + LEFT( ALLTRIM(::oIng:DOCUMENTO),6 )
      cNit  := LTRIM(STR(::oNit:oDb:CODIGO))
      ::oNit:oDb:Seek( {"codigo_nit",::oIng:CODIGONIT} )

      FOR nJ := 1 TO LEN( aCta )
         If (aCta[nJ,2] + aCta[nJ,3]) == 0
            LOOP
         EndIf
         ::aMov[25] := 0
         ::oPuc:oDb:Seek( {"empresa",oApl:nPuc,"cuenta",aCta[nJ,1]} )
         cNom := { TRIM(::oPuc:oDb:INFA),TRIM(::oPuc:oDb:INFB),;
                   TRIM(::oPuc:oDb:INFC),TRIM(::oPuc:oDb:INFD),;
                   "","","","",0 }
         FOR nC := 1 TO 4
            do case
            Case cNom[nC] == "BASE"
               ::aMov[25] := aCta[nJ,5] * If( nJ == 7, 1000, 100 )
               ::aMov[27] := ROUND( aCta[nJ,2] / aCta[nJ,5] ,0 )
               cNom[4+nC] := If( EMPTY(::aMov[27]), "", LTRIM(STR(::aMov[27],10,0)) )
            Case cNom[nC] == "CHEQUE"
               If ISALPHA( aCta[nJ,5] )
                  cNom[4+nC] := aCta[nJ,5]
               Else
                  cNom[4+nC] := ALLTRIM(::oIng:DOCUMENTO)
               EndIf
            Case cNom[nC] == "COD-VAR"
               cNom[4+nC] := ALLTRIM(aCta[nJ,1])
            Case cNom[nC] == "CTA-CTE"
               cNom[4+nC] := ALLTRIM(::oIng:CTA_CTE)
            Case cNom[nC] == "DOCUMENTO"
               If ISALPHA( aCta[nJ,5] )
                  cNom[4+nC] := cBan
               Else
                  cNom[4+nC] := LTRIM(STR(::oIng:COMPROBANT))
               EndIf
            Case cNom[nC] == "FACTURA"
               cNom[4+nC] := aCta[nJ,4]
            Case cNom[nC] == "FECHA"
               cNom[4+nC] := DTOC( ::oIng:FECHA )
            Case cNom[nC] == "NIT"
               If aCta[nJ,4] == "X" .AND. ::oIng:FORMAPAGO >= 3
                  cNom[nC+4] := cNit
                  cNom[9]    := ::oBan:CODIGO_NIT
               Else
                  cNom[nC+4] := LTRIM(STR(::aMov[10]))
                  cNom[9]    := ::oIng:CODIGONIT
               EndIf
            EndCase
         NEXT nC
         ::oMvd:xBlank()
         ::oMvd:CUENTA     := aCta[nJ,1]
         ::oMvd:INFA       := cNom[5]
         ::oMvd:INFB       := cNom[6]
         ::oMvd:INFC       := cNom[7]
         ::oMvd:INFD       := cNom[8]
         ::oMvd:CODIGO_NIT := cNom[9]
         ::oMvd:VALOR_DEB  := aCta[nJ,2]
         ::oMvd:VALOR_CRE  := aCta[nJ,3]
         ::oMvd:PTAJE      := ::aMov[25]
         ::aTL[7] := cNom[9]
         ::Graba( .t.,1 )
      NEXT nJ
      ::oIng:CONTROL := ::oMvc:CONTROL ; ::oIng:Update(.t.,1)
      ::aMov[4] := "INGRESO"
      If oLbx # NIL
         ::Filtrar()
         oLbx:Refresh()
         oDlg:Update()
      EndIf
   EndIf
EndIf

RETURN NIL

//----NIT--DOC--FAC-------------------//
METHOD Facturas() CLASS TIngre
   LOCAL aFac, aGT, cQry, hRes, nL, oDlg, oGet, oLbf
If LEN( oApl:Tipo ) == 1
   aGT := " = " + xValToChar( oApl:Tipo )
Else
   aGT := " IN("
   FOR nL := 1 TO LEN( oApl:Tipo )
      aGT += "'" + SUBSTR( oApl:Tipo,nL,1 ) + "', "
   NEXT nL
   aGT := LEFT( aGT,LEN(aGT)-2 ) + ")"
EndIf
cQry := "SELECT f.numfac, f.tipo, f.fechoy, s.saldo "         +;
        "FROM [Fam] s, [Fac] f "                              +;
        "WHERE f.empresa = " + LTRIM(STR(oApl:nEmpresa))      +;
         " AND f.fechoy <= " + xValToChar( ::oIng:FECHA )     +;
         " AND f.tipo"       + aGT                            +;
         " AND f.codigo_nit = " + LTRIM(STR(::oIng:CODIGONIT))+;
         " AND f.indicador <> 'A'"                            +;
         " AND s.empresa = f.empresa"                         +;
         " AND s.numfac = f.numfac AND s.tipo = s.tipo"       +;
         " AND s.anomes = (SELECT MAX(m.anomes) FROM [Fam] m "+;
                          "WHERE m.empresa = f.empresa"       +;
                           " AND m.numfac  = f.numfac"        +;
                           " AND m.tipo    = f.tipo"          +;
                           " AND m.anomes <= '" + oApl:cPer   +;
       "') AND s.saldo <> 0 ORDER BY f.numfac"
cQry := STRTRAN( cQry,"[Fac]",oApl:oFac:cName )
cQry := STRTRAN( cQry,"[Fam]",oApl:oFam:cName )
If oApl:oFac:cName == "cgefactc"
   cQry := STRTRAN( cQry,"fechoy","fecha" )
EndIf
//MsgInfo( cQry )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY FACTURAS PENDIENTES" )
   MSFreeResult( hRes )
   RETURN NIL
EndIf
aFac := {}
aGT  := { 0,0,0,::aCta[2,4],.f. }
oGet := ARRAY(4)
While nL > 0
   cQry := MyReadRow( hRes )
   AEVAL( cQry, { | xV,nP | cQry[nP] := MyClReadCol( hRes,nP ) } )
   AADD( aFac, { LTRIM(STR(cQry[1]))+cQry[2],cQry[3],cQry[4],0 } )
   aGT[1] += cQry[4]
   nL --
EndDo
MSFreeResult( hRes )
DEFINE DIALOG oDlg TITLE "Facturas Pendientes" FROM 0, 0 TO 330, 430 PIXEL
   @ 02, 00 SAY "Valor del Pago" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 02, 62 SAY oGet[1] VAR ::aCta[2,4] OF oDlg PICTURE "9,999,999,999.99";
      SIZE 50,12 PIXEL
   @ 02,120 SAY oGet[2] VAR aGT[4] OF oDlg PICTURE "9,999,999,999.99";
      SIZE 50,12 PIXEL UPDATE COLOR nRGB( 255,0,0 )
   @ 16,10 BROWSE oLbf SIZE 190,120 PIXEL OF oDlg CELLED; // CELLED  es requerida
      ON CLICK ( ::ValidaFP( aFac,aGT,oLbf ), oGet[2]:Refresh(), oLbf:Refresh() );
      COLORS CLR_BLACK, CLR_NBLUE                         // para editar Celdas
   oLbf:SetArray( aFac )     // Esto es necesario para trabajar con arrays
   oLbf:nFreeze     := 1
   oLbf:nColPos     := oLbf:nCell := 2
   oLbf:nHeightCell += 4
   oLbf:nHeightHead += 4
   oLbf:SetAppendMode( .f. )                     // Activando Auto Append Mode

   ADD COLUMN TO BROWSE oLbf DATA ARRAY ELEMENT 1;
       TITLE "Numero"+CRLF+"Factura"             ;
       SIZE  90 ;
       3DLOOK TRUE, TRUE, TRUE;                  // Celda, Titulo, Footers
       MOVE DT_MOVE_NEXT;                        // Cursor pasa a la Sig.Columna editable
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;      // Celda, Titulo, Footer
       FOOTER "Totales->"
   ADD COLUMN TO BROWSE oLbf DATA ARRAY ELEMENT 4;
       TITLE "Valor"+CRLF+"Pago" PICTURE "99,999,999";
       SIZE 110 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_DOWN;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       PREEDIT {|uVar| aGT[3] := uVar, nL := oLbf:nAt } ;
       VALID { |uVar| ::ValidaPG( aGT,uVar,aFac[nL,3] ) };
       POSTEDIT { |uVar| If( oLbf:lChanged, ( aGT[2] += ( uVar - aGT[3] ),;
                                           aGT[4] := ::aCta[2,4] - aGT[2],;
                              oGet[2]:Refresh(), oLbf:DrawFooters() ), ) };
       FOOTER { || TRANSFORM( aGT[2], "999,999,999" ) }
   ADD COLUMN TO BROWSE oLbf DATA ARRAY ELEMENT 3;
       TITLE "Saldo"         PICTURE "99,999,999";
       SIZE 110 ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       FOOTER { || TRANSFORM( aGT[1], "999,999,999" ) }
   ADD COLUMN TO BROWSE oLbf DATA ARRAY ELEMENT 2;
       TITLE "Fecha"                             ;
       SIZE  90 ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_CENTER, DT_CENTER
   oLbf:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbf:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color
   @ 138, 70 BUTTON oGet[3] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( aGT[5] := .t. , oDlg:End() ) PIXEL
   @ 138,120 BUTTON oGet[4] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
If aGT[5]
   ::aCar := {}
   cQry := "PAGOS A FACT."
   FOR nL := 1 TO LEN( aFac )
      If aFac[nL,4] > 0
         cQry += (aFac[nL,1] + "/")
         AADD( ::aCar, { aFac[nL,1],aFac[nL,4] } )
      EndIf
   NEXT nL
   If ::aCta[2,4] > aGT[2]
      AADD( ::aCar, { "",::aCta[2,4] - aGT[2] } )
   EndIf
   ::oMvc:CONCEPTO := PADR( cQry,40 )
EndIf
RETURN NIL

//------------------------------------//
METHOD ValidaFP( aFac,aGT,oLbf,nPag ) CLASS TIngre
   LOCAL nL := oLbf:nAt
If aFac[nL,4] == 0
    aGT[3]    := 0
   If nPag == NIL
      nPag := If( aFac[nL,3] > aGT[4], aGT[4], aFac[nL,3] )
   EndIf
   If ::ValidaPG( aGT,nPag,aFac[nL,3] )
      aFac[nL,4] := nPag
   Else
      nPag := 0
   EndIf
Else
    aGT[3]    := aFac[nL,4]
   aFac[nL,4] := nPag := 0
EndIf
   aGT[2] += ( nPag - aGT[3] )
   aGT[4] := ::aCta[2,4] - aGT[2]
   oLbf:DrawFooters()
/*
   LOCAL aIng, aRes, hRes, nR
aRes := "SELECT c.ingre_id, c.formapago, c.codigo, c.documento, d.orden, d.valor "+;
        "FROM ingresoc c LEFT JOIN ingresod d "+;
         "USING( empresa, comprobant, tipo ) " +;
        "WHERE c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
        " ORDER BY c.ingre_id"
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nR   := MSNumRows( hRes )
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
aIng := { aRes[1],aRes[2],aRes[3],aRes[4],0,0,0,0,0,0,0,0,0,0 }
While nR > 0
   aIng[ aRes[5]+4 ] += aRes[6]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aIng[1] # aRes[1]
   EndIf
EndDo
MSFreeResult( hRes )



aRes := "SELECT comprobant, valor_car, valor_var, valor_fte, "+;
              "valor_iva, valor_ica, valor_des FROM cgeingre "+;
        "WHERE empresa = "   + LTRIM(STR(oApl:nEmpresa))      +;
        " ORDER BY ingreso"
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nR   := MSNumRows( hRes )
While nR > 0
   aRes := MyReadRow( hRes )
   oApl:oWnd:SetMsg( "Comprobante = " + aRes[1] )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   AEVAL( ::aCta, {|x| AFILL( x,0,4,2 ) } )
   ::aMov[3]   := aRes[1]
   ::aCta[2,4] := aRes[2]
   ::aCta[3,4] := aRes[3]
   ::aCta[7,4] := aRes[4]
   ::aCta[8,4] := aRes[5]
   ::aCta[9,4] := aRes[6]
   ::aCta[7,4] := aRes[7]
   ::BuscarCta( .t. )
   nR --
EndDo
MSFreeResult( hRes )
*/
RETURN NIL

//------------------------------------//
METHOD ValidaPG( aGT,nPag,nSal ) CLASS TIngre
   LOCAL lOK := .t.
If aGT == NIL
   nSal := LEN( ::aPag )
   If nPag <= 0 .OR. nPag > nSal
      MsgStop( "Forma de Pago va de 1 a" +STR(nSal,3) ,">> OJO <<" )
     lOK := .f.
   EndIf
ElseIf nPag <= 0
   MsgStop("Valor tiene que ser Positivo",">> OJO <<")
   lOK := .f.
ElseIf nPag > nSal
   MsgStop( "Pago Mayor que el Saldo",">> OJO <<" )
   lOK := .f.
ElseIf (aGT[2] + nPag - aGT[3]) > ::aCta[2,4]
   MsgStop( "Pago Mayor que el Total",">> OJO <<" )
   lOK := .f.
EndIf
RETURN lOK

//----------------------------------------------//
METHOD Listado() CLASS TIngre
If ::oMvc:CONTROL > 0
   If CgeLista( ::oMvc:CONTROL,{ LTRIM(::oIng:DOCUMENTO),;
                ::oBan:NOMBRE,::oIng:CTA_CTE,"" },"Ingreso" )
      ::oIng:ESTADO := 1 ; ::oIng:Update(.t.,1)
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Barra( oDlg,oLbx ) CLASS TIngre
   LOCAL oBar, oBot := ARRAY(7)
DEFINE BUTTONBAR oBar OF oDlg 3DLOOK SIZE 28,28

DEFINE BUTTON oBot[1] RESOURCE "DEDISCO"  OF oBar NOBORDER;
   TOOLTIP "Grabar (F11)"  ACTION;
    (If( EMPTY(::oIng:CODIGONIT) .OR. (::aCta[2,4]+::aCta[3,4]) <= 0,;
       ( MsgStop("Imposible grabar este Ingreso") ),;
       ( ::GrabaI( oDlg,oLbx ) )))
DEFINE BUTTON oBot[2] RESOURCE "IMPRIMIR" OF oBar NOBORDER ;
   TOOLTIP "Imprimir Ingreso" ;
   ACTION ::Listado()
// TOOLTIP "Imprimir Ingreso"                       ACTION ;
// (If( MsgYesNo( "Imprimir este Ingreso","QUIERE" )      ,;
//      ::Listado() , ))
DEFINE BUTTON oBot[3] RESOURCE "ELIMINAR" OF oBar NOBORDER;
   TOOLTIP "Anula Comprobante" ;
   ACTION ::AnulaCpte( oDlg,oLbx )
// ACTION ::ValidaFP()
DEFINE BUTTON oBot[4] RESOURCE "ADD"      OF oBar NOBORDER ;
   ACTION ::Detalle( oDlg,oLbx,.t. )      TOOLTIP "Nuevo Registro (Ctrl+N)"
DEFINE BUTTON oBot[5] RESOURCE "MODIFY"   OF oBar NOBORDER ;
   ACTION ::Detalle( oDlg,oLbx,.f. )      TOOLTIP "Editar Registro (Ctrl+E)"
DEFINE BUTTON oBot[6] RESOURCE "DELREC"   OF oBar NOBORDER ;
   ACTION ::BorraDeta( oDlg,oLbx )        TOOLTIP "Borrar  (Ctrl+DEL)"
DEFINE BUTTON oBot[7] RESOURCE "QUIT"     OF oBar NOBORDER;
   TOOLTIP "Salir"    ;
   ACTION oDlg:End()    GROUP
 oBar:bRClicked := {|| NIL }
 oBar:bLClicked := {|| NIL }
RETURN oBar

//------------------------------------//
FUNCTION PIva( cPer )
   LOCAL aDF, hRes
cPer := If( VALTYPE( cPer ) == "D", NtChr( cPer,"1" ), cPer )
cPer := "SELECT piva, toperet, retfte, retica, retiva, ret2, iva2, ica2, pcree FROM nomfijos "+;
        "WHERE periodoi <= '" + cPer +;
        "' AND periodof >= '" + cPer + "'"
hRes := If( MSQuery( oApl:oMySql:hConnect,cPer ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If MSNumRows( hRes ) > 0
   aDF := MyReadRow( hRes )
   AEVAL( aDF, { | xV,nP | aDF[nP] := MyClReadCol( hRes,nP ) } )
   aDF[1] := aDF[1] / 100
   aDF[3] := aDF[3] / 100
   aDF[4] := aDF[4] / 1000
   aDF[5] := aDF[5] / 100
   aDF[6] := aDF[6] / 100
   aDF[7] := aDF[7] / 100
   aDF[8] := aDF[8] / 1000
   aDF[9] := aDF[9] / 100
Else
   aDF := { .16,663000,.035,.0054,.50,.015,.10,.0042,.003 }
EndIf
MSFreeResult( hRes )
RETURN aDF