// Programa.: NOMEMPLE.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Creacion y Manto. de Empleados.
#include "Fivewin.ch"
#include "Btnget.ch"

MEMVAR oApl

FUNCTION Empleados()
   LOCAL oEpl := TEpl()
Empresa( .f. )
oEpl:New()
oEpl:Activate()
RETURN NIL

//------------------------------------//
CLASS TEpl FROM TNits

 DATA aCivi AS ARRAY INIT { {"Soltero(a)" ,"S"},{"Casado(a)"    ,"C"},;
                            {"Union Libre","U"},{"Divorciado(a)","D"} }
 DATA aNive AS ARRAY INIT { "Minimo 0.522","Bajo 1.044","Medio 2.436","Alto 4.350","Maximo 6.960"}
 DATA aLabo AS ARRAY INIT { {"Activo"     ,"A"},{"Vacación"   ,"V"},;
                            {"Licencia"   ,"L"},{"Retirado(a)","R"},;
                            {"Incapacidad","I"} }
 DATA aLiqu AS ARRAY INIT { {"Quincena"   ,"Q"},{"Decada"     ,"D"},;
                            {"Semana"     ,"S"} }
 DATA aSexo AS ARRAY INIT { {"Masculino"  ,"M"},{"Femenino"   ,"F"} }
 DATA aCCos, oCC
 METHOD NEW( oBase ) Constructor
 METHOD Mostrar( xRec,lNuevo,lView )
 METHOD Editar( lAyuda,nOrd )
 METHOD Buscar( nCod,oDlg )
 METHOD Fondos( aEd )
 METHOD Listado()
 METHOD Telefono( aLS )

ENDCLASS

//------------------------------------//
METHOD NEW( oBase ) CLASS TEpl
   LOCAL aCos, nL
   DEFAULT oBase := oApl:oEpl
 oApl:oEpl:cWhere := "Empresa = " + LTRIM(STR(oApl:nEmpresa))
Super:New( oBase,.f. )
::oCC   := TNits()
::oCC:New()
::aOrden := { {"<None>" ,1},{"Código"  ,2},;
              {"Nombre" ,3} }
::aCCos  := CCosto()
RETURN NIL

//------------------------------------//
METHOD Mostrar( lAyuda,nOrd ) CLASS TEpl
   LOCAL oDlg, oM := Self
   LOCAL aMt := { "Ayuda de Empleados",NIL }, bHacer
   DEFAULT lAyuda := .t. , nOrd := 3
If lAyuda
   aMt[2] := .f.
   bHacer := {|| aMt[2] :=.t., oDlg:End() }
ELSE
   aMt[1] := "Código de Empleados"
   bHacer := ::bEditar
