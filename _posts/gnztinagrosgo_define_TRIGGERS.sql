USE `gnztinagrosgo`;

/* Definition for the `ajustes_after_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `ajustes_after_upd_tr1` AFTER UPDATE ON `ajustes`
  FOR EACH ROW
BEGIN
DECLARE qEXI TINYINT(1);
DECLARE qSUM TINYINT(1);
DECLARE qCANTID DECIMAL(15,3);
DECLARE qIDPROD INTEGER(11) UNSIGNED;

DECLARE done TINYINT DEFAULT FALSE;
DECLARE curRenglones CURSOR
	FOR SELECT ID_PROD, CANTIDAD
		FROM ajustes_detalle
		WHERE ID_AJUSTE=NEW.ID;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=TRUE;

IF OLD.REGISTRADO=0 AND NEW.REGISTRADO=1		THEN

   SET qEXI = 0;
   SET qSUM = 0;
   SELECT EXISTEN, EXISUMA 
          FROM tipocomp 
          WHERE TIPCOM=NEW.COMPRO  
          INTO qEXI, qSUM;

   IF qEXI=1		THEN
      OPEN curRenglones;
		renglones_loop:LOOP

         FETCH curRenglones INTO qIDPROD, qCANTID; 
         IF done	THEN
            LEAVE renglones_loop;
         END IF;

         IF qSUM=0			THEN
            SET qCANTID = -qCANTID;
         END IF;

         UPDATE productos
                SET EXISTENTOT=EXISTENTOT+qCANTID
                WHERE ID=qIDPROD;

         INSERT INTO existen
               (NROSUC, ID_PROD, CANTIDAD) 
                VALUES( NEW.NROSUC, qIDPROD, qCANTID ) 
             ON DUPLICATE KEY UPDATE CANTIDAD=CANTIDAD+qCANTID;

      END LOOP;
      CLOSE curRenglones;

	  SELECT Genera_envio_datos(NEW.NROSUC, 'ajustes', NEW.ID)
   					INTO qIDPROD;

   END IF;

END IF;

END$$

DELIMITER ;

/* Definition for the `bancos_after_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `bancos_after_ins_tr1` AFTER INSERT ON `bancos`
  FOR EACH ROW
BEGIN
DECLARE codsuc SMALLINT(6);
DECLARE nada INTEGER(11);

/*--- solamente desde casa central ---*/
SELECT LEO_PARAMETRO('ESTASUC') INTO codsuc;

IF codsuc=1      THEN 
   SELECT Genera_envio_datos(codsuc, 'bancos', NEW.CODBAN)
              INTO nada;
END IF;	

END$$

DELIMITER ;

/* Definition for the `bancos_after_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `bancos_after_upd_tr1` AFTER UPDATE ON `bancos`
  FOR EACH ROW
BEGIN
DECLARE codsuc SMALLINT(6);
DECLARE nada INTEGER(11);

/*--- solamente desde casa central ---*/
SELECT LEO_PARAMETRO('ESTASUC') INTO codsuc;

IF codsuc=1      THEN 
   SELECT Genera_envio_datos(codsuc, 'bancos', NEW.CODBAN)
              INTO nada;
END IF;	

END$$

DELIMITER ;

/* Definition for the `bancos_cuentas_before_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `bancos_cuentas_before_ins_tr1` BEFORE INSERT ON `bancos_cuentas`
  FOR EACH ROW
BEGIN
  SET NEW.FECMOVIM = CURRENT_TIMESTAMP();
END$$

DELIMITER ;

/* Definition for the `bancos_cuentas_before_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `bancos_cuentas_before_upd_tr1` BEFORE UPDATE ON `bancos_cuentas`
  FOR EACH ROW
BEGIN
  SET NEW.FECMOVIM = CURRENT_TIMESTAMP();
END$$

DELIMITER ;

/* Definition for the `cajadiaria_before_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `cajadiaria_before_ins_tr1` BEFORE INSERT ON `cajadiaria`
  FOR EACH ROW
BEGIN
  IF NEW.FECHA IS NULL		THEN
     SET NEW.FECHA = CURDATE();
  END IF;
  SET NEW.FECMOVIM = CURRENT_TIMESTAMP();
END$$

DELIMITER ;

/* Definition for the `cajadiaria_cierres_before_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `cajadiaria_cierres_before_ins_tr1` BEFORE INSERT ON `cajadiaria_cierres`
  FOR EACH ROW
BEGIN
IF NEW.fecha IS NULL	THEN
	SET NEW.fecha = CURRENT_DATE();
END IF;

IF NEW.fecmovim IS NULL		THEN
	SET NEW.fecmovim = CURRENT_TIMESTAMP();
END IF;

END$$

DELIMITER ;

/* Definition for the `cajadiaria_cierres_after_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `cajadiaria_cierres_after_ins_tr1` AFTER INSERT ON `cajadiaria_cierres`
  FOR EACH ROW
BEGIN
DECLARE nada INTEGER(11);
SELECT Genera_envio_datos(NEW.nrosuc, 'cajadiaria_cierres', NEW.id)
   					INTO nada;
END$$

DELIMITER ;

/* Definition for the `catclien_after_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `catclien_after_ins_tr1` AFTER INSERT ON `catclien`
  FOR EACH ROW
BEGIN
DECLARE codsuc SMALLINT(6);
DECLARE nada INTEGER(11);

/*--- solamente desde casa central ---*/
SELECT LEO_PARAMETRO('ESTASUC') INTO codsuc;

