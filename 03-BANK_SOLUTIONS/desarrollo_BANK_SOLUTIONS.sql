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
/
--SELECT * FROM cliente_todosuma;
/
-- CASO 02
VARIABLE b_monto_giftcard_1 NUMBER;
VARIABLE b_monto_giftcard_2 NUMBER;
VARIABLE b_monto_giftcard_3 NUMBER;
VARIABLE b_monto_giftcard_4 NUMBER;
VARIABLE b_monto_giftcard_5 NUMBER;
VARIABLE b_numrun NUMBER;
VARIABLE b_tramo_1 NUMBER;
VARIABLE b_tramo_2 NUMBER;
VARIABLE b_tramo_3 NUMBER;
VARIABLE b_tramo_4 NUMBER;
VARIABLE b_tramo_5 NUMBER;
VARIABLE b_tramo_6 NUMBER;
VARIABLE b_mes_cumpleanno VARCHAR2(200);

DECLARE
    v_nro_cliente NUMBER;
    v_run_cliente VARCHAR2(20);
    v_nombre_cliente VARCHAR2(200);
    v_profesion_oficio VARCHAR2(200);
    v_fecha_nacimiento cliente.fecha_nacimiento%TYPE;
    v_mes_cumpleanno NUMBER;
    v_dia_cumpleanno VARCHAR2(200);
    v_monto_total_ahorrado NUMBER;
    v_monto_giftcard NUMBER;
    v_observacion VARCHAR2(300);
    
BEGIN
    :b_monto_giftcard_1 := 0; 
    :b_monto_giftcard_2 := 50000;
    :b_monto_giftcard_3 := 100000;
    :b_monto_giftcard_4 := 200000;
    :b_monto_giftcard_5 := 300000;
    :b_tramo_1 := 0;
    :b_tramo_2 := 900000;
    :b_tramo_3 := 2000000;
    :b_tramo_4 := 5000000;
    :b_tramo_5 := 8000000;
    :b_tramo_6 := 15000000;
    :b_mes_cumpleanno := TO_CHAR(SYSDATE,'MM')+1;
    
    SELECT cli.nro_cliente,
        LTRIM(REPLACE(TO_CHAR(numrun, '999G999G999'), ',', '.')) || '-' || dvrun AS RUN_CLIENTE,
        INITCAP(pnombre || ' ' || snombre || ' ' || appaterno || ' ' || apmaterno) AS NOMBRE_CLIENTE,
        prof.nombre_prof_ofic AS PROFESION_OFICIO,
        cli.fecha_nacimiento,
        SUM(prod.monto_total_ahorrado) AS MONTO_TOTAL_AHORRADO
    INTO v_nro_cliente, v_run_cliente, v_nombre_cliente, v_profesion_oficio, v_fecha_nacimiento, v_monto_total_ahorrado
    FROM cliente cli
    JOIN profesion_oficio prof
        ON cli.cod_prof_ofic = prof.cod_prof_ofic
    FULL JOIN producto_inversion_cliente prod
        ON cli.nro_cliente = prod.nro_cliente
    WHERE cli.numrun = 24617341 -- 12362093, 07455786, 06604005, 08925537, 24617341
    GROUP BY cli.nro_cliente, LTRIM(REPLACE(TO_CHAR(numrun, '999G999G999'), ',', '.')) || '-' || dvrun,
            INITCAP(pnombre || ' ' || snombre || ' ' || appaterno || ' ' || apmaterno),
            prof.nombre_prof_ofic,
            cli.fecha_nacimiento
    ORDER BY cli.nro_cliente;
    
    v_mes_cumpleanno := TO_CHAR(v_fecha_nacimiento, 'MM');
    v_dia_cumpleanno := TO_CHAR(v_fecha_nacimiento, 'DD')  || ' de ' || TO_CHAR(v_fecha_nacimiento, 'Month');
    
    IF v_monto_total_ahorrado >= :b_tramo_1 AND v_monto_total_ahorrado <= :b_tramo_2 THEN
        v_monto_giftcard := :b_monto_giftcard_1;
    ELSIF v_monto_total_ahorrado > :b_tramo_2 AND v_monto_total_ahorrado <= :b_tramo_3 THEN        
        v_monto_giftcard := :b_monto_giftcard_2;        
    ELSIF v_monto_total_ahorrado > :b_tramo_3 AND v_monto_total_ahorrado <= :b_tramo_4 THEN
        v_monto_giftcard := :b_monto_giftcard_3;
    ELSIF v_monto_total_ahorrado > :b_tramo_4 AND v_monto_total_ahorrado <= :b_tramo_5 THEN
        v_monto_giftcard := :b_monto_giftcard_4;
    ELSIF v_monto_total_ahorrado > :b_tramo_5 AND v_monto_total_ahorrado <= :b_tramo_6 THEN
        v_monto_giftcard := :b_monto_giftcard_5;
    END IF;
    
    IF v_mes_cumpleanno LIKE :b_mes_cumpleanno THEN
        v_observacion := 'El cliente está de cumpleaños en el mes procesado';
    ELSE
        v_observacion := 'El cliente no está de cumpleaños en el mes procesado';
    END IF;
    
    INSERT INTO cumpleanno_cliente(nro_cliente, run_cliente, nombre_cliente, 
                profesion_oficio, dia_cumpleano, monto_gifcard, observacion)
    VALUES(v_nro_cliente, v_run_cliente, v_nombre_cliente, v_profesion_oficio, 
            v_dia_cumpleanno, v_monto_giftcard, v_observacion);
    
    DBMS_OUTPUT.PUT_LINE(v_nro_cliente);
    DBMS_OUTPUT.PUT_LINE(v_run_cliente);
    DBMS_OUTPUT.PUT_LINE(v_nombre_cliente);
    DBMS_OUTPUT.PUT_LINE(v_profesion_oficio);
    DBMS_OUTPUT.PUT_LINE(v_dia_cumpleanno);    
    DBMS_OUTPUT.PUT_LINE(v_monto_giftcard);
    DBMS_OUTPUT.PUT_LINE(v_observacion);

