// Programa.: CGECHEQU.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Generacion de Cheques y su Comprobante de Egreso.
#include "FiveWin.ch"
#include "TSBrowse.ch"
#include "Btnget.ch"

MEMVAR oApl

#define CLR_PINK  nRGB( 128, 150, 150) //255, 128, 128
#define CLR_NBLUE nRGB( 255, 255, 235)

FUNCTION CgeChequ()
   LOCAL aCge := { "CHEQUES Y EGRESOS || ",.t.,.f. }
   LOCAL nBan := 1
   LOCAL oM, oGet := ARRAY(12)
 oM := TPago() ; oM:New()
SETKEY( VK_F5,{|| If( oM:oChq:lOK, ( oM:oChq:ESTADO := 0,;
                      Guardar( oM:oChq,.f.,.f. )        ,;
                      oGet[3]:SetFocus() ), ) } )
DEFINE DIALOG oM:oDlg TITLE aCge[1] + oApl:cEmpresa;
   FROM 0, 0 TO 400, 670 PIXEL
   @ 16, 00 SAY "Código del Banco" OF oM:oDlg RIGHT PIXEL SIZE 50,10
   @ 16, 52 COMBOBOX oGet[1] VAR nBan ITEMS ArrayCol( oM:aBan,1 ) SIZE 90,99;
      VALID EVAL( {|| oM:oBan:Seek( {"empresa",oApl:nEmpresa   ,;
                                     "banco",oM:aBan[nBan,2]} ),;
                      oM:aChq[1] := oM:oBan:BANCO              ,;
                      oM:aChq[2] := oM:oBan:CTA_CTE            ,;
                      oM:oDlg:Update(), .t. }) OF oM:oDlg PIXEL UPDATE
   @ 16,160 SAY "Sgte. Egreso" + STR( oM:aChq[4],7 ) OF oM:oDlg PIXEL SIZE 70,10;
      UPDATE COLOR nRGB( 255,0,0 )
   @ 28, 00 SAY "Cuenta Corriente" OF oM:oDlg RIGHT PIXEL SIZE 50,10
   @ 28, 52 GET oGet[2] VAR oM:aChq[2] OF oM:oDlg PICTURE "@!"        ;
      VALID EVAL( {|| If( oM:oBan:Seek( {"empresa",oApl:nEmpresa     ,;
                                         "banco"  ,oM:aChq[1]        ,;
                                         "cta_cte",oM:aChq[2]} )     ,;
                        ( oM:aChq[5] := oM:oBan:NUM_CHEQUE + 1       ,;
                          oM:oDlg:Update(), .t. )                    ,;
                        ( MsgStop("Está Cuenta NO EXISTE"), .f. ) ) });
      SIZE 40,10 PIXEL UPDATE
   @ 28,160 SAY "Nro. Egreso" + STR( oM:oChq:COMPROBANT,7 ) OF oM:oDlg PIXEL SIZE 70,10;
      UPDATE COLOR nRGB( 255,128,64 )
   @ 40, 00 SAY "Nro. del Cheque" OF oM:oDlg RIGHT PIXEL SIZE 50,10
   @ 40, 52 BTNGET oGet[3] VAR oM:aChq[3] OF oM:oDlg PICTURE "9999999999";
      ACTION EVAL({|| If( oM:oAyu:Mostrar()                             ,;
                        ( oM:aChq[1] := oM:oAyu:oDb:BANCO               ,;
                          oM:aChq[2] := oM:oAyu:oDb:CTA_CTE             ,;
                          oM:aChq[3] := oM:oAyu:oDb:CHEQUE              ,;
                          nBan := ArrayValor(oM:aBan,oM:aChq[1],,.t.)   ,;
                          oM:oBan:Seek( {"empresa",oApl:nEmpresa        ,;
                                         "banco",oM:aBan[nBan,2]} )     ,;
                          oGet[3]:Refresh() ), ) })                      ;
      VALID EVAL( {|| oM:BuscarMov()                                    ,;
                      If( oM:oChq:lOK, oGet[3]:oJump := oM:oLbx, ), .t.});
      SIZE 56,10 PIXEL RESOURCE "BUSCAR"
    oGet[3]:cToolTip := "[F5] PARA CAMBIAR ESTADO DEL CHEQUE"

   @ 40,160 SAY "Sgte. Cheque" + STR( oM:aChq[5] ) OF oM:oDlg PIXEL SIZE 80,10;
      UPDATE COLOR nRGB( 0,128,255 )
   @ 52, 00 SAY "Fecha [DD.MM.AA]" OF oM:oDlg RIGHT PIXEL SIZE 50,10
   @ 52, 52 GET oGet[4] VAR oM:oChq:FECHA OF oM:oDlg SIZE 40,10 PIXEL UPDATE;
      VALID oM:Fechas( oM:oChq:lOK,1 ) ;
      WHEN  oM:oChq:ESTADO == 0
   @ 52,160 SAY "ESTADO : " + oM:aMov[05] OF oM:oDlg PIXEL SIZE 80,10;
      UPDATE COLOR nRGB( 255,0,128 )
   @ 64, 00 SAY "Nit Beneficiario" OF oM:oDlg RIGHT PIXEL SIZE 50,10
   @ 64, 52 BTNGET oGet[05] VAR oM:aMov[10] OF oM:oDlg PICTURE "9999999999"    ;
      ACTION EVAL({|| If(oM:oNit:Mostrar(), (oM:aMov[10] := oM:oNit:oDb:CODIGO,;
                         oGet[5]:Refresh(), oGet[5]:lValid(.f.)), ) })         ;
      VALID EVAL( {|| If( oM:oNit:oDb:Seek( {"codigo",oM:aMov[10]} )          ,;
                     ( oM:oChq:CODIGONIT := oM:oNit:oDb:CODIGO_NIT            ,;
                       oM:aMov[11] := oM:oNit:oDb:NOMBRE, oM:oDlg:Update(), .t. ),;
                     (If( MsgYesNo("Desea ingresarlo","Este Nit no Existe")   ,;
                        oM:oNit:Editar( ,.t.,,oM:aMov[10] ), ),.f.) ) } )      ;
      WHEN oM:oChq:ESTADO == 0 UPDATE                                          ;
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"
   @ 64,116 SAY oGet[06] VAR oM:aMov[11] OF oM:oDlg PIXEL SIZE 110,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 76, 00 SAY "Valor del Cheque" OF oM:oDlg RIGHT PIXEL SIZE 50,10
   @ 76, 52 GET oGet[07] VAR oM:oChq:VALORB OF oM:oDlg PICTURE "9,999,999,999.99";
      VALID oM:oChq:VALORB > 0 ;
      WHEN oM:oChq:ESTADO == 0 SIZE 50,10 PIXEL UPDATE
   @ 76,108 SAY "Nro. Factura"     OF oM:oDlg RIGHT PIXEL SIZE 50,10
   @ 76,160 GET oGet[08] VAR oM:oChq:FACTURA  OF oM:oDlg ;
      WHEN oM:oChq:ESTADO == 0 SIZE 40,10 PIXEL UPDATE
   @ 88, 00 SAY "Servicios" OF oM:oDlg RIGHT PIXEL SIZE 50,10
   @ 88, 52 COMBOBOX oGet[09] VAR oM:aChq[6] ITEMS ArrayCol( oM:aSrv,1 ) SIZE 100,99;
      VALID oM:Facturas( .t. ) OF oM:oDlg PIXEL UPDATE
    oGet[9]:bRClicked = {|| oM:Mostrar( oGet[09] ) }
   @ 88,160 SAY oGet[10] VAR oM:oMvc:CONCEPTO OF oM:oDlg SIZE 120,10 PIXEL UPDATE

   @ 184,226 SAY oGet[11] VAR oM:aMov[7]      OF oM:oDlg PICTURE "9,999,999,999.99";
      SIZE 50,10 PIXEL UPDATE
   @ 184,280 SAY oGet[12] VAR oM:aMov[8]      OF oM:oDlg PICTURE "9,999,999,999.99";
      SIZE 50,10 PIXEL UPDATE
   ACTIVAGET(oGet)

   @ 102,06 BROWSE oM:oLbp SIZE 140,96 PIXEL OF oM:oDlg CELLED; // CELLED  es requerida
      COLORS CLR_BLACK, CLR_NBLUE                               // para editar Celdas
   oM:oLbp:SetArray( oM:aCta )     // Esto es necesario para trabajar con arrays
   oM:oLbp:nFreeze     := 1
   oM:oLbp:nColPos     := oM:oLbp:nCell := 2
   oM:oLbp:nHeightCell += 3
   oM:oLbp:nHeightHead += 3
   oM:oLbp:bKeyDown := {|nKey| If( nKey== VK_TAB, oM:oLbp:oJump := oM:oLbx,;
                               If( nKey== VK_F11 .AND. !aCge[3]           ,;
                                 ( oM:GrabaC(), oM:oLbp:oJump:oJump := oM:oLbx), )) }
   oM:oLbp:SetAppendMode( .f. )                         // Activando Auto Append Mode

   ADD COLUMN TO BROWSE oM:oLbp DATA ARRAY ELEMENT 2;
       TITLE "Nombre"+CRLF+"Concepto"            ;
       SIZE 160 ;
       3DLOOK TRUE, TRUE, TRUE;    // Celda, Titulo, Footers
       MOVE DT_MOVE_NEXT;          // Cursor pasa a la Sig.Columna editable
       VALID { | uVar| !EMPTY( uVar ) }; // don't want empty rows
       ALIGN DT_LEFT, DT_CENTER;   // Celda, Titulo, Footer
       FOOTER "Totales->"
   ADD COLUMN TO BROWSE oM:oLbp DATA ARRAY ELEMENT 4;
       TITLE "Valor"         PICTURE "99,999,999" ;
       SIZE 100 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       VALID { |uVar| If( uVar >= 0, .t., ;
              (MsgStop("Valor tiene que ser Positivo","<<OJO>>"), .f.)) };
       FOOTER { || TRANSFORM( oM:nDes, "999,999,999" ) } ;
       POSTEDIT { |uVar| If( oM:oLbp:lChanged, oM:BuscarMov( 1 ), ) }
   //oLbp:aDefault := { " ", SPACE(30), 0, 0, 0 }
   oM:oLbp:SetColor( { 2, 6, 15 }, ;
                     { {|| If( oM:oLbp:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                     { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                       CLR_GRAY } )  // grid lines color

   @ 113,150 LISTBOX oM:oLbx FIELDS  ;
      oM:oMvd:CUENTA, oM:oMvd:INFA  ,;
      TRANSFORM( oM:oMvd:VALOR_DEB,"@Z 9,999,999,999.99" ),;
      TRANSFORM( oM:oMvd:VALOR_CRE,"@Z 9,999,999,999.99" ) ;
      HEADERS "Cuenta","InfA"  ,;
              "Debito","Credito";
      SIZES 400,450 SIZE 182,66 ;
      OF oM:oDlg UPDATE PIXEL
   oM:oLbx:nClrBackHead  := oApl:nClrBackHead
   oM:oLbx:nClrForeHead  := oApl:nClrForeHead
   oM:oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
   oM:oLbx:nClrBackFocus := oApl:nClrBackFocus
   oM:oLbx:nClrForeFocus := oApl:nClrForeFocus
   oM:oLbx:nHeaderHeight := 26
   oM:oLbx:GoTop()
   oM:oLbx:oFont       := Tfont():New("Ms Sans Serif",0,-10,,.f.)
   oM:oLbx:aColSizes   := {72,74,98,98}
   oM:oLbx:aHjustify   := {2,2,2,2}
   oM:oLbx:aJustify    := {0,0,1,1}
   oM:oLbx:ladjlastcol := oM:oLbx:lCellStyle  := .f.
   oM:oLbx:ladjbrowse  := .t.
   oM:oLbx:bKeyDown := {|nKey| If(nKey == VK_ESCAPE, (oM:aMov[3] := 0    ,;
                                       oM:oChq:xBlank(),  oM:Filtrar( 0 ),;
                                       oM:oLbx:Refresh(), oM:oDlg:Update(), oGet[2]:SetFocus()),;
                            If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, oM:Detalle( oM:oDlg,oM:oLbx,.t. ),;
                            If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, oM:Detalle( oM:oDlg,oM:oLbx,.f. ),;
                            If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, oM:BorraDeta( oM:oDlg,oM:oLbx ),) ))) }
   MySetBrowse( oM:oLbx,oM:oMvd )
