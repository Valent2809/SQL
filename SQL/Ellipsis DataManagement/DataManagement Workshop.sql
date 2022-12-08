# Return Title and Job level of all jobs who have job levels lower than 5
select distinct title,joblevel from job where joblevel < 5;

#Return Name of departments which started after the year 2017
select name from department where extract(year from startdate)>2017;
#OR
select name from department where year(startdate)>2017;

#Return name and DeptID of departments which are named either “Procurement” or “Deployment”
select name,deptid from department where name = 'Procurement' or name = 'Deployment';
#OR
select name,deptid from department where name in ('Procurement','Deployment');

#Return the Presenters and no. of events they presented from year 2015 onwards.
select presenter,count(*) as NoOfEvents from speech where extract(year from eventdate)>2015 group by presenter;
#Answer: we do distinct because in the case in one event, the presenter can appear 2 times in different time, we dont double count this
select presenter,count(Distinct eventdate,eventname) as NoOfEvents from speech 
where extract(year from eventdate)>2015 group by presenter;

#Return DeptID, NoOfChildDept of parent departments with DeptID < 89000.
select parentdept,count(*) as NoOfChildDept from department group by parentdept having parentdept < 89000;
select parentdept,count(*) as NoOfChildDept from department where parentdept < 89000 group by parentdept;

#Return the StaffID, StaffName, NoOfSkills of the top 5 non-political staffs with the most skills. (Hint: WHERE, LIMIT)
select s.staffid,s.staffname,count(skill) as NoOfSkills from staff s,np_staff n,np_staff_skills np 
where s.staffType = 'NP' and s.staffid = n.staffid and n.staffid = np.staffid
 group by np.staffid,s.staffname order by NoOfSkills desc limit 5;
 
 #Answer: as long as got 2 common attribute can connect them
 select s.staffid,s.staffname,count(skill) as NoOfSkills from staff s,np_staff_skills np 
 where s.staffid = np.staffid and staffType = 'NP' group by np.staffid,s.staffname order by NoOfSkills desc limit 5;
 
#Return DeptID and Names of all departments that started on “2017-05-22”
select deptid,name from department where startdate = '2017-05-22';

#Return all JobID and Title under the department name “PRIME MINISTER'S OFFICE”
select jobid,title from department d,job j where d.deptid = j.deptid and name = "PRIME MINISTER'S OFFICE";
#or
select jobid,title from job where deptid in (select deptid from department where name = "PRIME MINISTER'S OFFICE");

#Return StaffID and number of non-political assignments assigned to “ONG Chun Kiat” and “TAN Lay Kuean”
select np.staffid,count(*) from staff s,np_assignment np 
where np.staffid = s.staffid and staffname in ("ONG Chun Kiat","Tan Lay Kuean") group by staffid; 
#or
#ANSWER
select staffid,count(*) from np_assignment group by staffid having staffid in 
(select staffid from staff where staffname in ('ONG Chun Kiat','Tan Lay Kuean'));

#Find StaffID of political staff who did not give any speeches.
select staffid from p_staff where staffid not in (select presenter from speech);


#Find events that have more than average number of speeches
#step 1 : get the average number of speeches
select avg(num) from (select eventname,eventdate,count(*) as num from speech group by eventname,eventdate) as temp;

#step 2: get the events with speech > avg
select eventname,eventdate,count(*) as num from speech
group by eventname,eventdate having num >(select avg(num) from
(select eventname,eventdate,count(*) as num from speech group by eventname,eventdate) as temp );


#List names of staff that have lower number of skills than average number of skills among staffs
#step 1: find the number of skills among the people
select count(skill) as NoOfSkills from np_staff_skills group by staffid;

#step 2: get the average number
select avg(NoOfSkills) as averageSkill from (select count(skill) as NoOfSkills from np_staff_skills group by staffid) as temp;
 
 #step 3: find staff that have less skills than this
 select staffname from staff s,np_staff_skills np where np.staffid = s.staffid
 group by staffname having count(skill) < (select avg(NoOfSkills) as averageSkill from
 (select count(skill) as NoOfSkills from np_staff_skills group by staffid) as temp);

#List names of staff that have lower number of skills than average number of skills in all jobs
#step 1: find the noOfSkills in all jobs
select jobid,count(*) as count from np_job_skills group by jobid;

#step 2: get the average out
(select avg(count) from (select jobid,count(*) as count from np_job_skills group by jobid) as t1);

#step 3: get staffname whose skill < than this amount
select staffname from staff where staffid in (select staffid from np_staff_skills group by staffid having count(*) < 
(select avg(count) from (select jobid,count(*) as count from np_job_skills group by jobid) as t1));


#Create a stored procedure SearchDepartmentName that takes in a search term 
#and returns the list of departments names containing the search term.
#Then invoke the procedure by searching for ‘Minister’.
DELIMITER $$
CREATE PROCEDURE SearchDepartmentName(IN searchTerm char(90))
BEGIN
select name from department where name like concat ('%',searchTerm,'%');
END $$
DELIMITER ;


call SearchDepartmentName('Minister');
drop procedure SearchDepartmentName;

#Create a trigger so that there will not be 2 events at the same Location on the same event Date
delimiter $$
create trigger before_insert_event before insert on t_event for each row
begin
declare count_event int;
set count_event = (select count(*) from t_event where eventdate = new.eventdate and location = new.location);
if count_event = 1
then signal sqlstate '45000' set message_text = 'Trigger error: Insertion Fail,event clash with another event';
end if;
end $$
delimiter ;

drop trigger before_insert_event;

#declare count_event int;
#set count_event = (select count(*) from t_event where eventdate = new.eventdate and location = new.location);
#if count_event = 1 then signal sqlstate...

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SearchDepartmentName`(IN searchTerm char(90))
BEGIN
select name from department where name like '%searchTerm%';
END$$
DELIMITER ;
