// Programa.: NOMNOVED.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Liquidacion de la Nomina.
#include "FiveWin.ch"
#include "TSBrowse.ch"
#include "btnget.ch"

MEMVAR oApl

#define CLR_PINK  nRGB( 128, 150, 150) //255, 128, 128
#define CLR_NBLUE nRGB( 128, 128, 192)

PROCEDURE Liquida()
   LOCAL oDlg, oLbx, aColor[ 2 ], lPer := .t., lNoBlink := .f.
   LOCAL oGet := ARRAY(10), nA, oNi, oN, oEp, oCn, nCCos := 1
If (aColor[ 1 ] := GetSysColor( COLOR_INACTIVECAPTION ) ) != ;
   GetSysColor( COLOR_ACTIVECAPTION )
   aColor[ 2 ] := GetSysColor( COLOR_INACTCAPTEXT )
   lNoBlink := .t.
   SBNoBlink()
EndIf
Empresa()
 oN  := TNomina() ;  oN:New()
 oEp := TEpl()    ; oEp:New()
 oCn := TCon()    ; oCn:New()
oN:AdicArray()
DEFINE DIALOG oDlg FROM 0, 0 TO 440,540 PIXEL;
   TITLE "Novedades de la Nomina || " + oApl:cEmpresa //OF oApl:oWnd
   @ 16, 00 SAY "EN Mision" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 16, 62 COMBOBOX oGet[9] VAR nCCos ITEMS ArrayCol( oEp:aCCos,1 );
     SIZE 150,99 OF oDlg PIXEL                        ;
     ON CHANGE( oApl:oEpl:cWhere := "empresa = "     +;
                LTRIM(STR(oApl:nEmpresa))            +;
                " AND estadolab <> 'R' AND cencos = "+;
                xValToChar( oEp:aCCos[nCCos,2] ) )
   @ 28, 00 SAY "Fecha Inicial" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 28, 62 SAY oGet[1] VAR oN:aM[2] OF oDlg SIZE 40,12 PIXEL
   @ 40, 00 SAY "Fecha   Final" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 40, 62 GET oGet[2] VAR oN:aM[1] OF oDlg SIZE 40,10 PIXEL;
      WHEN lPer                                              ;
      VALID ( If( oN:aM[1] > oApl:oFie:FECHA_HAS            ,;
                ( MsgStop( NtChr( oApl:oFie:FECHA_HAS,"2" ) ,;
                          "DEBE Cerrar la Quincena" ), .f. ),;
             (oN:New( oEp:aCCos[nCCos,2] ), lPer := .f.     ,;
              oN:AdicArray( .t.,oGet[4],oEp:aCCos[nCCos,2] ),;
              oGet[4]:Enable(), oGet[8]:Enable()            ,;
              Botones( oDlg,4 ), .t. ) ) )
   @ 40,106 COMBOBOX oGet[3] VAR oN:nTLiq ;
      ITEMS { "Quincena","Vacaciones","Liquidacion" };
      SIZE 50,99 OF oDlg PIXEL VALID oN:Iniciar( oGet )
   @ 40,160 BUTTON oGet[4] PROMPT "Siguiente" SIZE 40,10 OF oDlg ACTION;
       (If( !oN:oNvc:lOK .AND. oN:aM[5] > 0                  ,;
        If( MsgNoYes( oApl:oEpl:NOMBRE,"Graba los Datos de" ),;
            oN:Grabar( oDlg,oLbx,.f. ), ), )                 ,;
        oN:Liquida( oDlg,oLbx,.t. ), oLbx:aArray := oN:aD    ,;
        oDlg:Update(), oLbx:SetFocus() ) PIXEL
   @ 52, 00 SAY "Código Empleado" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 52, 62 BTNGET oGet[5] VAR oN:aM[3] OF oDlg PICTURE "99999";
      VALID( If( !oEp:oDb:Seek( {"empresa",oApl:nEmpresa      ,;
                                 "codigo",oN:aM[3]} )         ,;
               ( MsgStop("Este Empleado no Existe .."), .f. ) ,;
               ( If( oN:Liquida( oDlg,oLbx,.f. ), .f.         ,;
                   ( oLbx:aArray := oN:aD, oDlg:Update()      ,;
                     oGet[5]:oJump := oLbx, .t. ) ) ) ) )      ;
      SIZE 40,10 PIXEL UPDATE                                  ;
      RESOURCE "BUSCAR"                                        ;
      ACTION EVAL({|| If(oEp:Mostrar(), (oN:aM[3] := oEp:oDb:CODIGO,;
                         oGet[5]:Refresh() ), )})
   @ 52,110 SAY    oGet[6] VAR oApl:oEpl:NOMBRE OF oDlg PIXEL SIZE 130,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 28,110 SAY "Sueldo Actual" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 28,174 SAY oGet[7] VAR oApl:oEpl:SUELDOACT OF oDlg PIXEL SIZE  60,10 ;
      PICTURE "99,999,999" UPDATE COLOR "GR/W"
   @ 40,210 BUTTON oGet[8] PROMPT "Todos" SIZE 30,10 OF oDlg ACTION;
      ( oGet[8]:Disable(), oN:LiqTodos( oDlg,oLbx ) ,;
        oGet[4]:Disable(), oGet[5]:SetFocus() ) PIXEL
   @ 64, 00 SAY "Notas" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 64, 62 GET oGet[10] VAR oN:oNvc:NOTAS OF oDlg PICTURE "@!";
      VALID( If(oN:oNvc:lOK, oN:oNvc:Update( .f.,1 ), ), .t. ) ;
      SIZE 130,10 PIXEL UPDATE

   @ 78,10 BROWSE oLbx SIZE 240,140 PIXEL OF oDlg CELLED; // CELLED  es requerida
      COLORS CLR_BLACK, CLR_NBLUE                         // para editar Celdas
   oLbx:SetArray( oN:aD )     // Esto es necesario para trabajar con arrays
