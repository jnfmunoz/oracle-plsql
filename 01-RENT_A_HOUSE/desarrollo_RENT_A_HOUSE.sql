--CASO 01
VARIABLE b_porcentaje NUMBER;
VARIABLE b_rut NUMBER;
DECLARE
    v_nombre_empleado VARCHAR2(200);
    v_run_dv VARCHAR2(10);
    v_sueldo empleado.sueldo_emp%TYPE;
    v_bonificacion NUMBER;
    
BEGIN
    :b_porcentaje := 0.4;
    :b_rut := 11846972; --18560875
    SELECT nombre_emp || ' ' || appaterno_emp || ' ' || apmaterno_emp AS NOMBRE_EMPLEADO,
            numrut_emp || '-' || dvrut_emp AS RUN,
            sueldo_emp
    INTO v_nombre_empleado, v_run_dv, v_sueldo
    FROM empleado
    WHERE id_categoria_emp <> 3 AND sueldo_emp < 500000 AND numrut_emp = 11846972;
    
    v_bonificacion := :b_porcentaje * v_sueldo;
    
    DBMS_OUTPUT.PUT_LINE('DATOS CALCULO BONIFICACION EXTRA DEL 40% DEL SUELDO');
    DBMS_OUTPUT.PUT_LINE('Nombre Empleado : ' || v_nombre_empleado);
    DBMS_OUTPUT.PUT_LINE('RUN: ' || v_run_dv);
    DBMS_OUTPUT.PUT_LINE('Sueldo: ' || v_sueldo);
    DBMS_OUTPUT.PUT_LINE('Bonificacion extra: ' || v_bonificacion);
END;

--CASO 02
VARIABLE b_rut_cliente NUMBER;
VARIABLE b_monto_renta NUMBER;
DECLARE
    v_nombre_cliente VARCHAR2(200);
    v_rut_cliente VARCHAR2(10);
    v_estado_civil VARCHAR2(200);
    v_renta VARCHAR2(200);
BEGIN 
    :b_rut_cliente := 12487147; --12861354, 13050258 
    :b_monto_renta := 800000;
    
    SELECT nombre_cli || ' ' || appaterno_cli || ' ' || apmaterno_cli AS "nombre_cliente",
    numrut_cli || '-' || dvrut_cli AS "run",
    est_civ.desc_estcivil AS "estado_civil",
    TO_CHAR(renta_cli, '$999G999G999')
    INTO v_nombre_cliente, v_rut_cliente, v_estado_civil, v_renta
    FROM cliente cli
    JOIN estado_civil est_civ 
        ON cli.id_estcivil  = est_civ.id_estcivil
    WHERE cli.numrut_cli = :b_rut_cliente
    ORDER BY "nombre_cliente","run", "estado_civil" ASC;    
    
    DBMS_OUTPUT.PUT_LINE('DATOS DEL CLIENTE');
    DBMS_OUTPUT.PUT_LINE('-----------------');
    DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre_cliente);
    DBMS_OUTPUT.PUT_LINE('RUN: ' || v_rut_cliente);
    DBMS_OUTPUT.PUT_LINE('Estado Civil: ' || v_estado_civil);
    DBMS_OUTPUT.PUT_LINE('Renta: ' || v_renta);
END;

--CASO 03
VARIABLE b_porcentaje_aumento_1 NUMBER; 
VARIABLE b_porcentaje_aumento_2 NUMBER; 
VARIABLE b_run NUMBER;
DECLARE
    v_nombre_empleado VARCHAR2(200);
    v_run VARCHAR(10);
    v_sueldo NUMBER;
    v_reajuste_1 NUMBER;
    v_reajuste_2 NUMBER;
    v_sueldo_reajustado_1 NUMBER;
    v_sueldo_reajustado_2 NUMBER;
BEGIN
    :b_porcentaje_aumento_1 := 8.5;
    :b_porcentaje_aumento_2 := 20;
    :b_run := 11999100; -- 11999100
    
    SELECT nombre_emp || ' ' || appaterno_emp || ' ' || apmaterno_emp AS "nombre_empleado",
    numrut_emp || '-' || dvrut_emp AS "run",
    sueldo_emp
    INTO v_nombre_empleado, v_run, v_sueldo
    FROM empleado
    WHERE numrut_emp = :b_run;
    
    v_reajuste_1 := ROUND(v_sueldo*(:b_porcentaje_aumento_1/100));
    v_sueldo_reajustado_1 := ROUND(v_sueldo + v_reajuste_1);
    
    IF v_sueldo >= 200000 AND v_sueldo <= 400000 THEN
        v_reajuste_2 := ROUND(v_sueldo*(:b_porcentaje_aumento_2/100));
        v_sueldo_reajustado_2 := ROUND(v_sueldo + v_reajuste_2);
    ELSE
        v_reajuste_2 := 0;
        v_sueldo_reajustado_2 := v_sueldo;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('NOMBRE DEL EMPLEADO : ' || v_nombre_empleado);
    DBMS_OUTPUT.PUT_LINE('RUN: ' || v_run);
    DBMS_OUTPUT.PUT_LINE('SIMULACION 1: Aumentar en 8,5% el salario de todos los empleados');
    DBMS_OUTPUT.PUT_LINE('Sueldo actual: ' || v_sueldo);
    DBMS_OUTPUT.PUT_LINE('Sueldo reajustado: ' || v_sueldo_reajustado_1);
    DBMS_OUTPUT.PUT_LINE('Reajuste: ' || v_reajuste_1);
    DBMS_OUTPUT.PUT_LINE('SIMULACION 2: Aumentar en 20% el salario de los empleados que poseen salarios entre $200.000 y $400.000');
    DBMS_OUTPUT.PUT_LINE('Sueldo actual: ' || v_sueldo);
    DBMS_OUTPUT.PUT_LINE('Sueldo reajustado: ' || v_sueldo_reajustado_2);
    DBMS_OUTPUT.PUT_LINE('Reajuste: ' || v_reajuste_2);
    
END;

--CASO 04
VARIABLE b_tipo_propiedad VARCHAR2(1); 
DECLARE 
    v_desc_tipo_propiedad VARCHAR2(200);
    v_valor_arriendo VARCHAR2(200);
    v_cant_propiedad NUMBER;
BEGIN
    :b_tipo_propiedad := 'A'; -- A..H
    
    SELECT t.desc_tipo_propiedad, 
        TO_CHAR(SUM(p.valor_arriendo), '$999G999G999') AS "valor_arriendo",
        COUNT(t.desc_tipo_propiedad) AS "cant_propiedad"
    INTO v_desc_tipo_propiedad, v_valor_arriendo, v_cant_propiedad
    FROM propiedad p
    JOIN tipo_propiedad t
        ON p.id_tipo_propiedad = t.id_tipo_propiedad
    WHERE t.id_tipo_propiedad = :b_tipo_propiedad
    GROUP BY t.desc_tipo_propiedad;
    
    DBMS_OUTPUT.PUT_LINE('RESUMEN DE: ' || v_desc_tipo_propiedad);
    DBMS_OUTPUT.PUT_LINE('Total de Propiedades: ' || v_cant_propiedad);
    DBMS_OUTPUT.PUT_LINE('Valor Total Arriendo: ' || v_valor_arriendo);
END;