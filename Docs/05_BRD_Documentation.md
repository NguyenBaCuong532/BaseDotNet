# 05. BRD Documentation (Business Requirements Document)

## 📋 TỔNG QUAN

Tài liệu này mô tả các **Yêu Cầu Nghiệp Vụ (Business Requirements)** và **Nghiệp Vụ (Business Processes)** của hệ thống **UNI Resident API** - Hệ thống quản lý căn hộ thông minh.

### Mục Đích Hệ Thống

Hệ thống **UNI Resident API** được thiết kế để quản lý toàn diện các hoạt động của một khu căn hộ thông minh, bao gồm:

- Quản lý thông tin căn hộ, cư dân
- Quản lý thẻ ra vào (thẻ cư dân, thẻ xe, thẻ khách)
- Quản lý phí dịch vụ và thanh toán
- Quản lý yêu cầu và phản ánh từ cư dân
- Quản lý thông báo đa kênh (Push, SMS, Email)
- Quản lý thang máy
- Quản lý báo cáo và phân tích

---

## 🎯 BUSINESS OBJECTIVES

### Mục Tiêu Nghiệp Vụ

1. **Quản Lý Hiệu Quả**: Quản lý tập trung thông tin căn hộ, cư dân, và các dịch vụ
2. **Tự Động Hóa**: Tự động hóa các quy trình nghiệp vụ, giảm thiểu thao tác thủ công
3. **Trải Nghiệm Người Dùng**: Cung cấp trải nghiệm tốt cho cư dân và quản lý
4. **Tích Hợp Đa Kênh**: Tích hợp thông báo qua nhiều kênh (App, SMS, Email)
5. **Báo Cáo & Phân Tích**: Cung cấp báo cáo và phân tích dữ liệu hỗ trợ quyết định

---

## 📦 NGHIỆP VỤ CHÍNH (BUSINESS PROCESSES)

### 1. 📋 NGHIỆP VỤ QUẢN LÝ CĂN HỘ (APARTMENT MANAGEMENT)

#### 1.1 Quy Trình Đăng Ký Căn Hộ Mới

**Mô Tả**: Quy trình đăng ký và thiết lập thông tin cho căn hộ mới

**Actors**: 
- Quản lý tòa nhà (Building Manager)
- Nhân viên quản lý (Staff)

**Pre-conditions**:
- Dự án đã được tạo trong hệ thống
- Tòa nhà đã được thiết lập

**Business Rules**:
- RoomCode phải unique trong một project
- RoomCode format: `{BuildingCd}-{FloorNo}-{RoomNo}` (ví dụ: BLD01-05-A101)
- Mỗi căn hộ chỉ có một chủ hộ
- Ngày nhận căn hộ (ReceiveDt) không được là quá khứ khi tạo mới

**Process Flow**:
```
1. Nhập thông tin căn hộ cơ bản
   ├─→ RoomCode
   ├─→ projectCd
   ├─→ buildingCd
   ├─→ FloorNo
   ├─→ ApartmentType
   └─→ par_residence_type_oid

2. Thiết lập trạng thái căn hộ
   ├─→ IsReceived (Đã nhận chưa)
   ├─→ ReceiveDt (Ngày nhận)
   ├─→ IsRent (Cho thuê)
   ├─→ IsFree (Miễn phí)
   └─→ FeeStart (Ngày bắt đầu tính phí)

3. Validation
   ├─→ Check RoomCode uniqueness
   ├─→ Check ProjectCd exists
   ├─→ Validate business rules
   └─→ Calculate initial balance

4. Lưu thông tin
   ├─→ Insert into MAS_Apartments
   ├─→ Create related records
   └─→ Return result
```

**Post-conditions**:
- Căn hộ đã được tạo trong hệ thống
- Sẵn sàng để gán cư dân

---

#### 1.2 Quy Trình Thêm Thành Viên Căn Hộ

**Mô Tả**: Thêm thành viên vào căn hộ đã có chủ hộ

**Actors**: 
- Quản lý tòa nhà
- Chủ hộ

**Business Rules**:
- Mỗi căn hộ phải có ít nhất một chủ hộ (IsHost = true)
- Không thể có nhiều chủ hộ cùng lúc
- Thành viên phải có thông tin cá nhân hợp lệ (CMT/CCCD/Passport)
- Thành viên có thể là quan hệ (RelationId): Vợ/Chồng, Con, Bố/Mẹ, Khác

**Process Flow**:
```
1. Chọn căn hộ
   └─→ ApartmentId

2. Nhập thông tin thành viên
   ├─→ FullName, FirstName, LastName
   ├─→ Phone, Email
   ├─→ Pass_No (CMT/CCCD/Passport)
   ├─→ Birthday
   ├─→ RelationId (Quan hệ với chủ hộ)
   └─→ IsHost (Có phải chủ hộ không)

3. Validation
   ├─→ Check ApartmentId exists
   ├─→ Check IsHost conflict (chỉ 1 chủ hộ)
   ├─→ Validate Pass_No uniqueness
   └─→ Check business rules

4. Lưu thông tin
   ├─→ Insert/Update MAS_Customers
   ├─→ Insert into MAS_Apartment_Member
   └─→ Update ApartmentId cho customer
```

---

#### 1.3 Quy Trình Đổi Mã Căn Hộ (Change Room Code)

**Mô Tả**: Thay đổi mã phòng cho căn hộ đã có

**Business Rules**:
- RoomCode mới phải unique
- Không thể đổi nếu căn hộ đã có giao dịch thanh toán
- Phải có lý do rõ ràng cho việc đổi mã
- Cần approval từ manager level

**Process Flow**:
```
1. Chọn căn hộ cần đổi mã
   └─→ RoomCode hiện tại

2. Nhập thông tin đổi mã
   ├─→ RoomCode mới
   ├─→ buildingCd mới (nếu cần)
   ├─→ Reason (Lý do đổi)
   └─→ EffectiveDate (Ngày hiệu lực)

3. Validation
   ├─→ Check RoomCode mới unique
   ├─→ Check có giao dịch thanh toán chưa
   ├─→ Validate buildingCd exists
   └─→ Check permissions

4. Approval Process
   ├─→ Manager approval required
   └─→ Audit log

5. Update
   ├─→ Update MAS_Apartments
   ├─→ Update related records
   └─→ Create history record
```

