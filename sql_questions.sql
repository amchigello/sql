--self join

select * from(
select m.employee_id as mgr_id,m.last_name as mgr_name,
       e.last_name as employee_name,e.salary as emp_sal,
       max(e.salary) keep (dense_rank last order by e.salary) over (partition by m.employee_id) as max_sal 
  from hr.employees e, hr.employees m
 where e.manager_id = m.employee_id(+)
 )
 where emp_sal = max_sal;
 
 select * from(
select e.employee_id ,e.last_name,m.department_id,
       m.department_name,e.salary,
       max(e.salary) keep (dense_rank last order by e.salary) over (partition by m.department_name) as max_sal,
       max(e.salary) keep (dense_rank first order by e.salary) over (partition by m.department_name) as min_sal 
  from hr.employees e, hr.departments m
 where e.department_id = m.department_id
 )
 where (salary = max_sal or salary = min_sal);
 
with qry
as
(
select 1 as col from dual
union
select 2 from dual
union
select 3 from dual
)
select a.col 
from qry a, qry b
where a.col >= b.col

--nth highest salary

SELECT name, salary 
FROM #Employee e1
WHERE N-1 = (SELECT COUNT(DISTINCT salary) FROM #Employee e2
WHERE e2.salary > e1.salary)

--Get employees has saleary more than their managers

select emp.employee_id,emp.first_name,emp.salary,
       mgr.employee_id,mgr.first_name,mgr.salary
  from hr.employees emp ,hr.employees mgr
 where emp.manager_id=mgr.employee_id;


--I want to list all employees' names along with their manager names, including those who do not have a manager.
--For those employees, their manager's name should be displayed as 'BOSS'.

select emp.employee_id,emp.first_name,
       mgr.employee_id as manager_id ,
       case when mgr.first_name is not null
            then mgr.first_name
            else 'BOSS'
            end
  from hr.employees emp left join hr.employees mgr
    on (emp.manager_id=mgr.employee_id)

-- Delete (I,U,D)

create table new_joinees
(
employee_id   NUMBER,
name          VARCHAR2(10)
);

insert into new_joinees values(1,'Pandu');
insert into new_joinees values(2,'Nayak');
insert into new_joinees values(3,'Rashmi');
insert into new_joinees values(4,'Mallya');
insert into new_joinees values(5,'Pradyumna');
insert into new_joinees values(6,'Prabhu');


create table new_joinees_incr
(
employee_id   NUMBER,
name          VARCHAR2(10),
flg           VARCHAR2(1)
);


insert into new_joinees_incr values(7,'Sai','I');
insert into new_joinees_incr values(7,'Venkatesh','D');
insert into new_joinees_incr values(7,'MS','U');
insert into new_joinees_incr values(2,'Ranga','U');
insert into new_joinees_incr values(2,'Ranga','D');
insert into new_joinees_incr values(4,'Mallya','D');

commit;

select * from new_joinees_incr;

--Insert
select employee_id,name from new_joinees_incr where flg='I';

--Update


select employee_id,name
  from new_joinees_incr a
  where flg='U'
    and not exists (
                     select 1
                       from new_joinees_incr b
                      where a.employee_id=b.employee_id
                        and b.flg in ('I')
                       );

--Delete

select employee_id,name
  from new_joinees_incr a
  where flg='D'
    and not exists (
                     select 1
                       from new_joinees_incr b
                      where a.employee_id=b.employee_id
                        and b.flg in ('I','U')
                       );

---Window function

drop table emp;

CREATE TABLE emp (
  empno    NUMBER(4) CONSTRAINT pk_emp PRIMARY KEY,
  ename    VARCHAR2(10),
  job      VARCHAR2(9),
  mgr      NUMBER(4),
  hiredate DATE,
  sal      NUMBER(7,2),
  comm     NUMBER(7,2),
  deptno   NUMBER(2)
);

