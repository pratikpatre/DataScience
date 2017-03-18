
# Load library
library(randomForest)
# Help on ramdonForest package and function
library(help=randomForest)
help(randomForest)


## Read data
termCrosssell<-read.csv(file="termCrosssell.csv",header = T)
## Explore data frame
names(termCrosssell)
##  [1] "age"            "job"            "marital"        "education"     
##  [5] "default"        "housing"        "loan"           "contact"       
##  [9] "month"          "day_of_week"    "duration"       "campaign"      
## [13] "pdays"          "previous"       "poutcome"       "emp.var.rate"  
## [17] "cons.price.idx" "cons.conf.idx"  "euribor3m"      "nr.employed"   
## [21] "y"


table(termCrosssell$y)/nrow(termCrosssell)
## 
##        no       yes 
## 0.8873458 0.1126542


sample.ind <- sample(2, 
                     nrow(termCrosssell),
                     replace = T,
                     prob = c(0.6,0.4))
cross.sell.dev <- termCrosssell[sample.ind==1,]
cross.sell.val <- termCrosssell[sample.ind==2,]

table(cross.sell.dev$y)/nrow(cross.sell.dev)
## 
##        no       yes 
## 0.8859289 0.1140711


table(cross.sell.val$y)/nrow(cross.sell.val)
## 
## no yes 
## 0.8894524 0.1105476


Class of Target Variable

class(cross.sell.dev$y)

## [1] "factor"


varNames <- names(cross.sell.dev)
# Exclude ID or Response variable
varNames <- varNames[!varNames %in% c("y")]

# add + sign between exploratory variables
varNames1 <- paste(varNames, collapse = "+")

# Add response variable and convert to a formula object
rf.form <- as.formula(paste("y", varNames1, sep = " ~ "))


cross.sell.rf <- randomForest(rf.form,
                              cross.sell.dev,
                              ntree=500,
                              importance=T)

plot(cross.sell.rf)


# Variable Importance Plot
varImpPlot(cross.sell.rf,
           sort = T,
           main="Variable Importance",
           n.var=5)

Variable Importance


# Variable Importance Table
var.imp <- data.frame(importance(cross.sell.rf,
                                 type=2))
# make row names as columns
var.imp$Variables <- row.names(var.imp)
var.imp[order(var.imp$MeanDecreaseGini,decreasing = T),]
##                MeanDecreaseGini      Variables
## duration             1435.30741       duration
## euribor3m             511.25934      euribor3m
## age                   366.42477            age
## job                   316.16851            job
## nr.employed           288.84357    nr.employed
## education             221.98129      education
## day_of_week           207.70090    day_of_week
## pdays                 183.81116          pdays
## campaign              176.34274       campaign
## poutcome              145.60094       poutcome
## month                 143.67009          month
## cons.conf.idx         124.65672  cons.conf.idx
## emp.var.rate          104.73467   emp.var.rate
## cons.price.idx        100.65364 cons.price.idx
## marital                95.76891        marital
## housing                78.29705        housing
## previous               63.87996       previous
## loan                   58.70528           loan
## contact                44.74415        contact
## default                34.55498        default


# Predicting response variable
cross.sell.dev$predicted.response <- predict(cross.sell.rf ,cross.sell.dev)

# Load Library or packages
library(e1071)
library(caret)
## Loading required package: lattice
## Loading required package: ggplot2
# Create Confusion Matrix
confusionMatrix(data=cross.sell.dev$predicted.response,
                reference=cross.sell.dev$y,
                positive='yes')
## Confusion Matrix and Statistics
## 
##           Reference
## Prediction    no   yes
##        no  21816    42
##        yes     0  2767
##                                           
##                Accuracy : 0.9983          
##                  95% CI : (0.9977, 0.9988)
##     No Information Rate : 0.8859          
##     P-Value [Acc > NIR] : < 2.2e-16


Validation Sample

# Predicting response variable
cross.sell.val$predicted.response <- predict(cross.sell.rf ,cross.sell.val)

# Create Confusion Matrix
confusionMatrix(data=cross.sell.val$predicted.response,
                reference=cross.sell.val$y,
                positive='yes')


## Confusion Matrix and Statistics
## 
## Reference
## Prediction no yes
## no 14196 860
## yes 536 971
## 
## Accuracy : 0.9157 
## 95% CI : (0.9114, 0.9199)