---

#### 1.4 Quy Trình Import Căn Hộ Từ Excel

**Mô Tả**: Import hàng loạt căn hộ từ file Excel

**Business Rules**:
- File format: .xlsx only
- Template phải theo đúng format
- Validation từng row trước khi insert
- Có thể preview và xác nhận trước khi lưu

**Process Flow**:
```
1. Upload Excel File
   ├─→ Validate file format (.xlsx)
   ├─→ Validate file size
   └─→ Read file với FlexCel

2. Parse Data
   ├─→ Read từ row 5 trở đi (header ở row 1-4)
   ├─→ Map columns to ApartmentImportItem
   └─→ Filter empty rows

3. Validation (Row by Row)
   ├─→ Required fields check
   ├─→ Data format validation
   ├─→ Business rules validation
   └─→ Check duplicates in file

4. Preview & Confirm
   ├─→ Return ImportListPage với:
   │   ├─→ Valid records (có thể import)
   │   ├─→ Error records (cần sửa)
   │   └─→ Summary (tổng số, số lỗi)
   │
   └─→ User review và confirm

5. Execute Import (sau khi confirm)
   ├─→ Insert valid records
   ├─→ Create import history
   ├─→ Upload file to storage
   └─→ Return result
```

---

### 2. 🎫 NGHIỆP VỤ QUẢN LÝ THẺ (CARD MANAGEMENT)

#### 2.1 Quy Trình Cấp Thẻ Cư Dân

**Mô Tả**: Cấp thẻ ra vào cho cư dân căn hộ

**Actors**: 
- Quản lý tòa nhà
- Nhân viên quản lý

**Business Rules**:
- Mỗi cư dân chỉ được cấp một thẻ chính
- Thẻ phải gắn với căn hộ (ApartmentId)
- Thẻ có thể là thẻ VIP hoặc thẻ thường
- Thẻ có ngày phát hành và ngày hết hạn
- Thẻ có thể bị khóa/mở khóa

**Card Types**:
- **Thẻ Cư Dân (Resident Card)**: Thẻ chính của cư dân
- **Thẻ Khách (Guest Card)**: Thẻ tạm cho khách
- **Thẻ Ngày (Daily Card)**: Thẻ sử dụng theo ngày
- **Thẻ Nội Bộ (Internal Card)**: Thẻ cho nhân viên

**Process Flow**:
```
1. Chọn căn hộ
   └─→ ApartmentId

2. Chọn cư dân
   └─→ CustId (hoặc tạo mới)

3. Nhập thông tin thẻ
   ├─→ CardCd (Mã thẻ - có thể tự động generate)
   ├─→ CardTypeId (Loại thẻ)
   ├─→ IssueDate (Ngày phát hành)
   ├─→ ExpireDate (Ngày hết hạn)
   ├─→ IsVip (VIP card)
   ├─→ CardName (Tên thẻ)
   └─→ RequestId (Nếu có yêu cầu)

4. Validation
   ├─→ Check CardCd unique (nếu tự nhập)
   ├─→ Check ExpireDate > IssueDate
   ├─→ Check customer belongs to apartment
   └─→ Validate business rules

5. Lưu thông tin
   ├─→ Insert into MAS_Cards
   ├─→ Link với ApartmentId
   ├─→ Link với CustId
   └─→ Update card status
```

**Card Status Flow**:
```
Thẻ Mới (Card_St = 0)
  ↓
Đang Sử Dụng (Card_St = 1)
  ↓
[Khóa Tạm] (Card_St = 2)
  ↓
[Mở Khóa] (Card_St = 1)
  ↓
Đã Đóng (Card_St = 3)
```

---

#### 2.2 Quy Trình Cấp Thẻ Xe

**Mô Tả**: Cấp thẻ gửi xe cho cư dân

**Business Rules**:
- Một căn hộ có thể có nhiều thẻ xe
- Thẻ xe phải có biển số xe (VehicleNo)
- Thẻ xe có thể là tháng (monthly) hoặc ngày (daily)
- Thẻ xe có StartTime và EndTime
- Phải có file đính kèm: CMT/CCCD, Biển số xe, Đăng ký xe

**Vehicle Card Types**:
- **Xe Cư Dân (Resident Vehicle)**: Xe của cư dân căn hộ
- **Xe Khách (Guest Vehicle)**: Xe tạm của khách
- **Xe Nội Bộ (Internal Vehicle)**: Xe nhân viên

**Process Flow**:
```
1. Chọn căn hộ
   └─→ ApartmentId

2. Chọn/thêm thẻ cơ bản
   └─→ CardId (từ MAS_Cards)

3. Nhập thông tin xe
   ├─→ VehicleNo (Biển số xe)
   ├─→ VehicleTypeId (Loại xe: Xe máy, Ô tô)
   ├─→ VehicleName (Tên xe)
   ├─→ VehicleColor (Màu xe)
   ├─→ monthlyType (Loại tháng: Tháng cố định, Tháng linh hoạt)
   └─→ StartTime, EndTime

4. Upload Documents
   ├─→ IdCardAttach (CMT/CCCD)
   ├─→ VehicleNoAttach (Biển số xe)
   └─→ VehicleLicenseAttach (Đăng ký xe)

5. Tính Phí
   ├─→ Calculate fee based on:
   │   ├─→ VehicleTypeId
   │   ├─→ monthlyType
   │   ├─→ StartTime, EndTime
   │   └─→ Pricing rules
   └─→ Display fee to user

6. Validation
   ├─→ Check VehicleNo format
   ├─→ Check duplicate vehicle in apartment
   ├─→ Validate documents
   └─→ Check pricing rules

7. Lưu thông tin
   ├─→ Insert into MAS_CardVehicle
   ├─→ Update MAS_Cards (isVehicle = true)
   ├─→ Create fee records
   └─→ Update card status
```

---

#### 2.3 Quy Trình Mở/Khóa Thẻ

**Mô Tả**: Mở khóa hoặc khóa thẻ (tạm thời hoặc vĩnh viễn)