IF codsuc=1      THEN 
   SELECT Genera_envio_datos(codsuc, 'catclien', NEW.CATCLI)
              INTO nada;
END IF;	

END$$

DELIMITER ;

/* Definition for the `catclien_after_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `catclien_after_upd_tr1` AFTER UPDATE ON `catclien`
  FOR EACH ROW
BEGIN
DECLARE codsuc SMALLINT(6);
DECLARE nada INTEGER(11);

/*--- solamente desde casa central ---*/
SELECT LEO_PARAMETRO('ESTASUC') INTO codsuc;

IF codsuc=1      THEN 
   SELECT Genera_envio_datos(codsuc, 'catclien', NEW.CATCLI)
              INTO nada;
END IF;	

END$$

DELIMITER ;

/* Definition for the `chq3_titularcuenta_after_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `chq3_titularcuenta_after_ins_tr1` AFTER INSERT ON `chq3_titularcuenta`
  FOR EACH ROW
BEGIN
DECLARE nada INTEGER(11);
DECLARE codsuc SMALLINT(6);

SELECT LEO_PARAMETRO('ESTASUC') INTO codsuc;

SELECT Genera_envio_datos( codsuc, 'chq3_titularcuenta', NEW.ID )
   					INTO nada;

END$$

DELIMITER ;

/* Definition for the `chq3_titularcuenta_after_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `chq3_titularcuenta_after_upd_tr1` AFTER UPDATE ON `chq3_titularcuenta`
  FOR EACH ROW
BEGIN
DECLARE nada INTEGER(11);
DECLARE codsuc SMALLINT(6);

SELECT LEO_PARAMETRO('ESTASUC') INTO codsuc;

SELECT Genera_envio_datos( codsuc, 'chq3_titularcuenta', NEW.ID )
   					INTO nada;

END$$

DELIMITER ;

/* Definition for the `clientes_after_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `clientes_after_ins_tr1` AFTER INSERT ON `clientes`
  FOR EACH ROW
BEGIN
DECLARE nada INTEGER(11);
DECLARE codsuc SMALLINT(6);

SELECT LEO_PARAMETRO('ESTASUC') INTO codsuc;

SELECT Genera_envio_datos(codsuc, 'clientes', NEW.CODCLI)
   				INTO nada;

END$$

DELIMITER ;

/* Definition for the `clientes_after_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `clientes_after_upd_tr1` AFTER UPDATE ON `clientes`
  FOR EACH ROW
BEGIN
DECLARE nada INTEGER(11);
DECLARE codsuc SMALLINT(6);

SELECT LEO_PARAMETRO('ESTASUC') INTO codsuc;

SELECT Genera_envio_datos(codsuc, 'clientes', NEW.CODCLI)
   				INTO nada;

END$$

DELIMITER ;

/* Definition for the `clientes_saldos_before_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `clientes_saldos_before_ins_tr1` BEFORE INSERT ON `clientes_saldos`
  FOR EACH ROW
BEGIN
SET NEW.FECMOVIM = CURRENT_TIMESTAMP();
END$$

DELIMITER ;

/* Definition for the `clientes_saldos_before_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `clientes_saldos_before_upd_tr1` BEFORE UPDATE ON `clientes_saldos`
  FOR EACH ROW
BEGIN
SET NEW.FECMOVIM = CURRENT_TIMESTAMP();
END$$

DELIMITER ;

/* Definition for the `diagnosticos_after_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `diagnosticos_after_ins_tr1` AFTER INSERT ON `diagnosticos`
  FOR EACH ROW
BEGIN
DECLARE codsuc SMALLINT(6);
DECLARE nada INTEGER(11);

/*--- solamente desde casa central ---*/
SELECT LEO_PARAMETRO('ESTASUC') INTO codsuc;

IF codsuc=1      THEN 
   SELECT Genera_envio_datos(codsuc, 'diagnosticos', NEW.DIAGNOSTICO)
              INTO nada;
END IF;	

END$$

DELIMITER ;

/* Definition for the `diagnosticos_after_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `diagnosticos_after_upd_tr1` AFTER UPDATE ON `diagnosticos`
  FOR EACH ROW
BEGIN
DECLARE codsuc SMALLINT(6);
DECLARE nada INTEGER(11);

/*--- solamente desde casa central ---*/
SELECT LEO_PARAMETRO('ESTASUC') INTO codsuc;

IF codsuc=1      THEN 
   SELECT Genera_envio_datos(codsuc, 'diagnosticos', NEW.DIAGNOSTICO)
              INTO nada;
END IF;	

END$$

DELIMITER ;

/* Definition for the `factu01_after_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `factu01_after_ins_tr1` AFTER INSERT ON `factu01`
  FOR EACH ROW
BEGIN
DECLARE NADA TINYINT(1);
/*---
IF NEW.COMPRO=1 OR NEW.COMPRO=12		THEN

   SELECT crea_tmp_detalle_vales( NEW.CODCLI, NEW.REGISTRO_F01 )
      		 INTO NADA;

END IF;
----*/
END$$

DELIMITER ;

