PGDMP     &    .    
             z            BDD_GRUPO1_MUSICA    14.0    14.0 Z    \           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            ]           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            ^           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            _           1262    26023    BDD_GRUPO1_MUSICA    DATABASE     q   CREATE DATABASE "BDD_GRUPO1_MUSICA" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'Spanish_Ecuador.1252';
 #   DROP DATABASE "BDD_GRUPO1_MUSICA";
                postgres    false            �            1255    26188    f_val_date(character varying)    FUNCTION     �   CREATE FUNCTION public.f_val_date(s character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
begin
  perform s::date;
  return true;
exception when others then
  return false;
end;
$$;
 6   DROP FUNCTION public.f_val_date(s character varying);
       public          postgres    false            �            1255    26142    f_val_email(character varying)    FUNCTION     �   CREATE FUNCTION public.f_val_email(email character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
BEGIN
	IF (email !~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9-]+[.][A-Za-z]+$') THEN
		RETURN FALSE;
	ELSE
		RETURN TRUE;
	END IF;
END
$_$;
 ;   DROP FUNCTION public.f_val_email(email character varying);
       public          postgres    false            �            1255    26180    f_val_num(double precision)    FUNCTION     �   CREATE FUNCTION public.f_val_num(double precision) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
DECLARE x NUMERIC;
BEGIN
    RETURN TRUE;
END;
$$;
 2   DROP FUNCTION public.f_val_num(double precision);
       public          postgres    false            �            1255    26179    f_val_num(smallint)    FUNCTION     �   CREATE FUNCTION public.f_val_num(smallint) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
DECLARE x NUMERIC;
BEGIN
    RETURN TRUE;
END;
$$;
 *   DROP FUNCTION public.f_val_num(smallint);
       public          postgres    false            �            1255    26178    f_val_num(integer)    FUNCTION     �   CREATE FUNCTION public.f_val_num(integer) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
DECLARE x NUMERIC;
BEGIN
    RETURN TRUE;
END;
$$;
 )   DROP FUNCTION public.f_val_num(integer);
       public          postgres    false            �            1255    26177    f_val_num(bigint)    FUNCTION     �   CREATE FUNCTION public.f_val_num(bigint) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
DECLARE x NUMERIC;
BEGIN
    RETURN TRUE;
END;
$$;
 (   DROP FUNCTION public.f_val_num(bigint);
       public          postgres    false            �            1255    26175    f_val_num(text)    FUNCTION     �   CREATE FUNCTION public.f_val_num(text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $_$
DECLARE x NUMERIC;
BEGIN
    x = $1::NUMERIC;
    RETURN TRUE;
EXCEPTION WHEN others THEN
    RETURN FALSE;
END;
$_$;
 &   DROP FUNCTION public.f_val_num(text);
       public          postgres    false            �            1255    26173    t_val_alb()    FUNCTION       CREATE FUNCTION public.t_val_alb() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if length (new.id_art) = 0 then
		raise exception 'El id del artista es obligatorio';
	end if;
	
	if length (new.nombre_alb) = 0 then
		raise exception 'Escribir el nombre del album';
	end if;
	
	if length (new.genero_alb) = 0 then
		raise exception 'Escriba el género de su album';
	end if;
	
	if f_val_num(new.precio_alb) = false then
		raise exception 'Escriba una cantidad correcta';
	end if;
	
	if new.precio_alb < 0 then
		raise exception 'El precio debe ser un valor positivo';
	end if;
	
	----------------------------------------------------
	
	if (TG_OP='INSERT') then 
	
		if length (new.id_alb) > 0 then
			raise exception 'El id del album lo pone el sistema';
		end if;
		
		if not exists (select id_art from artistas where id_art=new.id_art) then
			raise exception 'El id del artista no existe en la tabla artistas';
		end if;
		
		if exists (select nombre_alb, id_art from albumes where (nombre_alb=new.nombre_alb) and (id_art=new.id_art)) then
			raise exception 'El artista ya tiene un album con ese nombre, ponga otro nombre';
		end if;					
		
		if new.numpistas_alb > 0 then
			raise exception 'El número de pistas lo pone el sistema';
		end if;
	
	new.id_alb:='alb-'||nextval('sec_alb');		
	new.numpistas_alb:=0;	
	return new;
	end if;
	
	-----------------------------------------------------------------------------------
	
	if (TG_OP='UPDATE') then
	
		if new.id_alb <> old.id_Alb then
			raise exception 'El id del album lo pone el sistema';
		end if;
		
		if new.id_art <> old.id_art then
			raise exception 'El id del artista lo controla el sistema';
		end if;
		
		if exists (select nombre_alb, id_art from albumes where (nombre_alb=new.nombre_alb) and (id_art=new.id_art)) then
			raise exception 'El artista ya tiene un album con ese nombre, ponga otro nombre';
		end if;	
		
		if new.numpistas_alb <> old.numpistas_alb then
			raise exception 'el numero de pistas lo controla el sistema';
		end if;
		
	return new;
	end if;
end;
$$;
 "   DROP FUNCTION public.t_val_alb();
       public          postgres    false            �            1255    26150    t_val_art()    FUNCTION     �  CREATE FUNCTION public.t_val_art() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin	

	if length (new.seudonimo_art) = 0 then
		raise exception 'Ingrese su nombre artistico';
	end if;	
	
	if length (new.email_art) = 0 then
		raise exception 'El correo es un campo obligatorio';
	end if;
	
	if f_val_email(new.email_art) = false then
		raise exception 'Escribir un correo válido';
	end if;		
	if length (new.contrasena_art) < 10 then
		raise exception 'La contraseña debe tener mínimo 10 caracteres';
	end if;

	if length (new.pais_art) = 0 then
		raise exception 'Ingrese un país';
	end if;

	--------------------------------------------------------------------------
	if (TG_OP='INSERT') then
		if exists (select seudonimo_art from artistas where seudonimo_art=new.seudonimo_art) then
			raise exception 'El nombre del artista ya ha sido registrado';
		end if;
		
		if exists (select email_art from artistas where email_art=new.email_art) then
			raise exception 'El correo ya ha sido registrado, ingrese otro';
		end if;
		
		if length (new.id_art) = null or length (new.id_art) > 0  or length (new.id_art) = 0 then
			raise exception 'El id del artista lo ingresa el sistema';
		end if;
		
		new.id_art:='art-'||nextval('sec_art');		
		return new;
	end if;	
	-----------------------------------------------------------------
	
	if (TG_OP='UPDATE') then
	
		if new.id_art <> old.id_art then
			raise exception 'El id no se puede cambiar';
		end if;
			
		if new.seudonimo_art <> old.seudonimo_art then
			if exists (select seudonimo_art from artistas where seudonimo_art=new.seudonimo_art) then
				raise exception 'El nombre del artista ya ha sido registrado';							
			end if;
		end if;		
		
		if new.email_art <> old.email_art then
			if exists (select email_art from artistas where email_art=new.email_art) then
				raise exception 'Este email ya ha sido registrado';
			end if;
		end if;		
		return new;
	end if;
end
$$;
 "   DROP FUNCTION public.t_val_art();
       public          postgres    false            �            1255    26182    t_val_can()    FUNCTION     w  CREATE FUNCTION public.t_val_can() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin 	
	
	if length (new.nombre_can) = 0 then
		raise exception 'Escriba el nombre de la canción';
	end if;
	
	--------------------------------------------------------------
	
	if (TG_OP='INSERT') then
		
		if length (new.id_can) > 0 then
			raise exception 'El id de las canciones lo pone el sistema';
		end if;
	
		if not exists (select id_alb from albumes where id_alb=new.id_alb) then
			raise exception 'No existe el album con ese id';
		end if;
		
		if exists (select id_alb, nombre_can from canciones where (id_alb=new.id_alb) and (nombre_can=new.nombre_can)) then
			raise exception 'No puede haber una canción con el mismo nombre en el mismo album';
		end if;				
		
		if new.nropista_can <> old.nropista_can then
			raise exception 'El numero de pista se encarga el sistema';
		end if;
											
	new.nropista_can:= 1 + count(old.nropista_can)from canciones where id_alb=new.id_alb;
	new.id_can:='can-'||nextval('sec_can');
	return new;
	end if;
	----------------------------------------------------------------------------
	return new;
end;
$$;
 "   DROP FUNCTION public.t_val_can();
       public          postgres    false            �            1255    26186    t_val_sus()    FUNCTION     �  CREATE FUNCTION public.t_val_sus() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (TG_OP='INSERT') then
		if length (new.id_sus) then
			raise exception 'El id de suscripciones lo pone el sistema';
		end if;
		
		if not exists (select id_art from artistas where id_art=new.id_art) then
			raise exception 'El id del artista no existe en la tabla artistas';
		end if;
		
		if not exists (select id_pl from planes where id_pl=new.id_pl) then
			raise exception 'El id del plan no existe en la tabla planes';
		end if;
		
		if length (new.finicio_sus) > 0 then 
			raise exception 'La fecha de inicio se pone pone automáticamente despues de';
		end if;
		
		if f_val_date(new.ffin_sus) = false then
			raise exception 'Escriba una fecha valida';
		end if;
		
		if new.subtotal_sus <> old.subtotal_sus then
			raise exception 'El subtotal lo calcula el sistema';
		end if;
		
		if new.iva_sus <> old.iva_sus then
			raise exception 'El iva lo calcula el sistema';
		end if;
			
		if new.total_sus <> old.total_sus then
			raise exception 'El total lo calcula el sistema';
		end if;
		
		new.finicio_sus:= current_date;
		new.subtotal_sus:= precio_pl from planes where id_pl=new.id_pl;
		new.iva_sus:= new.subtotal_sus * 0.12;
		new.total_sus:= new.subtotal_sus + new.iva_sus;
		new.id_sus:='sus-'||nextval('sec_sus');
	end if;
	
	if (TG_OP='UPDATE') then
		if new.id_sus <> old.id_art then
			raise exception 'El id de suscripcion lo controla el sistema';
		end if;
		
		if new.id_art <> old.id_art then
			raise exception 'el id del artista no se puede cambiar';
		end if;
		
		if new.id_pl <> old.id_pl then
			raise exception 'El id del plan no se puede cambiar';
		end if;
		
		if f_val_date(new.finicio_sus) = false then
			raise exception 'Ingrese una fecha válida';
		end if;
		
		if f_val_date(new.ffin_sus) = false then
			raise exception 'Ingrese una fecha válida';
		end if;
	
		if new.subtotal_sus <> old.subtotal_sus then
			raise exception 'El subtotal lo controla el sistema';
		end if;
		
		if new.iva_sus <> old.iva_sus then
			raise exception 'El iva lo controla el sistema';
		end if;
		
		if new.total_sus <> old.total_sus then
			raise exception 'El total lo controla el sistema';
		end if;
	end if;
	return new;
end;
$$;
 "   DROP FUNCTION public.t_val_sus();
       public          postgres    false            �            1259    26024    albumes    TABLE       CREATE TABLE public.albumes (
    id_alb character varying(10) NOT NULL,
    id_art character varying(10),
    nombre_alb character varying(50) NOT NULL,
    numpistas_alb smallint,
    genero_alb character varying(50) NOT NULL,
    precio_alb double precision NOT NULL
);
    DROP TABLE public.albumes;
       public         heap    postgres    false            �            1259    26031    artistas    TABLE       CREATE TABLE public.artistas (
    id_art character varying(10) NOT NULL,
    seudonimo_art character varying(50) NOT NULL,
    email_art character varying(50) NOT NULL,
    contrasena_art character varying(50) NOT NULL,
    pais_art character varying(20) NOT NULL
);
    DROP TABLE public.artistas;
       public         heap    postgres    false            �            1259    26037 	   canciones    TABLE     �   CREATE TABLE public.canciones (
    id_can character varying(10) NOT NULL,
    id_alb character varying(10),
    nombre_can character varying(50) NOT NULL,
    duracion_can time without time zone NOT NULL,
    nropista_can smallint NOT NULL
);
    DROP TABLE public.canciones;
       public         heap    postgres    false            �            1259    26044    detalles_facturas    TABLE     �   CREATE TABLE public.detalles_facturas (
    id_alb character varying(10),
    codigo_fac character varying(10),
    cantidad_fac smallint NOT NULL,
    descripcion_fac text NOT NULL
);
 %   DROP TABLE public.detalles_facturas;
       public         heap    postgres    false            �            1259    26051    facturas    TABLE     �   CREATE TABLE public.facturas (
    codigo_fac character varying(10) NOT NULL,
    id_usu character varying(10),
    fechaemision_fac date NOT NULL,
    subtotal_fac real NOT NULL,
    iva_fac real NOT NULL,
    total_fac real NOT NULL
);
    DROP TABLE public.facturas;
       public         heap    postgres    false            �            1259    26058    planes    TABLE     �   CREATE TABLE public.planes (
    id_pl character varying(10) NOT NULL,
    nombre_pl character varying(50) NOT NULL,
    descripcion_pl text NOT NULL,
    duracion_pl date NOT NULL,
    precio_pl real NOT NULL
);
    DROP TABLE public.planes;
       public         heap    postgres    false            �            1259    26172    sec_alb    SEQUENCE        CREATE SEQUENCE public.sec_alb
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE public.sec_alb;
       public          postgres    false    209            `           0    0    sec_alb    SEQUENCE OWNED BY     >   ALTER SEQUENCE public.sec_alb OWNED BY public.albumes.id_alb;
          public          postgres    false    220            �            1259    26144    sec_art    SEQUENCE        CREATE SEQUENCE public.sec_art
    AS integer
    START WITH 5
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE public.sec_art;
       public          postgres    false    210            a           0    0    sec_art    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.sec_art OWNED BY public.artistas.id_art;
          public          postgres    false    219            �            1259    26181    sec_can    SEQUENCE        CREATE SEQUENCE public.sec_can
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE public.sec_can;
       public          postgres    false    211            b           0    0    sec_can    SEQUENCE OWNED BY     @   ALTER SEQUENCE public.sec_can OWNED BY public.canciones.id_can;
          public          postgres    false    221            �            1259    26189    sec_pla    SEQUENCE        CREATE SEQUENCE public.sec_pla
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE public.sec_pla;
       public          postgres    false    214            c           0    0    sec_pla    SEQUENCE OWNED BY     <   ALTER SEQUENCE public.sec_pla OWNED BY public.planes.id_pl;
          public          postgres    false    223            �            1259    26066    suscripciones    TABLE     &  CREATE TABLE public.suscripciones (
    id_sus character varying(10) NOT NULL,
    id_art character varying(10),
    id_pl character varying(10),
    finico_sus date NOT NULL,
    ffin_sus date NOT NULL,
    subtotal_sus real NOT NULL,
    iva_sus real NOT NULL,
    total_sus real NOT NULL
);
 !   DROP TABLE public.suscripciones;
       public         heap    postgres    false            �            1259    26185    sec_sus    SEQUENCE     ~   CREATE SEQUENCE public.sec_sus
    AS integer
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE public.sec_sus;
       public          postgres    false    215            d           0    0    sec_sus    SEQUENCE OWNED BY     D   ALTER SEQUENCE public.sec_sus OWNED BY public.suscripciones.id_sus;
          public          postgres    false    222            �            1259    26074    tarjetas_artistas    TABLE     �   CREATE TABLE public.tarjetas_artistas (
    id_tar character varying(10) NOT NULL,
    id_art character varying(10),
    tipo_tar character varying(20) NOT NULL,
    numero_tar character varying(50) NOT NULL,
    fcaducidad date NOT NULL
);
 %   DROP TABLE public.tarjetas_artistas;
       public         heap    postgres    false            �            1259    26081    tarjetas_pagos    TABLE     �   CREATE TABLE public.tarjetas_pagos (
    id_tar character varying(10) NOT NULL,
    id_usu character varying(10),
    tipo_tar character varying(20) NOT NULL,
    numero_tar character varying(50) NOT NULL,
    fcaducidad_tar date NOT NULL
);
 "   DROP TABLE public.tarjetas_pagos;
       public         heap    postgres    false            �            1259    26088    usuarios    TABLE     �  CREATE TABLE public.usuarios (
    id_usu character varying(10) NOT NULL,
    nombre_usu character varying(50) NOT NULL,
    apellido_usu character varying(50) NOT NULL,
    email_usu character varying(50) NOT NULL,
    contrasena_usu character varying(50) NOT NULL,
    fnacimiento_usu date NOT NULL,
    genero_usu character varying(15) NOT NULL,
    pais_usu character varying(15) NOT NULL
);
    DROP TABLE public.usuarios;
       public         heap    postgres    false            K          0    26024    albumes 
   TABLE DATA           d   COPY public.albumes (id_alb, id_art, nombre_alb, numpistas_alb, genero_alb, precio_alb) FROM stdin;
    public          postgres    false    209   7�       L          0    26031    artistas 
   TABLE DATA           ^   COPY public.artistas (id_art, seudonimo_art, email_art, contrasena_art, pais_art) FROM stdin;
    public          postgres    false    210   ��       M          0    26037 	   canciones 
   TABLE DATA           [   COPY public.canciones (id_can, id_alb, nombre_can, duracion_can, nropista_can) FROM stdin;
    public          postgres    false    211   ��       N          0    26044    detalles_facturas 
   TABLE DATA           ^   COPY public.detalles_facturas (id_alb, codigo_fac, cantidad_fac, descripcion_fac) FROM stdin;
    public          postgres    false    212   �       O          0    26051    facturas 
   TABLE DATA           j   COPY public.facturas (codigo_fac, id_usu, fechaemision_fac, subtotal_fac, iva_fac, total_fac) FROM stdin;
    public          postgres    false    213   8�       P          0    26058    planes 
   TABLE DATA           Z   COPY public.planes (id_pl, nombre_pl, descripcion_pl, duracion_pl, precio_pl) FROM stdin;
    public          postgres    false    214   U�       Q          0    26066    suscripciones 
   TABLE DATA           v   COPY public.suscripciones (id_sus, id_art, id_pl, finico_sus, ffin_sus, subtotal_sus, iva_sus, total_sus) FROM stdin;
    public          postgres    false    215   r�       R          0    26074    tarjetas_artistas 
   TABLE DATA           ]   COPY public.tarjetas_artistas (id_tar, id_art, tipo_tar, numero_tar, fcaducidad) FROM stdin;
    public          postgres    false    216   ��       S          0    26081    tarjetas_pagos 
   TABLE DATA           ^   COPY public.tarjetas_pagos (id_tar, id_usu, tipo_tar, numero_tar, fcaducidad_tar) FROM stdin;
    public          postgres    false    217   ��       T          0    26088    usuarios 
   TABLE DATA           �   COPY public.usuarios (id_usu, nombre_usu, apellido_usu, email_usu, contrasena_usu, fnacimiento_usu, genero_usu, pais_usu) FROM stdin;
    public          postgres    false    218   ɋ       e           0    0    sec_alb    SEQUENCE SET     6   SELECT pg_catalog.setval('public.sec_alb', 22, true);
          public          postgres    false    220            f           0    0    sec_art    SEQUENCE SET     6   SELECT pg_catalog.setval('public.sec_art', 10, true);
          public          postgres    false    219            g           0    0    sec_can    SEQUENCE SET     5   SELECT pg_catalog.setval('public.sec_can', 4, true);
          public          postgres    false    221            h           0    0    sec_pla    SEQUENCE SET     6   SELECT pg_catalog.setval('public.sec_pla', 1, false);
          public          postgres    false    223            i           0    0    sec_sus    SEQUENCE SET     6   SELECT pg_catalog.setval('public.sec_sus', 1, false);
          public          postgres    false    222            �           2606    26028    albumes pk_albumes 
   CONSTRAINT     T   ALTER TABLE ONLY public.albumes
    ADD CONSTRAINT pk_albumes PRIMARY KEY (id_alb);
 <   ALTER TABLE ONLY public.albumes DROP CONSTRAINT pk_albumes;
       public            postgres    false    209            �           2606    26035    artistas pk_artistas 
   CONSTRAINT     V   ALTER TABLE ONLY public.artistas
    ADD CONSTRAINT pk_artistas PRIMARY KEY (id_art);
 >   ALTER TABLE ONLY public.artistas DROP CONSTRAINT pk_artistas;
       public            postgres    false    210            �           2606    26041    canciones pk_canciones 
   CONSTRAINT     X   ALTER TABLE ONLY public.canciones
    ADD CONSTRAINT pk_canciones PRIMARY KEY (id_can);
 @   ALTER TABLE ONLY public.canciones DROP CONSTRAINT pk_canciones;
       public            postgres    false    211            �           2606    26055    facturas pk_facturas 
   CONSTRAINT     Z   ALTER TABLE ONLY public.facturas
    ADD CONSTRAINT pk_facturas PRIMARY KEY (codigo_fac);
 >   ALTER TABLE ONLY public.facturas DROP CONSTRAINT pk_facturas;
       public            postgres    false    213            �           2606    26064    planes pk_planes 
   CONSTRAINT     Q   ALTER TABLE ONLY public.planes
    ADD CONSTRAINT pk_planes PRIMARY KEY (id_pl);
 :   ALTER TABLE ONLY public.planes DROP CONSTRAINT pk_planes;
       public            postgres    false    214            �           2606    26070    suscripciones pk_suscripciones 
   CONSTRAINT     `   ALTER TABLE ONLY public.suscripciones
    ADD CONSTRAINT pk_suscripciones PRIMARY KEY (id_sus);
 H   ALTER TABLE ONLY public.suscripciones DROP CONSTRAINT pk_suscripciones;
       public            postgres    false    215            �           2606    26078 &   tarjetas_artistas pk_tarjetas_artistas 
   CONSTRAINT     h   ALTER TABLE ONLY public.tarjetas_artistas
    ADD CONSTRAINT pk_tarjetas_artistas PRIMARY KEY (id_tar);
 P   ALTER TABLE ONLY public.tarjetas_artistas DROP CONSTRAINT pk_tarjetas_artistas;
       public            postgres    false    216            �           2606    26085     tarjetas_pagos pk_tarjetas_pagos 
   CONSTRAINT     b   ALTER TABLE ONLY public.tarjetas_pagos
    ADD CONSTRAINT pk_tarjetas_pagos PRIMARY KEY (id_tar);
 J   ALTER TABLE ONLY public.tarjetas_pagos DROP CONSTRAINT pk_tarjetas_pagos;
       public            postgres    false    217            �           2606    26092    usuarios pk_usuarios 
   CONSTRAINT     V   ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT pk_usuarios PRIMARY KEY (id_usu);
 >   ALTER TABLE ONLY public.usuarios DROP CONSTRAINT pk_usuarios;
       public            postgres    false    218            �           1259    26043    albumes_canciones_fk    INDEX     L   CREATE INDEX albumes_canciones_fk ON public.canciones USING btree (id_alb);
 (   DROP INDEX public.albumes_canciones_fk;
       public            postgres    false    211            �           1259    26049    albumes_detallesfacturas_fk    INDEX     [   CREATE INDEX albumes_detallesfacturas_fk ON public.detalles_facturas USING btree (id_alb);
 /   DROP INDEX public.albumes_detallesfacturas_fk;
       public            postgres    false    212            �           1259    26029 
   albumes_pk    INDEX     G   CREATE UNIQUE INDEX albumes_pk ON public.albumes USING btree (id_alb);
    DROP INDEX public.albumes_pk;
       public            postgres    false    209            �           1259    26030    artistas_albumes_fk    INDEX     I   CREATE INDEX artistas_albumes_fk ON public.albumes USING btree (id_art);
 '   DROP INDEX public.artistas_albumes_fk;
       public            postgres    false    209            �           1259    26036    artistas_pk    INDEX     I   CREATE UNIQUE INDEX artistas_pk ON public.artistas USING btree (id_art);
    DROP INDEX public.artistas_pk;
       public            postgres    false    210            �           1259    26072    artistas_suscripciones_fk    INDEX     U   CREATE INDEX artistas_suscripciones_fk ON public.suscripciones USING btree (id_art);
 -   DROP INDEX public.artistas_suscripciones_fk;
       public            postgres    false    215            �           1259    26080    artistas_tarjetasartistas_fk    INDEX     \   CREATE INDEX artistas_tarjetasartistas_fk ON public.tarjetas_artistas USING btree (id_art);
 0   DROP INDEX public.artistas_tarjetasartistas_fk;
       public            postgres    false    216            �           1259    26042    canciones_pk    INDEX     K   CREATE UNIQUE INDEX canciones_pk ON public.canciones USING btree (id_can);
     DROP INDEX public.canciones_pk;
       public            postgres    false    211            �           1259    26050    facturas_detallesfacturas_fk    INDEX     `   CREATE INDEX facturas_detallesfacturas_fk ON public.detalles_facturas USING btree (codigo_fac);
 0   DROP INDEX public.facturas_detallesfacturas_fk;
       public            postgres    false    212            �           1259    26056    facturas_pk    INDEX     M   CREATE UNIQUE INDEX facturas_pk ON public.facturas USING btree (codigo_fac);
    DROP INDEX public.facturas_pk;
       public            postgres    false    213            �           1259    26065 	   planes_pk    INDEX     D   CREATE UNIQUE INDEX planes_pk ON public.planes USING btree (id_pl);
    DROP INDEX public.planes_pk;
       public            postgres    false    214            �           1259    26073    planes_suscripciones_fk    INDEX     R   CREATE INDEX planes_suscripciones_fk ON public.suscripciones USING btree (id_pl);
 +   DROP INDEX public.planes_suscripciones_fk;
       public            postgres    false    215            �           1259    26071    suscripciones_pk    INDEX     S   CREATE UNIQUE INDEX suscripciones_pk ON public.suscripciones USING btree (id_sus);
 $   DROP INDEX public.suscripciones_pk;
       public            postgres    false    215            �           1259    26079    tarjetas_artistas_pk    INDEX     [   CREATE UNIQUE INDEX tarjetas_artistas_pk ON public.tarjetas_artistas USING btree (id_tar);
 (   DROP INDEX public.tarjetas_artistas_pk;
       public            postgres    false    216            �           1259    26086    tarjetas_pagos_pk    INDEX     U   CREATE UNIQUE INDEX tarjetas_pagos_pk ON public.tarjetas_pagos USING btree (id_tar);
 %   DROP INDEX public.tarjetas_pagos_pk;
       public            postgres    false    217            �           1259    26057    usuarios_facturas_fk    INDEX     K   CREATE INDEX usuarios_facturas_fk ON public.facturas USING btree (id_usu);
 (   DROP INDEX public.usuarios_facturas_fk;
       public            postgres    false    213            �           1259    26093    usuarios_pk    INDEX     I   CREATE UNIQUE INDEX usuarios_pk ON public.usuarios USING btree (id_usu);
    DROP INDEX public.usuarios_pk;
       public            postgres    false    218            �           1259    26087    usuarios_tarjetaspagos_fk    INDEX     V   CREATE INDEX usuarios_tarjetaspagos_fk ON public.tarjetas_pagos USING btree (id_usu);
 -   DROP INDEX public.usuarios_tarjetaspagos_fk;
       public            postgres    false    217            �           2620    26176    albumes t_val_alb    TRIGGER     u   CREATE TRIGGER t_val_alb BEFORE INSERT OR UPDATE ON public.albumes FOR EACH ROW EXECUTE FUNCTION public.t_val_alb();
 *   DROP TRIGGER t_val_alb ON public.albumes;
       public          postgres    false    209    243            �           2620    26151    artistas t_val_art    TRIGGER     v   CREATE TRIGGER t_val_art BEFORE INSERT OR UPDATE ON public.artistas FOR EACH ROW EXECUTE FUNCTION public.t_val_art();
 +   DROP TRIGGER t_val_art ON public.artistas;
       public          postgres    false    210    242            �           2620    26183    canciones t_val_can    TRIGGER     w   CREATE TRIGGER t_val_can BEFORE INSERT OR UPDATE ON public.canciones FOR EACH ROW EXECUTE FUNCTION public.t_val_can();
 ,   DROP TRIGGER t_val_can ON public.canciones;
       public          postgres    false    244    211            �           2620    26187    suscripciones t_val_sus    TRIGGER     {   CREATE TRIGGER t_val_sus BEFORE INSERT OR UPDATE ON public.suscripciones FOR EACH ROW EXECUTE FUNCTION public.t_val_sus();
 0   DROP TRIGGER t_val_sus ON public.suscripciones;
       public          postgres    false    245    215            �           2606    26094 %   albumes fk_albumes_artistas__artistas    FK CONSTRAINT     �   ALTER TABLE ONLY public.albumes
    ADD CONSTRAINT fk_albumes_artistas__artistas FOREIGN KEY (id_art) REFERENCES public.artistas(id_art) ON UPDATE RESTRICT ON DELETE RESTRICT;
 O   ALTER TABLE ONLY public.albumes DROP CONSTRAINT fk_albumes_artistas__artistas;
       public          postgres    false    210    3221    209            �           2606    26099 '   canciones fk_cancione_albumes_c_albumes    FK CONSTRAINT     �   ALTER TABLE ONLY public.canciones
    ADD CONSTRAINT fk_cancione_albumes_c_albumes FOREIGN KEY (id_alb) REFERENCES public.albumes(id_alb) ON UPDATE RESTRICT ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.canciones DROP CONSTRAINT fk_cancione_albumes_c_albumes;
       public          postgres    false    211    3218    209            �           2606    26104 /   detalles_facturas fk_detalles_albumes_d_albumes    FK CONSTRAINT     �   ALTER TABLE ONLY public.detalles_facturas
    ADD CONSTRAINT fk_detalles_albumes_d_albumes FOREIGN KEY (id_alb) REFERENCES public.albumes(id_alb) ON UPDATE RESTRICT ON DELETE RESTRICT;
 Y   ALTER TABLE ONLY public.detalles_facturas DROP CONSTRAINT fk_detalles_albumes_d_albumes;
       public          postgres    false    212    209    3218            �           2606    26109 0   detalles_facturas fk_detalles_facturas__facturas    FK CONSTRAINT     �   ALTER TABLE ONLY public.detalles_facturas
    ADD CONSTRAINT fk_detalles_facturas__facturas FOREIGN KEY (codigo_fac) REFERENCES public.facturas(codigo_fac) ON UPDATE RESTRICT ON DELETE RESTRICT;
 Z   ALTER TABLE ONLY public.detalles_facturas DROP CONSTRAINT fk_detalles_facturas__facturas;
       public          postgres    false    3230    213    212            �           2606    26114 '   facturas fk_facturas_usuarios__usuarios    FK CONSTRAINT     �   ALTER TABLE ONLY public.facturas
    ADD CONSTRAINT fk_facturas_usuarios__usuarios FOREIGN KEY (id_usu) REFERENCES public.usuarios(id_usu) ON UPDATE RESTRICT ON DELETE RESTRICT;
 Q   ALTER TABLE ONLY public.facturas DROP CONSTRAINT fk_facturas_usuarios__usuarios;
       public          postgres    false    213    218    3249            �           2606    26119 ,   suscripciones fk_suscripc_artistas__artistas    FK CONSTRAINT     �   ALTER TABLE ONLY public.suscripciones
    ADD CONSTRAINT fk_suscripc_artistas__artistas FOREIGN KEY (id_art) REFERENCES public.artistas(id_art) ON UPDATE RESTRICT ON DELETE RESTRICT;
 V   ALTER TABLE ONLY public.suscripciones DROP CONSTRAINT fk_suscripc_artistas__artistas;
       public          postgres    false    215    210    3221            �           2606    26124 *   suscripciones fk_suscripc_planes_su_planes    FK CONSTRAINT     �   ALTER TABLE ONLY public.suscripciones
    ADD CONSTRAINT fk_suscripc_planes_su_planes FOREIGN KEY (id_pl) REFERENCES public.planes(id_pl) ON UPDATE RESTRICT ON DELETE RESTRICT;
 T   ALTER TABLE ONLY public.suscripciones DROP CONSTRAINT fk_suscripc_planes_su_planes;
       public          postgres    false    3233    215    214            �           2606    26129 0   tarjetas_artistas fk_tarjetas_artistas__artistas    FK CONSTRAINT     �   ALTER TABLE ONLY public.tarjetas_artistas
    ADD CONSTRAINT fk_tarjetas_artistas__artistas FOREIGN KEY (id_art) REFERENCES public.artistas(id_art) ON UPDATE RESTRICT ON DELETE RESTRICT;
 Z   ALTER TABLE ONLY public.tarjetas_artistas DROP CONSTRAINT fk_tarjetas_artistas__artistas;
       public          postgres    false    216    3221    210            �           2606    26134 -   tarjetas_pagos fk_tarjetas_usuarios__usuarios    FK CONSTRAINT     �   ALTER TABLE ONLY public.tarjetas_pagos
    ADD CONSTRAINT fk_tarjetas_usuarios__usuarios FOREIGN KEY (id_usu) REFERENCES public.usuarios(id_usu) ON UPDATE RESTRICT ON DELETE RESTRICT;
 W   ALTER TABLE ONLY public.tarjetas_pagos DROP CONSTRAINT fk_tarjetas_usuarios__usuarios;
       public          postgres    false    3249    217    218            K   <  x�eұn� �?S� C6��%	*������s������������Cן�GG5N�k�jt���G�����8���(�:�@!�h
 ��v%D�O�A�!8c"�񁒊%Ux���CfR�B��-�-�NZޭ6�"�]�R��H�μ!�!�� �j�>�q1R�������/�?��E\��S���n�k�����3�پ0�q���ab��A�Bz���^+�m\q����P����/�`��]Gh>2O�m�$ŶOv�����6��Q,��̹�[�������*̧�矤��?L�5      L   !  x�u�[N�@�����H,7�#���2��_�2b#�!3m�e����,-���|�����uq�G@X<'���4Y�lr�m��ʑ*Yhn�a��Hbb���.�)�܈�pj����p�5�3Ew��Yk����!�sϧ5<B<�0B�2g�պL��
��G��>��W������u���1]T��;F�r}h�\.���'Mi�!n����o�l���}.������Q�ڗ�{�̰���Z�V�QP�/\%O³n�׵qMf1V����ٿ�gc�P��:��kY�$��z      M   W   x�KN��5�L�I�54�N�IMT�Tp�,I�9�9��������ȔӐ+�ЈX��0�����%E���&p�s2����VF�@�=... t�'�      N      x������ � �      O      x������ � �      P      x������ � �      Q      x������ � �      R      x������ � �      S      x������ � �      T      x������ � �     