**Business Rules**:
- Chỉ có thể khóa thẻ đang hoạt động (Card_St = 1)
- Khóa tạm có thể mở lại
- Khóa vĩnh viễn cần có lý do rõ ràng
- Phải ghi log mọi thay đổi trạng thái

**Process Flow**:
```
1. Chọn thẻ
   └─→ CardCd hoặc CardVehicleId

2. Chọn hành động
   ├─→ Status = 0: Mở thẻ
   ├─→ Status = 1: Khóa thẻ tạm
   └─→ Status = 2: Khóa thẻ vĩnh viễn

3. Nhập lý do (nếu khóa)
   └─→ Reason

4. Validation
   ├─→ Check current status
   ├─→ Check permissions
   └─→ Validate reason (nếu khóa)

5. Update Status
   ├─→ Update MAS_Cards (Card_St)
   ├─→ Update MAS_CardVehicle (Status, locked_dt)
   ├─→ Log change history
   └─→ Return result
```

---

#### 2.4 Quy Trình Gia Hạn Thẻ Xe

**Mô Tả**: Gia hạn thẻ xe khi hết hạn hoặc sắp hết hạn

**Business Rules**:
- Chỉ gia hạn thẻ đang hoạt động
- Có thể gia hạn theo ngày hoặc theo tháng
- Tính phí dựa trên khoảng thời gian gia hạn
- Cập nhật EndTime sau khi thanh toán

**Process Flow**:
```
1. Chọn thẻ xe
   └─→ CardVehicleId

2. Nhập thông tin gia hạn
   ├─→ StartDate (Ngày bắt đầu mới)
   ├─→ EndDate (Ngày kết thúc mới)
   └─→ monthlyType (Nếu thay đổi)

3. Tính Phí
   ├─→ Calculate fee based on:
   │   ├─→ StartDate, EndDate
   │   ├─→ VehicleTypeId
   │   ├─→ monthlyType
   │   └─→ Current pricing rules
   └─→ Display fee breakdown

4. Xác Nhận & Thanh Toán
   ├─→ User confirm
   ├─→ Process payment
   └─→ Update EndTime

5. Update Records
   ├─→ Update MAS_CardVehicle
   │   ├─→ EndTime
   │   ├─→ lastReceivable
   │   └─→ Status
   ├─→ Create payment record
   └─→ Update apartment balance
```

---

#### 2.5 Quy Trình Trả Thẻ (Card Return)

**Mô Tả**: Xử lý yêu cầu trả thẻ từ cư dân

**Business Rules**:
- Cư dân có thể yêu cầu trả thẻ
- Phải thanh toán đầy đủ các khoản phí trước khi trả thẻ
- Thẻ được trả sẽ không thể sử dụng nữa
- Phải cập nhật trạng thái và lịch sử

**Process Flow**:
```
1. Cư Dân Yêu Cầu Trả Thẻ
   ├─→ CardVehicleId
   └─→ Reason (Lý do)

2. Kiểm Tra Điều Kiện
   ├─→ Check outstanding balance
   ├─→ Check card status
   └─→ Validate business rules

3. Xử Lý Thanh Toán (nếu có nợ)
   ├─→ Display outstanding amount
   ├─→ Process payment
   └─→ Update balance

4. Xác Nhận Trả Thẻ
   ├─→ Manager approval
   ├─→ Update card status:
   │   ├─→ IsClose = true
   │   ├─→ CloseDate = current date
   │   └─→ CloseBy = userId
   ├─→ Update MAS_CardVehicle:
   │   ├─→ card_return_date
   │   └─→ Status
   └─→ Create history record
```

---

### 3. 💰 NGHIỆP VỤ QUẢN LÝ PHÍ DỊCH VỤ (SERVICE FEE MANAGEMENT)

#### 3.1 Quy Trình Tính Phí Dịch Vụ

**Mô Tả**: Tính toán và tạo phí dịch vụ cho căn hộ

**Phí Dịch Vụ Bao Gồm**:
- Phí ở (Service Living): Phí quản lý căn hộ
- Phí điện nước: Tính theo chỉ số công tơ
- Phí gửi xe: Phí thẻ xe hàng tháng
- Phí dịch vụ mở rộng: Internet, TV, bảo trì, v.v.

**Business Rules**:
- Phí ở được tính theo loại căn hộ (par_residence_type_oid)
- Phí điện nước tính theo bậc thang (two-stage rate)
- Phí gửi xe tính theo loại xe và loại tháng
- Phí được tính theo chu kỳ (tháng)
- Có thể áp dụng miễn giảm

**Process Flow**:
```
1. Chọn Căn Hộ
   └─→ ApartmentId

2. Chọn Loại Phí
   ├─→ ServiceLiving (Phí ở)
   ├─→ ElectricWater (Phí điện nước)
   ├─→ Vehicle (Phí gửi xe)
   └─→ Extend (Phí mở rộng)

3. Nhập Chỉ Số/Thông Tin
   ├─→ Electric Index (Chỉ số điện)
   ├─→ Water Index (Chỉ số nước)
   ├─→ Service Period (Kỳ dịch vụ)
   └─→ Extra Services (Dịch vụ mở rộng)

4. Tính Phí
   ├─→ Get pricing rules từ PAR_ServicePrice
   ├─→ Apply calculation rules:
   │   ├─→ Two-stage rate (điện nước)
   │   ├─→ Block uniform rate
   │   └─→ Short stay rule
   ├─→ Apply discounts (nếu có)
   └─→ Calculate total amount

5. Tạo Receivable
   ├─→ Insert into MAS_Service_Receivable
   ├─→ Link to ApartmentId
   ├─→ Set ReceivableDate
   └─→ Update apartment balance
```

---

#### 3.2 Quy Trình Thanh Toán Phí Dịch Vụ

**Mô Tả**: Xử lý thanh toán phí dịch vụ từ cư dân

**Payment Methods**:
- Tiền mặt
- Chuyển khoản ngân hàng
- Ví điện tử
- QR Pay

**Business Rules**:
- Có thể thanh toán một phần hoặc toàn bộ
- Thanh toán có thể áp dụng cho nhiều khoản phí
- Phải tạo biên lai sau khi thanh toán
- Cập nhật số dư căn hộ (CurrBal)

