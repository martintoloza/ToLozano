// Programa.: INOAJUST.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Ajustes al Inventario
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

PROCEDURE InoAjust()
   LOCAL oDlg, oLbx, oGet := ARRAY(2), lSalir := .f.
   LOCAL aBarra, aDev := { "" }, oA := TAjuste()
oA:New()
aBarra := { {|| oA:Editar( oLbx,.t. ) }, {|| oA:Editar( oLbx,.f. ) },;
            {|| .t. }                  , {|| oA:Borrar( oLbx ) }    ,;
            {|| ListAjus( {oA:aCab[2],oA:aCab[2],"N",.t.} ), oGet[1]:SetFocus() },;
            {|| lSalir := .t., oDlg:End() } }
AEVAL( oA:aCab[5], {|aVal| AADD( aDev, aVal[1] ) } )

DEFINE DIALOG oDlg FROM 0, 0 TO 320, 580 PIXEL;
   TITLE "Ajustes al Inventario"
   @ 02,00 SAY "Numero de Documento" OF oDlg RIGHT PIXEL SIZE 76,10
   @ 02,80 GET oGet[1] VAR oA:aCab[1]   OF oDlg PICTURE "999999999" ;
      SIZE 40,12 PIXEL
   @ 16,00 SAY "Fecha Ajuste [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 76,10
   @ 16,80 GET oGet[2] VAR oA:aCab[2]    OF oDlg              ;
      VALID If( EMPTY( oA:aCab[2] ), .f.                     ,;
        ( oA:Buscar( oLbx ), oLbx:GoTop(), oDlg:Update(), .t.) );
      SIZE 34,12 PIXEL
   @ 50,06 LISTBOX oLbx FIELDS oA:oAju:CODIGO            ,;
                    LeerCodig( oA:oAju:CODIGO )          ,;
                    TRANSFORM( oA:oAju:CANTIDAD,"9,999" ),;
                         aDev[ oA:oAju:TIPO+1 ]           ;
      HEADERS "Código"+CRLF+"Artículo", "Descripción", "Cantidad", "Tipo";
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
    oLbx:lCellStyle  := .f.
    oLbx:ladjlastcol := .t.
    oLbx:ladjbrowse  := .f.
   MySetBrowse( oLbx, oA:oAju )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT ;
   (oDlg:Move(80,1), DefineBar( oDlg,oLbx,aBarra,66,18 ) );
   VALID lSalir
oA:oAju:Destroy()
RETURN

//------------------------------------//
CLASS TAjuste

 DATA aCab, oAju

 METHOD NEW() Constructor
 METHOD Buscar( oLbx )
 METHOD Borrar( oLbx )
 METHOD Editar( oLbx,lNew )
 METHOD Grabar( oLbx,lNew )

ENDCLASS

//------------------------------------//
METHOD New() CLASS TAjuste

 ::aCab := { 0,DATE(),TInv(),0,"",0,0,0,0,"UN" }
 ::oAju := oApl:Abrir( "cadajust","Codigo",.t.,,100 )
 ::oAju:Seek( { "Empresa",oApl:nEmpresa,"Fecajus",::aCab[2],;
                "Documen",::aCab[1],"Tipoajust"," " } )
 ::aCab[3]:New( ,.f. )
 ::aCab[5] := Buscar( { "Clase","Ajustes" },"cadtipos",;
                      "Nombre, Tipo_ajust",2,"Tipo" )
RETURN NIL

//------------------------------------//
METHOD Buscar( oLbx ) CLASS TAjuste
   LOCAL lSi := .t.
 ::aCab[1] := If( ::aCab[1] == 0, 999999, ::aCab[1] )
 ::oAju:Seek( { "Empresa",oApl:nEmpresa,"Fecajus",::aCab[2],;
                "Documen",::aCab[1],"Tipoajust"," " } )
 ::aCab[4] := ::oAju:nRowCount
 oLbx:Refresh()
RETURN lSi

//------------------------------------//
METHOD Borrar( oLbx ) CLASS TAjuste
   LOCAL nMov
