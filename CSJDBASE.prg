// Programa.: CSJDBASE.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Modulo para la creacion de el diccionario de datos

MEMVAR oApl

FUNCTION Diccionario( cTabla,xDbf,cTB )
   LOCAL aStruct, aIndice := {}, nI, oTb
   LOCAL cLogica := " unsigned zerofill NOT NULL default '0'"
//Para los campos con decimales aumentar el entero + decimales
do Case
 Case cTabla == "actclase"
   aStruct := { { "clase_id"  , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "clase"     , "C", 01, 00, },;
                { "grupo"     , "C", 04, 00, },;
                { "nombre"    , "C", 60, 00, },;
                { "vutil"     , "N", 02, 00, },;
                { "vifrs"     , "N", 02, 00, },;
                { "conse"     , "N", 07, 00, } }
 Case cTabla == "actfijos"
   aStruct := { { "fijos_id"  , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "clase_id"  , "N", 11, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "codigo"    , "C", 10, 00, },;
                { "nombre"    , "C", 60, 00, },;
                { "marca"     , "C", 20, 00, },;
                { "modelo"    , "C", 20, 00, },;
                { "serial"    , "C", 20, 00, },;
                { "conse"     , "N", 07, 00, } }
   aIndice := { { "actfijos_FKIndex1", { "clase_id" } } }
Case cTabla == "cadajust"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "numero"    , "N", 10, 00, },;
                { "fecha"     , "D", 08, 00, },;
                { "codigo"    , "C", 10, 00, },;
                { "cantidad"  , "N", 09, 02, },;
                { "unidadmed" , "C", 02, 00, },;
                { "tipo"      , "N", 01, 00, " default 1" },;
                { "pcosto"    , "N", 12, 02, },;
                { "pventa"    , "N", 12, 02, },;
                { "tipoajust" , "C", 01, 00, },;
                { "row_salid" , "N", 11, 00, } }
   aIndice := { { "Periodo", { "empresa","fecha","numero" } } }
//                { "Codigo" , { "empresa","codigo", "fecha" } } }
Case cTabla == "cadarque"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "codigo"    , "C", 10, 00, },;
                { "anomes"    , "C", 06, 00, },;
                { "cantidad"  , "N", 15, 05, },;
                { "vitrina"   , "C", 10, 00, } }
   aIndice := { { "Codigo" , { "empresa", "codigo", "anomes" } },;
                { "Periodo", { "empresa", "anomes", "vitrina" } } }
Case cTabla == "cadartic"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "ingreso"   , "N", 06, 00, },;
                { "fecingre"  , "D", 08, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "factura"   , "C", 10, 00, },;
                { "subtotal"  , "N", 12, 02, },;
                { "totaldes"  , "N", 12, 02, },;
                { "totalfle"  , "N", 12, 02, },;
                { "totaliva"  , "N", 12, 02, },;
                { "totalica"  , "N", 12, 02, },;
                { "totalret"  , "N", 12, 02, },;
                { "totalcre"  , "N", 12, 02, },;
                { "totalfac"  , "N", 12, 02, },;
                { "secuencia" , "N", 06, 00, },;
                { "comprobant", "N", 06, 00, } }
   aIndice := { { "Ingreso", {"ingreso"} } ,;
                { "Fecha"  , {"fecingre,ingreso"} } }
Case cTabla == "cadartid"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "ingreso"   , "N", 06, 00, },;
                { "codigo"    , "C", 10, 00, },;
                { "cantidad"  , "N", 09, 02, },;
                { "unidadmed" , "C", 02, 00, },;
                { "pcosto"    , "N", 12, 02, },;
                { "pventa"    , "N", 12, 02, },;
                { "ppubli"    , "N", 12, 02, },;
                { "despor"    , "N", 08, 02, },;
                { "secuencia" , "N", 06, 00, },;
                { "indica"    , "C", 01, 00, },;
                { "indiva"    , "L", 01, 00, cLogica } }
   aIndice := { { "Ingreso", {"ingreso"} } }
Case cTabla == "cadartiv"
   aStruct := "CREATE VIEW cadartiv AS "    +;
              "SELECT c.empresa, c.fecingre, c.ingreso, c.factura, n.nombre "+;
              "FROM cadartic c, cadclien n "+;
              "WHERE (c.codigo_nit = n.codigo_nit)"
