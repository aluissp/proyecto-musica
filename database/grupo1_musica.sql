/*==============================================================*/
/* DBMS name:      PostgreSQL 9.x                               */
/* Created on:     30/12/2021 17:03:43                          */
/*==============================================================*/


drop index ARTISTAS_ALBUMES_FK;

drop index ALBUMES_PK;

drop table ALBUMES;

drop index ARTISTA_PK;

drop table ARTISTA;

drop index ALBUMES_CANCIONES_FK;

drop index CANCIONES_PK;

drop table CANCIONES;

drop index ALBUM_FAC_FK;

drop index FACTURAS_DET_FK;

drop table DETALLE_FACTURA;

drop index USUARIOS_FACTURAS_FK;

drop index FACTURAS_PK;

drop table FACTURAS;

drop index PLAN_PK;

drop table PLAN;

drop index PLAN_SUS_FK;

drop index ARTISTA_SUSCRIPCION_FK;

drop index SUSCRIPCION_PK;

drop table SUSCRIPCION;

drop index ARTISTAS_TAR_FK;

drop index USUARIO_TAR_FK;

drop index TARJETAS_BANCARIAS_PK;

drop table TARJETAS_BANCARIAS;

drop index USUARIOS_PK;

drop table USUARIOS;

/*==============================================================*/
/* Table: ALBUMES                                               */
/*==============================================================*/
create table ALBUMES (
   ID_AL                VARCHAR(10)          not null,
   ID_ART               VARCHAR(10)          null,
   TITULO_AL            VARCHAR(50)          not null,
   FECHA_AL             DATE                 not null,
   NUMPISTAS_AL         INT2                 not null,
   GENERO_AL            VARCHAR(30)          not null,
   PRECIO_AL            FLOAT4               not null,
   URL_AL               TEXT                 not null,
   constraint PK_ALBUMES primary key (ID_AL)
);

/*==============================================================*/
/* Index: ALBUMES_PK                                            */
/*==============================================================*/
create unique index ALBUMES_PK on ALBUMES (
ID_AL
);

/*==============================================================*/
/* Index: ARTISTAS_ALBUMES_FK                                   */
/*==============================================================*/
create  index ARTISTAS_ALBUMES_FK on ALBUMES (
ID_ART
);

/*==============================================================*/
/* Table: ARTISTA                                               */
/*==============================================================*/
create table ARTISTA (
   ID_ART               VARCHAR(10)          not null,
   NOMBREARTISTICO_ART  VARCHAR(50)          not null,
   EMAIL_ART            VARCHAR(50)          not null,
   CONTRASENA_ART       VARCHAR(50)          not null,
   PAIS_ART             VARCHAR(20)          not null,
   constraint PK_ARTISTA primary key (ID_ART)
);

/*==============================================================*/
/* Index: ARTISTA_PK                                            */
/*==============================================================*/
create unique index ARTISTA_PK on ARTISTA (
ID_ART
);

/*==============================================================*/
/* Table: CANCIONES                                             */
/*==============================================================*/
create table CANCIONES (
   ID_CAN               VARCHAR(10)          not null,
   ID_AL                VARCHAR(10)          null,
   NOMBRE_CAN           VARCHAR(50)          not null,
   DURACION_CAN         TIME                 not null,
   NROPISTA_CAN         INT2                 not null,
   GENERO_CAN           VARCHAR(30)          not null,
   URL_CAN              TEXT                 null,
   constraint PK_CANCIONES primary key (ID_CAN)
);

/*==============================================================*/
/* Index: CANCIONES_PK                                          */
/*==============================================================*/
create unique index CANCIONES_PK on CANCIONES (
ID_CAN
);

/*==============================================================*/
/* Index: ALBUMES_CANCIONES_FK                                  */
/*==============================================================*/
create  index ALBUMES_CANCIONES_FK on CANCIONES (
ID_AL
);

/*==============================================================*/
/* Table: DETALLE_FACTURA                                       */
/*==============================================================*/
create table DETALLE_FACTURA (
   CODIGO_FAC           VARCHAR(10)          null,
   ID_AL                VARCHAR(10)          null,
   CANTIDAD_FAC         INT2                 not null,
   DESCRIPCION_FAC      TEXT                 not null
);

/*==============================================================*/
/* Index: FACTURAS_DET_FK                                       */
/*==============================================================*/
create  index FACTURAS_DET_FK on DETALLE_FACTURA (
CODIGO_FAC
);

/*==============================================================*/
/* Index: ALBUM_FAC_FK                                          */
/*==============================================================*/
create  index ALBUM_FAC_FK on DETALLE_FACTURA (
ID_AL
);

/*==============================================================*/
/* Table: FACTURAS                                              */
/*==============================================================*/
create table FACTURAS (
   CODIGO_FAC           VARCHAR(10)          not null,
   ID_USU               VARCHAR(10)          null,
   FECHAEMISION_FAC     DATE                 not null,
   SUBTOTAL_FAC         FLOAT4               not null,
   IVA_FAC              FLOAT4               not null,
   TOTAL_FAC            FLOAT4               not null,
   constraint PK_FACTURAS primary key (CODIGO_FAC)
);

/*==============================================================*/
/* Index: FACTURAS_PK                                           */
/*==============================================================*/
create unique index FACTURAS_PK on FACTURAS (
CODIGO_FAC
);

/*==============================================================*/
/* Index: USUARIOS_FACTURAS_FK                                  */
/*==============================================================*/
create  index USUARIOS_FACTURAS_FK on FACTURAS (
ID_USU
);

/*==============================================================*/
/* Table: PLAN                                                  */
/*==============================================================*/
create table PLAN (
   ID_PL                VARCHAR(10)          not null,
   NOMBRE_PL            VARCHAR(50)          not null,
   DESCRIPCION_PL       TEXT                 not null,
   DURACION_PL          INT2                 not null,
   PRECIO_PL            FLOAT4               not null,
   constraint PK_PLAN primary key (ID_PL)
);

