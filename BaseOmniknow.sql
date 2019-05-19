DROP DATABASE IF EXISTS omniknow;
CREATE DATABASE OMNIKNOW DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
USE OMNIKNOW;

/*====================================TABLAS====================================*/

/*Catálogo*/
CREATE TABLE ACCESOS(
ID_ACCESO INT(10) NOT NULL,
USUARIO VARCHAR(100),
CONTRASEÑA VARCHAR(100),
PRIMARY KEY (ID_ACCESO)
);
CREATE TABLE ENTRENADORES(
ID_ENTRENADOR INT(10) NOT NULL,
ID_ACCESO INT(10),
CLAVE_MAESTRA VARCHAR(30),
PRIMARY KEY (ID_ENTRENADOR),
FOREIGN KEY (ID_ACCESO) REFERENCES ACCESOS(ID_ACCESO)
);

INSERT INTO ACCESOS VALUE (1,'entrenador','1234');
INSERT INTO ENTRENADORES VALUE(1,1,'m');
/*Catálogo*/
CREATE TABLE ESCUELAS(
ID_ESCUELA INT(10) NOT NULL,
NOMBRE_ESCUELA VARCHAR(200),
PRIMARY KEY (ID_ESCUELA)
);
/*Catálogo*/
CREATE TABLE DATOS_PERSONALES(
ID_DATO_PERSONAL INT(10) NOT NULL,
NOMBRE VARCHAR(100),
APELLIDO_PATERNO VARCHAR(100),
APELLIDO_MATERNO VARCHAR(100),
CORREO VARCHAR(100),
GRADO INT(1),
PRIMARY KEY (ID_DATO_PERSONAL)
);

CREATE TABLE PARTICIPANTES(
ID_PARTICIPANTE INT(10) NOT NULL,
ID_DATO_PERSONAL INT(10),
ID_ACCESO INT(10),
ID_ESCUELA INT(10),
PRIMARY KEY (ID_PARTICIPANTE),
FOREIGN KEY (ID_DATO_PERSONAL) REFERENCES DATOS_PERSONALES(ID_DATO_PERSONAL),
FOREIGN KEY (ID_ACCESO) REFERENCES ACCESOS(ID_ACCESO),
FOREIGN KEY (ID_ESCUELA) REFERENCES ESCUELAS(ID_ESCUELA)
);
/*Catálogo*/
CREATE TABLE CATALOGOS_RESPUESTAS(
ID_CATALOGO_RESPUESTA INT(10) NOT NULL,
RESPUESTA1 VARCHAR(255),
RESPUESTA2 VARCHAR(255),
RESPUESTA3 VARCHAR(255),
RESPUESTA4 VARCHAR(255),
RESPUESTA5 VARCHAR(255),
PRIMARY KEY (ID_CATALOGO_RESPUESTA)
);
/*Catálogo*/
CREATE TABLE PROBLEMAS(
ID_PROBLEMA INT(10) NOT NULL,
NOMBRE_PROBLEMA VARCHAR(255),
ARCHIVO_PROBLEMA VARCHAR(255),
PRIMARY KEY (ID_PROBLEMA)
);
/*Catálogo*/
CREATE TABLE SOLUCIONES(
ID_SOLUCION INT(10) NOT NULL,
NOMBRE_SOLUCION VARCHAR(255),
ARCHIVO_SOLUCION VARCHAR(255),
PRIMARY KEY (ID_SOLUCION)
);

CREATE TABLE TAREAS(
ID_TAREA INT(10) NOT NULL,
GRADO_TAREA INT(1),
ID_PROBLEMA INT(10),
ID_SOLUCION INT(10),
ID_CATALOGO_RESPUESTA INT(10),
-- FECHA_INICIO DATE,
FECHA_FINAL DATE,
DISPONIBLE TINYINT(1),
PRIMARY KEY (ID_TAREA),
FOREIGN KEY (ID_PROBLEMA) REFERENCES PROBLEMAS(ID_PROBLEMA),
FOREIGN KEY (ID_SOLUCION) REFERENCES SOLUCIONES(ID_SOLUCION),
FOREIGN KEY (ID_CATALOGO_RESPUESTA) REFERENCES CATALOGOS_RESPUESTAS(ID_CATALOGO_RESPUESTA)
);

