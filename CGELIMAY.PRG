// Programa.: CGELIMAY.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listado de Mayor y Balance Ajustado.
#include "Fivewin.ch"
#INCLUDE "Utilprn.CH"

MEMVAR oApl

PROCEDURE CgeLiMay()
   LOCAL oA, oDlg, oGet := ARRAY(8)
 oA := TLimay() ; oA:New()
DEFINE DIALOG oDlg TITLE oA:aEnc[2] FROM 0, 0 TO 12,46
   @ 02,00 SAY "PERIODO [AAAAMM]"  OF oDlg RIGHT PIXEL SIZE 70,10
   @ 02,72 GET oGet[1] VAR oA:aLS[1] OF oDlg PICTURE "999999" SIZE 32,10 PIXEL;
      VALID NtChr( oA:aLS[1],"P" )
   @ 14,00 SAY "NIVEL [2/3/4]"     OF oDlg RIGHT PIXEL SIZE 70,10
   @ 14,72 COMBOBOX oGet[2] VAR oA:aLS[2] ITEMS { "Cuenta(4)","SubCuenta(6)","Auxiliar(8)" };
      SIZE 48,90 OF oDlg PIXEL
   @ 26,00 SAY "Libro" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 26,72 COMBOBOX oGet[3] VAR oA:aLS[5] ITEMS { "COLGAAP","IFRS" };
      SIZE 48,90 OF oDlg PIXEL;
      WHEN !EMPTY(oApl:oEmp:NIIF) .AND. oA:aLS[1] >= oApl:oEmp:NIIF
   @ 38,00 SAY "CLASE DE LISTADO"  OF oDlg RIGHT PIXEL SIZE 70,10
   @ 38,72 COMBOBOX oGet[4] VAR oA:aLS[3] ITEMS { "Matriz","Laser","Excel" };
      SIZE 48,90 OF oDlg PIXEL
   @ 38,124 CHECKBOX oGet[5] VAR oA:aLS[4] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 50,00 SAY "Escoja la Fuente"  OF oDlg RIGHT PIXEL SIZE 70,10
   @ 50,72 COMBOBOX oGet[6] VAR oA:cFont ITEMS oA:aFont SIZE 80,99 OF oDlg PIXEL;
      WHEN oA:aLS[3] > 1
   @ 64, 50 BUTTON oGet[7] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[7]:Disable(), oA:ArmarMOV( oDlg ), oGet[7]:Enable(),;
        oGet[7]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 64,100 BUTTON oGet[8] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 70, 02 SAY "[CGELIMAY]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT ( Empresa( .t. ) )
RETURN

//------------------------------------//
CLASS TLimay FROM TIMPRIME

 DATA aLS, aMV, aRS, hRes, nL

 METHOD NEW() Constructor
 METHOD ArmarMOV( oDlg )
 METHOD ListoDOS( oDlg )
 METHOD Lineas()
 METHOD Cabecera( lSep,nSpace )
 METHOD ExcelBal()
 METHOD LBalance()

ENDCLASS

//------------------------------------//
METHOD NEW() CLASS TLimay
   LOCAL hDC := GetDC( 0 )
 ::aFont:= GetFontNames( hDC )
 ::aLS  := { NtChr( DATE(),"1" ),3,oApl:nTFor,.t.,1,"" }
 ::aEnc := { .t.,"LIBRO DE MAYOR Y BALANCE AJUSTADO","" }
 ::cFont := "Arial"
RETURN NIL

//------------------------------------//
METHOD ArmarMOV( oDlg ) CLASS TLimay
   LOCAL aV, cPerI, cPerF
 ::aEnc[3] := NtChr( ::aLS[1],"F" )
 cPerI := STR( VAL( LEFT(::aLS[1],4) )-1,4 ) + "13"
 cPerF := If( RIGHT( ::aLS[1],2 ) == "13", STUFF( ::aLS[1],5,2,"12" ),;
              NtChr( ::aEnc[3]-1,"1" ) )
 cPerF := If( cPerF < cPerI, cPerI, cPerF )
