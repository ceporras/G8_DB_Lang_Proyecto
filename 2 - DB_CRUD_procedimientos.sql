---------------
--Procedimientos almacenados
--Tabla CINE_TB
---------------

CREATE OR REPLACE PROCEDURE SP_INSERTAR_CINE (
    p_id_generado OUT CINE_TB.ID_CINE%TYPE,
    p_nombre IN CINE_TB.NOMBRE%TYPE,
    p_direccion IN CINE_TB.DIRECCION%TYPE DEFAULT NULL,
    p_telefono IN CINE_TB.TELEFONO%TYPE DEFAULT NULL,
    p_estado IN CINE_TB.ESTADO%TYPE DEFAULT 1
) IS
BEGIN
    INSERT INTO CINE_TB (NOMBRE, DIRECCION, TELEFONO, ESTADO)
    VALUES (p_nombre, p_direccion, p_telefono, p_estado)
    RETURNING ID_CINE INTO p_id_generado;
END;
---
--NOTA: WHERE p_id IS NULL is en caso que no se especifique cual cine consultar (devolver todos)
CREATE OR REPLACE PROCEDURE SP_CONSULTAR_CINE (
        p_cursor OUT SYS_REFCURSOR,
        p_id IN CINE_TB.ID_CINE%TYPE DEFAULT NULL
    ) IS
    BEGIN
        OPEN p_cursor FOR SELECT * FROM CINE_TB
             WHERE p_id IS NULL OR ID_CINE = p_id ORDER BY ID_CINE;
END;

----
CREATE OR REPLACE PROCEDURE SP_ACTUALIZAR_CINE (
        p_id IN CINE_TB.ID_CINE%TYPE,
        p_nombre IN CINE_TB.NOMBRE%TYPE,
        p_direccion IN CINE_TB.DIRECCION%TYPE,
        p_telefono IN CINE_TB.TELEFONO%TYPE,
        p_estado IN CINE_TB.ESTADO%TYPE
    ) IS
    BEGIN
        UPDATE CINE_TB
           SET NOMBRE = p_nombre, DIRECCION = p_direccion, TELEFONO = p_telefono,
                ESTADO = p_estado WHERE ID_CINE = p_id;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'No existe un cine para el ID indicado.');
        END IF;
END;
----
CREATE OR REPLACE PROCEDURE SP_ELIMINAR_CINE (
        p_id IN CINE_TB.ID_CINE%TYPE
    ) IS
    BEGIN
        DELETE FROM CINE_TB WHERE ID_CINE = p_id;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'No existe un cine para el ID indicado.');
        END IF;
END;

---------------
--Procedimientos almacenados
--Tabla SALA_TB
---------------

CREATE OR REPLACE PROCEDURE SP_INSERTAR_SALA (
        p_id_generado OUT SALA_TB.ID_SALA%TYPE,
        p_id_cine IN SALA_TB.ID_CINE%TYPE,
        p_nombre IN SALA_TB.NOMBRE%TYPE,
        p_capacidad IN SALA_TB.CAPACIDAD%TYPE,
        p_tipopantalla IN SALA_TB.TIPOPANTALLA%TYPE
    ) IS
    BEGIN
        INSERT INTO SALA_TB (ID_CINE, NOMBRE, CAPACIDAD, TIPOPANTALLA)
        VALUES (p_id_cine, p_nombre, p_capacidad, p_tipopantalla)
        RETURNING ID_SALA INTO p_id_generado;
    EXCEPTION
        WHEN OTHERS THEN
        -- para evitar ORA-2291 --> parent key not found
        IF SQLCODE = -2291 THEN
            RAISE_APPLICATION_ERROR(-20001, 'No existe un cine para el ID indicado.');
        END IF;       
END;
---
CREATE OR REPLACE PROCEDURE P_CONSULTAR_SALA (
        p_cursor OUT SYS_REFCURSOR,
        p_id IN SALA_TB.ID_SALA%TYPE DEFAULT NULL
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT * FROM SALA_TB WHERE p_id IS NULL OR ID_SALA = p_id
             ORDER BY ID_SALA;
END;
---
CREATE OR REPLACE PROCEDURE P_ACTUALIZAR_SALA (
        p_id IN SALA_TB.ID_SALA%TYPE,
        p_id_cine IN SALA_TB.ID_CINE%TYPE,
        p_nombre IN SALA_TB.NOMBRE%TYPE,
        p_capacidad IN SALA_TB.CAPACIDAD%TYPE,
        p_tipopantalla IN SALA_TB.TIPOPANTALLA%TYPE
    ) IS
    BEGIN
        UPDATE SALA_TB SET ID_CINE = p_id_cine, NOMBRE = p_nombre,
                   CAPACIDAD = p_capacidad, TIPOPANTALLA = p_tipopantalla
         WHERE ID_SALA = p_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'No existe una sala para el ID indicado.');
        END IF;
END;
---
CREATE OR REPLACE PROCEDURE P_ELIMINAR_SALA (
        p_id IN SALA_TB.ID_SALA%TYPE
    ) IS
    BEGIN
        DELETE FROM SALA_TB WHERE ID_SALA = p_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'No existe una sala para el ID indicado.');
        END IF;
END;

---------------
--Procedimientos almacenados
--Tabla ASIENTO_TB
---------------

CREATE OR REPLACE PROCEDURE SP_INSERTAR_ASIENTO (
        p_id_generado OUT ASIENTO_TB.ID_ASIENTO%TYPE,
        p_id_sala IN ASIENTO_TB.ID_SALA%TYPE,
        p_fila IN ASIENTO_TB.FILA%TYPE,
        p_numero IN ASIENTO_TB.NUMERO%TYPE,
        p_tipoasiento IN ASIENTO_TB.TIPOASIENTO%TYPE DEFAULT 'Estandar'
    ) IS
    BEGIN
        INSERT INTO ASIENTO_TB (ID_SALA, FILA, NUMERO, TIPOASIENTO)
        VALUES (p_id_sala, p_fila, p_numero, NVL(p_tipoasiento, 'Estandar'))
        RETURNING ID_ASIENTO INTO p_id_generado;
        
        EXCEPTION
        WHEN OTHERS THEN
        -- para evitar ORA-2291 --> parent key not found
        IF SQLCODE = -2291 THEN
            RAISE_APPLICATION_ERROR(-20001, 'No existe una referencia para el ID indicado.');
        END IF;   
END;
---
CREATE OR REPLACE PROCEDURE SP_CONSULTAR_ASIENTO (
        p_cursor OUT SYS_REFCURSOR,
        p_id IN ASIENTO_TB.ID_ASIENTO%TYPE DEFAULT NULL
    ) IS
    BEGIN
        OPEN p_cursor FOR SELECT * FROM ASIENTO_TB
             WHERE p_id IS NULL OR ID_ASIENTO = p_id ORDER BY ID_ASIENTO;
