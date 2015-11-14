// Programa.: CGEINGRE.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Mantenimiento de los Comprobante de Ingreso.
#include "FiveWin.ch"
#include "TSBrowse.ch"
#include "Btnget.ch"

MEMVAR oApl

#define CLR_PINK  nRGB( 128, 150, 150) //255, 128, 128
#define CLR_NBLUE nRGB( 255, 255, 235)

PROCEDURE CgeIngre()
   LOCAL oDlg, oLbp, oLbx, oM, oGet := ARRAY(10), nA, nP, nBan := 1
   LOCAL aCge := { "Recibos de Caja || ",.t.,.f.,"9,999,999,999.99",1 }
 oM := TIngre() ; oM:New()
oApl:Tipo := oApl:oEmp:TIPOFAC
SETKEY( VK_F11,{|| oM:GrabaI( oDlg,oLbx ) } )
DEFINE DIALOG oDlg TITLE aCge[1] + oApl:cEmpresa;
   FROM 0, 0 TO 424, 670 PIXEL
   @ 16, 00 SAY "Nro. del Ingreso" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 16, 52 GET oGet[10] VAR oM:cTipo OF oDlg PICTURE "!"  ;
      VALID( If( oM:cTipo $ "NV", .t.                     ,;
               ( MsgStop( "El Tipo es [NV]","<< OJO >>" ), .f. ) ) );
      SIZE 10,10 PIXEL
   @ 16, 62 BTNGET oGet[1] VAR oM:aMov[3] OF oDlg PICTURE "9999999"  ;
      ACTION EVAL({|| If( oM:oAyu:Mostrar()                         ,;
                        ( oM:aMov[3] := oM:oAyu:oDb:COMPROBANT      ,;
                          oGet[1]:Refresh() ), ) })                  ;
      VALID EVAL( {|| nBan := oM:BuscarMov(), aCge[3] := oM:oIng:lOK,;
                      If( aCge[3], (oGet[1]:oJump := oLbx), )       ,;
                      oLbp:aArray := oM:aPag, oM:Filtrar()          ,;
                      oLbp:Refresh()        , oLbp:DrawFooters()    ,;
                      oLbx:Refresh()        , oDlg:Update(), .t. } ) ;
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
                        ( oM:aCta[1,1] := oM:oBan:CUENTA             ,;
                          oDlg:Update(), .t. )                       ,;
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
   @ 52,116 SAY oGet[06] VAR oM:aMov[11] OF oDlg PIXEL SIZE 120,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 64, 00 SAY "Concepto Ingreso" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 64, 52 GET oGet[07] VAR oM:oMvc:CONCEPTO OF oDlg PICTURE "@!" ;
      VALID EVAL( { || If( !aCge[3], oGet[07]:oJump := oLbp, ), .t. } );
      WHEN oM:oIng:ESTADO == 0 SIZE 140,10 PIXEL UPDATE
//    VALID EVAL( { || If( EMPTY( oM:oMvc:CONCEPTO )               ,;
//            (MsgStop("Digite un Breve Concepto",">>>OJO<<<"),.f.),;
//                       (If( !aCge[3], oGet[07]:oJump := oLbp, ), .t. )) } );
   @ 200,138 SAY oGet[08] VAR oM:aMov[7]      OF oDlg PICTURE aCge[4];
      SIZE 50,10 PIXEL UPDATE
   @ 200,189 SAY oGet[09] VAR oM:aMov[8]      OF oDlg PICTURE aCge[4];
      SIZE 50,10 PIXEL UPDATE
   ACTIVAGET(oGet)

   @ 76,04 BROWSE oLbp SIZE 320, 60 PIXEL OF oDlg CELLED; // CELLED  es requerida
      COLORS CLR_BLACK, CLR_NBLUE                         // para editar Celdas
   oLbp:SetArray( oM:aPag )     // Esto es necesario para trabajar con arrays
// oLbp:nFreeze     := 1
   oLbp:nHeightCell += 4
   oLbp:nHeightHead += 4
   oLbp:bKeyDown := {|nKey| If( nKey== VK_TAB, oLbp:oJump := oLbx, ;
                            If( nKey== VK_F11 .AND. !aCge[3]       ,;
                              (oM:GrabaI( oDlg,oLbx ), oLbp:oJump:oJump := oLbx), )) }
   oLbp:SetAppendMode( .t. )                         // Activando Auto Append Mode
