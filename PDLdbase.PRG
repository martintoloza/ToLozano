// Programa.: CAODBASE.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Modulo para la creacion de el diccionario de datos

MEMVAR oApl

FUNCTION Diccionario( cTabla,xDbf )
   LOCAL aStruct, aIndice := {}, nI, oTb
   LOCAL cLogica := " unsigned zerofill NOT NULL default '0'"
do Case
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
Case cTabla == "cadajust"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "documen"   , "N", 10, 00, },;
                { "fecajus"   , "D", 08, 00, },;
                { "codigo"    , "C", 10, 00, },;
                { "cantidad"  , "N", 06, 01, },;
                { "unidadmed" , "C", 02, 00, },;
                { "tipo"      , "N", 01, 00, " default 1" },;
                { "pcosto"    , "N", 10, 02, },;
                { "pventa"    , "N", 10, 02, },;
                { "tipoajust" , "C", 01, 00, },;
                { "row_salid" , "N", 11, 00, } }
   aIndice := { { "Periodo", { "empresa","fecajus","documen" } } }
//                { "Codigo" , { "empresa","codigo", "fecajus" } } }
Case cTabla == "cadarque"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "codigo"    , "C", 10, 00, },;
                { "anomes"    , "C", 06, 00, },;
                { "cantidad"  , "N", 08, 02, },;
                { "vitrina"   , "C", 03, 00, } }
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
                { "totalret"  , "N", 12, 02, },;
                { "totalfac"  , "N", 12, 02, },;
                { "secuencia" , "N", 06, 00, },;
                { "control"   , "N", 06, 00, } }
   aIndice := { { "Ingreso", {"ingreso"} } ,;
                { "Fecha"  , {"fecingre,ingreso"} } }
Case cTabla == "cadartid"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "ingreso"   , "N", 06, 00, },;
                { "codigo"    , "C", 10, 00, },;
                { "cantidad"  , "N", 08, 02, },;
                { "unidadmed" , "C", 02, 00, },;
                { "pcosto"    , "N", 10, 02, },;
                { "pventa"    , "N", 10, 02, },;
                { "ppubli"    , "N", 10, 02, },;
                { "indiva"    , "N", 01, 00, },;
                { "secuencia" , "N", 06, 00, },;
                { "indica"    , "C", 01, 00, } }
   aIndice := { { "Ingreso", {"ingreso"} } }
Case cTabla == "cadbanco"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 02, 00, },;
                { "nombre"    , "C", 30, 00, },;
                { "debito"    , "N", 05, 02, },;
                { "credito"   , "N", 05, 02, },;
                { "en_espera" , "L", 01, 00, cLogica } }
   aIndice := { { "Codigo", {"codigo"} } ,;
                { "Nombre", {"nombre"} } }
Case cTabla == "cadcajac"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "remision"  , "N", 05, 00, },;
                { "tipo"      , "C", 01, 00, },;
                { "fechoy"    , "D", 08, 00, },;
                { "cliente"   , "C", 30, 00, },;
                { "enviado"   , "C", 24, 00, },;
                { "direcci"   , "C", 30, 00, },;
                { "telefon"   , "C", 24, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "totaldes"  , "N", 10, 02, },;
                { "totaliva"  , "N", 10, 02, },;
                { "totalfac"  , "N", 11, 02, },;
                { "estado"    , "N", 01, 00, },;
                { "nota"      , "M", 10, 00, },;
                { "fechacob"  , "D", 08, 00, },;
                { "fechaent"  , "D", 08, 00, },;
                { "hora"      , "C", 05, 00, },;
                { "tomadop"   , "C", 15, 00, },;
                { "saldo"     , "N", 11, 02, },;
                { "abonos"    , "N", 11, 02, },;
                { "tipo_p"    , "C", 01, 00, },;
                { "facturado" , "C", 01, 00, },;
                { "numfac"    , "N", 10, 00, }  }
   aIndice := { { "Remision", {"fechoy","remision","tipo_p"} },;
                { "Entrega" , {"fechaent","hora"} } }
