#1. Add a new column SPEAIRCRAFT (Type: INT) to the EMPLOYEE table which is
#a foreign key referring to AIRCRAFT’S AID. Then insert data as follows.

alter table employee add Speaircraft int;
update employee set Speaircraft = 1 where eid = 1;
update employee set Speaircraft = 3 where eid = 2;
update employee set Speaircraft = 4 where eid = 3;
update employee set Speaircraft = 3 where eid = 4;

#2. Find the EID of those employees who are certified to fly Aircraft with AID equal 1
#or CERTDATE falling in the year of 2003

select e.eid from employee e,certified c where e.eid=c.eid and (aid = 1 or
extract(year from certdate) = 2003);

#3. Print out the names of all the destinations in FLIGHT table according to the
#descending order of the names.

select fly_to from flight order by fly_to desc;

#4. Print the EID of those employees with salary between 70000 and 100000(inclusive)

select eid from employee where salary >= 70000 and salary <= 100000;

#5. Display the largest CRUISINGRANGE and the smallest CRUISINGRANGE of all the aircrafts.

select min(cruisingrange),max(cruisingrange) from aircraft;

#6 Find the names and salaries of all the employees. If the employee is a pilot, print
#the names of all the aircrafts that he/she is certified to drive. (Note: an employee
#who is certified to drive at least one aircraft is considered as a pilot).

select e.ename,salary,aname from employee e left outer join certified c on e.eid = c.eid left outer join 
aircraft a on c.aid = a.aid;

#7. For each pair of (FLY_FROM, FLY_TO) in FLIGHT table, find the price of the
#cheapest flight between them.

select fly_from,fly_to,min(price) from flight group by fly_from,fly_to; 

#8. Print the name and salary of every employee who is not a pilot and has salary
#higher than the average salary of those pilots who are certified to fly aircrafts with
#cruisingrange longer than 1000 (Note: an employee who is certified to drive at
#least one aircraft is considered as a pilot)

#find the eid of those who is not a pilot
select eid from employee where eid not in (select distinct eid from certified);

#find the average salary of pilots who are cerfied to fly aircraft with cruiserrange >1000
select avg(salary) from employee where eid in
 (select eid from certified c,aircraft a where c.aid = a.aid and cruisingrange > 1000);
 
 #answer
 select ename,salary from employee where eid in 
 (select eid from employee where eid not in (select distinct eid from certified)) and
 salary > (select avg(salary) from employee where eid in
 (select eid from certified c,aircraft a where c.aid = a.aid and cruisingrange > 1000));
 
 
#9. For each pilot who is certified to drive at least two aircrafts, print the EID, ENAME
#and the minimum CRUISINGRANGE of the aircrafts for which she/ he is certified.

select c.eid,ename,min(cruisingrange) from employee e,certified c,aircraft a where e.eid = c.eid 
and a.aid = c.aid group by c.eid having count(*) >= 2;

#10.Find the pilots who are certified to drive any aircraft with its name containing
#character ‘b’ (e.g., a2b). For each of these pilots, list his/her name, the names of
#the aircrafts with their name containing ‘b’, and the corresponding certified date. 

select ename,a.aid,certdate from employee e,certified c,aircraft a where e.eid = c.eid
and c.aid = a.aid and aname like '%b%';

#11.Find the names of employees with salary less than the price of the cheapest
#route from LA to SF.

#find the cheapest flight price
select min(price) from flight where fly_from = 'LA' and fly_to= 'SF';

#answer:
select ename from employee where salary < 
(select min(price) from flight where fly_from = 'LA' and fly_to= 'SF');

#12.Find the names of aircrafts that are certified by Jacob ONLY.
#find the aircraft name certified by jacob
select aname from employee e,certified c,aircraft a where ename = 'Jacob' and e.eid = c.eid
 and a.aid=c.aid;
 
 #find the aircraft name not certified by jacob
 select distinct aname from employee e,certified c,aircraft a where ename <> 'Jacob' and e.eid = c.eid
 and a.aid=c.aid;
 
 #answer:
 select aname from aircraft where aname in (select aname from employee e,certified c,aircraft a where ename = 'Jacob' and e.eid = c.eid
 and a.aid=c.aid) 
 and aname not in (select distinct aname from employee e,certified c,aircraft a where ename <> 'Jacob' and e.eid = c.eid
 and a.aid=c.aid);
 
 #13.Find the names of aircrafts such that ALL pilots certified to operate them have
#salaries between $60000 and $85000

#find the eid of those with salary in the range
select eid from employee where eid in (select distinct eid from certified)
 and salary >= 60000 and salary <= 85000;
 
 #Answer
 select aname from aircraft where aid in 
 (select aid from certified where eid in (select eid from employee where eid in 
 (select distinct eid from certified)
 and salary >= 60000 and salary <= 85000));
 
