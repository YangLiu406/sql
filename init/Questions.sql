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

<!-- 21. 查询不同老师所教不同课程平均分从高到低显示 -->
SELECT
	t.t_name,
	c.c_name,
	pjf
FROM
	Teacher t
	JOIN Course c ON t.t_id = c.t_id
	RIGHT JOIN ( SELECT sc.c_id, avg( sc.s_score ) AS pjf FROM Score sc GROUP BY sc.c_id ORDER BY pjf DESC ) ss ON ss.c_id = c.c_id;

<!-- 22. 查询所有课程的成绩第2名到第3名的学生信息及该课程成绩  -->
SELECT
	st.*,
	tt.c_id,
	tt.ordinal,
	tt.s_score
FROM
	(
	SELECT
		sc.s_id,
		sc.c_id,
		@i := @i + 1 AS ordinal,
		sc.s_score
	FROM
		Score sc,(
		SELECT
			@i := 0
		) i
	WHERE
		sc.c_id = '01'
	ORDER BY
		sc.s_score DESC
	) tt
	LEFT JOIN Student st ON st.s_id = tt.s_id
WHERE
	tt.ordinal BETWEEN 2
	AND 3 UNION
SELECT
	st.*,
	tt.c_id,
	tt.ordinal,
	tt.s_score
FROM
	(
	SELECT
		sc.s_id,
		sc.c_id,
		@j := @j + 1 AS ordinal,
		sc.s_score
	FROM
		Score sc,(
		SELECT
			@j := 0
		) i
	WHERE
		sc.c_id = '02'
	ORDER BY
		sc.s_score DESC
	) tt
	LEFT JOIN Student st ON st.s_id = tt.s_id
WHERE
	tt.ordinal BETWEEN 2
	AND 3 UNION
	(
	SELECT
		st.*,
		tt.c_id,
		tt.ordinal,
		tt.s_score
	FROM
		(
		SELECT
			sc.s_id,
			sc.c_id,
			@k := @k + 1 AS ordinal,
			sc.s_score
		FROM
			Score sc,(
			SELECT
				@k := 0
			) i
		WHERE
			sc.c_id = '03'
		ORDER BY
			sc.s_score DESC
		) tt
		LEFT JOIN Student st ON st.s_id = tt.s_id
	WHERE
		tt.ordinal BETWEEN 2
	AND 3)

<!-- 23. 统计各科成绩各分数段人数：课程编号,课程名称,[100-85],[85-70],[70-60],[0-60]及所占百分比 -->
SELECT
	c.c_name,
	ttt.*
FROM
	(
	SELECT
		COUNT( 1 ) AS 人数,
		sc.c_id,
		SUM( CASE WHEN sc.s_score < 60 THEN 1 ELSE 0 END ) AS 不及格,
		ROUND( 100 * SUM( CASE WHEN sc.s_score < 60 THEN 1 ELSE 0 END )/ COUNT( 1 ), 2 ) AS 不及格率,
		SUM( CASE WHEN sc.s_score >= 60 AND sc.s_score < 70 THEN 1 ELSE 0 END ) AS 中等,
		ROUND(
			100 * SUM( CASE WHEN sc.s_score >= 60 AND sc.s_score < 70 THEN 1 ELSE 0 END )/ COUNT( 1 ),
			2
		) AS 中等率,
		SUM( CASE WHEN sc.s_score >= 70 AND sc.s_score < 85 THEN 1 ELSE 0 END ) AS 良等,
		ROUND(
			100 * SUM( CASE WHEN sc.s_score >= 70 AND sc.s_score < 85 THEN 1 ELSE 0 END )/ COUNT( 1 ),
			2
		) AS 良等率,
		SUM( CASE WHEN sc.s_score >= 85 AND sc.s_score <= 100 THEN 1 ELSE 0 END ) AS 优等,
		ROUND(
			100 * SUM( CASE WHEN sc.s_score >= 85 AND sc.s_score <= 100 THEN 1 ELSE 0 END )/ COUNT( 1 ),
			2
		) AS 优等率
	FROM
		Score sc
	WHERE
		sc.c_id = '01' UNION
	SELECT
		COUNT( 1 ) AS 人数,
		sc.c_id,
		SUM( CASE WHEN sc.s_score < 60 THEN 1 ELSE 0 END ) AS 不及格,
		ROUND( 100 * SUM( CASE WHEN sc.s_score < 60 THEN 1 ELSE 0 END )/ COUNT( 1 ), 2 ) AS 不及格率,
		SUM( CASE WHEN sc.s_score >= 60 AND sc.s_score < 70 THEN 1 ELSE 0 END ) AS 中等,
		ROUND(
			100 * SUM( CASE WHEN sc.s_score >= 60 AND sc.s_score < 70 THEN 1 ELSE 0 END )/ COUNT( 1 ),
			2
		) AS 中等率,
		SUM( CASE WHEN sc.s_score >= 70 AND sc.s_score < 85 THEN 1 ELSE 0 END ) AS 良等,
		ROUND(
			100 * SUM( CASE WHEN sc.s_score >= 70 AND sc.s_score < 85 THEN 1 ELSE 0 END )/ COUNT( 1 ),
			2
		) AS 良等率,
		SUM( CASE WHEN sc.s_score >= 85 AND sc.s_score <= 100 THEN 1 ELSE 0 END ) AS 优等,
		ROUND(
			100 * SUM( CASE WHEN sc.s_score >= 85 AND sc.s_score <= 100 THEN 1 ELSE 0 END )/ COUNT( 1 ),
			2
		) AS 优等率
	FROM
		Score sc
	WHERE
		sc.c_id = '02' UNION
	SELECT
		COUNT( 1 ) AS 人数,
		sc.c_id,
		SUM( CASE WHEN sc.s_score < 60 THEN 1 ELSE 0 END ) AS 不及格,
		ROUND( 100 * SUM( CASE WHEN sc.s_score < 60 THEN 1 ELSE 0 END )/ COUNT( 1 ), 2 ) AS 不及格率,
		SUM( CASE WHEN sc.s_score >= 60 AND sc.s_score < 70 THEN 1 ELSE 0 END ) AS 中等,
		ROUND(
			100 * SUM( CASE WHEN sc.s_score >= 60 AND sc.s_score < 70 THEN 1 ELSE 0 END )/ COUNT( 1 ),
			2
		) AS 中等率,
		SUM( CASE WHEN sc.s_score >= 70 AND sc.s_score < 85 THEN 1 ELSE 0 END ) AS 良等,
		ROUND(
			100 * SUM( CASE WHEN sc.s_score >= 70 AND sc.s_score < 85 THEN 1 ELSE 0 END )/ COUNT( 1 ),
			2
		) AS 良等率,
		SUM( CASE WHEN sc.s_score >= 85 AND sc.s_score <= 100 THEN 1 ELSE 0 END ) AS 优等,
		ROUND(
			100 * SUM( CASE WHEN sc.s_score >= 85 AND sc.s_score <= 100 THEN 1 ELSE 0 END )/ COUNT( 1 ),
			2
		) AS 优等率
	FROM
		Score sc
	WHERE
		sc.c_id = '03'
	) ttt
	JOIN Course c ON ttt.c_id = c.c_id;
