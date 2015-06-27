// Programa.: NOMDBASE.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Modulo para la creacion de el diccionario de datos

MEMVAR oApl

FUNCTION Diccionario( cTabla,xDbf )
   LOCAL aStruct, aIndice := {}, nI, oTb
   LOCAL cLogica := " unsigned zerofill NOT NULL default '0'"
do Case
Case cTabla == "nomcausa"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "secuencia" , "N", 05, 00, },;
                { "descripcio", "C", 40, 00, },;
                { "cuenta"    , "C", 10, 00, },;
                { "db_cr"     , "N", 01, 00, },;
                { "tabla"     , "C", 15, 00, },;
                { "identifica", "C", 20, 00, },;
                { "proceso"   , "C",256, 00, },;
                { "ptaje"     , "N", 09, 05, } }
Case cTabla == "nomcauci"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "secuencia" , "N", 05, 00, },;
                { "concepto"  , "N", 03, 00, } }
Case cTabla == "nomconce"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "tabla"     , "N", 02, 00, },;
                { "concepto"  , "N", 03, 00, },;
                { "nombre"    , "C", 22, 00, },;
                { "clasepd"   , "N", 01, 00, },;
                { "cuenta"    , "C", 10, 00, },;
                { "ptaje"     , "N", 06, 02, },;
                { "salario"   , "L", 01, 00, cLogica},;
                { "caja"      , "L", 01, 00, cLogica},;
                { "primas"    , "L", 01, 00, cLogica},;
                { "vacaciones", "L", 01, 00, cLogica},;
                { "cesantias" , "L", 01, 00, cLogica},;
                { "retencion" , "L", 01, 00, cLogica},;
                { "brutoneto" , "C", 01, 00, },;
                { "formaliq"  , "N", 01, 00, },;
                { "automatica", "L", 01, 00, cLogica},;
                { "acumuladia", "L", 01, 00, cLogica},;
                { "rutina"    , "C", 20, 00, },;
                { "libroaux"  , "L", 01, 00, cLogica} }
   aIndice := { { "Concepto", { "concepto" } },;
                { "Nombre"  , { "nombre" } } }
Case cTabla == "nomdesfi"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "codigo"    , "N", 03, 00, },;
                { "concepto"  , "N", 03, 00, },;
                { "valorinic" , "N", 13, 02, },;
                { "saldoact"  , "N", 13, 02, },;
                { "cuotadesc" , "N", 13, 02, },;
                { "valorcargo", "N", 13, 02, },;
                { "fechainic" , "D", 08, 00, },;
                { "tipodesc"  , "C", 01, 00, },;
                { "formadesc" , "N", 01, 00, },;
                { "hacerdesc" , "L", 01, 00, cLogica},;
                { "fechacomp" , "D", 08, 00, } }
   aIndice := { { "Codigo"  , { "empresa","codigo","concepto" } },;
                { "Concepto", { "empresa","concepto","codigo" } } }
Case cTabla == "nomemple"
   aStruct := { { "empresa"   , "N", 02, 00, },;
                { "codigo"    , "N", 03, 00, " auto_increment" },;
                { "codigo_nit", "N", 05, 00, },;
                { "sucursal"  , "C", 03, 00, },;
                { "primer_ap" , "C", 15, 00, },;
                { "segun_ap"  , "C", 15, 00, },;
                { "nombre"    , "C", 30, 00, },;
                { "basico"    , "N", 12, 02, },;
                { "integral"  , "L", 01, 00, cLogica},;
                { "pro_pen"   , "C", 30, 00, },;
                { "apo_pat"   , "N", 10, 00, },;
                { "apo_emp"   , "N", 10, 00, },;
                { "entra"     , "N", 01, 00, },;
                { "fecha_ing" , "D", 08, 00, },;
                { "eps"       , "C", 30, 00, },;
                { "libreta"   , "C", 10, 00, },;
                { "libreta_cl", "C", 01, 00, },;
                { "libreta_dt", "C", 02, 00, },;
                { "sexo"      , "C", 01, 00, },;
                { "profesion" , "C", 20, 00, },;
                { "lugar_nac" , "C", 20, 00, },;
                { "fecha_nac" , "D", 08, 00, },;
                { "estado_civ", "C", 01, 00, },;
                { "personas_c", "N", 02, 00, },;
                { "hijos"     , "N", 02, 00, },;
                { "cen_cos"   , "N", 02, 00, },;
                { "fechasuact", "D", 08, 00, },;
                { "sueldo_ant", "N", 12, 02, },;
                { "fechasuant", "D", 08, 00, },;
                { "ocupacion" , "C", 20, 00, },;
                { "tipo_liq"  , "C", 01, 00, },;
                { "sindicato" , "L", 01, 00, cLogica},;
                { "periodopag", "N", 01, 00, },;
                { "fecha_vac" , "D", 08, 00, },;
                { "estado_lab", "C", 01, 00, },;
                { "fecha_est" , "D", 08, 00, },;
                { "ctacte"    , "C", 14, 00, },;
                { "fecfin_vac", "D", 08, 00, },;
                { "dias_est"  , "N", 01, 00, },;
                { "cotiza_sal", "N", 01, 00, },;
                { "cotiza_pen", "N", 01, 00, },;
                { "cesantias" , "C", 30, 00, },;
                { "tipocta"   , "C", 02, 00, },;
                { "PRIMARY KEY (empresa, codigo)", "P",,,} }
   aIndice := { { "Nombre", { "grupo","pos" } } }
