SET NAMES utf8mb4;

SET @default_password_hash = '$2a$10$TkpWpInMFmWbL4HWZXC7yuMC3szk.vR/ghGvrCEClWQxWBWgFQ6LK';

INSERT INTO t_college (college_code, college_name, status, remark, deleted)
VALUES ('CS', '计算机与软件工程学院', 1, 'base demo seed', 0)
ON DUPLICATE KEY UPDATE
    college_name = VALUES(college_name),
    status = VALUES(status),
    remark = VALUES(remark),
    deleted = VALUES(deleted);

INSERT INTO t_college (college_code, college_name, status, remark, deleted)
VALUES ('AI', '大数据与人工智能学院', 1, 'base demo seed', 0)
ON DUPLICATE KEY UPDATE
    college_name = VALUES(college_name),
    status = VALUES(status),
    remark = VALUES(remark),
    deleted = VALUES(deleted);

INSERT INTO t_college (college_code, college_name, status, remark, deleted)
VALUES ('EEE', '电气与电子工程学院', 1, 'base demo seed', 0)
ON DUPLICATE KEY UPDATE
    college_name = VALUES(college_name),
    status = VALUES(status),
    remark = VALUES(remark),
    deleted = VALUES(deleted);

INSERT INTO t_college (college_code, college_name, status, remark, deleted)
VALUES ('ME', '机械工程学院', 1, 'base demo seed', 0)
ON DUPLICATE KEY UPDATE
    college_name = VALUES(college_name),
    status = VALUES(status),
    remark = VALUES(remark),
    deleted = VALUES(deleted);

INSERT INTO t_college (college_code, college_name, status, remark, deleted)
VALUES ('MGT', '管理工程学院', 1, 'base demo seed', 0)
ON DUPLICATE KEY UPDATE
    college_name = VALUES(college_name),
    status = VALUES(status),
    remark = VALUES(remark),
    deleted = VALUES(deleted);

INSERT INTO t_college (college_code, college_name, status, remark, deleted)
VALUES ('ART', '艺术设计学院', 1, 'base demo seed', 0)
ON DUPLICATE KEY UPDATE
    college_name = VALUES(college_name),
    status = VALUES(status),
    remark = VALUES(remark),
    deleted = VALUES(deleted);

INSERT INTO t_college (college_code, college_name, status, remark, deleted)
VALUES ('FLA', '通识教育与外国语学院', 1, 'base demo seed', 0)
ON DUPLICATE KEY UPDATE
    college_name = VALUES(college_name),
    status = VALUES(status),
    remark = VALUES(remark),
    deleted = VALUES(deleted);

SET @college_cs_id = (SELECT id FROM t_college WHERE college_code = 'CS' LIMIT 1);
SET @college_ai_id = (SELECT id FROM t_college WHERE college_code = 'AI' LIMIT 1);
SET @college_eee_id = (SELECT id FROM t_college WHERE college_code = 'EEE' LIMIT 1);
SET @college_me_id = (SELECT id FROM t_college WHERE college_code = 'ME' LIMIT 1);
SET @college_mgt_id = (SELECT id FROM t_college WHERE college_code = 'MGT' LIMIT 1);
SET @college_art_id = (SELECT id FROM t_college WHERE college_code = 'ART' LIMIT 1);
SET @college_fla_id = (SELECT id FROM t_college WHERE college_code = 'FLA' LIMIT 1);

INSERT INTO t_user (
    username, password, real_name, role, student_id, college, major, grade,
    phone, email, lab_id, can_edit, system_account_code, status, deleted
) VALUES (
    'superadmin', @default_password_hash, '学校管理员', 'super_admin', NULL, NULL, NULL, NULL,
    '13800000001', 'superadmin@aiit.edu.cn', NULL, 0, 'SYS_SCHOOL_DIRECTOR', 1, 0
)
ON DUPLICATE KEY UPDATE
    password = VALUES(password),
    real_name = VALUES(real_name),
    role = VALUES(role),
    student_id = VALUES(student_id),
    college = VALUES(college),
    major = VALUES(major),
    grade = VALUES(grade),
    phone = VALUES(phone),
    email = VALUES(email),
    can_edit = VALUES(can_edit),
    system_account_code = VALUES(system_account_code),
    status = VALUES(status),
    deleted = VALUES(deleted);

INSERT INTO t_user (
    username, password, real_name, role, student_id, college, major, grade,
    phone, email, lab_id, can_edit, system_account_code, status, deleted
) VALUES (
    'cs_admin', @default_password_hash, '计算机与软件工程学院管理员', 'admin', NULL, '计算机与软件工程学院', NULL, NULL,
    '13800000002', 'cs_admin@aiit.edu.cn', NULL, 0, 'SYS_COLLEGE_MANAGER#1', 1, 0
)
ON DUPLICATE KEY UPDATE
    password = VALUES(password),
    real_name = VALUES(real_name),
    role = VALUES(role),
    student_id = VALUES(student_id),
    college = VALUES(college),
    major = VALUES(major),
    grade = VALUES(grade),
    phone = VALUES(phone),
    email = VALUES(email),
    can_edit = VALUES(can_edit),
    system_account_code = VALUES(system_account_code),
    status = VALUES(status),
    deleted = VALUES(deleted);

INSERT INTO t_user (
    username, password, real_name, role, student_id, college, major, grade,
    phone, email, lab_id, can_edit, system_account_code, status, deleted
) VALUES (
    'ai_admin', @default_password_hash, '大数据与人工智能学院管理员', 'admin', NULL, '大数据与人工智能学院', NULL, NULL,
    '13800000003', 'ai_admin@aiit.edu.cn', NULL, 0, 'SYS_COLLEGE_MANAGER#2', 1, 0
)
ON DUPLICATE KEY UPDATE
    password = VALUES(password),
    real_name = VALUES(real_name),
    role = VALUES(role),
    student_id = VALUES(student_id),
    college = VALUES(college),
    major = VALUES(major),
    grade = VALUES(grade),
    phone = VALUES(phone),
    email = VALUES(email),
    can_edit = VALUES(can_edit),
    system_account_code = VALUES(system_account_code),
    status = VALUES(status),
    deleted = VALUES(deleted);

INSERT INTO t_user (
    username, password, real_name, role, student_id, college, major, grade,
    phone, email, lab_id, can_edit, system_account_code, status, deleted
) VALUES (
    'ee_admin', @default_password_hash, '电气与电子工程学院管理员', 'admin', NULL, '电气与电子工程学院', NULL, NULL,
    '13800000004', 'ee_admin@aiit.edu.cn', NULL, 0, 'SYS_COLLEGE_MANAGER#3', 1, 0
)
ON DUPLICATE KEY UPDATE
    password = VALUES(password),
    real_name = VALUES(real_name),
    role = VALUES(role),
    student_id = VALUES(student_id),
    college = VALUES(college),
    major = VALUES(major),
    grade = VALUES(grade),
    phone = VALUES(phone),
    email = VALUES(email),
    can_edit = VALUES(can_edit),
    system_account_code = VALUES(system_account_code),
    status = VALUES(status),
    deleted = VALUES(deleted);

