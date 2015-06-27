// Programa.: CGEMOVTO.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Modulo para la Elaboracion de los Comprobantes
#include "Fivewin.ch"
#include "Btnget.ch"
#include "nget.ch"
//#include "Report.ch"

MEMVAR oApl

FUNCTION MovimientoCge( nFte )
   LOCAL aCge := { "Movimiento Contable || ",.t.,.f. }
   LOCAL oDlg, oLbx, oM, oAget := ARRAY(6)
   DEFAULT nFte := 0
oM := TMov() ; oM:New( nFte )
SETKEY( VK_F4,{|| If( Empresa(), ( oDlg:SetText( aCge[1] + oApl:cEmpresa ),;
                      aCge[2] := .t., oDlg:Update() ), ), oAget[1]:SetFocus() } )
DEFINE DIALOG oDlg RESOURCE "MOVIMIENTO";
   TITLE aCge[1] + oApl:cEmpresa OF oApl:oWnd
   REDEFINE GET oAget[1] VAR oM:aMov[1] ID 01 OF oDlg PICTURE "999999" UPDATE ;
      WHEN aCge[2]                                                            ;
      VALID If( NtChr( oM:aMov[1],"P" ), (aCge[2] := .f., oM:Fechas()), .f. )
   REDEFINE SAY VAR oM:aMov[15]         ID 27 OF oDlg UPDATE COLOR nRGB( 255,0,0 )
   REDEFINE BTNGET oAget[2] VAR oM:aMov[2] ID 03 OF oDlg PICTURE "99"         ;
      RESOURCE "BUSCAR"                                                       ;
      ACTION EVAL({|| If(oM:oFte:Mostrar(), (oM:aMov[2] := oM:oFte:oDb:FUENTE,;
                        oAget[2]:Refresh(), oAget[2]:lValid(.f.)), )})        ;
      VALID EVAL( {|| If( oM:Compras()                                       ,;
                        ( oAget[3]:Settext( oM:oFte:oDb:DESCRIPCIO )         ,;
                          oDlg:Update(), .t.)                                ,;
                        ( MsgStop("Esta Fuente no Existe"), .f.) ) } )
   REDEFINE SAY oAget[3]                ID 04 OF oDlg UPDATE
   REDEFINE GET oAget[4] VAR oM:aMov[3] ID 06 OF oDlg  PICTURE "999999"UPDATE ;
      VALID EVAL( {|| aCge[3] := oM:BuscarMov( oDlg )       ,;
                  If( aCge[3], (oAget[4]:oJump := oLbx), )  ,;
                  oM:Filtrar( 0,oDlg,oLbx ), .t. } )
   REDEFINE GET oM:oMvc:FECHA           ID 08 OF oDlg UPDATE ;
      WHEN oM:oMvc:ESTADO # 2                                ;
      VALID oM:Fechas( oDlg,oLbx )
   REDEFINE SAY VAR oM:oMvc:CONTROL     ID 10 OF oDlg UPDATE
   REDEFINE BTNGET oAget[5] VAR oM:aMov[10] ID 12 OF oDlg                   ;
      RESOURCE "BUSCAR" PICTURE "9999999999"                                ;
      ACTION EVAL({|| If(oM:oNit:Mostrar( ,,oM:aMov[10] ), (oM:aMov[10] :=  ;
                         oM:oNit:oDb:CODIGO, oAget[5]:Refresh() ), )} )     ;
      VALID EVAL( {|| If( EMPTY( oM:aMov[10] ), .t.                        ,;
                     (If( oM:oNit:Buscar( oM:aMov[10],,.t. )               ,;
                        ( oM:oMvc:CODIGONIT := oM:oNit:oDb:CODIGO_NIT      ,;
                          oM:aMov[11] := oM:oNit:oDb:NOMBRE, oDlg:Update() ,;
                      If( aCge[3], oM:oMvc:Update(.t.,1), ), .t. )         ,;
                     (If( MsgYesNo("Desea ingresarlo","Este Nit no Existe"),;
                        oM:oNit:Editar( ,.t.,,oM:aMov[10] ), ),.f.) ))) } ) UPDATE
   REDEFINE SAY VAR oM:aMov[11]         ID 13 OF oDlg UPDATE
   REDEFINE SAY VAR oM:aMov[5]          ID 15 OF oDlg UPDATE COLOR nRGB( 255,0,0 )
   REDEFINE GET oAget[6] VAR oM:oMvc:CONCEPTO ID 17 OF oDlg UPDATE;
      WHEN oM:oMvc:ESTADO # 2                                     ;
      VALID EVAL( { || If( EMPTY( oM:oMvc:CONCEPTO )             ,;
            (MsgStop("Digite un Breve Concepto",">>>OJO<<<"),.f.),;
            (If( !aCge[3],  oM:Detalle( oDlg,oLbx,.t. )          ,;
               (If( oM:oMvc:CONCEPTO # oM:oMvc:XColumn( 8 )      ,;
                  ( oM:oMvc:Update(.t.,1), oAget[6]:oJump := oLbx), )) ), .t. ) ) } )
   REDEFINE SAY VAR oM:oMvc:CONSECUTIV  ID 18 OF oDlg UPDATE
   REDEFINE SAY VAR oM:aMov[6]  ID 22 OF oDlg PICTURE "@(9,999,999,999.99" UPDATE
   REDEFINE BITMAP  oM:aMov[9]  ID 23 ADJUST ;
      RESOURCE  If( oM:aMov[6] # 0,"OFF","ON" ) OF oDlg
   REDEFINE SAY VAR oM:aMov[29] ID 24 OF oDlg UPDATE
   REDEFINE SAY VAR oM:aMov[7]  ID 25 OF oDlg PICTURE   "9,999,999,999.99" UPDATE
   REDEFINE SAY VAR oM:aMov[8]  ID 26 OF oDlg PICTURE   "9,999,999,999.99" UPDATE
   ACTIVAGET(oAget)

   REDEFINE LISTBOX oLbx FIELDS ;
      oM:oMvd:CUENTA, oM:oMvd:INFA , ;
      oM:oMvd:INFB  , oM:oMvd:INFC , oM:oMvd:INFD, ;
      TRANSFORM( oM:oMvd:VALOR_DEB,"@Z 9,999,999,999.99" ),;
      TRANSFORM( oM:oMvd:VALOR_CRE,"@Z 9,999,999,999.99" ) ;
      ID 20 OF oDlg ;
      HEADERS "Cuenta","InfA","InfB","InfC","InfD",;
              "Debito","Credito" UPDATE
   oLbx:nClrBackHead  := oApl:nClrBackHead
   oLbx:nClrForeHead  := oApl:nClrForeHead
   oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
   oLbx:nClrBackFocus := oApl:nClrBackFocus
   oLbx:nClrForeFocus := oApl:nClrForeFocus
   oLbx:nHeaderHeight := 28
   oLbx:GoTop()
   oLbx:oFont       := Tfont():New("Ms Sans Serif",0,-10,,.f.)
   oLbx:aColSizes   := {70,70,70,70,70,100,100}
   oLbx:aHjustify   := {2,2,2,2,2,2,2}
   oLbx:aJustify    := {0,0,0,0,1,1,1}
   oLbx:ladjlastcol := oLbx:lCellStyle  := .f.
   oLbx:ladjbrowse  := .t.
   oLbx:bKeyDown := {|nKey| If(nKey == VK_ESCAPE, (oM:aMov[3] := 0, oM:oMvc:xBlank()    ,;
                                         oM:Filtrar( 0,oDlg,oLbx ), oAGet[2]:SetFocus()),;
                            If(nKey == VK_F5 .AND. aCge[3], oM:CopiaCpte( oDlg,oLbx )   ,;
                            If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, oM:Detalle( oDlg,oLbx,.t. ),;
                            If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, oM:Detalle( oDlg,oLbx,.f. ),;
                            If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, oM:BorraDeta( oDlg,oLbx ),) )))) }
   MySetBrowse( oLbx,oM:oMvd )
ACTIVATE DIALOG oDlg ;
   ON INIT ( oM:Barram( oDlg,oLbx ), oM:Filtrar() )
//CENTERED
oM:oFte:Cerrar()
oM:oPuc:Cerrar()
oM:oVar:Cerrar()
oM:oCtl:Destroy()
oM:oMvc:Destroy()
oM:oMvd:Destroy()
SETKEY( VK_F4,{||Empresa()} )
RETURN NIL

/*
  aTL[1] = 0
     [2] = 0
     [3] = Cuenta
     [4] = If( [3] == oApl:oEmp:CARTERA, "FACTURA   ", "DOCUMENTO " )
     [5] =     oMvd:VALOR_DEB + oMvd:VALOR_CRE
     [6] = If( oMvd:VALOR_CRE # 0, 1, 2 )
     [7] =     oMvd:CODIGO_NIT
 ------------
 aMov[01] = Periodo (captura)
     [02] = Fuente
     [03] = Comprobante
     [04] = "INGRESO, EGRESO, "
     [05] = "Vigente, Actualizado, Anulado" :ESTADO
     [06] = Valor Descuadre
     [07] = Valor Debito
     [08] = Valor Credito
     [09] = SetBmp( 'OFF', 'ON' )
     [10] = Nit
     [11] = Nombre Nit
     [12] = Periodo para busqueda
     [13] = oFte:CONTADOR
     [14] = 1 para el skip
     [15] = Mes y Año "ENERO DE 2.014"
     [16] = Si hay mas de un Comprobante(nRowCount)
     [17] = oMvd:CUENTA
     [18] =      INFA
     [19] =      INFB
     [20] =      INFC
     [21] =      INFD
     [22] =      CODIGO_NIT
     [23] =      VALOR_DEB
     [24] =      VALOR_CRE
     [25] =      LIBRO
     [26] =      PTAJE
     [27] = nC+16 Posicion Base
     [28] = Valor Base
     [29] = "Totales COLGAAP"
*/
//------------------------------------//
CLASS TMov FROM TNits
 DATA aMov AS ARRAY INIT { NtChr( DATE(),"1" ),1,0,"","",0,0,0,,0,"",,"",1,"",;
                           .f.,SPACE(10),"","","","",0,0,0,0,0,0,0,"Totales COLGAAP" }
 DATA lCierre       INIT .f.
 DATA nLbr          INIT 1
 DATA aCG, aCXP, aTL, oNot
 DATA oArf, oCtl, oMvc, oMvd, oFte, oNit, oPuc, oVar

 METHOD NEW( nFte ) Constructor
 METHOD BuscarMov( oDlg )
 METHOD Avanza( oDlg,oLbx,nSkip )
 METHOD Filtrar( nFiltro,oDlg,oLbx )
 METHOD Compras( cQry )
 METHOD Fechas( oDlg,oLbx )
 METHOD Detalle( oMov,oLbx,lNuevo )
 METHOD ValidarPuc( aDet,oDlg,lNew )
 METHOD ValidarDet()
 METHOD AyudaInf( oGet,cNom,lBus,oSay )
 METHOD BuscaFac( cFac,oSay )
 METHOD AnulaCpte( oDlg )
 METHOD CopiaCpte( oDlg,oLbx )
 METHOD BorraDeta( oDlg,oLbx )
 METHOD Graba( lSi,xInf )
 METHOD GrabaPago( cCta,cDoc,nPago,nMov,nDel,nIfrs )
 METHOD GrabaCXP( cCta,cDoc,nPago,nMov,nDel,nIfrs )
 METHOD Prestamo( nPago,nMov,nDel )
 METHOD Barram( oDlg,oLbx )
 METHOD ArmarLis( aChq )
 METHOD Dsctos( oLbd,nID )
 METHOD Editad( nID,oLbx,lNew )
