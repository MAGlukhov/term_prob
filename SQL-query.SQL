-- attached query with homework and attendance
WITH 
  	lesson_performance AS 
    (
    SELECT 
		lla.student_user_id student_id,
	    ll.education_group_id group_id,
	    round(uniqExactIf(lla.id, lla.type != 'missed') / COUNTDistinct(lla.id), 2) attendance, 
	    round(AVG(multiIf(toDate(skbs.created_at) = '1970-01-01', 0, 1)),2) theory_read
    FROM   
      	dwh.lms_lesson_attendance lla -- attendance table
    JOIN 
      	dwh.lms_lesson ll ON ll.id = lla.lesson_id -- lesson table for group id info
    JOIN 
      	dwh.lms_education_group leg ON ll.education_group_id = leg.id -- group table for course id info
    JOIN 
      	dwh.lms_education_course lec ON leg.education_course_id = lec.id -- course table
    JOIN 
     	dwh.lms_education_subject les ON lec.education_subject_id = les.id -- education subject table
    JOIN
      	dwh.lms_subject ls ON les.subject_id = ls.id -- subject table
    JOIN 
      	dwh.lms_lesson_curriculum_subject llcs ON ll.id = llcs.lesson_id -- table with education plan
    JOIN 
      	dwh.lms_curriculum_subject_knowledge_base_section kbs ON llcs.curriculum_subject_id = kbs.curriculum_subject_id -- base_section table
    LEFT JOIN
      	dwh.lms_student_knowledge_base_section skbs ON lla.student_user_id = skbs.student_user_id AND skbs.knowledge_base_section_id = kbs.knowledge_base_section_id  -- theory reading table
    WHERE 
      	leg.first_lesson_start_at BETWEEN '2020-09-01' AND '2024-08-30'
    GROUP BY 
      	lla.student_user_id,
      	ll.education_group_id
    ),
-- attached query with homework
  	HW_table AS 
    (
    SELECT
		student_id_HW,
	    group_id_HW,
	    AVG(HW) AS avg_HW, -- average homework completion
	    AVG(HW_right) AS avg_HW_right -- average right homework completion
	FROM
		(
		SELECT 
			lla.student_user_id student_id_HW,
		    ll.education_group_id group_id_HW,
		    ll.title l_title,
		    lcs.title theme_title,
		    round(AVG(CASE 
		        	  	  WHEN str.education_subject_type LIKE '%App\\Models\\CurriculumSubject%' THEN 1
		          	  	  ELSE 0
		        	  END),2) HW,
		    round(CAST(sum(str.percent) AS float) 
		    							   	     / CAST(count(*) AS float),2) HW_right
		FROM   
			dwh.lms_lesson_attendance lla -- attendance table
		JOIN 
		    dwh.lms_lesson ll ON ll.id = lla.lesson_id -- lesson table for group id info
		JOIN 
		    dwh.lms_education_group leg ON ll.education_group_id = leg.id -- group table for course id info
		JOIN 
		    dwh.lms_lesson_curriculum_subject llcs ON ll.id = llcs.lesson_id -- table with education plan
		JOIN 
		    dwh.lms_curriculum_subject lcs ON llcs.curriculum_subject_id = lcs.id -- education subject table
		JOIN 
		    dwh.lms_curriculum_subject_education_test cset ON lcs.id = cset.curriculum_subject_id -- all platform test table
		LEFT JOIN 
		    dwh.lms_student_test_result str ON lla.student_user_id = str.student_id AND cset.education_test_id = str.education_test_id AND lcs.id = str.education_subject_id
		WHERE 
		    leg.first_lesson_start_at BETWEEN '2020-09-01' AND '2024-08-30'
		GROUP BY 
		    lla.student_user_id,
		    ll.education_group_id,
		    ll.title,
		    lcs.title
		)
	GROUP BY
		student_id_HW,
    	group_id_HW
    ),
