// Programa.: INOAJUES.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Ajustes Especiales al Iventario
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

PROCEDURE InoAjues()
   LOCAL oDlg, oLbx, oGet := ARRAY(2), lSalir := .f.
   LOCAL aBarra, oA := TAjuesp()
oA:New()
aBarra := { {|| oA:Editar( oLbx,.t. ) }, {|| oA:Editar( oLbx,.f. ) },;
            {|| .t. }                  , {|| oA:Borrar( oLbx ) }    ,;
            {|| ListAjus( {oA:aCab[2],oA:aCab[2],"N",.t.} ), oGet[1]:SetFocus() },;
            {|| lSalir := oA:Fin(), oDlg:End() } }
DEFINE DIALOG oDlg FROM 0, 0 TO 320, 580 PIXEL;
   TITLE "Ajustes Especiales al Inventario" OF oApl:oWnd
   @ 02,00 SAY "Numero de Documento" OF oDlg RIGHT PIXEL SIZE 76,10
   @ 02,80 GET oGet[1] VAR oA:aCab[1] OF oDlg PICTURE "999999999" ;
      SIZE 40,12 PIXEL
   @ 16,00 SAY "Fecha Ajuste [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 76,10
   @ 16,80 GET oGet[2] VAR oA:aCab[2] OF oDlg                   ;
      VALID If( EMPTY( oA:aCab[2] ), .f.                       ,;
        ( oA:Buscar( oLbx ), oLbx:GoTop(), oDlg:Update(), .t.) );
      SIZE 34,12 PIXEL
   @ 50,06 LISTBOX oLbx FIELDS oA:oAju:CODIGO            ,;
                    LeerCodig( oA:oAju:CODIGO )          ,;
                    TRANSFORM( oA:oAju:CANTIDAD,"9,999" ),;
                    "Entrada Especial"                 ;
      HEADERS "Código"+CRLF+"Artículo", "Descripción", "Cantidad",;
              "Tipo de"+CRLF+"Ajuste";
      SIZES 400, 450 SIZE 280,100 ;
      OF oDlg UPDATE PIXEL        ;
      ON DBLCLICK EVAL( aBarra[2] )
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:GoTop()
    oLbx:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:nHeaderHeight := 28
    oLbx:aColSizes  := {90,250,90,100}
    oLbx:aHjustify  := {2,2,2,2}
    oLbx:aJustify   := {0,0,1,0}
    oLbx:bKeyDown := {|nKey| If(nKey == VK_ESCAPE, ( oGet[1]:SetFocus() ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(aBarra[1]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, EVAL(aBarra[2]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, EVAL(aBarra[4]),) ))) }
    oLbx:lCellStyle  := oLbx:ladjbrowse  := .f.
    oLbx:ladjlastcol := .t.
   MySetBrowse( oLbx, oA:oAju )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg NOWAIT ON INIT ;
   (oDlg:Move(80,1), DefineBar( oDlg,oLbx,aBarra,66,18 ) );
   VALID lSalir
RETURN

//------------------------------------//
CLASS TAjuesp

 DATA aCab, oAju

 METHOD NEW() Constructor
 METHOD Fin()
 METHOD Buscar( oLbx )
 METHOD Borrar( oLbx )
 METHOD Editar( oLbx,lNew )
 METHOD Grabar( oLbx,lNew )

ENDCLASS

//------------------------------------//
METHOD New() CLASS TAjuesp

 oApl:oInv:cWhere := "Ajuste_esp = 'S'"
 ::aCab := { 0,DATE(),TInv(),0,0,0,0,0,"UN" }
 ::oAju := oApl:Abrir( "cadajust","Codigo",.t.,,100 )
 ::oAju:Seek( { "Empresa",oApl:nEmpresa,"Fecajus",::aCab[2],;
                "Documen",::aCab[1],"Tipoajust","E","Row_salid",0 } )
 ::aCab[3]:New( ,.f. )

RETURN NIL

//------------------------------------//
METHOD Fin() CLASS TAjuesp
 ::oAju:Destroy()
 oApl:oInv:cWhere := ''
RETURN .t.

//------------------------------------//
METHOD Buscar( oLbx ) CLASS TAjuesp
   LOCAL lSi := .t.
 ::aCab[1] := If( ::aCab[1] == 0, 999999, ::aCab[1] )
 ::oAju:Seek( { "Empresa",oApl:nEmpresa,"Fecajus",::aCab[2],;
                "Documen",::aCab[1],"Tipoajust","E","Row_salid",0 } )
 ::aCab[4] := ::oAju:nRowCount
 oLbx:Refresh()
RETURN lSi


//------------------------------------//
METHOD Borrar( oLbx ) CLASS TAjuesp
   LOCAL aEsp, cQry