// METHOD DosNForma( lPreview )
// METHOD DosFForma( lPreview )
// METHOD NotasCge()
// METHOD WinNForma( oRpt )
// METHOD CicloDeta( oRpt,aC )

ENDCLASS

//------------------------------------//
METHOD NEW( nFte,cFte ) CLASS TMov
If nFte == NIL
   Super:New( cFte )
Else
   Empresa( .t. )
   ::aMov[2] := nFte
   ::aMov[4] := If( nFte == 1, "INGRESO", If( nFte == 2, "EGRESO", "" ) )
   ::oCtl := oApl:Abrir( "cgecntrl","empresa, ano_mes",,,5 )
  // ::oNot := oApl:Abrir( "cgenotas","empresa, fuente",,,1 )
   ::oPuc := TPuc()  ; ::oPuc:New()
   ::oVar := TVar()  ; ::oVar:New()
EndIf
   ::oMvc := oApl:Abrir( "cgemovc" ,"empresa, ano_mes, control",.t.,,10 )
   ::oMvd := oApl:Abrir( "cgemovd" ,"empresa, ano_mes, control",.t.,,100 )
   ::oMvd:nLimit := 2000
   ::oFte := TFte()  ; ::oFte:New()
   ::oNit := TNits() ; ::oNit:New()
If oApl:oDb:ExistTable( "ctasxpc" )
   cFte  := "SELECT cuenta FROM cgeplan WHERE empresa = " + LTRIM(STR(oApl:nPuc))+;
            " AND pagos_terc = '1'" +;
            " AND estado    <> 'R'" +;
            " AND nivel = 4 ORDER BY cuenta"
   ::aCXP := Buscar( cFte,"CM",,9 )
   If VALTYPE( ::aCXP ) == "C"
      ::aCXP := { "NADA" }
   EndIf
Else
   ::aCXP := { "NADA" }
EndIf
RETURN NIL

//------------------------------------//
METHOD BuscarMov( oDlg ) CLASS TMov
   LOCAL lSi
 ::aMov[1] := ::aMov[12]
If !(lSi := ::oMvc:Seek( {"empresa",oApl:nEmpresa,"ano_mes",::aMov[1],;
                          "fuente" ,::aMov[2], "comprobant",::aMov[3]} ))
   If ::oFte:oDb:CTRL_CONSE
      If ::oMvc:Seek( {"empresa",oApl:nEmpresa,"fuente",::aMov[2],;
                       "comprobant",::aMov[3]} )
         If MsgNoYes("Desea Verlo","Esta en un periodo diferente")
            ::aMov[1] := ::oMvc:ANO_MES
            lSi := .t.
         Else
            ::oMvc:Seek( {"empresa",oApl:nEmpresa,"ano_mes",::aMov[1],;
                          "fuente" ,::aMov[2], "comprobant",::aMov[3]} )
         EndIf
      EndIf
   EndIf
EndIf
If !lSi
   ::oMvc:FECHA := NtChr( ::aMov[1],"F" )
EndIf
 ::oNit:oDb:Seek( {"codigo_nit",::oMvc:CODIGONIT} )
 ::aMov[05] := {"Vigente","Actualizado","Anulado"}[::oMvc:ESTADO+1]
 ::aMov[10] := ::oNit:oDb:CODIGO
 ::aMov[11] := ::oNit:oDb:NOMBRE
 ::aMov[14] := 1
 ::aMov[16] := If( ::oMvc:nRowCount > 1, .t., .f. )
 oApl:cPer := ::aMov[01]
If oDlg # NIL
   Botones( oDlg,{5,6},::aMov[16] )
EndIf
RETURN lSi

//------------------------------------//
METHOD Avanza( oDlg,oLbx,nSkip,lSkip ) CLASS TMov

