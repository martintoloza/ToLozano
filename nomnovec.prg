// Programa.: NOMNOVEC.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Novedades para la Nomina.
#include "FiveWin.ch"
#include "TSBrowse.ch"
#include "btnget.ch"

MEMVAR oApl

#define CLR_PINK  nRGB( 128, 150, 150) //255, 128, 128
#define CLR_NBLUE nRGB( 128, 128, 192)

PROCEDURE Novedades()
   LOCAL oDlg, oLbx, aColor[ 2 ], lPer := .t., lNoBlink := .f.
   LOCAL oGet := ARRAY(6), nA, oNi, oN, oEp, oCn, nCCos := 1
If (aColor[ 1 ] := GetSysColor( COLOR_INACTIVECAPTION ) ) != ;
   GetSysColor( COLOR_ACTIVECAPTION )
   aColor[ 2 ] := GetSysColor( COLOR_INACTCAPTEXT )
   lNoBlink := .t.
   SBNoBlink()
EndIf
Empresa()
 oN  := TNovedad();  oN:New()
 oEp := TEpl()    ; oEp:New()
 oCn := TCon()    ; oCn:New()
oN:AdicArray()

DEFINE DIALOG oDlg FROM 0, 0 TO 360,560 PIXEL;
   TITLE "Novedades de la Nomina || " + oApl:cEmpresa //OF oApl:oWnd
   @ 16, 00 SAY "EN Mision" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 16, 62 COMBOBOX oGet[1] VAR nCCos ITEMS ArrayCol( oEp:aCCos,1 );
     SIZE 150,99 OF oDlg PIXEL                        ;
     ON CHANGE( oApl:oEpl:cWhere := "Empresa = "     +;
                LTRIM(STR(oApl:nEmpresa))            +;
                " AND Estadolab <> 'R' AND Cencos = "+;
                xValToChar( oEp:aCCos[nCCos,2] ) )
   @ 28, 00 SAY "Fecha   Final" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 28, 62 GET oGet[2] VAR oN:aM[1] OF oDlg SIZE 40,10 PIXEL ;
      WHEN lPer                                               ;
      VALID ( lPer := .f., oN:AdicArray( .f. ), .t. )
   @ 28,106 SAY oGet[3] VAR oN:aM[2] OF oDlg SIZE 34,10 PIXEL
   @ 40, 00 SAY "Código Empleado" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 40, 62 BTNGET oGet[4] VAR oN:aM[3] OF oDlg PICTURE "99999";
      VALID( If( !oEp:oDb:Seek( {"Empresa",oApl:nEmpresa      ,;
                                 "Codigo",oN:aM[3]} )         ,;
               ( MsgStop("Este Empleado no Existe .."),.f.)   ,;
               ( oN:nBasico  := oApl:oEpl:SUELDOACT / 240     ,;
                 oN:nSalario := oN:nGSalario := 0             ,;
                 oN:AdicArray(), oLbx:aArray := oN:aD         ,;
                 oLbx:Refresh(), oLbx:DrawFooters()           ,;
                 oDlg:Update(), oGet[4]:oJump := oLbx, .t. )) );
      SIZE 40,10 PIXEL UPDATE                                  ;
      RESOURCE "BUSCAR"                                        ;
      ACTION EVAL({|| If(oEp:Mostrar(), (oN:aM[3] := oEp:oDb:CODIGO,;
                        oGet[4]:Refresh(), oGet[4]:lValid(.f.)),)})
   @ 40,110 SAY    oGet[5] VAR oApl:oEpl:NOMBRE OF oDlg PIXEL SIZE 130,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 28,142 SAY "Sueldo Actual" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 28,194 SAY oGet[6] VAR oApl:oEpl:SUELDOACT OF oDlg PIXEL SIZE  60,10 ;
      PICTURE "99,999,999" UPDATE COLOR "GR/W"

   @ 60,06 BROWSE oLbx SIZE 240,120 PIXEL OF oDlg CELLED; // CELLED  es requerida
      COLORS CLR_BLACK, CLR_NBLUE                         // para editar Celdas
   oLbx:SetArray( oN:aD )     // Esto es necesario para trabajar con arrays