Case cTabla == "cadcajad"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "fechoy"    , "D", 08, 00, },;
                { "remision"  , "N", 05, 00, },;
                { "codigo"    , "C", 05, 00, },;
                { "cantidad"  , "N", 06, 01, },;
                { "precioven" , "N", 11, 02, },;
                { "despor"    , "N", 06, 02, },;
                { "desmon"    , "N", 10, 02, },;
                { "montoiva"  , "N", 10, 02, },;
                { "tipo_p"    , "C", 01, 00, } }
   aIndice := { { "Remision", {"fechoy","remision","tipo_p"} } }
Case cTabla == "cadcajap"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "numfac"    , "N", 10, 00, },;
                { "tipo"      , "C", 01, 00, },;
                { "fecpag"    , "D", 08, 00, },;
                { "abono"     , "N", 10, 02, },;
                { "pagado"    , "N", 11, 02, },;
                { "retencion" , "N", 10, 02, },;
                { "deduccion" , "N", 10, 02, },;
                { "descuento" , "N", 10, 02, },;
                { "numcheque" , "C", 22, 00, },;
                { "codbanco"  , "C", 02, 00, },;
                { "formapago" , "N", 01, 00, },;
                { "indicador" , "C", 01, 00, },;
                { "indred"    , "C", 01, 00, },;
                { "pordonde"  , "C", 01, 00, " default 'P'"} ,;
                { "retica"    , "N", 10, 02, },;
                { "retiva"    , "N", 10, 02, },;
                { "retfte"    , "N", 10, 02, } }
   aIndice := { { "Factura", {"fecpag","numfac"} } }
 Case cTabla == "cadcateg"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "categoria" , "N", 03, 00, },;
                { "nombre"    , "C", 40, 00, },;
                { "grupo"     , "C", 20, 00, } }
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
                { "ciudad"    , "C", 12, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "sector"    , "N", 02, 00, } }
   aIndice := { { "Codigo", {"codigo"} } ,;
                { "Nombre", {"nombre"} } ,;
                { "Codigo_nit", {"codigo_nit"} } }
Case cTabla == "cadcombo"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "tipo"      , "C", 10, 00, },;
                { "desplegar" , "C", 30, 00, },;
                { "retornar"  , "C", 02, 00, } }
   aIndice := { { "TipoComb", {"tipo"} } }
Case cTabla == "caddevoc"      //21
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"    , "N", 02, 00, },;
                { "documen"   , "N", 10, 00, },;
                { "fechad"    , "D", 08, 00, },;
                { "consedev"  , "N", 08, 00, },;
                { "nombre"    , "C", 30, 00, } }
   aIndice := { { "Devolucion", { "empresa","documen" } },;
                { "Fecha"     , { "empresa","fechad" } } }
Case cTabla == "caddevod"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"    , "N", 02, 00, },;
                { "documen"   , "N", 10, 00, },;
                { "fechad"    , "D", 08, 00, },;
                { "codigo"    , "C", 12, 00, },;
                { "cantidad"  , "N", 04, 00, " default 1"},;
                { "pcosto"    , "N", 10, 02, },;
                { "causadev"  , "N", 01, 00, " default 1"},;
                { "destino"   , "N", 02, 00, },;
                { "numfac"    , "N", 10, 00, },;
                { "facturado" , "L", 01, 00, cLogica },;
                { "indica"    , "C", 01, 00, } }
   aIndice := { { "Devolucion", { "empresa","documen" } },;
                { "Destino"   , { "destino","fechad" } } }
