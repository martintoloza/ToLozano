// Programa.: CSJRECEP.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Modulo para la Elaboracion de Cotizaciones
#include "Fivewin.ch"
#include "TSBrowse.ch"
#include "Btnget.ch"

MEMVAR oApl

#define CLR_PINK  nRGB( 128, 150, 150) //255, 128, 128
#define CLR_NBLUE nRGB( 128, 128, 192)

FUNCTION Cotizacion()
   LOCAL oDlg, oLbt, oLbx, aColor[2], lNoBlink := .f.
   LOCAL cTit, nA, oF, oNi
If (aColor[ 1 ] := GetSysColor( COLOR_INACTIVECAPTION ) ) != ;
   GetSysColor( COLOR_ACTIVECAPTION )
   aColor[ 2 ] := GetSysColor( COLOR_INACTCAPTEXT )
   lNoBlink := .t.
   SBNoBlink()
EndIf
 oF  := TCotizar() ;  oF:New()
 oNi := TPer()     ; oNi:New()
 oF:oTP := TChq()  ; oF:oTP:NEW( 3 )
cTit := "Recepción - Facturas || "
oApl:oEmp:Seek( {"localiz",oApl:oEmp:TITULAR} )
nEmpresa( .t. )
ASIZE( oF:oG,11 )
oF:dFec := oApl:oEmp:FEC_HOY
oF:Iniciar( ,,"A" )
oF:AdicArray()

DEFINE DIALOG oDlg FROM 0, 0 TO 470, 580 PIXEL;
   TITLE cTit + oApl:cEmpresa
   @ 16, 00 SAY "Nro. Factura" OF oDlg RIGHT PIXEL SIZE 40,10
   @ 16, 42 BTNGET oF:oG[1] VAR oF:aM[2] OF oDlg  PICTURE "9999999999";
      ACTION EVAL({|| If(oF:Mostrar(,,'A'), (oF:aM[2] := oF:oDb:NUMFAC,;
                         oApl:nEmpresa := oF:oDb:EMPRESA              ,;
                         oApl:Tipo     := oF:oDb:TIPO                 ,;
                         oF:oG[1]:Refresh() ), ) } )                   ;
      VALID( If( !oApl:oFac:Seek( { "empresa",oApl:nEmpresa,"numfac"  ,;
                       oF:aM[2],"tipo",oApl:Tipo} ) .AND. oF:aM[2] # 0,;
               ( MsgStop("Factura NO EXISTE"), .f. )                  ,;
               (oF:AdicArray(),  oLbt:aArray := oF:aVen               ,;
                oLbx:aArray := oF:aV, oDlg:Update(), oLbt:Refresh()   ,;
                oLbt:DrawFooters(),                 oF:Dscto( 0,oLbx ),;
                If( oApl:oFac:lOK, (oF:oG[1]:oJump := oLbx), ), .t. )));
      SIZE 40,10 PIXEL UPDATE  RESOURCE "BUSCAR"
   @ 16,110 SAY "Sgte. Factura" + STR( oF:nSigFac,8 ) OF oDlg PIXEL SIZE 70,10;
      UPDATE COLOR nRGB( 255,0,0 )
   @ 16,172 SAY "Fecha [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 16,236 GET oF:oG[2] VAR oApl:oFac:FECHOY OF oDlg ;
      MESSAGE "Fecha Factura";
      VALID oF:Fechas( oApl:oFac:lOK,1 ) ;
      WHEN oApl:cFecha == "SI" SIZE 40,10 PIXEL UPDATE
   @ 28, 00 SAY "Documento ID" OF oDlg RIGHT PIXEL SIZE 40,10
   @ 28, 42 BTNGET oF:oG[3] VAR oF:aM[3] OF oDlg                      ;
      ACTION EVAL({|| If( oNi:Mostrar( ,,oF:aM[3]), (oF:aM[3] :=      ;
                          oNi:oDb:DOCIDEN, oF:oG[3]:Refresh() ), ) }) ;
      VALID EVAL( {|| If( oNi:Buscar( oF:aM[3],"dociden",.t. )       ,;
                 (oApl:oFac:TURISTA_ID := oNi:oDb:TURISTA_ID         ,;
                  oApl:oFac:CLIENTE    := oF:aM[4] := oNi:oDb:NOMBRES,;
                  oDlg:Update(), .t. )                               ,;
                 (oNi:Editar( ,.t.,,oF:aM[3] ), .f. ) ) } )           ;
      SIZE 60,10 PIXEL UPDATE  RESOURCE "BUSCAR"
