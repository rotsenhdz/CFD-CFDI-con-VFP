CLOSE ALL
CLEAR ALL
CLEAR

SET CONFIRM OFF
SET SAFETY OFF
SET DATE ITALIAN   

SET PROCEDURE TO cfd

CFDInit()

?"CFD v" + CFDConf.Version
?"Demo"
?
?

?"- Inicializando..."
WITH CFDConf
 .OpenSSL = ".\SSL"
 .SMTPServer = "smtp.gmail.com" 
 .SMTPPort = 465
 .SMTPUserName = "sucuenta@gmail.com"
 .SMTPPassword = "su-contrasena"
 .MailSender = "sucuenta@gmail.com"
 .modoPruebas = .T.
 .XMLversion = CFDVersions.CFD_20
 .incluirBOM = .F.
ENDWITH


?"- Probando OpenSSL..."
IF CFDProbarOpenSSL()
 ??"OK! ("+STRT(CFDConf.ultimoError,CHR(13)+CHR(10),"")+")"
ELSE
 ?"ERROR: "
 ?CFDConf.ultimoError
 RETURN
ENDIF
    
    
?"- Generando CFD..."    
LOCAL oCFD, o
oCFD = CREATEOBJECT("CFDComprobante")
WITH oCFD
 .Serie = "A"
 .Folio = 25815
 .Fecha = DATETIME()
 .noAprobacion = 1
 .anoAprobacion = 2009
 .formaDePago = "Una sola exhibici�n"
 .condicionesDePago = "A 30 d�as"
 .metodoDePago = "Cheque"
 .subTotal = 4371.00
 .Total = 4640.00
 .Descuento = 371.00
 .motivoDescuento = "Anticipo"
 .tipoDeComprobante = "ingreso"
 
 .Emisor.RFC = "GOYA780416GM0"
 .Emisor.nombre = "ANA CECILIA GOMEZ YA�EZ" 
 .Emisor.domicilioFiscal.Calle = "Benito Juarez Ote"
 .Emisor.domicilioFiscal.noExterior = "106"
 .Emisor.domicilioFiscal.noInterior = "1" 
 .Emisor.domicilioFiscal.Colonia = "Centro"
 .Emisor.domicilioFiscal.Municipio = "Cd. Guadalupe"
 .Emisor.domicilioFiscal.Localidad = "M�xico" 
 .Emisor.domicilioFiscal.Estado = "Nuevo Le�n"
 .Emisor.domicilioFiscal.Pais = "Mexico"
 .Emisor.domicilioFiscal.codigoPostal = "67100"

 .Emisor.expedidoEn.Calle = "Benito Juarez Ote"
 .Emisor.expedidoEn.noExterior = "106"
 .Emisor.expedidoEn.noInterior = "1" 
 .Emisor.expedidoEn.Colonia = "Centro"
 .Emisor.expedidoEn.Municipio = "Cd. Guadalupe"
 .Emisor.expedidoEn.Localidad = "Cd. Guadalupe" 
 .Emisor.expedidoEn.Estado = "Nuevo Le�n"
 .Emisor.expedidoEn.Pais = "M�xico"	
 .Emisor.expedidoEn.codigoPostal = "67100"
 
 .Receptor.RFC = "EAM001231D51"
 .Receptor.Nombre = "ENVASADORAS DE AGUAS EN M�XICO, S. DE R. L. DE C.V." 
 .Receptor.domicilioFiscal.Calle = "AVE. LA SILLA"
 .Receptor.domicilioFiscal.noExterior = "7707"
 .Receptor.domicilioFiscal.noInterior = "1" 
 .Receptor.domicilioFiscal.Colonia = "PARQUE INDUSTRIAL LA SILLA"
 .Receptor.domicilioFiscal.Localidad = "GUADALUPE" 
 .Receptor.domicilioFiscal.Municipio = "GUADALUPE"
 .Receptor.domicilioFiscal.Estado = "NUEVO LE�N"
 .Receptor.domicilioFiscal.Pais = "M�xico"
 .Receptor.domicilioFiscal.codigoPostal = "67190"
 
 .Impuestos.Traslados.Add("IVA",16.00,640.00)
 
 o = .Conceptos.Add(1.000, "ARCO PARA SEGUETA DE ALTA TENS", 176.00, 176.00)    
 o.noIdentificacion = "ABC-12345"
 o.Unidad = "PIEZA"
 o.informacionAduanera.numero = "12345678901" 
 o.informacionAduanera.fecha = CTOD("15-12-2009")
 o.informacionAduanera.aduana = "240"

 o = .Conceptos.Add(1.000, "CORTADORA CIRCULAR DE 1/2", 1696.00, 1696.00)    
 o.noIdentificacion = "CCIRC-98"
 o.Unidad = "PIEZA"
    
 o = .Conceptos.Add(1.000, "MESA DE TRABAJO USO RUDO MADERA", 2499.00, 2499.00)    
 o.noIdentificacion = "MES0002" 
 o.Unidad = "PIEZA"
 o.informacionAduanera.numero = "12345678901" 
 o.informacionAduanera.fecha = CTOD("15-12-2009")
 o.informacionAduanera.aduana = "240"
 
