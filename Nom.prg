/* Programa............................ NOM
*    Sistema De Nomina
*  Fecha de escritura...................29/12/2005
*  Fecha de Culminacion ................
*  Version ..............................1.0 para windows 9x
*  Lenguaje ...................CA-Clipper for Windows Library(fiveWin 2.0)
*  Programador ................. Martin A. Toloza Lozano
*/
#include "Fivewin.ch"        //Incluir Archivos Nesaarios
#include "Colors.ch"
#include "Objects.ch"
#include "Eagle1.ch"

MEMVAR oApl

FUNCTION main()
   LOCAL  hBorland, oBarra, oBru, oIco
   PUBLIC oApl
SET CENTURY ON
SET EXACT ON
SET CONFIRM ON
SET EPOCH TO 1990
SET DATE FORMAT TO "DD.MM.YYYY"
SET DELETED ON
SET _3DLOOK ON

SETKEY( VK_F4,{||Empresa()} )

oApl := TNom()
oApl:New()

DEFINE ICON  oIco RESOURCE "Hombre"
DEFINE BRUSH oBru FILE oApl:FondoWnd()

// Definir Ventana Principal
DEFINE WINDOW oApl:oWnd FROM 1,1 TO 400,600 PIXEL;
   TITLE oApl:cEmpresa +                         ;
        " [ Sistema de Nomina ver 1.0 ]"         ;
   BRUSH oBru                                    ;
   MENU Creamenu()                               ;
   MDI ICON oIco                                 ;
   COLOR CLR_BLUE,RGB(0,128,192)
   SET MESSAGE OF oApl:oWnd TO "Tolozano. Telf: 3430560  Celular: 300-8045043";
       TIME DATE KEYBOARD

   DEFINE BUTTONBAR oBarra _3D OF oApl:oWnd SIZE 35,35
      DEFINE BUTTON RESOURCE "Salir" ADJUST NOBORDER OF oBarra;
         TOOLTIP "Cerrar la aplicación";
         ACTION oApl:oWnd:End()
      DEFINE BUTTON RESOURCE "ARCHIVAR" ADJUST GROUP NOBORDER OF oBarra;
         TOOLTIP "Captura de las Novedades"
//         ACTION Novedades()
      DEFINE BUTTON RESOURCE "DEDISCO"  ADJUST GROUP NOBORDER OF oBarra;
         TOOLTIP "Archivo plano de la Nomina para Davivienda";
         ACTION Diskette()

ACTIVATE WINDOW oApl:oWnd MAXIMIZED             ;
   ON INIT (If( oApl:lSalir, oApl:oWnd:End(), ));
   VALID If( oApl:lSalir, .t., Salir() )
RETURN NIL

//------------------------------------//
FUNCTION Salir()
If (MsgYesNo("Deseas salir del programa","Abandonar el sistema"),;
   (oApl:oMySql:End(), oApl:lSalir := .t., oApl:oWnd:End()),)
RETURN oApl:lSalir

RETURN NIL

//------------------------------------//
STATIC FUNCTION Creamenu()
   LOCAL oMenu , aMenuP := ARRAY(6)
   LOCAL aTablas := ARRAY(6), aInformes := ARRAY(3)
MENU oMenu
   MENUITEM "&Menu Principal"
   MENU
      MENUITEM aMenuP[1] PROMPT "&Datos Fijos"          ;
         MESSAGE "Modificar las Constantes de la Nomina";
         ACTION DatosFijos()                            ;
         ACCELERATOR ACC_ALT, ASC( "D" )
      MENUITEM aMenuP[2] PROMPT "&Cierre del Periodo"   ;
         MESSAGE "Hacer el Cierre del Periodo"
//         ACTION Nomcierre()
      SEPARATOR
      MENUITEM aMenuP[3] PROMPT "Descuentos Fijos"     ;
         MESSAGE "Modificar los Descuentos Fijos"
//         ACTION NomDesFi()
      MENUITEM aMenuP[4] PROMPT "&Empleados"           ;
         MESSAGE "Mantenimiento de los Empleados"      ;
         ACTION Empleados()                            ;
         ACCELERATOR ACC_ALT, ASC( "E" )
      MENUITEM aMenuP[5] PROMPT "&Novedades"           ;
         MESSAGE "Liquidar las Novedades de la Nomina" ;
         ACTION Novedades()