If ::aCab[4] > 0
   If MsgNoYes( "Este Código "+::oAju:CODIGO,"Elimina" )
      nMov := ::aCab[5][::oAju:TIPO,2]
      Actualiz( ::oAju:CODIGO,-::oAju:CANTIDAD,::oAju:FECAJUS,nMov,;
                ::oAju:PCOSTO,::oAju:UNIDADMED )
      If ::oAju:Delete( .t.,1 )
         ::aCab[4] --
         oLbx:GoBottom()
      EndIf
      oLbx:SetFocus() ; oLbx:Refresh()
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Editar( oLbx,lNew ) CLASS TAjuste
   LOCAL oDlg, oAr, oGet := ARRAY(8), bGrabar, oE := Self
   LOCAL aEd := { "Modificando Ajuste",0,NtChr( ::aCab[2],"1" ) }, nMed
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
   ::aCab[06] := ::oAju:CODIGO
   ::aCab[07] := ::oAju:TIPO
   ::aCab[08] := ::oAju:CANTIDAD
   ::aCab[09] := ::oAju:PCOSTO
   ::aCab[10] := ::oAju:UNIDADMED
EndIf
oAr := ::aCab[3]
oApl:oInv:Seek( {"Codigo",::oAju:CODIGO} )
EVAL( bMed,::oAju:UNIDADMED )

