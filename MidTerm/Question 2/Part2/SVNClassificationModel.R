historic = read.csv("/Users/rahulchandra/Desktop/ADS/historical_data1_Q12005/historical_data1_time_Q12005_2_1.csv")
historic_Q2 = read.csv("/Users/rahulchandra/Desktop/ADS/historical_data1_Q22005/historical_data1_time_Q22005_1.csv")

library(e1071)
plot(historic)

colmSec <- c("CurrentActualUPB", "OrigDTI", "LoanAge", "ZeroBalanceEffectiveDate","CLDS")

historic_train <- historic[,colmSec]
historic_test <- historic_Q2[,colmSec]


historic_train$Delinquent[historic_train$CLDS > 0] <- 1
historic_train$Delinquent[historic_train$CLDS == 0] <- 0
historic_train$Delinquent[is.na(historic_train$Delinquent)] <- 1
historic_train$CLDS
historic_train$Delinquent
historic_train$Delinquent <- factor(historic_train$Delinquent, 
                                    levels = c(0,1), 
                                    labels = c("N","Y"))

table (historic_train$Delinquent)


svmfit <- svm(Delinquent ~. , data = historic_train, kernel = "linear", cost = 0.01, scale = FALSE)
print (svmfit)
plot(svmfit,historic_train[,colmSec])

tuned <- tune(svm, CLDS ~., data = historic_train, kernel = "linear", ranges = list(cost=c(0.001,0.01,0.1,1,10,100)))
summary(tuned)

p <- predict(svmfit,historic_test[,colmSec], type="class")

#New
pred <- rep("N", length(p))
pred[p>=0.5] <- "Y"

install.packages("caret")
install.packages('e1071', dependencies=TRUE)
library(caret)

confMAtrixResult <- confusionMatrix(historic_train$Delinquent,pred)
#New


plot(p)
table(p,historic_test[,3])
mean(p=historic_test[,3])