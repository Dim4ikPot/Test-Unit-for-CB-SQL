-------Таблица кухонного гарнитура------
create table kitchen_set (
    object_id    integer        not null
  , object_name  varchar2(1000) not null
  , description  varchar2(4000) null
  , parent_id    integer        null
  , install_date date           default trunc(sysdate)
  , constraint pk_kitchen_set primary key (object_id)
  , constraint fk_kitchen_set foreign key (parent_id) references kitchen_set(object_id) on delete set null
);

create sequence seq_kitchen_set_id
  start with  1
  increment by 1
  nocache
  nocycle;
  
create trigger kitchen_set_trg
  before INSERT on kitchen_set
  for each row
  begin
    :new.object_id := seq_kitchen_set_id.Nextval;
  end;
/

-------Справочник продуктов------
create table products_dict (
    product_type_id   integer        not null
  , product_name varchar2(500)  not null
  , description  varchar2(1000) null
  , constraint pk_products_dict primary key (product_type_id)
);

create sequence seq_products_dict_id
  start with  1
  increment by 1
  nocache
  nocycle;
  
create trigger products_dict_trg
  before INSERT on products_dict
  for each row
  begin
    :new.product_type_id := seq_products_dict_id.Nextval;
  end;
/

-------Таблица с имеющимися продуктами------
create table products_table (
    product_id      integer      not null
  , product_type_id integer      not null
  , buy_date        date         null
  , life_days       number       null
  , buy_source      varchar2(30) null
  , constraint pk_products_table primary key (product_id)
  , constraint fk_products_table foreign key (product_type_id) references products_dict(product_type_id) on delete cascade
);

create trigger products_table_trg
  before INSERT on products_table
  for each row
  declare
    v_cnt integer := 0;
  begin
    select count(*) into v_cnt
    from products_table
    where product_id = :new.product_id;
  
    if v_cnt = 0 then
      raise_application_error(-20001, 'Error: Product not found!');
    end if;
  end;
/

-------Расположение имеющихся продуктов------
create table products_history (
    product_id     number       not null
  , action_ident   varchar2(50) not null
  , object_id      number       not null
  , product_weight number  	null
  , action_date    date         default trunc(sysdate)
  , constraint fk_ph_prod_id foreign key (product_id) references products_table(product_id) on delete cascade
  , constraint fk_ph_obj_id  foreign key (object_id)  references kitchen_set(object_id)    on delete set null
);


-------Справочник рецептов------
create table recipes_dict (
    recipe_id   number          not null
  , recipe_title varchar2(1000) not null
  , description  varchar2(4000) null
  , constraint pk_recipes_table primary key (recipe_id)
);


-------Информация по ингридиентам рецептов------
create table recipes_composition (
    recipe_id       number not null
  , product_type_id number not null
  , product_weight  number null     
  , constraint pk_recipes_composition unique (recipe_id, product_type_id)
  , constraint fk_rc_ptid foreign key (product_type_id) references products_dict(product_type_id) on delete set null
);


-------Информация по стадиям рецептов------
create table recipes_workflow (
    recipe_id   number         not null
  , stage_from  number         null
  , stage_to    number         null     
  , composition varchar2(4000) null
  , constraint fk_recipes_workflow foreign key (recipe_id) references recipes_dict(recipe_id) on delete cascade
);

--===============================================--
/*drop table recipes_workflow;
drop table recipes_composition;
drop table recipes_dict;
drop table products_history;
drop table products_table;
drop sequence seq_products_dict_id;
drop table products_dict;
drop sequence seq_kitchen_set_id;
drop table kitchen_set;*/
