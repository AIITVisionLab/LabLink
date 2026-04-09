SET @table_exists = (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 't_notice');
SET @index_exists = (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 't_notice' AND index_name = 'idx_notice_deleted_scope_status_time');
SET @sql = IF(@table_exists > 0 AND @index_exists = 0, 'CREATE INDEX idx_notice_deleted_scope_status_time ON t_notice (deleted, publish_scope, status, publish_time, id)', 'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @table_exists = (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 't_notice');
SET @index_exists = (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 't_notice' AND index_name = 'idx_notice_deleted_college_status_time');
SET @sql = IF(@table_exists > 0 AND @index_exists = 0, 'CREATE INDEX idx_notice_deleted_college_status_time ON t_notice (deleted, college_id, status, publish_time, id)', 'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @table_exists = (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 't_notice');
SET @index_exists = (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 't_notice' AND index_name = 'idx_notice_deleted_lab_status_time');
SET @sql = IF(@table_exists > 0 AND @index_exists = 0, 'CREATE INDEX idx_notice_deleted_lab_status_time ON t_notice (deleted, lab_id, status, publish_time, id)', 'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @table_exists = (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 't_notice');
SET @index_exists = (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 't_notice' AND index_name = 'ft_notice_title_content');
SET @ngram_exists = (SELECT COUNT(*) FROM information_schema.plugins WHERE plugin_name = 'ngram' AND plugin_status = 'ACTIVE');
SET @sql = IF(@table_exists > 0 AND @index_exists = 0,
    IF(@ngram_exists > 0,
        'CREATE FULLTEXT INDEX ft_notice_title_content ON t_notice (title, content) WITH PARSER ngram',
        'CREATE FULLTEXT INDEX ft_notice_title_content ON t_notice (title, content)'
    ),
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @table_exists = (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 't_lab');
SET @index_exists = (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 't_lab' AND index_name = 'idx_lab_deleted_college_status_create');
SET @sql = IF(@table_exists > 0 AND @index_exists = 0, 'CREATE INDEX idx_lab_deleted_college_status_create ON t_lab (deleted, college_id, status, create_time, id)', 'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @table_exists = (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 't_user');
SET @index_exists = (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 't_user' AND index_name = 'idx_user_role_deleted_create');
SET @sql = IF(@table_exists > 0 AND @index_exists = 0, 'CREATE INDEX idx_user_role_deleted_create ON t_user (role, deleted, create_time, id)', 'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @table_exists = (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 't_delivery');
SET @index_exists = (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 't_delivery' AND index_name = 'idx_delivery_lab_deleted_user');
SET @sql = IF(@table_exists > 0 AND @index_exists = 0, 'CREATE INDEX idx_delivery_lab_deleted_user ON t_delivery (lab_id, deleted, user_id)', 'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @table_exists = (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 't_recruit_plan');
SET @index_exists = (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 't_recruit_plan' AND index_name = 'idx_recruit_plan_lab_status_time');
SET @sql = IF(@table_exists > 0 AND @index_exists = 0, 'CREATE INDEX idx_recruit_plan_lab_status_time ON t_recruit_plan (lab_id, status, start_time, end_time)', 'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
