#(a)  For each student registered in Semester 'I-2001', list SID and SNAME of the student, and
#CID of the corresponding course(s).
#Method 1
select s.sid,sname,cid from student s,registration r
where s.sid = r.sid and semester = 'I-2001';

#Method 2
select s.sid,sname,cid
from student s inner join registration r
on s.sid=r.sid
where semester = 'I-2001'; # and also works

#(b) or slide 14 Return FID and FNAME of all the faculty members who were qualified to teach course in
#year 1995.

# Method 1
select f.fid,fname from faculty f, qualification q 
where f.fid = q.fid and extract(year from date_qualified) = 1995;

# Method 2
select f.fid,fname from faculty f inner join qualification q 
on f.fid = q.fid 
where extract(year from date_qualified) = 1995;

#what if they want year <= 1995, there will be duplicates of names like Ama repeat so to solve use distinct
select distinct f.fid,fname from faculty f inner join qualification q 
on f.fid = q.fid 
where extract(year from date_qualified) <= 1995;

#(C) Display CNAME and CID of all the courses for which Professor Ama has been qualified.
#Display the results based on descending order of CID.
select cname,c.cid from
(faculty f inner join qualification q
on f.fid = q.fid and fname = 'Ama')
inner join course c on c.cid = q.cid order by cid desc;

select c.cid,cname from course c,faculty f,qualification q 
where c.cid = q.cid and f.fid = q.fid and fname = 'Ama'
order by cid desc;

#(D) For each faculty in QUALIFICATION table, return FID and FNAME of the faculty. Display
#the results based on ascending order of FNAME.

# Method 1
select distinct q.fid, f.fname from qualification q,faculty f 
where q.fid = f.fid order by fname asc;

# Method 2
select distinct f.fid ,fname 
from faculty f inner join qualification q 
on f.fid=q.fid order by fname asc;

#(E) Return SID of those students who are enrolled into ‘Syst Analysis’ during semester I-2001.
select r.sid from registration r,course c 
where c.cid = r.cid and semester = 'I-2001' and cname = 'Syst Analysis';

#(F) Return SID and SNAME of those students who are enrolled into course ‘Syst Analysis’
#during semester I-2001.
select s.sid, sname from student s, registration r, course c 
where r.cid=c.cid and s.sid=r.sid
and semester = 'I-2001' and cname = 'Syst Analysis';

#or
select s.sid, sname 
from registration r inner join course c on r.cid=c.cid
inner join student s on s.sid = r.sid 
where semester = 'I-2001' and cname = 'Syst Analysis';


#(G) Return CNAME and CID of all the courses registered by those students whose names
#start with character ‘a’. Return SNAME of the students as well. 

select cname,c.cid,sname from student s,registration r, course c 
where s.sid=r.sid and r.cid =c.cid and sname like 'a%';

#or
select cname,c.cid,sname from (student s inner join registration r
on s.sid = r.sid) inner join course c on r.cid = c.cid and sname like 'a%';

#(h):  Return SID and SNAME of those students who are enrolled into at least one course that
#professor Berry can teach.
select distinct s.sid,s.sname from qualification q,registration r,student s,faculty f where
f.fid = q.fid and r.cid = q.cid and s.sid = r.sid and fname = 'Berry'; 

#(I) Return FID and FNAME of all the faculty in FACULTY table. If a faculty can teach, return
#CID of all the courses he/she can teach as well.
#we dont use q.fid as it does not contain Ester, try using q.fid and see the difference
select f.fid,q.fid,fname,cid from 
qualification q right outer join faculty f 
on f.fid = q.fid;

#(J) Return FID and FNAME of all the faculty in FACULTY table. If a faculty can teach, return
#CNAME of all the courses he/she can teach as well.

#use the original table from part I
select f.fid,fname,cname from 
(qualification q right outer join faculty f 
on f.fid = q.fid) left outer join course c on c.cid = q.cid;
#user outer join as we want to maintain the null values