Case cTabla == "cadbanco"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 02, 00, },;
                { "nombre"    , "C", 30, 00, },;
                { "debito"    , "N", 06, 02, },;
                { "credito"   , "N", 06, 02, },;
                { "en_espera" , "L", 01, 00, cLogica } }
   aIndice := { { "Codigo", {"codigo"} } ,;
                { "Nombre", {"nombre"} } }
 Case cTabla == "cadclien"
   aStruct := { { "codigo_nit", "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "tipocod"   , "N", 01, 00, },;
                { "codigo"    , "B", 12, 00, },;
                { "digito"    , "N", 01, 00, },;
                { "pri_ape"   , "C", 25, 00, },;
                { "seg_ape"   , "C", 25, 00, },;
                { "pri_nom"   , "C", 25, 00, },;
                { "seg_nom"   , "C", 25, 00, },;
                { "nombre"    , "C",100, 00, },;
                { "direccion" , "C", 40, 00, },;
                { "email"     , "C", 40, 00, },;
                { "codigo_ciu", "C", 05, 00, },;
                { "codpais"   , "C", 03, 00, " default '169'"},;
                { "natura"    , "C", 06, 00, },;
                { "actecon"   , "C", 06, 00, },;
                { "toperet"   , "L", 01, 00, cLogica },;
                { "retenedor" , "L", 01, 00, cLogica },;
                { "grancontr" , "L", 01, 00, cLogica },;
                { "pica"      , "N", 06, 02, },;
                { "piva"      , "N", 06, 02, },;
                { "pcree"     , "N", 06, 02, } }
   aIndice := { { "Codigo", {"codigo"} } ,;
                { "Nombre", {"nombre"} } }
Case cTabla == "cadcombo"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "tipo"      , "C", 10, 00, },;
                { "desplegar" , "C", 30, 00, },;
                { "retornar"  , "C", 02, 00, } }
   aIndice := { { "TipoComb", {"tipo"} } }
Case cTabla == "cadcotic"
   aStruct := { { "empresa"   , "N", 02, 00, },;
                { "numero"    , "N", 10, 00, " auto_increment" },;
                { "fecha"     , "D", 08, 00, },;
                { "cliente"   , "C", 30, 00, },;
                { "orden"     , "C", 20, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "fechaent"  , "D", 08, 00, },;
                { "totaldes"  , "N", 12, 02, },;
                { "totaliva"  , "N", 12, 02, },;
                { "totalfac"  , "N", 12, 02, },;
                { "indicador" , "C", 01, 00, },;
                { "clase"     , "N", 01, 00, },;
                { "numfac"    , "N", 10, 00, },;
                { "PRIMARY KEY (empresa, numero)", "P",,,} }
   aIndice := { { "Fecha"  , {"empresa","fecha","numero"} },;
                { "Cliente", {"cliente"} } }
Case cTabla == "cadcotid"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "numero"    , "N", 10, 00, },;
                { "codigo"    , "C", 10, 00, },;
                { "unidadmed" , "C", 02, 00, },;
                { "cantidad"  , "N", 08, 02, },;
                { "precioven" , "N", 12, 02, },;
                { "despor"    , "N", 06, 02, },;
                { "desmon"    , "N", 12, 02, },;
                { "montoiva"  , "N", 12, 02, },;
                { "ppubli"    , "N", 12, 02, },;
                { "pcosto"    , "N", 12, 02, },;
                { "indicador" , "C", 01, 00, } }
   aIndice := { { "Factura", {"empresa","numero"} } }
Case cTabla == "caddevoc"
   aStruct := { { "empresa"   , "N", 02, 00, },;
                { "numero"    , "N", 10, 00, " auto_increment" },;
                { "fecha"     , "D", 08, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "factura"   , "C", 10, 00, },;
                { "subtotal"  , "N", 14, 02, },;
                { "totaliva"  , "N", 14, 02, },;
                { "totalica"  , "N", 14, 02, },;
                { "totalret"  , "N", 14, 02, },;
                { "totalfac"  , "N", 14, 02, },;
                { "comprobant", "N", 06, 00, },;
                { "secuencia" , "N", 06, 00, },;
                { "PRIMARY KEY (empresa, numero)", "P",,,} }
   aIndice := { { "Devolucion", { "empresa","numero" } },;
                { "Fecha"     , { "empresa","fecha" } } }
Case cTabla == "caddevod"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "numero"    , "N", 10, 00, },;
                { "codigo"    , "C", 10, 00, },;
                { "unidadmed" , "C", 02, 00, },;
                { "cantidad"  , "N", 10, 02, " default 1"},;
                { "pcosto"    , "N", 14, 02, },;
                { "causadev"  , "N", 01, 00, " default 1"},;
                { "secuencia" , "N", 06, 00, } }
   aIndice := { { "Devolucion", { "empresa","numero" } } }
Case cTabla == "caddevov"
   aStruct := "CREATE VIEW caddevov AS "    +;
              "SELECT c.empresa, c.fecha, c.numero, c.factura, n.nombre "+;
              "FROM caddevoc c, cadclien n "+;
              "WHERE (c.codigo_nit = n.codigo_nit)"
