// Programa.: CAOLIVED.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo ventas diarias de las Empresas
#include "FiveWin.ch"
#include "UtilPrn.ch"

MEMVAR oApl

PROCEDURE CaoLiVed( nOpc )
   LOCAL aVT, oA, oDlg, oGet := ARRAY(10)
   DEFAULT nOpc := 1
 oA := CDiarias()
aVT := { { {|| oA:ListoVen() },"Listar Ventas Diarias" }       ,;
         { {|| oA:ListoRes() },"Resumen de Ventas Consolidadas" } }
DEFINE DIALOG oDlg TITLE aVT[nOpc,2] FROM 0, 0 TO 12,50
   @ 02, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 86,10
   @ 02, 88 GET oGet[1] VAR oA:aLS[1] OF oDlg  SIZE 40,10 PIXEL
   @ 14, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 86,10
   @ 14, 88 GET oGet[2] VAR oA:aLS[2] OF oDlg ;
      VALID oA:aLS[2] >= oA:aLS[1] SIZE 40,10 PIXEL
   @ 26, 00 SAY "DESEA UN RESUMEN [S/N/D]" OF oDlg RIGHT PIXEL SIZE 86,10
   @ 26, 88 GET oGet[3] VAR oA:aLS[3] OF oDlg PICTURE "!";
      VALID If( oA:aLS[3] $ "NSD", .t., .f. ) SIZE 08,10 PIXEL
   @ 38, 00 SAY "PAGINA INICIAL"           OF oDlg RIGHT PIXEL SIZE 86,10
   @ 38, 88 GET oGet[4] VAR oA:aLS[4] OF oDlg PICTURE "999";
      VALID Rango( oA:aLS[4],1,999 )  SIZE 24,10 PIXEL
   @ 50, 00 SAY "CLASE DE PAPEL"           OF oDlg RIGHT PIXEL SIZE 86,10
   @ 50, 88 COMBOBOX oGet[5] VAR oA:aLS[5] ITEMS ArrayCol( oApl:aPapel,1 );
      SIZE 46,99 OF oDlg PIXEL
   @ 62, 00 SAY "TIPO DE IMPRESORA"        OF oDlg RIGHT PIXEL SIZE 86,10
   @ 62, 88 COMBOBOX oGet[6] VAR oA:aLS[6] ITEMS { "Matriz","Laser" };
      SIZE 48,90 OF oDlg PIXEL
   @ 62,138 CHECKBOX oGet[7] VAR oA:aLS[7] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 76, 50 BUTTON oGet[08] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[8]:Disable(), EVAL( aVT[nOpc,1] ), oDlg:End() ) PIXEL
   @ 76,100 BUTTON oGet[09] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 76,150 BUTTON oGet[10] PROMPT "Descuadre" SIZE 40,12 OF oDlg ACTION;
      ( oGet[10]:Disable(), oA:CuadreFAC(), oGet[10]:Enable(),;
        oGet[10]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 82, 02 SAY "[PDLLIVED]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED

RETURN

//------------------------------------//
CLASS CDiarias FROM TIMPRIME

 DATA aLS  INIT { DATE(),DATE(),"N",1,1,oApl:nTFor, .t.,0 }

 METHOD ListoVen()
 METHOD LaserVen( hRes,nL )
 METHOD ListoDia()
 METHOD LaserDia( hRes,nL )
 METHOD Categoria( nCat,nP )
 METHOD ListoRes()
 METHOD CuadreFAC()
 METHOD Memo( cTit,hRes )
ENDCLASS

//------------------------------------//
METHOD ListoVen() CLASS CDiarias
   LOCAL oRpt, aGT := ARRAY(12), aVT := ARRAY(9)
   LOCAL aFF, aRes, aTem, cFF, hRes, nL, nP
If ::aLS[3] == "D"
   ::ListoDia()
   RETURN NIL
EndIf
hRes := ::Memo( "LISTADO DE VENTAS DIARIAS",1 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[6] == 2
   ::LaserVen( hRes,nL )
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4], ::aEnc[5],;
          "FACTURA NOMBRE DEL CLIENTE   -----VENTAS  -DESCUENTO  ----I.V.A. " +;
          " ---PICADAS  ---INSTITU  ---COMIDAS  ----DULCES  ---PUDINES "+;
          " POSTRE-PIE  ----VARIOS  TRANS.FLET" },::aLS[7],,2,oApl:aPapel[::aLS[5],2] )
 AFILL( aGT,0 )
 AFILL( aVT,0 )
 aRes := MyReadRow( hRes )
 AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
  aFF := { aRes[1],aRes[1]+1 }
 aTem := { aRes[1],aRes[2],aRes[3],aRes[4],aRes[5],aRes[6],aRes[7] }
