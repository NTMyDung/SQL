USE QUANLYGIAOVU
--III/
-- 19. Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất.
SELECT TOP 1 WITH TIES MAKHOA,TENKHOA, NGTLAP AS NGTLAPSOMNHAT 
FROM KHOA ORDER BY NGTLAP ASC

--20. Có bao nhiêu giáo viên có học hàm là “GS” hoặc “PGS”.
SELECT HOCHAM, COUNT (MAGV) AS SOLUONG 
FROM GIAOVIEN 
WHERE HOCHAM='GS' OR HOCHAM='PGS' 
GROUP BY HOCHAM

--21. Thống kê có bao nhiêu giáo viên có học vị là “CN”, “KS”, “Ths”, “TS”, “PTS” trong mỗi khoa.
SELECT MAKHOA, HOCVI, COUNT(*) AS SOLUONGGV
FROM GIAOVIEN
GROUP BY MAKHOA, HOCVI
ORDER BY MAKHOA

--22. Mỗi môn học thống kê số lượng học viên theo kết quả (đạt và không đạt).
SELECT MAMH, KQUA, COUNT (*) AS SOLUONGHV
FROM KETQUATHI
GROUP BY MAMH, KQUA
ORDER BY MAMH

--23. Tìm giáo viên (mã giáo viên, họ tên) là giáo viên chủ nhiệm của một lớp, đồng thời dạy cho lớp đó ít nhất một môn học.
SELECT DISTINCT GD.MAGV, HOTEN FROM GIANGDAY GD, GIAOVIEN GV, LOP L
WHERE GD.MAGV=L.MAGVCN AND GD.MAGV=GV.MAGV AND GD.MALOP=L.MALOP

--24. Tìm họ tên lớp trưởng của lớp có sỉ số cao nhất.
SELECT TOP 1 WITH TIES HO, TEN FROM HOCVIEN HV, LOP L
WHERE HV.MAHV=L.TRGLOP ORDER BY SISO DESC

--25. * Tìm họ tên những LOPTRG thi không đạt quá 3 môn (mỗi môn đều thi không đạt ở tất cả các lần thi).
SELECT  HO, TEN 
FROM HOCVIEN HV, KETQUATHI KQ, LOP L
WHERE KQ.MAHV=L.TRGLOP AND KQ.MAHV=HV.MAHV AND KQUA='Khong Dat' 
	AND LANTHI=(SELECT MAX(LANTHI) FROM KETQUATHI K WHERE K.MAHV=KQ.MAHV AND K.MAMH=KQ.MAMH )
GROUP BY TRGLOP, HO, TEN
HAVING COUNT(MAMH)>=3
-- mỗi môn đều thi không đạt ở tất cả các lần thi -> mỗi môn ở lần thi cuối cùng (MAX(LANTHI)) là không đạt

--26. Tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9, 10 nhiều nhất.
SELECT TOP 1 WITH TIES HV.MAHV, HO, TEN, COUNT(DISTINCT MAMH) AS SOMONDAT9VA10
FROM HOCVIEN HV, KETQUATHI KQ
WHERE HV.MAHV=KQ.MAHV AND (DIEM BETWEEN 9 AND 10) 
GROUP BY HV.MAHV, HO, TEN
ORDER BY COUNT(DISTINCT MAMH) DESC

--27. Trong từng lớp, tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9, 10 nhiều nhất.
SELECT HV.MALOP, HV.MAHV, HO, TEN, COUNT(DISTINCT MAMH) AS SOMONDAT9VA10
FROM HOCVIEN HV, KETQUATHI KQ
WHERE KQ.MAHV=HV.MAHV AND (DIEM BETWEEN 9 AND 10)
	AND KQ.MAHV IN(SELECT TOP 1 WITH TIES K.MAHV FROM KETQUATHI K, HOCVIEN H 
				WHERE K.MAHV=H.MAHV AND (DIEM BETWEEN 9 AND 10) AND H.MALOP=HV.MALOP
				GROUP BY K.MAHV ORDER BY COUNT(DISTINCT MAMH) DESC)
GROUP BY HV.MALOP, HV.MAHV, HO, TEN

--28. Trong từng học kỳ của từng năm, mỗi giáo viên phân công dạy bao nhiêu môn học, bao nhiêu lớp.
SELECT MAGV, HOCKY, NAM, COUNT(DISTINCT MAMH) AS SOMH, COUNT(DISTINCT MALOP) AS SOLOP
FROM GIANGDAY 
GROUP BY MAGV, HOCKY, NAM

