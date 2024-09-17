
--去掉完全重复的行
select distinct * into job_m from Job


--去掉实习生样本
delete from job_m
where title like '%兼职%' or salary like '%天%' or title like '%实习%' or salary like '%时%'

--去掉工资为空的样本
delete from job_m
where salary is null

SELECT * FROM job_m

--1.在表中加入新的变量 senior，
--如果工作名称中包含工程师、高级、专家、专员、研究员、资深、开发、算法等字眼
--则该变量取1，否则取0
alter table job_m
add senior nchar(10)

update job_m
set senior=1
where title like '%工程师%' or title like '%高级%'  or title like '%科学家%'
or title like '%专员%' or title like '%研究员%' or title like '%资深%' 
or  title like '%开发%' or title like '%算法%'

update job_m
set senior=0
where senior is null


--3.创建新变量jclass
alter table job_m
add jclass nchar(10)
--将机器学习、深度学习、AI等关键字都替换为人工智能

--根据职位名称中含有的关键字，对职位内容进行分类（先通过K均值直接对职业名称进行分类）
--关键词有:1.爬虫；2.数据分析；
---3.后端；4.前端；5.运维；
---6.人工智能（其中由于样本原因，机器学习、深度学习、AI关键字都被包含在内）
---7.大数据
---8.测试
---9.python（python虽然是一个岗位特征，但是有与其他技术混合，因此在处理上，选择最后再对python进行归类）
---10.其他

---可能含有多个工作类别的样本

---把AI,机器学习，深度学习，数据挖掘全部变成人工智能
update job_m
set title=replace(title,'AI','人工智能')
where title not like '%人工智能%'

update job_m
set title=replace(title,'机器学习','人工智能')
where title not like '%人工智能%'

update job_m
set title=replace(title,'深度学习','人工智能')
where title not like '%人工智能%'

update job_m
set title=replace(title,'数据挖掘','人工智能')
where title not like '%人工智能%'

select title,count(distinct(keyword)) cnt into multi_job
from job_m  left join j_keyword 
on title like CONCAT('%',keyword,'%') 
group by title having count( distinct(keyword)) >1

---经查询只有57个样本，样本数量不多，选择剔除
delete job_m
from job_m join multi_job on job_m.title=multi_job.title

---根据职位名生成工作类别
update job_m
set jclass=1
where title like '%爬虫%'

update job_m
set jclass=2
where title like '%数据分析%'

update job_m
set jclass=3
where title like '%后端%'

update job_m
set jclass=4
where title like '%前端%'

update job_m
set jclass=5
where title like '%运维%'

update job_m
set jclass=6
where title like '%人工智能%' or title like '%数据挖掘%'

update job_m
set jclass=7
where title like '%大数据%'

update job_m
set jclass=8
where title like '%测试%'

update job_m
set jclass=9
where title like '%python%'

update job_m
set jclass=10
where jclass is null


--4.创建新变量min_s_mon,max_s_mon,min_s_year,
--max_s_year,portion,y_salary
alter table job_m
add min_s_mon int ,max_s_mon int,min_s_year int,max_s_year int,portion int,y_salary int

---取出月薪份数
UPDATE job_m
SET portion =  (SUBSTRING(salary,CHARINDEX('·',salary)+1,2))
where salary like '%薪%'

UPDATE job_m
SET portion =  (select avg(portion) from job_m where salary like '%薪%')
where salary not like '%薪%' and benefits  like '%年终奖%'

UPDATE job_m
SET portion =  12
where portion is null

UPDATE job_m
SET portion = 16
where portion>=16


--将salary中薪水份数这一信息去掉，然后可以通过salary的字符长度来判断工资高低：1.A-BK,4;2.A-BCK,5;3.AB-CDK，6
UPDATE job_m
SET salary = (SUBSTRING(salary,1,CHARINDEX('K',salary)-1))
where salary like '%K%'


---取出最小月薪
UPDATE job_m
SET min_s_mon = (SUBSTRING(salary,1,CHARINDEX('-',salary)-1))

---取出最大月薪
UPDATE job_m
SET max_s_mon = ( SUBSTRING(salary,CHARINDEX('-',salary)+1,len(salary)-(CHARINDEX('-',salary))))

---用最小月薪和最大月薪分别乘以portion
UPDATE job_m
SET min_s_year = min_s_mon*portion

UPDATE job_m
SET max_s_year = max_s_mon*portion


---生成标准工资=（最大年工资-最小年工资）*0.35+最小年工资
update job_m
set y_salary=((max_s_year-min_s_year)*0.35+min_s_year)*1.0

---对工资进行1%的缩尾处理
select top 22 y_salary from job_m order by y_salary desc
select top 22 y_salary from job_m order by y_salary

update job_m
set y_salary=707
where y_salary>707

update job_m
set y_salary=40
where y_salary<40

--6.创造学历变量edu：0.大专以下/学历不限；1.大专；2.本科；3.硕士及以上
alter table job_m
add edu nchar(10)

update job_m
set edu=1
where exp like '%大专%'

update job_m
set edu=2
where exp like '%本科%'

update job_m
set edu=3
where exp like '%硕士%' or exp like '%博士%'

update job_m
set edu=0
where edu is null

--7.创造工作经验年限最低要求变量mrexp
---因为在雇佣者看来，应聘者的工作经验当然是越多越好，
---但是求职者更在乎自己是否达到最低要求，因此选择了最低要求的工作年限
UPDATE job_m
SET exp = 0
where exp like '%在校/应届%'