END;
---
CREATE OR REPLACE PROCEDURE SP_ACTUALIZAR_ASIENTO (
        p_id IN ASIENTO_TB.ID_ASIENTO%TYPE,
        p_id_sala IN ASIENTO_TB.ID_SALA%TYPE,
        p_fila IN ASIENTO_TB.FILA%TYPE,
        p_numero IN ASIENTO_TB.NUMERO%TYPE,
        p_tipoasiento IN ASIENTO_TB.TIPOASIENTO%TYPE
    ) IS
    BEGIN
        UPDATE ASIENTO_TB SET ID_SALA = p_id_sala, FILA = p_fila, NUMERO = p_numero,
            TIPOASIENTO = p_tipoasiento WHERE ID_ASIENTO = p_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'No existe un asiento para el ID indicado.');
        END IF;
END;
---
CREATE OR REPLACE PROCEDURE SP_ELIMINAR_ASIENTO (
        p_id IN ASIENTO_TB.ID_ASIENTO%TYPE
    ) IS
    BEGIN
        DELETE FROM ASIENTO_TB WHERE ID_ASIENTO = p_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'No existe un asiento para el ID indicado.');
        END IF;
END;

---------------
--Procedimientos almacenados
--Tabla GENERO_TB
---------------

CREATE OR REPLACE PROCEDURE SP_INSERTAR_GENERO (
        p_id_generado OUT GENERO_TB.ID_GENERO%TYPE,
        p_nombre IN GENERO_TB.NOMBRE%TYPE
    ) IS
    BEGIN
        INSERT INTO GENERO_TB (NOMBRE) VALUES (p_nombre)
        RETURNING ID_GENERO INTO p_id_generado;
END;
---
CREATE OR REPLACE PROCEDURE SP_CONSULTAR_GENERO (
        p_cursor OUT SYS_REFCURSOR,
        p_id IN GENERO_TB.ID_GENERO%TYPE DEFAULT NULL
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT *
              FROM GENERO_TB
             WHERE p_id IS NULL OR ID_GENERO = p_id
             ORDER BY ID_GENERO;
END;
---
CREATE OR REPLACE PROCEDURE SP_ACTUALIZAR_GENERO (
        p_id IN GENERO_TB.ID_GENERO%TYPE,
        p_nombre IN GENERO_TB.NOMBRE%TYPE
    ) IS
    BEGIN
        UPDATE GENERO_TB
           SET                    NOMBRE = p_nombre
         WHERE ID_GENERO = p_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'No existe un genero para el ID indicado.');
        END IF;
END;
---
CREATE OR REPLACE PROCEDURE SP_ELIMINAR_GENERO (
        p_id IN GENERO_TB.ID_GENERO%TYPE
    ) IS
    BEGIN
        DELETE FROM GENERO_TB WHERE ID_GENERO = p_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'No existe un genero para el ID indicado.');
        END IF;
END;

---------------
--Procedimientos almacenados
--Tabla PELICULA_TB
---------------


CREATE OR REPLACE PROCEDURE SP_INSERTAR_PELICULA (
        p_id_generado OUT PELICULA_TB.ID_PELICULA%TYPE,
        p_titulo IN PELICULA_TB.TITULO%TYPE,
        p_duracion IN PELICULA_TB.DURACION%TYPE,
        p_clasificacion IN PELICULA_TB.CLASIFICACION%TYPE,
        p_fechaestreno IN PELICULA_TB.FECHAESTRENO%TYPE,
        p_idioma IN PELICULA_TB.IDIOMA%TYPE,
        p_sinopsis IN PELICULA_TB.SINOPSIS%TYPE DEFAULT NULL,
        p_urltrailer IN PELICULA_TB.URLTRAILER%TYPE DEFAULT NULL,
        p_urlposter IN PELICULA_TB.URLPOSTER%TYPE DEFAULT NULL,
        p_estado IN PELICULA_TB.ESTADO%TYPE DEFAULT 1
    ) IS
    BEGIN
        INSERT INTO PELICULA_TB (TITULO, SINOPSIS, DURACION, CLASIFICACION, FECHAESTRENO, URLTRAILER, URLPOSTER, ESTADO, IDIOMA)
        VALUES (p_titulo, p_sinopsis, p_duracion, p_clasificacion, p_fechaestreno, p_urltrailer, p_urlposter, NVL(p_estado, 1), p_idioma)
        RETURNING ID_PELICULA INTO p_id_generado;
END;
---
CREATE OR REPLACE PROCEDURE SP_CONSULTAR_PELICULA (
        p_cursor OUT SYS_REFCURSOR,
        p_id IN PELICULA_TB.ID_PELICULA%TYPE DEFAULT NULL
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT *
              FROM PELICULA_TB
             WHERE p_id IS NULL OR ID_PELICULA = p_id
             ORDER BY ID_PELICULA;
END;
---
CREATE OR REPLACE PROCEDURE SP_ACTUALIZAR_PELICULA (
        p_id IN PELICULA_TB.ID_PELICULA%TYPE,
        p_titulo IN PELICULA_TB.TITULO%TYPE,
        p_sinopsis IN PELICULA_TB.SINOPSIS%TYPE,
        p_duracion IN PELICULA_TB.DURACION%TYPE,
        p_clasificacion IN PELICULA_TB.CLASIFICACION%TYPE,
        p_fechaestreno IN PELICULA_TB.FECHAESTRENO%TYPE,
        p_urltrailer IN PELICULA_TB.URLTRAILER%TYPE,
        p_urlposter IN PELICULA_TB.URLPOSTER%TYPE,
        p_estado IN PELICULA_TB.ESTADO%TYPE,
        p_idioma IN PELICULA_TB.IDIOMA%TYPE
    ) IS
    BEGIN
        UPDATE PELICULA_TB
           SET     TITULO = p_titulo, SINOPSIS = p_sinopsis, DURACION = p_duracion,
                   CLASIFICACION = p_clasificacion, FECHAESTRENO = p_fechaestreno,
                   URLTRAILER = p_urltrailer, URLPOSTER = p_urlposter, ESTADO = p_estado,
                   IDIOMA = p_idioma WHERE ID_PELICULA = p_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'No existe registro una pelicula para el ID indicado.');
        END IF;
END;
---
CREATE OR REPLACE PROCEDURE SP_ELIMINAR_PELICULA (
        p_id IN PELICULA_TB.ID_PELICULA%TYPE
    ) IS
    BEGIN
        DELETE FROM PELICULA_TB WHERE ID_PELICULA = p_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'No existe una pelicula para el ID indicado.');
        END IF;
END;


---------------
--Procedimientos almacenados
--Tabla PELICULA_GENERO_TB
---------------