-- attached query with control tests
    TK_table AS
   	(
   	SELECT 
		student_id_TK,
		group_id_TK,
		round(AVG(CASE
				      WHEN toDate(solv_date) = '1970-01-01' THEN 0
			   	      ELSE 1
			      END),2) TK_solved, -- tests solved
		round(AVG(CASE 
					  WHEN TK_right = 0 THEN NULL
				      ELSE TK_right
			      END) 
					  / 100,2) TK_right -- tests solved right. if null then 0
	FROM
		(
		SELECT
			lla.student_user_id student_id_TK,
			ll.education_group_id group_id_TK,
			ll.title l_title,
			les.title TK_title,
			lse.max_points TK_max_points,
			lse.student_points TK_stud_points,
			lse.test_points_percent TK_right,
			lses.created_at solv_date
		FROM   
		    dwh.lms_lesson_attendance lla -- attendance table
		JOIN 
		    dwh.lms_lesson ll ON ll.id = lla.lesson_id -- lesson table for group id info
		JOIN 
		    dwh.lms_education_group leg ON ll.education_group_id = leg.id -- group table for course id info
		JOIN 
		    dwh.lms_lesson_curriculum_subject llcs ON ll.id = llcs.lesson_id -- table with education plan
		JOIN 
		    dwh.lms_curriculum_subject lcs ON llcs.curriculum_subject_id = lcs.id -- education subject table
		LEFT JOIN 
		    dwh.lms_lesson_exam_subject lles ON ll.id = lles.lesson_id -- lesson_exam_subject table
		LEFT JOIN 
			dwh.lms_exam_subjects les ON lles.exam_subject_id = les.id -- exam_subject table
		LEFT JOIN 
			dwh.lms_student_exam_subjects lses ON lla.student_user_id = lses.student_id  AND ll.id = lses.lesson_id AND les.id = lses.exam_subject_id -- exam table
		LEFT JOIN 
			dwh.lms_student_exams lse ON lla.student_user_id = lse.student_id AND ll.id = lse.lesson_id AND ll.education_group_id = lse.education_group_id AND les.id = lse.exam_subject_id -- student answers table
		WHERE 
		    leg.first_lesson_start_at BETWEEN '2020-09-01' AND '2024-08-30'
		AND empty(les.title) = 0
		GROUP BY 
			lla.student_user_id,
		    ll.education_group_id,
		    ll.title,
		   	les.title, 
		   	lse.max_points,
		   	lse.student_points,
		   	lse.test_points_percent,
		   	lses.created_at
		)
GROUP BY 
	student_id_TK,
	group_id_TK
   	)
-- MAIN QUERY
SELECT 
	u.id student_id, -- student id 
  	u.email student_email, -- student email 
  	leg.id group_id, -- group id
  	leg.title group_title, -- group title
	u2.email prep_email, -- prep_email 
  	leg.first_lesson_start_at date_first_l, -- date of first lesson 
  	count(*) over (partition by leg.id) feat_group_size, -- feature group size
  	lp.attendance feat_attendance, -- feature attandence
  	avg_HW feat_HW,  -- feature HW
  	(avg_HW_right / 100) feat_HW_right,  -- feature right HW 
  	lp.theory_read feat_theory_read, -- feature theore_read
  	TK.TK_solved feat_TK, -- feature avg TK solved
  	TK.TK_right feat_TK_right, -- feature avg TK right
  	LB.sum_pc feat_LB, -- feature LB
  	tickets.tickets_call_we_need feat_tickets_we_need, -- feature tickets we need
  	tickets.tickets_mb_term feat_tickets_mb_term, -- feature tickets_mb_term
  	CRM.payment_type feat_payment_type, -- feature payment_type
  	CRM.payment_place feat_payment_place, -- feature paymen_place
  	CRM.term_percent feat_term_perc, -- feature term_perc
  	CRM.good_agr_before feat_good_agr_before, -- feature good_agr_before
  	CRM.target target -- target term
FROM 
  	dwh.lms_users u -- users table from LMS_BD
LEFT JOIN 
 	HW_table HW ON u.id = HW.student_id_HW -- таблица с ДЗ
JOIN
  	dwh.lms_education_group leg ON HW.group_id_HW = leg.id -- table to connect group id and group info
LEFT JOIN
	dwh.lms_users u2 ON leg.curator_user_id = u2.id -- lms users table for teachers
JOIN 
  	lesson_performance lp ON u.id = lp.student_id AND leg.id = lp.group_id -- table with student's attendance and homework
JOIN 
	TK_table TK ON u.id = TK.student_id_TK AND leg.id = TK.group_id_TK
-- Embedded query with personal conversation
JOIN
	(
  	SELECT
    	pc.student_id student_id,
    	pc.education_group_id group_id,
    	sum(CASE
      			WHEN pc.attendance_status = 'visited' then 1
      			ELSE 0
      		END) sum_pc
  	FROM 
    	dwh.lms_new_personal_conversations as pc
  	GROUP BY
    	pc.student_id,
    	pc.education_group_id
  	) LB ON u.id = LB.student_id AND leg.id = LB.group_id