UPDATE job_m
SET exp = 0
where exp like '%经验不限%'

select exp from job_m 

UPDATE job_m
SET exp = replace(exp,'/','')

UPDATE job_m
SET exp = (substring( dbo.remove_hz(exp),1,1))

select exp,count(*) from job_m group by exp


--9.创造公司福利变量
---选择将股票期权（stack）、五险一金(binsurance)、补充医疗保险(minsurance)、
---带薪年假(paleave)、定期体检(fpe)作为关键词
---并最终将公司福利中提到的总福利项数-上述5项福利数作为一个关键变量ebenefit
alter table job_m
add stack int,binsurance int,minsurance int,
paleave int,fpe int,obenefit int



update job_m
set fpe=1
where benefits like '%定期体检%'
update job_m
set fpe=0
where  fpe is null

update job_m
set stack=1
where benefits like '%股票期权%'
update job_m
set stack=0
where stack is null

update job_m
set binsurance=1
where benefits like '%五险一金%'
update job_m
set binsurance=0
where  binsurance is null

update job_m
set minsurance=1
where benefits like '%补充医疗保险%'
update job_m
set minsurance=0
where  minsurance is null

update job_m
set paleave=1
where benefits like '%带薪年假%'
update job_m
set paleave=0
where  paleave is null

update job_m
set obenefit=0
where benefits is null

update job_m
set obenefit=len(benefits)-len(replace(benefits,'，',''))+1

select obenefit,count(*) from job_m group by obenefit

update job_m
set obenefit='1'
where obenefit=1 or  obenefit=2 or obenefit=3

update job_m
set obenefit='2'
where obenefit=4 or  obenefit=5 

update job_m
set obenefit='3'
where obenefit=6 

update job_m
set obenefit='4'
where obenefit=7 

update job_m
set obenefit='5'
where obenefit=8

update job_m
set obenefit='6'
where obenefit=9

update job_m
set obenefit='7'
where obenefit=10

update job_m
set obenefit='8'
where obenefit=11 

update job_m
set obenefit='9'
where obenefit=12


update job_m
set obenefit='10'
where obenefit>=13



---划分公司规模
select size from job_m group by size

update job_m
set size='0-99'
WHERE size LIKE '%0-20%' OR size LIKE '%20-99%'

update job_m
set size='100-999'
WHERE size LIKE '%100-499%' OR size LIKE '%499-999%'

update job_m
set size='1000-9999'
WHERE size LIKE '%1000-9999%' 


--10.创造城市等级变量cclass
---其中上海、北京、广州、深圳作为一线城市

---成都、重庆、杭州、武汉、苏州、西安、南京、长沙、天津、郑州、东莞、青岛、昆明、宁波、合肥作为新一线城市

---佛山、沈阳、无锡、济南、厦门、福州、温州、哈尔滨、石家庄、大连、南宁、泉州、
----金华、贵阳、常州、长春、南昌、南通、嘉兴、徐州、惠州、太原、台州、绍兴、保定、中山、
----潍坊、临沂、珠海、烟台作为二线城市

alter table job_m
add cclass nchar(10)

update job_m
set cclass=1
where area like '%上海%' or  area like '%北京%' or  area like '%广州%' or  area like '%深圳%'

update job_m
set cclass=2
where area like '%成都%' or  area like '%重庆%' or  area like '%杭州%' or  area like '%武汉%'
or  area like '%苏州%' or  area like '%西安%' or  area like '%南京%' or  area like '%长沙%'
or  area like '%天津%' or  area like '%郑州%' or  area like '%东莞%' or  area like '%青岛%'
or  area like '%昆明%' or  area like '%宁波%' or  area like '%合肥%' 

update job_m
set cclass=3
where area like '%佛山%' or  area like '%沈阳%' or  area like '%无锡%' or  area like '%济南%' 
or  area like '%厦门%' or  area like '%福州%' or  area like '%温州%' or  area like '%哈尔滨%' 
or  area like '%石家庄%' or  area like '%大连%' or  area like '%南宁%' or  area like '%泉州%'
or  area like '%金华%' or  area like '%贵阳%' or  area like '%常州%' or area like '%长春%' 
or  area like '%南昌%' or  area like '%南通%' or  area like '%嘉兴%' 
or  area like '%徐州%' or  area like '%惠州%' or  area like '%台州%' or  area like '%绍兴%' 
or  area like '%保定%' or  area like '%中山%' or  area like '%潍坊%' or  area like '%临沂%'
or  area like '%珠海%' or  area like '%烟台%' or  area like '%合肥%'

update job_m
set cclass=4
where cclass is null

select cclass,count(*) from job_m group by cclass

--10.创造行业变量变量internet:
---将公司区分为是否为信息传播、软件和信息技术服务行业（参照国民经济分类）
---定义关键词：O2O,电子商务，互联网、互联网金融、计算机服务、计算机软件、社交网络
---数据服务、信息安全、移动互联网、游戏
alter table job_m
add internet nchar(10)

update job_m
set internet=1
where field like '%O2O%' or  field like '%电子商务%' or  field like '%互联网%' or  field like '%互联网金融%' or  field like '%计算机服务%'
or  field like '%计算机软件%' or  field like '%社交网络%' or  field like '%数据服务%' or  field like '%信息安全%' or  field like '%移动互联网%'
or  field like '%游戏%' 

update job_m
set internet=0
where internet is null

select senior,y_salary,edu,exp,size,stack,binsurance,minsurance,paleave,fpe,obenefit,cclass,internet,jclass from job_m

select * from job_m where obenefit is null