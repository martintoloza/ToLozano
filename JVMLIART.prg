// Programa.: INOLIART.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Ingresos de Liq., Acces. y L.Contacto
#include "FiveWin.ch"
#include "btnget.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE InoLiArt( nOpc,aLS )
   LOCAL oLF, oAr, oNi, oDlg, oGet := ARRAY(11)
   DEFAULT nOpc := 1
 oLF := TLCompra()
If aLS # NIL
   oLF:aLS := ACLONE( aLS )
   oLF:ListoArt( )
   RETURN
EndIf
oLF:aLS := { DATE(),DATE(),0,SPACE(10),1,oApl:nTFor,.t.,0,"" }
 aLS := { { {|| oLF:ListoArt() },"Listado de Compras" }  ,;
          { {|| oLF:ListoRes() },"Compras de un Código" },;
          { {|| oLF:ListoRes( 3 ) },"Resumen de Ventas" },;
          { {|| oLF:ListoPro() },"Resumen de Compras por Proveedor" } }
oAr := TInv()  ; oAr:New()
oNi := TNits() ; oNi:New()
oNi:oDb:Seek( { "codigo",oLF:aLS[8] } )
DEFINE DIALOG oDlg TITLE aLS[nOpc,2] FROM 0, 0 TO 14,60
   @ 02, 00 SAY "NIT o C.C. DEL PROVEEDOR" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 02, 82 BTNGET oGet[1] VAR oLF:aLS[8] OF oDlg PICTURE "9999999999";
      VALID EVAL( {|| If( EMPTY( oLF:aLS[8] ), .t.                   ,;
                        (If( oNi:oDb:Seek( { "codigo",oLF:aLS[8] } ) ,;
                           ( oDlg:Update(), .t. )                    ,;
                           ( MsgStop("Este Nit no Existe"),.f.)))) } );
      WHEN Rango( nOpc,{1,4} )  SIZE 50,10 PIXEL  RESOURCE "BUSCAR"   ;
      ACTION EVAL({|| If(oNi:Mostrar(), (oLF:aLS[8] := oNi:oDb:CODIGO,;
                         oGet[1]:Refresh() ), )})
   @ 02,134 SAY oGet[2] VAR oNi:oDb:NOMBRE OF oDlg PIXEL SIZE 88,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 14, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 14, 82 GET oGet[3] VAR oLF:aLS[1] OF oDlg SIZE 40,10 PIXEL
   @ 26, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 26, 82 GET oGet[4] VAR oLF:aLS[2] OF oDlg SIZE 40,10 PIXEL;
      VALID oLF:aLS[2] >= oLF:aLS[1]
   @ 38, 00 SAY       "NUMERO DEL INGRESO" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 38, 82 GET oGet[5] VAR oLF:aLS[3] OF oDlg PICTURE "99999" SIZE 40,10 PIXEL;
      WHEN nOpc == 1
   @ 50, 00 SAY "Código del Artículo" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 50, 82 BTNGET oGet[6] VAR oLF:aLS[4] OF oDlg PICTURE "@!"        ;
      VALID If( oAr:oDb:Seek( {"codigo",oLF:aLS[4]} ), .t.           ,;
              ( MsgStop( "Este Código NO EXISTE !!!" ), .f. ))        ;
      WHEN Rango( nOpc,{2,3} ) SIZE 50,10 PIXEL  RESOURCE "BUSCAR"    ;
      ACTION EVAL({|| If(oAr:Mostrar(), (oLF:aLS[4] := oAr:oDb:CODIGO,;
                         oGet[6]:Refresh() ), )})
   @ 62, 00 SAY "Resumen por Dia" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 62, 82 COMBOBOX oGet[7] VAR oLF:aLS[5] ITEMS {"Sin Resumen","Con Resumen","Retenciones"};
      SIZE 48,90 OF oDlg PIXEL
   @ 74, 00 SAY "TIPO DE IMPRESORA"    OF oDlg RIGHT PIXEL SIZE 80,10
   @ 74, 82 COMBOBOX oGet[8] VAR oLF:aLS[6] ITEMS { "Matriz","Laser" };
      SIZE 40,90 OF oDlg PIXEL
   @ 74,134 CHECKBOX oGet[9] VAR oLF:aLS[7] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 88, 50 BUTTON oGet[10] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[10]:Disable(), oLF:aLS[9] := If( oLF:aLS[8] == 0, ""     ,;
           " AND c.codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT)) ),;
        EVAL( aLS[nOpc,1] )      , oGet[10]:Enable(),;
        oGet[10]:oJump := oGet[3], oGet[3]:SetFocus() ) PIXEL
   @ 88,100 BUTTON oGet[11] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 94, 02 SAY "[INOLIART]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT (If( nOpc == 4, Empresa(), ))

RETURN