CREATE TABLE RESPUESTAS(
ID_RESPUESTA INT(10) NOT NULL,
ID_PARTICIPANTE INT(10),
ID_TAREA INT(10),
ID_CATALOGO_RESPUESTA INT(10),
PRIMARY KEY (ID_RESPUESTA),
FOREIGN KEY (ID_PARTICIPANTE) REFERENCES PARTICIPANTES(ID_PARTICIPANTE),
FOREIGN KEY (ID_TAREA) REFERENCES TAREAS(ID_TAREA),
FOREIGN KEY (ID_CATALOGO_RESPUESTA) REFERENCES CATALOGOS_RESPUESTAS(ID_CATALOGO_RESPUESTA)
);
/*Catálogo*/
CREATE TABLE CATALOGOS_REVISADAS(
ID_CATALOGO_REVISADA INT(10) NOT NULL,
REVISADA1 TINYINT(1),
REVISADA2 TINYINT(1),
REVISADA3 TINYINT(1),
REVISADA4 TINYINT(1),
REVISADA5 TINYINT(1),
TOTAL INT(1),
PRIMARY KEY (ID_CATALOGO_REVISADA)
);

CREATE TABLE PUNTAJES(
ID_PUNTAJE INT(10) NOT NULL,
ID_RESPUESTA INT(10),
ID_CATALOGO_REVISADA INT(10),
PRIMARY KEY (ID_PUNTAJE),
FOREIGN KEY (ID_RESPUESTA) REFERENCES RESPUESTAS(ID_RESPUESTA),
FOREIGN KEY (ID_CATALOGO_REVISADA) REFERENCES CATALOGOS_REVISADAS(ID_CATALOGO_REVISADA)
);

CREATE TABLE PENDIENTES(
	ID_PENDIENTE INT(10),
    ID_DATO_PERSONAL INT(10),
    PRIMARY KEY (ID_PENDIENTE),
    FOREIGN KEY (ID_DATO_PERSONAL) REFERENCES DATOS_PERSONALES(ID_DATO_PERSONAL)
);

/*====================================PROCEDIMIENTOS====================================*/
DELIMITER $$
CREATE PROCEDURE REGISTRAR(IN NOMBRE_PART VARCHAR(100), IN PATER_PART VARCHAR(100), IN MATER_PART VARCHAR(100), IN GRADO_PART INT(1), IN ESCUELA_PART VARCHAR(200), IN CORREO_PART VARCHAR(100), IN USUA_PART VARCHAR(100), IN CON_PART VARCHAR(100))
BEGIN
/*Estos van a ser los id's porque no podemos usar auto_increment :(*/
DECLARE _DATO_PERSONAL INT(10);
DECLARE _PARTICIPANTE INT(10);
DECLARE _ACCESO INT(10);
DECLARE _ESCUELA INT(10);
DECLARE EXISTE_ESCUELA TINYINT(1); /*Este no es id*/
/*Ver si  hay alguien en la misma escuela y grado para usar el mismo id*/
SET EXISTE_ESCUELA = (SELECT COUNT(*) FROM ESCUELAS WHERE NOMBRE_ESCUELA = ESCUELA_PART);
/*Ahora asignamos los valores a los id's*/
SET _DATO_PERSONAL = (SELECT IFNULL(MAX(ID_DATO_PERSONAL),0)+1 FROM DATOS_PERSONALES);
SET _PARTICIPANTE = (SELECT IFNULL(MAX(ID_PARTICIPANTE),0)+1 FROM PARTICIPANTES);
SET _ACCESO = (SELECT IFNULL(MAX(ID_ACCESO),0)+1 FROM ACCESOS);
/*Y empezamos el procedimiento*/
IF (EXISTE_ESCUELA = 0) THEN
	SET _ESCUELA = (SELECT IFNULL(MAX(ID_ESCUELA),0)+1 FROM ESCUELAS);
	INSERT INTO ESCUELAS VALUE(_ESCUELA, ESCUELA_PART);
ELSE
	SET _ESCUELA = (SELECT ID_ESCUELA FROM ESCUELAS WHERE NOMBRE_ESCUELA = ESCUELA_PART);
END IF;
INSERT INTO DATOS_PERSONALES VALUE(_DATO_PERSONAL, NOMBRE_PART, PATER_PART, MATER_PART, CORREO_PART, GRADO_PART);
INSERT INTO ACCESOS VALUE(_ACCESO, USUA_PART, CON_PART);
INSERT INTO PARTICIPANTES VALUE(_PARTICIPANTE, _DATO_PERSONAL, _ACCESO, _ESCUELA);
END;
$$

CREATE PROCEDURE CAMBIAR_ENTRENADOR(IN USU_ENTR VARCHAR(100), IN CON_ENTR VARCHAR(100), IN CLAVE VARCHAR(30))
BEGIN
UPDATE ACCESOS SET USUARIO = USU_ENTR, CONTRASEÑA = CON_ENTR WHERE ID_ACCESO = 1;
UPDATE ENTRENADORES SET CLAVE_MAESTRA = CLAVE WHERE ID_ENTRENADOR = 1;
END;
$$

