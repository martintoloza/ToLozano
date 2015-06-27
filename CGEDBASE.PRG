// Programa.: CGEDBASE.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Modulo para la creacion de el diccionario de datos

MEMVAR oApl

FUNCTION Diccionario( cTabla,xDbf )
   LOCAL aStruct, aIndice := {}, nI, oTb
   LOCAL cLogica := " unsigned zerofill NOT NULL default '0'"
do Case
/*
   DEFINE TABLE CADEMPRE ALIAS EMP  NORECYCLE CONVERT DOS
      DEFINE FIELD FEC_HOY    TYP D LEN   8
      DEFINE FIELD EMPRESA    TYP N LEN   2
      DEFINE FIELD LOCALIZ    TYP C LEN   3
      DEFINE FIELD NIT        TYP C LEN  16
      DEFINE FIELD NOMBRE     TYP C LEN  35
      DEFINE FIELD ENLINEA    TYP L LEN   1
      DEFINE FIELD DIRECCION  TYP C LEN  30
      DEFINE FIELD CIUDAD     TYP C LEN  12
      DEFINE FIELD CTACTE     TYP C LEN  14
      DEFINE FIELD TABLAISS   TYP N LEN   2
      DEFINE FIELD FECHADES   TYP D LEN   8
      DEFINE FIELD FECHAHAS   TYP D LEN   8
      DEFINE FIELD VECESPAGO  TYP N LEN   1
      DEFINE FIELD DIASDESCAN TYP N LEN   2
      DEFINE FIELD TIPOLIQ    TYP C LEN   1
      DEFINE FIELD SUELDOMIN  TYP N LEN  15,2
      DEFINE FIELD TRANSPORTE TYP N LEN  15,2
    DEFINE INDEX LOCALIZ      TAG Localiz
    DEFINE INDEX EMPRESA      TAG Empresa*/
Case cTabla == "cadclien"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "N", 12, 00, },;
                { "digito"    , "N", 01, 00, },;
                { "tipocod"   , "N", 01, 00, },;
                { "nombre"    , "C", 35, 00, },;
                { "telefono"  , "C", 16, 00, },;
                { "fax"       , "C", 08, 00, },;
                { "direccion" , "C", 40, 00, },;
                { "email"     , "C", 30, 00, },;
                { "codigo_ciu", "C", 05, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "sector"    , "N", 02, 00, },;
                { "por_dscto" , "N", 05, 02, } }
   aIndice := { { "Codigo"    , { "codigo" } },;
                { "Nombre"    , { "nombre" } } }
Case cTabla == "cadcombo"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "tipo"      , "C", 10, 00, },;
                { "desplegar" , "C", 30, 00, },;
                { "retornar"  , "C", 02, 00, } }
Case cTabla == "chequesc"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "fecha"     , "D", 08, 00, },;
                { "banco"     , "C", 02, 00, },;
                { "cta_cte"   , "C", 10, 00, },;
                { "cheque"    , "N", 10, 00, },;
                { "codigonit" , "N", 05, 00, },;
                { "servicio"  , "C", 10, 00, },;
                { "valorb"    , "N", 12, 02, },;
                { "comprobant", "N", 06, 00, },;
                { "estado"    , "N", 01, 00, } }
   aIndice := { { "Cheque", {"empresa","banco","cta_cte","cheque"} } }
Case cTabla == "chequesd"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "comprobant", "N", 06, 00, },;
                { "orden"     , "N", 02, 00, },;
                { "valor"     , "N", 14, 02, } }
   aIndice := { { "Comprobant", {"empresa","comprobant"} } }
Case cTabla == "chequesv"
   aStruct := "CREATE VIEW chequesv AS "    +;
              "SELECT c.empresa, c.fecha, c.banco, c.cta_cte, c.cheque, n.nombre "+;
              "FROM chequesc c, cadclien n "+;
              "WHERE (c.codigonit = n.codigo_nit)"
Case cTabla == "cgeacumc"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "ano_mes"   , "C", 06, 00, },;
                { "cuenta"    , "C", 10, 00, },;
                { "valor_deb" , "N", 17, 02, },;
                { "valor_cre" , "N", 17, 02, } }
   aIndice := { { "Cuenta" , {"empresa","cuenta","ano_mes"} } }
Case cTabla == "cgeacumn"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "ano_mes"   , "C", 06, 00, },;
                { "cuenta"    , "C", 10, 00, },;
                { "codigo"    , "C", 10, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "valor_deb" , "N", 17, 02, },;
                { "valor_cre" , "N", 17, 02, },;
                { "valor_ret" , "N", 17, 02, } }
   aIndice := { { "Cuenta"   , {"empresa","cuenta","codigo","codigo_nit","ano_mes"} },;
                { "CodigoNit", {"empresa","codigo_nit","cuenta","ano_mes"} } }