**Process Flow**:
```
1. Chọn Căn Hộ
   └─→ ApartmentId

2. Hiển Thị Công Nợ
   ├─→ Outstanding receivables
   ├─→ Total amount
   └─→ Payment priority (theo cấu hình)

3. Chọn Khoản Thanh Toán
   ├─→ Select receivables to pay
   ├─→ Enter payment amount
   └─→ Select payment method

4. Validation
   ├─→ Check payment amount <= total
   ├─→ Validate payment method
   └─→ Check business rules

5. Process Payment
   ├─→ Create payment transaction
   ├─→ Update MAS_Service_Receivable:
   │   └─→ Paid amount, status
   ├─→ Update MAS_Service_Receipts:
   │   └─→ Create receipt record
   ├─→ Update Apartment balance:
   │   └─→ CurrBal = CurrBal - payment
   └─→ Generate receipt

6. Generate Receipt
   ├─→ Create receipt number
   ├─→ Generate receipt document
   └─→ Send to customer (Email/SMS)
```

---

#### 3.3 Quy Trình Tính Phí Điện Nước

**Mô Tả**: Tính phí điện nước dựa trên chỉ số công tơ

**Business Rules**:
- Tính theo bậc thang (two-stage rate)
- Chỉ số mới phải lớn hơn chỉ số cũ
- Tính theo công thức:
  ```
  Bậc 1: Nếu < Ngưỡng bậc 1 → Giá bậc 1
  Bậc 2: Nếu >= Ngưỡng bậc 1 → Giá bậc 2
  ```
- Có thể áp dụng discount theo loại căn hộ

**Process Flow**:
```
1. Chọn Căn Hộ
   └─→ ApartmentId

2. Nhập Chỉ Số
   ├─→ ElectricIndex (Chỉ số điện mới)
   ├─→ WaterIndex (Chỉ số nước mới)
   ├─→ ReadingDate (Ngày đọc chỉ số)
   └─→ ReadingBy (Người đọc)

3. Lấy Chỉ Số Cũ
   ├─→ Get last ElectricIndex
   ├─→ Get last WaterIndex
   └─→ Calculate consumption:
       ├─→ ElectricUsage = NewIndex - OldIndex
       └─→ WaterUsage = NewIndex - OldIndex

4. Tính Phí
   ├─→ Get pricing from par_electric_detail
   ├─→ Apply two-stage rate:
   │   ├─→ If usage <= threshold → Rate1
   │   └─→ If usage > threshold → Rate2
   ├─→ Calculate Electric Fee
   ├─→ Calculate Water Fee (tương tự)
   └─→ Apply discount (nếu có)

5. Lưu Kết Quả
   ├─→ Insert into MAS_Service_Living_Tracking
   ├─→ Update MAS_Service_Receivable
   └─→ Update apartment balance
```

---

### 4. 🔔 NGHIỆP VỤ YÊU CẦU & PHẢN ÁNH (REQUEST MANAGEMENT)

#### 4.1 Quy Trình Tạo Yêu Cầu

**Mô Tả**: Cư dân tạo yêu cầu dịch vụ hoặc phản ánh

**Request Types**:
- Yêu cầu dịch vụ (Service Request): Sửa chữa, bảo trì, v.v.
- Yêu cầu hỗ trợ (Support Request): Hỗ trợ kỹ thuật
- Phản ánh (Feedback): Phản ánh về chất lượng dịch vụ

**Business Rules**:
- Yêu cầu phải gắn với căn hộ
- Yêu cầu có thể có file đính kèm
- Yêu cầu có thể là ngay lập tức (isNow = true) hoặc hẹn giờ (atTime)
- Yêu cầu có trạng thái: Mới, Đang xử lý, Hoàn thành, Đóng

**Process Flow**:
```
1. Cư Dân Tạo Yêu Cầu
   ├─→ ApartmentId (tự động từ user context)
   ├─→ RequestTypeId (Loại yêu cầu)
   ├─→ Comment (Nội dung yêu cầu)
   ├─→ IsNow (Ngay lập tức hoặc hẹn giờ)
   ├─→ AtTime (Thời gian hẹn - nếu không phải ngay)
   └─→ AttachOid (File đính kèm - optional)

2. Generate Request Key
   ├─→ Auto-generate requestKey
   └─→ Format: REQ{Date}{Sequence}

3. Validation
   ├─→ Check ApartmentId exists
   ├─→ Check RequestTypeId valid
   ├─→ Validate comment length
   └─→ Check file size (nếu có)

4. Create Request
   ├─→ Insert into MAS_Requests
   │   ├─→ requestKey
   │   ├─→ requestDt = current datetime
   │   ├─→ status = 0 (Mới)
   │   └─→ requestUserId = userId
   ├─→ Insert into MAS_Request_Attach (nếu có file)
   └─→ Create notification job

5. Notify Stakeholders
   ├─→ Notify building manager
   ├─→ Notify assigned staff
   └─→ Confirm to resident
```

**Request Status Flow**:
```
Mới (status = 0)
  ↓
[Phân Công] → Đang Xử Lý (status = 1)
  ↓
[Đang Xử Lý] (status = 2)
  ↓
[Hoàn Thành] (status = 3)
  ↓
[Cư Dân Đánh Giá] → Đóng (status = 4)
```

---

#### 4.2 Quy Trình Xử Lý Yêu Cầu

**Mô Tả**: Quản lý quy trình xử lý yêu cầu từ cư dân

**Actors**:
- Building Manager
- Staff (Nhân viên xử lý)
- Resident (Cư dân - đánh giá)

**Business Rules**:
- Yêu cầu phải được phân công cho nhân viên
- Mỗi bước xử lý đều được ghi log
- Có thể đính kèm file trong quá trình xử lý
- Yêu cầu hoàn thành phải có đánh giá từ cư dân

