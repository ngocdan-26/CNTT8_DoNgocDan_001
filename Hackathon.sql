create database hackathon;
use hackathon;
-- p mọi tuổi c cấm k < 13  
-- bảng movies 
create table movies(
movie_id char(5) primary key,
movie_name varchar(100) not null unique,
genre varchar(100) not null,
duration int not null check(duration > 0),
Age_rating varchar(2) not null 
);

-- bảng rooms
create table rooms(
room_id char(5) primary key,
room_name varchar(100) not null,
seat_count int not null check(seat_count > 0),
room_type enum ('IMAX','3D','2D') default('IMAX'),
room_status bit default(1)
);

-- bảng showtime
create table showtime(
show_id char(5) primary key,
movie_id char(5),
foreign key ̣̣(movie_id) references movies(movie_id),
room_id char(5),
foreign key (room_id) references rooms(room_id),
start_time datetime not null ,
end_time datetime not null ,
show_status enum('scheduled','canceduled') default('scheduled')
);

-- bảng bookings
create table bookings(
booking_id char(5) primary key,
show_id char(5),
foreign key (show_id) references showtime(show_id),
seat_no varchar(10) not null unique,
hold_time datetime not null ,
payment_status enum('paid','pending','expired') default('pending')
);

-- II. thêm dữ liệu vào trong các bảng
insert into movies(movie_id,movie_name,genre,duration,Age_rating)
value 
('PH001','Avengers: Secret Wars','Action',180,'13'),
('PH002','Dreamon Movie','Animation',105,'P'),
('PH003','The Nun','Horror',120,'18'),
('PH004','Interstellar','Sci-fi',169,'13'),
('PH005','Kungfu Panda 4','Animation',94,'P');

insert into rooms
value
('PC001','Hall A',120,'IMAX',1),
('PC002','Hall B',80,'3D',1),
('PC003','Hall C',60,'2D',0),
('PC004','Hall D',100,'3D',1),
('PC005','Hall E',150,'IMAX',1);

insert into showtime
value
('SC001','PH001','PC001','2026-05-20 18:00','2026-05-20 21:00','scheduled'),
('SC002','PH002','PC002','2026-05-20 14:00','2026-05-20 15:45','scheduled'),
('SC003','PH003','PC003','2026-05-20 20:00','2026-05-20 22:00','canceduled'),
('SC004','PH004','PC004','2026-05-20 19:00','2026-05-20 21:49','scheduled'),
('SC005','PH005','PC002','2026-05-20 09:00','2026-05-20 10:34','scheduled'),
('SC006','PH001','PC001','2026-05-20 14:00','2026-05-20 17:00','scheduled');

insert into bookings
value
('BK001','SC001','A12','2026-05-20 17:45','paid'),
('BK002','SC001','A13','2026-05-20 17:45','pending'),
('BK003','SC001','A14','2026-05-20 17:45','expired'),
('BK004','SC001','B01','2026-05-20 17:45','expired'),
('BK005','SC001','B02','2026-05-20 17:45','expired'),
('BK006','SC002','B05','2026-05-20 17:45','paid'),
('BK007','SC004','C20','2026-05-20 17:45','paid'),
('BK008','SC005','D09','2026-05-20 08:55','pending'),
('BK009','SC006','E01','2026-05-20 13:30','paid'),
('BK010','SC006','E02','2026-05-20 13:35','paid');

update showtime
set show_status = 'scheduled'
where room_id = 'PC003';

delete from movies
where movie_name = 'The Nun'; -- hệ thống đã ngăn chặn xóa do trong bảng showtime đang chứa dữ liệu của dữ liệu cần xóa
-- nên sửa trạng thái cúa showtime sang canceduled
update showtime
set show_status = 'canceduled'
where movie_id = 'PH003';


-- III. nghiệp vụ điều phối và hỗ trợ khách hàng
-- 1. tra cứu nhanh cho khách
select m.movie_name , s.start_time 
from movies m inner join showtime s on m.movie_id = s.movie_id
where m.movie_name = 'Avengers: Secret Wars';

-- 2. hỗ trợ quầy vé
select seat_no
from bookings
where payment_status = 'pending' and show_id = 'SC001';

-- 3. Bảng tin LED sảnh chờ 
select show_id,movie_id,room_id,start_time,end_time,show_status
from showtime 
order by start_time asc limit 5 offset 3 ;

-- IV. giám sát hiệu suất thất thoát
select s.show_id , m.movie_name ,seat_count ,((count(payment_status)/seat_count)*100)as 'ti le lap day'
from movies m inner join showtime s on m.movie_id = s.movie_id
inner join rooms r on r.room_id = s.room_id
inner join bookings b on b.show_id = s.show_id
where payment_status = 'paid'
group by b.show_id
having count(payment_status) 