//   oLbp:SetDeleteMode( .t.,.f.,{ |nAt,oLbx| oF:DelArray(oLbx) },;
//                  {|oLbx| oF:Dscto( 0,oLbx ) } ) // lOnOff, lConfirm, bDelete

   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 1;
       TITLE "Clase" + CRLF +"Pago"   PICTURE "9";
       SIZE  44 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;              // Celda, Titulo, Footers
       MOVE DT_MOVE_NEXT;                    // Cursor pasa a la Sig.Columna editable
       ALIGN DT_RIGHT, DT_CENTER;            // Celda, Titulo, Footer
       PREEDIT {|nVar| oM:aTP[12] := nVar, nA := oLbp:nAt ,;
                       oM:nTP := If( nA > LEN(oM:aPag), -1, oM:aPag[nA,12] ) };
       VALID { |nVar| If(!oM:ValidaPG( ,nVar,1,nA ), .f., .t. ) };
       WHEN oM:Tarjetas( oLbp,1 )
    oLbp:aColumns[1]:bPostEdit := { |nVar| oM:aPag[nA,1] := oM:aTP[12],;
              oM:aPag[nA,2] := oM:aTP[13], oM:aPag[nA,3] := oM:aTP[14],;
              oM:aPag[nA,6] := oM:aTP[15], oM:aPag[nA,6] := oM:nTP    ,;
              oM:Tarjetas( oLbp,1 ) }
    oLbp:SetBtnGet( 1, "Buscar", { | oGet,nVar | If( oM:FormaPago( oM:aCP,@nVar ),;
                                   ( oGet:cText( nVar ), oGet:Refresh(),;
                                     oGet:KeyDown( VK_RETURN, 0 )), ) }, 16 )

   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 2;
       TITLE "Forma" + CRLF +"Pago"   PICTURE "9";
       SIZE  46 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER ;
       PREEDIT {|nVar| aCge[5] := nVar, nA := oLbp:nAt };
       VALID { |nVar| If(!oM:ValidaPG( ,nVar,2,nA ), .f.,;
                        ( oM:aPag[nA,13] := Rango( nVar,2,4 ),;
                          oM:aPag[nA,03] := oM:aTP[14], .t. )) };
       POSTEDIT { |uVar| If( oLbp:lChanged, oM:Tarjetas( oLbp,2 ), ) }
    oLbp:SetBtnGet( 2, "Buscar", { | oGet,nVar | If( oM:FormaPago( oM:aFP,@nVar ),;
                                   ( oGet:cText( nVar ), oGet:Refresh(),;
                                     oGet:KeyDown( VK_RETURN, 0 )), ) }, 16 )
   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 3;
       TITLE "Nombre Pago" ;
       SIZE 120;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_LEFT, DT_CENTER;
       FOOTER "Totales->"
   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 4;
       TITLE "Código"+CRLF+"Tarjeta" PICTURE "!!";
       SIZE 50 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_LEFT, DT_CENTER, DT_RIGHT;
       VALID { |uVar| If( Buscar( {"codigo",uVar},"cadbanco","1",;
                                   8,,4 ) == 1, .t.                   ,;
                        ( MsgStop("Está Tarjeta no Existe .."),.f.) ) };
       POSTEDIT { |uVar| If( oLbp:lChanged, oM:Tarjetas( oLbp,4 ), ) } ;
       WHEN oM:aPag[oLbp:nAt,13]
   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 5;
       TITLE "Numero"+CRLF+"Documento" PICTURE "@!";
       SIZE 70 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_LEFT, DT_CENTER, DT_RIGHT;
       FOOTER { || TRANSFORM( oM:aTP[8], "999,999,999" ) };
       WHEN oM:aPag[oLbp:nAt,2] >= 2
   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 6;
       TITLE "Valor"+CRLF+"Pago"  PICTURE "99,999,999";
       SIZE 76 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       VALID { |uVar| If( uVar >= 0, .t., ;
              (MsgStop("Valor tiene que ser Positivo",">>OJO<<"), .f.)) };
       FOOTER { || TRANSFORM( oM:aTP[1], "999,999,999" ) };
       POSTEDIT { |uVar| If( oLbp:lChanged, oM:Tarjetas( oLbp,6 ), ) }
   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 7;
       TITLE "Dscto"+CRLF+"Comercial" PICTURE "99,999,999";
       SIZE 76 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       VALID { |uVar| If( uVar >= 0, .t., ;
              (MsgStop("Valor tiene que ser Positivo",">>OJO<<"), .f.)) };
       FOOTER { || TRANSFORM( oM:aTP[2], "999,999,999" ) };
       POSTEDIT { |uVar| If( oLbp:lChanged, oM:Tarjetas( oLbp,7 ), ) };
       WHEN oM:aPag[oLbp:nAt,1] == 1
   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 8;
       TITLE "Valor"+CRLF+"Retención" PICTURE "99,999,999";
       SIZE 76 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       VALID { |uVar| If( uVar >= 0, .t., ;
              (MsgStop("Valor tiene que ser Positivo",">>OJO<<"), .f.)) };
       FOOTER { || TRANSFORM( oM:aTP[3], "999,999,999" ) };
       POSTEDIT { |uVar| If( oLbp:lChanged, oM:Tarjetas( oLbp,8 ), ) };
       WHEN oM:aPag[oLbp:nAt,2] <= 2
   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 9;
       TITLE "Ret."+CRLF+"I.V.A." PICTURE "99,999,999";
       SIZE 76 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       VALID { |uVar| If( uVar >= 0, .t., ;
              (MsgStop("Valor tiene que ser Positivo",">>OJO<<"), .f.)) };
       FOOTER { || TRANSFORM( oM:aTP[4], "999,999,999" ) };
       POSTEDIT { |uVar| If( oLbp:lChanged, oM:Tarjetas( oLbp,9 ), ) };
       WHEN oM:aPag[oLbp:nAt,2] <= 4
   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 10;
       TITLE "Ret."+CRLF+"I.C.A." PICTURE "99,999,999";
       SIZE 76 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       VALID { |uVar| If( uVar >= 0, .t., ;
              (MsgStop("Valor tiene que ser Positivo",">>OJO<<"), .f.)) };
       FOOTER { || TRANSFORM( oM:aTP[5], "999,999,999" ) };
       POSTEDIT { |uVar| If( oLbp:lChanged, oM:Tarjetas( oLbp,10 ), ) };
       WHEN oM:aPag[oLbp:nAt,2] <= 2

   oLbp:aDefault := { 1, 1, "Cartera_Efectivo", "  ", SPACE(16), 0, 0, 0, 0, 0, 0, 0, .f. }
   oLbp:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbp:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color

   @ 138, 52 LISTBOX oLbx FIELDS     ;
      oM:oMvd:CUENTA, oM:oMvd:INFC  ,;
      TRANSFORM( oM:oMvd:VALOR_DEB,"@Z 9,999,999,999.99" ),;
      TRANSFORM( oM:oMvd:VALOR_CRE,"@Z 9,999,999,999.99" ) ;
      HEADERS "Cuenta","InfC"  ,;
              "Debito","Credito";
      SIZES 400,450 SIZE 182,60 ;
      OF oDlg UPDATE PIXEL
   oLbx:nClrBackHead  := oApl:nClrBackHead
   oLbx:nClrForeHead  := oApl:nClrForeHead
   oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
   oLbx:nClrBackFocus := oApl:nClrBackFocus
   oLbx:nClrForeFocus := oApl:nClrForeFocus
   oLbx:nHeaderHeight := 18
   oLbx:GoTop()
   oLbx:oFont       := Tfont():New("Ms Sans Serif",0,-10,,.f.)
   oLbx:aColSizes   := {72,74,98,98}
   oLbx:aHjustify   := {2,2,2,2}
   oLbx:aJustify    := {0,0,1,1}
   oLbx:ladjlastcol := oLbx:lCellStyle  := .f.
   oLbx:ladjbrowse  := .t.
   oLbx:bKeyDown := {|nKey| If(nKey == VK_ESCAPE, (oM:aMov[3] := 0      ,;
                                       oM:oIng:xBlank(), oM:Filtrar( 0 ),;
                                       oLbx:Refresh(), oDlg:Update(), oGet[2]:SetFocus()),;
                            If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, oM:Detalle( oDlg,oLbx,.t. ),;
                            If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, oM:Detalle( oDlg,oLbx,.f. ),;
                            If(GetKeyState(VK_CONTROL) .AND. nKey=70 .OR. nKey=102, oM:NEW( 70,oGet ) ,;
                            If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, oM:BorraDeta( oDlg,oLbx ),) )))) }
   MySetBrowse( oLbx,oM:oMvd )
ACTIVATE DIALOG oDlg CENTERED ;
   ON INIT ( oM:Barra( oDlg,oLbx ), oM:Filtrar() )
