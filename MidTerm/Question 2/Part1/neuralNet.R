install.packages("neuralnet")
library(MASS)
library(grid)
library(neuralnet)

#Going to create a neural network to perform sqare rooting
#Type ?neuralnet for more information on the neuralnet library

#Generate 50 random numbers uniformly distributed between 0 and 100
#And store them as a dataframe

train = read.csv("C:\\Users\\Pratik Patre\\Desktop\\historical_data1_Q12005.csv")
test = read.csv("C:\\Users\\Pratik Patre\\Desktop\\historical_data1_Q22005.csv")
set.seed(123)

train = sqldf("select CreditScore,
              MortgageInsurancePT,
              NoUnits,
              OrigUPB,
              OrigInterestRate,
              NoOfBorrowers
              from train")

test = sqldf("select CreditScore,
              MortgageInsurancePT,
             NoUnits,
             OrigUPB,
             OrigInterestRate,
             NoOfBorrowers
             from test")

maxValue <- apply(train, 2, max)
minValue <- apply(train, 2, min)

#traininginput <-  as.data.frame(runif(50, min=0, max=100))
#trainingoutput <- sqrt(traininginput)

#Column bind the data into one variable
#trainingdata <- cbind(traininginput,trainingoutput)
#colnames(trainingdata) <- c("Input","Output")

#Train the neural network
#Going to have 10 hidden layers
#Threshold is a numeric value specifying the threshold for the partial
#derivatives of the error function as stopping criteria.

allVars <- colnames(train)
predictorVars <- allVars[!allVars%in%"OrigInterestRate"]
predictorVars <- paste(predictorVars, collapse = "+")
form = as.formula(paste("OrigInterestRate~",predictorVars,collapse = "+"))

names <- c("CreditScore", "MortgageInsurancePT", "NoUnits", "OrigUPB", "NoOfBorrowers")
a <- as.formula(paste('OrigInterestRate ~ ' ,paste(names,collapse='+')))


train$CreditScore[is.na(train$CreditScore)] <- 300
train$MortgageInsurancePT[is.na(train$MortgageInsurancePT)] <- 0
train$NoUnits[is.na(train$NoUnits)] <-0
train$OrigUPB[is.na(train$OrigUPB)] <- 0
train$NoOfBorrowers[is.na(train$NoOfBorrowers)] <-0

test$CreditScore[is.na(test$CreditScore)] <- 300
test$MortgageInsurancePT[is.na(test$MortgageInsurancePT)] <- 0
test$NoUnits[is.na(test$NoUnits)] <-0
test$OrigUPB[is.na(test$OrigUPB)] <- 0
test$NoOfBorrowers[is.na(test$NoOfBorrowers)] <-0

net.sqrt <- neuralnet( a ,train, hidden=c(10,4,4), threshold = 0.01, linear.output = T)
print(net.sqrt)

#Plot the neural network
plot(net.sqrt)

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
