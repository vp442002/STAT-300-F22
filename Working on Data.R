

# To read the CSV files directly:



library(data.table)

# put the files in your working directory, or use setwd()

setwd("C:/Users/vrajp/Downloads/Data/Data")

x <- fread("R1_2000_2021_Dam_Survey_Shed.csv", header = T)  

y <- fread("R3_2000_2021_Dam_Survey_Shed.csv", header = T)


#It takes several minutes to read it.
# Another way is using the databases. I created a database with two tables. 
# You can read the tables as follows (it is faster than the first method!):

#load the database and name it db
library(DBI)
library(RSQLite)
library(tidyverse)

db <- dbConnect(SQLite(), dbname = "example.sqlite")

# to check the tables in database
dbListTables(db)

dbWriteTable(db, "R1_Dam_Sur", as.data.frame(R1_Dam_Sur)) 

dbGetQuery(db, 
  'SELECT MidPoint_1 
  FROM R1_Dam_Sur')







# redaing first table
x <- dbGetQuery(db,'
  SELECT *
  FROM R1_Dam_Sur
  ')

# reading the second table
y <- dbGetQuery(db,'
  SELECT *
  FROM R3_Dam_Sur
  ')
############################### Loading data for region 1 #####################################

load("R1.rda")


ptn = '^MidPoint.*?'                                       # gets the names with starting MidPoint 
ndx = grep(ptn, names(R1_Dam_Sur), perl=T)
midpoint1 <- R1_Dam_Sur[,ndx]


ptn = '^Flown_Tally*?'                                       # gets the names with starting MidPoint 
ndx = grep(ptn, names(R1_Dam_Sur), perl=T)
flown1 <- R1_Dam_Sur[,ndx]

ptn = '^YEAR.*?'                                       # gets the names with starting MidPoint 
ndx = grep(ptn, names(R1_Dam_Sur), perl=T)
year1 <- R1_Dam_Sur[,ndx]





DSA <- function(midpoint, flown, year, n) {
  x <- R1_Dam_Sur$ACRES_FINAL * midpoint/65
  y <- R1_Dam_Sur$ACRES_FINAL * flown
  z <- R1_Dam_Sur$ACRES_FINAL * year
  
  t <- data.frame(x,y,z) 
  a <- c("Damage", "Survey", "Area_map")
  b <- paste(a,n)
  names(t) <- b 
  t
}

m <- data.frame(empty = rep(0, dim(midpoint1)[1]))

for (i in 1:22) { 
  
  n = 2000 + i - 1
  m <- data.frame(m, DSA(midpoint1[, i], flown1[, i], year1[,i], n))
  
}

part1 <- m[,-1]



#############################################  Creating Data frame for subwatershed ############3

subwatershed <- data.frame(HUC12 = R1_Dam_Sur$HUC12, DCA_CODE = R1_Dam_Sur$DCA_CODE, ACRES_FINAL = R1_Dam_Sur$ACRES_FINAL)


################################ Making tables #############################################


dbGetQuery(watershed, 
  'SELECT HUC12, SUM(ACRES_FINAL)
FROM watershed 
GROUP BY HUC12;')





dbGetQuery(watershed, 
  'SELECT HUC12, DCA_CODE, SUM(ACRES_FINAL)
FROM watershed 
GROUP BY HUC12, DCA_CODE;')



