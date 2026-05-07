-- 西藏文旅演示数据脚本
-- 适用库：aftourism_server
-- 说明：
-- 1. 保留管理员、菜单、权限、系统配置、景区、场馆等基础数据。
-- 2. 清理并重铺门户/后台演示业务数据。
-- 3. demo_ 前缀门户用户统一演示密码：123456。

SET NAMES utf8mb4;
SET time_zone = '+08:00';

START TRANSACTION;

-- ----------------------------------------
-- 1. 清理旧演示业务数据（按外键依赖顺序）
-- ----------------------------------------
DELETE FROM t_content_report;
DELETE FROM t_portal_notification;
DELETE FROM t_user_favorite;
DELETE FROM t_message_feedback_comment;
DELETE FROM t_message_feedback;
DELETE FROM t_activity_comment;
DELETE FROM t_activity_apply;
DELETE FROM t_activity;
DELETE FROM t_exchange_comment;
DELETE FROM t_exchange_article;
DELETE FROM t_user_qualification_apply;
DELETE FROM t_home_scenic;
DELETE FROM t_home_banner;
DELETE FROM t_home_intro;
DELETE FROM t_news;
DELETE FROM t_notice;

-- ----------------------------------------
-- 2. 取真实景区/场馆变量，并强化重点地点排序与热度
-- ----------------------------------------
SET @scenic_potala = COALESCE((SELECT id FROM t_scenic_spot WHERE name = '布达拉宫' AND is_deleted = 0 LIMIT 1), (SELECT MIN(id) FROM t_scenic_spot WHERE is_deleted = 0));
SET @scenic_jokhang = COALESCE((SELECT id FROM t_scenic_spot WHERE name = '大昭寺' AND is_deleted = 0 LIMIT 1), @scenic_potala);
SET @scenic_tashilhunpo = COALESCE((SELECT id FROM t_scenic_spot WHERE name = '扎什伦布寺' AND is_deleted = 0 LIMIT 1), @scenic_potala);
SET @scenic_basum = COALESCE((SELECT id FROM t_scenic_spot WHERE name = '巴松措' AND is_deleted = 0 LIMIT 1), @scenic_potala);
SET @scenic_canyon = COALESCE((SELECT id FROM t_scenic_spot WHERE name = '雅鲁藏布大峡谷' AND is_deleted = 0 LIMIT 1), @scenic_potala);
SET @scenic_norbulingka = COALESCE((SELECT id FROM t_scenic_spot WHERE name = '罗布林卡' AND is_deleted = 0 LIMIT 1), @scenic_potala);
SET @scenic_tibet_museum = COALESCE((SELECT id FROM t_scenic_spot WHERE name = '西藏博物馆' AND is_deleted = 0 LIMIT 1), @scenic_potala);
SET @scenic_drepung = COALESCE((SELECT id FROM t_scenic_spot WHERE name = '哲蚌寺' AND is_deleted = 0 LIMIT 1), @scenic_potala);
SET @scenic_yak_museum = COALESCE((SELECT id FROM t_scenic_spot WHERE name = '西藏牦牛博物馆' AND is_deleted = 0 LIMIT 1), @scenic_potala);
SET @scenic_namco = COALESCE((SELECT id FROM t_scenic_spot WHERE name = '纳木措国家风景区' AND is_deleted = 0 LIMIT 1), @scenic_potala);

SET @venue_tibet_museum = COALESCE((SELECT id FROM t_venue WHERE name = '西藏博物馆' AND is_deleted = 0 LIMIT 1), (SELECT MIN(id) FROM t_venue WHERE is_deleted = 0));
SET @venue_contemporary_art = COALESCE((SELECT id FROM t_venue WHERE name = '介观当代艺术博物馆' AND is_deleted = 0 LIMIT 1), @venue_tibet_museum);
SET @venue_ich = COALESCE((SELECT id FROM t_venue WHERE name = '西藏非物质文化遗产博物馆' AND is_deleted = 0 LIMIT 1), @venue_tibet_museum);
SET @venue_yak = COALESCE((SELECT id FROM t_venue WHERE name = '西藏牦牛博物馆' AND is_deleted = 0 LIMIT 1), @venue_tibet_museum);
SET @venue_natural = COALESCE((SELECT id FROM t_venue WHERE name = '西藏自然科学博物馆' AND is_deleted = 0 LIMIT 1), @venue_tibet_museum);
SET @venue_thangka = COALESCE((SELECT id FROM t_venue WHERE name = '唐卡之都博物馆' AND is_deleted = 0 LIMIT 1), @venue_tibet_museum);
SET @venue_culture_palace = COALESCE((SELECT id FROM t_venue WHERE name = '拉萨民族文化艺术宫' AND is_deleted = 0 LIMIT 1), @venue_tibet_museum);
SET @venue_shannan_center = COALESCE((SELECT id FROM t_venue WHERE name = '山南市文化艺术中心' AND is_deleted = 0 LIMIT 1), @venue_tibet_museum);
SET @venue_thangka_park = COALESCE((SELECT id FROM t_venue WHERE name = '西藏唐卡文化艺术创作园区' AND is_deleted = 0 LIMIT 1), @venue_tibet_museum);
SET @venue_sports_center = COALESCE((SELECT id FROM t_venue WHERE name = '拉萨市群众文化体育中心' AND is_deleted = 0 LIMIT 1), @venue_tibet_museum);

-- 补齐景区/场馆联系电话与门票价格，均为演示用确定性生成值
UPDATE t_scenic_spot
SET phone = CASE
        WHEN phone IS NULL OR phone = '' OR phone = '[]' THEN CONCAT(
            CASE
                WHEN city LIKE '%日喀则%' THEN '0892'
                WHEN city LIKE '%山南%' THEN '0893'
                WHEN city LIKE '%林芝%' THEN '0894'
                WHEN city LIKE '%昌都%' THEN '0895'
                WHEN city LIKE '%那曲%' THEN '0896'
                WHEN city LIKE '%阿里%' THEN '0897'
                ELSE '0891'
            END,
            '-',
            LPAD(6000000 + MOD(id * 137, 3000000), 7, '0')
        )
        ELSE phone
    END,
    ticket_price = CASE
        WHEN ticket_price IS NULL THEN CAST(
            CASE
                WHEN level = '5A' THEN 120 + MOD(id * 17, 81)
                WHEN level = '4A' AND (tags LIKE '%博物馆%' OR tags LIKE '%公园%') THEN MOD(id * 7, 2) * 20
                WHEN level = '4A' THEN 40 + MOD(id * 13, 81)
                WHEN level IN ('3A', '2A') THEN 20 + MOD(id * 11, 41)
                WHEN level IN ('1A', 'A') THEN MOD(id * 9, 31)
                ELSE 20 + MOD(id * 7, 61)
            END AS DECIMAL(10, 2)
        )
        ELSE ticket_price
    END,
    update_time = NOW()
WHERE is_deleted = 0
  AND (phone IS NULL OR phone = '' OR phone = '[]' OR ticket_price IS NULL);

UPDATE t_venue
SET phone = CASE
        WHEN phone IS NULL OR phone = '' OR phone = '[]' THEN CONCAT(
            CASE
                WHEN city LIKE '%日喀则%' THEN '0892'
                WHEN city LIKE '%山南%' THEN '0893'
                WHEN city LIKE '%林芝%' THEN '0894'
                WHEN city LIKE '%昌都%' THEN '0895'
                WHEN city LIKE '%那曲%' THEN '0896'
                WHEN city LIKE '%阿里%' THEN '0897'
                ELSE '0891'
            END,
            '-',
            LPAD(6100000 + MOD(id * 149, 2800000), 7, '0')
        )
        ELSE phone
    END,
    ticket_price = CASE
        WHEN ticket_price IS NULL THEN CAST(
            CASE
                WHEN category LIKE '%图书馆%' OR category LIKE '%文化站%' OR category LIKE '%文化宫%' THEN 0
                WHEN category LIKE '%博物馆%' AND MOD(id, 4) <> 0 THEN 0
                WHEN category LIKE '%博物馆%' THEN 20 + MOD(id * 7, 31)
                WHEN category LIKE '%艺术%' OR category LIKE '%演出%' THEN 30 + MOD(id * 11, 51)
                WHEN category LIKE '%体育%' THEN 20 + MOD(id * 13, 41)
                ELSE 10 + MOD(id * 17, 61)
            END AS DECIMAL(10, 2)
        )
        ELSE ticket_price
    END,
    is_free = CASE
        WHEN ticket_price IS NULL THEN
            CASE
                WHEN category LIKE '%图书馆%' OR category LIKE '%文化站%' OR category LIKE '%文化宫%' THEN 1
                WHEN category LIKE '%博物馆%' AND MOD(id, 4) <> 0 THEN 1
                ELSE 0
            END
        ELSE is_free
    END,
    update_time = NOW()
WHERE is_deleted = 0
  AND (phone IS NULL OR phone = '' OR phone = '[]' OR ticket_price IS NULL);

UPDATE t_venue
SET is_free = CASE WHEN ticket_price = 0 THEN 1 ELSE 0 END,
    update_time = NOW()
WHERE is_deleted = 0
  AND ticket_price IS NOT NULL;

UPDATE t_scenic_spot
SET sort = CASE id
        WHEN @scenic_potala THEN 100
        WHEN @scenic_jokhang THEN 98
        WHEN @scenic_tashilhunpo THEN 96
        WHEN @scenic_basum THEN 94
        WHEN @scenic_canyon THEN 92
        WHEN @scenic_norbulingka THEN 90
        WHEN @scenic_tibet_museum THEN 88
        WHEN @scenic_drepung THEN 86
        WHEN @scenic_yak_museum THEN 84
        WHEN @scenic_namco THEN 82
        ELSE sort
    END,
    view_count = CASE id
        WHEN @scenic_potala THEN 8650
        WHEN @scenic_jokhang THEN 7410
        WHEN @scenic_tashilhunpo THEN 5280
        WHEN @scenic_basum THEN 4930
        WHEN @scenic_canyon THEN 6320
        WHEN @scenic_norbulingka THEN 3860
        WHEN @scenic_tibet_museum THEN 3540
        WHEN @scenic_drepung THEN 3180
        WHEN @scenic_yak_museum THEN 2760
        WHEN @scenic_namco THEN 4590
        ELSE view_count
    END,
    update_time = NOW()
WHERE id IN (@scenic_potala, @scenic_jokhang, @scenic_tashilhunpo, @scenic_basum, @scenic_canyon, @scenic_norbulingka, @scenic_tibet_museum, @scenic_drepung, @scenic_yak_museum, @scenic_namco);

UPDATE t_venue
SET sort = CASE id
        WHEN @venue_tibet_museum THEN 100
        WHEN @venue_ich THEN 96
        WHEN @venue_yak THEN 94
        WHEN @venue_natural THEN 92
        WHEN @venue_thangka THEN 90
        WHEN @venue_culture_palace THEN 88
        WHEN @venue_shannan_center THEN 86
        WHEN @venue_sports_center THEN 84
        ELSE sort
    END,
    view_count = CASE id
        WHEN @venue_tibet_museum THEN 5240
        WHEN @venue_ich THEN 4310
        WHEN @venue_yak THEN 3680
        WHEN @venue_natural THEN 3350
        WHEN @venue_thangka THEN 2810
        WHEN @venue_culture_palace THEN 2580
        WHEN @venue_shannan_center THEN 2190
        WHEN @venue_sports_center THEN 1960
        ELSE view_count
    END,
    update_time = NOW()
WHERE id IN (@venue_tibet_museum, @venue_ich, @venue_yak, @venue_natural, @venue_thangka, @venue_culture_palace, @venue_shannan_center, @venue_sports_center);

