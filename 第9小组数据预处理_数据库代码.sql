
--ȥ����ȫ�ظ�����
select distinct * into job_m from Job


--ȥ��ʵϰ������
delete from job_m
where title like '%��ְ%' or salary like '%��%' or title like '%ʵϰ%' or salary like '%ʱ%'

--ȥ������Ϊ�յ�����
delete from job_m
where salary is null

SELECT * FROM job_m

--1.�ڱ��м����µı��� senior��
--������������а�������ʦ���߼���ר�ҡ�רԱ���о�Ա������������㷨������
--��ñ���ȡ1������ȡ0
alter table job_m
add senior nchar(10)

update job_m
set senior=1
where title like '%����ʦ%' or title like '%�߼�%'  or title like '%��ѧ��%'
or title like '%רԱ%' or title like '%�о�Ա%' or title like '%����%' 
or  title like '%����%' or title like '%�㷨%'

update job_m
set senior=0
where senior is null


--3.�����±���jclass
alter table job_m
add jclass nchar(10)
--������ѧϰ�����ѧϰ��AI�ȹؼ��ֶ��滻Ϊ�˹�����

--����ְλ�����к��еĹؼ��֣���ְλ���ݽ��з��ࣨ��ͨ��K��ֱֵ�Ӷ�ְҵ���ƽ��з��ࣩ
--�ؼ�����:1.���棻2.���ݷ�����
---3.��ˣ�4.ǰ�ˣ�5.��ά��
---6.�˹����ܣ�������������ԭ�򣬻���ѧϰ�����ѧϰ��AI�ؼ��ֶ����������ڣ�
---7.������
---8.����
---9.python��python��Ȼ��һ����λ������������������������ϣ�����ڴ����ϣ�ѡ������ٶ�python���й��ࣩ
---10.����

---���ܺ��ж��������������

---��AI,����ѧϰ�����ѧϰ�������ھ�ȫ������˹�����
update job_m
set title=replace(title,'AI','�˹�����')
where title not like '%�˹�����%'

update job_m
set title=replace(title,'����ѧϰ','�˹�����')
where title not like '%�˹�����%'

update job_m
set title=replace(title,'���ѧϰ','�˹�����')
where title not like '%�˹�����%'

update job_m
set title=replace(title,'�����ھ�','�˹�����')
where title not like '%�˹�����%'

select title,count(distinct(keyword)) cnt into multi_job
from job_m  left join j_keyword 
on title like CONCAT('%',keyword,'%') 
group by title having count( distinct(keyword)) >1

---����ѯֻ��57�������������������࣬ѡ���޳�
delete job_m
from job_m join multi_job on job_m.title=multi_job.title

---����ְλ�����ɹ������
update job_m
set jclass=1
where title like '%����%'

update job_m
set jclass=2
where title like '%���ݷ���%'

update job_m
set jclass=3
where title like '%���%'

update job_m
set jclass=4
where title like '%ǰ��%'

update job_m
set jclass=5
where title like '%��ά%'

update job_m
set jclass=6
where title like '%�˹�����%' or title like '%�����ھ�%'

update job_m
set jclass=7
where title like '%������%'

update job_m
set jclass=8
where title like '%����%'

update job_m
set jclass=9
where title like '%python%'

update job_m
set jclass=10
where jclass is null


--4.�����±���min_s_mon,max_s_mon,min_s_year,
--max_s_year,portion,y_salary
alter table job_m
add min_s_mon int ,max_s_mon int,min_s_year int,max_s_year int,portion int,y_salary int

---ȡ����н����
UPDATE job_m
SET portion =  (SUBSTRING(salary,CHARINDEX('��',salary)+1,2))
where salary like '%н%'

UPDATE job_m
SET portion =  (select avg(portion) from job_m where salary like '%н%')
where salary not like '%н%' and benefits  like '%���ս�%'

UPDATE job_m
SET portion =  12
where portion is null

UPDATE job_m
SET portion = 16
where portion>=16


--��salary��нˮ������һ��Ϣȥ����Ȼ�����ͨ��salary���ַ��������жϹ��ʸߵͣ�1.A-BK,4;2.A-BCK,5;3.AB-CDK��6
UPDATE job_m
SET salary = (SUBSTRING(salary,1,CHARINDEX('K',salary)-1))
where salary like '%K%'


---ȡ����С��н
UPDATE job_m
SET min_s_mon = (SUBSTRING(salary,1,CHARINDEX('-',salary)-1))

---ȡ�������н
UPDATE job_m
SET max_s_mon = ( SUBSTRING(salary,CHARINDEX('-',salary)+1,len(salary)-(CHARINDEX('-',salary))))

---����С��н�������н�ֱ����portion
UPDATE job_m
SET min_s_year = min_s_mon*portion

UPDATE job_m
SET max_s_year = max_s_mon*portion


---���ɱ�׼����=������깤��-��С�깤�ʣ�*0.35+��С�깤��
update job_m
set y_salary=((max_s_year-min_s_year)*0.35+min_s_year)*1.0

---�Թ��ʽ���1%����β����
select top 22 y_salary from job_m order by y_salary desc
select top 22 y_salary from job_m order by y_salary

update job_m
set y_salary=707
where y_salary>707

update job_m
set y_salary=40
where y_salary<40

--6.����ѧ������edu��0.��ר����/ѧ�����ޣ�1.��ר��2.���ƣ�3.˶ʿ������
alter table job_m
add edu nchar(10)

