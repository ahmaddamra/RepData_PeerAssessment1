## http://www.cookbook-r.com/Manipulating_data/Summarizing_data/
setwd("/home/ahmaddamra/Coursera/0050-ReproducibleResearch/peerassignment1/RepData_PeerAssessment1")
if (! file.exists("./activity.zip")){
  fileUrl <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip"
  download.file(fileUrl, destfile="./activity.zip", method="curl")
}

if (! file.exists("./activity.csv")){
  unzip("./activity.zip", files = NULL, list = FALSE, overwrite = TRUE,
        junkpaths = FALSE, exdir = "./", unzip = "internal",
        setTimes = FALSE)
}

activity <- read.csv("./activity.csv", sep=",", na.strings="NA")
head(activity)
names(activity)
str(activity)
summary(activity)

mean(is.na(activity$steps)) ## Are missing values important here?

mean(activity$steps,  na.rm = TRUE)
##[1] 37.3826
median(activity$steps,  na.rm = TRUE)
## [1] 0
## group data
## activitybyday <- aggregate(steps ~ date, activity, sum)
library(data.table)
activity <- data.table(activity)
ActivityByDay <- activity[, sum(steps), by = date]

##dyplyr package 
##require(dplyr)    
##df <- data.frame(A = c(1, 1, 2, 3, 3), B = c(2, 3, 3, 5, 6))
##df %>% group_by(A) %>% summarise(B = sum(B))

##summarize(by_package, mean(size))

## colnames(DT1) <- c("date","totalsteps")
## setnames(x,old,new)
setnames(ActivityByDay,c("Date","TotalSteps"))

library(xtable)
xt <- xtable(ActivityByDay)
print(xt, type = "html")
hist(ActivityByDay$TotalSteps, main = "Total number of steps taken per day", xlab="Total no. steps/day", ylab="Frequency")

ActivityByInterval <- activity[, mean(steps,na.rm = TRUE), by = interval]
library(lubridate)
x <- ymd("2012-10-01")
ActivityByInterval[,ts:=hm("00:00")+minutes(interval)]
ActivityByInterval[,ts:=x+minutes(interval)]
library(stringr)
str_pad(ActivityByInterval$interval, 4, pad = "0")
hm(gsub('^([a-z0-9]{2})([a-z0-9]+)$', '\\1:\\2', str_pad(ActivityByInterval$interval, 4, pad = "0")))
ActivityByInterval[,ts:=x+hm(gsub('^([a-z0-9]{2})([a-z0-9]+)$', '\\1:\\2', str_pad(ActivityByInterval$interval, 4, pad = "0")))]
setnames(ActivityByInterval,c("Interval","AverageSteps", "Time"))

plot(ActivityByInterval$Time,ActivityByInterval$AverageSteps,type = "l", main = "Average steps per Interval", xlab="Intervals as time of day", ylab="Average Steps")

ActivityByInterval[AverageSteps==max(ActivityByInterval$AverageSteps),1:2, with = FALSE]

nrow(activity[is.na(steps),])

activitynoNA <- activity

activitynoNA[is.na(steps),steps:=ActivityByInterval[Interval==interval,as.integer(AverageSteps)]]

activitynoNA[is.na(steps),steps:=ActivityByInterval[interval,AverageSteps]]
ActivityByInterval[805,AverageSteps]

##
activitywkdy = copy(activity)

weekdays(activitywkdy$date, abbr = TRUE)
weekend <- c('Sat','Sun')
tt <- ifelse(wday(activitywkdy$date, label = TRUE) %in% weekend,"weekend","weekday")
tt <- wday(activitywkdy$date,label = TRUE)
zz <- ifelse (tt %in% weekend,"weekend","weekday")
activitywkdy$daytype <- zz
activitywkdy[daytype=="weekend"]
activitywkdy <- transform(activitywkdy, daytype = factor(daytype))

qplot(Time, AverageSteps, data = ActivityBydaytype, facets = DayType ~ .)
library(scales)

sp <- ggplot(ActivityBydaytype, aes(x=Time, y=AverageSteps)) + geom_line() +
facet_grid(DayType ~ .) +
xlab("Time Interval") + ylab("Average No. of steps") +
ggtitle("Average no. of steps per interval by day type") + 
  scale_x_datetime(labels=date_format("%H:%M"))

sp

scale_x_continuous(expression(votes^alpha))

hm(ActivityBydaytype$Time)
labels=c("horrible", "ok", "awesome")
strptime(ActivityBydaytype$Time, "%H:%M")