If ::aCab[4] > 0
   If MsgNoYes( "Este Código "+::oAju:CODIGO,"Elimina" )
      aEsp := Buscar( {"Row_salid",::oAju:ROW_ID},"cadajust",;
                       "Row_id, Codigo, Cantidad, Pcosto",9 )
      Actualiz( ::oAju:CODIGO,-::oAju:CANTIDAD,::oAju:FECAJUS,5,::oAju:PCOSTO )
      AEVAL( aEsp, {|a| Actualiz( a[2],-a[3],::oAju:FECAJUS,6,a[4] )  ,;
                        cQry := "DELETE FROM cadajust WHERE Row_id = "+;
                                LTRIM(STR(a[1]))                      ,;
                        MSQuery( oApl:oMySql:hConnect,cQry ) } )
      If ::oAju:Delete( .t.,1 )
         ::aCab[4] --
         oLbx:GoBottom()
      EndIf
      oLbx:SetFocus() ; oLbx:Refresh()
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Editar( oLbx,lNew ) CLASS TAjuesp
   LOCAL oDlg, oAr, oGet := ARRAY(6), bGrabar, oE := Self
   LOCAL aEd := { "Modificando Ajuste","" }, nMed
   LOCAL bMed := {|cUMed| nMed := ArrayValor( oAr:aMed,cUMed,,.t. ) }
lNew := If( ::aCab[4] <= 0, .t., lNew )
If lNew
   aEd[1]  := "Nuevo Ajuste"
   bGrabar := {|| ::Grabar( oLbx,lNew )         ,;
                  ::oAju:xBlank(), ::aCab[4] ++ ,;
                  oDlg:Update(), oDlg:SetFocus() }
   oLbx:GoBottom() ; ::oAju:xBlank()
Else
   bGrabar := {|| ::Grabar( oLbx,lNew ), oLbx:Refresh(), oDlg:End() }
   ::aCab[5] := ::oAju:CODIGO
   ::aCab[6] := ::oAju:CANTIDAD
   ::aCab[7] := ::oAju:PCOSTO
   ::aCab[8] := ::oAju:UNIDADMED
EndIf
oAr := ::aCab[3]
oApl:oInv:Seek( {"Codigo",::oAju:CODIGO} )
EVAL( bMed,::oAju:UNIDADMED )

