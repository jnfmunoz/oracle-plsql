-- CASO 01
VARIABLE b_anio_proceso NUMBER;
VARIABLE b_comuna_1 NUMBER; -- (117 - María Pinto), (118 - Curacaví),  (119 - Talagante),  (120 - El Monte), (121 - Buin); 
VARIABLE b_comuna_2 NUMBER;
VARIABLE b_comuna_3 NUMBER;
VARIABLE b_comuna_4 NUMBER;
VARIABLE b_comuna_5 NUMBER;
VARIABLE b_movilizacion_1 NUMBER;
VARIABLE b_movilizacion_2 NUMBER;
VARIABLE b_movilizacion_3 NUMBER;
VARIABLE b_movilizacion_4 NUMBER;
VARIABLE b_movilizacion_5 NUMBER;
VARIABLE b_run_empleado NUMBER;
 
 DECLARE    
    v_dvrun_emp NUMBER; 
    v_nombre_empleado VARCHAR(200);
    v_sueldo_base NUMBER;
    v_porc_movil NUMBER;
    v_valor_movil_normal NUMBER;
    v_valor_movil_extra NUMBER;
    v_total_movil NUMBER;
    v_id_comuna NUMBER;
    
 BEGIN
    :b_comuna_1 := 117;
    :b_comuna_2 := 118;
    :b_comuna_3 := 119;
    :b_comuna_4 := 120;
    :b_comuna_5 := 121;
    :b_movilizacion_1 := 20000;
    :b_movilizacion_2 := 25000;
    :b_movilizacion_3 := 30000;
    :b_movilizacion_4 := 35000;
    :b_movilizacion_5 := 40000;
    :b_run_empleado := 11846972; -- 12272880, 12113369, 11999100, 12868553
    :b_anio_proceso := 2024;
    
    SELECT dvrun_emp, pnombre_emp || ' ' || snombre_emp|| ' ' || appaterno_emp || ' ' || apmaterno_emp, 
            sueldo_base, id_comuna
    INTO v_dvrun_emp, v_nombre_empleado, v_sueldo_base, v_id_comuna
    FROM empleado
    WHERE numrun_emp = :b_run_empleado;
    
    v_porc_movil := TRUNC(v_sueldo_base/100000);
    v_valor_movil_normal := ROUND(v_sueldo_base*(v_porc_movil/100));
    
    IF v_id_comuna = :b_comuna_1 THEN 
        v_valor_movil_extra := :b_movilizacion_1;
    ELSIF v_id_comuna = :b_comuna_2 THEN 
        v_valor_movil_extra := :b_movilizacion_2;
    ELSIF v_id_comuna = :b_comuna_3 THEN 
        v_valor_movil_extra := :b_movilizacion_3;
    ELSIF v_id_comuna = :b_comuna_4 THEN 
        v_valor_movil_extra := :b_movilizacion_4;
    ELSIF v_id_comuna = :b_comuna_5 THEN 
        v_valor_movil_extra := :b_movilizacion_5;
    ELSE
        v_valor_movil_extra := 0;
    END IF;
    
    v_total_movil := ROUND(v_valor_movil_normal + v_valor_movil_extra);
    
    INSERT INTO proy_movilizacion
    VALUES(:b_anio_proceso, :b_run_empleado, v_dvrun_emp, v_nombre_empleado, v_sueldo_base, v_porc_movil, 
            v_valor_movil_normal, v_valor_movil_extra, v_total_movil);
       
 END;
 
 -- SELECT * FROM proy_movilizacion;
 
-- CASO 02
VARIABLE b_run_empleado NUMBER;
VARIABLE b_mes_anno NUMBER;

DECLARE
    v_dv_run_emp VARCHAR2(1);
    v_nombre_empleado VARCHAR2(200);
    v_concat_user VARCHAR(200);
    v_anios_trabajados NUMBER;
    v_nombre_usuario VARCHAR2(200);
    v_num_run_emp NUMBER;
    v_anio_nacimiento NUMBER;
    v_sueldo NUMBER;
    v_clave_usuario VARCHAR2(200);
    v_appaterno_emp VARCHAR2(200);
    v_id_estado_civil NUMBER;
    v_nombre_comuna VARCHAR2(200);
    