Case cTabla == "cgeajust"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "fuente"    , "N", 02, 00, },;
                { "cuenta"    , "C", 10, 00, },;
                { "cuenta_db" , "C", 10, 00, },;
                { "cuenta_cr" , "C", 10, 00, },;
                { "porcentaje", "N", 06, 02, },;
                { "codigo"    , "C", 10, 00, } }
   aIndice := { { "Fuente", {"fuente"} } }
Case cTabla == "cgeanexo"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "cuenta"    , "C", 10, 00, },;
                { "codigo"    , "N", 10, 00, },;
                { "codvar"    , "C", 10, 00, },;
                { "nombre"    , "C", 40, 00, },;
                { "valor"     , "N", 17, 02, },;
                { "nivel"     , "N", 01, 00, } }
//   aIndice := { { "Cuenta", {"cuenta","codigo", "codvar"} } }
Case cTabla == "cgeauxil"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "cuenta"    , "C", 10, 00, },;
                { "codigo"    , "B", 12, 00, },;
                { "codvar"    , "C", 10, 00, },;
                { "fecha"     , "D", 08, 00, },;
                { "fuente"    , "N", 02, 00, },;
                { "comprobant", "N", 06, 00, },;
                { "concepto"  , "C", 40, 00, },;
                { "infa"      , "C", 10, 00, },;
                { "infb"      , "C", 10, 00, },;
                { "infc"      , "C", 10, 00, },;
                { "infd"      , "C", 10, 00, },;
                { "valor_deb" , "N", 17, 02, },;
                { "valor_cre" , "N", 17, 02, },;
                { "codigo_nit", "N", 05, 00, },;
                { "nombre"    , "C", 42, 00, },;
                { "pnombre"   , "C", 42, 00, },;
                { "db_cr"     , "N", 01, 00, } }
   aIndice := { { "Cuenta", {"cuenta","codigo","codvar","fecha"} } }
Case cTabla == "cgecntrl"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "ano_mes"   , "C", 06, 00, },;
                { "control"   , "N", 06, 00, },;
                { "compro_prv", "N", 06, 00, },;
                { "control_in", "N", 06, 00, },;
                { "control_de", "N", 06, 00, },;
                { "contro_not", "N", 06, 00, },;
                { "cierre"    , "L", 01, 00, cLogica } }
   aIndice := { { "Control", {"empresa","ano_mes"} } }
Case cTabla == "cgemovc"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "ano_mes"   , "C", 06, 00, },;
                { "fecha"     , "D", 08, 00, },;
                { "fuente"    , "N", 02, 00, },;
                { "comprobant", "N", 06, 00, },;
                { "control"   , "N", 06, 00, },;
                { "concepto"  , "C", 40, 00, },;
                { "estado"    , "N", 01, 00, },;
                { "codigonit" , "N", 05, 00, },;
                { "valorb"    , "N", 14, 02, },;
                { "consecutiv", "N", 03, 00, } }
   aIndice := { { "Control"   , {"empresa","ano_mes","control"} },;
                { "Fuente"    , {"empresa","ano_mes","fuente","comprobant"} },;
                { "Fecha"     , {"empresa","ano_mes","fecha"} }  ,;
                { "Comprobant", {"empresa","fuente","comprobant"} } }
Case cTabla == "cgemovd"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "ano_mes"   , "C", 06, 00, },;
                { "control"   , "N", 06, 00, },;
                { "cuenta"    , "C", 10, 00, },;
                { "infa"      , "C", 10, 00, },;
                { "infb"      , "C", 10, 00, },;
                { "infc"      , "C", 10, 00, },;
                { "infd"      , "C", 10, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "valor_deb" , "N", 17, 02, },;
                { "valor_cre" , "N", 17, 02, },;
                { "ptaje"     , "N", 07, 02, } }
   aIndice := { { "Control"   , {"empresa","ano_mes","control"} },;
                { "Cuenta"    , {"empresa","cuenta","ano_mes"} } }
Case cTabla == "cgeplan"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "cuenta"    , "C", 10, 00, },;
                { "nivel"     , "N", 01, 00, },;
                { "nombre"    , "C", 40, 00, },;
                { "infa"      , "C", 10, 00, },;
                { "infb"      , "C", 10, 00, },;
                { "infc"      , "C", 10, 00, },;
                { "infd"      , "C", 10, 00, },;
                { "pagos_terc", "L", 01, 00, cLogica },;
                { "db_cr"     , "N", 01, 00, },;
                { "estado"    , "N", 01, 00, } }
   aIndice := { { "Cuenta"    , {"empresa","cuenta"} },;
                { "Nombre"    , {"nombre"} } }
