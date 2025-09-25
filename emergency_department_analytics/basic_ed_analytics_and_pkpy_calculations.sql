


-- ***************************************************************
-- This CTE gives us the number of member_months corresponding
-- to each data_source, year_month:
-- ***************************************************************
with member_months_by_year_month_and_data_source as (
select
  data_source,
  year_month,
  sum(member_months) as member_months
from financial_pmpm.pmpm_payer
group by data_source, year_month
),



-- ***************************************************************
-- This CTE gives all ED encounters, both standalone ED encounters
-- and ED encounters that led to an inpatient admission:
-- ***************************************************************
all_ed_encounters as (
select
  aa.*,
  to_char(aa.encounter_start_date, 'YYYYMM') AS year_month,

-- This flag is 1 when the encounter is a standalone ED encounter,
-- as opposed to an ED encounter that led to an inpatient admission:
  case
    when aa.encounter_type = 'emergency department' then 1
    else 0
  end as solo_ed_encounter,

-- This flag is 1 when there were members with enrollment
-- on the year_month corresponding to the encounter:
  case
    when bb.member_months is not null then 1
    else 0
  end as year_month_has_member_months
  
from core.encounter aa
left join member_months_by_year_month_and_data_source bb
on aa.data_source = bb.data_source
and to_char(aa.encounter_start_date, 'YYYYMM') = bb.year_month

-- We only look at ED encounters coming from claims for the purpose
-- of analyzing spend and utilization PMPM and PKPY, for which we need
-- claims enrollment data to compute member months:
where aa.encounter_source_type = 'claim'
and
-- This grabs both solo ED encounters & inpatient encoutners that had an ED component:
(aa.encounter_type = 'emergency department' or aa.ed_flag = 1)
),



-- ***************************************************************
-- This CTE gives us the raw count of each type of ED encounter
-- (standalone ED encounters, ED encounters that led to inpatient admission,
-- and total ED encounters) trending by year_month:
-- ***************************************************************
ed_encounters_by_year_month as (
select
  data_source,
  year_month,
  sum(solo_ed_encounter) as count_of_solo_ed_encounters,
  sum(ed_flag) as count_of_ed_encounters_with_admission,
  count(*) as count_of_all_ed_encounters,
  max(year_month_has_member_months) as year_month_has_member_months
from all_ed_encounters
group by year_month, data_source
),



-- ***************************************************************
-- This CTE gives us the raw count of each type of ED encounter
-- (standalone ED encounters, ED encounters that led to inpatient admission,
-- and total ED encounters) trending by year_month, but it also 
-- gives us the number of member months of enrollment we have for each year_month
-- as well as the number of ED encounters PKPY for each type of
-- ED encounter:
-- ***************************************************************
ed_encounters_by_year_month_pkpy as (
select
  aa.data_source,
  aa.year_month,
  aa.count_of_solo_ed_encounters,
  aa.count_of_ed_encounters_with_admission,
  aa.count_of_all_ed_encounters,
  aa.year_month_has_member_months,
  
  bb.member_months,

  case
    when bb.member_months is not null
    then round(aa.count_of_solo_ed_encounters * 12000.0 / bb.member_months, 2)
    else null
  end as solo_ed_encounters_pkpy,

  case
    when bb.member_months is not null
    then round(aa.count_of_ed_encounters_with_admission * 12000.0 / bb.member_months, 2)
    else null
  end as ed_encounters_with_admission_pkpy,

  case
    when bb.member_months is not null
    then round(aa.count_of_all_ed_encounters * 12000.0 / bb.member_months, 2)
    else null
  end as all_ed_encounters_pkpy

  
from ed_encounters_by_year_month aa
left join member_months_by_year_month_and_data_source bb
on aa.data_source = bb.data_source
and aa.year_month = bb.year_month
),



-- ***************************************************************
-- This CTE gives us the total counts of different types of ED
-- encounters (standalone ED encounters, ED encounters that led to inpatient admission,
-- and total ED encounters) as well as the number of ED encounters PKPY
-- for each type ED encounter for the whole time period covered in our dataset
-- (i.e. for the whole time period for which we had member enrollment):
-- ***************************************************************
metrics_for_the_whole_time_period as (
select
  data_source,
  sum(count_of_all_ed_encounters) as total_ed_encounters,
  sum(count_of_solo_ed_encounters) as ed_encounters_without_inpatient_admission,
  sum(count_of_ed_encounters_with_admission) as ed_encounters_with_inpatient_admission,
  sum(member_months) as member_months_for_time_period,

  round(sum(count_of_all_ed_encounters) * 12000.0
          / sum(member_months) , 2) as total_ed_encounters_pkpy,

  round(sum(count_of_solo_ed_encounters) * 12000.0
          / sum(member_months) , 2) as ed_encounters_without_inpatient_admission_pkpy,

  round(sum(count_of_ed_encounters_with_admission) * 12000.0
          / sum(member_months) , 2) as ed_encounters_with_inpatient_admission_pkpy

from ed_encounters_by_year_month_pkpy
where member_months is not null

group by data_source
),