//         ACCELERATOR ACC_ALT, ASC( "N" )
      SEPARATOR
      MENUITEM aMenuP[6] PROMPT "Sa&lir" ACTION Salir() ;
         MESSAGE "Abandona el sistema"
   ENDMENU

   MENUITEM "&Tablas"
   MENU
      MENUITEM aTablas[1] PROMPT "&Nit ó C.C."   ;
         MESSAGE "Mantenimiento de los Nit ó C.C";
         ACTION Nits()                           ;
         ACCELERATOR ACC_ALT, ASC( "N" )
      MENUITEM aTablas[2] PROMPT "C&onceptos"    ;
         MESSAGE "Mantenimiento de los Conceptos";
         ACTION Conceptos()                      ;
         ACCELERATOR ACC_ALT, ASC( "O" )
      MENUITEM aTablas[3] PROMPT "Tabla de Retención"   ;
         MESSAGE "Modificar los valores de Retención"   ;
         ACTION NomReten()
      MENUITEM aTablas[4] PROMPT "&Trafico de Conceptos";
         MESSAGE "Mantenimiento del Trafico"            ;
         ACTION NomTrafi()
      MENUITEM aTablas[5] PROMPT "Conceptos &Fijos"     ;
         MESSAGE "Mantenimiento de los Conceptos Fijos" ;
         ACTION NomPaDes()
      MENUITEM aTablas[6] PROMPT "Datos Generales"        ;
         MESSAGE "Modificar los valores del Seguro Social";
         ACTION NomTaIss()
      ENDMENU

   MENUITEM "&Informes"
   MENU
      MENUITEM aInformes[1] PROMPT "&Volante de liquidación";
         MESSAGE "Inprimir los Volantes de liquidación"     ;
         ACTION NomLiVol()
      MENUITEM aInformes[2] PROMPT "Liquidación de &Novedades";
         MESSAGE "Liquidación de novedades"                   ;
         ACTION NomLiNov()
      MENUITEM aInformes[3] PROMPT "Auxiliar de Descuentos" ;
         MESSAGE "Listar los Auxiliares de Descuento"
//         ACTION NomLiAux()
      ENDMENU
ENDMENU

RETURN oMenu

//------------------------------------//
CLASS TNom

   DATA aWHija AS ARRAY INIT { NIL,NIL }
   DATA aInvme AS ARRAY INIT { 0,0 }
   DATA aOptic
   DATA cEmpresa INIT "Martin Toloza Lozano"
   DATA dFec     INIT DATE()
   DATA lSalir   INIT .F.
   DATA Tipo     INIT "U"
   DATA cCiu, cPer, cRuta1, cRuta2, cLocal, cImpres, cPuerto, nTHoja, nLF
   DATA cIP, cUser, cBaseD, nPort, cSocket
   DATA lEnLinea, lFam, nEmpresa, nPuc, nSaldo
   DATA nClrBackHead, nClrForeHead, nClrBack, nClrFore
   DATA nClrBackFocus, nClrForeFocus, nClrNBack, nClrNFore, nGotFocus, nLostFocus
   DATA oMysql, oDb, oWnd, oFont
   DATA oEmp, oNit, oEpl, oCon, oFie, oFis
   DATA oHab, oDef, oTra, oRet, oIss, oPad

   METHOD NEW() Constructor
   METHOD Conectar( cPassw,oGet )
   METHOD Abrir( cTabla,cOrderBy,lBlank,lTemp,nLimit,oGet )
   METHOD FondoWnd()
ENDCLASS

//------------------------------------//
METHOD New() CLASS TNom
   LOCAL oIni, cFecha, aC := ARRAY(30), nP := 0
   LOCAL oDlg, oGet[10], cPassw := SPACE(16)