SETKEY( VK_F11,{|| .t. } )
oM:New( 1 )
RETURN

//------------------------------------//
PROCEDURE PagosFac( cInd )
   LOCAL nA, nP, nBan, oDlg, oLbp, oM, oGet := ARRAY(6)
   LOCAL aCge := { "Recibos de Caja || ",0,.f.,"9,999,999,999.99",1 }
 oM := TIngre() ; oM:New()
If oApl:oFac:INGRE_ID > 0
   oM:oIng:Seek( {"ingre_id",oApl:oFac:INGRE_ID} )
   oM:aMov[3] := oM:oIng:COMPROBANT
   oM:cTipo   := oM:oIng:TIPO
EndIf
aCge[2] := oApl:oNit:CODIGO
   nBan := oM:BuscarMov()
oApl:Tipo := oApl:oFac:TIPO
If oM:oIng:lOK
   If cInd == "A"
      oM:AnulaCpte()
      RETURN
   EndIf
Else
   oM:aPag[1,6] := oApl:oFac:TOTALFAC
EndIf
DEFINE DIALOG oDlg TITLE aCge[1] + oApl:cEmpresa;
   FROM 0, 0 TO 230, 600 PIXEL
   @ 02, 00 SAY "Nro. del Ingreso" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 02, 53 SAY oGet[1] VAR oM:aMov[3] OF oDlg PICTURE "9999999";
      COLOR nRGB( 255,0,0 ) BORDER PIXEL SIZE 50,10
   @ 02,195 SAY "FECHA" OF oDlg RIGHT PIXEL SIZE 40,10
   @ 02,238 SAY oGet[2] VAR oM:oIng:FECHA OF oDlg BORDER PIXEL SIZE 40,10
   @ 14, 00 SAY "Nro. Factura"     OF oDlg RIGHT PIXEL SIZE 40,10
   @ 14, 53 SAY oGet[3] VAR oApl:oFac:NUMFAC  OF oDlg PICTURE "9999999999";
      BORDER PIXEL SIZE 50,10
   @ 14,116 SAY oGet[4] VAR oApl:oFac:CLIENTE OF oDlg ;
      COLOR nRGB( 128,0,255 ) PIXEL SIZE 100,10

   @ 28,04 BROWSE oLbp SIZE 280, 60 PIXEL OF oDlg CELLED; // CELLED  es requerida
      COLORS CLR_BLACK, CLR_NBLUE                         // para editar Celdas
   oLbp:SetArray( oM:aPag )     // Esto es necesario para trabajar con arrays
 //oLbp:nFreeze     := 1
   oLbp:nHeightCell += 4
   oLbp:nHeightHead += 4
//   oLbp:bKeyDown := {|nKey| If( nKey== VK_TAB, oLbp:oJump := oLbx, ;
//                            If( nKey== VK_F11 .AND. !aCge[3]       ,;
//                              (oM:GrabaI( oDlg,oLbx ), oLbp:oJump:oJump := oLbx), )) }
   oLbp:SetAppendMode( .t. )                         // Activando Auto Append Mode