ACTIVATE DIALOG oM:oDlg CENTERED ;
   ON INIT ( oM:Barram(), oM:Filtrar() )
oM:oCtl:Destroy()
oM:oFte:Cerrar()
oM:oMvc:Destroy()
oM:oMvd:Destroy()
oM:oPuc:Cerrar()
oM:oVar:Cerrar()
//oM:oAyu:Destroy()
oM:oBan:Destroy()
oM:oChq:Destroy()
oM:oSrv:Destroy()
RELEASE oM
SETKEY( VK_F5,{|| Empresa() } )
RETURN NIL

//------------------------------------//
CLASS TPago FROM TMov

 DATA aBan AS ARRAY INIT {}
 DATA aChq AS ARRAY INIT { "  ",SPACE(10),0,oApl:oEmp:EGRESO + 1,0,1 }
 DATA aCta AS ARRAY INIT {}
 DATA aSrv AS ARRAY INIT {}
 DATA nDes    INIT 0
 DATA aCar, oAyu, oBan, oChq, oSrv
 DATA oDlg, oLbp, oLbx

 METHOD NEW() Constructor
 METHOD Mostrar( oCB )
 METHOD Editar( oCB,oLbx,lNuevo )
 METHOD BuscarMov( nSum,nMov )
 METHOD BusChq( sCta,nSkip,lSkip )
 METHOD Fechas( lOK,nMsg )
 METHOD BuscarCta( lNew )
 METHOD GrabaC()
 METHOD AnulaCpte()
 METHOD Egresos( nEgr )
 METHOD Facturas( lCXP )
 METHOD ValidaFP( aFac,aGT,oLbf,nPag )
 METHOD ValidaPG( aGT,nPag,nSal )
 METHOD Cheque()
 METHOD Listado()
 METHOD Barram()