Case cTabla == "cadempre"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "fec_hoy"   , "D", 08, 00, },;
                { "empresa"   , "N", 02, 00, },;
                { "puc"       , "N", 02, 00, },;
                { "localiz"   , "C", 03, 00, },;
                { "titular"   , "C", 03, 00, },;
                { "nit"       , "C", 14, 00, },;
                { "nombre"    , "C", 43, 00, },;
                { "numfacu"   , "N", 10, 00, },;
                { "numfacd"   , "N", 10, 00, },;
                { "piva"      , "N", 06, 02, },;
                { "dias"      , "N", 02, 00, },;
                { "retencion" , "C", 20, 00, },;
                { "enlinea"   , "L", 01, 00, cLogica },;
                { "numingreso", "N", 06, 00, },;
                { "direccion" , "C", 30, 00, },;
                { "telefonos" , "C", 30, 00, },;
                { "gerente"   , "C", 30, 00, },;
                { "contador"  , "C", 30, 00, },;
                { "fec_rem"   , "D", 08, 00, },;
                { "remision"  , "N", 05, 00, },;
                { "pedido"    , "N", 05, 00, },;
                { "dian"      , "C",120, 00, },;
                { "nota"      , "M", 10, 00, },;
                { "ingreso"   , "N", 06, 00, },;
                { "egreso"    , "N", 06, 00, } }
   aIndice := { { "Empresa", {"empresa"} } }
Case cTabla == "cadfacth"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "numfac"    , "N", 10, 00, },;
                { "tipo"      , "C", 01, 00, },;
                { "nota"      , "M", 10, 00, } }
   aIndice := { { "Factura", {"numfac","tipo"} } }
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
Case cTabla == "cadfactu"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "numfac"    , "N", 10, 00, },;
                { "tipo"      , "C", 01, 00, },;
                { "fechoy"    , "D", 08, 00, },;
                { "cliente"   , "C", 30, 00, },;
                { "enviado_a" , "C", 24, 00, },;
                { "direcc"    , "C", 30, 00, },;
                { "telefono"  , "C", 24, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "fechaven"  , "D", 08, 00, },;
                { "fechacan"  , "D", 08, 00, },;
                { "totaldes"  , "N", 10, 02, },;
                { "totaliva"  , "N", 10, 02, },;
                { "totalfac"  , "N", 11, 02, },;
                { "cedula"    , "N", 10, 00, },;
                { "indicador" , "C", 01, 00, },;
                { "control"   , "N", 06, 00, },;
                { "fechacob"  , "D", 08, 00, },;
                { "hora"      , "C", 08, 00, } }
   aIndice := { { "Factura", {"empresa","numfac","tipo"} }  ,;
                { "Fecha"  , {"empresa","fechoy","numfac"} },;
                { "Cartera", {"empresa","codigo_nit","fechoy"} } }
Case cTabla == "cadflujo"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "fecha"     , "D", 08, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "motivo"    , "C",  30,   0} ,;
                { "tipopago"  , "N",   1,   0} ,;
                { "documen"   , "N",  10,   0} ,;
                { "valor_deb" , "N",  12,   2}  }
   aIndice := { { "Fecha", {"empresa","fecha","codigo_nit"} } }
Case cTabla == "cadinven"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 10, 00, },;
                { "descrip"   , "C", 40, 00, },;
                { "pcosto"    , "N", 10, 02, },;
                { "pventa"    , "N", 10, 02, },;
                { "ppubli"    , "N", 10, 02, },;
                { "indiva"    , "N", 01, 00, },;
                { "impuesto"  , "N", 06, 02, },;
                { "categoria" , "N", 03, 00, },;
                { "pnuevo"    , "N", 10, 02, },;
                { "listar"    , "C", 01, 00, },;
                { "unidadmed" , "C", 02, 00, },;
                { "ajuste_esp", "C", 01, 00, } }
   aIndice := { { "Codigo", { "codigo" } },;
                { "Nombre", { "descrip" } } }
Case cTabla == "cadinves"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 10, 00, },;
                { "codigo_sal", "C", 10, 00, },;
                { "cantid_sal", "N", 06, 01, } }
