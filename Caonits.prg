// Programa.: CAONITS.PRG     >>> Martin A. Toloza Lozano <<<
// Notas....: Modulo para la manipulacion de Nits
#include "Fivewin.ch"
#include "TSBrowse.ch"
#include "btnget.ch"

MEMVAR oApl

#define CLR_PINK  nRGB( 128, 150, 150)
#define CLR_NBLUE nRGB( 255, 255, 235)

FUNCTION Nits()
   LOCAL oNits := TNits()
oNits:New(,.f.)
oNits:Activate()
RETURN NIL
/*
     VALID EVAL( {|| If( oAr:oNi:Buscar( oF:aM[3],,.t. )              ,;

RENAME TABLE cadclien TO cadclienv;

CREATE TABLE `cadclien` (
  `codigo_nit` int(11) NOT NULL AUTO_INCREMENT,
  `tipocod` int(1) DEFAULT NULL,
  `codigo` bigint(12) DEFAULT NULL,
  `digito` int(1) DEFAULT NULL,
  `pri_ape` varchar(20) DEFAULT NULL,
  `seg_ape` varchar(20) DEFAULT NULL,
  `pri_nom` varchar(20) DEFAULT NULL,
  `seg_nom` varchar(20) DEFAULT NULL,
  `nombre` varchar(50) DEFAULT NULL,
  `direccion` varchar(40) DEFAULT NULL,
  `email` varchar(40) DEFAULT NULL,
  `codigo_ciu` varchar(5) DEFAULT NULL,
  `codpais` varchar(3) DEFAULT '169',
  `natura` char(1) DEFAULT NULL,
  `actecon` int(4) DEFAULT NULL,
  `doc_ext` varchar(16) DEFAULT NULL,
  `toperet` tinyint(1) NOT NULL DEFAULT '0',
  `retenedor` tinyint(1) NOT NULL DEFAULT '0',
  `grancontr` tinyint(1) NOT NULL DEFAULT '0',
  `pica` double(6,2) DEFAULT '0.00',
  `piva` double(6,2) DEFAULT '0.00',
  `pcree` double(6,2) DEFAULT '0.30',
  PRIMARY KEY (`codigo_nit`),
  KEY `FKIndex1` (`nombre`),
  KEY `FKIndex2` (`codigo`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

UPDATE cadclienv SET tipocod = 1
WHERE codigo > 8000000000
  AND codigo < 9999999999;

INSERT INTO cadclien
(codigo_nit, tipocod, codigo, digito, pri_ape, seg_ape, pri_nom, seg_nom, nombre,
 direccion, email, codigo_ciu, toperet, retenedor, grancontr, pica, piva, pcree)
SELECT n.codigo_nit, n.tipocod, n.codigo, n.digito,
       If( n.tipocod = 2, SUBSTR(n.nombre,1, n.pa), '' ),
       If( n.tipocod = 2, SUBSTR(n.nombre,n.pa+2,n.sa), '' ),
       If( n.tipocod = 2, SUBSTR(n.nombre,n.pa+If(n.sa = 0,2,n.sa+3),n.pn), '' ),
       If( n.tipocod = 2, SUBSTR(n.nombre,n.pa+If(n.sa = 0,3,n.sa+4)+n.pn,n.sn), '' ),
       n.nombre, n.direccion, n.email, n.codigo_ciu, n.toperet,
       n.retenedor, n.grancontr, n.pica, n.piva, n.pcree
FROM cadclienv n

UPDATE cadclien SET natura = 'J'
WHERE codigo >= 800000000
  AND codigo <= 999999999

SELECT codigo, pri_ape, seg_ape, pri_nom, seg_nom, nombre
FROM cadclien
WHERE tipocod = 2

*/

//------------------------------------//
CLASS TNits

 DATA cBus          INIT ""
 DATA cWhere        INIT ""
 DATA lBuscar       INIT .f.
 DATA nOrden        INIT 2
 DATA xVar          INIT 0
 DATA oFont         INIT Tfont():New("Ms Sans Serif",0,-10,,.f.)
 DATA aOrden, aNatu, aOld, aV, oDb, oCiu, oIndex, oLbx
 DATA bNew, bEditar, bVer
 DATA bBorrar, bBuscar, bPrint, lBorrar

 METHOD NEW( oTabla,lDel ) Constructor
 METHOD ACTIVATE() INLINE ::Mostrar( .f.,2 )
 METHOD Cerrar()   INLINE ::oDb:Destroy()
 METHOD Guardar( lNew )
 METHOD Editar( xRec,lNuevo,lView,nNit )
 METHOD Mostrar( lAyuda,nOrd,nCod )
 METHOD Ordenar( nOrd )
 METHOD Barra( lHelp,oDlg )
 METHOD Borrar( xRec )
 METHOD Buscar( uBus,cCampo,lTB,lNew )
 METHOD Buscando( cWhere )
 METHOD BuscaInc( nKey,cWhere )
 METHOD ChangeOrder()
 METHOD Cambios( sMsj,nBtn,oGet,lNew )
 METHOD Listado()
ENDCLASS

//------------------------------------//
METHOD NEW( oTabla,lDel ) CLASS TNits
   DEFAULT oTabla := oApl:oNit, lDel := .t.
::aOrden  := { {"<None> "  ,1},{"Código"   ,3},;
               {"Nombre"   ,9},{"CódigoNit",1} }