//            (If( MsgYesNo("Desea ingresarlo","Este ID  no Existe") ,;
//                oNi:Editar( ,.t.,,oF:aM[3] ), ),.f.) ) } )          ;
   @ 28,114 SAY oF:oG[4] VAR oApl:oFac:CLIENTE OF oDlg BORDER PIXEL ;
      SIZE 162,10 UPDATE COLOR nRGB( 128,0,255 )
   @ 40, 00 SAY "Fecha Llegada"           OF oDlg RIGHT  PIXEL SIZE 40,10
   @ 40, 42 SAY oF:oG[5] VAR oF:aCli[1]   OF oDlg BORDER PIXEL SIZE 76,10 UPDATE
   @ 40,194 SAY "No. de Noches"           OF oDlg RIGHT  PIXEL SIZE 40,10
   @ 40,236 GET oF:oG[6] VAR oApl:oFac:PAGINAS OF oDlg PICTURE "99";
      VALID( If( oApl:oFac:PAGINAS > 0,;
               ( oF:Estadia( 1 ), oF:oG[8]:REFRESH(), .t. ) ,;
               ( MsgStop( "Nro. de Noches debe ser mayor de 0" ), .f. ) ));
      SIZE 20,10 PIXEL UPDATE
   @ 40,258 SAY oF:oG[7] VAR oApl:oFac:NOCHE_EXT OF oDlg PICTURE "999";
      BORDER PIXEL SIZE 20,10 UPDATE
   @ 52, 00 SAY "Fecha Salida"            OF oDlg RIGHT  PIXEL SIZE 40,10
   @ 52, 42 SAY oF:oG[08] VAR oF:aCli[2]  OF oDlg BORDER PIXEL SIZE 76,10 UPDATE
   @ 52,120 SAY oF:oG[09] VAR oF:aM[7]    OF oDlg COLOR nRGB( 255,0,0 );
      BORDER PIXEL SIZE 70,10 UPDATE
   @ 52,182 SAY "Valor Factura"           OF oDlg RIGHT  PIXEL SIZE 50,10
   @ 52,236 SAY oF:oG[10] VAR oF:aM[6]    OF oDlg PICTURE "999,999,999";
      BORDER PIXEL SIZE 42,10 UPDATE
   @ 64,194 SAY "Saldo"                   OF oDlg RIGHT PIXEL SIZE 40,10
   @ 64,236 SAY oF:oG[11] VAR oApl:nSaldo OF oDlg PICTURE "999,999,999";
      BORDER PIXEL SIZE 42,10 UPDATE

   @ 66.0,06 BROWSE oLbt SIZE 200,58 PIXEL OF oDlg CELLED;
      COLORS CLR_BLACK, CLR_NBLUE
   oLbt:SetArray( oF:aVen )     // Esto es necesario para trabajar con arrays
   oLbt:nHeightCell += 4
   oLbt:nHeightHead += 4
   oLbt:lNoHScroll  := .t.
 //oLbt:lNoVScroll  := .t.
   oLbt:bKeyDown := {|nKey| If(nKey=VK_TAB, oLbt:oJump := oF:oG[3],;
                            If(nKey=VK_F3 , oF:oB[1]:Click() ,;
                            If(nKey=VK_F5 , oF:oB[2]:Click() ,;
                            If(nKey=VK_F6 , oF:oB[3]:Click() ,;
                            If(nKey=VK_F7 , oF:oB[4]:Click() ,;
                            If(nKey=VK_F11, oF:oB[5]:Click() , )))))) }
   oLbt:SetAppendMode( .t. )                  // Activando Auto Append Mode
 //oLbt:SetAppendMode( oF:lNuevo )            // Activando Auto Append Mode
   oLbt:SetDeleteMode( .t.,.f.,{ |nAt,oLbt| oF:DelArray(oLbt) },;
                  {|oLbt| oF:Dscto( 0,oLbt ) } ) // lOnOff, lConfirm, bDelete
   ADD COLUMN TO BROWSE oLbt DATA ARRAY ELEMENT 1;
       TITLE "Documento ID"+CRLF+"Acompañante"   ;
       SIZE 100 EDITABLE;          // Esta columna es editable
       3DLOOK TRUE, TRUE, TRUE;    // Celda, Titulo, Footers
       MOVE DT_MOVE_DOWN;          // Cursor pasa a la Sig.Fila editable
       VALID { |uVar| oF:Busacom( uVar,oNi ) }; // don't want empty rows
       ALIGN DT_LEFT, DT_CENTER  ; // Celda, Titulo, Footer
       PREEDIT {|uVar| oF:aM[11] := uVar, nA := oLbt:nAt };
       FOOTER { || STR( oLbt:nLen,4 ) + " Items" } ;
       WHEN oF:EditAcomp( oLbt )
    oLbt:aColumns[1]:bPostEdit := { |uVar| oF:aVen[nA,1] := oF:aM[11],;
               oF:aVen[nA,2] := oF:aM[12], oF:aVen[nA,3] := oF:aM[13],;
               oF:EditAcomp( oLbt,nA ) }
     // activando BtnGet para la columna 1 y habilitando una Ayuda
    oLbt:SetBtnGet( 1, "Buscar", { | oGet,cVar | If( oNi:Mostrar() ,;
        (cVar := oNi:oDb:DOCIDEN, oGet:cText( cVar ), oGet:Refresh(),;
         oGet:KeyDown( VK_RETURN, 0 )), ) }, 16 )
   ADD COLUMN TO BROWSE oLbt DATA ARRAY ELEMENT 2;
       TITLE "Nombre Acompañante" ;
       SIZE 300 ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_LEFT, DT_CENTER
   // Asignando Valores por defaults para nueva Fila creada con Auto Append.
   oLbt:aDefault := { SPACE(15), SPACE(50), 0, 0 }
   oLbt:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbt:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color

   @ 130.0,06 BROWSE oLbx SIZE 250,98 PIXEL OF oDlg CELLED;
      COLORS CLR_BLACK, CLR_NBLUE
   oLbx:SetArray( oF:aV )     // Esto es necesario para trabajar con arrays
   //oLbx:nFreeze     := 1
   //oLbx:nRowPos     := oLbx:nAt   := 4
   //oLbx:nColPos     := oLbx:nCell := 3
   oLbx:nHeightCell += 4
   oLbx:nHeightHead += 4
   oLbx:bKeyDown := {|nKey| If(nKey=VK_TAB, oLbx:oJump := oF:oG[3],;
                            If(nKey=VK_F3 , oF:oB[1]:Click() ,;
                            If(nKey=VK_F5 , oF:oB[2]:Click() ,;
                            If(nKey=VK_F6 , oF:oB[3]:Click() ,;
                            If(nKey=VK_F7 , oF:oB[4]:Click() ,;
                            If(nKey=VK_F11, oF:oB[5]:Click() , )))))) }
   oLbx:SetAppendMode( .f. )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 2;
       TITLE "Nombre Servicio" ;
       SIZE 180 ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_LEFT, DT_CENTER, DT_RIGHT;
       WHEN oF:EditArray( oLbx ) ;
       FOOTER "Totales->"
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 3;
       TITLE "Precio"+CRLF+"Noche" PICTURE "99,999,999";
       SIZE  74 ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 4;
       TITLE "No. de"+CRLF+"Noches" PICTURE "9,999" ;
       SIZE  58 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER ;
       POSTEDIT { |uVar| If( oLbx:lChanged, oF:Dscto( 4,oLbx,uVar,oF:nAcom ), ) } ;
       VALID { |uVar| oF:DelArray( oLbx,4,uVar ) } ;
       WHEN oF:EditArray( oLbx )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 8;
       TITLE "Precio"+CRLF+"Neto"   PICTURE "99,999,999" ;
       SIZE  76 ;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       FOOTER { || TRANSFORM( oF:aM[09], "99,999,999" ) }
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 6;
       TITLE "%"+CRLF+"Dscto."   PICTURE "999.99" ;
       SIZE  48 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER ;
       VALID { |uVar| If( Rango( uVar,0,100 ), .t., ;
              (MsgStop( "El Porcentaje debe ser entre 0 y 100",">>OJO<<" ), .f.)) };
       POSTEDIT { |uVar| If( oLbx:lChanged, oF:Dscto( 6,oLbx,uVar,oF:nAcom ), ) };
       WHEN oF:EditArray( oLbx )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 7;
       TITLE "Descuento"     PICTURE "99,999,999" ;
       SIZE  74 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       VALID { |uVar| oF:DelArray( oLbx,7,uVar ) };
       FOOTER { || TRANSFORM( oF:aM[08], "99,999,999" ) };
       POSTEDIT { |uVar| If( oLbx:lChanged, oF:Dscto( 7,oLbx,uVar,oF:nAcom ), ) };
       WHEN oF:EditArray( oLbx )
   ADD COLUMN TO BROWSE oLbx DATA ARRAY ELEMENT 9;
       TITLE "Monto"+CRLF+"I.V.A"   PICTURE "99,999,999" ;
       SIZE  74 EDITABLE;
       3DLOOK TRUE, TRUE, TRUE;
       MOVE DT_MOVE_NEXT;
       ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT;
       FOOTER { || TRANSFORM( oF:aM[10], "99,999,999" ) };
       POSTEDIT { |uVar| If( oLbx:lChanged, oF:Dscto( 0,oLbx,uVar ), ) };
       WHEN oF:EditArray( oLbx )
   //oLbx:aDefault := { SPACE(12), SPACE(40), 0, 1, "UN", 0, 0, 0, 0, " ", 0, .f., 1, 0, 1, "", 0 }
   oLbx:SetColor( { 2, 6, 15 }, ;
                  { {|| If( oLbx:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) },;
                    { CLR_WHITE, CLR_HRED }, ; // degraded cursor
                      CLR_GRAY } )  // grid lines color
   ACTIVAGET( oF:oG )
