// Programa.: CGELINOT.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listar Los Comprobantes Ingreso, Egresos y Notas
#INCLUDE "Fivewin.CH"
#INCLUDE "Utilprn.CH"

MEMVAR oApl

FUNCTION CgeLista( nCtl,aChq,cTit )
   LOCAL oBtn, oDlg, oLF, lSI := .f.
// LOCAL hDC := GetDC( 0 )
//::aFont := GetFontNames( hDC )
oLF := TLinot()
DEFINE DIALOG oDlg TITLE cTit
   @ 02,62 CHECKBOX oLF:lPrev PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,10 PIXEL
   @ 14,00 SAY "TIPO DE IMPRESORA" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 14,62 COMBOBOX oLF:aLS[1] ITEMS { "Matriz","Laser" };
      SIZE 48,90 OF oDlg PIXEL
   @ 26,00 SAY "Libro" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 26,62 COMBOBOX oLF:aLS[2] ITEMS { "COLGAAP","IFRS" };
      SIZE 48,90 OF oDlg PIXEL;
      WHEN !EMPTY(oApl:oEmp:NIIF)
// @ 26,00 SAY "Escoja la Fuente"  OF oDlg RIGHT PIXEL SIZE 60,10
// @ 26,62 COMBOBOX oLF:aLS[2] ITEMS ::aFont SIZE 80,99 OF oDlg PIXEL;
//    WHEN oLF:aLS[1] > 1

   @ 38,70 BUTTON oBtn PROMPT "Imprimir" SIZE 44,12 ;
      ACTION ( lSI := .t., oDlg:End() ) OF oDlg PIXEL
ACTIVATE DIALOG oDlg CENTER
If lSI
   oLF:NEW( nCtl,aChq,cTit )
EndIf
RETURN lSI

//------------------------------------//
CLASS TLinot FROM TIMPRIME

 DATA aCG, aTL, hRes, lPrev, nCtl, nL, nLib
 DATA aLS  AS ARRAY INIT { oApl:nTFor,1,"Arial" }
 DATA lPrev   INIT .f.
 DATA lTit    INIT .t.

  METHOD NEW( nCtl,aChq,cTit ) Constructor
  METHOD DosNForma()
  METHOD DosFForma()
  METHOD DosNotas()
  METHOD WinNForma()
  METHOD WinFForma()
  METHOD WinNotas()
  METHOD CicloData( nP,xDat,nRight )
  METHOD CicloDeta()
  METHOD Cabecera( lSep,nSpace,nSuma )
ENDCLASS

//------------------------------------//
METHOD NEW( nCtl,aChq,cTit ) CLASS TLinot
   LOCAL cQry, nP
cQry := "SELECT c.fecha, c.fuente, c.comprobant, c.concepto, c.valorb, c.codigonit, n.forma, "+;
               "n.listar, n.ff, n.cf, n.fv, n.cv, n.fb, n.cb, n.fn, n.cn, n.fm, n.cm, n.lm, " +;
               "n.fc, n.cc, n.fp, n.cp, n.fd, n.ct, n.cd, n.db, n.cr, n.thoja, n.items "      +;
        "FROM cgemovc c LEFT JOIN cgenotas n "          +;
         " ON (c.empresa = n.empresa "                  +;
          " OR n.empresa = " + LTRIM(STR(oApl:nPuc))    +;
        ") AND c.fuente  = n.fuente "                   +;
         " AND n.listar  = '" + { "D'","W'" }[::aLS[1]] +;
       " WHERE c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.ano_mes = " + xValToChar( oApl:cPer )  +;
         " AND c.control = " + LTRIM(STR(nCtl))
::hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nP := MSNumRows( ::hRes )) == 0
   MSFreeResult( ::hRes )
   RETURN NIL
EndIf
 ::nCtl := nCtl
   nCtl := ::aLS[1]
 ::nLib := ::aLS[2]
 ::aLS  := MyReadRow( ::hRes )
 AEVAL( ::aLS, { | xV,nP | ::aLS[nP] := MyClReadCol( ::hRes,nP ) } )