INI oIni FILE ".\Nom.ini"
   GET ::cIP     SECTION "MySQL"     ENTRY "ServerIP" OF oIni;
       DEFAULT "LocalHost"
   GET ::cUser   SECTION "MySQL"     ENTRY "Usuario"  OF oIni;
       DEFAULT "root"
   GET ::cBaseD  SECTION "MySQL"     ENTRY "DataBase" OF oIni;
       DEFAULT "mysql"
   GET ::nPort   SECTION "MySQL"     ENTRY "nPort"    OF oIni;
       DEFAULT 3306
   GET ::cSocket SECTION "MySQL"     ENTRY "cSocket"  OF oIni;
       DEFAULT "/tmp/mysql.sock"
   GET ::cRuta1  SECTION "Tablas"    ENTRY "Ruta1"    OF oIni;
       DEFAULT "\ProyecFW\Bitmap\"
   GET ::cRuta2  SECTION "Tablas"    ENTRY "Ruta2"    OF oIni;
       DEFAULT "\ProyecFW\Datos\"
   GET ::cLocal  SECTION "Tablas"    ENTRY "Localiz"  OF oIni;
       DEFAULT "COC"
   GET ::cImpres SECTION "Impresora" ENTRY "Modelo"   OF oIni;
       DEFAULT "EPSON"
   GET ::cPuerto SECTION "Impresora" ENTRY "Puerto"   OF oIni;
       DEFAULT "LPT1"
   GET ::nTHoja  SECTION "Impresora" ENTRY "THoja"    OF oIni;
       DEFAULT 66
   GET ::nLF     SECTION "Impresora" ENTRY "LFactura" OF oIni;
       DEFAULT 11
   GET cFecha    SECTION "BrowSetu"  ENTRY "Colors"   OF oIni;
       DEFAULT "252,231,165,120,25,25,255,255,235,0,0,0,225,192,192,0,0,0,128,178,182,100,0,0,255,255,255,0,0,0"
//   SET SECTION "Impresora" ENTRY "Modelo" TO oApl:cImpres OF oIni
ENDINI
AFILL( aC,0 )
WHILE !EMPTY(cFecha)
   aC[++nP] := VAL( Saca(@cFecha,",") )
ENDDO
//  DEFINE FONT ::oFont NAME "Ms Sans Serif" SIZE 0, -8
::nClrBackHead  := nRGB( aC[01],aC[02],aC[03] ) //Fondo Encabezado
::nClrForeHead  := nRGB( aC[04],aC[05],aC[06] ) //Texto Encabezado
::nClrBack      := nRGB( aC[07],aC[08],aC[09] ) //Fondo Browse
::nClrFore      := nRGB( aC[10],aC[11],aC[12] ) //Texto Browse
::nClrBackFocus := nRGB( aC[13],aC[14],aC[15] ) //Linea Activa Browse
::nClrForeFocus := nRGB( aC[16],aC[17],aC[18] ) //Texto Activa Browse
::nClrNBack     := nRGB( aC[19],aC[20],aC[21] ) //Fondo Celda con Foco
::nClrNFore     := nRGB( aC[22],aC[23],aC[24] ) //Texto Celda con Foco
::nGotFocus     := nRGB( aC[25],aC[26],aC[27] ) //Fondo Edicion
::nLostFocus    := nRGB( aC[28],aC[29],aC[30] ) //Texto Edicion
cFecha  := "CONECTANDO ...."
::cIP   := PADR( ::cIP   ,16 )
::cUser := PADR( ::cUser ,16 )
::cBaseD:= PADR( ::cBaseD,16 )
DEFINE DIALOG oDlg FROM 1, 2 TO 15, 40 TITLE "Conexion TC/IP remota a " + oApl:cIP

   @ 02,  0 SAY "Server IP:"         OF oDlg RIGHT PIXEL SIZE  50,10
   @ 02, 52 GET oGet[1] VAR ::cIP    OF oDlg       PIXEL SIZE  46,10
   @ 16,  0 SAY "Usuario:"           OF oDlg RIGHT PIXEL SIZE  50,10
   @ 16, 52 GET oGet[2] VAR ::cUser  OF oDlg       PIXEL SIZE  46,10
   @ 30,  0 SAY "Clave:"             OF oDlg RIGHT PIXEL SIZE  50,10
   @ 30, 52 GET oGet[3] VAR cPassw   OF oDlg       PIXEL SIZE  46,10 PASSWORD
   @ 44,  0 SAY "Base Datos:"        OF oDlg RIGHT PIXEL SIZE  50,10
   @ 44, 52 GET oGet[4] VAR ::cBaseD OF oDlg       PIXEL SIZE  46,10
   @ 58,  0 SAY oGet[5] VAR cFecha   OF oDlg RIGHT PIXEL SIZE  50,10
   @ 58, 52 METER oGet[6] VAR ::aInvme[1] TOTAL 100 SIZE 46,10 OF oDlg PIXEL
   @ 58,104 SAY oGet[7]   VAR ::aInvme[2] OF oDlg  PIXEL SIZE  30,10
   @ 72, 52 SAY oGet[8] VAR "     "  OF oDlg       PIXEL SIZE  90,10

   @ 88, 50 BUTTON oGet[09] PROMPT "&Ok"     OF oDlg SIZE 44,12 ACTION ;
      ( oGet[9]:Disable(), ::Conectar( cPassw,oGet ), oDlg:End() ) PIXEL
   @ 88,100 BUTTON oGet[10] PROMPT "&Cancel" OF oDlg SIZE 44,12 CANCEL ;
      ACTION ( ::lSalir := .t., oDlg:End() ) PIXEL