CREATE PROCEDURE CAMBIAR_TAREA(IN NOM_PROB VARCHAR(255), IN NOM_SOLU VARCHAR(255), IN GRAD_TARE INT(1), IN ARCH_PROB VARCHAR(255), IN ARCH_SOLU VARCHAR(255), IN CORR1 VARCHAR(255), IN CORR2 VARCHAR(255), IN CORR3 VARCHAR(255), IN CORR4 VARCHAR(255), IN CORR5 VARCHAR(255), IN FEC_FINA DATE,IN _TAREA INT(10))
BEGIN
-- Conseguir los id´s de PROBLEMAS, SOLUCIONES y CATALOGOS_RESPUESTAS --
DECLARE _SOLUCION INT(10);
DECLARE _PROBLEMA INT(10);
DECLARE _CATALOGO_RESPUESTA INT(10);
SET _SOLUCION = (SELECT ID_SOLUCION FROM INFOS_TAREAS WHERE INFOS_TAREAS.ID_TAREA = _TAREA);
SET _PROBLEMA = (SELECT ID_PROBLEMA FROM INFOS_TAREAS WHERE INFOS_TAREAS.ID_TAREA = _TAREA);
SET _CATALOGO_RESPUESTA = (SELECT ID_CATALOGO_RESPUESTA FROM INFOS_TAREAS WHERE INFOS_TAREAS.ID_TAREA = _TAREA);
-- Y empezamos el procedimiento --
UPDATE PROBLEMAS SET NOMBRE_PROBLEMA = NOM_PROB, ARCHIVO_PROBLEMA = ARCH_PROB WHERE ID_PROBLEMA = _PROBLEMA;
UPDATE SOLUCIONES SET NOMBRE_SOLUCION = NOM_SOLU, ARCHIVO_SOLUCION = ARCH_SOLU WHERE ID_SOLUCION = _SOLUCION;
UPDATE CATALOGOS_RESPUESTAS SET RESPUESTA1 = CORR1, RESPUESTA2 = CORR2, RESPUESTA3 = CORR3, RESPUESTA4 = CORR4, RESPUESTA5 = CORR5 WHERE ID_CATALOGO_RESPUESTA = _CATALOGO_RESPUESTA;
UPDATE TAREAS SET GRADO_TAREA = GRAD_TARE, FECHA_FINAL = FEC_FINA WHERE ID_TAREA = _TAREA;
END;
$$

CREATE PROCEDURE CAMBIAR_PARTICIPANTE(IN NOMBRE_PART VARCHAR(100), IN PATER_PART VARCHAR(100), IN MATER_PART VARCHAR(100), IN GRADO_PART INT(1), IN ESCUELA_PART VARCHAR(200), IN CORREO_PART VARCHAR(100), IN USUA_PART VARCHAR(100), IN CON_PART VARCHAR(100), IN _PARTICIPANTE INT(10))
BEGIN
-- Los id's de DATOS_PERSONALES, ACCESOS y ESCUELAS correspondientes al participante --
DECLARE _DATO_PERSONAL INT(10);
DECLARE _ACCESO INT(10);
DECLARE _ESCUELA INT(10);
DECLARE EXISTE_ESCUELA TINYINT(1); /*Este no es id*/
/*Ver si  hay alguien en la misma escuela y grado para usar el mismo id*/
SET EXISTE_ESCUELA = (SELECT COUNT(*) FROM ESCUELAS WHERE NOMBRE_ESCUELA = ESCUELA_PART);
IF (EXISTE_ESCUELA = 0) THEN
	SET _ESCUELA = (SELECT IFNULL(MAX(ID_ESCUELA),0)+1 FROM ESCUELAS);
	INSERT INTO ESCUELAS VALUE(_ESCUELA, ESCUELA_PART);
ELSE
	SET _ESCUELA = (SELECT ID_ESCUELA FROM ESCUELAS WHERE NOMBRE_ESCUELA = ESCUELA_PART);
    UPDATE PARTICIPANTES SET ID_ESCUELA = _ESCUELA WHERE ID_PARTICIPANTE = _PARTICIPANTE;
END IF;
SET _DATO_PERSONAL = (SELECT ID_DATO_PERSONAL FROM INFOS_PARTICIPANTES WHERE INFOS_PARTICIPANTES.ID_PARTICIPANTE = _PARTICIPANTE);
SET _ACCESO = (SELECT ID_ACCESO FROM INFOS_PARTICIPANTES WHERE INFOS_PARTICIPANTES.ID_PARTICIPANTE = _PARTICIPANTE);
-- Ahora empezamos el procedimiento, es decir, actualizar los datos --
UPDATE DATOS_PERSONALES SET NOMBRE = NOMBRE_PART, APELLIDO_PATERNO = PATER_PART, APELLIDO_MATERNO = MATER_PART, CORREO = CORREO_PART, GRADO = GRADO_PART WHERE ID_DATO_PERSONAL = _DATO_PERSONAL;
UPDATE ACCESOS SET USUARIO = USUA_PART, CONTRASEÑA = CON_PART WHERE ID_ACCESO = _ACCESO;
END;
$$