ACTIVATE DIALOG oDlg CENTERED ON INIT ;
  ( oF:Barrecep( oDlg,oLbx,oLbt ) );
   VALID !GetKeyState( VK_ESCAPE )
If( lNoBlink, SBNoBlink( aColor[1], aColor[2] ), Nil )
oApl:oEmp:Seek( {"empresa",oF:nOptica} )
oF:oDb:Destroy()
oF:oMvc:Destroy()
oF:oMvd:Destroy()
oF:oVen:Destroy()
SETKEY( VK_F4,{||Empresa()} )
nEmpresa( .f. )
RETURN NIL

/*
DATEDIFF
TIMEDIFF
DATE_FORMAT(p.fecha, '%r')  04:30:00 PM
CAST(p.fecha AS DATE) = " + xValToChar( ::aLS[1] )

CREATE TABLE `cadfacte` (
  `row_id` int(11) NOT NULL AUTO_INCREMENT,
  `factc_id` int(11) DEFAULT NULL,
  `fecha_ent` datetime DEFAULT NULL,
  `fecha_sal` datetime DEFAULT NULL,
  PRIMARY KEY (`row_id`),
  KEY `Llegada` (`fecha_ent`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
//) ENGINE=InnoDB DEFAULT CHARSET=latin1;

ALTER TABLE cadfactg
ADD FOREIGN KEY fk_cadfactg_ref_turista(turista_id) REFERENCES turista(turista_id)
CREATE TABLE cliente
(
    id_cliente INT NOT NULL,
    nombre VARCHAR(30),
    PRIMARY KEY (id_cliente)
) TYPE = INNODB;

CREATE TABLE venta
(
    id_factura INT NOT NULL,
    id_cliente INT NOT NULL,
    cantidad   INT,
    PRIMARY KEY(id_factura),
    INDEX (id_cliente),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
) TYPE = INNODB;
ALTER TABLE venta ADD FOREIGN KEY(id_cliente) REFERENCES cliente(id_cliente);
La sintaxis completa de una restricción de clave foránea es la siguiente:

[CONSTRAINT símbolo] FOREIGN KEY (nombre_columna, ...)
                  REFERENCES nombre_tabla (nombre_columna, ...)
                  [ON DELETE {CASCADE | SET NULL | NO ACTION
                              | RESTRICT}]
                  [ON UPDATE {CASCADE | SET NULL | NO ACTION
                              | RESTRICT}]
*/

