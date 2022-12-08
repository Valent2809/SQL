alter table employee add column speaircraft int;

alter table employee add constraint foreign_key foreign key(speaircraft) references aircraft(aid);

select * from employee;
alter table employee drop column spearircraft;

update employee set speaircraft = 1 where ename = 'Jacob';
update employee set speaircraft = 3 where ename = 'Michael';
update employee set speaircraft = 4 where ename = 'Emily';
update employee set speaircraft = 3 where ename = 'Ashley';

select * from employee;

select * from certified;
#Question 2
select eid from certified where aid = 1 or extract(year from certdate) = 2003;

#Question 3
select * from flight order by name desc;
select * from flight;
select * from aircraft;
#part 3
select distinct fly_to from flight order by fly_to desc;

#question 4
describe employee;
select eid from employee where salary >= 70000 and salary <= 100000;

#question 5
describe aircraft;
select min(cruisingrange) ,max(cruisingrange) from aircraft;

#question 6
describe employee;
describe certified;
select * from certified;
select e.ename, salary, aname from employee e left outer join certified c on c.eid = e.eid left outer join aircraft a on a.aid = c.aid;

#question 7
select * from flight;
select fly_from, fly_to, min(price) from flight group by fly_from, fly_to;

#question 8
describe employee;
select * from employee;

select salary from employee where eid not in (select eid from employee e, aircraft a where e.speaircraft = a.aid) and salary > (
select avg(salary) from (
select eid , ename, salary from employee where speaircraft in (select aid from aircraft where cruisingrange > 1000))tmp);

select salary from employee where eid not in (select eid from employee e, aircraft a where e.speaircraft = a.aid);

select ename, salary from employee where eid not in 
(select distinct eid from certified) and salary >
(select avg(salary) from employee where eid in (select c.eid 
 from certified c, aircraft a
 where a.aid = c.aid and cruisingrange >1000));
 
 select * from employee;
 
#question 9 
select e.eid, ename, min(cruisingrange) 
from employee e, certified c, aircraft a 
where e.eid = c.eid and c.aid = a.aid group by e.eid, ename having count(*) >= 2;



select * , count(*) from certified group by eid;
select * from aircraft;
describe employee;

#question 10
select ename, aname, certdate from employee e, aircraft a, certified c where e.eid = c.eid and a.aid = c.aid and aname in (
select aname from aircraft where aname like '%b%');

#question 11. 
select ename from employee where salary < (
select min(price) from flight where fly_from = 'LA' and fly_to = 'SF');

#question 12
select aname from aircraft where aid in (
select aid from certified where eid in (select eid from employee where ename = 'Jacob'))
and aid in (
select aid from certified group by aid having count(distinct eid) = 1);

#question 13
#find whose salary is not between that range
select aname from aircraft where aid not in (
select aid from certified where eid in 
(select eid from employee where salary < 60000 or salary > 85000))
and aid not in 
(select aid from aircraft where aid not in 
(select distinct a.aid from aircraft a, certified c where c.aid = a.aid));

#question 14
select ename, salary from employee where salary > 70000;

select aid from aircraft where cruisingrange > (select distance from flight where flno = 3);

select ename, salary from employee e, certified c where e.eid = c.eid and aid in ;
select c.eid from certified c where aid in ;
(select aid from aircraft where cruisingrange > (select distance from flight where flno = 3) and aid not in (select aid from aircraft where aid not in 
(select distinct a.aid from aircraft a, certified c where c.aid = a.aid)));

select * from certified;

#question 15
describe aircraft;
select ename from employee e, aircraft a, certified c 
where e.eid = c.eid and a.aid = c.aid and cruisingrange > 1000 
and e.eid not in (select distinct e.eid from employee e, certified c, aircraft a where e.eid = c.eid and a.aid = c.aid and aname like '%b%');

select aid from aircraft where aname like '%b%';

select distinct e.eid from employee e, certified c, aircraft a where e.eid = c.eid and a.aid = c.aid and aname not like '%b%';

#question 16. 
select extract(year from certdate) as Year, count(*) as count from certified group by Year having count(*) = (
select max(count) from (
select extract(year from certdate) as Year, count(*) as count from certified group by Year)tmp);

#question 17
select * from flight left outer join ;
select * from aircraft;
select e.eid, ename, a.aid from aircraft a, employee e, certified c where a.aid = c.aid and e.eid = c.eid;

#question 19
select * from aircraft;
describe aircraft;
describe certified;
delimiter $$
create trigger after_certified_insert after insert on certified for each row
begin
	declare tempCruisingRange int;
    set tempCruisingRange = (select cruisingrange from aircraft where aid = new.aid);
    if tempCruisingRange >= 1200 then
		update employee set salary = salary + 200 where eid = new.eid;
	end if;
end $$
delimiter ;
select * from employee;
update employee set salary = salary + 200 where eid = 1;

select * from aircraft;
select * from employee;
insert into certified values(2,5,now());

describe aircraft;
describe employee;
delimiter $$
create procedure sp_AircraftPilots(in aircraftID int, out total int)
begin 
	declare lowestSalary int;
    set lowestSalary = (select min(salary) from employee e, certified c where e.eid = c.eid and c.aid = aircraftID);
	set total = (select count(c.eid) from employee e, certified c where e.eid = c.eid and c.aid = aircraftID and salary = lowestSalary);
    select e.eid, ename from employee e, certified c where e.eid = c.eid and c.aid = aircraftID and salary = lowestSalary;

end $$
delimiter ;

select eid, ename from employee where salary = (
select min(salary) from aircraft a, certified c, employee e where e.eid = c.eid and a.aid = c.aid and a.aid = 1);
select count(*) from aircraft a, certified c, employee e where e.eid = c.eid and a.aid = c.aid and a.aid = 2;
drop procedure sp_aircraftPilots;
call sp_AircraftPilots(5, @total);
select @total;


