/* Programa............................ CSJ
*    Sistema De Caja Registradora
*  Fecha de escritura...................14/02/2002
*  Fecha de Culminacion .................
*  Version ..............................1.0 para windows 9x
*  Lenguaje ...................CA-Clipper for Windows Library(fiveWin 2.0)
*  Programador ................. Martin A. Toloza Lozano
*/
#include "Fivewin.ch"        //Incluir Archivos Nesaarios
#include "Colors.ch"
#include "Objects.ch"
#include "Eagle1.ch"

MEMVAR oApl

FUNCTION Main()
   LOCAL  oBru, oIco
   PUBLIC oApl
SET CENTURY ON
SET EXACT ON
SET CONFIRM ON
SET EPOCH TO 1990
SET DATE FORMAT TO "DD.MM.YYYY"
SET DELETED ON
SET _3DLOOK ON

SETKEY( VK_F4,{||Empresa()} )

oApl := TCao()
oApl:New()

DEFINE ICON  oIco RESOURCE "RECIBOS"
DEFINE BRUSH oBru FILE oApl:FondoWnd()

// Definir Ventana Principal
DEFINE WINDOW oApl:oWnd FROM 1,1 TO 400,600 PIXEL  ;
   TITLE oApl:cEmpresa +                           ;
        " [ Sistema de Caja Registradora ver 1.0 ]";
   BRUSH oBru                                      ;
   MENU Creamenu()                                 ;
   MDI ICON oIco                                   ;
   COLOR CLR_BLUE,RGB(0,128,192)
   SET MESSAGE OF oApl:oWnd TO "Tolozano. Telf: 3815140  Celular: 300-8045043, 321-6627536";
       TIME DATE KEYBOARD
//   DEFINE BUTTONBAR OF oApl:oWnd _3D SIZE 40, 40 //CURSOR oHand
   DEFINE BUTTONBAR OF oApl:oWnd 3DLOOK SIZE 40,40
      DEFINE BUTTON RESOURCE "ARCHIVAR"   OF oApl:oWnd:oBar NOBORDER ;
         TOOLTIP "Comprobantes de Contabilidad [Ctrl+C]"             ;
         ACTION MovimientoCge( 0 )
      DEFINE BUTTON RESOURCE "ARTICULOS"  OF oApl:oWnd:oBar NOBORDER ;
         TOOLTIP "Crear, Anular e Imprimir Facturas [Ctrl+F]"        ;
         ACTION CaoVenta()
      DEFINE BUTTON RESOURCE "SECURITY"   OF oApl:oWnd:oBar NOBORDER ;
         TOOLTIP "Comprobantes de Ingresos [Ctrl+R]"                 ;
         ACTION CgeIngre() GROUP
      DEFINE BUTTON RESOURCE "MONEY"      OF oApl:oWnd:oBar NOBORDER ;
         TOOLTIP "Comprobantes de Egresos [Ctrl+E]"                  ;
         ACTION CgeChequ()
      DEFINE BUTTON OF oApl:oWnd:oBar NOBORDER ;
         ACTION Inoinart()                     ;
         FILENAME oApl:cIco+"FACE.BMP"         ;
         TOOLTIP "Compras de Articulos [Ctrl+I]"
      DEFINE BUTTON RESOURCE "PROVEEDOR"  OF oApl:oWnd:oBar NOBORDER;
         TOOLTIP "Cotizacioes [Ctrl+Z]"        ;
         ACTION Cotizacion() GROUP
      DEFINE BUTTON  RESOURCE "REINDEZAR" OF oApl:oWnd:oBar NOBORDER;
         TOOLTIP "Actualiza � Reversa los Movimiento" ;
         ACTION CgeActua()
      DEFINE BUTTON RESOURCE "Salir" ADJUST OF oApl:oWnd:oBar NOBORDER;
         TOOLTIP "Cerrar la aplicaci�n";
         ACTION Salir()
ACTIVATE WINDOW oApl:oWnd MAXIMIZED             ;
   ON INIT (If( oApl:lSalir, oApl:oWnd:End(), ));
   VALID If( oApl:lSalir, .t., Salir() )