While nL > 0
   aRes[8] += aRes[9]
       nP  := ::Categoria( aRes[10],1 )
   aVT[nP] += aRes[8]
   aVT[09] += aRes[8]

   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aTem[1] # aRes[1]
      If ::aLS[3] == "N"
         oRpt:Titulo( 160 )
         oRpt:Say( oRpt:nL,00,STR( aTem[1],7 ) )
         If aTem[5] == "A"
            oRpt:Say( oRpt:nL,08,"** A N U L A D A **" )
         Else
            oApl:oNit:Seek( {"codigo_nit",aTem[7]} )
            oRpt:Say( oRpt:nL,08,If( oApl:oNit:CODIGO > 0,;
                           oApl:oNit:NOMBRE, aTem[6] ),20 )
            oRpt:Say( oRpt:nL, 29,TRANSFORM( aTem[2],"999,999,999" ))
            oRpt:Say( oRpt:nL, 40,If( aTem[2] # aVT[9], "*"," " ))
            oRpt:Say( oRpt:nL, 41,TRANSFORM(aTem[3],"@Z 999,999,999" ))
            oRpt:Say( oRpt:nL, 53,TRANSFORM(aTem[4],"@Z 999,999,999" ))
            oRpt:Say( oRpt:nL, 65,TRANSFORM( aVT[1],"@Z 999,999,999" ))
            oRpt:Say( oRpt:nL, 77,TRANSFORM( aVT[2],"@Z 999,999,999" ))
            oRpt:Say( oRpt:nL, 89,TRANSFORM( aVT[3],"@Z 999,999,999" ))
            oRpt:Say( oRpt:nL,101,TRANSFORM( aVT[4],"@Z 999,999,999" ))
            oRpt:Say( oRpt:nL,113,TRANSFORM( aVT[5],"@Z 999,999,999" ))
            oRpt:Say( oRpt:nL,125,TRANSFORM( aVT[6],"@Z 999,999,999" ))
            oRpt:Say( oRpt:nL,137,TRANSFORM( aVT[7],"@Z 999,999,999" ))
            oRpt:Say( oRpt:nL,149,TRANSFORM( aVT[8],"@Z 999,999,999" ))
         EndIf
         oRpt:nL ++
      EndIf
      aGT[1] ++
      aGT[2] += aTem[2]
      aGT[3] += aTem[3]
      aGT[4] += aTem[4]
      AEVAL( aVT, {|nVal,nPos| aGT[nPos+4] += nVal },1,8 )
      If aFF[2] < aRes[1]
            cFF := STR(aFF[2],9)
         If aFF[2] < aRes[1] -1
            cFF += " al" + STR(aRes[1] -1,9)
         EndIf
         AADD( aFF,cFF )
      EndIf
         aFF[2] := aRes[1] + 1
      aTem := { aRes[1],aRes[2],aRes[3],aRes[4],aRes[5],aRes[6],aRes[7] }
      AFILL( aVT,0 )
   EndIf
EndDo
   MSFreeResult( hRes )
   nL := 0
   AEVAL( aGT, {|nVal| nL += nVal },5 )
   oRpt:Titulo( 160 )
   oRpt:Say(  oRpt:nL, 00,REPLICATE("_",160) )
   oRpt:Say(++oRpt:nL, 01,STR(aGT[1],5) + " FACTURAS" )
   oRpt:Say(  oRpt:nL, 23,If( aGT[2] # nL, "***"," " ))
   oRpt:Say(  oRpt:nL, 27,TRANSFORM(aGT[02],"9,999,999,999" ))
   oRpt:Say(  oRpt:nL, 41,TRANSFORM(aGT[03],  "999,999,999" ))
   oRpt:Say(  oRpt:nL, 53,TRANSFORM(aGT[04],  "999,999,999" ))
   oRpt:Say(  oRpt:nL, 65,TRANSFORM(aGT[05],  "999,999,999" ))
   oRpt:Say(  oRpt:nL, 77,TRANSFORM(aGT[06],  "999,999,999" ))
   oRpt:Say(  oRpt:nL, 89,TRANSFORM(aGT[07],  "999,999,999" ))
   oRpt:Say(  oRpt:nL,101,TRANSFORM(aGT[08],  "999,999,999" ))
   oRpt:Say(  oRpt:nL,113,TRANSFORM(aGT[09],  "999,999,999" ))
   oRpt:Say(  oRpt:nL,125,TRANSFORM(aGT[10],  "999,999,999" ))
   oRpt:Say(  oRpt:nL,137,TRANSFORM(aGT[11],  "999,999,999" ))
   oRpt:Say(  oRpt:nL,149,TRANSFORM(aGT[12],  "999,999,999" ))
If LEN( aFF ) > 2
   oRpt:nL := 67
   oRpt:aEnc[3]:= "     FACTURAS FALTANTES"
   oRpt:Titulo( 78 )
   oRpt:Say( oRpt:nL,20,"Primer Factura :" + STR( aFF[1],8) )
   oRpt:Say( oRpt:nL,50,"Ultima Factura :" + STR(aTem[1]) )
   FOR nL := 3 TO LEN( aFF )
      oRpt:nL ++
      oRpt:Say( oRpt:nL,02,aFF[nL] )
   NEXT nL
EndIf
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserVen( hRes,nL ) CLASS CDiarias
   LOCAL aGT := ARRAY(12), aVT := ARRAY(9)
   LOCAL aFF, aRes, aTem, cFF, nP
 ::aEnc:= { ::aEnc[1], ::aEnc[2], ::aEnc[3], ::aEnc[4], ::aEnc[5],;
            { .T., 2.0,"FACTURA" }, { .F., 2.2,"C L I E N T E" } ,;
            { .T., 6.4,"VENTAS" } , { .T., 7.8,"Descuentos" }    ,;
            { .T., 9.2,"ImpConsumo" }, { .T.,10.6,"PICADAS" }    ,;
            { .T.,12.0,"INSTITU" }, { .T.,13.4,"COMIDAS" }       ,;
            { .T.,14.8,"DULCES" } , { .T.,16.2,"PUDINES" }       ,;
            { .T.,17.6,"Postre-Pie" },;
            { .T.,19.0,"VARIOS" } , { .T.,20.4,"FLETES" } }
 ::TamanoHoja( oApl:aPapel[::aLS[5],2] )
 ::Init( ::aEnc[4], .f. ,, !::aLS[7] ,,,, 5 )
 ::nMD := 20.5
 DEFINE FONT ::aFnt[5] NAME ::cFont SIZE 0,-7              OF ::oPrn
  PAGE
 AFILL( aGT,0 )
 AFILL( aVT,0 )
 aRes := MyReadRow( hRes )
 AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
  aFF := { aRes[1],aRes[1]+1 }
 aTem := { aRes[1],aRes[2],aRes[3],aRes[4],aRes[5],aRes[6],aRes[7] }
While nL > 0
   aRes[8] += aRes[9]
       nP  := ::Categoria( aRes[10],1 )
   aVT[nP] += aRes[8]
   aVT[09] += aRes[8]

   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aTem[1] # aRes[1]
      If ::aLS[3] == "N"
         ::Cabecera( .t.,0.42 )
         UTILPRN ::oUtil Self:nLinea, 2.0 SAY STR( aTem[1],7 ) RIGHT
         If aTem[5] == "A"
            UTILPRN ::oUtil Self:nLinea, 2.2 SAY "** A N U L A D A **"
         Else
            oApl:oNit:Seek( {"codigo_nit",aTem[7]} )
            If oApl:oNit:CODIGO > 0
               aTem[6] := oApl:oNit:NOMBRE
            EndIf
            UTILPRN ::oUtil Self:nLinea, 2.2 SAY LEFT( aTem[6],18 )
            UTILPRN ::oUtil Self:nLinea, 6.4 SAY TRANSFORM( aTem[2],   "999,999,999" ) RIGHT
            UTILPRN ::oUtil Self:nLinea, 6.5 SAY If( aTem[2] # aVT[9], "*"," " )
            UTILPRN ::oUtil Self:nLinea, 7.8 SAY TRANSFORM( aTem[3],"@Z 999,999,999" ) RIGHT
            UTILPRN ::oUtil Self:nLinea, 9.2 SAY TRANSFORM( aTem[4],"@Z 999,999,999" ) RIGHT
            UTILPRN ::oUtil Self:nLinea,10.6 SAY TRANSFORM(  aVT[1],"@Z 999,999,999" ) RIGHT
            UTILPRN ::oUtil Self:nLinea,12.0 SAY TRANSFORM(  aVT[2],"@Z 999,999,999" ) RIGHT
            UTILPRN ::oUtil Self:nLinea,13.4 SAY TRANSFORM(  aVT[3],"@Z 999,999,999" ) RIGHT
            UTILPRN ::oUtil Self:nLinea,14.8 SAY TRANSFORM(  aVT[4],"@Z 999,999,999" ) RIGHT
            UTILPRN ::oUtil Self:nLinea,16.2 SAY TRANSFORM(  aVT[5],"@Z 999,999,999" ) RIGHT
            UTILPRN ::oUtil Self:nLinea,17.6 SAY TRANSFORM(  aVT[6],"@Z 999,999,999" ) RIGHT
            UTILPRN ::oUtil Self:nLinea,19.0 SAY TRANSFORM(  aVT[7],"@Z 999,999,999" ) RIGHT
            UTILPRN ::oUtil Self:nLinea,20.4 SAY TRANSFORM(  aVT[8],"@Z 999,999,999" ) RIGHT
         EndIf
      EndIf
      aGT[1] ++
      aGT[2] += aTem[2]
      aGT[3] += aTem[3]
      aGT[4] += aTem[4]
      AEVAL( aVT, {|nVal,nPos| aGT[nPos+4] += nVal },1,8 )
      If aFF[2] < aRes[1]
            cFF := STR(aFF[2],9)
         If aFF[2] < aRes[1] -1
            cFF += " al" + STR(aRes[1] -1,9)
         EndIf
         AADD( aFF,cFF )
      EndIf
         aFF[2] := aRes[1] + 1
      aTem := { aRes[1],aRes[2],aRes[3],aRes[4],aRes[5],aRes[6],aRes[7] }
      AFILL( aVT,0 )
   EndIf
EndDo
   MSFreeResult( hRes )
   nL := 0
   AEVAL( aGT, {|nVal| nL += nVal },5 )
   ::Cabecera( .t.,0.42,1.26,20.5 )
   UTILPRN ::oUtil Self:nLinea, 1.5 SAY STR(aGT[01],5) + " FACTURAS"
   UTILPRN ::oUtil Self:nLinea, 3.5 SAY If( aGT[2] # nL, "***"," " )
   UTILPRN ::oUtil Self:nLinea, 6.4 SAY TRANSFORM( aGT[02],"9,999,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea, 7.8 SAY TRANSFORM( aGT[03],  "999,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea, 9.2 SAY TRANSFORM( aGT[04],  "999,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,10.6 SAY TRANSFORM( aGT[05],  "999,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,12.0 SAY TRANSFORM( aGT[06],  "999,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,13.4 SAY TRANSFORM( aGT[07],  "999,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,14.8 SAY TRANSFORM( aGT[08],  "999,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,16.2 SAY TRANSFORM( aGT[09],  "999,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,17.6 SAY TRANSFORM( aGT[10],  "999,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,19.0 SAY TRANSFORM( aGT[11],  "999,999,999" ) RIGHT
   UTILPRN ::oUtil Self:nLinea,20.4 SAY TRANSFORM( aGT[12],  "999,999,999" ) RIGHT
If LEN( aFF ) > 2
   ::nLinea := ::nEndLine
   ::aEnc[4]:= "     FACTURAS FALTANTES"
   ::Cabecera( .t.,0.42 )
   UTILPRN ::oUtil Self:nLinea, 2.5 SAY "Primer Factura :" + STR( aFF[1],8)
   UTILPRN ::oUtil Self:nLinea,12.5 SAY "Ultima Factura :" + STR(aTem[1])
   FOR nL := 3 TO LEN( aFF )
      ::nLinea += 0.42
      UTILPRN ::oUtil Self:nLinea, 2.5 SAY aFF[nL]
   NEXT nL
EndIf
   ENDPAGE
IMPRIME END .F.
RETURN NIL

//------------------------------------//
METHOD ListoDia() CLASS CDiarias
   LOCAL aRes, aTem, hRes, nL, nP, oRpt
   LOCAL aGT := ARRAY(2,13)
hRes := ::Memo( "LISTADO DE VENTAS DIARIAS",2 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[6] == 2
   ::LaserDia( hRes,nL )
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4], ::aEnc[5],;
          "FACTURA    DIA DE LA VENTA   -----VENTAS  -DESCUENTO  IMPCONSUMO " +;
          " ---PICADAS  ---INSTITU  ---COMIDAS  ----DULCES  ---PUDINES "+;
          " POSTRE-PIE  ----VARIOS  TRANS.FLET" },::aLS[7],,2,oApl:aPapel[::aLS[5],2] )
AEVAL( aGT, { |x| AFILL( x,0 ) } )
 aRes := MyReadRow( hRes )
 AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
 aTem := { aRes[1],0 }
While nL > 0
   If aTem[2]  # aRes[2] .AND. aTem[1] == aRes[1]
      aTem[2] := aRes[2]
      aGT[1,01] ++
      aGT[1,02] +=  aRes[3]
      aGT[1,03] +=  aRes[4]
      aGT[1,04] +=  aRes[5]
      aGT[1,13] += If( aRes[9] == 147, aRes[3], 0)
   EndIf
            nP  := ::Categoria( aRes[8],1 ) + 4
      aGT[1,nP] += (aRes[6] + aRes[7])
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aTem[1] # aRes[1]
      oRpt:Titulo( 150 )
      oRpt:Say( oRpt:nL, 00,STR( aGT[1,01],4 ) + " FACT" )
      oRpt:Say( oRpt:nL, 11,LEFT(NtChr( aTem[1],"2" ),7) + NtChr( aTem[1],"5" ) )
      oRpt:Say( oRpt:nL, 29,TRANSFORM( aGT[1,02],   "999,999,999" ))
      oRpt:Say( oRpt:nL, 41,TRANSFORM( aGT[1,03],"@Z 999,999,999" ))
      oRpt:Say( oRpt:nL, 53,TRANSFORM( aGT[1,04],"@Z 999,999,999" ))
      oRpt:Say( oRpt:nL, 65,TRANSFORM( aGT[1,05],"@Z 999,999,999" ))
      oRpt:Say( oRpt:nL, 77,TRANSFORM( aGT[1,06],"@Z 999,999,999" ))
      oRpt:Say( oRpt:nL, 89,TRANSFORM( aGT[1,07],"@Z 999,999,999" ))
      oRpt:Say( oRpt:nL,101,TRANSFORM( aGT[1,08],"@Z 999,999,999" ))
      oRpt:Say( oRpt:nL,113,TRANSFORM( aGT[1,09],"@Z 999,999,999" ))
      oRpt:Say( oRpt:nL,125,TRANSFORM( aGT[1,10],"@Z 999,999,999" ))
      oRpt:Say( oRpt:nL,137,TRANSFORM( aGT[1,11],"@Z 999,999,999" ))
      oRpt:Say( oRpt:nL,149,TRANSFORM( aGT[1,12],"@Z 999,999,999" ))
      oRpt:nL ++
      aTem := { aRes[1],0 }
      FOR nP := 1 TO 13
         aGT[2,nP] += aGT[1,nP]
         aGT[1,nP] := 0
      NEXT nP
   EndIf
EndDo
   MSFreeResult( hRes )
   oRpt:Titulo( 150 )
   oRpt:Say(  oRpt:nL, 00,REPLICATE("_",150) )
   oRpt:Say(++oRpt:nL, 01,STR(aGT[2,01],5) + " FACTURAS" )
   oRpt:Say(  oRpt:nL, 27,TRANSFORM(aGT[2,02],"9,999,999,999" ))
   oRpt:Say(  oRpt:nL, 41,TRANSFORM(aGT[2,03],  "999,999,999" ))
   oRpt:Say(  oRpt:nL, 53,TRANSFORM(aGT[2,04],  "999,999,999" ))
   oRpt:Say(  oRpt:nL, 65,TRANSFORM(aGT[2,05],  "999,999,999" ))
   oRpt:Say(  oRpt:nL, 77,TRANSFORM(aGT[2,06],  "999,999,999" ))
   oRpt:Say(  oRpt:nL, 89,TRANSFORM(aGT[2,07],  "999,999,999" ))
   oRpt:Say(  oRpt:nL,101,TRANSFORM(aGT[2,08],  "999,999,999" ))
   oRpt:Say(  oRpt:nL,113,TRANSFORM(aGT[2,09],  "999,999,999" ))
   oRpt:Say(  oRpt:nL,125,TRANSFORM(aGT[2,10],  "999,999,999" ))
   oRpt:Say(  oRpt:nL,137,TRANSFORM(aGT[2,11],  "999,999,999" ))
   oRpt:Say(  oRpt:nL,149,TRANSFORM(aGT[2,12],  "999,999,999" ))
   oRpt:NewPage()
   oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserDia( hRes,nL ) CLASS CDiarias
   LOCAL aRes, aTem, nP
   LOCAL aGT := ARRAY(2,13)
 ::aEnc:= { ::aEnc[1], ::aEnc[2], ::aEnc[3], ::aEnc[4], ::aEnc[5],;
            { .T., 2.0,"FACTURA" }, { .F., 2.2,"DIA DE LA VENTA" },;
            { .T., 6.4,"VENTAS" } , { .T., 7.8,"Descuentos" }    ,;
            { .T., 9.2,"ImpConsumo" }, { .T.,10.6,"PICADAS" }    ,;
            { .T.,12.0,"INSTITU" }, { .T.,13.4,"COMIDAS" }       ,;
            { .T.,14.8,"DULCES" } , { .T.,16.2,"PUDINES" }       ,;
            { .T.,17.6,"Postre-Pie" },;
            { .T.,19.0,"VARIOS" } , { .T.,20.4,"FLETES" } }
 ::TamanoHoja( oApl:aPapel[::aLS[5],2] )
 ::Init( ::aEnc[4], .f. ,, !::aLS[7] ,,,, 5 )
 ::nMD := 20.5
 DEFINE FONT ::aFnt[5] NAME ::cFont SIZE 0,-7              OF ::oPrn
  PAGE
AEVAL( aGT, { |x| AFILL( x,0 ) } )
 aRes := MyReadRow( hRes )
 AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
 aTem := { aRes[1],0 }
While nL > 0
   If aTem[2]  # aRes[2] .AND. aTem[1] == aRes[1]
      aTem[2] := aRes[2]
      aGT[1,01] ++
      aGT[1,02] +=  aRes[3]
      aGT[1,03] +=  aRes[4]
      aGT[1,04] +=  aRes[5]
      aGT[1,13] += If( aRes[9] == 147, aRes[3], 0)
   EndIf
            nP  := ::Categoria( aRes[8],1 ) + 4
      aGT[1,nP] += (aRes[6] + aRes[7])
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aTem[1] # aRes[1]
      ::Cabecera( .t.,0.42 )
      UTILPRN ::oUtil Self:nLinea, 0.5 SAY STR( aGT[1,01],4 ) + " FACT"
      UTILPRN ::oUtil Self:nLinea, 2.2 SAY LEFT(NtChr( aTem[1],"2" ),7) + NtChr( aTem[1],"5" )
      UTILPRN ::oUtil Self:nLinea, 6.4 SAY TRANSFORM( aGT[1,02],   "999,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea, 7.8 SAY TRANSFORM( aGT[1,03],"@Z 999,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea, 9.2 SAY TRANSFORM( aGT[1,04],"@Z 999,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,10.6 SAY TRANSFORM( aGT[1,05],"@Z 999,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,12.0 SAY TRANSFORM( aGT[1,06],"@Z 999,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,13.4 SAY TRANSFORM( aGT[1,07],"@Z 999,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,14.8 SAY TRANSFORM( aGT[1,08],"@Z 999,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,16.2 SAY TRANSFORM( aGT[1,09],"@Z 999,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,17.6 SAY TRANSFORM( aGT[1,10],"@Z 999,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,19.0 SAY TRANSFORM( aGT[1,11],"@Z 999,999,999" ) RIGHT
      UTILPRN ::oUtil Self:nLinea,20.4 SAY TRANSFORM( aGT[1,12],"@Z 999,999,999" ) RIGHT
      aTem := { aRes[1],0 }
      FOR nP := 1 TO 13
         aGT[2,nP] += aGT[1,nP]
         aGT[1,nP] := 0
      NEXT nP
   EndIf
EndDo
   MSFreeResult( hRes )
    ::Cabecera( .t.,0.42,1.26,20.5 )
    UTILPRN ::oUtil Self:nLinea, 1.5 SAY STR(aGT[2,01],5) + " FACTURAS"
    UTILPRN ::oUtil Self:nLinea, 6.4 SAY TRANSFORM( aGT[2,02],"9,999,999,999" ) RIGHT
    UTILPRN ::oUtil Self:nLinea, 7.8 SAY TRANSFORM( aGT[2,03],  "999,999,999" ) RIGHT
    UTILPRN ::oUtil Self:nLinea, 9.2 SAY TRANSFORM( aGT[2,04],  "999,999,999" ) RIGHT
    UTILPRN ::oUtil Self:nLinea,10.6 SAY TRANSFORM( aGT[2,05],  "999,999,999" ) RIGHT
    UTILPRN ::oUtil Self:nLinea,12.0 SAY TRANSFORM( aGT[2,06],  "999,999,999" ) RIGHT
    UTILPRN ::oUtil Self:nLinea,13.4 SAY TRANSFORM( aGT[2,07],  "999,999,999" ) RIGHT
    UTILPRN ::oUtil Self:nLinea,14.8 SAY TRANSFORM( aGT[2,08],  "999,999,999" ) RIGHT
    UTILPRN ::oUtil Self:nLinea,16.2 SAY TRANSFORM( aGT[2,09],  "999,999,999" ) RIGHT
    UTILPRN ::oUtil Self:nLinea,17.6 SAY TRANSFORM( aGT[2,10],  "999,999,999" ) RIGHT
    UTILPRN ::oUtil Self:nLinea,19.0 SAY TRANSFORM( aGT[2,11],  "999,999,999" ) RIGHT
    UTILPRN ::oUtil Self:nLinea,20.4 SAY TRANSFORM( aGT[2,12],  "999,999,999" ) RIGHT
   ENDPAGE
IMPRIME END .F.
RETURN NIL

//------------------------------------//
METHOD Categoria( nCat,nP ) CLASS CDiarias
   do Case
   Case nCat >= 100 .AND. nCat < 200
      nP :=  1
   Case nCat >= 200 .AND. nCat < 300
      nP :=  2
   Case nCat >= 300 .AND. nCat < 400
      nP :=  3
   Case nCat >= 400 .AND. nCat < 500
      nP :=  4
   Case nCat >= 500 .AND. nCat < 600
      nP :=  5
   Case nCat >= 600 .AND. nCat < 700
      nP :=  6
   Case nCat >= 700 .AND. nCat < 800
      nP :=  7
   Case nCat >= 800 .AND. nCat < 900
      nP :=  8
   EndCase
RETURN nP

//------------------------------------//
METHOD ListoRes() CLASS CDiarias
   LOCAL aRes, hRes, nL, nK, oRpt, cPict := "999,999,999"
   LOCAL aMV, aVT := ARRAY(4,5), aGT := { 0,0,0,0,0,0,0,0,0,0 }
hRes := ::Memo( "Resumen de Ventas Consolidadas",3 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
//ElseIf ::aLS[6] == 2
//   ::LaserRes( hRes,nL )
//   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4], ::aEnc[5],;
          "                             --VENTAS--  --VENTAS--              "   +;
          "                                                CUENTAS  X     TOTAL",;
          "FACTURA NOMBRE DEL CLIENTE   -GRAVADAS-  NOGRAVADAS  --I.V.A.--  DES"+;
          "CUENTOS  --RET.FTE-  --RET.IVA-  --RET.ICA-  --COBRAR--  ---PAGOS--"},;
          ::aLS[7],::aLS[4],2,oApl:aPapel[::aLS[5],2] )
//      aMV[4] := TOTALFAC - c.Retfte - c.Retica - c.Retiva
   aMV  := { 0,0,0,0,0 }
   aRes := MyReadRow( hRes )
   AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ), AADD(aMV,aRes[nP]) } )
   AEVAL( aVT, { |x| AFILL( x,0 ) } )
While nL > 0
   If aRes[9] > 0
      aMV[1] += aRes[8]  //Gravadas
   Else
      aMV[2] += aRes[8]
   EndIf
      aMV[3] += aRes[9]  //Montoiva
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aMV[6] # aRes[1]
      aMV[4] := aMV[9] //- RETFTE - RETICA - RETIVA
      If ::aLS[3] == "N"
         oApl:oPag:dbEval( {|o| aMV[5] += If( o:FORMAPAGO <= 4, o:PAGADO, 0 ) },;
                           {"empresa",oApl:nEmpresa,"numfac",aMV[6],;
                            "tipo",oApl:Tipo,"indicador <>","A"} )
         oRpt:Titulo( 135 )
         If oRpt:nPage >= oRpt:nPagI
            oRpt:Say( oRpt:nL,00,STR(aMV[6],6) )
            If aMV[10] == "A"
               oRpt:Say( oRpt:nL,08,"** A N U L A D A **" )
            Else
               oApl:oNit:Seek( {"codigo_nit",aMV[12]} )
               oRpt:Say( oRpt:nL, 08,If( oApl:oNit:CODIGO > 0,;
                                         oApl:oNit:NOMBRE, aMV[11] ),20 )
//                           99,999,999  99,999,999  99,999,999  99,999,999  99,999,999  99,999,999  99,999,999  99,999,999  99,999,999
               oRpt:Say( oRpt:nL, 29,TRANSFORM(aMV[1],   "99,999,999") )
               oRpt:Say( oRpt:nL, 41,TRANSFORM(aMV[2],   "99,999,999") )
               oRpt:Say( oRpt:nL, 53,TRANSFORM(aMV[7],"@Z 99,999,999") )
               oRpt:Say( oRpt:nL, 65,TRANSFORM(aMV[8],"@Z 99,999,999") )
//             oRpt:Say( oRpt:nL, 77,TRANSFORM(RETFTE,"@Z 99,999,999") )
//             oRpt:Say( oRpt:nL, 89,TRANSFORM(RETIVA,"@Z 99,999,999") )
//             oRpt:Say( oRpt:nL,101,TRANSFORM(RETICA,"@Z 99,999,999") )
               oRpt:Say( oRpt:nL,113,TRANSFORM(aMV[4],"@Z 99,999,999") )
               oRpt:Say( oRpt:nL,125,TRANSFORM(aMV[5],"@Z 99,999,999") )
            EndIf
         EndIf
         oRpt:nL ++
         If aMV[10] # "A"
            aGT[02] += aMV[1]
            aGT[03] += aMV[2]
            aGT[04] += aMV[7]
            aGT[05] += aMV[8]
//          aGT[06] += RETFTE
//          aGT[07] += RETIVA
//          aGT[08] += RETICA
            aGT[09] += aMV[4]
            aGT[10] += aMV[5]
         EndIf
      EndIf
      If aMV[10] # "A"
         nK := 1 //AT( TIPO,"ABC" )
         aVT[nK,1] += aMV[9]
         aVT[nK,2] += aMV[8]
         aVT[nK,3] += aMV[1]
         aVT[nK,4] += aMV[2]
         aVT[nK,5] += aMV[7]
      EndIf
      aGT[01] ++
      aMV := { 0,0,0,0,0 }
      AEVAL( aRes, {|xV| AADD( aMV,xV ) },1,7 )
   EndIf
EndDo
MSFreeResult( hRes )
If aGT[01] > 0
   If ::aLS[3] == "N"
      oRpt:Say(  oRpt:nL,  0,REPLICATE("_",135) )
      oRpt:Say(++oRpt:nL, 00,STR( aGT[01],3 ) + " FACTURAS" )
      oRpt:Say(  oRpt:nL, 28,TRANSFORM(aGT[02],cPict) )
      oRpt:Say(  oRpt:nL, 40,TRANSFORM(aGT[03],cPict) )
      oRpt:Say(  oRpt:nL, 52,TRANSFORM(aGT[04],cPict) )
      oRpt:Say(  oRpt:nL, 64,TRANSFORM(aGT[05],cPict) )
      oRpt:Say(  oRpt:nL, 76,TRANSFORM(aGT[06],cPict) )
      oRpt:Say(  oRpt:nL, 88,TRANSFORM(aGT[07],cPict) )
      oRpt:Say(  oRpt:nL,100,TRANSFORM(aGT[08],cPict) )
      oRpt:Say(  oRpt:nL,112,TRANSFORM(aGT[09],cPict) )
      oRpt:Say(  oRpt:nL,124,TRANSFORM(aGT[10],cPict) )
      oRpt:NewPage()
      oRpt:nL := 67
   EndIf
   ASIZE( oRpt:aEnc,2 )
   oRpt:cFontI := oRpt:CPINormal
   oRpt:Titulo( 78 )
   FOR nK := 1 TO 3
      If aVT[nK,1] # 0
         aVT[04,1] += aVT[nK,1]
         aVT[04,2] += aVT[nK,2]
         aVT[04,3] += aVT[nK,3]
         aVT[04,4] += aVT[nK,4]
         aVT[04,5] += aVT[nK,5]
         oRpt:Say(++oRpt:nL,14,"Total Facturas Tipo " + SUBSTR( "ABC",nK,1 ) )
         oRpt:Say(++oRpt:nL,14,"Cuentas por Cobrar            " + NtChr( aVT[nK,1],cPict ))
         oRpt:Say(++oRpt:nL,14,"Descuento                     " + NtChr( aVT[nK,2],cPict ))
         oRpt:Say(++oRpt:nL,14,"Ventas    Gravadas" + SPACE(23) + NtChr( aVT[nK,3],cPict ))
         oRpt:Say(++oRpt:nL,14,"Ventas no Gravadas" + SPACE(23) + NtChr( aVT[nK,4],cPict ))
         oRpt:Say(++oRpt:nL,14,"I.V.A.            " + SPACE(23) + NtChr( aVT[nK,5],cPict ))
      EndIf
   NEXT
   If LEN( oApl:Tipo ) > 1
      oRpt:Say(++oRpt:nL,14,"Gran Total" )
      oRpt:Say(++oRpt:nL,14,"Cuentas por Cobrar            " + NtChr( aVT[4,1],cPict ))
      oRpt:Say(++oRpt:nL,14,"Descuento                     " + NtChr( aVT[4,2],cPict ))
      oRpt:Say(++oRpt:nL,14,"Ventas    Gravadas" + SPACE(23) + NtChr( aVT[4,3],cPict ))
      oRpt:Say(++oRpt:nL,14,"Ventas no Gravadas" + SPACE(23) + NtChr( aVT[4,4],cPict ))
      oRpt:Say(++oRpt:nL,14,"I.V.A.            " + SPACE(23) + NtChr( aVT[4,5],cPict ))
   EndIf
EndIf
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD CuadreFAC() CLASS CDiarias
   LOCAL aRes, cQry, hRes, nL, nC := 0, oRpt
MSQuery( oApl:oMySql:hConnect,"DROP TABLE temporalm" )
cQry := "CREATE TABLE temporalm AS "                    +;
        "SELECT c.comprobant, c.control, SUM(IFNULL(d.valor_cre,0)) ventas "+;
        "FROM cgemovd d, cgemovc c "                    +;
        "WHERE LEFT(d.cuenta,4) = '4120'"               +;
         " AND c.empresa = d.empresa"                   +;
         " AND c.ano_mes = d.ano_mes"                   +;
         " AND c.control = d.control"                   +;
         " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.ano_mes = '"+ NtChr( ::aLS[2],"1" )    +;
        "' AND c.estado <> 2  GROUP BY c.comprobant"
MSQuery( oApl:oMySql:hConnect,cQry )

MSQuery( oApl:oMySql:hConnect,"DROP TABLE temporalf" )
cQry := "CREATE TABLE temporalf AS "                    +;
        "SELECT numfac, control, SUM(totalfac - totaliva) ventas " +;
        "FROM cadfactu "                                +;
        "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))  +;
         " AND fechoy >= " + xValToChar( ::aLS[1] )     +;
         " AND fechoy <= " + xValToChar( ::aLS[2] )     +;
         " AND tipo    = " + xValToChar(oApl:Tipo)      +;
         " AND indicador <> 'A' GROUP BY numfac"
MSQuery( oApl:oMySql:hConnect,cQry )

hRes := ::Memo( "DESCUADRE EN LAS VENTAS",4 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "CUADRADAS CON CONTABILIDAD","VENTAS ESTAN" )
   MSFreeResult( hRes )
   RETURN NIL
EndIf
   oRpt := TDosPrint()
   oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4], ::aEnc[5],;
             "   FACTURA  CONTROL         V E N T A S       CONTABILIDAD"},.t. )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   cQry := "SELECT ventas FROM temporalm "            +;
           "WHERE comprobant = " + LTRIM(STR(aRes[1]))+;
            " AND control    = " + LTRIM(STR(aRes[2]))
   nC   := Buscar( cQry,"CM",,8,,4 )
   oRpt:Titulo( 96 )
   oRpt:Say( oRpt:nL,00,STR(aRes[1],10) + STR(aRes[2],9) )
   oRpt:Say( oRpt:nL,21,TRANSFORM( aRes[3],"999,999,999,999.99" ) )
   oRpt:Say( oRpt:nL,41,TRANSFORM(     nC ,"999,999,999,999.99" ) )
   oRpt:nL ++
   nL --
EndDo
MSFreeResult( hRes )

cQry := "SELECT m.comprobant, m.control, m.ventas "        +;
        "FROM temporalm m "                                +;
        "WHERE NOT EXISTS ( SELECT 'x' FROM temporalf f "  +;
                           "WHERE f.numfac  = m.comprobant"+;
                            " AND f.control = m.control )"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) > 0
   oRpt:Say( oRpt:nL++,02,"COMPROBANTES QUE NO ESTAN EN VENTAS" )
EndIf
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   oRpt:Titulo( 96 )
   oRpt:Say( oRpt:nL,00,STR(aRes[1],10) + STR(aRes[2],9) )
   oRpt:Say( oRpt:nL,41,TRANSFORM( aRes[3],"999,999,999,999.99" ) )
   oRpt:nL ++
   nL --
EndDo
MSFreeResult( hRes )
   oRpt:NewPage()
   oRpt:End()
RETURN NIL

//------------------------------------//
METHOD Memo( cTit,hRes ) CLASS CDiarias
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit, cTit ,;
            "DESDE " + NtChr(::aLS[1],"2" ) + " HASTA " + NtChr(::aLS[2],"2" ) }
If hRes == 1
   cTit := "SELECT c.numfac, c.totalfac, c.totaldes, c.totaliva"+;
                     ", c.indicador, c.cliente, c.codigo_nit, " +;
                       "d.precioven, d.montoiva, i.categoria "  +;
           "FROM cadfactu c LEFT JOIN cadventa d "         +;
            "USING( empresa, numfac, tipo ) "              +;
           "JOIN cadinven i USING( codigo ) "              +;
           "WHERE c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND c.fechoy >= " + xValToChar( ::aLS[1] )   +;
            " AND c.fechoy <= " + xValToChar( ::aLS[2] )   +;
            " AND c.tipo    = " + xValToChar(oApl:Tipo)    +;
           " ORDER BY c.numfac"
ElseIf hRes == 2
   cTit := "SELECT c.fechoy, c.numfac, c.totalfac, c.totaldes, c.totaliva"+;
                ", d.precioven, d.montoiva, i.categoria, c.codigo_nit "   +;
           "FROM cadfactu c LEFT JOIN cadventa d "         +;
            "USING( empresa, numfac, tipo ) "              +;
           "JOIN cadinven i USING( codigo ) "              +;
           "WHERE c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND c.fechoy >= " + xValToChar( ::aLS[1] )   +;
            " AND c.fechoy <= " + xValToChar( ::aLS[2] )   +;
            " AND c.tipo    = " + xValToChar(oApl:Tipo)    +;
            " AND c.indicador <> 'A' ORDER BY c.fechoy, c.numfac"
ElseIf hRes == 3
   cTit := "SELECT c.numfac, c.totaliva, c.totaldes, c.totalfac, "         +;
           "c.indicador, c.cliente, c.codigo_nit, d.precioven, d.montoiva "+;
           "FROM cadfactu c LEFT JOIN cadventa d "         +;
            "USING( empresa, numfac, tipo ) "              +;
           "WHERE c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND c.fechoy >= " + xValToChar( ::aLS[1] )   +;
            " AND c.fechoy <= " + xValToChar( ::aLS[2] )   +;
            " AND c.tipo    = " + xValToChar(oApl:Tipo)    +;
            " ORDER BY c.numfac"
   If ::aLS[3] == "N"
      ::aEnc[5] := "EN " + NtChr( ::aLS[2],"6" )
   EndIf
ElseIf hRes == 4
   ::aEnc[5] := "PERIODO : " + NtChr( ::aLS[2],"1" )
   cTit := "SELECT f.numfac, f.control, f.ventas "            +;
           "FROM temporalf f "                                +;
           "WHERE NOT EXISTS ( SELECT 'x' FROM temporalm m "  +;
                              "WHERE m.comprobant = f.numfac" +;
                               " AND m.control    = f.control"+;
                               " AND m.ventas     = f.ventas)"
EndIf
 hRes := If( MSQuery( oApl:oMySql:hConnect,cTit ) ,;
             MSStoreResult( oApl:oMySql:hConnect ), 0 )
RETURN hRes