CREATE PROCEDURE REVISION(IN _RESPUESTA INT(10), IN REV1 TINYINT(1), IN REV2 TINYINT(1), IN REV3 TINYINT(1), IN REV4 TINYINT(1), IN REV5 TINYINT(1), IN TOTAL INT(1))
BEGIN
-- Los id --
DECLARE _PUNTAJE INT(10);
DECLARE _CATALOGO_REVISADA INT(10);
SET _PUNTAJE = (SELECT IFNULL(MAX(ID_PUNTAJE),0)+1 FROM PUNTAJES);
SET _CATALOGO_REVISADA = (SELECT IFNULL(MAX(ID_CATALOGO_REVISADA),0)+1 FROM CATALOGOS_REVISADAS);
-- Empezamos el procedimiento --
INSERT INTO CATALOGOS_REVISADAS VALUE(_CATALOGO_REVISADA, REV1, REV2, REV3, REV4, REV5, TOTAL);
INSERT INTO PUNTAJES VALUE(_PUNTAJE, _RESPUESTA, _CATALOGO_REVISADA);
END;
$$

CREATE PROCEDURE ENVIAR_RESPUESTAS(IN _PARTICIPANTE INT(10), IN _TAREA INT(10), IN RESP1 VARCHAR(255), IN RESP2 VARCHAR(255), IN RESP3 VARCHAR(255), IN RESP4 VARCHAR(255), IN RESP5 VARCHAR(255))
BEGIN
-- Obtener id's actuales de RESPUESTAS y CATALOGOS_RESPUESTAS --
DECLARE _RESPUESTA INT(10);
DECLARE _CATALOGO_RESPUESTA INT(10);
SET _RESPUESTA = (SELECT IFNULL(MAX(ID_RESPUESTA),0)+1 FROM RESPUESTAS);
SET _CATALOGO_RESPUESTA = (SELECT IFNULL(MAX(ID_CATALOGO_RESPUESTA),0)+1 FROM CATALOGOS_RESPUESTAS);
INSERT INTO CATALOGOS_RESPUESTAS VALUE(_CATALOGO_RESPUESTA, RESP1, RESP2, RESP3, RESP4, RESP5);
INSERT INTO RESPUESTAS VALUE(_RESPUESTA, _PARTICIPANTE, _TAREA, _CATALOGO_RESPUESTA);
END;
$$

CREATE PROCEDURE CREAR_TAREA(IN GRA_TARE INT(1), IN NOM_PROB VARCHAR(255), IN NOM_SOLU VARCHAR(255), IN PDF_PROB VARCHAR(255), IN PDF_SOLU VARCHAR(255), IN COR1 VARCHAR(255), IN COR2 VARCHAR(255), IN COR3 VARCHAR(255), IN COR4 VARCHAR(255), IN COR5 VARCHAR(255), IN FEC_FINA DATE)
BEGIN
-- id de las cosas nuevas --	
DECLARE _TAREA INT(10);
DECLARE _PROBLEMA INT(10);
DECLARE _SOLUCION INT(10);
DECLARE _CATALOGO_RESPUESTA INT(10);
SET _TAREA = (SELECT IFNULL(MAX(ID_TAREA),0)+1 FROM TAREAS);
SET _PROBLEMA = (SELECT IFNULL(MAX(ID_PROBLEMA),0)+1 FROM PROBLEMAS);
SET _SOLUCION = (SELECT IFNULL(MAX(ID_SOLUCION),0)+1 FROM SOLUCIONES);
SET _CATALOGO_RESPUESTA = (SELECT IFNULL(MAX(ID_CATALOGO_RESPUESTA),0)+1 FROM CATALOGOS_RESPUESTAS);
INSERT INTO CATALOGOS_RESPUESTAS VALUE(_CATALOGO_RESPUESTA, COR1, COR2, COR3, COR4, COR5);
INSERT INTO PROBLEMAS VALUE(_PROBLEMA, NOM_PROB, PDF_PROB);
INSERT INTO SOLUCIONES VALUE(_SOLUCION, NOM_SOLU, PDF_SOLU);
INSERT INTO TAREAS VALUE(_TAREA, GRA_TARE, _PROBLEMA, _SOLUCION, _CATALOGO_RESPUESTA, FEC_FINA, 1);
END;
$$

