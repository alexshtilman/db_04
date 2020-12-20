-- Update table marks such that all marks for those who don’t have “Java Technologies” mark will be decreased on 20
-- only for postgress
UPDATE marks set mark=mark - 20 where stid not in 
(select stid from students_marks_subjects where subject = 'Java Technologies')
-- for mysql without temporary table

UPDATE marks
SET mark = mark - 20
WHERE stid NOT IN (
SELECT * FROM (
SELECT stid
    FROM marks
    WHERE suid = (
                SELECT suid
                from subjects
                WHERE subject = "Java Technologies"
        )
) x
);
-- for mysql with temporary table  
CREATE TEMPORARY TABLE m2
SELECT stid
FROM marks
WHERE suid = (
        SELECT suid
        from subjects
        WHERE subject = "Java Technologies"
    );
UPDATE marks
SET mark = mark - 20
WHERE stid not in (
        SELECT stid
        from m2
    );
-- average mark
UPDATE marks
SET mark = mark - 20
WHERE stid NOT IN (
        SELECT stid
        FROM students_marks_subjects
        WHERE subject = 'Java Technologies'
    );
-- Update subject name ‘Java’ to ‘Java core’
UPDATE subjects
set subject = 'Java core'
where subject = 'Java'
    /*
     Insert new “Java Advanced” marks for all students. 
     These marks should be equaled to an average mark among all subjects related to Java of each student. 
     For example if a student has 100 of “Java Technologies” and 70 of “Java core” the “Java Advanced” 
     mark should be 85 for the student. Hint: applying either “like” or regular expressionDisplay 
     two best students of Front-End (React, JS)*/
INSERT INTO subjects
VALUES (5, 'Java Advanced');
INSERT INTO marks (stid, mark, suid)
SELECT st.stid,
    ROUND(AVG(m.mark)),
    (
        SELECT suid
        from subjects
        WHERE subject = 'Java Advanced'
    )
FROM marks m
    JOIN subjects su on m.suid = su.suid
    JOIN students st on m.stid = st.stid
WHERE su.subject LIKE '%Java%'
GROUP by st.stid -- Delete mark objects of React of students who have mark of JS less than 80
DELETE FROM marks
WHERE stid IN (
        SELECT *
        FROM (
                SELECT stid
                from marks m1
                where EXISTS (
                        SELECT *
                        from marks m2
                        where m1.stid = m2.stid
                            and suid = (
                                SELECT suid
                                from subjects
                                where subject = 'JS'
                            )
                            and m2.mark < 80
                    )
            ) AS p
    )
    AND suid = (
        SELECT suid
        from subjects
        where subject = 'React'
    ) -- Delete students having average mark less than the college average mark 
DELETE FROM students
WHERE stid IN (
        SELECT stid
        from marks
        group by stid
        HAVING AVG(mark) <(
                SELECT AVG(mark)
                FROM marks
            )
    )