/* Definition for the `factu01_after_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `factu01_after_upd_tr1` AFTER UPDATE ON `factu01`
  FOR EACH ROW
BEGIN
DECLARE MCTACTE TINYINT(1);
DECLARE MDEBITA TINYINT(1);
DECLARE MEXISTEN TINYINT(1);
DECLARE MEXISUMA TINYINT(1);
DECLARE QUEIMPO DECIMAL(15,2);

DECLARE QEXIST DECIMAL(15,3);
DECLARE QID_PROD INTEGER(11) UNSIGNED;
DECLARE QCANTID DECIMAL(15,3);

DECLARE Q_IDVAL INTEGER(11) UNSIGNED;
DECLARE Q_CLAVE INTEGER(11) UNSIGNED;

DECLARE actualizar TINYINT(1);

DECLARE done TINYINT DEFAULT FALSE;
DECLARE curRenglones CURSOR
	FOR SELECT ID_PROD, CANTIDAD
		FROM factu02
		WHERE REGISTRO_F01=NEW.REGISTRO_F01;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=TRUE;

IF NEW.COMPRO=1	OR NEW.COMPRO=12		THEN
   IF OLD.CODCLI <> NEW.CODCLI			THEN

      DELETE FROM `tmp_pagos_detalle_vales`
      		 WHERE IDENTIFICADOR=NEW.REGISTRO_F01;

      SELECT crea_tmp_detalle_vales( NEW.CODCLI, NEW.REGISTRO_F01 )
      		 INTO MCTACTE;

	  SET done = FALSE;
   END IF;
END IF;

IF NEW.CERRADO=1 AND NEW.VALIDO=1
	AND (OLD.CERRADO<>1 OR OLD.VALIDO<>1)		THEN

   /*--- IMPORTANTE !!
   		el comprobante debe INSERTarse como NO valido y NO cerrado
         porque primero INSERTa factu01 y luego los renglones en factu02
         esto es, si se graba como VALIDO y CERRADO, no existen aun
         los renglones ... entonces aqui no va a hacer nada.
   ---*/

	SELECT CTACTE, DEBITA, EXISTEN, EXISUMA
		FROM tipocomp
  	WHERE TIPCOM=NEW.COMPRO
   	INTO MCTACTE, MDEBITA, MEXISTEN, MEXISUMA;

	/*--- FORMA DE PAGO CUENTA CORRIENTE ---*/
	IF NEW.FORPAG=2 AND MCTACTE=1		THEN
		IF MDEBITA=1	THEN
   		SET QUEIMPO=NEW.IMPORTE;
   	ELSE
			SET QUEIMPO=-NEW.IMPORTE;
		END IF;

   	UPDATE clientes
   		SET SALDO=SALDO+QUEIMPO
	     WHERE CODCLI=NEW.CODCLI;
	END IF;

	IF MEXISTEN=1		THEN

		SET done = FALSE;
		OPEN curRenglones;
		renglones_loop:LOOP

			FETCH curRenglones INTO QID_PROD, QCANTID;
			IF done THEN
    			LEAVE renglones_loop;
	    	END IF;

            IF MEXISUMA=1		THEN
               SET QEXIST=QCANTID;
            ELSE
               SET QEXIST=-QCANTID;
            END IF;

            UPDATE productos
                SET EXISTENTOT=EXISTENTOT+QEXIST
               WHERE ID=QID_PROD;

            INSERT INTO existen
                    (NROSUC, ID_PROD, CANTIDAD)
                 VALUES( NEW.NROSUC, QID_PROD, QEXIST )
              ON DUPLICATE KEY UPDATE CANTIDAD=CANTIDAD+QEXIST;

			SET done = FALSE;
	    END LOOP;
		CLOSE curRenglones;

    END IF;

   /*---------
   		le pasa el registro de factu01 y 1
         indicando que se trata de una venta o
         nota de credito o factura o cobranza ---*/
   CALL Genera_Movimiento_Caja( NEW.REGISTRO_F01, 1 ); 

   SELECT Genera_envio_datos(NEW.NROSUC, 'factu01', NEW.REGISTRO_F01)
   				INTO QID_PROD;

END IF;

END$$

DELIMITER ;

/* Definition for the `factu01_transportista_before_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `factu01_transportista_before_ins_tr1` BEFORE INSERT ON `factu01_transportista`
  FOR EACH ROW
BEGIN
  SET NEW.FECMOVIM = CURRENT_TIMESTAMP();
END$$

DELIMITER ;

/* Definition for the `grupos_after_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `grupos_after_ins_tr1` AFTER INSERT ON `grupos`
  FOR EACH ROW
BEGIN
DECLARE nada INTEGER(11);
DECLARE codsuc SMALLINT(6);

   SELECT LEO_PARAMETRO('ESTASUC') INTO codsuc;

      /*-- envia los grupos, SOLO desde central. --*/
   IF codsuc = 1		THEN
       SELECT Genera_envio_datos( codsuc, 'grupos', NEW.GRUPO )
                   INTO nada;
   END IF;

END$$

DELIMITER ;

/* Definition for the `grupos_after_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `grupos_after_upd_tr1` AFTER UPDATE ON `grupos`
  FOR EACH ROW
BEGIN
DECLARE nada INTEGER(11);
DECLARE codsuc SMALLINT(6);

   SELECT LEO_PARAMETRO('ESTASUC') INTO codsuc;

      /*-- envia los grupos, SOLO desde central. --*/
   IF codsuc = 1		THEN
       SELECT Genera_envio_datos( codsuc, 'grupos', NEW.GRUPO )
                   INTO nada;
   END IF;

END$$

DELIMITER ;

/* Definition for the `grupos_objetivos_after_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `grupos_objetivos_after_ins_tr1` AFTER INSERT ON `grupos_objetivos`
  FOR EACH ROW
BEGIN
DECLARE codsuc SMALLINT(6);
DECLARE nada INTEGER(11);

/*--- solamente desde casa central ---*/
SELECT LEO_PARAMETRO('ESTASUC') INTO codsuc;

