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
-- Name: albumes_comprados(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.albumes_comprados(idusu character varying) RETURNS TABLE(id_albumes character varying)
    LANGUAGE plpgsql
    AS $$
begin
return query
select d.id_alb from detalles_facturas as d
inner join facturas as f on d.codigo_fac=f.codigo_fac where id_usu=idusu;
end;
$$;


ALTER FUNCTION public.albumes_comprados(idusu character varying) OWNER TO postgres;

--
-- Name: completar_factura(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.completar_factura(idalb character varying, idusu character varying, idfac character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
cantidad smallint = count(*) from canciones where id_alb=idalb;
subtotal double precision = (select precio_alb from albumes where id_alb=idalb);
iva double precision = subtotal * (select valor_imp from impuestos where id_imp='imp-2');
total double precision = (subtotal + iva);
begin
insert into detalles_facturas values (idfac,idalb,cantidad,'Un albúm de '||cantidad||' canciones');
update facturas set subtotal_fac = subtotal,iva_fac = iva,total_fac = total where codigo_fac = idfac;
end;
$$;


ALTER FUNCTION public.completar_factura(idalb character varying, idusu character varying, idfac character varying) OWNER TO postgres;

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
-- Name: obtener_ultimoidfac(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.obtener_ultimoidfac(iduser character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare
id_fac varchar = (select codigo_fac from facturas where id_usu=idUser ORDER BY codigo_fac DESC LIMIT 1);
begin
return id_fac;
end;
$$;


ALTER FUNCTION public.obtener_ultimoidfac(iduser character varying) OWNER TO postgres;

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
-- Name: t_delete_generos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.t_delete_generos() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
if exists(select id_gen from albumes where id_gen=old.id_gen) then
raise exception 'No se puede eliminar este género porque existen albumes registrados con el género';
end if;
return old;
end;
$$;


ALTER FUNCTION public.t_delete_generos() OWNER TO postgres;

--
-- Name: t_delete_planes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.t_delete_planes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
if exists (select id_pl from suscripciones where id_pl=old.id_pl) then
raise exception 'No se puede borrar el plan porque hay artistas que ya compraron el plan';
end if;
return old;
end;
$$;


ALTER FUNCTION public.t_delete_planes() OWNER TO postgres;

--
-- Name: t_val_admin(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.t_val_admin() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (TG_OP='INSERT') then
		if length (new.id_adm) > 0 then
			raise exception 'El id_adm lo asigna el sistema';
		end if;
		if exists (select id_adm from administradores where id_adm=new.id_adm) then
			raise exception 'El correo ya fue registrado';
		end if;
		new.id_adm='admin-'||nextval('sec_admin');
	end if;
	---------------------------------------------
	if (TG_OP='UPDATE') then
		if new.id_adm <> old.id_adm then
			raise exception 'El id_adm lo controla el sistema';
		end if;
		if exists (select id_adm from administradores where id_adm=new.id_adm) then
			raise exception 'El correo ya fue registrado';
		end if;
	end if;
	return new;
end;
$$;


ALTER FUNCTION public.t_val_admin() OWNER TO postgres;

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
	if length (new.id_alb) = 0 then
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
-- Name: t_val_fac(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.t_val_fac() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (TG_OP='INSERT') then
		if length (new.codigo_fac) > 0 then
			raise exception 'El código de factura lo asigna el sistema';
		end if;
		if not exists (select id_usu from usuarios where id_usu=new.id_usu) then 
			raise exception 'El id_usu no existe en la tabla usuarios';
		end if;
		if new.fechaemision_fac <> current_date then
			raise exception 'La fecha de la factura debe ser la fecha actual';
		end if;
		if new.subtotal_fac < 0 then 
			raise exception 'El subtotal no debe ser menor a 0';
		end if;
		if new.iva_fac <> 0 then
			raise exception 'El iva lo controla el sistema';			
		end if;
		if new.total_fac <> 0 then
			raise exception 'El total lo controla el sistema';
		end if;
		new.fechaemision_fac:= current_date;
		new.codigo_fac:='fac-'||nextval('sec_fac');
	end if;
	------------------------------------------------------------
	if (TG_OP='UPDATE') then
		if new.codigo_fac <> old.codigo_fac then
			raise exception 'El codigo de factura no se puede modificar';
		end if;
		if new.id_usu <> old.id_usu then
			raise exception 'El id_usu no se puede modificiar';
		end if;
		if new.subtotal_fac <> old.subtotal_fac then
			if new.subtotal_fac < 0 then
				raise exception 'El valor no debe ser menor a 0';
			end if;
		end if;
	end if;
	
	return new;
end;
$$;


ALTER FUNCTION public.t_val_fac() OWNER TO postgres;

--
-- Name: t_val_gen(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.t_val_gen() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
--------------------------------
if (TG_OP='INSERT') then
if length(new.id_gen) > 0 then
raise exception 'El id_gen lo controla el sistema';
end if;
if length(new.nombre_gen) = 0 then
raise exception 'El nombre del género es un campo obligatorio';
end if;
if exists (select nombre_gen from generos where nombre_gen=new.nombre_gen) then
raise exception 'Ya existe un género con ese nombre';
end if;
new.nombre_gen:=upper(new.nombre_gen);
new.id_gen:='gen-'||nextval('sec_gen');
end if;
---------------------------
if (TG_OP='UPDATE') then
if new.id_gen <> old.id_gen then
raise exception 'El id_gen no se puede modificar';
end if;
if exists (select nombre_gen from generos where nombre_gen=new.nombre_gen) then
raise exception 'Ya existe un género con ese nombre';
end if;
new.nombre_gen:=upper(new.nombre_gen);
end if;
return new;
end;
$$;


ALTER FUNCTION public.t_val_gen() OWNER TO postgres;

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
		new.iva_sus:= new.subtotal_sus * (select valor_imp from impuestos where id_imp='imp-1');
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

--
-- Name: t_val_tar_usu(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.t_val_tar_usu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (TG_OP='INSERT') then 
		if length (new.id_tar)>0 then 
			raise exception 'no debe escribir un id de tarjeta, lo asigna el sistema'; 
		end if;	
		if not exists (select id_usu from usuarios where id_usu = new.id_usu ) then
			raise exception 'no existe el usuario en la tabla usuarios';
		end if;
		if length (new.tipo_tar)=0 then
			raise exception 'ingrese un tipo de tarjeta por favor';
		end if;
		if length (new.numero_tar)<> 16 then
			raise exception 'el número de tarjeta debe ser de 16 dígitos'; 	
		end if;
		if exists (select numero_tar from tarjetas_usuarios where numero_tar = new.numero_tar ) then
			raise exception 'El número de tarjeta ya fue registrado';
		end if;
		if new.fcaducidad_tar < current_date then
			raise exception 'ingrese una fecha de caducidad mayor a la fecha actual';
		end if;
		new.id_tar:='tar-'||nextval('sec_tar_usu');
	end if;
	---------------------------------------------------
	if (TG_OP='UPDATE') then
		if new.id_tar <> old.id_tar then
			raise exception 'no se puede modificar el id_tar';
		end if;
		if new.id_usu <> old.id_usu then
			raise exception 'no se puede modificar el id_usu';
		end if;
		if new.tipo_tar <> old.tipo_tar then
			if length (new.tipo_tar)=0 then
				raise exception 'ingrese un tipo de tarjeta por favor';
			end if;
		end if;
		if new.numero_tar <> old.numero_tar then
			if length (new.numero_tar)<> 16 then
				raise exception 'el número de tarjeta debe ser de 16 dígitos'; 	
			end if;
			if exists (select numero_tar from usuarios where numero_tar = new.numero_tar ) then
				raise exception 'El número de tarjeta ya fue registrado';
			end if;
		end if;
		if new.fcaducidad_tar <> old.fcaducidad_tar then
			if new.fcaducidad_tar < current_date then
				raise exception 'ingrese una fecha de caducidad mayor a la fecha actual';
			end if;
		end if;
	end if;
	return new;
end;
$$;


ALTER FUNCTION public.t_val_tar_usu() OWNER TO postgres;

--
-- Name: t_val_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.t_val_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	--------------------------------
		if (TG_OP='INSERT') then
		if length (new.id_usu) > 0 then
			raise exception 'El id_usu lo asigna el sistema';
		end if;
		if exists (select email_usu from usuarios where id_usu=new.id_usu) then
			raise exception 'El correo ya fue registrado';
		end if;
		if f_val_email(new.email_usu) = false then
		raise exception 'Escribir un correo válido';
		end if;
		new.id_usu='usu-'||nextval('sec_user');
	end if;
	---------------------------------------------
	if (TG_OP='UPDATE') then
		if new.id_usu <> old.id_usu then
			raise exception 'El id_usu lo controla el sistema';
		end if;
		if exists (select email_usu from usuarios where id_usu=new.id_usu) then
			raise exception 'El correo ya fue registrado';
		end if;
		if f_val_email(new.email_usu) = false then
		raise exception 'Escribir un correo válido';
		end if;
		
	end if;
	return new;
end;
$$;


ALTER FUNCTION public.t_val_user() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: personas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personas (
    nombres character varying(50),
    apellidos character varying(50),
    genero character varying(20),
    fecha_nacim date
);


ALTER TABLE public.personas OWNER TO postgres;

--
-- Name: administradores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.administradores (
    id_adm character varying(15) NOT NULL,
    email_usu character varying(50) NOT NULL,
    contrasena_usu character varying(50) NOT NULL
)
INHERITS (public.personas);


ALTER TABLE public.administradores OWNER TO postgres;

--
-- Name: albumes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.albumes (
    id_alb character varying(10) NOT NULL,
    id_art character varying(10),
    nombre_alb character varying(50) NOT NULL,
    numpistas_alb smallint,
    precio_alb double precision NOT NULL,
    fecha_alb date,
    id_gen character varying(10)
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
    fechaemision_fac date,
    subtotal_fac double precision,
    iva_fac double precision,
    total_fac double precision,
    tarjeta_fac character varying(16)
);


ALTER TABLE public.facturas OWNER TO postgres;

--
-- Name: generos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.generos (
    id_gen character varying(10) NOT NULL,
    nombre_gen character varying(50) NOT NULL
);


ALTER TABLE public.generos OWNER TO postgres;

--
-- Name: impuestos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.impuestos (
    id_imp character varying(10) NOT NULL,
    nombre_imp character varying(50) NOT NULL,
    valor_imp double precision NOT NULL
);


ALTER TABLE public.impuestos OWNER TO postgres;

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
-- Name: sec_admin; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sec_admin
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sec_admin OWNER TO postgres;

--
-- Name: sec_admin; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sec_admin OWNED BY public.administradores.id_adm;


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
-- Name: sec_fac; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sec_fac
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sec_fac OWNER TO postgres;

--
-- Name: sec_fac; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sec_fac OWNED BY public.facturas.codigo_fac;


--
-- Name: sec_gen; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sec_gen
    AS integer
    START WITH 9
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sec_gen OWNER TO postgres;

--
-- Name: sec_gen; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sec_gen OWNED BY public.generos.id_gen;


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
    total_sus double precision NOT NULL,
    tarjeta_fac character varying(16)
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
-- Name: sec_tar_usu; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sec_tar_usu
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sec_tar_usu OWNER TO postgres;

--
-- Name: sec_tar_usu; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sec_tar_usu OWNED BY public.tarjetas_usuarios.id_tar;


--
-- Name: usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuarios (
    id_usu character varying(10) NOT NULL,
    email_usu character varying(50) NOT NULL,
    contrasena_usu character varying(50) NOT NULL
)
INHERITS (public.personas);


ALTER TABLE public.usuarios OWNER TO postgres;

--
-- Name: sec_user; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sec_user
    AS integer
    START WITH 2
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sec_user OWNER TO postgres;

--
-- Name: sec_user; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sec_user OWNED BY public.usuarios.id_usu;


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
-- Data for Name: administradores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.administradores (nombres, apellidos, genero, fecha_nacim, id_adm, email_usu, contrasena_usu) FROM stdin;
Alberto	Rodrigez	Hombre	1998-09-25	admin-1	roalberto@mail.com	alberto1234
Alicia	de la Torre	Mujer	1998-04-05	admin-3	alicia@mail.com	hola
Alvaro	Martinez	Hombre	2002-02-25	admin-4	alvaro@mail.com	admin-alvaro
\.


--
-- Data for Name: albumes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.albumes (id_alb, id_art, nombre_alb, numpistas_alb, precio_alb, fecha_alb, id_gen) FROM stdin;
alb-29	art-17	Guardarraya	9	4.5	2000-04-02	gen-4
alb-30	art-17	La diabla	2	2.5	2018-05-06	gen-6
alb-31	art-7	Proyecto 2022	0	7.5	2022-02-04	gen-17
alb-18	art-7	Epicentro en Vivo	2	5.5	2022-01-15	gen-6
alb-19	art-13	Pistola de Balin	13	12.5	2018-02-09	gen-4
alb-20	art-15	Un futuro mejor	6	9.99	2020-06-06	gen-1
alb-21	art-15	Robormiga	10	9.99	2015-02-03	gen-1
alb-8	art-7	Nucleos Activos Imaginarios	12	10.5	2013-01-05	gen-4
alb-25	art-16	FIESTA	0	49.99	2002-01-23	gen-6
alb-26	art-16	FIESTA II	0	50	2021-01-23	gen-6
alb-27	art-16	FIESTA III	0	50	2022-01-16	gen-6
alb-28	art-16	LP	0	80	2019-09-12	gen-6
\.


--
-- Data for Name: artistas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.artistas (id_art, seudonimo_art, email_art, contrasena_art, pais_art) FROM stdin;
art-7	Mundos	mundos@mail.com	mundos1234	Ecuador
art-13	Da pawn	dapawn@mail.com	dapawn1234	Ecuador
art-14	Lil Pump	lil69@mail.com	lil123456789	EEUU
art-15	Tripulacion de Osos	latri@gmail.com	latri12345	Ecuador
art-16	Orquesta Joven	orquestajoven@mail.com	orquesta1234	Panama
art-17	Guardarraya	guardarraya@mail.com	gardarraya1234	Ecuador
\.


--
-- Data for Name: canciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.canciones (id_can, id_alb, nombre_can, duracion_can, nropista_can) FROM stdin;
can-53	alb-8	Nopal	00:03:15	12
can-69	alb-18	Natural	00:03:05	1
can-70	alb-18	KKK	00:02:53	2
can-71	alb-19	La ultima oportunidad	00:04:58	1
can-72	alb-19	Balsa	00:03:42	2
can-73	alb-19	Pistola de balin	00:04:46	3
can-74	alb-19	La muerte	00:05:50	4
can-75	alb-19	Tres	00:04:11	5
can-76	alb-19	Crimen	00:04:41	6
can-77	alb-19	Rutas para no volver	00:04:22	7
can-29	alb-8	Oruga	00:03:50	2
can-30	alb-8	Artemia	00:02:55	3
can-31	alb-8	Luciernagas	00:04:30	4
can-78	alb-19	Cometas	00:04:29	8
can-79	alb-19	Un momento	00:03:36	9
can-80	alb-19	Final violento	00:03:27	10
can-81	alb-19	Helio	00:04:11	11
can-82	alb-19	Gelatina	00:02:57	12
can-83	alb-19	Voces difusas	00:11:34	13
can-84	alb-20	Kilimanjaro	00:03:05	1
can-85	alb-20	Fin de mes	00:02:16	2
can-86	alb-20	Luana	00:03:30	3
can-87	alb-20	Tren de vidas pasadas	00:02:27	4
can-88	alb-20	Ariel	00:03:32	5
can-89	alb-20	Nada que hacer	00:03:14	6
can-90	alb-21	Robormiga	00:03:32	1
can-91	alb-21	Un espejo	00:02:42	2
can-92	alb-21	Fantasma	00:02:40	3
can-93	alb-21	Corriente aparente	00:03:32	4
can-94	alb-21	Cumpleaños	00:02:53	5
can-95	alb-21	11 Chinas Hacen Pirámide en una Bicicleta	00:02:53	6
can-96	alb-21	Cavernícolas Dando a Luz	00:02:46	7
can-97	alb-21	Consumidor Final	00:03:40	8
can-28	alb-8	Atomos	00:03:10	1
can-33	alb-8	Mantis	00:05:30	5
can-34	alb-8	Mantarraya	00:03:31	6
can-35	alb-8	Metrikas	00:04:50	7
can-36	alb-8	Sombras	00:05:42	8
can-37	alb-8	Cuervos	00:05:05	9
can-38	alb-8	Nocturna	00:04:22	10
can-39	alb-8	Gorriones	00:06:02	11
can-98	alb-21	Cavaletti	00:03:19	9
can-99	alb-21	El Piloto Comprometió la Integridad Física	00:05:20	10
can-100	alb-29	Muestra gratis	00:01:06	1
can-101	alb-29	Hombre Cuerdo	00:03:16	2
can-102	alb-29	Big Bang	00:04:06	3
can-103	alb-29	Sonriendo asustadito	00:00:49	4
can-104	alb-29	Háblame mas suave	00:04:24	5
can-105	alb-29	Los verdes	00:04:57	6
can-106	alb-29	Oil	00:03:30	7
can-107	alb-29	Peligro inflamable	00:03:19	8
can-108	alb-29	Pepe grillo	00:02:36	9
can-109	alb-30	La diabla	00:04:25	1
can-110	alb-30	Retorno	00:03:55	2
\.


--
-- Data for Name: detalles_facturas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.detalles_facturas (codigo_fac, id_alb, cantidad_fac, descripcion_fac) FROM stdin;
fac-28	alb-18	2	Un albúm de 2 canciones
fac-29	alb-8	12	Un albúm de 12 canciones
fac-30	alb-19	2	Un albúm de 2 canciones
fac-31	alb-20	6	Un albúm de 6 canciones
fac-32	alb-20	6	Un albúm de 6 canciones
fac-33	alb-21	10	Un albúm de 10 canciones
fac-34	alb-18	2	Un albúm de 2 canciones
fac-35	alb-8	12	Un albúm de 12 canciones
\.


--
-- Data for Name: facturas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.facturas (codigo_fac, id_usu, fechaemision_fac, subtotal_fac, iva_fac, total_fac, tarjeta_fac) FROM stdin;
fac-28	usu-1	2022-02-06	5.5	0.6599999999999999	6.16	1111133337779995
fac-29	usu-1	2022-02-06	10.5	1.26	11.76	5555559999878756
fac-30	usu-1	2022-02-07	2.5	0.3	2.8	1111133337779995
fac-31	usu-1	2022-02-07	9.99	1.1988	11.1888	7778884442223369
fac-32	usu-2	2022-02-07	9.99	1.1988	11.1888	8956237845129563
fac-33	usu-2	2022-02-07	9.99	1.1988	11.1888	8956237845129563
fac-34	usu-3	2022-02-09	5.5	0.6599999999999999	6.16	1111111111111111
fac-35	usu-3	2022-02-09	10.5	1.26	11.76	1111111111111111
\.


--
-- Data for Name: generos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.generos (id_gen, nombre_gen) FROM stdin;
gen-1	ROCK
gen-2	POP
gen-5	LATINO
gen-6	INDIE
gen-7	OPERA
gen-4	ALTERNATIVO
gen-10	REGGE
gen-11	REGGAE
gen-12	POP LATINO
gen-13	TRAP
gen-14	TRAP LATINO
gen-15	FOLK
gen-16	CHANSON
gen-17	FOLKLORE
gen-18	ROCK POP
gen-19	NEOCLÁSICA
gen-20	MINIMALISTA
gen-21	CRISTIANO
gen-22	ROCK CRISTIANO
gen-23	LATIN
gen-24	RAP
gen-25	RAP & HIP HOP
gen-26	HIP HOP
\.


--
-- Data for Name: impuestos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.impuestos (id_imp, nombre_imp, valor_imp) FROM stdin;
imp-1	iva artista	0.15
imp-2	iva usuarios	0.12
\.


--
-- Data for Name: personas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personas (nombres, apellidos, genero, fecha_nacim) FROM stdin;
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
4Yi_lFIoTCbJYirbmhv8y6VoitG5q96u	{"cookie":{"originalMaxAge":null,"expires":null,"httpOnly":true,"path":"/"},"flash":{"success":["Bienvenido Alberto","BienvenidoMundos","Bienvenido Alberto"]},"passport":{}}	2022-02-10 13:24:51
XPmNj51iKrovPFIGnHz4x0MWHPa0vZd_	{"cookie":{"originalMaxAge":null,"expires":null,"httpOnly":true,"path":"/"},"flash":{"success":["Bienvenido Alberto","BienvenidoMundos","Bienvenido Alberto","Bienvenido Alberto","BienvenidoMundos"],"error":["Missing credentials","Missing credentials"]},"passport":{"user":"art-16"}}	2022-02-10 03:10:49
\.


--
-- Data for Name: suscripciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.suscripciones (id_sus, id_art, id_pl, finico_sus, ffin_sus, subtotal_sus, iva_sus, total_sus, tarjeta_fac) FROM stdin;
sus-5	art-7	pl-1	2020-01-05	2020-02-05	19.99	2.3987999999999996	22.388799999999996	1010111876221333
sus-6	art-7	pl-2	2020-03-05	2020-05-05	29.99	3.5987999999999998	33.5888	1010991876243333
sus-7	art-7	pl-3	2020-06-06	2020-12-03	49.99	5.9988	55.988800000000005	1010991876243333
sus-9	art-7	pl-1	2022-01-21	2022-02-21	19.99	2.3987999999999996	22.388799999999996	1010111876221333
sus-16	art-13	pl-4	2022-01-26	2023-01-26	74.99	8.9988	83.9888	9876543218524561
sus-17	art-14	pl-4	2022-02-06	2023-02-06	74.99	11.248499999999998	86.23849999999999	1234567891354896
sus-18	art-15	pl-1	2022-02-06	2022-03-09	19.99	2.9984999999999995	22.9885	2233344558877695
sus-19	art-17	pl-1	2022-02-09	2022-03-12	19.99	2.9984999999999995	22.9885	5612314506004530
\.


--
-- Data for Name: tarjetas_artistas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tarjetas_artistas (id_tar, id_art, tipo_tar, numero_tar, fcaducidad) FROM stdin;
tar-art-12	art-7	Tarjeta de debito	1010111876221333	2023-10-10
tar-art-14	art-7	Tarjeta de crédito	1010991876243333	2024-02-02
tar-art-13	art-7	Tarjeta de debito	1010991876221333	2024-04-10
tar-art-23	art-7	Tarjeta de debito	1234567897415961	2023-06-16
tar-art-25	art-13	Tarjeta de crédito	1234567987894561	2022-03-25
tar-art-26	art-13	Tarjeta de debito	9876543218524561	2022-05-28
tar-art-27	art-14	Tarjeta de debito	1234567891354896	2027-06-09
tar-art-28	art-15	Tarjeta de crédito	4445558887776662	2026-10-06
tar-art-29	art-15	Tarjeta de debito	2233344558877695	2022-03-10
tar-art-30	art-17	Tarjeta de debito	4554896213559846	2026-08-12
tar-art-31	art-17	Tarjeta de debito	5612314506004530	2023-12-29
\.


--
-- Data for Name: tarjetas_usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tarjetas_usuarios (id_tar, id_usu, tipo_tar, numero_tar, fcaducidad_tar) FROM stdin;
tar-1	usu-1	Tarjeta de debito	1111133337779995	2022-02-12
tar-3	usu-1	Tarjeta de debito	5555559999878756	2028-01-05
tar-4	usu-1	Tarjeta de debito	7778884442223369	2024-10-23
tar-5	usu-2	Tarjeta de debito	8956237845129563	2025-09-23
tar-6	usu-3	Tarjeta de crédito	1111111111111111	2024-08-20
\.


--
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuarios (nombres, apellidos, genero, fecha_nacim, id_usu, email_usu, contrasena_usu) FROM stdin;
Luis	Perugachi	Hombre	2002-01-19	usu-1	luis@mail.com	luis1234
Maite	Perugachi	Mujer	1995-08-23	usu-2	maite@gmail.com	maite1234
Pepito	Cerezo	Hombre	1998-04-10	usu-3	pepito@gmail.com	peito12344
\.


--
-- Name: sec_admin; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sec_admin', 4, true);


--
-- Name: sec_alb; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sec_alb', 31, true);


--
-- Name: sec_art; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sec_art', 17, true);


--
-- Name: sec_can; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sec_can', 110, true);


--
-- Name: sec_fac; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sec_fac', 35, true);


--
-- Name: sec_gen; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sec_gen', 26, true);


--
-- Name: sec_pla; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sec_pla', 9, true);


--
-- Name: sec_sus; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sec_sus', 19, true);


--
-- Name: sec_tar_art; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sec_tar_art', 31, true);


--
-- Name: sec_tar_usu; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sec_tar_usu', 6, true);


--
-- Name: sec_user; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sec_user', 3, true);


--
-- Name: administradores pk_administradores; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.administradores
    ADD CONSTRAINT pk_administradores PRIMARY KEY (id_adm);


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
-- Name: generos pk_generos; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.generos
    ADD CONSTRAINT pk_generos PRIMARY KEY (id_gen);


--
-- Name: impuestos pk_impuestos; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.impuestos
    ADD CONSTRAINT pk_impuestos PRIMARY KEY (id_imp);


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
-- Name: generos_pk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX generos_pk ON public.generos USING btree (id_gen);


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
-- Name: generos t_delete_generos; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_delete_generos BEFORE DELETE ON public.generos FOR EACH ROW EXECUTE FUNCTION public.t_delete_generos();


--
-- Name: planes t_delete_planes; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_delete_planes BEFORE DELETE ON public.planes FOR EACH ROW EXECUTE FUNCTION public.t_delete_planes();


--
-- Name: administradores t_val_admin; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_val_admin BEFORE INSERT OR UPDATE ON public.administradores FOR EACH ROW EXECUTE FUNCTION public.t_val_admin();


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
-- Name: facturas t_val_fac; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_val_fac BEFORE INSERT OR UPDATE ON public.facturas FOR EACH ROW EXECUTE FUNCTION public.t_val_fac();


--
-- Name: generos t_val_gen; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_val_gen BEFORE INSERT OR UPDATE ON public.generos FOR EACH ROW EXECUTE FUNCTION public.t_val_gen();


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
-- Name: tarjetas_usuarios t_val_tar_usu; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_val_tar_usu BEFORE INSERT OR UPDATE ON public.tarjetas_usuarios FOR EACH ROW EXECUTE FUNCTION public.t_val_tar_usu();


--
-- Name: usuarios t_val_user; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_val_user BEFORE INSERT OR UPDATE ON public.usuarios FOR EACH ROW EXECUTE FUNCTION public.t_val_user();


--
-- Name: albumes fk_albumes_artistas__artistas; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.albumes
    ADD CONSTRAINT fk_albumes_artistas__artistas FOREIGN KEY (id_art) REFERENCES public.artistas(id_art) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: albumes fk_albumes_generos__generos; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.albumes
    ADD CONSTRAINT fk_albumes_generos__generos FOREIGN KEY (id_gen) REFERENCES public.generos(id_gen) ON UPDATE CASCADE ON DELETE CASCADE;


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