CREATE OR REPLACE PROCEDURE SP_INSERTAR_PELICULA_GENERO (
        p_id_pelicula IN PELICULA_GENERO_TB.ID_PELICULA%TYPE,
        p_id_genero IN PELICULA_GENERO_TB.ID_GENERO%TYPE
    ) IS
    BEGIN
        INSERT INTO PELICULA_GENERO_TB (ID_PELICULA, ID_GENERO)
        VALUES (p_id_pelicula, p_id_genero);
END;

CREATE OR REPLACE PROCEDURE SP_CONSULTAR_PELICULA_GENERO (
        p_cursor OUT SYS_REFCURSOR,
        p_id_pelicula IN PELICULA_GENERO_TB.ID_PELICULA%TYPE DEFAULT NULL,
        p_id_genero IN PELICULA_GENERO_TB.ID_GENERO%TYPE DEFAULT NULL
    ) IS
    BEGIN
        OPEN p_cursor FOR SELECT * FROM PELICULA_GENERO_TB
             WHERE (p_id_pelicula IS NULL OR ID_PELICULA = p_id_pelicula)
               AND (p_id_genero IS NULL OR ID_GENERO = p_id_genero)
             ORDER BY ID_PELICULA, ID_GENERO;
END;

CREATE OR REPLACE PROCEDURE SP_ACTUALIZAR_PELICULA_GENERO (
        p_id_pelicula_actual IN PELICULA_GENERO_TB.ID_PELICULA%TYPE,
        p_id_genero_actual IN PELICULA_GENERO_TB.ID_GENERO%TYPE,
        p_id_pelicula_nuevo IN PELICULA_GENERO_TB.ID_PELICULA%TYPE,
        p_id_genero_nuevo IN PELICULA_GENERO_TB.ID_GENERO%TYPE
    ) IS
    BEGIN
        UPDATE PELICULA_GENERO_TB SET ID_PELICULA = p_id_pelicula_nuevo,
               ID_GENERO = p_id_genero_nuevo
         WHERE ID_PELICULA = p_id_pelicula_actual AND ID_GENERO = p_id_genero_actual;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'No existe la relacion pelicula-genero indicada.');
        END IF;
END;

CREATE OR REPLACE PROCEDURE SP_ELIMINAR_PELICULA_GENERO (
        p_id_pelicula IN PELICULA_GENERO_TB.ID_PELICULA%TYPE,
        p_id_genero IN PELICULA_GENERO_TB.ID_GENERO%TYPE
    ) IS
    BEGIN
        DELETE FROM PELICULA_GENERO_TB WHERE ID_PELICULA = p_id_pelicula
           AND ID_GENERO = p_id_genero;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'No existe la relacion pelicula-genero indicada.');
        END IF;
END;

---------------
--Procedimientos almacenados
--Tabla FUNCION_TB
---------------

CREATE OR REPLACE PROCEDURE SP_INSERTAR_FUNCION (
        p_id_generado OUT FUNCION_TB.ID_FUNCION%TYPE,
        p_id_pelicula IN FUNCION_TB.ID_PELICULA%TYPE,
        p_id_sala IN FUNCION_TB.ID_SALA%TYPE,
        p_horainicio IN FUNCION_TB.HORAINICIO%TYPE,
        p_horafin IN FUNCION_TB.HORAFIN%TYPE,
        p_idioma IN FUNCION_TB.IDIOMA%TYPE DEFAULT NULL,
        p_formato IN FUNCION_TB.FORMATO%TYPE DEFAULT NULL
    ) IS
        v_traslape NUMBER;
    BEGIN
        IF p_horafin <= p_horainicio THEN
            RAISE_APPLICATION_ERROR(-20003, 'La hora de fin debe ser posterior a la hora de inicio.');
        END IF;
 
        -- una sala no puede tener dos funciones al mismo tiempo
        SELECT COUNT(*) INTO v_traslape FROM FUNCION_TB
         WHERE ID_SALA = p_id_sala
           AND HORAINICIO < p_horafin AND HORAFIN > p_horainicio;
        IF v_traslape > 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'La sala ya tiene una funcion programada en ese horario.');
        END IF;
 
        INSERT INTO FUNCION_TB (ID_PELICULA, ID_SALA, HORAINICIO, HORAFIN, IDIOMA, FORMATO)
        VALUES (p_id_pelicula, p_id_sala, p_horainicio, p_horafin, p_idioma, p_formato)
        RETURNING ID_FUNCION INTO p_id_generado;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -2291 THEN
                RAISE_APPLICATION_ERROR(-20001, 'No existe la pelicula o la sala indicada.');
            ELSE
                RAISE;
            END IF;
END;
/

CREATE OR REPLACE PROCEDURE SP_CONSULTAR_FUNCION (
        p_cursor OUT SYS_REFCURSOR,
        p_id IN FUNCION_TB.ID_FUNCION%TYPE DEFAULT NULL,
        p_id_pelicula IN FUNCION_TB.ID_PELICULA%TYPE DEFAULT NULL
    ) IS
    BEGIN
        OPEN p_cursor FOR SELECT * FROM FUNCION_TB
             WHERE (p_id IS NULL OR ID_FUNCION = p_id)
               AND (p_id_pelicula IS NULL OR ID_PELICULA = p_id_pelicula)
             ORDER BY ID_FUNCION;
END;
/

CREATE OR REPLACE PROCEDURE SP_ACTUALIZAR_FUNCION (
        p_id IN FUNCION_TB.ID_FUNCION%TYPE,
        p_id_pelicula IN FUNCION_TB.ID_PELICULA%TYPE,
        p_id_sala IN FUNCION_TB.ID_SALA%TYPE,
        p_horainicio IN FUNCION_TB.HORAINICIO%TYPE,
        p_horafin IN FUNCION_TB.HORAFIN%TYPE,
        p_idioma IN FUNCION_TB.IDIOMA%TYPE,
        p_formato IN FUNCION_TB.FORMATO%TYPE
    ) IS
        v_traslape NUMBER;
    BEGIN
        IF p_horafin <= p_horainicio THEN
            RAISE_APPLICATION_ERROR(-20003, 'La hora de fin debe ser posterior a la hora de inicio.');
        END IF;
 
        -- se excluye la propia funcion para que no choque consigo misma
        SELECT COUNT(*) INTO v_traslape FROM FUNCION_TB
         WHERE ID_SALA = p_id_sala AND ID_FUNCION <> p_id
           AND HORAINICIO < p_horafin AND HORAFIN > p_horainicio;
        IF v_traslape > 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'La sala ya tiene una funcion programada en ese horario.');
        END IF;
 
        UPDATE FUNCION_TB
           SET ID_PELICULA = p_id_pelicula, ID_SALA = p_id_sala, HORAINICIO = p_horainicio,
               HORAFIN = p_horafin, IDIOMA = p_idioma, FORMATO = p_formato
         WHERE ID_FUNCION = p_id;
 
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'No existe una funcion para el ID indicado.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -2291 THEN
                RAISE_APPLICATION_ERROR(-20001, 'No existe la pelicula o la sala indicada.');
            ELSE
                RAISE;
            END IF;
