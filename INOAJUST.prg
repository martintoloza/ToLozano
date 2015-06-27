// Programa.: INOAJUST.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Ajustes al Inventario
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

PROCEDURE InoAjust( cEsp )
   LOCAL oA, oDlg, oLbx, lSalir := .f.
   LOCAL aBarra, aDev := { "" }
   DEFAULT cEsp := " "
oA := TAjuste() ; oA:NEW( cEsp )
cEsp   := "Ajustes " + If( cEsp == "S", "Especiales", "" ) + " al Inventario"
aBarra := { {|| oA:Editar( oLbx,.t. ) }, {|| oA:Editar( oLbx,.f. ) }  ,;
            {|| oA:Contabil( .t. ) }   , {|| oA:Borrar( oLbx ) }      ,;
            {|| InoLista( 1,{oA:aCab[2],oA:aCab[2],"C",oA:aCab[1],"N" ,;
                          oApl:nTFor,.t.,"" } ), oA:oG[1]:SetFocus() },;
            {|| lSalir := oA:NEW(), oDlg:End() } }
AEVAL( oA:aCab[5], {|aVal| AADD( aDev, aVal[1] ) } )

DEFINE DIALOG oDlg FROM 0, 0 TO 320, 580 PIXEL TITLE cEsp
   @ 16, 00 SAY "Empresa"        OF oDlg RIGHT PIXEL SIZE 50,10
   @ 16, 52 GET oA:oG[1] VAR oA:aCab[3] OF oDlg PICTURE "@!"       ;
      VALID EVAL( {|| If( oApl:oEmp:Seek( {"localiz",oA:aCab[3]} ),;
                        ( nEmpresa( .t. ) , oA:aCab[1] := 0       ,;
                          oA:aCab[6] :=                            ;
                          SgteNumero( "AJUSTES",oApl:nEmpresa,.f.),;
                          oA:oG[3]:Refresh(), .t. )               ,;
                        (MsgStop("Esta Empresa NO EXISTE"), .f.) ) } );
      SIZE 21,10 PIXEL
   @ 28,00 SAY "Numero de Ajuste" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 28,52 GET oA:oG[2] VAR oA:aCab[1]  OF oDlg PICTURE "999999999" ;
      VALID ( oA:Buscar( oLbx,,oDlg ) )  SIZE 40,10 PIXEL
   @ 28, 90 SAY "Sgte. Ajuste"    OF oDlg RIGHT PIXEL SIZE 50,10
   @ 28,142 SAY oA:oG[3] VAR oA:aCab[6] OF oDlg PIXEL SIZE 44,10 ;
      UPDATE COLOR nRGB( 255,0,0 )
   @ 40, 00 SAY "Fecha [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 40, 52 GET oA:oG[4] VAR oA:aCab[2] OF oDlg               ;
      VALID If( EMPTY( oA:aCab[2] )                          ,;
              ( MsgStop("Fecha no puede ir en Blanco"), .f.) ,;
              ( oA:aCab[13] := NtChr( oA:aCab[2],"1" ), .t.) );
      WHEN !oA:oAju:lOK  SIZE 34,10 PIXEL UPDATE
   @ 56,06 LISTBOX oLbx FIELDS oA:oAju:CODIGO              ,;
                    LeerCodig( oA:oAju:CODIGO )            ,;
                    TRANSFORM( oA:oAju:CANTIDAD,"99,999.99999"),;
                         aDev[ oA:oAju:TIPO+1 ]             ;
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
    oLbx:aColSizes   := {90,250,90,100}
    oLbx:aHjustify   := {2,2,2,2}
    oLbx:aJustify    := {0,0,1,0}
    oLbx:ladjbrowse  := oLbx:lCellStyle := .f.
    oLbx:ladjlastcol := .t.
    oLbx:bKeyDown := {|nKey| If(nKey == VK_ESCAPE, ( oA:oG[1]:SetFocus() ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(aBarra[1]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, EVAL(aBarra[2]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, EVAL(aBarra[4]),) ))) }
   MySetBrowse( oLbx, oA:oAju )
   ACTIVAGET(oA:oG)
ACTIVATE DIALOG oDlg ON INIT ;
   (oDlg:Move(80,1), DefineBar( oDlg,oLbx,aBarra ) );
   VALID lSalir
oA:oAju:Destroy()
oA:oMvc:Destroy()
oA:oMvd:Destroy()
RETURN

//------------------------------------//
CLASS TAjuste

 DATA aCab, aCta, aUM, cEsp, cNit, oAju, oCA, oMvc, oMvd
 DATA oG            INIT ARRAY(4)

 METHOD NEW( cEsp ) Constructor
 METHOD Buscar( oLbx,aEd,oDlg )
 METHOD Borrar( oLbx )
 METHOD Editar( oLbx,lNew )
 METHOD Grabar( oLbx,lNew )
 METHOD Especial( lNew,lCam )
 METHOD Contabil( lG,oGet )
ENDCLASS

//------------------------------------//
METHOD NEW( cEsp ) CLASS TAjuste