::aNatu   := ArrayCombo( "NATURALEZA" )
::oDb     := oTabla
::bNew    := {||::Editar( ::oDb:Recno(),.t. ),    ;
                ::oLbx:SetFocus(),::oLbx:Refresh()  }
::bEditar := {||::Editar( ::oDb:Recno(),.f. ),    ;
                ::oLbx:SetFocus(),::oLbx:Refresh()  }
::bVer    := {||::Editar( ::oDb:Recno(),.f.,.t. ),;
                ::oLbx:SetFocus(),::oLbx:Refresh()  }
::bBorrar := {||::Borrar( ::oDb:Recno() ),        ;
                ::oLbx:SetFocus(),::oLbx:Refresh()  }
::bBuscar := {|| ::cBus := If( EMPTY( ::cBus ), ::Buscando(), "" ),;
                 ::oLbx:SetFocus(),::oLbx:Refresh() }
::bPrint  := {|| ::Listado() }
::lBorrar := lDel
If ::oDb:cName == "cadclien"
   ::oCiu := TRip()
   ::oCiu:New( 1,.f. )
EndIf
RETURN NIL

//------------------------------------//
METHOD Mostrar( lAyuda,nOrd,nCod ) CLASS TNits
   LOCAL oDlg, oM := Self
   LOCAL cTit := "Ayuda de Nits", bHacer, lReturn := NIL
DEFAULT lAyuda := .t. , nOrd := 3, nCod := 0
If lAyuda
   bHacer  := {||lReturn := ::lBuscar := .t., oDlg:End()}
   lReturn := .f.
ELSE
   bHacer  := ::bEditar
   cTit    := "Clientes o Proveedores"
ENDIF
::xVar := nCod
nOrd   := ::Ordenar( nOrd )
If ::oDb:cName == "cadclien" .AND. nCod > 0
   ::oDb:Seek( {"codigo",nCod} )
