#Name: Valentino Ong (ID:valentinoo.2021)

#Q1
select nric,name,dob from driver order by name desc;

#Q2
select cardid,balance,expiry from citylink where year(expiry) = 2021;

#Q3
select * from stoppair where basefee > 3;

#Q4
select stopid,address from stop where address like '%Rd';

#Q5
select cardid,balance from citylink where type in ('Senior','Student') and oldcardid is null;

#Q6
select company,count(*) as NoOfServices from company c,service s where s.sid=c.sid group by company having count(*) >= 5;

#Q7
select distinct d.did,name,plateno from driver d left outer join bustrip bt on d.did=bt.did;

#Q8
select count(*) as NoOfPair from (
select sp1.fromstop ,sp1.tostop from stoppair sp1,stoppair sp2 where sp2.fromstop = sp1.tostop and sp1.fromstop = sp2.tostop) as temp;

#Q9
select dr.did,count(*) as numberOfOffence from offence o,bustrip bt,driver dr where o.sid=bt.sid and o.sdate = bt.tdate and o.stime = bt.starttime and
dr.did = bt.did group by dr.did having count(*) =
(select max(numberOfOffence) from (select dr.did,count(*) as numberOfOffence from offence o,bustrip bt,driver dr where o.sid=bt.sid and o.sdate = bt.tdate and o.stime = bt.starttime and
dr.did = bt.did group by dr.did) as temp);


#Q10

select c.cardid, count(distinct o.oid) as 'OffenceCount', count(distinct r.boardtime) as 'RideCount' from citylink c
left outer join offence o on c.cardid = o.paycard
left outer join ride r on c.cardid = r.cardid
group by c.cardid;


#Q13
delimiter $$ 

CREATE TRIGGER afterUpdatePayCard after update on offence for each row 
BEGIN 
DECLARE fine double; 
declare balanceAvail double;
set fine = (select sum(penalty) from offence where paycard = new.paycard);
set balanceAvail = (select balance from citylink where cardid = new.paycard);
IF (balanceAvail < fine) then signal sqlstate '45000' set message_text = 'Insufficient balance to cover the penalty';

elseif (select paycard from offence where paycard = old.paycard is null)
then UPDATE CITYLINK SET BALANCE = (BALANCE - FINE) WHERE CARDID = new.paycard;

else signal sqlstate '45000' set message_text = "Offence has already been paid with cardID + 'old.paycard'";

end IF;
end  $$
delimiter ;

delimiter $$
create procedure checkDirectService (in stopA int,in stopB int, out NumofDirectServices int,out ExpressServiceExcist char(3))
begin 
 select count(*) from busstop;
 
end $$
delimiter ;