<!-- 24. 查询学生平均成绩及其名次  -->
SELECT t.s_id, t.平均分,( @i := @i + 1 ) AS 排名
FROM
	( SELECT sc.s_id, avg( sc.s_score ) AS 平均分 FROM Score sc GROUP BY sc.s_id ORDER BY 平均分 DESC ) t,
	( SELECT @i := 0 ) i
ORDER BY
	排名
<!-- 25. 查询各科成绩前三名的记录
            -- 1.选出b表比a表成绩大的所有组
            -- 2.选出比当前id成绩大的 小于三个的 -->

<!-- 26. 查询每门课程被选修的学生数  -->
Select c_id,count(1) from Score group by c_id;
<!-- 27. 查询出只有两门课程的全部学生的学号和姓名 -->
SELECT
	st.s_name,
	st.s_id
FROM
	Student st
	LEFT JOIN Score sc ON st.s_id = sc.s_id
GROUP BY
	sc.s_id
HAVING
	count(*) = 2;
<!-- 28. 查询男生、女生人数 -->
SELECT
	SUM( CASE WHEN st.s_sex = '男' THEN 1 ELSE 0 END ) AS 男,
	SUM( CASE WHEN st.s_sex = '女' THEN 1 ELSE 0 END ) AS 女
FROM
	Student st;
<!-- 29. 查询名字中含有"风"字的学生信息 -->
SELECT * FROM Student WHERE s_name LIKE '%风%';
<!-- 30. 查询同名同性学生名单，并统计同名人数 -->
SELECT
	a.s_name,
	a.s_sex,
	count(*)
FROM
	Student a
	JOIN Student b ON a.s_id != b.s_id
	AND a.s_name = b.s_name
	AND a.s_sex = b.s_sex
GROUP BY
	a.s_name,
	a.s_sex

<!-- 31.查询1990年出生的学生名单  -->
Select * FROM Student where s_birth like '1990%';
<!-- 32.查询每门课程的平均成绩，结果按平均成绩降序排列，平均成绩相同时，按课程编号升序排列  -->
SELECT
	sc.c_id,
	ROUND( avg( sc.s_score ), 2 ) avgs
FROM
	Score sc
GROUP BY
	sc.c_id
ORDER BY
	avgs DESC,
	c_id ASC;
<!-- 33.查询平均成绩大于等于85的所有学生的学号、姓名和平均成绩  -->
SELECT
	st.s_id,
	st.s_name,
	avg( sc.s_score ) avgs
FROM
	Student st
	JOIN Score sc ON st.s_id = sc.s_id
