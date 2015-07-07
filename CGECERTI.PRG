// Programa.: CGECERTI.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Certificado de Ingresos
#include "Fivewin.ch"
#include "btnget.ch"
#INCLUDE "Utilprn.CH"

MEMVAR oApl

PROCEDURE Certific()
   LOCAL oDlg, oGet := ARRAY(10), oA, oNi
   LOCAL aX := { "","" }
 oA := TCerti() ;  oA:New()
oNi := TNits()  ; oNi:New()
DEFINE DIALOG oDlg TITLE oA:aEnc[2] FROM 0, 0 TO 16,76
   @ 02, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 02, 82 GET oGet[1] VAR oA:aLS[1] OF oDlg  SIZE 40,10 PIXEL
   @ 14, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 14, 82 GET oGet[2] VAR oA:aLS[2] OF oDlg ;
      VALID oA:aLS[2] >= oA:aLS[1] SIZE 40,10 PIXEL
   @ 26,00 SAY "NIT INICIAL" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 26,82 BTNGET oGet[3] VAR oA:aLS[3] OF oDlg PICTURE "9999999999" ;
      VALID EVAL( {|| If( EMPTY( oA:aLS[3] ), .t.                   ,;
              (If( oNi:oDb:Seek( { "codigo",oA:aLS[3] } )           ,;
              ( aX[1] := oNi:oDb:NOMBRE, oDlg:Update(), .t. )       ,;
              ( MsgStop("Este Nit no Existe"),.f.)))) } )            ;
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"                            ;
      ACTION EVAL({|| If(oNi:Mostrar(), (oA:aLS[3] := oNi:oDb:CODIGO,;
                        oGet[3]:Refresh(), oGet[3]:lValid(.f.)),)})
   @ 26,140 SAY aX[1] OF oDlg PIXEL SIZE 160,10 UPDATE COLOR nRGB( 128,0,255 )
   @ 38,00 SAY "NIT   FINAL" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 38,82 BTNGET oGet[4] VAR oA:aLS[4] OF oDlg PICTURE "9999999999" ;
      VALID EVAL( {|| If( EMPTY( oA:aLS[4] ), .t.                   ,;
              (If( oNi:oDb:Seek( { "codigo",oA:aLS[4] } )           ,;
              ( aX[2] := oNi:oDb:NOMBRE, oDlg:Update(), .t. )       ,;
              ( MsgStop("Este Nit no Existe"),.f.)))) } )            ;
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"                            ;
      ACTION EVAL({|| If(oNi:Mostrar(), (oA:aLS[4] := oNi:oDb:CODIGO,;
                        oGet[4]:Refresh(), oGet[4]:lValid(.f.)),)})
   @ 38,140 SAY aX[2] OF oDlg PIXEL SIZE 160,10 UPDATE COLOR nRGB( 128,0,255 )
   @ 50, 00 SAY "FORMA [S/N]" OF oDlg RIGHT PIXEL SIZE 80,10 UPDATE
   @ 50, 82 GET oGet[5] VAR oA:aLS[5] OF oDlg PICTURE "!";
      VALID oA:aLS[5] $ "NS"     SIZE 10,10 PIXEL
   @ 62, 00 SAY "TIPO DE IMPRESORA"   OF oDlg RIGHT PIXEL SIZE 80,10
   @ 62, 82 COMBOBOX oGet[6] VAR oA:aLS[6] ITEMS { "Matriz","Laser" };
      SIZE 48,90 OF oDlg PIXEL
   @ 62,136 CHECKBOX oGet[7] VAR oA:aLS[7] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,10 PIXEL
   @ 74,00 SAY "Escoja la Fuente"  OF oDlg RIGHT PIXEL SIZE 80,10
   @ 74,82 COMBOBOX oGet[8] VAR oA:cFont ITEMS oA:aFont SIZE 80,99 OF oDlg PIXEL;
      WHEN oA:aLS[6] > 1
   @  88,170 BUTTON oGet[09] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[09]:Disable(), oA:ArmarMOV( oDlg ), oDlg:End() ) PIXEL
   @  88,220 BUTTON oGet[10] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 104, 02 SAY "[CGECERTI]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT ( Empresa( .t. ) )
RETURN

//------------------------------------//
CLASS TCerti FROM TIMPRIME

 DATA aLS
 METHOD NEW() Constructor
 METHOD ArmarMOV( oDlg )
 METHOD ListoDOS( oRpt,aIR )
 METHOD ListoWIN( aIR )