Case cTabla == "cadempre"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "fec_hoy"   , "D", 08, 00, },;
                { "empresa"   , "N", 02, 00, },;
                { "puc"       , "N", 02, 00, },;
                { "localiz"   , "C", 03, 00, },;
                { "titular"   , "C", 03, 00, },;
                { "nit"       , "C", 14, 00, },;
                { "nombre"    , "C", 43, 00, },;
                { "nombre2"   , "C", 40, 00, },;
                { "reshabit"  , "C", 05, 00, },;
                { "direccion" , "C", 30, 00, },;
                { "telefono"  , "C", 16, 00, },;
                { "fax"       , "C", 16, 00, },;
                { "gerente"   , "C", 30, 00, },;
                { "cc"        , "C", 15, 00, },;
                { "contador"  , "C", 30, 00, },;
                { "tp"        , "C", 15, 00, },;
                { "piva"      , "N", 06, 02, },;
                { "enlinea"   , "L", 01, 00, cLogica },;
                { "lencod"    , "N", 02, 00, },;
                { "cartera"   , "C", 10, 00, },;
                { "nomina"    , "L", 01, 00, cLogica },;
                { "porpc"     , "L", 01, 00, cLogica },;
                { "pos"       , "C", 02, 00, },;
                { "tipofac"   , "C", 10, 00, },;
                { "prefijo"   , "C", 02, 00, },;
                { "email"     , "C", 50, 00, },;
                { "tregimen"  , "N", 01, 00, },;
                { "regimen"   , "C", 20, 00, },;
                { "ica"       , "C", 50, 00, },;
                { "numfaca"   , "N", 10, 00, },;
                { "numfacb"   , "N", 10, 00, },;
                { "numfacc"   , "N", 10, 00, },;
                { "numfacx"   , "N", 10, 00, },;
                { "numfacz"   , "N", 10, 00, },;
                { "ingreso"   , "N", 06, 00, },;
                { "egreso"    , "N", 06, 00, },;
                { "notasc"    , "N", 08, 00, },;
                { "numingreso", "N", 06, 00, },;
                { "ajustes"   , "N", 10, 00, },;
                { "pfte"      , "N", 06, 02, },;
                { "pica"      , "N", 06, 02, },;
                { "anexo"     , "L", 01, 00, cLogica },;
                { "admon"     , "L", 01, 00, cLogica },;
                { "descanso"  , "L", 01, 00, cLogica },;
                { "tactucon"  , "L", 01, 00, cLogica },;
                { "tactuinv"  , "L", 01, 00, cLogica },;
                { "filecxc"   , "C", 10, 00, },;
                { "filecxp"   , "C", 10, 00, } }
   aIndice := { { "Empresa", {"empresa"} } }
Case cTabla == "cademprf"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "tipo"      , "C", 01, 00, },;
                { "desde"     , "N", 10, 00, },;
                { "hasta"     , "N", 10, 00, },;
                { "fecha"     , "D", 08, 00, },;
                { "prefijo"   , "C", 02, 00, },;
                { "piefactu"  , "M", 10, 00, } }
Case cTabla == "cadfactc"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "numfac"    , "N", 10, 00, },;
                { "tipo"      , "C", 01, 00, },;
                { "fechoy"    , "D", 08, 00, },;
                { "cliente"   , "C", 30, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "turista_id", "N", 11, 00, },;
                { "fechaent"  , "D", 08, 00, },;
                { "fechacan"  , "D", 08, 00, },;
                { "totaldes"  , "N", 13, 02, },;
                { "totaliva"  , "N", 13, 02, },;
                { "totalfac"  , "N", 13, 02, },;
                { "llegada"   , "E", 08, 00, },;
                { "salida"    , "E", 08, 00, },;
                { "indicador" , "C", 01, 00, },;
                { "noches"    , "N", 02, 00, },;
                { "noche_ext" , "N", 02, 00, },;
                { "amigos"    , "N", 02, 00, },;
                { "retfte"    , "N", 10, 00, },;
                { "retica"    , "N", 10, 00, },;
                { "retiva"    , "N", 10, 00, },;
                { "remision"  , "N", 10, 00, },;
                { "control"   , "N", 06, 00, } }
   aIndice := { { "Factura", {"empresa","numfac","tipo"} }  ,;
                { "Fecha"  , {"empresa","fechoy","numfac"} },;
                { "Cartera", {"empresa","codigo_nit","fechoy"} } }
Case cTabla == "cadfactd"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "numfac"    , "N", 10, 00, },;
                { "tipo"      , "C", 01, 00, },;
                { "codigo"    , "C", 10, 00, },;
                { "unidadmed" , "C", 02, 00, },;
                { "cantidad"  , "N", 10, 02, },;
                { "precioven" , "N", 13, 02, },;
                { "despor"    , "N", 07, 02, },;
                { "desmon"    , "N", 12, 02, },;
                { "montoiva"  , "N", 13, 02, },;
                { "ppubli"    , "N", 13, 02, },;
                { "pcosto"    , "N", 13, 02, },;
                { "indicador" , "C", 01, 00, },;
                { "fecdev"    , "D", 08, 00, } }
   aIndice := { { "Factura", {"empresa","numfac","tipo"} } }
