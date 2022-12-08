#create a stored procedure that returns all student records from student table

#to change the table, we need to drop it first
drop procedure getAllStudents;

create procedure getAllStudents()
select sid as MatricNumber,sname as name from student;

call getAllStudents();

#invoke stored procedure GetStudentsByCourses to return all students
#that registered for course id 'ISM 4212'
create procedure GetStudentsByCourse(in courseid char(8))
select sid from registration where cid = courseid;

drop procedure GetStudentsByCourse;
call GetStudentsByCourse('ISM 4212');

#select a stored procedure that return counts of faculty members
#who are qualified to teach a particular course

create procedure getCountFacByCourse(Courseid char(8), out CountFac int,out CountFac10 int)
	#method 1
	#set CountFac = (select count(*) from qualification where cid = 'ISM 4212');
    #set CountFac10 = (select count(*)*10 from qualification where cid = courseid);
    
    #method 2
    # count(*)*10 is for when they want the count to multiply by 10
    select count(*), count(*)*10 into CountFac,CountFac10 from qualification where cid = courseid;
drop procedure getCountFacByCourse;
call getCountFacByCourse('ISM 4212',@CountFac,@CountFac10);
select cid from qualification group by cid having count(*) = @CountFac;

CREATE PROCEDURE GetCountOfFaculty(IN courseid char(8) , OUT total int)	    
    select count(*) into total from qualification  where cid = courseid; 
    
CALL GetCountOfFaculty('ISM 3112', @total);
select @total;

#create a stored procedure that returns the sum of top X unique marks of a particular course,where X in integer
# so this will calculate the sum of the top 5/10/any number highest mark for a single course
DELIMITER $$
create procedure getSumTopXMarks(in x int,in courseid char(8),out total int)
Begin
	DECLARE cnt int DEFAULT 1; 	# this is a counter
	DECLARE maxloop int;	
	DECLARE currMax int;	
	DECLARE nextMax int;	    

set maxloop = (select count(distinct mark) from performance where cid = courseid);
set currMax = (select max(mark) from performance where cid = courseid);          
set total = currMax;

while cnt<x and cnt<maxloop
do
	set nextMax = (select max(mark) from performance where cid = courseid and mark < currMax);            	
	set cnt = cnt + 1;		
	set currMax = nextMax;		
	set total = total + nextMax;		
end while;
End$$
DELIMITER ;
drop procedure getSumTopXMarks;
call getSumTopXMarks(5,'ISM 4212',@total);
select @total;
