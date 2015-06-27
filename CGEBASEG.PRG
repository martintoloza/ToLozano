// Programa.: CGEBASEG.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listado de Bases Gravadas
#INCLUDE "Fivewin.ch"
#INCLUDE "Utilprn.CH"

MEMVAR oApl

PROCEDURE CgeBaseg()
   LOCAL oDlg, oM, oGet := ARRAY(8)
 oM := TBaseg() ; oM:NEW()
DEFINE DIALOG oDlg TITLE oM:aEnc[2] FROM 0, 0 TO 12,50
   @ 02, 00 SAY "PERIODO [AAAAMM]"    OF oDlg RIGHT PIXEL SIZE 80,10
   @ 02, 82 GET oGet[1] VAR oM:aLS[1] OF oDlg PICTURE "999999" SIZE 36,10 PIXEL;
      VALID NtChr( oM:aLS[1],"P" )
   @ 14, 00 SAY "ACUMULADO"           OF oDlg RIGHT PIXEL SIZE 80,10
   @ 14, 82 CHECKBOX oGet[2] VAR oM:aLS[2] PROMPT " " OF oDlg SIZE 14,10 PIXEL
   @ 26, 00 SAY "Libro" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 26, 82 COMBOBOX oGet[3] VAR oM:aLS[5] ITEMS { "COLGAAP","IFRS" };
      SIZE 48,90 OF oDlg PIXEL;
      WHEN !EMPTY(oApl:oEmp:NIIF) .AND. oM:aLS[1] >= oApl:oEmp:NIIF
   @ 38, 00 SAY "CLASE DE LISTADO"   OF oDlg RIGHT PIXEL SIZE 80,10
   @ 38, 82 COMBOBOX oGet[4] VAR oM:aLS[3] ITEMS { "Matriz","Laser","Excel" };
      SIZE 48,90 OF oDlg PIXEL
   @ 38,134 CHECKBOX oGet[5] VAR oM:aLS[4] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 50,00 SAY "Escoja la Fuente"  OF oDlg RIGHT PIXEL SIZE 80,10
   @ 50,82 COMBOBOX oGet[6] VAR oM:cFont ITEMS oM:aFont SIZE 80,99 OF oDlg PIXEL;
      WHEN oM:aLS[3] > 1
   @ 64, 50 BUTTON oGet[7] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[7]:Disable(), oM:ArmarMOV( oDlg ) ,;
        oGet[7]:Enable() , oGet[7]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 64,100 BUTTON oGet[8] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 70, 02 SAY "[CGEBASEG]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT ( Empresa( .t. ) )
RETURN

//------------------------------------//
CLASS TBaseg FROM TIMPRIME

 DATA aLS, aMV, aRes, hRes, nF, nL, oExc

 METHOD NEW( cFile,hDC ) Constructor
 METHOD ArmarMOV( oDlg )
 METHOD Acumulad( oDlg )
 METHOD ListoDOS()
 METHOD ListoACU()
 METHOD Lineas()
 METHOD LineACU()
 METHOD Cabecera( lSep,nSpace,nSuma )
 METHOD ExcelBGR()
 METHOD ExcelACU()
 METHOD SayExec( aEx,nC )
 METHOD Cambios( oRpt )
 METHOD Cuentas( cCta,hRes )

ENDCLASS

//------------------------------------//
METHOD NEW( cFile,hDC ) CLASS TBaseg
If cFile == NIL
   hDC := GetDC( 0 )
   ::aFont := GetFontNames( hDC )
   ::aLS   := { NtChr( DATE(),"1" ),.f.,oApl:nTFor,.t.,1,"@( 9,999,999,999.99" }
   ::aEnc  := { .t.,"MOVIMIENTO BASES GRAVADAS","","",CHR(13) + CHR(10) }
   ::cFont := "Arial"
ElseIf cFile == "NEW"
   If oApl:lOffice
      cFile := cFilePath( GetModuleFileName( GetInstance() )) + "BGR.csv"
      FERASE( cFile )
      ::oExc := FCREATE( cFile,0 )
      If FERROR() != 0
         Msginfo( FERROR(),"No se pudo crear el archivo "+cFile )
         RETURN .T.
      EndIf
   Else
      cFile := cFilePath( GetModuleFileName( GetInstance() )) + "BGR.xls"
      If EMPTY( cFile )
         RETURN .T.
      EndIf
      ::oExc := TExcelScript():New()
      ::oExc:Create( cFile )
      ::oExc:Font("Verdana")
      ::oExc:Visualizar(.F.)
   EndIf
   oApl:oWnd:SetMsg( "Exportando hacia "+cFile )
Else
   If oApl:lOffice
      If !FCLOSE( ::oExc )
         Msginfo( FERROR(),"Error cerrando el archivo BGR.csv" )
      EndIf
      WAITRUN( "OPENOFICE.BAT BGR.csv", 0 )
   Else
      ::oExc:Borders( cFile + LTRIM(STR(::nF)) ,,, 1 )
      ::oExc:ColumnWidth( 2 , 15 )
      ::oExc:ColumnWidth( 3 , 30 )
      ::oExc:Visualizar(.T.)
      ::oExc:End(.f.) ; ::oExc := NIL
   EndIf