END;
/

CREATE OR REPLACE PROCEDURE SP_ELIMINAR_FUNCION (
        p_id IN FUNCION_TB.ID_FUNCION%TYPE
    ) IS
    BEGIN
        DELETE FROM FUNCION_TB WHERE ID_FUNCION = p_id;
 
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'No existe una funcion para el ID indicado.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -2292 THEN
                RAISE_APPLICATION_ERROR(-20005, 'No se puede eliminar la funcion porque tiene boletos vendidos.');
            ELSE
                RAISE;
            END IF;
END;
/
 
---------------
--Procedimientos almacenados
--Tabla PROMOCION_TB
---------------
 
CREATE OR REPLACE PROCEDURE SP_INSERTAR_PROMOCION (
        p_id_generado OUT PROMOCION_TB.ID_PROMOCION%TYPE,
        p_nombre IN PROMOCION_TB.NOMBRE%TYPE,
        p_porcentajedescuento IN PROMOCION_TB.PORCENTAJEDESCUENTO%TYPE,
        p_codigo IN PROMOCION_TB.CODIGO%TYPE DEFAULT NULL,
        p_fechainicio IN PROMOCION_TB.FECHAINICIO%TYPE DEFAULT NULL,
        p_fechafin IN PROMOCION_TB.FECHAFIN%TYPE DEFAULT NULL,
        p_estado IN PROMOCION_TB.ESTADO%TYPE DEFAULT 1
    ) IS
    BEGIN
        -- el codigo se guarda en mayusculas y sin espacios para que "verano10" y "VERANO10" sean el mismo
        INSERT INTO PROMOCION_TB (CODIGO, NOMBRE, PORCENTAJEDESCUENTO, FECHAINICIO, FECHAFIN, ESTADO)
        VALUES (UPPER(TRIM(p_codigo)), p_nombre, p_porcentajedescuento, p_fechainicio, p_fechafin, NVL(p_estado, 1))
        RETURNING ID_PROMOCION INTO p_id_generado;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1 THEN
                RAISE_APPLICATION_ERROR(-20004, 'Ya existe una promocion con ese codigo.');
            ELSIF SQLCODE = -2290 THEN
                RAISE_APPLICATION_ERROR(-20003, 'Descuento fuera del rango 0-100, estado invalido o fecha fin anterior a fecha inicio.');
            ELSE
                RAISE;
            END IF;
END;
/

CREATE OR REPLACE PROCEDURE SP_CONSULTAR_PROMOCION (
        p_cursor OUT SYS_REFCURSOR,
        p_id IN PROMOCION_TB.ID_PROMOCION%TYPE DEFAULT NULL
    ) IS
    BEGIN
        OPEN p_cursor FOR SELECT * FROM PROMOCION_TB
             WHERE p_id IS NULL OR ID_PROMOCION = p_id ORDER BY ID_PROMOCION;
END;
/

CREATE OR REPLACE PROCEDURE SP_ACTUALIZAR_PROMOCION (
        p_id IN PROMOCION_TB.ID_PROMOCION%TYPE,
        p_codigo IN PROMOCION_TB.CODIGO%TYPE,
        p_nombre IN PROMOCION_TB.NOMBRE%TYPE,
        p_porcentajedescuento IN PROMOCION_TB.PORCENTAJEDESCUENTO%TYPE,
        p_fechainicio IN PROMOCION_TB.FECHAINICIO%TYPE,
        p_fechafin IN PROMOCION_TB.FECHAFIN%TYPE,
        p_estado IN PROMOCION_TB.ESTADO%TYPE
    ) IS
    BEGIN
        UPDATE PROMOCION_TB
           SET CODIGO = UPPER(TRIM(p_codigo)), NOMBRE = p_nombre,
               PORCENTAJEDESCUENTO = p_porcentajedescuento, FECHAINICIO = p_fechainicio,
               FECHAFIN = p_fechafin, ESTADO = p_estado
         WHERE ID_PROMOCION = p_id;
 
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'No existe una promocion para el ID indicado.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1 THEN
                RAISE_APPLICATION_ERROR(-20004, 'Ya existe una promocion con ese codigo.');
            ELSIF SQLCODE = -2290 THEN
                RAISE_APPLICATION_ERROR(-20003, 'Descuento fuera del rango 0-100, estado invalido o fecha fin anterior a fecha inicio.');
            ELSE
                RAISE;
            END IF;
END;
/

CREATE OR REPLACE PROCEDURE SP_ELIMINAR_PROMOCION (
        p_id IN PROMOCION_TB.ID_PROMOCION%TYPE
    ) IS
    BEGIN
        DELETE FROM PROMOCION_TB WHERE ID_PROMOCION = p_id;
 
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'No existe una promocion para el ID indicado.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -2292 THEN
                RAISE_APPLICATION_ERROR(-20005, 'No se puede eliminar la promocion porque ya fue usada en ordenes. Desactivela en su lugar.');
            ELSE
                RAISE;
            END IF;
END;
/
 
---------------
--Procedimientos almacenados
--Tabla CLIENTE_TB
---------------
 
CREATE OR REPLACE PROCEDURE SP_INSERTAR_CLIENTE (
        p_id_generado OUT CLIENTE_TB.ID_CLIENTE%TYPE,
        p_nombre IN CLIENTE_TB.NOMBRE%TYPE,
        p_apellidopaterno IN CLIENTE_TB.APELLIDOPATERNO%TYPE,
        p_correo IN CLIENTE_TB.CORREO%TYPE,
        p_contrasenna IN CLIENTE_TB.CONTRASENNA%TYPE,
        p_apellidomaterno IN CLIENTE_TB.APELLIDOMATERNO%TYPE DEFAULT NULL,
        p_telefono IN CLIENTE_TB.TELEFONO%TYPE DEFAULT NULL
    ) IS
    BEGIN
        IF p_contrasenna IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'La contrasenna es obligatoria.');
        END IF;
 
        -- el correo se guarda en minusculas para que no se registre dos veces con distinta capitalizacion
        INSERT INTO CLIENTE_TB (NOMBRE, APELLIDOPATERNO, APELLIDOMATERNO, CORREO, TELEFONO, CONTRASENNA)
        VALUES (p_nombre, p_apellidopaterno, p_apellidomaterno, LOWER(TRIM(p_correo)), p_telefono, p_contrasenna)
        RETURNING ID_CLIENTE INTO p_id_generado;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1 THEN
                RAISE_APPLICATION_ERROR(-20004, 'Ya existe un cliente registrado con ese correo.');
            ELSE
                RAISE;
            END IF;
END;
/