//   oLbx:nFreeze     := 2
   oLbx:nHeightCell += 4
   oLbx:nHeightHead += 4
   oLbx:bKeyDown := {|nKey| If(nKey=VK_TAB, oLbx:oJump := oN:oG[3],;
                            If(nKey=VK_F3 , oN:Listado( oDlg,oLbx ) ,;
                            If(nKey=VK_F5 , (oN:aM[1] := .t.        ,;
                                 oLbx:KeyDown( VK_DELETE,0 ))       ,;
                            If(nKey=VK_F7 , oN:Iniciar( oDlg,oLbx)  ,;
                            If(nKey=VK_F11, oN:Guardar( oDlg,oLbx ) ,;
                            If(nKey=VK_F8 , (oN:Iniciar( oDlg,oLbx )), )))))) }

   oLbx:SetAppendMode( .t. ) //oN:aM[9] )            // Activando Auto Append Mode
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
                       oN:aM[13] := If( nA > LEN(oN:aD), 0, oN:aD[nA,6] ) };
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
       POSTEDIT { |uVar| If( oLbx:lChanged,;
                  ( oN:VerConcepto( oLbx ), oN:Buscar( ,oLbx ) ), ) };
       WHEN oN:EditArray( oLbx )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 4;
       TITLE "Valor"         PICTURE "99,999,999" ;
       SIZE 100 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       VALID { |uVar| If( uVar >= 0, .t., ;
              (MsgStop("Valor tiene que ser Positivo","<<OJO>>"), .f.)) };
       FOOTER { || TransForm( oN:aM[6], "99,999,999" ) };
       POSTEDIT { |uVar| If( oLbx:lChanged, oN:Buscar( ,oLbx ), ) };
       WHEN oN:EditArray( oLbx )
   // Asignando Valores por defaults para nueva Fila creada con Auto Append.
   oLbx:aDefault := { SPACE(5), SPACE(30), 0, 0, 0, 0, 0, "", .f., 2 }
   oLbx:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbx:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTER ON INIT (oN:Barra( oDlg,oLbx ));
   VALID oN:aM[7]
//   ( Empresa(), oN:Barra( oDlg ) );
RETURN

//------------------------------------//
CLASS TNovedad

 DATA aM, aD, cPer, hRes
 DATA aHoras AS ARRAY INIT { 0,0,0,0,"" }
 DATA nL         INIT 0
 DATA nBasico, nSalario, nGSalario
 DATA oNvc, oNvd

 METHOD NEW() Constructor
 METHOD Iniciar( oDlg,oLbx )
 METHOD AdicArray( cQry,oBot,cCen )
 METHOD EditArray( oLbx )
 METHOD DelArray( oLbx )
 METHOD Buscar( xBuscar,oLbx )
 METHOD VerConcepto( oLbx,nA )
 METHOD DesctoEps( nA,lSalud )
 METHOD DesctoFSP( nA )
 METHOD Ordinaria( nA )
 METHOD Primas( nA,lNav )
 METHOD Prestamo( nA )
 METHOD Retencion( nA )
 METHOD Transporte( nA )
 METHOD Grabar( oDlg,oLbx )
 METHOD Barra( oDlg,oLbx )

ENDCLASS

//------------------------------------//
METHOD New( cQry ) CLASS TNovedad

 oApl:oEpl:cWhere := "Empresa = " + LTRIM(STR(oApl:nEmpresa))
 oApl:oFie:Seek( {"Empresa",oApl:nEmpresa} )
 ::aM   := { oApl:oFie:FECHA_HAS,oApl:oFie:FECHA_DES,1,0,0,0,.f.,,.t.,;
             0,0,"",0,0,0,0 }
If cQry == nil
   ::oNvc := oApl:Abrir( "nomcambc","Empresa, Fechahas, Codigo",,,01 )
   ::oNvd := oApl:Abrir( "nomcambd","Empresa, Fechahas, Codigo",,,15 )
Else
   ::oNvc := oApl:Abrir( "nomnovec","Empresa, Fechahas, Codigo",,,10 )
   ::oNvd := oApl:Abrir( "nomnoved","Empresa, Fechahas, Codigo",,,50 )
EndIf
RETURN NIL

//------------------------------------//
METHOD Iniciar( oDlg,oLbx ) CLASS TNovedad
If oDlg == NIL
   ::oNvc:Destroy()
   ::oNvd:Destroy()
   oApl:oEpl:cWhere := ''
Else
   ::AdicArray()
   oLbx:aArray := ::aD
   oDlg:Update()
   oLbx:SetFocus()
EndIf
RETURN .t.