Case cTabla == "cgesocio"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "porcentaje", "N", 06, 02, } }
   aIndice := { { "Empresa", {"empresa","codigo_nit"} } }
Case cTabla == "cgevaria"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "tipo"      , "C", 01, 00, },;
                { "cuenta"    , "C", 10, 00, },;
                { "codigo"    , "C", 10, 00, },;
                { "nombre"    , "C", 30, 00, } }
   aIndice := { { "Cuenta", {"empresa","cuenta","codigo"} },;
                { "Nombre", {"nombre"} } }
Case cTabla == "mediosmg"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "conce"     , "N", 04, 00, },;
                { "td"        , "C", 02, 00, },;
                { "nit"       , "C", 10, 00, },;
                { "dv"        , "C", 01, 00, },;
                { "apellido1" , "C", 30, 00, },;
                { "apellido2" , "C", 30, 00, },;
                { "nombre1"   , "C", 30, 00, },;
                { "nombre2"   , "C", 30, 00, },;
                { "razonso"   , "C", 40, 00, },;
                { "direccion" , "C", 40, 00, },;
                { "dpto"      , "C", 02, 00, },;
                { "mcp"       , "C", 03, 00, },;
                { "valor_deb" , "N", 14, 02, },;
                { "valor_cre" , "N", 14, 02, },;
                { "retencion" , "N", 14, 02, } }
Case cTabla == "menudbf" .OR. cTabla == "menucge"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "grupo"     , "N", 02, 00, },;
                { "Nivel"     , "N", 02, 00, },;
                { "pos"       , "N", 02, 00, },;
                { "submenu"   , "L", 01, 00, cLogica },;
                { "finsubmenu", "L", 01, 00, cLogica },;
                { "item"      , "C", 40, 00, },;
                { "accion"    , "C", 40, 00, },;
                { "mensaje"   , "C", 60, 00, },;
                { "prompt"    , "C", 20, 00, },;
                { "acelerador", "C", 03, 00, },;
                { "tecla"     , "C", 03, 00, } }
   aIndice := { { "Posicion", { "grupo","pos" } } }
Case cTabla == "nocausac"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "secuencia" , "N", 05, 00, },;
                { "nombre"    , "C", 40, 00, },;
                { "cuenta"    , "C", 10, 00, },;
                { "db_cr"     , "N", 01, 00, },;
                { "tabla"     , "C", 15, 00, },;
                { "identifica", "C", 20, 00, },;
                { "procedimie", "C", 20, 00, },;
                { "ptaje"     , "N", 04, 05, },;
                { "verbasico" , "N", 01, 00, } }
Case cTabla == "nocausad"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "secuencia" , "N", 05, 00, },;
                { "concepto"  , "N", 03, 00, } }
Case cTabla == "nomcambc"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "fechahas"  , "D", 08, 00, },;
                { "codigo"    , "N", 05, 00, } }
Case cTabla == "nomcambd"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "fechahas"  , "D", 08, 00, },;
                { "codigo"    , "N", 05, 00, },;
                { "clasepd"   , "N", 01, 00, },;
                { "concepto"  , "N", 03, 00, },;
                { "valornoved", "N", 12, 02, },;
                { "horas"     , "N", 05, 01, },;
                { "formaliq"  , "N", 01, 00, } }
   aIndice := { { "Codigo"    , { "empresa","fechahas","codigo" } } }
Case cTabla == "nomconce"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "concepto"  , "N", 03, 00, },;
                { "nombre"    , "C", 22, 00, },;
                { "clasepd"   , "N", 01, 00, },;
                { "cuenta"    , "C", 10, 00, },;
                { "ptaje"     , "N", 06, 02, },;
                { "salario"   , "L", 01, 00, cLogica },;
                { "caja"      , "L", 01, 00, cLogica },;
                { "primas"    , "L", 01, 00, cLogica },;
                { "vacaciones", "L", 01, 00, cLogica },;
                { "cesantias" , "L", 01, 00, cLogica },;
                { "retencion" , "L", 01, 00, cLogica },;
                { "gsalario"  , "L", 01, 00, cLogica },;
                { "formaliq"  , "N", 01, 00, },;
                { "automatica", "L", 01, 00, cLogica },;
                { "acumuladia", "L", 01, 00, cLogica },;
                { "rutina"    , "C", 20, 00, },;
                { "libroaux"  , "L", 01, 00, cLogica } }
   aIndice := { { "Concepto"  , { "concepto" } },;
                { "Nombre"    , { "nombre" } } }
