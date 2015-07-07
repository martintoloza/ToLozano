// Programa.: INOLICAT.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo Resumen de Ventas por Categorías.
#include "FiveWin.ch"

MEMVAR oApl

PROCEDURE InoLiCat( nOpc )
   LOCAL oDlg, oGet := ARRAY(6)
   LOCAL aRep, aOpc := { DATE(),DATE(),"N",.f. }
   DEFAULT nOpc := 1
aRep := { { {|| ListoCat( aOpc ) },"Resumen por Categorías" },;
          { {|| ListoEst( aOpc ) },"Resumen Unidades Estrategicas" } }

DEFINE DIALOG oDlg TITLE aRep[nOpc,2] FROM 0, 0 TO 09,44
   @ 02,00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 02,82 GET oGet[1] VAR aOpc[1] OF oDlg  SIZE 40,12 PIXEL
   @ 16,00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 16,82 GET oGet[2] VAR aOpc[2] OF oDlg ;
      VALID aOpc[2] >= aOpc[1] SIZE 40,12 PIXEL
   @ 30,00 SAY "DESEA  UN  RESUMEN [S/N]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 30,82 GET oGet[3] VAR aOpc[3] OF oDlg PICTURE "!";
      VALID aOpc[3] $ "NS"  SIZE 08,12 PIXEL
   @ 30,110 CHECKBOX oGet[4] VAR aOpc[4] PROMPT "Vista &Previa" OF oDlg;
       SIZE 60,12 PIXEL
   @ 46, 50 BUTTON oGet[5] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[5]:Disable(), EVAL( aRep[nOpc,1] ), oDlg:End() ) PIXEL
   @ 46,100 BUTTON oGet[6] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 52, 02 SAY "[INOLICAT]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED NOMODAL
RETURN

//------------------------------------//
STATIC PROCEDURE ListoCat( aLS )
   LOCAL oRpt, aGT, aRes, cQry, nL, nK
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"RESUMEN DE VENTAS POR CATEGORIAS" ,;
        "DESDE " + NtChr( aLS[1],"2" ) + " HASTA " + NtChr( aLS[2],"2" ),;
        "    C A T E G O R I A                             CANTIDAD  VA"+;
        "LOR VENTA" },aLS[4] )
cQry := "SELECT c.categoria, c.nombre, c.grupo, SUM(v.cantidad), SUM(v.precioven) "+;
        "FROM cadcateg c, cadinven i, cadventa v "                +;
        "WHERE i.categoria = c.categoria AND v.codigo = i.codigo "+;
         " AND v.empresa  = " + LTRIM(STR(oApl:nEmpresa))         +;
         " AND v.fecfac  >= " + xValToChar( aLS[1] )              +;
         " AND v.fecfac  <= " + xValToChar( aLS[2] )              +;
         " AND v.indicador <> 'A'"                                +;
        " GROUP BY c.categoria ORDER BY c.categoria"
oApl:oWnd:SetMsg("Ejecutando Consulta por ESPERE")
aRes := Buscar( cQry,"CM",,9 )
aGT  := { 0,0,0,0,0,aRes[1,3],LEN( aRes ) }
AEVAL( aRes, {| e | aGT[4] += e[5] } )

FOR nL := 1 TO LEN( aRes )
   nK := ROUND( aRes[nL,5] / aGT[4] * 100,2 )
   If aLS[3] == "N"
      oRpt:Titulo( 80 )
      oRpt:Say( oRpt:nL,04,aRes[nL,2] )
      oRpt:Say( oRpt:nL,49,TRANSFORM(aRes[nL,4],"999,999.9") )
      oRpt:Say( oRpt:nL,60,TRANSFORM(aRes[nL,5],"999,999,999") )
      oRpt:Say( oRpt:nL,73,TRANSFORM( nK       ,"999.99%") )
      oRpt:nL ++
   EndIf
   aGT[1]+= aRes[nL,4]
   aGT[2]+= aRes[nL,5]
   aGT[5]+= nK
   nK    := If( aGT[7] == nL, nL, nL+1 )
   If nK == nL .OR. aGT[6] # aRes[nK,3]
      oRpt:Say(  oRpt:nL,49,"=========  ===========  =======",,,1 )
      oRpt:Say(++oRpt:nL,04,"TOTAL " + aGT[6],,,1 )
      oRpt:Say(  oRpt:nL,49,TRANSFORM(aGT[1],"999,999.9") )
      oRpt:Say(  oRpt:nL,60,TRANSFORM(aGT[2],"999,999,999") )
      oRpt:Say(  oRpt:nL,73,TRANSFORM(aGT[5],"999.99%") )
      oRpt:nL += 2
      aGT[3] += aGT[1]
      aGT[1] := aGT[2] := aGT[5] := 0
      aGT[6] := aRes[nK,3]
   EndIf
NEXT nL
oRpt:Say(  oRpt:nL,04,REPLICATE("=",67),,,1 )
oRpt:Say(++oRpt:nL,04,"GRAN TOTAL DE VENTAS",,,1 )
oRpt:Say(  oRpt:nL,49,TRANSFORM(aGT[3],"999,999.9") )
oRpt:Say(  oRpt:nL,60,TRANSFORM(aGT[4],"999,999,999") )
oRpt:NewPage()
oRpt:End()
RETURN

//------------------------------------//
STATIC PROCEDURE ListoEst( aLS )
   LOCAL oRpt, aGT, aRes, cQry, nL, nK
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"UNIDADES ESTRATEGICAS DE NEGOCIO" ,;
        "DESDE " + NtChr( aLS[1],"2" ) + " HASTA " + NtChr( aLS[2],"2" ),;
        "    C A T E G O R I A                             CANTIDAD  VA"+;
        "LOR VENTA" },aLS[4] )