ENDCLASS

//------------------------------------//
METHOD NEW() CLASS TPago
   LOCAL aFor, hRes, nL
Super:NEW( 2 )
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

 ::aCar := {}
 ::aCta := Cuentas( ::aMov[2] )
 ::oAyu := TChq() ; ::oAyu:New( 2 )
 ::oBan := oApl:Abrir( "cgebanco","empresa, banco, cta_cte",,,10 )
 ::oChq := oApl:Abrir( "chequesc","empresa, banco, cta_cte",,,10 )
 ::oSrv := oApl:Abrir( "cgeservi","servicio",,,100 )
 ::oSrv:dbEval( {|o| AADD( ::aSrv, { o:SERVICIO,o:CUENTA } ) } )
//                {"empresa",oApl:nPuc} )
 ::oChq:Seek( {"empresa",oApl:nEmpresa,"banco",::aChq[1],;
               "cta_cte",::aChq[2],"cheque",::aChq[3]} )
 ::oFte:oDb:Seek( {"fuente",::aMov[2]} )
/*
aFor := "(empresa = " + LTRIM(STR(oApl:nEmpresa))+;
     " OR empresa = " + LTRIM(STR(oApl:nPuc))    +;
    ") AND fuente = " + LTRIM(STR(::aMov[2]))
 ::oNot:Seek( aFor,"CM" )
 */
RETURN NIL

//------------------------------------//
METHOD Mostrar( oCB ) CLASS TPago
   LOCAL oDlg, oLbx, oM := Self
If ::oSrv:RecCount() > 0
   ::oSrv:GoTop():Read()
   ::oSrv:xLoad()
Else
   ::oSrv:xBlank():Read()
EndIf

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE "Código de Pagos"
   @ 1.5, 0 LISTBOX oLbx FIELDS ;
                ::oSrv:SERVICIO,;
                ::oSrv:CUENTA   ;
      HEADERS "Nombre","Código"+CRLF+"Cuenta" ;
      SIZES 400, 450 SIZE 200,107  ;
      OF oDlg UPDATE               ;
      ON DBLCLICK ::Editar( oLbx,.f. )
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:GoTop()
    oLbx:oFont       := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:nHeaderHeight := 28
    oLbx:aColSizes   := {240,100}
    oLbx:aHjustify   := {2,2}
    oLbx:aJustify    := {0,0}
    oLbx:ladjbrowse  := oLbx:lCellStyle  := .f.
    oLbx:ladjlastcol := .t.
//    oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey ), oDlg:Update() }
    oLbx:bKeyDown := {|nKey| If(nKey=VK_RETURN, ::Editar( oLbx,.f. ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, ::Editar( oCB,oLbx,.t. ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69, ::Editar( oCB,oLbx,.f. ), ))) }
   MySetBrowse( oLbx,::oSrv )
ACTIVATE DIALOG oDlg CENTER

RETURN NIL

//------------------------------------//
METHOD Editar( oCB,oLbx,lNuevo ) CLASS TPago
   LOCAL bPuc, oDlg, oGet := ARRAY(4), oE := Self
   LOCAL aEd := { "Nuevo Código",.f.,::oPuc,1 }
   DEFAULT lNuevo := .t.
If lNuevo
   ::oSrv:xBlank():Read()
   ::oSrv:xLoad()
Else
   aEd[1] := "Modificando Código"
EndIf
bPuc := {|sCta| If( ::oPuc:oDb:Seek( {"empresa",oApl:nPUC,"cuenta",sCta} ),;
               (If( ::oPuc:oDb:ESTADO == "R" .OR. ::oPuc:oDb:NIVEL < 4    ,;
                  ( MsgStop( If( ::oPuc:oDb:ESTADO == "R", "Esta Anulada" ,;
                                  "no es Auxiliar" ),"Esta Cuenta" ),.f. ),;
                  ( ::oSrv:SERVICIO := If( lNuevo, LEFT(::oPuc:oDb:NOMBRE,20),;
                    ::oSrv:SERVICIO ), oDlg:Update(), .t. ) ) )           ,;
                  ( MsgStop( "Está Cuenta NO EXISTE !!!" ), .f. ) ) }
DEFINE DIALOG oDlg TITLE aEd[1] FROM 0, 0 TO 08,50
   @ 02,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 50,10
   @ 02,52 BTNGET oGet[1] VAR oE:oSrv:CUENTA OF oDlg PICTURE "9999999999";
      ACTION EVAL({|| If( aEd[3]:Mostrar()                      ,;
                        ( oE:oSrv:CUENTA := aEd[3]:oDb:CUENTA   ,;
                          oGet[1]:Refresh() ) ,) })              ;
      VALID EVAL( bPuc,oE:oSrv:CUENTA );
      SIZE 52,10 PIXEL  RESOURCE "BUSCAR"
   @ 16,00 SAY "Nombre"   OF oDlg RIGHT PIXEL SIZE 50,10
   @ 16,52 GET oGet[2] VAR ::oSrv:SERVICIO OF oDlg PICTURE "@!";
      VALID !EMPTY(::oSrv:SERVICIO)  SIZE 120,10 PIXEL UPDATE
   @ 32, 60 BUTTON oGet[3] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION;
      (IF( EMPTY(::oSrv:CUENTA) .OR. EMPTY(::oSrv:SERVICIO),;
         (MsgStop("No se puede grabar este Código, debe completar datos"),;
          oGet[1]:SetFocus()), (aEd[2] := .t., oDlg:End()) )) PIXEL
   @ 32,110 BUTTON oGet[4] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTER

If aEd[2]
   If lNuevo
    //::oSrv:EMPRESA := oApl:nPUC
      ::oSrv:Append( .t. )
    //AADD( ::aSrv, { ::oSrv:SERVICIO,::oSrv:CUENTA } )
    //ASORT( ::aSrv,,, { |x,y| x[1] < y[1] } )
   Else
   // ::aSrv[aEd[4],1] := ::oSrv:SERVICIO
   // ::aSrv[aEd[4],2] := ::oSrv:CUENTA
      ::oSrv:Update(.t.,1)
   EndIf
   AEVAL( ::aSrv, { |x| oCB:Del(1) } )
   ::aSrv := {}
   ::oSrv:dbEval( { |o| AADD( ::aSrv, { o:SERVICIO,o:CUENTA } ) } )
   //             {"empresa",oApl:nPuc} )
   AEVAL( ::aSrv, { |x| oCB:Add( x[1] ) } )
   oLbx:SetFocus()
   oLbx:Refresh()