-- ***************************************************************
-- This CTE is used to select the name of the data source
-- for which we want to calcualte ED Analytics metrics in the
-- 'summary_table' CTE below.
-- Replace 'name_of_data_source_to_calculate_metrics_on' with the name
-- of the data_source for which you want to run ED Analytics metrics
-- in the summary_table:
-- ***************************************************************
selected_data_source as (
select 'name_of_data_source_to_calculate_metrics_on' as selected_data_source
),



-- ***************************************************************
-- This CTE gives a summary table showing a variety of basic
-- ED Visit Analytics metrics for a data_source of interest:
-- ***************************************************************
summary_table as (
select
  0 as metric_id,
  'Count of ED encounters:' as metric_name,
  null as metric_value



union all




select
  1 as metric_id,
  'Total ED Encounters PKPY' as metric_name,
  (select total_ed_encounters_pkpy
   from metrics_for_the_whole_time_period
   where data_source =
   (select selected_data_source from selected_data_source)) as metric_value 



union all



select
  2 as metric_id,
  'ED Encounters without inpatient admission PKPY' as metric_name,
  (select ed_encounters_without_inpatient_admission_pkpy
   from metrics_for_the_whole_time_period
   where data_source =
   (select selected_data_source from selected_data_source)) as metric_value 



union all



select
  3 as metric_id,
  'ED Encounters with inpatient admission PKPY' as metric_name,
  (select ed_encounters_with_inpatient_admission_pkpy
   from metrics_for_the_whole_time_period
   where data_source =
   (select selected_data_source from selected_data_source)) as metric_value 



union all



select
  4 as metric_id,
  '(ED encounters without inpatient admission) / (total ED encounters) * 100' as metric_name,
  (select round( ed_encounters_without_inpatient_admission * 100.0 / total_ed_encounters , 2)
   from metrics_for_the_whole_time_period
   where data_source =
   (select selected_data_source from selected_data_source)) as metric_value 



union all



select
  5 as metric_id,
  '(ED encounters with inpatient admission) / (total ED encounters) * 100' as metric_name,
  (select round( ed_encounters_with_inpatient_admission * 100.0 / total_ed_encounters , 2)
   from metrics_for_the_whole_time_period
   where data_source =
   (select selected_data_source from selected_data_source)) as metric_value



union all



select
  6 as metric_id,
  '------------------------------' as metric_name,
  null as metric_value



union all



select
  7 as metric_id,
  'Distribution of encounter types for ED encounters with inpatient admission:',
  null as metric_value



union all



select
  8 as metric_id,
  'acute inpatient %',
  round(
  (select count(*)
  from all_ed_encounters
  where encounter_type = 'acute inpatient') * 100.0 /
  (select count(*)
   from all_ed_encounters
   where ed_flag = 1) , 2 ) as metric_value



union all



select
  9 as metric_id,
  'inpatient hospice %',
  round(
  (select count(*)
  from all_ed_encounters
  where encounter_type = 'inpatient hospice') * 100.0 /
  (select count(*)
   from all_ed_encounters
   where ed_flag = 1) , 2 ) as metric_value



union all



select
  10 as metric_id,
  'inpatient long term acute care %',
  round(
  (select count(*)
  from all_ed_encounters
  where encounter_type = 'inpatient long term acute care') * 100.0 /
  (select count(*)
   from all_ed_encounters
   where ed_flag = 1) , 2 ) as metric_value



union all



select
  11 as metric_id,
  'inpatient psych %',
  round(
  (select count(*)
  from all_ed_encounters
  where encounter_type = 'inpatient psych') * 100.0 /
  (select count(*)
   from all_ed_encounters
   where ed_flag = 1) , 2 ) as metric_value



union all



select
  12 as metric_id,
  'inpatient rehabilitation %',
  round(
  (select count(*)
  from all_ed_encounters
  where encounter_type = 'inpatient rehabilitation') * 100.0 /
  (select count(*)
   from all_ed_encounters
   where ed_flag = 1) , 2 ) as metric_value



union all



select
  13 as metric_id,
  'inpatient skilled nursing %',
  round(
  (select count(*)
  from all_ed_encounters
  where encounter_type = 'inpatient skilled nursing') * 100.0 /
  (select count(*)
   from all_ed_encounters
   where ed_flag = 1) , 2 ) as metric_value



union all



select
  14 as metric_id,
  'inpatient substance use %',
  round(
  (select count(*)
  from all_ed_encounters
  where encounter_type = 'inpatient substance use') * 100.0 /
  (select count(*)
   from all_ed_encounters
   where ed_flag = 1) , 2 ) as metric_value



union all



select
  15 as metric_id,
  '------------------------------' as metric_name,  
  null as metric_value



union all



select
  16 as metric_id,
  'LOS histogram for ED encounters without inpatient admission:',
  null as metric_value



union all



select
  17 as metric_id,
  'LOS = 0 %',
  round(
  (select count(*)
  from all_ed_encounters   
  where solo_ed_encounter = 1 and length_of_stay = 0) * 100.0 /
  (select count(*)
   from all_ed_encounters
   where solo_ed_encounter = 1) , 2 ) as metric_value



union all



select
  18 as metric_id,
  'LOS = 1 %',
  round(
  (select count(*)
  from all_ed_encounters
  where solo_ed_encounter = 1 and length_of_stay = 1) * 100.0 /
  (select count(*)
   from all_ed_encounters
   where solo_ed_encounter = 1) , 2 ) as metric_value



union all



select
  19 as metric_id,
  'LOS = 2 %',
  round(
  (select count(*)
  from all_ed_encounters
  where solo_ed_encounter = 1 and length_of_stay = 2) * 100.0 /
  (select count(*)
   from all_ed_encounters
   where solo_ed_encounter = 1) , 2 ) as metric_value



union all



select
  20 as metric_id,
  'LOS = 3 %',
  round(
  (select count(*)
  from all_ed_encounters
  where solo_ed_encounter = 1 and length_of_stay = 3) * 100.0 /
  (select count(*)
   from all_ed_encounters
   where solo_ed_encounter = 1) , 2 ) as metric_value



union all



select
  21 as metric_id,
  'LOS = 4 %',
  round(
  (select count(*)
  from all_ed_encounters
  where solo_ed_encounter = 1 and length_of_stay = 4) * 100.0 /
  (select count(*)
   from all_ed_encounters
   where solo_ed_encounter = 1) , 2 ) as metric_value



union all



select
  22 as metric_id,
  'LOS = 5 %',
  round(
  (select count(*)
  from all_ed_encounters
  where solo_ed_encounter = 1 and length_of_stay = 5) * 100.0 /
  (select count(*)
   from all_ed_encounters
   where solo_ed_encounter = 1) , 2 ) as metric_value



union all



select
  23 as metric_id,
  'LOS = 6 %',
  round(
  (select count(*)
  from all_ed_encounters
  where solo_ed_encounter = 1 and length_of_stay = 6) * 100.0 /
  (select count(*)
   from all_ed_encounters
   where solo_ed_encounter = 1) , 2 ) as metric_value



union all



select
  24 as metric_id,
  'LOS = 7 %',
  round(
  (select count(*)
  from all_ed_encounters
  where solo_ed_encounter = 1 and length_of_stay = 7) * 100.0 /
  (select count(*)
   from all_ed_encounters
   where solo_ed_encounter = 1) , 2 ) as metric_value



union all



select
  25 as metric_id,
  'LOS = 8 %',
  round(
  (select count(*)
  from all_ed_encounters
  where solo_ed_encounter = 1 and length_of_stay = 8) * 100.0 /
  (select count(*)
   from all_ed_encounters
   where solo_ed_encounter = 1) , 2 ) as metric_value



union all



select
  26 as metric_id,
  'LOS = 9 %',
  round(
  (select count(*)
  from all_ed_encounters
  where solo_ed_encounter = 1 and length_of_stay = 9) * 100.0 /
  (select count(*)
   from all_ed_encounters
   where solo_ed_encounter = 1) , 2 ) as metric_value



union all



select
  27 as metric_id,
  'LOS = 10 %',
  round(
  (select count(*)
  from all_ed_encounters
  where solo_ed_encounter = 1 and length_of_stay = 10) * 100.0 /
  (select count(*)
   from all_ed_encounters
   where solo_ed_encounter = 1) , 2 ) as metric_value



union all



select
  28 as metric_id,
  'LOS > 10 %',
  round(
  (select count(*)
  from all_ed_encounters
  where solo_ed_encounter = 1 and length_of_stay > 10) * 100.0 /
  (select count(*)
   from all_ed_encounters
   where solo_ed_encounter = 1) , 2 ) as metric_value



union all



select
  29 as metric_id,
  '------------------------------' as metric_name,  
  null as metric_value



union all



select
  30 as metric_id,
  'ED Spend:' as metric_name,
  null as metric_value



union all



select
  31 as metric_id,
  'ED Spend PMPM (using service categories)' as metric_name,
  round(
  (select sum(emergency_department_paid * member_months)
   from financial_pmpm.pmpm_payer
   where member_months is not null) /
  (select sum(member_months)
   from financial_pmpm.pmpm_payer
   where member_months is not null)
  , 2) as metric_value



union all



select
  32 as metric_id,
  'Medical Spend PMPM (using service categories)' as metric_name,
  round(
  (select sum(medical_paid * member_months)
   from financial_pmpm.pmpm_payer
   where member_months is not null) /
  (select sum(member_months)
   from financial_pmpm.pmpm_payer
   where member_months is not null)
  , 2) as metric_value



union all



select
  33 as metric_id,
  'Total Spend PMPM (using service categories)' as metric_name,
  round(
  (select sum(total_paid * member_months)
   from financial_pmpm.pmpm_payer
   where member_months is not null) /
  (select sum(member_months)
   from financial_pmpm.pmpm_payer
   where member_months is not null)
  , 2) as metric_value



union all



select
  34 as metric_id,
  '(ED Spend / Medical Spend) * 100.0' as metric_name,
  round(
  (select sum(emergency_department_paid)
   from financial_pmpm.pmpm_payer
   where member_months is not null) * 100.0 /
  (select sum(medical_paid)
   from financial_pmpm.pmpm_payer
   where member_months is not null) 
  , 2) as metric_value



union all



select
  35 as metric_id,
  '(ED Spend / Total Spend) * 100.0' as metric_name,
  round(
  (select sum(emergency_department_paid)
   from financial_pmpm.pmpm_payer
   where member_months is not null) * 100.0 /
  (select sum(total_paid)
   from financial_pmpm.pmpm_payer
   where member_months is not null) 
  , 2) as metric_value



union all



select
  36 as metric_id,
  'ED Spend PMPM (using ED encounters without inpatient admission)' as metric_name,
  round(
  (select sum(paid_amount)
   from all_ed_encounters
   where year_month_has_member_months = 1 and solo_ed_encounter = 1)  /
  (select sum(member_months)
   from member_months_by_year_month_and_data_source)
  , 2) as metric_value



union all



select
  37 as metric_id,
  '------------------------------' as metric_name,  
  null as metric_value



union all



select
  38 as metric_id,
  'Ambulance utilization for ED visits:' as metric_name,
  null as metric_value



union all



select
  39 as metric_id,
  'ED encounters without inpatient admission: % with ambulance_flag = 0' as metric_name,
  round(
  (select count(*)
   from all_ed_encounters
   where ambulance_flag = 0 and solo_ed_encounter = 1) * 100.0 /
  (select count(*)
   from all_ed_encounters
   where solo_ed_encounter = 1)
  , 2) as metric_value



union all



select
  40 as metric_id,
  'ED encounters without inpatient admission: % with ambulance_flag = 1' as metric_name,
  round(
  (select count(*)
   from all_ed_encounters
   where ambulance_flag = 1 and solo_ed_encounter = 1) * 100.0 /
  (select count(*)
   from all_ed_encounters
   where solo_ed_encounter = 1)
  , 2) as metric_value



union all



select
  41 as metric_id,
  'ED encounters with inpatient admission: % with ambulance_flag = 0' as metric_name,
  round(
  (select count(*)
   from all_ed_encounters
   where ambulance_flag = 0 and solo_ed_encounter = 0) * 100.0 /
  (select count(*)
   from all_ed_encounters
   where solo_ed_encounter = 0)
  , 2) as metric_value



union all



select
  42 as metric_id,
  'ED encounters with inpatient admission: % with ambulance_flag = 1' as metric_name,
  round(
  (select count(*)
   from all_ed_encounters
   where ambulance_flag = 1 and solo_ed_encounter = 0) * 100.0 /
  (select count(*)
   from all_ed_encounters
   where solo_ed_encounter = 0)
  , 2) as metric_value



union all



select
  43 as metric_id,
  'Total ED encounters: % with ambulance_flag = 0' as metric_name,
  round(
  (select count(*)
   from all_ed_encounters
   where ambulance_flag = 0) * 100.0 /
  (select count(*)
   from all_ed_encounters)
  , 2) as metric_value



union all



select
  44 as metric_id,
  'Total ED encounters: % with ambulance_flag = 1' as metric_name,
  round(
  (select count(*)
   from all_ed_encounters
   where ambulance_flag = 1) * 100.0 /
  (select count(*)
   from all_ed_encounters)
  , 2) as metric_value




)


