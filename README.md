# Agreement termination probability based on sltudents' metrics

This repository contains a project on predicting the probability of contract termination. 
The original dataset contains an extract from a database with the following characteristics.

## Features info

1. student_id_lms - student id from LMS_DB                                                            
2. courses_count - amount of paid courses student has
3. group_id - education group id from LMS_DB
4. group_code - group's code that includes all nessecary information about duration, discipline and etc.
5. course_title - course's name 
6. subject_title - education discipline
7. group_format - specific format of an education group
8. class - class number
9. group_size - amount of students in a group
10. avg_attendance - average lesson attendance
11. avg_theory_read - average theory read in 
12. homework_avg_percent - average % homework completion
13. homework_avg_percent2 - average % homework completion with alternative calculation
14. right_homework_avg_percent - average % right homework completion
15. right_homework_avg_percent2 - average % right homework completion with alternative calculation
16. goal_filled - filling of the goal in a personal account
17. lb_count - amount of attended personal convarsations
18. teacher_id_lms - teacher id from LMS_DB
19. created_date - user creation date in LMS_DB
20. student_email - student's email
21. student_phone - student's phone number
22. last_enter - date of the last enter on the platform
23. activity - date of the last activity on the platform
24. city_id - city id from LMS_DB
25. external_id - unknown field
26. student_crm_id - student CRM id from LMS_BD as a primaty key for CRM_BD
27. year_graduation_id - graduation year from school
28. tickets_no_hw - amount of service tickets because of poor homework completion
29. tickets_no_attendance - amount of service tickets because of poor attendance
30. tickets_no_connect - amount of service tickets because of no contact
31. tickets_no_TK - amount of service tickets because of ignoring of control works
32. tickets_mb_term - amount of service tickets due to termination chance
33. tickets_fiacko_on_simulation - amount of service tickets due to bad results on important tests
34. tickets_fiacko_fold_1by1 - amount of service tickets due to 1vs1 lesson skip
35. tickets_call_to_parents - amount of service tickets to make a call to parents
36. tickets_call_we_need - sum of all tickets
37. TK_solved_per - average % control test completion
38. AVG_TK_verno - average % right test completion
39. payment_type - payment type from CRM_DB
40. agreement_status - agreement status from CRM_DB
41. payment_place - payment place from CRM_DB
42. term_percent_man - percentage of terminated contracts with the manager from CRM_DB
43. target - is agreement terminated of being terminated (1 - yes; 0 - no) from CRM_DB
44. termination_case - are there any termaniton cases within the student from CRM_DB