EndIf
RETURN NIL

//------------------------------------//
METHOD BuscarMov( nSum,nMov ) CLASS TPago

If nSum == NIL
   If nMov == NIL
      If !::oChq:Seek( {"empresa",oApl:nEmpresa,"banco",::aChq[1],;
                        "cta_cte",::aChq[2],"cheque",::aChq[3]} )
         If ::aChq[3] > 0
            MsgStop( "Cheque"+STR(::aChq[3]),">>> Voy hacer <<<" )
         EndIf
         ::oChq:FECHA := DATE()
         ::oChq:SERVICIO := ::aSrv[1,2]
      EndIf
      ::aMov[14] := 1
      ::aMov[16] := If( ::oChq:nRowCount > 1, .t., .f. )
      Botones( ::oDlg,{5,6},::aMov[16] )
   EndIf
      ::BusChq( ,0,.t. )
Else
   If ::oChq:lOK
      ::BuscarCta( .t. )
   Else
      ::nDes := 0
      FOR nMov := 2 TO LEN( ::aCta )
         ::nDes += ::aCta[nMov,4]
      NEXT nMov
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD BusChq( sCta,nSkip,lSkip ) CLASS TPago

If ::aMov[16] .AND. nSkip # 0
   lSkip := .f.
   If (nSkip ==  1 .AND. ::aMov[14] < ::oChq:nRowCount) .OR.;
      (nSkip == -1 .AND. ::aMov[14] > 1)
       lSkip := .t.
      ::oChq:Skip(nSkip):Read()
      ::oChq:xLoad()
   EndIf
EndIf
If lSkip
   ::Fechas( .f. )
   ::oNit:oDb:Seek( {"codigo_nit",::oChq:CODIGONIT} )
   ::aMov[01] := oApl:cPer
   ::aMov[03] := ::oChq:COMPROBANT
   ::aMov[05] := {"Sin Imprimir","Impreso","Anulado"}[::oChq:ESTADO+1]
   ::aMov[10] := ::oNit:oDb:CODIGO
   ::aMov[11] := ::oNit:oDb:NOMBRE
   ::aMov[14] += nSkip
   ::aCar     := {}
   ::aChq[6]  := ArrayValor( ::aSrv,::oChq:SERVICIO,,.t. )
   ::BuscarCta( .f. )
   ::oMvc:Seek( {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,;
                 "fuente" ,::aMov[2], "comprobant",::aMov[3]} )
   If ::oMvc:lOK .AND. Rango( ::oChq:SERVICIO,::aCXP )
      If InfAc( ::oChq:SERVICIO,@nSkip,"DOCUMENTO " )
         sCta := { "infa","infb","infc","infd" }[nSkip]
         sCta := "SELECT d.cuenta, d.valor_deb, c.numero FROM ctasxpc c, cgemovd d "+;
                 "WHERE d.empresa    = c.empresa"                   +;
                  " AND d.codigo_nit = c.codigo_nit"                +;
                  " AND d." + sCta+" = c.numero"                    +;
                  " AND d.empresa    = " + LTRIM(STR(oApl:nEmpresa))+;
                  " AND d.ano_mes    = '"+ oApl:cPer                +;
                 "' AND d.control    = " + LTRIM(STR(::oMvc:CONTROL))
         ::aCar := Buscar( sCta,"CM",,9 )
       //AEVAL( ::aCar, {|a| Msginfo( TRANSFORM(a[2],"99,999,999.99"),a[3] ) } )
      EndIf
   EndIf
   ::Filtrar( 0 )
   ::oLbp:Refresh()
   ::oLbx:Refresh()
   ::oDlg:Update()
EndIf
RETURN NIL

//------------------------------------//
METHOD Fechas( lOK,nMsg ) CLASS TPago
   LOCAL aFec, lSI := .t.
If lOK
   aFec := { ::oChq:XColumn( 3 ),::oChq:FECHA,oApl:cPer,::lCierre,.t.,"" }
   If ::oChq:COMPROBANT > 0
      ::BuscarMov( ,1 )
      aFec[6] := "empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
            " AND ano_mes = " + xValToChar(oApl:cPer )    +;
            " AND control = " + LTRIM(STR(::oMvc:CONTROL))
   EndIf
   If (aFec[5] := ::Fechas( .f.,1 ))
      If (aFec[3] == LEFT( DTOS(aFec[2]),6 ))
         If ::oChq:COMPROBANT > 0
            Guardar( "UPDATE cgemovc SET fecha = " + xValToChar(aFec[2]) +;
                     " WHERE " + aFec[6],"cgemovc" )
         EndIf
         Guardar( ::oChq,.f.,.f. )
      ElseIf MsgYesNo( "QUIERE HACER EL CAMBIO","VA A CAMBIAR DE MES" )
         If ::oChq:COMPROBANT > 0
            ::oMvc:ANO_MES := oApl:cPer
            ::oMvc:FECHA   := aFec[2]
            ::oMvc:CONTROL := SgteCntrl( "Control",oApl:cPer,.t. )
            Guardar( ::oMvc,.f.,.f. )
            ::oMvd:dbEval( {|o| ::Avanza( ,o:CUENTA )                                ,;
                                ::GrabaPago( o:CUENTA,::aTL[4],-::aTL[5],::aTL[6],1 ),;
                                Acumular( ::oMvc:ESTADO,o,5,5,.f.,.f. )              ,;
                                o:ANO_MES := oApl:cPer, o:CONTROL := ::oMvc:CONTROL  ,;
                                ::GrabaPago( o:CUENTA,::aTL[4], ::aTL[5],::aTL[6],2 ),;
                                Acumular( ::oMvc:ESTADO,o,2,2,.f.,.f. ) }, aFec[6] )
            ::Filtrar()
         EndIf
         Guardar( ::oChq,.f.,.f. )
         ::aMov[1] := oApl:cPer
      Else
         aFec[5] := .f.
      EndIf
   EndIf
   If (lSI := aFec[5])
      MsgInfo( "El cambio de Fecha","HECHO" )
   Else
      lSI := If( EMPTY( aFec[2] ) .OR. ::lCierre, .t., .f. )
      ::oChq:FECHA := aFec[1]
      oApl:cPer := aFec[3]
      ::lCierre := aFec[4]
   EndIf
ElseIf EMPTY( ::oChq:FECHA )
   MsgStop( "No puede ir en Blanco","FECHA" )
   lSI := .f.
