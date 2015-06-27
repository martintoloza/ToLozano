// Programa.: PDLCOREM.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Consulta Remisiones Pendientes. 195
#include "Fivewin.ch"
#include "Btnget.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE CaoCoRem()
   LOCAL oDlg, oLbx, oCaj, oGet := ARRAY(7)
   LOCAL oCR, oNi := TNits()
oCaj := oApl:Abrir( "cadcajac","fechoy, remision, tipo_p",.t.,,50 )
oNi:New()
oNi:oDb:Seek( {"codigo_nit",147} )
oCR := TLRemis()
oCR:aLS := { oNi:oDb:CODIGO,oApl:oEmp:FEC_REM,oApl:oEmp:FEC_REM,0,"" }

DEFINE DIALOG oDlg FROM 0, 0 TO 330, 580 PIXEL;
   TITLE "Consulta Remisiones y Factura" OF oApl:oWnd
   @ 02, 00 SAY "Nit o C.C. del Cliente" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 02, 72 BTNGET oGet[1] VAR oCR:aLS[1] OF oDlg PICTURE "9999999999";
      ACTION EVAL({|| If(oNi:Mostrar(), (oCR:aLS[1] := oNi:oDb:CODIGO,;
                         oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})  ;
      VALID EVAL( {|| If(!oNi:oDb:Seek( {"codigo",oCR:aLS[1]} ),;
                ( MsgStop("Este Cliente no Existe .."),.f.)    ,;
                ( oGet[2]:Settext( oNi:oDb:NOMBRE), .t. )) } )  ;
      SIZE 50,12 PIXEL  RESOURCE "BUSCAR"
   @ 02,126 SAY oGet[2] VAR oCR:aLS[5] OF oDlg PIXEL SIZE 130,12 UPDATE
  //    UPDATE COLOR nRGB( 128,0,255 )
   @ 16, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 16, 72 GET oGet[3] VAR oCR:aLS[2] OF oDlg  SIZE 40,12 PIXEL
   @ 30, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 30, 72 GET oGet[4] VAR oCR:aLS[3] OF oDlg ;
      VALID( If( oCR:aLS[3] < oCR:aLS[2], .f.,;
               ( oCaj:Seek( { "fechoy >= ",oCR:aLS[2],"fechoy <= ",oCR:aLS[3],;
                              "estado <> ",2,"codigo_nit",oNi:oDb:CODIGO_NIT } ),;
                 oLbx:Refresh(), oDlg:Update(),;
                 oLbx:GoBottom(), oGet[4]:oJump := oLbx, .t. ) )) ;
      SIZE 40,12 PIXEL
   @ 30,130 BUTTON oGet[5] PROMPT "&Facturar" SIZE 44,12 OF oDlg ACTION  ;
      (If( oCR:aLS[4] > 0, If( MsgYesNo( "Desea hacer la Factura ?" )      ,;
         (CaoFactu( oCR:aLS[2],oNi:oDb:CODIGO_NIT,"X",oNi:oDb:NOMBRE )),),),;
          oLbx:SetFocus() ) PIXEL
   @ 30,180 BUTTON oGet[6] PROMPT "&Regresar" SIZE 44,12 OF oDlg CANCEL;
      ACTION ( oDlg:End() ) PIXEL
   @ 44, 00 SAY "REMISIONES MARCADAS" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 44, 72 SAY oGet[7] VAR oCR:aLS[4]   OF oDlg PIXEL SIZE 40,12 ;
      UPDATE COLOR nRGB( 255,0,0 )

   @ 62,06 LISTBOX oLbx FIELDS            ;
            STR( oCaj:REMISION )         ,;
                 oCaj:FACTURADO          ,;
      TRANSFORM( oCaj:NUMFAC,"999999" )  ,;
          NtChr( oCaj:FECHOY,"2" )       ,;
      TRANSFORM( oCaj:TOTALFAC,"99,999,999" ),;
      TRANSFORM( oCaj:ABONOS  ,"99,999,999" ),;
      TRANSFORM( oCaj:SALDO   ,"99,999,999" ) ;
      HEADERS "Remisión", "Facturado", "# Factura", "Fecha",;
              "Valor"+CRLF+"Remisión", "Abonos", "Saldo" ;
      SIZES 400, 450 SIZE 280,100 OF oDlg PIXEL ;
      MESSAGE "[Ctrl] M ó [Enter] = Marcar Remision" UPDATE
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:nHeaderHeight := 28
    oLbx:GoTop()
    oLbx:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:aColSizes  := {70,60,70,80,84,84,84}
    oLbx:aHjustify  := {2,2,2,2,2,2,2,2}
    oLbx:aJustify   := {1,2,1,2,1,1,1,1}
    oLbx:bKeyDown := {|nKey| If(nKey == VK_ESCAPE, ( oGet[1]:SetFocus() ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=77 .OR. nKey=VK_RETURN, oCR:MarcaRem( oDlg,oLbx,@oCaj ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, oCR:Borrado( oCaj ),) )) }
    oLbx:ladjbrowse  := oLbx:lCellStyle  := .f.
    oLbx:ladjlastcol := .t.
   MySetBrowse( oLbx,oCaj )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT ;
  (oCaj:Seek( { "fechoy >= ",oCR:aLS[2],"fechoy <= ",oCR:aLS[3],;
                "estado <> ",2,"codigo_nit",oNi:oDb:CODIGO_NIT } ),;
   oDlg:Move(80,1) );
   VALID !GetKeyState(VK_ESCAPE)
oCaj:Destroy()

RETURN

//------------------------------------//
PROCEDURE CaoCoRep( nOpc,aLS )
   LOCAL aDB, oDlg, oLF, oGet := ARRAY(6)
   DEFAULT nOpc := 1
oLF := TLRemis()
aDB := { { {|| oLF:ListoRep() },"Consulta Remisiones Pendientes" },;
         { {|| oLF:ListoRem() },"Ventas por Mostrador" } }
If aLS # NIL
   oLF:aLS := ACLONE( aLS )
   EVAL( aDB[nOpc,1] )
   RETURN
ElseIf nOpc == 2
   aDB[3] := "FECHA ANTERIOR [DD.MM.AA]"
   aDB[4] := "FECHA DE CORTE [DD.MM.AA]"
EndIf
oLF:aLS := { DATE(),DATE(),.f.,"P",0,oApl:nTFor }

DEFINE DIALOG oDlg TITLE aDB[nOpc,2] FROM 0, 0 TO 08,50
   @ 02, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 02, 82 GET oGet[1] VAR oLF:aLS[1] OF oDlg  SIZE 44,10 PIXEL
   @ 14, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 14, 82 GET oGet[2] VAR oLF:aLS[2] OF oDlg ;
      VALID oLF:aLS[2] >= oLF:aLS[1] SIZE 44,10 PIXEL
   @ 14,140 CHECKBOX oGet[3] VAR oLF:aLS[3] PROMPT "Vista &Previa" OF oDlg ;
      SIZE 60,10 PIXEL
   @ 26, 00 SAY "TIPO DE IMPRESORA"   OF oDlg RIGHT PIXEL SIZE 80,10
   @ 26, 82 COMBOBOX oGet[4] VAR oLF:aLS[6] ITEMS { "MS-DOS","Laser" };
      SIZE 48,90 OF oDlg PIXEL

   @ 40, 50 BUTTON oGet[5] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION ;
      ( oGet[5]:Disable(), EVAL( aDB[nOpc,1] ), oGet[5]:Enable(),;
        oGet[5]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 40,100 BUTTON oGet[6] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL ;
      ACTION ( oDlg:End() ) PIXEL
   @ 46, 02 SAY STR(nOpc,1)+"_PDLCOREM" OF oDlg PIXEL SIZE 36,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
CLASS TLRemis FROM TIMPRIME
 DATA aLS, hRes, nL

 METHOD Borrado( oCaj )
 METHOD MarcaRem( oDlg,oLbx,oCaj )
 METHOD ListoRep()
 METHOD LaserRep( aRes,aGT )
 METHOD ListoRem()
 METHOD LaserRem( aRes,aGT )
 METHOD Memo( aRes,cQry )
ENDCLASS

//------------------------------------//
METHOD Borrado( oCaj ) CLASS TLRemis
   LOCAL cQry
If ::aLS[2] < oApl:oEmp:FEC_REM
   If MsgNoYes( "Este Día de Remisiones","Quiere Borrar" )
      oCaj:GoTop():Read()
      oCaj:xLoad()
      While !oCaj:Eof()
         If oCaj:FECHOY    == ::aLS[2] .AND.;
           (oCaj:FACTURADO == "S" .OR. oCaj:ESTADO == 2)
            cQry := "DELETE FROM cadcajad WHERE "           +;
                    "fechoy  = " + xValToChar(oCaj:FECHOY)  +;
              " AND remision = " + LTRIM(STR(oCaj:REMISION))+;
              " AND tipo_p  = '" + oCaj:TIPO_P + "'"
            MSQuery( oApl:oMySql:hConnect,cQry )
            cQry := "DELETE FROM cadcajap WHERE " + ;
                    "fecpag = " + xValToChar(oCaj:FECHOY) +;
               " AND numfac = " + LTRIM(STR(oCaj:REMISION))
            MSQuery( oApl:oMySql:hConnect,cQry )
            oCaj:Delete( .f.,1 )
         EndIf
         oCaj:Skip(1):Read()
         oCaj:xLoad()
      EndDo
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD MarcaRem( oDlg,oLbx,oCaj ) CLASS TLRemis
   LOCAL aSw, nSw, nRec := oCaj:Recno()
If oApl:oNit:CODIGO_NIT # 147 .AND.;
   oCaj:FACTURADO $ " X"
   aSw := { "Desmarca","Marca"," ","X" }
   nSw := If( oCaj:FACTURADO == "X", 1, 2 )
   If MsgNoYes( "esta Remision ?",aSw[nSw] )
      ::aLS[4] += If( nSw == 1, -1, 1 )
      oCaj:FACTURADO := aSw[nSw+2]
      oCaj:Update( .t.,1 )
      oCaj:Go( nRec ):Read()
      oCaj:xLoad()
      oLbx:Refresh() ; oDlg:Update()
      oLbx:SetFocus()
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD ListoRep() CLASS TLRemis
   LOCAL aGT := { 0,0,"99,999,999.99" }
   LOCAL aRes, nC, oRpt
If ::aLS[5] > 0
   aRes := " AND c.estado     = 0" +;
           " AND c.codigo_nit = "  + LTRIM(STR(::aLS[5]))
Else
   aRes := " AND c.estado    <> 2" +;
           " AND c.facturado <> 'S'"
EndIf
 aRes := ::Memo( "Remision",aRes )
If (aGT[1] := ::nL) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes )
   RETURN NIL
ElseIf ::aLS[6] == 2
   ::LaserRep( aRes,aGT )
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"REMISIONES PENDIENTES",;
         "DESDE " + NtChr( ::aLS[1],"2" ) + " HASTA " + NtChr( ::aLS[2],"2" ),;
         "    REMISION  ---FECHA---  VALOR REMISION     C L I E N T E" },::aLS[3] )