EndIf

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE cTit
   @ 1.5, 0 LISTBOX ::oLbx FIELDS   ;
         TRANSFORM( ::oDb:CODIGO,"999,999,999,999"),;
         OEMTOANSI( ::oDb:NOMBRE ),;
                    ::oDb:EMAIL    ;
      HEADERS "Nit ó"+CRLF+"Cédula","Nombre","Email" ;
      SIZES 400, 450 SIZE 200,107  ;
      OF oDlg UPDATE               ;
      ON DBLCLICK EVAL(bHacer)
    ::oLbx:nClrBackHead  := oApl:nClrBackHead
    ::oLbx:nClrForeHead  := oApl:nClrForeHead
    ::oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    ::oLbx:nClrBackFocus := oApl:nClrBackFocus
    ::oLbx:nClrForeFocus := oApl:nClrForeFocus
    ::oLbx:GoTop()
    ::oLbx:oFont      := ::oFont
    ::oLbx:nHeaderHeight := 28
    ::oLbx:aColSizes   := {80,240,110}
    ::oLbx:aHjustify   := {2,2,2}
    ::oLbx:aJustify    := {1,0,0}
    ::oLbx:ladjbrowse  := ::oLbx:lCellStyle  := .f.
    ::oLbx:ladjlastcol := .t.
    ::oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey=VK_RETURN, (EVAL(bHacer)),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(::bNew),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=69, EVAL(::bEditar)		 ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=86, EVAL(::bVer) 		         ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, EVAL(::bBorrar)	         ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) ))))) }
   MySetBrowse( ::oLbx, ::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
//        UPPER(SUBSTR(::cBus,1,1))+LOWER(SUBSTR(::cBus,2,LEN(::cBus)-1) );
ACTIVATE DIALOG oDlg CENTER ON INIT (oM:Barra(lAyuda,oDlg))

::oDb:Setorder(nOrd)

RETURN lReturn

//------------------------------------//
METHOD Ordenar( nOrd ) CLASS TNits

::cBus   := ""
::nOrden := nOrd
nOrd     := ::oDb:Setorder( ::aOrden[ ::nOrden,2 ] )
If ::oDb:RecCount() > 0
   ::oDb:GoTop():Read()  // Hacer siempre un Read() para cargar el buffer interno
   ::oDb:xLoad()
Else
   ::oDb:xBlank():Read()
EndIf

RETURN nOrd

//------------------------------------//
METHOD Editar(xRec,lNuevo,lView,nNit) CLASS TNits
   LOCAL oDlg, oLbd, oGet := ARRAY(25), oE := Self
   LOCAL aEd := { "Nuevo Nit",.f.,1,0 }
DEFAULT lNuevo := .t. , lView := .f. ,;
        xRec   :=  0  , nNit  := ::xVar
If lNuevo
   ::oDb:xBlank()
   ::oDb:TIPOCOD    := 2
   ::oDb:CODIGO     := nNit
   ::oDb:CODIGO_CIU := oApl:oEmp:RESHABIT
   ::oDb:CODPAIS    := "169"
Else
   aEd[1] := IF( lView, "Viendo Nit", "Modificando Nit" )
   nNit   := ::oDb:CODIGO
EndIf
::aOld := ACLONE( ::oDb:axBuffer )
::aV   := Telefono( .f.,::oDb:CODIGO_NIT,{} )
::oCiu:oDb:Seek( { "codigo",::oDb:CODIGO_CIU } )
aEd[3] := ArrayValor( ::aNatu,::oDb:NATURA ,{|xV|::oDb:NATURA  := xV},.t. )
aEd[4] := {|| DigitoVerifica( ::oDb ), oDlg:Update()            ,;
              xRec := ::Buscar( ::oDb:CODIGO )                  ,;
              If( (xRec .AND.  lNuevo) .OR.                      ;
                  (xRec .AND. !lNuevo .AND. ::oDb:CODIGO # nNit),;
                ( MsgNoYes("Nit ó Cédula ya existe") ), .t. ) }
DEFINE DIALOG oDlg TITLE aEd[1] FROM 0, 0 TO 366,570 PIXEL
   @  04, 00 SAY "Tipo de NIT" OF oDlg RIGHT PIXEL SIZE 48,10
   @  04, 50 COMBOBOX oGet[1] VAR ::oDb:TIPOCOD PROMPTS {"Nit","Cédula","Exterior"};
      SIZE 50,99 OF oDlg ;
      VALID ( If( lNuevo .AND. ::oDb:TIPOCOD == 3,;
                ( ::oDb:CODIGO := SgteNumero( "exterior",1,.f. ),;
                  oGet[3]:Refresh(), .t. ), .t. ) ) PIXEL
   //   WHEN lNuevo
   @  04,142 SAY "Código Nit" OF oDlg RIGHT PIXEL SIZE 48,10
   @  04,192 SAY oGet[2] VAR ::oDb:CODIGO_NIT OF oDlg ;
      PICTURE "99,999" SIZE 30,10 PIXEL
   @  16, 00 SAY "Cédula / Nit" OF oDlg RIGHT PIXEL SIZE 48,10
   @  16, 50 GET oGet[3] VAR ::oDb:CODIGO OF oDlg ;
      PICTURE "999,999,999,999"                   ;
      VALID EVAL( aEd[4] ) SIZE 50,10 PIXEL
   @  16,102 SAY "DV"         OF oDlg RIGHT PIXEL SIZE 12,10
   @  16,116 GET oGet[4] VAR ::oDb:DIGITO OF oDlg ;
      PICTURE "9" SIZE 10,10 PIXEL UPDATE
   @  16,140 SAY "Doc. Extranjeria" OF oDlg RIGHT PIXEL SIZE 50,10
   @  16,192 GET oGet[05] VAR ::oDb:DOC_EXT OF oDlg PICTURE "@!";
      WHEN ::oDb:TIPOCOD == 3 SIZE 80,10 PIXEL
   @  28, 00 SAY "Primer Apellido"  OF oDlg RIGHT PIXEL SIZE 48,10
   @  28, 50 GET oGet[06] VAR ::oDb:PRI_APE OF oDlg PICTURE "@!";
      VALID ::Cambios( "1er.Apellido",5,oGet[10],.f. );
      WHEN ::oDb:TIPOCOD == 2 SIZE 90,10 PIXEL
   @  28,140 SAY "Segundo Apellido" OF oDlg RIGHT PIXEL SIZE 50,10
   @  28,192 GET oGet[07] VAR ::oDb:SEG_APE OF oDlg PICTURE "@!";
      VALID ::Cambios( "",6,oGet[10],.f. );
      WHEN ::oDb:TIPOCOD == 2 SIZE 80,10 PIXEL
   @  42, 00 SAY "Primer Nombre"    OF oDlg RIGHT PIXEL SIZE 48,10
   @  42, 50 GET oGet[08] VAR ::oDb:PRI_NOM OF oDlg PICTURE "@!";
      VALID ::Cambios( "1er.Nombre",7,oGet[10],.f. );
      WHEN ::oDb:TIPOCOD == 2 SIZE 90,10 PIXEL
   @  42,140 SAY "Segundo Nombre"   OF oDlg RIGHT PIXEL SIZE 50,10
   @  42,192 GET oGet[09] VAR ::oDb:SEG_NOM OF oDlg PICTURE "@!";
      VALID ::Cambios( "",8,oGet[10],lNuevo );
      WHEN ::oDb:TIPOCOD == 2 SIZE 80,10 PIXEL
   @  54, 00 SAY "Razon Social"     OF oDlg RIGHT PIXEL SIZE 48,10
   @  54, 50 GET oGet[10] VAR ::oDb:NOMBRE OF oDlg PICTURE "@!";
      VALID ::Cambios( "Razon Social",9,oGet[10],lNuevo );
      WHEN ::oDb:TIPOCOD <> 2 SIZE 154,10 PIXEL
   @  66, 00 SAY "Dirección" OF oDlg RIGHT PIXEL SIZE 48,10
   @  66, 50 GET oGet[11] VAR ::oDb:DIRECCION OF oDlg SIZE 130,10 PIXEL
   @  66,190 SAY "Naturaleza" OF oDlg RIGHT PIXEL SIZE 30,10
   @  66,222 COMBOBOX oGet[12] VAR aEd[3] ITEMS ArrayCol( ::aNatu,1 );
      SIZE 50,99 OF oDlg PIXEL
   @  78, 00 SAY "Email" OF oDlg RIGHT PIXEL SIZE 48,10
   @  78, 50 GET oGet[13] VAR ::oDb:EMAIL     OF oDlg SIZE 130,10 PIXEL
   @  90, 00 SAY "Cíudad" OF oDlg RIGHT PIXEL SIZE 48,10
   @  90, 50 BTNGET oGet[14] VAR oE:oDb:CODIGO_CIU OF oDlg PICTURE "99999";
      ACTION EVAL({|| If( oE:oCiu:Mostrar(), (oE:oDb:CODIGO_CIU := oE:oCiu:oDb:CODIGO,;
                         oGet[14]:Refresh(), oGet[14]:lValid(.f.)), ) })  ;
      SIZE 30,10 PIXEL UPDATE  RESOURCE "BUSCAR"                          ;
      VALID  EVAL({|| If( oE:oCiu:oDb:Seek( {"codigo",oE:oDb:CODIGO_CIU}),;
                        ( oDlg:Update(), .t. )                           ,;
                        ( MsgStop("Está Ciudad no Existe"),.f.) ) } )
   @  90, 84 SAY ::oCiu:oDb:NOMBRE OF oDlg PIXEL SIZE 110,10 UPDATE
   @ 102, 00 SAY "Código País"     OF oDlg RIGHT PIXEL SIZE 48,10
   @ 102, 50 GET oGet[15] VAR ::oDb:CODPAIS OF oDlg PICTURE "999";
      SIZE 30,10 PIXEL
   @ 102, 98 SAY "Actividad Económica" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 102,150 GET oGet[16] VAR ::oDb:ACTECON OF oDlg PICTURE "9999";
      SIZE 30,10 PIXEL
   @  78,200 CHECKBOX oGet[17] VAR ::oDb:TOPERET   PROMPT "Sin Tope Retencion" ;
      OF oDlg SIZE 60,10 PIXEL
   @  90,200 CHECKBOX oGet[18] VAR ::oDb:RETENEDOR PROMPT "AutoRetenedor"      ;
      OF oDlg SIZE 60,10 PIXEL
   @ 102,200 CHECKBOX oGet[19] VAR ::oDb:GRANCONTR PROMPT "Gran Contribuyente" ;
      OF oDlg SIZE 60,10 PIXEL
   @ 114, 00 SAY "% Ret.ICA"     OF oDlg RIGHT PIXEL SIZE 48,10
   @ 114, 50 GET oGet[20] VAR ::oDb:PICA  OF oDlg PICTURE "999.99";
      VALID Rango( ::oDb:PICA,0,100 )  SIZE 30,10 PIXEL
   @ 114, 80 SAY "% Ret.IVA"     OF oDlg RIGHT PIXEL SIZE 48,10
   @ 114,130 GET oGet[21] VAR ::oDb:PIVA  OF oDlg PICTURE "999.99";
      VALID Rango( ::oDb:PIVA,0,100 )  SIZE 30,10 PIXEL
   @ 114,150 SAY "% Ret.CREE"    OF oDlg RIGHT PIXEL SIZE 48,10
   @ 114,200 GET oGet[22] VAR ::oDb:PCREE OF oDlg PICTURE "999.99";
      VALID Rango( ::oDb:PCREE,0,100 ) SIZE 30,10 PIXEL

   @ 130,08 BROWSE oLbd SIZE 170,48 PIXEL OF oDlg CELLED;
      COLORS CLR_BLACK, CLR_NBLUE
   oLbd:SetArray( ::aV )
   oLbd:nHeightCell += 4
   oLbd:nHeightHead += 4
   oLbd:SetAppendMode( .t. )

   ADD COLUMN TO BROWSE oLbd DATA ARRAY ELEMENT 1;
       TITLE "Orden"        PICTURE "99"         ;
       SIZE  40 EDITABLE;          // Esta columna es editable
       3DLOOK TRUE, TRUE, TRUE;    // Celda, Titulo, Footers
       MOVE DT_MOVE_NEXT;          // Cursor pasa a la Sig.Columna editable
       ALIGN DT_RIGHT, DT_CENTER;  // Celda, Titulo, Footer
       POSTEDIT { |uVar| If( !lNuevo .AND. oLbd:lChanged, oGet[25]:Enable(), ) }
   ADD COLUMN TO BROWSE oLbd DATA ARRAY ELEMENT 2;
       TITLE "Tipo de"+CRLF+"Telefono" PICTURE "!";
       SIZE  60 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_CENTER, DT_CENTER;
       VALID { |uVar| If( AT( uVar,"TFC" ) > 0, .t., ;
              (MsgStop( "El Tipo debe ser T, F, C",">>OJO<<" ), .f.)) };
       POSTEDIT { |uVar| If( !lNuevo .AND. oLbd:lChanged, oGet[25]:Enable(), ) }
   ADD COLUMN TO BROWSE oLbd DATA ARRAY ELEMENT 3;
       TITLE "Numero"       PICTURE "9999999999" ;
       SIZE 104 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_LEFT, DT_CENTER;
       POSTEDIT { |uVar| If( !lNuevo .AND. oLbd:lChanged, oGet[25]:Enable(), ) }
   ADD COLUMN TO BROWSE oLbd DATA ARRAY ELEMENT 4;
       TITLE "Extencion"+CRLF+"ú Operador"       ;
       SIZE 130 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       ALIGN DT_LEFT, DT_CENTER;
       POSTEDIT { |uVar| If( !lNuevo .AND. oLbd:lChanged, oGet[25]:Enable(), ) }
   oLbd:aDefault := { 0, "T", SPACE(16), SPACE(30), 0 }
   oLbd:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbd:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color
   @ 130,210 BUTTON oGet[23] PROMPT "Grabar"   SIZE 44,14 OF oDlg ACTION;
      ( If( ::Cambios( "",1 ), (aEd[2] := .t., oDlg:End()),;
          ( oGet[3]:SetFocus() ))) PIXEL
    oGet[23]:cToolTip := "Graba estos Datos"
   @ 145,210 BUTTON oGet[24] PROMPT "Cancelar" SIZE 44,14 OF oDlg CANCEL;
      ACTION ( If( ::Cambios( "",2 )                      ,;
               If( MsgYesNo( "Desea Guardar los Cambios" ),;
                   aEd[2] := .t. , ), ), oDlg:End() ) PIXEL
    oGet[24]:cToolTip := "Regresa al menu Anterior"
   @ 160,210 BUTTON oGet[25] PROMPT "Telefono" SIZE 44,14 OF oDlg ACTION;
      ( ::aV := Telefono( .t.,::oDb:CODIGO_NIT,::aV ), oDlg:End() ) PIXEL
   ACTIVAGET(oGet)
   IF lView                     // Solo Consulta
      DesactivaALLGET(oGet)
      oGet[23]:Disable()
      oGet[24]:Enable()
      oGet[24]:SetFocus()
   ElseIf !lNuevo
      oGet[3]:SetFocus()
   ENDIF
ACTIVATE DIALOG oDlg CENTER ON INIT ( oGet[25]:Disable() )
If aEd[2]
   If ::oDb:TIPOCOD  # 2
      ::oDb:PRI_APE := ::oDb:SEG_APE := ""
      ::oDb:PRI_NOM := ::oDb:SEG_NOM := ""
   EndIf
   ::oDb:NATURA  := ::aNatu[aEd[3],2]
   ::Guardar( lNuevo )
   If lNuevo
      If ::oDb:TIPOCOD == 3
         nNit := SgteNumero( "exterior",1,.t. )
      EndIf
      ::oDb:Seek( { "codigo",::oDb:CODIGO } )
   EndIf
   Telefono( .t.,::oDb:CODIGO_NIT,::aV )
EndIf
::aOld := NIL
RETURN NIL

//------------------------------------//
METHOD Guardar( lNew ) CLASS TNits

   If lNew
      ::oDb:Append( .t. )
   Else
      ::oDb:Update(.t.,1)
   EndIf

RETURN NIL

//------------------------------------//
METHOD Borrar(xRec) CLASS TNits
   LOCAL nRecNo := ::oDb:RecNo()
If ::lBorrar
   If MsgNoYes( "Esta seguro que desea"+ CRLF + "eliminar este registro "+;
                STR(::oDb:row_id)+"?", "MySQL" )
      ::oDb:GoTo(xRec)
      ::oDb:Read()
      If ::oDb:Delete(.t.,1)
         MsgInfo("Borrado exitoso!!!","Borrado en el servidor")
         ::oDb:Refresh()
         ::oDb:GoTo(nRecNo)
         If ::oDb:lEof
            ::oDb:Read()
         Else
            ::oDb:Read()
            ::oDb:xLoad()
         EndIf
         ::oLbx:Refresh()
      EndIf
   EndIf
Else
   MsgStop( "Esta Prohibido Borrar","IMPOSIBLE" )
EndIf

RETURN NIL

//------------------------------------//
METHOD Buscar( uBus,cCampo,lTB,lNew ) CLASS TNits
   LOCAL cQry, hRes, lSi := .t., nRow := 0
   DEFAULT cCampo := "codigo", lTB := .f., lNew := .t.
If !::lBuscar
   If lTB
      ::oDb:Seek( {cCampo,uBus} )
         lSi := ( ::oDb:nRowCount != 0 )
      If ::oDb:nRowCount > 1
         MsgStop( cCampo+" Está en (" + STR(::oDb:nRowCount) + " ) Registros","Buscar por AYUDA" )
         lSi := .f.
      EndIf
   Else
      cQry := "SELECT " + If( ::oDb:cName == "cadclien", "nombre", (cCampo) ) +;
              " FROM "  + ::oDb:cName +;
              " WHERE " + (cCampo) + " = " + xValToChar( uBus )
      hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      nRow := MSNumRows( hRes )
      lSi  := If( !lNew .AND. nRow > 0, .f., ( nRow != 0 ) )
      cQry := ""
      While nRow > 0
         cCampo := MyReadRow( hRes )
         cQry += (STR(nRow,3) + ".  " + cCampo[1] + CRLF)
         nRow --
      EndDo
      MSFreeResult( hRes )
      If lSi
         MsgStop( cQry,">> Está en <<" )
      EndIf
   EndIf
/* Version Anterior
   If !lTB
      cQry := "SELECT " + (cCampo) + " FROM " + ::oDb:cName +;
              " WHERE " + (cCampo) + " = " + xValToChar( uBus )
      hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      nRow := MSNumRows( hRes )
      MSFreeResult( hRes )
   Else
      ::oDb:Seek( {cCampo,uBus} )
      nRow := ::oDb:RecCount()
   EndIf
   lSi := ( nRow != 0 )
   If nRow > 1
      MsgStop( cCampo+" Está en (" + STR(nRow) + " ) Registros","Buscar por AYUDA" )
      lSi := .f.
   EndIf
*/
EndIf
::lBuscar := .f.
RETURN lSi

//------------------------------------//
METHOD Buscando( cWhere ) CLASS TNits
   LOCAL cBus := "%" + SPACE(24), nOldRec := ::oDb:Recno()
   LOCAL nTab := ::aOrden[ ::nOrden,2 ]
   DEFAULT cWhere := ""
If MsgGet( ::aOrden[ ::nOrden,1 ],"Buscar",@cBus )
   cBus := UPPER( ALLTRIM( cBus ) )
   cBus += If( RIGHT( cBus ) == "%", "", "%" )
   If ::oDb:Find( nTab, cBus, cWhere ) == 0
      MessageBeep()
      Msginfo( "Termino la busqueda"+ CRLF +"Examine o corrija","Advertencia!!!" )
      ::oDb:Go(nOldRec):Read()
   Else
      ::cBus := cBus
      ::oDb:GoTop():Read()
   EndIf
EndIf

RETURN ::cBus

//------------------------------------//
METHOD BuscaInc( nKey,cWhere ) CLASS TNits
   LOCAL bSeek, cQry, nTab := ::aOrden[ ::nOrden,2 ]
   DEFAULT cWhere := ""
bSeek := {|| If( ::oDb:Find( nTab, ALLTRIM(::cBus), cWhere ) = 0          ,;
               ( MessageBeep()                                            ,;
                 Msginfo( "Termino la busqueda"+ CRLF +"Examine o corrija",;
                          "Advertencia!!!" )                              ,;
                 ::cBus := LEFT( ::cBus,LEN( ALLTRIM( ::cBus ) )-2 ) + "%",;
                 ::oDb:Find( nTab, ALLTRIM(::cBus), cWhere ) ), )         ,;
                 ::oDb:GoTop():Read()                                     ,;
                 ::oLbx:GoTop(), ::oLbx:Refresh() }
If nKey # VK_RETURN
   ::cBus := STRTRAN(::cBus,"%","")
   do Case
      Case nKey == VK_BACK
         ::cBus := LEFT( ::cBus,LEN( ALLTRIM( ::cBus ) )-1 ) + "%"
      Case nKey == VK_ESCAPE
         ::cBus := "%"
      Case nKey >= 32
         ::cBus += UPPER( CHR( nKey ) )+"%"
   EndCase
   EVAL(bSeek)
EndIf

RETURN ::cBus

//------------------------------------//
METHOD Cambios( sMsj,nBtn,oGet,lNew ) CLASS TNits
   LOCAL lOK := .f., nFld
If oGet == NIL
   FOR nFld := 2 TO ::oDb:nFieldCount
      If ::oDb:axBuffer[ nFld ] # ::aOld[ nFld ]
            lOK := .t.
         If EMPTY(::oDb:CODIGO) .OR. EMPTY(::oDb:NOMBRE) .OR. EMPTY(::oDb:DIRECCION) .OR.;
                 (::oDb:TIPOCOD == 2 .AND. EMPTY(::oDb:PRI_APE) )
            If nBtn == 1
               MsgStop("No es posible grabar este registro, debe completar datos" +CRLF+;
                       "Cédula / NIT, Primer Nombre, Primer Apellido, Dirección" )
            EndIf
            lOK := .f.
         EndIf
         EXIT
      EndIf
   NEXT nFld
Else
   lOK := .t.
   If !EMPTY(sMsj)
      If EMPTY(::oDb:axBuffer[ nBtn ])
         MsgStop( sMsj,">> Es obligatorio <<" )
         lOK := .f.
      EndIf
   EndIf
   If lOK
      If nBtn # 9
         sMsj := XTRIM( ::oDb:PRI_APE ) +   XTRIM( ::oDb:SEG_APE ) +;
                 XTRIM( ::oDb:PRI_NOM ) + ALLTRIM( ::oDb:SEG_NOM )
         ::oDb:axBuffer[ 9 ] := PADR( sMsj,::oDb:FieldLength(9) )
         oGet:Refresh()
      EndIf
      If lNew .AND. (nBtn == 8 .OR. nBtn == 9)
         sMsj := Buscar( "SELECT codigo FROM cadclien WHERE nombre = "+;
                         xValToChar( ::oDb:NOMBRE ),"CM",,8,,1 )
         If !EMPTY( sMsj )
            MsgStop( "Cédula / NIT = " + TRANSFORM(sMsj,"999,999,999,999"),">> ya Existe <<" )
            lOK := .f.
         EndIf
      EndIf
   EndIf
EndIf
RETURN lOK

//------------------------------------//
METHOD Listado() CLASS TNits
   LOCAL oRpt, aLS := { 0,::oDb:Recno(),"" }
//   LOCAL lOK := If( ::nOrden == 3 .AND. TRIM(oApl:cUser) == "Martin", .t., .f. )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"LISTADO DE NITS","",;
         "N O M B R E-------------------- DOC No. DOCUMENTO  CODIGO  "+;
         "TELEFONOS-------  F A X     D I R E C C I O N"},,,2 )
