<!-- 1. 查询"01"课程比"02"课程成绩高的学生的信息及课程分数 -->
SELECT
		t1.s_id,
		t1.s1,
		t2.s2
	FROM
		((
			SELECT
				s.s_id,
				s.s_score s1
			FROM
				Score s
			WHERE
				s.c_id = '01'
				) t1
			JOIN ( SELECT s.s_id, s.s_score s2 FROM Score s WHERE s.c_id = '02' ) t2 ON t1.s_id = t2.s_id
			AND t1.s1 > t2.s2
		)) tt ON st.s_id = tt.s_id;

<!-- 2. 查询"01"课程比"02"课程成绩低的学生的信息及课程分数 -->
SELECT st.*, s1.s_score AS s01, s2.s_score AS s02
FROM
	Student st
	LEFT JOIN
	Score s1 on st.s_id = s1.s_id and s1.c_id='01'
	LEFT JOIN
	Score s2 on st.s_id = s2.s_id and s2.c_id='02'
WHERE
  s1.s_score < s2.s_score;

<!-- 3. 查询平均成绩大于等于60分的同学的学生编号和学生姓名和平均成绩 -->
SELECT
	st.s_id,
	st.s_name,
	ttt.avgscore
FROM
	Student st
	JOIN ( SELECT sc.s_id, avg( sc.s_score ) AS avgscore FROM Score sc GROUP BY sc.s_id HAVING avgscore > 60 ) ttt ON st.s_id = ttt.s_id;

<!-- 4. 查询平均成绩小于60分的同学的学生编号和学生姓名和平均成绩 -- (包括有成绩的和无成绩的) -->
SELECT
	st.s_id,
	st.s_name,
	ttt.avgscore
FROM
	Student st
	JOIN ( SELECT sc.s_id, avg( sc.s_score ) AS avgscore FROM Score sc GROUP BY sc.s_id HAVING avgscore < 60 ) ttt ON st.s_id = ttt.s_id UNION
SELECT
	a.s_id,
	a.s_name,
	0 avgscore
FROM
	Student a
WHERE
	a.s_id NOT IN (
	SELECT DISTINCT
		s_id
	FROM
	Score)

<!-- 5. 查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩 -->
SELECT
	st.*,
	tt.total,
	tt.selectedNum
FROM
	Student st
	LEFT JOIN ( SELECT sc.s_id, sum( sc.s_score ) total, count( 1 ) selectedNum FROM Score sc GROUP BY sc.s_id ) tt ON st.s_id = tt.s_id;

<!-- 6. 查询"李"姓老师的数量 -->
SELECT count(1) FROM Teacher where t_name like '李%';

<!-- 7. 查询学过"张三"老师授课的同学的信息 -->
SELECT
	st.*
FROM
	Student st
	LEFT JOIN Score sc ON st.s_id = sc.s_id
	LEFT JOIN Course c ON sc.c_id = c.c_id
	LEFT JOIN Teacher t ON c.t_id = t.t_id
WHERE
	t.t_name = '张三';

<!-- 8. 查询没学过"张三"老师授课的同学的信息 -->
SELECT
	st.*
FROM
	Student st
WHERE
	st.s_id NOT IN (
	SELECT
		sc.s_id
	FROM
		Score sc
		LEFT JOIN Course c ON sc.c_id = c.c_id
		JOIN Teacher t ON c.t_id = t.t_id
	AND t.t_name = '张三'
	);

<!-- 9. 查询学过编号为"01"并且也学过编号为"02"的课程的同学的信息 -->
SELECT
	*
FROM
	Student st
WHERE
	(
	EXISTS ( SELECT * FROM Score s1 WHERE st.s_id = s1.s_id AND s1.c_id = '01' )
	AND EXISTS ( SELECT * FROM Score s1 WHERE st.s_id = s1.s_id AND s1.c_id = '02' ))

<!-- 10. 查询学过编号为"01"但是没有学过编号为"02"的课程的同学的信息-->
SELECT
	*
FROM
	Student st
WHERE
	(
	EXISTS ( SELECT * FROM Score s1 WHERE st.s_id = s1.s_id AND s1.c_id = '01' )
	AND NOT EXISTS ( SELECT * FROM Score s1 WHERE st.s_id = s1.s_id AND s1.c_id = '02' ))