Else
   oApl:cPer := NtChr( ::oChq:FECHA,"1" )
   ::lCierre := Buscar( {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer},;
                        "cgecntrl","cierre",8,,3 )
   If ::lCierre .AND. nMsg # NIL
      MsgStop( "Ya esta CERRADO","Periodo "+oApl:cPer )
      lSI := .f.
   EndIf
EndIf
RETURN lSI

//------------------------------------//
METHOD BuscarCta( lNew ) CLASS TPago
   LOCAL cQry, hRes, nR
If lNew
   FOR nR := 1 TO LEN( ::aCta  )
      If ::aCta[nR,4] > 0
         If ::aCta[nR,5] == 0
            cQry := "INSERT INTO chequesd VALUES ( null, " +;
                  LTRIM(STR(oApl:nEmpresa)) + ", " + LTRIM(STR(::oChq:ROW_ID))+ ", "+;
                  LTRIM(STR(::aCta[nR,3]))  + ", " + LTRIM(STR(::aCta[nR,4])) + " )"
         Else
            cQry := "UPDATE chequesd SET valor = " + LTRIM(STR(::aCta[nR,4])) +;
                    " WHERE row_id = " + LTRIM(STR(::aCta[nR,5]))
         EndIf
         MSQuery( oApl:oMySql:hConnect,cQry )
      ElseIf ::aCta[nR,5] > 0
         MSQuery( oApl:oMySql:hConnect,"DELETE FROM chequesd WHERE row_id = "+;
                  LTRIM(STR(::aCta[nR,5])) )
      EndIf
   NEXT nR
EndIf
 ::nDes := 0
AEVAL( ::aCta, {|x| AFILL( x,0,4,2 ) } )
cQry := "SELECT orden, valor, row_id FROM chequesd "    +;
        "WHERE row_idc = "   + LTRIM(STR(::oChq:ROW_ID))
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nR   := MSNumRows( hRes )
While nR > 0
   cQry := MyReadRow( hRes )
   AEVAL( cQry, { | xV,nP | cQry[nP] := MyClReadCol( hRes,nP ) } )
   If cQry[1] >= 2
      ::nDes += cQry[2]
   EndIf
   ::aCta[cQry[1],4] := cQry[2]
   ::aCta[cQry[1],5] := cQry[3]
   nR --
EndDo
MSFreeResult( hRes )
RETURN NIL

//------------------------------------//
METHOD GrabaC() CLASS TPago

If ::oChq:ESTADO == 0
   If MsgYesNo( "Grabar este Cheque","QUIERE" )
      If ::oChq:CHEQUE == 0 .OR. !::oChq:lOK
         If ::aChq[3] == 0
            ::aChq[3] := ++::oBan:NUM_CHEQUE
         Else
            ::oBan:NUM_CHEQUE := ::aChq[3]
         EndIf
         ::oChq:EMPRESA:= oApl:nEmpresa
         ::oChq:BANCO  := ::aChq[1] ; ::oChq:CTA_CTE := ::aChq[2]
         ::oChq:CHEQUE := ::aChq[3]
         ::oBan:Update(.t.,1)
         ::oChq:Append(.t.)
         ::oDlg:Update()
      Else
         ::oChq:Update(.t.,1)
      EndIf
      If ::oChq:ESTADO == 0
         If ::oBan:IMPRIMO
           ::Cheque()
         Else
           ::oChq:ESTADO := 1 ; ::oChq:Update(.t.,1)
        EndIf
      EndIf
      If ::oMvc:lOK .AND. ::oChq:COMPROBANT > 0
         ::Egresos( 1 )
      EndIf
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD AnulaCpte() CLASS TPago
   LOCAL cQry
If ::lCierre
   MsgStop( "YA ESTA CERRADO","Periodo "+oApl:cPer )
   RETURN NIL
ElseIf ::oChq:ESTADO # 0
   cQry := If( ::oChq:ESTADO == 2, "ACTIVAR", "ANULAR" )
   If MsgNoYes( "Este Cheque","QUIERE "+cQry )
      If ::oChq:COMPROBANT > 0
         ::BuscarMov( ,2 )
         ::oMvd:dbEval( {|o| ::Avanza( ,o:CUENTA )                       ,;
                             If( ::oMvc:ESTADO == 1                      ,;
                               (      o:EMPRESA := -4                    ,;
                                 ::GrabaPago( o:CUENTA,::aTL[4],-::aTL[5],::aTL[6],1 ),;
                                 Acumular( 2, o, 3, 3, .f., .f. ) ), ) } ,;
                        {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,"control",::oMvc:CONTROL} )
         ::oMvc:CONSECUTIV := 0
         If ::oMvc:ESTADO == 2
            If MsgYesNo( "Con el Comprobante"+STR(::oChq:COMPROBANT),"QUIERE dejar este Cheque" )
               ::oMvc:ESTADO := 1 ; ::oMvc:Update(.t.,1)
            Else
               ::oChq:COMPROBANT := 0
               ::BuscarMov( ,1 )
            EndIf
         ElseIf ::oMvc:lOK
            ::oMvc:ESTADO := 2 ; ::oMvc:Update(.t.,1)
         EndIf
      EndIf
      ::oChq:ESTADO := If( ::oChq:ESTADO == 2, 0, 2 )
      ::oChq:Update(.t.,1)
      ::aMov[05] := {"Sin Imprimir","Impreso","Anulado"}[::oChq:ESTADO+1]
      ::oDlg:Update()
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Egresos( nEgr ) CLASS TPago
   LOCAL aCta, cNom, nC, nJ
If nEgr == NIL
   If ::oChq:ESTADO == 1
      If !MsgYesNo( "Hacerle el Egreso","QUIERE" )
         RETURN NIL
      EndIf
   Else
      RETURN NIL
   EndIf
EndIf
If LEN( ::aCar ) == 0
   ::Facturas( .f. )
EndIf
nJ   := ::oChq:VALORB + ::nDes - ::aCta[1,4]
If LEN( ::aCar ) > 0
   aCta := {}
   AEVAL( ::aCar, {|a| cNom := If( EMPTY(a[1]), ::oChq:SERVICIO, a[1] ),;
                       AADD( aCta,{ cNom,"","","",a[3],a[2],0,0,0,0 } ) } )
Else
   aCta := { { ::oChq:SERVICIO,"","","","",nJ,0,0,0,0 } }
EndIf
   AADD( aCta,{ ::aCta[1,1] ,"","","","",::aCta[1,4],0,0,0,0 } )
   AADD( aCta,{::oBan:CUENTA,"","","","",0,::oChq:VALORB,0,0,0 } )
FOR nC := 2 TO LEN( ::aCta )
   AADD( aCta,{ ::aCta[nC,1],"","","","",0,::aCta[nC,4],0,0,0 } )