oRpt:lPreview := MsgNoYes( "Vista Previa", ">>> Desea Ver <<<" )
::oDb:GoTop():Read()
::oDb:xLoad()
While !::oDb:Eof()
/*
   If LenNum(::oDb:CODIGO) >= 9 .AND.;
            (::oDb:CODIGO > 8000000000 .OR. ::oDb:DIGITO == 0)
      If ::oDb:CODIGO > 8000000000 .AND.;
         ::oDb:CODIGO < 9999999999
         aLS[3] := LTRIM( STR(::oDb:CODIGO) )
         ::oDb:CODIGO  := VAL( LEFT(aLS[3],9) )
         ::oDb:TIPOCOD := 1
      EndIf
      DigitoVerifica( ::oDb ); ::oDb:Update(.t.,1)
   EndIf
   ::aV := {}
   If !EMPTY( ::oDb:TELEFONO )
      AADD( ::aV, { 0, 0, "T", ::oDb:TELEFONO, "" } )
   EndIf
   If !EMPTY( ::oDb:FAX )
      AADD( ::aV, { 0, 0, "F", ::oDb:FAX, "" } )
   EndIf
   If LEN( ::aV ) > 0
      Telefono( .t.,::oDb:CODIGO_NIT,::aV )
   EndIf*/
   If ::oDb:TIPOCOD # 2
      oRpt:Titulo( 130 )
      oRpt:Say( oRpt:nL,00,::oDb:NOMBRE,31 )
      oRpt:Say( oRpt:nL,32,If( ::oDb:TIPOCOD = 0, " CC", "NIT" ))
      oRpt:Say( oRpt:nL,36,FormatoNit(::oDb:CODIGO,::oDb:DIGITO) )
      oRpt:Say( oRpt:nL,51,TRANSFORM( ::oDb:CODIGO_NIT,"99,999" ))
      oRpt:Say( oRpt:nL,59,::oDb:TELEFONO )
      oRpt:Say( oRpt:nL,77,::oDb:FAX )
      oRpt:Say( oRpt:nL,87,::oDb:DIRECCION )
      oRpt:nL ++
      aLS[1]  ++
   EndIf
   ::oDb:Skip(1):Read()
   ::oDb:xLoad()