-- ----------------------------------------
-- 3. 门户演示用户
-- ----------------------------------------
-- 头像走后端文件服务，对应文件位于 uploads/user_avatar/2026/05/07/
INSERT INTO t_user
    (username, password, nickname, gender, phone, email, avatar, role_code, is_advanced, status, remark, is_deleted, create_time, update_time)
VALUES
    ('demo_lhamo', '$2a$10$A/S6MeEjExb5zk.KZwBFv./rdxNFcTqUVmMhYEjtkRIJaYA4ebXfu', '拉姆卓玛', '女', '13908910001', 'lhamo.demo@example.com', 'http://localhost:8080/files/user_avatar/2026/05/07/demo-lhamo.png', 'PORTAL_USER', 1, 1, '演示用户：西藏本地讲解员', 0, '2026-03-18 10:12:00', NOW()),
    ('demo_tenzin', '$2a$10$A/S6MeEjExb5zk.KZwBFv./rdxNFcTqUVmMhYEjtkRIJaYA4ebXfu', '次仁扎西', '男', '13908910002', 'tenzin.demo@example.com', 'http://localhost:8080/files/user_avatar/2026/05/07/demo-tenzin.png', 'PORTAL_USER', 1, 1, '演示用户：活动组织者', 0, '2026-03-20 09:30:00', NOW()),
    ('demo_nima', '$2a$10$A/S6MeEjExb5zk.KZwBFv./rdxNFcTqUVmMhYEjtkRIJaYA4ebXfu', '尼玛央金', '女', '13908910003', 'nima.demo@example.com', 'http://localhost:8080/files/user_avatar/2026/05/07/demo-nima.png', 'PORTAL_USER', 0, 1, '演示用户：亲子游客', 0, '2026-03-21 14:20:00', NOW()),
    ('demo_dawa', '$2a$10$A/S6MeEjExb5zk.KZwBFv./rdxNFcTqUVmMhYEjtkRIJaYA4ebXfu', '达瓦多吉', '男', '13908910004', 'dawa.demo@example.com', 'http://localhost:8080/files/user_avatar/2026/05/07/demo-dawa.png', 'PORTAL_USER', 0, 1, '演示用户：摄影爱好者', 0, '2026-03-24 16:40:00', NOW()),
    ('demo_pema', '$2a$10$A/S6MeEjExb5zk.KZwBFv./rdxNFcTqUVmMhYEjtkRIJaYA4ebXfu', '白玛曲珍', '女', '13908910005', 'pema.demo@example.com', 'http://localhost:8080/files/user_avatar/2026/05/07/demo-pema.png', 'PORTAL_USER', 0, 1, '演示用户：博物馆志愿者', 0, '2026-03-25 11:05:00', NOW()),
    ('demo_yonten', '$2a$10$A/S6MeEjExb5zk.KZwBFv./rdxNFcTqUVmMhYEjtkRIJaYA4ebXfu', '云登桑布', '男', '13908910006', 'yonten.demo@example.com', 'http://localhost:8080/files/user_avatar/2026/05/07/demo-yonten.png', 'PORTAL_USER', 1, 1, '演示用户：户外领队', 0, '2026-03-27 08:45:00', NOW()),
    ('demo_sonam', '$2a$10$A/S6MeEjExb5zk.KZwBFv./rdxNFcTqUVmMhYEjtkRIJaYA4ebXfu', '索南措姆', '女', '13908910007', 'sonam.demo@example.com', 'http://localhost:8080/files/user_avatar/2026/05/07/demo-sonam.png', 'PORTAL_USER', 0, 1, '演示用户：大学生游客', 0, '2026-03-28 19:10:00', NOW()),
    ('demo_karma', '$2a$10$A/S6MeEjExb5zk.KZwBFv./rdxNFcTqUVmMhYEjtkRIJaYA4ebXfu', '贡嘎嘉措', '男', '13908910008', 'karma.demo@example.com', 'http://localhost:8080/files/user_avatar/2026/05/07/demo-karma.png', 'PORTAL_USER', 0, 1, '演示用户：骑行爱好者', 0, '2026-03-30 15:15:00', NOW()),
    ('demo_maya', '$2a$10$A/S6MeEjExb5zk.KZwBFv./rdxNFcTqUVmMhYEjtkRIJaYA4ebXfu', '马雅', '女', '13908910009', 'maya.demo@example.com', 'http://localhost:8080/files/user_avatar/2026/05/07/demo-maya.png', 'PORTAL_USER', 0, 1, '演示用户：外地游客', 0, '2026-04-01 12:00:00', NOW()),
    ('demo_operator', '$2a$10$A/S6MeEjExb5zk.KZwBFv./rdxNFcTqUVmMhYEjtkRIJaYA4ebXfu', '平台运营助手', '未知', '13908910010', 'operator.demo@example.com', 'http://localhost:8080/files/user_avatar/2026/05/07/demo-operator.png', 'PORTAL_USER', 1, 1, '演示用户：用于前台互动回复', 0, '2026-04-02 10:00:00', NOW()),
    ('demo_guide', '$2a$10$A/S6MeEjExb5zk.KZwBFv./rdxNFcTqUVmMhYEjtkRIJaYA4ebXfu', '阿旺讲解员', '男', '13908910011', 'guide.demo@example.com', 'http://localhost:8080/files/user_avatar/2026/05/07/demo-guide.png', 'PORTAL_USER', 1, 1, '演示用户：认证讲解员', 0, '2026-04-05 09:00:00', NOW()),
    ('demo_student', '$2a$10$A/S6MeEjExb5zk.KZwBFv./rdxNFcTqUVmMhYEjtkRIJaYA4ebXfu', '林芝研学小队', '未知', '13908910012', 'student.demo@example.com', 'http://localhost:8080/files/user_avatar/2026/05/07/demo-student.png', 'PORTAL_USER', 0, 1, '演示用户：研学团队账号', 0, '2026-04-07 13:30:00', NOW())
ON DUPLICATE KEY UPDATE
    password = VALUES(password),
    nickname = VALUES(nickname),
    gender = VALUES(gender),
    phone = VALUES(phone),
    email = VALUES(email),
    avatar = VALUES(avatar),
    role_code = VALUES(role_code),
    is_advanced = VALUES(is_advanced),
    status = VALUES(status),
    remark = VALUES(remark),
    is_deleted = 0,
    update_time = NOW();

SET @u_lhamo = (SELECT id FROM t_user WHERE username = 'demo_lhamo' LIMIT 1);
SET @u_tenzin = (SELECT id FROM t_user WHERE username = 'demo_tenzin' LIMIT 1);
SET @u_nima = (SELECT id FROM t_user WHERE username = 'demo_nima' LIMIT 1);
SET @u_dawa = (SELECT id FROM t_user WHERE username = 'demo_dawa' LIMIT 1);
SET @u_pema = (SELECT id FROM t_user WHERE username = 'demo_pema' LIMIT 1);
SET @u_yonten = (SELECT id FROM t_user WHERE username = 'demo_yonten' LIMIT 1);
SET @u_sonam = (SELECT id FROM t_user WHERE username = 'demo_sonam' LIMIT 1);
SET @u_karma = (SELECT id FROM t_user WHERE username = 'demo_karma' LIMIT 1);
SET @u_maya = (SELECT id FROM t_user WHERE username = 'demo_maya' LIMIT 1);
SET @u_operator = (SELECT id FROM t_user WHERE username = 'demo_operator' LIMIT 1);
SET @u_guide = (SELECT id FROM t_user WHERE username = 'demo_guide' LIMIT 1);
SET @u_student = (SELECT id FROM t_user WHERE username = 'demo_student' LIMIT 1);

-- 兼容旧演示账号头像，避免前台回退为文字头像
UPDATE t_user
SET avatar = CASE username
        WHEN 'user5' THEN 'http://localhost:8080/files/user_avatar/2026/05/07/demo-sonam.png'
        WHEN 'user6' THEN 'http://localhost:8080/files/user_avatar/2026/05/07/demo-dawa.png'
        WHEN 'user7' THEN 'http://localhost:8080/files/user_avatar/2026/05/07/demo-karma.png'
        WHEN 'user8' THEN 'http://localhost:8080/files/user_avatar/2026/05/07/demo-pema.png'
        WHEN 'user9' THEN 'http://localhost:8080/files/user_avatar/2026/05/07/demo-yonten.png'
        WHEN 'user10' THEN 'http://localhost:8080/files/user_avatar/2026/05/07/demo-tenzin.png'
        WHEN 'user11' THEN 'http://localhost:8080/files/user_avatar/2026/05/07/demo-nima.png'
        WHEN 'user12' THEN 'http://localhost:8080/files/user_avatar/2026/05/07/demo-maya.png'
        ELSE avatar
    END,
    update_time = NOW()
WHERE username IN ('user5', 'user6', 'user7', 'user8', 'user9', 'user10', 'user11', 'user12')
  AND is_deleted = 0;

-- ----------------------------------------
-- 4. 新闻与公告
-- ----------------------------------------
INSERT INTO t_news
    (title, content, cover_url, publish_time, author, status, view_count, is_deleted, create_time, update_time)
VALUES
    ('2026西藏春夏文旅服务季启动', '<p>本演示新闻用于展示平台内容管理能力。2026年春夏服务季围绕预约导览、公共文化场馆、生态游线和社区互动展开，为游客提供更清晰的出行参考。</p><p>平台将持续更新景区开放信息、活动报名信息和场馆服务提醒。</p>', 'http://store.is.autonavi.com/showpic/abc43f4373ca7c3cd59e884283c31051', '2026-05-07 09:30:00', '西藏文旅演示中心', 1, 2860, 0, NOW(), NOW()),
    ('布达拉宫周边文明游览提示发布', '<p>围绕布达拉宫、大昭寺、八廓街等热门区域，平台整理了预约、拍照、步行线路和文明游览提示，帮助游客错峰出行。</p>', 'http://store.is.autonavi.com/showpic/9e29ebc1fbe5bb29f2fc83aa17bdb71d', '2026-05-06 14:10:00', '拉萨服务专班', 1, 2415, 0, NOW(), NOW()),
    ('西藏博物馆推出高原文明导览活动', '<p>西藏博物馆高原文明主题导览将结合馆藏文物、民俗展陈与研学问答，面向家庭游客和研学团队开放预约。</p>', 'http://store.is.autonavi.com/showpic/92dbc5423b126b7884d1295077870f6d', '2026-05-05 10:00:00', '公共文化场馆组', 1, 2210, 0, NOW(), NOW()),
    ('非遗体验活动报名通道上线', '<p>唐卡线描、藏香制作、传统服饰讲解等非遗体验内容已纳入活动模块。游客可在门户活动页查看时间、地点和报名须知。</p>', 'http://store.is.autonavi.com/showpic/1223e466d09e77dd82d68de268845319', '2026-05-04 16:20:00', '非遗活动运营组', 1, 1986, 0, NOW(), NOW()),
    ('林芝生态游线迎来春夏观景期', '<p>巴松措、雅鲁藏布大峡谷等生态游线进入适宜观景期。平台提示游客关注天气、交通和高原户外安全。</p>', 'http://store.is.autonavi.com/showpic/5cf852159a40e956aa76b02bd2de213f', '2026-05-03 11:40:00', '生态游线编辑组', 1, 1870, 0, NOW(), NOW()),
    ('山南雅砻文化主题内容更新', '<p>围绕藏源文化、博物馆展陈和传统村落体验，山南主题内容已完成一轮更新，适合一日游和研学线路展示。</p>', 'https://aos-comment.amap.com/B0G1TATR4G/comment/content_media_external_file_1000066673_ss__1757393011050_00490482.jpg', '2026-05-02 15:00:00', '山南内容协作组', 1, 1658, 0, NOW(), NOW()),
    ('纳木措观星安全清单上线', '<p>纳木措及周边高海拔夜间活动需提前关注保暖、供氧、交通和集合点信息。平台同步上线观星安全清单。</p>', 'http://store.is.autonavi.com/showpic/75d2306cb0ade904bad4ce0afb1d34c4', '2026-05-01 19:00:00', '户外安全编辑组', 1, 1765, 0, NOW(), NOW()),
    ('拉萨河城市漫步路线完成优化', '<p>演示数据新增拉萨河畔城市漫步活动，串联滨河公共空间、文化场馆与夜景观赏点，适合低强度休闲游。</p>', 'https://comment-oss-online.oss-cn-wulanchabu.aliyuncs.com/B0H10HVY44/comment/content_media_external_images_media_2652409_1652276490909_a8f6fe7e.jpg', '2026-04-30 17:30:00', '城市休闲组', 1, 1480, 0, NOW(), NOW()),
    ('高原亲子研学内容专区试运行', '<p>牦牛文化、自然科学、博物馆导览等亲子研学内容将集中展示，便于家庭游客筛选半日和一日体验项目。</p>', 'http://store.is.autonavi.com/showpic/30ffb6effdfae76ad3ae07424fa8a3bf', '2026-04-29 09:45:00', '研学服务组', 1, 1396, 0, NOW(), NOW()),
    ('活动审核流程演示数据已准备', '<p>后台活动审核、驳回、通过及关联正式活动的演示数据已就绪，可用于管理端流程讲解。</p>', 'http://store.is.autonavi.com/showpic/1934a84936a344bdf8bb53f4c0213de7', '2026-04-28 13:20:00', '平台运营组', 1, 1260, 0, NOW(), NOW()),
    ('交流社区游记分享功能完善', '<p>门户交流社区补充了游记、路线问答、举报处理和通知提醒演示数据，便于展示用户互动闭环。</p>', 'http://store.is.autonavi.com/showpic/6795bf614b062fbbcd95c1c1f17d03a7', '2026-04-27 15:10:00', '社区运营组', 1, 1188, 0, NOW(), NOW()),
    ('游客反馈处理样例上线', '<p>留言反馈模块新增待处理、已处理和追问回复样例，用于演示后台反馈管理与前台详情展示。</p>', 'http://store.is.autonavi.com/showpic/fe41f27428bb2020ebef8f347f6d616a', '2026-04-26 10:30:00', '客服体验组', 1, 1065, 0, NOW(), NOW());