INSERT INTO emp VALUES (1,'SMITH','CLERK',7902,to_date('17-12-1980','dd-mm-yyyy'),800,NULL,20);
INSERT INTO emp VALUES (2,'ALLEN','SALESMAN',7698,to_date('20-2-1981','dd-mm-yyyy'),1600,300,30);
INSERT INTO emp VALUES (3,'WARD','SALESMAN',7698,to_date('22-2-1981','dd-mm-yyyy'),1250,500,30);
INSERT INTO emp VALUES (4,'JONES','MANAGER',7839,to_date('2-4-1981','dd-mm-yyyy'),2975,NULL,20);
INSERT INTO emp VALUES (5,'MARTIN','SALESMAN',7698,to_date('28-9-1981','dd-mm-yyyy'),1250,1400,30);
INSERT INTO emp VALUES (6,'BLAKE','MANAGER',7839,to_date('1-5-1981','dd-mm-yyyy'),2850,NULL,30);
INSERT INTO emp VALUES (7,'CLARK','MANAGER',7839,to_date('9-6-1981','dd-mm-yyyy'),2450,NULL,10);
INSERT INTO emp VALUES (8,'SCOTT','ANALYST',7566,to_date('13-JUL-87','dd-mm-rr')-85,3000,NULL,20);
INSERT INTO emp VALUES (9,'KING','PRESIDENT',NULL,to_date('17-11-1981','dd-mm-yyyy'),5000,NULL,10);
INSERT INTO emp VALUES (10,'TURNER','SALESMAN',7698,to_date('8-9-1981','dd-mm-yyyy'),1500,0,30);
INSERT INTO emp VALUES (11,'ADAMS','CLERK',7788,to_date('13-JUL-87', 'dd-mm-rr')-51,1100,NULL,20);
INSERT INTO emp VALUES (12,'JAMES','CLERK',7698,to_date('3-12-1981','dd-mm-yyyy'),950,NULL,30);
INSERT INTO emp VALUES (13,'FORD','ANALYST',7566,to_date('3-12-1981','dd-mm-yyyy'),3000,NULL,20);
INSERT INTO emp VALUES (14,'MILLER','CLERK',7782,to_date('23-1-1982','dd-mm-yyyy'),1300,NULL,10);
COMMIT;

select empno, deptno, sal
       ,SUM(sal) OVER (PARTITION BY deptno order by sal
        ) as sum_sal
  from emp
  ORDER BY 2,3;


Result Set 18

EMPNO   DEPTNO  SAL SUM_SAL
14  10  1300    1300
7   10  2450    3750
9   10  5000    8750
1   20  800 800
11  20  1100    1900
4   20  2975    4875
8   20  3000    10875
13  20  3000    10875
12  30  950 950
5   30  1250    3450
3   30  1250    3450
10  30  1500    4950
2   30  1600    6550
6   30  2850    9400

select empno, deptno, sal
       ,SUM(sal) OVER (PARTITION BY deptno
        ) as sum_sal
  from emp
  ORDER BY 2,3;

EMPNO   DEPTNO  SAL SUM_SAL
14  10  1300    8750
7   10  2450    8750
9   10  5000    8750
1   20  800 10875
11  20  1100    10875
4   20  2975    10875
8   20  3000    10875
13  20  3000    10875
12  30  950 9400
5   30  1250    9400
3   30  1250    9400
10  30  1500    9400
2   30  1600    9400
6   30  2850    9400

select empno, deptno, sal
       ,SUM(sal) OVER (PARTITION BY deptno order by sal
        ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING
        ) as sum_sal
  from emp
  ORDER BY 2,3;

EMPNO DEPTNO  SAL SUM_SAL
14  10  1300  8750
7 10  2450  8750
9 10  5000  8750
1 20  800 4875
11  20  1100  7875
4 20  2975  10875
8 20  3000  10075
13  20  3000  8975
12  30  950 3450
5 30  1250  4950
3 30  1250  6550
10  30  1500  8450
2 30  1600  7200
6 30  2850  5950


select empno, deptno, sal
       ,SUM(sal) OVER (PARTITION BY deptno order by sal
        ROWS BETWEEN unbounded PRECEDING AND unbounded FOLLOWING
        ) as sum_sal
  from emp
  ORDER BY 2,3;

EMPNO DEPTNO  SAL SUM_SAL
14  10  1300  8750
7 10  2450  8750
9 10  5000  8750
1 20  800 10875
11  20  1100  10875
4 20  2975  10875
8 20  3000  10875
13  20  3000  10875
12  30  950 9400
5 30  1250  9400
3 30  1250  9400
10  30  1500  9400
2 30  1600  9400
6 30  2850  9400

---Hierarchichal Queries

