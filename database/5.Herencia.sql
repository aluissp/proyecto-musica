----SCRIPT HERENCIA---
CREATE TABLE personas
(
   nombres        VARCHAR(50),
   apellidos      VARCHAR(50),
   genero       VARCHAR(20),
   fecha_nacim    DATE
);

--HACER DROP CASCADE EN TABLA USUARIOS;

--tabla usuarios--

CREATE TABLE IF NOT EXISTS public.usuarios
(
    id_usu character varying(10) NOT NULL,
    email_usu character varying(50) NOT NULL,
    contrasena_usu character varying(50)  NOT NULL,
    CONSTRAINT pk_usuarios PRIMARY KEY (id_usu)
)inherits (personas);

ALTER TABLE public.usuarios OWNER to postgres;

create unique index USUARIOS_PK on USUARIOS (
ID_USU
);

--relacion con facturas--
alter table FACTURAS
   add constraint FK_FACTURAS_USUARIOS__USUARIOS foreign key (ID_USU)
      references USUARIOS (ID_USU)
      on delete cascade on update cascade;

--tarjetas usuarios--
alter table TARJETAS_USUARIOS
   add constraint FK_TARJETAS_USUARIOS__USUARIOS foreign key (ID_USU)
      references USUARIOS (ID_USU)
      on delete cascade on update cascade;


--modificar tabla facturas--

alter table facturas drop column fechaemision_fac;
alter table facturas drop column subtotal_fac;
alter table facturas drop column iva_fac;
alter table facturas drop column total_fac;

alter table facturas add column cantidad_fac int2;
alter table facturas add column fechaemision_fac date;
alter table facturas add column subtotal_fac float8;
alter table facturas add column iva_fac float8;
alter table facturas add column total_fac float8;


--tabla administradores--


CREATE TABLE ADMINISTRADORES
(
    id_adm character varying(15) NOT NULL,
    email_usu character varying(50) NOT NULL,
    contrasena_usu character varying(50)  NOT NULL,
    CONSTRAINT pk_administradores PRIMARY KEY (id_adm)
)inherits (personas);


-------------------------------------------------------------------------
-------------albumes y genero--------

select * from albumes;

alter table albumes drop column genero_alb;

CREATE TABLE GENEROS
(
    id_gen character varying(10) NOT NULL,
    nombre_gen character varying(50) NOT NULL,
    CONSTRAINT pk_generos PRIMARY KEY (id_gen)
);

ALTER TABLE generos OWNER to postgres;

create unique index GENEROS_PK on GENEROS (
ID_GEN
);

alter table albumes add column id_gen character varying(10);

alter table ALBUMES
   add constraint FK_ALBUMES_GENEROS__GENEROS foreign key (ID_GEN)
      references GENEROS (ID_GEN)
      on delete cascade on update cascade;

select * from albumes;

select * from generos;
insert into generos values ('gen-1','SALSA')
insert into generos values ('gen-2','POP')
insert into generos values ('gen-3','ROCK POP')

select * from albumes;
INSERT INTO public.albumes(
	id_art, nombre_alb, precio_alb, fecha_alb,id_gen)
	VALUES ('art-5', 'AULLIDOS', 50, '16-01-2022','gen-2');