Case cTabla == "cadfacte"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "factc_id"  , "N", 11, 00, },;
                { "fecha_ent" , "E", 19, 00, },;
                { "fecha_sal" , "E", 19, 00, },;
                { "estado"    , "C", 01, 00, } }
   aIndice := { { "Llegada", {"fecha_ent"} } }
Case cTabla == "cadfactg"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "factc_id"  , "N", 11, 00, },;
                { "turista_id", "N", 11, 00, } }
   aIndice := { { "Grupos", {"factc_id"} } }
Case cTabla == "cadfactm"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "numfac"    , "N", 10, 00, },;
                { "tipo"      , "C", 01, 00, },;
                { "anomes"    , "C", 06, 00, },;
                { "saldo"     , "N", 13, 02, },;
                { "abonos"    , "N", 13, 02, },;
                { "debito"    , "N", 13, 02, } }
   aIndice := { { "Factura", {"empresa","numfac","tipo","anomes"} } }
Case cTabla == "cadfactv"
   aStruct := "CREATE VIEW cadfactv AS "    +;
              "SELECT c.cliente, DATE_FORMAT(e.fecha_ent,'%d.%m.%Y a las %h:%i %p') AS fecha, c.numfac "+;
              "FROM cadfactc c, cadfacte e "+;
              "WHERE c.row_id = e.factc_id "+;
                "AND e.estado = 'P'"
Case cTabla == "cadinveb"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codbarra"  , "C", 15, 00, },;
                { "codigo"    , "C", 10, 00, } }
   aIndice := { { "Codigo", { "codbarra" } } }
Case cTabla == "cadinven"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 10, 00, },;
                { "descrip"   , "C", 40, 00, },;
                { "linea"     , "C", 03, 00, },;
                { "pcosto"    , "N", 13, 02, },;
                { "pventa"    , "N", 13, 02, },;
                { "ppubli"    , "N", 13, 02, },;
                { "indiva"    , "L", 01, 00, cLogica },;
                { "impuesto"  , "N", 06, 02, },;
                { "unidadmed" , "C", 02, 00, },;
                { "ajuste_esp", "C", 01, 00, },;
                { "putil"     , "N", 06, 02, },;
                { "despor"    , "N", 06, 02, },;
                { "vitrina"   , "C", 05, 00, },;
                { "punidad"   , "N", 13, 02, },;
                { "stockm"    , "N", 10, 00, },;
                { "codcon"    , "N", 03, 00, },;
                { "marca"     , "C", 15, 00, },;
                { "referencia", "C", 30, 00, },;
                { "aplica"    , "C",255, 00, } }
   aIndice := { { "Codigo", { "codigo" } },;
                { "Nombre", { "descrip" } } }
Case cTabla == "cadinves"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 10, 00, },;
                { "codigo_sal", "C", 10, 00, },;
                { "cantid_sal", "N", 10, 02, },;
                { "unidadmed" , "C", 02, 00, } }
Case cTabla == "cadinvme"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "codigo"    , "C", 10, 00, },;
                { "anomes"    , "C", 06, 00, },;
                { "existencia", "N", 15, 05, },;
                { "entradas"  , "N", 15, 05, },;
                { "salidas"   , "N", 15, 05, },;
                { "ajustes_e" , "N", 15, 05, },;
                { "ajustes_s" , "N", 15, 05, },;
                { "fec_ulte"  , "D", 08, 00, },;
                { "fec_ults"  , "D", 08, 00, },;
                { "devol_e"   , "N", 15, 05, },;
                { "devol_s"   , "N", 15, 05, },;
                { "devolcli"  , "N", 15, 05, },;
                { "pcosto"    , "N", 12, 02, } }
   aIndice := { { "Codigo", { "empresa","codigo","anomes" } } }
 Case cTabla == "cadlinea"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "linea"     , "C", 03, 00, },;
                { "nombre"    , "C", 60, 00, },;
                { "conse"     , "N", 07, 00, } }
Case cTabla == "cadmedid"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 02, 00, },;
                { "nombre"    , "C", 15, 00, },;
                { "codcon"    , "C", 04, 00, },;
                { "nombre_con", "C", 15, 00, },;
                { "formula"   , "C", 40, 00, },;
                { "tipo"      , "C", 03, 00, } }
Case cTabla == "cadnotac"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "numero"    , "N", 08, 00, },;
                { "tipo"      , "C", 01, 00, },;
                { "fecha"     , "D", 08, 00, },;
                { "concepto"  , "C", 40, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "totaliva"  , "N", 12, 02, },;
                { "totalfac"  , "N", 13, 02, },;
                { "numfac"    , "N", 10, 00, },;
                { "pagado"    , "N", 13, 02, },;
                { "clase"     , "N", 01, 00, },;
                { "anulap"    , "L", 01, 00, cLogica } }
   aIndice := { { "Numero" , {"empresa","numero","tipo"} } }