update job_m
set edu=1
where exp like '%��ר%'

update job_m
set edu=2
where exp like '%����%'

update job_m
set edu=3
where exp like '%˶ʿ%' or exp like '%��ʿ%'

update job_m
set edu=0
where edu is null

--7.���칤�������������Ҫ�����mrexp
---��Ϊ�ڹ�Ӷ�߿�����ӦƸ�ߵĹ������鵱Ȼ��Խ��Խ�ã�
---������ְ�߸��ں��Լ��Ƿ�ﵽ���Ҫ�����ѡ�������Ҫ��Ĺ�������
UPDATE job_m
SET exp = 0
where exp like '%��У/Ӧ��%'

UPDATE job_m
SET exp = 0
where exp like '%���鲻��%'

select exp from job_m 

UPDATE job_m
SET exp = replace(exp,'/','')

UPDATE job_m
SET exp = (substring( dbo.remove_hz(exp),1,1))

select exp,count(*) from job_m group by exp


--9.���칫˾��������
---ѡ�񽫹�Ʊ��Ȩ��stack��������һ��(binsurance)������ҽ�Ʊ���(minsurance)��
---��н���(paleave)���������(fpe)��Ϊ�ؼ���
---�����ս���˾�������ᵽ���ܸ�������-����5�������Ϊһ���ؼ�����ebenefit
alter table job_m
add stack int,binsurance int,minsurance int,
paleave int,fpe int,obenefit int



update job_m
set fpe=1
where benefits like '%�������%'
update job_m
set fpe=0
where  fpe is null

update job_m
set stack=1
where benefits like '%��Ʊ��Ȩ%'
update job_m
set stack=0
where stack is null

update job_m
set binsurance=1
where benefits like '%����һ��%'
update job_m
set binsurance=0
where  binsurance is null

update job_m
set minsurance=1
where benefits like '%����ҽ�Ʊ���%'
update job_m
set minsurance=0
where  minsurance is null

update job_m
set paleave=1
where benefits like '%��н���%'
update job_m
set paleave=0
where  paleave is null

update job_m
set obenefit=0
where benefits is null

update job_m
set obenefit=len(benefits)-len(replace(benefits,'��',''))+1

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



---���ֹ�˾��ģ
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


--10.������еȼ�����cclass
---�����Ϻ������������ݡ�������Ϊһ�߳���

---�ɶ������졢���ݡ��人�����ݡ��������Ͼ�����ɳ�����֣�ݡ���ݸ���ൺ���������������Ϸ���Ϊ��һ�߳���

---��ɽ�����������������ϡ����š����ݡ����ݡ���������ʯ��ׯ��������������Ȫ�ݡ�
----�𻪡����������ݡ��������ϲ�����ͨ�����ˡ����ݡ����ݡ�̫ԭ��̨�ݡ����ˡ���������ɽ��
----Ϋ�������ʡ��麣����̨��Ϊ���߳���

alter table job_m
add cclass nchar(10)

update job_m
set cclass=1
where area like '%�Ϻ�%' or  area like '%����%' or  area like '%����%' or  area like '%����%'

update job_m
set cclass=2
where area like '%�ɶ�%' or  area like '%����%' or  area like '%����%' or  area like '%�人%'
or  area like '%����%' or  area like '%����%' or  area like '%�Ͼ�%' or  area like '%��ɳ%'
or  area like '%���%' or  area like '%֣��%' or  area like '%��ݸ%' or  area like '%�ൺ%'
or  area like '%����%' or  area like '%����%' or  area like '%�Ϸ�%' 

update job_m
set cclass=3
where area like '%��ɽ%' or  area like '%����%' or  area like '%����%' or  area like '%����%' 
or  area like '%����%' or  area like '%����%' or  area like '%����%' or  area like '%������%' 
or  area like '%ʯ��ׯ%' or  area like '%����%' or  area like '%����%' or  area like '%Ȫ��%'
or  area like '%��%' or  area like '%����%' or  area like '%����%' or area like '%����%' 
or  area like '%�ϲ�%' or  area like '%��ͨ%' or  area like '%����%' 
or  area like '%����%' or  area like '%����%' or  area like '%̨��%' or  area like '%����%' 
or  area like '%����%' or  area like '%��ɽ%' or  area like '%Ϋ��%' or  area like '%����%'
or  area like '%�麣%' or  area like '%��̨%' or  area like '%�Ϸ�%'

update job_m
set cclass=4
where cclass is null

select cclass,count(*) from job_m group by cclass

--10.������ҵ��������internet:
---����˾����Ϊ�Ƿ�Ϊ��Ϣ�������������Ϣ����������ҵ�����չ��񾭼÷��ࣩ
---����ؼ��ʣ�O2O,�������񣬻����������������ڡ���������񡢼����������罻����
---���ݷ�����Ϣ��ȫ���ƶ�����������Ϸ
alter table job_m
add internet nchar(10)

update job_m
set internet=1
where field like '%O2O%' or  field like '%��������%' or  field like '%������%' or  field like '%����������%' or  field like '%���������%'
or  field like '%��������%' or  field like '%�罻����%' or  field like '%���ݷ���%' or  field like '%��Ϣ��ȫ%' or  field like '%�ƶ�������%'
or  field like '%��Ϸ%' 

update job_m
set internet=0
where internet is null

select senior,y_salary,edu,exp,size,stack,binsurance,minsurance,paleave,fpe,obenefit,cclass,internet,jclass from job_m

select * from job_m where obenefit is null