ACTIVATE DIALOG oDlg CENTERED ;
   ON INIT (oDlg:PostMsg( WM_KEYDOWN, 13, 0 ), oDlg:PostMsg( WM_KEYDOWN, 13, 0 ))
If !::lSalir
   cFecha := If( RIGHT( AmPm(TIME()),2 ) == "am", "BUENOS DIAS",;
                 "BUENAS TARDES" ) + "   >> HOY ES <<"  + CRLF +;
        NtChr( DATE(),"5" ) + " " + NtChr( DATE(),"2" ) + CRLF +;
              "Y SON LAS " + AmPm(TIME())
   If !MsgYesNo( cFecha,::cUser )
      ::lSalir := .t.
      RETURN NIL
   EndIf
   If oApl:dFec >= CTOD("30.06.2006") + ::oEmp:DIAS
      MsgStop( "ESTO ERA UN PROGRAMA DE DEMOSTRACION" + CRLF +;
               "POR FAVOR CONTACTE A SU PROPIETARIO " + CRLF +;
               "PARA OBTENER LA LICENCIA............" )
      ::lSalir := .t.
   EndIf
   If DATE() < ::oEmp:FEC_HOY .AND. oApl:lEnLinea
      MsgStop( "Fecha del Sistema menor que la Ultima Facturación",">> ERROR <<" )
      ::lSalir := .t.
   EndIf
EndIf

RETURN NIL

//--------Conectarse con MySQL--------//
METHOD Conectar( cPassw,oGet ) CLASS TNom
   LOCAL nSec := Seconds()
 INIT CONNECT  ::oMySql         ;
      HOST     ALLTRIM(::cIP)   ;
      USER     ALLTRIM(::cUser) ;
      PASSWORD ALLTRIM(cPassw)  ;
      PORT     ::nPort          ;
      SOCKET   ALLTRIM(::cSocket)
 If ::oMySql:lConnected
    USE DATABASE ::oDb NAME (ALLTRIM(::cBaseD)) OF ::oMySql
    If ::oDb:Used()
       oGet[5]:setText( "Conectado " + LTRIM(STR(SECONDS() - nSec)) +" S" )
       ::oEmp := ::Abrir( "cadempre",,,,,oGet )
       ::oEmp:GoTop():Read()
       cPassw := ::oEmp:FieldGet( 5 )
       ::aOptic := {}
       While !::oEmp:EOF()
          ::oEmp:xLoad()
          AADD( ::aOptic, { ::oEmp:Localiz, STR(::oEmp:Empresa,2) } )
          ::oEmp:Skip(1):Read()
       EndDo
       ::oEmp:Seek( {"Localiz",cPassw} )
       nEmpresa( .f. )
       ::oNit := ::Abrir( "cadclien",,,,,oGet )
       ::oEpl := ::Abrir( "nomemple","Codigo",.t.,,,oGet )
       ::oCon := ::Abrir( "nomconce","Concepto",,,,oGet )
       ::oFie := ::Abrir( "nomfijoe",,,,,oGet )
       ::oFis := ::Abrir( "nomfijos","Periodoi",,,,oGet )