//   oLbp:SetDeleteMode( .t.,.f.,{ |nAt,oLbx| oF:DelArray(oLbx) },;
//                  {|oLbx| oF:Dscto( 0,oLbx ) } ) // lOnOff, lConfirm, bDelete

   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 1;
       TITLE "Clase" + CRLF +"Pago"   PICTURE "9";
       SIZE  44 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;              // Celda, Titulo, Footers
       MOVE DT_MOVE_NEXT;                    // Cursor pasa a la Sig.Columna editable
       ALIGN DT_RIGHT, DT_CENTER;            // Celda, Titulo, Footer
       PREEDIT {|nVar| oM:aTP[12] := nVar, nA := oLbp:nAt ,;
                       oM:nTP := If( nA > LEN(oM:aPag), -1, oM:aPag[nA,12] ) };
       VALID { |nVar| If(!oM:ValidaPG( ,nVar,1,nA ), .f., .t. ) };
       WHEN oM:Tarjetas( oLbp,1 )
    oLbp:aColumns[1]:bPostEdit := { |nVar| oM:aPag[nA,1] := oM:aTP[12],;
              oM:aPag[nA,2] := oM:aTP[13], oM:aPag[nA,3] := oM:aTP[14],;
              oM:aPag[nA,6] := oM:aTP[15], oM:aPag[nA,6] := oM:nTP    ,;
              oM:Tarjetas( oLbp,1 ) }
    oLbp:SetBtnGet( 1, "Buscar", { | oGet,nVar | If( oM:FormaPago( oM:aCP,@nVar ),;
                                   ( oGet:cText( nVar ), oGet:Refresh(),;
                                     oGet:KeyDown( VK_RETURN, 0 )), ) }, 16 )
   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 2;
       TITLE "Forma" + CRLF +"Pago"   PICTURE "9";
       SIZE  46 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER ;
       PREEDIT {|nVar| aCge[5] := nVar, nA := oLbp:nAt };
       VALID { |nVar| If(!oM:ValidaPG( ,nVar,2,nA ), .f.,;
                        ( oM:aPag[nA,13] := Rango( nVar,2,4 ),;
                          oM:aPag[nA,03] := oM:aTP[14], .t. )) };
       POSTEDIT { |uVar| If( oLbp:lChanged, oM:Tarjetas( oLbp,2 ), ) }
    oLbp:SetBtnGet( 2, "Buscar", { | oGet,nVar | If( oM:FormaPago( oM:aFP,@nVar ),;
                                   ( oGet:cText( nVar ), oGet:Refresh(),;
                                     oGet:KeyDown( VK_RETURN, 0 )), ) }, 16 )
   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 3;
       TITLE "Nombre Pago" ;
       SIZE 120;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_LEFT, DT_CENTER;
       FOOTER "Totales->"
   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 4;
       TITLE "Código"+CRLF+"Tarjeta" PICTURE "!!";
       SIZE 60 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       VALID { |uVar| If( Buscar( {"codigo",uVar},"cadbanco","1",;
                                   8,,4 ) == 1, .t.                   ,;
                        ( MsgStop("Está Tarjeta no Existe .."),.f.) ) };
       POSTEDIT { |uVar| If( oLbp:lChanged, oM:Tarjetas( oLbp,4 ), ) } ;
       WHEN oM:aPag[oLbp:nAt,13]
   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 5;
       TITLE "Numero"+CRLF+"Documento" PICTURE "@!";
       SIZE 70 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       FOOTER { || TRANSFORM( oM:aTP[8], "999,999,999" ) };
       WHEN oM:aPag[oLbp:nAt,2] >= 2
   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 6;
       TITLE "Valor"+CRLF+"Pago"  PICTURE "99,999,999";
       SIZE 76 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       VALID { |uVar| If( uVar >= 0, .t., ;
              (MsgStop("Valor tiene que ser Positivo",">>OJO<<"), .f.)) };
       FOOTER { || TRANSFORM( oM:aTP[1], "999,999,999" ) };
       POSTEDIT { |uVar| If( oLbp:lChanged, oM:Tarjetas( oLbp,6 ), ) }
   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 7;
       TITLE "Dscto"+CRLF+"Comercial" PICTURE "99,999,999";
       SIZE 76 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       VALID { |uVar| If( uVar >= 0, .t., ;
              (MsgStop("Valor tiene que ser Positivo",">>OJO<<"), .f.)) };
       FOOTER { || TRANSFORM( oM:aTP[2], "999,999,999" ) };
       POSTEDIT { |uVar| If( oLbp:lChanged, oM:Tarjetas( oLbp,7 ), ) };
       WHEN oM:aPag[oLbp:nAt,1] == 1
   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 8;
       TITLE "Valor"+CRLF+"Retención" PICTURE "99,999,999";
       SIZE 76 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       VALID { |uVar| If( uVar >= 0, .t., ;
              (MsgStop("Valor tiene que ser Positivo",">>OJO<<"), .f.)) };
       FOOTER { || TRANSFORM( oM:aTP[3], "999,999,999" ) };
       POSTEDIT { |uVar| If( oLbp:lChanged, oM:Tarjetas( oLbp,8 ), ) };
       WHEN oM:aPag[oLbp:nAt,2] <= 2
   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 9;
       TITLE "Ret."+CRLF+"I.V.A." PICTURE "99,999,999";
       SIZE 76 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       VALID { |uVar| If( uVar >= 0, .t., ;
              (MsgStop("Valor tiene que ser Positivo",">>OJO<<"), .f.)) };
       FOOTER { || TRANSFORM( oM:aTP[4], "999,999,999" ) };
       POSTEDIT { |uVar| If( oLbp:lChanged, oM:Tarjetas( oLbp,9 ), ) };
       WHEN oM:aPag[oLbp:nAt,2] <= 4
   ADD COLUMN TO BROWSE oLbp DATA ARRAY ELEMENT 10;
       TITLE "Ret."+CRLF+"I.C.A." PICTURE "99,999,999";
       SIZE 76 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       VALID { |uVar| If( uVar >= 0, .t., ;
              (MsgStop("Valor tiene que ser Positivo",">>OJO<<"), .f.)) };
       FOOTER { || TRANSFORM( oM:aTP[5], "999,999,999" ) };
       POSTEDIT { |uVar| If( oLbp:lChanged, oM:Tarjetas( oLbp,10 ), ) };
       WHEN oM:aPag[oLbp:nAt,2] <= 2

   oLbp:aDefault := { 1, 1, "Cartera_Efectivo", "  ", SPACE(16), 0, 0, 0, 0, 0, 0, 0, .f. }
   oLbp:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbp:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color
   @ 94,100 BUTTON oGet[5] PROMPT "GRABAR"   SIZE 40,12 OF oDlg ACTION;
      (If( (oM:aTP[8]+oM:aTP[9]+oM:aTP[10]) > 0               ,;
      (If(  oM:aTP[8] > 0 .AND. oM:aTP[8] > oApl:oFac:TOTALFAC,;
         ( MsgStop( "Pago Mayor que el Saldo",">>> OJO <<<" ) ,;
           oLbp:SetFocus() ), (aCge[3] := .t., oDlg:End()) )) ,;
         ( MsgStop("Imposible grabar este Ingreso"), oLbp:SetFocus()) )) PIXEL
   @ 94,150 BUTTON oGet[6] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)

ACTIVATE DIALOG oDlg CENTERED
If aCge[3]
   nBan    := oM:Listado( nBan )
   oM:oBan:Seek( {"empresa",oApl:nEmpresa,"banco",oM:aBan[nBan,2]} )
   oM:aCar := { { LTRIM(STR(oApl:oFac:NUMFAC))+oApl:Tipo,oM:aTP[8] } }
   oM:aMov[10]       := aCge[2]
   oM:aMov[11]       := oApl:oNit:NOMBRE
   oM:oMvc:CONCEPTO  := PADR( "PAGOS A FACT."+oM:aCar[1,1],40 )
   oM:oIng:BANCO     := oM:oBan:BANCO
   oM:oIng:CTA_CTE   := oM:oBan:CTA_CTE
   oM:oIng:CODIGONIT := oApl:oFac:CODIGO_NIT
   oM:oIng:FORMAPAGO := nBan
   If oM:oMvc:CONTROL > 0
      oM:oMvd:dbEval( {|o| oM:Avanza( ,o:CUENTA )                                       ,;
                           If( oM:oMvc:ESTADO  <= 1                                     ,;
                             (      o:EMPRESA := -9                                     ,;
                               oM:GrabaPago( o:CUENTA,oM:aTL[4],-oM:aTL[5],oM:aTL[6],1 ),;
                               Acumular( 2, o, 3, 3, .f., .f. ) ), ) }                  ,;
                      {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,"control",oM:oMvc:CONTROL} )
      oM:oMvc:CONSECUTIV := 0
   EndIf
   oM:GrabaI( oDlg )
   oApl:oFac:INGRE_ID := oM:oIng:INGRE_ID
   oApl:oFac:Update(.f.,1)
EndIf
oM:New( 1 )
RETURN

//------------------------------------//
CLASS TIngre FROM TMov

 DATA aBan AS ARRAY INIT {}
 DATA aCta AS ARRAY INIT {}
 DATA aDF  AS ARRAY INIT { .16,663000,.035,.0054,.50,.015,.10,.0042,.003 }
 DATA aTP  AS ARRAY INIT { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 }
 DATA aCP  AS ARRAY INIT {}
 DATA aFP  AS ARRAY INIT {}
 DATA aPag AS ARRAY INIT { { 1, 1, "Cartera_Efectivo", "  ", SPACE(16), 0, 0, 0, 0, 0, 0, 0, .f. } }
 DATA cTipo   INIT "N"
 DATA nSgte   INIT oApl:oEmp:INGRESO + 1
 DATA aCar, nTP, oAyu, oBan, oIng, oSay

 METHOD NEW( nFin,oGet ) Constructor
 METHOD BuscarMov()
 METHOD Fechas( lOK,nMsg )
 METHOD BuscarCta( lNew )
 METHOD Tarjetas( oLbx,nC )
 METHOD AnulaCpte( oDlg,oLbx )
 METHOD GrabaI( oDlg,oLbx )
 METHOD Facturas()
 METHOD FormaPago( aCFP,nVar )
 METHOD ValidaFP( aFac,aGT,oLbf )
 METHOD ValidaPG( aGT,nPag,nSal,nA )
 METHOD Listado( nBan )
 METHOD Barra( oDlg,oLbx )