Case cTabla == "nomfijos"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "sucursal"  , "C", 03, 00, },;
                { "municipio" , "C", 30, 00, },;
                { "cod_mun"   , "C", 03, 00, },;
                { "depto"     , "C", 30, 00, },;
                { "cod_dep"   , "C", 02, 00, },;
                { "trab_indep", "N", 01, 00, },;
                { "cob_salud" , "C", 08, 00, },;
                { "por_saludt", "N", 06, 03, },;
                { "por_salude", "N", 06, 03, },;
                { "por_pensit", "N", 06, 03, },;
                { "por_pensie", "N", 06, 03, },;
                { "por_r_prof", "N", 06, 03, },;
                { "por_fon"   , "N", 06, 03, },;
                { "tasa"      , "N", 06, 03, },;
                { "minimo"    , "N", 12, 02, },;
                { "patronal"  , "C", 11, 00, },;
                { "rp_iss"    , "N", 01, 00, },;
                { "fecha_des" , "D", 08, 00, },;
                { "fecha_has" , "D", 08, 00, },;
                { "diasdescan", "N", 02, 00, },;
                { "veces_pago", "N", 01, 00, },;
                { "tabla"     , "N", 02, 00, },;
                { "transporte", "N", 15, 00, },;
                { "fechacierr", "D", 08, 00, },;
                { "ctacte"    , "C", 16, 00, },;
                { "minimos"   , "N", 02, 00, },;
                { "codigo_arp", "N", 05, 00, },;
                { "codigo_caj", "N", 05, 00, },;
                { "codigo_sen", "N", 05, 00, },;
                { "codigo_icb", "N", 05, 00, } }
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
                { "tipo_liq"  , "C", 01, 00, },;
                { "codigo"    , "N", 05, 00, },;
                { "clasepd"   , "N", 01, 00, },;
                { "concepto"  , "N", 03, 00, },;
                { "secuencia" , "N", 02, 00, },;
                { "valornoved", "N", 13, 02, },;
                { "forma_liq" , "N", 01, 00, },;
                { "automatica", "L", 01, 00, cLogica},;
                { "listo_chq" , "L", 01, 00, cLogica},;
                { "horas"     , "N", 06, 02, } }
   aIndice := { { "Codigo"  , { "empresa","fechahas","codigo" } },;
                { "ClasePD" , { "empresa","fechahas","codigo","clasepd","concepto" } },;
                { "Concepto", { "empresa","fechahas","clasepd","concepto" } } }
Case cTabla == "nompades"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "concepto"  , "N", 03, 00, },;
                { "perpag"    , "N", 01, 00, },;
                { "valornov"  , "N", 13, 02, },;
                { "formaliq"  , "N", 01, 00, },;
                { "fechades"  , "D", 08, 00, },;
                { "automatica", "L", 01, 00, cLogica},;
                { "basprom"   , "C", 01, 00, },;
                { "permanente", "L", 01, 00, cLogica} }
   aIndice := { { "Concepto"  , { "empresa","concepto" } } }
Case cTabla == "nomreten"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "valormay"  , "N", 13, 02, },;
                { "valormen"  , "N", 13, 02, },;
                { "valorret"  , "N", 13, 02, },;
                { "ptaje"     , "N", 06, 02, } }
   aIndice := { { "Valores"  , { "valormay" } } }
Case cTabla == "nomtaiss"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "salft"     , "N", 08, 03, },;
                { "penft"     , "N", 08, 03, },;
                { "issft"     , "N", 08, 03, },;
                { "salct"     , "N", 08, 03, },;
                { "penct"     , "N", 08, 03, },;
                { "issct"     , "N", 08, 03, },;
                { "salfe"     , "N", 08, 03, },;
                { "penfe"     , "N", 08, 03, },;
                { "issfe"     , "N", 08, 03, },;
                { "issfe"     , "N", 08, 03, },;
                { "pence"     , "N", 08, 03, },;
                { "issce"     , "N", 08, 03, },;
                { "adict"     , "N", 08, 03, } }
Case cTabla == "nomtrafi"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "concepto"  , "N", 03, 00, },;
                { "condes"    , "N", 03, 00, } }
   aIndice := { { "Concepto", { "empresa","concepto" } },;
                { "Condesto", { "empresa","condes" } } }
EndCase
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
RETURN NIL
