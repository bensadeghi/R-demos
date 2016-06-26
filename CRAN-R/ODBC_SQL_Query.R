### Demonstrate connectivity and SQL Query via ODBC with SQL-DW and Hive/HDInsight on Azure

# Install and load the RODBC library
install.packages("RODBC", dependencies = TRUE)
library(RODBC)

######################
# Connect to MS SQL-DW
conn <- "DRIVER={SQL Server Native Client 11.0};
        SERVER=*****.database.windows.net;
        DATABASE=*****;
        UID=*****;
        PWD=*****;
        Encrypt=yes;
        TrustServerCertificate=no"

channel <- odbcDriverConnect(conn)

# Perform SQL query on database
initdata <- sqlQuery(channel, paste("SELECT TOP 10 * FROM nyctaxinb.nyctaxi"))

head(initdata)

###########################
# Connect to Hive/HDInsight
conn <- "DRIVER={Microsoft Hive ODBC Driver};
        Host=*****.azurehdinsight.net;
        Port=443;
        HiveServerType=2;
        AuthMech=6;
        UID=*****;
        PWD=*****"

channel <- odbcDriverConnect(conn)

initdata <- sqlQuery(channel, paste("SELECT * FROM nyctaxidb.trip LIMIT 10;"))

head(initdata)
