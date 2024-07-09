-- CASO 01
VARIABLE b_run_cliente NUMBER;
VARIABLE b_valor_peso_normal NUMBER;
VARIABLE b_tramo_1 NUMBER;
VARIABLE b_tramo_2 NUMBER;
VARIABLE b_tramo_3 NUMBER;
VARIABLE b_peso_extra_1 NUMBER;
VARIABLE b_peso_extra_2 NUMBER;
VARIABLE b_peso_extra_3 NUMBER;

DECLARE
    v_nro_cliente NUMBER;
    v_run_cliente VARCHAR2(12);
    v_nombre_cliente VARCHAR2(200);
    v_nombre_tipo_cliente VARCHAR2(200);
    v_monto_solic_creditos NUMBER := 0;
    v_monto_pesos_todosuma NUMBER := 0;
    v_monto_pesos_todosuma_extra NUMBER := 0;

BEGIN
    :b_run_cliente := 21242003;-- 21242003, 22176845, 18858542, 21300628, 22558061
    :b_valor_peso_normal := 1200;
    :b_tramo_1 := 1000000;
    :b_tramo_2 := 3000000;
    :b_peso_extra_1 := 100;
    :b_peso_extra_2 := 300;
    :b_peso_extra_3 := 550;
    
    SELECT cli.nro_cliente, 
        LTRIM(REPLACE(TO_CHAR(cli.numrun, '999G999G999'), ',', '.')) || '-' || cli.dvrun AS "run_cliente", 
        pnombre || ' ' || snombre || ' ' || appaterno || ' ' || apmaterno AS "nombre_cliente",
        tipo.nombre_tipo_cliente,
        SUM(cred.monto_solicitado) AS "monto_solicitado"
    INTO v_nro_cliente, v_run_cliente, v_nombre_cliente, v_nombre_tipo_cliente, v_monto_solic_creditos
    FROM cliente cli
    JOIN tipo_cliente tipo
        ON cli.cod_tipo_cliente = tipo.cod_tipo_cliente
    JOIN credito_cliente cred
        ON cli.nro_cliente = cred.nro_cliente
    WHERE cli.numrun = :b_run_cliente 
        AND TO_CHAR(fecha_otorga_cred, 'YYYY') = TO_CHAR(SYSDATE, 'YYYY')-1
    GROUP BY cli.nro_cliente, 
        LTRIM(REPLACE(TO_CHAR(cli.numrun, '999G999G999'), ',', '.')) || '-' || cli.dvrun, 
        pnombre || ' ' || snombre || ' ' || appaterno || ' ' || apmaterno,
        tipo.nombre_tipo_cliente;
    
    v_monto_pesos_todosuma := (v_monto_solic_creditos / 100000) * :b_valor_peso_normal;
    
    IF v_nombre_tipo_cliente LIKE('Trabajadores independientes') THEN
        CASE
            WHEN v_monto_solic_creditos < :b_tramo_1 THEN
                v_monto_pesos_todosuma := v_monto_pesos_todosuma + (v_monto_solic_creditos / 100000) * :b_peso_extra_1;
            WHEN v_monto_solic_creditos > :b_tramo_1 AND v_monto_solic_creditos <= :b_tramo_2  THEN
                v_monto_pesos_todosuma_extra := (v_monto_solic_creditos / 100000) * :b_peso_extra_2;
                v_monto_pesos_todosuma := v_monto_pesos_todosuma + v_monto_pesos_todosuma_extra;
            WHEN v_monto_solic_creditos > :b_tramo_2 THEN
                v_monto_pesos_todosuma_extra := (v_monto_solic_creditos / 100000) * :b_peso_extra_3;
                v_monto_pesos_todosuma := v_monto_pesos_todosuma + v_monto_pesos_todosuma_extra;           
        END CASE;
    END IF;
    
    INSERT INTO cliente_todosuma
    VALUES(v_nro_cliente, v_run_cliente, v_nombre_cliente, v_nombre_tipo_cliente, v_monto_solic_creditos, v_monto_pesos_todosuma);
    
    DBMS_OUTPUT.PUT_LINE('TABLA CLIENTE_TODOSUMA');
    DBMS_OUTPUT.PUT_LINE('nro_cliente: ' || v_nro_cliente);
    DBMS_OUTPUT.PUT_LINE('run_cliente: ' || v_run_cliente);
    DBMS_OUTPUT.PUT_LINE('nombre_cliente: ' || v_nombre_cliente);
    DBMS_OUTPUT.PUT_LINE('nombre_tipo_cliente: ' || v_nombre_tipo_cliente);
    DBMS_OUTPUT.PUT_LINE('monto_solic_creditos: ' || v_monto_solic_creditos);
    DBMS_OUTPUT.PUT_LINE('monto_pesos_todosuma: ' || v_monto_pesos_todosuma);
END;

--SELECT * FROM cliente_todosuma;
/