EndDo
If aLS[1] > 0
   oRpt:Say( oRpt:nL++,00,Replicate ("_",130) )
   oRpt:Say( oRpt:nL  ,10,"TOTAL NITS ESTE LISTADO...." + STR( aLS[1],4 ) )
EndIf
oRpt:NewPage()
oRpt:End()
::oDb:Go(aLS[2]):Read()
::oLbx:GoTop()
::oLbx:Refresh()
RETURN NIL

//------------------------------------//
METHOD Barra(lHelp,oDlg) CLASS TNits
   LOCAL oBar, oBot := ARRAY(7)
DEFINE BUTTONBAR oBar OF oDlg 3DLOOK SIZE 28,28

DEFINE BUTTON oBot[1] RESOURCE "NUEVO"    OF oBar NOBORDER ;
   TOOLTIP "Nuevo Registro (Ctrl+N)" ;
   ACTION Eval(::bNew)
DEFINE BUTTON oBot[2] RESOURCE "EDIT"     OF oBar NOBORDER ;
   TOOLTIP "Editar Registro (Ctrl+E)";
   ACTION Eval(::bEditar)
DEFINE BUTTON oBot[3] RESOURCE "VER"      OF oBar NOBORDER ;
   TOOLTIP "Ver datos (Ctrl+V)" ;
   ACTION Eval(::bVer)