CREATE OR REPLACE PROCEDURE SP_CONSULTAR_CLIENTE (
        p_cursor OUT SYS_REFCURSOR,
        p_id IN CLIENTE_TB.ID_CLIENTE%TYPE DEFAULT NULL
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT ID_CLIENTE, NOMBRE, APELLIDOPATERNO, APELLIDOMATERNO, CORREO,
                   TELEFONO, FECHAREGISTRO
              FROM CLIENTE_TB
             WHERE p_id IS NULL OR ID_CLIENTE = p_id
             ORDER BY ID_CLIENTE;
END;
/

CREATE OR REPLACE PROCEDURE SP_ACTUALIZAR_CLIENTE (
        p_id IN CLIENTE_TB.ID_CLIENTE%TYPE,
        p_nombre IN CLIENTE_TB.NOMBRE%TYPE,
        p_apellidopaterno IN CLIENTE_TB.APELLIDOPATERNO%TYPE,
        p_apellidomaterno IN CLIENTE_TB.APELLIDOMATERNO%TYPE,
        p_correo IN CLIENTE_TB.CORREO%TYPE,
        p_telefono IN CLIENTE_TB.TELEFONO%TYPE
    ) IS
    BEGIN
        UPDATE CLIENTE_TB
           SET NOMBRE = p_nombre, APELLIDOPATERNO = p_apellidopaterno,
               APELLIDOMATERNO = p_apellidomaterno, CORREO = LOWER(TRIM(p_correo)),
               TELEFONO = p_telefono
         WHERE ID_CLIENTE = p_id;
 
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'No existe un cliente para el ID indicado.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1 THEN
                RAISE_APPLICATION_ERROR(-20004, 'Ya existe un cliente registrado con ese correo.');
            ELSE
                RAISE;
            END IF;
END;
/

CREATE OR REPLACE PROCEDURE SP_ACTUALIZAR_CONTRASENNA_CLIENTE (
        p_id IN CLIENTE_TB.ID_CLIENTE%TYPE,
        p_contrasenna IN CLIENTE_TB.CONTRASENNA%TYPE
    ) IS
    BEGIN
        IF p_contrasenna IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'La contrasenna es obligatoria.');
        END IF;
 
        UPDATE CLIENTE_TB SET CONTRASENNA = p_contrasenna WHERE ID_CLIENTE = p_id;
 
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'No existe un cliente para el ID indicado.');
        END IF;
END;
/

CREATE OR REPLACE PROCEDURE SP_ELIMINAR_CLIENTE (
        p_id IN CLIENTE_TB.ID_CLIENTE%TYPE
    ) IS
    BEGIN
        DELETE FROM CLIENTE_TB WHERE ID_CLIENTE = p_id;
 
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'No existe un cliente para el ID indicado.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -2292 THEN
                RAISE_APPLICATION_ERROR(-20005, 'No se puede eliminar el cliente porque tiene ordenes registradas.');
            ELSE
                RAISE;
            END IF;
END;
/
 
---------------
--Procedimientos almacenados
--Tabla ORDEN_TB
---------------
 
CREATE OR REPLACE PROCEDURE SP_INSERTAR_ORDEN (
        p_id_generado OUT ORDEN_TB.ID_ORDEN%TYPE,
        p_id_cliente IN ORDEN_TB.ID_CLIENTE%TYPE,
        p_id_promocion IN ORDEN_TB.ID_PROMOCION%TYPE DEFAULT NULL
    ) IS
    BEGIN
        INSERT INTO ORDEN_TB (ID_CLIENTE, ID_PROMOCION)
        VALUES (p_id_cliente, p_id_promocion)
        RETURNING ID_ORDEN INTO p_id_generado;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -2291 THEN
                RAISE_APPLICATION_ERROR(-20001, 'No existe el cliente o la promocion indicada.');
            ELSE
                RAISE;
            END IF;
END;
/

CREATE OR REPLACE PROCEDURE SP_CONSULTAR_ORDEN (
        p_cursor OUT SYS_REFCURSOR,
        p_id IN ORDEN_TB.ID_ORDEN%TYPE DEFAULT NULL,
        p_id_cliente IN ORDEN_TB.ID_CLIENTE%TYPE DEFAULT NULL
    ) IS
    BEGIN
        OPEN p_cursor FOR SELECT * FROM ORDEN_TB
             WHERE (p_id IS NULL OR ID_ORDEN = p_id)
               AND (p_id_cliente IS NULL OR ID_CLIENTE = p_id_cliente)
             ORDER BY ID_ORDEN;
END;
/

CREATE OR REPLACE PROCEDURE SP_ACTUALIZAR_ORDEN (
        p_id IN ORDEN_TB.ID_ORDEN%TYPE,
        p_id_promocion IN ORDEN_TB.ID_PROMOCION%TYPE,
        p_estado IN ORDEN_TB.ESTADO%TYPE,
        p_subtotal IN ORDEN_TB.SUBTOTAL%TYPE,
        p_descuento IN ORDEN_TB.DESCUENTO%TYPE,
        p_total IN ORDEN_TB.TOTAL%TYPE
    ) IS
    BEGIN
        -- el total siempre debe cuadrar con subtotal - descuento
        IF p_total <> p_subtotal - p_descuento THEN
            RAISE_APPLICATION_ERROR(-20003, 'El total debe ser igual al subtotal menos el descuento.');
        END IF;
 
        UPDATE ORDEN_TB
           SET ID_PROMOCION = p_id_promocion, ESTADO = p_estado, SUBTOTAL = p_subtotal,
               DESCUENTO = p_descuento, TOTAL = p_total
         WHERE ID_ORDEN = p_id;
 
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'No existe una orden para el ID indicado.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -2291 THEN
                RAISE_APPLICATION_ERROR(-20001, 'No existe la promocion indicada.');
            ELSIF SQLCODE = -2290 THEN
                RAISE_APPLICATION_ERROR(-20003, 'Los montos de la orden no pueden ser negativos.');
            ELSE
                RAISE;
            END IF;
END;
/

CREATE OR REPLACE PROCEDURE SP_ELIMINAR_ORDEN (
        p_id IN ORDEN_TB.ID_ORDEN%TYPE
    ) IS
    BEGIN
        DELETE FROM ORDEN_TB WHERE ID_ORDEN = p_id;
 
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'No existe una orden para el ID indicado.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -2292 THEN
                RAISE_APPLICATION_ERROR(-20005, 'No se puede eliminar la orden porque tiene boletos, pagos o alimentos asociados.');
            ELSE
                RAISE;
            END IF;
END;
/
 
---------------
--Procedimientos almacenados
--Tabla BOLETO_TB
---------------
 
