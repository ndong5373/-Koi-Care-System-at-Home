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
CREATE TABLE ChuNha (
    chu_nha_id INT PRIMARY KEY IDENTITY(1,1),
    ten_tai_khoan VARCHAR(50) UNIQUE NOT NULL,
    mat_khau VARCHAR(255) NOT NULL,
    ho_ten VARCHAR(50) NOT NULL,
    dia_chi VARCHAR(100),
    so_dien_thoai VARCHAR(15),
    email VARCHAR(50)
);

-- Bảng lưu trữ thông tin nhân viên bảo trì
CREATE TABLE NhanVienBaoTri (
    nhan_vien_id INT PRIMARY KEY IDENTITY(1,1),
    ho_ten VARCHAR(50) NOT NULL,
    so_dien_thoai VARCHAR(15),
    email VARCHAR(50),
    kinh_nghiem_nam INT
);

-- Bảng lưu trữ thông tin về hồ cá
CREATE TABLE HoCa (
    ho_ca_id INT PRIMARY KEY IDENTITY(1,1),
    chu_nha_id INT,
    kich_thuoc DECIMAL(10, 2), -- kích thước hồ (m²)
    chat_luong_nuoc VARCHAR(50),
    so_ca INT,
    FOREIGN KEY (chu_nha_id) REFERENCES ChuNha(chu_nha_id) ON DELETE SET NULL
);

-- Bảng lưu trữ thông tin thức ăn cho cá koi
CREATE TABLE ThucAn (
    thuc_an_id INT PRIMARY KEY IDENTITY(1,1),
    ten_thuc_an VARCHAR(50) NOT NULL,
    loai_thuc_an VARCHAR(50),
    gia_tri_dinh_duong VARCHAR(100),
    ngay_hhet_han DATE
);

-- Bảng quản lý lượng thức ăn và thời gian cho ăn của từng hồ cá
CREATE TABLE ThucAnHoCa (
    ho_ca_id INT,
    thuc_an_id INT,
    thoi_gian_cho_an TIME, -- thời gian cho ăn
    FOREIGN KEY (ho_ca_id) REFERENCES HoCa(ho_ca_id) ON DELETE CASCADE,
    FOREIGN KEY (thuc_an_id) REFERENCES ThucAn(thuc_an_id) ON DELETE CASCADE,
    PRIMARY KEY (ho_ca_id, thuc_an_id, thoi_gian_cho_an)
);

-- Bảng lưu trữ dữ liệu cảm biến về nhiệt độ, độ pH và oxy
CREATE TABLE DuLieuCamBien (
    cam_bien_id INT PRIMARY KEY IDENTITY(1,1),
    ho_ca_id INT,
    thoi_gian_ghi DATETIME DEFAULT GETDATE(),
    nhiet_do DECIMAL(5, 2), -- nhiệt độ
    muc_pH DECIMAL(3, 2), -- độ pH
    muc_oxy DECIMAL(5, 2), -- mức oxy
    FOREIGN KEY (ho_ca_id) REFERENCES HoCa(ho_ca_id) ON DELETE CASCADE
);

-- Bảng lưu trữ lịch sử bảo trì hồ cá
CREATE TABLE LichSuBaoTri (
    nhan_vien_id INT,
    ho_ca_id INT,
    ngay_bao_tri DATE,
    mo_ta VARCHAR(MAX),
    FOREIGN KEY (nhan_vien_id) REFERENCES NhanVienBaoTri(nhan_vien_id) ON DELETE CASCADE,
    FOREIGN KEY (ho_ca_id) REFERENCES HoCa(ho_ca_id) ON DELETE CASCADE,
    PRIMARY KEY (nhan_vien_id, ho_ca_id, ngay_bao_tri)
);

-- Bảng thông báo tự động cho người dùng
CREATE TABLE ThongBao (
    thong_bao_id INT PRIMARY KEY IDENTITY(1,1),
    chu_nha_id INT,
    ho_ca_id INT,
    thong_diep VARCHAR(MAX),
    thoi_gian_thong_bao DATETIME DEFAULT GETDATE(),
    trang_thai VARCHAR(10) CHECK (trang_thai IN ('Gửi', 'Đang chờ')) DEFAULT 'Đang chờ',
    FOREIGN KEY (chu_nha_id) REFERENCES ChuNha(chu_nha_id) ON DELETE CASCADE,
    FOREIGN KEY (ho_ca_id) REFERENCES HoCa(ho_ca_id) ON DELETE CASCADE
);

-- Thêm dữ liệu mẫu vào các bảng
INSERT INTO ChuNha (ten_tai_khoan, mat_khau, ho_ten, dia_chi, so_dien_thoai, email)
VALUES 
('user1', 'password123', 'Nguyen Van A', '123 Đường', '0123456789', 'nguyenvana@gmail.com'),
('user2', 'password456', 'Tran Van B', '456 Đại lộ', '0987654321', 'tranvanb@gmail.com');

INSERT INTO NhanVienBaoTri (ho_ten, so_dien_thoai, email, kinh_nghiem_nam)
VALUES 
('Nguyen Van C', '0987654321', 'nguyenvanc@gmail.com', 5),
('Le Thi D', '0123456789', 'lethid@gmail.com', 3);

INSERT INTO HoCa (chu_nha_id, kich_thuoc, chat_luong_nuoc, so_ca)
VALUES 
(1, 20.5, 'Tốt', 15),
(2, 15.0, 'Trung bình', 10);

INSERT INTO ThucAn (ten_thuc_an, loai_thuc_an, gia_tri_dinh_duong, ngay_hhet_han)
VALUES 
('Thức ăn cá koi', 'Loại A', 'Cao', '2025-12-31'),
('Thức ăn cho cá', 'Loại B', 'Trung bình', '2026-06-30');

INSERT INTO ThucAnHoCa (ho_ca_id, thuc_an_id, thoi_gian_cho_an)
VALUES 
(1, 1, '09:00:00'),
(2, 2, '18:00:00');

INSERT INTO DuLieuCamBien (ho_ca_id, nhiet_do, muc_pH, muc_oxy)
VALUES 
(1, 26.5, 7.5, 6.0),
(2, 24.0, 7.2, 5.5);

INSERT INTO LichSuBaoTri (nhan_vien_id, ho_ca_id, ngay_bao_tri, mo_ta)
VALUES 
(1, 1, '2024-11-01', 'Kiểm tra chất lượng nước hồ'),
(2, 2, '2024-11-02', 'Thay nước hồ');

INSERT INTO ThongBao (chu_nha_id, ho_ca_id, thong_diep, thoi_gian_thong_bao, trang_thai)
VALUES 
(1, 1, 'Cần bổ sung thức ăn cho cá.', GETDATE(), 'Đang chờ'),
(2, 2, 'Kiểm tra hồ cá trong ngày.', GETDATE(), 'Gửi');
