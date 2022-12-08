create schema if not exists `G1T5`;
use `G1T5`;

create table if not exists `Service`(
	SID int not null primary key,
    Normal boolean not null
);	

set global local_infile=true;
LOAD DATA LOCAL INFILE 'C:\\Users\\Valentino Ong\\Desktop\\IS112\\Project Phase 2\\G1T5\\Data\\service.txt' INTO TABLE 
service FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 
1 LINES;

create table if not exists `Driver`(
	DID int not null primary key,
    NRIC char(9) not null,
    Name varchar(50) not null,
    DoB Date not null,
    Gender char(1) not null
);


LOAD DATA LOCAL INFILE 'C:\\Users\\Valentino Ong\\Desktop\\IS112\\Project Phase 2\\G1T5\\Data\\driver.txt' INTO TABLE 
Driver FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 
1 LINES;

create table if not exists `bus`(
	plateno char(8) not null,
	fueltype varchar(10) not null,
	capacity int not null,
	constraint bus_pk primary key(plateno)
);

LOAD DATA LOCAL INFILE 'C:\\Users\\Valentino Ong\\Desktop\\IS112\\Project Phase 2\\G1T5\\Data\\bus.txt' INTO TABLE 
bus FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 
1 LINES;


create table if not exists `Officer`(
	Name varchar(50) not null,
    YearsEmp int not null,
    OfficerId int not null primary key
);

LOAD DATA LOCAL INFILE 'C:\\Users\\Valentino Ong\\Desktop\\IS112\\Project Phase 2\\G1T5\\Data\\officer.txt' INTO TABLE 
officer FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 
1 LINES (officerid, name, yearsemp);

create table if not exists `CardType`(
	`Type` varchar(10) not null primary key,
	Discount float not null,
	MinTopAmoun int not null,
	Description varchar(200) not null
);

LOAD DATA LOCAL INFILE 'C:\\Users\\Valentino Ong\\Desktop\\IS112\\Project Phase 2\\G1T5\\Data\\cardtype.txt' INTO TABLE 
cardtype FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 
1 LINES;

create table if not exists `stop`(
	StopID int not null primary key,
	LocationDes varchar(50) not null,
	Address varchar(50) not null
);

LOAD DATA LOCAL INFILE 'C:\\Users\\Valentino Ong\\Desktop\\IS112\\Project Phase 2\\G1T5\\Data\\stop.txt' INTO TABLE 
stop FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 
1 LINES;

create table if not exists `Bustrip`(
	SID int not null,
    TDate date not null,
    StartTime time not null,
    EndTime time not null,
    PlateNo char(8) not null, 
    DID int not null,
    constraint bustrip_pk primary key (SID, Tdate, StartTime),
    constraint bustrip_fk1 foreign key (SID) references Service(SID),
    constraint bustrip_fk2 foreign key (DID) references Driver(DID),
    constraint bustrip_fk3 foreign key (PlateNo) references Bus(PlateNo)
);

LOAD DATA LOCAL INFILE 'C:\\Users\\Valentino Ong\\Desktop\\IS112\\Project Phase 2\\G1T5\\Data\\bustrip.txt' INTO TABLE 
bustrip FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 
1 LINES;

create table if not exists `Citylink`(
	CardID int not null primary key,
    Balance float not null,
    Expiry date not null,
    Type varchar(10) not null, 
    OldCardId int,
    constraint citylink_fk1 foreign key (OldCardId) references Citylink(CardID),
    constraint citylink_fk2 foreign key (Type) references CardType(Type)
);

LOAD DATA LOCAL INFILE 'C:\\Users\\Valentino Ong\\Desktop\\IS112\\Project Phase 2\\G1T5\\Data\\citylink.txt' INTO TABLE 
citylink FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 
1 LINES (cardID, balance ,expiry , type, @OldCardId) set OldCardId = NULLIF(@OldCardId,'NULL');

