drop database if exists sailors;
create database sailors;
use sailors;

create table if not exists Sailors(
	sid int primary key,
	sname varchar(35) not null,
	rating float not null,
	age int not null
);

create table if not exists Boat(
	bid int primary key,
	bname varchar(35) not null,
	color varchar(25) not null
);

create table if not exists reserves(
	sid int not null,
	bid int not null,
	sdate date not null,
	foreign key (sid) references Sailors(sid) on delete cascade,
	foreign key (bid) references Boat(bid) on delete cascade
);

insert into Sailors values
(1,"Albert", 5.0, 40),
(2, "Nakul", 5.0, 49),
(3, "Darshan", 9, 18),
(4, "Astorm Gowda", 2, 68),
(5, "Armstormin", 7, 19);


insert into Boat values
(1,"Boat_1", "Green"),
(2,"Boat_2", "Red"),
(103,"Boat_3", "Blue");

insert into reserves values
(1,103,"2023-01-01"),
(1,2,"2023-02-01"),
(2,1,"2023-02-05"),
(3,2,"2023-03-06"),
(5,103,"2023-03-06"),
(1,1,"2023-03-06");

select * from Sailors;
select * from Boat;
select * from reserves;

-- 1. Find the colours of the boats reserved by Albert
select color 
from Sailors s, Boat b, reserves r 
where s.sid=r.sid and b.bid=r.bid and s.sname="Albert";

-- 2. Find all the sailor sids who have rating atleast 8 or reserved boat 103
(select sid
from Sailors
where Sailors.rating>=8)
UNION
(select sid
from reserves
where reserves.bid=103);


-- 3. Find the names of the sailor who have not reserved a boat whose name contains the
-- string "storm". Order the name in the ascending order
select s.sname
from Sailors s
where s.sid not in 
(select s1.sid 
from Sailors s1, reserves r1 
where r1.sid=s1.sid and s1.sname like "%storm%")
and s.sname like "%storm%"
order by s.sname ASC;

-- 4. Find the name of the sailors who have reserved all boats
select sname from Sailors s where not exists
	(select * from Boat b where not exists
		(select * from reserves r where r.sid=s.sid and b.bid=r.bid));


-- 5. Find the name and age of the oldest sailor
select sname, age
from Sailors 
where age in (select max(age) from Sailors);

-- 6. For each boat which was reserved by atleast 2 sailors with age >= 40, find the bid and 
--average age of such sailors
select b.bid, avg(s.age) as average_age
from Sailors s, Boat b, reserves r
where r.sid=s.sid and r.bid=b.bid and s.age>=40
group by bid
having 2<=count(distinct r.sid);

-- 7. Create a view that shows the names and colours of all the boats that have been reserved by a sailor with a specific rating.
create view ReservedBoatsWithRatedSailor as
select distinct bname, color
from Sailors s, Boat b, reserves r
where s.sid=r.sid and b.bid=r.bid and s.rating=5;
select * from ReservedBoatsWithRatedSailor;


-- 8. Trigger that prevents boats from being deleted if they have active reservation
DELIMITER //
create or replace trigger CheckAndDelete
before delete on Boat
for each row
BEGIN
	IF EXISTS (select * from reserves where reserves.bid=old.bid) THEN
		SIGNAL SQLSTATE '45000' SET message_text='Boat is reserved and hence cannot be deleted';
	END IF;
END;//

DELIMITER ;
delete from Boat where bid=103; -- This gives error since boat 103 is reserved