SET @news_start = (SELECT id FROM t_news WHERE title = '2026西藏春夏文旅服务季启动' LIMIT 1);
SET @news_museum = (SELECT id FROM t_news WHERE title = '西藏博物馆推出高原文明导览活动' LIMIT 1);
SET @news_ich = (SELECT id FROM t_news WHERE title = '非遗体验活动报名通道上线' LIMIT 1);

INSERT INTO t_notice
    (title, content, publish_time, author, status, view_count, is_deleted, create_time, update_time)
VALUES
    ('五一后错峰游览服务提示', '<p>本演示公告提示游客关注热门景区预约时段，合理安排布达拉宫、大昭寺、罗布林卡等点位游览顺序。</p>', '2026-05-07 08:30:00', '平台运营组', 1, 1560, 0, NOW(), NOW()),
    ('布达拉宫夜景摄影公开课集合说明', '<p>报名成功游客请于活动开始前30分钟到达集合点，携带身份证件、保暖衣物和三脚架保护套。</p>', '2026-05-06 18:00:00', '活动服务组', 1, 1320, 0, NOW(), NOW()),
    ('场馆预约系统维护公告', '<p>5月12日凌晨进行预约系统维护，期间可能短暂影响场馆详情页访问，维护完成后自动恢复。</p>', '2026-05-05 20:00:00', '技术保障组', 1, 980, 0, NOW(), NOW()),
    ('高原户外活动安全提醒', '<p>参加徒步、骑行、观星等户外活动前，请评估身体状态，准备保暖、防晒、补水用品，并服从领队安排。</p>', '2026-05-04 09:00:00', '户外安全组', 1, 1680, 0, NOW(), NOW()),
    ('西藏博物馆导览日预约规则', '<p>导览活动按预约名单入场，团队账号请提前在个人中心完善联系方式，现场以短信和站内通知为准。</p>', '2026-05-03 11:15:00', '公共文化场馆组', 1, 1125, 0, NOW(), NOW()),
    ('交流社区文明互动公约', '<p>请勿发布广告、辱骂攻击、虚假低价揽客等内容。平台保留删除违规内容和限制账号操作的权利。</p>', '2026-05-02 10:00:00', '社区运营组', 1, 1410, 0, NOW(), NOW()),
    ('活动申报材料规范', '<p>活动申报需提交真实主办单位、联系人、场地信息、活动说明及安全预案。材料不完整将被驳回。</p>', '2026-05-01 16:40:00', '审核管理组', 1, 1188, 0, NOW(), NOW()),
    ('拉萨河城市漫步临时交通提醒', '<p>部分滨河道路周末人流较多，建议游客优先选择公共交通或步行接驳。</p>', '2026-04-30 19:20:00', '城市服务组', 1, 876, 0, NOW(), NOW()),
    ('反馈受理时间说明', '<p>游客留言反馈将在工作日内优先处理，紧急安全问题请同步联系现场服务电话。</p>', '2026-04-29 09:10:00', '客服体验组', 1, 760, 0, NOW(), NOW()),
    ('演示环境数据说明', '<p>本环境中的活动、报名、评论、举报和反馈均为演示数据，用于功能展示和流程验证。</p>', '2026-04-28 08:50:00', '平台运营组', 1, 690, 0, NOW(), NOW());

-- ----------------------------------------
-- 5. 活动与活动申报
-- ----------------------------------------
INSERT INTO t_activity
    (name, cover_url, start_time, end_time, category, venue_id, organizer, contact_phone, intro, address_cache, online_status, view_count, favorite_count, is_deleted, create_time, update_time)
VALUES
    ('布达拉宫夜景摄影公开课', 'http://store.is.autonavi.com/showpic/abc43f4373ca7c3cd59e884283c31051', '2026-05-15 19:30:00', '2026-05-15 21:30:00', '摄影', @venue_contemporary_art, '拉萨城市影像志愿队', '0891-6601001', '面向摄影爱好者的夜景拍摄公开课，讲解高原夜间曝光、机位选择和文明拍摄边界。活动为演示数据。', '拉萨市城关区北京中路及周边公共区域', 1, 2350, 0, 0, NOW(), NOW()),
    ('西藏博物馆高原文明导览日', 'http://store.is.autonavi.com/showpic/92dbc5423b126b7884d1295077870f6d', '2026-05-18 10:00:00', '2026-05-18 12:00:00', '展览', @venue_tibet_museum, '西藏博物馆志愿服务队', '0891-6839222', '围绕自然地理、历史文化和民俗展陈进行主题导览，适合初到拉萨游客和研学团队。活动为演示数据。', '罗布林卡路34号', 1, 3180, 0, 0, NOW(), NOW()),
    ('唐卡线描体验工作坊', 'http://store.is.autonavi.com/showpic/1223e466d09e77dd82d68de268845319', '2026-05-23 14:30:00', '2026-05-23 17:00:00', '非遗', @venue_thangka, '唐卡之都博物馆', '0891-6601003', '由讲解员介绍唐卡构图、线描和矿物颜料基础知识，参与者可完成一张入门线稿。活动为演示数据。', '鲁固一巷夏扎大院内', 1, 2260, 0, 0, NOW(), NOW()),
    ('牦牛文化亲子研学营', 'http://store.is.autonavi.com/showpic/30ffb6effdfae76ad3ae07424fa8a3bf', '2026-05-30 09:30:00', '2026-05-30 11:30:00', '研学', @venue_yak, '西藏牦牛博物馆公共教育部', '0891-6380000', '通过展陈导览、互动问答和手作环节认识牦牛与高原生活的关系，适合亲子家庭。活动为演示数据。', '柳梧新区察古大道16号', 1, 2015, 0, 0, NOW(), NOW()),
    ('拉萨河畔城市漫步', 'https://comment-oss-online.oss-cn-wulanchabu.aliyuncs.com/B0H10HVY44/comment/content_media_external_images_media_2652409_1652276490909_a8f6fe7e.jpg', '2026-06-06 17:00:00', '2026-06-06 19:00:00', '漫步', @venue_culture_palace, '拉萨城市公共文化观察团', '0891-6601005', '低强度城市步行活动，串联拉萨河公共空间、文化场馆和傍晚观景点。活动为演示数据。', '拉萨河两岸及太阳岛周边', 1, 1890, 0, 0, NOW(), NOW()),
    ('雅鲁藏布大峡谷影像分享会', 'http://store.is.autonavi.com/showpic/c39f3403de7d84e33ebff0316e8aa159', '2026-06-14 15:00:00', '2026-06-14 17:00:00', '讲座', @venue_tibet_museum, '林芝生态影像小组', '0891-6601006', '分享雅鲁藏布大峡谷自然地理、生态观察和旅行影像记录方法。活动为演示数据。', '罗布林卡路34号', 1, 1680, 0, 0, NOW(), NOW()),
    ('罗布林卡夏宫园林讲解', 'http://store.is.autonavi.com/showpic/6795bf614b062fbbcd95c1c1f17d03a7', '2026-06-21 09:30:00', '2026-06-21 11:00:00', '导览', @venue_tibet_museum, '拉萨历史文化讲解队', '0891-6601007', '以夏宫园林、建筑空间和历史故事为主线，讲解罗布林卡的游览方法。活动为演示数据。', '罗布林卡景区周边', 1, 1520, 0, 0, NOW(), NOW()),
    ('非遗藏香制作体验课', 'https://aos-comment.amap.com/B0JD7N9FKT/comment/content_media_external_images_media_1000188846_ss__1727329152509_76208824.jpg', '2026-06-28 14:00:00', '2026-06-28 16:30:00', '非遗', @venue_ich, '西藏非遗公共教育项目组', '0891-6601008', '通过材料识别、配方讲解和手作体验了解藏香制作流程。活动为演示数据。', '拉萨河畔慈觉林文城大道', 1, 1785, 0, 0, NOW(), NOW()),
    ('哲蚌寺雪顿节文化预热导览', 'http://store.is.autonavi.com/showpic/928935f92625f21c61dc40ef3e64f67a', '2026-07-04 09:00:00', '2026-07-04 11:30:00', '节庆', @venue_culture_palace, '雪顿节文化志愿讲解队', '0891-6601009', '面向游客介绍雪顿节习俗、展佛礼仪和文明参观注意事项。活动为演示数据。', '拉萨市城关区及哲蚌寺周边', 1, 2640, 0, 0, NOW(), NOW()),
    ('拉萨民族文化艺术宫周末展演', 'https://store.is.autonavi.com/showpic/b9f7e529fabfd182af9e7065774aad69', '2026-07-12 19:30:00', '2026-07-12 21:00:00', '演出', @venue_culture_palace, '拉萨民族文化艺术宫', '0891-6601010', '周末小型展演，包含传统乐舞赏析和互动讲解。活动为演示数据。', '太阳岛二路20号中和国际城', 1, 1430, 0, 0, NOW(), NOW()),
    ('山南雅砻文化讲堂', 'https://aos-comment.amap.com/B0G1TATR4G/comment/content_media_external_file_1000066673_ss__1757393011050_00490482.jpg', '2026-07-19 10:00:00', '2026-07-19 12:00:00', '讲座', @venue_shannan_center, '山南文化艺术中心', '0893-6601011', '围绕藏源文化、博物馆展陈和雅砻河谷游线进行主题分享。活动为演示数据。', '山南市香曲西路与格桑路交叉口北140米', 1, 1210, 0, 0, NOW(), NOW()),
    ('巴松措生态徒步说明会', 'http://store.is.autonavi.com/showpic/5cf852159a40e956aa76b02bd2de213f', '2026-07-26 15:00:00', '2026-07-26 16:30:00', '户外', @venue_natural, '林芝生态旅行观察团', '0891-6601012', '讲解巴松措周边徒步路线、垃圾带离、天气判断和高原生态观察注意事项。活动为演示数据。', '藏大东路9号', 1, 1325, 0, 0, NOW(), NOW()),
    ('纳木措星空观测公开课', 'http://store.is.autonavi.com/showpic/75d2306cb0ade904bad4ce0afb1d34c4', '2026-08-08 20:30:00', '2026-08-08 22:30:00', '观星', @venue_natural, '藏域星空科普小组', '0891-6601013', '介绍高海拔观星安全、星空摄影基础和夜间保暖清单。活动为演示数据。', '拉萨市科普活动集合点', 1, 2140, 0, 0, NOW(), NOW()),
    ('西藏自然科学博物馆高原生态课', 'http://store.is.autonavi.com/showpic/fe41f27428bb2020ebef8f347f6d616a', '2026-08-22 10:00:00', '2026-08-22 12:00:00', '科普', @venue_natural, '西藏自然科学博物馆', '0891-6401062', '面向青少年讲解青藏高原地理、动植物与生态保护基础知识。活动为演示数据。', '纳金街道藏大东路9号', 1, 1160, 0, 0, NOW(), NOW()),
    ('文成公主主题园实景演艺导赏', 'http://store.is.autonavi.com/showpic/1934a84936a344bdf8bb53f4c0213de7', '2026-09-12 18:30:00', '2026-09-12 20:30:00', '演出', @venue_ich, '唐蕃古道文化体验团', '0891-6601015', '通过演前导赏理解文成公主主题园的叙事背景和观看重点。活动为演示数据。', '慈觉林文成大道周边', 1, 1565, 0, 0, NOW(), NOW()),
    ('拉萨群众文化体育中心骑行集合日', 'https://aos-comment.amap.com/B037B0OZK5/comment/content_media_external_file_1000049103_ss__1759075555671_87662816.jpg', '2026-10-08 08:00:00', '2026-10-08 11:30:00', '运动', @venue_sports_center, '拉萨城市骑行协会', '0891-6601016', '城市低碳骑行集合活动，含安全检查、短线骑行和补给点说明。活动为演示数据。', '拉萨市群众文化体育中心', 1, 980, 0, 0, NOW(), NOW());

