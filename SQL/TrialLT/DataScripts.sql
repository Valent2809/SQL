Create table aircraft (
Aid int not null,
AName varchar(20) not null,
CruisingRange int not null,
constraint aircraft_pk1 primary key (AID));

create table employee(
eid int not null,
ename varchar(20) not null,
salary int not null,
constraint employee_pk1 primary key (eid));

create table certified(
eid int not null,
aid int not null,
certdate date not null,
constraint certified_pk1 primary key (eid,aid),
constraint certified_fk1 foreign key (aid) references aircraft(aid),
constraint certified_fk2 foreign key (eid) references employee(eid));

create table flight(
flno int not null,
fly_from varchar(20) not null,
fly_to varchar(20) not null,
distance int not null,
price int not null,
constraint flight_pk1 primary key (flno));


insert into aircraft values(1,'a1',800),(2,'a2b',700),
(3,'a3',1000),(4,'a4b',1100),(5,'a5',1200);

insert into employee values(1,'Jacob',85000),(2,'Micheal',55000),
(3,'Emily',80000),(4,'Ashley',110000),(5,'Daniel',70000),(6,'Olivia',70000);

insert into flight values(1,'LA','SF',600,65000),(2,'LA','SF',700,70000),
(3,'LA','SF',800,90000),(4,'LA','NY',1000,85000),(5,'NY','LA',1100,95000);

insert into certified values(1,1,'2005-01-01'),(1,2,'2001-01-01'),
(1,3,'2000-01-01'),(1,5,'2000-01-01'),(2,3,'2002-01-01'),(2,2,'2003-01-01'),
(3,3,'2003-01-01'),(3,5,'2004-01-01');