Case cTabla == "cadnotad"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "numero"    , "N", 08, 00, },;
                { "tipo"      , "C", 01, 00, },;
                { "codigo"    , "C", 10, 00, },;
                { "unidadmed" , "C", 02, 00, },;
                { "cantidad"  , "N", 10, 02, },;
                { "precioven" , "N", 12, 02, },;
                { "montoiva"  , "N", 12, 02, },;
                { "pcosto"    , "N", 12, 02, } }
   aIndice := { { "Numero" , {"empresa","numero","tipo"} } }
Case cTabla == "cadpagos"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "numfac"    , "N", 10, 00, },;
                { "tipo"      , "C", 01, 00, },;
                { "fecpag"    , "D", 08, 00, },;
                { "abono"     , "N", 14, 02, },;
                { "pagado"    , "N", 14, 02, },;
                { "retencion" , "N", 14, 02, },;
                { "deduccion" , "N", 14, 02, },;
                { "descuento" , "N", 14, 02, },;
                { "numcheque" , "C", 22, 00, },;
                { "codbanco"  , "C", 02, 00, },;
                { "formapago" , "N", 01, 00, },;
                { "documento" , "N", 06, 00, },;
                { "tipo_pag"  , "C", 01, 00, " default 'P'"} ,;
                { "indicador" , "C", 01, 00, } }
   aIndice := { { "Factura", {"empresa","numfac","tipo"} }  ,;
                { "Fecha"  , {"empresa","fecpag","numfac"} },;
                { "NotasDC", {"empresa","fecpag","formapago"} } }
Case cTabla == "cadsaldo"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 12, 00, },;
                { "anomes_an" , "C", 06, 00, },;
                { "existe_an" , "N", 16, 05, },;
                { "pcosto_an" , "N", 12, 02, },;
                { "anomes_ac" , "C", 06, 00, },;
                { "existe_ac" , "N", 16, 05, },;
                { "pcosto_ac" , "N", 12, 02, },;
                { "descrip"   , "C", 40, 00, },;
                { "cantidad"  , "N", 16, 05, },;
                { "entradas"  , "N", 16, 05, },;
                { "salidas"   , "N", 16, 05, },;
                { "ajustes_e" , "N", 16, 05, },;
                { "ajustes_s" , "N", 16, 05, },;
                { "devol_e"   , "N", 16, 05, },;
                { "devol_s"   , "N", 16, 05, },;
                { "devolcli"  , "N", 16, 05, } }
   aIndice := { { "Codigo", {"codigo"} } }
Case cTabla == "cadtipos"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "tipo"      , "N", 02, 00, },;
                { "nombre"    , "C", 30, 00, },;
                { "tipo_ajust", "N", 01, 00, },;
                { "clase"     , "C", 10, 00, } }
   aIndice := { { "Tipo", {"tipo"} } }
Case cTabla == "cgeacumc"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "ano_mes"   , "C", 06, 00, },;
                { "cuenta"    , "C", 10, 00, },;
                { "valor_deb" , "N", 14, 02, },;
                { "valor_cre" , "N", 14, 02, } }
   aIndice := { { "Cuenta" , {"empresa","cuenta","ano_mes"} } }
Case cTabla == "cgeacumn"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "ano_mes"   , "C", 06, 00, },;
                { "cuenta"    , "C", 10, 00, },;
                { "codigo"    , "C", 10, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "valor_deb" , "N", 14, 02, },;
                { "valor_cre" , "N", 14, 02, },;
                { "valor_ret" , "N", 14, 02, } }
   aIndice := { { "Cuenta"   , {"empresa","cuenta","codigo","codigo_nit","ano_mes"} },;
                { "CodigoNit", {"empresa","codigo_nit","cuenta","ano_mes"} } }
Case cTabla == "cgeajust"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "fuente"    , "N", 02, 00, },;
                { "cuenta"    , "C", 10, 00, },;
                { "cuenta_db" , "C", 10, 00, },;
                { "cuenta_cr" , "C", 10, 00, },;
                { "porcentaje", "N", 06, 02, },;
                { "codigo"    , "C", 10, 00, } }
   aIndice := { { "Fuente", {"empresa","fuente"} } }
Case cTabla == "cgeanexo"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "cuenta"    , "C", 10, 00, },;
                { "codigo"    , "N", 12, 00, },;
                { "codvar"    , "C", 10, 00, },;
                { "nombre"    , "C", 40, 00, },;
                { "valor"     , "N", 14, 02, },;
                { "nivel"     , "N", 01, 00, } }
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
                { "valor_deb" , "N", 14, 02, },;
                { "valor_cre" , "N", 14, 02, },;
                { "codigo_nit", "N", 05, 00, },;
                { "nombre"    , "C", 42, 00, },;
                { "pnombre"   , "C", 42, 00, },;
                { "db_cr"     , "N", 01, 00, } }
   aIndice := { { "Cuenta", {"cuenta","codigo","codvar","fecha"} } }