If cEsp == NIL
   If ::aCab[12]
      ::Contabil( .f. )
   EndIf
   ::oAju:Destroy()
   oApl:oInv:cWhere := ''
Else
   oApl:oInv:cWhere := " ajuste_esp = " + xValToChar( cEsp )
   ::aCab := { 0,DATE(),oApl:oEmp:TITULAR,0,"",oApl:oEmp:AJUSTES+1,0,0,0,0,"UN",.f.,"" }
   ::aCta := {}
   ::cEsp := If( cEsp == "S", "E", " " )
   ::cNit := STRTRAN( LEFT( oApl:oEmp:NIT,AT("-",oApl:oEmp:NIT)-1 ),".","" )
   ::oAju := oApl:Abrir( "cadajust","codigo",.t.,,100 )
   ::oAju:Seek( {"empresa",oApl:nEmpresa,"numero",::aCab[1],;
                 "tipoajust",::cEsp,"row_salid",0} )
   ::oMvc := oApl:Abrir( "cgemovc" ,"empresa, ano_mes, control",.t.,,5 )
   ::oMvd := oApl:Abrir( "cgemovd" ,"empresa, ano_mes, control",.t.,,10 )
   ::aCab[5] := Buscar( { "clase","Ajustes" },"cadtipos","nombre, tipo_ajust",2,"tipo" )
   ::aCab[6] := SgteNumero( "AJUSTES",oApl:nEmpresa,.f. )
 //::aCab[6] := Buscar( "SELECT sec_val FROM secuencia WHERE empresa = " +;
 //                     STR(oApl:nEmpresa,2) + " AND sec_name = 'AJUSTES'","CM",,8,,4 ) +1
   ::oCA  := TInv() ; ::oCA:New( ,.f. )
   ::aUM  := ACLONE( ::oCA:aMed )
   ::aCta := Cuentas( 13,1 )
   //cEsp   := Cuentas( 3,1 )
   //AEVAL( cEsp, {| x | AADD( ::aCta, x[1] ) },10 )
   //AEVAL( cEsp, {| x | AADD( ::aCta, LEFT(x[1],6) ) },10 )
EndIf
RETURN .t.

//------------------------------------//
METHOD Buscar( oLbx,aEd,oDlg ) CLASS TAjuste
   LOCAL lSi := .t.
If oLbx # NIL
         lSi := .f.
   If Rango( ::aCab[1],0,::aCab[6] )
      If ::aCab[12]
         ::Contabil( .f. )
      EndIf
      If !::oAju:Seek( {"empresa",oApl:nEmpresa,"numero",::aCab[1],;
                        "tipoajust",::cEsp,"row_salid",0} ) .AND. ::aCab[1] > 0
         MsgStop( "Este Ajuste NO EXISTE !!" )
      Else
         If ::oAju:lOK
            ::oG[2]:oJump := oLbx
            ::aCab[2] := ::oAju:FECHA
         Else
            ::aCab[2] := DATE()
         EndIf
         ::aCab[04] := ::oAju:nRowCount
         ::aCab[12] := .f. //::oAju:lOK
         ::aCab[13] := NtChr( ::aCab[2],"1" )
         oDlg:Update()
         oLbx:Refresh() ; oLbx:GoTop()
         lSi := .t.
      EndIf
   EndIf
Else
   If oApl:oInv:Seek( {"codigo",::oAju:CODIGO} )
      If NtChr( ::oAju:CODIGO ) < oApl:oEmp:LENCOD
         MsgStop( "NO se Puede hacer Ajuste !!!","Este Código" )
         lSi := .f.
      ElseIf ::cEsp == "E"
         aEd[2] := Buscar( {"codigo",::oAju:CODIGO},"cadinves","codigo_sal",8 )
         If EMPTY( aEd[2] )
            MsgStop( "NO es Ajuste Especial !!!","Este Código" )
            lSi := .f.
         EndIf
      EndIf
      If lSi
         SaldoInv( ::oAju:CODIGO,::aCab[13] )
         If NtChr( ::oAju:CODIGO ) < oApl:oEmp:LENCOD
            oApl:aInvme[1] := 10
         EndIf
         ::oAju:TIPO   := If( ::cEsp == "E", 9, 1 )
         ::oAju:PCOSTO := oApl:aInvme[2]
         ::oAju:PVENTA := oApl:oInv:PVENTA
      EndIf
      AEVAL( ::aUM, { |x| oDlg:Del(1) } )
      ::aUM := UMedidas( ::oCA:aMed,oApl:oInv:UNIDADMED,oApl:oInv:CODCON )
      AEVAL( ::aUM, { |x| oDlg:Add( x[1] ) } )
   Else
      MsgStop( "Este Código NO EXISTE !!!" )
      lSi := .f.
   EndIf
EndIf
RETURN lSi

//------------------------------------//
METHOD Borrar( oLbx ) CLASS TAjuste
   LOCAL aBor, aEsp, cQry