IF codsuc=1      THEN 
   SELECT Genera_envio_datos(codsuc, 'grupos_objetivos', NEW.id)
              INTO nada;
END IF;	

END$$

DELIMITER ;

/* Definition for the `grupos_objetivos_after_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `grupos_objetivos_after_upd_tr1` AFTER UPDATE ON `grupos_objetivos`
  FOR EACH ROW
BEGIN
DECLARE codsuc SMALLINT(6);
DECLARE nada INTEGER(11);

/*--- solamente desde casa central ---*/
SELECT LEO_PARAMETRO('ESTASUC') INTO codsuc;

IF codsuc=1      THEN 
   SELECT Genera_envio_datos(codsuc, 'grupos_objetivos', NEW.id)
              INTO nada;
END IF;	

END$$

DELIMITER ;

/* Definition for the `informe_recepcion_after_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `informe_recepcion_after_upd_tr1` AFTER UPDATE ON `informe_recepcion`
  FOR EACH ROW
BEGIN
  DECLARE MEXISTEN TINYINT(1);
  DECLARE MEXISUMA TINYINT(1);
  DECLARE QUEIMPO DECIMAL(15,2);
  DECLARE QEXIST DECIMAL(15,3);
  DECLARE QID_PROD INTEGER(11) UNSIGNED;
  DECLARE QCANTID DECIMAL(15,3);
  DECLARE actualizar TINYINT(1);
  DECLARE done TINYINT DEFAULT FALSE;
  
  DECLARE curRenglones CURSOR FOR
  		SELECT ID_PROD, CANTID
          FROM informe_recepcion_detalle
          WHERE ID_INFORME = NEW . ID; 
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=TRUE;
  
  IF NEW.REGISTRADO=1 AND OLD.REGISTRADO<>1 THEN
    /*--- IMPORTANTE !!
           el comprobante debe INSERTarse como NO REGISTRADA
         porque primero INSERTa remito_proveedor y luego los renglones en _detalle
   ---*/
    SELECT EXISTEN, EXISUMA
        FROM tipocomp
        WHERE TIPCOM = NEW . COMPRO
        INTO MEXISTEN, MEXISUMA; 
    IF MEXISTEN=1 THEN
      OPEN curRenglones;
      renglones_loop:LOOP
          FETCH curRenglones INTO QID_PROD, QCANTID;
          IF done THEN
            LEAVE renglones_loop;
          END IF;
          IF MEXISUMA=1 THEN
            SET QEXIST=QCANTID;
          ELSE
            SET QEXIST=-QCANTID;
          END IF;
         
          UPDATE productos
              SET EXISTENTOT = EXISTENTOT + QEXIST
              WHERE ID = QID_PROD;
          INSERT INTO existen(NROSUC, ID_PROD, CANTIDAD)
              VALUES (NEW . NROSUC, QID_PROD, QEXIST) 
              ON DUPLICATE KEY
              		UPDATE CANTIDAD = CANTIDAD + QEXIST; 
      END LOOP;
      CLOSE curRenglones;
      
      SELECT Genera_envio_datos(NEW.NROSUC, 'informe_recepcion', NEW.ID)
   				INTO QID_PROD;
    END IF;
  END IF;
END$$

DELIMITER ;

/* Definition for the `inventario_ajuste_after_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `inventario_ajuste_after_ins_tr1` AFTER INSERT ON `inventario_ajuste`
  FOR EACH ROW
BEGIN
  DECLARE actualizar TINYINT(1);
  DECLARE nada INTEGER(11);

  SELECT Genera_envio_datos(NEW.NROSUC, 'inventario_ajuste', NEW.ID)
   				INTO nada;

END$$

DELIMITER ;

/* Definition for the `inventario_ajuste_detalle_before_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `inventario_ajuste_detalle_before_ins_tr1` AFTER INSERT ON `inventario_ajuste_detalle`
  FOR EACH ROW
BEGIN
DECLARE qCOM SMALLINT(6);
DECLARE qSUC SMALLINT(6);
DECLARE subtotal DECIMAL(15,3);
DECLARE qEXI TINYINT(1);
DECLARE qSUM TINYINT(1);
DECLARE qCANTID DECIMAL(15,3);

SELECT NROSUC, COMPRO
		 FROM inventario_ajuste
       WHERE ID=NEW.ID_AJUSTE
       INTO qSUC, qCOM;

SET qEXI = 0;
SET qSUM = 0;
SELECT EXISTEN, EXISUMA
		 FROM tipocomp
       WHERE TIPCOM=qCOM
		 INTO qEXI, qSUM;

IF qEXI <> 0		THEN
	IF qSUM=1			THEN
   	SET qCANTID = NEW.AJUSTE;
   ELSE
   	SET qCANTID = -NEW.AJUSTE;
   END IF;
END IF;

SET subtotal = ROUND( qCANTID * NEW.PRECIO, 3 );

UPDATE inventario_ajuste
		 SET VALUACION = VALUACION + subtotal
		 WHERE ID=NEW.ID_AJUSTE;

UPDATE productos
  		 SET EXISTENTOT=EXISTENTOT+qCANTID
 		 WHERE ID=NEW.ID_PROD;

INSERT INTO existen
      (NROSUC, ID_PROD, CANTIDAD)
   	 VALUES( qSUC, NEW.ID_PROD, qCANTID )
	 ON DUPLICATE KEY UPDATE CANTIDAD=CANTIDAD+qCANTID;

END$$

DELIMITER ;

/* Definition for the `maquinas_before_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `maquinas_before_ins_tr1` BEFORE INSERT ON `maquinas`
  FOR EACH ROW
BEGIN
  SET NEW.FEALTA = CURRENT_DATE();
END$$

DELIMITER ;

/* Definition for the `maquinas_after_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `maquinas_after_ins_tr1` AFTER INSERT ON `maquinas`
  FOR EACH ROW
BEGIN
DECLARE nada INTEGER(11);
DECLARE codsuc SMALLINT(6);

SELECT LEO_PARAMETRO('ESTASUC') INTO codsuc;

SELECT Genera_envio_datos( codsuc, 'maquinas', NEW.ID )
       INTO nada;

END$$

DELIMITER ;

/* Definition for the `maquinas_after_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `maquinas_after_upd_tr1` AFTER UPDATE ON `maquinas`
  FOR EACH ROW
BEGIN
DECLARE nada INTEGER(11);
DECLARE codsuc SMALLINT(6);

SELECT LEO_PARAMETRO('ESTASUC') INTO codsuc;

SELECT Genera_envio_datos( codsuc, 'maquinas', NEW.ID )
       INTO nada;

END$$

DELIMITER ;

/* Definition for the `marcas_after_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `marcas_after_ins_tr1` AFTER INSERT ON `marcas`
  FOR EACH ROW
BEGIN
DECLARE nada INTEGER(11);
DECLARE codsuc SMALLINT(6);

   SELECT LEO_PARAMETRO('ESTASUC') INTO codsuc;

      /*-- envia las marcas, SOLO desde central. --*/
   IF codsuc = 1		THEN
       SELECT Genera_envio_datos( codsuc, 'marcas', NEW.MARCA )
                   INTO nada;
   END IF;