NEXT nC
   nC := 0
If ::oBan:BANCO # "99"
   nC := Buscar( { "codigo_nit",::oBan:CODIGO_NIT },"cadclien","codigo",8,,4 )
   nJ := ROUND( ::oChq:VALORB * .004,0 )         //4 X MIL
   AADD( aCta,{ "53050510  ","","","","",nJ,0,::oBan:CODIGO_NIT,0,0 } )
   AADD( aCta,{::oBan:CUENTA,"","","","",0,nJ,::oBan:CODIGO_NIT,0,0 } )
EndIf
cNom := ::oMvc:CONCEPTO
 MsgGet( "Descripcion Pago","Concepto",@cNom )
 ::aMov[1] := oApl:cPer := NtChr( ::oChq:FECHA,"1" )
If ::oChq:COMPROBANT == 0
   ::aMov[3] := SgteNumero( ::aMov[4],oApl:nEmpresa,.t. )
   ::aChq[4]        := ::aMov[3] +1
   ::oChq:COMPROBANT:= ::aMov[3] ; ::oChq:Update(.t.,1)
   ::oCtl:Seek( {"empresa",oApl:nEmpresa,"ano_mes",::aMov[1]} )
Else
   ::aMov[3] := ::oChq:COMPROBANT
   ::oMvd:dbEval( {|o| ::Avanza( ,o:CUENTA ), o:EMPRESA := -4               ,;
                       ::GrabaPago( o:CUENTA,::aTL[4],-::aTL[5],::aTL[6],1 ),;
                       Acumular( ::oMvc:ESTADO,o,3,3,.f.,.f. ) }            ,;
                  {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,"control",::oMvc:CONTROL} )
EndIf
 ::aMov[04] := ""
 ::aMov[18] := If( EMPTY(::oChq:FACTURA), LTRIM(STR(::aMov[3])), ::oChq:FACTURA )
 ::oMvc:FECHA     := ::oChq:FECHA
 ::oMvc:CONCEPTO  := UPPER( cNom )
 ::oMvc:CODIGONIT := ::oChq:CODIGONIT
 ::oMvc:VALORB    := ::oChq:VALORB

 ::BuscarCta( .t. )
 ::aTL := { 0,0,"","",0,1,0 }
 ActuaINF( @aCta,{::aMov[18],::aMov[3],::oChq:CTA_CTE,::oChq:FECHA,::aMov[10],;
                  ::oChq:CODIGONIT,::oChq:CHEQUE,nC} )
FOR nJ := 1 TO LEN( aCta )
   If aCta[nJ,10] == 0
      LOOP
   EndIf
// ::oMvd:Seek( "empresa = -9 LIMIT 1","CM" )
   ::oMvd:xBlank()
   ::oMvd:CUENTA     := aCta[nJ,1] ; ::oMvd:INFA       := aCta[nJ,2]
   ::oMvd:INFB       := aCta[nJ,3] ; ::oMvd:INFC       := aCta[nJ,4]
   ::oMvd:INFD       := aCta[nJ,5] ; ::oMvd:VALOR_DEB  := aCta[nJ,6]
   ::oMvd:VALOR_CRE  := aCta[nJ,7] ; ::oMvd:CODIGO_NIT := aCta[nJ,8]
   ::oMvd:PTAJE      := aCta[nJ,9] ; ::oMvd:LIBRO      := aCta[nJ,10]
   ::aTL[7] := aCta[nJ,8]
   ::Graba( .t.,1 )
NEXT nJ
 ::aMov[4] := "EGRESO"
 ::Filtrar()
 ::oLbx:Refresh()
 ::oDlg:Update()
RETURN NIL

//----NIT--DOC--FAC-------------------//
METHOD Facturas( lCXP ) CLASS TPago
   LOCAL aFac, aGT, cQry, hRes, nL, oDlg, oGet, oLbf
If lCXP
   ::oChq:SERVICIO := ::aSrv[::aChq[6],2]
   RETURN .t.
ElseIf !Rango( ::oChq:SERVICIO,::aCXP )
   ::aCar := {}
   RETURN .t.
EndIf
cQry := "SELECT c.numero, c.fecha, s.saldo, c.cuenta " +;
        "FROM ctasxpm s, ctasxpc c "         +;
        "WHERE c.empresa    = " + LTRIM(STR(oApl:nEmpresa))       +;
         " AND c.codigo_nit = " + LTRIM(STR(::oChq:CODIGONIT))    +;
         " AND c.fecha     <= " + xValToChar( ::oChq:FECHA )      +;
         " AND c.cxpc_id    = s.cxpc_id"                          +;
         " AND s.ano_mes = (SELECT MAX(m.ano_mes) FROM ctasxpm m "+;
                           "WHERE m.cxpc_id    = c.cxpc_id"       +;
                            " AND m.ano_mes   <= '" + oApl:cPer   +;
       "') AND s.saldo <> 0 ORDER BY c.numero"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY FACTURAS PENDIENTES" )
   MSFreeResult( hRes )
   RETURN .t.
EndIf
aFac := ::oChq:VALORB + ::aCta[2,4]
aGT  := { 0,0,0,aFac,.f.,aFac }
aFac := {}
oGet := ARRAY(4)
While nL > 0
   cQry := MyReadRow( hRes )
   AEVAL( cQry, { | xV,nP | cQry[nP] := MyClReadCol( hRes,nP ) } )
   AADD( aFac, { cQry[1],cQry[2],cQry[3],0,cQry[4] } )
   aGT[1] += cQry[3]
   nL --
EndDo
MSFreeResult( hRes )
DEFINE DIALOG oDlg TITLE "Facturas Pendientes" FROM 0, 0 TO 330, 430 PIXEL
   @ 02, 00 SAY "Valor del Pago" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 02, 62 SAY oGet[1] VAR aGT[6] OF oDlg PICTURE "9,999,999,999.99";
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
                                              aGT[4] := aGT[6] - aGT[2]  ,;
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
         AADD( ::aCar, { aFac[nL,5],aFac[nL,4],aFac[nL,1] } )
      EndIf
   NEXT nL
   If aGT[6] > aGT[2]
      AADD( ::aCar, { "",aGT[6] - aGT[2],"" } )
   EndIf
   ::oMvc:CONCEPTO := PADR( cQry,40 )
EndIf
RETURN .t.

//------------------------------------//
METHOD ValidaFP( aFac,aGT,oLbf,nPag ) CLASS TPago
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
   aGT[4] := aGT[6] - aGT[2]
   oLbf:DrawFooters()
RETURN NIL

//------------------------------------//
METHOD ValidaPG( aGT,nPag,nSal ) CLASS TPago
   LOCAL lOK := .t.
If nPag <= 0
   MsgStop("Valor tiene que ser Positivo",">> OJO <<")
   lOK := .f.
