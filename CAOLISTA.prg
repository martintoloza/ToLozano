// Programa.: CAOLISTA.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Modulo para listar las Tablas
#include "FiveWin.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE Listados( nOpc,cOrden )
   LOCAL aLS, oBtn, oDlg, oLF
oLF := TListar()
aLS := { { {|| oLF:ListoArt( cOrden ) },"PRECIOS AL PUBLICO DE ARTICULOS" },;
         { {|| ListoCan() },"Listo Facturas Canceladas" } }
DEFINE DIALOG oDlg TITLE aLS[nOpc,2]
   @ 02,62 CHECKBOX oLF:aLS[1] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,10 PIXEL
   @ 14,00 SAY "TIPO DE IMPRESORA" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 14,62 COMBOBOX oLF:aLS[2] ITEMS { "Matriz","Laser" };
      SIZE 44,90 OF oDlg PIXEL

   @ 38,70 BUTTON oBtn PROMPT "Imprimir" SIZE 44,12 ;
      ACTION ( oBtn:Disable(), EVAL( aLS[nOpc,1] ), oDlg:End() ) OF oDlg PIXEL
ACTIVATE DIALOG oDlg CENTER
RETURN

//------------------------------------//
CLASS TListar FROM TIMPRIME

 DATA aLS  AS ARRAY INIT { .t.,oApl:nTFor,.f. }

 METHOD ListoArt( cOrden )
// METHOD LaserSal( nL,hRes )
// METHOD ListoCan()
// METHOD LaserCan( nL,hRes )
// METHOD Query( nH,aGT )
ENDCLASS

//------------------------------------//
METHOD ListoArt( cOrden ) CLASS TListar
   LOCAL aLI, cQry, hRes, nL, oRpt
cQry := "SELECT codigo, descrip, unidadmed, ppubli, linea, indiva FROM cadinven"+;
        " ORDER BY " + cOrden
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
cQry := ""
If ::aLS[2] == 1
   oRpt := TDosPrint()
   oRpt:New( oApl:cPuerto,oApl:cImpres,{"PRECIOS AL PUBLICO",NtChr( DATE(),"3" ),;
             " C O D I G O-  D E S C R I P C I O N" + SPACE(26) + "PRECIO PUBLICO"},::aLS[1] )
Else
   ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit       ,;
               "PRECIOS AL PUBLICO",NtChr( DATE(),"3" ),;
               { .F., 0.6,"C O D I G O" }, { .F., 4.0,"D E S C R I P C I O N" },;
               { .T.,20.4,"PRECIO PUBLICO" } }
   ::Init( ::aEnc[4], .f. ,, !::aLS[1] ,,, ::aLS[1] )
   ::nMD := 20.5
    PAGE
EndIf
While nL > 0
   aLI := MyReadRow( hRes )
   AEVAL( aLI, { | xV,nP | aLI[nP] := MyClReadCol( hRes,nP ) } )
   If LEN( TRIM(aLI[1]) ) < oApl:oEmp:LENCOD
      aLI[4] := 0
   EndIf
   If cQry  # aLI[5] .AND. cOrden == "codigo"
      cQry := aLI[5]
      aLI[5] := Buscar( { "linea",cQry },"cadlinea","nombre",8 )
      ::aLS[3] := .t.
   EndIf
   If ::aLS[2] == 1
      oRpt:Titulo( 75 )
      If ::aLS[3]
         ::aLS[3] := .f.
         oRpt:Say( oRpt:nL,15,aLI[5] )
         oRpt:nL++
      EndIf
      oRpt:Say( oRpt:nL,01,aLI[1] )
      oRpt:Say( oRpt:nL,15,aLI[2] + "  " + aLI[3] )
      oRpt:Say( oRpt:nL,62,TRANSFORM(aLI[4],"@Z 999,999,999.99") )
//   oRpt:Say( oRpt:nL,57,If( aLI[6], "*", "" ) )
      oRpt:nL++
   Else
         ::Cabecera( .t.,0.42 )
      If ::aLS[3]
         ::aLS[3] := .f.
         UTILPRN ::oUtil Self:nLinea, 4.0 SAY aLI[5]
         ::nLinea += 0.42
      EndIf
         UTILPRN ::oUtil Self:nLinea, 0.6 SAY aLI[1]
         UTILPRN ::oUtil Self:nLinea, 4.0 SAY aLI[2]
         UTILPRN ::oUtil Self:nLinea,15.0 SAY aLI[3]
         UTILPRN ::oUtil Self:nLinea,20.4 SAY TRANSFORM(aLI[4],"@Z 999,999,999.99") RIGHT
    EndIf
   nL --
EndDo
MSFreeResult( hRes )
If ::aLS[2] == 1
   oRpt:NewPage()
   oRpt:End()
Else
    ENDPAGE
   ::EndInit( .F. )
EndIf
RETURN NIL