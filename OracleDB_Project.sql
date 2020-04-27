create or replace TYPE t_rec IS OBJECT(id NUMBER, ders_kod VARCHAR2(7));

create or replace TYPE t_rec_stud IS OBJECT(stud_id VARCHAR2(50));

create or replace TYPE t_rec_teacher IS OBJECT(id NUMBER, emp_id NUMBER);

create or replace TYPE t_table_teacher IS TABLE OF t_rec_teacher;

create or replace TYPE list_of_sections IS VARRAY(50) OF VARCHAR2(2);

create or replace TYPE table_schedule IS TABLE OF t_schedule;

create or replace TYPE list_of_studs IS TABLE OF  t_rec_stud;

create or replace TYPE t_table IS TABLE OF t_rec;

create or replace TYPE list_of_ids IS VARRAY(50) OF NUMBER;

create or replace TYPE t_schedule IS OBJECT(ders_kod VARCHAR(7), weekday VARCHAR2(10), start_time VARCHAR2(5), section VARCHAR2(2), type VARCHAR2(1)); 

create or replace PACKAGE pkg_courses IS
    FUNCTION picking_time(v_ders VARCHAR2, v_term NUMBER, v_year NUMBER, v_count OUT NUMBER) RETURN NUMBER;
    FUNCTION popular_courses(v_term NUMBER, v_year NUMBER) RETURN t_table;
END pkg_courses;

create or replace PACKAGE BODY pkg_courses IS
    FUNCTION picking_time(v_ders IN VARCHAR2, v_term IN NUMBER, v_year IN NUMBER, v_count OUT NUMBER)
        RETURN NUMBER IS
        v_diff NUMBER;
    BEGIN
        SELECT (MAX(reg_date)-MIN(reg_date))*24*3600, count(*) INTO v_diff, v_count FROM course_selections WHERE year = v_year AND term = v_term AND ders_kod = v_ders;
        RETURN v_diff;
    END;

    FUNCTION popular_courses(v_term IN NUMBER, v_year IN NUMBER) 
        RETURN t_table IS
        t_result t_table := t_table();
        CURSOR cur_course IS SELECT ders_kod, SUM(NVL(credits, 3)) as credits, count(ders_kod) as ders_count FROM course_sections WHERE term = v_term AND year = v_year GROUP BY ders_kod;
        v_time NUMBER := 1;
        v_count NUMBER := 1;
    BEGIN

        FOR rec_course IN cur_course LOOP
            v_time := picking_time(rec_course.ders_kod, v_term, v_year, v_count); 
            IF v_time = 0 THEN
                v_time := null;
            END IF;
            t_result.extend;
            t_result(t_result.count) := t_rec(null, null);
            t_result(t_result.count).id := v_time / (v_count+0.0) / (rec_course.credits+0.0);
            t_result(t_result.count).ders_kod := rec_course.ders_kod;
            v_count := 1;
        END LOOP;
        RETURN t_result;
    END;
END; 

create or replace PACKAGE pkg_teachers_section IS
    FUNCTION picking_time(v_ders VARCHAR2, v_term NUMBER, v_year NUMBER, v_count OUT NUMBER, l_sections IN list_of_sections) RETURN NUMBER;
    FUNCTION popular_teachers_lection(v_term IN NUMBER, v_year IN NUMBER, v_ders_kod IN VARCHAR2) RETURN t_table_teacher;
     FUNCTION popular_teachers_practice(v_term IN NUMBER, v_year IN NUMBER, v_ders_kod IN VARCHAR2) RETURN t_table_teacher;
END pkg_teachers_section;