-- Embedded query with service tickets
LEFT JOIN
	(
	SELECT
		tm.stud_id stud_id,
	    tm.eg_id eg_id,
	    sum(CASE 
		    	WHEN
		           tm.tick_theme = 'Ученик не делает ДЗ 0-60%'
		        OR tm.tick_theme = 'Ученик не делает ДЗ 60-80%'
		        OR tm.tick_theme = 'Ученик пропускает занятия 75-85%'
		        OR tm.tick_theme = 'Ученик пропускает занятия 0-75%'
		        OR tm.tick_theme = 'Ученик не выходит на связь'
		        OR tm.tick_theme = 'Ученик не написал ТК/СИМ'
		        OR tm.tick_theme = 'Ученик не прошел порог симуляции'
		        OR tm.tick_theme = 'Ученик пропустил индивидуальное занятие'
		        OR tm.tick_theme = 'Звонок родителям'
		        OR tm.tick_theme = 'Звонок родителям по успеваемости/нужно их уточнение' THEN 1
	       		ELSE 0
	       END) tickets_call_we_need, -- tickets sum
	    sum(CASE 
		    	WHEN 
	           	   tm.tick_theme = 'Подозрение на расторжение' THEN 1
	         	ELSE 0
	        END) tickets_mb_term -- tickets due to termination chance
	 FROM 
	 	lms.dpp_tickets_mv tm -- tickets tables
	 GROUP BY
	    tm.stud_id,
	    tm.eg_id
	  ) tickets on u.id = tickets.stud_id AND leg.id = tickets.eg_id
-- Embedded query with CRM info
JOIN 
	(
	SELECT
	cma.max_student_contactid as crm_id, -- CRM id as key part
	cmg.new_educationgroupid as max_group_code, -- group code as key part 
CASE
	when cma.max_paymenttypelist == 809720000 then 'Позтапная' 
	when cma.max_paymenttypelist == 809720001 then 'Единовременная' 
	when cma.max_paymenttypelist == 809720002 then 'Рекуррентная' 
	when cma.max_paymenttypelist == 809720003 then 'Paccpoчка банка'
	when cma.max_paymenttypelist == 809720004 then 'Kомбо'
	when cma.max_paymenttypelist == 809720005 then 'Материнский капитал'
	when cma.max_paymenttypelist == 694440000 then 'Буст'
	when cma.max_paymenttypelist == 694440001 then 'Бронирование'
END as payment_type, -- payment type
CASE
	when cma.statuscode == 1 then 'Oткpыто'
	when cma.statuscode == 809720000 then 'Заключено'
	when cma.statuscode == 809720001 then 'Заморожено (приостановлено оказание услуг)' 
	when cma.statuscode == 809720005 then 'Ha pасторжении'
	when cma.statuscode == 2 then '3авершено (оказание услуг)'
	when cma.statuscode == 809720002 then 'Oтменено'
	when cma.statuscode == 809720006 then 'Paсторжение'
	when cma.statuscode == 809720007 then 'Texнический перевод' 
	when cma.statuscode == 809720008 then 'Нe oплачен'
	when cma.statuscode == 809720009 then 'Oшибка менеджерa' 
END as agreement_status, -- agreement status
CASE
	when cma.max_payment_place == 809720000 then 'ИK'
	when cma.max_payment_place == 809720001 then 'ДОД' 
	when cma.max_payment_place == 809720002 then 'Cайт' 
	when cma.max_payment_place == 809720003 then 'Cepвep' 
	when cma.max_payment_place == 100000000 then 'Навигатор' 
END as payment_place, -- payment place
t1.term_percent as term_percent, -- percentage of terminated contracts with the manager from CRM_DB
CASE 
	WHEN cma.statuscode == 809720005 OR cma.statuscode == 809720006 THEN 1 
	else 0
END AS target, -- is agreement terminated of being terminated (1 - yes; 0 - no) from CRM_DB
CASE
	when t2.good_agr > 0 then 1
	else 0
END as good_agr_before, -- are there any not terminated agreements within a student?
CASE
	when t2.bad_agr > 0 then 1
	else 0
END as termination_case -- are there any cases within a student?
FROM dwh.crm_max_agreement as cma
INNER JOIN dwh.crm_max_group cmg ON cma.max_groupid = cmg.id -- crm group table
INNER JOIN (SELECT 
				DISTINCT cma.max_manager_systemuseridname as manager,
				COUNT(DISTINCT CASE WHEN cma.statuscode == 2 OR cma.statuscode == 809720000 OR cma.statuscode == 809720001 THEN cma.id END) AS good_agr,
				COUNT(DISTINCT CASE WHEN cma.statuscode == 809720005  OR cma.statuscode == 	809720006 THEN cma.id END) AS bad_agr,
				bad_agr / (good_agr +  bad_agr) * 100 as term_percent
			FROM dwh.crm_max_agreement cma
			WHERE date(cma.createdon) > '2021-01-01'
			GROUP BY cma.max_manager_systemuseridname) as t1 -- terminated contracts with the manager
ON cma.max_manager_systemuseridname = t1.manager
INNER JOIN (SELECT 
				DISTINCT cc.id as contact_id,
				COUNT(DISTINCT CASE WHEN cma.statuscode == 2 OR cma.statuscode == 809720000 OR cma.statuscode == 809720001 THEN cma.id END) AS good_agr,
				COUNT(DISTINCT CASE WHEN cma.statuscode == 809720005  OR cma.statuscode == 	809720006 THEN cma.id END) AS bad_agr
			FROM dwh.crm_contact cc 
			INNER JOIN dwh.crm_max_agreement cma ON cc.id = cma.max_student_contactid
			WHERE max_contractamount >= 5000
				and date(cma.createdon) > '2021-01-01'
			GROUP BY cc.id) as t2 -- not terminated agreements within a student
ON t2.contact_id = cma.max_student_contactid 
WHERE date(cma.createdon) BETWEEN '2020-09-01' AND '2024-08-30' -- data filter
	) CRM on u.crm_uuid = CRM.crm_id AND toString(leg.id) = toString(CRM.max_group_code)
