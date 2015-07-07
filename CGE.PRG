/* Programa............................ CGE
*    Sistema De Contabilidad General
*  Fecha de escritura...................14/02/2006
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

oApl := TCge()
oApl:New()

DEFINE ICON  oIco RESOURCE "RECIBOS"
DEFINE BRUSH oBru FILE oApl:FondoWnd()

// Definir Ventana Principal
DEFINE WINDOW oApl:oWnd FROM 1,1 TO 400,600 PIXEL  ;
   TITLE oApl:cEmpresa +                           ;
    " [ Sistema de Contabilidad General ver 2.1 ]" ;
   BRUSH oBru                                      ;
   MENU Creamenu( "menucge" )                      ;
   MDI ICON oIco                                   ;
   COLOR CLR_BLUE,RGB(0,128,192)
   SET MESSAGE OF oApl:oWnd TO "Tolozano. Telf: 3649075  Celular: 300-8045043";
       TIME DATE KEYBOARD
   DEFINE BUTTONBAR OF oApl:oWnd 3DLOOK SIZE 40,40
      DEFINE BUTTON RESOURCE "ARTICULOS" OF oApl:oWnd:oBar NOBORDER ;
         TOOLTIP "Comprobantes de Diario"                   ;
         ACTION MovimientoCge( 0 )
      DEFINE BUTTON RESOURCE "ARCHIVAR"  OF oApl:oWnd:oBar NOBORDER ;
         TOOLTIP "Crear, Anular e Imprimir Facturas(Ctrl+F)";
         ACTION CgeFactu()
      DEFINE BUTTON RESOURCE "PROVEEDOR" OF oApl:oWnd:oBar NOBORDER ;
         TOOLTIP "Plan Unico de Cuentas"                    ;
         ACTION PlanCtas() GROUP
      DEFINE BUTTON RESOURCE "CLIENTE"   OF oApl:oWnd:oBar NOBORDER ;
         TOOLTIP "Clientes"                                 ;
         ACTION Nits()
      DEFINE BUTTON RESOURCE "SECURITY"  OF oApl:oWnd:oBar NOBORDER ;
         TOOLTIP "Comprobantes de Ingresos"                 ;
         ACTION MovimientoCge( 1 )                          ;
         GROUP
//         ACTION CgeIngre()                                  ;
      DEFINE BUTTON RESOURCE "MONEY"     OF oApl:oWnd:oBar NOBORDER ;
         TOOLTIP "Comprobantes de Egresos"                  ;
         ACTION MovimientoCge( 2 )
      DEFINE BUTTON  RESOURCE "REINDEZAR" OF oApl:oWnd:oBar NOBORDER;
         TOOLTIP "Actualiza ó Reversa los Movimiento"       ;
         ACTION CgeActua()
      DEFINE BUTTON OF oApl:oWnd:oBar NOBORDER ;
         ACTION Liquida()                  ;
         FILENAME oApl:cIco+"Favorite.bmp" ;
         MESSAGE "Liquidación de la Nomina";
         TOOLTIP "Liquidación de la Nomina"
      DEFINE BUTTON RESOURCE "Salir" ADJUST OF oApl:oWnd:oBar NOBORDER;
         TOOLTIP "Cerrar la aplicación";
         ACTION Salir()
ACTIVATE WINDOW oApl:oWnd MAXIMIZED             ;
   ON INIT (If( oApl:lSalir, oApl:oWnd:End(), ));
   VALID If( oApl:lSalir, .t., Salir() )
RETURN NIL

//------------------------------------//
FUNCTION Salir()
If (MsgYesNo("Deseas salir del programa","Abandonar el sistema"),;
   (oApl:oMySql:End(), oApl:lSalir := .t., oApl:oWnd:End()),)
RETURN oApl:lSalir

//------------------------------------//
CLASS TCge

   DATA aWHija AS ARRAY INIT { NIL }
   DATA aInvme AS ARRAY INIT { 0,0 }
   DATA aOptic, aInf
   DATA cEmpresa INIT "Martin Toloza Lozano"
   DATA dFec     INIT DATE()
   DATA lSalir   INIT .F.
   DATA Tipo     INIT "U"
   DATA cCiu, cPer, cRuta1, cRuta2, cImpres, cPuerto, nTHoja, nLF, nTFor
   DATA cIco, cIP, cTF, cUser, cBaseD, nPort, cSocket
   DATA lEnLinea, lFam, lOffice, nEmpresa, nPuc, nSaldo
   DATA nClrBackHead, nClrForeHead, nClrBack, nClrFore
   DATA nClrBackFocus, nClrForeFocus, nClrNBack, nClrNFore, nGotFocus, nLostFocus
   DATA oMysql, oDb, oWnd
   DATA oEmp, oNit, oPuc, oFac, oFam, oPag
   DATA oCon, oEpl, oFie, oFis, oHab
//   DATA oVar, oCtl, oMvc, oMvd, oAuc, oAun
//   DATA oTra

   METHOD NEW() Constructor
   METHOD Conectar( cPassw,oGet )
   METHOD Abrir( cTabla,cOrderBy,lBlank,lTemp,nLimit,oGet )
   METHOD FondoWnd()
   //METHOD Guardar( oTB,lInsert,lRefresh )
ENDCLASS

//------------------------------------//
METHOD New() CLASS TCge
   LOCAL oIni, cFecha, aC := ARRAY(30), nP := 0
   LOCAL oDlg, oGet[10], cPassw := SPACE(16)
INI oIni FILE ".\Cge.ini"
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
   GET ::nLF     SECTION "Impresora" ENTRY "LFactura" OF oIni;
       DEFAULT 11
   GET ::nTFor   SECTION "Impresora" ENTRY "Formato"  OF oIni;
       DEFAULT 1
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
// ON INIT (oDlg:PostMsg( WM_KEYDOWN, 13, 0 ), oDlg:PostMsg( WM_KEYDOWN, 13, 0 ))
If !::lSalir
   cFecha := If( RIGHT( AmPm(TIME()),2 ) == "am", "BUENOS DIAS",;
                 "BUENAS TARDES" ) + "   >> HOY ES <<"  + CRLF +;
        NtChr( DATE(),"5" ) + " " + NtChr( DATE(),"2" ) + CRLF +;
              "Y SON LAS " + AmPm(TIME())
   If !MsgYesNo( cFecha,::cUser )
      ::lSalir := .t.
      RETURN NIL
   EndIf
/* If oApl:dFec >= CTOD("30.06.2006") + ::oEmp:DIAS
      MsgStop( "ESTO ERA UN PROGRAMA DE DEMOSTRACION" + CRLF +;
               "POR FAVOR CONTACTE A SU PROPIETARIO " + CRLF +;
               "PARA OBTENER LA LICENCIA............" )
      ::lSalir := .t.
   EndIf
   If DATE() < ::oEmp:FEC_HOY .AND. oApl:lEnLinea
      MsgStop( "Fecha del Sistema menor que la Ultima Facturación",">> ERROR <<" )
      ::lSalir := .t.
   EndIf*/
   ::lOffice := FILE( "OPENOFICE.BAT" )