create or replace PACKAGE BODY pkg_teachers_section IS
    FUNCTION picking_time(v_ders IN VARCHAR2, v_term IN NUMBER, v_year IN NUMBER, v_count OUT NUMBER, l_sections IN list_of_sections)
        RETURN NUMBER IS
        v_diff NUMBER;
    BEGIN
        SELECT (MAX(reg_date)-MIN(reg_date))*24*3600, count(*) INTO v_diff, v_count FROM course_selections WHERE year = v_year AND term = v_term AND ders_kod = v_ders and section IN (SELECT section FROM table(l_sections));
        RETURN v_diff;
    END;

    FUNCTION popular_teachers_lection(v_term IN NUMBER, v_year IN NUMBER, v_ders_kod IN VARCHAR2) 
        RETURN t_table_teacher IS
        t_result t_table_teacher := t_table_teacher();
        l_sections list_of_sections := list_of_sections();
        CURSOR cur_teachers IS SELECT emp_id, SUM(NVL(credits, 3)) as credits, count(emp_id) as section_count FROM course_sections WHERE term = v_term AND year = v_year AND ders_kod = v_ders_kod AND type IN ('L', 'N') GROUP BY emp_id;
        v_time NUMBER := 1;
        v_count NUMBER := 1;
    BEGIN
        FOR rec_teacher IN cur_teachers LOOP
            SELECT section BULK COLLECT INTO l_sections FROM course_sections WHERE year = v_year and term = v_term and emp_id = rec_teacher.emp_id and ders_kod = v_ders_kod;
            v_time := picking_time(v_ders_kod, v_term, v_year, v_count, l_sections); 
            IF v_time = 0 THEN
                v_time := null;
            END IF;
            t_result.extend;
            t_result(t_result.count) := t_rec_teacher(null, null);
            t_result(t_result.count).id := v_time / (v_count+0.0) / (rec_teacher.credits+0.0);
            t_result(t_result.count).emp_id := rec_teacher.emp_id;
            v_count := 1;
        END LOOP;
        RETURN t_result;
    END;

    FUNCTION popular_teachers_practice(v_term IN NUMBER, v_year IN NUMBER, v_ders_kod IN VARCHAR2) 
        RETURN t_table_teacher IS
        t_result t_table_teacher := t_table_teacher();
        l_sections list_of_sections := list_of_sections();
        CURSOR cur_teachers IS SELECT emp_id, SUM(NVL(credits, 3)) as credits, count(emp_id) as section_count FROM course_sections WHERE term = v_term AND year = v_year AND ders_kod = v_ders_kod AND type = 'P' GROUP BY emp_id;
        v_time NUMBER := 1;
        v_count NUMBER := 1;
    BEGIN
        FOR rec_teacher IN cur_teachers LOOP

            SELECT section BULK COLLECT INTO l_sections FROM course_sections WHERE year = v_year and term = v_term and emp_id = rec_teacher.emp_id and ders_kod = v_ders_kod;
            v_time := picking_time(v_ders_kod, v_term, v_year, v_count, l_sections); 
            IF v_time = 0 THEN
                v_time := null;
            END IF;
            t_result.extend;
            t_result(t_result.count) := t_rec_teacher(null, null);
            t_result(t_result.count).id := v_time / (v_count+0.0) / (rec_teacher.credits+0.0);
            t_result(t_result.count).emp_id := rec_teacher.emp_id;
            v_count := 1;
        END LOOP;
        RETURN t_result;
    END;
END;


create or replace FUNCTION calculateGPA_total(v_stud_id IN course_selections.stud_id%TYPE) RETURN NUMBER 
    IS
        v_credit NUMBER;
        v_point NUMBER;
        v_res NUMBER := 0;
        v_sum_credit NUMBER := 0;
    CURSOR cur_stud IS SELECT ders_kod, qiymet_herf, grading_type FROM course_selections where stud_id = v_stud_id;
BEGIN
    FOR rec_stud IN cur_stud LOOP
        SELECT NVL(credits, 3) INTO v_credit FROM course_sections  WHERE ders_kod = rec_stud.ders_kod and rownum = 1;
        IF rec_stud.grading_type = 'PNP' THEN
            CONTINUE;
        END IF;
        v_res := v_res + (getPoint(rec_stud.qiymet_herf)*v_credit);
        v_sum_credit := v_sum_credit + v_credit;
    END LOOP;
    RETURN v_res / v_sum_credit;
END;

create or replace FUNCTION calculateGPA_term(v_stud_id IN course_selections.stud_id%TYPE, v_term  IN NUMBER, v_year IN NUMBER) RETURN NUMBER 
    IS
        v_credit NUMBER;
        v_point NUMBER;
        v_res NUMBER := 0;
        v_sum_credit NUMBER := 0;
    CURSOR cur_stud IS SELECT ders_kod, qiymet_herf, grading_type FROM course_selections where stud_id = v_stud_id and year = v_year and term = v_term;
BEGIN
    FOR rec_stud IN cur_stud LOOP
        SELECT NVL(credits, 3) INTO v_credit FROM course_sections  WHERE ders_kod = rec_stud.ders_kod AND term = v_term and year = v_year and rownum = 1;
        IF rec_stud.grading_type = 'PNP' THEN
            CONTINUE;
        END IF;
        v_res := v_res + (getPoint(rec_stud.qiymet_herf)*v_credit);
        v_sum_credit := v_sum_credit + v_credit;
    END LOOP;
    RETURN v_res / v_sum_credit;
END;


create or replace FUNCTION students_not_registered(v_term NUMBER, v_year NUMBER)
    RETURN list_of_studs IS 
    l_studs list_of_studs;
    v_count NUMBER := 0;
    v_year_count NUMBER;
    v_next_year_count NUMBER;
