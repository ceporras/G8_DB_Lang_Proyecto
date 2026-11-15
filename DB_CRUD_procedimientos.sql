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
---
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
---
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
---
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









---------------
--Procedimientos almacenados
--Tabla PROMOCION_TB
---------------










---------------
--Procedimientos almacenados
--Tabla CLIENTE_TB
---------------










---------------
--Procedimientos almacenados
--Tabla ORDEN_TB
---------------





---------------
--Procedimientos almacenados
--Tabla BOLETO_TB
---------------






---------------
--Procedimientos almacenados
--Tabla PAGO_TB
---------------




















---------------
--Procedimientos almacenados
--Tabla CATEGORIAALIMENTO_TB
---------------














---------------
--Procedimientos almacenados
--Tabla ALIMENTO_TB
---------------











---------------
--Procedimientos almacenados
--Tabla COMPRAALIMENTO_TB
---------------