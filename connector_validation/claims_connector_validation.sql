select
    0 as metric_id,
    'medical claim: count of records in input layer' as metric_name,
    count(*) as metric_value
from input_layer.medical_claim

union all

select
    1 as metric_id,
    'medical claim: count of records in core' as metric_name,
    count(*) as metric_value
from core.medical_claim

union all

select
    2 as metric_id,
    'pharmacy claim: count of records in input layer' as metric_name,
    count(*) as metric_value
from input_layer.pharmacy_claim

union all

select
    3 as metric_id,
    'pharmacy claim: count of records in core' as metric_name,
    count(*) as metric_value
from core.pharmacy_claim

union all

select
    4 as metric_id,
    'eligibility: count of records in input layer' as metric_name,
    count(*) as metric_value
from input_layer.eligibility

union all

select
    5 as metric_id,
    'eligibility: count of records in core' as metric_name,
    count(*) as metric_value
from core.eligibility

union all

-- Percent of Institutional Claims in Input Layer
select
    6 as metric_id,
    'medical claim: percent institutional in input layer' as metric_name,
    round(
        sum(case when claim_type = 'institutional' then 1 else 0 end) * 100.0 / count(*),
        2
    ) as metric_value
from input_layer.medical_claim

union all

-- Percent of Institutional Claims in Core
select
    7 as metric_id,
    'medical claim: percent institutional in core' as metric_name,
    round(
        sum(case when claim_type = 'institutional' then 1 else 0 end) * 100.0 / count(*),
        2
    ) as metric_value
from core.medical_claim

union all

-- Percent of Professional Claims in Input Layer
select
    8 as metric_id,
    'medical claim: percent professional in input layer' as metric_name,
    round(
        sum(case when claim_type = 'professional' then 1 else 0 end) * 100.0 / count(*),
        2
    ) as metric_value
from input_layer.medical_claim

union all
-- Percent of Professional Claims in Core
select
    9 as metric_id,
    'medical claim: percent professional in core' as metric_name,
    round(
        sum(case when claim_type = 'professional' then 1 else 0 end) * 100.0 / count(*),
        2
    ) as metric_value
from core.medical_claim

union all

select
    10 as metric_id,
    'ahrq_measures.pqi_denom_long: count of records' as metric_name,
    count(*) as metric_value
from ahrq_measures.pqi_denom_long

union all

select
    11 as metric_id,
    'ahrq_measures.pqi_exclusion_long: count of records' as metric_name,
    count(*) as metric_value
from ahrq_measures.pqi_exclusion_long

union all

select
    12 as metric_id,
    'ahrq_measures.pqi_num_long: count of records' as metric_name,
    count(*) as metric_value
from ahrq_measures.pqi_num_long

union all

select
    13 as metric_id,
    'ahrq_measures.pqi_rate: count of records' as metric_name,
    count(*) as metric_value
from ahrq_measures.pqi_rate

union all

select
    14 as metric_id,
    'ahrq_measures.pqi_summary: count of records' as metric_name,
    count(*) as metric_value
from ahrq_measures.pqi_summary

union all

select
    15 as metric_id,
    'ccsr.long_condition_category: count of records' as metric_name,
    count(*) as metric_value
from ccsr.long_condition_category

union all

select
    16 as metric_id,
    'ccsr.long_procedure_category: count of records' as metric_name,
    count(*) as metric_value
from ccsr.long_procedure_category

union all

select
    17 as metric_id,
    'ccsr.singular_condition_category: count of records' as metric_name,
    count(*) as metric_value
from ccsr.singular_condition_category

union all

select
    18 as metric_id,
    'chronic_conditions.cms_chronic_conditions_long: count of records' as metric_name,
    count(*) as metric_value
from chronic_conditions.cms_chronic_conditions_long

union all

select
    19 as metric_id,
    'chronic_conditions.cms_chronic_conditions_wide: count of records' as metric_name,
    count(*) as metric_value
from chronic_conditions.cms_chronic_conditions_wide

union all

select
    20 as metric_id,
    'chronic_conditions.tuva_chronic_conditions_long: count of records' as metric_name,
    count(*) as metric_value
from chronic_conditions.tuva_chronic_conditions_long

union all

select
    21 as metric_id,
    'chronic_conditions.tuva_chronic_conditions_wide: count of records' as metric_name,
    count(*) as metric_value
from chronic_conditions.tuva_chronic_conditions_wide

union all

select
    22 as metric_id,
    'cms_hcc.patient_risk_factors: count of records' as metric_name,
    count(*) as metric_value
from cms_hcc.patient_risk_factors

union all

select
    23 as metric_id,
    'cms_hcc.patient_risk_factors_monthly: count of records' as metric_name,
    count(*) as metric_value
from cms_hcc.patient_risk_factors_monthly

union all

select
    24 as metric_id,
    'cms_hcc.patient_risk_scores: count of records' as metric_name,
    count(*) as metric_value
from cms_hcc.patient_risk_scores

union all

select
    25 as metric_id,
    'cms_hcc.patient_risk_scores_monthly: count of records' as metric_name,
    count(*) as metric_value
from cms_hcc.patient_risk_scores_monthly

union all

select
    26 as metric_id,
    'ed_classification.summary: count of records' as metric_name,
    count(*) as metric_value
from ed_classification.summary

union all

select
    27 as metric_id,
    'financial_pmpm.pmpm_prep: count of records' as metric_name,
    count(*) as metric_value
from financial_pmpm.pmpm_prep

union all

select
    28 as metric_id,
    'financial_pmpm.pmpm_payer_plan: count of records' as metric_name,
    count(*) as metric_value
from financial_pmpm.pmpm_payer_plan

union all

select
    29 as metric_id,
    'financial_pmpm.pmpm_payer: count of records' as metric_name,
    count(*) as metric_value
from financial_pmpm.pmpm_payer

union all

select
    30 as metric_id,
    'hcc_suspecting.list: count of records' as metric_name,
    count(*) as metric_value
from hcc_suspecting.list

union all

select
    31 as metric_id,
    'hcc_suspecting.list_rollup: count of records' as metric_name,
    count(*) as metric_value
from hcc_suspecting.list_rollup

union all

select
    32 as metric_id,
    'hcc_suspecting.summary: count of records' as metric_name,
    count(*) as metric_value
from hcc_suspecting.summary

union all

select
    33 as metric_id,
    'pharmacy.brand_generic_opportunity: count of records' as metric_name,
    count(*) as metric_value
from pharmacy.brand_generic_opportunity

union all

select
    34 as metric_id,
    'pharmacy.generic_available_list: count of records' as metric_name,
    count(*) as metric_value
from pharmacy.generic_available_list

union all

select
    35 as metric_id,
    'pharmacy.pharmacy_claim_expanded: count of records' as metric_name,
    count(*) as metric_value
from pharmacy.pharmacy_claim_expanded

union all

select
    36 as metric_id,
    'quality_measures.summary_counts: count of records' as metric_name,
    count(*) as metric_value
from quality_measures.summary_counts

union all

select
    37 as metric_id,
    'quality_measures.summary_long: count of records' as metric_name,
    count(*) as metric_value
from quality_measures.summary_long

union all

select
    38 as metric_id,
    'quality_measures.summary_wide: count of records' as metric_name,
    count(*) as metric_value
from quality_measures.summary_wide

union all

select
    39 as metric_id,
    'readmissions.readmission_summary: count of records' as metric_name,
    count(*) as metric_value
from readmissions.readmission_summary

union all

select
    40 as metric_id,
    'readmissions.encounter_augmented: count of records' as metric_name,
    count(*) as metric_value
from readmissions.encounter_augmented;