INSERT INTO t_user (
    username, password, real_name, role, student_id, college, major, grade,
    phone, email, lab_id, can_edit, system_account_code, status, deleted
) VALUES (
    'me_admin', @default_password_hash, '机械工程学院管理员', 'admin', NULL, '机械工程学院', NULL, NULL,
    '13800000005', 'me_admin@aiit.edu.cn', NULL, 0, 'SYS_COLLEGE_MANAGER#4', 1, 0
)
ON DUPLICATE KEY UPDATE
    password = VALUES(password),
    real_name = VALUES(real_name),
    role = VALUES(role),
    student_id = VALUES(student_id),
    college = VALUES(college),
    major = VALUES(major),
    grade = VALUES(grade),
    phone = VALUES(phone),
    email = VALUES(email),
    can_edit = VALUES(can_edit),
    system_account_code = VALUES(system_account_code),
    status = VALUES(status),
    deleted = VALUES(deleted);

INSERT INTO t_user (
    username, password, real_name, role, student_id, college, major, grade,
    phone, email, lab_id, can_edit, system_account_code, status, deleted
) VALUES (
    'mgt_admin', @default_password_hash, '管理工程学院管理员', 'admin', NULL, '管理工程学院', NULL, NULL,
    '13800000006', 'mgt_admin@aiit.edu.cn', NULL, 0, 'SYS_COLLEGE_MANAGER#5', 1, 0
)
ON DUPLICATE KEY UPDATE
    password = VALUES(password),
    real_name = VALUES(real_name),
    role = VALUES(role),
    student_id = VALUES(student_id),
    college = VALUES(college),
    major = VALUES(major),
    grade = VALUES(grade),
    phone = VALUES(phone),
    email = VALUES(email),
    can_edit = VALUES(can_edit),
    system_account_code = VALUES(system_account_code),
    status = VALUES(status),
    deleted = VALUES(deleted);

INSERT INTO t_user (
    username, password, real_name, role, student_id, college, major, grade,
    phone, email, lab_id, can_edit, system_account_code, status, deleted
) VALUES (
    'art_admin', @default_password_hash, '艺术设计学院管理员', 'admin', NULL, '艺术设计学院', NULL, NULL,
    '13800000007', 'art_admin@aiit.edu.cn', NULL, 0, 'SYS_COLLEGE_MANAGER#6', 1, 0
)
ON DUPLICATE KEY UPDATE
    password = VALUES(password),
    real_name = VALUES(real_name),
    role = VALUES(role),
    student_id = VALUES(student_id),
    college = VALUES(college),
    major = VALUES(major),
    grade = VALUES(grade),
    phone = VALUES(phone),
    email = VALUES(email),
    can_edit = VALUES(can_edit),
    system_account_code = VALUES(system_account_code),
    status = VALUES(status),
    deleted = VALUES(deleted);

INSERT INTO t_user (
    username, password, real_name, role, student_id, college, major, grade,
    phone, email, lab_id, can_edit, system_account_code, status, deleted
) VALUES (
    'fla_admin', @default_password_hash, '通识教育与外国语学院管理员', 'admin', NULL, '通识教育与外国语学院', NULL, NULL,
    '13800000008', 'fla_admin@aiit.edu.cn', NULL, 0, 'SYS_COLLEGE_MANAGER#7', 1, 0
)
ON DUPLICATE KEY UPDATE
    password = VALUES(password),
    real_name = VALUES(real_name),
    role = VALUES(role),
    student_id = VALUES(student_id),
    college = VALUES(college),
    major = VALUES(major),
    grade = VALUES(grade),
    phone = VALUES(phone),
    email = VALUES(email),
    can_edit = VALUES(can_edit),
    system_account_code = VALUES(system_account_code),
    status = VALUES(status),
    deleted = VALUES(deleted);

INSERT INTO t_user (
    username, password, real_name, role, student_id, college, major, grade,
    phone, email, lab_id, can_edit, system_account_code, status, deleted
) VALUES
    ('teacher_cs_01', @default_password_hash, '陈志远', 'teacher', NULL, '计算机与软件工程学院', '软件工程教研室', NULL, '13800000101', 'teacher_cs_01@aiit.edu.cn', NULL, 1, NULL, 1, 0),
    ('teacher_ai_01', @default_password_hash, '刘敏', 'teacher', NULL, '大数据与人工智能学院', '人工智能教研室', NULL, '13800000102', 'teacher_ai_01@aiit.edu.cn', NULL, 1, NULL, 1, 0),
    ('teacher_ee_01', @default_password_hash, '周海峰', 'teacher', NULL, '电气与电子工程学院', '电子信息工程教研室', NULL, '13800000103', 'teacher_ee_01@aiit.edu.cn', NULL, 1, NULL, 1, 0),
    ('teacher_me_01', @default_password_hash, '许建国', 'teacher', NULL, '机械工程学院', '机械设计教研室', NULL, '13800000104', 'teacher_me_01@aiit.edu.cn', NULL, 1, NULL, 1, 0),
    ('teacher_mgt_01', @default_password_hash, '何嘉宁', 'teacher', NULL, '管理工程学院', '数字运营教研室', NULL, '13800000105', 'teacher_mgt_01@aiit.edu.cn', NULL, 1, NULL, 1, 0),
    ('teacher_art_01', @default_password_hash, '林若彤', 'teacher', NULL, '艺术设计学院', '数字媒体艺术教研室', NULL, '13800000106', 'teacher_art_01@aiit.edu.cn', NULL, 1, NULL, 1, 0),
    ('teacher_fla_01', @default_password_hash, '唐思远', 'teacher', NULL, '通识教育与外国语学院', '外国语教研室', NULL, '13800000107', 'teacher_fla_01@aiit.edu.cn', NULL, 1, NULL, 1, 0)
ON DUPLICATE KEY UPDATE
    password = VALUES(password),
    real_name = VALUES(real_name),
    role = VALUES(role),
    student_id = VALUES(student_id),
    college = VALUES(college),
    major = VALUES(major),
    grade = VALUES(grade),
    phone = VALUES(phone),
    email = VALUES(email),
    can_edit = VALUES(can_edit),
    status = VALUES(status),
    deleted = VALUES(deleted);

