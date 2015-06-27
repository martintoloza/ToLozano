// Programa.: CSJTURIS.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Creacion y Manto. de Datos Personales.
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

FUNCTION Turistas()
   LOCAL oPer := TPer()
oPer:NEW()
oPer:Activate()
oPer:NEW( "FIN" )
RETURN NIL

//------------------------------------//
CLASS TPer FROM TNits

 DATA aTipoD, aSexo
 DATA oMu, oPs, oPr

 METHOD NEW( xFin ) Constructor
 METHOD Editar( xRec,lNuevo,lView,cNit )
 METHOD Mostrar( lAyuda,nOrd,cNI )
 METHOD Cambios( sMsj,nBtn,oGet,lNew )
 METHOD Listado()
ENDCLASS

//------------------------------------//
METHOD NEW( xFin ) CLASS TPer
If xFin == NIL
   Super:New( oApl:oTur )
   ::aOrden := { {"<None> "  ,1,.f.},{"Dociden"  ,"dociden",.f.},;
                 {"Nombres"  ,"nombres",.f.} }
       //        {"Apellido" ,"CONCAT(apellidos,' ', nombres)",.f.},;
   ::aTipoD := ArrayCombo( "TIPODOC" )
   ::aSexo  := ArrayCombo( "SEXO" )
   //::cLista := "dociden, apellidos, nombres, nro_histor"
   ::xVar   := SPACE(15)
   ::oMu    := TRip() ; ::oMu:New( 1 )
   ::oPs    := TRip() ; ::oPs:New( 7 )
   ::oPr    := TRip() ; ::oPr:New( 4 )
Else
   ::oMu:oDb:Destroy()
   ::oPs:oDb:Destroy()
   ::oPr:oDb:Destroy()
EndIf
RETURN NIL

//------------------------------------//
METHOD Mostrar( lAyuda,nOrd,cNI ) CLASS TPer
   LOCAL oDlg, oM := Self
   LOCAL cTit := "Ayuda de Datos Personales", bHacer, lReturn := NIL
   DEFAULT lAyuda := .t. , nOrd := 2, cNI := ""
If lAyuda
   bHacer  := {|| ::lBuscar := lReturn := .t., oDlg:End()}
   lReturn := .f.
ELSE
   bHacer  := ::bEditar
   cTit    := "Datos Personales"
ENDIF
nOrd := ::Ordenar( nOrd )
If !EMPTY( cNI )
   ::oDb:Seek( {"dociden",cNI} )
EndIf

DEFINE DIALOG oDlg FROM 3, 3 TO 22, 68 TITLE cTit
   @ 1.5,.5 LISTBOX ::oLbx FIELDS    ;
                    ::oDb:DOCIDEN   ,;
          OEMTOANSI(::oDb:NOMBRES)   ;
      HEADERS "Documento"+CRLF+"Identidad","Apellidos y Nombres" ;
      SIZES 400, 450 SIZE 250,107 ;
      OF oDlg UPDATE              ;
      ON DBLCLICK EVAL(bHacer)
    ::oLbx:nClrBackHead  := oApl:nClrBackHead
    ::oLbx:nClrForeHead  := oApl:nClrForeHead
    ::oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    ::oLbx:nClrBackFocus := oApl:nClrBackFocus
    ::oLbx:nClrForeFocus := oApl:nClrForeFocus
    ::oLbx:GoTop()
    ::oLbx:oFont      := ::oFont
    ::oLbx:nHeaderHeight := 28
    ::oLbx:aColSizes  := {75,300}
    ::oLbx:aHjustify  := {2,2}
    ::oLbx:aJustify   := {0,0}
    ::oLbx:lCellStyle := ::oLbx:ladjbrowse := .f.
    ::oLbx:ladjlastcol:= .t.
    ::oLbx:bKeyChar := {|nKey,nFlags| ::cBus := ::BuscaInc( nKey ), oDlg:Update() }
    ::oLbx:bKeyDown := {|nKey| If(nKey=VK_RETURN, EVAL(bHacer),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(::bNew),;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=69, EVAL(::bEditar)	 ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=86, EVAL(::bVer) 		 ,;
                               If(GetKeyState(VK_CONTROL) .AND. nKey=76, EVAL(::bBuscar),) )))) }
   MySetBrowse( ::oLbx,::oDb )

   @ 8.7,1 SAY ::aOrden[ ::nOrden,1 ] + ": " + ::cBus ;
          OF oDlg UPDATE COLOR CLR_BLACK, NIL SIZE 390,18 FONT ::oFont