-- FILTERS
WHERE
		u.email NOT LIKE '%@maximumtest.ru' -- excluding teachers
	AND u.email NOT LIKE '%@test%' -- excluding tests
	AND match (leg.title, '[а-яА-Я]') = 0 -- excludig cirrilic names
	AND leg.title NOT LIKE '%\\_gr'  AND leg.title NOT LIKE '%\\_mah' AND leg.title NOT LIKE '%\\_naz' -- excluding Caucasus
	AND leg.title NOT LIKE 'spo\\_%' -- excluding college
	AND leg.title NOT LIKE 'prp\\_%' -- excluding career development of teenagers
	AND leg.title NOT LIKE '%\\_asyn\\_%' -- excluding asyncronised groups
	AND leg.title NOT LIKE '%dgt\\_%' -- excluding digital skills group
	AND leg.title NOT LIKE '%\\_ingos\\_%' -- excluding Ingostrah
	AND leg.title NOT LIKE '%pers\\_%' -- excluding 1vs1
	AND leg.title NOT LIKE 'nav\\_%' -- excluding skill cources
	AND leg.title NOT LIKE '%test%' -- excluding test groups
	AND leg.title NOT LIKE '%corp%' -- excluding corporate courses
	AND leg.title NOT LIKE '%\\_6\\_%' AND leg.title NOT LIKE '%\\_7\\_%' AND leg.title NOT LIKE '%\\_8\\_%' AND leg.title NOT LIKE '%\\_5\\_%'-- excluding 6,7,8 classes
	AND leg.title NOT LIKE '%mix%' -- excluding mixed formats
	AND leg.title NOT LIKE '%Salehard%' -- excluding Salehard
	AND leg.title NOT LIKE '%easy%' -- excluding Easy
	AND leg.title NOT LIKE '%\\_tripwire\\_%' AND leg.title NOT LIKE '%\\_intro\\_%' AND leg.title NOT LIKE '%\\_free\\_%' -- excluding tripwires and intro courses
	AND leg.title NOT LIKE '%\\_sumsch%' AND leg.title NOT LIKE '%\\_winsch\\_%' AND leg.title NOT LIKE '%\\_maxaugust_\\_%' AND leg.title NOT LIKE '%\\_maxjuly_\\_%' AND leg.title NOT LIKE '%\\_maxjune_\\_%'-- excluding summer and winter school
	AND leg.title NOT LIKE '%\\_marathon\\_%' -- excluding marathon groups
	AND leg.title NOT LIKE '%\\_sobes\\_%' AND leg.title NOT LIKE '%is\\_normal\\_%'-- excluding interviews
	AND leg.first_lesson_start_at BETWEEN '2020-09-01' AND '2024-08-30'
	ORDER BY 
  leg.title