While ::nL > 0
   If ::aLS[5] > 0
      aRes[4] := ""
   EndIf
   oRpt:Titulo( 78 )
   oRpt:Say( oRpt:nL,05,STR(aRes[1],7) )
   oRpt:Say( oRpt:nL,14,NtChr( aRes[2],"2" ) )
   oRpt:Say( oRpt:nL,28,TRANSFORM(aRes[3],aGT[3]) )
   oRpt:Say( oRpt:nL,46,aRes[4] )
   oRpt:nL++
   aGT[2] += aRes[3]
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
EndDo
MSFreeResult( ::hRes )
   oRpt:Say(  oRpt:nL,01,REPLICATE("_",78) )
   oRpt:Say(++oRpt:nL,02,STR(aGT[1],4) + " REMISIONES :" )
   oRpt:Say( oRpt:nL,28,TRANSFORM( aGT[2],aGT[3] ))
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserRep( aRes,aGT ) CLASS TLRemis
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit,;
             "REMISIONES PENDIENTES"          ,;
             "DESDE "+NtChr( ::aLS[1],"2" ) + " HASTA " + NtChr( ::aLS[2],"2" ),;
             { .T., 3.0,"REMISION" }      , { .F., 3.5,"FECHA" },;
             { .T., 8.1,"VALOR REMISION" }, { .F., 8.5,"C L I E N T E" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[3] ,,,, 2 )
   PAGE