aV := "SELECT p.cuenta, p.nivel, p.nombre, SUM(c.valor_deb), SUM(c.valor_cre), 'S' "+;
      "FROM cgeplan p, cgeacumc c "                   +;
      "WHERE p.empresa = " + LTRIM(STR(oApl:nPUC))    +;
       " AND p.nivel  <= " + LTRIM(STR(::aLS[2]+1))   +;
       " AND p.estado  = 'A'"                         +;
       " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
       " AND LEFT( c.cuenta,LENGTH(p.cuenta) ) = p.cuenta"+;
       " AND c.libro   = " +       STR(::aLS[5],2)
//     " AND LEFT(c.cuenta,p.nivel*2) = p.cuenta "
aV +=  " AND c.ano_mes >= " + xValToChar( cPerI )     +;
       " AND c.ano_mes <= " + xValToChar( cPerF )     +;
       " GROUP BY p.cuenta UNION " + STRTRAN( aV,"'S'","'M'" ) +;
       " AND c.ano_mes = "  + xValToChar( ::aLS[1] )  +;
       " GROUP BY p.cuenta ORDER BY cuenta"
::hRes := If( MSQuery( oApl:oMySql:hConnect,aV ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes ) ; RETURN NIL
EndIf
 ::aRS := MyReadRow( ::hRes )
 AEVAL( ::aRS, {| xV,nP | ::aRS[nP] := MyClReadCol( ::hRes,nP ) } )
 ::aMV := { ::aRS[1],::aRS[2],::aRS[3],0,0,0,0,"",.f.,0,0,0,0,"99,999,999,999.99" }
 ::aEnc[2] += NtChr( ::aLS[5],"CI" )
 ::aEnc[3] := NtChr( ::aEnc[3],"6" )
If ::aLS[3] == 1
   ::ListoDOS( oDlg )
ElseIf ::aLS[3] == 2
   ::Init( ::aEnc[2], .f. ,, !::aLS[4] ,,,, 5 )
     PAGE
       ::Lineas()
     ENDPAGE
   IMPRIME END .F.
   ::aEnc[1] := .T.
Else
   ::ExcelBal()
EndIf
 MSFreeResult( ::hRes )
 ::aEnc[2] := "LIBRO DE MAYOR Y BALANCE AJUSTADO"
RETURN NIL

//------------------------------------//
METHOD ListoDOS( oDlg ) CLASS TLimay
   LOCAL oRpt
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[2],::aEnc[2],;
         SPACE(71) + "M O V I M I E N T O S",;
         "CUENTA----  NOMBRE DE LA CUENTA---------------------    SALDO  ANTERIOR"+;
         "      D E B I T O S    C R E D I T O S       NUEVO  SALDO"},::aLS[4],,2 )
While ::nL > 0
      ::LBalance()
   If ::aMV[9]
         oRpt:Titulo( 128 )
      If ::aMV[2] <= 2
         oRpt:nL += If( oRpt:nL == 10, 0, 1 )
       //oRpt:Say( oRpt:nL,00,oRpt:CPIBold )
       //oRpt:SetFont( oRpt:CPIBold + oRpt:cFontI )
      EndIf
         oRpt:Say( oRpt:nL, 01,::aMV[1] + "  " + ::aMV[3] )
         oRpt:Say( oRpt:nL, 54,TRANSFORM( ::aMV[4],::aMV[14] ) )
         oRpt:Say( oRpt:nL, 73,TRANSFORM( ::aMV[5],::aMV[14] ) )
         oRpt:Say( oRpt:nL, 92,TRANSFORM( ::aMV[6],::aMV[14] ) )
         oRpt:Say( oRpt:nL,111,TRANSFORM( ::aMV[7],::aMV[14] ) )
         If ::aMV[2] == 0
            oRpt:nL++
         //ElseIf ::aRS[2] >= 3
         //   oRpt:Say( oRpt:nL,129,oRpt:CPIBoldN )
         //   oRpt:SetFont( oRpt:cFontI )
         EndIf
         oRpt:nL++
   EndIf
