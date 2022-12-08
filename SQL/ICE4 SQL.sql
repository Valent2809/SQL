#Exe4-Q3(a) Add a student with SID = 65798 and SNAME = 'Lopez' into STUDENT table.
insert into student values (65798, 'Lopez');	
select * from student;

#Exe4-Q3(b) Remove student with SID = 65798 from the STUDENT table
delete from student where sid=65798;#and name='Lopez' is optional as sid is they primary key(Unique)
select * from student;

#Exe4-Q3(c) Change the name of the faculty with FID = 4756 from 'Coke' to 'Collin'
update faculty set fname='Collin' where fid=4756;
select * from faculty;

select * from student;
#add a new column called GPA(decimal(3,2)) to student table
alter table student add GPA decimal(3,2) not null;
alter table student add school char(6);
alter table student drop school;
alter table student drop GPA;

#(d) Return ANAME of assessments with WEIGHT>0.3.
select aname from assessment where weight > 0.3;

#Exe4-Q3(e) Return SID and SNAME of students having SID less than 50000.
select sid,sname from student where sid < 50000 order by sid asc;# in ascending order of SID
#order by sid desc;#in descending order of SID

#(f) Return FNAME of the faculty member whose FID is 4756.
select fname from faculty where fid = 4756;

#Exe4-A3(g) Find the faculty members who have qualified to teach certain course(s) since year 1993 (inclusive
#1993). List the FID, CID and DATE_QUALIFIED. 

select fid,cid,date_qualified from qualification
where extract(year from date_qualified)>=1993;#since the date got year,month and day, we only want year
#extract(portion from date_column)
#portion for a column of date type: year, month,day
#portion for a column of time type: hour,minute,second
select fid,cid,date_qualified from qualification
where date_qualified>='1993-01-01';#same as on top

#Exe-Q3(h) Return the FNAME of all the faculty members with name containing the character ‘a’ (hint: use
#wildcard ‘%’).
#wildcards (%,_) must be paired with LIKE/NOT LIKE
select fname from faculty
where fname like '%a%';
#%a%: represent all the strings that contains 'a'
#a%: represent all the strings that start with 'a'
#%a: represent all the strings that end with 'a'
#%aa% : represents all the strings that contain 'aa'
#not like '%a%': represent all the strings without 'a'
#'_a%': all the strings with second letter being 'a'

select sid,sname from student;
select * from student;

#Exe4-Q3(i) Display CID and CNAME for all courses with an ‘ISM’ prefix in the CID (hint: use wildcard ‘%’)
select * from course where cid like 'ISM%';

#Exe4-Q3(j) Display the lowest assessment mark of student having SID =54907 (hint: use function MIN())
select min(mark) from performance where sid=54907;

#Exe4-Q3(k) Return the number of students who are enrolled in course ‘ISM 4212’ in the semester ‘I-2001’ (hint:
#use function count())
select count(*) from registration
where cid='ISM 4212' and semester='I-2001';

#Exe4-Q3(l) Return the total number of students who registered in semester ‘I-2001’
select count(distinct sid) from registration
where semester ='I-2001';	

#Exe4-Q3(m) List FID of those faculty members who are qualified to teach either ISM 3112 or ISM 3113 with the
#corresponding qualified date falling in the month September. List CID and DATE_QUALIFIED as
#well (hint: use function extract(month from date_qualified) to get the month).

#better answer
select fid,cid,date_qualified from qualification
where cid in ('ISM 3112','ISM 3113') and 
extract(month from date_qualified) = 9;
#alternative solution
select fid,cid,date_qualified from qualification
where (cid = 'ISM 3112' or cid = 'ISM 3113')
and date_qualified like '%-09-%';

#without () that means 'ISM 3112' is condition alone and ISM 3113 and date_qualified like ... is another which is wrong

#Exe4-Q3(n) Display CID of the courses offered in the semester I-2001. List each course only once (hint: use
#‘distinct’ to avoid duplication).

select distinct cid from registration
where semester='I-2001';

#Exe4-Q3(o) List SID and SNAME of all students in alphabetical order by SNAME. 
select * from student order by sname;

#Exe4-Q3(p) For each student in PERFORMANCE table, return SID and the best performance in an assessment (that
#means the highest mark in any assessment).

select sid,max(mark) as 'Best Performance' from performance
group by sid;# cause for each of the student we want to apply this max function
#having max(mark) >= 85;#(if we want only student with max result >= 85) where and having is diff

#Exe4-Q3(q) For each type in ROOM table, return TYPE and the total number of rooms belonging to that type.
select type,count(*) from room group by type;
#group by type means we count the number of instances in the each type

#(r) For each course in QUALIFICATION table, return CID of the course and the number of faculty
#members who are qualified to teach the course.
select cid,count(*) as QualifiedToTeach from qualification group by cid;

#(s) For each student in REGISTRATION table, return SID of the student and the number of courses that
#student registers.
select sid,count(*) as NoOfCourse from registration group by sid;

#(t) For each assessment corresponding to course with CID = ‘ISM 4212’ in PERFORMANCE table, return
#AID, the minimal mark, the maximal mark, and the average mark. 

select aid,min(mark),max(mark),avg(mark)
 from performance group by aid,cid having cid = 'ISM 4212';
 
 select aid,min(mark),max(mark),avg(mark) 
 from performance where cid = 'ISM 4212' group by aid,cid;
 
 #(u)For each course in PERFORMANCE table, return CID of that course, AID of each assessment of that
 #course, together with the minimal mark, the maximal mark, and the average mark. 
 select cid,aid,min(mark),max(mark),avg(mark) from performance group by cid,aid;
 
 #(v) For each course in PERFORMANCE table with CID different from ‘ISM 4212’, return AID of each
#assessment of that course, together with the minimal mark, the maximal mark, and the average mark. 

 select aid,min(mark),max(mark),avg(mark) from performance 
 group by aid,cid having cid != 'ISM 4212';
 
 #(w) Display CID of the course as well as the total number of qualified teaching faculty members for all the
#courses that can be taught by at least two faculty members.
 select cid,count(*) as NoOfQualifiedTeaching from qualification 
 group by cid having count(*) >= 2;