CREATE OR REPLACE PROCEDURE SP_INSERTAR_BOLETO (
        p_id_generado OUT BOLETO_TB.ID_BOLETO%TYPE,
        p_id_orden IN BOLETO_TB.ID_ORDEN%TYPE,
        p_id_funcion IN BOLETO_TB.ID_FUNCION%TYPE,
        p_id_asiento IN BOLETO_TB.ID_ASIENTO%TYPE,
        p_tipoboleto IN BOLETO_TB.TIPOBOLETO%TYPE,
        p_precio IN BOLETO_TB.PRECIO%TYPE
    ) IS
        v_valido NUMBER;
    BEGIN
        -- el asiento debe pertenecer a la misma sala en la que se proyecta la funcion
        SELECT COUNT(*) INTO v_valido
          FROM FUNCION_TB f JOIN ASIENTO_TB a ON a.ID_SALA = f.ID_SALA
         WHERE f.ID_FUNCION = p_id_funcion AND a.ID_ASIENTO = p_id_asiento;
        IF v_valido = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'La funcion o el asiento no existen, o el asiento no pertenece a la sala de la funcion.');
        END IF;
 
        INSERT INTO BOLETO_TB (ID_ORDEN, ID_FUNCION, ID_ASIENTO, TIPOBOLETO, PRECIO)
        VALUES (p_id_orden, p_id_funcion, p_id_asiento, p_tipoboleto, p_precio)
        RETURNING ID_BOLETO INTO p_id_generado;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1 THEN
                RAISE_APPLICATION_ERROR(-20004, 'Ese asiento ya esta vendido para la funcion indicada.');
            ELSIF SQLCODE = -2291 THEN
                RAISE_APPLICATION_ERROR(-20001, 'No existe la orden indicada.');
            ELSIF SQLCODE = -2290 THEN
                RAISE_APPLICATION_ERROR(-20003, 'El precio del boleto no puede ser negativo.');
            ELSE
                RAISE;
            END IF;
END;
/

CREATE OR REPLACE PROCEDURE SP_CONSULTAR_BOLETO (
        p_cursor OUT SYS_REFCURSOR,
        p_id IN BOLETO_TB.ID_BOLETO%TYPE DEFAULT NULL,
        p_id_orden IN BOLETO_TB.ID_ORDEN%TYPE DEFAULT NULL,
        p_id_funcion IN BOLETO_TB.ID_FUNCION%TYPE DEFAULT NULL
    ) IS
    BEGIN
        OPEN p_cursor FOR SELECT * FROM BOLETO_TB
             WHERE (p_id IS NULL OR ID_BOLETO = p_id)
               AND (p_id_orden IS NULL OR ID_ORDEN = p_id_orden)
               AND (p_id_funcion IS NULL OR ID_FUNCION = p_id_funcion)
             ORDER BY ID_BOLETO;
END;
/

CREATE OR REPLACE PROCEDURE SP_ACTUALIZAR_BOLETO (
        p_id IN BOLETO_TB.ID_BOLETO%TYPE,
        p_id_orden IN BOLETO_TB.ID_ORDEN%TYPE,
        p_id_funcion IN BOLETO_TB.ID_FUNCION%TYPE,
        p_id_asiento IN BOLETO_TB.ID_ASIENTO%TYPE,
        p_tipoboleto IN BOLETO_TB.TIPOBOLETO%TYPE,
        p_precio IN BOLETO_TB.PRECIO%TYPE
    ) IS
        v_valido NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_valido
          FROM FUNCION_TB f JOIN ASIENTO_TB a ON a.ID_SALA = f.ID_SALA
         WHERE f.ID_FUNCION = p_id_funcion AND a.ID_ASIENTO = p_id_asiento;
        IF v_valido = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'La funcion o el asiento no existen, o el asiento no pertenece a la sala de la funcion.');
        END IF;
 
        UPDATE BOLETO_TB
           SET ID_ORDEN = p_id_orden, ID_FUNCION = p_id_funcion, ID_ASIENTO = p_id_asiento,
               TIPOBOLETO = p_tipoboleto, PRECIO = p_precio
         WHERE ID_BOLETO = p_id;
 
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'No existe un boleto para el ID indicado.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1 THEN
                RAISE_APPLICATION_ERROR(-20004, 'Ese asiento ya esta vendido para la funcion indicada.');
            ELSIF SQLCODE = -2291 THEN
                RAISE_APPLICATION_ERROR(-20001, 'No existe la orden indicada.');
            ELSIF SQLCODE = -2290 THEN
                RAISE_APPLICATION_ERROR(-20003, 'El precio del boleto no puede ser negativo.');
            ELSE
                RAISE;
            END IF;
END;
/

CREATE OR REPLACE PROCEDURE SP_ELIMINAR_BOLETO (
        p_id IN BOLETO_TB.ID_BOLETO%TYPE
    ) IS
    BEGIN
        DELETE FROM BOLETO_TB WHERE ID_BOLETO = p_id;
 
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'No existe un boleto para el ID indicado.');
        END IF;
END;
/
 
---------------
--Procedimientos almacenados
--Tabla PAGO_TB
---------------
 

CREATE OR REPLACE PROCEDURE SP_INSERTAR_PAGO (
        p_id_generado OUT PAGO_TB.ID_PAGO%TYPE,
        p_id_orden IN PAGO_TB.ID_ORDEN%TYPE,
        p_monto IN PAGO_TB.MONTO%TYPE,
        p_metodopago IN PAGO_TB.METODOPAGO%TYPE DEFAULT NULL,
        p_referenciatransaccion IN PAGO_TB.REFERENCIATRANSACCION%TYPE DEFAULT NULL,
        p_estado IN PAGO_TB.ESTADO%TYPE DEFAULT 1
    ) IS
    BEGIN
        INSERT INTO PAGO_TB (ID_ORDEN, MONTO, METODOPAGO, REFERENCIATRANSACCION, ESTADO)
        VALUES (p_id_orden, p_monto, p_metodopago, p_referenciatransaccion, NVL(p_estado, 1))
        RETURNING ID_PAGO INTO p_id_generado;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1 THEN
                RAISE_APPLICATION_ERROR(-20004, 'Ya existe un pago con esa referencia de transaccion.');
            ELSIF SQLCODE = -2291 THEN
                RAISE_APPLICATION_ERROR(-20001, 'No existe la orden indicada.');
            ELSIF SQLCODE = -2290 THEN
                RAISE_APPLICATION_ERROR(-20003, 'El monto debe ser mayor a 0 y el estado debe ser 0 o 1.');
            ELSE
                RAISE;
            END IF;
END;
/

CREATE OR REPLACE PROCEDURE SP_CONSULTAR_PAGO (
        p_cursor OUT SYS_REFCURSOR,
        p_id IN PAGO_TB.ID_PAGO%TYPE DEFAULT NULL,
        p_id_orden IN PAGO_TB.ID_ORDEN%TYPE DEFAULT NULL
    ) IS
    BEGIN
        OPEN p_cursor FOR SELECT * FROM PAGO_TB
             WHERE (p_id IS NULL OR ID_PAGO = p_id)
               AND (p_id_orden IS NULL OR ID_ORDEN = p_id_orden)
             ORDER BY ID_PAGO;
END;
/

