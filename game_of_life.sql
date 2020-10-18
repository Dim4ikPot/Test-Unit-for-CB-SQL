-----------Начальные настройки задачи-----------
create table Life (x number, y number, gen number default 1);

insert all 
  into Life (x, y) values (-1, 0)
  into Life (x, y) values (0, 0)
  into Life (x, y) values (1, 0)
  into Life (x, y) values (1, 1)
  into Life (x, y) values (0, 2)
select * from dual;


-----------1.1-----------
insert into Life

  with lastGen as (
      select * from Life where gen = (select max(gen) from Life)
  )
    
  , neighbours as (
      select -1 x, -1 y from dual
      union all
      select -1 x, 0 y from dual
      union all
      select -1 x, 1 y from dual
      union all
      select 0 x, -1 y from dual
      union all
      select 0 x, 1 y from dual
      union all
      select 1 x, -1 y from dual
      union all
      select 1 x, 0 y from dual
      union all
      select 1 x, 1 y from dual
  )
    
  select 
      lg1.x
    , lg1.y
    , lg1.gen + 1 gen
  from lastGen lg1
  cross join neighbours n
  join lastGen lg2
    on lg2.x = lg1.x + n.x and lg2.y = lg1.y + n.y
  group by lg1.x, lg1.y, lg1.gen
  having count(*) = 3
      or count(*) = 2
        
  union all
    
  select 
      lg1.x + n.x x
    , lg1.y + n.y y
    , lg1.gen + 1 gen
  from lastGen lg1
  cross join neighbours n
  left join lastGen lg2 
    on lg2.x = lg1.x + n.x and lg2.y = lg1.y + n.y
  where lg2.x is null 
     or lg2.y is null
  group by lg1.x + n.x, lg1.y + n.y, lg1.gen
  having count(*) = 3;


-----------1.2-----------
alter table Life modify  x  not null;
alter table Life modify  y  not null;
alter table Life modify gen not null check (gen > 0);


-----------2.1-----------
insert into Life  
  with lastGen as (
      select * from Life where gen = (select max(gen) from Life)
  )
    
  , neighbours as (
      select -1 x, -1 y from dual
      union all
      select -1 x, 0 y from dual
      union all
      select -1 x, 1 y from dual
      union all
      select 0 x, -1 y from dual
      union all
      select 0 x, 1 y from dual
      union all
      select 1 x, -1 y from dual
      union all
      select 1 x, 0 y from dual
      union all
      select 1 x, 1 y from dual
  )
  
  , torBorders as (
      select 
          case mod(&TorY, 2)
            when 0 then &TorY / 2 - 1 + y
            else ceil(&TorY / 2) - 1 + y
          end max_y
        , case mod(&TorY, 2)
            when 0 then &TorY / 2 * (-1) + y
            else floor(&TorY / 2) * (-1) + y
          end min_y
        , case mod(&TorX, 2)
            when 0 then &TorX / 2 + x
            else floor(&TorX / 2) + x
          end max_x
        , case mod(&TorX, 2)
            when 0 then &TorX / 2 * (-1) + 1 + x
            else ceil(&TorX / 2) * (-1) + 1+ x
          end min_x
      from (
        select max(x) x, min(y) y from Life where gen = (select min(gen) from Life)
      )
  )
    
  select 
      lg1.x
    , lg1.y
    , lg1.gen + 1 gen
  from lastGen lg1
  cross join torBorders b
  cross join neighbours n
  join lastGen lg2 
      on lg2.x = case 
          when lg1.x + n.x < b.min_x then b.max_x
          when lg1.x + n.x > b.max_x then b.min_x
          else lg1.x + n.x
        end
      and lg2.y = case 
          when lg1.y + n.y < b.min_y then b.max_y
          when lg1.y + n.y > b.max_y then b.min_y
          else lg1.y + n.y
        end
  group by lg1.x, lg1.y, lg1.gen
  having count(*) = 3
      or count(*) = 2
      
  union all
   
  select res_x, res_y, gen
  from ( 
    select 
        case 
          when lg1.x + n.x < b.min_x then b.max_x
          when lg1.x + n.x > b.max_x then b.min_x
          else lg1.x + n.x
        end res_x
      , case 
          when lg1.y + n.y < b.min_y then b.max_y
          when lg1.y + n.y > b.max_y then b.min_y
          else lg1.y + n.y
        end res_y
      , lg1.gen + 1 gen
    from lastGen lg1
    cross join torBorders b
    cross join neighbours n
    left join lastGen lg2
        on lg2.x = case 
          when lg1.x + n.x < b.min_x then b.max_x
          when lg1.x + n.x > b.max_x then b.min_x
          else lg1.x + n.x
        end
      and lg2.y = case 
          when lg1.y + n.y < b.min_y then b.max_y
          when lg1.y + n.y > b.max_y then b.min_y
          else lg1.y + n.y
        end
    where lg2.x is null
       or lg2.y is null
  )
  group by res_x, res_y, gen
  having count(*) = 3;


