// Programa.: CGELIBRO.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Timbrar Libros de Contabilidad.
#include "Fivewin.ch"
#include "Btnget.ch"
#include "Utilprn.CH"
//#DEFINE CLR_GREY 14671839

MEMVAR oApl

PROCEDURE CgeLibro()
   LOCAL oDlg, oM, oGet := ARRAY(7)
 oM := TLibro() ; oM:New( .f. )
DEFINE DIALOG oDlg TITLE "TIMBRAR LIBROS" FROM 0, 0 TO 09,54
   @ 02,00 SAY "ESCOJA EL LIBRO" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 02,82 COMBOBOX oGet[1] VAR oM:aLS[1] ITEMS ArrayCol( oM:aLib,1 );
      SIZE 129,99 OF oDlg PIXEL ;
      VALID ( oM:aLS[2] := oM:aLS[3] := oM:aLib[oM:aLS[1],2] + 1, oDlg:Update(), .t. )
   @ 14,00 SAY "DESDE EL FOLIO No."  OF oDlg RIGHT PIXEL SIZE 80,10
   @ 14,82 GET oGet[2] VAR oM:aLS[2] OF oDlg PICTURE "99999" SIZE 36,10 PIXEL UPDATE;
      VALID oM:aLS[2] > 0
   @ 26,00 SAY "HASTA EL FOLIO No."  OF oDlg RIGHT PIXEL SIZE 80,10
   @ 26,82 GET oGet[3] VAR oM:aLS[3] OF oDlg PICTURE "99999" SIZE 36,10 PIXEL UPDATE;
      VALID oM:aLS[3] >= oM:aLS[2]
   @ 38, 00 SAY "TIPO DE IMPRESORA"  OF oDlg RIGHT PIXEL SIZE 80,10
   @ 38, 82 COMBOBOX oGet[4] VAR oM:aLS[4] ITEMS { "Matriz","Laser" };
      SIZE 48,90 OF oDlg PIXEL
   @ 38,134 CHECKBOX oGet[5] VAR oM:aLS[5] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,10 PIXEL
   @ 52, 50 BUTTON oGet[6] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[6]:Disable(), oM:Timbrar( oDlg ), oDlg:End() ) PIXEL
   @ 52,100 BUTTON oGet[7] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 58, 02 SAY "[CGELIBRO]" OF oDlg PIXEL SIZE 30,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
oM:oLib:Destroy()
RETURN

//------------------------------------//
PROCEDURE Cgelichq()
   LOCAL oM, oNi, oDlg, oGet := ARRAY(10)
 oM  := TLibro() ; oM:New( .t. )
 oNi := TNits()  ; oNi:New()
DEFINE DIALOG oDlg TITLE "RELACION DE CHEQUES" FROM 0, 0 TO 16,50
   @ 02, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 02, 82 GET oGet[1] VAR oM:aLS[1] OF oDlg  SIZE 40,10 PIXEL
   @ 14, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 14, 82 GET oGet[2] VAR oM:aLS[2] OF oDlg ;
      VALID oM:aLS[2] >= oM:aLS[1] SIZE 40,10 PIXEL
   @ 26, 00 SAY "NIT o C.C." OF oDlg RIGHT PIXEL SIZE 80,10
   @ 26, 82 BTNGET oGet[3] VAR oM:aLS[3] OF oDlg PICTURE "9999999999" ;
      VALID EVAL( {|| If( EMPTY( oM:aLS[3] ), .t.                    ,;
              (If( oNi:oDb:Seek( {"codigo",oM:aLS[3]} )              ,;
                 ( oM:aLS[8] := oNi:oDb:NOMBRE, oDlg:Update(), .t. ),;
                 ( MsgStop("Este Nit no Existe"), .f. ) )) ) } )      ;
      SIZE 52,10 PIXEL  RESOURCE "BUSCAR"                             ;
      ACTION EVAL({|| If(oNi:Mostrar(), (oM:aLS[3] := oNi:oDb:CODIGO ,;
                         oGet[3]:Refresh() ), )})
   @ 38, 10 SAY oM:aLS[8] OF oDlg PIXEL SIZE 100,12 UPDATE COLOR nRGB( 128,0,255 )
   @ 50, 00 SAY "SERVICIOS" OF oM:oDlg RIGHT PIXEL SIZE 80,10
   @ 50, 82 COMBOBOX oGet[4] VAR oM:aLS[4] ITEMS ArrayCol( oM:aLib,1 ) ;
      SIZE 100,99 OF oDlg PIXEL
   @ 62, 00 SAY "Agrupar Servicios Públicos" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 62, 82 CHECKBOX oGet[5] VAR oM:aLS[5] PROMPT " " OF oDlg SIZE 14,10 PIXEL
   @ 74, 00 SAY "TIPO DE IMPRESORA"  OF oDlg RIGHT PIXEL SIZE 80,10
   @ 74, 82 COMBOBOX oGet[6] VAR oM:aLS[6] ITEMS { "Matriz","Laser" };
      SIZE 48,90 OF oDlg PIXEL
   @ 74,134 CHECKBOX oGet[7] VAR oM:aLS[7] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 86,00 SAY "Escoja la Fuente"  OF oDlg RIGHT PIXEL SIZE 80,10
   @ 86,82 COMBOBOX oGet[8] VAR oM:cFont ITEMS oM:aFont SIZE 80,99 OF oDlg PIXEL;
      WHEN oM:aLS[6] > 1
   @ 100, 50 BUTTON oGet[09] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[9]:Disable(), oM:ArmarMOV( oDlg ) ,;
        oGet[9]:Enable() , oGet[9]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 100,100 BUTTON oGet[10] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 106, 02 SAY "[CGELIBRO]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT ( Empresa( .t. ) )