//------------------------------------//
CLASS TCotizar FROM TFactura

 DATA oB            INIT ARRAY(9)
 DATA dFec, nAcom, nDias, oTP
 METHOD AdicArray()
 METHOD Barrecep( oDlg,oLbx,oLbt )
 METHOD Busacom( xBuscar,oNi,nA )
 METHOD EditAcomp( oLbt,nA,nF )
 METHOD Guardar( oDlg,oLbx )
 METHOD Estadia( nR )
 METHOD Borrar( nR,nT )
 METHOD Facturar( oDlg,oLbx )
 METHOD Listado( oDlg,oLbx )

ENDCLASS

//------------------------------------//
METHOD AdicArray() CLASS TCotizar
   LOCAL aRes, nL
::nAcom := oApl:oFac:AMIGOS
 Super:AdicArray( ::nAcom )
   ::aCli := {}
   ::aVen := {}
If ::aM[2] == 0
   ::aM[3] := SPACE(15)
   ::aV := {}
   ::nDias := 0
   oApl:oFac:FECHAENT := oApl:dFec + 1
   aRes := Buscar( "SELECT codigo FROM cadinven WHERE linea = 'REC'","CM",,9 )
   FOR nL := 1 TO LEN( aRes )
      ::Buscar( aRes[nL] )
      If ::aM[17]
         ::aM[14] := ROUND( ::aM[13] / ::aM[18],2 )
      Else
         ::aM[14] := ::aM[13]
      EndIf
      AADD( ::aV,{ aRes[nL], ::aM[12], ::aM[13], 0       ,;
                   ::aM[20], 0       , 0       , 0       ,;
                   0       , " "     , 0       , ::aM[17],;
                   ::aM[18], ::aM[14], ::aM[19], ::aM[20], 0 } )
   NEXT nL
   //AADD( ::aV,{ SPACE(12), SPACE(40), 0, 1, "UN", 0, 0, 0, 0, " ", 0, .f., 1, 0, 1, "", 0 } )
Else
   oApl:oTur:Seek( {"turista_id",oApl:oFac:TURISTA_ID} )
   ::aM[3]:= oApl:oTur:DOCIDEN
   ::aCli := Buscar( "SELECT DATE_FORMAT(fecha_ent,'%d.%m.%Y a las %h:%i %p'), "+;
                            "DATE_FORMAT(fecha_sal,'%d.%m.%Y a las %h:%i %p'), estado "+;
                     "FROM cadfacte WHERE factc_id = " + LTRIM(STR(oApl:oFac:ROW_ID)),"CM",,8 )
   ::aVen := Buscar( "SELECT t.dociden, t.nombres, t.turista_id, g.row_id "+;
                     "FROM turista t, cadfactg g "        +;
                     "WHERE g.turista_id = t.turista_id " +;
                       "AND g.factc_id   = " + LTRIM(STR(oApl:oFac:ROW_ID)),"CM",,9 )