While ::nL > 0
   If ::aLS[5] > 0
      aRes[4] := ""
   EndIf
   ::Cabecera( .t.,0.45 )
   UTILPRN ::oUtil Self:nLinea,03.0 SAY STR(aRes[1],10)             RIGHT
   UTILPRN ::oUtil Self:nLinea,03.2 SAY NtChr( aRes[2],"2" )
   UTILPRN ::oUtil Self:nLinea,08.1 SAY TRANSFORM( aRes[3],aGT[3] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,08.5 SAY aRes[4]
   aGT[2] += aRes[3]
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
EndDo
MSFreeResult( ::hRes )
   ::Cabecera( .t.,0.4,0.60,20 )
   UTILPRN ::oUtil Self:nLinea,02.0 SAY STR( aGT[1],4 ) + " REMISIONES :"
   UTILPRN ::oUtil Self:nLinea,08.1 SAY TRANSFORM( aGT[2],aGT[3] )  RIGHT
   ENDPAGE
IMPRIME END .F.
RETURN NIL

//------------------------------------//
METHOD ListoRem() CLASS TLRemis
   LOCAL aRes, oRpt
   LOCAL aGT := { 0,0,0,0,0,0,0,0,0,"99,999,999.99",;
                  "Efectivo Cheque   T.Debito T.Credito" }
 aRes := ::Memo( "Mostrador" )
If ::nL == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes )
   RETURN NIL
