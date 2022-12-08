alter table REGISTRATION add final_mark decimal(5,2);
select * from registration;

insert into COURSE values ('ISM 5555', 'Course 5');
insert into COURSE values ('ISM 6666', 'Course 6');

#a. Write a stored procedure sp_get_SCfinalmarks( IN studsid int, IN regcid char(8), OUT finalmarks
#decimal(5,2) ) to obtain the final mark for a given student sid and a given course cid that he has
#registered. Eg: Final Mark for SID 38214 of CID ISM 4212 is 74.80 (64*0.3 + 79*0.4 + 80*0.3).


DELIMITER $$
CREATE PROCEDURE sp_get_SCfinalmarks( IN studsid int, IN regcid char(8), OUT finalmarks decimal(5,2) )
 BEGIN

set finalmarks = (select sum(weight * mark) from assessment a,performance p where sid = studsid
and cid = regcid and p.aid = a.aid);

 END $$
DELIMITER ;

CALL sp_get_SCfinalmarks(38214, 'ISM 4212', @final); 
SELECT @final; 

#b. Write a stored procedure sp_populate_finalmarks() to populate the final mark column for all records in
#table REGISTRATION using stored procedure sp_get_SCfinalmarks. (Hint: Use clause limit offset). 

delimiter $$
CREATE PROCEDURE sp_populate_finalmarks()
BEGIN

	declare totalcount int;
    declare counter int;
    declare tmpsid int;
    declare tmpcid char(8);
    declare tmpmarks decimal(5,2);
    set counter = 0;
    select count(*) into totalcount from registration;
    
    while (counter < totalcount) do
		-- note order by is used to fix the order of the retrieved records		
        -- offset clause is to specify from which row to start retrieving 
        -- limit 1 is used to limit selection of 1 record
		select sid, cid into tmpsid, tmpcid from registration order by sid, cid limit 1 offset counter;
        
        call sp_get_SCfinalmarks(tmpsid, tmpcid, tmpmarks);        
        UPDATE REGISTRATION SET final_mark = tmpmarks where sid = tmpsid and cid = tmpcid;
        set counter= counter + 1;
    end while;
END$$
delimiter ;

call sp_populate_finalmarks();
select * from registration;  #to verify if final marks are updated for all records


#c. Write a trigger ‘after_performance_update’ that executes after there is an update of marks on
#performance table. When the marks of a student for a course in performance table is updated, the
#final_mark should be updated for the corresponding student in REGISTRATION table. Use stored
#procedure sp_get_SCfinalmarks in your trigger.

DELIMITER $$
CREATE trigger after_performance_update after update on performance for each row
 BEGIN
declare tmpmarks decimal(5,2);
if old.mark <> new.mark then  -- #this is to update only if there is change in marks
		call sp_get_SCfinalmarks(new.sid, new.cid, tmpmarks);
		UPDATE REGISTRATION SET final_mark = tmpmarks where sid=new.sid and cid=new.cid;
end if;
 END $$
DELIMITER ;

#d. Write a trigger ‘after_performance_delete’ that executes after a record is deleted from performance
#table. Update the REGISTRATION table’s final_mark for the student and the course. Use
#sp_get_SCfinalmarks in your trigger.

DELIMITER $$
CREATE trigger after_performance_delete after delete on performance for each row
 BEGIN
declare tmpmarks decimal(5,2);
		call sp_get_SCfinalmarks(old.sid, old.cid, tmpmarks);
		UPDATE REGISTRATION SET final_mark = tmpmarks where sid=old.sid and cid=old.cid;

 END $$
DELIMITER ;

#e. Write a trigger ‘after_performance_insert’ that executes after a new record inserted into performance
#table. Update the REGISTRATION table’s final_mark for the student and the course for the new
#assessment marks. Use sp_get_SCfinalmarks in your trigger.

delimiter $$
create trigger after_performance_insert after insert on performance for each row
begin
	declare tmpmarks decimal(5,2);
    call sp_get_SCfinalmarks(new.sid, new.cid, tmpmarks);
    UPDATE REGISTRATION SET final_mark = tmpmarks where sid=new.sid and cid=new.cid;
end$$
delimiter ;


# f.Write a trigger that executes before a record is inserted into registration table. 
# Stop the insertion of the registration record if the student has already registered  
# for more than 5 courses for the semester.

delimiter $$
create trigger before_regist_insert before insert on registration for each row
begin

declare tempCount int;
set tempCount = (select count(*) from registration where sid = new.sid);
if (tempCount >= 5) 
then SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT
= 'student has registered for more than 5 courses';
end if;
end$$
delimiter ;

select * from registration where sid = 54907;  #checks how many courses has this student registered in
insert into registration(sid, cid, semester) values (54907, 'ISM 5555', 'I-2001');
insert into registration(sid, cid, semester)  values (54907, 'ISM 6666', 'I-2001');  #this fails and record is not inserted


# g.	Write a stored procedure that takes in an integer say n. The stored procedure should list 
#       all the faculty whose qualification is more than n years old. The stored procedure is 
#       expected to list the FID, FName, CID, number of years since the "qualification certificate" 
#       was obtained (ignoring the actual month the qualification was obtained in

DELIMITER $$
CREATE PROCEDURE sp_get_faculty_for_training(years int)
 BEGIN

select fid,fname,cid, year(curdate()) - year(date_qualified) as "Years Since Qualified" from qualification where YearsQualified > years;

 END $$
DELIMITER ;
drop procedure sp_get_faculty_for_training;
CALL sp_get_faculty_for_training(25);