CREATE PROCEDURE CREAR_PENDIENTE(IN NOM VARCHAR(100), IN APE_P VARCHAR(100), IN APE_M VARCHAR(100), IN CORR VARCHAR(100))
BEGIN
	DECLARE _PENDIENTE INT(10);
    DECLARE _DATO_PERSONAL INT(10);
	SET _PENDIENTE = (SELECT IFNULL(MAX(ID_PENDIENTE),0) + 1 FROM PENDIENTES);
	SET _DATO_PERSONAL = (SELECT IFNULL(MAX(ID_DATO_PERSONAL),0) + 1 FROM DATOS_PERSONALES);
    INSERT INTO DATOS_PERSONALES VALUE(_DATO_PERSONAL, NOM, APE_P, APE_M, CORR, NULL);
    INSERT INTO PENDIENTES VALUE(_PENDIENTE, _DATO_PERSONAL);
END;
$$

CREATE PROCEDURE BORRAR_PENDIENTE(IN _PENDIENTE INT(10))
BEGIN
DECLARE _DATO_PERSONAL INT(10);
SET _DATO_PERSONAL = (SELECT ID_DATO_PERSONAL FROM PENDIENTES WHERE ID_PENDIENTE = _PENDIENTE);
DELETE FROM PENDIENTES WHERE ID_PENDIENTE = _PENDIENTE;
DELETE FROM DATOS_PERSONALES WHERE ID_DATO_PERSONAL = _DATO_PERSONAL;
END;
$$

/*====================================VISTAS====================================*/
DELIMITER ;
CREATE VIEW INFOS_PARTICIPANTES AS
SELECT
PARTICIPANTES.ID_PARTICIPANTE,
ACCESOS.ID_ACCESO, ACCESOS.USUARIO, ACCESOS.CONTRASEÑA,
ESCUELAS.ID_ESCUELA, ESCUELAS.NOMBRE_ESCUELA,
DATOS_PERSONALES.ID_DATO_PERSONAL, DATOS_PERSONALES.NOMBRE, DATOS_PERSONALES.APELLIDO_PATERNO, DATOS_PERSONALES.APELLIDO_MATERNO, DATOS_PERSONALES.CORREO, DATOS_PERSONALES.GRADO
FROM ACCESOS
INNER JOIN PARTICIPANTES ON ACCESOS.ID_ACCESO = PARTICIPANTES.ID_ACCESO
INNER JOIN ESCUELAS ON ESCUELAS.ID_ESCUELA = PARTICIPANTES.ID_ESCUELA
INNER JOIN DATOS_PERSONALES ON DATOS_PERSONALES.ID_DATO_PERSONAL = PARTICIPANTES.ID_DATO_PERSONAL;

CREATE VIEW INFOS_TAREAS AS
SELECT
TAREAS.ID_TAREA, TAREAS.GRADO_TAREA, TAREAS.FECHA_FINAL, TAREAS.DISPONIBLE,
PROBLEMAS.ID_PROBLEMA, PROBLEMAS.NOMBRE_PROBLEMA, PROBLEMAS.ARCHIVO_PROBLEMA,
SOLUCIONES.ID_SOLUCION, SOLUCIONES.NOMBRE_SOLUCION, SOLUCIONES.ARCHIVO_SOLUCION,
CATALOGOS_RESPUESTAS.ID_CATALOGO_RESPUESTA, CATALOGOS_RESPUESTAS.RESPUESTA1, CATALOGOS_RESPUESTAS.RESPUESTA2, CATALOGOS_RESPUESTAS.RESPUESTA3, CATALOGOS_RESPUESTAS.RESPUESTA4, CATALOGOS_RESPUESTAS.RESPUESTA5
FROM TAREAS
INNER JOIN PROBLEMAS ON PROBLEMAS.ID_PROBLEMA = TAREAS.ID_PROBLEMA
INNER JOIN SOLUCIONES ON SOLUCIONES.ID_SOLUCION = TAREAS.ID_SOLUCION
INNER JOIN CATALOGOS_RESPUESTAS ON CATALOGOS_RESPUESTAS.ID_CATALOGO_RESPUESTA = TAREAS.ID_CATALOGO_RESPUESTA;

CREATE VIEW INFOS_ENTRENADORES AS
SELECT
ACCESOS.ID_ACCESO, ACCESOS.USUARIO, ACCESOS.CONTRASEÑA,
ENTRENADORES.ID_ENTRENADOR, ENTRENADORES.CLAVE_MAESTRA
FROM ENTRENADORES
INNER JOIN ACCESOS ON ENTRENADORES.ID_ACCESO = ACCESOS.ID_ACCESO;

