
library(data.table)
library(ggplot2)

file_url = "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
dest_file = ".\\data\\storm_data.csv.bz2"
if(!file.exists(dest_file)){
    download.file(file_url, dest_file)
}

#st_data = as.data.table(read.csv(dest_file))

fatalities_dt = st_data[, list(Total.Fatalities = sum(FATALITIES)), by = EVTYPE]
setorder(fatalities_dt, -Total.Fatalities, na.last = T)

injuries_dt = st_data[, list(Total.Injuries = sum(INJURIES)), by = EVTYPE]
setorder(injuries_dt, -Total.Injuries, na.last = T)

EXP = sort(unique(as.character(st_data$PROPDMGEXP)))
coefficient <- c(0,0,0,1,10,10,10,10,10,10,10,10,10,10^9,10^2,10^2,10^3,10^6,10^6)

convert = data.table("EXP" = EXP, "coefficient" = coefficient)

damage_dt = st_data[, c("EVTYPE", "PROPDMG", "PROPDMGEXP", "CROPDMG", "CROPDMGEXP")]

damage_dt$PROPCOEFFICIENT = convert$coefficient[match(damage_dt$PROPDMGEXP, convert$EXP)]
damage_dt$CROPCOEFFICIENT = convert$coefficient[match(damage_dt$CROPDMGEXP, convert$EXP)]
damage_dt$PROPDMG = damage_dt$PROPDMG * damage_dt$PROPCOEFFICIENT
damage_dt$CROPDMG = damage_dt$CROPDMG * damage_dt$CROPCOEFFICIENT
damage_dt$TOTAL = damage_dt$PROPDMG + damage_dt$CROPDMG

total_dmg_dt = damage_dt[, list(Total = sum(TOTAL)), by = EVTYPE]
setorder(total_dmg_dt, -Total, na.last = T)

plot_1 = ggplot(data = fatalities_dt[1:10,], 
                aes(x = reorder(EVTYPE, -Total.Fatalities), y = Total.Fatalities)) + 
    geom_bar(stat="identity") + 
    labs(title="The total amount of deaths of top-10 most dangerous disasters.", 
         y = "Amount of deaths", x = "") + 
    theme_light() + theme(axis.text.x = element_text(angle=90, vjust=0.5, hjust=1))

plot_2 = ggplot(data = injuries_dt[1:10,], 
                aes(x = reorder(EVTYPE, -Total.Injuries), y = Total.Injuries)) + 
    geom_bar(stat="identity") + 
    labs(title="The total amount of injuries of top-10 most dangerous disasters.", 
         y = "Amount of injeries", x = "") + 
    theme_light() + theme(axis.text.x = element_text(angle=90, vjust=0.5, hjust=1))

plot_3 = ggplot(data = total_dmg_dt[1:10,], 
              aes(x = reorder(EVTYPE, -Total), y = Total)) + 
    geom_bar(stat="identity") + 
    labs(title="The economical consequences of top-10 most costly disasters.", 
         y = "Economical damage ($USD)", x = "") + 
    theme_light() + theme(axis.text.x = element_text(angle=90, vjust=0.5, hjust=1))

print(plot_2)