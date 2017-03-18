install.packages("ISLR")
install.packages("leaps")
library(ISLR)
library(leaps)
library(sqldf)

getwd()
loan = c()
loan = read.csv("/Users/rahulchandra/Downloads/sample_1999/sample_orig_1999.csv")
samp_size = floor(0.01 * nrow(loan))
set.seed(123)
train_ind = sample(seq_len(nrow(loan)),size = samp_size)
train= loan[train_ind,]
test= loan[-train_ind,]

s = sqldf("select CreditScore,
          MortgageInsurancePT,
          NoUnits,
          OrigCLTV,
          OrigDTI,
          OrigUPB,
          OrigLTV,
          OrigInterestRate,
          PPMFlag,
          NoOfBorrowers,
          FirstPaymentDT,FirstTimeHomeBuyerFlag,MaturityDT,MetroDiv,OccupancyStatus,Channel,PropertyState,PropertyType,PostaleCode,LoanSeqNo,LoanPurpose,OrigLoanTerm
          from train")

s = sqldf("select MaturityDT,CreditScore,
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
          from train")

s$FirstPaymentDT[s$FirstPaymentDT== ""] <- 0
s$FirstTimeHomeBuyerFlag[s$FirstTimeHomeBuyerFlag== ""] <- 'U'
s$MaturityDT[s$MaturityDT== ""] <- 0
s$MetroDiv[s$MetroDiv== ""] <- 0
s$OccupancyStatus[s$OccupancyStatus== ""] <- 'U'
s$Channel[s$Channel== ""] <- 'U'
s$PropertyState[s$PropertyState== ""] <- 'XX'
s$PropertyType[s$PropertyType== ""] <- 'XX'
s$PostaleCode[s$PostaleCode== ""] <- 0
s$LoanSeqNo[s$LoanSeqNo== ""] <- 0
s$LoanPurpose[s$LoanPurpose== ""] <- 'U'
s$OrigLoanTerm[s$OrigLoanTerm== ""] <- 0

s$CreditScore[s$CreditScore== ""] <- 300
s$MortgageInsurancePT[s$MortgageInsurancePT==""] <- 0
s$NoUnits[s$NoUnits==""] <-0
s$OrigCLTV[s$OrigCLTV==""] <- 201
s$OrigDTI[s$OrigDTI==""] <- 67
s$OrigUPB[s$OrigUPB==""] <- 0
s$OrigLTV[s$OrigLTV==""] <- 201
s$OrigInterestRate[s$OrigInterestRate==""] <-0
s$PPMFlag[s$PPMFlag==""] <- 'Y'
s$NoOfBorrowers[s$NoOfBorrowers==""] <-0

regfit.full1=regsubsets(OrigInterestRate~.,nvmax = 22, data = s)

reg.summary1 = summary(regfit.full1)
reg.summary1$rss
reg.summary1$adjr2
par(mfrow=c(2,2)) 
plot(reg.summary1$rss ,xlab="Number of Variables ",ylab="RSS", type="l")
plot(reg.summary1$adjr2 ,xlab="Number of Variables ", ylab="Adjusted RSq",type="l")
summary(regfit.full1)
coef(regfit.full1 ,8)

regsubsets()()



lm.fit1=lm(OrigInterestRate~.,data = s)
summary(lm.fit1)