DEFINE DIALOG oDlg TITLE aEd[1] + STR(::aCab[4]) FROM 0, 0 TO 10,46
   @ 02,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 60,10
   @ 02,64 BTNGET oGet[1] VAR oE:oAju:CODIGO OF oDlg         ;
      VALID If( oApl:oInv:Seek( {"Codigo",oE:oAju:CODIGO} ) ,;
              ( aEd[2] := Buscar( {"Codigo",oE:oAju:CODIGO} ,;
                                 "cadinves","Codigo_sal",8 ),;
                If( EMPTY( aEd[2] )                         ,;
              ( MsgStop( "NO es Ajuste Especial !!!" ), .f.),;
              ( oE:oAju:PCOSTO := oApl:oInv:PCOSTO          ,;
                oE:oAju:PVENTA := oApl:oInv:PVENTA          ,;
                EVAL( bMed,oApl:oInv:UNIDADMED )            ,;
                oDlg:Update(), .t. ) ) )                    ,;
              ( MsgStop( "Este Código NO EXISTE !!!" ), .f.));
      SIZE 56,12 PIXEL  RESOURCE "BUSCAR"                    ;
      ACTION Eval({|| If(oAr:Mostrar(), (oE:oAju:CODIGO := oAr:oDb:CODIGO,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
   @ 16,40 SAY oGet[2] VAR oApl:oInv:DESCRIP    OF oDlg PIXEL SIZE 100,12 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 30,00 SAY "Codigo Salida" OF oDlg RIGHT PIXEL SIZE 60,8
   @ 30,64 SAY oGet[3] VAR aEd[2] OF oDlg PIXEL SIZE 56,12 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 44,00 SAY "Cantidad" OF oDlg RIGHT PIXEL SIZE 60,8
   @ 44,64 GET oGet[4] VAR ::oAju:CANTIDAD OF oDlg PICTURE "9,999.9";
      VALID {|| If( ::oAju:CANTIDAD > 0, .t. ,;
          (MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>" ), .f.) ) };
      SIZE 40,12 PIXEL UPDATE
//   @ 58,00 SAY "Unidad Medida" OF oDlg RIGHT PIXEL SIZE 60,8
//   @ 58,64 COMBOBOX oGet[5] VAR nMed ITEMS ArrayCol( oAr:aMed,1 ) SIZE 68,99 ;
///      OF oDlg PIXEL UPDATE

   @ 60, 70 BUTTON oGet[5] PROMPT "&Grabar"   SIZE 44,12 OF oDlg ACTION;
      (If( EMPTY(::oAju:CODIGO) .OR. ::oAju:CANTIDAD <= 0       ,;
         (MsgStop("Imposible grabar este AJUSte"), oGet[1]:SetFocus()),;
         ( oGet[5]:Disable(), ::oAju:UNIDADMED := oAr:aMed[nMed,2]    ,;
           EVAL( bGrabar ), oGet[5]:Enable() ))) PIXEL
   @ 60,120 BUTTON oGet[6] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
RETURN NIL

//------------------------------------//
METHOD Grabar( oLbx,lNew ) CLASS TAjuesp
   LOCAL aEsp, aSal, cQry, nE, nEsp, nSal, nCantid := 0
cQry := "SELECT e.Codigo_sal, e.Cantid_sal, i.Pcosto, i.Pventa "+;
        "FROM cadinves e, cadinven i "+;
        "WHERE e.Codigo = '" + TRIM(::oAju:CODIGO) + "' AND e.Codigo = i.Codigo"
aSal := Buscar( cQry,"CM",,9 )
If lNew
   ::oAju:EMPRESA  := oApl:nEmpresa
   ::oAju:DOCUMEN  := ::aCab[1]
   ::oAju:FECAJUS  := ::aCab[2]
   ::oAju:TIPO     := 9          //5_Entrada Especial
   ::oAju:TIPOAJUST:= "E"
   ::oAju:Append( .t. )
   Actualiz( ::oAju:CODIGO,::oAju:CANTIDAD,::aCab[2],5,::oAju:PCOSTO )
   PListbox( oLbx,::oAju )
   nCantid       := ::oAju:CANTIDAD
   ::oAju:TIPO     := 8          //6_Salida  Especial
   ::oAju:ROW_SALID:= ::oAju:ROW_ID
   AEVAL( aSal, {|a| ::oAju:CODIGO := a[1], ::oAju:CANTIDAD := a[2] * nCantid,;
                     ::oAju:PCOSTO := a[3], ::oAju:PVENTA   := a[4]          ,;
                     ::oAju:Append( .f. )    ,;
                     Actualiz( a[1],::oAju:CANTIDAD,::aCab[2],6,a[3] ) } )
Else
   aEsp := Buscar( { "Row_salid",::oAju:ROW_ID},"cadajust",;
                     "Row_id, Codigo, Cantidad, Pcosto",9 )
   nEsp := LEN( aEsp ) ; nSal := LEN( aSal )
   If ::aCab[5] # ::oAju:CODIGO
      Actualiz( ::aCab[5],-::aCab[6],::aCab[2],5,::oAju:PCOSTO )
      AEVAL( aEsp, {|a| Actualiz( a[2],-a[3],::aCab[2],6,a[4] ), a[3] := 0 } )
      ::aCab[6] := 0
   EndIf
   ::oAju:Update( .t.,1 )
   Actualiz( ::oAju:CODIGO,::oAju:CANTIDAD-::aCab[6],::aCab[2],5,::oAju:PCOSTO )
   nCantid := MIN( nEsp,nSal )
   FOR nE := 1 TO nCantid
      aEsp[nE,4] := aSal[nE,2] * ::oAju:CANTIDAD - aEsp[nE,3]
      aEsp[nE,3] := aSal[nE,2] * ::oAju:CANTIDAD
      Actualiz( aSal[nE,1],aEsp[nE,4],::aCab[2],6,aSal[nE,3] )
      cQry := "UPDATE cadajust SET Codigo = " + xValToChar(aSal[nE,1]) +;
              ", Cantidad = "    + LTRIM(STR(aEsp[nE,3])) +;
              ", Pcosto = "      + LTRIM(STR(aSal[nE,3])) +;
              ", Pventa = "      + LTRIM(STR(aSal[nE,4])) +;
              " WHERE Row_id = " + LTRIM(STR(aEsp[nE,1]))
      MSQuery( oApl:oMySql:hConnect,cQry )
   NEXT
   If nEsp > nSal
      FOR nE := nCantid+1 TO nEsp
         aEsp[nE,3] := ::oAju:CANTIDAD - aEsp[nE,3]
         Actualiz( aEsp[nE,2],aEsp[nE,3],::aCab[2],6,aEsp[nE,4] )
         cQry := "DELETE FROM cadajust WHERE Row_id = " + LTRIM(STR(aEsp[nE,1]))
         MSQuery( oApl:oMySql:hConnect,cQry )
      NEXT
   ElseIf nSal > nEsp
      aEsp := "INSERT INTO cadajust VALUES ( null, " + LTRIM(STR(oApl:nEmpresa)) +;
              ", " + LTRIM(STR(::aCab[1])) + ", " + xValToChar(::aCab[2]) + ", "
      FOR nE := nCantid+1 TO nSal
         aSal[nE,2] := aSal[nE,2] * ::oAju:CANTIDAD
         cQry := aEsp   + xValToChar(aSal[nE,1])  + ", " + LTRIM(STR(aSal[nE,2])) +;
                 ", 8, " + LTRIM(STR(aSal[nE,3])) + ", " + LTRIM(STR(aSal[nE,4])) +;
                 ", 'E', "+ LTRIM(STR(::oAju:ROW_ID)) + " )"
         MSQuery( oApl:oMySql:hConnect,cQry )
         Actualiz( aSal[nE,1],aSal[nE,2],::aCab[2],6,aSal[nE,3] )
      NEXT
   EndIf
EndIf
RETURN NIL
