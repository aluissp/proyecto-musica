---------TRIGUER GENEROS---------
--secuencia--
create sequence sec_gen as int start with 1 increment by 1;
alter sequence sec_gen owned by generos.id_gen;

--trigger--

create or replace function t_val_gen()
returns trigger as
$$
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
$$
language plpgsql

--apuntador--

create trigger t_val_gen before insert or update on generos
	for each row execute procedure t_val_gen();
	

--testing--

insert into generos (nombre_gen) values ('alternativo');
select * from generos;

update generos set nombre_gen='salSA' where id_gen='gen-4';
