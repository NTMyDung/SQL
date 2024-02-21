USE QUANLYGIAOVU
--II
--1. Tăng hệ số lương thêm 0.2 cho những giáo viên là trưởng khoa.--
UPDATE GIAOVIEN
SET HESO = HESO*1.2
WHERE MAGV IN(SELECT TRGKHOA FROM KHOA)

--2. Cập nhật giá trị điểm trung bình tất cả các môn học (DIEMTB) của mỗi học viên (tất cả các môn học đều có hệ số 1 và nếu học viên thi một môn nhiều lần, chỉ lấy điểm của lần thi sau cùng).
UPDATE HOCVIEN
SET DIEMTB=(SELECT AVG(DIEM) FROM KETQUATHI
			WHERE LANTHI=(SELECT MAX(LANTHI) FROM KETQUATHI KQ WHERE MAHV=KETQUATHI.MAHV GROUP BY MAHV)
			GROUP BY MAHV HAVING MAHV= HOCVIEN.MAHV)

--3. Cập nhật giá trị cho cột GHICHU là “Cam thi” đối với trường hợp: học viên có một môn bất kỳ thi lần thứ 3 dưới 5 điểm.
UPDATE HOCVIEN 
SET GHICHU= 'Cam thi'
WHERE MAHV IN(SELECT MAHV FROM KETQUATHI WHERE LANTHI=3 AND DIEM<5)

--4. Cập nhật giá trị cho cột XEPLOAI trong quan hệ HOCVIEN như sau:
-- Nếu DIEMTB >= 9 thì XEPLOAI = ”XS”
-- Nếu 8 <= DIEMTB < 9 thì XEPLOAI = “G”
-- Nếu 6.5 <= DIEMTB < 8 thì XEPLOAI = “K”
-- Nếu 5 <= DIEMTB < 6.5 thì XEPLOAI = “TB” 
-- Nếu DIEMTB < 5 thì XEPLOAI = ”Y” 

UPDATE HOCVIEN
SET XEPLOAI =
(
	CASE 
		WHEN DIEMTB >= 9 THEN 'XS'
		WHEN DIEMTB >= 8 AND DIEMTB < 9 THEN 'G'
		WHEN DIEMTB >= 6.5 AND DIEMTB < 8 THEN 'K'
		WHEN DIEMTB >= 5 AND DIEMTB < 6.5 THEN 'TB'
		WHEN DIEMTB < 5 THEN 'Y'
	END
)

--III.
--6. Tìm tên những môn học mà giáo viên có tên “Tran Tam Thanh” dạy trong học kỳ 1 năm 2006.
SELECT DISTINCT TENMH 
FROM MONHOC 
WHERE MAMH IN(SELECT MAMH 
				FROM GIANGDAY GD JOIN GIAOVIEN GV ON GD.MAGV=GV.MAGV 
				WHERE GV.HOTEN='Tran Tam Thanh' AND HOCKY=1 AND NAM='2006')

--7. Tìm những môn học (mã môn học, tên môn học) mà giáo viên chủ nhiệm lớp “K11” dạy trong học kỳ 1 năm 2006.
SELECT DISTINCT MAMH, TENMH
FROM MONHOC
WHERE MAMH IN(SELECT MAMH FROM GIANGDAY GD
				JOIN LOP L ON GD.MAGV=L.MAGVCN
				WHERE GD.MALOP ='K11' AND HOCKY='1' AND NAM='2006')

--8. Tìm họ tên lớp trưởng của các lớp mà giáo viên có tên “Nguyen To Lan” dạy môn “Co So Du Lieu”.
SELECT DISTINCT HO, TEN 
FROM HOCVIEN HV JOIN LOP L ON HV.MAHV=L.TRGLOP
WHERE L.MALOP IN ( SELECT MALOP FROM GIANGDAY GD 
					JOIN GIAOVIEN GV ON GD.MAGV= GV.MAGV 
					JOIN  MONHOC MH ON GD.MAMH= MH.MAMH
					WHERE HOTEN='Nguyen To Lan' AND TENMH='Co So Du Lieu'
					)

--9. In ra danh sách những môn học (mã môn học, tên môn học) phải học liền trước môn “Co So Du Lieu”.
SELECT MHTRUOC.MAMH, MHTRUOC.TENMH
FROM MONHOC, MONHOC AS MHTRUOC, DIEUKIEN
WHERE
	MONHOC.MAMH = DIEUKIEN.MAMH
	AND MHTRUOC.MAMH = DIEUKIEN.MAMH_TRUOC
	AND MONHOC.TENMH = 'Co So Du Lieu'
				