EndDo
oRpt:Say(  oRpt:nL, 00,REPLICATE("_",128) )
oRpt:Say(++oRpt:nL, 12,"T O T A L E S ------->" )
oRpt:Say(  oRpt:nL, 54,TRANSFORM( ::aMV[10],::aMV[14] ) )
oRpt:Say(  oRpt:nL, 73,TRANSFORM( ::aMV[11],::aMV[14] ) )
oRpt:Say(  oRpt:nL, 92,TRANSFORM( ::aMV[12],::aMV[14] ) )
oRpt:Say(  oRpt:nL,111,TRANSFORM( ::aMV[13],::aMV[14] ) )
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD Lineas() CLASS TLimay

While ::nL > 0
      ::LBalance()
   If ::aMV[9]
      ::Cabecera( .t. )
      If ::aMV[2] <= 2
         If ::aMV[2] == 0 .AND. ::nLinea > 4
            ::Cabecera( .t. )
         EndIf
         UTILPRN ::oUtil SELECT ::aFnt[6]
      EndIf
      UTILPRN ::oUtil Self:nLinea, 1.0 SAY ::aMV[1]
      UTILPRN ::oUtil Self:nLinea, 2.5 SAY LEFT(::aMV[3],34)
      UTILPRN ::oUtil Self:nLinea,11.9 SAY TRANSFORM(::aMV[4],::aMV[14] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,14.6 SAY TRANSFORM(::aMV[5],::aMV[14] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,17.3 SAY TRANSFORM(::aMV[6],::aMV[14] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM(::aMV[7],::aMV[14] ) RIGHT
      If ::aMV[2] == 0
         ::nLinea += .5
      ElseIf ::aRS[2] >= 3
         UTILPRN ::oUtil SELECT ::aFnt[5]
      EndIf
   EndIf
EndDo
        ::Cabecera( .t. )
UTILPRN ::oUtil LINEA Self:nLinea,1.0 TO Self:nLinea,20.0 PEN ::oPen
        ::nLinea += .5
UTILPRN ::oUtil Self:nLinea, 2.5 SAY "T O T A L E S ------->"
UTILPRN ::oUtil Self:nLinea,11.9 SAY TRANSFORM(::aMV[10],::aMV[14] ) RIGHT
UTILPRN ::oUtil Self:nLinea,14.6 SAY TRANSFORM(::aMV[11],::aMV[14] ) RIGHT
UTILPRN ::oUtil Self:nLinea,17.3 SAY TRANSFORM(::aMV[12],::aMV[14] ) RIGHT
UTILPRN ::oUtil Self:nLinea,20.0 SAY TRANSFORM(::aMV[13],::aMV[14] ) RIGHT
RETURN NIL

//------------------------------------//
METHOD Cabecera( lSep,nSpace ) CLASS TLimay
If lSep .AND. !::aEnc[1]
   ::aEnc[1] := ::Separator( nSpace )
EndIf
If ::aEnc[1]
   ::aEnc[1] := .F.
   ::Centrar( oApl:cEmpresa,::aFnt[4],1.0 )
   UTILPRN ::oUtil 1.5, 0.5 SAY "FEC.PROC:"+DTOC( DATE() )
   UTILPRN ::oUtil 1.5, 8.2 SAY "NIT: " + oApl:oEmp:Nit
   UTILPRN ::oUtil 1.5,16.4 SAY "HORA: " + AmPm( TIME() )
   ::Centrar( ::aEnc[2],,2.0 )
   UTILPRN ::oUtil 2.0,16.5 SAY "PAGINA" + STR(::nPage,4 )
   ::Centrar( ::aEnc[3],,2.5 )

   UTILPRN ::oUtil 3.0,13.7 SAY "M O V I M I E N T O S"
   UTILPRN ::oUtil 3.5, 1.0 SAY "CUENTA"
   UTILPRN ::oUtil 3.5, 2.5 SAY "NOMBRE CUENTA"
   UTILPRN ::oUtil 3.5,11.9 SAY "SALDO ANTERIOR"  RIGHT
   UTILPRN ::oUtil 3.5,14.6 SAY "D E B I T O S"   RIGHT
   UTILPRN ::oUtil 3.5,17.3 SAY "C R E D I T O S" RIGHT
   UTILPRN ::oUtil 3.5,20.0 SAY "NUEVO  SALDO"    RIGHT
   UTILPRN ::oUtil LINEA 4.0,1.0 TO 4.0,20.0 PEN ::oPen
   ::nLinea := 4.0
EndIf
RETURN NIL

//------------------------------------//
METHOD ExcelBal() CLASS TLimay
   LOCAL aGT, cQry, nF, hRes, oExcel
If oApl:lOffice
   cQry := cFilePath( GetModuleFileName( GetInstance() )) + "Balance.csv"
   FERASE(cQry)
   hRes := FCREATE(cQry,0) //, FC_NORMAL)
   If FERROR() != 0
      Msginfo(FERROR(),"No se pudo crear el archivo "+cQry )
      RETURN NIL
   EndIf
   aGT := { "",CHR(13) + CHR(10),"=" }
               //CRLF
   nF  := 6
   FWRITE( hRes,'"","'+oApl:cEmpresa+'"'+aGT[2] )
   FWRITE( hRes,'"","NIT: ' + oApl:oEmp:Nit + '"' +aGT[2] )
   FWRITE( hRes,'"","'+::aEnc[2]+'"'+aGT[2] )
   FWRITE( hRes,'"","'+::aEnc[3]+'"'+aGT[2] )
   FWRITE( hRes,'"CUENTA","NOMBRE DE LA CUENTA","SALDO ANTERIOR","L.DEBITOS","CREDITOS","NUEVO SALDO"'+aGT[2] )

   While ::nL > 0
         ::LBalance()
      If ::aMV[9]
         If ::aMV[2] == 0
            nF ++
            aGT[3] += "C" + LTRIM(STR(nF)) + "+"
            FWRITE( hRes,'""'+aGT[2] )
         EndIf
         aGT[1] := '"' + ::aMV[1] +'",' + XTrim( ::aMV[3],-9 ) + XTrim( ::aMV[4],-9 ) +;
                   XTrim( ::aMV[5],-9 ) + XTrim( ::aMV[6],-9 ) + XTrim( ::aMV[7],-9 )
         FWRITE( hRes,aGT[1] + aGT[2] )
         If ::aMV[2] == 0
            nF ++
            FWRITE( hRes,'""'+aGT[2] )
         EndIf
            nF ++
      EndIf
   EndDo
         aGT[1] := XTrim( "T O T A L E S ------->",-9 )          + XTrim( ::aMV[10],-9 ) +;
                   XTrim( ::aMV[11],-9 ) + XTrim( ::aMV[12],-9 ) + XTrim( ::aMV[13],-9 )
         FWRITE( hRes,'"",'+ aGT[1] + aGT[2] )
/*
   aGT[3] := LEFT( aGT[3],LEN(aGT[3])-1 )
   FWRITE( hRes,'"","T O T A L E S ------->","'+aGT[3]+'","' +;
                STRTRAN( aGT[3],"C","D" )+'","' +;
                STRTRAN( aGT[3],"C","E" )+'","' +;
                STRTRAN( aGT[3],"C","F" )+'"'   + aGT[2] )
*/
   If !FCLOSE(hRes)
      Msginfo(FERROR(),"Error cerrando el archivo "+cQry)
   EndIf
   WAITRUN("OPENOFICE.BAT " + cQry, 0 )
Else
   cQry := cFilePath( GetModuleFileName( GetInstance() )) + "Balance.xls"
   oApl:oWnd:SetMsg( "Exportando hacia "+cQry )
   oExcel := TExcelScript():New()
   oExcel:Create( cQry )
   oExcel:Font("Verdana")
   oExcel:Visualizar(.F.)
// oExcel:Say( nRow, nCol, xValue, cFont, nSize, lBold, lItalic, ;
//             lUnderLine, nAlign, nColor, nFondo , nOrien , nStyle , cFormat )
   oExcel:Say(  1 , 2 , oApl:cEmpresa, , 14 ,,,,,,,, 0  )
   oExcel:Say(  2 , 2 , "NIT: " + oApl:oEmp:Nit, ,12 ,,,, 7,,,, 0 )
   oExcel:Say(  3 , 2 , ::aEnc[2], , 12 ,,,, 7,,,, 0  )
   oExcel:Say(  4 , 2 , ::aEnc[3], , 12 ,,,, 7,,,, 0  )
   oExcel:Say(  5,  1, "CUENTA",,,,,, 7,,,, 0, "Text" )
   oExcel:Say(  5,  2, "NOMBRE DE LA CUENTA",,,,,, 7,,,, 0, "Text" )
   oExcel:Say(  5,  3, "SALDO ANTERIOR",,,,,, 7,,,, 0, "Text" )
   oExcel:Say(  5,  4, "DEBITOS",,,,,, 7,,,, 0, "Text" )
   oExcel:Say(  5,  5, "CREDITOS",,,,,, 7,,,, 0, "Text" )
   oExcel:Say(  5,  6, "NUEVO SALDO",,,,,, 7,,,, 0, "Text" )
   ::aMV[08] := .f.
   ::aMV[14] := "#.##0,00"
   nF := 5
   While ::nL > 0
         ::LBalance()
      If ::aMV[9]
         If ::aMV[2] <= 2
            ::aMV[8] := .t.
            nF += If( ::aMV[2] == 0, 1, 0 )
         EndIf
         oExcel:Say( nF, 1, ::aMV[1],,, ::aMV[8],,, 2,,,,, "Text" )
         oExcel:Say( nF, 2, ::aMV[3],,, ::aMV[8],,, 2,,,,, "Text" )
         AEVAL( ::aMV, {| xV,nP | oExcel:Say( nF, nP-1, xV,,, ::aMV[8],,,,,,,, ::aMV[14] ) },4,4 )
         If ::aMV[2] == 0
            nF ++
         ElseIf ::aRS[2] >= 3
            ::aMV[8] := .f.
         EndIf
            nF ++
      EndIf
   EndDo
   oExcel:Say( nF, 2, "T O T A L E S ------->",,,,,, 2,,,,, "Text" )
   AEVAL( ::aMV, {| xV,nP | oExcel:Say( nF, nP-7, xV,,,,,,,,,,, ::aMV[14] ) },10,4 )
   oExcel:Borders("A1:F" + LTRIM(STR(nF)) ,,, 3 )
   oExcel:ColumnWidth( 2 , 45 )
   oExcel:Visualizar(.T.)
   oExcel:End(.f.) ; oExcel := NIL
EndIf
RETURN NIL

//------------------------------------//
METHOD LBalance() CLASS TLimay

 If ::aMV[9] .OR. ::aRS[1] # ::aMV[1]
    ::aMV[1] := ::aRS[1]
    ::aMV[2] := ::aRS[2]
    ::aMV[3] := ::aRS[3]
    ::aMV[4] := ::aMV[5] := ::aMV[6] := ::aMV[7] := 0
    ::aMV[9] := .f.
 EndIf
 If ::aRS[6] == "S"
    ::aMV[4] := ::aRS[4] - ::aRS[5]
 Else
    ::aMV[5] := ::aRS[4]
    ::aMV[6] := ::aRS[5]
 EndIf
 If (::nL --) > 1
    ::aRS := MyReadRow( ::hRes )
    AEVAL( ::aRS, {| xV,nP | ::aRS[nP] := MyClReadCol( ::hRes,nP ) } )
 EndIf
 If ::nL == 0 .OR. ::aRS[1] # ::aMV[1]
    If ::aMV[4] # 0 .OR. ::aMV[5] # 0 .OR.;
       ::aMV[6] # 0 .OR. ::aMV[7] # 0
       ::aMV[07] := ::aMV[4] + ::aMV[5] - ::aMV[6]
       ::aMV[09] := .t.
       If ::aMV[2] == 0
          ::aMV[10] += ::aMV[4]
          ::aMV[11] += ::aMV[5]
          ::aMV[12] += ::aMV[6]
          ::aMV[13] += ::aMV[7]
       EndIf
    EndIf
 EndIf
RETURN NIL