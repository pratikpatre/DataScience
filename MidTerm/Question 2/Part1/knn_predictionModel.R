setwd("C:/Users/cool/Desktop")
q12005 <- read.csv("C:\\Users\\Pratik Patre\\Desktop\\historical_data1_Q12005.csv")
q22005 <- read.csv("C:\\Users\\Pratik Patre\\Desktop\\historical_data1_Q22005.csv")
head (gc)
head (fc)
samp_size = floor(0.01 * nrow(q12005))
set.seed(123)
train_ind = sample(seq_len(nrow(q12005)),size = samp_size)
gc= q12005[train_ind,]
fc= q12005[-train_ind,]

## Taking back-up of the input file, in case the original data is required later

gc.bkup <- gc

## Convert the dependent var to factor. Normalize the numeric variables  
gc$CreditScore[is.na(gc$CreditScore)] <- 300
gc$MortgageInsurancePT[is.na(gc$MortgageInsurancePT)] <- 0
gc$OrigCLTV[is.na(gc$OrigCLTV)] <- 201
gc$OrigDTI[is.na(gc$OrigDTI)] <- 67
gc$OrigUPB[is.na(gc$OrigUPB)] <- 0
gc$OrigLTV[is.na(gc$OrigLTV)] <- 201
gc$OrigInterestRate[is.na(gc$OrigInterestRate)] <-0
gc$PPMFlag[is.na(gc$PPMFlag)] <- 'Y'
gc$NoOfBorrowers[is.na(gc$NoOfBorrowers)] <-0
gc$OrigInterestRate[is.na(gc$OrigInterestRate)] <-0

fc$CreditScore[is.na(fc$CreditScore)] <- 300
fc$MortgageInsurancePT[is.na(fc$MortgageInsurancePT)] <- 0
fc$OrigCLTV[is.na(fc$OrigCLTV)] <- 201
fc$OrigDTI[is.na(fc$OrigDTI)] <- 67
fc$OrigUPB[is.na(fc$OrigUPB)] <- 0
fc$OrigLTV[is.na(fc$OrigLTV)] <- 201
fc$OrigInterestRate[is.na(fc$OrigInterestRate)] <-0
fc$PPMFlag[is.na(fc$PPMFlag)] <- 'Y'
fc$NoOfBorrowers[is.na(fc$NoOfBorrowers)] <-0
fc$OrigInterestRate[is.na(fc$OrigInterestRate)] <-0

fc$OrigInterestRate <- factor(fc$OrigInterestRate)
gc$OrigInterestRate <- factor(gc$OrigInterestRate)


normalize <- function(x){
  return ( (x - min(x)) / (max(x) - min(x)) )
}

## Selecting only 3 numeric variables for this demostration, just to keep things simple
myvars <- c("CreditScore", "OrigUPB", "MortgageInsurancePT")
target_var <- c("OrigInterestRate")

gc_n <- as.data.frame(lapply(gc[,myvars], normalize))
head(gc_n)
gc_n_target <- gc[,target_var]

fc_n <- as.data.frame(lapply(fc[,myvars], normalize))
head(fc_n)
fc_n_target <- fc[,target_var]


## checking the summary
summary(gc_n)
summary(fc_n)

## performing KNN algorithm
itr = ceiling(sqrt(length(gc_n_target)))
itr = itr -1

library(class)
m1 <-  knn(train=gc_n, test=fc_n, cl=gc_n_target, k=59)

values <- as.numeric(as.character(m1))

library(forecast)
table(fc_n_target,m1)
accuracy(fc_n_target)

?accuracy

####################################################################################################
######################################Below code not needed#########################################
####################################################################################################

set.seed() 
train.gc <- gc.subset
#train.gc[train.gc==""]=0
test.fc <- fc.subset
#test.gc[test.gc==""]=0

train.def <- gc$OrigInterestRate
len(train.def)
train.def[train.def==""]=0
train.def[is.na(train.def)] = 0
test.def <- fc$OrigInterestRate

## Let's use k values (no of NNs) as 1, 5 and 20 to see how they perform in terms of correct proportion of classification and success rate. The optimum k value can be chosen based on the outcomes as below...

library(class)

m1 <-  knn(train = train.gc, test.gc, train.def, k=223)
knn.5 <-  knn(train.gc, test.gc, train.def, k=5)
knn.20 <- knn(train.gc, test.gc, train.def, k=20)

pred = predict(knn.1,test.def)
## Let's calculate the proportion of correct classification for k = 1, 5 & 20 

100 * sum(test.def == knn.1)/100  # For knn = 1


100 * sum(test.def == knn.5)/100  # For knn = 5


100 * sum(test.def == knn.20)/100 # For knn = 20

## If we look at the above proportions, it's quite evident that K = 1 correctly classifies 68% of the outcomes, K = 5 correctly classifies 74% and K = 20 does it for 81% of the outcomes. 

## We should also look at the success rate against the value of increasing K.

table(test.def,knn.1)

## For K = 1, among 65 customers, 54 or 83%, is success rate. Let's look at k = 5 now

table(knn.5 ,test.def)

## For K = 5, among 76 customers, 63 or 82%, is success rate.Let's look at K = 20 now

table(knn.20 ,test.def)

##For K = 20, among 88 customers, 71 or 80%, is success rate.

## It seems increasing K increases the classification but reduces success rate. It is worse to class a customer as good when it is bad, than it is to class a customer as bad when it is good. 
## By looking at above success rates, K = 1 or K = 5 can be taken as optimum K.
## We can make a plot of the data with the training set in hollow shapes and the new ones filled in. 
## Plot for K = 1 can be created as follows - 

plot(train.gc[,c("amount","duration")],
     col=c(4,3,6,2)[gc.bkup[-test, "installment"]],
     pch=c(1,2)[as.numeric(train.def)],
     main="Predicted Default, by 1 Nearest Neighbors",cex.main=.95)

points(test.gc[,c("amount","duration")],
       bg=c(4,3,6,2)[gc.bkup[-test,"installment"]],
       pch=c(21,24)[as.numeric(knn.1)],cex=1.2,col=grey(.7))

legend("bottomright",pch=c(1,16,2,17),bg=c(1,1,1,1),
       legend=c("data 0","pred 0","data 1","pred 1"),
       title="default",bty="n",cex=.8)

legend("topleft",fill=c(4,3,6,2),legend=c(1,2,3,4),
       title="installment %", horiz=TRUE,bty="n",col=grey(.7),cex=.8)