//------------------------------------//
CLASS TLCompra FROM TIMPRIME

 DATA aLS, aEX

 METHOD NEW( cTit,hRes ) Constructor
 METHOD ListoArt()
 METHOD LaserArt( hRes,nL )
 METHOD ListoRes( nL )
 METHOD LaserRes( hRes,nL )
 METHOD ListoPro()
 METHOD ListoCom()
 METHOD LaserCom( hRes,nL )
 METHOD ListoRet()
 METHOD LaserRet( hRes,nL )
ENDCLASS

//------------------------------------//
METHOD NEW( cTit,hRes ) CLASS TLCompra
If hRes == NIL
   If cTit[6] == 4
      ::aEX[1] := cTit[7]  //IVA
   ElseIf cTit[6] == 6
      ::aEX[2] := cTit[7]  //FTE
   ElseIf cTit[6] == 7
      ::aEX[3] := cTit[7]  //ICA
   ElseIf cTit[6] == 8
      ::aEX[4] := cTit[7]  //CRE
   EndIf
Else
   ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit, cTit ,;
               "DESDE " + NtChr(::aLS[1],"2" ) + " HASTA " + NtChr(::aLS[2],"2" ) }
   If hRes == 1
      cTit := "SELECT c.empresa, c.ingreso, c.codigo_nit, c.fecingre, c.factura, d.codigo"+;
                   ", d.cantidad, d.unidadmed, d.pcosto, d.pventa, d.ppubli, i.descrip "  +;
              "FROM cadinven i, cadartid d, cadartic c "       +;
              "WHERE i.codigo  = d.codigo"                     +;
               " AND d.indica <> 'B'"                          +;
               " AND c.ingreso = d.ingreso"                    +;
               " AND c.fecingre >= " + xValToChar( ::aLS[1] )  +;
               " AND c.fecingre <= " + xValToChar( ::aLS[2] )  + If( ::aLS[3] > 0,;
               " AND c.ingreso = " + LTRIM(STR(::aLS[3])), "" )+     ::aLS[9]    +;
               " ORDER BY c.ingreso"