BEGIN
    l_studs := list_of_studs();
    FOR i IN (SELECT distinct(stud_id) FROM course_selections where year = v_year and 
        term =  v_term AND ROWNUM <= 3000) LOOP
        SELECT COUNT(*) INTO v_year_count FROM (SELECT year FROM course_selections WHERE stud_id = i.stud_id AND term = 2 and year <= v_year-1 GROUP BY year);
        IF  v_year < 2019 THEN
            SELECT COUNT(*) INTO v_next_year_count FROM (SELECT year FROM course_selections WHERE stud_id = i.stud_id AND term = 2 and year >= v_year+1 GROUP BY year);
            dbms_output.put_line(v_next_year_count || ' --- ' || v_year_count);
            IF v_year_count > 0 AND v_next_year_count > 0 THEN
                l_studs.extend;
                l_studs(l_studs.count) := t_rec_stud(i.stud_id);
            END IF;
        ELSIF v_year = 2019 THEN 
            IF v_year_count != 3 THEN
                l_studs.extend;
                l_studs(l_studs.count) := t_rec_stud(i.stud_id);
            END IF;
        END IF;
    END LOOP;
    RETURN l_studs;
END;


create or replace FUNCTION calculateSpentRetake_total(v_stud_id IN course_selections.stud_id%TYPE)
    RETURN NUMBER IS
        v_sum_credit NUMBER := 0;
        v_credit NUMBER;
BEGIN
    FOR rec IN (SELECT ders_kod FROM course_selections WHERE stud_id = v_stud_id AND qiymet_yuz <50) LOOP
        SELECT NVL(credits, 3) INTO v_credit FROM course_sections  WHERE ders_kod = rec.ders_kod and rownum = 1;
        v_sum_credit := v_sum_credit + v_credit; 
    END LOOP;
    RETURN v_sum_credit * 25000;
END;

create or replace FUNCTION calculateSpentRetake_term(v_stud_id IN course_selections.stud_id%TYPE, v_term  IN NUMBER, v_year IN NUMBER)
    RETURN NUMBER IS
        v_sum_credit NUMBER := 0;
        v_credit NUMBER;
BEGIN
    FOR rec IN (SELECT ders_kod FROM course_selections WHERE term = v_term AND year = v_year AND stud_id = v_stud_id AND qiymet_yuz <50) LOOP
        SELECT NVL(credits, 3) INTO v_credit FROM course_sections  WHERE ders_kod = rec.ders_kod and rownum = 1;
        v_sum_credit := v_sum_credit + v_credit; 
    END LOOP;
    RETURN v_sum_credit * 25000;
END;


create or replace FUNCTION teacher_loading(v_term IN NUMBER, v_year IN NUMBER, v_emp_id IN NUMBER)
RETURN NUMBER IS
    v_hours NUMBER;
BEGIN
    SELECT SUM(NVL(hour_num, 15)) INTO v_hours FROM course_sections WHERE year = v_year AND term = v_term AND emp_id = v_emp_id;
    RETURN v_hours;
END;

create or replace FUNCTION schedule_teacher(v_emp_id NUMBER, v_term NUMBER, v_year NUMBER) 
    RETURN table_schedule IS
    t_res table_schedule := table_schedule();
    CURSOR cur_teacher IS SELECT * FROM course_sections WHERE emp_id = v_emp_id AND term = v_term AND year = v_year;
BEGIN
    FOR rec_t IN cur_teacher LOOP
        BEGIN
        FOR i IN (SELECT to_char(min_start_time, 'DAY') as weekday, to_char(min_start_time, 'HH24:MI') as start_time 
            FROM course_schedule WHERE ders_kod = rec_t.ders_kod AND section = rec_t.section
                AND year = v_year AND term = v_term) LOOP
            t_res.extend;
            t_res(t_res.count) := t_schedule(rec_t.ders_kod, i.weekday, i.start_time, rec_t.section, rec_t.type);
        END LOOP;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN CONTINUE;
        END;
    END LOOP;
    RETURN t_res;
END;

create or replace FUNCTION schedule_student(v_stud_id course_selections.stud_id%TYPE, v_term NUMBER, v_year NUMBER) 
    RETURN table_schedule IS
    t_res table_schedule := table_schedule();
    v_type VARCHAR2(1);
    CURSOR cur_stud IS SELECT * FROM course_selections WHERE stud_id = v_stud_id AND term = v_term AND year = v_year;
BEGIN
    FOR rec_t IN cur_stud LOOP
        BEGIN
        FOR i IN (SELECT to_char(min_start_time, 'DAY') as weekday, to_char(min_start_time, 'HH24:MI') as start_time 
            FROM course_schedule WHERE ders_kod = rec_t.ders_kod AND section = rec_t.section
                AND year = v_year AND term = v_term) 
        LOOP
            t_res.extend;
            SELECT type INTO v_type FROM course_sections WHERE ders_kod = rec_t.ders_kod AND section = rec_t.section and year = v_year and term = v_term;
            t_res(t_res.count) := t_schedule(rec_t.ders_kod, i.weekday, i.start_time, rec_t.section, v_type);
        END LOOP;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN 
            NULL;
        END;
    END LOOP;
    RETURN t_res;