CREATE VIEW INFOS_PENDIENTES AS
SELECT
PENDIENTES.ID_PENDIENTE,
DATOS_PERSONALES.ID_DATO_PERSONAL, DATOS_PERSONALES.NOMBRE, DATOS_PERSONALES.APELLIDO_PATERNO, DATOS_PERSONALES.APELLIDO_MATERNO, DATOS_PERSONALES.CORREO, DATOS_PERSONALES.GRADO
FROM PENDIENTES
INNER JOIN DATOS_PERSONALES ON DATOS_PERSONALES.ID_DATO_PERSONAL = PENDIENTES.ID_DATO_PERSONAL;

CREATE VIEW RESPUESTAS_PARTICIPANTES AS
SELECT
RESPUESTAS.ID_RESPUESTA, RESPUESTAS.ID_PARTICIPANTE, RESPUESTAS.ID_TAREA,
CATALOGOS_RESPUESTAS.ID_CATALOGO_RESPUESTA, CATALOGOS_RESPUESTAS.RESPUESTA1, CATALOGOS_RESPUESTAS.RESPUESTA2, CATALOGOS_RESPUESTAS.RESPUESTA3, CATALOGOS_RESPUESTAS.RESPUESTA4, CATALOGOS_RESPUESTAS.RESPUESTA5
FROM RESPUESTAS
INNER JOIN CATALOGOS_RESPUESTAS ON RESPUESTAS.ID_CATALOGO_RESPUESTA = CATALOGOS_RESPUESTAS.ID_CATALOGO_RESPUESTA;

CREATE VIEW RESPUESTAS_CORRECTAS AS
SELECT
TAREAS.ID_TAREA,
CATALOGOS_RESPUESTAS.ID_CATALOGO_RESPUESTA, CATALOGOS_RESPUESTAS.RESPUESTA1, CATALOGOS_RESPUESTAS.RESPUESTA2, CATALOGOS_RESPUESTAS.RESPUESTA3, CATALOGOS_RESPUESTAS.RESPUESTA4, CATALOGOS_RESPUESTAS.RESPUESTA5
FROM TAREAS
INNER JOIN CATALOGOS_RESPUESTAS ON CATALOGOS_RESPUESTAS.ID_CATALOGO_RESPUESTA = TAREAS.ID_CATALOGO_RESPUESTA;

CREATE VIEW RESPUESTAS_REVISADAS AS
SELECT 
RESPUESTAS.ID_PARTICIPANTE, RESPUESTAS.ID_TAREA,
CATALOGOS_REVISADAS.REVISADA1, CATALOGOS_REVISADAS.REVISADA2, CATALOGOS_REVISADAS.REVISADA3, CATALOGOS_REVISADAS.REVISADA4, CATALOGOS_REVISADAS.REVISADA5, CATALOGOS_REVISADAS.TOTAL
FROM PUNTAJES
INNER JOIN CATALOGOS_REVISADAS ON PUNTAJES.ID_CATALOGO_REVISADA = CATALOGOS_REVISADAS.ID_CATALOGO_REVISADA
INNER JOIN RESPUESTAS ON PUNTAJES.ID_RESPUESTA = RESPUESTAS.ID_RESPUESTA;

CREATE VIEW INFOS_GRAFICAS AS
SELECT
DATOS_PERSONALES.NOMBRE, DATOS_PERSONALES.APELLIDO_PATERNO, DATOS_PERSONALES.APELLIDO_MATERNO,
TAREAS.GRADO_TAREA, TAREAS.ID_TAREA,
PROBLEMAS.NOMBRE_PROBLEMA,
CATALOGOS_REVISADAS.TOTAL,
PARTICIPANTES.ID_PARTICIPANTE
FROM RESPUESTAS
INNER JOIN PARTICIPANTES ON PARTICIPANTES.ID_PARTICIPANTE = RESPUESTAS.ID_PARTICIPANTE
INNER JOIN DATOS_PERSONALES ON DATOS_PERSONALES.ID_DATO_PERSONAL = PARTICIPANTES.ID_DATO_PERSONAL
INNER JOIN TAREAS ON TAREAS.ID_TAREA = RESPUESTAS.ID_TAREA
INNER JOIN PROBLEMAS ON PROBLEMAS.ID_PROBLEMA = TAREAS.ID_PROBLEMA
INNER JOIN PUNTAJES ON PUNTAJES.ID_RESPUESTA = RESPUESTAS.ID_RESPUESTA
INNER JOIN CATALOGOS_REVISADAS ON CATALOGOS_REVISADAS.ID_CATALOGO_REVISADA = PUNTAJES.ID_CATALOGO_REVISADA;