/*
        "FROM cadartic c LEFT JOIN cadartid d "          +;
          " ON d.indica <> 'B'"                          +;
         " AND c.ingreso = d.ingreso"                    +;
                       " LEFT JOIN cadinven i "          +;
         "USING( codigo ) "                              +;
        "WHERE c.fecingre >= " + xValToChar( ::aLS[1] )  +;
         " AND c.fecingre <= " + xValToChar( ::aLS[2] )  + If( ::aLS[3] > 0,;
         " AND c.ingreso = " + LTRIM(STR(::aLS[3])), "" )+     ::aLS[9]    +;
         " ORDER BY c.ingreso"
*/
   ElseIf hRes == 2
      cTit := "SELECT c.ingreso, c.fecingre, d.cantidad, "  +;
               "d.unidadmed, d.pcosto, c.factura, n.nombre "+;
              "FROM cadartid d, cadclien n, cadartic c "    +;
              "WHERE d.indica <> 'B'"                       +;
               " AND d.codigo  = "   + xValToChar(::aLS[4] )+;
               " AND c.ingreso = d.ingreso"                 +;
               " AND c.codigo_nit = n.codigo_nit"           +;
               " AND c.fecingre >= " + xValToChar(::aLS[1] )+;
               " AND c.fecingre <= " + xValToChar(::aLS[2] )+;
              " ORDER BY n.nombre, c.fecingre"
   ElseIf hRes == 3
      cTit := "SELECT c.numfac, c.fechoy, d.cantidad, "     +;
               "d.unidadmed, d.precioven, c.tipo, n.nombre "+;
              "FROM cadfactd d, cadclien n, cadfactc c "    +;
              "WHERE d.codigo  = "   + xValToChar(::aLS[4] )+;
               " AND c.empresa = d.empresa"                 +;
               " AND c.numfac  = d.numfac"                  +;
               " AND c.tipo    = d.tipo"                    +;
               " AND c.codigo_nit = n.codigo_nit"           +;
               " AND c.fechoy >= " + xValToChar(::aLS[1] )  +;
               " AND c.fechoy <= " + xValToChar(::aLS[2] )  +;
              " ORDER BY n.nombre, c.fechoy"
   ElseIf hRes == 4
      cTit := "SELECT d.codigo, SUM(d.cantidad), SUM(d.cantidad*d.pcosto) "+;
              "FROM cadartid d, cadartic c "                  +;
              "WHERE d.indica <> 'B'"                         +;
               " AND c.ingreso = d.ingreso"                   +;
               " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND c.fecingre >= " + xValToChar( ::aLS[1] ) +;
               " AND c.fecingre <= " + xValToChar( ::aLS[2] ) +;
               ::aLS[9] + " GROUP BY d.codigo ORDER BY d.codigo"
   ElseIf hRes == 5
      cTit := "SELECT c.fecingre, c.ingreso, n.nombre, c.factura, c.subtotal, "    +;
                     "c.totaldes, c.totalfle, c.totaliva, c.totalfac, c.totalret, "+;
                     "c.totalica, SUM(d.cantidad*d.pcosto) "    +;
              "FROM cadartid d, cadartic c LEFT JOIN cadclien n"+;
               " USING(codigo_nit) "                            +;
              "WHERE d.indica   <> 'B'"                         +;
               " AND c.ingreso   = d.ingreso"                   +;
               " AND c.empresa   = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND c.fecingre >= " + xValToChar( ::aLS[1] )   +;
               " AND c.fecingre <= " + xValToChar( ::aLS[2] )   +;
               " GROUP BY c.ingreso ORDER BY c.fecingre"
   ElseIf hRes == 6
      cTit := "SELECT n.codigo, n.digito, n.nombre, c.ingreso, "+;
                     "c.totalfac, d.orden, d.valor "            +;
              "FROM cadartic c LEFT JOIN cadclien n USING( codigo_nit ) " +;
                              "LEFT JOIN comprasd d "                     +;
                 "ON c.row_id    = d.comprasc_id AND d.orden IN(4, 6, 7, 8) "+;
              "WHERE c.empresa   = " + LTRIM(STR(oApl:nEmpresa))+;
               " AND c.fecingre >= " + xValToChar( ::aLS[1] )  +;
               " AND c.fecingre <= " + xValToChar( ::aLS[2] )  +;
               " AND c.totalfac  > 0 ORDER BY n.codigo, c.ingreso"
   EndIf
   hRes := If( MSQuery( oApl:oMySql:hConnect,cTit ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
EndIf
RETURN hRes

//------------------------------------//
METHOD ListoArt() CLASS TLCompra
   LOCAL aRes, aMon, hRes, nL, oRpt
If ::aLS[5] == 3
   ::ListoRet()
   RETURN NIL
EndIf
hRes := ::NEW( "COMPRAS",1 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[6] == 2
   ::LaserArt( hRes,nL )
   RETURN NIL
EndIf
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   ::aLS[3] := 0
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"","","",;
         " C O D I G O  D E S C R I P C I O N-------------------  " +;
         "CANTIDAD       PRECIO COSTO  PRECIO VENTA  PREC.PUBLICO" },::aLS[7],,2 )
While nL > 0
   If ::aLS[3]  # aRes[2]
      ::aLS[3] := aRes[2]
      aMon := { 0,0,0 }
      oApl:oEmp:Seek( {"empresa",aRes[1]} )
      oApl:oNit:Seek( {"codigo_nit",aRes[3]} )
      oApl:cEmpresa := ALLTRIM( oApl:oEmp:NOMBRE )
      oRpt:aEnc[1] := "INGRESO DE ARTICULO" + STR(aRes[2],6)
      oRpt:aEnc[2] := NtChr( aRes[4],"3" ) + "   Factura No." + aRes[5]
      oRpt:aEnc[3] := "PROVEEDOR : " + FormatoNit( oApl:oNit:CODIGO,oApl:oNit:DIGITO )+;
                       "  " + oApl:oNit:NOMBRE
      oRpt:nL    := 67
      oRpt:nPage := 0
   EndIf
//1234567890  1234567890123456789012345678901234567890 99,999.99 MT  999,999,999   999,999,999   999,999,999
   oRpt:Titulo( 113 )
   oRpt:Say( oRpt:nL, 02,aRes[06] )
   oRpt:Say( oRpt:nL, 14,aRes[12] )
   oRpt:Say( oRpt:nL, 55,TRANSFORM(aRes[07],"99,999.99") )
   oRpt:Say( oRpt:nL, 65,aRes[08] )
   oRpt:Say( oRpt:nL, 69,TRANSFORM(aRes[09],"999,999,999.99") )
   oRpt:Say( oRpt:nL, 86,TRANSFORM(aRes[10],"999,999,999") )
   oRpt:Say( oRpt:nL,100,TRANSFORM(aRes[11],"999,999,999") )
   oRpt:nL++
   aMon[1] +=  aRes[7]
   aMon[2] += (aRes[7] * aRes[9])
// aMon[3] := aRes[7] * aRes[10]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. ::aLS[3] # aRes[2]
      If aMon[1] > 0
         oRpt:Say(  oRpt:nL,00,REPLICATE("_",113) )
         oRpt:Say(++oRpt:nL,54,TRANSFORM(aMon[1],"999,999.99") )
         oRpt:Say(  oRpt:nL,69,TRANSFORM(aMon[2],"999,999,999.99" ) )
         oRpt:NewPage()
      EndIf
   EndIf
EndDo
MSFreeResult( hRes )
oRpt:End()
oApl:oEmp:Seek( {"empresa",oApl:nEmpresa} )
oApl:cEmpresa := ALLTRIM( oApl:oEmp:NOMBRE )
RETURN NIL

//------------------------------------//
METHOD LaserArt( hRes,nL ) CLASS TLCompra
   LOCAL aRes, aMon
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
 ::aLS[3] := 0
 ::aEnc := { .t., "", "" , "COMPRAS", ""            ,;
             { .F., 0.5,"","C O D I G O" }          ,;
             { .F., 2.7,"","D E S C R I P C I O N" },;
             { .T.,12.6,"","CANTIDAD" }    , { .T.,15.5,"","PRECIO COSTO" },;
             { .T.,18.0,"","PRECIO VENTA" }, { .T.,20.5,"","PREC.PUBLICO" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[7] ,,, ::aLS[7], 5 )
 ::nMD := 20.5
  PAGE
While nL > 0
   If ::aLS[3]  # aRes[2]
      ::aLS[3] := aRes[2]
      aMon := { 0,0,0 }
      oApl:oEmp:Seek( {"empresa",aRes[1]} )
      oApl:oNit:Seek( {"codigo_nit",aRes[3]} )
      ::aEnc[2]  := ALLTRIM( oApl:oEmp:NOMBRE )
      ::aEnc[3]  := oApl:oEmp:NIT
      ::aEnc[4]  := "INGRESO DE ARTICULO" + STR(aRes[2],6)
      ::aEnc[5]  := NtChr( aRes[4],"3" ) + "   Factura No." + aRes[5]
      ::aEnc[7,3]:= FormatoNit( oApl:oNit:CODIGO,oApl:oNit:DIGITO )+;
                     "  " + oApl:oNit:NOMBRE
      ::nPage    := 1
   EndIf
   ::Cabecera( .t.,0.42 )
   UTILPRN ::oUtil Self:nLinea, 0.5 SAY aRes[06]
   UTILPRN ::oUtil Self:nLinea, 2.7 SAY aRes[12]
   UTILPRN ::oUtil Self:nLinea,12.6 SAY TRANSFORM( aRes[07], "99,999.99" )     RIGHT
   UTILPRN ::oUtil Self:nLinea,12.8 SAY aRes[08]
   UTILPRN ::oUtil Self:nLinea,15.5 SAY TRANSFORM( aRes[09],"999,999,999.99" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,18.0 SAY TRANSFORM( aRes[10],"999,999,999" )    RIGHT
   UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aRes[11],"999,999,999" )    RIGHT
   aMon[1] +=  aRes[7]
   aMon[2] += (aRes[7] * aRes[9])
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. ::aLS[3] # aRes[2]
      If aMon[1] > 0
         ::Cabecera( .t.,0.40,0.82,20.5 )
         UTILPRN ::oUtil Self:nLinea,12.6 SAY TRANSFORM( aMon[1],"999,999.99" )     RIGHT
         UTILPRN ::oUtil Self:nLinea,15.5 SAY TRANSFORM( aMon[2],"999,999,999.99" ) RIGHT
     	   ::nLinea := ::nEndLine
      EndIf
   EndIf
EndDo
MSFreeResult( hRes )
  ENDPAGE
 ::EndInit( .F. )
RETURN NIL

//------------------------------------//
METHOD ListoRes( nL ) CLASS TLCompra
   LOCAL aCom, aRes, hRes, oRpt
aRes := {"COMPRAS DEL CODIGO " + ::aLS[4], ALLTRIM(oApl:oInv:DESCRIP)  +;
         " DESDE " +NtChr(::aLS[1],"2") +" HASTA " +NtChr(::aLS[2],"2"),;
         "P R O V E E D O R------------------ INGRESO   F E C H A   "  +;
         "CANTIDAD    PRECIO COSTO  FACTURA"}
If nL == NIL
   ::aLS[5]:= 1
   hRes := ::NEW( aRes[1],2 )
Else
   ::aLS[5]:= 2
   aRes[3] := "C L I E N T E---------------------- FACTURA   F E C H A"+;
              "   CANTIDAD    PRECIO VENTA  TIPO"
   hRes := ::NEW( aRes[1],3 )
EndIf
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[6] == 2
   ::LaserRes( hRes,nL )
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New(oApl:cPuerto,oApl:cImpres, aRes, ::aLS[7],,2 )
aCom := { "",0,0 }
//345678901234567890123456789012345 1234567 15-may-2007  99,999.99 MT  999,999,999  1234567890
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      oRpt:Titulo( 94 )
   If aCom[1]  # aRes[7]
      aCom[1] := aRes[7]
      oRpt:Say( oRpt:nL,01,aCom[1] )
   EndIf
   oRpt:Say( oRpt:nL, 36,STR(aRes[1],7) )
   oRpt:Say( oRpt:nL, 44,NtChr(aRes[2],"2") )
   oRpt:Say( oRpt:nL, 57,TRANSFORM(aRes[3], "99,999.99") )
   oRpt:Say( oRpt:nL, 67,aRes[4] )
   oRpt:Say( oRpt:nL, 71,TRANSFORM(aRes[5],"999,999,999") )
   oRpt:Say( oRpt:nL, 84,aRes[6] )
   oRpt:nL++
   aCom[2] +=  aRes[3]
   aCom[3] += (aRes[3] * aRes[5])
   nL --
EndDo
MSFreeResult( hRes )
aCom[3] := ROUND( aCom[3] / aCom[2],2 )
oRpt:Say(  oRpt:nL,00,REPLICATE("_",94) )
oRpt:Say(++oRpt:nL,56,TRANSFORM(aCom[2],"999,999.99") )
oRpt:Say(  oRpt:nL,71,TRANSFORM(aCom[3],"999,999,999.99") )
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserRes( hRes,nL ) CLASS TLCompra
   LOCAL aRes, aCom := { "",0,0 }
 ::aEnc := { .t., ::aEnc[2], ::aEnc[3], ::aEnc[4], ::aEnc[5]          ,;
             { .F., 0.5,"P R O V E E D O R" }, { .T.,10.0,"INGRESO" } ,;
             { .F.,10.6,"F E C H A" }        , { .T.,15.0,"CANTIDAD" },;
             { .T.,18.0,"PRECIO COSTO" }     , { .T.,20.5,"FACTURA" } }
If ::aLS[5] == 2
   ::aEnc[06,3]:= "C L I E N T E"
   ::aEnc[07,3]:= "FACTURA"
   ::aEnc[10,3]:= "PRECIO VENTA"
   ::aEnc[11,3]:= "TIPO"
EndIf
 ::Init( ::aEnc[4], .f. ,, !::aLS[7] ,,, ::aLS[7], 5 )
 ::nMD := 20.5
  PAGE
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   ::Cabecera( .t.,0.42 )
   If aCom[1]  # aRes[7]
      aCom[1] := aRes[7]
      UTILPRN ::oUtil Self:nLinea, 0.5 SAY aCom[1]
   EndIf
   UTILPRN ::oUtil Self:nLinea,10.0 SAY STR(aRes[1],7)                     RIGHT
   UTILPRN ::oUtil Self:nLinea,10.5 SAY NtChr(aRes[2],"2")
   UTILPRN ::oUtil Self:nLinea,15.0 SAY TRANSFORM( aRes[3], "99,999.99" )  RIGHT
   UTILPRN ::oUtil Self:nLinea,15.2 SAY aRes[4]
   UTILPRN ::oUtil Self:nLinea,18.0 SAY TRANSFORM( aRes[5],"999,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,20.5 SAY aRes[6]                            RIGHT
   aCom[2] +=  aRes[3]
   aCom[3] += (aRes[3] * aRes[5])
   nL --
EndDo
MSFreeResult( hRes )
aCom[3] := ROUND( aCom[3] / aCom[2],2 )
   ::Cabecera( .t.,0.40,0.82,20.5 )
   UTILPRN ::oUtil Self:nLinea,15.0 SAY TRANSFORM( aCom[2],"999,999.99" )     RIGHT
   UTILPRN ::oUtil Self:nLinea,18.3 SAY TRANSFORM( aCom[3],"999,999,999.99" ) RIGHT
  ENDPAGE
 ::EndInit( .F. )
RETURN NIL

//------------------------------------//
METHOD ListoPro() CLASS TLCompra
   LOCAL aGT, aRes, hRes, nL, oRpt
If ::aLS[5] == 2
   ::ListoCom()
   RETURN NIL
EndIf
hRes := ::NEW( "COMPRAS DISCRIMINADAS POR PRODUCTO",4 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[6] == 2
   ::aEnc := { .t., ::aEnc[2], ::aEnc[3], ::aEnc[4], ::aEnc[5]           ,;
               { .F., 0.5,"","C O D I G O" },;
               { .F., 3.0,FormatoNit( oApl:oNit:CODIGO,oApl:oNit:DIGITO )+;
                        "  " + oApl:oNit:NOMBRE,"D E S C R I P C I O N" },;
               { .T.,17.0,"","CANTIDAD" }   , { .T.,20.0,"","PRECIO COSTO" } }
   ::Init( ::aEnc[4], .f. ,, !::aLS[7] ,,, ::aLS[7] )
   PAGE
Else
   oRpt := TDosPrint()
   oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4], ::aEnc[5],;
             "        PROVEEDOR : " + STR(::aLS[8]) + "  " + oApl:oNit:NOMBRE  ,;
             "C O D I G O-  D E S C R I P C I O N            CANTIDAD   PRECIO COSTO"},::aLS[7] )
EndIf
aGT  := { 0,0,0,"" }
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   oApl:oInv:Seek( {"codigo",aRes[1]} )
   If ::aLS[6] == 1
      oRpt:Titulo( 70 )
      oRpt:Say( oRpt:nL  ,00,aRes[1] )
      oRpt:Say( oRpt:nL  ,14,oApl:oInv:DESCRIP )
      oRpt:Say( oRpt:nL  ,46,TRANSFORM( aRes[2],  "9,999,999") )
      oRpt:Say( oRpt:nL++,59,TRANSFORM( aRes[3],"999,999,999") )
   Else
      ::Cabecera( .t.,0.42 )
      UTILPRN ::oUtil Self:nLinea, 0.5 SAY aRes[1]
      UTILPRN ::oUtil Self:nLinea, 3.0 SAY oApl:oInv:DESCRIP
      UTILPRN ::oUtil Self:nLinea,17.0 SAY TRANSFORM( aRes[2],  "9,999,999.99" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM( aRes[3],"999,999,999" )    RIGHT
   EndIf
   aGT[1] += aRes[2]
   aGT[2] += aRes[3]
   aGT[3] ++
   nL --
EndDo
MSFreeResult( hRes )
If ::aLS[6] == 1
   oRpt:Say(  oRpt:nL,00,REPLICATE("_",70) )
   oRpt:Say(++oRpt:nL,16,"GRAN TOTAL ==>" )
   oRpt:Say(  oRpt:nL,45,TRANSFORM(aGT[1],   "99,999,999" ) )
   oRpt:Say(  oRpt:nL,57,TRANSFORM(aGT[2],"9,999,999,999" ) )
   oRpt:NewPage()
   oRpt:End()
Else
   ::Cabecera( .t.,0.40,0.82,20 )
   UTILPRN ::oUtil Self:nLinea, 3.0 SAY "GRAN TOTAL ==>"
   UTILPRN ::oUtil Self:nLinea,17.0 SAY TRANSFORM( aGT[1],   "99,999,999.99" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM( aGT[2],"9,999,999,999" )    RIGHT
  ENDPAGE
 ::EndInit( .F. )
EndIf
RETURN NIL

//------------------------------------//
METHOD ListoCom() CLASS TLCompra
   LOCAL aGT, aRes, hRes, nL, oRpt
hRes := ::NEW( "RESUMEN DE COMPRAS POR DIA",5 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[6] == 2
   ::LaserCom( hRes,nL )
   RETURN NIL
EndIf
aRes := MyReadRow( hRes )
AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
aGT  := { aRes[1],0,0,0,0 }
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4], ::aEnc[5],;
          "INGRESO NOMBRE DEL PROVEEDOR       FACTURA---  ---SUBTOTAL  -----FLETES"+;
          "  -----I.V.A.  TOTAL FACT.  ---RET.FTE.  ---RET.ICA.  -DIFERENCIA"},::aLS[7],,2 )
While nL > 0
   If aRes[12] > 0
      If oApl:oEmp:TREGIMEN == 1
         aGT[5] := aRes[09]
      Else
         aGT[5] := aRes[09] - aRes[10] - aRes[11]
      EndIf
      aRes[12] := (aRes[05] + aRes[07] + aRes[08] - aRes[06]) -;
                  (  aGT[5] + aRes[10] + aRes[11])
      oRpt:Titulo( 136 )
      oRpt:Say( oRpt:nL, 00,STR(aRes[2],7) )
      oRpt:Say( oRpt:nL, 08,aRes[3],25 )
      oRpt:Say( oRpt:nL, 35,aRes[4] )
      oRpt:Say( oRpt:nL, 47,TRANSFORM( aRes[05],  "999,999,999") )
      oRpt:Say( oRpt:nL, 60,TRANSFORM( aRes[07],  "999,999,999") )
      oRpt:Say( oRpt:nL, 73,TRANSFORM( aRes[08],  "999,999,999") )
      oRpt:Say( oRpt:nL, 86,TRANSFORM( aRes[09],  "999,999,999") )
      oRpt:Say( oRpt:nL, 99,TRANSFORM( aRes[10],  "999,999,999") )
      oRpt:Say( oRpt:nL,112,TRANSFORM( aRes[11],  "999,999,999") )
      oRpt:Say( oRpt:nL,126,TRANSFORM( aRes[12],"@Z 99,999,999") )
      oRpt:nL ++
      aGT[2]  ++
      aGT[3]  += aRes[9]
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If (nL == 0 .OR. aGT[1] # aRes[1]) .AND. aGT[2] > 0
      oRpt:Say(  oRpt:nL,00,REPLICATE("_",136),,,1 )
      oRpt:Say(++oRpt:nL,11,"TOTAL DEL DIA " +LEFT( NtChr(aGT[1],"2"),6 ),,,1)
      oRpt:Say(  oRpt:nL,86,TRANSFORM( aGT[3],"999,999,999" ))
      oRpt:nL += 3
      aGT[1] := aRes[1]
      aGT[4] += aGT[3]
      aGT[2] := aGT[3] := 0
   EndIf
EndDo
MSFreeResult( hRes )
If aGT[4] > 0
   oRpt:Say( oRpt:nL,16,"GRAN TOTAL ==>",,,1 )
   oRpt:Say( oRpt:nL,84,TRANSFORM(aGT[4],"9,999,999,999" ) )
EndIf
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserCom( hRes,nL ) CLASS TLCompra
   LOCAL aGT, aRes
aRes := MyReadRow( hRes )
AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
aGT  := { aRes[1],0,0,0,0 }
 ::aEnc := { .t., ::aEnc[2], ::aEnc[3], ::aEnc[4], ::aEnc[5]    ,;
             { .F., 0.5,"INGRESO" }   , { .F., 2.0,"NOMBRE DEL PROVEEDOR" },;
             { .F., 6.4,"FACTURA" }   , { .T., 9.7,"SUBTOTAL" } ,;
             { .T.,11.5,"FLETES" }    , { .T.,13.3,"I.V.A." }   ,;
             { .T.,15.1,"TOTAL FACT" }, { .T.,16.9,"RET.FTE." } ,;
             { .T.,18.7,"RET.ICA." }  , { .T.,20.5,"DIFERENCIA" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[7] ,,, ::aLS[7], 5 )
 ::nMD := 20.5
  PAGE
While nL > 0
   If aRes[12] > 0
      If oApl:oEmp:TREGIMEN == 1
         aGT[5] := aRes[09]
      Else
         aGT[5] := aRes[09] - aRes[10] - aRes[11]
      EndIf
      aRes[12] := (aRes[05] + aRes[07] + aRes[08] - aRes[06]) -;
                  (  aGT[5] + aRes[10] + aRes[11])
      ::Cabecera( .t.,0.42 )
      UTILPRN ::oUtil Self:nLinea, 1.7 SAY   STR(aRes[2],7)                     RIGHT
      UTILPRN ::oUtil Self:nLinea, 2.0 SAY LEFT( aRes[3],25 )
      UTILPRN ::oUtil Self:nLinea, 6.4 SAY       aRes[4]
      UTILPRN ::oUtil Self:nLinea, 9.7 SAY TRANSFORM( aRes[05],  "999,999,999") RIGHT
      UTILPRN ::oUtil Self:nLinea,11.5 SAY TRANSFORM( aRes[07],  "999,999,999") RIGHT
      UTILPRN ::oUtil Self:nLinea,13.3 SAY TRANSFORM( aRes[08],  "999,999,999") RIGHT
      UTILPRN ::oUtil Self:nLinea,15.1 SAY TRANSFORM( aRes[09],  "999,999,999") RIGHT
      UTILPRN ::oUtil Self:nLinea,16.9 SAY TRANSFORM( aRes[10],  "999,999,999") RIGHT
      UTILPRN ::oUtil Self:nLinea,18.7 SAY TRANSFORM( aRes[11],  "999,999,999") RIGHT
      UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( aRes[12],"@Z 99,999,999") RIGHT
      aGT[2]  ++
      aGT[3]  += aRes[9]
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If (nL == 0 .OR. aGT[1] # aRes[1]) .AND. aGT[2] > 0
      ::Cabecera( .t.,0.40,0.82,20.5 )
      UTILPRN ::oUtil Self:nLinea, 2.0 SAY "TOTAL DEL DIA " +LEFT( NtChr(aGT[1],"2"),6 )
      UTILPRN ::oUtil Self:nLinea,15.1 SAY TRANSFORM(  aGT[3],"9,999,999,999" ) RIGHT
      ::nLinea += 0.15
      aGT[1] := aRes[1]
      aGT[4] += aGT[3]
      aGT[2] := aGT[3] := 0
   EndIf
EndDo
MSFreeResult( hRes )
If aGT[4] > 0
   ::Cabecera( .t.,0.40,0.82,20.5 )
   UTILPRN ::oUtil Self:nLinea, 2.0 SAY "GRAN TOTAL ==>"
   UTILPRN ::oUtil Self:nLinea,15.1 SAY TRANSFORM(  aGT[4],"9,999,999,999" ) RIGHT
  ENDPAGE
 ::EndInit( .F. )
EndIf
RETURN NIL

//------------------------------------//
METHOD ListoRet() CLASS TLCompra
   LOCAL aGT, aRes, hRes, nL, oRpt
hRes := ::NEW( "RETENCIONES EN COMPRAS",6 )
 ::aLS[9] := "999,999,999"
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[6] == 2
   ::LaserRet( hRes,nL )
   RETURN NIL
EndIf
   oRpt := TDosPrint()
   oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4], ::aEnc[5],;
             "      CC o NIT  NOMBRE DEL PROVEEDOR                     INGRESO  " +;
             "TOTAL FACTURA    I.V.A.    RET.FTE.    RET.ICA.    RET.CREE"},::aLS[7],,2 )
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aGT := { aRes[1],aRes[2],aRes[3],aRes[4],aRes[5] }
   ::aEX := { 0,0,0,0,0,0,0,0,0,0,0 }
While nL > 0
   ::NEW( aRes )
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aGT[4] # aRes[4]
      oRpt:Titulo( 125 )
      If ::aEX[11]  # aGT[1]
         ::aEX[11] := aGT[1]
         oRpt:Say( oRpt:nL, 00,FormatoNit(aGT[1],aGT[2]) )
         oRpt:Say( oRpt:nL, 16,aGT[3] )
      EndIf
      oRpt:Say( oRpt:nL, 53,STR(aGT[4]) )
      oRpt:Say( oRpt:nL, 66,TRANSFORM(   aGT[5],::aLS[9] ))
      oRpt:Say( oRpt:nL, 78,TRANSFORM( ::aEX[1],::aLS[9] ))
      oRpt:Say( oRpt:nL, 90,TRANSFORM( ::aEX[2],::aLS[9] ))
      oRpt:Say( oRpt:nL,102,TRANSFORM( ::aEX[3],::aLS[9] ))
      oRpt:Say( oRpt:nL,114,TRANSFORM( ::aEX[4],::aLS[9] ))
      oRpt:nL ++
      ::aEX[05] ++
      ::aEX[06] +=   aGT[5]
      ::aEX[07] += ::aEX[1]
      ::aEX[08] += ::aEX[2]
      ::aEX[09] += ::aEX[3]
      ::aEX[10] += ::aEX[4]
      ::aEX[01] := ::aEX[2] := ::aEX[3] := ::aEX[4] := 0
      aGT := { aRes[1],aRes[2],aRes[3],aRes[4],aRes[5] }
   EndIf
EndDo
MSFreeResult( hRes )
   oRpt:Titulo( 112 )
   oRpt:Say(  oRpt:nL, 00,REPLICATE("_",125) )
   oRpt:Say(++oRpt:nL, 01,STR(::aEX[5],5) + " FACTURAS" )
   oRpt:Say(  oRpt:nL, 66,TRANSFORM( ::aEX[06],::aLS[9] ))
   oRpt:Say(  oRpt:nL, 78,TRANSFORM( ::aEX[07],::aLS[9] ))
   oRpt:Say(  oRpt:nL, 90,TRANSFORM( ::aEX[08],::aLS[9] ))
   oRpt:Say(  oRpt:nL,102,TRANSFORM( ::aEX[09],::aLS[9] ))
   oRpt:Say(  oRpt:nL,114,TRANSFORM( ::aEX[10],::aLS[9] ))
   oRpt:NewPage()
   oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserRet( hRes,nL ) CLASS TLCompra
   LOCAL aGT, aRes
  aRes := MyReadRow( hRes )
AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aGT := { aRes[1],aRes[2],aRes[3],aRes[4],aRes[5] }
 ::aEX := { 0,0,0,0,0,0,0,0,0,0,0 }
 ::aEnc:= { ::aEnc[1], ::aEnc[2], ::aEnc[3], ::aEnc[4], ::aEnc[5],;
           { .T., 2.5,"CC o NIT" }, { .F., 2.8,"PROVEEDOR" }     ,;
           { .T.,11.4,"INGRESO" } , { .T.,13.3,"Total Factura" } ,;
           { .T.,15.1,"I.V.A." }  , { .T.,16.9,"RET.FTE." }      ,;
           { .T.,18.7,"RET.ICA." }, { .T.,20.5,"RET.CREE" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[7] ,,, ::aLS[7], 5 )
 ::nMD := 20.5
  PAGE
While nL > 0
   ::NEW( aRes )
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aGT[4] # aRes[4]
      ::Cabecera( .t.,0.41 )
      If ::aEX[11]  # aGT[1]
         ::aEX[11] := aGT[1]
         UTILPRN ::oUtil Self:nLinea, 2.5 SAY FormatoNit(aGT[1],aGT[2])   RIGHT
         UTILPRN ::oUtil Self:nLinea, 2.8 SAY aGT[3]
      EndIf
      UTILPRN ::oUtil Self:nLinea,11.4 SAY STR(aGT[4])                    RIGHT
      UTILPRN ::oUtil Self:nLinea,13.3 SAY TRANSFORM(   aGT[5],::aLS[9] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,15.1 SAY TRANSFORM( ::aEX[1],::aLS[9] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,16.9 SAY TRANSFORM( ::aEX[2],::aLS[9] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,18.7 SAY TRANSFORM( ::aEX[3],::aLS[9] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( ::aEX[4],::aLS[9] ) RIGHT
      ::aEX[05] ++
      ::aEX[06] +=   aGT[5]
      ::aEX[07] += ::aEX[1]
      ::aEX[08] += ::aEX[2]
      ::aEX[09] += ::aEX[3]
      ::aEX[10] += ::aEX[4]
      ::aEX[01] := ::aEX[2] := ::aEX[3] := ::aEX[4] := 0
      aGT := { aRes[1],aRes[2],aRes[3],aRes[4],aRes[5] }
   EndIf
EndDo
MSFreeResult( hRes )
   ::Cabecera( .t.,0.41,0.82,20.5 )
   UTILPRN ::oUtil Self:nLinea, 2.8 SAY STR(::aEX[5],5) + " FACTURAS"
   UTILPRN ::oUtil Self:nLinea,13.3 SAY TRANSFORM( ::aEX[06],::aLS[9] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,15.1 SAY TRANSFORM( ::aEX[07],::aLS[9] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,16.9 SAY TRANSFORM( ::aEX[08],::aLS[9] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,18.7 SAY TRANSFORM( ::aEX[09],::aLS[9] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( ::aEX[10],::aLS[9] ) RIGHT
  ENDPAGE
 ::EndInit( .F. )
RETURN NIL