Case cTabla == "nomdesfi"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "codigo"    , "N", 05, 00, },;
                { "concepto"  , "N", 03, 00, },;
                { "anomes"    , "C", 07, 00, },;
                { "valorinic" , "N", 13, 02, },;
                { "saldoact"  , "N", 13, 02, },;
                { "cuotadesc" , "N", 13, 02, },;
                { "valorcargo", "N", 13, 02, },;
                { "fechainic" , "D", 08, 00, },;
                { "tipodesc"  , "C", 01, 00, },;
                { "formadesc" , "N", 01, 00, },;
                { "hacerdesc" , "L", 01, 00, cLogica },;
                { "fechacomp" , "D", 08, 00, } }
   aIndice := { { "Codigo"    , { "empresa","codigo","concepto" } },;
                { "Concepto"  , { "empresa","concepto","codigo" } } }
Case cTabla == "nomemple"
   aStruct := { { "empresa"   , "N", 02, 00, },;
                { "codigo"    , "N", 05, 00, " auto_increment" },;
                { "nombre"    , "C", 40, 00, },;
                { "libreta"   , "C", 10, 00, },;
                { "libretacl" , "C", 01, 00, },;
                { "libretadt" , "C", 02, 00, },;
                { "sexo"      , "C", 01, 00, },;
                { "profesion" , "C", 20, 00, },;
                { "lugarnac"  , "C", 20, 00, },;
                { "fechanac"  , "D", 08, 00, },;
                { "estadociv" , "C", 01, 00, },;
                { "personasc" , "N", 02, 00, },;
                { "nrohijos"  , "N", 02, 00, },;
                { "cencos"    , "C", 02, 00, },;
                { "sueldoact" , "N", 12, 00, },;
                { "fechasuact", "D", 08, 00, },;
                { "sueldoant" , "N", 12, 00, },;
                { "fechasuant", "D", 08, 00, },;
                { "ocupacion" , "C", 10, 00, },;
                { "tipoliq"   , "C", 01, 00, },;
                { "sindicato" , "L", 01, 00, cLogica },;
                { "periodopag", "N", 01, 00, },;
                { "fechaing"  , "D", 08, 00, },;
                { "fechavac"  , "D", 08, 00, },;
                { "estadolab" , "C", 01, 00, " default 'A'" },;
                { "fechaest"  , "D", 08, 00, },;
                { "dias_est"  , "N", 03, 00, },;
                { "tipocta"   , "C", 02, 00, },;
                { "ctacte"    , "C", 14, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "eps"       , "L", 01, 00, cLogica },;
                { "cnit_eps"  , "N", 05, 00, },;
                { "afp"       , "L", 01, 00, cLogica },;
                { "cnit_afp"  , "N", 05, 00, },;
                { "cnit_ces"  , "N", 05, 00, },;
                { "nivelarp"  , "N", 01, 00, " default 1" },;
                { "PRIMARY KEY (empresa, codigo)", "P",,,} }
   aIndice := { { "Nombre"    , { "nombre" } } }
Case cTabla == "nomemplv"
   aStruct := "CREATE VIEW nomemplv AS "    +;
              "SELECT c.empresa, c.cencos, c.codigo, c.nombre, n.codigo cedula"+;
              "FROM nomemple c, cadclien n "+;
              "WHERE (c.codigo_nit = n.codigo_nit)"
Case cTabla == "nomfijoe"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "sucursal"  , "C", 03, 00, },;
                { "reshabit"  , "C", 05, 00, },;
                { "trab_indep", "N", 01, 00, },;
                { "cob_salud" , "C", 08, 00, },;
                { "por_r_prof", "N", 06, 03, },;
                { "tasa"      , "N", 06, 03, },;
                { "patronal"  , "C", 11, 00, },;
                { "rp_iss"    , "L", 01, 00, cLogica },;
                { "fecha_des" , "D", 08, 00, },;
                { "fecha_has" , "D", 08, 00, },;
                { "fechacierr", "D", 08, 00, },;
                { "diasdescan", "N", 02, 00, },;
                { "veces_pago", "N", 01, 00, },;
                { "tabla"     , "N", 02, 00, },;
                { "ctacte"    , "C", 16, 00, },;
                { "minimos"   , "N", 02, 00, },;
                { "cnit_arp"  , "N", 05, 00, },;
                { "cnit_caja" , "N", 05, 00, },;
                { "cnit_sena" , "N", 05, 00, },;
                { "cnit_icbf" , "N", 05, 00, } }
