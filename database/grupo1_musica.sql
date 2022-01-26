--
-- PostgreSQL database dump
--

-- Dumped from database version 13.4
-- Dumped by pg_dump version 13.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: f_val_date(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.f_val_date(s date) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
begin  
  return true;
end;
$$;


ALTER FUNCTION public.f_val_date(s date) OWNER TO postgres;

--
-- Name: f_val_date(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.f_val_date(s character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
begin
  perform s::date;
  return true;
exception when others then
  return false;
end;
$$;


ALTER FUNCTION public.f_val_date(s character varying) OWNER TO postgres;

--
-- Name: f_val_email(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.f_val_email(email character varying) RETURNS boolean
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


ALTER FUNCTION public.f_val_email(email character varying) OWNER TO postgres;

--
-- Name: f_val_num(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.f_val_num(text) RETURNS boolean
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


ALTER FUNCTION public.f_val_num(text) OWNER TO postgres;

--
-- Name: t_act_alb(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.t_act_alb() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (TG_OP='DELETE') then
	update albumes set numpistas_alb= (select count(*) from canciones where id_alb=new.id_alb) where id_alb=new.id_alb;
	end if;
	return new;
end;
$$;


ALTER FUNCTION public.t_act_alb() OWNER TO postgres;

--
-- Name: t_act_alb_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.t_act_alb_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	declare 
	x int :=old.nropista_can + 1;
	y int :=count(*) from canciones where id_alb=old.id_alb;
begin 
	---------
	y:=y+1;
	while (x <= y)
	loop
		update canciones set nropista_can=(x-1) where nropista_can=x and id_alb=old.id_alb;
		x:= x+1;
	end loop;
	---------
	update albumes set numpistas_alb=(y-1)  where id_alb=old.id_alb;
	return old;
end;
$$;


ALTER FUNCTION public.t_act_alb_delete() OWNER TO postgres;

--
-- Name: t_act_alb_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.t_act_alb_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin	
	update albumes set numpistas_alb= (select count(*) from canciones where id_alb=new.id_alb) where id_alb=new.id_alb;
	return new;
end $$;


ALTER FUNCTION public.t_act_alb_insert() OWNER TO postgres;

--
-- Name: t_val_alb(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.t_val_alb() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if length (new.id_art) = 0 then
		raise exception 'El id_art es un campo obligatorio';
	end if;
	if exists (select id_art from artistas where id_art=new.id_art) = false then
			raise exception 'El id_art no existe en la tabla artistas';
	end if;
	if length (new.nombre_alb) = 0 then
		raise exception 'El nombre_alb es un campo obligatorio';
	end if;	
	if length (new.genero_alb) = 0 then
		raise exception 'El genero es un campo obligatorio';
	end if;
	if new.precio_alb < 0 then
		raise exception 'El precio debe ser mayor a 0';
	end if;
	if not f_val_date(new.fecha_alb) then
		raise exception 'Escriba una fecha correcta';
	end if;	
	if new.fecha_alb > current_date then
			raise exception 'La fecha del album no debe superar la fecha actual';
	end if;
	-------------------------------------------------------
	
	if (TG_OP='INSERT') then
		if length (new.id_alb) > 0 then
			raise exception 'El id_alb lo asigna el sistema';
		end if;		
		if new.numpistas_alb > 0 or new.numpistas_alb < 0 then
			raise exception 'El numpistas lo asigna el sistema';
		end if;
		if (select exists (select 1 from albumes where id_art=new.id_art and nombre_alb=new.nombre_alb)) = true then
			raise exception 'El artista ya tiene un album con ese nombre, ponga otro nombre';
		end if;
		new.numpistas_alb:=0;
		new.id_alb:='alb-'||nextval('sec_alb');
	end if;
	
	-------------------------------------------------------
	
	if (TG_OP='UPDATE') then 
		if new.id_alb <> old.id_alb then
			raise exception 'El id_alb no se puede cambiar';
		end if;
		if new.id_art <> old.id_art then
			raise exception 'No se puede cambiar el id_art';
		end if;
		if new.nombre_alb <> old.nombre_alb then						
			if (select exists (select 1 from albumes where id_art=new.id_art and nombre_alb=new.nombre_alb)) = true then
				raise exception 'El artista ya tiene un album con ese nombre, ponga otro nombre';
			end if;
		end if;			
	end if;
return new;
end;
$$;


ALTER FUNCTION public.t_val_alb() OWNER TO postgres;

--
-- Name: t_val_art(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.t_val_art() RETURNS trigger
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
	
	---------------------------------------
	
	if (TG_OP='INSERT') then
		if length (new.id_art) > 0 then
			raise exception 'El id_art lo asigna el sistema';
		end if;
		if exists (select seudonimo_art from artistas where seudonimo_art=new.seudonimo_art) then
			raise exception 'El nombre de artista ya ha sido registrado';
		end if;
		if exists (select email_art from artistas where email_art=new.email_art) then
			raise exception 'El correo ya ha sido registrado, ingrese otro';
		end if;
		new.id_art:='art-'||nextval('sec_art');
	end if;
	
	------------------------------------------------------------
	
	if (TG_OP='UPDATE') then
		if new.id_art <> old.id_art then
			raise exception 'El id_art no se puede cambiar';
		end if;
		--if exists (select seudonimo_art from artistas where seudonimo_art=new.seudonimo_art) then
		--	raise exception 'El nombre de artista ya ha sido registrado';
		--end if;
		--if exists (select email_art from artistas where email_art=new.email_art) then
		--	raise exception 'El correo ya ha sido registrado, ingrese otro';
		--end if;
	end if;
	return new;
end;
$$;


ALTER FUNCTION public.t_val_art() OWNER TO postgres;

--
-- Name: t_val_can(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.t_val_can() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if length (new.nombre_can) = 0 then
		raise exception 'El nombre de la canción es obligatorio';
	end if;
	if not exists (select id_alb from albumes where id_alb=new.id_alb) then
		raise exception 'No existe el album con ese id';
	end if;
	------------------------------------------------------------
	if (TG_OP='INSERT') then 
		if length (new.id_can) > 0 then
			raise exception 'El id de las canciones lo pone el sistema';
		end if;
		if (select exists (select 1 from canciones where id_alb=new.id_alb and nombre_can=new.nombre_can)) = true then
			raise exception 'Ya existe una canción con ese nombre en el album';
		end if;
		if new.nropista_can <> old.nropista_can then
			raise exception 'El numero de pista se encarga el sistema';
		end if;		
		new.nropista_can:= 1 + count(*) from canciones where id_alb=new.id_alb;
		new.id_can:='can-'||nextval('sec_can');
	end if;
	-----------------------------------------------------------------
	if (TG_OP='UPDATE') then
		if new.id_can <> old.id_can then
			raise exception 'El id_can lo controla el sistema, no se puede borrar ni cambiar';
		end if;
		if new.id_alb <> old.id_alb then
			raise exception 'El id_alb lo controla el sistema, no se puede borrar ni cambiar';
		end if;
		if new.nombre_can <> old.nombre_can then
			if (select exists (select 1 from canciones where id_alb=new.id_alb and nombre_can=new.nombre_can)) = true then 
				raise exception 'Ya exise una cancion con ese nombre en el album';
			end if;
		end if;
	end if;	
	return new;
end;
$$;


ALTER FUNCTION public.t_val_can() OWNER TO postgres;

--
-- Name: t_val_pla(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.t_val_pla() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if length (new.nombre_pl) = 0 then
		raise exception 'El nombre del plan es obligatorio';
	end if;
	if length (new.descripcion_pl) = 0 then
		raise exception 'La descripción es un campo obligatio';
	end if;
	if new.duracion_pl < 0 then
		raise exception 'La duración del plan debe ser los números de dias que dura el plan (mayor a 0)';
	end if;
	if new.precio_pl < 0 then
		raise exception 'El precio debe ser mayor o igual a 0';
	end if;
	--------------------------------------------------------
	if (TG_OP='INSERT') then 
		if length (new.id_pl) > 0 then 
			raise exception 'El id_pl lo asigna el sistema';
		end if;		
		new.id_pl:='pl-'||nextval('sec_pla');
	end if;
	-------------------------------------------------------
	if (TG_OP='UPDATE') then
		if new.id_pl <> old.id_pl then
			raise exception 'El id_pl no se puede cambiar';
		end if;		
	end if;
	return new;
end;
$$;


ALTER FUNCTION public.t_val_pla() OWNER TO postgres;

--
-- Name: t_val_sus(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.t_val_sus() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	--if exists (select id_art from suscripciones where id_art=new.id_art) then 
	--	raise exception 'el artista ya tiene una suscripcion';
	--end if;
	
	if not exists (select id_art from artistas where id_art=new.id_art) then
			raise exception 'El id del artista no existe en la tabla artistas';
	end if;
	if not exists (select id_pl from planes where id_pl=new.id_pl) then
			raise exception 'El id del plan no existe en la tabla planes';
	end if;
	
	if f_val_date(new.finico_sus) = false then 
		raise exception 'La fecha de inicio tiene un formato incorrecto dd-mes-año';
	end if;
		
	---------------------------------------------------------------------
	if (TG_OP='INSERT') then 
		if length (new.id_sus) > 0 then
			raise exception 'El id_sus lo asigna el sistema';
		end if;		
		if new.ffin_sus <> null then
			raise exception 'La fecha de final de suscripción lo calcula el sistema';
		end if;						
		new.ffin_sus:= date (new.finico_sus) + (select duracion_pl from planes where id_pl=new.id_pl);
		new.subtotal_sus:= (select precio_pl from planes where id_pl=new.id_pl);
		new.iva_sus:= new.subtotal_sus * 0.12;
		new.total_sus:= new.subtotal_sus + new.iva_sus;
		new.id_sus:='sus-'||nextval('sec_sus');
	end if;
	
	---------------------------------------------------------------------
	return new;
end;
$$;


ALTER FUNCTION public.t_val_sus() OWNER TO postgres;

--
-- Name: t_val_tar_art(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.t_val_tar_art() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if length (new.tipo_tar) = 0 then
		raise exception 'Escriba el tipo de tarjeta ';
	end if;
	if not f_val_date(new.fcaducidad) then
		raise exception 'Escriba una fecha correcta en formato correcto';
	end if;	
	if new.fcaducidad < current_date then
			raise exception 'La fecha de caducidad debe ser mayor a la fecha actual';
	end if;
	if f_val_num(new.numero_tar) = false then
		raise exception 'Escriba un número de tarjeta válido';
	end if;
	if length (new.numero_tar) <> 16  then 
		raise exception 'Escriba una tarjeta de 16 dígitos';
	end if;	
	--------------------------------------------------------------
	if (TG_OP='INSERT') then 		
		if not exists (select id_art from artistas where id_art=new.id_art) then
			raise exception 'No existe un artista con ese id_art';
		end if;		
		if exists (select numero_tar from tarjetas_artistas where numero_tar=new.numero_tar) then
			raise exception 'Ya existe una tarjeta con ese número';
		end if;
		new.id_tar:='tar-art-'||nextval('sec_tar_art');
	end if;
	-------------------------------------------------
	if (TG_OP='UPDATE') then 
		if new.id_tar <> old.id_tar then
			raise exception 'El id_tar no se puede cambiar';
		end if;
		if new.id_art <> old.id_art then
			raise exception 'El id_art no se puede cambiar';
		end if;			
		--if exists (select numero_tar from tarjetas_artistas where numero_tar=new.numero_tar) then
		--	raise exception 'Ya existe una tarjeta con ese número';
		--end if;
	end if;
	return new;
end;
$$;


ALTER FUNCTION public.t_val_tar_art() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: albumes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.albumes (
    id_alb character varying(10) NOT NULL,
    id_art character varying(10),
    nombre_alb character varying(50) NOT NULL,
    numpistas_alb smallint,
    genero_alb character varying(50) NOT NULL,
    precio_alb double precision NOT NULL,
    fecha_alb date
);


ALTER TABLE public.albumes OWNER TO postgres;

--
-- Name: artistas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.artistas (
    id_art character varying(10) NOT NULL,
    seudonimo_art character varying(50) NOT NULL,
    email_art character varying(50) NOT NULL,
    contrasena_art character varying(50) NOT NULL,
    pais_art character varying(20) NOT NULL
);


ALTER TABLE public.artistas OWNER TO postgres;

--
-- Name: canciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.canciones (
    id_can character varying(10) NOT NULL,
    id_alb character varying(10),
    nombre_can character varying(50) NOT NULL,
    duracion_can time without time zone NOT NULL,
    nropista_can smallint NOT NULL
);


ALTER TABLE public.canciones OWNER TO postgres;

--
-- Name: detalles_facturas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.detalles_facturas (
    codigo_fac character varying(10),
    id_alb character varying(10),
    cantidad_fac smallint NOT NULL,
    descripcion_fac text NOT NULL
);


ALTER TABLE public.detalles_facturas OWNER TO postgres;

--
-- Name: facturas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.facturas (
    codigo_fac character varying(10) NOT NULL,
    id_usu character varying(10),
    fechaemision_fac date NOT NULL,
    subtotal_fac double precision NOT NULL,
    iva_fac double precision NOT NULL,
    total_fac double precision NOT NULL
);


ALTER TABLE public.facturas OWNER TO postgres;

--
-- Name: planes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.planes (
    id_pl character varying(10) NOT NULL,
    nombre_pl character varying(50) NOT NULL,
    descripcion_pl text NOT NULL,
    precio_pl double precision NOT NULL,
    duracion_pl integer
);


ALTER TABLE public.planes OWNER TO postgres;

--
-- Name: sec_alb; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sec_alb
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sec_alb OWNER TO postgres;

--
-- Name: sec_alb; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sec_alb OWNED BY public.albumes.id_alb;


--
-- Name: sec_art; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sec_art
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sec_art OWNER TO postgres;

--
-- Name: sec_art; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sec_art OWNED BY public.artistas.id_art;


--
-- Name: sec_can; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sec_can
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sec_can OWNER TO postgres;

--
-- Name: sec_can; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sec_can OWNED BY public.canciones.id_can;


--
-- Name: sec_pla; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sec_pla
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sec_pla OWNER TO postgres;

--
-- Name: sec_pla; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sec_pla OWNED BY public.planes.id_pl;


--
-- Name: suscripciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suscripciones (
    id_sus character varying(10) NOT NULL,
    id_art character varying(10),
    id_pl character varying(10),
    finico_sus date NOT NULL,
    ffin_sus date NOT NULL,
    subtotal_sus double precision NOT NULL,
    iva_sus double precision NOT NULL,
    total_sus double precision NOT NULL
);


ALTER TABLE public.suscripciones OWNER TO postgres;

--
-- Name: sec_sus; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sec_sus
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sec_sus OWNER TO postgres;

--
-- Name: sec_sus; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sec_sus OWNED BY public.suscripciones.id_sus;


--
-- Name: tarjetas_artistas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tarjetas_artistas (
    id_tar character varying(10) NOT NULL,
    id_art character varying(10),
    tipo_tar character varying(20) NOT NULL,
    numero_tar character varying(50) NOT NULL,
    fcaducidad date NOT NULL
);


ALTER TABLE public.tarjetas_artistas OWNER TO postgres;

--
-- Name: sec_tar_art; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sec_tar_art
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sec_tar_art OWNER TO postgres;

--
-- Name: sec_tar_art; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sec_tar_art OWNED BY public.tarjetas_artistas.id_tar;


--
-- Name: session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session (
    sid character varying NOT NULL,
    sess json NOT NULL,
    expire timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.session OWNER TO postgres;

--
-- Name: tarjetas_usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tarjetas_usuarios (
    id_tar character varying(10) NOT NULL,
    id_usu character varying(10),
    tipo_tar character varying(20) NOT NULL,
    numero_tar character varying(50) NOT NULL,
    fcaducidad_tar date NOT NULL
);


ALTER TABLE public.tarjetas_usuarios OWNER TO postgres;

--
-- Name: usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuarios (
    id_usu character varying(10) NOT NULL,
    nombre_usu character varying(50) NOT NULL,
    apellido_usu character varying(50) NOT NULL,
    email_usu character varying(50) NOT NULL,
    contrasena_usu character varying(50) NOT NULL,
    fnacimiento_usu date NOT NULL,
    genero_usu character varying(15) NOT NULL
);


ALTER TABLE public.usuarios OWNER TO postgres;

--
-- Data for Name: albumes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.albumes (id_alb, id_art, nombre_alb, numpistas_alb, genero_alb, precio_alb, fecha_alb) FROM stdin;
alb-6	art-5	ALONE	3	RAP & HIP HOP	80	2019-09-12
alb-4	art-5	LOBO NEGRO I	6	RAP & HIP HOP	74.99	2019-05-12
alb-5	art-5	LOBO NEGRO II	4	RAP & HIP HOP	80	2019-09-12
alb-3	art-3	FIESTA III	2	ALTERNATIVO	50	2022-01-16
alb-2	art-3	FIESTA II	4	ALTERNATIVO	50	2021-01-23
alb-1	art-3	FIESTA I	3	ALTERNATIVO	49.99	2002-01-23
alb-7	art-3	MIX III	2	CHICHA	12	2022-01-05
alb-8	art-7	Nucleos Activos Imaginarios	11	Alternative	10.5	2013-01-05
alb-9	art-7	Epicentro en Vivo	2	Indie	1.4	2015-01-14
alb-12	art-12	Nuevo Amanecer	2	Folk	3.5	2022-01-06
\.


--
-- Data for Name: artistas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.artistas (id_art, seudonimo_art, email_art, contrasena_art, pais_art) FROM stdin;
art-1	EMINEM	eminem@music.com	contraseña	ESTADOS UNIDOS
art-2	POMME	chanson@music.fr	contraseña1	FRANCIA
art-3	DROOW	akaa@droow.es	contraseña2	CHILE
art-4	CRISTINA AGUILAR	operacion@musical.mex	contraseña2	MEXICO
art-5	AMBKOR	lobonegro@music.com	contraseña8	ESPAÑA
art-6	COEUR DE PIRATE	rock@star.es	contraseña	CANADA
art-8	Da pawn 	dapawn@mail.com	sapawn1234	Ecuador
art-9	Tripulacion de osos	latri@mail.com	latri12345	Ecuador
art-10	Alkaloides	alkaloides@mail.com	lakaloides	Ecuador
art-7	Mundos	mundos@mail.com	mundos1234	Ecuador
art-11	Chayane	chayane@gmail.com	chayane1234	Puerto Rico
art-12	Gerardo Moran	gerardo@mail.com	gerardo1234	Ecuador
\.


--
-- Data for Name: canciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.canciones (id_can, id_alb, nombre_can, duracion_can, nropista_can) FROM stdin;
can-1	alb-6	Temblando	00:04:20	1
can-2	alb-6	Verte otra vez	00:02:30	2
can-3	alb-6	Viento	00:03:00	3
can-5	alb-5	Por Dentro	00:05:23	2
can-4	alb-5	Mi suerte	00:06:00	1
can-7	alb-5	Si nos cruzamos	00:04:01	3
can-8	alb-4	Lobo Negro	00:03:33	1
can-9	alb-4	Difícil feat Beret	00:03:56	2
can-10	alb-4	Llévame	00:03:56	3
can-11	alb-4	Bébeme	00:05:01	4
can-12	alb-4	Buenas Noches	00:06:00	5
can-13	alb-4	Vuelve feat Dante	00:04:15	6
can-14	alb-5	Llévame contigo	00:04:15	4
can-15	alb-3	Party	00:04:20	1
can-16	alb-3	Not party	00:04:20	2
can-17	alb-2	I	00:01:00	1
can-18	alb-2	LOVE	00:01:00	2
can-19	alb-2	YOU	00:02:00	3
can-20	alb-2	BABY	00:03:00	4
can-21	alb-1	YO	00:03:00	1
can-22	alb-1	TE	00:02:00	2
can-23	alb-1	AMO	00:01:00	3
can-24	alb-7	Sanjuanjito mix 1	01:04:00	1
can-29	alb-8	Oruga	00:03:50	2
can-30	alb-8	Artemia	00:02:55	3
can-31	alb-8	Luciernagas	00:04:30	4
can-42	alb-7	Bailables	00:03:06	2
can-28	alb-8	Atomos	00:03:10	1
can-33	alb-8	Mantis	00:05:30	5
can-34	alb-8	Mantarraya	00:03:31	6
can-35	alb-8	Metrikas	00:04:50	7
can-36	alb-8	Sombras	00:05:42	8
can-37	alb-8	Cuervos	00:05:05	9
can-38	alb-8	Nocturna	00:04:22	10
can-39	alb-8	Gorriones	00:06:02	11
can-46	alb-9	Natural	00:03:54	1
can-50	alb-9	Tiempos de pandemia	00:05:03	2
can-51	alb-12	Tu sonrisa	00:06:02	1
can-52	alb-12	Destello de luz	00:03:00	2
\.


--
-- Data for Name: detalles_facturas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.detalles_facturas (codigo_fac, id_alb, cantidad_fac, descripcion_fac) FROM stdin;
\.


--
-- Data for Name: facturas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.facturas (codigo_fac, id_usu, fechaemision_fac, subtotal_fac, iva_fac, total_fac) FROM stdin;
\.


--
-- Data for Name: planes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.planes (id_pl, nombre_pl, descripcion_pl, precio_pl, duracion_pl) FROM stdin;
pl-1	Plan Básico	Plan de 1 mes en la página	19.99	31
pl-2	Plan Normal	Plan de 3 mes en la página	29.99	61
pl-3	Plan Gold	Plan de 6 mes en la página	49.99	180
pl-4	Plan Platino	Plan de 1 año en la página	74.99	365
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session (sid, sess, expire) FROM stdin;
9UzVjX4iMCMAWEE-kMGATXvtDxlXeGAS	{"cookie":{"originalMaxAge":null,"expires":null,"httpOnly":true,"path":"/"},"flash":{}}	2022-01-26 06:17:17
GFquiuXYom-N7WXaH-NWouEoTYzV4-MM	{"cookie":{"originalMaxAge":null,"expires":null,"httpOnly":true,"path":"/"},"flash":{"success":["BienvenidoMundos","BienvenidoMundos","BienvenidoMundos"]},"passport":{"user":"art-12"}}	2022-01-26 15:33:55
\.


--
-- Data for Name: suscripciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.suscripciones (id_sus, id_art, id_pl, finico_sus, ffin_sus, subtotal_sus, iva_sus, total_sus) FROM stdin;
sus-1	art-3	pl-4	2022-01-17	2023-01-17	74.99	8.9988	83.9888
sus-2	art-5	pl-1	2022-01-17	2022-02-17	19.99	2.3987999999999996	22.388799999999996
sus-3	art-6	pl-3	2022-01-17	2022-07-16	49.99	5.9988	55.988800000000005
sus-4	art-1	pl-2	2022-01-17	2022-03-19	29.99	3.5987999999999998	33.5888
sus-5	art-7	pl-1	2020-01-05	2020-02-05	19.99	2.3987999999999996	22.388799999999996
sus-6	art-7	pl-2	2020-03-05	2020-05-05	29.99	3.5987999999999998	33.5888
sus-7	art-7	pl-3	2020-06-06	2020-12-03	49.99	5.9988	55.988800000000005
sus-9	art-7	pl-1	2022-01-21	2022-02-21	19.99	2.3987999999999996	22.388799999999996
sus-10	art-8	pl-1	2022-01-23	2022-02-23	19.99	2.3987999999999996	22.388799999999996
sus-11	art-4	pl-2	2022-01-23	2022-03-25	29.99	3.5987999999999998	33.5888
sus-12	art-2	pl-4	2022-01-23	2023-01-23	74.99	8.9988	83.9888
sus-13	art-10	pl-1	2022-01-23	2022-02-23	19.99	2.3987999999999996	22.388799999999996
sus-14	art-11	pl-4	2022-01-24	2023-01-24	74.99	8.9988	83.9888
sus-15	art-12	pl-3	2022-01-25	2022-07-24	49.99	5.9988	55.988800000000005
\.


--
-- Data for Name: tarjetas_artistas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tarjetas_artistas (id_tar, id_art, tipo_tar, numero_tar, fcaducidad) FROM stdin;
tar-art-1	art-3	Tarjeta de debito	0000111122223333	2022-06-23
tar-art-2	art-3	Tarjeta de crédito	0000111122224444	2022-06-23
tar-art-3	art-2	Tarjeta de debito	1000111122223333	2022-06-23
tar-art-4	art-1	Tarjeta de crédito	1000111122224444	2022-06-23
tar-art-5	art-2	Tarjeta de debito	1010111122223333	2022-05-23
tar-art-6	art-1	Tarjeta de crédito	1010111122224444	2022-08-23
tar-art-7	art-4	Tarjeta de debito	1010111022223333	2022-10-13
tar-art-8	art-5	Tarjeta de crédito	1010113122224444	2022-08-03
tar-art-9	art-5	Tarjeta de debito	1010111022221333	2022-10-13
tar-art-10	art-4	Tarjeta de crédito	1010113122214444	2022-08-03
tar-art-11	art-6	Tarjeta de crédito	1010113126214444	2022-08-03
tar-art-12	art-7	Tarjeta de debito	1010111876221333	2023-10-10
tar-art-15	art-8	Tarjeta de debito	1234567891035496	2023-01-01
tar-art-14	art-7	Tarjeta de crédito	1010991876243333	2024-02-02
tar-art-13	art-7	Tarjeta de debito	1010991876221333	2024-04-10
tar-art-17	art-8	Tarjeta de crédito	9876543215987456	2022-05-03
tar-art-19	art-10	Tarjeta de debito	7418529637894561	2022-09-11
tar-art-21	art-11	Tarjeta de debito	5555577777999996	2022-12-28
tar-art-22	art-11	Tarjeta de debito	8888855555999996	2025-01-16
tar-art-23	art-7	Tarjeta de debito	1234567897415961	2023-06-16
tar-art-24	art-12	Tarjeta de crédito	9999997777666548	2023-07-25
\.


--
-- Data for Name: tarjetas_usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tarjetas_usuarios (id_tar, id_usu, tipo_tar, numero_tar, fcaducidad_tar) FROM stdin;
\.


--
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuarios (id_usu, nombre_usu, apellido_usu, email_usu, contrasena_usu, fnacimiento_usu, genero_usu) FROM stdin;
usu-1	Maite	Perugachi	maite@mail.com	hola	2007-08-24	Mujer
usu-2	Luis	Perugachi	luis@mail.com	luisf	2002-01-05	Hombre
\.


--
-- Name: sec_alb; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sec_alb', 12, true);


--
-- Name: sec_art; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sec_art', 12, true);


--
-- Name: sec_can; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sec_can', 52, true);


--
-- Name: sec_pla; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sec_pla', 4, true);


--
-- Name: sec_sus; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sec_sus', 15, true);


--
-- Name: sec_tar_art; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sec_tar_art', 24, true);


--
-- Name: albumes pk_albumes; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.albumes
    ADD CONSTRAINT pk_albumes PRIMARY KEY (id_alb);


--
-- Name: artistas pk_artistas; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.artistas
    ADD CONSTRAINT pk_artistas PRIMARY KEY (id_art);


--
-- Name: canciones pk_canciones; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canciones
    ADD CONSTRAINT pk_canciones PRIMARY KEY (id_can);


--
-- Name: facturas pk_facturas; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facturas
    ADD CONSTRAINT pk_facturas PRIMARY KEY (codigo_fac);


--
-- Name: planes pk_planes; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.planes
    ADD CONSTRAINT pk_planes PRIMARY KEY (id_pl);


--
-- Name: suscripciones pk_suscripciones; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suscripciones
    ADD CONSTRAINT pk_suscripciones PRIMARY KEY (id_sus);


--
-- Name: tarjetas_artistas pk_tarjetas_artistas; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tarjetas_artistas
    ADD CONSTRAINT pk_tarjetas_artistas PRIMARY KEY (id_tar);


--
-- Name: tarjetas_usuarios pk_tarjetas_usuarios; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tarjetas_usuarios
    ADD CONSTRAINT pk_tarjetas_usuarios PRIMARY KEY (id_tar);


--
-- Name: usuarios pk_usuarios; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT pk_usuarios PRIMARY KEY (id_usu);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (sid);


--
-- Name: IDX_session_expire; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_session_expire" ON public.session USING btree (expire);


--
-- Name: albumes_canciones_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX albumes_canciones_fk ON public.canciones USING btree (id_alb);


--
-- Name: albumes_detallesfacturas_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX albumes_detallesfacturas_fk ON public.detalles_facturas USING btree (id_alb);


--
-- Name: albumes_pk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX albumes_pk ON public.albumes USING btree (id_alb);


--
-- Name: artistas_albumes_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX artistas_albumes_fk ON public.albumes USING btree (id_art);


--
-- Name: artistas_pk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX artistas_pk ON public.artistas USING btree (id_art);


--
-- Name: artistas_suscripciones_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX artistas_suscripciones_fk ON public.suscripciones USING btree (id_art);


--
-- Name: artistas_tarjetasartistas_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX artistas_tarjetasartistas_fk ON public.tarjetas_artistas USING btree (id_art);


--
-- Name: canciones_pk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX canciones_pk ON public.canciones USING btree (id_can);


--
-- Name: facturas_detallesfacturas_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facturas_detallesfacturas_fk ON public.detalles_facturas USING btree (codigo_fac);


--
-- Name: facturas_pk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX facturas_pk ON public.facturas USING btree (codigo_fac);


--
-- Name: planes_pk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX planes_pk ON public.planes USING btree (id_pl);


--
-- Name: planes_suscripciones_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX planes_suscripciones_fk ON public.suscripciones USING btree (id_pl);


--
-- Name: suscripciones_pk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX suscripciones_pk ON public.suscripciones USING btree (id_sus);


--
-- Name: tarjetas_artistas_pk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX tarjetas_artistas_pk ON public.tarjetas_artistas USING btree (id_tar);


--
-- Name: tarjetas_usuarios_pk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX tarjetas_usuarios_pk ON public.tarjetas_usuarios USING btree (id_tar);


--
-- Name: usuarios_facturas_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX usuarios_facturas_fk ON public.facturas USING btree (id_usu);


--
-- Name: usuarios_pk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX usuarios_pk ON public.usuarios USING btree (id_usu);


--
-- Name: usuarios_tarjetasusuarios_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX usuarios_tarjetasusuarios_fk ON public.tarjetas_usuarios USING btree (id_usu);


--
-- Name: canciones t_act_alb; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_act_alb AFTER DELETE ON public.canciones FOR EACH ROW EXECUTE FUNCTION public.t_act_alb();


--
-- Name: canciones t_act_alb_delete; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_act_alb_delete AFTER DELETE ON public.canciones FOR EACH ROW EXECUTE FUNCTION public.t_act_alb_delete();


--
-- Name: canciones t_act_alb_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_act_alb_insert AFTER INSERT ON public.canciones FOR EACH ROW EXECUTE FUNCTION public.t_act_alb_insert();


--
-- Name: albumes t_val_alb; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_val_alb BEFORE INSERT OR UPDATE ON public.albumes FOR EACH ROW EXECUTE FUNCTION public.t_val_alb();


--
-- Name: artistas t_val_art; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_val_art BEFORE INSERT OR UPDATE ON public.artistas FOR EACH ROW EXECUTE FUNCTION public.t_val_art();


--
-- Name: canciones t_val_can; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_val_can BEFORE INSERT OR UPDATE ON public.canciones FOR EACH ROW EXECUTE FUNCTION public.t_val_can();


--
-- Name: planes t_val_pla; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_val_pla BEFORE INSERT OR UPDATE ON public.planes FOR EACH ROW EXECUTE FUNCTION public.t_val_pla();


--
-- Name: suscripciones t_val_sus; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_val_sus BEFORE INSERT OR UPDATE ON public.suscripciones FOR EACH ROW EXECUTE FUNCTION public.t_val_sus();


--
-- Name: tarjetas_artistas t_val_tar_art; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_val_tar_art BEFORE INSERT OR UPDATE ON public.tarjetas_artistas FOR EACH ROW EXECUTE FUNCTION public.t_val_tar_art();


--
-- Name: albumes fk_albumes_artistas__artistas; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.albumes
    ADD CONSTRAINT fk_albumes_artistas__artistas FOREIGN KEY (id_art) REFERENCES public.artistas(id_art) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: canciones fk_cancione_albumes_c_albumes; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canciones
    ADD CONSTRAINT fk_cancione_albumes_c_albumes FOREIGN KEY (id_alb) REFERENCES public.albumes(id_alb) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: detalles_facturas fk_detalles_albumes_d_albumes; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalles_facturas
    ADD CONSTRAINT fk_detalles_albumes_d_albumes FOREIGN KEY (id_alb) REFERENCES public.albumes(id_alb) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: detalles_facturas fk_detalles_facturas__facturas; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalles_facturas
    ADD CONSTRAINT fk_detalles_facturas__facturas FOREIGN KEY (codigo_fac) REFERENCES public.facturas(codigo_fac) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facturas fk_facturas_usuarios__usuarios; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facturas
    ADD CONSTRAINT fk_facturas_usuarios__usuarios FOREIGN KEY (id_usu) REFERENCES public.usuarios(id_usu) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: suscripciones fk_suscripc_artistas__artistas; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suscripciones
    ADD CONSTRAINT fk_suscripc_artistas__artistas FOREIGN KEY (id_art) REFERENCES public.artistas(id_art) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: suscripciones fk_suscripc_planes_su_planes; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suscripciones
    ADD CONSTRAINT fk_suscripc_planes_su_planes FOREIGN KEY (id_pl) REFERENCES public.planes(id_pl) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tarjetas_artistas fk_tarjetas_artistas__artistas; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tarjetas_artistas
    ADD CONSTRAINT fk_tarjetas_artistas__artistas FOREIGN KEY (id_art) REFERENCES public.artistas(id_art) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tarjetas_usuarios fk_tarjetas_usuarios__usuarios; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tarjetas_usuarios
    ADD CONSTRAINT fk_tarjetas_usuarios__usuarios FOREIGN KEY (id_usu) REFERENCES public.usuarios(id_usu) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