EndIf

RETURN NIL

//--------Conectarse con MySQL--------//
METHOD Conectar( cPassw,oGet ) CLASS TCge
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
          AADD( ::aOptic, { ::oEmp:LOCALIZ,STR(::oEmp:EMPRESA,2) } )
          ::oEmp:Skip(1):Read()
       EndDo
       ::oEmp:Seek( {"localiz",cPassw} )
       nEmpresa( .f. )
       ::oNit := ::Abrir( "cadclien",,,,,oGet )
       ::oHab := ::Abrir( "ciudades","codigo",,,100,oGet )
       If ::oEmp:NOMINA
          ::oEpl := ::Abrir( "nomemple","codigo",.t.,,,oGet )
          ::oCon := ::Abrir( "nomconce","concepto",,,,oGet )
          ::oFie := ::Abrir( "nomfijoe",,,,,oGet )
          ::oFis := ::Abrir( "nomfijos","periodoi",,,,oGet )
          ::oFac := ::Abrir( "cgefactc","empresa, numfac, tipo",,,50,oGet )
          ::oFam := ::Abrir( "cgefactm","empresa, numfac, tipo",,,30,oGet )
          ::oFie:Seek( {"empresa",oApl:nEmpresa} )
       EndIf
//       ::oPuc := ::Abrir( "cgeplan","empresa, cuenta",,,100,oGet )
//       ::oCtl := ::Abrir( "cgecntrl","empresa, ano_mes",,,5,oGet )
//       ::oFte := ::Abrir( "cgefntes","fuente",,,5,oGet )
//       ::oVar := ::Abrir( "cgevaria","empresa, cuenta",,,5,oGet )
//       ::oAuc := ::Abrir( "cgeacumc","empresa, ano_mes",,,5,oGet )
//       ::oAun := ::Abrir( "cgeacumn","empresa, ano_mes",,,5,oGet )
//       ::oMvc := ::Abrir( "cgemovc" ,"empresa, ano_mes, control",.t.,,10,oGet )
//       ::oMvd := ::Abrir( "cgemovd" ,"empresa, ano_mes, control",.t.,,100,oGet )
//       ::oPag := ::Abrir( "cadpagos","empresa, numfac, tipo",,,30,oGet )
//       ::oTra := ::Abrir( "ridocupa","codigo",,,100,oGet )
    Else
       ::lSalir := .t.
    EndIf
 Else
    ::lSalir := .t.
 EndIf