DEFINE BUTTON oBot[4] RESOURCE "ELIMINAR" OF oBar NOBORDER ;
   TOOLTIP "Eliminar (Ctrl+DEL)" ;
   ACTION Eval(::bBorrar)
DEFINE BUTTON oBot[5] RESOURCE "BUSCAR"   OF oBar NOBORDER ;
   TOOLTIP "Localizar (Ctrl+L)"  ;
   ACTION Eval(::bBuscar) GROUP
DEFINE BUTTON oBot[6] RESOURCE "PRINT"    OF oBar NOBORDER ;
   TOOLTIP "Imprimir" ;
   ACTION Eval(::bPrint)
DEFINE BUTTON oBot[7] RESOURCE "QUIT"     OF oBar NOBORDER ;
   TOOLTIP "Salir"    ;
   ACTION (oDlg:End())    GROUP
// Crear combobox para indices
   @ .45,36 COMBOBOX ::oIndex VAR ::nOrden;
          ITEMS ArrayCol( ::aOrden,1 )    ;
          SIZE 95, 120 FONT ::oFont ;
          COLOR CLR_BLACK, NIL  OF oBar
   ::oIndex:cTooltip := "Selecione el orden"
   ::oIndex:bChange  := {|| ::cBus := If( !EMPTY(::cBus) .AND. ::nOrden # 1    ;
                                  .AND. VALTYPE( ::aOrden[::nOrden,2] ) == "N",;
                             xValBuscar( ::oDb:FldLoad(::aOrden[::nOrden,2]) ),;
                             "%" ), oDlg:Update(), ::ChangeOrder()   ,;
                            ::oDb:Find( ::aOrden[::nOrden,2],::cBus ),;
                            ::oDb:GoTop():Read()                     ,;
                            ::oLbx:GoTop(), ::oLbx:Refresh() }
   ::oIndex:Set3DLook()