ENDCLASS

//------------------------------------//
METHOD NEW( nFin,oGet ) CLASS TIngre
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
   aFor := ArrayCombo( "CPAGO",1 )
   AEVAL( aFor, {|x| AADD( ::aCP, { TRIM(x[1])+"_",INT(VAL(x[2])) } ) } )
   aFor := ArrayCombo( "FPAGO" )
   AEVAL( aFor, {|x| AADD( ::aFP, { x[1],INT(VAL(x[2])) } ) } )
   ::aCar := {}
   ::aCta := Cuentas( ::aMov[2] )
   ::oAyu := TChq() ; ::oAyu:New( 1 )
   ::oBan := oApl:Abrir( "cgebanco","empresa, banco, cta_cte",,,10 )
   ::oIng := oApl:Abrir( "ingresoc","empresa, comprobant",,,10 )
   ::oIng:Seek( {"empresa",oApl:nEmpresa,"comprobant",::aMov[3],"tipo",::cTipo} )
   ::oFte:oDb:Seek( {"fuente",::aMov[2]} )
   oApl:oEmp:XLoad()
ElseIf nFin == 70
   //Activar Cambio de Fecha
   If ::oIng:ESTADO == 1
      MsgStop( STR(::aMov[3]),"Pase" )
      ::oIng:ESTADO := 0
      oGet[8]:Refresh()
      oGet[2]:SetFocus()
   EndIf
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
If ::oIng:Seek( {"empresa",oApl:nEmpresa,"comprobant",::aMov[3],"tipo",::cTipo} )
   ::oBan:Seek( {"empresa",oApl:nEmpresa,"banco",::oIng:BANCO,"cta_cte",::oIng:CTA_CTE} )
   ::aCta[1,1] := ::oBan:CUENTA
Else
   ::oIng:FECHA := DATE()
   ::oIng:FORMAPAGO := 1
   ::oBan:Seek( {"empresa",oApl:nEmpresa,"banco",::aBan[1,2]} )
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
   FOR nR := 1 TO LEN( ::aPag  )
      If ::aPag[nR,6] > 0
         If ::aPag[nR,12] == 0
            cQry := "INSERT INTO ingresod VALUES ( null, " +;
             LTRIM(STR(::oIng:INGRE_ID)) + ", "  + LTRIM(STR(::aPag[nR,01]))+  ", " +;
               LTRIM(STR(::aPag[nR,02])) + ", '" +   ALLTRIM(::aPag[nR,04]) + "', '"+;
                 ALLTRIM(::aPag[nR,05]) + "', "  + LTRIM(STR(::aPag[nR,06]))+  ", " +;
               LTRIM(STR(::aPag[nR,07])) + ", "  + LTRIM(STR(::aPag[nR,08]))+  ", " +;
               LTRIM(STR(::aPag[nR,09])) + ", "  + LTRIM(STR(::aPag[nR,10]))+  ", " +;
               LTRIM(STR(::aPag[nR,11])) + " )"
         Else
            cQry := "UPDATE ingresod SET clasepag = "  + LTRIM(STR(::aPag[nR,01])) +;
                                     ", formapago = "  + LTRIM(STR(::aPag[nR,02])) +;
                                        ", codigo = '" +   ALLTRIM(::aPag[nR,04])  +;
                                    "', numcheque = '" +   ALLTRIM(::aPag[nR,05])  +;
                                       "', valorp = "  + LTRIM(STR(::aPag[nR,06])) +;
                                        ", dsctos = "  + LTRIM(STR(::aPag[nR,07])) +;
                                        ", retfte = "  + LTRIM(STR(::aPag[nR,08])) +;
                                        ", retiva = "  + LTRIM(STR(::aPag[nR,09])) +;
                                        ", retica = "  + LTRIM(STR(::aPag[nR,10])) +;
                                      ", comision = "  + LTRIM(STR(::aPag[nR,11])) +;
                    " WHERE row_id = " + LTRIM(STR(::aPag[nR,12]))
         EndIf
         MSQuery( oApl:oMySql:hConnect,cQry )
      ElseIf ::aPag[nR,12] > 0
         MSQuery( oApl:oMySql:hConnect,"DELETE FROM ingresod WHERE row_id = "+;
                  LTRIM(STR(::aPag[nR,12])) )
      EndIf
   NEXT nR
EndIf
 ::aPag := {}
cQry := "SELECT clasepag, formapago, codigo, numcheque, valorp, " +;
               "dsctos, retfte, retiva, retica, comision, row_id "+;
        "FROM ingresod "    +;
        "WHERE ingre_id = " + LTRIM(STR(::oIng:INGRE_ID))
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nR   := MSNumRows( hRes )
While nR > 0
   cQry := MyReadRow( hRes )
   AEVAL( cQry, { | xV,nP | cQry[nP] := MyClReadCol( hRes,nP ) } )
   AADD( ::aPag,{ cQry[01], cQry[02], ::aCP[cQry[1],1] + ::aFP[cQry[2],1],;
                  cQry[03], cQry[04], cQry[05], cQry[06],;
                  cQry[07], cQry[08], cQry[09], cQry[10],;
                  cQry[11],    Rango( cQry[02],2,4 ) } )
   nR --
EndDo
MSFreeResult( hRes )
If LEN( ::aPag ) == 0
   AADD( ::aPag,{ 1, 1, "Cartera_Efectivo", "  ", SPACE(16), 0, 0, 0, 0, 0, 0, 0, .f. } )
EndIf
 ::Tarjetas()
RETURN NIL

//------------------------------------//
METHOD Tarjetas( oLbx,nC ) CLASS TIngre
   LOCAL lEdit := .t., nA, nF, nPorT