EndIf
::Estadia( 0 )
If LEN( ::aVen ) == 0
   AADD( ::aVen,{ SPACE(15), SPACE(50), 0, 0 } )
EndIf
SysRefresh()
RETURN NIL

//------------------------------------//
METHOD Barrecep( oDlg,oLbx,oLbt ) CLASS TCotizar
   LOCAL oBar
DEFINE BUTTONBAR oBar OF oDlg 3DLOOK SIZE 28,28

DEFINE BUTTON ::oB[5] RESOURCE "DEDISCO"   OF oBar NOBORDER ;
   TOOLTIP "Grabar Factura [F11]" ;
   ACTION ::Guardar( oDlg,oLbx )
DEFINE BUTTON ::oB[1] RESOURCE "IMPRIMIR"  OF oBar NOBORDER ;
   TOOLTIP "Imprime Factura [F3]" ;
   ACTION ( CSJLIREC( 1,{::dFec,::dFec,1,oApl:nTFor,.t.,0,""} ),;
            ::Iniciar( oDlg,oLbx ) )
DEFINE BUTTON ::oB[2] RESOURCE "REINDEZAR" OF oBar NOBORDER ;
   TOOLTIP "Borrar Código [F5]"  ;
   ACTION ( ::aM[1] := .t., oLbx:KeyDown( VK_DELETE,0 ) )
DEFINE BUTTON ::oB[3] RESOURCE "DELREC"    OF oBar NOBORDER ;
   TOOLTIP "Anular Factura [F6]" ;
   ACTION ::DelFactu( oDlg,oLbx )
DEFINE BUTTON ::oB[4] RESOURCE "NEW"       OF oBar NOBORDER ;
   TOOLTIP "Nueva Factura [F7]"  ;
   ACTION ::Iniciar( oDlg,oLbx ) GROUP
DEFINE BUTTON ::oB[6] RESOURCE "MONEY"     OF oBar NOBORDER ;
   TOOLTIP "Check UP [F8]"  ;
   ACTION EVAL({|| If( ::oTP:Muestra(), (::aM[2] := ::oTP:oDb:NUMFAC,;
                       ::Facturar( oDlg,oLbx ) ), ) } )
//                     ::Facturar(), __Keyboard( CHR( VK_RETURN ) ) ), ) } )
DEFINE BUTTON ::oB[7] RESOURCE "MIRAR"     OF oBar NOBORDER ;
   TOOLTIP "Pagos a Cartera"     ;
   ACTION MsgInfo( "Dispobible para lo que SEA" )
DEFINE BUTTON ::oB[8] RESOURCE "CALC"      OF oBar NOBORDER ;
   TOOLTIP "Calculadora"         ;
   ACTION WinExec( "Calc" )      GROUP
DEFINE BUTTON ::oB[9] RESOURCE "SALIR"     OF oBar NOBORDER ;
   TOOLTIP "Regresar al Menu"    ;
   ACTION oDlg:End()
 oBar:bRClicked := {|| NIL }
 oBar:bLClicked := {|| NIL }
RETURN oBar

//------------------------------------//
METHOD Busacom( xBuscar,oNi,nA ) CLASS TCotizar
   LOCAL lOK
If (nA := ASCAN( ::aVen, { |x| x[1] == xBuscar } )) > 0
   MsgStop( ::aVen[nA,2],"Documento ID no puede estar 2 VECES" )
   RETURN .f.
EndIf

If (lOK := oApl:oTur:Seek( {"dociden",xBuscar} ))
   ::aM[11] := xBuscar
   ::aM[12] := oApl:oTur:NOMBRES
   ::aM[13] := oApl:oTur:TURISTA_ID
ElseIf !EMPTY( xBuscar )
   oNi:Editar( ,.t.,,xBuscar )
   If (lOK := oApl:oTur:Seek( {"dociden",xBuscar} ))
      ::aM[11] := xBuscar
      ::aM[12] := oApl:oTur:NOMBRES
      ::aM[13] := oApl:oTur:TURISTA_ID
   Else
      MsgStop( "Este Documento ID NO EXISTE !!!",xBuscar )
   EndIf
EndIf
RETURN If( EMPTY( xBuscar ), .f., lOK )

//------------------------------------//
METHOD EditAcomp( oLbt,nA,nF ) CLASS TCotizar
   LOCAL lEdit
