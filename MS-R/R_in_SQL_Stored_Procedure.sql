-- Demo of R Services Embedded Within SQL Statements

-- Set up SQL Server 2016 R Services (In-Database)
-- https://msdn.microsoft.com/en-us/library/mt696069.aspx


-- simple Hello World example to log
EXEC sp_execute_external_script
  @language = N'R',
  @script = N'print(''Hello World'')'
GO

-- simple Hello example as SQL table
EXEC sp_execute_external_script
  @language = N'R',
  @script = N'OutputDataSet <- InputDataSet',
  @input_data_1 = N'SELECT 1 AS hello'
WITH RESULT SETS (([hello] INT NOT NULL));
GO

-- fetch a table from SQL to R
DROP TABLE IF EXISTS MyData;
CREATE TABLE MyData([Col1] INT NOT NULL) ON [PRIMARY];
INSERT INTO MyData VALUES(1);
INSERT INTO MyData VALUES(10);
INSERT INTO MyData VALUES(100);
GO

-- print all rows of MyData table
SELECT * FROM MyData;

-- pass select query resutls to ouput dataset
EXEC sp_execute_external_script
  @language = N'R',
  @script = N'OutputDataSet <- InputDataSet',
  @input_data_1 = N'SELECT * FROM MyData;'
WITH RESULT SETS (([NewColName] INT NOT NULL));

-- input and output tables are SQL
EXEC sp_execute_external_script
  @language = N'R',
  @script = N'SQLOut <- SQLIn',
  @input_data_1 = N'SELECT 12 AS Col;',
  @input_data_1_name = N'SQLIn',
  @output_data_1_name = N'SQLOut'
WITH RESULT SETS (([NewColName] INT NOT NULL));

-- input table is data.frame, output is single column SQL table
EXEC sp_execute_external_script
  @language = N'R',
  @script = N'mytextvariable <- c("hello", " ", "world")
    OutputDataSet <- as.data.frame(mytextvariable)',
  @input_data_1 = N'SELECT 1 AS Temp1'
WITH RESULT SETS (([col] CHAR(20) NOT NULL));

-- input table is data.frame, output is single row SQL table
EXEC sp_execute_external_script
  @language = N'R',
  @script = N'OutputDataSet <- data.frame("hello", " ", "world")',
  @input_data_1 = N''
WITH RESULT SETS (([col1] VARCHAR(20), [col2] CHAR(1), [col3] VARCHAR(20)));

-- matrix multiplication with R (outer product)
EXEC sp_execute_external_script
  @language = N'R',
  @script = N'
    x <- as.matrix(InputDataSet)
    y <- array(12:15)
    OutputDataSet <- as.data.frame(x %*% y)',
  @input_data_1 = N'SELECT [Col1] FROM MyData;'
WITH RESULT SETS (([Col1] INT, [Col2] INT, [Col3] INT, Col4 INT));

-- combining R and SQL datasets
EXEC sp_execute_external_script
  @language = N'R',
  @script = N'
    df1 <- as.data.frame(array(1:6))
    df2 <- as.data.frame(c(InputDataSet, df1))
    OutputDataSet <- df2',
  @input_data_1 = N'SELECT [Col1] FROM MyData;'
WITH RESULT SETS (([Col2] INT NOT NULL, [Col3] INT NOT NULL));


------ iris data set examples ------
-- return a data.frame from R to SQL
DROP PROC IF EXISTS get_iris_dataset;  
GO
CREATE PROC get_iris_dataset  
AS  
BEGIN  
 EXEC sp_execute_external_script
       @language = N'R',
       @script = N'iris_data <- iris',
       @input_data_1 = N'',
       @output_data_1_name = N'iris_data' 
     WITH RESULT SETS ((
       "Sepal.Length" FLOAT NOT NULL,   
       "Sepal.Width" FLOAT NOT NULL,  
       "Petal.Length" FLOAT NOT NULL,   
       "Petal.Width" FLOAT NOT NULL, 
       "Species" VARCHAR(100)));  
END;  
GO

DROP TABLE IF EXISTS iris_data
GO
CREATE TABLE iris_data 
( 
  "Sepal.Length" FLOAT NOT NULL, 
  "Sepal.Width" FLOAT NOT NULL, 
  "Petal.Length" FLOAT NOT NULL, 
  "Petal.Width" FLOAT NOT NULL, 
  "Species" VARCHAR(100) 
);
GO 
INSERT INTO iris_data EXEC get_iris_dataset;
GO
SELECT * FROM iris_data;
GO

-- generate a decision tree model based on data from SQL Server
DROP PROC IF EXISTS generate_iris_model;  
GO
CREATE PROC generate_iris_model  
AS  
BEGIN  
 EXEC sp_execute_external_script  
       @language = N'R',
       @script = N'
          iris_model <- rxDTree(Species ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width, data = read_iris_data)
          trained_model <- data.frame(payload = as.raw(serialize(iris_model, connection = NULL)))',
       @input_data_1 = N'SELECT "Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width", "Species" FROM iris_data',
       @input_data_1_name = N'read_iris_data',
       @output_data_1_name = N'trained_model'
    WITH RESULT SETS ((model varbinary(max)));  
END;  
GO

-- save R model object in SQL table
DROP TABLE IF EXISTS built_models;
CREATE TABLE built_models (
	model_name VARCHAR(30) NOT NULL DEFAULT('default model') PRIMARY KEY,
	model varbinary(max) NOT NULL
);
GO
INSERT INTO built_models (model) EXEC generate_iris_model;
UPDATE built_models SET model_name = 'DTree' WHERE model_name = 'default model';
SELECT * FROM built_models;
GO

-- make predictions using decision tree model
DROP PROCEDURE IF EXISTS predict_species;
GO
CREATE PROCEDURE predict_species (@model VARCHAR(100)) AS
BEGIN
    DECLARE @dtree_model varbinary(max) = (SELECT model FROM built_models WHERE model_name = @model);
    EXEC sp_execute_external_script
      @language = N'R',
      @script = N'
          iris_model <- unserialize(dtree_model)
          OutputDataSet <- rxPredict(iris_model, read_iris_data)',
      @input_data_1 = N'SELECT "Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width" FROM iris_data',
      @input_data_1_name = N'read_iris_data',
      @params = N'@dtree_model varbinary(max)',
      @dtree_model = @dtree_model
    WITH RESULT SETS (("Setosa_Prob" FLOAT, "Versicolor_Prob" FLOAT, "Virginica_Prob" FLOAT));
END;
GO
EXEC predict_species 'DTree';
GO