select e.*,level,LTRIM(SYS_CONNECT_BY_PATH(manager_id, '-'), '-') AS path
from hr.employees e
start with manager_id is null
connect by manager_id = prior employee_id

create table tasks
(
task_id  varchar2(2),
steps    number,
status   varchar2(1)
);

insert into tasks values('T1',1,'C');
insert into tasks values('T1',2,'W');
insert into tasks values('T1',3,'W');
insert into tasks values('T2',1,'W');
insert into tasks values('T2',2,'C');
insert into tasks values('T2',3,'C');
insert into tasks values('T3',1,'C');
insert into tasks values('T3',2,'W');
insert into tasks values('T3',3,'C');

SELECT A.*,
       LAG(STATUS,STEPS-1,STATUS) OVER (PARTITION BY TASK_ID ORDER BY STEPS) AS VAL
  FROM TASKS A;
  
select e1.first_name,e1.salary,e1.department_id
  from hr.employees e1
 where 2-1 = (select count(distinct salary)
                 from hr.employees e2
                where e2.salary>e1.salary
                and e1.department_id=e2.department_id
                )
order by 3;

select explode(col2) from table1;

select author_name, exploded_books 
  from table1 lateral view explode(books_name) dummy as exploded_books;

select key, value 
  from table1 lateral view explode(books_name) dummy as key,value;

drop table dim_user;
--dim table 

drop table dim_user_stg;
--incremental table


create table dim_user
(
user_id  number,
user_name varchar2(10),
start_dt  date,
end_dt  date,
active varchar2(1)
);

insert into dim_user values(1,'abc',sysdate-10,null,'Y');
insert into dim_user values(2,'def',sysdate-10,sysdate-9,'N');
insert into dim_user values(2,'ghi',sysdate-9,null,'Y');

commit;

create table dim_user_stg
(
user_id  number,
user_name varchar2(10)
);


insert into dim_user_stg values(1,'123');
insert into dim_user_stg values(2,'456');
insert into dim_user_stg values(3,'789');

drop table dim_user_stg1;  
--stage table

create table dim_user_stg1
as
select a.user_id,a.user_name,sysdate as start_dt,cast(null as date) as end_dt,'Y' as active from dim_user_stg a, dim_user b
where a.user_id=b.user_id(+)
and b.end_dt is null;
  
merge into dim_user t
  using(select * from dim_user_stg1) s
on (s.user_id=t.user_id)
when matched then update set END_DT=sysdate,active='N'
where end_dt is null;

insert into dim_user
select * from dim_user_stg1

commit;
 
 select * from dim_user;
 
 --scd type 3
 --SCD Type3 Implementation

drop table dim_user_scd_3;

create table dim_user_scd_3
(
user_id      number,
curr_user_name    varchar2(10),
prev_user_name    varchar2(10)
);

insert into dim_user_scd_3 values(1,'Pandu','Nayak');
insert into dim_user_scd_3 values(2,'Rashmi','');
insert into dim_user_scd_3 values(3,'John','Jon');
insert into dim_user_scd_3 values(4,'Kevin','');

commit;

drop table dim_user_stg;

create table dim_user_stg
(
user_id  number,
user_name  varchar2(10)
);

insert into dim_user_stg values(1,'Pandu');
insert into dim_user_stg values(2,'Rashmi M');
insert into dim_user_stg values(3,'Jon');
insert into dim_user_stg values(4,'Kelvin');
insert into dim_user_stg values(5,'Penny');

commit;

MERGE INTO DIM_USER_SCD_3 T
USING(
SELECT  B.USER_ID,
       B.USER_NAME AS CURR_USER_NAME,
       A.CURR_USER_NAME AS PREV_USER_NAME  
  FROM DIM_USER_SCD_3 A,  DIM_USER_STG B
WHERE A.USER_ID(+)=B.USER_ID
AND NVL(A.CURR_USER_NAME,'-99') <> NVL(B.USER_NAME,'-99') 
) S
ON (S.USER_ID=T.USER_ID)
WHEN MATCHED THEN
UPDATE SET T.CURR_USER_NAME = S.CURR_USER_NAME,
           T.PREV_USER_NAME = S.PREV_USER_NAME;

COMMIT;    

SELECT * FROM DIM_USER_SCD_3;

 
 