ACTIVATE DIALOG oDlg CENTER ON INIT ( oM:Barra(lAyuda,oDlg) )
::oDb:Setorder(nOrd)
If lReturn # NIL .AND. lReturn
   ::oDb:Seek( {"turista_id",::oDb:TURISTA_ID} )
EndIf

RETURN lReturn

//------------------------------------//
METHOD Editar( xRec,lNuevo,lView,cNit ) CLASS TPer
   LOCAL oDlg, oGet := ARRAY(18), aH := ARRAY(8), oE := Self
   LOCAL aEd := { "Nuevo Nit ",.f. }
   DEFAULT lNuevo := .t. , lView := .f. ,;
           cNit   := ::xVar
If lNuevo
   ::oDb:xBlank()
   ::oDb:DOCIDEN  := cNit
   ::oDb:PAIS_ID  := 48
   ::oDb:RESHABIT := oApl:oEmp:RESHABIT
   ::oDb:OCUPACION:= "999"
Else
   ::oDb:Seek( {"turista_id",::oDb:TURISTA_ID} )
   aEd[1] := If( lView, "Viendo", "Modificando" ) + " Nit"
   cNit   := ::oDb:DOCIDEN
EndIf
 ::aOld := ACLONE( ::oDb:axBuffer )
 ::oMu:oDb:Seek( { "codigo" ,::oDb:RESHABIT } )
 ::oPs:oDb:Seek( { "pais_id",::oDb:PAIS_ID } )
 ::oPr:oDb:Seek( { "codigo" ,::oDb:OCUPACION} )
aH[1] := ArrayValor( ::aTipoD,::oDb:TIPOIDEN ,{|xV|::oDb:TIPOIDEN  := xV},.t. )
aH[2] := ArrayValor( ::aSexo ,::oDb:SEXO     ,{|xV|::oDb:SEXO      := xV},.t. )
aH[3] := ::oPs:oDb:CODIGO
//aH[4] := If( EMPTY(::oDb:FEC_NACIMI), ::oDb:EDAD, NtChr( ::oDb:FEC_NACIMI,"A" ) )
//aH[8] := Direcion( ::oDb )