If oLbx # NIL
   nA := oLbx:nAt
   If nA > LEN(::aPag)
      nF := If( nA > 2, 1, nA-1 )
      If EMPTY( ::aPag[nF,01] ) .OR. oLbx:nCell # 1
         MsgStop( "Primero Digite Clase de Pago","Nuevo" )
         ::aPag[nF,01] := ::aPag[nF,02] := 1
         oLbx:nAt   := oLbx:nLen := oLbx:nRowPos := nA
         oLbx:nCell := 1 ; lEdit := .f.
         oLbx:HiliteCell( 1 ) ; oLbx:Refresh(.t.)
         oLbx:DrawSelect()
      EndIf
   Else
      If ::aPag[nA,13] .AND. EMPTY( ::aPag[nA,4] ) .AND. nC > 4
         MsgStop( "Primero Digite el Código del Banco",">> OJO <<" )
         oLbx:nRowPos := nA
         oLbx:nCell   := 3 ; lEdit := .f.
         oLbx:HiliteCell( 3 ) ; oLbx:Refresh(.t.)
         oLbx:DrawSelect()
      ElseIf Rango( ::aPag[nA,2],3,4 ) .AND. nC # 7 .AND. ::aPag[nA,6] > 0
         If nC # 9
            ::aPag[nA,9] := ::aPag[nA,9] * ::aDF[7] * 100
         EndIf
         nPorT := Buscar( "SELECT " + {"debito","credito"}[::aPag[nA,2]-2] +;
                       " FROM cadbanco WHERE codigo = '" + TRIM(::aPag[nA,4]) + "'","CM",,8,,4 )
         ::aTP[2] := ::aPag[nA,6] - ::aPag[nA,9]
         ::aPag[nA,08] := ROUND( ::aTP[2]    * ::aDF[6],0 )  //Ret.FTE
         ::aPag[nA,09] := ROUND( ::aPag[nA,9] * ::aDF[7],0 ) //Ret.IVA
         ::aPag[nA,10] := ROUND( ::aTP[2]    * ::aDF[8],0 )  //Ret.ICA
         ::aPag[nA,11] := ROUND( ::aTP[2] * nPorT / 100,2 )  //Comision Bancaria
      ElseIf !::aPag[nA,13]
            ::aPag[nA,04] := "  "
            ::aPag[nA,11] := 0
         If ::aPag[nA,02] == 1
            ::aPag[nA,05] := SPACE(16)
         ElseIf ::aPag[nA,02] >= 5
            ::aPag[nA,07] := ::aPag[nA,08] := ::aPag[nA,09] := ::aPag[nA,10] := 0
         EndIf
      EndIf
         If ::aPag[nA,01] == 5
            ::aPag[nA,07] := 0
         EndIf
   EndIf
EndIf
If lEdit
   // aTP[07] 7.Dscto + If( FPAGO <= 2, (8.Ret.Fte + 9.Ret.Iva + 10.Ret.Ica), 0 )
   // aTP[08] Valor Cartera
   // aTP[09] Ing.Varios
   // aTP[10] Comisiones Por Venta
   // aTP[11] Ahorro Tercero
   AFILL( ::aTP,0,1,11 )
   AEVAL( ::aPag, { | e | nA := e[7] + If( e[2] <= 2, (e[8] + e[9]  + e[10]), 0 ),;
                          ::aTP[1] += e[06], ::aTP[2] += e[07], ::aTP[3] += e[08],;
                          ::aTP[4] += e[09], ::aTP[5] += e[10], ::aTP[6] += e[11],;
                          ::aTP[7] += nA   , ::aTP[ e[1]+7 ] += ( e[6] + nA ) } )
   If oLbx # NIL
      oLbx:Refresh()
      oLbx:DrawFooters()
   EndIf
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
If ::oIng:ESTADO == 2 .OR. ::oMvc:CONSECUTIV > 0
   RETURN NIL
ElseIf oLbx # NIL
  If !MsgYesNo( "Grabar este Ingreso","QUIERE" )
     RETURN NIL
  EndIf
