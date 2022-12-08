#step 1: Find SID of those students who take 'ISM 3113' in 'I-2001'
#assume: output is stored by List1
select sid from registration
where cid = 'ISM 3113' and semester='I-2001';

#step 2: find Sname for students whose SID in List1
select sname from student 
where sid in (select sid,cid from registration
where cid='ISM 3113' and semester='I-2001');

#step 1: find FID of faculty who can teach >= 2 courses
#output: List
select fid from qualification group by fid having count(*)>=2;

#step 2: find fname for all the faculty whose FID appears in the List
select fname,fid from faculty where fid in 
(select fid from qualification group by fid having count(*)>=2);

#how to use subquery to solve: both - and
#step 1: find SID of students who take 'Database'
select sid from course c,registration r where c.cid=r.cid and cname='Database';

#step 2: Find sid for students who take 'Networking'
#output: list2;
select sid from course c,registration r
where c.cid=r.cid and cname='Networking';



#Slide 8
#using join
select distinct fid from qualification q,course c 
where c.cid = q.cid and (cname = 'Syst Analysis' or cname = 'Syst Design');

select distinct fid from qualification q,course c 
where c.cid = q.cid and cname in ('Syst Analysis','Syst Design');

#using sub query
select fid from faculty 
where fid in (select fid from qualification q,course c 
where q.cid =c.cid and cname = 'Syst Design')
or fid in (select fid from qualification q,course c
where q.cid=c.cid and cname = 'Syst Analysis');

#slide 9
select fid from qualification q,course c 
where q.cid = c.cid and cname in ('Syst Design','Syst Analysis')
group by fid having count(*) = 1;

select fid from faculty 
where fid in (select fid from qualification q,course c 
where q.cid =c.cid and cname = 'Syst Design')
xor fid in (select fid from qualification q,course c
where q.cid=c.cid and cname = 'Syst Analysis');


#find students who take only 'Database' and 'Networking'
select sid from student 
where sid in (select sid from registration r,course c
where r.cid = c.cid and cname = 'Database')
and sid in (select sid from registration r,course c
where r.cid = c.cid and cname = 'Networking')
and sid in (select sid from registration r,course c
group by sid having count(*) = 2);

#slide 12
select fid,fname from faculty 
where fid in (select fid from qualification f,course c 
where f.cid = q.cid and cname = 'Syst Design')
and fid in (select fid from qualification 
group by fid having count(*) = 1);

select * from faculty
where fid in (select fid from qualification q,course c
where q.cid = c.cid and cname = 'Syst Design')
and fid not in (select fid from qualification q,course c
where q.cid=c.cid and cname<>'Syst Design');

#slide 13: step 1 find the total number of available courses
select count(*) from course;
#output = 4
#step 2: find sid of students who take four courses
select sid from registration group by sid
having count(*) = (select count(*) from course);

#slide 14: step 1: find the number of courses prof.berry can teach
select count(*) from qualification q,faculty f
where q.fid = f.fid and fname='Berry';
#step 2: find fid of faculty who can teach 2 courses
select fid from qualification group by fid
having count(*) = (select count(*) from qualification q,faculty f
where q.fid = f.fid and fname='Berry');

#slide 15:
select fid from qualification
where fid not in (select fid from faculty where fname ='Berry')
group by fid having count(*) = (select count(*) from qualification q,faculty f 
where q.fid = f.fid and fname = 'Berry')
and fid<> (select fid from faculty where fname = 'Berry');

#slide 16:
#step 1: form a temp table(cid,semester) to capture the courses Dave take
select cid,semester from registration r,student s 
where r.sid=s.sid and sname = 'Dave';
#step 2: course c left outer join temp(table in step 1)
select c.cid, cname, semester from course c left outer join
(select cid,semester from registration r,student s 
where r.sid=s.sid and sname = 'Dave') as
temp on c.cid=temp.cid;

#slide 18:
#step 1: form table (cid,semester,student_no)
select cid,semester,count(*) as student_no from registration 
group by cid, semester;

select t1.cid,t2.cid,t1.semester,t1.student_no
from (select cid,semester,count(*) as student_no from registration
group by cid,semester) as t1, # this creates a table and named it as t1
(select cid,semester,count(*) as student_no from registration
group by cid,semester) as t2
where t1.cid<t2.cid and t1.semester=t2.semester
and t1.student_no=t2.student_no;

#step 1: form a table in the form of (sid,semester,courseTaken),
#courseTaken: the number of courses student takes in the semester
select sid,semester,count(*) as coursesTaken 
from registration group by sid,semester;

#step 2: apply MAX(CourseTaken) to find the max Count
select max(coursesTaken)
from (select sid,semester,count(*) as coursesTaken 
from registration group by sid,semester) as temp;

#Step 3: Find students who take max count number of courses
select sid,semester,count(*) as coursesTaken 
from registration group by sid,semester 
having count(*) = (select max(coursesTaken)
from (select sid,semester,count(*) as coursesTaken 
from registration group by sid,semester) as temp);


#slide 21
#step 1: form a table t1(cid, sid, finalscore)
select cid,sid,a.aid,sum(mark*weight) as FinalScore
from performance p,assessment a
where p.aid = a.aid group by cid,sid;

#step 2: form another table t2(cid,MaxScore)
#select cid,max(FinalScore) as maxscore
#from t1 group by cid;

select cid,max(FinalScore) as maxscore
from (select cid,sid,a.aid,sum(mark*weight) as FinalScore
from performance p,assessment a
where p.aid = a.aid group by cid,sid) as t1 
group by cid;

#step 3: find student(s) who score maxscore in the course,t1 table capture all final score,t2 table capture MaxScore
#select t1.cid,t1.sid
#from t1,t2
#where t1.cid= t2.cid and t1.FinalScore=t2.FinalScore;

select t1.cid,t1.sid
from (select cid,sid,a.aid,sum(mark*weight) as FinalScore
from performance p,assessment a
where p.aid = a.aid group by cid,sid) as t1,
 
(select cid,max(FinalScore) as maxscore
from (select cid,sid,a.aid,sum(mark*weight) as FinalScore
from performance p,assessment a
where p.aid = a.aid group by cid,sid) as t1
group by cid) as t2

where t1.cid = t2.cid and t1.FinalScore = t2.maxscore;			