#14.Print the names and salary of employee who has salary>70000 and are certified
#ONLY on aircrafts with cruising range longer than the distance of the flight with
#FLNO = 3

#finding eid of those where aircrafts with cruising range longer than the distance of the flight with flno 3
#find the aircraft with cruising range > distance of flno3
select aid from aircraft where cruisingrange > (select distance from flight where flno = 3 );

#find the aid of other aircraft with cruising range <dist of lfno 3 that other pilots take
select distinct c.aid from aircraft a,certified c where a.aid = c.aid and cruisingrange < (select distance from flight where flno = 3 );

select  eid from certified where aid in 
(select aid from aircraft where cruisingrange > (select distance from flight where flno = 3 ))
 and aid not in 
 (select distinct c.aid from aircraft a,certified c where a.aid = c.aid and cruisingrange < (select distance from flight where flno = 3 ));
 
 #15.Print the ENAMES of pilots who can operate planes with CRUISINGRANGE
#greater than 1000 miles but are not certified on any aircraft with name containing
#‘b’ (e.g., a2b)
#finding eid of those with aid with cruising range >1000
select eid from certified where aid in (select aid from aircraft where cruisingrange > 1000);

#finding eid of those that have aircraft name containing 'b'
select eid from certified c,aircraft a where c.aid = a.aid and aname like '%b%';

#answer:
select ename from employee where eid in (select eid from certified where aid in (select aid from aircraft where cruisingrange > 1000))
 and eid not in (select eid from certified c,aircraft a where c.aid = a.aid and aname like '%b%');
 
#16.Find the year that issues most certificates (assumption: each record in
#CERTIFIED table corresponds to a certificate). 
#find the max number of aid given out
select max(number) as MostCert from (select extract(year from certdate) as year,count(*) as number from certified group by year) as temp;

#find the year that have the most cert 
select extract(year from certdate) as year from certified group by year having count(*) 
= (select max(number) from 
(select extract(year from certdate) as year,count(*) as number from certified group by year) as temp);

#17.For each flight in FLIGHT table, find the name of the pilot who can fly that flight
#with lowest salary. Note: a pilot can fly the flight only when the pilot is certified to
#operate some aircraft with CRUISINGRANGE >= the distance of the flight. 

select flno,aid from flight f,aircraft a where a.cruisingrange >= f.distance order by flno;
select e.eid, ename, a.aid,salary from aircraft a, employee e, certified c where a.aid = c.aid and e.eid = c.eid ;

#for each aid find the min salary


#18.Given a flight, the aircraft that has its CRUSINGRANGE >= distance of the flight
#and having the smallest (CRUISINGRANGE - the distance of the flight) is
#considered to be the most economical choice. For each flight in the FLIGHT
#table, find the most economical aircraft, together with number of pilots who can fly
#that aircraft. The output is in the form of (FLNO, AID, NUMBER). 


#find the number of pilot for each flight
select aid,count(*) as noPilots from certified group by aid;

#find the most economical aircraft



#19.Write a trigger to increase the salary of the pilot by $200 for each new
#certification he receives which is for aircrafts with cruising range of 1200 and
#above.

select * from certified;
select * from employee;

DELIMITER $$
CREATE TRIGGER salary_increase after
insert ON certified FOR EACH ROW
BEGIN
declare tempCruisingrange int;
set tempCruisingrange = (select cruisingrange from aircraft where new.aid = aid);

if (tempCruisingrange >= 1200)
then update employee set salary = salary + 200 where new.eid = eid;
end if;

END $$
DELIMITER ;
drop trigger salary_increase;
insert into certified values (2,5,'2005-01-01');
select * from employee;

#20.Write a stored procedure named 'sp_AircraftPilots' that takes in Aircraft AID as
#the input and displays the EID and ENAME of the lowest salaried pilots who are
#certified to fly the given aircraft. Note: there could be more than one pilot with the
#same lowest salary amount that can fly the aircraft. In addition, return the total
#number of pilots with the out variable ‘total’.

DELIMITER $$
CREATE PROCEDURE sp_AircraftPilots (IN aircraftID int,OUT total int)
 BEGIN
declare lowestSalary int;
set lowestSalary = (select min(salary) from employee e,certified c where e.eid=c.eid and c.aid = aircraftID);
set total = (select count(c.eid) from certified c,employee e where c.eid = e.eid and c.aid = aircraftID and salary
 = lowestSalary);
 select e.eid,ename from employee e,certified c where e.eid=c.eid and c.aid=aircraftID and salary = lowestSalary;

 END $$
DELIMITER ;

select min(salary) from employee e,certified c where e.eid=c.eid and c.aid = 3;
select count(c.eid) from certified c,employee e where c.eid = e.eid and c.aid = 3 and salary
 = (select min(salary) from employee e,certified c where e.eid=c.eid and c.aid = 3);

call sp_AircraftPilots(5, @total);
select @total;