ElseIf nPag > nSal
   MsgStop( "Pago Mayor que el Saldo",">> OJO <<" )
   lOK := .f.
ElseIf (aGT[2] + nPag - aGT[3]) > aGT[6]
   MsgStop( "Pago Mayor que el Total",">> OJO <<" )
   lOK := .f.
EndIf
RETURN lOK

//------------------------------------//
METHOD Cheque() CLASS TPago
   LOCAL aTL, cFecha, oRpt, nL, nK := 0
   LOCAL cFeed8 := CHR(27)+CHR(48)        // 1/8 ESC 0
If ::oChq:ESTADO # 0
   RETURN NIL
ElseIf !MsgYesNo( "Imprimir este Cheque","QUIERE" )
   RETURN NIL
EndIf
   aTL    := Letras( ::oChq:VALORB )
   cFecha := STRTRAN( DTOC(::oChq:FECHA),"."," " )
   If ::oBan:TF == "AS"
      cFecha := DTOS( ::oChq:FECHA )
      FOR nL := 2 TO 14 STEP 2
         cFecha := STUFF( cFecha,nL,0," " )
      NEXT
   ElseIf ::oBan:TF == "A "
      cFecha := RIGHT( cFecha,4 ) + SUBSTR( cFecha,3,4 ) + LEFT( cFecha,2 )
   EndIf
   If LEN( aTL[1] ) > ::oBan:LM
      nK := LEN(aTL[1])
      nL := ::oBan:LM + If( nK > (::oBan:LM + 25), ROUND( ::oBan:LM/1.7,0 ), 0 )
      While !SUBSTR( aTL[1],nL,1 ) $ " "
         nL--
      EndDo
      //Divide el monto en dos partes
      aTL[2] := SUBSTR( aTL[1],nL+1,nK-nL )
      nK     := If( nK > (::oBan:LM + 25), ROUND( ::oBan:LM/1.7,0 ), 0 )
      aTL[1] := SPACE(nK) + LEFT( aTL[1],nL )
   EndIf
   nK := If( nK == 0, 1, 2 )
   nL := CHR(27)+CHR(48)        // 1/8 ESC 0

oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,,.t.,,nK,30,30 )
oRpt:nPage := 1
oRpt:SetFont( oRpt:CPINormal+nL,82,2 )

oRpt:Say( ::oBan:FF,::oBan:CF,cFecha )
oRpt:Say( ::oBan:FV,::oBan:CV,LTrim( Trans( ::oChq:VALORB,"9,999,999,999.99" ) ) )
oRpt:Say( ::oBan:FB,::oBan:CB,oApl:oNit:NOMBRE )
oRpt:SetFont( oRpt:cFontI+nL,82,2 )
oRpt:Say( ::oBan:FM,::oBan:CM,aTL[1] )
oRpt:Say( ::oBan:FM+2,02,aTL[2] )
//oRpt:Say( ::oBan:FM+3,02,CHR(27)+CHR(50) ) // 1/6   ESC 2 Normal
oRpt:NewPage()
oRpt:End()
 ::oChq:ESTADO := 1 ; ::oChq:Update(.t.,1)

RETURN NIL

//----------------------------------------------//
METHOD Listado() CLASS TPago
If ::oMvc:CONTROL > 0
//::oMvc:ESTADO # 2
   CgeLista( ::oMvc:CONTROL,{ LTRIM(STR(::aChq[3])),::oBan:NOMBRE,::aChq[2],;
             If( ::aChq[1] == "99", "X", "" ) },"Egreso" )
EndIf
RETURN NIL
/*
//----------------------------------------------//
METHOD Listado() CLASS TPago
   LOCAL aC := {}, nK, nL, oRpt
 ::aCG := { "","",0,0,0,0,0 }
 ::aTL := Letras( ::oMvc:VALORB,100 )
If ::oNot:FORMA == "N"
   ::DosNForma()
   RETURN NIL
EndIf
FOR nL := 1 TO 18 STEP 3
  nK := VAL( SUBSTR( ::oBan:EGRESO,nL,3 ) )
  AADD( aC, nK  )
NEXT nL
 ::aCG[7] := ROUND( ::oMvc:VALORB * .004,0 )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,,.t.,,1,50,50 )
oRpt:SetFont( oRpt:CPINormal,82,2 )
oRpt:nPage := 1
oRpt:Say( 02,38,NtChr( ::oMvc:FECHA,"2" ) )
oRpt:Say( 02,50,"$" + LTRIM(TRANSFORM( ::oMvc:VALORB,"9,999,999,999.99" )) )
oRpt:Say( 04,02,NtChr( ::aMov[11],"\" ) )
oRpt:Say( 06,06,oRpt:CPICompress+::aTL[1] )
oRpt:Say( 07,02,oRpt:CPICompress+::aTL[2] )

//oRpt:Say( nL+06,10,"Nit "+ FormatoNit( ::oNit:oDb:CODIGO,::oNit:oDb:DIGITO ) )

nL := aC[1] + aC[2]
 ::oMvd:GoTop():Read()
 ::oMvd:xLoad()
While !::oMvd:Eof()
   If nL == 22
      oRpt:Say( nL,aC[4],oRpt:CPICompress+::oMvc:CONCEPTO )
      nL++
   EndIf
   If !(LEFT(::oMvd:CUENTA,4) == "5305" .AND. ::oMvd:VALOR_DEB == ::aCG[7]) .OR.;
      !(LEFT(::oMvd:CUENTA,4) == "1110" .AND. ::oMvd:VALOR_CRE == ::aCG[7])
      oRpt:Say( nL,aC[3],::oMvd:CUENTA )
      oRpt:Say( nL,aC[4],::oMvd:INFA + "  " + ::oMvd:INFB )
      If ::oMvd:VALOR_DEB > 0
         oRpt:Say( nL,aC[5],TRANSFORM( ::oMvd:VALOR_DEB,"@Z 9,999,999,999.99" ) )
      Else
         oRpt:Say( nL,aC[6],TRANSFORM( ::oMvd:VALOR_CRE,"@Z 9,999,999,999.99" ) )
      EndIf
      If LEFT( ::oMvd:CUENTA,2 ) == "11"
         ::oPuc:oDb:Seek( {"empresa",oApl:nPuc,"cuenta",::oMvd:CUENTA} )
         ::aCG[1] := ::oMvd:INFC
      EndIf
      nL ++
   EndIf
   ::oMvd:Skip(1):Read()
   ::oMvd:xLoad()
EndDo
 oRpt:Say( 40,08,::aCG[1] )
 oRpt:Say( 41,08,::oPuc:oDb:NOMBRE )
 oRpt:NewPage()
 oRpt:End()
RETURN NIL

//------------------------------------//
METHOD DosNForma( lPreview ) CLASS TPago
   LOCAL oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"Comprobante de Egreso",;
          STR(::oMvc:COMPROBANT,6)," P.U.C.              C O N C "+;
          "E P T O             D E B I T O     C R E D I T O" },lPreview,,1,33,33 )
oRpt:nPage := 1
oRpt:SetFont( oRpt:CPINormal,82,2 )
oRpt:Say( 01,00,oRpt:CPILarge+PADC( oApl:cEmpresa,43 ) )
oRpt:Say( 02,30,oApl:oEmp:NOMBRE2 )
oRpt:Say( 03,30,"NIT: " + oApl:oEmp:Nit )
oRpt:Say( 04,02,"BENEFICIARIO " +::oNit:oDb:NOMBRE )
oRpt:Say( 05,02,"Nit. o C.C.  " + FormatoNit( ::oNit:oDb:CODIGO,::oNit:oDb:DIGITO ) )
//oRpt:Say( 05,06,oRpt:CPICompress + ::aTL[1] )
oRpt:Say( 06,02,"FECHA        " + NtChr( ::oMvc:FECHA,"2" ) )
oRpt:Say( 06,58,oRpt:aEnc[1] )
oRpt:Say( 07,02,"Por Concepto de : " + ::oMvc:CONCEPTO + "  No." )
oRpt:Say( 07,65,oRpt:CPILarge + oRpt:aEnc[2] )
oRpt:Say( 08,00,oRpt:aEnc[3] )
oRpt:Say( 09,00,REPLICATE("_",78) )
oRpt:nL := 10
::CicloDeta( oRpt,{ 0,11,45,62 } )

oRpt:Say(  oRpt:nL,45,Replicate("=",33),,,1 )
oRpt:Say(++oRpt:nL,33,"TOTALES ==>",,,1 )
oRpt:Say(  oRpt:nL,45,TransForm( ::aCG[3],"9,999,999,999.99" ) )
oRpt:Say(  oRpt:nL,62,TransForm( ::aCG[4],"9,999,999,999.99" ) )
//oRpt:nL += 5
oRpt:Say( 28,02,"Cheque No "+ STR(::aChq[3]) )
oRpt:Say( 28,24,"$" + LTRIM(TRANSFORM( ::oMvc:VALORB,"9,999,999,999.99" )) )
oRpt:Say( 28,45,REPLICATE("_",34) )
oRpt:Say( 29,02,"Banco  "   + ::oBan:NOMBRE )
oRpt:Say( 29,47,"Firma y sello del Beneficiario" )
oRpt:Say( 30,49,"C.C. - Nit" )
oRpt:NewPage()
oRpt:End()

RETURN NIL
*/
//------------------------------------//
METHOD Barram() CLASS TPago
   LOCAL oBar, oBot := ARRAY(11)
