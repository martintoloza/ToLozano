DELIMITER //

DROP FUNCTION IF EXISTS `mysql`.`formula`//

CREATE FUNCTION `mysql`.`formula`(valor DOUBLE(10,5), codcon CHAR(4))
       RETURNS REAL
    BEGIN
       DECLARE salida DOUBLE(10,5) DEFAULT valor;
       IF codcon = 'KGGR' then
          SET salida = valor * 1000;
       else IF codcon = 'GRKG' then
          SET salida = valor / 1000;
       else IF codcon = 'LBKG' then
          SET salida = valor * .5;
       else IF codcon = 'OZKG' then
          SET salida = valor * .03125;
       else IF codcon = 'OZGR' then
          SET salida = valor * 31.25;
       else IF codcon = 'MTKG' then
          SET salida = valor * .00156;
       else
          SET salida = valor * 1;
       end IF;
       RETURN valor;
    END;
//
DELIMITER ;