RETURN


//------------------------------------//
CLASS TLibro FROM TIMPRIME

 DATA aLS, aLib, aRes, hRes, oLib, nL

 METHOD New( lChq ) Constructor
 METHOD Timbrar( oDlg )
 METHOD ArmarMOV( oDlg )
 METHOD ListoDOS()
 METHOD Lineas()
 METHOD Cabecera( lSep,nSpace,nSuma )

ENDCLASS

//------------------------------------//
METHOD NEW( lChq ) CLASS TLibro
   LOCAL hDC
If lChq
   hDC := GetDC( 0 )
   ::aFont := GetFontNames( hDC )
   ::aLS   := { DATE(),DATE(),0,1,.f.,oApl:nTFor,.t.,"","999,999,999.99" }
   ::aLib  := Buscar( "SELECT servicio, cuenta FROM cgeservi ORDER BY servicio","CM",,9 )
   ::cFont := "Arial"
Else
//aLib := { "LIBRO DE MAYOR Y BALANCES","L I B R O  D I A R I O",;
//          "LIBRO INVENTARIO Y BALANCES","L I B R O  D E  A C T A S" }
   ::aLib := {}
   ::oLib := oApl:Abrir( "cgelibro","row_id",,,50 )
   ::oLib:dbEval( {|o| AADD( ::aLib, { o:LIBRO,o:FOLIO,o:Row_id } ) } )
    ::aLS   := { 1,::aLib[1,2] + 1,::aLib[1,2] + 1,oApl:nTFor,.f. }
EndIf
 Empresa( .t. )
RETURN NIL

//------------------------------------//
METHOD Timbrar( oDlg ) CLASS TLibro
   LOCAL cEmp, cLib, oRpt
cLib := ::aLib[::aLS[1],1]
If ::aLS[4] == 1
   cEmp := PADC( oApl:cEmpresa,44 )
   cLib := PADC( cLib,30 ) + "   FOLIO No. "
   oRpt := TDosPrint()
   oRpt:New( oApl:cPuerto,oApl:cImpres,,::aLS[5] )
   oRpt:nPage := 1
   oRpt:SetFont( oRpt:CPINormal,82,2 )
   While ::aLS[2] <= ::aLS[3]
      oRpt:Say( 01,00,oRpt:CPILarge + cEmp )
      oRpt:Say( 03,20,cLib + STR( ::aLS[2],6 ) )
      oRpt:NewPage()
      ::aLS[2] ++
   EndDo
   oRpt:End()
Else
   ::Init( "TIMBRAR LIBROS", .f. ,, !::aLS[5] )
   cEmp := { ::Centrar( oApl:cEmpresa,::aFnt[4] ),;
             ::Centrar( cLib,::aFnt[2] ) }
   While ::aLS[2] <= ::aLS[3]
      PAGE
        UTILPRN ::oUtil 1.0,cEmp[1] SAY oApl:cEmpresa FONT ::aFnt[4]
        UTILPRN ::oUtil 2.0,cEmp[2] SAY cLib
        UTILPRN ::oUtil 2.0,16.0    SAY "FOLIO No." + STR( ::aLS[2],7 )
      ENDPAGE
      ::aLS[2] ++
   EndDo
   IMPRIME END .F.
