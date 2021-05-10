drop table if exists disaster_affected_state cascade;
drop table if exists disaster cascade;
drop table if exists state cascade;
drop table if exists country cascade;

create table country (
  id serial primary key,
  name text not null
);
select create_reference_table('country');
insert into country ("name") values ('India');

create table state (
  id serial primary key,
  country_id integer references country(id),
  name text NOT NULL
);
select create_reference_table('state');
insert into state ("country_id", "name")
values (1, 'Karnataka'), (1, 'Andhra Pradesh'), (1, 'Orissa'), (1, 'Tamilnadu');

create table disaster (
  id serial,
  country_id integer references country(id),
  name text not null,
  primary key (id, country_id)
);
select create_distributed_table('disaster', 'country_id');
insert into disaster ("country_id", "name")
values (1, 'cyclone_amphan'),
       (1, 'cyclone_nisarga');

create table disaster_affected_state (
  id serial,
  country_id integer references country(id),
  disaster_id integer,
  state_id integer references state(id),
  primary key (id, country_id)
);
select create_distributed_table('disaster_affected_state', 'country_id');

alter table disaster_affected_state add constraint disaster_fkey foreign key (country_id, disaster_id) references disaster(country_id, id);

insert into disaster_affected_state ("country_id", "disaster_id", "state_id")
values (1, 1, 2), (1, 1, 3), (1, 2, 2), (1, 2, 3), (1, 2, 4);

create function search_disasters(search text)
returns setof disaster as $$
begin
    return query select *
    from disaster
    where
      name ilike ('%' || search || '%');
end;
$$ language plpgsql stable;
