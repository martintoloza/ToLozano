// Programa.: INTINPRO.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Mantenimiento de las Ordenes de Produccion.
#include "FiveWin.ch"
#include "TSBrowse.ch"
#include "btnget.ch"

MEMVAR oApl

#define CLR_PINK  nRGB( 128, 150, 150)
#define CLR_NBLUE nRGB( 255, 255, 235)

PROCEDURE InoinPro()
   LOCAL oLbd, oLbx, oGet := ARRAY(4), lSalir := .f.
   LOCAL aBarra, aRect, cTit, nA, oP, oNi
cTit := "Ordenes de Produccion || "
oP   := TProduc() ;  oP:New()
oNi  := TNits()   ; oNi:New()
oNi:oDb:xBlank()
 SETKEY( VK_F4,{|| If( Empresa(), ( oP:oDlg:SetText(cTit + oApl:cEmpresa),;
                       oP:New( 1 ), oP:oDlg:Update() ), ), oGet[1]:SetFocus() } )
aBarra := { {|| oP:Editar( oLbx,.t. ) }, {|| oP:Editar( oLbx,.f. ) },;
            {|| oP:Contabil( .t. ) }   , {|| oP:Borrar( oLbx ) }    ,;
            {|| ListoArt( {oP:oArc:FECHA,oP:oArc:FECHA,oP:aCab[1],"",;
                      .f.,0} ),oP:aCab[1] := 0, oGet[1]:SetFocus() },;
            {|| If( oP:aCab[8], oP:Contabil(.f.), ), lSalir := .t., oP:oDlg:End() },;
            {|| oP:Borrar( oLbx,oGet ) } }