**Process Flow**:
```
1. Phân Công Yêu Cầu (Manager)
   ├─→ RequestId
   ├─→ AssignTo (UserId nhân viên)
   ├─→ Priority (Độ ưu tiên)
   └─→ ExpectedDate (Ngày hoàn thành dự kiến)

2. Nhân Viên Tiếp Nhận
   ├─→ Update status = 1 (Đang xử lý)
   ├─→ Create MAS_Request_Process record
   └─→ Notify resident

3. Xử Lý Yêu Cầu
   ├─→ Staff thực hiện công việc
   ├─→ Update progress:
   │   ├─→ Add process notes
   │   ├─→ Upload attachments
   │   └─→ Update status
   └─→ Communicate with resident (chat)

4. Hoàn Thành
   ├─→ Update status = 3 (Hoàn thành)
   ├─→ Add completion notes
   └─→ Notify resident

5. Đánh Giá (Resident)
   ├─→ Rating (1-5 sao)
   ├─→ Review comment
   └─→ Update status = 4 (Đóng)
```

---

#### 4.3 Quy Trình Phản Ánh

**Mô Tả**: Cư dân phản ánh về chất lượng dịch vụ

**Feedback Types**:
- Phản ánh chất lượng dịch vụ
- Phản ánh về nhân viên
- Phản ánh về cơ sở hạ tầng
- Phản ánh khác

**Business Rules**:
- Phản ánh phải được xử lý trong vòng 24h
- Phản ánh phải có phản hồi từ quản lý
- Có thể đính kèm hình ảnh/chứng cứ

**Process Flow**:
```
1. Cư Dân Gửi Phản Ánh
   ├─→ FeedbackTypeId
   ├─→ Subject (Tiêu đề)
   ├─→ Content (Nội dung)
   ├─→ ApartmentId
   └─→ AttachOid (Hình ảnh - optional)

2. Tạo Feedback Record
   ├─→ Insert into MAS_Feedbacks
   ├─→ status = 0 (Mới)
   └─→ feedbackDt = current datetime

3. Phân Công Xử Lý
   ├─→ Assign to manager
   └─→ Set priority

4. Xử Lý Phản Ánh
   ├─→ Manager review
   ├─→ Add process notes
   ├─→ Update status
   └─→ Notify resident về kết quả
```

---

### 5. 📧 NGHIỆP VỤ THÔNG BÁO (NOTIFICATION MANAGEMENT)

#### 5.1 Quy Trình Gửi Thông Báo

**Mô Tả**: Gửi thông báo đa kênh (Push, SMS, Email) đến cư dân

**Notification Channels**:
- **Push Notification**: Thông báo trên mobile app
- **SMS**: Tin nhắn SMS
- **Email**: Email thông báo

**Business Rules**:
- Có thể gửi đến một hoặc nhiều căn hộ
- Có thể gửi theo dự án, tòa nhà
- Có thể lên lịch gửi (Schedule)
- Có thể có file đính kèm
- Track trạng thái gửi (sent, failed, pending)

**Process Flow**:
```
1. Tạo Thông Báo
   ├─→ Subject (Tiêu đề)
   ├─→ Content_notify (Nội dung push)
   ├─→ Content_sms (Nội dung SMS)
   ├─→ Content_email (Nội dung email)
   ├─→ Content_markdown (Markdown format)
   ├─→ NotiType (Loại thông báo)
   └─→ AttachOid (File đính kèm - optional)

2. Chọn Người Nhận
   ├─→ By ApartmentId (Danh sách căn hộ)
   ├─→ By ProjectCd (Theo dự án)
   ├─→ By BuildingCd (Theo tòa nhà)
   └─→ Manual list (Danh sách thủ công)

3. Chọn Kênh Gửi
   ├─→ Push (is_act_push = true)
   ├─→ SMS (content_sms not empty)
   └─→ Email (content_email not empty)

4. Lên Lịch (Optional)
   └─→ Schedule (Ngày giờ gửi)

5. Create Notification
   ├─→ Insert into NotifyInbox
   ├─→ Insert into NotifyTo (recipients)
   └─→ Insert into NotifyJob (job queue)

6. Background Processing
   ├─→ Process NotifyJob queue
   ├─→ Send Push via FCM
   ├─→ Send SMS via SMS Gateway
   ├─→ Send Email via Email Service
   └─→ Update NotifySent, NotifyJob status
```

---

#### 5.2 Quy Trình Thông Báo Theo Chu Kỳ

**Mô Tả**: Gửi thông báo tự động theo chu kỳ (hàng tháng, hàng tuần)

**Use Cases**:
- Thông báo phí dịch vụ hàng tháng
- Thông báo nhắc nhở thanh toán
- Thông báo bảo trì định kỳ

**Process Flow**:
```
1. Tạo Template Thông Báo
   ├─→ NotifyTemplate
   ├─→ Placeholders: {RoomCode}, {Amount}, {DueDate}
   └─→ Schedule: Monthly, Weekly, Daily

2. Setup Schedule Job
   ├─→ Define schedule time
   ├─→ Define recipients filter
   └─→ Link to template

3. Automated Execution
   ├─→ Job runs at scheduled time
   ├─→ Get recipients from filter
   ├─→ Replace placeholders with data
   ├─→ Create NotifyInbox records
   └─→ Trigger sending
```

---

### 6. 🚗 NGHIỆP VỤ QUẢN LÝ GỬI XE (PARKING MANAGEMENT)

#### 6.1 Quy Trình Đăng Ký Gửi Xe

**Mô Tả**: Đăng ký gửi xe cho cư dân

**Business Rules**:
- Một căn hộ có thể có nhiều xe
- Mỗi xe phải có biển số duy nhất trong dự án
- Phải có giấy tờ hợp lệ (CMT/CCCD, Biển số, Đăng ký)
- Phí gửi xe tính theo loại xe và loại tháng

**Vehicle Types**:
- Xe máy (Motorcycle)
- Ô tô (Car)
- Xe tải (Truck)

**Monthly Types**:
- Tháng cố định: Gửi theo tháng cố định
- Tháng linh hoạt: Tính theo số ngày thực tế