--29. Trong từng học kỳ của từng năm, tìm giáo viên (mã giáo viên, họ tên) giảng dạy nhiều nhất.
SELECT GIAOVIEN.MAGV, HOTEN, HOCKY, NAM
FROM GIAOVIEN,
(
	SELECT 
		HOCKY, NAM, MAGV, RANK() OVER (PARTITION BY HOCKY, NAM ORDER BY COUNT(*) DESC) AS XEPHANG
	FROM GIANGDAY
	GROUP BY HOCKY, NAM, MAGV
) AS A
WHERE
	A.MAGV = GIAOVIEN.MAGV
	AND XEPHANG = 1
ORDER BY
	NAM, HOCKY

--30. Tìm môn học (mã môn học, tên môn học) có nhiều học viên thi không đạt (ở lần thi thứ 1) nhất.
SELECT TOP 1 WITH TIES M.MAMH, TENMH
FROM MONHOC M, KETQUATHI K 
WHERE M.MAMH = K.MAMH AND LANTHI=1 AND KQUA='Khong Dat'
GROUP BY M.MAMH, TENMH
ORDER BY COUNT (*) DESC

--31. Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi thứ 1).
SELECT DISTINCT H.MAHV, HO, TEN
FROM HOCVIEN H, KETQUATHI K
WHERE H.MAHV=K.MAHV
AND NOT EXISTS(
	SELECT * FROM KETQUATHI 
	WHERE MAHV=H.MAHV AND LANTHI='1' AND KQUA='Khong Dat'
)

--32.* Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi sau cùng).
SELECT DISTINCT H.MAHV, HO, TEN
FROM HOCVIEN H, KETQUATHI K
WHERE H.MAHV=K.MAHV
AND NOT EXISTS(
	SELECT * FROM KETQUATHI KQ
	WHERE KQ.MAHV=H.MAHV AND LANTHI= (SELECT MAX(LANTHI) FROM KETQUATHI KQT WHERE KQT.MAHV= KQ.MAHV GROUP BY MAHV) 
	AND KQUA='Khong Dat'
)
--33.* Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn và đều đạt (chỉ xét lần thi thứ 1).
SELECT H.MAHV, HO, TEN
FROM HOCVIEN H, KETQUATHI K
WHERE H.MAHV= K.MAHV AND NOT EXISTS (SELECT * FROM KETQUATHI K 
										WHERE MAHV=H.MAHV AND LANTHI=1 AND KQUA='Khong Dat')
GROUP BY H.MAHV, HO, TEN
HAVING COUNT(DISTINCT MAMH)=(SELECT COUNT(MAMH) FROM MONHOC)

--34.* Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn và đều đạt (chỉ xét lần thi sau cùng).
SELECT DISTINCT H.MAHV, HO, TEN
FROM HOCVIEN H, KETQUATHI K
WHERE H.MAHV=K.MAHV
AND NOT EXISTS(
	SELECT * FROM KETQUATHI KQ
	WHERE KQ.MAHV=H.MAHV AND LANTHI= (SELECT MAX(LANTHI) FROM KETQUATHI KQT WHERE KQT.MAHV= KQ.MAHV GROUP BY MAHV) 
	AND KQUA='Khong Dat'
)
GROUP BY H.MAHV, HO, TEN
HAVING COUNT(DISTINCT MAMH)=(SELECT COUNT(MAMH) FROM MONHOC)

--35.** Tìm học viên (mã học viên, họ tên) có điểm thi cao nhất trong từng môn (lấy điểm ở lần thi sau cùng).
SELECT MAMH, HV.MAHV, HO, TEN
FROM HOCVIEN HV, KETQUATHI KQ
WHERE HV.MAHV=KQ.MAHV AND DIEM IN(SELECT MAX(DIEM) FROM KETQUATHI K 
									WHERE K.MAMH=MAMH AND LANTHI=(SELECT MAX(LANTHI) FROM KETQUATHI KQT 
																	WHERE KQT.MAHV=K.MAHV AND KQT.MAMH=K.MAMH
																	GROUP BY KQT.MAHV)
									GROUP BY MAMH)
GROUP BY MAMH, HV.MAHV, HO, TEN
ORDER BY MAMH ASC