INSERT INTO t_user (
    username, password, real_name, role, student_id, college, major, grade,
    phone, email, lab_id, can_edit, system_account_code, status, deleted
) VALUES
    ('20231001', @default_password_hash, '张晨', 'student', '20231001', '计算机与软件工程学院', '软件工程', '2023级', '13800001001', '20231001@aiit.edu.cn', NULL, 1, NULL, 1, 0),
    ('20231002', @default_password_hash, '李沐', 'student', '20231002', '计算机与软件工程学院', '计算机科学与技术', '2023级', '13800001002', '20231002@aiit.edu.cn', NULL, 1, NULL, 1, 0),
    ('20231003', @default_password_hash, '王宁', 'student', '20231003', '大数据与人工智能学院', '人工智能', '2023级', '13800001003', '20231003@aiit.edu.cn', NULL, 1, NULL, 1, 0),
    ('20231004', @default_password_hash, '赵桐', 'student', '20231004', '大数据与人工智能学院', '数据科学与大数据技术', '2023级', '13800001004', '20231004@aiit.edu.cn', NULL, 1, NULL, 1, 0),
    ('20231005', @default_password_hash, '周航', 'student', '20231005', '电气与电子工程学院', '电子信息工程', '2023级', '13800001005', '20231005@aiit.edu.cn', NULL, 1, NULL, 1, 0),
    ('20231006', @default_password_hash, '孙越', 'student', '20231006', '电气与电子工程学院', '自动化', '2023级', '13800001006', '20231006@aiit.edu.cn', NULL, 1, NULL, 1, 0),
    ('20231007', @default_password_hash, '陈锐', 'student', '20231007', '机械工程学院', '机械设计制造及其自动化', '2023级', '13800001007', '20231007@aiit.edu.cn', NULL, 1, NULL, 1, 0),
    ('20231008', @default_password_hash, '吴彤', 'student', '20231008', '机械工程学院', '机器人工程', '2023级', '13800001008', '20231008@aiit.edu.cn', NULL, 1, NULL, 1, 0),
    ('20231009', @default_password_hash, '郑琪', 'student', '20231009', '管理工程学院', '信息管理与信息系统', '2023级', '13800001009', '20231009@aiit.edu.cn', NULL, 1, NULL, 1, 0),
    ('20231010', @default_password_hash, '何雅', 'student', '20231010', '管理工程学院', '大数据管理与应用', '2023级', '13800001010', '20231010@aiit.edu.cn', NULL, 1, NULL, 1, 0),
    ('20231011', @default_password_hash, '林溪', 'student', '20231011', '艺术设计学院', '数字媒体艺术', '2023级', '13800001011', '20231011@aiit.edu.cn', NULL, 1, NULL, 1, 0),
    ('20231012', @default_password_hash, '许诺', 'student', '20231012', '艺术设计学院', '视觉传达设计', '2023级', '13800001012', '20231012@aiit.edu.cn', NULL, 1, NULL, 1, 0),
    ('20231013', @default_password_hash, '宋佳', 'student', '20231013', '通识教育与外国语学院', '英语', '2023级', '13800001013', '20231013@aiit.edu.cn', NULL, 1, NULL, 1, 0),
    ('20231014', @default_password_hash, '唐悦', 'student', '20231014', '通识教育与外国语学院', '商务英语', '2023级', '13800001014', '20231014@aiit.edu.cn', NULL, 1, NULL, 1, 0)
ON DUPLICATE KEY UPDATE
    password = VALUES(password),
    real_name = VALUES(real_name),
    role = VALUES(role),
    student_id = VALUES(student_id),
    college = VALUES(college),
    major = VALUES(major),
    grade = VALUES(grade),
    phone = VALUES(phone),
    email = VALUES(email),
    can_edit = VALUES(can_edit),
    status = VALUES(status),
    deleted = VALUES(deleted);

SET @school_admin_id = (SELECT id FROM t_user WHERE username = 'superadmin' LIMIT 1);
SET @cs_admin_id = (SELECT id FROM t_user WHERE username = 'cs_admin' LIMIT 1);
SET @ai_admin_id = (SELECT id FROM t_user WHERE username = 'ai_admin' LIMIT 1);
SET @ee_admin_id = (SELECT id FROM t_user WHERE username = 'ee_admin' LIMIT 1);
SET @me_admin_id = (SELECT id FROM t_user WHERE username = 'me_admin' LIMIT 1);
SET @mgt_admin_id = (SELECT id FROM t_user WHERE username = 'mgt_admin' LIMIT 1);
SET @art_admin_id = (SELECT id FROM t_user WHERE username = 'art_admin' LIMIT 1);
SET @fla_admin_id = (SELECT id FROM t_user WHERE username = 'fla_admin' LIMIT 1);

SET @teacher_cs_id = (SELECT id FROM t_user WHERE username = 'teacher_cs_01' LIMIT 1);
SET @teacher_ai_id = (SELECT id FROM t_user WHERE username = 'teacher_ai_01' LIMIT 1);
SET @teacher_ee_id = (SELECT id FROM t_user WHERE username = 'teacher_ee_01' LIMIT 1);
SET @teacher_me_id = (SELECT id FROM t_user WHERE username = 'teacher_me_01' LIMIT 1);
SET @teacher_mgt_id = (SELECT id FROM t_user WHERE username = 'teacher_mgt_01' LIMIT 1);
SET @teacher_art_id = (SELECT id FROM t_user WHERE username = 'teacher_art_01' LIMIT 1);
SET @teacher_fla_id = (SELECT id FROM t_user WHERE username = 'teacher_fla_01' LIMIT 1);

SET @student_20231001_id = (SELECT id FROM t_user WHERE username = '20231001' LIMIT 1);
SET @student_20231002_id = (SELECT id FROM t_user WHERE username = '20231002' LIMIT 1);
SET @student_20231003_id = (SELECT id FROM t_user WHERE username = '20231003' LIMIT 1);
SET @student_20231004_id = (SELECT id FROM t_user WHERE username = '20231004' LIMIT 1);
SET @student_20231005_id = (SELECT id FROM t_user WHERE username = '20231005' LIMIT 1);
SET @student_20231006_id = (SELECT id FROM t_user WHERE username = '20231006' LIMIT 1);
SET @student_20231007_id = (SELECT id FROM t_user WHERE username = '20231007' LIMIT 1);
SET @student_20231008_id = (SELECT id FROM t_user WHERE username = '20231008' LIMIT 1);
SET @student_20231009_id = (SELECT id FROM t_user WHERE username = '20231009' LIMIT 1);
SET @student_20231010_id = (SELECT id FROM t_user WHERE username = '20231010' LIMIT 1);
SET @student_20231011_id = (SELECT id FROM t_user WHERE username = '20231011' LIMIT 1);
SET @student_20231012_id = (SELECT id FROM t_user WHERE username = '20231012' LIMIT 1);
SET @student_20231013_id = (SELECT id FROM t_user WHERE username = '20231013' LIMIT 1);
SET @student_20231014_id = (SELECT id FROM t_user WHERE username = '20231014' LIMIT 1);