END;


create or replace FUNCTION most_clever_flow_students(v_term IN NUMBER, v_year IN NUMBER, v_emp_id IN NUMBER, v_ders_kod IN VARCHAR2)
RETURN VARCHAR2 IS
    v_res_section VARCHAR2(2);
    v_max_grade_avg NUMBER := 0;
    v_sum_grade NUMBER := 0;
    v_count NUMBER :=0;
BEGIN
    FOR i in (SELECT section FROM course_sections WHERE year = v_year AND term = v_term AND emp_id = v_emp_id AND ders_kod = v_ders_kod) LOOP
        FOR j IN (SELECT stud_id, qiymet_yuz FROM course_selections WHERE year = v_year AND term = v_term AND ders_kod = v_ders_kod AND section = i.section) LOOP
            v_sum_grade:= v_sum_grade+j.qiymet_yuz;
            v_count := v_count + 1;
        END LOOP;
        IF v_count != 0 THEN
            IF v_sum_grade / v_count > v_max_grade_avg THEN
                v_res_section := i.section;
                v_max_grade_avg := v_sum_grade / v_count;
            END IF;
        END IF;
        v_count := 0;
        v_sum_grade := 0;
    END LOOP;
    RETURN v_res_section;
END;  

create or replace FUNCTION rating_courses(v_term NUMBER, v_year NUMBER) 
RETURN t_table IS
t_result t_table := t_table();
CURSOR cur_course IS SELECT distinct(ders_kod) FROM course_sections WHERE term = v_term AND year = v_year;
v_count_stud NUMBER := 1;
BEGIN
    FOR rec_course IN cur_course LOOP
        SELECT count(*) INTO v_count_stud FROM course_selections WHERE year = v_year AND term = v_term AND ders_kod = rec_course.ders_kod;
        t_result.extend;
        t_result(t_result.count) := t_rec(null, null);
        t_result(t_result.count).id := v_count_stud;
        t_result(t_result.count).ders_kod := rec_course.ders_kod;
        v_count_stud := null;
    END LOOP;
RETURN t_result;
END;

create or replace FUNCTION rating_teachers(v_term NUMBER, v_year NUMBER) 
RETURN t_table_teacher IS
t_result t_table_teacher := t_table_teacher();
CURSOR cur_emp IS SELECT distinct(emp_id) FROM course_sections WHERE term = v_term AND year = v_year;
v_hours NUMBER := null;
BEGIN
    FOR rec_emp IN cur_emp LOOP
        if rec_emp.emp_id IS NOT NULL THEN
            v_hours := teacher_loading(v_term, v_year, rec_emp.emp_id);
            t_result.extend;
            t_result(t_result.count) := t_rec_teacher(null, null);
            t_result(t_result.count).id := v_hours;
            t_result(t_result.count).emp_id := rec_emp.emp_id;
            v_hours := null;
        END IF;

    END LOOP;
RETURN t_result;
END;

create or replace PROCEDURE courses_credits_total(
    v_stud_id IN course_selections.stud_id%TYPE,
    v_courses OUT NUMBER, v_credits OUT NUMBER) IS
    v_credits_cur NUMBER := 0;
BEGIN
    v_courses := 0;
    v_credits := 0;
     FOR i IN (SELECT ders_kod FROM course_selections WHERE stud_id=v_stud_id) LOOP
        v_courses := v_courses+1;
        SELECT NVL(credits, 3) INTO v_credits_cur FROM course_sections WHERE ders_kod=i.ders_kod AND ROWNUM = 1;
        v_credits := v_credits + v_credits_cur;
     END LOOP;
END;

create or replace PROCEDURE courses_credits_term(
    v_stud_id IN course_selections.stud_id%TYPE, 
    v_term IN NUMBER, v_year IN NUMBER, 
    v_courses OUT NUMBER, v_credits OUT NUMBER) IS
    v_credits_cur NUMBER := 0;
BEGIN
    v_courses := 0;
    v_credits := 0;
     FOR i IN (SELECT ders_kod FROM  course_selections WHERE term=v_term AND year=v_year AND stud_id=v_stud_id) LOOP
        v_courses := v_courses+1;
        SELECT NVL(credits, 3) INTO v_credits_cur FROM course_sections WHERE year=v_year AND term=v_term AND ders_kod=i.ders_kod AND ROWNUM = 1;
        v_credits := v_credits + v_credits_cur;
     END LOOP;
END;
