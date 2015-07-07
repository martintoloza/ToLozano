// Programa.: CGEAYUCH.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: VISTA Ayuda de los Cheques.
#include "Fivewin.ch"

MEMVAR oApl

//------------------------------------//
CLASS TChq FROM TNits

 METHOD NEW( nOpc ) Constructor
 METHOD Mostrar()
 METHOD Muestra()
ENDCLASS
/*
CREATE VIEW ingresov AS
SELECT c.empresa, c.fecha, c.banco, c.cta_cte, c.documento, c.comprobant, n.nombre
FROM cgeingre c, cadclien n
WHERE (c.codigonit = n.codigo_nit)

CREATE VIEW chequesv AS
SELECT c.empresa, c.fecha, c.banco, c.cta_cte, c.cheque, c.comprobant, n.nombre
FROM chequesc c, cadclien n
WHERE (c.codigonit = n.codigo_nit)
*/
//------------------------------------//
METHOD NEW( nOpc ) CLASS TChq
   LOCAL oBase
 ::aV := { { "ingresov","nombre, fecha","R.de Caja" },;
           { "chequesv","nombre, fecha","Cheques"   },;
           { "cadfactv","cliente, fecha","Pendientes" } }
 //oBase := oApl:Abrir( "chequesv","empresa, banco, cta_cte" )
 oBase := oApl:Abrir( ::aV[nOpc,1],::aV[nOpc,2],.t.,,100 )
Super:New( oBase )
If nOpc == 3
   ::aOrden  := { {"Nombre",1},{"Fecha" ,2} }
Else
   ::aOrden  := { {"Nombre",7},{"Fecha" ,2},;
                  {"Banco" ,3},{"Cuenta",4} }
EndIf
::bEditar := ::bNew := ::bVer := {|| MsgStop( "Solo para Ayuda" ) }
::xVar    := "Ayuda de los " + ::aV[nOpc,3]
RETURN NIL

//------------------------------------//
METHOD Mostrar() CLASS TChq
   LOCAL bHacer, nOrd, oDlg, oM := Self
   LOCAL lReturn := .f.
::oDb:cWhere := " empresa = " + LTRIM(STR(oApl:nEmpresa))
bHacer := {||lReturn := ::lBuscar := .t., oDlg:End()}
nOrd   := ::Ordenar( 1 )

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE ::xVar
   @ 1.5, 0 LISTBOX ::oLbx FIELDS ;
                    ::oDb:NOMBRE  , DTOC(::oDb:FECHA) ,;
                    ::oDb:BANCO   ,      ::oDb:CTA_CTE ;
      HEADERS "Nombre", "Fecha", "Código"+CRLF+"Banco",;
              "Cuenta"+CRLF+"Corriente"                ;
      SIZES 400, 450 SIZE 200,107 ;
      OF oDlg UPDATE              ;
      ON DBLCLICK EVAL(bHacer)
    ::oLbx:nClrBackHead  := oApl:nClrBackHead
    ::oLbx:nClrForeHead  := oApl:nClrForeHead
    ::oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    ::oLbx:nClrBackFocus := oApl:nClrBackFocus
    ::oLbx:nClrForeFocus := oApl:nClrForeFocus
    ::oLbx:nHeaderHeight := 28
    ::oLbx:GoTop()
    ::oLbx:oFont       := ::oFont
    ::oLbx:aColSizes   := {200,70,60,60}
    ::oLbx:aHjustify   := {2,2,2,2}
    ::oLbx:aJustify    := {0,0,0,0}
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

//------------------------------------//
METHOD Muestra() CLASS TChq
   LOCAL bHacer, nOrd, oDlg, oM := Self
   LOCAL lReturn := .f.
bHacer := {||lReturn := ::lBuscar := .t., oDlg:End()}
nOrd   := ::Ordenar( 1 )

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 60 TITLE ::xVar
   @ 1.5, 0 LISTBOX ::oLbx FIELDS ;
                    ::oDb:CLIENTE , ::oDb:FECHA,;
                STR(::oDb:NUMFAC) ;
      HEADERS "Nombre", "Fecha"+CRLF+"Entrada",;
              "Nro."+CRLF+"Factura"            ;
      SIZES 400, 450 SIZE 220,107 ;
      OF oDlg UPDATE              ;
      ON DBLCLICK EVAL(bHacer)
    ::oLbx:nClrBackHead  := oApl:nClrBackHead
    ::oLbx:nClrForeHead  := oApl:nClrForeHead
    ::oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    ::oLbx:nClrBackFocus := oApl:nClrBackFocus
    ::oLbx:nClrForeFocus := oApl:nClrForeFocus
    ::oLbx:nHeaderHeight := 28
    ::oLbx:GoTop()
    ::oLbx:oFont       := ::oFont
    ::oLbx:aColSizes   := {200,130,60}
    ::oLbx:aHjustify   := {2,2,2}
    ::oLbx:aJustify    := {0,0,1}
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