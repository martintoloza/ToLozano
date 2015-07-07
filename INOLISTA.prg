// Programa.: JVMLIVET.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Total de venta por Cliente.
#include "FiveWin.ch"
#include "Btnget.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE InoLista( nOpc,aLS )
   LOCAL aVT, oDlg, oLF, oGet := ARRAY(9)
   DEFAULT nOpc := 1
oLF := TLAjust()
aVT := { { {|| oLF:ListoAju() },"Listar los Ajustes al Inventario" },;
         { {|| oLF:ListoDev() },"Listar Devoluciones a Proveedores" } }
If aLS # NIL
   oLF:aLS := ACLONE( aLS )
   EVAL( aVT[nOpc,1] )
   RETURN
EndIf
// aLS := { DATE(),DATE(),"C",0,"N","   ",.f. }
oLF:aLS := { NtChr( LEFT( DTOS(DATE()),6 ),"F" ),DATE(),"C",0,"N",oApl:nTFor,.t.,"" }

DEFINE DIALOG oDlg TITLE aVT[nOpc,2] FROM 0, 0 TO 14,50
   @ 02, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 86,10
   @ 02, 88 GET oGet[1] VAR oLF:aLS[1] OF oDlg  SIZE 40,10 PIXEL
   @ 14, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 86,10
   @ 14, 88 GET oGet[2] VAR oLF:aLS[2] OF oDlg ;
      VALID oLF:aLS[2] >= oLF:aLS[1] SIZE 40,10 PIXEL
   @ 26, 00 SAY "A PRECIO COSTO O PUBLICO" OF oDlg RIGHT PIXEL SIZE 86,10
   @ 26, 88 GET oGet[3] VAR oLF:aLS[3] OF oDlg PICTURE "!" ;
      VALID If( oLF:aLS[3] $ "CP", .t., .f. )   SIZE 08,10 PIXEL
   @ 38, 00 SAY     "NUMERO Default Todos" OF oDlg RIGHT PIXEL SIZE 86,10
   @ 38, 88 GET oGet[4] VAR oLF:aLS[4] OF oDlg PICTURE "999999" SIZE 44,10 PIXEL
   @ 50, 00 SAY     "DOCUMENTOS SEPARADOS" OF oDlg RIGHT PIXEL SIZE 86,10
   @ 50, 88 GET oGet[5] VAR oLF:aLS[5] OF oDlg PICTURE "!" ;
      VALID If( oLF:aLS[5] $ "SN", .t., .f. )   SIZE 08,10 PIXEL
   @ 62, 00 SAY "TIPO DE IMPRESORA"    OF oDlg RIGHT PIXEL SIZE 86,10
   @ 62, 88 COMBOBOX oGet[6] VAR oLF:aLS[6] ITEMS { "Matriz","Laser" };
      SIZE 40,90 OF oDlg PIXEL
   @ 62,138 CHECKBOX oGet[7] VAR oLF:aLS[7] PROMPT "Vista Previa" OF oDlg;
       SIZE 60,12 PIXEL
   @ 76, 50 BUTTON oGet[8] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[8]:Disable(), EVAL( aVT[nOpc,1] ), oDlg:End() ) PIXEL
   @ 76,100 BUTTON oGet[9] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 92, 02 SAY "[INOLISTA]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED NOMODAL
RETURN

//------------------------------------//
CLASS TLAjust FROM TIMPRIME

 DATA aLS

 METHOD ListoAju()
 METHOD LaserAju( hRes,nL )
 METHOD ListoDev()
 METHOD LaserDev( hRes,nL )
ENDCLASS

//------------------------------------//
METHOD ListoAju() CLASS TLAjust
   LOCAL oRpt, aLis, hRes, nC, nL, nK, nT
   LOCAL aAju := { 0,0,0,0,0,0,0,0,0,0,"" }, aTip