SET @act_photo = (SELECT id FROM t_activity WHERE name = '布达拉宫夜景摄影公开课' LIMIT 1);
SET @act_museum = (SELECT id FROM t_activity WHERE name = '西藏博物馆高原文明导览日' LIMIT 1);
SET @act_thangka = (SELECT id FROM t_activity WHERE name = '唐卡线描体验工作坊' LIMIT 1);
SET @act_yak = (SELECT id FROM t_activity WHERE name = '牦牛文化亲子研学营' LIMIT 1);
SET @act_walk = (SELECT id FROM t_activity WHERE name = '拉萨河畔城市漫步' LIMIT 1);
SET @act_canyon = (SELECT id FROM t_activity WHERE name = '雅鲁藏布大峡谷影像分享会' LIMIT 1);
SET @act_norbulingka = (SELECT id FROM t_activity WHERE name = '罗布林卡夏宫园林讲解' LIMIT 1);
SET @act_incense = (SELECT id FROM t_activity WHERE name = '非遗藏香制作体验课' LIMIT 1);
SET @act_drepung = (SELECT id FROM t_activity WHERE name = '哲蚌寺雪顿节文化预热导览' LIMIT 1);
SET @act_performance = (SELECT id FROM t_activity WHERE name = '拉萨民族文化艺术宫周末展演' LIMIT 1);
SET @act_shannan = (SELECT id FROM t_activity WHERE name = '山南雅砻文化讲堂' LIMIT 1);
SET @act_basum = (SELECT id FROM t_activity WHERE name = '巴松措生态徒步说明会' LIMIT 1);
SET @act_namco = (SELECT id FROM t_activity WHERE name = '纳木措星空观测公开课' LIMIT 1);
SET @act_natural = (SELECT id FROM t_activity WHERE name = '西藏自然科学博物馆高原生态课' LIMIT 1);
SET @act_wencheng = (SELECT id FROM t_activity WHERE name = '文成公主主题园实景演艺导赏' LIMIT 1);
SET @act_cycling = (SELECT id FROM t_activity WHERE name = '拉萨群众文化体育中心骑行集合日' LIMIT 1);

INSERT INTO t_activity_apply
    (name, cover_url, start_time, end_time, category, venue_id, organizer, contact_phone, intro, address_cache, apply_user_id, apply_status, reject_reason, audit_remark, activity_id, is_deleted, create_time, update_time)
VALUES
    ('山南雅砻文化讲堂', 'https://aos-comment.amap.com/B0G1TATR4G/comment/content_media_external_file_1000066673_ss__1757393011050_00490482.jpg', '2026-07-19 10:00:00', '2026-07-19 12:00:00', '讲座', @venue_shannan_center, '山南文化艺术中心', '0893-6601011', '材料完整，活动已进入正式列表。', '山南市香曲西路与格桑路交叉口北140米', @u_tenzin, 1, NULL, '演示审核：通过并生成正式活动。', @act_shannan, 0, NOW(), NOW()),
    ('巴松措生态徒步说明会', 'http://store.is.autonavi.com/showpic/5cf852159a40e956aa76b02bd2de213f', '2026-07-26 15:00:00', '2026-07-26 16:30:00', '户外', @venue_natural, '林芝生态旅行观察团', '0891-6601012', '材料完整，活动已进入正式列表。', '藏大东路9号', @u_yonten, 1, NULL, '演示审核：通过并生成正式活动。', @act_basum, 0, NOW(), NOW()),
    ('文成公主实景剧幕后导览', 'http://store.is.autonavi.com/showpic/1934a84936a344bdf8bb53f4c0213de7', '2026-09-20 17:00:00', '2026-09-20 19:00:00', '导览', @venue_ich, '唐蕃古道文化体验团', '0891-6602011', '拟组织演前幕后导览，等待补充现场容量说明。', '慈觉林文成大道周边', @u_guide, 0, NULL, NULL, NULL, 0, NOW(), NOW()),
    ('纳木措观星营地分享会', 'http://store.is.autonavi.com/showpic/75d2306cb0ade904bad4ce0afb1d34c4', '2026-08-15 20:30:00', '2026-08-15 22:30:00', '观星', @venue_natural, '星空旅行俱乐部', '0891-6602012', '申请内容缺少交通保障与医疗应急说明。', '拉萨市科普活动集合点', @u_karma, 2, '请补充交通保障、应急联系人和高原夜间安全预案后重新提交。', '演示审核：材料不完整。', NULL, 0, NOW(), NOW()),
    ('拉萨河亲子定向赛', 'https://comment-oss-online.oss-cn-wulanchabu.aliyuncs.com/B0H10HVY44/comment/content_media_external_images_media_2652409_1652276490909_a8f6fe7e.jpg', '2026-06-20 09:00:00', '2026-06-20 11:00:00', '亲子', @venue_sports_center, '亲子户外小队', '0891-6602013', '路线说明较完整，等待审核人员确认场地协调函。', '拉萨河两岸公共空间', @u_nima, 0, NULL, NULL, NULL, 0, NOW(), NOW()),
    ('唐卡入门体验加场', 'http://store.is.autonavi.com/showpic/1223e466d09e77dd82d68de268845319', '2026-06-01 14:30:00', '2026-06-01 17:00:00', '非遗', @venue_thangka, '唐卡之都博物馆', '0891-6602014', '与正式活动主题重复，建议合并场次。', '鲁固一巷夏扎大院内', @u_pema, 2, '与已上线活动高度重复，请调整时间或合并为同一活动。', '演示审核：驳回重复活动。', NULL, 0, NOW(), NOW()),
    ('西藏博物馆高原文明导览日', 'http://store.is.autonavi.com/showpic/92dbc5423b126b7884d1295077870f6d', '2026-05-18 10:00:00', '2026-05-18 12:00:00', '展览', @venue_tibet_museum, '西藏博物馆志愿服务队', '0891-6839222', '材料完整，活动已进入正式列表。', '罗布林卡路34号', @u_lhamo, 1, NULL, '演示审核：通过并生成正式活动。', @act_museum, 0, NOW(), NOW()),
    ('高原生态课堂校园专场', 'http://store.is.autonavi.com/showpic/fe41f27428bb2020ebef8f347f6d616a', '2026-08-29 10:00:00', '2026-08-29 12:00:00', '科普', @venue_natural, '林芝研学小队', '0891-6602015', '研学团队申请校园专场，等待审核。', '纳金街道藏大东路9号', @u_student, 0, NULL, NULL, NULL, 0, NOW(), NOW());

-- ----------------------------------------
-- 6. 首页配置
-- ----------------------------------------
INSERT INTO t_home_intro
    (title, content, cover_url, cover_type, scenic_limit, is_deleted, create_time, update_time)
VALUES
    ('走进西藏：高原文明、自然秘境与公共文化体验', '这里是 Aftourism 西藏文旅演示首页。内容以真实景区和场馆基础数据为底，串联布达拉宫、大昭寺、雅鲁藏布大峡谷、巴松措、西藏博物馆、非遗体验和城市公共文化活动，便于展示门户首页、内容管理、活动报名、收藏评论、反馈处理和后台审核等完整业务流程。', 'http://store.is.autonavi.com/showpic/abc43f4373ca7c3cd59e884283c31051', 'IMAGE', 8, 0, NOW(), NOW());

INSERT INTO t_home_banner
    (title, image_url, link_url, sort, is_enabled, is_deleted, create_time, update_time)
SELECT '布达拉宫夜景摄影公开课', 'http://store.is.autonavi.com/showpic/abc43f4373ca7c3cd59e884283c31051', CONCAT('/activities/', @act_photo), 100, 1, 0, NOW(), NOW()
UNION ALL SELECT '西藏博物馆高原文明导览', 'http://store.is.autonavi.com/showpic/92dbc5423b126b7884d1295077870f6d', CONCAT('/activities/', @act_museum), 96, 1, 0, NOW(), NOW()
UNION ALL SELECT '非遗体验活动报名上线', 'http://store.is.autonavi.com/showpic/1223e466d09e77dd82d68de268845319', CONCAT('/news/', @news_ich), 92, 1, 0, NOW(), NOW()
UNION ALL SELECT '巴松措生态徒步说明会', 'http://store.is.autonavi.com/showpic/5cf852159a40e956aa76b02bd2de213f', CONCAT('/activities/', @act_basum), 88, 1, 0, NOW(), NOW()
UNION ALL SELECT '西藏春夏文旅服务季', 'http://store.is.autonavi.com/showpic/9e29ebc1fbe5bb29f2fc83aa17bdb71d', CONCAT('/news/', @news_start), 84, 1, 0, NOW(), NOW();

INSERT INTO t_home_scenic
    (scenic_id, sort, is_enabled, is_deleted, create_time, update_time)
VALUES
    (@scenic_potala, 100, 1, 0, NOW(), NOW()),
    (@scenic_jokhang, 96, 1, 0, NOW(), NOW()),
    (@scenic_canyon, 92, 1, 0, NOW(), NOW()),
    (@scenic_basum, 88, 1, 0, NOW(), NOW()),
    (@scenic_tashilhunpo, 84, 1, 0, NOW(), NOW()),
    (@scenic_norbulingka, 80, 1, 0, NOW(), NOW()),
    (@scenic_tibet_museum, 76, 1, 0, NOW(), NOW()),
    (@scenic_namco, 72, 1, 0, NOW(), NOW());