//------------------------------------//
METHOD AdicArray( cQry,oBot,cCen ) CLASS TNovedad
   LOCAL aRes, hRes, nL
If cQry == nil
   ::aD := {}
   ::oNvc:Seek( {"Empresa",oApl:nEmpresa,"Fechahas",::aM[1],"Codigo",::aM[3]} )
   aRes := "SELECT d.Concepto, c.Nombre, d.Horas, d.Valornoved, c.Clasepd, "+;
           "d.Row_id, c.Ptaje, c.Rutina, c.Gsalario, d.Formaliq "+;
           "FROM " + ::oNvd:cName + " d, nomconce c "            +;
           "WHERE d.Empresa = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND d.Fechahas = "+ xValToChar( ::aM[1] )    +;
            " AND d.Codigo  = " + LTRIM(STR(::aM[3]))      +;
            " AND c.Concepto = d.Concepto ORDER BY d.Concepto"
   hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := ::aM[5] := MSNumRows( hRes )
   While nL > 0
      aRes := MyReadRow( hRes )
      AEval( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      AADD( ::aD,{ aRes[01], aRes[02], aRes[03] ,;
                   aRes[04], aRes[05], aRes[06] ,;
                   aRes[07], aRes[08], aRes[09] , aRes[10]} )
      nL --
   EndDo
   MSFreeResult( hRes )
   If LEN( ::aD ) == 0
      AADD( ::aD,{ 0, SPACE(30), 0, 0, 0, 0, 0, "", .f., 2 } )
   EndIf
   SysRefresh()
Else
   If cQry
      cQry := "SELECT codigo, estadolab, fechaest, fechavac FROM nomemple "+;
              "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))     +;
               " AND codigo  > " + LTRIM(STR(::aM[3]))           +;
               " AND estadolab <> 'R'"  +   If( EMPTY( cCen ), "",;
               " AND cencos = '" + cCen + "'" )                  +;
               " ORDER BY codigo"
      ::hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
                    MSStoreResult( oApl:oMySql:hConnect ), 0 )
      If (::nL := MSNumRows( ::hRes )) > 0
         ::aM[9] := .t.
      Else
         ::aM[3] := 0 ; ::aM[9] := .f.
         oBot:Disable()
      EndIf
   EndIf
   ::cPer := NtChr( ::aM[1],"1" )
   oApl:oFis:Seek( {"Periodoi <= ",::cPer,"Periodof >= ",::cPer} )
   ::cPer += If( DAY(::aM[1]) >= 16, "2", "1" )
   ::aHoras[5] := cCen
EndIf
RETURN NIL

//------------------------------------//
METHOD EditArray( oLbx ) CLASS TNovedad
   LOCAL lEdit := .t., nA := oLbx:nAt, nF
If nA > LEN(::aD)
   nF := If( nA > 2, 1, nA-1 )
   If EMPTY( ::aD[nF,01] ) .OR. oLbx:nCell # 1
      MsgStop( "Primero Digite Código del Concepto","Nuevo" )
      oLbx:nAt   := oLbx:nLen := oLbx:nRowPos := nA
      oLbx:nCell := 1 ; lEdit := .f.
      oLbx:HiliteCell( 1 ) ; oLbx:Refresh(.t.)
      oLbx:DrawSelect()
   EndIf
Else
   If EMPTY( ::aD[nA,01] ) .AND. oLbx:nCell # 1
      MsgStop( "Primero Digite Código del Concepto" )
      oLbx:nCell := 1 ; lEdit := .f.
      oLbx:HiliteCell( 1 ) ; oLbx:Refresh()
   EndIf
EndIf
RETURN lEdit

//------------------------------------//
METHOD DelArray( oLbx ) CLASS TNovedad
   LOCAL cQry, lSi := .f., nA := oLbx:nAt
If ::aM[5] > 0
   If MsgNoYes( "Este Código "+STR(::aD[nA,1]),"Elimina" )
      ::aM[5] --
      cQry := "DELETE FROM nomcambd WHERE Row_id = " + LTRIM(STR(::aD[nA,6]))
      MSQuery( oApl:oMySql:hConnect,cQry )
      lSi := .t.
   EndIf
EndIf
RETURN lSi

//------------------------------------//
METHOD Buscar( xBuscar,oLbx ) CLASS TNovedad
   LOCAL nA, lExiste := nil
