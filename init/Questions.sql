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

<!--11. 查询没有学全所有课程的同学的信息 -->
SELECT
	st.*
FROM
	Student st
WHERE
	st.s_id IN (
	SELECT
		sc.s_id
	FROM
		Score sc
	GROUP BY
		sc.s_id
	HAVING
	COUNT( sc.c_id ) < ( SELECT count( 1 ) FROM Course ));

<!-- 12. 查询至少有一门课与学号为"01"的同学所学相同的同学的信息  -->
SELECT
	st.*
FROM
	Student st
WHERE
	EXISTS (
	SELECT DISTINCT
		ss.s_id
	FROM
		Score ss
	WHERE
		ss.c_id IN ( SELECT sc.c_id FROM Score sc WHERE sc.s_id = '01' )
		AND ss.s_id != '01'
	AND st.s_id = ss.s_id)

<!-- 13. 查询和"01"号的同学学习的课程完全相同的其他同学的信息 -->
SELECT
	st.*
FROM
	Student st
WHERE
	st.s_id IN (
	SELECT DISTINCT
		so.s_id
	FROM
		Score so
	WHERE
		so.s_id != '01'
		AND so.c_id IN ( SELECT sc.c_id FROM Score sc WHERE sc.s_id = '01' )
	GROUP BY
		so.s_id
HAVING
	count( 1 ) = ( SELECT count( 1 ) FROM Score WHERE s_id = '01' ));
<!-- 14. 查询没学过"张三"老师讲授的任一门课程的学生姓名 -->
SELECT
	st.*
FROM
	Student st
WHERE
	st.s_id NOT IN (
	SELECT DISTINCT
		so.s_id
	FROM
		Score so
	WHERE
		so.c_id IN (
		SELECT
			c.c_id
		FROM
			Course c
	WHERE
	c.t_id = ( SELECT t.t_id FROM Teacher t WHERE t.t_name = '张三' )));
<!-- 15. 查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩 -->
SELECT
	st.s_id,
	st.s_name,
	round( tt.avgScore )
FROM
	Student st
	JOIN (
	SELECT
		sc.s_id,
		count( 1 ) AS num,
		avg( sc.s_score ) AS avgScore
	FROM
		Score sc
	WHERE
		sc.s_score < 60 GROUP BY sc.s_id HAVING num >= 2
	) AS tt ON st.s_id = tt.s_id;
<!-- 16. 检索"01"课程分数小于60，按分数降序排列的学生信息 -->
SELECT
	st.*,
	t.s_score
FROM
	Student st
	RIGHT JOIN ( SELECT sc.* FROM Score sc WHERE sc.s_score < 60 AND sc.c_id = '01' ORDER BY sc.s_score DESC ) t ON st.s_id = t.s_id;

<!-- 17. 按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩 -->
SELECT
	so.s_id,
	so.s_score,
	t.avgScore
FROM
	Score so
	RIGHT JOIN (
	SELECT
		sc.s_id,
		avg( sc.s_score ) avgScore
	FROM
		Score sc
	GROUP BY
		sc.s_id
	ORDER BY
	avg( sc.s_score ) DESC
	) t ON so.s_id = t.s_id

<!-- 18. 查询各科成绩最高分、最低分和平均分：以如下形式显示：课程ID，课程name，最高分，最低分，平均分，及格率，中等率，优良率，优秀率
--及格为>=60，中等为：70-80，优良为：80-90，优秀为：>=90-->
Select c.c_name,t.* FROM Course c join
(Select sc.c_id, max(sc.s_score) as 最高分,min(sc.s_score) as 最低分,avg(sc.s_score) as 平均分,
100 * (SUM(case when sc.s_score>=60 then 1 else 0 end)/SUM(case when sc.s_score then 1 else 0 end)) as 及格率,
100 * (SUM(case when sc.s_score>=70 then 1 else 0 end)/SUM(case when sc.s_score then 1 else 0 end)) as 中等率,
100 * (SUM(case when sc.s_score>=80 then 1 else 0 end)/SUM(case when sc.s_score then 1 else 0 end)) as 优良率,
100 * (SUM(case when sc.s_score>=90 then 1 else 0 end)/SUM(case when sc.s_score then 1 else 0 end)) as 优秀率
FROM Score sc group by sc.c_id) t on c.c_id=t.c_id order by 及格率 desc;
<!-- 19. 按各科成绩进行排序，并显示排名 -->
<!-- 20. 查询学生的总成绩并进行排名-->
SELECT
	@i := @i + 1 AS i,
	a.*
FROM
	( SELECT sc.s_id, sum( sc.s_score ) total FROM Score sc GROUP BY sc.s_id ORDER BY total DESC ) a,
	( SELECT @i := 0 ) s;