-- ----------------------------------------
-- 7. 活动评论
-- ----------------------------------------
INSERT INTO t_activity_comment
    (activity_id, user_id, content, parent_id, mention_user_id, like_count, is_deleted, create_time, update_time)
VALUES
    (@act_photo, @u_dawa, '夜景课正好适合想拍布达拉宫蓝调时刻的人，希望能讲一下机位礼仪。', NULL, NULL, 18, 0, '2026-05-07 10:01:00', NOW()),
    (@act_photo, @u_lhamo, '会重点说明不要影响通行和朝拜人群，演示活动也会把文明拍摄放在第一位。', NULL, @u_dawa, 12, 0, '2026-05-07 10:08:00', NOW()),
    (@act_photo, @u_maya, '外地游客第一次来拉萨，想问普通手机能不能参加。', NULL, NULL, 8, 0, '2026-05-07 10:20:00', NOW()),
    (@act_photo, @u_operator, '可以参加，课程会分手机和相机两个示例。', NULL, @u_maya, 9, 0, '2026-05-07 10:24:00', NOW()),
    (@act_museum, @u_pema, '博物馆导览很适合半日安排，建议把罗布林卡也串起来。', NULL, NULL, 16, 0, '2026-05-07 11:00:00', NOW()),
    (@act_museum, @u_student, '研学团队报名需要提前提交名单吗？', NULL, NULL, 5, 0, '2026-05-07 11:05:00', NOW()),
    (@act_museum, @u_operator, '团队账号请提前在个人中心确认联系人，名单可现场核验。', NULL, @u_student, 7, 0, '2026-05-07 11:09:00', NOW()),
    (@act_thangka, @u_sonam, '想体验唐卡线描，但完全零基础可以吗？', NULL, NULL, 11, 0, '2026-05-07 11:30:00', NOW()),
    (@act_thangka, @u_guide, '零基础没问题，会从线条和构图讲起。', NULL, @u_sonam, 10, 0, '2026-05-07 11:36:00', NOW()),
    (@act_yak, @u_nima, '亲子研学营孩子六岁能参加吗？', NULL, NULL, 15, 0, '2026-05-07 12:00:00', NOW()),
    (@act_yak, @u_operator, '六岁可以参加，建议由家长全程陪同。', NULL, @u_nima, 9, 0, '2026-05-07 12:05:00', NOW()),
    (@act_walk, @u_karma, '拉萨河漫步路线强度不高，适合到达第二天慢慢适应。', NULL, NULL, 14, 0, '2026-05-07 12:30:00', NOW()),
    (@act_walk, @u_maya, '这个路线会经过卫生间和补给点吗？', NULL, NULL, 4, 0, '2026-05-07 12:45:00', NOW()),
    (@act_walk, @u_operator, '集合说明会标出公共卫生间和补水点。', NULL, @u_maya, 6, 0, '2026-05-07 12:50:00', NOW()),
    (@act_canyon, @u_dawa, '影像分享会如果能讲季节光线就更好了。', NULL, NULL, 13, 0, '2026-05-07 13:10:00', NOW()),
    (@act_norbulingka, @u_lhamo, '罗布林卡讲解建议控制步速，园林细节很多。', NULL, NULL, 12, 0, '2026-05-07 13:25:00', NOW()),
    (@act_incense, @u_pema, '藏香体验课对香料过敏的人需要提前说明。', NULL, NULL, 18, 0, '2026-05-07 13:40:00', NOW()),
    (@act_incense, @u_operator, '提醒很重要，报名页会要求备注过敏情况。', NULL, @u_pema, 11, 0, '2026-05-07 13:48:00', NOW()),
    (@act_drepung, @u_guide, '雪顿节预热导览可以提前讲清礼仪，挺适合游客。', NULL, NULL, 19, 0, '2026-05-07 14:00:00', NOW()),
    (@act_drepung, @u_sonam, '希望能安排公共交通建议，节庆期间打车可能不方便。', NULL, NULL, 7, 0, '2026-05-07 14:12:00', NOW()),
    (@act_performance, @u_maya, '周末展演时间很友好，晚上还有其他交通提示吗？', NULL, NULL, 8, 0, '2026-05-07 14:30:00', NOW()),
    (@act_shannan, @u_tenzin, '山南讲堂适合作为后续一日游的行前课。', NULL, NULL, 14, 0, '2026-05-07 14:45:00', NOW()),
    (@act_basum, @u_yonten, '生态徒步说明会会强调垃圾带离和天气判断。', NULL, NULL, 20, 0, '2026-05-07 15:00:00', NOW()),
    (@act_basum, @u_student, '研学队想参加这个说明会，是否适合十几人的小团队？', NULL, NULL, 6, 0, '2026-05-07 15:08:00', NOW()),
    (@act_namco, @u_karma, '纳木措观星一定要强调保暖，八月夜里也冷。', NULL, NULL, 17, 0, '2026-05-07 15:30:00', NOW()),
    (@act_namco, @u_operator, '会在活动通知里列出保暖和高反风险提示。', NULL, @u_karma, 8, 0, '2026-05-07 15:36:00', NOW()),
    (@act_natural, @u_nima, '高原生态课适合孩子做暑期作业素材。', NULL, NULL, 12, 0, '2026-05-07 16:00:00', NOW()),
    (@act_wencheng, @u_dawa, '演艺导赏如果有剧情背景介绍就很加分。', NULL, NULL, 9, 0, '2026-05-07 16:20:00', NOW()),
    (@act_cycling, @u_karma, '骑行集合日请务必检查头盔和刹车。', NULL, NULL, 21, 0, '2026-05-07 16:40:00', NOW()),
    (@act_cycling, @u_operator, '安全检查会作为签到后的第一项。', NULL, @u_karma, 10, 0, '2026-05-07 16:45:00', NOW()),
    (@act_photo, @u_sonam, '有人在评论里发低价包车广告，希望管理员处理。', NULL, NULL, 2, 0, '2026-05-07 17:00:00', NOW()),
    (@act_thangka, @u_maya, '体验课名额如果满了，希望能开候补。', NULL, NULL, 5, 0, '2026-05-07 17:20:00', NOW());

SET @activity_comment_report = (SELECT id FROM t_activity_comment WHERE content = '有人在评论里发低价包车广告，希望管理员处理。' LIMIT 1);

-- ----------------------------------------
-- 8. 交流文章与评论
-- ----------------------------------------
INSERT INTO t_exchange_article
    (user_id, title, content, cover_url, status, like_count, comment_count, audit_remark, is_deleted, create_time, update_time)
VALUES
    (@u_maya, '初到拉萨三天节奏建议', '<p>第一天不要安排太满，可以把西藏博物馆、罗布林卡或拉萨河慢行放在前面，给身体一点适应时间。</p><p>第二天再考虑布达拉宫和八廓街，第三天视状态安排近郊或场馆活动。</p>', 'http://store.is.autonavi.com/showpic/6795bf614b062fbbcd95c1c1f17d03a7', 1, 86, 0, '演示审核：内容真实友好。', 0, '2026-05-07 09:00:00', NOW()),
    (@u_dawa, '布达拉宫预约与拍摄机位小记', '<p>拍摄布达拉宫时，尊重现场秩序比机位更重要。建议先确认预约时间，再安排广场、药王山或周边步行路线。</p>', 'http://store.is.autonavi.com/showpic/abc43f4373ca7c3cd59e884283c31051', 1, 74, 0, '演示审核：摄影经验分享。', 0, '2026-05-06 21:00:00', NOW()),
    (@u_pema, '博物馆半日路线：从西藏博物馆到罗布林卡', '<p>上午看西藏博物馆，午后去罗布林卡散步，是比较平稳的半日安排。场馆和园林相邻，节奏不会太急。</p>', 'http://store.is.autonavi.com/showpic/92dbc5423b126b7884d1295077870f6d', 1, 62, 0, '演示审核：路线清晰。', 0, '2026-05-06 16:20:00', NOW()),
    (@u_nima, '牦牛博物馆适合亲子吗', '<p>亲子游可以把牦牛博物馆和自然科学博物馆放在同一天，孩子对动物、生态和高原生活更容易建立直观印象。</p>', 'http://store.is.autonavi.com/showpic/30ffb6effdfae76ad3ae07424fa8a3bf', 1, 58, 0, '演示审核：亲子内容。', 0, '2026-05-06 12:10:00', NOW()),
    (@u_sonam, '唐卡体验课新手记录', '<p>线描看起来简单，实际很考验耐心。老师提醒要先理解构图，再慢慢练习线条稳定性。</p>', 'http://store.is.autonavi.com/showpic/1223e466d09e77dd82d68de268845319', 1, 51, 0, '演示审核：体验记录。', 0, '2026-05-05 19:35:00', NOW()),
    (@u_tenzin, '山南一日文化线怎么排', '<p>如果从拉萨出发，山南文化艺术中心、山南市博物馆和雅砻河谷相关点位可以串成一条文化线，但交通时间要留足。</p>', 'https://aos-comment.amap.com/B0G1TATR4G/comment/content_media_external_file_1000066673_ss__1757393011050_00490482.jpg', 1, 45, 0, '演示审核：路线建议。', 0, '2026-05-05 14:15:00', NOW()),
    (@u_yonten, '林芝巴松措生态徒步注意事项', '<p>徒步前要确认天气、补水和垃圾带离。生态游线最重要的是不打扰当地环境，照片之外也要留下好的游览方式。</p>', 'http://store.is.autonavi.com/showpic/5cf852159a40e956aa76b02bd2de213f', 1, 66, 0, '演示审核：户外安全。', 0, '2026-05-04 20:40:00', NOW()),
    (@u_lhamo, '大昭寺周边文明游览提示', '<p>八廓街和大昭寺周边人流密集，拍照、排队和通行都需要给他人留空间。初到游客建议放慢步速。</p>', 'http://store.is.autonavi.com/showpic/df5a8b4a1a882cedaebee0a32f516e7c', 1, 73, 0, '演示审核：文明游览提醒。', 0, '2026-05-04 10:25:00', NOW()),
    (@u_karma, '纳木措观星保暖清单', '<p>高海拔夜间温差很大，保暖层、防风外套、热水、手套和头灯都很重要。不要因为白天阳光好就低估夜间寒冷。</p>', 'http://store.is.autonavi.com/showpic/75d2306cb0ade904bad4ce0afb1d34c4', 1, 69, 0, '演示审核：安全清单。', 0, '2026-05-03 22:00:00', NOW()),
    (@u_operator, '拉萨河傍晚散步路线', '<p>傍晚沿拉萨河慢走，适合刚到高原的游客。建议关注天气、补水和返程交通，别把第一天安排得太满。</p>', 'https://comment-oss-online.oss-cn-wulanchabu.aliyuncs.com/B0H10HVY44/comment/content_media_external_images_media_2652409_1652276490909_a8f6fe7e.jpg', 1, 41, 0, '演示审核：平台示例内容。', 0, '2026-05-03 18:10:00', NOW()),
    (@u_student, '高原骑行招募贴', '<p>我们想组织一次低强度城市骑行，希望找同学一起参与，路线还在确认中。</p>', 'https://aos-comment.amap.com/B037B0OZK5/comment/content_media_external_file_1000049103_ss__1759075555671_87662816.jpg', 0, 12, 0, NULL, 0, '2026-05-07 11:20:00', NOW()),
    (@u_maya, '低价包车广告请勿跟', '<p>低价拼车包车，私聊即可，保证最低价。</p>', 'http://store.is.autonavi.com/showpic/1c986f61f3d5ab6e1f4139407ae25f2c', 2, 1, 0, '演示审核：含明显广告导流，不予发布。', 0, '2026-05-07 08:30:00', NOW());