INSERT INTO t_user_identity (user_id, identity_type, college_id, status, remark, deleted)
VALUES
    (@school_admin_id, 'teacher', NULL, 'active', 'base demo management identity', 0),
    (@cs_admin_id, 'teacher', @college_cs_id, 'active', 'base demo management identity', 0),
    (@ai_admin_id, 'teacher', @college_ai_id, 'active', 'base demo management identity', 0),
    (@ee_admin_id, 'teacher', @college_eee_id, 'active', 'base demo management identity', 0),
    (@me_admin_id, 'teacher', @college_me_id, 'active', 'base demo management identity', 0),
    (@mgt_admin_id, 'teacher', @college_mgt_id, 'active', 'base demo management identity', 0),
    (@art_admin_id, 'teacher', @college_art_id, 'active', 'base demo management identity', 0),
    (@fla_admin_id, 'teacher', @college_fla_id, 'active', 'base demo management identity', 0),
    (@teacher_cs_id, 'teacher', @college_cs_id, 'active', 'base demo teacher identity', 0),
    (@teacher_ai_id, 'teacher', @college_ai_id, 'active', 'base demo teacher identity', 0),
    (@teacher_ee_id, 'teacher', @college_eee_id, 'active', 'base demo teacher identity', 0),
    (@teacher_me_id, 'teacher', @college_me_id, 'active', 'base demo teacher identity', 0),
    (@teacher_mgt_id, 'teacher', @college_mgt_id, 'active', 'base demo teacher identity', 0),
    (@teacher_art_id, 'teacher', @college_art_id, 'active', 'base demo teacher identity', 0),
    (@teacher_fla_id, 'teacher', @college_fla_id, 'active', 'base demo teacher identity', 0),
    (@student_20231001_id, 'student', @college_cs_id, 'active', 'base demo student identity', 0),
    (@student_20231002_id, 'student', @college_cs_id, 'active', 'base demo student identity', 0),
    (@student_20231003_id, 'student', @college_ai_id, 'active', 'base demo student identity', 0),
    (@student_20231004_id, 'student', @college_ai_id, 'active', 'base demo student identity', 0),
    (@student_20231005_id, 'student', @college_eee_id, 'active', 'base demo student identity', 0),
    (@student_20231006_id, 'student', @college_eee_id, 'active', 'base demo student identity', 0),
    (@student_20231007_id, 'student', @college_me_id, 'active', 'base demo student identity', 0),
    (@student_20231008_id, 'student', @college_me_id, 'active', 'base demo student identity', 0),
    (@student_20231009_id, 'student', @college_mgt_id, 'active', 'base demo student identity', 0),
    (@student_20231010_id, 'student', @college_mgt_id, 'active', 'base demo student identity', 0),
    (@student_20231011_id, 'student', @college_art_id, 'active', 'base demo student identity', 0),
    (@student_20231012_id, 'student', @college_art_id, 'active', 'base demo student identity', 0),
    (@student_20231013_id, 'student', @college_fla_id, 'active', 'base demo student identity', 0),
    (@student_20231014_id, 'student', @college_fla_id, 'active', 'base demo student identity', 0)
ON DUPLICATE KEY UPDATE
    college_id = VALUES(college_id),
    status = VALUES(status),
    remark = VALUES(remark);

INSERT INTO t_platform_post (user_id, post_code, college_id, status, start_time, end_time, remark, deleted)
VALUES (@school_admin_id, 'SCHOOL_DIRECTOR', NULL, 'active', NOW(), NULL, 'base demo school director', 0)
ON DUPLICATE KEY UPDATE
    user_id = VALUES(user_id),
    status = VALUES(status),
    end_time = VALUES(end_time),
    remark = VALUES(remark),
    deleted = VALUES(deleted);

INSERT INTO t_platform_post (user_id, post_code, college_id, status, start_time, end_time, remark, deleted)
VALUES
    (@cs_admin_id, 'COLLEGE_MANAGER', @college_cs_id, 'active', NOW(), NULL, 'base demo college manager', 0),
    (@ai_admin_id, 'COLLEGE_MANAGER', @college_ai_id, 'active', NOW(), NULL, 'base demo college manager', 0),
    (@ee_admin_id, 'COLLEGE_MANAGER', @college_eee_id, 'active', NOW(), NULL, 'base demo college manager', 0),
    (@me_admin_id, 'COLLEGE_MANAGER', @college_me_id, 'active', NOW(), NULL, 'base demo college manager', 0),
    (@mgt_admin_id, 'COLLEGE_MANAGER', @college_mgt_id, 'active', NOW(), NULL, 'base demo college manager', 0),
    (@art_admin_id, 'COLLEGE_MANAGER', @college_art_id, 'active', NOW(), NULL, 'base demo college manager', 0),
    (@fla_admin_id, 'COLLEGE_MANAGER', @college_fla_id, 'active', NOW(), NULL, 'base demo college manager', 0)
ON DUPLICATE KEY UPDATE
    user_id = VALUES(user_id),
    status = VALUES(status),
    end_time = VALUES(end_time),
    remark = VALUES(remark),
    deleted = VALUES(deleted);

UPDATE t_college SET admin_user_id = @cs_admin_id WHERE id = @college_cs_id;
UPDATE t_college SET admin_user_id = @ai_admin_id WHERE id = @college_ai_id;
UPDATE t_college SET admin_user_id = @ee_admin_id WHERE id = @college_eee_id;
UPDATE t_college SET admin_user_id = @me_admin_id WHERE id = @college_me_id;
UPDATE t_college SET admin_user_id = @mgt_admin_id WHERE id = @college_mgt_id;
UPDATE t_college SET admin_user_id = @art_admin_id WHERE id = @college_art_id;
UPDATE t_college SET admin_user_id = @fla_admin_id WHERE id = @college_fla_id;