/*====================================TRIGGERS====================================*/
DELIMITER **
CREATE TRIGGER REVISAR AFTER INSERT ON RESPUESTAS FOR EACH ROW
BEGIN
-- Variables que vamos a usar --
	DECLARE C1 VARCHAR(255); -- "CORRECTAS"
	DECLARE C2 VARCHAR(255);
	DECLARE C3 VARCHAR(255);
	DECLARE C4 VARCHAR(255);
	DECLARE C5 VARCHAR(255);
    
    DECLARE I1 VARCHAR(255); -- "INTENTOS"
	DECLARE I2 VARCHAR(255);
	DECLARE I3 VARCHAR(255);
	DECLARE I4 VARCHAR(255);
	DECLARE I5 VARCHAR(255);
    
	DECLARE R1 TINYINT(1); -- "REVISADAS"
    DECLARE R2 TINYINT(1);
    DECLARE R3 TINYINT(1);
    DECLARE R4 TINYINT(1);
    DECLARE R5 TINYINT(1);
    
    DECLARE _CATALOGO_RESPUESTA_CORRECTA INT(10);
    DECLARE _CATALOGO_RESPUESTA_INTENTO INT(10);
    DECLARE _RESPUESTA INT(10);
    DECLARE TOTAL INT(1);
    
-- Asginar los valores que necesitamos --
	SET _RESPUESTA = NEW.ID_RESPUESTA;
    
    SET _CATALOGO_RESPUESTA_CORRECTA = (SELECT ID_CATALOGO_RESPUESTA FROM RESPUESTAS_CORRECTAS WHERE ID_TAREA = NEW.ID_TAREA);
    SET C1 = (SELECT RESPUESTA1 FROM RESPUESTAS_CORRECTAS WHERE ID_TAREA = NEW.ID_TAREA);
    SET C2 = (SELECT RESPUESTA2 FROM RESPUESTAS_CORRECTAS WHERE ID_TAREA = NEW.ID_TAREA);
    SET C3 = (SELECT RESPUESTA3 FROM RESPUESTAS_CORRECTAS WHERE ID_TAREA = NEW.ID_TAREA);
    SET C4 = (SELECT RESPUESTA4 FROM RESPUESTAS_CORRECTAS WHERE ID_TAREA = NEW.ID_TAREA);
    SET C5 = (SELECT RESPUESTA5 FROM RESPUESTAS_CORRECTAS WHERE ID_TAREA = NEW.ID_TAREA);
    
    SET _CATALOGO_RESPUESTA_INTENTO = NEW.ID_CATALOGO_RESPUESTA;
    SET I1 = (SELECT RESPUESTA1 FROM CATALOGOS_RESPUESTAS WHERE ID_CATALOGO_RESPUESTA = NEW.ID_CATALOGO_RESPUESTA);
    SET I2 = (SELECT RESPUESTA2 FROM CATALOGOS_RESPUESTAS WHERE ID_CATALOGO_RESPUESTA = NEW.ID_CATALOGO_RESPUESTA);
    SET I3 = (SELECT RESPUESTA3 FROM CATALOGOS_RESPUESTAS WHERE ID_CATALOGO_RESPUESTA = NEW.ID_CATALOGO_RESPUESTA);
    SET I4 = (SELECT RESPUESTA4 FROM CATALOGOS_RESPUESTAS WHERE ID_CATALOGO_RESPUESTA = NEW.ID_CATALOGO_RESPUESTA);
    SET I5 = (SELECT RESPUESTA5 FROM CATALOGOS_RESPUESTAS WHERE ID_CATALOGO_RESPUESTA = NEW.ID_CATALOGO_RESPUESTA);
    
    IF C1 = I1 THEN
		SET R1 = 1;
	ELSE
		SET R1 = 0;
	END IF;
	IF C2 = I2 THEN
		SET R2 = 1;
	ELSE
		SET R2 = 0;
	END IF;
	IF C3 = I3 THEN
		SET R3 = 1;
	ELSE
		SET R3 = 0;
	END IF;
	IF C4 = I4 THEN
		SET R4 = 1;
	ELSE
		SET R4 = 0;
	END IF;
        IF C5 = I5 THEN
		SET R5 = 1;
	ELSE
		SET R5 = 0;
	END IF;
    
    SET TOTAL = R1 + R2 + R3 + R4 + R5;    
-- Comparar las enviadas con las correctas y obtener el total --
    
    
-- Terminar --
	CALL REVISION(_RESPUESTA,R1,R2,R3,R4,R5,TOTAL);
END;
**
-- Cosas locas de las FAQS --
delimiter ;
create table faqs
(
	id_faq	int(10),
    pregunta varchar(1000),
    contestada tinyint,
    primary key (id_faq)
);

