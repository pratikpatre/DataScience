install.packages("randomForest")
# Load library
library(randomForest)
library(sqldf)

historic = read.csv("/Users/rahulchandra/Desktop/ADS/historical_data1_Q12005/historical_data1_time_Q12005_2_1.csv")
historic_Q2 = read.csv("/Users/rahulchandra/Desktop/ADS/historical_data1_Q22005/historical_data1_time_Q22005_1.csv")


#allVars <- colnames(train)
#predictorVars <- allVars[!allVars%in%"CLDS"]
#predictorVars <- paste(predictorVars, collapse = "+")
#form = as.formula(paste("CLDS~",predictorVars,collapse = "+"))

historic$CLDS[is.na(historic$CLDS)] <- 1
historic$CLDS[historic$CLDS == "R"] <- 51

summary(historic$MonthlyReportingPeriod)

historic$CurrentActualUPB[is.na(historic$CurrentActualUPB)]
historic$OrigDTI[is.na(historic$OrigDTI)]
historic$LoanAge[is.na(historic$LoanAge)]
historic$ZeroBalanceEffectiveDate[is.na(historic$ZeroBalanceEffectiveDate)]

historic_Q2$CurrentActualUPB[is.na(historic_Q2$CurrentActualUPB)]
historic_Q2$OrigDTI[is.na(historic_Q2$OrigDTI)]
historic_Q2$LoanAge[is.na(historic_Q2$LoanAge)]
historic_Q2$ZeroBalanceEffectiveDate[is.na(historic_Q2$ZeroBalanceEffectiveDate)]

## Explore data frame
colmSec <- c("CurrentActualUPB", "OrigDTI", "LoanAge", "ZeroBalanceEffectiveDate","CLDS")
colmSec_test <- c("CurrentActualUPB", "OrigDTI", "LoanAge", "ZeroBalanceEffectiveDate")
historic_train <- historic[,colmSec]
historic_test <- historic_Q2[,colmSec_test]

historic_train$Delinquent[historic_train$CLDS > 0] <- 1
historic_train$Delinquent[historic_train$CLDS == 0] <- 0
historic_train$Delinquent[is.na(historic_train$Delinquent)] <- 1
historic_train$CLDS
historic_train$Delinquent

table (historic_train$Delinquent)
colmSec_train <- c("CurrentActualUPB", "OrigDTI", "LoanAge", "ZeroBalanceEffectiveDate","Delinquent")
historic_train <- historic_train[,colmSec_train]
apply(historic_train,2,function(x) length(unique(x)))

str(historic_test)
str(historic_train)


#trainning of model
modelRandom <- randomForest(Delinquent~.,data = historic_train, mtry=4,nodesize=5000, ntree=30,sampsize=10000, importance=T)

importance(modelRandom)
varImpPlot(modelRandom)

predic = predict(modelRandom, historic_test)

colmSec <- c("CurrentActualUPB", "OrigDTI", "LoanAge", "ZeroBalanceEffectiveDate","CLDS")
historic_test1 <- historic_Q2[,colmSec]

historic_test1$Delinquent[historic_test1$CLDS > 0] <- 1
historic_test1$Delinquent[historic_test1$CLDS == 0] <- 0
historic_test1$Delinquent[is.na(historic_test1$Delinquent)] <- 1
historic_test1$CLDS
historic_test1$Delinquent

t = table(predictions=predic,actual=historic_test1$Delinquent)

sum(diag(t))/sum(t)*100

modelRandom$confusion

table(getTree(modelRandom,20,labelVar = TRUE))