select f.fid,fname,cname from (course c inner join qualification q on q.cid=c.cid)
right outer join faculty f on f.fid=q.fid;

#(K) Return FID and FNAME of all the faculty in FACULTY table. Display the number of
#courses he/she can teach.
select f.fid,fname,count(distinct cid) as CourseCanTeach
from faculty f left outer join qualification q on f.fid=q.fid
#use left outer join because we want qualification to be null for Ester
group by f.fid,fname;
#group by ... should contain same as what we select

#(L) Return SID and SNAME of all the students in STUDENT table. In addition, display the
#total number of courses each student has registered in semester I-2002.
select s.sid,sname,count(distinct cid) as CoursesTaken
from student s left outer join registration r on s.sid = r.sid and semester = 'I-2002'
group by s.sid,sname;

#(M)  Return CID and CNAME of all the courses in COURSE table. In addition, display the
#number of students registered during semester I-2002 per course.
select c.cid,cname,count(distinct sid) as StudentTake
from course c left outer join registration r on c.cid = r.cid and semester = 'I-2002'
group by c.cid,cname;

#(N) Find all the pairs of student and faculty with same name. The result is in the format of
#SID, FID, NAME).
select sid, sname, fid, fname from student,faculty where sname = fname; 

#(O) Find all the pairs of student and faculty with different names. The result is in the format of
#SID, SNAME, FID, FNAME). 
select sid,sname,fid,fname from student,faculty where sname != fname;

#(P) Based on the content of PERFORMANCE table, show the final mark per student per
#course. The result is in the format of (CID, SID, FINALMARK). The FINALMARK is the
#accumulated mark of student’s performance in various assessments based on the weight
#of assessment. 

select cid, sid, sum(weight*mark) as totalResult
from assessment a, performance p
where a.aid = p.aid 
group by cid, sid;

#(Q),Week 9 slide 7 Return SID of students who are enrolled in BOTH 'Database' AND 'Networking'.
select sid from registration r,course c 
where r.cid=c.cid and
(cname = 'database' or cname='Networking')
group by sid
having count(distinct c.cid) = 2;

#(Q) this is without the group by method which is slightly harder
select r1.sid, r1.cid as cid1, c1.cname as cname1, r2.cid as cid2,c2.cname as cname2
from registration r1,registration r2,course c1,course c2
where r1.sid = r2.sid and r1.cid<r2.cid and r1.cid=c1.cid and r2.cid = c2.cid
and ((c1.cname='Database' and c2.cname='Networking')
or (c1.cname='Networking' and c2.cname='Database'))
order by r1.sid;

#(r) Return FID of faculty who can teach either 'Syst Analysis' OR 'Syst Design', but not both.
select fid from qualification q, course c where q.cid = c.cid and (cname = 'Syst Analysis' or cname ='Syst Design')
group by fid having count(cname) = 1;

#(s) Find all the pair of faculty members who can teach the same course. The output is in
#(FID1, FID2, CNAME) format without any duplication.
select q1.fid,q2.fid,cname from 
qualification q1,qualification q2, course c 
where q1.cid = q2.cid and q1.cid = c.cid and q1.fid < q2.fid;  

#(t)Find the pair of rooms with same type and same capacity. The output is in the format of
#(RID1, RID2, TYPE, CAPACITY) without any duplication.
select r1.rid,r2.rid,r1.type,r1.capacity from 
room r1,room r2 where r1.type = r2.type and r1.capacity = r2.capacity 
and r1.rid < r2.rid;

#(u) Find the pair of students who have registered for the same course in the same semester.
#The output is in (SNAME1, SNAME2, CNAME, SEMESTER) format without any
#duplication.
select s1.sname,s2.sname,cname,r1.semester from student s1,student s2,registration r1,registration r2,course c 
where r1.sid = s1.sid and s2.sid = r2.sid and r1.cid = r2.cid
 and r1.semester = r2.semester and s1.sid < s2.sid;