EndIf
RETURN .F.

//------------------------------------//
METHOD ArmarMOV( oDlg ) CLASS TBaseg
   LOCAL cQry
 ::aEnc[3]:= NtChr( ::aLS[1],"F" )
 ::aMV    := { "","",0,0,0,0,0,"",0,0,0,0,0,0,0,"",1 }
 ::nF     := 1
If ::aLS[2]
   ::Acumulad( oDlg )
   RETURN NIL
EndIf
cQry := "SELECT c.fuente, c.comprobant, c.control, d.cuenta, d.infa, d.infb, "+;
            "d.infc, d.infd, d.valor_deb, d.valor_cre, d.ptaje, d.codigo_nit "+;
        "FROM cgemovd d, cgemovc c "   +;
        "WHERE d.empresa = c.empresa"  +;
         " AND d.ano_mes = c.ano_mes"  +;
         " AND d.control = c.control"  +;
         " AND d.cuenta >= '23'"       +;
         " AND d.cuenta <= '24999999'" +;
         " AND d.libro   = " + LTRIM(STR(::aLS[5]))     +;
         " AND c.empresa = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.ano_mes = " + xValToChar( ::aLS[1] )   +;
         " AND c.estado <> 2 ORDER BY d.cuenta, c.fuente"
::hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes ) ; RETURN NIL
EndIf
 ::aEnc[2] += NtChr( ::aLS[5],"CI" )
 ::aEnc[3] := NtChr( ::aEnc[3],"6" )
If ::aLS[3] == 1
   ::ListoDOS()
ElseIf ::aLS[3] == 2
   ::Init( ::aEnc[2], .f. ,, !::aLS[4] ,,,, 5 )
     PAGE
       ::Lineas()
     ENDPAGE
   IMPRIME END .F.
Else
  ::ExcelBGR()
EndIf
 MSFreeResult( ::hRes )
  ::aEnc[2] := "MOVIMIENTO BASES GRAVADAS"
RETURN NIL

//------------------------------------//
METHOD Acumulad( oDlg ) CLASS TBaseg
   LOCAL aRes, cQry, oTB
cQry := "SELECT d.ano_mes, d.cuenta, d.codigo_nit, d.ptaje, d.infa, "+;
                  "d.infb, d.infc, d.infd, d.valor_deb, d.valor_cre "+;
        "FROM cgemovd d, cgemovc c "    +;
        "WHERE d.empresa  = c.empresa"  +;
         " AND d.ano_mes  = c.ano_mes"  +;
         " AND d.control  = c.control"  +;
         " AND d.cuenta  >= '23'"       +;
         " AND d.cuenta  <= '24999999'" +;
         " AND d.libro    = " + LTRIM(STR(::aLS[5]))     +;
         " AND c.empresa  = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.ano_mes >= '"+ STUFF( ::aLS[1],5,2,"01")+;
        "' AND c.ano_mes <= " + xValToChar( ::aLS[1] )   +;
         " AND c.estado <> 2 ORDER BY d.cuenta, d.codigo_nit"
::hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes ) ; RETURN NIL
EndIf
aRes := { { "row_id"   , "N", 11, 00, " auto_increment PRIMARY KEY" },;
          { "cuenta"   , "C", 10, 00, },;
          { "nomcta"   , "C", 40, 00, },;
          { "nit"      , "C", 15, 00, },;
          { "nombre"   , "C", 40, 00, },;
          { "valorper" , "N", 14, 02, },;
          { "baseper"  , "N", 14, 02, },;
          { "valoracu" , "N", 14, 02, },;
          { "baseacu"  , "N", 14, 02, },;
          { "ptaje"    , "N", 07, 02, } }
If oApl:oDb:ExistTable( "basegrav" )
   MSQuery( oApl:oMySql:hConnect,"DELETE FROM basegrav" )
Else
   oTB := TMSTable():Create( oApl:oMySql, "basegrav", aRes )
   oTB:Destroy()
EndIf
//oTB := oApl:Abrir( "basegrav" ,"cuenta",.f.,,5 )
   aRes := MyReadRow( ::hRes )
   AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
  ::aMV[1] := aRes[2]
  ::aMV[9] := aRes[3]
   ::Cuentas( aRes[2] )