//     ::oFam := ::Abrir( "cadfactm","Optica, Numfac, Tipo",,,30,oGet )
//     ::oPag := ::Abrir( "cadpagos","Optica, Numfac, Tipo",,,30,oGet )
//     ::oVen := ::Abrir( "cadventa","Optica, Numfac, Tipo",,,50,oGet )
       ::oHab := ::Abrir( "ciudades","Codigo",,,100,oGet )
    // ::oHis := ::Abrir( "historia","Nroiden",,,100,oGet )
    // ::oTra := ::Abrir( "ridocupa","Codigo",,,100,oGet )
/*
 CREATE SERVER oApl:oDef  ALIAS Def    INDEX Codigo
 CREATE SERVER oApl:oPad  ALIAS Pades  INDEX Concepto
 CREATE SERVER oApl:oIss  ALIAS Iss
 CREATE SERVER oApl:oRet  ALIAS Ret    INDEX Valores
 CREATE SERVER oApl:oTra  ALIAS Tra    INDEX Concepto
*/
       ::oFie:Seek( {"Empresa",oApl:nEmpresa} )
    Else
       ::lSalir := .t.
    EndIf
 Else
    ::lSalir := .t.
 EndIf
If ::lSalir
   MsgInfo( "No hay conexion", "Señor(a) : "+ALLTRIM(::cUser) )
EndIf
RETURN NIL

//------------------------------------//
METHOD Abrir( cTabla,cOrderBy,lBlank,lTemp,nLimit,oGet ) CLASS TNom
   LOCAL oTb, lSi := .f., nSec, nCon := 0
   DEFAULT cOrderBy := 1, lBlank := .f. , lTemp := .f.
While !lSi .AND. nCon <= 3
   If !(lSi := ::oDb:ExistTable( cTabla ))
      Diccionario( cTabla )
   EndIf
   nCon++
EndDo
If ::oDb:ExistTable( cTabla )
//	New( oDbCon, cName, cWhere, cHaving, cOrderBy, nLimit )
   nSec:= Seconds()
   oTb := TMyTable( (cTabla) ):New( ::oDb, (cTabla),"",,cOrderBy,nLimit )
   If oTb:Open()
      nCon := oTb:RecCount()
      If nCon == 0 .AND. !lTemp
         MsgInfo( "está sin registros",cTabla )
      ElseIf nCon > 0 .AND. lTemp
         oTb:dbEval( {|o| o:Delete( .f.,1 ) } )
      EndIf
      If lBlank
         oTb:xBlank()
      EndIf
   EndIf
   If oGet # NIL
      nSec := SECONDS() - nSec
      oGet[8]:setText( cTabla +" Demore " + STR(nSec) + " Seg" )
      ::aInvme[1] += 10   ; oGet[6]:Refresh() ; SysRefresh()
      ::aInvme[2] += nSec ; oGet[7]:Refresh()
   EndIf
Else
   MsgInfo( "No Existe !!!!",cTabla )
EndIf
RETURN oTb

//------------------------------------//
METHOD FondoWnd() CLASS TNom
   LOCAL aEstru  := DIRECTORY( oApl:cRuta1+"*.BMP" )
   LOCAL aNombre := {}, nFon, nLen
AEVAL( aEstru , {|aFile| AADD( aNombre, oApl:cRuta1+ aFile[1] ) } )
If LEN( aNombre ) == 0
   AADD( aNombre, "STYLE TILED" )
EndIf
nLen := LEN( aNombre )
nFon := nRandom( nLen ) + 1
nFon := If( nFon > nLen, nLen, nFon )
RETURN aNombre[ nFon ]

//------------------------------------//
FUNCTION Diskette()
   LOCAL oDlg, oGet := ARRAY(4), aCab := { Emp->FECHAHAS,.f. }
