# Agreement termination probability based on sltudents' metrics

This repository contains a project on predicting the probability of contract termination. 
The original dataset contains an extract from a database with the following characteristics.

## Features info

1. student_id - *student id*
2. student_email - *student email*
3. group_id - *education group id from LMS_DB*
4. group_title - *group's code that includes all nessecary information about duration, discipline and etc.*
5. prep_email - *teacher email*
6. date_first_l - *first lesson date*
7. feat_class - *student school class number*
8. feat_group_format - *specific format of education group*
9. feat_group_weeks - *group duration in weeks*
10. feat_group_size - *group size*
11. feat_attendance - *average lesson attendance*
12. feat_HW - *average % homework completion*
13. feat_HW_righ - *average % right homework completion*
14. feat_theory_read - *average theory read in*
15. feat_TK - *average % control test completion*
16. feat_TK_right - *average % right control test completion*
17. feat_LB - *amount of attended personal convarsations*
18. feat_tickets_we_need - *sum of service tickets*
19. feat_tickets_mb_term - *amount of service tickets due to termination chance*
20. feat_payment_type - *payment type from CRM_DB*
21. feat_payment_place - *payment place from CRM_DB*
22. feat_term_perc - *percentage of terminated contracts with the manager from CRM_DB*
23. feat_good_agr_before - *are there any not terminated agreements within a student?*
24. target - *is agreement terminated of being terminated (1 - yes; 0 - no) from CRM_DB*
25. feat_prep_attendence - *average attendance within teacher by rating*
26. feat_prep_HW - *average homework within teacher by rating*
27. feat_prep_SIM - *average teacher's exam result by rating*
28. feat_prep_OpenLessons - *average teacher's mark for open lesson by rating*

## Machine learning models
#### In this project several machine learning models were implemented:

1. **Logistic Regression**
2. **Random Forest**
3. **XGboost**
4. **Catboost**
5. **KNN**

#### To solve the problem of class imbalance different methods were used:
1. **Oversampling**
2. **Undersampling**
3. **SMOTE (Synthetic Minority Over-sampling Technique)**
4. **ADASYN (Adaptive Synthetic Sampling)**

#### To estimate models quality following metrics were used:
1. **Accuracy**
2. **Presicion**
3. **Recall**
4. **F1-score**

||Precision|Recall|F1-score|Average cross validation F1-score|
|-|-|-|-|-|
|**Logistic Regression**|0,83|0,82|0,82|0,81|
|**Random Forest**|0,83|0,83|0,83|0,824|
|**XGboost**|0,84|0,84|0,84|0,832|
|**Catboost**|0,85|0,85|0,85|**0,8406**|
|**KNN**|0,81|0,81|0,81|0,804|

**The best metrics belong to Catboost model. That is why the pipeline was implemented with this model**