END$$

DELIMITER ;

/* Definition for the `marcas_after_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `marcas_after_upd_tr1` AFTER UPDATE ON `marcas`
  FOR EACH ROW
BEGIN
DECLARE nada INTEGER(11);
DECLARE codsuc SMALLINT(6);

   SELECT LEO_PARAMETRO('ESTASUC') INTO codsuc;

      /*-- envia las marcas, SOLO desde central. --*/
   IF codsuc = 1		THEN
       SELECT Genera_envio_datos( codsuc, 'marcas', NEW.MARCA )
                   INTO nada;
   END IF;

END$$

DELIMITER ;

/* Definition for the `mecanicos_after_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `mecanicos_after_ins_tr1` AFTER INSERT ON `mecanicos`
  FOR EACH ROW
BEGIN
DECLARE nada INTEGER(11);
DECLARE codsuc SMALLINT(6);

   SELECT LEO_PARAMETRO('ESTASUC') INTO codsuc;

      /*-- envia mecanicos, SOLO desde central. --*/
   IF codsuc = 1		THEN
       SELECT Genera_envio_datos( codsuc, 'mecanicos', NEW.MECANICO )
                   INTO nada;
   END IF;

END$$

DELIMITER ;

/* Definition for the `mecanicos_after_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `mecanicos_after_upd_tr1` AFTER UPDATE ON `mecanicos`
  FOR EACH ROW
BEGIN
DECLARE nada INTEGER(11);
DECLARE codsuc SMALLINT(6);

   SELECT LEO_PARAMETRO('ESTASUC') INTO codsuc;

      /*-- envia mecanicos, SOLO desde central. --*/
   IF codsuc = 1		THEN
       SELECT Genera_envio_datos( codsuc, 'mecanicos', NEW.MECANICO )
                   INTO nada;
   END IF;

END$$

DELIMITER ;

/* Definition for the `orden_repar_requerimiento_after_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `orden_repar_requerimiento_after_upd_tr1` AFTER UPDATE ON `orden_repar_requerimiento`
  FOR EACH ROW
BEGIN
DECLARE orden_suc SMALLINT(6);
DECLARE orden_en_taller TINYINT(1);
DECLARE nada SMALLINT(6);

DECLARE qIDPROD INTEGER(11);
DECLARE qCANTID DECIMAL(15,2);

DECLARE done TINYINT DEFAULT FALSE;
DECLARE curRequerimientos CURSOR FOR 
      SELECT rd.ID_PROD, rd.CANTIDAD
      FROM `orden_repar_requer_detalle` rd 
            WHERE rd.ID_REQUER=NEW.ID
              AND rd.ACTIVA=1;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=TRUE;

SELECT NROSUC, EN_TALLER 
	FROM orden_reparacion
    WHERE ID=NEW.ID_ORDEN
     INTO orden_suc, orden_en_taller;

IF orden_en_taller = 1		THEN
   IF OLD.REGISTRADA=0 AND NEW.REGISTRADA=1	THEN
      OPEN curRequerimientos;
      renglones_loop:LOOP

         FETCH curRequerimientos INTO qIDPROD, qCANTID; 
         IF done	THEN
            LEAVE renglones_loop;
         END IF;

         SET qCANTID = -qCANTID;

         UPDATE `productos_existencias`
                SET EXISTENTOT=EXISTENTOT+qCANTID
                WHERE ID_PROD=qIDPROD;

         INSERT INTO existen
               (NROSUC, ID_PROD, CANTIDAD) 
                VALUES( orden_suc, qIDPROD, qCANTID ) 
             ON DUPLICATE KEY UPDATE CANTIDAD=CANTIDAD+qCANTID;

		 SET done = FALSE;
      END LOOP;
      CLOSE curRequerimientos;

      SELECT Genera_envio_datos( orden_suc, 'orden_repar_requerimiento', NEW.ID )
                        INTO nada;
   END IF;
END IF;

END$$

DELIMITER ;

/* Definition for the `orden_reparacion_before_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `orden_reparacion_before_ins_tr1` BEFORE INSERT ON `orden_reparacion`
  FOR EACH ROW
BEGIN
  DECLARE ultima INTEGER(11);
  
  SET NEW.FECMODIF = CURRENT_TIMESTAMP();
  
  SELECT LEO_PARAMETRO_NUM('OREPULTIMA') INTO ultima;
  
  SET ultima = ultima + 1;
  SET NEW.NUMERO = ultima;
  
  UPDATE zvarios
  		SET VALOR=ultima
		WHERE clave2='OREPULTIMA';
END$$

DELIMITER ;

/* Definition for the `precios_after_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `precios_after_upd_tr1` AFTER UPDATE ON `precios`
  FOR EACH ROW
BEGIN
DECLARE nada INTEGER(11);
DECLARE codsuc SMALLINT(6);

IF OLD.APLICADO=0 AND NEW.APLICADO=1		THEN
   SELECT LEO_PARAMETRO('ESTASUC') INTO codsuc;

      /*-- envia los precios modificados, SOLO desde central. --*/
   IF codsuc = 1		THEN
       SELECT Genera_envio_datos( codsuc, 'precios', NEW.ID )
                   INTO nada;
   END IF;