//CLOSE CONNECT oApl:oMySql
RETURN NIL

//------------------------------------//
CLASS TCao

   DATA aWHija AS ARRAY INIT { NIL,NIL }
   DATA aInvme AS ARRAY INIT { 0,0 }
   DATA aInf, aOptic, aPapel
   DATA cEmpresa INIT "Martin Toloza Lozano"
   DATA dFec     INIT DATE()
   DATA lSalir   INIT .F.
   DATA Tipo     INIT "U"
   DATA cIP, cUser, cBaseD, nPort, cSocket, cRuta1, cRuta2, cImpres
   DATA cPuerto, nTHoja, cFT, cFecha, nTFor, cCiu, cIco, cPer, cTF
   DATA lEnLinea, lFam, lOffice, nEmpresa, nPuc, nSaldo, nX, nY
   DATA nClrBackHead, nClrForeHead, nClrBack, nClrFore
   DATA nClrBackFocus, nClrForeFocus, nClrNBack, nClrNFore, nGotFocus, nLostFocus
   DATA oMysql, oDb, oWnd
   DATA oEmp, oNit, oLin, oMes, oTur
   DATA oCon, oEpl, oFie, oFis, oHab
   DATA oInv, oFac, oFam, oPag //, oTra

   METHOD NEW() Constructor
   METHOD Conectar( cPassw,oGet )
   METHOD Abrir( cTabla,cOrderBy,lBlank,lTemp,nLimit,oGet )
   METHOD FondoWnd()
ENDCLASS

//------------------------------------//
METHOD New() CLASS TCao
   LOCAL oIni, cFecha, aC := ARRAY(30), nP := 0
   LOCAL oDlg, oGet[10], cPassw := SPACE(16)
INI oIni FILE ".\CSJ.ini"
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
   GET ::cImpres SECTION "Impresora" ENTRY "Modelo"   OF oIni;
       DEFAULT "EPSON"
   GET ::cPuerto SECTION "Impresora" ENTRY "Puerto"   OF oIni;
       DEFAULT "LPT1"
   GET ::nTHoja  SECTION "Impresora" ENTRY "THoja"    OF oIni;
       DEFAULT 66
   GET ::cFT     SECTION "Impresora" ENTRY "TFactura" OF oIni;
       DEFAULT "C"
   GET ::cFecha  SECTION "Impresora" ENTRY "FechaFac" OF oIni;
       DEFAULT "SI"
   GET ::nTFor   SECTION "Impresora" ENTRY "Formato"  OF oIni;
       DEFAULT 1
   GET ::nX      SECTION "Logo"      ENTRY "nX"       OF oIni;
       DEFAULT 3
   GET ::nY      SECTION "Logo"      ENTRY "nY"       OF oIni;
       DEFAULT 3
   GET cFecha    SECTION "BrowSetu"  ENTRY "Colors"   OF oIni;
       DEFAULT "252,231,165,120,25,25,255,255,235,0,0,0,225,192,192,0,0,0,128,178,182,100,0,0,255,255,255,0,0,0"
//   SET SECTION "Impresora" ENTRY "Modelo" TO oApl:cImpres OF oIni
ENDINI
AFILL( aC,0 )
WHILE !EMPTY(cFecha)
   aC[++nP] := VAL( Saca(@cFecha,",") )
ENDDO
::cIco          := STRTRAN( ::cRuta1,"map","maps" )
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
aC := { 1,2 }
If !EMPTY( ::cUser )
   AADD( aC,3 )
