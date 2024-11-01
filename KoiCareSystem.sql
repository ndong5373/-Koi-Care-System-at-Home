USE master;
GO
IF EXISTS(SELECT * FROM sys.databases WHERE name = 'KoiCareSystem')
BEGIN
    ALTER DATABASE KoiCareSystem SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE KoiCareSystem;
END
GO

CREATE DATABASE KoiCareSystem;
GO
USE KoiCareSystem;
GO

-- Bảng lưu trữ thông tin chủ nhà
CREATE TABLE Homeowner (
    homeowner_id INT PRIMARY KEY IDENTITY(1,1),
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(50) NOT NULL,
    address VARCHAR(100),
    phone_number VARCHAR(15),
    email VARCHAR(50)
);

-- Bảng lưu trữ thông tin nhân viên bảo trì
CREATE TABLE MaintenancePerson (
    maintenance_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(15),
    email VARCHAR(50),
    experience_years INT
);

-- Bảng lưu trữ thông tin về hồ cá
CREATE TABLE Pond (
    pond_id INT PRIMARY KEY IDENTITY(1,1),
    homeowner_id INT,
    pond_size DECIMAL(10, 2), -- kích thước hồ (m²)
    water_quality VARCHAR(50),
    fish_count INT,
    FOREIGN KEY (homeowner_id) REFERENCES Homeowner(homeowner_id) ON DELETE SET NULL
);

-- Bảng lưu trữ thông tin thức ăn cho cá koi
CREATE TABLE Food (
    food_id INT PRIMARY KEY IDENTITY(1,1),
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
    sensor_id INT PRIMARY KEY IDENTITY(1,1),
    pond_id INT,
    record_time DATETIME DEFAULT GETDATE(),
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
    description VARCHAR(MAX),
    FOREIGN KEY (maintenance_id) REFERENCES MaintenancePerson(maintenance_id) ON DELETE CASCADE,
    FOREIGN KEY (pond_id) REFERENCES Pond(pond_id) ON DELETE CASCADE,
    PRIMARY KEY (maintenance_id, pond_id, maintenance_date)
);

-- Bảng thông báo tự động cho người dùng
CREATE TABLE Notifications (
    notification_id INT PRIMARY KEY IDENTITY(1,1),
    homeowner_id INT,
    pond_id INT,
    message VARCHAR(MAX),
    notification_date DATETIME DEFAULT GETDATE(),
    status VARCHAR(10) CHECK (status IN ('Sent', 'Pending')) DEFAULT 'Pending',
    FOREIGN KEY (homeowner_id) REFERENCES Homeowner(homeowner_id) ON DELETE CASCADE,
    FOREIGN KEY (pond_id) REFERENCES Pond(pond_id) ON DELETE CASCADE
);

-- Thêm dữ liệu mẫu vào các bảng
INSERT INTO Homeowner (username, password, name, address, phone_number, email)
VALUES 
('user1', 'password123', 'Nguyen Van A', '123 Street', '0123456789', 'nguyenvana@example.com'),
('user2', 'password456', 'Tran Van B', '456 Avenue', '0987654321', 'tranvanb@example.com');

INSERT INTO MaintenancePerson (name, phone_number, email, experience_years)
VALUES 
('John Doe', '0987654321', 'johndoe@example.com', 5),
('Jane Smith', '0123456789', 'janesmith@example.com', 3);

INSERT INTO Pond (homeowner_id, pond_size, water_quality, fish_count)
VALUES 
(1, 20.5, 'Good', 15),
(2, 15.0, 'Average', 10);

INSERT INTO Food (food_name, food_type, nutrition_value, expiration_date)
VALUES 
('Koi Food', 'Type A', 'High', '2025-12-31'),
('Fish Treat', 'Type B', 'Medium', '2026-06-30');

INSERT INTO PondFood (pond_id, food_id, feed_time)
VALUES 
(1, 1, '09:00:00'),
(2, 2, '18:00:00');

INSERT INTO SensorData (pond_id, temperature, pH_level, oxygen_level)
VALUES 
(1, 26.5, 7.5, 6.0),
(2, 24.0, 7.2, 5.5);

INSERT INTO MaintenanceRecord (maintenance_id, pond_id, maintenance_date, description)
VALUES 
(1, 1, '2024-11-01', 'Kiểm tra chất lượng nước hồ'),
(2, 2, '2024-11-02', 'Thay nước hồ');

INSERT INTO Notifications (homeowner_id, pond_id, message, notification_date, status)
VALUES 
(1, 1, 'Cần bổ sung thức ăn cho cá.', GETDATE(), 'Pending'),
(2, 2, 'Kiểm tra hồ cá trong ngày.', GETDATE(), 'Sent');