INSERT INTO t_lab (
    lab_name, lab_code, college_id, lab_desc, teacher_name, location, contact_email, require_skill,
    recruit_num, current_num, status, founding_date, awards, basic_info, advisors, current_admins, deleted
) VALUES
    ('智能软件与应用创新实验室', 'LAB-CS-001', @college_cs_id, '面向 Web 系统、软件工程实践、校园数字化应用与创新创业项目。', '陈志远', '科创楼 A-301', 'lab_cs_001@aiit.edu.cn', 'Java、Spring Boot、Vue、数据库基础', 20, 2, 1, '2021-09', '承担校级软件项目孵化与竞赛训练', '适合作为学校版环境下的综合软件实验室测试数据。', '陈志远', 'cs_admin / teacher_cs_01', 0),
    ('数据智能决策实验室', 'LAB-AI-001', @college_ai_id, '聚焦数据治理、机器学习、可视化分析与智能决策应用。', '刘敏', '科创楼 B-402', 'lab_ai_001@aiit.edu.cn', 'Python、机器学习、数据分析基础', 18, 2, 1, '2022-03', '支持学院人工智能方向项目实训', '覆盖数据分析与 AI 场景的测试实验室。', '刘敏', 'ai_admin / teacher_ai_01', 0),
    ('工业智能与嵌入式系统实验室', 'LAB-EEE-001', @college_eee_id, '围绕嵌入式系统、物联网应用与工业控制方向开展实践。', '周海峰', '工程楼 C-214', 'lab_eee_001@aiit.edu.cn', 'C、单片机、嵌入式系统基础', 16, 2, 1, '2020-06', '面向电子设计与嵌入式竞赛训练', '适配电子信息与自动化方向实验数据。', '周海峰', 'ee_admin / teacher_ee_01', 0),
    ('智造装备与机器人实验室', 'LAB-ME-001', @college_me_id, '聚焦智能制造、机器人控制与数字化加工工艺实践。', '许建国', '工程楼 D-118', 'lab_me_001@aiit.edu.cn', '机械设计、传感控制、机器人基础', 15, 2, 1, '2021-04', '服务智造装备课程与竞赛训练', '面向机械工程学院的实验与训练场景。', '许建国', 'me_admin / teacher_me_01', 0),
    ('数字运营与商业分析实验室', 'LAB-MGT-001', @college_mgt_id, '覆盖数据运营、流程分析、数字营销与商业决策实践。', '何嘉宁', '经管楼 A-205', 'lab_mgt_001@aiit.edu.cn', 'Excel、SQL、商业分析思维', 15, 2, 1, '2022-09', '支撑商业数据分析与运营项目', '面向管理类专业的数字运营实验环境。', '何嘉宁', 'mgt_admin / teacher_mgt_01', 0),
    ('数字媒体与交互设计实验室', 'LAB-ART-001', @college_art_id, '用于数字媒体创作、交互设计、视觉传播与作品孵化实践。', '林若彤', '艺术楼 B-106', 'lab_art_001@aiit.edu.cn', 'Figma、Adobe、交互设计基础', 18, 2, 1, '2021-11', '支持交互作品集与创意竞赛训练', '面向艺术设计学院的综合设计实验数据。', '林若彤', 'art_admin / teacher_art_01', 0),
    ('数字人文与跨文化传播实验室', 'LAB-FLA-001', @college_fla_id, '用于外语实践、跨文化传播、数字人文与国际传播训练。', '唐思远', '文教楼 C-308', 'lab_fla_001@aiit.edu.cn', '英语表达、内容策划、跨文化沟通', 12, 2, 1, '2023-02', '支持跨文化传播项目与赛事', '适合外语与通识课程的项目制实验环境。', '唐思远', 'fla_admin / teacher_fla_01', 0)
ON DUPLICATE KEY UPDATE
    lab_name = VALUES(lab_name),
    lab_code = VALUES(lab_code),
    college_id = VALUES(college_id),
    lab_desc = VALUES(lab_desc),
    teacher_name = VALUES(teacher_name),
    location = VALUES(location),
    contact_email = VALUES(contact_email),
    require_skill = VALUES(require_skill),
    recruit_num = VALUES(recruit_num),
    current_num = VALUES(current_num),
    status = VALUES(status),
    founding_date = VALUES(founding_date),
    awards = VALUES(awards),
    basic_info = VALUES(basic_info),
    advisors = VALUES(advisors),
    current_admins = VALUES(current_admins),
    deleted = VALUES(deleted);

SET @lab_cs_id = (SELECT id FROM t_lab WHERE lab_code = 'LAB-CS-001' LIMIT 1);
SET @lab_ai_id = (SELECT id FROM t_lab WHERE lab_code IN ('LAB-AI-001', 'LAB-AI-002') LIMIT 1);
SET @lab_eee_id = (SELECT id FROM t_lab WHERE lab_code IN ('LAB-EEE-001', 'LAB-EEE-003') LIMIT 1);
SET @lab_me_id = (SELECT id FROM t_lab WHERE lab_code = 'LAB-ME-001' LIMIT 1);
SET @lab_mgt_id = (SELECT id FROM t_lab WHERE lab_code = 'LAB-MGT-001' LIMIT 1);
SET @lab_art_id = (SELECT id FROM t_lab WHERE lab_code = 'LAB-ART-001' LIMIT 1);
SET @lab_fla_id = (SELECT id FROM t_lab WHERE lab_code = 'LAB-FLA-001' LIMIT 1);

UPDATE t_user SET lab_id = NULL WHERE username = 'superadmin';
UPDATE t_user SET lab_id = @lab_cs_id WHERE username = 'cs_admin';
UPDATE t_user SET lab_id = @lab_ai_id WHERE username = 'ai_admin';
UPDATE t_user SET lab_id = @lab_eee_id WHERE username = 'ee_admin';
UPDATE t_user SET lab_id = @lab_me_id WHERE username = 'me_admin';
UPDATE t_user SET lab_id = @lab_mgt_id WHERE username = 'mgt_admin';
UPDATE t_user SET lab_id = @lab_art_id WHERE username = 'art_admin';
UPDATE t_user SET lab_id = @lab_fla_id WHERE username = 'fla_admin';

UPDATE t_user SET lab_id = @lab_cs_id WHERE username = 'teacher_cs_01';
UPDATE t_user SET lab_id = @lab_ai_id WHERE username = 'teacher_ai_01';
UPDATE t_user SET lab_id = @lab_eee_id WHERE username = 'teacher_ee_01';
UPDATE t_user SET lab_id = @lab_me_id WHERE username = 'teacher_me_01';
UPDATE t_user SET lab_id = @lab_mgt_id WHERE username = 'teacher_mgt_01';
UPDATE t_user SET lab_id = @lab_art_id WHERE username = 'teacher_art_01';
UPDATE t_user SET lab_id = @lab_fla_id WHERE username = 'teacher_fla_01';

UPDATE t_user SET lab_id = @lab_cs_id WHERE username IN ('20231001', '20231002');
UPDATE t_user SET lab_id = @lab_ai_id WHERE username IN ('20231003', '20231004');
UPDATE t_user SET lab_id = @lab_eee_id WHERE username IN ('20231005', '20231006');
UPDATE t_user SET lab_id = @lab_me_id WHERE username IN ('20231007', '20231008');
UPDATE t_user SET lab_id = @lab_mgt_id WHERE username IN ('20231009', '20231010');
UPDATE t_user SET lab_id = @lab_art_id WHERE username IN ('20231011', '20231012');
UPDATE t_user SET lab_id = @lab_fla_id WHERE username IN ('20231013', '20231014');

INSERT INTO t_lab_teacher_relation (lab_id, user_id, is_primary, status, remark, deleted)
VALUES
    (@lab_cs_id, @teacher_cs_id, 1, 'active', 'base demo advisor', 0),
    (@lab_ai_id, @teacher_ai_id, 1, 'active', 'base demo advisor', 0),
    (@lab_eee_id, @teacher_ee_id, 1, 'active', 'base demo advisor', 0),
    (@lab_me_id, @teacher_me_id, 1, 'active', 'base demo advisor', 0),
    (@lab_mgt_id, @teacher_mgt_id, 1, 'active', 'base demo advisor', 0),
    (@lab_art_id, @teacher_art_id, 1, 'active', 'base demo advisor', 0),
    (@lab_fla_id, @teacher_fla_id, 1, 'active', 'base demo advisor', 0)
