#Exercise 1
#method 1
select * from account;
delimiter $$
create procedure sp_count_accounts(in cusname varchar(45), out noOfSavingAcc int,out noOfFixedDep int)
Begin
	set noOfSavingacc = (select count(*) from account where cus_name=cusname and acc_type = 'SA');
    set noOfFixedDep = (select count(*) from account where cus_name=cusname and acc_type = 'FD');
end$$
delimiter ;
drop procedure sp_count_accounts;
call sp_count_accounts('Alex',@SA,@FD);
SELECT @SA as Savings, @FD as 'Fixed Deposit';

#method 2
create procedure sp_count_accounts(in cusname varchar(45),out noSA int,out noFD int)
	select sum(if(acc_type='SA',1,0)),
    sum(if(acc_type='FD',1,0)) into noSA, noFD
    from account where cus_name=cusname;

CALL sp_count_accounts('Alex', @SA, @FD);
SELECT @SA as Savings, @FD as 'Fixed Deposit';

#Exercise 2
delimiter $$
create trigger after_transactions_insert after insert on transactions for each row
begin
	declare currBalance decimal(10,2);
    set currBalance = (select balance from account where acc_num = new.acc_num);
    if(new.trans_type = 'D')
    THEN update account set balance = (currBalance + new.amount) where acc_num = new.acc_num;
    else update account set balance = (currBalance - new.amount) where acc_num = new.acc_num;
    end if;
end $$
delimiter ; 

update account set balance = 1000.0 where acc_num = 'A1';
select * from account;
delete from transactions where acc_num = 'A9' and amount = 200;
update account set balance = 550.0 where acc_num = 'A9';
INSERT INTO TRANSACTIONS(ACC_NUM, AMOUNT, TRANS_TYPE) VALUES ('A9',200, 'D');
INSERT INTO TRANSACTIONS(ACC_NUM, AMOUNT, TRANS_TYPE) VALUES ('A9',100, 'W'); 


#Exercise 3
INSERT INTO ACCOUNT VALUES ('ZZ', 'FD', 'DUMMY', 200);
INSERT INTO TRANSACTIONS(ACC_NUM, AMOUNT, TRANS_TYPE) VALUES('ZZ', 888.88, 'D');
select * from account;
select * from transactions;

delimiter $$
create trigger before_account_delete before delete on account for each row
begin
	delete from transactions where acc_num = old.acc_num;
    insert into deleted_accounts values(old.acc_num,old.acc_type,old.cus_name,old.balance, now());
end $$
delimiter ;

drop trigger before_account_delete;
DELETE FROM ACCOUNT WHERE ACC_NUM = 'ZZ';
select * from transactions;
delete from transactions where acc_num = 'ZZ';
select * from deleted_accounts;
