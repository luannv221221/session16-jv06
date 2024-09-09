CREATE DATABASE session15;
USE session15;

CREATE TABLE Category (
	Id int auto_increment primary key,
    Name nvarchar(100) NOT NULL UNIQUE,
	Status tinyint default 1 check (Status IN (0,1))
);

CREATE TABLE Room (
	Id int primary key auto_increment,
    Name nvarchar(150) NOT NULL,
    Status tinyint default 1 check (Status IN (0,1)),
    Price float NOT NULL check (Price >= 10000),
    SalePrice float default 0 ,check (SalePrice <= Price),
    CreatedDate datetime DEFAULT CURRENT_TIMESTAMP,
    CategoryId INT NOT NULL,
    FOREIGN KEY (CategoryId) REFERENCES Category(Id)
);

CREATE TABLE Customer (
	Id int auto_increment primary key,
	Name Nvarchar(150) NOT NULL,
	Email varchar(150) NOT NULL UNIQUE CHECK (Email LIKE '%_@__%.__%'),
	Phone varchar(50) NOT NULL UNIQUE,
	Address nvarchar(255),
	CreatedDate datetime DEFAULT CURRENT_TIMESTAMP,
	Gender tinyint NOT NULL check (Gender IN (0,1,2)),
	BirthDay date NOT NULL
);

CREATE TABLE Booking (
	Id int auto_increment primary key,
	Customerid int NOT NULL,
    Status TINYINT DEFAULT 1 CHECK (Status IN (0, 1, 2, 3)),
    BookingDate datetime DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (Customerid) REFERENCES Customer(id)
);

CREATE TABLE BookingDetail (
    BookingId int NOT NULL,
    RoomId int NOT NULL,
    Price float NOT NULL,
    StartDate datetime NOT NULL,
    EndDate datetime NOT NULL ,CHECK (EndDate > StartDate),
    PRIMARY KEY (BookingId, RoomId),
    FOREIGN KEY (BookingId) REFERENCES Booking(Id),
    FOREIGN KEY (RoomId) REFERENCES Room(Id)
);

INSERT INTO Category (Name, Status) VALUES
('Deluxe', 1), ('Standard', 1), ('Suite', 1), ('Single', 1), ('Double', 1);

INSERT INTO Room (Name, Status, Price, SalePrice, CategoryId) VALUES
('Room A', 1, 300000, 250000,  1),
('Room B', 1, 500000, 450000, 2),
('Room C', 1, 400000, 380000, 3),
('Room D', 1, 400000, 280000, 4),
('Room E', 1, 400000, 380000, 5),
('Room F', 1, 400000, 380000, 5),
('Room G', 1, 400000, 380000, 4),
('Room H', 1, 400000, 380000, 3),
('Room I', 1, 400000, 380000, 2),
('Room K', 1, 400000, 380000, 2),
('Room L', 1, 400000, 380000, 1),
('Room Q', 1, 400000, 380000, 3),
('Room W', 1, 400000, 380000, 4),
('Room E', 1, 400000, 380000, 1),
('Room R', 1, 400000, 380000, 2);

INSERT INTO Customer (Name, Email, Phone, Address, CreatedDate, Gender, BirthDay) VALUES
('Nguyen Van A', 'a@example.com', '0901234567', '123 ABC Street', CURRENT_DATE, 1, '1990-01-01'),
('Le Thi B', 'b@example.com', '0909876543', '456 DEF Street', CURRENT_DATE, 2, '1985-05-15'),
('Tran Van C', 'c@example.com', '0908765432', '789 GHI Street', CURRENT_DATE, 0, '1995-12-12');

INSERT INTO Booking (CustomerId, Status, BookingDate) VALUES
(1, 1, CURRENT_TIMESTAMP),
(2, 1, CURRENT_TIMESTAMP),
(3, 1, CURRENT_TIMESTAMP);

INSERT INTO BookingDetail (BookingId, RoomId, Price, StartDate, EndDate) VALUES
(1, 1, 300000, '2024-09-01 14:00', '2024-09-09 12:00'),
(1, 2, 500000, '2024-09-01 14:00', '2024-09-12 12:00'),
(2, 3, 400000, '2024-09-06 14:00', '2024-09-10 12:00'),
(3, 2, 500000, '2024-09-07 14:00', '2024-09-15 12:00');
SELECT * FROM Room;
SELECT * FROM Booking;
SELECT * FROM BookingDetail;
SELECT * FROM Customer;
SELECT * FROM Category;
-- Lấy ra danh phòng có sắp xếp giảm dần theo Price gồm các cột sau: Id, Name, Price, SalePrice, Status, CategoryName, CreatedDate
SELECT Room.Id, Room.Name, Room.Price, Room.SalePrice, Room.Status, Category.Name AS CategoryName, Room.CreatedDate
FROM Room 
JOIN Category ON Room.CategoryId = Category.Id
ORDER BY Room.Price DESC;

