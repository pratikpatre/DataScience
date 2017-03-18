historic = read.csv("/Users/rahulchandra/Desktop/ADS/historical_data1_Q12005/historical_data1_time_Q12005_2_1.csv")
historic_Q2 = read.csv("/Users/rahulchandra/Desktop/ADS/historical_data1_Q22005/historical_data1_time_Q22005_1.csv")
head(historic_Q2)

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


colmSec <- c("CurrentActualUPB", "OrigDTI", "LoanAge", "ZeroBalanceEffectiveDate", "Delinquent")
colmSec1 <- c("CurrentActualUPB", "OrigDTI", "LoanAge", "ZeroBalanceEffectiveDate")

summary(historic)
historic_bkp <- historic
historic$Delinquent[historic$CLDS > 0] <- 1
historic$Delinquent[historic$CLDS == 0] <- 0
historic$Delinquent[is.na(historic$Delinquent)] <- 1
historic$CLDS
historic$Delinquent
historic$Delinquent <- factor(historic$Delinquent, 
                              levels = c(0,1), 
                              labels = c("N","Y"))

table (historic$Delinquent)

historic_train <- historic[,colmSec]
historic_test <- historic_Q2[,colmSec1]

fit1 <- glm(Delinquent ~ ., data = historic_train, family = binomial(link = "logit"))

summary(fit1)

coef(fit1)

prob <- predict(fit1,newdata = historic_test, type = "response")

#new
sum(diag(prob))/sum(prob)*100
install.packages("forecast")
library(forecast)
accuracy(prob,historic_train$Delinquent)
#new


pred <- rep("N", length(prob))
pred[prob>=0.5] <- "Y"

install.packages("caret")
install.packages('e1071', dependencies=TRUE)
library(caret)

#New
confMAtrixResult <- confusionMatrix(historic_train$Delinquent,pred)
confMAtrixResult$table
#New

install.packages("ROCR")
library(ROCR)
prediction <- prediction(prob,historic_train$Delinquent)
performance <- performance(prediction, measure = "tpr", x.measure = "fpr")
plot(performance, main="ROC curve",xlab="1-specificity", ylab="Sensitivity")


historic_train$Probs = prob
historic_train$Prob = sort(historic_train$Probs,decreasing = T)
lift <- lift(Delinquent ~ prob, data = historic_train)
lift
xyplot(lift,plot = "gain")