If ::lSalir
   MsgInfo( "No hay conexion", "Señor : "+ALLTRIM(::cUser) )
EndIf
RETURN NIL

//------------------------------------//
METHOD Abrir( cTabla,cOrderBy,lBlank,lTemp,nLimit,oGet ) CLASS TCge
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
   If !(lSi := oTb:Open())
      If ::oMySql:GetErrNo() == 1030
         If ::oDb:Repair( cTabla )
            MsgInfo( "la Tabla "+cTabla,"Se Reparo" )
            lSi := oTb:Open()
         Else
            MsgInfo( "la Tabla "+cTabla,"No se Pudo Reparar" )
         EndIf
      EndIf
   EndIf
   If lSi
      nCon := oTb:RecCount()
      If nCon == 0 .AND. !lTemp
         MsgInfo( "está sin registros",cTabla )
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
METHOD FondoWnd() CLASS TCge
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
PROCEDURE Constantes()
   LOCAL oDlg, oGet := ARRAY(09), cNombre, lOk := .f.
   LOCAL aPrv := Privileg( "CONSTANTES" )
If !aPrv[2]
   MsgStop( "Usted no esta Autorizado para hacer CAMBIOS" )
   RETURN
EndIf
cNombre := oApl:oEmp:NOMBRE
DEFINE DIALOG oDlg TITLE "CONSTANTES EMPRESA" FROM 0, 0 TO 18,70
   @  02, 00 SAY "NOMBRE DE LA EMPRESA" OF oDlg RIGHT PIXEL SIZE 100,10
   @  02,102 GET oGet[1] VAR cNombre OF oDlg PICTURE "@!" SIZE 140,12 PIXEL;
      WHEN aPrv[1]
   @  16, 00 SAY    "NIT DE LA EMPRESA" OF oDlg RIGHT PIXEL SIZE 100,10
   @  16,102 GET oGet[2] VAR oApl:oEmp:NIT OF oDlg PICTURE "@!" SIZE 68,12 PIXEL;
      WHEN aPrv[1]
   @  30, 00 SAY "DIRECCION"     OF oDlg RIGHT PIXEL SIZE 100,10
   @  30,102 GET oGet[3] VAR oApl:oEmp:DIRECCION  OF oDlg PICTURE "@!" SIZE 124,12 PIXEL
   @  44, 00 SAY "# INGRESO"     OF oDlg RIGHT PIXEL SIZE 100,10
   @  44,102 GET oGet[4] VAR oApl:oEmp:INGRESO    OF oDlg SIZE 50,12 PIXEL
   @  58, 00 SAY "# EGRESO"      OF oDlg RIGHT PIXEL SIZE 100,10
   @  58,102 GET oGet[5] VAR oApl:oEmp:EGRESO    OF oDlg SIZE 50,12 PIXEL
   @  72, 00 SAY   "GERENTE" OF oDlg RIGHT PIXEL SIZE 100,10
   @  72,102 GET oGet[6] VAR oApl:oEmp:GERENTE   OF oDlg PICTURE "@!" SIZE 124,12 PIXEL
   @  86, 00 SAY  "CONTADOR" OF oDlg RIGHT PIXEL SIZE 100,10
   @  86,102 GET oGet[7] VAR oApl:oEmp:CONTADOR  OF oDlg PICTURE "@!" SIZE 124,12 PIXEL
   @ 102,100 BUTTON oGet[08] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( lOk := MsgYesNo( "Graba estos Datos" ), oDlg:End() ) PIXEL
   @ 102,150 BUTTON oGet[09] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
If lOk
   oApl:oEmp:NOMBRE := oApl:cEmpresa := ALLTRIM( cNombre )
// oApl:oEmp:NOMBRE := Encriptar( cNombre )
   oApl:oEmp:Update( .t.,1 )
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
cQry := "SELECT host FROM mysql.user WHERE user = " + xValToChar( aUsu[1] ) +;
        " AND password = OLD_PASSWORD(" + xValToChar( aUsu[2] ) +")"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
RETURN ( MSNumRows( hRes ) != 0 )

//------------------------------------//
FUNCTION Encriptar( cNomH,lEncrita )
   LOCAL nC, nX, nLen := LEN( ALLTRIM( cNomH ) )
DEFAULT lEncrita := .t.
FOR nX  := 1 TO nLen
   If lEncrita
      nC := ASC( SUBSTR( cNomH,nX,1 ) ) + 4 + nX * 25
   Else
      nC := ASC( SUBSTR( cNomH,nX,1 ) ) - 4 - nX * 25
   EndIf
   cNomH := STUFF( cNomH,nX,1,CHR( nC ) )
Next
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
     // Atail -> Devuelve el último elemento de una Matriz
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