If xBuscar == nil
   ::aM[6] := ::nGSalario := 0
   AEval( ::aD, { | e | ::aM[6] += If( e[5] == 1, e[4],  -e[4] ),;
                        ::nGSalario += If( e[9], e[4], 0 ) } )
   oLbx:Refresh() ; oLbx:DrawFooters()
Else
   If oApl:oCon:Seek( {"Concepto",xBuscar} )
      ::aM[11] := xBuscar
      ::aM[12] := oApl:oCon:NOMBRE
      ::aM[13] := oApl:oCon:CLASEPD
      ::aM[14] := oApl:oCon:PTAJE
      ::aM[15] := oApl:oCon:RUTINA
      ::aM[16] := oApl:oCon:GSALARIO
   ElseIf !EMPTY( xBuscar )
      MsgStop( "Este Concepto NO EXISTE !!!",xBuscar )
   EndIf
   lExiste := If( EMPTY( xBuscar ), .f., oApl:oCon:lOK )
EndIf
RETURN lExiste

//------------------------------------//
METHOD VerConcepto( oLbx,nA ) CLASS TNovedad
   LOCAL cRut, nVal
   DEFAULT nA := oLbx:nAt
cRut := UPPER( ALLTRIM(::aD[nA,08]) )
do Case
Case cRut == "ASOCIALES"
   If ::aD[nA,1] == 58      //Aporte Social
      ::aD[nA,4] := ROUND( oApl:oFis:SALARIOMIN * .003,0 )
   ElseIf ::aD[nA,1] == 59  //Cuota Admision
      ::aD[nA,4] := ROUND( oApl:oFis:SALARIOMIN * .002,0 )
   ElseIf ::aD[nA,1] == 60  //Cuota Inicial
      ::aD[nA,4] := ROUND( oApl:oFis:SALARIOMIN * .001,0 )
   EndIf
Case cRut == "DESCTOEPS"
   ::DesctoEps( nA,.t. )
Case cRut == "DESCTOAFP"
   ::DesctoEps( nA,.f. )
Case cRut == "DESCTOFSP"
   ::DesctoFsp( nA )
Case cRut == "INCAPACIDAD"
   If ::aD[nA,3] == 0
      ::aD[nA,3] := MAX( 1,oApl:oEpl:DIAS_EST )
   EndIf
   ::aD[nA,4] := ROUND( ::aD[nA,3] * ::nBasico*8, 0 ) * ::aD[nA,7] / 100
Case cRut == "ORDINARIA"
   ::Ordinaria( nA )
Case cRut == "PRIMAS"
   ::Primas( nA )
Case cRut == "PRESTAMO"
   ::Prestamo( nA )
Case cRut == "RETENCION"
   ::Retencion( nA )
Case cRut == "RETROACTIVO"
   If oApl:oEpl:TIPOLIQ == "Q"
      nVal := oApl:oEpl:SUELDOACT - oApl:oEpl:SUELDOANT
      ::aD[nA,3] := 120
      ::aD[nA,4] := ROUND( nVal/240 * ::aD[nA,3], 0 )
   EndIf
Case cRut == "TRANSPORTE"
   ::Transporte( nA )
Case cRut == "VACACIONES"
   If oApl:oEpl:TIPOLIQ == "Q"
      ::aD[nA,4] := ROUND( ((::nBasico*::aD[nA,3]) *8 * ::aD[nA,7]) / 100, 0 )
   EndIf
Case ::aD[nA,1] == 22 .AND. ::oNvc:RADIO == 1    //Int. Sobre Cesantias
   ::aD[nA,04] := ROUND( oApl:oEpl:SUELDOACT * .12,0 )
EndCase
RETURN NIL

//------------------------------------//
METHOD DesctoEps( nA,lSalud ) CLASS TNovedad
   LOCAL nSeguro := 0, lMin := .t.
   LOCAL nSueldo := oApl:oFis:SALARIOMIN
If lSalud
   If oApl:oEpl:EPS
      nSeguro := oApl:oFis:EPS_TRA
   EndIf
Else
   If oApl:oEpl:AFP
      nSeguro := oApl:oFis:AFP_TRA
   EndIf
EndIf
If oApl:oEpl:SUELDOACT > nSueldo
   lMin    := .f.
   nSueldo := oApl:oEpl:SUELDOACT
EndIf
If ::aD[nA,3] == 0
   ::aD[nA,3] := 15