GROUP BY
	sc.s_id
HAVING
	avgs >= 85
<!-- 34.查询课程名称为"数学"，且分数低于60的学生姓名和分数  -->
SELECT
	st.s_name,
	sc.s_score,
	c.c_name
FROM
	Score sc
	LEFT JOIN Course c ON sc.c_id = c.c_id
	LEFT JOIN Student st ON sc.s_id = st.s_id
WHERE
	c.c_name = '数学'
	AND sc.s_score < 60
<!-- 35.查询所有学生的课程及分数情况 -->
Select sc.s_id,
SUM(case sc.c_id when '01' then sc.s_score else 0 end) as a,
SUM(case sc.c_id when '02' then sc.s_score else 0 end) as b,
SUM(case sc.c_id when '03' then sc.s_score else 0 end) as c,
SUM(sc.s_score) as total
FROM Student st join Score sc on st.s_id=sc.s_id group by sc.s_id
<!-- 36.查询任何一门课程成绩在70分以上的姓名、课程名称和分数 -->
SELECT DISTINCT
	st.s_name,
	scc.s_score,
	c.c_name
FROM
	Student st
	JOIN Score scc ON st.s_id = scc.s_id
	JOIN Course c ON scc.c_id = c.c_id
WHERE
	scc.s_score > 70
<!-- 37.查询不及格的课程 -->
Select sc.s_id, sc.s_score, c.c_id,c.c_name FROM Score sc join Course c on sc.c_id=c.c_id WHERE sc.s_score < 60


<!-- 38.查询课程编号为01且课程成绩在80分以上的学生的学号和姓名 -->
Select st.s_id, st.s_name FROM Student st
WHERE st.s_id in
	(Select sc.s_id FROM Score sc WHERE sc.c_id='01' and sc.s_score>=80)

<!-- 39.求每门课程的学生人数 -->
Select sc.c_id, count(1) FROM Score sc group by sc.c_id

<!-- 40.查询选修"张三"老师所授课程的学生中，成绩最高的学生信息及其成绩 -->
SELECT
	st.*,
	so.s_score
FROM
	Student st
	JOIN Score so ON st.s_id = so.s_id
WHERE
	so.c_id IN ( SELECT c.c_id FROM Course c LEFT JOIN Teacher t ON c.t_id = t.t_id WHERE t.t_name = '张三' )
	AND so.s_score IN (
	SELECT
		max( sc.s_score )
	FROM
		Score sc
	WHERE
		sc.c_id IN ( SELECT c.c_id FROM Course c LEFT JOIN Teacher t ON c.t_id = t.t_id WHERE t.t_name = '张三' )
	GROUP BY
	sc.c_id)


-- 41 查询不同课程成绩相同的学生的学生编号、课程编号、学生成绩
select DISTINCT b.s_id,b.c_id,b.s_Score from Score a,Score b where a.c_id != b.c_id and a.s_Score = b.s_Score

-- 42、查询每门功成绩最好的前两名
        -- 牛逼的写法
SELECT
	a.s_id,
	a.c_id,
	a.s_score
FROM
	Score a
WHERE
	( SELECT COUNT( 1 ) FROM Score b WHERE a.c_id = b.c_id AND a.s_score <= b.s_score ) <= 2
ORDER BY
	a.c_id;
-- 43、统计每门课程的学生选修人数（超过5人的课程才统计）。要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列
SELECT
	sc.c_id,
	count( 1 ) num
FROM
	Score sc
GROUP BY
	sc.c_id
HAVING
	num >= 5
ORDER BY
	num DESC,
	sc.c_id ASC;

-- 44、检索至少选修两门课程的学生学号
Select sc.s_id FROM Score sc group by sc.s_id having count(1) >= 2;
-- 45、查询选修了全部课程的学生信息
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
	count( 1 ) = ( SELECT count( 1 ) FROM Course ))
--46、查询各学生的年龄
    -- 按照出生日期来算，当前月日 < 出生年月的月日则，年龄减一
SELECT
	s_birth,
	(
	DATE_FORMAT( NOW(), '%Y' )- DATE_FORMAT( s_birth, '%Y' ))- ( CASE WHEN DATE_FORMAT( NOW(), '%M%D' ) > DATE_FORMAT( s_birth, '%M%D' ) THEN 0 ELSE 1 END )
FROM
	Student
-- 47、查询本周过生日的学生
Select * FROM Student where week(DATE_FORMAT(NOW(),'%y%m%d'))=week(s_birth);
-- 48、查询下周过生日的学生
Select * FROM Student where week(DATE_FORMAT(NOW(),'%y%m%d')) + 1=week(s_birth);
-- 49、查询本月过生日的学生
Select * FROM Student where week(DATE_FORMAT(NOW(),'%y%m%d'))=week(s_birth);
-- 50、查询下月过生日的学生
Select * FROM Student where week(DATE_FORMAT(NOW(),'%y%m%d')) + 1=week(s_birth);