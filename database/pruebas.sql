insert into usuarios
values(
        '001',
        'Luis',
        'Perugachi',
        'luis@mail.com',
        'hola',
        '05/01/2002',
        'Hombre',
        'Ecuador'
    );
insert into usuarios
values(
        '002',
        'Maite',
        'Perugachi',
        'maite@mail.com',
        'gato',
        '12/04/2010',
        'Mujer',
        'Ecuador'
    );


create table ARTISTA (
    ID_ART VARCHAR(10) not null,
    NOMBREARTISTICO_ART VARCHAR(50) not null,
    EMAIL_ART VARCHAR(50) not null,
    CONTRASENA_ART VARCHAR(50) not null,
    PAIS_ART VARCHAR(20) not null,
    constraint PK_ARTISTA primary key (ID_ART)
);