DEFINE DIALOG oDlg TITLE "Archivo Plano" FROM 0, 0 TO 06,46
   @ 02, 00 SAY "FECHA [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 02, 82 GET oGet[1] VAR aCab[1] OF oDlg SIZE 40,10 PIXEL
   @ 02,130 CHECKBOX oGet[2] VAR aCab[2] PROMPT "Con Prima" OF oDlg SIZE 60,12 PIXEL
   @ 20, 50 BUTTON oGet[3] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION ;
      ( Espejo( aCab ), oDlg:End() ) PIXEL
   @ 20,100 BUTTON oGet[4] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(260,230)
RETURN NIL

//------------------------------------//
STATIC PROCEDURE Espejo( aLS )
   LOCAL cRegis, hFile, aPG := { 0,0,0,"NOMI" + Emp->LOCALIZ }
FERASE( aPG[4]+".PLN" )
hFile := FCREATE( aPG[4]+".PLN", 0 )
Nov->(dbSeek( STR(oApl:nEmpresa)+DTOS(aLS[1]),.t. ))
aPG[1] := Nov->CODIGO
While Nov->EMPRESA  == oApl:nEmpresa .AND.;
      Nov->FECHAHAS == aLS[1]        .AND. !Nov->(EOF())
   If Nov->CLASEPD  == 1
      aPG[3] += Nov->VALORNOVED
   Else
      aPG[3] -= Nov->VALORNOVED
   EndIf
   Nov->(dbSkip())
   If aPG[1]  # Nov->CODIGO .OR. Nov->(EOF())
      aPG[1] := Nov->CODIGO
      aPG[2] ++
   EndIf
EndDo
aPG[4] := "NOMIP" + If( aLS[2], "P", "N" ) + StrZero(oApl:nEmpresa,2)
cRegis := "RC"                                    +;
          StrZero(VAL(LEFT(Emp->Nit,3)            +;
                    SUBSTR(Emp->Nit,5,3)          +;
                    SUBSTR(Emp->Nit,9,3)          +;
                    SUBSTR(Emp->Nit,13,1)),16)    +;
          aPG[4]                                  +;
          StrZero(VAL(LEFT(Emp->CTACTE,4)         +;
                    SUBSTR(Emp->CTACTE,6,7)       +;
                    SUBSTR(Emp->CTACTE,14,1)),16) +;
          "CA000051"                              +;
          STRTRAN(StrZero(aPG[3],19,2),".")       +;
          StrZero(aPG[2],6)                       +;
          "00000000"                              +;
          "000000"                                +;
          "00009999"                              +;
          "00000000"                              +;
          "000000"                                +;
          "0001"                                  +;
          "0000000005890000"                      +;
          Strzero(0,40)
FWRITE( hFile, cRegis + CRLF )
Nov->(dbSeek( STR(oApl:nEmpresa)+DTOS(aLS[1]),.t. ))
aPG[1] := Nov->CODIGO
aPG[3] := 0
While Nov->EMPRESA  == oApl:nEmpresa .AND.;
      Nov->FECHAHAS == aLS[1]        .AND. !Nov->(EOF())
   If Nov->CLASEPD  == 1
      aPG[3] += Nov->VALORNOVED
   Else
      aPG[3] -= Nov->VALORNOVED
   EndIf
   Nov->(dbSkip())
   If aPG[1]  # Nov->CODIGO .OR. Nov->(EOF())
      Epl->(dbSeek( STR(aPG[1]) ))
      cRegis := "TR"                                    +;
                StrZero(Epl->CEDULA,16)                 +;
                "0000000000000000"                      +;
                StrZero(VAL(LEFT(Epl->CTACTE,4)         +;
                          SUBSTR(Epl->CTACTE,6,7)       +;
                          SUBSTR(Epl->CTACTE,14,1)),16) +;
                "CA000051"                              +;
                STRTRAN(StrZero(aPG[3],19,2),".")       +;
                "0000000209999"                         +;
                Strzero(0,40)                           +;
                Strzero(0,18)                           +;
                "00000000"                              +;
                "00000000"                              +;
                "0000000"
      FWRITE( hFile, cRegis + CRLF )
      aPG[1] := Nov->CODIGO
      aPG[3] := 0
   EndIf
EndDo
FCLOSE( hFile )
RETURN