IF lHelp == NIL
   AEVAL( oBot,{|o| o:Disable() },1,4 )
   oBot[6]:Disable()
ElseIF lHelp
   oBot[4]:Disable()
   oBot[6]:Disable()
ENDIF
 oBar:bRClicked := {|| NIL }
 oBar:bLClicked := {|| NIL }
RETURN oBar

//------------------------------------//
METHOD ChangeOrder() CLASS TNits
   LOCAL nOrder := ::aOrden[ ::nOrden,2 ]
CursorWait()

::oDb:SetOrder( nOrder )
::oDb:GoTop():Read()

::oIndex:Refresh()
::oLbx:GoTop()
::oLbx:Refresh()
::oLbx:SetFocus()

CursorArrow()

RETURN .T.

//------------------------------------//
FUNCTION DigitoVerifica( oDb )
   LOCAL aP, cNum, nR, nNit, nSuma := 0
If LenNum( oDb:CODIGO ) > 4
   aP := { 71,67,59,53,47,43,41,37,29,23,19,17,13,7,3 }
   cNum := STRZERO( oDb:CODIGO,15 )
   FOR nR := 15 TO 1 STEP -1
      nNit  := VAL(SUBSTR( cNum,nR,1 ))
      nSuma += (nNit * aP[nR])
   NEXT
   nR := nSuma % 11            // Resto