/*
** ff[09],cf[10]  FECHA
** fv[11],cv[12]  VALOR
** fb[13],cb[14]  NOMBRE BENEFICIARIO
** fn[15],cn[16]  NIT o C.C.
** fm[17],cm[18]  MONTO ESCRITO
** lm[19]         ANCHO MONTO ESCRITO 1era LINEA
** fc[20],cc[21]  CONCEPTO
** fp[22],cp[23]  COMPROBANTE
** fd[24]         LINEA DONDE COMIENZAN LOS DETALLES
** ct[25]         COLUMNA CUENTA PUC
** cd[26]         COLUMNA INFA
** db[27]         COLUMNA DEBITO
** cr[28]         COLUMNA CREDITO
** thoja[29]      ALTO DE LA HOJA
** items[30]      TOTAL DE ITEMS
*/
If EMPTY( ::aLS[7] )
   //CHEQUE := 0
   //TF     := 'AS'
   If nCtl == 1
      cQry := { "N","D",9,10,15,50,11,13,11,61,13,10,50,17,14,0,0,27,0,11,45,62,66,0 }
   Else
      cQry := { "N","W",9,10,15,50,11,13,11,61,13,10,50,17,14,0,0,6,2.5,5.5,16.7,19.2,0,0 }
   EndIf
   AEVAL( cQry, { |x,p| ::aLS[p+6] := x } )
EndIf
 MSFreeResult( ::hRes )
 ::aCG  := { cTit,"",0,0,0,0,0,"" }
If oApl:oNit:Seek( {"codigo_nit",::aLS[6]} )
   ::aCG[2] := FormatoNit( oApl:oNit:CODIGO,oApl:oNit:DIGITO )
EndIf
If aChq == NIL .AND. ::aLS[2] <= 2
   AADD( ::aCG, { "","","","" } )
   cQry := "SELECT d.cuenta, d.infa, d.infb, d.infc, d.infd, "+;
                  "d.valor_deb, d.valor_cre, p.nombre "       +;
           "FROM cgeplan p, cgemovd d "                       +;
           "WHERE p.empresa = " + LTRIM(STR(oApl:nPuc))       +;
            " AND d.cuenta  = p.cuenta"                       +;
            " AND d.empresa = " + LTRIM(STR(oApl:nEmpresa))   +;
            " AND d.ano_mes = " + xValToChar( oApl:cPer )     +;
            " AND d.control = " + LTRIM(STR(::nCtl))          +;
            " AND d.libro   = " +       STR(::nLib,2)         +;
            " AND (LEFT(d.cuenta,2) = '11' OR LEFT(d.cuenta,4) = '1310')"
   ::hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
                 MSStoreResult( oApl:oMySql:hConnect ), 0 )
   ::nL := MSNumRows( ::hRes )
   While ::nL > 0
      cQry := MyReadRow( ::hRes )
      AEVAL( cQry, { | xV,nP | cQry[nP] := MyClReadCol( ::hRes,nP ) } )
      If InfAc( cQry[1],@nP,"CHEQUE    " )
         ::aCG[9,1] := cQry[nP+1]
         ::aCG[9,2] := cQry[8]
         ::aCG[9,3] := cQry[2]
      ElseIf LEFT( cQry[1],4 ) == "1105"
         ::aCG[9,4] := "X"
      EndIf
      ::aCG[6] += If( ::aLS[2] == 1, cQry[6], cQry[7] )
      ::nL --
   EndDo
   MSFreeResult( ::hRes )
Else
   ::aCG[6] := ::aLS[5]
   If aChq # NIL
      AADD( ::aCG, { aChq[1],aChq[2],aChq[3],aChq[4] } )
   EndIf