create table respuestasFaqs
(
	id_respuesta int(10),
	id_faq int(10),
    respuesta	varchar(1000),
    id_entrenador int(10),
    primary key (id_respuesta),
    foreign key (id_faq) references faqs(id_faq)
);

select * from respuestasFaqs inner join faqs on respuestasFaqs.id_faq = faqs.id_faq;
select * from faqs;

create table faqs_fija
(
	id_faqF int(10),
    id_faq int(10),
    respuesta varchar(5000),
    primary key (id_faqf)
);

insert into faqs values(1,'ww',0);
insert into faqs values(2,'Futura faq',0);




create view FAQindex as
select faqs.pregunta, faqs_fija.respuesta from faqs
inner join faqs_fija on id_faqF=faqs.id_faq;
/*
drop view contestada;

create view contestada as
select faqs.* from faqs
inner join faqs_fija where id_faqF=id_faq;

select * from contestada;
*/
delimiter **
create view cualTarea as SELECT ID_TAREA,NOMBRE_PROBLEMA,GRADO_TAREA FROM TAREAS inner join PROBLEMAS on TAREAS.ID_PROBLEMA = PROBLEMAS.ID_PROBLEMA;**

delimiter ;
USE OMNIKNOW;
CREATE TABLE CHATS 
(
	ID_CHAT		INT(10),
	ID_USER1	INT(10),
    ID_USER2	INT(10),
    primary key(ID_CHAT)
);

create table MENSAJES
(
	ID_MENSAJE	INT,
    ID_EMISOR	INT,
    ID_RECEPTOR	INT,
    ID_CHAT	INT,
    CONTENIDO	TEXT,
    FECHA	DATETIME,
    primary key(ID_MENSAJE),
    FOREIGN KEY (ID_CHAT) REFERENCES CHATS(ID_CHAT)
);


delimiter **

DROP PROCEDURE IF EXISTS TRAE_CHAT**
CREATE PROCEDURE TRAE_CHAT(IN ID_EMISOR INT, IN ID_RECEPTOR INT)
BEGIN
	DECLARE _ID INT;
    DECLARE EXISTE INT;
    DECLARE _ID_CONVERSACION INT;
    
    SET EXISTE = ( SELECT COUNT(*) FROM CHATS WHERE (ID_USER1 = ID_EMISOR        	AND ID_USER2 = ID_RECEPTOR) OR  (ID_USER1 = ID_RECEPTOR  	AND ID_USER2 = ID_EMISOR) );
	IF ( EXISTE = 0 ) THEN
			SET _ID_CONVERSACION = (SELECT IFNULL(MAX(ID_CHAT),0)+1 FROM CHATS);
			INSERT INTO CHATS VALUES(_ID_CONVERSACION,ID_EMISOR,ID_RECEPTOR);
            SELECT _ID_CONVERSACION AS ID_CHAT;
    ELSE
			SELECT ID_CHAT FROM CHATS WHERE (ID_USER1 = ID_EMISOR        	AND ID_USER2 = ID_RECEPTOR) OR (ID_USER1 = ID_RECEPTOR  	AND ID_USER2 = ID_EMISOR);
    END IF;
END**

CALL TRAE_CHAT(1,2)**

DROP PROCEDURE IF EXISTS TRAE_MENSAJES**
CREATE PROCEDURE TRAE_MENSAJES(IN _ID_CONVERSACION INT)
BEGIN
	SELECT * FROM MENSAJES WHERE ID_CHAT = _ID_CONVERSACION;
END**
call TRAE_CHAT(1,2)**

DROP PROCEDURE IF EXISTS AGREGAR_MSJ**
CREATE PROCEDURE AGREGAR_MSJ(IN _ID_EMISOR INT,IN _ID_RECEPTOR INT,IN _ID_CONVERSACION INT,IN _CONTENIDO TEXT, IN _FECHA datetime)
BEGIN
	DECLARE _ID_MENSAJE INT;
    SET _ID_MENSAJE = (SELECT IFNULL(MAX(ID_MENSAJE),0)+1 FROM MENSAJES);
    INSERT INTO MENSAJES VALUES(_ID_MENSAJE,_ID_EMISOR,_ID_RECEPTOR,_ID_CONVERSACION,_CONTENIDO,_FECHA);
END**

delimiter ;
/*COSAS DE JUANMANUEL*/
use omniknow;
CREATE TABLE REPORTES
(
	ID_REPORTE	INT(10) PRIMARY KEY auto_increment,
    CORREO		VARCHAR(200),
    NOMBRE		VARCHAR(200),
    PROBLEMA	TEXT,
    SOLUCION TEXT,
    ID_INGE		INT(10),
    ESTADO		VARCHAR(200)
);