SET @article_lhasa3 = (SELECT id FROM t_exchange_article WHERE title = '初到拉萨三天节奏建议' LIMIT 1);
SET @article_photo = (SELECT id FROM t_exchange_article WHERE title = '布达拉宫预约与拍摄机位小记' LIMIT 1);
SET @article_museum_route = (SELECT id FROM t_exchange_article WHERE title = '博物馆半日路线：从西藏博物馆到罗布林卡' LIMIT 1);
SET @article_yak_parent = (SELECT id FROM t_exchange_article WHERE title = '牦牛博物馆适合亲子吗' LIMIT 1);
SET @article_thangka = (SELECT id FROM t_exchange_article WHERE title = '唐卡体验课新手记录' LIMIT 1);
SET @article_shannan = (SELECT id FROM t_exchange_article WHERE title = '山南一日文化线怎么排' LIMIT 1);
SET @article_basum = (SELECT id FROM t_exchange_article WHERE title = '林芝巴松措生态徒步注意事项' LIMIT 1);
SET @article_jokhang = (SELECT id FROM t_exchange_article WHERE title = '大昭寺周边文明游览提示' LIMIT 1);
SET @article_namco = (SELECT id FROM t_exchange_article WHERE title = '纳木措观星保暖清单' LIMIT 1);
SET @article_walk = (SELECT id FROM t_exchange_article WHERE title = '拉萨河傍晚散步路线' LIMIT 1);
SET @article_pending = (SELECT id FROM t_exchange_article WHERE title = '高原骑行招募贴' LIMIT 1);
SET @article_rejected = (SELECT id FROM t_exchange_article WHERE title = '低价包车广告请勿跟' LIMIT 1);

INSERT INTO t_exchange_comment
    (article_id, user_id, content, parent_id, mention_user_id, like_count, is_deleted, create_time, update_time)
VALUES
    (@article_lhasa3, @u_lhamo, '这个节奏很稳，第一天慢一点真的很重要。', NULL, NULL, 21, 0, '2026-05-07 09:20:00', NOW()),
    (@article_lhasa3, @u_nima, '亲子家庭也建议这样排，孩子不会太累。', NULL, NULL, 14, 0, '2026-05-07 09:24:00', NOW()),
    (@article_lhasa3, @u_operator, '平台活动页也会补充低强度半日活动筛选。', NULL, NULL, 9, 0, '2026-05-07 09:28:00', NOW()),
    (@article_photo, @u_dawa, '药王山视角很经典，但人多时一定要排队等待。', NULL, NULL, 18, 0, '2026-05-07 09:35:00', NOW()),
    (@article_photo, @u_maya, '手机拍夜景需要三脚架吗？', NULL, NULL, 5, 0, '2026-05-07 09:38:00', NOW()),
    (@article_photo, @u_dawa, '不一定，先学会稳住和控制曝光补偿就够用了。', NULL, @u_maya, 8, 0, '2026-05-07 09:42:00', NOW()),
    (@article_museum_route, @u_pema, '博物馆到罗布林卡确实适合慢慢看。', NULL, NULL, 16, 0, '2026-05-07 09:50:00', NOW()),
    (@article_museum_route, @u_student, '研学团队可以按这个路线做观察笔记。', NULL, NULL, 10, 0, '2026-05-07 09:55:00', NOW()),
    (@article_yak_parent, @u_nima, '小朋友会喜欢牦牛主题展，互动感强。', NULL, NULL, 13, 0, '2026-05-07 10:05:00', NOW()),
    (@article_yak_parent, @u_operator, '亲子研学营也会加入这个场馆。', NULL, NULL, 7, 0, '2026-05-07 10:08:00', NOW()),
    (@article_thangka, @u_sonam, '线描真的需要耐心，体验完更能理解手艺人的功夫。', NULL, NULL, 19, 0, '2026-05-07 10:20:00', NOW()),
    (@article_thangka, @u_guide, '建议体验前先看一圈展品，会更有感觉。', NULL, NULL, 12, 0, '2026-05-07 10:25:00', NOW()),
    (@article_shannan, @u_tenzin, '山南一日线不要贪多，讲堂加一个重点场馆就很好。', NULL, NULL, 14, 0, '2026-05-07 10:40:00', NOW()),
    (@article_shannan, @u_maya, '从拉萨当天往返会不会太赶？', NULL, NULL, 4, 0, '2026-05-07 10:44:00', NOW()),
    (@article_shannan, @u_tenzin, '公共交通和包车都要提前查好，建议留足路上时间。', NULL, @u_maya, 6, 0, '2026-05-07 10:48:00', NOW()),
    (@article_basum, @u_yonten, '生态路线最怕临时改天气，说明会很有必要。', NULL, NULL, 18, 0, '2026-05-07 11:00:00', NOW()),
    (@article_basum, @u_student, '会讲垃圾带离和拍照不踩草甸吗？', NULL, NULL, 8, 0, '2026-05-07 11:05:00', NOW()),
    (@article_basum, @u_yonten, '会讲，这些比拍到照片更重要。', NULL, @u_student, 11, 0, '2026-05-07 11:10:00', NOW()),
    (@article_jokhang, @u_lhamo, '文明游览提示非常需要，尤其在人多的时段。', NULL, NULL, 20, 0, '2026-05-07 11:20:00', NOW()),
    (@article_jokhang, @u_pema, '建议加一条不要随意拍摄他人近景。', NULL, NULL, 12, 0, '2026-05-07 11:25:00', NOW()),
    (@article_namco, @u_karma, '观星清单要把手套写进去，拍照时手很容易冷。', NULL, NULL, 16, 0, '2026-05-07 11:40:00', NOW()),
    (@article_namco, @u_dawa, '相机电池也要多带一块，低温掉电很快。', NULL, NULL, 14, 0, '2026-05-07 11:44:00', NOW()),
    (@article_walk, @u_operator, '傍晚路线适合做平台首页推荐。', NULL, NULL, 9, 0, '2026-05-07 12:00:00', NOW()),
    (@article_walk, @u_maya, '刚到拉萨第一晚散步比赶景点舒服。', NULL, NULL, 13, 0, '2026-05-07 12:05:00', NOW()),
    (@article_pending, @u_karma, '骑行路线确认后建议补上集合点和保障车信息。', NULL, NULL, 5, 0, '2026-05-07 12:20:00', NOW()),
    (@article_pending, @u_operator, '待审核内容暂不在公开列表展示，但后台可以看到。', NULL, NULL, 3, 0, '2026-05-07 12:24:00', NOW()),
    (@article_rejected, @u_sonam, '这个内容像广告，建议管理员再看一下。', NULL, NULL, 2, 0, '2026-05-07 12:40:00', NOW()),
    (@article_photo, @u_sonam, '摄影公开课和这篇内容刚好能互相补充。', NULL, NULL, 9, 0, '2026-05-07 13:00:00', NOW()),
    (@article_museum_route, @u_maya, '半日路线收藏了，适合第二天安排。', NULL, NULL, 8, 0, '2026-05-07 13:10:00', NOW()),
    (@article_thangka, @u_pema, '如果名额满了，可以先去看唐卡专题展。', NULL, NULL, 6, 0, '2026-05-07 13:25:00', NOW()),
    (@article_shannan, @u_guide, '雅砻文化讲堂可以作为山南线的前置知识。', NULL, NULL, 7, 0, '2026-05-07 13:40:00', NOW()),
    (@article_namco, @u_lhamo, '高海拔夜间活动一定要保守一点。', NULL, NULL, 10, 0, '2026-05-07 13:50:00', NOW());

SET @exchange_comment_report = (SELECT id FROM t_exchange_comment WHERE content = '这个内容像广告，建议管理员再看一下。' LIMIT 1);

UPDATE t_exchange_article a
LEFT JOIN (
    SELECT article_id, COUNT(*) AS cnt
    FROM t_exchange_comment
    WHERE is_deleted = 0
    GROUP BY article_id
) c ON a.id = c.article_id
SET a.comment_count = IFNULL(c.cnt, 0),
    a.update_time = NOW()
WHERE a.is_deleted = 0;

-- ----------------------------------------
-- 9. 收藏、反馈、通知、举报、资质
-- ----------------------------------------
INSERT INTO t_user_favorite
    (user_id, target_type, target_id, is_deleted, create_time, update_time)
VALUES
    (@u_lhamo, 'SCENIC', @scenic_potala, 0, NOW(), NOW()),
    (@u_lhamo, 'SCENIC', @scenic_jokhang, 0, NOW(), NOW()),
    (@u_lhamo, 'ACTIVITY', @act_drepung, 0, NOW(), NOW()),
    (@u_lhamo, 'VENUE', @venue_tibet_museum, 0, NOW(), NOW()),
    (@u_tenzin, 'SCENIC', @scenic_tashilhunpo, 0, NOW(), NOW()),
    (@u_tenzin, 'ACTIVITY', @act_shannan, 0, NOW(), NOW()),
    (@u_tenzin, 'VENUE', @venue_shannan_center, 0, NOW(), NOW()),
    (@u_nima, 'ACTIVITY', @act_yak, 0, NOW(), NOW()),
    (@u_nima, 'ACTIVITY', @act_natural, 0, NOW(), NOW()),
    (@u_nima, 'VENUE', @venue_yak, 0, NOW(), NOW()),
    (@u_nima, 'SCENIC', @scenic_tibet_museum, 0, NOW(), NOW()),
    (@u_dawa, 'ACTIVITY', @act_photo, 0, NOW(), NOW()),
    (@u_dawa, 'ACTIVITY', @act_canyon, 0, NOW(), NOW()),
    (@u_dawa, 'SCENIC', @scenic_canyon, 0, NOW(), NOW()),
    (@u_dawa, 'SCENIC', @scenic_potala, 0, NOW(), NOW()),
    (@u_pema, 'VENUE', @venue_ich, 0, NOW(), NOW()),
    (@u_pema, 'ACTIVITY', @act_incense, 0, NOW(), NOW()),
    (@u_pema, 'ACTIVITY', @act_museum, 0, NOW(), NOW()),
    (@u_yonten, 'SCENIC', @scenic_basum, 0, NOW(), NOW()),
    (@u_yonten, 'ACTIVITY', @act_basum, 0, NOW(), NOW()),
    (@u_yonten, 'SCENIC', @scenic_namco, 0, NOW(), NOW()),
    (@u_yonten, 'ACTIVITY', @act_namco, 0, NOW(), NOW()),
    (@u_sonam, 'ACTIVITY', @act_thangka, 0, NOW(), NOW()),
    (@u_sonam, 'VENUE', @venue_thangka, 0, NOW(), NOW()),
    (@u_sonam, 'SCENIC', @scenic_norbulingka, 0, NOW(), NOW()),
    (@u_karma, 'ACTIVITY', @act_cycling, 0, NOW(), NOW()),
    (@u_karma, 'ACTIVITY', @act_namco, 0, NOW(), NOW()),
    (@u_karma, 'VENUE', @venue_sports_center, 0, NOW(), NOW()),
    (@u_maya, 'SCENIC', @scenic_potala, 0, NOW(), NOW()),
    (@u_maya, 'ACTIVITY', @act_walk, 0, NOW(), NOW()),
    (@u_maya, 'ACTIVITY', @act_performance, 0, NOW(), NOW()),
    (@u_operator, 'SCENIC', @scenic_potala, 0, NOW(), NOW()),
    (@u_operator, 'SCENIC', @scenic_canyon, 0, NOW(), NOW()),
    (@u_operator, 'VENUE', @venue_tibet_museum, 0, NOW(), NOW()),
    (@u_guide, 'ACTIVITY', @act_wencheng, 0, NOW(), NOW()),
    (@u_guide, 'ACTIVITY', @act_drepung, 0, NOW(), NOW()),
    (@u_guide, 'SCENIC', @scenic_jokhang, 0, NOW(), NOW()),
    (@u_student, 'ACTIVITY', @act_museum, 0, NOW(), NOW()),
    (@u_student, 'ACTIVITY', @act_basum, 0, NOW(), NOW()),
    (@u_student, 'VENUE', @venue_natural, 0, NOW(), NOW()),
    (@u_student, 'SCENIC', @scenic_tibet_museum, 0, NOW(), NOW()),
    (@u_student, 'SCENIC', @scenic_basum, 0, NOW(), NOW());