//   oLbx:nFreeze     := 2
   oLbx:nHeightCell += 4
   oLbx:nHeightHead += 4
   oLbx:bKeyDown := {|nKey| If(nKey=VK_TAB, oLbx:oJump := oGet[3] ,;
                            If(nKey=VK_F3 , ListoVol( {oN:aM[3],oN:aM[3],oN:aM[1],;
                                                 .t.,"","",nCCos,.t.},oEp:aCCos ),;
                            If(nKey=VK_F5 , (oN:aM[1] := .t.       ,;
                                       oLbx:KeyDown( VK_DELETE,0 )),;
                            If(nKey=VK_F7 , oN:Iniciar( oDlg,oLbx) ,;
                            If(nKey=VK_F8 , Resumenc( {nCCos,,oN:aM[1],.t.,0,0,""},;
                                                      oEp:aCCos ),;
                            If(nKey=VK_F9 , NomLiNov( 2,oN:aM[1] ),;
                            If(nKey=VK_F11, oN:Grabar( oDlg,oLbx,.t. ) , ))))))) }
   oLbx:SetAppendMode( .t. )                     // Activando Auto Append Mode
   oLbx:SetDeleteMode( .t.,.f.,{ |nAt,oLbx| oN:DelArray(oLbx) },;
                  {|oLbx| oN:Buscar( ,oLbx ) } ) // lOnOff, lConfirm, bDelete

   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 1;
       TITLE "Código"+CRLF+"Concepto"            ;
       SIZE  70 EDITABLE;          // Esta columna es editable
       3DLOOK TRUE, TRUE, TRUE;    // Celda, Titulo, Footers
       MOVE DT_MOVE_NEXT;          // Cursor pasa a la Sig.Columna editable
       VALID { | uVar| oN:Buscar( uVar,oLbx ) }; // don't want empty rows
       ALIGN DT_LEFT, DT_CENTER  ; // Celda, Titulo, Footer
       PREEDIT {|uVar| oN:aM[11] := uVar, nA := oLbx:nAt ,;
                       oN:aM[13] := If( nA > LEN(oN:aD), 0, oN:aD[nA,7] ) };
       FOOTER { || STR( oLbx:nLen,4 ) + " Items" };
       WHEN oN:EditArray( oLbx )
    oLbx:aColumns[01]:bPostEdit := { |uVar| ;
       oN:aD[nA,01] := oN:aM[11], oN:aD[nA,02] := oN:aM[12],;
       oN:aD[nA,05] := oN:aM[13], oN:aD[nA,07] := oN:aM[14],;
       oN:aD[nA,08] := oN:aM[15], oN:aD[nA,09] := oN:aM[16],;
       oN:VerConcepto( oLbx )   , oN:Buscar( ,oLbx ) }
     // activando BtnGet para la columna 1 y habilitando una Ayuda
    oLbx:SetBtnGet( 1, "Buscar", { | oGet,cVar | If( oCn:Mostrar() ,;
        (cVar := oCn:oDb:CONCEPTO, oGet:cText( cVar ), oGet:Refresh(),;
         oGet:KeyDown( VK_RETURN, 0 )), ) }, 16 )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 2;
       TITLE "Descripción";
       SIZE 230           ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_LEFT, DT_CENTER, DT_RIGHT;
       FOOTER "Total Devengado->"
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 3;
       TITLE "Horas ó"+CRLF+"Dias" PICTURE "999.99";
       SIZE  74 EDITABLE;          // Esta columna es editable
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       POSTEDIT { |uVar| If( oLbx:lChanged, (oN:VerConcepto( oLbx ),;
                  oN:Buscar( ,oLbx ), oN:Diastrab( oLbx,oDlg )), ) };
       WHEN oN:EditArray( oLbx )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 4;
       TITLE "Valor"         PICTURE "99,999,999" ;
       SIZE 110 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       VALID { |uVar| If( uVar >= 0, .t., ;
              (MsgStop("Valor tiene que ser Positivo","<<OJO>>"), .f.)) };
       FOOTER { || TransForm( oN:aM[6], "99,999,999" ) }        ;
       POSTEDIT { |uVar| If( oLbx:lChanged, (oN:Buscar( ,oLbx ),;
                                       oN:Diastrab( oLbx )), ) };
       WHEN oN:EditArray( oLbx )
   // Asignando Valores por defaults para nueva Fila creada con Auto Append.
   oLbx:aDefault := { SPACE(5), SPACE(30), 0, 0, 0, 0, 0, "", .f., 2 }
   oLbx:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbx:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTER ON INIT ;
  (oN:Barra( oDlg,oLbx ), oGet[4]:Disable(), oGet[8]:Disable());
   VALID oN:aM[7]
RETURN

//------------------------------------//
CLASS TNomina FROM TNovedad
 DATA nTLiq      INIT 1
 DATA lFec       INIT .t.
 METHOD NEW( cMis ) Constructor
 METHOD Iniciar( oDlg,oLbx )
 METHOD DelArray( oLbx )
 METHOD Diastrab( oLbx,oDlg )
 METHOD LiqTodos( oDlg,oLbx )
 METHOD Liquida( oDlg,oLbx,lSig )
 METHOD Grabar( oDlg,oLbx,lOK )
 METHOD GrabaSal( nCon,nPago,nMov )
 METHOD Fechas()
 METHOD Dias( oDlg )
 METHOD GHoras()
 METHOD GSalario( dFecI,dFecF )
 METHOD DePlano( oDlg,oLbx )
 METHOD AnulaCpte( oLbx )
 METHOD Barra( oDlg,oLbx )
ENDCLASS

//------------------------------------//
METHOD New( cMis ) CLASS TNomina
    LOCAL hRes
If cMis == nil
   Super:New( "SI" )
   cMis := "SELECT MAX(codigo) FROM nomnovec "            +;
           "WHERE empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND fechahas = " + xValToChar( ::aM[1] )
Else
   If !EMPTY(cMis)
      oApl:oEpl:Seek( {"empresa",oApl:nEmpresa,"cencos",cMis},"codigo" )
   EndIf
   cMis := "SELECT MAX(c.codigo) "                         +;
           "FROM nomnovec c, nomemple e "                  +;
           "WHERE c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
           " AND c.fechahas = " + xValToChar( ::aM[1] )    +;
           " AND e.empresa = c.empresa"                    +;
           " AND e.codigo  = c.codigo"                     +;
           " AND e.cencos  = "  + xValToChar( cMis )
