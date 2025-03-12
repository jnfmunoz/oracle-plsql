-- CASO 01
VARIABLE b_anio_proceso NUMBER;
VARIABLE b_comuna_1 VARCHAR2(255); 
VARIABLE b_comuna_2 VARCHAR2(255);
VARIABLE b_comuna_3 VARCHAR2(255);
VARIABLE b_comuna_4 VARCHAR2(255);
VARIABLE b_comuna_5 VARCHAR2(255);
VARIABLE b_movilizacion_1 NUMBER;
VARIABLE b_movilizacion_2 NUMBER;
VARIABLE b_movilizacion_3 NUMBER;
VARIABLE b_movilizacion_4 NUMBER;
VARIABLE b_movilizacion_5 NUMBER;

DECLARE
    v_dvrun_emp VARCHAR2(255);
    v_id_emp NUMBER;
    v_id_min NUMBER;
    v_id_max NUMBER;
    v_nombre_comuna VARCHAR2(255);
    v_nombre_emp VARCHAR2(255);
    v_numrun_emp VARCHAR2(255);
    v_sueldo_base NUMBER;
    v_porc_movil NUMBER;
    v_total_empleados_procesados NUMBER:= 0;
    v_valor_movil_normal NUMBER;
    v_valor_movil_extra NUMBER;
    v_valor_total_movil NUMBER;
  
BEGIN

    :b_anio_proceso := 2025;
    :b_comuna_1 := 'María Pinto';
    :b_comuna_2 := 'Curacaví';
    :b_comuna_3 := 'Talagante';
    :b_comuna_4 := 'El Monte';
    :b_comuna_5 := 'Buin';
    :b_movilizacion_1 := 20000;
    :b_movilizacion_2 := 25000;
    :b_movilizacion_3 := 30000;
    :b_movilizacion_4 := 35000;
    :b_movilizacion_5 := 40000;
    
    EXECUTE IMMEDIATE ('TRUNCATE TABLE proy_movilizacion');
    
    SELECT MIN(id_emp), MAX(id_emp)
    INTO v_id_min, v_id_max
    FROM empleado;
    
    LOOP
        SELECT emp.sueldo_base, 
            com.nombre_comuna, 
            emp.numrun_emp, 
            emp.dvrun_emp, 
            INITCAP(emp.pnombre_emp || ' ' || emp.snombre_emp || ' ' || emp.appaterno_emp || ' ' || emp.apmaterno_emp)
        INTO v_sueldo_base, v_nombre_comuna, v_numrun_emp, v_dvrun_emp, v_nombre_emp
        FROM empleado emp
            INNER JOIN comuna com
                ON emp.id_comuna = com.id_comuna
        WHERE id_emp = v_id_min;
        
        v_porc_movil := (TRUNC(v_sueldo_base /100000))/100; 
        v_valor_movil_normal := (v_porc_movil * v_sueldo_base);
        
        CASE v_nombre_comuna
            WHEN :b_comuna_1 THEN v_valor_movil_extra := :b_movilizacion_1;
            WHEN :b_comuna_2 THEN v_valor_movil_extra := :b_movilizacion_2;
            WHEN :b_comuna_3 THEN v_valor_movil_extra := :b_movilizacion_3;
            WHEN :b_comuna_4 THEN v_valor_movil_extra := :b_movilizacion_4;
            WHEN :b_comuna_5 THEN v_valor_movil_extra := :b_movilizacion_5;
            ELSE v_valor_movil_extra := 0;
        END CASE;
        
        v_valor_total_movil := ROUND(v_valor_movil_normal + v_valor_movil_extra);
        
        INSERT INTO proy_movilizacion(anno_proceso, id_emp, numrun_emp, dvrun_emp, nombre_empleado, nombre_comuna, 
        sueldo_base, porc_movil_normal, valor_movil_normal, valor_movil_extra, valor_total_movil)
        VALUES(:b_anio_proceso, v_id_min, v_numrun_emp, v_dvrun_emp, v_nombre_emp, v_nombre_comuna, v_sueldo_base, v_porc_movil, 
            v_valor_movil_normal, v_valor_movil_extra, v_valor_total_movil);
        
        IF SQL%ROWCOUNT > 0 THEN
            v_total_empleados_procesados:= v_total_empleados_procesados + 1;
        END IF;
        
        v_id_min := v_id_min + 10;
        EXIT WHEN v_id_min > v_id_max;
        
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Total empleados procesados: ' || v_total_empleados_procesados);
    
END;