ElseIf ::aLS[6] == 2
   ::LaserRem( aRes,aGT )
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"VENTAS POR MOSTRADOR","EN " +;
           NtChr( ::aLS[1],"3" ), "  REMISION  VALOR REMISION   VAL" +;
           "OR  PAGOS           SALDO REMISION" },::aLS[3] )
While ::nL > 0
   oRpt:Titulo( 76 )
   If aGT[6]  # aRes[1]
      aGT[6] := aRes[1]
      aGT[8] := aRes[2]
      aGT[9] += aRes[2]
      oRpt:Say( oRpt:nL,02,STR(aRes[1],8) )
      oRpt:Say( oRpt:nL,13,TRANSFORM(aRes[2],aGT[10]) )
   EndIf
   aGT[7] := aRes[3] + aRes[4] + aRes[5] + aRes[6]
   aGT[8] -= aGT[7]
   oRpt:Say( oRpt:nL,28,TRANSFORM(aGT[7],aGT[10]) )
   oRpt:Say( oRpt:nL,42, SUBSTR( aGT[11],aRes[7]*9-8,9 ) )
   oRpt:Say( oRpt:nL,53,TRANSFORM(aGT[8],aGT[10]) )
   oRpt:nL ++
   aGT[5] += aGT[7]
   aGT[ aRes[7] ] += aGT[7]
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
EndDo
MSFreeResult( ::hRes )
If aGT[9] > 0
   aGT[6] := aGT[9] - aGT[5]
   aGT[10]:= "9" + aGT[10]
   oRpt:Say(  oRpt:nL,01,REPLICATE("_",76) )
   oRpt:Separator( 1,4 )
   oRpt:Say(  oRpt:nL,01,"GRAN TOTAL" )
   oRpt:Say(  oRpt:nL,12,TRANSFORM(aGT[9],aGT[10]) )
   oRpt:Say(  oRpt:nL,27,TRANSFORM(aGT[5],aGT[10]) )
   oRpt:Say(  oRpt:nL,52,TRANSFORM(aGT[6],aGT[10]) )
   oRpt:nL += 2
   oRpt:Say(  oRpt:nL,10,"Efectivo         Cheques       T.Debitos       T.Credito" )
   oRpt:Say(++oRpt:nL,04,TRANSFORM(aGT[1],aGT[10]) )
   oRpt:Say(  oRpt:nL,20,TRANSFORM(aGT[2],aGT[10]) )
   oRpt:Say(  oRpt:nL,36,TRANSFORM(aGT[3],aGT[10]) )
   oRpt:Say(  oRpt:nL,52,TRANSFORM(aGT[4],aGT[10]) )
EndIf
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserRem( aRes,aGT ) CLASS TLRemis
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit,;
             "VENTAS POR MOSTRADOR"           ,;
             "EN " + NtChr( ::aLS[1],"3" )    ,;
             { .T., 3.0,"REMISION" }   , { .T., 6.5,"VALOR REMISION" },;
             { .T.,10.0,"VALOR PAGOS" }, { .T.,17.0,"SALDO REMISION" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[3] ,,,, 2 )
 ::nMD := 17.0
   PAGE