END IF;

END$$

DELIMITER ;

/* Definition for the `productos_after_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `productos_after_ins_tr1` AFTER INSERT ON `productos`
  FOR EACH ROW
BEGIN
DECLARE nada INTEGER(11);
DECLARE codsuc SMALLINT(6);

SELECT LEO_PARAMETRO('ESTASUC') INTO codsuc;

SELECT Genera_envio_datos( codsuc, 'productos', NEW.ID )
   				INTO nada;

END$$

DELIMITER ;

/* Definition for the `productos_before_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `productos_before_upd_tr1` BEFORE UPDATE ON `productos`
  FOR EACH ROW
BEGIN
IF NEW.EXISTENTOT IS NULL		THEN
	SET NEW.EXISTENTOT = 0.00;
END IF;
END$$

DELIMITER ;

/* Definition for the `productos_after_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `productos_after_upd_tr1` AFTER UPDATE ON `productos`
  FOR EACH ROW
BEGIN
DECLARE nada INTEGER(11);
DECLARE codsuc SMALLINT(6);

SELECT LEO_PARAMETRO('ESTASUC') INTO codsuc;

      /*-- envia los productos modificados, SOLO desde central. --*/
IF codsuc = 1		THEN
	SELECT Genera_envio_datos( codsuc, 'productos', NEW.ID )
   				INTO nada;
END IF;

END$$

DELIMITER ;

