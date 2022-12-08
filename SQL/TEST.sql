#Return sid of buses that are connected by more than 5 stops
select sr1.sid,sr2.sid,count(*) as connectedStops from stoprank sr1,stoprank sr2 where 
sr1.stopid=sr2.stopid and sr1.sid<sr2.sid group by sr1.sid,sr2.sid having count(*)>5;

#Return bus services whose stops are identical
select distinct sr1.sid,sr2.sid from stoprank sr1,stoprank sr2 where sr1.stopid=sr2.stopid
and sr1.sid < sr2.sid;

#Return buses (not services) that operates both express and normal services
select sid from service where normal = 0;
select sid from service where normal = 1;
#this is not correct as there is no service which operate in both express and normal
select plateno from bustrip where sid in (select sid from service where normal = 1)
 and sid in (select sid from service where normal = 0);

#find plate numbers that operate normal
select distinct plateno from bustrip where sid in(
select bt.sid from bustrip bt,service s where bt.sid = s.sid and normal = 1);

select sid from service where normal = 1;
select sid from service where normal = 0;

#find plate numbers that operate express 
select distinct plateno from bustrip where sid in 
(select bt.sid from bustrip bt inner join service s on bt.sid = s.sid and normal = 0);

#combine?

select distinct plateno from bustrip
where plateno in (select distinct plateno from bustrip where sid in 
(select bt.sid from bustrip bt inner join service s on bt.sid = s.sid and normal = 1))
and plateno in (select distinct plateno from bustrip where sid in 
(select bt.sid from bustrip bt inner join service s on bt.sid = s.sid and normal = 0));

#Return citylink cards which got replaced as a senior citizen card and was previously an adult card.
select * from citylink;
select * from cardtype;
select cardid from citylink where type = 'Adult';
select cardid from citylink where type = 'Senior';
select cl.CardID from (select cardid from citylink where type = 'Adult') as ta , 
citylink cl where type = 'Senior' and cl.oldcardid = ta.cardid ;


#Return the number of offences each officers dished out.
select * from offence;
select count(*),name from offence off,officer ofc where ofc.officerid=off.oid group by oid;

#List the available buses that is available in June 2020 and service after 12 midnight and before 7am.
select * from express;
select * from bustrip;
select * from bustrip where tdate like '2020-06-%' and hour(starttime) >= 0 and hour(endtime) <= 7;

#List the instances where each bus trip had no passengers boarding it
select bt.sid,starttime,count(*) as passangers from bustrip bt,ride rd where boardtime >= starttime
and alighttime <= endtime and tdate = rdate group by bt.sid,tdate,starttime;

#List out the amount of current users of each card type
select type,count(*) from citylink group by type;

select type,count(*) from citylink where expiry >= now() and 
cardid not in (select oldcardid from citylink where oldcardid is not null) group by type;


select cardid from citylink where cardid not in (select oldcardid from citylink where oldcardid is not null);


select * from normal;
select * from express;
select * from service;
select * from company;
select * from company c,service s where c.sid = s.sid;
select * from bus;
select distinct b1.plateno,b2.plateno,b1.capacity from bus b1,bus b2 where b1.capacity=b2.capacity and b1.plateno < b2.plateno;
select * from driver;
select count(*) as NoOfMale from driver where gender='M';
select count(*) as NoOfFemale from driver where gender='F';
select * from bustrip;
select dr.did,name,count(*) as BusDrove from bustrip bt,driver dr where dr.did=bt.did group by dr.did having count(*) > 5;
select * from officer;

select plateno from bustrip bt,service s where bt.sid=s.sid and normal = 0;
select plateno from bustrip bt,service s where bt.sid=s.sid and normal = 1;

select distinct plateno from bustrip where plateno in 
(select plateno from bustrip bt,service s where bt.sid=s.sid and normal = 0)
 and plateno in (select plateno from bustrip bt,service s where bt.sid=s.sid and normal = 1);

select distinct plateno from bustrip where plateno in 
(select plateno from bustrip bt,service s where bt.sid=s.sid and normal = 0)
xor plateno in (select plateno from bustrip bt,service s where bt.sid=s.sid and normal = 1);



select * from offence;
select * from citylink;
select * from citylink where oldcardid is not null;

select * from cardtype;
select * from ride;
select * from stoprank;
select * from stop;
select * from stoppair;

#List out cardIDs and its previously replaced card ID along with its balance before it was replaced.
select t1.cardid, oldcardid , balance from (select cardid, oldcardid from citylink where oldcardid <> 'null') as t1 , 
(select cardid, balance from citylink) as t2 where t1.oldcardid = t2.cardid;
DELIMITER $$
CREATE PROCEDURE TriggerTransferBalance()
 BEGIN
	select 'create trigger transferbalance before insert on citylink for each row begin declare oldbalance int; if (new.oldcardid is not null) then select balance into oldbalance from citylink where cardid = new.oldcardid; set new.balance = new.balance + oldbalance; end if;';
 END $$
DELIMITER ;

call TriggerTransferBalance();
select * from offence;
select * from citylink;

CREATE TRIGGER UPDATE_BALANCE_AFTER_RIDE AFTER INSERT ON RIDE FOR EACH ROW
BEGIN
DECLARE FARE DOUBLE;
IF (NEW.ALIGHTSTOP IS NOT NULL) THEN
SELECT BASEFEE INTO FARE FROM STOPPAIR WHERE FROMSTOP = NEW.BOARDSTOP AND TOSTOP = NEW.ALIGHTSTOP;
UPDATE CITYLINK SET BALANCE = (BALANCE - FARE) WHERE CARDID = NEW.CARDID;
ELSE
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DID NOT TAP OUT CHARGE MAX FARE?';
END IF;

DELIMITER $$
CREATE PROCEDURE TriggerUpdateBalanceAfterRide()
 BEGIN
select 'create trigger update_balance_after_ride after insert on ride for each row begin declare fare double; if (new.alightstop is not null) then set fare = select basefee from stoppair where fromstop = new.boardstop and tostop = new.alightstop; update citylink set balance = (balance - fare) where cardid = new.cardid; end if;';
 END $$
DELIMITER ;

select * from citylink;


DELIMITER $$
CREATE PROCEDURE NoOfNonExpiredCards()
 BEGIN
select 'select type,count(*) from citylink where expiry >= now() and cardid not in (select oldcardid from citylink where oldcardid is not null) group by type; ';
 END $$
DELIMITER ;

select * from cardtype;

select cardid,discount from citylink cl,cardtype ct where cl.type = ct.type;
select cardid,basefee from ride r,stoppair st where r.boardstop = st.fromstop and r.alightstop = st.tostop;
select t1.cardid,t2.basefee, (1-discount)*basefee as RealFee from (select cardid,discount from citylink cl,cardtype ct where cl.type = ct.type) as t1,
(select cardid,basefee from ride r,stoppair st where r.boardstop = st.fromstop and r.alightstop = st.tostop) as t2 
where t1.cardid = t2.cardid;