**Process Flow**:
```
1. Cư Dân Đăng Ký
   ├─→ ApartmentId
   ├─→ VehicleNo (Biển số xe)
   ├─→ VehicleTypeId (Loại xe)
   ├─→ VehicleName, VehicleColor
   └─→ Documents (upload)

2. Upload Documents
   ├─→ IdCardAttach (CMT/CCCD)
   ├─→ VehicleNoAttach (Biển số)
   └─→ VehicleLicenseAttach (Đăng ký)

3. Tính Phí
   ├─→ Get pricing từ par_vehicle
   ├─→ Calculate based on:
   │   ├─→ VehicleTypeId
   │   ├─→ monthlyType
   │   └─→ StartDate, EndDate
   └─→ Display fee to user

4. Approval
   ├─→ Manager review documents
   ├─→ Approve or reject
   └─→ Notify resident

5. Cấp Thẻ
   ├─→ Create MAS_CardVehicle
   ├─→ Link với MAS_Cards
   ├─→ Set status = active
   └─→ Generate card
```

---

#### 6.2 Quy Trình Thanh Toán Phí Gửi Xe

**Mô Tả**: Thanh toán phí gửi xe theo kỳ

**Business Rules**:
- Phí gửi xe có thể thanh toán trước hoặc sau
- Có thể thanh toán nhiều kỳ cùng lúc
- Thanh toán cập nhật lastReceivable
- Tự động tính phí kỳ tiếp theo

**Process Flow**:
```
1. Chọn Thẻ Xe
   └─→ CardVehicleId

2. Hiển Thị Công Nợ
   ├─→ Outstanding periods
   ├─→ Total amount
   └─→ Next period amount

3. Chọn Kỳ Thanh Toán
   ├─→ Select periods to pay
   ├─→ Enter payment amount
   └─→ Select payment method

4. Process Payment
   ├─→ Create payment record
   ├─→ Update MAS_CardVehicle:
   │   └─→ lastReceivable = last paid period
   ├─→ Update MAS_Service_Receipts
   └─→ Update apartment balance

5. Generate Receipt
   └─→ Create receipt for payment
```

---

### 7. 🛗 NGHIỆP VỤ QUẢN LÝ THANG MÁY (ELEVATOR MANAGEMENT)

#### 7.1 Quy Trình Quản Lý Thẻ Thang Máy

**Mô Tả**: Quản lý quyền truy cập thang máy cho cư dân

**Business Rules**:
- Mỗi cư dân có thể có thẻ thang máy
- Thẻ thang máy được gán tầng cụ thể
- Có thể giới hạn thời gian sử dụng
- Có thể cấp thẻ tạm cho khách

**Process Flow**:
```
1. Chọn Cư Dân
   └─→ CustId

2. Cấu Hình Thẻ Thang Máy
   ├─→ ElevatorBuildingId (Tòa nhà)
   ├─→ Allowed Floors (Danh sách tầng được phép)
   ├─→ StartTime (Thời gian bắt đầu)
   ├─→ EndTime (Thời gian kết thúc)
   └─→ CardRole (Vai trò: Resident, Guest, Staff)

3. Validation
   ├─→ Check floor exists
   ├─→ Check time range valid
   └─→ Validate permissions

4. Create Elevator Card
   ├─→ Insert into MAS_Elevator_Card
   ├─→ Link to MAS_Elevator_Floor
   ├─→ Link to MAS_Cards
   └─→ Sync to elevator system
```

---

### 8. 📊 NGHIỆP VỤ BÁO CÁO (REPORTING)

#### 8.1 Quy Trình Tạo Báo Cáo

**Mô Tả**: Tạo các báo cáo theo yêu cầu

**Report Types**:
- Báo cáo căn hộ
- Báo cáo phí dịch vụ
- Báo cáo thẻ xe
- Báo cáo yêu cầu
- Báo cáo công nợ

**Business Rules**:
- Báo cáo có thể filter theo nhiều tiêu chí
- Báo cáo có thể export Excel/PDF
- Báo cáo có thể lên lịch tự động

**Process Flow**:
```
1. Chọn Loại Báo Cáo
   └─→ ReportId

2. Nhập Tham Số
   ├─→ ProjectCd
   ├─→ Date Range
   ├─→ Filters
   └─→ Export Format (Excel/PDF)

3. Generate Report
   ├─→ Execute stored procedure
   ├─→ Get data from database
   ├─→ Apply filters
   └─→ Format data

4. Format & Export
   ├─→ Use template Excel/PDF
   ├─→ Fill data with FlexCel
   └─→ Return file stream
```

---

## 📐 BUSINESS RULES TỔNG QUÁT

### Data Validation Rules

#### 1. Apartment Rules
- **BR-001**: RoomCode phải unique trong một project
- **BR-002**: Mỗi căn hộ chỉ có một chủ hộ (IsHost = true)
- **BR-003**: Ngày nhận căn hộ (ReceiveDt) không được là tương lai
- **BR-004**: Không thể xóa căn hộ đã có giao dịch thanh toán

#### 2. Card Rules
- **BR-005**: Mỗi cư dân chỉ có một thẻ chính
- **BR-006**: CardCd phải unique trong hệ thống
- **BR-007**: ExpireDate phải lớn hơn IssueDate
- **BR-008**: Không thể khóa thẻ đã đóng (IsClose = true)

#### 3. Vehicle Card Rules
- **BR-009**: VehicleNo phải unique trong một project
- **BR-010**: Thẻ xe phải có giấy tờ hợp lệ (CMT/CCCD, Biển số, Đăng ký)
- **BR-011**: EndTime phải lớn hơn StartTime
- **BR-012**: Không thể xóa thẻ xe đã có thanh toán

#### 4. Fee Rules
- **BR-013**: Phí dịch vụ tính theo chu kỳ tháng
- **BR-014**: Phí điện nước tính theo bậc thang
- **BR-015**: Phí gửi xe tính theo loại xe và loại tháng
- **BR-016**: Có thể áp dụng miễn giảm phí (IsFree, numFreeMonth)

#### 5. Payment Rules
- **BR-017**: Số tiền thanh toán không được vượt quá công nợ
- **BR-018**: Thanh toán phải tạo biên lai
- **BR-019**: Thanh toán cập nhật số dư căn hộ (CurrBal)
- **BR-020**: Có thể thanh toán nhiều khoản cùng lúc

