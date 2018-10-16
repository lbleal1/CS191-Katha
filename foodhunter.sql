--no mechanism for reporting inappropriate pictures of feedback
create table FoodEstablishment
  (
    fe_ID varchar(4),
    type varchar(9), --cafeteria or kiosk or cafe
    name varchar(20), -- FE name
    fe_avg_rating numeric(2,0), -- on a scale of 1-10, default 0
    total_views numeric(6,0) default null, --max
    weekly_views numeric(6,0) default null, --wouldn't this be limiting to 999 999
    location varchar (60),
    open_hours varchar(15),
    open_days varchar(20),
    contact_number varchar(11) default null, --optional
    contact_person varchar(50) default null, --optional
    -- ATTRIBUTES ONWARDS ARE FOR CAFETERIA ONLY
    seating_capacity numeric(3,0) default null,
    free_water varchar(3) default null,
    additional_cost_for_takeOut varchar(5) default null,
    bring_your_own_baon_incentive varchar(5) default null,
    clean_as_you_go varchar(3) default null,
    description varchar(250) default null,
    --baka pwedeng mag add ng minimum price for ulam and max price (price range), a little complicated pa so wag muna
    primary key (fe_ID)
  );

create table Consumables -- not weak entity to food establishment because of the isOffering relationship
  (
    c_ID varchar(5),
    c_name varchar(20),
    type varchar(20), -- food or beverage or combo (for kiosk)
    primary key (c_ID)
  );

create table BrandedConsumables -- (all branded consumables will start with a 1, has no rating since theyre all the same anyway)
  (
    bc_ID varchar(5),
    bc_name varchar(20),
    bc_type varchar(20), --food or beverage
    primary key (bc_ID)
  );


create table ComboMeal -- for Kiosk
  (
    fe_ID varchar(4),
    cm_name varchar (20),
    c_ID_1 varchar(5),
    c_qty_1 varchar(20),
    c_ID_2 varchar(5),
    c_qty_2 varchar(20),
    cm_price numeric (2,0),
    cm_avg_rating numeric(2,0),
    primary key (fe_ID,combo_name),
    foreign key (fe_ID) references FoodEstablishment
        on delete cascade
  );

create table UPStudent -- might still have additional attribs
  (
    upmail varchar (30),
    primary key (upmail)
  );

create table consumable_rating_and_upload_picture
  (
    upmail varchar(30),
    c_ID varchar(5),
    c_rating numeric(2,0),
    blob_column default null,       -- FOR IMAGE; default set to null
    primary key (upmail, c_ID),
    foreign key (upmail) references UPStudent
          on delete cascade,
    foreign key (c_ID) references Consumables
          on delete cascade
  );


create table food_establishment_rating_and_feedback
  (
    upmail varchar(30),
    foodestablishment_ID varchar(4),
    fe_rating numeric(2,0),
    feedback varchar (500) default null,
    primary key (upmail,foodestablishment_ID),
    foreign key (upmail) references UPStudent
          on delete cascade, --will have to update avd rating of food establishment if student gets deleted
    foreign key (foodestablishment_ID) references FoodEstablishment
          on delete cascade   --if food establishment gets deleted so does everything else with it
  );

create table combomeal_rating_and_upload_picture (
    upmail varchar(30),
    foodestablishment_ID varchar (4),
    cm_name varchar (20),
    cm_rating numeric (2,0)
    blob column default null,
    primary key (upmail,foodestablishment_ID,cm_name),
    foreign key (upmail) references UPStudent
          on delete cascade,
    foreign key (foodestablishment_ID) references FoodEstablishment
          on delete cascade,
    foreign key (cm_name) references ComboMeal
          on delete cascade

);
create table isOfferingConsumable
  (
    c_ID varchar(5),
    foodestablishment_ID varchar(4),
    c_avg_rating numeric (2,0) default 0,
    price numeric(3,0),
    primary key (c_ID,foodestablishment_ID),
    foreign key (c_ID) references Consumables
          on delete cascade,
    foreign key (foodestablishment_ID) references FoodEstablishment
          on delete cascade
  );

create table isOfferingBrandedConsumable -- difference from Consumable? No rating
  (
    bc_ID varchar(5),
    foodestablishment_ID varchar(4),
    price numeric(3,0),
    primary key (bc_ID,foodestablishment_ID),
    foreign key (bc_ID) references BrandedConsumables
          on delete cascade,
    foreign key (foodestablishment_ID) references FoodEstablishment
          on delete cascade
  );

------------------------------------------------------------------------------------TRIGGERS----------------------------------------------------------------------------------------------
--note: Cascaded foreign key actions do not activate triggers.
--TRIGGERS
--AverageRatingFoodEstablishment and/or Consumables Rating should be changed when:
--              1. someone changes their rating of a food establishment
--              2. the user who gave the rating is deleted
--
--
--UNTESTED TRIGGERS
create trigger updatedFoodEstablishmentRating -- UNTESTED
  after update on fe_rating
  begin
    update fe_avg_rating
      set fe_avg_rating = sum(select fe_rating from food_establishment_rating_and_feedback as ferf where ferf.foodestablishment_ID = foodestablishment_ID)/count(select fe_rating from food_establishment_rating_and_feedback as ferf where ferf.foodestablishment_ID = foodestablishment_ID)
    end;
  end;

create trigger updatedConsumableRating --UNTESTED
  after update on c_rating
  begin
    update c_avg_rating
      set c_avg_rating = sum(select c_rating from isOffering where isOffering.c_ID = c_ID)/count(select c_rating from isOffering where isOffering.c_ID=c_ID)
    end;
  end;


create trigger deletedUser -- deletes all feedback and ratings it gave --UNTESTED
  before delete on upmail
  begin
    --deleting all ratings and pictures it gave to a consumable
    delete
      from consumable_rating_and_upload_picture
      where upmail = consumable_rating_and_upload_picture.upmail
    --deleting all ratings and feedback it gave to a food establishment
    delete
      from food_establishment_rating_and_feedback
      where upmail = food_establishment_rating_and_feedback.upmail
  end;

-- update triggers to acct for combo meal

  -- to do:
  -- test TRIGGERS
