// Programa.: CGEANEXO.PRG    >>> Martin A. Toloza L. <<<
// Notas....: ANEXOS AL BALANCE DE PRUEBA
#include "Fivewin.ch"
#include "btnget.ch"
#INCLUDE "Utilprn.CH"

MEMVAR oApl

FUNCTION CgeAnexo()
   LOCAL oA, oCt, oDlg, oGet := ARRAY(12)
 oA  := TAnexo();  oA:New()
 oCt := TPuc()  ; oCt:New()
DEFINE DIALOG oDlg TITLE oA:aEnc[2] FROM 0, 0 TO 14,76
   @ 02,00 SAY "CUENTA INICIAL" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 02,72 BTNGET oGet[1] VAR oA:aLS[1] OF oDlg     PICTURE "9999999999" ;
      VALID If( oCt:oDb:Seek( {"empresa",oApl:nPUC,"cuenta",oA:aLS[1]} ),;
              ( oGet[2]:setText( oCt:oDb:NOMBRE ), .t. )     ,;
              ( MsgStop( "Está Cuenta NO EXISTE !!!" ), .f. ));
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"                     ;
      ACTION EVAL({|| If(oCt:Mostrar(), (oA:aLS[1] := oCt:oDb:CUENTA,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
//            ( oA:aLS[7] := oCt:oDb:NOMBRE, oDlg:Update(), .t. ),;
   @ 02,130 SAY oGet[2] VAR oA:aLS[7] OF oDlg PIXEL SIZE 170,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 14,00 SAY "CUENTA   FINAL" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 14,72 BTNGET oGet[3] VAR oA:aLS[2] OF oDlg     PICTURE "9999999999" ;
      VALID If( oCt:oDb:Seek( {"empresa",oApl:nPUC,"cuenta",oA:aLS[2]} ),;
              ( oGet[4]:setText( oCt:oDb:NOMBRE ), .t. )     ,;
              ( MsgStop( "Está Cuenta NO EXISTE !!!" ), .f. ));
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"                     ;
      ACTION EVAL({|| If(oCt:Mostrar(), (oA:aLS[2] := oCt:oDb:CUENTA,;
                        oGet[3]:Refresh(), oGet[3]:lValid(.f.)),)})
   @ 14,130 SAY oGet[4] VAR oA:aLS[8] OF oDlg PIXEL SIZE 170,10 ;
      UPDATE COLOR nRGB( 160,19,132 )
   @ 26,00 SAY "PERIODO [AAAAMM]"    OF oDlg RIGHT PIXEL SIZE 70,10
   @ 26,72 GET oGet[5] VAR oA:aLS[3] OF oDlg PICTURE "999999" SIZE 36,10 PIXEL;
      VALID NtChr( oA:aLS[3],"P" )
   @ 38,00 SAY "REGISTRADO"          OF oDlg RIGHT PIXEL SIZE 70,10
   @ 37,72 CHECKBOX oGet[6] VAR oA:aLS[4] PROMPT " " OF oDlg SIZE 14,10 PIXEL
   @ 50,00 SAY "Libro" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 50,82 COMBOBOX oGet[7] VAR oA:aLS[9] ITEMS { "COLGAAP","IFRS" };
      SIZE 48,90 OF oDlg PIXEL;
      WHEN !EMPTY(oApl:oEmp:NIIF) .AND. oA:aLS[3] >= oApl:oEmp:NIIF
   // WHEN oApl:oEmp:NIIF
   @ 62,00 SAY "TIPO DE IMPRESORA"   OF oDlg RIGHT PIXEL SIZE 70,10
   @ 62,72 COMBOBOX oGet[8] VAR oA:aLS[5] ITEMS { "Matriz","Laser" };
      SIZE 48,90 OF oDlg PIXEL
   @ 62,124 CHECKBOX oGet[9] VAR oA:aLS[6] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 74,00 SAY "Escoja la Fuente"  OF oDlg RIGHT PIXEL SIZE 70,10
   @ 74,72 COMBOBOX oGet[10] VAR oA:cFont ITEMS oA:aFont SIZE 80,99 OF oDlg PIXEL;
      WHEN oA:aLS[5] > 1
   @ 88, 50 BUTTON oGet[11] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[11]:Disable(), oA:ArmarMOV( oDlg ), oDlg:End() ) PIXEL
   @ 88,100 BUTTON oGet[12] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 94, 02 SAY "[CGEANEXO]" OF oDlg PIXEL SIZE 34,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT Empresa( .t. )
RETURN NIL

//------------------------------------//
CLASS TAnexo FROM TIMPRIME

 DATA aLS, aMV, hRes, nL
 DATA oAne

 METHOD NEW() Constructor
 METHOD ArmarMOV( oDlg )
 METHOD ListoDOS( oRpt )
 METHOD Cabecera( lSep,nSpace,nSuma )

ENDCLASS

//------------------------------------//
METHOD NEW() CLASS TAnexo
   LOCAL hDC := GetDC( 0 )
 ::aFont:= GetFontNames( hDC )
 ::aLS  := { SPACE(10),SPACE(10),NtChr( DATE(),"1" ),.f.,oApl:nTFor,.t.,"","",1 }
 ::aMV  := { 0,0,0,0,0,"@Z 9999999999","##,###,###,###.##" }
 ::aEnc := { .t.,"ANEXOS AL BALANCE DE PRUEBA","" }
 ::cFont:= "Arial"
RETURN NIL

//------------------------------------//
METHOD ArmarMOV( oDlg ) CLASS TAnexo
   LOCAL aV, nA, nC, oRpt
oDlg:SetText( "POR FAVOR << ESPERE >>" )
::aLS[2] := PADR( ALLTRIM(::aLS[2]),10,"9" )
::aLS[8] := STR( VAL( LEFT(::aLS[3],4) )-1,4 )+ "13"
/*
SELECT p.cuenta CTA, p.nivel, p.nombre, 0 NIT, '' COD, SUM(a.valor_deb-a.valor_cre)
FROM cgeplan p, cgeacumn a
WHERE p.empresa  = 2
  AND p.nivel   >= 2
  AND a.empresa  = 2
  AND LEFT( a.cuenta,LENGTH(p.cuenta) ) = p.cuenta
  AND a.ano_mes >= '201113'
  AND a.ano_mes <= '201210'
  AND a.cuenta  >= '1'
  AND a.cuenta  <= '29999999'
GROUP BY p.cuenta
UNION
SELECT a.cuenta CTA, 4, n.nombre,
   IF( a.codigo_nit = 0, 0, n.codigo ) NIT, a.codigo COD, SUM(a.valor_deb-a.valor_cre)
FROM cgeacumn a LEFT JOIN cadclien n
 USING (codigo_nit)
WHERE a.empresa  = 2
  AND a.ano_mes >= '201113'
  AND a.ano_mes <= '201210'
  AND a.cuenta  >= '1'
  AND a.cuenta  <= '29999999'
GROUP BY a.cuenta, NIT, COD
ORDER BY CTA, NIT, COD
*/
aV   :=  " AND a.ano_mes >= " + xValToChar( ::aLS[8] )    +;
         " AND a.ano_mes <= " + xValToChar( ::aLS[3] )    +;
         " AND a.cuenta  >= " + xValToChar( ::aLS[1] )    +;
         " AND a.cuenta  <= " + xValToChar( ::aLS[2] )    +;
         " AND a.libro    = " +  LTRIM(STR( ::aLS[9] ))
oRpt := "SELECT p.cuenta CTA, p.nivel, p.nombre, 0 NIT, '' COD, SUM(a.valor_deb-a.valor_cre) "   +;
        "FROM cgeplan p, cgeacumn a "                     +;
        "WHERE p.empresa  = " + LTRIM(STR(oApl:nPUC))     +;
         " AND p.nivel   >= 2"                            +;
         " AND a.empresa  = " + LTRIM(STR(oApl:nEmpresa)) +;
         " AND LEFT( a.cuenta,LENGTH(p.cuenta) ) = p.cuenta "+;
         aV + " GROUP BY p.cuenta  UNION "                +;
        "SELECT a.cuenta CTA, 4, n.nombre, "              +;
           "IF( a.codigo_nit = 0, 0, n.codigo ) NIT, a.codigo COD, SUM(a.valor_deb-a.valor_cre) "+;
        "FROM cgeacumn a LEFT JOIN cadclien n "           +;
         "USING (codigo_nit) "                            +;
        "WHERE a.empresa  = " + LTRIM(STR(oApl:nEmpresa)) +;
         aV + " GROUP BY a.cuenta, a.codigo_nit, NIT, COD"+;
        " ORDER BY CTA, NIT, COD"
 ::hRes := If( MSQuery( oApl:oMySql:hConnect,oRpt ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes )
   RETURN NIL
EndIf
/*
oRpt := "SELECT a.cuenta, n.codigo, a.codigo, n.nombre, SUM(a.valor_deb-a.valor_cre) "+;
        "FROM cgeacumn a LEFT JOIN cadclien n ON a.codigo_nit = n.codigo_nit "    +;
        "WHERE a.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND a.ano_mes >= " + xValToChar( ::aLS[8] )  +;
         " AND a.ano_mes <= " + xValToChar( ::aLS[3] )  +;
         " AND a.cuenta  >= " + xValToChar( ::aLS[1] )  +;
         " AND a.cuenta  <= " + xValToChar( ::aLS[2] )  +;
         " GROUP BY a.cuenta, n.codigo, a.codigo"       +;
         " ORDER BY a.cuenta, n.codigo, a.codigo"
 ::hRes := If( MSQuery( oApl:oMySql:hConnect,oRpt ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes )
   RETURN NIL
EndIf
::oAne := oApl:Abrir( "cgeanexo","cuenta, codigo, codvar",,.t. )
While ::nL > 0
   aV := MyReadRow( ::hRes )
   AEVAL( aV, {| xV,nP | aV[nP] := MyClReadCol( ::hRes,nP ) } )
   If aV[5] # 0
      nA := 10
      FOR nC := 1 TO 4 //6
         ::aLS[8] := aV[1] + STR(aV[2],10) + aV[3] ; oDlg:Update()
         If ::oAne:Seek( {"cuenta",aV[1],"codigo",aV[2],"codvar",aV[3]} )
            ::oAne:VALOR += aV[5]  ; ::oAne:Update(.f.,1)
         Else
            aV[1] := ALLTRIM( aV[1] )
            If EMPTY( aV[2] )
               aV[4] :=  Buscar( {"empresa",oApl:nPUC,"cuenta",aV[1]},;
                                 "cgeplan","nombre",8 )
            EndIf
            ::oAne:NIVEL  := If( LEN( aV[1] ) == 1, 0, LEN( aV[1] )/2 )
            ::oAne:CUENTA := aV[1] ; ::oAne:CODIGO := aV[2]
            ::oAne:CODVAR := aV[3] ; ::oAne:NOMBRE := aV[4]
            ::oAne:VALOR  := aV[5] ; ::oAne:Append()
         EndIf
         nA    -= If( nC == 5, 1, 2)
         aV[1] := LEFT( aV[1],nA )
         aV[2] := 0
         aV[3] := ""
      NEXT nC
   EndIf
   ::nL --
EndDo
 ::oAne:Seek( {"valor <>",0},"cuenta, codigo, codvar" )
*/
 ::aEnc[2] += { " COLGAAP"," IFRS" }[::aLS[9]]
 ::aEnc[3] := NtChr( NtChr( ::aLS[3],"F" ),"6" )
If ::aLS[5] == 1
   oRpt := TDosPrint()
   oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[2],::aEnc[3],;
         "CUENTA   NIT        CODIGO     NOMBRE CUENTA" + SPACE(26) +;
         "AUXILIAR #2       AUXILIAR #1         SUBCUENTA            CUENTA"},::aLS[6],,2 )
   oRpt:lTimbrado := ::aLS[4]
      ::ListoDOS( oRpt )
   oRpt:NewPage()
   oRpt:End()
Else
   ::Init( ::aEnc[2], .f. ,, !::aLS[6] ,,,, 5 )
     PAGE
       ::ListoDOS()
     ENDPAGE
   IMPRIME END .F.
EndIf
MSFreeResult( ::hRes )
/*
 ::oAne:Destroy()
MSQuery( oApl:oMySql:hConnect,"DROP TABLE cgeanexo" )
oApl:oDb:GetTables()
*/
RETURN NIL

//------------------------------------//
METHOD ListoDOS( oRpt ) CLASS TAnexo
   LOCAL aV, nA, nC
While ::nL > 0
   aV := MyReadRow( ::hRes )
   AEVAL( aV, {| xV,nP | aV[nP] := MyClReadCol( ::hRes,nP ) } )
   If aV[6] # 0
      If !EMPTY( aV[4] ) .OR. !EMPTY( aV[5] )
         nA := 1 ; nC := 64
         aV[3] := If( EMPTY( aV[3] ), ::aLS[7], aV[3] )
      Else
         nA :=   6 - aV[2]
         nC := 154 - aV[2] * 18
         ::aLS[7] := aV[3]
      EndIf
      If ::aLS[5] == 1
         oRpt:Titulo( 136 )
         oRpt:Say( oRpt:nL,00,aV[1] )
         oRpt:Say( oRpt:nL,10,TRANSFORM( aV[4],::aMV[6] ) )
         oRpt:Say( oRpt:nL,21,aV[5] )
         oRpt:Say( oRpt:nL,32,LEFT( aV[3],31 ) )
         oRpt:Say( oRpt:nL,nC,TRANSFORM( aV[6],::aMV[7] ) )
         oRpt:nL++
      Else
         nC := (nA * 2.4) + 10.9
         ::Cabecera( .t. )
         UTILPRN ::oUtil Self:nLinea,00.7 SAY aV[1]
         UTILPRN ::oUtil Self:nLinea,03.8 SAY TRANSFORM( aV[4],::aMV[6] ) RIGHT
         UTILPRN ::oUtil Self:nLinea,04.0 SAY aV[5]
         UTILPRN ::oUtil Self:nLinea,05.6 SAY LEFT( aV[3],35 )
         UTILPRN ::oUtil Self:nLinea, nC  SAY TRANSFORM( aV[6],::aMV[7] ) RIGHT
      EndIf
      ::aMV[nA] += aV[6]
      ::aMV[nA] := ROUND(::aMV[nA],2)
   EndIf
   ::nL --
EndDo
If ::aLS[5] == 1
   oRpt:Say( oRpt:nL,01,REPLICATE("_",136) )
Else
   ::nLinea += 0.5
   UTILPRN ::oUtil LINEA Self:nLinea,1.0 TO Self:nLinea,20.5 PEN ::oPen
EndIf
 ::aMV[5] := ::aMV[4]
 ::aMV[6] := "AUXILIAR #2AUXILIAR #1SUBCUENTA  CUENTA     GRUPO      CLASE      "
FOR nA := 1 TO 4
   If ::aMV[nA] # ::aMV[nA+1]
      If ::aLS[5] == 1
         oRpt:Titulo( 136 )
         oRpt:Say(++oRpt:nL,32,SUBSTR( ::aMV[6],nA*11-10,11 ) + " DESCUADRADO" )
         oRpt:Say(  oRpt:nL,68,TRANSFORM( ::aMV[nA],::aMV[7] ) )
      Else
         ::Cabecera( .t. )
         UTILPRN ::oUtil Self:nLinea,05.6 SAY SUBSTR( ::aMV[6],nA*11-10,11 ) + " DESCUADRADO"
         UTILPRN ::oUtil Self:nLinea,13.3 SAY TRANSFORM( ::aMV[nA],::aMV[7] ) RIGHT
      EndIf
   EndIf
NEXT
RETURN NIL
/*
//------------------------------------//
METHOD ListoDOS( oRpt ) CLASS TAnexo
   LOCAL nA, nC
While !::oAne:EOF()
   If !EMPTY(::oAne:CODIGO) .OR. !EMPTY(::oAne:CODVAR)
      nA := 1 ; nC := 64
   Else
      nA :=   6 - ::oAne:NIVEL
      nC := 154 - ::oAne:NIVEL * 18
   EndIf
   If ::aLS[5] == 1
      oRpt:Titulo( 136 )
      oRpt:Say( oRpt:nL,00,TRIM(::oAne:CUENTA ) )
      oRpt:Say( oRpt:nL,10,TRANSFORM( ::oAne:CODIGO,::aMV[6] ) )
      oRpt:Say( oRpt:nL,21,::oAne:CODVAR )
      oRpt:Say( oRpt:nL,32,LEFT( ::oAne:NOMBRE,31 ) )
      oRpt:Say( oRpt:nL,nC,TRANSFORM( ::oAne:VALOR,::aMV[7] ) )
      oRpt:nL++
   Else
      nC := (nA * 2.4) + 10.9
      ::Cabecera( .t. )
      UTILPRN ::oUtil Self:nLinea,00.7 SAY ::oAne:CUENTA
      UTILPRN ::oUtil Self:nLinea,03.8 SAY TRANSFORM( ::oAne:CODIGO,::aMV[6] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,04.0 SAY ::oAne:CODVAR
      UTILPRN ::oUtil Self:nLinea,05.6 SAY LEFT( ::oAne:NOMBRE,35 )
      UTILPRN ::oUtil Self:nLinea, nC  SAY TRANSFORM( ::oAne:VALOR ,::aMV[7] ) RIGHT
   EndIf
   ::aMV[nA] += ::oAne:VALOR
   ::aMV[nA] := ROUND(::aMV[nA],2)
   ::oAne:Skip(1):Read()
   ::oAne:xLoad()
EndDo
If ::aLS[5] == 1
   oRpt:Say( oRpt:nL,01,REPLICATE("_",136) )
Else
   ::nLinea += 0.5
   UTILPRN ::oUtil LINEA Self:nLinea,1.0 TO Self:nLinea,20.5 PEN ::oPen
EndIf
 ::aMV[5] := ::aMV[4]
 ::aMV[6] := "AUXILIAR #2AUXILIAR #1SUBCUENTA  CUENTA     GRUPO      CLASE      "
FOR nA := 1 TO 4
   If ::aMV[nA] # ::aMV[nA+1]
      If ::aLS[5] == 1
         oRpt:Titulo( 136 )
         oRpt:Say(++oRpt:nL,32,SUBSTR( ::aMV[6],nA*11-10,11 ) + " DESCUADRADO" )
         oRpt:Say(  oRpt:nL,68,TRANSFORM( ::aMV[nA],::aMV[7] ) )
      Else
         ::Cabecera( .t. )
         UTILPRN ::oUtil Self:nLinea,05.6 SAY SUBSTR( ::aMV[6],nA*11-10,11 ) + " DESCUADRADO"
         UTILPRN ::oUtil Self:nLinea,13.3 SAY TRANSFORM( ::aMV[nA],::aMV[7] ) RIGHT
      EndIf
   EndIf
NEXT
RETURN NIL
*/
//------------------------------------//
METHOD Cabecera( lSep,nSpace,nSuma ) CLASS TAnexo
If lSep .AND. !::aEnc[1]
   ::aEnc[1] := ::Separator( nSpace,nSuma )
EndIf
If ::aEnc[1]
   ::aEnc[1] := .F.
   If !::aLS[4]
      ::Centrar( oApl:cEmpresa,::aFnt[4],1.0 )
      UTILPRN ::oUtil 1.5, 8.2 SAY "NIT: " + oApl:oEmp:Nit
      ::Centrar( ::aEnc[2],,2.0 )
   EndIf
      ::Centrar( ::aEnc[3],,2.5 )
      UTILPRN ::oUtil 3.0, 0.7 SAY "CUENTA        NIT"
      UTILPRN ::oUtil 3.0, 4.0 SAY "CODIGO"
      UTILPRN ::oUtil 3.0, 5.6 SAY "NOMBRE CUENTA"
      UTILPRN ::oUtil 3.0,13.3 SAY "AUXILIAR #2"   RIGHT
      UTILPRN ::oUtil 3.0,15.7 SAY "AUXILIAR #1"   RIGHT
      UTILPRN ::oUtil 3.0,18.1 SAY "SUBCUENTA"     RIGHT
      UTILPRN ::oUtil 3.0,20.5 SAY "CUENTA"        RIGHT
      UTILPRN ::oUtil LINEA 3.5,1.0 TO 3.5,20.5 PEN ::oPen
   ::nLinea := 3.5
EndIf
RETURN NIL