aLis := "SELECT a.numero, a.fecha, a.codigo, i.descrip, a.cantidad, a.tipo, a.pcosto, "+;
               "a.pventa, t.tipo_ajust, a.unidadmed, i.unidadmed, i.codcon "+;
        "FROM cadtipos t, cadinven i, cadajust a "    +;
        "WHERE t.clase   = 'Ajustes'"                 +;
         " AND a.tipo    = t.tipo"                    +;
         " AND a.codigo  = i.codigo"                  +;
         " AND a.empresa = " + LTRIM(STR(oApl:nEmpresa)) +;
         " AND a.fecha  >= " + xValToChar( ::aLS[1] ) +;
         " AND a.fecha  <= " + xValToChar( ::aLS[2] ) + If( ::aLS[4] > 0,;
         " AND a.numero  = " + LTRIM(STR(::aLS[4])), "" )+;
         " ORDER BY a.numero, a.codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,aLis ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
 ::aLS[4] := 0
If (nL := MSNumRows( hRes )) == 0
   MsgStop( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[6] == 2
   ::LaserAju( hRes,nL )
   RETURN NIL
EndIf
aTip := Buscar( { "clase","Ajustes" },"cadtipos","tipo, nombre, 0, 0",2,"tipo" )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"AJUSTES AL INVENTARIO","",;
          "  NUMERO   F E C H A  C O D I G O-  N O M B R E   D E L   A R T I C "+;
          "U L O---   FALTANTE  SOBRANTE         PRECIO COSTO  PRECIO VENTA"},::aLS[7],1,2 )
While nL > 0
   aLis := MyReadRow( hRes )
   AEVAL( aLis, { | xV,nP | aLis[nP] := MyClReadCol( hRes,nP ) } )
   nT   := aLis[6]
   If aLis[10] # aLis[11]
      aLis[7] := AFormula( aLis[7],aLis[10],aLis[11],aLis[12] )
   EndIf
   If aLis[9] == 6     //AJUSTE_S
      nC := 79 ; nK := 1
   Else
      nC := 89 ; nK := 4
   EndIf
   If ::aLS[5] == "N"
      oRpt:Titulo( 132 )
      If ::aLS[4]  # aLis[1]
         ::aLS[4] := aLis[1]
         oRpt:Say( oRpt:nL,00,STR(aLis[1],8) )
         oRpt:Say( oRpt:nL,09,NtChr( aLis[2],"2" ) )
      EndIf
      oRpt:Say( oRpt:nL, 22,aLis[3] )
      oRpt:Say( oRpt:nL, 36,aLis[4] )
      oRpt:Say( oRpt:nL, nC,TRANSFORM(aLis[05],"9,999.99" ))
      oRpt:Say( oRpt:nL, 98,UMedidas( aLis[10],"" ),6 )
      oRpt:Say( oRpt:nL,107,TRANSFORM(aLis[07],"999,999,999" ))
      oRpt:Say( oRpt:nL,121,TRANSFORM(aLis[07],"999,999,999" ))
      oRpt:nL ++
   EndIf
   aAju[nK]   +=  aLis[5]
   aAju[nK+1] += (aLis[5] * aLis[7])
   aAju[nK+2] += (aLis[5] * aLis[8])
   aTip[nT,3] +=  aLis[5]
   aTip[nT,4] += (aLis[5] * aLis[8])
   nL --
EndDo
oRpt:Titulo( 132 )
oRpt:Say(  oRpt:nL, 00,REPLICATE("_",132),,,1 )
oRpt:Say(++oRpt:nL, 36,"TOTAL FALTANTES",,,1 )
oRpt:Say(  oRpt:nL, 79,TRANSFORM(aAju[1],"9,999.99" ))
oRpt:Say(  oRpt:nL,105,TRANSFORM(aAju[2],"9,999,999,999" ))
oRpt:Say(  oRpt:nL,119,TRANSFORM(aAju[3],"9,999,999,999" ))
oRpt:Say(++oRpt:nL, 36,"TOTAL SOBRANTES",,,1 )
oRpt:Say(  oRpt:nL, 89,TRANSFORM(aAju[4],"9,999.99" ))
oRpt:Say(  oRpt:nL,105,TRANSFORM(aAju[5],"9,999,999,999" ))
oRpt:Say(  oRpt:nL,119,TRANSFORM(aAju[6],"9,999,999,999" ))
oRpt:nL += 2
oRpt:Say( oRpt:nL,14,"RESUMEN DISTRIBUCION CANTIDADES POR CENTRO DE COSTO",,,1 )
FOR nT := 1 TO LEN( aTip )
   If aTip[nT,3] > 0
      oRpt:Say(++oRpt:nL,14,aTip[nT,1],,,1 )
      oRpt:Say(  oRpt:nL,23,aTip[nT,2] )
      oRpt:Say(  oRpt:nL,59,TRANSFORM(aTip[nT,3],"99,999.99" ) )
      oRpt:Say(  oRpt:nL,90,TRANSFORM(aTip[nT,4],"999,999,999" ) )
   EndIf