EndIf
If ::aD[nA,1] == 50 .OR. ::aD[nA,1] == 51 //Retroactivo
   nSueldo -= oApl:oEpl:SUELDOANT
   ::aD[nA,4] := ROUND( nSueldo * nSeguro / 200, 0 )
Else
   If lMin
      nSueldo := nSueldo / 30
   Else
      nSueldo := ::nBasico * 8
   EndIf
   nSueldo *= ::aD[nA,3]
   If ::nGSalario > 0
      ::aD[nA,4] := ROUND( (nSueldo + ::nGSalario) * nSeguro / 100, 0)
    //::aD[nA,4] := ROUND( ( nSueldo / 2 + ::nGSalario ) * nSeguro / 100, 0 )
   Else
      ::aD[nA,4] := ROUND( nSueldo * nSeguro / 100, 0)
    //::aD[nA,4] := ROUND( nSueldo * nSeguro / 200, 0 )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD DesctoFSP( nA ) CLASS TNovedad
   LOCAL nSeguro := 0, nSueldo := oApl:oFis:SALARIOMIN
   LOCAL nTope   := oApl:oFis:SALARIOMIN*oApl:oFie:MINIMOS
   LOCAL cQry, nIntegral, nPtaje := 0
If oApl:oEpl:EPS
   nSeguro := oApl:oFis:EPS_TRA
EndIf
If oApl:oEpl:SUELDOACT > nSueldo
   nSueldo := oApl:oEpl:SUELDOACT
EndIf
If ::aD[nA,1] == 52  //Retroactivo
   nSueldo -= oApl:oEpl:SUELDOANT
EndIf
   nIntegral := nSueldo/2
If DAY( ::aM[1] ) > 15
   If ::nGSalario > 0 .OR. nSueldo >= nTope
      ::nGSalario += ::nSalario
        nIntegral += ::nGSalario
   EndIf
EndIf

If nIntegral >= nTope
   nPtaje := nIntegral / oApl:oFis:SALARIOMIN
   cQry := "WHERE Valori <= " + LTRIM(STR(nPtaje)) +;
            " AND Valorf >= " + LTRIM(STR(nPtaje))
   cQry := "SELECT Ptaje FROM nomfsp "+ cQry +;
            " AND  Ptaje = (SELECT MIN(Ptaje) FROM nomfsp " + cQry + ")"
   nPtaje := Buscar( cQry,"CM","",8 )
   If EMPTY(nPtaje)
      nPtaje := 0
   EndIf
   If nIntegral /oApl:oFie:MINIMOS > oApl:oFis:SALARIOMIN .AND. nSeguro > 0
      nSeguro := oApl:oFis:FSP_FON + nPtaje
   EndIf
// If ::oNvc:RADIO == 2  //Comisiones
//    If ::nGSalario > 0
//       ::aD[nA,4] := ROUND( ::nGSalario * nSeguro / 100, 0 )
//    EndIf
// Else
      If DAY( ::aM[1] ) > 15 .AND. ::nGSalario > 0
         ::aD[nA,4] := ROUND( ( nSueldo / 2 + ::nGSalario ) * nSeguro / 100, 0 )
      Else
         ::aD[nA,4] := ROUND( nSueldo * nSeguro / 200, 0 )
      EndIf
      If nSeguro > 0
          cQry := CTOD( "15"+RIGHT( DTOC(::aM[1]),8 ) )
         ::aD[nA,4] -= ValorConce( ::aM[3],NtChr( LEFT(::cPer,6),"F" ),cQry,12 )
      EndIf
// EndIf
Else
   ::aD[nA,4] := 0
EndIf
RETURN NIL

//------------------------------------//
METHOD Ordinaria( nA ) CLASS TNovedad
   LOCAL nDiafin, nDescanso
If ::aD[nA,3] == 0   //Horas
   If oApl:oEpl:TIPOLIQ == "Q"
      If ::aD[nA,1] == 1
         ::aD[nA,3] := ::aHoras[01]
      ElseIf ::aD[nA,1] == 2
         ::aD[nA,3] := ::aHoras[02]
      EndIf
   EndIf
EndIf
 ::aD[nA,4] := ROUND( ::aD[nA,3] * ::nBasico, 0 ) * ::aD[nA,7] / 100
RETURN NIL