CREATE OR REPLACE PROCEDURE SP_ACTUALIZAR_PAGO (
        p_id IN PAGO_TB.ID_PAGO%TYPE,
        p_id_orden IN PAGO_TB.ID_ORDEN%TYPE,
        p_monto IN PAGO_TB.MONTO%TYPE,
        p_metodopago IN PAGO_TB.METODOPAGO%TYPE,
        p_referenciatransaccion IN PAGO_TB.REFERENCIATRANSACCION%TYPE,
        p_estado IN PAGO_TB.ESTADO%TYPE
    ) IS
    BEGIN
        UPDATE PAGO_TB
           SET ID_ORDEN = p_id_orden, MONTO = p_monto, METODOPAGO = p_metodopago,
               REFERENCIATRANSACCION = p_referenciatransaccion, ESTADO = p_estado
         WHERE ID_PAGO = p_id;
 
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'No existe un pago para el ID indicado.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1 THEN
                RAISE_APPLICATION_ERROR(-20004, 'Ya existe un pago con esa referencia de transaccion.');
            ELSIF SQLCODE = -2291 THEN
                RAISE_APPLICATION_ERROR(-20001, 'No existe la orden indicada.');
            ELSIF SQLCODE = -2290 THEN
                RAISE_APPLICATION_ERROR(-20003, 'El monto debe ser mayor a 0 y el estado debe ser 0 o 1.');
            ELSE
                RAISE;
            END IF;
END;
/

CREATE OR REPLACE PROCEDURE SP_ELIMINAR_PAGO (
        p_id IN PAGO_TB.ID_PAGO%TYPE
    ) IS
    BEGIN
        DELETE FROM PAGO_TB WHERE ID_PAGO = p_id;
 
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'No existe un pago para el ID indicado.');
        END IF;
END;
/
 
---------------
--Procedimientos almacenados
--Tabla CATEGORIAALIMENTO_TB
---------------
 
CREATE OR REPLACE PROCEDURE SP_INSERTAR_CATEGORIAALIMENTO (
        p_id_generado OUT CATEGORIAALIMENTO_TB.ID_CATEGORIA%TYPE,
        p_nombre IN CATEGORIAALIMENTO_TB.NOMBRE%TYPE
    ) IS
    BEGIN
        INSERT INTO CATEGORIAALIMENTO_TB (NOMBRE) VALUES (p_nombre)
        RETURNING ID_CATEGORIA INTO p_id_generado;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1 THEN
                RAISE_APPLICATION_ERROR(-20004, 'Ya existe una categoria con ese nombre.');
            ELSE
                RAISE;
            END IF;
END;
/

CREATE OR REPLACE PROCEDURE SP_CONSULTAR_CATEGORIAALIMENTO (
        p_cursor OUT SYS_REFCURSOR,
        p_id IN CATEGORIAALIMENTO_TB.ID_CATEGORIA%TYPE DEFAULT NULL
    ) IS
    BEGIN
        OPEN p_cursor FOR SELECT * FROM CATEGORIAALIMENTO_TB
             WHERE p_id IS NULL OR ID_CATEGORIA = p_id ORDER BY ID_CATEGORIA;
END;
/
---
CREATE OR REPLACE PROCEDURE SP_ACTUALIZAR_CATEGORIAALIMENTO (
        p_id IN CATEGORIAALIMENTO_TB.ID_CATEGORIA%TYPE,
        p_nombre IN CATEGORIAALIMENTO_TB.NOMBRE%TYPE
    ) IS
    BEGIN
        UPDATE CATEGORIAALIMENTO_TB SET NOMBRE = p_nombre WHERE ID_CATEGORIA = p_id;
 
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'No existe una categoria para el ID indicado.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1 THEN
                RAISE_APPLICATION_ERROR(-20004, 'Ya existe una categoria con ese nombre.');
            ELSE
                RAISE;
            END IF;
END;
/
---
CREATE OR REPLACE PROCEDURE SP_ELIMINAR_CATEGORIAALIMENTO (
        p_id IN CATEGORIAALIMENTO_TB.ID_CATEGORIA%TYPE
    ) IS
    BEGIN
        DELETE FROM CATEGORIAALIMENTO_TB WHERE ID_CATEGORIA = p_id;
 
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'No existe una categoria para el ID indicado.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -2292 THEN
                RAISE_APPLICATION_ERROR(-20005, 'No se puede eliminar la categoria porque tiene alimentos asociados.');
            ELSE
                RAISE;
            END IF;
END;
/
 
---------------
--Procedimientos almacenados
--Tabla ALIMENTO_TB
---------------
 
CREATE OR REPLACE PROCEDURE SP_INSERTAR_ALIMENTO (
        p_id_generado OUT ALIMENTO_TB.ID_ALIMENTO%TYPE,
        p_nombre IN ALIMENTO_TB.NOMBRE%TYPE,
        p_precio IN ALIMENTO_TB.PRECIO%TYPE,
        p_id_categoria IN ALIMENTO_TB.ID_CATEGORIA%TYPE DEFAULT NULL,
        p_descripcion IN ALIMENTO_TB.DESCRIPCION%TYPE DEFAULT NULL,
        p_urlimagen IN ALIMENTO_TB.URLIMAGEN%TYPE DEFAULT NULL,
        p_disponible IN ALIMENTO_TB.DISPONIBLE%TYPE DEFAULT 1
    ) IS
    BEGIN
        INSERT INTO ALIMENTO_TB (ID_CATEGORIA, NOMBRE, DESCRIPCION, PRECIO, URLIMAGEN, DISPONIBLE)
        VALUES (p_id_categoria, p_nombre, p_descripcion, p_precio, p_urlimagen, NVL(p_disponible, 1))
        RETURNING ID_ALIMENTO INTO p_id_generado;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -2291 THEN
                RAISE_APPLICATION_ERROR(-20001, 'No existe la categoria indicada.');
            ELSIF SQLCODE = -2290 THEN
                RAISE_APPLICATION_ERROR(-20003, 'El precio no puede ser negativo y disponible debe ser 0 o 1.');
            ELSE
                RAISE;
            END IF;
END;
/


CREATE OR REPLACE PROCEDURE SP_CONSULTAR_ALIMENTO (
        p_cursor OUT SYS_REFCURSOR,
        p_id IN ALIMENTO_TB.ID_ALIMENTO%TYPE DEFAULT NULL,
        p_id_categoria IN ALIMENTO_TB.ID_CATEGORIA%TYPE DEFAULT NULL
    ) IS
    BEGIN
        OPEN p_cursor FOR SELECT * FROM ALIMENTO_TB
             WHERE (p_id IS NULL OR ID_ALIMENTO = p_id)
               AND (p_id_categoria IS NULL OR ID_CATEGORIA = p_id_categoria)
             ORDER BY ID_ALIMENTO;
END;
/

