/*                           Tabla «public.albumes»
   Columna    |         Tipo          | Ordenamiento | Nulable  | Por omisión
--------------+-----------------------+--------------+----------+-------------
 id_al        | character varying(10) |              | not null |
 id_art       | character varying(10) |              |          |
 titulo_al    | character varying(50) |              | not null |
 fecha_al     | date                  |              | not null |
 numpistas_al | smallint              |              | not null |
 genero_al    | character varying(30) |              | not null |
 precio_al    | real                  |              | not null |
 url_al       | text                  |    

                           Tabla «public.canciones»
   Columna    |          Tipo          | Ordenamiento | Nulable  | Por omisión
--------------+------------------------+--------------+----------+-------------
 id_can       | character varying(10)  |              | not null |
 id_al        | character varying(10)  |              |          |
 nombre_can   | character varying(50)  |              | not null |
 duracion_can | time without time zone |              | not null |
 nropista_can | smallint               |              | not null |
 genero_can   | character varying(30)  |              | not null |
 url_can      | text                   |              |          |

*/
/*
 id_art | nombreartistico_art |        email_art         | contrasena_art | pais_art
--------+---------------------+--------------------------+----------------+----------
 001    | Alcaloides          | alcaloide@mail.com       | alca           | Ecuador
 003    | Guardarraya         | guardarrayapapa@mail.com | alavaro        | Ecuador
 */

 insert into albumes values('ALBM-001', '001', 'La Sombra Fuera Del Espacio', '2011-05-24', 5, 'Rock', 5.5, 'https://www.discogs.com/es/release/12576022-Los-Alkaloides-La-Sombra-Fuera-Del-Espacio');

 insert into canciones values('CAN-01', 'ALBM-001', 'Perdidos En El Tiempo', '00:03:21', 1, 'Rock', 'none');
 insert into canciones values('CAN-02', 'ALBM-001', 'Te Enamoraste', '00:03:15', 2, 'Rock', 'none');
 insert into canciones values('CAN-03', 'ALBM-001', 'La Sombra Fuera Del Espacio', '00:04:18', 3, 'Rock', 'none');
 insert into canciones values('CAN-04', 'ALBM-001', 'El Perro Que No Aguanta Mas', '00:03:21', 4, 'Rock', 'none');