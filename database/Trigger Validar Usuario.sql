---------TRIGUER GENEROS---------
--secuencia--
create sequence sec_user as int start with 2 increment by 1;
alter sequence sec_user owned by usuarios.id_usu;

--trigger--

create or replace function t_val_user()
returns trigger as
$$
begin
	--------------------------------
		if (TG_OP='INSERT') then
		if length (new.id_usu) > 0 then
			raise exception 'El id_usu lo asigna el sistema';
		end if;
		if exists (select email_usu from usuarios where id_usu=new.id_usu) then
			raise exception 'El correo ya fue registrado';
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
	end if;
	return new;
end;
$$
language plpgsql;

--apuntador--

create trigger t_val_user before insert or update on usuarios
	for each row execute procedure t_val_user();


--testing--

insert into generos (nombre_gen) values ('alternativo');
select * from generos;

update generos set nombre_gen='salSA' where id_gen='gen-4';