EndIf
DEFINE DIALOG oDlg FROM 1, 2 TO 15, 40 TITLE "Conexion TC/IP remota a " + oApl:cIP

   @ 02,  0 SAY "Server IP:"         OF oDlg RIGHT PIXEL SIZE  50,10
   @ 02, 52 GET oGet[1] VAR ::cIP    OF oDlg       PIXEL SIZE  46,10
   @ 16,  0 SAY "Base Datos:"        OF oDlg RIGHT PIXEL SIZE  50,10
   @ 16, 52 GET oGet[2] VAR ::cBaseD OF oDlg       PIXEL SIZE  46,10
   @ 30,  0 SAY "Usuario:"           OF oDlg RIGHT PIXEL SIZE  50,10
   @ 30, 52 GET oGet[3] VAR ::cUser  OF oDlg       PIXEL SIZE  46,10
   @ 44,  0 SAY "Clave:"             OF oDlg RIGHT PIXEL SIZE  50,10
   @ 44, 52 GET oGet[4] VAR cPassw   OF oDlg       PIXEL SIZE  46,10 PASSWORD
   @ 58,  0 SAY oGet[5] VAR cFecha   OF oDlg RIGHT PIXEL SIZE  50,10
   @ 58, 52 METER oGet[6] VAR ::aInvme[1] TOTAL 100 SIZE 46,10 OF oDlg PIXEL
   @ 58,104 SAY oGet[7]   VAR ::aInvme[2] OF oDlg  PIXEL SIZE  30,10
   @ 72, 52 SAY oGet[8] VAR "     "  OF oDlg       PIXEL SIZE  90,10

   @ 88, 50 BUTTON oGet[09] PROMPT "&Ok"     OF oDlg SIZE 44,12 ACTION ;
      ( oGet[9]:Disable(), ::Conectar( cPassw,oGet ), oDlg:End() ) PIXEL
   @ 88,100 BUTTON oGet[10] PROMPT "&Cancel" OF oDlg SIZE 44,12 CANCEL ;
      ACTION ( ::lSalir := .t., oDlg:End() ) PIXEL
ACTIVATE DIALOG oDlg CENTERED ;
   ON INIT AEVAL( aC,{|xV| oDlg:PostMsg( WM_KEYDOWN, 13, 0 ) } )
If !::lSalir
   cFecha := If( RIGHT( AmPm(TIME()),2 ) == "am", "BUENOS DIAS",;
                 "BUENAS TARDES" ) + "   >> HOY ES <<"  + CRLF +;
        NtChr( DATE(),"5" ) + " " + NtChr( DATE(),"2" ) + CRLF +;
              "Y SON LAS " + AmPm(TIME())
   If !MsgYesNo( cFecha,::cUser )
      ::lSalir := .t.
      RETURN NIL
   EndIf
/*
   If oApl:dFec >= CTOD("30.07.2014")
      MsgStop( "ESTO ERA UN PROGRAMA DE DEMOSTRACION" + CRLF +;
               "POR FAVOR CONTACTE A SU PROPIETARIO " + CRLF +;
               "PARA OBTENER LA LICENCIA............" )
      MSQuery( oApl:oMySql:hConnect,"RENAME TABLE usuarios TO ordenesx" )
      ::lSalir := .t.
   EndIf
*/
   If DATE() < ::oEmp:FEC_HOY .AND. oApl:lEnLinea
      MsgStop( "Fecha del Sistema menor que la Ultima Facturaci�n",">> ERROR <<" )
      ::lSalir := .t.
   EndIf
   ::aPapel  := {}
   ::lOffice := FILE( "OPENOFICE.BAT" )
/*   cFecha := "SELECT papel, tama�o FROM papeldef "
   oIni   := If( MSQuery( oApl:oMySql:hConnect,cFecha ),;
                 MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nP     := MSNumRows( oIni )
   While nP > 0
      aC := MyReadRow( oIni )
      AADD( ::aPapel, { aC[1],MyClReadCol( oIni,2 ) } )
      nP --
   EndDo*/
EndIf

RETURN NIL

//--------Conectarse con MySQL--------//
METHOD Conectar( cPassw,oGet ) CLASS TCao
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
       If ::oEmp:RecCount() == 0
          Encriptar()
       EndIf
       ::oEmp:GoTop():Read()
       cPassw := ::oEmp:FieldGet( 5 )
       ::aOptic := {}
       While !::oEmp:EOF()
          ::oEmp:xLoad()
          AADD( ::aOptic, { ::oEmp:Localiz, STR(::oEmp:Empresa,2) } )
          ::oEmp:Skip(1):Read()
       EndDo
       ::oEmp:Seek( {"localiz",cPassw} )
       nEmpresa( .f. )
       ::oNit := ::Abrir( "cadclien",,,,,oGet )
       ::oTur := ::Abrir( "turista" ,"dociden",,,60,oGet )