EndIf
If !::aLS[5]
   ::oLib:Seek( {"row_id",::aLib[::aLS[1],3] } )
   ::oLib:FOLIO := ::aLS[3] ; ::oLib:Update(.f.,1)
EndIf
RETURN NIL

//------------------------------------//
METHOD ArmarMOV( oDlg ) CLASS TLibro
   LOCAL cQry
 ::aEnc := { .t.,"RELACION DE CHEQUES POR SERVICIO","",CTOD(""),"",0 }
If ::aLS[5]
   cQry := " AND LEFT(c.servicio,4) = '" + LEFT( ::aLib[::aLS[4],2],4 ) + "'"
Else
   ::aEnc[2] += " : " + ALLTRIM( ::aLib[::aLS[4],1] )
   cQry := " AND c.servicio = " + xValToChar( ::aLib[::aLS[4],2] )
EndIf
cQry += If( ::aLS[3] == 0, "", " AND c.codigonit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT)) )
cQry := "SELECT c.fecha, b.nombre, c.cta_cte, c.cheque, c.comprobant, c.valorb"+;
             ", c.servicio, n.nombre "                                         +;
        "FROM chequesc c LEFT JOIN cgebanco b USING(empresa, banco, cta_cte)"  +;
                       " LEFT JOIN cadclien n"                  +;
          " ON c.codigonit = n.codigo_nit "                     +;
        "WHERE c.empresa  = " + LTRIM(STR(oApl:nEmpresa))       +;
         " AND c.fecha   >= " + xValToChar( ::aLS[1] )          +;
         " AND c.fecha   <= " + xValToChar( ::aLS[2] ) +  cQry  +;
         " AND c.estado <> 2 ORDER BY c.fecha, b.nombre"
::hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
              MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (::nL := MSNumRows( ::hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( ::hRes ) ; RETURN NIL
EndIf
 ::aEnc[3] := "DESDE "+ NtChr( ::aLS[1],"2" )+ " HASTA "+ NtChr( ::aLS[2],"2" )
If ::aLS[6] == 1
   ::ListoDOS()
Else
   ::Init( ::aEnc[2], .f. ,, !::aLS[7] ,,,, 5 )
     PAGE
       ::Lineas()
     ENDPAGE
   IMPRIME END .F.
EndIf
 MSFreeResult( ::hRes )
RETURN NIL

//------------------------------------//
METHOD ListoDOS() CLASS TLibro
   LOCAL oRpt
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[2],::aEnc[3],;
          "   FECHA    BANCO                          CTA_CTE"+;
          "    Nro.CHEQUE   VALOR CHEQUE"},::aLS[7] )
//27-JUN-2012 123456789012345678901234567890 1234567890 1234567890  999,999,999.99
//                                               "Cpbante #1234567
While ::nL > 0
    ::aRes := MyReadRow( ::hRes )
    AEVAL( ::aRes, {| xV,nP | ::aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   oRpt:Titulo( 79 )
   If ::aEnc[4]  # ::aRes[1]
      ::aEnc[4] := ::aRes[1]
      ::aEnc[5] := ""
      oRpt:Say( oRpt:nL, 00,NtChr( ::aRes[1],"2" ) )
   EndIf
   If ::aEnc[5]  # ::aRes[2]
      ::aEnc[5] := ::aRes[2]
      oRpt:Say( oRpt:nL, 12,::aRes[2] )
   EndIf
   oRpt:Say( oRpt:nL, 43,::aRes[3] )
   oRpt:Say( oRpt:nL, 54,STR(::aRes[4],10) )
   oRpt:Say( oRpt:nL, 65,TRANSFORM( ::aRes[6],::aLS[9] ) )
   oRpt:nL ++
   oRpt:Say( oRpt:nL, 14,::aRes[8] )
   oRpt:Say( oRpt:nL, 48,"Cpbante #" +STR(::aRes[5],7) )
   oRpt:nL ++
   ::aEnc[6] += ::aRes[6]
   ::nL --
EndDo
   oRpt:nL += 2
   oRpt:Say( oRpt:nL, 12,"TOTALES ====>",,,1 )
   oRpt:Say( oRpt:nL, 65,TRANSFORM( ::aEnc[6],::aLS[9] ) )
   oRpt:NewPage()
   oRpt:End()
RETURN NIL

//------------------------------------//
METHOD Lineas() CLASS TLibro

While ::nL > 0
    ::aRes := MyReadRow( ::hRes )
    AEVAL( ::aRes, {| xV,nP | ::aRes[nP] := MyClReadCol( ::hRes,nP ) } )
   ::Cabecera( .t. )
   If ::aEnc[4]  # ::aRes[1]
      ::aEnc[4] := ::aRes[1]
      ::aEnc[5] := ""
      UTILPRN ::oUtil Self:nLinea,01.0 SAY NtChr( ::aRes[1],"2" )
   EndIf
   If ::aEnc[5]  # ::aRes[2]
      ::aEnc[5] := ::aRes[2]
      UTILPRN ::oUtil Self:nLinea,03.7 SAY ::aRes[2]
   EndIf
   UTILPRN ::oUtil Self:nLinea,11.5 SAY ::aRes[3]
   UTILPRN ::oUtil Self:nLinea,16.2 SAY ::aRes[4]                       RIGHT
   UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( ::aRes[6],::aLS[9] ) RIGHT
   ::nLinea += 0.5
   UTILPRN ::oUtil Self:nLinea,04.0 SAY ::aRes[8]
   UTILPRN ::oUtil Self:nLinea,12.2 SAY "Comprobante #"
   UTILPRN ::oUtil Self:nLinea,16.2 SAY ::aRes[5]                       RIGHT
   ::aEnc[6] += ::aRes[6]
   ::nL --
EndDo
   ::Cabecera( .t.,0.5 )
   UTILPRN ::oUtil Self:nLinea,11.5 SAY "TOTALES ====>"
   UTILPRN ::oUtil Self:nLinea,20.5 SAY TRANSFORM( ::aEnc[6],::aLS[9] ) RIGHT
RETURN NIL

//------------------------------------//
METHOD Cabecera( lSep,nSpace,nSuma ) CLASS TLibro
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
   UTILPRN ::oUtil 3.0, 1.4 SAY "F e c h a"
   UTILPRN ::oUtil 3.0, 3.7 SAY "BANCO"
   UTILPRN ::oUtil 3.0,11.5 SAY "CTA_CTE"
   UTILPRN ::oUtil 3.0,16.2 SAY "Nro.CHEQUE"   RIGHT
   UTILPRN ::oUtil 3.0,20.5 SAY "VALOR CHEQUE" RIGHT
   UTILPRN ::oUtil LINEA 3.5,1.0 TO 3.5,20.5 PEN ::oPen
   ::nLinea := 3.5
   ::nPage ++
EndIf
RETURN NIL
/*
//------------------------------------//
PROCEDURE Codigo_nit()
   LOCAL aCli := { 0,0 }, cQry, oNit, oPuc
If !MsgYesNo( "Si esta todo Ok.", "Actualizo Los NITS" )
   RETURN
EndIf
oNit := oApl:Abrir( "clien","Codigo_nit",.f. )
oNit:Seek( {"codigo_nit >= ",1} )
oApl:oWnd:SetMsg("Actualizando [cadclien]")
While !oNit:Eof()
   If !oApl:oNit:Seek( {"codigo",oNit:CODIGO} )
      oApl:oNit:CODIGO    := oNit:CODIGO
      oApl:oNit:DIGITO    := oNit:DIGITO
      oApl:oNit:TIPOCOD   := oNit:TIPOCOD
      oApl:oNit:NOMBRE    := oNit:NOMBRE
      oApl:oNit:TELEFONO  := oNit:TELEFONO
      oApl:oNit:FAX       := oNit:FAX
      oApl:oNit:DIRECCION := oNit:DIRECCION
      oApl:oNit:EMAIL     := oNit:EMAIL
      oApl:oNit:CIUDAD    := oNit:CIUDAD
//      oApl:oNit:CODIGO_CIU:= oNit:CODIGO_CIU
      oApl:oNit:CODIGO_NIT:= Buscar( "SELECT MAX(codigo_nit) FROM cadclien","CM" ) + 1
      oApl:oNit:Append( .t. )
      aCli[1] ++
   EndIf
   If oNit:CODIGO_NIT # oApl:oNit:CODIGO_NIT
      cQry := "UPDATE cgemovd SET OK = 1, " +;
                     "codigo_nit = " + LTRIM(STR(oApl:oNit:CODIGO_NIT))+;
              " WHERE empresa    = " + LTRIM(STR(oApl:nEmpresa))       +;
                " AND codigo_nit = " + LTRIM(STR(oNit:CODIGO_NIT))     +;
                " AND OK = 0"
      MSQuery( oApl:oMySql:hConnect,cQry )
      cQry := STRTRAN( cQry,"movd","acumn" )
      MSQuery( oApl:oMySql:hConnect,cQry )
      cQry := STRTRAN( cQry,"acumn","movc" )
      MSQuery( oApl:oMySql:hConnect,STRTRAN( cQry,"_","" ) )
      aCli[2] ++
   EndIf
   oNit:Skip(1):Read()
   oNit:xLoad()
EndDo
oNit:Destroy()
MsgInfo( "Cambios"+STR(aCli[2],5),"Nuevos"+STR(aCli[1],5) )
*/
/*
If MsgYesNo( "Acumn, Movc, Movd", "Insertar" )
   cQry := "INSERT INTO cgeacumn (empresa, ano_mes, cuenta, "     +;
           "codigo, codigo_nit, valor_deb, valor_cre, valor_ret) "+;
           "SELECT n.empresa, n.ano_mes, n.cuenta, n.codigo, "    +;
           "n.codigo_nit, n.valor_deb, n.valor_cre, n.valor_ret " +;
           "FROM acumn n"
   oApl:oWnd:SetMsg("Insertando en [cgeacumn]")
   MSQuery( oApl:oMySql:hConnect,cQry )
   cQry := "INSERT INTO cgemovc (empresa, ano_mes, fecha, fuente, comprobant, "+;
           "control, concepto, estado, codigonit, valorb, consecutiv) "        +;
           "SELECT c.empresa, c.ano_mes, c.fecha, c.fuente, c.comprobant, "    +;
           "c.control, c.concepto, c.estado, c.codigonit, c.valorb, c.consecutiv "+;
           "FROM movc c"
   oApl:oWnd:SetMsg("Insertando en [cgemovc]")
   MSQuery( oApl:oMySql:hConnect,cQry )
   cQry := "INSERT INTO cgemovd (empresa, ano_mes, control, cuenta, infa, " +;
                     "infb, infc, infd, codigo_nit, valor_deb, valor_cre) " +;
           "SELECT d.empresa, d.ano_mes, d.control, d.cuenta, d.infa, "     +;
           "d.infb, d.infc, d.infd, d.codigo_nit, d.valor_deb, d.valor_cre "+;
           "FROM movd d"
   oApl:oWnd:SetMsg("Insertando en [cgemovd]")
   MSQuery( oApl:oMySql:hConnect,cQry )
   MsgInfo( "ya hice la Insercion","LISTO" )
EndIf
oPuc := oApl:Abrir( "cgeplan","Empresa, Cuenta" )
oNit := oApl:Abrir( "plan","Empresa, Cuenta",.f. )
oNit:Seek( {"cuenta >= ","11"} )
While !oNit:Eof()
   If !oPuc:Seek( {"empresa",oApl:nPuc,"cuenta",oNit:CUENTA} )
      oPuc:EMPRESA    := oApl:nPuc       ; oPuc:CUENTA     := oNit:CUENTA
      oPuc:NIVEL      := oNit:NIVEL      ; oPuc:NOMBRE     := oNit:NOMBRE
      oPuc:INFA       := oNit:INFA       ; oPuc:INFB       := oNit:INFB
      oPuc:INFC       := oNit:INFC       ; oPuc:INFD       := oNit:INFD
      oPuc:PAGOS_TERC := oNit:PAGOS_TERC ; oPuc:DB_CR      := oNit:DB_CR
      oPuc:ESTADO     := oNit:ESTADO     ; oPuc:Append( .f. )
   EndIf
   oNit:Skip(1):Read()
   oNit:xLoad()
EndDo
oNit:Destroy()
oPuc:Destroy()
*/
//RETURN