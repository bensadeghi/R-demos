### Demonstrate Open Database Connectivity (ODBC)
### Make connections with, and perform queries on Azure SQL-DW and Hive (HDInsight)

# Install and load the RODBC library
install.packages("RODBC", dependencies = TRUE)
library(RODBC)

# Connect to Azure SQL-DW database
conn <- "DRIVER={SQL Server Native Client 11.0};
        SERVER=*****.database.windows.net;
        DATABASE=*****;
        UID=*****;
        PWD=*****;
        Encrypt=yes;
        TrustServerCertificate=no"

channel <- odbcDriverConnect(conn)

# Perform direct SQL query via ODBC
sqldwData <- sqlQuery(channel, paste("SELECT TOP 10 * FROM mySQLDWTable"))

# Print first few rows of results
head(sqldwData)

# Close the connection
close(channel)


# Connect to Hive/Hadoop via ODBC
conn <- "DRIVER={Microsoft Hive ODBC Driver};
        Host=*****.azurehdinsight.net;
        Port=443;
        HiveServerType=2;
        AuthMech=6;
        UID=*****;
        PWD=*****"

channel <- odbcDriverConnect(conn)

hiveData <- sqlQuery(channel, paste("SELECT * FROM myHiveTable LIMIT 10;"))

head(hiveData)

close(channel)