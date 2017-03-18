library(ISLR)
library(leaps)
library(sqldf)
library(forecast)

loan_train = read.csv("C:\\Users\\Pratik Patre\\Desktop\\historical_data1_Q12005.csv")
samp_size = floor(0.01 * nrow(loan))
set.seed(123)
train_ind = sample(seq_len(nrow(loan)),size = samp_size)
loan <- loan_train
train= loan[train_ind,]
test= loan[-train_ind,]

train = sqldf("select MaturityDT,CreditScore,
                  MortgageInsurancePT,
                  NoUnits,
                  OrigUPB,
                  OrigInterestRate,
                  PPMFlag,
                  NoOfBorrowers,
                  FirstPaymentDT,
                  FirstTimeHomeBuyerFlag,
                  OccupancyStatus,
                  PropertyType,
                  LoanPurpose,
                  OrigLoanTerm
           from loan_train")
train$CreditScore[train$CreditScore== ""] <- 300
train$MortgageInsurancePT[train$MortgageInsurancePT==""] <- 0
train$NoUnits[train$NoUnits==""] <-0
train$OrigCLTV[train$OrigCLTV==""] <- 201
train$OrigDTI[train$OrigDTI==""] <- 67
train$OrigUPB[train$OrigUPB==""] <- 0
train$OrigLTV[train$OrigLTV==""] <- 201
train$OrigInterestRate[train$OrigInterestRate==""] <-0
train$PPMFlag[train$PPMFlag==""] <- 'Y'
train$NoOfBorrowers[train$NoOfBorrowers==""] <-0

regfit.full.train=regsubsets(OrigInterestRate~.,data = train,nvmax=22)

reg.summary.train = summary(regfit.full.train)
reg.summary.train$rss
reg.summary.train$adjr2
par(mfrow=c(2,2)) 
plot(reg.summary.train$rss ,xlab="Number of Variables ",ylab="RSS", type="l")
plot(reg.summary.train$adjr2 ,xlab="Number of Variables ", ylab="Adjusted RSq",type="l")

summary(regfit.full.train)

coef(regfit.full.train ,9)

xhstve.train = sqldf("select MaturityDT,
                       CreditScore,
                       MortgageInsurancePT,
                       OrigUPB,
                       PPMFlag,
                       FirstPaymentDT,
                       FirstTimeHomeBuyerFlag,
                       OccupancyStatus,
                       LoanPurpose,
                       OrigLoanTerm,
                       OrigInterestRate
                 from loan_train")

fit.train=lm(OrigInterestRate~.,data = xhstve.train)
summary(fit.train)

summ =summary(fit.train)
summ$r.squared
summ$adj.r.squared

loan_test = read.csv("C:\\Users\\Pratik Patre\\Desktop\\historical_data1_Q22005.csv")

xhstve.test = sqldf("select MaturityDT,
                       CreditScore,
                     MortgageInsurancePT,
                     OrigUPB,
                     PPMFlag,
                     FirstPaymentDT,
                     FirstTimeHomeBuyerFlag,
                     OccupancyStatus,
                     LoanPurpose,
                     OrigLoanTerm,
                     OrigInterestRate
                     from loan_test")

pred = predict(fit.train,xhstve.test)
accuracy(pred, xhstve.train$OrigInterestRate)