If oDlg == NIL
   ::aTL := { 0,0,oLbx,If( oLbx == oApl:oEmp:CARTERA, "FACTURA   ", "DOCUMENTO " ),;
              ::oMvd:VALOR_DEB + ::oMvd:VALOR_CRE,;
              If( ::oMvd:VALOR_CRE # 0, 1, 2 ) , ::oMvd:CODIGO_NIT }
   ::aTL[4]:= If( InfAc( oLbx,@nSkip,::aTL[4] ), ::oMvd:axBuffer[nSkip+5], "" )
ElseIf ::aMov[16]
   lSkip := .f.
   If (nSkip ==  1 .AND. ::aMov[14] < ::oMvc:nRowCount) .OR.;
      (nSkip == -1 .AND. ::aMov[14] > 1)
      lSkip := .t.
   EndIf
   If lSkip
      ::oMvc:Skip(nSkip):Read()
      ::oMvc:xLoad()
      ::oNit:oDb:Seek( {"codigo_nit",::oMvc:CODIGONIT} )
      ::aMov[01] := ::oMvc:ANO_MES
      ::aMov[05] := {"Vigente","Actualizado","Anulado"}[::oMvc:ESTADO+1]
      ::aMov[10] := ::oNit:oDb:CODIGO
      ::aMov[11] := ::oNit:oDb:NOMBRE
      ::aMov[14] += nSkip
      ::Filtrar( 0,oDlg,oLbx )
      oLbx:Setfocus()
      If ::aMov[01] # ::aMov[12]
         ::lCierre := Buscar( {"empresa",oApl:nEmpresa,"ano_mes",::aMov[01]},;
                              "cgecntrl","cierre",8,,3 )
      Else
         ::lCierre := ::oCtl:CIERRE
      EndIf
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Filtrar( nFiltro,oDlg,oLbx ) CLASS TMov
   DEFAULT nFiltro := 0
If nFiltro == 2
   If !EMPTY(oApl:oEmp:NIIF) .AND. ::aMov[1] >= oApl:oEmp:NIIF
      ::nLbr := { 2,1 }[::nLbr]
      ::aMov[29] :=  "Totales "  + { "COLGAAP","IFRS" }[::nLbr]
   EndIf
EndIf
If nFiltro <> 1
   ::oMvd:Seek( {"empresa",oApl:nEmpresa,"ano_mes",::aMov[1],;
                 "control",::oMvc:CONTROL} )
              // "control",::oMvc:CONTROL,"libro",::nLbr},"cuenta" )
EndIf
 ::aMov[7] := ::aMov[8] := 0
 ::oMvd:dbEval( {|o| ::aMov[7] += o:VALOR_DEB,;
                     ::aMov[8] += o:VALOR_CRE } )
 ::aMov[6] := ::aMov[7] - ::aMov[8]
If !EMPTY(::aMov[15])
   If( ::aMov[6] # 0, ::aMov[9]:SetBmp("OFF"), ::aMov[9]:SetBmp("ON") )
EndIf
If oDlg # NIL
   oLbx:Refresh()
   oDlg:Update()
EndIf
RETURN NIL

//------------------------------------//
METHOD Compras( cQry ) CLASS TMov
   LOCAL hRes, lOK := .t.
//If cQry == NIL
   If (lOK := ::oFte:oDb:Seek( {"fuente",::aMov[2]} ))
      ::aMov[4] := If( ::aMov[2] == 1, "ingreso", If( ::aMov[2] == 2, "egreso", "" ) )
      If !EMPTY( ::aMov[4] )
         ::aMov[3] := SgteNumero( ::aMov[4],oApl:nEmpresa,.f. )
      ElseIf !EMPTY( ::aMov[13] := ::oFte:oDb:CONTADOR )
         ::aMov[3] := SgteCntrl( ::aMov[13],::aMov[1],.f. )
      EndIf
   EndIf
/*Else
  cQry := "SELECT comprobant FROM cgemovc "             +;
          "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
           " AND ano_mes = '"+ ::aMov[01]               +;
          "' AND control = XX"
   WHILE lOK
      ::oMvc:CONTROL := SgteCntrl( "control",::aMov[1],.t. )
      hRes := If( MSQuery( oApl:oMySql:hConnect,STRTRAN(cQry,"XX",LTRIM(STR(::oMvc:CONTROL))) ),;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      lOK  := If( MSNumRows( hRes ) > 0, .t., .f. )
      MSFreeResult( hRes )
   EndDo
EndIf*/
RETURN lOK

//------------------------------------//
METHOD Fechas( oDlg,oLbx ) CLASS TMov
   LOCAL aF, cAno, lOk := .t.
If oDlg == NIL
   ::oCtl:Seek( {"empresa",oApl:nEmpresa,"ano_mes",::aMov[1]} )
   ::aMov[12] := oApl:cPer := ::aMov[1]
   ::aMov[15] := NtChr( NtChr( ::aMov[1],"F" ),"6" )
   ::lCierre  := ::oCtl:CIERRE
Else
   cAno := If( RIGHT( ::aMov[1],2 ) == "13", STUFF( ::aMov[1],6,1,"2" ), ::aMov[1] )
   If cAno # NtChr( ::oMvc:FECHA,"1" )
      If ::oMvc:lOK
         aF := { ::oMvc:XColumn( 4 ),::oMvc:FECHA,0,0 }
         If Login( "QUIERE HACER EL CAMBIO DE PERIODO" )
            ::oMvc:ANO_MES := ::aMov[01] := NtChr( ::oMvc:FECHA,"1" )
            //::Compras( "C" )
            ::oMvc:CONTROL := SgteCntrl( "control",::aMov[01],.t. )
            ::oMvd:dbEval( {|o| ::Avanza( ,o:CUENTA )                   ,;
                                oApl:cPer := o:ANO_MES                  ,;
                                ::oMvc:FECHA := aF[1]                   ,;
                                ::GrabaPago( o:CUENTA,::aTL[4],-::aTL[5],::aTL[6],1,o:LIBRO ),;
                                Acumular( ::oMvc:ESTADO,o,5,5,.f.,.f. ) ,;
                                o:ANO_MES := oApl:cPer := ::aMov[01]    ,;
                                o:CONTROL := ::oMvc:CONTROL             ,;
                                ::oMvc:FECHA := aF[2]                   ,;
                                ::GrabaPago( o:CUENTA,::aTL[4], ::aTL[5],::aTL[6],2,o:LIBRO ),;
                                Acumular( ::oMvc:ESTADO,o,2,2,.f.,.f. ) } )
            ::oMvc:Update(.t.,1)
            ::Filtrar( 0,oDlg,oLbx )
            oLbx:Setfocus()
         Else
            ::oMvc:FECHA := aF[1]
         EndIf
      Else
         MsgStop( "Esta Fecha no Corresponde al Periodo" )
         lOk := .f.
      EndIf
   ElseIf ::oMvc:lOK
          ::oMvc:Update(.t.,1)
   EndIf
EndIf
RETURN lOk

//------------------------------------//
METHOD Detalle( oMov,oLbx,lNuevo ) CLASS TMov
   LOCAL aDet, bGrabar, nG, oD, oDlg, oGet
If ::lCierre
   MsgStop( "YA ESTA CERRADO",If( RIGHT( ::aMov[1],2 ) == "13",;
            "AÑO "+LEFT(::aMov[1],4), "Periodo "+::aMov[1] ) )
   RETURN NIL
ElseIf ::oMvc:ESTADO == 2
   MsgStop( ::aMov[5], "Este Comprobante esta" )
   RETURN NIL
ElseIf ::aMov[2] == 0 .OR. ::aMov[3] == 0
   RETURN NIL
EndIf
oGet := ARRAY(14)
oD   := Self
If lNuevo .OR. ::oMvd:ROW_ID == 0
   lNuevo  := .t.
   bGrabar := {|| ::Graba( .t. )                 ,;
                  PListbox( oLbx, ::oMvd )       ,;
                  oMov:Update() , ::oMvd:xBlanK(),;
                  AEVAL( ::oMvd:axBuffer, { |x,p| ::aMov[p+12] := x },6 ),;
                  ::aMov[27] := ::aMov[28] := 0  ,;
                  oDlg:Update() , oDlg:SetFocus() }
   oLbx:GoBottom() ; ::oMvd:xBlank()
// AEVAL( ::aMov, {|x,p| ::aMov[p] := {"","",0}[AT(VALTYPE(x),"CDN")] },18 )
Else
   ::oNit:oDb:Seek( {"codigo_nit",::oMvd:CODIGO_NIT} )
   bGrabar := {|| ::Graba( .f. ), oMov:Update(), oDlg:End() }
EndIf
aDet := { "","","","","","","",;
          If( !EMPTY(oApl:oEmp:NIIF) .AND. ::aMov[1] >= oApl:oEmp:NIIF .AND. lNuevo, .t., .f. ) }
   AEVAL( ::oMvd:axBuffer, { |x,p| ::aMov[p+12] := x },5 )
   ::Avanza( ,::aMov[17] )
   ::ValidarPuc( @aDet,,lNuevo )
DEFINE DIALOG oDlg TITLE If(lNuevo,"Añadir","Modificar") + " Detalle" ;
   FROM 0, 0 TO 14,60
   @ 02, 00 SAY "Cuenta"   OF oDlg RIGHT PIXEL SIZE 40,10
   @ 02, 42 BTNGET oGet[1] VAR oD:aMov[17] OF oDlg PICTURE "9999999999";
      VALID oD:ValidarPuc( @aDet,oDlg,lNuevo );
      SIZE 48,10 PIXEL  RESOURCE "BUSCAR"     ;
      ACTION EVAL({|| If( oD:oPuc:Mostrar()                ,;
                        ( oD:aMov[17] := oD:oPuc:oDb:CUENTA,;
                          oGet[1]:Refresh() ) ,) })
   @ 02, 92 SAY     aDet[1] OF oDlg BORDER PIXEL SIZE 136,10 UPDATE
   @ 14, 00 SAY "Libro" OF oDlg RIGHT PIXEL SIZE 40,10
   @ 14, 42 COMBOBOX oGet[14] VAR ::aMov[25] ITEMS { "COLGAAP","IFRS" };
      SIZE 48,90 OF oDlg PIXEL;
      WHEN aDet[8]
   @ 26, 00 SAY     aDet[2] OF oDlg  RIGHT PIXEL SIZE 40,10  UPDATE
   @ 26, 42 BTNGET oGet[2] VAR ::aMov[18] OF oDlg PICTURE "9999999999";
      VALID  oD:AyudaInf( oGet[2],aDet[2],.t.,oGet[3] );
      SIZE 48,10 PIXEL UPDATE  RESOURCE "BUSCAR"       ;
      ACTION oD:AyudaInf( oGet[2],aDet[2],.f. )
   @ 26, 92 SAY oGet[3] VAR aDet[6] OF oDlg BORDER PIXEL SIZE 136,10 UPDATE
   @ 38, 00 SAY     aDet[3] OF oDlg  RIGHT PIXEL SIZE 40,10  UPDATE
   @ 38, 42 BTNGET oGet[4] VAR ::aMov[19] OF oDlg PICTURE "9999999999";
      VALID  oD:AyudaInf( oGet[4],aDet[3],.t.,oGet[5] );
      SIZE 48,10 PIXEL UPDATE  RESOURCE "BUSCAR"       ;
      ACTION oD:AyudaInf( oGet[4],aDet[3],.f. )        ;
      WHEN !EMPTY( aDet[3] )
   @ 38, 92 SAY oGet[5] VAR aDet[7] OF oDlg BORDER PIXEL SIZE 136,10 UPDATE
   @ 50, 00 SAY     aDet[4] OF oDlg  RIGHT PIXEL SIZE 40,10  UPDATE
   @ 50, 42 GET oGet[6] VAR ::aMov[20] OF oDlg         ;
      VALID  oD:AyudaInf( oGet[6],aDet[4],.t.,oGet[5] );
      WHEN !EMPTY( aDet[4] )                           ;
      SIZE 40,10 PIXEL UPDATE
   @ 62, 00 SAY     aDet[5] OF oDlg  RIGHT PIXEL SIZE 40,10  UPDATE
   @ 62, 42 GET oGet[7] VAR ::aMov[21] OF oDlg        ;
      WHEN !EMPTY( aDet[5] )                          ;
      SIZE 40,10 PIXEL UPDATE
   @ 74, 00 SAY "Debito"   OF oDlg RIGHT PIXEL SIZE 40,10
   @ 74, 42 GET oGet[8] VAR ::aMov[23] OF oDlg PICTURE "@E 9,999,999,999.99";
      SIZE 48,10 PIXEL UPDATE
   @ 86, 00 SAY "Credito"  OF oDlg RIGHT PIXEL SIZE 40,10
   @ 86, 42 GET oGet[9] VAR ::aMov[24] OF oDlg PICTURE "@E 9,999,999,999.99";
      SIZE 48,10 PIXEL UPDATE
   @ 74, 92 SAY "Base Gravada" OF oDlg RIGHT PIXEL SIZE 40,10
   @ 74,134 GET oGet[10] VAR ::aMov[28] OF oDlg PICTURE "@E 9,999,999,999.99";
      VALID ::aMov[28] >= 0 ;
      WHEN  ::aMov[27] >  0 ;
      SIZE 48,10 PIXEL UPDATE
   @ 74,184 SAY "%"            OF oDlg RIGHT PIXEL SIZE 10,10
   @ 74,196 GET oGet[11] VAR ::aMov[26] OF oDlg PICTURE "@E 999.99";
      VALID ::aMov[26] >= 0 ;
      WHEN  ::aMov[27] >  0 ;
      SIZE 30,10 PIXEL UPDATE

   @ 90,134 BUTTON oGet[12] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      (If( (nG := ::ValidarDet()) # 0, oGet[nG]:SetFocus(), EVAL(bGrabar) )) PIXEL
   @ 90,184 BUTTON oGet[13] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(250,250)

oLbx:Refresh()
oLbx:SetFocus()
RETURN NIL

//------------------------------------//
METHOD ValidarPuc( aDet,oDlg,lNew ) CLASS TMov
   LOCAL cCod, nC, lSi := .t.
If ::oPuc:oDb:Seek( {"empresa",oApl:nPuc,"cuenta",::aMov[17]} )
   If ::oPuc:oDb:ESTADO == "R" .OR. ::oPuc:oDb:NIVEL < 4
      MsgStop( If( ::oPuc:oDb:ESTADO == "R", "Esta Anulada",;
                   "no es Auxiliar" ),"Esta Cuenta" )
      lSi := .f.
   Else
      aDet[1] := ::oPuc:oDb:NOMBRE
      aDet[2] := TRIM(::oPuc:oDb:INFA) ; aDet[3] := TRIM(::oPuc:oDb:INFB)
      aDet[4] := TRIM(::oPuc:oDb:INFC) ; aDet[5] := TRIM(::oPuc:oDb:INFD)
      If lNew
         ::aMov[18] := ::aMov[19] := SPACE(10)
         ::aMov[20] := ::aMov[21] := SPACE(10)
         ::aMov[25] := ::nLbr
      EndIf
      ::aMov[27] := 0
      FOR nC := 2 TO 5
         do case
         Case aDet[nC] == "BASE"
            ::aMov[27] := nC + 16
            ::aMov[28] := VAL( ::aMov[nC+16] )
              aDet[nC] := ::aMov[nC+16] := ""
         Case aDet[nC] == "CTA-CTE" .OR. ;
              aDet[nC] == "COD-VAR" .AND. lNew
            cCod := If( aDet[nC] == "COD-VAR", ::aMov[17],;
                        SUBSTR(::aMov[17],7,2) )
            ::oVar:oDb:Seek( {"empresa",oApl:nEmpresa,"cuenta",cCod} )
            ::aMov[nC+16] := ::oVar:oDb:CODIGO
         Case aDet[nC] == "NIT" .AND. lNew
            ::aMov[nC+16] := PADR( LTRIM( STR(::aMov[10]) ),10 )
         Case aDet[nC] == "FECHA"
            cCod := ::aMov[nC+16]
            ::aMov[nC+16] := If( EMPTY(cCod), ::oMvc:FECHA+30,;
                             If( AT(cCod,".") > 0, CTOD(cCod), cCod ) )
         EndCase
      NEXT nC
      If oDlg # NIL
         oDlg:Update()
      EndIf
   EndIf
ElseIf oDlg # NIL
   MsgStop( "Esta Cuenta no Existe .." )
   lSi := .f.
EndIf
RETURN lSi

//------------------------------------//
METHOD ValidarDet() CLASS TMov
   LOCAL cMsg := "Imposible grabar este Registro"
If EMPTY(::aMov[17])
   MsgStop( "Falta Cuenta",cMsg )
   RETURN 1
EndIf
If EMPTY(::aMov[18])
   MsgStop( "Falta "+::oPuc:oDb:INFA,cMsg )
   RETURN 2
EndIf
If ::aMov[23] < 0 .OR.  ::aMov[24] < 0  .OR. ;
  (::aMov[23] > 0 .AND. ::aMov[24] > 0) .OR. ;
   ::aMov[23] == ::aMov[24]
   MsgStop( "Valores Errados",cMsg )
   RETURN 8
EndIf
If ::aTL[1] == 1 .AND.;
   (::aMov[23] > ::aTL[2] .OR. ::aMov[24] > ::aTL[2])
   cMsg := If( ::aMov[24] > 0, "Pago", "N.Debito" ) + " Mayor que el Saldo"
   If !MsgNoYes( "Desea Continuar",cMsg )
      RETURN 8
   EndIf
EndIf
If ::aMov[27] > 0
   ::aMov[ ::aMov[27] ] := If( EMPTY(::aMov[28]), "", STR(::aMov[28],10,0) )
EndIf
   ::oMvd:CUENTA     := ::aMov[17]
   ::oMvd:INFA       := ::aMov[18]
   ::oMvd:INFB       := ::aMov[19]
   ::oMvd:INFC       := ::aMov[20]
   ::oMvd:INFD       := ::aMov[21]
   ::oMvd:CODIGO_NIT := ::aMov[22]
   ::oMvd:VALOR_DEB  := ::aMov[23]
   ::oMvd:VALOR_CRE  := ::aMov[24]
   ::oMvd:LIBRO      := ::aMov[25]
   ::oMvd:PTAJE      := ::aMov[26]
 //AEVAL( ::aMov, {|x,p| ::aMov[p] := {"","",0}[AT(VALTYPE(x),"CDN")] },18 )
RETURN 0

//------------------------------------//
METHOD AyudaInf( oGet,cNom,lBus,oSay ) CLASS TMov
   LOCAL cVar := oGet:Varget(), lSi := .f.
do CASE
CASE cNom == "NIT"
   ::oNit:xVar := VAL( cVar )
   If lBus
      If !(lSi := ::oNit:Buscar( ::oNit:xVar,,.t. ))
         MsgStop( cVar,"NIT No Existe" )
         If ::oNit:Mostrar( ,,::oNit:xVar )
            cVar := STR(::oNit:oDb:CODIGO) ; lSi := .t.
         EndIf
      EndIf
      ::aMov[10] := ::oNit:oDb:CODIGO
      ::aMov[22] := ::oNit:oDb:CODIGO_NIT
      oSay:Settext( ::oNit:oDb:NOMBRE )
   ElseIf ::oNit:Mostrar( ,,::oNit:xVar )
      cVar := STR(::oNit:oDb:CODIGO)
   EndIf
CASE cNom == "CTA-CTE" .OR.;
     cNom == "COD-VAR"
   If cNom = "CTA-CTE"
      ::oVar:aCta := { "B", SUBSTR(::aMov[17],7,2), ::oPuc:oDb:NOMBRE }
   Else
      ::oVar:aCta := { "V", ::aMov[17], ::oPuc:oDb:NOMBRE }
   EndIf
   If lBus
      cVar := PADR( ALLTRIM( cVar ),10 )
      If !(lSi := ::oVar:oDb:Seek( {"empresa",oApl:nEmpresa,"cuenta",;
                                    ::oVar:aCta[2],"codigo",cVar} ))
         MsgStop( cVar,cNom+" No Existe" )
         ::oVar:xVar  := cVar
         If ::oVar:Mostrar(,,::oVar:aCta[2])
            cVar := ::oVar:oDb:CODIGO ; lSi := .t.
         EndIf
      EndIf
      oSay:Settext( ::oVar:oDb:NOMBRE )
   Else
      If ::oVar:Mostrar(,,::oVar:aCta[2])
         cVar := ::oVar:oDb:CODIGO
      EndIf
   EndIf
CASE cNom == "FACTURA" .AND. ::aMov[17] == oApl:oEmp:CARTERA .AND.;
   ::oFte:oDb:CARTERA  .AND. !EMPTY( ::aMov[20] )
   lSi  := ::BuscaFac( PADL( ALLTRIM( cVar ),10 ),oSay )
OtherWise
   lSi := .t.
EndCase
If VALTYPE( cVar ) == "C"
   oGet:cText( PADR( ALLTRIM(cVar),10 ) )
   oGet:Refresh()
EndIf
RETURN lSi

//------------------------------------//
METHOD BuscaFac( cFac,oSay ) CLASS TMov
   LOCAL lBuscar, nFac
 ::aTL[1] := 1
oApl:Tipo := UPPER(RIGHT( cFac,1 ))
If ISALPHA( oApl:Tipo )
   cFac := " " + LEFT( cFac,9 )
Else
   oApl:Tipo := "U"
EndIf
nFac := INT( VAL(cFac) )
lBuscar := oApl:oFac:Seek( {"empresa",oApl:nEmpresa,"numfac",nFac,"tipo",oApl:Tipo} )
If lBuscar .AND. oApl:oFac:CODIGO_NIT == ::aMov[22] .AND. oApl:oFac:INDICADOR # "A"
   oApl:lFam := SaldoFac( nFac,,::aMov[25] )
   oSay:Settext( oApl:oFac:CLIENTE + TRANSFORM( oApl:nSaldo,"99,999,999.99" ) )
      ::aTL[2]   := ABS(oApl:nSaldo)
   If ::aMov[2] == 5 .OR. (::aMov[23] == 0 .AND. oApl:nSaldo < 0)
      ::aMov[23] := If( EMPTY(::aMov[23]), ::aTL[2], ::aMov[23] )
   Else
      ::aMov[24] := If( EMPTY(::aMov[24]), ::aTL[2], ::aMov[24] )
   EndIf
      ::aTL[2]   += If( ::aTL[4] == cFac, ::aTL[5], 0 )
Else
   cFac := If( oApl:oFac:CODIGO_NIT # ::aMov[22], "no es de este Cliente",;
           If( oApl:oFac:INDICADOR == "A", "esta Anulada", "NO EXISTE !!" ) )
   MsgStop( cFac,"FACTURA"+STR(nFac) )
   lBuscar := .f.
EndIf
RETURN lBuscar

//------------------------------------//
METHOD AnulaCpte( oDlg ) CLASS TMov
   LOCAL cNom, nP, nVal
If ::lCierre
   MsgStop( "YA ESTA CERRADO","Periodo "+::aMov[1] )
   RETURN NIL
ElseIf ::oMvc:CONTROL > 0 .AND. ::oMvc:ESTADO # 0
   cNom := If( ::oMvc:ESTADO == 2, "ACTIVA", "ANULA" )
   If MsgNoYes( "Este Comprobante",cNom )
      ::oMvc:ESTADO := If( ::oMvc:ESTADO == 2, 1, 2 )
      ::oMvc:Update(.t.,1)
      ::aMov[5] := {"Vigente","Actualizado","Anulado"}[::oMvc:ESTADO+1]
      oDlg:Update()
      ::oMvd:dbEval( {|o| ::Avanza( ,o:CUENTA )                       ,;
                          If( ::oMvc:ESTADO == 1                      ,;
                            ( ::GrabaPago( o:CUENTA,::aTL[4], ::aTL[5],::aTL[6],2,o:LIBRO ),;
                              Acumular( 1, o, 4, 4, .f., .f. ) )      ,;
                            ( ::GrabaPago( o:CUENTA,::aTL[4],-::aTL[5],::aTL[6],1,o:LIBRO ),;
                              Acumular( 2, o, 5, 5, .f., .f. ) ) ) } )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD CopiaCpte( oDlg,oLbx ) CLASS TMov
   LOCAL aMvc, aLS, cQry, nK, nL, oDlc, oGet
If ::oMvc:ESTADO == 2
   MsgStop( "No lo puedo Copiar","Comprobante ANULADO" )
   RETURN NIL
EndIf
 aLS  := { SPACE(10),.f.,.f.,.t. }
 aMvc := ACLONE( ::oMvc:axBuffer )
 oGet := ARRAY(7)
 ::oMvc:lOK := .f.
DEFINE DIALOG oDlc TITLE "Copiar Comprobante" FROM 0, 0 TO 11,40
   @ 02, 00 SAY "Periodo [AAAAMM]" OF oDlc RIGHT PIXEL SIZE 50,10
   @ 02, 52 GET oGet[1] VAR ::aMov[1] OF oDlc PICTURE "999999";
      VALID If( NtChr( ::aMov[1],"P" ), (aLS[4] := .f., ::Fechas()), .f. );
      WHEN aLS[4]  SIZE 28,10 PIXEL
    oGet[1]:bGotFocus := { || ::Compras(), oGet[2]:Refresh() }
   @ 14, 00 SAY "Nro. Comprobante" OF oDlc RIGHT PIXEL SIZE 50,10
   @ 14, 52 GET oGet[2] VAR ::aMov[3] OF oDlc PICTURE "999999"        ;
      VALID If( Buscar( {"empresa",oApl:nEmpresa,"ano_mes",::aMov[1] ,;
                         "fuente" ,::aMov[2], "comprobant",::aMov[3]},;
                         "cgemovc","1",8,,4 ) == 1                   ,;
              ( MsgStop("Este Comprobante ya Existe" ), .f. )        ,;
              ( ::oMvc:FECHA := NtChr( ::aMov[1],"F" ), aLS[3] := .t., .t. ) );
      SIZE 28,10 PIXEL
   @ 26, 00 SAY "Fecha [DD.MM.AA]"  OF oDlc RIGHT PIXEL SIZE 50,10
   @ 26, 52 GET oGet[3] VAR ::oMvc:FECHA OF oDlc SIZE 40,10 PIXEL ;
      VALID ::Fechas( oDlg )
   @ 38, 00 SAY "Concepto Cpbte"    OF oDlc RIGHT PIXEL SIZE 50,10
   @ 38, 52 GET oGet[4] VAR aMvc[8] OF oDlc SIZE 100,10 PIXEL
   @ 50, 00 SAY "Nro. Factura"      OF oDlc RIGHT PIXEL SIZE 50,10
   @ 50, 52 GET oGet[5] VAR aLS[1]  OF oDlc SIZE 40,10 PIXEL
   @ 64, 20 BUTTON oGet[6] PROMPT "Aceptar"  SIZE 44,12 OF oDlc ACTION;
      ( aLS[2] := .t., oDlc:End() ) PIXEL
   @ 64, 70 BUTTON oGet[7] PROMPT "Cancelar" SIZE 44,12 OF oDlc CANCEL;
      ACTION oDlc:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlc CENTERED

If aLS[2] .AND. aLS[3]
   cQry := "SELECT * FROM cgemovd "                 +;
           "WHERE empresa = " + LTRIM(STR(aMvc[2])) +;
            " AND ano_mes = '"+           aMvc[3]   +;
           "' AND control = " + LTRIM(STR(aMvc[7]))
    aLS[1] := ALLTRIM( aLS[1] )
   aMvc[4] := ::oMvc:FECHA
   aMvc[6] := ::aMov[3]
   aMvc[7] := aMvc[12] := 0
   ::oMvc:Seek( {"empresa",oApl:nEmpresa,"ano_mes",::aMov[1],;
                 "fuente" ,::aMov[2], "comprobant",::aMov[3]} )
   ::aMov[16]:= .f.
   ::aTL := { 0,0,"","",0,1,0 }
   AEVAL( aMvc, { |x,p| ::oMvc:axBuffer[p] := x },4 )
   oGet := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( oGet )
   While nL > 0
      ::oMvd:xBlank()
      aMvc := MyReadRow( oGet )
      AEVAL( aMvc, { | xV,nP | ::oMvd:axBuffer[nP] := MyClReadCol( oGet,nP ) },5 )
      If !EMPTY(aLS[1])
         cQry := Buscar( { "empresa",oApl:nPuc,"cuenta",aMvc[5] },"cgeplan",;
                           "infa, infb, infc, infd",8 )
         FOR nK := 1 TO 4
            If cQry[nK] == "DOCUMENTO " .OR.;
               cQry[nK] == "FACTURA   "
               ::oMvd:axBuffer[nK+5] := aLS[1]
            EndIf
         NEXT nK
      EndIf
      ::Graba( .t.,1 )
      nL --
   EndDo
   MSFreeResult( oGet )
   ::Filtrar( 0,oDlg,oLbx )
Else
   ::aMov[1]    := aMvc[3]
   ::oMvc:FECHA := aMvc[4]
   ::oMvc:lOK   := ::Fechas()
EndIf
RETURN NIL

//------------------------------------//
METHOD BorraDeta( oDlg,oLbx ) CLASS TMov
   LOCAL cQry
If ::lCierre
   MsgStop( "YA ESTA CERRADO","Periodo "+::aMov[1] )
   RETURN NIL
ElseIf ::oMvc:ESTADO # 2
   If MsgYesNo("Desea Eliminar este Registro","Borrar Detalle")
      ::Avanza( ,::oMvd:CUENTA )
      ::GrabaPago( ::oMvd:CUENTA,::aTL[4],-::aTL[5],::aTL[6],1,::oMvd:LIBRO )
      ::oMvd:EMPRESA := -9
      Acumular( ::oMvc:ESTADO,::oMvd,3,3,.f.,.f. )
/*    cQry := "UPDATE cgemovd SET empresa = -9 " +;
              "WHERE row_id = " + LTRIM(STR(::oMvd:ROW_ID))
      MSQuery( oApl:oMySql:hConnect,cQry )*/
      ::oMvc:CONSECUTIV --
      ::oMvc:Update(.t.,1)
      ::Filtrar( 0,oDlg,oLbx )
      oLbx:Setfocus()
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Graba( lSi,xInf ) CLASS TMov
   LOCAL nGraba, aInf, nP
//   LOCAL lGraba := ::oMvc:lOK, aInf, nP
//If !lGraba
If (nGraba := If( ::oMvc:lOK, 1, 0 )) == 0
   If !::oCtl:lOK
      ::oCtl:xBlank()
      ::oCtl:lOK     := .t.
      ::oCtl:EMPRESA := oApl:nEmpresa
      ::oCtl:ANO_MES := ::aMov[1]
      ::oCtl:Append(.t.)
   EndIf
   If !EMPTY( ::aMov[4] )
      nP := SgteNumero( ::aMov[4],oApl:nEmpresa,.t. )
   ElseIf !EMPTY( ::aMov[13] )
      nP := SgteCntrl( ::aMov[13],::aMov[1],.t. )
   EndIf
   If ::aMov[10] # 0 .AND. ::oMvc:CODIGONIT == 0
      ::oNit:oDb:Seek( {"codigo",::aMov[10]} )
      ::oMvc:CODIGONIT := ::oNit:oDb:CODIGO_NIT
   EndIf
   ::oMvc:EMPRESA    := oApl:nEmpresa
   ::oMvc:ANO_MES    := ::aMov[1]
   ::oMvc:FUENTE     := ::aMov[2]
   ::oMvc:COMPROBANT := ::aMov[3]
   ::oMvc:CONTROL    := SgteCntrl( "control",::aMov[1],.t. )
   ::oMvc:ESTADO     := 1 ; ::aMov[5] := "Actualizado"
   ::oMvc:lOK        := .t.
   ::oMvc:Append(.t.)
EndIf
If xInf == NIL
   ::oMvd:CODIGO_NIT := 0
   FOR nP := 6 TO 9
      aInf := TRIM(::oPuc:oDb:axBuffer[nP])
      If aInf == "NIT"
         ::oMvd:CODIGO_NIT := ::oNit:oDb:CODIGO_NIT
      ElseIf aInf == "FECHA"
         aInf := ::oMvd:FldLoad( nP )
         ::oMvd:FldSave( nP,If( EMPTY(aInf), "",;
                            If( VALTYPE(aInf) == "D", DTOC(aInf), aInf ) ) )
      EndIf
   NEXT nP
EndIf
 aInf     := ACLONE( ::aTL )
 ::Avanza( ,::oMvd:CUENTA )
 ::aTL[7] := aInf[7]
If lSi
   ::oMvd:EMPRESA := ::oMvc:EMPRESA
   ::oMvd:ANO_MES := ::oMvc:ANO_MES
   ::oMvd:CONTROL := ::oMvc:CONTROL
   ::oMvd:LIBRO   := ::nLbr
   //::oMvd:Append(.t.)
   Acumular( ::oMvc:ESTADO,::oMvd,2,2,.t.,.t. )
   ::oMvc:CONSECUTIV ++
   ::oMvc:Update(.t.,1)
   ::GrabaPago( ::oMvd:CUENTA,::aTL[4],::aTL[5],::aTL[6],2,::oMvd:LIBRO )
Else
   If aInf[3] # ::aTL[3] .OR. aInf[4] # ::aTL[4] .OR. aInf[7] # ::aTL[7]
      ::GrabaPago( aInf[3],aInf[4],-aInf[5],aInf[6],0,::oMvd:LIBRO )
      aInf[5] := 0
   EndIf
   //::oMvd:Update(.t.,1)
   Acumular( ::oMvc:ESTADO,::oMvd,1,2,.f.,.t. )
   ::GrabaPago( ::oMvd:CUENTA,::aTL[4],::aTL[5]-aInf[5],::aTL[6],3,::oMvd:LIBRO )
EndIf
 ::Filtrar( nGraba )
RETURN NIL
/*
//------------------------------------//
METHOD GrabaInf( aCta,aInf ) CLASS TMov
   LOCAL aInf, cSql, hRes, nE, nK
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
            aCta[nE,nK+1] := DTOC(::oArc:FECINGRE+30)
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
    //::oMvd:LIBRO     := aCta[nE,11]
      Acumular( ::oMvc:ESTADO,::oMvd,2,2,!::oMvd:lOK,.f. )
      ::Avanza( ,aCta[nE,1] )
      ::GrabaPago( ::oMvd:CUENTA,::aTL[4],::aTL[5],::aTL[6],2 )
      ::oMvc:CONSECUTIV ++
   EndIf
NEXT nE
RETURN NIL
*/
//nDel 0y1=Del, 2=Cambio ó Nuevo------//
METHOD GrabaPago( cCta,cDoc,nPago,nMov,nDel,nIfrs ) CLASS TMov
   LOCAL aCan, cTipo
   DEFAULT nDel := 2
If oApl:oEmp:TACTUCON
   oApl:oWnd:SetMsg( "Trabajan los Disparadores" )
   RETURN NIL
ElseIf Rango( cCta,::aCXP )  //::oPuc:oDb:PAGOS_TERC
  ::GrabaCXP( cCta,cDoc,nPago,nMov,nDel,nIfrs )
ElseIf oApl:oEmp:NOMINA .AND. cCta == "13652501  " .AND. nPago # 0
  ::Prestamo( nPago,nMov,nDel )
ElseIf ::oFte:oDb:CARTERA .AND. cCta == oApl:oEmp:CARTERA .AND. nPago # 0
   cDoc  := PADL( ALLTRIM( cDoc ),10 )
   cTipo := oApl:Tipo
   oApl:Tipo := UPPER(RIGHT( cDoc,1 ))
   If ISALPHA( oApl:Tipo )
      cDoc := LEFT( cDoc,9 )
   Else
      oApl:Tipo := LEFT(oApl:cTF,1)
   EndIf
//::aMov[2] == 1_INGRESO, 5_N.D. 6_N.C.
   If !EMPTY( cDoc ).AND. oApl:Tipo $ oApl:oEmp:TIPOFAC
      aCan := { "P",CTOD(""),LOWER(oApl:oFac:cName),INT( VAL(cDoc) ) }
      If aCan[3] == "cadfactc" .AND. nIfrs == 1
         oApl:oPag:Seek( {"empresa",oApl:nEmpresa,"numfac",aCan[4],"tipo",oApl:Tipo,;
                          "fecpag" ,::oMvc:FECHA,"documento",::oMvc:COMPROBANT} )
         If nDel > 1
            If !oApl:oPag:lOK
               oApl:oPag:EMPRESA  := oApl:nEmpresa; oApl:oPag:NUMFAC  := aCan[4]
               oApl:oPag:TIPO     := oApl:Tipo    ; oApl:oPag:FECPAG  := ::oMvc:FECHA
               oApl:oPag:DOCUMENTO:= ::oMvc:COMPROBANT
            EndIf
            oApl:oPag:ABONO    += nPago
            oApl:oPag:PAGADO   := oApl:oPag:ABONO ; oApl:oPag:NUMCHEQUE := ::oMvd:INFD
            oApl:oPag:TIPO_PAG := If( ::aMov[2] == 1, "P", If( nMov == 2, "D", "C" ) )
            Guardar( oApl:oPag,!oApl:oPag:lOK,.f. )
         ElseIf oApl:oPag:lOK
                oApl:oPag:Delete(.f.,1)
         EndIf
      EndIf
      oApl:lFam := SaldoFac( aCan[4],,nIfrs )
      GrabaSal( aCan[4],nMov,nPago,nIfrs )
      If nPago < 0
         oApl:nSaldo += If( nMov == 2, -nPago, nPago )
      Else
         oApl:nSaldo += If( nMov == 2, nPago, -nPago )
      EndIf
      If oApl:nSaldo == 0
         aCan[1] := "C"
         aCan[2] := ::oMvc:FECHA
      EndIf
      cCta := "UPDATE "+aCan[3]+ " SET indicador = '" +aCan[1]+;
                 "', fechacan = " + xValToChar( aCan[2] )     +;
              " WHERE empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
                " AND numfac  = " + LTRIM(STR(aCan[4]))       +;
                " AND tipo = '"   + oApl:Tipo + "'"
      MSQuery( oApl:oMySql:hConnect,cCta )
   EndIf
   oApl:Tipo := cTipo
EndIf
RETURN NIL

//------------------------------------//
METHOD GrabaCXP( cCta,cDoc,nPago,nMov,nDel,nIfrs ) CLASS TMov
   LOCAL aInf := { cDoc,"",0,0,nPago,0,.f. }, cQry, hRes, nP
aInf[2] := If( InfAc( cCta,@nP,"FECHA     " ), ::oMvd:axBuffer[nP+5], "" )
aInf[3] := If( nDel == 1, ::aTL[7], ::oMvd:CODIGO_NIT )
aInf[4] := Buscar( {"empresa",oApl:nEmpresa,"codigo_nit",aInf[3],;
                    "numero",aInf[1]},"ctasxpc","cxpc_id",8,,4 )
 cDoc   := " WHERE cxpc_id = " + LTRIM(STR(aInf[4]))+;
             " AND ano_mes = '"+ ::oMvd:ANO_MES + "'"
If nIfrs == 1
   nIfrs := 0
Else
   nIfrs := nPago
   nPago := 0
EndIf
If nDel <= 1
   If nMov == 1
      cQry := "DELETE FROM ctasxpc" + cDoc
      Guardar( cQry,"ctasxpc" )
      cQry :=  STRTRAN( cQry,"mes ","mes >" )
      Guardar( STRTRAN( cQry,"sxpc","sxpm" ),"ctasxpm" )
   Else
      cQry := "UPDATE ctasxpm SET abonos = abonos + " + LTRIM(STR(nPago))+;
                               ", abonon = abonon + " + LTRIM(STR(nIfrs))+ cDoc
      Guardar( cQry,"ctasxpm" )
      nPago *= -1
      nIfrs *= -1
      cQry := "UPDATE ctasxpm SET saldo  = saldo  + " + LTRIM(STR(nPago))+;
                               ", saldon = saldon + " + LTRIM(STR(nIfrs))+;
              STRTRAN( cDoc,"mes ","mes >" )
      Guardar( cQry,"ctasxpm" )
   EndIf
   RETURN NIL
ElseIf aInf[5] == 0 .OR. EMPTY( aInf[1] ) .OR. EMPTY( aInf[2]) .OR. aInf[3] == 0
   RETURN NIL
EndIf
aInf[2] := CTOD( aInf[2] )
aInf[5] := ::oMvd:VALOR_CRE
If nMov == 1
/* VALOR_CRE > 0
   `row_id`   int(11) NOT NULL AUTO_INCREMENT,
   `empresa`  int(2) DEFAULT NULL,
   `codigo_nit` int(5) DEFAULT NULL,
   `numero`   varchar(10) DEFAULT NULL,
   `ano_mes`  varchar(6) DEFAULT NULL,
   `control`  int(6) DEFAULT NULL,
   `fecha`    date DEFAULT NULL,
   `fechaven` date DEFAULT NULL,
   `valor`    double(12,2) DEFAULT NULL,
   `cuenta`   varchar(10) DEFAULT NULL,
   `estado`   char(1) DEFAULT NULL,
   `fechapag` date DEFAULT NULL,
*/
   If aInf[4] == 0
      cQry := "INSERT INTO ctasxpc VALUES( null, "  +;
               LTRIM(STR(oApl:nEmpresa))   +  ", "  +;
               LTRIM(STR(aInf[3]))         +  ", '" +;
               ALLTRIM( aInf[1] )          + "', '" +;
               ::oMvd:ANO_MES              + "', "  +;
               LTRIM(STR( ::oMvd:CONTROL)) +  ", "  +;
               xValToChar(::oMvc:FECHA )   +  ", "  +;
               xValToChar( aInf[2] )       +  ", "  +;
               LTRIM(STR(aInf[5]))         +  ", '" +;
               ALLTRIM( cCta )             + "', 'P', null )"
      Guardar( cQry,"ctasxpc" )
      aInf[4] := Buscar( {"empresa",oApl:nEmpresa,"codigo_nit",aInf[3],;
                          "numero",aInf[1]},"ctasxpc","cxpc_id",8,,4 )
   ElseIf nIfrs == 0
      cQry := "UPDATE ctasxpc SET codigo_nit = "  + LTRIM(STR(aInf[3]))        +;
                                    ", fecha = "  + xValToChar( ::oMvc:FECHA ) +;
                                 ", fechaven = "  + xValToChar( aInf[2] )      +;
                                    ", valor = "  + LTRIM(STR(aInf[5]))        +;
                                   ", cuenta = '" + ALLTRIM( cCta )            +;
            "' WHERE cxpc_id = " + LTRIM(STR(aInf[4]))
      Guardar( cQry,"ctasxpc" )
   EndIf
EndIf
If aInf[4] == 0
   RETURN NIL
EndIf
cQry := "SELECT s.saldo, s.saldon, s.ano_mes FROM ctasxpm s "        +;
        "WHERE s.cxpc_id = " + LTRIM(STR(aInf[4]))                   +;
         " AND s.ano_mes = (SELECT MAX(m.ano_mes) FROM ctasxpm m "   +;
                           "WHERE m.cxpc_id  = " +LTRIM(STR(aInf[4]))+;
			                      " AND m.ano_mes <= '" + ::oMvd:ANO_MES + "')"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If MSNumRows( hRes ) > 0
   cQry := MyReadRow( hRes )
   AEVAL( cQry, { | xV,nP | cQry[nP] := MyClReadCol( hRes,nP ) } )
   aInf[5] := cQry[1]
   aInf[6] := cQry[2]
   aInf[7] := !(cQry[3] != ::oMvd:ANO_MES)
EndIf
MSFreeResult( hRes )
If !aInf[7] .AND.;
   (aInf[5] # 0 .OR. nPago # 0 .OR. aInf[6] # 0 .OR. nIfrs # 0)
/* `row_id`  int(11) NOT NULL AUTO_INCREMENT,
   `cxpc_id` int(11) DEFAULT NULL,
   `ano_mes` varchar(6) DEFAULT NULL,
   `saldo`   double(12,2) DEFAULT NULL,
   `abonos`  double(12,2) DEFAULT NULL,
   `saldon`  double(12,2) DEFAULT NULL,
   `abonon`  double(12,2) DEFAULT NULL,
*/
   cQry := "INSERT INTO ctasxpm VALUES ( null, "  +;
            LTRIM(STR(aInf[4]))         +  ", '"  +;
            ::oMvd:ANO_MES              + "', "   +;
            LTRIM(STR(aInf[5]))         +  ", 0, "+;
            LTRIM(STR(aInf[6]))         +  ", 0 )"
   Guardar( cQry,"ctasxpm" )
EndIf
If nMov == 1 .AND. nDel == 2
   nPago := nIfrs := 0
EndIf
If nPago # 0 .OR. nIfrs # 0
   cDoc := " WHERE cxpc_id = " + LTRIM(STR(aInf[4]))+;
             " AND ano_mes = '"+ ::oMvd:ANO_MES + "'"
   If nMov == 2
      //VALOR_DEB > 0
      cQry := "UPDATE ctasxpm SET abonos = abonos + " + LTRIM(STR(nPago))+;
                               ", abonon = abonon + " + LTRIM(STR(nIfrs))+ cDoc
      Guardar( cQry,"ctasxpm" )
      nPago *= -1
      nIfrs *= -1
   EndIf
   cQry := "UPDATE ctasxpm SET saldo  = saldo  + " + LTRIM(STR(nPago))+;
                            ", saldon = saldon + " + LTRIM(STR(nIfrs))+;
           STRTRAN( cDoc,"mes ","mes >" )
   Guardar( cQry,"ctasxpm" )
/*
   nP := RAT( "AND",cDoc )
   aInf[5] += nPago
   If aInf[5] == 0
      aInf[1] := "C"
      aInf[2] := ::oMvc:FECHA
   Else
      aInf[1] := "P"
      aInf[2] := CTOD("")
   EndIf
   cQry := "UPDATE ctasxpc SET estado = '" +aInf[1]  +;
             "', fechapag = " + xValToChar( aInf[2] )+ cDoc
   Guardar( cQry,"ctasxpc" )
*/
EndIf
RETURN NIL

//------------------------------------//
METHOD Prestamo( nPago,nMov,nDel ) CLASS TMov
   LOCAL aCam, aPE := { 0,0,25,"" }, cQry, hRes
aPE[1] := If( nDel == 1, ::aTL[7], ::oMvd:CODIGO_NIT )
aPE[2] := Buscar( {"empresa",oApl:nEmpresa,"codigo_nit",aPE[1]},;
                  "nomemple","codigo",8,,4 )
If aPE[2] == 0
   RETURN NIL
EndIf
aPE[4] := ::aMov[1] + If( DAY(::oMvc:FECHA) >= 16, "2", "1" )
aPE[1] := " WHERE empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND codigo   = " + LTRIM(STR( aPE[2] ))     +;
            " AND concepto = " + LTRIM(STR( aPE[3] ))     +;
            " AND anomes = '"  + aPE[4] + "'"
If nDel <= 1
   nPago*= If( nMov == 1, -1, 1 )
   cQry := "UPDATE nomdesfi SET saldoact = saldoact + " + LTRIM(STR(nPago))
   If nMov # 1
      cQry += ", valorcargo = valorcargo + " + LTRIM(STR(nPago))
   EndIf
   Guardar( cQry + STRTRAN( aPE[1],"mes ","mes >" ),"nomdesfi" )
   cQry := "DELETE FROM nomdesfi" + aPE[1]
   //Guardar( cQry,"nomdesfi" )
   RETURN NIL
EndIf

cQry := "SELECT d.saldoact, d.cuotadesc, d.fechainic, d.anomes " +;
        "FROM nomdesfi d "                                       +;
        "WHERE d.empresa = " + LTRIM(STR(oApl:nEmpresa))         +;
         " AND d.codigo  = " + LTRIM(STR( aPE[2] ))              +;
         " AND d.concepto = "+ LTRIM(STR( aPE[3] ))              +;
         " AND d.anomes = (SELECT MAX(m.anomes) FROM nomdesfi m "+;
                          "WHERE m.empresa  = d.empresa"         +;
                           " AND m.codigo   = d.codigo"          +;
                           " AND m.concepto = d.concepto"        +;
                           " AND m.anomes  <= '" + aPE[4] + "')"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If MSNumRows( hRes ) > 0
   aCam := MyReadRow( hRes )
   AEVAL( aCam, { | xV,nP | aCam[nP] := MyClReadCol( hRes,nP ) } )
Else
   aCam := { 0,nPago,::oMvc:FECHA,"" }
EndIf
   MSFreeResult( hRes )
If nMov == 2
   nDel := aCam[2]
   MsgGet( "DESCUENTO","Valor Cuota $",@nDel )
   aCam[2] := nDel
EndIf
/* nomdesfi
  `row_id` int(11) NOT NULL AUTO_INCREMENT,
  `empresa` int(2) DEFAULT NULL,
  `codigo` int(5) DEFAULT NULL,
  `concepto` int(3) DEFAULT NULL,
  `anomes` varchar(7) DEFAULT NULL,
  `valorinic` double(11,2) DEFAULT NULL,
  `saldoact` double(11,2) DEFAULT NULL,
  `cuotadesc` double(11,2) DEFAULT NULL,
  `valorcargo` double(11,2) DEFAULT NULL,
  `fechainic` date DEFAULT NULL,
  `tipodesc` char(1) DEFAULT NULL,
  `formadesc` int(1) DEFAULT NULL,
  `hacerdesc` tinyint(1) unsigned zerofill NOT NULL DEFAULT '0',
  `acumular` tinyint(1) unsigned zerofill NOT NULL DEFAULT '1',
  `fechacomp` date DEFAULT NULL,
*/
If aCam[4] # aPE[4]
   If EMPTY( aCam[3] )
      aCam[3] := ::oMvc:FECHA
   EndIf
   nDel := If( nMov == 2, nPago, aCam[1] )
   cQry := "INSERT INTO nomdesfi VALUES ( null, " +;
           INF( oApl:nEmpresa,", " )    + INF( aPE[2] ,", " ) +;
           INF( aPE[3]       ,", " )    + INF( aPE[4] ,", " ) +;
           INF( nDel         ,", " )    + INF( aCam[1],", " ) +;
           INF( aCam[2]      ,", 0, " ) + INF( aCam[3],", " ) +;
           "'V', 0, '1', '1', "         + INF(::oMvc:FECHA,")" )
   //Msginfo( cQry,"Grabar Prestamo" )
   Guardar( cQry,"nomdesfi" )
EndIf
If nMov # 1
   cQry := "UPDATE nomdesfi SET valorcargo = valorcargo + " + LTRIM(STR(nPago)) + aPE[1]
   Guardar( cQry,"nomdesfi" )
EndIf
nPago*= If( nMov == 1, -1, 1 )
cQry := "UPDATE nomdesfi SET saldoact = saldoact + " + LTRIM(STR(nPago)) +;
        STRTRAN( aPE[1],"mes ","mes >" )
   Guardar( cQry,"nomdesfi" )
RETURN NIL

//------------------------------------//
METHOD Barram( oDlg,oLbx ) CLASS TMov
   LOCAL oBar, oBot := ARRAY(9)
DEFINE BUTTONBAR oBar OF oDlg 3DLOOK SIZE 28,28

DEFINE BUTTON oBot[1] RESOURCE "ADD"       OF oBar NOBORDER ;
   ACTION ::Detalle( oDlg,oLbx,.t. )       TOOLTIP "Nuevo Registro (Ctrl+N)"
DEFINE BUTTON oBot[2] RESOURCE "MODIFY"    OF oBar NOBORDER ;
   ACTION ::Detalle( oDlg,oLbx,.f. )       TOOLTIP "Editar Registro (Ctrl+E)"
DEFINE BUTTON oBot[3] RESOURCE "DELREC"    OF oBar NOBORDER ;
   ACTION ::BorraDeta( oDlg,oLbx )         TOOLTIP "Borrar  (Ctrl+DEL)"
DEFINE BUTTON oBot[4] RESOURCE "IMPRIMIR"  OF oBar NOBORDER ;
   ACTION ::ArmarLis()                     TOOLTIP "Imprimir Nota"
DEFINE BUTTON oBot[5] RESOURCE "ANTERIOR"  OF oBar NOBORDER ;
   ACTION ::Avanza( oDlg,oLbx,-1 ) GROUP   TOOLTIP "Comprobante Anterior"
DEFINE BUTTON oBot[6] RESOURCE "SIGUIENTE" OF oBar NOBORDER ;
   ACTION ::Avanza( oDlg,oLbx,1 )          TOOLTIP "Siguiente Comprobante"
DEFINE BUTTON OF oBar NOBORDER     ;
   ACTION ::Filtrar( 2,oDlg,oLbx ) ;
   FILENAME oApl:cIco+"SBloque.bmp";
   TOOLTIP "COLGAAP ó NIIF"
DEFINE BUTTON oBot[7] RESOURCE "BORRAR"    OF oBar NOBORDER ;
   ACTION ::AnulaCpte( oDlg )      GROUP   TOOLTIP "Anular Comprobante"
DEFINE BUTTON oBot[8] RESOURCE "CALC"      OF oBar NOBORDER ;
   ACTION WinExec("Calc")                  TOOLTIP "Calculadora"
DEFINE BUTTON oBot[9] RESOURCE "CLOSE"     OF oBar NOBORDER ;
   GROUP ACTION oDlg:End()         GROUP   TOOLTIP "Salir"
RETURN oBar

//------------------------------------//
METHOD ArmarLis() CLASS TMov
If ::oFte:oDb:IMPRIMO .AND.;
   ::oMvc:CONTROL > 0 .AND. ::oMvc:ESTADO # 2
   CgeLista( ::oMvc:CONTROL,,::oFte:oDb:DESCRIPCIO )
EndIf
RETURN NIL

//------------------------------------//
METHOD Dsctos( oLbd,nID ) CLASS TMov
   LOCAL oDlg, oLbx
If nID == 0
   RETURN NIL
EndIf
 ::oArf:Seek( {"comprasc_id",nID} )

DEFINE DIALOG oDlg TITLE "Descuentos Condicionados" FROM 0, 0 TO 15,36

   @ 16,06 LISTBOX oLbx FIELDS DTOC( ::oArf:FECHA )                ,;
                          TRANSFORM( ::oArf:DSCTO,"99,999,999.99" ),;
                          TRANSFORM( ::oArf:PTAJE,       "999.99" ) ;
      HEADERS "Fecha" +CRLF+ "Descuento", "Descuento", "Porcentaje" ;
      SIZES 400, 450 SIZE 130,86 ;
      OF oDlg UPDATE PIXEL       ;
      ON DBLCLICK ::Editad( nID,oLbx,.f. )
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:nHeaderHeight := 28
    oLbx:GoTop()
    oLbx:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:aColSizes   := {84,86,86}
    oLbx:aHjustify   := {2,2,2}
    oLbx:aJustify    := {0,1,1}
    oLbx:ladjbrowse  := oLbx:lCellStyle  := .f.
    oLbx:ladjlastcol := .t.
    oLbx:bKeyDown := {|nKey| If(nKey == VK_ESCAPE, ( oDlg:End() ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, ::Editad( nID,oLbx,.t. ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, ::Editad( nID,oLbx,.f. ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE             , DelRecord( ::oArf,oLbx ), )))) }
   MySetBrowse( oLbx, ::oArf )
ACTIVATE DIALOG oDlg CENTERED
 oLbd:SetFocus()
RETURN NIL

//------------------------------------//
METHOD Editad( nID,oLbx,lNew ) CLASS TMov
   LOCAL oDlg, cTit := "Modificando Descuento"
   LOCAL bGrabar, oGet := ARRAY(6)
If lNew
   cTit    := "Nuevo Descuento"
   bGrabar := {|| ::oArf:COMPRASC_ID := nID     ,;
                  ::oArf:Append( .t. )          ,;
                  ::oArf:xBlanK()               ,;
                  oDlg:Update(), oDlg:SetFocus() }
   oLbx:GoBottom() ; ::oArf:xBlank()
Else
   bGrabar := {|| ::oArf:Update( .f.,1 ), oDlg:End() }
EndIf

DEFINE DIALOG oDlg TITLE cTit FROM 0, 0 TO 10,30
   @ 02,00 SAY "Fecha"      OF oDlg RIGHT PIXEL SIZE 46,10
   @ 02,50 GET oGet[1] VAR ::oArf:FECHA OF oDlg ;
      SIZE 40,10 PIXEL
   @ 14,00 SAY "Descuento"  OF oDlg RIGHT PIXEL SIZE 46,10
   @ 14,50 GET oGet[2] VAR ::oArf:DSCTO OF oDlg PICTURE "99,999,999";
      VALID {|| If( ::oArf:DSCTO <  ::oArc:TOTALFAC, .t.           ,;
          (MsgStop( "Dscto debe ser Menor de "+STR(::oArc:TOTALFAC),"<< OJO >>"), .f.)) };
      SIZE 40,10 PIXEL UPDATE
   @ 26,00 SAY "Dscto US"   OF oDlg RIGHT PIXEL SIZE 46,10
   @ 26,50 GET oGet[3] VAR ::oArf:DSCTO_US OF oDlg PICTURE "99,999,999";
      VALID {|| If( ::oArf:DSCTO_US <  ::oArc:TOTALFAC, .t.           ,;
          (MsgStop( "Dscto debe ser Menor de "+STR(::oArc:TOTALFAC),"<< OJO >>"), .f.)) };
      SIZE 40,10 PIXEL UPDATE
   @ 38,00 SAY "Porcentaje" OF oDlg RIGHT PIXEL SIZE 46,10
   @ 38,50 GET oGet[4] VAR ::oArf:PTAJE OF oDlg PICTURE "999.99";
      SIZE 40,10 PIXEL UPDATE

   @ 52,30 BUTTON oGet[5] PROMPT "&Grabar"   SIZE 34,12 OF oDlg ACTION ;
      (If( EMPTY(::oArf:FECHA) .OR. ::oArf:DSCTO <= 0                 ,;
         ( MsgStop("Imposible grabar este Dscto"), oGet[1]:SetFocus()),;
         ( oGet[5]:Disable(), EVAL( bGrabar ), oGet[5]:Enable() ))) PIXEL
   @ 52,70 BUTTON oGet[6] PROMPT "&Cancelar" SIZE 34,12 OF oDlg CANCEL;
      ACTION ( oDlg:End() ) PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
 oLbx:Refresh()
 oLbx:SetFocus()
RETURN NIL
/*
//------------------------------------//
METHOD ArmarLis( aChq ) CLASS TMov
   LOCAL lPreview, nP, oRpt, aFnt := ARRAY(2)
   ::aCG := { "","",0,0,0,0 }
If ::oNit:oDb:Seek( {"codigo_nit",::oMvc:CODIGONIT} )
   ::aCG[2] := FormatoNit( ::oNit:oDb:CODIGO,::oNit:oDb:DIGITO )
EndIf
If ::aMov[2] >= 3
   ::oNot:LISTAR := "D"
   ::NotasCge()
   RETURN NIL
EndIf
If aChq == NIL
   AADD( ::aCG, { "","","","" } )
   ::oMvd:dbEval( {|o| If( LEFT( o:CUENTA,2 ) == "11" .OR.;
                           LEFT( o:CUENTA,4 ) == "1310"  ,;
                         ( ::oPuc:oDb:Seek( {"empresa",oApl:nPuc,"cuenta",o:CUENTA} ),;
                           If( InfAc( ::oPuc:oDb,@nP,"CHEQUE    " )                  ,;
                             ( ::aCG[7,1] := o:axBuffer[nP+5]                        ,;
                               ::aCG[7,2] := ::oPuc:oDb:NOMBRE                       ,;
                               ::aCG[7,4] := o:INFA )                                ,;
                           If( LEFT( o:CUENTA,2 ) == "11", ::aCG[7,3] := "X", ) )    ,;
                          ::aCG[6] += If( ::aMov[2] == 1, o:VALOR_DEB, o:VALOR_CRE )  ;
                         ), ) } )
Else
   ::aCG[6] := ::oMvc:VALORB
   AADD( ::aCG, { aChq[1],aChq[2],aChq[3],aChq[4] } )
EndIf
If LEN( ::aCG ) >= 7
   ::aCG[7,1] := If( ::aMov[2] == 2, ::aCG[7,1], "" )
   ::aCG[7,2] := TRIM( ::aCG[7,2] ) + " CtaCte " + ::aCG[7,4]
Else
   AADD( ::aCG, { "","","" } )
EndIf
aChq := "(empresa = " + LTRIM(STR(oApl:nEmpresa))+;
     " OR empresa = " + LTRIM(STR(oApl:nPuc))    +;
    ") AND fuente = " + LTRIM(STR(::aMov[2]))
If !::oNot:Seek( aChq,"CM" )
   aChq := { "N",If( oApl:nTFor == 1, "D", "W" ),"0",;
             9,10,15,50,11,13,11,61,13,10,50,17,14,"AS",27,1,12,45,60 }
   AEVAL( aChq, { |x,p| ::oNot:axBuffer[p+3] := x } )
EndIf
::aTL := Letras( ::aCG[6],::oNot:LM )
If ::oNot:LISTAR == "D"
   lPreview := MsgNoYes( "Vista Previa", ">>> Desea Ver <<<" )
   If ::oNot:FORMA == "N"
      ::DosNForma( lPreview )
   Else
      ::DosFForma( lPreview )
   EndIf
ELSE
PrinterSetup()
   DEFINE FONT aFnt[1] NAME "ARIAL"         SIZE 0,-10
   DEFINE FONT aFnt[2] NAME "Ms Sans Serif" SIZE 0,-20

   REPORT oRpt TITLE ""     , ""                    RIGHT  ;
      HEADER oApl:cEmpresa, "NIT: " + oApl:oEmp:Nit CENTER ;
      FONT aFnt[1], aFnt[2]                                ;
      PREVIEW                                              ;
      CAPTION "COMPROBANTES"

    COLUMN TITLE " " DATA " " SIZE 11
    COLUMN TITLE " " DATA " " SIZE 32
    COLUMN TITLE " " DATA " " SIZE 12
    COLUMN TITLE " " DATA " " SIZE 12

   END REPORT
   oRpt:oHeader:aFont[1] := {|| 2 }   //Primera linea del titulo en 20
   oRpt:nTitleUpLine := RPT_NOLINE
   oRpt:nTitleDnLine := RPT_NOLINE    //SINGLELINE

   ACTIVATE REPORT oRpt WHILE ::WinNForma( oRpt )

   AEVAL( aFnt, { |oFont| oFont:End() } ) // Destruye el objecto font
EndIf
RETURN NIL

//------------------------------------//
METHOD DosFForma( lPreview ) CLASS TMov
   LOCAL oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,,lPreview )//,,1,66,66 )
oRpt:nPage := 1
oRpt:SetFont( oRpt:CPINormal,82,2 )

oRpt:Say( ::oNot:FF,::oNot:CF,NtChr( ::oMvc:FECHA,"2" ) )
oRpt:Say( ::oNot:FB,::oNot:CB,::oNit:oDb:NOMBRE )
oRpt:Say( ::oNot:FN,::oNot:CN,::aCG[2] )
oRpt:Say( ::oNot:FM,::oNot:CM,::aTL[1] )
oRpt:Say( ::oNot:FV,::oNot:CV,TRANSFORM( ::aCG[6],"9,999,999,999.99" ) )
oRpt:Say( ::oNot:FC,::oNot:CC,::oMvc:CONCEPTO )
oRpt:nL := ::oNot:FD

::CicloDeta( oRpt,{ ::oNot:CT,::oNot:CD,::oNot:DB,::oNot:CR } )

oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD DosNForma( lPreview ) CLASS TMov
   LOCAL oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"Comprobante de " +;
          If( ::oMvc:FUENTE == 1,"Ingreso", "Egreso" ) + " No"  ,;
          STR(::oMvc:COMPROBANT)," P.U.C.              C O N C "+;
          "E P T O             D E B I T O     C R E D I T O" },lPreview ) //,,1,66,66 )
oRpt:nPage := 1
oRpt:SetFont( oRpt:CPINormal,82,2 )

oRpt:Say( 02,00,oRpt:CPILarge+PADC( oApl:cEmpresa,43 ) )
oRpt:Say( 03,30,"NIT: " + oApl:oEmp:Nit )
oRpt:Say( 04,02,"BENEFICIARIO " +::oNit:oDb:NOMBRE )
oRpt:Say( 05,02,"Nit. o C.C.  " + ::aCG[2] )
oRpt:Say( 07,02,"FECHA        " + NtChr( ::oMvc:FECHA,"2" ) )
oRpt:Say( 09,16,oRpt:aEnc[1] )
oRpt:Say( 09,42,oRpt:CPILarge + oRpt:aEnc[2] )
oRpt:Say( 11,02,"Por Concepto de : " + ::oMvc:CONCEPTO )
oRpt:Say( 12,00,oRpt:aEnc[3] )
oRpt:Say( 13,00,REPLICATE("_",78) )
oRpt:nL := 14
::CicloDeta( oRpt,{ 0,11,45,62 } )

oRpt:Say(  oRpt:nL,45,Replicate("=",33),,,1 )
oRpt:Say(++oRpt:nL,33,"TOTALES ==>",,,1 )
oRpt:Say(  oRpt:nL,45,TransForm( ::aCG[3],"9,999,999,999.99" ) )
oRpt:Say(  oRpt:nL,62,TransForm( ::aCG[4],"9,999,999,999.99" ) )
If ::aMov[2] == 2
   If ::aCG[7,3] == "X"
      oRpt:Say(++oRpt:nL,02,"Efectivo " + ::aCG[7,3] )
   EndIf
   If !EMPTY(::aCG[7,1])
      oRpt:Say(++oRpt:nL,02,"Cheque No "+ ::aCG[7,1] )
      oRpt:Say(++oRpt:nL,02,"Banco "    + ::aCG[7,2] )
   EndIf
   oRpt:nL += 5
   oRpt:Say(++oRpt:nL,10,REPLICATE("_",42) )
   oRpt:Say(++oRpt:nL,16,"Firma y sello del Beneficiario" )
   oRpt:Say(++oRpt:nL,18,"C.C. - Nit" )
EndIf
oRpt:NewPage()
oRpt:End()

RETURN NIL

//------------------------------------//
METHOD NotasCge() CLASS TMov
   LOCAL oRpt := TDosPrint()
::aCG[1]:= If( ::oFte:oDb:FUENTE == 7, "NOTA DE CONTABILIDAD",;
            TRIM(::oFte:oDb:DESCRIPCIO) ) + " No." + STR(::oMvc:COMPROBANT)
::aCG[2]+= "    " + ::oNit:oDb:NOMBRE
oRpt:New( oApl:cPuerto,oApl:cImpres,{::aCG[1],NtChr( ::oMvc:FECHA,"2" ),;
         "NIT: " + ::aCG[2],SPACE(32) +"D E T A L L E",::oMvc:CONCEPTO +"      "+;
         PADC( TRIM(::oFte:oDb:DESCRIPCIO),32 )," P.U.C.              "+;
         "C O N C E P T O             D E B I T O     C R E D I T O"},,,,,,78)
oRpt:lPreview := MsgNoYes( "Vista Previa", ">>> Desea Ver <<<" )

::CicloDeta( oRpt,{ 0,11,45,62 } )

::aCG[5] := ::aCG[3] - ::aCG[4]
oRpt:Say(  oRpt:nL,45,Replicate("=",33),,,1 )
oRpt:Say(++oRpt:nL,33,"TOTALES ==>",,,1 )
oRpt:Say(  oRpt:nL,45,TransForm( ::aCG[3],"9,999,999,999.99" ) )
oRpt:Say(  oRpt:nL,62,TransForm( ::aCG[4],"9,999,999,999.99" ) )
oRpt:Say(++oRpt:nL,00,Replicate("_",78),,,1 )
oRpt:Say(++oRpt:nL,00,"PREPARADO      REVISADO        APROBADO",,,1 )
If ::aCG[5] # 0
   oRpt:Say(++oRpt:nL,45,"Descuadre ==>" )
   oRpt:Say(  oRpt:nL,62,TransForm( ::aCG[5],"9,999,999,999.99" ) )
EndIf
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD WinNForma( oRpt ) CLASS TMov
   LOCAL nK
oRpt:NewLine()
ImpLine( {3,"","Comprobante de " + If( ::oMvc:FUENTE == 1, "Ingreso", "Egreso" )+;
          " No",2,1, 4,"",STR( ::oMvc:COMPROBANT ),2,1 }, oRpt )
oRpt:NewLine()
ImpLine( {2,"","FECHA",2,1,        3,"",NtChr( ::oMvc:FECHA,"3" ),1,1 }, oRpt )
oRpt:NewLine()
ImpLine( {1,"","BENEFICIARIO",1,1, 2,"",::oNit:oDb:NOMBRE        ,1,1 }, oRpt )
ImpLine( {1,"","Nit. o C.C." ,1,1, 2,"",::aCG[2] ,1,1 }, oRpt )
ImpLine( {1,"","LA SUMA DE"  ,1,1, 2,"",::aTL[1],1,1 }, oRpt )
ImpLine( {2,"",::aTL[2],1,1 }, oRpt )
oRpt:NewLine()

ImpLine( {1,"","Codigo P.U.C.",1,1, 2,"","C O N C E P T O",3,1,;
          3,"","DEBITO"       ,2,1, 4,"","CREDITO"        ,2,1 }, oRpt )
ImpLine( {1,"",REPLICATE("_",84),1,1 }, oRpt )
ImpLine( {2,"",::oMvc:CONCEPTO,1,1 }, oRpt )

::CicloDeta( oRpt )

FOR nK := ::aCG[5] TO 6 //20
   oRpt:NewLine()
NEXT nK
ImpLine( {1,"",REPLICATE("_",84),1,1 }, oRpt )
ImpLine( {2,"","VALOR TOTAL ==> $",2,1,;
          3,"",TRANSFORM( ::aCG[3],"9,999,999,999.99" ),2,1,;
          4,"",TRANSFORM( ::aCG[4],"9,999,999,999.99" ),2,1 }, oRpt )
ImpLine( {1,"",REPLICATE("_",84),1,1 }, oRpt )
oRpt:NewLine()
ImpLine( {1,"","Cheque No",1,1, 2,"",::aCG[7,1],1,1 }, oRpt )
ImpLine( {1,"","Banco"    ,1,1, 2,"",::aCG[7,2],1,1 }, oRpt )
ImpLine( {1,"","Efectivo" ,1,1, 2,"",::aCG[7,3],1,1 }, oRpt )
FOR nK := 1 TO 4
   oRpt:NewLine()
NEXT nK
ImpLine( {2,"",REPLICATE("_",40),1,1 }, oRpt )
ImpLine( {2,"","Firma y sello del Beneficiario",3,1 }, oRpt )
ImpLine( {2,"","C.C. - Nit",3,1 }, oRpt )
RETURN .f.

//------------------------------------//
METHOD CicloDeta( oRpt,aC ) CLASS TMov
   LOCAL aRes, nL, nMIl, hRes, cPict := "@Z 9,999,999,999.99"
aRes := "SELECT d.cuenta, d.infa, d.valor_deb, d.valor_cre"+;
             ", p.nombre, n.codigo, n.digito, n.nombre "   +;
        "FROM cgeplan p, cgemovd d LEFT JOIN cadclien n "  +;
          "ON (d.codigo_nit = n.codigo_nit) "              +;
        "WHERE d.empresa = " + LTRIM(STR(oApl:nEmpresa))   +;
         " AND d.ano_mes = " + xValToChar( ::aMov[1] )     +;
         " AND d.control = " + LTRIM(STR(::oMvc:CONTROL))  +;
         " AND p.empresa = " + LTRIM(STR(oApl:nPuc))       +;
         " AND p.cuenta  = d.cuenta "                      +;
        "ORDER BY d.row_id"
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
nMil := ROUND( ::oMvc:VALORB * .004,0 )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If ::oMvc:FUENTE == 2
      If (LEFT(aRes[1],4) == "5305" .AND. aRes[3] == nMil) .OR.;
         (LEFT(aRes[1],4) == "1110" .AND. aRes[4] == nMil)
         nL --
         LOOP
      EndIf
   EndIf
   If EMPTY( aRes[8] )
      aRes[2] := PADL(aRes[2],13) + " " + aRes[5]
   Else
      aRes[2] := FormatoNit( aRes[6],aRes[7] )
      aRes[2] += If( LEN( aRes[2] ) == 13, " ", "   " ) + LEFT(aRes[8],20)
   EndIf
   If ::oNot:LISTAR == "D"
      oRpt:Titulo( 78,9,1 )
      oRpt:Say( oRpt:nL,aC[1],aRes[1] )
      oRpt:Say( oRpt:nL,aC[2],aRes[2] )
      oRpt:Say( oRpt:nL,aC[3],TRANSFORM( aRes[3],cPict ) )
      oRpt:Say( oRpt:nL,aC[4],TRANSFORM( aRes[4],cPict ) )
      oRpt:nL ++
   Else
    //::Cabecera( .t. )
      oRpt:StartLine()
      oRpt:Say( 1,aRes[1] )
      oRpt:Say( 2,aRes[2] )
      oRpt:Say( 3,TRANSFORM( aRes[3],cPict ),1,2 )
      oRpt:Say( 4,TRANSFORM( aRes[4],cPict ),1,2 )
      oRpt:EndLine()
   EndIf
   ::aCG[3] += aRes[3]
   ::aCG[4] += aRes[4]
   ::aCG[5] ++
   nL --
EndDo
MSFreeResult( hRes )
RETURN NIL
*/
/*
METHOD Cabecera( cTit,lSep,nSpace,nSuma ) CLASS TLibro
If lSep .AND. !::aTL[3]
   ::aTL[3] := ::Separator( nSpace,nSuma )
EndIf
If ::aTL[3]
   ::Centrar( oApl:cEmpresa,::oFnt4,1.0 )
   UTILPRN ::oUtil 1.5, 8.2 SAY "NIT: " + oApl:oEmp:Nit
   UTILPRN ::oUtil 2.0, 1.0 SAY oApl:oEmp:DIRECCION FONT ::oFnt5
   UTILPRN ::oUtil 2.0,13.0 SAY "COMPROBANTE DE"
   UTILPRN ::oUtil 2.5, 1.0 SAY oApl:oEmp:TELEFONOS FONT ::oFnt5
   UTILPRN ::oUtil 2.5,13.0 SAY cTit + TRANSFORM(::oMvc:COMPROBANT,"9999999999")
   UTILPRN ::oUtil 3.0, 1.0 SAY oApl:cCiu FONT ::oFnt5
   UTILPRN ::oUtil 3.0,13.0 SAY "FECHA " + NtChr( ::oMvc:FECHA,"3" )
 //UTILPRN ::oUtil 2.0,16.5 SAY "PAGINA" + STR(::nPage,4 )

   UTILPRN ::oUtil BOX 3.5,1 TO 5.5,20 PEN ::oPen;
           ROUND 150,150
   UTILPRN ::oUtil 3.7, 1.2 SAY {"RECIBIDO DE","PAGADO A"}[::oMvc:FUENTE];
           FONT ::oFnt5
   UTILPRN ::oUtil 4.2, 1.2 SAY ::aMov[11]
   If ::oMvc:FUENTE == 2
      UTILPRN ::oUtil 3.7,15.2 SAY "C.C. ó NIT." FONT ::oFnt5
      UTILPRN ::oUtil 4.2,15.2 SAY ::aCG[2]
      UTILPRN ::oUtil 4.7, 1.2 TO 4.7,19.8 PEN ::oPen
      UTILPRN ::oUtil 4.9, 1.2 SAY "LA SUMA DE"  FONT ::oFnt5
      UTILPRN ::oUtil 5.4, 1.2 SAY ::aTL[1]      FONT ::oFnt5
   //   UTILPRN ::oUtil 5.4,20.0 SAY TRANSFORM( ::aCG[6],"9,999,999,999.99" ) RIGHT
   EndIf
   UTILPRN ::oUtil 6.0, 3.5 SAY ::oMvc:CONCEPTO
   UTILPRN ::oUtil 6.5, 1.0 SAY "P.U.C."
   UTILPRN ::oUtil 6.5, 2.5 SAY "C O N C E P T O"
   UTILPRN ::oUtil 6.5,14.6 SAY "D E B I T O S"   RIGHT
   UTILPRN ::oUtil 6.5,17.3 SAY "C R E D I T O S" RIGHT
   UTILPRN ::oUtil 6.7, 1.0 TO 4.7,20.0 PEN ::oPen
   ::nLinea := 7.0

  UTILPRN ::oUtil ;
          MSG { { "Listado de Facturas",oFont,CLR_RED,PAD_CENTER },;
                { "Ordenado por Codigo",::oFnt,CLR_BLUE,PAD_CENTER },;
                { "Ejemplo de Uso de TImprime / TUtilPrn", ::oFnt2,CLR_GREEN,PAD_LEFT } } AT 1.25,0;
          BRUSH ::oBrush ;
          PEN oPen ;
          ROUND  20,20 ;
          SHADOW WIDTH 0.1 ;
          SHADOWPEN oPen  ;
          EXPANDBOX 0.25,2 TITLE
RETURN NIL*/