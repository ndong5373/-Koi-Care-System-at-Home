-- Tạo cơ sở dữ liệu và sử dụng nó
CREATE DATABASE IF NOT EXISTS KoiCareSystem;
USE KoiCareSystem;

-- Xóa các bảng nếu đã tồn tại
DROP TABLE IF EXISTS PondFood;
DROP TABLE IF EXISTS SensorData;
DROP TABLE IF EXISTS Notifications;
DROP TABLE IF EXISTS MaintenanceRecord;
DROP TABLE IF EXISTS Pond;
DROP TABLE IF EXISTS Food;
DROP TABLE IF EXISTS MaintenancePerson;
DROP TABLE IF EXISTS Homeowner;

-- Bảng lưu trữ thông tin chủ nhà
CREATE TABLE Homeowner (
    homeowner_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(50) NOT NULL,
    address VARCHAR(100),
    phone_number VARCHAR(15),
    email VARCHAR(50)
);

-- Bảng lưu trữ thông tin nhân viên bảo trì
CREATE TABLE MaintenancePerson (
    maintenance_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(15),
    email VARCHAR(50),
    experience_years INT
);

-- Bảng lưu trữ thông tin về hồ cá
CREATE TABLE Pond (
    pond_id INT PRIMARY KEY AUTO_INCREMENT,
    homeowner_id INT,
    pond_size DECIMAL(10, 2), -- kích thước hồ (m²)
    water_quality VARCHAR(50),
    fish_count INT,
    FOREIGN KEY (homeowner_id) REFERENCES Homeowner(homeowner_id) ON DELETE SET NULL
);

-- Bảng lưu trữ thông tin thức ăn cho cá koi
CREATE TABLE Food (
    food_id INT PRIMARY KEY AUTO_INCREMENT,
    food_name VARCHAR(50) NOT NULL,
    food_type VARCHAR(50),
    nutrition_value VARCHAR(100),
    expiration_date DATE
);

-- Bảng quản lý lượng thức ăn và thời gian cho ăn của từng hồ cá
CREATE TABLE PondFood (
    pond_id INT,
    food_id INT,
    feed_time TIME, -- thời gian cho ăn
    FOREIGN KEY (pond_id) REFERENCES Pond(pond_id) ON DELETE CASCADE,
    FOREIGN KEY (food_id) REFERENCES Food(food_id) ON DELETE CASCADE,
    PRIMARY KEY (pond_id, food_id, feed_time)
);

-- Bảng lưu trữ dữ liệu cảm biến về nhiệt độ, độ pH và oxy
CREATE TABLE SensorData (
    sensor_id INT PRIMARY KEY AUTO_INCREMENT,
    pond_id INT,
    record_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    temperature DECIMAL(5, 2), -- nhiệt độ
    pH_level DECIMAL(3, 2), -- độ pH
    oxygen_level DECIMAL(5, 2), -- mức oxy
    FOREIGN KEY (pond_id) REFERENCES Pond(pond_id) ON DELETE CASCADE
);

-- Bảng lưu trữ lịch sử bảo trì hồ cá
CREATE TABLE MaintenanceRecord (
    maintenance_id INT,
    pond_id INT,
    maintenance_date DATE,
    description TEXT,
    FOREIGN KEY (maintenance_id) REFERENCES MaintenancePerson(maintenance_id) ON DELETE CASCADE,
    FOREIGN KEY (pond_id) REFERENCES Pond(pond_id) ON DELETE CASCADE,
    PRIMARY KEY (maintenance_id, pond_id, maintenance_date)
);

-- Bảng thông báo tự động cho người dùng
CREATE TABLE Notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    homeowner_id INT,
    pond_id INT,
    message TEXT,
    notification_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Sent', 'Pending') DEFAULT 'Pending',
    FOREIGN KEY (homeowner_id) REFERENCES Homeowner(homeowner_id) ON DELETE CASCADE,
    FOREIGN KEY (pond_id) REFERENCES Pond(pond_id) ON DELETE CASCADE
);

-- Thêm dữ liệu mẫu để kiểm tra các chức năng use-case
-- Thêm dữ liệu vào Homeowner và Pond trước khi tạo thông báo
INSERT INTO Homeowner (username, password, name, address, phone_number, email)
VALUES ('user1', 'password123', 'Nguyen Van A', '123 Street', '0123456789', 'nguyenvana@example.com');

INSERT INTO Pond (homeowner_id, pond_size, water_quality, fish_count)
VALUES (1, 20.5, 'Good', 15);

-- a. Thêm Thông báo khi Thiếu Thức Ăn
INSERT INTO Notifications (homeowner_id, pond_id, message)
VALUES (1, 1, 'Thức ăn cho cá trong hồ này sắp hết. Vui lòng kiểm tra và bổ sung.');

-- b. Lấy Dữ liệu Cảm Biến Mới Nhất cho Hồ Cá
SELECT * FROM SensorData
WHERE pond_id = 1
ORDER BY record_time DESC
LIMIT 1;

-- c. Kiểm tra Lịch Sử Bảo Trì cho Hồ Cá
SELECT * FROM MaintenanceRecord
WHERE pond_id = 1;

-- d. Kiểm tra Lịch sử Cho Ăn
SELECT PondFood.feed_time, Food.food_name
FROM PondFood
JOIN Food ON PondFood.food_id = Food.food_id
WHERE pond_id = 1;

-- e. Cập nhật Trạng thái Thông báo sau Khi Gửi
UPDATE Notifications
SET status = 'Sent'
WHERE notification_id = 1;