ENDCLASS

//------------------------------------//
METHOD NEW() CLASS TCerti
   LOCAL hDC := GetDC( 0 )
 ::aFont:= GetFontNames( hDC )
 ::aLS  := { DATE(),DATE(),1,1,"N",oApl:nTFor,.t. }
 ::aEnc := { .t.,"Certificado de Ingresos y Retenciones","","","","","","" }
 ::aLS[4] := Buscar( "SELECT MAX(codigo) FROM cadclien","CM",,8 )
 ::cFont := "Arial"
RETURN NIL

//------------------------------------//
METHOD ArmarMOV( oDlg ) CLASS TCerti
   LOCAL aRes, cQry, hRes, nL, oRpt
   LOCAL aIR := ::aLS
oDlg:SetText( "POR FAVOR << ESPERE >>" )
Swap( @aIR,3,4 ) //Nit
cQry := "SELECT n.codigo, e.nombre, d.concepto, SUM(d.valornoved) "+;
             ", e.fechaing, e.fechaest, e.estadolab "      +;
        "FROM nomnoved d, nomemple e, cadclien n "         +;
        "WHERE d.empresa   = " + LTRIM(STR(oApl:nEmpresa)) +;
         " AND d.fechahas >= " + xValToChar( ::aLS[1] )    +;
         " AND d.fechahas <= " + xValToChar( ::aLS[2] )    +;
         " AND e.empresa   = d.empresa"                    +;
         " AND e.codigo    = d.codigo"                     +;
         " AND e.codigo_nit = n.codigo_nit"                +;
         " AND n.codigo >= " + LTRIM(STR( aIR[3] ))        +;
         " AND n.codigo <= " + LTRIM(STR( aIR[4] ))        +;
       " GROUP BY n.codigo, d.concepto"                    +;
       " ORDER BY n.codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes ) ; RETURN NIL
EndIf
 ::aEnc[3] := "Año Gravable" + STR(YEAR(::aLS[2]),5 )
 ::aEnc[4] := oApl:oEmp:NIT
 ::aEnc[7] := NtChr( DATE()  ,"7" )
 ::aEnc[8] := NtChr( oApl:oEmp:RESHABIT,"A" )
If ::aLS[6] == 1
   oRpt := TDosPrint()
   oRpt:New( oApl:cPuerto,oApl:cImpres,,::aLS[7],,,66,66 )
   oRpt:nL := 40
   oRpt:nPage ++
   oRpt:SetFont( oRpt:CPINormal,80,2 )
   ::aEnc[2] := PADC( ::aEnc[2],43 )
   ::aEnc[3] := PADC( ::aEnc[3],43 )
Else
   ::Init( ::aEnc[2], .f. ,, !::aLS[7] ,,,, 5 )