Case cTabla == "cgebanco"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "banco"     , "C", 02, 00, },;
                { "nombre"    , "C", 30, 00, },;
                { "cta_cte"   , "C", 10, 00, },;
                { "cuenta"    , "C", 10, 00, },;
                { "num_cheque", "N", 10, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "ff"        , "N", 02, 00, },;
                { "cf"        , "N", 02, 00, },;
                { "fv"        , "N", 02, 00, },;
                { "cv"        , "N", 02, 00, },;
                { "fb"        , "N", 02, 00, },;
                { "cb"        , "N", 02, 00, },;
                { "fm"        , "N", 02, 00, },;
                { "cm"        , "N", 02, 00, },;
                { "lm"        , "N", 02, 00, },;
                { "tf"        , "N", 02, 00, },;
                { "ingreso"   , "C", 18, 00, },;
                { "egreso"    , "C", 18, 00, },;
                { "imprimo"   , "L", 01, 00, cLogica } }
Case cTabla == "cgecntrl"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "ano_mes"   , "C", 06, 00, },;
                { "control"   , "N", 06, 00, },;
                { "compro_prv", "N", 06, 00, },;
                { "control_in", "N", 06, 00, },;
                { "control_de", "N", 06, 00, },;
                { "compro_var", "N", 06, 00, },;
                { "cierre"    , "L", 01, 00, cLogica } }
   aIndice := { { "Control", {"empresa","ano_mes"} } }
Case cTabla == "cgefntes"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "fuente"    , "N", 02, 00, },;
                { "descripcio", "C", 32, 00, },;
                { "ctrl_conse", "L", 01, 00, cLogica },;
                { "imprimo"   , "L", 01, 00, cLogica },;
                { "contador"  , "C", 10, 00, },;
                { "cartera"   , "L", 01, 00, cLogica } }
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
                { "infa"      , "C", 10, 00, },;
                { "infb"      , "C", 10, 00, },;
                { "infc"      , "C", 10, 00, },;
                { "infd"      , "C", 10, 00, },;
                { "pagos_terc", "L", 01, 00, cLogica },;
                { "db_cr"     , "N", 01, 00, },;
                { "estado"    , "C", 01, 00, } }
   aIndice := { { "Cuenta", {"empresa","cuenta"} },;
                { "Nombre", {"nombre"} } }
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
                { "row_idc"   , "N", 11, 00, },;
                { "orden"     , "N", 02, 00, },;
                { "valor"     , "N", 14, 02, } }
   aIndice := { { "Comprobant", {"empresa","comprobant"} } }
Case cTabla == "chequesv"
   aStruct := "CREATE VIEW chequesv AS "    +;
              "SELECT c.empresa, c.fecha, c.banco, c.cta_cte, c.cheque, n.nombre "+;
              "FROM chequesc c, cadclien n "+;
              "WHERE (c.codigonit = n.codigo_nit)"
Case cTabla == "ciudades"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 05, 00, },;
                { "nombre"    , "C", 30, 00, } }
   aIndice := { { "Codigo", { "codigo" } },;
                { "Nombre", { "nombre" } } }
Case cTabla == "extracto"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "numfac"    , "N", 10, 00, },;
                { "tipo"      , "C", 01, 00, },;
                { "fechoy"    , "D", 08, 00, },;
                { "cliente"   , "C", 40, 00, },;
                { "valor"     , "N", 13, 02, },;
                { "debitos"   , "N", 13, 02, },;
                { "creditos"  , "N", 13, 02, } }
   aIndice := { { "Fecha", {"fechoy"} } }
Case cTabla == "fisicoc"
   aStruct := { { "fisic_id"  , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "anomes"    , "C", 06, 00, },;
                { "vitrina"   , "C", 05, 00, },;
                { "tvitrina"  , "N", 08, 00, },;
                { "fecha"     , "D", 08, 00, } }
   aIndice := { { "Periodo", { "empresa", "anomes", "vitrina" } } }
Case cTabla == "fisicod"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "fisic_id"  , "N", 11, 00, },;
                { "codigo"    , "C", 12, 00, },;
                { "unidadmed" , "C", 02, 00, },;
                { "fisico"    , "N", 10, 02, },;
                { "cantidad"  , "N", 15, 05, } }
   aIndice := { { "Codigo" , { "ifisc_id", "codigo" } } }