While ::nL > 0
   ::Cabecera( .t.,0.45 )
   If aGT[6]  # aRes[1]
      aGT[6] := aRes[1]
      aGT[8] := aRes[2]
      aGT[9] += aRes[2]
      UTILPRN ::oUtil Self:nLinea,03.0 SAY STR(aRes[1],10)            RIGHT
      UTILPRN ::oUtil Self:nLinea,06.5 SAY TRANSFORM(aRes[2],aGT[10]) RIGHT
   EndIf
   aGT[7] := aRes[3] + aRes[4] + aRes[5] + aRes[6]
   aGT[8] -= aGT[7]
   UTILPRN ::oUtil Self:nLinea,10.0 SAY TRANSFORM( aGT[7],aGT[10] )   RIGHT
   UTILPRN ::oUtil Self:nLinea,10.2 SAY SUBSTR( aGT[11],aRes[7]*9-8,9 )
   UTILPRN ::oUtil Self:nLinea,17.0 SAY TRANSFORM( aGT[8],aGT[10] )   RIGHT
   aGT[5] += aGT[7]
   aGT[ aRes[7] ] += aGT[7]
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
EndDo
MSFreeResult( ::hRes )
   aGT[6] := aGT[9] - aGT[5]
   aGT[10]:= "9" + aGT[10]
   ::Cabecera( .t.,0.4,1.45,17 )
   UTILPRN ::oUtil Self:nLinea,01.2 SAY "GRAN TOTAL"
   UTILPRN ::oUtil Self:nLinea,06.5 SAY TRANSFORM( aGT[9],aGT[10] )   RIGHT
   UTILPRN ::oUtil Self:nLinea,10.0 SAY TRANSFORM( aGT[5],aGT[10] )   RIGHT
   UTILPRN ::oUtil Self:nLinea,16.7 SAY TRANSFORM( aGT[6],aGT[10] )   RIGHT
   ::nLinea += 0.60
   UTILPRN ::oUtil Self:nLinea,06.5 SAY "Efectivo"                    RIGHT
   UTILPRN ::oUtil Self:nLinea,10.0 SAY "Cheques"                     RIGHT
   UTILPRN ::oUtil Self:nLinea,13.5 SAY "T.Debitos"                   RIGHT
   UTILPRN ::oUtil Self:nLinea,17.0 SAY "T.Credito"                   RIGHT
   ::nLinea += 0.45
   UTILPRN ::oUtil Self:nLinea,06.5 SAY TRANSFORM( aGT[1],aGT[10] )   RIGHT
   UTILPRN ::oUtil Self:nLinea,10.0 SAY TRANSFORM( aGT[2],aGT[10] )   RIGHT
   UTILPRN ::oUtil Self:nLinea,13.5 SAY TRANSFORM( aGT[3],aGT[10] )   RIGHT
   UTILPRN ::oUtil Self:nLinea,17.0 SAY TRANSFORM( aGT[4],aGT[10] )   RIGHT
   ENDPAGE
IMPRIME END .F.
RETURN NIL

//------------------------------------//
METHOD Memo( aRes,cQry ) CLASS TLRemis
If aRes == "Remision"
   cQry := "SELECT c.remision, c.fechoy, c.totalfac, n.nombre " +;
           "FROM cadcajac c LEFT JOIN cadclien n "              +;
            "USING( codigo_nit ) "                              +;
           "WHERE c.fechoy >= " + xValToChar( ::aLS[1] )        +;
            " AND c.fechoy <= " + xValToChar( ::aLS[2] )        +;
            " AND c.tipo_p  = " + xValToChar( ::aLS[4] )        +;
            cQry +  " ORDER BY c.fechoy, c.remision"
ElseIf aRes == "Mostrador"
   cQry := "SELECT c.remision, c.totalfac, p.abono, p.deduccion, "+;
                  "p.retencion, p.descuento, p.formaPago + 1 "    +;
           "FROM cadcajap p, cadcajac c "                  +;
           "WHERE c.fechoy     = p.fecpag"                 +;
            " AND c.remision   = p.numfac"                 +;
            " AND c.fechoy     = " + xValToChar( ::aLS[1] )+;
            " AND c.codigo_nit = 147 AND c.estado <> 2"    +;
            " ORDER BY c.remision"
/*
cQry := "SELECT c.remision, c.totalfac, p.abono, p.deduccion, "+;
                   "p.retencion, p.descuento, p.formaPago + 1 "+;
        "FROM cadcajac c, cadcajap p "            +;
        "WHERE c.fechoy = " + xValToChar( aLS[1] )+;
     " AND c.codigo_nit = 147 AND c.estado <> 2"  +;
         " AND p.fecpag = c.fechoy"               +;
         " AND p.numfac = c.remision ORDER BY c.remision"
*/
EndIf
::hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) > 0
   aRes := MyReadRow( ::hRes )
   AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( ::hRes,nP ) } )
EndIf
RETURN aRes

//------------------------------------//
PROCEDURE Recupera()
   LOCAL oDlg, oGet := ARRAY(5), aOpc := { 1,DATE(),0 }
   LOCAL aItem := { "Facturas","Remisiones" }