EndIf
   hRes := If( MSQuery( oApl:oMySql:hConnect,cMis ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   If MSNumRows( hRes ) > 0
      cMis := MyReadRow( hRes )
      oApl:oEpl:Seek( {"empresa",oApl:nEmpresa,"codigo",MyClReadCol( hRes,1 )} )
   Else
      oApl:oEpl:GoTop():Read()
      oApl:oEpl:xLoad()
   EndIf
   ::aM[3] := oApl:oEpl:CODIGO
RETURN NIL

//------------------------------------//
METHOD Iniciar( oDlg,oLbx ) CLASS TNomina
If oDlg == NIL
   ::oNvc:Destroy()
   ::oNvd:Destroy()
   oApl:oEpl:cWhere := ''
ElseIf oLbx == NIL
   If ::nTLiq > 2
      oDlg[4]:Disable()
      oDlg[8]:Disable()
   Else
      oDlg[4]:Enable()
      oDlg[8]:Enable()
   EndIf
Else
   ::Liquida( oDlg,oLbx,.t. )
   oLbx:aArray := ::aD
   oDlg:Update()
   oLbx:SetFocus()
EndIf
RETURN .t.

//------------------------------------//
METHOD DelArray( oLbx ) CLASS TNomina
   LOCAL cQry, lSi := .f., nA := oLbx:nAt
If ::aM[5] > 0
   If MsgNoYes( "Este Código "+STR(::aD[nA,1]),"Elimina" )
      ::aM[5] --
      ::GrabaSal( ::aD[nA,1],-::aD[nA,4],1 )
      cQry := "DELETE FROM nomnoved WHERE row_id = " + LTRIM(STR(::aD[nA,6]))
      MSQuery( oApl:oMySql:hConnect,cQry )
      lSi := .t.
   EndIf
EndIf
RETURN lSi

//------------------------------------//
METHOD Diastrab( oLbx,oDlg ) CLASS TNomina
   LOCAL nDia, nR, nA := oLbx:nAt
If ::aD[nA,1] <= 2 .AND. oDlg # NIL
   If !MsgYesNo( "Los dias Trabajados en los demas Items","QUIERE Cambiar" )
      RETURN NIL
   EndIf
   nDia := 0
   AEval( ::aD, {| e | nDia += If( e[1] <= 2, e[3],  0) } )
   nDia := nDia / 8
   FOR nR := 1 TO LEN( ::aD )
      If Rango( ::aD[nR,1],{12,47,48,49} )
         ::aD[nR,3] := nDia
         oApl:oCon:Seek( {"concepto",::aD[nR,1]} )
         ::VerConcepto( oLbx,nR )
      EndIf
   NEXT nR
   ::Buscar( ,oLbx )
ElseIf ::aD[nA,9]
   FOR nR := 1 TO LEN( ::aD )
      If Rango( ::aD[nR,1],{47,48,49} )
         oApl:oCon:Seek( {"concepto",::aD[nR,1]} )
         ::VerConcepto( oLbx,nR )
      EndIf
   NEXT nR
   ::Buscar( ,oLbx )
EndIf
RETURN NIL

//------------------------------------//
METHOD LiqTodos( oDlg,oLbx ) CLASS TNomina
   LOCAL aRes
While ::nL > 0
   aRes := MyReadRow( ::hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   ::nL --
//  09-12-2009 <= 01-12-2009   || 15-12-2009  27-12-2009
   If aRes[2] == "V" .AND. aRes[3] <= ::aM[2]
      LOOP
   Else
      ::aM[3] := aRes[1]
      ::Liquida( oDlg,oLbx,.f. )
      oLbx:aArray := ::aD
      oDlg:Update()
      If ::aM[5] > 0
         ::Grabar( oDlg,oLbx,.f. )
      EndIf
   EndIf
EndDo
RETURN NIL

//------------------------------------//
METHOD Liquida( oDlg,oLbx,lSig ) CLASS TNomina
   LOCAL aRes, cQry, nL, hRes
   DEFAULT lSig := .f.
If ::aM[9] .AND. lSig
   //1.Codigo, 2.Estadolab, 3.Fechaest, 4.Fechavac
   While ::nL > 0
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
      ::nL --
      If aRes[2] == "V" .AND. aRes[3] <= ::aM[2]
         LOOP
      Else
         ::aM[3] := aRes[1]
         EXIT
      EndIf
   EndDo
EndIf
oApl:oEpl:Seek( {"empresa",oApl:nEmpresa,"codigo",::aM[3]} )
::oNvc:Seek( {"empresa",oApl:nEmpresa,"fechahas",::aM[1],"codigo",::aM[3]} )

If oApl:oEpl:ESTADOLAB == "R" .AND. !::oNvc:lOK
   MsgStop( "Esta RETIRADO en " + NtChr( oApl:oEpl:FECHAEST,"2" ),;
             oApl:oEpl:NOMBRE )
   //SetFocus( oDlg:aControls[ 5 ]:hWnd )
   RETURN .t.
EndIf

::nBasico  := oApl:oEpl:SUELDOACT / 240
::nSalario := ::nGSalario := 0
If DAY( ::aM[1] ) > 16
   aRes := CTOD( "15"+ RIGHT( DTOC( ::aM[1] ),8 ) )
   ::nSalario := ::GSalario( aRes )
EndIf
::aM[9] := .t.
::Ghoras()
::AdicArray()

If ::aM[5] == 0
   ::aD := {}
   ::oNvc:RADIO := ::nTLiq
   If ::oNvc:RADIO # 1
      ::Fechas()
   EndIf
//1,2,12,31,47,48,49
   cQry := "SELECT concepto, horas, valornoved, 2 FROM nomcambd "+;
           "WHERE empresa  = " + LTRIM(STR(oApl:nEmpresa))       +;
            " AND fechahas = " + xValToChar( ::aM[1] )           +;
            " AND codigo   = " + LTRIM(STR(::aM[3]))             +;
            " UNION "                                            +;
           "SELECT concepto, 0, 0, formaliq FROM nompades "      +;
           "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))
           //" ORDER BY Concepto"
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   While nL > 0
      cQry := MyReadRow( hRes )
      AEVAL( cQry, { | xV,nP | cQry[nP] := MyClReadCol( hRes,nP ) } )
      oApl:oCon:Seek( {"concepto",cQry[1]} )
      If oApl:oCon:GSALARIO .AND. cQry[3] > 0
         ::nGSalario += cQry[3]
      EndIf
      AADD( ::aD,{ cQry[1]          , oApl:oCon:NOMBRE ,;
                   cQry[2]          , cQry[3]          ,;
                   oApl:oCon:CLASEPD, 0                ,;
                   oApl:oCon:PTAJE  , oApl:oCon:RUTINA , oApl:oCon:GSALARIO, cQry[4] } )
      If cQry[3] == 0
         ::VerConcepto( oLbx,++::aM[5] )
      Else
         ::aM[5] ++
      EndIf
      nL --
   EndDo
   MSFreeResult( hRes )
   cQry := "SELECT t.condes, d.formadesc, d.saldoact, d.cuotadesc, d.hacerdesc, "+;
           "d.fechainic FROM nomdesfi d, nomtrafi t "      +;
           "WHERE d.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND d.codigo = "  + LTRIM(STR( ::aM[3]))     +;
            " AND d.anomes = (SELECT MAX(m.anomes) FROM nomdesfi m "+;
                             "WHERE m.empresa = d.empresa"          +;
                              " AND m.codigo  = d.codigo"           +;
                              " AND m.anomes <= '" + ::cPer + "')"  +;
            " AND d.empresa  = t.empresa"                  +;
            " AND d.concepto = t.concepto ORDER BY t.condes"
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := INT( VAL( RIGHT(::cPer,1) ) )
   cQry := { 0,nL,oApl:oFie:VECES_PAGO }  //,9
   nL   := MSNumRows( hRes )
   While nL > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      If aRes[5] .AND. aRes[6] <= ::aM[1] .AND.;
         oApl:oEpl:TIPOLIQ  == "Q"        .AND.;
         Rango( aRes[2],cQry )
         If aRes[2] # 9
            aRes[3] := If( aRes[3] > aRes[4], aRes[4], aRes[3] )
         EndIF
         oApl:oCon:Seek( {"concepto",aRes[1]} )
         AADD( ::aD,{ aRes[1], oApl:oCon:NOMBRE ,  0 ,;
                      aRes[3], oApl:oCon:CLASEPD     ,;
                      0      , oApl:oCon:PTAJE  , oApl:oCon:RUTINA, .f., 2 } )
      EndIf
      nL --
   EndDo
   MSFreeResult( hRes )
   aRes := {}
   AEVAL( ::aD, { |e| If( e[4] # 0, AADD( aRes,{ e[01],e[02],e[03],e[04],e[05],;
                                                 e[06],e[07],e[08],e[09],e[10] } ), ) } )
   ::aD    := aRes
   If LEN( ::aD ) == 0
      AADD( ::aD,{ 0, SPACE(30), 0, 0, 0, 0, 0, "", .f., 2 } )
   EndIf
   ::aM[5] := LEN( ::aD )
EndIf
  Botones( oDlg,1 )
::Buscar( ,oLbx )
RETURN .f.

//------------------------------------//
METHOD Grabar( oDlg,oLbx,lOK ) CLASS TNomina
   LOCAL cQry, lNew := ::oNvc:lOK, nR := 0
If !lNew
   AEval( ::aD, {| e | nR += If( e[1] > 0 .AND. e[4] > 0,  1, 0 ) } )
   If nR > 0
      ::oNvc:EMPRESA  := oApl:nEmpresa ; ::oNvc:FECHAHAS := ::aM[1]
      ::oNvc:CODIGO   := ::aM[3]       ; ::oNvc:RADIO    := ::nTLiq
      ::oNvc:Append( .t. )
      If ::nTLiq # 1
         oApl:oEpl:FECHAEST  := ::oNvc:FECHAI ; oApl:oEpl:FECHAVAC := ::oNvc:FECHAF
         oApl:oEpl:ESTADOLAB := { oApl:oEpl:ESTADOLAB,"A","V","R" }[::nTLiq]
         oApl:oEpl:Update( .f.,1 )
      Else
         cQry := "UPDATE nomnovec SET fechai = NULL, fechaf = NULL, "+;
                                     "basico = NULL, dias = NULL WHERE row_id = "
         MSQuery( oApl:oMySql:hConnect,cQry+LTRIM(STR(::oNvc:ROW_ID)) )
      EndIf
   EndIf
   If ::lFec
      ::lFec := .F.
      cQry := Buscar( {"empresa",oApl:nEmpresa,"fechahas",::aM[1]},;
                       "nomfecha","row_id",8 )
      If EMPTY(cQry)
         cQry := "INSERT INTO nomfecha VALUES ( null, " +;
                 INF( oApl:nEmpresa,", " ) + INF( ::aM[2],", " ) +;
                 INF( ::aM[1]      ,", null, null )" )
         MSQuery( oApl:oMySql:hConnect,cQry )
      EndIf
   EndIf
EndIf
FOR nR := 1 TO LEN( ::aD )
   If ::aD[nR,1] > 0 .AND. ::aD[nR,4] > 0
      If ::aD[nR,6] == 0
         ::oNvd:xBlank()
         ::oNvd:EMPRESA  := oApl:nEmpresa ; ::oNvd:FECHAHAS   := ::aM[1]
         ::oNvd:CODIGO   := ::aM[3]       ; ::oNvd:CONCEPTO   := ::aD[nR,01]
         ::oNvd:HORAS    := ::aD[nR,03]   ; ::oNvd:VALORNOVED := ::aD[nR,04]
         ::oNvd:CLASEPD  := ::aD[nR,05]   ; ::oNvd:FORMALIQ   := ::aD[nR,10]
         ::oNvd:Append( .t. )
      Else
         ::oNvd:Seek( {"row_id",::aD[nR,6]} )
         ::GrabaSal( ::oNvd:CONCEPTO,-::oNvd:VALORNOVED,1 )
         ::oNvd:CONCEPTO   := ::aD[nR,01] ; ::oNvd:HORAS      := ::aD[nR,03]
         ::oNvd:VALORNOVED := ::aD[nR,04] ; ::oNvd:CLASEPD    := ::aD[nR,05]
         ::oNvd:FORMALIQ   := ::aD[nR,10] ; ::oNvd:Update( .f.,1 )
      EndIf
         ::GrabaSal( ::aD[nR,1],::aD[nR,4],1 )
   EndIf
NEXT nR
If !lNew .AND. lOK
   Botones( oDlg,1 )
   ::Iniciar( oDlg,oLbx )
EndIf
If lOK
   MsgWait( oApl:oEpl:NOMBRE,"GRABE LOS DATOS DE",1 )
EndIf
RETURN NIL

//------------------------------------//
METHOD GrabaSal( nCon,nPago,nMov,nCod ) CLASS TNomina
   LOCAL aCam, cWhe, cQry, hRes
   DEFAULT nCod := ::aM[3]
nCon := Buscar( {"condes",nCon},"nomtrafi","concepto",8 )
If EMPTY( nCon )
   RETURN NIL
EndIf
cQry := "SELECT d.saldoact, d.cuotadesc, d.acumular, d.anomes "  +;
        "FROM nomdesfi d "                                       +;
        "WHERE d.empresa = " + LTRIM(STR(oApl:nEmpresa))         +;
         " AND d.codigo  = " + LTRIM(STR( nCod ))                +;
         " AND d.concepto = "+ LTRIM(STR( nCon ))                +;
         " AND d.anomes = (SELECT MAX(m.anomes) FROM nomdesfi m "+;
                          "WHERE m.empresa  = d.empresa"         +;
                           " AND m.codigo   = d.codigo"          +;
                           " AND m.concepto = d.concepto"        +;
                           " AND m.anomes <= '" + ::cPer + "')"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If MSNumRows( hRes ) > 0
   aCam := MyReadRow( hRes )
   AEVAL( aCam, { | xV,nP | aCam[nP] := MyClReadCol( hRes,nP ) } )
Else
   aCam := { nPago,nPago,.t.,"" }
EndIf
   MSFreeResult( hRes )
If aCam[4] # ::cPer
   cQry := "INSERT INTO nomdesfi VALUES ( null, " +;
           INF( oApl:nEmpresa,", " ) + INF( nCod   ,", " ) +;
           INF( nCon         ,", " ) + INF( ::cPer ,", " ) +;
           INF( aCam[1]      ,", " ) + INF( aCam[1],", " ) +;
           INF( aCam[2]      ,", 0, null, 'V', 0, '1' " )  +;
           INF( aCam[3]      ,", null )" )
   MSQuery( oApl:oMySql:hConnect,cQry )
EndIf
cWhe := " WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
          " AND codigo = "  + LTRIM(STR( nCod ))       +;
          " AND concepto = "+ LTRIM(STR( nCon ))       +;
          " AND anomes = '" + ::cPer + "'"
If nMov # 1
   cQry := "UPDATE nomdesfi SET valorcargo = valorcargo + " + LTRIM(STR(nPago)) + cWhe
   MSQuery( oApl:oMySql:hConnect,cQry )
EndIf
If aCam[3]
   nPago*= If( nMov == 1, -1, 1 )
   cQry := "UPDATE nomdesfi SET saldoact = saldoact + " + LTRIM(STR(nPago)) +;
           STRTRAN( cWhe,"mes ","mes >" )
   MSQuery( oApl:oMySql:hConnect,cQry )
EndIf
RETURN NIL

//------------------------------------//
METHOD Fechas() CLASS TNomina
   LOCAL oDlg, oGet := ARRAY(9), aFec := { .f.,0,0, .f.,0,0,0 }, nDia
If !::oNvc:lOK
    ::oNvc:FECHAI := If( ::nTLiq == 2, DATE(), oApl:oEpl:FECHAING )
    ::oNvc:FECHAF := DATE()
EndIf
DEFINE DIALOG oDlg TITLE "Vacaciones o Liquidacion" FROM 0, 0 TO 14,44
   @ 02, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02, 92 GET oGet[1] VAR ::oNvc:FECHAI  OF oDlg  SIZE 40,10 PIXEL
   @ 14, 00 SAY "PROMDIO Dias Trabajados"  OF oDlg RIGHT PIXEL SIZE 90,10
   @ 14, 92 CHECKBOX oGet[2] VAR aFec[1] PROMPT " "  OF oDlg   SIZE 20,10 PIXEL
   @ 26, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 26, 92 GET oGet[3] VAR ::oNvc:FECHAF  OF oDlg ;
      VALID ::Dias( oDlg,@aFec ) SIZE 40,10 PIXEL
   @ 38, 00 SAY "S.BASICO O SUEL.PROMEDIO" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 38, 92 GET oGet[4] VAR ::oNvc:BASICO  OF oDlg PICTURE "99,999,999" UPDATE;
      SIZE 40,10 PIXEL
   @ 50, 00 SAY "DIAS TRABAJADOS"          OF oDlg RIGHT PIXEL SIZE 90,10
   @ 50, 92 GET oGet[5] VAR ::oNvc:DIAS    OF oDlg PICTURE "999,999" UPDATE;
      SIZE 40,10 PIXEL
   @ 62, 00 SAY "DIAS COMPENSACION"        OF oDlg RIGHT PIXEL SIZE 90,10
   @ 62, 92 GET oGet[6] VAR aFec[5]        OF oDlg PICTURE "999,999" UPDATE;
      SIZE 40,10 PIXEL
   @ 74, 00 SAY "PROMEDIO EXTRAS"          OF oDlg RIGHT PIXEL SIZE 90,10
   @ 74, 92 GET oGet[7] VAR aFec[6]        OF oDlg PICTURE "99,999,999" UPDATE;
      SIZE 40,10 PIXEL
   @ 88, 50 BUTTON oGet[8] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( aFec[4] := .t., oDlg:End() ) PIXEL
   @ 88,100 BUTTON oGet[9] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
If !aFec[4]
   RETURN NIL
EndIf
 oGet := {}
 aFec[4] := ::oNvc:BASICO + aFec[6]
 If ::oNvc:RADIO == 2
    AADD( oGet,{ 17, ::oNvc:DIAS, ROUND( (aFec[4] * ::oNvc:DIAS) / 30,0 ) } )
 Else
    aFec[3] := oApl:oFis:SALARIOMIN * oApl:oFie:MINIMOS
    aFec[2] := aFec[4] + If( oApl:oEpl:SUELDOACT > aFec[3], 0, oApl:oFis:TRANSPORTE )
    aFec[7] := CTOD( "01.01"+ RIGHT( DTOC( ::aM[1] ),5 ) )
    //MsgInfo( TRANSFORM( aFec[2],"99,999,999" ) )
    aFec[3] := ROUND( aFec[2] / 360 *aFec[5],0 )
    AADD( oGet,{ 21, aFec[5], aFec[3] } )
    AADD( oGet,{ 22, aFec[5], ROUND( (aFec[3]*.12)/360*aFec[5],0 ) } )
    aFec[3] -= ValorConce( ::aM[3],aFec[7],::aM[1],15 )
    ::oNvc:DIAS := ::oNvc:DIAS / 360 * 15
    AADD( oGet,{ 15, ::oNvc:DIAS, aFec[3] } )
    AADD( oGet,{ 17, ::oNvc:DIAS, ROUND( (aFec[4] * ::oNvc:DIAS) / 30,0 ) } )
 EndIf

 FOR nDia := 1 TO LEN( oGet )
    If oGet[nDia,3] > 0
       oApl:oCon:Seek( {"concepto",oGet[nDia,1]} )
       AADD( ::aD,{ oGet[nDia,1]     , oApl:oCon:NOMBRE ,;
                    oGet[nDia,2]     , oGet[nDia,3]     ,;
                    oApl:oCon:CLASEPD, 0                ,;
                    oApl:oCon:PTAJE  , ""               , oApl:oCon:GSALARIO, 2 } )
    EndIf
 NEXT nDia
RETURN NIL

//------------------------------------//
METHOD Dias( oDlg,aFec ) CLASS TNomina
   LOCAL aDia, dFec, hRes, nL, lOK := .f.
//1_Q, 2_V, 3_L
   ::oNvc:BASICO := oApl:oEpl:SUELDOACT
If ::oNvc:FECHAF >= ::oNvc:FECHAI
   If ::oNvc:RADIO == 3
      If aFec[1] .OR. ::oNvc:FECHAF - oApl:oEpl:FECHASUACT < 90
         If aFec[1]
            dFec := ::oNvc:FECHAI
         Else
            dFec := ::oNvc:FECHAF - 180
            If DAY( dFec ) <= 15
               dFec := CTOD( "01" + RIGHT( DTOC( dFec ),8 ) )
            Else
               dFec := CTOD( "16" + RIGHT( DTOC( dFec ),8 ) )
            EndIf
         EndIf
         aDia := "SELECT concepto, SUM(horas), SUM(valornoved) FROM nomnoved "+;
                 "WHERE empresa = "   + LTRIM(STR(oApl:nEmpresa))+;
                  " AND codigo  = "   + LTRIM(STR( ::aM[3] ))    +;
                  " AND fechahas >= "+ xValToChar( dFec )        +;
                  " AND fechahas <= "+ xValToChar(::oNvc:FECHAF) +;
                  " AND concepto IN(1, 2, 13) GROUP BY concepto"
         //MsgInfo( aDia,"TIN" )
         hRes := If( MSQuery( oApl:oMySql:hConnect,aDia ) ,;
                     MSStoreResult( oApl:oMySql:hConnect ), 0 )
         nL   := MSNumRows( hRes )
         ::oNvc:BASICO := ::oNvc:DIAS := 0
         While nL > 0
            aDia := MyReadRow( hRes )
            AEVAL( aDia, { | xV,nP | aDia[nP] := MyClReadCol( hRes,nP ) } )
            If aDia[1] <= 2
               ::oNvc:DIAS += (aDia[2] / 8)
            EndIf
            ::oNvc:BASICO += aDia[3]
            nL --
         EndDo
         MSFreeResult( hRes )
         ::oNvc:BASICO := ROUND( ::oNvc:BASICO / ::oNvc:DIAS * 30,0 )
      EndIf
   EndIf

   dFec := CTOD( "01.01"+ RIGHT( DTOC( ::aM[1] ),5 ) )
   lOK  := .t.
   If oApl:oEpl:FECHAING > dFec
      dFec := oApl:oEpl:FECHAING
   EndIf
   //Dias T
   ::oNvc:DIAS := Dias( ::oNvc:FECHAI,::oNvc:FECHAF )
   //Dias Compensa
   aFec[5]     := Dias( dFec,::oNvc:FECHAF )
   //Promedio
   aDia    := Conce( "Primas" )  //"(3,4,5,6,7,8,34,35,37,40,53,56,57)"
   aFec[6] := ValorConce( ::aM[3],dFec,::aM[1],aDia )
   aFec[6] := ROUND( aFec[6] / aFec[5],0 )
   oDlg:Update()
EndIf
RETURN lOK

//------------------------------------//
METHOD GHoras() CLASS TNomina
   LOCAL cQry, hRes, dFecI, nD, nL
dFecI := NtChr( LEFT(::cPer,6),"F" )
cQry := "SELECT fechahas, concepto, horas FROM nomnoved "+;
        "WHERE empresa = "  + LTRIM(STR(oApl:nEmpresa))  +;
         " AND fechahas >= "+ xValToChar( dFecI )        +;
         " AND fechahas <= "+ xValToChar( ::aM[1] )      +;
         " AND codigo  = "  + LTRIM(STR(::aM[3]))        +;
         " AND concepto IN(1, 2)"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
AFILL( ::aHoras,0,1,4 )
While nL > 0
   cQry := MyReadRow( hRes )
   AEVAL( cQry, { | xV,nP | cQry[nP] := MyClReadCol( hRes,nP ) } )
   nD := If( cQry[1] < ::aM[1], 3, cQry[2] )
   ::aHoras[nD] += cQry[3]
   nL --
EndDo
MSFreeResult( hRes )
If (::aHoras[01] + ::aHoras[02]) == 0
   nD := DAY(oApl:oEpl:FECHAVAC)
   If oApl:oEpl:FECHAVAC >= oApl:oFie:FECHA_DES
      If nD > 15
         nD := (30 - nD)
      Else
         nD := (15 - nD)
      EndIf
   Else
      nD := 15
   EndIf
   nL := oApl:oFie:DIASDESCAN
   If oApl:oEpl:ESTADOLAB == "I"
      If oApl:oEpl:DIAS_EST >= nL
         nD := nD - ( oApl:oEpl:DIAS_EST - nL) * 2
         nL := 0
      Else
         nL -= oApl:oEpl:DIAS_EST
         nD := nD - oApl:oFie:DIASDESCAN
      EndIf
   Else
      nD -= nL
   EndIf
   ::aHoras[01] := nD * 8
   ::aHoras[02] := nL * 8
EndIf
::aHoras[04] := ::aHoras[01] + ::aHoras[02] + ::aHoras[03]
RETURN NIL

//------------------------------------//
METHOD GSalario( dFecI,dFecF ) CLASS TNomina
   LOCAL cQry, hRes, nGSal := 0
   DEFAULT dFecF := dFecI
cQry := "SELECT SUM(d.valornoved) FROM nomnoved d, nomconce c "+;
        "WHERE d.empresa = "  + LTRIM(STR(oApl:nEmpresa))+;
         " AND d.fechahas >= "+ xValToChar( dFecI )      +;
         " AND d.fechahas <= "+ xValToChar( dFecF )      +;
         " AND d.codigo  = "  + LTRIM(STR(::aM[3]))      +;
         " AND c.concepto = d.concepto"                  +;
         " AND c.salario = '1' AND c.automatica = '1'"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If MSNumRows( hRes ) > 0
   cQry := MyReadRow( hRes )
   nGSal:= MyClReadCol( hRes,1 )
EndIf
MSFreeResult( hRes )
RETURN nGSal

//------------------------------------//
METHOD DePlano( oDlg,oLbx ) CLASS TNomina
   LOCAL aDBF, cFile, cRuta, nSB, nF, nX, oRpt
cFile := UPPER( AbrirFile( 2 ) )
cRuta := RIGHT( cFile,3 )
If EMPTY( cFile ) .OR. (cRuta # "PRN" .AND. cRuta # "TXT")
   MsgStop( "No Escogio ningun Archivo o no es un .TXT",cFile )
   RETURN NIL
ElseIf cRuta == "PRN"
   cRuta := cFile
   cFile := STRTRAN( cRuta,"PRN","TXT" )
   RENAME &(cRuta) TO &(cFile)
EndIf
aDBF  := { { "CEL", "C", 160, 0 } }
cRuta := "\" + CURDIR() + "\"
dbCREATE( "ARQUEO",aDbf )
If !AbreDbf( "Tem","ARQUEO",,cRuta,.f. )
   BorraFile( "ARQUEO",{"DBF"},cRuta )
   RETURN NIL
EndIf
APPEND FROM &(cFile) SDF
 aDBF := { .f.,.f.,.f.,2,68,0,0,0,0,.t.,If( EMPTY(::aHoras[5]),;
           "", " AND e.Cencos = '" + ::aHoras[5] + "'" ),0,.f.,0,0 }
 oRpt := TDosPrint()
 oRpt:New( oApl:cPuerto,oApl:cImpres,{"ESTOS NO EXISTEN","POR FAVOR CREELOS"},.t. )
 oRpt:SetFont( oRpt:CPINormal,82,2 )
/*---------------/
         COOEMPRESARIAL                 N¢mina de Personal - PLANILLA DE PAGOS       Sep 15/2006         Pag:     1
Código y Nombre del Empleado                   Centro de Costo                           Identificaci¢n                B sico Neto
383        MONROY MONTESINO WILLIAM        01         ADMINISTRACION                      1125951400                 99,408,000.00
Cargo :    58   OPERADOR DE COMPUTADOR
Concepto Descripci¢n del Concepto           Cant    Vr Devengos   Concepto Descripci¢n del Concepto           Cant    Vr Descuento
 DV01   COMPENSACION                         11.00    149,600.00   DX02   SALUD 02 - COOMEVA EPS               11.00      5,984.00
 DV03   AUX. DE MOVILIZACION                 11.00     17,490.00   DX03   PENSION 06 - PROTECCION              11.00      5,797.00
        Totales                                       167,090.00                                                         11,781.00
        Neto a Pagar  (** Efectivo **)                                                    155,309.00
----------Nuevo Formato                                                                                                       Fecha: 05/12/2008
                                                              COOEMPRESARIAL                                                  Hora: 11:20:02 a.m.
                                                                                                                              Pagina: 1
                                                             Planilla de Pago
  Centro de Costo:        01 ADMINISTRACION
  Contrato:               569                                                                         Periodo:         2008/10/01 a 2008/10/15
  Empleado:               72140060  BARRIOS ECHEVERRIA ALEXANDER JOS                                  Sueldo Basico:   461.500,00
  Cargo:                  42 COBRADOR
  Codigo        Descripción del Concepto            Cantidad          Vr Devengos    Codigo  Descripción del Concepto       Cantidad          Vr Descuentos
  DV01           COMPENSACION                          1.200.00         184.600.00   DX02    SALUD                                 0.00             7.400.00
  DV03           AUX. DE MOVILIZACION                  1.200.00          22.000.00   DX03    PENSION                               0.00             7.400.00
                                                                                     DX76    APORTE SOCIAL MENSUAL                 0.00             1.385.00
                                                                 //123456789012                                                           //1234567890123456
  Totales                                                                206.600.00                                                               16.185.00
  Neto a Pagar en Efectivo: 190.415,00
*/
Tem->(dbGoTop())
While !Tem->(EOF())
   If aDBF[10]
      If SUBSTR( Tem->CEL,62,17 ) == "PLANILLA DE PAGOS"
         If MsgYesNo( SUBSTR( Tem->CEL,86,11 ),"Esta es la Fecha" )
            aDBF[10] := .f.
         Else
            EXIT
         EndIf
      ElseIf SUBSTR( Tem->CEL,62,16 ) == "Planilla de Pago"
         Tem->(dbSkip(2))
         If MsgYesNo( SUBSTR( Tem->CEL,133,11 ),"Esta es la Fecha" )
            aDBF[04] :=  3
            aDBF[05] := 86
            aDBF[10] := .f.
            aDBF[13] := .t.
         Else
            EXIT
         EndIf
      EndIf
      Tem->(dbSkip())
      LOOP
   EndIf
   If SUBSTR( Tem->CEL,10,10 ) == "Nombre del" .OR.;
      SUBSTR( Tem->CEL,03,09 ) == "Empleado:"
      aDBF[1] := aDBF[2] := .t.
      If !aDBF[13]
         Tem->(dbSkip())
         LOOP
      EndIf
   EndIf
   If aDBF[1]
//T1  MsgInfo( LEFT( Tem->CEL,20),"MTL" )
      If aDBF[2]
         If aDBF[13]
            aDBF[6] := NtChr( SUBSTR( Tem->CEL,25,13 ),"N" )
            ::aM[3] := Buscar( "SELECT e.codigo FROM cadclien n, nomemple e " +;
                               "WHERE n.codigo = " + ALLTRIM( aDBF[6] )       +;
                               " AND e.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
                               " AND e.codigo_nit = n.codigo_nit"+aDBF[11],"CM",,8 )
            If EMPTY( ::aM[3] )
               oRpt:Titulo( 80 )
               oRpt:Say(++oRpt:nL,02,SUBSTR( Tem->CEL,37,32 ) +" CC." + aDBF[6] )
               aDBF[1] := aDBF[2] := aDBF[3] := .f.
               ::oNvc:lOK := .t.
//T2           MsgInfo( aDBF[6],"Cedula NO" )
            Else
               If !aDBF[3]
                //nSB :=      STRTRAN( SUBSTR( Tem->CEL,118,14 ),".","" )
                //nSB := VAL( STRTRAN( nSB,",","." ) )
                  nSB := ALLTRIM( SUBSTR( Tem->CEL,112,22 ) )
                  If RIGHT(nSB,3) == ",00"
                     nSB := LEFT( nSB,LEN(nSB)-3 )
                  EndIf
                  nSB := VAL( NtChr( nSB,"N" ) )
                  ::AdicArray()
               EndIf
               aDBF[2] := .f.
//Buscar Vr Devengos y Vr Descuentos
               nX := 1
               While nX == 1
                  If SUBSTR( Tem->CEL,3,6 ) == "Codigo"
                     FOR nF := 20 TO 160
                        If SUBSTR( Tem->CEL,nF,11 ) == "Vr Devengos"
                           aDBF[05] := nF + 14
                           aDBF[14] := nF -  2
                        EndIF
                        If SUBSTR( Tem->CEL,nF,13 ) == "Vr Descuentos"
                           aDBF[15] := nF -  2
                           EXIT
                        EndIF
                     NEXT nF
                     nX := 0
                  Else
                     Tem->(dbSkip())
                  EndIf
               EndDo
               If nX == 0
                  //MsgInfo( STR(aDBF[14])+"Des"+STR(aDBF[15]),"CC." + aDBF[6] )
                  aDBF[3] := !::oNvc:lOK
                  Tem->(dbSkip())
                  LOOP
               EndIf
            EndIf
            oApl:oWnd:SetMsg( SUBSTR( Tem->CEL,37,32 ) )
         ElseIf SUBSTR( Tem->CEL,128,03 ) == ".00"
            aDBF[6] := SUBSTR( Tem->CEL,91,10 )   //Cedula
            ::aM[3] := Buscar( "SELECT e.codigo FROM cadclien n, nomemple e " +;
                               "WHERE n.codigo = " + ALLTRIM( aDBF[6] )       +;
                               " AND e.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
                               " AND e.codigo_nit = n.codigo_nit"+aDBF[11],"CM",,8 )
            If EMPTY( ::aM[3] )
               oRpt:Titulo( 80 )
               oRpt:Say(++oRpt:nL,02,SUBSTR( Tem->CEL,12,32 ) +" CC." + aDBF[6] )
               aDBF[1] := aDBF[2] := aDBF[3] := .f.
               ::oNvc:lOK := .t.
            //   MsgInfo( SUBSTR( Tem->CEL,12,25 ),"No EXiste" )
            Else
               If !aDBF[3]
                  nSB := VAL( STRTRAN( SUBSTR( Tem->CEL,118,13 ),",","" ) )
                  ::AdicArray()
               EndIf
               aDBF[2] := .f.
            EndIf
            oApl:oWnd:SetMsg( SUBSTR( Tem->CEL,12,32 ) )
         EndIf
      ElseIf LEFT( Tem->CEL,8 ) $ "  Codigo,Concepto"
         aDBF[3] := !::oNvc:lOK
         Tem->(dbSkip())
         LOOP
      EndIf
   EndIf
   If aDBF[3]
      FOR nF := 4 TO 5
         aDBF[7] := SUBSTR( Tem->CEL,aDBF[nF],04 )
         cFile   := LEFT(aDBF[7],2)
         If !EMPTY( aDBF[7] ) .AND.;
            (cFile == "DV" .OR. cFile == "DX")
            If aDBF[13]
               If nF == 4
                  aDBF[8] := STRTRAN( SUBSTR( Tem->CEL,aDBF[14]-18,06 ),".","" )
                  If (nX := AT( ":",aDBF[8] )) > 0
                     aDBF[8] := ALLTRIM(  LEFT( aDBF[8],nX-1 )) + "." +;
                                ALLTRIM(SUBSTR( aDBF[8],nX+1 ))
                     aDBF[8] := VAL( aDBF[8] )
                  Else
                     aDBF[8] := VAL( aDBF[8] )
                     If aDBF[8] >= 100
                        aDBF[8] := aDBF[8] / 100
                     EndIf
                  EndIf
                  aDBF[9] := ALLTRIM( SUBSTR( Tem->CEL,aDBF[14],16 ) )
               Else
                  aDBF[9] := ALLTRIM( SUBSTR( Tem->CEL,aDBF[15],18 ) )
               EndIf
                  aDBF[9] := NtChr( aDBF[9],"N","1234567890." )
               If RIGHT(aDBF[9],3) == ".00"
                  aDBF[9] := LEFT( aDBF[9],LEN(aDBF[9])-3 )
               EndIf
                  aDBF[9] :=      STRTRAN( aDBF[9],".","" )
            Else
               aDBF[8] :=     VAL( SUBSTR( Tem->CEL,aDBF[nF]+43,06 ) )
               aDBF[9] := STRTRAN( SUBSTR( Tem->CEL,aDBF[nF]+51,12 ),",","" )
            EndIf
            If Rango( aDBF[7],{"DV01","DV03"} )
               aDBF[8] *= 8
            EndIf
            If Rango( aDBF[7],{"DV53","DV56","DV57"} )  //INCAPACIDAD
               aDBF[8] /= 8
            EndIf
            If !oApl:oCon:Seek( {"zeus",aDBF[7]} )
                oApl:oCon:Seek( {"concepto",If( aDBF[7] == "DV08", 4,;
                                            If( nF == 4, 40, 41 ))} )
            EndIf
//T5        MsgInfo( oApl:oCon:NOMBRE,aDBF[7] )
            AADD( ::aD,{ oApl:oCon:CONCEPTO, oApl:oCon:NOMBRE,;
                         aDBF[8]           , ROUND( VAL(aDBF[9]),0 ),;
                         oApl:oCon:CLASEPD , 0               ,;
                         oApl:oCon:PTAJE   , oApl:oCon:RUTINA, oApl:oCon:GSALARIO, 0 } )
         EndIf
      NEXT nF
      If SUBSTR( Tem->CEL,9,7 ) == "Totales" .OR.;
         SUBSTR( Tem->CEL,3,7 ) == "Totales"
//       MsgInfo( "VOY A GRABAR" )
         ::Grabar( oDlg,oLbx,.f. )
         aDBF[1] := aDBF[2] := aDBF[3] := .f.
         oApl:oEpl:Seek( {"empresa",oApl:nEmpresa,"codigo",::aM[3]} )
         If oApl:oEpl:SUELDOACT # nSB
            oApl:oEpl:SUELDOANT  := oApl:oEpl:SUELDOACT
            oApl:oEpl:FECHASUANT := oApl:oEpl:FECHASUACT
            oApl:oEpl:SUELDOACT  := nSB
            oApl:oEpl:FECHASUACT := ::aM[1]
//            oApl:oEpl:FECHASUACT := CTOD( "01" + SUBSTR( DTOC( ::aM[1] ),3 ) )
            oApl:oEpl:Update( .f.,1 )
            aDBF[12] ++
         EndIf
      EndIf
   EndIf
   Tem->(dbSkip())
EndDo
Tem->(dbCloseArea())
BorraFile( "ARQUEO",{"DBF"},cRuta )
oRpt:NewPage()
oRpt:End()
MsgStop( "A "+STR(aDBF[12],4)+" TRABAJADORES","ACTUALICE SUELDO" )
RETURN NIL

//------------------------------------//
METHOD AnulaCpte( oLbx ) CLASS TNomina
   LOCAL cQry, oDlg, oGet := ARRAY(6), aBD := { 1,15,::aM[1], .f.,"",0,0 }
cQry := Buscar( {"cencos",::aHoras[5]},"cencosto","nombre",8 )
DEFINE DIALOG oDlg TITLE "Modificar "+cQry FROM 0, 0 TO 14,44
   @ .5, 2 RADIO oGet[1] VAR aBD[1] PROMPT "&Cambiar Fecha" ,;
         "&Borrar Concepto", "Borrar &Mision" OF oDlg
   @ 50,00 SAY "CONCEPTO" OF oDlg RIGHT PIXEL SIZE 54,10
   @ 50,56 BTNGET oGet[2] VAR aBD[2] OF oDlg PICTURE "999"           ;
      VALID EVAL( {|| If( oApl:oCon:Seek( {"concepto",aBD[2]} )     ,;
                        ( oGet[3]:Settext( oApl:oCon:NOMBRE), .t. ) ,;
                 ( MsgStop("Este Concepto NO EXISTE !!!"), .f. )) } );
      WHEN aBD[1] <= 2  SIZE 30,10 PIXEL //RESOURCE "BUSCAR"
//      ACTION EVAL({|| If(oCn:Mostrar(), (aBD[2] := oCn:oDb:CONCEPTO,;
//                         oGet[2]:Refresh() ), ) })                   ;
//
   @ 62, 50 SAY oGet[3] VAR aBD[5] OF oDlg PIXEL SIZE 120,10;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 74, 00 SAY "FECHA [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 54,10
   @ 74, 56 GET oGet[4] VAR aBD[3] OF oDlg;
      VALID aBD[3] > ::aM[1]              ;
      WHEN aBD[1] == 1  SIZE 40,10 PIXEL
   @ 88, 50 BUTTON oGet[5] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( aBD[4] := .t., oDlg:End() ) PIXEL
   @ 88,100 BUTTON oGet[6] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
If !aBD[4]
   RETURN NIL
EndIf
aBD[5] := If( EMPTY(::aHoras[5]), "",;
             " AND e.cencos = '" + ::aHoras[5] + "'" )
If aBD[1] == 1
   cQry := "UPDATE nomnoved d, nomemple e "                +;
            "SET d.fechahas = " + xValToChar( aBD[3] )     +;
          " WHERE e.empresa = " + LTRIM(STR(oApl:nEmpresa))+ aBD[5] +;
            " AND d.empresa  = e.empresa"                  +;
            " AND d.codigo   = e.codigo"                   +;
            " AND d.fechahas = " + xValToChar( ::aM[1] )   +;
            " AND d.concepto = " + LTRIM(STR( aBD[2] ))
   RunSql1( cQry )
   cQry := "SELECT d.codigo FROM nomnoved d, nomemple e "  +;
           "WHERE e.empresa = " + LTRIM(STR(oApl:nEmpresa))+ aBD[5] +;
            " AND d.empresa  = e.empresa"                  +;
            " AND d.codigo   = e.codigo"                   +;
            " AND d.fechahas = " + xValToChar( aBD[3] )    +;
            " GROUP BY d.codigo"
   aBD[6] := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
                 MSStoreResult( oApl:oMySql:hConnect ), 0 )
   aBD[7] := MSNumRows( aBD[6] )
   While aBD[7] > 0
      oGet    :=   MyReadRow( aBD[6] )
      oGet[1] := MyClReadCol( aBD[6],1 )
      If !::oNvc:Seek( {"empresa",oApl:nEmpresa,"fechahas",aBD[3],"codigo",oGet[1]} )
         ::oNvc:EMPRESA  := oApl:nEmpresa ; ::oNvc:FECHAHAS := aBD[3]
         ::oNvc:CODIGO   := oGet[1]       ; ::oNvc:RADIO    := 1
         ::oNvc:Append( .f. )
      EndIf
      aBD[7] --
   EndDo
   MSFreeResult( aBD[6] )
   cQry := Buscar( {"empresa",oApl:nEmpresa,"fechahas",aBD[3]},;
                    "nomfecha","row_id",8 )
   If EMPTY(cQry)
         aBD[6] := ::aM[2]
      If LEFT( DTOS( aBD[3] ),6 ) # LEFT( DTOS( ::aM[1] ),6 )
         aBD[6] := CTOD( "01" + RIGHT( DTOC( aBD[3] ),8 ) )
      EndIf
      cQry := "INSERT INTO nomfecha VALUES ( null, " +;
              INF( oApl:nEmpresa,", " ) + INF( aBD[6],", " ) +;
              INF( aBD[3]       ,", null, null )" )
      MSQuery( oApl:oMySql:hConnect,cQry )
   EndIf
ElseIf aBD[1] == 2
   cQry := "UPDATE nomnoved d, nomemple e "                +;
             "SET d.empresa = -9 "                         +;
           "WHERE e.empresa = " + LTRIM(STR(oApl:nEmpresa))+ aBD[5] +;
            " AND d.empresa  = e.empresa"                  +;
            " AND d.codigo   = e.codigo"                   +;
            " AND d.fechahas = " + xValToChar( ::aM[1] )   +;
            " AND d.concepto = " + LTRIM(STR( aBD[2] ))
   RunSql1( cQry )
   cQry := "DELETE FROM nomnoved WHERE empresa = -9"
   MSQuery( oApl:oMySql:hConnect,cQry )
Else
   cQry := "SELECT d.codigo, d.concepto, d.valornoved "+;
           "FROM nomnoved d, nomemple e, nomtrafi t "  +;
           "WHERE e.empresa = " + LTRIM(STR(oApl:nEmpresa))+ aBD[5] +;
            " AND d.empresa  = e.empresa"                  +;
            " AND d.codigo   = e.codigo"                   +;
            " AND d.fechahas = " + xValToChar( ::aM[1] )   +;
            " AND d.concepto = t.condes"
   aBD[6] := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
                 MSStoreResult( oApl:oMySql:hConnect ), 0 )
   aBD[7] := MSNumRows( aBD[6] )
   While aBD[7] > 0
      oGet := MyReadRow( aBD[6] )
      AEVAL( oGet, { | xV,nP | oGet[nP] := MyClReadCol( aBD[6],nP ) } )
      ::GrabaSal( oGet[2],-oGet[3],1,oGet[1] )
      aBD[7] --
   EndDo
   MSFreeResult( aBD[6] )
   cQry := "UPDATE nomnoved d, nomemple e "                +;
             "SET d.empresa = -9 "                         +;
           "WHERE e.empresa = " + LTRIM(STR(oApl:nEmpresa))+ aBD[5] +;
            " AND d.empresa  = e.empresa"                  +;
            " AND d.codigo   = e.codigo"                   +;
            " AND d.fechahas = " + xValToChar( ::aM[1] )
   RunSql1( cQry )
   cQry := STRTRAN( cQry,"nomnoved","nomnovec" )
   MSQuery( oApl:oMySql:hConnect,cQry )
   cQry := "DELETE FROM nomnoved WHERE empresa = -9"
   MSQuery( oApl:oMySql:hConnect,cQry )
   cQry := STRTRAN( cQry,"nomnoved","nomnovec" )
   MSQuery( oApl:oMySql:hConnect,cQry )
   aBD[7] := Buscar( {"empresa",oApl:nEmpresa,"fechahas",::aM[1]},;
                      "nomnoved","COUNT(*)",8 )
   If aBD[7] <= 0
      cQry := "DELETE FROM nomfecha "                       +;
              "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND fechahas = " + xValToChar( ::aM[1] )
      MSQuery( oApl:oMySql:hConnect,cQry )
   EndIf