While ::nL > 0
      ::aMV[10] := MAX( ::aMV[10],aRes[4] )
      ::aMV[11] :=  If( ::aMV[03] > 4, VAL( aRes[ ::aMV[3] ] ), 0 )
   If aRes[1] == ::aLS[1]
      ::aMV[4] += (aRes[09] - aRes[10])
      ::aMV[5] += ::aMV[11]
   EndIf
      ::aMV[6] += (aRes[09] - aRes[10])
      ::aMV[7] += ::aMV[11]
   If (::nL --) > 1
      aRes := MyReadRow( ::hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aMV[1] # aRes[2] .OR. ::aMV[9] # aRes[3]
      oApl:oNit:Seek( {"codigo_nit",::aMV[9]} )
      ::aMV[8] := FormatoNit( oApl:oNit:CODIGO,oApl:oNit:DIGITO )
      cQry := "INSERT INTO basegrav VALUES ( null, '"+ TRIM(::aMV[1])+ "', '"+;
           TRIM(::aMV[2])        + "', '"+           ::aMV[8]        + "', '"+;
           TRIM(oApl:oNit:NOMBRE)+ "', " +;
          LTRIM(STR(::aMV[4]))    + ", " + LTRIM(STR(::aMV[5]))      +  ", " +;
          LTRIM(STR(::aMV[6]))    + ", " + LTRIM(STR(::aMV[7]))      +  ", " +;
          LTRIM(STR(::aMV[10]))   + " )"
      If !MSQuery( oApl:oMySql:hConnect,cQry )
         oApl:oMySql:oError:Display( .f. )
      EndIf
      ::aMV[1]  := aRes[2]
      ::aMV[9]  := aRes[3]
      ::aMV[10] := ::aMV[4] := ::aMV[5] := ::aMV[6] := ::aMV[7] := 0
      ::Cuentas( aRes[2] )
   EndIf
EndDo
 MSFreeResult( ::hRes )
 AEVAL( ::aMV, {|xV,nI| ::aMV[nI] := {"",CTOD(""),.f.,0}[AT(VALTYPE(xV),"CDLN")] } )
cQry := "SELECT cuenta, nomcta, nit, nombre, valorper, "+;
              "baseper, valoracu, baseacu, ptaje "      +;
        "FROM basegrav ORDER BY cuenta, nit"
::hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
::nL   := MSNumRows( ::hRes )
::aRes := MyReadRow( ::hRes )
AEVAL( ::aRes, {| xV,nP | ::aRes[nP] := MyClReadCol( ::hRes,nP ) } )
  ::aEnc[2] += " ACUMULADAS" + NtChr( ::aLS[5],"CI" )
  ::aEnc[3] := NtChr( ::aEnc[3],"6" )
If ::aLS[3] == 1
   ::ListoACU()
ElseIf ::aLS[3] == 2
   ::Init( ::aEnc[2], .f. ,, !::aLS[4] ,,,, 5 )
     PAGE
       ::LineACU()
     ENDPAGE
   IMPRIME END .F.
Else
  ::ExcelACU()
EndIf
MSFreeResult( ::hRes )
//oTB:Destroy()
MSQuery( oApl:oMySql:hConnect,"DROP TABLE basegrav" )
oApl:oDb:GetTables()
  ::aEnc[2] := "MOVIMIENTO BASES GRAVADAS"
RETURN NIL

//------------------------------------//
METHOD ListoDOS() CLASS TBaseg
   LOCAL oRpt
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[2],::aEnc[3],;
          " Cuenta       Nombre Cuenta"                  ,;
          "     TC         Nombre Comprobante"           ,;
          "   Nro.Cpbte.  Documento           Tercero            DEBITOS"+;
          "          CREDITOS              BASE  Porcentaje"},::aLS[4],,2 )
While ::nL > 0
   oRpt:Titulo( 130 )
   ::Cambios( oRpt )
   oRpt:Say( oRpt:nL, 07,STR(::aRes[02],6) )
   oRpt:Say( oRpt:nL, 15,::aRes[06] )
   oRpt:Say( oRpt:nL, 28, ::aMV[16] )
   oRpt:Say( oRpt:nL, 45,TRANSFORM( ::aRes[09],::aLS[6] ) )
   oRpt:Say( oRpt:nL, 63,TRANSFORM( ::aRes[10],::aLS[6] ) )
   oRpt:Say( oRpt:nL, 81,TRANSFORM(  ::aMV[15],::aLS[6] ) )
   oRpt:Say( oRpt:nL,101,TRANSFORM( ::aRes[11],"999.99" ) )
   oRpt:nL ++
   ::nL --
EndDo
   ::Cambios( oRpt )
   oRpt:nL += 2
   oRpt:Say( oRpt:nL, 01,"TOTAL GENERAL",,,1 )
   oRpt:Say( oRpt:nL, 45,TRANSFORM( ::aMV[12],::aLS[6] ) )
   oRpt:Say( oRpt:nL, 63,TRANSFORM( ::aMV[13],::aLS[6] ) )
   oRpt:Say( oRpt:nL, 81,TRANSFORM( ::aMV[14],::aLS[6] ) )
   oRpt:NewPage()
   oRpt:End()
RETURN NIL

//------------------------------------//
METHOD ListoACU() CLASS TBaseg
   LOCAL oRpt
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[2],::aEnc[3],;
          " Cuenta            Nombre Cuenta"             ,;
          "       NIT CEDULA        Nombre                     Valor Periodo      "+;
          "Base Periodo   Valor Acumulado    Base Acumulada Porcentaje"},::aLS[4],,2 )