EndIf
If LEN( ::aCG ) >= 9
   ::aCG[9,1] := If( ::aLS[2] == 2, ::aCG[9,1], "" )
 //::aCG[9,2] := TRIM( ::aCG[9,2] ) + " CtaCte " + ::aCG[9,4]
Else
   AADD( ::aCG, { "","","","" } )
EndIf
 ::aTL := Letras( ::aCG[6],::aLS[19] )
 ::aCG[8] := If( ::aLS[2] == 1, "RECIBIDO DE  ", "BENEFICIARIO " )
If ::aLS[2] >= 3
   nP := 3
   If ::aLS[2] == 7
      ::aCG[1] := "NOTA DE CONTABILIDAD"
   EndIf
   ::aCG[1] += " No." + STR(::aLS[3])
   ::aCG[2] += "    " + oApl:oNit:NOMBRE
Else
   nP := If( ::aLS[7] == "N", 1, 2 )
   ::aCG[1] := "Comprobante de " + { "Ingreso","Egreso" }[::aLS[2]]
EndIf
// ::lPrev := MsgNoYes( "Vista Previa", ">>> Desea Ver <<<" )
If ::aLS[8] == "D"
   aChq := { {|| ::DosNForma() },{|| ::DosFForma() },;
             {|| ::DosNotas() } }
   EVAL( aChq[ nP ] )
   ::oPrn:NewPage()
   ::oPrn:End()
Else
/*
   If ::aLS[29]    //thoja
      // 8.5 Pulgadas ó 21.59 cm ó 2159 mm
      ::nAncho := 8.5 * 2.54 * 100
      //11.0 Pulgadas ó 27.94 cm ó 2794 mm
      ::nAlto  := ::aLS[29] * 42.33333333
   EndIf
*/
   //PrinterSetup()
   aChq := { {|| ::WinNForma() },{|| ::WinFForma() },;
             {|| ::WinNotas() } }
   ::Init( ::aCG[1], .t. ,, !::lPrev ,,, ::lPrev, 5 )
   PAGE
      EVAL( aChq[ nP ] )
   ENDPAGE
   IMPRIME END .F.
EndIf
RETURN NIL

//------------------------------------//
METHOD DosFForma() CLASS TLinot
 ::oPrn := TDosPrint()
 ::oPrn:New( oApl:cPuerto,oApl:cImpres,,::lPrev,1,1,::aLS[29],::aLS[29] )
 ::oPrn:nPage := 1
 ::CicloData( 22,TRANSFORM( ::aLS[3],"999999" ) )  //02,48
 ::CicloData( 09,NtChr( ::aLS[1],"3" ) )
 ::CicloData( 13,oApl:oNit:NOMBRE )
 ::CicloData( 15,::aCG[2] )
 ::oPrn:SetFont( ::oPrn:CPICompress,144,1 )
 ::CicloData( 17,::aTL[1] )
 //::aLS[17] ++
 //::CicloData( 17,::aTL[2] )
 //::aLS[17] --
 ::CicloData( 11,::oPrn:CPINormal+TRANSFORM( ::aCG[6],"9,999,999,999.99" ) )
 ::CicloData( 20,::aLS[4] )
 ::oPrn:SetFont( ::oPrn:CPINormal,82,1 )

 ::oPrn:nL := ::aLS[24]

 ::CicloDeta()
RETURN NIL