Case cTabla == "nomfijos"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "issfami"   , "C", 01, 00, " default 'F'" },;
                { "periodoi"  , "N", 06, 00, },;
                { "periodof"  , "N", 06, 00, },;
                { "salariomin", "N", 14, 02, },;
                { "transporte", "N", 14, 02, },;
                { "eps_emp"   , "N", 08, 03, },;
                { "eps_tra"   , "N", 08, 03, },;
                { "eps_fon"   , "N", 08, 03, },;
                { "afp_emp"   , "N", 08, 03, },;
                { "afp_tra"   , "N", 08, 03, },;
                { "afp_fon"   , "N", 08, 03, },;
                { "fsp_min"   , "N", 04, 00, },;
                { "fsp_fon"   , "N", 08, 03, },;
                { "arp_fon"   , "N", 08, 03, },;
                { "caja"      , "N", 08, 03, },;
                { "icbf"      , "N", 08, 03, },;
                { "sena"      , "N", 08, 03, },;
                { "piva"      , "N", 06, 02, } }
Case cTabla == "nomfsp"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "valori"    , "N", 05, 00, },;
                { "valorf"    , "N", 05, 00, },;
                { "ptaje"     , "N", 03, 04, },;
                { "ano_mesi"  , "C", 06, 00, },;
                { "ano_mesf"  , "C", 06, 00, } }
Case cTabla == "nomnovec"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "fechahas"  , "D", 08, 00, },;
                { "codigo"    , "N", 05, 00, },;
                { "radio"     , "N", 01, 00, } }
Case cTabla == "nomnoved"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "fechahas"  , "D", 08, 00, },;
                { "codigo"    , "N", 05, 00, },;
                { "clasepd"   , "N", 01, 00, },;
                { "concepto"  , "N", 03, 00, },;
                { "valornoved", "N", 12, 02, },;
                { "horas"     , "N", 05, 01, },;
                { "formaliq"  , "N", 01, 00, } }
   aIndice := { { "Codigo"    , { "empresa","fechahas","codigo" } },;
                { "ClasePD"   , { "empresa","fechahas","codigo","clasepd","concepto" } },;
                { "Concepto"  , { "empresa","fechahas","clasepd","concepto" } } }
Case cTabla == "nompades"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "concepto"  , "N", 03, 00, },;
                { "perpag"    , "N", 01, 00, },;
                { "valornov"  , "N", 12, 02, },;
                { "formaliq"  , "N", 01, 00, },;
                { "fechahas"  , "D", 08, 00, },;
                { "automatica", "L", 01, 00, cLogica },;
                { "basprom"   , "C", 01, 00, },;
                { "permanente", "L", 01, 00, cLogica } }
   aIndice := { { "Concepto"  , { "empresa","concepto" } } }
Case cTabla == "nomreten"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "valormay"  , "N", 12, 02, },;
                { "valormen"  , "N", 12, 02, },;
                { "valorret"  , "N", 12, 02, },;
                { "ptaje"     , "N", 06, 02, } }
Case cTabla == "nomtrafi"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "concepto"  , "N", 03, 00, },;
                { "condes"    , "N", 03, 00, } }
   aIndice := { { "Concepto"  , { "empresa","concepto" } },;
                { "ConDesto"  , { "empresa","condes" } } }
Case cTabla == "CODIGOS"       //DBF
   aStruct := { { "VITRINA"   , "C", 03, 00 },;
                { "CODIGO"    , "C", 12, 00 },;
                { "VALOR"     , "C", 11, 00 } }
EndCase
If VALTYPE( aStruct ) == "C"
   MSQuery( oApl:oMySql:hConnect,aStruct )
   oApl:oDb:GetTables()
Else
   If VALTYPE( xDbf ) == "C"
      If LEFT( xDbf,5 ) == "movto"
         aIndice:= {}
         cTabla := xDbf
         xDbf   := nil
      EndIf
   EndIf
   If xDbf == nil
      oTb := TMSTable():Create( oApl:oMySql, cTabla, aStruct )
      FOR nI := 1 TO LEN( aIndice )
         If aIndice[nI,1] == "PrimaryKey"
            oTb:CreatePrimaryKey( aIndice[nI,2] )
         ElseIf aIndice[nI,1] == "Constraint"
            MSQuery( oApl:oMySql:hConnect,aIndice[nI,2] )
         Else
            oTb:CreateIndex( aIndice[nI,1],aIndice[nI,2], .f. )
         EndIf
      NEXT nI
      oTb:Destroy()
   Else
      BorraFile( cTabla,{"DBF"} )
      dbCREATE( oApl:cRuta2+cTabla,aStruct )
   EndIf
EndIf
RETURN NIL