DEFINE BUTTONBAR oBar OF ::oDlg 3DLOOK SIZE 28,28

DEFINE BUTTON oBot[01] RESOURCE "DEDISCO"  OF oBar NOBORDER;
   TOOLTIP "Grabar (F11)"  ACTION;
    (If( EMPTY(::oChq:CODIGONIT) .OR. EMPTY(::oChq:SERVICIO) .OR. ::oChq:VALORB <= 0,;
       ( MsgStop("Imposible grabar este CHEQUE") ),;
       ( ::GrabaC() )))
DEFINE BUTTON oBot[02] RESOURCE "IMPRIMIR" OF oBar NOBORDER ;
   TOOLTIP "Imprimir Cheque" ;
   ACTION ::Cheque()
DEFINE BUTTON oBot[03] RESOURCE "MIRAR"    OF oBar NOBORDER ;
   TOOLTIP "Hacer el EGRESO" ;
   ACTION ::Egresos()
DEFINE BUTTON oBot[04] RESOURCE "PRINTER"  OF oBar NOBORDER ;
   TOOLTIP "Imprimir EGRESO" ;
   ACTION ::Listado()
// ACTION (If( MsgYesNo( "Imprimir este Egreso","QUIERE" ),;
//             ::Listado(), ))
DEFINE BUTTON oBot[05] RESOURCE "ANTERIOR"  OF oBar NOBORDER ;
   ACTION ::BusChq( ,-1 ) GROUP   TOOLTIP "Cheque Anterior"
DEFINE BUTTON oBot[06] RESOURCE "SIGUIENTE" OF oBar NOBORDER ;
   ACTION ::BusChq( ,1 )          TOOLTIP "Siguiente Cheque"
DEFINE BUTTON oBot[07] RESOURCE "ELIMINAR" OF oBar NOBORDER;
   TOOLTIP "Anular Cheque"    ;
   ACTION ::AnulaCpte() GROUP
DEFINE BUTTON oBot[08] RESOURCE "ADD"      OF oBar NOBORDER ;
   ACTION ::Detalle( ::oDlg,::oLbx,.t. )  TOOLTIP "Nuevo Registro (Ctrl+N)"
DEFINE BUTTON oBot[09] RESOURCE "MODIFY"   OF oBar NOBORDER ;
   ACTION ::Detalle( ::oDlg,::oLbx,.f. )  TOOLTIP "Editar Registro (Ctrl+E)"
DEFINE BUTTON oBot[10] RESOURCE "DELREC"   OF oBar NOBORDER ;
   ACTION ::BorraDeta( ::oDlg,::oLbx )    TOOLTIP "Borrar  (Ctrl+DEL)"
DEFINE BUTTON oBot[11] RESOURCE "EXIT2"    OF oBar NOBORDER;
   TOOLTIP "Salir"    ;
   ACTION ::oDlg:End()    GROUP
 oBar:bRClicked := {|| NIL }
 oBar:bLClicked := {|| NIL }
RETURN oBar

//------------------------------------//
FUNCTION Cuentas( nFte,nCon )
   LOCAL aRes := {}, cQry, hRes, nL
//cQry := "SELECT cuenta, nombre, orden, codigo_nit FROM cgcuenta "+;
cQry := "SELECT cuenta, nombre, orden, codigo_nit, editar, db_cr "+;
        "FROM ctasfase "                               +;
        "WHERE (empresa = " + LTRIM(STR(oApl:nEmpresa))+;
           " OR empresa = " + LTRIM(STR(oApl:nPuc))    +;
         ") AND fuente = "  + LTRIM(STR(nFte))         +;
        " ORDER BY orden"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   cQry := MyReadRow( hRes )
   AEVAL( cQry, { | xV,nP | cQry[nP] := MyClReadCol( hRes,nP ) } )
   If nCon == NIL
      AADD( aRes, { cQry[1],cQry[2],cQry[3],0,0,cQry[4],cQry[5],cQry[6],0 } )
   Else
      AADD( aRes, { cQry[1],"","","","",0,0,cQry[4],0,0 } )
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
If LEN( aRes ) == 0
   AADD( aRes,{ " ", SPACE(30), 0, 0, 0 } )
EndIf
RETURN aRes