//     ::oBco := ::Abrir( "cadbanco",,,,,oGet )
       ::oLin := ::Abrir( "cadlinea",,,,,oGet )
       ::oInv := ::Abrir( "cadinven","codigo",,,150,oGet )
       ::oMes := ::Abrir( "cadinvme","empresa, codigo, anomes",.t.,,50,oGet )
       ::oFac := ::Abrir( "cadfactc","empresa, numfac, tipo",,,50,oGet )
       ::oFam := ::Abrir( "cadfactm","empresa, numfac, tipo",,,30,oGet )
       ::oPag := ::Abrir( "cadpagos","empresa, numfac, tipo",.t.,,30,oGet )
       ::oHab := ::Abrir( "ciudades","codigo",,,100,oGet )
       ::oEpl := ::Abrir( "nomemple","codigo",.t.,,,oGet )
       ::oCon := ::Abrir( "nomconce","concepto",,,,oGet )
       ::oFie := ::Abrir( "nomfijoe",,,,,oGet )
       ::oFis := ::Abrir( "nomfijos","periodoi",,,,oGet )
       ::oFie:Seek( {"empresa",oApl:nEmpresa} )
    Else
       ::lSalir := .t.
    EndIf
 Else
    ::lSalir := .t.
 EndIf
If ::lSalir
   MsgInfo( "No hay conexion", "Se�or : "+ALLTRIM(::cUser) )
EndIf
RETURN NIL

//------------------------------------//
METHOD Abrir( cTabla,cOrderBy,lBlank,lTemp,nLimit,oGet ) CLASS TCao
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
         MsgInfo( "est� sin registros",cTabla )
      ElseIf nCon > 0 .AND. lTemp
         oTb:dbEval( {|o| o:Delete( .f.,1 ) } )
      EndIf
      If lBlank
         oTb:xBlank():Read()
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
METHOD FondoWnd() CLASS TCao
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
FUNCTION Salir()
If (MsgYesNo("Deseas salir del programa","Abandonar el sistema"),;
   (oApl:oMySql:End(), oApl:lSalir := .t., oApl:oWnd:End()),)
RETURN oApl:lSalir

//------------------------------------//
PROCEDURE Backup( cBaseD )
   LOCAL aMsg, cFile := ALLTRIM(cBaseD) + ".sql"
//If cBaseD == "A"
   aMsg := { "Voy a Sacar una Copia de Seguridad" ,;
             "Por favor digite la >>> Contrase�a <<<<" }
//Else
//   aMsg := { "Voy a Copiar de Diskettes al Disco Duro" ,;
//             "Por favor Inserte el Ultimo Diskette en la Unidad" }
//EndIf
If !MsgYesNo( aMsg[2],aMsg[1] )
   RETURN
EndIf
//WAITRUN('Copia.bat ' + cUnd + ' ' + cFile )
//Vuelco todos los datos de cache a disco, cierro y bloqueo todas las tablas
MSQuery( oApl:oMySql:hConnect,"FLUSH TABLES WITH READ LOCK" )
//WAITRUN( 'mysqldump -u root -p ' + cBaseD + ' > ' + cFile )
WAITRUN('BACKUP.bat ' + cBaseD + ' ' + cFile + ' ' + oApl:cRuta2 )
//Desbloqueo las tablas
MSQuery( oApl:oMySql:hConnect,"UNLOCK TABLES" )
MsgInfo( "OK!" )
//Para Restaurar
//mysql -u root -p base_de_datos < backup.sql
RETURN

//------------------------------------//
PROCEDURE CgeConst()
   LOCAL oDlg, oGet := ARRAY(9)
   LOCAL aEmp, aPrv := Privileg( "CONSTANTES" )
