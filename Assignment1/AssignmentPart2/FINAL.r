install.packages("sqldf")
install.packages("dplyr")
install.packages("chron")
install.packages("xlsx")

library(sqldf)
library(dplyr)
library(chron)
library(xlsx)

sink(file="test10.txt", append = TRUE)

readinteger <- function()
{ 
  n <- readline(prompt="Enter year: ")
  n <- as.integer(n)
  if (is.na(n)){
    n <- readinteger()
  }
  return(n)
}

file_path_input <- paste(getwd(),"/input_append2.csv", sep = "")
file_read <- read_csv(file_path_input)
year = file_read$year

#year = readinteger()

#year = read.csv("P:/config.csv")

for(i in c(01,02,03,04,05,06,07,08,09,10,11,12)){
  temp <- tempfile()
  
  if(i==01){
    download.file(paste("http://www.sec.gov/dera/data/Public-EDGAR-log-file-data/",year,"/Qtr1/log",year,"0101.zip", sep = ""),temp)
    print(paste(Sys.time(),"Success: File for 1st of January",year,"is downloaded.",sep=" "))
    data1 <- read.csv(unz(temp, paste("log",year,"0101.csv", sep = "")))
    print(paste(Sys.time(),"Handling empty data for 1st of January",year,sep=" "))
    if((NROW(data1)>1)){
      data1[data1== ""] <- NA}
    print(paste(Sys.time(),"Success: Empty Data Handled for 1st of January",year,sep=" "))
    print(paste(Sys.time(),"Handling CIK having 0 Values and fetching relevant data for analysis for 1st of January",year,sep=" "))
    sam = (sqldf("select d.ip, d.cik, d.time, d.date 
                 from data1 d 
                 where d.ip in (select distinct j.ip 
                 from data1 j 
                 where j.cik = 0) 
                 order by d.ip,d.time"))
    
    if(!NROW(sam) == 0){
      colm <- c()
      k<- 0
      for(j in sam$cik){
        k <- k + 1
        if(j==0){
          print(k)
          colm <- c(colm,k)
        }
      }
      j<- 0
      for(j in 1:length(sam[,1])){
        cik1 <- 0
        time1 <- 0
        cik2<- 0
        time2 <- 0
        if(j %in% colm){
          if(sam$ip[j] == sam$ip[j-1]){
            
            cik1 <- sam$cik[j-1]
            if (chron(times.= sam$time[j]) > chron(times.= sam$time[j-1])){
              time1 <- (chron(times.= sam$time[j])) - chron(times. = sam$time[j-1])
              
            } else {
              time1 <- (chron(times.= sam$time[j-1])) - chron(times. = sam$time[j])
              
            }
          }
          if (sam$ip[j] == sam$ip[j+1]){
            
            cik2 <- sam$cik[j+1]
            if (chron(times.= sam$time[j]) > chron(times.= sam$time[j+1])){
              time2 <- (chron(times.= sam$time[j])) - chron(times. = sam$time[j+1])
              
            } else {
              time2 <- (chron(times.= sam$time[j+1])) - chron(times. = sam$time[j])
              
            }
          }
          
          if(time2 >= time1 & sam$ip[j] == sam$ip[j-1]){
            sam$cik[j] <- cik1
          }
          if (time2 <= time1 & sam$ip[j] == sam$ip[j+1]){
            sam$cik[j] <- cik2
          }
        }
      }
      
      data1 = sam
    }
    
    print(paste(Sys.time(),"Success: CIK with 0 values handled for 1st of January",year,sep=" "))
    print(paste(Sys.time(),"Fetching Master List for CIK",sep=" "))
    
    temp <- tempfile()
    download.file("https://www.sec.gov/edgar/NYU/cik.coleft.c",temp)
    field = unlist(strsplit(readLines(temp),":"))
    field2 = substr(field,regexpr("[^0]",field),nchar(field)) 
    
    print(paste(Sys.time(),"Deleting invalid CIK records for 1st of January",year,sep=" "))
    
    tri <- c()
    k=0
    for (val in data1$cik){
      k= k+1
      if (!(as.character(val) %in% (field2))){
        tri = c(tri,k )
      }
    }
    if(!(is.null(tri))){
      data1 = data1[-tri,]
    }
    print(paste(Sys.time(),"Success: Invalid CIK records deleted for 1st of January",year,sep=" "))
    
    print(paste(Sys.time(),"Summarizing data for 1st of January",year,sep=" "))
    data1 = sqldf("select date, cik, count(cik) as count 
                  from data1 
                  group by cik 
                  order by count desc")
    
    print(paste(Sys.time(),"Success: Data summarized for 1st of January",year,sep=" "))
    
  }
  
  if(i==02){
    download.file(paste("http://www.sec.gov/dera/data/Public-EDGAR-log-file-data/",year,"/Qtr1/log",year,"0201.zip", sep = ""),temp)
    print(paste(Sys.time(),"File for 1st of February",year,"is downloaded.",sep=" "))
    data2 <- read.csv(unz(temp, paste("log",year,"0201.csv", sep = "")))
    print(paste(Sys.time(),"Handling empty data for 1st of February",year,sep=" "))
    if((NROW(data2)>1)){
      data2[data2== ""] <- NA}
    print(paste(Sys.time(),"Success: Empty Data Handled for 1st of February",year,sep=" "))
    print(paste(Sys.time(),"Handling CIK having 0 Values and fetching relevant data for analysis for 1st of February",year,sep=" "))
    sam = (sqldf("select d.ip, d.cik, d.time, d.date 
                 from data2 d 
                 where d.ip in (select distinct j.ip 
                 from data2 j 
                 where j.cik = 0) 
                 order by d.ip,d.time"))
    
    if(!NROW(sam) == 0){
      colm <- c()
      k<- 0
      for(j in sam$cik){
        k <- k + 1
        if(j==0){
          print(k)
          colm <- c(colm,k)
        }
      }
      j<- 0
      for(j in 1:length(sam[,1])){
        cik1 <- 0
        time1 <- 0
        cik2<- 0
        time2 <- 0
        if(j %in% colm){
          if(sam$ip[j] == sam$ip[j-1]){
            
            cik1 <- sam$cik[j-1]
            if (chron(times.= sam$time[j]) > chron(times.= sam$time[j-1])){
              time1 <- (chron(times.= sam$time[j])) - chron(times. = sam$time[j-1])
              
            } else {
              time1 <- (chron(times.= sam$time[j-1])) - chron(times. = sam$time[j])
              
            }
          }
          if (sam$ip[j] == sam$ip[j+1]){
            
            cik2 <- sam$cik[j+1]
            if (chron(times.= sam$time[j]) > chron(times.= sam$time[j+1])){
              time2 <- (chron(times.= sam$time[j])) - chron(times. = sam$time[j+1])
              
            } else {
              time2 <- (chron(times.= sam$time[j+1])) - chron(times. = sam$time[j])
              
            }
          }
          
          if(time2 >= time1 & sam$ip[j] == sam$ip[j-1]){
            sam$cik[j] <- cik1
          }
          if (time2 <= time1 & sam$ip[j] == sam$ip[j+1]){
            sam$cik[j] <- cik2
          }
        }
      }
      
      data2 = sam
    }
    
    print(paste(Sys.time(),"Success: CIK with 0 values handled for 1st of February",year,sep=" "))
    print(paste(Sys.time(),"Fetching Master List for CIK",sep=" "))
    
    temp <- tempfile()
    download.file("https://www.sec.gov/edgar/NYU/cik.coleft.c",temp)
    field = unlist(strsplit(readLines(temp),":"))
    field2 = substr(field,regexpr("[^0]",field),nchar(field)) 
    
    print(paste(Sys.time(),"Deleting invalid CIK records for 1st of February",year,sep=" "))
    
    tri <- c()
    k=0
    for (val in data2$cik){
      k= k+1
      if (!(as.character(val) %in% (field2))){
        tri = c(tri,k )
      }
    }
    if(!(is.null(tri))){
      data2 = data2[-tri,]
    }
    print(paste(Sys.time(),"Success: Invalid CIK records deleted for 1st of February",year,sep=" "))
    
    print(paste(Sys.time(),"Summarizing data for 1st of February",year,sep=" "))
    data2 = sqldf("select date, cik, count(cik) as count 
                  from data2 
                  group by cik 
                  order by count desc")
    
    print(paste(Sys.time(),"Success: Data summarized for 1st of February",year,sep=" "))
  }
  if(i==03){
    download.file(paste("http://www.sec.gov/dera/data/Public-EDGAR-log-file-data/",year,"/Qtr1/log",year,"0301.zip", sep = ""),temp)
    print(paste(Sys.time(),"File for 1st of March",year,"is downloaded.",sep=" "))
    data3 <- read.csv(unz(temp, paste("log",year,"0301.csv", sep = "")))
    print(paste(Sys.time(),"Handling empty data for 1st of March",year,sep=" "))
    if((NROW(data3)>1)){
      data3[data3== ""] <- NA}
    print(paste(Sys.time(),"Success: Empty Data Handled for 1st of March",year,sep=" "))
    print(paste(Sys.time(),"Handling CIK having 0 Values and fetching relevant data for analysis for 1st of March",year,sep=" "))
    sam = (sqldf("select d.ip, d.cik, d.time, d.date 
                 from data3 d 
                 where d.ip in (select distinct j.ip 
                 from data3 j 
                 where j.cik = 0) 
                 order by d.ip,d.time"))
    
    if(!NROW(sam) == 0){
      colm <- c()
      k<- 0
      for(j in sam$cik){
        k <- k + 1
        if(j==0){
          print(k)
          colm <- c(colm,k)
        }
      }
      j<- 0
      for(j in 1:length(sam[,1])){
        cik1 <- 0
        time1 <- 0
        cik2<- 0
        time2 <- 0
        if(j %in% colm){
          if(sam$ip[j] == sam$ip[j-1]){
            
            cik1 <- sam$cik[j-1]
            if (chron(times.= sam$time[j]) > chron(times.= sam$time[j-1])){
              time1 <- (chron(times.= sam$time[j])) - chron(times. = sam$time[j-1])
              
            } else {
              time1 <- (chron(times.= sam$time[j-1])) - chron(times. = sam$time[j])
              
            }
          }
          if (sam$ip[j] == sam$ip[j+1]){
            
            cik2 <- sam$cik[j+1]
            if (chron(times.= sam$time[j]) > chron(times.= sam$time[j+1])){
              time2 <- (chron(times.= sam$time[j])) - chron(times. = sam$time[j+1])
              
            } else {
              time2 <- (chron(times.= sam$time[j+1])) - chron(times. = sam$time[j])
              
            }
          }
          
          if(time2 >= time1 & sam$ip[j] == sam$ip[j-1]){
            sam$cik[j] <- cik1
          }
          if (time2 <= time1 & sam$ip[j] == sam$ip[j+1]){
            sam$cik[j] <- cik2
          }
        }
      }
      
      data3 = sam
    }
    
    print(paste(Sys.time(),"Success: CIK with 0 values handled for 1st of March",year,sep=" "))
    print(paste(Sys.time(),"Fetching Master List for CIK",sep=" "))
    
    temp <- tempfile()
    download.file("https://www.sec.gov/edgar/NYU/cik.coleft.c",temp)
    field = unlist(strsplit(readLines(temp),":"))
    field2 = substr(field,regexpr("[^0]",field),nchar(field)) 
    
    print(paste(Sys.time(),"Deleting invalid CIK records for 1st of March",year,sep=" "))
    
    #tri <- c()
    #k=0
    #for (val in data3$cik){
    #  k= k+1
     # if (!(as.character(val) %in% (field2))){
     #   tri = c(tri,k )
     # }
    #}
    #if(!(is.null(tri))){
    #  data3 = data3[-tri,]
    #}
    #print(paste(Sys.time(),"Success: Invalid CIK records deleted for 1st of March",year,sep=" "))
    
    print(paste(Sys.time(),"Summarizing data for 1st of March",year,sep=" "))
    data3 = sqldf("select date, cik, count(cik) as count 
                  from data3 
                  group by cik 
                  order by count desc")
    
    print(paste(Sys.time(),"Success: Data summarized for 1st of March",year,sep=" "))}
  if(i==04){
    download.file(paste("http://www.sec.gov/dera/data/Public-EDGAR-log-file-data/",year,"/Qtr2/log",year,"0401.zip", sep = ""),temp)
    print(paste(Sys.time(),"File for 1st of April",year,"is downloaded.",sep=" "))
    data4 <- read.csv(unz(temp, paste("log",year,"0401.csv", sep = "")))
    print(paste(Sys.time(),"Handling empty data for 1st of April",year,sep=" "))
    if((NROW(data4)>1)){
      data4[data4== ""] <- NA}
    print(paste(Sys.time(),"Success: Empty Data Handled for 1st of April",year,sep=" "))
    print(paste(Sys.time(),"Handling CIK having 0 Values and fetching relevant data for analysis for 1st of April",year,sep=" "))
    sam = (sqldf("select d.ip, d.cik, d.time, d.date 
                 from data4 d 
                 where d.ip in (select distinct j.ip 
                 from data4 j 
                 where j.cik = 0) 
                 order by d.ip,d.time"))
    
    if(!NROW(sam) == 0){
      colm <- c()
      k<- 0
      for(j in sam$cik){
        k <- k + 1
        if(j==0){
          print(k)
          colm <- c(colm,k)
        }
      }
      j<- 0
      for(j in 1:length(sam[,1])){
        cik1 <- 0
        time1 <- 0
        cik2<- 0
        time2 <- 0
        if(j %in% colm){
          if(sam$ip[j] == sam$ip[j-1]){
            
            cik1 <- sam$cik[j-1]
            if (chron(times.= sam$time[j]) > chron(times.= sam$time[j-1])){
              time1 <- (chron(times.= sam$time[j])) - chron(times. = sam$time[j-1])
              
            } else {
              time1 <- (chron(times.= sam$time[j-1])) - chron(times. = sam$time[j])
              
            }
          }
          if (sam$ip[j] == sam$ip[j+1]){
            
            cik2 <- sam$cik[j+1]
            if (chron(times.= sam$time[j]) > chron(times.= sam$time[j+1])){
              time2 <- (chron(times.= sam$time[j])) - chron(times. = sam$time[j+1])
              
            } else {
              time2 <- (chron(times.= sam$time[j+1])) - chron(times. = sam$time[j])
              
            }
          }
          
          if(time2 >= time1 & sam$ip[j] == sam$ip[j-1]){
            sam$cik[j] <- cik1
          }
          if (time2 <= time1 & sam$ip[j] == sam$ip[j+1]){
            sam$cik[j] <- cik2
          }
        }
      }
      
      data4 = sam
    }
    
    print(paste(Sys.time(),"Success: CIK with 0 values handled for 1st of April",year,sep=" "))
    print(paste(Sys.time(),"Fetching Master List for CIK",sep=" "))
    
    temp <- tempfile()
    download.file("https://www.sec.gov/edgar/NYU/cik.coleft.c",temp)
    field = unlist(strsplit(readLines(temp),":"))
    field2 = substr(field,regexpr("[^0]",field),nchar(field)) 
    
    print(paste(Sys.time(),"Deleting invalid CIK records for 1st of April",year,sep=" "))
    
    #tri <- c()
    #k=0
    #for (val in data4$cik){
    #  k= k+1
    #  if (!(as.character(val) %in% (field2))){
     #   tri = c(tri,k )
    #  }
    #}
    #if(!(is.null(tri))){
    #  data4 = data4[-tri,]
    #}
    #print(paste(Sys.time(),"Success: Invalid CIK records deleted for 1st of April",year,sep=" "))
    
    print(paste(Sys.time(),"Summarizing data for 1st of April",year,sep=" "))
    data4 = sqldf("select date, cik, count(cik) as count 
                  from data4 
                  group by cik 
                  order by count desc")
    
    print(paste(Sys.time(),"Success: Data summarized for 1st of April",year,sep=" "))
  }
  if(i==05){
    download.file(paste("http://www.sec.gov/dera/data/Public-EDGAR-log-file-data/",year,"/Qtr2/log",year,"0501.zip", sep = ""),temp)
    print(paste(Sys.time(),"File for 1st of May",year,"is downloaded.",sep=" "))
    data5 <- read.csv(unz(temp, paste("log",year,"0501.csv", sep = "")))
    print(paste(Sys.time(),"Handling empty data for 1st of May",year,sep=" "))
    if((NROW(data5)>1)){
      data5[data5== ""] <- NA}
    print(paste(Sys.time(),"Success: Empty Data Handled for 1st of May",year,sep=" "))
    print(paste(Sys.time(),"Handling CIK having 0 Values and fetching relevant data for analysis for 1st of May",year,sep=" "))
    sam = (sqldf("select d.ip, d.cik, d.time, d.date 
                 from data5 d 
                 where d.ip in (select distinct j.ip 
                 from data5 j 
                 where j.cik = 0) 
                 order by d.ip,d.time"))
    
    if(!NROW(sam) == 0){
      colm <- c()
      k<- 0
      for(j in sam$cik){
        k <- k + 1
        if(j==0){
          print(k)
          colm <- c(colm,k)
        }
      }
      j<- 0
      for(j in 1:length(sam[,1])){
        cik1 <- 0
        time1 <- 0
        cik2<- 0
        time2 <- 0
        if(j %in% colm){
          if(sam$ip[j] == sam$ip[j-1]){
            
            cik1 <- sam$cik[j-1]
            if (chron(times.= sam$time[j]) > chron(times.= sam$time[j-1])){
              time1 <- (chron(times.= sam$time[j])) - chron(times. = sam$time[j-1])
              
            } else {
              time1 <- (chron(times.= sam$time[j-1])) - chron(times. = sam$time[j])
              
            }
          }
          if (sam$ip[j] == sam$ip[j+1]){
            
            cik2 <- sam$cik[j+1]
            if (chron(times.= sam$time[j]) > chron(times.= sam$time[j+1])){
              time2 <- (chron(times.= sam$time[j])) - chron(times. = sam$time[j+1])
              
            } else {
              time2 <- (chron(times.= sam$time[j+1])) - chron(times. = sam$time[j])
              
            }
          }
          
          if(time2 >= time1 & sam$ip[j] == sam$ip[j-1]){
            sam$cik[j] <- cik1
          }
          if (time2 <= time1 & sam$ip[j] == sam$ip[j+1]){
            sam$cik[j] <- cik2
          }
        }
      }
      
      data5 = sam
    }
    
    print(paste(Sys.time(),"Success: CIK with 0 values handled for 1st of May",year,sep=" "))
    print(paste(Sys.time(),"Fetching Master List for CIK",sep=" "))
    
    temp <- tempfile()
    download.file("https://www.sec.gov/edgar/NYU/cik.coleft.c",temp)
    field = unlist(strsplit(readLines(temp),":"))
    field2 = substr(field,regexpr("[^0]",field),nchar(field)) 
    
    print(paste(Sys.time(),"Deleting invalid CIK records for 1st of May",year,sep=" "))
    
    #tri <- c()
    #k=0
    #for (val in data5$cik){
    #  k= k+1
    #  if (!(as.character(val) %in% (field2))){
    #    tri = c(tri,k )
     # }
    #}
    #if(!(is.null(tri))){
    #  data5 = data5[-tri,]
    #}
    #print(paste(Sys.time(),"Success: Invalid CIK records deleted for 1st of May",year,sep=" "))
    
    print(paste(Sys.time(),"Summarizing data for 1st of May",year,sep=" "))
    data5 = sqldf("select date, cik, count(cik) as count 
                  from data5 
                  group by cik 
                  order by count desc")
    
    print(paste(Sys.time(),"Success: Data summarized for 1st of May",year,sep=" "))
  }
  if(i==06){
    download.file(paste("http://www.sec.gov/dera/data/Public-EDGAR-log-file-data/",year,"/Qtr2/log",year,"0601.zip", sep = ""),temp)
    print(paste(Sys.time(),"File for 1st of June",year,"is downloaded.",sep=" "))
    data6 <- read.csv(unz(temp, paste("log",year,"0601.csv", sep = "")))
    print(paste(Sys.time(),"Handling empty data for 1st of June",year,sep=" "))
    if((NROW(data6)>1)){
      data6[data6== ""] <- NA}
    print(paste(Sys.time(),"Success: Empty Data Handled for 1st of June",year,sep=" "))
    print(paste(Sys.time(),"Handling CIK having 0 Values and fetching relevant data for analysis for 1st of June",year,sep=" "))
    sam = (sqldf("select d.ip, d.cik, d.time, d.date 
                 from data6 d 
                 where d.ip in (select distinct j.ip 
                 from data6 j 
                 where j.cik = 0) 
                 order by d.ip,d.time"))
    
    if(!NROW(sam) == 0){
      colm <- c()
      k<- 0
      for(j in sam$cik){
        k <- k + 1
        if(j==0){
          print(k)
          colm <- c(colm,k)
        }
      }
      j<- 0
      for(j in 1:length(sam[,1])){
        cik1 <- 0
        time1 <- 0
        cik2<- 0
        time2 <- 0
        if(j %in% colm){
          if(sam$ip[j] == sam$ip[j-1]){
            
            cik1 <- sam$cik[j-1]
            if (chron(times.= sam$time[j]) > chron(times.= sam$time[j-1])){
              time1 <- (chron(times.= sam$time[j])) - chron(times. = sam$time[j-1])
              
            } else {
              time1 <- (chron(times.= sam$time[j-1])) - chron(times. = sam$time[j])
              
            }
          }
          if (sam$ip[j] == sam$ip[j+1]){
            
            cik2 <- sam$cik[j+1]
            if (chron(times.= sam$time[j]) > chron(times.= sam$time[j+1])){
              time2 <- (chron(times.= sam$time[j])) - chron(times. = sam$time[j+1])
              
            } else {
              time2 <- (chron(times.= sam$time[j+1])) - chron(times. = sam$time[j])
              
            }
          }
          
          if(time2 >= time1 & sam$ip[j] == sam$ip[j-1]){
            sam$cik[j] <- cik1
          }
          if (time2 <= time1 & sam$ip[j] == sam$ip[j+1]){
            sam$cik[j] <- cik2
          }
        }
      }
      
      data6 = sam
    }
    
    print(paste(Sys.time(),"Success: CIK with 0 values handled for 1st of June",year,sep=" "))
    print(paste(Sys.time(),"Fetching Master List for CIK",sep=" "))
    
    temp <- tempfile()
    download.file("https://www.sec.gov/edgar/NYU/cik.coleft.c",temp)
    field = unlist(strsplit(readLines(temp),":"))
    field2 = substr(field,regexpr("[^0]",field),nchar(field)) 
    
    print(paste(Sys.time(),"Deleting invalid CIK records for 1st of June",year,sep=" "))
    
    #tri <- c()
    #k=0
    #for (val in data6$cik){
    #  k= k+1
    #  if (!(as.character(val) %in% (field2))){
    #    tri = c(tri,k )
    #  }
    #}
    #if(!(is.null(tri))){
    #  data6 = data6[-tri,]
    #}
    #print(paste(Sys.time(),"Success: Invalid CIK records deleted for 1st of June",year,sep=" "))
    
    print(paste(Sys.time(),"Summarizing data for 1st of June",year,sep=" "))
    data6 = sqldf("select date, cik, count(cik) as count 
                  from data6 
                  group by cik 
                  order by count desc")
    
    print(paste(Sys.time(),"Success: Data summarized for 1st of June",year,sep=" "))
  }
  if(i==07){
    download.file(paste("http://www.sec.gov/dera/data/Public-EDGAR-log-file-data/",year,"/Qtr3/log",year,"0701.zip", sep = ""),temp)
    print(paste(Sys.time(),"File for 1st of July",year,"is downloaded.",sep=" "))
    data7 <- read.csv(unz(temp, paste("log",year,"0701.csv", sep = "")))
    print(paste(Sys.time(),"Handling empty data for 1st of July",year,sep=" "))
    if((NROW(data7)>1)){
      data7[data7== ""] <- NA}
    print(paste(Sys.time(),"Success: Empty Data Handled for 1st of July",year,sep=" "))
    print(paste(Sys.time(),"Handling CIK having 0 Values and fetching relevant data for analysis for 1st of July",year,sep=" "))
    sam = (sqldf("select d.ip, d.cik, d.time, d.date 
                 from data7 d 
                 where d.ip in (select distinct j.ip 
                 from data7 j 
                 where j.cik = 0) 
                 order by d.ip,d.time"))
    
    if(!NROW(sam) == 0){
      colm <- c()
      k<- 0
      for(j in sam$cik){
        k <- k + 1
        if(j==0){
          print(k)
          colm <- c(colm,k)
        }
      }
      j<- 0
      for(j in 1:length(sam[,1])){
        cik1 <- 0
        time1 <- 0
        cik2<- 0
        time2 <- 0
        if(j %in% colm){
          if(sam$ip[j] == sam$ip[j-1]){
            
            cik1 <- sam$cik[j-1]
            if (chron(times.= sam$time[j]) > chron(times.= sam$time[j-1])){
              time1 <- (chron(times.= sam$time[j])) - chron(times. = sam$time[j-1])
              
            } else {
              time1 <- (chron(times.= sam$time[j-1])) - chron(times. = sam$time[j])
              
            }
          }
          if (sam$ip[j] == sam$ip[j+1]){
            
            cik2 <- sam$cik[j+1]
            if (chron(times.= sam$time[j]) > chron(times.= sam$time[j+1])){
              time2 <- (chron(times.= sam$time[j])) - chron(times. = sam$time[j+1])
              
            } else {
              time2 <- (chron(times.= sam$time[j+1])) - chron(times. = sam$time[j])
              
            }
          }
          
          if(time2 >= time1 & sam$ip[j] == sam$ip[j-1]){
            sam$cik[j] <- cik1
          }
          if (time2 <= time1 & sam$ip[j] == sam$ip[j+1]){
            sam$cik[j] <- cik2
          }
        }
      }
      
      data7 = sam
    }
    
    print(paste(Sys.time(),"Success: CIK with 0 values handled for 1st of July",year,sep=" "))
    print(paste(Sys.time(),"Fetching Master List for CIK",sep=" "))
    
    temp <- tempfile()
    download.file("https://www.sec.gov/edgar/NYU/cik.coleft.c",temp)
    field = unlist(strsplit(readLines(temp),":"))
    field2 = substr(field,regexpr("[^0]",field),nchar(field)) 
    
    print(paste(Sys.time(),"Deleting invalid CIK records for 1st of July",year,sep=" "))
    
    #tri <- c()
    #k=0
    #for (val in data7$cik){
    #  k= k+1
    # if (!(as.character(val) %in% (field2))){
    #    tri = c(tri,k )
    #  }
    #}
    #if(!(is.null(tri))){
    #  data7 = data7[-tri,]
    #}
    #print(paste(Sys.time(),"Success: Invalid CIK records deleted for 1st of July",year,sep=" "))
    
    print(paste(Sys.time(),"Summarizing data for 1st of July",year,sep=" "))
    data7 = sqldf("select date, cik, count(cik) as count 
                  from data7 
                  group by cik 
                  order by count desc")
    
    print(paste(Sys.time(),"Success: Data summarized for 1st of July",year,sep=" "))
  }
  if(i==08){
    download.file(paste("http://www.sec.gov/dera/data/Public-EDGAR-log-file-data/",year,"/Qtr3/log",year,"0801.zip", sep = ""),temp)
    print(paste(Sys.time(),"File for 1st of August",year,"is downloaded.",sep=" "))
    data8 <- read.csv(unz(temp, paste("log",year,"0801.csv", sep = "")))
    print(paste(Sys.time(),"Handling empty data for 1st of August",year,sep=" "))
    if((NROW(data8)>1)){
      data8[data8== ""] <- NA}
    print(paste(Sys.time(),"Success: Empty Data Handled for 1st of August",year,sep=" "))
    print(paste(Sys.time(),"Handling CIK having 0 Values and fetching relevant data for analysis for 1st of August",year,sep=" "))
    sam = (sqldf("select d.ip, d.cik, d.time, d.date 
                 from data8 d 
                 where d.ip in (select distinct j.ip 
                 from data8 j 
                 where j.cik = 0) 
                 order by d.ip,d.time"))
    
    if(!NROW(sam) == 0){
      colm <- c()
      k<- 0
      for(j in sam$cik){
        k <- k + 1
        if(j==0){
          print(k)
          colm <- c(colm,k)
        }
      }
      j<- 0
      for(j in 1:length(sam[,1])){
        cik1 <- 0
        time1 <- 0
        cik2<- 0
        time2 <- 0
        if(j %in% colm){
          if(sam$ip[j] == sam$ip[j-1]){
            
            cik1 <- sam$cik[j-1]
            if (chron(times.= sam$time[j]) > chron(times.= sam$time[j-1])){
              time1 <- (chron(times.= sam$time[j])) - chron(times. = sam$time[j-1])
              
            } else {
              time1 <- (chron(times.= sam$time[j-1])) - chron(times. = sam$time[j])
              
            }
          }
          if (sam$ip[j] == sam$ip[j+1]){
            
            cik2 <- sam$cik[j+1]
            if (chron(times.= sam$time[j]) > chron(times.= sam$time[j+1])){
              time2 <- (chron(times.= sam$time[j])) - chron(times. = sam$time[j+1])
              
            } else {
              time2 <- (chron(times.= sam$time[j+1])) - chron(times. = sam$time[j])
              
            }
          }
          
          if(time2 >= time1 & sam$ip[j] == sam$ip[j-1]){
            sam$cik[j] <- cik1
          }
          if (time2 <= time1 & sam$ip[j] == sam$ip[j+1]){
            sam$cik[j] <- cik2
          }
        }
      }
      
      data8 = sam
    }
    
    print(paste(Sys.time(),"Success: CIK with 0 values handled for 1st of August",year,sep=" "))
    print(paste(Sys.time(),"Fetching Master List for CIK",sep=" "))
    
    temp <- tempfile()
    download.file("https://www.sec.gov/edgar/NYU/cik.coleft.c",temp)
    field = unlist(strsplit(readLines(temp),":"))
    field2 = substr(field,regexpr("[^0]",field),nchar(field)) 
    
    print(paste(Sys.time(),"Deleting invalid CIK records for 1st of August",year,sep=" "))
    
    #tri <- c()
    #k=0
    #for (val in data8$cik){
    #  k= k+1
    #  if (!(as.character(val) %in% (field2))){
    #    tri = c(tri,k )
     # }
    #}
    #if(!(is.null(tri))){
    #  data8 = data8[-tri,]
    #}
    #print(paste(Sys.time(),"Success: Invalid CIK records deleted for 1st of August",year,sep=" "))
    
    print(paste(Sys.time(),"Summarizing data for 1st of August",year,sep=" "))
    data8 = sqldf("select date, cik, count(cik) as count 
                  from data8 
                  group by cik 
                  order by count desc")
    
    print(paste(Sys.time(),"Success: Data summarized for 1st of August",year,sep=" "))
  }
  if(i==09){
    download.file(paste("http://www.sec.gov/dera/data/Public-EDGAR-log-file-data/",year,"/Qtr3/log",year,"0901.zip", sep = ""),temp)
    print(paste(Sys.time(),"File for 1st of September",year,"is downloaded.",sep=" "))
    data9 <- read.csv(unz(temp, paste("log",year,"0901.csv", sep = "")))
    print(paste(Sys.time(),"Handling empty data for 1st of September",year,sep=" "))
    if((NROW(data9)>1)){
      data9[data9== ""] <- NA}
    print(paste(Sys.time(),"Success: Empty Data Handled for 1st of September",year,sep=" "))
    print(paste(Sys.time(),"Handling CIK having 0 Values and fetching relevant data for analysis for 1st of September",year,sep=" "))
    sam = (sqldf("select d.ip, d.cik, d.time, d.date 
                 from data9 d 
                 where d.ip in (select distinct j.ip 
                 from data9 j 
                 where j.cik = 0) 
                 order by d.ip,d.time"))
    
    if(!NROW(sam) == 0){
      colm <- c()
      k<- 0
      for(j in sam$cik){
        k <- k + 1
        if(j==0){
          print(k)
          colm <- c(colm,k)
        }
      }
      j<- 0
      for(j in 1:length(sam[,1])){
        cik1 <- 0
        time1 <- 0
        cik2<- 0
        time2 <- 0
        if(j %in% colm){
          if(sam$ip[j] == sam$ip[j-1]){
            
            cik1 <- sam$cik[j-1]
            if (chron(times.= sam$time[j]) > chron(times.= sam$time[j-1])){
              time1 <- (chron(times.= sam$time[j])) - chron(times. = sam$time[j-1])
              
            } else {
              time1 <- (chron(times.= sam$time[j-1])) - chron(times. = sam$time[j])
              
            }
          }
          if (sam$ip[j] == sam$ip[j+1]){
            
            cik2 <- sam$cik[j+1]
            if (chron(times.= sam$time[j]) > chron(times.= sam$time[j+1])){
              time2 <- (chron(times.= sam$time[j])) - chron(times. = sam$time[j+1])
              
            } else {
              time2 <- (chron(times.= sam$time[j+1])) - chron(times. = sam$time[j])
              
            }
          }
          
          if(time2 >= time1 & sam$ip[j] == sam$ip[j-1]){
            sam$cik[j] <- cik1
          }
          if (time2 <= time1 & sam$ip[j] == sam$ip[j+1]){
            sam$cik[j] <- cik2
          }
        }
      }
      
      data9 = sam
    }
    
    print(paste(Sys.time(),"Success: CIK with 0 values handled for 1st of September",year,sep=" "))
    print(paste(Sys.time(),"Fetching Master List for CIK",sep=" "))
    
    temp <- tempfile()
    download.file("https://www.sec.gov/edgar/NYU/cik.coleft.c",temp)
    field = unlist(strsplit(readLines(temp),":"))
    field2 = substr(field,regexpr("[^0]",field),nchar(field)) 
    
    print(paste(Sys.time(),"Deleting invalid CIK records for 1st of September",year,sep=" "))
    
    #tri <- c()
    #k=0
    #for (val in data9$cik){
    #  k= k+1
    #  if (!(as.character(val) %in% (field2))){
    #    tri = c(tri,k )
    #  }
    #}
    #if(!(is.null(tri))){
    #  data9 = data9[-tri,]
    #}
    #print(paste(Sys.time(),"Success: Invalid CIK records deleted for 1st of September",year,sep=" "))
    
    print(paste(Sys.time(),"Summarizing data for 1st of September",year,sep=" "))
    data9 = sqldf("select date, cik, count(cik) as count 
                  from data9 
                  group by cik 
                  order by count desc")
    
    print(paste(Sys.time(),"Success: Data summarized for 1st of September",year,sep=" "))
  }
  if(i==10){
    download.file(paste("http://www.sec.gov/dera/data/Public-EDGAR-log-file-data/",year,"/Qtr4/log",year,"1001.zip", sep = ""),temp)
    print(paste(Sys.time(),"File for 1st of October",year,"is downloaded.",sep=" "))
    data10 <- read.csv(unz(temp, paste("log",year,"1001.csv", sep = "")))
    print(paste(Sys.time(),"Handling empty data for 1st of October",year,sep=" "))
    if((NROW(data10)>1)){
      data10[data10== ""] <- NA}
    print(paste(Sys.time(),"Success: Empty Data Handled for 1st of October",year,sep=" "))
    print(paste(Sys.time(),"Handling CIK having 0 Values and fetching relevant data for analysis for 1st of October",year,sep=" "))
    sam = (sqldf("select d.ip, d.cik, d.time, d.date 
                 from data10 d 
                 where d.ip in (select distinct j.ip 
                 from data10 j 
                 where j.cik = 0) 
                 order by d.ip,d.time"))
    
    if(!NROW(sam) == 0){
      colm <- c()
      k<- 0
      for(j in sam$cik){
        k <- k + 1
        if(j==0){
          print(k)
          colm <- c(colm,k)
        }
      }
      j<- 0
      for(j in 1:length(sam[,1])){
        cik1 <- 0
        time1 <- 0
        cik2<- 0
        time2 <- 0
        if(j %in% colm){
          if(sam$ip[j] == sam$ip[j-1]){
            
            cik1 <- sam$cik[j-1]
            if (chron(times.= sam$time[j]) > chron(times.= sam$time[j-1])){
              time1 <- (chron(times.= sam$time[j])) - chron(times. = sam$time[j-1])
              
            } else {
              time1 <- (chron(times.= sam$time[j-1])) - chron(times. = sam$time[j])
              
            }
          }
          if (sam$ip[j] == sam$ip[j+1]){
            
            cik2 <- sam$cik[j+1]
            if (chron(times.= sam$time[j]) > chron(times.= sam$time[j+1])){
              time2 <- (chron(times.= sam$time[j])) - chron(times. = sam$time[j+1])
              
            } else {
              time2 <- (chron(times.= sam$time[j+1])) - chron(times. = sam$time[j])
              
            }
          }
          
          if(time2 >= time1 & sam$ip[j] == sam$ip[j-1]){
            sam$cik[j] <- cik1
          }
          if (time2 <= time1 & sam$ip[j] == sam$ip[j+1]){
            sam$cik[j] <- cik2
          }
        }
      }
      
      data10 = sam
    }
    
    print(paste(Sys.time(),"Success: CIK with 0 values handled for 1st of October",year,sep=" "))
    print(paste(Sys.time(),"Fetching Master List for CIK",sep=" "))
    
    temp <- tempfile()
    download.file("https://www.sec.gov/edgar/NYU/cik.coleft.c",temp)
    field = unlist(strsplit(readLines(temp),":"))
    field2 = substr(field,regexpr("[^0]",field),nchar(field)) 
    
    print(paste(Sys.time(),"Deleting invalid CIK records for 1st of October",year,sep=" "))
    
    #tri <- c()
    #k=0
    #for (val in data10$cik){
    #  k= k+1
    #  if (!(as.character(val) %in% (field2))){
    #    tri = c(tri,k )
    #  }
    #}
    #if(!(is.null(tri))){
    #  data10 = data10[-tri,]
    #}
    #print(paste(Sys.time(),"Success: Invalid CIK records deleted for 1st of October",year,sep=" "))
    
    print(paste(Sys.time(),"Summarizing data for 1st of October",year,sep=" "))
    data10 = sqldf("select date, cik, count(cik) as count 
                   from data10 
                   group by cik 
                   order by count desc")
    
    print(paste(Sys.time(),"Success: Data summarized for 1st of October",year,sep=" "))
  }
  if(i==11){
    download.file(paste("http://www.sec.gov/dera/data/Public-EDGAR-log-file-data/",year,"/Qtr4/log",year,"1101.zip", sep = ""),temp)
    print(paste(Sys.time(),"File for 1st of November",year,"is downloaded.",sep=" "))
    data11 <- read.csv(unz(temp, paste("log",year,"1101.csv", sep = "")))
    print(paste(Sys.time(),"Handling empty data for 1st of November",year,sep=" "))
    if((NROW(data11)>1)){
      data11[data11== ""] <- NA}
    print(paste(Sys.time(),"Success: Empty Data Handled for 1st of November",year,sep=" "))
    print(paste(Sys.time(),"Handling CIK having 0 Values and fetching relevant data for analysis for 1st of November",year,sep=" "))
    sam = (sqldf("select d.ip, d.cik, d.time, d.date 
                 from data11 d 
                 where d.ip in (select distinct j.ip 
                 from data11 j 
                 where j.cik = 0) 
                 order by d.ip,d.time"))
    
    if(!NROW(sam) == 0){
      colm <- c()
      k<- 0
      for(j in sam$cik){
        k <- k + 1
        if(j==0){
          print(k)
          colm <- c(colm,k)
        }
      }
      j<- 0
      for(j in 1:length(sam[,1])){
        cik1 <- 0
        time1 <- 0
        cik2<- 0
        time2 <- 0
        if(j %in% colm){
          if(sam$ip[j] == sam$ip[j-1]){
            
            cik1 <- sam$cik[j-1]
            if (chron(times.= sam$time[j]) > chron(times.= sam$time[j-1])){
              time1 <- (chron(times.= sam$time[j])) - chron(times. = sam$time[j-1])
              
            } else {
              time1 <- (chron(times.= sam$time[j-1])) - chron(times. = sam$time[j])
              
            }
          }
          if (sam$ip[j] == sam$ip[j+1]){
            
            cik2 <- sam$cik[j+1]
            if (chron(times.= sam$time[j]) > chron(times.= sam$time[j+1])){
              time2 <- (chron(times.= sam$time[j])) - chron(times. = sam$time[j+1])
              
            } else {
              time2 <- (chron(times.= sam$time[j+1])) - chron(times. = sam$time[j])
              
            }
          }
          
          if(time2 >= time1 & sam$ip[j] == sam$ip[j-1]){
            sam$cik[j] <- cik1
          }
          if (time2 <= time1 & sam$ip[j] == sam$ip[j+1]){
            sam$cik[j] <- cik2
          }
        }
      }
      
      data11 = sam
    }
    
    print(paste(Sys.time(),"Success: CIK with 0 values handled for 1st of November",year,sep=" "))
    print(paste(Sys.time(),"Fetching Master List for CIK",sep=" "))
    
    temp <- tempfile()
    download.file("https://www.sec.gov/edgar/NYU/cik.coleft.c",temp)
    field = unlist(strsplit(readLines(temp),":"))
    field2 = substr(field,regexpr("[^0]",field),nchar(field)) 
    
    print(paste(Sys.time(),"Deleting invalid CIK records for 1st of November",year,sep=" "))
    
    #tri <- c()
    #k=0
    #for (val in data11$cik){
    #  k= k+1
    #  if (!(as.character(val) %in% (field2))){
    #    tri = c(tri,k )
    #  }
    #}
    #if(!(is.null(tri))){
    #  data11 = data11[-tri,]
    #}
    #print(paste(Sys.time(),"Success: Invalid CIK records deleted for 1st of November",year,sep=" "))
    
    print(paste(Sys.time(),"Summarizing data for 1st of November",year,sep=" "))
    data11 = sqldf("select date, cik, count(cik) as count 
                   from data11 
                   group by cik 
                   order by count desc")
    
    print(paste(Sys.time(),"Success: Data summarized for 1st of November",year,sep=" "))
  }
  if(i==12){
    download.file(paste("http://www.sec.gov/dera/data/Public-EDGAR-log-file-data/",year,"/Qtr4/log",year,"1201.zip", sep = ""),temp)
    print(paste(Sys.time(),"File for 1st of December",year,"is downloaded.",sep=" "))
    data12 <- read.csv(unz(temp, paste("log",year,"1201.csv", sep = "")))
    print(paste(Sys.time(),"Handling empty data for 1st of December",year,sep=" "))
    if((NROW(data12)>1)){
      data12[data12== ""] <- NA}
    print(paste(Sys.time(),"Success: Empty Data Handled for 1st of December",year,sep=" "))
    print(paste(Sys.time(),"Handling CIK having 0 Values and fetching relevant data for analysis for 1st of December",year,sep=" "))
    sam = (sqldf("select d.ip, d.cik, d.time, d.date 
                 from data12 d 
                 where d.ip in (select distinct j.ip 
                 from data12 j 
                 where j.cik = 0) 
                 order by d.ip,d.time"))
    
    if(!NROW(sam) == 0){
      colm <- c()
      k<- 0
      for(j in sam$cik){
        k <- k + 1
        if(j==0){
          print(k)
          colm <- c(colm,k)
        }
      }
      j<- 0
      for(j in 1:length(sam[,1])){
        cik1 <- 0
        time1 <- 0
        cik2<- 0
        time2 <- 0
        if(j %in% colm){
          if(sam$ip[j] == sam$ip[j-1]){
            
            cik1 <- sam$cik[j-1]
            if (chron(times.= sam$time[j]) > chron(times.= sam$time[j-1])){
              time1 <- (chron(times.= sam$time[j])) - chron(times. = sam$time[j-1])
              
            } else {
              time1 <- (chron(times.= sam$time[j-1])) - chron(times. = sam$time[j])
              
            }
          }
          if (sam$ip[j] == sam$ip[j+1]){
            
            cik2 <- sam$cik[j+1]
            if (chron(times.= sam$time[j]) > chron(times.= sam$time[j+1])){
              time2 <- (chron(times.= sam$time[j])) - chron(times. = sam$time[j+1])
              
            } else {
              time2 <- (chron(times.= sam$time[j+1])) - chron(times. = sam$time[j])
              
            }
          }
          
          if(time2 >= time1 & sam$ip[j] == sam$ip[j-1]){
            sam$cik[j] <- cik1
          }
          if (time2 <= time1 & sam$ip[j] == sam$ip[j+1]){
            sam$cik[j] <- cik2
          }
        }
      }
      
      data12 = sam
    }
    
    print(paste(Sys.time(),"Success: CIK with 0 values handled for 1st of December",year,sep=" "))
    print(paste(Sys.time(),"Fetching Master List for CIK",sep=" "))
    
    temp <- tempfile()
    download.file("https://www.sec.gov/edgar/NYU/cik.coleft.c",temp)
    field = unlist(strsplit(readLines(temp),":"))
    field2 = substr(field,regexpr("[^0]",field),nchar(field)) 
    
    print(paste(Sys.time(),"Deleting invalid CIK records for 1st of December",year,sep=" "))
    
    #tri <- c()
    #k=0
    #for (val in data12$cik){
    #  k= k+1
    #  if (!(as.character(val) %in% (field2))){
    #    tri = c(tri,k )
    #  }
    #}
    #if(!(is.null(tri))){
    #  data12 = data12[-tri,]
    #}
    #print(paste(Sys.time(),"Success: Invalid CIK records deleted for 1st of December",year,sep=" "))
    
    print(paste(Sys.time(),"Summarizing data for 1st of December",year,sep=" "))
    data12 = sqldf("select date, cik, count(cik) as count 
                 from data12 
                 group by cik 
                 order by count desc")
    
    print(paste(Sys.time(),"Success: Data summarized for 1st of December",year,sep=" "))
  }
}

print(paste(Sys.time(),"Merging Data into one File",year,sep=" "))
bigData =0
bigData=merge(data1,data2,all=TRUE)
bigData=merge(bigData,data3,all=TRUE)
bigData=merge(bigData,data4,all=TRUE)
bigData=merge(bigData,data5,all=TRUE)
bigData=merge(bigData,data6,all=TRUE)
bigData=merge(bigData,data7,all=TRUE)
bigData=merge(bigData,data8,all=TRUE)
bigData=merge(bigData,data9,all=TRUE)
bigData=merge(bigData,data10,all=TRUE)
bigData=merge(bigData,data11,all=TRUE)
bigData=merge(bigData,data12,all=TRUE)

print(paste(Sys.time(),"Success: Data Merged into one File",year,sep=" "))

write.xlsx(bigData, "bigData.xlsx")

print(paste(Sys.time(),"Summarizing Analyzed Data",year,sep=" "))

big = sqldf("select f.* from bigData f where f.cik in (select d.cik from bigData d order by d.count desc limit 15) group by f.cik,f.date")

print(paste(Sys.time(),"Success: Summarized Analyzed Data",year,sep=" "))

write.xlsx(big, "big.xlsx")
write.xlsx(big, paste(getwd(),"/big.xlsx",sep = ""))

sink()