ON DUPLICATE KEY UPDATE
    is_primary = VALUES(is_primary),
    status = VALUES(status),
    remark = VALUES(remark);

UPDATE t_lab_member
SET member_role = 'lab_leader', join_date = '2026-03-01', quit_date = NULL, status = 'active', appointed_by = @cs_admin_id, remark = 'base demo lab leader'
WHERE lab_id = @lab_cs_id AND user_id = @student_20231001_id AND deleted = 0;
INSERT INTO t_lab_member (lab_id, user_id, member_role, join_date, status, appointed_by, remark, deleted)
SELECT @lab_cs_id, @student_20231001_id, 'lab_leader', '2026-03-01', 'active', @cs_admin_id, 'base demo lab leader', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM t_lab_member WHERE lab_id = @lab_cs_id AND user_id = @student_20231001_id AND deleted = 0);

UPDATE t_lab_member
SET member_role = 'member', join_date = '2026-03-02', quit_date = NULL, status = 'active', appointed_by = @cs_admin_id, remark = 'base demo member'
WHERE lab_id = @lab_cs_id AND user_id = @student_20231002_id AND deleted = 0;
INSERT INTO t_lab_member (lab_id, user_id, member_role, join_date, status, appointed_by, remark, deleted)
SELECT @lab_cs_id, @student_20231002_id, 'member', '2026-03-02', 'active', @cs_admin_id, 'base demo member', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM t_lab_member WHERE lab_id = @lab_cs_id AND user_id = @student_20231002_id AND deleted = 0);

UPDATE t_lab_member
SET member_role = 'lab_leader', join_date = '2026-03-01', quit_date = NULL, status = 'active', appointed_by = @ai_admin_id, remark = 'base demo lab leader'
WHERE lab_id = @lab_ai_id AND user_id = @student_20231003_id AND deleted = 0;
INSERT INTO t_lab_member (lab_id, user_id, member_role, join_date, status, appointed_by, remark, deleted)
SELECT @lab_ai_id, @student_20231003_id, 'lab_leader', '2026-03-01', 'active', @ai_admin_id, 'base demo lab leader', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM t_lab_member WHERE lab_id = @lab_ai_id AND user_id = @student_20231003_id AND deleted = 0);

UPDATE t_lab_member
SET member_role = 'member', join_date = '2026-03-02', quit_date = NULL, status = 'active', appointed_by = @ai_admin_id, remark = 'base demo member'
WHERE lab_id = @lab_ai_id AND user_id = @student_20231004_id AND deleted = 0;
INSERT INTO t_lab_member (lab_id, user_id, member_role, join_date, status, appointed_by, remark, deleted)
SELECT @lab_ai_id, @student_20231004_id, 'member', '2026-03-02', 'active', @ai_admin_id, 'base demo member', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM t_lab_member WHERE lab_id = @lab_ai_id AND user_id = @student_20231004_id AND deleted = 0);

UPDATE t_lab_member
SET member_role = 'lab_leader', join_date = '2026-03-01', quit_date = NULL, status = 'active', appointed_by = @ee_admin_id, remark = 'base demo lab leader'
WHERE lab_id = @lab_eee_id AND user_id = @student_20231005_id AND deleted = 0;
INSERT INTO t_lab_member (lab_id, user_id, member_role, join_date, status, appointed_by, remark, deleted)
SELECT @lab_eee_id, @student_20231005_id, 'lab_leader', '2026-03-01', 'active', @ee_admin_id, 'base demo lab leader', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM t_lab_member WHERE lab_id = @lab_eee_id AND user_id = @student_20231005_id AND deleted = 0);

UPDATE t_lab_member
SET member_role = 'member', join_date = '2026-03-02', quit_date = NULL, status = 'active', appointed_by = @ee_admin_id, remark = 'base demo member'
WHERE lab_id = @lab_eee_id AND user_id = @student_20231006_id AND deleted = 0;
INSERT INTO t_lab_member (lab_id, user_id, member_role, join_date, status, appointed_by, remark, deleted)
SELECT @lab_eee_id, @student_20231006_id, 'member', '2026-03-02', 'active', @ee_admin_id, 'base demo member', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM t_lab_member WHERE lab_id = @lab_eee_id AND user_id = @student_20231006_id AND deleted = 0);

UPDATE t_lab_member
SET member_role = 'lab_leader', join_date = '2026-03-01', quit_date = NULL, status = 'active', appointed_by = @me_admin_id, remark = 'base demo lab leader'
WHERE lab_id = @lab_me_id AND user_id = @student_20231007_id AND deleted = 0;
INSERT INTO t_lab_member (lab_id, user_id, member_role, join_date, status, appointed_by, remark, deleted)
SELECT @lab_me_id, @student_20231007_id, 'lab_leader', '2026-03-01', 'active', @me_admin_id, 'base demo lab leader', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM t_lab_member WHERE lab_id = @lab_me_id AND user_id = @student_20231007_id AND deleted = 0);

UPDATE t_lab_member
SET member_role = 'member', join_date = '2026-03-02', quit_date = NULL, status = 'active', appointed_by = @me_admin_id, remark = 'base demo member'
WHERE lab_id = @lab_me_id AND user_id = @student_20231008_id AND deleted = 0;
INSERT INTO t_lab_member (lab_id, user_id, member_role, join_date, status, appointed_by, remark, deleted)
SELECT @lab_me_id, @student_20231008_id, 'member', '2026-03-02', 'active', @me_admin_id, 'base demo member', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM t_lab_member WHERE lab_id = @lab_me_id AND user_id = @student_20231008_id AND deleted = 0);

UPDATE t_lab_member
SET member_role = 'lab_leader', join_date = '2026-03-01', quit_date = NULL, status = 'active', appointed_by = @mgt_admin_id, remark = 'base demo lab leader'
WHERE lab_id = @lab_mgt_id AND user_id = @student_20231009_id AND deleted = 0;
INSERT INTO t_lab_member (lab_id, user_id, member_role, join_date, status, appointed_by, remark, deleted)
SELECT @lab_mgt_id, @student_20231009_id, 'lab_leader', '2026-03-01', 'active', @mgt_admin_id, 'base demo lab leader', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM t_lab_member WHERE lab_id = @lab_mgt_id AND user_id = @student_20231009_id AND deleted = 0);

UPDATE t_lab_member
SET member_role = 'member', join_date = '2026-03-02', quit_date = NULL, status = 'active', appointed_by = @mgt_admin_id, remark = 'base demo member'
WHERE lab_id = @lab_mgt_id AND user_id = @student_20231010_id AND deleted = 0;
INSERT INTO t_lab_member (lab_id, user_id, member_role, join_date, status, appointed_by, remark, deleted)
SELECT @lab_mgt_id, @student_20231010_id, 'member', '2026-03-02', 'active', @mgt_admin_id, 'base demo member', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM t_lab_member WHERE lab_id = @lab_mgt_id AND user_id = @student_20231010_id AND deleted = 0);