While ::nL > 0
   oRpt:Titulo( 130 )
   If ::aMV[1]  # ::aRes[1]
      ::aMV[1] := ::aRes[1]
      oRpt:Say( oRpt:nL, 01,::aRes[1] )
      oRpt:Say( oRpt:nL, 19,::aRes[2] )
      oRpt:nL ++
   EndIf
   oRpt:Say( oRpt:nL, 03,::aRes[3] )
   oRpt:Say( oRpt:nL, 19,::aRes[4] )
   oRpt:Say( oRpt:nL, 49,TRANSFORM( ::aRes[5],::aLS[6] ) )
   oRpt:Say( oRpt:nL, 67,TRANSFORM( ::aRes[6],::aLS[6] ) )
   oRpt:Say( oRpt:nL, 85,TRANSFORM( ::aRes[7],::aLS[6] ) )
   oRpt:Say( oRpt:nL,103,TRANSFORM( ::aRes[8],::aLS[6] ) )
   oRpt:Say( oRpt:nL,122,TRANSFORM( ::aRes[9],"999.99" ) )
   oRpt:nL ++
   ::aMV[4] += ::aRes[5]
   ::aMV[5] += ::aRes[6]
   ::aMV[6] += ::aRes[7]
   ::aMV[7] += ::aRes[8]
   If (::nL --) > 1
      ::aRes := MyReadRow( ::hRes )
      AEVAL( ::aRes, {| xV,nP | ::aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aMV[1]  # ::aRes[1]
      oRpt:Say( oRpt:nL, 03,::aMV[1] )
      oRpt:Say( oRpt:nL, 49,TRANSFORM( ::aMV[4],::aLS[6] ) )
      oRpt:Say( oRpt:nL, 67,TRANSFORM( ::aMV[5],::aLS[6] ) )
      oRpt:Say( oRpt:nL, 85,TRANSFORM( ::aMV[6],::aLS[6] ) )
      oRpt:Say( oRpt:nL,103,TRANSFORM( ::aMV[7],::aLS[6] ) )
      oRpt:nL ++
      ::aMV[10] += ::aMV[4]
      ::aMV[11] += ::aMV[5]
      ::aMV[12] += ::aMV[6]
      ::aMV[13] += ::aMV[7]
      ::aMV[4]  := ::aMV[5] := ::aMV[6] := ::aMV[7] := 0
   EndIf
EndDo
   oRpt:nL ++
   oRpt:Say( oRpt:nL, 01,"TOTALES GENERALES",,,1 )
   oRpt:Say( oRpt:nL, 49,TRANSFORM( ::aMV[10],::aLS[6] ) )
   oRpt:Say( oRpt:nL, 67,TRANSFORM( ::aMV[11],::aLS[6] ) )
   oRpt:Say( oRpt:nL, 85,TRANSFORM( ::aMV[12],::aLS[6] ) )
   oRpt:Say( oRpt:nL,103,TRANSFORM( ::aMV[13],::aLS[6] ) )
   oRpt:NewPage()
   oRpt:End()
RETURN NIL

//------------------------------------//
METHOD Lineas() CLASS TBaseg
   LOCAL lOK := .t.
While ::nL > 0
   ::Cambios()
   ::Cabecera( .t. )
   UTILPRN ::oUtil Self:nLinea,02.7 SAY STR(::aRes[02],6)                RIGHT
   UTILPRN ::oUtil Self:nLinea,03.1 SAY ::aRes[06]
   UTILPRN ::oUtil Self:nLinea,07.0 SAY ::aMV[16]                        RIGHT
   UTILPRN ::oUtil Self:nLinea,10.0 SAY TRANSFORM( ::aRes[09],::aLS[6] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,12.6 SAY TRANSFORM( ::aRes[10],::aLS[6] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,15.2 SAY TRANSFORM(  ::aMV[15],::aLS[6] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,16.6 SAY TRANSFORM( ::aRes[11],"999.99" ) RIGHT
   ::nL --
EndDo
   ::Cambios()
   ::Cabecera( .t.,0.5 )
   UTILPRN ::oUtil Self:nLinea,01.0 SAY "TOTAL GENERAL"
   UTILPRN ::oUtil Self:nLinea,10.0 SAY TRANSFORM( ::aMV[12],::aLS[6] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,12.6 SAY TRANSFORM( ::aMV[13],::aLS[6] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,16.6 SAY TRANSFORM( ::aMV[14],::aLS[6] ) RIGHT
RETURN NIL

//------------------------------------//
METHOD LineACU() CLASS TBaseg
While ::nL > 0
   ::Cabecera( .t. )
   If ::aMV[1]  # ::aRes[1]
      ::aMV[1] := ::aRes[1]
      UTILPRN ::oUtil Self:nLinea, 1.0 SAY ::aRes[1]
      UTILPRN ::oUtil Self:nLinea, 3.2 SAY ::aRes[2]
      ::Cabecera( .t. )
   EndIf
   UTILPRN ::oUtil Self:nLinea,03.0 SAY ::aRes[3]                       RIGHT
   UTILPRN ::oUtil Self:nLinea,03.2 SAY ::aRes[4]
   UTILPRN ::oUtil Self:nLinea,10.0 SAY TRANSFORM( ::aRes[5],::aLS[6] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,12.6 SAY TRANSFORM( ::aRes[6],::aLS[6] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,15.2 SAY TRANSFORM( ::aRes[7],::aLS[6] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,17.8 SAY TRANSFORM( ::aRes[8],::aLS[6] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,19.2 SAY TRANSFORM( ::aRes[9],"999.99" ) RIGHT
   ::aMV[4] += ::aRes[5]
   ::aMV[5] += ::aRes[6]
   ::aMV[6] += ::aRes[7]
   ::aMV[7] += ::aRes[8]
   If (::nL --) > 1
      ::aRes := MyReadRow( ::hRes )
      AEVAL( ::aRes, {| xV,nP | ::aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aMV[1]  # ::aRes[1]
      ::Cabecera( .t. )
      UTILPRN ::oUtil Self:nLinea,01.5 SAY ::aMV[1]
      UTILPRN ::oUtil Self:nLinea,10.0 SAY TRANSFORM( ::aMV[4],::aLS[6] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,12.6 SAY TRANSFORM( ::aMV[5],::aLS[6] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,15.2 SAY TRANSFORM( ::aMV[6],::aLS[6] ) RIGHT
      UTILPRN ::oUtil Self:nLinea,17.8 SAY TRANSFORM( ::aMV[7],::aLS[6] ) RIGHT
      ::aMV[10] += ::aMV[4]
      ::aMV[11] += ::aMV[5]
      ::aMV[12] += ::aMV[6]
      ::aMV[13] += ::aMV[7]
      ::aMV[4]  := ::aMV[5] := ::aMV[6] := ::aMV[7] := 0
   EndIf
EndDo
   ::Cabecera( .t.,0.5 )
   UTILPRN ::oUtil Self:nLinea,01.1 SAY "TOTALES GENERALES"
   UTILPRN ::oUtil Self:nLinea,10.0 SAY TRANSFORM( ::aMV[10],::aLS[6] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,12.6 SAY TRANSFORM( ::aMV[11],::aLS[6] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,15.2 SAY TRANSFORM( ::aMV[12],::aLS[6] ) RIGHT
   UTILPRN ::oUtil Self:nLinea,17.8 SAY TRANSFORM( ::aMV[13],::aLS[6] ) RIGHT
RETURN NIL

//------------------------------------//
METHOD Cabecera( lSep,nSpace,nSuma ) CLASS TBaseg
If lSep .AND. !::aEnc[1]
   ::aEnc[1] := ::Separator( nSpace,nSuma )
EndIf
If ::aEnc[1]
   ::aEnc[1] := .F.
   ::Centrar( oApl:cEmpresa,::aFnt[4],1.0 )
   UTILPRN ::oUtil 1.5, 0.5 SAY "FEC.PROC:"+DTOC( DATE() ) FONT ::aFnt[2]
   UTILPRN ::oUtil 1.5, 8.2 SAY "NIT: " + oApl:oEmp:Nit    FONT ::aFnt[2]
   UTILPRN ::oUtil 1.5,16.4 SAY "HORA: " + AmPm( TIME() )  FONT ::aFnt[2]
   ::Centrar( ::aEnc[2],,2.0 )
   UTILPRN ::oUtil 2.0,16.5 SAY "PAGINA" + STR(::nPage,4 ) FONT ::aFnt[2]
   ::Centrar( ::aEnc[3],,2.5 )
   UTILPRN ::oUtil 3.0, 1.0 SAY "Cuenta"
   UTILPRN ::oUtil 3.0, 3.2 SAY "Nombre Cuenta"
   If ::aLS[2]
      UTILPRN ::oUtil 3.5, 3.0 SAY "NIT CEDULA"      RIGHT
      UTILPRN ::oUtil 3.5, 3.8 SAY "Nombre"
      UTILPRN ::oUtil 3.5,10.0 SAY "Valor Periodo"   RIGHT
      UTILPRN ::oUtil 3.5,12.6 SAY  "Base Periodo"   RIGHT
      UTILPRN ::oUtil 3.5,15.2 SAY "Valor Acumulado" RIGHT
      UTILPRN ::oUtil 3.5,17.8 SAY  "Base Acumulado" RIGHT
      UTILPRN ::oUtil 3.5,18.2 SAY "Porcentaje"
      UTILPRN ::oUtil LINEA 4.0,1.0 TO 4.0,19.4 PEN ::oPen
      ::nLinea := 4.0
   Else
      UTILPRN ::oUtil 3.5, 1.9 SAY "TC"              RIGHT
      UTILPRN ::oUtil 3.5, 3.2 SAY "Nombre Comprobante"
      UTILPRN ::oUtil 4.0, 2.7 SAY "Nro.Cpbte."      RIGHT
      UTILPRN ::oUtil 4.0, 3.1 SAY "Documento"
      UTILPRN ::oUtil 4.0, 7.0 SAY "Tercero"         RIGHT
      UTILPRN ::oUtil 4.0,10.0 SAY "DEBITOS"         RIGHT
      UTILPRN ::oUtil 4.0,12.6 SAY "CREDITOS"        RIGHT
      UTILPRN ::oUtil 4.0,15.2 SAY "BASE"            RIGHT
      UTILPRN ::oUtil 4.0,15.6 SAY "Porcentaje"
      UTILPRN ::oUtil LINEA 4.5,1.0 TO 4.5,18.6 PEN ::oPen
      ::nLinea := 4.5
   EndIf
   ::nPage ++
EndIf
RETURN NIL

//------------------------------------//
METHOD ExcelBGR() CLASS TBaseg
If ::NEW( "NEW" )
   RETURN NIL
EndIf
// 1_xValue, 2_nSize, 3_nAlign, 4_nStyle, 5_cFormat //
   ::SayExec( { {"",,,,},{oApl:cEmpresa,14,,0,} } )
   ::SayExec( { {"",,,,},{"NIT: " + oApl:oEmp:Nit,12,7,0,} } )
   ::SayExec( { {"",,,,},{"",,,,},{::aEnc[2],12,7,0,} } )
   ::SayExec( { {"",,,,},{"",,,,},{::aEnc[3],12,7,0,} } )
   ::SayExec( { {"Cuenta",,,,},{"",,,,},{"Nombre Cuenta",,,,} } )
   ::SayExec( { {"TC",,1,,},{"Nombre Comprobante",,,,} } )
   ::SayExec( { {"Nro.Cpbte.",,1,,},{"Documento",,,,},{"Tercero",,1,,},;
                {"DEBITOS",,1,,}   ,{"CREDITOS",,1,,},{"BASE",,1,,}   ,;
                {"Porcentaje",,1,,} } )
While ::nL > 0
   ::Cambios()
   ::SayExec( { {::aRes[02],,,,},{::aRes[06],,1,,},{::aMV[16],,,,}   ,;
                {::aRes[09],,,,"#.##0,00"},{::aRes[10],,,,"#.##0,00"},;
                {::aMV[15] ,,,,"#.##0,00"},{::aRes[11],,,,"#.##0,00"} } )
   ::nL --
EndDo
   ::Cambios()
   ::SayExec( { {"",,,,} } )
   ::SayExec( { {"TOTAL GENERAL",,,,}, {"",,,,}, {"",,,,}          ,;
                {::aMV[12],,,,"#.##0,00"},{::aMV[13],,,,"#.##0,00"},;
                {::aMV[14],,,,"#.##0,00"} } )
 ::NEW( "A1:G" )
RETURN NIL

//------------------------------------//
METHOD ExcelACU() CLASS TBaseg
If ::NEW( "NEW" )
   RETURN NIL
EndIf
// 1_xValue, 2_nSize, 3_nAlign, 4_nStyle, 5_cFormat //
   ::SayExec( { {"",,,,},{oApl:cEmpresa,14,,0,} } )
   ::SayExec( { {"",,,,},{"NIT: " + oApl:oEmp:Nit,12,7,0,} } )
   ::SayExec( { {"",,,,},{"",,,,},{::aEnc[2],12,7,0,} } )
   ::SayExec( { {"",,,,},{"",,,,},{::aEnc[3],12,7,0,} } )
   ::SayExec( { {"Cuenta",,,,},{"",,,,},{"Nombre Cuenta",,,,} } )
   ::SayExec( { {"",,,,},{"NIT CEDULA",,,,},{"Nombre",,,,},{"Valor Periodo",,,,},;
                {"Base Periodo",,,,}  ,{"Valor Acumulado",,,,},;
                {"Base Acumulado",,,,},{"Porcentaje",,,,} } )
While ::nL > 0
   If ::aMV[1]  # ::aRes[1]
      ::aMV[1] := ::aRes[1]
      ::SayExec( { {::aRes[1],,,,},{"",,,,},{::aRes[2],,,,} } )
   EndIf
   ::SayExec( { {"",,,,}       ,{::aRes[3],,,,},{::aRes[4],,,,},;
                {::aRes[5],,,,"#.##0,00"},{::aRes[6],,,,"#.##0,00"},{::aRes[7],,,,"#.##0,00"},;
                {::aRes[8],,,,"#.##0,00"},{::aRes[9],,,,"#.##0,00"} } )
   ::aMV[4] += ::aRes[5]
   ::aMV[5] += ::aRes[6]
   ::aMV[6] += ::aRes[7]
   ::aMV[7] += ::aRes[8]
   If (::nL --) > 1
      ::aRes := MyReadRow( ::hRes )
      AEVAL( ::aRes, {| xV,nP | ::aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   EndIf
   If ::nL == 0 .OR. ::aMV[1]  # ::aRes[1]
      ::SayExec( { {"TOTAL " + ::aMV[1],,,,} , {"",,,,}, {"",,,,}   ,;
                   {::aMV[4],,,,"#.##0,00"},{::aMV[5],,,,"#.##0,00"},;
                   {::aMV[6],,,,"#.##0,00"},{::aMV[7],,,,"#.##0,00"} } )
      ::aMV[10] += ::aMV[4]
      ::aMV[11] += ::aMV[5]
      ::aMV[12] += ::aMV[6]
      ::aMV[13] += ::aMV[7]
      ::aMV[4]  := ::aMV[5] := ::aMV[6] := ::aMV[7] := 0
   EndIf
EndDo
   ::SayExec( { {"TOTAL ES GENERALES",,,,},  {"",,,,}, {"",,,,}    ,;
                {::aMV[10],,,,"#.##0,00"},{::aMV[11],,,,"#.##0,00"},;
                {::aMV[12],,,,"#.##0,00"},{::aMV[13],,,,"#.##0,00"} } )
 ::NEW( "A1:H" )
RETURN NIL

// 1_xValue, 2_nSize, 3_nAlign, 4_nStyle, 5_cFormat //
METHOD SayExec( aEx,nC ) CLASS TBaseg
 ::aEnc[4] := ""
FOR nC := 1 TO LEN( aEx )
   If oApl:lOffice
      ::aEnc[4] += XTrim( aEx[nC,1],-9 )
   Else
      ::oExc:Say( ::nF,nC,aEx[nC,1],,aEx[nC,2],,,,aEx[nC,3],,,,aEx[nC,4],aEx[nC,5] )
   // oExcel:Say( nRow, nCol, 3xValue, cFont, 5nSize, lBold, lItalic, ;
   //             lUnderLine, 9nAlign, nColor, nFondo, nOrien, 13nStyle, cFormat )
   EndIf
NEXT nC
   If oApl:lOffice
      FWRITE( ::oExc,::aEnc[4] + ::aEnc[5] )
   EndIf
 ::nF ++
RETURN NIL

//------------------------------------//
METHOD Cambios( oRpt ) CLASS TBaseg

 If ::nL > 0
    ::aRes := MyReadRow( ::hRes )
    AEVAL( ::aRes, {| xV,nP | ::aRes[nP] := MyClReadCol( ::hRes,nP ) } )
       ::aMV[16] := ""
    If ::aRes[12] > 0
       oApl:oNit:Seek( {"codigo_nit",::aRes[12]} )
       ::aMV[16] := FormatoNit( oApl:oNit:CODIGO,oApl:oNit:DIGITO )
    EndIf
 EndIf
 If ::aMV[7]  # ::aRes[1] .OR. ;
    ::aMV[1]  # ::aRes[4] .OR. ::nL == 0
    If ::aMV[09] # 0 .OR. ::aMV[10] # 0
       //Total Fuente [7-1]
       If ::aLS[3] == 1
        //oRpt:Say(  oRpt:nL, 05,"TOTAL " + STR(::aMV[7]),,,1 )
          oRpt:Say(  oRpt:nL, 05,"TOTAL " + ::aMV[8],,,1 )
          oRpt:Say(  oRpt:nL, 45,TRANSFORM( ::aMV[09],::aLS[6] ) )
          oRpt:Say(  oRpt:nL, 63,TRANSFORM( ::aMV[10],::aLS[6] ) )
          oRpt:Say(  oRpt:nL, 81,TRANSFORM( ::aMV[11],::aLS[6] ) )
          oRpt:nL ++
       ElseIf ::aLS[3] == 2
          ::Cabecera( .t. )
          UTILPRN ::oUtil Self:nLinea, 1.8 SAY "TOTAL " + ::aMV[8]
          UTILPRN ::oUtil Self:nLinea,10.0 SAY TRANSFORM( ::aMV[09],::aLS[6] ) RIGHT
          UTILPRN ::oUtil Self:nLinea,12.6 SAY TRANSFORM( ::aMV[10],::aLS[6] ) RIGHT
          UTILPRN ::oUtil Self:nLinea,15.2 SAY TRANSFORM( ::aMV[11],::aLS[6] ) RIGHT
       Else
          ::SayExec( { {"",,,,}, {"TOTAL " + ::aMV[8],,,,},  {"",,,,}     ,;
                       {::aMV[09],,,,"#.##0,00"},{::aMV[10],,,,"#.##0,00"},;
                       {::aMV[11],,,,"#.##0,00"} } )
       EndIf
    EndIf
    ::aMV[8] := Buscar( {"fuente",::aRes[1]},"cgefntes","descripcio",8 )
    ::aMV[4] += ::aMV[09]
    ::aMV[5] += ::aMV[10]
    ::aMV[6] += ::aMV[11]
    ::aMV[7] := ::aRes[1]
    ::aMV[9] := ::aMV[10] := ::aMV[11] := ::aMV[17] := 0
 EndIf

 If ::aMV[1]  # ::aRes[4] .OR. ::nL == 0
    //Total Cuenta [1-4]
    If ::aMV[04] # 0 .OR. ::aMV[05] # 0
       If ::aLS[3] == 1
          oRpt:Say(++oRpt:nL, 03,"TOTAL " + ::aMV[1],,,1 )
          oRpt:Say(  oRpt:nL, 45,TRANSFORM( ::aMV[04],::aLS[6] ) )
          oRpt:Say(  oRpt:nL, 63,TRANSFORM( ::aMV[05],::aLS[6] ) )
          oRpt:Say(  oRpt:nL, 81,TRANSFORM( ::aMV[06],::aLS[6] ) )
          oRpt:nL ++
       ElseIf ::aLS[3] == 2
          ::Cabecera( .t. )
          UTILPRN ::oUtil Self:nLinea, 1.0 SAY "TOTAL " + ::aMV[1]
          UTILPRN ::oUtil Self:nLinea,10.0 SAY TRANSFORM( ::aMV[04],::aLS[6] ) RIGHT
          UTILPRN ::oUtil Self:nLinea,12.6 SAY TRANSFORM( ::aMV[05],::aLS[6] ) RIGHT
          UTILPRN ::oUtil Self:nLinea,15.2 SAY TRANSFORM( ::aMV[06],::aLS[6] ) RIGHT
       Else
          ::SayExec( { {"",,,,}, {"TOTAL " + ::aMV[1],,,,},  {"",,,,}     ,;
                       {::aMV[04],,,,"#.##0,00"},{::aMV[05],,,,"#.##0,00"},;
                       {::aMV[06],,,,"#.##0,00"} } )
       EndIf
    EndIf
    If ::nL > 0
       ::Cuentas( ::aRes[4] )
       If ::aLS[3] == 1
          oRpt:Say(++oRpt:nL, 01,::aRes[4]+"   "+::aMV[2],,,1 )
          oRpt:Say(++oRpt:nL, 05,STR(::aRes[1],2)+SPACE(9)+::aMV[8],,,1 )
          oRpt:nL ++
       ElseIf ::aLS[3] == 2
          ::Cabecera( .t. )
          UTILPRN ::oUtil Self:nLinea, 1.0 SAY ::aRes[4]
          UTILPRN ::oUtil Self:nLinea, 3.0 SAY ::aMV[2]
          ::Cabecera( .t. )
          UTILPRN ::oUtil Self:nLinea, 1.8 SAY STR(::aRes[1],2)
          UTILPRN ::oUtil Self:nLinea, 3.2 SAY ::aMV[8]
       Else
          ::SayExec( { {::aRes[4]+"   "+::aMV[2],,,,} } )
          ::SayExec( { {::aRes[1],,,,},{::aMV[8],,,,} } )
       EndIf
       ::aMV[17] := 1
    EndIf
    ::aMV[1]  := ::aRes[4]
    ::aMV[12] += ::aMV[04]
    ::aMV[13] += ::aMV[05]
    ::aMV[14] += ::aMV[06]
    ::aMV[04] := ::aMV[05] := ::aMV[06] := 0
 ElseIf ::aMV[17] == 0
     If ::aLS[3] == 1
        oRpt:Say(++oRpt:nL, 05,STR(::aRes[1],2)+SPACE(9)+::aMV[8],,,1 )
        oRpt:nL ++
     ElseIf ::aLS[3] == 2
        ::Cabecera( .t. )
        UTILPRN ::oUtil Self:nLinea, 1.8 SAY STR(::aRes[1],2)
        UTILPRN ::oUtil Self:nLinea, 3.2 SAY ::aMV[8]
     Else
        ::SayExec( { {"",,,,} } )
        ::SayExec( { {::aRes[1],,,,},{::aMV[8],,,,} } )
     EndIf
    ::aMV[17] := 1
 EndIf
    ::aMV[09] += ::aRes[09]
    ::aMV[10] += ::aRes[10]
    ::aMV[15] := 0
 If ::aMV[03] > 4
    ::aMV[15] := VAL( ::aRes[ ::aMV[3] ] )
    ::aMV[11] += ::aMV[15]
 EndIf
RETURN NIL

//------------------------------------//
METHOD Cuentas( cCta,hRes ) CLASS TBaseg
cCta := "SELECT infa, infb, infc, infd, nombre FROM cgeplan"+;
        " WHERE empresa = " + LTRIM(STR(oApl:nPuc))         +;
          " AND cuenta  = " + xValToChar( cCta )
hRes := If( MSQuery( oApl:oMySql:hConnect,cCta ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If MSNumRows( hRes ) == 0
   ::aMV[2] := ""
   ::aMV[3] := 4
Else
   cCta := MyReadRow( hRes )
   ::aMV[2] := cCta[5]
   ::aMV[3] := ASCAN( cCta,"BASE" ) + 4
EndIf
MSFreeResult( hRes )
RETURN NIL