DEFINE DIALOG oDlg TITLE aEd[1] + STR(::aCab[4]) FROM 0, 0 TO 12,46
   @ 02,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 60,10
   @ 02,64 BTNGET oGet[1] VAR oE:oAju:CODIGO OF oDlg PICTURE "999999999!!!";
      VALID If( oApl:oInv:Seek( {"Codigo",oE:oAju:CODIGO} )  ,;
              ( oE:oAju:PCOSTO := oApl:oInv:PCOSTO           ,;
                oE:oAju:PVENTA := oApl:oInv:PVENTA           ,;
                EVAL( bMed,oApl:oInv:UNIDADMED )             ,;
                aEd[2] := SaldoInv( oE:oAju:CODIGO,aEd[3],1 ),;
                oDlg:Update(), .t. )                         ,;
              ( MsgStop( "Este Código NO EXISTE !!!" ), .f.) );
      SIZE 56,12 PIXEL  RESOURCE "BUSCAR"                     ;
      ACTION Eval({|| If(oAr:Mostrar(), (oE:oAju:CODIGO := oAr:oDb:CODIGO,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
   @ 16, 40 SAY   oGet[2] VAR oApl:oInv:DESCRIP OF oDlg PIXEL SIZE 100,12 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 30, 00 SAY "Cantidad" OF oDlg RIGHT PIXEL SIZE 60,8
   @ 30, 64 GET oGet[3] VAR ::oAju:CANTIDAD OF oDlg PICTURE "9,999.9";
      VALID {|| If( ::oAju:CANTIDAD > 0, .t. ,;
          (MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>" ), .f.) ) };
      SIZE 40,12 PIXEL UPDATE
   @ 30,120 SAY oGet[4] VAR aEd[2] OF oDlg PIXEL SIZE 90,12 PICTURE "[9,999.9]";
      UPDATE COLOR nRGB( 255,0,0 )
   @ 44, 00 SAY "Tipo de Ajuste" OF oDlg RIGHT PIXEL SIZE 60,8
   @ 44,64 COMBOBOX oGet[5] VAR ::oAju:TIPO ITEMS ArrayCol( ::aCab[5],1 ) SIZE 68,99 ;
      OF oDlg PIXEL UPDATE ;
      VALID {|| If( ::aCab[5][::oAju:TIPO,2] == 6 .AND. aEd[2] == 0,;
             (MsgStop("No Puedo hacer Ajuste-Faltante sin Existencia"),.f.),;
               .t. ) }
   @ 58,00 SAY "Unidad Medida" OF oDlg RIGHT PIXEL SIZE 60,8
   @ 58,64 COMBOBOX oGet[6] VAR nMed ITEMS ArrayCol( oAr:aMed,1 ) SIZE 68,99 ;
      OF oDlg PIXEL UPDATE
   @ 74, 70 BUTTON oGet[7] PROMPT "&Grabar"   SIZE 44,12 OF oDlg ACTION;
      (If( EMPTY(::oAju:CODIGO) .OR. ::oAju:CANTIDAD <= 0       ,;
         (MsgStop("Imposible grabar este AJUSte"), oGet[1]:SetFocus()),;
         ( oGet[7]:Disable(), ::oAju:UNIDADMED := oAr:aMed[nMed,2]    ,;
           EVAL( bGrabar ), oGet[7]:Enable() ))) PIXEL
   @ 74,120 BUTTON oGet[8] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
RETURN NIL

//------------------------------------//
METHOD Grabar( oLbx,lNew ) CLASS TAjuste
   LOCAL nMov := ::aCab[5][::oAju:TIPO,2]
If lNew
   ::oAju:EMPRESA := oApl:nEmpresa
   ::oAju:DOCUMEN := ::aCab[1]
   ::oAju:FECAJUS := ::aCab[2]
   ::oAju:Append( .t. )
   Actualiz( ::oAju:CODIGO,::oAju:CANTIDAD,::oAju:FECAJUS,nMov,;
             ::oAju:PCOSTO,::oAju:UNIDADMED )
   PListbox( oLbx,::oAju )
Else
   If ::aCab[6] # ::oAju:CODIGO .OR.;
      ::aCab[7] # ::oAju:TIPO   .OR. ::aCab[10] # ::oAju:UNIDADMED
      nMov := ::aCab[5][::aCab[7],2]
      Actualiz( ::aCab[6],-::aCab[8],::oAju:FECAJUS,nMov,::aCab[9],::aCab[10] )
      ::aCab[8] := 0
      nMov := ::aCab[5][::oAju:TIPO,2]
   EndIf
   ::oAju:Update( .t.,1 )
   Actualiz( ::oAju:CODIGO,::oAju:CANTIDAD-::aCab[8],::oAju:FECAJUS,nMov,;
             ::oAju:PCOSTO,::oAju:UNIDADMED )
EndIf
RETURN NIL

//------------------------------------//
FUNCTION LeerCodig( cCod )
   oApl:oInv:Seek( {"Codigo",cCod} )
RETURN oApl:oInv:DESCRIP

//------------------------------------//
PROCEDURE InoLiAju()
   LOCAL oDlg, oGet := ARRAY(6), aAju := { DATE(),DATE(),"S",.f. }
DEFINE DIALOG oDlg FROM 0, 0 TO 160,370 PIXEL;
   TITLE "Listo los Ajustes al Inventario"
   @ 02,00 SAY "Fecha Inicial [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02,92 GET oGet[1] VAR aAju[1] OF oDlg SIZE 40,12 PIXEL
   @ 16,00 SAY "Fecha   Final [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 16,92 GET oGet[2] VAR aAju[2] OF oDlg ;
      VALID aAju[2] >= aAju[1] SIZE 40,12 PIXEL
   @ 30,00 SAY "SOLAMENTE EL RESUMEN  S/N" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 30,92 GET oGet[3] VAR aAju[3] OF oDlg PICTURE "!"     SIZE 10,12 PIXEL;
      VALID aAju[3] $ "SN"
   @ 44, 98 CHECKBOX oGet[4] VAR aAju[4] PROMPT "Vista &Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 60, 70 BUTTON oGet[5] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[5]:Disable(), ListAjus( aAju ), oDlg:End() ) PIXEL
   @ 60,120 BUTTON oGet[6] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 66, 02 SAY "[INOAJUST]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
PROCEDURE ListAjus( aLS )
   LOCAL oDPrn, aLis, hRes, nC, nL, nK, nT
   LOCAL aAju := { 0,0,0,0,0,0,0,0,0,0,"" }, aTip
oDPrn := TDosPrint()
oDPrn:New( oApl:cPuerto,oApl:cImpres,{"AJUSTES AL INVENTARIO","DESDE "  +;
         NtChr( aLS[1],"2" ) + " HASTA " + NtChr( aLS[1],"2" ),"C O D I G O-  "+;
         "N O M B R E   D E L   A R T I C U L O-------   FALTANTE  SOBRANTE   "  +;
         "PRECIO COSTO  PRECIO VENTA"},aLS[4],1,2 )
aTip := Buscar( { "Clase","Ajustes" },"cadtipos","Tipo, Nombre, 0, 0",2,"Tipo" )
aLis := "SELECT a.Codigo, a.Cantidad, a.Tipo, "       +;
        "a.Pcosto, a.Pventa, i.Descrip, t.Tipo_ajust "+;
        "FROM cadajust a, cadinven i, cadtipos t "    +;
        "WHERE a.Empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND a.Fecajus >= " + xValToChar( aLS[1] ) +;
         " AND a.Fecajus <= " + xValToChar( aLS[2] ) +;
         " AND a.Codigo = i.Codigo AND a.Tipo = t.Tipo ORDER BY a.Codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,aLis ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aLis := MyReadRow( hRes )
   AEval( aLis, { | xV,nP | aLis[nP] := MyClReadCol( hRes,nP ) } )
   If aLis[nL,7] == 6     //AJUSTE_S
      nC := 61 ; nK := 1
   Else
      nC := 71 ; nK := 4
   EndIf
   nT := aLis[nL,3]
   If aLS[3] == "N"
      oDPrn:Titulo( 108 )
      oDPrn:Say( oDPrn:nL,01,aLis[nL,1] )
      oDPrn:Say( oDPrn:nL,14,aLis[nL,6] )
      oDPrn:Say( oDPrn:nL,nC,TransForm(aLis[nL,2],"9,999.99" ))
      oDPrn:Say( oDPrn:nL,83,TransForm(aLis[nL,4],"999,999,999" ))
      oDPrn:Say( oDPrn:nL,97,TransForm(aLis[nL,5],"999,999,999" ))
      oDPrn:nL ++
   EndIf
   aAju[nK]   +=  aLis[nL,2]
   aAju[nK+1] += (aLis[nL,2] * aLis[nL,4])
   aAju[nK+2] += (aLis[nL,2] * aLis[nL,5])
   aTip[nT,3] +=  aLis[nL,2]
   aTip[nT,4] += (aLis[nL,2] * aLis[nL,5])
   nL --
EndDo
oDPrn:Titulo( 108 )
oDPrn:Say(  oDPrn:nL,00,Replicate("_",108),,,1 )
oDPrn:Say(++oDPrn:nL,14,"TOTAL FALTANTES",,,1 )
oDPrn:Say(  oDPrn:nL,61,TransForm(aAju[1],"9,999.99" ))
oDPrn:Say(  oDPrn:nL,81,TransForm(aAju[2],"9,999,999,999" ))
oDPrn:Say(  oDPrn:nL,95,TransForm(aAju[3],"9,999,999,999" ))
oDPrn:Say(++oDPrn:nL,14,"TOTAL SOBRANTES",,,1 )
oDPrn:Say(  oDPrn:nL,71,TransForm(aAju[4],"9,999.99" ))
oDPrn:Say(  oDPrn:nL,81,TransForm(aAju[5],"9,999,999,999" ))
oDPrn:Say(  oDPrn:nL,95,TransForm(aAju[6],"9,999,999,999" ))
oDPrn:nL += 2
oDPrn:Say( oDPrn:nL,14,"RESUMEN DISTRIBUCION CANTIDADES POR CENTRO DE COSTO",,,1 )
FOR nT := 1 TO LEN( aTip )
   If aTip[nT,3] > 0
      oDPrn:Say(++oDPrn:nL,14,aTip[nT,1],,,1 )
      oDPrn:Say(  oDPrn:nL,23,aTip[nT,2] )
      oDPrn:Say(  oDPrn:nL,59,TransForm(aTip[nT,3],"99,999.99" ) )
      oDPrn:Say(  oDPrn:nL,81,TransForm(aTip[nT,4],"999,999,999" ) )
   EndIf
NEXT
oDPrn:NewPage()
oDPrn:End()
RETURN