cQry := "SELECT e.sector, e.nombre, c.categoria, c.nombre, "+;
               "c.grupo, SUM(v.cantidad), SUM(v.precioven) "+;
        "FROM cadfactu u, cadclien n, cadestra e, "         +;
             "cadventa v, cadinven i, cadcateg c "          +;
        "WHERE u.empresa = " + LTRIM(STR(oApl:nEmpresa))    +;
         " AND u.fechoy >= " + xValToChar( aLS[1] )         +;
         " AND u.fechoy <= " + xValToChar( aLS[2] )         +;
         " AND u.tipo   = " + xValToChar(oApl:Tipo)         +;
         " AND u.indicador <> 'A'"                          +;
         " AND u.codigo_nit = n.codigo_nit "                +;
         " AND n.sectore = e.sector "                       +;
         " AND u.empresa = v.empresa "                      +;
         " AND u.numfac  = v.numfac "                       +;
         " AND u.tipo    = v.tipo "                         +;
         " AND v.codigo  = i.codigo "                       +;
         " AND i.categoria = c.categoria "                  +;
         " GROUP BY e.sector, c.categoria ORDER BY e.sector, c.categoria"
/*
FROM cadcateg c, cadinven i, cadventa v,
     cadestra e, cadclien n, cadfactu u
WHERE i.categoria = c.categoria
  AND v.codigo  = i.codigo
  AND u.empresa = v.empresa
  AND u.numfac  = v.numfac
  AND u.tipo    = v.tipo
  AND n.sectore = e.sector
  AND u.codigo_nit = n.codigo_nit
  AND u.empresa = 4
  AND u.fechoy >= '2006-04-01'
  AND u.fechoy <= '2006-04-30'
  AND u.tipo   = 'U'
  AND u.indicador <> 'A'
GROUP BY e.sector, c.categoria
ORDER BY e.sector, c.categoria
*/
oApl:oWnd:SetMsg("Ejecutando Consulta por ESPERE")
aRes := Buscar( cQry,"CM",,9 )
aGT  := { 0,0,0,0,0,0,0,0,aRes[1,2],aRes[1,5],LEN( aRes ) }
AEVAL( aRes, {| e | aGT[6] += e[7] } )

FOR nL := 1 TO LEN( aRes )
   nK := ROUND( aRes[nL,7] / aGT[6] * 100,2 )
   If aLS[3] == "N"
//    cQry := Buscar( "SELECT nombre FROM cadcateg WHERE categoria = "+;
//                    LTRIM(STR(aRes[nL,4])),"CM",,8,,1 )
      oRpt:Titulo( 80 )
      oRpt:Say( oRpt:nL,04,aRes[nL,4] )
      oRpt:Say( oRpt:nL,49,TRANSFORM(aRes[nL,6],"999,999.9") )
      oRpt:Say( oRpt:nL,60,TRANSFORM(aRes[nL,7],"999,999,999") )
      oRpt:Say( oRpt:nL,73,TRANSFORM( nK       ,"999.99%") )
      oRpt:nL ++
   EndIf
   aGT[1]+= aRes[nL,6]
   aGT[2]+= aRes[nL,7]
   aGT[7]+= nK
   nK    := If( aGT[11] == nL, nL, nL+1 )
   If nK == nL .OR. aGT[09] # aRes[nK,2] .OR. aGT[10] # aRes[nK,5]
      oRpt:Say(  oRpt:nL,49,"=========  ===========  =======",,,1 )
      oRpt:Say(++oRpt:nL,04,"TOTAL " + aGT[10],,,1 )
      oRpt:Say(  oRpt:nL,49,TRANSFORM(aGT[1],"999,999.9") )
      oRpt:Say(  oRpt:nL,60,TRANSFORM(aGT[2],"999,999,999") )
      oRpt:Say(  oRpt:nL,73,TRANSFORM(aGT[7],"999.99%") )
      oRpt:nL+= 2
      aGT[03] += aGT[1]
      aGT[04] += aGT[2]
      aGT[08] += aGT[7]
      aGT[01] := aGT[2] := aGT[7] := 0
      aGT[10] := aRes[nK,5]
      If nK == nL .OR. aGT[09] # aRes[nK,2]
//    cQry := Buscar( "SELECT nombre FROM cadestra WHERE sector = "+;
//                    LTRIM(STR(aRes[nL,4])),"CM",,8,,1 )
         oRpt:Say(  oRpt:nL,01,REPLICATE("=",79),,,1 )
         oRpt:Say(++oRpt:nL,04,"TOTAL " + aGT[09],,,1 )
         oRpt:Say(  oRpt:nL,49,TRANSFORM(aGT[3],"999,999.9") )
         oRpt:Say(  oRpt:nL,60,TRANSFORM(aGT[4],"999,999,999") )
         oRpt:Say(  oRpt:nL,73,TRANSFORM(aGT[8],"999.99%") )
         oRpt:Say(++oRpt:nL,01,REPLICATE("=",79),,,1 )
         oRpt:nL+= 3
         aGT[05] += aGT[3]
         aGT[03] := aGT[4] := aGT[8] := 0
         aGT[09] := aRes[nK,2]
      EndIf
   EndIf
NEXT nL
oRpt:Say(  oRpt:nL,04,REPLICATE("=",67),,,1 )
oRpt:Say(++oRpt:nL,04,"GRAN TOTAL DE VENTAS",,,1 )
oRpt:Say(  oRpt:nL,49,TRANSFORM(aGT[5],"999,999.9") )
oRpt:Say(  oRpt:nL,60,TRANSFORM(aGT[6],"999,999,999") )
oRpt:NewPage()
oRpt:End()
RETURN