UPDATE t_activity a
LEFT JOIN (
    SELECT target_id, COUNT(*) AS cnt
    FROM t_user_favorite
    WHERE target_type = 'ACTIVITY' AND is_deleted = 0
    GROUP BY target_id
) f ON a.id = f.target_id
SET a.favorite_count = IFNULL(f.cnt, 0),
    a.update_time = NOW()
WHERE a.is_deleted = 0;

INSERT INTO t_message_feedback
    (user_id, title, content, contact_phone, contact_email, status, is_deleted, create_time, update_time)
VALUES
    (@u_maya, '布达拉宫预约入口加载慢', '进入预约说明页时偶尔加载比较慢，希望能优化图片和说明展示。', '13908910009', 'maya.demo@example.com', 0, 0, '2026-05-07 09:20:00', NOW()),
    (@u_karma, '景区地图希望增加公交换乘', '地图页如果能展示附近公交站和步行接驳会更方便。', '13908910008', 'karma.demo@example.com', 1, 0, '2026-05-07 09:40:00', NOW()),
    (@u_sonam, '个人中心收藏分类建议', '收藏里景区、场馆、活动可以再做一个更醒目的分类切换。', '13908910007', 'sonam.demo@example.com', 1, 0, '2026-05-07 10:05:00', NOW()),
    (@u_nima, '活动报名短信提醒问题', '亲子研学营报名后希望能收到短信和站内通知双提醒。', '13908910003', 'nima.demo@example.com', 0, 0, '2026-05-07 10:30:00', NOW()),
    (@u_pema, '场馆开放时间需更及时', '部分场馆节假日开放时间可能调整，建议详情页展示更新时间。', '13908910005', 'pema.demo@example.com', 1, 0, '2026-05-07 11:00:00', NOW()),
    (@u_dawa, '交流社区希望增加游记标签', '社区里路线、摄影、亲子、户外内容可以用标签区分。', '13908910004', 'dawa.demo@example.com', 0, 0, '2026-05-07 11:30:00', NOW()),
    (@u_yonten, '高原徒步安全提示建议', '户外活动详情页建议固定展示高反、天气和垃圾带离提醒。', '13908910006', 'yonten.demo@example.com', 1, 0, '2026-05-07 12:00:00', NOW()),
    (@u_student, '反馈已解决：博物馆图片无法显示', '之前西藏博物馆详情图片打不开，现在已经恢复，感谢处理。', '13908910012', 'student.demo@example.com', 1, 0, '2026-05-07 12:30:00', NOW());

SET @fb_booking = (SELECT id FROM t_message_feedback WHERE title = '布达拉宫预约入口加载慢' LIMIT 1);
SET @fb_map = (SELECT id FROM t_message_feedback WHERE title = '景区地图希望增加公交换乘' LIMIT 1);
SET @fb_fav = (SELECT id FROM t_message_feedback WHERE title = '个人中心收藏分类建议' LIMIT 1);
SET @fb_sms = (SELECT id FROM t_message_feedback WHERE title = '活动报名短信提醒问题' LIMIT 1);
SET @fb_time = (SELECT id FROM t_message_feedback WHERE title = '场馆开放时间需更及时' LIMIT 1);
SET @fb_tag = (SELECT id FROM t_message_feedback WHERE title = '交流社区希望增加游记标签' LIMIT 1);
SET @fb_safety = (SELECT id FROM t_message_feedback WHERE title = '高原徒步安全提示建议' LIMIT 1);
SET @fb_image = (SELECT id FROM t_message_feedback WHERE title = '反馈已解决：博物馆图片无法显示' LIMIT 1);

INSERT INTO t_message_feedback_comment
    (feedback_id, user_id, content, parent_id, like_count, is_deleted, create_time, update_time)
VALUES
    (@fb_booking, @u_operator, '已收到，预约说明页图片会压缩并增加缓存策略。', NULL, 3, 0, NOW(), NOW()),
    (@fb_booking, @u_maya, '谢谢，希望手机网络下也能快一点。', NULL, 1, 0, NOW(), NOW()),
    (@fb_map, @u_operator, '公交换乘属于地图二期能力，已记录到优化清单。', NULL, 4, 0, NOW(), NOW()),
    (@fb_map, @u_karma, '骑行和公交接驳一起展示会很实用。', NULL, 2, 0, NOW(), NOW()),
    (@fb_fav, @u_operator, '收藏分类已经在新版原型中调整，后续会优先展示目标类型。', NULL, 5, 0, NOW(), NOW()),
    (@fb_fav, @u_sonam, '这个改动对经常收藏活动的人很有帮助。', NULL, 2, 0, NOW(), NOW()),
    (@fb_sms, @u_operator, '短信提醒已进入排查，当前站内通知可正常收到。', NULL, 3, 0, NOW(), NOW()),
    (@fb_sms, @u_nima, '亲子活动临近前一天也希望能提醒一次。', NULL, 2, 0, NOW(), NOW()),
    (@fb_time, @u_operator, '场馆详情页会补充信息更新时间，并提示以馆方公告为准。', NULL, 4, 0, NOW(), NOW()),
    (@fb_time, @u_pema, '这样游客就能判断信息是否新。', NULL, 1, 0, NOW(), NOW()),
    (@fb_tag, @u_operator, '社区标签建议已记录，先从摄影、亲子、户外、路线四类试运行。', NULL, 3, 0, NOW(), NOW()),
    (@fb_safety, @u_operator, '户外活动详情页将固定展示安全提醒模块。', NULL, 5, 0, NOW(), NOW()),
    (@fb_safety, @u_yonten, '安全提醒最好放在报名按钮附近。', NULL, 3, 0, NOW(), NOW()),
    (@fb_image, @u_operator, '图片服务已恢复，感谢反馈。', NULL, 4, 0, NOW(), NOW());

INSERT INTO t_user_qualification_apply
    (user_id, real_name, organization, contact_phone, apply_reason, attachment_url, apply_status, audit_remark, is_deleted, create_time, update_time)
VALUES
    (@u_lhamo, '拉姆卓玛', '拉萨本地讲解员协作组', '13908910001', '申请发布公益导览和文明游览提醒活动。', '/files/demo/qualification/lhamo-guide.pdf', 1, '资料完整，演示审核通过。', 0, NOW(), NOW()),
    (@u_tenzin, '次仁扎西', '山南文化活动策划中心', '13908910002', '申请发布山南文化讲堂和公共文化活动。', '/files/demo/qualification/tenzin-org.pdf', 1, '组织资质清晰，演示审核通过。', 0, NOW(), NOW()),
    (@u_yonten, '云登桑布', '林芝生态户外观察团', '13908910006', '申请发布户外说明会和生态徒步安全课程。', '/files/demo/qualification/yonten-outdoor.pdf', 1, '户外安全说明完整，演示审核通过。', 0, NOW(), NOW()),
    (@u_guide, '阿旺', '唐蕃古道文化体验团', '13908910011', '申请发布演艺导赏和非遗体验相关活动。', '/files/demo/qualification/guide-culture.pdf', 0, NULL, 0, NOW(), NOW()),
    (@u_student, '林芝研学小队', '林芝高校研学社团', '13908910012', '申请以团队账号发布研学线路和校园专场。', '/files/demo/qualification/student-team.pdf', 0, NULL, 0, NOW(), NOW()),
    (@u_karma, '贡嘎嘉措', '个人骑行爱好者', '13908910008', '申请发布城市骑行集合活动。', '/files/demo/qualification/karma-cycling.pdf', 2, '个人组织保障材料不足，请补充保险和应急预案。', 0, NOW(), NOW());

UPDATE t_user
SET is_advanced = 1,
    update_time = NOW()
WHERE id IN (@u_lhamo, @u_tenzin, @u_yonten)
  AND is_deleted = 0;

INSERT INTO t_content_report
    (reporter_id, target_user_id, target_type, target_id, reason_type, reason, screenshot_urls, status, result_remark, violation_flag, is_deleted, create_time, update_time)
VALUES
    (@u_sonam, @u_maya, 'ARTICLE', @article_rejected, 'SPAM', '文章内容疑似低价包车广告导流。', '["/files/demo/report/ad-article-01.png"]', 1, '演示处理：内容已驳回，判定违规。', 1, 0, NOW(), NOW()),
    (@u_lhamo, @u_sonam, 'COMMENT', @exchange_comment_report, 'OTHER', '评论提醒管理员关注广告内容。', NULL, 2, '演示处理：评论本身为善意提醒，不判定违规。', 0, 0, NOW(), NOW()),
    (@u_pema, @u_sonam, 'ACTIVITY_COMMENT', @activity_comment_report, 'OTHER', '活动评论中提到疑似广告，需要核查上下文。', NULL, 0, NULL, 0, 0, NOW(), NOW()),
    (@u_karma, @u_maya, 'ARTICLE', @article_lhasa3, 'OTHER', '标题正常，但想测试举报流程。', NULL, 2, '演示处理：未发现违规，驳回举报。', 0, 0, NOW(), NOW()),
    (@u_operator, @u_maya, 'ARTICLE', @article_rejected, 'SPAM', '重复广告内容进入审核样例。', '["/files/demo/report/ad-article-02.png"]', 1, '演示处理：重复广告样例，已处理。', 1, 0, NOW(), NOW()),
    (@u_yonten, @u_karma, 'ARTICLE', @article_pending, 'OTHER', '骑行招募内容缺少安全保障，建议审核时关注。', NULL, 0, NULL, 0, 0, NOW(), NOW());

INSERT INTO t_portal_notification
    (user_id, type, title, content, related_type, related_id, is_read, is_deleted, create_time, update_time)