NEXT
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserAju( hRes,nL ) CLASS TLAjust
   LOCAL aLis, aTip, nC, nK, nT
   LOCAL aAju := { 0,0,0,0,0,0,0,0,0,0,"" }
aTip := Buscar( { "clase","Ajustes" },"cadtipos","tipo, nombre, 0, 0",2,"tipo" )
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit ,;
             "AJUSTES AL INVENTARIO",""        ,;
             { .F., 0.5,"NUMERO" }      , { .F., 2.3,"F E C H A" },;
             { .F., 3.9,"C O D I G O" } , { .F., 5.6,"NOMBRE DEL ARTICULO" },;
             { .T.,13.0,"FALTANTE" }    , { .T.,15.0,"SOBRANTE" } ,;
             { .T.,18.5,"Precio Costo" }, { .T.,20.5,"Precio Venta" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[7] ,,, ::aLS[7], 5 )
 ::nMD := 20.5
  PAGE
While nL > 0
   aLis := MyReadRow( hRes )
   AEVAL( aLis, { | xV,nP | aLis[nP] := MyClReadCol( hRes,nP ) } )
   nT   := aLis[6]
   If aLis[10] # aLis[11]
      aLis[7] := AFormula( aLis[7],aLis[10],aLis[11],aLis[12] )
   EndIf
   If aLis[9] == 6     //AJUSTE_S
      nC := 13.0 ; nK := 1
   Else
      nC := 15.0 ; nK := 4
   EndIf
   If ::aLS[5] == "N"
      ::Cabecera( .t.,0.42 )
      If ::aLS[4]  # aLis[1]
         ::aLS[4] := aLis[1]
         UTILPRN ::oUtil Self:nLinea,1.9 SAY STR(aLis[1],8) RIGHT
         UTILPRN ::oUtil Self:nLinea,2.1 SAY NtChr( aLis[2],"2" )
      EndIf
      UTILPRN ::oUtil Self:nLinea, 3.9 SAY aLis[3]
      UTILPRN ::oUtil Self:nLinea, 5.6 SAY aLis[4]
      UTILPRN ::oUtil Self:nLinea,nC   SAY TRANSFORM( aLis[5],  "9,999.99" )  RIGHT
      UTILPRN ::oUtil Self:nLinea,15.2 SAY LEFT( UMedidas( aLis[10],"" ),6 )
      UTILPRN ::oUtil Self:nLinea,18.5 SAY TRANSFORM( aLis[7],"999,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aLis[8],"999,999,999" ) RIGHT
   EndIf
   aAju[nK]   +=  aLis[5]
   aAju[nK+1] += (aLis[5] * aLis[7])
   aAju[nK+2] += (aLis[5] * aLis[8])
   aTip[nT,3] +=  aLis[5]
   aTip[nT,4] += (aLis[5] * aLis[8])
   nL --
EndDo
MSFreeResult( hRes )
   nL := 1.52
AEVAL( aTip, { | e | nL += If( e[3] > 0, 0.42, 0 ) } )
      ::Cabecera( .t.,0.40,nL,20.5 )
      UTILPRN ::oUtil Self:nLinea, 5.6 SAY "TOTAL FALTANTES"
      UTILPRN ::oUtil Self:nLinea,13.0 SAY TRANSFORM( aAju[1],    "9,999.99" )  RIGHT
      UTILPRN ::oUtil Self:nLinea,18.5 SAY TRANSFORM( aAju[2],"9,999,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aAju[3],"9,999,999,999" ) RIGHT
      ::nLinea += 0.42
      UTILPRN ::oUtil Self:nLinea, 5.6 SAY "TOTAL SOBRANTES"
      UTILPRN ::oUtil Self:nLinea,15.0 SAY TRANSFORM( aAju[4],    "9,999.99" )  RIGHT
      UTILPRN ::oUtil Self:nLinea,18.5 SAY TRANSFORM( aAju[5],"9,999,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aAju[6],"9,999,999,999" ) RIGHT
      ::nLinea += 0.70
      UTILPRN ::oUtil Self:nLinea, 3.9 SAY "RESUMEN DISTRIBUCION CANTIDADES POR CENTRO DE COSTO"
FOR nT := 1 TO LEN( aTip )
   If aTip[nT,3] > 0
      ::nLinea += 0.42
      UTILPRN ::oUtil Self:nLinea, 3.9 SAY aTip[nT,1]
      UTILPRN ::oUtil Self:nLinea, 5.6 SAY aTip[nT,2]
      UTILPRN ::oUtil Self:nLinea,13.0 SAY TRANSFORM(aTip[nT,3], "99,999.99" )  RIGHT
      UTILPRN ::oUtil Self:nLinea,18.5 SAY TRANSFORM(aTip[nT,4],"999,999,999" ) RIGHT
   EndIf
NEXT
  ENDPAGE
 ::EndInit( .F. )
RETURN NIL

//------------------------------------//
METHOD ListoDev() CLASS TLAjust
   LOCAL oRpt, aTD, nG, nL
   LOCAL cOpt, cQry, aRes, hRes
cQry := "SELECT c.empresa, c.numero, c.factura, c.fecha, "        +;
               "d.codigo, d.cantidad, d.unidadmed, d.causadev, "  +;
               "d.pcosto, i.descrip, i.ppubli, c.codigo_nit "     +;
        "FROM cadinven i, caddevod d, caddevoc c "                +;
        "WHERE i.codigo  = d.codigo"                              +;
         " AND c.empresa = d.empresa"                             +;
         " AND c.numero  = d.numero"                              +;
         " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa))          +;
         " AND c.fecha  >= " + xValToChar( ::aLS[1] )             +;
         " AND c.fecha  <= " + xValToChar( ::aLS[2] ) + If( ::aLS[4] > 0,;
         " AND c.numero  = " + LTRIM(STR(::aLS[4])), "" )         +;
         " ORDER BY c.numero"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[6] == 2
   ::LaserDev( hRes,nL )
   RETURN NIL
EndIf
   cQry := If( ::aLS[3] == "C", "COSTO", "PUBLI" )
If MONTH(::aLS[1]) == MONTH(::aLS[2])
   cOpt := "EN " + NtChr( ::aLS[1],"6" )
Else
   cOpt := "DESDE "+ NtChr( ::aLS[1],"2" )+ " HASTA "+ NtChr( ::aLS[2],"2" )
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"DEVOLUCIONES A PROVEEDOR",cOpt,;
         " DOCUMEN FACTURA   FECHA   C O D I G O  D E S C R I P C I O N---"+;
         "------------  CANTIDAD         PREC."+cQry + "  C A U S A" },::aLS[7],,2 )
   ::aLS[4]:= 0
   aTD  := Buscar( {"clase","Devolucion"},"cadtipos","nombre, 0, 0",2,"tipo" )
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
While nL > 0
   nG := aRes[8]
   If ::aLS[4]  # aRes[2]
      ::aLS[4] := aRes[2]
      oApl:oEmp:Seek( {"empresa",aRes[1]} )
      oApl:cEmpresa := ALLTRIM( oApl:oEmp:NOMBRE )
      oRpt:Titulo( 116 )
      oRpt:Say( oRpt:nL,00,STR(aRes[2],7) + "-" + aRes[3] )
      oRpt:Say( oRpt:nL,16,aRes[4] )
   Else
      oRpt:Titulo( 116 )
   EndIf
      oRpt:Say( oRpt:nL, 27,aRes[05] )
      oRpt:Say( oRpt:nL, 40,aRes[10] )
      oRpt:Say( oRpt:nL, 77,TRANSFORM(aRes[6], "99,999.99") )
      oRpt:Say( oRpt:nL, 87,UMedidas( aRes[7],"" ),6 )
      oRpt:Say( oRpt:nL, 94,TRANSFORM(aRes[9],"999,999,999") )
      oRpt:Say( oRpt:nL,107,aTD[ nG,1 ],11 )
      oRpt:nL++
      aTD[nG,2] +=  aRes[6]
      aTD[nG,3] += (aRes[6] * aRes[9])
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. (::aLS[4] # aRes[2] .AND. ::aLS[5] == "S")
      nG := 0
      AEVAL( aTD, { | e | nG += If( e[2] > 0, 1, 0 ) } )
      oRpt:Separator( 0,nG,116 )
      FOR nG := 1 TO LEN( aTD )
         If aTD[nG,2] > 0
            oRpt:Say(++oRpt:nL,46,aTD[nG,1] + TRANSFORM( aTD[nG,2],"999,999.99" ) )
            oRpt:Say(  oRpt:nL,94,TRANSFORM( aTD[nG,3],"999,999,999" ) )
         EndIf
         aTD[nG,2] := aTD[nG,3] := 0
      NEXT nG
      oRpt:NewPage()
      oRpt:nPage := 0
      oRpt:nL    := oRpt:nLength + 1
   EndIf
EndDo
MSFreeResult( hRes )
oRpt:End()
oApl:oEmp:Seek( {"empresa",oApl:nEmpresa} )
oApl:cEmpresa := ALLTRIM( oApl:oEmp:NOMBRE )
RETURN NIL

//------------------------------------//
METHOD LaserDev( hRes,nL ) CLASS TLAjust
   LOCAL aTD, aRes, nG
aTD  := Buscar( {"clase","Devolucion"},"cadtipos","nombre, 0, 0",2,"tipo" )
aRes := MyReadRow( hRes )
AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
 ::aLS[4]:= 0
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit ,;
             "DEVOLUCIONES A PROVEEDOR",""     ,;
             { .F., 0.5,"NUMERO" }   , { .F., 2.1,"FACTURA" }     ,;
             { .F., 3.7,"F E C H A" }, { .F., 5.4,"C O D I G O" } ,;
             { .F., 7.2,"NOMBRE DEL ARTICULO" },;
             { .T.,15.0,"CANTIDAD" } , { .T.,18.5,"Precio Costo" },;
             { .F.,18.7,"C A U S A" } }
 //      "PREC."+cQry + }
 ::Init( ::aEnc[4], .f. ,, !::aLS[7] ,,, ::aLS[7], 5 )
 ::nMD := 20.5
  PAGE
While nL > 0
   nG := aRes[8]
      ::Cabecera( .t.,0.42 )
   If ::aLS[4]  # aRes[2]
      ::aLS[4] := aRes[2]
      UTILPRN ::oUtil Self:nLinea,1.9 SAY STR(aRes[2],8) RIGHT
      UTILPRN ::oUtil Self:nLinea,2.1 SAY     aRes[3]
      UTILPRN ::oUtil Self:nLinea,3.5 SAY NtChr( aRes[4],"2" )
   EndIf
      UTILPRN ::oUtil Self:nLinea, 5.4 SAY aRes[05]
      UTILPRN ::oUtil Self:nLinea, 7.2 SAY aRes[10]
      UTILPRN ::oUtil Self:nLinea,15.0 SAY TRANSFORM( aRes[6], "99,999.99" )  RIGHT
      UTILPRN ::oUtil Self:nLinea,15.2 SAY LEFT( UMedidas( aRes[7],"" ),6 )
      UTILPRN ::oUtil Self:nLinea,18.5 SAY TRANSFORM( aRes[9],"999,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,18.7 SAY LEFT( aTD[ nG,1 ],11 )
      aTD[nG,2] +=  aRes[6]
      aTD[nG,3] += (aRes[6] * aRes[9])
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. (::aLS[4] # aRes[2] .AND. ::aLS[5] == "S")
      nG := 0.40
      AEVAL( aTD, { | e | nG += If( e[2] > 0, 0.42, 0 ) } )
      ::Cabecera( .t.,0.40,nG,20.5 )
      FOR nG := 1 TO LEN( aTD )
         If aTD[nG,2] > 0
            UTILPRN ::oUtil Self:nLinea, 8.0 SAY aTD[nG,1]
            UTILPRN ::oUtil Self:nLinea,15.0 SAY TRANSFORM(aTD[nG,2],"999,999.99" )  RIGHT
            UTILPRN ::oUtil Self:nLinea,18.5 SAY TRANSFORM(aTD[nG,3],"999,999,999" ) RIGHT
            ::nLinea += 0.42
         EndIf
         aTD[nG,2] := aTD[nG,3] := 0
      NEXT nG
      ::nLinea := ::nEndLine
   EndIf
EndDo
MSFreeResult( hRes )
  ENDPAGE
 ::EndInit( .F. )
RETURN NIL