EndIf
/*
   cQry := "UPDATE nomnoved SET empresa = -9 "            +;
           "WHERE empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND fechahas = " + xValToChar( ::aM[1] )    +;
            " AND codigo   = " + LTRIM(STR( ::aM[3] ))
   ::AdicArray()
   oLbx:aArray := ::aD
DELETE nomnovec c, nomnovec d
FROM nomnovec c, nomnovec d
WHERE c.empresa  = d.empresa
  AND c.codigo   = d.codigo
  AND c.Fechahas = d.Fechahas
  AND c.Empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
  AND c.Codigo   = " + LTRIM(STR( ::aM[3] ))    +;
  AND c.Fechahas = " + xValToChar( ::aM[1] )
*/
RETURN NIL

//------------------------------------//
METHOD Barra( oDlg,oLbx ) CLASS TNomina
   LOCAL oBar, oBot := ARRAY(7)
DEFINE BUTTONBAR oBar OF oDlg 3DLOOK SIZE 28,28

DEFINE BUTTON RESOURCE "DEDISCO" OF oBar NOBORDER TOOLTIP "Grabar [F11]";
   ACTION ::Grabar( oDlg,oLbx,.t. )
DEFINE BUTTON oBot[2] RESOURCE "ELIMINAR" OF oBar NOBORDER ;
   TOOLTIP "Eliminar [Ctrl+DEL]" ;
   ACTION oLbx:KeyDown( VK_DELETE, 0 )
