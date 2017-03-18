library(ISLR)
library(leaps)
library(sqldf)
library(forecast)

loan_train = read.csv("C:\\Users\\Pratik Patre\\Desktop\\historical_data1_Q12005.csv")

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

regfit.bwd.train=regsubsets(OrigInterestRate~.,data = train,nvmax=22, method= "backward")

reg.summary.train = summary(regfit.bwd.train)
reg.summary.train$rss
reg.summary.train$adjr2
par(mfrow=c(2,2)) 
plot(reg.summary.train$rss ,xlab="Number of Variables ",ylab="RSS", type="l")
plot(reg.summary.train$adjr2 ,xlab="Number of Variables ", ylab="Adjusted RSq",type="l")

summary(regfit.bwd.train)

coef(regfit.bwd.train ,9)

xhstve.train = sqldf("select 
                     CreditScore,
                     MortgageInsurancePT,
                     OrigUPB,
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

xhstve.test = sqldf("select 
                    CreditScore,
                    MortgageInsurancePT,
                    OrigUPB,
                    OccupancyStatus,
                    LoanPurpose,
                    OrigLoanTerm,
                    OrigInterestRate
                    from loan_train")

pred = predict(fit.train,xhstve.test)
accuracy(pred, xhstve.train$OrigInterestRate)