Case cTabla == "cadinvme"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "codigo"    , "C", 10, 00, },;
                { "anomes"    , "C", 06, 00, },;
                { "existencia", "N", 07, 01, },;
                { "entradas"  , "N", 07, 01, },;
                { "salidas"   , "N", 07, 01, },;
                { "ajustes_e" , "N", 07, 01, },;
                { "ajustes_s" , "N", 07, 01, },;
                { "fec_ulte"  , "D", 08, 00, },;
                { "fec_ults"  , "D", 08, 00, },;
                { "devol_e"   , "N", 07, 01, },;
                { "devol_s"   , "N", 07, 01, },;
                { "devolcli"  , "N", 07, 01, },;
                { "pcosto"    , "N", 10, 02, } }
   aIndice := { { "Codigo", { "empresa","codigo","anomes" } } }
Case cTabla == "cadmedid"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 02, 00, },;
                { "nombre"    , "C", 15, 00, },;
                { "codcon"    , "C", 04, 00, },;
                { "nombre_con", "C", 15, 00, },;
                { "formula"   , "C", 40, 00, },;
                { "tipo"      , "C", 03, 00, } }
Case cTabla == "cadpagos"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "numfac"    , "N", 10, 00, },;
                { "tipo"      , "C", 01, 00, },;
                { "fecpag"    , "D", 08, 00, },;
                { "abono"     , "N", 10, 02, },;
                { "pagado"    , "N", 11, 02, },;
                { "retencion" , "N", 10, 02, },;
                { "deduccion" , "N", 10, 02, },;
                { "descuento" , "N", 10, 02, },;
                { "numcheque" , "C", 22, 00, },;
                { "codbanco"  , "C", 02, 00, },;
                { "formapago" , "N", 01, 00, },;
                { "indicador" , "C", 01, 00, },;
                { "indred"    , "C", 01, 00, },;
                { "pordonde"  , "C", 01, 00, " default 'P'"} ,;
                { "retica"    , "N", 10, 02, },;
                { "retiva"    , "N", 10, 02, },;
                { "retfte"    , "N", 10, 02, } }
   aIndice := { { "Factura", {"empresa","numfac","tipo"} }  ,;
                { "Fecha"  , {"empresa","fecpag","numfac"} },;
                { "NotasDC", {"empresa","fecpag","formapago"} } }
Case cTabla == "cadsaldo"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 12, 00, },;
                { "anomes_an" , "C", 06, 00, },;
                { "existe_an" , "N", 08, 02, },;
                { "pcosto_an" , "N", 12, 02, },;
                { "anomes_ac" , "C", 06, 00, },;
                { "existe_ac" , "N", 08, 02, },;
                { "pcosto_ac" , "N", 12, 02, },;
                { "descrip"   , "C", 30, 00, },;
                { "cantidad"  , "N", 08, 02, },;
                { "entradas"  , "N", 08, 02, },;
                { "salidas"   , "N", 08, 02, },;
                { "ajustes_e" , "N", 08, 02, },;
                { "ajustes_s" , "N", 08, 02, },;
                { "devol_e"   , "N", 08, 02, },;
                { "devol_s"   , "N", 08, 02, },;
                { "devolcli"  , "N", 08, 02, } }
   aIndice := { { "Codigo", {"codigo"} } }
Case cTabla == "cadtipos"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "tipo"      , "N", 02, 00, },;
                { "nombre"    , "C", 30, 00, },;
                { "tipo_ajust", "N", 01, 00, },;
                { "clase"     , "C", 10, 00, } }
   aIndice := { { "Tipo", {"tipo"} } }
Case cTabla == "cadventa"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "empresa"   , "N", 02, 00, },;
                { "numfac"    , "N", 10, 00, },;
                { "tipo"      , "C", 01, 00, },;
                { "fecfac"    , "D", 08, 00, },;
                { "codigo"    , "C", 05, 00, },;
                { "cantidad"  , "N", 07, 02, },;
                { "precioven" , "N", 11, 02, },;
                { "despor"    , "N", 06, 02, },;
                { "desmon"    , "N", 10, 02, },;
                { "montoiva"  , "N", 10, 02, },;
                { "indicador" , "C", 01, 00, },;
                { "fecdev"    , "D", 08, 00, } }
   aIndice := { { "Factura", {"empresa","numfac","tipo"} }  ,;
                { "Fecha"  , {"empresa","fecfac","numfac"} } }
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
                { "nombre"    , "C", 35, 00, },;
                { "valor"     , "N", 14, 02, },;
                { "nivel"     , "N", 01, 00, } }