ENDIF
nOrd := ::Ordenar( nOrd )
DEFINE DIALOG oDlg FROM 3, 3 TO 22, 54 TITLE aMt[1] + oApl:cEmpresa
   @ 1.5, 0 LISTBOX ::oLbx FIELDS  ;
         TRANSFORM( ::oDb:CODIGO,"9999"),;
             Nitsx( ::oDb:CODIGO_NIT )  ,;
         OEMTOANSI( ::oDb:NOMBRE ) ;
      HEADERS "Código"+CRLF+"Empleado","Cédula", "Nombre" ;
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
    ::oLbx:aColSizes  := {50,90,370}
    ::oLbx:aHjustify  := {2,2,2}
    ::oLbx:aJustify   := {0,1,0}
    ::oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey=VK_RETURN, EVAL(bHacer)       ,;
                               If(nKey=VK_F3    , NomLiNov( 1 )      ,;
                               If(nKey=VK_F5    , (::Editar( -1,.t. ),;
                                                   ::oLbx:SetFocus() , ::oLbx:Refresh() ),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(::bNew),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=69, EVAL(::bEditar)		 ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=86, EVAL(::bVer) 		         ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) )))))) }
    ::oLbx:ladjbrowse  := ::oLbx:lCellStyle := .f.
    ::oLbx:ladjlastcol := .t.
   MySetBrowse( ::oLbx, ::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT (oM:Barra(lAyuda,oDlg))
::oDb:Setorder(nOrd)

RETURN aMt[2]

//------------------------------------//
METHOD Editar( xRec,lNuevo,lView ) CLASS TEpl
   LOCAL oDlg, oGet := ARRAY(29), oE := Self
   LOCAL aEd := { "Nuevo Código",.f.,0,0,"",0,"",0,"",0,"" }
   LOCAL nCivi, nLabo, nLiqu, nSexo, nCCos
   DEFAULT lNuevo := .t. , lView  := .f. , xRec := 0
IF lNuevo
   If xRec == -1
      aEd := ACLONE( ::oDb:axBuffer )
      ::oDb:xBlank()
      ::oDb:EMPRESA := oApl:nEmpresa
      AEVAL( aEd, { |x,p| ::oDb:axBuffer[p] := x },3 )
      aEd := { "Nuevo Código",.f.,0,0,"",0,"",0,"" }
      Nitsx( ::oDb:CODIGO_NIT,@aEd, 3 )
      Nitsx( ::oDb:CNIT_EPS  ,@aEd, 4,5 )
      Nitsx( ::oDb:CNIT_AFP  ,@aEd, 6,7 )
      Nitsx( ::oDb:CNIT_CES  ,@aEd, 8,9 )
   Else
      ::oDb:xBlank()
      ::oDb:EMPRESA := oApl:nEmpresa
      ::oDb:TIPOCTA := "CA"
    //::oDb:SUELDOACT  := oApl:oFis:SALARIOMIN
      ::oDb:FECHASUACT := ::oDb:FECHAING  := DATE()
      ::oDb:PERIODOPAG := 2
      ::oDb:CNIT_CAJA  := oApl:oFie:CNIT_CAJA
   EndIf
      Nitsx( ::oDb:CNIT_CAJA ,@aEd,10,11 )
   xRec := -9
ELSE
   aEd[1] := "SELECT COUNT(*) FROM nomnovec "              +;
             "WHERE empresa = " + LTRIM(STR(oApl:nEmpresa))+;
              " AND codigo  = " + LTRIM(STR(::oDb:CODIGO))
   If EMPTY( Buscar( aEd[1],"CM" ) )
      xRec := -9
   EndIf
   aEd[1] := IF( lView, "Viendo", "Modificando" ) + " Código"
   Nitsx( ::oDb:CODIGO_NIT,@aEd, 3 )
   Nitsx( ::oDb:CNIT_EPS  ,@aEd, 4,5 )
   Nitsx( ::oDb:CNIT_AFP  ,@aEd, 6,7 )
   Nitsx( ::oDb:CNIT_CES  ,@aEd, 8,9 )
   Nitsx( ::oDb:CNIT_CAJA ,@aEd,10,11 )
ENDIF
nCivi := ArrayValor( ::aCivi,::oDb:ESTADOCIV,,.t. )
nCCos := ArrayValor( ::aCCos,::oDb:CENCOS   ,,.t. )
nLabo := ArrayValor( ::aLabo,::oDb:ESTADOLAB,,.t. )
nLiqu := ArrayValor( ::aLiqu,::oDb:TIPOLIQ  ,,.t. )
nSexo := ArrayValor( ::aSexo,::oDb:SEXO     ,,.t. )

DEFINE DIALOG oDlg TITLE aEd[1] FROM 0, 0 TO 370, 560 PIXEL //OF oApl:oWnd
   @  02, 00 SAY "Cédula"    OF oDlg RIGHT PIXEL SIZE 50,10
   @  02, 52 BTNGET oGet[1] VAR aEd[3] OF oDlg PICTURE "9999999999";
      ACTION EVAL({|| If(oE:oCC:Mostrar(), (aEd[3] := oE:oCC:oDb:CODIGO,;
                         oGet[1]:Refresh() ),) })                       ;
      VALID EVAL( {|| oE:Buscar( aEd[3],oDlg ) })                       ;
      SIZE 48,12 PIXEL UPDATE  RESOURCE "BUSCAR" ;
      WHEN xRec == -9
   @  02,164 SAY "Código"    OF oDlg RIGHT PIXEL SIZE 60,10
   @  02,228 SAY oGet[02] VAR ::oDb:CODIGO OF oDlg PICTURE "999";
      SIZE 18,10 PIXEL
   @  14, 00 SAY "Nombre"    OF oDlg RIGHT PIXEL SIZE 50,10
   @  14, 52 GET oGet[03] VAR ::oDb:NOMBRE  OF oDlg PICTURE "@!";
      VALID !EMPTY(::oDb:NOMBRE)  SIZE 130,10 PIXEL UPDATE
   @  26, 00 SAY "EN Mision" OF oDlg RIGHT PIXEL SIZE 50,10
   @  26, 52 COMBOBOX oGet[04] VAR nCCos ITEMS ArrayCol( ::aCCos,1 );
     SIZE 146,99 OF oDlg PIXEL WHEN xRec == -9
   @  38, 00 SAY "Sexo"      OF oDlg RIGHT PIXEL SIZE 50,10
   @  38, 52 COMBOBOX oGet[05] VAR nSexo ITEMS ArrayCol( ::aSexo,1 );
      SIZE 50,99 OF oDlg PIXEL
   @  14,200 SAY "Libreta Militar" OF oDlg PIXEL SIZE 60,10
   @  26,200 GET oGet[06] VAR ::oDb:LIBRETA   OF oDlg PICTURE "@K!X";
      SIZE 40,10 PIXEL
   @  38,116 SAY "Clase"     OF oDlg RIGHT PIXEL SIZE 24,10
   @  38,142 GET oGet[07] VAR ::oDb:LIBRETACL OF oDlg PICTURE "@K!X";
      SIZE 10,10 PIXEL
   @  38,158 SAY "Distrito"  OF oDlg RIGHT PIXEL SIZE 40,10
   @  38,200 GET oGet[08] VAR ::oDb:LIBRETADT OF oDlg PICTURE "@K!X";
      SIZE 24,10 PIXEL
   @  50, 00 SAY "Lugar Nac" OF oDlg RIGHT PIXEL SIZE 50,10
   @  50, 52 GET oGet[09] VAR ::oDb:LUGARNAC  OF oDlg PICTURE "@K!X";
      SIZE 66,10 PIXEL
   @  50,138 SAY "Fecha Nac" OF oDlg RIGHT PIXEL SIZE 60,10
   @  50,200 GET oGet[10] VAR ::oDb:FECHANAC OF oDlg SIZE 40,10 PIXEL
   @  62, 00 SAY "Estado Civil" OF oDlg RIGHT PIXEL SIZE 50,10
   @  62, 52 COMBOBOX oGet[11] VAR nCivi ITEMS ArrayCol( ::aCivi,1 );
      SIZE 50,99 OF oDlg PIXEL
   @  62,116 SAY "Nro.Hijos" OF oDlg RIGHT PIXEL SIZE 24,10
   @  62,142 GET oGet[12] VAR ::oDb:NROHIJOS  OF oDlg PICTURE "99";
      SIZE 20,10 PIXEL
   @  62,168 SAY "Profesion" OF oDlg RIGHT PIXEL SIZE 30,10
   @  62,200 GET oGet[13] VAR ::oDb:PROFESION OF oDlg PICTURE "@K!X";
      SIZE 66,10 PIXEL
   @  74, 00 SAY "Salario Básico" OF oDlg RIGHT PIXEL SIZE 50,10
   @  74, 52 GET oGet[14] VAR ::oDb:SUELDOACT OF oDlg PICTURE "999,999,999";
      SIZE 50,10 PIXEL
   @  74,138 SAY "Fecha Actual" OF oDlg RIGHT PIXEL SIZE 60,10
   @  74,200 GET oGet[15] VAR ::oDb:FECHASUACT OF oDlg SIZE 40,10 PIXEL
   @  86, 00 SAY "Sueldo Anterior" OF oDlg RIGHT PIXEL SIZE 50,10
   @  86, 52 GET oGet[16] VAR ::oDb:SUELDOANT OF oDlg PICTURE "999,999,999";
      SIZE 50,10 PIXEL
   @  86,138 SAY "Fecha Anterior" OF oDlg RIGHT PIXEL SIZE 60,10
   @  86,200 GET oGet[17] VAR ::oDb:FECHASUANT OF oDlg SIZE 40,10 PIXEL
   @  98, 00 SAY "Ocupación" OF oDlg RIGHT PIXEL SIZE 50,10
   @  98, 52 GET oGet[18] VAR ::oDb:OCUPACION OF oDlg PICTURE "@K!X";
      SIZE 66,10 PIXEL
   @  98,138 SAY "Fecha Ingreso" OF oDlg RIGHT PIXEL SIZE 60,10
   @  98,200 GET oGet[19] VAR ::oDb:FECHAING  OF oDlg SIZE 40,10 PIXEL
// @  98,138 CHECKBOX oGet[5] VAR ::oDb:SINDICATO PROMPT "&Sindicato" OF oDlg ;
//    SIZE 60,12 PIXEL
   @ 110, 00 SAY "Tipo Liq." OF oDlg RIGHT PIXEL SIZE 50,10
   @ 110, 52 COMBOBOX oGet[20] VAR nLiqu ITEMS ArrayCol( ::aLiqu,1 );
     SIZE 50,99 OF oDlg PIXEL
   @ 110,138 SAY "Periodo Pago" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 110,200 GET oGet[21] VAR ::oDb:PERIODOPAG OF oDlg PICTURE "9";
     SIZE 20,10 PIXEL
   @ 122, 00 SAY "Estado Laboral" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 122, 52 COMBOBOX oGet[22] VAR nLabo ITEMS ArrayCol( ::aLabo,1 );
     SIZE 50,99 OF oDlg PIXEL
   @ 122,138 SAY "Fecha Estado" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 122,200 GET oGet[23] VAR ::oDb:FECHAEST  OF oDlg SIZE 40,10 PIXEL
   @ 134,138 SAY "Fecha Fin Vac." OF oDlg RIGHT PIXEL SIZE 60,10
   @ 134,200 GET oGet[24] VAR ::oDb:FECHAVAC  OF oDlg SIZE 40,10 PIXEL
   @ 146, 00 SAY "Tipo Cuenta" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 146, 52 GET oGet[25] VAR ::oDb:TIPOCTA   OF oDlg PICTURE "@!" SIZE 24,10 PIXEL
   @ 146,138 SAY "Cuenta"      OF oDlg RIGHT PIXEL SIZE 60,10
   @ 146,200 GET oGet[26] VAR ::oDb:CTACTE    OF oDlg PICTURE "@K!X";
     SIZE 60,10 PIXEL
   @ 162, 80 BUTTON oGet[27] PROMPT "FONDOS"   SIZE 44,12 OF oDlg ACTION;
      ( ::oDb:NIVELARP := If( lNuevo, ::aCCos[nCCos,3], ::oDb:NIVELARP),;
        ::Fondos( @aEd ), oGet[28]:SetFocus() ) PIXEL
   @ 162,130 BUTTON oGet[28] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION;
      (If( EMPTY(::oDb:CODIGO_NIT) .OR. EMPTY(::oDb:NOMBRE)    ,;
         (MsgStop("No se puede grabar este EMPLEADO, debe completar datos"),;
          oGet[1]:SetFocus()), (aEd[2] := .t., oDlg:End()) )) PIXEL
   @ 162,180 BUTTON oGet[29] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
   IF lView                     // Solo Consulta
      DesactivaALLGET(oGet)
      oGet[28]:Disable()
      oGet[29]:Enable()
      oGet[29]:SetFocus()
   ENDIF
ACTIVATE DIALOG oDlg CENTER
If aEd[2]
   ::oDb:SEXO      := ::aSexo[nSexo,2]
   ::oDb:ESTADOCIV := ::aCivi[nCivi,2]
   ::oDb:CENCOS    := ::aCCos[nCCos,2]
   ::oDb:TIPOLIQ   := ::aLiqu[nLiqu,2]
   ::oDb:ESTADOLAB := ::aLabo[nLabo,2]
   If ::oDb:NIVELARP == 0
      ::oDb:NIVELARP := ::aCCos[nCCos,3]
   EndIf
   If !::oDb:EPS
       ::oDb:CNIT_EPS := 0
   EndIf
   If !::oDb:AFP
       ::oDb:CNIT_AFP := 0
   EndIf
   ::Guardar( lNuevo )
   If lNuevo
      ::oDb:Seek( {"empresa",oApl:nEmpresa,"codigo",::oDb:CODIGO} )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Buscar( nCod,oDlg ) CLASS TEpl
   LOCAL aRes, cQry, hRes, lSi, nRow
If (lSi := ::oCC:oDb:Seek( {"Codigo",nCod} ))
   cQry := "SELECT e.codigo, c.nombre FROM nomemple e, cencosto c "  +;
           "WHERE e.empresa    = " + LTRIM(STR(oApl:nEmpresa))       +;
            " AND e.codigo_nit = " + LTRIM(STR(::oCC:oDb:CODIGO_NIT))+;
            " AND c.cencos = e.cencos ORDER BY e.codigo"
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nRow := MSNumRows( hRes )
   cQry := ""
   While nRow > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      cQry += STR(aRes[1],5) + " = " + aRes[2] + CRLF
      nRow --
   EndDo
   MSFreeResult( hRes )
   If !EMPTY( cQry )
      MsgStop( cQry,TRANSFORM( nCod,"9,999,999,999" )+" Está en las Misiones" )
   EndIf
   ::oDb:NOMBRE     := ::oCC:oDb:NOMBRE
   ::oDb:CODIGO_NIT := ::oCC:oDb:CODIGO_NIT
   oDlg:Update()
Else
   MsgStop( "Está Cédula no Existe ..",TRANSFORM( nCod,"9,999,999,999" ) )
EndIf
RETURN lSi

//------------------------------------//
METHOD Fondos( aEd ) CLASS TEpl
   LOCAL oDlg, oGet := ARRAY(8), oE := Self
DEFINE DIALOG oDlg TITLE "EPS, PENSION Y CESANTIAS" FROM 0, 0 TO 150, 560 PIXEL
   @ 02, 00 SAY "Cotiza Salud" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 02, 52 CHECKBOX oGet[1] VAR ::oDb:EPS PROMPT " " OF oDlg SIZE 12,12 PIXEL
   @ 02, 70 SAY "Eps"    OF oDlg RIGHT PIXEL SIZE 20,10
   @ 02, 92 BTNGET oGet[2] VAR aEd[4] OF oDlg PICTURE "9999999999"      ;
      ACTION EVAL({|| If(oE:oCC:Mostrar(), (aEd[4] := oE:oCC:oDb:CODIGO,;
                         oGet[2]:Refresh() ),) })                       ;
      VALID EVAL( {|| If( oE:oCC:oDb:Seek( {"codigo",aEd[4]} )         ,;
                        ( aEd[5]          := oE:oCC:oDb:NOMBRE         ,;
                          oE:oDb:CNIT_EPS := oE:oCC:oDb:CODIGO_NIT     ,;
                          oDlg:Update(), .t. )                         ,;
                  (MsgStop("Este Nit ó C.C. no Existe .."), .f. )) })   ;
      SIZE 48,10 PIXEL UPDATE  RESOURCE "BUSCAR" WHEN ::oDb:EPS
   @ 02,142 SAY    aEd[5] OF oDlg PIXEL SIZE 70,10 UPDATE
   @ 14, 00 SAY "Cotiza Pensión" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 14, 52 CHECKBOX oGet[3] VAR ::oDb:AFP PROMPT " " OF oDlg SIZE 12,12 PIXEL
   @ 14, 70 SAY "Pensión"  OF oDlg RIGHT PIXEL SIZE 20,10
   @ 14, 92 BTNGET oGet[4] VAR aEd[6] OF oDlg PICTURE "9999999999"      ;
      ACTION EVAL({|| If(oE:oCC:Mostrar(), (aEd[6] := oE:oCC:oDb:CODIGO,;
                         oGet[4]:Refresh() ),) })                       ;
      VALID EVAL( {|| If( oE:oCC:oDb:Seek( {"codigo",aEd[6]} )         ,;
                        ( aEd[7]          := oE:oCC:oDb:NOMBRE         ,;
                          oE:oDb:CNIT_AFP := oE:oCC:oDb:CODIGO_NIT     ,;
                          oDlg:Update(), .t. )                         ,;
                  (MsgStop("Este Nit ó C.C. no Existe .."), .f. )) })   ;
      SIZE 48,10 PIXEL UPDATE  RESOURCE "BUSCAR" WHEN ::oDb:AFP
   @ 14,142 SAY    aEd[7] OF oDlg PIXEL SIZE 70,10 UPDATE
   @ 26, 30 SAY "Fondo Cesantia" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 26, 92 BTNGET oGet[5] VAR aEd[8] OF oDlg PICTURE "9999999999"      ;
      ACTION EVAL({|| If(oE:oCC:Mostrar(), (aEd[8] := oE:oCC:oDb:CODIGO,;
                         oGet[5]:Refresh() ),) })                       ;
      VALID EVAL( {|| If( oE:oCC:oDb:Seek( {"codigo",aEd[8]} )         ,;
                        ( aEd[9]          := oE:oCC:oDb:NOMBRE         ,;
                          oE:oDb:CNIT_CES := oE:oCC:oDb:CODIGO_NIT     ,;
                          oDlg:Update(), .t. )                         ,;
                  (MsgStop("Este Nit ó C.C. no Existe .."), .f. )) })   ;
      SIZE 48,10 PIXEL UPDATE  RESOURCE "BUSCAR"
   @ 26,142 SAY    aEd[9] OF oDlg PIXEL SIZE 70,10 UPDATE
   @ 38, 30 SAY "Caja Compensación" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 38, 92 BTNGET oGet[6] VAR aEd[10] OF oDlg PICTURE "9999999999"     ;
      ACTION EVAL({|| If(oE:oCC:Mostrar(), (aEd[10]:= oE:oCC:oDb:CODIGO,;
                         oGet[6]:Refresh() ),) })                       ;
      VALID EVAL( {|| If( oE:oCC:oDb:Seek( {"codigo",aEd[10]} )        ,;
                        ( aEd[11]          := oE:oCC:oDb:NOMBRE        ,;
                          oE:oDb:CNIT_CAJA := oE:oCC:oDb:CODIGO_NIT    ,;
                          oDlg:Update(), .t. )                         ,;
                  (MsgStop("Este Nit ó C.C. no Existe .."), .f. )) })   ;
      SIZE 48,10 PIXEL UPDATE  RESOURCE "BUSCAR"
   @ 38,142 SAY   aEd[11] OF oDlg PIXEL SIZE 70,10 UPDATE
   @ 50, 00 SAY "Clase de Riesgo" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 50, 52 COMBOBOX oGet[7] VAR ::oDb:NIVELARP ITEMS ::aNive ;
      SIZE 52,99 OF oDlg PIXEL
   @ 58,140 BUTTON oGet[8] PROMPT "&OK" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTER
RETURN NIL

//------------------------------------//
METHOD Listado() CLASS TEpl
   LOCAL aLS := { 1,CTOD(""),CTOD(""),.f. }, oDlg, oGet := ARRAY(6)
DEFINE DIALOG oDlg TITLE "ASOCIADOS" FROM 0, 0 TO 08,50
   @ 02, 00 SAY "EN Mision" OF oDlg RIGHT PIXEL SIZE 30,10
   @ 02, 32 COMBOBOX oGet[1] VAR aLS[1] ITEMS ArrayCol( ::aCCos,1 );
     SIZE 150,99 OF oDlg PIXEL
   @ 14, 00 SAY "FECHA INICIAL"    OF oDlg RIGHT PIXEL SIZE 80,10
   @ 14, 82 GET oGet[2] VAR aLS[2] OF oDlg SIZE 40,10 PIXEL
   @ 26, 00 SAY "FECHA FINAL"      OF oDlg RIGHT PIXEL SIZE 80,10
   @ 26, 82 GET oGet[3] VAR aLS[3] OF oDlg ;
      VALID aLS[3] >= aLS[2] SIZE 40,10 PIXEL
   @ 26,130 CHECKBOX oGet[4] VAR aLS[4] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,12 PIXEL
   @ 40, 50 BUTTON oGet[5] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[5]:Disable(), ::Telefono( aLS ), oGet[5]:Enable(),;
        oGet[5]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 40,100 BUTTON oGet[6] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 46, 02 SAY "[NOMEMPLE]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN NIL

//------------------------------------//
METHOD Telefono( aLS ) CLASS TEpl
   LOCAL aNS, cQry, hRes, nL, oRpt
cQry := "SELECT e.codigo, n.codigo, e.nombre, e.sueldoact, e.cencos"+;
             ", e.fechaing, e.cnit_eps, e.cnit_afp, e.cnit_ces "    +;
        "FROM nomemple e LEFT JOIN cadclien n "            +;
         "USING( codigo_nit ) "                            +;
        "WHERE e.empresa    = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND e.estadolab <> 'R'" +    If( aLS[1] == 1, "",;
         " AND e.cencos     = '" +::aCCos[aLS[1],2] + "'" )
If !EMPTY( aLS[2] )
 cQry += " AND e.fechaing  >= " + xValToChar( aLS[2] )     +;
         " AND e.fechaing  <= " + xValToChar( aLS[3] )
EndIf
cQry +=  " ORDER BY e.cencos, n.codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   RETURN NIL
EndIf
aNS := { nL,"",0,"",0,"",0,"" }
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"LISTADO DE ASOCIADOS","",;
         "Nro.de CEDULA  NOMBRE   DEL   ASOCIADO          CODIGO  B A S I C O FEC.INGRESO"},aLS[4] )