#### 6. Request Rules
- **BR-021**: Yêu cầu phải gắn với căn hộ
- **BR-022**: Yêu cầu mới phải được phân công trong vòng 24h
- **BR-023**: Yêu cầu hoàn thành phải có đánh giá từ cư dân
- **BR-024**: Không thể xóa yêu cầu đã có quy trình xử lý

---

## 👥 ACTORS & ROLES

### System Actors

| Actor | Mô Tả | Quyền Hạn |
|-------|-------|-----------|
| **Super Admin** | Quản trị hệ thống cao cấp | Toàn quyền hệ thống |
| **Building Manager** | Quản lý tòa nhà | Quản lý căn hộ, phí dịch vụ, yêu cầu |
| **Staff** | Nhân viên quản lý | Xử lý yêu cầu, hỗ trợ cư dân |
| **Resident** | Cư dân | Xem thông tin, tạo yêu cầu, thanh toán |
| **Guest** | Khách | Sử dụng dịch vụ tạm thời |

### Role-Based Access Control

```
Super Admin
  └─→ Full system access

Building Manager
  ├─→ Manage apartments
  ├─→ Manage cards
  ├─→ Manage fees & payments
  ├─→ Process requests
  ├─→ Send notifications
  └─→ View reports

Staff
  ├─→ View apartments
  ├─→ Process requests
  ├─→ View fees
  └─→ Limited editing

Resident
  ├─→ View own apartment info
  ├─→ Create requests
  ├─→ View fees & payments
  ├─→ View notifications
  └─→ Update profile
```

---

## 🔄 BUSINESS WORKFLOWS

### 1. Workflow: Quản Lý Vòng Đời Căn Hộ

```
Tạo Căn Hộ
  ↓
Gán Chủ Hộ
  ↓
Nhận Căn Hộ (ReceiveDt)
  ↓
Bắt Đầu Tính Phí (FeeStart)
  ↓
[Đang Sử Dụng]
  ├─→ Có thể: Đổi mã căn hộ
  ├─→ Có thể: Cho thuê
  ├─→ Có thể: Miễn phí tạm thời
  └─→ Có thể: Đóng căn hộ
  ↓
Đóng Căn Hộ (IsClose = true)
```

### 2. Workflow: Quản Lý Vòng Đời Thẻ

```
Tạo Yêu Cầu Thẻ
  ↓
Phê Duyệt
  ↓
Cấp Thẻ (IssueDate)
  ↓
[Đang Sử Dụng]
  ├─→ Có thể: Khóa tạm
  ├─→ Có thể: Mở khóa
  ├─→ Có thể: Gia hạn (ExpireDate)
  └─→ Có thể: Đóng thẻ
  ↓
Hết Hạn (ExpireDate)
  ├─→ Gia hạn
  └─→ Đóng thẻ
  ↓
Đóng Thẻ (IsClose = true)
```

### 3. Workflow: Quy Trình Xử Lý Yêu Cầu

```
Cư Dân Tạo Yêu Cầu
  ↓
Yêu Cầu Mới (status = 0)
  ↓
Manager Phân Công
  ↓
Đang Xử Lý (status = 1)
  ↓
Nhân Viên Tiếp Nhận
  ↓
Đang Thực Hiện (status = 2)
  ├─→ Có thể: Cập nhật tiến độ
  ├─→ Có thể: Chat với cư dân
  └─→ Có thể: Đính kèm file
  ↓
Hoàn Thành (status = 3)
  ↓
Cư Dân Đánh Giá
  ├─→ Rating (1-5 sao)
  └─→ Review comment
  ↓
Đóng (status = 4)
```

---

## 📊 BUSINESS ENTITIES & RELATIONSHIPS

### Core Entities

```
Project (Dự án)
  └─→ 1:N → Apartment (Căn hộ)
       └─→ 1:N → Customer (Khách hàng)
            └─→ 1:N → Card (Thẻ)
                 └─→ 1:N → CardVehicle (Thẻ xe)

Apartment
  └─→ 1:N → Request (Yêu cầu)
  └─→ 1:N → ServiceReceivable (Phải thu)
       └─→ 1:N → ServiceReceipts (Biên lai)

CardVehicle
  └─→ 1:N → VehiclePayment (Thanh toán)

Request
  └─→ 1:N → RequestProcess (Quy trình xử lý)
  └─→ 1:N → RequestAssign (Phân công)
```

---

## 💼 USE CASES

### UC-001: Quản Lý Thông Tin Căn Hộ

**Actor**: Building Manager

**Main Success Scenario**:
1. Manager đăng nhập hệ thống
2. Truy cập module Quản lý Căn hộ
3. Tìm kiếm căn hộ theo RoomCode/ProjectCd
4. Xem chi tiết căn hộ
5. Cập nhật thông tin căn hộ
6. Lưu thay đổi
7. Hệ thống xác nhận cập nhật thành công

**Alternative Flows**:
- 3a. Không tìm thấy căn hộ → Hiển thị thông báo
- 5a. Validation lỗi → Hiển thị lỗi, yêu cầu sửa

---

### UC-002: Cư Dân Tạo Yêu Cầu

**Actor**: Resident

**Main Success Scenario**:
1. Resident đăng nhập app
2. Chọn menu "Yêu Cầu"
3. Chọn loại yêu cầu
4. Nhập nội dung yêu cầu
5. Đính kèm hình ảnh (nếu cần)
6. Chọn thời gian (ngay lập tức hoặc hẹn giờ)
7. Gửi yêu cầu
8. Hệ thống xác nhận đã nhận yêu cầu

**Business Rules**:
- Yêu cầu tự động gắn với căn hộ của resident
- Yêu cầu tự động có requestKey
- Yêu cầu gửi thông báo đến manager

---

### UC-003: Thanh Toán Phí Dịch Vụ

**Actor**: Resident

**Main Success Scenario**:
1. Resident đăng nhập app
2. Xem danh sách phí dịch vụ
3. Chọn các khoản cần thanh toán
4. Chọn phương thức thanh toán
5. Xác nhận thanh toán
6. Hệ thống xử lý thanh toán
7. Tạo biên lai
8. Gửi biên lai qua Email/SMS

**Alternative Flows**:
- 6a. Thanh toán thất bại → Hiển thị lỗi, yêu cầu thử lại