/* Definition for the `productos_existencias_before_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `productos_existencias_before_ins_tr1` BEFORE INSERT ON `productos_existencias`
  FOR EACH ROW
BEGIN
SET NEW.FECMOVIM = CURRENT_TIMESTAMP();
END$$

DELIMITER ;

/* Definition for the `productos_existencias_before_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `productos_existencias_before_upd_tr1` BEFORE UPDATE ON `productos_existencias`
  FOR EACH ROW
BEGIN
SET NEW.FECMOVIM = CURRENT_TIMESTAMP();
END$$

DELIMITER ;

/* Definition for the `proveedores_saldos_before_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `proveedores_saldos_before_ins_tr1` BEFORE INSERT ON `proveedores_saldos`
  FOR EACH ROW
BEGIN
SET NEW.fecmovim = CURRENT_TIMESTAMP();
END$$

DELIMITER ;

/* Definition for the `proveedores_saldos_before_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'luis'@'localhost' TRIGGER `proveedores_saldos_before_upd_tr1` BEFORE UPDATE ON `proveedores_saldos`
  FOR EACH ROW
BEGIN
SET NEW.fecmovim = CURRENT_TIMESTAMP();
END$$

DELIMITER ;

/* Definition for the `prv_facpr01_before_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `prv_facpr01_before_ins_tr1` BEFORE INSERT ON `prv_facpr01`
  FOR EACH ROW
BEGIN
  SET NEW.FECMOVIM = CURRENT_TIMESTAMP();
END$$

DELIMITER ;

/* Definition for the `prv_facpr01_before_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `prv_facpr01_before_upd_tr1` BEFORE UPDATE ON `prv_facpr01`
  FOR EACH ROW
BEGIN
  SET NEW.FECMOVIM = CURRENT_TIMESTAMP();
END$$

DELIMITER ;

/* Definition for the `prv_facpr01_after_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `prv_facpr01_after_upd_tr1` AFTER UPDATE ON `prv_facpr01`
  FOR EACH ROW
BEGIN
DECLARE MCTACTE TINYINT(1);
DECLARE MDEBITA TINYINT(1);
DECLARE MEXISTEN TINYINT(1);
DECLARE MEXISUMA TINYINT(1);
DECLARE QUEIMPO DECIMAL(15,2);

DECLARE QEXIST DECIMAL(15,3);
DECLARE QID_PROD INTEGER(11) UNSIGNED ;
DECLARE QCANTID DECIMAL(15,3);

DECLARE done TINYINT DEFAULT FALSE;
DECLARE curRenglones CURSOR
	FOR SELECT ID_PROD, CANTIDAD
		FROM prv_facpr02
		WHERE ID_FP01=NEW.ID;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=TRUE;

IF NEW.ACTIVA=1 AND NEW.REGISTRADA=1
	AND (OLD.REGISTRADA<>1)		THEN

   /*--- IMPORTANTE !!
   		el comprobante debe INSERTarse como ACTIVA y NO REGISTRADA
         porque primero INSERTa prv_facpr01 y luego los renglones en prv_facpr02
   ---*/

	SELECT CTACTE, DEBITA, EXISTEN, EXISUMA
		FROM tipocomp
  	WHERE TIPCOM=NEW.COMPRO
   	INTO MCTACTE, MDEBITA, MEXISTEN, MEXISUMA;

	/*--- FORMA DE PAGO CUENTA CORRIENTE ---*/
	IF MCTACTE=1		THEN
		IF MDEBITA=1	THEN
   		SET QUEIMPO=NEW.IMPORTE;
   	ELSE
			SET QUEIMPO=-NEW.IMPORTE;
		END IF;

   	UPDATE proveedores
   		SET SALDO=SALDO+QUEIMPO
	     WHERE ID=NEW.ID_PRV;
	END IF;

	IF MEXISTEN=1		THEN

		OPEN curRenglones;
		renglones_loop:LOOP

			FETCH curRenglones INTO QID_PROD, QCANTID;
			IF done THEN
    			LEAVE renglones_loop;
	    	END IF;

   	   IF MEXISUMA=1		THEN
      		SET QEXIST=QCANTID;
	      ELSE
   	   	SET QEXIST=-QCANTID;
   		END IF;

         UPDATE productos
         	SET EXISTENTOT=EXISTENTOT+QEXIST
           WHERE ID=QID_PROD;

         INSERT INTO existen
         		(NROSUC, ID_PROD, CANTIDAD)
             VALUES( 1, QID_PROD, QEXIST )
          ON DUPLICATE KEY UPDATE CANTIDAD=CANTIDAD+QEXIST;
	/*--- LA SUCURSAL ES 1 (UNO) ---*/


      END LOOP;
		CLOSE curRenglones;

   END IF;

    /*---------
   		le pasa el registro de prv_facpr01 y 2
         indicando que se trata de un pago o
         nota de credito ---*/
   CALL Genera_Movimiento_Caja( NEW.ID, 2 ); 

END IF;

END$$

DELIMITER ;

/* Definition for the `prv_pagofact_after_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `prv_pagofact_after_ins_tr1` AFTER INSERT ON `prv_pagofact`
  FOR EACH ROW
BEGIN
UPDATE prv_facpr01
	SET PAGOS = PAGOS + NEW.IMPORTE
 WHERE ID=NEW.PAGA_FP01;

UPDATE prv_facpr01
	SET PAGOS = PAGOS + NEW.IMPORTE
 WHERE ID=NEW.REGFP01;
END$$

DELIMITER ;

/* Definition for the `remito_proveedor_after_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `remito_proveedor_after_upd_tr1` AFTER UPDATE ON `remito_proveedor`
  FOR EACH ROW
BEGIN
DECLARE MEXISTEN TINYINT(1);
DECLARE MEXISUMA TINYINT(1);
DECLARE QUEIMPO DECIMAL(15,2);

DECLARE QEXIST DECIMAL(15,3);
DECLARE QID_PROD INTEGER(11) UNSIGNED ;
DECLARE QCANTID DECIMAL(15,3);

DECLARE done TINYINT DEFAULT FALSE;
DECLARE curRenglones CURSOR
	FOR SELECT ID_PROD, CANTID
		FROM remito_proveedor_detalle
		WHERE ID_REMITO=NEW.ID;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=TRUE;

IF NEW.REGISTRADO=1 AND OLD.REGISTRADO<>1		THEN

   /*--- IMPORTANTE !!
   		el comprobante debe INSERTarse como NO REGISTRADA
         porque primero INSERTa remito_proveedor y luego los renglones en _detalle
   ---*/

	SELECT EXISTEN, EXISUMA
		FROM tipocomp
  	WHERE TIPCOM=NEW.COMPRO
   	INTO MEXISTEN, MEXISUMA;

	IF MEXISTEN=1		THEN

		OPEN curRenglones;
		renglones_loop:LOOP

			FETCH curRenglones INTO QID_PROD, QCANTID;
			IF done THEN
    			LEAVE renglones_loop;
	    	END IF;

   	   IF MEXISUMA=1		THEN
      		SET QEXIST=QCANTID;
	      ELSE
   	   	SET QEXIST=-QCANTID;
   		END IF;

         UPDATE productos
         	SET EXISTENTOT=EXISTENTOT+QEXIST
           WHERE ID=QID_PROD;

         INSERT INTO existen (NROSUC, ID_PROD, CANTIDAD)
              VALUES( NEW.NROSUC, QID_PROD, QEXIST )
           ON DUPLICATE KEY UPDATE CANTIDAD=CANTIDAD+QEXIST;

      END LOOP;
		CLOSE curRenglones;

   END IF;

END IF;

END$$

DELIMITER ;