-- Lấy ra danh sách Category gồm: Id, Name, TotalRoom, Status

SELECT Category.Id, Category.Name, COUNT(Category.Id) AS TotalRoom, Category.Status
From Category
LEFT JOIN Room ON Category.Id = Room.CategoryId
GROUP BY Category.Id, Category.Name, Category.Status;

-- Truy vấn danh sách Customer gồm: Id, Name, Email, Phone, Address, CreatedDate, Gender, BirthDay, Age

SELECT Id, Name, Email, Phone, Address, CreatedDate, Gender, BirthDay, 
YEAR(CURRENT_DATE) - YEAR(BirthDay) AS Age
FROM Customer;

-- Truy vấn xóa các sản phẩm chưa được bán
-- lấy ra được id room trong bảng booking_detail 
SELECT RoomId FROM BookingDetail;
-- Xóa room có id khác danh sách lấy được ở bước trên 
DELETE FROM Room WHERE id NOT IN(SELECT RoomId FROM BookingDetail);

-- Lấy ra danh sách của 10 phòng có giá cao nhất 
-- Sắp xếp danh sách phòng theo giá giảm dần giới hạn 10 bản ghi
SELECT * FROM Room  ORDER BY price DESC LIMIT 10;

-- Hiển thị danh sách phiếu đặt hàng gồm: Id, BookingDate, Status, CusName, Email, Phone,TotalAmount 
SELECT * FROM Booking;
SELECT * FROM Customer;
SELECT * FROM BookingDetail;
SELECT Booking.Id,Booking.BookingDate,Booking.Status,Customer.Name as CusName,Customer.Email,Customer.Phone,COUNT(BookingDetail.BookingId) as TotalAmount
FROM Booking
JOIN Customer
ON Booking.Customerid = Customer.Id
JOIN BookingDetail 
ON Booking.Id = BookingDetail.BookingId
GROUP BY Booking.Id;

-- Tạo Stored Procedure 
-- Tạo thủ tục lưu trữ để lấy về Lấy ra danh sách của 10 phòng có giá cao nhất  
DELIMITER $$ 
	CREATE PROCEDURE proc_fetch_10_recod_rom_DESC()
		BEGIN
			/*Xư lý */
            SELECT * FROM Room  ORDER BY price DESC LIMIT 10;
        END; $$
DELIMITER ;
-- Gọi Thủ tục lưu trữ 
CALL proc_fetch_10_recod_rom_DESC();
-- Tao thủ tục lưu trữ thêm mới dữ liệu vào bảng 

DELIMITER $$ 
	CREATE PROCEDURE proc_add_category(IN category_name nvarchar(150), category_status tinyint)
    BEGIN
		INSERT INTO Category (Name, Status) VALUE (category_name, category_status);
    END $$
DELIMITER ;
-- Goi thủ tục có tham số đầu vào call proc_add_category('Ao', 1);
CALL proc_add_category('ÁO SƠ MI',1);
SELECT * FROM category;
-- Tạo thủ tục update danh mục 

DELIMITER $$ 
	CREATE PROCEDURE proc_update_category(IN category_name nvarchar(150), category_status tinyint,cate_id int)
    BEGIN
		UPDATE Category SET Name = category_name,Status = category_status WHERE Id = cate_id; 
    END $$
DELIMITER ;

CALL proc_update_category('Quần',0,6);
-- Tạo thủ tục xóa danh mục 
 
DELIMITER $$ 
	CREATE PROCEDURE proc_delete_category(IN cate_id int)
    BEGIN
		DELETE FROM category WHERE Id = cate_id;
    END $$
DELIMITER ;
CALL proc_delete_category(6);

-- Tạo thủ tục lấy về thông tin danh mục theo id truyền vào 

DELIMITER $$ 
	CREATE PROCEDURE proc_get_category_by_id(IN cate_id int,OUT total_rom int)
    BEGIN
		
    END $$
DELIMITER ;
CALL proc_get_category_by_id(8);
-- Thủ tục lưu trữ có tham số đầu vào và đầu ra 
-- Tạo thủ tục trả về tổng số rom theo id của danh mục truyền vào 
DELIMITER $$ 
	CREATE PROCEDURE proc_get_total_rom_by_categoryID(IN cate_id int,OUT total_room int)
    BEGIN
		SET total_room = (SELECT count(room.categoryId)
			FROM category
			JOIN room
			ON category.id = room.categoryId 
			GROUP BY room.categoryId
			HAVING room.categoryId = cate_id);
    END $$
DELIMITER ;
-- Gọi thủ tục 
set @total_room = 0;
call proc_get_total_rom_by_categoryID(1, @total_room);
select @total_room;