//------------------------------------//
METHOD Primas( nA,lNav ) CLASS TNovedad
   LOCAL aGT := { 180,0,1,2 }
 If oApl:oEpl:TIPOLIQ  == "Q" .AND.;
    oApl:oEpl:ESTADOLAB # "R"
    If MONTH( ::aM[1] ) <= 6
       aGT[3] := CTOD( "01.01."+STR(YEAR(::aM[1]),4) )
       aGT[4] := CTOD( "30.06."+STR(YEAR(::aM[1]),4) )
    Else
       aGT[3] := CTOD( "01.07."+STR(YEAR(::aM[1]),4) )
       aGT[4] := CTOD( "30.12."+STR(YEAR(::aM[1]),4) )
    EndIf
    If oApl:oEpl:FECHAING > aGT[3]
       aGT[1] := Dias( oApl:oEpl:FECHAING,aGT[4] )
    EndIf
    aGT[2] := ValorConce( ::aM[3],aGT[3],aGT[4]+1,;
                          "(3,4,5,6,7,8,34,35,37,40,53,56,57)" )
    aGT[2] := ROUND( aGT[2] / aGT[1] * 30, 0 )
 EndIf

 If oApl:oEpl:TIPOLIQ == "Q"
    If ::aD[nA,3] == 0
       ::aD[nA,3] := aGT[1] / 12
    Else
       aGT[1] := ::aD[nA,3] * 12
    EndIf
    aGT[3] := oApl:oEpl:SUELDOACT
    If aGT[3] <= oApl:oFis:SALARIOMIN * 2
       aGT[3] += oApl:oFis:TRANSPORTE
    EndIf
    aGT[2] += aGT[3]
    ::aD[nA,4] := ROUND( aGT[2] / 360 * aGT[1], 0 )
    //::aD[nA,4] := ROUND ( oApl:oEpl:SUELDOACT / 2 + aGT[2]/12, 0 )
 EndIf
RETURN NIL

//------------------------------------//
METHOD Prestamo( nA ) CLASS TNovedad
   LOCAL cQry, hRes
cQry := "SELECT d.Saldoact, d.Cuotadesc "               +;
        "FROM nomdesfi d, nomtrafi t "                  +;
        "WHERE t.Condes  = " + LTRIM(STR( ::aD[nA,1] )) +;
         " AND d.Empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND d.Codigo  = " + LTRIM(STR( ::aM[3]))     +;
         " AND d.Concepto = t.Concepto"                 +;
         " AND d.Anomes = (SELECT MAX(m.Anomes) FROM nomdesfi m "+;
                          "WHERE m.Empresa  = d.Empresa"         +;
                           " AND m.Codigo   = d.Codigo"          +;
                           " AND m.Concepto = d.Concepto"        +;
                           " AND m.Anomes <= '" + ::cPer + "')"
//        "WHERE t.Empresa = " + LTRIM(STR(oApl:nEmpresa))+;
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If MSNumRows( hRes ) > 0
   cQry := MyReadRow( hRes )
   AEval( cQry, { | xV,nP | cQry[nP] := MyClReadCol( hRes,nP ) } )
   cQry[1]    += If( ::aD[nA,6] == 0, 0, ::aD[nA,4] )
   ::aD[nA,4] := If( cQry[1] > cQry[2], cQry[2], cQry[1] )
EndIf
   MSFreeResult( hRes )
RETURN NIL

//------------------------------------//
METHOD Retencion( nA ) CLASS TNovedad
   LOCAL nValor, nRet
If oApl:oEpl:TIPOLIQ == "Q" .AND. ;
  (oApl:oEpl:SUELDOACT/4) > oApl:oFis:SALARIOMIN
   nValor := oApl:oEpl:SUELDOACT - ROUND(oApl:oEpl:SUELDOACT*30/200,0)
   nRet := Buscar( {"Valormay >= ",nValor,"Valormen <= ",nValor},;
                   "nomreten","valorret",8 )
   If !EMPTY( nRet )
      ::aD[nA,04] := ROUND( nRet/2,0 )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Transporte( nA ) CLASS TNovedad
   LOCAL nDiafin   := DAY(oApl:oEpl:FECHAVAC)
   LOCAL nDiastran := 30, nDescanso := oApl:oFie:DIASDESCAN
If oApl:oEpl:SUELDOACT + ::nSalario + ::nGSalario < oApl:oFis:SALARIOMIN * 2
   If ::aD[nA,3] == 0   //Horas