If nA == NIL
   nA := oLbt:nAt
   lEdit := .t.
   If nA > LEN(::aVen)
      nF := If( nA > 2, 1, nA-1 )
      If EMPTY( ::aVen[nF,1] ) .OR. oLbt:nCell # 1
         MsgStop( "Primero Digite Documento ID","Nuevo" )
         oLbt:nAt   := oLbt:nRowPos := oLbt:nLen
         lEdit := .f.
      EndIf
      If !lEdit
         oLbt:nCell := 1
         oLbt:HiliteCell( 1 ) ; oLbt:Refresh(.t.)
         oLbt:DrawSelect()
      EndIf
   Else
      If EMPTY( ::aVen[nA,1] ) .AND. oLbt:nCell # 1
         MsgStop( "Primero Digite Documento ID" )
         oLbt:nCell := 1 ; lEdit := .f.
         oLbt:HiliteCell( 1 ) ; oLbt:Refresh()
      EndIf
   EndIf
Else
   ::nAcom := oLbt:nLen
   oLbt:Refresh()
   oLbt:DrawFooters()
   oLbt:SetFocus()
EndIf
RETURN lEdit

//------------------------------------//
METHOD Guardar( oDlg,oLbx ) CLASS TCotizar
   LOCAL nR, sQry
If ::aM[09] > 0
   FOR nR := 1 TO LEN( ::aV )
      If ::aV[nR,04] == 0
         ::aV[nR,10] := "*"
      EndIf
   NEXT nR
   oApl:oFac:AMIGOS := ::nAcom
   Super:Guardar( oDlg,oLbx,1 )
   If ::aM[17]
      sQry := "INSERT INTO cadfacte VALUES ( null, " + LTRIM(STR(oApl:oFac:ROW_ID))+;
              ", NOW(), DATE_ADD( NOW(), INTERVAL"   + STR(oApl:oFac:PAGINAS,3)    +;
              " DAY), 'P' )"
      Guardar( sQry,"cadfacte" )
   EndIf
   FOR nR := 1 TO LEN( ::aVen )
      If !EMPTY( ::aVen[nR,1] )
         If ::aVen[nR,4] == 0
            sQry := "INSERT INTO cadfactg VALUES ( null, " + LTRIM(STR(oApl:oFac:ROW_ID)) +;
                    ", " + LTRIM(STR(::aVen[nR,3])) + " )"
         Else
            sQry := "UPDATE cadfactg SET turista_id = " + LTRIM(STR(::aVen[nR,3])) +;
                    " WHERE row_id = " + LTRIM(STR(::aVen[nR,4]))
         EndIf
         Guardar( sQry,"cadfactg" )
      EndIf
   NEXT nR
   ::Iniciar( oDlg,oLbx )
EndIf
RETURN NIL

//------------------------------------//
METHOD Estadia( nR ) CLASS TCotizar
   LOCAL sFec
If LEN( ::aCli ) == 0
   ::aCli := Buscar("SELECT DATE_FORMAT(NOW(),'%d.%m.%Y a las %h:%i %p'), "                  +;
                    "DATE_FORMAT(DATE_ADD( NOW(), INTERVAL 1 DAY),'%d.%m.%Y a las %h:%i %p')"+;
                    ", 'P' FROM dual","CM",,8 )
EndIf
If nR == 0
   ::aCli[1] := NtChr( CTOD(LEFT(::aCli[1],10)),"2" ) + RIGHT(::aCli[1],15)
   ::aCli[2] := NtChr( CTOD(LEFT(::aCli[2],10)),"2" ) + RIGHT(::aCli[2],15)
ElseIf nR == 1
   oApl:oFac:FECHAENT := oApl:oFac:FECHOY + oApl:oFac:PAGINAS
   sFec := Buscar( "SELECT DATE_FORMAT(DATE_ADD( NOW(), INTERVAL"+ STR(oApl:oFac:PAGINAS,3) +;
                   " DAY),'%d.%m.%Y a las %h:%i %p') FROM dual","CM",,8 )
   ::aCli[2] := NtChr( CTOD(LEFT(sFec,10)),"2" ) + RIGHT(sFec,15)
EndIf

//cQry := "SELECT TIMESTAMPDIFF( day, e.fecha_ent, NOW() ) "+;
//cQry := "SELECT TIMESTAMPDIFF( day, CAST(e.fecha_ent AS DATE), CURDATE() ) "+;
If ::aCli[3] == "P"
   ::nDias := Buscar( "SELECT DATEDIFF( CURDATE(), CAST(fecha_sal AS DATE) ) "+;
                      "FROM cadfacte WHERE factc_id = " + LTRIM(STR(oApl:oFac:ROW_ID)),"CM",,8,,4 )
   If ::nDias > 0
      oApl:nSaldo := (::aM[6] / oApl:oFac:PAGINAS) * ::nDias
      ::aM[7]     := "Debe" + STR(::nDias,4) + " Noches"
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Borrar( nA,nT ) CLASS TCotizar
   LOCAL aEsp, nR