---

## 🎯 BUSINESS REQUIREMENTS

### Functional Requirements

#### FR-001: Quản Lý Căn Hộ
- **FR-001.1**: Hệ thống phải cho phép tạo, sửa, xóa căn hộ
- **FR-001.2**: Hệ thống phải validate RoomCode unique
- **FR-001.3**: Hệ thống phải hỗ trợ import căn hộ từ Excel
- **FR-001.4**: Hệ thống phải quản lý trạng thái căn hộ (Đã nhận, Cho thuê, Đóng)

#### FR-002: Quản Lý Thẻ
- **FR-002.1**: Hệ thống phải cho phép cấp thẻ cư dân
- **FR-002.2**: Hệ thống phải quản lý thẻ xe với đầy đủ giấy tờ
- **FR-002.3**: Hệ thống phải hỗ trợ mở/khóa thẻ
- **FR-002.4**: Hệ thống phải tính phí gửi xe tự động

#### FR-003: Quản Lý Phí Dịch Vụ
- **FR-003.1**: Hệ thống phải tính phí ở theo loại căn hộ
- **FR-003.2**: Hệ thống phải tính phí điện nước theo bậc thang
- **FR-003.3**: Hệ thống phải hỗ trợ thanh toán đa phương thức
- **FR-003.4**: Hệ thống phải tự động tạo biên lai

#### FR-004: Quản Lý Yêu Cầu
- **FR-004.1**: Hệ thống phải cho phép cư dân tạo yêu cầu
- **FR-004.2**: Hệ thống phải hỗ trợ quy trình xử lý yêu cầu
- **FR-004.3**: Hệ thống phải gửi thông báo khi có yêu cầu mới
- **FR-004.4**: Hệ thống phải hỗ trợ chat trong yêu cầu

#### FR-005: Quản Lý Thông Báo
- **FR-005.1**: Hệ thống phải gửi thông báo đa kênh (Push, SMS, Email)
- **FR-005.2**: Hệ thống phải hỗ trợ lên lịch gửi thông báo
- **FR-005.3**: Hệ thống phải track trạng thái gửi thông báo

### Non-Functional Requirements

#### NFR-001: Performance
- API response time < 2 seconds cho 95% requests
- Support concurrent users: 1000+
- Database query optimization với indexes

#### NFR-002: Security
- JWT token authentication
- HTTPS only trong production
- SQL injection prevention (parameterized queries)
- XSS prevention

#### NFR-003: Availability
- System uptime: 99.5%
- Backup database daily
- Disaster recovery plan

#### NFR-004: Scalability
- Horizontal scaling support
- Stateless API design
- Database connection pooling

---

## 📋 BUSINESS CONSTRAINTS

### Technical Constraints
- Database: SQL Server only
- API: RESTful API only
- Authentication: JWT Bearer tokens only
- File storage: MinIO hoặc Firebase

### Business Constraints
- RoomCode format phải tuân theo quy tắc của dự án
- Phí dịch vụ không thể thay đổi retroactive
- Yêu cầu không thể xóa sau 24h
- Thẻ xe phải có đầy đủ giấy tờ mới được cấp

---

## 🔍 BUSINESS GLOSSARY

### Thuật Ngữ Nghiệp Vụ

| Thuật Ngữ | Định Nghĩa |
|-----------|------------|
| **Căn Hộ (Apartment)** | Đơn vị nhà ở trong dự án |
| **Chủ Hộ (Host)** | Người đại diện chính của căn hộ |
| **Thành Viên (Family Member)** | Người sống trong căn hộ nhưng không phải chủ hộ |
| **Thẻ Cư Dân (Resident Card)** | Thẻ ra vào chính của cư dân |
| **Thẻ Xe (Vehicle Card)** | Thẻ gửi xe cho phương tiện |
| **Phí Ở (Service Living Fee)** | Phí quản lý căn hộ hàng tháng |
| **Công Nợ (Receivable)** | Khoản phí chưa thanh toán |
| **Biên Lai (Receipt)** | Chứng từ thanh toán |
| **Yêu Cầu (Request)** | Đơn yêu cầu dịch vụ từ cư dân |
| **Phản Ánh (Feedback)** | Phản ánh về chất lượng dịch vụ |

---

## 📚 TÀI LIỆU LIÊN QUAN

- **00_Project_Structure.md**: Cấu trúc project
- **01_High_Level_Architecture.md**: Kiến trúc tổng thể
- **02_DATABASE_STRUCTURE.md**: Cấu trúc database
- **03_API_Documentation.md**: Tài liệu API endpoints
- **04_Data_Flow_Diagram.md**: Luồng dữ liệu

---

## 🎯 KẾT LUẬN

### Tóm Tắt Nghiệp Vụ

Hệ thống **UNI Resident API** quản lý toàn diện các nghiệp vụ của một khu căn hộ thông minh:

- ✅ **Quản lý Căn Hộ**: Từ đăng ký đến đóng căn hộ
- ✅ **Quản lý Thẻ**: Thẻ cư dân, thẻ xe, thẻ khách
- ✅ **Quản lý Phí Dịch Vụ**: Tính phí, thanh toán, biên lai
- ✅ **Quản lý Yêu Cầu**: Tạo yêu cầu, xử lý, đánh giá
- ✅ **Quản lý Thông Báo**: Đa kênh, lên lịch, tracking
- ✅ **Quản lý Gửi Xe**: Đăng ký, thanh toán, gia hạn
- ✅ **Quản lý Thang Máy**: Quyền truy cập, quản lý tầng
- ✅ **Báo Cáo & Phân Tích**: Đa dạng báo cáo hỗ trợ quyết định

### Business Value

- 🎯 **Tự Động Hóa**: Giảm thiểu thao tác thủ công
- 🎯 **Hiệu Quả**: Quản lý tập trung, dễ dàng truy xuất
- 🎯 **Trải Nghiệm**: Trải nghiệm tốt cho cư dân và quản lý
- 🎯 **Minh Bạch**: Thông tin rõ ràng, báo cáo đầy đủ

---

**Tài liệu được cập nhật**: {Ngày tạo tài liệu}  
**Phiên bản**: 1.0.0