--10. Môn “Cau Truc Roi Rac” là môn bắt buộc phải học liền trước những môn học (mã môn học, tên môn học) nào.
SELECT MHSAU.MAMH, MHSAU.TENMH
FROM MONHOC, MONHOC AS MHSAU, DIEUKIEN
WHERE
	MHSAU.MAMH = DIEUKIEN.MAMH
	AND MONHOC.MAMH = DIEUKIEN.MAMH_TRUOC
	AND MONHOC.TENMH = 'Cau Truc Roi Rac'

--11. Tìm họ tên giáo viên dạy môn CTRR cho cả hai lớp “K11” và “K12” trong cùng học kỳ 1 năm 2006.
SELECT HOTEN
FROM GIAOVIEN GV, GIANGDAY GD
WHERE GD.MAGV= GV.MAGV AND MAMH='CTRR' AND MALOP='K11' AND HOCKY='1' AND NAM='2006'
INTERSECT
SELECT HOTEN
FROM GIAOVIEN GV, GIANGDAY GD
WHERE GD.MAGV= GV.MAGV AND MAMH='CTRR' AND MALOP='K12' AND HOCKY='1' AND NAM='2006'

--12. Tìm những học viên (mã học viên, họ tên) thi không đạt môn CSDL ở lần thi thứ 1 nhưng chưa thi lại môn này.
SELECT MAHV, HO, TEN
FROM HOCVIEN
WHERE MAHV IN( SELECT MAHV FROM KETQUATHI 
				WHERE MAMH='CSDL' AND LANTHI='1' AND KQUA='Khong Dat'
				EXCEPT
					SELECT MAHV FROM KETQUATHI 
					WHERE MAMH='CSDL' AND LANTHI>1)

--13. Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào.
SELECT MAGV, HOTEN
FROM GIAOVIEN
WHERE MAGV NOT IN (SELECT MAGV FROM GIANGDAY)

--14.	Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào thuộc khoa giáo viên đó phụ trách.
SELECT MAGV, HOTEN
FROM GIAOVIEN 
EXCEPT
SELECT GD.MAGV, HOTEN FROM GIANGDAY GD
	JOIN MONHOC MH ON GD.MAMH=MH.MAMH
	JOIN GIAOVIEN GV ON GD.MAGV= GV.MAGV
WHERE MH.MAKHOA=GV.MAKHOA
--(Bao gồm cả những giáo viên không được phân công giảng dạy lớp nào)

--15. Tìm họ tên các học viên thuộc lớp “K11” thi một môn bất kỳ quá 3 lần vẫn “Khong dat” hoặc thi lần thứ 2 môn CTRR được 5 điểm.
SELECT HO, TEN
FROM HOCVIEN HV
WHERE MAHV IN( SELECT DISTINCT MAHV FROM KETQUATHI
				WHERE (MALOP='K11' AND LANTHI>=3 AND KQUA='Khong Dat') OR ( MALOP='K11' AND LANTHI=2 AND MAMH='CTRR' AND DIEM=5))

-- 16. Tìm họ tên giáo viên dạy môn CTRR cho ít nhất hai lớp trong cùng một học kỳ của một năm học.
SELECT HOTEN
FROM GIAOVIEN
WHERE MAGV IN( SELECT MAGV FROM GIANGDAY
				WHERE MAMH='CTRR' GROUP BY MAGV, HOCKY, NAM HAVING COUNT(MALOP)>=2)

-- 17. Danh sách học viên và điểm thi môn CSDL (chỉ lấy điểm của lần thi sau cùng).
SELECT HV.*,  DIEM AS DIEMTHISAUCUNG
FROM HOCVIEN HV
	 JOIN KETQUATHI KQ ON HV.MAHV= KQ.MAHV
WHERE MAMH='CSDL' AND LANTHI =(SELECT MAX(LANTHI) FROM KETQUATHI K
								WHERE MAMH='CSDL' AND K.MAHV= HV.MAHV
								GROUP BY K.MAHV)
ORDER BY TEN ASC, HO ASC

-- 18. Danh sách học viên và điểm thi môn “Co So Du Lieu” (chỉ lấy điểm cao nhất của các lần thi).
SELECT HV.*, DIEM AS DIEMTHICSDLCAONHAT
FROM HOCVIEN HV
	 JOIN KETQUATHI KQ ON HV.MAHV= KQ.MAHV
	 JOIN MONHOC MH ON KQ.MAMH= MH.MAMH
WHERE TENMH='Co So Du Lieu' AND DIEM =(SELECT MAX(DIEM) FROM KETQUATHI K, MONHOC M
							WHERE K.MAMH=M.MAMH AND TENMH='Co So Du Lieu' AND MAHV=HV.MAHV
							GROUP BY MAHV)
				