VALUES
    (@u_tenzin, 'AUDIT', '活动审核通过', '你提交的山南雅砻文化讲堂已通过审核并生成正式活动。', 'ACTIVITY_APPLY', @act_shannan, 0, 0, NOW(), NOW()),
    (@u_yonten, 'AUDIT', '活动审核通过', '你提交的巴松措生态徒步说明会已通过审核。', 'ACTIVITY_APPLY', @act_basum, 0, 0, NOW(), NOW()),
    (@u_karma, 'AUDIT', '活动审核未通过', '纳木措观星营地分享会需补充交通保障和应急预案。', 'ACTIVITY_APPLY', NULL, 0, 0, NOW(), NOW()),
    (@u_pema, 'AUDIT', '活动审核未通过', '唐卡入门体验加场与已上线活动重复，请调整后再提交。', 'ACTIVITY_APPLY', NULL, 1, 0, NOW(), NOW()),
    (@u_maya, 'REPLY', '你的反馈有新回复', '预约入口加载慢问题已进入优化处理。', 'FEEDBACK', @fb_booking, 0, 0, NOW(), NOW()),
    (@u_karma, 'REPLY', '你的反馈有新回复', '地图公交换乘建议已记录到二期优化清单。', 'FEEDBACK', @fb_map, 1, 0, NOW(), NOW()),
    (@u_sonam, 'LIKE', '你的交流评论获得点赞', '唐卡体验课评论获得了新的点赞。', 'COMMENT', @article_thangka, 0, 0, NOW(), NOW()),
    (@u_dawa, 'REPLY', '有人回复了你的摄影问题', '布达拉宫夜景公开课评论有新回复。', 'ACTIVITY', @act_photo, 0, 0, NOW(), NOW()),
    (@u_student, 'REPLY', '研学团队问题已回复', '西藏博物馆导览日团队报名问题已有回复。', 'ACTIVITY', @act_museum, 0, 0, NOW(), NOW()),
    (@u_maya, 'VIOLATION', '交流文章审核未通过', '低价包车广告请勿跟因广告导流被驳回。', 'EXCHANGE_ARTICLE', @article_rejected, 0, 0, NOW(), NOW()),
    (@u_sonam, 'REPORT', '举报处理完成', '你举报的广告文章已处理。', 'REPORT', @article_rejected, 0, 0, NOW(), NOW()),
    (@u_lhamo, 'REPORT', '举报处理完成', '你提交的评论举报已复核，未判定违规。', 'REPORT', @exchange_comment_report, 1, 0, NOW(), NOW()),
    (@u_yonten, 'LIKE', '你的户外安全文章获得点赞', '林芝巴松措生态徒步注意事项获得新的点赞。', 'EXCHANGE_ARTICLE', @article_basum, 0, 0, NOW(), NOW()),
    (@u_lhamo, 'LIKE', '你的文明游览提醒受到关注', '大昭寺周边文明游览提示获得新的点赞。', 'EXCHANGE_ARTICLE', @article_jokhang, 0, 0, NOW(), NOW()),
    (@u_nima, 'REPLY', '亲子研学营问题已回复', '平台运营助手回复了你的活动咨询。', 'ACTIVITY', @act_yak, 0, 0, NOW(), NOW()),
    (@u_pema, 'REPLY', '场馆开放时间建议已回复', '平台将补充信息更新时间提示。', 'FEEDBACK', @fb_time, 1, 0, NOW(), NOW()),
    (@u_yonten, 'REPLY', '户外安全建议已回复', '安全提醒模块将放入户外活动详情页。', 'FEEDBACK', @fb_safety, 0, 0, NOW(), NOW()),
    (@u_operator, 'REPORT', '有新的待处理举报', '活动评论中出现广告相关举报，请后台处理。', 'REPORT', @activity_comment_report, 0, 0, NOW(), NOW()),
    (@u_guide, 'AUDIT', '资质申请待审核', '你的认证讲解员资质申请已提交，等待后台审核。', 'QUALIFICATION', NULL, 0, 0, NOW(), NOW()),
    (@u_student, 'AUDIT', '资质申请待审核', '研学团队账号资质申请已提交，等待后台审核。', 'QUALIFICATION', NULL, 0, 0, NOW(), NOW()),
    (@u_karma, 'AUDIT', '资质申请未通过', '城市骑行资质申请需补充保险和应急预案。', 'QUALIFICATION', NULL, 0, 0, NOW(), NOW()),
    (@u_maya, 'LIKE', '你的路线分享获得点赞', '初到拉萨三天节奏建议获得新的点赞。', 'EXCHANGE_ARTICLE', @article_lhasa3, 0, 0, NOW(), NOW()),
    (@u_dawa, 'LIKE', '你的摄影小记获得点赞', '布达拉宫预约与拍摄机位小记获得新的点赞。', 'EXCHANGE_ARTICLE', @article_photo, 1, 0, NOW(), NOW()),
    (@u_operator, 'REPLY', '社区有新的用户互动', '拉萨河傍晚散步路线收到新的评论。', 'EXCHANGE_ARTICLE', @article_walk, 0, 0, NOW(), NOW());

-- ----------------------------------------
-- 10. 看板访问趋势与系统快照
-- ----------------------------------------
INSERT INTO t_site_visit_stats
    (stat_date, pv_count, uv_count, ip_count, remark, is_deleted, create_time, update_time)
VALUES
    ('2026-03-24', 820, 260, 210, '演示趋势：春夏服务季预热', 0, NOW(), NOW()),
    ('2026-03-25', 845, 268, 214, '演示趋势：春夏服务季预热', 0, NOW(), NOW()),
    ('2026-03-26', 870, 276, 221, '演示趋势：春夏服务季预热', 0, NOW(), NOW()),
    ('2026-03-27', 910, 288, 230, '演示趋势：周末前访问增长', 0, NOW(), NOW()),
    ('2026-03-28', 1080, 340, 266, '演示趋势：周末访问增长', 0, NOW(), NOW()),
    ('2026-03-29', 1125, 352, 275, '演示趋势：周末访问增长', 0, NOW(), NOW()),
    ('2026-03-30', 930, 295, 236, '演示趋势：工作日回落', 0, NOW(), NOW()),
    ('2026-03-31', 965, 304, 241, '演示趋势：活动页访问提升', 0, NOW(), NOW()),
    ('2026-04-01', 1020, 322, 255, '演示趋势：清明出游咨询', 0, NOW(), NOW()),
    ('2026-04-02', 1110, 350, 280, '演示趋势：清明出游咨询', 0, NOW(), NOW()),
    ('2026-04-03', 1260, 392, 309, '演示趋势：假期前访问增长', 0, NOW(), NOW()),
    ('2026-04-04', 1510, 470, 360, '演示趋势：假期高峰', 0, NOW(), NOW()),
    ('2026-04-05', 1585, 486, 372, '演示趋势：假期高峰', 0, NOW(), NOW()),
    ('2026-04-06', 1390, 431, 338, '演示趋势：假期返程', 0, NOW(), NOW()),
    ('2026-04-07', 1035, 328, 260, '演示趋势：工作日回落', 0, NOW(), NOW()),
    ('2026-04-08', 1065, 335, 268, '演示趋势：内容更新', 0, NOW(), NOW()),
    ('2026-04-09', 1090, 342, 272, '演示趋势：内容更新', 0, NOW(), NOW()),
    ('2026-04-10', 1180, 368, 291, '演示趋势：周末前访问增长', 0, NOW(), NOW()),
    ('2026-04-11', 1320, 410, 318, '演示趋势：周末访问增长', 0, NOW(), NOW()),
    ('2026-04-12', 1285, 398, 306, '演示趋势：周末访问增长', 0, NOW(), NOW()),
    ('2026-04-13', 1115, 350, 278, '演示趋势：活动报名咨询', 0, NOW(), NOW()),
    ('2026-04-14', 1160, 362, 286, '演示趋势：活动报名咨询', 0, NOW(), NOW()),
    ('2026-04-15', 1210, 378, 299, '演示趋势：活动报名咨询', 0, NOW(), NOW()),
    ('2026-04-16', 1245, 386, 304, '演示趋势：首页推荐更新', 0, NOW(), NOW()),
    ('2026-04-17', 1375, 425, 332, '演示趋势：周末前访问增长', 0, NOW(), NOW()),
    ('2026-04-18', 1520, 468, 362, '演示趋势：周末访问增长', 0, NOW(), NOW()),
    ('2026-04-19', 1495, 459, 355, '演示趋势：周末访问增长', 0, NOW(), NOW()),
    ('2026-04-20', 1260, 392, 308, '演示趋势：交流社区活跃', 0, NOW(), NOW()),
    ('2026-04-21', 1295, 405, 316, '演示趋势：交流社区活跃', 0, NOW(), NOW()),
    ('2026-04-22', 1330, 416, 323, '演示趋势：交流社区活跃', 0, NOW(), NOW()),
    ('2026-04-23', 1380, 430, 335, '演示趋势：景区详情访问提升', 0, NOW(), NOW()),
    ('2026-04-24', 1515, 468, 360, '演示趋势：周末前访问增长', 0, NOW(), NOW()),
    ('2026-04-25', 1740, 535, 410, '演示趋势：周末访问高峰', 0, NOW(), NOW()),
    ('2026-04-26', 1685, 518, 398, '演示趋势：周末访问高峰', 0, NOW(), NOW()),
    ('2026-04-27', 1395, 432, 336, '演示趋势：新闻内容更新', 0, NOW(), NOW()),
    ('2026-04-28', 1430, 442, 343, '演示趋势：新闻内容更新', 0, NOW(), NOW()),
    ('2026-04-29', 1510, 466, 361, '演示趋势：五一前咨询', 0, NOW(), NOW()),
    ('2026-04-30', 1725, 528, 406, '演示趋势：五一前咨询', 0, NOW(), NOW()),
    ('2026-05-01', 2050, 626, 480, '演示趋势：假期访问高峰', 0, NOW(), NOW()),
    ('2026-05-02', 2185, 662, 506, '演示趋势：假期访问高峰', 0, NOW(), NOW()),
    ('2026-05-03', 2260, 681, 520, '演示趋势：假期访问高峰', 0, NOW(), NOW()),
    ('2026-05-04', 2140, 648, 498, '演示趋势：假期访问高峰', 0, NOW(), NOW()),
    ('2026-05-05', 1810, 552, 424, '演示趋势：返程与活动查询', 0, NOW(), NOW()),
    ('2026-05-06', 1665, 510, 392, '演示趋势：服务季内容更新', 0, NOW(), NOW()),
    ('2026-05-07', 1745, 536, 410, '演示趋势：演示数据写入日', 0, NOW(), NOW())
ON DUPLICATE KEY UPDATE
    pv_count = VALUES(pv_count),
    uv_count = VALUES(uv_count),
    ip_count = VALUES(ip_count),
    remark = VALUES(remark),
    is_deleted = 0,
    update_time = NOW();

INSERT INTO t_system_metric
    (host, cpu_usage, memory_usage, disk_usage, load_avg, remark, is_deleted, create_time, update_time)
VALUES
    ('aft-demo-local', 18.40, 46.20, 61.30, '0.42,0.38,0.35', '演示快照：服务平稳', 0, '2026-05-07 08:00:00', NOW()),
    ('aft-demo-local', 22.10, 48.70, 61.40, '0.51,0.44,0.39', '演示快照：访问增长', 0, '2026-05-07 09:00:00', NOW()),
    ('aft-demo-local', 25.80, 50.10, 61.40, '0.60,0.50,0.43', '演示快照：内容查询活跃', 0, '2026-05-07 10:00:00', NOW()),
    ('aft-demo-local', 21.30, 49.20, 61.50, '0.48,0.45,0.42', '演示快照：缓存命中稳定', 0, '2026-05-07 11:00:00', NOW()),
    ('aft-demo-local', 28.60, 53.40, 61.50, '0.72,0.58,0.49', '演示快照：活动页访问提升', 0, '2026-05-07 12:00:00', NOW()),
    ('aft-demo-local', 24.50, 51.60, 61.60, '0.56,0.51,0.47', '演示快照：系统平稳', 0, '2026-05-07 13:00:00', NOW()),
    ('aft-demo-local', 19.90, 47.80, 61.60, '0.43,0.40,0.38', '演示快照：午后回落', 0, '2026-05-07 14:00:00', NOW()),
    ('aft-demo-local', 23.70, 49.90, 61.70, '0.52,0.47,0.43', '演示快照：社区互动活跃', 0, '2026-05-07 15:00:00', NOW()),
    ('aft-demo-local', 26.20, 52.10, 61.70, '0.63,0.54,0.48', '演示快照：后台审核演示', 0, '2026-05-07 16:00:00', NOW()),
    ('aft-demo-local', 20.80, 48.30, 61.80, '0.46,0.42,0.40', '演示快照：服务平稳', 0, '2026-05-07 17:00:00', NOW());

COMMIT;