/* Definition for the `remitos_internos_after_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `remitos_internos_after_upd_tr1` AFTER UPDATE ON `remitos_internos`
  FOR EACH ROW
BEGIN
DECLARE MEXISTEN TINYINT(1);
DECLARE MEXISUMA TINYINT(1);
DECLARE QUEIMPO DECIMAL(15,2);

DECLARE QEXIST DECIMAL(15,3);
DECLARE QID_PROD INTEGER(11) UNSIGNED ;
DECLARE QCANTID DECIMAL(15,3);

DECLARE done TINYINT DEFAULT FALSE;
DECLARE curRenglones CURSOR
	FOR SELECT ID_PROD, CANTID
		FROM remitos_internos_detalle
		WHERE ID_REMITO=NEW.ID;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=TRUE;

IF NEW.REGISTRADO=1 AND OLD.REGISTRADO<>1		THEN

   /*--- IMPORTANTE !!
   	el comprobante debe INSERTarse como NO REGISTRADA
      porque primero INSERTa remito_interno
      y luego los renglones en _detalle
   ---*/

	SELECT EXISTEN, EXISUMA
		FROM tipocomp
  	WHERE TIPCOM=NEW.COMPRO
   	INTO MEXISTEN, MEXISUMA;

	IF MEXISTEN=1		THEN

		OPEN curRenglones;
		renglones_loop:LOOP

			FETCH curRenglones INTO QID_PROD, QCANTID;
			IF done THEN
    			LEAVE renglones_loop;
	    	END IF;

   	   IF MEXISUMA=1		THEN
      		SET QEXIST=QCANTID;
	      ELSE
   	   	SET QEXIST=-QCANTID;
   		END IF;

         UPDATE productos
         	SET EXISTENTOT=EXISTENTOT+QEXIST
           WHERE ID=QID_PROD;

         INSERT INTO existen (NROSUC, ID_PROD, CANTIDAD)
              VALUES( NEW.NROSUC, QID_PROD, QEXIST )
           ON DUPLICATE KEY UPDATE CANTIDAD=CANTIDAD+QEXIST;

      END LOOP;
		CLOSE curRenglones;

   END IF;

END IF;

END$$

DELIMITER ;

/* Definition for the `tmp_cobranzas_before_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `tmp_cobranzas_before_ins_tr1` BEFORE INSERT ON `tmp_cobranzas`
  FOR EACH ROW
BEGIN
  SET NEW.FECMODIF = CURRENT_TIMESTAMP();
END$$

DELIMITER ;

/* Definition for the `tmp_factu01_nc_after_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `tmp_factu01_nc_after_ins_tr1` AFTER INSERT ON `tmp_factu01_nc`
  FOR EACH ROW
BEGIN

/*--- si se trata de una DEVOLUCION ... ---*/
IF NEW.MOTIVO=1		THEN
	INSERT INTO tmp_factu02_nc
   	(ID_TMP01, REGISTRO_F01, RENGLON_F02,
      	ID_PROD, CANTIDAD, PRECIO)
		SELECT NEW.ID, NEW.REGISTRO_F01, F2.RENGLON_F02,
        		 F2.ID_PROD, F2.CANTIDAD,
             CASE WHEN F2.DCTO=0 OR F2.DCTO IS NULL THEN
             		F2.PRECIO
             ELSE F2.PRECIO-((F2.PRECIO*F2.DCTO)/100) END AS PRECIO
		  FROM factu02 F2
		 WHERE F2.REGISTRO_F01=NEW.REGISTRO_F01;
END IF;

END$$

DELIMITER ;

/* Definition for the `tmp_factu02_nc_before_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `tmp_factu02_nc_before_ins_tr1` BEFORE INSERT ON `tmp_factu02_nc`
  FOR EACH ROW
BEGIN
DECLARE XCANTID DECIMAL(15,3);
DECLARE XDEVUELTO DECIMAL(15,3);

SET NEW.FECMOVIM = CURRENT_TIMESTAMP();

SELECT CANTIDAD FROM factu02
     WHERE RENGLON_F02=NEW.RENGLON_F02
      INTO XCANTID;

SELECT SUM(F2.CANTIDAD) FROM notacredito_factura NC
   INNER JOIN factu02 F2 ON F2.REGISTRO_F01=NC.ID_NC AND F2.ID_PROD=NEW.ID_PROD
	WHERE NC.ID_FACTURA=NEW.REGISTRO_F01
    INTO XDEVUELTO;

IF XDEVUELTO IS NULL		THEN
	SET NEW.ENTREGADO = XCANTID;
ELSE
	SET NEW.ENTREGADO = XCANTID - XDEVUELTO;
END IF;

END$$

DELIMITER ;

/* Definition for the `tmp_pagos_before_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `tmp_pagos_before_ins_tr1` BEFORE INSERT ON `tmp_pagos`
  FOR EACH ROW
BEGIN
  SET NEW.FECMODIF = CURRENT_TIMESTAMP();
END$$

DELIMITER ;

/* Definition for the `usuario_formularios_before_ins_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `usuario_formularios_before_ins_tr1` BEFORE INSERT ON `usuario_formularios`
  FOR EACH ROW
BEGIN
   SET NEW.FECMODIF = CURRENT_TIMESTAMP();
END$$

DELIMITER ;

/* Definition for the `usuario_formularios_before_upd_tr1` trigger : */

DELIMITER $$

CREATE DEFINER = 'root'@'localhost' TRIGGER `usuario_formularios_before_upd_tr1` BEFORE UPDATE ON `usuario_formularios`
  FOR EACH ROW
BEGIN
   SET NEW.FECMODIF = CURRENT_TIMESTAMP();
END$$

DELIMITER ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;