BEGIN
    :b_run_empleado := 12648200; -- 12648200, 12260812, 12456905, 11649964, 12642309
    :b_mes_anno := TO_CHAR(SYSDATE, 'MMYYYY');
    
    SELECT dvrun_emp, 
            pnombre_emp || ' ' || snombre_emp || ' ' || appaterno_emp || ' ' || apmaterno_emp AS NOMBRE_EMPLEADO, 
            SUBSTR(pnombre_emp,0,3)|| LENGTH(pnombre_emp) || '*' || SUBSTR(sueldo_base, -1) || dvrun_emp AS CONCAT_USER, 
            ROUND((TO_CHAR(SYSDATE, 'YYYYMMDD') - TO_CHAR(fecha_contrato, 'YYYYMMDD')) / 10000) AS anios_trabajados,
            SUBSTR(numrun_emp, 3,1), 
            TO_CHAR(fecha_nac, 'YYYY') AS anio_nacimiento, 
            SUBSTR(sueldo_base-1, -3,3),
            LOWER(appaterno_emp),
            id_estado_civil,
            SUBSTR(com.nombre_comuna, 1,1)
            
    INTO v_dv_run_emp, v_nombre_empleado, v_concat_user, v_anios_trabajados, v_num_run_emp, v_anio_nacimiento, 
            v_sueldo, v_appaterno_emp, v_id_estado_civil, v_nombre_comuna
    FROM empleado emp
    JOIN comuna  com
        ON emp.id_comuna = com.id_comuna
    WHERE :b_run_empleado = numrun_emp;
    
    v_anio_nacimiento := v_anio_nacimiento + 2;
    
    IF v_anios_trabajados < 10 THEN 
        v_nombre_usuario := v_concat_user || v_anios_trabajados || 'X';
    ELSE
        v_nombre_usuario := v_concat_user || v_anios_trabajados;    
    END IF;
    
    IF v_id_estado_civil = 10 OR v_id_estado_civil = 60 THEN
        v_appaterno_emp := SUBSTR(v_appaterno_emp, 0,2);
    ELSIF v_id_estado_civil = 20 OR v_id_estado_civil = 30 THEN
        v_appaterno_emp := SUBSTR(v_appaterno_emp, 1, 1) ||  SUBSTR(v_appaterno_emp, -1, 1);
    ELSIF v_id_estado_civil = 40 THEN
        v_appaterno_emp := SUBSTR(v_appaterno_emp, -3, 2);
    ELSIF v_id_estado_civil = 50 THEN 
        v_appaterno_emp := SUBSTR(v_appaterno_emp, -2, 2);
    END IF;

    v_clave_usuario := v_num_run_emp || v_anio_nacimiento || v_sueldo || v_appaterno_emp || :b_mes_anno || v_nombre_comuna;

    INSERT INTO usuario_clave
    VALUES(:b_mes_anno, :b_run_empleado, v_dv_run_emp, v_nombre_empleado, v_nombre_usuario, v_clave_usuario);
    
    dbms_output.put_line('Datos insertados con éxito!');
    dbms_output.put_line('MES_ANNO: ' || :b_mes_anno);    
    dbms_output.put_line('NUMRUN_EMP: ' || :b_run_empleado);    
    dbms_output.put_line('DVRUN_EMP: ' || v_dv_run_emp);    
    dbms_output.put_line('NOMBRE_EMPLEADO: ' || v_nombre_empleado);    
    dbms_output.put_line('NOMBRE_USUARIO: ' || v_nombre_usuario);    
    dbms_output.put_line('CLAVE_USUARIO: ' || v_clave_usuario);    
    
END;

-- SELECT * FROM usuario_clave;