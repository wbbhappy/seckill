/*
Navicat MySQL Data Transfer

Source Server         : 127.0.0.1
Source Server Version : 50618
Source Host           : localhost:3306
Source Database       : seckill

Target Server Type    : MYSQL
Target Server Version : 50618
File Encoding         : 65001

Date: 2019-02-26 17:01:36
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for pay_order
-- ----------------------------
DROP TABLE IF EXISTS `pay_order`;
CREATE TABLE `pay_order` (
  `seckill_id` bigint(20) NOT NULL COMMENT '秒杀商品id',
  `user_phone` bigint(20) NOT NULL COMMENT '用户手机号',
  `state` tinyint(4) NOT NULL DEFAULT '-1' COMMENT '状态标示:-1:无效 0:成功 1:已付款 2:已发货',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`seckill_id`,`user_phone`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='秒杀成功明细表';

-- ----------------------------
-- Records of pay_order
-- ----------------------------

-- ----------------------------
-- Table structure for seckill
-- ----------------------------
DROP TABLE IF EXISTS `seckill`;
CREATE TABLE `seckill` (
  `seckill_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '商品库存id',
  `name` varchar(120) NOT NULL COMMENT '商品名称',
  `number` int(11) NOT NULL COMMENT '库存数量',
  `start_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '秒杀开启时间',
  `end_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '秒杀结束时间',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`seckill_id`),
  KEY `idx_start_time` (`start_time`),
  KEY `idx_end_time` (`end_time`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB AUTO_INCREMENT=1004 DEFAULT CHARSET=utf8 COMMENT='秒杀库存表';

-- ----------------------------
-- Records of seckill
-- ----------------------------
INSERT INTO `seckill` VALUES ('1000', '1000元秒杀iphone6s', '99', '2019-02-26 17:00:02', '2019-02-26 17:30:00', '2019-02-25 16:24:30');
INSERT INTO `seckill` VALUES ('1001', '100元秒杀iphone6', '200', '2016-12-19 00:00:00', '2016-12-20 00:00:00', '2019-02-25 16:24:30');
INSERT INTO `seckill` VALUES ('1002', '200元秒杀iphone5', '300', '2016-12-19 00:00:00', '2016-12-20 00:00:00', '2019-02-25 16:24:30');
INSERT INTO `seckill` VALUES ('1003', '10元秒杀iphone4', '400', '2016-12-19 00:00:00', '2016-12-20 00:00:00', '2019-02-25 16:24:30');

-- ----------------------------
-- Table structure for success_killed
-- ----------------------------
DROP TABLE IF EXISTS `success_killed`;
CREATE TABLE `success_killed` (
  `seckill_id` bigint(20) NOT NULL COMMENT '秒杀商品id',
  `user_phone` bigint(20) NOT NULL COMMENT '用户手机号',
  `state` tinyint(4) NOT NULL DEFAULT '-1' COMMENT '创建标识：-1 无效  0 成功 1：已付款 2：已发货',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`seckill_id`,`user_phone`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='秒杀成功明细表';

-- ----------------------------
-- Records of success_killed
-- ----------------------------
INSERT INTO `success_killed` VALUES ('1000', '15100317880', '-1', '2019-02-26 17:00:03');

-- ----------------------------
-- Procedure structure for execute_seckill
-- ----------------------------
DROP PROCEDURE IF EXISTS `execute_seckill`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `execute_seckill`(in v_seckill_id bigint,in v_phone bigint,in v_kill_time timestamp,out r_result int)
BEGIN
		DECLARE insert_count int DEFAULT 0;
		START TRANSACTION;
		insert ignore into success_killed
			(seckill_id,user_phone,create_time)
		values (v_seckill_id,v_phone,v_kill_time);
		SELECT row_count() into insert_count;
		IF (insert_count=0) THEN
			ROLLBACK;
			set r_result = -1;
		ELSEIF(insert_count<0) then
			ROLLBACK;
			SET r_result = -2;
		ELSE
			update seckill
			set number = number-1
			where seckill_id =v_seckill_id
				and end_time>v_kill_time
				and start_time<v_kill_time
				and number>0;
			SELECT row_count() into insert_count;
			IF(insert_count=0) THEN
				ROLLBACK;
				set r_result=0;
			ELSEIF(insert_count<0) THEN
				ROLLBACK;
				set r_result=-2;
			ELSE
				COMMIT;
				set r_result=1;
			END IF;
		END IF;
	END
;;
DELIMITER ;