//------------------------------------//
METHOD DosNForma() CLASS TLinot
 ::oPrn := TDosPrint()
 ::oPrn:New( oApl:cPuerto,oApl:cImpres,{ ::aCG[1],STR(::aLS[3],6),;
             " P.U.C.              C O N C E P T O             "+;
             "D E B I T O     C R E D I T O" },::lPrev,1,1,::aLS[29],::aLS[29] )
 ::oPrn:nPage := 1
 ::oPrn:SetFont( ::oPrn:CPINormal,82,2 )
 ::oPrn:Say( 01,00,::oPrn:CPILarge+PADC( oApl:cEmpresa,43 ) )
 ::oPrn:Say( 02,30,oApl:oEmp:NOMBRE2 )
 ::oPrn:Say( 03,30,"NIT: " + oApl:oEmp:Nit )
 ::oPrn:Say( 04,02,::aCG[8]+ oApl:oNit:NOMBRE )
 ::oPrn:Say( 05,02,"Nit. o C.C.  " + ::aCG[2] )

 ::oPrn:Say( 06,02,"FECHA        " + NtChr( ::aLS[1],"3" ) )
 ::oPrn:Say( 06,57,::aCG[1] )
 ::oPrn:Say( 07,02,"Por Concepto de : " + ::aLS[4] + "  No." )
 ::oPrn:Say( 07,65,::oPrn:CPILarge + ::oPrn:aEnc[2] )
//::oPrn:Say( 08,06,::oPrn:CPICompress + aTL[1] )
//::oPrn:Say( 09,02,::oPrn:CPICompress + aTL[2] )
 ::oPrn:Say( 08,00,::oPrn:aEnc[3] )
 ::oPrn:Say( 09,00,REPLICATE("_",78) )
 ::oPrn:nL := 10
 ::CicloDeta()

 ::oPrn:Say(  ::oPrn:nL,45,REPLICATE("=",33),,,1 )
 ::oPrn:Say(++::oPrn:nL,33,"TOTALES ==>",,,1 )
 ::oPrn:Say(  ::oPrn:nL,45,TRANSFORM( ::aCG[3],"9,999,999,999.99" ) )
 ::oPrn:Say(  ::oPrn:nL,62,TRANSFORM( ::aCG[4],"9,999,999,999.99" ) )
If ::aLS[2] == 2
   If ::oPrn:nL <= ::aLS[29] - 5
      ::oPrn:nL := ::aLS[29] - 5
   Else
      ::oPrn:nL += 5
   EndIf
   //If ::aCG[9,4] == "X"
   //   ::oPrn:Say( ::oPrn:nL,02,"Efectivo " + ::aCG[9,3] )
   //EndIf
   If !EMPTY(::aCG[9,1])
      ::oPrn:Say( ::oPrn:nL  ,02,"Cheque No "+ ::aCG[9,1] )
      ::oPrn:Say( ::oPrn:nL+1,02,"Banco "    + ::aCG[9,2] )
      ::oPrn:Say( ::oPrn:nL+2,02,"CtaCte "   + ::aCG[9,3] )
   EndIf
   ::oPrn:Say(  ::oPrn:nL,24,"$" + LTRIM(TRANSFORM( ::aLS[5],"9,999,999,999.99" )) )
   ::oPrn:Say(  ::oPrn:nL,45,REPLICATE("_",34) )
   ::oPrn:Say(++::oPrn:nL,47,"Firma y sello del Beneficiario" )
   ::oPrn:Say(++::oPrn:nL,49,"C.C. - Nit" )
EndIf
RETURN NIL

//------------------------------------//
METHOD DosNotas() CLASS TLinot
 ::oPrn := TDosPrint()
 ::oPrn:New( oApl:cPuerto,oApl:cImpres,{::aCG[1] ,NtChr( ::aLS[1],"2" ) ,;
          "Tipo de Comprobante" + STR(::aLS[2],5), "NIT: " + ::aCG[2],;
          ::aLS[4]," P.U.C.              C O N C E P T O            "+;
          " D E B I T O     C R E D I T O"},::lPrev,,,,,78)
 ::CicloDeta()

 ::aCG[5] := ::aCG[3] - ::aCG[4]
 ::oPrn:Say(  ::oPrn:nL,45,REPLICATE("=",33),,,1 )
 ::oPrn:Say(++::oPrn:nL,33,"TOTALES ==>",,,1 )
 ::oPrn:Say(  ::oPrn:nL,45,TRANSFORM( ::aCG[3],"9,999,999,999.99" ) )
 ::oPrn:Say(  ::oPrn:nL,62,TRANSFORM( ::aCG[4],"9,999,999,999.99" ) )
 ::oPrn:Say(++::oPrn:nL,00,REPLICATE("_",78),,,1 )
 ::oPrn:Say(++::oPrn:nL,00,"PREPARADO      REVISADO        APROBADO",,,1 )