If ::aCab[4] > 0
   If MsgNoYes( "Este Código "+::oAju:CODIGO,"Elimina" )
      aBor := { ::oAju:CODIGO, ::oAju:CANTIDAD , ::aCab[5][::oAju:TIPO,2],;
                ::oAju:PCOSTO, ::oAju:UNIDADMED, ::oAju:ROW_ID }
      If ::oAju:Delete( .t.,1 )
         PListbox( oLbx,::oAju )
       //Actualiz( cCodigo,nCantid,dFecha,nMov,nPCos,cUnidadM )
         Actualiz( aBor[1],-aBor[2],::aCab[2],aBor[3],aBor[4],aBor[5] )
         ::aCab[4] --
         ::aCab[12] := .t.
         If ::cEsp == "E"
            aEsp := Buscar( {"row_salid",aBor[6]},"cadajust",;
                             "row_id, codigo, cantidad, pcosto, unidadmed",9 )
            AEVAL( aEsp, {|a| Actualiz( a[2],-a[3],::aCab[2],6,a[4] )  ,;
                         Guardar( "DELETE FROM cadajust WHERE row_id = "+;
                                  LTRIM(STR(a[1])),"cadajust" ) } )
         EndIf
      EndIf
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Editar( oLbx,lNew ) CLASS TAjuste
   LOCAL oDlg, oGet := ARRAY(10), bGrabar, oE := Self
   LOCAL aEd := { "Modificando Ajuste","" }, nMed
   LOCAL bMed := {|cUMed| nMed := ArrayValor( ::aUM,cUMed,,.t. ) }
lNew := If( ::aCab[4] <= 0, .t., lNew )
If lNew
   aEd[1]  := "Nuevo Ajuste"
   bGrabar := {|| ::Grabar( oLbx,lNew )         ,;
                  ::oAju:xBlank(), ::aCab[4] ++ ,;
                  oDlg:Update(), oDlg:SetFocus() }
   oLbx:GoBottom() ; ::oAju:xBlank()
Else
   bGrabar := {|| ::Grabar( oLbx,lNew ), oLbx:Refresh(), oDlg:End() }
   ::aCab[07] := ::oAju:CODIGO
   ::aCab[08] := ::oAju:TIPO
   ::aCab[09] := ::oAju:CANTIDAD
   ::aCab[10] := ::oAju:PCOSTO
   ::aCab[11] := ::oAju:UNIDADMED
EndIf
oApl:oInv:Seek( {"codigo",::oAju:CODIGO} )
oApl:aInvme[1] := 0
EVAL( bMed,::oAju:UNIDADMED )