EndIf

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
   If ::oFte:oDb:CARTERA .AND. LEN( ::aCar ) == 0 .AND. ::aTP[8] > 0
      ::Facturas( .f. )
   EndIf
   If oLbx # NIL
      //nJ := ::oBan:ROW_ID
      ::Listado( 1 )
      //::oBan:Seek( {"row_id",nJ} )
   EndIf
   ::aMov[1] := oApl:cPer := NtChr( ::oIng:FECHA,"1" )
   ::aMov[4] := ""
   ::oMvc:FECHA    := ::oIng:FECHA
   ::oMvc:CODIGONIT:= ::oIng:CODIGONIT
   ::oMvc:VALORB   := ::nTP
   aCta := { { ::aCta[1,1],::nTP - ::aTP[14] ,0,"",0,"" } }
   cNom := { ::aDF[3],::aDF[9],0,::aDF[6],::aDF[7],::aDF[8],0 }
   //        "RET","IVA","ICA","COM" }
      //AEVAL( <aMatriz> , <bBloque> , <nInicio>, <nPosiciones> )
   //Deducciones del Pago con Tarjeta
   AEVAL( ::aPag,{|x| If( Rango( x[2],3,4 ),;
                        ( cBan := x[04] + "-" + LEFT( ALLTRIM(x[05]),6 )         ,;
                          AADD( aCta,{ ::aTP[12],x[06],0,cBan,"TAR",::aTP[13] } ),;
                          AADD( aCta,{ ::aTP[12],0,x[08],cBan,"RET",::aTP[13] } ),;
                          AADD( aCta,{ ::aTP[12],0,x[09],cBan,"IVA",::aTP[13] } ),;
                          AADD( aCta,{ ::aTP[12],0,x[10],cBan,"ICA",::aTP[13] } ),;
                          AADD( aCta,{ ::aTP[12],0,x[11],cBan,"COM",::aTP[13] } ) ), ) } )
   AEVAL( ::aPag,{|x| If( Rango( x[2],3,4 ),;
                        ( AADD( aCta,{ ::aCta[07,1],x[08],0,"X" ,cNom[4],"" } ),;
                          AADD( aCta,{ ::aCta[08,1],x[09],0,"X" ,cNom[5],"" } ),;
                          AADD( aCta,{ ::aCta[09,1],x[10],0,"X" ,cNom[6],"" } ),;
                          AADD( aCta,{ ::aCta[10,1],x[11],0,"X" ,cNom[7],"" } ),;
                          ::aTP[3] -= x[8], ::aTP[4] -= x[9], ::aTP[5] -= x[10]), ) } )
   //7_Dscto, 8_Ret.Fte, 9_Ret.Iva, 10_Ret.Ica
                          AADD( aCta,{ ::aCta[4,1],::aTP[2],0,"",0      ,"" } )
                          AADD( aCta,{ ::aCta[5,1],::aTP[3],0,"",cNom[1],"" } )
                          AADD( aCta,{ ::aCta[8,1],::aTP[4],0,"",cNom[2],"" } )
                          AADD( aCta,{ ::aCta[9,1],::aTP[5],0,"",cNom[3],"" } )
   //Ing.Varios, Comisiones y Ahorro Tercero
                          AADD( aCta,{ ::aCta[3,1],0,::aTP[09],"",0,"" } )
                          AADD( aCta,{ ::aCta[3,1],0,::aTP[10],"",0,"" } )
                          AADD( aCta,{ ::aCta[1,1],0,::aTP[11],"",0,"" } )
   //5.Bonos, 6.P.Redimidos
 //AEVAL( ::aPag,{|x| If( x[2] >= 5,;
 //                     ( AADD( aCta,{ ::aCta[3,1],x[6],0,"",0,"" } ),;
 //                             aCta[1,2] -= x[6] ), ) } )
   If LEN( ::aCar ) > 0
      AEVAL( ::aCar, {|a| AADD( aCta,{ ::aCta[2,1],0,a[2],a[1],0,"" } ) } )
   Else
      AADD( aCta,{ ::aCta[2,1],0,::aTP[8],"",0,"" } )
   EndIf
   cNom := ::oMvc:CONCEPTO
   If EMPTY(cNom)
      MsgGet( "Descripcion Ingreso","Concepto",@cNom )
   EndIf
   ::oMvc:CONCEPTO := UPPER( cNom )
   ::oCtl:Seek( {"empresa",oApl:nEmpresa,"ano_mes",::aMov[1]} )
   ::oNit:oDb:Seek( {"codigo_nit",::aTP[15]} )
   ::aTL := { 0,0,"","",0,1,0 }
   cNit  := LTRIM(STR(::oNit:oDb:CODIGO))
   ::oNit:oDb:Seek( {"codigo_nit",::oIng:CODIGONIT} )

   FOR nJ := 1 TO LEN( aCta )
      If (aCta[nJ,2] + aCta[nJ,3]) == 0
         LOOP
      EndIf
      ::aMov[26] := 0
      ::oPuc:oDb:Seek( {"empresa",oApl:nPuc,"cuenta",aCta[nJ,1]} )
      cNom := { TRIM(::oPuc:oDb:INFA),TRIM(::oPuc:oDb:INFB),;
                TRIM(::oPuc:oDb:INFC),TRIM(::oPuc:oDb:INFD),;
                "","","","",0 }
      FOR nC := 1 TO 4
         do case
         Case cNom[nC] == "BASE"
            ::aMov[26] := aCta[nJ,5] * If( nJ == 7, 1000, 100 )
            ::aMov[28] := ROUND( aCta[nJ,2] / aCta[nJ,5] ,0 )
            cNom[4+nC] := If( EMPTY(::aMov[28]), "", LTRIM(STR(::aMov[28],10,0)) )
         Case cNom[nC] == "CHEQUE"
            If ISALPHA( aCta[nJ,5] )
               cNom[4+nC] := aCta[nJ,5]
            Else
               cNom[4+nC] := ALLTRIM(::oIng:DOCUMENTO)
            EndIf
         Case cNom[nC] == "COD-VAR"
            cNom[4+nC] := ALLTRIM(aCta[nJ,1])
         Case cNom[nC] == "CTA-CTE"
            cNom[4+nC] := If( EMPTY(aCta[nJ,6]), ALLTRIM(::oIng:CTA_CTE), aCta[nJ,6] )
         Case cNom[nC] == "DOCUMENTO"
            If ISALPHA( aCta[nJ,5] )
               cNom[4+nC] := aCta[nJ,4]
            Else
               cNom[4+nC] := LTRIM(STR(::oIng:COMPROBANT))
            EndIf
         Case cNom[nC] == "FACTURA"
            cNom[4+nC] := aCta[nJ,4]
         Case cNom[nC] == "FECHA"
            cNom[4+nC] := DTOC( ::oIng:FECHA )
         Case cNom[nC] == "NIT"
            If aCta[nJ,4] == "X"
               cNom[nC+4] := cNit
               cNom[9]    := ::aTP[15]
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
      ::oMvd:LIBRO      := 1
      ::oMvd:PTAJE      := ::aMov[26]
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
RETURN NIL

//------------------------------------//
METHOD FormaPago( aCFP,nVar ) CLASS TIngre
   LOCAL lOK := .f., oDlg, oLbx
   LOCAL bHacer := {|| nVar := oLbx:nAt, lOK := .t., oDlg:End() }
DEFINE DIALOG oDlg TITLE "Código de Pagos" FROM 4,10 TO 14,40
   @ 02,04 LISTBOX oLbx FIELDS "", "";
      HEADERS "CODIGO", "NOMBRE"     ;
      SIZE 100,72       ;
      FIELDSIZES 50, 84 ;
      OF oDlg PIXEL     ;
      ON CLICK EVAL( bHacer )
    oLbx:nClrBackHead := oApl:nClrBackHead
    oLbx:nLineStyle:= 2
    oLbx:nClrLine  := nRgb(184,196,224)
    oLbx:nAt       := 1
    oLbx:bLine     := {|| { STR(aCFP[oLbx:nAt][2],3), aCFP[oLbx:nAt][1] } }
    oLbx:bGoTop    := {|| oLbx:nAt := 1 }
    oLbx:bGoBottom := {|| oLbx:nAt := EVAL( oLbx:bLogicLen ) }
    oLbx:bSkip     := {|nWant,nOld| nOld := oLbx:nAt, oLbx:nAt += nWant,;
                        oLbx:nAt := MAX( 1, MIN( oLbx:nAt, EVAL( oLbx:bLogicLen ) ) ),;
                        oLbx:nAt - nOld }
    oLbx:bLogicLen := {|| LEN( aCFP ) }
    oLbx:bKeyDown  := {|nKey| If( nKey=VK_RETURN, EVAL( bHacer ), ) }
    oLbx:lHScroll  := .f.
    oLbx:cAlias    := "Array"
ACTIVATE DIALOG oDlg CENTERED
RETURN lOK

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
aGT  := { 0,0,0,::aTP[8],.f. }
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
   @ 02, 62 SAY oGet[1] VAR ::aTP[8] OF oDlg PICTURE "9,999,999,999.99";
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
                                             aGT[4] := ::aTP[8] - aGT[2],;
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
   If ::aTP[8] > aGT[2]
      AADD( ::aCar, { "",::aTP[8] - aGT[2] } )
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
   aGT[4] := ::aTP[8] - aGT[2]
   oLbf:DrawFooters()