If ::aCG[5] # 0
   ::oPrn:Say(++::oPrn:nL,45,"Descuadre ==>" )
   ::oPrn:Say(  ::oPrn:nL,62,TRANSFORM( ::aCG[5],"9,999,999,999.99" ) )
EndIf
RETURN NIL

//------------------------------------//
METHOD WinFForma() CLASS TLinot

 ::CicloData( 22,TRANSFORM( ::aLS[3],"999999" ) )
//UTILPRN ::oUtil Self:aLS[09],Self:aLS[10] SAY NtChr( ::aLS[1],"2" )
 ::CicloData( 09,NtChr( ::aLS[1],"3" ) )
 ::CicloData( 13,oApl:oNit:NOMBRE )
 ::CicloData( 15,::aCG[2] )
 ::CicloData( 17,::aTL[1] )
 ::CicloData( 11,TRANSFORM( ::aCG[6],"9,999,999,999.99" ),1 )
 ::CicloData( 20,::aLS[4] )

 ::CicloDeta()

RETURN NIL

//------------------------------------//
METHOD WinNForma() CLASS TLinot
   LOCAL cPict := "9,999,999,999.99"
 ::CicloDeta()
 ::Cabecera( .t.,2.5,7.0 )

 UTILPRN ::oUtil BOX Self:nLinea-.1, 2.5 TO Self:nLinea+.4 ,19.3 ROUND 25,25
//UTILPRN ::oUtil LINEA Self:nLinea,2.5 TO Self:nLinea,19.2 PEN ::oPen
 UTILPRN ::oUtil Self:nLinea, 9.5 SAY "VALOR TOTAL ==> $"
 UTILPRN ::oUtil Self:nLinea,::aLS[27] SAY TRANSFORM( ::aCG[3],cPict ) RIGHT
 UTILPRN ::oUtil Self:nLinea,::aLS[28] SAY TRANSFORM( ::aCG[4],cPict ) RIGHT
 ::nLinea +=  .5
If ::aLS[2] == 2
   ::nL := ::nLinea
   //If ::aCG[9,4] == "X"
   //   UTILPRN ::oUtil Self:nLinea, 2.5 SAY "Efectivo"
   //   UTILPRN ::oUtil Self:nLinea, 5.5 SAY ::aCG[9,3]
   //EndIf
   If !EMPTY(::aCG[9,1])
      UTILPRN ::oUtil Self:nLinea, 2.5 SAY "Cheque No " + ::aCG[9,1]
      ::nLinea +=  .5
      UTILPRN ::oUtil Self:nLinea, 2.5 SAY "Banco "     + ::aCG[9,2]
      ::nLinea +=  .5
      UTILPRN ::oUtil Self:nLinea, 2.5 SAY "CtaCte "    + ::aCG[9,3]
   EndIf
   UTILPRN ::oUtil Self:nL, 6.5 SAY "$" + LTRIM(TRANSFORM( ::aLS[5],"9,999,999,999.99" ))
   ::nL += 1.5
   UTILPRN ::oUtil Self:nL,12.0 SAY REPLICATE("_",40)
   ::nL +=  .5
   UTILPRN ::oUtil Self:nL,12.2 SAY "Firma y sello del Beneficiario"
   ::nL +=  .5
   UTILPRN ::oUtil Self:nL,12.4 SAY "C.C. - Nit"
EndIf

RETURN .f.