//   If DAY(::aM[2]) >= 16
      If ::aD[nA,10] == 2
         ::aD[nA,03] := (::aHoras[01] + ::aHoras[02]) / 8
      ElseIf DAY(oApl:oFie:FECHA_DES) >= 16
         ::aD[nA,03] := ::aHoras[04] / 8
      EndIf
   EndIf
   If oApl:oEpl:TIPOLIQ == "Q"
      ::aD[nA,04] := ROUND( oApl:oFis:TRANSPORTE/30 * ::aD[nA,3],0 )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Grabar( oDlg,oLbx ) CLASS TNovedad
   LOCAL lNew := ::oNvc:lOK, nR := 0
If !lNew
   AEval( ::aD, {| e | nR += If( e[1] > 0 .AND. e[4] > 0,  1, 0 ) } )
   If nR > 0
      ::oNvc:EMPRESA  := oApl:nEmpresa ; ::oNvc:FECHAHAS := ::aM[1]
      ::oNvc:CODIGO   := ::aM[3]       ; ::oNvc:Append( .t. )
      ::oNvc:lOK      := .t.
   EndIf
EndIf
FOR nR := 1 TO LEN( ::aD )
   If ::aD[nR,1] > 0 .AND. ::aD[nR,4] > 0
      If ::aD[nR,6] == 0
         ::oNvd:xBlank()
         ::oNvd:EMPRESA  := oApl:nEmpresa ; ::oNvd:FECHAHAS   := ::aM[1]
         ::oNvd:CODIGO   := ::aM[3]       ; ::oNvd:CONCEPTO   := ::aD[nR,1]
         ::oNvd:HORAS    := ::aD[nR,3]    ; ::oNvd:VALORNOVED := ::aD[nR,4]
         ::oNvd:CLASEPD  := ::aD[nR,5]    ; ::oNvd:Append( .f. )
      Else
         ::oNvd:Seek( {"Row_id",::aD[nR,6]} )
         ::oNvd:CONCEPTO   := ::aD[nR,1]  ; ::oNvd:HORAS    := ::aD[nR,3]
         ::oNvd:VALORNOVED := ::aD[nR,4]  ; ::oNvd:CLASEPD  := ::aD[nR,5]
         ::oNvd:Update( .f.,1 )
      EndIf
   EndIf
NEXT nR
If !lNew
   ::Iniciar( oDlg,oLbx )
EndIf
RETURN NIL

//------------------------------------//
METHOD Barra( oDlg,oLbx ) CLASS TNovedad
   LOCAL oBar, oBot := ARRAY(3)
DEFINE BUTTONBAR oBar OF oDlg 3DLOOK SIZE 28,28

DEFINE BUTTON oBot[1] RESOURCE "DEDISCO"  OF oBar NOBORDER;
   TOOLTIP "Grabar (F11)";
   ACTION ::Grabar( oDlg,oLbx )
DEFINE BUTTON oBot[2] RESOURCE "ELIMINAR" OF oBar NOBORDER;
   TOOLTIP "Eliminar (Ctrl+DEL)" ;
   ACTION oLbx:KeyDown( VK_DELETE, 0 )
DEFINE BUTTON oBot[3] RESOURCE "QUIT"     OF oBar NOBORDER;
   TOOLTIP "Salir"    ;
   ACTION (::aM[7] := ::Iniciar(), oDlg:End())    GROUP
 oBar:bRClicked := {|| NIL }
 oBar:bLClicked := {|| NIL }
RETURN oBar

//------------------------------------//
FUNCTION ValorConce( nCod,dFecI,dFecF,uCon )
   LOCAL cQry, hRes, nValor := 0
uCon := If( VALTYPE( uCon ) == "C", "IN " + uCon, "= " + LTRIM(STR(uCon)) )
cQry := "SELECT SUM(Valornoved) FROM nomnoved "        +;
        "WHERE Empresa = "  + LTRIM(STR(oApl:nEmpresa))+;
         " AND Codigo = "   + LTRIM(STR(nCod))         +;
         " AND Fechahas >= "+ xValToChar( dFecI )      +;
         " AND Fechahas <= "+ xValToChar( dFecF )      +;
         " AND Concepto "   + uCon
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If MSNumRows( hRes ) > 0
   cQry   := MyReadRow( hRes )
   nValor := MyClReadCol( hRes,1 )
EndIf
RETURN nValor