While nL > 0
   cQry := MyReadRow( hRes )
   AEVAL( cQry, { | xV,nP | cQry[nP] := MyClReadCol( hRes,nP ) } )
   Nitsx( cQry[7],@aNS,3,4 )
   Nitsx( cQry[8],@aNS,5,6 )
   Nitsx( cQry[9],@aNS,7,8 )
   oRpt:Titulo( 79 )
   If aNS[2]  # cQry[5] .AND. VAL(cQry[5]) > 0
      aNS[2] := cQry[5]
      oRpt:Say( oRpt:nL++,01,ArrayValor( ::aCCos,aNS[2],,.f. ) )
   EndIf
   oRpt:Say(  oRpt:nL,00,TRANSFORM(cQry[2],"9,999,999,999") )
   oRpt:Say(  oRpt:nL,15,cQry[3] )
   oRpt:Say(  oRpt:nL,48,STR(cQry[1],6) )
   oRpt:Say(  oRpt:nL,56,TRANSFORM(cQry[4],"999,999,999") )
   oRpt:Say(  oRpt:nL,68,NtChr( cQry[6],"2" ) )
   oRpt:Say(++oRpt:nL,08,"EPS-"+LEFT(aNS[4],14) )
   oRpt:Say(++oRpt:nL,08,"PEN-"+LEFT(aNS[6],14) )
   oRpt:Say(  oRpt:nL,48,"CES-"+LEFT(aNS[8],14) )
   oRpt:nL ++
   nL --
EndDo
MSFreeResult( hRes )
oRpt:Say( oRpt:nL++,10,REPLICATE("_",62) )
oRpt:Say( oRpt:nL  ,10,"TOTAL EMPLEADOS ESTE LISTADO...." + STR( aNS[1],4 ) )
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
FUNCTION Nitsx( nNit,aEd,nPC,nPN )
If nNit > 0
   oApl:oNit:Seek( {"codigo_nit",nNit} )
   If aEd # NIL
      aEd[nPC] := oApl:oNit:CODIGO
      If nPN # NIL
         aEd[nPN] := oApl:oNit:NOMBRE
      EndIf
   Else
      aEd := TRANSFORM( oApl:oNit:CODIGO,"9,999,999,999" )
   EndIf
EndIf
RETURN aEd