END;
/
-- SELECT * FROM cumpleanno_cliente;
/
-- CASO 03
VARIABLE b_nro_cliente NUMBER;
VARIABLE b_nro_solic_credito NUMBER;
VARIABLE b_cant_cuotas_postergar NUMBER;

DECLARE
    v_nro_cliente NUMBER;
    v_cant_cred_solic NUMBER;
    v_ultima_cuota NUMBER;
    v_tipo_credito NUMBER;
    v_fecha_venc_cuota cuota_credito_cliente.fecha_venc_cuota%TYPE;
    v_valor_cuota NUMBER;
    
BEGIN
    :b_nro_cliente := 5; --5, 67, 13, 
    :b_nro_solic_credito := 2004; -- 2004, 3004, 2001
    :b_cant_cuotas_postergar := 2; -- hasta 2, cant.cuotas[1,1,2]
    
    SELECT nro_cliente,
        COUNT(nro_cliente) AS cant_cred_solic
    INTO v_nro_cliente, v_cant_cred_solic
    FROM credito_cliente
    WHERE TO_CHAR(fecha_solic_cred,'YYYY') = TO_CHAR(SYSDATE, 'YYYY')-1
        AND nro_cliente = :b_nro_cliente
    GROUP BY nro_cliente;
    
    BEGIN 
        SELECT MAX(nro_cuota), cred.cod_credito, MAX(cuota.fecha_venc_cuota), cuota.valor_cuota
        INTO v_ultima_cuota, v_tipo_credito, v_fecha_venc_cuota, v_valor_cuota
        FROM cuota_credito_cliente cuota
        JOIN credito_cliente cred
            ON cuota.nro_solic_credito = cred.nro_solic_credito
        WHERE cred.nro_solic_credito = :b_nro_solic_credito 
        GROUP BY cred.nro_solic_credito, cred.cod_credito, cuota.valor_cuota;
    END;
    
    IF v_cant_cred_solic > 1 THEN
        UPDATE cuota_credito_cliente
        SET fecha_pago_cuota = fecha_venc_cuota,
            monto_pagado = valor_cuota
        WHERE nro_solic_credito = :b_nro_solic_credito
            AND nro_cuota = v_ultima_cuota;
    END IF;
    
    CASE
        WHEN v_tipo_credito = 1 THEN 
            IF :b_cant_cuotas_postergar = 1 THEN
                v_ultima_cuota := v_ultima_cuota +1;
                v_fecha_venc_cuota := ADD_MONTHS(v_fecha_venc_cuota, 1);
                v_valor_cuota := v_valor_cuota;
				INSERT INTO cuota_credito_cliente(nro_solic_credito, nro_cuota, fecha_venc_cuota, valor_cuota)
				VALUES(:b_nro_solic_credito, v_ultima_cuota,v_fecha_venc_cuota, v_valor_cuota);
            ELSIF :b_cant_cuotas_postergar = 2 THEN
                v_valor_cuota := (v_valor_cuota*(0.5/100))+v_valor_cuota;
                FOR x IN 1..2 LOOP
                    v_ultima_cuota := v_ultima_cuota +1;
                    v_fecha_venc_cuota := ADD_MONTHS(v_fecha_venc_cuota, 1);                    
                INSERT INTO cuota_credito_cliente(nro_solic_credito, nro_cuota, fecha_venc_cuota, valor_cuota)
                VALUES(:b_nro_solic_credito, v_ultima_cuota,v_fecha_venc_cuota, v_valor_cuota);
                END LOOP;
            END IF;
        WHEN v_tipo_credito = 2 THEN 
            v_ultima_cuota := v_ultima_cuota +1;
            v_fecha_venc_cuota := ADD_MONTHS(v_fecha_venc_cuota, 1);
            v_valor_cuota := (v_valor_cuota*(1/100))+v_valor_cuota;
            INSERT INTO cuota_credito_cliente(nro_solic_credito, nro_cuota, fecha_venc_cuota, valor_cuota)
            VALUES(:b_nro_solic_credito, v_ultima_cuota,v_fecha_venc_cuota, v_valor_cuota);
        WHEN v_tipo_credito = 3 THEN 
            v_ultima_cuota := v_ultima_cuota +1;
            v_fecha_venc_cuota := ADD_MONTHS(v_fecha_venc_cuota, 1);
            v_valor_cuota := (v_valor_cuota*(2/100))+v_valor_cuota;
            INSERT INTO cuota_credito_cliente(nro_solic_credito, nro_cuota, fecha_venc_cuota, valor_cuota)
            VALUES(:b_nro_solic_credito, v_ultima_cuota,v_fecha_venc_cuota, v_valor_cuota);
    END CASE;

END;
/
-- SELECT * FROM cuota_credito_cliente;