--Câu 1. Tạo quan hệ và khai báo tất cả các ràng buộc khóa chính, khóa ngoại. Thêm vào 3 thuộc tính GHICHU, DIEMTB, XEPLOAI cho quan hệ HOCVIEN.--
CREATE TABLE HOCVIEN(
	MAHV char(5),
	HO varchar(40),
	TEN varchar(10),
	NGSINH smalldatetime,
	GIOITINH varchar(3),
	NOISINH varchar(40),
	MALOP char(3),
	CONSTRAINT PK_HV PRIMARY KEY (MAHV)
)
CREATE TABLE LOP(
	MALOP char(3),
	TENLOP varchar(40),
	TRGLOP char(5),
	SISO tinyint,
	MAGVCN char(4),
	CONSTRAINT PK_LOP PRIMARY KEY (MALOP)
)
CREATE TABLE KHOA(
	MAKHOA varchar(4),
	TENKHOA varchar(40),
	NGTLAP smalldatetime,
	TRGKHOA char(4),
	CONSTRAINT PK_KHOA PRIMARY KEY (MAKHOA)
)
CREATE TABLE MONHOC(
	MAMH varchar(10),
	TENMH varchar(40),
	TCLT tinyint,
	TCTH tinyint,
	MAKHOA varchar(4),
	CONSTRAINT PK_MH PRIMARY KEY (MAMH)
)
CREATE TABLE DIEUKIEN(
	MAMH  varchar(10),
	MAMH_TRUOC varchar(10),
	CONSTRAINT PK_DK PRIMARY KEY(MAMH, MAMH_TRUOC)
)
CREATE TABLE GIAOVIEN(
	MAGV char(4),
	HOTEN varchar(40),
	HOCVI varchar(10),
	HOCHAM varchar(10),
	GIOITINH varchar(3),
	NGSINH smalldatetime,
	NGVL smalldatetime,
	HESO numeric (4,2),
	MUCLUONG money,
	MAKHOA varchar(4),
	CONSTRAINT PK_GV PRIMARY KEY (MAGV)
)
CREATE TABLE GIANGDAY(
	MALOP char(3),
	MAMH varchar(10),
	MAGV char(4),
	HOCKY tinyint,
	NAM smallint,
	TUNGAY smalldatetime,
	DNENGAY smalldatetime,
	CONSTRAINT PK_GD PRIMARY KEY(MALOP, MAMH)
)
CREATE TABLE KETQUATHI(
	MAHV char(5),
	MAMH varchar(10),
	LANTHI tinyint,
	NGTHI smalldatetime,
	DIEM numeric(4,2),
	KQUA varchar(10),
	CONSTRAINT PK_KQT PRIMARY KEY (MAHV, MAMH, LANTHI)
)
ALTER TABLE HOCVIEN
ADD GHICHU nvarchar(50), DIEMTB numeric(4,2), XEPLOAI varchar(10)

--Câu 2. Mã học viên là một chuỗi 5 ký tự, 3 ký tự đầu là mã lớp, 2 ký tự cuối cùng là số thứ tự học viên trong lớp. VD: “K1101”--
CREATE TRIGGER TRG_MAHV 
ON HOCVIEN
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @SISO INT, @MAHV VARCHAR(5), @MALOP VARCHAR(3)
	SELECT @MAHV=MAHV , @MALOP = MALOP FROM INSERTED
	SELECT @SISO=SISO FROM dbo.LOP WHERE LOP.MALOP= @MALOP
	IF LEFT(@MAHV,3) <> @MALOP
	BEGIN 
		PRINT ('3 KI TU DAU CUA MAHV PHAI LA MA LOP')
		ROLLBACK TRANSACTION
	END
	ELSE IF CAST(RIGHT(@MAHV,2) AS INT) NOT BETWEEN 1 AND @SISO
	BEGIN 
		PRINT ('2 KI TU CUOI CUA MAHV PHAI SO THU TU HOC VIEN TRONG LOP')
		ROLLBACK TRANSACTION
	END
END 
GO
--Câu 3. Thuộc tính GIOITINH chỉ có giá trị là “Nam” hoặc “Nu”.--
ALTER TABLE HOCVIEN 
ADD CHECK (GIOITINH IN ('Nam', 'Nu'))
ALTER TABLE GIAOVIEN 
ADD CHECK (GIOITINH IN('Nam', 'Nu'))

--Câu 4. Điểm số của một lần thi có giá trị từ 0 đến 10 và cần lưu đến 2 số lẽ (VD: 6.22).--
ALTER TABLE KETQUATHI
ADD CHECK( DIEM BETWEEN 0 AND 10 
			AND RIGHT (CAST(DIEM AS VARCHAR),3) LIKE '.__')

--Câu 5. Kết quả thi là “Dat” nếu điểm từ 5 đến 10  và “Khong dat” nếu điểm nhỏ hơn 5.--
ALTER TABLE KETQUATHI 
ADD CHECK ( (KQUA = 'Dat' AND DIEM BETWEEN 5 AND 10)
		 OR (KQUA = 'Khong dat' AND DIEM<5))

--Câu 6. Học viên thi một môn tối đa 3 lần.--
ALTER TABLE KETQUATHI
ADD CHECK (LANTHI<=3)

--Câu 7. Học kỳ chỉ có giá trị từ 1 đến 3.--
ALTER TABLE GIANGDAY
ADD CHECK ( HOCKY<=3 AND HOCKY>=1)

--Câu 8. Học vị của giáo viên chỉ có thể là “CN”, “KS”, “Ths”, ”TS”, ”PTS”.--
ALTER TABLE GIAOVIEN
ADD CHECK ( HOCVI IN('CN','KS', 'Ths', 'TS', 'PTS'))