ENDWITH
??"...Version " + CFDVersions.ToLongString(CFDVersions.fromString(oCFD.Version))


*-- Se carga la informacion del certificado 
*
LOCAL cArchivoKey, cArchivoCer
* Para pruebas con certificados del SAT
cArchivoKey = "aaa010101aaa_CSD_01.key"
cArchivoCer = "aaa010101aaa_CSD_01.cer"
cPasswrdKey = "a0123456789"

* Certificado de pruebas del PAC
*cArchivoKey = "goya780416gm0_1011181055s.key"
*cArchivoCer = "goya780416gm0.cer"
*cPasswrdKey = "12345678a"


?"- Validando archivos key y cer..."
IF NOT CFDValidarKeyCer(cArchivoKey, cArchivoCer, cPasswrdKey,".\SSL")
 ?"ERROR: " + CFDConf.ultimoError
 RETURN
ENDIF

?"- Leyendo certificado"
LOCAL oCert
oCert = oCFD.leerCertificado(cArchivoCer)
IF ISNULL(oCert)
 ?"ERROR: " + CFDConf.ultimoError
 RETURN
ENDIF

IF NOT oCert.Valido
 ?"ERROR: El certificado no es valido"
 RETURN
ENDIF

IF (NOT oCert.Vigente) AND (NOT CFDConf.modoPruebas)
 ?"ERROR: El certificado no esta vigente"
 RETURN
ENDIF



*-- Se sella el CFD
*
?"- Generando sello digital"
IF NOT oCFD.Sellar(cArchivoKey,cPasswrdKey)
 ?"ERROR: " + CFDConf.ultimoError
 RETURN
ENDIF



*-- Se crea el CFD
*
?"- Creando CFD"
oCFD.CrearXML("test.xml")



*-- Se vaaida el CFD
*
?"- Validando CFD"
IF NOT CFDValidarXML("test.xml",cArchivoKey, cPasswrdKey, "sha1", ".\SSL")
 ?"ERROR: " + CFDConf.ultimoError
 RETURN
ELSE 
  ??" OK"
ENDIF


*-- Se graba el CFD como PDF (se requiere PDFCreator)
*
?"- Generando PDF"
CFDPrint("test.xml",,.T.,"TEST.PDF")


*!*	*-- Se envia el CFD por correo. Configure los parametros apropiados
*!*	*   en CFDCOnf al inicio de este programa, y luego quite los comentarios
*!*	*   para poder enviar por correo
*!*	*
*!*	*   El envio por correo se hace usando CDO, asi que en teoria no es necesario
*!*	*   instalar ningun software adicional para que funcione
*!*	*
*!*	*?"- Enviando por correo"
*!*	*CFDEnviarPorCorreo("sucuenta@gmail.com","Asunto","Texto","TEST.PDF")


*!*	*-- Se imprime el CFD
*!*	*
*!*	?"- Imprimendo CFD"
*!*	CFDPrint("test.xml",.T.)





RETURN