//------------------------------------//
METHOD WinNotas() CLASS TLinot

 ::aLS[24]:= 6.5

 ::CicloDeta()

 ::aCG[5] := ::aCG[3] - ::aCG[4]
 ::Cabecera( .t.,.5,2.5 )
 UTILPRN ::oUtil Self:nLinea,19.2 SAY REPLICATE("=",34)                        RIGHT
 ::nLinea +=  .5
 UTILPRN ::oUtil Self:nLinea,10.5 SAY "TOTALES =========>  $" FONT ::aFnt[5]
 UTILPRN ::oUtil Self:nLinea,16.7 SAY TRANSFORM( ::aCG[3],"9,999,999,999.99" ) RIGHT
 UTILPRN ::oUtil Self:nLinea,19.2 SAY TRANSFORM( ::aCG[4],"9,999,999,999.99" ) RIGHT
 ::nLinea +=  .5
 UTILPRN ::oUtil LINEA Self:nLinea,2.5 TO Self:nLinea,19.2 PEN ::oPen
 ::nLinea +=  .5
 UTILPRN ::oUtil Self:nLinea, 2.5 SAY "PREPARADO      REVISADO        APROBADO"
 ::nLinea +=  .5
If ::aCG[5] # 0
   UTILPRN ::oUtil Self:nLinea,10.5 SAY "Descuadre =======>  $" FONT ::aFnt[5]
   UTILPRN ::oUtil Self:nLinea,19.2 SAY TRANSFORM( ::aCG[5],"9,999,999,999.99" ) RIGHT
EndIf
RETURN NIL

//------------------------------------//
METHOD CicloData( nP,xDat,nRight ) CLASS TLinot
If ::aLS[nP] # 0
   If ::aLS[8] == "D"
      ::oPrn:Say( ::aLS[nP],::aLS[nP+1],xDat )
   ElseIf nRight == NIL
      UTILPRN ::oUtil Self:aLS[nP],Self:aLS[nP+1] SAY xDat
   Else
      UTILPRN ::oUtil Self:aLS[nP],Self:aLS[nP+1] SAY xDat RIGHT
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD CicloDeta() CLASS TLinot
   LOCAL aRes, nL, nMIl, hRes, cPict := "@Z 9,999,999,999.99"
aRes := "SELECT d.cuenta, d.infa, d.valor_deb, d.valor_cre"+;
             ", p.nombre, n.codigo, n.digito, n.nombre "   +;
        "FROM cgeplan p, cgemovd d LEFT JOIN cadclien n "  +;
         "USING (codigo_nit) "                             +;
        "WHERE p.empresa = " + LTRIM(STR(oApl:nPuc))       +;
         " AND d.cuenta  = p.cuenta"                       +;
         " AND d.empresa = " + LTRIM(STR(oApl:nEmpresa))   +;
         " AND d.ano_mes = " + xValToChar( oApl:cPer )     +;
         " AND d.control = " + LTRIM(STR( ::nCtl ))        +;
         " AND d.libro   = " +       STR(::nLib,2)         +;
        " ORDER BY d.row_id"
//        "GROUP BY d.cuenta, d.codigo_nit"
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
If ::aLS[5] > 0
   nMil := ROUND( ::aLS[5] * .004,0 )
Else
   nMil := 0.5
EndIf
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If ::aLS[2] == 1 .AND. aRes[1] == oApl:oEmp:CARTERA .AND.;
      ::aLS[7] == "F"
      ::aCG[4] += aRes[4]
      ::aCG[7] += aRes[4]
    //::aCG[8] += ALLTRIM( ::oMvd:INFC ) + "-"
      nL --
      LOOP
   ElseIf ::aLS[2] == 2
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
   If ::aLS[08] == "D"
      ::oPrn:Titulo( 78,9,1 )
      ::oPrn:Say( ::oPrn:nL,::aLS[25],aRes[1] )
      If ::aLS[26] > 0
         ::oPrn:Say( ::oPrn:nL,::aLS[26],aRes[2] )
      EndIf
      ::oPrn:Say( ::oPrn:nL,::aLS[27],TRANSFORM( aRes[3],cPict ) )
      ::oPrn:Say( ::oPrn:nL,::aLS[28],TRANSFORM( aRes[4],cPict ) )
      ::oPrn:nL ++
   Else
      ::Cabecera( .t. )
      UTILPRN ::oUtil Self:nLinea,::aLS[25] SAY aRes[1]
      If ::aLS[26] > 0
         UTILPRN ::oUtil Self:nLinea,::aLS[26] SAY aRes[2]
      EndIf
      UTILPRN ::oUtil Self:nLinea,::aLS[27] SAY TRANSFORM( aRes[3],cPict ) RIGHT
      UTILPRN ::oUtil Self:nLinea,::aLS[28] SAY TRANSFORM( aRes[4],cPict ) RIGHT
   EndIf
   ::aCG[3] += aRes[3]
   ::aCG[4] += aRes[4]
   ::aCG[5] ++
   nL --