If ::oDb:CLASE == 1
   nT := If( nT == NIL, LEN( ::aV ), nA )
   FOR nR := nA TO nT
      If ::aV[nR,10] > 0 .AND. ::aV[nR,16] == "M"
         aEsp := Buscar( { "cotid_id",::aV[nR,10] },"cadcotie",;
                        "row_id, codigo, cantidad, pcosto, unidadmed",9 )
         AEVAL( aEsp, {|a| Actualiz( a[2],-a[3],::oDb:FECHA,2,a[4] ) ,;
                         Guardar( "DELETE FROM cadcotie WHERE row_id = "+;
                                  LTRIM(STR(a[1])),"cadcotie" ) } )
      EndIf
   NEXT nA
EndIf
RETURN NIL

//------------------------------------//
METHOD Facturar( oDlg,oLbx ) CLASS TCotizar
   LOCAL aPG, oDlp, oLbs, oGet := ARRAY(15)
oApl:oFac:Seek( {"empresa",oApl:nEmpresa,"numfac",::aM[2],"tipo",oApl:Tipo} )
 ::AdicArray()
 aPG := { .f.,1,oApl:nSaldo,"" }
DEFINE DIALOG oDlp FROM 0, 0 TO 290, 580 PIXEL;
   TITLE "CHECK OUT"
   @ 02, 00 SAY "Nro. Factura" OF oDlp RIGHT PIXEL SIZE 50,10
   @ 02, 52 SAY oGet[1] VAR ::aM[2] OF oDlp  PICTURE "9999999999";
      BORDER PIXEL SIZE 40,10
   @ 14, 00 SAY "Documento ID" OF oDlp RIGHT PIXEL SIZE 50,10
   @ 14, 52 SAY oGet[2] VAR ::aM[3]      OF oDlp BORDER PIXEL SIZE 60,10
   @ 14,114 SAY oGet[3] VAR oApl:oFac:CLIENTE OF oDlp BORDER PIXEL ;
      SIZE 162,10 COLOR nRGB( 128,0,255 )
   @ 26, 00 SAY "Fecha Llegada"          OF oDlp RIGHT  PIXEL SIZE 50,10
   @ 26, 52 SAY oGet[4] VAR ::aCli[1]    OF oDlp BORDER PIXEL SIZE 76,10 UPDATE
   @ 26,194 SAY "No. de Noches"          OF oDlp RIGHT  PIXEL SIZE 40,10
   @ 26,236 SAY oGet[5] VAR oApl:oFac:PAGINAS OF oDlp PICTURE "99";
      BORDER PIXEL SIZE 20,10
   @ 26,258 SAY oGet[6] VAR oApl:oFac:NOCHE_EXT OF oDlp PICTURE "999";
      BORDER PIXEL SIZE 20,10
   @ 38, 00 SAY "Fecha Salida"           OF oDlp RIGHT  PIXEL SIZE 50,10
   @ 38, 52 SAY oGet[7] VAR ::aCli[2]    OF oDlp BORDER PIXEL SIZE 76,10
   @ 38,182 SAY "Valor Factura"          OF oDlp RIGHT  PIXEL SIZE 50,10
   @ 38,236 SAY oGet[9] VAR ::aM[6]      OF oDlp PICTURE "999,999,999";
      BORDER PIXEL SIZE 42,10
   @ 50,122 SAY oGet[8] VAR ::aM[7]      OF oDlp COLOR nRGB( 255,0,0 );
      BORDER PIXEL SIZE 70,10
   @ 50,194 SAY "Saldo"                  OF oDlp RIGHT PIXEL SIZE 40,10
   @ 50,236 SAY oGet[10] VAR oApl:nSaldo OF oDlp PICTURE "999,999,999";
      BORDER PIXEL SIZE 42,10
   @ 62, 00 SAY "Noches a Renovar"       OF oDlp RIGHT  PIXEL SIZE 50,10
   @ 62, 52 GET oGet[11] VAR ::nDias     OF oDlp PICTURE "99";
      VALID( If( ::nDias >= 0,;
               ( aPG[3] := (::aM[6] / oApl:oFac:PAGINAS) * ::nDias,;
                 oGet[13]:REFRESH(), .t. ) ,;
               ( MsgStop( "Nro. de Noches debe ser mayor de 0" ), .f. ) ));
      SIZE 20,10 PIXEL
   @ 62, 80 SAY "Opción Pagos"           OF oDlp RIGHT PIXEL SIZE 40,10
   @ 62,122 COMBOBOX oGet[12] VAR aPG[2] ITEMS {"Renovar","Salida","Salida sin Pagar"};
      SIZE 48,90 OF oDlp PIXEL

   @ 62,194 SAY "Total a Pagar"          OF oDlp RIGHT PIXEL SIZE 40,10
   @ 62,236 SAY oGet[13] VAR aPG[3]      OF oDlp PICTURE "999,999,999";
      BORDER PIXEL SIZE 42,10 UPDATE

   @ 76,200 BUTTON oGet[14] PROMPT "Grabar Pago"  SIZE 44,12 OF oDlp ;
      ACTION ( If( MsgYesNo( "Graba este Pago" ), (aPG[1] := .t., oDlp:End()),;
                 ( oGet[14]:oJump := oGet[11], oGet[11]:SetFocus()) ) ) PIXEL
   @ 92,200 BUTTON oGet[15] PROMPT "Cancelar" SIZE 44,12 OF oDlp CANCEL;
      ACTION oDlp:End() PIXEL

   @ 76, 10 LISTBOX oLbs FIELDS "", "", "";
      HEADERS "Nombre Servicio", "No. de"+CRLF+"Noches", "Precio"+CRLF+"Neto" ;
      SIZE 180, 66          ;
      FIELDSIZES 200, 50, 60;
      OF oDlp PIXEL         ;
      ON DBLCLICK MsgInfo( "Array row: " + STR( oLbs:nAt ) + CRLF + ;
                           "Array col: " + STR( oLbs:nAtCol( nCol ) ) )
    oLbs:nClrBackHead := oApl:nClrBackHead
    oLbs:nLineStyle:= 2
    oLbs:nClrLine  := nRgb(184,196,224)
    oLbs:nHeaderHeight := 28
    oLbs:aHjustify   := {2,2,2}
    oLbs:aJustify    := {0,1,1}
    oLbs:nAt       := 1
    oLbs:bLine     := { || { ::aV[oLbs:nAt,2],;
                  TRANSFORM( ::aV[oLbs:nAt,4],  "9,999"),;
                  TRANSFORM( ::aV[oLbs:nAt,8],"999,999,999") } }
    oLbs:bGoTop    := {|| oLbs:nAt := 1 }
    oLbs:bGoBottom := {|| oLbs:nAt := EVAL( oLbs:bLogicLen ) }
    oLbs:bSkip     := {|nWant,nOld| nOld := oLbs:nAt, oLbs:nAt += nWant,;
                        oLbs:nAt := MAX( 1, MIN( oLbs:nAt, EVAL( oLbs:bLogicLen ) ) ),;
                        oLbs:nAt - nOld }
    oLbs:bLogicLen := {|| LEN( ::aV ) }
    oLbs:cAlias    := "Array"

   ACTIVAGET( oGet )
