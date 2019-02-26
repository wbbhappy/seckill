create table seckill(
seckill_id bigint not null auto_increment comment '商品库存id',
name varchar(120) not null comment '商品名称',
number int not null comment '库存数量',
start_time timestamp not null comment '秒杀开启时间',
end_time timestamp not null comment '秒杀结束时间',
create_time timestamp not null default current_timestamp comment '创建时间',
primary key (seckill_id),
key idx_start_time (start_time),
key idx_end_time (end_time),
key idx_create_time (create_time)
)engine=InnoDB auto_increment=1000 default charset=utf8 comment='秒杀库存表';
insert into seckill(name,number,start_time,end_time) values
('1000元秒杀iphone6',100,'2015-11-01 00:00:00','2015-11-02 00:00:00'),
('500元秒杀ipad2',200,'2015-11-01 00:00:00','2015-11-02 00:00:00'),
('300元秒杀小米4',300,'2015-11-01 00:00:00','2015-11-02 00:00:00'),
('200元秒杀红米note',400,'2015-11-01 00:00:00','2015-11-02 00:00:00');


create table success_killed(
seckill_id int not null comment '秒杀商品id',
user_phone bigint not null comment '用户手机号',
state int(1) not null default -1 comment '状态标示,-1：无效,0：成功,1：无效，2：已发货',
create_time timestamp not null comment '创建时间',
primary key (seckill_id,user_phone),
key idx_create_time(create_time)
)engine=InnoDB default charset=utf8 comment='秒杀成功明细表';