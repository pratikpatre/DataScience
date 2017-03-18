install.packages("neuralnet")
library(MASS)
library(grid)
library(neuralnet)
library(sqldf)
library(nnet)


#Going to create a neural network to perform sqare rooting
#Type ?neuralnet for more information on the neuralnet library

#Generate 50 random numbers uniformly distributed between 0 and 100
#And store them as a dataframe

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


colmSec <- c("CurrentActualUPB", "OrigDTI", "LoanAge", "ZeroBalanceEffectiveDate","CLDS")
colmSec_train <- c("CurrentActualUPB", "OrigDTI", "LoanAge", "ZeroBalanceEffectiveDate")
historic_train <- historic[,colmSec]
historic_test <- historic_Q2[,colmSec_train]

historic_train$Delinquent[historic_train$CLDS > 0] <- 1
historic_train$Delinquent[historic_train$CLDS == 0] <- 0
historic_train$Delinquent[is.na(historic_train$Delinquent)] <- 1
historic_train$CLDS
historic_train$Delinquent
historic_train$Delinquent <- factor(historic_train$Delinquent, 
                                    levels = c(0,1), 
                                    labels = c("N","Y"))

table (historic_train$Delinquent)


names <- c("CurrentActualUPB", "OrigDTI", "LoanAge", "ZeroBalanceEffectiveDate")
a <- as.formula(paste('Delinquent ~ ' ,paste(names,collapse='+')))


net.sqrt <- neuralnet( a ,historic_train, hidden=2, err.fct = "ce", linear.output = FALSE)

net.sqrt$net.result
net.sqrt$weights
net.sqrt$result.matrix
net.sqrt$covariate
net.sqrt$net.result[[1]]

net.sqrt1 <- ifelse(net.sqrt$net.result[[1]]>0.5,1,0)
misClassificationError = mean(historic_train$Delinquent != net.sqrt1)
OutPutVsPred = cbind(historic_train$Delinquent,net.sqrt1)

net.pred <- compute(net.sqrt, historic_test)

net.pred$net.result


performance <- performance(net.pred, measure = "tpr", x.measure = "fpr")
plot(performance, main="ROC curve",xlab="1-specificity", ylab="Sensitivity")

net.pred1 = c()
for (a in net.pred){
  print(a)
  net.pred1 = append(net.pred1,a)
}
pred <- rep("N", length(net.pred1))
pred[net.pred$net.result >=0.05] <- "Y"

install.packages("caret")
install.packages('e1071', dependencies=TRUE)
library(caret)





#New
confMAtrixResult <- confusionMatrix(historic_train$Delinquent,pred1)
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







#Test the neural network on some training data
net.results <- compute(net.sqrt, test[,1:5]) #Run them through the neural network
str(net.results)
#Lets see what properties net.sqrt has
ls(net.results)

#Lets see the results
print(net.results$net.result)

#Lets display a better version of the results
cleanoutput <- cbind(test$OrigInterestRate,
                     as.data.frame(net.results$net.result))
colnames(cleanoutput) <- c("Input","Neural Net Output")
print(cleanoutput)