Case cTabla == "ingresoc"
   aStruct := { { "ingre_id"  , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "comprobant", "N", 06, 00, },;
                { "tipo"      , "C", 01, 00, },;
                { "fecha"     , "D", 08, 00, },;
                { "banco"     , "C", 02, 00, },;
                { "cta_cte"   , "C", 10, 00, },;
                { "codigonit" , "N", 05, 00, },;
                { "formapago" , "N", 01, 00, },;
                { "codigo"    , "C", 02, 00, },;
                { "documento" , "C", 10, 00, },;
                { "estado"    , "N", 01, 00, },;
                { "control"   , "N", 06, 00, } }
   aIndice := { { "Comprobant", {"empresa","comprobant"} } }
Case cTabla == "ingresod"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "ingre_id"  , "N", 11, 00, },;
                { "clasepag"  , "N", 01, 00, },;
                { "formapago" , "N", 01, 00, },;
                { "codigo"    , "C", 02, 00, },;
                { "numcheque" , "C", 16, 00, },;
                { "valorp"    , "N", 14, 02, },;
                { "dsctos"    , "N", 14, 02, },;
                { "retfte"    , "N", 14, 02, },;
                { "retiva"    , "N", 14, 02, },;
                { "retica"    , "N", 14, 02, },;
                { "comision"  , "N", 14, 02, } }
   aIndice := { { "Ingreso", {"ingre_id"} } }
Case cTabla == "ingresov"
   aStruct := "CREATE VIEW ingresov AS "    +;
              "SELECT c.empresa, c.fecha, c.banco, c.cta_cte, c.documento, c.comprobant, n.nombre "+;
              "FROM ingresoc c, cadclien n "+;
              "WHERE (c.codigonit = n.codigo_nit)"
Case cTabla == "mediosmd"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "formato"   , "N", 04, 00, },;
                { "concepto"  , "N", 04, 00, },;
                { "cuentai"   , "C", 10, 00, },;
                { "cuentaf"   , "C", 10, 00, },;
                { "ptaje"     , "N", 08, 02, },;
                { "saldo"     , "L", 01, 00, cLogica },;
                { "movto"     , "N", 01, 00, " default 3" },;
                { "restar"    , "L", 01, 00, cLogica },;
                { "columna"   , "N", 02, 00, " default 14" } }
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
                { "pais"      , "C", 03, 00, " NOT NULL default '169'" },;
                { "colum14"   , "N", 14, 02, },;
                { "colum15"   , "N", 14, 02, },;
                { "colum16"   , "N", 14, 02, },;
                { "colum17"   , "N", 14, 02, },;
                { "colum18"   , "N", 14, 02, },;
                { "colum19"   , "N", 14, 02, },;
                { "colum20"   , "N", 14, 02, },;
                { "colum21"   , "N", 14, 02, },;
                { "colum22"   , "N", 14, 02, } }
Case cTabla == "menudbf" .OR. cTabla == "menucge"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "grupo"     , "N", 02, 00, },;
                { "nivel"     , "N", 02, 00, },;
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
                { "valornoved", "N", 13, 02, },;
                { "horas"     , "N", 07, 02, },;
                { "formaliq"  , "N", 01, 00, } }
   aIndice := { { "Codigo"  , { "empresa","fechahas","codigo" } } }
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
                { "sueldoact" , "N", 14, 02, },;
                { "fechasuact", "D", 08, 00, },;
                { "sueldoant" , "N", 14, 02, },;
                { "fechasuant", "D", 08, 00, },;
                { "ocupacion" , "C", 20, 00, },;
                { "tipoliq"   , "C", 01, 00, },;
                { "sindicato" , "L", 01, 00, cLogica},;
                { "periodopag", "N", 01, 00, },;
                { "fechaing"  , "D", 08, 00, },;
                { "fechavac"  , "D", 08, 00, },;
                { "estadolab" , "C", 01, 00, " default 'A'"},;
                { "fechaest"  , "D", 08, 00, },;
                { "dias_est"  , "N", 03, 00, },;
                { "tipocta"   , "C", 02, 00, },;
                { "ctacte"    , "C", 14, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "eps"       , "L", 01, 00, cLogica},;
                { "cnit_eps"  , "N", 05, 00, },;
                { "afp"       , "L", 01, 00, cLogica},;
                { "cnit_afp"  , "N", 05, 00, },;
                { "cnit_ces"  , "N", 05, 00, },;
                { "nivelarp"  , "N", 01, 00, " default 1"},;
                { "PRIMARY KEY (empresa, codigo)", "P",,,} }
   aIndice := { { "Nombre", { "nombre" } } }
Case cTabla == "nomnovec"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "fechahas"  , "D", 08, 00, },;
                { "codigo"    , "N", 05, 00, },;
                { "radio"     , "N", 01, 00, },;
                { "notas"     , "C", 60, 00, },;
                { "fechai"    , "D", 08, 00, },;
                { "fechaf"    , "D", 08, 00, },;
                { "basico"    , "N", 12, 02, },;
                { "dias"      , "N", 07, 02, } }