DEFINE DIALOG oP:oDlg FROM 0, 0 TO 370, 580 PIXEL;
   TITLE cTit + oApl:cEmpresa
   @ 16, 00 SAY "Nro. de Orden" OF oP:oDlg RIGHT PIXEL SIZE 60,10
   @ 16, 62 GET oGet[1] VAR oP:aCab[1] OF oP:oDlg PICTURE "999999";
      VALID oP:Buscar( oLbx,oGet,oLbd )                           ;
      SIZE 30,10 PIXEL UPDATE
   @ 16,100 SAY "Sgte. Orden" + STR( oP:aCab[4],6 ) OF oP:oDlg PIXEL SIZE 70,10;
      UPDATE COLOR nRGB( 255,0,0 )
   @ 16,172 SAY "Fecha [DD.MM.AA]" OF oP:oDlg RIGHT PIXEL SIZE 60,10
   @ 16,236 GET oGet[2] VAR oP:oArc:FECHA OF oP:oDlg ;
      VALID( oP:CambiaFec(), .t. ) ;
      WHEN oP:aPrv[2] SIZE 40,10 PIXEL UPDATE
   @ 28, 00 SAY "# Comprobante" OF oP:oDlg RIGHT PIXEL SIZE 60,10
   @ 28, 62 SAY oP:oArc:COMPROBANT OF oP:oDlg PIXEL SIZE 30,10;
      UPDATE COLOR nRGB( 0,128,192 )
   @ 40, 00 SAY "Nit Operador" OF oP:oDlg RIGHT PIXEL SIZE 60,10
   @ 40, 62 BTNGET oGet[3] VAR oP:aCab[2] OF oP:oDlg PICTURE "9999999999";
      ACTION EVAL({|| If(oNi:Mostrar(), (oP:aCab[2] := oNi:oDb:CODIGO,;
                         oGet[3]:Refresh() ),) })                     ;
      VALID EVAL( {|| If( oNi:Buscar( oP:aCab[2],"Codigo",.t. )      ,;
            ( oP:aCab[7] := oNi:oDb:CODIGO_NIT, oP:oDlg:Update()     ,;
             If( oP:oArc:lOK .AND. oP:oArc:CODIGO_NIT # oP:aCab[7]   ,;
               ( oP:oArc:CODIGO_NIT := oP:aCab[7]                    ,;
                 oP:oArc:Update( .f.,1 ), MsgInfo("HECHO EL CAMBIO") ,;
                 oP:aCab[15] := .t., oGet[3]:oJump := oLbx), ) ,.t. ),;
            ( MsgStop( "Este Operador no Existe .." ), .f. )) })      ;
      SIZE 48,10 PIXEL UPDATE  RESOURCE "BUSCAR"
   @ 40,114 SAY oGet[4] VAR oNi:oDb:NOMBRE OF oP:oDlg PIXEL SIZE 130,12;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 52,194 SAY "SubTotal"    OF oP:oDlg RIGHT PIXEL SIZE 40,10
   @ 52,236 SAY oP:aCab[3] OF oP:oDlg PICTURE "999,999,999.99" PIXEL SIZE 42,10;
      UPDATE COLOR nRGB( 255,0,128 )

   @ 64,06 LISTBOX oLbx FIELDS oP:oArd:CODIGO             ,;
                    LeerCodig( oP:oArd:CODIGO )           ,;
                    TRANSFORM( oP:oArd:CANTIDAD,"99,999" ),;
                               oP:oArd:UNIDADMED          ,;
                    TRANSFORM( oP:oArd:PCOSTO  ,"99,999,999.99" ) ;
      HEADERS "Código"+CRLF+"Artículo", "Descripción", "Cantidad",;
              "Unidad"+CRLF+"Medida"  , "Precio"+CRLF+"Costo"     ;
      SIZES 400, 450 SIZE 280,56  ;
      OF oP:oDlg UPDATE PIXEL     ;
      ON DBLCLICK EVAL( aBarra[2] )
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:nHeaderHeight := 28
    oLbx:GoTop()
    oLbx:oFont      := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:aColSizes  := {84,200,60,86,86}
    oLbx:aHjustify  := {2,2,2,2,2}
    oLbx:aJustify   := {0,0,1,0,1}
    oLbx:ladjbrowse := oLbx:lCellStyle := .f.
    oLbx:ladjlastcol:= .t.
    oLbx:bKeyDown := {|nKey| If(nKey == VK_ESCAPE, ( oP:aCab[1] := 0, oGet[1]:SetFocus() )    ,;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(aBarra[1]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, EVAL(aBarra[2]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE             , EVAL(aBarra[4]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=80 .OR. nKey=VK_F3    , EVAL(aBarra[5]),) )))) }
   MySetBrowse( oLbx,oP:oArd )

                     //SIZE Ancho, Alto
   @ 126.0,06 BROWSE oLbd SIZE 270,50 PIXEL OF oP:oDlg CELLED;
      COLORS CLR_BLACK, CLR_NBLUE
   oLbd:SetArray( oP:aEnt )
   oLbd:nHeightCell += 4
   oLbd:nHeightHead += 4
   oLbd:bKeyDown    := {|nKey| If( nKey== VK_TAB, oLbd:oJump := oLbx, ) }
   oLbd:SetAppendMode( oP:aCab[8] )             // Activando Auto Append Mode
   oLbd:SetDeleteMode( .t.,.f.,{ |nAt,oLbd| oP:DelArray(oLbd) },;
                  {|oLbd| oP:Dscto( 0,oLbd ) } ) // lOnOff, lConfirm, bDelete

   ADD COLUMN TO BROWSE oLbd DATA ARRAY ELEMENT 1;
       TITLE "Código"+CRLF+"Artículo"            ;
       SIZE  90 EDITABLE;          // Esta columna es editable
       3DLOOK TRUE, TRUE, TRUE;    // Celda, Titulo, Footers
       MOVE DT_MOVE_NEXT;          // Cursor pasa a la Sig.Columna editable
       VALID { |uVar| oP:Buscar( oLbd,uVar ) }; // don't want empty rows
       ALIGN DT_LEFT, DT_CENTER  ; // Celda, Titulo, Footer
       PREEDIT {|uVar| oP:aCab[14] := uVar, nA := oLbd:nAt ,;
                       oP:aCab[17] := If( nA > LEN(oP:aEnt), 0, oP:aEnt[nA,6] ) };
       WHEN oP:EditArray( oLbd )
    oLbd:aColumns[1]:bPostEdit := { |uVar| oP:aEnt[nA,1] := oP:aCab[14],;
             oP:aEnt[nA,2] := oP:aCab[15], oP:aEnt[nA,4] := oP:aCab[16],;
             oP:aEnt[nA,5] := oP:aCab[17], oP:Dscto( 1,oLbd ) }
     // activando BtnGet para la columna 1 y habilitando una Ayuda
    oLbd:SetBtnGet( 1, "Buscar", { | oGet,cVar | If( oP:oCA:Mostrar() ,;
        (cVar := oP:oCA:oDb:CODIGO, oGet:cText( cVar ), oGet:Refresh(),;
         oGet:KeyDown( VK_RETURN, 0 )), ) }, 16 )
   ADD COLUMN TO BROWSE oLbd DATA ARRAY ELEMENT 2;
       TITLE "Descripción de Entrada" ;
       SIZE 220 ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_LEFT, DT_CENTER, DT_RIGHT
   //  FOOTER "Totales->"
   ADD COLUMN TO BROWSE oLbd DATA ARRAY ELEMENT 3;
       TITLE "Cantidad"      PICTURE "999,999.99" ;
       SIZE  60 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER ;
       POSTEDIT { |uVar| If( oLbd:lChanged, oP:Dscto( 3,oLbd,uVar ), ) } ;
       WHEN oP:EditArray( oLbd ) ;
       VALID { |uVar| If( uVar > 0, .t. ,;
             (MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>" ), .f.) ) }
   ADD COLUMN TO BROWSE oLbd DATA ARRAY ELEMENT 4;
       TITLE "Unidad"+CRLF+"Medida"              ;
       SIZE  54 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_LEFT, DT_CENTER;
       PREEDIT  {|uVar| oP:aCab[16] := uVar, nA := oLbd:nAt }      ;
       POSTEDIT {|uVar| If( oLbd:lChanged .AND. oP:aCab[16] # uVar,;
                            oP:Dscto( 4,oLbd,uVar ), ) }           ;
       WHEN oP:EditArray( oLbd )
    // activando BtnGet para la columna 4 y habilitando (Combo Browse)
    oLbd:SetBtnGet( 4, "This", { | oGet, cVar |   ;
                If( !GetKeyState( VK_ESCAPE )    ,;
                  (aRect := GetCoors( oGet:hWnd ),;
                   cVar  := oGet:Value()         ,;
                   cVar  := oP:ComboBrowse( cVar,aRect[1],aRect[4],oGet:oWnd ),;
                   oGet:cText( cVar ), oGet:Refresh(),;
                   oGet:KeyDown( VK_RETURN, 0 ) ), ) }, 16 )
     oLbd:aColumns[ 4 ]:cMsg := "Presione F2 o Click boton para ver la lista"

   ADD COLUMN TO BROWSE oLbd DATA ARRAY ELEMENT 5;
       TITLE "Precio"+CRLF+"Costo"   PICTURE "99,999,999" ;
       SIZE  80 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       POSTEDIT { |uVar| If( oLbd:lChanged, oP:Dscto( 5,oLbd,uVar ), ) };
       WHEN oP:EditArray( oLbd )
//     FOOTER { || TransForm( oP:aCab[6], "99,999,999" ) };
   // Asignando Valores por defaults para nueva Fila creada con Auto Append.
   oLbd:aDefault := { SPACE(10), SPACE(40), 1, "UN", 0, 0 }
   oLbd:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbd:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color

   ACTIVAGET(oGet)
ACTIVATE DIALOG oP:oDlg ON INIT ;
  (oP:oDlg:Move(80,1), DefineBar( oP:oDlg,oLbx,aBarra ) );
   VALID lSalir
oP:oArc:Destroy()
oP:oArd:Destroy()
oP:oMvc:Destroy()
oP:oMvd:Destroy()
SETKEY( VK_F4,{||Empresa()} )
oApl:oEmp:Seek( {"Empresa",oP:aCab[5]} )
nEmpresa( .t. )
RETURN

//------------------------------------//
CLASS TProduc

 DATA aCab  AS ARRAY INIT { 0,0,0,1,1,0,0,.f.,.f.,"",0,0,"UN","","","",0 }
 DATA aCta, aPrv, aEnt, nMed
 DATA oArc, oArd, oDlg, oCA, oMvc, oMvd

 METHOD NEW( nFld ) Constructor
 METHOD Buscar( oLbx,oGet,oLbd )
 METHOD BuscarC( oDlg,lNew )
 METHOD Borrar( oLbx,oGet )
 METHOD DelArray( oLbx )
 METHOD Dscto( nPos,oLbx,mGetVar )
 METHOD EditArray( oLbx )
 METHOD Editar( oLbx,lNew )
 METHOD Grabar( oLbx,lNew )
 METHOD CambiaFec()
 METHOD ComboBrowse( cState,nRow,nCol,oWnd )
 METHOD Contabil( lG )

ENDCLASS

//------------------------------------//
METHOD New( nFld ) CLASS TProduc
   LOCAL cQry, hRes
If nFld == NIL
   oApl:oEmp:Seek( {"Localiz",oApl:oEmp:TITULAR} )
   nEmpresa( .t. )
   ::aCab[5] := oApl:oEmp:EMPRESA
   ::aEnt := { { SPACE(10), SPACE(40), 1, "UN", 0, 0 } }
   ::aCta := Cuentas( 4 )
   ::aPrv := Privileg( "COMPRAS" )
   ::oArc := oApl:Abrir( "ordenesc","Empresa, numero",.t.,,10 )
   ::oArd := oApl:Abrir( "ordenesd","Empresa, numero",,,100 )
   ::oMvc := oApl:Abrir( "cgemovc" ,"Empresa, ano_mes, control",.t.,,5 )
   ::oMvd := oApl:Abrir( "cgemovd" ,"Empresa, ano_mes, control",.t.,,10 )
   ::oArd:Seek( {"Empresa",oApl:nEmpresa,"Numero",0} )
   ::oCA  := TInv()
   ::oCA:New( ,.f. )
EndIf
 cQry := "SELECT MAX(Numero) FROM ordenesc WHERE Empresa = " +LTRIM(STR(oApl:nEmpresa))
 hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
             MSStoreResult( oApl:oMySql:hConnect ), 0 )
 If MSNumRows( hRes ) > 0
    cQry := MyReadRow( hRes )
    AEval( cQry, { | xV,nP | cQry[nP] := MyClReadCol( hRes,nP ) } )
    ::aCab[4] += cQry[1]
 EndIf
 MSFreeResult( hRes )
RETURN .t.

//------------------------------------//
METHOD Buscar( oLbx,oGet,oLbd ) CLASS TProduc
   LOCAL nA, lSi := .f.
If VALTYPE( oGet ) == "C"
   If (lSi := oApl:oInv:Seek( {"Codigo",oGet} ))
      nA := oLbx:nAt
      ::aCab[14] := oGet
      ::aCab[15] := oApl:oInv:DESCRIP
      If nA > LEN(::aEnt) .OR. ::aEnt[nA,1] # oGet
         ::aCab[16] := oApl:oInv:UNIDADMED
         ::aCab[17] := oApl:oInv:PCOSTO
      Else
         ::aCab[16] := ::aEnt[nA,4]
         ::aCab[17] := ::aEnt[nA,5]
      EndIf
   ElseIf !EMPTY( oGet )
      MsgStop( "Este Código NO EXISTE !!!",oGet )
   EndIf
ElseIf Rango( ::aCab[1],0,::aCab[4] )
   If ::aCab[8]
      ::Contabil( .f. )
   EndIf
   If !::oArc:Seek( {"Empresa",oApl:nEmpresa,"Numero",::aCab[1]} ) .AND. ::aCab[1] > 0
      MsgStop( "Esta Orden NO EXISTE !!" )
   Else
      If ::oArc:lOK
         oApl:oNit:Seek( {"Codigo_nit",::oArc:CODIGO_NIT} )
         ::aCab[2] := oApl:oNit:CODIGO
         ::aCab[3] := Buscar( {"Empresa",oApl:nEmpresa,"Numero",::aCab[1],"Tipo",2},;
                              "ordenesd","SUM(Cantidad * Pcosto)" )
         ::aCab[7] := ::oArc:CODIGO_NIT
         oGet[1]:oJump := oLbx
      Else
         ::aCab[3] := 0
         ::oArc:FECHA := DATE()
      EndIf
      ::aEnt := {}
      ::oArd:Seek( {"Empresa",oApl:nEmpresa,"Numero",::aCab[1],"Tipo",1} )
      While !::oArd:Eof()
         oApl:oInv:Seek( {"Codigo",::oArd:CODIGO} )
         AADD( ::aEnt,{ ::oArd:CODIGO   , oApl:oInv:DESCRIP, ::oArd:CANTIDAD,;
                        ::oArd:UNIDADMED, ::oArd:PCOSTO    , ::oArd:ROW_ID  } )
         ::oArd:Skip(1):Read()
         ::oArd:xLoad()
      EndDo
      If LEN( ::aEnt ) == 0
         AADD(::aEnt,{ SPACE(10), SPACE(40), 1, "UN", 0, 0 } )
      EndIf
      ::oArd:Seek( {"Empresa",oApl:nEmpresa,"Numero",::aCab[1],"Tipo",2} )
      ::oDlg:Update()
      ::aCab[8] := ::oArc:lOK
      ::aCab[9] := !(::oArc:COMPROBANT != 0)
      oLbd:aArray := ::aEnt
      oLbx:Refresh()
      lSi := .t.
   EndIf
EndIf
RETURN lSi

//------------------------------------//
METHOD BuscarC( oDlg,lNew ) CLASS TProduc

If oApl:oInv:Seek( {"Codigo",::oArd:CODIGO} )
   If lNew
      ::nMed := ArrayValor( ::oCA:aMed,oApl:oInv:UNIDADMED,,.t. )
      ::oArd:CANTIDAD := 1
      ::oArd:PCOSTO   := oApl:oInv:PCOSTO
   EndIf
   oDlg:Update()
Else
   MsgStop( "Este Código NO EXISTE !!!" )
EndIf
RETURN oApl:oInv:lOK

//------------------------------------//
METHOD Borrar( oLbx,oGet ) CLASS TProduc
   LOCAL aBor
If ::aPrv[3] //.AND. ::oArc:SECUENCIA > 0
   If oGet == NIL
      If MsgNoYes( "Este Código "+::oArd:CODIGO,"Elimina" )
         aBor := { ::oArd:CODIGO,-::oArd:CANTIDAD,::oArd:PCOSTO,::oArd:UNIDADMED,.f. }
         If (aBor[5] := ::oArd:Delete( .t.,1 ))
            PListbox( oLbx,::oArd )
         EndIf
         If aBor[5]
            Actualiz( aBor[1],aBor[2],::oArc:FECHA,1,aBor[3],aBor[4] )
            ::aCab[3] += (aBor[2] * aBor[3])
            Guardar( ::oArc,.f.,.f. )
         EndIf
      EndIf
   Else
      If Login( "Desea Anular esta Orden" )
         oApl:cPer := NtChr( ::oArc:FECHA,"1" )
         ::oMvc:Seek( {"Empresa",oApl:nEmpresa,"Ano_mes",oApl:cPer,"Fuente",4,;
                       "Comprobant",::oArc:COMPROBANT} )
         aBor := "Empresa = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND Ano_mes = " + xValToChar(oApl:cPer )   +;
            " AND Control = " + LTRIM(STR(::oMvc:CONTROL))
         ::oMvd:dbEval( {|o| o:EMPRESA := -4, Acumular( ::oMvc:ESTADO,o,3,3,.f.,.f. ) },aBor )
         Guardar( "UPDATE cgemovc SET Estado = 2 WHERE " + aBor,"cgemovc" )
         ::oArd:dbEval( {|o| Actualiz( o:CODIGO,-o:CANTIDAD,::oArc:FECHA,o:TIPO,o:PCOSTO,o:UNIDADMED ),;
                             o:Delete( .f.,1 ) } ,;
                        {"Empresa",oApl:nEmpresa,"Numero",::aCab[1]} )
         ::aCab[3] := 0
         ::aCab[8] := .f.
         Guardar( ::oArc,.f.,.f. )
         oGet[1]:SetFocus()
      EndIf
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD DelArray( oLbx ) CLASS TProduc
   LOCAL lSi := .f., nA := oLbx:nAt
do Case
Case ::aV[nA,6] == 0
   lSi := .t.
Case ::oArc:lOK .AND. ::aPrv[3]
   If MsgNoYes( "Elimina este Código",::aV[nA,1] )
      ::oArd:Seek( {"Row_id",::aV[nA,6]} )
      If ::oArd:Delete( .f.,1 )
         Actualiz( ::aEnt[nA,1],-::aEnt[nA,3],::oArc:FECHA,1,::aEnt[nA,5],::aEnt[nA,4] )
         lSi := .t.
      EndIf
      ::oArd:Seek( {"Empresa",oApl:nEmpresa,"Numero",::aCab[1],"Tipo",2} )
   EndIf
EndCase
RETURN lSi

//------------------------------------//
METHOD Dscto( nPos,oLbx,mGetVar ) CLASS TProduc
   LOCAL nSubTot, nA := oLbx:nAt
do Case
Case nPos == 3           // Cantidad
   ::aEnt[nA,3] := mGetVar
   ::aEnt[nA,5] := ROUND( ::aCab[3] / mGetVar,0 )
Case nPos == 4           // UnidadMed
   ::aEnt[nA,3] := AFormula( ::aEnt[nA,3],mGetVar,::aCab[16] )
EndCase
oLbx:Refresh() ; oLbx:DrawFooters()
RETURN NIL

//------------------------------------//
METHOD EditArray( oLbx ) CLASS TProduc
   LOCAL lEdit := .t., nA := oLbx:nAt, nF
If nA > LEN(::aEnt)
   nF := If( nA > 2, 1, nA-1 )
   If EMPTY( ::aEnt[nF,1] ) .OR. oLbx:nCell # 1
      MsgStop( "Primero Digite Código del Artículo","Nuevo" )
      oLbx:nAt   := oLbx:nLen := oLbx:nRowPos := nA
      oLbx:nCell := 1 ; lEdit := .f.
      oLbx:HiliteCell( 1 ) ; oLbx:Refresh(.t.)
      oLbx:DrawSelect()
   EndIf
Else
   If EMPTY( ::aEnt[nA,1] ) .AND. oLbx:nCell # 1
      MsgStop( "Primero Digite Código del Artículo" )
      oLbx:nCell := 1 ; lEdit := .f.
      oLbx:HiliteCell( 1 ) ; oLbx:Refresh()
   ElseIf ::oArc:lOK .AND. !::aPrv[2]
      MsgStop( "Este Registro no se Puede Modificar","Lo Siento" )
      lEdit := .f.
   EndIf
EndIf
RETURN lEdit

//------------------------------------//
METHOD Editar( oLbx,lNew ) CLASS TProduc
   LOCAL oDlg, cTit := "Modificando Código"
   LOCAL bGrabar, oGet := ARRAY(6), oE := Self
lNew := If( ::oArd:nRowCount == 0, .t., lNew )
If lNew
   cTit    := "Nuevo Código"
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
   ::aCab[10] := ::oArd:CODIGO
   ::aCab[11] := ::oArd:CANTIDAD
   ::aCab[12] := ::oArd:PCOSTO
   ::aCab[13] := ::oArd:UNIDADMED
EndIf
::nMed := ArrayValor( ::oCA:aMed,::oArd:UNIDADMED,,.t. )
oApl:oInv:Seek( {"Codigo",::oArd:CODIGO} )

DEFINE DIALOG oDlg TITLE cTit FROM 0, 0 TO 12,50
   @ 02,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 66,10
   @ 02,70 BTNGET oGet[1] VAR oE:oArd:CODIGO OF oDlg PICTURE "@!";
      VALID oE:BuscarC( oDlg,lNew )        ;
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"  ;
      ACTION EVAL({|| If(oE:oCA:Mostrar(), (oE:oArd:CODIGO := oApl:oInv:CODIGO,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
   @ 14,50 SAY    oGet[2] VAR oApl:oInv:DESCRIP OF oDlg PIXEL SIZE 120,10;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 26,00 SAY "Cantidad" OF oDlg RIGHT PIXEL SIZE 66,8
   @ 26,70 GET oGet[3] VAR ::oArd:CANTIDAD OF oDlg PICTURE "9,999.99";
      VALID {|| If( ::oArd:CANTIDAD >  0, .t.                       ,;
          (MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>"), .f.)) };
      SIZE 40,10 PIXEL UPDATE
   @ 38,00 SAY "Unidad Medida" OF oDlg RIGHT PIXEL SIZE 66,10
   @ 38,70 COMBOBOX oGet[4] VAR ::nMed ITEMS ArrayCol( oE:oCA:aMed,1 ) SIZE 68,99 ;
      OF oDlg PIXEL UPDATE
   @ 50,00 SAY "Precio Costo"  OF oDlg RIGHT PIXEL SIZE 66,10
   @ 50,70 GET oGet[5] VAR ::oArd:PCOSTO   OF oDlg PICTURE "999,999,999";
      SIZE 40,10 PIXEL UPDATE

   @ 64, 70 BUTTON oGet[5] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION ;
      (If( EMPTY(::oArd:CODIGO) .OR. ::oArd:CANTIDAD <= 0              ,;
         (MsgStop("Imposible grabar este Código"), oGet[1]:SetFocus() ),;
         ( oGet[5]:Disable(), ::oArd:UNIDADMED := oE:oCA:aMed[::nMed,2],;
           EVAL( bGrabar ), oGet[5]:Enable() ))) PIXEL
   @ 64,120 BUTTON oGet[6] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL ;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
   If !::aPrv[1]
      oGet[5]:Disable()
   EndIf
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
 oLbx:SetFocus()
RETURN NIL

//------------------------------------//
METHOD Grabar( oLbx,lNew ) CLASS TProduc

If ::aCab[1] == 0
   ::oArc:EMPRESA   := oApl:nEmpresa
   ::oArc:CODIGO_NIT:= ::aCab[7]
   Guardar( ::oArc,.t.,.t. )
   ::aCab[1] := ::oArc:NUMERO
   ::aCab[4] := ::aCab[1] + 1
   ::aCab[8] := .t.
EndIf
If lNew
   ::aCab[3] += (::oArd:CANTIDAD * ::oArd:PCOSTO)
   ::oArd:EMPRESA:= oApl:nEmpresa; ::oArd:NUMERO   := ::aCab[1]
   ::oArd:TIPO   := 2
   Guardar( ::oArd,.t.,.t. )
   Actualiz( ::oArd:CODIGO,::oArd:CANTIDAD,::oArc:FECHA,2,;
             ::oArd:PCOSTO,::oArd:UNIDADMED )
   PListbox( oLbx,::oArd )
Else
   ::aCab[3] += (::oArd:CANTIDAD * ::oArd:PCOSTO - ::aCab[11] * ::aCab[12])
   If ::aCab[10] # ::oArd:CODIGO .OR. ::aCab[13] # ::oArd:UNIDADMED
      Actualiz( ::aCab[10],-::aCab[11],::oArc:FECHA,2,::aCab[12],::aCab[13] )
      ::aCab[11] := 0
   EndIf
   Guardar( ::oArd,.f.,.t. )
   Actualiz( ::oArd:CODIGO,::oArd:CANTIDAD-::aCab[11],::oArc:FECHA,2,;
             ::oArd:PCOSTO,::oArd:UNIDADMED )
EndIf
::oDlg:Update()
RETURN NIL

//------------------------------------//
METHOD CambiaFec() CLASS TProduc
   LOCAL aFec
If ::oArc:lOK
   aFec := { ::oArc:XColumn( 3 ),::oArc:FECHA,"" }
   oApl:cPer := NtChr( aFec[1],"1" )
   ::oMvc:Seek( {"Empresa",oApl:nEmpresa,"Ano_mes",oApl:cPer,"Fuente",4,;
                 "Comprobant",::oArc:COMPROBANT} )
   aFec[3] := "Empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND Ano_mes = " + xValToChar(oApl:cPer )   +;
         " AND Control = " + LTRIM(STR(::oMvc:CONTROL))
   If (oApl:cPer == LEFT( DTOS(aFec[2]),6 ))
      Guardar( "UPDATE cgemovc SET Fecha = " + xValToChar(aFec[2]) +;
               " WHERE " + aFec[3],"cgemovc" )
      Guardar( ::oArc,.f.,.f. )
   ElseIf MsgYesNo( "QUIERE HACER EL CAMBIO","VA A CAMBIAR DE MES" )
      ::oArd:dbEval( {|o| Actualiz( o:CODIGO,-o:CANTIDAD,aFec[1],o:TIPO,o:PCOSTO,o:UNIDADMED )  ,;
                          Actualiz( o:CODIGO, o:CANTIDAD,aFec[2],o:TIPO,o:PCOSTO,o:UNIDADMED ) },;
                     {"Empresa",oApl:nEmpresa,"Numero",::aCab[1]} )
      If ::oMvc:lOK
         oApl:cPer := NtChr( aFec[2],"1" )
         ::oMvc:COMPROBANT:= SgteCntrl( "Compro_prv",oApl:cPer,.t. )
         ::oMvc:CONTROL   := SgteCntrl( "Control",oApl:cPer,.t. )
         ::oMvc:FECHA     := aFec[2]
         ::oArc:COMPROBANT:= ::oMvc:COMPROBANT
         Guardar( ::oMvc,.f.,.f. )
         ::oMvd:dbEval( {|o| Acumular( ::oMvc:ESTADO,o,5,5,.f.,.f. )            ,;
                             o:ANO_MES := oApl:cPer, o:CONTROL := ::oMvc:CONTROL,;
                             Acumular( ::oMvc:ESTADO,o,2,2,.f.,.f. ) }, aFec[3] )
      EndIf
      Guardar( ::oArc,.f.,.f. )
      MsgInfo( "El cambio de Fecha","HECHO" )
   Else
      ::oArc:FECHA := aFec[2]
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD ComboBrowse( cState,nRow,nCol,oWnd ) CLASS TProduc
   LOCAL oDlg, oBrw, oFont, oRect, nEle, lOk := .f.
   DEFAULT nRow := 0, nCol := 0

   If ValType( oWnd ) = "O"

      oRect := oWnd:GetRect()

      If ValType( nRow ) = "N"
         nRow += oRect:nTop
         nCol += oRect:nLeft
      EndIf

      If ( nEle := ( GetSysMetrics( 1 ) - ( nRow + 254 ) ) ) < 0
         nRow += nEle
      EndIf

      If ( nEle := ( GetSysMetrics( 0 ) - ( nCol + 158 ) ) ) < 0
         nCol += nEle
      EndIf

   Else
      nRow := Nil
   EndIf

   DEFINE FONT oFont NAME "MS Sans Serif" SIZE 0, -10

   DEFINE DIALOG oDlg FROM nRow, nCol TO nRow + 197, nCol + 157 PIXEL ;
          STYLE nOr( WS_VISIBLE, WS_POPUP )

   @0,0 BROWSE oBrw OF oDlg CELLED SIZE 79, 99 PIXEL FONT oFont ;
        ON DBLCLICK ( lOk := .T., oDlg:End() ) ;
        COLORS CLR_WHITE, nRGB(128,0,255)

   oBrw:SetArray( ::oCA:aMed )     // Esto es necesario para trabajar con arrays
   oBrw:aDefault := { SPACE(5), SPACE(30) }

   ADD COLUMN TO BROWSE oBrw DATA ARRAY ELEMENT 2;
       TITLE "Código" ;
       SIZE 40 PIXELS ;
       COLORS CLR_WHITE, nRGB(128,0,255),,, CLR_WHITE, CLR_BLACK

   ADD COLUMN TO BROWSE oBrw DATA ARRAY ELEMENT 1;
       TITLE "Nombre"  ;
       SIZE 500 PIXELS ;
       COLORS CLR_WHITE, nRGB(128,0,255),,, CLR_WHITE, CLR_BLACK

   oBrw:bKeyDown := { | nKey | If( nKey == VK_RETURN .OR. nKey == VK_ESCAPE, ;
                                oDlg:End(), Nil ), lOk := nKey != VK_ESCAPE }
   oBrw:lSeek       := oBrw:lNoHScroll  := oBrw:lNoResetPos := .T.
   oBrw:nLineStyle  := 0
   oBrw:SetColor( { 15 }, { CLR_BLACK } )

   ACTIVATE DIALOG oDlg ;
         ON PAINT ( If( ValType( nRow ) != "N", WndCenter( oDlg:hWnd ), ;
                    oDlg:Move( nRow, nCol ) ) ) ;
         VALID ( oFont:End(), .T. )

RETURN If( lOk, ::oCA:aMed[oBrw:nAt,1], cState )

//------------------------------------//
METHOD Contabil( lG ) CLASS TProduc
   LOCAL aCta := {}, aInf, cSql, nE, nK
If ::oArc:COMPROBANT == 0 .OR. ::aCab[9] .OR. lG
   FOR nE := 1 TO LEN( ::aEnt )
      If !EMPTY( ::aEnt[nE,1] )
         nK := 0
         If ::oArd:Seek( {"Row_id",::aEnt[nE,6]} )
            nK  := ::oArd:CANTIDAD * -1
            If ::oArd:CODIGO # ::aEnt[nE,1] .OR. ::oArd:UNIDADMED # ::aEnt[nE,4]
               Actualiz( ::oArd:CODIGO,nK,::oArc:FECHA,1,::oArd:COSTO,::oArd:UNIDADMED )
               nK := 0
            EndIf
            ::oArd:CODIGO   := ::aEnt[nE,1] ; ::oArd:CANTIDAD := ::aEnt[nE,3]
            ::oArd:UNIDADMED:= ::aEnt[nE,4] ; ::oArd:COSTO    := ::aEnt[nE,5]
            ::oArd:Update( .f.,1 )
         Else
            ::oArd:EMPRESA  := oApl:nEmpresa; ::oArd:NUMERO   := ::oArc:NUMERO
            ::oArd:CODIGO   := ::aEnt[nE,1] ; ::oArd:CANTIDAD := ::aEnt[nE,3]
            ::oArd:UNIDADMED:= ::aEnt[nE,4] ; ::oVen:PCOSTO   := ::aEnt[nE,5]
            ::oArd:TIPO     := 1            ; ::oArd:Append( .t. )
         EndIf
         nK += ::aEnt[nE,3]
         Actualiz( ::oArd:CODIGO,nK,::oArc:FECHA,1,::oArd:COSTO,::oArd:UNIDADMED )
      EndIf
   NEXT nE
/*
   AEVAL( ::aCta, {| x | AADD( aCta, { x[1],"","","","",0,0,0 } ) } )
   aCta[1,6] := ::aCab[3] - ::oArc:TOTALDES
   aCta[2,6] := ::oArc:TOTALFLE
   aCta[3,6] := ::oArc:TOTALIVA
   aCta[4,7] := ::oArc:TOTALFAC - ::oArc:TOTALRET
   aCta[5,7] := ::oArc:TOTALRET
   oApl:cPer := NtChr( ::oArc:FECHA,"1" )
   If ::oMvc:Seek( {"Empresa",oApl:nEmpresa,"Ano_mes",oApl:cPer,"Fuente",4,;
                    "Comprobant",::oArc:COMPROBANT} )
      ::oMvc:CONSECUTIV:= 0
      ::oMvc:ESTADO    := 1
      ::oMvd:dbEval( {|o| o:EMPRESA := -4, Acumular( ::oMvc:ESTADO,o,3,3,.f.,.f. ) },;
                     {"Empresa",oApl:nEmpresa,"Ano_mes",oApl:cPer,;
                      "Control",::oMvc:CONTROL} )
   Else
      ::oMvc:EMPRESA   := oApl:nEmpresa    ; ::oMvc:ANO_MES  := oApl:cPer
      ::oMvc:FECHA     := ::oArc:FECHA  ; ::oMvc:FUENTE   := 4
      ::oMvc:COMPROBANT:= SgteCntrl( "Compro_prv",oApl:cPer,.t. )
      ::oMvc:CONCEPTO  := "FACTURA # " + TRIM(::oArc:FACTURA) + " INGRESO # " + LTRIM(STR(::oArc:INGRESO))
      ::oMvc:CODIGONIT := ::oArc:CODIGO_NIT
      ::oMvc:CONTROL   := SgteCntrl( "Control",oApl:cPer,.t. )
      ::oMvc:ESTADO    := 1
      ::oMvc:Append(.t.)
      ::oArc:COMPROBANT:= ::oMvc:COMPROBANT; ::oArc:Update( .f.,1 )
   EndIf
   FOR nE := 1 TO LEN( aCta )
      If aCta[nE,6] > 0 .OR. aCta[nE,7] > 0
         aInf := Buscar( { "Empresa",oApl:nPuc,"Cuenta",aCta[nE,1] },"cgeplan",;
                           "Infa, Infb, Infc, Infd",8 )
         FOR nK := 1 TO 4
            cSql := TRIM( aInf[nK] )
            do case
            Case cSql == "COD-VAR"
               aCta[nE,nK+1] := aCta[nE,1]
            Case cSql == "DOCUMENTO"
               aCta[nE,nK+1] := ::oArc:FACTURA
            Case cSql == "FECHA"
               aCta[nE,nK+1] := DTOC(::oArc:FECHA)
            Case cSql == "NIT"
               aCta[nE,nK+1] := LTRIM(STR(::aCab[2]))
               aCta[nE,8]    := ::oArc:CODIGO_NIT
            EndCase
         NEXT nK
         ::oMvd:Seek( "Empresa = -4 LIMIT 1","CM" )
         ::oMvd:EMPRESA   := oApl:nEmpresa  ; ::oMvd:ANO_MES  := oApl:cPer
         ::oMvd:CONTROL   := ::oMvc:CONTROL ; ::oMvd:CUENTA   := aCta[nE,1]
         ::oMvd:INFA      := aCta[nE,2]     ; ::oMvd:INFB     := aCta[nE,3]
         ::oMvd:INFC      := aCta[nE,4]     ; ::oMvd:INFD     := aCta[nE,5]
         ::oMvd:VALOR_DEB := aCta[nE,6]     ; ::oMvd:VALOR_CRE:= aCta[nE,7]
         ::oMvd:CODIGO_NIT:= aCta[nE,8]
         Acumular( ::oMvc:ESTADO,::oMvd,2,2,!::oMvd:lOK,.f. )
         ::oMvc:CONSECUTIV ++
      EndIf
   NEXT nE
   ::oMvc:Update(.f.,1)
*/
EndIf
RETURN NIL