UPDATE t_lab_member
SET member_role = 'lab_leader', join_date = '2026-03-01', quit_date = NULL, status = 'active', appointed_by = @art_admin_id, remark = 'base demo lab leader'
WHERE lab_id = @lab_art_id AND user_id = @student_20231011_id AND deleted = 0;
INSERT INTO t_lab_member (lab_id, user_id, member_role, join_date, status, appointed_by, remark, deleted)
SELECT @lab_art_id, @student_20231011_id, 'lab_leader', '2026-03-01', 'active', @art_admin_id, 'base demo lab leader', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM t_lab_member WHERE lab_id = @lab_art_id AND user_id = @student_20231011_id AND deleted = 0);

UPDATE t_lab_member
SET member_role = 'member', join_date = '2026-03-02', quit_date = NULL, status = 'active', appointed_by = @art_admin_id, remark = 'base demo member'
WHERE lab_id = @lab_art_id AND user_id = @student_20231012_id AND deleted = 0;
INSERT INTO t_lab_member (lab_id, user_id, member_role, join_date, status, appointed_by, remark, deleted)
SELECT @lab_art_id, @student_20231012_id, 'member', '2026-03-02', 'active', @art_admin_id, 'base demo member', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM t_lab_member WHERE lab_id = @lab_art_id AND user_id = @student_20231012_id AND deleted = 0);

UPDATE t_lab_member
SET member_role = 'lab_leader', join_date = '2026-03-01', quit_date = NULL, status = 'active', appointed_by = @fla_admin_id, remark = 'base demo lab leader'
WHERE lab_id = @lab_fla_id AND user_id = @student_20231013_id AND deleted = 0;
INSERT INTO t_lab_member (lab_id, user_id, member_role, join_date, status, appointed_by, remark, deleted)
SELECT @lab_fla_id, @student_20231013_id, 'lab_leader', '2026-03-01', 'active', @fla_admin_id, 'base demo lab leader', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM t_lab_member WHERE lab_id = @lab_fla_id AND user_id = @student_20231013_id AND deleted = 0);

UPDATE t_lab_member
SET member_role = 'member', join_date = '2026-03-02', quit_date = NULL, status = 'active', appointed_by = @fla_admin_id, remark = 'base demo member'
WHERE lab_id = @lab_fla_id AND user_id = @student_20231014_id AND deleted = 0;
INSERT INTO t_lab_member (lab_id, user_id, member_role, join_date, status, appointed_by, remark, deleted)
SELECT @lab_fla_id, @student_20231014_id, 'member', '2026-03-02', 'active', @fla_admin_id, 'base demo member', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM t_lab_member WHERE lab_id = @lab_fla_id AND user_id = @student_20231014_id AND deleted = 0);

INSERT INTO t_lab_space_folder (lab_id, parent_id, folder_name, category, sort_order, access_scope, archived, created_by, deleted)
SELECT l.id, 0, '基础档案', 'profile', 10, 'lab', 0, NULL, 0
FROM t_lab l
WHERE l.deleted = 0
  AND NOT EXISTS (
      SELECT 1 FROM t_lab_space_folder f
      WHERE f.lab_id = l.id AND f.category = 'profile' AND f.deleted = 0
  );

INSERT INTO t_lab_space_folder (lab_id, parent_id, folder_name, category, sort_order, access_scope, archived, created_by, deleted)
SELECT l.id, 0, '招募归档', 'recruit', 20, 'lab', 0, NULL, 0
FROM t_lab l
WHERE l.deleted = 0
  AND NOT EXISTS (
      SELECT 1 FROM t_lab_space_folder f
      WHERE f.lab_id = l.id AND f.category = 'recruit' AND f.deleted = 0
  );

INSERT INTO t_lab_space_folder (lab_id, parent_id, folder_name, category, sort_order, access_scope, archived, created_by, deleted)
SELECT l.id, 0, '成员资料', 'member', 30, 'lab', 0, NULL, 0
FROM t_lab l
WHERE l.deleted = 0
  AND NOT EXISTS (
      SELECT 1 FROM t_lab_space_folder f
      WHERE f.lab_id = l.id AND f.category = 'member' AND f.deleted = 0
  );

INSERT INTO t_lab_space_folder (lab_id, parent_id, folder_name, category, sort_order, access_scope, archived, created_by, deleted)
SELECT l.id, 0, '项目文档', 'project', 40, 'lab', 0, NULL, 0
FROM t_lab l
WHERE l.deleted = 0
  AND NOT EXISTS (
      SELECT 1 FROM t_lab_space_folder f
      WHERE f.lab_id = l.id AND f.category = 'project' AND f.deleted = 0
  );

UPDATE t_recruit_plan
SET start_time = '2026-04-01 08:00:00', end_time = '2026-05-31 23:59:59', quota = 8,
    requirement = '具备对应专业基础，愿意参与项目制训练。', status = 'open', created_by = @cs_admin_id, deleted = 0
WHERE lab_id = @lab_cs_id AND title = '智能软件与应用创新实验室 2026 春季招募';
INSERT INTO t_recruit_plan (lab_id, title, start_time, end_time, quota, requirement, status, created_by, deleted)
SELECT @lab_cs_id, '智能软件与应用创新实验室 2026 春季招募', '2026-04-01 08:00:00', '2026-05-31 23:59:59', 8, '具备对应专业基础，愿意参与项目制训练。', 'open', @cs_admin_id, 0
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM t_recruit_plan WHERE lab_id = @lab_cs_id AND title = '智能软件与应用创新实验室 2026 春季招募' AND deleted = 0
);

UPDATE t_recruit_plan
SET start_time = '2026-04-01 08:00:00', end_time = '2026-05-31 23:59:59', quota = 8,
    requirement = '具备对应专业基础，愿意参与项目制训练。', status = 'open', created_by = @ai_admin_id, deleted = 0
WHERE lab_id = @lab_ai_id AND title = '数据智能决策实验室 2026 春季招募';
INSERT INTO t_recruit_plan (lab_id, title, start_time, end_time, quota, requirement, status, created_by, deleted)
SELECT @lab_ai_id, '数据智能决策实验室 2026 春季招募', '2026-04-01 08:00:00', '2026-05-31 23:59:59', 8, '具备对应专业基础，愿意参与项目制训练。', 'open', @ai_admin_id, 0
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM t_recruit_plan WHERE lab_id = @lab_ai_id AND title = '数据智能决策实验室 2026 春季招募' AND deleted = 0
);

UPDATE t_recruit_plan
SET start_time = '2026-04-01 08:00:00', end_time = '2026-05-31 23:59:59', quota = 8,
    requirement = '具备对应专业基础，愿意参与项目制训练。', status = 'open', created_by = @ee_admin_id, deleted = 0
