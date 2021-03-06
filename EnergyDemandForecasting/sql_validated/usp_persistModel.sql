USE [forecastdb]
GO
/****** Object:  StoredProcedure [dbo].[usp_persistModel]    Script Date: 10/12/2018 5:13:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- stored procedure for persisting model
ALTER PROCEDURE [dbo].[usp_persistModel] 
	@region VARCHAR(64),
	@scoreStartTime VARCHAR(50),
	@sqlConnString VARCHAR(255)
AS
BEGIN
	DECLARE @ModelTable TABLE 
	(model varbinary(max))

	DECLARE @queryStr VARCHAR(max)
	set @queryStr = concat('select * from inputAllfeatures where region=''',  @region, ''' and utcTimestamp < ''',  @scoreStartTime , '''')

	INSERT INTO @ModelTable EXEC usp_trainModel @queryStr = @queryStr,@region=@region,@scoreStartTime=@scoreStartTime, @sqlConnString = @sqlConnString

	Merge Model as target
		USING (select @region as region,@scoreStartTime as startTime, model from @ModelTable) as source
	on target.region = source.region and target.startTime=source.startTime
	WHEN MATCHED THEN 
		UPDATE SET target.model= source.model
	WHEN NOT MATCHED THEN
		INSERT (model, region, startTime) values (source.model,source.region,@scoreStartTime);
END;