DEFINE BUTTON oBot[3] RESOURCE "PRINT"    OF oBar NOBORDER ;
   TOOLTIP "Imprimir volante [F3]" ;
   ACTION ListoVol( { ::aM[3],::aM[3],::aM[1],.t.,"","" } )
DEFINE BUTTON oBot[4] RESOURCE "ABRIR"    OF oBar NOBORDER ;
   TOOLTIP "Grabar de Archivo Plano" ;
   ACTION ::DePlano( oDlg,oLbx )          GROUP
/*
DEFINE BUTTON oBot[5] RESOURCE "IMPRIMIR" OF oBar NOBORDER ;
   TOOLTIP "Imprimir Resumen [F8]" ;
   ACTION Resumenc( {nCCos,,::aM[1],.t.,0,0,""},oEp:aCCos )
*/
DEFINE BUTTON oBot[5] RESOURCE "PRINTER"  OF oBar NOBORDER ;
   TOOLTIP "Imprimir Liquidacion [F9]" ;
   ACTION NomLiNov( 2,::aM[1] )
DEFINE BUTTON oBot[6] RESOURCE "BORRAR"   OF oBar NOBORDER ;
   TOOLTIP "Cambiar de Fecha a un Concepto" ;
   ACTION ::AnulaCpte( oLbx )             GROUP
DEFINE BUTTON oBot[7] RESOURCE "QUIT"     OF oBar NOBORDER ;
   TOOLTIP "Salir"    ;
   ACTION (::aM[7] := ::Iniciar(), oDlg:End())    GROUP
 oBot[4]:Disable()
 oBar:bRClicked := {|| NIL }
 oBar:bLClicked := {|| NIL }
RETURN oBar