WHERE lab_id = @lab_eee_id AND title = '工业智能与嵌入式系统实验室 2026 春季招募';
INSERT INTO t_recruit_plan (lab_id, title, start_time, end_time, quota, requirement, status, created_by, deleted)
SELECT @lab_eee_id, '工业智能与嵌入式系统实验室 2026 春季招募', '2026-04-01 08:00:00', '2026-05-31 23:59:59', 8, '具备对应专业基础，愿意参与项目制训练。', 'open', @ee_admin_id, 0
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM t_recruit_plan WHERE lab_id = @lab_eee_id AND title = '工业智能与嵌入式系统实验室 2026 春季招募' AND deleted = 0
);

UPDATE t_recruit_plan
SET start_time = '2026-04-01 08:00:00', end_time = '2026-05-31 23:59:59', quota = 8,
    requirement = '具备对应专业基础，愿意参与项目制训练。', status = 'open', created_by = @me_admin_id, deleted = 0
WHERE lab_id = @lab_me_id AND title = '智造装备与机器人实验室 2026 春季招募';
INSERT INTO t_recruit_plan (lab_id, title, start_time, end_time, quota, requirement, status, created_by, deleted)
SELECT @lab_me_id, '智造装备与机器人实验室 2026 春季招募', '2026-04-01 08:00:00', '2026-05-31 23:59:59', 8, '具备对应专业基础，愿意参与项目制训练。', 'open', @me_admin_id, 0
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM t_recruit_plan WHERE lab_id = @lab_me_id AND title = '智造装备与机器人实验室 2026 春季招募' AND deleted = 0
);

UPDATE t_recruit_plan
SET start_time = '2026-04-01 08:00:00', end_time = '2026-05-31 23:59:59', quota = 8,
    requirement = '具备对应专业基础，愿意参与项目制训练。', status = 'open', created_by = @mgt_admin_id, deleted = 0
WHERE lab_id = @lab_mgt_id AND title = '数字运营与商业分析实验室 2026 春季招募';
INSERT INTO t_recruit_plan (lab_id, title, start_time, end_time, quota, requirement, status, created_by, deleted)
SELECT @lab_mgt_id, '数字运营与商业分析实验室 2026 春季招募', '2026-04-01 08:00:00', '2026-05-31 23:59:59', 8, '具备对应专业基础，愿意参与项目制训练。', 'open', @mgt_admin_id, 0
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM t_recruit_plan WHERE lab_id = @lab_mgt_id AND title = '数字运营与商业分析实验室 2026 春季招募' AND deleted = 0
);

UPDATE t_recruit_plan
SET start_time = '2026-04-01 08:00:00', end_time = '2026-05-31 23:59:59', quota = 8,
    requirement = '具备对应专业基础，愿意参与项目制训练。', status = 'open', created_by = @art_admin_id, deleted = 0
WHERE lab_id = @lab_art_id AND title = '数字媒体与交互设计实验室 2026 春季招募';
INSERT INTO t_recruit_plan (lab_id, title, start_time, end_time, quota, requirement, status, created_by, deleted)
SELECT @lab_art_id, '数字媒体与交互设计实验室 2026 春季招募', '2026-04-01 08:00:00', '2026-05-31 23:59:59', 8, '具备对应专业基础，愿意参与项目制训练。', 'open', @art_admin_id, 0
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM t_recruit_plan WHERE lab_id = @lab_art_id AND title = '数字媒体与交互设计实验室 2026 春季招募' AND deleted = 0
);

UPDATE t_recruit_plan
SET start_time = '2026-04-01 08:00:00', end_time = '2026-05-31 23:59:59', quota = 8,
    requirement = '具备对应专业基础，愿意参与项目制训练。', status = 'open', created_by = @fla_admin_id, deleted = 0
WHERE lab_id = @lab_fla_id AND title = '数字人文与跨文化传播实验室 2026 春季招募';
INSERT INTO t_recruit_plan (lab_id, title, start_time, end_time, quota, requirement, status, created_by, deleted)
SELECT @lab_fla_id, '数字人文与跨文化传播实验室 2026 春季招募', '2026-04-01 08:00:00', '2026-05-31 23:59:59', 8, '具备对应专业基础，愿意参与项目制训练。', 'open', @fla_admin_id, 0
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM t_recruit_plan WHERE lab_id = @lab_fla_id AND title = '数字人文与跨文化传播实验室 2026 春季招募' AND deleted = 0
);

UPDATE t_notice
SET content = '学校版实验室平台基础账号与测试实验室已经初始化完成，可直接使用管理员、老师、学生账号登录。', publish_scope = 'school', college_id = NULL, lab_id = NULL, publisher_id = @school_admin_id, status = 1, publish_time = '2026-04-21 09:00:00', deleted = 0
WHERE title = '基础测试数据初始化完成';
INSERT INTO t_notice (title, content, publish_scope, college_id, lab_id, publisher_id, status, publish_time, deleted)
SELECT '基础测试数据初始化完成', '学校版实验室平台基础账号与测试实验室已经初始化完成，可直接使用管理员、老师、学生账号登录。', 'school', NULL, NULL, @school_admin_id, 1, '2026-04-21 09:00:00', 0
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM t_notice WHERE title = '基础测试数据初始化完成' AND deleted = 0
);

UPDATE t_notice
SET content = '各学院负责人已完成固定账号创建，请登录后核对实验室、老师与学生测试数据。', publish_scope = 'school', college_id = NULL, lab_id = NULL, publisher_id = @school_admin_id, status = 1, publish_time = '2026-04-21 09:10:00', deleted = 0
WHERE title = '学院管理员账号已就绪';
INSERT INTO t_notice (title, content, publish_scope, college_id, lab_id, publisher_id, status, publish_time, deleted)
SELECT '学院管理员账号已就绪', '各学院负责人已完成固定账号创建，请登录后核对实验室、老师与学生测试数据。', 'school', NULL, NULL, @school_admin_id, 1, '2026-04-21 09:10:00', 0
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM t_notice WHERE title = '学院管理员账号已就绪' AND deleted = 0
);

UPDATE t_notice
SET content = '智能软件与应用创新实验室本周开放体验，欢迎测试老师端、学生端和实验室资料空间。', publish_scope = 'lab', college_id = @college_cs_id, lab_id = @lab_cs_id, publisher_id = @teacher_cs_id, status = 1, publish_time = '2026-04-21 14:00:00', deleted = 0
WHERE title = '智能软件实验室体验开放';
INSERT INTO t_notice (title, content, publish_scope, college_id, lab_id, publisher_id, status, publish_time, deleted)
SELECT '智能软件实验室体验开放', '智能软件与应用创新实验室本周开放体验，欢迎测试老师端、学生端和实验室资料空间。', 'lab', @college_cs_id, @lab_cs_id, @teacher_cs_id, 1, '2026-04-21 14:00:00', 0
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM t_notice WHERE title = '智能软件实验室体验开放' AND deleted = 0
);