EndIf
aRes := MyReadRow( hRes )
AEval( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
aIR := { aRes[1],aRes[2],0,0,0,0,0,0,0,0,0,0 }
While nL > 0
   If Rango( aRes[3],{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,17,34,37,53,54,56,57} )
      // R34. Salarios
      aIR[03] += aRes[4]
   ElseIf Rango( aRes[3],18,22 )
      // R35. Cesantias e Interteses de cesantias
      aIR[04] += aRes[4]
   ElseIf Rango( aRes[3],{23,24,40} )
      // R38. Otros Ingresos originados
      aIR[07] += aRes[4]
   ElseIf Rango( aRes[3],{47,50} )
      // R40. Aportes obligatorios por Salud
      aIR[09] += aRes[4]
   ElseIf Rango( aRes[3],{48,49,51,52} )
      // R41. Aportes obligatorios a Fondos de Pension y Solidaridad Pensional
      aIR[10] += aRes[4]
   ElseIf aRes[3] == 55
      // R42. Aportes voluntarios a Fondos de Pension y cuentas AFC
      aIR[11] += aRes[4]
   ElseIf aRes[3] == 31
      // R43. Retencion en la Fuente por salarios
      aIR[12] += aRes[4]
   EndIF
   If EMPTY(::aEnc[5])
      If aRes[5] > ::aLS[1]
         ::aEnc[5] := NtChr( aRes[5] ,"7" )
      Else
         ::aEnc[5] := NtChr( ::aLS[1],"7" )
      EndIF
      If aRes[6] < ::aLS[2] .AND. aRes[7] == "R"
         ::aEnc[6] := NtChr( aRes[6] ,"7" )
      Else
         ::aEnc[6] := NtChr( ::aLS[2],"7" )
      EndIF
   EndIF
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEval( aRes, {|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aIR[1] # aRes[1]
      aIR[01] := NtChr( STR( aIR[01],10 ),"A" )
      aIR[08] := aIR[03] + aIR[04] + aIR[05] + aIR[06] + aIR[07]
      If ::aLS[6] == 1
         ::ListoDOS( oRpt,aIR )
      Else
         ::ListoWIN( aIR )
      EndIf
      aIR := { aRes[1],aRes[2],0,0,0,0,0,0,0,0,0,0 }
      ::aEnc[5] := ::aEnc[6] := ""
   EndIf
EndDo
MSFreeResult( hRes )
If ::aLS[6] == 1
   oRpt:End()
Else
   IMPRIME END .F.
EndIf
RETURN NIL

//------------------------------------//
METHOD ListoDOS( oRpt,aIR ) CLASS TCerti

If ::aLS[5] == "S"
   oRpt:Say( 12,02,::aEnc[4] )
   oRpt:Say( 14,02,oApl:cEmpresa )
   oRpt:Say( 16,03,"13" )
   oRpt:Say( 16,12,aIR[01] )
   oRpt:Say( 16,07,aIR[02] )
   oRpt:Say( 18,02,::aEnc[5] )
   oRpt:Say( 18,12,::aEnc[6] )
   oRpt:Say( 18,20,::aEnc[7] )
   oRpt:Say( 18,32,oApl:cCiu )
   oRpt:Say( 18,60,::aEnc[8] )

   oRpt:Say( 21,63,TRANSFORM( aIR[03],"99,999,999,999.99") )
   oRpt:Say( 22,63,TRANSFORM( aIR[04],"99,999,999,999.99") )
   oRpt:Say( 23,63,TRANSFORM( aIR[05],"99,999,999,999.99") )
   oRpt:Say( 24,63,TRANSFORM( aIR[06],"99,999,999,999.99") )
   oRpt:Say( 25,63,TRANSFORM( aIR[07],"99,999,999,999.99") )
   oRpt:Say( 26,63,TRANSFORM( aIR[08],"99,999,999,999.99") )
   oRpt:Say( 28,63,TRANSFORM( aIR[09],"99,999,999,999.99") )
   oRpt:Say( 29,63,TRANSFORM( aIR[10],"99,999,999,999.99") )
   oRpt:Say( 30,63,TRANSFORM( aIR[11],"99,999,999,999.99") )
   oRpt:Say( 31,63,TRANSFORM( aIR[12],"99,999,999,999.99") )
   oRpt:NewPage()
Else
   oRpt:Say(  2,00,oRpt:CPILarge+ ::aEnc[2] )
   oRpt:Say(  3,00,oRpt:CPILarge+ ::aEnc[3] )
   oRpt:Say(  5,00,"Retenedor  "+ oApl:oEmp:NIT )
   oRpt:Say(  6,11,oApl:cEmpresa )
   oRpt:SetFont( oRpt:CPICompress,140,2 )
   oRpt:Say(  8,00,"25. Numero documento de Identificacion"+;
             SPACE(10)+"26. Apellidos y nombres" )
   oRpt:Say(  9,00,oRpt:CPINormal+aIR[01] )
   oRpt:Say(  9,35,oRpt:CPINormal+aIR[02] )
   oRpt:Say( 11,05,"Periodo de la Certificacion" )
   oRpt:Say( 11,40,"29. Fecha de Expedicion  30. Lugar donde se practico la retencion" )
   oRpt:Say( 12,00,"27. DE: "+::aEnc[5] )
   oRpt:Say( 12,20,"28. A: " +::aEnc[6] )
   oRpt:Say( 12,47,::aEnc[7] )
   oRpt:Say( 12,69,oApl:cCiu )
   oRpt:Say( 14,30,oRpt:CPINormal+"Concepto de los ingresos" )
   oRpt:Say( 15,00,"34. Salarios (No incluya los valores de las casillas 35 a 38" )
   oRpt:Say( 15,76,oRpt:CPINormal+TRANSFORM( aIR[03],"99,999,999,999.99") )
   oRpt:Say( 16,00,"35. Cesantias e intereses de cesantias efectivamente pagadas en el periodo" )
   oRpt:Say( 16,76,oRpt:CPINormal+TRANSFORM( aIR[04],"99,999,999,999.99") )
   oRpt:Say( 17,00,"36. Gastos de representacion" )
   oRpt:Say( 17,76,oRpt:CPINormal+TRANSFORM( aIR[05],"99,999,999,999.99") )
   oRpt:Say( 18,00,"37. Pensiones de jubilacion, vejez o invalidez" )
   oRpt:Say( 18,76,oRpt:CPINormal+TRANSFORM( aIR[06],"99,999,999,999.99") )
   oRpt:Say( 19,00,"38. Otros ingresos originados en la relacion laboral" )
   oRpt:Say( 19,76,oRpt:CPINormal+TRANSFORM( aIR[07],"99,999,999,999.99") )
   oRpt:Say( 20,00,"39. Total de ingresos brutos (Sume casillas 34 a 38)" )
   oRpt:Say( 20,76,oRpt:CPINormal+TRANSFORM( aIR[08],"99,999,999,999.99") )
   oRpt:Say( 22,30,oRpt:CPINormal+"Concepto de los aportes" )
   oRpt:Say( 23,00,"40. Aportes obligatorios por salud" )
   oRpt:Say( 23,76,oRpt:CPINormal+TRANSFORM( aIR[09],"99,999,999,999.99") )
   oRpt:Say( 24,00,"41. Aportes voluntarios a fondos de pensiones y solidaridad social" )
   oRpt:Say( 24,76,oRpt:CPINormal+TRANSFORM( aIR[10],"99,999,999,999.99") )
   oRpt:Say( 25,00,"42. Aportes voluntarios, a fondos de pensiones y cuentas AFC." )
   oRpt:Say( 25,76,oRpt:CPINormal+TRANSFORM( aIR[11],"99,999,999,999.99") )
   oRpt:Say( 26,00,"43. Valor de la retencion en la fuente por salarios y demas pagos laborales" )
   oRpt:Say( 26,76,oRpt:CPINormal+TRANSFORM( aIR[12],"99,999,999,999.99") )
   oRpt:SetFont( oRpt:CPINormal,80,2 )
   oRpt:Say( 34,00,"Firma del retenedor" )
   oRpt:NewPage()
EndIf
RETURN NIL

//------------------------------------//
METHOD ListoWIN( aIR ) CLASS TCerti

PAGE
   ::Centrar( oApl:cEmpresa,::aFnt[4],1.0 )
   UTILPRN ::oUtil 1.5, 8.2 SAY "NIT: " + oApl:oEmp:Nit
   UTILPRN ::oUtil 1.5,16.4 SAY "HORA: " + AmPm( TIME() )
   ::Centrar( ::aEnc[2],,2.0 )
   UTILPRN ::oUtil 2.0,16.5 SAY "PAGINA" + STR(::nPage,4 )
   ::Centrar( ::aEnc[3],,2.5 )
   UTILPRN ::oUtil 3.0, 1.0 SAY ::aEnc[4]
   UTILPRN ::oUtil 3.5, 2.5 SAY ::aEnc[5]
   UTILPRN ::oUtil 4.0,15.2 SAY "Saldo Anterior" RIGHT
   UTILPRN ::oUtil 4.0,20.2 SAY "-----MOVIMIENTO DEL MES-----" RIGHT
   UTILPRN ::oUtil 4.5, 0.7 SAY "Descripcion"
   UTILPRN ::oUtil 4.5, 6.5 SAY "F e c h a"
   UTILPRN ::oUtil 4.5, 8.2 SAY "TC  DOCUM."
   UTILPRN ::oUtil 4.5,10.0 SAY "INFA/INFC"
   UTILPRN ::oUtil 4.5,11.5 SAY "INFB/INFD"
   UTILPRN ::oUtil 4.5,15.2 SAY ::aEnc[6]        RIGHT
   UTILPRN ::oUtil 4.5,17.7 SAY "DEBITOS"        RIGHT
   UTILPRN ::oUtil 4.5,20.2 SAY "CREDITOS"       RIGHT
   UTILPRN ::oUtil LINEA 5.0,1.0 TO 5.0,20.0 PEN ::oPen
   ::nLinea += .5
ENDPAGE
RETURN NIL