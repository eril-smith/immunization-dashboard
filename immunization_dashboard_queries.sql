/*
Objectives
Come up with flu shots dashboard for 2022 that does that following

1.) Total % of patients getting flu shots stratified by
	a.) Age
	b.) Race
	c.) County (On a Map)
	d.) Overall
2.) Running Total of Flu Shots over the course of 2022
3.) Total number of Flu Shots given in 2022
4.) A list of Patients that show whether or not they received the flu shots

Requirements:
Patients must be "Active at our hospital"
*note that flu shots are recommended for patients 6 months or older
*/

with active_patients as
(
	select distinct patient
	from encounters as e
	join patients as pat 
		on e.patient = pat.id
	where start between '2020-01-01 00:00' and '2022-12-31 23:59'
		and pat.deathdate is null
		and extract(EPOCH from age('2022-12-31',pat.birthdate)/259200) >=6
),

flu_shot_2022 as 
(
select patient, min(date) as earliest_flu_shot_2022 
from immunizations
where code = '5302'
	and date between '2022-01-01 00:00' and '2022-12-31 23:59'
group by patient
)

select pat.birthdate
	,extract(YEAR FROM age('12-31-2022', birthdate)) as age
	,pat.race
	,pat.county
	,pat.id
	,pat.first
	,pat.last
	,flu.earliest_flu_shot_2022
	,case when flu.patient is not null then 1
	else 0
	end as flu_shot_2022
	,pat.income
	,pat.healthcare_expenses
	,pat.healthcare_coverage
	,(pat.healthcare_expenses/(pat.healthcare_expenses+pat.healthcare_coverage)) as hc_expenses_ratio
from patients as pat
left join flu_shot_2022 as flu
	on pat.id = flu.patient
where 1=1
	and pat.id in (select patient from active_patients)

