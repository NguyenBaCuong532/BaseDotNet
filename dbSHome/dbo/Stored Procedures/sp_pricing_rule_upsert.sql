CREATE   PROCEDURE dbo.sp_pricing_rule_upsert
    @project_code INT,
    @vehicle_type_id INT,
    @valid_from DATETIME2(0),
    @valid_to   DATETIME2(0) = NULL,
    -- các tham số rule chính
    @rate_mode VARCHAR(30),
    @under24_enabled BIT = 0, @under24_cap MONEY = NULL,
    @full24_enabled  BIT = 0, @full24_amount MONEY = NULL,
    @over24_mode VARCHAR(30) = 'cap_then_block',
    @rate_over_per_hour MONEY = NULL, @extra_per_24h MONEY = NULL,
    -- output
    @o_rule_id INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  -- 1) chống chồng lắp: nếu khoảng [from,to) giao bất kỳ rule đang active khác => báo lỗi
  IF EXISTS (
     SELECT 1
     FROM dbo.pricing_rule r
     WHERE r.project_code=@project_code AND r.vehicle_type_id=@vehicle_type_id AND r.is_active=1
       AND ( @valid_to   IS NULL OR r.valid_from < @valid_to )
       AND ( r.valid_to    IS NULL OR @valid_from < r.valid_to )
  )
     THROW 50011, 'Time range overlaps with an existing active rule.', 1;

  INSERT dbo.pricing_rule(
      project_code, vehicle_type_id, valid_from, valid_to, is_active,
      rate_mode, under24_enabled, under24_cap_amount, full24_enabled, full24_amount,
      over24_mode, rate_over_per_hour, extra_per_24h
  )
  VALUES (
      @project_code, @vehicle_type_id, @valid_from, @valid_to, 1,
      @rate_mode, @under24_enabled, @under24_cap, @full24_enabled, @full24_amount,
      @over24_mode, @rate_over_per_hour, @extra_per_24h
  );

  SET @o_rule_id = SCOPE_IDENTITY();
END