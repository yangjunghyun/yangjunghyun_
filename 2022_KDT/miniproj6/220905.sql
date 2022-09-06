create database mini6;
use mini6;

create table mini6.인적정보 (
성명 char(5), 
학번 int, 
학과 char(10), 
생년월일 date
);

insert into mini6.인적정보 (성명, 학번, 학과, 생년월일) values 
('손흥구', 20040805, '통계학과', 19850729), 
('고희정', 20090908, '통계학과', 19890527), 
('김연경', 20125708, '물류학과', 19920309), 
('이주형', 20161201, null, 19910619);

select * from 인적정보;


# delete from mini6.인적정보 where 학번 < 20070000; # 구버전만 됨.

create table mini6.data1 (
성명 char(5), 
학번 int, 
학과 char(10), 
생년월일 date
);

#load data infile 'Users/yangjunghyun/Desktop/2022_02/KDT/mini6/Untitled.csv' into table mini6.data1
#fields terminated by ',' lines terminated by '\n'
#ignore 1 lines;

alter table 인적정보 add primary key (학번);

create table 인적정보결과 select*, substring(학번,1,4) as 입학년도 from 인적정보;
select * from 인적정보결과;

select avg(2023-substring(학번,1,4))+20 as 연령평균,
sum(2023 - substring(학번,1,4))+20 as 연령합계 from 인적정보;

### 자료선택
# 패턴을 이용한 자료 선택 : LIKE
#Use world;
#Select name from world.city where name like ‘a%’; # a로 시작하는 모든 단어
#Select name from world.city where name like ‘%a’; # a로 끝나는 모든 단어
#Select name from world.city where name like ‘%a%’; # a가 들어간 모든 단어

# random sample : 랜덤 추출

# group by : 지정한 열의 값을 동일한 수준으로 그룹화하여 결과를 도출
# pk는 group by를 할 수 없음
# country code를 기준으로 group by를 실행함

#Select *, avg(Population) from world.city group by CountryCode;
#Select *, sum(Population) from world.city group by CountryCode;