//   aIndice := { { "Cuenta", {"cuenta","codigo", "codvar"} } }
Case cTabla == "cgeauxil"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "cuenta"    , "C", 10, 00, },;
                { "codigo"    , "N", 10, 00, },;
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
                { "valor_deb" , "N", 14, 02, },;
                { "valor_cre" , "N", 14, 02, } }
   aIndice := { { "Control"   , {"empresa","ano_mes","control"} },;
                { "Cuenta"    , {"empresa","cuenta","ano_mes"} } }
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
Case cTabla == "extracto"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "numfac"    , "N", 10, 00, },;
                { "tipo"      , "C", 01, 00, },;
                { "fechoy"    , "D", 08, 00, },;
                { "cliente"   , "C", 30, 00, },;
                { "valor"     , "N", 13, 02, },;
                { "debitos"   , "N", 13, 02, },;
                { "creditos"  , "N", 13, 02, } }
   aIndice := { { "Fecha", {"fechoy"} } }
EndCase
/*
Case cTabla == "Historia"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "tipoiden"  , "C", 02, 00, " default 'CC'"},;
                { "nroiden"   , "C", 15, 00, },;
                { "apellidos" , "C", 35, 00, },;
                { "nombres"   , "C", 30, 00, },;
                { "sexo"      , "C", 01, 00, " default 'M'"},;
                { "fec_nacimi", "D", 08, 00, },;
                { "uniedad"   , "C", 01, 00, " default '1'"},;
                { "edad"      , "N", 03, 00, },;
                { "reshabit"  , "C", 05, 00, },; {||Emp->RESHABIT}
                { "zonaresi"  , "C", 01, 00, " default 'U'"},;
                { "direccion" , "C", 40, 00, },;
                { "tel_reside", "C", 15, 00, },;
                { "tel_oficin", "C", 15, 00, },;
                { "email"     , "C", 40, 00, },;
                { "ocupacion" , "C", 03, 00, " default '999'"},;
                { "tipousua"  , "C", 01, 00, " default '5'"},;
                { "tipoafili" , "C", 01, 00, " default 'C'"},;
                { "nro_histor", "N", 08, 00, },;
                { "papel"     , "N", 02, 00, },;
                { "pnomb"     , "N", 02, 00, },;
                { "tapel"     , "N", 02, 00, },;
                { "tnomb"     , "N", 02, 00, } }
   aIndice := { { "NroIden" , { "nroiden" } }            ,;
                { "Apellido", { "apellidos","nombres" } },;
                { "Nombres" , { "nombres","apellidos" } },;
                { "Historia", { "nro_histor" } } }
Case cTabla == "ciudades"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 05, 00, },;
                { "nombre"    , "C", 30, 00, } }
   aIndice := { { "Codigo", { "codigo" } },;
                { "Nombre", { "nombre" } } }
Case cTabla == "ridocupa"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 03, 00, },;
                { "nombre"    , "C", 73, 00, } }
   aIndice := { { "Codigo", { "codigo" } },;
                { "Nombre", { "nombre" } } }
*/
If xDbf == nil
   oTb := TMSTable():Create( oApl:oMySql, cTabla, aStruct )
   FOR nI := 1 TO LEN( aIndice )
      oTb:CreateIndex( aIndice[nI,1],aIndice[nI,2], .f. )
   NEXT nI
   oTb:Destroy()
Else
   BorraFile( cTabla,{"DBF"} )
   dbCREATE( oApl:cRuta2+cTabla,aStruct )
EndIf
RETURN NIL