/*==============================================================*/
/* Index: PLAN_PK                                               */
/*==============================================================*/
create unique index PLAN_PK on PLAN (
ID_PL
);

/*==============================================================*/
/* Table: SUSCRIPCION                                           */
/*==============================================================*/
create table SUSCRIPCION (
   ID_SUS               VARCHAR(10)          not null,
   ID_ART               VARCHAR(10)          null,
   ID_PL                VARCHAR(10)          null,
   FINICO_SUS           DATE                 not null,
   FFIN_SUS             DATE                 not null,
   SUBTOTAL_SUS         FLOAT4               not null,
   IVA_SUS              FLOAT4               not null,
   TOTAL_SUS            FLOAT4               not null,
   constraint PK_SUSCRIPCION primary key (ID_SUS)
);

/*==============================================================*/
/* Index: SUSCRIPCION_PK                                        */
/*==============================================================*/
create unique index SUSCRIPCION_PK on SUSCRIPCION (
ID_SUS
);

/*==============================================================*/
/* Index: ARTISTA_SUSCRIPCION_FK                                */
/*==============================================================*/
create  index ARTISTA_SUSCRIPCION_FK on SUSCRIPCION (
ID_ART
);

/*==============================================================*/
/* Index: PLAN_SUS_FK                                           */
/*==============================================================*/
create  index PLAN_SUS_FK on SUSCRIPCION (
ID_PL
);

/*==============================================================*/
/* Table: TARJETAS_BANCARIAS                                    */
/*==============================================================*/
create table TARJETAS_BANCARIAS (
   ID_TAR               VARCHAR(10)          not null,
   ID_USU               VARCHAR(10)          null,
   ID_ART               VARCHAR(10)          null,
   TIPO_TAR             VARCHAR(20)          not null,
   NUMERO_TAR           VARCHAR(50)          not null,
   MESCADUCIDAD_TAR     INT2                 not null,
   ANIOCADUCIDAD_TAR    INT2                 not null,
   CODIGOSEGURIDAD_TAR  INT2                 not null,
   constraint PK_TARJETAS_BANCARIAS primary key (ID_TAR)
);

/*==============================================================*/
/* Index: TARJETAS_BANCARIAS_PK                                 */
/*==============================================================*/
create unique index TARJETAS_BANCARIAS_PK on TARJETAS_BANCARIAS (
ID_TAR
);

/*==============================================================*/
/* Index: USUARIO_TAR_FK                                        */
/*==============================================================*/
create  index USUARIO_TAR_FK on TARJETAS_BANCARIAS (
ID_USU
);

/*==============================================================*/
/* Index: ARTISTAS_TAR_FK                                       */
/*==============================================================*/
create  index ARTISTAS_TAR_FK on TARJETAS_BANCARIAS (
ID_ART
);

/*==============================================================*/
/* Table: USUARIOS                                              */
/*==============================================================*/
create table USUARIOS (
   ID_USU               VARCHAR(10)          not null,
   NOMBRE_USU           VARCHAR(50)          not null,
   APELLIDO_USU         VARCHAR(50)          not null,
   EMAIL_USU            VARCHAR(50)          not null,
   CONTRASENA_USU       VARCHAR(50)          not null,
   FNACIMIENTO_USU      DATE                 not null,
   IDENTIDAD_USU        VARCHAR(15)          not null,
   PAIS_USU             VARCHAR(15)          not null,
   constraint PK_USUARIOS primary key (ID_USU)
);

/*==============================================================*/
/* Index: USUARIOS_PK                                           */
/*==============================================================*/
create unique index USUARIOS_PK on USUARIOS (
ID_USU
);

alter table ALBUMES
   add constraint FK_ALBUMES_ARTISTAS__ARTISTA foreign key (ID_ART)
      references ARTISTA (ID_ART)
      on delete restrict on update restrict;

alter table CANCIONES
   add constraint FK_CANCIONE_ALBUMES_C_ALBUMES foreign key (ID_AL)
      references ALBUMES (ID_AL)
      on delete restrict on update restrict;

alter table DETALLE_FACTURA
   add constraint FK_DETALLE__ALBUM_FAC_ALBUMES foreign key (ID_AL)
      references ALBUMES (ID_AL)
      on delete restrict on update restrict;

alter table DETALLE_FACTURA
   add constraint FK_DETALLE__FACTURAS__FACTURAS foreign key (CODIGO_FAC)
      references FACTURAS (CODIGO_FAC)
      on delete restrict on update restrict;

alter table FACTURAS
   add constraint FK_FACTURAS_USUARIOS__USUARIOS foreign key (ID_USU)
      references USUARIOS (ID_USU)
      on delete restrict on update restrict;

alter table SUSCRIPCION
   add constraint FK_SUSCRIPC_ARTISTA_S_ARTISTA foreign key (ID_ART)
      references ARTISTA (ID_ART)
      on delete restrict on update restrict;

alter table SUSCRIPCION
   add constraint FK_SUSCRIPC_PLAN_SUS_PLAN foreign key (ID_PL)
      references PLAN (ID_PL)
      on delete restrict on update restrict;

alter table TARJETAS_BANCARIAS
   add constraint FK_TARJETAS_ARTISTAS__ARTISTA foreign key (ID_ART)
      references ARTISTA (ID_ART)
      on delete restrict on update restrict;

alter table TARJETAS_BANCARIAS
   add constraint FK_TARJETAS_USUARIO_T_USUARIOS foreign key (ID_USU)
      references USUARIOS (ID_USU)
      on delete restrict on update restrict;