/*
   LOCAL aIng, aRes, cQry, hRes, nP, nR
If !MsgYesNo( "Desea cambiar el Formato","INGRESOD" )
   RETURN NIL
EndIf
MsgInfo( "Voy hacer el Cambio" )
aRes := "SELECT c.row_id, c.formapago, c.codigo, c.documento, d.orden, d.valor "+;
        "FROM ingreso_d d, cgeingre c "    +;
        "WHERE c.empresa    = d.empresa"   +;
         " AND c.comprobant = d.comprobant"+;
         " AND c.tipo       = d.tipo"      +;
         " AND c.empresa    = " + LTRIM(STR(oApl:nEmpresa))+;
        " ORDER BY c.row_id"
//        "FROM cgeingre c LEFT JOIN ingreso_d d "+;
//         "USING( empresa, comprobant, tipo ) " +;
//        "WHERE c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nR   := MSNumRows( hRes )
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
aIng := { aRes[1],aRes[2],aRes[3],aRes[4],0,0,0,0,0,0,0,0,0,0 }
While nR > 0
   aIng[ aRes[5]+4 ] += aRes[6]
   If (nR --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nR == 0 .OR. aIng[1] # aRes[1]
      If aIng[6] > 0
         nP := 1
      Else
         aIng[6] := aIng[7]
         nP := 2
      EndIF
      aIng[06] -= aIng[08]
      aIng[09] += aIng[11]
// aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
//              { "ingre_id"  , "N", 11, 00, },;
//              { "clasepag"  , "N", 01, 00, },;
//              { "formapago" , "N", 01, 00, },;
//              { "codigo"    , "C", 02, 00, },;
//              { "numcheque" , "C", 16, 00, },;
//              { "valorp"    , "N", 14, 02, },;
//              { "dsctos"    , "N", 14, 02, },;
//              { "retfte"    , "N", 14, 02, },;
//              { "retiva"    , "N", 14, 02, },;
//              { "retica"    , "N", 14, 02, },;
//              { "comision"  , "N", 14, 02, } }
      cQry := "INSERT INTO ingresod VALUES ( null, " +;
               LTRIM(STR(aIng[01])) + ", "  + LTRIM(STR(nP))      +  ", " +;
               LTRIM(STR(aIng[02])) + ", '" +   ALLTRIM(aIng[03]) + "', '"+;
                 ALLTRIM(aIng[04]) + "', "  + LTRIM(STR(aIng[06]))+  ", " +;
               LTRIM(STR(aIng[08])) + ", "  + LTRIM(STR(aIng[09]))+  ", " +;
               LTRIM(STR(aIng[12])) + ", "  + LTRIM(STR(aIng[13]))+  ", " +;
               LTRIM(STR(aIng[14])) + " )"
      MSQuery( oApl:oMySql:hConnect,cQry )
      aIng := { aRes[1],aRes[2],aRes[3],aRes[4],0,0,0,0,0,0,0,0,0,0 }
   EndIf
EndDo
MSFreeResult( hRes )
MsgInfo( "PASE INGRESOD" )
*/
/*
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
METHOD ValidaPG( aGT,nPag,nSal,nA ) CLASS TIngre
   LOCAL lOK := .t.
If aGT == NIL
   If nSal == 1
      aGT  := "Clase"
      nSal := LEN( ::aCP )
   Else
      aGT  := "Forma"
      nSal := LEN( ::aFP )
   EndIf
   If nPag <= 0 .OR. nPag > nSal
      MsgStop( aGT+" de Pago va de 1 a" +STR(nSal,3) ,">> OJO Ver Ayuda<<" )
      lOK := .f.
   EndIf
   If lOK
      If ::nTP == -1
       //MsgInfo( "Hola 1",STR(nPag) )
         ::aTP[12] := ::aTP[13] := 1
         ::aTP[15] := "  "
         ::nTP     := 0
      Else
       //MsgInfo( "Hola 2",STR(nPag) )
         ::aTP[12] := ::aPag[nA,1]
         ::aTP[13] := ::aPag[nA,2]
         ::aTP[15] := ::aPag[nA,4]
         ::nTP     := ::aPag[nA,6]
      EndIf
      nA := If( aGT == "Clase", 12, 13 )
      ::aTP[nA]    := nPag
      ::aTP[14]    := ::aCP[::aTP[12],1] + ::aFP[::aTP[13],1]
   EndIf
ElseIf nPag <= 0
   MsgStop("Valor tiene que ser Positivo",">> OJO <<")
   lOK := .f.
ElseIf nPag > nSal
   MsgStop( "Pago Mayor que el Saldo",">> OJO <<" )
   lOK := .f.
ElseIf (aGT[2] + nPag - aGT[3]) > ::aTP[8]
   MsgStop( "Pago Mayor que el Total",">> OJO <<" )
   lOK := .f.
EndIf
RETURN lOK

//----------------------------------------------//
METHOD Listado( nBan ) CLASS TIngre
If nBan == NIL
   If ::oMvc:CONTROL > 0
      If CgeLista( ::oMvc:CONTROL,{ LTRIM(::oIng:DOCUMENTO),;
                   ::oBan:NOMBRE,::oIng:CTA_CTE,"" },"Ingreso" )
         ::oIng:ESTADO := 1 ; ::oIng:Update(.t.,1)
      EndIf
   EndIf
Else
   ::aTP[12] := ::aTP[13] := ""
   ::aTP[14] := ::nTP := 0
   AEVAL( ::aPag,{|x| If( Rango( x[2],3,4 ), ::aTP[14] += x[6], ) } )
   AEVAL( ::aTP ,{|x| ::nTP += x },8,4 )
   ::nTP -= ::aTP[7]
   If ::aTP[14] > 0
      If (::nTP - ::aTP[14]) == 0
         nBan := 2
      EndIf
    //::oBan:Seek( {"empresa",oApl:nEmpresa,"banco",::aBan[2,2]} )
      ::aTP[12] := ::oBan:CUENTA
      ::aTP[13] := ALLTRIM(::oBan:CTA_CTE)
      ::aTP[15] := ::oBan:CODIGO_NIT
   EndIf
EndIf
RETURN nBan

//------------------------------------//
METHOD Barra( oDlg,oLbx ) CLASS TIngre
   LOCAL oBar, oBot := ARRAY(7)
DEFINE BUTTONBAR oBar OF oDlg 3DLOOK SIZE 28,28

DEFINE BUTTON oBot[1] RESOURCE "DEDISCO"  OF oBar NOBORDER;
   TOOLTIP "Grabar (F11)"  ACTION;
    (If( EMPTY(::oIng:CODIGONIT) .OR. (::aTP[8]+::aTP[9]+::aTP[10]) <= 0,;
       ( MsgStop("Imposible grabar este Ingreso") ),;
       ( ::GrabaI( oDlg,oLbx ) )))
DEFINE BUTTON oBot[2] RESOURCE "IMPRIMIR" OF oBar NOBORDER ;
   TOOLTIP "Imprimir Ingreso" ;
   ACTION ::Listado()
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