ACTIVATE DIALOG oDlp CENTERED
If aPG[1]
   If aPG[2] == 1
      aPG[4] := "UPDATE cadfacte SET fecha_sal = DATE_ADD( fecha_sal, INTERVAL" +;
                STR(::nDias,3) + " DAY) "
   Else
      aPG[3] := If( aPG[2] == 3, 0, aPG[3] )
      aPG[4] := "UPDATE cadfacte SET fecha_sal = NOW(), estado = 'C' "
      oApl:oFac:FECHACAN := ::dFec
      oApl:oFac:INDICADOR:= "C"
   EndIf
   Guardar( aPG[4] + "WHERE factc_id = " + LTRIM(STR(oApl:oFac:ROW_ID)),"cadfacte" )
   oApl:oFac:NOCHE_EXT += ::nDias
   oApl:oFac:Update( .f.,1 )
   If aPG[3] > 0
      aPG[4] := "INSERT INTO cadpagos (empresa, numfac, tipo, fecpag, abono, "  +;
                                      "pagado, numcheque, documento, tipo_pag) "+;
                "VALUES ( "+ LTRIM(STR(oApl:nEmpresa)) + ", "       +;
                             LTRIM(STR(::aM[2]))       + ", 'A', '" +;
                             MyDToMs( DTOS(::dFec) )   + "', "      +;
                             LTRIM(STR(aPG[3]))        + ", " + LTRIM(STR(aPG[3])) + ", '" +;
                             LTRIM(STR(::nDias))       + "', 2, 'P' )"
      Guardar( aPG[4],"cadpagos" )
   EndIf
// ContaVta( ::oMvc,::oMvd,.f.,::aCta )
EndIf
 ::Iniciar( oDlg,oLbx )
RETURN NIL

//------------------------------------//
METHOD Listado( oDlg,oLbx ) CLASS TCotizar
   LOCAL aGT, aRes, cQry, hRes, nL, oRpt
/*
SELECT c.numfac FAC, 'F' CLA, c.fechoy, c.totalfac, t.nombres
FROM cadfactc c LEFT JOIN turista t
 USING( turista_id )
WHERE c.empresa    = 1
  AND c.fechoy     = '2015-07-09'
  AND c.tipo       = 'A'
  AND c.indicador <> 'A'
UNION ALL
SELECT c.numfac FAC, 'G' CLA, c.fechoy, c.totalfac, t.nombres
FROM cadfactc c, cadfactg g LEFT JOIN turista t
 USING( turista_id )
WHERE c.row_id     = g.factc_id
  AND c.empresa    = 1
  AND c.fechoy     = '2015-07-09'
  AND c.tipo       = 'A'
  AND c.indicador <> 'A'
ORDER BY FAC, CLA
*/
RETURN NIL