If !aPrv[2]
   MsgStop( "Usted no esta Autorizado para hacer CAMBIOS" )
   RETURN
EndIf
aEmp := { .f.,oApl:oEmp:NOMBRE }
DEFINE DIALOG oDlg RESOURCE "MemoEdit"
   REDEFINE GET oGet[1] VAR aEmp[2]              ID  1 OF oDlg PICTURE "@!";
      WHEN aPrv[1]
   REDEFINE GET oGet[2] VAR oApl:oEmp:NIT        ID  3 OF oDlg PICTURE "@!";
      WHEN aPrv[1]
   REDEFINE GET oGet[3] VAR oApl:oEmp:NUMFACU    ID  5 OF oDlg
   REDEFINE GET oGet[4] VAR oApl:oEmp:NUMINGRESO ID  7 OF oDlg
   REDEFINE GET oGet[5] VAR oApl:oEmp:PEDIDO     ID  9 OF oDlg
   REDEFINE GET oGet[6] VAR oApl:oEmp:DIAN       ID 11 OF oDlg PICTURE "@!"

   REDEFINE BUTTON oGet[8] ID 20 OF oDlg ACTION ;
      ( aEmp[1] := MsgYesNo( "Graba estos Datos" ), oDlg:End() )
   REDEFINE BUTTON oGet[9] ID 21 OF oDlg CANCEL ;
      ACTION oDlg:End()
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
If aEmp[1]
   oApl:oEmp:NOMBRE := ALLTRIM( aEmp[2] )
   oApl:cEmpresa    := STRTRAN( oApl:oEmp:NOMBRE,"�","\" )
   oApl:oEmp:Update( .t.,1 )
/*   cQry := "UPDATE cadempre SET Nombre = " + INF( aEmp[2],", Nit = " ) +;
           INF( oApl:oEmp:NIT       ,", Numfacu = " )   +;
           INF( oApl:oEmp:NUMFACU   ,", Numingreso = " )+;
           INF( oApl:oEmp:NUMINGRESO,", Pedido = " )    +;
           INF( oApl:oEmp:PEDIDO    ,", Dian = " )      +;
           INF( oApl:oEmp:DIAN      ,", Nota = " )      +;
           INF( oApl:oEmp:NOTA )  +  " WHERE Empresa = " + LTRIM(STR(oApl:nEmpresa))
   MSQuery( oApl:oMySql:hConnect,cQry )*/
EndIf
RETURN

//------------------------------------//
FUNCTION Login( cTit )
   LOCAL oDlg, lLogin := .f., nInten := 0
   LOCAL oGet := ARRAY(4), aLog := { oApl:cUser,SPACE(16) }
   DEFAULT cTit := ""
DEFINE DIALOG oDlg FROM 1, 2 TO 08, 40 TITLE cTit
   @ 02,  0 SAY "Usuario:"          OF oDlg RIGHT PIXEL SIZE  50,10
   @ 02, 52 GET oGet[1] VAR aLog[1] OF oDlg       PIXEL SIZE  46,10
   @ 16,  0 SAY "Clave:"            OF oDlg RIGHT PIXEL SIZE  50,10
   @ 16, 52 GET oGet[2] VAR aLog[2] OF oDlg       PIXEL SIZE  46,10 PASSWORD

   @ 32, 50 BUTTON oGet[3] PROMPT "&Ok"     OF oDlg SIZE 44,12 ACTION ;
      ( nInten++, lLogin := Leer_Clave( aLog ),;
       If( nInten > 3 .OR. lLogin, oDlg:End() ,;
         ( MsgInfo("Clave Erronea","Error")   ,;
           oGet[3]:oJump := oGet[1], oGet[1]:SetFocus())) ) PIXEL
   @ 32,100 BUTTON oGet[4] PROMPT "&Cancel" OF oDlg SIZE 44,12 CANCEL ;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN lLogin

//------------------------------------//
FUNCTION Leer_Clave( aUsu )
   LOCAL hRes, cQry //:= MyPasswd( oApl:oMySql:hConnect )
cQry := "SELECT Host FROM mysql.user WHERE User = " + xValToChar( aUsu[1] ) +;
        " AND Password = OLD_PASSWORD(" + xValToChar( aUsu[2] ) +")"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
RETURN ( MSNumRows( hRes ) != 0 )

//------------------------------------//
FUNCTION Encriptar( cNomH,lEncrita )
   LOCAL nC, nX, nLen, oTmp
   DEFAULT lEncrita := .t.
If cNomH == NIL
   //oApl:oEmp:ENLINEA := .t.
   //oApl:oEmp:PORPC   := .t.
   //oApl:oEmp:PREFIJO := "A"
   cNomH := "INSERT INTO cadempre (empresa, puc, regimen, localiz, titular, "+;
               "nit, nombre, reshabit, piva, lencod, cartera, pos, tipofac) "+;
             "VALUES( 1, 1, 1, 'MTL', 'MTL', '8.708.966-9', 'MARTIN TOLOZA LOZANO'"+;
                    ", '08001', 16, 10, '13050501', 'A', 'C,ABCX' )"
   MSQuery( oApl:oMySql:hConnect,cNomH )
   oApl:oEmp:Seek( {"empresa",1} )

   oTmp := oApl:Abrir( "cademprf",1,.f.,.t. )
   oTmp:Destroy()
   oTmp := oApl:Abrir( "caddevoc",1,.f.,.t. )
   oTmp:Destroy()
   oTmp := oApl:Abrir( "caddevod",1,.f.,.t. )
   oTmp:Destroy()
Else
   nLen := LEN( ALLTRIM( cNomH ) )
   FOR nX  := 1 TO nLen
      If lEncrita
         nC := ASC( SUBSTR( cNomH,nX,1 ) ) + 4 + nX * 25
      Else
         nC := ASC( SUBSTR( cNomH,nX,1 ) ) - 4 - nX * 25
      EndIf
      cNomH := STUFF( cNomH,nX,1,CHR( nC ) )
   NEXT nX
EndIf
RETURN cNomH

//----------------------------------------------//
FUNCTION MsgDate( dDate, cPrompt, oGet )
   LOCAL oDlg, oFont, oCursor, dSelect, dWork
   LOCAL nRow, nCol, nMonth, nYear, cCYear, cFechaLarga
   LOCAL aMes := { "Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio",;
                   "Agosto","Septiembre","Octubre","Noviembre","Diciembre"}
   DEFAULT dDate := Date(), cPrompt := "Selecione una Fecha"
dDate       := If( EMPTY(dDate), Date(), dDate )
cFechaLarga := dDateToString( dDate,aMes )
cCYear      := str(year(dDate), 4)
nYear       := Year( dDate )
nMonth      := Month( dDate )
dSelect     := dDate
dWork       := TToD( "01/" + padl( nMonth, 2 ) + "/" + ;
                      right( cCYear, 2), "DD/MM/YY" )
while DoW( dWork ) > 1
   dWork --
enddo

DEFINE FONT oFont NAME "Ms Sans Serif" SIZE 0, -14
DEFINE DIALOG oDlg SIZE 250, 235 TITLE cPrompt FONT oFont // -> 6 Semanas

   @ 0.2, .75 COMBOBOX  nMonth  ITEMS  aMes SIZE 50,150  OF  oDlg ;
              ON CHANGE MoveCalendar( oDlg,1,nMonth,aMes )
   @ 3.5, 63 BTNBMP PROMPT "-" SIZE 11,11 ACTION ( MoveCalendar(oDlg,3,,aMes ))
   @ 3.5,105 BTNBMP PROMPT "+" SIZE 11,11 ACTION ( MoveCalendar(oDlg,4,,aMes ))

   @ 0.2, 9.3 GET  nYear  SIZE 31, 12 OF oDlg
   ATail( oDlg:aControls ):Cargo = "YEAR"
     // Atail -> Devuelve el �ltimo elemento de una Matriz
   @ 1.1, (35  - LEN( cFechaLarga )) / 4.8  SAY cFechaLarga COLOR CLR_HBLUE
   ATail( oDlg:aControls ):Cargo = "DATE"

   @ 2, 1 SAY "Dom   Lun   Mar   Mie   Jue    Vie   Sab" COLOR CLR_HRED

   FOR nRow = 2 TO 7
      FOR nCol = 1 TO 7
         @ (nRow * 10) + 20, ( nCol * 16 ) - 6 BTNBMP ;
             PROMPT STR( DAY( dWork ), 2 ) SIZE 12, 12 NOBORDER ;
             ACTION ( oDlg:Cargo := ::Cargo, oDlg:End( IDOK ) )

         ATail( oDlg:aControls ):Cargo    = dWork
         ATail( oDlg:aControls ):nClrText = If( dWork == Date(), CLR_HRED,;
                If( dWork == dDate, CLR_HBLUE, If( Month( dWork ) == nMonth,;
                CLR_BLACK, CLR_GRAY ) ) )
         If ATail( oDlg:aControls ):Cargo == dDate
            ATail( oDlg:aControls ):lPressed = .t.
            ATail( oDlg:aControls ):cToolTip = "Seleccionado"
         ElseIf ATail( oDlg:aControls ):Cargo == Date()
            ATail( oDlg:aControls ):cToolTip = "Hoy"
         Else
            ATail( oDlg:aControls ):cToolTip = DToC(ATail( oDlg:aControls ):Cargo)
         EndIf

         dWork++
      NEXT
   NEXT
   oDlg:Cargo := dDate

ACTIVATE DIALOG oDlg CENTERED

dSelect := oDlg:Cargo
If oGet != NIL
   oGet:VarPut( If( oDlg:nResult == IDOK, dSelect, dDate ) )
   oGet:Refresh()
EndIf

RETURN If( oDlg:nResult == IDOK, dSelect, dDate )

//----------------------------------------------//
STATIC FUNCTION MoveCalendar( oDlg, nMode, nVar, aMes )
   LOCAL cFechaLarga, dWork, nDay, nMonth, nYear, n
   LOCAL dSelect      := oDlg:Cargo
   LOCAL nFirstButton := 0, nLastButton := 0
   LOCAL nDays  := 0
   LOCAL nDate  := 0
   LOCAL nSkip  := 0
   LOCAL nPDate := 0
   LOCAL nPYear := 0
FOR n := 1 TO Len( oDlg:aControls )
   If oDlg:aControls[ n ]:ClassName() == "TBTNBMP"
      nFirstButton := If( nFirstButton == 0, If(nSkip<2, 0, n), nFirstButton )
      nLastButton  := n
      nSkip++
      oDlg:aControls[ n ]:lPressed := .f.
   EndIf
   If ValType( oDlg:aControls[ n ]:Cargo ) == "C"
      If oDlg:aControls[ n ]:Cargo == "DATE"
         nPDate    := n
      EndIf
      If oDlg:aControls[ n ]:Cargo == "YEAR"
         nPYear    := n
      EndIf
   EndIf
NEXT n

nDay   := Day( dSelect )
nMonth := Month( dSelect )
nYear  := Year( dSelect )

do case
   case nMode == 1
      nMonth := nVar
   case nMode == 3
      nYear --
   case nMode == 4
      nYear ++
endcase
If LEFT(NtChr( dSelect,"4" ),2) == STR(nDay,2)
   nDay := DAY(CTOD(NtChr( CTOD("01."+STRZERO(nMonth,2)+STR(nYear)),"4" )))
EndIf
dSelect     := TToD( padl( nDay, 2) + "/" + ;
                     padl( nMonth, 2 ) + "/" + ;
                     right(padl( nYear, 4 ), 2), "DD/MM/YY" )
cFechaLarga := dDateToString( dSelect,aMes )
oDlg:aControls[ nPDate ]:cMsg := cFechaLarga
oDlg:aControls[ nPYear ]:VarPut( nYear)

dWork    := TToD( "01/" + padl( nMonth, 2 ) + "/" + right(padl( nYear, 4 ), 2), "DD/MM/YY" )
while DoW( dWork ) > 1
   dWork --
enddo

FOR n := nFirstButton TO nLastButton
   oDlg:aControls[ n ]:SetText( Str( Day( dWork ), 2 ) )
   oDlg:aControls[ n ]:Cargo   = dWork
   oDlg:aControls[ n ]:nClrText = If( dWork == Date(), CLR_HRED,;
        If( dWork == dSelect, CLR_HBLUE, If( Month( dWork ) == nMonth,;
            CLR_BLACK, CLR_GRAY ) ) )
   oDlg:aControls[ n ]:cToolTip = DToC(dWork)
   If dWork == dSelect
      oDlg:aControls[ n ]:lPressed = .t.
      oDlg:aControls[ n ]:cToolTip = "Seleccionado"
   EndIf
   dWork++
NEXT n

FOR n := 1 TO Len( oDlg:aControls )
   oDlg:aControls[ n ]:Refresh()
NEXT n
oDlg:Cargo   := dSelect
return nil

//----------------------------------------------//
STATIC FUNCTION dDateToString( dDate,aMes )
   Local aDia := { "Domingo ","Lunes ","Martes ","Miercoles ","Jueves ",;
                   "Viernes ","Sabado " }
RETURN aDia[Dow( dDate )] + aMes[Month( dDate )] + Str( Day( dDate ),3 ) +;
       ", " + Str( Year( dDate), 4)

//----------------------------------------------//
STATIC FUNCTION TToD(cDate, cFormat)
  LOCAL cDia, cMes, cYear, cLYear
  LOCAL RetDate
  LOCAL cClipFormat := UPPER(SET(4))
  LOCAL nEPOCH      := SET(5)

IF VALTYPE(cFormat) != "C"
   cFormat  := "MM/DD/YY"
ENDIF
IF EMPTY(cDate)
   RetDate := CTOD("")
ELSE
   IF ("YYYY" $ cFormat)
      cLYear :=  PADR( VAL( SUBSTR(cDate, AT("YYYY", cFormat), 4 )), 4, "0")
      cYear  :=  PADL( VAL( RIGHT(cLYear, 2)), 2, "0")
   ELSEIF ("YY" $ cFormat)
      cYear  :=  PADL( VAL( SUBSTR(cDate, AT("YY", cFormat), 2 )), 2, "0")
      IF VAL("19" + cYear) > nEPOCH
         cLYear := "19" + cYear
      ELSE
         cLYear := "20" + cYear
      ENDIF
   ENDIF
   IF ("MM" $ cFormat)
      cMes  :=  PADL( ALLTRIM( SUBSTR(cDate, AT("MM", cFormat), 2 )), 2, "0")
   ENDIF
   IF ("DD" $ cFormat)
      cDia  :=  PADL( ALLTRIM( SUBSTR(cDate, AT("DD", cFormat), 2 )), 2, "0")
   ENDIF

   IF ("YYYY" $ cClipFormat)
      cClipFormat := LEFT(cClipFormat, AT("YYYY", cClipFormat) - 1 ) + cLYear + SUBSTR(cClipFormat, AT("YYYY", cClipFormat) + 4 )
   ELSEIF ("YY" $ cClipFormat)
       cClipFormat := LEFT(cClipFormat, AT("YY", cClipFormat) - 1 ) + cYear + SUBSTR(cClipFormat, AT("YY", cClipFormat) + 2 )
   ENDIF
   IF ("MM" $ cClipFormat)
      cClipFormat := LEFT(cClipFormat, AT("MM", cClipFormat) - 1 ) + cMes + SUBSTR(cClipFormat, AT("MM", cClipFormat) + 2 )
   ENDIF
   IF ("DD" $ cClipFormat)
      cClipFormat := LEFT(cClipFormat, AT("DD", cClipFormat) - 1 ) + cDia + SUBSTR(cClipFormat, AT("DD", cClipFormat) + 2 )
   ENDIF
   RetDate := CTOD(cClipFormat)
ENDIF
RETURN (RetDate)