EndDo
MSFreeResult( hRes )
If ::aCG[7] > 0
   If ::aLS[08] == "D"
      ::oPrn:Titulo( 78,9,1 )
      ::oPrn:Say( ::oPrn:nL,::aLS[25],oApl:oEmp:CARTERA )
    //::oPrn:Say( ::oPrn:nL,::aLS[26],::aCG[8] )
      ::oPrn:Say( ::oPrn:nL,::aLS[28],TRANSFORM( ::aCG[7],cPict ) )
      ::oPrn:nL ++
   Else
      ::Cabecera( .t. )
      UTILPRN ::oUtil Self:nLinea,::aLS[25] SAY oApl:oEmp:CARTERA
    //UTILPRN ::oUtil Self:nLinea,::aLS[26] SAY ::aCG[8]
      UTILPRN ::oUtil Self:nLinea,::aLS[28] SAY TRANSFORM( ::aCG[7],cPict ) RIGHT
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Cabecera( lSep,nSpace,nSuma ) CLASS TLinot
If lSep .AND. !::lTit
   ::lTit := ::Separator( nSpace,nSuma )
EndIf
If ::lTit
/*
If ::aTL[3]
   ::Centrar( oApl:cEmpresa,::aFnt[4],1.0 )
   UTILPRN ::oUtil 1.5, 8.2 SAY "NIT: " + oApl:oEmp:Nit
   UTILPRN ::oUtil 2.0, 1.0 SAY oApl:oEmp:DIRECCION FONT ::aFnt[5]
   UTILPRN ::oUtil 2.0,13.0 SAY "COMPROBANTE DE"
   UTILPRN ::oUtil 2.5, 1.0 SAY oApl:oEmp:TELEFONOS FONT ::aFnt[5]
   UTILPRN ::oUtil 2.5,13.0 SAY cTit + TRANSFORM(::aLS[3],"9999999999")
   UTILPRN ::oUtil 3.0, 1.0 SAY oApl:cCiu FONT ::aFnt[5]
   UTILPRN ::oUtil 3.0,13.0 SAY "FECHA " + NtChr( ::aLS[1],"3" )

   UTILPRN ::oUtil BOX 3.5,1 TO 5.5,20 PEN ::oPen;
           ROUND 150,150
   UTILPRN ::oUtil 3.7, 1.2 SAY {"RECIBIDO DE","PAGADO A"}[ ::aLS[2] ];
           FONT ::aFnt[5]
   UTILPRN ::oUtil 4.2, 1.2 SAY ::aMov[11]
   If ::aLS[2] == 2
      UTILPRN ::oUtil 3.7,15.2 SAY "C.C. ó NIT." FONT ::aFnt[5]
      UTILPRN ::oUtil 4.2,15.2 SAY ::aCG[2]
      UTILPRN ::oUtil 4.7, 1.2 TO 4.7,19.8 PEN ::oPen
      UTILPRN ::oUtil 4.9, 1.2 SAY "LA SUMA DE"  FONT ::aFnt[5]
      UTILPRN ::oUtil 5.4, 1.2 SAY ::aTL[1]      FONT ::aFnt[5]
   //   UTILPRN ::oUtil 5.4,20.0 SAY TRANSFORM( ::aCG[6],"9,999,999,999.99" ) RIGHT
   EndIf
   UTILPRN ::oUtil 6.0, 3.5 SAY ::aLS[4]
   UTILPRN ::oUtil 6.5, 1.0 SAY "P.U.C."
   UTILPRN ::oUtil 6.5, 2.5 SAY "C O N C E P T O"
   UTILPRN ::oUtil 6.5,14.6 SAY "D E B I T O S"   RIGHT
   UTILPRN ::oUtil 6.5,17.3 SAY "C R E D I T O S" RIGHT
   UTILPRN ::oUtil 6.7, 1.0 TO 4.7,20.0 PEN ::oPen
   ::nLinea := 7.0
*/
   If ::aLS[7] == "N"
      ::Centrar( oApl:cEmpresa,::aFnt[4],1.0 )
      ::Centrar( oApl:oEmp:NOMBRE2,::aFnt[2],1.5 )
      ::Centrar( "NIT: " + oApl:oEmp:Nit,::aFnt[2],2.0 )
      UTILPRN ::oUtil SELECT ::aFnt[2]
      If ::aLS[2] >= 3
         ::FechaHora()
         ::Centrar( ::aCG[1],::aFnt[2],2.5 )
         UTILPRN ::oUtil 2.5,16.5 SAY "PAGINA" + STR(::nPage,4 )
         ::Centrar( NtChr( ::aLS[1],"2" ),::aFnt[2],3.0 )
         UTILPRN ::oUtil 3.5, 2.5 SAY "Tipo de Comprobante" + STR(::aLS[2],5)
         UTILPRN ::oUtil 4.0, 2.5 SAY "NIT: " + ::aCG[2]
         UTILPRN ::oUtil 4.5, 2.5 SAY ::aLS[4]
      Else
         UTILPRN ::oUtil 2.5, 2.5 SAY ::aCG[8]
         UTILPRN ::oUtil 2.5, 5.5 SAY oApl:oNit:NOMBRE
         UTILPRN ::oUtil 3.0, 2.5 SAY "Nit. o C.C."
         UTILPRN ::oUtil 3.0, 5.5 SAY ::aCG[2]
         UTILPRN ::oUtil 3.5, 2.5 SAY "FECHA"
         UTILPRN ::oUtil 3.5, 5.5 SAY NtChr( ::aLS[1],"3" )
         UTILPRN ::oUtil 3.5,14.5 SAY ::aCG[1]
         UTILPRN ::oUtil 4.0, 2.5 SAY "Por Concepto de : " + ::aLS[4]
         UTILPRN ::oUtil 4.0,16.0 SAY "No."
         UTILPRN ::oUtil 4.0,16.2 SAY STR(::aLS[3],7)  FONT ::aFnt[4]
         UTILPRN ::oUtil 4.5, 2.5 SAY "LA SUMA DE"
         UTILPRN ::oUtil 4.5, 5.5 SAY ::aTL[1] FONT ::aFnt[5]
         UTILPRN ::oUtil 5.0, 5.5 SAY ::aTL[2] FONT ::aFnt[5]
      EndIf
      UTILPRN ::oUtil BOX 5.4, 2.4 TO 5.9 ,19.3 ROUND 25,25
      UTILPRN ::oUtil 5.5, 2.5 SAY "Codigo P.U.C."
      UTILPRN ::oUtil 5.5, 8.0 SAY "C O N C E P T O"
      UTILPRN ::oUtil 5.5,16.7 SAY "DEBITO"               RIGHT
      UTILPRN ::oUtil 5.5,19.2 SAY "CREDITO"              RIGHT
      UTILPRN ::oUtil SELECT ::aFnt[5]
   EndIf
   ::lTit   := .F.
   ::nLinea := ::aLS[24]
EndIf
RETURN NIL