DEFINE DIALOG oDlg TITLE aEd[1] + STR(::aCab[4]) FROM 0, 0 TO 14,46
   @ 02,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 60,10
   @ 02,64 BTNGET oGet[1] VAR oE:oAju:CODIGO OF oDlg PICTURE "@!";
      VALID If( oE:Buscar( ,@aEd,oGet[7] )                      ,;
              ( EVAL( bMed,oApl:oInv:UNIDADMED )                ,;
                oDlg:Update(), .t. ), .f. )                      ;
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"                        ;
      ACTION EVAL({|| If(oE:oCA:Mostrar(), (oE:oAju:CODIGO := oE:oCA:oDb:CODIGO,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
   @ 14, 40 SAY   oGet[2] VAR oApl:oInv:DESCRIP OF oDlg PIXEL SIZE 100,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 26, 00 SAY "Codigo Salida" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 26, 64 SAY oGet[3] VAR aEd[2] OF oDlg PIXEL SIZE 56,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 38, 00 SAY "Cantidad" OF oDlg RIGHT PIXEL SIZE 60,8
   @ 38, 64 GET oGet[4] VAR ::oAju:CANTIDAD OF oDlg PICTURE "999,999.99999";
      VALID {|| If( ::oAju:CANTIDAD > 0, .t. ,;
          (MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>" ), .f.) ) };
      SIZE 40,10 PIXEL UPDATE
   @ 38,120 SAY oGet[5] VAR oApl:aInvme[1] OF oDlg PIXEL SIZE 90,10 PICTURE "[999,999.99999]";
      UPDATE COLOR nRGB( 255,0,0 )
   @ 50, 00 SAY "Tipo de Ajuste" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 50,64 COMBOBOX oGet[6] VAR ::oAju:TIPO ITEMS ArrayCol( ::aCab[5],1 ) ;
      SIZE 78,99 OF oDlg PIXEL UPDATE ;
      VALID {|| If( ::aCab[5][::oAju:TIPO,2] == 6 .AND. oApl:aInvme[1] == 0,;
             (MsgStop("No Puedo hacer Ajuste-Faltante sin Existencia"),.f.), ;
               .t. ) } ;
      WHEN EMPTY( ::cEsp )
   @ 62,00 SAY "Unidad Medida" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 62,64 COMBOBOX oGet[7] VAR nMed ITEMS ArrayCol( ::aUM,1 ) SIZE 70,99 ;
      OF oDlg PIXEL UPDATE
   @ 74,00 SAY "Precio Costo"  OF oDlg RIGHT PIXEL SIZE 60,10
   @ 74,64 GET oGet[8] VAR ::oAju:PCOSTO   OF oDlg PICTURE "999,999,999.99";
      VALID ::Contabil( ,oGet[8] )         SIZE 40,10 PIXEL UPDATE
   @ 88, 70 BUTTON oGet[09] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION;
      (If( EMPTY(::oAju:CODIGO) .OR. ::oAju:CANTIDAD <= 0             ,;
         (MsgStop("Imposible grabar este AJUSTE"), oGet[1]:SetFocus()),;
         ( oGet[9]:Disable(), ::oAju:UNIDADMED := ::aUM[nMed,2]  ,;
           EVAL( bGrabar ), oGet[9]:Enable() ))) PIXEL
   @ 88,120 BUTTON oGet[10] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
RETURN NIL

//------------------------------------//
METHOD Grabar( oLbx,lNew ) CLASS TAjuste
   LOCAL nMov := ::aCab[5][::oAju:TIPO,2]
If lNew
   If ::aCab[1] == 0
      ::aCab[1] := SgteNumero( "ajustes",oApl:nEmpresa,.t. )
      ::aCab[6] := ::aCab[1] + 1
      ::oG[2]:Refresh()
      ::oG[3]:Refresh()
   EndIf
   ::aCab[12]      := .t.
   ::oAju:EMPRESA  := oApl:nEmpresa
   ::oAju:NUMERO   := ::aCab[1]
   ::oAju:FECHA    := ::aCab[2]
   ::oAju:TIPOAJUST:= ::cEsp
   ::oAju:Append( .t. )
   Actualiz( ::oAju:CODIGO,::oAju:CANTIDAD,::aCab[2],nMov,;
             ::oAju:PCOSTO,::oAju:UNIDADMED )
   PListbox( oLbx,::oAju )
   ::Especial( .t. )
Else
   If ::aCab[7] # ::oAju:CODIGO .OR.;
      ::aCab[8] # ::oAju:TIPO   .OR. ::aCab[11] # ::oAju:UNIDADMED
      nMov := ::aCab[5][::aCab[8],2]
      Actualiz( ::aCab[7],-::aCab[9],::aCab[2],nMov,::aCab[10],::aCab[11] )
      ::aCab[9] := 0
      lNew := (::aCab[7] != ::oAju:CODIGO)
      nMov := ::aCab[5][::oAju:TIPO,2]
   EndIf
   ::oAju:Update( .t.,1 )
   Actualiz( ::oAju:CODIGO,::oAju:CANTIDAD-::aCab[9],::aCab[2],nMov,;
             ::oAju:PCOSTO,::oAju:UNIDADMED )
   ::Especial( .f.,lNew )
EndIf
If oApl:oInv:PCOSTO == 0 .AND. ::oAju:PCOSTO > 1
   oApl:oInv:PCOSTO := ::oArd:PCOSTO
   oApl:oInv:PUTIL  := If( oApl:oInv:PUTIL == 0, 30, oApl:oInv:PUTIL )
   oApl:oInv:PVENTA := ROUND(::oArd:PCOSTO * (1+oApl:oInv:PUTIL/100),0 )
   PrecioVenta()
   oApl:oInv:Update( .f.,1 )
EndIf
RETURN NIL

//------------------------------------//
METHOD Especial( lNew,lCam ) CLASS TAjuste
   LOCAL aEsp, aSal, cIns, cQry, nE, nCan, nEsp, nSal
If ::cEsp == "E"
   oApl:cPer := ::aCab[13]
   aSal := Especiales( ::oAju:CODIGO )
   nSal := LEN( aSal )
/*
   AEVAL( aSal, {|a| SaldoInv( a[1],::aCab[13] ), a[4] := oApl:aInvme[2] } )
 1 row_id
 2 empresa
 3 numero
 4 fecha
 5 codigo
 6 cantidad
 7 unidadmed
 8 tipo
 9 pcosto
 9 pventa
10 tipoajust
11 row_salid
*/
   cIns := "INSERT INTO cadajust VALUES ( null, " + LTRIM(STR(oApl:nEmpresa)) +;
              ", " + LTRIM(STR(::aCab[1])) + ", " + xValToChar(::aCab[2]) + ", "
   If lNew
      nCan := 0
      FOR nE := 1 TO nSal
         aSal[nE,2] *= ::oAju:CANTIDAD
         cQry := xValToChar(aSal[nE,1]) + ", "     + LTRIM(STR(aSal[nE,2])) + ", " +;
                 xValToChar(aSal[nE,3]) + ", 8, "  + LTRIM(STR(aSal[nE,4])) + ", " +;
                 LTRIM(STR(aSal[nE,5])) + ", 'E', "+ LTRIM(STR(::oAju:ROW_ID)) + " )"
         Guardar( cIns+cQry,"cadajust" )
         Actualiz( aSal[nE,1],aSal[nE,2],::aCab[2],6,aSal[nE,4],aSal[nE,3] )
      NEXT nE
   Else
      aEsp := Buscar( { "row_salid",::oAju:ROW_ID},"cadajust",;
                        "row_id, codigo, cantidad, pcosto, unidadmed",9 )
      nEsp := LEN( aEsp )
      If lCam
         AEVAL( aEsp, {|a| Actualiz( a[2],-a[3],::aCab[2],6,a[4],a[5] ), a[3] := 0 } )
      EndIf
      nCan := MIN( nEsp,nSal )
      FOR nE := 1 TO nCan
          ::aCab[9] := aSal[nE,2] * ::oAju:CANTIDAD - aEsp[nE,3]
         aEsp[nE,3] := aSal[nE,2] * ::oAju:CANTIDAD
         Actualiz( aSal[nE,1],::aCab[9],::aCab[2],6,aSal[nE,4],aSal[nE,3] )
         cQry := "UPDATE cadajust SET codigo = " + xValToChar(aSal[nE,1]) +;
                 ", cantidad = " + LTRIM(STR(aEsp[nE,3])) +;
                ", unidadmed = " + xValToChar(aSal[nE,3]) +;
                   ", pcosto = " + LTRIM(STR(aSal[nE,4])) +;
                   ", pventa = " + LTRIM(STR(aSal[nE,5])) +;
              " WHERE row_id = " + LTRIM(STR(aEsp[nE,1]))
         Guardar( cQry,"cadajust" )
      NEXT nE
      If nEsp > nSal
         FOR nE := nCan+1 TO nEsp
            Actualiz( aEsp[nE,2],aEsp[nE,3],::aCab[2],6,aEsp[nE,4],aEsp[nE,5] )
            Guardar( "DELETE FROM cadajust WHERE row_id = " + LTRIM(STR(aEsp[nE,1])),"cadajust" )
         NEXT nE
      ElseIf nSal > nEsp
         FOR nE := nCan+1 TO nSal
            aSal[nE,2] *= ::oAju:CANTIDAD
            cQry := xValToChar(aSal[nE,1]) + ", "     + LTRIM(STR(aSal[nE,2])) + ", " +;
                    xValToChar(aSal[nE,3]) + ", 8, "  + LTRIM(STR(aSal[nE,4])) + ", " +;
                   LTRIM(STR(aSal[nE,5])) + ", 'E', "+ LTRIM(STR(::oAju:ROW_ID)) + " )"
            Guardar( cIns+cQry,"cadajust" )
            Actualiz( aSal[nE,1],aSal[nE,2],::aCab[2],6,aSal[nE,4],aSal[nE,3] )
         NEXT nE
      EndIf
   EndIf
   //Calcular el Precio Costo para la Entrada
   cQry := "SELECT a.cantidad, a.pcosto, a.unidadmed, i.unidadmed, i.codcon "+;
           "FROM cadinven i, cadajust a " +;
           "WHERE a.codigo    = i.codigo" +;
            " AND a.row_salid = " + LTRIM(STR(::oAju:ROW_ID))
   nSal := Especiales( cQry,::oAju:CANTIDAD )
   If ::oAju:PCOSTO # nSal
      nEsp := ::aCab[5][::oAju:TIPO,2]
      Actualiz( ::oAju:CODIGO,-::oAju:CANTIDAD,::aCab[2],nEsp,::oAju:PCOSTO,::oAju:UNIDADMED )
      ::oAju:PCOSTO := nSal
      ::oAju:Update( .t.,1 )
      Actualiz( ::oAju:CODIGO, ::oAju:CANTIDAD,::aCab[2],nEsp,::oAju:PCOSTO,::oAju:UNIDADMED )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Contabil( lG,oGet ) CLASS TAjuste
If lG == NIL
   If ::oAju:CANTIDAD > 1
      If !MsgYesNo( "Este es el Precio Unitario","DIVIDIR" )
         ::oAju:PCOSTO := ROUND( ::oAju:PCOSTO / ::oAju:CANTIDAD,2 )
         oGet:Refresh()
      EndIf
   EndIf
   RETURN .t.
Else
   If LEN( ::aCta ) > 0 .AND. (::aCab[12] .OR. lG)
      oApl:oNit:Seek( {"codigo",::cNit} )
      ContAjuste( ::oMvc,::oMvd,::aCab[1],::aCta )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
FUNCTION Especiales( sCod,nCan )
   LOCAL aEsp := {}, aRes, hRes, nL
If nCan == NIL
   aRes := "SELECT e.codigo_sal, e.cantid_sal, e.unidadmed, i.pcosto, i.pventa "+;
           "FROM cadinven i, cadinves e " +;
           "WHERE e.codigo_sal = i.codigo"+;
            " AND e.codigo = '" + TRIM(sCod) + "'"
   hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   While nL > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      SaldoInv( aRes[1],oApl:cPer )
      If oApl:aInvme[2] # 0
         aRes[4] := oApl:aInvme[2]
      EndIf
      AADD( aEsp, { aRes[1],aRes[2],aRes[3],aRes[4],aRes[5] } )
      nL --
   EndDo
Else
   //Calcular el Precio Costo para la Entrada
   aEsp := 0
   hRes := If( MSQuery( oApl:oMySql:hConnect,sCod ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   While nL > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      aRes[2] := AFormula( aRes[2],aRes[3],aRes[4],aRes[5] )
      aEsp    += (aRes[1] * aRes[2])
      nL --
   EndDo
   aEsp := ROUND( aEsp / nCan,2 )
EndIf
   MSFreeResult( hRes )
RETURN aEsp

//------------------------------------//
PROCEDURE ContAjuste( oMvc,oMvd,nAju,aCtx )
   LOCAL aCge := {}, aCT, aInf, cQry, hRes, nL, nE, nK
/*
SELECT a.tipo, a.cantidad, a.pcosto, a.unidadmed, i.unidadmed,
       i.codcon, a.fecha, t.tipo_ajust, SUBSTRING(t.nombre,1,10)
FROM cadtipos t, cadinven i, cadajust a
WHERE t.clase   = 'Ajustes'
  AND a.tipo    = t.tipo
  AND a.codigo  = i.codigo
  AND a.empresa = 1
  AND a.numero  = 93
ORDER BY a.tipo
*/
cQry := "SELECT a.tipo, a.cantidad, a.pcosto, a.unidadmed, i.unidadmed, i.codcon, "+;
               "a.fecha, t.tipo_ajust, SUBSTRING(t.nombre,1,10), LENGTH(a.codigo) "+;
        "FROM cadtipos t, cadinven i, cadajust a "      +;
        "WHERE t.clase   = 'Ajustes'"                   +;
         " AND a.tipo    = t.tipo"                      +;
         " AND a.codigo  = i.codigo"                    +;
         " AND a.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND a.numero  = " + LTRIM(STR(nAju))         +;
        " ORDER BY a.tipo"
//MsgInfo( cQry,"ContAjuste" )
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   RETURN
EndIf
aInf := MyReadRow( hRes )
AEVAL( aInf, { | xV,nP | aInf[nP] := MyClReadCol( hRes,nP ) } )
aCT  := { aInf[1],aInf[8],"",aInf[9],0,0 }
nK   := 0
While nL > 0
   aInf[3] := AFormula( aInf[3],aInf[4],aInf[5],aInf[6] )
   If aInf[10] >= oApl:oEmp:LENCOD
      aCT[5] += (aInf[2] * aInf[3])
   Else
      aCT[6] += (aInf[2] * aInf[3])
   EndIf
   If (nL --) > 1
      aInf := MyReadRow( hRes )
      AEVAL( aInf, { | xV,nP | aInf[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aCT[1] # aInf[1]
      //aCT[3] := STRZERO(aCT[1]+2,2)
      cQry := LTRIM(STR(aCT[1]))
      nE   := aCT[1]
      If aCT[2] == 5
         //ENTRADAS
         aCT[5] += aCT[6]
         AADD( aCge, { aCtx[nE  ,1],"","",cQry,aCT[4],aCT[5],0,aCtx[nE  ,8],0 } )
         AADD( aCge, { aCtx[nE+9,1],"","",cQry,aCT[4],0,aCT[5],aCtx[nE+9,8],0 } )
       //AADD( aCge, { aCtx[2]+aCT[3],"","",cQry,"",aCT[5],0,0,0 } )
       //AADD( aCge, { aCtx[2],"","",cQry,aCT[4],aCT[5],0,0,0 } )
       //AADD( aCge, { aCtx[1],"","",cQry,aCT[4],0,aCT[5],0,0 } )
      Else
         AADD( aCge, { aCtx[nE+9,1],"","",cQry,aCT[4],aCT[5],0,aCtx[nE+9,8],0 } )
         AADD( aCge, { aCtx[  19,1],"","",cQry,aCT[4],aCT[6],0,aCtx[  19,8],0 } )
         AADD( aCge, { aCtx[nE  ,1],"","",cQry,aCT[4],0,aCT[5],aCtx[nE  ,8],0 } )
         AADD( aCge, { aCtx[  20,1],"","",cQry,aCT[4],0,aCT[6],aCtx[  20,8],0 } )
       //AADD( aCge, { aCtx[1],"","",cQry,aCT[4],nK,0,0,0 } )
       //AADD( aCge, { aCtx[2],"","",cQry,aCT[4],0,nK,0,0 } )
      EndIf
      aCT := { aInf[1],aInf[8],"",aInf[9],0,0 }
   EndIf
EndDo
MSFreeResult( hRes )
oApl:cPer := NtChr( aInf[7],"1" )
If oMvc:Seek( {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,"fuente",13,;
               "comprobant",nAju} )
   oMvc:CONSECUTIV:= 0
   oMvc:ESTADO    := 1
   oMvd:dbEval( {|o| o:EMPRESA := -4, Acumular( oMvc:ESTADO,o,3,3,.f.,.f. ) },;
                {"empresa",oApl:nEmpresa,"ano_mes",oApl:cPer,"control",oMvc:CONTROL} )
Else
   oMvc:EMPRESA   := oApl:nEmpresa ; oMvc:ANO_MES  := oApl:cPer
   oMvc:FECHA     := aInf[7]       ; oMvc:FUENTE   := 13
   oMvc:COMPROBANT:= nAju
   oMvc:CONTROL   := SgteCntrl( "control",oApl:cPer,.t. )
   oMvc:CONCEPTO  := "AJUSTES AL INVENTARIO # " + LTRIM(STR(nAju))
   oMvc:ESTADO    := 1
   oMvc:CODIGONIT := oApl:oNit:CODIGO_NIT
   oMvc:Append(.t.)
EndIf
aCT  := LTRIM(STR(oApl:oNit:CODIGO))
FOR nE := 1 TO LEN( aCge )
   If aCge[nE,6] > 0 .OR. aCge[nE,7] > 0
      aInf := Buscar( { "empresa",oApl:nPuc,"cuenta",aCge[nE,1] },"cgeplan",;
                        "infa, infb, infc, infd",8 )
      FOR nK := 1 TO 4
         cQry := TRIM( aInf[nK] )
         do case
         Case cQry == "COD-VAR"
             aCge[nE,nK+1] := aCge[nE,1]
         Case cQry == "DOCUMENTO"
             aCge[nE,nK+1] := LTRIM(STR(nAju))
         Case cQry == "NIT"
            If LEFT( aCge[nE,1],4 ) == "1435" .OR. LEFT( aCge[nE,1],4 ) == "6135"
               aCge[nE,nK+1] := aCtx[1,1]
            Else
               aCge[nE,nK+1] := aCT
               aCge[nE,8]    := oApl:oNit:CODIGO_NIT
            EndIf
         EndCase
      NEXT nK
      oMvd:Seek( "empresa = -4 ORDER BY row_id LIMIT 1","CM" )
      oMvd:EMPRESA   := oApl:nEmpresa  ; oMvd:ANO_MES  := oApl:cPer
      oMvd:CONTROL   := oMvc:CONTROL   ; oMvd:CUENTA   := aCge[nE,1]
      oMvd:INFA      := aCge[nE,2]     ; oMvd:INFB     := aCge[nE,3]
      oMvd:INFC      := aCge[nE,4]     ; oMvd:INFD     := aCge[nE,5]
      oMvd:VALOR_DEB := aCge[nE,6]     ; oMvd:VALOR_CRE:= aCge[nE,7]
      oMvd:CODIGO_NIT:= aCge[nE,8]     ; oMvd:PTAJE    := aCge[nE,9]
      Acumular( oMvc:ESTADO,oMvd,2,2,!oMvd:lOK,.f. )
      oMvc:CONSECUTIV ++
   EndIf
NEXT nE
  oMvc:Update(.f.,1)
RETURN

//------------------------------------//
FUNCTION LeerCodig( cCod )
   oApl:oInv:Seek( {"codigo",cCod} )
RETURN oApl:oInv:DESCRIP

//------------------------------------//
PROCEDURE AEspecial()
   LOCAL aBar, sCod, oAju, oDlg, oGet, oLbx, oAr
oAr  := TInv() ; oAr:New( ,.f. )
oAju := oApl:Abrir( "cadinves","codigo",.t. )
If oAju:RecCount() > 0
   oAju:GoTop():Read()
   oAju:xLoad()
EndIf
sCod := oAju:CODIGO
oAju:Seek( {"codigo",sCod} )
oAr:oDb:Seek( {"codigo",sCod} )
oAr:oDb:cWhere := " ajuste_esp = 'S'"
oGet := { ,,oAr:oDb:DESCRIP }
aBar := { {|| AjustEdita( oLbx,oAju,sCod,oAr,.t. ) },;
          {|| AjustEdita( oLbx,oAju,sCod,oAr,.f. ) },;
          {|| .t. }                    ,;
          {|| AjustBorra( oLbx,oAju ) },;
          {|| .t. }                    ,;
          {|| oDlg:End() } }
DEFINE DIALOG oDlg FROM 3, 3 TO 22, 56 ;
   TITLE "Código de Ajustes Especiales"
   @ 20,00 SAY "Código Entrada" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 20,64 BTNGET oGet[1] VAR sCod OF oDlg PICTURE "@!";
      VALID EVAL( {|| If( oAr:oDb:Seek( {"codigo",sCod} )            ,;
                      If( oAr:oDb:AJUSTE_ESP == "S"                  ,;
                        ( oGet[2]:Settext( oAr:oDb:DESCRIP )         ,;
                          oAju:Seek( {"codigo",sCod} )               ,;
                          oLbx:Refresh(), oLbx:GoTop(), .t. )        ,;
                        ( MsgStop("NO es Ajuste Especial !!!"), .f.)),;
                        ( MsgStop("Este Código no Existe") ,.f. )) } );
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"                       ;
      ACTION EVAL({|| If(oAr:Mostrar(), (sCod := oAr:oDb:CODIGO,;
                         oGet[1]:Refresh() ), )})
   @ 32,50 SAY   oGet[2] VAR oGet[3] OF oDlg PIXEL SIZE 100,10 ;
      UPDATE COLOR nRGB( 128,0,255 )

   @ 46,06 LISTBOX oLbx FIELDS oAju:CODIGO_SAL            ,;
                    LeerCodig( oAju:CODIGO_SAL )          ,;
                    TRANSFORM( oAju:CANTID_SAL,"9,999.99"),;
                               oAju:UNIDADMED              ;
      HEADERS "Código"+CRLF+"Salida", "Descripción", "Cantidad",;
              "Unidad"+CRLF+"Medida";
      SIZES 400, 450 SIZE 200,90 ;
      OF oDlg UPDATE PIXEL       ;
      ON DBLCLICK EVAL( aBar[2] )
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:nHeaderHeight := 28
    oLbx:GoTop()
    oLbx:oFont       := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:aColSizes   := {76,180,80,50}
    oLbx:aHjustify   := {2,2,2,2}
    oLbx:aJustify    := {0,0,1,2}
    oLbx:ladjbrowse  := oLbx:lCellStyle := .f.
    oLbx:ladjlastcol := .t.
    oLbx:bKeyDown := {|nKey| If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(aBar[1]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, EVAL(aBar[2]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, EVAL(aBar[4]),) )) }
   MySetBrowse( oLbx, oAju )

ACTIVATE DIALOG oDlg ON INIT ;
  ( oDlg:Move(80,1), DefineBar( oDlg,oLbx,aBar,01,18 ) )
oAju:Destroy()
oApl:oInv:cWhere := ''
RETURN

//------------------------------------//
STATIC PROCEDURE AjustBorra( oLbx,oAju )
If MsgNoYes( "Este Código "+oAju:CODIGO,"Elimina" )
   oAju:Read()
   oAju:Delete(.t.,1)
   oLbx:Refresh()
EndIf
RETURN

//------------------------------------//
STATIC PROCEDURE AjustEdita( oLbx,oAju,sCod,oAr,lNew )
   LOCAL nMed, oDlg, oGet := ARRAY(6), cText := "Modificando Código"
   LOCAL aUM, bGrabar := {|| oAju:Update(.t.,1), oDlg:End() }
If lNew
   oAju:xBlank()
   bGrabar := {|| oAju:CODIGO    := sCod        ,;
                  oAju:UNIDADMED := aUM[nMed,2] ,;
                  oAju:Append(.t.)              ,;
                  PListbox( oLbx,oAju )         ,;
                  oAju:xBlanK()                 ,;
                  oDlg:Update(), oDlg:SetFocus() }
   cText := "Nuevo Código"
EndIf
oApl:oInv:Seek( {"codigo",oAju:CODIGO_SAL} )
oAr:oDb:cWhere := ''
aUM := ACLONE( oAr:aMed )
nMed:= ArrayValor( aUM,oAju:UNIDADMED,,.t. )

DEFINE DIALOG oDlg TITLE cText FROM 0, 0 TO 10,40
   @ 02,00 SAY "Código Salida" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 02,64 BTNGET oGet[1] VAR oAju:CODIGO_SAL OF oDlg PICTURE "@!"     ;
      VALID EVAL( {|| If( oAr:oDb:Seek( {"codigo",oAju:CODIGO_SAL} )  ,;
                      If( oAju:CODIGO_SAL  # sCod                     ,;
                        ( AEVAL( aUM, { |x| oGet[4]:Del(1) } )        ,;
                          aUM := UMedidas( oAr:aMed,oAr:oDb:UNIDADMED,oAr:oDb:CODCON ),;
                          nMed:= ArrayValor( aUM,oAr:oDb:UNIDADMED,,.t. )             ,;
                          AEVAL( aUM, { |x| oGet[4]:Add( x[1] ) } )   ,;
                          oGet[4]:Refresh(), .t. )                    ,;
                        ( MsgStop("Código Igual al de Entrada"), .f.)),;
                        ( MsgStop("Este Código no Existe") ,.f. )) } ) ;
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"                              ;
      ACTION EVAL({|| If(oAr:Mostrar(), (oAju:CODIGO_SAL := oAr:oDb:CODIGO,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
   @ 14, 40 SAY oGet[2] VAR oApl:oInv:DESCRIP OF oDlg PIXEL SIZE 100,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 26, 00 SAY "Cantidad" OF oDlg RIGHT PIXEL SIZE 60,8
   @ 26, 64 GET oGet[3] VAR oAju:CANTID_SAL OF oDlg PICTURE "9,999.99";
      VALID {|| If( oAju:CANTID_SAL > 0, .t. ,;
          (MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>" ), .f.) ) };
      SIZE 40,10 PIXEL UPDATE
   @ 38,00 SAY "Unidad Medida" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 38,64 COMBOBOX oGet[4] VAR nMed ITEMS ArrayCol( aUM,1 ) SIZE 70,99 ;
      OF oDlg PIXEL UPDATE
   @ 52, 50 BUTTON oGet[5] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION;
      (If( EMPTY(oAju:CODIGO_SAL) .OR. EMPTY(oAju:CANTID_SAL)        ,;
         ( MsgStop("Imposible grabar CODIGO"), oGet[1]:SetFocus() )  ,;
          EVAL(bGrabar) )) PIXEL
   @ 52,100 BUTTON oGet[6] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
oAr:oDb:cWhere := " ajuste_esp = 'S'"
RETURN