// nR := INT(nSuma / 11)       // Resto
// nR := nSuma - (11*nR)       // Residuo
   If nR > 1
      nR := 11 - nR
   EndIf
   oDb:DIGITO := nR
EndIf
RETURN NIL

//------------------------------------//
FUNCTION Telefono( lNew,nCNit,aTel )
   LOCAL cQry, hRes, nR
If lNew
   FOR nR := 1 TO LEN( aTel )
      If !EMPTY( aTel[nR,3] )
         If aTel[nR,5] == 0
            cQry := "INSERT INTO telefonos VALUES ( null, " + LTRIM(STR(nCNit))     +;
                    ", " + If( EMPTY(aTel[nR,1]), "null",  LTRIM(STR(aTel[nR,1])) ) +;
                    ", " + If( EMPTY(aTel[nR,2]), "null", xValToChar(aTel[nR,2] ) ) +;
                    ", " +                                xValToChar(aTel[nR,3] )   +;
                    ", " + If( EMPTY(aTel[nR,4]), "null", xValToChar(aTel[nR,4] ) ) + " )"
         Else
            cQry := "UPDATE telefonos SET " +;
                    "orden = " + If( EMPTY(aTel[nR,1]), "null",  LTRIM(STR(aTel[nR,1])) )+;
                   ", tipo = " + If( EMPTY(aTel[nR,2]), "null", xValToChar(aTel[nR,2] ) )+;
                 ", numero = " +                                xValToChar(aTel[nR,3] )  +;
              ", extencion = " + If( EMPTY(aTel[nR,4]), "null", xValToChar(aTel[nR,4] ) )+;
                 " WHERE row_id = " + LTRIM(STR(aTel[nR,5]))
         EndIf
         MSQuery( oApl:oMySql:hConnect,cQry )
      ElseIf aTel[nR,5] > 0
            cQry := "DELETE FROM telefonos WHERE row_id = " +;
                    LTRIM(STR(aTel[nR,5]))
         MSQuery( oApl:oMySql:hConnect,cQry )
      EndIf
   NEXT nR
EndIf
 cQry := "SELECT orden, tipo, numero, extencion, row_id "        +;
         "FROM telefonos WHERE codigo_nit = " + LTRIM(STR(nCNit))+;
         " ORDER BY orden"
 hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
             MSStoreResult( oApl:oMySql:hConnect ), 0 )
 nR   := MSNumRows( hRes )
 While nR > 0
    cQry := MyReadRow( hRes )
    AEVAL( cQry, { |xV,nP| cQry[nP] := MyClReadCol( hRes,nP ) } )
    If VALTYPE( aTel ) == "A"
       AADD( aTel,{ cQry[1],cQry[2],cQry[3],cQry[4],cQry[5] } )
    Else
       aTel += (ALLTRIM(cQry[3]) + If( EMPTY(cQry[4]), "", "-"+ALLTRIM(cQry[4]) ) + "/")
    EndIf
    nR --
 EndDo
 MSFreeResult( hRes )
 If VALTYPE( aTel ) == "A" .AND. LEN( aTel ) == 0
    AADD( aTel,{ 0, "T", SPACE(16), SPACE(40), 0 } )
 EndIf
RETURN aTel

//------------------------------------//
FUNCTION FormatoNit( nNit,nDV )
   LOCAL cDV := If( LenNum(nNit) > 4, "-"+STR(nDV,1), "" )
RETURN TransForm( nNit,"9999,999,999" ) + cDV

//------------------------------------//
FUNCTION Separar( cNom,nPA,nSA,nPN,nSN )
   LOCAL aNom := { "",SPACE(20),SPACE(15),SPACE(15) }
If nPA > 0
   aNom[1] := PADR( SUBSTR( cNom,  1,nPA ),40 )
   nPA     += 2
   aNom[2] := PADR( SUBSTR( cNom,nPA,nSA ),20 )
   nPA     += nSA + 1
   aNom[3] := PADR( SUBSTR( cNom,nPA,nPN ),15 )
   nPA     += nPN + 1
   aNom[4] := PADR( SUBSTR( cNom,nPA,nSN ),15 )
Else
   aNom[1] := cNom
EndIf
RETURN aNom

//------------------------------------//
FUNCTION xValBuscar( uVal )
   LOCAL cType := VALTYPE( uVal ), cValor := ""
do Case
Case cType == "C"
   cValor := ALLTRIM( uVal )
case cType == "D"
   cValor := MyDToMs( DToS( uVal ) )
case cType == "L"
   cValor := MyLToMs( uVal )
Case cType == "N"
   cValor := LTRIM( STR( uVal ) )
EndCase
RETURN cValor + "%"