DEFINE DIALOG oDlg TITLE aEd[1] FROM 0, 0 TO 374,570 PIXEL
   @  02, 14 SAY "Información de los Datos Personles" OF oDlg PIXEL SIZE 116,10
   @  02,178 SAY "ID." OF oDlg RIGHT PIXEL SIZE 12,10
   @  02,192 SAY ::oDb:TURISTA_ID OF oDlg BORDER SIZE 50,10 PIXEL
   @  14, 00 SAY "Documento ID" OF oDlg RIGHT PIXEL SIZE 48,10
   @  14, 50 GET oGet[1] VAR ::oDb:DOCIDEN OF oDlg                   ;
      VALID If( EMPTY( ::oDb:DOCIDEN ),                              ;
              (MsgStop("Doc.Identidad no puede quedar vacío"),.f.)  ,;
              (::oDb:DOCIDEN := LTRIM(STRTRAN(::oDb:DOCIDEN,".","")),;
               xRec := ::Buscar( ::oDb:DOCIDEN,"dociden",,lNuevo )  ,;
               If( (xRec .AND.  lNuevo) .OR.                         ;
                   (xRec .AND. !lNuevo .AND. ::oDb:DOCIDEN # cNit)  ,;
              (MsgStop("Doc.Identidad ya existe"),.f.),.t. ) ))      ;
      SIZE 65,10 PIXEL
   @  14,140 SAY "Tipo de Documento" OF oDlg RIGHT PIXEL SIZE 50,10
   @  14,192 COMBOBOX oGet[02] VAR aH[1] ITEMS ArrayCol( ::aTipoD,1 );
      SIZE 50,99 OF oDlg PIXEL
   @  26, 00 SAY "Primer Apellido" OF oDlg RIGHT PIXEL SIZE 48,10
   @  26, 50 GET oGet[03] VAR ::oDb:PRI_APE OF oDlg PICTURE "@!";
      VALID ::Cambios( "1er.Apellido",4,oGet[07],.f. );
      SIZE 90,10 PIXEL
   @  26,140 SAY "Segundo Apellido" OF oDlg RIGHT PIXEL SIZE 50,10
   @  26,192 GET oGet[04] VAR ::oDb:SEG_APE OF oDlg PICTURE "@!";
      VALID ::Cambios( "",5,oGet[07],.f. );
      SIZE 88,10 PIXEL
   @  38, 00 SAY "Primer Nombre" OF oDlg RIGHT PIXEL SIZE 48,10
   @  38, 50 GET oGet[05] VAR ::oDb:PRI_NOM OF oDlg PICTURE "@!";
      VALID ::Cambios( "1er.Nombre",6,oGet[07],.f. );
      SIZE 90,10 PIXEL
   @  38,140 SAY "Segundo Nombre" OF oDlg RIGHT PIXEL SIZE 50,10
   @  38,192 GET oGet[06] VAR ::oDb:SEG_NOM OF oDlg PICTURE "@!";
      VALID ::Cambios( "",7,oGet[07],lNuevo );
      SIZE 88,10 PIXEL
   @  50, 50 SAY oGet[07] VAR ::oDb:NOMBRES OF oDlg BORDER ;
      SIZE 154,10 PIXEL
   @  62, 00 SAY "Sexo" OF oDlg RIGHT PIXEL SIZE 48,10
   @  62, 50 COMBOBOX oGet[08] VAR aH[2] ITEMS ArrayCol( ::aSexo,1 );
      SIZE 50,99 OF oDlg PIXEL
   @  62,144 SAY "Fecha Nacimiento" OF oDlg RIGHT PIXEL SIZE 50,10
   @  62,196 GET oGet[09] VAR ::oDb:FEC_NACIMI OF oDlg ;
      VALID ::Cambios( "",10,oGet[09] );
      SIZE 40,10 PIXEL
   @  74, 00 SAY "Nacionalidad" OF oDlg RIGHT PIXEL SIZE 48,10
   @  74, 50 BTNGET oGet[10] VAR aH[3] OF oDlg PICTURE "!!";
      ACTION EVAL({|| If( oE:oPs:Mostrar( .t.,3 )             ,;
                        ( aH[3]          := oE:oPs:oDb:CODIGO ,;
                          oGet[10]:Refresh() ), ) })           ;
      VALID  EVAL({|| If( oE:oPs:oDb:Seek( {"codigo",aH[3]} ) ,;
                        ( oE:oDb:PAIS_ID := oE:oPs:oDb:PAIS_ID,;
                          oDlg:Update(), .t. )                ,;
                        (MsgStop("Este Pais no Existe"),.f.) ) } );
      SIZE 30,10 PIXEL UPDATE  RESOURCE "BUSCAR"
   @  74, 84 SAY ::oPs:oDb:NOMBRE OF oDlg PIXEL SIZE 130,10 UPDATE
   @  86, 00 SAY "Resid.Habitual" OF oDlg RIGHT PIXEL SIZE 48,10
   @  86, 50 BTNGET oGet[11] VAR oE:oDb:RESHABIT OF oDlg PICTURE "99999";
      ACTION EVAL({|| If( oE:oMu:Mostrar()                    ,;
                        ( oE:oDb:RESHABIT := oE:oMu:oDb:CODIGO,;
                          oGet[11]:Refresh() ), ) })           ;
      VALID  EVAL({|| If( oE:oMu:oDb:Seek( {"codigo",oE:oDb:RESHABIT}) ,;
             (oDlg:Update(), .t.), (MsgStop("Este Municipio no Existe"),.f.) ) } );
      WHEN aH[3] == "CO"  SIZE 30,10 PIXEL UPDATE  RESOURCE "BUSCAR"
   @  86, 84 SAY ::oMu:oDb:NOMBRE OF oDlg PIXEL SIZE 100,10 UPDATE
   @  98, 00 SAY "Dirección" OF oDlg RIGHT PIXEL SIZE 48,10
   @  98, 50 GET oGet[12] VAR ::oDb:DIRECCION OF oDlg SIZE 150,10 PIXEL
//        VALID EVAL( {|| aH[8] := Direcion( ::oDb,1 ), oGet[12]:Refresh(), .t. })
   @ 110, 00 SAY "Telefono" OF oDlg RIGHT PIXEL SIZE 48,10
   @ 110, 50 GET oGet[13] VAR ::oDb:TEL_RESIDE OF oDlg SIZE 80,10 PIXEL
   @ 110,150 SAY "Tel.Celular" OF oDlg RIGHT PIXEL SIZE 40,10
   @ 110,192 GET oGet[14] VAR ::oDb:CELULAR    OF oDlg SIZE 80,10 PIXEL
   @ 122, 00 SAY "Email" OF oDlg RIGHT PIXEL SIZE 48,10
   @ 122, 50 GET oGet[15] VAR ::oDb:EMAIL OF oDlg SIZE 120,10 PIXEL
   @ 134, 00 SAY "Ocupación" OF oDlg RIGHT PIXEL SIZE 48,10
   @ 134, 50 BTNGET oGet[16] VAR oE:oDb:OCUPACION OF oDlg PICTURE "99999";
      ACTION EVAL({|| If( oE:oPr:Mostrar(), (oE:oDb:OCUPACION := oE:oPr:oDb:CODIGO,;
                          oGet[16]:Refresh(), oGet[16]:lValid(.f.) ), ) })         ;
      VALID  EVAL({|| If( oE:oPr:oDb:Seek( {"codigo",oE:oDb:OCUPACION})           ,;
             (oDlg:Update(), .t.), (MsgStop("Esta Ocupación no Existe"),.f.) ) } ) ;
      SIZE 30,10 PIXEL UPDATE  RESOURCE "BUSCAR"
   @ 134, 84 SAY ::oPr:oDb:NOMBRE OF oDlg PIXEL SIZE 200,10 UPDATE

   @ 165,100 BUTTON oGet[17] PROMPT "Grabar"   SIZE 44,14 OF oDlg ACTION;
      ( If( ::Cambios( "",1 ), (aEd[2] := .t., oDlg:End()),;
          (oGet[1]:SetFocus()))) PIXEL
    oGet[17]:cToolTip := "Graba estos Datos"
   @ 165,148 BUTTON oGet[18] PROMPT "Cancelar" SIZE 44,14 OF oDlg CANCEL;
      ACTION ( If( ::Cambios( "",2 )                        ,;
               If( MsgYesNo( "Guardar los Cambios","DESEA" ),;
                   aEd[2] := .t. , ), ), oDlg:End() ) PIXEL
    oGet[18]:cToolTip := "Regresa al menu Anterior"
   ACTIVAGET(oGet)
   IF lView                     // Solo Consulta
      DesactivaALLGET(oGet)
      oGet[17]:Disable()
      oGet[18]:Enable()
      oGet[18]:SetFocus()
   ENDIF
ACTIVATE DIALOG oDlg CENTER
If aEd[2]
   ::oDb:TIPOIDEN := ::aTipoD[aH[1],2]
   ::oDb:SEXO     :=  ::aSexo[aH[2],2]
   ::Guardar( lNuevo )
   If lNuevo
      ::oDb:Seek( {"turista_id",::oDb:TURISTA_ID} )
   EndIf
EndIf
 ::aOld := NIL
RETURN NIL

//------------------------------------//
METHOD Cambios( sMsj,nBtn,oGet,lNew ) CLASS TPer
   LOCAL lOK := .t., nFld
If oGet == NIL
   FOR nFld := 2 TO ::oDb:nFieldCount
            lOK := .f.
      If ::oDb:axBuffer[ nFld ] # ::aOld[ nFld ]
            lOK := .t.
         If EMPTY(::oDb:DOCIDEN) .OR. EMPTY(::oDb:PRI_APE) .OR.;
            EMPTY(::oDb:PRI_NOM) .OR. EMPTY(::oDb:DIRECCION)
            If nBtn == 1
               MsgStop("No es posible grabar este registro, debe completar datos" +CRLF+;
                       "Documento ID, Primer Nombre, Primer Apellido, Dirección" )
            EndIf
            lOK := .f.
         EndIf
         EXIT
      EndIf
   NEXT nFld
ElseIf nBtn == 10
   If !EMPTY( ::oDb:FEC_NACIMI )
      If DATE() <= ::oDb:FEC_NACIMI
         MsgStop("Fecha del Sistema es MENOR",">> ERROR <<")
         lOK := .f.
      ElseIf YEAR( ::oDb:FEC_NACIMI ) < 1900
         MsgStop("Año de Nacimiento es MENOR de 1900",">> ERROR <<")
         lOK := .f.
      Else
      // ::oDb:EDAD := If( !EMPTY( ::oDb:EDAD ), ::oDb:EDAD,;
      //                   NtChr( ::oDb:FEC_NACIMI,"A" ))
      // oGet:Refresh()
      EndIf
   EndIf
Else
   If !EMPTY(sMsj)
      If EMPTY(::oDb:axBuffer[ nBtn ])
         MsgStop( sMsj,">> Es obligatorio <<" )
         lOK := .f.
      EndIf
   EndIf
   If lOK
      If nBtn # 8
         sMsj := XTRIM( ::oDb:PRI_APE ) +   XTRIM( ::oDb:SEG_APE ) +;
                 XTRIM( ::oDb:PRI_NOM ) + ALLTRIM( ::oDb:SEG_NOM )
         ::oDb:axBuffer[ 8 ] := PADR( sMsj,::oDb:FieldLength(8) )
         oGet:Refresh()
      EndIf
      If lNew .AND. nBtn == 7
         sMsj := Buscar( "SELECT dociden FROM turista WHERE nombres = "+;
                         xValToChar( ::oDb:NOMBRES ),"CM",,8,,1 )
         If !EMPTY( sMsj )
            MsgStop( "ya Existe Documento ID = " + sMsj,"Este Turista" )
            lOK := .f.
         EndIf
      EndIf
   EndIf
EndIf
RETURN lOK

//------------------------------------//
METHOD Listado() CLASS TPer
   LOCAL aHis := { 0,0,.f. }, cQry, oIni
If oApl:cLocal == "LOC"
   cQry := AbrirFile( 4,"Archivo de Ventas Opticas","*.DBF" )
   If (oIni := RAT( "\", cQry )) > 0
      cQry := LEFT( cQry,oIni )
   Else
      cQry := "A:"
   EndIf
   Empresa()
   aHis[3] := .t.
   oIni := ::oDb:Recno()
   ActuCedulas( @aHis,,cQry )
   BorraFile( "REPLICA",{"DBF"} )
   ::oDb:Go(oIni):Read()
   ::oLbx:GoTop()
   ::oLbx:Refresh()
   cQry := "UPDATE cadfactu c, histocli n SET c.codigo_cli = n.codigo_cli "+;
           "WHERE c.optica     = n.optica"    +;
            " AND c.codigo_cli = n.codigo_nit"+;
            " AND c.optica = " + LTRIM(STR(oApl:nEmpresa))
   MSQuery( oApl:oMySql:hConnect,cQry )
   MSQuery( oApl:oMySql:hConnect,STRTRAN(cQry,"factu","antic") )
Else
   INI oIni FILE ".\Nit.ini"
      GET cQry    SECTION "Historia" ENTRY "Ruta"      OF oIni;
          DEFAULT "\ProyecFW\His\Datos\"
      GET aHis[2] SECTION "Historia" ENTRY "CodigoNit" OF oIni;
          DEFAULT 1
   ENDINI
   ActuCedulas( @aHis,cQry )
   SET SECTION "Historia" ENTRY "CodigoNit" TO aHis[2] OF oIni
EndIf
MsgInfo( STR(aHis[1])+" Nuevos","INSERTE" )
RETURN NIL

//------------------------------------//
FUNCTION ActuCedulas( aHis,cRut,cHis )
   LOCAL cDoc, cQry, hRes, n, nFldCount
If aHis[3]
   cHis += "HCEDULAS.DBF"
   If !FILE( cHis )
      RETURN NIL
   EndIf
   hRes := oApl:cRuta2 + "REPLICA.DBF"
   COPY FILE &(cHis) TO &(hRes)
   If !AbreDbf( "His","REPLICA",,,.f. )
      RETURN NIL
   EndIf
   cHis := "SELECT codigo_cli FROM histocli " +;
           "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
        " AND codigo_nit = [NIT]"
   nFldCount := oApl:oHis:FieldCount()
Else
   If !AbreDbf( "His","HISTORIA","HISTORIA",cRut,.t. )
      RETURN NIL
   EndIf
   His->(DBSETORDER( 5 ))
   His->(dbSeek( STR(aHis[2],6) ))
EndIf
oApl:oWnd:SetMsg( "Por FAVOR espere estoy Actualizando" )
While !His->(EOF())
   cDoc := ALLTRIM( STRTRAN( His->DOCIDEN,".","" ) )
   cQry :=    "dociden = '" + cDoc                    +;
      "' OR (apellidos = '" + ALLTRIM(His->APELLIDOS) +;
      "' AND nombres = '"   + ALLTRIM(His->NOMBRES)   + "' )"
      aHis[2] := His->CODIGO_NIT
   If aHis[3]
      If EMPTY( cDoc ) .OR. cDoc == LTRIM(STR(His->NRO_HISTOR))
         His->(dbSkip())
         LOOP
      EndIf
      If His->EXPORTAR == "C"
         cRut := Buscar( STRTRAN( cHis,"[NIT]",LTRIM(STR(aHis[2])) ),"CM",,8 )
         If !EMPTY( cRut )
            cQry := "Codigo_nit = " + LTRIM(STR(cRut))
         EndIf
      EndIf
      oApl:oWnd:SetMsg( "Row_id = "+STR(His->CODIGO_NIT) )
   EndIf
   If !oApl:oHis:Seek( cQry,"CM" )
       oApl:oHis:Seek( "dociden LIKE 'XXXXX%' LIMIT 1","CM" )
      If aHis[3] .AND. oApl:oHis:CODIGO_NIT == 0
         His->DOCIDEN := cDoc
         cQry := "INSERT INTO turista VALUES ( "
         FOR n := 1 TO nFldCount
            cRut := FieldGet( n )
            cQry += If( MyIsAutoInc( oApl:oHis:hResult,n ), 'NULL'       ,;
                    If( VALTYPE( cRut ) == "C", ( '"' + ALLTRIM(cRut) + '"' ),;
                        xValToChar( cRut,1 ) ) ) + ", "
         NEXT n
         cQry := LEFT( cQry,LEN(cQry)-2 ) + ' )'
         MSQuery( oApl:oMySql:hConnect,cQry )
         oApl:oHis:Seek( "dociden = '"+ cDoc +"'","CM" )
      Else
         oApl:oHis:TIPOIDEN  := His->TIPOIDEN  ; oApl:oHis:DOCIDEN   := cDoc
         oApl:oHis:APELLIDOS := His->APELLIDOS ; oApl:oHis:NOMBRES   := His->NOMBRES
         oApl:oHis:SEXO      := His->SEXO      ; oApl:oHis:FEC_NACIMI:= His->FEC_NACIMI
         oApl:oHis:UNIEDAD   := His->UNIEDAD   ; oApl:oHis:EDAD      := His->EDAD
         oApl:oHis:RESHABIT  := His->RESHABIT  ; oApl:oHis:ZONARESI  := His->ZONARESI
         oApl:oHis:DIRECCION := His->DIRECCION ; oApl:oHis:TEL_RESIDE:= His->TEL_RESIDE
         oApl:oHis:TEL_OFICIN:= His->TEL_OFICIN; oApl:oHis:EMAIL     := His->EMAIL
         oApl:oHis:OCUPACION := His->OCUPACION ; oApl:oHis:TIPOUSUA  := His->TIPOUSUA
         oApl:oHis:TIPOAFILI := His->TIPOAFILI ; oApl:oHis:NRO_HISTOR:= His->NRO_HISTOR
         oApl:oHis:PAPEL     := His->PAPEL     ; oApl:oHis:PNOMB     := His->PNOMB
         oApl:oHis:OPTICA    := oApl:nEmpresa  ; oApl:oHis:EXPORTAR  := "N"
         Guardar( oApl:oHis,!oApl:oHis:lOK,.t. )
      EndIf
      aHis[1] ++
   ElseIf LEFT( cQry,6 ) == "Codigo"
      oApl:oHis:TIPOIDEN  := His->TIPOIDEN  ; oApl:oHis:DOCIDEN   := cDoc
      oApl:oHis:APELLIDOS := His->APELLIDOS ; oApl:oHis:NOMBRES   := His->NOMBRES
      oApl:oHis:SEXO      := His->SEXO      ; oApl:oHis:FEC_NACIMI:= His->FEC_NACIMI
      oApl:oHis:UNIEDAD   := His->UNIEDAD   ; oApl:oHis:EDAD      := His->EDAD
      oApl:oHis:RESHABIT  := His->RESHABIT  ; oApl:oHis:ZONARESI  := His->ZONARESI
      oApl:oHis:DIRECCION := His->DIRECCION ; oApl:oHis:TEL_RESIDE:= His->TEL_RESIDE
      oApl:oHis:TEL_OFICIN:= His->TEL_OFICIN; oApl:oHis:EMAIL     := His->EMAIL
      oApl:oHis:OCUPACION := His->OCUPACION ; oApl:oHis:TIPOUSUA  := His->TIPOUSUA
      oApl:oHis:TIPOAFILI := His->TIPOAFILI ; oApl:oHis:NRO_HISTOR:= His->NRO_HISTOR
      oApl:oHis:PAPEL     := His->PAPEL     ; oApl:oHis:PNOMB     := His->PNOMB
      Guardar( oApl:oHis,.f.,.f. )
   EndIf
   If aHis[3] .AND. aHis[2] # oApl:oHis:CODIGO_NIT
      hRes := If( MSQuery( oApl:oMySql:hConnect,STRTRAN( cHis,"[NIT]",LTRIM(STR(aHis[2])) ) ),;
                  MSStoreResult( oApl:oMySql:hConnect ), 0 )
      If MSNumRows( hRes ) == 0
            //Row_id, Optica, Codigo_nit, Codigo_cli
         cQry := "INSERT INTO histocli VALUES( null, "    +;
                  LTRIM(STR(oApl:nEmpresa))        + ", " +;
                  LTRIM(STR(     His->CODIGO_NIT)) + ", " +;
                  LTRIM(STR(oApl:oHis:CODIGO_NIT)) + " )"
         Guardar( cQry,"histocli" )
      EndIf
      MSFreeResult( hRes )
   EndIf
   His->(dbSkip())
EndDo
His->(dbCloseArea())
RETURN NIL
/*
//------------------------------------//
FUNCTION Direcion( o,lCap )
   LOCAL cDir, oDlg, oGet
If lCap # nil
   cDir := { { " ","A","B","C","D","E","F","G","H","I","J","K","L","M"  ,;
               "N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z" },;
             { " ","BIS","SUR","ESTE","OESTE","1","2","3","4","5","6","7","8","9" } }
   oGet := ARRAY(9)
   DEFINE DIALOG oDlg TITLE "DIRECCION" FROM 2,02 TO 10,60
      @ 02, 04 SAY "CL         25       A        BIS           No.   48       F         SUR          -  100";
         OF oDlg PIXEL SIZE 220,10
      @ 16, 02 COMBOBOX oGet[1] VAR o:CALLE ITEMS { " ","CL","CR","TR","DG","AV" };
         SIZE 23,99 OF oDlg PIXEL
      @ 16, 27 GET oGet[2] VAR o:NUMERO1 OF oDlg PICTURE "999" SIZE 20,12 PIXEL
      @ 16, 49 COMBOBOX oGet[3] VAR o:LADO1 ITEMS cDir[1] ;
         SIZE 20,99 OF oDlg PIXEL
      @ 16, 71 COMBOBOX oGet[4] VAR o:CARDINAL1 ITEMS cDir[2] ;
         SIZE 34,99 OF oDlg PIXEL
      @ 16,107 SAY "No." OF oDlg PIXEL SIZE 12,12
      @ 16,121 GET oGet[5] VAR o:NUMERO2 OF oDlg PICTURE "999" SIZE 20,12 PIXEL
      @ 16,143 COMBOBOX oGet[6] VAR o:LADO2     ITEMS cDir[1] ;
         SIZE 20,99 OF oDlg PIXEL
      @ 16,165 COMBOBOX oGet[7] VAR o:CARDINAL2 ITEMS cDir[2] ;
         SIZE 34,99 OF oDlg PIXEL
      @ 16,201 SAY "-" OF oDlg PIXEL SIZE 08,12
      @ 16,208 GET oGet[8] VAR o:NUMERO3 OF oDlg PICTURE "999" SIZE 20,12 PIXEL
      @ 36, 90 BUTTON oGet[9] PROMPT "&OK"       SIZE 44,12 OF oDlg ;
         ACTION oDlg:End() PIXEL
      ACTIVAGET(oGet)
   ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
EndIf
cDir := XTRIM( o:CALLE )   +   XTRIM( o:NUMERO1 ) +;
        XTRIM( o:LADO1 )   + ALLTRIM( o:CARDINAL1 )
cDir += If( EMPTY( cDir ), "", " No. " )          +;
        XTRIM( o:NUMERO2 ) + XTRIM( o:LADO2 )     +;
        XTRIM( o:CARDINAL2 )                      +;
        If( EMPTY( o:NUMERO3 ), "", " - " )       + ALLTRIM( o:NUMERO3 )
RETURN cDir*/