CREATE OR REPLACE PROCEDURE SP_ACTUALIZAR_ALIMENTO (
        p_id IN ALIMENTO_TB.ID_ALIMENTO%TYPE,
        p_id_categoria IN ALIMENTO_TB.ID_CATEGORIA%TYPE,
        p_nombre IN ALIMENTO_TB.NOMBRE%TYPE,
        p_descripcion IN ALIMENTO_TB.DESCRIPCION%TYPE,
        p_precio IN ALIMENTO_TB.PRECIO%TYPE,
        p_urlimagen IN ALIMENTO_TB.URLIMAGEN%TYPE,
        p_disponible IN ALIMENTO_TB.DISPONIBLE%TYPE
    ) IS
    BEGIN
        UPDATE ALIMENTO_TB
           SET ID_CATEGORIA = p_id_categoria, NOMBRE = p_nombre, DESCRIPCION = p_descripcion,
               PRECIO = p_precio, URLIMAGEN = p_urlimagen, DISPONIBLE = p_disponible
         WHERE ID_ALIMENTO = p_id;
 
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'No existe un alimento para el ID indicado.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -2291 THEN
                RAISE_APPLICATION_ERROR(-20001, 'No existe la categoria indicada.');
            ELSIF SQLCODE = -2290 THEN
                RAISE_APPLICATION_ERROR(-20003, 'El precio no puede ser negativo y disponible debe ser 0 o 1.');
            ELSE
                RAISE;
            END IF;
END;
/


CREATE OR REPLACE PROCEDURE SP_ELIMINAR_ALIMENTO (
        p_id IN ALIMENTO_TB.ID_ALIMENTO%TYPE
    ) IS
    BEGIN
        DELETE FROM ALIMENTO_TB WHERE ID_ALIMENTO = p_id;
 
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'No existe un alimento para el ID indicado.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -2292 THEN
                RAISE_APPLICATION_ERROR(-20005, 'No se puede eliminar el alimento porque ya fue comprado en ordenes. Marquelo como no disponible en su lugar.');
            ELSE
                RAISE;
            END IF;
END;
/
 
---------------
--Procedimientos almacenados
--Tabla COMPRAALIMENTO_TB
---------------
 
CREATE OR REPLACE PROCEDURE SP_INSERTAR_COMPRAALIMENTO (
        p_id_generado OUT COMPRAALIMENTO_TB.ID_COMPRAALIMENTO%TYPE,
        p_id_orden IN COMPRAALIMENTO_TB.ID_ORDEN%TYPE,
        p_id_alimento IN COMPRAALIMENTO_TB.ID_ALIMENTO%TYPE,
        p_cantidad IN COMPRAALIMENTO_TB.CANTIDAD%TYPE,
        p_preciounitario IN COMPRAALIMENTO_TB.PRECIOUNITARIO%TYPE DEFAULT NULL
    ) IS
        v_precio ALIMENTO_TB.PRECIO%TYPE;
        v_disponible ALIMENTO_TB.DISPONIBLE%TYPE;
    BEGIN
        SELECT PRECIO, DISPONIBLE INTO v_precio, v_disponible
          FROM ALIMENTO_TB WHERE ID_ALIMENTO = p_id_alimento;
 
        IF v_disponible = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'El alimento indicado no esta disponible.');
        END IF;
 
        INSERT INTO COMPRAALIMENTO_TB (ID_ORDEN, ID_ALIMENTO, CANTIDAD, PRECIOUNITARIO)
        VALUES (p_id_orden, p_id_alimento, p_cantidad, NVL(p_preciounitario, v_precio))
        RETURNING ID_COMPRAALIMENTO INTO p_id_generado;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'No existe el alimento indicado.');
        WHEN OTHERS THEN
            IF SQLCODE = -1 THEN
                RAISE_APPLICATION_ERROR(-20004, 'Ese alimento ya esta en la orden; actualice la cantidad en lugar de agregarlo otra vez.');
            ELSIF SQLCODE = -2291 THEN
                RAISE_APPLICATION_ERROR(-20001, 'No existe la orden indicada.');
            ELSIF SQLCODE = -2290 THEN
                RAISE_APPLICATION_ERROR(-20003, 'La cantidad debe ser mayor a 0 y el precio no puede ser negativo.');
            ELSE
                RAISE;
            END IF;
END;
/

CREATE OR REPLACE PROCEDURE SP_CONSULTAR_COMPRAALIMENTO (
        p_cursor OUT SYS_REFCURSOR,
        p_id IN COMPRAALIMENTO_TB.ID_COMPRAALIMENTO%TYPE DEFAULT NULL,
        p_id_orden IN COMPRAALIMENTO_TB.ID_ORDEN%TYPE DEFAULT NULL
    ) IS
    BEGIN
        OPEN p_cursor FOR SELECT * FROM COMPRAALIMENTO_TB
             WHERE (p_id IS NULL OR ID_COMPRAALIMENTO = p_id)
               AND (p_id_orden IS NULL OR ID_ORDEN = p_id_orden)
             ORDER BY ID_COMPRAALIMENTO;
END;
/
---
CREATE OR REPLACE PROCEDURE SP_ACTUALIZAR_COMPRAALIMENTO (
        p_id IN COMPRAALIMENTO_TB.ID_COMPRAALIMENTO%TYPE,
        p_id_orden IN COMPRAALIMENTO_TB.ID_ORDEN%TYPE,
        p_id_alimento IN COMPRAALIMENTO_TB.ID_ALIMENTO%TYPE,
        p_cantidad IN COMPRAALIMENTO_TB.CANTIDAD%TYPE,
        p_preciounitario IN COMPRAALIMENTO_TB.PRECIOUNITARIO%TYPE
    ) IS
    BEGIN
        UPDATE COMPRAALIMENTO_TB
           SET ID_ORDEN = p_id_orden, ID_ALIMENTO = p_id_alimento, CANTIDAD = p_cantidad,
               PRECIOUNITARIO = p_preciounitario
         WHERE ID_COMPRAALIMENTO = p_id;
 
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'No existe una compra de alimento para el ID indicado.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1 THEN
                RAISE_APPLICATION_ERROR(-20004, 'Ese alimento ya esta en la orden.');
            ELSIF SQLCODE = -2291 THEN
                RAISE_APPLICATION_ERROR(-20001, 'No existe la orden o el alimento indicado.');
            ELSIF SQLCODE = -2290 THEN
                RAISE_APPLICATION_ERROR(-20003, 'La cantidad debe ser mayor a 0 y el precio no puede ser negativo.');
            ELSE
                RAISE;
            END IF;
END;
/
---
CREATE OR REPLACE PROCEDURE SP_ELIMINAR_COMPRAALIMENTO (
        p_id IN COMPRAALIMENTO_TB.ID_COMPRAALIMENTO%TYPE
    ) IS
    BEGIN
        DELETE FROM COMPRAALIMENTO_TB WHERE ID_COMPRAALIMENTO = p_id;
 
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'No existe una compra de alimento para el ID indicado.');
        END IF;
END;
/