DEFINE DIALOG oDlg TITLE "RECUPERACION" FROM 0, 0 TO 08,46
   @ 02,00 SAY "RECUPERAR"         OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02,92 COMBOBOX oGet[1] VAR aOpc[1] ITEMS aItem SIZE 54,99 ;
      OF oDlg PIXEL
   @ 14,00 SAY "FECHA [DD.MM.AA]"  OF oDlg RIGHT PIXEL SIZE 90,10
   @ 14,92 GET oGet[2] VAR aOpc[2] OF oDlg ;
      WHEN aOpc[1] == 2 SIZE 40,10 PIXEL
   @ 26,00 SAY "NUMERO FACT/REMI"  OF oDlg RIGHT PIXEL SIZE 90,10
   @ 26,92 GET oGet[3] VAR aOpc[3] OF oDlg  SIZE 40,10 PIXEL

   @ 40, 50 BUTTON oGet[4] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[4]:Disable(), ListoCTL( aOpc ), oGet[4]:Enable(),;
        oGet[4]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 40,100 BUTTON oGet[5] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 46, 02 SAY "[PDLCOREM]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT (Empresa() )
RETURN

//------------------------------------//
PROCEDURE ListoCTL( aLS )
   LOCAL cMsg, cQry, hRes, nL
If aLS[1] == 1
   If oApl:oFac:Seek( {"empresa",oApl:nEmpresa,"numfac",aLS[3]} )
      MsgStop( "Esta Factura no Tiene Problemas",">>> OJO <<<" )
      RETURN
   EndIf
   cMsg := "FACTURA"
   cQry := "INSERT INTO cadfactu "+;
           "(empresa, numfac, tipo, fechoy, codigo_nit, totaldes,"   +;
           " totaliva, totalfac, indicador, control) "               +;
           "SELECT 4, d.numfac, d.tipo, d.fecfac, 147, SUM(d.desmon)"+;
           ", SUM(d.montoiva), SUM(d.montoiva+d.precioven), 'P', 0 " +;
           "FROM cadventa d "                              +;
           "WHERE d.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND d.numfac  = " + LTRIM(STR(aLS[3]))       +;
           " GROUP BY d.numfac"
Else
   If Buscar( {"fechoy",aLS[2],"remision",aLS[3]},"cadcajac","1",8,,4 ) == 1
      MsgStop( "Esta Remision Tiene Problemas",">>> OJO <<<" )
      RETURN
   EndIf
   cMsg := "REMISION"
   cQry := "INSERT INTO cadcajac "+;
           "(empresa, remision, tipo, fechoy, codigo_nit, totaldes," +;
           " totaliva, totalfac, estado, tipo_p, facturado, numfac) "+;
           "SELECT 4, d.remision, 'U', d.fechoy, 147, SUM(d.desmon),"+;
           " SUM(d.montoiva), SUM(d.montoiva+d.precioven), 1, d.tipo_p, ' ', 0 "+;
           "FROM cadcajad d "                          +;
           "WHERE d.fechoy   = " + xValToChar( aLS[2] )+;
            " AND d.remision = " +   LTRIM(STR(aLS[3]))+;
           " GROUP BY d.remision"
EndIf
If !MSQuery( oApl:oMySql:hConnect,cQry )
   oApl:oMySql:oError:Display( .f. )
   MsgStop( cMsg+STR(aLS[3]),"No se pudo RECUPERAR" )
Else
   hRes := MSStoreResult( oApl:oMySql:hConnect )
   nL   := MSAffectedRows(oApl:oMySql:hConnect )
   MSFreeResult( hRes )
   If aLS[1] == 1 .AND. nL > 0
      cQry := "UPDATE cadfactu c, cgemovc u "+;
              "SET c.cliente = u.concepto, c.control = u.control "+;
              "WHERE u.empresa    = " + LTRIM(STR(oApl:nEmpresa)) +;
               " AND u.fuente     = 3"                            +;
               " AND u.comprobant = " + LTRIM(STR(aLS[3]))        +;
               " AND c.empresa    = u.empresa"                    +;
               " AND c.numfac     = u.comprobant"                 +;
               " AND c.fechoy     = u.fecha"
//EXTRACT(YEAR_MONTH FROM '1999-07-02 01:02:03')
      MSQuery( oApl:oMySql:hConnect,cQry )
   EndIf
   MsgStop( cMsg+STR(aLS[3]),"RECUPERDA" )
EndIf
RETURN