create table if not exists `Offence`(
	ID int not null primary key,
    NRIC char(9) not null, 
    Time time not null,
    Penalty float not null,
    PayCard int,
    SID int not null,
    SDate date not null,
    STime time not null,
    OID int not null,
    constraint offence_fk1 foreign key (SID, SDate, STime) references Bustrip(SID, TDate, StartTime),
    constraint offence_fk2 foreign key (OID) references Officer(OfficerID),
    constraint offence_fk3 foreign key (PayCard) references CityLink(CardID)
);

LOAD DATA LOCAL INFILE 'C:\\Users\\Valentino Ong\\Desktop\\IS112\\Project Phase 2\\G1T5\\Data\\offence.txt' INTO TABLE 
offence FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 
1 LINES (ID,NRIC,Time,penalty,@paycard,SID,Sdate,Stime,OID) set paycard = NULLIF(@paycard,'NULL');

create table if not exists `StopRank`(
	StopID int not null,
	SID int not null,
	RankOrder int not null,
	constraint StopRank_pk primary key(StopID,SID),
	constraint StopRank_fk1 foreign key(StopID) references stop(StopID),
	constraint StopRank_fk2 foreign key(SID) references service(SID)
);

LOAD DATA LOCAL INFILE 'C:\\Users\\Valentino Ong\\Desktop\\IS112\\Project Phase 2\\G1T5\\Data\\stoprank.txt' INTO TABLE 
stoprank FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 
1 LINES;

create table if not exists `Ride`(
	CardID int not null,
	RDate date not null,
	UsePhone boolean not null,
	BoardStop int not null,
	SID int not null,
	AlightStop int,
	BoardTime time not null,
	AlightTime time,
	constraint Ride_pk primary key(CardID,RDate,BoardTime),
	constraint Ride_fk1 foreign key(CardID) references citylink(CardID),
	constraint Ride_fk2 foreign key(BoardStop,SID) references stoprank(StopID,SID),
	constraint Ride_fk3 foreign key(AlightStop) references stop(stopid)
);

LOAD DATA LOCAL INFILE 'C:\\Users\\Valentino Ong\\Desktop\\IS112\\Project Phase 2\\G1T5\\Data\\ride.txt' INTO TABLE 
ride FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 
1 LINES (cardID,rdate,usephone,boardstop,sid,@alightstop,boardtime,@alighttime) set alightstop = NULLIF(@alightstop,'NULL'),alighttime = NULLIF(@alighttime,'NULL');

create table if not exists `StopPair`(
	FromStop int not null,
	ToStop int not null,
	BaseFee float not null,
	constraint StopPair_pk primary key(FromStop, ToStop),
	constraint StopPair_fk1 foreign key(FromStop) references stop(StopID),
	constraint StopPair_fk2 foreign key(ToStop) references stop(StopID)
);
LOAD DATA LOCAL INFILE 'C:\\Users\\Valentino Ong\\Desktop\\IS112\\Project Phase 2\\G1T5\\Data\\stoppair.txt' INTO TABLE 
stoppair FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 
1 LINES;

create table if not exists `normal`(
	sid int not null,
	weekdayfreq int not null,
	weekendfreq int not null,
	constraint normal_pk primary key (sid),
	constraint normal_fk1 foreign key(sid) references service(sid)
);

LOAD DATA LOCAL INFILE 'C:\\Users\\Valentino Ong\\Desktop\\IS112\\Project Phase 2\\G1T5\\Data\\normal.txt' INTO TABLE 
normal FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 
1 LINES;

create table if not exists `express`(
	sid int not null,
	availableweekend boolean not null,
	availableph boolean not null,
	constraint express_pk primary key(sid),
	constraint express_fk1 foreign key(sid) references service(sid)
);

LOAD DATA LOCAL INFILE 'C:\\Users\\Valentino Ong\\Desktop\\IS112\\Project Phase 2\\G1T5\\Data\\express.txt' INTO TABLE 
express FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 
1 LINES;

create table if not exists `company`(
	sid int not null,
	company varchar(20) not null,
	constraint company_pk primary key(sid,company),
	constraint company_fk1 foreign key (sid) references service(sid)
);

LOAD DATA LOCAL INFILE 'C:\\Users\\Valentino Ong\\Desktop\\IS112\\Project Phase 2\\G1T5\\Data\\company.txt' INTO TABLE 
company FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 
1 LINES;