Case cTabla == "nomnoved"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "fechahas"  , "D", 08, 00, },;
                { "codigo"    , "N", 05, 00, },;
                { "clasepd"   , "N", 01, 00, },;
                { "concepto"  , "N", 03, 00, },;
                { "valornoved", "N", 13, 02, },;
                { "horas"     , "N", 07, 02, },;
                { "formaliq"  , "N", 01, 00, } }
   aIndice := { { "Codigo"  , { "empresa","fechahas","codigo" } },;
                { "ClasePD" , { "empresa","fechahas","codigo","clasepd","concepto" } },;
                { "Concepto", { "empresa","fechahas","clasepd","concepto" } } }
Case cTabla == "ordenesc"
   aStruct := { { "empresa"   , "N", 02, 00, },;
                { "numero"    , "N", 10, 00, " auto_increment" },;
                { "fecha"     , "D", 08, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "comprobant", "N", 06, 00, },;
                { "PRIMARY KEY (empresa, numero)", "P",,,} }
   aIndice := { { "Fecha"  , {"empresa","fecha","numero"} } }
Case cTabla == "ordenesd"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "numero"    , "N", 10, 00, },;
                { "codigo"    , "C", 10, 00, },;
                { "unidadmed" , "C", 02, 00, },;
                { "cantidad"  , "N", 08, 02, },;
                { "pcosto"    , "N", 10, 02, },;
                { "tipo"      , "N", 01, 00, } }
   aIndice := { { "Orden"  , {"empresa","numero"} } }
Case cTabla == "promedio"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "fecha"     , "D", 08, 00, },;
                { "codigo"    , "C", 12, 00, },;
                { "cantidad"  , "N", 09, 02, },;
                { "unidadmed" , "C", 02, 00, },;
                { "pcosto"    , "N", 14, 02, },;
                { "mov"       , "N", 01, 00, },;
                { "row_vta"   , "N", 11, 00, } }
Case cTabla == "telefonos"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo_nit", "N", 05, 00, },;
                { "orden"     , "N", 02, 00, },;
                { "tipo"      , "C", 01, 00, },;
                { "numero"    , "C", 16, 00, },;
                { "extencion" , "C", 20, 00, } }
   aIndice := { { "Codigo"    , {"codigo_nit"} } }
Case cTabla == "reservac"
   aStruct := { { "id"        , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "numero"    , "N", 08, 00, },;
                { "fecha"     , "D", 08, 00, },;
                { "concepto"  , "C", 40, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "turista_id", "N", 11, 00, },;
                { "totalfac"  , "N", 13, 02, },;
                { "idcadfactc", "N", 11, 00, } }
   aIndice := { { "Numero" , {"empresa","numero"} } }
Case cTabla == "reservad"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "idreservac", "N", 11, 00, },;
                { "codigo"    , "C", 10, 00, },;
                { "cantidad"  , "N", 10, 00, },;
                { "precioven" , "N", 12, 02, } }
   aIndice := { { "Numero" , {"idreservac"} } }
//                { "Constraint",{ "ALTER TABLE reservad ADD CONSTRAINT fk_Resrva "+;
//                             "FOREIGN KEY (idreservac) REFERENCES reservac "+;
//                             "(id) ON DELETE CASCADE ON UPDATE CASCADE" } } }
Case cTabla == "turista"
   aStruct := { { "turista_id", "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "tipoiden"  , "C", 02, 00, " default 'CC'"},;
                { "dociden"   , "C", 15, 00, },;
                { "pri_ape"   , "C", 25, 00, },;
                { "seg_ape"   , "C", 25, 00, },;
                { "pri_nom"   , "C", 25, 00, },;
                { "seg_nom"   , "C", 25, 00, },;
                { "nombres"   , "C",100, 00, },;
                { "sexo"      , "C", 01, 00, " default 'M'"},;
                { "fec_nacimi", "D", 08, 00, },;
                { "pais_id"   , "N", 11, 00, },;
                { "reshabit"  , "C", 05, 00, },;
                { "direccion" , "C", 40, 00, },;
                { "tel_reside", "C", 15, 00, },;
                { "celular"   , "C", 15, 00, },;
                { "email"     , "C", 40, 00, },;
                { "ocupacion" , "C", 03, 00, " default '999'"} }
   aIndice := { { "DocIden"  , { "dociden" } } ,;
                { "Nombres"  , { "nombres" } } }
   //           { "Apellido" , { "apellidos", "nombres" } },;
Case cTabla == "vendedor"
   aStruct := { { "codigo_ven", "N", 06, 00, " auto_increment PRIMARY KEY" },;
                { "codigo_nit", "C", 05, 00, },;
                { "nombre"    , "C", 30, 00, } }
Case cTabla == "vitrinas"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 05, 00, },;
                { "nombre"    , "C", 40, 00, } }
   aIndice := { { "Codigo",  { "codigo" } },;
                { "Nombre",  { "nombre" } } }
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
      cTabla := If( cTB == nil, cTabla, cTB )
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